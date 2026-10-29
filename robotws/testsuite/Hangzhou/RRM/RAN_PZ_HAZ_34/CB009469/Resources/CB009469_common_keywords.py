# -*- coding: utf-8 -*
import re
import os
import linecache
from robot.libraries.BuiltIn import BuiltIn
import xml.dom.minidom
import logging
import csv
import types


def Sum_all_counter_values(counter_input_dict):
    sum_counter_dict = {}
    for key in counter_input_dict.keys():
        sum_value_list = []
        for sub_list in counter_input_dict[key]:
            sum_value = sum(sub_list)
            sum_value_list.append(sum_value)
        sum_counter_dict[key] = sum_value_list
    return sum_counter_dict


def Calculate_diff_between_the_sum_two_counters(counter_input_dict1, counter_input_dict2):
    sum_counter_dict1 = Sum_all_counter_values(counter_input_dict1)
    sum_counter_dict2 = Sum_all_counter_values(counter_input_dict2)
    counter_diff_dict = {}
    for key in sum_counter_dict1.keys():
        if len(sum_counter_dict1[key]) == 1:
            counter_diff_dict[key] = sum_counter_dict2[key][0] - sum_counter_dict1[key][0]
        else:
            counter_diff_dict[key] = [sum_counter_dict2[key][i] - sum_counter_dict1[key][i]
                                      for i in range(0, len(sum_counter_dict1[key]))]
    return counter_diff_dict


def Check_counter_value_as_expect(actual_value_dict, attach_counter_dict, tp_time_counter_dict, Toler):
    for key in attach_counter_dict.keys():
        diff_value = attach_counter_dict[key] - actual_value_dict[key]
        if diff_value != 0:
            print("actual attach times is: ", actual_value_dict[key])
            print("expect attach times is: ", attach_counter_dict[key])
            return False
    for key in tp_time_counter_dict.keys():
        if isinstance(tp_time_counter_dict[key], int):
            diff_value = tp_time_counter_dict[key] - actual_value_dict[key]
            if abs(diff_value) > int(Toler):
                print("actual Pcell attach time is:", actual_value_dict[key])
                print("expect Pcell attach time is:", tp_time_counter_dict[key])
                return False
        else:
            diff_value_list = [tp_time_counter_dict[key][i] - actual_value_dict[key][i]
                               for i in range(0, len(tp_time_counter_dict[key]))]
            for value in diff_value_list:
                if abs(value) > int(Toler):
                    print("actual Sbcell attach time is: ", actual_value_dict[key])
                    print("expect Sbcell attach time is: ", tp_time_counter_dict[key])
                    return False
    return True


def Get_UL_TP_Start_line(ul_tp_list, cell_id):
    for i in range(0, len(ul_tp_list)):
        if ('nrCellIdentity ' + cell_id) in ul_tp_list[i]:
            for content in ul_tp_list[i].split(':'):
                if 'Bytes received' in content:
                    tp_value = content.split(' ')[1]
                    if int(tp_value) > 131072:
                        return i
    return None


def Get_DL_TP_Start_line(dl_tp_list, cell_id):
    for i in range(0, len(dl_tp_list)):
        if ('nrCellId ' + cell_id) in dl_tp_list[i]:
            tp_value = dl_tp_list[i].split(':')[-1].strip(' ').split('|')[0]
            if int(tp_value) > 131072:
                return i
    return None


def Get_time_Diff_second(start_time_list, end_time_list):
    start_time = start_time_list[0]
    end_time = end_time_list[0]
    time_list1 = [int(i) for i in start_time.split('.')[0].split(':')]
    print(time_list1)
    time_list2 = [int(i) for i in end_time.split('.')[0].split(':')]
    print(time_list2)
    if end_time[0] < start_time[0]:
        time_list2[0] = 24
    time2 = time_list2[0] * 60 * 60 + time_list2[1] * 60 + time_list2[2]
    time1 = time_list1[0] * 60 * 60 + time_list1[1] * 60 + time_list1[2]
    diff = time2 - time1
    return diff


def Generate_Corresponding_expected_counter(check_counter_dict, actual_value_list):
    attach_counter_list = check_counter_dict['attach']
    ul_time_counter_list = check_counter_dict['ul_attach_counter']
    dl_time_counter_list = check_counter_dict['dl_attach_counter']
    ul_scell_counter_id = check_counter_dict['ul_scell_counter']
    dl_scell_counter_id = check_counter_dict['dl_scell_counter']
    attach_counter_dict = {}
    ul_time_counter_dict = {}
    dl_time_counter_dict = {}
    for counter_id in attach_counter_list:
        attach_counter_dict[counter_id] = 1
    for counter_id in ul_time_counter_list:
        ul_time_counter_dict[counter_id] = actual_value_list[0]
    for counter_id in dl_time_counter_list:
        dl_time_counter_dict[counter_id] = actual_value_list[0]
    ul_time_counter_dict[ul_scell_counter_id] = [actual_value_list[0] for i in range(0, 3)]
    dl_time_counter_dict[dl_scell_counter_id] = [actual_value_list[0] for i in range(0, 6)]
    ul_time_counter_dict[check_counter_dict['ul_tp_counter']] = actual_value_list[1]
    dl_time_counter_dict[check_counter_dict['dl_tp_counter']] = actual_value_list[2]
    print(attach_counter_dict, ul_time_counter_dict, dl_time_counter_dict)
    return attach_counter_dict, ul_time_counter_dict, dl_time_counter_dict
