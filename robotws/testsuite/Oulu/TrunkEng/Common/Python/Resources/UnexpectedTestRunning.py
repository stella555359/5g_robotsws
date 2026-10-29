"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import psutil
import subprocess
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import EnvironmentIssue
logger = BuiltIn().get_library_instance("LOG")


def check_robot_processes():
    """
    Check for any Robot Framework processes running on the system.
    If any are found, raise an EnvironmentIssue with details.
    """
    info("Checking running Robot Framework processes...")
    robot_processes = []
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        try:
            if 'robot' == proc.info['name'].lower() and any('robot' in part.lower() for part in proc.info['cmdline']):
                robot_processes.append(proc.info)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    expected_robot = BuiltIn().get_variable_value("${SUITE SOURCE}")
    if expected_robot:
        expected_robot = f"testsuite{expected_robot.split('testsuite')[1]}"
    print(f"Expected Robot Framework suite source: {expected_robot}")
    if robot_processes:
        if len(robot_processes) > 1:
            info(f"Multiple Robot Framework processes are found: {len(robot_processes)}")
            for r_proc in robot_processes:
                if expected_robot and expected_robot in r_proc['cmdline']:
                    print(f"Expected Robot Framework process is running: PID={r_proc['pid']}, Name={r_proc['name']}, "
                          f"Cmdline={' '.join(r_proc['cmdline'])}")
                else:
                    details = f"PID: {r_proc['pid']}, Name: {r_proc['name']}, Cmdline: {' '.join(r_proc['cmdline'])}"
                    error(f"Unexpected Robot Framework process is running: {details}")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            BuiltIn().set_suite_variable("${FAIL_FAST}", "${True}")
            BuiltIn().fatal_error("Unexpected Robot Framework processes are running. Stopping execution of the suite. "
                                  "Take contact to UTE/COSI.")
            raise EnvironmentIssue(f"Unexpected Robot Framework processes are running. Other test executions "
                                   f"detected on the reserved site. Take contact to UTE/COSI.")
        else:
            info(f"Only expected Robot process {expected_robot} is running.")
            print(f"PID={robot_processes[0]['pid']},Name={robot_processes[0]['name']}, Cmdline="
                  f"{robot_processes[0]['cmdline']}")
    else:
        print("No Robot Framework processes are found.")
        # raise EnvironmentIssue(f"No running Robot Framework processes.")


def get_all_processes(log_path, info_to_log_file):
    """
    Get a list of all running processes on the system.

    :param str log_path: Path to save the log file.
    :param str info_to_log_file: Name to the file.
    """
    try:
        subp = subprocess.Popen("ps auxf -w -w", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        outs, errs = subp.communicate(timeout=300)
        with open(log_path, 'a') as f:
            f.write(f"\n{'-'*10} {info_to_log_file} all running processes of control PC {'-'*10}\n")
            f.write(outs.decode())
    except subprocess.TimeoutExpired:
        info("TimeoutExpired when getting all processes of the control PC")
    except Exception as e:
        info(f"Exception when getting all processes of the control PC: {e.__class__.__name__}:{e}")
        info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
