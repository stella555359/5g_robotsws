from pprint import pformat
import time
from robot.libraries.BuiltIn import BuiltIn, logger
from typing import Union
from SSHRMOD import SSHRMOD
from Fault_verifier import Fault_verifier
from variables_b3 import conn_level_map_b, fans_fetch, fans_store, tcs_fetch, tcs_store, \
    frmon_prepare, frmon_fan_set_setpoint, frmon_thermo_override
from helpers_12097 import convert_str_to_list, f_log
import common
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as gnbru


def prepare_tcs_json(ssh: SSHRMOD, rmod_type: str):
    ssh.run_command_on_rmod(tcs_fetch, rmod_type)
    ssh.run_command_on_rmod(tcs_store, rmod_type)


def prepare_fans_json(ssh: SSHRMOD, rmod_type: str):
    ssh.run_command_on_rmod(fans_fetch, rmod_type)
    ssh.run_command_on_rmod(fans_store, rmod_type)


def fetch_tcs(ssh: SSHRMOD, rmod_type: str):
    ssh.run_command_on_rmod('frmonShellClient 127.0.0.1 2000 /mnt/runtime/tcs_fetch.sh', rmod_type)


def store_tcs(ssh: SSHRMOD, rmod_type: str):
    ssh.run_command_on_rmod('frmonShellClient 127.0.0.1 2000 /mnt/runtime/tcs_store.sh', rmod_type)


def fetch_fans(ssh: SSHRMOD, rmod_type: str):
    ssh.run_command_on_rmod('frmonShellClient 127.0.0.1 2000 /mnt/runtime/fans_fetch.sh', rmod_type)


def store_fans(ssh: SSHRMOD, rmod_type: str):
    ssh.run_command_on_rmod('frmonShellClient 127.0.0.1 2000 /mnt/runtime/fans_store.sh', rmod_type)


def fault_1933_1934_AHLOA_toggle(ssh: SSHRMOD, trigger: Union[bool, str], prep=True, trig_1934=False,
                                 rmod_sn: str = None):
    '''Trigger FAN 1933 fault by frmon
    :param bool/str trigger: True/Trigger to trigger, False/Clear to clear;
    '''
    rmod_type = 'AHLOA'
    trigger = False if trigger == 'Clear' or not trigger else True  # cast bool or str type to bool
    trig = 'trigger' if trigger else 'clear'
    fid = '1934' if trig_1934 else '1933'
    set_setpoint = '0.3' if trig_1934 else '0'
    value = set_setpoint if trigger else '1'
    cmd_prep = frmon_prepare
    cmd_fan = frmon_fan_set_setpoint.format(value)
    temp = 'TEMPERATURE 110' if trig_1934 else 'TEMPERATURE 90'
    cmd_temp = frmon_thermo_override.format(temp)
    logger.debug(f'fault_{fid}_AHEGA_toggle {rmod_type=} {trigger=}\n{cmd_prep=} {cmd_fan=} {cmd_temp=}')
    # -----
    logger.info(f'{trig.capitalize()}ing fault_{fid} on {rmod_type=} on fan...', also_console=True)
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    if trigger and prep:
        ssh.run_frmon_command(cmd_prep, rmod_type)
    time.sleep(2)
    ssh.run_frmon_command(cmd_temp, rmod_type)
    time.sleep(2)
    ssh.run_frmon_command(cmd_fan, rmod_type)
    ssh.logout_from_rmod(rmod_type)
    logger.info(f'Fault_{fid} on {rmod_type=} on fan {trig}ed', also_console=True)
