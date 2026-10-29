"""
        Keywords Purpose:
            PM files analyze
        AUTHOR :
            Annie WONG        annie.wong@nokia.com
        Update 12.12.2019 :
           since taf.analyzer.pmcounter 0.3.2 format findall() or get_pi_value() changed
           (TALIB-758 and TALIB-761), thus need to take pm_setup change in account
        update 08.09.20 :
           add function: get_pi_value_for_one_cell_from_file, get_pi_xpaths
"""

from taf.analyzer.pmcounter.pm_log_reader import PMCounterLogReader
import re
import os
import json
import time


def get_pi_value_for_one_cell_from_file(pi_name, pi_dir, file_name, cell):
    n = 0
    while True:
        with open(os.path.join(pi_dir, file_name)) as file_obj:
            for log_entry in PMCounterLogReader([file_obj]):
                try:
                    n = n + 1
                    return log_entry.pm_setup.xpath("//NRCELL[@id='{}']//@{}".format(cell, pi_name))[0]
                except IndexError as e:
                    time.sleep(10)
                    if n > 10:
                        raise Exception("Counter value not found in file %s" % (file_name))
        continue


def get_pi_xpaths(pi_name, pi_dir, file_name):
    with open(os.path.join(pi_dir, file_name)) as file_obj:
        for log_entry in PMCounterLogReader([file_obj]):
            return json.dumps(log_entry.pm_setup.paths(pi_name), indent=4)


def read_pi_value_from_file_obsolete(pi_dir, file_name, pi_name):
    return [log_entry.pm_setup.findall(pi_name)[0]
            for log_entry in PMCounterLogReader.from_dir(
            pm_dir=pi_dir, file_pattern=file_name)]


def get_pi_dict_from_file(pi_name, pi_dir, file_name):
    return [log_entry.pm_setup.pi_dict(pi_name)
            for log_entry in PMCounterLogReader.from_dir(
            pm_dir=pi_dir, file_pattern=file_name)]


def get_pi_list_values_from_file(pi_name, pi_dir, file_name):
    pi_dir = _parsing_path(pi_dir)
    return [log_entry.pm_setup.findall(pi_name)
            for log_entry in PMCounterLogReader.from_dir(
            pm_dir=pi_dir, file_pattern=file_name)]


def get_pi_value_from_file(pi_name, pi_dir, file_name):
    result_list = get_pi_list_values_from_file(pi_name, pi_dir, file_name)
    length = len(result_list)
    if length == 0:
        raise KeyError(pi_name)
    else:
        sum = 0
        for PmSetup in result_list:
            if PmSetup:
                for pi_value in PmSetup:
                    sum = sum + int(pi_value)
    return sum


def _parsing_path(path):
    square_bracket_regex_pattern = r"[\[|\]]"
    new_path = re.sub(square_bracket_regex_pattern, r"[\g<0>]", path)
    if new_path:
        return new_path
    return path


def extract_last_values_from_pi_dict(pi_dict, counters_count):
    # add by Amadou FAYE
    result_dict = str(pi_dict)

    result_dict = result_dict.split(":")
    y = result_dict[6]
    w = y.replace("'}}}", "")
    w = w.replace("'", "")
    value = int(w)
    return value


def extract_last_values_from_pi_dict_for_du_pm(pi_dict, counters_count):
    # added by Philippe VIGNERTE for DU PM
    # similar to original extract_last_values_from_pi_dict
    result_dict = str(pi_dict)

    result_dict = result_dict.split(":")
    y = result_dict[6]
    w = y.replace("'}}}", "")
    w = w.replace("'", "")
    value = int(w)
    return value


def read_pi_value_from_file(pi_dir, file_name, pi_name):
    print(pi_dir)
    print(file_name)
    print(pi_name)

    return [{str(pi_name): log_entry.pm_setup.findall(pi_name)}
            for log_entry in PMCounterLogReader.from_dir(pm_dir=pi_dir, file_pattern=file_name)]


def report_latest_PIvalue(pi_dir, file_name, pi_name):
    print(file_name)
    print(pi_name)
    for log_entry in PMCounterLogReader.from_dir(pm_dir=pi_dir, file_pattern=file_name):
        lg = log_entry.pm_setup.findall(pi_name)
        if lg:
            val = int(lg[0])
    return val
