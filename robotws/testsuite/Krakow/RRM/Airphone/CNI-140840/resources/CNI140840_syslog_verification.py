"""
:author: Dawid Chuchnowski  <dawid.chuchnowski@nokia.com>
:maintainer: Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
"""
import os
import re
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

OUTPUT_DIR = BuiltIn().get_variable_value("${OUTPUT_DIR}")


def load_syslog(syslog_path):
    """
    Verifies that syslog is collected and loads it
    :param syslog_path: path to syslog
    :return syslog_lines: list of syslog lines
    """
    logger.info(f"Syslog path: {syslog_path}")
    assert os.path.exists(syslog_path), "Syslog is not collected"
    with open(syslog_path, 'r') as syslog:
        syslog_lines = syslog.readlines()
    return syslog_lines


def filter_syslog(syslog_lines, pattern):
    """
    Filters syslog list elements containing given pattern
    :param syslog_lines: syslog loaded to list
    :param pattern: pattern to be searched in syslog lines
    :return list: list of syslog line containing pattern
    """
    return [line for line in syslog_lines if pattern in line]


def get_line_timestamp_in_sec(line):
    """Converts syslog line timestamp to seconds

    Sample 26.09 08:54:51.336346
    :param line: syslog line (str)
    :return int: timestamp converted to seconds
    """

    timestamp_pattern = re.compile(r"(\d{2}):(\d{2}):(\d{2})")
    match = timestamp_pattern.search(line)
    hour, minute, second = match.groups()
    return int(hour) * 3600 + int(minute) * 60 + int(second)


def verify_invalid_antenna_RSSI_and_noise_values_error_messages_in_syslog(num_of_cells, consecutive_occurrences):
    """
    Verifies number and interval of error prints for consecutive invalid RSSI/Noise measurements

    :param num_of_cells: number of cells to be checked, starting from 1
    :param consecutive_occurrences: number of consecutive invalid measurements occurrences set by
                                    0x580254 #rdNumConsecutiveInvalidFakeUeMeas
    """
    syslog_lines = load_syslog(f"{OUTPUT_DIR}/GNB_syslog.txt")
    filtered_syslog = filter_syslog(syslog_lines, f"{consecutive_occurrences} consecutive invalid measurements")
    if not filtered_syslog:
        # SBTS26R1 filter
        filtered_syslog = filter_syslog(syslog_lines, f"Invalid value (10 aW) detected consecutively "
                                                      f"{consecutive_occurrences} times")
    assert len(filtered_syslog) > 0, "No error messages about consecutive invalid fake UEs' measurements in syslog"
    cell_err_numbers = []
    for cell in range(int(num_of_cells)):
        cell_err_prints = filter_syslog(filtered_syslog, f"subcellId:{cell}")
        cell_err_prints_number = len(cell_err_prints)
        cell_err_numbers.append(cell_err_prints_number)
        logger.info(f"Total prints found for Cell-{cell + 1}: {cell_err_prints_number}")
        duration = get_line_timestamp_in_sec(cell_err_prints[-1]) - get_line_timestamp_in_sec(cell_err_prints[0])
        average_print_interval = duration / cell_err_prints_number
        logger.info(f"Average print interval for Cell-{cell + 1}: {average_print_interval:.2f} s")
        assert 0.95 < average_print_interval, "Error prints occur more frequently than every second (100SFNs)"

    spread = max(cell_err_numbers) - min(cell_err_numbers)
    assert spread < 50, (f'There is significant difference ({spread}) in number of reported error logs between cells. '
                         f'Check log.html')
