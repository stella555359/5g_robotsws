from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import unzip_file
from datetime import datetime
import shutil
import json
import os


def __get_date_in_epoch_time(content):
    for line in content:
        if 'startTime=' in line:
            data = line.split('T')
            year, month, day = data[1][5:].split('-')
            hour, minute, sec = data[-1].split('.')[0].split(':')
            file_datetime = datetime(int(year), int(month), int(day), int(hour), int(minute), int(sec))
            delta_time = file_datetime - datetime(1970, 1, 1)
            return int(delta_time.total_seconds())
    return None


def __gather_counters(content, epoch_time, result_dict):
    for line in content:
        if line.startswith('M') and '</M' in line:
            counter = line.split('>')[0]
            value = line.split('>')[1].split('</')[0]
            if counter in result_dict:
                result_dict[counter].update({epoch_time: int(value)})
            else:
                result_dict.update({counter: {epoch_time: int(value)}})


def __pack_counters_to_dictionary(dir_list):
    result_dict = dict()
    for a_file in dir_list:
        if 'PM.BTS' in a_file:
            with open(a_file, 'r') as the_file:
                content = the_file.read().split('><')
                epoch_time = __get_date_in_epoch_time(content)
                __gather_counters(content, epoch_time, result_dict)
    return result_dict


def __get_pm_counters_zip_file(destination):
    snapshot_list_path = os.path.join(destination, 'snapshot_file_list.txt')
    with open(snapshot_list_path, 'r') as snapshot_list_file:
        content = snapshot_list_file.read().split('\n\n')
        for a_file in content:
            if 'PM.BTS' in a_file:
                return a_file.split(':')[0]


def __unpack_pm_counters_zips(destination, dir_list):
    counters = os.path.join(destination, 'counters')
    os.mkdir(counters)
    dir_list = [os.path.join(destination, a_file) for a_file in dir_list]
    for a_file in dir_list:
        if 'PM.BTS' in a_file:
            unzip_file(a_file, counters)
    return counters


def get_pm_counters_from_snapshot(snapshot_path):
    """
    It gathers pm counters from snapshot.

    :author: Adrianna Pienkowska
    :param snapshot_path: snapshot_path
    :return: pm counters dictionary as json
    """
    destination = os.path.join(os.getcwd(), 'temp_snapshot_counters')
    os.mkdir(destination)
    unzip_file(snapshot_path, destination)
    pm_counters_zip_name = __get_pm_counters_zip_file(destination)
    pm_counters_zip_path = os.path.join(destination, pm_counters_zip_name)
    pm_counter_file = os.path.join(destination, 'pm_counters')
    os.mkdir(pm_counter_file)
    unzip_file(pm_counters_zip_path, pm_counter_file)
    dir_list = os.listdir(pm_counter_file)
    counters_path = __unpack_pm_counters_zips(pm_counter_file, dir_list)
    dir_list = os.listdir(counters_path)
    dir_list = [os.path.join(counters_path, a_file) for a_file in dir_list]
    result_dict = json.dumps(__pack_counters_to_dictionary(dir_list))
    shutil.rmtree(destination)
    return result_dict
