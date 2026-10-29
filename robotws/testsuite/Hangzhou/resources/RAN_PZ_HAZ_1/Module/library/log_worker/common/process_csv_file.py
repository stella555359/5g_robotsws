# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Contacts: renhui-david.liu@nokia-sbell.com
Description: this script is used to read and analyze a csv file
"""

import csv
import sys
import re
import operator as opt


def filter_csv_rows_using_and_conditions(file_path, comparison_conditions, csv_field_size=None):
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
        - csv_field_size: the csv's field size limit to set
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
    set_csv_field_size_limit(csv_field_size)
    matching_rows = []
    row_nums = ["matching rows' numbers are"]
    condition_length = len(comparison_conditions)
    column_names = get_column_names_from_comparison_conditions(comparison_conditions)
    if condition_length == 0:
        raise ComparisonConditionsNullError()
    make_sure_operator_in_comparison_value_is_list(comparison_conditions)
    with open(file_path, 'rt') as csv_file:
        dict_reader = csv.DictReader(csv_file)
        set_fieldnames(dict_reader, column_names)
        if dict_reader.fieldnames is None:
            raise CsvFIleNoComparisonColumnNamesError()
        for row in dict_reader:
            for index_condition, condition in enumerate(comparison_conditions):
                column_name, operator, comparison_value = condition
                operation = get_matching_operation(operator)
                csv_value = row[column_name]
                if not csv_value:
                    break
                if operation(convert_data_type(csv_value), convert_data_type(comparison_value)):
                    if index_condition == condition_length - 1:
                        matching_rows.append(row)
                        row_nums.append(dict_reader.line_num)
                    else:
                        continue
                else:
                    break
    return matching_rows, row_nums


def filter_csv_rows_using_or_conditions(file_path, comparison_conditions, csv_field_size=None):
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
        - csv_field_size: the csv's field size limit to set
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
    set_csv_field_size_limit(csv_field_size)
    matching_rows = []
    row_nums = ["matching rows' numbers are"]
    condition_length = len(comparison_conditions)
    column_names = get_column_names_from_comparison_conditions(comparison_conditions)
    if condition_length == 0:
        raise ComparisonConditionsNullError()
    make_sure_operator_in_comparison_value_is_list(comparison_conditions)
    with open(file_path, 'rt') as csv_file:
        dict_reader = csv.DictReader(csv_file)
        set_fieldnames(dict_reader, column_names)
        if dict_reader.fieldnames is None:
            raise CsvFIleNoComparisonColumnNamesError()
        for row in dict_reader:
            for index_condition, condition in enumerate(comparison_conditions):
                column_name, operator, comparison_value = condition
                operation = get_matching_operation(operator)
                csv_value = row[column_name]
                if not csv_value:
                    break
                if operation(convert_data_type(csv_value), convert_data_type(comparison_value)):
                    matching_rows.append(row)
                    row_nums.append(dict_reader.line_num)
                    break
    return matching_rows, row_nums


def check_statistics_using_and_conditions(matching_rows, statistics_rules):
    """
    *Usage:*
        - Keyword
        - This keyword is used to
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
     """
    results = [check_statistic(matching_rows, rule) for rule in statistics_rules]
    and_result = all(results)
    return and_result


def check_statistics_using_or_conditions(matching_rows, statistics_rules):
    """
    *Usage:*
        - Keyword
        - This keyword is used to
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
     """
    results = [check_statistic(matching_rows, rule) for rule in statistics_rules]
    or_result = any(results)
    return or_result


def check_statistic(matching_rows, statistics_rule):
    operation, key, comparison_operation, comparison_value = statistics_rule
    values = [float(item[key]) for item in matching_rows if key in item]

    if operation == 'max':
        result = max(values)
    elif operation == 'sum':
        result = sum(values)
    elif operation == 'average':
        result = sum(values) / len(values) if values else 0
    elif operation == 'min':
        result = min(values)
    else:
        raise Exception(f'Operation {operation} not supported')

    comparison_opt = get_matching_operation(comparison_operation)
    print(f"------ check_statistic result ------")
    print(f"{operation}({key}) = {result} {comparison_operation} {comparison_value}")
    return comparison_opt(result, float(comparison_value))


def filter_rows_with_conditions_from_csv_file(file_path, comparison_conditions, csv_field_size=None):
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
        - csv_field_size: the csv's field size limit to set
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
    set_csv_field_size_limit(csv_field_size)
    matching_rows = []
    row_nums = ["matching rows' numbers are"]
    condition_length = len(comparison_conditions)
    column_names = get_column_names_from_comparison_conditions(comparison_conditions)
    if condition_length == 0:
        raise ComparisonConditionsNullError()
    make_sure_operator_in_comparison_value_is_list(comparison_conditions)
    with open(file_path, 'rt') as csv_file:
        dict_reader = csv.DictReader(csv_file)
        set_fieldnames(dict_reader, column_names)
        if dict_reader.fieldnames is None:
            raise CsvFIleNoComparisonColumnNamesError()
        for row in dict_reader:
            for index_condition, condition in enumerate(comparison_conditions):
                column_name, operator, comparison_value = condition
                operation = get_matching_operation(operator)
                csv_value = row[column_name]
                if not csv_value:
                    break
                if operation(convert_data_type(csv_value), convert_data_type(comparison_value)):
                    if index_condition == condition_length - 1:
                        matching_rows.append({name: row[name] for name in column_names})
                        row_nums.append(dict_reader.line_num)
                    else:
                        continue
                else:
                    break
    return matching_rows, row_nums


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


def get_columns_from_csv_file(file_path, column_names, keep_empty_row=False):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get multiple columns by the column names from a csv file.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - file_path: the csv file path
        - column_names: the column names
        - keep_empty_row: (bool) if false, not keep a row with any empty column
    *Returns:*
        - columns: a dictionary containing multiple columns
    *Example:*
        - get_columns_from_csv_file(file_path, ["dlFdSchedData.numOfLayers", "slot"])
     """
    columns = {}
    for name in column_names:
        columns[name] = []
    with open(file_path, 'rt') as csv_file:
        reader = csv.DictReader(csv_file)
        set_fieldnames(reader, column_names)
        for row in reader:
            if not keep_empty_row:
                column = [row[name] for name in column_names]
                if '' in column:
                    continue
            for name in column_names:
                columns[name].append(row[name])
    return columns


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


