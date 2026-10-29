import requests
import time
import re
import json
import sys
import ipaddress
from robot.api import logger


def is_Same_FPGA(version_list=[]):
    try:
        items = Get_Package_sub_build(version_list)
        loner_version_list = []
        for item in items:
            sub_builds = item['sub_builds']
            for sub_build in sub_builds:
                name = sub_build['name']
                baseline = sub_build['baseline']

                if name == "LONER-TDD-eCPRI":
                    loner_version_list.append(baseline)
        loner_version_list = list(dict.fromkeys(loner_version_list))
        print(loner_version_list)
        if len(loner_version_list) <= 1:
            return True

        items = Get_LONER_TDD_eCPRI_sub_build(loner_version_list)
        fpga_version_list = []
        for item in items:
            sub_builds = item['sub_builds']
            for sub_build in sub_builds:
                name = sub_build['name']
                baseline = sub_build['baseline']

                if name == "meta-socsw-fpga":
                    fpga_version_list.append(baseline)
        fpga_version_list = list(dict.fromkeys(fpga_version_list))
        print(fpga_version_list)
        return True if len(fpga_version_list) <= 1 else False
    except Exception:
        return True
    else:
        return True


def Get_Package_sub_build(version_list=[]):
    geturl = 'https://wft.int.net.nokia.com:8091/SBTS/api/v1/build_branch.json'
    proxies = {"http": "http://10.144.1.10:8080",
               "https": "http://10.144.1.10:8080"}
    headers = {'Content-Type': 'application/json',
               'Accept': 'application/json'}
    params = (
        ('access_key', '66gzbWeO9aQQLLHl07PaAfqDTT6jQ523sAPkxXU2'),
        ('view[items]', 5),
        ('view[sorting_field]', 'created_at'),
        ('view[sorting_direction]', 'DESC'),
        ('view[columns[][id]]', 'version'),
        ('view[columns[][id]]', 'state'),
        ('view[columns[][id]]', 'sub_builds'),
        ('view[view_filters_attributes[753977344455643]][column]', 'version'),
        ('view[view_filters_attributes[753977344455643]][operation]', 'eq_any'),
    )

    for version in version_list:
        params += (('view[view_filters_attributes[753977344455643]][value][]', version), )

    try:
        r = requests.get(geturl, timeout=60, headers=headers, params=params)
        r.raise_for_status()
    except requests.exceptions.ConnectTimeout as t:
        print('Connection to: ', geturl, ' timed out')
        logger.info('Connection timed out', also_console=True)
    except requests.exceptions.HTTPError as err:
        print(err)
        logger.info(err, also_console=True)
    except requests.exceptions.RequestException as e:
        print(e)
        logger.info(e, also_console=True)
    packages = eval(r.text)
    return packages['items']


def Get_LONER_TDD_eCPRI_sub_build(version_list=[]):
    geturl = 'https://wft.int.net.nokia.com:8091/ALL/api/v1/build.json'
    proxies = {"http": "http://10.144.1.10:8080",
               "https": "http://10.144.1.10:8080"}
    headers = {'Content-Type': 'application/json',
               'Accept': 'application/json'}
    params = (
        ('access_key', '66gzbWeO9aQQLLHl07PaAfqDTT6jQ523sAPkxXU2'),
        ('view[items]', 5),
        ('view[sorting_field]', 'created_at'),
        ('view[sorting_direction]', 'DESC'),
        ('view[columns[][id]]', 'version'),
        ('view[columns[][id]]', 'state'),
        ('view[columns[][id]]', 'sub_builds'),
        ('view[view_filters_attributes[471585898327304]][column]', 'component'),
        ('view[view_filters_attributes[471585898327304]][operation]', 'eq'),
        ('view[view_filters_attributes[471585898327304]][value][]', 'LONER-TDD-eCPRI'),
        ('view[view_filters_attributes[660502019447676]][column]', 'version'),
        ('view[view_filters_attributes[660502019447676]][operation]', 'eq_any'),
        # ('view[view_filters_attributes[660502019447676]][value][]', 'LONER-TDD-eCPRI_5G24R3.0.0.20240611-072631'),
    )

    for version in version_list:
        params += (('view[view_filters_attributes[660502019447676]][value][]', version), )

    try:
        r = requests.get(geturl, timeout=60, headers=headers, params=params)
        r.raise_for_status()
    except requests.exceptions.ConnectTimeout as t:
        print('Connection to: ', geturl, ' timed out')
        logger.info('Connection timed out', also_console=True)
    except requests.exceptions.HTTPError as err:
        print(err)
        logger.info(err, also_console=True)
    except requests.exceptions.RequestException as e:
        print(e)
        logger.info(e, also_console=True)
    packages = eval(r.text)
    return packages['items']


if __name__ == "__main__":
    version_list = ['SBTS00_ENB_9999_240616_000012', 'SBTS00_ENB_9999_240513_000009']
    print(is_Same_FPGA(version_list=version_list))
