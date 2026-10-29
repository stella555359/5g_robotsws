"""
:modified: 13.03.2025
"""

from robot.api import logger
from datetime import datetime
from robot.api.deco import keyword
from tabulate import tabulate
import re
import sys

ROBOT_AUTO_KEYWORDS = False


@keyword('Get Section From BlackBox File By Item ID')
def get_section_from_blackbox_file_by_item_id(file_path, item_id, bbox_file_type=None):
    """
    Retrieves a section from a BlackBox file by item ID.

    Args:
        file_path (str): The path to the BlackBox file.
        item_id (str): The item ID to search for.

    Returns:
        str: The section of the file corresponding to the item ID.

    Raises:
        ValueError: If the file is not a valid BlackBox file or the item ID is not found.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    return _get_section_from_blackbox_file_by(file_path, item_id, type_or_id='id', bbox_file_type=bbox_file_type)


@keyword('Get Section From BlackBox File By Item Type')
def get_section_from_blackbox_file_by_item_type(file_path, item_type, bbox_file_type=None):
    """
    Retrieves a section from a BlackBox file by item type.

    Args:
        file_path (str): The path to the BlackBox file.
        item_type (str): The item type to search for.

    Returns:
        str: The section of the file corresponding to the item type.

    Raises:
        ValueError: If the file is not a valid BlackBox file or the item type is not found.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    return _get_section_from_blackbox_file_by(file_path, item_type, type_or_id='type', bbox_file_type=bbox_file_type)


@keyword('Verify Shift For BlackBox POST Result')
def verify_shift_for_blackbox_post_result(output1, output2, from_index, to_index):
    """
    Verifies if the rows in POST[from_index] from output1 have shifted to POST[to_index] in output2.

    Args:
        output1 (str): The first output string to compare.
        output2 (str): The second output string to compare.
        from_index (int): The index of the POST in the first output.
        to_index (int): The index of the POST in the second output.

    Returns:
        bool: True if the rows have shifted as expected, False otherwise.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    post_data1 = _parse_blackbox_post_result_output(output1)
    logger.info(f'POST data 1: {post_data1}')
    post_data2 = _parse_blackbox_post_result_output(output2)
    logger.info(f'POST data 2: {post_data2}')

    post_from_output1 = {k.replace(f'POST[{from_index}]', ''): v for k, v in post_data1.items() if
                         k.startswith(f'POST[{from_index}]')}
    post_to_output2 = {k.replace(f'POST[{to_index}]', ''): v for k, v in post_data2.items() if
                       k.startswith(f'POST[{to_index}]')}

    return post_from_output1 == post_to_output2


@keyword('Verify Last Write For BlackBox POST Result')
def verify_last_write_for_blackbox_post_result(output):
    """
    Verifies if the Last write timestamp is equal to POST[0] timestamp.

    Args:
        output (str): The output string to verify.

    Returns:
        bool: True if the Last write timestamp is equal to POST[0] timestamp, False otherwise.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    post_data = _parse_blackbox_post_result_output(output)

    last_write = post_data.get('Last write')
    logger.info(f'Last write: {last_write}')
    post0_timestamp = post_data.get('POST[0] timestamp')
    logger.info(f'POST[0] timestamp: {post0_timestamp}')

    if last_write and post0_timestamp:
        last_write_dt = datetime.fromisoformat(last_write)
        post0_timestamp_dt = datetime.fromisoformat(post0_timestamp)
        logger.info(f'Last write: {last_write_dt}, POST[0] timestamp: {post0_timestamp_dt}')

        return last_write_dt == post0_timestamp_dt
    return False


