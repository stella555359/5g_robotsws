import taf.collectors.btslog as btslog
import taf.collectors.core as collectors_core
from taf.collectors.core import ExecutionError

from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as VmOs
from robot.libraries.BuiltIn import BuiltIn
from time import sleep


class SyslogCollector(object):

    def __init__(self):

        self._core = collectors_core.CollectorKeywords()
        self._btslog = btslog.btslog()

    def start_btslog_on_local_machine(self, bts_log_dir=Env.BTS_LOG_DIR_5G, name=Env.BTSLOG_5G_ALIAS):
        """
        Starts btslog on local machine
        :param bts_log_dir: log collection directory
        :param name: name for the alias and for the log directory storage
        :return: None
        """
        VmOs().make_empty_dir(bts_log_dir)
        self._start_btslog(name=name, bts_log_dir=bts_log_dir)

    def start_btslog_on_remote_machine(self, bts_log_dir=Env.BTS_LOG_DIR_4G, name=Env.BTSLOG_4G_ALIAS,
                                       ssh_connection_details=Env.LTE_VM_SSH_CONN_DETAILS,
                                       executor=Env.LTE_VM_SSH_PARAM_DICT):
        """
        Starts btslog on remote machine
        :param bts_log_dir: log collection directory
        :param name: name for the alias and for the log directory storage
        :param ssh_connection_details: ssh connection details to VM
        :param executor: pass the VM ssh connection details ip, user, passwd
        :return: None
        """
        VmOs().make_empty_dir_remote(ssh_connection_details=ssh_connection_details, directory=bts_log_dir)
        self._start_btslog(name=name, bts_log_dir=bts_log_dir, executor=executor)

    def stop_btslog_and_collect_files_on_local_os_if_the_test_fails(self, name=Env.BTSLOG_5G_ALIAS, target_dir=None):
        """
        Stops btslog and collects files in case of the test case fails.
        :param name: name for the alias and for the log directory storage
        :param target_dir: For different location than the robot output directory/test case name
        :return: None
        """
        target_dir_to_save_logs = Env().test_log_dir if target_dir is None else target_dir
        self._core.stop_collectors(names=name)
        try:
            if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
                self._core.collect_collectors(names=name, target_dir=target_dir_to_save_logs)
        except ExecutionError:
            Logger.warning("Bts logs was not collected properly.")
        finally:
            self._core.teardown_collectors(names=name)

    def stop_btslog_and_collect_files_on_local_os(self, name=Env.BTSLOG_5G_ALIAS, target_dir=None):
        """
        Stops btslog and collects files in case of the test case fails.
        :param name: name for the alias and for the log directory storage
        :param target_dir: For different location than the robot output directory/test case name
        :return: None
        """
        target_dir_to_save_logs = Env().test_log_dir if target_dir is None else target_dir
        self._core.stop_collectors(names=name)
        self._core.collect_collectors(names=name, target_dir=target_dir_to_save_logs)
        self._core.teardown_collectors(names=name)

    def stop_btslog(self, name=Env.BTSLOG_5G_ALIAS):
        """
        Stops btslog.
        :param name: name for the alias and for the log directory storage
        :return: None
        """
        self._core.stop_collectors(names=name)
        self._core.teardown_collectors(names=name)

    @staticmethod
    def get_all_logs_containing_text_from_syslog_files(expected_log):
        """
        Function searches for SYSLOG files in the btslog dir and finds all lines matching
        given expected string (not regexp)
        :param expected_log: Expected string to be found
        :return: string lines
        """
        found_lines = []
        for file_ in VmOs.get_files_with_names_starting_with(Env.BTS_LOG_DIR_5G, "SYSLOG"):
            with open(VmOs.join_path_elements(Env.BTS_LOG_DIR_5G, file_), "r") as log:
                found_lines += [line for line in log if line.find(expected_log) > -1]
        lines = "".join(found_lines)
        BuiltIn().log(lines, "DEBUG")
        return lines

    def wait_for_logs_containing_text_from_syslog_files(self, expected_log, interval=10, timeout=60):
        """
        Function waits for first appearance of the expected string in the BTSLOG.
        :param expected_log: Expected string to be found
        :param interval: seconds to wait for the next attempt
        :param timeout: Timeout for the wait action to be finished if string not found
        :return: list of lines with found string
        """
        while timeout > 0:
            found_logs = self.get_all_logs_containing_text_from_syslog_files(expected_log)
            if len(found_logs) > 0:
                return found_logs
            sleep(interval)
            timeout -= interval
        assert False, f"Log containing '{expected_log}' not found within {timeout}s timeout"

    def _start_btslog(self, name, bts_log_dir, executor=None):
        self._btslog.create_btslog_collector(name=name, log_dir=bts_log_dir, executor=executor, start_timeout=20)
        self._core.setup_collectors(names=name)
        self._core.start_collectors(names=name)
        self._btslog.set_suite_alias(alias=name)
