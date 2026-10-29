# -*- coding: utf-8 -*-
"""
Keywords to help filtering lists of alarms
:copyright: Nokia Networks
:author: Amaand.li@nokia-sbell.com
:maintainer: Amaand.li@nokia-sbell.com
"""

import logging
import re

LTE_SIMPLIFIED_DICT = {'alarmInformation': {'alarmNumber': None, 'alarmText': {'alarmDetail': None}, 'faultId': None}}


class AlarmAnalysis(object):

    def __init__(self):
        super(AlarmAnalysis, self).__init__()

    @staticmethod
    def get_filtered_alarms(current_alarms, expected_patterns=list(), ignored_patterns=list(), critical_patterns=list(),
                            simplified_dictionary=LTE_SIMPLIFIED_DICT):
        """
        Filter given alarm lists using given patterns

        **Input Parameters**

        +-----------------------+-------+---------------------------------------------------------------------+
        | Parameter Name        | Man.  | Description                                                         |
        +=======================+=======+========================================================================+
        | current_alarms        | No    | list of alarms in dict format                                            |
        +-----------------------+-------+-----------------------------------------------------------------------+
        | expected_patterns     | No    | list of expected alarms patterns, it should contain one pattern for 
        each expected alarm  |
        +-----------------------+-------+---------------------------------------------------------------------------+
        | ignored_patterns      | No    | list of ignored alarms patterns, one pattern will be used multiply         |
        +-----------------------+-------+-----------------------------------------------------------------------+
        | critical_patterns     | No    | list of critical alarms patterns, one pattern will be used multiply    |
        +-----------------------+-------+-----------------------------------------------------------------------+
        | simplified_dictionary | No    | if set, define which keys of alarms should be printed in the report   |
        +-----------------------+-------+----------------------------------------------------------------------+

        **RETURN VALUE**

        - found_expected_alarms (list), missing_alarms_patterns (list),
        critical_alarms (list), ignored_alarms (list), warnings (list)

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

    @staticmethod
    def print_alarms(found_expected_alarms=list(), missing_alarms_patterns=list(), critical_alarms=list(),
                     ignored_alarms=list(), warnings=list(), simplified_dictionary=LTE_SIMPLIFIED_DICT):
        """
        It print given alarms lists to TC report with proper severities

        **Input Parameters**

        +---------------------------+-------+--------------------------------------------------------------------------+
        | Input Parameters          | Man.  | Description                                                              |
        +===========================+=======+==========================================================================+
        | found_expected_alarms     | No    | list of alarms in dict format, log severity: INFO                        |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | missing_alarms_patterns   | No    | list of alarms in dict format, log severity: ERR                         |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | critical_alarms           | No    | list of alarms in dict format, log severity: ERR                         |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | ignored_alarms            | No    | list of alarms in dict format, log severity: INFO                        |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | warnings                  | No    | list of alarms in dict format, log severity: WARN                        |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | simplified_dictionary     | No    | if set, define which keys of alarm dict should be printed in the report  |
        +---------------------------+-------+--------------------------------------------------------------------------+

        **RETURN VALUE**

        - None

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


def _filter_alarms(alarms_list, filter_patterns, simplified_dictionary=None, use_pattern_once=True):
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
    new_dict = {}
    for key, value in recogn_dict.items():
        if isinstance(value, dict):
            new_dict[key] = _make_pretty_alarm(source_dict.get(key, {}), value)
        else:
            new_dict[key] = str(source_dict.get(key, ''))
    return new_dict
