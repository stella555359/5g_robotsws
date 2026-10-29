import os
import csv
import re
import sys
from robot.api import logger


def read_pcmd_record(filename, record):
    """
    Searches parameters fields for the record in CSV file.

    :param filename: Path to CSV file with logs,
            e.g. "/home/ute/logs/dcap_logs/combined_result.csv"
    :param record: Name of the record from logs, e.g.
           CuCaConfigurationTraceRecord
    :return Message body with parameters assigned to record.
    """
    data = []
    with open(filename, 'rt') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            if row[1] == record:            # Second column in row is 'Message name'
                data.append(row[7])         # Eighth column in row is 'Message body'
    return data


def combine_multi_csv_files(path):
    """
    Combines multi CSV files to one file.

    :param path: Path to the folder with all CSV files to merge,
            e.g. "${LOG_PATH}/dcap_logs/CSV"
    :return Path to combined CSV file.
    """
    combined_file_path = os.path.join(path, 'combined_result.csv')
    csv_list = os.listdir(path)
    for csv_name in csv_list:
        file_path = os.path.join(path, csv_name)
        f_obj = open(file_path, 'r')
        try:
            csv_content = f_obj.read()
        finally:
            f_obj.close()
        with open(combined_file_path, 'a') as f:
            f.write(csv_content)
    return combined_file_path


def check_whether_the_keyword_exists_in_csv(csv_file_name, key_name):
    """
    Checks if keyword (record) exists in CSV file.

    :param csv_file_name: Path to CSV file with logs,
            e.g. "/home/ute/logs/dcap_logs/combined_result.csv"
    :param key_name: Name of the record from logs, e.g.
           CuCaConfigurationTraceRecord
    :return Boolean value defining if keyword (record) from key_name
                was found. True if any was found and False otherwise.
    """
    flag = 0
    with open(csv_file_name, "r") as csvfile:
        reader = csv.reader(csvfile)

        maxint = sys.maxsize
        while True:
            # decrease the maxInt value by factor 10
            # as long as the OverflowError occurs.
            try:
                csv.field_size_limit(maxint)
                break
            except OverflowError:
                maxint = int(maxint / 10)
                if maxint == 0:
                    raise Exception("Field size reached 0.")

        for row in reader:
            if flag == 1:
                break
            for i in range(len(row)):
                key_value = re.findall(key_name, row[i])
                if key_value != []:
                    flag = 1
                    break
    if flag == 0:
        return False
    else:
        return True


def rename_files(log_dir_path):
    """
    Renames lcbin files.

    :param log_dir_path: Path to CSV file with logs,
            e.g. "/home/ute/logs/dcap_logs/dcap_unzipped"
    :return New filename after renaming.
    """
    file_paths = [
        (root, file_name)
        for root, dirs, files in os.walk(log_dir_path)
        for file_name in files if file_name.endswith('.lcbin')
    ]
    i = 0
    for directory, filename in file_paths:
        i += 1
        new_filename = '/trace'+str(i)+'.bin.lcbin'
        os.rename(directory+'/'+filename, directory+'/'+new_filename)
        logger.debug(f"New name of the logs file: {new_filename}")


def check_timing_advance_records_periodicity(filename, record):
    """
    Checks if periodicity of the Timing Advance Trace Record is around 4s.

    :param filename: Path to CSV file with logs,
            e.g. "/home/ute/logs/dcap_logs/combined_result.csv"
    :param record: Name of the record from logs, e.g.
           CuCaConfigurationTraceRecord
    :return Boolean value defining if TA records periodicity is >= 4s and <= 5s.
            Then it is True, otherwise False.
    """
    periodic_list = []
    with open(filename, 'rt') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            if row[1] == record:
                if "periodic," in str(row[7]):
                    seconds = convert_time_to_seconds(row[6])
                    periodic_list.append(seconds)
            elif row[1] == 'DuCaConfigurationTraceRecord' and 'releasedSCells' in str(row[7]):
                break
    time_diff = check_time_diff_between_records(periodic_list)
    return time_diff


def convert_time_to_seconds(time_str):
    """
    Converts time between specific records to seconds.

    :param time_str: Time diff for record in string format HHHH:MM:SS.ffffff
    :return Time diff in seconds (float format)
    """
    time_parts = time_str.split(":")
    hours = int(time_parts[0])
    minutes = int(time_parts[1])
    seconds = float(time_parts[2])
    return seconds + minutes * 60 + hours * 3600


def check_time_diff_between_records(periodic_list):
    """
    Checks whether periodicity between records are greater than 4 and less than 5 seconds.

    :param periodic_list: List with time diff for selected record in seconds.
    :return Boolean value defining if records periodicity is >= 4s and <= 5s.
            Then it is True, otherwise False.
    """
    print(periodic_list)
    for i in range(len(periodic_list)-1):
        if 4 <= periodic_list[i + 1] - periodic_list[i] <= 5:
            continue
        else:
            return False
    return True


def check_records_periodicity(filename, record, cell_id_nrci_scell1, cell_id_nrci_scell2):
    """
    Checks if periodicity of the record is around 4s.

    :param filename: Path to CSV file with logs,
            e.g. "/home/ute/logs/dcap_logs/combined_result.csv"
    :param record: Name of the record from logs, e.g.
           CuCaConfigurationTraceRecord
    :param cell_id_nrci_scell1: SCell 1 Id NRCI
    :param cell_id_nrci_scell2: SCell 2 Id NRCI
    :return Boolean value defining if records periodicity is >= 4s and <= 5s.
            Then it is True, otherwise False.
    """
    periodic_list_cell1 = []
    periodic_list_cell2 = []
    with open(filename, 'rt') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            if row[1] == record:
                if cell_id_nrci_scell1 in str(row[7]):
                    seconds = convert_time_to_seconds(row[6])
                    periodic_list_cell1.append(seconds)
                elif cell_id_nrci_scell2 in str(row[7]):
                    seconds = convert_time_to_seconds(row[6])
                    periodic_list_cell2.append(seconds)
            elif row[1] == 'DuCaConfigurationTraceRecord' and 'releasedSCells' in str(row[7]):
                break
    time_diff_cell1 = check_time_diff_between_records(periodic_list_cell1)
    time_diff_cell2 = check_time_diff_between_records(periodic_list_cell2)
    return time_diff_cell1 and time_diff_cell2
