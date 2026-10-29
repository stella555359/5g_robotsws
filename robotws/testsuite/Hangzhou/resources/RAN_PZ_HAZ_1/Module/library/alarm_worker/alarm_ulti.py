#!/usr/bin/env python
import yaml
from robot.libraries.BuiltIn import BuiltIn
import os
import csv
import logging
import re
import json
import socket

__all__ = [
    "yaml_file_to_dictionary",
    "dictionary_to_yaml_file",
    "create_alarm_file",
    "save_alarms_to_csvfile",
    "check_active_alarms",
    "analyze_active_alarms",
    "get_hostname",
    "create_watchdog_logdir",
    "remove_suffix"
]

SIMPLIFIED_DICT = {'additional_info': {'alarm_id': None, 'alarm_name': None, 'alarming_object': None, 'fault_id': None}}


def yaml_file_to_dictionary(file_path):
    """Get dictionary according yaml format file.
    | Input Parameters | Man. | Description |
    | file_path       | Yes  | file_path of yaml file |

    *RETURN VALUE*
    Dictionary of content

    Example
    | ${dictionary_content} | yaml_file_to_dictionary | /home/ute/a.yaml |
    """
    with open(file_path) as stream:
        NoDatesSafeLoader = yaml.SafeLoader
        NoDatesSafeLoader.yaml_implicit_resolvers = {
            k: [r for r in v if r[0] != 'tag:yaml.org,2002:timestamp']
            for k, v in NoDatesSafeLoader.yaml_implicit_resolvers.items()
        }
        data_loaded = yaml.load(stream, Loader=NoDatesSafeLoader)
    return data_loaded


def dictionary_to_yaml_file(dict_values, file_path):
    """Get dictionary according yaml format file.
    | Input Parameters | Man. | Description |
    | dict_values      | Yes  | dict_values to be dumped|
    | file_path       | Yes  | file_path of yaml file |

    *RETURN VALUE*
    None

    Example
    | ${dictionary_content} | yaml_file_to_dictionary | /home/ute/a.yaml |
    """
    with open(file_path, 'w') as f:
        yaml.safe_dump(dict_values, f, encoding='utf-8', allow_unicode=True)


def create_alarm_file(log_path, file_name):
    """create a file name with absolute path, Raise exception if failed to generate a file name.
    | Input Parameters  | Man. | Description |
    | path            | Yes  |   list type, e.g, ["folder1", "fold2", "filename.txt"] |
    *RETURN VALUE*
    string

    Example:
    | ${file_name}  | create_a_file | folder1 | folder2 | filename.txt |
    """
    builtin_obj = BuiltIn()
    rtn = ""
    try:
        file_abs_path = os.path.join(log_path, file_name)
        builtin_obj.log(file_abs_path, "INFO")
        file_dir, file_name = os.path.split(file_abs_path)
        if not os.path.exists(file_dir):
            os.makedirs(file_dir)
        if not os.path.exists(file_abs_path):
            os.system("touch %s" % file_abs_path)
        rtn = file_abs_path
    except Exception as e:
        builtin_obj.log(e, "ERROR")
    if len(rtn) == 0:
        raise RuntimeError("get_a_file(): fail!!")
    return rtn


def create_watchdog_logdir(log_path):
    builtin_obj = BuiltIn()
    rtn = ""
    try:
        builtin_obj.log("create %s" % log_path, "INFO")
        if not os.path.exists(log_path):
            os.mkdir(log_path)
        rtn = log_path
    except Exception as e:
        builtin_obj.log(e, "ERROR")
    if len(rtn) == 0:
        raise RuntimeError('Create dir%s:fail!!' % log_path)
    return rtn


