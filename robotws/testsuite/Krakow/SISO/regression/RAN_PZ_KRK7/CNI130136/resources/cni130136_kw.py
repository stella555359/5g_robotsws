from testsuite.Krakow.resources.RAN_PZ_KRK7.tools import keywords
# from time import sleep
from time import time
from typing import Iterator, Optional, Union
from pprint import pprint, pformat

from robot.api import logger
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from ute_common_abstract_core.message import KeyFindingDict, NotFoundKey
from ta_messaging.message_verifiers import build_message_verifier_from_query
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as gnbru
from testsuite.Krakow.resources.RAN_PZ_KRK7.sshrmod import common, helpers_12097
from testsuite.Krakow.resources.RAN_PZ_KRK7.sshrmod.SSHRMOD import SSHRMOD
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations

import inspect
import json
from shutil import copyfile


def is_legacy_sw(sw_version: str):
    """Check if installed SW is older than given build. Uses simple string compare.

    :param str: sw_version: sw version to compare. Do not set SBTS00 build version, give e.g. SBTS26R2 instead.
    :return bool: True if active version is older than given one.
    """
    if not sw_version:
        return False
    bts_operations = GnbDuOperations()
    sw_version_current = bts_operations.get_bts_sw_version(bts_id=0, du_id=0)
    logger.info(f'{sw_version_current = }\n{sw_version = }\n{sw_version_current < sw_version = }')
    return sw_version_current < sw_version


def f_log(depth=1):
    desc = 'Function'
    log = ''
    for level in range(1, depth + 1):
        try:
            log += f'{level}.{desc}={inspect.stack()[level][3]} line={inspect.stack()[level][2]}' +\
                   f' from {inspect.stack()[level][1]}\n'
            desc = 'Called by'
        except IndexError:
            log += f'{level}.Function log level too deep. Aborting.\n'
            break
    return log


def get_data_from_json_file(file_path):
    _out = ''
    with open(file_path) as file:
        _out += file.read()
    out = json.loads(_out)
    logger.debug(f'{f_log()}out={pformat(out)}')
    return out


def json_validate(condition, file_path):
    out = get_data_from_json_file(file_path)
    alarm_lists_compare_result = out['data']['compareResultData'][0]['alarmListsCompareResult']
    logger.info(alarm_lists_compare_result.keys(), also_console=False)
    logger.info(alarm_lists_compare_result.keys(), also_console=False)


def get_value_from_container_by_path(container, path: list, default=None):
    current_data = container
    logger.info(f'{path=}')
    for key in path:
        logger.info(f'{type(current_data)=} ' +
                    (repr(current_data.keys()) if isinstance(current_data, dict)
                     else f'list len={len(current_data)}, elements={[type(el) for el in current_data]}') +
                    f' {key=}')
        # Check if the current_data is a dictionary and if the key exists in it
        if isinstance(current_data, dict) and key in current_data:
            current_data = current_data[key]
        elif isinstance(current_data, list) and len(current_data) > key:
            current_data = current_data[key]
        else:
            # If key is not found or current_data is not a dictionary, return default
            logger.warn(f'Key/index [{key}] not found, returned: ' + ('None' if default is None else default))
            return default
    logger.info(repr(current_data.keys()) if isinstance(current_data, dict)
                else (f'list len={len(current_data)}, elements={[type(el) for el in current_data]}')
                if isinstance(current_data, list) else current_data)
    logger.debug('current_data=\n'+pformat(current_data))
    return current_data


def json_get_value_by_path(file_path: str, path: list, default=None):
    json_dict = get_data_from_json_file(file_path)
    return get_value_from_container_by_path(json_dict, path, default)


def json_key_finding_dict_test(file_path: str, key: str):
    json_dict = get_data_from_json_file(file_path)
    logger.info(pformat(KeyFindingDict.get_all_values_by_key(json_dict, key)))
    logger.info(pformat(KeyFindingDict._find_paths2key(json_dict, key, 'container')))