def _get_section_from_blackbox_file_by(file_path, item, type_or_id, bbox_file_type=None):
    """
    Retrieves a section from a BlackBox file by item (ID or type).

    Args:
        file_path (str): The path to the BlackBox file.
        item (str): The item (ID or type) to search for.
        type_or_id (str): The type of item to search for ('id' or 'type').

    Returns:
        str: The section of the file corresponding to the item.

    Raises:
        ValueError: If the file is not a valid BlackBox file or the item is not found.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    with open(file_path, 'r') as file:
        first_line = file.readline().strip()

    if 'BlackBox ver:' not in first_line and bbox_file_type is None:
        raise ValueError(f'File {file_path} is not a valid BlackBox file.')
    else:
        logger.info(f'File {file_path} is a valid BlackBox file.')

    item_section = _extract_section_by_item_id(file_path, item) if type_or_id == 'id' else \
        _extract_section_by_item_type(file_path, item)
    if item_section is None:
        raise ValueError(f'Item {item} not found in file {file_path}.')
    else:
        logger.info(f'Item {item} found in file {file_path}.')
        return item_section


def _extract_section_by_item_id(file_path, item_id):
    """
    Extracts a section from a BlackBox file by item ID.

    Args:
        file_path (str): The path to the BlackBox file.
        item_id (str): The item ID to search for.

    Returns:
        str: The section of the file corresponding to the item ID, or None if not found.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    section = _open_blackbox_and_extract_section(file_path)

    for row in section:
        lines = row.strip().splitlines()
        if len(lines) > 1 and lines[1] == f'Item id: {item_id}':
            return row.strip()

    return None


def _extract_section_by_item_type(file_path, item_type):
    """
    Extracts a section from a BlackBox file by item type.

    Args:
        file_path (str): The path to the BlackBox file.
        item_type (str): The item type to search for.

    Returns:
        str: The section of the file corresponding to the item type, or None if not found.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    section = _open_blackbox_and_extract_section(file_path)

    for row in section:
        lines = row.strip().splitlines()
        if lines and lines[0] == f'Item type: {item_type}':
            return row.strip()

    return None


def _open_blackbox_and_extract_section(file_path):
    """
    Opens a BlackBox file and extracts its sections.

    Args:
        file_path (str): The path to the BlackBox file.

    Returns:
        list: A list of sections in the file.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    with open(file_path, 'r') as file:
        content = file.read()

    section = content.split('\n---\n')
    return section


