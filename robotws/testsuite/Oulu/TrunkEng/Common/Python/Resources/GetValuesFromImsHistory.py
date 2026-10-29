"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

from typing import Any
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import error, info
from taf.analyzer.ims2 import Ims2ChangesetLogEntry, Ims2LogReader, Ims2ResetLogEntry
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (
    PathToIms2NotGiven, ScriptIssue, NoDictionaryForIms2HistoryCheck, WrongStateInIms2History,
    ComponentNotFoundFromIms2History, ElementNotFoundFromIms2History, StateNotFoundFromIms2History)


class GetValuesFromImsHistory:
    """
    GetValuesFromImsHistory is used for checking unit, component etc. states from ims2 file.

    GetValuesFromImsHistory is called in common_resources.robot. If the class is already initiated once, import robot
    BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("IMS_HISTORY")
    """
    current_state = ""
    current_element = ""
    current_distname = ""
    current_timestamp = None
    unexpected_state = ""
    component_element_state_timestamp = {}

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.collect_logs = None

    @staticmethod
    def add_values_to_dict(component, element, state, timestamp):
        """
        Adds values to dictionary. Dictionary can be used for better error messages and for calculating durations etc.

        :param str component: Component for example /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-1.
        :param str element: Element for example operationalState.
        :param str state: State for example Enabled.
        :param str timestamp: Time when state reached for example 2023-05-31 22:06:30.270000+00:00.
        """
        if (not GetValuesFromImsHistory.component_element_state_timestamp or
                component not in GetValuesFromImsHistory.component_element_state_timestamp):
            timestamp_dict = {state: timestamp}
            element_dict = {element: timestamp_dict}
            GetValuesFromImsHistory.component_element_state_timestamp[component] = element_dict
        elif element not in GetValuesFromImsHistory.component_element_state_timestamp[component]:
            timestamp_dict = {state: timestamp}
            GetValuesFromImsHistory.component_element_state_timestamp[component][element] = timestamp_dict
        elif state not in GetValuesFromImsHistory.component_element_state_timestamp[component][element]:
            GetValuesFromImsHistory.component_element_state_timestamp[component][element][state] = timestamp
        elif GetValuesFromImsHistory.component_element_state_timestamp[component][element][state]:
            # If there are multiple timestamps for same state, they are added to list
            timestamp_value = GetValuesFromImsHistory.component_element_state_timestamp[component][element][state]
            if not isinstance(timestamp_value, list):
                # First timestamp is added to list
                GetValuesFromImsHistory.component_element_state_timestamp[component][element][state] = [timestamp_value,
                                                                                                        timestamp]
            else:
                # Next timestamps are added to list
                timestamp_value.append(timestamp)
                GetValuesFromImsHistory.component_element_state_timestamp[component][element][state] = timestamp_value

    def get_timestamp_of_element_from_dict(self, component, element, state, print_to_eventlog=True, start_point=None,
                                           timestamp_error=True):
        """
        Get timestamp of state of element from dictionary.

        :param str component: Component for example /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-1.
        :param str element: Element for example operationalState.
        :param str state: State for example Enabled.
        :param bool print_to_eventlog: If True, prints timestamp to eventlog. Default value is True.
        :param datetime start_point: Start point to start searching timestamp. Default value is None.
        :param bool timestamp_error: If True, raises error if timestamp is before start point. Default value is True.
        :return timestamp: Time when state reached for example 2023-05-31 22:06:30.270000+00:00.
        :raise ComponentNotFoundFromIms2History: If component is not found from dictionary.
        """
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        if not GetValuesFromImsHistory.component_element_state_timestamp or \
                component not in GetValuesFromImsHistory.component_element_state_timestamp:
            if not timestamp_error:
                return None
            error(f"{loop}Component {component} is not found from dictionary, cannot get timestamp(s)")
            raise ComponentNotFoundFromIms2History
        if element not in GetValuesFromImsHistory.component_element_state_timestamp[component]:
            if not timestamp_error:
                return None
            error(f"{loop}Element {element} is not found from dictionary, cannot get timestamp(s). All elements that "
                  f"are get for component {component} are "
                  f"{GetValuesFromImsHistory.component_element_state_timestamp[component]}")
            raise ElementNotFoundFromIms2History
        if state not in GetValuesFromImsHistory.component_element_state_timestamp[component][element]:
            if not timestamp_error:
                return None
            error(f"{loop}State {state} of {element} of {component} is not found from dictionary, cannot get "
                  f"timestamp. All states that are get for {component} are "
                  f"{GetValuesFromImsHistory.component_element_state_timestamp[component][element]}")
            raise StateNotFoundFromIms2History
        if print_to_eventlog:
            info(f"Timestamp of {state} of {element} of {component} is "
                 f"{GetValuesFromImsHistory.component_element_state_timestamp[component][element][state]}")
        else:
            self.logger.debug(
                f"Timestamp of {state} of {element} of {component} is "
                f"{GetValuesFromImsHistory.component_element_state_timestamp[component][element][state]}")
        if start_point:
            self.logger.debug(f"Start point is {start_point}")
            timestamps = GetValuesFromImsHistory.component_element_state_timestamp[component][element][state]
            self.logger.debug(f"Timestamps: {timestamps}")
            if isinstance(start_point, list):
                self.logger.debug(f"Select the last start point from the list as a start point {start_point[-1]}")
                start_point = start_point[-1]
            if not isinstance(timestamps, list):
                if timestamps >= start_point:
                    if print_to_eventlog:
                        info(f"Timestamp {timestamps} for {state} of {element} of {component} "
                             f"is first timestamp after wanted start point {start_point}")
                    return timestamps
            elif isinstance(timestamps, list):
                for timestamp in timestamps:
                    if timestamp >= start_point:
                        if print_to_eventlog:
                            info(f"Timestamp {timestamp} for {state} of {element} of {component}"
                                 f"is first timestamp after wanted start point {start_point}")
                        return timestamp
            if timestamp_error:
                error(f"Timestamp for {state} of {element} of {component} is before start point {start_point}")
                raise StateNotFoundFromIms2History
            else:
                return None
        return GetValuesFromImsHistory.component_element_state_timestamp[component][element][state]

    @staticmethod
    def get_dict_depth(dic, level=1):
        """
        Find depth of a dictionary.

        :param dict dic: Dictionary which depth is calculated.
        :param int level: Default value is 1.
        :return int: Returns the depth of dictionary.
        """
        if not isinstance(dic, dict) or not dic:
            return level
        return max(GetValuesFromImsHistory.get_dict_depth(dic[key], level + 1) for key in dic)

    def _expected_state_reached(self, expected_value):
        self.logger.debug(f"Expected value {expected_value} found!")
        GetValuesFromImsHistory.current_state = str(expected_value)
        return True

    def _expected_states_was_not_reached(self, expected_value, history_value):
        self.logger.debug(f"Expected value {expected_value} was not equal with history {history_value}")
        GetValuesFromImsHistory.unexpected_state = str(history_value)
        return False

    def compare_values(self, expected_value, history_value, print_to_eventlog=True):
        """
        Compares values of dictionaries to each other.

        :param str expected_value: Expected value.
        :param str history_value: Value from history dict.
        :param bool print_to_eventlog: If True, prints timestamp to eventlog. Default value is True.
        :return bool: True if values are equal, otherwise False.
        """
        if "__Space__" in history_value:
            history_value = history_value.replace("__Space__", " ")
        if expected_value.lower() == history_value.lower():
            if GetValuesFromImsHistory.component_element_state_timestamp and (
                    GetValuesFromImsHistory.current_distname in
                    GetValuesFromImsHistory.component_element_state_timestamp and
                    GetValuesFromImsHistory.current_element in
                    GetValuesFromImsHistory.component_element_state_timestamp[
                        GetValuesFromImsHistory.current_distname]):
                self.logger.debug(f"All collected: {GetValuesFromImsHistory.component_element_state_timestamp}\n"
                                  f"Current_distname: {GetValuesFromImsHistory.current_distname}\n"
                                  f"Current_element: {GetValuesFromImsHistory.current_element}\n"
                                  f"Current_state: {GetValuesFromImsHistory.current_state}")
                if (history_value not in GetValuesFromImsHistory.component_element_state_timestamp[
                            GetValuesFromImsHistory.current_distname][GetValuesFromImsHistory.current_element]):
                    return self._expected_state_reached(expected_value)
                else:
                    ts = GetValuesFromImsHistory.component_element_state_timestamp[
                        GetValuesFromImsHistory.current_distname][GetValuesFromImsHistory.current_element][
                        history_value]
                    if (isinstance(ts, list) and GetValuesFromImsHistory.current_timestamp in ts) or (
                            ts == GetValuesFromImsHistory.current_timestamp):
                        if print_to_eventlog:
                            info(f"Expected value ({expected_value}) of {GetValuesFromImsHistory.current_element} of "
                                 f"{GetValuesFromImsHistory.current_distname} was already reached in earlier checks ("
                                 f"timestamp {ts}).")
                        return True
                    else:
                        if print_to_eventlog:
                            info(f"Expected value ({expected_value}) of {GetValuesFromImsHistory.current_element} of "
                                 f"{GetValuesFromImsHistory.current_distname} was already reached in earlier checks "
                                 f"with timestamp {ts}, now found again with timestamp "
                                 f"{GetValuesFromImsHistory.current_timestamp}.")
                        return self._expected_state_reached(expected_value)
            else:
                return self._expected_state_reached(expected_value)
        else:
            return self._expected_states_was_not_reached(expected_value, history_value)

    def replace_reset_by_disabled(self, log_entry, component_state_dict, component_and_value):
        """
        When a reset occurs, add expected disabled/inactive/unavailable states to the component history
        with the reset timestamp.

        :param log_entry: The reset log entry with timestamp
        :param component_state_dict: Dictionary of components and their expected states
        :param component_and_value: Dictionary to track states observed for each component
        """
        for component, state_dicts in component_state_dict.items():
            # Initialize component tracking if needed
            if component not in component_and_value:
                component_and_value[component] = []

            # Process only states we haven't recorded yet
            for i, state_dict in enumerate(state_dicts):
                if len(component_and_value[component]) <= i:
                    self._process_state_dict(component, state_dict, log_entry, component_and_value)

    def _process_state_dict(self, component, state_dict, log_entry, component_and_value):
        depth = GetValuesFromImsHistory.get_dict_depth(state_dict)
        if depth == 2:  # {"s1LinkStatus": "unavailable"}
            self._check_simple_dict(component, state_dict, log_entry, component_and_value)
        elif depth == 3:  # {"stateInfo": {"operationalState": "disabled"}}
            self._check_nested_dict(component, state_dict, log_entry, component_and_value)

    def _check_simple_dict(self, component, state_dict, log_entry, component_and_value):
        for elem, expected_value in state_dict.items():
            self._check_and_record_state(component, elem, expected_value, log_entry, component_and_value)

    def _check_nested_dict(self, component, state_dict, log_entry, component_and_value):
        for key, inner_dict in state_dict.items():
            if isinstance(inner_dict, dict):
                for elem, expected_value in inner_dict.items():
                    self._check_and_record_state(component, elem, expected_value, log_entry, component_and_value)

    def _check_and_record_state(self, component, elem, expected_value, log_entry, component_and_value):
        if (isinstance(expected_value, str) and
                expected_value.lower() in ["disabled", "inactive", "unavailable"]):
            self._set_reset_states_as_disabled(component, elem, expected_value, log_entry, component_and_value)

    def _set_reset_states_as_disabled(self, component, elem, expected_value, log_entry, component_and_value):
        GetValuesFromImsHistory.current_element = elem
        GetValuesFromImsHistory.current_distname = component
        GetValuesFromImsHistory.current_state = expected_value
        GetValuesFromImsHistory.current_timestamp = log_entry.timestamp
        self.logger.debug(f"Setting {log_entry.timestamp} for {expected_value} state for {elem} of {component}")
        component_and_value[component].append(expected_value)
        self.add_values_to_dict(component, elem, expected_value, log_entry.timestamp)

    def check_if_in_history(self, ims_file_path, component_state_dict):
        """
        Checks if component is found from the ims2 file and have had the requested value(s) during testing.

        :param str ims_file_path: Path to ims2 log file. For example:
                                  /home/ute/MN/UTE/robotws/Test_logs_20230410_224858/Rat_reset_1/Loop_1/ims_history.ims2
        :param dict component_state_dict: Expected component(s) and values. For example:
                {
                "/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1/POWER_GROUP_L-2/SOC_L-1/DSP_L-1": {
                "stateInfo": {
                    "proceduralState": "Resetting"
                      }
                   },
                "/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1/POWER_GROUP_L-1/SOC_L-2/DSP_L-1": {
                "stateInfo": {
                    "proceduralState": "Resetting"
                      }
                   }
                }
        :return bool: True if component with requested value is found from ims2 history, otherwise False.
        :raise PathToIms2NotGiven: If there is no path given to ims2 file.
        :raise NoDictionaryForIms2HistoryCheck: If no component_state_dict given.
        """
        component_found = []
        component_and_value = {}
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        if not ims_file_path:
            if not self.collect_logs:
                self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
            ims_file_path = self.collect_logs.ims_file_name
        if not ims_file_path:
            error(f"{loop}IMS file path is not given, unable to check ims2 history.")
            raise PathToIms2NotGiven("No path to ims2 file")
        if not component_state_dict:
            error(f"{loop}Dictionary not given, cannot check values from ims2 history")
            raise NoDictionaryForIms2HistoryCheck("Dictionary not given, cannot check values from ims2 history")
        if isinstance(ims_file_path, str):
            ims_file_path = [ims_file_path]
        for ims_path in ims_file_path:
            print(f"Parse file {ims_path}")
            for frame_number, log_entry in enumerate(Ims2LogReader.from_file(file_path=ims_path)):
                if isinstance(log_entry, Ims2ResetLogEntry):
                    self.logger.debug(f"{log_entry.timestamp} RESET")
                    self.replace_reset_by_disabled(log_entry, component_state_dict, component_and_value)
                elif isinstance(log_entry, Ims2ChangesetLogEntry):
                    # self.logger.debug(f"{log_entry.timestamp} CHANGES")
                    # self.logger.debug(f"UPDATES: {json.dumps(log_entry.updates, sort_keys=True, indent=4)}")
                    # self.logger.debug(f"REMOVALS:{json.dumps(log_entry.removals, sort_keys=True, indent=4)}")
                    self._compare_found_component_to_all_components(
                        "in history check", component_and_value, component_found, component_state_dict, log_entry,
                        print_to_eventlog=False)
        if not component_found:
            error(f"{loop}{component_state_dict.keys()} were not found at all from ims2 history. "
                  f"Check that dist_names are correctly given.")
            return False
        elif set(component_state_dict.keys()) == set(component_and_value.keys()):
            self.logger.debug(f"{set(component_state_dict.keys())} == {set(component_and_value.keys())}")
            return True
        else:
            self.logger.debug(f"{set(component_found) - set(component_and_value.keys())} "
                              f"didn't have expected values in ims2 history")
            error(f"{loop}{component_found} didn't have expected values in ims2 history")
            return False

    def check_multiple_states_from_history(self, ims_file_path, component_state_dict, collect_all=False,
                                           print_to_eventlog=True):
        """
        Checks if component is found from the ims2 file and have had the requested values during testing. Multiple
        states should be given to key component as a list and first state should be in index 0, second in index 1...
        NOTE that states are expected to appear in same order as given to list.

        :param str ims_file_path: Path to ims2 log file. For example:
            /home/ute/MN/UTE/robotws/Test_logs_20230410_224858/Rat_reset_1/Loop_1/ims_history.ims2
        :param dict component_state_dict: Expected component(s) and values. For example:
                {
                "/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1/POWER_GROUP_L-2/SOC_L-1/DSP_L-1": {
                ["stateInfo": {
                    "operationalState": "Disabled"
                      },
                "stateInfo": {
                    "operationalState": "Enabled"
                      }
                ]
                },
                "/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1/POWER_GROUP_L-1/SOC_L-2/DSP_L-1": {
                ["stateInfo": {
                    "operationalState": "Disabled"
                      },
                "stateInfo": {
                    "operationalState": "Enabled"
                      }
                ]
                }
        :param bool collect_all: If True, collects all states from ims2 history. Default value is False.
        :param bool print_to_eventlog: If True, prints timestamp to eventlog. Default value is True.
        :return bool: True if component with requested value is found from ims2 history, otherwise False.
        :raise PathToIms2NotGiven: If there is no path given to ims2 file.
        :raise NoDictionaryForIms2HistoryCheck: If no component_state_dict given.
        """
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        component_found = []
        component_and_value = {}
        if not ims_file_path:
            if not self.collect_logs:
                self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
            ims_file_path = self.collect_logs.ims_file_name
        if not ims_file_path:
            error(f"{loop}IMS file path is not given, unable to check ims2 history.")
            raise PathToIms2NotGiven("No path to ims2 file")
        if isinstance(ims_file_path, str):
            ims_file_path = [ims_file_path]
        if not component_state_dict:
            error(f"{loop}Dictionary not given, cannot check values from ims2 history")
            raise NoDictionaryForIms2HistoryCheck("Dictionary not given, cannot check values from ims2 history")
        for ims_path in ims_file_path:
            print(f"Parse file {ims_path}")
            for frame_number, log_entry in enumerate(Ims2LogReader.from_file(file_path=ims_path)):
                if isinstance(log_entry, Ims2ResetLogEntry):
                    self.logger.debug(f"{log_entry.timestamp} RESET")
                    self.replace_reset_by_disabled(log_entry, component_state_dict, component_and_value)
                elif isinstance(log_entry, Ims2ChangesetLogEntry):
                    # self.logger.debug(f"{log_entry.timestamp} CHANGES")
                    self._compare_found_component_to_all_components(
                        "multiple state history check", component_and_value, component_found,
                        component_state_dict, log_entry, loop, collect_all=collect_all,
                        print_to_eventlog=print_to_eventlog)
        if not component_found:
            error(f"{loop}{component_state_dict.keys()} were not found at all from ims2 history. Check that "
                  f"dist_names are correctly given.")
            return False
        elif set(component_state_dict.keys()) == set(component_and_value.keys()):
            all_components_have_all_true = []
            component_not_found = []
            for component in component_state_dict:
                self.logger.debug(f"len == "
                                  f"{len(component_state_dict[component]) == len(component_and_value[component])}, "
                                  f"component_state_dict[{component}]={component_state_dict[component]}, "
                                  f"component_and_value[{component}]={component_and_value[component]}")
                if component in component_and_value:
                    if len(component_state_dict[component]) == len(component_and_value[component]) and len(
                            set(component_and_value[component])) == len(component_state_dict[component]) or collect_all:
                        all_components_have_all_true.append(True)
                else:
                    self.logger.debug(f"Component {component} not found from component_and_value...")
                    component_not_found.append(component)
            self.logger.debug(f"all_components_have_all_true: {all_components_have_all_true}")
            self.logger.debug(f"len(comonent_state_dict.keys()): {len(component_state_dict.keys())}")
            if len(all_components_have_all_true) == len(component_state_dict.keys()):
                return True
            else:
                self.logger.debug(f"{loop}{component_not_found} didn't have all expected values in ims2 history "
                                  f"(all found:\n{component_and_value})")
                error(f"{loop}{component_not_found} didn't have all expected values in ims2 history. Check debug-log "
                      f"for more information.")
                return False
        else:
            difference = set(component_found) - set[Any](list(component_and_value.keys()))
            self.logger.debug(f"{loop}didn't have expected values in ims2 history \n"
                              f"(component_value={component_and_value.keys()}, component_found={component_found})")
            error(f"{loop}All the needed components didn't have expected values in ims2 history. Difference: "
                  f"{difference}")
            return False

    def check_if_state_in_history_has_not_changed(self, ims_file_path, component_state_dict):
        """
        Checks if component is found from the ims2 file and have had the requested value(s) all time during testing.

        :param str ims_file_path: Path to ims2 log file. For example:
            /home/ute/MN/UTE/robotws/Test_logs_20230410_224858/Rat_reset_1/Loop_1/ims_history.ims2
        :param dict component_state_dict: Expected component(s) and values. For example:
                {
                "/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-1": {
                "stateInfo": {
                    "operationalState": "Enabled"
                     }
                }
                "/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-2": {
                "stateInfo": {
                    "operationalState": "Enabled"
                      }
                   }
                }
        :return bool: True if component with requested value is found from ims2 history, otherwise False.
        :raise PathToIms2NotGiven: If there is no path given to ims2 file.
        :raise NoDictionaryForIms2HistoryCheck: If no component_state_dict given.
        """
        component_found = []
        component_and_value = {}
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        if not ims_file_path:
            if not self.collect_logs:
                self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
            ims_file_path = self.collect_logs.ims_file_name
        if not ims_file_path:
            error(f"{loop}IMS file path is not given, unable to check ims2 history.")
            raise PathToIms2NotGiven("No path to ims2 file")
        if isinstance(ims_file_path, str):
            ims_file_path = [ims_file_path]
        if not component_state_dict:
            error(f"{loop}Dictionary not given, cannot check values from ims2 history")
            raise NoDictionaryForIms2HistoryCheck("Dictionary not given, cannot check values from ims2 history")
        for ims_path in ims_file_path:
            print(f"Parse file {ims_path}")
            for frame_number, log_entry in enumerate(Ims2LogReader.from_file(file_path=ims_path)):
                if isinstance(log_entry, Ims2ResetLogEntry):
                    self.logger.debug(f"{log_entry.timestamp} RESET")
                    self.replace_reset_by_disabled(log_entry, component_state_dict, component_and_value)
                elif isinstance(log_entry, Ims2ChangesetLogEntry):
                    # self.logger.debug(f"{log_entry.timestamp} CHANGES")
                    component_found = self._compare_found_component_to_all_components(
                        "state history check", component_and_value, component_found, component_state_dict, log_entry)
        if not component_found:
            error(f"{loop}{component_state_dict.keys()} were not found at all from ims2 history. Check that "
                  f"distNames are correctly given.")
            return False
        elif set(component_state_dict.keys()) == set(component_and_value.keys()):
            self.logger.debug(f"{set(component_state_dict.keys())} == {set(component_state_dict.keys())}")
            return True
        else:
            self.logger.debug(f"{set(component_found) - set(component_and_value.keys())} didn't have expected "
                              f"values in ims2 history")
            error(f"{loop}{component_found} didn't have expected values in ims2 history")
            return False

    def check_if_reset_happened(self, ims_file_path):
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        if not ims_file_path:
            if not self.collect_logs:
                self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
            ims_file_path = self.collect_logs.ims_file_name
        if not ims_file_path:
            error(f"{loop}IMS file path is not given, unable to check ims2 history.")
            raise PathToIms2NotGiven("No path to ims2 file")
        if isinstance(ims_file_path, str):
            ims_file_path = [ims_file_path]
        for ims_path in ims_file_path:
            print(f"Parse file {ims_path}")
            for frame_number, log_entry in enumerate(Ims2LogReader.from_file(file_path=ims_path)):
                if isinstance(log_entry, Ims2ResetLogEntry):
                    self.logger.debug(f"{log_entry.timestamp} RESET")
                    return log_entry.timestamp
        error(f"{loop}No reset happened in ims2 history")

    def clear_values(self):
        """
        Clears values from dictionary.
        """
        self.logger.debug("Clear values of GetValuesFromImsHistory")
        GetValuesFromImsHistory.component_element_state_timestamp = {}
        GetValuesFromImsHistory.current_state = ""
        GetValuesFromImsHistory.current_element = ""
        GetValuesFromImsHistory.current_distname = ""
        GetValuesFromImsHistory.unexpected_state = ""
        GetValuesFromImsHistory.current_timestamp = None

    def _compare_found_component_to_all_components(self, method, component_and_value, component_found,
                                                   component_state_dict, log_entry, loop="", collect_all=False,
                                                   print_to_eventlog=True):
        for dist_name, value in log_entry.updates.items():
            for d_name, expected_dict in component_state_dict.items():
                if d_name == dist_name:
                    if d_name not in component_found:
                        component_found.append(d_name)
                    self.logger.debug(f"Component {dist_name} was found from ims2 history")
                    self.logger.debug(f"Value: {value}")
                    self.logger.debug(f"Method: {method}")
                    if method == "state history check":
                        component_found = self._state_history_value_check(
                            component_and_value, component_found, expected_dict, value, d_name, log_entry,
                            print_to_eventlog=print_to_eventlog)
                    elif method == "multiple state history check":
                        comparison_done = self._multiple_state_history_value_check(
                            component_and_value, component_state_dict, expected_dict, value, d_name, log_entry, loop,
                            collect_all, print_to_eventlog=print_to_eventlog)
                        if comparison_done:
                            break
                    elif method == "in history check":
                        self._in_history_value_check(component_and_value, expected_dict, value, d_name, log_entry,
                                                     print_to_eventlog=print_to_eventlog)
        return component_found

    def _state_history_value_check(self, component_and_value, component_found, expected_dict, value, d_name, log_entry,
                                   print_to_eventlog=True):
        GetValuesFromImsHistory.current_distname = d_name
        GetValuesFromImsHistory.current_timestamp = log_entry.timestamp
        if self._check_if_dict_contents_are_equal(expected_dict, value, print_to_eventlog):
            component_and_value[d_name] = True
            self.logger.debug(f"Expected state {d_name} = {value} in {log_entry.timestamp}")
        else:
            error(f"Unexpected state {GetValuesFromImsHistory.unexpected_state} for {d_name} "
                  f"in {log_entry.timestamp}. Should be {expected_dict} through the "
                  f"whole history")
            raise WrongStateInIms2History
        return component_found

    def _check_and_add_values_to_dict(self, expected_dict, index, value, d_name, component_and_value, log_entry,
                                      collect_all, print_to_eventlog=True):
        GetValuesFromImsHistory.current_distname = d_name
        GetValuesFromImsHistory.current_timestamp = log_entry.timestamp
        if self._check_if_dict_contents_are_equal(expected_dict[index], value, print_to_eventlog=print_to_eventlog):
            if d_name not in component_and_value:
                component_and_value[d_name] = [GetValuesFromImsHistory.current_state]
                if print_to_eventlog:
                    info(f"Expected state ({GetValuesFromImsHistory.current_state}) of {d_name} "
                         f"was reached {self._trim_time_stamp(str(log_entry.timestamp))}")
                self.add_values_to_dict(d_name, GetValuesFromImsHistory.current_element,
                                        GetValuesFromImsHistory.current_state, log_entry.timestamp)
            elif GetValuesFromImsHistory.current_state not in component_and_value[d_name] or collect_all:
                component_and_value[d_name].append(GetValuesFromImsHistory.current_state)
                if print_to_eventlog:
                    info(f"Expected state ({GetValuesFromImsHistory.current_state}) of {d_name} "
                         f"was reached {self._trim_time_stamp(str(log_entry.timestamp))}")
                self.add_values_to_dict(d_name, GetValuesFromImsHistory.current_element,
                                        GetValuesFromImsHistory.current_state, log_entry.timestamp)

    def _multiple_state_history_value_check(self, component_and_value, component_state_dict, expected_dict, value,
                                            d_name, log_entry, loop, collect_all, print_to_eventlog=True):
        state_amount = len(expected_dict)
        if state_amount == 0:
            error(f"{loop}No state list is given, {expected_dict}")
            raise ScriptIssue("No state list")
        index = 0
        if component_and_value and d_name in component_and_value and len(
                component_and_value[d_name]) < state_amount:
            self.logger.debug("Still states to reach!!")
            index = len(component_and_value[d_name])
            self.logger.debug(f"Index is {index}")
        self.logger.debug(f"set(component_state_dict.keys()): {set(component_state_dict.keys())}")
        if component_and_value:
            self.logger.debug(f"set(component_and_value.keys()): {set(component_and_value.keys())}")
            if d_name in component_and_value.keys():
                self.logger.debug(f"len(component_and_value[d_name]): {len(component_and_value[d_name])}")
        self.logger.debug(f"state_amount: {state_amount}")
        if not collect_all and (
                component_and_value and set(component_state_dict.keys()) == set(component_and_value.keys()) and (
                d_name in component_and_value.keys() and len(component_and_value[d_name]) == state_amount)):
            index += 1
            self.logger.debug(f"Index is {index}")
            if index == state_amount:
                return "Check complete, break loop"
        if not collect_all:
            self._check_and_add_values_to_dict(expected_dict, index, value, d_name, component_and_value, log_entry,
                                               collect_all, print_to_eventlog=print_to_eventlog)
        elif collect_all:
            for i in range(state_amount):
                self._check_and_add_values_to_dict(expected_dict, i, value, d_name, component_and_value, log_entry,
                                                   collect_all, print_to_eventlog=print_to_eventlog)
        self.logger.debug(f"Index {index}")

    def _in_history_value_check(self, component_and_value, expected_dict, value, d_name, log_entry,
                                print_to_eventlog=True):
        GetValuesFromImsHistory.current_distname = d_name
        if self._check_if_dict_contents_are_equal(expected_dict, value, print_to_eventlog=print_to_eventlog):
            component_and_value[d_name] = True
            self.logger.debug(f"Expected state {d_name} = {value} in {log_entry.timestamp}")
            self.add_values_to_dict(d_name, GetValuesFromImsHistory.current_element,
                                    GetValuesFromImsHistory.current_state, log_entry.timestamp)

    def _check_if_dict_contents_are_equal(self, expected_dict, history_dict, print_to_eventlog=True):
        """
        Compares content of expected dictionary of user given dist_name to dictionary of updates of the dist_name found
        from ims2 history.

        :param dict expected_dict: Expected keys and values for example:
                                   {'stateInfo': {'proceduralState': 'Resetting'}}
        :param dict history_dict: Value of dist_name in ims2 history. For example:
                                  {'stateInfo': {'reasoningStatus': [], 'operationalState': 'Enabled',
                                  'usageState': 'Active', 'administrativeState': 'Unlocked',
                                  'availabilityStatus': 'Offline', 'proceduralState': 'SwLoaded',
                                  'memoryDumpStatus': 'Idle'}, 'nodeId': 8784, 'routingTableDN': '',
                                  'hwVariant': 'Kepler2', 'postStatus': 'Ok'}
        :param bool print_to_eventlog: If True, prints timestamp to eventlog. Default value is True.
        :return bool: Returns True if expected value is found from the history. False otherwise.
        :raise ScriptIssue if user has given expected value that's structure is not as expected in update history.
        """
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        if isinstance(expected_dict, dict) and isinstance(history_dict, dict):
            all_expected_values = []
            expected_dict_depth = GetValuesFromImsHistory.get_dict_depth(expected_dict)
            self.logger.debug(f"expected_dict_depth: {expected_dict_depth}")
            for expected_key in expected_dict.keys():
                if expected_key not in history_dict.keys():
                    if "stateInfo" in history_dict.keys():
                        if expected_key in history_dict["stateInfo"]:
                            GetValuesFromImsHistory.current_element = expected_key
                            all_expected_values.append(
                                self.compare_values(expected_dict[expected_key],
                                                    history_dict["stateInfo"][expected_key],
                                                    print_to_eventlog=print_to_eventlog))
                elif expected_key in history_dict.keys():
                    if expected_dict_depth == 2:
                        GetValuesFromImsHistory.current_element = expected_key
                        all_expected_values.append(
                            self.compare_values(expected_dict[expected_key], history_dict[expected_key],
                                                print_to_eventlog=print_to_eventlog))
                    elif expected_dict_depth == 3:
                        for expected_key2 in expected_dict[expected_key]:
                            GetValuesFromImsHistory.current_element = expected_key2
                            all_expected_values.append(
                                self.compare_values(expected_dict[expected_key][expected_key2],
                                                    history_dict[expected_key][expected_key2],
                                                    print_to_eventlog=print_to_eventlog))
            if all_expected_values and all(all_expected_values):
                return True
            else:
                return False
        else:
            error(f"{loop}Not dictionary! (expected_dict: {expected_dict} and history_dict: {history_dict}).")
            raise ScriptIssue

    def _trim_time_stamp(self, time_stamp):
        """
        This method leaves just 3 digits to seconds and removes end of the time stamp.

        :param str time_stamp: Time stamp to be trimmed for example '2023-10-26 10:50:35.397000+00:00'
        :return str: Return for example '2023-10-26 10:50:35.397'
        """
        self.logger.debug(f"Trim time stamp: {time_stamp}")
        return time_stamp[:time_stamp.rfind(".") + 4]
