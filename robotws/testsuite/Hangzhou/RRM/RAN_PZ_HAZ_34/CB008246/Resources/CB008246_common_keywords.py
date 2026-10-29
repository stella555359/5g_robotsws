# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/6/15 23:45
import csv
import json
import os
import re
import subprocess
import time

import pexpect
import requests

from taf.transport.ssh.connection import SSHConnection
import taf.transport.ssh as ssh
from robot.libraries.BuiltIn import BuiltIn
from taf.hw.rf_attenuator import rf_attenuator


def get_value_test(csv_file, filter_name):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: list_col_filter_name: list of all values under col filter name
             total_num_filter_value: total num of list_col_filter_name
    """
    col_data_new = []
    col_data_aggregationLevel = []
    with open(csv_file) as f:
        reader = csv.DictReader(f)
        origin_col_data = [row[filter_name] for row in reader]
        col_data = origin_col_data
        for element in col_data:
            if element and int(eval(element)) != 255:
                col_data_new.append(element)
        for element in col_data:
            if element:
                col_data_aggregationLevel.append(element)
    print(col_data_new, col_data_aggregationLevel)
    return col_data_new, col_data_aggregationLevel


# def get_dlFdSchedData_rrmDlUsedMcs_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv dlFdSchedData_rrmDlUsedMcs value except 'null' and '255'
#
#     """
#     col_data_new = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         # print(origin_col_data)
#         col_data = origin_col_data
#         for element in col_data:
#             if element and int(eval(element)) not in [29, 30, 31, 255]:
#                 #            if element and int(eval(element)) != 255:
#                 col_data_new.append(element)
#     # print(type(col_data_new[0]))
#     print(col_data_new)
#     return col_data_new


def get_dlFdSchedData_rrmDlUsedMcs_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv dlFdSchedData_rrmDlUsedMcs value except 'null' and '255'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        dlFdSchedData_rrmDlUsedMcs = []
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
            if col_data1[i][0] == filter_name3 and col_data1[i][1] != '' \
                    and eval(col_data1[i][1]) not in [29.0, 30.0, 31.0, 255.0]:
                # if col_data1[i][0] == filter_name3 and col_data1[i][1] != '' and eval(col_data1[i][1]) != 255.0:
                dlFdSchedData_rrmDlUsedMcs.append(col_data1[i][1])
                counter += 1
        print(len(dlFdSchedData_rrmDlUsedMcs))
        if counter >= 1:
            assert True
        else:
            assert False
        return dlFdSchedData_rrmDlUsedMcs


# def get_dlFdSchedData_targetBLER_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv dlFdSchedData_targetBLER value except 'null' and '255'
#
#     """
#     col_data_targetBLER = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         col_data = origin_col_data
#         for element in col_data:
#             if element != '' and eval(element) != 255.0:
#                 col_data_targetBLER.append(element)
#     print(col_data_targetBLER)
#     return col_data_targetBLER


def get_dlFdSchedData_targetBLER_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv dlFdSchedData_targetBLER value except 'null' and '255'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        hr_dlFdSchedData_targetBLER = []
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
            if col_data1[i][0] == filter_name3 and col_data1[i][1] != '' and eval(col_data1[i][1]) != 255.0:
                hr_dlFdSchedData_targetBLER.append(col_data1[i][1])
                counter += 1
        print(len(hr_dlFdSchedData_targetBLER))
        if counter >= 1:
            assert True
        else:
            assert False
        return hr_dlFdSchedData_targetBLER


# def get_dlFdSchedData_mcsTable_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv dlFdSchedData.mcsTable value except 'null'
#
#     """
#     col_data_mcsTable = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         col_data = origin_col_data
#         for element in col_data:
#             if element:
#                 col_data_mcsTable.append(element)
#     print(col_data_mcsTable)
#     return col_data_mcsTable


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


# def get_dlFdSchedData_laMode_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv dlFdSchedData.laMode value except 'null'
#
#     """
#     col_data_laMode = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         col_data = origin_col_data
#         for element in col_data:
#             if element:
#                 col_data_laMode.append(element)
#     print(col_data_laMode)
#     return col_data_laMode


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


# def get_dlFdSchedData_aggregationLevel_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv dlFdSchedData.aggregationLevel value except 'null'
#
#     """
#     col_data_aggregationLevel = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         col_data = origin_col_data
#         for element in col_data:
#             if element:
#                 col_data_aggregationLevel.append(element)
#     print(col_data_aggregationLevel)
#     return col_data_aggregationLevel


def get_dlFdSchedData_aggregationLevel_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv dlFdSchedData.aggregationLevel value except 'null'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        dlFdSchedData_aggregationLevel = []
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
                dlFdSchedData_aggregationLevel.append(col_data1[i][1])
                counter += 1
        print(len(dlFdSchedData_aggregationLevel))
        if counter >= 1:
            assert True
        else:
            assert False
        return dlFdSchedData_aggregationLevel


# def get_ulFdSchedData_rrmUlUsedMcs_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv ulFdSchedData.rrmUlUsedMcs value except 'null' and '255'
#
#     """
#     col_data_new = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         # print(origin_col_data)
#         col_data = origin_col_data
#         for element in col_data:
#             # if element and element!=255.0:
#             if element and int(eval(element)) != 255:
#                 # if int(eval(element)) != 255:
#                 col_data_new.append(element)
#     # print(type(col_data_new[0]))
#     print(col_data_new)
#     return col_data_new


def get_ulFdSchedData_rrmUlUsedMcs_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv ulFdSchedData.rrmUlUsedMcs value except 'null' and '255'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        ulFdSchedData_rrmUlUsedMcs = []
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
            if col_data1[i][0] == filter_name3 and col_data1[i][1] != '' \
                    and eval(col_data1[i][1]) not in [29.0, 30.0, 31.0, 255.0]:
                ulFdSchedData_rrmUlUsedMcs.append(col_data1[i][1])
                counter += 1
        print(len(ulFdSchedData_rrmUlUsedMcs))
        if counter >= 1:
            assert True
        else:
            assert False
        return ulFdSchedData_rrmUlUsedMcs


# def get_ulFdSchedData_targetBLER_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv ulFdSchedData.targetBLER value except 'null' and '255'
#
#     """
#     col_data_targetBLER = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         col_data = origin_col_data
#         for element in col_data:
#             if element != '' and eval(element) != 255.0:
#                 col_data_targetBLER.append(element)
#     print(col_data_targetBLER)
#     return col_data_targetBLER


