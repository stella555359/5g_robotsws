"""
:copyright: Nokia Networks
:author: Damian Piasecki, Anna Bien
:maintainer: Anna Bien
:contact: anna.bien@nokia.com
"""

from ta5g_pm_counters import ta5g_pm_counters
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import logger_console_info, logger_info


class ValueOutOfRange(Exception):
    pass


class PmCounterNotFound(Exception):
    pass


def get_latest_pm_file(log_dir=None, wait_for_pm_interval_end=True):
    """
    Copy latest PM File to VM

    :param log_dir: (str) Path to directory where PM counters file will be copied
    :param wait_for_pm_interval_end: (bool)
    :return: (str) Path to the latest pm file. E.g.: '/home/ute/results/PM.BTS-1.20231010.085500.ANY.xml'
    """

    pm_counters_instance = ta5g_pm_counters()
    if wait_for_pm_interval_end:
        pm_counters_instance.wait_for_next_full_pm_interval()
    pm_file_path = pm_counters_instance.get_latest_unpacked_full_pm_counters_file(log_dir)
    logger_info(f'PM Counters file saved at: {pm_file_path}')
    return pm_file_path


def get_sum_of_counter_list(first_counter, last_counter, counters_path, counter_file_path):
    """
    The function for acquiring the sum of PM Counters list values

    :param first_counter: (str) The ID of the first counter from checking range
    :param last_counter: (str) The ID of the last counter from checking range
    :param counters_path: (str) Path to counter in PM counters file
    :param counter_file_path: (str) Path to PM counters file
    """

    counters_group_name = first_counter[:-2]
    counters_list = ['{}{:02d}'.format(counters_group_name, suffix) for suffix in
                     range(int(first_counter[-2:]), int(last_counter[-2:]) + 1)]
    sum_of_counters = 0
    for counter in counters_list:
        counter_value = get_latest_pm_counter_value(
            counter_id=counter, counter_path=counters_path, filepath=counter_file_path
        )
        sum_of_counters += counter_value
    logger_info(f'Sum of counters {first_counter}-{last_counter}: {sum_of_counters}')
    return sum_of_counters


def get_latest_pm_counter_value(counter_id, counter_path, filepath):
    """
    The function for getting latest PM counter value.

    :param counter_id: (str) PM counter ID
    :param counter_path: (str) Path to counter in PM counters file
    :param filepath: (str) Path to PM counters file; Can be collected with use of get_latest_pm_file()
    :return: (int)
    """

    pm_counters_instance = ta5g_pm_counters()
    pm_counter_value = pm_counters_instance.get_pm_counter_value(
        counter=counter_id, localmoid=counter_path, filepath=filepath
    )
    try:
        return pm_counter_value[0]
    except IndexError:
        raise PmCounterNotFound(f'{counter_path}/{counter_id} not found in {filepath}')


def verify_counter_value_is_in_range(counter_name, obtained_value, min_value, max_value):
    """
    The function for verifying if obtained counter value is in specified range

    :param counter_name: (str) PM counter name
    :param obtained_value: (float) Obtained PM counter value
    :param min_value: (int) Minimum value within the range
    :param max_value: (int) Maximum value within the range
    """

    try:
        assert float(min_value) <= obtained_value <= float(max_value)
        logger_console_info(f'{counter_name} value ({round(obtained_value, 2)}) is in range '
                            f'from {float(min_value)} to {float(max_value)}')
    except AssertionError:
        raise ValueOutOfRange(f'{counter_name} value ({round(obtained_value, 2)}) is out of range '
                              f'from {min_value} to {max_value}')