def _parse_blackbox_post_result_output(output):
    """
    Parses the output string of a BlackBox POST result into a dictionary.

    Args:
        output (str): The output string to parse.

    Returns:
        dict: A dictionary containing the parsed POST result data.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    lines = output.strip().split('\n')
    post_data = {}
    for line in lines:
        if line.startswith('POST') or line.startswith('Last write'):
            parts = line.split(': ', 1)
            key = parts[0]
            value = parts[1]
            post_data[key] = value
    return post_data


def _extract_fan_speed_lines_from_blackbox_file(file_path: str) -> list:
    """
    Retrieves the fan speed from a BlackBox file.

    Args:
        file_path (str): The path to the BlackBox file.

    Returns:
        list: Extracted lines containing fan speed data.
    """
    with open(file_path, 'r') as file:
        content = file.readlines()

    is_between = False
    extracted_lines = []

    for line in content:
        if '#TEMPANDSPEED' in line:
            is_between = True
            continue
        if '#yearly historical of temperatures' in line and is_between:
            break
        if is_between:
            extracted_lines.append(line.strip())

    return extracted_lines


def _filter_lines_by_time_range(lines: list, start_time: str, end_time: str) -> list:
    """
    Filters lines by a given time range.

    Args:
        lines (list): List of lines to filter.
        start_time (str): Start time in format '%Y-%m-%d %H:%M'.
        end_time (str): End time in format '%Y-%m-%d %H:%M'.

    Returns:
        list: Filtered lines within the given time range.
    """
    if not start_time or not end_time:
        return lines

    start_dt = datetime.strptime(start_time, '%Y-%m-%d %H:%M')
    end_dt = datetime.strptime(end_time, '%Y-%m-%d %H:%M')

    filtered_lines = []
    for line in lines:
        try:
            timestamp_part = line.split()[0]
            timestamp_str = timestamp_part.split('T')[0] + ' ' + timestamp_part.split('T')[1][:5]
            line_dt = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M')
        except (ValueError, IndexError):
            logger.warn(f"Failed to parse line: {line}")
            continue

        if start_dt <= line_dt <= end_dt:
            logger.info(f"Line '{line}' is within the time range.")
            filtered_lines.append(line)

    return filtered_lines


def _extract_fan_unit_data(header_line: str, filtered_lines: list) -> dict:
    headers = header_line.split('\t')
    """
    Extracts data for FanUnit columns and their values from the given lines.

    Args:
        header_line (str): Header line containing column names.
        filtered_lines (list): Filtered lines containing data.

    Returns:
        dict: Dictionary with Fan keys extracted from the blackbox file (FAN-1, FAN-2, etc.) and their values.
    """
    # Find indices and numbers for columns containing 'FsmFan'
    fan_unit_info = [
        (idx, re.search(r'FsmFan(\d+)', header))
        for idx, header in enumerate(headers)
        if "FsmFan" in header
    ]
    # Build keys using the actual fan number
    fan_unit_data = {
        f"FAN-{match.group(1)}": [] for idx, match in fan_unit_info if match
    }
    for line in filtered_lines:
        try:
            values = line.split('\t')
            for idx, match in fan_unit_info:
                if match:
                    fan_key = f"FAN-{match.group(1)}"
                    fan_unit_data[fan_key].append(int(values[idx]))
        except (ValueError, IndexError):
            logger.warn(f"Failed to extract FanUnit data from line: {line}")
            continue
    return fan_unit_data


@keyword('Get Fan Speed From BlackBox File')
def get_fan_speed_from_blackbox_file(file_path, starting_time=None, ending_time=None):
    """
    Retrieves the fan speed lines from the BlackBox file within a specific time range.

    Args:
        file_path (str): The path to the BlackBox file.
        starting_time (str): The start of the time range (format '%Y-%m-%d %H:%M').
        ending_time (str): The end of the time range (format '%Y-%m-%d %H:%M').

    Returns:
        dict: Dictionary with FanUnit keys and their values within the time range.
    """
    fan_speed_lines = _extract_fan_speed_lines_from_blackbox_file(file_path)

    if not fan_speed_lines:
        logger.warn("No fan speed lines found.")
        return {}

    header_line = fan_speed_lines[0]
    data_lines = fan_speed_lines[1:]

    # Filter lines by the given time range
    filtered_lines = _filter_lines_by_time_range(data_lines, starting_time, ending_time)

    # Extract FanUnit data
    fan_unit_data = _extract_fan_unit_data(header_line, filtered_lines)
    logger.info(f"FanUnit data: {fan_unit_data}")

    return fan_unit_data


@keyword('Extract New Rows')
def extract_new_rows(reference_file_path: str, new_file_path: str, spliter: str = None) -> str:
    """
    Extracts new rows from the new file that are not present in the reference file.
    If no spliter is provided, compares all rows.
    The result includes the new rows plus one additional row as a reference.
    If all data rows in the new file's section are new, it attempts to include
    the last data row from the reference file's section as context.

    Args:
        reference_file_path (str): The path to the reference file.
        new_file_path (str): The path to the new file.
        spliter (str): The name indicating the section to compare up to. Defaults to None.

    Returns:
        str: A formatted string containing the new rows plus one additional reference row,
         or a message indicating no new rows were found.

    Raises:
        FileNotFoundError: If the specified file paths are incorrect.
        ValueError: If the specified section name is not found in either file.

    Author: malgorzata.piecyk-celuch@nokia.com
    Maintainer: malgorzata.piecyk-celuch@nokia.com
    """
    with open(reference_file_path, "r", encoding="utf-8") as ref_file:
        ref_lines = ref_file.readlines()
    with open(new_file_path, "r", encoding="utf-8") as new_file:
        new_lines = new_file.readlines()

    if spliter:
        try:
            ref_threshold_index = next(idx for idx, line in enumerate(ref_lines) if spliter in line)
            ref_data_lines = ref_lines[:ref_threshold_index]
        except StopIteration:
            raise ValueError(f"'{spliter}' section not found in reference file: {reference_file_path}")

        try:
            new_threshold_index = next(idx for idx, line in enumerate(new_lines) if spliter in line)
            new_data_lines = new_lines[:new_threshold_index]
        except StopIteration:
            raise ValueError(f"'{spliter}' section not found in new file: {new_file_path}")
    else:
        ref_data_lines = ref_lines
        new_data_lines = new_lines

    # Identify truly new rows (present in new_data_lines but not in ref_data_lines)
    new_rows = [line for line in new_data_lines if line not in ref_data_lines]

    if not new_rows:
        print("No new rows found.")
        return "No new rows found."

    # Find the index of the first identified new row within the original new_data_lines list
    first_new_row_original_index = -1
    for i, line in enumerate(new_data_lines):
        if line in new_rows:
            first_new_row_original_index = i
            break

    line_to_prepend = None

    if first_new_row_original_index > 0:
        potential_preceding_line = new_data_lines[first_new_row_original_index - 1]

        # Check if the potential preceding line is the header of the section
        # This is true if the first new data row appears immediately after the header
        is_header_preceding = (first_new_row_original_index == 1) and (potential_preceding_line == new_data_lines[0])

        if is_header_preceding:
            # If the first new data row is right after the header, and all data rows are new,
            # we want to prepend the last data row from the reference file's section.
            # Ensure there's at least one data row in ref_data_lines (i.e., more than just the header).
            if len(ref_data_lines) > 1:
                line_to_prepend = ref_data_lines[-1]  # Take the last data row from reference
        else:
            # If the preceding line is not the header, it must be a common data row.
            # We prepend this common data row for context.
            line_to_prepend = potential_preceding_line

    if line_to_prepend:
        new_rows.insert(0, line_to_prepend)

    # Format the output
    # The first line of the new file (new_lines[0]) is typically the overall header
    # of the section being compared (e.g., "DATE | COUNTERS...").
    # This is combined with the 'new_rows' (which now includes the prepended context row).
    data = [re.split(r'\s{2,}|\t+', line.strip()) for line in [new_lines[0]] + new_rows]
    col_widths = [max(len(str(item)) for item in col) for col in zip(*data)]

    extracted_rows = "\n".join("  ".join(val.ljust(w) for val, w in zip(row, col_widths)) for row in data)
    print("\n" + extracted_rows)

    return extracted_rows


def _extract_date(date_string: str) -> str:
    """
    Extracts a date from a given string using predefined date patterns.

    The function searches for dates in the formats YYYY-MM-DD, YYYY/MM/DD, YYYY.MM.DD,
    DD-MM-YYYY, DD/MM/YYYY, and DD.MM.YYYY. If a date is found, it returns the matched
    date string. If no date is found, it returns an empty string.

    Args:
        date_string (str): The string containing the date to be extracted.

    Returns:
        str: The extracted date string if a match is found, otherwise an empty string.

    Author: malgorzata.piecyk-celuch@nokia.com
    Maintainer: malgorzata.piecyk-celuch@nokia.com
    """
    date_patterns = [
        r"(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})",
        r"(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})"
    ]
    for pattern in date_patterns:
        match = re.search(pattern, date_string)
        if match:
            return match.group()

    return ""


@keyword('Verify Dates In File')
def verify_dates_in_file(file_path: str) -> tuple[bool, str]:
    """
    Verifies that all dates in the specified file match today's date.
    The function reads the file content and checks the date
    in each subsequent row. If all dates match today's date, it returns a success message.
    If any date does not match, it returns a failure message indicating the incorrect date.

    Args:
        file_path (str): The path to the file containing dates to be verified.

    Returns:
        tuple[bool, str]: A tuple containing a boolean indicating success or failure,
                          and a message detailing the result.

    Raises:
        FileNotFoundError: If the specified file path is incorrect.

    Author: malgorzata.piecyk-celuch@nokia.com
    maintainer: malgorzata.piecyk-celuch@nokia.com
    """
    today_date = datetime.today().date().isoformat()
    rows = file_path.strip().split("\n")[2:]

    message = f"All items have correct date: {today_date}"

    for row in rows:
        parts = row.split()
        if not parts:
            continue

        date_part = parts[0]
        date_only = _extract_date(date_part)

        if date_only != today_date:
            message = f"\nIncorrect date found: {date_only}. Expected: {today_date}"
            logger.warn(message)
            return False, message

    logger.info(message)
    return True, message


@keyword('Check Flags Incrementation')
def check_flags_incrementation(file_path: str, high_extend_th: int, high_nominal_th: int,
                               low_nominal_th: int, low_extend_th: int) -> tuple[bool, str]:
    """
    Checks the incrementation of flags in a file based on specified voltage thresholds.
    The function reads the file content, processes the numeric data, and verifies that
    the flags increment correctly according to the voltage ranges defined by the thresholds.

    Args:
        file_path (str): The path to the file containing voltage and flag data.
        high_extend_th (int): High extend threshold value.
        high_nominal_th (int): High nominal threshold value.
        low_nominal_th (int): Low nominal threshold value.
        low_extend_th (int): Low extend threshold value.

    Returns:
        tuple: [bool, str] A tuple containing a boolean indicating success or failure,
                          and a message detailing the result.

    Raises:
        ValueError: If the specified file path is incorrect.

    Author: malgorzata.piecyk-celuch@nokia.com
    maintainer: malgorzata.piecyk-celuch@nokia.com
    """
    thresholds = {
        "EXTEND_HIGH": high_extend_th * 1000,
        "NOMINAL_HIGH": high_nominal_th * 1000,
        "NOMINAL_LOW": low_nominal_th * 1000,
        "EXTEND_LOW": low_extend_th * 1000
    }
    column_map = {"EXTEND_HIGH": 4, "NOMINAL_HIGH": 3, "NOMINAL_LOW": 2, "EXTEND_LOW": 1}
    column_names = {idx: name for name, idx in column_map.items()}
    voltage_ranges = {k: (v - 500, v + 500) for k, v in thresholds.items()}
    no_increment_range = (47700, 48300)

    numeric_data = [[int(value) for value in re.split(r"\t|\s+", line.strip())[-5:]]
                    for line in file_path.strip().split("\n")[1:]
                    ]
    errors = []
    increment_count = 0

    logger.info("\nAllowed Voltage Ranges:")
    for k, (low, high) in voltage_ranges.items():
        logger.info(f"{k}: {low}V - {high}V")

    for r in range(1, len(numeric_data)):
        current_voltage, *flags = numeric_data[r]
        logger.info(f"\nChecking voltage: {current_voltage} V")

        if no_increment_range[0] <= current_voltage <= no_increment_range[1]:
            logger.info(f"Voltage {current_voltage}V is within the no-increment range {no_increment_range}.")
            continue

        expected_col = next((column_map[k] for k, (low, high) in voltage_ranges.items()
                             if low <= current_voltage <= high), None)
        expected_col_name = column_names.get(expected_col, "UNKNOWN")
        if expected_col is None:
            error_msg = f"FAIL: Voltage {current_voltage}V out of expected ranges."
            errors.append(error_msg)
            continue

        changed_cols = [col for col in range(1, 5) if numeric_data[r - 1][col] < numeric_data[r][col]]
        changed_col_names = [column_names[col] for col in changed_cols]
        logger.info(f"Detected increments in columns: {changed_cols} ({', '.join(changed_col_names)})"
                    f"(Expected: {expected_col} ({expected_col_name}))")

        if expected_col not in changed_cols:
            error_msg = (
                f"FAIL: Expected increment in column {expected_col} ({expected_col_name}), "
                f"but found in {changed_cols} ({', '.join(changed_col_names)})."
            )
            errors.append(error_msg)
        else:
            increment_count += 1

        for col_name, col_idx in column_map.items():
            diff = numeric_data[r][col_idx] - numeric_data[r - 1][col_idx]
            if diff < 0:
                error_msg = f"FAIL: Value in {col_name} decreased! (Prev {numeric_data[r - 1][col_idx]} ->" \
                            f"Current {numeric_data[r][col_idx]})"
                errors.append(error_msg)
            elif diff > 1:
                error_msg = f"FAIL: Value in {col_name} increased by more than 1! (Diff={diff})"
                errors.append(error_msg)

    if errors:
        logger.warn("\n".join(errors))
        return False, "\n".join(errors)
    if increment_count == 4:
        logger.info("\nAll values increment correctly!")
        return True, "All values are correct."
    else:
        logger.warn("\nFAIL: Expected 4 increments, but found {increment_count}.")
        return False, "FAIL: Expected 4 increments, but found {increment_count}."


@keyword('Verify Voltage In Blackbox File')
def verify_voltage_in_blackbox_file(file_path: str, vol_extend_low: int, vol_nominal_low: int,
                                    vol_nominal_high: int, vol_extend_high: int) -> tuple[bool, str]:
    """
    Verifies the voltage values in the last line of a blackbox file against expected values.
    The function reads the last line of the specified file, extracts the voltage values,
    and compares them to the expected values provided as arguments.

    Args:
        file_path (str): The path to the text file containing voltage values.
        vol_extend_low (int): Expected value for the extended low voltage threshold.
        vol_nominal_low (int): Expected value for the nominal low voltage threshold.
        vol_nominal_high (int): Expected value for the nominal high voltage threshold.
        vol_extend_high (int): Expected value for the extended high voltage threshold.

    Returns:
        tuple[bool, str]: A tuple containing a boolean indicating success or failure,
                          and a message detailing the result.

    Author: malgorzata.piecyk-celuch@nokia.com
    Maintainer: malgorzata.piecyk-celuch@nokia.com
    """
    labels = ["EXTEND_LOW", "NOMINAL_LOW", "NOMINAL_HIGH", "EXTEND_HIGH"]
    expected_values = [vol_extend_low, vol_nominal_low, vol_nominal_high, vol_extend_high]
    expected_values = [int(value) * 1000 for value in expected_values]

    try:
        with open(file_path, 'r') as file:
            values = list(map(int, file.readlines()[-1].split()[-4:]))
    except (IndexError, ValueError) as e:
        return False, f"Error reading file: {e}"

    errors = [f"{label}: expected {exp}, found {val}" for label, exp, val in zip(labels, expected_values, values) if
              exp != val]

    logger.info(tabulate(zip(labels, expected_values, values), headers=["Value", "Expected", "Found"], tablefmt="grid"))
    return (False, "Values do not match:\n" + "\n".join(errors)) if errors else (True, "All values match to expected.")


@keyword('Parse Section Result Output')
def _parse_section_result_output(output):
    """
    Parses the output string of a BlackBox POST result into a dictionary.

    Args:
        output (str): The output string to parse.

    Returns:
        dict: A dictionary containing the parsed POST result data.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    lines = output.strip().split('\n')
    result_data = {}
    for line in lines:
        # if line.startswith('First') or line.startswith('Last'):
        parts = line.split(': ', 1)
        key = parts[0]
        value = parts[1]
        result_data[key] = value
    return result_data


