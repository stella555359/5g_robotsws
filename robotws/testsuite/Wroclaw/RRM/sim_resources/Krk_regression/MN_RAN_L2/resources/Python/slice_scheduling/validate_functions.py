# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""


class VariableManager:
    """
    A class for storing values between individual code executions.
    """
    def __init__(self):
        self.variables = {}

    def set_variable(self, value):
        """
        The method adds the value to the store, provided as an argument, to the class instance.
        :param value: the value to the store
        :return: None
        """
        self.variables = value

    def get_variable(self):
        """
        The method returns a dictionary with the stored values.
        :return: type dict, a dictionary with the stored values.
        """
        return self.variables


class WrongValue(Exception):
    pass


def check_msg_with_values_in_frame(match, value):
    """
    The function compares the values provided as parameters and returns an error if the comparison does not yield a
    valid result.
    :param match: type any, a value found in logs
    :param value: type any, an expected value to compare with match
    :return: exception WrongValue or None
    """
    try:
        __check_value_exists(match, value)
        __check_value_is_callable(match, value)
        __check_value_equal_to_value(match, value)
        __check_value_among_values(match, value)
        __check_value_in_range(match, value)
        __check_value_equal_when_is_list(match, value)
    except WrongValue as wv:
        return str(wv)


def __check_value_equal_when_is_list(match, value):
    if isinstance((match, value), list):
        if match != value:
            msg = f'Expected value {match} not equal to list {value}'
            raise WrongValue(msg)


def __check_value_in_range(match, value):
    if type(value) is tuple and not callable(value[0]):
        left_limit, right_limit = value
        if float(match) < left_limit or float(match) > right_limit:
            msg = f'Expected value {match} in range {value}'
            raise WrongValue(msg)


def is_sublist(sublist, main_list):
    for i in range(len(main_list) - len(sublist) + 1):
        if main_list[i:i + len(sublist)] == sublist:
            return True
    return False


def __check_value_among_values(match, value):
    if type(value) is list and type(match) is list:
        if is_sublist(match, value) is not True:
            msg = f'Expected value {match} among values {value}'
            raise WrongValue(msg)

    if type(value) is list and type(match) is not list:
        if match not in value:
            msg = f'Expected value {match} among values {value}'
            raise WrongValue(msg)


def __check_value_equal_to_value(match, value):
    if not isinstance(value, (list, tuple, bool)) and not callable(value):
        if type(value)(match) != value:
            msg = f'Expected value {value}, received value {match}'
            raise WrongValue(msg)


def __check_value_is_callable(match, value):
    error = None
    if callable(value):
        error = value(match)
    elif isinstance(value, tuple) and callable(value[0]):
        args = value[1:]
        error = value[0](match, *args)
    if error:
        raise WrongValue(str(error))


def __check_value_exists(match, value):
    if isinstance(value, bool):
        if bool(int(match)) is not value:
            msg = f'Expected {match} exists and is not {value}'
            raise WrongValue(msg)
