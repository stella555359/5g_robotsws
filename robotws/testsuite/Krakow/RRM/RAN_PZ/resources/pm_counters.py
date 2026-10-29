import datetime
import re
import time
import pytz
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.RRM.RAN_PZ.resources.pcap_verification.cap_pyshark import (
    get_log_count_of_given_message_type, Filters)
from testsuite.Krakow.RRM.RAN_PZ.resources.pcap_verification.param_tree_helper import TreeWalker
from testsuite.Krakow.RRM.RAN_PZ.resources.webui.interface import WebuiInterface
from testsuite.Krakow.RRM.RAN_PZ.resources.rrm_fixture import get_robot_variable


def get_library_instance(library):
    instance = BuiltIn().get_library_instance(library)
    if not instance:
        raise ImportError("Unable to access %s instance, check if library is imported" % instance)
    return instance


def verify_if_counter_is_incremented_correctly(counter_id, nr_cell_id=None, expected_value=1):
    period, counter_value = get_latest_counter_value(counter_id, nr_cell_id)
    print("Counter value: {} Counter period: {}".format(counter_value, period))
    assert counter_value == expected_value, "Value for period {} is {} but expected is {}". \
        format(period, counter_value, expected_value)


def verify_if_counters_value_is_incremented(prev_counters, current_counters):
    """
    Author: Mateusz Pajor
    Contact: mateusz.pajor@nokia.com
    Creation Date: 29.04.2021
    Modified Date: -

    Function used to verify if sum of counters has increased

    Args:
        prev_counters(dict): Dictionary of previous counters
        current_counters(dict): Dictionary of current counters

    Raises:
        KeyError: Counter keys do not match!

    Returns:
        None
    """

    try:
        assert prev_counters.keys() == current_counters.keys()
    except AssertionError as err:
        print(err)
        raise KeyError("Counter keys do not match! {}\n{}".format(prev_counters.keys(), current_counters.keys()))
    sum_values = sum(current_counters.values())
    sum_values_prev = sum(prev_counters.values())
    assert sum_values > sum_values_prev, \
        "Sum of values: {} from current pm counters is not bigger than previous values {}".format(sum_values,
                                                                                                  sum_values_prev)


def wait_for_next_pm_period(interval=15):
    """Sleeps until interval starts. Unit is minutes, default value 15min"""
    next_pm_period = int(interval) * 60 - time.time() % (int(interval) * 60)
    delay = 30
    time.sleep(next_pm_period + delay)


def compare_counters(prev_counters, counters):
    """
    Calculates difference between 2 sets of counters (counters - prev_counters)

    :param prev_counters: dict of counter IDs and values at the beginning of the test
    :param counters:      dict of counter IDs and values at the end of the test
    :return:              dict of counter IDs and result of substraction
    """
    results = {}
    try:
        assert prev_counters.keys() == counters.keys()
    except AssertionError as err:
        print(err)
        raise KeyError("Counter sets do not match! {}\n{}".format(prev_counters.keys(), counters.keys()))

    for counter in counters:
        results[counter] = counters[counter] - prev_counters[counter]
    return results


def compare_counters_for_cells(prev_counters_packed, counters_packed):
    """
    Calculates difference between 2 dicts of counters (counters_packed - prev_counters_packed)

    :param prev_counters_packed:
    :param counters_packed:
    :return:
    """
    try:
        assert all(x in prev_counters_packed.keys() for x in counters_packed.keys())
        assert all(x in counters_packed.keys() for x in prev_counters_packed.keys())
    except AssertionError as err:
        print(err)
        raise KeyError("Counter sets do not match! {}\n{}".format(prev_counters_packed.keys(), counters_packed.keys()))
    results = {}
    for cell_id in prev_counters_packed.keys():
        results[cell_id] = compare_counters(prev_counters_packed[cell_id], counters_packed[cell_id])
    return results


def get_latest_counter_value(counter_id, nr_cell_id=None, dist_name=''):
    """

    :param counter_id: counter id eg: M55117C02003
    :param dist_name: eg: BTS/BTS/NRBTS-1/NRDU-1/NF1CD . It's optional parameter.
                      If not defined, it's get automatically.
    :param nr_cell_id: If you would like get counter for particular nrcell.
    :return:
    """
    coam = get_library_instance("coam")
    counters = coam.get_pm_counters(couter_ids=counter_id)
    return _get_latest_counter_value(counters, counter_id, nr_cell_id, dist_name)


def get_latest_counter_value_for_all_cells(counter_id):
    values = {}
    coam = get_library_instance("coam")
    counters = coam.get_pm_counters(couter_ids=counter_id)
    nr_cell_ids = get_all_nrcell_ids()
    for nr_cell_id in nr_cell_ids:
        values[nr_cell_id] = _get_latest_counter_value(counters, counter_id, nr_cell_id)

    return values


def get_counters_from_list(counter_list, cell_id=1):
    """

    :param counter_list: list of counter IDs
    :param cell_id:      cell ID
    :return:             dict of counter IDs and latest values
    """
    counter_dict = {}
    for counter in counter_list:
        counter_dict[counter] = get_latest_counter_value(counter_id=counter, nr_cell_id=cell_id)[1]
    return counter_dict


def get_counters_from_list_for_cells(counter_list, cell_id_list):
    """
    :param counter_list:
    :param cell_id_list:
    :return: results - list of counters
    """
    results = {}
    for cell_id in cell_id_list:
        results[cell_id] = get_counters_from_list(counter_list, cell_id)
    return results