def get_ulFdSchedData_targetBLER_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv ulFdSchedData.targetBLER value except 'null' and '255'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        hr_ulFdSchedData_targetBLER = []
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
            if col_data1[i][0] == filter_name3 and col_data1[i][1] != '' and eval(col_data1[i][1]) != 255.0:
                hr_ulFdSchedData_targetBLER.append(col_data1[i][1])
                counter += 1
        print(len(hr_ulFdSchedData_targetBLER))
        if counter >= 1:
            assert True
        else:
            assert False
        return hr_ulFdSchedData_targetBLER


# def get_ulFdSchedData_mcsTable_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv ulFdSchedData.mcsTable value except 'null'
#
#     """
#     col_data_mcsTable = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         col_data = origin_col_data
#         for element in col_data:
#             if element:
#                 col_data_mcsTable.append(element)
#     print(col_data_mcsTable)
#     return col_data_mcsTable


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


# def get_ulFdSchedData_laMode_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv ulFdSchedData.laMode value except 'null'
#
#     """
#     col_data_laMode = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         col_data = origin_col_data
#         for element in col_data:
#             if element:
#                 col_data_laMode.append(element)
#     print(col_data_laMode)
#     return col_data_laMode


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


# def get_ulFdSchedData_aggregationLevel_value(csv_file, filter_name):
#     """
#     as per filter name get all values per col
#     :param csv_file: csv file name
#     :param filter_name: head of filter name
#     :return: col_data_new: list csv ulFdSchedData.aggregationLevel value except 'null'
#
#     """
#     col_data_aggregationLevel = []
#     with open(csv_file) as f:
#         reader = csv.DictReader(f)
#         origin_col_data = [row[filter_name] for row in reader]
#         col_data = origin_col_data
#         for element in col_data:
#             if element:
#                 col_data_aggregationLevel.append(element)
#     print(col_data_aggregationLevel)
#     return col_data_aggregationLevel


def get_ulFdSchedData_aggregationLevel_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv ulFdSchedData.aggregationLevel value except 'null'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        ulFdSchedData_aggregationLevel = []
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
                ulFdSchedData_aggregationLevel.append(col_data1[i][1])
                counter += 1
        print(len(ulFdSchedData_aggregationLevel))
        if counter >= 1:
            assert True
        else:
            assert False
        return ulFdSchedData_aggregationLevel


def get_BR_BR_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4):
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        hr_pdcchMetric_ratio = []
        hr_pdschMetric_ratio = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f4 = header.index(filter_name4)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f4]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        # print(col_data1[0][0])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == 'BASICRELIABILITY' and col_data1[i][1] == 'DLHRBLERRECOVERPERIODTIMER':
                assert eval(col_data1[i][2]) < 60.0 or eval(col_data1[i][3]) < 60.0
                counter += 1
        print(counter)
        if counter >= 1:
            assert True
        else:
            assert False


def get_BR_HR_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4):
    with open(csv_file, 'r') as f:
        col_data1 = []
        hr_pdcchMetric_ratio = []
        hr_pdschMetric_ratio = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f4 = header.index(filter_name4)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f4]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == 'HIGHRELIABILITY' and col_data1[i][1] == 'DLHRBLERRECOVERPERIODTIMER':
                hr_pdcchMetric_ratio.append(col_data1[i][2])
                hr_pdschMetric_ratio.append(col_data1[i][3])
        print(len(hr_pdcchMetric_ratio))
        print(len(hr_pdschMetric_ratio))
        return hr_pdcchMetric_ratio, hr_pdschMetric_ratio


def get_HR_BR_rrmCorrAvgCqi_RANK2_AD_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4,
                                           filter_name5):
    with open(csv_file, 'r') as f:
        col_data1 = []
        hr_rrmCorrAvgCqi = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f4 = header.index(filter_name4)
        column_index_f5 = header.index(filter_name5)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f4, column_index_f5]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == 'BASICRELIABILITY' and col_data1[i][1] == 'RANK2' and col_data1[i][2] == '12.0' \
                    and eval(col_data1[i][4]) not in [0.0, 1.0]:
                hr_rrmCorrAvgCqi.append(col_data1[i][3])
        num1 = len(hr_rrmCorrAvgCqi)
        return hr_rrmCorrAvgCqi, num1


def get_HR_BR_rrmCorrAvgCqi_RANK1_AD_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4,
                                           filter_name5):
    with open(csv_file, 'r') as f:
        col_data1 = []
        hr_rrmCorrAvgCqi = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f4 = header.index(filter_name4)
        column_index_f5 = header.index(filter_name5)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f4, column_index_f5]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == 'BASICRELIABILITY' and col_data1[i][1] == 'RANK1' and col_data1[i][2] == '12.0' \
                    and eval(col_data1[i][4]) not in [0.0, 1.0]:
                hr_rrmCorrAvgCqi.append(col_data1[i][3])
        num2 = len(hr_rrmCorrAvgCqi)
        return hr_rrmCorrAvgCqi, num2


def get_HR_HR_rrmCorrAvgCqi_RANK2_AD_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4,
                                           filter_name5):
    with open(csv_file, 'r') as f:
        col_data1 = []
        hr_rrmCorrAvgCqi = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f4 = header.index(filter_name4)
        column_index_f5 = header.index(filter_name5)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f4, column_index_f5]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == 'HIGHRELIABILITY' and col_data1[i][1] == 'RANK2' and col_data1[i][2] == '12.0' \
                    and eval(col_data1[i][4]) not in [0.0, 1.0]:
                hr_rrmCorrAvgCqi.append(col_data1[i][3])
        num3 = len(hr_rrmCorrAvgCqi)
        return hr_rrmCorrAvgCqi, num3


def get_HR_HR_rrmCorrAvgCqi_RANK1_AD_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4,
                                           filter_name5):
    with open(csv_file, 'r') as f:
        col_data1 = []
        hr_rrmCorrAvgCqi = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f4 = header.index(filter_name4)
        column_index_f5 = header.index(filter_name5)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f4, column_index_f5]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == 'HIGHRELIABILITY' and col_data1[i][1] == 'RANK1' and col_data1[i][2] == '12.0' \
                    and eval(col_data1[i][4]) not in [0.0, 1.0]:
                hr_rrmCorrAvgCqi.append(col_data1[i][3])
        num4 = len(hr_rrmCorrAvgCqi)
        return hr_rrmCorrAvgCqi, num4


def get_HR_HR_AL8_AD_value(csv_file, filter_name1, filter_name2, filter_name3):
    with open(csv_file, 'r') as f:
        col_data1 = []
        hr_CqiAlSelection = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_indices = [column_index_f1, column_index_f2, column_index_f3]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == 'HIGHRELIABILITY' and col_data1[i][1] == '8.0':
                hr_CqiAlSelection.append(col_data1[i][2])
        print(len(hr_CqiAlSelection))
        return hr_CqiAlSelection


