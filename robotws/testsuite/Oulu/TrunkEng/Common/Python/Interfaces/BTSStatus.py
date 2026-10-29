"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import copy
import os
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (
    UnexpectedBTSStatus, BTSConnectionFailure, SSHConnectionFailure, EnvironmentIssue,
    ScriptIssue, WrongRadioStates, WrongSmodStates, WrongBbmodStates)

OnAirLib = {"availabilityStatus": "online",
            "operationalState": "enabled",
            "administrativeState": "unlocked"
            }

FaultyLib = {"availabilityStatus": "failed",
             "operationalState": "disabled",
             "administrativeState": "unlocked"
             }

MODULES = ["SMOD", "BBMOD", "RMOD"]


class BTSStatus:
    """
    BTSStatus is used for checking BTS states. User can change the expected states using BTSStatus.

    BTSStatus is called in common_resources.robot. If the class is already initiated once, import robot BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("BTSSTATUS")
    """
    airscale_product = True
    bts_info_after_faulting = None
    bts_ip = "192.168.255.129"  # default IP to ping in wait_for_bts_connection, can be changed if needed

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.connection = BuiltIn().get_library_instance("ADMIN")
        self.cell_operations = BuiltIn().get_library_instance("CELLS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.smod_lib = BuiltIn().get_library_instance("SMODS")
        self.collect_logs = None
        self.loop_info = ""
        if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
            BTSStatus.bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")

    def wait_for_bts_connection(self, timeout=600, ip_to_ping=bts_ip):
        """
        Wait for BTS SSH connection.

        :param int timeout: (Optional) Set to 600s if not given. Timeout in seconds.
        :param str ip_to_ping: (Optional) Set to 192.168.255.129 if not given. IP to ping.
        :raise BTSConnectionFailure: If BTS could not be connected within timeout.
        """
        start_time = datetime.now()
        connection = False
        info(f"Try to ping BTS ({ip_to_ping}) before attempting SSH connection. Wait max {timeout}s.")
        while (datetime.now() - start_time).total_seconds() < int(timeout) and not connection:
            try:
                connection = self._ping_ip(ip_to_ping)
            except SSHConnectionFailure as e:
                info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                error(f"{self.loop_info} Cannot send ping request, do not try to make SSH connection. If the problem"
                      "persists, take contact to script developer.")
                break
        if connection:
            info("BTS pings!")
            try:
                self.ssh.take_ssh_connection(ip_to_ping, alias="BTS")
            except SSHConnectionFailure as e:
                error(f"{self.loop_info} Could not connect BTS via SSH.\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise BTSConnectionFailure
            else:
                info("BTS connection successful! Wait time was {}s.".format(
                    (datetime.now() - start_time).total_seconds()))
                BuiltIn().sleep("5s")
                self.ssh.close_ssh_connection("BTS")
        else:
            error(f"{self.loop_info} No connection to BTS within wait time {timeout}s.")
            raise BTSConnectionFailure(f"No connection to BTS within wait time {timeout}s.")

    def check_bts_status(self):
        """
        Compare expected and current status. Expected status is changed with change_expected_status.
        """
        self.loop_info = f"Loop {self.logger.loop + 1}:"
        if BuiltIn().get_variable_value("${BBMODS_MASK}") or BuiltIn().get_variable_value("${BREAK_LOKI}"):
            print("Because only runtime id is found ->  get_bts_info")
            self.logger.debug("Because only runtime id is found when BBMOD removed -> get_bts_info")
            BTSStatus.bts_info_after_faulting = self.connection.get_bts_info(detailed_output=True)
        self._get_current_status()
        self._compare_expected_and_current_bts_statuses()

    def initiate_bts_status_check(self):
        """
        Initiate BTS status check. This is called in Common Test Setup (common_resources.robot)
        --> no need to call again if it is used.
        """
        self._find_unit_ids(initializing=True)
        self.bts.current_status = copy.deepcopy(self.bts.expected_status)
        self.logger.debug("Expecting following states in the beginning:\n{}".format(self.bts.expected_status))

    def get_active_and_passive_sw_versions(self, retry=0):
        """
        Get active and passive software versions.

        :param int retry: (Optional) Set to 0 if not given. Retries onece in retry is 0.
        :return tuple[str]: Active SW version, Passive SW version.
        """
        try:
            sw_info = self.connection.get_software_info(timeout=60)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"{self.loop_info} Unable to get active and passive sw versions. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to get active and passive sw versions from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    self.get_active_and_passive_sw_versions(retry=1)
                else:
                    error(f"{self.loop_info} Unable to get active and passive sw versions from admin and admin "
                          f"connection restart did not help.")
            raise BTSConnectionFailure
        return sw_info["Active SW version"], sw_info["Passive SW version"]

    def get_current_radio_status(self, print_info=False, retry=0):
        """
        Get current status of all radios.

        :return dict radio_status: Returns dictionary of radios f.ex.

        'FXEB(1.1.1.1)': {'administrativeState': 'Unlocked',
                         'availabilityStatus': 'NotInstalled',
                         'blockingState': 'Unblocked',
                         'operationalState': 'Disabled',
                         'usageState': 'Idle'},
        'FXEB(1.1.1.2)': {'administrativeState': 'Unlocked',
                         'availabilityStatus': 'NotInstalled',
                         'blockingState': 'Unblocked',
                         'operationalState': 'Disabled',
                         'usageState': 'Idle'}
        """
        radio_status = {}
        try:
            rmod_info = self.connection.get_frm(timeout=60, connection="log_admin")
            self.logger.debug("RMOD info: {}".format(rmod_info))
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            for rmod in rmod_info:
                for radio in self.bts.radios:
                    if rmod["id"]["configuration"] == radio.scf_dist_name and radio.name not in radio_status:
                        radio_status[radio.name] = rmod["status"]
            if print_info:
                info("Current status radios: {}".format(radio_status))
            return radio_status
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"{self.loop_info} Unable to get current radio status. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to get current radio status from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Try to get current radio status again.")
                    self.get_current_radio_status(print_info=print_info, retry=1)
                else:
                    error(f"{self.loop_info} Unable to get current radio status from admin and admin connection restart"
                          f"did not help.")
            raise BTSConnectionFailure

    def get_current_bbmod_status(self, retry=0):
        """
        Get current status of all bbmods.

        :param int retry: (Optional) Set to 0 if not given. Retries once if retry is 0.
        :return dict bbmod_status: Returns dictionary of bbmods f.ex.

        'ABIN1': {'administrativeState': 'Unlocked',
                  'availabilityStatus': 'Failed',
                  'operationalState': 'Disabled',
                  'usageState': 'Idle'},
        'ABIA2': {'administrativeState': 'Unlocked',
                  'operationalState': 'Enabled',
                  'usageState': 'Idle'},
        'ABIO3': {'administrativeState': 'Unlocked',
                  'availabilityStatus': 'Failed',
                  'operationalState': 'Disabled',
                  'usageState': 'Idle'}
        """
        bbmod_status = {}
        try:
            bbmod_info = self.connection.get_fbb_info(timeout=60, connection="log_admin")
            self.logger.debug("BBMOD info: {}".format(bbmod_info))
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            for fsp in bbmod_info:
                for bbmod in self.bts.bbmods:
                    if fsp["id"]["configuration"] == bbmod.scf_dist_name and bbmod.name not in bbmod_status:
                        bbmod_status[bbmod.name] = fsp["status"]
            info("Current status BBMODs: {}".format(bbmod_status))
            return bbmod_status
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"{self.loop_info} Unable to get current bbmod status. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to get current bbmod status from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method get_current_bbmod_status again after admin connection reset.")
                    self.get_current_bbmod_status(retry=1)
                elif retry == 1:
                    error("Unable to get current bbmod status from admin, because of session invalidation. Admin "
                          "connection restart did not help.")
            raise BTSConnectionFailure

    def check_if_current_and_expected_states_exist(self, current_states, expected_states):
        if not current_states:
            error(f"{self.loop_info} Unable to get current states.")
            raise EnvironmentIssue
        if not expected_states:
            error(f"{self.loop_info} Expected states are not given in test.")
            raise ScriptIssue
        self.logger.debug("Current states: {}".format(current_states))
        self.logger.debug("Expected states: {}".format(expected_states))
        return True

    @staticmethod
    def compare_current_state_to_expected(state, unit, expected_states, current_state, ok_str, fail_str):
        if state in expected_states and state in current_state:
            if current_state[state] != expected_states[state]:
                fail_str = "{}{} of {} is expected to be {}, but is {}. NOK\n".format(
                    fail_str, state, unit, expected_states[state], current_state[state])
            elif current_state[state] == expected_states[state]:
                ok_str = "{}{}'s {} is {}, as expected. OK\n".format(ok_str, unit, state, expected_states[state])
        elif state in expected_states and state not in current_state:
            fail_str = "{}{}'s {} is expected to be {}, but it is missing from current states, NOK\n".format(
                fail_str, unit, state, expected_states[state])
        return ok_str, fail_str

    def check_radio_states(self, expected_states=None, states_of_other_rmods=None, print_ok_states=False):
        """
        Checks radio states.

        :param expected_states: Dictionary that has radio.name as a key and it's states dictionary as value
                                Note if all radios are affected All_radios can be used as key.
        :param states_of_other_rmods: This is usable when just some radios of environment are faulted, and we want to
                                      check that other radios were not affected by fault.
        :param bool print_ok_states: If set to True prints states of all OK RMODs. If set to False and all rmods
                                     are ok prints All radio states OK.
        :return success: True if success, else False.
        """
        current_states = self.get_current_radio_status(print_info=True)
        if self.check_if_current_and_expected_states_exist(current_states, expected_states):
            fail_string = ""
            ok_string = ""
            faulty_loki_rmods = []
            print_txt = "BREAK_LOKI"
            print_txt2 = "F_LOKI_RMODS"
            for radio in current_states:
                if BuiltIn().get_variable_value("${BREAK_LOKI}"):
                    faulty_loki_rmods = BuiltIn().get_variable_value("${F_LOKI_RMODS}")
                if BuiltIn().get_variable_value("${BBMODS_MASK}"):
                    faulty_loki_rmods = BuiltIn().get_variable_value("${FAULTY_BBMODS_RMODS}")
                    print_txt = "BBMODS_MASK"
                    print_txt2 = "FAULTY_BBMODS_RMODS"
                if "All_radios" in expected_states:
                    if faulty_loki_rmods and radio in faulty_loki_rmods:
                        info(f"{radio} is allowed to be broken, because {print_txt} is in suite variables and the radio"
                             f" is in {print_txt2}. Current states of {radio} are {current_states[radio]}")
                    else:
                        for state in expected_states["All_radios"]:
                            ok_string, fail_string = self.compare_current_state_to_expected(
                                state, radio, expected_states["All_radios"], current_states[radio], ok_string,
                                fail_string)
                elif radio in expected_states:
                    if faulty_loki_rmods and radio in faulty_loki_rmods:
                        info(f"{radio} is allowed to be broken, because {print_txt} is in suite variables and the radio"
                             f" is in {print_txt2}. Current states of {radio} are {current_states[radio]}")
                    else:
                        for state in expected_states[radio]:
                            ok_string, fail_string = self.compare_current_state_to_expected(
                                state, radio, expected_states[radio], current_states[radio], ok_string, fail_string)
                if states_of_other_rmods:
                    if radio not in expected_states:
                        if faulty_loki_rmods and radio in faulty_loki_rmods:
                            info(f"{radio} is allowed to be broken, because {print_txt} is in suite variables and the "
                                 f"radio is in {print_txt2}.. Current states of {radio} are {current_states[radio]}")
                        else:
                            for state in states_of_other_rmods:
                                ok_string, fail_string = self.compare_current_state_to_expected(
                                    state, radio, states_of_other_rmods, current_states[radio], ok_string, fail_string)
            if ok_string and not fail_string and not print_ok_states:
                info("All radio states were OK.")
            if ok_string and print_ok_states:
                info("{}".format(ok_string))
            if fail_string:
                error(f"{self.loop_info} {fail_string}")
                if ok_string and not print_ok_states:
                    info("Other radio states were ok.")
                raise WrongRadioStates
        return True

    def check_bbmod_states(self, expected_states=None, states_of_other_bbmods=None, print_ok_states=False):
        """
        Checks BBMOD states.

        :param expected_states: Dictionary that has bbmod.name as a key and it's states dictionary as value.
                                For example 'ABIA1' or 'ABIO2' etc.
                                Note if all bbmods are affected All_bbmods can be used as key.
        :param states_of_other_bbmods: This is usable when just some bbmods of environment are faulted, and we want to
                                       check that other bbmods were not affected by fault.
        :param bool print_ok_states: If set to True prints states of all OK BBMODs. If set to False and all bbmods
                                     are ok prints All bbmod states OK.
        :return success: True if success, else False.
        """
        current_states = self.get_current_bbmod_status()
        if self.check_if_current_and_expected_states_exist(current_states, expected_states):
            fail_string = ""
            ok_string = ""
            for fsp in current_states:
                if "All_bbmods" in expected_states:
                    for state in expected_states["All_bbmods"]:
                        ok_string, fail_string = self.compare_current_state_to_expected(
                            state, fsp, expected_states["All_bbmods"], current_states[fsp], ok_string, fail_string)
                elif fsp in expected_states:
                    for state in expected_states[fsp]:
                        ok_string, fail_string = self.compare_current_state_to_expected(
                            state, fsp, expected_states[fsp], current_states[fsp], ok_string, fail_string)
                if states_of_other_bbmods:
                    if fsp not in expected_states:
                        for state in states_of_other_bbmods:
                            ok_string, fail_string = self.compare_current_state_to_expected(
                                state, fsp, states_of_other_bbmods, current_states[fsp], ok_string, fail_string)
            if ok_string and not fail_string and not print_ok_states:
                info("All BBMOD states were OK.")
            if ok_string and print_ok_states:
                info("{}".format(ok_string))
            if fail_string:
                error(f"{self.loop_info} {fail_string}")
                if ok_string and not print_ok_states:
                    info("Other BBMOD states were ok.")
                raise WrongBbmodStates
        return True

    def get_current_bts_status(self, retry=0):
        """
        Get current BTS status using MRBTS_M object.

        :param int retry: (Optional) Set to 0 if not given. Retries once if retry is 0.
        :return dict smod_status: Returns dictionary of smods f.ex.

        {'/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1': {
        'operationalState': 'Enabled', 'usageState': 'Idle', 'administrativeState': 'Unlocked',
        'availabilityStatus': 'NotInstalled', 'reasoningStatus': [], 'blockingState': 'Unblocked',
        'proceduralState': 'OnAir', 'testingState': 'Disabled', 'softwareState': 'Deploying',
        'powerBreakLockingState': 'Unlocked', 'btsReadyForSwUpdate': True}
        }
        """
        smod_status = {}
        # NOTE in fullrack there is also just one MRBTS_M
        try:
            components = self.connection.get_managed_objects("MRBTS_M")
            self.logger.debug("MRBTS_M parameters: {}".format(components))
            for bts in components:
                if "distName" not in bts or "parameters" not in bts or "stateInfo" not in bts["parameters"]:
                    error(f"{self.loop_info} Output of get_managed_objects has changed or cannot be collected. "
                          f"{components}")
                    raise EnvironmentIssue
                smod_status[bts["distName"]] = bts["parameters"]["stateInfo"]
            self.logger.debug("Current states of SMOD: {}".format(smod_status))
            return smod_status
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"{self.loop_info} Unable to get current bts status. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to get active alarms from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method get_current_bts_status again after admin connection reset.")
                    self.get_current_bts_status(retry=1)
                elif retry == 1:
                    error("Unable to get current bts status from admin, because of session invalidation. Admin "
                          "connection restart did not help.")
            raise BTSConnectionFailure

    def check_bts_state(self, expected_states=None):
        """
        Checks system module states.

        :param expected_states: States dictionary
        {
        'operationalState': 'Enabled',
        'administrativeState': 'Unlocked',
        'proceduralState': 'OnAir', '}
        }

        :return success: True if success, else False.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        current_states = self.get_current_bts_status()
        unit_name = self.smod_lib.get_master_smod_productname()
        if self.check_if_current_and_expected_states_exist(current_states, expected_states):
            fail_string = ""
            ok_string = ""
            for smod in current_states:
                for state in expected_states:
                    ok_string, fail_string = self.compare_current_state_to_expected(
                        state, unit_name, expected_states, current_states[smod], ok_string, fail_string)
            if ok_string:
                info("{}".format(ok_string))
            if fail_string:
                error(f"{self.loop_info} {fail_string}")
                raise WrongSmodStates
        return True

    def get_expected_bts_state(self, affected_cells=None, lte441a_active=False):
        """
        Get Expected BTS state.

        :param bool lte441a_active: Default value is False.
        :param list affected_cells: List of cells that are faulty. Default is None and returns onAir if not given.
        """
        state = {'operationalState': 'Enabled', 'administrativeState': 'Unlocked', 'proceduralState': 'OnAir'}
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        self.logger.debug("Affected_cells: {}, All cells: {}".format(affected_cells, self.bts.cells))
        if lte441a_active and affected_cells and self.bts.cells and len(affected_cells) == len(self.bts.cells):
            info("All cells of environment are affected, but because feature LTE441-a is active -> SMOD should be OnAir"
                 " and Enabled")
        elif affected_cells and self.bts.cells and len(affected_cells) == len(self.bts.cells):
            info("All cells of environment are affected -> SMOD should be IntegratedToRun and Disabled")
            state = {'operationalState': 'Disabled', 'administrativeState': 'Unlocked',
                     'proceduralState': 'IntegratedToRan'}
        return state

    def asix_is_faulty(self, smod):
        """
        Special check for ASIx to confirm if it is faulty during TruckRoll checks
        --> special Snapshot collection is needed.
        """
        smod_status = self._get_current_smod_status(smod.dist_name)
        if not smod_status:
            error(f"{self.loop_info} Cannot find status of SMOD {smod.name}.")
            return True
        if "ASI" in smod.name:
            if smod_status['operationalState'].lower() != "enabled":
                error(f"{self.loop_info} {smod.name} operationalState is not Enabled, as expected.")
                return True
        return False

    def _get_current_status(self, retry=0):
        """
        Finds the current BTS status for all units, updates self.bts.current_status.

        :param int retry: (Optional) Set to 0 if not given. Retries once if retry is 0.
        """
        try:
            for module in MODULES:
                for module_dict in self.connection.get_parameters_for_all(module):
                    self.logger.debug("module dict: {}".format(module_dict))
                    parsed_id = self._get_parsed_id(module_dict)
                    if parsed_id in self.bts.current_status:
                        for state in self.bts.current_status[parsed_id]:
                            try:
                                self.bts.current_status[parsed_id][state] = module_dict[state].lower()
                            except KeyError:
                                if state == "availabilityStatus":
                                    info("Unit does not have availabilityStatus when it is online. Assume value to "
                                         "'online'")
                                    self.bts.current_status[parsed_id][state] = "online"
                                else:
                                    error(f"{self.loop_info} Cannot find {state} from module_dict.")
                                    info(f"Module_dict: {module_dict}")
                                    raise KeyError
                    else:
                        info(f"Skipped {parsed_id} because it is not in expected status.")
            current_cell_states = self.cell_operations.get_current_cell_states()
            for cell in current_cell_states:
                self.bts.current_status[cell] = current_cell_states[cell]
            if BTSStatus.airscale_product:
                fhs_modules = self.connection.get_parameters_for_all("FHS")
                if fhs_modules:
                    for fhs_dicts in fhs_modules:
                        mod_dist_name = fhs_dicts["id"]
                        parsed_id = mod_dist_name[mod_dist_name.rfind("/") + 1:]
                        self.bts.current_status[parsed_id]["operationalState"] = fhs_dicts["operationalState"].lower()
                        self.bts.current_status[parsed_id]["administrativeState"] =\
                            fhs_dicts["administrativeState"].lower()
            self.logger.debug("Current status is: {}".format(self.bts.current_status))
            print("Current status: {}".format(self.bts.current_status))
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"{self.loop_info} Unable to get current BTS status for units. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to get current status from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    self._get_current_status(retry=1)
                else:
                    error(f"{self.loop_info} Unable to get current status from admin and admin connection restart "
                          f"did not help.")
            raise BTSConnectionFailure

    def _get_current_smod_status(self, dist_name, retry=0):
        """
        Get current smod status

        :param str dist_name: Dist name of the SMOD.
        :param int retry: (Optional) Set to 0 if not given. Retries once if retry is 0.
        """
        try:
            smods = self.connection.get_managed_objects('SMOD_L')
            for smod in smods:
                if dist_name == smod['distName']:
                    self.logger.debug(f"SMOD status: {smod['parameters']['stateInfo']}")
                    return smod['parameters']['stateInfo']
        except AliasLookupError as e:
            error(f"{self.loop_info} Cannot find SMOD with distName {dist_name}, no connection to admin.\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        except (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                AdminApiTerminatedException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AliasInUse, AliasLookupError) as e:
            tb = ''.join(format_exception(type(e), e, e.__traceback__))
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to get current smod status from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method _get_current_smod_status again after admin connection reset.")
                    self._get_current_smod_status(dist_name, retry=1)
                elif retry == 1:
                    error("Unable to get surrent smod status from admin, because of session invalidation. Admin "
                          "connection restart did not help.")
        return {}

    def _change_expected_status(self, unit, status_library):
        """
        Change expected status for given unit.

        :param str unit: Unit in question.
        :param dict status_library: Status changes (only the changing values, no need to give the ones that
                                    remain the same).

        Robot Example
        *** Variables ***
        &{step1_statuses}   operationalState=Disabled    availabilityStatus=Offline
        *** Test Cases ***
        TestCase
        .......
            Change Expected Status    unit    ${step1_statuses}
        .......
        """
        try:
            for status in status_library:
                if status in self.bts.expected_status[unit]:
                    self.bts.expected_status[unit][status] = status_library[status].lower()
        except TypeError as e:
            error(f"{self.loop_info} TypeError. Did you give the status library in the correct format or is the "
                  "unit correct? Check instructions."
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def _compare_expected_and_current_bts_statuses(self):
        """
        Compares the expected BTS status to current status.

        :raise UnexpectedBTSStatus: If the BTS has unexpected states.
        """
        success = True
        extra_info = BuiltIn().get_variable_value("${EXTRA_INFO_FOR_LOOP}", default="")
        extra_info = extra_info.replace("_", " ")
        faulty_loki_cells, faulty_loki_rmods, faulty_loki_bbmod = [], [], []
        print_txt = "BREAK_LOKI"
        if BuiltIn().get_variable_value("${BREAK_LOKI}"):
            faulty_loki_cells = BuiltIn().get_variable_value("${F_LOKI_CELLS}")
            faulty_loki_rmods = BuiltIn().get_variable_value("${F_LOKI_RMODS}")
            faulty_loki_bbmod = BuiltIn().get_variable_value("${F_LOKI_BBMOD}")
            info(f"BREAK_LOKI is True and cells {faulty_loki_cells} are allowed to be disabled, {faulty_loki_rmods}"
                 f" are allowed to be disable and {faulty_loki_bbmod} is allowed to be degraded.")
        if BuiltIn().get_variable_value("${BBMODS_MASK}"):
            faulty_loki_cells = BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")
            faulty_loki_rmods = BuiltIn().get_variable_value("${FAULTY_BBMODS_RMODS}")
            faulty_loki_bbmod = BuiltIn().get_variable_value("${FAULTY_BBMODS}")
            info(f"BBMODS_MASK has been given and cells {faulty_loki_cells} are allowed to be disabled, "
                 f"{faulty_loki_rmods} are allowed to be disable and {faulty_loki_bbmod} is allowed to be disabled.")
            print_txt = "BBMODS_MASK"
        for module in self.bts.expected_status:
            for state in self.bts.expected_status[module]:
                try:
                    if self.bts.current_status[module][state] != self.bts.expected_status[module][state]:
                        if "Cell" in module and BuiltIn().get_variable_value("${SERIAL_CONSOLE}"):
                            info(f"State of {module} is {self.bts.current_status[module][state]}, ignore it because "
                                 f"serial logging is active.")
                        elif (faulty_loki_cells and "Cell" in module and module in faulty_loki_cells) or (
                                faulty_loki_bbmod and module in faulty_loki_bbmod) or (
                                faulty_loki_rmods and module in faulty_loki_rmods):
                            info(f"State of {module} is {self.bts.current_status[module][state]}, ignore it because "
                                 f"{print_txt} is active.")
                        else:
                            error(f"{self.loop_info}{extra_info} State of {module} is "
                                  f"{self.bts.current_status[module][state]} "
                                  f"when it should be {self.bts.expected_status[module][state]}.")
                            success = False
                except KeyError as e:
                    if "Cell" in module and state == "availabilityStatus":
                        self.logger.debug(f"AvailabilityStatus of {module} is empty, meaning it is OK. ")
                    else:
                        error(f"{self.loop_info}{extra_info} Missing {state} of {module}.\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                        success = False
        if success:
            info("All BTS units were OK.")
        else:
            if "${OMKPI_CASE}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${OMKPI_CASE}"):
                info("OMKPI test. Problems when checking BTS Status. Do not calculate KPIs (set CALCULATE_KPI to "
                     "False).")
                BuiltIn().set_suite_variable("${CALCULATE_KPI}", "${False}")
            raise UnexpectedBTSStatus("BTS has unexpected states")

    def _ping_ip(self, ip):
        """
        Ping the given ip address.

        :param str ip: IP address.
        :raise SSHConnectionFailure: If there are problems with ping.
        :return boolean: Ping success.
        """
        command = "ping -n 5 {}".format(ip)
        if os.name != "nt":
            command = "ping -c 5 {}".format(ip)  # Linux environment
        try:
            handle = os.popen("{}".format(command))
            output = "".join(handle.readlines())
            handle.close()
            BuiltIn().sleep("1s")
            percentages = ["50%", "60%", "70%", "80%", "90%"]
            if output:
                percent_50_to_90 = list(percent for percent in percentages if percent in output)
                if ((output.count("Request timed out.") == 5) or
                        ("100%" in output) or
                        (percent_50_to_90 and "Destination host unreachable" in output) or
                        ("TTL expired in transit" in output)):
                    return False
                else:
                    info("IP {} is pinging.\n{}".format(ip, output))
                    return True
            else:
                error(f"No output get for {command}")
                return False
        except (OSError, ValueError) as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{self.loop_info} Problems when trying to ping IP '{ip}'.")
            if "No space left on device" in str(e):
                self.collect_logs.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
            raise SSHConnectionFailure

    def _check_if_unit_is_required_unit(self, module_internal_id, unit, bts_dict):
        """ Check if unit is required unit """
        if "id" in unit and 'internal' in unit['id'] and 'configuration' in unit['id']:
            if str(unit['id']['internal']) == module_internal_id:
                configuration_name = str(unit['id']['configuration'])
                for unit_object in bts_dict:
                    if unit_object.scf_dist_name == configuration_name:
                        self.logger.debug(f"{module_internal_id} == {unit_object.name}")
                        return unit_object.name
        return None

    def _get_configuration_name_from_btsinfo(self, module_internal_id, units, bts_dict):
        """Get configuration name from btsinfo"""
        conf_name = None
        if units:
            for unit in units:
                self.logger.debug(f"{unit}, {type(unit)}")
                if type(unit) is dict:  # if "BBMOD_R" in module_internal_id
                    conf_name = self._check_if_unit_is_required_unit(module_internal_id, unit, bts_dict)
                elif type(unit) is str:  # if "RMOD_R" in module_internal_id
                    for rmod in units[unit]:
                        conf_name = self._check_if_unit_is_required_unit(module_internal_id, rmod, bts_dict)
                        if conf_name:
                            break
                if conf_name:
                    break
        return conf_name

    def _check_if_unit_is_expectedly_faulty(self, module_internal_id):
        """
        Check if unit is expectedly faulty checks the name of unit that is missing serial number information.

        :param str module_internal_id: Internal name of unit, for example:
                                       /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-2
        """
        try:
            units = []
            bts_dict = {}
            if BTSStatus.bts_info_after_faulting:  # there are faulty_bbmods and rmods
                if "BBMOD_R" in module_internal_id:
                    units = BTSStatus.bts_info_after_faulting["requestMessage"]["basebandModules"]
                    bts_dict = self.bts.bbmods
                elif "RMOD_R" in module_internal_id:
                    units = BTSStatus.bts_info_after_faulting['requestMessage']['radioModules']
                    bts_dict = self.bts.radios
                return self._get_configuration_name_from_btsinfo(module_internal_id, units, bts_dict)
            return None
        except (KeyError, TypeError, AttributeError) as e:
            error(f"Exception {e.__class__.__name__}: {e}")
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            return None

    def _get_parsed_id(self, module_dict):
        """
        Get parsed id for RMOD, BBMOD and SMOD.

        :param dict module_dict: Module dict.
        :return str parsed_id: Parsed id.
        """
        mod_ser_no = module_dict.get("serialNumber", "")
        self.logger.debug(f"mod_ser_no: {mod_ser_no}")
        mod_dist_name = str(module_dict["id"])
        if not mod_ser_no:
            if not BTSStatus.bts_info_after_faulting:
                BTSStatus.bts_info_after_faulting = self.connection.get_bts_info(detailed_output=True)
            expectedly_faulty = self._check_if_unit_is_expectedly_faulty(mod_dist_name)
            if expectedly_faulty:
                info(f"Unit {mod_dist_name} doesn't have any serialNumber, but it is ok, expected to be faulty.")
                return expectedly_faulty
            else:
                warning(f"{self.loop_info} Serial number is missing from module_dict ({mod_dist_name}). Cannot get "
                        f"parsed id.")
                return "UNKNOWN"
        module_r_name = mod_dist_name[mod_dist_name.rfind("/") + 1:]
        parsed_id = mod_ser_no
        if "RMOD" in module_r_name:
            parsed_id = self.bts.find_name_with_serial_number(self.bts.radios, mod_ser_no)
        elif "BBMOD" in module_r_name:
            parsed_id = self.bts.find_name_with_serial_number(self.bts.bbmods, mod_ser_no)
        elif "SMOD" in module_r_name:
            parsed_id = self.bts.find_name_with_serial_number(self.bts.smods, mod_ser_no)
        return parsed_id

    def _find_unit_ids(self, initializing=False, retry=0):
        """
        Find all unit IDs. If initializing in progress, adds missing keys to dictionary self.bts.expected_status.

        :param initializing: (Optional) Set to True if initializing in progress. If not provided, initializing set
                                        to False.
        :param int retry: (Optional) Set to 0 if not given. Retries once if retry is 0.
        """
        self.logger.debug("Expected status before change:\n{}".format(self.bts.expected_status))
        try:
            for module in MODULES:
                for module_dict in self.connection.get_parameters_for_all(module):
                    parsed_id = self._get_parsed_id(module_dict)
                    self.logger.debug(f"module_dict: {module_dict}")
                    if initializing:
                        BTSStatus.bts_info_after_faulting = None
                        if module == "SMOD":
                            self.check_if_airscale_product(module_dict)
                        self.bts.expected_status[parsed_id] = {}
                        for status in OnAirLib:
                            if status in module_dict:
                                self.bts.expected_status[parsed_id][status] = None
                        self._change_expected_status(parsed_id, OnAirLib)
                    else:
                        faulty_bbmods = BuiltIn().get_variable_value("${FAULTY_BBMODS}")
                        faulty_rmods = BuiltIn().get_variable_value("${FAULTY_BBMODS_RMODS}")
                        if faulty_bbmods or faulty_rmods:
                            if not BTSStatus.bts_info_after_faulting:
                                BTSStatus.bts_info_after_faulting = self.connection.get_bts_info(detailed_output=True)
                        if (faulty_bbmods and parsed_id in faulty_bbmods) or (faulty_rmods and parsed_id in
                                                                              faulty_rmods):
                            self._change_expected_status(parsed_id, FaultyLib)
                        else:
                            self._change_expected_status(parsed_id, OnAirLib)
            if initializing:
                self._all_cells = self.cell_operations.get_all_cells()
            for cell in self._all_cells:
                if initializing:
                    self.bts.expected_status[cell] = {}
                    for status in OnAirLib:
                        if status in self._all_cells[cell]["status"]:
                            self.bts.expected_status[cell][status] = None
                self._change_expected_status(cell, OnAirLib)
            if BTSStatus.airscale_product:
                fhs_modules = self.connection.get_parameters_for_all("FHS")
                if fhs_modules:
                    for fhs_dicts in fhs_modules:
                        mod_dist_name = fhs_dicts["id"]
                        parsed_id = mod_dist_name[mod_dist_name.rfind("/") + 1:]
                        self.bts.expected_status[parsed_id] = {
                            "operationalState": "enabled", "administrativeState": "unlocked"}
            self.logger.debug("Expected status after change:\n{}".format(self.bts.expected_status))
            print("Expected status:\n{}".format(self.bts.expected_status))
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"{self.loop_info} Unable to get active and passive sw versions. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to find unit ids, because of session invalidation from admin."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method _get_active_alarms_from_admin again after admin connection reset.")
                    self._find_unit_ids(initializing=initializing, retry=1)
                elif retry == 1:
                    error("Unable to find unit ids, because of session invalidation. Admin connection "
                          "restart did not help.")
            raise BTSConnectionFailure

    def check_if_airscale_product(self, module_dict):
        """
        Check if Airscale Product mwthod checks if SMOD is AirScale product. This is needed because for example FHS is
        not found from FSMF.

        :param dict module_dict: Module dictionary.
        :return True is AirScale product, else False
        """
        print("Check if SMOD is AirScale product")
        mod_productname = str(module_dict["productName"])
        if "AirScale" in mod_productname or "ASI" in mod_productname:
            print("SMOD is AirScale product")
            BTSStatus.airscale_product = True
        else:
            print(f"SMOD is not AirScale product, it is {mod_productname} product.")
            BTSStatus.airscale_product = False
        self.logger.debug("BTSStatus.airscale_product: {}".format(BTSStatus.airscale_product))
