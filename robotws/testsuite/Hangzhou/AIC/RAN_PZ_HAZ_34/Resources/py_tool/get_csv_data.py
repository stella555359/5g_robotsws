# -*- coding: utf-8 -*-


import os
import io
import paramiko
import csv
import glob
import time
import re


def read_csv_file(filename):
    """This creates a keyword named "Read CSV File"
    This keyword takes one argument, which is a path to a .csv file. It
    returns a list of rows, with each row being a list of the data in
    each column.
    """
    data = []
    with open(filename, 'rt') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            data.append(row)
    return data


def get_specified_column_from_csv_file(filename, linename):
    """This creates a keyword named "Read a column from CSV File"

    This keyword takes one argument, which is a path to a .csv file. It
    returns a list of column.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        column = [row[linename] for row in reader]
    return column


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


def check_whether_the_keyword_exists_in_csv(key_name, csvFile_name):
    flag = 0
    with open(csvFile_name, "r") as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            if flag == 1:
                break
            for i in range(len(row)):
                keyValue = re.findall(key_name, row[i])
                if keyValue != []:
                    flag = 1
                    break
    if flag == 0:
        return "non-exist"
    else:
        return "exist"