def save_alarms_to_csvfile(alarm_data, file_name):
    """
    this function is used to store alarms to a csv file

    Parameters:
        alarm_data(dict): dict with keys: - alarms: the value is list with alarms
                                          - total: the value is total amount of alarms as int
        file_name(str): file path of csv file

    Returns:
        None
    """
    # use vdu active alarm header as alarm base header
    alarm_base_header = ['severity', 'appear_time', 'last_updated_time', 'alarm_id', 'alarm_name',
                         'fault_id', 'fault_name', 'alarming_object', 'event_type_name',
                         'probable_cause_name', 'additional_info', 'uuid', 'affected_cells',
                         'fault_signature', 'degraded_cells', 'faulty_cells']
    alarm_bts_header = ['appear_time', 'impactedCells', 'hwPath', 'severity', 'impactedCellsList',
                        'btsObservationTime', 'notifier', 'configObjectName', 'faultName', 'faultId',
                        'alarmDetail', 'faultSeverity', 'technology', 'alarmAttribute', 'impactedCell',
                        'serialNo', 'eventType', 'cellName', 'impactedCellsLcrIdList', 'btsObservationTimezone',
                        'faultSignature', 'degradedCells', 'impactedCellsListCliInfo', 'cellLcrId', 'distName',
                        'number', 'btsLastUpdateTime', 'alarmName', 'alarmText', 'alarmId', 'alarmingObjectIds',
                        'additionalFaultID', 'btsLastUpdateTimezone', 'shared']
    vdu_historical_alarm_header = alarm_base_header.copy()
    insert_index = vdu_historical_alarm_header.index('appear_time') + 1
    vdu_historical_alarm_header.insert(insert_index, 'cleared_time')

    vcu_active_alarm_header = alarm_base_header.copy()
    insert_index = vcu_active_alarm_header.index('alarming_object') + 1
    vcu_active_alarm_header.insert(insert_index, 'cell_name')

    vcu_historical_alarm_header = vdu_historical_alarm_header.copy()
    insert_index = vcu_historical_alarm_header.index('additional_info') + 1
    vcu_historical_alarm_header.insert(insert_index, 'affected_cells')

    bts_active_alarm_header = alarm_bts_header.copy()

    bts_historical_alarm_header = alarm_bts_header.copy()
    insert_index = bts_historical_alarm_header.index('appear_time') + 1
    bts_historical_alarm_header.insert(insert_index, 'clearedTime')
    tmp_list = ['eventTime', 'btsClearedTimezone', 'disappearTime']
    bts_historical_alarm_header.extend(tmp_list)

    with open(file_name, 'a', newline='', encoding='utf-8') as f:
        if 'vdu_active' in file_name:
            writer = csv.DictWriter(f, fieldnames=alarm_base_header)
        elif 'vdu_historical' in file_name:
            writer = csv.DictWriter(f, fieldnames=vdu_historical_alarm_header)
        elif 'vcu_active' in file_name:
            writer = csv.DictWriter(f, fieldnames=vcu_active_alarm_header)
        elif 'vcu_historical' in file_name:
            writer = csv.DictWriter(f, fieldnames=vcu_historical_alarm_header)
        elif 'bts_active' in file_name:
            writer = csv.DictWriter(f, fieldnames=bts_active_alarm_header)
        elif 'bts_historical' in file_name:
            writer = csv.DictWriter(f, fieldnames=bts_historical_alarm_header)

        writer.writeheader()
        if isinstance(alarm_data, list):
            alarm_data = {'alarms': alarm_data, 'total': len(alarm_data)}
        if alarm_data['total'] == 0:
            print('No data')
            return
        else:
            writer.writerows(alarm_data['alarms'])


def analyze_active_alarms(active_alarms, expected_alarms):
    fault_names = [alarm['fault_name'] for key, alarm in active_alarms.items()]
    fault_ids = [alarm['fault_id'] for key, alarm in active_alarms.items()]
    match_found = True
    mismatch_res1, mismatch_res2, match_res1, match_res2 = [], [], [], []

    expect_fault_names = [item['fault_name'] for item in expected_alarms if 'fault_name' in item.keys()]
    expect_fault_ids = [item['fault_id'] for item in expected_alarms if 'fault_id' in item.keys()]

    if len(expect_fault_names):
        match_res1 = [item for item in expect_fault_names if item in fault_names]
        mismatch_res1 = [item for item in expect_fault_names if item not in fault_names]

    if len(expect_fault_ids):
        match_res2 = [item for item in expect_fault_ids if item in fault_ids]
        mismatch_res2 = [item for item in expect_fault_ids if item not in fault_ids]

    mismatch_res = mismatch_res1 + mismatch_res2
    match_res = match_res1 + match_res2
    if len(mismatch_res):
        match_found = False
        logging.warning(f"{mismatch_res}"
                        f" does not exist on the base station, please verify.")
    if len(match_res):
        logging.info(f"{match_res}"
                     f"matches exactly the one that exists on the base station.")
    return match_found, "The fault does not exist on the base station:{}".format(mismatch_res)


def get_filtered_alarms(current_alarms, expected_patterns=list(), ignored_patterns=list(), critical_patterns=list(),
                        simplified_dictionary=SIMPLIFIED_DICT):
    found_expected_alarms, found_other_alarms, not_found_expected_patterns = _filter_alarms(
        current_alarms,
        expected_patterns,
        simplified_dictionary=simplified_dictionary
    )

    found_ignored_alarms, found_other_alarms, not_found_ignored_patterns = _filter_alarms(
        found_other_alarms,
        ignored_patterns,
        simplified_dictionary=simplified_dictionary,
        use_pattern_once=False
    )
    found_critical_alarms, found_not_cloud_alarms, not_found_critical_patterns = _filter_alarms(
        found_other_alarms,
        critical_patterns,
        simplified_dictionary=simplified_dictionary,
        use_pattern_once=False
    )
    return (found_expected_alarms, not_found_expected_patterns,
            found_critical_alarms, found_ignored_alarms, found_not_cloud_alarms)


