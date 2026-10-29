"""
:copyright: Nokia Networks
:author: Kamil Bucki
:contact: kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import csv
import os
import logging
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console


def create_list_from_tti_trace_csv(direction, path_override=None):
    """
    Applicable for excelCsv format.

    :param direction:
    :param path_override:
    :return:
    """

    direction = direction.lower()
    output_dir = BuiltIn().get_variable_value("${OUTPUTDIR}")
    if path_override:
        csv_path = os.path.join(path_override, "output_{}.csv".format(direction))
        logger_console(csv_path)
    else:
        csv_path = os.path.join(output_dir, "TTItrace", "output_{}.csv".format(direction))
    logging.info("csv path is {}".format(csv_path))
    tti_trace = open(csv_path)
    csv_list = list(csv.reader(tti_trace))
    return csv_list


def create_list_from_column(tti_trace_list, column_name):
    """
    Applicable for excelCsv format.

    :param tti_trace_list:
    :param column_name:
    :return:
    """

    try:
        sr_column_index = tti_trace_list[0].index(column_name)
    except ValueError:
        raise ValueError("No such column {} in tti traces. Available columns are {}".format(column_name,
                                                                                            tti_trace_list[0]))
    list_from_single_column = [row[sr_column_index] for row in tti_trace_list[1:]]
    return list_from_single_column


def filter_out_tti_traces_with_value(tti_data, column, value):
    """
    Applicable for excelCsv format.

    :param tti_data:
    :param column:
    :param value:
    :return:
    """

    logger_console("Filtering out tti with value...  column:{}, value: {}".format(column, value))
    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] != value]
    return tti_traces_filtered


def filter_tti_traces_with_value_less_than(tti_data, column, value):
    """
    Applicable for excelCsv format.

    :param tti_data:
    :param column:
    :param value:
    :return:
    """

    logger_console("Filtering tti with value  less than...  column:{}, value: {}".format(column, value))
    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] < value]
    return tti_traces_filtered


def filter_tti_traces_with_value_greater_than(tti_data, column, value):
    """
    Applicable for excelCsv format.

    :param tti_data:
    :param column:
    :param value:
    :return:
    """

    logger_console("Filtering tti with value  greater than...  column:{}, value: {}".format(column, value))
    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] > value]
    return tti_traces_filtered


def filter_tti_traces_with_value_in_the_range(tti_data, column, min, max):
    """
    Applicable for excelCsv format.

    :param tti_data:
    :param column:
    :param min:
    :param max:
    :return:
    """

    logger_console("Filtering tti with value  in range...  column:{}, range: ({} {})".format(column, min, max))
    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if min <= row[column_index] <= max]
    return tti_traces_filtered


def filter_tti_traces_with_value_not_in(tti_data, column, values):
    """
    Applicable for excelCsv format.

    :param tti_data:
    :param column:
    :param values:
    :return:
    """

    logger_console("Filtering tti with value not in...  column:{}, value: {}".format(column, values))
    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] not in values]
    return tti_traces_filtered


def filter_tti_traces_with_value_in(tti_data, column, values):
    """
    Applicable for excelCsv format.

    :param tti_data:
    :param column:
    :param values:
    :return:
    """

    logger_console("Filtering tti with value in...  column:{}, value: {}".format(column, values))
    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] in values]
    return tti_traces_filtered


def filter_out_tti_traces_with_empty_columns(tti_data, columns, all_column=True):
    """
    Applicable for excelCsv format.

    :param tti_data:
    :param columns:
    :param all_column:
    :return:
    """

    logger_console("Filtering out tti with empty columns..."
                   "  columns_list:{}, all_column: {}".format(columns, all_column))
    columns_index = [tti_data[0].index(column) for column in columns]
    header = tti_data[0]
    content = tti_data[1:]
    tti_to_return = [header]

    for tti in content:
        counter_of_empty_column = 0
        for column_index in columns_index:
            if tti[column_index] == "":
                counter_of_empty_column = counter_of_empty_column + 1
        if counter_of_empty_column == 0:
            tti_to_return.append(tti)
        elif counter_of_empty_column != len(columns_index) and all_column is True:
            tti_to_return.append(tti)
    return tti_to_return


def filter_tti_traces_by_column_and_value(tti_data, column, value):
    """
    Applicable for excelCsv format.

    :param tti_data:
    :param column:
    :param value:
    :return:
    """

    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] == value]
    return tti_traces_filtered


def filter_out_tti_traces_with_different_values_than(tti_data, column, values):
    """
    Applicable for excelCsv format.

    :param tti_data:
    :param column:
    :param values:
    :return:
    """

    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] in values]
    return tti_traces_filtered
