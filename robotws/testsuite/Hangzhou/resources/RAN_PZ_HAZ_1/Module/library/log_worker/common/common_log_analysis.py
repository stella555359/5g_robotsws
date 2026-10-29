# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Contacts: renhui-david.liu@nokia-sbell.com
Description: this script is used to
"""

import os

from process_csv_file import filter_csv_rows_using_and_conditions, filter_csv_rows_using_or_conditions, \
    check_statistics_using_and_conditions, check_statistics_using_or_conditions
from log_metadata import load_log_metadata
from copy import deepcopy

DEFAULT_ROW_COUNT = 10


def check_rules_from_csv_file(csv_file_path, analysis_dict):
    """
    *Usage:*
        - Keyword
        - This keyword is used to verify a CSV file with rules specified in analysis_dict.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    if "check_rules" not in analysis_dict or not analysis_dict["check_rules"]:
        raise Exception('check_rules not existing or empty')

    # check basic rules existing
    check_rules = analysis_dict["check_rules"]
    if "basic_rules" not in check_rules or not check_rules["basic_rules"]:
        raise Exception('basic_rules not existing or empty')
    basic_rules = deepcopy(check_rules["basic_rules"])
    logic_operation = basic_rules.pop(0)
    if logic_operation not in ["and", "or"]:
        raise Exception('The operator in basic_rules is not and/or')
    matching_rows = []
    row_nums = []
    if logic_operation == "and":
        matching_rows, row_nums = filter_csv_rows_using_and_conditions(csv_file_path, basic_rules)
    if logic_operation == "or":
        matching_rows, row_nums = filter_csv_rows_using_or_conditions(csv_file_path, basic_rules)
    if not matching_rows:
        return False, None
    row_count = DEFAULT_ROW_COUNT
    if "row_count" in analysis_dict:
        row_count = analysis_dict["row_count"]
    if "statistics_rules" not in check_rules or not check_rules["statistics_rules"]:
        if len(matching_rows) < row_count:
            return True, [matching_rows, row_nums]
        else:
            return True, [matching_rows[:row_count], row_nums[:row_count + 1]]

    statistics_rules = deepcopy(check_rules["statistics_rules"])
    logic_operation_2 = statistics_rules.pop(0)
    result = False
    if logic_operation_2 == "and":
        result = check_statistics_using_and_conditions(matching_rows, statistics_rules)
    if logic_operation_2 == "or":
        result = check_statistics_using_or_conditions(matching_rows, statistics_rules)

    if len(matching_rows) < row_count:
        return result, [matching_rows, row_nums]
    else:
        return result, [matching_rows[:row_count], row_nums[:row_count + 1]]


def validate_log_expected(log_type, log_path, log_metadata=None):
    """
    *Usage:*
        - Keyword
        - This keyword is used to validate whether log is expected.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    if not os.path.exists(log_path):
        raise Exception(f"The log path {log_path} does not exist")

    if log_type == 'wireshark':
        if not (log_path.endswith('.pcap') or log_path.endswith('.gz')):
            raise Exception(f"The wireshark log path {log_path} does not have a .pcap or .gz extension")
    elif log_type == 'tti' and not log_path.endswith('.zip'):
        raise Exception(f"The tti log path {log_path} does not have a .zip extension")
    elif log_type == 'bip':
        log_metadata = load_log_metadata(log_path)
        if log_metadata['product_type'] in ['gnb', 'enb'] and not log_path.endswith('.zip'):
            raise Exception(f"The classical bts tti log path {log_path} does not have a .zip extension")
        elif log_metadata['product_type'] in ['vdu', 'vcu'] and not log_path.endswith('.pcap'):
            raise Exception(f"The cloudRAN bts tti log path {log_path} does not have a .pcap extension")
