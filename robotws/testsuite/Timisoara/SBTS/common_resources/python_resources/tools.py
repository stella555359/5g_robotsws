"""
:description: General KWs
:copyright: Nokia Networks
:author: Alexandru Stamp
:contact: alexandru.stamp@nokia.com
:maintainer: I_BTSAUTO_DEV_TSR@internal.nsn.com
:contact: I_BTSAUTO_DEV_TSR@internal.nsn.com
"""

import logging
import re
import subprocess


def _filter_alarms(alarms_list, filter_patterns, simplified_dictionary=None, use_pattern_once=True):
    """
    Filter Alarms based on a supplied pattern
    :param alarm_list: alarm list
    :param filter_patterns: patterns to filter the alarms
    :param simplified_dictionary: if set, define which keys of alarms should be printed in the report
    :return: alarms that mathced, alarms that were not matched, patterns that were not matched
    """
    matched_alarms = []
    left_patterns = filter_patterns[:]
    left_alarms = alarms_list[:]
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


def _matching_dicts(pattern_dict, source_dict):
    """
    Check if a source dict matches a pattern dict
    :param pattern_dict: pattern dictionary
    :param source_dict: dictionary that will be checked
    :return: boolean based on matching
    """
    for key, value in pattern_dict.items():
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
    """
    Check if a source dict matches a pattern dict
    :param pattern_dict: pattern dictionary
    :param source_dict: dictionary that will be checked
    :return: boolean based on matching
    """
    new_dict = {}
    for key, value in recogn_dict.items():
        if isinstance(value, dict):
            new_dict[key] = _make_pretty_alarm(source_dict.get(key, {}), value)
        else:
            new_dict[key] = str(source_dict.get(key, ''))
    return new_dict


def convert_tuple_to_dict(set_tuple, new_keys=list()):
    """
    Convert tuple to dictionary combining values from set_tuple with keys from new_keys respectively to their
    indexes
    :param set_tuple: given tuple or list
    :param new_keys: list of keys to use, if not set, element's indexes will be used as keys
    :return: Dictionary containing values from set_tuple under keys from new_keys respectively to their indexes
    """
    converted_dict = {}
    for index, element in enumerate(set_tuple):
        new_key = get_list_element(new_keys, index, index)
        converted_dict[new_key] = element

    return converted_dict


def get_list_element(some_list, element_index, default=None):
    """
    Return the element with given index if exist in list, else default. If default is not given, it defaults to
    None, so that this method never raises a IndexError.
    :param some_list: given tuple or list
    :param element_index : element index to get
    :param default : default value of element not existing on list
    :return: list element or default
    """
    try:
        element = some_list[element_index]
    except IndexError:
        element = default
    return element


def list_diff(a, b):
    """
    This method converts two lists into sets and then calculates the difference between them.
    :param a: first given tuple or list
    :param b: second given tuple or list
    :return: list that consists the difference between two provided lists
    """
    return list(set(a) - set(b))
