"""
:copyright: Nokia Networks
:author: Damian Zak
:contact: damian.zak@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""
from taf.gnb.oam.coam.admin import admin
from robot.api import logger
from robot.errors import ExecutionFailed
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import handle_admin
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import (
    logger_console_info, logger_info
)


class ValidationFailed(Exception):
    def __init__(self, *args, **kwargs):
        pass


def note_active_alarms():
    """
    Author: Damian Zak
    Contact: damian.zak@nokia.com
    Creation Date: 01.04.2021
    Modified Date: -

    Function used to get the number of active alarms

    Returns:
        alarms_number(int): Number of active alarms
    """
    api = admin()
    connection = api.connect_to()
    alarms_number = connection.get_active_alarms_number()
    connection.teardown_admin()
    return alarms_number


def check_number_of_active_alarms(noted_active_alarms):
    """
    Author: Damian Zak
    Contact: damian.zak@nokia.com
    Creation Date: 01.04.2021
    Modified Date: -

    Function used to check if the number of current active alarms differ form noted active alarms

    Args:
        noted_active_alarms(int): Noted active alarms to compare with current active alarms

    Raises:
        ExecutionFailed: New alarms appeared

    Returns:
        None
    """
    api = admin()
    connection = api.connect_to()
    alarms_number = connection.get_active_alarms_number()
    if alarms_number > noted_active_alarms:
        raise ExecutionFailed(message="New alarms appeared")
    connection.teardown_admin()


@handle_admin
def get_critical_or_major_alarms_details(*args, **kwargs):
    """
    Get info pertaining critical or major bts alarms. Alarm with whole information will be returned

    :return: (list) python list with the observed alarms
    """

    alarms = kwargs["connection"].get_active_alarms()
    alarms_list = list()
    for alarm in alarms:
        if alarm["severity"] == "Critical" or alarm["severity"] == "Major":
            logger_info(alarm)
            alarms_list.append(alarm)
    return alarms_list


@handle_admin
def get_warnings_details(*args, **kwargs):
    """
    Get info pertaining warnings from BTS. Warning with whole information will be returned

    :return: (list) python list with the observed warnings
    """

    warnings = kwargs["connection"].get_active_alarms()
    warnings_list = list()
    for warning in warnings:
        if warning["severity"] == "Warning":
            logger_info(warning)
            warnings_list.append(warning)
    return warnings_list


def get_warnings(*args, **kwargs):
    """
    Get info pertaining warnings from BTS. Only 'faultID' of the warning will be returned

    :return: Tuple(num_of_warnings, python set with the observed warnings)
    """

    warnings_list = get_warnings_details(*args, **kwargs)
    num_of_warnings = len(warnings_list)
    warnings_set = set([warning['faultId'] for warning in warnings_list])
    return num_of_warnings, warnings_set


def get_critical_or_major_alarms(*args, **kwargs):
    """
    Get info pertaining critical or major bts alarms. Only 'faultID' of the alarm will be returned

    :return: Tuple(num_of_critical_or_major_alarms, python set with the observed alarms)
    """

    alarms_list = get_critical_or_major_alarms_details(*args, **kwargs)
    num_of_critical_or_major_alarms = len(alarms_list)
    alarms_set = set([alarm['faultId'] for alarm in alarms_list])
    return num_of_critical_or_major_alarms, alarms_set


def assert_no_new_major_or_critical_alarms_appeared(previous_num_of_alarms=0, previous_alarms_set=None,
                                                    ignored_alarms=None):
    """
    Author: Mateusz Plinta
    Contact: mateusz.plinta@nokia.com
    Creation Date: 19.01.2022
    Modified Date:

    Check if no new major or critical alarms appeared. Works with get_critical_or_major_alarms method.

    :param previous_num_of_alarms: number of alarms to compare against
    :param previous_alarms_set: set of alarms to compare against
    :param ignored_alarms: (list) set of alarms that might be ignored
    """
    if ignored_alarms:
        ignored_alarms = [int(alarm) for alarm in ignored_alarms]
        ignored_alarms = set(ignored_alarms)
    else:
        ignored_alarms = set()
    current_num, current_alarms_set = get_critical_or_major_alarms()
    new_alarms = current_alarms_set.difference(previous_alarms_set) - ignored_alarms
    if new_alarms:
        for fault_id in new_alarms:
            for alarm in current_alarms_set:
                if int(alarm) == int(fault_id):
                    logger.info("New alarm failing execution: {}".format(alarm), also_console=True)
        raise Exception("New alarm(s) occurred: {}".format(new_alarms))


def check_presence_of_redundant_alarms(current_alarms=None, expected_alarms=None, ignored_alarms=None):
    """
    Validate if redundant, unnecessary alarms have appeared on WebEM.

    :param current_alarms: (list) Output of get_critical_or_major_alarms_details()
    :param expected_alarms: (list) Alarms that should appear with specified details (without whitespaces)
                            e.g: [{'faultId': 6354, 'impactedcells': 'nr:faulty:nrcell-1'},
                                  {'faultId': 6354}]
    :param ignored_alarms: (list) Fault ID of alarms that would be ignored in validation
    """

    if not current_alarms:
        current_alarms = get_critical_or_major_alarms_details()
    if not expected_alarms:
        expected_alarms = []
    if not ignored_alarms:
        ignored_alarms = []
    expected_alarms_fault_ids = [item['faultId'] for item in expected_alarms]
    current_alarms_fauld_ids = [item['faultId'] for item in current_alarms]
    for expected_alarm in expected_alarms_fault_ids:
        try:
            current_alarms_fauld_ids.remove(expected_alarm)
        except ValueError:
            continue
    for ignored_alarm in ignored_alarms:
        try:
            current_alarms_fauld_ids.remove(ignored_alarm)
        except ValueError:
            continue
    try:
        assert len(current_alarms_fauld_ids) == 0, f'Not expected alarms found in WebEM: {current_alarms_fauld_ids}'
    except AssertionError as not_expected_alarms:
        raise ValidationFailed(not_expected_alarms)
