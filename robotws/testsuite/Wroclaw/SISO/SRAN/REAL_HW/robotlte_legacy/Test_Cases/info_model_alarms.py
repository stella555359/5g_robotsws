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
ALARM_SEVERITY_MAPPING_DICT = {'a1': 'Minor', 'a2': 'Major', 'a3': 'Critical'}
ALARM_KEY_MAPPING_DICT = {'faultName': 'alarmDetail',
                          'severity': 'alarmSeverity', 'alarmingResource': 'alarmingResourceDN'}
ALLOWED_MANDATORY_KEYS_LIST = ['alarmDetail', 'alarmSeverity', 'alarmingResourceDN', 'distName',
                               'faultId', 'impactedCells']


def info_model_alarms_check(available, allowed=None, mandatory=None):
    """Checks info model mandatory and allowed alarms inside provided list of active alarms.

    :param list available: list of active info model alarms (returned by "Info Model Alarms Get Active" KW).
    :param list allowed: (optional) list of allowed alarms defined by alarmDetail attribute
     (regex is supported in Value).
    :param list mandatory: (optional) list of dictionaries with mandatory alarms defined by alarmDetail/faultName,
     faultId, alarmSeverity/severity, \
                           distName, impactedCells, alarmingResourceDN/alarmingResource, alarmCounter attributes. \
                           At least alarmDetail/faultName or faultId dictionary key and its value has to be defined
                            (regex is supported in Value).

    Examples for FL SW:
        allowed = ['(?i)vendor bts certificate', 'Synchronization lost', '.*BTS booted at.+']
        mandatory = [{'alarmDetail': 'Unit blocked', 'faultId': '48', 'alarmSeverity': 'Major',
         'distName': '.*LNCEL-60000.*'}, \
                     {'alarmDetail': 'Unit blocked', 'faultId': '48', 'distName': '.*LNCEL-60001.*'}, \
                     {'faultName': 'Unit blocked', 'severity': 'Major', 'distName': '.*LNCEL-60002.*'}, \
                     {'faultName': 'Unit blocked', 'alarmSeverity': 'Major', 'alarmCounter': '4'}, \
                     {'faultId': '48', 'alarmSeverity': 'Major', 'distName': '.*LNCEL-60004.*'}, \
                     {'alarmDetail': 'Transmission path failure'}]

    Examples for SBTS SW:
        allowed = ['(?i)vendor bts certificate', 'Synchronization lost', '.*BTS booted at.+']
        mandatory = [{'alarmDetail': 'Unit blocked', 'faultId': '48', 'alarmSeverity': 'Major',
         'impactedCells': '.*LNCEL-60000.*'}, \
                     {'alarmDetail': 'Unit blocked', 'faultId': '48', 'impactedCells': '.*LNCEL-60001.*'}, \
                     {'faultName': 'Unit blocked', 'severity': 'Major', 'impactedCells': '.*LNCEL-60002.*'}, \
                     {'faultName': 'Unit blocked', 'alarmSeverity': 'Major', 'alarmCounter': '4'}, \
                     {'faultId': '48', 'alarmSeverity': 'Major', 'impactedCells': '.*LNCEL-60004.*'}, \
                     {'alarmDetail': 'Transmission path failure', 'faultId': '4003', 'severity': 'Minor',
                      'alarmingResourceDN': '.*LNCEL-60000.*'}, \
                     {'faultName': 'Transmission path failure', 'alarmSeverity': 'Minor',
                      'alarmingResource': '.*LNCEL-60001.*'}, \
                     {'faultName': 'Transmission path failure', 'faultId': '4003', 'severity': 'Minor',
                      'alarmingResourceDN': '.*LNCEL-60002.*'}]
    """
    global UNEXPECTED_ALARM_KEY_LIST
    UNEXPECTED_ALARM_KEY_LIST = ['faultId', 'alarmDetail', 'alarmSeverity']
    allowed = allowed if allowed is not None else []
    mandatory = mandatory if mandatory is not None else []
    available = available[:]
    output_after_mandatory = _im_remove_mandatory_alarms(available, mandatory)
    output_after_allowed = _im_remove_allowed_alarms(output_after_mandatory[0], allowed)
    output_after_unexpected = _im_log_unexpected_alarms(output_after_allowed)
    if len(output_after_mandatory[1]):
        raise Exception('\n'.join(output_after_mandatory[1]))
    if len(output_after_allowed) != 0 or len(output_after_mandatory[2]) != 0:
        raise Exception('\n' + '\n'.join(output_after_mandatory[2]) + '\n' + '\n'.join(output_after_unexpected))


