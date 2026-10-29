import requests
import time
import re
import json
import sys
import ipaddress
from robot.api import logger


def Get_RFMPlugin_Version(product_code="474736A-101"):
    geturl = 'https://wft.int.net.nokia.com:8091/LTE/api/v1/build.json'
    proxies = {"http": "http://10.144.1.10:8080",
               "https": "http://10.144.1.10:8080"}
    headers = {'Content-Type': 'application/json',
               'Accept': 'application/json'}
    params = (
        ('access_key', 'LH54rQfxJMvcoBJw3WoyYXMhG0mQ29ZcaHJTtolM'),
        ('view[items]', 20),
        ('view[sorting_field]', 'created_at'),
        ('view[sorting_direction]', 'DESC'),
        ('view[columns[][id]]', 'version'),
        ('view[columns[][id]]', 'state'),
        ('view[view_filters_attributes[845537914895697]][column]', 'component'),
        ('view[view_filters_attributes[845537914895697]][operation]', 'eq'),
        ('view[view_filters_attributes[845537914895697]][value][]', 'RFMPlugin'),
        ('view[view_filters_attributes[418319236550090]][column]', 'version'),
        ('view[view_filters_attributes[418319236550090]][operation]', 'cont'),
        ('view[view_filters_attributes[418319236550090]][value][]', product_code),
        ('view[view_filters_attributes[70019399008589]][column]', 'state'),
        ('view[view_filters_attributes[70019399008589]][operation]', 'cont'),
        ('view[view_filters_attributes[70019399008589]][value][]', 'RELEASED'),
    )

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


def Get_Package_Version(package_header, states=['RELEASED']):
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
        ('view[view_filters_attributes[753977344455643]][column]', 'version'),
        ('view[view_filters_attributes[753977344455643]][operation]', 'cont'),
        ('view[view_filters_attributes[753977344455643]][value][]', package_header),
        ('view[view_filters_attributes[596423879355311]][column]', 'state'),
        ('view[view_filters_attributes[596423879355311]][operation]', 'eq_any')
    )

    for state in states:
        params += (('view[view_filters_attributes[596423879355311]][value][]', state), )
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


def get_fault_id_via_nom(alarms_list):
    list_alarm = []
    for alarms in alarms_list:
        for key, value in alarms.items():
            print(value)
            try:
                if value.split('additionalFaultID=')[1].split()[0]:
                    list_alarm.append(int(value.split('additionalFaultID=')[1].split()[0]))
            except BaseException as e:
                pass
    return list_alarm


if __name__ == "__main__":
    product_code = "474736A-102"
    print(Get_RFMPlugin_Version(product_code=product_code))