def convert_path2key_to_key_list(path2key: str):
    key_list = path2key.replace('][', ', ')
    return eval(key_list)


def key_finding_dict_test(container, key: str):
    logger.info('_find_paths2key:\n' + (pformat(KeyFindingDict._find_paths2key(container, key)) or 'None'))
    path = [convert_path2key_to_key_list(el) for el in (KeyFindingDict._find_paths2key(container, key))]
    logger.info(f'{path=}')
    logger.info('get_all_values_by_key:\n' + (pformat(KeyFindingDict.get_all_values_by_key(container, key)) or 'None'))


def container_fulfills_query(*query_parts, container):
    verify_has_fields = build_message_verifier_from_query(query_parts)
    result = verify_has_fields(KeyFindingDict(container))
    logger.debug(f'container_fulfills_query {result=}')
    return result


def verify_container_fulfills_query(*query_parts, container):
    assert container_fulfills_query(*query_parts, container=container), \
        f'Query {query_parts} failed on container:\n' + pformat(container)


def get_path_to_key(container, key):
    return [convert_path2key_to_key_list(el) for el in (KeyFindingDict._find_paths2key(container, key))]


def get_value_of_key_from_alarm_that_fulfills_query(*query_parts,
                                                    container,
                                                    path_to_alarms: list,
                                                    path_to_key: Union[list, str]):
    '''
    As a query you can use full query language
     (https://wrgitlab.int.net.nokia.com/TAF/abstract_library/ta_messaging/-/wikis/query-language)

    param query_parts - lines that build query
    E.g.:
    1.  alarmAttribute contains
            ((attributeValue eq 'NH203500361-0')
            and
            (attributeName eq 'affected_cells'))

    2.  additionalFaultID contains (1932)
    3.  additionalFaultID contains (1932, 1932)
    4.  (additionalFaultID is present)
    5.  alarmAdditionalInfo contains (additionalFaultID eq 1932)
    6.  dn eq 'PLMN-PLMN/MRBTS-75016/EQM_R-1/APEQM_R-1/ASIRMOD_R-1/FAN_R-1'
        and
        additionalText1 eq 'No module fan detected'

    param path_to_alarms - list of subsequent keys pointing to list of alarms in dict/list structure
      E.g.: path_to_alarms = ['data', 0, 'alarmInfo']
    param path_to_key - list of keys or simple key (str)
    return value of key as str or tuple of list of values and list of path to keys
    E.g.:
    1. path_to_key=['additionalFaultID']
       return value=1934
    2. path_to_key=['additionalText3']
       return value='1932 additionalFaultID=1932 serial_no=NH203500361-0'
    3. path_to_key=additionalFaultID
       return value=([1934, 1934], [['additionalFaultID'], ['alarmText', 'alarmAdditionalInfo', 'additionalFaultID']])
    4. path_to_key=additionalText3
       return value=(['1932 additionalFaultID=1932 serial_no=NH203500361-0'], [['additionalText3']])
    '''
    alarms = get_value_from_container_by_path(container, path_to_alarms)
    value = None
    for alarm in alarms:
        if container_fulfills_query(*query_parts, container=alarm):
            logger.info('alarm=\n' + pformat(alarm))
            if isinstance(path_to_key, list):
                value = get_value_from_container_by_path(alarm, path_to_key)
            else:
                value = KeyFindingDict.get_all_values_by_key(alarm, path_to_key), get_path_to_key(alarm, path_to_key)
    logger.info(f'{f_log()}{value=}')
    return value


def container_has_all_keys_with_values(filter_dict: dict, container):
    match_all = []
    logger.debug(f'{f_log()}')
    for key, val in filter_dict.items():
        values = KeyFindingDict.get_all_values_by_key(container, key)
        match_any = [value == val for value in values]
        logger.debug(f'{match_any=}')
        match_all.append(any(match_any))
    logger.debug(f'{match_all=}')
    return all(match_all)


