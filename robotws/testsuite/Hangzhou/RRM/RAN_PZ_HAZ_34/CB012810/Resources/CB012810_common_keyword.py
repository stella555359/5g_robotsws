# *-coding=utf-8-*

# Name: Ming Shi
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


def get_GrantType_value(csv_file, filter_name):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_GrantType: list of all values under col filter name
    """
    col_data_GrantType = []
    with open(csv_file) as f:
        reader = csv.DictReader(f)
        origin_col_data = [row[filter_name] for row in reader]
        col_data = origin_col_data
        for element in col_data:
            if element:
                col_data_GrantType.append(element)
    print(col_data_GrantType)
    return col_data_GrantType


def get_rrmBufferedDataUl_value(csv_file, target_filter, key_filter, grant_type):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv rrmBufferedDataUlTotal value
    """
    with open(csv_file, 'r') as f:
        rrmBufferedDataUl_data = []
        reader = csv.DictReader(f)
        for row in reader:
            if row[key_filter] == grant_type:
                rrmBufferedDataUl_data.append(row[target_filter])
    return rrmBufferedDataUl_data


def get_SFN_value(csv_file, target_filter, key_filter, grant_type, slot_num):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv rrmBufferedDataUlTotal value
    """
    with open(csv_file, 'r') as f:
        SFN_data = []
        reader = csv.DictReader(f)
        for row in reader:
            if row[key_filter] == grant_type and row['slot'] == slot_num:
                SFN_data.append(row[target_filter])
    return SFN_data
