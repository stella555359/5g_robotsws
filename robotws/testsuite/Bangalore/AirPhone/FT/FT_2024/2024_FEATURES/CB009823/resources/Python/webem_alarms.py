"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""
from taf.gnb.oam.coam.admin import admin
from robot.api import logger
from robot.errors import ExecutionFailed
from testsuite.Wroclaw.RRM.L2PS_WRO.resources.Python.common_gnb import handle_admin


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
def get_critical_or_major_alarms(*args, **kwargs):
    """
    Author: Mateusz Plinta
    Contact: mateusz.plinta@nokia.com
    Creation Date: 19.01.2022
    Modified Date:

    Get info pertaining critical or major bts alarms.

    :return: Tuple(num_of_critical_or_major_alarms, python set with the observed alarms)
    """
    alarms = kwargs["connection"].get_active_alarms()
    num_of_critical_or_major_alarms = 0
    alarms_set = set()
    for alarm in alarms:
        if alarm["severity"] == "Critical" or alarm["severity"] == "Major":
            num_of_critical_or_major_alarms += 1
            logger.info(alarm)
            alarms_set.add(alarm['faultId'])
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
    ignored_alarms = set(ignored_alarms) if ignored_alarms else set()
    current_num, current_alarms_set = get_critical_or_major_alarms()
    new_alarms = current_alarms_set.difference(previous_alarms_set) - ignored_alarms
    if new_alarms:
        for fault_id in new_alarms:
            for alarm in current_alarms_set:
                if int(alarm) == int(fault_id):
                    logger.info("New alarm failing execution: {}".format(alarm), also_console=True)
        raise Exception("New alarm(s) occurred: {}".format(new_alarms))
    assert int(previous_num_of_alarms) >= current_num - len(ignored_alarms), \
        "New major or critical fault appeared! Check info logs."


@handle_admin
def print_active_alarms(*args, **kwargs):
    alarms = kwargs["connection"].get_active_alarms()
    logger.warn(msg="\n*** Current active faults on BTS: ***")
    alarm_list = ["{}: {} {}".format(alarm["severity"], alarm["alarmDetail"], alarm["faultId"])
                  for alarm in alarms]
    for alarm in alarm_list:
        logger.warn(msg=alarm)
