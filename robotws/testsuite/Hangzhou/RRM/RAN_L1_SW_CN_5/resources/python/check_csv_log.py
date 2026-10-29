# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Civen Chen
:contact: civen.chen@nokia.com
:maintainer: Civen Chen
:contact: civen.chen@nokia.com
"""

import csv
import re


__all__ = ['read_csv_file_into_matrix', 'get_cell_value', 'get_row_value_list', 'get_column_value_list',
           'check_cell_value', 'check_row_value', 'check_column_value', 'compare_csv_files',
           'count_expected_value', 'locate_row_in_csv', 'locate_column_in_csv', 'locate_value_in_csv',
           'check_keyvalue_exist', 'get_lines_with_column_filter', 'get_lines_with_multiple_column_filter',
           'get_key_value_when_other_column_matched', 'get_column_from_matrix', 'add_filters_to_matrix',
           'get_unique_values_in_column', 'add_filter_to_matrix_in_given_range']


def read_csv_file_into_matrix(file_path, delimiter=","):
    """
    read csv log file , split value by ",", and store all value into the matrix

    :param file_path: String: csv log file path.
    :param delimiter: String: the spliter to split values into cells.
    :return: The value matrix
    """
    with open(file_path) as csvfile:
        reader = csv.reader(csvfile, delimiter=str(delimiter))
        matrix = []
        line_number = 0
        for line in reader:
            if line:
                line_number += 1
                line_data = [line_number, line]
                matrix.append(line_data)
        return matrix


def get_cell_value(file_path, row, column, delimiter=","):
    """
    get target cell's value from csv log file

    :param file_path: String: csv log file path.
    :param row: Int: row number of target cell in the excel
    :param column: Int: column number of target cell in the excel
    :param delimiter: String: the spliter to split values into cells.
    :return: value in the target cell
    """
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    row = int(row) - 1
    column = int(column) - 1
    return matrix[row][1][column]


def get_row_value_list(file_path, row, delimiter=","):
    """
    get target row's value from csv log file and stored into the list.

    :param file_path: String: csv log file path.
    :param row: Int: row number in the excel
    :param delimiter: String: the spliter to split values into cells.
    :return: List: list of target row value
    """
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    row = int(row) - 1
    return matrix[row][1]


def get_column_value_list(file_path, column, delimiter=","):
    """
    get target column's value from csv log file and stored into the list.

    :param file_path: String: csv log file path.
    :param column: Int: column number(please use 123, not ABC) in the excel
    :param delimiter: String: the spliter to split values into cells.
    :return: List: list of target column value
    """
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    column = int(column) - 1
    column_list = []
    for row in matrix:
        column_list.append(row[1][column])
    return column_list


def check_cell_value(file_path, row, column, expected, delimiter=","):
    """
    get target cell's value from csv log file, and match it with given expected value.
    Fail if not matched.

    :param file_path: String: csv log file path.
    :param row: Int: row number of target cell in the excel
    :param column: Int: column number of target cell in the excel
    :param expected: String: Expected value of the cell.
    :param delimiter: String: the spliter to split values into cells.
    :return:
    """
    target_cell_value = get_cell_value(file_path=file_path, row=row, column=column, delimiter=delimiter)
    try:
        assert target_cell_value == expected
    except AssertionError:
        raise AssertionError("Cell value is {}, not match expected value {}".format(target_cell_value,
                                                                                    expected))


def check_row_value(file_path, row, expected, delimiter=","):
    """
    get target row's value from csv log file and match it with given expected value.
    Fail if not matched.

    :param file_path: String: csv log file path.
    :param row: Int: row number of target in the excel
    :param expected: List: Expected value of the row. must be list type value.
    :param delimiter: String: the spliter to split values into cells.
    :return:
    """
    target_row = get_row_value_list(file_path=file_path, row=row, delimiter=delimiter)
    if expected != target_row:
        length_expected = len(expected)
        length_target = len(target_row)
        if length_expected != length_target:
            raise AssertionError("Row length different.\nTarget row:{}\nExpected row:{}".format(
                length_target, length_expected)
            )
        else:
            for column_number in range(length_expected):
                if expected[column_number] != target_row[column_number]:
                    raise AssertionError(
                        "Diff at column:{} in csv, expected:{}, actually:{}".format(
                            (column_number + 1),
                            expected[column_number],
                            target_row[column_number])
                    )


def check_column_value(file_path, column, expected, delimiter=","):
    """
    get target column's value from csv log file and match it with given expected value.
    Fail if not matched.

    :param file_path: String: csv log file path.
    :param column: Int: column number of target in the excel
    :param expected: List: Expected value of the column. must be list type value.
    :param delimiter: String: the spliter to split values into cells.
    :return:
    """
    target_column = get_column_value_list(file_path=file_path, column=column, delimiter=delimiter)
    if expected != target_column:
        length_expected = len(expected)
        length_target = len(target_column)
        if length_expected != length_target:
            raise AssertionError("Column length different.\nTarget column:{}\nExpected column:{}".format(
                length_target, length_expected)
            )
        else:
            for row_number in range(length_expected):
                if expected[row_number] != target_column[row_number]:
                    raise AssertionError(
                        "Diff at row:{} in csv, expected:{}, actually:{}".format(
                            (row_number + 1),
                            expected[row_number],
                            target_column[row_number])
                    )


def compare_csv_files(first_file, second_file, mode="assert"):
    """
    Check whether given files' contents are same.

    :param first_file: String: csv log file path.
    :param second_file: String: csv log file path.
    :param mode: String: assert | return.
                assert: raise errors if files are different.
                return: return false if files are different.
    :return:
    """
    first_matrix = read_csv_file_into_matrix(file_path=first_file)
    second_matrix = read_csv_file_into_matrix(file_path=second_file)
    try:
        assert first_matrix == second_matrix
    except AssertionError:
        if mode == "assert":
            raise AssertionError("These two csv files are different.")
        elif mode == "return":
            return False
        else:
            raise AttributeError("Please input a correct mode: assert/return")


def count_expected_value(file_path, expected, delimiter=","):
    """
    Count how many expected value are matched in the target csv file.

    :param file_path: String: csv log file path.
    :param expected: String: Expected value that want to count in file.
    :param delimiter: String: the spliter to split values into cells.
    :return:
    """
    expected_count = 0
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    for row in matrix:
        expected_count += row[1].count(expected)
    if expected_count == 0:
        raise LookupError("Can't found expected value")
    return expected_count


def locate_row_in_csv(file_path, expected, delimiter=","):
    """
    try to match expected row, then return the row number that match the expected.

    :param file_path: String: csv log file path.
    :param expected: list: The list type value of the expected row elements.
    :param delimiter: String: the spliter to split values into cells.
    :return: a list of all matched row number.
    """
    result = []
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    for row_number in range(len(matrix)):
        if matrix[row_number][1] == expected:
            result.append(row_number + 1)
    if not result:
        raise LookupError("Can't found expected row.")
    return result


def locate_column_in_csv(file_path, expected, delimiter=","):
    """
    try to match expected column, then return the column number that match the expected.

    :param file_path: String: csv log file path.
    :param expected: list: The list type value of the expected column elements.
    :param delimiter: String: the spliter to split values into cells.
    :return: a list of all matched column number.
    """
    result = []
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    for column_number in range(len(matrix[0][1])):
        if matrix[0][1][column_number] == expected[0]:
            column = get_column_value_list(file_path=file_path,
                                           column=column_number)
            if column == expected:
                result.append(column_number + 1)
    if not result:
        raise LookupError("Can't found expected column")
    return result


def locate_value_in_csv(file_path, expected, delimiter=","):
    """
    try to match expected value, then return the coordinate of the cell that match the expected.

    :param file_path: String: csv log file path.
    :param expected: list: The list type value of the expected column elements.
    :param delimiter: String: the spliter to split values into cells.
    :return: a list of all matched cell's coordinate , the row and column will be a tuple.
    """
    result = []
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    for row_number in range(len(matrix)):
        for column_number in range(len(matrix[row_number][1])):
            if matrix[row_number][1][column_number] == expected:
                result.append((row_number + 1, column_number + 1))
    if not result:
        raise LookupError("Can't found expected value")
    return result


def check_keyvalue_exist(file_path, key, min_value=None, max_value=None):
    """
    get all value of the key in the csv file , and check whether one of the values
    can match the given scope.
    when only min value is given,  the scope will be min_value ~ infinity
    when only max value is given , the scope will be infinitesimal ~ max_value
    when both max and min are given, the scope will be min_value ~ max_value

    e.g:
    check_keyvalue_exist  |  file_path=trace.csv  |  key=mcs  |  min_value=1
    the mcs=1 or mcs=2 will sufficient.

    :param file_path: String: csv log file path.
    :param key: String: the key of the value , only used for equal type contents.
    :param min_value: Int: the minimum value of the key.
    :param max_value: Int: the maximum value of the key.
    :return:
    """
    expected_re = re.compile(r"{}=(\d+)".format(key))
    result = False
    with open(file_path) as cf:
        content = cf.read()
    results = expected_re.findall(content)
    for i in results:
        if min_value and max_value:
            if min_value <= int(i) <= max_value:
                result = True
                break
        elif min_value and not max_value:
            if min_value <= int(i):
                result = True
                break
        elif not min_value and max_value:
            if int(i) <= max_value:
                result = True
                break
    if not result:
        raise LookupError("Can't found value in scope by key")
    return result


def get_column_from_matrix(matrix, column_nubmer):
    """
    get target column from matrix

    :param matrix: List: the matrix
    :param column_nubmer: Int: the index of target column.
                         column number count start from 1.
    :return: List: target column
    """
    column = int(column_nubmer) - 1
    column_list = []
    for row in matrix:
        column_list.append(row[1][column])
    return column_list


def get_lines_with_column_filter(file_path, column_number, expected, delimiter=","):
    """
    get all lines that match the filter.

    :param file_path: String: csv log file path.
    :param column_number: Int: column number of target filter in the excel.
                         column number count start from 1.
    :param expected: String: Expected filter value.
    :param delimiter: String: the spliter to split values into cells.
    :return: List: content all lines match the filter.
    """
    result = []
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    for line in matrix:
        if line[1]:
            try:
                target = line[1][int(column_number) - 1]
                if expected == target:
                    result.append(line)
            except IndexError:
                continue
    if not result:
        raise LookupError("Can't found any line match expected.")
    return result


def get_lines_with_multiple_column_filter(file_path, column_list, expected_list, delimiter=","):
    """
    get all lines that match all filter.

    :param file_path: String: csv log file path.
    :param column_list: List: a list content all target filters' column number.
                         column number count start from 1.
    :param expected_list: List: a list content all filters, the sort should match with column_list
    :param delimiter: String: the spliter to split values into cells.
    :return: List: content all lines match the filter.
    """
    result = []
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    for line in matrix:
        if line[1]:
            for i in range(len(column_list)):
                try:
                    target = line[1][int(column_list[i]) - 1]
                    expected = expected_list[i]
                    if expected not in target:
                        break
                except IndexError:
                    continue
            else:
                result.append(line)
    if not result:
        raise LookupError("Can't found any line match all column expected.")
    return result


def get_key_value_when_other_column_matched(file_path, column_number, expected, key_column, key, delimiter=","):
    """

    :param file_path: String: csv log file path.
    :param column_number: Int: target filter's column number.
                         column number count start from 1.
    :param expected: String: Expected filter value.
    :param key_column: Int: the key value's column number
    :param key: String: the key
    :param delimiter: String: the spliter to split values into cells.
    :return: Dict: a dictionary, content the value of the key, match with line number.
    """
    result = {}
    get_value_re = re.compile(r"{}=\w*".format(key))
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    for line_num in range(len(matrix)):
        target = matrix[line_num][1][int(column_number) - 1]
        if expected == target:
            value = get_value_re.findall(matrix[line_num][1][int(key_column) - 1])[0]
            result.update({line_num + 1: value})
    if not result:
        raise LookupError("Can't found any line match all column expected.")
    return result


def add_filters_to_matrix(matrix, *args):
    """

    filters:
    A list content column number and list of filters at this column.
    Will check the target column match any one of the filters.
    [  "7" ,  ["START", "END", "FULL"]  ]

    example:
    ${csv_content}    read_csv_file_into_matrix    file_path=xxxx
    add_filters_to_matrix    ${csv_content}
    ...                      ${filter1}
    ...                      ${filter2}

    you may follow as much filter as you want , just need to ensure all
    filters syntax are correct.

    :param matrix: List: matrix type of csv file content
    :param args: Dict: dict type filters, key is the column number,
                      value is list type filters.
    :return:
    """
    result = []
    for line in matrix:
        if line[1]:
            for filter_list in args:
                column_number = int(filter_list[0]) - 1
                expected_list = filter_list[1]
                target = line[1][column_number]
                for expected in expected_list:
                    if expected == target:
                        break
                else:
                    break
            else:
                result.append(line)
    if not result:
        raise LookupError("Can't found any line match all column expected.")
    return result


def get_unique_values_in_column(matrix, column_number):
    """
    check the column and return a list ,
    which content all values in the column (already removed duplicate data)

    :param matrix: List: matrix type of csv file content
    :param column_number: target column's number
    :return: List: all unique values in target column
    """
    column = get_column_from_matrix(matrix, column_number)
    result = list(set(column))
    return result


def add_filter_to_matrix_in_given_range(matrix, start_line, end_line, *args):
    """
    start_line and end_line:
    these two parameters are used to limit the line number range.
    the line out of the limited range will be removed.
    will not limit if be given None value (in robot, ${None})
    e.g:
    start_line=80, end_line=None ->  line_number 80 ~ ∞
    start_line=None, end_line=500 -> line_number 1 ~ 500

    filters:
    A list content column number and list of filters at this column.
    Will check the target column match any one of the filters.
    [  "7" ,  ["START", "END", "FULL"]  ]

    example:
    ${csv_content}    read_csv_file_into_matrix    file_path=xxxx
    add_filters_to_matrix    ${csv_content} # matrix content with line_number
    ...                      8              # match from line number 8
    ...                      ${None}        # match will reach the last line.
    ...                      ${filter1}     # filters
    ...                      ${filter2}     # filters

    you may follow as much filter as you want , just need to ensure all
    filters syntax are correct.

    :param matrix: List: matrix type of csv file content
    :param start_line: Int: will remove lines before start line number.
    :param end_line: Int: will remove lines after end line number.
    :param args: Dict: dict type filters, key is the column number,
                      value is list type filters.
    :return:
    """
    result = []
    for line in matrix:
        if start_line:
            if line[0] < int(start_line):
                continue
        if end_line:
            if line[0] > int(end_line):
                continue
        if line[1]:
            for filter_list in args:
                column_number = int(filter_list[0]) - 1
                expected_list = filter_list[1]
                target = line[1][column_number]
                for expected in expected_list:
                    if expected == target:
                        break
                else:
                    break
            else:
                result.append(line)
    if not result:
        raise LookupError("Can't found any line match all column expected.")
    return result
