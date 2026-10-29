# -*- coding: utf-8 -*-
# @Time    : 2022/2/15 14:40
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : csvanalyzer.py
# @Software: PyCharm
import csv


def get_all_items_value(file_path):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))

    all_items = []
    for item in reader[1:]:
        cur_item = {}
        for column in range(len(item)):
            cur_item[reader[0][column]] = item[column]
        all_items.append(cur_item)

    return all_items


def get_the_special_item_value(file_path, special_item="3gpp.slot"):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))

    item_column = 0
    for item in reader[0]:
        if item == special_item:
            break
        item_column += 1

    special_item_value_list = []
    for item in reader[1:]:
        special_item_value_list.append(item[item_column])

    special_item_value_list = list(set(special_item_value_list))
    list.sort(special_item_value_list)

    return special_item_value_list


def get_the_special_item_value_with_preconditon(file_path, special_item="DlData_DciInfo.startCce",
                                                precondition={"3gpp.slot": "5"}):
    all_items = get_all_items_value(file_path)

    special_item_value_list = []
    for item in all_items:
        add_flag = True
        for key in precondition:
            if item[key] != precondition[key]:
                add_flag = False
        if add_flag:
            special_item_value_list.append(item[special_item])

    special_item_value_list = list(set(special_item_value_list))
    list.sort(special_item_value_list)

    return special_item_value_list
