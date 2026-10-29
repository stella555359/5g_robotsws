# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: He winnie
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""
from robot.api import logger
import csv
import os
import zipfile
import shutil
import re
import sys
maxInt = sys.maxsize
decrement = True
while decrement:
    decrement = False
    try:
        csv.field_size_limit(maxInt)
    except OverflowError:
        maxInt = int(maxInt / 10)
        decrement = True
# from numpy import empty


class csv_analysis(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        pass

    def __unzip(self, filepath):
        extract_dir = os.path.join(
            os.path.dirname(filepath),
            os.path.basename(filepath).split(".zip")[0])
        if os.path.exists(extract_dir):
            shutil.rmtree(extract_dir)
        os.makedirs(extract_dir)
        if zipfile.is_zipfile(filepath):
            with zipfile.ZipFile(filepath, 'r') as zipf:
                zipf.extractall(extract_dir)
        return extract_dir

    def __get_filepath_from_dir(self, dirpath):
        self.filepaths = []
        for root, dirs, files in os.walk(dirpath, topdown=False):
            for name in files:
                path = os.path.join(root, name)
                if path.endswith(".csv") and (f"{self.traffic_type}__" in path or
                                              f"_{self.traffic_type}" in path):
                    self.filepaths.append(os.path.join(dirpath, path))
        return self.filepaths[0]

    def prepare_csv_parser(self, filepath, traffic_type='dl', index_row=0):
        self.index_row = None
        self.traffic_type = traffic_type
        if os.path.basename(filepath).endswith(".zip"):
            unziped_dir = self.__unzip(filepath=filepath)
            self.filepath = self.__get_filepath_from_dir(dirpath=unziped_dir)
            ret_filepath = self.filepaths
        else:
            self.filepath = filepath
            ret_filepath = self.filepath
        self.__init__csv_parser()
        return ret_filepath

    def __init__csv_parser(self):
        file_obj = open(self.filepath)
        self.csv = csv.reader(file_obj)

    def filter_content_by_parameters(self, filter_parameter, filter_value,
                                     parameter, condition="=", index_row=0, support_empty_value=False,
                                     convert_to_float=True,
                                     filepath=None):
        if filepath is not None:
            self.filepath = filepath
            self.__init__csv_parser()
        i = 0
        filter_parameter_column = None
        filter_value = filter_value if isinstance(filter_value, list) else [filter_value]
        params = parameter if isinstance(parameter, list) else [parameter]
        params = [param for param in params]
        parameter_columns = {}
        ret_row = {}
        for row in self.csv:
            j = 0
            if i == index_row:
                self.index_row = row
                # start row
                for column in row:
                    if filter_parameter == column:
                        filter_parameter_column = j
                    if column in params:
                        parameter_columns[column] = j
                    j += 1
                if filter_parameter_column is None or len(
                        parameter_columns.keys()) != len(params):
                    raise ValueError(
                        "Can't find parameter {} or filter {}={} in this csv file {}".format(
                            parameter, filter_parameter, filter_value, self.filepath))
                else:
                    logger.info("Find the filter parameter column {} and parameter columns {}".format(
                        filter_parameter_column, parameter_columns))
            else:
                filter = False
                if row[filter_parameter_column] is not None and row[filter_parameter_column] != "":
                    if condition == "=":
                        condition = "=="
                    # logger.info(f"filter_value {row[filter_parameter_column]}")
                    for v in filter_value:
                        if isinstance(v, str) and re.match(r"\d+", v) is None:
                            if condition == "!=":
                                filter = str(row[filter_parameter_column]) != v
                            elif condition == "==":
                                filter = str(row[filter_parameter_column]) == v
                        else:
                            filter = eval(
                                "{}{}{}".format(
                                    row[filter_parameter_column],
                                    condition,
                                    v))
                        # logger.info(f"filter {filter}")
                        if filter:
                            for param in params:
                                if param not in ret_row.keys():
                                    ret_row[param] = []
                                if support_empty_value:
                                    if convert_to_float:
                                        ret_row[param].append(
                                            float(row[parameter_columns[param]]))
                                    else:
                                        ret_row[param].append(
                                            row[parameter_columns[param]])
                                else:

                                    if row[filter_parameter_column] != "":
                                        if convert_to_float:
                                            ret_row[param].append(
                                                float(row[parameter_columns[param]]))
                                        else:
                                            ret_row[param].append(
                                                row[parameter_columns[param]])
            i += 1
        logger.info(f"ret_row {ret_row}")
        if isinstance(parameter, str):
            if parameter.lower() in ret_row.keys():
                return ret_row[parameter.lower()]
            else:
                return ret_row[parameter]
        else:
            return ret_row

    def get_value_list_of_rows(self, values, formulae=None):
        if formulae.lower() == "sum":
            return eval("{}({})".format(formulae, values))
        elif formulae.lower() == "avg":
            if len(values) > 0:
                return (eval("sum({})".format(values)) / len(values))
            else:
                raise ("Can't calculate this value list, it is empty")
        elif ">=" in formulae.lower() or ">" in formulae.lower() or \
                "<=" in formulae.lower() or "<" in formulae.lower():
            return [eval("{}{}".format(value, formulae)) for value in values]

# if __name__ == '__main__':
#     c = csv_analysis()
#     c.prepare_csv_parser(filepath="emil_parser_output_20230721_080616.csv")
#     ret = c.filter_content_by_parameters(filter_parameter="Message name",
#     filter_value=["rrcReconfiguration"], parameter="Message body",
#     condition="==", support_empty_value=False,convert_to_float=False)
#     print(ret)
#     re.match
