# coding:utf-8
import csv
import logging


def get_csv_dedicated_line(file_path, key_start):
    with open(file_path, "r") as fp:
        ins_lines = csv.DictReader(fp)
        for content in ins_lines:
            logging.info(content)
            if content['key'] == key_start:
                return content
    return {}
