"""
:author: Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
import time
import datetime
from traceback import format_exception
from collections import namedtuple
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
import testsuite.Oulu.TrunkEng.Common.Python.Resources.category_alarms_dicts as category_alarms
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (
    UnallowedAlarmFound, ExpectedAlarmNotFound, ConfigurationIssue, ScriptIssue, BTSConnectionFailure, ErrorFromAdmin)


Alarm = namedtuple("Alarm", ['alarm_id', 'fault_id', 'fault_name', 'hw_path', 'severity', 'reason', 'unit_path',
                             'impacted_cells_list', 'impacted_cell', 'degraded_cells', 'faulty_cells',
                             'cells_cli_info'])


class CheckAlarms:
    """
    CheckAlarms is used for checking alarms, active and alarm history. Accepted, expected and unallowed alarms can be
    changed.

    CheckAlarms is called in common_resources.robot. If the class is already initiated once, import robot BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("ALARMS")
    """
    active_category_alarms = True
    allowed_alarms = []
    expected_alarms = []
    allowed_alarms_file = ""
    optional_fault_found = False
    # CNI-127210
    suppressed_faults = []
    fault_active_added_allowed = []
    truck_roll = False

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.cells = BuiltIn().get_library_instance("CELLS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.rt_alarms = BuiltIn().get_library_instance("RT_ALARMS")
        self.scf = BuiltIn().get_library_instance("SCF")
        self.bts = None

    def start_alarm_listener(self, allowed_alarms_file="", allowed_alarm_list=None):
        """
        This method is called in Test Cases. It reads allowed alarms file and creates alarms accordingly.
        NOTE if ALLOWED_ALARMS is given as a TAG it will overwrite content of ALLOWED_ALARMS variable in test.

        :param str allowed_alarms_file: (Optional) Path to allowed alarms file. e.g.
                                        testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
        :param list allowed_alarm_list: (Optional) Separate allowed alarms in same format as text file
        """

        self.truck_roll = BuiltIn().get_variable_value("${TRUCK_ROLL}", "${False}")
        if self.truck_roll:
            info(f"TRUCK_ROLL was given as a TAG and it is now set to {self.truck_roll}")
        if allowed_alarms_file:
            CheckAlarms.allowed_alarms_file = allowed_alarms_file
        allowed_alarms = self.read_text_file(CheckAlarms.allowed_alarms_file)
        if allowed_alarm_list or BuiltIn().get_variable_value("${ALLOWED_ALARMS}"):
            if BuiltIn().get_variable_value("${ALLOWED_ALARMS}"):
                allowed_alarm_list = BuiltIn().get_variable_value("${ALLOWED_ALARMS}")
                if isinstance(allowed_alarm_list, str):
                    if "," in allowed_alarm_list:
                        allowed_alarm_list = allowed_alarm_list.split(',')
                        allowed_alarm_list = [alrm.strip() for alrm in allowed_alarm_list]
                    else:
                        allowed_alarm_list = [allowed_alarm_list]
            if isinstance(allowed_alarm_list, list):
                allowed_alarms.extend(allowed_alarm_list)
            else:
                warning(f"ALLOWED_ALARMS variable should be list or string, now {allowed_alarm_list} is not "
                        f"given as list nor as a string")
        CheckAlarms.allowed_alarms = self._create_allowed_alarms(allowed_alarms_list=allowed_alarms)
        if BuiltIn().get_variable_value("${SERIAL_CONSOLE}"):
            self.add_allowed_alarm(fault_name="Serial console activated")
        self.logger.debug("Allowed alarms: \n{}".format(self.pretty_alarm_print(CheckAlarms.allowed_alarms)))

    def pretty_alarm_print(self, alarm_list, loop_text=False):
        """
        Parses just meaningful values of alarm for printing purposes.

        :param list/namedtuple alarm_list: List of named alarm tuples or just named alarm tuple.
        :param bool loop_text: Loop number for error prints for log.html
        :return str: Returns parsed alarms string.
        """
        pretty_text = ""
        loop = "Loop {}: ".format(self.logger.loop+1) if loop_text else ""
        if isinstance(alarm_list, list):
            for alarm in alarm_list:
                p_text = "{}{} - {} - {}  ({}) - {} - {} - {} - {} - {} - degradedCells:{} - {} - {}".format(
                    loop, alarm.severity, alarm.alarm_id, alarm.fault_name, alarm.fault_id, alarm.unit_path,
                    alarm.reason, alarm.hw_path, alarm.impacted_cells_list, alarm.impacted_cell, alarm.degraded_cells,
                    alarm.faulty_cells, alarm.cells_cli_info)
                pretty_text = "{}{}\n".format(pretty_text, p_text)
        elif isinstance(alarm_list, dict):
            for alarms in list(alarm_list.values()):
                for alarm in alarms:
                    p_text = "{}{} - {} - {}  ({}) - {} - {} - {} - {} - {} - degradedCells:{} - {} - {}".format(
                        loop, alarm.severity, alarm.alarm_id, alarm.fault_name, alarm.fault_id, alarm.unit_path,
                        alarm.reason, alarm.hw_path, alarm.impacted_cells_list, alarm.impacted_cell,
                        alarm.degraded_cells, alarm.faulty_cells, alarm.cells_cli_info)
                    pretty_text = "{}{}\n".format(pretty_text, p_text)
        else:
            pretty_text = "{}{} - {} - {}  ({}) - {} - {} - {} - {} - {} - degradedCells:{} - {} - {}".format(
                loop, alarm_list.severity, alarm_list.alarm_id, alarm_list.fault_name, alarm_list.fault_id,
                alarm_list.unit_path, alarm_list.reason, alarm_list.hw_path, alarm_list.impacted_cells_list,
                alarm_list.impacted_cell, alarm_list.degraded_cells, alarm_list.faulty_cells, alarm_list.cells_cli_info)
        return pretty_text

    def read_text_file(self, file_path):
        """
        Creates a list of strings from a text file. Each item is separated by a new line.

        :param file_path: The text file that will be read.
        :return listed_content: List of the contents of the text file.
        """
        opened_file = open(file_path, "r")
        content = opened_file.read()
        listed_content = content.splitlines()
        listed_content = self._remove_comments(listed_content)
        opened_file.close()
        return listed_content

    def reset_alarms(self, only_rt_alarms=False):
        """
        Clears list of expected alarms and clears list of active alarms collected in RealtimeAlarms.py.

        :param bool only_rt_alarms: If True, skips clearing expected alarms. Clears only list of active alarms
        """
        if not only_rt_alarms:
            info("Clear list of expected alarms.")
            CheckAlarms.expected_alarms = []
        info("Clear list of active alarms.")
        self.rt_alarms.reset_active_alarms_during_test()

    def add_allowed_alarm(self, alarm_id=None, fault_id=None, fault_name=None, hw_path=None, severity=None,
                          reason=None, unit_path=None, impacted_cells_list=None, impacted_cell=None,
                          degraded_cells=None, faulty_cells=None, cells_cli_info=None):
        """
        Creates allowed alarm from user given values and adds it to allowed_alarms list. At least one parameter needs
        to have a value different from None. Fields that are not checked can be skipped with setting to None -value.

        :param str alarm_id: (Optional) set to None if not given. Used during comparison with alarm ID of alarms.
        :param str fault_id: (Optional) set to None if not given. Used during comparison with fault ID of alarms.
        :param str fault_name: (Optional) set to None if not given. Used during comparison with fault name of alarms.
        :param str hw_path: (Optional) set to None if not given. Used during comparison with HW path of alarms.
        :param str severity: (Optional) set to None if not given. Used during comparison with severity of alarms.
        :param str reason: (Optional) set to None if not given. Used during comparison with reason of alarms.
        :param str unit_path: (Optional) set to None if not given. Used during comparison with unit path of alarms.
        :param list impacted_cells_list: (Optional) set to None if not given. Used during comparison with impacted cells
        :param str impacted_cell: (Optional) set to None if not given. Used during comparison with impacted_cell field.
        :param str degraded_cells: (Optional) set to None if not given. Used during comparison with degraded cells.
        :param str faulty_cells: (Optional) set to None if not given. Used during comparison with impactedCellsLcrIdList
        :param list cells_cli_info: (Optional) set to None if not given. Used during comparison with cells cli info
        """
        add_alarm = True
        fault_name, alarm_id = self.update_alarm(fault_id=fault_id, fault_name=fault_name, alarm_id=alarm_id)
        a_text = (f"'{severity} - {alarm_id} - {fault_name}  ({fault_id}) - {unit_path} - {reason} - {hw_path} -"
                  f" {impacted_cells_list} - {impacted_cell} - degradedCells:{degraded_cells} - {faulty_cells} -"
                  f" {cells_cli_info}'")
        if CheckAlarms.allowed_alarms:
            for a_alarm in CheckAlarms.allowed_alarms:
                if (a_alarm.fault_id == fault_id and a_alarm.fault_name == fault_name and a_alarm.alarm_id == alarm_id
                        and a_alarm.hw_path == hw_path and a_alarm.severity == severity and a_alarm.reason == reason
                        and a_alarm.unit_path == unit_path and a_alarm.impacted_cells_list == impacted_cells_list
                        and a_alarm.impacted_cell == impacted_cell and a_alarm.degraded_cells == a_alarm.degraded_cells
                        and a_alarm.faulty_cells == faulty_cells and a_alarm.cells_cli_info == cells_cli_info):
                    info(f"Alarm is already added to allowed alarms list, no need to add it again:\n{a_text}")
                    add_alarm = False
                    break
        if add_alarm:
            self.logger.debug(f"Add allowed alarm:\n{a_text}")
            print(f"Add allowed alarm:\n{a_text}")
            CheckAlarms.allowed_alarms.append(
                self.create_alarm(alarm_id=alarm_id, fault_id=fault_id, fault_name=fault_name, hw_path=hw_path,
                                  severity=severity, reason=reason, unit_path=unit_path,
                                  impacted_cells_list=impacted_cells_list, impacted_cell=impacted_cell,
                                  degraded_cells=degraded_cells, faulty_cells=faulty_cells,
                                  cells_cli_info=cells_cli_info))

    def add_allowed_alarms(self, list_of_alarms):
        """
        Add list of alarms to allowed alarms. NOTE list has to be list of Alarm named tuples.
        :param list list_of_alarms: List of alarms to be added to allowed alarms.
        :raise ScriptIssue if item in list is not Alarm named tuple.
        """
        for allowed_alarm in list_of_alarms:
            if isinstance(allowed_alarm, Alarm):
                self.add_allowed_alarm(alarm_id=allowed_alarm.alarm_id, fault_id=allowed_alarm.fault_id,
                                       fault_name=allowed_alarm.fault_name, hw_path=allowed_alarm.hw_path,
                                       severity=allowed_alarm.severity, reason=allowed_alarm.reason,
                                       unit_path=allowed_alarm.unit_path,
                                       impacted_cells_list=allowed_alarm.impacted_cells_list,
                                       impacted_cell=allowed_alarm.impacted_cell,
                                       degraded_cells=allowed_alarm.degraded_cells,
                                       faulty_cells=allowed_alarm.faulty_cells,
                                       cells_cli_info=allowed_alarm.cells_cli_info)
            else:
                error(f"Type of {allowed_alarm} is not Alarm named tuple. Create alarm before giving to "
                      f"add_allowed_alarms method.")
                raise ScriptIssue

    def remove_allowed_alarm(self, alarm_id=None, fault_id=None, fault_name=None):
        """
        Remove allowed alarm from allowed list. Fault_id and fault_name are the fields that decide the removed.

        :param str alarm_id: (Optional) set to None if not given. Used during comparison with alarm ID of alarms.
        :param str fault_id: (Optional) set to None if not given. Used during comparison with fault ID of alarms.
        :param str fault_name: (Optional) set to None if not given. Used during comparison with fault name of active
                               alarms.
        """
        fault_name, alarm_id = self.update_alarm(fault_id=fault_id, fault_name=fault_name, alarm_id=alarm_id)
        allowed_for_loop = CheckAlarms.allowed_alarms
        for allowed_alarm in allowed_for_loop:
            if alarm_id is not None and fault_id is not None and fault_name is not None:
                if (alarm_id == allowed_alarm.alarm_id and fault_id == allowed_alarm.fault_id and
                        fault_name == allowed_alarm.fault_name):
                    info("Remove alarm '{}' from allowed_alarms list.".format(self.pretty_alarm_print(allowed_alarm)))
                    CheckAlarms.allowed_alarms.remove(allowed_alarm)
                    break
            elif fault_id is not None and fault_name is not None:
                if fault_id == allowed_alarm.fault_id and fault_name == allowed_alarm.fault_name:
                    info("Remove alarm '{}' from allowed_alarms list.".format(self.pretty_alarm_print(allowed_alarm)))
                    CheckAlarms.allowed_alarms.remove(allowed_alarm)
                    break
            elif ((fault_id == allowed_alarm.fault_id and allowed_alarm.fault_id is not None) or
                    (fault_name == allowed_alarm.fault_name and allowed_alarm.fault_name is not None)):
                info("Remove alarm '{}' from allowed_alarms list.".format(self.pretty_alarm_print(allowed_alarm)))
                CheckAlarms.allowed_alarms.remove(allowed_alarm)
                break

    def add_expected_alarm(self, option=None, alarm_id=None, fault_id=None, fault_name=None, hw_path=None,
                           severity=None, reason=None, unit_path=None, impacted_cells_list=None, impacted_cell=None,
                           degraded_cells=None, faulty_cells=None, cells_cli_info=None):
        """
        Creates alarm from user given values and adds it to a list of expected alarms. At least one parameter needs to
        have a value different from None.

        :param str option: (Optional) set to None if not given. Additional information for allowing an alarm.
        :param str alarm_id: (Optional) set to None if not given. Used during comparison with alarm ID of alarms.
        :param str fault_id: (Optional) set to None if not given. Used during comparison with fault ID of alarms.
        :param str fault_name: (Optional) set to None if not given. Used during comparison with fault name of alarms.
        :param str hw_path: (Optional) set to None if not given. Used during comparison with HW path of alarms.
        :param str severity: (Optional) set to None if not given. Used during comparison with severity of alarms.
        :param str reason: (Optional) set to None if not given. Used during comparison with reason of alarms.
        :param str unit_path: (Optional) set to None if not given. Used during comparison with unit path of alarms.
        :param list impacted_cells_list: (Optional) set to None if not given. Used during comparison with impacted cell
                                         list.
        :param str impacted_cell: (Optional) set to None if not given. Used during comparison with impacted_cell field.
        :param str degraded_cells: (Optional) set to None if not given. Used during comparison with degraded cells
        :param str faulty_cells: (Optional) set to None if not given. Used during comparison with impactedCellsLcrIdList
        :param list cells_cli_info: (Optional) set to None if not given. Used during comparison with cells cli info

        """
        fault_name, alarm_id = self.update_alarm(fault_id=fault_id, fault_name=fault_name, alarm_id=alarm_id)
        if isinstance(unit_path, list):
            self.logger.debug("Unit_path as list")
            for unit_p in unit_path:
                info("Add alarm to expected alarms list: \n'{} - {} - {}({}) - {} - {} - {} - {} - {} - {} - "
                     "{} - {}'".format(severity, alarm_id, fault_name, fault_id, unit_p, reason, hw_path,
                                       impacted_cells_list, impacted_cell, degraded_cells, faulty_cells,
                                       cells_cli_info))
                CheckAlarms.expected_alarms.append(
                    self.create_alarm(alarm_id=alarm_id, fault_id=fault_id, fault_name=fault_name,
                                      hw_path=hw_path, severity=severity, reason=reason, unit_path=unit_p,
                                      impacted_cells_list=impacted_cells_list, impacted_cell=impacted_cell,
                                      degraded_cells=degraded_cells, faulty_cells=faulty_cells,
                                      cells_cli_info=cells_cli_info))
        if option == "add_cells_to_alarm":
            cells = self._get_cells()
            for cell in cells:
                unit_path = cell
                info("Add alarm to expected alarms list: \n'{} - {} - {}({}) - {} - {} - {} - {} - {} - {} - "
                     "{} - {}'".format(severity, alarm_id, fault_name, fault_id, unit_path, reason, hw_path,
                                       impacted_cells_list, impacted_cell, degraded_cells, faulty_cells,
                                       cells_cli_info))
                CheckAlarms.expected_alarms.append(
                    self.create_alarm(alarm_id=alarm_id, fault_id=fault_id, fault_name=fault_name,
                                      hw_path=hw_path, severity=severity, reason=reason, unit_path=unit_path,
                                      impacted_cells_list=impacted_cells_list, impacted_cell=impacted_cell,
                                      degraded_cells=degraded_cells, faulty_cells=faulty_cells,
                                      cells_cli_info=cells_cli_info))
        else:
            info("Add alarm to expected alarms list: \n'{} - {} - {}({}) - {} - {} - {} - {} - {} - {} - "
                 "{} - {}'".format(severity, alarm_id, fault_name, fault_id, unit_path, reason, hw_path,
                                   impacted_cells_list, impacted_cell, degraded_cells, faulty_cells,
                                   cells_cli_info))
            CheckAlarms.expected_alarms.append(
                self.create_alarm(alarm_id=alarm_id, fault_id=fault_id, fault_name=fault_name,
                                  hw_path=hw_path, severity=severity, reason=reason, unit_path=unit_path,
                                  impacted_cells_list=impacted_cells_list, impacted_cell=impacted_cell,
                                  degraded_cells=degraded_cells, faulty_cells=faulty_cells,
                                  cells_cli_info=cells_cli_info))

    def add_objects_to_expected_alarms(self, objects_to_alarm, add_values, alarm_id=None, fault_id=None,
                                       fault_name=None, hw_path=None, severity=None, reason=None, unit_path=None,
                                       impacted_cells_list=None, impacted_cell=None, degraded_cells=None,
                                       faulty_cells=None, cells_cli_info=None):
        """
        Creates alarm from user given values and adds it to a list of expected alarms. At least one parameter needs to
        have a value different from None.

        :param list objects_to_alarm: List of objects for example radio or bbmod objects.
        :param list add_values: Have values that differs in every object for example unit_path, hw_path
        :param str alarm_id: (Optional) set to None if not given. Used during comparison with alarm ID of alarms.
        :param str fault_id: (Optional) set to None if not given. Used during comparison with fault ID of alarms.
        :param str fault_name: (Optional) set to None if not given. Used during comparison with fault name of alarms.
        :param str hw_path: (Optional) set to None if not given. Used during comparison with HW path of alarms.
        :param str severity: (Optional) set to None if not given. Used during comparison with severity of alarms.
        :param str reason: (Optional) set to None if not given. Used during comparison with reason of alarms.
        :param str unit_path: (Optional) set to None if not given. Used during comparison with unit path of alarms.
        :param list impacted_cells_list: (Optional) set to None if not given. Used during comparison with impacted cell
                                         list.
        :param str impacted_cell: (Optional) set to None if not given. Used during comparison with impacted_cell field.
        :param str degraded_cells: (Optional) set to None if not given. Used during comparison with degraded cells
        :param str faulty_cells: (Optional) set to None if not given. Used during comparison with impactedCellsLcrIdList
        :param list cells_cli_info: (Optional) set to None if not given. Used during comparison with cells cli info
        """
        if objects_to_alarm:
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            fault_name, alarm_id = self.update_alarm(
                fault_id=fault_id, fault_name=fault_name, alarm_id=alarm_id)
            if add_values:
                for obj in objects_to_alarm:
                    for val in add_values:
                        if val == "unit_path":
                            unit_path = self.bts.get_values_from_object(obj, val)
                        if val == "hw_path":
                            hw_path = self.bts.get_values_from_object(obj, val)
                    self.add_expected_alarm(alarm_id=alarm_id, fault_id=fault_id, fault_name=fault_name,
                                            hw_path=hw_path, severity=severity, reason=reason, unit_path=unit_path,
                                            impacted_cells_list=impacted_cells_list, impacted_cell=impacted_cell,
                                            degraded_cells=degraded_cells, faulty_cells=faulty_cells,
                                            cells_cli_info=cells_cli_info)
        else:
            self.logger.debug("No objects given to be added to expected alarm.")

    def update_alarm(self, fault_id=None, fault_name=None, alarm_id=None, unit=None):
        """
        Updates the alarm parameters IF self.active_category_alarms is set to True (default is False).

        :param str unit: (Optional) set to None if not given.
        :param str alarm_id: (Optional) set to None if not given.
        :param str fault_id: (Optional) set to None if not given.
        :param str fault_name: (Optional) set to None if not given.
        :return tuple(str, str): Returns fault_name and alarm_id.
        """
        try:
            if fault_name is None and alarm_id is None:
                self.logger.debug("No fault name or alarm id given, no need to update them.")
                return fault_name, alarm_id
            org_fault_name = fault_name
            org_alarm_id = alarm_id
            if CheckAlarms.active_category_alarms:
                self.logger.debug("Category alarms are active.")
                fault_name, alarm_id = self._update_legacy_alarm_to_category_alarm(fault_id, fault_name, alarm_id, unit)
            else:
                self.logger.debug("Legacy alarms are active.")
            if org_alarm_id is None and org_fault_name:
                return fault_name, org_alarm_id
            elif org_fault_name is None and org_alarm_id:
                return org_fault_name, alarm_id
        except KeyError as e:
            error(f"Problems with category_alarms dictionary\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        return fault_name, alarm_id

    def add_expected_alarm_to_allowed(self):
        """
        Adds the expected alarms to allowed alarms list. This is needed for example if alarm history is checked and
        expected alarm is not active anymore.
        """
        if CheckAlarms.expected_alarms:
            info("Add expected alarms also to allowed alarms: \n{} ".format(
                self.pretty_alarm_print(CheckAlarms.expected_alarms)))
            self.add_list_of_alarms_to_allowed(CheckAlarms.expected_alarms, print_reason=False)
        else:
            info("There are no expected alarms listed.")

    def add_list_of_alarms_to_allowed(self, list_of_alarms, print_reason=True):
        """
        Adds list of alarms to allowed alarms list.
        :param list list_of_alarms: List of alarms to be added to allowed alarms.
        :param bool print_reason: (Optional) Set to True if not given. Prints the reason for adding alarms.
        """
        if not isinstance(list_of_alarms, list):
            error(f"Given alarms are not in list format: {list_of_alarms}")
            raise ScriptIssue
        if list_of_alarms:
            if print_reason:
                info("Add list of alarms to allowed alarms: \n{} ".format(self.pretty_alarm_print(list_of_alarms)))
            for alarmi in list_of_alarms:
                self.add_allowed_alarm(alarm_id=alarmi.alarm_id, fault_id=alarmi.fault_id, fault_name=alarmi.fault_name,
                                       hw_path=alarmi.hw_path, severity=alarmi.severity, reason=alarmi.reason,
                                       unit_path=alarmi.unit_path, impacted_cells_list=alarmi.impacted_cells_list,
                                       impacted_cell=alarmi.impacted_cell, degraded_cells=alarmi.degraded_cells,
                                       faulty_cells=alarmi.faulty_cells, cells_cli_info=alarmi.cells_cli_info)
        else:
            if print_reason:
                info("There are no alarms listed.")

    def remove_expected_alarm_from_allowed(self):
        """
        Removes expected alarms from allowed alarms list.
        """
        if CheckAlarms.expected_alarms:
            info("Remove expected alarms {} from allowed alarms".format(
                self.pretty_alarm_print(CheckAlarms.expected_alarms)))
            for expected_alarm in CheckAlarms.expected_alarms:
                self.remove_allowed_alarm(alarm_id=expected_alarm.alarm_id, fault_id=expected_alarm.fault_id,
                                          fault_name=expected_alarm.fault_name)
        else:
            info("There are no expected alarms listed.")

    def remove_expected_alarm(self, expected_alarm):
        """
        Remove expected alarm or list of expected alarms from the CheckAlarms.expected_alarms list
        :param str/list expected_alarm: Expected alarm to be removed from expected_alarms list.
        """
        if isinstance(expected_alarm, list):
            for expected in expected_alarm:
                info("Remove alarm '{}' from expected_alarms list.".format(self.pretty_alarm_print(expected)))
                CheckAlarms.expected_alarms.remove(expected)
        else:
            info("Remove alarm '{}' from expected_alarms list.".format(self.pretty_alarm_print(expected_alarm)))
            CheckAlarms.expected_alarms.remove(expected_alarm)

    def remove_expected_alarms(self, alarm_id=None, fault_id=None, fault_name=None, only_first_alarm=False):
        """
        Removes expected alarms. If no alarm_id, fault_id and fault_name given removes all expected alarms.

        :param str alarm_id: (Optional) set to None if not given. Used during comparison with alarm ID of alarms.
        :param str fault_id: (Optional) set to None if not given. Used during comparison with fault ID of alarms.
        :param str fault_name: (Optional) set to None if not given. Used during comparison with fault name of active
                               alarms.
        :param bool only_first_alarm: (Optional) Removes only first found alarm. Useful for removing duplicates
        """
        if CheckAlarms.expected_alarms:
            if fault_id and fault_name and alarm_id:
                f_name, a_id = self.update_alarm(
                    fault_id=fault_id, fault_name=fault_name, alarm_id=alarm_id)
                for e_alarm in CheckAlarms.expected_alarms:
                    if alarm_id and ((fault_id == e_alarm.fault_id and e_alarm.fault_id is not None) and
                                     (f_name == e_alarm.fault_name and e_alarm.fault_name is not None) and
                                     (a_id == e_alarm.alarm_id and e_alarm.alarm_id is not None)):
                        self.remove_expected_alarm(e_alarm)
                        if only_first_alarm:
                            break
                    if not alarm_id and ((fault_id == e_alarm.fault_id and e_alarm.fault_id is not None) or
                                         (f_name == e_alarm.fault_name and e_alarm.fault_name is not None)):
                        self.remove_expected_alarm(e_alarm)
            else:
                info("Remove expected alarms {}".format(self.pretty_alarm_print(CheckAlarms.expected_alarms)))
                CheckAlarms.expected_alarms = []
        else:
            info("There are no expected alarms listed.")

    def _get_active_alarms_from_admin(self, admin_connection="log_admin", raise_error=True, retry=0):
        """
        Get active alarms from admin interface.

        :param str admin_connection: (Optional) Set to log_admin if not given. Admin connection to be used.
        :param bool raise_error: Default True
        :param int retry: (Optional) Set to 0 if not given. Used for retrying the method if session invalidation error
        """
        active_alarms = []
        try:
            active_alarms = self.admin.get_active_alarms(timeout=60, connection=admin_connection)
        except (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                AdminApiTerminatedException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AliasInUse, AliasLookupError) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            if raise_error:
                error(
                    f"Unable to get active alarms from admin: {admin_error.__class__.__name__}:"
                    f"{admin_error} was raised\n{tb}")
            else:
                info(f"Unable to get active alarms from admin: {admin_error.__class__.__name__}:"
                     f"{admin_error} was raised\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    if raise_error:
                        info("Unable to get active alarms from admin, because of session invalidation."
                             "Set test to fail so we will have logs about the issue and restart admin connection.")
                        BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    else:
                        info("Unable to get active alarms from admin, because of session invalidation.\n"
                             "Restart admin connection (NOTE that test will not fail to this).")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin=admin_connection, raise_error=raise_error)
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method _get_active_alarms_from_admin again after admin connection reset.")
                    self._get_active_alarms_from_admin(admin_connection=admin_connection, raise_error=raise_error,
                                                       retry=1)
                elif retry == 1:
                    if raise_error:
                        error("Unable to get active alarms from admin, because of session invalidation. Admin "
                              "connection restart did not help.")
                    else:
                        info("Unable to get active alarms from admin, because of session invalidation. Admin "
                             "connection restart did not help. NOTE this will not fail the test.")
            if raise_error:
                raise ErrorFromAdmin(f"Unable to get active alarms from admin, {admin_error.__class__.__name__} was "
                                     f"raised.")
            else:
                self.logger.debug("Unable to get active alarms. Will not raise error, used for debug reasons")
        return active_alarms

    def wait_for_active_alarm(self, time_limit="10", get_active_alarms=False):
        """
        Waits for expected alarm to be active.

        :param str time_limit: Time to wait for alarm to be active. Default value is 10s.
        :param bool get_active_alarms: (Optional) Set to False if not given. If True, gets active alarms from admin.
        :return bool: True if alarm is active, False if not.
        """
        start_time = datetime.datetime.now()
        alarm_active = False
        active_alarms = []
        # CNI-127210
        self._remove_suppressfaults_from_expected_and_allowed_alarms()
        if CheckAlarms.expected_alarms:
            while (datetime.datetime.now() - start_time).total_seconds() < int(time_limit) and not alarm_active:
                for expected_alarm in CheckAlarms.expected_alarms:
                    a_active = self.check_if_alarm_in_rt_alarms(expected_alarm)
                    if get_active_alarms:
                        parsed_active = self.parse_alarm_info_from_admin(self._get_active_alarms_from_admin())
                        a_active = self._check_if_alarm_in_rt_alarms(parsed_active, expected_alarm)
                    if a_active and expected_alarm not in active_alarms:
                        active_alarms.append(expected_alarm)
                if active_alarms and len(active_alarms) == len(CheckAlarms.expected_alarms):
                    alarm_active = True
                time.sleep(1)
            info("Wait for expected alarm DONE.")
            if not alarm_active:
                inactive_alarms = [alarm for alarm in CheckAlarms.expected_alarms if alarm not in active_alarms]
                if len(CheckAlarms.expected_alarms) == 1:
                    error("This alarm is not active after {}s wait time: \n{}".format(
                        time_limit, self.pretty_alarm_print(inactive_alarms)))
                else:
                    error("These alarms are not active after {}s wait time: \n{}".format(
                        time_limit, self.pretty_alarm_print(inactive_alarms)))
            else:
                if len(CheckAlarms.expected_alarms) == 1:
                    info("Expected alarm is active, OK.")
                else:
                    info("Expected alarms are active, OK.")
        else:
            info("There are no expected alarms listed. No need to wait for alarm to be active, returning True.")
            alarm_active = True
        return alarm_active

    def check_if_alarm_in_rt_alarms(self, expected_alarm):
        """
        Checks if expected alarm is found from RealtimeAlarms.

        NOTE if fault_id in expected_alarm is given with ' / ' then the first fault_id that is found from the alarms is
        set as expected and if the other one is also found from alarms, it is set as unallowed.

        :param obj expected_alarm: The expected alarm object.
        :return bool: Returns True if alarm is found and False if not.
        """
        if self.rt_alarms.active_alarms_during_test:
            for rt_alarms in list(self.rt_alarms.active_alarms_during_test.values()):
                for rt_alarm in rt_alarms:
                    info_text = (f"Optional expected fault_id '{expected_alarm.fault_id}' was found from alarms, but "
                                 f"because the another fault_id was found earlier from alarms this alarm is set as not"
                                 f" allowed.\nCheck from logs which fault_id was found first and which fault_id should"
                                 f" not be seen.")
                    if self._compare_alarms_and_check_if_found_earlier(rt_alarm, expected_alarm, info_text):
                        return True
                    # if self.compare_alarms(rt_alarm, expected_alarm):
        return False

    def _check_if_alarm_in_rt_alarms(self, admin_alarms, expected_alarm):
        """
        Checks if expected alarm is found from admin alarm.

        NOTE if fault_id in expected_alarm is given with ' / ' then the first fault_id that is found from the alarms is
        set as expected and if the other one is also found from alarms, it is set as unallowed.

        :param list admin_alarms: List of alarms from admin.
        :param obj expected_alarm: The expected alarm object.
        :return bool: Returns True if alarm is found and False if not.
        """
        if admin_alarms:
            for a_alarm in admin_alarms:
                info_text = (f"Optional expected fault_id '{expected_alarm.fault_id}' was found from alarms, but "
                             f"because the another fault_id was found earlier from alarms this alarm is set as not"
                             f" allowed.\nCheck from logs which fault_id was found first and which fault_id should"
                             f" not be seen.")
                if self._compare_alarms_and_check_if_found_earlier(a_alarm, expected_alarm, info_text):
                    return True
                    # if self.compare_alarms(rt_alarm, expected_alarm):
        return False

    def check_expected_alarms(self, wait_for_active=True, wait_active_timeout="10", get_active_alarms=False):
        """
        Checks that expected alarms are detected. NOTE if error is printed the fields in alarm are:
        severity - alarm_id - fault_name (fault_id) - unit_path - reason - hw_path - impacted_cells_list -
        impacted_cell - degraded_cells - faulty_cells - cells_cli_info

        :param boolean wait_for_active: (Optional) Set to True if not given. Waits for expected alarm to be active.
        :param str wait_active_timeout: (Optional) Set to 10 if not given. It is the maximum wait time (s) for the
                                         expected alarm to appear.
        :param boolean get_active_alarms: (Optional) Set to False if not given. If True, gets active alarms from admin.
        :raise ExpectedAlarmNotFound: If the expected alarm is not found.
        :return expected_alarms_found: Return boolean True if all expected alarms are found, else False.
        """
        expected_alarms_found = True
        # CNI-127210
        self._remove_suppressfaults_from_expected_and_allowed_alarms()
        if CheckAlarms.expected_alarms:
            info("All expected alarms are: \n{}".format(self.pretty_alarm_print(CheckAlarms.expected_alarms)))
            print("Allowed alarms: \n{}".format(self.pretty_alarm_print(CheckAlarms.allowed_alarms)))
            self.logger.debug("Expected alarms: {}".format(CheckAlarms.expected_alarms))
            self.logger.debug("Allowed alarms: {}".format(CheckAlarms.allowed_alarms))
            self.logger.debug("Active alarms: {}".format(self.rt_alarms.active_alarms_during_test))
            if wait_for_active:
                info("Wait expected alarm to be active max {}s: \n{}".format(
                    wait_active_timeout, self.pretty_alarm_print(CheckAlarms.expected_alarms)))
                self.logger.debug("Before waiting starts self.rt_alarms.active_alarms_during_test: {}".format(
                                  self.rt_alarms.active_alarms_during_test))
                expected_alarms_found = self.wait_for_active_alarm(wait_active_timeout, get_active_alarms)
                if not expected_alarms_found:
                    info("Expected alarm was not seen in real time alarms thread. Check from admin interface of the "
                         "main thread to verify if there is just some problems with realtime alarms thread.")
                    parsed_active = self.parse_alarm_info_from_admin(self._get_active_alarms_from_admin())
                    for expected_alarm in CheckAlarms.expected_alarms:
                        if self._check_if_alarm_in_rt_alarms(parsed_active, expected_alarm):
                            info("Expected alarm '{}' is found active in the main thread, OK.".format(
                                self.pretty_alarm_print(expected_alarm)))
                        else:
                            error("Expected alarm '{}' was not active in main thread either, NOK".format(
                                self.pretty_alarm_print(expected_alarm)))
                else:
                    # This is just for debug, not for failing the test
                    self._get_active_alarms_from_admin(raise_error=False)
                print("Alarms in realtime alarms interface: \n{}".format(
                    self.pretty_alarm_print(self.rt_alarms.active_alarms_during_test)))
                self.logger.debug("After waiting self.rt_alarms.active_alarms_during_test: {}".format(
                    self.rt_alarms.active_alarms_during_test))
            else:
                if get_active_alarms:
                    parsed_active = self.parse_alarm_info_from_admin(self._get_active_alarms_from_admin())
                for expected_alarm in CheckAlarms.expected_alarms:
                    if self.check_if_alarm_in_rt_alarms(expected_alarm) or (
                            get_active_alarms and self._check_if_alarm_in_rt_alarms(parsed_active, expected_alarm)):
                        info("Expected alarm '{}' is active, OK.".format(self.pretty_alarm_print(expected_alarm)))
                    else:
                        error("Expected alarm '{}' was not active (not found from {}) NOK".format(
                            self.pretty_alarm_print(expected_alarm),
                            self.pretty_alarm_print(self.rt_alarms.active_alarms_during_test)))
                        expected_alarms_found = False
                        # this is just for debug reason to make it easier to create pronto if some fields are lost
                        self._get_active_alarms_from_admin(raise_error=False)
            if not expected_alarms_found:
                self.check_if_unallowed_alarms(self.rt_alarms.active_alarms_during_test)
                if ("${OMKPI_CASE}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${OMKPI_CASE}")):
                    info("OMKPI test. Expected alarm(s) not found. Do not calculate KPIs (set CALCULATE_KPI to False).")
                    BuiltIn().set_suite_variable("${CALCULATE_KPI}", "${False}")
                raise ExpectedAlarmNotFound("Mandatory alarm(s) '{}' were not found as active alarm, NOK".format(
                    self.pretty_alarm_print(CheckAlarms.expected_alarms)))
        else:
            info("There are no expected alarms listed.")
        if not self.check_if_unallowed_alarms(self.rt_alarms.active_alarms_during_test):
            self.logger.debug("Active alarms: {}".format(self.rt_alarms.active_alarms_during_test))
            if ("${OMKPI_CASE}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${OMKPI_CASE}")):
                info("OMKPI test. Unallowed alarms found. Do not calculate KPIs (set CALCULATE_KPI to False).")
                BuiltIn().set_suite_variable("${CALCULATE_KPI}", "${False}")
            raise UnallowedAlarmFound()
        return expected_alarms_found

    def _get_history_and_active_alarms_from_admin(self, retry=0):
        """
        Get history and active alarms from admin

        :param int retry: (Optional) Set to 0 if not given. If retry is 0, retries the alarm check, otherwise not.
        """
        history_alarms = []
        active_and_history = []
        try:
            # this is mainly just for debug reason to make it easier to create pronto if some fields are missing etc.
            history_alarms = self.parse_alarm_info_from_admin(self.admin.get_alarm_history(
                timeout=60, detailed_output=False, connection="log_admin"))
            active_and_history.extend(history_alarms)
            self.logger.debug("Alarm history (from admin interface): \n{}".format(
                self.pretty_alarm_print(active_and_history)))
            print("Alarm history (from admin interface): \n{}".format(self.pretty_alarm_print(active_and_history)))
            active_in_admin = self.parse_alarm_info_from_admin(self.admin.get_active_alarms(connection="log_admin",
                                                                                            timeout=60))
            self.logger.debug("Active alarms seen in admin: {}".format(active_in_admin))
            print("Active alarms seen in admin: {}".format(active_in_admin))
        except (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                AdminApiTerminatedException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasInUse, AliasLookupError) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to get alarm history and active alarms from admin: {admin_error.__class__.__name__}:"
                  f"{admin_error} was raised\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    error("Unable to get alarm history and active alarms from admin, because of session invalidation."
                          "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection()
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method _get_history_and_active_alarms_from_admin again after admin connection reset.")
                    self._get_history_and_active_alarms_from_admin(retry=1)
                elif retry == 1:
                    error("Unable to get alarm history and active alarms from admin, because of session invalidation."
                          "Admin restart did not help.")
            # Alarm checks are mainly done via realtime alarms so this exception will not fail the test
            # raise BTSConnectionFailure("Unable to get active alarms from admin")
        return active_and_history, history_alarms

    def check_alarm_history(self, reset_alarms=False, test_step_txt=""):
        """
        Checks that the alarm history and active alarms includes expected alarms which may also include allowed alarms.
        NOTE if error is printed the fields in alarm are:
        severity - alarm_id - fault_name (fault_id) - unit_path - reason - hw_path - impacted_cells_list -
        impacted_cell - degraded_cells - faulty_cells - cells_cli_info

        NOTE if fault_id in expected_alarm is given with ' / ' then the first fault_id that is found from the alarms is
        set as expected and if the other one is also found from alarms, it is set as unallowed.

        :param boolean reset_alarms: (Optional) Set to False if not given. If True, removes all expected alarms from the
                                      allowed alarms list and clears the list of expected alarms completely.
        :param str test_step_txt: Default is empty, can have some text.
        :raise ExpectedAlarmNotFound: If the expected alarm does not appear.
        :raise UnallowedAlarmFound: If unallowed alarms are found.
        """
        # CNI-127210
        self._remove_suppressfaults_from_expected_and_allowed_alarms()
        active_and_history, history_alarms = self._get_history_and_active_alarms_from_admin()
        self.logger.debug("Active alarms seen in rt alarms: {}".format(self.rt_alarms.active_alarms_during_test))
        active_rt_alarms = sum(list(self.rt_alarms.active_alarms_during_test.values()), [])
        active_and_history.extend(active_rt_alarms)
        print("Alarms in realtime alarms interface: \n{}".format(
            self.pretty_alarm_print(self.rt_alarms.active_alarms_during_test)))
        extra_info = BuiltIn().get_variable_value("${EXTRA_INFO_FOR_LOOP}", default="")
        extra_info = extra_info.replace("_", " ")
        info(f"Check alarm history{extra_info}.")
        test_step_txt = test_step_txt + extra_info
        self.logger.debug("Active alarms and alarm history list: {}".format(active_and_history))
        self.logger.debug("Expected alarms in check_alarm_history: {}".format(CheckAlarms.expected_alarms))
        self.logger.debug("Allowed alarms in check_alarm_history: {}".format(CheckAlarms.allowed_alarms))
        print("Expected alarms in check_alarm_history: \n{}".format(
            self.pretty_alarm_print(CheckAlarms.expected_alarms)))
        print("Allowed alarms in check_alarm_history: \n{}".format(self.pretty_alarm_print(CheckAlarms.allowed_alarms)))
        self.logger.debug("Expected alarms, pretty print: \n{}".format(
            self.pretty_alarm_print(CheckAlarms.expected_alarms)))
        self.logger.debug("Allowed alarms, pretty print: \n{}".format(
            self.pretty_alarm_print(CheckAlarms.allowed_alarms)))
        if active_and_history:
            active_and_history = self._combine_alarms(history_alarms, active_rt_alarms)
            if not self.check_if_unallowed_alarms(active_and_history, test_step_txt):
                if reset_alarms:
                    self.reset_alarms()
                if ("${OMKPI_CASE}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${OMKPI_CASE}")):
                    info("OMKPI test. Unallowed alarms found. Do not calculate KPIs (set CALCULATE_KPI to False).")
                    BuiltIn().set_suite_variable("${CALCULATE_KPI}", "${False}")
                info("Alarm history check DONE.")
                raise UnallowedAlarmFound()
        if active_and_history and CheckAlarms.expected_alarms:
            missing_expected_alarms = []
            for expected_alarm in CheckAlarms.expected_alarms:
                all_expected_alarms = []
                CheckAlarms.optional_fault_found = False
                for alarm in active_and_history:
                    # all_expected_alarms.append(self.compare_alarms(alarm, expected_alarm))
                    info_text = (f"Optional expected fault_id '{expected_alarm.fault_id}' was found from alarms, but "
                                 f"because the another fault_id was found earlier from alarms this alarm is set as not"
                                 f" allowed.\nCheck from logs which fault_id was found first and which fault_id should"
                                 f" not be seen.")
                    all_expected_alarms.append(self._compare_alarms_and_check_if_found_earlier(alarm, expected_alarm,
                                                                                               info_text))
                if True not in all_expected_alarms:
                    missing_expected_alarms.append(expected_alarm)
            if not missing_expected_alarms:  # found_alarms and len(found_alarms) == len(CheckAlarms.expected_alarms):
                info("Expected alarms were found from alarm history, OK")
            else:
                error("{}Expected alarms '{}' were not found from the alarm history, NOK".format(
                    extra_info, self.pretty_alarm_print(missing_expected_alarms)))
                if reset_alarms:
                    self.reset_alarms()
                raise ExpectedAlarmNotFound()
        if reset_alarms:
            self.reset_alarms()
        info("Alarm history check DONE.")

    @staticmethod
    def _check_if_expected_alarm_field(alarm_field, found_alarm, alarm_field_values):
        was_found = False
        for expected_option in alarm_field_values:
            if expected_option and found_alarm[alarm_field] and expected_option in found_alarm[alarm_field]:
                was_found = True
                break
        return was_found

    def compare_alarms(self, alarm, user_defined_alarm):
        """
        Compares fields of user defined alarm, expected or allowed alarm to found alarm.

        :param namedtuple alarm: Found alarm.
        :param namedtuple user_defined_alarm: User defined alarm, may be expected alarm or allowed alarm.
        :return bool: Return True if all not None fields are identical.
        """
        # noinspection PyProtectedMember
        field_dict = user_defined_alarm._asdict()
        # noinspection PyProtectedMember
        found_alarm = alarm._asdict()
        not_none_fields = []
        if len(set(field_dict.values())) == 1 and None in set(field_dict.values()):
            error("User has defined alarm {} that's all fields have value None. At least one field should "
                  "have other that None value. NOK.".format(user_defined_alarm))
            return False
        for alarm_field, alarm_field_value in field_dict.items():
            if alarm_field_value is not None:  # check only fields that are not None
                if " / " in alarm_field_value:  # if field has multiple values
                    # info("!!!! DEBUG: Alarm field {} has multiple values {}".format(alarm_field, alarm_field_value))
                    alarm_field_values = self._safe_split(alarm_field_value, " / ")
                    if alarm_field == "reason":
                        not_none_fields.append(CheckAlarms._check_if_expected_alarm_field(
                            alarm_field, found_alarm, alarm_field_values))
                    else:
                        if found_alarm[alarm_field] in alarm_field_values:
                            # info("!!!! DEBUG: Active alarm field {} was found from user given alarm {}".format(
                            #     found_alarm[alarm_field], alarm_field_value))
                            not_none_fields.append(True)
                        else:
                            # info("!!!! DEBUG: Active alarm field {} was NOT found from user given alarm {}".format(
                            #     found_alarm[alarm_field], alarm_field_value))
                            not_none_fields.append(False)
                elif alarm_field_value == found_alarm[alarm_field]:
                    not_none_fields.append(True)
                elif (alarm_field == "reason" and found_alarm[alarm_field] and
                      alarm_field_value in found_alarm[alarm_field]):
                    not_none_fields.append(True)
                else:
                    not_none_fields.append(False)
        if True in not_none_fields and len(set(not_none_fields)) == 1:
            # self.logger.debug("Alarms {} and {} are equal".format(alarm, user_defined_alarm))
            return True
        else:
            # self.logger.debug("Alarms {} and {} are not equal".format(alarm, user_defined_alarm))
            return False

    def _compare_alarms_and_check_if_found_earlier(self, found_alarm, user_given_alarm, info_text=""):
        """
        Compares user given alarm to expected and allowed alarms and checks if the alarm is found earlier from alarms.

        :param namedtuple user_given_alarm: User given alarm.
        :param namedtuple found_alarm: Found alarm.
        :param str info_text: (Optional) set to empty if not given. Information text to be printed if alarm is found.
        :return bool: Returns True if the user given alarm is found from alarms, otherwise returns False.
        """
        compared_result = self.compare_alarms(found_alarm, user_given_alarm)
        if user_given_alarm.fault_id and " / " in user_given_alarm.fault_id:
            if not CheckAlarms.optional_fault_found:
                if compared_result:
                    CheckAlarms.optional_fault_found = True
                    return True
                else:
                    return False
            else:
                if compared_result:
                    info(info_text)
                return False
        else:
            return compared_result

    @staticmethod
    def _combine_alarms(history_alarms, active_alarms):
        """
        Combines alarms from active and history data.

        :param list history_alarms: List of history alarms.
        :param list active_alarms: List of active alarms.
        :return list: Returns combined list of alarms.
        """
        combined_alarms = []
        for alarm in history_alarms:
            combined_alarms.append(alarm)
        for alarm in active_alarms:
            if alarm not in combined_alarms:
                combined_alarms.append(alarm)
        return combined_alarms

    def _remove_suppressfaults_from_expected_and_allowed_alarms(self):
        """
        To get the test to fail if some suppressed alarm is coming through remove those from expected and allowed
        alarms.
        """
        # CNI-127210
        expected_alarms_to_remove = []
        allowed_alarms_to_remove = []
        if CheckAlarms.suppressed_faults:
            self.logger.debug("Check if there are some expected alarms that should be suppressed.")
            for expected_alarm in CheckAlarms.expected_alarms:
                if (expected_alarm.alarm_id in ("7115", "7102") and
                        expected_alarm.fault_id in CheckAlarms.suppressed_faults):
                    info(f"Expected alarm with alarm_id {expected_alarm.alarm_id} and fault_id "
                         f"{expected_alarm.fault_id} is in suppressed faults list and it should never be seen in "
                         f"WebEM because of CNI-127210.")
                    expected_alarms_to_remove.append(expected_alarm)
            for alarm in expected_alarms_to_remove:
                info(f"Remove ({self.pretty_alarm_print(alarm)}) from expected alarms.")
                CheckAlarms.expected_alarms.remove(alarm)
            self.logger.debug("Check if there are some allowed alarms that should be suppressed.")
            for allowed_alarm in CheckAlarms.allowed_alarms:
                if (allowed_alarm.alarm_id in ("7115", "7102") and
                        allowed_alarm.fault_id in CheckAlarms.suppressed_faults):
                    info(f"Allowed alarm with alarm_id {allowed_alarm.alarm_id} and fault_id "
                         f"{allowed_alarm.fault_id} is in suppressed faults list and it should never be seen in "
                         f"WebEM because of CNI-127210.")
                    allowed_alarms_to_remove.append(allowed_alarm)
            for alarm in allowed_alarms_to_remove:
                info(f"Remove alarm {self.pretty_alarm_print(alarm)} from allowed alarms.")
                CheckAlarms.allowed_alarms.remove(alarm)
        else:
            self.logger.debug("No need for changes in expected and allowed alarms, CNI-127210 is not activated.")

    def check_if_unallowed_alarms(self, active_and_history, test_step_txt=""):
        """
        Checks if found alarms are expected, allowed or unallowed.

        NOTE if fault_id is given with ' / ' then the first fault_id that is found from the alarms is set as expected/
        allowed and if the other one is also found from alarms, it is set as unallowed.

        :param list active_and_history: List of alarms, may be for example active and historical alarms.
        :param str test_step_txt: Default is empty, can have some text.
        :return bool: Returns True if no unallowed alarms found else False
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        faulty_loki_alarms = []
        # CNI-127210
        self._remove_suppressfaults_from_expected_and_allowed_alarms()
        all_variables = BuiltIn().get_variables()
        if BuiltIn().get_variable_value("${BREAK_LOKI}"):
            faulty_loki_alarms = BuiltIn().get_variable_value("${F_LOKI_ALARMS}")
            self.logger.debug(
                f"check_if_unallowed_alarms F_LOKI_ALARMS:\n{self.pretty_alarm_print(faulty_loki_alarms)}")
            print(f"check_if_unallowed_alarms F_LOKI_ALARMS:\n{self.pretty_alarm_print(faulty_loki_alarms)}")
        if BuiltIn().get_variable_value("${BBMODS_MASK}"):
            faulty_loki_alarms = BuiltIn().get_variable_value("${FAULTY_BBMODS_ALARMS}")
            self.logger.debug(
                f"check_if_unallowed_alarms FAULTY_BBMODS_ALARMS:\n{self.pretty_alarm_print(faulty_loki_alarms)}")
            print(f"check_if_unallowed_alarms FAULTY_BBMODS_ALARMS:\n{self.pretty_alarm_print(faulty_loki_alarms)}")
            if faulty_loki_alarms is None:
                error("BBMODS_MASK variable was given, but no allowed alarm has been able to be created to "
                      "FAULTY_BBMODS_ALARMS")
        if active_and_history:
            unallowed_alarms = []
            if isinstance(active_and_history, dict):
                all_alarms = list(active_and_history.values())
                active_and_history = sum(all_alarms, [])  # flatten the list
            for alarm in active_and_history:
                all_expected_alarms = []
                all_allowed_alarms = []
                CheckAlarms.optional_fault_found = False
                for expected_alarm in CheckAlarms.expected_alarms:
                    info_text = (f"Optional expected fault_id '{expected_alarm.fault_id}' was found from alarms, but "
                                 f"because the another fault_id was found earlier from alarms this alarm is set as not"
                                 f" allowed.\nCheck from logs which fault_id was found first and which fault_id should"
                                 f" not be seen.")
                    all_expected_alarms.append(self._compare_alarms_and_check_if_found_earlier(alarm, expected_alarm,
                                                                                               info_text))
                CheckAlarms.optional_fault_found = False  # reset this variable for unallowed checks
                for allowed_alarm in CheckAlarms.allowed_alarms:
                    info_text = (f"Optional allowed fault_id '{allowed_alarm.fault_id}' was found from alarms, but "
                                 f"because the another fault_id was found earlier from alarms this alarm is set as not"
                                 f" allowed.\nCheck from logs which fault_id was found first and which fault_id should"
                                 f" not be seen.")
                    all_allowed_alarms.append(self._compare_alarms_and_check_if_found_earlier(alarm, allowed_alarm,
                                                                                              info_text))
                if (((CheckAlarms.expected_alarms and True not in all_expected_alarms) and
                     (CheckAlarms.allowed_alarms and True not in all_allowed_alarms)) or
                        ((not CheckAlarms.expected_alarms and
                          (CheckAlarms.allowed_alarms and True not in all_allowed_alarms)))):
                    if faulty_loki_alarms:
                        all_faulty_lokis = []
                        for f_loki_alarm in faulty_loki_alarms:
                            all_faulty_lokis.append(self.compare_alarms(alarm, f_loki_alarm))
                        if True not in all_faulty_lokis:
                            unallowed_alarms.append(alarm)
                    else:
                        unallowed_alarms.append(alarm)
            if unallowed_alarms:
                if self.truck_roll:
                    from testsuite.Oulu.TrunkEng.Common.Python.Resources.TruckRoll import TruckRoll
                    TruckRoll().check_truck_roll_alarms(unallowed_alarms, CheckAlarms.expected_alarms)
                test_step_txt = " " + test_step_txt if test_step_txt else ""
                error(f"Unallowed alarms{test_step_txt}: \n{self.pretty_alarm_print(unallowed_alarms, loop_text=True)}")
                collect_dumps = self._unallowed_6450_fault_is_active(unallowed_alarms)
                if collect_dumps:
                    self.bts.check_failed_component_and_get_dumps()
                return False
            else:
                info("Unallowed alarms not found, OK")
                return True
        else:
            info("No alarms at all. Unallowed alarms not found, OK")
            return True

    def parse_alarm_info_from_admin(self, alarms):
        """
        Parse needed alarm information from admin output.

        :alarms list: Alarm information object list from admin.
        :return list parsed_alarms: A list of Alarm named tuples.
        """
        parsed_alarms = []
        if alarms:
            for alarm in alarms:
                a_id, f_id, f_name, hw_path, sev, reason, u_path, i_c_list, i_c, degraded_c, faulty_c, c_cli_i, d_t = \
                    self.rt_alarms.parse_active_alarm(alarm)
                parsed_alarms.append(self.create_alarm(
                    a_id, f_id, f_name, hw_path, sev, reason, u_path, i_c_list, i_c, degraded_c, faulty_c, c_cli_i))
        return parsed_alarms

    def check_active_alarms(self, connection="log_admin", test_step_txt=""):
        """
        Check active alarms. Ignores expected and allowed alarms. NOTE if error is printed the fields in alarm are:
        severity - alarm_id - fault_name (fault_id) - unit_path - reason - hw_path - impacted_cells_list -
        impacted_cell - degraded_cells - faulty_cells - cells_cli_info

        :param str connection: (Optional) Set to log_admin if not given. Alias for connection to admin.
        :param str test_step_txt: Default is empty, can have some text.

        :raise UnallowedAlarmFound: If unallowed alarms are found
        """
        # CNI-127210
        self._remove_suppressfaults_from_expected_and_allowed_alarms()
        extra_info = BuiltIn().get_variable_value("${EXTRA_INFO_FOR_LOOP}", default="")
        extra_info = extra_info.replace("_", " ")
        info(f"Checking active alarms{extra_info}")
        BuiltIn().sleep("1s")
        active_alarms = self._get_active_alarms_from_admin(admin_connection=connection)
        self.logger.debug("Active alarms: {}".format(active_alarms))
        parsed_active = self.parse_alarm_info_from_admin(active_alarms)
        self.logger.debug("Parsed active alarms: {}".format(parsed_active))
        self.logger.debug("Expected alarms: {}".format(CheckAlarms.expected_alarms))
        self.logger.debug("Allowed alarms: {}".format(CheckAlarms.allowed_alarms))
        print("Expected alarms: \n{}".format(self.pretty_alarm_print(CheckAlarms.expected_alarms)))
        print("Allowed alarms: \n{}".format(self.pretty_alarm_print(CheckAlarms.allowed_alarms)))
        if parsed_active:
            print("Active alarms (in admin interface): \n{}".format(self.pretty_alarm_print(parsed_active)))
            test_step_txt = test_step_txt + extra_info
            no_unallowed = self.check_if_unallowed_alarms(parsed_active, test_step_txt)
            if not no_unallowed:
                info("Active alarms check completed")
                if "${OMKPI_CASE}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${OMKPI_CASE}"):
                    info("OMKPI test. Unallowed alarms found. Do not calculate KPIs (set CALCULATE_KPI to "
                         "False).")
                    BuiltIn().set_suite_variable("${CALCULATE_KPI}", "${False}")
                raise UnallowedAlarmFound()
        else:
            info("No active alarms.")
        info("Active alarms check completed")

    def wait_for_active_alarms(self, timeout="10", get_active_alarms=False):
        """
        Wait for expected alarms.

        :param str timeout: Timeout time for expected alarms in seconds
        :param bool get_active_alarms: (Optional) Set to False if not given. If True, gets active alarms from admin.
        :raise ExpectedAlarmNotFound: If expected alarms are not found during timeout time
        """
        alarms_not_activated = []
        # CNI-127210
        self._remove_suppressfaults_from_expected_and_allowed_alarms()
        if CheckAlarms.expected_alarms:
            info("Wait for expected alarms ({}) max {}s".format(
                self.pretty_alarm_print(CheckAlarms.expected_alarms), timeout))
            alarms_active = self.wait_for_active_alarm(timeout, get_active_alarms)
            if not alarms_active:
                raise ExpectedAlarmNotFound("Expected alarm(s) is/are inactive after timeout ({}s): {}, NOK.".format(
                    timeout, self.pretty_alarm_print(alarms_not_activated)))
            else:
                info("All expected alarms were found as active, OK.")
        else:
            info("There aren't any expected alarm to wait for.")

    @staticmethod
    def create_alarm(alarm_id=None, fault_id=None, fault_name=None, hw_path=None, severity=None, reason=None,
                     unit_path=None, impacted_cells_list=None, impacted_cell=None, degraded_cells=None,
                     faulty_cells=None, cells_cli_info=None):
        """
        Creates named alarm tuple.

        :param str alarm_id: Default value None, meaning not checked. Can be f.ex. 7116
        :param str fault_id: Default value None, meaning not checked. Can be f.ex. 10
        :param str fault_name: Default value None, meaning not checked. Can be f.ex. No connection to unit
        :param str hw_path: Default value None, meaning not checked. Can be f.ex.
                            /SMOD_R-1(Right)/BBMOD_R-1(Right_Bottom)/rf1/RMOD_R-1
        :param str severity: Default value None, meaning not checked. Can be f.ex. Critical
        :param str reason: Default value None, meaning not checked. Can be f.ex. Reset request
        :param str unit_path: Default value None, meaning not checked. Can be f.ex.
                              [2_11_CLOUD418] MRBTS-22234/EQM-1/APEQM-1/RMOD-1
        :param list/str impacted_cells_list: Default value None, meaning not checked. Can be f.ex.
                                             ["/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-22260/LNCEL_R-1"]
        :param str impacted_cell: Default value None, meaning not checked. Can be f.ex.
                                  [2_11_CLOUD561] /MRBTS-22282/LNBTS-22282/LNCEL-1
        :param str degraded_cells: Default value None, meaning not checked. Can be f.ex. "Faulty: All"
        :param str/list faulty_cells: (Optional) set to None if not given. Can be f.ex. ['22255/2']
        :param list cells_cli_info: (Optional) set to None if not given. Used during comparison with cells cli info
                                    Can be f.ex. "LTE": "All Failed"
        :return tuple: Returns named Alarm tuple.
        """
        if alarm_id is not None:
            alarm_id = str(alarm_id)
        if fault_id is not None:
            fault_id = str(fault_id)
        if impacted_cells_list is not None:
            if isinstance(impacted_cells_list, str) and "[" not in impacted_cells_list:
                impacted_cells_list = str([impacted_cells_list])
            elif isinstance(impacted_cells_list, list):
                impacted_cells_list = str(sorted(impacted_cells_list))
        if faulty_cells is not None:
            if isinstance(faulty_cells, str) and "[" not in faulty_cells:
                faulty_cells = str([faulty_cells])
            elif isinstance(faulty_cells, list):
                faulty_cells = str(sorted(faulty_cells))
        return Alarm(alarm_id, fault_id, fault_name, hw_path, severity, reason, unit_path, impacted_cells_list,
                     impacted_cell, degraded_cells, faulty_cells, cells_cli_info)

    def check_if_fault_1815_should_be_allowed(self, rmod_name, cells_of_rmod, hw_path):
        """
        Checks if fault 1815 could be added as an allowed alarm. Fault 1815 is allowed if Nokia nahka radio in question
        and if the RMOD has some cells.

        :param str rmod_name: Name of radio for example ARGA(1.1.1.1)
        :param list cells_of_rmod: Cells of the RMOD for example [LNCell-1]
        :param str hw_path: Hw_path of the RMOD for example /SMOD_R-1(Right)/BBMOD_R-1(Right_Bottom)/rf1/RMOD_R-1
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if cells_of_rmod:
            if self.bts.nokia_nahka_rmod(rmod_name):
                info("Alarming of 1815 fault may happen, add it as an allowed alarm.")
                self.add_1815_fault_as_allowed(hw_path)
            else:
                self.logger.debug("Alarming of 1815 fault should not be seen on {}".format(rmod_name))
        else:
            self.logger.debug("No cells on {}, alarming of 1815 fault should not be seen.".format(rmod_name))

    def add_1815_fault_as_allowed(self, hw_path):
        """
        This method adds 1815 alarm as allowed alarm and parses hw_path to the form that is seen in alarm.

        :param str hw_path: Hw_path of the RMOD for example /SMOD_R-1(Right)/BBMOD_R-1(Right_Bottom)/rf1/RMOD_R-1

        NOTE that unit_path when alarming of 1815 fault is CABLNK and hw_path is missing the last RMOD_L part f.ex.:
        Major - 7116 - Not able to synchronize baseband bus (1815) - [2_11_CLOUD436] MRBTS-23261/EQM-1/HWTOP-1/CABLINK-2
        - The CPRI synchronization is lost on cable between system module/extension baseband module/fronthaul switch
        module and radio module. - /SMOD_R-1(Right)/BBMOD_R-1(Right_Bottom)/rf1 -
        ['/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-23261/LNCEL_R-2',
        '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-23261/LNCEL_R-1'] - degradedCells:Degraded: All
        """
        if "BBMOD" not in hw_path:
            pattern = r"(/SMOD_R-\d+/rf\d+)"
            hw_paths = re.findall(pattern, hw_path)
            for parsed_hw_path in hw_paths:
                self.add_allowed_alarm(fault_id="1815", fault_name="Baseband bus failure", hw_path=parsed_hw_path)
        else:
            if " / " in hw_path:
                info("Radio is connected with more than one fiber")
                hwp_list = self._safe_split(hw_path, " / ")
                hwpl = []
                for hwp in hwp_list:
                    hwpl.append(hwp[:hwp.rfind('/')])
                self.logger.debug(hwpl)
                parsed_hw_path = ''.join([f'{item} / ' for item in hwpl[:-1]] + [hwpl[-1]])
            else:
                parsed_hw_path = hw_path[:hw_path.rfind('/')]
            if "fh" in hw_path:
                info("HW path includes fh --> FHS environment, ignore hw_path in alarm check.")
                parsed_hw_path = None
            self.add_allowed_alarm(fault_id="1815", fault_name="Baseband bus failure", hw_path=parsed_hw_path)

    def check_if_fault_4590_should_be_allowed(self, should_be_expected=False):
        """
        Checks from commissioning if fault 4590 should be allowed (or expected if should_be_expected is set to True).
        Adds fault 4590 to allowed alarms/expected alarms if <p name="actFaultSignature">true</p>. NOTE true is default
        value in commissioning. Parameter is optional so if it has default value then it may not be seen in scf.xml

        :param bool should_be_expected: Default is value is False and fault 4590 is added to allowed. If set to True
                                        adds fault 4590 to expected alarms.
        """
        fse = self._check_if_fault_signature_enabled()
        if not fse:
            info("Fault signature is not enabled -> Fault 4590 should not be seen")
        elif fse and not should_be_expected:
            info("Fault signature is enabled -> Add 4590 to allowed alarms.")
            self.add_allowed_alarm(alarm_id="7652", fault_id="4590", fault_name="Fault signature for crash or failure")
        elif fse and should_be_expected:
            info("Fault signature is enabled -> Add 4590 to expected alarms.")
            self.add_expected_alarm(alarm_id="7652", fault_id="4590", fault_name="Fault signature for crash or failure")

    def check_if_fault_61675_should_be_allowed(self):
        """
        Check if SMOD in use is ASOG or ASOH and if fault 61675 should be added to allowed alarms.

        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")

        # Check if fault 61675 is already in allowed alarms and if it is, do not add it again
        for alarm in CheckAlarms.allowed_alarms:
            if alarm.fault_id == "61675":
                self.logger.debug("Fault 61675 is already in allowed alarms.")
                info("Fault 61675 is already in allowed alarms.")
                return

        for smod in self.bts.smods:
            if smod.name in ["ASOG1", "ASOH1", "ASOG2", "ASOH2"]:
                info("SMOD is ASOG or ASOH -> Add 61675 to allowed alarms.")
                self.add_allowed_alarm(fault_id="61675", fault_name="WiFi Configuration Issue")
                return

        info(f"SMOD is not ASOG or ASOH, fault 61675 should not be allowed.")

    def check_if_fault_4589_should_be_allowed(self, should_be_expected=False):
        """
        Checks from commissioning if fault 4589 should be allowed (or expected if should_be_expected is set to True).
        Adds fault 4589 to allowed alarms/expected alarms if <p name="actFaultSignature">true</p>.

        :param bool should_be_expected: Default is value is False and fault 4589 is added to allowed. If set to True
                                        adds fault 4589 to expected alarms.
        """
        fse = self._check_if_fault_signature_enabled()
        if not fse:
            info("Fault signature is not enabled -> Fault 4589 should not be seen")
        elif fse and not should_be_expected:
            info("Fault signature is enabled -> Add 4589 to allowed alarms.")
            self.add_allowed_alarm(alarm_id="7652", fault_id="4589", fault_name="Unit power reset")
        elif fse and should_be_expected:
            info("Fault signature is enabled -> Add 4589 to expected alarms")
            self.add_expected_alarm(alarm_id="7652", fault_id="4590", fault_name="Fault signature for crash or failure")

    def check_if_fault_4003_should_be_allowed(self, name_of_radio="", should_be_expected=False, lte441a_active=None):
        """
        Check if fault 4003 should be added to allowed. During RMOD hot remove: 4003 is added to allowed alarms if cell
        resources are reserved from two different RMODs. During RMOD hot remove or RMOD TX fault: if cell has more than
        one TX (and just some are faulted), txPathFailureMode = keepCellInService, Mimo mode for cell != SingleTX and
        Sync sign transmission mode for cell = TxDiv.

        :param str name_of_radio: Name of radio that's cells are affected or if not given then it is assumed that not
                                  hot remove insert test in question.
        :param bool should_be_expected: Default is value is False and fault 4003 is added to allowed. If set to True
                                        adds fault 4003 to expected alarms.
        :param bool lte441a_active: Default value is None if not given. If lte441a_active is None it is checked in this
                                    method if lte441a should be allowed or not.
        """
        if lte441a_active is None:
            if not name_of_radio:
                lte441a_active = self.bts.check_if_lte441a_feature_is_active()
            else:
                lte441a_active = self.bts.check_if_lte441a_feature_is_active(name_of_radio)
        if lte441a_active:
            if not should_be_expected:
                info("Feature LTE441-a is active -> Add 4003 to allowed alarms.")
                self.add_allowed_alarm(alarm_id="7655", fault_id="4003", fault_name="Transmission path failure")
            elif should_be_expected:
                info("Feature LTE441-a is active -> Add 4003 to expected alarms.")
                self.add_expected_alarm(alarm_id="7655", fault_id="4003", fault_name="Transmission path failure")
        else:
            info("Feature LTE441-a is not active -> 4003 is not added to allowed alarm.")

    def check_if_fault_1972_should_be_allowed(self, rmod_obj):
        """
        Check if fault 1972 should be allowed. The fault should be allowed for (e)CPRI radios.
        The fault should also be cancelled after fault 10.

        """
        if rmod_obj.cablink_type != "RP3_01Link":
            info(f"Based on cablink type {rmod_obj.cablink_type} fault 1972 should be allowed, adding as allowed alarm")
            self.add_allowed_alarm(alarm_id="7115", fault_id="1972", fault_name="RRU power loss")
        else:
            info(f"NOT adding fault 1972 as allowed because radio is not (e)CPRI. "
                 f"(cablink type is: {rmod_obj.cablink_type})")

    def add_10_fault_as_expected_to_radios(self, radios_of_bbmod, cells_of_radio=None,
                                           get_and_add_to_chain_radios=False, lte441a_active=False,
                                           suppl_alarm_info=None, add_just_to_allowed=False):
        """
        Adds 10 fault as expected alarm for all given radios.

        :param list/str radios_of_bbmod: List of radios for example ['FXEB(1.1.1.1)', 'ARGA(1.1.4.1)'] or
                                         string 'ARGA(1.1.4.1)'
        :param bool get_and_add_to_chain_radios: Default False. If set to True checks if radio has some radios in chain
                                                 and adds 10 faults also to them.
        :param list cells_of_radio: List of cells on radio, if None then cells will be searched in this method.
        :param bool lte441a_active: Default value is False.
        :param str suppl_alarm_info: Default value is None. If given adds this information to the expected alarm.
        :param bool add_just_to_allowed: Default value is False. If set to True adds 10 fault just to allowed alarms.
        """
        all_lte_cells_affected = False
        all_nr_cells_affected = False
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if radios_of_bbmod:
            # added that if radio is given as string adds it to list so if in test one radio selected no need to add it
            # to list in robot framework
            if isinstance(radios_of_bbmod, str):
                radios_of_bbmod = [radios_of_bbmod]
            all_lte_cells = self.cells.get_cells_rmods_or_both_of_rat("LTE", cell_rmod_or_both="cells")
            all_nr_cells = self.cells.get_cells_rmods_or_both_of_rat("NR", cell_rmod_or_both="cells")
            for name_of_radio in radios_of_bbmod:
                for rmod in self.bts.radios:
                    if rmod.name == name_of_radio:
                        self.logger.debug(f"radios_of_bbmod {name_of_radio}, cells_of_radio={cells_of_radio}")
                        if cells_of_radio is None:
                            cells_of_radio = self.bts.get_cells_of_radio(name_of_radio)
                        if all_lte_cells and all(lte_cell in cells_of_radio for lte_cell in all_lte_cells):
                            info(f"All LTE cells are affected ({all_lte_cells}).")
                            all_lte_cells_affected = True
                        if all_nr_cells and all(nr_cell in cells_of_radio for nr_cell in all_nr_cells):
                            info(f"All NR cells are affected ({all_nr_cells}).")
                            all_nr_cells_affected = True
                        self.logger.debug(f"radios_of_bbmod {name_of_radio}, cells_of_radio={cells_of_radio}")
                        if not cells_of_radio:
                            info("No cells on {} -> severity set to 7652 (legacy)".format(name_of_radio))
                            if add_just_to_allowed:
                                self.add_allowed_alarm(
                                    alarm_id="7652", fault_id="10", fault_name="Failure in optical interface",
                                    unit_path=rmod.unit_path, hw_path=rmod.hw_path)
                            else:
                                self.add_expected_alarm(
                                    alarm_id="7652", fault_id="10", fault_name="Failure in optical interface",
                                    unit_path=rmod.unit_path, hw_path=rmod.hw_path)
                        else:
                            alarm_info_list = ["7653", "10", "Failure in optical interface", "Critical", rmod.unit_path,
                                               rmod.hw_path]
                            if lte441a_active:
                                alarm_info_list = ["7654", "10", "Failure in optical interface", "Major",
                                                   rmod.unit_path, rmod.hw_path]
                            if suppl_alarm_info:
                                alarm_info_list.append(suppl_alarm_info)
                            self.select_alarming_cells_according_to_commissioning(
                                cells_of_radio, alarm_info_list, lte441a_active, add_just_to_allowed,
                                all_lte_cells_affected=all_lte_cells_affected,
                                all_nr_cells_affected=all_nr_cells_affected)
                        if get_and_add_to_chain_radios:
                            chain_rmod_objects = self.bts.get_chained_rmods(name_of_radio, print_to_eventlog=False)
                            if chain_rmod_objects:
                                for chain_rmod in chain_rmod_objects:
                                    cells_of_chain_radio = self.bts.get_cells_of_radio(chain_rmod.name)
                                    if cells_of_chain_radio:
                                        alarm_info_list = ["7653", "10", "Failure in optical interface", "Critical",
                                                           chain_rmod.unit_path, chain_rmod.hw_path]
                                        if lte441a_active:
                                            alarm_info_list = ["7654", "10", "Failure in optical interface", "Major",
                                                               rmod.unit_path, rmod.hw_path]
                                        self.select_alarming_cells_according_to_commissioning(
                                            cells_of_chain_radio, alarm_info_list, lte441a_active, add_just_to_allowed)
                                    else:
                                        info("No cells on {} that is in chain -> severity set to 7651 (legacy)".format(
                                            name_of_radio))
                                        if add_just_to_allowed:
                                            self.add_allowed_alarm(
                                                alarm_id="7651", fault_id="10",
                                                fault_name="Failure in optical interface",
                                                unit_path=chain_rmod.unit_path, hw_path=chain_rmod.hw_path)
                                        else:
                                            self.add_expected_alarm(
                                                alarm_id="7651", fault_id="10",
                                                fault_name="Failure in optical interface",
                                                unit_path=chain_rmod.unit_path, hw_path=chain_rmod.hw_path)
                        # Clear cells of radio in for loop when expected alarm has been added
                        cells_of_radio = None
                        break  # break from inner for when radio found -> faster to go through all radios
        else:
            self.logger.debug("No radios found -> no 10 alarms expected")

    def select_alarm_id_by_resources_and_add_fault_to_expected_alarm(self, resource, radio, fault_id, fault_name,
                                                                     lte441a_active=None, last_resource_faulted=False,
                                                                     print_to_eventlog=True, list_of_cells=None,
                                                                     cells_degraded_faulty=""):
        """
        Select alarm id and cells by resources and commissioning and add fault to expected_alarms list.

        :param str resource: Can have value LTX or TX1, TX2,... TX8 or RX1, RX2,... RX8
        :param object radio: Radio object.
        :param str fault_id: Fault id, for example 1907
        :param str fault_name: Fault name for example RF Module failure
        :param bool lte441a_active: Default value is None
        :param bool last_resource_faulted: Default value is False, if True alarm_id is 7653 even thought lte441a is
                                           active.
        :param bool print_to_eventlog: If True prints to eventlog, if False prints just to debugger log.
        :param list list_of_cells: This is needed because cells in category alarms are in one alarm so if multiple
                                   faulted antennas from the same radio information of other antennas is needed.
        :param str cells_degraded_faulty: OPTIONAL. Some faults doesn't cause any recovery actions and sets cells to
                                          degraded or faulty. This is used to set cells to degraded or faulty.
        :return str: The alarm_id used
        """
        alarm_id = "7653"
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        alarm_info_list = [alarm_id, fault_id, fault_name, "Critical", radio.unit_path, radio.hw_path]
        if resource == "LTX":
            if lte441a_active is None:
                lte441a_active = self.bts.check_if_lte441a_feature_is_active(radio.name)
            if not list_of_cells:
                cells_of_radio = self.bts.get_cells_of_radio(radio.name, print_to_eventlog=False)
            else:
                cells_of_radio = list_of_cells
            if ((cells_degraded_faulty and cells_degraded_faulty == "degraded") or
                    (lte441a_active and not last_resource_faulted)):
                alarm_id = "7654"
                alarm_info_list = [alarm_id, fault_id, fault_name, "Major", radio.unit_path, radio.hw_path]
                lte441a_active = True
            if (cells_degraded_faulty and cells_degraded_faulty == "faulty") or last_resource_faulted:
                lte441a_active = False
            self.select_alarming_cells_according_to_commissioning(cells_of_radio, alarm_info_list, lte441a_active)
        elif "TX" in resource:
            if lte441a_active is None:
                lte441a_active = self.bts.check_if_lte441a_feature_is_active()
            cells_of_antenna = self.bts.get_cells_of_resource_on_antenna(radio, resource, print_to_eventlog)
            if ((lte441a_active and not last_resource_faulted) or
                    (cells_degraded_faulty and cells_degraded_faulty == "degraded")):
                alarm_id = "7654"
                alarm_info_list = [alarm_id, fault_id, fault_name, "Major", radio.unit_path, radio.hw_path]
            if last_resource_faulted or (cells_degraded_faulty and cells_degraded_faulty == "faulty"):
                lte441a_active = False
            if list_of_cells:
                for cell in list_of_cells:
                    if cell not in cells_of_antenna:
                        cells_of_antenna.append(cell)
            self.select_alarming_cells_according_to_commissioning(cells_of_antenna, alarm_info_list, lte441a_active)
        elif "RX" in resource:
            cells_of_antenna = self.bts.get_cells_of_resource_on_antenna(radio, resource, print_to_eventlog)
            if list_of_cells:
                for cell in list_of_cells:
                    if cell not in cells_of_antenna:
                        cells_of_antenna.append(cell)
            alarm_id = "7653"
            severity = "Critical"
            lte441a_active = False  # this sets cells faulty to alarm
            if (self.cells.check_if_cells_have_at_least_two_rx() or
                    (cells_degraded_faulty and cells_degraded_faulty == "degraded")):
                alarm_id = "7654"
                severity = "Major"
                lte441a_active = True  # this sets cells degraded to alarm
            alarm_info_list = [alarm_id, fault_id, fault_name, severity, radio.unit_path, radio.hw_path]
            if last_resource_faulted or (cells_degraded_faulty and cells_degraded_faulty == "faulty"):
                alarm_id = "7653"
                alarm_info_list = [alarm_id, fault_id, fault_name, "Critical", radio.unit_path, radio.hw_path]
                lte441a_active = False
            self.select_alarming_cells_according_to_commissioning(cells_of_antenna, alarm_info_list, lte441a_active)
        else:
            error("Given resource should be LTX, TX1-TX8 or RX1-RX8, now {} given, NOK.".format(resource))
            raise ScriptIssue
        return alarm_id

    def get_alarm_id_based_on_cell_resources_on_bbmod_and_soc(self, bbmod_name, soc_name, cell_resources=None):
        """
        Get alarm id based on cell resources on BBMOD and SOC.

        :param str bbmod_name: Name of BBMOD for example ABIA1
        :param srt soc_name: Name of SOC for example K2A.
        :param dict cell_resources: (OPTIONAL) Default is None. If None will be get in this method. This is dictionary
                                    that is get when get_cell_resources (in robot 'Get Cell Resources') is called.
        """
        if cell_resources is None:
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            cell_resources = self.bts.get_cell_resources()
        cells_of_soc = []
        cells_of_bbmod = []
        if cell_resources:
            for cell, fsp_and_soc in cell_resources.items():
                for fsp, soc in fsp_and_soc.items():
                    if fsp == bbmod_name:
                        if cell not in cells_of_bbmod:
                            self.logger.debug(f"Cell {cell} is supported by SOCs {soc} of {fsp}")
                            cells_of_bbmod.append(cell)
                    if fsp == bbmod_name and soc_name in soc:
                        self.logger.debug("{} is supported by {} of {}".format(cell, soc_name, fsp))
                        if cell not in cells_of_soc:
                            cells_of_soc.append(cell)
            if not cells_of_soc:
                info(f"No cells on {soc_name} of {bbmod_name} -> alarm id is expected to be 7651")
                return "7651"
            elif cells_of_bbmod.sort() == cells_of_soc.sort():
                info(f"All cells on {bbmod_name} are on {soc_name} -> alarm id is expected to be 7652")
                return "7652"
            elif len(cells_of_bbmod) > len(cells_of_soc):
                info(f"Cells on {bbmod_name} are not all on {soc_name} -> alarm id is expected to be 7653")
                return "7653"
            else:
                error(f"All cells on {bbmod_name} are {cells_of_bbmod}. {soc_name} supports {cells_of_soc}. None of the"
                      f" possibilities given in https://jiradc.ext.net.nokia.com/browse/FCA_TATSCRIPTS-182449 are true "
                      f"here. Check environment and scripts and take contact to script personnel.")
                raise ScriptIssue
        else:
            error(f"No cell resources found for {bbmod_name}/{soc_name}, cannot get alarm id, NOK.")
            raise ScriptIssue("Check if this HW has BBMOD units.")

    def add_expected_made_radio_alarms(self, fault_id, radio_object):
        """
        In made radios given fault is not always the fault that does the recovery to radio thus more checks are needed
        to decide which alarms are expected.

        :param str fault_id: Fault_id for example 1911
        :param object radio_object: Radio object (from BTS.py)
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if str(fault_id) == "1911":
            possible_alarms = {"1911": radio_object.unit_path, "1907": radio_object.unit_path}
            self.check_appeared_alarms_and_add_selected_to_expected_alarms(possible_alarms)
        # antenna_direction_cells = self.bts.get_active_antennas_of_radio_and_cells(radio_object)
        # if any(pipe for pipe in ["ANT5", "ANT6", "ANT7", "ANT8"] if pipe in antenna_direction_cells):
        #     info("There are cell resources also on pipes 5-8 -> 1907 will be the fault that causes recovery reset.")
        #     self.add_expected_alarm(alarm_id="7652", fault_id="1907",
        #                             fault_name="Radio autonomous reset as recovery action",
        #                             unit_path=radio_object.unit_path, hw_path=radio_object.hw_path)
        #     self.add_expected_alarm(fault_id="1911", fault_name="RF module failure",
        #                             unit_path=radio_object.unit_path, hw_path=radio_object.hw_path)
        # else:
        #     info("There are cell resources only on pipes 1-4 -> 1911 will be the fault that causes recovery reset.")
        #     self.add_expected_alarm(alarm_id="7652", fault_id=str(fault_id),
        #                             fault_name="Radio autonomous reset as recovery action",
        #                             unit_path=radio_object.unit_path, hw_path=radio_object.hw_path)
        else:
            possible_alarms = {"1907": radio_object.unit_path}
            self.check_appeared_alarms_and_add_selected_to_expected_alarms(possible_alarms, time_limit=600)
            # self.add_expected_alarm(alarm_id="7652", fault_id=str(fault_id),
            #                         fault_name="Radio autonomous reset as recovery action",
            #                         unit_path=radio_object.unit_path, hw_path=radio_object.hw_path)

    def add_expected_alarm_for_fsp_generated_fault(self, fault_ids, fsp_object):
        """
        Adds expected alarm for FSP generated fault.

        :param list(str) fault_ids: Possible fault IDs as a list, for example ['2087', .
        :param object fsp_object: FSP object (from BTS.py)
        """
        possible_alarms = {}
        for alarm in fault_ids:
            possible_alarms[alarm] = fsp_object.unit_path
        info(f"Wait max 360s for one of the faults in {fault_ids} to appear to FSP "
             f"{fsp_object.name} ({fsp_object.unit_path}).")
        self.check_appeared_alarms_and_add_selected_to_expected_alarms(possible_alarms)

    def check_appeared_alarms_and_add_selected_to_expected_alarms(self, possible_expected_alarms, time_limit=360):
        """
        Checks active alarms from admin and checks if any of the given fault_ids are found from the active alarms. If
        they are found, set them as expected alarms. Waits for alarms, default is 360s.

        :param dict possible_expected_alarms: Dictionary where fault_id is a key and unit_path/hw_path etc. as a value.
        :param int time_limit: Time to max wait for the alarm. Default is 360 seconds.
        """
        start_time = datetime.datetime.now()
        active_alarms = []
        reset_found = False
        info(f"Wait {time_limit}s for alarms and check if some of alarms {possible_expected_alarms} appears")
        while (datetime.datetime.now() - start_time).total_seconds() < int(time_limit):
            for f_id in possible_expected_alarms:
                if self.rt_alarms.active_alarms_during_test:
                    for rt_alarms in list(self.rt_alarms.active_alarms_during_test.values()):
                        for rt_alarm in rt_alarms:
                            if rt_alarm.fault_id == f_id:
                                ea = None
                                if (not reset_found and "Radio autonomous reset as recovery action"
                                        in rt_alarm.fault_name):
                                    info(f"Radio autonomous reset as recovery action found with fault_id {f_id}")
                                    reset_found = True
                                elif not reset_found and (
                                        "Baseband card autonomous reset as recovery action" in rt_alarm.fault_name or
                                        "Baseband card crash has been detected" in rt_alarm.fault_name):
                                    info(f"Baseband card autonomous reset as recovery action found with fault_id "
                                         f"{f_id}")
                                    reset_found = True
                                if rt_alarm.unit_path == possible_expected_alarms[f_id]:
                                    ea = self.create_alarm(fault_id=f_id, fault_name=rt_alarm.fault_name,
                                                           unit_path=possible_expected_alarms[f_id])
                                elif rt_alarm.hw_path == possible_expected_alarms[f_id]:
                                    ea = self.create_alarm(fault_id=f_id, fault_name=rt_alarm.fault_name,
                                                           unit_path=possible_expected_alarms[f_id])
                                if ea:
                                    if ea not in CheckAlarms.expected_alarms:
                                        CheckAlarms.expected_alarms.append(ea)
                                    if ea not in active_alarms:
                                        active_alarms.append(ea)
            # if active_alarms and len(active_alarms) == len(possible_expected_alarms.keys()):
            #     break
            time.sleep(1)
        info("Wait for alarm appearance done.")
        if not reset_found:
            error(f"Autonomous reset as recovery action is not found with expected fault_ids: "
                  f"{possible_expected_alarms.keys()}")
            raise ExpectedAlarmNotFound
        if not active_alarms:
            error(f"None of the expected alarms {list(possible_expected_alarms.keys())} was raised, NOK")
            raise ExpectedAlarmNotFound
        else:
            info(f"These alarms were added as expected alarms: \n{self.pretty_alarm_print(active_alarms)}")

    def select_alarming_cells_according_to_commissioning(self, cells_of_radio, alarm_info_list, lte441a=False,
                                                         add_just_to_allowed=False, all_lte_cells_affected=False,
                                                         all_nr_cells_affected=False):
        """
        Legacy alarms and category alarms have different fields for cell information. With this method we can check get
        cell in suitable format and add alar to expected alarms.

        :param list cells_of_radio: List of cells. For example ["LNCell-1", "LNCell-2"]
        :param list alarm_info_list: List of fields of alarm to be added to expected alarm. Content of list:
                                    [alarm_id, fault_id, fault_name, severity, unit_path, hw_path]
                                    For example:
                                    ["7653", "10", "Failure in optical interface", "Critical",
                                    [2_11_CLOUD423] MRBTS-22255/EQM-1/APEQM-1/RMOD-1,
                                    /SMOD_R-1(Left)/BBMOD_R-1(Left_Bottom)/rf1/RMOD_R-1]
        :param bool lte441a: (Optional) True if feature lte441-a is on else False. Default is False
        :param bool add_just_to_allowed: Default value is False. If set to True adds faults just to allowed alarms.
        :param bool all_lte_cells_affected: If True then sets LTE:Faulty: All
        :param bool all_nr_cells_affected: If True then sets NR:Faulty: All
        """
        if len(alarm_info_list) not in (6, 7):
            error("Content of alarm_info_list is expected to be [alarm_id, fault_id, fault_name, severity, unit_path, "
                  "hw_path] or [alarm_id, fault_id, fault_name, severity, unit_path, "
                  "hw_path, reason], now user has given {}, NOK.".format(alarm_info_list))
            raise ScriptIssue
        if not cells_of_radio:
            error("No cells given to select_alarming_cells_according_to_commissioning method, NOK.")
            raise ScriptIssue
        if CheckAlarms.active_category_alarms:
            self.logger.debug("active_category_alarms is True")
            alarming_cells = self.cells.get_cells_to_alarm_format(cells_of_radio, lte441a_active=lte441a,
                                                                  all_lte_cells_affected=all_lte_cells_affected,
                                                                  all_nr_cells_affected=all_nr_cells_affected)
            if len(alarm_info_list) == 6:
                if add_just_to_allowed:
                    self.add_allowed_alarm(
                        alarm_id=alarm_info_list[0], fault_id=alarm_info_list[1], fault_name=alarm_info_list[2],
                        severity=alarm_info_list[3], unit_path=alarm_info_list[4], hw_path=alarm_info_list[5],
                        cells_cli_info=alarming_cells)
                else:
                    self.add_expected_alarm(
                        alarm_id=alarm_info_list[0], fault_id=alarm_info_list[1], fault_name=alarm_info_list[2],
                        severity=alarm_info_list[3], unit_path=alarm_info_list[4], hw_path=alarm_info_list[5],
                        cells_cli_info=alarming_cells)
            elif len(alarm_info_list) == 7:
                if add_just_to_allowed:
                    self.add_allowed_alarm(
                        alarm_id=alarm_info_list[0], fault_id=alarm_info_list[1], fault_name=alarm_info_list[2],
                        severity=alarm_info_list[3], unit_path=alarm_info_list[4], hw_path=alarm_info_list[5],
                        reason=alarm_info_list[6], cells_cli_info=alarming_cells)
                else:
                    self.add_expected_alarm(
                        alarm_id=alarm_info_list[0], fault_id=alarm_info_list[1], fault_name=alarm_info_list[2],
                        severity=alarm_info_list[3], unit_path=alarm_info_list[4], hw_path=alarm_info_list[5],
                        reason=alarm_info_list[6], cells_cli_info=alarming_cells)
        else:  # legacy alarms are active cell info is only in the impacted_cell -field
            self.logger.debug("active_category_alarms is False")
            for cell in cells_of_radio:
                alarming_cell = self.cells.get_cells_to_alarm_format(
                    cell, cell_field_in_alarm="impacted_cell", lte441a_active=lte441a)
                if len(alarm_info_list) == 6:
                    if add_just_to_allowed:
                        self.add_allowed_alarm(
                            alarm_id=alarm_info_list[0], fault_id=alarm_info_list[1], fault_name=alarm_info_list[2],
                            severity=alarm_info_list[3], unit_path=alarm_info_list[4], hw_path=alarm_info_list[5],
                            impacted_cell=alarming_cell)
                    else:
                        self.add_expected_alarm(
                            alarm_id=alarm_info_list[0], fault_id=alarm_info_list[1], fault_name=alarm_info_list[2],
                            severity=alarm_info_list[3], unit_path=alarm_info_list[4], hw_path=alarm_info_list[5],
                            impacted_cell=alarming_cell)
                elif len(alarm_info_list) == 7:
                    if add_just_to_allowed:
                        self.add_allowed_alarm(
                            alarm_id=alarm_info_list[0], fault_id=alarm_info_list[1], fault_name=alarm_info_list[2],
                            severity=alarm_info_list[3], unit_path=alarm_info_list[4], hw_path=alarm_info_list[5],
                            reason=alarm_info_list[6], impacted_cell=alarming_cell)
                    else:
                        self.add_expected_alarm(
                            alarm_id=alarm_info_list[0], fault_id=alarm_info_list[1], fault_name=alarm_info_list[2],
                            severity=alarm_info_list[3], unit_path=alarm_info_list[4], hw_path=alarm_info_list[5],
                            reason=alarm_info_list[6], impacted_cell=alarming_cell)

    def check_if_4019_should_be_expected_bbmod_alarm(self, bbmod_object, application):
        """
        Check if 4019 should be added as expected alarm, depending on the selected bbmod and killed application.
        If ABIA under testing and crashed application is HWRHwCtrlSExe also 4019 is expected.

        :param obj bbmod_object: Tested BBMOD object.
        :param str application: Crashed application.
        """
        if "ABIA" in bbmod_object.name and application == "HWRHwCtrlSExe":
            self.add_expected_alarm(severity="Warning", alarm_id="7652", fault_id="4019",
                                    fault_name="Baseband card autonomous reset as recovery action",
                                    unit_path=bbmod_object.unit_path, hw_path=bbmod_object.hw_path)

    def add_fault_7504_as_allowed_if_5g(self):
        """
        Check if BTS is 5G. If is then add fault 7504 'F1 SCTP endpoint in DU' as an allowed alarm.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if self.bts.check_if_5g_environment():
            # if "SBTS00" not in self.bts.get_branch_of_active_build():
            #     print("There is non trunk SW in 5G environment -> add allowed alarm")
            warning("Adding fault 'F1 SCTP endpoint in DU' as a allowed alarm. This is temporary fix due PR740214 "
                    "until new cloud-BTS CNI.")
            self.add_allowed_alarm(fault_id="7504", fault_name="F1 SCTP endpoint in DU")

    def check_if_fault_is_active(self, fault_id, unit_path=None, info_txt="", set_fault_to_allowed=False):
        """
        Check if fault is active

        :param str/list fault_id: FaultId that is checked if it is active
        :param str unit_path: Unit_path to check if None then just faultId is checked
        :param str info_txt: Text to be printed to user
        :param bool set_fault_to_allowed: Default is False, if True then Fault is added to allowed alarm
        """
        fault_active = False
        if self.rt_alarms.active_alarms_during_test:
            for rt_alarms in list(self.rt_alarms.active_alarms_during_test.values()):
                for rt_alarm in rt_alarms:
                    if not unit_path:
                        if isinstance(fault_id, list):
                            for fault in fault_id:
                                if str(rt_alarm.fault_id) == str(fault):
                                    fault_active = True
                                    if set_fault_to_allowed:
                                        info(f"Add fault_id {fault} to allowed alarms")
                                        self.add_allowed_alarm(fault_id=f"{fault}")
                                        CheckAlarms.fault_active_added_allowed.append(fault)
                        else:
                            if str(rt_alarm.fault_id) == str(fault_id):
                                fault_active = True
                                if set_fault_to_allowed:
                                    info(f"Add fault_id {fault_id} to allowed alarms")
                                    self.add_allowed_alarm(fault_id=f"{fault_id}")
                                    CheckAlarms.fault_active_added_allowed.append(fault_id)
                    else:
                        if str(rt_alarm.unit_path) == str(unit_path) and str(rt_alarm.fault_id) == str(fault_id):
                            fault_active = True
        if not fault_active:
            info(f"Fault {fault_id} is not found from the active alarms.")
        else:
            if info_txt:
                info(f"{info_txt}")
            else:
                info(f"Fault {fault_id} is found as an active alarm.")
        return fault_active

    def remove_allowed_alarms_added_in_check_if_fault_active(self):
        """
        Remove allowed alarms added in check if fault active
        """
        info(f"Removing alarms from allowed alarms that were added in check if fault active "
             f"{CheckAlarms.fault_active_added_allowed}")
        if CheckAlarms.fault_active_added_allowed:
            for fault in CheckAlarms.fault_active_added_allowed:
                self.remove_allowed_alarm(fault_id=fault)
        CheckAlarms.fault_active_added_allowed = []

    def check_if_fault_active_and_wait_for_it_to_clear(self, fault_id, wait_max_clear=700, unit_path=None):
        """
        Check active alarms and if given fault_id is found as an active alarm wait for it to clear max given time.
        Default wait_max_clear time is set to 700s. If wait_max_clear == 0 clearing of fault is not expected.

        :param str fault_id: Fault_id for example 4420.
        :param int wait_max_clear: Default value is 700s.
        :param unit_path: Default value is None. If given waits for fault to clear only on this unit
        """
        start_time = datetime.datetime.now()
        if wait_max_clear > 0:
            info(f"Check if fault {fault_id} is found as an active alarm. If it is active, wait max {wait_max_clear} "
                 f"seconds for fault to be cleared.")
            fault_active = self.check_if_fault_is_active(
                fault_id, unit_path=unit_path,
                info_txt=f"Fault {fault_id} is found as an active alarm, wait for it to clear.")
        else:
            info(f"Check if fault {fault_id} is found as an active alarm.")
            fault_active = self.check_if_fault_is_active(
                fault_id, unit_path=unit_path,
                info_txt=f"Fault {fault_id} is found as an active alarm.")
        if fault_active:
            while (datetime.datetime.now() - start_time).total_seconds() < int(wait_max_clear) and fault_active:
                BuiltIn().sleep("30s")
                fault_cleared = True
                try:
                    active_admin_alarms = self._get_active_alarms_from_admin()
                    parsed_active = self.parse_alarm_info_from_admin(active_admin_alarms)
                    self.logger.debug("Parsed active alarms: {}".format(parsed_active))
                    print("Parsed active alarms: {}".format(parsed_active))
                    if parsed_active:
                        for admin_alarm in parsed_active:
                            if not unit_path:
                                if admin_alarm.fault_id == fault_id:
                                    self.logger.debug(f"Fault {fault_id} is not yet cleared. Wait 30s and check again.")
                                    fault_cleared = False
                                    break  # out from for-loop
                            else:
                                if admin_alarm.fault_id == fault_id and admin_alarm.unit_path == unit_path:
                                    self.logger.debug(f"Fault {fault_id} is not yet cleared on unit {unit_path}. Wait "
                                                      f"30s and check again.")
                                    fault_cleared = False
                                    break  # out from for-loop

                    if fault_cleared:
                        info(f"Fault {fault_id} is cleared. Wait for it took "
                             f"{(datetime.datetime.now() - start_time).total_seconds()} seconds")
                        info(f"Add {fault_id} to allowed alarms since it was active during the test so alarm history "
                             f"check won't fail.")
                        self.add_allowed_alarm(fault_id=fault_id)
                        fault_active = False  # this should break out from while-loop
                        break  # from while-loop
                except (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                        AdminApiTerminatedException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                        AliasInUse, AliasLookupError) as admin_error:
                    error(f"Unable to get active alarms from admin: {admin_error.__class__.__name__}:{admin_error} "
                          f"was raised\n"
                          f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
        else:
            self.logger.debug(f"Fault {fault_id} was not in the active alarms.")

    def get_expected_alarms(self):
        """Return list of expected alarms."""
        self.logger.debug(f"Expected alarms: {CheckAlarms.expected_alarms}")
        return CheckAlarms.expected_alarms

    def _check_if_fault_signature_enabled(self):
        """
        Checks if fault signature is enabled, <p name="actFaultSignature">true</p>.

        :raise ConfigurationIssue: If the state of actFaultSignature is neither true nor false if the parameter in scf.
        :return: True if actFaultSignature == true or the parameter is missing from commissioning, else return False.
        """
        try:
            object_distname = self.scf.get_distname_based_on_class("com.nokia.srbts.mnl:FEATCADM")[0]
            f_signature = self.scf.get_value_from_scf(dist_name=object_distname, p_name="actFaultSignature",
                                                      allow_missing=True)
            self.logger.debug("Value of actFaultSignature: {}".format(f_signature))
            if not f_signature:  # if parameter is missing from commissioning, assume that fault signature is enabled
                self.logger.debug("actFaultSignature parameter is missing from commissioning, assume that it is enabled"
                                  " since it should be default value.")
                print("actFaultSignature parameter is missing from commissioning, assume that it is enabled since it "
                      "should be default value.")
                return True
            elif f_signature.lower() == "true":
                return True
            elif f_signature.lower() == "false":
                return False
            else:
                error("actFaultSignature of the test environment should be 'True', 'true', 'false' or 'False', not {}, "
                      "NOK.".format(f_signature))
                raise ConfigurationIssue("Problems in test environment, actFaultSignature has unfitting value")
        except IndexError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error("Could not find com.nokia.srbts.mnl:FEATCADM value, cannot check if fault signature is enabled.")

    def _update_legacy_alarm_to_category_alarm(self, fault_id, fault_name, alarm_id, unit):
        """
        Updates legacy alarms to category alarms by giving them an updated alarm ID and fault ID.

        :param str/int/None fault_id: The ID of the fault.
        :param str fault_name: The name of the fault.
        :param str/int/None alarm_id: The ID of the alarm.
        :param str unit: The unit in question.
        :return tuple(str/None, str): Returns alarm_id and fault_name.
        """
        ald = fault_name and (str(alarm_id) in ("7652", "7653", "7654", "7655") and (
                    (("mast head amplifier" in fault_name.lower() and str(alarm_id) not in "7652") or "vswr" in
                     fault_name.lower()) or ("antenna line" in fault_name.lower() and str(alarm_id) not in "7652"))
               and str(fault_id) not in ("1871", "1872", "1873", "1874", "10") or unit and "Other BTS" not in unit)

        try:
            if not alarm_id or (alarm_id and str(alarm_id) in ("7650", "7651", "7652", "7653", "7654", "7655", "7665")):
                if fault_name in category_alarms.change_fault_text["autonomous_text"]:  # autonomous alarm
                    alarm_id = "7101"
                    if fault_id == "4663" and "site" not in fault_name:
                        alarm_id = "7115"
                else:
                    if fault_id and str(fault_id) in category_alarms.change_fault_text["fault_number"].keys():
                        fault_name = category_alarms.change_fault_text["fault_number"][str(fault_id)]["fault_txt"]
                        if str(fault_id) in category_alarms.change_fault_text["fault_number"].keys() and \
                                "alarm_id" in category_alarms.change_fault_text["fault_number"][str(fault_id)]:
                            alarm_id = category_alarms.change_fault_text["fault_number"][str(fault_id)]["alarm_id"]
                    if str(alarm_id) in ("7650", "7652", "7653", "7654") and "blocked" in fault_name:
                        # no 7652 in flame
                        alarm_id = "7102"
                    elif ald:
                        alarm_id = "7113"
                    elif str(alarm_id) in ("7650", "7653", "7654") or (
                                    str(alarm_id) == "7652" and "BTS reset required" in fault_name):
                        alarm_id = "7116"
                    elif str(alarm_id) == "7652" and 'autonomous' in fault_name:
                        alarm_id = "7101"
                    elif str(alarm_id) in ("7651", "7655", "7652"):
                        alarm_id = "7115"
            else:
                self.logger.debug("Alarm in test is already category alarm type, no need to change.")
        except KeyError as e:
            error(f"KeyError ({e}). Problems when getting category alarms\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        return fault_name, alarm_id

    def _create_allowed_alarms(self, allowed_alarms_list):
        """
        Add a list of alarm objects to allowed_alarms -object from a list of fault names.

        :param list allowed_alarms_list: list of allowed fault names.
        :return list allowed_alarms: a list of allowed alarms.
        """
        allowed_alarms = []
        for part_of_fault in allowed_alarms_list:
            if part_of_fault.isnumeric():
                allowed_alarms.append(self.create_alarm(fault_id=part_of_fault))
            else:
                allowed_alarms.append(self.create_alarm(fault_name=part_of_fault))
        return allowed_alarms

    def _get_cells(self):
        """
        Finds a list of cells in an alarm list in the unit_path form.

        :return cells_in_alarm_list: Returns the cells in an alarm list.
        """
        cells_in_alarm_list = self.cells.parse_cell_information_for_alarm()
        self.logger.debug("Cells in alarm: {}".format(cells_in_alarm_list))
        return cells_in_alarm_list

    @staticmethod
    def _remove_comments(content):
        """Remove comments and empty lines from allowed_alarms content."""
        comment_pattern = re.compile(r"\s*(#.*)")
        return [row for row in content if row and not comment_pattern.match(row)]

    @staticmethod
    def _unallowed_6450_fault_is_active(unallowed_alarms):
        """Checks id fault 6450 is found from unallowed alarms. If is found return True, otherwise return False."""
        for unallowed_alarm in unallowed_alarms:
            if str(unallowed_alarm.fault_id) == "6450":
                info("Fault_id 6450 found from alarms as unallowed.")
                return True
        return False

    def check_if_suppressfaults_are_in_use(self, cni127210, suppressfaults_path):
        """
        Check If Suppressfaults are in use is method is created because of CNI-12710. It checks if suite variable
        ${CNI127210} is set to True or False. If ${CNI127210} is True, collects all fault_ids (given in file
        ${SUPRESSFAULTS_PATH}) that are suppressed if alarming as minor.

        :param bool cni127210: If True CNI-127210 is expected to be activated.
        :param str suppressfaults_path: Path to file to which all suppressed fault ids are collected.
        """
        info("Check if suppressFault is set into use and if it is in use that suppressfault file has some fault_ids.")
        if cni127210:  # self.scf.suppressfaults:
            info("${CNI127210} is ${True} -> suppressFault is set into use")
            suppressed_faults_and_names = self.read_text_file(suppressfaults_path)
            print(f"All suppressFaults:{suppressed_faults_and_names}")
            CheckAlarms.suppressed_faults = [
                self._safe_split(sfault, ":")[0].strip() for sfault in suppressed_faults_and_names
            ]
            if not CheckAlarms.suppressed_faults:
                error(f"CNI-127210 is set to True, but couldn't parse fault ids from file {suppressfaults_path}. Check "
                      f"file content if it has suitable values.\nValues should be given as: <faultid>:<fault name> or "
                      f"as <fault_id>.")
                raise ScriptIssue(f"Couldn't parse fault ids from file {suppressfaults_path}.")
        else:
            info("${CNI127210} is ${False} -> suppressFault is not in use.")

    @staticmethod
    def get_specific_expected_alarm(fault_id, fault_name, alarm_id=None):
        """
        Get and return a specific expected alarm object based on given parameters

        :param str fault_id: Fault id of the alarm.
        :param str fault_name: Fault name of the alarm.
        :param str alarm_id: (Optional) Alarm id of the alarm.
        """
        if CheckAlarms.expected_alarms:
            if fault_id and fault_name:
                for e_alarm in CheckAlarms.expected_alarms:
                    if alarm_id and ((fault_id == e_alarm.fault_id and e_alarm.fault_id is not None) and
                                     (fault_name == e_alarm.fault_name and e_alarm.fault_name is not None) and
                                     (alarm_id == e_alarm.alarm_id and e_alarm.alarm_id is not None)):
                        return e_alarm
                    if not alarm_id and ((fault_id == e_alarm.fault_id and e_alarm.fault_id is not None) or
                                         (fault_name == e_alarm.fault_name and e_alarm.fault_name is not None)):
                        return e_alarm
        else:
            info("There are no expected alarms listed.")

    def check_if_fault_10_should_be_allowed_to_fhs(self):
        """Check If Fault 10 Should Be Allowed To FHS"""
        fhs_unit_path = self.get_unit_path_of_fhs()
        if fhs_unit_path:
            self.add_allowed_alarm(fault_id="10", fault_name="No connection to unit", unit_path=fhs_unit_path)
            return True
        else:
            self.logger.debug("No FHS in the environment -> 10 fault not added to FHS as allowed")
            return False

    def get_unit_path_of_fhs(self):
        """Get unit path of FHS gets unit_path used in alarms of FHS"""
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if "fhs" in self.bts.bts_info['requestMessage']:
            for fhs in self.bts.bts_info['requestMessage']['fhs']:
                self.logger.debug(f"Configuration name of the FHS unit: {fhs['id']['configuration']}")
                return f"[{self.bts.bts_name}] {fhs['id']['configuration']}"
        self.logger.debug("There is no FHS unit in the environment")
        return None

    def add_radio_of_other_side_to_allowed_if_shared(self, radio_object, alarm_id=None, fault_id=None, fault_name=None,
                                                     severity=None):
        """
        Add radio of other side to allowed if shared. In RFS if power of radio is switched off alarm may be raised to
        the radio of other side. This alarm is not expected to be raised in the test, but is allowed.
        """
        if not fault_id or not fault_name:
            error("Fault_id and fault_name are required to radio of other side to set allowed alarm.")
            raise ScriptIssue("Fault_id and fault_name are required to add radio of other side to "
                              "allowed alarm.")
        if not radio_object:
            error("Radio object is required to add radio of other side to allowed alarm.")
            raise ScriptIssue("Radio object is required to add radio of other side to allowed alarm.")
        if BuiltIn().get_variable_value("${RFS}"):
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            for radio in self.bts.radios_remote:
                if radio_object.serial_number == radio.serial_number:
                    info(f"Adding fault {fault_id} to allowed alarms for shared radio of other side {radio.name} ("
                         f"{radio.serial_number}, {radio.unit_path})")
                    self.add_allowed_alarm(alarm_id=alarm_id, fault_id=fault_id, fault_name=fault_name,
                                           severity=severity, unit_path=radio.unit_path)
                    break

    def check_if_allowed_alarms_during_rollback(self, remove=False):
        """
        Check if allowed alarms during rollback checks if user has given tag/variable ALLOWED_DURING_ROLLBACK.
        If ALLOWED_DURING_ROLLBACK has been given and remove is False then adds fault id 4220: 'Radio slave has taken
        temporary radio master role' to allowed alarms. If remove is True then removes the 4220 fault from allowed fault

        :param bool remove: Default is False and then adds the fault to allowed. If True removes from the allowed alarms
        """
        if BuiltIn().get_variable_value("${ALLOWED_DURING_ROLLBACK}", default=False):
            if not remove:
                self.add_allowed_alarm(fault_id="4220", fault_name="Radio slave has taken temporary radio master role")
            else:
                self.remove_allowed_alarm(fault_id="4220",
                                          fault_name="Radio slave has taken temporary radio master role")
        else:
            print("TAG/Variable ALLOWED_DURING_ROLLBACK is not given")
            self.logger.debug("TAG/Variable ALLOWED_DURING_ROLLBACK is not given")

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)
