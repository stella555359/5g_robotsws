# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Artur Dobosz
:contact: artur.dobosz@nokia.com
:maintainer: None
:contact: None
"""
import re
import ast

UNEXPECTED_ALARM_KEY_LIST = []
ALARM_KEY_MAPPING_DICT = {'alarmDetail': 'faultName', 'alarmSeverity': 'severity',
                          'alarmingResourceDN': 'alarmingResource'}
ALLOWED_MANDATORY_KEYS_LIST = \
    ['alarmId', 'alarmName', 'alarmingResource', 'btsObservationTime', 'degradedCells', 'detailsAlarmId', 'distName',
        'faultId', 'faultName', 'hwPath', 'impactedCells', 'notifier', 'number', 'severity', 'technology',
        'configObjectName', 'impactedCellsList', 'serialNo', 'supplAlarmInfo']


def admin_alarms_check(available, allowed=None, mandatory=None, allowed_key='faultName'):
    """Checks info model mandatory and allowed alarms inside provided list of active alarms.

    :param list available: list of active info model alarms (returned by "ute_admin.Get Active Alarms" KW).
    :param list allowed: (optional) list of allowed alarms defined by faultName attribute (regex is supported in Value).
    :param list mandatory: (optional) list of dictionaries with mandatory alarms defined by faultName/alarmDetail,
                        faultId, \
                        severity/alarmSeverity, impactedCells, alarmingResource/alarmingResourceDN, alarmCounter, \
                        or any other attribute matching to first level key name of active alarm and . \
                        At least faultName/alarmDetail or faultId dictionary key and its value has to be
                        defined (regex is supported in Value).
    :param string allowed_key: key name used for verifications alarms defined as allowed (faultName as default).

    Examples:
        allowed = ['(?i)vendor bts certificate', 'Synchronization lost', '.*BTS booted at.+']
        mandatory = [{'faultName': 'Unit blocked', 'faultId': '48', 'severity': 'Major', 'impactedCells':
                    '.*?LNCEL-60000.*'}, \
                    {'faultName': 'Unit blocked', 'faultId': '48', 'impactedCells': '.*LNCEL-60001.*'}, \
                    {'alarmDetail': 'Unit blocked', 'alarmSeverity': 'Major', 'impactedCells': '.*LNCEL-60002.*}, \
                    {'faultId': '48', 'alarmSeverity': 'Major', 'impactedCells': '.*LNCEL-60003.*'}, \
                    {'faultName': 'Transmission path failure', 'alarmCounter': 3}]
    """
    global UNEXPECTED_ALARM_KEY_LIST
    UNEXPECTED_ALARM_KEY_LIST = ['faultId', 'faultName', 'severity']
    available = available[:]
    output_after_mandatory = _admin_remove_mandatory_alarms(available, mandatory)
    output_after_allowed = _admin_remove_allowed_alarms(output_after_mandatory[0], allowed, allowed_key)
    output_after_unexpected = _admin_log_unexpected_alarms(output_after_allowed)
    if len(output_after_mandatory[1]):
        raise Exception('\n'.join(output_after_mandatory[1]))
    if len(output_after_allowed) != 0 or len(output_after_mandatory[2]) != 0:
        raise Exception('\n' + '\n'.join(output_after_mandatory[2]) + '\n' + '\n'.join(output_after_unexpected))


def _admin_remove_mandatory_alarms(available, mandatory=None):
    """Removes mandatory alarms from available ones."""
    mandatory = mandatory if mandatory else []
    mandatory_incorrect = []
    mandatory_missing = []
    alarms_to_be_removed = []
    print('ADMIN active alarms count is {}'.format(len(available)))
    for mandatory_index in range(len(mandatory)):
        occurrence_counter = 0
        mandatory_element = mandatory[mandatory_index]
        mandatory_element = mandatory_element if isinstance(mandatory_element, dict) \
            else ast.literal_eval(mandatory_element)
        mandatory_alarm_string = _create_manadatory_alarm_string(mandatory_element)
        mandatory_alarm_counter = int(mandatory_element['alarmCounter']) if 'alarmCounter' in mandatory_element \
            else None
        if 'faultName' in mandatory_element or 'alarmDetail' in mandatory_element or 'faultId' in mandatory_element:
            for available_index in range(len(available)):
                available_element = available[available_index]
                mismatch_counter = _compare_mandatory_with_available(mandatory_element, available_element)
                if mismatch_counter == 0:
                    alarms_to_be_removed.append(available_element)
                    occurrence_counter += 1
        else:
            mandatory_incorrect.append(
                                        '! MandatoryAlarm{} incorrect definition: at least faultName/alarmDetail'
                                        ' or faultId has to be defined'
                                        .format(mandatory_index + 1))
        if mandatory_alarm_counter is None and occurrence_counter == 0:
            mandatory_missing.append('- MandatoryAlarm{}: {} not available'.format(mandatory_index + 1,
                                                                                   mandatory_alarm_string[0]))
            print(mandatory_missing[-1])
        elif mandatory_alarm_counter is None:
            print('+ MandatoryAlarm{}: {} available {} time(s)'.format(mandatory_index + 1,
                                                                       mandatory_alarm_string[0], occurrence_counter))
        elif mandatory_alarm_counter == occurrence_counter:
            print('+ MandatoryAlarm{}: {};alarmCounter={} available {} time(s)'
                  .format(mandatory_index + 1, mandatory_alarm_string[0],
                          mandatory_alarm_counter, occurrence_counter))
        else:
            mandatory_missing.append('- MandatoryAlarm{}: {};alarmCounter={} available {} time(s)'
                                     .format(mandatory_index + 1, mandatory_alarm_string[0],
                                             mandatory_alarm_counter, occurrence_counter))
            print(mandatory_missing[-1])
    available_left = _remove_list_elements(available, alarms_to_be_removed)
    return [available_left, mandatory_incorrect, mandatory_missing]


def _create_manadatory_alarm_string(mandatory_alarm):
    global UNEXPECTED_ALARM_KEY_LIST
    mandatory_items_list = []
    mandatory_keys_list = []
    for key_tmp_name in mandatory_alarm.keys():
        key_org_name = _convert_mandatory_key_name(key_tmp_name)
        if key_org_name in ALLOWED_MANDATORY_KEYS_LIST:
            mandatory_items_list.append(key_org_name + '=' + mandatory_alarm[key_tmp_name])
            mandatory_keys_list.append(key_org_name)
            UNEXPECTED_ALARM_KEY_LIST.append(key_org_name) if key_org_name not in UNEXPECTED_ALARM_KEY_LIST \
                else UNEXPECTED_ALARM_KEY_LIST
    return [';'.join(sorted(mandatory_items_list)), sorted(mandatory_keys_list)]


def _create_available_alarm_string(available_alarm, mandatory_keys_list):
    available_items_list = []
    for key_name in mandatory_keys_list:
        if key_name in available_alarm:
            available_items_list.append(key_name + '=' + str(available_alarm[key_name]))
    return ';'.join(available_items_list)


def _compare_mandatory_with_available(mandatory_alarm, available_alarm):
    mismatch_counter = 0
    for key_tmp_name in mandatory_alarm.keys():
        key_org_name = _convert_mandatory_key_name(key_tmp_name)
        if key_org_name in ALLOWED_MANDATORY_KEYS_LIST:
            mandatory_alarm_regex = re.compile(mandatory_alarm[key_tmp_name])
            result = re.search(mandatory_alarm_regex, str(available_alarm[key_org_name])) \
                if key_org_name in available_alarm else False
        if not result:
            mismatch_counter += 1
    return mismatch_counter


def _convert_mandatory_key_name(key_name):
    return ALARM_KEY_MAPPING_DICT[key_name] if key_name in ALARM_KEY_MAPPING_DICT else key_name


def _admin_remove_allowed_alarms(available, allowed=None, allowed_key='faultName'):
    """Removes allowed alarms from available ones."""
    allowed = allowed if allowed else []
    alarms_to_be_removed = []
    for allowed_alarm_fault_name in allowed:
        occurrence_counter = 0
        for available_alarm in available:
            available_alarm_fault_name = str(available_alarm[allowed_key])
            result = re.search(allowed_alarm_fault_name, available_alarm_fault_name)
            if result is not None:
                alarms_to_be_removed.append(available_alarm)
                occurrence_counter += 1
        if occurrence_counter != 0:
            print('! Allowed alarm: {}={} available {} time(s)'.format(allowed_key,
                                                                       allowed_alarm_fault_name,
                                                                       occurrence_counter))
    available_left = _remove_list_elements(available, alarms_to_be_removed)
    return available_left


def _admin_log_unexpected_alarms(available):
    """Prints available left alarms as unexpected ones."""
    unexpected_alarms_list = []
    available_count = len(available)
    unexpected_alarms_list.append('ADMIN unexpected alarms count is {}'.format(available_count))
    print(unexpected_alarms_list[0])
    for available_index in range(available_count):
        available_element = dict(available[available_index])
        available_alarm_string = _create_available_alarm_string(available_element, sorted(UNEXPECTED_ALARM_KEY_LIST))
        unexpected_alarms_list.append('- UnexpectedAlarm{}: {} available'.format(available_index + 1,
                                                                                 available_alarm_string))
        print(unexpected_alarms_list[-1])
    return unexpected_alarms_list


def _remove_list_elements(list_main, list_remove):
    """Removes list elements from main list."""
    list_left = list_main[:]
    for element in list_remove:
        while element in list_left:
            list_left.remove(element)
    return list_left
