from pprint import pformat
from time import sleep
from robot.libraries.BuiltIn import BuiltIn, logger
from typing import Union
from SSHRMOD import SSHRMOD
from Fault_verifier import Fault_verifier
from variables02 import APHA_swconfig, APHG_swconfig, tcs_fetch, tcs_store
from helpers_12097 import convert_str_to_list, f_log
import common
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as gnbru

swconfig = {'APHA': APHA_swconfig, 'APHG': APHG_swconfig}


def prepare_tcs(ssh: SSHRMOD, rmod_type: str, tcs_fetch=tcs_fetch, tcs_store=tcs_store):
    ssh.run_command_on_rmod(tcs_fetch, rmod_type)
    ssh.run_command_on_rmod(tcs_store, rmod_type)


def fetch_tcs(ssh: SSHRMOD, rmod_type: str):
    ssh.run_command_on_rmod('frmonShellClient 127.0.0.1 2000 tcs_fetch.sh', rmod_type)


def store_tcs(ssh: SSHRMOD, rmod_type: str):
    ssh.run_command_on_rmod('frmonShellClient 127.0.0.1 2000 tcs_store.sh', rmod_type)


def prepare_rmod_swconfig(ssh: SSHRMOD, rmod_type: str, swconfig=swconfig):
    ssh.reset_rmod_swconfig(swconfig_flags=swconfig.get(rmod_type), rmod_type=rmod_type)


def fault_1932_toggle(ssh: SSHRMOD, rmod_type: str, fans: str, trigger: Union[bool, str],
                      skip_reboot=False, rmod_sn: str = None):
    '''Trigger FAN 1932 fault by RMOD rad params

    :param str rmod_type: 'APHA' or 'APHG';
    :param str fans: any string like '2', '1-3', '3,4, 2', etc.;
    :param bool/str trigger: True/Trigger to trigger, False/Clear to clear;
    :param bool skip_reboot: True or False;
    '''
    supported_rmods = {'APHA', 'APHG'}
    supported_fans = set(range(1, 4+1))
    rad_param_pattern = '0x0012001_'
    fan_list = convert_str_to_list(fans)
    if not set(fan_list).issubset(supported_fans):
        raise ValueError(f'Given {fan_list=} isn\'t supported, {supported_fans=}')
    if rmod_type not in supported_rmods:
        raise NotImplementedError(f'{rmod_type} not supported, should be: {supported_rmods}')
    skip_reboot = True if skip_reboot else False
    trigger = False if trigger == 'Clear' or not trigger else True  # cast bool or str type to bool
    trig = 'trigger' if trigger else 'clear'
    trigger = '1' if trigger else '0'
    '''
    0x00120010 = 0 //for fan1
    0x00120011 = 0 //for fan2
    0x00120012 = 0 //for fan3
    0x00120013 = 0 //for fan4
    '''
    rad_list = [rad_param_pattern.replace('_', str(fan-1)) for fan in fan_list]
    logger.debug(f'fault_1932_toggle {rmod_type=} {fans=} {trigger=} {skip_reboot=}' +
                 f' {supported_fans=} {fan_list=} {rad_list=}')
    # -----
    logger.info(f'{trig.capitalize()}ing fault_1932 on {rmod_type=} on fans: {fan_list}...', also_console=True)
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    ssh.edit_rmod_rad_params(rad_params=rad_list, value=trigger, rmod_type=rmod_type)
    ssh.logout_from_rmod(rmod_type)
    if not skip_reboot:
        lib_ru = BuiltIn().get_library_instance('gnbru')
        radio_unit_id = common.get_rmod_id(rmod_type, rmod_sn)
        radio_type = 'asirmod' if common.is_asi_hub(rmod_type, rmod_sn) else 'rmod'
        logger.info(f'Going to reboot {rmod_type=} with id:{radio_unit_id} by Admin...', also_console=True)
        gnbru.reset_radio_unit(lib_ru, radio_unit_id=radio_unit_id, radio_type=radio_type)
        logger.info(f'... {rmod_type=} rebooted', also_console=True)
    logger.info(f'Fault_1932 on {rmod_type=} on fans: {fan_list} {trig}ed', also_console=True)


