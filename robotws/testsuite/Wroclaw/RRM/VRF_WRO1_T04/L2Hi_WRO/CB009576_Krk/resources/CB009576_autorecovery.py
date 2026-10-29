"""
:copyright: Nokia Networks
:author: Damian Piasecki
:maintainer: Damian Piasecki
:contact: damian.piasecki@nokia.com
:team: MN_RAN_RD_VRF_KRK_11
"""

from random import choice
from datetime import datetime
from variables import *
from CB009576_keywords import get_default_log_dir
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.procedures.resources.python.bsh_interface.bsh_interface import execute_ssh_command_on_bsh
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_info,
    logger_console_info
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import (
    run_on_gnb,
    collect_gnb_snapshot
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.snapshot_utilities import (
    check_if_file_is_present_in_snapshot
)


def execute_command_on_gnb(cmd):
    """
    The function to execute the command on gNB.

    :param cmd: (str) Command to be executed
    :return: (str) Output of the command
    """
    logger_info(f"Executing command on gNB: {cmd}")
    rc, output = run_on_gnb(cmd=cmd)
    return output


def execute_command_on_thor(cmd):
    """
    The function to execute the command on Thor

    :param cmd: (str) Command to be executed
    :return: (str) Output of the command
    """
    logger_info(f"Executing command on Thor: {cmd}")
    TESTLINE = BuiltIn().get_variable_value("${tl}")
    GNB_SSH_CONNECTION_DETAILS = TESTLINE.gnbs[0].cu.oam_ssh_connection_details
    output = execute_ssh_command_on_bsh(smod_ssh_connection_parameters=GNB_SSH_CONNECTION_DETAILS,
                                        bsh_number="0:1",
                                        command=cmd)

    return output


def send_signal_for_memory_access_violation(pid):
    """
    The function to kill process on gNB with SIGSEGV signal

    :param pid: PID of process that should be killed
    """
    cmd = f"kill -s SIGSEGV {pid}"
    logger_console_info(f"Performing SIGSEGV kill: {cmd}")
    return execute_command_on_gnb(cmd=cmd)


def kill_process_on_thor(pid):
    """
    The function to kill process on Thor

    :param pid: PID of process that should be killed
    """
    cmd = f"kill -6 {pid}"
    logger_console_info(f"Killing process on Thor: {cmd}")
    return execute_command_on_thor(cmd=cmd)


def attach_prefix_to_container_name(container_name, prefix="lxc.*"):
    """
    The function to attach prefix to Marlin container in order to grep proper process

    :param container_name: (str) Marlin container name
    :param prefix: (str) prefix to add to a Marlin container name
    :return: (str) Marlin container name with prefix
    """
    container_name = prefix + container_name
    return container_name


def get_process_basename_from_process_command(process_command):
    """
    The function to get process basename

    :param process_command: (str) Full process name in gNB system
    :return: (str) Process basename
    """
    process = os.path.basename(process_command.split()[0])
    return process


def select_process_randomly(process_list):
    """
    The function to get process to be crashed randomly

    :param process_list: (list) List of all processes
    :return: (str) Process to be crashed
    """
    process = choice(process_list)
    logger_console_info(f"Selected process: {process}")
    return process


def get_all_pids_of_process(process, thor=None):
    """
    The function to get all PIDs associated with specified process

    :param process: (str) Process for which PIDs should be searched
    :param thor: (str) Thor card number on which PIDs should be searched
    :return: (list) List of all PIDs associated with specified process
    """
    if thor:
        output = execute_command_on_thor(cmd=f"pgrep -f \"{process}\"")
    else:
        output = execute_command_on_gnb(cmd=f"pgrep -f \"{process}\"")
    if output:
        pids = output.splitlines()
    else:
        raise Exception(f"Searched process {process} not found on gNB")
    logger_console_info(f"Found {len(pids)} pids associated to process {process}: {pids}")
    return pids


def select_pid_randomly(pids):
    """
    The function to select PID randomly

    :param pids: (list) List of all PIDs
    :return: (str) Selected PID
    """
    pid = choice(pids)
    logger_console_info(f"Selected PID: {pid}")
    return pid


def collect_crash_snapshot(process, pid):
    """
    The function to collect snapshot after crash procedure

    :param process: (str) Process name
    :param pid: (str) PID of process

    :return: (str) Path to the crash snapshot
    """
    log_dir = get_default_log_dir()
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S%z')
    snapshot_path = os.path.join(log_dir, f"snapshot_{process}_{pid}_{timestamp}.zip")
    collect_gnb_snapshot(output_filepath=snapshot_path)
    return snapshot_path


def get_rest_loop_count_value_from_gnb():
    """
    The function to get the value of reset loop counter on gNB

    :return: (str) current value of reset loop counter on gNB
    """
    rc, output = run_on_gnb(cmd="ddal -s ddal_boot_get_reset_loop_count | tail -n 1 | cut -d'=' -f 2")
    return output


def set_rest_loop_count_value_from_gnb(value=0):
    """
    The function to set the value of reset loop counter on gNB
    :param value: (int) value to set for reset loop counter on gNB
    """
    run_on_gnb(cmd="ddal -s ddal_boot_set_reset_loop_count" + f" {value}")


def check_if_loop_count_value_is_correct(expected_value=1):
    """
    The function to verify if reset loop counter on gNB is equal to expected value
    :param expected_value: (int) expected value of reset loop counter
    """
    actual_value = get_rest_loop_count_value_from_gnb()

    if int(actual_value) != int(expected_value):
        raise Exception(f"Number of resets is incorrect.\nExpected: {expected_value}\nActual: {actual_value}")


def verify_if_crash_file_is_present_in_snapshot(pid, snapshot_zip_path, process=None, from_thor=False,
                                                is_non_restartable=False, is_container=False):
    """
    The function to verify if crash file is present in snapshot

    :param pid: (str) PID of process
    :param snapshot_zip_path: (list) PID of process
    :param process: (str) Process name
    :param from_thor: (bool) Checks if thor has been crashed
    :param is_non_restartable: (bool) Checks if process is non-restartable
    :param is_container: (bool) Checks if process was related to Marlin container
    :return: (list) List of crash files
    """
    log_dir = get_default_log_dir()
    if process:
        if len(process) > 16:
            process = process[0:16]
    if from_thor:
        python_processes = PYTHON_PROCESS_LIST
        if process in python_processes:
            pattern = rf'core\.python3\.\d+\.\d+\.{pid}\.\d+\.gz'
        else:
            pattern = rf'core\.{process}.*\..*\.{pid}\.\d+\.gz'
    elif is_non_restartable:
        pattern = rf'core\.{process}\.{process}.*\..*\.{pid}\.\d+\.gz'
    elif is_container:
        pattern = rf'0x1011_memfd:lxc-attach_{pid}_\d+_\d+\.core\.xz\.p7'
    else:
        pattern = rf'{process}.*_{pid}_6.*core\.xz\.p7'
    file_list = check_if_file_is_present_in_snapshot(pattern=pattern, file_name=snapshot_zip_path, output_dir=log_dir)
    if len(file_list) > 0:
        logger_console_info(f"Saved files from snapshot: {file_list}")
    else:
        raise Exception(f"Did not find any files matching pattern: {pattern}")
    return file_list
