"""
:copyright: Nokia Networks
:author: Mateusz Michalik
:maintainer:  Mateusz Michalik
:contact: mateusz.michalik@nokia.com
"""


import csv
import os
from datetime import datetime, timedelta
from robot.api import logger


def get_csv_list_of_dicts(file_path):
    """
    Reads a CSV file and returns a list of dictionaries, where each dictionary represents a row in the CSV file.

    :param file_path: The path to the CSV file to be read.
    :return: List of dictionaries representing the data from the CSV file. Each dictionary contains
                   column names as keys and corresponding values from the CSV file.
    """
    with open(file_path) as csvfile:
        csv_data = csvfile.readlines()
        csv_data[0] = rename_duplicates(csv_data[0])
    return list(csv.DictReader(csv_data))


def rename_duplicates(input_string):
    """
    Renames duplicate occurrences of words in a comma-separated input string by appending a count
    to the duplicate word.

    :param input_string: A comma-separated string where duplicates are to be renamed.
    :return: The input string with duplicate words renamed by appending a count to them.

    Example:
    Calling function:
    rename_duplicates('logicalChannelId,amountBytes,eTh,burstId,logicalChannelId,amountBytes,eTh,burstId')
    Would return:
    'logicalChannelId,amountBytes,eTh,burstId,logicalChannelId_2,amountBytes_2,eTh_2,burstId_2'
    """
    word_list = input_string.split(',')
    counts = {}
    for i, name in enumerate(word_list):
        if name in counts:
            counts[name] += 1
            word_list[i] = f"{name}_{counts[name]}"
        else:
            counts[name] = 1
    return ','.join(word_list)


def extract_data_based_on_column_names(csv_data, column_name_list):
    """
    Extracts data from a list of dictionaries based on specified column names.

    :param csv_data: List of dictionaries representing data from a CSV file.
    :param column_name_list: List of column names to extract from the data.
    :return: A list of dictionaries containing only the specified columns from the original data.
    """
    return [{key: item[key] for key in column_name_list} for item in csv_data]


def filter_by_base_criterion(csv_data):
    """
    Filters CSV data based on a set of base criteria:
    It checks each row (dictionary) in the CSV data and filters out rows that do not meet the following criteria:
            1. 'requestType' is 'EBUILDREQUEST'.
            2. 'sduNum' is greater than 1.
            3. 'burstId' is not empty and not equal to '65535'.
            4. 'logicalChannelId' is greater than or equal to 3 (after converting to an integer).

    :param csv_data: List of dictionaries representing CSV data.
    :return: Filtered data list based on the specified base criteria.
    """
    return list(filter(lambda row: (row['requestType'] == 'EBUILDREQUEST') & (int(row['sduNum']) > 1) &
                                   (row['burstId'] != '') & (row['burstId'] != '65535') &
                                   (int(float('0' + row['logicalChannelId']) >= 3)),
                       csv_data))


def filter_data_by_key_values(csv_data, **kwargs):
    """
    Filters data based on specified key-value pairs.

    :param csv_data: List of dictionaries representing data.
    :param kwargs: Key-value pairs for filtering.
    :return: List of dictionaries matching all specified key-value pairs.

    Example:
    filter_data_by_key_values(csv_data, physCellId=50, rnti=59080)
    """
    return list(filter(lambda row: all(row.get(key) == str(value) for key, value in kwargs.items()), csv_data))


def calculate_timestamp(dict_item, year, month):
    """
    Calculates the timestamp based on the provided dictionary item, year, and month.

    :param dict_item: Dictionary representing a row in the CSV file and containing keys:
                      'days', 'hours', 'minutes', 'seconds', 'microSeconds'.
    :param year: Year value for the timestamp.
    :param month: Month value for the timestamp.
    :return: Timestamp calculated from the provided row occurred time.
    """
    return datetime(
        year=year,
        month=month,
        day=int(dict_item['days']),
        hour=int(dict_item['hours']),
        minute=int(dict_item['minutes']),
        second=int(dict_item['seconds']),
        microsecond=int(dict_item['microSeconds'])
    ).timestamp()


