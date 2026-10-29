#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Dawid Chuchnowski  <dawid.chuchnowski@nokia.com>
:maintainer: Lukasz Klimowicz <lukasz.klimowicz@nokia.com>
"""

import csv
from robot.api import logger


class csv_verifiers:
    """

    """

    def __init__(self):
        self.csv_list = []

    def create_list_of_lists_from_csv(self, csv_path):
        """
        Convert csv to list of lists

        :param csv_path: path to csv file
        :return: list of lists
        """
        try:
            csv_file = open(csv_path)
        except IOError:
            raise Exception("CSV file {} not found".format(csv_path))

        csv_list = list(csv.reader(csv_file))
        assert len(csv_list) > 1, 'CSV file {} is empty'.format(csv_path)
        self.csv_list = csv_list
        return csv_list

    def get_column_values(self, input_list, column_name, unique_values=False):
        """
        Gets values from specified column

        :param input_list: input list
        :param column_name: column to be extracted
        :param unique_values: specify if all values/unique values should be included
        :return: list
        """
        column_index = self.get_index_for_column_name(column_name)
        single_column_list = [row[column_index] for row in input_list][1:]
        if unique_values:
            single_column_list_unique_values = list(set(single_column_list))
            return single_column_list_unique_values
        else:
            return single_column_list

    def print_column_names(self):
        """
        Prints column names to console and log.html

        :return: none
        """
        columns = "CSV column names:\n" + '\n'.join(self.csv_list[0])
        logger.info(msg=columns, also_console=True)

    def get_index_for_column_name(self, column_name):
        """
        Gets index of specified column

        :param column_name: name of column
        :return: int
        """
        try:
            column_index = self.csv_list[0].index(column_name)
        except ValueError:
            raise ValueError("No column named {}".format(column_name))
        return column_index

    def filter_csv_by_column_value(self, csv_list, column_name, condition, value):
        """
        Filters input list according to specified condition for selected column

        :param csv_list: input list to be filtered
        :param column_name: name of column
        :param condition: filter for column (one of '>', '>=', '<', '<=', '==', '!=')
        :param value: value to be filtered

        :return: filtered list of lists
        """
        assert condition in ['>', '>=', '<', '<=', '==', '!='], \
            'Incorrect condition "{}". Please choose one from ">, >=, <, <=, ==, !="'.format(condition)
        column_index = self.get_index_for_column_name(column_name)
        filtered_list = [row for row in csv_list[1:] if ((row[column_index] != '') and
                                                         eval('{} {} {}'.format(row[column_index], condition, value)))]
        filtered_list.insert(0, csv_list[0])
        assert len(filtered_list) > 1, "No results for filter: {} {} {}".format(column_name, condition, value)
        return filtered_list

    def filter_csv_by_column_multiple_values(self, csv_list, column_name, condition, values):
        """
        Filters input list by specified values for selected column

        :param csv_list: input list to be filtered
        :param column_name: name of column
        :param condition: filter for column (one of 'in' or 'not in')
        :param values: values to be filtered

        :return: filtered list of lists
        """
        assert condition in ['in', 'not in'], \
            'Incorrect condition "{}". Please choose one from "in" and "not in"'.format(condition)
        column_index = self.get_index_for_column_name(column_name)
        filtered_list = [row for row in csv_list[1:]
                         if ((row[column_index] != '')
                             and eval('{} {} {}'.format(row[column_index], condition, values)))]
        filtered_list.insert(0, csv_list[0])
        assert len(filtered_list) > 1, "No results for filter: {} {} {}".format(column_name, condition, values)
        return filtered_list

    def get_multiple_columns_values(self, *columns, input_list=None, as_dict=False, ignore_wrong_column=False):
        """
        Gets values from specified columns
        Parameters as_dict, ignore_wrong_column and input list should be provided as named arguments
         and before column names!
        :param input_list: list of parsed tti traces
        :param as_dict: defines if columns are presented as table (list of list) or dict where column names are the keys
        :param ignore_wrong_column: ignores errors when column with provided name does not exist in file
        :param columns: columns to be extracted (each column name as different argument, if column names are
         given as iterable object (e.g. list) please extract it first i.e. function(tti_traces, *list_of_column_names))
        :return: extracted columns [list or dict]
        Example:
        column_names = ('timeStamp', 'ulPucchReceiveReqData.pucchFormat')
        get_multiple_columns_values(*columns, input_list=csv_list, as_dict=True, ignore_wrong_column=False)
        or
        get_multiple_columns_values('timeStamp', 'ulPucchReceiveReqData.pucchFormat',
                                    input_list=csv_list, as_dict=True, ignore_wrong_column=False)
        Example output as list:
            Column names: timeStamp, ulPucchReceiveReqData.pucchFormat, ulPucchReceiveReqData.timeDomainOcc
            result: [['2023-07-20 13:06:36.085818', '2023-07-20 13:06:36.095876'], ['1.0', '3.0'], ['0.0', '0.0']]
        Example output as dict:
            Column names: timeStamp, ulPucchReceiveReqData.pucchFormat, ulPucchReceiveReqData.timeDomainOcc
            result: {'timeStamp': ['2023-07-20 13:06:36.085818', '2023-07-20 13:06:36.095876'],
                     'ulPucchReceiveReqData.pucchFormat': ['1.0', '3.0'],
                     'ulPucchReceiveReqData.timeDomainOcc' : ['0.0', '0.0']}
        """
        table = []
        dict_table = {}
        for column in columns:
            try:
                col = self.get_column_values(input_list, column_name=column)
                table.append(col)
                dict_table[column] = col
            except ValueError as msg:
                if not ignore_wrong_column:
                    raise ValueError(msg)
        if as_dict:
            return dict_table

        return table

    def get_multiple_columns_values_as_rows(self,  *columns, input_list=None, as_list=True, ignore_wrong_column=False):
        """
        Gets values from specified columns and parses data to rows
        :param columns: columns to be extracted (each column name as different argument, if column names are
         given as iterable object (e.g. list) please extract it first i.e. function(tti_traces, *list_of_column_names))
        :param input_list: list of parsed tti traces
        :param as_list: defines if rows are presented as list of lists or are returned as iterable object (zip)
        :param ignore_wrong_column: ignores errors when column with provided name does not exist in file
        :return table: extracted columns in form of rows [list or zip_object]
        Example:
        column_names = ('timeStamp', 'ulPucchReceiveReqData.pucchFormat')
        get_multiple_columns_values(*columns, input_list=csv_list, as_dict=True)
        or
        get_multiple_columns_values('timeStamp', 'ulPucchReceiveReqData.pucchFormat',
                                    input_list=csv_list, as_list=True)
        Example output:
            Column names: timeStamp, ulPucchReceiveReqData.pucchFormat, ulPucchReceiveReqData.timeDomainOcc
            result: [['2023-07-20 13:06:36.085818', '1.0', '0.0'], ['2023-07-20 13:06:36.095876', '3.0', '0.0']]
        """
        table = []
        for column in columns:
            try:
                table.append(self.get_column_values(input_list, column_name=column))
            except ValueError as msg:
                if not ignore_wrong_column:
                    raise ValueError(msg)

        table = zip(*table)
        if as_list:
            table = [list(row) for row in table]
        return table
