from pprint import pformat
from time import sleep
from robot.libraries.BuiltIn import BuiltIn, logger
from typing import Union
import random
from SSHRMOD import SSHRMOD
from Fault_verifier import Fault_verifier, login_logout
from helpers_12097 import convert_str_to_list, f_log
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as gnbru, GenericRuOperations as genru
from taf.rfrl.bts.helpers.dist_name import get_id_from_dist_name
import taf.rfrl.procedures.resources.python.diagnostic_check.diagnostic_check as diagnostic_check
import taf.rfrl.procedures.resources.python.connections as connections
from taf.config.testline.radio import RU


@login_logout
def get_rmod_info(inst: gnbru, bts_id=0, du_id=0):
    objects = inst.admin.get_managed_objects(connection=inst.rest_alias.format(bts_id, du_id),
                                             class_name='RMOD_L')
    logger.debug(f'{f_log(2)}rmod_objects={pformat(objects)}', html=True)

    return objects


def get_rmod_brief_info():
    gnbru_ = gnbru()
    rmods = list(get_rmod_info(gnbru_))
    rmod_list = []
    for rmod in rmods:
        rmod = dict(rmod)
        rmod_list.append({'distName': rmod.get('distName'),
                          'productName': rmod.get('parameters').get('productName'),
                          'ipAddress': rmod.get('parameters').get('ipAddress'),
                          'serialNumber': rmod.get('parameters').get('serialNumber'),
                          'isAsiHub': rmod.get('parameters').get('isAsiHub')})
    logger.info(f'{f_log(2)}rmod_list={pformat(rmod_list)}', html=True)
    return rmod_list


def get_rmod_ip(rmod_type, rmod_sn=None):
    ip_addr = None
    rmod_list = get_rmod_brief_info()
    for rmod in rmod_list:
        if rmod.get('productName') == rmod_type:
            if ip_addr and not rmod_sn:
                raise AssertionError(f'Multiple RMODs with {rmod_type=} found. Please provide serial number.')
            if rmod_sn and rmod.get('serialNumber') == rmod_sn:
                ip_addr = rmod.get('ipAddress')
            elif not rmod_sn:
                ip_addr = rmod.get('ipAddress')
    logger.info(f'{f_log()}{ip_addr=}', html=True)
    return ip_addr


def is_asi_hub(rmod_type, rmod_sn=None):
    asir = None
    rmod_list = get_rmod_brief_info()
    for rmod in rmod_list:
        if rmod.get('productName') == rmod_type:
            if asir is not None and not rmod_sn:
                raise AssertionError(f'Multiple RMODs with {rmod_type=} found. Please provide serial number.')
            if rmod_sn and rmod.get('serialNumber') == rmod_sn:
                asir = rmod.get('isAsiHub')
            elif not rmod_sn:
                asir = rmod.get('isAsiHub')
    logger.info(f'{f_log()}{asir=}', html=True)
    return asir


def get_ru_full_info():
    genru().connect()
    ru_info = genru._get_all_rus_info(genru())
    logger.debug(f'{f_log(2)}ru_info={pformat(ru_info)}', html=True)
    return ru_info


def get_ru_dist_name(rmod_type, rmod_sn=None, id_type='configuration') -> str:
    """
    id_type: possible options 'configuration', 'runtime', 'internal'
    """
    all_rus_info = get_ru_full_info()
    dist_name = None
    for ru_info in all_rus_info:
        if ru_info.get('productName') == rmod_type:
            if dist_name and not rmod_sn:
                raise AssertionError(f'Multiple RMODs with {rmod_type=} found. Please provide serial number.')
            if not rmod_sn or (rmod_sn and ru_info.get('serialNumber') == rmod_sn):
                dist_name = ru_info['id'][id_type]
    logger.info(f'{f_log()}{dist_name=}', html=True)
    return dist_name


def get_rmod_id(rmod_type, rmod_sn=None, id_type='configuration'):
    dist_name = get_ru_dist_name(rmod_type, rmod_sn=rmod_sn, id_type=id_type)
    ru_name = genru._get_ru_object_name_from_dist_name(dist_name)
    ru_id = get_id_from_dist_name(ru_name)
    logger.info(f'{f_log()}{ru_id=}', html=True)
    return ru_id


def get_rmod_and_fan_dist_names(rmod_type, rmod_sn=None, id_type='runtime'):
    ru_name = get_ru_dist_name(rmod_type, rmod_sn=rmod_sn, id_type=id_type)
    fan_name = 'MRBTS-1/' + ru_name.split('/', 1)[1] + '/FAN_R-'
    return ru_name, fan_name


def login_to_rmod(ssh: SSHRMOD, rmod_type: str, rmod_sn: str = None):
    rmod_ip = get_rmod_ip(rmod_type=rmod_type, rmod_sn=rmod_sn)
    ssh.login_to_rmod(rmod_ip, rmod_type)
    return rmod_ip


