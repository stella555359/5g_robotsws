from robot.libraries.BuiltIn import BuiltIn
from bs4 import BeautifulSoup
import re
import csv
import os
import json
import subprocess
import importlib
import sys

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def get_ue_stats_for_given_cc(ue_id, cc, direction):
    if direction == 'dl':
        stats_type = 'pdsch'
    else:
        stats_type = 'pusch'
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type={} scell={}'
                                                                       .format(ue_id, stats_type, cc),
                                                                       pass_regexp='UE-{}: NR {} Throughput'
                                                                       .format(ue_id, stats_type.upper()))


def get_max_data_traffic_for_given_cc(ue_id, cc, direction, unit):
    ue_stats = get_ue_stats_for_given_cc(ue_id, cc, direction)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(ue_stats)[-2][0]
    return float(avg_tput)


def get_max_DlBufBasedDowngradedTbSize(file_path):
    with open(file_path) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        prb_num_list = [int(float(line["dlFdSchedData.DlBufBasedDowngradedTbSize"]))
                        for line in csv_reader
                        if line["dlFdSchedData.DlBufBasedDowngradedTbSize"] != '']
        print(prb_num_list)
        return max(prb_num_list)


def get_max_TbSize(file_path):
    with open(file_path) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        prb_num_list = [int(float(line["dlFdSchedData.tbSize"]))
                        for line in csv_reader
                        if line["dlFdSchedData.tbSize"] != '']
        print(prb_num_list)
        return max(prb_num_list)


def get_max_maxDataVolumeDl(file_path):
    with open(file_path) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        prb_num_list = [int(float(line["dlFdSchedData.maxDataVolumeDl"]))
                        for line in csv_reader
                        if line["dlFdSchedData.maxDataVolumeDl"] != '']
        print(prb_num_list)
        return max(prb_num_list)


def contain_subband(file_path):
    with open(file_path) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for line in csv_reader:
            if line["dlFdSchedData.beamType"] == "SUBBAND":
                return True

    return False
