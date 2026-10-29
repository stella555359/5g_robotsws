import csv
import os
from datetime import datetime
from typing import List, Dict, Union
from taf.analyzer.pmcounter import pmcounter
from testsuite.Paris.RRM.ET.resources.vrf_nps2.python.utilities import (
    to_int,
    _timestamp_to_int,
    save_in_json_file,
    load_json_file,
    extract_unique_names,
    eval_comparison
)


def get_pi_list_values(
    pi_list,
    pi_dir,
    mos_list=None,
    pi_file_pattern="*.PM.*",
    m_period=5,
    intervals=None,
    before=False,
):
    """
    Extracts performance indicator (PI) values from PM files in a directory,
    filters by managed objects (MOs), and selects timestamps based on intervals.

    Args:
        pi_list (list): List of PI counters to extract.
        pi_dir (str): Directory containing PM files.
        mos_list (list, optional): List of managed objects to filter. Defaults to [].
        pi_file_pattern (str, optional): File pattern for PM files. Defaults to "*.PM.*".
        intervals (list, optional): List of interval timestamps (str) to select. Defaults to [].
        m_period (int, optional): Measurement period in minutes. Default to 5.
        before (bool, optional): If True, select interval before the timestamp. Defaults to False.

    Raises:
        FileNotFoundError: If the PM directory does not exist.

    Returns:
        dict: Dictionary containing selected timestamps, counters, and managed objects.
    """
    # Set default values for optional arguments
    if intervals is None:
        intervals = []
    m_period = to_int(m_period)

    # Check if the PM directory exists
    if not os.path.isdir(pi_dir):
        raise FileNotFoundError(f"Output directory '{pi_dir}' does not exist.")

    # Retrieve PI values from PM files
    pm_data_list = pmcounter.get_pi_value(
        pi_list, pi_dir=pi_dir, pi_file_pattern=pi_file_pattern, interval=None
    )

    if not pm_data_list:
        raise FileNotFoundError(f"no pm counters found please check the path: {pi_dir}")

    # Collect all timestamps, counters, and managed objects
    timestamps = []
    counters = set()
    mos = set()

    for entry in pm_data_list:
        for ts, counter_dict in entry.items():
            if ts not in timestamps:
                timestamps.append(ts)
            for counter, mos_dict in counter_dict.items():
                counters.add(counter)
                for mo in mos_dict.keys():
                    mos.add(mo)

    if intervals:
        sel_timestamps = []
        intervals_int = [_timestamp_to_int(e) for e in intervals]
        timestamps_int = [_timestamp_to_int(e) for e in timestamps]
        # Add one more timestamp for range comparison
        timestamps_int.append(timestamps_int[-1] + m_period * 60)
        delta = m_period * 60 if before else 0
        for i, ts_int in enumerate(timestamps_int[:-1]):
            for interval_int in intervals_int:
                if ts_int <= interval_int - delta < timestamps_int[i + 1]:
                    sel_timestamps.append(timestamps[i])
                    break
    else:
        sel_timestamps = timestamps.copy()
    entries = []
    if mos_list is None:
        mos_list = mos.copy()
    for _entries in pm_data_list:
        for _ts, _counter_mos in _entries.items():
            if _ts in sel_timestamps:
                for _counter, _mos_entries in _counter_mos.items():
                    _elements = {}
                    for mo, value in _mos_entries.items():
                        if value and mo in mos_list:
                            _elements.update({mo: value})
                    if _elements:
                        entries.append({_ts: {_counter: _elements}})
    return entries


def save_pi_json_to_csv(json_file_path, output_dir=None):
    """
    Converts JSON counters data to CSV format for easy filtering and analysis.

    Args:
        json_file_path (str): Path to the input JSON file
        output_dir (str, optional): Directory to save the CSV file. Defaults to the same as JSON file.

    Returns:
        str: Path to the created CSV file

    Raises:
        FileNotFoundError: If the JSON file doesn't exist
        json.JSONDecodeError: If the JSON file is invalid
    """
    # Check if JSON file exists
    if not os.path.isfile(json_file_path):
        raise FileNotFoundError(f"JSON file '{json_file_path}' does not exist.")

    # Set output directory
    if output_dir is None:
        output_dir = os.path.dirname(json_file_path)

    # Load JSON data
    data = load_json_file(json_file_path)

    # Collect all timestamps, counters, and managed objects
    timestamps = set()
    counters = set()
    managed_objects = set()

    # Aggregate data by timestamp
    timestamp_data = {}

    for entry in data:
        for ts, counter_dict in entry.items():
            timestamps.add(ts)
            if ts not in timestamp_data:
                timestamp_data[ts] = {}

            for counter, mo_dict in counter_dict.items():
                counters.add(counter)
                if counter not in timestamp_data[ts]:
                    timestamp_data[ts][counter] = {}

                for mo, value in mo_dict.items():
                    managed_objects.add(mo)
                    timestamp_data[ts][counter][mo] = value

    # Sort for consistent ordering
    timestamps = sorted(timestamps)
    counters = sorted(counters)
    managed_objects = sorted(managed_objects)

    # Create CSV header: timestamp, managed_object, counter1, counter2, ...
    header = ['timestamp', 'managed_object'] + counters

    # Prepare rows
    rows = []
    for ts in timestamps:
        for mo in managed_objects:
            row = [ts, mo]
            for counter in counters:
                value = ''
                if counter in timestamp_data.get(ts, {}) and mo in timestamp_data[ts][counter]:
                    value = timestamp_data[ts][counter][mo]
                row.append(value)
            rows.append(row)

    # Generate output filename
    base_name = os.path.splitext(os.path.basename(json_file_path))[0]
    csv_filename = f'{base_name}.csv'
    csv_file_path = os.path.join(output_dir, csv_filename)

    # Write to CSV
    with open(csv_file_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)

    print(f"CSV file created: {csv_file_path}")
    print(f"Total timestamps: {len(timestamps)}")
    print(f"Total counters: {len(counters)}")
    print(f"Total managed objects: {len(managed_objects)}")

    return csv_file_path


