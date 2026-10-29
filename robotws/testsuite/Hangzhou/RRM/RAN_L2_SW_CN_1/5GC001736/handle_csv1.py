# -*- coding: utf-8 -*-
"""
:created on: 6-22-2017

:copyright: Nokia
:author: liu qi
:contact: qi.e.liu@alcatel-sbell.com.cn
"""

import re
import csv


class CsvHandler(object):
    """find value in .csv file
    """

    def __init__(self, file_path, title):
        self.csv_file = file_path
        self.csv_raw_list = []
        # for valid line list
        self.valid_line_list = []
        # index title line keyword
        self.title = title
        # title name list
        self.title_list = []

        with open(self.csv_file, 'r') as file_object:
            content = csv.reader(file_object)
            for con in content:
                self.csv_raw_list.append(con)

    def null_list(self, check_list):
        """to judge if a list is null
        """
        return (check_list == []) or len(set(check_list)) == 1

    def get_valid_line_lists(self):
        """to get the valid line lists
        """
        title_line_num = 0
        for line_index in range(len(self.csv_raw_list)):
            if self.title in self.csv_raw_list[line_index]:
                self.title_list = self.csv_raw_list[line_index]
                title_line_num = line_index
                break
        for line_index in range(title_line_num + 1, len(self.csv_raw_list)):
            line_info = self.csv_raw_list[line_index]
            if not self.null_list(line_info):
                self.valid_line_list.append(line_info)

    def get_csv_columns_list(self, *cared_title):
        """to get the columns with the cared titles
        """
        csv_columns_list = []
        self.get_valid_line_lists()
        for title in cared_title:
            if title not in self.title_list:
                raise Exception("Title '%s' cann't be find." % title)
            else:
                column_pos = self.title_list.index(title)
                column_list = []
                for valid in self.valid_line_list:
                    value = valid[column_pos].strip()
                    if re.match(r'^\d+$', value):
                        value = int(value)
                    elif re.match(r'^\d+.\d+$', value):
                        value = float(value)
                    column_list.append(value)
                csv_columns_list.append(column_list)

        result_list = [csv_columns_list, csv_columns_list[0]][len(csv_columns_list) == 1]
        return result_list


def read_csv_columns(source_file, *cared_title, **kwargs):
    cc = CsvHandler(source_file, cared_title[0])
    return cc.get_csv_columns_list(*cared_title)


if __name__ == '__main__':
    pass
