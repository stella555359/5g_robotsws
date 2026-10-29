# -*- coding: utf-8 -*-
# @Time    : 2024/11/25 21:25
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_counter.py
# @Software: PyCharm
import time
import datetime


def get_target_cell_recent_counters(counters, mrbts, nrbts):
    cell_infos = counters["BTS"][mrbts][nrbts]
    counter_values = {}
    for cell in cell_infos:
        counter_values[cell] = {}
        cell_info = cell_infos[cell]
        for tag in cell_info:
            for counter_name in cell_info[tag]:
                time_list = cell_info[tag][counter_name].keys()
                counter_values[cell][counter_name] = cell_info[tag][counter_name][max(time_list)]
    return counter_values


def wait_until_next_5_min(extra_sleep_time=120):
    now = datetime.datetime.now()
    seconds_past_last_5_min = (now.minute % 5) * 60 + now.second
    seconds_until_next_5_min = 300 - seconds_past_last_5_min
    time.sleep(seconds_until_next_5_min)
    if extra_sleep_time:
        time.sleep(int(extra_sleep_time))


def assert_values_close(param1, param2, threshold=3):
    """
    Assert that the absolute difference between the two parameters is less than or equal to a given threshold,
    and that param1 is greater than 0.

    :param param1: First parameter (must be > 0)
    :param param2: Second parameter
    :param threshold: The maximum allowed absolute difference
    :raises AssertionError: If the conditions are not met
    """
    print(abs(param1 - param2))
    assert param1 > 0, "param1 must be greater than 0"
    assert abs(param1 - param2) <= threshold, f"The absolute difference must be <= {threshold}"
