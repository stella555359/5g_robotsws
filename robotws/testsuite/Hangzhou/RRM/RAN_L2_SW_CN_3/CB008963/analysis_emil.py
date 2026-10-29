# -*- coding: utf-8 -*-
# @Time    : 2025/1/3 10:54
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_emil.py
# @Software: PyCharm
import zipfile
import os
import time
import datetime


def my_unzip(zip_file):
    zip_folder = zip_file.replace(".zip", "")
    with zipfile.ZipFile(zip_file, "r") as zip_ref:
        if not os.path.exists(zip_folder):
            os.mkdir(zip_folder)
            zip_ref.extractall(zip_folder)
    return zip_folder


def find_special_file_from_folder(folder, special_file):
    file_list = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            try:
                if special_file in file:
                    file_list.append(root + "/" + file)
            except zipfile.BadZipFile:
                pass
    return file_list


def deep_get(dictionary, key, results):
    for k, v in dictionary.items():
        if k == key:
            results.append(v)
        if isinstance(v, dict):
            result = deep_get(v, key, results)
        if isinstance(v, list):
            for i in v:
                if isinstance(i, dict):
                    result = deep_get(i, key, results)
    return results


def verify_target_key_value_in_emil_json(emil_json, key, value):
    key_value = deep_get(emil_json, key, [])
    print(key_value)
    assert value in key_value


def get_target_key_value_in_emil_json(emil_json, key):
    key_value = deep_get(emil_json, key, [])
    return key_value


def find_target_key_values(emil_json, key):
    if isinstance(emil_json, dict):
        for k, value in emil_json.items():
            if k == key:
                return value
            elif isinstance(value, dict):
                result = find_target_key_values(value, key)
                if result:
                    return result
            elif isinstance(value, list):
                for item in value:
                    if isinstance(item, dict):
                        result = find_target_key_values(item, key)
                        if result:
                            return result
    return None


def wait_until_next_5_min(extra_sleep_time=60):
    now = datetime.datetime.now()
    seconds_past_last_5_min = (now.minute % 5) * 60 + now.second
    seconds_until_next_5_min = 300 - seconds_past_last_5_min
    time.sleep(seconds_until_next_5_min)
    if extra_sleep_time:
        time.sleep(int(extra_sleep_time))
