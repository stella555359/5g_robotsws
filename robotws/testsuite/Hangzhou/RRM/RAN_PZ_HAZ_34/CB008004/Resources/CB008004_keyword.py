# -*- coding: utf-8 -*
import linecache
from robot.libraries.BuiltIn import BuiltIn
import xml.dom.minidom
import logging
import csv
import types
import math
import re
import os
import random


def Generate_random_number(start, stop, step):
    if step == 1:
        round_number = random.randrange(start, stop, 1)
    else:
        ran_index = random.randrange(start, stop, 1)
        round_number = ran_index * step
    random_num_str = str(round_number)
    return random_num_str


def calculate_alpha_beta(frameStartOffset, sfnOffset, timingAdvanceOffset):
    alpha_DL = round(float(frameStartOffset) * 1228.8)
    beta_DL = int(sfnOffset)
    nTaOffset = 1.2288 * 10**9 * float(timingAdvanceOffset) / (480 * 10**3 * 4096)
    alpha_UL = round(float(frameStartOffset) * 1228.8 - nTaOffset) % 12288000
    beta_UL_raw = math.floor((float(frameStartOffset) * 1228.8 + float(sfnOffset) * 12288000 - nTaOffset)/12288000)
    beta_UL = (beta_UL_raw + 32768) % 65536 - 32768
    alpha_beta_list_calculated = [alpha_DL, beta_DL, alpha_UL, beta_UL]
    return alpha_beta_list_calculated


def find_value_of_parameter(para_list, file_path):
    para_value_list = []
    para_line_list = []
    for file_name in os.listdir(file_path):
        if file_name.startswith('SYSLOG'):
            file = os.path.join(file_path, file_name)
    print(file)
    file_content = open(file, 'r')
    file_list = [line for line in file_content.readlines()]
    for para in para_list:
        for line in file_list:
            if para in line:
                para_line_list.append(line.strip('\n').split('=')[0])
    for para in para_list:
        for line in para_line_list:
            if para+'{' in line:
                para_value = re.findall(para+'{(.*)}', line)
                para_value_list.append(int(para_value[0]))
                continue
    print(para_list)
    print(para_value_list)
    file_content.close()
    return para_value_list


def find_all_value_of_parameter(para_list, file_path):
    para_value_dict = {}
    para_line_list = []
    file_list = []
    file_path_list = [os.path.join(file_path, file_name) for file_name in os.listdir(file_path)
                      if file_name.startswith('SYSLOG')]
    print(file_path_list)
    for file in file_path_list:
        file_content = open(file, 'r')
        file_list_tmp = [line for line in file_content.readlines()]
        file_list = file_list + file_list_tmp
        file_content.close()
    for para in para_list:
        for line in file_list:
            if para in line:
                para_line_list.append(line.strip('\n').split('=')[0])
    for para in para_list:
        para_value_dict[para] = []
        for line in para_line_list:
            if para+'{' in line:
                para_value = re.findall(para+'{(.*)}', line)
                para_value_dict[para].append(int(para_value[0]))
    print(para_list)
    print(para_value_dict)
    return para_value_dict
