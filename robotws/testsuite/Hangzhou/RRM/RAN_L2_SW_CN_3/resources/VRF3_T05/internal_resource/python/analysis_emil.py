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


def get_values_via_key(data, target_key):
    """
    Recursively find all values associated with a target key in a JSON structure.
    :param data: The JSON data (dict or list).
    :param target_key: The key to search for.
    :return: A list of values associated with the target key.
    """
    results = []

    if isinstance(data, dict):
        for key, value in data.items():
            if key == target_key:
                results.append(value)
            elif isinstance(value, (dict, list)):
                results.extend(get_values_via_key(value, target_key))
    elif isinstance(data, list):
        for item in data:
            results.extend(get_values_via_key(item, target_key))

    return results


def get_ue_contains_measconfig_from_emil(emil_content):
    result = {
        "add_meas_ids": [],
        "remove_meas_ids": [],
        "add_meas_objects": [],
        "report_configs": []
    }
    for row in emil_content["emil_data"]["rows"]:
        try:
            user_data = row["User_data"]
            assert "DL RRC: rrcReconfiguration" in user_data
            json_contents = row["JsonContent"]
            for json_content in json_contents:
                try:
                    rrcReconfiguration = json_content["DL-DCCH-Message"]["message"]["c1"]["rrcReconfiguration"]
                    measConfig = rrcReconfiguration["criticalExtensions"]["rrcReconfiguration"]["measConfig"]
                    for add_meas_id in measConfig["measIdToAddModList"]:
                        result["add_meas_ids"].append(add_meas_id["measId"])
                    for remove_meas_id in measConfig["measIdToRemoveList"]:
                        result["remove_meas_ids"].append(remove_meas_id)
                    for add_meas_object in measConfig["measObjectToAddModList"]:
                        result["add_meas_objects"].append(add_meas_object["measObjectId"])
                    for report_config in measConfig["reportConfigToAddModList"]:
                        result["report_configs"].append(report_config["reportConfigId"])
                except KeyError:
                    pass
        except KeyError:
            pass
        except TypeError:
            pass
        except AssertionError:
            pass
    return result


def get_ue_contains_measreport_from_emil(emil_content):
    result = {
        "ser_cell_ids": [],
        "neigh_cell_ids": []
    }
    for row in emil_content["emil_data"]["rows"]:
        try:
            user_data = row["User_data"]
            assert "measurementReport" in user_data
            json_contents = row["JsonContent"]
            for json_content in json_contents:
                try:
                    measurementreport = json_content["UL-DCCH-Message"]["message"]["c1"]["measurementReport"]
                    measresults = measurementreport["criticalExtensions"]["measurementReport"]["measResults"]
                    for ser_item in measresults["measResultServingMOList"]:
                        if "measResultServingCell" in ser_item:
                            result["ser_cell_ids"].append(ser_item["measResultServingCell"]["physCellId"])
                    for neigh_cell_id in measresults["measResultNeighCells"]["measResultListNR"]:
                        result["neigh_cell_ids"].append(neigh_cell_id["physCellId"])
                except KeyError:
                    pass
        except KeyError:
            pass
        except TypeError:
            pass
        except AssertionError:
            pass
    return result
