import urllib
import os
import sys
import urllib
import ssl
from optparse import OptionParser
import requests
import urllib.request
import ast
import json
from time import time
from itertools import cycle
import urllib3
from datetime import datetime, timedelta
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def return_sbts_trunk_builds_list_of_dicts(link):
    proxy = urllib.request.ProxyHandler({
        'http': '10.158.100.6:8080',
        'https': '10.158.100.6:8080'
    })
    opener = urllib.request.build_opener(proxy)
    urllib.request.install_opener(opener)
    req = urllib.request.urlopen(link)
    datatrunk = json.loads(req.read().decode('utf-8'))
    return (datatrunk)


def replace_sbts_version_prefix_to_sbts00(raw_version):
    length = raw_version.find('_')
    new_version = raw_version.replace(raw_version[0:length], "SBTS00")
    return (new_version)


def return_list_of_trunk_builds_corrected_with_sbts00(list_of_build_dict):
    list_of_builds_modified = []
    for each in list_of_build_dict:
        buildid = each['buildId']
        new_version = replace_sbts_version_prefix_to_sbts00(buildid)
        list_of_builds_modified.append(new_version)
    return (list_of_builds_modified)


def make_coop_link_for_today():
    today = datetime.today().strftime("%Y-%m-%d")
    yesterday = datetime.today() - timedelta(1)
    yesterday = yesterday.strftime("%Y-%m-%d")
    link_part1 = "http://coop.int.net.nokia.com:3001/api/pci/getBuildList?startDate=2024-04-20&"
    link_part2 = "endDate=2024-04-29&bl=sran&product=sbts&phase=qt&branch=sbts00&type=product"
    link = link_part1 + link_part2
    start_date_pos = link.find('startDate=')
    end_date_pos = link.find('endDate=')
    new_link = link.replace(
        link[start_date_pos + 10:start_date_pos + 20], yesterday)
    new_link = new_link.replace(
        new_link[end_date_pos + 8:end_date_pos + 18], today)
    return (new_link)


def return_latest_trunk_passed():
    coop_link = make_coop_link_for_today()
    list_of_build_dict = return_sbts_trunk_builds_list_of_dicts(coop_link)
    final_list_of_builds = return_list_of_trunk_builds_corrected_with_sbts00(
        list_of_build_dict)
    return (final_list_of_builds)


def convert_str_to_date(date_time_str):
    format = '%y%m%d'
    datetime_converted = datetime.strptime(date_time_str, format)
    return datetime_converted


def return_target_build_to_rfrl(curr_build_installed):
    curr_version_splitted = curr_build_installed.split('_')
    date_of_curr_build = convert_str_to_date(curr_version_splitted[3])
    version_number_curr_build = curr_version_splitted[4]
    list_trunk = return_latest_trunk_passed()
    reverse_list = list_trunk
    reverse_list.reverse()
    for each in reverse_list:
        version_splitted = each.split('_')
        date_of_build = convert_str_to_date(version_splitted[3])
        version_number_each = version_splitted[4]
        if date_of_curr_build < date_of_build:
            break
        elif date_of_curr_build == date_of_build:
            if version_number_curr_build < version_number_each:
                break
            elif version_number_curr_build == version_number_each:
                pass
        else:
            continue
    return (each)
