# -*- coding: utf-8 -*
import re
import os
import linecache
from robot.libraries.BuiltIn import BuiltIn
import xml.dom.minidom
import logging
import csv
import sys


def Modify_Structure_Value(input_list, new_value, index):
    output_list = []
    input_list_tmp = []
    if isinstance(input_list, list) is False:
        input_list_tmp.append(input_list)
        input_dict = input_list_tmp[int(index)]
    else:
        input_dict = input_list[int(index)]
    for keys in new_value[int(index)].keys():
        input_dict[keys] = new_value[int(index)][keys]
    for keys in input_dict.keys():
        if input_dict[keys] is None:
            del input_dict[keys]
    output_list.append(input_dict)
    return output_list


def Return_Structure_Mofify_Value(input_list, modify_list, keywords_list, index):
    output_dict_list = []
    for i in range(len(keywords_list)):
        for item_dict in input_list:
            if keywords_list[i] == item_dict['distName'].split('/')[-1]:
                output_dict = {}
                parameters_value = item_dict['parameters']
                modify_parameter = modify_list[i]['parameter']
                structure_value = parameters_value[modify_parameter]
                new_value = modify_list[i]['value']
                output_list = Modify_Structure_Value(structure_value, new_value, index)
                output_dict['dist_name'] = modify_list[i]['dist_name']
                output_dict['parameter'] = modify_list[i]['parameter']
                output_dict['value'] = output_list
                output_dict_list.append(output_dict)
    return output_dict_list


# ssb slot ###
def Check_sfn_even_numbers_slot(sfn_list, slot_list):
    sfn_list_tmp = []
    slot_list_tmp = []
    for i in range(0, len(sfn_list)):
        if int(sfn_list[i]) % 2 == 0:
            sfn_list_tmp.append(int(sfn_list[i]))
            slot_list_tmp.append(int(slot_list[i]))
    for j in slot_list_tmp:
        if j == 0:
            print("The value of slot 0 appears in even sfn")
            return False
    return True


# trs slot ###
def Check_sfn_Dividing_eight_slot(sfn_list, slot_list):
    sfn_list_tmp = []
    slot_list_tmp = []
    for i in range(0, len(sfn_list)):
        if int(sfn_list[i]) % 8 == 0:
            sfn_list_tmp.append(int(sfn_list[i]))
            slot_list_tmp.append(int(slot_list[i]))
    for j in slot_list_tmp:
        if j == 1:
            print("The value of slot 1 appears in Dividing eight sfn")
            return False
    return True


def Check_Two_Rnti_Prb_Sum(sfn_list, slot_list, rnti_list, prb_list, expect_vaule):
    rnti_value = {}
    sum_prb_list = []
    for i in range(0, len(rnti_list)):
        if rnti_list[i] not in rnti_value.keys():
            rnti_value[rnti_list[i]] = []
        tmp_list = [sfn_list[i], slot_list[i], prb_list[i]]
        rnti_value[rnti_list[i]].append(tmp_list)
    key_list = [key for key in rnti_value.keys()]
    print(key_list)
    key_value1 = rnti_value[key_list[0]]
    key_value2 = rnti_value[key_list[1]]
    for line_list1 in key_value1:
        for line_list2 in key_value2:
            if (line_list1[0] == line_list2[0]) and (line_list1[1] == line_list2[1]):
                sum_prb_list.append(line_list1[2] + line_list2[2])
    print(sum_prb_list)
    for m in sum_prb_list:
        if m >= int(expect_vaule):
            return True
    return False


def Check_msc_list(msc_list, expect_value):
    for i in msc_list:
        if i == expect_value:
            return True
    print("The value of msc is not right!")
    return False


def Check_Wireshark_Attach_PCI_From_Txt(txt_path, expect_value, parameters=[]):
    txt_file = open(txt_path, 'r')
    txt_lines = [line for line in txt_file.readlines()]
    txt_file.close()
    frame_index_list = [txt_lines.index(i) for i in txt_lines if i.startswith('Frame ')]
    frame_content_list = []
    physCellId_list = []
    for i in range(0, len(frame_index_list) - 1):
        frame_content = [i.strip('\n').strip(' ') for i in txt_lines[frame_index_list[i]: frame_index_list[i+1]]]
        frame_content_list.append(frame_content)
    frame_content_list.append([i.strip('\n').strip(' ') for i in txt_lines[frame_index_list[-1]: -1]])
    for frame_content in frame_content_list:
        if set(parameters).issubset(frame_content):
            for j in frame_content:
                if j.startswith('physCellId'):
                    physCellId_list.append(j)
    print(physCellId_list)
    if int(physCellId_list[0].split(':')[-1].strip(' ')) == int(expect_value):
        return True
    return False