def get_all_nrcell_ids():
    nr_cells = set()
    coam = get_library_instance("coam")
    subcell_info = coam.get_subcells_info()
    for cell_group in subcell_info:
        for cell in subcell_info[cell_group]:
            for subcell in subcell_info[cell_group][cell]:
                nr_cell_id = subcell_info[cell_group][cell][subcell]['parameters']['nrCellIdentity']
                if nr_cell_id:
                    nr_cells.add(nr_cell_id)

    return nr_cells


def validate_counters(expected_results, actual_results):
    """
    Validates given results of substracting conuter values against a mask (expected_results)

    :param expected_results: dict of counter IDs and values -1/0/1 meaning that counter is expected to
                             decrease/stay at 0/increase, eg:
                             expected_results = {
                                 'M55308C10002': 1,
                                 'M55308C10004': -1
                             }
    :param actual_results: result of substracting counter values at the beginning from values at the end of
                           the test - see compare_counters
    """
    try:
        assert all(x in expected_results.keys() for x in actual_results.keys())
        assert all(x in actual_results.keys() for x in expected_results.keys())
    except AssertionError as err:
        logger.info("expected_results type:{}".format(type(expected_results)))
        logger.info("actual_results type:{}".format(type(actual_results)))
        logger.error(err)
        logger.error("Counter sets do not match!\n{}\n{}".format(expected_results.keys(), actual_results.keys()))
        raise KeyError()

    passed = True
    for result in expected_results:
        if expected_results[result] == 0 and not (0 <= actual_results[result] <= 10):
            passed = False
            logger.warn("PM Counter: {} is not supposed to change value and it did!".format(result))
            continue
        if expected_results[result] != 0 and actual_results[result] * expected_results[result] < 10:
            passed = False
            logger.warn("PM Counter: {} did not change value as expected!".format(result))

    return passed


def validate_counters_for_cells(expected_results, actual_results_packed):
    """
    Verify if dict of counters have expected values for each cell
    :param expected_results:
    :param actual_results_packed:
    :return: True or False
    """
    results = {}
    for cell_id in actual_results_packed.keys():
        results[cell_id] = validate_counters(expected_results, actual_results_packed[cell_id])
    if any(x is False for x in results.values()):
        return False
    return True


def _get_latest_counter_value(counters, counter_id, nr_cell_id=None, dist_name=''):
    if not dist_name:
        dist_name = _find_dist_name(counters, nr_cell_id)

    counter_values = _get_counter_values(counters, dist_name)

    sorted_timestamps = sorted(counter_values[counter_id].keys(), reverse=True)
    latest_timestamp = sorted_timestamps[0]
    latest_counter_value = counter_values[counter_id][latest_timestamp]

    return latest_timestamp, latest_counter_value


def _get_sum_of_counter_values_from_coam(counter_id):
    sum_val = []
    with WebuiInterface() as webUI:
        result = webUI.get_counters_info(dist_name="all")
        tw = TreeWalker(result)
        tw.find_all(counter_id)
        counters = tw.get_found_elements()
        assert bool(counters), counter_id + " not found"
        for counter in counters:
            sum_val.append(sum(counter.values()))
    if len(sum_val) == 1:
        return sum_val[0]
    else:
        return sum_val, tw.search_result


def _find_dist_name(counters, nr_cell_id=None):
    def build_dist_path(counters_dict, dist_path=''):
        for key in counters_dict:
            recursive_flag = False
            if len(counters_dict.keys()) == 1 and not re.search(r"^M.*\d+$", key):
                recursive_flag = True
            elif len(counters_dict.keys()) > 1 and re.search(r"^NRCELL-", key):
                key = "NRCELL-{}".format(nr_cell_id)
                recursive_flag = True

            if recursive_flag:
                new_dist_path = "{}/{}".format(dist_path, key)
                dist_path = build_dist_path(counters_dict[key], new_dist_path)
                break
        return dist_path

    dist_name = build_dist_path(counters)
    dist_name = dist_name.strip("/")
    return dist_name


def _get_counter_values(counters, dist_name):
    dist_name = dist_name.strip("/")
    dist_keys = dist_name.split('/')
    for key in dist_keys:
        counters = counters[key]

    return counters


def assert_pm_value_is_consistent_with_pcap(pcap_filepath, message_type, counter_name):
    count_from_pcap = get_log_count_of_given_message_type(pcap_filepath, message_type)
    counter_value = _get_sum_of_counter_values_from_coam(get_robot_variable(counter_name))

    assert count_from_pcap == counter_value


def check_f1_setup_succ_pm_counter(pcap_filepath):
    assert_pm_value_is_consistent_with_pcap(pcap_filepath, Filters.F1_SETUP_REQUEST, '${F1_SETUP_SUCC}')


def wait_for_next_pm_period_if_little_time_left(min_minutes_left=5, interval=15):
    """
    Sleeps until new interval starts if current interval ends in less than min_minutes_left.
    :param min_minutes_left:    int, Minimum number of minutes left in current interval
    :param interval:            int, PM Counters period in minutes
    """
    delay = 10
    seconds_left = int(interval) * 60 - time.time() % (int(interval) * 60)
    if seconds_left < min_minutes_left * 60:
        time.sleep(seconds_left + delay)


def get_last_quarter(timezone="UTC"):
    """
    :param timezone    string, When provided, the returned time region
    """
    now = pytz.timezone('UTC').localize(datetime.datetime.utcnow())
    tz = pytz.timezone(timezone)
    local_time = now.astimezone(tz)

    date = local_time.replace(minute=15 * (local_time.minute // 15))
    return date.strftime("%Y-%m-%d %H:%M:00")
