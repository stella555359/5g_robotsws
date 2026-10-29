# -*- coding: utf-8 -*
import re
import os
import linecache
from robot.libraries.BuiltIn import BuiltIn
import xml.dom.minidom
import logging
import csv
import types
import math


def Modify_Structure_Value(input_list, new_value, index):
    output_list = []
    if isinstance(input_list, dict):
        input_list = [input_list]
    input_dict = input_list[int(index)]
    for keys in new_value.keys():
        input_dict[keys] = new_value[keys]
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


def Caculate_TargetSinr_Value(a, Pathloss_list, Interference_list):
    TargetSinr_list = []
    for i in range(len(Pathloss_list)):
        TargetSinr_tmp = -96 + 10*math.log((30/15), 10) + 10*math.log(4, 10) \
                         - (1 - float(a))*float(Pathloss_list[i]) - float(Interference_list[i])
        TargetSinr = max(min(TargetSinr_tmp, 30), -10)
        TargetSinr_list.append(TargetSinr)
    return TargetSinr_list


def Caculate_TwoList_DiffValue(list1, list2, Tolerance):
    diff_value_list = []
    for i in range(len(list1)):
        diff_value = abs(float(list1[i]) - float(list2[i]))
        diff_value_list.append(diff_value)
        if diff_value > float(Tolerance):
            raise Exception("Tolerance exceeds maximum")
            return False
    return True


def Check_Pathloss_Status(input_list, expect_diff, flag='add'):
    begin_index = 0
    if flag == 'add':
        tmp_list = [i for i in range(0, len(input_list)) if input_list[i] == 134]
        if len(tmp_list) == 0:
            for i in range(0, len(input_list)):
                if float(input_list[i]) - 80 < 20:
                    begin_index = i
                    break
        else:
            begin_index = tmp_list[-1]
        new_list = [float(i) for i in input_list[begin_index + 1:]]
        diff = new_list[-1] - new_list[0]
    else:
        new_list = [float(i) for i in input_list]
        diff = new_list[0] - new_list[-1]
    print(diff)
    if diff < float(expect_diff):
        print("Pathloss is not right!")
        return False
    return True


def Check_list_Value_Trend(add_list, reduce_list, add_tolerance, reduce_tolerance):
    add_unexpect_list = [i for i in add_list if i < 0]
    reduce_unexpect_list = [i for i in reduce_list if i > 0]
    for i in add_unexpect_list:
        if i < -2:
            raise Exception("Added data exception!")
            return False
    for j in reduce_unexpect_list:
        if j > 2:
            raise Exception("Reduce data exception!")
            return False
    add_unexpect_tolerance = float(len(add_unexpect_list)/len(add_list))
    reduce_unexpect_tolerance = float(len(reduce_unexpect_list)/len(reduce_list))
    print("Add unexpect tolerance is:", add_unexpect_tolerance)
    print("Reduce unexpect tolerance is:", reduce_unexpect_tolerance)
    if add_unexpect_tolerance > float(add_tolerance) or reduce_unexpect_tolerance > float(reduce_tolerance):
        raise Exception("Abnormal data exceeds the maximum tolerance!")
        return False
    return True


def Check_TPCcommand_Value(TargetSinr_list, AvgSinr_list, TPC_value_list):
    deltasinr_list = []
    expect_TPC_list = []
    for i in range(0, len(TargetSinr_list)):
        tmp_value = float(TargetSinr_list[i]) - float(AvgSinr_list[i])
        deltasinr_list.append(tmp_value)
    for deltasinr in deltasinr_list:
        if deltasinr < -2:
            expect_TPC_list.append('0')
        elif deltasinr > -2 and deltasinr < 0:
            expect_TPC_list.append('1')
        elif deltasinr > 0 and deltasinr < 1:
            expect_TPC_list.append('2')
        elif deltasinr > 1:
            expect_TPC_list.append('3')
    for j in range(0, len(TPC_value_list)):
        if expect_TPC_list[i] != TPC_value_list[i]:
            print("error line is:", i)
            return False
    return True


def Check_TPCcommand_Trend(TPC_value_list, tolerance, flag='add'):
    begin_index = 0
    end_index = len(TPC_value_list)
    if flag == 'add':
        tmp_list = [i for i in range(0, len(TPC_value_list)) if
                    int(TPC_value_list[i]) == 2 or int(TPC_value_list[i]) == 3]
        end_index = tmp_list[-1]
        for i in range(0, len(TPC_value_list) - 1):
            if (int(TPC_value_list[i]) == 2 or int(TPC_value_list[i]) == 3) and \
                    (int(TPC_value_list[i + 1]) == 2 or int(TPC_value_list[i + 1]) == 3):
                begin_index = i
                break
        print(begin_index)
    else:
        for i in range(0, len(TPC_value_list) - 1):
            if (int(TPC_value_list[i]) == 0) and (int(TPC_value_list[i + 1]) == 0):
                begin_index = i
                break
    new_list = [int(i) for i in TPC_value_list[begin_index: end_index]]
    add_list = [i for i in new_list if i == 2 or i == 3]
    reduce_list = [i for i in new_list if i == 0]
    unexpect_list = [i for i in new_list if i == 1]
    if len(unexpect_list) != 0:
        print('TPC value appear 1')
        return False
    if flag.lower() == 'add':
        actual_tolerance = float(len(add_list))/float(len(new_list))
    else:
        actual_tolerance = float(len(reduce_list))/float(len(new_list))
    print(actual_tolerance)
    if actual_tolerance < float(tolerance):
        print('Maximum tolerance exceeded !')
        return False
    return True


def Check_LaPhr_Sfn_cycle(LaPhr_list, tolerance):
    new_list = [int(i) for i in LaPhr_list]
    LaPhr_diff_list = [(new_list[i] - new_list[i - 1]) for i in range(1, len(new_list))]
    print(len(LaPhr_diff_list))
    unexcept_list = [j for j in LaPhr_diff_list if j != 2 and j != -1022]
    print(len(unexcept_list))
    Proportion = float(len(unexcept_list))/float(len(LaPhr_diff_list))
    print(Proportion)
    if Proportion < float(tolerance):
        return True
    return False
