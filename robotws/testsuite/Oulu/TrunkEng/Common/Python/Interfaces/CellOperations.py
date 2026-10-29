"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

from datetime import datetime
import time
import threading
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                                                AdminApiProcedureTimeoutException, AdminApiNoResponseException)
from taf.internal.aliasing.exceptions import AliasLookupError
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import WrongCellStates, ScriptIssue, EnvironmentIssue, \
    InvalidUserInput
from testsuite.Oulu.TrunkEng.Common.Python.Resources.BBMODs import BBMODs
from testsuite.Oulu.TrunkEng.Common.Python.Resources.HTMLReport import HTMLReport
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.PowerBreakers import PowerBreakers


class CellOperations:
    """
    This class includes methods used for different cell operations.

    CellOperations is called in common_resources.robot. If the class is already initiated once, import robot BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("CELLS")
    """

    cell_states_are_expected = False
    error_during_admin_call = ""

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.scf = None
        self.bts = None
        self.file_path_to_write = None

    def _get_cell_check_interval(self, interval):
        """
        Set interval between cell state checks.

        :param int/str interval: Interval between checks.
        """
        user_given_interval = BuiltIn().get_variable_value("${CELL_STATE_INTERVAL}")
        if not user_given_interval:
            self.logger.debug("Default interval is used.")
            return int(interval)
        if isinstance(user_given_interval, str) or isinstance(user_given_interval, int):
            interval = int(user_given_interval)
        else:
            error(f"Loop {self.logger.loop + 1}: Interval should be gives as a string or as a integer, now it is "
                  f"{type(user_given_interval)}.")
            raise InvalidUserInput("Interval should be gives to CELL_STATE_INTERVAL variable as string or integer.")
        info(f"Cell state check interval is set to {interval}")
        return interval

    @HTMLReport("Wait for all cells up")
    def wait_for_all_cells_up(self, time_limit, degraded_cells=None, admin_connection="default", interval=5):
        """
        Wait for all cells to get back up within time limit. If time limit is exceeded, raises an error.

        :param str time_limit: Time limit for waiting all cells to get up.
        :param list/str degraded_cells: List of allowed degraded cells, need to be in 'LNCell-x' or 'NRCell-x' or
                                        'GNCell-x' format. 'All' if all cells. Default value None.
        :param str admin_connection: Admin connection name. Default value is "default".
        :param int/str interval: Interval between checks. Default value is 5.
        :raises WrongCellStates: If any cells are not up within time limit.
        :return bool success: True if success, else False.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        interval = self._get_cell_check_interval(interval)
        self.logger.debug("Clear value of expected states.")
        CellOperations.cell_states_are_expected = False
        time_limit = int(time_limit)
        start_time = datetime.now()
        faulty_loki_cells = []
        affected_bbmod = ""
        if BuiltIn().get_variable_value("${SERIAL_CONSOLE}"):
            degraded_cells = "All"
        if BuiltIn().get_variable_value("${BREAK_LOKI}"):
            faulty_loki_cells = BuiltIn().get_variable_value("${F_LOKI_CELLS}")
            info(f"BREAK_LOKI is True and cells {faulty_loki_cells} are allowed to stay faulty.")
            affected_bbmod = "{}/{}".format(BuiltIn().get_variable_value("${F_LOKI_BBMOD}"),
                                            BuiltIn().get_variable_value("${F_LOKI}"))
        if BuiltIn().get_variable_value("${BBMODS_MASK}"):
            affected_bbmod = BuiltIn().get_variable_value("${FAULTY_BBMODS}")
            faulty_loki_cells = BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")
            info(f"BBMODS_MASK has been given and cells {faulty_loki_cells} are affected and allowed to stay faulty.")
        if isinstance(degraded_cells, str):
            if degraded_cells == "All":
                degraded_cells = []
                cells = self.bts.cells
                for cell in cells:
                    degraded_cells.append(cell)
        self.logger.debug(f"Cells that are allowed to be degraded: {degraded_cells}")
        faulty_cells = self.get_faulty_cells(degraded_cells, print_to_eventlog=False, admin_connection=admin_connection)
        self.file_path_to_write = (f"{self.logger.log_dir}/"
                                   f"looped_wait_for_cells_up_requests_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt")
        if faulty_cells:
            info("Wait for all cells up max {}s".format(time_limit))
            while (datetime.now() - start_time).total_seconds() < int(time_limit) and faulty_cells:
                faulty_cells_result = []

                def get_faulty_cells_thread():
                    faulty_cells_result.extend(self.get_faulty_cells(degraded_cells, print_to_eventlog=False,
                                                                     admin_connection=admin_connection))

                faulty_cells_thread = threading.Thread(target=get_faulty_cells_thread,
                                                       name="cells_up_faulty_cells_thread", daemon=True)
                faulty_cells_thread.start()
                faulty_cells_thread.join()
                faulty_cells = faulty_cells_result
                if faulty_loki_cells and sorted(faulty_loki_cells) == sorted(faulty_cells):
                    break
                time.sleep(interval)
            if (((faulty_loki_cells and sorted(faulty_loki_cells) != sorted(faulty_cells)) or faulty_cells) and
                    CellOperations.error_during_admin_call):
                if ("ErrorCode: 6" in CellOperations.error_during_admin_call and
                        ("Version request failed" in CellOperations.error_during_admin_call or
                         "http sessionId invalid" in CellOperations.error_during_admin_call)):
                    warning("There was ErrorCode: 6 and because of that we were unable to get cell states from admin, "
                            "because of session invalidation. Restart admin connection and try again.")
                    faulty_cells = []
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    try:
                        self.bts.reset_admin_connection(admin=admin_connection)
                    except BTSConnectionFailure as e:
                        info("Problems while doing reset_admin_connection, check if it was reason for the problem:\n")
                    faulty_cells.extend(self.get_faulty_cells(print_to_eventlog=False,
                                                              admin_connection=admin_connection))
            if faulty_loki_cells and sorted(faulty_loki_cells) == sorted(faulty_cells):
                info("All cells that are not affected by {} are up in {} seconds (NOTE not KPI value)".format(
                    affected_bbmod, (datetime.now() - start_time).total_seconds()))
                CellOperations.cell_states_are_expected = True
            elif faulty_cells:
                error("Loop {}: All cells are not up in {} seconds.".format(self.logger.loop + 1, time_limit))
                if CellOperations.error_during_admin_call:
                    info(f"There were error from admin, check if it was reason for the problem:\n"
                         f"{CellOperations.error_during_admin_call}")
                    CellOperations.error_during_admin_call = ""
                info("Faulty cells are: {}".format(faulty_cells))
                PowerBreakers().print_power_breaker_port_statuses()
                raise WrongCellStates("All cells are not up in {} seconds.".format(time_limit))
            else:
                info("All cells are up in {} seconds (NOTE not KPI value)".format(
                    (datetime.now() - start_time).total_seconds()))
                CellOperations.cell_states_are_expected = True
        else:
            info("All cells are up when the check is started. Skip wait.")
            CellOperations.cell_states_are_expected = True
        self.file_path_to_write = ""

    def wait_for_cells_faulty(self, time_limit, cells_to_be_faulty=None, admin_connection=None,
                              degraded_cells_stops_wait=False, interval=5, check_only_given_cells=False,
                              raise_error=True):
        """
        Waits for given cells to be faulty.

        :param str time_limit: Time to max wait for faulty cells.
        :param list cells_to_be_faulty: List of cells that are expected to be faulty during wait time. Default value
                                        None. If None then all cells are expected to be faulty.
        :param str admin_connection: Admin connection name. Default value is None so it will be "default".
        :param bool degraded_cells_stops_wait: If this is set to True then waiting of faulty cells is stopped also if
                                               cells are degraded. Default value is False.
        :param int/str interval: Interval between checks. Default value is 5.
        :param check_only_given_cells: If set to True, checks only given cells. Default value is False.
        :param bool raise_error: Default is True. If True then test will fail if cells not faulty in given time. If
                                 False then doesn't raise error, just warns.
        :raise WrongCellStates: If given cells are not faulty during wait time.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        self.logger.debug("Clear value of expected states.")
        CellOperations.cell_states_are_expected = False
        time_limit = int(time_limit)
        start_time = datetime.now()
        faulty_cells = []
        interval = self._get_cell_check_interval(interval)
        self.file_path_to_write = (f"{self.logger.log_dir}/"
                                   f"looped_wait_for_cells_faulty_requests_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
                                   ".txt")
        if cells_to_be_faulty is None:
            self.logger.debug("No cells for wait to be faulty given -> All cells {} are expected to be faulty.".format(
                self.bts.cells.keys()))
            cells_to_be_faulty = list(self.bts.cells.keys())
        elif not cells_to_be_faulty:
            self.logger.debug("List cells_to_be_faulty is empty -> Cells are not expected to be faulty.")
            return
        if degraded_cells_stops_wait:
            info("Wait for cells {} to be degraded or faulty max {}s".format(cells_to_be_faulty, time_limit))
        else:
            cells_to_be_faulty = [self.get_cell_used_id_by_local_id(
                cell, "NR" if "NR" in cell else "GN" if "GN" in cell else "LN", add_prefix=True)
                for cell in cells_to_be_faulty]
            info("Wait for cells {} to be faulty max {}s".format(cells_to_be_faulty, time_limit))
        while (datetime.now() - start_time).total_seconds() < int(time_limit):
            faulty_cells_result = []

            def get_faulty_cells_thread():
                faulty_cells_result.extend(self.get_faulty_cells(print_to_eventlog=False,
                                                                 admin_connection=admin_connection))

            faulty_cells_thread = threading.Thread(target=get_faulty_cells_thread,
                                                   name="faulty_cells_thread", daemon=True)
            faulty_cells_thread.start()
            faulty_cells_thread.join()
            found_faulty_cells = faulty_cells_result
            for cell in cells_to_be_faulty:
                if cell in found_faulty_cells and cell not in faulty_cells:
                    info("{} is disabled.".format(cell))
                    faulty_cells.append(cell)
            if len(faulty_cells) == len(cells_to_be_faulty):
                break  # break out of while
            time.sleep(interval)
        if not faulty_cells and CellOperations.error_during_admin_call:
            if ("ErrorCode: 6" in CellOperations.error_during_admin_call and
                    ("Version request failed" in CellOperations.error_during_admin_call or
                     "http sessionId invalid" in CellOperations.error_during_admin_call)):
                warning("There was ErrorCode: 6 and because of that we were unable to get cell states from admin, "
                        "because of session invalidation. Restart admin connection and try again.")
                faulty_cells = []
                if not self.bts:
                    self.bts = BuiltIn().get_library_instance("BTS")
                self.bts.reset_admin_connection(admin=admin_connection)
                faulty_cells.extend(self.get_faulty_cells(print_to_eventlog=False, admin_connection=admin_connection))
        if (not faulty_cells or set(cells_to_be_faulty) != set(faulty_cells)) and raise_error:
            if degraded_cells_stops_wait:
                error("Loop {}: Cells {} are not degraded or faulty in {} seconds.".format(
                    self.logger.loop + 1, set(cells_to_be_faulty) - set(faulty_cells), time_limit))
                info("Degraded/faulty cells are: {}".format(faulty_cells))
            else:
                error("Loop {}: Cells {} are not faulty in {} seconds.".format(self.logger.loop + 1,
                      set(cells_to_be_faulty) - set(faulty_cells), time_limit))
                info("Faulty cells are: {}".format(faulty_cells))
            if CellOperations.error_during_admin_call:
                info(f"There were error from admin, check if it was reason for the problem:\n"
                     f"{CellOperations.error_during_admin_call}")
                CellOperations.error_during_admin_call = ""
            PowerBreakers().print_power_breaker_port_statuses()
            raise WrongCellStates("Cells {} are not faulty in {} seconds.".format(cells_to_be_faulty, time_limit))
        elif (not faulty_cells or set(cells_to_be_faulty) != set(faulty_cells)) and not raise_error:
            warning("Loop {}: Cells {} are not degraded/faulty in {} seconds.".format(
                    self.logger.loop + 1, set(cells_to_be_faulty) - set(faulty_cells), time_limit))
            if CellOperations.error_during_admin_call:
                info(f"There were error from admin, check if it was reason for the problem:\n"
                     f"{CellOperations.error_during_admin_call}")
                CellOperations.error_during_admin_call = ""
            PowerBreakers().print_power_breaker_port_statuses()
        else:
            if degraded_cells_stops_wait:
                info("Cells {} are degraded or faulty in {} seconds (NOTE not KPI value)".format(
                    cells_to_be_faulty, (datetime.now() - start_time).total_seconds()))
            else:
                info("Cells {} are faulty in {} seconds (NOTE not KPI value)".format(
                    cells_to_be_faulty, (datetime.now() - start_time).total_seconds()))
            CellOperations.cell_states_are_expected = True
        if (cells_to_be_faulty and not BuiltIn().get_variable_value(
                "${RFS}") and not check_only_given_cells):
            BuiltIn().sleep("3s")
            faulty_cells_result = []

            def get_faulty_cells_thread():
                faulty_cells_result.extend(self.get_faulty_cells(print_to_eventlog=False,
                                                                 admin_connection=admin_connection))

            faulty_cells_thread = threading.Thread(target=get_faulty_cells_thread, name="faulty_cells_thread",
                                                   daemon=True)
            faulty_cells_thread.start()
            faulty_cells_thread.join()
            found_faulty_cells = faulty_cells_result
            if BuiltIn().get_variable_value("${BREAK_LOKI}"):
                remove_check = []
                faulty_loki_cells = BuiltIn().get_variable_value("${F_LOKI_CELLS}")
                for ffc in found_faulty_cells:
                    if ffc in faulty_loki_cells:
                        self.logger.debug(f"Ignore faulty cell {ffc}")
                        remove_check.append(ffc)
                for rc in remove_check:
                    found_faulty_cells.remove(rc)
            if len(cells_to_be_faulty) < len(found_faulty_cells):
                if raise_error and not self.compare_cells_of_rat_and_those_mapped_to_bbmod(
                        cells_of_rat=cells_to_be_faulty
                ):
                    error(f"Loop {self.logger.loop + 1}: Found more faulty cells than expected. Expected: "
                          f"{cells_to_be_faulty}, found: {found_faulty_cells}")
                    if CellOperations.error_during_admin_call:
                        info(f"There were error from admin, check if it was reason for the problem:\n"
                             f"{CellOperations.error_during_admin_call}")
                        CellOperations.error_during_admin_call = ""
                else:
                    warning(f"Loop {self.logger.loop + 1}: Found more faulty cells than expected. Expected: "
                            f"{cells_to_be_faulty}, found: {found_faulty_cells}")
                    if CellOperations.error_during_admin_call:
                        info(f"There were error from admin, check if it was reason for the problem:\n"
                             f"{CellOperations.error_during_admin_call}")
                        CellOperations.error_during_admin_call = ""
        self.file_path_to_write = ""

    def compare_cells_of_rat_and_those_mapped_to_bbmod(self, cells_of_rat):
        """
        Compare cells of given RAT and those mapped to BBMOD.

        :param list cells_of_rat: List of cells of given RAT.

        :return bool: True if all cells of RAT are mapped to BBMOD, else False.
        """
        reset_type = BuiltIn().get_variable_value("${RESET_TYPE}", default="Soft")
        if reset_type == "Hard":
            bbmod = BBMODs()
            bbmod_objects = bbmod.get_bbmod_connections()
            bbmod_names = [obj.name for obj in bbmod_objects]
            cells_mapped_to_bbmod = {}
            for name in bbmod_names:
                cells_mapped_to_bbmod[name] = bbmod.get_cells_mapped_to_bbmod(bbmod_name=name)
            all_cells = [cell for cells in cells_mapped_to_bbmod.values() for cell in cells]
            if all(cell in all_cells for cell in cells_of_rat):
                return True
        return False

    def _parse_configuration_number_from_cell_info(self, cell_info):
        """
        Parse configuration number from cell info string
        :param cell_info: cell info dictionary
        """
        if isinstance(cell_info, dict):
            if "id" in cell_info and "configuration" in cell_info["id"]:
                configuration_str = cell_info["id"]["configuration"]
                configuration_number = self._safe_split(configuration_str, '-')[-1]
                return configuration_number
            else:
                error(f"Loop {self.logger.loop + 1}: Something changed in cell information dictionary, no "
                      f"cell_info[id][configuration] in cell_info: {cell_info}.")
                raise EnvironmentIssue("Something has changed in return of get_cells_info (admin method).")
        error(f"Loop {self.logger.loop + 1}: Something changed in cell information dictionary. {cell_info} is not a"
              f" dictionary.")
        raise EnvironmentIssue("Something has changed in return of get_cells_info (admin method).")

    def _get_cells_from_get_cells_info(self, rat, cells, admin_connection):
        """Get cells from get cells info"""
        CellOperations.error_during_admin_call = ""
        try:
            nr_cells = self.admin.get_cells_info(cell_type=rat, timeout=30, connection=admin_connection,
                                                 detailed_output=True)
            if self.file_path_to_write:
                with open(self.file_path_to_write, 'a') as file_to_write:
                    file_to_write.write(f"{nr_cells}\n")
            self.logger.debug(f"{rat.upper()} cells:\n{nr_cells}")
            if "requestMessage" in nr_cells and "cells" in nr_cells["requestMessage"]:
                nr_cells = nr_cells["requestMessage"]["cells"]
                for rat_of_cells in nr_cells:
                    if isinstance(rat_of_cells, str) and rat_of_cells == rat:
                        self.logger.debug(f"{rat.upper()} Cell is string: {rat_of_cells}")
                        for nr_c in nr_cells[rat_of_cells]:
                            if rat == "nr":
                                cells[f"NRCell-{nr_c['globalCellId']}"] = nr_c
                            elif rat == "lte":
                                cells[f'LNCell-{nr_c["physicalCellId"]}'] = nr_c
                            elif rat == "gsm":
                                conf_number = self._parse_configuration_number_from_cell_info(nr_c)
                                cells[f'GNCell-{conf_number}'] = nr_c
            else:
                for cell in nr_cells:
                    if rat == "nr":
                        cells[f"NRCell-{cell['globalCellId']}"] = cell
                    elif rat == "lte":
                        cells[f'LNCell-{cell["physicalCellId"]}'] = cell
                    elif rat == "gsm":
                        conf_number = self._parse_configuration_number_from_cell_info(cell)
                        cells[f'GNCell-{conf_number}'] = cell
        except (AdminApiProcedureTimeoutException, AdminApiConnectionClosedException,
                AdminApiProcedureFailureException, AdminApiNoResponseException, AliasLookupError) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            CellOperations.error_during_admin_call = tb
            self.logger.debug(
                f"Error occurred when requesting get_cells_info from admin. "
                f"{admin_error.__class__.__name__}:{admin_error} was raised\n{tb}")
        return cells

    def get_all_cells(self, admin_connection=None):
        """
        Get information of all cells

        :param str admin_connection: Admin connection name. Default value is "default".
        """
        cells = {}
        cells = self._get_cells_from_get_cells_info("nr", cells, admin_connection)
        cells = self._get_cells_from_get_cells_info("lte", cells, admin_connection)
        cells = self._get_cells_from_get_cells_info("gsm", cells, admin_connection)
        return cells

    def get_current_cell_states(self, admin_connection=None):
        """
        Get current cell states from admin interface.

        :param str admin_connection: Admin connection name. Default value is None so it will be "default".
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        cell_states = {}
        all_cell_information = self.get_all_cells(admin_connection)
        for cell in all_cell_information:
            cell_states[cell] = {}
            for status in all_cell_information[cell]["status"]:
                cell_states[cell][status] = all_cell_information[cell]["status"][status].lower()
        unknown_states = {"administrativeState": "", "operationalState": "",
                          "blockingState": "", "availabilityStatus": ""}
        all_cells = self.bts.cells if admin_connection != "remote" else self.bts.cells_remote
        for cell in all_cells:
            if cell not in cell_states:
                cell_states[cell] = unknown_states
        return cell_states

    @staticmethod
    def compare_current_cell_state_to_expected(state, cell, expected_states, current_state, ok_str, fail_str):
        if state in expected_states and state in current_state:
            if current_state[state] != expected_states[state]:
                if BuiltIn().get_variable_value("${SERIAL_CONSOLE}") and state == "availabilityStatus":
                    ok_str = f"{ok_str}{cell}'s {state} is {current_state[state]}, but since Serial Console logging" \
                             f"is active, ignore the cell availabilityStatus. OK.\n"
                else:
                    fail_str = f"{fail_str}{state} of {cell} is expected to be {expected_states[state]}, " \
                               f"but is {current_state[state]}. NOK\n"
            elif current_state[state] == expected_states[state]:
                ok_str = f"{ok_str}{cell}'s {state} is {expected_states[state]}, as expected. OK\n"
        elif state in expected_states and state not in current_state:
            fail_str = f"{fail_str}{cell}'s {state} is expected to be {expected_states[state]}, but it is missing " \
                       f"from current cell states, NOK\n"
        return ok_str, fail_str

    @staticmethod
    def _remove_extra_rat_from_expected_states(expected_states):
        for cell, states in expected_states.items():
            if cell.count("LNCell") > 1 or cell.count("NRCell") > 1 or cell.count("GNCell") > 1:
                new_cell = cell.replace("NRCell-", "", 1).replace("LNCell-", "", 1).replace("GNCell-", "", 1)
                expected_states[new_cell] = states
                del expected_states[cell]
        return expected_states

    def check_cell_states(self, expected_states=None, states_of_other_cells=None, print_ok_cell_states=False,
                          admin_connection=None):
        """
        Checks cell states.

        :param dict expected_states: dictionary that has cell as a key and its states as value.
                                     Note, if all cells are affected, 'All_cells' can be used as key.
        :param dict states_of_other_cells: This is used if only some cells are faulted, and the rest needs to be
                                           checked that they are OK. Similar dict as expected_states.
        :param bool print_ok_cell_states: If set to True, prints states of all OK cells. If set to False and all cells
                                          are ok, prints 'All cell states OK'.
        :param str admin_connection: Admin connection name. Default value is None so it will be "default".
        :return success: True if success, else False.
        """
        faulty_loki_cells = []
        current_states = self.get_current_cell_states(admin_connection=admin_connection)
        expected_states = self._remove_extra_rat_from_expected_states(expected_states)
        self.logger.debug(f"Expected_states: {expected_states}")
        self.logger.debug(f"Current_states: {current_states}")
        extra_info = BuiltIn().get_variable_value("${EXTRA_INFO_FOR_LOOP}", default="")
        extra_info = extra_info.replace("_", " ")
        print_txt = "F_LOKI_CELLS"
        if BuiltIn().get_variable_value("${BREAK_LOKI}"):
            faulty_loki_cells = BuiltIn().get_variable_value("${F_LOKI_CELLS}")
        if BuiltIn().get_variable_value("${BBMODS_MASK}"):
            faulty_loki_cells = BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")
            print_txt = "FAULTY_BBMODS_CELLS"
        if self._check_if_current_and_expected_states_exist(current_states, expected_states):
            fail_print = ""
            ok_print = ""
            for cell in current_states:
                if faulty_loki_cells and cell in faulty_loki_cells:
                    info(f"State of {cell} is {current_states[cell]}, it is in {print_txt} and allowed to stay "
                         f"faulty & disabled. Ignore state checks for it.")
                elif "All_cells" in expected_states:
                    for state in expected_states["All_cells"]:
                        ok_print, fail_print = self.compare_current_cell_state_to_expected(
                            state, cell, expected_states["All_cells"], current_states[cell], ok_print, fail_print)
                elif cell in expected_states:
                    info(f"Expected states of {cell} are: {expected_states[cell]}")
                    for state in expected_states[cell]:
                        ok_print, fail_print = self.compare_current_cell_state_to_expected(
                            state, cell, expected_states[cell], current_states[cell], ok_print, fail_print)
                elif states_of_other_cells:
                    # if cell not in expected_states:
                    for state in states_of_other_cells:
                        ok_print, fail_print = self.compare_current_cell_state_to_expected(
                            state, cell, states_of_other_cells, current_states[cell], ok_print, fail_print)
            if ok_print and not fail_print and not print_ok_cell_states:
                info("All cell states were OK.")
            if ok_print and print_ok_cell_states:
                info(f"{ok_print}")
            if fail_print:
                error(f"Loop {self.logger.loop + 1}{extra_info}: {fail_print}")
                if ok_print and not print_ok_cell_states:
                    info("Other cells were ok.")
                raise WrongCellStates(fail_print)

    def get_faulty_cells(self, degraded_cells=None, print_to_eventlog=True, admin_connection=None,
                         degraded_cells_stops_wait=False):
        """
        Checks if there are disabled cells. If disabled cells found, returns list of faulty cells. If parameter
        degraded_cells_stops_wait is set to True then stops waiting for faulty cells also if cells are degraded.

        :param str admin_connection: Admin connection name. Default value is None so it will be "default".
        :param list degraded_cells: List of degraded cells, if no degraded cells are expected, is None.
        :param bool print_to_eventlog: Default is True, if False doesn't print to eventlog.
        :param bool degraded_cells_stops_wait: If this is set to True then waiting of faulty cells is stopped also if
                                               cells are in degraded state.
        :return list: List of faulty cells or if no disabled cells returns empty list.
        """
        faulty_cells = []
        current_states = self.get_current_cell_states(admin_connection)
        if BuiltIn().get_variable_value("${RFS}"):  # RFS environment in question
            remote_current_states = self.get_current_cell_states("remote")
            current_states.update(remote_current_states)
        self.logger.debug("Current states: {}".format(current_states))
        if current_states:
            for cell in current_states:
                degraded_cell = True if degraded_cells and cell in degraded_cells else False
                if degraded_cell:
                    self.logger.debug(f"{cell} is allowed to have degraded state.")
                faulty_cell = self._check_if_cell_is_faulty(cell, current_states[cell], degraded_cell,
                                                            degraded_cells_stops_wait)
                if faulty_cell:
                    faulty_cells.append(faulty_cell)
        else:
            warning("Could not find current cell states.")
        if faulty_cells:
            if print_to_eventlog:
                if degraded_cells_stops_wait:
                    info("Found degraded or faulty cells: {}".format(faulty_cells))
                else:
                    info("Found faulty cells: {}".format(faulty_cells))
            else:
                self.logger.debug("Found faulty/degraded cells: {}".format(faulty_cells))
        else:
            if print_to_eventlog:
                if degraded_cells_stops_wait:
                    info("All cell states were OK, no degraded or faulty cells found.")
                else:
                    info("All cell states were OK, no faulty cells.")
            else:
                self.logger.debug("All cell states were OK, no faulty cells.")
        return faulty_cells

    def parse_cell_information_from_dictionary(self, cells, cell_info, info_key_1, info_key_2):
        """
        Parses cell information from dictionary that is got by get_cells_info method of taf.sbts.oam.coam.admin.

        :param cells: dictionary got by get_cells_info method.
        :param cell_info: local cell key f.ex. LNCell-1.
        :param info_key_1: can be f.ex. 'id'.
        :param info_key_2: f.ex. 'configuration'.
        :return str: String containing parsed value f.ex. MRBTS-26241/LNBTS-26241/LNCEL-17697.
        """
        parsed_value = ""
        for c_i in cells:
            self.logger.debug(info_key_1 in cells[c_i] and info_key_2 in cells[c_i][info_key_1])
            if c_i == cell_info and info_key_1 in cells[c_i] and info_key_2 in cells[c_i][info_key_1]:
                parsed_value = cells[cell_info][info_key_1][info_key_2]
                self.logger.debug("Parsed value of the cell {} is {}".format(cell_info, parsed_value))
                break
        if not parsed_value:
            error("Loop {}: Something has changed in cell information dictionary, cannot parse configuration "
                  "name for cell {}".format(self.logger.loop + 1, cell_info))
            raise EnvironmentIssue
        self.logger.debug(
            "Cell's {} parsed value is {}.\nKeys '{}' and '{}' were used to parse".format(
                cell_info, parsed_value, info_key_1, info_key_2))
        return parsed_value

    def parse_cell_and_add_to_list(self, cell_to_parse, cells, cell_information, bts_name, all_elements):
        cells_for_alarm = []
        if cell_to_parse.count('/') >= 2:
            self.logger.debug("Parameter cell_to_parse is dist_name {}".format(cell_to_parse))
            cell_id = self.parse_cell_information_from_dictionary(
                cells, cell_information, 'id', 'configuration')
            if cell_id == cell_to_parse:
                if all_elements:
                    cell_name = self.get_cell_name_from_commissioning(cell_id, all_elements)
                    if cell_name:
                        cells_for_alarm.append("[{}][{}] {}".format(bts_name, cell_name, cell_id))
                    else:
                        cells_for_alarm.append("[{}] {}".format(bts_name, cell_id))
                else:
                    cells_for_alarm.append("[{}] {}".format(bts_name, cell_id))
        elif cell_to_parse.isdigit() or (
                len(self._safe_split(cell_to_parse, '-')) > 1 and
                self._safe_split(cell_to_parse, '-')[1].isdigit()):
            self.logger.debug(f"Parameter cell_to_parse is local_id {cell_to_parse}")
            self.logger.debug(f"cell_information: {cell_information}")
            self.logger.debug(f"cell physical id: {cells[cell_information].get('physicalCellId', '')}")
            parts = self._safe_split(cell_information, '-')
            sec_part = parts[1] if len(parts) > 1 else ""
            cond_name = (cell_to_parse == sec_part or cell_to_parse == cell_information)
            phys_id = str(cells[cell_information].get('physicalCellId', ''))
            if cond_name or str(cell_to_parse) == phys_id:
                cell_id = self.parse_cell_information_from_dictionary(
                    cells, cell_information, 'id', 'configuration')
                if all_elements:
                    cell_name = self.get_cell_name_from_commissioning(cell_id, all_elements)
                    if cell_name:
                        cells_for_alarm.append(f"[{bts_name}][{cell_name}] {cell_id}")
                    else:
                        cells_for_alarm.append(f"[{bts_name}] {cell_id}")
                else:
                    cells_for_alarm.append(f"[{bts_name}] {cell_id}")
        else:
            error("Loop {}: Value of parameter cell_to_parse='{}' is wrong. Cell_to_parse should be local_cell id of "
                  "cell or dist_name of cell.".format(self.logger.loop + 1, cell_to_parse))
            raise ScriptIssue
        return cells_for_alarm

    def parse_cell_information_for_alarm(self, cell_to_parse=None):
        """
        Parses cell information and modify it to the type that is seen in alarm.

        :param cell_to_parse: A list of local_ids or dist_names of cells or a string of local_id or dist_name.
        :return list: List of cells in the form that is in unit_path variable of alarm.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if not self.scf:
            self.scf = BuiltIn().get_library_instance("SCF")
        if isinstance(cell_to_parse, int):
            cell_to_parse = str(cell_to_parse)
        cells_for_alarm = []
        cells = self.bts.cells
        all_elements = {}
        if self.bts.check_if_5g_environment(print_eventlog=False):
            all_elements_5g = self.scf.get_class_dict("com.nokia.srbts.nrbts:NRCELL")
            all_elements.update(all_elements_5g)
        if self.bts.check_if_gsm_environment(print_eventlog=False):
            all_elements_gsm = self.scf.get_class_dict("com.nokia.srbts.gsm:GNCEL")
            all_elements.update(all_elements_gsm)
        if self.bts.check_if_lte_environment(print_eventlog=False):
            all_elements_lte = self.scf.get_class_dict("NOKLTE:LNCEL")
            all_elements.update(all_elements_lte)
        self.logger.debug(f"All cell elements from commissioning file: {all_elements}")
        self.logger.debug("Parse cell information from this: {}".format(cells))
        for cell_info in cells:
            if cell_to_parse:
                self.logger.debug("All cells are not added to alarm, just specific cells: {}".format(cell_to_parse))
                if isinstance(cell_to_parse, list):
                    for specific_cell in cell_to_parse:
                        cells_for_alarm.extend(
                            self.parse_cell_and_add_to_list(
                                specific_cell, cells, cell_info, self.bts.bts_name, all_elements))
                elif isinstance(cell_to_parse, str):
                    cells_for_alarm.extend(self.parse_cell_and_add_to_list(
                        cell_to_parse, cells, cell_info, self.bts.bts_name, all_elements))
                else:
                    error("Loop {}: Type of parameter cell_to_parse should be list or string, "
                          "now it is {}, NOK.".format(self.logger.loop + 1, type(cell_to_parse)))
                    raise ScriptIssue
            else:
                self.logger.debug("All cells are added to alarm")
                cell_id = self.parse_cell_information_from_dictionary(cells, cell_info, 'id', 'configuration')
                cell_name = self.get_cell_name_from_commissioning(cell_id, all_elements)
                if cell_name:
                    cells_for_alarm.append("[{}][{}] {}".format(self.bts.bts_name, cell_name, cell_id))
                else:
                    cells_for_alarm.append("[{}] {}".format(self.bts.bts_name, cell_id))
        return cells_for_alarm

    def get_cell_name_from_commissioning(self, cell_dist_name, dictionary_of_class):
        """ Check if cellName is in commissioning file."""
        cell_name = ""
        if dictionary_of_class:
            for cell_d_name in dictionary_of_class:
                if cell_d_name == cell_dist_name:
                    if "cellName" in dictionary_of_class[cell_dist_name]:
                        cell_name = dictionary_of_class[cell_dist_name]["cellName"]
                        break
            self.logger.debug("Searched distName:{},\nDictionary from which cell is searched:{},\ncellName: {}".format(
                cell_dist_name, dictionary_of_class, cell_name))
        else:
            self.logger.debug("Commissioning file didn't have class com.nokia.srbts.nrbts:NRCELL nor NOKLTE:LNCEL")
        return cell_name

    def get_cell_distname_by_localid(self, local_id):
        """
        Parse cell distName.

        :param str/list local_id: localId of cell f.ex. 1 or LNCell-1.
        :return str: distName of cell f.ex MRBTS-26241/LNBTS-26241/LNCEL-17697 or list
                     [MRBTS-26241/LNBTS-26241/LNCEL-17697, MRBTS-26241/LNBTS-26241/LNCEL-17698].
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        list_of_cells = []
        cells = self.bts.cells
        self.logger.debug("Parse local_id and dist_name of cell from this: {}".format(cells))
        for cell_name, cell_info in cells.items():
            cell_name_valid = False
            rat = "NR" if "NR" in cell_name else "GN" if "GN" in cell_name else "LN"
            conf_number = None
            if rat == "GN":
                conf_number = self._parse_configuration_number_from_cell_info(cell_info)
            if isinstance(local_id, list):
                for l_id in local_id:
                    if "-" in str(l_id):
                        cell_name_valid = cell_name == str(l_id)
                    l_id_str = str(l_id)
                    l_id_last = self._safe_split(l_id_str, "-")[-1]
                    phys_ok = (rat == "LN" and str(l_id_last) == str(cell_info.get('physicalCellId', "")))
                    glob_ok = (rat == "NR" and str(l_id_last) == str(cell_info.get('globalCellId', "")))
                    gsm_ok = (rat == "GN" and str(l_id_last) == str(conf_number))
                    if cell_name_valid or phys_ok or glob_ok or gsm_ok:
                        parts = self._safe_split(cell_name, '-')
                        sec_part = parts[1] if len(parts) > 1 else ""
                        self.logger.debug(
                            f"local_id: {l_id_last}, cell_name.split('-')[1]: {sec_part}")
                        cell_dist_name = self.parse_cell_information_from_dictionary(
                            cells, cell_name, 'id', 'configuration')
                        if cell_dist_name not in list_of_cells:
                            list_of_cells.append(cell_dist_name)
            elif isinstance(local_id, str):
                if "-" in local_id:
                    cell_name_valid = cell_name == local_id
                local_last = self._safe_split(local_id, "-")[-1]
                phys_ok = (rat == "LN" and str(local_last) == str(cell_info.get('physicalCellId', "")))
                glob_ok = (rat == "NR" and str(local_last) == str(cell_info.get('globalCellId', "")))
                gsm_ok = (rat == "GN" and str(local_last) == str(conf_number))
                if cell_name_valid or phys_ok or glob_ok or gsm_ok:
                    parts = self._safe_split(cell_name, '-')
                    sec_part = parts[1] if len(parts) > 1 else ""
                    self.logger.debug(
                        f"local_id: {local_last}, cell_name.split('-')[1]: {sec_part}")
                    cell_dist_name = self.parse_cell_information_from_dictionary(
                        cells, cell_name, 'id', 'configuration')
                    return cell_dist_name
        return list_of_cells

    def get_cell_global_id_by_local_id(self, local_id, rat="lte"):
        """
        Get globalCellId by local id

        :param str local_id: Local id
        :param str rat: (Optional) RAT. Default value "lte". Possible values: lte/nr
        :return str: globalCellId of cell
        """
        rat = "nr" if rat.lower() == "nr" else "gsm" if rat.lower() == "gsm" else "lte"
        cells_info = self.admin.get_cells_info(cell_type=rat)
        local_id = self._safe_split(str(local_id), "-")[-1]
        for cell_info in cells_info:
            self.logger.debug("cell_info: {}".format(cell_info))
            conf = cell_info['id']['configuration'] if 'id' in cell_info and 'configuration' in cell_info['id'] else ""
            conf_last = self._safe_split(conf, "-")[-1]
            phys = cell_info.get('physicalCellId')
            glob = cell_info.get('globalCellId')
            cond = ((str(local_id) == str(conf_last) or str(local_id) == str(phys)) or
                    str(local_id) == str(glob))
            if cond:
                if 'globalCellId' not in cell_info:
                    if rat != "gsm":
                        error(
                            f"Loop {self.logger.loop + 1}: globalCellId not found from cell information dictionary.")
                        raise EnvironmentIssue(f"{rat.upper()} cell doesn't have globalCellId.")
                    else:
                        info("GSM cells doesn't have globalCellId, returning configuration id instead.")
                        return str(conf_last)
                return str(cell_info['globalCellId'])
        if not cells_info:
            error("Loop {}: Check used rat. Now script gets {}".format(self.logger.loop + 1, rat))
        return None

    def get_cell_used_id_by_local_id(self, local_id, rat="LN", add_prefix=False):
        """
        Get used id by local id

        :param str local_id: Local id
        :param str rat: (Optional) RAT. Default value "LN". Possible values: LN/NR
        :param bool add_prefix: (Optional) If True, add prefix to used id. Default value False.
        :return str: used id of cell
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        local_id = self._safe_split(str(local_id), "-")[-1]
        for cell_rat, cell_info in self.bts.cells.items():
            if rat in cell_rat:
                self.logger.debug(f"cell_info: {cell_info}")
                conf = cell_info['id']['configuration'] if (
                        'id' in cell_info and 'configuration' in cell_info['id']) else ""
                conf_last = self._safe_split(conf, "-")[-1]
                phys = cell_info.get('physicalCellId')
                glob = cell_info.get('globalCellId')
                cond = ((str(local_id) == str(conf_last) or str(local_id) == str(phys)) or
                        str(local_id) == str(glob))
                if cond:
                    if "GN" in cell_rat:
                        cell_id = self._parse_configuration_number_from_cell_info(cell_info)
                    else:
                        cell_id = str(phys) if rat == "LN" else str(glob)
                    if add_prefix:
                        return f"{rat}Cell-{cell_id}"
                    else:
                        return cell_id
        warning(f"Cell with local id {local_id} not found from cell dictionary")
        return local_id

    def get_localids_and_distnames_of_cells(self):
        """
        Parse local_cell_ids and dist_names of all cells.

        :return dict: Dictionary local_id[dist_name] of all cells.
        """
        local_ids_and_dist_names = {}
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        cells = self.bts.cells
        self.logger.debug("Parse local_ids and dist_names of cells from this: {}".format(cells))
        for cell_info in cells:
            local_ids_and_dist_names[cell_info] = self.parse_cell_information_from_dictionary(
                cells, cell_info, 'id', 'configuration')
        self.logger.debug("Local ids and dist_names of cells {} ".format(local_ids_and_dist_names))
        return local_ids_and_dist_names

    def map_global_id_to_lncel_r(self, given_id):
        """
        Map LNCEL_L-x to LNCEL_R dist name.

        :param str given_id: LNCEL physical cell id
        :return str: LNCEL_R dist name
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        for cell_information in self.bts.cells.values():
            last = self._safe_split(given_id, "-")[-1]
            if last == str(cell_information["physicalCellId"]):
                return str(cell_information["id"]["internal"])
        error(
            f"Loop {self.logger.loop + 1}: Given LNCEL physical cell id {given_id} is not found from cell dictionary")
        return None

    def _smallest_id_of_cell(self):
        """
        NR cells can be configured with different cell ids. This method finds the smallest cell ids from all cells.

        :return dict: Sorted dictionary of smallest cell ids of all cells.
        """
        smallest_id_cells = {}
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        for cell, cell_information in self.bts.cells.items():
            parts = self._safe_split(cell, '-')
            dn_id = int(parts[1]) if len(parts) > 1 and parts[1].isdigit() else 0
            if "globalCellId" in cell_information and "physicalCellId" in cell_information:
                global_cell_id = int(cell_information["globalCellId"])
                physical_cell_id = int(cell_information["physicalCellId"])
                smallest_id_cells[cell] = str(min(global_cell_id, physical_cell_id, dn_id))
            else:  # gsm cell doesn't have globalCellId nor physicalCellId
                smallest_id_cells[cell] = str(dn_id)
        return dict(sorted(smallest_id_cells.items(), key=lambda x: int(x[1])))

    def map_cells_to_smallest_ids(self, include_smallest_id=False):
        """
        Translate cell id to smallest cell id.

        :return dict: Dictionary of smallest cell ids of all cells.
        """
        cells = {}
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        smallest_id_cells = self._smallest_id_of_cell()
        self.logger.debug("Smallest cell ids of all cells: {}".format(smallest_id_cells))
        cell_no = 1
        for cell, smallest_id in smallest_id_cells.items():
            cells[str(cell_no)] = self.bts.cells[cell] if not include_smallest_id else (self.bts.cells[cell],
                                                                                        smallest_id)
            cell_no += 1
        self.logger.debug("Mapped cells to smallest cell ids: {}".format(cells))
        return cells

    def get_smallest_id_of_cell(self, selected_cell):
        """
        Get smallest cell id of cell.

        :param str selected_cell: Selected cell.
        :return str: Smallest id of cell
        """
        smallest_id_cells = self.map_cells_to_smallest_ids(include_smallest_id=True)
        for cell_no, (_, smallest_id) in smallest_id_cells.items():
            if selected_cell == cell_no:
                return smallest_id

    def get_cells_rmods_or_both_of_rat(self, rat, cell_rmod_or_both="both"):
        """
        Gets cells or radios or both of specific radio access technology.

        :param str rat: Radio access technology. Possible values are: LTE, NR, WCDMA and GSM.
        :param str cell_rmod_or_both: Possible values are: cells, rmods or both. Default value is both.
        :return list: Returns list of cells or radios or both of given RAT or empty list.
        """
        type_rat = {
            "GSM": "GNCell",
            "WCDMA": "WNCell",
            "LTE": "LNCell",
            "NR": "NRCell"
        }
        cells_of_rat = []
        radios_of_rat = []
        search_str = type_rat[rat]
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        self.logger.debug("self.bts.rmod_cell_links: {}".format(self.bts.rmod_cell_links))
        if self.bts.rmod_cell_links:
            for rmod in self.bts.rmod_cell_links:
                for cell in self.bts.rmod_cell_links[rmod]:
                    if search_str in cell:
                        if cell_rmod_or_both in ("both", "cells"):
                            cells_of_rat.append(cell)
                        elif cell_rmod_or_both in ("both", "rmods"):
                            if rmod not in radios_of_rat:
                                radios_of_rat.append(rmod)
        if cell_rmod_or_both == "both":
            return cells_of_rat, radios_of_rat
        elif cell_rmod_or_both == "cells":
            return cells_of_rat
        elif cell_rmod_or_both == "rmods":
            return radios_of_rat
        else:
            error("Loop {}: Unallowed value given to cell_rmod_or_both parameter: {}. Only values: cells, rmods and "
                  "both are allowed.".format(self.logger.loop + 1, cell_rmod_or_both))
            raise ScriptIssue

    def lock_cells(self, cells):
        """
        Lock cells.

        :param str/list cells: Cell to lock or list of cells to lock. F.ex MRBTS-26241/LNBTS-26241/LNCEL-17697
                               or list [MRBTS-26241/LNBTS-26241/LNCEL-17697, MRBTS-26241/LNBTS-26241/LNCEL-17698]
        """
        if isinstance(cells, list):
            for cell in cells:
                info("Lock cell {}".format(cell))
                self.admin.lock(dist_name=cell, timeout=180, detailed_output=True)
                info("Lock done.")
        elif isinstance(cells, str):
            info("Lock cell {}".format(cells))
            self.admin.lock(dist_name=cells, timeout=180, detailed_output=True)
            info("Lock done.")
        else:
            error("Loop {}: Unknown type of cell, should be str or list, is {}".format(type(cells),
                                                                                       self.logger.loop + 1))

    def unlock_cells(self, cells):
        """
        Unlock cells.

        :param str/list cells: Cell to unlock or list of cells to unlock. F.ex MRBTS-26241/LNBTS-26241/LNCEL-17697
                               or list [MRBTS-26241/LNBTS-26241/LNCEL-17697, MRBTS-26241/LNBTS-26241/LNCEL-17698]
        """
        if isinstance(cells, list):
            for cell in cells:
                info("Unlock cell {}".format(cell))
                self.admin.unlock(dist_name=cell, timeout=300, detailed_output=True)
                info("Unlock done.")
        elif isinstance(cells, str):
            info("Unlock cell {}".format(cells))
            self.admin.lock(dist_name=cells, timeout=180, detailed_output=True)
            info("Unlock done.")
        else:
            error("Loop {}: Unknown type of cell, should be str or list, is {}".format(type(cells),
                                                                                       self.logger.loop + 1))

    def parse_cell_for_alarm(self, cell_field_in_alarm, alarming_cells, cells, cell, cells_with_alarm, lte441a_active,
                             all_lte_cells_affected=False, all_nr_cells_affected=False):
        """
        Parses cell shown in alarm according to its cell_field_in_alarm value and adds it to list or in string.

        :param str cell_field_in_alarm: Can have values: cells_cli_info, faulty_cells, degraded_cells,
                                        impacted_cells_list or impacted_cell.
        :param list/str alarming_cells: List of alarming cells or string with alarming cells, depends on selected
                                        cell_field_in_alarm.
        :param dict cells: Dictionary of cells (self.bts.cells)
        :param str cell: Can be for example LNCell-1, LNCell-2, NRCell-1...
        :param list/str cells_with_alarm: List of cells or cell name as a string for example ['LNCell-1', 'LNCell-2'] or
                                          'LNCell-1'
        :param bool lte441a_active: If True then cell is expected to be degraded, not faulty.
        :param bool all_lte_cells_affected: If True then sets LTE:Faulty: All
        :param bool all_nr_cells_affected: If True then sets NR:Faulty: All
        :raise ScriptIssue: if given cell is not found from cell dictionary.
        :return list/str: type of return depends on given cell_field_in_alarm
        """
        affected_cell = ""
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if cell not in cells:
            error("Loop {}: Cell {} is not found from cell dictionary {}.".format(self.logger.loop + 1, cell, cells))
            raise ScriptIssue
        if isinstance(cells_with_alarm, list) and len(cells_with_alarm) == len(cells.keys()):
            self.logger.debug("All cells of environment are affected")
            affected_cell = " All"
        if cell_field_in_alarm == "impacted_cells_list":
            if not alarming_cells:
                alarming_cells = [cells[cell]["id"]["internal"]]
            elif cells[cell]["id"]["internal"] not in alarming_cells:
                alarming_cells.append(cells[cell]["id"]["internal"])
        elif cell_field_in_alarm == "impacted_cell":  # this field only in use in legacy alarms
            # [2_11_CLOUD561] /MRBTS-22282/LNBTS-22282/LNCEL-1
            alarming_cells = "[{}] /{}".format(self.bts.bts_name, cells[cell]["id"]["configuration"])
        elif cell_field_in_alarm == "degraded_cells":
            if affected_cell:
                alarming_cells = "Faulty: All"
            elif isinstance(cells_with_alarm, str):
                alarming_cells = "Faulty: 1"
            else:
                alarming_cells = "Faulty: {}".format(len(cells_with_alarm))
            if lte441a_active:
                alarming_cells = alarming_cells.replace("Faulty", "Degraded")
        elif cell_field_in_alarm == "faulty_cells":
            # if all cells are affected this field may be empty
            bts_id = self.bts.get_parameter_value_from_bts_info("btsId")
            nmbr = cell.split("-")[1]
            if not alarming_cells:
                alarming_cells = ["{}/{}".format(bts_id, nmbr)]
            elif "{}/{}".format(bts_id, nmbr) not in alarming_cells:
                alarming_cells.append("{}/{}".format(bts_id, nmbr))
        elif cell_field_in_alarm == "cells_cli_info":
            if all_lte_cells_affected and all_nr_cells_affected:
                return "LTE:Faulty: AllNR:Faulty: All / NR:Faulty: AllLTE:Faulty: All"
            if all_lte_cells_affected:
                return "LTE:Faulty: All"
            if all_nr_cells_affected:
                return "NR:Faulty: All"
            cell_conf = cells[cell]["id"]["configuration"]
            cell_state = "LTE:Faulty:"  # NR:Faulty: All
            split_cell = "LNCEL-"
            if "NR" in cell:
                cell_state = "NR:Faulty:"
                split_cell = "NRCEL-"
            if "GN" in cell:
                cell_state = "GN:Faulty:"
                split_cell = "GNCEL-"
            if lte441a_active:
                cell_state = cell_state.replace("Faulty", "Degraded")
            if affected_cell:
                alarming_cells = "{}{}".format(cell_state, affected_cell)
            elif not alarming_cells:
                alarming_cells = "{}{}".format(cell_state, cell_conf[cell_conf.rfind("/") + 1:])
            elif cell_conf[cell_conf.rfind("/") + 1:] not in alarming_cells:
                alarming_cells = "{}{}".format(alarming_cells, cell_conf[cell_conf.rfind("/") + 1:])
                split_list = alarming_cells.split(split_cell)
                ordered_cells = split_list[0]
                split_list.pop(0)
                for c in sorted(split_list):
                    ordered_cells = ordered_cells + split_cell + c
                alarming_cells = ordered_cells
        self.logger.debug("Cell in alarm: {}".format(alarming_cells))
        return alarming_cells

    def get_cells_to_alarm_format(self, cells_with_alarm, cell_field_in_alarm="cells_cli_info", lte441a_active=False,
                                  all_lte_cells_affected=False, all_nr_cells_affected=False):
        """
        This method modifies cell/cells to format that is used in alarm object. User can define field of alarm that is
        returned with cell_field_in_alarm parameter. Default field is cells_cli_info.

        :param str/list cells_with_alarm: Cell/Cells to be added to alarm for example:
                                          "LNCell-1" or ["LNCell-1", "LNCell-2"]
        :param str cell_field_in_alarm: Default value is cells_cli_info. Can have values: cells_cli_info, faulty_cells,
                                        degraded_cells, impacted_cells_list or impacted_cell.
                                        NOTE that value of impacted_cells_list differs in active alarm and in alarm
                                        history, because of admin output, and that is why it cannot be used if the alarm
                                        is checked also from alarm history.
                                        NOTE that field faulty_cells may be empty list if all cells are affected, at
                                        least it is working like this in some 5G environments.
                                        NOTE degraded_cells field tells how many cells are affected, number in it is not
                                        the cell id.
        :param bool lte441a_active: Default value False, if set to True cells expected to be degraded, not faulty.
        :param bool all_lte_cells_affected: If True then sets LTE:Faulty: All
        :param bool all_nr_cells_affected: If True then sets NR:Faulty: All
        :raise ScriptIssue: if type of cells_to_alarm is not str or list or if cell_field_in_alarm doesn't have sane
                            value or if there aren't any cells in the environment.
        :return list/str: List/str of cells/cell for alarm
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if cell_field_in_alarm not in ("cells_cli_info", "faulty_cells", "degraded_cells", "impacted_cells_list",
                                       "impacted_cell"):
            error(f"Loop {self.logger.loop + 1}: Given parameter cell_field_in_alarm is not cells_cli_info, "
                  f"faulty_cells, degraded_cells, impacted_cells_list or impacted_cell.")
            raise ScriptIssue("Given parameter cell_field_in_alarm is not cells_cli_info, faulty_cells, "
                              "degraded_cells, impacted_cells_list or impacted_cell.")
        cells = self.bts.cells
        self.logger.debug(f"Parse cell information from this: {cells}")
        alarming_cells = []
        if not cells_with_alarm:
            self.logger.debug("No cells expected, return empty list.")
            return alarming_cells
        if isinstance(cells_with_alarm, str):
            for cell in cells:
                if cell == cells_with_alarm:
                    alarming_cells = self.parse_cell_for_alarm(cell_field_in_alarm, alarming_cells, cells, cell,
                                                               cells_with_alarm, lte441a_active,
                                                               all_lte_cells_affected=all_lte_cells_affected,
                                                               all_nr_cells_affected=all_nr_cells_affected)
        elif isinstance(cells_with_alarm, list):
            for cell_with_alarm in cells_with_alarm:
                alarming_cells = self.parse_cell_for_alarm(cell_field_in_alarm, alarming_cells, cells,
                                                           cell_with_alarm, cells_with_alarm, lte441a_active,
                                                           all_lte_cells_affected=all_lte_cells_affected,
                                                           all_nr_cells_affected=all_nr_cells_affected)
        else:
            error(f"Loop {self.logger.loop + 1}: Cells should be given as a list or as a string not as "
                  f"{cells_with_alarm} ({type(cells_with_alarm)})")
            raise ScriptIssue(f"Cells should be given as a list or as a string not as {cells_with_alarm}.")
        if not alarming_cells:
            error(f"Loop {self.logger.loop + 1}: Cells {cells_with_alarm} were not found from the environment. "
                  f"Cells in environment are {cells.keys()}.")
            raise ScriptIssue(f"Cells {cells_with_alarm} were not found from the environment.")
        return alarming_cells

    def get_directions_of_cells(self, print_to_eventlog=True):
        """
        Get directions of all cells, collects all RXs and TX of cell to list.

        :param bool print_to_eventlog: If True, prints cell directions to eventlog, default is True.
        :return dict: Returns dictionary where cell is a key and TX and RX are collected to list.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        cell_directions = {}
        self.logger.debug("Cell information: {}".format(self.bts.cells))
        for cell in self.bts.cells:
            directions = []
            carrier_list = self.bts.cells[cell]['carrierList']
            for carrier in carrier_list:
                directions.append(carrier['direction'])
            cell_directions[cell] = directions
            self.logger.debug("directions: {}".format(cell_directions))
        if print_to_eventlog:
            info("Cells and directions: {}".format(cell_directions))
        else:
            self.logger.debug("Cells and directions: {}".format(cell_directions))
        return cell_directions

    def check_if_cells_have_at_least_two_tx(self, selected_cell=""):
        """
        Check that cells have at least two TXs.

        :param str selected_cell: Optional, if not given checks all cells. Can be for example 'LNCell-2'.
        :return bool: Return True if all cells or selected cell have at least two TX else return False

        """
        cells_and_directions = self.get_directions_of_cells()
        counted_tx = []
        for cell in cells_and_directions:
            if selected_cell and cell == selected_cell:
                if cells_and_directions[cell].count("TX") > 1:
                    info(f"Cell {selected_cell} has {cells_and_directions[cell].count('TX')} TX (more than one TX)")
                    return True
                else:
                    info(f"Cell {selected_cell} has {cells_and_directions[cell].count('TX')} TX (less than two TX)")
                    return False
            else:
                if cells_and_directions[cell].count("TX") >= 2:
                    counted_tx.append(cell)
        if counted_tx and len(counted_tx) == len(cells_and_directions.keys()):
            info("All cells have at least two TX.")
            return True
        elif counted_tx:
            info(f"Cells {counted_tx} have at least two TX, but cells "
                 f"{set(cells_and_directions.keys()) - set(counted_tx)} don't.")
            return False
        else:
            info("All cells have less than two TX.")
            return False

    def check_if_cells_have_at_least_two_rx(self, selected_cell=""):
        """
        Check that cells have at least two RXs.

        :param str selected_cell: Optional, if not given checks all cells. Can be for example 'LNCell-2'.
        :return bool: Return True if all cells or selected cell have at least two RX else return False

        """
        cells_and_directions = self.get_directions_of_cells()
        counted_rx = []
        for cell in cells_and_directions:
            if selected_cell and cell == selected_cell:
                if cells_and_directions[cell].count("RX") > 1:
                    info(f"Cell {selected_cell} has {cells_and_directions[cell].count('RX')} RX (more than one RX)")
                    return True
                else:
                    info(f"Cell {selected_cell} has {cells_and_directions[cell].count('RX')} RX (less than two RX)")
                    return False
            else:
                if cells_and_directions[cell].count("RX") >= 2:
                    counted_rx.append(cell)
        if counted_rx and len(counted_rx) == len(cells_and_directions.keys()):
            info("All cells have at least two RX.")
            return True
        elif counted_rx:
            info(f"Cells {counted_rx} have at least two RX, but cells "
                 f"{set(cells_and_directions.keys()) - set(counted_rx)} don't.")
            return False
        else:
            info("All cells have less than two RX.")
            return False

    def get_number_of_tx_or_rx_on_cell(self, txrx_resource="RX", selected_cell=""):
        """
        Get number of tx or rx on cell

        :param str txrx_resource: 'TX' or 'RX'
        :param str/list selected_cell: Optional, if not given checks all cells. Can be for example 'LNCell-2'.
        :return dict: Return dict of all cells with number of resource on them or if selected_cell is given dict of
                      selected_cells
        """
        cells_and_directions = self.get_directions_of_cells(print_to_eventlog=False)
        number_of_resource_on_cell = {}
        if selected_cell and isinstance(selected_cell, str):
            selected_cell = [selected_cell]
        for cell in cells_and_directions:
            if selected_cell:
                for selected in selected_cell:
                    if selected and cell == selected:
                        if cells_and_directions[cell].count(txrx_resource.upper()) > 0:
                            resource_amount = cells_and_directions[cell].count(txrx_resource.upper())
                            info(f"Cell {selected} has {resource_amount} {txrx_resource.upper()}")
                            number_of_resource_on_cell[cell] = resource_amount
                        else:
                            info(f"No {txrx_resource.upper()} on cell {selected}")
                            number_of_resource_on_cell[cell] = 0
                        break
            elif not selected_cell:
                if cells_and_directions[cell].count(txrx_resource.upper()) > 0:
                    number_of_resource_on_cell[cell] = cells_and_directions[cell].count(txrx_resource.upper())
                else:
                    number_of_resource_on_cell[cell] = 0
        return number_of_resource_on_cell

    def wait_cells_faulty_and_all_cells_up(self, cells_faulty_limit, all_cells_up_limit):
        """
        Wait cells faulty and cells up method waits for cells to be faulty if COMMISSIONING_TRIGGERED_RESET is True or
        and doesn't exist then waits for all cells to be up.

        :param str cells_faulty_limit: Time to wait for cells to be faulty.
        :param str all_cells_up_limit: Time to wait for all cells to be up.
        """
        if ("${COMMISSIONING_TRIGGERED_RESET}" in BuiltIn().get_variables() and
                BuiltIn().get_variable_value("${COMMISSIONING_TRIGGERED_RESET}")) or (
                "${COMMISSIONING_TRIGGERED_RESET}" not in BuiltIn().get_variables()):
            self.wait_for_cells_faulty(cells_faulty_limit)
        else:  # if COMMISSIONING_TRIGGERED_RESET is False, or it is not given
            info(f"Wait {cells_faulty_limit} seconds before waiting for all cells up.")
            BuiltIn().sleep(f"{cells_faulty_limit}s")
        self.wait_for_all_cells_up(all_cells_up_limit)

    def _check_if_cell_is_faulty(self, cell, current_state, allow_degraded, degraded_cells_stops_wait):
        """
        Checks if a cell is faulty by comparing cell states to working states.

        :param str cell: Cell to be checked.
        :param dict current_state: Current states of cell.
        :param bool allow_degraded: True if availabilityStatus is allowed to have degraded state. Else False.
        :param bool degraded_cells_stops_wait: If this is set to True then waiting of faulty cells is stopped also if
                                               cells are degraded.
        :return str: Returns the faulty cell if cell is faulty, else None.
        """
        working_states = {"administrativeState": "unlocked", "operationalState": "enabled",
                          "blockingState": "unblocked", "availabilityStatus": "online"}
        if "availabilityStatus" not in current_state:
            current_state["availabilityStatus"] = "online"
        if current_state["operationalState"] == "":
            current_state["operationalState"] = "disabled"
        for state in working_states:
            if state in current_state:
                if allow_degraded and state == "availabilityStatus" and current_state[state] == "degraded":
                    self.logger.debug(f"{state} of {cell} is {current_state[state]}, it is accepted. Cell is OK.")
                    continue
                if (state == "operationalState" and current_state[state] == "disabled") or (
                        state == "availabilityStatus" and current_state[state] == "faulty"):
                    self.logger.debug(f"{state} of {cell} is {current_state[state]}. Cell is faulty.")
                    return cell
                elif degraded_cells_stops_wait and state == "availabilityStatus" and current_state[state] == "degraded":
                    self.logger.debug(f"{state} of {cell} is {current_state[state]}. Cell is degraded.")
                    return cell
                elif current_state[state] == working_states[state]:
                    self.logger.debug(f"{state} of {cell} is {current_state[state]}. Cell is not faulty.")
            elif state in working_states and state not in current_state:
                warning(f"{cell}'s {state} is expected to be {working_states[state]}, but it is missing "
                        f"from current cell states, NOK")
                return cell
        return None

    def _check_if_current_and_expected_states_exist(self, current_states, expected_states):
        if not current_states:
            error(f"Loop {self.logger.loop + 1}: Unable to get current states of cells")
            raise EnvironmentIssue("Unable to get current states of cells")
        if not expected_states:
            error(f"Loop {self.logger.loop + 1}: Expected states of cells are not given in test")
            raise ScriptIssue("Expected states of cells are not given in test")
        return True

    def get_key_cell_from_m_cell(self, value_to_check):
        """
        Get key cell from m cell goes through values of bts.cells parameter and if value_to_check is found from
         carrierList. Method will return key of cell of that carrieriList includes the value.

        :parameter str value_to_check: Value to check from carrierList.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if not self.bts.cells:
            error(f"Loop {self.logger.loop + 1}: Cannot go through cell values because cells are not found")
            raise EnvironmentIssue("No cells found from the environment.")
        for cell_key in self.bts.cells:
            if 'carrierList' in self.bts.cells[cell_key]:
                for carrier_list_item in self.bts.cells[cell_key]['carrierList']:
                    print(f"carrier_list_item: {carrier_list_item}")
                    self.logger.debug(f"carrier_list_item: {carrier_list_item}")
                    if "id" in carrier_list_item and "internal" in carrier_list_item["id"]:
                        chan_group = carrier_list_item["id"]["internal"]
                        self.logger.debug(f"chan_group: {chan_group}")
                        chan_group_head = self._safe_split(chan_group, "/CHANNEL_GROUP_M")[0]
                        check_val = "" if value_to_check is None else str(value_to_check)
                        if check_val in chan_group_head:
                            self.logger.debug(f"{cell_key} is same as CELL_M {check_val}")
                            return cell_key
        error(f"Loop {self.logger.loop + 1}: Value {value_to_check} not found from any cell's carrierList")
        raise ScriptIssue

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None.
        Returns list from splitting str(value); if value is None returns [""].
        """
        if value is None:
            return [""]
        return str(value).split(sep)
