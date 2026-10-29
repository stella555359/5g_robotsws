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


def list_file_with_extension(path, extension=".zip"):
    """List file under given path with desired extension.

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters | Man. | Description |
    | path       | Yes  | path to be scanned |
    | extension  | no  | file extension, it can be .zip, .txt, .log etc,  default is .zip |

    *RETURN VALUE*
    File list with desired extension,  eg.
    [['a.zip', 'b.zip'], ['/temp/a.zip', '/temp/abc/b.zip']]

    Example
    | ${file_list} | ${full_file_path_list}  | list_file_with_extension | /temp | extension=.zip |
    """
    rtn_filename = []
    rtn_full_filename = []
    if not os.path.isdir(path):
        print("Directory {} does not exist!")
        return rtn

    for root, dirs_list, files_list in os.walk(path):
        for file_name in files_list:
            if os.path.splitext(file_name)[-1] == extension:
                file_name_path = os.path.join(root, file_name)
                rtn_filename.append(file_name)
                rtn_full_filename.append(file_name_path)

    return [rtn_filename, rtn_full_filename]


def delete_unexpect_rnti_row(csvFile_name, target_csv_file, column_filter):
    with open(csvFile_name, 'r') as source_df, open(target_csv_file, 'w') as target_df:
        source_df = csv.DictReader(source_df)
        target_df = csv.DictWriter(target_df, fieldnames=source_df.fieldnames)
        target_df.writeheader()
        flag = 0
        if 'ulFdSchedData.rrmBufferedDataUlTotal_bytes' in source_df.fieldnames:
            for row in source_df:
                if row['ulFdSchedData.rrmBufferedDataUlTotal_bytes'] != '0':
                    flag = 1
                    break
        print(flag)
        for row in source_df:
            if flag == 0:
                if row['rnti'] != '65535' and row['rnti'] != '0' and row[column_filter] != '':
                    target_df.writerow(row)
            else:
                if row['rnti'] != '65535' and row['rnti'] != '0' and \
                        row['ulFdSchedData.rrmBufferedDataUlTotal_bytes'] != '0.0' and row[column_filter] != '':
                    target_df.writerow(row)
