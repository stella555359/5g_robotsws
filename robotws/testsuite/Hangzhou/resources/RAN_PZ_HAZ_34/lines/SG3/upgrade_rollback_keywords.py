import json
import os

import requests
from lxml import etree


def get_download_version(file, index=0):
    with open(file, 'r') as f:
        json_data = json.load(f)
    version_list = json_data[index].get('download_version')
    return version_list


def get_repeat_times(file, index=0):
    with open(file, 'r') as f:
        json_data = json.load(f)
    repeat_times = json_data[index].get('repeat_times')
    return repeat_times


def get_used_info(file, index=0):
    with open(file, 'r') as f:
        json_data = json.load(f)
    node_index = json_data[index].get('node_index')
    node_type = json_data[index].get('node_type')
    node_upgrade_boolean = json_data[index].get('node_upgrade_boolean')
    node_rollback_boolean = json_data[index].get('node_rollback_boolean')
    node_reset_boolean = json_data[index].get('node_reset_boolean')
    return node_index, node_type, node_upgrade_boolean, node_rollback_boolean, node_reset_boolean


def get_node_num(file):
    with open(file, 'r') as f:
        json_data = json.load(f)
    node_num = len(json_data)
    return node_num


def get_download_link_release(release_url):
    release_name = []
    response = requests.get(url=release_url)
    if response.status_code == 200:
        html = etree.HTML(response.text)
        release = html.xpath('//a/text()')
        for i in release:
            if i[:-1].endswith('packages'):
                release_name.append(i[:-1].split('_')[0])
    print(release_name)
    return release_name


def get_version_size(package_url):
    response = requests.get(url=package_url)
    if response.status_code == 200:
        print(response.text)


def get_parameter_value_on_json(file, key, index=0):
    para_value = "False"
    with open(file, 'r') as f:
        json_data = json.load(f)
    if key in json_data[index]:
        para_value = json_data[index].get(key)
    return para_value


def get_alarm_check_time_on_json(file, key, index=0):
    para_value = 5
    with open(file, 'r') as f:
        json_data = json.load(f)
    if key in json_data[index]:
        para_value = json_data[index].get(key)
    return para_value


def get_is_check_lower_version_to_upgrade_on_json(file, key, index=0):
    is_check_lower_version_to_upgrade = "True"
    with open(file, 'r') as f:
        json_data = json.load(f)
    if key in json_data[index]:
        is_check_lower_version_to_upgrade = json_data[index].get(key)
    return is_check_lower_version_to_upgrade


def get_new_download_link_release(release_url):
    release_name = []
    headers = {
        "authorization": "Basic bTFzaGk6UWF6d3N4ZWRjcmZ2dGdiOA=="
    }
    response = requests.get(url=release_url, headers=headers)
    if response.status_code == 200:
        html = etree.HTML(response.text)
        release = html.xpath('//a/text()')
        print(release)
        for i in release:
            release_name.append(i[:-1])
    print(release_name)
    return release_name


def convert_list_to_string(para_list):
    para_str = ','.join(para_list)
    return para_str


def download_release_build(release_url, release_name, download_path='/home/ute/Downloads/'):
    headers = {
        "authorization": "Basic bTFzaGk6UWF6d3N4ZWRjcmZ2dGdiOA=="
    }
    split_release_name_first_part = release_name.split(sep='_', maxsplit=1)[0]
    split_release_name_second_part = release_name.split(sep='_', maxsplit=1)[1]
    release_branch_list = get_new_download_link_release(release_url)
    if split_release_name_first_part != 'SBTS00':
        if release_name.split('_')[0] not in release_branch_list:
            release_branch = 'SBTS00'
            build_name = release_branch + '_' + split_release_name_second_part
        else:
            release_branch = split_release_name_first_part
            build_name = release_branch + '_' + split_release_name_second_part
    else:
        release_branch = split_release_name_first_part
        build_name = release_branch + '_' + split_release_name_second_part
    with requests.get(
            url=f"{release_url}{release_branch}/{build_name}/{build_name}_release_BTSSM_downloadable_A54.zip",
            headers=headers, stream=True) as response:
        with open(download_path + build_name + '_release_BTSSM_downloadable_A54.zip', 'wb') as f:
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    f.write(chunk)


def check_fault_is_existed(
        detected_fault_id: list):
    _default_white_fault_id = [
        61652,
        4655,
        61524,
        4654,
        7313,
        61649,
        7300,
        7319,
        4459,
        4592,
        4334,
        2922,
        2923,
        49,
        4614,
        7107,
        62003,
        7523,
        6327,
        62001,
        7311,
        4125,
        4420
    ]
    is_unexpected_fault = False
    unexpected_fault_id = None
    for fault_id in detected_fault_id:
        if fault_id in _default_white_fault_id:
            continue
        else:
            is_unexpected_fault = True
            unexpected_fault_id = fault_id
            break
    return is_unexpected_fault, unexpected_fault_id