def get_value_of_key_from_alarm_that_has_key_value_pairs(filter_dict,
                                                         container,
                                                         path_to_alarms: list,
                                                         path_to_key: Union[list, str]):

    alarms = get_value_from_container_by_path(container, path_to_alarms)
    value = None
    for alarm in alarms:
        if container_has_all_keys_with_values(filter_dict, container=alarm):
            logger.info(f_log() + 'alarm=\n' + pformat(alarm))
            if isinstance(path_to_key, list):
                value = get_value_from_container_by_path(alarm, path_to_key)
            else:
                value = KeyFindingDict.get_all_values_by_key(alarm, path_to_key), get_path_to_key(alarm, path_to_key)
    logger.info(f'{f_log()}{value=}')
    return value


def verify_value_of_key_from_alarm(container, conditions, query_ph={}, expected_ph={}, internal_queries_ph=None):
    '''
    param conditions - dict/list structure containing alarm verification info,
      E.g:
      fid_1932 = {
        'webem':
        {
            'query': "alarmingObjectIds contains (runtime eq '{runtime_object}') and faultId eq 1932",
            'path_to_alarms': [],
            'expected': [{
                'path_to_key': ['serialNo'],
                'value': '{serialNo}'
                }, {
                'path_to_key': ['faultName'],
                'value': 'No module fan detected'
                },
            ],
            'internal_queries': [
                "alarmAttribute contains (attributeName eq 'serial_no' and attributeValue eq '{serialNo}')",
                ]
        },
        'netact_live': {},
        'netact_snap': {},
        'netact_compare': {}
    }
    query can be in query language form (sting) or simple dict where alarm must contain all given key/value pairs
      E.g:
      fid_4348_asir = {
          'webem':
          {
              'query': {
                  'source_object': '{so}',
                  'fault_id': 4348
              },
              'path_to_alarms': [],
              'expected': [{
                  'path_to_key': ['fault_name'],
                  'value': 'Ant Blocked'
                  },
              ],
          },
          'netact_live': {
              'query': "dn eq '{dn}' and additionalText1 eq 'Ant Blocked'",
              'path_to_alarms': [],
              'expected': [{
                  'path_to_key': ['additionalText3'],
                  'value': '4348;path={path};serial_no={serialNo};;caPartnerId=;antPortRDN={antPortRDN};'
                          'chainPosition={chainPosition};additionalFaultId=4348;conf_path={conf_path}'
              },
              ],
          },
      }

    param query_ph - query placeholder of str.format '{some_value}' style from 'conditions' dict/list structure
    '''
    logger.debug(f'{f_log()}{conditions=},\n{query_ph=}, {expected_ph=}, {internal_queries_ph=}')
    logger.debug(f"{conditions['query']=}")
    for el in conditions['expected']:
        if isinstance(conditions['query'], dict):
            _dict = conditions['query']
            filter_dict = {key: val.format(**query_ph) if isinstance(val, str) else val for key, val in _dict.items()}
            logger.debug(f"{filter_dict=}")
            value = get_value_of_key_from_alarm_that_has_key_value_pairs(filter_dict,
                                                                         container=container,
                                                                         path_to_alarms=conditions['path_to_alarms'],
                                                                         path_to_key=el['path_to_key'])
        else:
            logger.debug(f"{conditions['query'].format(**query_ph)=}")
            value = get_value_of_key_from_alarm_that_fulfills_query(conditions['query'].format(**query_ph),
                                                                    container=container,
                                                                    path_to_alarms=conditions['path_to_alarms'],
                                                                    path_to_key=el['path_to_key'])
        expected = el["value"].format(**expected_ph)
        logger.info(f'value of {el["path_to_key"]}: "{value}", Expected: "{expected}"')
        assert value == expected, f'Value of {el["path_to_key"]}: "{value}" wasn\'t as expected: "{expected}"'
    if internal_queries_ph:
        for query in conditions['internal_queries']:
            alarm = get_value_of_key_from_alarm_that_fulfills_query(conditions['query'].format(**query_ph),
                                                                    container=container,
                                                                    path_to_alarms=conditions['path_to_alarms'],
                                                                    path_to_key=[])
            formatted_query = query.format(**internal_queries_ph)
            matches_query = container_fulfills_query(formatted_query, container=alarm)
            logger.info(f'Is alarm matching query "{formatted_query}"?: {matches_query}')
            assert matches_query, f'Alarm failed to match query "{formatted_query}"'


