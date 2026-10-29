# *-coding=utf-8-*

# Name: liujia
# Time: 2023/6/15 23:45
import csv
import json
import os
import re
import subprocess
import time

import pexpect
import requests

from taf.transport.ssh.connection import SSHConnection
import taf.transport.ssh as ssh
from robot.libraries.BuiltIn import BuiltIn
from taf.hw.rf_attenuator import rf_attenuator


def get_value_from_csv_file_dlFdSchedData(file_path, filter_name_1, queried_filed, mode="r"):
    with open(file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        required_data_list = []
        for data in csv_data:
            # if data[filter_name_1] == 'P14_VOIPTRAFFIC':
            #     required_data_list.append(float(data[queried_filed]))
            if 'VOIPTRAFFIC' in data[filter_name_1]:
                required_data_list.append(float(data[queried_filed]))
            # if 'P22' in data[filter_name_1]:
            #     required_data_list.append(float(data[queried_filed]))
    return required_data_list


def get_value_from_csv_file_dlFdSchedData_numOfPrb(file_path, filter_name_1, filter_name_2, filter_name_3, mode="r"):
    with open(file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        counter = 0
        required_data_list = []
        required_lowprb_data_list = []  # lower 4 prb list
        second_value = 0  # lower 4 prb counter
        for data in csv_data:
            if data[filter_name_1] == str(filter_name_2) and data['dlFdSchedData.laMode'] != '':
                required_data_list.append(float(data[filter_name_3]))
                counter += 1
        print(counter)
        length = len(required_data_list)
        if length > 0:
            for data in required_data_list:
                if data >= 4 and counter > 0:
                    assert True
                else:
                    second_value += 1
                    required_lowprb_data_list.append(float(data))
            lengthlow_prb = len(required_lowprb_data_list)
            if lengthlow_prb/length > 0.05:  # 5%
                print("required_lowprb_data_list is:", required_lowprb_data_list)
                assert False, f"value numOfPrb lowPRB {lengthlow_prb}>expect value total {length} PRB value 5%"
            else:
                print("lengthlow_prb num is:", lengthlow_prb)
        else:
            assert False, f"No any numOfPrb value in TTI log"
    return required_data_list


def get_value_numOfPrb_priorityIndex(file_path, filter_name_1, filter_name_2, filter_name_3, filter_name_4, mode="r"):
    with (open(file_path, mode) as csv_file):
        csv_data = csv.DictReader(f=csv_file)
        counter = 0
        required_data_list = []
        required_last_data_list = []
        for data in csv_data:
            if data[filter_name_1] == str(filter_name_2) and data['dlFdSchedData.laMode'] != '' \
                    and filter_name_4 != 'P09_DLMACCE' and filter_name_4 != 'P12_SRB2TRAFFIC':
                required_data_list.append(float(data[filter_name_3]))
                # print(required_data_list)
                counter += 1
        print(counter)
        length = len(required_data_list)
        if length > 0:
            for data in required_data_list:
                if data < 4 and counter > 0:
                    required_last_data_list.append(data)
            assert len(required_last_data_list) > 0, "列表长度为0"
            assert required_last_data_list, "列表中没有小于4的元素"
        else:
            assert False, f"No any numOfPrb value in TTI log"
    return required_last_data_list


def dynamic_rule_submit(imsi, rule):
    url = 'https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/ncp_api_update_device'
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJwejRfaHozIiwiZW1haWwiOiJtaW5'
                         'nLnNoaUBub2tpYS1zYmVsbC5jb20iLCJkaXNwbGF5bmFtZSI6IlB6NCBIejMiLCJuc25jaXR5IjoiSGFuZ3'
                         'pob3UiLCJyb2xlcyI6WyJwejRfaHozX2F1dG9tYXRpb24iXSwiZXhwIjoyMDEzNDAxMTk3LjAwNzE4OH0.R'
                         'HAz-svYO1k5byDdHI6ECT_0RG_J7pXc8ZmNyZh25QzkddRBJZcEP1HkuhPrkpisH9ED8hH9aCBSYLC5B0Yd'
                         'edKqx2NIbaW1SHyaey8GpdZDE-XVL2Z2OSY5jEvkWPTbHxu4ldvld_MESZuxtQ5kNeoHghuo-DbY8hSAQi-c'
                         'yT-EPgDJCEcBt4O903Rka3TQ-f_hOxkwrjqMtIjT1yfF4oEfxnqQRRGyqk-_Rzyu9A_1vg5PSsgMzYR6t-bnj'
                         'FOrv9gHMVYaeBiCjlY1CX8idpgcUfV24jvwTPrzLONF3hiYG1_bxcxwS5EAGlCh-JpRoFH1NoQEmRHvn73Uz9Q7QA'
    }
    data = {
        'imsi': imsi,
        'rule_name': rule
    }
    response = requests.post(url=url, headers=headers, data=data, verify=False)
    print(response.text)
    result = json.loads(response.text)
    if response.status_code == 200:
        # msg = result['msg']['responseStatus']['message']
        msg = result['msg']
    elif response.status_code == 500:
        msg = result['msg']
    return response.status_code, msg


def get_C03_value_numOfPrb_priorityIndex(file_path, filter_name_1, filter_name_2, filter_name_3,
                                         filter_name_4, mode="r"):
    with (open(file_path, mode) as csv_file):
        csv_data = csv.DictReader(f=csv_file)
        counter = 0
        required_data_list = []
        required_last_data_list = []
        for data in csv_data:
            if data[filter_name_1] == str(filter_name_2) and data['dlFdSchedData.laMode'] != '' \
                    and filter_name_4 != 'P09_DLMACCE' and filter_name_4 != 'P12_SRB2TRAFFIC':
                required_data_list.append(float(data[filter_name_3]))
                # print(required_data_list)
                counter += 1
        print(counter)
        length = len(required_data_list)
        if length > 0:
            for data in required_data_list:
                if data >= 4 and counter > 0:
                    required_last_data_list.append(data)
                if data < 4 and counter > 0:
                    assert False, "列表中有小于4的元素"
            assert len(required_last_data_list) > 0, "列表长度为0"
        else:
            assert False, f"No any numOfPrb value in TTI log"
    return required_last_data_list
