# -*- coding: utf-8 -*

import csv
import os


__all__ = [
    "create_new_csv_file",
    "write_data_into_csv",
    "write_kpi_value_into_csv"
]


def create_new_csv_file(csv_file_path):
    path = csv_file_path
    with open(path, 'a+') as f:
        csv_write = csv.writer(f)
        csv_head = ["title", "Release", "5QI1", "5QI2", "5QI3", "5QI4", "5QI5",
                    "5QI6", "5QI7", "5QI8", "5QI9", "5QI80", "5QI128", "5QI-avg"]
        csv_write.writerow(csv_head)


def write_data_into_csv(csv_file_path, case_name, release, value1, value2, value3,
                        value4, value5, value6, value7, value8, value9, value10, value11, value_avg):
    path = csv_file_path
    with open(path, 'a+') as f:
        csv_write = csv.writer(f)
        data_row = [case_name, release, value1, value2, value3, value4, value5, value6, value7,
                    value8, value9, value10, value11, value_avg]
        csv_write.writerow(data_row)


def write_kpi_value_into_csv(csv_file_path, kpi_name, release, kpi_value):
    path = csv_file_path
    with open(path, 'a+') as f:
        csv_write = csv.writer(f)
        data_row = [kpi_name, release, kpi_value]
        csv_write.writerow(data_row)