def save_pi_to_json(
    pi_list,
    pi_dir,
    mos_list=None,
    pi_file_pattern="*.PM.*",
    m_period=5,
    intervals=None,
    before=False,
    out_dir=None,
    filename_prefix="results"
):
    if out_dir is None:
        out_dir = pi_dir
    pm_data_list = get_pi_list_values(
        pi_list, pi_dir=pi_dir, mos_list=mos_list, pi_file_pattern=pi_file_pattern, intervals=intervals,
        m_period=m_period, before=before
    )

    # Write to JSON
    json_file = f"{os.path.join(out_dir, filename_prefix)}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    save_in_json_file(pm_data_list, json_file)
    return json_file


def validate_counters(
    *counter_args,
    pm_json_file: str,
    mo: str,
    timestamp: str,
    before: bool,
    m_period: Union[str | int]
):
    """
    Calls the 'Validate Counters Values Frm JSON File' Robot Framework keyword with the given arguments.

    Args:
        *counter_args: Tuples or strings for each counter, e.g. ('100000 <= M55332C00001 <= 120000',
                                                                 'EN_DSS_DL_NR_SLOTS')
        mo (str): The mo value.
        pm_json_file (str): The file path.
        timestamp: str: represent a timestamp
        before: boolean: indicate to collect the period before timestamp time or no.
        m_period: str or int: measurement period in minute for counters

    Example:
        verify_any_counters_in_file(
            ('100000 <= M55332C00001 <= 120000', 'EN_DSS_DL_NR_SLOTS'),
            ('290000 <= M55332C02001 <= 310000', 'EN_DSS_NBR_AVLBL_DL_SLOTS'),
            mo='MRBTS-1/NRBTS-1/NRCELL-1',
            pm_json_file='/path/to/logs',
            timestamp='2025-09-12 15:56:20+00:00'
            before=True
            m_period=5
        )
    """

    global results
    args = []
    for counter in counter_args:
        args.append(counter)
    req_counters = extract_unique_names(args, pattern=r'M\d+C\d+')
    pm_counters_data = load_json_file(pm_json_file)
    # Collect all timestamps, counters, and cell names
    timestamps = []
    counters = set()
    mos = set()

    for entry in pm_counters_data:
        for ts, counter_dict in entry.items():
            timestamps.append(ts)

    sel_timestamps = []
    m_period = to_int(m_period)
    timestamp_int = _timestamp_to_int(timestamp)
    timestamps_int = [_timestamp_to_int(e) for e in timestamps]
    # Add the first timestamp period
    timestamps_int.append(timestamps_int[-1] + m_period * 60)
    delta = m_period * 60 if before else 0
    for i, ts_int in enumerate(timestamps_int[:-1]):
        if ts_int <= timestamp_int - delta < timestamps_int[i + 1]:
            sel_timestamps.append(timestamps[i])
    if sel_timestamps:
        counters_values = {}
        for entry in pm_counters_data:
            for ts, counter_dict in entry.items():
                if ts in sel_timestamps:
                    for counter, mos_dict in counter_dict.items():
                        if mo in mos_dict:
                            counters_values.update({counter: mos_dict.get(mo, '')})
        print(f"counters value: {counters_values}")
        # Check if counter to validate are reported
        missing_counters = [counter for counter in req_counters if counter not in counters_values]
        if missing_counters:
            error_msg = "Error: *** PM Data Counter(s) Collection Error ***\n"
            error_msg += "\n".join(
                [f"\t {counter}" for counter in missing_counters])
            error_msg += f"\ndata was not found for managed object {mo} at {timestamp}.\n"
            error_msg += f"This indicates a potential issue with data collection or reporting for this counter(s).\n"
            error_msg += f"Please verify the counter(s)'s accuracy and the data availability for that period."
            raise ValueError(error_msg)
    else:
        raise ValueError(f"Error: *** Timestamp Not Found ***\n"
                         f"PM data for {timestamp} could not be retrieved. "
                         f"Please verify the timestamp's accuracy and the data availability for that period.")
    condition = []
    for arg in args:
        # Replace all counters in the current argument
        modified_arg = arg
        for counter, value in counters_values.items():
            modified_arg = modified_arg.replace(counter, str(value))
        condition.append(modified_arg)

    results = eval_comparison(*condition)
    print(results)
    validation = []
    for i, arg in enumerate(args):
        # Replace all counters in the current argument
        for counter, value in counters_values.items():
            arg = arg.replace(counter, f"{counter}({value})")
        validation.append({
            arg: results[i]
        })

    return validation
