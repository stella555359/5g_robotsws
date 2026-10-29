import os
import time
import datetime
from typing import NoReturn
from robot.api import logger
from collections import OrderedDict
from signal_generator import SignalGenerator
from pm_counter_errors import PmCounterComparisonError


def set_generator(generator_ip: str, frequency_val: str, amplitude_val: str, bandwidth_val: str) -> NoReturn:
    generator = SignalGenerator()
    generator.connect_to_generator(generator_ip, 5023)
    generator.execute_cmd(":FREQuency " + frequency_val)
    generator.execute_query(":FREQuency?")
    generator.execute_cmd(":AMPLitude " + amplitude_val)
    generator.execute_query(":AMPLitude?")
    generator.execute_cmd(":RADio:AWGN:RT:BWIDth " + bandwidth_val)
    generator.execute_query(":RADio:AWGN:RT:BWIDth?")
    generator.execute_cmd("RADio:AWGN:RT:STATe ON")
    generator.close_connections()


def run_generator(generator_ip: str) -> NoReturn:
    generator = SignalGenerator()
    generator.connect_to_generator(generator_ip, 5023)
    generator.execute_cmd(":OUTPut:STATe ON")
    generator.close_connections()
    logger.console("[{}] Generator running".format(datetime.datetime.now()))


def turn_off_generator(generator_ip: str) -> NoReturn:
    generator = SignalGenerator()
    generator.connect_to_generator(generator_ip, 5023)
    generator.execute_cmd(":OUTPut:STATe OFF")
    logger.console("[{}] Generator OFF".format(datetime.datetime.now()))
    generator.close_connections()


def schedule_delay(delay: str) -> str:
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
    slot_start = datetime.datetime.now() + datetime.timedelta(seconds=150)
    return slot_start.strftime("%Y-%m-%d_%H:%M:%S")


def generate_names_of_counters() -> str:
    prefix = "M55360C"
    first_counter_id_set_1 = 0
    first_counter_id_set_2 = 1000
    last_counter_id_set_1 = 272
    last_counter_id_set_2 = 1272
    counter_id_list = []
    counter_id_set_1 = str(first_counter_id_set_1).zfill(5)
    counter_id_list.append(prefix + counter_id_set_1)
    for c_id in range(first_counter_id_set_1, last_counter_id_set_1):
        counter_id_set_1 = str(int(counter_id_set_1) + 1).zfill(len(counter_id_set_1))
        counter_id_list.append(prefix + counter_id_set_1)
    counter_id_set_2 = str(first_counter_id_set_2).zfill(5)
    counter_id_list.append(prefix + counter_id_set_2)
    for c_id in range(first_counter_id_set_2, last_counter_id_set_2):
        counter_id_set_2 = str(int(counter_id_set_2) + 1).zfill(len(counter_id_set_2))
        counter_id_list.append(prefix + counter_id_set_2)
    counter_id_string = ",".join(counter_id_list)
    return counter_id_string


def save_dict_to_excel(dict_to_save: dict, out_dir_path: str, file_name: str) -> str:
    import pandas as pd
    if not os.path.isdir(out_dir_path):
        os.makedirs(out_dir_path)
    df = pd.DataFrame.from_dict({(i, j): dict_to_save[i][j]
                                for i in dict_to_save.keys()
                                for j in dict_to_save[i].keys()},
                                orient='index')
    file_name = f"{out_dir_path}/{file_name}.xlsx"
    df.to_excel(file_name)
    return file_name


def find_pm_counters_by_time_stamp(time_stamp: str,
                                   pm_counters_dir: dict,
                                   cell_list: list,
                                   out_dir_path: str,
                                   counters_ids: str) -> str:
    out_put_dict = {}
    for cell_id in cell_list:
        cell_pm_counters = get_pm_counters_for_cell(time_stamp, pm_counters_dir, "NRCELL-"+str(cell_id))
        cell_pm_counters = fill_in_missing_counters(cell_pm_counters, counters_ids, time_stamp)
        out_put_dict.update({"NRCELL-"+str(cell_id): cell_pm_counters})
    return save_dict_to_excel(out_put_dict, out_dir_path, f'WEM_pm_counters_{time_stamp}')


def get_pm_counters_for_cell(time_stamp: str, pm_counters_dir: dict, cell_id: str) -> dict:
    date_format = datetime.datetime.strptime(time_stamp, "%Y-%m-%d_%H:%M:%S")
    unix_time = int(datetime.datetime.timestamp(date_format))
    pm_counters_id_dict = pm_counters_dir['BTS']['MRBTS-75086']['NRBTS-75086'][cell_id]['NRRIP']
    keys = pm_counters_id_dict.keys()
    key_list = list(keys)
    key_list = sorted(key_list)
    selected_values_dir = {}
    for c_id in key_list:
        zmienna = pm_counters_dir['BTS']['MRBTS-75086']['NRBTS-75086'][cell_id]['NRRIP'][c_id]
        for k, v in zmienna.items():
            if k == str(unix_time):
                selected_values_dir.update({c_id: {time_stamp: v}})
    return selected_values_dir


def fill_in_missing_counters(counters_dict: dict, counters_ids: str, time_stamp: str) -> dict:
    counters_ids = counters_ids.split(',')
    for c_id in counters_ids:
        counters_dict.setdefault(c_id, {time_stamp: 0.0})
    counters_dict = OrderedDict(sorted(counters_dict.items()))
    return counters_dict


def compare_test_vector_and_pm_counters(test_vector_path: str, pm_counters_path: str, tolerance: int = 20) -> NoReturn:
    import pandas as pd
    pm_pd = pd.read_excel(pm_counters_path)
    test_vector_pd = pd.read_csv(test_vector_path)
    vector_val = test_vector_pd.iloc[:, 0].tolist()
    pm_values_orig = pm_pd.iloc[:, 2].tolist()
    pm_counters = pm_pd.iloc[:, 1].tolist()
    for idd, pm, v in zip(pm_counters, pm_values_orig, vector_val):
        logger.debug(f"{idd} -> {pm} =? {v}")
    within_deviation = [
        abs(pm - v) <= (tolerance / 100) * abs(v)
        for pm, v in zip(pm_values_orig, vector_val)
    ]
    failed_indices = [i for i, ok in enumerate(within_deviation) if not ok]
    failed_counters = [pm_counters[i] for i in failed_indices]
    if failed_counters:
        logger.console(f"Failed values: {failed_counters}")
        raise PmCounterComparisonError
