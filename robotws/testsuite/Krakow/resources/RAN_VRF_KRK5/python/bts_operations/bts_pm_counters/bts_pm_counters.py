import time
from datetime import datetime
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_operations import adjust_dist_name

'''
    Example how counters should be defined so functions `get_counters` and 'verify_counters' works properly
    counters = {
        'M55117C01010_min': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRDU-1']['NF1CD']['M55117C01010']",
            "value": 50,
            "condition": ">="
        },
        'M55117C01010_max': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRDU-1']['NF1CD']['M55117C01010']",
            "value": 100,
            "condition": "<="
        },
        'M55143C00001': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NXNCC']['M55143C00001']",
            "value": 1,
            "condition": ">="
        },
    }
'''


def extract_counter_ids(counters):
    counter_ids = set()
    for key in counters.keys():
        formula = counters[key]['formula']
        formula = formula.replace("response", "").replace("]", "").replace("'", "").replace('"', '')
        counter_id = formula.split('[')[-1]
        counter_ids.add(counter_id)
    return counter_ids


def get_counters(counters, bts_id=0):
    mrbts = adjust_dist_name(dist_name='MRBTS-{}', bts_id=bts_id)
    gnb_pm = GnbPmCounter()
    counter_ids = extract_counter_ids(counters)
    counter_ids = ",".join(map(str, counter_ids))
    response = gnb_pm.get_counter(counter_ids=counter_ids, bts_id=bts_id)
    counters_values = {}
    for counter_key in counters.keys():
        counter_values_for_pm = eval(counters[counter_key]['formula'])
        last_timestamp = sorted(counter_values_for_pm.keys())[-1]
        last_counter_value = counter_values_for_pm[last_timestamp]
        last_timestamp = str(datetime.fromtimestamp(int(last_timestamp)))
        if last_timestamp not in counters_values.keys():
            counters_values[last_timestamp] = {}
        counters_values[last_timestamp][counter_key] = last_counter_value
    log_info_to_console('Counters for {} collected in PM period:\t{}'.format(mrbts, counters_values), log_hierarchy=3)
    return counters_values


def verify_counters(counters, bts_id=0):
    gnb_counters = get_counters(counters=counters, bts_id=bts_id)
    counters_passed = []
    counters_failed = []
    for timestamp in gnb_counters.keys():
        for counter in counters.keys():
            condition = '{} {} {}'.format(gnb_counters[timestamp][counter], counters[counter]['condition'],
                                          counters[counter]['value'])
            if eval(condition):
                counters_passed.append('Counter {} is ok, `{}`'.format(counter, condition))
            else:
                counters_failed.append('Counter {} is NOT ok, `{}`'.format(counter, condition))
    if counters_passed:
        for counter_passed in counters_passed:
            log_info_to_console(counter_passed)
    if counters_failed:
        raise Exception('\n'.join(counters_failed))
    return gnb_counters


def check_time_to_next_pm_period(time_buffer=300, interval=15):
    timestamp_now = int(time.time())
    time_to_pm = int(interval) * 60 - (timestamp_now % (int(interval) * 60))
    if time_to_pm < int(time_buffer):
        log_info_to_console('It\'s only {}s to next PM period, so waiting for next one'.format(time_to_pm),
                            log_hierarchy=2)
        time.sleep(time_to_pm)
    else:
        log_info_to_console('It\'s {}s to next PM period, so more than needed buffer {}s, no waiting is needed'.
                            format(time_to_pm, time_buffer), log_hierarchy=2)
