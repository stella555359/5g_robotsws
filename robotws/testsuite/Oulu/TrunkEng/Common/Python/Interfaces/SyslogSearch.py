"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
import re
import datetime
import pytz
from traceback import format_exception
import copy
from robot.libraries.BuiltIn import BuiltIn
from time import sleep
from threading import Thread
from taf.collectors.core.entities.executor import TimeoutError
from testsuite.Oulu.TrunkEng.Common.Python.Resources.HaltTests import HaltTest
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ExpectedSyslogPrintNotFound, ScriptIssue,
                                                                        UnexpectedSyslogPrintFound, SyslogFilesNotFound,
                                                                        EnvironmentIssue, UnableToGetTimesFromSyslog)
from testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.E2EBtsStartupCheckpoint import pps_service_breakdown_check_points


class SyslogSearch(object):
    """
    SyslogSearch is called in common_resources.robot. It is used to search prints from syslog logs in realtime and
    non-realtime from the BTSLog dir. It can also be used to halt the test if user has given print(s) that will halt the
    test. Note that syslog is not started/stopped in this class, starting and stopping of BTSLog is done in CollectLogs
    class.

    If the class is already initiated once, import robot BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("SYSLOGSEARCH")
    """

    retry_counter = 0
    btslog_dir = ""  # moved out from the init because caused some problems
    stop_test = ""
    halt_prints = []
    halt_variable_already_checked = False
    remote_syslog_start = None
    remote_syslog_end = None
    e2e_dictionary = {}

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.found_syslog_prints = {}
        self.collect_logs = None
        self.swconfig = BuiltIn().get_library_instance("SWCONFIG")
        self.log_collector = BuiltIn().get_library_instance("COLLECTLOGS")
        self.other_master = False
        if self.log_collector.rfs:
            self.other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
        self._sl_thread = None
        self._sl_running = False

    @staticmethod
    def _decode_line(line: bytes) -> str:
        """
        Decode a raw syslog byte line to str. Tries UTF-8 first. If that fails, falls back to ISO-8859-1 (Latin-1),
        which is a lossless single-byte encoding that can represent all 256 byte values, so it will never raise a
        UnicodeDecodeError.
        """
        try:
            return line.decode('utf-8').strip()
        except UnicodeDecodeError:
            return line.decode('iso-8859-1').strip()

    def _check_if_syslog_folder_is_empty(self):
        """ This method checks if the syslog folder has content."""
        if SyslogSearch.btslog_dir:
            content_of_syslog_folder = os.listdir(SyslogSearch.btslog_dir)
            if not content_of_syslog_folder:
                self.logger.debug(f"No syslog files found from the directory '{SyslogSearch.btslog_dir}'. Check if "
                                  f"BTSLog is started.")
                # raise SyslogFilesNotFound

    def _check_if_log_dir_empty(self):
        """Check if SyslogSearch.btslog_dir path is empty and if it is empty, get the path."""
        if not SyslogSearch.btslog_dir:
            self.logger.debug("SyslogSearch.btslog_dir is empty")
            print("SyslogSearch.btslog_dir is empty")
            if not self.collect_logs:
                self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
            if not self.collect_logs.syslog_log_folder:
                SyslogSearch.btslog_dir = self.collect_logs.get_debian_version_and_set_log_folder()
            else:
                SyslogSearch.btslog_dir = self.collect_logs.syslog_log_folder
            if not SyslogSearch.btslog_dir:
                warning("Odd problems to get btslog_dir path from collect_logs. Using hard coded value /tmp/btslog2.")
                SyslogSearch.btslog_dir = "/tmp/btslog2"
            if SyslogSearch.btslog_dir and not os.path.exists(SyslogSearch.btslog_dir):
                info(f"SyslogSearch.btslog_dir '{SyslogSearch.btslog_dir}' does not exist. Create it.")
                os.mkdir(SyslogSearch.btslog_dir)
            print(f"SyslogSearch.btslog_dir is now set to {SyslogSearch.btslog_dir}")

    @staticmethod
    def get_last_folder_with_files(root_dir):
        for dirpath, dirnames, filenames in os.walk(root_dir, topdown=False):
            if filenames:
                return dirpath
        return None

    def _get_syslogs_from_remote(self):
        """
        Get syslogs from remote

        :returns path to syslogs get from remote to local /home/ute/logs/remote_syslog -folder and content of the dir
        """
        try:
            if not os.path.exists("/home/ute/logs/remote_syslog"):
                os.makedirs("/home/ute/logs/remote_syslog", exist_ok=True)
            remote_syslogs_path = self.log_collector.get_file_or_folder_by_scp(SyslogSearch.btslog_dir,
                                                                               self.collect_logs.remote_vm_ip,
                                                                               "ute", "",
                                                                               local_dir="/home/ute/logs/remote_syslog",
                                                                               update_name=False,
                                                                               scp_timeout=900)
            if remote_syslogs_path:
                self.logger.debug(f"Remote syslogs: {remote_syslogs_path}")
                print(f"Remote syslogs: {remote_syslogs_path}")
                r_syslog_path = self.get_last_folder_with_files(remote_syslogs_path)
                self.logger.debug(f"Remote syslogs last folder with files: {r_syslog_path}")
                print(f"Remote syslogs last folder with files: {r_syslog_path}")
                r_dir = os.listdir(r_syslog_path)
                self.logger.debug(f"Content of remote syslog folder: {r_dir}")
                print(f"Content of remote syslog folder: {r_dir}")
                return r_syslog_path, r_dir
            else:
                error("Unable to move syslog files from remote environment to test environment.")
                raise SyslogFilesNotFound
        except (OSError, AttributeError, TypeError) as e:
            error(f"Could not get syslogs from remote because: {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.collect_logs.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
            raise EnvironmentIssue(f"{e.__class__.__name__}:{e}")

    def get_prints_from_syslogs(self, expected_print, print_eventlog, time_stamp, real_time=False, both_sides=False,
                                exclude_print=None, just_once=False):
        """
        Searches SYSLOG files from the btslog dir and finds all lines matching the expected string.

        :param str or list expected_print: Expected string to be found or list of strings to be searched.
        :param bool print_eventlog: Prints found syslog line to eventlog. If set to False, will not print the line to
                                    eventlog
        :param object time_stamp: Datetime object for example 1900-09-11 13:57:41.513000, can also be None
        :param bool real_time: If set True, will search prints in real time. Default is False.
        :param bool both_sides: If set True, will search the syslogs from local and remote sides. Default is False
        :param str exclude_print: Use this if there are prints with minor changes and you want to exclude the other
        :param bool just_once: If user wants to get just one occurrence of the expected print from syslog files.
        :raise UnicodeDecodeError: If there are bytes in SYSLOG that 'utf-8' codec can't decode.
        :raise ScriptIssue: If expected_print is not a string or a list of strings.
        :return dict: Dictionary where syslog filenames from where the prints were found are as keys. Another dictionary
                      as value to which search strings are as keys and found syslog lines in a list as value. Empty
                      dict if not found.
        """
        file_and_search_results = {}
        remote_syslogs_path = ""
        self._check_if_log_dir_empty()
        self._check_if_syslog_folder_is_empty()
        if not expected_print:
            warning("Syslog prints to be parsed from the syslog are not given in test suite.")
            return file_and_search_results
        syslogs_in_dir = [name for name in os.listdir(SyslogSearch.btslog_dir) if name.startswith("SYSLOG")]
        self.logger.debug(f"Syslogs in dir ({SyslogSearch.btslog_dir}): {syslogs_in_dir}")
        print(self.logger.debug(f"Syslogs in dir ({SyslogSearch.btslog_dir}): {syslogs_in_dir}"))
        if (self.log_collector.rfs or BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}",
                                                                   default=False)) and both_sides:
            self.logger.debug(f"Local syslogs in dir: {syslogs_in_dir}")
            remote_syslogs_path, remote_syslogs = self._get_syslogs_from_remote()
            remote_syslogs_in_dir = [f"remote_{r}" for r in remote_syslogs if r.startswith("SYSLOG")]
            self.logger.debug(f"Remote syslogs in dir: {remote_syslogs_in_dir}")
            if syslogs_in_dir and remote_syslogs_in_dir:
                syslogs_in_dir.extend(remote_syslogs_in_dir)
            elif syslogs_in_dir and not remote_syslogs_in_dir:
                warning("No syslog get from the remote. Local syslogs are get.")
            elif not syslogs_in_dir and remote_syslogs_in_dir:
                warning("No syslog get from the local. Remote syslogs are get.")
                syslogs_in_dir = remote_syslogs_in_dir
            elif not syslogs_in_dir and not remote_syslogs_in_dir:
                warning("No syslog get from the local. No syslog get from the remote.")
        elif self.log_collector.rfs and self.other_master and not real_time:
            remote_syslogs_path, r_dir = self._get_syslogs_from_remote()
            syslogs_in_dir = [s_name for s_name in r_dir if s_name.startswith("SYSLOG")]
            if not syslogs_in_dir:
                error(f"No syslog files found from the directory '{remote_syslogs_path}' (content is {r_dir})")
                raise SyslogFilesNotFound
        if syslogs_in_dir:
            print(f"Syslogs in dir: {syslogs_in_dir}")
            self.logger.debug(f"Syslogs in dir: {syslogs_in_dir}")
            print_already_checked = []
            found_any = False
            for syslog_file in syslogs_in_dir:
                if found_any:
                    break
                try:
                    correct_bts_dir = remote_syslogs_path if self.other_master and not real_time or (
                                both_sides and "remote_" in syslog_file) else SyslogSearch.btslog_dir
                    if "remote_" in syslog_file:
                        syslog_file = syslog_file.strip("remote_")
                    with open(os.path.join(correct_bts_dir, syslog_file), "rb") as syslog:
                        found_lines = {}
                        for line in syslog:
                            line = self._decode_line(line)
                            if isinstance(expected_print, str):
                                if just_once:
                                    before = copy.deepcopy(found_lines)
                                found_lines.update(self.match_line_to_search_string_return_dict(
                                    line, found_lines, expected_print, syslog_file, print_eventlog, time_stamp,
                                    exclude_print))
                                if just_once and found_lines != before:
                                    found_any = True
                                    break
                            elif isinstance(expected_print, list):
                                for e_print in expected_print:
                                    if not just_once or (just_once and e_print not in print_already_checked):
                                        if just_once:
                                            before = copy.deepcopy(found_lines)
                                        found_lines.update(self.match_line_to_search_string_return_dict(
                                            line, found_lines, e_print, syslog_file, print_eventlog, time_stamp,
                                            exclude_print))
                                        if just_once and found_lines != before:
                                            print_already_checked.append(e_print)
                            else:
                                error("Expected syslog print should be string or list of strings not {}".format(
                                    type(expected_print)))
                                raise ScriptIssue
                        if found_lines:
                            file_and_search_results[syslog_file] = found_lines
                except UnicodeDecodeError as e:
                    file_and_search_results[syslog_file] = found_lines  # save currently found prints
                    self.logger.debug(f"Exception, save parsed to dict and return: {file_and_search_results}")
                    error(f"Syslog search was stopped after line '{line}', "
                          f"UnicodeDecodeError on file '{syslog_file}':{e}\n"
                          f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return file_and_search_results
        else:
            error(f"No syslog files found from the directory '{SyslogSearch.btslog_dir}'")
            raise SyslogFilesNotFound

    def match_line_to_search_string_return_dict(self, line, found_lines, expected_print, syslog_file, print_eventlog,
                                                time_stamp, exclude_print=None):
        """
        Matches expected print to line of syslog file and finds all lines matching the expected string.
        NOTE expected_print may be just string or regex.

        :param str line: Line of syslog file from where the print is searched.
        :param dict found_lines: Dictionary to which found expected prints are collected.
        :param str expected_print: Expected string to be found
        :param str syslog_file: Name of syslog file.
        :param bool print_eventlog: Prints found syslog line to eventlog. If set to False, will not print the line to
                                    eventlog
        :param time_stamp: Datetime object for example 1900-09-11 13:57:41.513000
        :param str exclude_print: If not None then checked if it is in the matched line
        :return dict: Dictionary where syslog filenames from where the prints were found are as keys. Another dictionary
                      as value to which search strings are as keys and found syslog lines in a list as value.
                      Empty dict if not found.
        """
        parse_syslog = re.compile(r"{}".format(expected_print))
        match = parse_syslog.match(line)
        time_of_line = None
        if exclude_print and exclude_print != expected_print and exclude_print in line:
            print(f"Exclude {exclude_print} is found from line '{line}', do not return the excluded print")
            return found_lines
        if line.find(expected_print) > -1 or match:  # checks is given is just string or if it is regex it matches
            if time_stamp is not None:
                time_of_line = self.get_time_of_line_as_datetime_object(line)
            if found_lines:
                if expected_print in found_lines.keys():
                    if line not in found_lines[expected_print] and (
                            (time_stamp is None) or (time_stamp is not None and time_of_line > time_stamp)):
                        found_lines[expected_print].append(line)
                        if print_eventlog:
                            info("Print '{}' is found from file '{}':\n{}".format(expected_print, syslog_file, line))
                        else:
                            self.logger.debug("Print '{}' is found from file '{}':\n{}".format(expected_print,
                                                                                               syslog_file, line))
                else:
                    if (time_stamp is None) or (time_stamp is not None and time_of_line > time_stamp):
                        found_lines[expected_print] = [line]
                        if print_eventlog:
                            info("Print '{}' is found from file '{}':\n{}".format(expected_print, syslog_file, line))
                        else:
                            self.logger.debug("Print '{}' is found from file '{}':\n{}".format(expected_print,
                                                                                               syslog_file, line))
            else:
                if (time_stamp is None) or (time_stamp is not None and time_of_line > time_stamp):
                    found_lines[expected_print] = [line]
                    if print_eventlog:
                        info("Print '{}' is found from file '{}':\n{}".format(expected_print, syslog_file, line))
                    else:
                        self.logger.debug("Print '{}' is found from file '{}':\n{}".format(expected_print, syslog_file,
                                                                                           line))
        return found_lines

    def find_bbmod_times_from_syslog(self):
        """
        Find BBMOD reset times from syslog. Searches for "Sending API2_RESET_REQ_MSG" and
        "Received API_RESET_RESP_MSG" prints
        """
        list_of_api2_messages = ["Sending API2_RESET_REQ_MSG", "Received API_RESET_RESP_MSG"]
        found_api2_messages = self.get_prints_from_syslogs(list_of_api2_messages, print_eventlog=True, time_stamp=None)
        timestamp_pattern = r"<([^>]+)>.*?(BBMOD_L-\d+)"
        bbmod_msgs = {}
        for syslog_file, found_dict in found_api2_messages.items():
            for message_type in list_of_api2_messages:
                for line in found_dict.get(message_type, []):
                    match = re.search(timestamp_pattern, line)
                    if match:
                        timestamp, bbmod_position = match.groups()
                        if bbmod_position not in bbmod_msgs:
                            bbmod_msgs[bbmod_position] = {"send": [], "receive": []}
                        if message_type == "Sending API2_RESET_REQ_MSG":
                            bbmod_msgs[bbmod_position]["send"].append(timestamp)
                        elif message_type == "Received API_RESET_RESP_MSG":
                            bbmod_msgs[bbmod_position]["receive"].append(timestamp)
                    else:
                        warning(f"Could not extract timestamp and BBMOD from line: {line}")
        if not bbmod_msgs:
            warning("No BBMOD reset messages found in syslog.")
            return
        timestamp_format = "%Y-%m-%dT%H:%M:%S.%fZ"
        for bbmod_position, msgs in bbmod_msgs.items():
            send_list = msgs["send"]
            receive_list = msgs["receive"]
            pair_count = min(len(send_list), len(receive_list))
            for i in range(pair_count):
                try:
                    send_time = datetime.datetime.strptime(send_list[i], timestamp_format)
                    receive_time = datetime.datetime.strptime(receive_list[i], timestamp_format)
                    reset_time = (receive_time - send_time).total_seconds()
                    info(
                        f"{bbmod_position}: reset time is {reset_time} seconds. "
                        f"Send time was {send_time}, "
                        f"receive time was {receive_time}.")
                except Exception as e:
                    warning(f"{bbmod_position}: Failed to parse timestamps: {e}")

    def check_if_test_fails(self, expected_print, fail_if_not_found, wait_for_print, timeout, unexpected_check=False):
        """
        Checks if test should fail or not.

        :param str expected_print: Searched string.
        :param bool fail_if_not_found: If set True will fail the test if missing syslog prints, otherwise just warns
                                       about missing syslog print.
        :param bool wait_for_print: If set True and prints not found, prints waited time.
        :param int timeout: Maximum time in seconds that was waited for syslog print to appear.
        :param bool unexpected_check: If set True checks if unexpected print is found and raises error if it is.
        :raise ExpectedSyslogPrintNotFound: When fail_if_not_found=True and syslog print is not found.
        :raise UnexpectedSyslogPrintFound: If unexpected_check=True and syslog print is found.
        """
        loop = "Loop {}: ".format(self.logger.loop + 1)
        if unexpected_check:
            if wait_for_print:
                error("{}Print '{}' was found from syslogs within {}s timeout, NOK".format(loop, expected_print,
                                                                                           timeout))
            else:
                error("{}Print '{}' was found from syslogs, NOK".format(loop, expected_print))
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise UnexpectedSyslogPrintFound
        else:
            if fail_if_not_found:
                if wait_for_print:
                    error("{}Print '{}' is NOT found from syslogs within {}s timeout".format(loop, expected_print,
                                                                                             timeout))
                else:
                    error("{}Print '{}' is NOT found from syslogs".format(loop, expected_print))
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                raise ExpectedSyslogPrintNotFound
            else:
                warning("{}Print '{}' is NOT found from syslogs".format(loop, expected_print))

    def check_if_syslog_print_is_found(self, expected_print, fail_if_not_found=False, print_eventlog=True,
                                       wait_for_print=False, interval=10, timeout=60, time_stamp=None):
        """
        Checks if expected print is found from syslog. User has multiple options how to use this check method.

        :param str/list expected_print: Expected string/list of strings to be found.
        :param bool fail_if_not_found: If set True will fail the test if print is not found. Default is False (missing
                                       syslog prints will not fail test).
        :param bool print_eventlog: If set to False, will not print found syslog print line to eventlog, prints just
                                    information that expected print was found. Default value is True, found syslog
                                    print line is printed to in total to eventlog.
        :param bool wait_for_print: If set True will wait user given time for expected print to appear in syslog.
                                    Default value is False and then will not wait for print, just checks if print is
                                    found.
        :param int interval: Time in seconds to wait between syslog print checks. Default value is 10s.
        :param int timeout: Maximum time in seconds that is waited for syslog print to appear. Default value is 60s.
        :param object time_stamp: Datetime object for example 1900-09-11 13:57:41.513000

        Some examples how to use this in robot-tests:
        Check If Syslog Print Is Found   BbmodReset
        Check If Syslog Print Is Found   Operation finished: [BbmodResetOperation]   fail_if_not_found=True
                                    ...  wait_for_print=True  timeout=180
        @{SYSLOG_LIST}          BbmodReset  ResetCounter  Detected most recent reset type was
        Check If Syslog Print Is Found  ${SYSLOG_LIST}    fail_if_not_found=True
        """
        if os.name != "nt":
            if wait_for_print:
                expected_syslogs = self.wait_for_syslog_containing_print(
                    expected_print, print_eventlog, interval, timeout)
            else:
                expected_syslogs = self.get_prints_from_syslogs(expected_print, print_eventlog, time_stamp)
            if isinstance(expected_print, str):
                if expected_syslogs:
                    if not print_eventlog:
                        info("Print '{}' is found from syslogs.".format(expected_print))
                else:
                    self.check_if_test_fails(expected_print, fail_if_not_found, wait_for_print, timeout)
            elif isinstance(expected_print, list):
                for exp in expected_print:
                    not_found = True
                    for syslog_file in expected_syslogs.keys():
                        if exp in expected_syslogs[syslog_file].keys():
                            not_found = False
                    if not_found:
                        self.check_if_test_fails(exp, fail_if_not_found, wait_for_print, timeout)
                    else:
                        if not print_eventlog:
                            info("Print '{}' is found from syslogs.".format(exp))
        else:
            warning("There is no support for Windows OS in taf syslog libraries, cannot Checks if expected\
                    print is found from syslog")

    def wait_for_syslog_containing_print(self, expected_print, print_eventlog, interval, timeout):
        """
        Waits for first appearance of the expected print in the SYSLOG.

        :param str/list expected_print: Expected syslog print to be found.
        :param bool print_eventlog: If set to False, will not print found syslog print line to eventlog.
                                    If True, found syslog print line is printed to in total to eventlog.
        :param interval: Seconds to wait for the next attempt.
        :param timeout: Timeout for the wait action to be finished if syslog print is not found.
        :return dict: Dictionary where syslog filenames from where the prints were found are as keys. Another dictionary
                      as value to which search strings are as keys and found syslog lines in a list as value.
                      None if not found.
        """
        while timeout > 0:
            found_logs = self.get_prints_from_syslogs(expected_print, print_eventlog, None, real_time=True)
            if len(found_logs) > 0:
                return found_logs
            sleep(interval)
            timeout -= interval
        return None

    @staticmethod
    def print_unexpected_not_found(unexpected_print):
        """
        Prints to eventlog that searched unexpected are not found.

        :param str/list unexpected_print: String or list of strings that should not be found from the syslog.
        """
        if isinstance(unexpected_print, str):
            info("Print '{}' was not found from syslogs, OK.".format(unexpected_print))
        elif isinstance(unexpected_print, list):
            for unexp in unexpected_print:
                info("Print '{}' was not found from syslogs, OK.".format(unexp))

    def check_if_unexpected_syslog_print(self, unexpected_print=None, print_eventlog=True, wait_for_print=False,
                                         interval=10, timeout=60, time_stamp=None):
        """
        Checks if unexpected syslog print is found. If print is found, will always fail the test.

        :param str/list unexpected_print: Unexpected string to be found.
        :param bool print_eventlog: If set to False, will not print found syslog print line to eventlog, prints just
                                    information that expected print was found. Default value is True, found syslog
                                    print line is printed to in total to eventlog.
        :param bool wait_for_print: If set True will wait user given time for expected print to appear in syslog.
                                    Default value is False and then will not wait for print, just checks if print
                                    is found.
        :param int interval: Time in seconds to wait between syslog print checks. Default value is 10s.
        :param int timeout: Maximum time in seconds that is waited for syslog print to appear. Default value is 60s.
        :param object time_stamp: Datetime object for example 1900-09-11 13:57:41.513000

        Some examples how to use this in robot-tests:
        Check If Unexpected Syslog Print   13 (ERPresetTypeApplicationBts)
        Check If Unexpected Syslog Print   reset type was 1 (ERPresetTypeApplication)  wait_for_print=True  timeout=180
        @{UNALLOWED_SYSLOGS}   4 (ERPresetTypeSpuriousReset)  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
        Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
        """
        if os.name != "nt":
            if unexpected_print is None:
                warning("User has not given any unexpected/unallowed syslog prints. Unexpected syslog print is not "
                        "checked.")
                return
            if wait_for_print:
                syslogs = self.wait_for_syslog_containing_print(unexpected_print, print_eventlog, interval, timeout)
            else:
                syslogs = self.get_prints_from_syslogs(unexpected_print, print_eventlog, time_stamp)
            if syslogs:
                if isinstance(unexpected_print, str):
                    self.check_if_test_fails(unexpected_print, False, wait_for_print, timeout, unexpected_check=True)
                elif isinstance(unexpected_print, list):
                    for exp in unexpected_print:
                        not_found = True
                        for syslog_file in syslogs.keys():
                            if exp in syslogs[syslog_file].keys():
                                not_found = False
                        if not_found:
                            self.print_unexpected_not_found(exp)
                        else:
                            self.check_if_test_fails(exp, False, wait_for_print, timeout, unexpected_check=True)
            else:
                self.print_unexpected_not_found(unexpected_print)
        else:
            warning("There is no support for Windows OS in taf syslog libraries, cannot Checks if "
                    "unexpected syslog print is found")

    def check_if_found_from_syslog(self, check_prints, was_found_txt=None, was_not_found_txt=None, print_eventlog=False,
                                   time_stamp=None, print_caught=True):
        """
        Checks if syslog prints are found. Prints user given text to eventlog if is found and another user given text
        if is found. Will not fail the test.

        :param str/list check_prints: Strings or list of strings to be found.
        :param str was_found_txt: Text that is printed to eventlog when print/some of prints is found from syslog.
        :param str was_not_found_txt: Text that is printed to eventlog when print/some of prints is not found from
                                      syslog.
        :param bool print_eventlog: Default is False, if True then prints to eventlog.
        :param object time_stamp: Datetime object for example 1900-09-11 13:57:41.513000
        :param bool print_caught: If True prints the searched prints that were found from the syslogs to eventlog and if
                                  no prints found prints what prints were searched but not found to eventlog.
        :return bool: True if found from syslog and False if not found from syslog.

        Some examples how to use this in robot-tests:
        Check If Found From Syslog   FirmwareActivationColdReset
        ...   was_found_txt=Firmware was updated when software was activated.
        ...   was_not_found_txt=Firmware was not updated when software was activated.


        @{CHECK_SYSLOGS}   FirmwareActivationColdReset  BW.bin updated  status = 70426 UPDATED
        Check If Found From Syslog   ${CHECK_SYSLOGS}
        ...   was_found_txt=Firmware was updated when software was activated.
        ...   was_not_found_txt=Firmware was not updated when software was activated.
        """
        if os.name != "nt":
            syslogs = self.get_prints_from_syslogs(check_prints, print_eventlog, time_stamp)
            if syslogs:
                if print_caught and was_found_txt:
                    caught_prints = SyslogSearch.get_caught_prints(syslogs, check_prints)
                    info("{} (Prints {} are found from the syslogs).".format(was_found_txt, caught_prints))
                    if "Firmware" in was_found_txt:
                        self._print_firmware_update_info(syslogs)
                elif was_found_txt:
                    info(was_found_txt)
                return True
            else:
                if print_caught and was_not_found_txt:
                    info("{} (Prints {} are NOT found from the syslogs.)".format(was_not_found_txt, check_prints))
                elif was_not_found_txt:
                    info(was_not_found_txt)
                return False
        else:
            warning("There is no support for Windows OS in taf syslog libraries, cannot Checks if \
                    unexpected syslog print is found")
            return None

    @staticmethod
    def _print_firmware_update_info(syslogs):
        """
        Prints firmware update info to eventlog.

        :param dict syslogs: Dictionary where syslog filenames from where the prints were found are as keys and found
                             lines as value.
        """
        for syslog_file in syslogs:
            for expected_string in syslogs[syslog_file]:
                expected_string_lines = "\n".join(syslogs[syslog_file][expected_string])
                info(f"Firmware updated print '{expected_string}' was found from file '{syslog_file}' from "
                     f"lines:\n{expected_string_lines}")

    @staticmethod
    def get_caught_prints(got_syslogs, searched_prints):
        """
        Gets which of the searched prints are found from syslogs to more readable way.
        :param dict got_syslogs: Found syslogs where file from where the text was found is as key and another dict as
        value where expected print as key and found prints in a list as value.
        :param list searched_prints: Prints that are parsed from syslog.
        :return str: Returns string where found prints are collected.
        """
        return_text = ""
        for caught_prints in got_syslogs.values():
            for caught_key in caught_prints:
                if caught_key in searched_prints:
                    if return_text:
                        if str(caught_key) not in return_text:
                            return_text = return_text + " / " + str(caught_key)
                    else:
                        return_text = str(caught_key)
        return return_text

    def start_syslog_print_search_to_background(self, search_prints=None, action=None, stop_when_found=False,
                                                print_eventlog=True):
        """
        Starts realtime syslog search to background.

        :param str/list search_prints: Prints user wants to monitor in realtime.
        :param str/list action: Action(s) that user wants to do if prints are found.
        :param bool stop_when_found: Stops realtime syslog search when print is found.
        :param bool print_eventlog: Print the found syslog to eventlog.
        """
        if search_prints is None:
            self.logger.debug("No prints given to be monitored from syslog in realtime. Syslog realtime monitoring"
                              " will not be started.")
            return
        if not self._sl_running:
            self._sl_running = True
            if self._sl_thread is None or not self._sl_thread.is_alive():
                info("Starting realtime syslog search to background.")
                self._sl_thread = Thread(target=self.loop_syslog_checks, name='Syslog-Thread',
                                         args=(search_prints, action, stop_when_found, print_eventlog))
                self._sl_thread.daemon = True  # stops when main thread stops
                self._sl_thread.start()

    def loop_syslog_checks(self, search_prints, action, stop_when_found, print_eventlog):
        """
        Loops syslog print checks. Gets value for parameters from start_syslog_print_search_to_background method.

        :param str/list search_prints: Prints user wants to monitor in realtime.
        :param str/list action: Action(s) that user wants to do if prints are found.
        :param bool stop_when_found: Stops realtime syslog search when print is found.
        :param bool print_eventlog: Print the found syslog to eventlog.
        """
        while self._sl_running:
            try:
                self.get_prints_from_syslogs_for_realtime(search_prints, print_eventlog)
                if self.found_syslog_prints:
                    if action:
                        info("Actions what to do if print found from syslog are not yet implemented.")
                    if stop_when_found:
                        self.stop_background_syslog_print_search()
                        BuiltIn().fatal_error("Stopping syslog print found. Stopping execution of the suite.")
            except (ValueError, FileNotFoundError, TimeoutError) as e:
                warning(f"Exception during syslog checks {e.__class__.__name__}:{e}\n"
                        f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                BuiltIn().sleep("5s")

    def _check_if_halt_prints_are_given(self):
        """This method checks if user has given some prints that will halt the test."""
        if not SyslogSearch.halt_variable_already_checked:
            all_suite_variables = BuiltIn().get_variables()
            self.logger.debug(f"All suite variables: {all_suite_variables}")
            if "${HALT_TEST}" in all_suite_variables or "@{HALT_TEST}" in all_suite_variables:
                self.logger.debug("HALT_TEST variable found from suite variables!")
                halt_test = BuiltIn().get_variable_value("${HALT_TEST}") if "${HALT_TEST}" in all_suite_variables else (
                    BuiltIn().get_variable_value("@{HALT_TEST}"))
                self.logger.debug(f"HALT_TEST value: {halt_test}")
                if isinstance(halt_test, str):
                    SyslogSearch.halt_prints = [halt_test]
                elif isinstance(halt_test, list):
                    SyslogSearch.halt_prints = halt_test
                else:
                    error("User has given HALT_TEST suite variable but it is not string or list of strings.")
                    raise ScriptIssue
            SyslogSearch.halt_variable_already_checked = True

    @staticmethod
    def _check_if_halt_print_in_syslog_and_kill_robot(line, syslog_file):
        """
        This method checks if halt prints are found from syslog and kills the robot if found.
        :param str line: Line of syslog.
        """
        for halt_print in SyslogSearch.halt_prints:
            parse_syslog = re.compile(f".*{halt_print}.*")
            match = parse_syslog.match(line)
            # checks is given is just string or if it is regex it matches
            if line.find(halt_print) > -1 or match:
                info(f"Test halting print {halt_print} was found from {syslog_file} from the line {line}.")
                HaltTest().halt_test()

    def get_prints_from_syslogs_for_realtime(self, expected_print, print_eventlog):
        """
        Searches SYSLOG files from the btslog dir and finds all lines matching the expected string(s).

        :param str or list expected_print: Expected string to be monitored or list of strings to be searched.
        :param bool print_eventlog: Prints found syslog line to eventlog. If set to False, will not print the line to
                                    eventlog.
        :raises UnicodeDecodeError: If there are bytes in SYSLOG that 'utf-8' codec can't decode.
        :return dict: Dictionary where syslog filenames from where the prints were found are as keys. Another dictionary
                      as value to which search strings are as keys and found syslog lines in a list as value.
                      Empty dict if not found.
        """
        self._check_if_log_dir_empty()
        self._check_if_syslog_folder_is_empty()
        syslogs_in_dir = [name for name in os.listdir(SyslogSearch.btslog_dir) if name.startswith("SYSLOG")]
        if not SyslogSearch.halt_prints:
            self._check_if_halt_prints_are_given()
        if syslogs_in_dir:
            for syslog_file in syslogs_in_dir:
                try:
                    s_file = os.path.join(SyslogSearch.btslog_dir, syslog_file)
                    if os.path.exists(s_file):
                        with open(s_file, "rb") as syslog:
                            for line in syslog:
                                line = self._decode_line(line)
                                if SyslogSearch.halt_prints:
                                    self._check_if_halt_print_in_syslog_and_kill_robot(line, syslog_file)
                                if isinstance(expected_print, str):
                                    self.match_line_to_search_string_realtime(line, expected_print, syslog_file,
                                                                              print_eventlog)
                                elif isinstance(expected_print, list):
                                    for e_print in expected_print:
                                        self.match_line_to_search_string_realtime(line, e_print, syslog_file,
                                                                                  print_eventlog)
                except UnicodeDecodeError as e:  # should never reach this
                    warning(f"Syslog search on file '{syslog_file}' was stopped after line '{line}', "
                            f"UnicodeDecodeError:{e}\n"
                            f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                except (FileNotFoundError, TypeError, AttributeError) as e:
                    warning(f"Problems when reading '{syslog_file}' in realtime: {e.__class__.__name__}:{e}")
                    info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def match_line_to_search_string_realtime(self, line, expected_print, syslog_file, print_eventlog):
        """
        Matches expected print to line of syslog file in real time and finds all lines matching the expected string.
        NOTE expected_print may be just string or regex. Updates dictionary where syslog filenames (from where the
        prints were found) are as keys and another dictionary as value to which search strings are as keys and found
        syslog lines in a list as value.

        :param str line: Line of syslog file from where the print is searched.
        :param str expected_print: Expected string to be found
        :param str syslog_file: Name of syslog file.
        :param bool print_eventlog: Prints found syslog line to eventlog. If set to False, will not print the line to
                                    eventlog
        """
        parse_syslog = re.compile(r"{}".format(expected_print))
        match = parse_syslog.match(line)
        if line.find(expected_print) > -1 or match:  # checks is given is just string or if it is regex it matches
            if self.found_syslog_prints:
                if syslog_file not in self.found_syslog_prints:
                    self.found_syslog_prints[syslog_file] = {expected_print: [line]}
                elif expected_print in self.found_syslog_prints[syslog_file].keys():
                    for saved_line in self.found_syslog_prints[syslog_file][expected_print]:
                        if saved_line in line and len(line) > len(saved_line):
                            # partial syslog print was previously saved, this check should not be needed, but...
                            self.logger.debug("Partial print was found earlier and saved {}, replace it with print {}"
                                              .format(saved_line, line))
                            self.found_syslog_prints[syslog_file][expected_print].remove(saved_line)
                            self.found_syslog_prints[syslog_file][expected_print].append(line)
                            info("Print '{}', found from file '{}':\n{}".format(
                                expected_print, syslog_file, line))
                    if line not in self.found_syslog_prints[syslog_file][expected_print]:
                        self.found_syslog_prints[syslog_file][expected_print].append(line)
                        if print_eventlog:
                            info("Print '{}', found from file '{}':\n{}".format(
                                expected_print, syslog_file, line))
                else:
                    expected_found_first_time = {expected_print: [line]}
                    self.found_syslog_prints[syslog_file].update(expected_found_first_time)
                    if print_eventlog:
                        info("Print '{}', found from file '{}':\n{}".format(
                            expected_print, syslog_file, line))
            else:
                expected_found_first_time = {expected_print: [line]}
                self.found_syslog_prints = {syslog_file: expected_found_first_time}
                if print_eventlog:
                    info("Print '{}', found from file '{}':\n{}".format(expected_print, syslog_file, line))

    def _get_last_line_from_syslog(self, syslog_file, last_attempt=None, syslog_folder=""):
        """Get last line from the syslog file."""
        if last_attempt:
            self.logger.debug(f"Line '{last_attempt}' was not parseable, trying to parse previous line")
        if not syslog_folder:
            syslog_folder = SyslogSearch.btslog_dir
        if not syslog_folder:
            info("Syslog folder was not saved to SyslogSearch.btslog_dir variable, using default folder '/tmp/btslog2'")
            syslog_folder = "/tmp/btslog2"
        if not syslog_file:
            error("Syslog file was not given.")
            raise ScriptIssue("Syslog file was not given.")
        previous_line = ""
        line = ""
        syslog_file_name = os.path.join(syslog_folder, syslog_file)
        if os.path.exists(syslog_file_name):
            with open(syslog_file_name, "rb") as syslog:
                for line in syslog:  # Syslog is huge, readlines() is too slow
                    line = self._decode_line(line)
                    if last_attempt and last_attempt in str(line) and previous_line:  # if previous line was found
                        line = previous_line
                        break
                    else:
                        previous_line = line
            return line
        else:
            warning(f"Syslog file '{syslog_file_name}' does not exist. Check if btslog is started correctly.")
            return None

    def get_time_of_last_syslog_line(self, bts_time=False):
        """
        Get time of last syslog line. Get time from the last line of the newest syslog file.

        :param bool bts_time: If set True, will return BTS time
        :return object: Datetime object for example 1900-09-11 13:57:41.513000. If bts_time is True, returns tuple
        """
        try:
            self._check_if_log_dir_empty()
            self._check_if_syslog_folder_is_empty()
            syslogs_in_dir = sorted([name for name in os.listdir(SyslogSearch.btslog_dir) if name.startswith("SYSLOG")],
                                    reverse=True)
            if syslogs_in_dir:
                syslog_file = syslogs_in_dir[0]
                line = self._get_last_line_from_syslog(syslog_file, syslog_folder=SyslogSearch.btslog_dir)
                time_from_log = self.get_time_of_line_as_datetime_object(line)
                if not time_from_log:
                    line = self._get_last_line_from_syslog(syslog_file, last_attempt=line,
                                                           syslog_folder=SyslogSearch.btslog_dir)
                    if line:
                        time_from_log = self.get_time_of_line_as_datetime_object(line)
                    else:
                        self.logger.debug("Unable to parse time from syslog, last_attempt (line: {})".format(line))
                        print("Unable to parse time from syslog, last_attempt (line: {})".format(line))
                if bts_time:
                    if time_from_log:
                        bts_time_from_log = self.get_time_of_line_as_datetime_object(line, bts_time=True)
                        if not bts_time_from_log:
                            line = self._get_last_line_from_syslog(syslog_file, last_attempt=line,
                                                                   syslog_folder=SyslogSearch.btslog_dir)
                            bts_time_from_log = self.get_time_of_line_as_datetime_object(line, bts_time=True)
                        if not bts_time_from_log:
                            print(f"Unable to parse BTS time from syslog (line: {line})")
                            self.logger.debug(f"Unable to parse BTS time from syslog (line: {line})")
                        return time_from_log, bts_time_from_log
                    else:
                        self.logger.debug(f"Unable to parse PC time from syslog (line: {line}) returning: None, None")
                        print(f"Unable to parse PC time from syslog (line: {line}) returning: None, None")
                        return None, None
                if time_from_log is None and SyslogSearch.retry_counter < 6:
                    self.logger.debug("Line {} was not parseable, retry counter {}".format(
                        line, SyslogSearch.retry_counter))
                    SyslogSearch.retry_counter += 1
                    self.get_time_of_last_syslog_line()
            else:
                error(f"No syslog files found from the directory '{SyslogSearch.btslog_dir}'")
                raise SyslogFilesNotFound
            return time_from_log
        except (ValueError, AttributeError, UnboundLocalError, FileNotFoundError, PermissionError,
                UnicodeDecodeError, TypeError, FileExistsError) as syslog_err:
            warning(f"Unable to parse timestamp from syslog. {syslog_err.__class__.__name__}:{syslog_err}\n"
                    f"{''.join(format_exception(type(syslog_err), syslog_err, syslog_err.__traceback__))}")
            return None

    def get_time_of_line_as_datetime_object(self, line, bts_time=False):
        """
        Get time stamp from the line of syslog file.

        :param str line: Line of syslog for example:  000962 11.09 13:57:42.587 [192.168.255.129] 14 FSP-223D-K-CCS
                                                      <2023-09-11T13:56:56.193751Z> F21-LogListener INF/LFS/LinuxSyslog,
                                                       cryptoagent[2201]: 9e0d72c0: key store (size 2) insert: 44:a0:bd:
                                                       1e:49:26, encipherment
        :param bool bts_time: If set True, will parse time from the line where time is in format
                              <2023-09-11T13:56:56.193751Z>
        :return object: Return datetime object
        """
        try:
            if bts_time:
                syslog_time_pattern = re.compile(r".*<(?P<syslog_time>\d+-\d+-\d+T\d+:\d+:\d+\.\d+)Z>.*")
            else:
                syslog_time_pattern = re.compile(r"\d+\s+(?P<syslog_time>\d+\.\d+\s+\d+:\d+:\d+\.\d+)\s+\[.*")
            match = syslog_time_pattern.match(line)
            if match:
                time_str = match.group("syslog_time")
                if bts_time:
                    self.logger.debug("Bts time in syslog line is: {}  (line '{}')".format(time_str, line))
                    print("Bts time in syslog line is: {}  (line '{}')".format(time_str, line))
                else:
                    self.logger.debug("Time in syslog line is: {}  (line '{}')".format(time_str, line))
                    print("Time in syslog line is: {}  (line '{}')".format(time_str, line))
                today = datetime.date.today()
                year = today.year  # for leap year, year information is needed
                if bts_time:
                    datetime_object = datetime.datetime.strptime(time_str, '%Y-%m-%dT%H:%M:%S.%f')
                else:
                    datetime_object = datetime.datetime.strptime(f"{year} {time_str}", '%Y %d.%m %H:%M:%S.%f')
                if datetime_object:
                    datetime_object = datetime_object.astimezone(pytz.UTC)
                self.logger.debug("Datetime object: {}".format(datetime_object))
                print("Datetime object: {}".format(datetime_object))
                return datetime_object
            else:
                self.logger.debug("Cannot parse time from the line '{}'".format(line))
                print("Cannot parse time from the line '{}'".format(line))
                return None
        except (ValueError, AttributeError) as syslog_err:
            error(f"Unable to parse timestamp from syslog: {syslog_err.__class__.__name__}:{syslog_err}\n"
                  f"{''.join(format_exception(type(syslog_err), syslog_err, syslog_err.__traceback__))}")
            return None

    def get_first_line_where_print_is_found(self, expected_print, print_eventlog=False):
        """
        Get first line of first SYSLOG where the given expected line is found.

        :param str expected_print: Expected string to be found NOTE it can also be a regex.
        :param bool print_eventlog: If set to False, will not print found syslog print line to eventlog.
        """
        found_logs = self.get_prints_from_syslogs(expected_print, print_eventlog, None)
        print(f"All syslogs and lines including {expected_print}:\n{found_logs}")
        if len(found_logs) > 0:
            syslogs = sorted(found_logs.keys())
            syslogs.sort(key=lambda x: int(x[x.find("_")+1:x.find(".")]))
            print(f"Logs sorted: {syslogs}")
            return found_logs[syslogs[0]][expected_print][0]
        else:
            error(f"'{expected_print}' was not found from the syslogs.")
            return None

    def chunk_list(self, input_list, size_of_chunck=100):
        """
        Split list to chunks of lines where each chunk is less than given size for example 100MiB.

        :param list input_list: List of lines.
        :param int size_of_chunck: Size of the chunk in MiB. Default value is 100.
        """
        self.logger.debug(f"Splitting list to chunks of list...")
        output_list = []
        o = []
        chars_in_chunk = 1048576 * size_of_chunck
        self.logger.debug(f"Max size for files is set to {size_of_chunck}MiB that is {chars_in_chunk} chars.")
        current_chars = 0
        for input_line in input_list:
            current_chars += len(input_line)
            o.append(input_line)
            if current_chars >= chars_in_chunk:
                self.logger.debug("Chunk ready")
                output_list.append(o)
                o = []
                current_chars = 0
        if o and o not in output_list:
            self.logger.debug("Add last, partial size chunk to list.")
            output_list.append(o)
        self.logger.debug(f"len output_list: {len(output_list)}")
        if len(output_list) > 1:
            self.logger.debug(f"Syslog should be split into {len(output_list)} files that are about {size_of_chunck}"
                              f"MiB each.")
        else:
            self.logger.debug(f"Syslog is less than {chars_in_chunk} chars ({size_of_chunck}MiB), no need to be split"
                              f" to smaller files.")
        return output_list

    def _write_cropped_syslogs_to_file(self, file_name, syslog_lines, extra_name="", e2e_startup_points=False):
        """
        Write cropped syslog to file.

        :parman str file_name: Name of the syslog file where the lines are saved.
        :param list syslog_lines: List of syslog lines.
        :param str extra_name: (OPTIONAL) Extra name for the file.
        :param e2e_startup_points: (OPTIONAL) True or False, default False.
        """
        save_path = os.path.join(self.logger.log_dir, "cropped_syslogs")
        if not os.path.exists(f"{save_path}"):
            self.logger.debug(f"Folder {save_path} doesn't exists, create it.")
            os.makedirs(f"{save_path}", exist_ok=True)
        if file_name:
            log_name = f"syslog_{file_name.replace(' ', '_')}{extra_name}.log"
            cropped_syslog = os.path.join(save_path, log_name)
        else:
            cropped_syslog = os.path.join(save_path, f"cropped_syslog{extra_name}.log")
        with open(cropped_syslog, "w") as log:
            for c_line in syslog_lines:
                log.write(f"{c_line}\n")
                if e2e_startup_points:
                    for e2e_print in pps_service_breakdown_check_points:
                        if e2e_print in c_line:
                            info(f"Print '{e2e_print}' was found from line (of file {cropped_syslog}):\n{c_line}")
                            if e2e_print not in SyslogSearch.e2e_dictionary:
                                SyslogSearch.e2e_dictionary[e2e_print] = [c_line]
                                SyslogSearch.e2e_dictionary[f"{e2e_print}_syslogfile"] = [cropped_syslog]
                            else:
                                if c_line not in SyslogSearch.e2e_dictionary[e2e_print]:
                                    SyslogSearch.e2e_dictionary[e2e_print].append(c_line)
                                else:
                                    self.logger.debug(f'Line {c_line} already in list. '
                                                      f'{SyslogSearch.e2e_dictionary[f"{e2e_print}"]}')
                                if cropped_syslog not in SyslogSearch.e2e_dictionary[f"{e2e_print}_syslogfile"]:
                                    SyslogSearch.e2e_dictionary[f"{e2e_print}_syslogfile"].append(cropped_syslog)
                                else:
                                    self.logger.debug(f'File {cropped_syslog} already in list. '
                                                      f'{SyslogSearch.e2e_dictionary[f"{e2e_print}_syslogfile"]}')
        info(f"Cropped syslog saved to file '{cropped_syslog}'")

    def _get_syslog_between_lines(self, start_line, end_line, file_name, write_to_file,
                                  syslog_folder_path):
        """
        Get syslog lines between two given lines.

        :param str start_line: Start line of syslog.
        :param str end_line: End line of syslog.
        :param str file_name: Name of the syslog file where the lines are saved if write_to_file is set to True.
        :param bool write_to_file: If set True, writes the found syslog lines to file, otherwise returns all lines as a
                                   list.
        :param str syslog_folder_path: Path to the syslog folder.
        """
        syslog_lines = []
        start_line_found = False
        end_line_found = False
        if not start_line or not end_line:
            info("No start_line nor end_line given, cannot get syslogs between the lines.")
            return None
        try:
            syslogs_in_dir = [name for name in os.listdir(syslog_folder_path) if name.startswith("SYSLOG")]
            print(f"All syslogs: {syslogs_in_dir}")
            if syslogs_in_dir:
                syslogs_in_dir.sort(key=lambda x: int(x[x.find("_") + 1:x.find(".")]))
                print(f"Logs sorted: {syslogs_in_dir}")
                e2e_startup_points = False
                if BuiltIn().get_variable_value("${E2E_CHECKPOINTS}"):
                    e2e_startup_points = True
                for syslog_file in syslogs_in_dir:
                    try:
                        with open(os.path.join(syslog_folder_path, syslog_file), "rb") as syslog:
                            for line in syslog:
                                line = self._decode_line(line)
                                if start_line in line:
                                    self.logger.debug(f"Start line '{start_line}' found from file '{syslog_file}'")
                                    start_line_found = True
                                if start_line_found:
                                    syslog_lines.append(line)
                                if end_line in line:
                                    self.logger.debug(f"End line '{end_line}' found from file '{syslog_file}'")
                                    end_line_found = True
                                    break  # break from reading this syslog file
                        if end_line_found:
                            break  # break from reading syslog files
                    except UnicodeDecodeError as e:
                        error(f"Syslog search was stopped after line '{line}', "
                              f"UnicodeDecodeError on file '{syslog_file}':{e}\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                if not start_line_found or not end_line_found:
                    warning(f"Given Start line('{start_line}')/End line('{end_line}') was not found from the syslogs. "
                            f"No cropped syslog is saved for {file_name}.")
                    return None
                if write_to_file:
                    chunks_for_files = self.chunk_list(syslog_lines)
                    if chunks_for_files and len(chunks_for_files) > 1:
                        info(f"Because there is a lot of syslog between start and end point, syslog needs to be split "
                             f"into multiple files ({len(chunks_for_files)} pcs) instead of one big file.")
                        i = 1
                        for chunk in chunks_for_files:
                            self._write_cropped_syslogs_to_file(file_name, chunk, f"_{i}",
                                                                e2e_startup_points=e2e_startup_points)
                            i += 1
                    else:
                        self._write_cropped_syslogs_to_file(file_name, syslog_lines,
                                                            e2e_startup_points=e2e_startup_points)
                    if e2e_startup_points and SyslogSearch.e2e_dictionary:
                        name_for_file = BuiltIn().get_variable_value("${EXTRA_INFO_FOR_LOOP}", default="")
                        path_for_the_file = os.path.join(self.logger.log_dir,
                                                         f"E2E_BTS_Startup_Checkpoint{name_for_file}.txt")
                        f = open(path_for_the_file, "w")
                        for e2e_point in pps_service_breakdown_check_points:
                            if e2e_point in SyslogSearch.e2e_dictionary:
                                # s_logs = list(SyslogSearch.e2e_dictionary[f'{e2e_point}_syslogfile'])
                                # s_logs.sort(key=lambda x: int(re.search(r"_(\d+)\.", x).group(1)))
                                syslog_files = list(SyslogSearch.e2e_dictionary[f'{e2e_point}_syslogfile'])
                                f.write(f"{e2e_point}\n\tWas found from lines (from files "
                                        f"{', '.join(j[j.rfind('/') + 1:] for j in syslog_files)}):\n")
                                for syslog_line in SyslogSearch.e2e_dictionary[e2e_point]:
                                    f.write(f"\t\t{syslog_line}\n")
                                f.write(f'{"-" * 100}\n')
                            else:
                                f.write(f"{e2e_point}\n\tWas not found.\n{'-' * 100}\n")
                    self.logger.debug("Clear SyslogSearch.e2e_dictionary")
                    SyslogSearch.e2e_dictionary = {}
                    if not self.log_collector:
                        self.log_collector = BuiltIn().get_library_instance("COLLECTLOGS")
                    save_path = os.path.join(self.logger.log_dir, "cropped_syslogs")
                    self.log_collector.zip_and_remove_log_folder(save_path, f"syslogs_{file_name.replace(' ', '_')}",
                                                                 compress_level=1)
                else:
                    return syslog_lines
            else:
                error(f"No SYSLOG files found from dir {syslog_folder_path}. No cropped syslog is saved for "
                      f"{file_name}.")
                return None
        except (FileNotFoundError, TypeError, AttributeError) as e:
            error(f"Problems when getting syslog between two line: {e.__class__.__name__}:{e} was raised.\n"
                  f"No cropped syslog is saved for {file_name}.\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return None

    def get_syslogs_between_two_lines(self, start_line, end_line, file_name="", write_to_file=True):
        """
        Get all syslog lines between two given lines.

        :param str start_line: Start line of syslog.
        :param str end_line: End line of syslog.
        :param str file_name: Name of the syslog file where the lines are saved if write_to_file is set to True.
        :param bool write_to_file: If set True, writes the found syslog lines to file, otherwise returns all lines as
                                   a list.
        :return list/None: List of syslog lines between start and end line if write_to_file is set to False.
        """
        try:
            self._check_if_log_dir_empty()
            self._check_if_syslog_folder_is_empty()
            if start_line is None or end_line is None:
                warning(f"Start line '{start_line}' or End line '{end_line}' was not get, cannot search syslog lines "
                        f"and cannot create cropped syslog file for {file_name}.")
                return None
            if not self.log_collector:
                self.log_collector = BuiltIn().get_library_instance("COLLECTLOGS")
            if self.log_collector.rfs or BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}",
                                                                      default=False):
                self.logger.debug("SyslogSearch.remote_syslog_end has value (also SyslogSearch.remote_syslog_start"
                                  " is set and folder than includes remote_syslogs  exists).")
                # self.logger.debug(f"Get current syslogs from remote environment ({self.collect_logs.remote_vm_ip}).")
                # self.log_collector.get_file_or_folder_by_scp(SyslogSearch.btslog_dir, self.collect_logs.remote_vm_ip,
                #                                              "ute", "", local_dir="/home/ute/logs/remote_syslog",
                #                                              update_name=False)
                self.logger.debug("Get all syslogs between start and end line of un tested remote environment.")
                remote_folder = "/home/ute/logs/remote_syslog"
                if os.path.exists("/home/ute/logs/remote_syslog/btslog2"):
                    remote_folder = "/home/ute/logs/remote_syslog/btslog2"
                self._get_syslog_between_lines(SyslogSearch.remote_syslog_start, SyslogSearch.remote_syslog_end,
                                               f"{file_name}_remote", write_to_file, remote_folder)
            self._get_syslog_between_lines(start_line, end_line, file_name, write_to_file, SyslogSearch.btslog_dir)
        finally:
            if self.log_collector.rfs or BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}",
                                                                      default=False):
                self.logger.debug("Clearing SyslogSearch remote variables and deleting fetched folder.")
                SyslogSearch.remote_syslog_start = None
                SyslogSearch.remote_syslog_end = None
                self.log_collector.remove_folder("/home/ute/logs/remote_syslog")

    def _check_if_last_line_is_valid(self, last_file, syslog_folder):
        """
        Check if latest syslog line is longer than 26 chars and if is return the line
        :param str last_file: Name of the latest syslog file.
        :param str syslog_folder: Folder where syslog are.
        """
        try_time = 0
        sane_length = False
        last_line = ""
        if not last_file:
            warning("Latest syslog file is not given to method _check_if_last_line_is_valid.")
            return ""
        while try_time < 6 and not sane_length:
            previous_line = last_line
            last_line = self._get_last_line_from_syslog(last_file, syslog_folder=syslog_folder)
            if last_line == previous_line:
                print(f"Syslog file {last_file} has not been updated. Check if there are newer files.")
                if "/home/ute/logs/remote_syslog" in syslog_folder:
                    self.logger.debug(f"Previous line was same as current latest line in file. Get folder "
                                      f"from {self.collect_logs.remote_vm_ip} again.")
                    syslog_folder, _ = self._get_syslogs_from_remote()
                last_file = self._get_latest_syslogs(syslog_folder)
                last_line = self._get_last_line_from_syslog(last_file, syslog_folder=syslog_folder)
            if len(last_line) < 26:
                self.logger.debug(f"Length of line '{last_line}' was less than 26 chars. Wait a second and try again")
                print(f"Length of line '{last_line}' was less than 26 chars. Wait a second and try again")
                BuiltIn().sleep("1s")
                try_time += 1
                if "/home/ute/logs/remote_syslog" in syslog_folder:
                    self.logger.debug(f"Length of line was not over 26 chars, not suitable line to be used. Get folder "
                                      f"from {self.collect_logs.remote_vm_ip} again.")
                    syslog_folder, _ = self._get_syslogs_from_remote()
            else:
                self.logger.debug(f"Length of line '{last_line}' is more than 26 chars. Exit loop.")
                print(f"Length of line '{last_line}' is more than 26 chars. Exit loop.")
                sane_length = True
        return last_line

    def _get_latest_syslogs(self, syslog_folder):
        """
        Get latest syslog file from the btslog log dir (/tmp/btslog2 or /tmp/btslog4 or /home/ute/logs/remote_syslog
        or some folder set with SYSLOG_FILE_PATH suite variable).
        """
        try:
            if not syslog_folder:
                syslog_folder = SyslogSearch.btslog_dir
            if not syslog_folder:
                self._check_if_log_dir_empty()
                syslog_folder = SyslogSearch.btslog_dir
            if not os.listdir(syslog_folder):
                warning(f"No content found from the dir {syslog_folder}")
                return None
            if "remote_syslog" in syslog_folder:
                syslog_folder, r_dir = self._get_syslogs_from_remote()
                syslogs_in_dir = [s_name for s_name in r_dir if s_name.startswith("SYSLOG")]
            else:
                syslogs_in_dir = [name for name in os.listdir(syslog_folder) if name.startswith("SYSLOG")]
            print(f"All syslogs in {syslog_folder}: {syslogs_in_dir}")
            self.logger.debug(f"All syslogs in {syslog_folder}: {syslogs_in_dir}")
            if syslogs_in_dir:
                syslogs_in_dir.sort(key=lambda x: int(x[x.find("_") + 1:x.find(".")]))
                print(f"Logs sorted: {syslogs_in_dir}")
                return syslogs_in_dir[-1]
            else:
                warning(f"No syslogs found from the dir {syslog_folder}.")
                return None
        except FileNotFoundError as e:
            warning(f"There were no syslogs, error was raised. {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return None

    def _get_lines_from_rfs(self):
        """
        Get latest syslog lines from the remote.
        """
        self.logger.debug("Get current syslogs from remote environment to test pc.")
        syslog_folder, _ = self._get_syslogs_from_remote()
        if SyslogSearch.remote_syslog_start is None:
            self.logger.debug("SyslogSearch.remote_syslog_start is None, set it.")
            latest_syslog_file_remote = self._get_latest_syslogs(syslog_folder)  # "/home/ute/logs/remote_syslog")
            if latest_syslog_file_remote:
                SyslogSearch.remote_syslog_start = self._check_if_last_line_is_valid(
                    latest_syslog_file_remote, syslog_folder)
                self.logger.debug("Remove collected remote_syslog -folder after getting remote start line")
                self.collect_logs.remove_folder("/home/ute/logs/remote_syslog")
            else:
                warning("Latest syslog file was not found from the remote environment. Cannot set remote_syslog_start.")
        else:
            self.logger.debug("SyslogSearch.remote_syslog_start has value so SyslogSearch.remote_syslog_end is"
                              " set.")
            latest_syslog_file_remote = self._get_latest_syslogs(syslog_folder)
            if latest_syslog_file_remote:
                SyslogSearch.remote_syslog_end = self._check_if_last_line_is_valid(
                    latest_syslog_file_remote, syslog_folder)
            else:
                warning("Latest syslog file was not found from the remote environment. Cannot set remote_syslog_end.")

    def get_last_line_from_syslogs(self):
        """
        Get last line from the latest syslog.

        :return str: Last line from the syslog.
        """
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        if self.collect_logs.rfs or BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}", default=False):
            self.logger.debug("Get current syslogs from remote environment...")
            self._get_lines_from_rfs()
        latest_syslog_file = self._get_latest_syslogs(SyslogSearch.btslog_dir)
        if latest_syslog_file:
            return self._check_if_last_line_is_valid(latest_syslog_file, SyslogSearch.btslog_dir)
        else:
            self.logger.debug("Last line was not found, return None")
            print("Last syslog line was not found, return None.")
            return None

    def check_if_print_in_syslog_and_if_is_warn_from_it(self, print_to_search=None, warn_print=None):
        """
        Check If Print In Syslog And If Is Warn From It

        :param str print_to_search: Print to search from syslog.
        :param str warn_print: Warn print if found from syslog.
        """
        if not print_to_search or not warn_print:
            error(f"Parameter print_to_search and warn_print are mandatory and should not be empty "
                  f"(print_to_search={print_to_search}, warn_print={warn_print}).")
            raise ScriptIssue("Empty parameters")
        found_prints = self.get_prints_from_syslogs(print_to_search, False, None)
        if found_prints:
            warning(f"{warn_print}")
        else:
            info(f"Print '{print_to_search}' was not found from the syslogs.")

    def check_if_print_in_syslog_and_if_is_error_from_it(self, print_to_search=None, error_print=None):
        """
        Check If Print In Syslog And If Is Error From It

        :param str print_to_search: Print to search from syslog.
        :param str error_print: Error print if found from syslog.
        """
        if not print_to_search:
            error(f"Parameter print_to_search and error_print are mandatory and should not be empty "
                  f"(print_to_search={print_to_search}, error_print={error_print}).")
            raise ScriptIssue("Empty parameters")
        found_prints = self.get_prints_from_syslogs(print_to_search, False, None)
        if found_prints:
            error_print = error_print if error_print else f"Error print '{print_to_search}' was found from the syslogs."
            error(error_print)
            raise UnexpectedSyslogPrintFound(f"{error_print}")
        else:
            info(f"Print '{print_to_search}' was not found from the syslogs.")

    def stop_background_syslog_print_search(self):
        """
        Stops syslog check loop and clears lists.
        """
        if self._sl_running:
            self._sl_running = False
            if self._sl_thread is not None:
                self._sl_thread.join()
                self._sl_thread = None  # Remove reference to thread
        BuiltIn().sleep("5s")  # needs to give a bit time to stop before clearing
        self.found_syslog_prints = []
        SyslogSearch.halt_variable_already_checked = False
        SyslogSearch.retry_counter = 0
        SyslogSearch.halt_prints = []
        info("Realtime syslog search stopped.")

    def add_delta_time_to_pc_timestamp(self, timestamp):
        """
        Add delta time between PC and BTS time to given timestamp.

        :param timedelta timestamp: Timestamp to which delta time is added.
        :return datetime: Timestamp with delta time added.
        """
        cell_regex = (
            r".*(Cell|Channel)Driver.*StateInfo..operationalState of.*has been changed from Disabled to Enabled")
        cell_enabled_line = self.get_first_line_where_print_is_found(cell_regex)
        info(f"Get times from cell enabled line:\n{cell_enabled_line}")
        if cell_enabled_line:
            pc_time = self.get_time_of_line_as_datetime_object(cell_enabled_line)
            bts_time = self.get_time_of_line_as_datetime_object(cell_enabled_line, bts_time=True)
            delta = bts_time - pc_time
            print(f"Delta time between PC and BTS time: {delta} (as integer {int(delta.total_seconds())})")
            info(f"Delta time between PC and BTS time added to given timestamp: {delta}")
            return timestamp + delta
        else:
            loop = "Loop {}: ".format(self.logger.loop + 1)
            error(
                f"{loop}Cell enabled line is not found from syslog (used regex: {cell_regex}). Could not get PC and "
                f"BTS time from syslog, cannot calculate delta time between PC and BTS times.")
            raise UnableToGetTimesFromSyslog