@keyword('Compare Specific Part Of Sections')
def _compare_specific_part_of_sections(output1, output2, key, value=0):
    """
    Compares a specific part of two section outputs.

    Args:
        output1 (str): The first output string to compare.
        output2 (str): The second output string to compare.
        part (str): The specific part to compare (e.g., 'First', 'Last').

    Returns:
        bool: True if the specified parts are equal, False otherwise.
    Author: szymon.przybylak@nokia.com
    Maintainer: szymon.przybylak@nokia.com
    """
    section_1_parsed = _parse_section_result_output(output1)
    logger.info(f"Section 1 parsed data: {section_1_parsed}")
    section_2_parsed = _parse_section_result_output(output2)
    logger.info(f"Section 2 parsed data: {section_2_parsed}")

    if key in section_1_parsed and key in section_2_parsed:
        logger.info(f"Comparing {key} from both sections with incrementation by {value}.")
        logger.info(f"Section 1 {key}: {section_1_parsed[key]}")
        logger.info(f"Section 2 {key}: {section_2_parsed[key]}")
        return int(section_1_parsed[key]) + value == int(section_2_parsed[key])


@keyword('Extract Row Values')
def _extract_row_values(data_string: str, row_identifier: str) -> list[int]:
    """
    Extracts all numerical values from a specified row in a multi-line string.

    Args:
        data_string (str): The complete string containing the data.
        row_identifier (str): The identifier for the row to extract (e.g., "module:CORE Value[°C]").

    Returns:
        list[int]: A list of integer values from the specified row.
                   Returns an empty list if the row_identifier is not found
                   or if no numerical values are present.
    """
    lines = data_string.splitlines()
    target_prefix = row_identifier + ":"

    for line in lines:
        if line.strip().startswith(target_prefix):
            # Extract the part of the string after the prefix and colon
            values_str = line.strip().replace(target_prefix, "", 1).strip()

            # Split by space and convert to integers, filtering out any empty strings
            try:
                # Handle potential multiple spaces between numbers
                numerical_values = [int(val) for val in values_str.split() if val]
                return numerical_values
            except ValueError:
                # Handle cases where conversion to int fails (e.g., non-numeric data)
                return []

    return []  # Return an empty list if the row_identifier is not found


