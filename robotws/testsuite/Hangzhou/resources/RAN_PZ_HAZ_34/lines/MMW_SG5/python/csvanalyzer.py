# -*- coding: utf-8 -*-
# @Time    : 2022/2/15 14:40
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : csvanalyzer.py
# @Software: PyCharm
import csv
from statistics import mean
from collections import Counter


def get_all_items_value(file_path):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))

    all_items = []
    for item in reader[1:]:
        cur_item = {}
        for column in range(len(item)):
            cur_item[reader[0][column]] = item[column]
        all_items.append(cur_item)

    return (all_items)


def get_the_special_item_value(file_path, special_item="3gpp.slot", sort_time=False):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))
        new_reader = sorted(reader[1:], key=lambda x: float(x[1]))
        new_reader.insert(0, reader[0])

    item_column = 0
    for item in new_reader[0]:
        if item == special_item:
            break
        item_column += 1

    special_item_value_list = []
    for item in new_reader[1:]:
        if item[item_column]:
            special_item_value_list.append(item[item_column])

    if not sort_time:
        special_item_value_list = list(set(special_item_value_list))
        list.sort(special_item_value_list)

    return special_item_value_list


def get_the_special_item_value_count(file_path, special_item="3gpp.slot", special_item_value=4, sort_time=False):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))
        new_reader = sorted(reader[1:], key=lambda x: x[1])
        new_reader.insert(0, reader[0])

    item_column = 0
    for item in new_reader[0]:
        if item == special_item:
            break
        item_column += 1

    count = 0
    for item in new_reader[1:]:
        if item[item_column] == str(special_item_value):
            count += 1

    return count


def get_the_special_item_value_with_percent(file_path, special_item="3gpp.slot"):
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

    count = Counter(special_item_value_list)
    special_item_value_list_with_percent = []
    for k, v in count.items():
        special_item_value_list_with_percent.append(k)

    return special_item_value_list_with_percent


def get_the_special_item_average_value(file_path, special_item="3gpp.slot"):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))

    item_column = 0
    for item in reader[0]:
        if item == special_item:
            break
        item_column += 1

    special_item_value_list = []
    for item in reader[1:]:
        if item[item_column] == "0":
            special_item_value_list.append(0)
        elif "," in item[item_column]:
            special_item_value_list.append(int(item[item_column].split(",")[1]))
        elif item[item_column] != "":
            special_item_value_list.append(int(item[item_column]))

    special_item_average_value = mean(special_item_value_list)

    return special_item_average_value


def get_the_special_item_row_values(file_path, special_item, item_value):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))

    item_column = 0
    for item in reader[0]:
        if item == special_item:
            break
        item_column += 1

    item_row = 1
    for item in reader[1:]:
        if item[item_column] == item_value:
            break
        item_row += 1

    special_item_values = {}
    for i in range(len(reader[item_row])):
        special_item_values[reader[0][i]] = reader[item_row][i]

    return special_item_values


def get_the_special_item_value_with_preconditon(file_path, special_item="DlData_DciInfo.startCce",
                                                precondition={"3gpp.slot": "5"}):
    all_items = get_all_items_value(file_path)

    special_item_value_list = []
    for item in all_items:
        add_flag = True
        for key in precondition:
            if item[key].strip() != precondition[key]:
                add_flag = False
        if add_flag:
            special_item_value_list.append(item[special_item])

    special_item_value_list = list(set(special_item_value_list))
    list.sort(special_item_value_list)

    return special_item_value_list