def fault_1933_APHA_toggle(ssh: SSHRMOD, rmod_type: str, fans: str, trigger: Union[bool, str],
                           skip_reboot=False, rmod_sn: str = None):
    '''Trigger FAN 1933 fault by RMOD rad params

    :param str rmod_type: 'APHA';
    :param str fans: any string like '2', '1-3', '3,4, 2', etc.;
    :param bool/str trigger: True/Trigger to trigger, False/Clear to clear;
    :param bool skip_reboot: True or False;
    '''
    supported_rmods = {'APHA'}
    supported_fans = set(range(1, 4+1))
    rad_param_pattern = '0x0012002_'
    fan_list = convert_str_to_list(fans)
    if not set(fan_list).issubset(supported_fans):
        raise ValueError(f'Given {fan_list=} isn\'t supported, {supported_fans=}')
    if rmod_type not in supported_rmods:
        raise NotImplementedError(f'{rmod_type} not supported, should be: {supported_rmods}')
    skip_reboot = True if skip_reboot else False
    trigger = False if trigger == 'Clear' or not trigger else True  # cast bool or str type to bool
    trig = 'trigger' if trigger else 'clear'
    trigger = '1' if trigger else '0'
    '''
    0x00120020 = 0 //for fan0
    0x00120021 = 0 //for fan1
    0x00120022 = 0 //for fan2
    0x00120023 = 0 //for fan3
    '''
    rad_list = [rad_param_pattern.replace('_', str(fan-1)) for fan in fan_list]
    # -----
    logger.info(f'{trig.capitalize()}ing fault_1933 on {rmod_type=} on fans: {fan_list}...', also_console=True)
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    ssh.edit_rmod_rad_params(rad_params=rad_list, value=trigger, rmod_type=rmod_type)
    ssh.logout_from_rmod(rmod_type)
    if not skip_reboot:
        lib_ru = BuiltIn().get_library_instance('gnbru')
        radio_unit_id = common.get_rmod_id(rmod_type, rmod_sn)
        radio_type = 'asirmod' if common.is_asi_hub(rmod_type, rmod_sn) else 'rmod'
        logger.info(f'Going to reboot {rmod_type=} with id:{radio_unit_id} by Admin...', also_console=True)
        gnbru.reset_radio_unit(lib_ru, radio_unit_id=radio_unit_id, radio_type=radio_type)
        logger.info(f'... {rmod_type=} rebooted', also_console=True)
    logger.info(f'Fault_1933 on {rmod_type=} on fans: {fan_list} {trig}ed', also_console=True)


def fault_1933_APHG_toggle(ssh: SSHRMOD, rmod_type: str, fans: str, trigger: Union[bool, str],
                           rmod_sn: str = None):
    '''Trigger FAN 1933 fault by devmem command

    :param str rmod_type: 'APHG';
    :param str fans: any string like '2', '1-3', '3,4, 2', etc.;
    :param bool/str trigger: True/Trigger to trigger, False/Clear to clear;
    '''
    supported_rmods = {'APHG'}
    supported_fans = set(range(1, 4+1))
    param_pattern = 'devmem 0xa00020_c 32 '
    fan_list = convert_str_to_list(fans)
    if not set(fan_list).issubset(supported_fans):
        raise ValueError(f'Given {fan_list=} isn\'t supported, {supported_fans=}')
    if rmod_type not in supported_rmods:
        raise NotImplementedError(f'{rmod_type} not supported, should be: {supported_rmods}')
    trigger = False if trigger == 'Clear' or not trigger else True  # cast bool or str type to bool
    trig = 'trigger' if trigger else 'clear'
    trigger = '666' if trigger else '0'
    '''
    devmem 0xa000200c 32 666// for fan0
    devmem 0xa000201c 32 666// for fan1
    devmem 0xa000202c 32 666// for fan2
    devmem 0xa000203c 32 666// for fan3
    '''
    cmd_list = [param_pattern.replace('_', str(fan-1)) + trigger for fan in fan_list]
    logger.debug(f'fault_1933_APHG_toggle {rmod_type=} {fans=} {trigger=}' +
                 f' {supported_fans=} {fan_list=} {cmd_list=}')
    # -----
    logger.info(f'{trig.capitalize()}ing fault_1933 on {rmod_type=} on fans: {fan_list}...', also_console=True)
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    for cmd in cmd_list:
        ssh.run_command_on_rmod(cmd, rmod_type=rmod_type)
    logger.info(f'Fault_1933 on {rmod_type=} on fans: {fan_list} {trig}ed', also_console=True)
    ssh.logout_from_rmod(rmod_type)


def fault_1934_APHG_toggle(ssh: SSHRMOD, trigger: Union[bool, str],
                           skip_reboot=False, rmod_sn: str = None):
    '''Trigger FAN 1934 fault by RMOD rad param, impacts all 4 fans.

    :param bool/str trigger: True/Trigger to trigger, False/Clear to clear;
    :param bool skip_reboot: True or False;
    '''
    rmod_type = 'APHG'
    rad_param = '0x0B'
    trigger = False if trigger == 'Clear' or not trigger else True  # cast bool or str type to bool
    trig = 'trigger' if trigger else 'clear'
    trigger = '1' if trigger else '0'
    skip_reboot = True if skip_reboot else False
    '''
    0x0B = 1; //this value impacts on all the fans.
    '''
    logger.debug(f'fault_1934_APHG_toggle {rmod_type=} {trigger=} {skip_reboot=}')
    # -----
    logger.info(f'{trig.capitalize()}ing fault_1934 on {rmod_type=} on all 4 fans...', also_console=True)
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    ssh.edit_rmod_rad_params(rad_params=rad_param, value=trigger, rmod_type=rmod_type)
    ssh.logout_from_rmod(rmod_type)
    if not skip_reboot:
        lib_ru = BuiltIn().get_library_instance('gnbru')
        radio_unit_id = common.get_rmod_id(rmod_type, rmod_sn)
        radio_type = 'asirmod' if common.is_asi_hub(rmod_type, rmod_sn) else 'rmod'
        logger.info(f'Going to reboot {rmod_type=} with id:{radio_unit_id} by Admin...', also_console=True)
        gnbru.reset_radio_unit(lib_ru, radio_unit_id=radio_unit_id, radio_type=radio_type)
        logger.info(f'... {rmod_type=} rebooted', also_console=True)
    logger.info(f'Fault_1934 on {rmod_type=} on all fans {trig}ed', also_console=True)


def show_alarms():
    lib = BuiltIn().get_library_instance('Fault_verifier')
    Fault_verifier.log_alarms(lib, also_console=True)
