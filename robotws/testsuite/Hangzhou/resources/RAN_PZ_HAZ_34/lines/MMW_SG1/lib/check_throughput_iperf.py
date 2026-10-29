# -*- coding: utf-8 -*-
"""
Author: Cui Lingxue
Contacts: lingxue.cui@nokia-sbell.com
"""

import logging
from robot.libraries.BuiltIn import BuiltIn


def calculate_tput_from_file(tput_file):
    """
    Author: Cui Lingxue
    Description: read throughput data from input file, calculate average throughput during the elapse time.
                 Throughput will be convert to Mbits/sec.
    :param tput_file: file contain throughput checking data via iperf.
    :return: average throughput value in Mbits/sec.
    """
    dict_tput = {}
    try:
        with open(tput_file) as f:
            lines = f.readlines()
            lines = lines[7:]

            for line in lines:
                if line != lines[-1]:
                    duration = line.split("sec")[0].split("]")[-1].strip()
                    if "Mbits/sec" in line:
                        tput_value = line.split("Mbits/sec")[0].split("Bytes")[-1]
                        dict_tput.update({duration + 's': float(tput_value)})
                    elif "Kbits/sec" in line:
                        tput_value = round(float(line.split("Kbits/sec")[0].split("Bytes")[-1])/1024, 2)
                        dict_tput.update({duration + 's': float(tput_value)})
                    elif "Gbits/sec" in line:
                        tput_value = round(float(line.split("Kbits/sec")[0].split("Bytes")[-1])*1024, 2)
                        dict_tput.update({duration + 's': float(tput_value)})
                    else:
                        pass
                else:
                    logging.info("Skip last line in file in case the captured log is incomplete.")
            logging.info("tput record in file {} is: {}".format(tput_file, dict_tput))

            tput_values = dict_tput.values()
            tput_sum = sum(tput_values)
            tput_duration = len(tput_values)
            if tput_duration == 0:
                raise Exception("Tput_duration is 0, means no tput record in tput file, please check file {}".
                                format(tput_file))
            average_tput = round(tput_sum/tput_duration, 2)
            logging.info("Tput sum up value is {}Mbits, total duration is {}s, average tput is {}Mbits/sec".
                         format(tput_sum, tput_duration, average_tput))

    except IOError as err:
        raise IOError("File Error: {}".format(err))
    else:
        f.close()
    return average_tput


def classify_tput_files_into_file_groups(tput_file_list):
    """
    Author: Cui Lingxue
    Description: classify tput files into different groups, group is identified by ue_id + direction.
                 ue_id and direction are read from file name.
       For example, ['TPUT_UE1_DL_port41801_20210204141527',  --> {'UE1_DL': ['TPUT_UE1_DL_port41801_20210204141527',
                     'TPUT_UE1_DL_port46801_20210204141528',                  'TPUT_UE1_DL_port46801_20210204141528',
                     'TPUT_UE1_DL_port47801_20210204141529',                  'TPUT_UE1_DL_port47801_20210204141529'],
                     'TPUT_UE2_DL_port59801_20210204141603',       'UE2_DL': ['TPUT_UE2_DL_port59801_20210204141603',
                     'TPUT_UE2_DL_port55801_20210204141604',                  'TPUT_UE2_DL_port55801_20210204141604',
                     'TPUT_UE2_DL_port50801_20210204141604']                  'TPUT_UE2_DL_port50801_20210204141604']}
    :param tput_file_list: a list of tput files.
    :return: a dict with classified tput files.
    """
    file_group_list = []
    for file in tput_file_list:
        file_name = file.split('/')[-1]
        ue_id = file_name.split('_')[1]
        direction = file_name.split('_')[2]
        group_info = ue_id + '_' + direction
        file_group_list.append(group_info)
    remove_dup = []
    for item in file_group_list:
        if item not in remove_dup:
            remove_dup.append(item)
    file_group_list = remove_dup
    file_group_dict = {}
    for group_info in file_group_list:
        group_tput_files = []
        temp_dict = {group_info: group_tput_files}
        file_group_dict.update(temp_dict)
    for file in tput_file_list:
        file_name = file.split('/')[-1]
        for group in file_group_list:
            if group in file_name:
                file_group_dict[group].append(file)
    return file_group_dict


def calculate_tput_for_file_groups(file_group_dict):
    """
    Author: Cui Lingxue
    Description: read throughput data from given tput files, calculate average tput for each port and total tput.
    ...    example: {'UE1_UL': {'port71824': 23.6, 'total': 23.6}, 'UE1_DL': {'port71825': 129.93, 'total': 129.93}}
    :param file_group_dict: files contain throughput checking data via iperf.
    :return: average throughput value in Mbits/sec.
    """
    file_group_list = file_group_dict.keys()
    tput_group_dict = {}
    for group in file_group_list:
        group_files = file_group_dict[group]
        total_tput = 0
        group_tput = {}
        for file in group_files:
            port = file.split('/')[-1].split('_')[3]
            try:
                average_tput = calculate_tput_from_file(tput_file=file)
            except Exception:
                average_tput = 'null'
            singal_drb_tput = {port: average_tput}
            group_tput.update(singal_drb_tput)
            if isinstance(average_tput, float):
                total_tput = round(total_tput + average_tput, 2)
        total_drb_tput = {'total': total_tput}
        group_tput.update(total_drb_tput)
        tput_group_dict[group] = group_tput
    return tput_group_dict
