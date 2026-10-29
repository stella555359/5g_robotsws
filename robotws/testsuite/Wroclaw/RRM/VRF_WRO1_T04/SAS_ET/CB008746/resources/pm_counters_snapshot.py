# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import datetime
import shutil
import glob
import re
import os
from mergedeep import merge

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    create_dir, unzip_file, copy_files_from_local_to_local, save_json_file
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console


def create_dir_at_tc_output(dir_name):
    tc_path = BuiltIn().get_variable_value('${OUTPUT_DIR_TC}')
    return create_dir(dir_name, tc_path)


def unpack_snapshot():
    tc_path = BuiltIn().get_variable_value('${OUTPUT_DIR_TC}')
    dir_path = create_dir_at_tc_output('SNAPSHOT')
    snapshot_file = glob.glob('{}/snapshot_8746_*'.format(tc_path))
    unzip_file(snapshot_file[0], dir_path)
    file_name = get_zip_with_pm_stats_from_snapshot_list(dir_path)
    file_path = '{}/{}'.format(dir_path, file_name)
    counters_dir = create_dir('counters', dir_path)
    unzip_file(file_path, dir_path)
    counter_file_list = glob.glob('{}/*PM.BTS*'.format(dir_path))
    for pm_stat in counter_file_list:
        try:
            unzip_file(pm_stat, counters_dir)
        except OSError:
            copy_files_from_local_to_local(pm_stat, counters_dir)
    return counters_dir


def parse_xml_files():
    dir_path = unpack_snapshot()
    dir_list = [os.path.join(dir_path, xml_file) for xml_file in os.listdir(dir_path)]
    all_counters = dict()
    for xml in dir_list:
        get_counters_values_from_file(xml, all_counters)
    return all_counters, dir_path


def get_counter_dict(counter_name, all_counters):
    dict_list = list()
    mo_objects = all_counters[counter_name].keys()
    for mos in mo_objects:
        values = all_counters[counter_name][mos]
        counter_dict = {counter_name: values}
        for mo in reversed(mos):
            counter_dict = {mo: counter_dict}
        dict_list.append(counter_dict)
    dict_tuple = tuple(dict_list)
    full_counter_dict = dict()
    merge(full_counter_dict, *dict_tuple)
    dir_path = create_dir_at_tc_output('counters')
    save_counter_to_json(counter_name, full_counter_dict, dir_path)


def get_counters_and_save_to_json(counters_list):
    logger_console(counters_list)
    all_counters, dir_path = parse_xml_files()
    for counter in counters_list:
        get_counter_dict(counter, all_counters)
    shutil.rmtree('/'.join(dir_path.split('/')[:-1]))


def save_counter_to_json(counter_name, counter_dict, dir_path):
    file_name = '{}/{}.json'.format(dir_path, counter_name)
    save_json_file(file_name, counter_dict)


def get_counters_values_from_file(file_path, all_counters):
    network_element = False
    new_mo = False
    re_counters = r'(M\d+C\d+)>(\d+)<\/M\d+C\d+'
    with open(file_path, 'r') as xml_file:
        xml = xml_file.read().split('><')
        for mark in xml:
            if 'PMSetup startTime' in mark:
                human, epoch = parse_datatime(mark)
            if network_element is True:
                network_element = False
                mo_element_list = mark.replace('<', '').split('/')[1:-1]
            if new_mo is True:
                new_mo = False
                mo_element_list.append(mark.replace('<', '').split('/')[1])
                logger_console(mark.replace('<', '').split('/')[1])
            if 'network_element' in mark:
                network_element = True
            if 'NR_Resource_Group_Id' in mark:
                new_mo = True
            if 'measurementType' in mark:
                mes_type = mark.split('=')[-1][1:-1]
                mo_element_list.append(mes_type)
                mo_element_tuple = tuple(mo_element_list)
            if re.search(re_counters, mark):
                matched = re.search(re_counters, mark)
                counter = matched.group(1)
                value = matched.group(2)
                counter_dict = {mo_element_tuple: {str(epoch): int(value)}}
                if counter in all_counters:
                    if mo_element_tuple in all_counters[counter]:
                        all_counters[counter][mo_element_tuple].update({str(epoch): int(value)})
                    else:
                        all_counters[counter].update(counter_dict)
                else:
                    all_counters.update({counter: counter_dict})


def parse_datatime(match):
    mark = match.split('\"')[1]
    datatime_regex = r'(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+).*'
    re_obj = re.search(datatime_regex, mark)
    data_t = (int(re_obj.group(3)), int(re_obj.group(2)), int(re_obj.group(1)))
    time_t = (int(re_obj.group(4)), int(re_obj.group(5)), int(re_obj.group(6)))
    datatime = '{0[0]}{0[1]}{0[2]}_{1[0]}{1[1]}{1[2]}'.format(data_t, time_t)
    data = list(data_t)
    data.reverse()
    epoch_time = int(datetime.datetime(*tuple(data), *time_t).timestamp())
    return datatime, epoch_time


def get_zip_with_pm_stats_from_snapshot_list(dir_path):
    with open('{}/snapshot_file_list.txt'.format(dir_path), 'r') as file_list:
        snap_content = file_list.read()
        matches = re.split(r'BTS\d+\w+part_\d+\.zip:', snap_content)
        findall = re.findall(r'BTS\d+\w+part_\d+\.zip:', snap_content)
        files = dict(zip(findall, matches[1:]))
        for file_name, content in files.items():
            if 'PM.BTS' in content:
                return file_name[:-1]
