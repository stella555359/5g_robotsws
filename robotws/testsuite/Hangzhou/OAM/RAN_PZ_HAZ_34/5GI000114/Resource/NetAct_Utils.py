import requests
import time
import re
import json
import sys
import ipaddress
from robot.api import logger


def Get_Package_Version(package_header, states=['RELEASED']):
    geturl = 'https://wft.int.net.nokia.com:8091/SBTS/api/v1/build_branch.json'
    proxies = {"http": "http://10.144.1.10:8080", "https": "http://10.144.1.10:8080"}
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
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
    '''
    params = (
        ('access_key', 'AeV05mdoXixIkWLehcgyU4axQK9pT2I4z8uMTNnk'),
        ('view[items]', 5),
        ('view[columns[][id]]', 'version'),
        ('view[columns[][id]]', 'state'),
        ('view[sorting_field]', 'created_at'),
        ('view[sorting_direction]', 'DESC'),
        ('view[view_filters_attributes[514270386402447]][column]', 'deliverer.title'),
        ('view[view_filters_attributes[514270386402447]][operation]', 'eq'),
        ('view[view_filters_attributes[514270386402447]][value][]', '5G_Central'),
        ('view[view_filters_attributes[679058805529075]][column]', 'deliverer.project.full_path'),
        ('view[view_filters_attributes[679058805529075]][operation]', 'eq'),
        ('view[view_filters_attributes[679058805529075]][value][]', '5G:WMP'),
        ('view[view_filters_attributes[707104893350814]][column]', 'version'),
        ('view[view_filters_attributes[707104893350814]][operation]', 'cont'),
        ('view[view_filters_attributes[707104893350814]][value][]', package_header),
        ('view[view_filters_attributes[884982785816370]][column]', 'state'),
        ('view[view_filters_attributes[884982785816370]][operation]', 'eq_any'),
    )
    '''
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


def Format_Date_String(date_str):
    return time.mktime(time.strptime(date_str, "%a %b %d %H:%M:%S %Y"))


def Download_NIDD_Alarm_Manual_Page(domain='SingleOAM', product='MRBTS PM/FM',
                                    productRelease='5G20B cOAM PM/FM', file_path='ManualPagesExport.zip'):
    geturl = 'http://esnidd055.emea.nsn-net.net/nidd/Api/Alarm/ManualPagesExport'
    proxies = {}
    headers = {'Content-Type': 'application/zip', 'Accept': 'application/zip'}
    params = (
        ('domain', domain),
        ('product', product),
        ('productRelease', productRelease),
        ('IncludeInheritedData', 'true'),
        ('versionFilter', 'Latest'),
    )
    try:
        r = requests.get(geturl, proxies=proxies, timeout=60, headers=headers, params=params)
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
    with open(file_path, "wb") as f:
        f.write(r.content)


def Get_Compressed_IPv6_Address(address):
    return ipaddress.ip_address(unicode(address)).compressed


def Get_Exploded_IPv6_Address(address):
    return ipaddress.ip_address(unicode(address)).exploded


if __name__ == "__main__":
    package_header = 'SBTS00_ENB_9999'
    states = ['RELEASED', 'RELEASED_WITH_RESTRICTIONS']
    # sort_rules = ['RELEASED']
    print(Get_Package_Version(package_header=package_header, states=states))
