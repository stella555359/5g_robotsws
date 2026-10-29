import datetime
import json
import time
import os
import pytz
from contextlib import contextmanager
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from taf.transport.ssh.ssh_keywords import SSHManager
from taf.transport.ssh import ssh

tl = BuiltIn().get_variable_value("${tl}")
work_dir = BuiltIn().get_variable_value("${work_directory}")


def find_pm_counters_by_time_stamp(time_stamp, pm_counters_dir, cell_list):
    import pandas as pd
    out_put_dir = {}
    for cell_id in cell_list:
        pm_counters = get_pm_counters_for_cell(time_stamp, pm_counters_dir, "NRCELL-"+str(cell_id))
        out_put_dir.update({"NRCELL-"+str(cell_id): pm_counters})
    df = pd.DataFrame.from_dict({(i, j): out_put_dir[i][j]
                                for i in out_put_dir.keys()
                                for j in out_put_dir[i].keys()},
                                orient='index')
    print(df)
    mod_time = str(time_stamp)
    mod_time = str.replace(mod_time, ':', '-')
    mod_time = str.replace(mod_time, ' ', '_')
    file_name = work_dir + 'pm_counters_' + mod_time + '.xlsx'
    df.to_excel(file_name)
    return file_name


def get_pm_counters_for_cell(time_stamp, pm_counters_dir, cell_id):
    date_format = datetime.datetime.strptime(time_stamp, "%Y-%m-%d_%H:%M:%S")
    unix_time = int(datetime.datetime.timestamp(date_format))
    print(unix_time)
    mrbts_id = BuiltIn().get_variable_value("${mrbts_id}")
    pm_counters_id_dir = pm_counters_dir['BTS']['MRBTS-'+mrbts_id]['NRBTS-'+mrbts_id][cell_id]['NRRIP']
    keys = pm_counters_id_dir.keys()
    key_list = list(keys)
    w = sorted(key_list)
    selected_values_dir = {}

    for nrrip_id in w:
        selected = pm_counters_dir['BTS']['MRBTS-'+mrbts_id]['NRBTS-'+mrbts_id][cell_id]['NRRIP'][nrrip_id]
        for k, v in selected.items():
            if k == str(unix_time):
                selected_values_dir.update({nrrip_id: {time_stamp: v}})
    return selected_values_dir


def generate_names_of_counters():
    prefix = "M55360C"
    first_counter_id_set_1 = 0
    last_counter_id_set_1 = 65
    first_counter_id_set_2 = 1000
    last_counter_id_set_2 = 1065
    counter_id_list = []

    counter_id_set_1 = str(first_counter_id_set_1).zfill(5)
    counter_id_list.append(prefix + counter_id_set_1)

    for counter in range(first_counter_id_set_1, last_counter_id_set_1):
        counter_id_set_1 = str(int(counter_id_set_1) + 1).zfill(len(counter_id_set_1))
        counter_id_list.append(prefix + counter_id_set_1)

    counter_id_set_2 = str(first_counter_id_set_2).zfill(5)
    counter_id_list.append(prefix + counter_id_set_2)

    for counter in range(first_counter_id_set_2, last_counter_id_set_2):
        counter_id_set_2 = str(int(counter_id_set_2) + 1).zfill(len(counter_id_set_2))
        counter_id_list.append(prefix + counter_id_set_2)

    counter_id_string = ",".join(counter_id_list)

    return counter_id_string


def verify_0_pm_counters(pm_output):
    if check_proper_zero_values(pm_output):
        logger.info('PASS')
        return True
    else:
        logger.error('FAIL!')
        return False


def check_proper_zero_values(input_excel_file):
    import pandas as pd
    df = pd.read_excel(input_excel_file)
    pm_cell_list = list(df.iloc[:, 0])
    pm_counters = list(df.iloc[:, 1])
    pm_values_orig = list(df.iloc[:, 2])
    if "NRCELL-1" not in pm_cell_list and "NRCELL-2" in pm_cell_list:
        return True
    else:
        # for debug purposes
        print(df)
        print(pm_cell_list)
        print(pm_counters)
        print(pm_values_orig)
        return False


def schedule_delay(delay):
    rerun = True
    while rerun:
        current_time = datetime.datetime.now().strftime("%M")
        rest_minute = 5 - int(current_time) % 5 - float(delay)

        current_time = datetime.datetime.now().strftime("%S")
        rest_seconds = 60 - int(current_time)

        scheduled_delay = rest_minute * 60 + rest_seconds

        if rest_minute < 0:
            rerun = True
            time.sleep(abs(scheduled_delay))
        else:
            rerun = False
            time.sleep(scheduled_delay)

    slot_start = datetime.datetime.now() + datetime.timedelta(seconds=int(150))
    return slot_start.strftime("%Y-%m-%d_%H:%M:%S")


def open_gnb_logger_connection(pc_alias):
    gnb_logger = SSHManager()
    hostname = BuiltIn().get_variable_value("${ue_pc_ip}")
    username = BuiltIn().get_variable_value("${ue_pc_user}")
    password = BuiltIn().get_variable_value("${ue_pc_password}")
    connection = gnb_logger.connect_to(hostname=hostname,
                                       username=username,
                                       password=password,
                                       alias=pc_alias,
                                       timeout=120.0)
    return gnb_logger, connection


