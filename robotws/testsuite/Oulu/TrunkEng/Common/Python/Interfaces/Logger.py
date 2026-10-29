"""
:author: Pekka Lonnakko
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import logging
import os
import pathlib
import subprocess
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import EnvironmentIssue

test_case_folder = f"Test_logs_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
pathlib.Path(os.path.join(
    BuiltIn().get_variable_value("${OUTPUT DIR}"), test_case_folder)).mkdir(parents=True, exist_ok=True)
log_folder = os.path.join(BuiltIn().get_variable_value("${OUTPUT DIR}"), test_case_folder)
logging.addLevelName(logging.CRITICAL, 'ALARM')
eventlog_path = ""

eventlog = logging.getLogger("EventLog")
if not eventlog.handlers:
    formatter = logging.Formatter("%(asctime)s: %(levelname)s: %(message)s", "%Y-%m-%d %H:%M:%S")

    time = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_handler = logging.FileHandler(os.path.join(log_folder, f"event_log_{time}.log"))
    eventlog_path = os.path.join(log_folder, f"event_log_{time}.log")
    file_handler.setFormatter(formatter)

    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)

    eventlog.addHandler(file_handler)
    eventlog.addHandler(stream_handler)


def info(message):
    Logger.info(eventlog, message)


def warning(message):
    Logger.warning(eventlog, message)


def error(message):
    Logger.error(eventlog, message)


def alarm(message):
    Logger.alarm(eventlog, message)


class Logger:
    log_dir = log_folder
    suite_folder = log_folder
    debugger = None
    errors_and_warnings = []
    _loop = 0
    _loops = 0

    def __init__(self):
        self.time = None
        self.stream_handler = None
        self.eventlog_path = eventlog_path

    @property
    def loop(self):
        return Logger._loop

    @loop.setter
    def loop(self, loop_no):
        Logger._loop = loop_no

    @property
    def loops(self):
        return Logger._loops

    @loops.setter
    def loops(self, loops_no):
        Logger._loops = loops_no

    @staticmethod
    def get_path_of_test_log_folder():
        if 'Test_logs' not in Logger.log_dir:
            Logger.log_dir = log_folder
        return Logger.log_dir

    def create_admin_folder(self, folder_name="admin"):
        try:
            current_dir = self.get_path_of_test_log_folder()
            admin_folder = os.path.join(current_dir, folder_name)
            os.makedirs(admin_folder, exist_ok=True)
            return admin_folder
        except (OSError, AttributeError, TypeError) as e:
            print(f"Could not create_admin_folder because {e.__class__.__name__}:{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                Logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
            raise EnvironmentIssue(f"{e.__class__.__name__}:{e}")

    def get_path_of_eventlog(self):
        return self.eventlog_path

    def start_test_script_debug(self, test_case):
        try:
            test_name = BuiltIn().get_variable_value("${TEST NAME}").replace(' ', '_')
            info(f"Create folder {test_name}_{test_case}/loop_{Logger._loop + 1} to which logs will be collected")
            if test_name and test_name in Logger.log_dir:
                pathlib.Path(os.path.join(
                    log_folder, f"{test_name}_{test_case}", f"loop_{Logger._loop + 1}")).mkdir(parents=True,
                                                                                               exist_ok=True)
                Logger.log_dir = os.path.join(log_folder, f"{test_name}_{test_case}", f"loop_{Logger._loop + 1}")
            elif test_name and test_name not in Logger.log_dir and '/loop_' in Logger.log_dir:  # previous test
                pathlib.Path(os.path.join(
                    log_folder, f"{test_name}_{test_case}", f"loop_{Logger._loop + 1}")).mkdir(parents=True,
                                                                                               exist_ok=True)
                Logger.log_dir = os.path.join(log_folder, f"{test_name}_{test_case}", f"loop_{Logger._loop + 1}")
            else:
                pathlib.Path(os.path.join(
                    Logger.log_dir, f"{test_name}_{test_case}", f"loop_{Logger._loop + 1}")).mkdir(
                    parents=True, exist_ok=True)
                Logger.log_dir = os.path.join(Logger.log_dir, f"{test_name}_{test_case}", f"loop_{Logger._loop + 1}")
            self.time = datetime.now().strftime("%Y%m%d_%H%M%S")
            Logger.debugger = open(os.path.join(Logger.log_dir, f"test_script_debug_{self.time}.log"), "w")
        except (OSError, AttributeError, TypeError) as e:
            print(f"Could not start_test_script_debug because {e.__class__.__name__}:{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                Logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    @staticmethod
    def stop_test_script_debug():
        if Logger.debugger:
            Logger.debugger.close()
        Logger.debugger = None

    @staticmethod
    def info(event_log, message):
        event_log.info(message)
        if Logger.debugger:
            try:
                Logger.debugger.write(datetime.now().isoformat(sep=" ") + f" INFO: {message}\n")
            except (OSError, AttributeError, TypeError) as e:
                print(f"Could not write info to debug file because {e.__class__.__name__}:{e}\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                if "No space left on device" in str(e):
                    Logger.command_via_commandline("df -h")
                    BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    @staticmethod
    def alarm(event_log, message):
        event_log.critical(message)
        if Logger.debugger:
            try:
                Logger.debugger.write(datetime.now().isoformat(sep=" ") + f" ALARM: {message}\n")
            except (OSError, AttributeError, TypeError) as e:
                print(f"Could not write alarm to debug file because {e.__class__.__name__}:{e}\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                if "No space left on device" in str(e):
                    Logger.command_via_commandline("df -h")
                    BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    @staticmethod
    def error(event_log, message):
        event_log.error(message)
        e = datetime.now().isoformat(sep=" ") + f" ERROR: {message}\n"
        Logger.errors_and_warnings.append(e)
        if Logger.debugger:
            try:
                Logger.debugger.write(e)
            except (OSError, AttributeError, TypeError) as e:
                print(f"Could not write error to debug file because {e.__class__.__name__}:{e}\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                if "No space left on device" in str(e):
                    Logger.command_via_commandline("df -h")
                    BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    @staticmethod
    def warning(event_log, message):
        event_log.warning(message)
        w = datetime.now().isoformat(sep=" ") + f" WARNING: {message}\n"
        Logger.errors_and_warnings.append(w)
        if Logger.debugger:
            try:
                Logger.debugger.write(w)
            except (OSError, AttributeError, TypeError) as e:
                print(f"Could not write warning to debug file because {e.__class__.__name__}:{e}\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                if "No space left on device" in str(e):
                    Logger.command_via_commandline("df -h")
                    BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    @staticmethod
    def debug(message):
        if Logger.debugger:
            try:
                Logger.debugger.write(datetime.now().isoformat(sep=" ") + f" DEBUG: {message}\n")
            except (OSError, AttributeError, TypeError) as e:
                print(f"Could not write debug to debug file because {e.__class__.__name__}:{e}\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    @staticmethod
    def command_via_commandline(command, command_timeout=300):
        """Executes a command via command line and logs the output."""
        result = None
        try:
            result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                    timeout=command_timeout)
        except (subprocess.TimeoutExpired, subprocess.SubprocessError, subprocess.CalledProcessError, ValueError,
                AttributeError) as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        print(f"Command output: outs={result.stdout},  errs={result.stderr}")
        try:
            if result is None:
                return ""
            decoded_outs = result.stdout.decode('utf-8')
            info(f"Command '{command}' executed with output:\n{decoded_outs}")
        except UnicodeDecodeError as ex:
            info(f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            decoded_outs = result.stdout.decode('latin-1')
        return decoded_outs