@keyword('Update Nested Value')
def update_nested_value(data_dict, key_path, new_value):
    """
    Updates a value in a nested dictionary given a key path and value.

    Args:
        data_dict (dict): The dictionary to modify.
        key_path (list): A list of strings representing the path to the key.
                         E.g., ['bboxTempMeasurement', 'temperatureDeltaForSave']
        new_value: The new value to set.

    Returns:
        dict: The modified dictionary.
    Author: szymon.przybylak@nokia.com
    Maintainer: szymon.przybylak@nokia.com
    """
    # Add a try-except block to catch any unexpected errors and re-raise them
    try:
        current_dict = data_dict
        # Traverse the dictionary using the key_path until the second-to-last key
        for i, key in enumerate(key_path[:-1]):
            # Ensure the current level is a dictionary and contains the key
            if not isinstance(current_dict, dict):
                raise TypeError(
                    f"Path segment '{key_path[:i + 1]}' expects a dictionary, "
                    f"but found {type(current_dict)} at key '{key}'. "
                    "Full path: {key_path}"
                )
            if key not in current_dict:
                raise KeyError(
                    f"Key '{key}' not found in path: {key_path}. "
                    f"Current dictionary keys: {list(current_dict.keys())}"
                )
            current_dict = current_dict[key]

        # Update the value at the final key
        final_key = key_path[-1]
        # Ensure the final level is a dictionary and contains the target key
        if not isinstance(current_dict, dict):
            raise TypeError(
                f"Target path '{key_path}' leads to a non-dictionary object before final key '{final_key}'."
                f"Found {type(current_dict)}"
            )
        if final_key not in current_dict:
            raise KeyError(
                f"Target key '{final_key}' not found in final dictionary. Full path: {key_path}."
                f"Current dictionary keys: {list(current_dict.keys())}")

        current_dict[final_key] = new_value
        return data_dict  # Always explicitly return the modified dictionary

    except Exception as e:
        # Log the error to stderr and re-raise it to ensure Robot Framework fails the test
        print(
            f"ERROR (Python): An unexpected error occurred in update_nested_value: "
            f"{type(e).__name__}: {e}",
            file=sys.stderr
        )
        raise  # Re-raise the exception to propagate the error to Robot Framework


