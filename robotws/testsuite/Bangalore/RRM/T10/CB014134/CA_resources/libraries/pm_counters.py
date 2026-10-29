# -*- coding: utf-8 -*-
"""
:author: Sebastian Dziewiecki
:contact: sebastian.dziewiecki@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
from collections import namedtuple
from functools import reduce


calculated_pmc_stats = namedtuple('calculated_pmc_stats', 'min max sum avg')


def get_avg_pm_counter_value(data, dist_name, n):
    """Returns mean value of dist_name PM counter from its last n measurements

    data has to be result of ute_admin.get_counters_info(dist_name)

    :param data: output of ute_admin.get_counters_info
    :type data: dict
    :param dist_name: dist name of pm counter to get from data
    :type dist_name: str
    :param n: number of measurements to use when calculating mean value
    :type n: int
    :rtype: float
    """
    pm_counters = reduce(
        lambda d, key: d.get(key) if d else None,
        dist_name.split("/"),
        data,
    )
    pm_values = list(pm_counters.values())[::-1][:n]
    return sum(pm_values) / n


def get_pm_counter_value_by_timestamp(data, dist_name, timestamp):
    """ Returns PM counter value from specific timestamp.

    :param data: PM counter (Performance Measurement) values. Output from get_counters_info
                 keyword (ute_admin).
    :type data: ''dict''
    :param dist_name: Path to PM counter e.g.: BTS/BTS/LNBTS-1/LTE_GNSS/M8039C2
    :type dist_name: ''str''
    :param timestamp: Timestamp for PM counter in Epoch format e.g.: 1604614260
    :type timestamp: ''str''
    :return: PM counter value
    :rtype ''int''
    """
    dictionary_keys = dist_name.split('/')
    for key in dictionary_keys:
        data = data.get(key)
    return data[timestamp]


def get_pm_counter_timestamp_by_value(data, dist_name, searched_pm_counter_value):
    """ Returns timestamp/s for PM counter values satisfying condition.

    :param data: PM counter (Performance Measurement) values. Output from get_counters_info
                 keyword (ute_admin).
    :type data: ''dict''
    :param dist_name: Path to PM counter e.g.: BTS/BTS/LNBTS-1/LTE_GNSS/M8039C2
    :type dist_name: ''str''
    :param searched_pm_counter_value: Condition describing searched PM counter value. Python condition formatting is
    supported e.g.:
    pass 'value == 1` to search all PM counters which value is 1,
    pass `value > 100` to search all PM counters which value is greater than 100,
    pass `100 <= value < 1000` to search all PM counters which is greater or equal 100 and less than 1000.
    :type searched_pm_counter_value: ``str``
    :return: PM counter value/s
    :rtype ''list''
    """
    dictionary_keys = dist_name.split('/')
    for key in dictionary_keys:
        data = data.get(key)
    return [timestamp for timestamp, value in data.items() if eval(searched_pm_counter_value)]


def get_pmc_statistics(data, dist_name):
    """Returns min, max, sum and avg value for PM counter with ``dist_name``
    Values are calculated for all PM counter measurements in ``data``.

    ``data`` is an output from taf.admin PM counter keyword.
    Statistics are returned in a form of namedtuple.

    Usage:
    .. sourcecode:: robotframework
        ${output}=    get_pmc_statistics    data    dist_name
        Log    ${output.min}    ${output.avg}
    """
    pmc_dict = _flatten_dictionary(data, dist_name)
    return _calculate_pmc_stats(pmc_dict.values())


def get_pmc_statistics_from_last_n_elements(data, dist_name, n):
    """Returns min, max, sum and avg value for PM counter with ``dist_name``
    Values are calculated for ``n`` last PM counter measurements in ``data``.
    In case ``n`` is out of range or 0 values will be calculated for all exising measurements.

    ``data`` is an output from taf.admin PM counter keyword.
    Statistics are returned in a form of namedtuple.

    Usage:
    .. sourcecode:: robotframework
        ${output}=    get_pmc_statistics_from_last_n_elements    data    dist_name    n
        Log    ${output.min}    ${output.avg}
    """
    pmc_dict = _flatten_dictionary(data, dist_name)
    return _calculate_pmc_stats(list(pmc_dict.values())[-n:])


def get_pmc_statistics_from_time_range(data, dist_name, start, stop, pmc_increment_interval):
    """Returns min, max, sum and avg value for PM counter with ``dist_name``
    Values are calculated for PM counter measurements from time range in ``data``.
    ``pmc_increment_interval`` defines how frequent PM counter is incremented (value in seconds).

    PM counter measurement from time x is saved under timestamp x minus PM counter increment interval e.g:
        measurement from 305 with 100 PM counter increment will be stored under timestamp 300.

    ``data`` is an output from taf.admin PM counter keyword.
    Statistics are returned in a form of namedtuple.

    Usage:
    .. sourcecode:: robotframework
        ${output}=    get_pmc_statistics_from_time_range    data    dist_name    start    stop    pmc_increment_interval
        Log    ${output.min}    ${output.avg}
    """
    pmc_dict = _flatten_dictionary(data, dist_name)
    return _calculate_pmc_stats(_get_from_time_range(pmc_dict, start, stop, pmc_increment_interval))


def _calculate_pmc_stats(data):
    return calculated_pmc_stats(
        min(data),
        max(data),
        sum(data),
        round(sum(data) / len(data), 2))


def _get_from_time_range(data, start, stop, pmc_increment_interval):
    data_filtered = {k: v for k, v in data.items() if (int(k) > start - pmc_increment_interval) and int(k) <= stop}
    return data_filtered.values()


def _flatten_dictionary(data, dist_name):
    return reduce(
        lambda d, key: d.get(key) if d else None,
        dist_name.split("/"),
        data)
