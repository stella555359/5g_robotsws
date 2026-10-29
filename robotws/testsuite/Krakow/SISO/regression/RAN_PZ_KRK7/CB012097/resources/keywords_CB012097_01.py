from pprint import pformat
import time
from robot.libraries.BuiltIn import BuiltIn, logger
from typing import Union
from SSHRMOD import SSHRMOD
from Fault_verifier import Fault_verifier
from variables01 import conn_level_map_a, conn_level_map_b, fans_fetch, fans_store, tcs_fetch, tcs_store, \
    frmon_prepare, frmon_fan_set_setpoint, frmon_thermo_override, fans_fetch_legacy, fans_store_legacy
from helpers_12097 import convert_str_to_list, f_log
import common
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as gnbru
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


def is_legacy_sw(sw_version: str):
    if not sw_version:
        return False
    bts_operations = GnbDuOperations()
    sw_version_current = bts_operations.get_bts_sw_version(bts_id=0, du_id=0)
    logger.info(f'{sw_version_current = }\n{sw_version = }\n{sw_version_current < sw_version = }')
    return sw_version_current < sw_version


def prepare_tcs_json(ssh: SSHRMOD, rmod_type: str):
    ssh.run_command_on_rmod(tcs_fetch, rmod_type)
    ssh.run_command_on_rmod(tcs_store, rmod_type)


def prepare_fans_json(ssh: SSHRMOD, rmod_type: str, sw_version=None):
    ''' param sw_version: default None to use only basic version
        or sw version below which is legacy method used, e.g. "SBTS00_ENB_9999_260128_000003".
        Do not use SBTS00, simple string comparison is used
    '''
    if is_legacy_sw(sw_version):
        ssh.run_command_on_rmod(fans_fetch_legacy, rmod_type)
        ssh.run_command_on_rmod(fans_store_legacy, rmod_type)
    else:
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


def fault_1932_AHFIG_toggle(ssh: SSHRMOD, trigger: Union[bool, str],
                            skip_reboot=False, rmod_sn: str = None):
    '''Trigger FAN 1932 fault by json
    :param bool/str trigger: True/Trigger to trigger, False/Clear to clear;
    '''
    lib_ru = BuiltIn().get_library_instance('gnbru')
    rmod_type = 'AHFIG'
    radio_unit_id = common.get_rmod_id(rmod_type, rmod_sn)
    trigger = False if trigger == 'Clear' or not trigger else True  # cast bool or str type to bool
    trig = 'trigger' if trigger else 'clear'
    param = 'speedResponseDetectionAllowed'
    value = not trigger
    logger.debug(f'fault_1932_AHFIG_toggle {rmod_type=} {trigger=}')
    # -----
    logger.info(f'{trig.capitalize()}ing fault_1932 on {rmod_type=} on all fans...', also_console=True)
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    fetch_fans(ssh, rmod_type)
    ssh.edit_rmod_json({param: value}, rmod_type, '/ram/fans.json', 'fans_instance')
    store_fans(ssh, rmod_type)
    logger.info(f'Fault_1932 on {rmod_type=} on all 2 fans {trig}ed', also_console=True)
    ssh.logout_from_rmod(rmod_type)
    if not skip_reboot:
        radio_type = 'asirmod' if common.is_asi_hub(rmod_type, rmod_sn) else 'rmod'
        logger.info(f'Going to reboot {rmod_type=} with id:{radio_unit_id} by Admin...', also_console=True)
        gnbru.reset_radio_unit(lib_ru, radio_unit_id=radio_unit_id, radio_type=radio_type)
        logger.info(f'... {rmod_type=} rebooted', also_console=True)


def fault_1933_1934_AHEGA_toggle(ssh: SSHRMOD, trigger: Union[bool, str], prep=True, trig_1934=False,
                                 rmod_sn: str = None):
    '''Trigger FAN 1933 fault by frmon
    :param bool/str trigger: True/Trigger to trigger, False/Clear to clear;
    '''
    rmod_type = 'AHEGA'
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


def fault_1933_AHFIG_toggle(ssh: SSHRMOD, trigger: Union[bool, str], temp_low=False,
                            rmod_sn: str = None):
    '''Trigger FAN 1933 fault by frmon
    :param bool/str trigger: True/Trigger to trigger, False/Clear to clear;
    '''
    rmod_type = 'AHFIG'
    trigger = False if trigger == 'Clear' or not trigger else True  # cast bool or str type to bool
    trig = 'trigger' if trigger else 'clear'
    value = '0' if trigger else '1'
    cmd_prep = frmon_prepare
    cmd_fan = frmon_fan_set_setpoint.format(value)
    temp = 'TEMPERATURE 62' if temp_low else 'TEMPERATURE 100'
    cmd_temp = frmon_thermo_override.format(temp)
    logger.debug(f'fault_1933_AHFIG_toggle {rmod_type=} {trigger=}\n{cmd_prep=} {cmd_fan=} {cmd_temp=}')
    # -----
    logger.info(f'{trig.capitalize()}ing fault_1933 on {rmod_type=} on fan...', also_console=True)
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    if trigger:
        ssh.run_frmon_command(cmd_prep, rmod_type)
        time.sleep(5)
        ssh.run_frmon_command(cmd_temp, rmod_type)
    time.sleep(5)
    ssh.run_frmon_command(cmd_fan, rmod_type)
    ssh.logout_from_rmod(rmod_type)
    logger.info(f'Fault_1933 on {rmod_type=} on fan {trig}ed', also_console=True)


def fault_1934_AHFIG_toggle(ssh: SSHRMOD, trigger: Union[bool, str],
                            rmod_sn: str = None):
    '''Trigger FAN 1934 fault by frmon
    :param bool/str trigger: True/Trigger to trigger, False/Clear to clear;
    '''
    rmod_type = 'AHFIG'
    trigger = False if trigger == 'Clear' or not trigger else True  # cast bool or str type to bool
    trig = 'trigger' if trigger else 'clear'
    value = '0.3' if trigger else '1'
    cmd_prep = frmon_prepare
    cmd_fan = frmon_fan_set_setpoint.format(value)
    cmd_temp = frmon_thermo_override.format('TEMPERATURE 90')
    logger.debug(f'fault_1934_AHFIG_toggle {rmod_type=} {trigger=}\n{cmd_prep=} {cmd_fan=} {cmd_temp=}')
    # -----
    logger.info(f'{trig.capitalize()}ing fault_1934 on {rmod_type=} on fan...', also_console=True)
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    if trigger:
        ssh.run_frmon_command(cmd_prep, rmod_type)
        time.sleep(5)
        ssh.run_frmon_command(cmd_temp, rmod_type)
    time.sleep(5)
    ssh.run_frmon_command(cmd_fan, rmod_type)
    ssh.logout_from_rmod(rmod_type)
    logger.info(f'Fault_1934 on {rmod_type=} on fan {trig}ed', also_console=True)