@keyword('Check Bbox Structure Match')
def _check_bbox_structure_match(info_keys, info_template):
    """
    Compares `info_keys` with `info_template` after removing brackets [x]/[number].
    Used to check black box structure/functions.

    Args:
        info_keys (list): The list of keys to be checked.
        info_template (list): The list of template keys to check against.

    Returns:
        bool: True if all items matched successfully, False otherwise.
        str: A message indicating if duplicate values are found in `info_keys`.

    Raises:
        Warning: If duplicate values are found in `info_keys`.
        Warning: If a key in `info_keys` does not match any key in `info_template`.

    Example:
        >>> info_keys = ['name[1]', 'age[2]', 'location']
        >>> info_template = ['name', 'age', 'location']
        >>> check_info_structure_match(info_keys, info_template)
        True

    Author: szymon.przybylak@nokia.com
    Maintainer: szymon.przybylak@nokia.com
    """

    # Function to remove [x] or [number] from a string
    def clean_item(item):
        return re.sub(r"\[\w+\]|\[\d+\]", "", item).strip()  # Remove [x] and [123] and trim spaces

    # Check for duplicates in info_keys
    if len(info_keys) != len(set(info_keys)):
        logger.warn("? Warning: Duplicate values found in info_keys!")
        return "Duplicate values found in info_keys!"
    logger.info(f"No duplicate values found in info_keys.")

    # Clean both lists (keys and template)
    cleaned_keys = [clean_item(item) for item in info_keys]
    cleaned_template = [clean_item(item) for item in info_template]

    logger.info(f"Cleaned info_keys: {cleaned_keys}")
    logger.info(f"Info_template: {cleaned_template}")

    # Check if all keys exist in the template
    for key in cleaned_keys:
        if key not in cleaned_template:
            logger.warn(f"? FAIL: No match found for '{key}' in template!")
            return f"No match found for '{key}' in template!"

    logger.info("All items matched successfully.")
    return True