def get_HR_HR_AL4_AD_value(csv_file, filter_name1, filter_name2, filter_name3):
    with open(csv_file, 'r') as f:
        col_data1 = []
        hr_CqiAlSelection = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_indices = [column_index_f1, column_index_f2, column_index_f3]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == 'HIGHRELIABILITY' and col_data1[i][1] == '4.0':
                hr_CqiAlSelection.append(col_data1[i][2])
        print(len(hr_CqiAlSelection))
        return hr_CqiAlSelection


def get_HR_BR_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4):
    with open(csv_file, 'r') as f:
        col_data1 = []
        br_pdcchMetric_ratio = []
        br_pdschMetric_ratio = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f4 = header.index(filter_name4)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f4]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == 'BASICRELIABILITY' and col_data1[i][1] == 'DLHRBLEROUTAGEPERIODTIMER':
                br_pdschMetric_ratio.append(col_data1[i][3])
            if col_data1[i][0] == 'BASICRELIABILITY' and col_data1[i][1] == 'DLPDCCHHRBLEROUTAGEPERIODTIMER':
                br_pdcchMetric_ratio.append(col_data1[i][2])
        print(len(br_pdschMetric_ratio))
        print(len(br_pdcchMetric_ratio))
        if len(br_pdschMetric_ratio) >= 1.0 and len(br_pdcchMetric_ratio) >= 1.0:
            assert eval(min(br_pdschMetric_ratio)) >= 50.0 or eval(min(br_pdcchMetric_ratio)) >= 50.0
            return br_pdschMetric_ratio, br_pdcchMetric_ratio
        elif len(br_pdschMetric_ratio) >= 1.0:
            # assert br_pdschMetric_ratio is not None and eval(min(br_pdschMetric_ratio)) >= 50.0
            assert eval(min(br_pdschMetric_ratio)) >= 50.0
            return br_pdschMetric_ratio
        elif len(br_pdcchMetric_ratio) >= 1.0:
            assert eval(min(br_pdcchMetric_ratio)) >= 50.0
            return br_pdcchMetric_ratio
        else:
            assert False


def get_HR_HR_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4):
    with open(csv_file, 'r') as f:
        col_data1 = []
        hr_pdcchMetric_ratio = []
        hr_pdschMetric_ratio = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f4 = header.index(filter_name4)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f4]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        # print(col_data1[0][0])
        print(col_data1)
        for i in range(len(col_data1)):
            if (col_data1[i][1] == 'DLHRBLEROUTAGEPERIODTIMER'
                or col_data1[i][1] == 'DLPDCCHHRBLEROUTAGEPERIODTIMER') \
                    and col_data1[i][0] == 'HIGHRELIABILITY':
                hr_pdcchMetric_ratio.append(col_data1[i][2])
                hr_pdschMetric_ratio.append(col_data1[i][3])
        print(len(hr_pdcchMetric_ratio))
        print(len(hr_pdschMetric_ratio))
        return hr_pdcchMetric_ratio, hr_pdschMetric_ratio


# def get_HR_BLER_SINR_value(csv_file, filter_name1, filter_name2, filter_name3):
#     with open(csv_file, 'r') as f:
#         col_data1 = []
#         hr_BLER = []
#         hr_SINR = []
#         reader = csv.reader(f)
#         header = next(reader)
#         column_index_f1 = header.index(filter_name1)
#         column_index_f2 = header.index(filter_name2)
#         column_index_f3 = header.index(filter_name3)
#         column_indices = [column_index_f1, column_index_f2, column_index_f3]
#         print(column_indices)
#         for row in reader:
#             col_data1.append([row[i] for i in column_indices])
#         # print(col_data1[0][0])
#         print(col_data1)
#         for i in range(len(col_data1)):
#             if col_data1[i][0] == 'HIGHRELIABILITY':
#                 hr_BLER.append(col_data1[i][1])
#                 hr_SINR.append(col_data1[i][2])
#         print(len(hr_BLER))
#         print(len(hr_SINR))
#         return hr_BLER, hr_SINR
#
#
# def get_BR_BLER_SINR_value(csv_file, filter_name1, filter_name2, filter_name3):
#     with open(csv_file, 'r') as f:
#         col_data1 = []
#         br_BLER = []
#         br_SINR = []
#         reader = csv.reader(f)
#         header = next(reader)
#         column_index_f1 = header.index(filter_name1)
#         column_index_f2 = header.index(filter_name2)
#         column_index_f3 = header.index(filter_name3)
#         column_indices = [column_index_f1, column_index_f2, column_index_f3]
#         print(column_indices)
#         for row in reader:
#             col_data1.append([row[i] for i in column_indices])
#         # print(col_data1[0][0])
#         print(col_data1)
#         for i in range(len(col_data1)):
#             if col_data1[i][0] == 'BASICRELIABILITY':
#                 br_BLER.append(col_data1[i][1])
#                 br_SINR.append(col_data1[i][2])
#         print(len(br_BLER))
#         print(len(br_SINR))
#         return br_BLER, br_SINR
#
#
# def get_BR_BLER_MCS_value(csv_file, filter_name1, filter_name2, filter_name3):
#     with open(csv_file, 'r') as f:
#         col_data1 = []
#         br_BLER = []
#         br_MCS = []
#         reader = csv.reader(f)
#         header = next(reader)
#         column_index_f1 = header.index(filter_name1)
#         column_index_f2 = header.index(filter_name2)
#         column_index_f3 = header.index(filter_name3)
#         column_indices = [column_index_f1, column_index_f2, column_index_f3]
#         print(column_indices)
#         for row in reader:
#             col_data1.append([row[i] for i in column_indices])
#         # print(col_data1[0][0])
#         print(col_data1)
#         for i in range(len(col_data1)):
#             if col_data1[i][0] == 'BASICRELIABILITY':
#                 br_BLER.append(col_data1[i][1])
#                 br_MCS.append(col_data1[i][2])
#         print(len(br_BLER))
#         print(len(br_MCS))
#         return br_BLER, br_MCS


def get_HR_BLER_SINR_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4, filter_name5):
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        hr_BLER = []
        hr_SINR = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f5 = header.index(filter_name5)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f5]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][3] == filter_name4 and col_data1[i][0] == 'HIGHRELIABILITY':
                hr_BLER.append(col_data1[i][1])
                hr_SINR.append(col_data1[i][2])
                counter += 1
        print(len(hr_BLER))
        print(len(hr_SINR))
        if counter >= 1:
            assert True
        else:
            assert False
        return hr_BLER, hr_SINR


