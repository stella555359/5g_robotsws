"""
:modified:05.04.2024

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""
from RadioInterface import RadioInterface
import re


class FaultAssertion(RadioInterface):

    def __init__(self):
        super(FaultAssertion, self).__init__()

    def _assert_active_fault_in_fault_history_log_file(self, fault_id, severity, fault_name):
        if severity is not None:
            severity = severity.lower()

        fault_history_log_file = self._get_fault_history_log_file()
        active_faults = list()

        copy = False
        for line in fault_history_log_file.splitlines():
            line = re.sub('\\s+', ' ', line)
            if ' active faults' in line.lower():
                copy = True
                continue
            elif ' inactive faults' in line.lower():
                copy = False
                continue
            elif copy:
                if 'efaultid' in line.lower():
                    active_faults.append(line)

        if not active_faults:
            raise Exception("No any active faults in fault_history_log.txt found.")

        return self._get_status(active_faults, fault_id, severity, fault_name)

    def _assert_active_alarm_in_fault_history_log_file(self, alarm_id, severity, alarm_name):
        if severity is not None:
            severity = severity.lower()

        fault_history_log_file = self._get_fault_history_log_file()
        active_alarms = list()

        copy = False
        for line in fault_history_log_file.splitlines():
            line = re.sub('\\s+', ' ', line)
            if ' active alarms' in line.lower():
                copy = True
                continue
            elif ' inactive alarms' in line.lower():
                copy = False
                continue
            elif copy:
                if re.search(r'\d{4}-\d{2}-\d{2}', line.lower()):
                    active_alarms.append(line)

        if not active_alarms:
            raise Exception("No any active faults in fault_history_log.txt found.")

        return self._get_status(active_alarms, alarm_id, severity, alarm_name)

    def _assert_inactive_fault_in_fault_history_log_file(self, fault_id, severity, fault_name):
        if severity is not None:
            severity = severity.lower()

        fault_history_log_file = self._get_fault_history_log_file()
        inactive_faults = list()

        copy = False
        for line in fault_history_log_file.splitlines():
            line = re.sub('\\s+', ' ', line)
            if 'inactive faults' in line.lower():
                copy = True
                continue
            elif 'fault events' in line.lower():
                copy = False
                continue
            elif copy:
                if 'efaultid' in line.lower():
                    inactive_faults.append(line)

        if not inactive_faults:
            raise Exception("No any inactive faults in fault_history_log.txt found.")

        return self._get_status(inactive_faults, fault_id, severity, fault_name)

    def _assert_inactive_alarm_in_fault_history_log_file(self, alarm_id, severity, alarm_name):
        if severity is not None:
            severity = severity.lower()

        fault_history_log_file = self._get_fault_history_log_file()
        inactive_alarms = list()

        copy = False
        for line in fault_history_log_file.splitlines():
            line = re.sub('\\s+', ' ', line)
            if 'inactive alarms' in line.lower():
                copy = True
                continue
            elif 'alarm events' in line.lower():
                copy = False
                continue
            elif copy:
                if re.search(r'\d{4}-\d{2}-\d{2}', line.lower()):
                    inactive_alarms.append(line)

        if not inactive_alarms:
            raise Exception("No any inactive alarms in fault_history_log.txt found.")

        return self._get_status(inactive_alarms, alarm_id, severity, alarm_name)

    def _assert_fault_event_in_fault_history_log_file(self, fault_id, severity, state, fault_name):
        fault_events = []
        state = state.lower()
        if severity is not None:
            severity = severity.lower()

        copy = False
        fault_history_log_file = self._get_fault_history_log_file()
        for line in fault_history_log_file.splitlines():
            line = re.sub('\\s+', ' ', line)
            if 'fault events' in line.lower():
                copy = True
                continue
            elif 'availability state change' in line.lower():
                copy = False
                continue
            elif copy:
                if 'active' in line or 'cleared' in line:
                    fault_events.append(line)

        return self._get_status(fault_events, fault_id, severity, fault_name, state)

    def _assert_alarm_event_in_fault_history_log_file(self, alarm_id, severity, state, alarm_name):
        alarm_events = []
        state = state.lower()
        if severity is not None:
            severity = severity.lower()

        copy = False
        fault_history_log_file = self._get_fault_history_log_file()
        for line in fault_history_log_file.splitlines():
            line = re.sub('\\s+', ' ', line)
            if 'alarm events' in line.lower():
                copy = True
                continue
            elif copy:
                if 'active' in line or 'cleared' in line:
                    alarm_events.append(line)

        return self._get_status(alarm_events, alarm_id, severity, alarm_name, state)

    @staticmethod
    def _get_status(alerts_list, alert_id, severity, alert_name, state=None):
        status_list = list()
        for alert_line in alerts_list:
            found_alert_id = re.search(r'\((.*?)\)', alert_line).group(1)
            found_severity = alert_line.split()[4]
            found_alert_name = alert_line.split()[1]
            if state is None:
                conditions = [
                    found_alert_id == alert_id,
                    (found_severity == severity or severity is None),
                    (found_alert_name == alert_name or alert_name is None)
                ]
                if all(conditions):
                    status_list.append(True)
                else:
                    status_list.append(False)
            else:
                found_alert_state = alert_line.split()[5]
                conditions = [
                    found_alert_id == alert_id,
                    (found_severity == severity or severity is None),
                    (found_alert_name == alert_name or alert_name is None),
                    found_alert_state == state
                ]
                if all(conditions):
                    status_list.append(True)
                else:
                    status_list.append(False)

        isTrueIn = True in status_list
        return isTrueIn

    @staticmethod
    def _get_state_from_line(line):
        info_list = line.split()
        state = info_list[5]

        return state

    def _get_fault_history_log_file(self):

        cmd = 'cat /ram/fault_history_log_temp.txt'
        self._send_command(cmd)
        output = self._read_until_regexp('$|#|>')
        if 'No such file or directory' in output:
            cmd = 'cat /ram/fault_history_log.txt'
            self._send_command(cmd)
            output = self._read_until_regexp('$|#|>')

        return output
