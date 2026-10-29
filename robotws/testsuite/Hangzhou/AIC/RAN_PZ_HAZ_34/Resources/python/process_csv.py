# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Contacts: renhui-david.liu@nokia-sbell.com
Description: this script is used to read and analyze a csv file
"""

import csv
import re
import operator as opt


def filter_rows_with_conditions_from_csv_file(file_path, comparison_conditions, row_count=10):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get required rows meeting multiple comparison conditions in the same time.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - file_path: the csv file path
        - comparison_conditions: [["column_name_1", "operator 1", comparison_value_1],
                                  ["column_name_2", "operator 2", comparison_value_2] ...]
        - row_count: *return matching rows of up to row_count* in order to prevent huge data in the robot html
    *Returns:*
        - matching_rows: [row_1, row_2, ...]
        - row_nums: ["matching rows' numbers are", row_num_1, row_num_2, ...]
    *supporting operators:*
        - >, >=
        - <, <=
        - ==, !=
        - in
    *Example:*
        - filter_rows_with_conditions_from_csv_file(csv_file_path,
          [["dlFdSchedData.numOfLayers", "==", "RANK2"]])
        - filter_rows_with_conditions_from_csv_file(csv_file_path,
          [["dlFdSchedData.txNumber", "==", 2], ["dlFdSchedData.numOf5qi1Prb", ">", 0],
          ["dlFdSchedData.numOfPrb", "==", 32]])
        - filter_rows_with_conditions_from_csv_file(csv_file_path,
          [["slot", "in", [1, 2, 3, 4, 5, 6]]])
        - filter_rows_with_conditions_from_csv_file(csv_file_path,
          [["dlPagingOrSibSchedData.numOfLayers", "in", ["RANK1", "RANK2"]]])
     """
    matching_rows = []
    row_nums = ["matching rows' numbers are"]
    condition_length = len(comparison_conditions)
    column_names = get_column_names_from_comparison_conditions(comparison_conditions)
    if condition_length == 0:
        raise ComparisonConditionsNullError()
    make_sure_operator_in_comparison_value_is_list(comparison_conditions)
    with open(file_path, 'rt') as csv_file:
        reader = csv.DictReader(csv_file)
        index_row = 2
        for row in reader:
            for index_condition, condition in enumerate(comparison_conditions):
                column_name, operator, comparison_value = condition
                operation = get_matching_operation(operator)
                csv_value = row[column_name]
                if not csv_value:
                    break
                if operation(convert_data_type(csv_value), convert_data_type(comparison_value)):
                    if index_condition == condition_length - 1:
                        matching_rows.append({name: row[name] for name in column_names})
                        row_nums.append(index_row)
                    else:
                        continue
                else:
                    break
            index_row = index_row + 1
    if len(matching_rows) < row_count:
        return matching_rows, row_nums
    else:
        if matching_rows and row_nums:
            return matching_rows[:row_count], row_nums[:row_count + 1]


def get_a_column_with_column_name_from_csv_file(file_path, column_name):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get a column by the column name from a csv file.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - file_path: the csv file path
        - column_name: the column name
    *Returns:*
        - column: a list of values in the column
    *Example:*
        - get_a_column_with_column_name_from_csv_file(file_path, "dlFdSchedData.numOfLayers")
     """
    with open(file_path, 'rt') as csv_file:
        reader = csv.DictReader(csv_file)
        column = [row[column_name] for row in reader]
    return column


def get_matching_operation(operator):
    """
    *Usage:*
        - used to get matching operation.
    *Args:*
        - operator: supporting operators: >, <, >=, <=, ==, !=
    *Returns:*
        - operation:
    *Example:*
        - get_matching_operation(">")
     """
    ops = {'>': opt.gt,
           '<': opt.lt,
           '>=': opt.ge,
           '<=': opt.le,
           '==': opt.eq,
           '!=': opt.ne,
           'in': is_in}
    return ops[operator]


def is_in(a, b):
    """
    *Usage:*
        - used to check if a is in b.
    *Args:*
        - a:
        - b:
    *Returns:*
        - bool type:
    *Example:*
        - is_in(1, [0, 1, 2, 3, 4, 5, 6])
     """
    return a in b


def get_column_names_from_comparison_conditions(comparison_conditions):
    """
    *Usage:*
        - used to get all the column names from the comparison condition.
    *Args:*
        - comparison_conditions: the comparison conditions
    *Returns:*
        - column_names:
    *Example:*
     """
    return [condition[0] for condition in comparison_conditions]


def convert_data_type(data):
    """
    *Usage:*
        - if parameter data is a string of numeric, convert it to int or float type.
        - if parameter data is a list, convert its numeric strings to int or float type.
    *Args:*
        - data:
    *Returns:*
        - converted_data:
    *Example:*
        - convert_data_type(data)
     """
    if type(data) is list:
        converted_data = convert_list_data_type(data)
    else:
        converted_data = convert_numeric_str_data_type(data)
    return converted_data


def convert_numeric_str_data_type(csv_data):
    """
    *Usage:*
        - used to convert a string of numeric type to int or float type.
    *Args:*
        - csv_data: data got from a csv file
    *Returns:*
        - converted_data:
    *Example:*
        - convert_numeric_str_data_type(csv_data)
     """
    converted_data = csv_data
    if csv_data.lstrip('-+').isdigit():
        converted_data = int(csv_data)
    if re.match(r'^-?\d+\.\d+$', csv_data):
        converted_data = float(csv_data)
    return converted_data


def convert_list_data_type(lst):
    """
    *Usage:*
        - used to convert all the strings of numeric type in a list to int or float type .
    *Args:*
        - lst: type list
    *Returns:*
        - a list of converted data
    *Example:*
        - convert_list_data_type(sequence)
     """
    return [convert_data_type(e) for e in lst]


def make_sure_operator_in_comparison_value_is_list(comparison_conditions):
    """
    *Usage:*
        - used to make sure the operator in's comparison value is type list .
    *Args:*
        - comparison_conditions: [["column_name_1", "operator 1", comparison_value_1],
                                  ["column_name_2", "operator 2", comparison_value_2] ...]
    *Returns:*
        - bool type
    *Example:*
        - make_sure_operator_in_comparison_value_is_list(data)
     """
    comparison_values = [condition[2] for condition in comparison_conditions if condition[1] == "in"]
    for value in comparison_values:
        if type(value) is not list:
            raise OperatorINComparisonValueNotList()


class ComparisonConditionsNullError(Exception):
    """Exception raised when comparison_conditions is null.
    Attributes:
    """

    def __init__(self, message="comparison_conditions is null"):
        self.message = message
        super().__init__(self.message)


class OperatorINComparisonValueNotList(Exception):
    """Exception raised when the operator in's comparison value is not list.
    Attributes:
    """

    def __init__(self, message="The comparison value of operator in is not list"):
        self.message = message
        super().__init__(self.message)
