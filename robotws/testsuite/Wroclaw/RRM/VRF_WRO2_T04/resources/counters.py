from datetime import datetime
from time import sleep
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession

LOCALHOST = '127.0.0.1'


def sync_to_next_reporting_interval(offset=40, pm_interval=300, show_countdown=False):
    """sleep time in seconds to next pm interval
    possible to show countdown on the console
    ALL arguments in seconds"""
    now = datetime.now()
    time_to_sleep = (
        pm_interval + int(offset) - now.minute * 60 - now.second
    ) % pm_interval
    logger.info(
        "\n [Syncing to next PM Interval in progress... - wait {} seconds]".format(
            time_to_sleep
        ),
        also_console=True,
    )
    for i in range(time_to_sleep):
        counter = time_to_sleep - i
        logger.info("{}".format(counter), also_console=show_countdown)
        sleep(1)


def calculate_pm_intervals_number(start_time, stop_time):
    pm_inervals_number = int((stop_time - start_time) // 300)
    return pm_inervals_number


def collect_pm_counters_data(counter_list, remote_host):
    with AdminSession(remote_host) as admin:
        pm_counters_data = admin.get_pm_counters(','.join(counter_list), timeout=120)
    return pm_counters_data


def find_values_with_keys(data, target_key, search_keys, n):
    result = {}
    direct_sum = 0

    def recurse(subdict, parent_key=''):
        nonlocal direct_sum
        if isinstance(subdict, dict):
            for key, value in subdict.items():
                if key == target_key:
                    if any(k in parent_key for k in search_keys):
                        result[parent_key] = value
                    else:
                        direct_sum = sum_last_n_values(value, n)
                else:
                    recurse(value, key if any(k in key for k in search_keys) else parent_key)

    recurse(data)
    return result, direct_sum


def sum_last_n_values(values_dict, n):
    sorted_values = [value for key, value in sorted(values_dict.items())]
    last_n_values = sorted_values[-n:]
    return sum(last_n_values)


def get_sum_of_n_last_pm_counters_values(counters, n=1, additional_dict_keys=None, remote_host=LOCALHOST):
    """ Function return dictionary of sum of 'n' last values for 'counters' list in format as below:
        {<PID>: <value>, <PID>: {NRCELL-(ID): <value>, ...}}
        If counter could have more than one value like for NRCELL, use 'additional_dict_keys'.
        Keys 'NRCELL' and 'LNCEL' are set as default, for other look sample as below:
        PID: M55197C00001, NE_ABBR: 'RAN_PAG_SENT_FIRST_PAGSTRA'
        path: MRBTS-<id>/NRBTS-<id>/NRPAGING_STRAT_RRCINACT-1/NMPS/RAN_PAG_SENT_FIRST_PAGSTRA
        set 'additional_dict_keys' = ['RRCINACT'] as best macth to master key 'NRPAGING_STRAT_RRCINACT'
        and counter will be written as:
        'M55197C00001': {'NRPAGING_STRAT_RRCINACT-1': <value>, 'NRPAGING_STRAT_RRCINACT-2': <value>, ...}
    """
    data = collect_pm_counters_data(counters, remote_host)

    default_keys = ['NRCELL', 'LNCEL']
    if additional_dict_keys:
        search_keys = default_keys + additional_dict_keys
    else:
        search_keys = default_keys

    counters_values = {}
    for counter in counters:
        result, direct_sum = find_values_with_keys(data, counter, search_keys, n)
        if result:
            counters_values[counter] = {k: sum_last_n_values(v, n) for k, v in result.items()}
        else:
            counters_values[counter] = direct_sum
    return counters_values
