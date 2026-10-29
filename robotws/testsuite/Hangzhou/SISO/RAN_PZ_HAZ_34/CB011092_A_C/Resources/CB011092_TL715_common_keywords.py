# -*- coding: utf-8 -*
import re
import os
import linecache
from robot.libraries.BuiltIn import BuiltIn
import xml.dom.minidom
import logging
import csv


def Calculate_average_max_min(input_list, list_length):
    sum_value = 0
    convert_list_tmp = [float(i) for i in input_list if i != ""]
    if len(convert_list_tmp) == 0:
        convert_list = [0]
    else:
        convert_list = list(reversed(convert_list_tmp))[0:list_length]
    for j in convert_list:
        sum_value = sum_value + float(j)
    average_value = sum_value / len(convert_list)
    max_vlaue = max(convert_list)
    min_value = min(convert_list)
    value_list = [average_value, max_vlaue, min_value, len(convert_list)]
    return value_list


def Get_UE_TP_From_spark_log(file_path, list_length, row_list):
    DL_tp = []
    UL_tp = []
    with open(file_path, "r", encoding="gbk") as csvfile:
        data = csv.DictReader(csvfile)
        for row in data:
            DL_tp.append(row[row_list[0]])
            UL_tp.append(row[row_list[1]])
    message_dict = {
        "DL_tp": Calculate_average_max_min(DL_tp, list_length),
        "UL_tp": Calculate_average_max_min(UL_tp, list_length),
    }
    return message_dict


def Get_UE_Right_IP(cmd_info):
    ue_ip = "127.0.0.1"
    ue_ip_list = cmd_info.split("\n")
    for ip in ue_ip_list:
        if ip.startswith("172"):
            ue_ip = ip
    return ue_ip


def Check_Cell_Id_Info(cells_info_list, expect_cell_info):
    cell_id_dict = {}
    for single_cell_info in cells_info_list:
        Cell_id = single_cell_info['id']['configuration']
        SubCellList = single_cell_info['subCellList']
        cell_id_dict[Cell_id.split('/')[-1]] = SubCellList
    print(cell_id_dict)
    if len(cell_id_dict.keys()) != len(expect_cell_info.keys()):
        return False
    for cell_id in cell_id_dict.keys():
        for subcell_info in cell_id_dict[cell_id]:
            if subcell_info not in expect_cell_info[cell_id]:
                return False
    return True
