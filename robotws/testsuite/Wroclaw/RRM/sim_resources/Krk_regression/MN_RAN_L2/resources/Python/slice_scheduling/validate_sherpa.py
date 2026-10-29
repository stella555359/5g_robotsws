# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainers: Mateusz Adamek
:contact: mateusz.adamek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import re
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console
from validate_functions import check_msg_with_values_in_frame


class SHERPAError(Exception):
    pass


def read_csv_as_txt(file_path):
    with open(file_path, 'r+') as csv:
        content = csv.read()
    return content.split('\n')


def check_at_least_one_print_with_expected_values_in_sherpa(csv_file, messages_to_check, expected_values):
    csv_content = read_csv_as_txt(csv_file)
    collected_values = __get_all_expected_msgs_in_csv_file(csv_content, messages_to_check)
    errors = __check_how_many_gathered_values_match_expected(collected_values, expected_values)


def check_all_msgs_in_procent_of_prints_have_value(csv_file, messages_to_check, expected_values, procent=90):
    csv_content = read_csv_as_txt(csv_file)
    collected_values = __get_all_expected_msgs_in_csv_file(csv_content, messages_to_check)
    errors = __check_how_many_gathered_values_match_expected(collected_values, expected_values)
    recived = (1 - errors/len(collected_values)) * 100
    if recived < procent:
        raise SHERPAError(f'Too many prints with wrong values, expected {procent}%, but recived  {recived}%,')
    logger_console(f'Prints with wrong values {100-recived}%')


def __check_how_many_gathered_values_match_expected(gathered, expected):
    wrong_values = 0
    for idx_msg, msg in enumerate(gathered):
        values = expected[idx_msg]
        error = None
        for group in msg:
            if isinstance(group, tuple):
                for idx, element in enumerate(group):
                    value = values[idx]
                    error = check_msg_with_values_in_frame(element, value)
        if error:
            wrong_values += 1
    return wrong_values


def __get_all_expected_msgs_in_csv_file(csv, messages_to_check):
    collected_values = [list() for msg in messages_to_check]
    for line in csv:
        for idx, msg in enumerate(messages_to_check):
            matched = re.findall(msg, line)
            if matched:
                collected_values[idx].append(matched[0])
    if not collected_values:
        raise SHERPAError(f'No messages in any line!')
    return collected_values
