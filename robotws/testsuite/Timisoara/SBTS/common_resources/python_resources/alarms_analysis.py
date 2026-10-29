# -*- coding: utf-8 -*-
"""
:description: Keywords to help parsing and filtering lists of alarms
:copyright: Nokia Networks
:author: Alexandru Stamp
:contact: alexandru.stamp@nokia.com
:maintainer: I_BTSAUTO_DEV_TSR@internal.nsn.com
:contact: I_BTSAUTO_DEV_TSR@internal.nsn.com
"""

import logging
import re

from tools import (_filter_alarms,  # type: ignore
                   _make_pretty_alarm)
from tools import convert_tuple_to_dict  # type: ignore
from six import text_type

LTE_SIMPLIFIED_DICT = {'alarmInformation': {'alarmNumber': None, 'alarmText': {'alarmDetail': None}, 'faultId': None}}
SBTS16_SIMPLIFIED_DICT = {'number': None, 'text': None, 'faultId': None}


def get_wcdma_alarms_from_file(alarm_file, keys=('alarm', 'detail')):
    """
    Parse a txt file obtained with CLI 'getactivealarms.sh' (has to be executed earlier) and return list
    of active alarms
    :param alarm_file: text file containing alarms table
    :param keys: text file containing alarms table
    :return: list of current_alarms in dictionary format, with defined keys (default are `alarm`, `detail`)
    """
    alarms_rule = re.compile(text_type(r'^.*?\s(\d{1,})\s+(\d{1,}|Core).*$'), flags=re.MULTILINE)
    alarm_str = alarm_file
    current_alarms = re.findall(alarms_rule, alarm_str)
    current_alarms = [convert_tuple_to_dict(single_tuple, keys) for single_tuple in current_alarms]
    return current_alarms


def get_btssm_alarms_from_file(alarms_data, possible_severities=["Minor", "Major", "Critical"]):
    """
    Parse an txt file obtained with CLI 'getactivealarms.sh' (has to be executed earlier) and return list
    of active alarms dictionaries
    :param alarms_data : text file containing alarms table
    :param possible_severities: possible available severities in alarms_data
    :return: list of dictionaries where single dictionary has keys
    """
    severities_regex = "({})".format("|".join(possible_severities))
    alarms_rule = re.compile(
        text_type(r'(\d+)\s+(\d+|Core)\s+(\d+)?(\s.*)\s+{severities}\s+([\s\d.:+]+)(.*)'.format(
            severities=severities_regex)))
    current_alarms = re.findall(alarms_rule, alarms_data)
    keys = ['alarm', 'faultId', 'rawFaultId', 'source', 'severity', 'time', 'description']
    return [dict(list(zip(keys, [v.strip() for v in values]))) for values in current_alarms]


def convert_wcdma_patterns(patterns, keys=('alarm', 'detail')):
    """
    Convert tuples to dicts containing keys ('alarm' and 'detail' as defaults).
    :param patterns: list of patterns (list or tuple)
    :param keys: alarms' attributes to set (list)
    :return: list of patterns in dictionary style
    """

    new_patterns = [convert_tuple_to_dict(single_tuple, keys) for single_tuple in patterns]
    return new_patterns


def get_filtered_alarms(current_alarms, expected_patterns=list(), ignored_patterns=list(), critical_patterns=list(),
                        simplified_dictionary=LTE_SIMPLIFIED_DICT):
    """
    Filter given alarm lists using given patterns
    :param current_alarms: list of alarms in dict format
    :param expected_patterns: list of expected alarms patterns,it should contain one pattern for each expected alarm
    :param ignored_patterns: list of ignored alarms patterns, one pattern will be used multiply
    :param critical_patterns: list of critical alarms patterns, one pattern will be used multiply
    :param simplified_dictionary: if set, define which keys of alarms should be printed in the report
    :return: found_expected_alarms (list), missing_alarms_patterns (list), critical_alarms (list),
    ignored_alarms (list), warnings (list)
    """  # noqa
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
    found_critical_alarms, found_not_classified_alarms, not_found_critical_patterns = _filter_alarms(
        found_other_alarms,
        critical_patterns,
        simplified_dictionary=simplified_dictionary,
        use_pattern_once=False
    )
    return (found_expected_alarms, not_found_expected_patterns,
            found_critical_alarms, found_ignored_alarms, found_not_classified_alarms)


def print_alarms(found_expected_alarms=list(), missing_alarms_patterns=list(), critical_alarms=list(),
                 ignored_alarms=list(), warnings=list(), simplified_dictionary=LTE_SIMPLIFIED_DICT):
    """
    It print given alarms lists to TC report with proper severities
    :param found_expected_alarms: list of alarms in dict format, log severity: INFO
    :param missing_alarms_patterns: list of alarms in dict format, log severity: ERR
    :param critical_alarms: list of alarms in dict format, log severity: ERR
    :param ignored_alarms: list of alarms in dict format, log severity:  INFO
    :param warnings: list of alarms in dict format, log severity: WARN
    :param simplified_dictionary: if set, define which keys of alarms should be printed in the report
    :return: None
    """
    if ignored_alarms:
        ignored_alarms = [_make_pretty_alarm(alarm, simplified_dictionary)
                          for alarm in ignored_alarms if simplified_dictionary] or ignored_alarms

        logging.info("Ignored alarms detected: {}".format(ignored_alarms))

    if found_expected_alarms:
        found_expected_alarms = [_make_pretty_alarm(alarm, simplified_dictionary)
                                 for alarm in found_expected_alarms
                                 if simplified_dictionary] or found_expected_alarms

        logging.info('Expected alarms detected: {}'.format(found_expected_alarms))

    if warnings:
        warnings = [_make_pretty_alarm(alarm, simplified_dictionary)
                    for alarm in warnings
                    if simplified_dictionary] or warnings
        logging.warning("Unexpected non critical alarms detected: {}".format(warnings))

    if missing_alarms_patterns:
        missing_alarms_patterns = [_make_pretty_alarm(alarm, simplified_dictionary)
                                   for alarm in missing_alarms_patterns
                                   if simplified_dictionary] or missing_alarms_patterns

        logging.error('Missing alarms: {}'.format(missing_alarms_patterns))

    if critical_alarms:
        critical_alarms = [_make_pretty_alarm(alarm, simplified_dictionary)
                           for alarm in critical_alarms
                           if simplified_dictionary] or critical_alarms
        logging.error('Critical alarms detected: {}'.format(critical_alarms))
