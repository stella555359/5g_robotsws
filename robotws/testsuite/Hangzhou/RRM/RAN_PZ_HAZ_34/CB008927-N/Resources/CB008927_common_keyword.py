# -*- coding: utf-8 -*

"""
Author:         Hongyu.Jiang
Contact Mail:   hongyu.jiang@nokia-sbell.com
"""
import os
import sys
import csv
import re
import linecache
import xml.etree.ElementTree as ET
from taf.analyzer.pdml import PdmlReader


def Get_packet_info(file_path, field_name):
    field_value_list = []
    with open(file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            if field_name in entry.packet:
                value = entry.packet[field_name].show
                field_value_list.append(value)
    return field_value_list


def Check_the_list_contains_zero_or_non_zero(value_list, check_value):
    """
    :param value_list:
    :param check_value: if check_value is 2, means value_list should content 0 and non 0
                        if check_value is 1, means value_list should only content non 0
                        if check_value is 0, means value_list should only content 0
    :return:
    """
    result = False
    list1 = []
    list2 = []
    for i in value_list:
        if str(i) == "0":
            list1.append(i)
        else:
            list2.append(i)
    if check_value == str(2):
        if len(list1) != 0 and len(list2) != 0:
            result = True
    elif check_value == str(1):
        if len(list1) == 0 and len(list2) != 0:
            result = True
    else:
        if len(list1) != 0 and len(list2) == 0:
            result = True
    return result


def Remove_the_previous_counter(befor_counter, after_counter):
    for key in befor_counter.keys():
        if key in after_counter.keys():
            del after_counter[key]
    print(after_counter)
    key_list = list(after_counter.keys())
    key_list.sort()
    value_list = [after_counter[key] for key in key_list]
    return value_list


def Case8_Count_counter_value(befor_counter, after_counter):
    value_list = Remove_the_previous_counter(befor_counter=befor_counter, after_counter=after_counter)
    max_value = max(value_list)
    return max_value


def Case7_Count_counter_value(befor_counter_list, after_counter_list):
    all_counter_value_list = []
    for i in range(0, len(befor_counter_list)):
        print(befor_counter_list[i])
        print(after_counter_list[i])
        value_list = Remove_the_previous_counter(befor_counter=befor_counter_list[i],
                                                 after_counter=after_counter_list[i])
        all_counter_value_list.append(value_list)
    return all_counter_value_list


def Analysize_Tcpdump_By_Frame(file_path):
    line_index = -1
    file_list = []
    frame_content_list = []
    frame_line_index_list = []
    with open(file_path, 'r') as file_obj:
        for line in file_obj:
            file_list.append(line)
            line_index += 1
            if line.startswith("Frame "):
                frame_line_index_list.append(line_index)
    frame_line_index_list.append(line_index)
    for i in range(0, len(frame_line_index_list) - 1):
        tmp_list = file_list[frame_line_index_list[i]:frame_line_index_list[i + 1]]
        frame_content_list.append(tmp_list)
    return frame_content_list


def Get_Field_Value_From_Frame_Content(file_path, field_list):
    """
    :param frame_content_list:
    :param field_list:It is necessary to search strictly according to the hierarchical directory,
    and reurn the value of field_list[-1]
    :return:
    """
    frame_content_list = Analysize_Tcpdump_By_Frame(file_path=file_path)
    all_field_content_list = []
    all_value_list = []
    for frame_content in frame_content_list:
        content_list = []
        start_index = 0
        for i in range(0, len(field_list) - 1):
            for j in range(start_index, len(frame_content)):
                if frame_content[j].strip(' ').startswith(field_list[i]):
                    start_index = j
                    break
        for k in range(start_index, len(frame_content)):
            if frame_content[k].strip(' ').startswith(field_list[-1]):
                content_list.append(frame_content[k].strip(' ').strip('\n'))
        if len(content_list) > 0:
            all_field_content_list.append(content_list)
    print(all_field_content_list[-1])
    for bwp_Id in all_field_content_list[-1]:
        all_value_list.append(bwp_Id.split(': ')[-1])
    return all_value_list


def Check_list_Only_Contain_one_value(input_list, check_value):
    vaild_list = [i for i in input_list if i == check_value]
    invaild_list = [i for i in input_list if i != check_value]
    return vaild_list, invaild_list


def Check_rat0Bitmap_and_physCellId(input_dict):
    result_list = []
    for physCellId in input_dict.keys():
        rat0Bitmap_list = input_dict[physCellId]
        result = Check_the_list_contains_zero_or_non_zero(value_list=rat0Bitmap_list, check_value='2')
        result_list.append(result)
    return result_list


def Count_the_value_of_one_layers_list(input_list, msc_value, numOfPrb_value1, numOfPrb_value2, ssb_slot=False):
    msc_value_list = [item[0] for item in input_list if item[0] == str(msc_value)]
    if ssb_slot:
        numOfPrb_value_list1 = \
            [item[1] for item in input_list if item[1] == str(numOfPrb_value1) and int(item[2]) % 2 == 0]
        numOfPrb_value_list2 = \
            [item[1] for item in input_list if item[1] == str(numOfPrb_value2) and int(item[2]) % 2 == 0]
    else:
        numOfPrb_value_list1 = [item[1] for item in input_list if item[1] == str(numOfPrb_value1)]
        numOfPrb_value_list2 = [item[1] for item in input_list if item[1] == str(numOfPrb_value2)]
    return msc_value_list, numOfPrb_value_list1, numOfPrb_value_list2


def Modify_RF_version_to_iphy(TargetBD_file, iphy_name, config_path, RF_list):
    iphy_file = os.path.join(config_path, iphy_name)
    new_iphy_name = iphy_name.replace(iphy_name, 'iphy.xml')
    new_iphy_file = os.path.join(config_path, new_iphy_name)
    with open(TargetBD_file, 'r') as file_obj:
        TargetBD_content = file_obj.readlines()
    file_obj.close()
    SWversion = list(set([line.strip('\n').strip('>').split(' ')[-1].split('=')[-1] for
                          line in TargetBD_content if 'resourceSWVersion=' in line]))
    RF_version_list = []
    for RF in RF_list:
        for version in SWversion:
            if RF in version:
                RF_version_list.append(version.strip('\"'))
    print(RF_version_list)
    with open(iphy_file, 'r') as file_obj:
        iphy_content = file_obj.readlines()
    file_obj.close()
    new_iphy_content = []
    for iphy_line in iphy_content:
        version = iphy_line.split('</')[0].split('>')[-1]
        for index in range(0, len(RF_list)):
            if RF_list[index] in iphy_line:
                iphy_line = iphy_line.replace(version, RF_version_list[index])
                print(iphy_line)
        new_iphy_content.append(iphy_line)
    with open(new_iphy_file, 'w') as file_obj:
        file_obj.writelines(new_iphy_content)
    file_obj.close()
    print(new_iphy_file)
    return new_iphy_file


def Get_TargetBD_file_name(input_list):
    for file in input_list:
        if file.startswith('TargetBD_') and file.strip('\r').endswith('.xml'):
            return file.strip('\r')
