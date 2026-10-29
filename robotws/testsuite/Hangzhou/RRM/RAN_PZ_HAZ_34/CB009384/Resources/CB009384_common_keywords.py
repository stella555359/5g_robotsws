# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/6/15 23:45
import csv
import json
import os
import subprocess
import time

import requests


def test():
    pass


def get_ulFdSchedData_mcsTable_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv ulFdSchedData.mcsTable value except 'null'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        ulFdSchedData_mcsTable = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_indices = [column_index_f1, column_index_f2]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == filter_name3 and col_data1[i][1] != '':
                ulFdSchedData_mcsTable.append(col_data1[i][1])
                counter += 1
        print(len(ulFdSchedData_mcsTable))
        if counter >= 1:
            assert True
        else:
            assert False
        return ulFdSchedData_mcsTable


def get_ulFdSchedData_laMode_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv ulFdSchedData.laMode value except 'null'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        ulFdSchedData_laMode = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_indices = [column_index_f1, column_index_f2]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == filter_name3 and col_data1[i][1] != '':
                ulFdSchedData_laMode.append(col_data1[i][1])
                counter += 1
        print(len(ulFdSchedData_laMode))
        if counter >= 1:
            assert True
        else:
            assert False
        return ulFdSchedData_laMode


def get_dlFdSchedData_laMode_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv dlFdSchedData.laMode value except 'null'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        dlFdSchedData_laMode = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_indices = [column_index_f1, column_index_f2]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == filter_name3 and col_data1[i][1] != '':
                dlFdSchedData_laMode.append(col_data1[i][1])
                counter += 1
        print(len(dlFdSchedData_laMode))
        if counter >= 1:
            assert True
        else:
            assert False
        return dlFdSchedData_laMode


def get_dlFdSchedData_mcsTable_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv dlFdSchedData.mcsTable value except 'null'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        dlFdSchedData_mcsTable = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_indices = [column_index_f1, column_index_f2]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == filter_name3 and col_data1[i][1] != '':
                dlFdSchedData_mcsTable.append(col_data1[i][1])
                counter += 1
        print(len(dlFdSchedData_mcsTable))
        if counter >= 1:
            assert True
        else:
            assert False
        return dlFdSchedData_mcsTable