def get_BR_BLER_SINR_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4, filter_name5):
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        br_BLER = []
        br_SINR = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f5 = header.index(filter_name5)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f5]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][3] == filter_name4 and col_data1[i][0] == 'BASICRELIABILITY':
                br_BLER.append(col_data1[i][1])
                br_SINR.append(col_data1[i][2])
                counter += 1
        print(len(br_BLER))
        print(len(br_SINR))
        if counter >= 1:
            assert True
        else:
            assert False
        return br_BLER, br_SINR


def get_BR_BLER_MCS_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4, filter_name5):
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        br_BLER = []
        br_MCS = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f3 = header.index(filter_name3)
        column_index_f5 = header.index(filter_name5)
        column_indices = [column_index_f1, column_index_f2, column_index_f3, column_index_f5]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][3] == filter_name4 and col_data1[i][0] == 'BASICRELIABILITY':
                br_BLER.append(col_data1[i][1])
                br_MCS.append(col_data1[i][2])
                counter += 1
        print(len(br_BLER))
        print(len(br_MCS))
        if counter >= 1:
            assert True
        else:
            assert False
        return br_BLER, br_MCS


def get_NgbrUlCgType2Prb_value(csv_file, filter_name1, filter_name2, filter_name3, filter_name4,
                               filter_name5, filter_name6):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv dlFdSchedData_rrmDlUsedMcs value except 'null' and '255'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        hr_NgbrUlCgType2Prb = []
        reader = csv.reader(f)
        header = next(reader)
        column_index_f1 = header.index(filter_name1)
        column_index_f2 = header.index(filter_name2)
        column_index_f4 = header.index(filter_name4)
        column_index_f5 = header.index(filter_name5)
        column_index_f6 = header.index(filter_name6)
        column_indices = [column_index_f1, column_index_f2, column_index_f4, column_index_f5, column_index_f6]
        print(column_indices)
        for row in reader:
            col_data1.append([row[i] for i in column_indices])
        print(col_data1)
        for i in range(len(col_data1)):
            if col_data1[i][0] == filter_name3 and col_data1[i][1] == 'HIGHRELIABILITY' \
                    and col_data1[i][2] == 'QAM64LOWSE' and col_data1[i][4] == '0.01':
                hr_NgbrUlCgType2Prb.append(col_data1[i][3])
                counter += 1
        print(len(hr_NgbrUlCgType2Prb))
        if counter >= 1:
            assert True
        else:
            assert False
        return hr_NgbrUlCgType2Prb