def check_active_alarms(expected_patterns, add_ignored_alarm, alarm_info, critical_patterns=None,
                        product_type='cloud'):

    ignored_patterns = handle_ignored_alarms(ignored_patterns=add_ignored_alarm)
    simplified_alarm = {"severity": None, "faultId": None, "faultName": None, "notifier": None, "number": None}
    logging.debug('alarm info: {}'.format(alarm_info))
    if product_type == 'cloud':
        if critical_patterns is None:
            critical_patterns = [{"severity": "Critical"}]
        found_expected_alarms, not_found_expected_alarms_patterns, \
            found_critical_alarms, found_ignored_alarms, \
            found_not_cloud_alarms = get_filtered_alarms(
                current_alarms=alarm_info['alarms'],
                expected_patterns=expected_patterns,
                ignored_patterns=ignored_patterns,
                critical_patterns=critical_patterns,
                simplified_dictionary=simplified_alarm
            )
    else:
        if critical_patterns is None:
            critical_patterns = [{"severity": "Critical"}]
        found_expected_alarms, not_found_expected_alarms_patterns, \
            found_critical_alarms, found_ignored_alarms, \
            found_not_enb_alarms = get_filtered_alarms(
                current_alarms=alarm_info,
                expected_patterns=expected_patterns,
                ignored_patterns=ignored_patterns,
                critical_patterns=critical_patterns,
                simplified_dictionary=simplified_alarm
            )
    logging.debug('expected alarms: {}'.format(found_expected_alarms))
    logging.debug('critical alarms: {}'.format(found_critical_alarms))
    logging.debug('ignored alarms: {}'.format(found_ignored_alarms))
    if not_found_expected_alarms_patterns:
        flag_expect_alarm = False
    else:
        flag_expect_alarm = True
    if found_critical_alarms:
        flag_critical_alarm = True
    else:
        flag_critical_alarm = False
    return flag_expect_alarm, flag_critical_alarm


def handle_ignored_alarms(ignored_patterns):
    current_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(current_dir, 'alarms_variable.json')
    print(f"current_dir:{current_dir}")
    if ignored_patterns is None:
        with open(json_path, 'r') as f:
            expected_alarm = json.load(f)
    elif ".json" in ignored_patterns:
        with open(ignored_patterns) as f:
            expected_alarm = json.load(f)
    elif isinstance(ignored_patterns, dict) or isinstance(ignored_patterns, list):
        current_file_path = os.path.realpath(__file__)
        current_directory = os.path.dirname(current_file_path)
        relative_path = os.path.join(current_directory, 'alarms_variable.json')
        with open(relative_path, "r") as f:
            default_alarm = json.load(f)
            for i in ignored_patterns:
                default_alarm.append(i)
            expected_alarm = default_alarm
    return expected_alarm


def _filter_alarms(alarms_list, filter_patterns, simplified_dictionary=None, use_pattern_once=True):
    matched_alarms = []
#    left_patterns = filter_patterns[:]
#    left_alarms = alarms_list[:]
    left_patterns = [item for item in filter_patterns]
    left_alarms = [item for item in alarms_list]
    for alarm in alarms_list:
        pretty_alarm = _make_pretty_alarm(alarm, simplified_dictionary) if simplified_dictionary else alarm
        logging.debug('Alarm under test: {}'.format(pretty_alarm))
        for pattern in left_patterns:
            logging.debug('Pattern to match: {}'.format(pattern))
            if _matching_dicts(pattern, alarm):
                logging.debug('Alarm matched pattern')
                matched_alarms.append(alarm)
                left_alarms.remove(alarm)
                if use_pattern_once:
                    left_patterns.remove(pattern)
                break
        else:
            logging.debug('Alarm doesnt match any pattern from: {}'.format(left_patterns))
    return matched_alarms, left_alarms, left_patterns


def add_slash_before_special_character(s):
    special_chars = ['(', ')', '{', '}', '[', ']', '.', '|', '+', '?']
    for char in special_chars:
        if char in s:
            s = s.replace(char, '\\'+char)
    return s


def _matching_dicts(pattern_dict, source_dict):
    for key, value in pattern_dict.items():
        value = add_slash_before_special_character(value)
        if isinstance(value, dict):
            _match = _matching_dicts(value, source_dict.get(key, {}))
        elif isinstance(value, list):
            _match = value == source_dict.get(key, [])
        else:
            _match = bool(re.search(str(value), str(source_dict.get(key, ''))))
        logging.debug('Key to check: {}, result: {} ({} vs {})'.format(key, _match, str(value),
                                                                       str(source_dict.get(key, ''))))
        if not _match:
            return False
    return True


def _make_pretty_alarm(source_dict, recogn_dict=None):
    new_dict = {}
    for key, value in recogn_dict.items():
        if isinstance(value, dict):
            new_dict[key] = _make_pretty_alarm(source_dict.get(key, {}), value)
        else:
            new_dict[key] = str(source_dict.get(key, ''))
    return new_dict


def get_hostname():
    return socket.gethostname()


def remove_suffix(input_str):
    if input_str.endswith('_1'):
        return input_str[:-2]
    return input_str


if __name__ == "__main__":
    pass