def set_fieldnames(dict_reader, column_names):
    """
    *Usage:*
        - used to set the fieldnames for a DictReader object according to testers' comparison conditions.
        - if the fieldnames for a csv file do not match the column names in testers' comparison conditions,
            set the DictReader fieldnames to None.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - dict_reader: DictReader object
        - column_names: the column name from comparison conditions
    *Returns:*
        -
    *Example:*
        - set_fieldnames(dict_reader, comparison_column_names)
     """
    candidate_fieldnames = dict_reader.fieldnames
    is_contained = set(column_names).issubset(set(candidate_fieldnames))
    if not is_contained:
        dict_reader.fieldnames = None
    while not is_contained:
        try:
            candidate_fieldnames = next(dict_reader.reader)
            is_contained = set(column_names).issubset(set(candidate_fieldnames))
        except StopIteration:
            dict_reader.fieldnames = None
            break
        dict_reader.line_num = dict_reader.reader.line_num
        if is_contained:
            dict_reader.fieldnames = candidate_fieldnames


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
    if isinstance(csv_data, (int, float)):
        return csv_data
    csv_data = str(csv_data)
    if csv_data.lstrip('-+').isdigit():
        return int(csv_data)
    try:
        return float(csv_data)
    except ValueError:
        return csv_data


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


def set_csv_field_size_limit(size_limit=None):
    """
    *Usage:*
        - used to set csv's field size limit. The default limit is 131072 (128 kB).
    *Args:*
        - size_limit: the csv field size limit to set
    *Returns:*
    *Example:*
        - set_csv_field_size_limit(data)
     """
    if size_limit is None:
        max_size = sys.maxsize
        while True:
            # as long as the OverflowError occurs, decrease the max_size value by factor 10
            try:
                csv.field_size_limit(max_size)
                break
            except OverflowError:
                max_size = int(max_size / 10)
    else:
        csv.field_size_limit(int(size_limit))


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


class CsvFIleNoComparisonColumnNamesError(Exception):
    """Exception raised when the operator in's comparison value is not list.
    Attributes:
    """

    def __init__(self, message="The csv file has no comparison column names"):
        self.message = message
        super().__init__(self.message)
