from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.resources.linux_accounts.system_account_permissions\
    import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from moler.exceptions import CommandFailure
import datetime
import json
import re


class CuRuemlog:
    """
    Class for validation RUEM.json log generated with auditlogconvert tool.
    """

    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.last_event_time = None
        self.test_suite_start = None
        self.all_log = None
        self.actual_logs_entries = []
        self.cu_address = tl.gnbs[0].cu.oam_ssh_connection_details.addr
        self.cu_username = tl.gnbs[0].cu.oam_ssh_connection_details.username
        self.cu_password = tl.gnbs[0].cu.oam_ssh_connection_details.password
        self.path_to_reum_log = "/home/robot/RUEM.json"

    @MolerTest.raise_background_exceptions()
    def set_time_before_event(self):
        """
        Save unix epoch time before defined event.
        """
        self.last_event_time = self._get_oam_cu_time()

    @MolerTest.raise_background_exceptions()
    def check_entry_in_ruemlog(self, operation=None, username=None, operationresult=None, additionaltext=None,
                               transaction=None, logstatus=None, timestamp=None, sessionid=None, clientaddress=None):
        """
        Search for entry matched with defined parameter's regex.

        :param operation: operation filed regex
        :param username: username filed regex
        :param operationresult: operationResult filed regex
        :param additionaltext: additionalText field regex
        :param transaction: transaction filed regex
        :param logstatus: operationResult field regex
        :param timestamp: timestamp field regex
        :param sessionid: applSessionId field regex
        :param clientaddress: clientAddress field regex
        """
        self._download_ruem_log()
        self._filter_entries_since_last_event()
        expected_dict = self._create_expected_entry_dict(operation, username, operationresult, additionaltext,
                                                         transaction, logstatus, timestamp, sessionid, clientaddress)
        correct_entry_found = False
        for entry in self.actual_logs_entries:
            if self._validate_single_entry(entry, expected_dict):
                correct_entry_found = True
                MolerTest.info("MATCHED LOGS ENTRY:", dump=entry)
                break
            else:
                continue
        if correct_entry_found:
            MolerTest.info("Proper logs entry found")
        else:
            MolerTest.info("Expected entry:", dump=expected_dict)
            MolerTest.error("Cannot find proper log entry in actual content:",
                            dump=self.actual_logs_entries, raise_exception=True)
        MolerTest.sleep(5)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_if_auth_log_is_visible_for_non_root_user(self, bts_id=0):
        """
        Check if auth.log is visible for non root user robot.

        :param bts_id: id of BTS
        """
        device_name = "GNB{}_CU".format(bts_id)
        bts = DeviceFactory.get_device(device_name)
        bts.goto_state("OAM")
        cmd_cat = bts.get_cmd(cmd_name="cat", cmd_params={"path": "/mnt/log/master/fsaudit/auth.log"})
        try:
            cmd_cat()
            MolerTest.error("Auth.log file is visible for non root user", raise_exception=True)
        except CommandFailure:
            MolerTest.info("Auth.log file is NOT visible for non root user")

    @staticmethod
    def _create_expected_entry_dict(operation, username, operationresult, additionaltext, transaction, logstatus,
                                    timestamp, sessionid, clientaddress):
        result = {
            "operation": operation,
            "username": username,
            "operationResult": operationresult,
            "additionalText": additionaltext,
            "transaction": transaction,
            "logStatus": logstatus,
            "timestamp": timestamp,
            "applSessionId": sessionid,
            "clientAddress": clientaddress
        }
        for key in list(result.keys()):
            if result[key]:
                continue
            else:
                del result[key]
        return result

    @load_moler_configuration_from_tl()
    def _download_ruem_log(self, bts_id=0):
        device_name = "GNB{}_CU".format(bts_id)
        bts = DeviceFactory.get_device(device_name)
        bts.goto_state("OAM")
        authlog_to_json_cmd_cmd_string = "auditlogconvert --output=json --type-filter=write,read-sensitive,none,read" \
                                         " --category-filter=event --file=/home/robot/RUEM.json"
        convert_authlog_to_json_cmd = bts.get_cmd(cmd_name="bash",
                                                  cmd_params={"bash": authlog_to_json_cmd_cmd_string})
        cmd_sudo = bts.get_cmd(cmd_name="sudo",
                               cmd_params={"password": "", "cmd_object": convert_authlog_to_json_cmd})
        cmd_sudo()
        chmod_cmd = bts.get_cmd(cmd_name="chmod", cmd_params={'filename': self.path_to_reum_log, 'permission': "777"})
        cmd_sudo_chmod = bts.get_cmd(cmd_name="sudo",
                                     cmd_params={"password": "", "cmd_object": chmod_cmd})
        cmd_sudo_chmod()
        bts.goto_state("PROXY_PC")
        scp_ruem_log = bts.get_cmd(cmd_name="scp", cmd_params={
            "source": "{}@{}:{}".format(self.cu_username, self.cu_address, self.path_to_reum_log),
            "dest": "/tmp",
            "password": self.cu_password})
        scp_ruem_log()
        self.all_log = self._open_local_ruemlog()
        self._delete_ruem_log_file()

    def _filter_entries_since_last_event(self):
        for entry in self.all_log["auditLogs"]:
            if self._get_unix_sec_from_timestamp(entry["timestamp"]) >= self.last_event_time:
                self.actual_logs_entries.append(entry)

    def _delete_ruem_log_file(self, bts_id=0):
        device_name = "GNB{}_CU".format(bts_id)
        bts = DeviceFactory.get_device(device_name, initial_state="PROXY_PC")
        bts.get_cmd(cmd_name="rm", cmd_params={"file": "/tmp/RUEM.json"})()
        bts.goto_state("OAM")
        bts.get_cmd(cmd_name="rm", cmd_params={"file": self.path_to_reum_log})()

    @staticmethod
    def _validate_single_entry(entry, expected_entry):
        for value in list(expected_entry.keys()):
            if value in list(entry.keys()) and re.match(expected_entry[value], str(entry[value])):
                continue
            else:
                return False
        return True

    @staticmethod
    def _get_unix_sec_from_timestamp(timestamp):
        sec = datetime.datetime.strptime(timestamp.split(".")[0], "%Y-%m-%dT%H:%M:%S") - datetime.datetime(1970, 1, 1)
        return int(sec.total_seconds())

    @staticmethod
    def _open_local_ruemlog():
        with open('/tmp/RUEM.json') as f:
            return json.load(f)

    @staticmethod
    @load_moler_configuration_from_tl()
    def _get_oam_cu_time(bts_id=0):
        device_name = "GNB{}_CU".format(bts_id)
        bts = DeviceFactory.get_device(device_name)
        bts.goto_state("OAM")
        cmd_date = bts.get_cmd(cmd_name="date")
        result = cmd_date()
        sec = datetime.datetime.strptime(result["DATE"]["FULL"] + result["TIME"]["FULL"],
                                         "%d-%m-%Y%H:%M:%S") - datetime.datetime(1970, 1, 1)
        return int(sec.total_seconds())
