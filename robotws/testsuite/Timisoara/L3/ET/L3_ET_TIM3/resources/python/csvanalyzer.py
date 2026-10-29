# -*- coding: utf-8 -*-
# @Time    : 2022/2/15 14:40
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : csvanalyzer.py
# @Software: PyCharm
# @Updates : Dan Moldovan 20 ian 2023
import csv
from datetime import datetime


def diff_time(start_time, end_time):

    # convert time string to datetime
    t1 = datetime.strptime(start_time[:-5], "%H:%M:%S.%f")
    print('Start time:', t1.time())

    t2 = datetime.strptime(end_time[:-5], "%H:%M:%S.%f")
    print('End time:', t2.time())

    # get difference
    delta = t2 - t1

    # time difference in seconds
    print("Time difference is {delta.total_seconds()} seconds")

    # time difference in milliseconds
    ms = delta.total_seconds() * 1000
    print("Time difference is {ms} milliseconds")
    return ms


def get_value(file_path, line_number1, column_number1):
    column = int(column_number1)
    line = int(line_number1)
    with open(file_path, 'r') as csv_file:
        reader = csv.reader(csv_file)
        line_count = 0
        for row in reader:
            line_count += 1
            if line_count == line:
                return row[column]
    return None


def find_nonzero_numbers(file_path, column1):
    column = int(column1)
    with open(file_path, 'r') as csv_file:
        reader = csv.reader(csv_file)
        line_number = 0
        nonzero_list = []
        for row in reader:
            line_number += 1
            try:
                number = int(row[column])
                if number != 0:
                    nonzero_list.append(number)
                    nonzero_list.append(line_number)

            except ValueError:
                pass
    return nonzero_list


def find_nonzero_value(file_path, column1):
    column = int(column1)
    with open(file_path, 'r') as csv_file:
        reader = csv.reader(csv_file)
        next(reader, None)
        line_number = 1
        nonzero_list = []
        for row in reader:
            line_number += 1
            try:
                number = len(row[column])
                if number > 0:
                    nonzero_list.append(row[column])
                    nonzero_list.append(line_number)

            except ValueError:
                pass
    return nonzero_list


def find_first_nonzero_number(file_path, column1):
    column = int(column1)
    with open(file_path, 'r') as csv_file:
        reader = csv.reader(csv_file)
        line_number = 0
        for row in reader:
            line_number += 1
            try:
                number = float(row[column])
                if number != 0:
                    # return number, line_number
                    print(number, line_number)
            except ValueError:
                pass


def get_csv_line_len(file_path):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))
    line_len = len(reader)

    return line_len


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
