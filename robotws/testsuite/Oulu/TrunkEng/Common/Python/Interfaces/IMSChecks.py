"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Resources.GetValuesFromImsHistory import GetValuesFromImsHistory
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (
    BTSConnectionFailure, StateNotInIms2History, EnvironmentIssue, ScriptIssue)


class IMSChecks:
    """
    Collection of checks from IMS.
    """
    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.cell_operations = BuiltIn().get_library_instance("CELLS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.collect_logs = None

        self.ims_history = GetValuesFromImsHistory()

    def check_smod_rmod_and_bbmod_states(self, check_link_status=True, file_name=None, ignore_state=None):
        """
        Saves ims2 file and checks SMOD, RMOD and BBMOD states and link status from the ims2 file.

        :param bool check_link_status: If True checks link status, if False skips link status check.
        :param str file_name: (Optional) File name of ims2 file. If not given ims2 log is fetched with name
                              ims_history_<timestamp>.ims2.
        :param str ignore_state: (Optional) State to ignore. If not given all states are checked. Possible values:
                                 "Commissioned", "IntegratedToRan", "OnAir". Default is None.
        """
        if file_name:
            log_name = f"{file_name.replace(' ', '_')}.ims2"
            ims_file_path = os.path.join(self.logger.log_dir, log_name)
        else:
            time_stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            ims_file_path = os.path.join(self.logger.log_dir, f"ims_history_{time_stamp}.ims2")
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        try:
            if os.path.exists(ims_file_path) and os.path.isfile(ims_file_path):
                print(f"IMS file already exists {ims_file_path}, no need to collect it again.")
            else:
                self.collect_logs.collect_ims(ims_file_path)
            if self.collect_logs.ims_file_name_after_swdl:
                self.logger.debug("Collecting KPIs from IMS file after SWDL, give two ims files to calculate KPIs")
                print("Collecting KPIs from IMS file after SWDL, give two ims files to calculate KPIs")
                ims_file_path = [self.collect_logs.ims_file_name_after_swdl, ims_file_path]
            if self.collect_logs.ims_file_from_disconnection:
                print(f"Ims from disconnection {self.collect_logs.ims_file_from_disconnection}")
                if isinstance(ims_file_path, list):  # ims2 after cells disabled was get and disconnection logs
                    self.logger.debug("ims2 after cells disabled was get and also disconnection logs")
                    ims_file_path.insert(1, self.collect_logs.ims_file_from_disconnection)
                else:  # ims2 after cells disabled was not get
                    self.logger.debug("ims2 after cells disabled was not get, use ims2 from disconnection and after "
                                      "swdl")
                    ims_file_path = [self.collect_logs.ims_file_from_disconnection, ims_file_path]
            self._check_smod_states_from_ims_history(ims_file_path, ignore_state=ignore_state)
            self.check_that_rmods_were_reset(ims_file_path=ims_file_path)
            self.check_that_bbmods_were_reset(ims_file_path=ims_file_path)
            if check_link_status:
                self.check_link_status_from_ims_history(ims_file_path)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to check smod rmod and bbmod_states from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise BTSConnectionFailure("Unable to check smod rmod and bbmod_states from ims history.")
        finally:
            self.ims_history.clear_values()

    def check_if_selected_units_were_reset(self, selected_smods=None, selected_bbmods=None, selected_rmods=None,
                                           selected_cells=None, rat=None):
        """
        Checks that selected units were reset during testing. Check is done from ims2 history.

        :param str/list selected_smods: List of SMOD names to be checked.
        :param str/list selected_bbmods: List of BBMOD names to be checked.
        :param str/list selected_rmods: List of RMOD names to be checked.
        :param str/list selected_cells: List of cell ids to be checked. For example ["LNCell-1", "LNCell-2"]
        :param str rat: RAT of the cells. LN/NR. Default is LN.
        """
        if selected_smods:
            if isinstance(selected_smods, str):
                selected_smods = [selected_smods]
            info(f"Check if selected SMODs {selected_smods} were reset during test.")
            error("'Check Selected Units Were Reset' -KW does not support selected_smods yet. "
                  "Create JIRA ticket if needed.")
        if selected_bbmods:
            if isinstance(selected_bbmods, str):
                selected_bbmods = [selected_bbmods]
            info(f"Check if selected BBMODs {selected_bbmods} were reset during test.")
            self.check_that_bbmods_were_reset(selected_bbmods)
        if selected_rmods:
            if isinstance(selected_rmods, str):
                selected_rmods = [selected_rmods]
            info(f"Check if selected RMODs {selected_rmods} were reset during test.")
            if "${F_LOKI_RMODS}" in BuiltIn().get_variables():
                print(f"DEBUG F_LOKI_RMODS: {BuiltIn().get_variable_value('${F_LOKI_RMODS}')}")
                f_loki_rmods = BuiltIn().get_variable_value("${F_LOKI_RMODS}")
                for f_r in f_loki_rmods:
                    if f_r in selected_rmods:
                        info(f"{f_r} is in F_LOKI_RMODS. It is allowed to stay disabled because LOKI to which it "
                             f"belongs is disabled.")
                        selected_rmods.remove(f_r)
            if BuiltIn().get_variable_value('${FAULTY_BBMODS_RMODS}'):
                print(f"DEBUG FAULTY_BBMODS_RMODS: {BuiltIn().get_variable_value('${FAULTY_BBMODS_RMODS}')}")
                rmods = BuiltIn().get_variable_value("${FAULTY_BBMODS_RMODS}")
                for f_r in rmods:
                    if f_r in selected_rmods:
                        info(f"{f_r} is in FAULTY_BBMODS_RMODS. It is allowed to stay disabled because BBMOD to which "
                             f"it belongs is disabled.")
                        selected_rmods.remove(f_r)
            self.check_that_rmods_were_reset(selected_rmods)
        if selected_cells:
            if isinstance(selected_cells, str):
                selected_cells = [selected_cells]
            info(f"Check if selected cells {selected_cells} were reset during test.")
            print_variable = "F_LOKI_CELLS"
            print_source = "LOKI"
            f_loki_cells = []
            if BuiltIn().get_variable_value('${F_LOKI_CELLS}'):
                print(f"DEBUG F_LOKI_CELLS: {BuiltIn().get_variable_value('${F_LOKI_CELLS}')}")
                f_loki_cells = BuiltIn().get_variable_value("${F_LOKI_CELLS}")
            if BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}"):
                print(f"DEBUG FAULTY_BBMODS_CELLS: {BuiltIn().get_variable_value('${FAULTY_BBMODS_CELLS}')}")
                f_loki_cells = BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")
                print_variable = "FAULTY_BBMODS_CELLS"
                print_source = "BBMOD"
            if f_loki_cells:
                for f_c in f_loki_cells:
                    if f_c in selected_cells:
                        info(f"{f_c} is in {print_variable}. It is allowed to stay disabled because {print_source} to "
                             f"which it belongs is disabled.")
                        selected_cells.remove(f_c)
            self.logger.debug(f"DEBUG: Check if selected cells {selected_cells} were reset during test.")
            self.check_if_selected_cells_were_disabled_and_enabled(selected_cells, rat=rat)
        if selected_smods:  # Remove this if when selected_smods is supported
            raise ScriptIssue("Check Selected Units Were Reset -KW does not support selected_smods yet. "
                              "Create JIRA ticket if needed.")

    def check_that_bbmods_were_reset(self, selected_bbmods=None, ims_file_path=None):
        """
        Checks that operationalState of BBMOD_L was disabled and enabled during testing. Check is done from ims2 history

        :param list selected_bbmods: List of BBMOD serial numbers to be checked.
        :param str ims_file_path: Path to ims file. If path is not given ims2 log is fetched.
        :raise StateNotInIms2History: If not all BBMOD_L had disabled and enabled states during testing.
        """
        if selected_bbmods:
            self._check_that_selected_bbmods_were_reset(selected_bbmods, ims_file_path)
            return
        for smod in self.bts.smods:
            # If there is at least one non-ASOE SMOD or non FSMr3 SMOD, check BBMODs
            if not any(smod_type for smod_type in ["ASOE", "FSMr3", "FSMF", "ASOG", "ASOH"] if smod_type in smod.name):
                self._check_disabled_enabled_component_from_ims_history("BBMOD_L", ims_file_path)
                return
        info("Skip BBMOD check since there is ASOE/ASOG/ASOH/FSMr3 in configuration.")

    def _get_dsps_and_socs(self, dsps, rat):
        all_dsps = {}
        dsp_states = {"stateInfo": {"proceduralState": "Resetting"}}
        if rat:
            socs = self.admin.get_managed_objects("SOC_L")
            for dsp in dsps:
                for soc in socs:
                    rat_correctness = (
                        "rat" in soc["parameters"]
                        and rat in list(soc["parameters"]["rat"])
                    )
                    if soc['distName'] in dsp['distName'] and rat_correctness:
                        all_dsps[dsp['distName']] = dsp_states
        else:
            for dsp in dsps:
                all_dsps[dsp['distName']] = dsp_states
        self.logger.debug(f"All DSPs: \n{all_dsps}")
        return all_dsps

    def check_that_dsps_were_resetting(self, retry=0, rat=""):
        """
        Checks that proceduralState of DSP_L was Resetting during testing. Check is done from ims2 history.

        :param int retry: If 0, retry is done if there is ErrorCode 6
        :param str rat: (Optional) RAT of the cells. LN/NR. Default is empty. If empty, all DSPs are checked.
        :raise StateNotInIms2History: If not all DSP_L had Resetting states during testing.
        """
        try:
            dsps = self.admin.get_managed_objects("DSP_L")
            if not dsps:
                info("There are no DSP_Ls with ABIO unit. Contact script developer in other cases."
                     " Skipping DSP reset check")
            else:
                info("Check from ims2 history if all DSPs have had proceduralState: Resetting during testing.")
                all_dsps = self._get_dsps_and_socs(dsps, rat)
                ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
                self.admin.collect_im_snapshot(ims_file_path, timeout=900, connection="log_admin")
                if self.ims_history.check_if_in_history(ims_file_path, all_dsps):
                    possible_rat_text = f" for RAT {rat}" if rat else ""
                    info(f"All DSPs{possible_rat_text} have had 'proceduralState: Resetting' during testing, OK.")
                else:
                    error("Resetting DSPs were not found from ims2 history, NOK.")
                    raise StateNotInIms2History(f"States {all_dsps} were not found from ims2 history")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to check proceduralState of DSP_L. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to check proceduralState of DSP_L from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    info("Call method check_that_dsps_were_resetting again after admin connection reset.")
                    self.check_that_dsps_were_resetting(retry=1)
                elif retry == 1:
                    error("Unable to check that dsps were resetting from admin, because of session invalidation. Admin "
                          "connection restart did not help.")
            raise BTSConnectionFailure
        finally:
            self.ims_history.clear_values()

    def check_that_rmods_were_reset(self, selected_rmods=None, ims_file_path=None):
        """
        Checks that operationalState of RMOD_L was disabled and enabled during testing. Check is done from ims2 history.

        :param list selected_rmods: List of RMOD names to be checked.
        :param str ims_file_path: Path to ims file. If path is not given ims2 log is fetched.
        :raise StateNotInIms2History: If not all RMOD_L had disabled and enabled states during testing.
        """
        if not selected_rmods:
            self._check_disabled_enabled_component_from_ims_history("RMOD_L", ims_file_path)
        else:
            serial_numbers = []
            for rmod_name in selected_rmods:
                for rmod in self.bts.radios:
                    if rmod.name == rmod_name:
                        serial_numbers.append(rmod.serial_number)
                        break
            self.check_if_selected_rmods_disabled_and_enabled(serial_numbers)

    def check_that_fhs_and_rmods_were_reset(self):
        """
        Checks that operationalState of FHS_L and RMOD_L was disabled and enabled during testing. Check is done from
        ims2 history.
        :raise StateNotInIms2History: If not all FHS_L and RMOD_L have had disabled and enabled states during testing.
        """
        ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
        log_collector = BuiltIn().get_library_instance("COLLECTLOGS")
        try:
            if os.path.exists(ims_file_path) and os.path.isfile(ims_file_path):
                print(f"IMS file already exists {ims_file_path}, no need to collect it again.")
            else:
                log_collector.collect_ims(ims_file_path)
            self._check_disabled_enabled_component_from_ims_history("FHS_L", ims_file_path)
            self.check_that_rmods_were_reset(ims_file_path=ims_file_path)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to check that fhs and rmods were reset from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise BTSConnectionFailure
        finally:
            self.ims_history.clear_values()

    def check_link_status_from_ims_history(self, ims_file_path="", retry=0):
        """
        Check from ims2 history that link status was updated.
        In LTE: s1 link status was unavailable and available during testing.
        in 5G: ng link was Active and Inactive

        :param str ims_file_path: Path to ims file. If path is not given ims2 log is fetched.
        :param int retry: If 0, retry is done if there is ErrorCode 6
        :raise StateNotInIms2History: Raises exception that state not in history.
        """
        try:
            if not ims_file_path:
                ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
                self.admin.collect_im_snapshot(ims_file_path, timeout=900, connection="log_admin")
            states_1 = {'s1LinkStatus': 'unavailable'}
            states_2 = {'s1LinkStatus': 'available'}
            component = "LNMME_R"
            if self.bts.check_if_5g_environment(print_eventlog=False):
                states_1 = {'ngLinkStatus': 'Inactive'}
                states_2 = {'ngLinkStatus': 'Active'}
                component = "SERVEDAMF_R"
            if ("${IGNORE_STATE}" in BuiltIn().get_variables() and BuiltIn().get_variable_value(
                    "${IGNORE_STATE}") == "SERVEDAMF"):
                info("Ignore checking link status for SERVEDAMF from ims2 history (because suite variable "
                     "${IGNORE_STATE} has value SERVEDAMF).")
                return
            all_components = {}
            components = self.admin.get_managed_objects(component)
            if components:
                for comp in components:
                    all_components[comp['distName']] = [states_1, states_2]
                if self.ims_history.check_multiple_states_from_history(ims_file_path, all_components):
                    info(f"{component} was {''.join(states_1.values())} and {''.join(states_2.values())} "
                         f"during testing, OK.")
                else:
                    error(f"States {''.join(states_1.values())} and {''.join(states_2.values())} were not found "
                          f"from ims2 history for {component}, NOK.")
                    raise StateNotInIms2History(f"States {all_components} were not found from ims2 history")
            else:
                info(f"Managed object {component} was not found. Link status is not checked from ims2 logs.")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to check link status from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to Unable to check link status from ims history, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method get_current_bbmod_status again after admin connection reset.")
                    self.check_link_status_from_ims_history(ims_file_path=ims_file_path, retry=1)
                elif retry == 1:
                    error("Unable to Unable to check link status from ims history, because of session invalidation. "
                          "Admin connection restart did not help.")
            raise BTSConnectionFailure
        finally:
            self.ims_history.clear_values()

    def check_if_selected_cells_were_disabled_and_enabled(
            self, cell_ids=None, all_cells=False, file_name=None, rfs=False, rat="LN"):
        """
        Checks if selected cells were disabled and enabled during testing or if no cells all cells have been enabled
        the whole ims2 history.

        :param list cell_ids: Cell ids to be checked. For example ["1"]
        :param boolean all_cells: Check that all cells were disabled and enabled. cell_ids can be empty
        :param str file_name: (Optional) File name of ims2 file. If not given ims2 log is fetched with name
                              ims_history_<timestamp>.ims2.
        :param bool rfs: If True checks that cells were disabled and enabled also from other BTS.
        :param str rat: RAT of the cells. LN/NR. Default is LN.
        """
        rfs_file_path = ""
        if file_name:
            log_name = f"{file_name.replace(' ', '_')}.ims2"
            ims_file_path = os.path.join(self.logger.log_dir, log_name)
        else:
            time_stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            ims_file_path = os.path.join(self.logger.log_dir, f"ims_history_{time_stamp}.ims2")
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        try:
            if os.path.exists(ims_file_path) and os.path.isfile(ims_file_path):
                print(f"IMS file already exists {ims_file_path}, no need to collect it again.")
            else:
                self.collect_logs.collect_ims(ims_file_path)
            if rfs:
                rfs_file_path = ims_file_path[:-5] + "_remote.ims2"
                if os.path.exists(rfs_file_path) and os.path.isfile(rfs_file_path):
                    print(f"IMS file already exists {ims_file_path}, no need to collect it again.")
                else:
                    self.collect_logs.collect_ims(rfs_file_path, connection="log_admin_remote")
            if self.collect_logs.ims_file_name_after_swdl:
                print(f"IMS during SWDL before admin reset: {self.collect_logs.ims_file_name_after_swdl}")
                ims_file_path = [self.collect_logs.ims_file_name_after_swdl, ims_file_path]
            if self.collect_logs.ims_file_from_disconnection:
                print(f"Ims from disconnection {self.collect_logs.ims_file_from_disconnection}")
                if isinstance(ims_file_path, list):  # ims2 after cells disabled was get and disconnection logs
                    self.logger.debug("ims2 after cells disabled was get and also disconnection logs")
                    ims_file_path.insert(1, self.collect_logs.ims_file_from_disconnection)
                else:  # ims2 after cells disabled was not get
                    self.logger.debug("ims2 after cells disabled was not get, use ims2 from disconnection and after "
                                      "swdl")
                    ims_file_path = [self.collect_logs.ims_file_from_disconnection, ims_file_path]
            if not cell_ids and not all_cells:
                states = {'stateInfo': {'operationalState': 'Enabled'}}
                info("No cells on selected component -> All cells should remain Enabled through whole ims2 history")
                self._check_that_state_of_component_has_not_changed("CELL_M", states, ims_file_path)
            else:
                if cell_ids:
                    nr_cell_ids = []
                    lte_cell_ids = []
                    gn_cell_ids = []
                    only_cell_ids = []
                    for cell_id in cell_ids:
                        if "NR" in cell_id or rat == "NR":
                            nr_cell_ids.append(cell_id)
                        elif "LN" in cell_id or rat == "LN":
                            lncel_r_dn = self.cell_operations.map_global_id_to_lncel_r(cell_id)
                            if lncel_r_dn:
                                lte_cell_ids.append(self._safe_split(lncel_r_dn, "-")[-1])
                        elif "GN" in cell_id or rat == "GN":
                            gn_cell_ids.append(cell_id)
                        else:
                            only_cell_ids = [self._safe_split(c, "-")[-1] for c in cell_ids]
                    if only_cell_ids:
                        rat_cell = f"LNCEL_R" if rat == "LN" else "NRCELL_L"
                        self._check_selected_component_disabled_enabled_from_ims_history(
                            rat_cell, only_cell_ids, ims_file_path)
                    if nr_cell_ids:
                        self._check_selected_component_disabled_enabled_from_ims_history(
                            "NRCELL_L", nr_cell_ids, ims_file_path)
                    if lte_cell_ids:
                        self._check_selected_component_disabled_enabled_from_ims_history(
                            "LNCEL_R", lte_cell_ids, ims_file_path)
                    if gn_cell_ids:
                        info("There are GN cells to be checked, all the GN are checked instead of specific cells.")
                        self._check_selected_component_disabled_enabled_from_ims_history(
                            "GNCEL_R", ims_file_path=ims_file_path)
                else:
                    self._check_selected_component_disabled_enabled_from_ims_history(
                        "CELL_M", [], ims_file_path)
                    if rfs:
                        info("Checking cells from other BTS")
                        self._check_selected_component_disabled_enabled_from_ims_history(
                            "CELL_M", [], rfs_file_path, rfs)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to check if selected cells were disabled and enabled from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise BTSConnectionFailure
        finally:
            self.ims_history.clear_values()

    def check_if_selected_rmods_disabled_and_enabled(self, rmod_serial_numbers=None, check_others_enabled=True,
                                                     retry=0):
        """
        Checks if selected radios were disabled and enabled during testing from ims2 history.

        :param list rmod_serial_numbers: Serial numbers of Radios to be checked. For example ["L1104506188",
                                         "K9124502508"]
        :param bool check_others_enabled: If True checks that other RMODs than selected have been enabled whole time
        :param int retry: If 0, retry is done if there is ErrorCode 6
        """
        states_1 = {'stateInfo': {'operationalState': 'Disabled'}}
        states_2 = {'stateInfo': {'operationalState': 'Enabled'}}
        ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
        try:
            self.admin.collect_im_snapshot(ims_file_path, timeout=900, connection="log_admin")
            if not rmod_serial_numbers:
                error("No serial number of radio given to method check_if_selected_rmods_disabled_and_enabled. "
                      "Check from ims2 that all radios in environment do have serial number")
                raise EnvironmentIssue
            all_components = {}
            components = self.admin.get_managed_objects("RMOD_L")
            for comp in components:
                for serial_nmbr in rmod_serial_numbers:
                    self._check_if_key_exists('distName', comp)
                    self._check_if_key_exists('parameters', comp)
                    self._check_if_key_exists('serialNumber', comp['parameters'])
                    component_dn = comp['distName']
                    if comp['parameters']['serialNumber'] == serial_nmbr:
                        if component_dn not in all_components:
                            all_components[component_dn] = [states_1, states_2]
                    elif check_others_enabled:  # other rmod
                        if component_dn not in all_components:
                            all_components[component_dn] = [states_2]
            self.logger.debug(f"All checked components: {all_components}")
            if self.ims_history.check_multiple_states_from_history(ims_file_path, all_components):
                info(f"RMOD_L with serialNumbers {rmod_serial_numbers} had operationalState disabled and "
                     f"enabled during testing, OK.")
            else:
                error(f"Disabled and enabled RMOD_Ls with serialNumbers {rmod_serial_numbers} "
                      f"were not found from ims2 history, NOK.")
                raise StateNotInIms2History(f"States {all_components} were not found from ims2 history")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to check if selected rmods disabled and enabled from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to check if selected rmods disabled and enabled, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method check_if_selected_rmods_disabled_and_enabled again after admin connection reset.")
                    self.check_if_selected_rmods_disabled_and_enabled(rmod_serial_numbers=rmod_serial_numbers,
                                                                      check_others_enabled=check_others_enabled,
                                                                      retry=1)
                elif retry == 1:
                    error("Unable to check if selected rmods disabled and enabled, because of session invalidation. "
                          "Admin connection restart did not help.")
            raise BTSConnectionFailure
        finally:
            self.ims_history.clear_values()

    def _check_smod_states_from_ims_history(self, ims_file_path=None, retry=0, ignore_state=None):
        """
        Check from ims2 history that SMOD was Commissioned, IntegratedToRan and OnAir during testing.

        :param str ims_file_path: Path to ims file. If path is not given ims2 log is fetched.
        :param int retry: If 0, retry is done if there is ErrorCode 6
        :param str ignore_state: (Optional) State to ignore. If not given all states are checked. Possible values:
                                 "Commissioned", "IntegratedToRan", "OnAir". Default is None.
        :raise StateNotInIms2History: Raises exception that state not in history.
        """
        states_list = []
        if ignore_state != "Commissioned":
            states_list.append({'stateInfo': {'proceduralState': 'Commissioned'}})
        if ignore_state != "IntegratedToRan":
            states_list.append({'stateInfo': {'proceduralState': 'IntegratedToRan'}})
        if ignore_state != "OnAir":
            states_list.append({'stateInfo': {'proceduralState': 'OnAir'}})
        all_components = {}
        try:
            components = self.admin.get_managed_objects("MRBTS_M")
            for comp in components:
                all_components[comp['distName']] = states_list
            info("Check from ims2 history that SMOD was Commissioned, IntegratedToRan and OnAir during "
                 "testing.")
            self.logger.debug(f"All SMODs: \n{all_components}")
            if not ims_file_path:
                ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
                self.admin.collect_im_snapshot(ims_file_path, timeout=900, connection="log_admin")
            if self.ims_history.check_multiple_states_from_history(ims_file_path, all_components):
                info("SMOD was Commissioned, IntegratedToRan and OnAir during testing, OK.")
            else:
                error("Commissioned, IntegratedToRan and OnAir SMOD states were not found from ims2 history, NOK.")
                raise StateNotInIms2History(f"States {all_components} were not found from ims2 history")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to check SMOD states from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to check SMOD states from ims history, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method _check_smod_states_from_ims_history again after admin connection reset.")
                    self._check_smod_states_from_ims_history(ims_file_path=ims_file_path, retry=1,
                                                             ignore_state=ignore_state)
                elif retry == 1:
                    error("Unable to check SMOD states from ims history, because of session invalidation. Admin "
                          "connection restart did not help.")
            raise BTSConnectionFailure("Unable to check SMOD states from ims history.")
        finally:
            self.ims_history.clear_values()

    def _check_that_selected_bbmods_were_reset(self, selected_bbmods=None, ims_file_path=None,
                                               check_others_enabled=True, retry=0):
        states_1 = {'stateInfo': {'operationalState': 'Disabled'}}
        states_2 = {'stateInfo': {'operationalState': 'Enabled'}}
        if not ims_file_path:
            ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
        try:
            self.admin.collect_im_snapshot(ims_file_path, timeout=900, connection="log_admin")
            all_components = {}
            components = self.admin.get_managed_objects("BBMOD_L")
            for comp in components:
                for serial_nmbr in selected_bbmods:
                    self._check_if_key_exists('distName', comp)
                    self._check_if_key_exists('parameters', comp)
                    self._check_if_key_exists('serialNumber', comp['parameters'])
                    component_dn = comp['distName']
                    if comp['parameters']['serialNumber'] == serial_nmbr:
                        if component_dn not in all_components:
                            all_components[component_dn] = [states_1, states_2]
                    elif check_others_enabled:  # other BBMODs
                        if component_dn not in all_components:
                            all_components[component_dn] = [states_2]
            self.logger.debug(f"All checked components: {all_components}")
            if self.ims_history.check_multiple_states_from_history(ims_file_path, all_components):
                info(f"BBMOD_Ls with serialNumbers {selected_bbmods} had operationalState disabled and enabled during "
                     f"testing, OK.")
            else:
                error(f"Disabled and enabled BBMOD_Ls with serialNumbers {selected_bbmods} were not found from "
                      f"ims2 history, NOK.")
                raise StateNotInIms2History(f"States {all_components} were not found from ims2 history")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to check if selected rmods disabled and enabled from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to check if selected rmods disabled and enabled, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method _check_that_selected_bbmods_were_reset again after admin connection reset.")
                    self._check_that_selected_bbmods_were_reset(selected_bbmods=selected_bbmods,
                                                                ims_file_path=ims_file_path,
                                                                check_others_enabled=check_others_enabled, retry=1)
                elif retry == 1:
                    error("Unable to check if selected rmods disabled and enabled, because of session invalidation. "
                          "Admin connection restart did not help.")
            raise BTSConnectionFailure
        finally:
            self.ims_history.clear_values()

    def _check_if_component_in_f_loki(self, component, component_dn):
        """
        Check if component is in F_LOKI* variables or in FAULTY_BBMODS* variables for example F_LOKI_CELLS. If for
         example cell is in F_LOKI_CELLS it is allowed to stay disabled because LOKI to which it belongs is disabled.

        :param str component: Component which is checked. For example CELL_M.
        :param str component_dn: Component distName.
        """
        if "CELL_M" == component and (BuiltIn().get_variable_value("${F_LOKI_CELLS}") or
                                      BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")):
            cell = self.cell_operations.get_key_cell_from_m_cell(component_dn)
            if (BuiltIn().get_variable_value("${F_LOKI_CELLS}") and
                    cell in BuiltIn().get_variable_value("${F_LOKI_CELLS}")):
                info(f"{cell} == {component_dn} and this cell is in F_LOKI_CELLS. It is allowed to "
                     f"stay disabled because LOKI to which it belongs is disabled.")
                return True
            if (BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}") and
                    cell in BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")):
                info(f"{cell} == {component_dn} and this cell is in FAULTY_BBMODS_CELLS. It is allowed to "
                     f"stay disabled because BBMOD to which it belongs is disabled.")
                return True
        if "LNCEL_R" == component and (BuiltIn().get_variable_value("${F_LOKI_CELLS}") or
                                       BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")):
            faulty_cells = []
            txt1 = "F_LOKI_CELLS"
            txt2 = "LOKI"
            if BuiltIn().get_variable_value("${F_LOKI_CELLS}"):
                faulty_cells = BuiltIn().get_variable_value("${F_LOKI_CELLS}")
            if BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}"):
                faulty_cells = BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")
                txt1 = "FAULTY_BBMODS_CELLS"
                txt2 = "BBMOD"
            if faulty_cells:
                for cell_key in self.bts.cells:
                    if cell_key in faulty_cells:
                        self.logger.debug(f"cell: {self.bts.cells[cell_key]['id']['internal']}")
                        self.logger.debug(f"component_dn: {component_dn}")
                        if self.bts.cells[cell_key]["id"]["internal"] == component_dn:
                            info(f"{cell_key} == {component_dn} and this cell is in {txt1}. It is allowed to "
                                 f"stay disabled because {txt2} to which it belongs is disabled.")
                            return True
        return False

    def _check_selected_component_disabled_enabled_from_ims_history(
            self, component=None, component_ids=None, ims_file_path=None, rfs=False, retry=0):
        """
        Check from ims2 history that some of selected components were disabled and enabled during testing.

        :param str component: Component which history will be checked for example CELL_M.
        :param list component_ids: Ids of components which states will be checked from history. If empty list, all cells
        :param str ims_file_path: Path to ims file. If path is not given ims2 log is fetched.
        :param bool rfs: If True checks that cells were disabled and enabled also from other BTS.
        :raise StateNotInIms2History: Raises exception that state not in history.
        """
        states_1 = {'operationalState': 'disabled'} if component == "LNCEL_R" or component == "GNCEL_R" else \
            {'stateInfo': {'operationalState': 'Disabled'}}
        states_2 = {'operationalState': 'enabled'} if component == "LNCEL_R" or component == "GNCEL_R" else \
            {'stateInfo': {'operationalState': 'Enabled'}}
        all_components = {}
        component_ids_for_log = component_ids
        try:
            if rfs:
                components = self.admin.get_managed_objects(component, connection="log_admin_remote")
            else:
                components = self.admin.get_managed_objects(component)
            for comp in components:
                if component_ids:
                    for component_id in component_ids:
                        if "-" in component_id:
                            component_id = component_id[component_id.rfind("-")+1:]
                        component_dn = comp['distName']
                        skip_component = self._check_if_component_in_f_loki(component, component_dn)
                        self.logger.debug(f"skip_component={skip_component}, Component {component_dn}")
                        if not skip_component and component_dn[component_dn.rfind("-")+1:] == component_id:
                            if component_dn not in all_components:
                                all_components[component_dn] = [states_1, states_2]
                else:
                    if component_ids_for_log is None:
                        component_ids_for_log = "All"
                    component_dn = comp['distName']
                    skip_component = self._check_if_component_in_f_loki(component, component_dn)
                    self.logger.debug(f"skip_component={skip_component}, Component {component_dn}")
                    if not skip_component and component_dn not in all_components:
                        all_components[component_dn] = [states_1, states_2]
            info(f"Check from ims2 history if {list(all_components.keys())} have had operationalState disabled "
                 f"and enabled during testing.")
            self.logger.debug(f"{component} with ids {component_ids_for_log}: \n{all_components}")
            if not ims_file_path:
                ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
                self.admin.collect_im_snapshot(ims_file_path, timeout=900, connection="log_admin")
            if self.ims_history.check_multiple_states_from_history(ims_file_path, all_components):
                self.logger.debug(self.ims_history.component_element_state_timestamp)
                info(f"{component} with ids {component_ids_for_log} had operationalState disabled and enabled during "
                     f"testing, OK.")
            else:
                error_message = ""
                self.logger.debug(self.ims_history.component_element_state_timestamp)
                for comp in all_components:
                    if comp not in self.ims_history.component_element_state_timestamp:
                        error_message = (f"{error_message}Disabled & Enabled changes of {comp} were not found from the "
                                         f"ims2 log, NOK.")
                    elif "operationalState" not in self.ims_history.component_element_state_timestamp[comp]:
                        error_message = (f"{error_message}operationalState of {comp} was not found from the ims2 log, "
                                         f"NOK. ")
                    elif "Enabled" not in self.ims_history.component_element_state_timestamp[comp]["operationalState"]:
                        error_message = f"{error_message}Enabled state of {comp} was not found from the ims2 log, NOK."
                    elif "Disabled" not in self.ims_history.component_element_state_timestamp[comp]["operationalState"]:
                        error_message = f"{error_message}Disabled state of {comp} was not found from the ims2 log, NOK."
                error(error_message)
                raise StateNotInIms2History(f"States {all_components} were not found from ims2 history")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to check selected component disabled enabled from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info(f"Unable to check component {component} disabled enabled, because of session invalidation."
                         f"Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method get_current_bbmod_status again after admin connection reset.")
                    self._check_selected_component_disabled_enabled_from_ims_history(
                        component=component, component_ids=component_ids, ims_file_path=ims_file_path, rfs=rfs, retry=1)
                elif retry == 1:
                    error(f"Unable to check component {component} disabled enabled, because of session invalidation. "
                          "Admin connection restart did not help.")
            raise BTSConnectionFailure
        finally:
            self.ims_history.clear_values()

    def _check_that_state_of_component_has_not_changed(self, component=None, states=None, ims_file_path=None, retry=0):
        """
        Check from ims2 history that state of components were not changed during testing.

        :param str component: Component which history will be checked for example CELL_M.
        :param dict states: Expected states that should remain whole history.
        :param str ims_file_path: Path to ims file. If path is not given ims2 log is fetched.
        :param int retry: If 0, retry is done if there is ErrorCode 6
        :raise StateNotInIms2History: Raises exception that state not in history.
        """
        all_components = {}
        try:
            components = self.admin.get_managed_objects(component)
            for comp in components:
                all_components[comp['distName']] = states
            info(f"Check from ims2 history that all {component} have had {states} during testing.")
            self.logger.debug(f"All components: \n{all_components}")
            if not ims_file_path:
                ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
                self.admin.collect_im_snapshot(ims_file_path, timeout=900, connection="log_admin")
            if self.ims_history.check_if_state_in_history_has_not_changed(ims_file_path, all_components):
                info(f"All {component} have had {states} during whole ims2 history, OK.")
            else:
                error(f"{component} were not found from ims2 history, NOK.")
                raise StateNotInIms2History(f"States {all_components} were not found from ims2 history")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to check that state of component has not changed from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info(f"Unable to check that state of {component} has not changed, because of session invalidation."
                         f"Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method get_current_bbmod_status again after admin connection reset.")
                    self._check_that_state_of_component_has_not_changed(
                        component=component, states=states, ims_file_path=ims_file_path, retry=1)
                elif retry == 1:
                    error(f"Unable to check that state of {component} has not changed, because of session invalidation."
                          f" Admin connection restart did not help.")
            raise BTSConnectionFailure
        finally:
            self.ims_history.clear_values()

    def _check_disabled_enabled_component_from_ims_history(self, component=None, ims_file_path=None, retry=0):
        """
        Check from ims2 history that selected component was disabled and enabled during testing.

        :param str component: Component which history will be checked for example BBMOD_L or RMOD_L.
        :param str ims_file_path: Path to ims file. If path is not given ims2 log is fetched.
        :param int retry: If 0, retry is done if there is ErrorCode 6
        :raise StateNotInIms2History: Raises exception that state not in history.
        """
        states_1 = {'stateInfo': {'operationalState': 'Disabled'}}
        states_2 = {'stateInfo': {'operationalState': 'Enabled'}}
        all_components = {}
        try:
            components = self.admin.get_managed_objects(component)
            for comp in components:
                all_components[comp['distName']] = [states_1, states_2]
            info(f"Check from ims2 history if all {component} have had operationalState disabled and enabled during "
                 f"testing.")
            self.logger.debug(f"All {component}s: \n{all_components}")
            if not ims_file_path:
                ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
                self.admin.collect_im_snapshot(ims_file_path, timeout=900, connection="log_admin")
            if self.ims_history.check_multiple_states_from_history(ims_file_path, all_components):
                info(f"All {component}s have had operationalState disabled and enabled during testing, OK.")
            else:
                error(f"All {component}s didn't have operationalState disabled and enabled in ims2 history (file(s) "
                      f"{ims_file_path}), NOK.")
                raise StateNotInIms2History(f"Expected operationalStates of {all_components} were not found from ims2 "
                                            f"history.")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to check disabled enabled component from ims history. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info(f"Unable to check disabled enabled {component}, because of session invalidation."
                         f"Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="log_admin")
                    info("Call method get_current_bbmod_status again after admin connection reset.")
                    self._check_disabled_enabled_component_from_ims_history(
                        component=component, ims_file_path=ims_file_path, retry=1)
                elif retry == 1:
                    error(f"Unable to check disabled enabled {component}, because of session invalidation. Admin "
                          f"connection restart did not help.")
            raise BTSConnectionFailure
        finally:
            self.ims_history.clear_values()

    @staticmethod
    def _check_if_key_exists(key_to_check, dictionary_to_check):
        if key_to_check not in dictionary_to_check:
            error(f"Key {key_to_check} is not found from {dictionary_to_check}. Changes in BTS SW?")
            raise EnvironmentIssue(f"Key {key_to_check} is not found from {dictionary_to_check}. Changes in BTS SW?")

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)
