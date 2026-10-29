# coding=utf-8
# Author: Abderrahmane NEZROUK
# @email: abderrahmane.nezrouk.nokia.com
#

import os


def merge_csv_files(csv_files, output_file_name):
    '''
    this function concatenate a list of csv files with the same headers.
    :param csv_files: list of csv file in absolute path
    :param output_file_name: string name of the output scv file
    :return: string the absolute csv file path output
    '''
    if bool(csv_files):
        file_path = csv_files[0]
        merged_csv_file = os.path.join(os.path.dirname(file_path), output_file_name)
        with open(merged_csv_file, "w") as merged_csv:
            with open(file_path, 'r') as csvfile:
                line = csvfile.readline()
                while bool(line) and '_ws.col.Info' not in line:
                    line = csvfile.readline()
                merged_csv.write(line)
                for line in csvfile:
                    merged_csv.write(line)

                for file_path in csv_files[1:]:
                    with open(file_path, 'r') as csvfile:
                        line = csvfile.readline()
                        while bool(line) and '_ws.col.Info' not in line:
                            line = csvfile.readline()
                        for line in csvfile:
                            merged_csv.write(line)
        return merged_csv_file
    return ''