def calculate_and_add_timestamp_column(csv_data_list, log_year, log_month, log_day):
    """
    Calculates and adds a timestamp column to the provided CSV data list based on the log date.

    :param csv_data_list: List of dictionaries representing CSV data rows.
    :param log_year: Year when last row occurred.
    :param log_month: Month when last row occurred.
    :param log_day: Day when last row occurred.
    :return: Updated CSV data list with the 'timestamp' column added.
    """
    log_datetime = datetime(log_year, log_month, log_day)
    yesterday_datetime = log_datetime - timedelta(days=1)
    outdated_log = False
    for item in csv_data_list:
        if int(item['days']) == int(log_datetime.day):
            item['timestamp'] = calculate_timestamp(item, log_datetime.year, log_datetime.month)
        elif int(item['days']) == int(yesterday_datetime.day):
            item['timestamp'] = calculate_timestamp(item, yesterday_datetime.year, yesterday_datetime.month)
        else:
            item['timestamp'] = None
            outdated_log = True

    if outdated_log:
        logger.warn('TTI log is outdated, please fill log_year, log_month, log_day during function call.\n')
        logger.warn('Timestamps are not available, burst duration is calculated based on slots.\n')

    return csv_data_list


def calculate_and_add_padding_column(csv_data_list):
    """
    Calculates and adds a 'padding' column to each item in the CSV data list.

    :param csv_data_list: A list of dictionaries representing CSV data rows.
    :return: The input CSV data list with a new 'padding' column added to each item.
             The 'padding' value represents the difference between 'tbSize' and 'amountBytes'.
    """
    for item in csv_data_list:
        item['padding'] = int(float('0' + item['tbSize'])) - int(float('0' + item['amountBytes']))
    return csv_data_list


def remove_wrong_lines_and_filter_data(csv_data, **kwargs):
    """
    Extracts data based on specified column names.
    Removes wrong lines based on each line check:
        1. 'requestType' is 'EBUILDREQUEST'.
        2. 'sduNum' is greater than 1.
        3. 'burstId' is not empty and not equal to '65535'.
        4. 'logicalChannelId' is greater than or equal to 3.
    Filters data based on specified key-value pairs, e.g. physCellId=50, rnti=59080.

    :param csv_data: List of dictionaries representing CSV data.
    :param kwargs: Key-value pairs for filtering, e.g. physCellId=50, rnti=59080.
    :return: Filtered data list containing specified columns and matching all specified key-value pairs.
    """

    main_columns = ['timestamp', 'padding', 'physCellId', 'sfn', 'slot', 'rnti', 'burstId',
                    'tbSize', 'amountBytes', 'logicalChannelId', 'requestType', 'sduNum', 'mcs', 'numOfRbs']
    basic_filtered_data = filter_by_base_criterion(extract_data_based_on_column_names(csv_data, main_columns))
    return filter_data_by_key_values(basic_filtered_data, **kwargs)


def group_by_keys(list_of_dicts, *group_by):
    """
    Groups a list of dictionaries by specified keys with defined value.

    :param list_of_dicts: List of dictionaries to be grouped.
    :param group_by: Keys based on which the dictionaries will be grouped.
    :return: A dictionary where keys are combinations of specified group_by keys, and values are lists of dictionaries
                 with matching key combinations.

    Example:
    Out of group_by_keys(filter_with_basic, 'logicalChannelId', 'burstId'):
    {'logicalChannelId_4_burstId_1': [
        {'timestamp': '1710173053', 'physCellId': '50', 'logicalChannelId': '4', 'burstId': '1' ...},
        {'timestamp': '1710173055', 'physCellId': '50', 'logicalChannelId': '4', 'burstId': '1' ...}
    ],
    'logicalChannelId_4_burstId_2': [
        {'timestamp': '1710173070', 'physCellId': '50', 'logicalChannelId': '4', 'burstId': '2' ...},
        {'timestamp': '1710173070', 'physCellId': '50', 'logicalChannelId': '4', 'burstId': '2' ...}
    ],
    'logicalChannelId_6_burstId_1': [
        {'timestamp': '1710173089', 'physCellId': '50', 'logicalChannelId': '6', 'burstId': '1' ...},
        {'timestamp': '1710173092', 'physCellId': '50', 'logicalChannelId': '6', 'burstId': '1' ...}
    ]}
    """
    grouped_dict = {}
    for item in list_of_dicts:
        key = '_'.join(['{}_{}'.format(key, item[key]) for key in group_by])
        grouped_dict.setdefault(key, []).append(item)
    return grouped_dict


