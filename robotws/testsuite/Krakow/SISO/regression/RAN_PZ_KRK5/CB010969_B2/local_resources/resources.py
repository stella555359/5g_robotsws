import os
import psutil
import logging
import shlex
import subprocess
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.utilities.test_config import get_repository_path


def exec_cmd(cmd):
    splitted_cmd = shlex.split(cmd)
    logging.info("Execute:({})".format(splitted_cmd))
    proc = subprocess.Popen(splitted_cmd, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, shell=False)
    stdout, stderr = proc.communicate()
    ret_code = proc.returncode
    assert ret_code == 0, \
        "Error on command {}:ERR CODE={} STDERR={}"\
        .format(cmd, ret_code, stderr)
    logging.info("Return:{}".format(stdout))
    return stdout.decode('utf-8')


def get_running_processes():
    running_processes = []
    for process in psutil.process_iter(['pid', 'name', 'username', 'cmdline']):
        cmdline = " ".join(process.info['cmdline']) if process.info['cmdline'] else None
        running_processes.append({
            'pid': process.info['pid'],
            'name': process.info['name'],
            'username': process.info['username'],
            'cmdline': cmdline
        })
    return running_processes


def find_process_is_running(name="python3 SAS_Sim.py"):
    running_processes = get_running_processes()
    found_process = []
    for process in running_processes:
        if process['cmdline'] and name in process['cmdline']:
            found_process.append(f"PID: {process['pid']}, "
                                 f"Name: {process['name']}, "
                                 f"User: {process['username']}, "
                                 f"CMD: {process['cmdline']}")
    return True if found_process else False


def check_sas_process_is_running():
    if "integration" not in os.uname()[1]:
        if find_process_is_running():
            logger.log_info_to_console("SASSim process is running, IT'S OK")
        else:
            logger.log_warn_to_console("SASsim process is not running!")
            return False
    else:
        return True


def upload_swconfig_to_bts():
    gnb_du = GnbDuOperations()
    sw_config_path = '{}/testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010969_B2/local_resources/configs/swconfig.txt'\
        .format(get_repository_path())
    gnb_du.upload_swconfig(sw_config_path=sw_config_path)
