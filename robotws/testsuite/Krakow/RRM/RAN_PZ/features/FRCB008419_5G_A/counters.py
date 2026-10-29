from moler.util.moler_test import MolerTest
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
import time
from taf.sbts.oam.coam.admin import admin

admin_connection = admin()
tl = BuiltIn().get_variable_value('${tl}')
lmp_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr


def wait_for_counter_change(interval=15):
    """
    Wait for counter change.

    :param interval: measurement interval
    :return: None
    """
    current_minutes = datetime.now().minute
    sleep_time = (interval + 1 - (current_minutes % interval)) * 60
    time.sleep(sleep_time)
    return sleep_time


def get_pm_counters(counter_dict):
    """
    Get values of pm counters.

    :param counter_dict: counters dict, e.g. {"NCELA": ['M55308C26001'], "NMSDU": ['M55309C12001']}
    :return: dict, values of counters
    """
    admin_connection.connect_to(bts_host=lmp_address)
    counter_values = dict()
    for nrcell_object in counter_dict:
        counter_str = ','.join(counter_dict[nrcell_object])
        counters = admin_connection.get_pm_counters(counter_str, timeout=300)
        for counter in counter_dict[nrcell_object]:
            key = sorted(list(counters['BTS']['CELLS']['NRCELL-1'][nrcell_object][counter].keys()))[-1]
            counter_values[counter] = counters['BTS']['CELLS']['NRCELL-1'][nrcell_object][counter][key]
    admin_connection.teardown()
    return counter_values


@MolerTest.raise_background_exceptions()
def verify_counters_are_higher(current_counters_dict, previous_counters_dict, zero_counters=None):
    """
    Verify counters are higher than in previous period.

    :param current_counters_dict: dict with current values
    :param previous_counters_dict: dict with values from previous period
    :param zero_counters: list, counters with value of zero
    :return: None
    """
    zero_counters_list = [] if zero_counters is None else zero_counters
    error_list = list()
    for counter in current_counters_dict:
        if counter in zero_counters_list and current_counters_dict[counter] != previous_counters_dict[counter]:
            error_list.append("Counter {} has unexpected value {}, expected {}"
                              .format(counter, current_counters_dict[counter], previous_counters_dict[counter]))
        elif counter not in zero_counters_list and current_counters_dict[counter] <= previous_counters_dict[counter]:
            error_list.append("Counter {} has unexpected value {}, expected > {}"
                              .format(counter, current_counters_dict[counter], previous_counters_dict[counter]))
    if error_list:
        MolerTest.error("Unexpected counter values", dump=error_list)


@MolerTest.raise_background_exceptions()
def get_counter_timestamps(counter_dict):
    """
    Get Counter Timestamps.

    :param counter_dict: counters dict, e.g. {"NCELA": ['M55308C26001'], "NMSDU": ['M55309C12001']}
    :return: dict, timestamps
    """
    admin_connection.connect_to(bts_host=lmp_address)
    timestamps = dict()
    for nrcell_object in counter_dict:
        counter_str = ','.join(counter_dict[nrcell_object])
        counters = admin_connection.get_pm_counters(counter_str, timeout=300)
        for counter in counter_dict[nrcell_object]:
            timestamps[counter] = sorted(list(counters['BTS']['CELLS']['NRCELL-1'][nrcell_object][counter]
                                              .keys()))[-1]
    admin_connection.teardown()
    return timestamps


@MolerTest.raise_background_exceptions()
def compare_counter_timestamps(counter_dict, timestamps):
    """
    Compare Counter Timestamps.

    :param counter_dict: counters dict, e.g. {"NCELA": ['M55308C26001'], "NMSDU": ['M55309C12001']}
    :param timestamps: timestamps dict
    :return: None
    """
    current_timestamps = get_counter_timestamps(counter_dict)
    error_list = list()
    for counter in timestamps:
        if timestamps[counter] != current_timestamps[counter]:
            error_list.append(counter)
    if error_list:
        MolerTest.error("MAC Throughput Counters listed below are not halted", dump=error_list)