def get_fan_location(fan_distname, bts_id=0, du_id=0):
    gnbru_ = gnbru()
    gnbru_.connect()
    admin_ = gnbru_.admin
    param = admin_.get_parameter_by_distname(dist_name=fan_distname,
                                             connection=gnbru_.rest_alias.format(bts_id, du_id))
    logger.debug(f'{f_log()}param={pformat(param)}')
    return param[0]['parameters']['fanLocation']


def get_fan_serialNo(rmod_sn, fan_dn):
    return f'{rmod_sn}-{get_fan_location(fan_dn)}'


def get_object_parameters(dist_name, parameter_list=None, bts_id=0, du_id=0):
    gnbru_ = gnbru()
    gnbru_.connect()
    dist_name = gnbru_.adjust_dist_name(dist_name, bts_id, du_id)
    admin_ = gnbru_.admin
    param = admin_.get_parameter_by_distname(dist_name,
                                             parameter_list,
                                             connection=gnbru_.rest_alias.format(bts_id, du_id))
    logger.debug(f'{f_log()}param={pformat(param)}')
    return param[0]


def get_object_dn_sn_conf_dn(dist_name: str):
    params = get_object_parameters(dist_name, ['serialNumber', 'configDN'])
    return (params['distName'],
            params['parameters']['serialNumber'],
            params['parameters']['configDN'])


def get_lane_dn_sn_conf_dn(dist_name: str):
    sn = get_object_parameters(dist_name.rsplit('/', 1)[0], ['serialNumber'])['parameters']['serialNumber']
    params = get_object_parameters(dist_name, ['laneRId', 'configDN'])
    return (params['distName'],
            sn + '-' + str(params['parameters']['laneRId']),
            params['parameters']['configDN'])


def change_antantl_swconfig_flag(ssh: SSHRMOD, prep: Union[bool, str],
                                 skip_reboot=False, rmod_sn: str = None):
    '''Prepares swconfig to asir  ANTANTL FID:1907, FID:1908, FID:1911 triggering

    :param bool/str prep: True/Prepare to trigger, False/Clear to clear;
    :param bool skip_reboot: True or False;
    '''
    rmod_type = 'APHA'
    rad_param = '0x60099'
    logger.debug(f'-change_antantl_swconfig_flag {rmod_type=} {rad_param=} {prep=} {skip_reboot=}')
    prep = False if prep == 'Clear' or not prep else True  # cast bool or str type to bool
    logger.debug(f'--change_antantl_swconfig_flag {rmod_type=} {rad_param=} {prep=} {skip_reboot=}')
    trig = 'prepar' if prep else 'clear'
    prep = '1' if prep else '0'
    skip_reboot = True if skip_reboot else False
    '''
    0x60099=1 means enabling newly added AAshell commands, or these commands are not supported by draco process
    '''
    logger.debug(f'change_antantl_swconfig_flag {rmod_type=} {rad_param=} {prep=} {skip_reboot=}')
    # -----
    logger.info(f'{trig.capitalize()}ing ANTANTL fault triggering on {rmod_type=} with {rmod_sn=}', also_console=True)
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    ssh.edit_rmod_rad_params(rad_params=rad_param, value=prep, rmod_type=rmod_type)
    ssh.logout_from_rmod(rmod_type)
    if not skip_reboot:
        lib_ru = BuiltIn().get_library_instance('gnbru')
        radio_unit_id = common.get_rmod_id(rmod_type, rmod_sn)
        radio_type = 'asirmod' if common.is_asi_hub(rmod_type, rmod_sn) else 'rmod'
        logger.info(f'Going to reboot {rmod_type=} with id:{radio_unit_id} by Admin...', also_console=True)
        gnbru.reset_radio_unit(lib_ru, radio_unit_id=radio_unit_id, radio_type=radio_type)
        logger.info(f'... {rmod_type=} rebooted', also_console=True)
    logger.info(f'{rmod_type=} ANTANTL fault triggering {trig}ed', also_console=True)