def get_ulFdSchedData_rrmUlProposedMcs_value(csv_file, filter_name1, filter_name2, filter_name3):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: col_data_new: list csv get_ulFdSchedData.rrmUlProposedMcs_value value except 'null'

    """
    with open(csv_file, 'r') as f:
        counter = 0
        col_data1 = []
        ulFdSchedData_rrmUlProposedMcs = []
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
                ulFdSchedData_rrmUlProposedMcs.append(col_data1[i][1])
                counter += 1
        print(len(ulFdSchedData_rrmUlProposedMcs))
        if counter >= 1:
            assert True
        else:
            assert False
        return ulFdSchedData_rrmUlProposedMcs


def get_corresponding_mo_id(parameter_list, distname_id):
    """
    get corresponding mo id from coam.get_managed_objects, which index is required to get
    parameter_list =
    [{'distName': '/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-37/SCF-1/MRBTS_A-38211/NRBTS_A-38211/NRCELL_A-2'},
    {'distName': '/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-37/SCF-1/MRBTS_A-38211/NRBTS_A-38211/NRCELL_A-1'}]
    :param parameter_list: mo_list from coam.get_managed_objects
    :param distname_id: which index is required to get
    """
    for i, j in enumerate(parameter_list):
        if int(parameter_list[i].get('distName').split('/')[-1][-1]) == int(distname_id):
            mo_id = i
    return mo_id


def dynamic_rule_submit(imsi, rule):
    url = 'https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/ncp_api_update_device'
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJwejRfaHozIiwiZW1haWwiOiJtaW5'
                         'nLnNoaUBub2tpYS1zYmVsbC5jb20iLCJkaXNwbGF5bmFtZSI6IlB6NCBIejMiLCJuc25jaXR5IjoiSGFuZ3'
                         'pob3UiLCJyb2xlcyI6WyJwejRfaHozX2F1dG9tYXRpb24iXSwiZXhwIjoyMDEzNDAxMTk3LjAwNzE4OH0.R'
                         'HAz-svYO1k5byDdHI6ECT_0RG_J7pXc8ZmNyZh25QzkddRBJZcEP1HkuhPrkpisH9ED8hH9aCBSYLC5B0Yd'
                         'edKqx2NIbaW1SHyaey8GpdZDE-XVL2Z2OSY5jEvkWPTbHxu4ldvld_MESZuxtQ5kNeoHghuo-DbY8hSAQi-c'
                         'yT-EPgDJCEcBt4O903Rka3TQ-f_hOxkwrjqMtIjT1yfF4oEfxnqQRRGyqk-_Rzyu9A_1vg5PSsgMzYR6t-bnj'
                         'FOrv9gHMVYaeBiCjlY1CX8idpgcUfV24jvwTPrzLONF3hiYG1_bxcxwS5EAGlCh-JpRoFH1NoQEmRHvn73Uz9Q7QA'
    }
    data = {
        'imsi': imsi,
        'rule_name': rule
    }
    response = requests.post(url=url, headers=headers, data=data, verify=False)
    print(response.text)
    result = json.loads(response.text)
    if response.status_code == 200:
        # msg = result['msg']['responseStatus']['message']
        msg = result['msg']
    elif response.status_code == 500:
        msg = result['msg']
    return response.status_code, msg


def put_plug_in_to_wireshark_path_of_ute(
        plug_in_path='/opt/workspace/Tool/wireshark_plug_in/',
        wireshark_installation_path='/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.2/epan/'):
    code = os.system(f"sudo cp -r {plug_in_path}* {wireshark_installation_path}")
    return code


def rm_plug_in_to_wireshark_path_of_ute(
        plug_in_path='/opt/workspace/Tool/wireshark_plug_in/',
        wireshark_installation_path='/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.2/epan/'):
    result = os.popen(cmd=f"cd {plug_in_path};ls -l")
    output = result.read().split('\n')[1:-1]
    file_name_list = []
    for i in output:
        file_name_list.append(i.split(' ')[-1])
    rm_file_names_str = ' '.join(file_name_list)
    code = os.system(f"cd {wireshark_installation_path};sudo rm -rf {rm_file_names_str}")
    return code


def get_value_from_csv_file(file_path, queried_filed, mode="r"):
    with open(file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        required_data_list = []
        for data in csv_data:
            if data[queried_filed] != '':
                required_data_list.append(data[queried_filed])

    return required_data_list


def get_value_from_csv_file_255_exclude(file_path, queried_filed, mode="r"):
    with open(file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        required_data_list = []
        for data in csv_data:
            if data[queried_filed] != '' and data[queried_filed] != '255' and data[queried_filed] != '255.0':
                required_data_list.append(data[queried_filed])

    return required_data_list


def get_scalefactorforhrgbr_dl_ul_num(log_path, is_vonr_setup=True):
    with open(log_path, "r") as f:
        result = f.read()
        if is_vonr_setup is True:
            obj = re.compile(
                pattern=r"is VONR use default ScaleFactorForGbrDLUL: DL=(?P<dl_num>\d+), UL=(?P<ul_num>\d+)",
                flags=re.I)
        else:
            obj = re.compile(pattern=r"scaleFactorForHRGbr: DL=(?P<dl_num>\d+), UL=(?P<ul_num>\d+)", flags=re.I)
        num = obj.search(string=result)

    return num.group('dl_num'), num.group('ul_num')


# def match_output(result, pattern, timeout):
#     start_time = time.time()
#     output = ""
#     pattern_obj = re.compile(pattern=pattern)
#     while (time.time() - start_time) <= timeout:
#         output += str(result.recv(65535))
#         if pattern_obj.search(output):
#             return output
#         time.sleep(0.5)
#     else:
#         raise TimeoutError(f"{output} is unable to be search via {pattern}")
#
#
# def execute_gnb_log_tool(hostname, username, password, command):
#     ssh_obj = SSHConnection()
#     ssh_obj.configure(hostname=hostname, username=username, password=password)
#     ssh_obj.connect()
#     # ssh_obj.send_command(command=command)
#     terminal = ssh_obj.invoke_shell()
#     terminal.send(command)
#     print("1")
#     match_output(result=terminal, pattern=r"(Q)uit", timeout=20)
#     print("2")
#     return terminal, ssh_obj
#
#
# def end_gnb_log_tool(tn, ssh_):
#     tn.send("\r")
#     match_output(result=tn, pattern=r"Tool finished running.", timeout=120)
#     ssh_.disconnect()


def make_voice_call(connection, ue_index=0, phone_number="6688", status=2):
    tl = BuiltIn().get_variable_value("${tl}")
    serial_number = tl.ues[ue_index].serial_number
    sshconn = ssh.ssh()
    sshconn.connect_to(hostname=tl.ues[ue_index].ssh_connection_details.addr,
                       username=tl.ues[ue_index].ssh_connection_details.username,
                       password=tl.ues[ue_index].ssh_connection_details.password,
                       alias=connection)
    time.sleep(5)
    sshconn.send_command(command=f'adb -s {serial_number} shell input keyevent 3',
                         connection=connection)
    time.sleep(2)
    sshconn.send_command(command=f'adb -s {serial_number} shell input swipe 500 2050 500 800',
                         connection=connection)
    time.sleep(2)
    sshconn.send_command(
        command=f'adb -s {serial_number} shell am start -a android.intent.action.CALL tel:+{phone_number}',
        connection=connection)
    time.sleep(20)
    sshconn.send_command(command=f'adb -s {serial_number} shell dumpsys telephony.registry |grep mCallState',
                         connection=connection)
    time.sleep(2)
    output = sshconn.read_output(connection=connection)
    time.sleep(1)
    sshconn.disconnect(connection=connection)
    if f"mCallState={status}" in output:
        return True
    else:
        return False


def hang_up_voice_call(connection, ue_index=0, status=0):
    tl = BuiltIn().get_variable_value("${tl}")
    serial_number = tl.ues[ue_index].serial_number
    sshconn = ssh.ssh()
    sshconn.connect_to(hostname=tl.ues[ue_index].ssh_connection_details.addr,
                       username=tl.ues[ue_index].ssh_connection_details.username,
                       password=tl.ues[ue_index].ssh_connection_details.password,
                       alias=connection)
    time.sleep(5)
    sshconn.send_command(command=f'adb -s {serial_number} shell input keyevent 6',
                         connection=connection)
    time.sleep(20)
    sshconn.send_command(command=f'adb -s {serial_number} shell dumpsys telephony.registry |grep mCallState',
                         connection=connection)
    time.sleep(2)
    output = sshconn.read_output(connection=connection)
    time.sleep(1)
    sshconn.disconnect(connection=connection)
    if f"mCallState={status}" in output:
        return True
    else:
        return False


def exec_gnb_logs_tool_for_voice_call(ute_ip, ute_username, ute_password, gnb_logs_tool_path, gnb_ip, connection,
                                      is_rm_old_log_file=True, is_make_voice_call=True, ue_index=0, timeout=120):
    call_result = ""
    with open("./test.txt", "wb") as f:
        child = pexpect.spawn(f'ssh {ute_username}@{ute_ip}', logfile=f)
        child.expect('password:')
        child.sendline(ute_password)
        child.expect("ute")
        child.sendline(f"cd {gnb_logs_tool_path}")
        child.expect("gnb_logs")
        if is_rm_old_log_file is True:
            child.sendline(f"rm -rf BTS-*")
            child.expect("gnb_logs")
        child.sendline(f"./gnb_logs {gnb_ip} -s")
        child.expect("uit", timeout=timeout)
        if is_make_voice_call is True:
            call_result = make_voice_call(connection=connection, ue_index=ue_index)
        else:
            call_result = hang_up_voice_call(connection=connection, ue_index=ue_index)
        child.sendline("\r")
        # child.expect('Tool finished running.', timeout=timeout)
        child.expect('intend to other BBMOD', timeout=timeout)
        child.close()
    return call_result


def adjust_pa_value(att_ipaddr, att_api_port, vendor, att_ports, origin_values, target_values, att_connection_port=None,
                    max_attenuation_value=127, model="HBTE"):
    att = rf_attenuator()
    att.setup_attenuator(ip_addr=att_ipaddr, port=att_api_port, attenuation_port_numbers=att_connection_port,
                         max_attenuation=max_attenuation_value, model=model, vendor=vendor)
    num_att_port = len(att_ports)
    for num in range(num_att_port):
        att.set_attenuation(port=att_ports[num], value=origin_values[num])
        time.sleep(0.5)
        value_port = att.read_attenuation(port=att_ports[num])
        value_port = int(value_port)
        assert value_port == origin_values[
            num], f"Set attenuation value failed, port:{att_ports[num]}, value:{origin_values[num]}"
    for step_value in range(origin_values[0], target_values[0] + 1):
        for num in range(num_att_port):
            att.set_attenuation(port=att_ports[num], value=step_value)
            time.sleep(0.5)
            value_port = att.read_attenuation(port=att_ports[num])
            value_port = int(value_port)
            assert value_port == step_value, f"Set attenuation value failed, port:{att_ports[num]}, value:{step_value}"


def exec_gnb_logs_tool_for_adjust_pa(ute_ip, ute_username, ute_password, gnb_logs_tool_path, gnb_ip, option, att_ipaddr,
                                     att_api_port, vendor, att_ports, origin_values, target_values,
                                     att_connection_port=None, max_attenuation_value=127, model="HBTE",
                                     is_rm_old_log_file=True, timeout=120):
    with open("./test.txt", "wb") as f:
        child = pexpect.spawn(f'ssh {ute_username}@{ute_ip}', logfile=f)
        child.expect('password:')
        child.sendline(ute_password)
        child.expect("ute")
        child.sendline(f"cd {gnb_logs_tool_path}")
        child.expect("gnb_logs")
        if is_rm_old_log_file is True:
            child.sendline(f"rm -rf BTS-*")
            child.expect("gnb_logs")
        child.sendline(f"./gnb_logs {gnb_ip} {option}")
        child.expect("uit", timeout=timeout)
        adjust_pa_value(att_ipaddr=att_ipaddr, att_api_port=att_api_port, vendor=vendor, att_ports=att_ports,
                        origin_values=origin_values, target_values=target_values,
                        att_connection_port=att_connection_port,
                        max_attenuation_value=max_attenuation_value,
                        model=model)
        child.sendline("\r")
        child.expect('Tool finished running.', timeout=timeout)
        # child.expect('intend to other BBMOD', timeout=timeout)
        child.close()


# def get_related_values(file_path, mode="r"):
#     cqiDerivedMcs_list = []
#     rrmCorrAvgCqi_list = []
#     numOfLayers_list = []
#     with open(file_path, mode) as csv_file:
#         csv_data = csv.DictReader(f=csv_file)
#         for data in csv_data:
#             if data["cqiDerivedMcs"] != '' and data["cqiDerivedMcs"] != '255' and (
#                     data["cqiDerivedMcs"] not in [str(n) for n in range(0, 10)]):
#                 cqiDerivedMcs_list.append(data["cqiDerivedMcs"])
#                 rrmCorrAvgCqi_list.append(data["rrmCorrAvgCqi"])
#                 numOfLayers_list.append(data["numOfLayers"])
#
#     return cqiDerivedMcs_list, rrmCorrAvgCqi_list, numOfLayers_list


def get_related_values(file_path, mode="r"):
    cqiDerivedMcs_list = []
    rrmCorrAvgCqi_list = []
    numOfLayers_list = []
    with open(file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        for data in csv_data:
            if data["dlFdSchedData.cqiDerivedMcs"] != '' and data["dlFdSchedData.cqiDerivedMcs"] != '255' and (
                    data["dlFdSchedData.cqiDerivedMcs"] not in [str(n) for n in range(0, 10)]):
                cqiDerivedMcs_list.append(data["dlFdSchedData.cqiDerivedMcs"])
                rrmCorrAvgCqi_list.append(data["dlFdSchedData.rrmCorrAvgCqi"])
                numOfLayers_list.append(data["dlFdSchedData.numOfLayers"])

    return cqiDerivedMcs_list, rrmCorrAvgCqi_list, numOfLayers_list


def get_standard_values(rank1_file_path, rank2_file_path, mode="r", num_prb="8"):
    rank1_Mcs_list = []
    rank2_Mcs_list = []
    rank1_standard_value_list = []
    rank2_standard_value_list = []
    with open(rank1_file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        for data in csv_data:
            rank1_Mcs_list.append(data["MCS"])
            rank1_standard_value_list.append(data[num_prb])
    with open(rank2_file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        for data in csv_data:
            rank2_Mcs_list.append(data["MCS"])
            rank2_standard_value_list.append(data[num_prb])
    return rank1_Mcs_list, rank2_Mcs_list, rank1_standard_value_list, rank2_standard_value_list


def check_value(file_path, rank1_file_path, rank2_file_path, num_prb="8"):
    """
    check values on direction dl
    1. get cqiDerivedMcs rrmCorrAvgCqi numOfLayers values from tti.csv
    2. get MCS-CQI mapping values from rank1.csv and rank2.csv
    3. as per numOfLayers to check rrmCorrAvgCqi value is in the range of MCS-CQI mapping values, then get msc value
    4. if numOfLayers is RANK1, then check cqiDerivedMcs value of rank1.csv equal msc value which get from step 3
    5. if numOfLayers is RANK2, then check cqiDerivedMcs value of rank1.csv equal msc value which get from step 3
    """
    cqiDerivedMcs_list, rrmCorrAvgCqi_list, numOfLayers_list = get_related_values(file_path=file_path)
    rank1_Mcs_list, rank2_Mcs_list, r1, r2 = get_standard_values(
        rank1_file_path=rank1_file_path, rank2_file_path=rank2_file_path, num_prb=num_prb)
    for index, cqi in enumerate(rrmCorrAvgCqi_list):
        if numOfLayers_list[index] == "RANK1":
            for i, mcs in enumerate(rank1_Mcs_list):
                if i != len(r1) - 1:
                    if eval(r1[i]) <= eval(cqi) <= eval(r1[i + 1]):
                        print(f"{eval(r1[i])} <= {eval(cqi)} < {eval(r1[i + 1])}")
                        print(f"{cqiDerivedMcs_list[index]} == {mcs}")
                        assert int(float(cqiDerivedMcs_list[index])) == int(mcs)
                        break
                else:
                    if eval(r1[i]) <= eval(cqi):
                        print(f"{eval(r1[i])} <= {eval(cqi)}")
                        print(f"{cqiDerivedMcs_list[index]} == {mcs}")
                        assert int(float(cqiDerivedMcs_list[index])) == int(mcs)
                        break
        elif numOfLayers_list[index] == "RANK2":
            for i, mcs in enumerate(rank2_Mcs_list):
                if i != len(r2) - 1:
                    if eval(r2[i]) <= eval(cqi) <= eval(r2[i + 1]):
                        print(f"{eval(r2[i])} <= {eval(cqi)} < {eval(r2[i + 1])}")
                        print(f"{cqiDerivedMcs_list[index]} == {mcs}")
                        assert int(float(cqiDerivedMcs_list[index])) == int(mcs)
                        break
                else:
                    if eval(r2[i]) <= eval(cqi):
                        print(f"{eval(r2[i])} <= {eval(cqi)}")
                        print(f"{cqiDerivedMcs_list[index]} == {mcs}")
                        assert int(float(cqiDerivedMcs_list[index])) == int(mcs)
                        break


# def get_related_value_on_direction_ul(file_path, mode="r"):
#     rrmUlProposedMcs_list = []
#     reScaledCorrAvgSinrPreAtb_list = []
#     numOfLayers_list = []
#     sinrOffsetUciInPusch_list = []
#     with open(file_path, mode) as csv_file:
#         csv_data = csv.DictReader(f=csv_file)
#         for data in csv_data:
#             if (data["rrmUlProposedMcs"] != '') and (data["rrmUlProposedMcs"] != '255') and \
#                     (data["rrmUlProposedMcs"] not in [str(n) for n in range(0, 10)]) and \
#                     (data["type"] == "ulFdSchedData") and (data["mcsTable"] == "QAM64LOWSE") and \
#                     (data["laMode"] == "HIGHRELIABILITY"):
#                 rrmUlProposedMcs_list.append(data["rrmUlProposedMcs"])
#                 reScaledCorrAvgSinrPreAtb_list.append(data["reScaledCorrAvgSinrPreAtb"])
#                 numOfLayers_list.append(data["numOfLayers"])
#                 sinrOffsetUciInPusch_list.append(data["sinrOffsetUciInPusch"])
#
#     return rrmUlProposedMcs_list, reScaledCorrAvgSinrPreAtb_list, numOfLayers_list, sinrOffsetUciInPusch_list


# def get_related_value_on_direction_ul(file_path, rnti, mode="r"):
#     rrmUlProposedMcs_list = []
#     reScaledCorrAvgSinrPreAtb_list = []
#     numOfLayers_list = []
#     sinrOffsetUciInPusch_list = []
#     with open(file_path, mode) as csv_file:
#         csv_data = csv.DictReader(f=csv_file)
#         for data in csv_data:
#             if data['rnti'] == rnti and data['numOfLayers'] != '':
#                 if (data["rrmUlProposedMcs"] != '') and (data["rrmUlProposedMcs"] != '255') and \
#                         (data["rrmUlProposedMcs"] != '0') and \
#                         (data["type"] == "ulFdSchedData") and (data["mcsTable"] == "QAM64LOWSE") and \
#                         (data["laMode"] == "HIGHRELIABILITY"):
#                     rrmUlProposedMcs_list.append(data["rrmUlProposedMcs"])
#                     reScaledCorrAvgSinrPreAtb_list.append(data["reScaledCorrAvgSinrPreAtb"])
#                     numOfLayers_list.append(data["numOfLayers"])
#                     sinrOffsetUciInPusch_list.append(data["sinrOffsetUciInPusch"])
#
#     return rrmUlProposedMcs_list, reScaledCorrAvgSinrPreAtb_list, numOfLayers_list, sinrOffsetUciInPusch_list


def get_related_value_on_direction_ul(file_path, rnti, mode="r"):
    rrmUlProposedMcs_list = []
    reScaledCorrAvgSinrPreAtb_list = []
    numOfLayers_list = []
    sinrOffsetUciInPusch_list = []
    with open(file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        for data in csv_data:
            if data['rnti'] == rnti and data['ulFdSchedData.numOfLayers'] != '':
                if (data["ulFdSchedData.rrmUlProposedMcs"] != '') and \
                        (data["ulFdSchedData.rrmUlProposedMcs"] != '255') and \
                        (data["ulFdSchedData.rrmUlProposedMcs"] != '0') and \
                        (data["ulFdSchedData.mcsTable"] == "QAM64LOWSE") and \
                        (data["ulFdSchedData.laMode"] == "HIGHRELIABILITY"):
                    rrmUlProposedMcs_list.append(data["ulFdSchedData.rrmUlProposedMcs"])
                    # reScaledCorrAvgSinrPreAtb_list.append(data["ulFdSchedData.ueData.reScaledCorrAvgSinrPreAtb"])
                    reScaledCorrAvgSinrPreAtb_list.append(data["ulFdSchedData.reScaledCorrAvgSinrPreAtb"])
                    numOfLayers_list.append(data["ulFdSchedData.numOfLayers"])
                    # sinrOffsetUciInPusch_list.append(data["ulFdSchedData.ueData.sinrOffsetUciInPusch"])
                    sinrOffsetUciInPusch_list.append(data["ulFdSchedData.sinrOffsetUciInPusch"])

    return rrmUlProposedMcs_list, reScaledCorrAvgSinrPreAtb_list, numOfLayers_list, sinrOffsetUciInPusch_list


def get_standard_values_on_direction_ul(rank1_file_path, rank2_file_path, mode="r", num_prb="8"):
    rank1_Mcs_list = []
    rank2_Mcs_list = []
    rank1_standard_value_list = []
    rank2_standard_value_list = []
    with open(rank1_file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        for data in csv_data:
            rank1_Mcs_list.append(data["MCS"])
            rank1_standard_value_list.append(data[num_prb])
    with open(rank2_file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        for data in csv_data:
            rank2_Mcs_list.append(data["MCS"])
            rank2_standard_value_list.append(data[num_prb])
    return rank1_Mcs_list, rank2_Mcs_list, rank1_standard_value_list, rank2_standard_value_list


def get_rank1_rank2_mapping(rank1_rank2_mcs_mapping, mode="r"):
    rank1_mcs = []
    rank2_mcs = []
    with open(rank1_rank2_mcs_mapping, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        for data in csv_data:
            rank1_mcs.append(data["Rank1"])
            rank2_mcs.append(data["Rank2"])
    rank1_rank2_mapping_dict = dict(zip(rank1_mcs, rank2_mcs))
    return rank1_rank2_mapping_dict


def check_values_on_direction_ul(file_path, rnti, rank1_file_path, rank2_file_path, rank1_rank2_mcs_mapping,
                                 num_prb="8"):
    """
    check values on direction ul
    rrmUlProposedMcs
    reScaledCorrAvgSinrPreAtb
    numOfLayers
    sinrOffsetUciInPusch
    1. get rrmUlProposedMcs reScaledCorrAvgSinrPreAtb numOfLayers sinrOffsetUciInPusch values from tti.csv
    2. get MCS-SINR mapping values from rank1.csv and rank2.csv
    3. as per numOfLayers to check reScaledCorrAvgSinrPreAtb-sinrOffsetUciInPusch
       value is in the range of MCS-SINR mapping values, then get msc value
    4. if numOfLayers is RANK1, then check rrmUlProposedMcs value of rank1.csv equal msc value which get from step 3
    5. if numOfLayers is RANK2, then check rrmUlProposedMcs value of rank2.csv equal msc value which get from step 3
    """
    rrmUlProposedMcs_list, al, numOfLayers_list, sl = get_related_value_on_direction_ul(file_path=file_path, rnti=rnti)
    rank1_Mcs_list, rank2_Mcs_list, r1, r2 = get_standard_values_on_direction_ul(rank1_file_path=rank1_file_path,
                                                                                 rank2_file_path=rank2_file_path,
                                                                                 num_prb=num_prb)
    rank1_rank2_mapping_dict = get_rank1_rank2_mapping(rank1_rank2_mcs_mapping=rank1_rank2_mcs_mapping)
    total_num = len(numOfLayers_list)
    diff_value = [eval(value) - eval(sl[index]) for index, value in enumerate(al)]
    switch_point = False
    for index, sinr in enumerate(diff_value):
        if switch_point is False:
            if total_num - 1 != index:
                if numOfLayers_list[index] == numOfLayers_list[index + 1]:
                    if numOfLayers_list[index] == "RANK1":
                        for i, mcs in enumerate(rank1_Mcs_list):
                            if i != len(r1) - 1:
                                if eval(r1[i]) <= sinr < eval(r1[i + 1]):
                                    print(f"{eval(r1[i])} <= {str(sinr)} < {eval(r1[i + 1])}")
                                    print(f"{rrmUlProposedMcs_list[index]} == {mcs}")
                                    assert int(float(rrmUlProposedMcs_list[index])) == int(mcs)
                                    break
                            else:
                                if eval(r1[i]) <= sinr:
                                    print(f"{eval(r1[i])} <= {str(sinr)}")
                                    print(f"{rrmUlProposedMcs_list[index]} == {mcs}")
                                    assert int(float(rrmUlProposedMcs_list[index])) == int(mcs)
                                    break
                    elif numOfLayers_list[index] == "RANK2":
                        for i, mcs in enumerate(rank2_Mcs_list):
                            if i != len(r2) - 1:
                                if eval(r2[i]) <= sinr < eval(r2[i + 1]):
                                    print(f"{eval(r2[i])} <= {str(sinr)} < {eval(r2[i + 1])}")
                                    print(f"{rrmUlProposedMcs_list[index]} == {mcs}")
                                    assert int(float(rrmUlProposedMcs_list[index])) == int(mcs)
                                    break
                            else:
                                if eval(r2[i]) <= sinr:
                                    print(f"{eval(r2[i])} <= {str(sinr)}")
                                    print(f"{rrmUlProposedMcs_list[index]} == {mcs}")
                                    if int(float(rrmUlProposedMcs_list[index])) != 255.0:
                                        assert int(float(rrmUlProposedMcs_list[index])) == int(mcs)
                                    break
                elif numOfLayers_list[index] != numOfLayers_list[index + 1]:
                    if numOfLayers_list[index] == "RANK1":
                        for i, mcs in enumerate(rank1_Mcs_list):
                            if i != len(r1) - 1:
                                if eval(r1[i]) <= diff_value[index + 1] < eval(r1[i + 1]):
                                    print(f"{eval(r1[i])} <= {str(diff_value[index + 1])} < {eval(r1[i + 1])}")
                                    print(f"{rrmUlProposedMcs_list[index + 1]} == {rank1_rank2_mapping_dict[mcs]}")
                                    assert rrmUlProposedMcs_list[index + 1] == rank1_rank2_mapping_dict[mcs]
                                    switch_point = True
                                    break
                            else:
                                if eval(r1[i]) <= sinr:
                                    print(f"{eval(r1[i])} <= {str(sinr)}")
                                    print(f"{rrmUlProposedMcs_list[index + 1]} == {mcs}")
                                    assert rrmUlProposedMcs_list[index + 1] == mcs
                                    switch_point = True
                                    break
                    elif numOfLayers_list[index] == "RANK2":
                        for i, mcs in enumerate(rank2_Mcs_list):
                            if i != len(r2) - 1:
                                if eval(r2[i]) <= diff_value[index + 1] < eval(r2[i + 1]):
                                    print(f"{eval(r2[i])} <= {str(diff_value[index + 1])} < {eval(r2[i + 1])}")
                                    print(f"{rrmUlProposedMcs_list[index + 1]} == {mcs}")
                                    assert rrmUlProposedMcs_list[index + 1] == mcs
                                    switch_point = True
                                    break
                            else:
                                if eval(r2[i]) <= sinr:
                                    print(f"{eval(r2[i])} <= {str(sinr)}")
                                    print(f"{rrmUlProposedMcs_list[index + 1]} == {mcs}")
                                    assert rrmUlProposedMcs_list[index + 1] == mcs
                                    switch_point = True
                                    break
            else:
                if numOfLayers_list[index] == "RANK1":
                    for i, mcs in enumerate(rank1_Mcs_list):
                        if i != len(r1) - 1:
                            if eval(r1[i]) <= sinr < eval(r1[i + 1]):
                                print(f"{eval(r1[i])} <= {str(sinr)} < {eval(r1[i + 1])}")
                                print(f"{rrmUlProposedMcs_list[index]} == {mcs}")
                                assert int(float(rrmUlProposedMcs_list[index])) == int(mcs)
                                break
                        else:
                            if eval(r1[i]) <= sinr:
                                print(f"{eval(r1[i])} <= {str(sinr)}")
                                print(f"{rrmUlProposedMcs_list[index]} == {mcs}")
                                assert int(float(rrmUlProposedMcs_list[index])) == int(mcs)
                                break
                elif numOfLayers_list[index] == "RANK2":
                    for i, mcs in enumerate(rank2_Mcs_list):
                        if i != len(r2) - 1:
                            if eval(r2[i]) <= sinr < eval(r2[i + 1]):
                                print(f"{eval(r2[i])} <= {str(sinr)} < {eval(r2[i + 1])}")
                                print(f"{rrmUlProposedMcs_list[index]} == {mcs}")
                                assert int(float(rrmUlProposedMcs_list[index])) == int(mcs)
                                break
                        else:
                            if eval(r2[i]) <= sinr:
                                print(f"{eval(r2[i])} <= {str(sinr)}")
                                print(f"{rrmUlProposedMcs_list[index]} == {mcs}")
                                assert int(float(rrmUlProposedMcs_list[index])) == int(mcs)
                                break
        else:
            switch_point = False


def check_release_year(release_info):
    release_year = release_info.split("_")[0][4:].split("R")[0]
    return int(release_year)


def convert_to_json_file(data, json_path):
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