def round_to_0_5(value):
    """
    Rounds the given value to the nearest 0.5.

    :param value: The value to be rounded.
    :return: The rounded value to the nearest 0.5.

    Examples:
        round_to_0_5(3.2) => 3.0
        round_to_0_5(4.7) => 4.5
        round_to_0_5(4.8) => 5.0
        round_to_0_5(5.0) => 5.0
        round_to_0_5(6.3) => 6.5
    """
    return round(value * 2) / 2


def get_sfn_cycle_times(list_of_rows_without_last):
    """
    Calculates the numbers of SFN cycle time occurrence in a list of rows (lists per burst ID).

    :param list_of_rows_without_last: A list of dictionaries representing rows of data without last element.
    :return: The numbers of SFN cycle time occurred.
    """
    if len(list_of_rows_without_last) > 1:
        sfn_cycle_times = sum(
            1 for i in range(len(list_of_rows_without_last) - 1) if
            int(list_of_rows_without_last[i]['sfn']) > int(list_of_rows_without_last[i + 1]['sfn'])
        )
    else:
        sfn_cycle_times = 0
    return sfn_cycle_times


def get_time_per_burst(list_of_rows, cell_type):
    """
    Calculates the time duration per burst.
    Function returns duration calculated on two methods: by timestamp and by frame and slots structure.

    Important:
        :var burst_duration is based on timestamp calculation by default.
        If timestamp was not found, the :var burst_duration is based on frame and slots structure!

    :param list_of_rows: A list of dictionaries representing rows of data per one burst.
    :param cell_type: The type of cell ('FR1_FDD' or 'FR1_TDD' or 'FR2_TDD').
    :return: Tuple containing the time durations per burst by timestamp and by frame and slots structure.
    """
    duplex_denominator = {'FR1_FDD': 1, 'FR1_TDD': 2, 'FR2_TDD': 8}
    if len(list_of_rows) > 1:
        sfn_cycle_time = get_sfn_cycle_times(list_of_rows)
        frame_burst_duration = (int(list_of_rows[-1]['sfn']) * 10 + 1024 * 10 * sfn_cycle_time +
                                (int(list_of_rows[-1]['slot']) + 1) / duplex_denominator[cell_type]) - \
                               (int(list_of_rows[0]['sfn']) * 10 + int(list_of_rows[0]['slot'])
                                / duplex_denominator[cell_type])

        start_timestamp = list_of_rows[0]['timestamp']
        stop_timestamp = list_of_rows[-1]['timestamp']
        if start_timestamp and stop_timestamp:
            burst_duration = round_to_0_5(
                (stop_timestamp - start_timestamp) * 1000 + 1 / duplex_denominator[cell_type]
            )
        else:
            burst_duration = frame_burst_duration

    else:
        burst_duration = frame_burst_duration = len(list_of_rows) / duplex_denominator[cell_type]

    return burst_duration, frame_burst_duration


def get_amount_bytes_per_burst(list_of_rows):
    """
    Calculates the amount of bytes per burst.

    :param list_of_rows: A list of dictionaries representing rows of data per burst.
    :return: The amount of bytes per burst.
    """
    padding_sdu_num = len([padding for padding in list_of_rows if padding['padding'] != 0])
    amount_bytes_col_sum = sum([int(float('0' + row['amountBytes'])) for row in list_of_rows])
    sdu_num_col_sum = sum([int('0' + row['sduNum']) for row in list_of_rows])
    return (amount_bytes_col_sum - 2.9 * (sdu_num_col_sum - padding_sdu_num)) * 8 / 1000