def trigger_antantl_alarm(ssh: SSHRMOD, fault_id: str, prrh: str, on_antenna,
                          rmod_type: str, rmod_sn: str = None):
    '''
    param on_antenna: None, '', False to clear alarms; '1', '0, 2-4' to trigger on given antennas
    '''
    fault_id_cmd_map = {
        '1907': ['alarm_simulate TXALARM {flag} @{pid}',
                 'Tx alarm flag {flag}'],
        '1911': ['alarm_simulate RXALARM {flag} @{pid}',
                 'Rx alarm flag {flag}'],
        '1908': ['alarm_simulate GCALARM {flag} @{pid}',
                 'GC alarm flag {flag}']
    }
    try:
        cmd_response = fault_id_cmd_map[fault_id]
    except KeyError:
        raise ValueError(f'{fault_id=} should be 1907 or 1908 or 1911')
    find_pid_cmd = f'ps -ef | grep hwrel::instance{prrh}'
    if on_antenna:
        antenna_set = set(helpers_12097.convert_str_to_list(on_antenna))
        logger.info(f'trigger_antantl_alarm: {antenna_set=}')
        flag = hex(sum(1 << n for n in antenna_set))
    else:
        flag = '0x0'
    common.login_to_rmod(ssh, rmod_type, rmod_sn)
    out = ssh.run_command_on_rmod(find_pid_cmd, rmod_type)
    pid = out.split()[1]
    logger.info(f'trigger_antantl_alarm: {pid=}')
    ssh.run_aashell_command(cmd_response[0].format(flag=flag, pid=pid), rmod_type,
                            expected_cmd_out=cmd_response[1].format(flag=flag))
    ssh.logout_from_rmod(rmod_type)


def add_param_to_swconfig(parameter, path):
    with open(path, 'r+') as sw_config:
        raw_param = parameter.split("#", 1)[0].strip(" ")                   # drop comments in file
        logger.info(f"Searching {raw_param} in swconfig...")
        param_found = any([raw_param in line for line in sw_config])
        if not param_found:
            logger.info(f"Not found. Adding new {parameter=} to swconfig")
            sw_config.write(f"\n{parameter}\n")
        else:
            logger.info(f"'{parameter=}' already in swconfig, skipping.")


def copy_and_modify_swconfig(parameters_list=[],
                             source_path="commissionings/Krakow/swconfig/default_swconfig.txt",
                             target_path="custom_swconfig.txt"):
    copyfile(src=source_path, dst=target_path)
    parameters_list = [parameters_list] if isinstance(parameters_list, str) else parameters_list
    for parameter in parameters_list:
        add_param_to_swconfig(parameter, target_path)


def correct_sw_version(sw_version):
    # logger.info(f"{sw_version=}\n{type(sw_version)=}")
    # sw_version = str(sw_version)
    logger.info(f"{sw_version=}\n{type(sw_version)=}")
    if sw_version.split("_", 3)[2] == "9999" or sw_version.split("_", 3)[2] == "9990":
        sw_version = "_".join(["SBTS00", sw_version.split("_", 1)[1]])
    if "5G" in sw_version.split("_", 1)[0]:
        release = sw_version.split("_", 1)[0]
        build_number = ".".join([_.lstrip("0") for _ in sw_version.split("_")[2::]])
        sw_version = "_".join([release, build_number])
    return sw_version
