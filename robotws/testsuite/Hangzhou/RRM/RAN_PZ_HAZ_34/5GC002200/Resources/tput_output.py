# -*- coding: utf-8 -*

import csv
import os


__all__ = [
    "create_new_file_csv",
    "write_tput_into_csv"
]


def create_new_file_csv(csv_file_path):
    path = csv_file_path
    with open(path, 'a+') as f:
        csv_write = csv.writer(f)
        csv_head = ["vertical", "horizontal", "tput"]
        csv_write.writerow(csv_head)


def write_tput_into_csv(csv_file_path, value1, value2, value3):
    path = csv_file_path
    with open(path, 'a+') as f:
        csv_write = csv.writer(f)
        data_row = [value1, value2, value3]
        csv_write.writerow(data_row)
