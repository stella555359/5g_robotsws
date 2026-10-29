# -*- coding: utf-8 -*-
import os
import io
import paramiko
import csv
import glob
import time
import re


def get_specified_column_from_csv_file(filename, linename):
    """This creates a keyword named "Read a column from CSV File"

    This keyword takes 2 arguments, which are a path to a .csv file and list name. It
    returns a list of column and remove empty string.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        column = [row[linename] for row in reader]
        column_new = [i for i in column if i != '']
    return column_new


def combine_multi_csv_files(path):
    combined_file_path = os.path.join(path, 'combined_result.csv')
    csvx_list = os.listdir(path)
    time.sleep(2)
    for csv_name in csvx_list:
        file_path = os.path.join(path, csv_name)
        f_obj = open(file_path, 'r')
        try:
            csv_content = f_obj.read()
        finally:
            f_obj.close()
        with open(combined_file_path, 'a') as f:
            f.write(csv_content)
    time.sleep(10)
    return combined_file_path


def get_specified_column_from_csv_file_for_rnti(filename, linename):
    """This creates a keyword named "Read a column from CSV File"

    This keyword takes 2 arguments, which are a path to a .csv file and list name. It
    returns a list of column and remove empty string.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        row_dict = dict()
        for row in reader:
            if row['rnti'] != '0' and row['rnti'] != '65535' and row[linename] != '':
                row_dict.setdefault(row['rnti'], []).append(row[linename])
        print(row_dict)
    return row_dict


def get_rnti_from_csv_file(filename):
    """This creates a keyword named "Read a column from CSV File"

    This keyword takes 2 arguments, which are a path to a .csv file and list name. It
    returns a list of column and remove empty string.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        column = [row['rnti'] for row in reader]
        column_rnti = set(column)
        if '0' in column_rnti:
            column_rnti.remove('0')
        if '65535' in column_rnti:
            column_rnti.remove('65535')
    for i in column_rnti.copy():
        count_result = column.count(i)
        if count_result < 20:
            column_rnti.remove(i)
    return list(column_rnti)


def count_Eligible_UE_and_non_Eligible_UE(buffer_list, mcs_list, rank_list, startPrb_list, numprb_list, Params_list):
    buffer_list_new = list(map(float, buffer_list))
    mcs_list_new = list(map(float, mcs_list))
    rank_list_new = list(map(float, rank_list))
    startPrb_list_new = list(map(float, startPrb_list))
    numprb_list_new = list(map(float, numprb_list))
    slot_all_UE = len(buffer_list)
    UE_startprb = list()
    UE_numprb = list()
    TTIresult_dist = dict()
    for i in range(slot_all_UE):
        if (buffer_list_new[i] > float(Params_list[0]) and mcs_list_new[i] >= float(Params_list[5])
                and mcs_list_new[i] <= float(Params_list[1]) and rank_list_new[i] >= float(Params_list[3])):
            UE_startprb.append(int(startPrb_list_new[i]))
            UE_numprb.append(int(numprb_list_new[i]))
    startprb_dist = dict()
    startprb_dist['max'] = max(UE_startprb)
    startprb_dist['min'] = min(UE_startprb)
    numprb_dist = dict()
    numprb_dist['max'] = max(UE_numprb)
    numprb_dist['min'] = min(UE_numprb)
    TTIresult_dist['slot_all'] = slot_all_UE
    TTIresult_dist['slot_eligible'] = len(UE_startprb)
    TTIresult_dist['startprb'] = startprb_dist
    TTIresult_dist['numprb'] = numprb_dist
    return TTIresult_dist


def set_numoflayers_from_str_to_num(rank_list):
    layer = [i.replace('RANK', '') for i in rank_list]
    return layer
