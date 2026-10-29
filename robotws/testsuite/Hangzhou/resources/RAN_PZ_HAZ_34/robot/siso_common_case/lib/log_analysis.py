# -*- coding: utf-8 -*-
"""
This module provides utilities for cloud analysis in the context of a RAN PZ HAZ 34 test suite.

:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""

import csv
import logging


def check_tti_log_file(tti_log_file, pair_percent=0.8, direction='dl'):
    """
    This function checks a TTI log file and asserts if the count of 'MUPAIR' in the specified direction is less than
    a certain percentage of the total line count.

    :param tti_log_file: The path to the TTI log file to be checked.
    :type tti_log_file: str
    :param pair_percent: The minimum percentage of 'MUPAIR' count to the total line count. Default is 0.8.
    :type pair_percent: float
    :param direction: The direction to check for 'MUPAIR'. Can be 'dl' for downlink or 'ul' for uplink. Default is 'dl'.
    :type direction: str
    :raises AssertionError: If the count of 'MUPAIR' is less than pair_percent of the total line count.
    """
    pair_count = 0
    total_count = 0
    date_name = 'dlFdSchedData' if direction == 'dl' else 'ulFdSchedData'
    check_name = 'muStatus' if direction == 'dl' else 'ulMuStatus'
    check_status_list = ['MUPAIR'] if direction == 'dl' else ['MUPAIRED_TAPERING', 'MUPAIRED_NO_TAPERING']

    with open(tti_log_file, 'r') as file:
        reader = csv.reader(file)
        header = next(reader)
        index = header.index(check_name)

        for row in reader:
            if str(row[0]) != str(date_name):
                continue
            total_count += 1
            if row[index] in check_status_list:
                pair_count += 1

    logging.info(f"mu pair count is {pair_count}, total line count is {total_count}")
    error_info = f"mu pair count is {pair_count} less than expect {pair_percent * total_count} of total line count"
    assert pair_count >= pair_percent * total_count, error_info