def _im_remove_mandatory_alarms(available, mandatory=None):
    """Removes mandatory alarms from available ones."""
    mandatory = mandatory if mandatory is not None else []
    mandatory_incorrect = []
    mandatory_missing = []
    alarms_to_be_removed = []
    print('Info Model active alarms count is {}'.format(len(available)))
    for mandatory_index in range(len(mandatory)):
        occurrence_counter = 0
        mandatory_element = mandatory[mandatory_index]
        manadatory_alarm_string = _create_manadatory_alarm_string(mandatory_element)
        mandatory_element = mandatory_element if isinstance(mandatory_element, dict) \
            else ast.literal_eval(mandatory_element)
        mandatory_alarm_counter = int(mandatory_element['alarmCounter']) \
            if 'alarmCounter' in mandatory_element else None
        if 'faultName' in mandatory_element or 'alarmDetail' in mandatory_element or 'faultId' in mandatory_element:
            for available_index in range(len(available)):
                available_element = available[available_index]
                available_alarm_string = _create_available_alarm_string(available_element, manadatory_alarm_string[1])
                mismatch_counter = _compare_mandatory_with_available(manadatory_alarm_string[0], available_alarm_string)
                if mismatch_counter == 0:
                    alarms_to_be_removed.append(available_element)
                    occurrence_counter += 1
        else:
            mandatory_incorrect.append('! MandatoryAlarm{} incorrect definition: at least faultId has to be defined'
                                       .format(mandatory_index + 1))
        if mandatory_alarm_counter is None and occurrence_counter == 0:
            mandatory_missing.append('- MandatoryAlarm{}: {} not available'.format(mandatory_index + 1,
                                                                                   manadatory_alarm_string[0]))
            print(mandatory_missing[-1])
        elif mandatory_alarm_counter is None:
            print('+ MandatoryAlarm{}: {} available {} time(s)'.format(mandatory_index + 1,
                                                                       manadatory_alarm_string[0], occurrence_counter))
        elif mandatory_alarm_counter == occurrence_counter:
            print('+ MandatoryAlarm{}: {};alarmCounter={} available {} time(s)'
                  .format(mandatory_index + 1, manadatory_alarm_string[0],
                          mandatory_alarm_counter, occurrence_counter))
        else:
            mandatory_missing.append('- MandatoryAlarm{}: {};alarmCounter={} available {} time(s)'
                                     .format(mandatory_index + 1,
                                             manadatory_alarm_string[0], mandatory_alarm_counter, occurrence_counter))
            print(mandatory_missing[-1])
    available_left = _remove_list_elements(available, alarms_to_be_removed)
    return [available_left, mandatory_incorrect, mandatory_missing]


def _compare_mandatory_with_available(mandatory_alarm_string, available_alarm_string):
    mismatch_counter = 0
    for mandatory_element, available_element in zip(mandatory_alarm_string.split(';'),
                                                    available_alarm_string.split(';')):
        result = re.search(str(mandatory_element), str(available_element))
        if result is None:
            mismatch_counter += 1
    return mismatch_counter


def _convert_alarm_severity(alarm_severity):
    return ALARM_SEVERITY_MAPPING_DICT[alarm_severity]\
        if alarm_severity in ALARM_SEVERITY_MAPPING_DICT else alarm_severity


