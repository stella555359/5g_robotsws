#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:li ya nan
import requests
import re
import json
import time
import datetime
from datetime import datetime, date, timedelta
import os

access_key = 'bLzHV0lmgNLPT2A1nm78Mf95iNd6Kuov0tZiJxz2'
parameters = {
    "page": "",
    "items": "20",
    "sorting_field": "created_at",
    "sorting_direction": "DESC",
    "group_by": "",
    "group_by_processor": "",
    "columns": {
        "0": {
            "id": "version"
        },
        "1": {
            "id": "quicktest_status"
        },
        "2": {
            "id": "quicktest2_status"
        },
        "3": {
            "id": "test_result_group",
            "element": "1"
        },
        "4": {
            "id": "build_reasons"
        },
        "5": {
            "id": "test_result_group",
            "element": "3"
        },
        "6": {
            "id": "delivery_date"
        },
        "7": {
            "id": "ps_env"
        },
        "8": {
            "id": "changed_baselines"
        },
        "9": {
            "id": "promotion_status_td"
        }
    },
    "projects": [
        "SBTS"
    ],
    "view_filters_attributes": {
        "0": {
            "column": "state_machine_title",
            "operation": "eq_any",
            "value": [
                "Central",
                "Imported Central",
                "Central_A1"
            ],
            "parameter": ""
        },
        "1": {
            "column": "branch.title",
            "operation": "eq",
            "value": [
                "SBTS00"
            ],
            "parameter": ""
        },
        "2": {
            "column": "quicktest.result",
            "operation": "matches_regexp",
            "value": [
                "RELEASED_WITH_RESTRICTIONS|^RELEASED$"
            ],
            "parameter": ""
        },
    },
    "access_key": access_key
}


def replace_matched_string_in_dict(obj, pattern, replacement):
    if isinstance(obj, str):
        x = re.sub(pattern, replacement, obj)
        return re.sub(pattern, replacement, obj)
    elif isinstance(obj, dict):
        return {k: replace_matched_string_in_dict(v, pattern, replacement) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [replace_matched_string_in_dict(v, pattern, replacement) for v in obj]
    else:
        return obj


def modify_parameter_json_file(filename, pattern, new_release):
    with open(filename, 'r') as f:
        data = json.load(f)

    data = replace_matched_string_in_dict(data, pattern, new_release)
    print("old_release:%s" % pattern)
    print("new_release:%s" % new_release)

    with open(filename, 'w') as f:
        json.dump(data, f, indent=4)


def get_enb(release='SBTS20B'):
    url = 'https://wft.int.net.nokia.com:8091/SBTS/api/v1/build_branch.json'

    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
    }
    path = os.path.dirname(__file__)
    print(path)
    # filename = path + '/params.json'
    # modify_parameter_json_file(filename, r"SBTS\d{2}(R\d)?(_FSM3)?(_1.0PD)?", release)
    # data = open(filename)
    data = parameters
    data['view_filters_attributes']['1']['value'][0] = release
    data = json.dumps(data, indent=4)
    try:
        info = requests.post(url, headers=headers, data=data)
    except Exception as e:
        print("Error type: {}, Error: {}".format(type(e).__name__, e))
        exit()

    builds = re.findall('version":(.*?),"started', info.text, re.S)
    print(builds)
    release_build_list = []
    for build in builds:
        full_info = build.split('\"')
        build_name = full_info[1]
        # print(full_info[1])
        build_state = full_info[7]
        # print(full_info[7])
        if build_state in ['released_with_restrictions', 'RELEASED', 'released', 'RELEASED_WITH_RESTRICTIONS']:
            release_build_list.append(build_name)

    print(release_build_list)
    return release_build_list


def get_enb_bakup(release_num):
    url = 'http://files.ute.nsn-rdnet.net/builds/enb/base/'
    html = requests.get(url).text
    requests.adapters.Default_RETRIES = 5
    s = requests.session()
    s.keep_alive = False
    release_list = []
    if release_num == 'SBTS00':
        release_date_list = re.findall(r'<a href="SBTS00_ENB_9999_2(.*?)/"', html)
        M_D = str(date.today()).replace('-', '')[4:]
        for i in range(len(release_date_list)):
            target_enb = "SBTS00_ENB_9999_2" + release_date_list[i]
            release_list.append(target_enb)
    elif release_num == 'SBTS00_FSM3':
        release_date_list = re.findall(r'<a href="SBTS00_FSM3_9999_2(.*?)/"', html)
        M_D = str(date.today()).replace('-', '')[4:]
        for i in range(len(release_date_list)):
            # if (M_D == release_date_list[i].split('_')[0]):
            target_enb = "SBTS00_FSM3_9999_2" + release_date_list[i]
            # print(("SBTS00_ENB_9999_2" + release_date_list[i]))
            release_list.append(target_enb)
    elif release_num == 'SBTS24R3_FSM3':
        release_date_list = re.findall(r'<a href="SBTS00_FSM3_9999_2(.*?)/"', html)
        M_D = str(date.today()).replace('-', '')[4:]
        for i in range(len(release_date_list)):
            # if (M_D == release_date_list[i].split('_')[0]):
            target_enb = "SBTS00_FSM3_9999_2" + release_date_list[i]
            # print(("SBTS00_ENB_9999_2" + release_date_list[i]))
            release_list.append(target_enb)
    elif release_num == 'SBTS24R2_FSM3':
        release_date_list = re.findall(r'<a href="SBTS00_FSM3_9999_2(.*?)/"', html)
        M_D = str(date.today()).replace('-', '')[4:]
        for i in range(len(release_date_list)):
            # if (M_D == release_date_list[i].split('_')[0]):
            target_enb = "SBTS00_FSM3_9999_2" + release_date_list[i]
            # print(("SBTS00_ENB_9999_2" + release_date_list[i]))
            release_list.append(target_enb)
    else:
        branch_part_list = re.findall(r'<a href="(%s)_ENB_0000(.*?)/"' % release_num, html)
        for i in range(len(branch_part_list)):
            target_branch = str(release_num) + "_ENB_0000" + branch_part_list[i][1]
            release_list.append(target_branch)
    return release_list


def CNI_Infomodel_Adapter_release(release_num):
    if release_num == 'SBTS21A' or release_num == 'SBTS21B' or release_num == 'SBTS21C' \
            or release_num == 'SBTS22R1' or release_num == 'SBTS22R2' or release_num == 'SBTS20C':
        with_CNI_Infomodel = False
    else:
        with_CNI_Infomodel = True
    return with_CNI_Infomodel


if __name__ == "__main__":
    get_enb('SBTS00')
