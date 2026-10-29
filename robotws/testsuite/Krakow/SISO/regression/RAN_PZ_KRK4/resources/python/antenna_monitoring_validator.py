"""
Keywords for Antenna Online Monitoring csv output validation.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

import csv
import logging
import random
import re

from datetime import timedelta
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections.device_aliases import ssh_bts_du
from datetime import datetime
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.resources.python.CellOperations import CellOperations


class InvalidTimestampIntervalException(Exception):
    """Exception raised for invalid timestamp intervals."""

    def __init__(self, section, record, expected_interval, actual_interval):
        self.section = section
        self.record = record
        self.expected_interval = expected_interval
        self.actual_interval = actual_interval
        super().__init__(f"Invalid interval in section '{section}' for record '{record}'. "
                         f"Expected: interval >= {expected_interval}s, Actual: interval = {actual_interval}s.")


class MissingCellException(Exception):
    """Exception raised for missing cells."""

    def __init__(self, missing_cells):
        self.missing_cells = missing_cells
        super().__init__(f"Missing cells: {', '.join(missing_cells)}")


class InvalidMonitoringValueException(Exception):
    """Exception raised when a monitoring value is not valid."""

    def __init__(self, actual_values, expected_value):
        self.actual_values = actual_values
        self.expected_value = expected_value
        super().__init__(f"Found invalid monitoring values in sections: '{actual_values}'. "
                         f"Should be: {expected_value}")


def parse_antenna_monitoring_output(path_csv_file):
    """
    Parses the antenna monitoring output from a CSV file.

    This function reads a CSV file containing antenna monitoring data and organizes it into sections:
    VSWR, RTWP, RSSI, and ETP. Each section's data is converted into a list of dictionaries where the keys
    are the column headers and the values are the corresponding data entries.

    :param path_csv_file: The path to the CSV file containing the antenna monitoring data.
    :type path_csv_file: str
    :return: A dictionary with keys 'VSWR', 'RTWP', 'RSSI', and 'ETP', each containing a list of dictionaries
             representing the parsed data for that section.
    :rtype: dict
    """
    with open(path_csv_file, mode='r', encoding='utf-8-sig') as file:
        reader = csv.reader(file)
        current_section = None
        vswr_data = []
        rtwp_data = []
        rssi_data = []
        etp_data = []

        for row in reader:
            if "VSWR" in row:
                current_section = "VSWR"
                continue
            elif "RTWP (dBm)" in row:
                current_section = "RTWP"
                continue
            elif "RSSI (dBm)" in row:
                current_section = "RSSI"
                continue
            elif "ETP (mW)" in row:
                current_section = "ETP"
                continue

            if current_section == "VSWR":
                vswr_data.append(row)
            elif current_section == "RTWP":
                rtwp_data.append(row)
            elif current_section == "RSSI":
                rssi_data.append(row)
            elif current_section == "ETP":
                etp_data.append(row)

        def convert_to_dict(data):
            """
            Converts a list of lists into a list of dictionaries using the first sublist as headers.

            :param data: List of lists where the first sublist contains the headers.
            :type data: list
            :return: Lst of dictionaries where keys are headers and values are data entries.
            :rtype: list
            """
            if not data:
                return []
            headers = data[0]
            return [dict(zip(headers, output_row)) for output_row in data[1:]]

        vswr_dict = convert_to_dict(list(filter(None, vswr_data)))
        rtwp_dict = convert_to_dict(list(filter(None, rtwp_data)))
        rssi_dict = convert_to_dict(list(filter(None, rssi_data)))
        etp_dict = convert_to_dict(list(filter(None, etp_data)))

        return {
            "VSWR": vswr_dict,
            "RTWP": rtwp_dict,
            "RSSI": rssi_dict,
            "ETP": etp_dict
        }


def _match_timestamp(key):
    """
    Matches a timestamp in the given key using a regex pattern.

    Args:
        key (str): The key to search for a timestamp.

    Returns:
        datetime or None: The matched timestamp as a datetime object, or None if no match is found.
    """
    re_timestamp = re.compile(r'\d{2}\.\d{2}\.\d{4} \d{2}:\d{2}:\d{2}')
    matched_timestamp = re.search(re_timestamp, key)
    if matched_timestamp:
        return datetime.strptime(matched_timestamp.group(0), "%d.%m.%Y %H:%M:%S")
    return None


def _validate_numeric_value(value, expected_value, deviation):
    """
    Validates a numeric value against the expected value and deviation.

    Args:
        value (str): The value to validate.
        expected_value (float): The expected numeric value.
        deviation (float): The allowed deviation.

    Returns:
        bool: True if the value is valid, False otherwise.
    """
    try:
        numeric_value = float(value)
        return deviation is not None and abs(numeric_value - expected_value) < deviation
    except ValueError:
        logging.warning(f"Non-numeric value encountered: {value}")
        return False


def _validate_string_value(value, expected_value):
    """
    Validates a string value against the expected value.

    Args:
        value (str): The value to validate.
        expected_value (str): The expected string value.

    Returns:
        bool: True if the value matches the expected value, False otherwise.
    """
    return value == expected_value


def _validate_value(current, expected, deviation, is_numeric_data):
    """
    Validates a value against the expected value, considering its type and an optional deviation.

    Args:
        current (str): The current value to validate.
        expected (int, float, or str): The expected value to compare against.
        deviation (int or float): The allowed deviation for numeric values. Ignored for string validation.
        is_numeric_data (bool): Indicates whether the value is numeric (True) or a string (False).

    Returns:
        bool: True if the value is valid (matches the expected value or is within the allowed deviation),
              False otherwise.
    """
    return _validate_numeric_value(current, expected, deviation) if is_numeric_data else \
        _validate_string_value(current, expected)


def _check_event_values(cell_data, expected, event_start_time, event_end_time, carrier_type,
                        event_delay=20, idle_state=False, interval=10):
    """
    Validates monitoring values during an event or idle state.

    Args:
        carrier_type (str): Type of carrier (e.g., RX or TX).
        cell_data (dict): Monitoring data for a specific cell.
        expected (dict): Expected value and deviation during the event.
        event_start_time (datetime): Start time of the event.
        event_end_time (datetime): End time of the event.
        event_delay (int, optional): Delay in seconds for data validation. Defaults to 20.
        idle_state (bool, optional): If True, validates idle state (after event finishes). Defaults to False.
        interval  (int, optional): Interval of monitoring data in seconds. Defaults to 10.

    Returns:
        str: Carrier type if invalid values are found, otherwise None.
    """
    valid_values, invalid_values = {}, {}
    is_numeric = isinstance(expected["value"], (int, float))

    def timestamp_in_range(timestamp, is_idle):
        if is_idle:
            return timestamp >= event_end_time + timedelta(seconds=event_delay)
        return event_start_time + timedelta(seconds=event_delay) <= timestamp <= event_end_time - timedelta(
            seconds=interval)

    for key, value in cell_data.items():
        data_timestamp = _match_timestamp(key)
        if data_timestamp and timestamp_in_range(data_timestamp, idle_state):
            if _validate_value(value, expected["value"], expected["deviation"], is_numeric):
                valid_values[data_timestamp] = value
            else:
                invalid_values[data_timestamp] = value

    if valid_values and not invalid_values:
        logging.info(f'Found in section "{cell_data[f"{carrier_type} carrier"]}": "{len(valid_values)}" '
                     f'valid values in {"idle" if idle_state else "event"} state:\n"{valid_values}"')
    else:
        logging.warning(
            f'{"Not found any valid monitoring value" if not valid_values else "Found improper monitoring values"} '
            f'in section "{cell_data[f"{carrier_type} carrier"]}" '
            f'{"after event finished in idle" if idle_state else "in event"} state:\n"{invalid_values}".')
        return cell_data[f"{carrier_type} carrier"]


def check_antenna_monitoring_data_timestamps_interval(monitoring_data, expected_interval=10, sampling_deviation=1,
                                                      carrier_type="RX"):
    """
    Checks if the interval between timestamps in the antenna monitoring data match the expected interval.

    :param monitoring_data: List of dicts containing parsed antenna monitoring output data.
    :type monitoring_data: list
    :param expected_interval: Expected interval between timestamps in seconds.
    :type expected_interval: int
    :param sampling_deviation: The sampling deviation in seconds. Introduced for OAM_REQ_WEBEM_6711 changes (PR817084).
    :type sampling_deviation: int
    :param carrier_type: The type of carrier: RX or TX. ANTLMonitoring csv output parameter. Defaults to RX.
    :type carrier_type: str
    :raises: InvalidTimestampIntervalException if any timestamps interval does not match the expected interval.
    """
    for cell_data in monitoring_data:
        timestamps = [datetime.strptime(
            time[2:-1] if time.startswith('="') and time.endswith('"') else time, "%d.%m.%Y %H:%M:%S") for time
            in cell_data if time not in ['Antenna/Port', f"{carrier_type} carrier", 'Radio module']]
        for i in range(len(timestamps) - 1):
            actual_interval = (timestamps[i + 1] - timestamps[i]).total_seconds()
            if float(actual_interval) < float(expected_interval - sampling_deviation):
                raise InvalidTimestampIntervalException(cell_data[f"{carrier_type} carrier"],
                                                        f"{timestamps[i + 1]} - {timestamps[i]}",
                                                        expected_interval, actual_interval)
        logging.info(f"Each timestamp from section '{cell_data[f'{carrier_type} carrier']}'"
                     f" has interval >= '{expected_interval}s'. Req OAM_REQ_WEBEM_6711 was met.")


def check_cells_in_antenna_monitoring_data(monitoring_data, cells=None, carrier_type="RX"):
    """
    Checks if cells exist in the antenna monitoring data.

    :param monitoring_data: List of dicts containing parsed antenna monitoring output data.
    :type monitoring_data: list
    :param cells: Lst of NR cells. All runtime BTS cells if None.
    :type cells: list
    :param carrier_type: The type of carrier: RX or TX. ANTLMonitoring csv output parameter. Defaults to RX.
    :type carrier_type: str
    :raises: MissingCellException if any cell not in monitoring data.
    """

    def get_cell_ids_from_monitoring_data(data):
        return [cell_data[f"{carrier_type} carrier"] for cell_data in data]

    cells_to_check = cells if cells else CellOperations().get_current_cells_dist_name(base_cell_name=True)
    missing_cells = [cell for cell in cells_to_check if
                     cell not in get_cell_ids_from_monitoring_data(monitoring_data)]
    if missing_cells:
        raise MissingCellException(missing_cells)
    else:
        logging.info(f"All expected BTS cells found in monitoring data: {cells_to_check}.")


def check_antenna_monitoring_values_during_event(monitoring_data, event_time, expected, cells=None,
                                                 carrier_type="RX", event_delay=20, idle_state=False):
    """
    Checks the antenna monitoring values during a specified event or idle state.

    This function validates the monitoring values for a given event or idle state by comparing the actual values
    in the monitoring data against the expected values within the specified time interval.

    Args:
        monitoring_data (list): List of dictionaries containing parsed antenna monitoring output data.
        event_time (dict): Dictionary with keys 'start_time' and 'end_time' representing the event time interval.
                           Example: {'start_time': '01-01-2023 12:00:00', 'end_time': '01-01-2023 12:30:00'}.
        expected (dict): Dictionary containing the expected value and allowed deviation.
                         Example: {'value': 10, 'deviation': 2}.
        cells (list, optional): List of cell identifiers to validate. If None, all cells are validated.
                                Example: ['NRCELL-1', 'NRCELL-2'].
        carrier_type (str, optional): The type of carrier to validate (e.g., "RX" or "TX"). Defaults to "RX".
        event_delay (int, optional): Delay in seconds to account for data validation after the event start time.
                                     Defaults to 20.
        idle_state (bool, optional): If True, validates the idle state (after the event). Defaults to False.

    Raises:
        InvalidMonitoringValueException: Raised if any monitoring values are invalid during the event or idle state.
    """
    start_time = datetime.strptime(event_time['start_time'], "%d-%m-%Y %H:%M:%S")
    end_time = datetime.strptime(event_time['end_time'], "%d-%m-%Y %H:%M:%S")
    invalid_sections = []

    if cells:
        monitoring_data = [cell_data for cell_data in monitoring_data if cell_data[f"{carrier_type} carrier"] in cells]
    for cell_data in monitoring_data:
        invalid_section = _check_event_values(cell_data, expected, start_time, end_time, carrier_type,
                                              event_delay, idle_state)
        if invalid_section:
            invalid_sections.append(invalid_section)
    if invalid_sections:
        range_msg = [f'during event interval: {start_time} - {end_time}' if not idle_state else
                     f'after event end time: {end_time}']
        raise InvalidMonitoringValueException(f"{', '.join(invalid_sections)}",
                                              '"{}" {}'.format(expected["value"], range_msg[0]))


@load_moler_configuration_from_tl()
def get_current_bts_datetime(options="", timeout=180, bts_id=0, du_id=0):
    """
    Get current BTS date and time.

    Args:
        options (str, optional): Options to be used with the date command. Defaults to an empty string.
        timeout (int, optional): Timeout for the command in seconds. Defaults to 180.
        bts_id (int, optional): BTS ID. Defaults to 0.
        du_id (int, optional): Distributed Unit (DU) ID. Defaults to 0.

    Returns:
        str: date and time.
    """
    device = DeviceFactory.get_device(name=ssh_bts_du.format("GNB", bts_id, du_id), initial_state='FCT')
    cmd_date = device.get_cmd(cmd_name='date', cmd_params={"options": options})(timeout=timeout)
    return " ".join([cmd_date["DATE"]['FULL'], cmd_date["TIME"]['FULL']])


def modify_cells_to_check(validation_data, measurement_type, cells_to_check):
    """
    Modify the cells to check in the monitoring settings.

    Args:
        validation_data (dict): The monitoring settings dictionary.
        measurement_type (str): The measurement type to modify.
        cells_to_check (list): The list of cells to check.

    """
    if measurement_type in validation_data:
        validation_data[measurement_type]["cells_to_check"] = cells_to_check
    else:
        raise KeyError(f"'{measurement_type}' not found in given monitoring settings: '{validation_data}'.")


def select_random_dict_element(input_dict):
    """
    Selects a random element from a dictionary.

    Args:
        input_dict (dict): The dictionary to select a random element from.

    Returns:
        The randomly selected element from the dictionary.
    """
    random_key = random.choice(list(input_dict.keys()))
    logging.info(f"Randomly selected element from dictionary: {random_key}")
    return input_dict[random_key]


def extract_data_transfer_time_related_to_measurement(time, carrier_type):
    return time['DL'] if carrier_type == 'TX' else time['UL']
