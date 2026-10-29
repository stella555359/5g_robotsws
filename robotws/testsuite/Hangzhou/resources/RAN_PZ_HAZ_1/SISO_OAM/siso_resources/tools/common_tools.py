import re
import time
import requests
import datetime
import json

month_abbr = {
    "Jan": "01",
    "Feb": "02",
    "Mar": "03",
    "Apr": "04",
    "May": "05",
    "Jun": "06",
    "Jul": "07",
    "Aug": "08",
    "Sep": "09",
    "Oct": "10",
    "Nov": "11",
    "Dec": "12",
}

ACCESS_KEY = "a4zS8OqgORdbgBcPl1zeARszoMOkWBdq3XwsFGl5"


def get_last_build(branch, access_key=ACCESS_KEY):
    url = "https://wft.int.net.nokia.com:8091/api/v1/build.json"
    params = {
        "page": 1,
        "items": 1,
        "sorting_field": "created_at",
        "sorting_direction": "DESC",
        "group_by": "branch.title",
        "group_by_processor": "",
        "columns": {
            "0": {
                "id": "deliverer.project.full_path"
            },
            "1": {
                "id": "deliverer.title"
            },
            "2": {
                "id": "version"
            },
            "3": {
                "id": "branch.title"
            },
            "4": {
                "id": "state"
            },
            "5": {
                "id": "planned_delivery_date"
            },
            "6": {
                "id": "common_links"
            },
            "7": {
                "id": "compare_link"
            }
        },
        "projects": [
            "ALL"
        ],
        "view_filters_attributes": {
            "0": {
                "column": "branch.title",
                "operation": "eq",
                "value": branch,
                "parameter": ""
            },
            "1": {
                "column": "state",
                "operation": "eq",
                "value": "RELEASED",
                "parameter": ""
            },
            "2": {
                "column": "component",
                "operation": "cont",
                "value": "CI_ENB",
                "parameter": ""
            },
            "3": {
                "column": "deliverer.project.full_path",
                "operation": "cont",
                "value": "SBTS",
                "parameter": ""
            },
            "4": {
                "column": "state",
                "operation": "eq",
                "value": "RELEASED_WITH_RESTRICTIONS",
                "parameter": ""
            }
        },
        "access_key": access_key
    }

    headers = {'content-type': "application/json"}
    res = requests.post(url, data=json.dumps(params), headers=headers, verify=False).json()
    return res["items"][branch][0]["version"]


def get_init_sw(sw_type, current_rl=None, release_minus=1):
    url_default = "https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/"
    release_list = []
    # current_sw =
    release = "SBTS\\d+R\\d"
    try:
        response = requests.get(url_default)
        assert response.status_code == 200, "{} {}".format(response.status_code, response.text)
        res_list = response.text.split("\n")
        for item in res_list:
            sw_release = re.search(rf"{release}", item)
            if sw_release:
                if sw_release.group() not in release_list:
                    release_list.append(sw_release.group())

        release_list.sort()
        release_list.append("SBTS00")
        print(release_list)

        for i in range(len(release_list)):
            if release_list[i] == current_rl:
                current_index = i
                break
        release_index = release_minus
        release_name = release_list[0] if current_index <= 1 else release_list[current_index-release_index]
        release_name = release_name if sw_type == "ENB" else f"{release_name}_{sw_type}"
        print(release_name)
        sw_version = get_last_build(release_name)
        return sw_version
    except Exception as e:
        print("Get Init SW Error:", str(e))


def get_vm_ip_by_sn(ru_sn, tl):
    bts_count = len(tl.enbs)
    for _bts_index in range(bts_count):
        rms_count = len(tl.enbs[_bts_index].rms)
        for _ru_index in range(rms_count):
            get_ru_sn = tl.enbs[_bts_index].rms[_ru_index].serial_number
            if get_ru_sn == ru_sn:
                break
    vm_ip = tl.test_pcs[_bts_index].default_ssh_connection_details.addr
    return vm_ip