def get_rmod_sn_from_rmod_list(rmod_type: str, rmod_id: Union[int, str], rmod_list: list[RU]):
    rmod_sn_list = [rmod.serial_number for rmod in rmod_list if rmod.radio_type == rmod_type]
    rmod_count = len(rmod_sn_list)
    logger.debug(f'{f_log()}{rmod_type=}: {rmod_sn_list=}, {rmod_count=}', html=True)
    if rmod_id == 'random':
        rmod_id = random.randint(0, rmod_count - 1)
    rmod_id = int(rmod_id)
    if rmod_id > rmod_count - 1:
        logger.warn(f'{f_log()}{rmod_id=} shouldn\'t be greater than {rmod_count - 1 =}, converting...', html=True)
        rmod_id %= rmod_count
    logger.debug(f'{f_log()}{rmod_id=}', html=True)
    return rmod_sn_list[rmod_id]


def run_diagnostic_check(timeout=120):
    gnbru().connect()
    connection = connections.get_default_admin_connection_alias()
    diag_check = diagnostic_check.get_diagnostic_check_report(connection=connection, timeout=timeout)
    logger.info(f'{f_log()}diag_check={pformat(diag_check)}', html=True)
    return diag_check


def verify_diagnostic_check(report: list[dict], checkpoint: str, status: str, rmod: str, negative_check=False):
    # param checkpoint: provide 'checkpointName' (str) or 'checkpoint' (number - int or str)
    match_found = []
    negative_check = bool(negative_check)
    for ch_point in report:
        if checkpoint == ch_point.get('checkpointName') or checkpoint == str(ch_point.get('checkpoint')):
            if ch_point.get('checkStatus') == status and ch_point.get('productName') == rmod:
                match_found.append({'checkpoint': ch_point.get('checkpoint'),
                                    'checkpointName': ch_point.get('checkpointName'),
                                    'checkStatus': ch_point.get('checkStatus'),
                                    'productName': ch_point.get('productName')})
    logger.info(f'{f_log()}match_found={pformat(match_found)}', html=True)
    found = len(match_found)
    msg_a, msg_b = (f'contains {match_found}', 'should not') if negative_check \
        else (f'does not contain any {status} for {rmod}, checkpoint:{checkpoint}', f'should ({match_found})')
    if (not negative_check and found == 0) or (negative_check and found > 0):
        raise AssertionError(f'Diagnostic check {msg_a}, but {msg_b}.')


def alter_faulty_objects(fault_id: str, rmod_type: str, fans: str = '', trigger: Union[bool, str] = True):
    # you can also change only faulty_rmods list by not providing fan list
    faulty_rmods = set(BuiltIn().get_variable_value('${FAULTY_' + fault_id + '_RMODS}'))
    faulty_fans = set(BuiltIn().get_variable_value('${FAULTY_' + fault_id + '_FANS}'))
    rmod_runtime = dict(BuiltIn().get_variable_value('${RMOD_RUNTIME}')).get(rmod_type)
    fan_runtime = dict(BuiltIn().get_variable_value('${FAN_RUNTIME}')).get(rmod_type)
    fan_list = convert_str_to_list(fans) if fans else []
    logger.info(f'{f_log()}Before change: {faulty_rmods=}\t{faulty_fans=}\t{fan_list=}' +
                f'\t{rmod_runtime=}\t{fan_runtime=}', html=True)
    trigger = False if trigger == 'Clear' or not trigger else True  # cast bool or str type to bool
    if trigger:
        faulty_rmods.add(rmod_runtime)
        for fan in fan_list:
            faulty_fans.add(fan_runtime + str(fan))
    else:
        for fan in fan_list:
            faulty_fans.discard(fan_runtime + str(fan))
        faulty_fans_on_rmod_left = [fan_obj for fan_obj in faulty_fans
                                    if fan_obj.split('/FAN_R-')[0] + '/FAN_R-' == fan_runtime]
        logger.debug(f'{faulty_fans_on_rmod_left=}', html=True)
        if not faulty_fans_on_rmod_left or not fan_list:
            faulty_rmods.discard(rmod_runtime)
    faulty_rmods = list(faulty_rmods)
    faulty_fans = list(faulty_fans)
    logger.info(f'{f_log()}After change: {faulty_rmods=}\t{faulty_fans=}', html=True)
    BuiltIn().set_test_variable('${FAULTY_' + fault_id + '_RMODS}', faulty_rmods)
    BuiltIn().set_test_variable('${FAULTY_' + fault_id + '_FANS}', faulty_fans)


def remove_all_fan_objects_from_faulty_objects(fault_id: str, rmod_type: str):
    # remove all FAN objects with given FID and RMOD type from expected faults, omits RMOD objects.
    # Needed after moving FAN faults to Severity: WARNING group, PR 05184468
    faulty_fans = set(BuiltIn().get_variable_value('${FAULTY_' + fault_id + '_FANS}'))
    fan_runtime = dict(BuiltIn().get_variable_value('${FAN_RUNTIME}')).get(rmod_type)
    logger.info(f'{f_log()}Before change: {faulty_fans=}\t{fan_runtime=}', html=True)
    for fan in faulty_fans.copy():
        if str(fan).startswith(fan_runtime):
            faulty_fans.discard(fan)
            logger.debug(f'{f_log()}Removed: {fan=}', html=True)
            logger.debug(f'{f_log()}Remaining: {faulty_fans=}', html=True)
    faulty_fans = list(faulty_fans)
    logger.info(f'{f_log()}After change: {faulty_fans=}', html=True)
    BuiltIn().set_test_variable('${FAULTY_' + fault_id + '_FANS}', faulty_fans)
