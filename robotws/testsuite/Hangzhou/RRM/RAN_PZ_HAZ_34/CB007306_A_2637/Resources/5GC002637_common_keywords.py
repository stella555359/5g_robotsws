# -*- coding: utf-8 -*
import re
import os
import linecache
from robot.libraries.BuiltIn import BuiltIn
import xml.dom.minidom
import logging
import csv
import types


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


def Check_UE_Release_Info_From_X2_log(file_path):
    with open(file_path, 'r') as file:
        for line in file.readlines():
            if 'SgNBReleaseRequest' in line:
                return False


def calculate_tput_from_file(tput_file):
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
            logging.info("Tput sum up value is {}, total durataion is {}s, average tput is {}".
                         format(tput_sum, tput_duration, average_tput))

    except IOError as err:
        raise IOError("File Error: {}".format(err))
    else:
        f.close()
    return average_tput


def classify_tput_files_into_file_groups(tput_file_list):
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


def Calculate_average_max_min(input_list, list_length):
    sum_value = 0
    convert_list_tmp = [float(i) for i in input_list if i != '']
    convert_list = list(reversed(convert_list_tmp))[0:list_length]
    for j in convert_list:
        sum_value = sum_value + float(j)
    average_value = sum_value/len(convert_list)
    max_vlaue = max(convert_list)
    min_value = min(convert_list)
    value_list = [average_value, max_vlaue, min_value, sum_value]
    return value_list


def Get_UE_TP_Bler_From_spark_log(file_path, list_length, row_list):
    DL_tp = []
    UL_tp = []
    DL_bler = []
    UL_bler = []
    with open(file_path, 'r', encoding='gbk') as csvfile:
        data = csv.DictReader(csvfile)
        for row in data:
            DL_tp.append(row[row_list[0]])
            UL_tp.append(row[row_list[1]])
            DL_bler.append(row[row_list[2]])
            UL_bler.append(row[row_list[3]])
    message_dict = {
        'DL_tp': Calculate_average_max_min(DL_tp, list_length),
        'UL_tp': Calculate_average_max_min(UL_tp, list_length),
        'DL_bler': Calculate_average_max_min(DL_bler, list_length),
        'UL_bler': Calculate_average_max_min(UL_bler, list_length)}
    return message_dict


def Caculate_total_tp(total_message_dict):
    total_tp_dict = {'dl': [0, 0, 0, 0], 'ul': [0, 0, 0, 0]}
    for i in range(len(total_message_dict)):
        message_dict = total_message_dict[i]
        total_tp_dict['dl'][0] = message_dict['DL_tp'][0] + total_tp_dict['dl'][0]
        total_tp_dict['dl'][1] = message_dict['DL_tp'][1] + total_tp_dict['dl'][1]
        total_tp_dict['dl'][2] = message_dict['DL_tp'][2] + total_tp_dict['dl'][2]
        total_tp_dict['dl'][3] = message_dict['DL_tp'][3] + total_tp_dict['dl'][3]
        total_tp_dict['ul'][0] = message_dict['UL_tp'][0] + total_tp_dict['ul'][0]
        total_tp_dict['ul'][1] = message_dict['UL_tp'][1] + total_tp_dict['ul'][1]
        total_tp_dict['ul'][2] = message_dict['UL_tp'][2] + total_tp_dict['ul'][2]
        total_tp_dict['ul'][3] = message_dict['UL_tp'][3] + total_tp_dict['ul'][3]
    return total_tp_dict


def List_Element_Add_To_Newlist(input_list):
    new_list = []
    for i in range(0, len(input_list[0])):
        new_value = 0
        for j in range(0, len(input_list)):
            new_value = new_value + int(input_list[j][i])
        new_list.append(new_value)
    return new_list


def Caculate_Value_Diff(actual_value, expect_max, expect_min):
    if int(actual_value) < int(expect_max) and int(actual_value) > int(expect_min):
        result = True
    else:
        result = False
    return result


def Caculate_Value_Proportion(actual_value, expect_value, proportion):
    max_value = float(expect_value)*(1 + float(proportion))
    min_value = float(expect_value)*(1 - float(proportion))
    if actual_value < max_value and actual_value > min_value:
        result = True
    else:
        result = False
    print(max_value)
    print(min_value)
    return result


def Caculate_Difference_Value(actual_value, expect_value, expect_diff):
    diff_value = abs(int(actual_value) - int(expect_value))
    if diff_value < expect_diff:
        result = True
    else:
        result = False
    return result


def Caculate_Value_From_Snapshot(file_path):
    all_tp_list = []
    result_list_tmp = []
    file = open(file_path, 'r')
    line_list = [line for line in file.readlines() if 'OutXx:' in line]
    for line in line_list:
        tmp_list = line.split(',')
        for content in tmp_list:
            if 'OutXx:' in content:
                all_tp_list.append(re.findall(r'\d+', content)[0])
    print(all_tp_list)
    diff_index = [i + 1 for i in range(0, len(all_tp_list) - 1) if all_tp_list[i] != all_tp_list[i + 1]]
    diff_index.insert(0, 0)
    diff_index.append(len(all_tp_list))
    for i in range(0, len(diff_index) - 1):
        tmp_list = all_tp_list[diff_index[i]: diff_index[i + 1]]
        result_list_tmp.append(tmp_list)
    result_list = [sub_list for sub_list in result_list_tmp if len(sub_list) > 7]
    print(result_list)
    actual_diff = int(result_list[-1][0]) - int(result_list[-2][0])
    return actual_diff


def Get_Dir_Path(file_path):
    dir_name, suffix = os.path.splitext(file_path)
    return dir_name