def close_gnb_logger_connection(gnb_logger, connection):
    gnb_logger.disconnect(connection=connection)


@contextmanager
def enb_connection():
    enb_connection = ssh()
    enb_connection.connect_to(
        hostname=tl.enbs[0].oam_ip.v4,
        username=tl.gnbs[0].cu.oam_ssh_connection_details.username,
        password=tl.gnbs[0].cu.oam_ssh_connection_details.password,
    )
    try:
        yield enb_connection
    finally:
        pass


def __check_for_empty_file(file_path):
    if os.stat(file_path).st_size == 0:
        raise IOError("File is empty")


def check_if_rach_should_be_counted(actNrUlRipMeasurement_value):
    if "WithPRACH" in actNrUlRipMeasurement_value:
        return True
    else:
        return False


def compare_test_vector_and_pm_counters(test_vector_path, pm_counters_path, threshold, counters_len):
    import pandas as pd
    pm_pd = pd.read_excel(pm_counters_path)
    test_vector_pd = pd.read_csv(test_vector_path)
    pm_values_orig = pm_pd.iloc[:, 2].tolist()
    pm_counters = pm_pd.iloc[:, 1].tolist()
    expanded_pm_values = []
    original_counter = 0

    for i in range(0, counters_len):
        counter_value = int(pm_counters[original_counter][-3:])
        if i == counter_value:
            expanded_pm_values.append(pm_values_orig[original_counter])
            original_counter += 1
        else:
            expanded_pm_values.append(0.0)
    for i in range(0, counters_len):
        counter_value = int(pm_counters[original_counter][-3:])
        if i == counter_value:
            expanded_pm_values.append(pm_values_orig[original_counter])
            original_counter += 1
        else:
            expanded_pm_values.append(0.0)
    expanded_pm_values.extend(pm_values_orig[original_counter:])
    print(pm_values_orig)
    print(expanded_pm_values)
    pm_values = expanded_pm_values
    test_values = test_vector_pd.iloc[:, 0].tolist()
    print(test_values)
    avg_cumulative_error_abs = 0
    avg_cumulative_error = 0
    avg_max_error_abs = 0
    avg_exceed_threshold_count = 0
    avg_mean_error = 0
    max_cumulative_error_abs = 0
    max_cumulative_error = 0
    max_max_error_abs = 0
    max_exceed_threshold_count = 0
    max_mean_error = 0
    check_pm_counter_min_value(pm_values_orig, test_values)

    for avg_index, avg_value in enumerate(pm_values[0:counters_len]):
        avg_cumulative_error += pm_values[avg_index] - test_values[avg_index]
        avg_cumulative_error_abs += abs(pm_values[avg_index] - test_values[avg_index])
        if avg_max_error_abs < abs(pm_values[avg_index] - test_values[avg_index]):
            avg_max_error_abs = abs(pm_values[avg_index] - test_values[avg_index])
        if abs(pm_values[avg_index] - test_values[avg_index]) > threshold:
            avg_exceed_threshold_count += 1
            print("PRB nr " + str(avg_index) + " exceeds avg threshold!")
        avg_mean_error = avg_cumulative_error_abs / counters_len

    for max_index, max_value in enumerate(pm_values[counters_len:(2 * counters_len)]):
        max_cumulative_error += pm_values[counters_len + max_index] - test_values[counters_len + max_index]
        max_cumulative_error_abs += abs(pm_values[counters_len + max_index] - test_values[counters_len + max_index])
        if max_max_error_abs < abs(pm_values[counters_len + max_index] - test_values[counters_len + max_index]):
            max_max_error_abs = abs(pm_values[counters_len + max_index] - test_values[counters_len + max_index])
        if abs(pm_values[counters_len + max_index] - test_values[counters_len + max_index]) > threshold:
            max_exceed_threshold_count += 1
            print("PRB nr " + str(max_index) + " exceeds max threshold!")
        max_mean_error = max_cumulative_error_abs / counters_len

    print("avg_cumulative_error_abs:", avg_cumulative_error_abs)
    print("avg_cumulative_error:", avg_cumulative_error)
    print("avg_max_error_abs:", avg_max_error_abs)
    print("avg_exceed_threshold_count:", avg_exceed_threshold_count)
    print("avg_mean_error:", avg_mean_error)
    print("max_cumulative_error_abs:", max_cumulative_error_abs)
    print("max_cumulative_error:", max_cumulative_error)
    print("max_max_error_abs:", max_max_error_abs)
    print("max_exceed_threshold_count:", max_exceed_threshold_count)
    print("max_mean_error:", max_mean_error)

    return avg_exceed_threshold_count, max_exceed_threshold_count


def check_pm_counter_min_value(pm_values_orig, test_values):
    MIN_COUNTER_VAL = -112.4
    orig_wrong_val = [counter for counter in pm_values_orig if counter < MIN_COUNTER_VAL]
    test_wrong_val = [counter for counter in test_values if counter < MIN_COUNTER_VAL]
    if orig_wrong_val:
        raise Exception(f"Minimum value in orig list exceeded: {orig_wrong_val}")
    elif test_wrong_val:
        raise Exception(f"Minimum value in test list exceeded: {test_wrong_val}")
