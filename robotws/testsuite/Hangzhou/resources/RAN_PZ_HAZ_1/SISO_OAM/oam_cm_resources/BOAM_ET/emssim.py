import os
from ta_emss import ta_emss
from utils import *


class emssim(object):

    def __init__(self, ):
        self.ems = ta_emss()

    def connect_to_emssim(self, user, port, bts_id, host):
        """
        Connect to devices required to the test.
        :param user:  emssim username
        :param port:  emssim json port
        :param bts_id:  emssim bts_id
        :return: None
        """
        self.ems.setup_emss(user=user, port=port, bts_id=bts_id, ne3s=True, host=host)

    def disconnect_to_emssim(self):
        self.ems.teardown_emss()

    def wait_for_onair_by_emssim(self, timeout=300):
        """
        Wait for onair via emssim
        :param timeout: timeout for waiting for onair
        :return: None
        """
        self.ems.wait_for_enb_on_air(timeout=timeout, retry_sleep=15)

    def perform_delta_commissioning_by_emssim(self, delta, bts_id):
        output = change_bts_id_in_json(delta, bts_id)
        self.ems.configure(output)

    @staticmethod
    def _get_latest_log_path():
        res = ''
        cmd = "ls /var/log/emssim/fbox*.log -altr | tail -n1 | awk '{print $9}'"
        with os.popen(cmd) as s:
            res = s.read().strip()
        return res

    @staticmethod
    def _parse_faults_lines_from_log(file, start):
        all_lines = []
        target_lines = []
        with open(file) as f:
            all_lines = f.readlines()
        for (offset, line) in enumerate(all_lines[::-1]):
            if start in line:
                target_lines = all_lines[len(all_lines) - offset:]
                break
        return target_lines

    @staticmethod
    def _sub_middle_str(line, start, end):
        res = None
        start_pos = line.find(start)
        if start_pos:
            end_pos = line.find(end, start_pos+len(start))
            if end_pos:
                res = line[start_pos+len(start):end_pos]
        return res

    @staticmethod
    def _parse_alarm_details(line):
        alarm = {}
        alarm['faultName'] = emssim._sub_middle_str(
            line, start='additionalText1: "', end='",')
        alarm['faultId'] = emssim._sub_middle_str(
            line, start='additionalText3: "', end=' unitName')
        alarm['alarmId'] = emssim._sub_middle_str(
            line, start='specificProblem: "', end='",')
        alarm['severity'] = emssim._sub_middle_str(
            line, start='perceivedSeverity: "', end='",').capitalize()
        return alarm

    @staticmethod
    def _filter_alarms_from_lines(lines):
        alarms = []
        filter = 'Alarm: %'
        for line in lines:
            if filter in line:
                alarm = emssim._parse_alarm_details(line)
                if alarm not in alarms:
                    alarms.append(alarm)
        return alarms

    @staticmethod
    def _parse_alarms_from_log():
        target_log = emssim._get_latest_log_path()
        start_line = 'Sending upload request: type="active_faults"'
        target_lines = emssim._parse_faults_lines_from_log(
            target_log, start_line)
        return emssim._filter_alarms_from_lines(target_lines)

    def get_active_alarms_by_emssim(self):
        self.ems.run_emssim_command('alarm_status')
        return self._parse_alarms_from_log()
