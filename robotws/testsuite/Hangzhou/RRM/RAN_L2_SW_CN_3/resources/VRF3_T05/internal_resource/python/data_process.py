# -*- coding: utf-8 -*-
# @Time    : 2025/5/16 10:33
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : data_process.py
# @Software: PyCharm


def is_values_close(value1, value2, tolerance_percent=3):
    """
    Determine whether two values are close, with the difference within a specified percentage range.
    :param value1: The first value
    :param value2: The second value
    :param tolerance_percent: Tolerance percentage, default is 3%
    :return: Boolean value, True if close, False otherwise
    """
    difference = abs(value1 - value2)
    tolerance = tolerance_percent / 100 * max(value1, value2)
    return difference <= tolerance


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
