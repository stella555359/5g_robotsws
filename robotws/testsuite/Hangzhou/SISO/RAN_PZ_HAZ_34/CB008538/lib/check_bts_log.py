# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Zhang Xuewen
:contact: xuewen.zhang@nokia-sbell.com
:maintainer: Zhang Xuewen
:contact: xuewen.zhang@nokia-sbell.com
"""
import re
from datetime import *


def get_timestamp_by_filter(
    file_log_name="../rureset_log.txt", filter_name="RESET_IND-1"
):
    """
    This keyword is used to find timestamp like 2022-07-14T06:19:33.393Z.
    """
    regex = "(\\d{4}-\\d{1,2}-\\d{1,2}T\\d{1,2}:\\d{1,2}:\\d{1,2})"
    with open(file_log_name) as f:
        for line in f.readlines():
            if filter_name in line:
                t = re.search(regex, line)
                if t:
                    return t.group(1)
    return None


def calculate_duration(start, end):
    try:
        start = datetime.strptime(start, "%Y-%m-%dT%H:%M:%S")
        end = datetime.strptime(end, "%Y-%m-%dT%H:%M:%S")
        duration = end - start
        print(start, end)
        print(duration.seconds)
        return duration.seconds
    except TypeError as e:
        print("except:", e)
        print("get reset time failed:", start, end)
        return None


def get_ru_reset_duration(file_log_name="../rureset_log.txt"):
    start = get_timestamp_by_filter(file_log_name, filter_name="availabilityStatus = NotInstalled")
    end = get_timestamp_by_filter(file_log_name, filter_name="RESET_RESULT-1 requested, success: true")
    return calculate_duration(start, end)


def get_ru_power_reset_duration(file_log_name="../rupower_reset_log.txt"):
    start = get_timestamp_by_filter(
        file_log_name, filter_name="objToUpdate: /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L"
    )
    end = get_timestamp_by_filter(file_log_name, filter_name="Radio Module detected")
    return calculate_duration(start, end)
