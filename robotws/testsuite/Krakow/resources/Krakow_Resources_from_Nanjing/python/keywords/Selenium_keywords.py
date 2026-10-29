__author__ = 'Szymon Czaplak'
__copyright__ = 'Copyright (C) 2019, Nokia'
__email__ = 'szymon.czaplak@nokia.com'

from taf.ul.sc.gnb.oam.selenium import Selenium
from taf.ul.sc.asimgr import AsiMgr
from taf.ul.sc.tl_config import tl
from moler.util.moler_test import MolerTest
from datetime import datetime, timedelta
from taf.ul.sc.gnb.oam.rest import Rest
from taf.ul.oam.selenium_coam import selenium_coam

import time


def reset_all_hubs():
    """
    Reset all available hubs
    :return:
    """
    s = Selenium()
    num_of_hubs = len(tl.gnbs[0].dus[0].rus)
    for i in range(1, num_of_hubs + 1):
        s.reset_hub_via_selenium(ru_index=i)


def get_all_hubs_info():
    """
    Return info (name,SN,ant count etc.) of available hubs
    :return: dict with hub info
    """
    s = Selenium()
    num_of_hubs = len(tl.gnbs[0].dus[0].rus)
    out = dict()
    for i in range(1, num_of_hubs + 1):
        out['HUB{}'.format(i)] = s.get_hub_info_via_selenium(ru_index=i)
    return out


def check_number_of_configured_ants():
    """
    Check if ants count equal to function:get_antennas_number
    :return: boolean or int with number of configured ants
    """
    info = get_all_hubs_info()
    ants = 0
    for hub_index in info:
        ants += int(info[hub_index]['Configured ant count'])
        num_of_hubs = len(tl.gnbs[0].dus[0].rus)
    if ants != AsiMgr(autoconnect=True).get_antennas_number(num_of_hubs):
        return None
    return ants


def get_number_of_cells(timeout=60):
    """
    Get number of cells
    :param timeout: int
    :return: int with number of cells
    """

    return Selenium().get_number_of_cells(timeout)


def get_led_status_changes_of_an_unit(unit, interval=5, timeout=300):
    """
    Get led status of defined unit till on air
    :param unit: string with name of an unit
    :param interval: int
    :param timeout: int
    :return:string with led status of an unit
    """
    time_start = time.time()
    led_status = ['States:']
    s = Selenium()
    while (time.time() - time_start) < timeout:
        state = s.get_led_status_of_an_unit_via_selenium(unit, timeout=timeout)
        if led_status[-1] == state:
            continue
        led_status.append(state)
        time.sleep(interval)
    return led_status


def get_hub_administrative_state():
    """
    Get administrative  state of hub
    :return: string with administrative status of hub
    """
    s = Selenium()
    return s.get_ru_info_via_selenium()['Status']['Administrative state']


def collect_pms_info_time(counter_id):
    """
    Collect time info of PM counter
    :param counter_id: string
    :return: datetime object containing time info of PM counter
    """

    s = Selenium()
    return datetime.strptime(str(sorted(s.get_bts_counters_info(counter_id))[::-1][0][11:]), '%H:%M:%S')


def add_specific_amount_of_minutes_to_given_time(time_now, minute):
    """
    Add specifing amount of minutes to type time.
    :param time_now: datetime
    :param minute: int
    :return: datetime with started datetime added by minute value
    """

    return time_now + timedelta(minutes=int(minute))


def get_parameter_value_via_selenium_with_id(id_string, parameter_value):
    """
    Get parameter value with proper MRBTS or NRBTS id
    :param id_string: string, MRBTS or NRBTS
    :param parameter_value: string, parameter to be checked
    :return: string, value of parameter
    """
    if id_string == "NRBTS":
        full_id = Rest().nrbts_id
    else:
        full_id = Rest().mrbts_id

    full_id = "{}-{}".format(id_string, full_id)

    return Selenium().get_parameter_value_via_selenium(full_id, parameter_value)


def set_parameter_value_via_selenium_with_id(id_string, parameter_to_change, new_value):
    """
    Set parameter value with proper MRBTS or NRBTS id
    :param id_string: string, MRBTS or NRBTS
    :param parameter_to_change: string, value of parameter to be changed
    :param new_value: string, new parameter value
    :return: None
    """
    if id_string == "NRBTS":
        full_id = Rest().nrbts_id
    else:
        full_id = Rest().mrbts_id

    full_id = "{}-{}".format(id_string, full_id)

    Selenium().set_parameter_value_via_selenium(full_id, parameter_to_change, new_value)