def _create_manadatory_alarm_string(mandatory_alarm):
    global UNEXPECTED_ALARM_KEY_LIST
    mandatory_alarm = mandatory_alarm if isinstance(mandatory_alarm, dict) else ast.literal_eval(mandatory_alarm)
    mandatory_items_list = []
    mandatory_keys_list = []
    for key_tmp_name in mandatory_alarm.keys():
        key_org_name = _convert_mandatory_key_name(key_tmp_name)
        key_org_value = (
            mandatory_alarm[key_tmp_name] if key_org_name != 'alarmSeverity'
            else _convert_alarm_severity(mandatory_alarm[key_tmp_name]))
        if key_org_name in ALLOWED_MANDATORY_KEYS_LIST:
            mandatory_items_list.append(key_org_name + '=' + key_org_value)
            mandatory_keys_list.append(key_org_name)
            UNEXPECTED_ALARM_KEY_LIST.append((key_org_name) if key_org_name not in UNEXPECTED_ALARM_KEY_LIST
                                             else UNEXPECTED_ALARM_KEY_LIST)
    return [';'.join(sorted(mandatory_items_list)), sorted(mandatory_keys_list)]


def _convert_mandatory_key_name(key_name):
    return ALARM_KEY_MAPPING_DICT[key_name] if key_name in ALARM_KEY_MAPPING_DICT else key_name


def _get_available_alarm_detail(available_alarm):
    """Gets value of alarmDetail from available alarm object."""
    return available_alarm['alarmInformation']['alarmText']['alarmDetail'] \
        if 'alarmInformation' in available_alarm else \
        available_alarm['alarmText']['alarmDetail']


def _get_available_alarm_severity(available_alarm):
    """Gets value of alarmSeverity from available alarm object."""
    return (available_alarm['alarmSeverity']
            if 'alarmSeverity' in available_alarm else available_alarm['alarmInformation']['alarmSeverity'])


def _get_available_fault_id(available_alarm):
    """Gets value of faultId from available alarm object."""
    return (available_alarm['faultId']
            if 'faultId' in available_alarm else available_alarm['alarmInformation']['faultId'])


def _create_available_alarm_string(available_alarm, mandatory_keys_list):
    available_alarm_key_mapping_dict = {
        'alarmDetail': _get_available_alarm_detail(available_alarm),
        'alarmSeverity': _get_available_alarm_severity(available_alarm),
        'alarmingResourceDN': (available_alarm['alarmingResourceDN']
                               if 'alarmingResourceDN' in available_alarm else None),
        'distName': available_alarm['dist_name'] if 'dist_name' in available_alarm else None,
        'faultId': _get_available_fault_id(available_alarm),
        'impactedCells': available_alarm['ratsImpact'] if 'ratsImpact' in available_alarm else None}
    available_items_list = []
    for key_name in mandatory_keys_list:
        available_items_list.append(key_name + '=' + str(available_alarm_key_mapping_dict[key_name]))
    return ';'.join(available_items_list)


def _im_remove_allowed_alarms(available, allowed):
    """Removes allowed alarms from available ones."""
    alarms_to_be_removed = []
    for allowed_alarm_fault_name in allowed:
        occurrence_counter = 0
        for available_alarm in available:
            available_alarm_fault_name = _get_available_alarm_detail(available_alarm)
            result = re.search(allowed_alarm_fault_name, available_alarm_fault_name)
            if result is not None:
                alarms_to_be_removed.append(available_alarm)
                occurrence_counter += 1
        if occurrence_counter != 0:
            print('! Allowed alarm: alarmDetail={} available {} time(s)'.format(
                allowed_alarm_fault_name, occurrence_counter))
    available_left = _remove_list_elements(available, alarms_to_be_removed)
    return available_left


def _im_log_unexpected_alarms(available):
    """Prints available left alarms as unexpected ones."""
    unexpected_alarms_list = []
    available_count = len(available)
    unexpected_alarms_list.append('Info Model unexpected alarms count is {}'.format(available_count))
    print(unexpected_alarms_list[0])
    for available_index in range(available_count):
        available_element = dict(available[available_index])
        available_alarm_string = _create_available_alarm_string(available_element, UNEXPECTED_ALARM_KEY_LIST)
        unexpected_alarms_list.append('- UnexpectedAlarm{}: {} available'.format(
            available_index + 1, available_alarm_string))
        print(unexpected_alarms_list[-1])
    return unexpected_alarms_list


def _remove_list_elements(list_main, list_remove):
    """Removes list elements from main list."""
    list_left = list_main[:]
    for element in list_remove:
        while element in list_left:
            list_left.remove(element)
    return list_left
