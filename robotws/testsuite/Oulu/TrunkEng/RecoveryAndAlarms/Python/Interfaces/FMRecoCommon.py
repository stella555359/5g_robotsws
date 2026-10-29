"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ErrorFromAdmin, ScriptIssue)
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Resources.exceptions import PartitionWasNotChanged


class FMRecoCommon(object):

    allowed_during_test_loop = []
    ssh_objects = []

    def __init__(self):
        """
        FMRecoCommon is collection of commonly needed method for Faut management and recovery tests
        """
        self.logger = BuiltIn().get_library_instance("LOG")
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.cells = BuiltIn().get_library_instance("CELLS")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.bts_status = BuiltIn().get_library_instance("BTSSTATUS")
        self.alarms = BuiltIn().get_library_instance("ALARMS")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")

    def check_from_wait_time_if_alarm_and_states_should_be_check(self, wait_time, rmod_object, fault, fault_name,
                                                                 resource, step, cells, expected_cell_states="degraded",
                                                                 expected_rmod_states="degraded", limit=60):
        """Check if wait time is more than given limit, if it is add alarm to expected alarms and do checks"""
        if int(wait_time) > int(limit):  # alarm is expected
            self.bts.print_step_text(f"{step}.2", f"Check expected alarms and states when fault {fault} is activated")
            self.alarms.select_alarm_id_by_resources_and_add_fault_to_expected_alarm(
                resource, rmod_object, fault, fault_name, list_of_cells=cells,
                cells_degraded_faulty=expected_cell_states)
            self.alarms.check_expected_alarms()
            self.check_cell_radio_and_bts_states(rmod_object, expected_cell_states, expected_rmod_states, cells)
            expected = self.alarms.get_expected_alarms()
            FMRecoCommon.allowed_during_test_loop.extend(expected)
            self.alarms.remove_expected_alarms()
        else:
            info(f"Alarms and states are not checked because fault is active just {wait_time} seconds (limit for "
                 f"checks is {limit} seconds.")

    def check_cell_radio_and_bts_states(self, rmod_obj, expected_cell_state, expected_rmod_state, cells):
        """
        This method is used to check that cells are in expected state and radio is in expected state.
        """
        cell_states = {}
        info("Check cell, radio and smod states")
        ok_cell_state = {"operationalState": "enabled", "availabilityStatus": "online"}
        ok_rmod_state = {"operationalState": "enabled", "availabilityStatus": "online"}
        cell_state = {"operationalState": "enabled", "availabilityStatus": "degraded"}
        rmod_state = {"administrativeState": "Unlocked", "operationalState": "enabled",
                      "availabilityStatus": "degraded"}
        cells_not_faulty = True
        try:
            if expected_cell_state == 'faulty':
                cell_state = {"operationalState": "disabled", "availabilityStatus": "faulty"}
                cells_not_faulty = False
            if expected_rmod_state == 'faulty':
                rmod_state = {"administrativeState": "Unlocked", "operationalState": "disabled",
                              "availabilityStatus": "faulty"}
            for cell in cells:
                cell_states[cell] = cell_state
            radio_states = {rmod_obj.name: rmod_state}
            bts_state = self.bts_status.get_expected_bts_state(cells, lte441a_active=cells_not_faulty)
            self.cells.check_cell_states(cell_states, states_of_other_cells=ok_cell_state)
            self.bts_status.check_radio_states(radio_states, states_of_other_rmods=ok_rmod_state, print_ok_states=True)
            self.bts_status.check_bts_state(bts_state)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to check_cell_radio_and_bts_states. {admin_error.__class__.__name__}:"
                  f"{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise ErrorFromAdmin(f"Unable to check_cell_radio_and_bts_states, {admin_error.__class__.__name__} was "
                                 f"raised")

    def add_collected_alarms_to_allowed(self):
        """Add collected alarm to allowed alarms and clear allowed_during_test_loop list."""
        self.alarms.add_list_of_alarms_to_allowed(FMRecoCommon.allowed_during_test_loop)
        self.logger.debug(f"Clear FMRecoCommon.allowed_during_test_loop: {FMRecoCommon.allowed_during_test_loop}")
        FMRecoCommon.allowed_during_test_loop = []

    def start_logs_and_journals_by_ssh(self):
        """
        Start BR0 logs starts collecting BR0 logs by ssh with command given in suite variable ${BRO_LOG_CMD}.
        Also starts collecting sctp.txt log with command given in suite variable ${SCTP_LOG}.
        """
        enb_ssh = None
        br0_cmd = BuiltIn().get_variable_value("${BRO_LOG_CMD}")
        if br0_cmd is None:
            self.logger.debug("BR0 logs are not started because suite variable ${BRO_LOG_CMD} is not set.")
        else:
            self.logger.debug("Start BR0 logs")
            enb_ssh = self.ssh.send_command_to_smod_by_ssh(br0_cmd, print_to_eventlog=True, disconnect_ssh=False)
            self.logger.debug("BR0 logs started")
        journal_cmd = BuiltIn().get_variable_value("${SCTP_LOG_CMD}")
        if journal_cmd is None:
            self.logger.debug("sctp.txt log is not started because suite variable ${SCTP_LOG_CMD} is not set.")
        else:
            self.logger.debug("Start collecting sctp.txt log")
            if enb_ssh:
                self.ssh.send_command_to_smod_by_ssh(journal_cmd, enb_ssh=enb_ssh, print_to_eventlog=True,
                                                     disconnect_ssh=False)
            else:
                enb_ssh = self.ssh.send_command_to_smod_by_ssh(journal_cmd, print_to_eventlog=True,
                                                               disconnect_ssh=False)
            self.logger.debug("Collection is started")
            FMRecoCommon.ssh_objects.append(enb_ssh)

    def _get_file_from_bts(self, file_path, extra_name=""):
        """
        Get file from BTS using SCP.

        :param file_path: Path to the file on the remote server.
        :param extra_name: Optional extra name to append to the log file name.
        :return: The path to the retrieved file.
        """
        log = self.collect_logs.get_file_or_folder_by_scp(
            file_path, "192.168.255.129", "toor4nsn", 'oZPS0POrRieRtu', update_name=True, extra_name=extra_name)
        if log:
            self.logger.debug(f"{file_path} logs retrieved to test logs (with additional name {extra_name})")
        else:
            self.logger.debug(f"{file_path} logs not retrieved")
        return log

    def get_logs_and_journal_by_scp(self, extra_name=""):
        """
        Get BR0 logs. This method retrieves BR0 logs from the remote server using SCP.
        It uses the command specified in the suite variable ${BRO_LOG_CMD} to determine the file path.
        It also retrieves the sctp.txt log using the command specified in the suite variable ${SCTP_LOG_CMD}.

        :param extra_name: Optional extra name to append to the log file name. For example "step1_br0_s1.pcap".
        """
        br0_cmd = BuiltIn().get_variable_value("${BRO_LOG_CMD}")
        if br0_cmd is None:
            self.logger.debug("BR0 logs are not collected because suite variable ${BRO_LOG_CMD} is not set.")
        else:
            self.logger.debug("Get BR0 logs")
            br0_cmd_lst = br0_cmd.split(" ")
            path_to_file = "/user/toor4nsn/br0_s1.pcap"
            if br0_cmd_lst[-2].strip() != "br0_s1.pcap":
                path_to_file = str(br0_cmd_lst[-2].strip())
            self._get_file_from_bts(path_to_file, extra_name=extra_name)
        sctp_cmd = BuiltIn().get_variable_value("${SCTP_LOG_CMD}")
        if sctp_cmd is None:
            self.logger.debug("sctp.txt log is not collected because suite variable ${SCTP_LOG_CMD} is not set.")
        else:
            self.logger.debug("Get sctp.txt log")
            if isinstance(sctp_cmd, list):
                sctp_cmd = " ".join(sctp_cmd)
            sctp_cmd_lst = sctp_cmd.split(" ")
            path_to_file = "/user/toor4nsn/sctp.txt"
            if sctp_cmd_lst[-2].strip() != "sctp.txt":
                path_to_file = str(sctp_cmd_lst[-2].strip())
            self._get_file_from_bts(path_to_file, extra_name=extra_name)
        for ssh_obj in FMRecoCommon.ssh_objects:
            if ssh_obj:
                self.ssh.disconnect_ssh_connection(ssh_obj)
        FMRecoCommon.ssh_objects = []

    def check_if_more_than_one_cells_on_rmod_and_last_rx_of_cell(self, ant_resource, selected_cells, cells_of_rmod,
                                                                 radio_name):
        """
        Check if there is more than one cell on rmod and if the last rx on cell is used
        """
        try:
            rx_on_cell = self.cells.get_number_of_tx_or_rx_on_cell(txrx_resource="RX", selected_cell=selected_cells)
            cell_on_multiple_radios = self.bts.check_if_cell_resources_on_two_radios(radio_name, check_also_tx=False)
            number_of_rx = ant_resource.split("RX")[1]
            cells_on_rmod = len(cells_of_rmod)
            cell_should_be_faulty = False
            if isinstance(selected_cells, str):
                selected_cells = [selected_cells]
            if isinstance(selected_cells, list):
                for selected in selected_cells:
                    if (selected in rx_on_cell and str(number_of_rx) == str(rx_on_cell[selected]) and cells_on_rmod > 1
                            and not cell_on_multiple_radios):
                        info(f"There are more than one cell on {radio_name} ({sorted(cells_of_rmod)}) and last RX of "
                             f"cell on radio is used ({ant_resource}) and cell is only on one radio -> cell will be "
                             f"faulty")
                        cell_should_be_faulty = True
                        break

                    else:
                        self.logger.debug("Either there is only one cell on rmod or last RX on cell is not used or cell"
                                          " is on multiple radios.")
        except (TypeError, AttributeError, KeyError, ValueError) as e:
            error(f"Unable to check if more than one cells on rmod and last rx of cell. {e.__class__.__name__}:"
                  f"{e} was raised.\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise ScriptIssue(f"Unable to check if more than one cells on rmod and last rx of cell, "
                              f"{e.__class__.__name__} was raised")
        return cell_should_be_faulty

    @staticmethod
    def verify_partition_change(active_partition_name, active_partition_before):
        """
        Check if partition has changed compared to original info.

        :param str active_partition_name: Name of the partition to check.
        :param str active_partition_before: Original partition info to compare against.
        :return: True if partition info has changed, False otherwise.
        """
        if active_partition_name != active_partition_before:
            info(f"Partition has changed from '{active_partition_before}' to '{active_partition_name}'. OK.")
            return True
        else:
            error(f"Partition has not changed and it is still '{active_partition_before}'. NOK.")
            raise PartitionWasNotChanged(f"Partition is still '{active_partition_before}'.")
