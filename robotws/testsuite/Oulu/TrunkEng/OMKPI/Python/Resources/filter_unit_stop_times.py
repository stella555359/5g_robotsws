#!/usr/bin/env python3


"""Module providing functions to extract and filter unit stop times from log files."""
import io
import re
from collections import defaultdict
from datetime import datetime

long_durations_filename = "/tmp/long_durations.txt"
unit_stop_durations_filename = "/tmp/unit_stop_durations.txt"

# The log files are listed in reverse order becuase we start reading from latest (not erarliest) log file.
logfilenames = ["messages.gz", "messages.1.gz", "messages.2.gz", "messages.3.gz", "messages.4.gz", "messages.boot.gz"]

# Conditional import of Flatshot
if __name__ != "__main__":
    from flatshot import Flatshot

# Conditional imports for main
if __name__ == "__main__":
    import gzip
    import os
    import sys


def unit_stop_times(flatshot_path):
    """
    Extracts unit stop times from the given flatshot log files.

    Args:
        flatshot_path (str): The path to the flatshot log files.

    Returns:
        tuple: A tuple containing the unit stop times summary and details.
            The summary is a dictionary with the following key:
                - "units": The total number of units found.
            The details is a dictionary with unit names as keys and a list of stop times as values.
    """
    if 'Flatshot' not in globals():
        raise ImportError("Flatshot is required for this function to run.")

    ust_summary = {}
    units = set()
    times = defaultdict(list)

    flatshot_object = Flatshot.open(flatshot_path)
    log_files = [f for logfilename in logfilenames for f in flatshot_object.filenames()
                 if re.search(r'011.*\/last\.0\/.*' + logfilename, f)]

    if not log_files:
        log_files = [f for logfilename in logfilenames for f in flatshot_object.filenames()
                     if re.search(r'021.*\/last\.0\/.*' + logfilename, f)]

    for file in log_files:
        try:
            with flatshot_object.extract(file) as f:
                content = f.read().decode("utf-8", errors='ignore')
                if extract_unit_data(units, times, content) is True:
                    break
        except OSError:
            print(f"Error in reading and converting log file: {file}")

    ust_details = calculate_and_sort_unit_durations(times)
    ust_summary["units"] = len(ust_details)

    ust_details = filter_long_durations(ust_details)

    return ust_summary, ust_details


def filter_unit_stop_times():
    """
    This script reads log files and extracts the stop times of systemd units.
    It calculates the duration of each unit and prints the results in sorted order.

    """
    units = set()
    times = defaultdict(list)

    for file in logfilenames:
        print(f"INFO: Reading file: {file}")
        if not os.path.exists(file):  # Check if file exists
            print(f"INFO: File {file} does not exist. Skipping...")
            continue  # Skip to the next file if the current one doesn't exist
        with gzip.open(file, 'rb') as f:
            content = f.read().decode("utf-8", errors='ignore')
            if extract_unit_data(units, times, content) is True:
                break

    durations = calculate_and_sort_unit_durations(times)

    if len(durations) == 0:
        print("ERROR: No units found.")
        return 255

    write_dict_to_file(durations, unit_stop_durations_filename)

    durations = filter_long_durations(durations, 3)

    # WA starts
    # Remove common-switch-daemon from the list of long durations
    # until FCA_PS_LFS-144931 is fixed -> check End of 2025
    if "common-switch-daemon" in durations:
        del durations["common-switch-daemon"]
    # WA ends

    if "ccs.service" in durations and durations["ccs.service"] < 4:
        del durations["ccs.service"]
    long_duration_count = len(durations)
    if long_duration_count > 0:
        write_dict_to_file(durations, long_durations_filename)
        print(f"ERROR: {long_duration_count} unit(s) took longer than 3 seconds "
              "or in case of ccs.service longer than 4 s to stop.")
        return long_duration_count

    return 0


def write_dict_to_file(dictionary, file_path):
    """
    Writes the content of a dictionary to a file.

    :param dictionary: Dictionary to write to the file.
    :param file_path: Path to the file where dictionary content will be written.
    """
    with open(file_path, 'w') as file:
        for key, value in dictionary.items():
            file.write(f"{key}: {value}\n")


def calculate_and_sort_unit_durations(times):
    """
    Calculates the duration of each unit and prints the results in sorted order.

    Args:
        times (dict): A dictionary containing unit names as keys and a list of stop times as values.

    Returns:
        dict: A dictionary containing the calculated durations of each unit.
    """
    durations = {}
    for unit, events in times.items():
        stopping_time = None
        stopped_time = None
        for event, timestamp in sorted(events, key=lambda x: x[1]):
            if event == "Stopping":
                stopping_time = timestamp
            elif event == "Stopped":
                stopped_time = timestamp
                if stopping_time is not None:
                    duration = stopped_time - stopping_time
                    durations[unit] = round(duration, 3)
                    stopping_time = None  # Reset stopping_time to only consider the last pair

    # Sort durations by duration value
    durations = dict(sorted(durations.items(), key=lambda item: item[1], reverse=True))

    return durations


def filter_long_durations(durations, threshold=0.5):
    """
    Filters units with a duration greater than a specified threshold.

    Args:
        durations (dict): A dictionary containing unit names as keys and their durations as values.
        threshold (float): The duration threshold in seconds.

    Returns:
        dict: A dictionary containing only the units with durations greater than the threshold.
    """
    return {unit: duration for unit, duration in durations.items() if duration > threshold}


def extract_unit_data(units, times, content):
    """
    Extracts the stop times of systemd units from the log file content.
    The log file content is read line by line in reverse order.

    Args:
        units (set): A set of unit names to extract stop times for.
        times (dict): A dictionary to store the extracted stop times.
        content (str): The log file content.

    Returns:
        bool: True if the beginning of reboot has been reached, False otherwise
    """
    for line in reversed(io.StringIO(content).readlines()):
        start_of_reboot = re.search(r'^(.+)Z .+ ddal_reboot_sm_site_graceful_hw: ----- start', line.rstrip())
        if start_of_reboot:
            # start of reboot found, stop reading the file
            return True
        match = re.search(r'^(.+)Z .+ (Stopping|Stopped) (.+)\.service', line.rstrip())
        if match:
            datetime_str = match.group(1)
            event = match.group(2)
            unit = match.group(3)
            datetime_obj = datetime.fromisoformat(datetime_str)
            units.add(unit)
            if event == "Stopped":
                times[unit] = [(event, datetime_obj.timestamp())]
            elif event == "Stopping" and unit in times:
                times[unit].append((event, datetime_obj.timestamp()))
    return False


if __name__ == "__main__":
    ret = filter_unit_stop_times()
    sys.exit(ret)
