from taf.sbts.oam.coam.admin import admin
from datetime import datetime
from robot.api import logger
from collections import OrderedDict
from ute_common_admin.exception import AdminApiProcedureFailureException
from testsuite.Wroclaw.OAM.VRF_WRO3_T04.common_resources.generic.decorators import retry_if_fail
import os
import time


def check_if_set_interval_works(password, minutes, destination, counter):
    """
    checking if interval parameter is equal as 'minutes' parameter
    :param password:
    :param minutes: digital
    :param destination: destination path to counter
    :param counter: counter name
    :return: boolean value
    """
    interval_times = sorted([int(time) for time in get_counters(password, destination+counter).keys()])
    logger.console(datetime.utcfromtimestamp(int(interval_times[-1])).strftime('%Y-%m-%d %H:%M:%S'))
    logger.console(datetime.utcfromtimestamp(int(interval_times[-2])).strftime('%Y-%m-%d %H:%M:%S'))
    return int(interval_times[-1]) - int(interval_times[-2]) == int(minutes)*60


def get_counter_value_via_netact(counter_number, counter_path_number, path_to_file='PM_Report',
                                 measurementType="IP_filtering_FH_Stats"):
    counter1 = os.popen("cat {}".format(path_to_file)).read()
    if counter_number not in counter1:
        raise AssertionError("Counter {} is not visible by NetAct.".format(counter_number))
    counter2 = counter1.split('measurementType="{}'.format(measurementType))
    counter3 = counter2[int(counter_path_number)].split(counter_number)
    return counter3[1]


@retry_if_fail(exception=AdminApiProcedureFailureException, max_retries=15, interval_sec=60, part_of_msg="unreachable")
def get_counters(password, path):
    """
    getting counter values by admin
    :param password:
    :param path: destination_path + counter_name, for example: TRS/IPNO/IPNO-1/TCP_UDP_stats/M51325C0
    :return: dict with values, for example:
        counters_result = u'M51325C0':    { u'1566976080': 453,
                                            u'1566976500': 131187,
                                            u'1566977400': 372351  }
    """
    api = admin()
    connection = api.connect_to(bts_host="192.168.255.129", password=password)
    counters = api.get_counters_info(path, connection=connection)
    api.teardown(connection=connection)
    result = get_measurements(counters)
    return OrderedDict(sorted(result.items(), key=lambda t: int(t[0])))


def get_measurements(dictionary):
    if type(list(dictionary.values())[0]) is not dict:
        return dictionary
    return get_measurements(list(dictionary.values())[0])


def get_newest_value(password, path):
    all_values = get_counters(password, path)
    return list(all_values.items())[-1][1]


def get_software_version_and_modify_path_to_counter_if_neccesary(password, path_to_counter):
    api = admin()
    connection = api.connect_to(bts_host="192.168.255.129", password=password)
    soft = api.get_sw_version(connection=connection)
    if "_0000_" or "_0009_" in soft:
        path_to_counter = path_to_counter.replace("TRS/", "TRS/TNL-1/")
    return path_to_counter


def convert_time_from_epoch(epoch_time):
    converted_time = time.strftime('%H:%M:%S', time.localtime(int(epoch_time)))
    return converted_time
