"""
Author: pengliang.wu@nokia.com
Description: This keyword for Counter and related Kpi calculation
"""

import csv  # CSV file read/write
import re  # Regular expressions
from datetime import datetime, timedelta  # Time processing
import os  # System path operations
from taf.sbts.oam.coam.admin import admin  # OAM API

# Initialize API connection
api = admin()

# Mapping from counter ID to KPI name
# Define friendly names for various performance counters
COUNTER_KPI_NAME = {
    'M55349C04002': 'DL_RLC_PDU_TIME_UE_TPUT',
    'M55349C03002': 'DL_RLC_PDU_VOL_UE_TPUT',
    'NR_5904a': '5G DL MAC SDU UE Throughput at P(S)Cell for FR1(Mbit/s)',
    'M55139C01002': 'GNB_DU_SCELL_ADMI_SUCC_SA',
    'M55139C01001': 'GNB_DU_SCELL_ADMI_REQ_SA',
    'NR_1473a': '5G SA DU SCell admission success ratio for SCells in SCell(%)',
    'M55139C01004': 'GNB_DU_SCELL_1_ADMI_SUCC_SA',
    'M55139C01502': 'GNB_DU_SCELL_2_ADMI_SUCC_SA',
    'M55139C03002': 'GNB_DU_SCELL_3_ADMI_SUCC_SA',
    'M55139C00024': 'GNB_DU_SCELL_4_ADMI_SUCC_SA',
    'M55139C03006': 'GNB_DU_SCELL_5_ADMI_SUCC_SA',
    'M55139C03007': 'GNB_DU_SCELL_6_ADMI_SUCC_SA',
    'M55139C03008': 'GNB_DU_SCELL_7_ADMI_SUCC_SA',
    'M55139C01003': 'GNB_DU_SCELL_1_ADMI_REQ_SA',
    'M55139C01501': 'GNB_DU_SCELL_2_ADMI_REQ_SA',
    'M55139C03001': 'GNB_DU_SCELL_3_ADMI_REQ_SA',
    'M55139C00023': 'GNB_DU_SCELL_4_ADMI_REQ_SA',
    'M55139C03003': 'GNB_DU_SCELL_5_ADMI_REQ_SA',
    'M55139C03004': 'GNB_DU_SCELL_6_ADMI_REQ_SA',
    'M55139C03005': 'GNB_DU_SCELL_7_ADMI_REQ_SA',
    'NR_5523c': '5G SA SCell admission success ratio for SCell(s) in PCell (DU level)(%)',
    'M55113C00002': 'F1_UE_CTXT_MOD_RESP_RECEIVED',
    'M55113C00001': 'F1_UE_CTXT_MOD_REQ_SENT',
    'NR_46a': '5G UE context modification success ratio(%)',
    'M55118C10501': 'SCELL_SWAP_1_ATT_SA',
    'M55118C10502': 'SCELL_SWAP_1_SUCC_SA',
    'swap': 'swap succ ratio(%)',
}

# Mapping from KPI ID to related counter IDs
# Each KPI requires multiple counters for calculation
COUNTER_KPI_MAPPING = {
    'NR_5904a': 'M55349C03002,M55349C04002',
    'NR_1473a': 'M55139C01002,M55139C01001',
    'NR_5523c': 'M55139C01004,M55139C01502,M55139C03002,M55139C00024,M55139C03006,M55139C03007,M55139C03008,'
                'M55139C01003,M55139C01501,M55139C03001,M55139C00023,M55139C03003,M55139C03004,M55139C03005',
    'NR_46a': 'M55113C00001,M55113C00002',
    'swap': 'M55118C10501,M55118C10502',
}


def get_counter_ids_by_kpi(kpi_ids=None):
    """
    Get corresponding counter ID list based on KPI ID

    Args:
        kpi_ids (str): Comma-separated KPI ID string, None means get counters for all KPIs

    Returns:
        str: Comma-separated counter ID string
    """
    counter_ids = ''
    # Split KPI ID string into list
    kpi_id_list = kpi_ids.split(',') if kpi_ids else None

    # Iterate through KPI mapping to collect corresponding counter IDs
    if kpi_id_list is None or isinstance(kpi_id_list, list):
        for kpi_id, counters in COUNTER_KPI_MAPPING.items():
            if kpi_id_list is None or kpi_id in kpi_id_list:
                counter_ids += counters + ','

    # Remove trailing comma
    counter_ids = counter_ids[:-1] if counter_ids[-1] == ',' else counter_ids
    return counter_ids


def unix_timestamp_to_datetime(timestamp, timezone_offset=0):
    """
    Convert Unix timestamp to datetime format: yyyy-mm-dd hh:mm:ss

    Args:
        timestamp (int/float/str): Unix timestamp (seconds)
        timezone_offset (int): Timezone offset in hours, default 0 (UTC time)

    Returns:
        str: Formatted time string "yyyy-mm-dd hh:mm:ss"

    Examples:
        >>> unix_timestamp_to_datetime(1768773060)
        '2025-12-31 12:51:00'
        >>> unix_timestamp_to_datetime('1768773060', 8)  # UTC+8
        '2025-12-31 20:51:00'
    """
    try:
        # Convert to float for processing
        if isinstance(timestamp, str):
            timestamp = float(timestamp)
        elif isinstance(timestamp, int):
            timestamp = float(timestamp)

        # Create datetime object
        dt = datetime.fromtimestamp(timestamp)

        # Apply timezone offset
        if timezone_offset != 0:
            dt = dt + timedelta(hours=timezone_offset)

        # Format to specified format
        formatted_time = dt.strftime('%Y-%m-%d %H:%M:%S')

        return formatted_time

    except (ValueError, TypeError, OSError) as e:
        return f"Invalid timestamp: {timestamp}"


class CounterObject():
    """
    Counter Object Class - Used to process nested counter data dictionaries

    Main functions:
    1. Flatten nested dictionaries
    2. Search keys based on filter conditions
    3. Calculate KPI values
    4. Export CSV files
    """

    def __init__(self):
        """Initialize counter object"""
        self.separator = '/'  # Separator used during flattening
        self.new_dict = {}  # Store flattened dictionary

    def setCounterData(self, counter_dict):
        """
        Set original counter data

        Args:
            counter_dict (dict): Original nested counter data dictionary
        """
        self.counter_dict = counter_dict

    def flatten_dict(self, nested_dict, parent_key=''):
        """
        Flatten nested dictionary into single-layer dictionary

        Args:
            nested_dict (dict): Nested dictionary to be flattened
            parent_key (str): Parent key name, used to build complete path

        Returns:
            dict: Flattened dictionary with path as key and final data as value

        Example:
            Input: {'a': {'b': {'c': 123}}}
            Output: {'/a/b/c/': 123}
        """
        result = {}

        for key, value in nested_dict.items():
            # Build new key path
            new_key = f"{parent_key}{self.separator}{key}" if parent_key else key

            if isinstance(value, dict):
                # Check if this dictionary has nested dictionaries
                has_nested_dict = any(isinstance(v, dict) for v in value.values())
                if has_nested_dict:
                    # If there are nested dictionaries, process recursively
                    result.update(self.flatten_dict(value, new_key))
                else:
                    # If no nested dictionaries, this is our final value
                    # Add separators before and after key for easier searching
                    result[f'{self.separator}{new_key}{self.separator}'] = value
            else:
                # If not a dictionary, assign directly
                result[f'{self.separator}{new_key}{self.separator}'] = value

        # Save flattening result to instance variable
        self.new_dict = result
        return result

    def getValidKpiData(self):
        kpi_dict = {}
        for key, value in self.new_dict.items():
            if key.startswith('[kpi]'):
                if value['total'] != '-':
                    kpi_dict[key] = value['total']
        return kpi_dict

    def get_flatten_dict(self):
        """
        Get flattened dictionary

        Returns:
            dict: Flattened dictionary
        """
        return self.new_dict

    def get_key_with_filter(self, filters):
        """
        Find matching key based on filter conditions

        Args:
            filters (list): Filter condition list, key must contain all filter conditions

        Returns:
            str: First matching key, return None if not found

        Example:
            filters = ['NRCELL-1', 'M55349C03002']
            Will find the first key containing both conditions
        """
        find_key = None

        for key in self.new_dict.keys():
            isMatched = True  # Assume match

            # Check if contains all filter conditions
            for filter in filters:
                if f'{self.separator}{filter}{self.separator}' not in key:
                    isMatched = False
                    break

            if isMatched:
                find_key = key
                break

        return find_key

    def get_key_with_regexp(self, pattern):
        """
        Find matching key based on regular expression

        Args:
            pattern (str): Regular expression pattern

        Returns:
            str: First matching key, return None if not found
        """
        find_key = None

        for key in self.new_dict.keys():
            matches = re.search(pattern, key)
            if matches is not None:
                find_key = key
                break

        return find_key

    def get_counter_lastest_timestamp(self, counter_dict):
        """
        Get latest timestamp from counter data

        Args:
            counter_dict (dict): Original counter data dictionary

        Returns:
            str/int: Latest timestamp
        """
        self.counter_latest_timestamp = 0
        self.setCounterData(counter_dict)

        # Flatten dictionary for timestamp search
        new_counter_dict = self.flatten_dict(nested_dict=counter_dict)

        # Get all timestamps from first counter and find maximum value
        for key, values in new_counter_dict.items():
            timestamp_list = values.keys()
            self.counter_latest_timestamp = max(timestamp_list)
            break  # Only need the first one, all counters should have same timestamps

        return self.counter_latest_timestamp

    def flatten_conter_to_csv(self, output_path='', filename='kpi'):
        """
        Export flattened counter data to CSV file

        Args:
            output_path (str): Output folder path
            filename (str): Output filename prefix

        Returns:
            str: Complete path of output file

        CSV format:
            - First row: Header (Time + counter paths)
            - Second row: Counter names
            - Data rows: Timestamp corresponding counter values
        """
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = os.path.join(output_path, f'{filename}_{timestamp}.csv')

        # Check if flattened data exists
        if not hasattr(self, 'new_dict') or not self.new_dict:
            print("Error: No flattened data, please call flatten_dict method first")
            return None

        # Collect all timestamps (row indices)
        all_timestamps = set()
        for key, value_dict in self.new_dict.items():
            if isinstance(value_dict, dict):
                all_timestamps.update(value_dict.keys())

        # Sort timestamps (descending order, latest first)
        sorted_timestamps = sorted(all_timestamps, reverse=True)

        # Get all column names (flattened keys)
        column_names = list(self.new_dict.keys())

        # Write to CSV file
        with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)

            # Write header (first column is Time, subsequent columns are counter paths)
            header = ['Time'] + column_names
            writer.writerow(header)

            # Write second row: counter friendly names
            # Extract counter ID from path and find corresponding friendly name
            counter_names = \
                [COUNTER_KPI_NAME.get(column_name.split(self.separator)[-2], '') for column_name in column_names]
            header2 = ['Counter Name'] + counter_names
            writer.writerow(header2)

            # Write data rows
            for timestamp in sorted_timestamps:
                row = [timestamp]  # First column is timestamp

                # Iterate through each counter column
                for column_key in column_names:
                    value_dict = self.new_dict[column_key]
                    if isinstance(value_dict, dict):
                        # Get value corresponding to timestamp, empty string if not exists
                        cell_value = value_dict.get(timestamp, '')
                        row.append(cell_value)
                    else:
                        # If not a dictionary, use the value directly
                        row.append(value_dict)

                # Convert timestamp to readable date time format
                if timestamp != 'total':
                    row[0] = unix_timestamp_to_datetime(timestamp)
                writer.writerow(row)

        print(f"CSV file saved to: {output_file}")
        print(f"Total {len(sorted_timestamps)} rows of data, {len(column_names)} columns written")
        return output_file

    def calculate_kpi_by_ids(self, counter_object_patterns='/NRCELL-1/,/NRCELL-2/', kpi_ids='NR_5904a,NR_1473a'):
        """
        Batch calculate multiple KPIs for multiple objects

        Args:
            counter_object_patterns (str): Comma-separated object pattern string for matching flattened keys
            kpi_ids (str): Comma-separated KPI ID string

        Note:
            Flattened key format example: /BTS/MRBTS-11388/NRBTS-37520/NRCELL-5/NF1CC/M55113C00002/
            counter_object_pattern uses regex to match these keys
        """
        kpi_id_list = kpi_ids.split(',')
        counter_object_pattern_list = counter_object_patterns.split(',')

        # Calculate KPI for each object pattern and KPI combination
        for kpi_id in kpi_id_list:
            for counter_object_pattern in counter_object_pattern_list:
                self.calculate_kpi(counter_object_pattern=counter_object_pattern, kpi_id=kpi_id)

    def calculate_kpi(self, counter_object_pattern='/NRCELL-1/', kpi_id='NR_5904a'):
        """
        Calculate single KPI value

        Args:
            counter_object_pattern (str): Object pattern for matching related counters
            kpi_id (str): KPI ID to calculate

        Supported KPIs:
            - NR_5904a: 5G DL MAC SDU UE Throughput
            - NR_1473a: 5G SA DU SCell admission success ratio
            - NR_5523c: 5G SA SCell admission success ratio
            - NR_46a: 5G UE context modification success ratio
        """
        # Create new key for calculation result
        kpi_key = f'[kpi]{counter_object_pattern}_{self.separator}{kpi_id}{self.separator}'
        self.new_dict.setdefault(kpi_key, {})

        # Execute different calculation logic based on different KPI IDs
        if kpi_id == 'NR_5904a':
            # 5G DL MAC SDU UE Throughput calculation
            # Formula: M55349C03002 / M55349C04002 (bytes / time = throughput)
            M55349C03002_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55349C03002/')
            M55349C04002_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55349C04002/')

            if M55349C03002_key and M55349C04002_key:
                timestamp_list = self.new_dict[M55349C03002_key].keys()

                for timestamp in timestamp_list:
                    M55349C03002_value = self.new_dict[M55349C03002_key][timestamp]
                    M55349C04002_value = self.new_dict[M55349C04002_key][timestamp]

                    # Exception handling
                    if M55349C04002_value == 0 and M55349C03002_value != 0:
                        self.new_dict[kpi_key][timestamp] = 'Error, Need Check'
                    elif M55349C04002_value == 0 and M55349C03002_value == 0:
                        self.new_dict[kpi_key][timestamp] = '-'
                    else:
                        # Normal calculation: throughput = data volume / time
                        self.new_dict[kpi_key][timestamp] = str(M55349C03002_value / M55349C04002_value) + 'Mbit/s'
        if kpi_id == 'NR_1473a':
            # 5G SA DU SCell admission success ratio calculation
            # Formula: (success count / request count) * 100%
            M55139C01002_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C01002/')
            M55139C01001_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C01001/')
            M55139C01002_value_total, M55139C01001_value_total = 0, 0
            if M55139C01002_key and M55139C01001_key:
                timestamp_list = self.new_dict[M55139C01002_key].keys()

                for timestamp in timestamp_list:
                    M55139C01002_value = self.new_dict[M55139C01002_key][timestamp]  # Success count
                    M55139C01001_value = self.new_dict[M55139C01001_key][timestamp]  # Request count

                    # Data anomaly check: success count cannot be greater than request count
                    if M55139C01002_value > M55139C01001_value:
                        self.new_dict[kpi_key][timestamp] = 'Error, Need Check'
                    elif M55139C01002_value == 0 and M55139C01001_value == 0:
                        self.new_dict[kpi_key][timestamp] = '-'
                    else:
                        # Calculate success ratio percentage
                        self.new_dict[kpi_key][timestamp] = str(100 * M55139C01002_value / M55139C01001_value) + '%'
                    M55139C01002_value_total += M55139C01002_value
                    M55139C01001_value_total += M55139C01001_value
                if M55139C01001_value_total > 0:
                    self.new_dict[kpi_key]['total'] = \
                        str(100 * M55139C01002_value_total / M55139C01001_value_total)
                else:
                    self.new_dict[kpi_key]['total'] = '-'
        if kpi_id == 'NR_5523c':
            # 5G SA SCell admission success ratio calculation (multiple SCell aggregation)
            # Need to aggregate success and request counts from multiple SCells

            # Get all related counter keys - success counters
            M55139C01004_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C01004/')
            M55139C01502_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C01502/')
            M55139C03002_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C03002/')
            M55139C00024_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C00024/')
            M55139C03006_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C03006/')
            M55139C03007_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C03007/')
            M55139C03008_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C03008/')

            # Get all related counter keys - request counters
            M55139C01003_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C01003/')
            M55139C01501_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C01501/')
            M55139C03001_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C03001/')
            M55139C00023_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C00023/')
            M55139C03003_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C03003/')
            M55139C03004_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C03004/')
            M55139C03005_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55139C03005/')

            all_sum_req, all_sum_succ = 0, 0
            if M55139C01004_key:  # Ensure at least one counter exists
                timestamp_list = self.new_dict[M55139C01004_key].keys()

                for timestamp in timestamp_list:
                    # Get all success counter values
                    M55139C01004_value = self.new_dict[M55139C01004_key][timestamp]
                    M55139C01502_value = self.new_dict[M55139C01502_key][timestamp]
                    M55139C03002_value = self.new_dict[M55139C03002_key][timestamp]
                    M55139C00024_value = self.new_dict[M55139C00024_key][timestamp]
                    M55139C03006_value = self.new_dict[M55139C03006_key][timestamp]
                    M55139C03007_value = self.new_dict[M55139C03007_key][timestamp]
                    M55139C03008_value = self.new_dict[M55139C03008_key][timestamp]

                    # Get all request counter values
                    M55139C01003_value = self.new_dict[M55139C01003_key][timestamp]
                    M55139C01501_value = self.new_dict[M55139C01501_key][timestamp]
                    M55139C03001_value = self.new_dict[M55139C03001_key][timestamp]
                    M55139C00023_value = self.new_dict[M55139C00023_key][timestamp]
                    M55139C03003_value = self.new_dict[M55139C03003_key][timestamp]
                    M55139C03004_value = self.new_dict[M55139C03004_key][timestamp]
                    M55139C03005_value = self.new_dict[M55139C03005_key][timestamp]

                    # Calculate total success and request counts
                    sum_succ = sum([M55139C01004_value, M55139C01502_value, M55139C03002_value, M55139C00024_value,
                                    M55139C03006_value, M55139C03007_value, M55139C03008_value])
                    sum_req = sum([M55139C01003_value, M55139C01501_value, M55139C03001_value, M55139C00023_value,
                                   M55139C03003_value, M55139C03004_value, M55139C03005_value])

                    # Data anomaly check and calculation
                    if sum_succ > sum_req:
                        self.new_dict[kpi_key][timestamp] = 'Error, Need Check'
                    elif sum_succ == 0 and sum_req == 0:
                        self.new_dict[kpi_key][timestamp] = '-'
                    else:
                        # Calculate total success ratio
                        self.new_dict[kpi_key][timestamp] = str(100 * sum_succ / sum_req) + '%'
                    all_sum_req += sum_succ
                    all_sum_succ += sum_req
                    if all_sum_req > 0:
                        self.new_dict[kpi_key]['total'] = str(100 * all_sum_succ / all_sum_req)
                    else:
                        self.new_dict[kpi_key]['total'] = '-'
        if kpi_id == 'NR_46a':
            # 5G UE context modification success ratio calculation
            # Formula: (response count / request count) * 100%
            M55113C00002_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55113C00002/')  # Response
            M55113C00001_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55113C00001/')  # Request
            M55113C00002_value_total, M55113C00001_value_total = 0, 0
            if M55113C00002_key and M55113C00001_key:
                timestamp_list = self.new_dict[M55113C00002_key].keys()

                for timestamp in timestamp_list:
                    M55113C00002_value = self.new_dict[M55113C00002_key][timestamp]  # Response count
                    M55113C00001_value = self.new_dict[M55113C00001_key][timestamp]  # Request count

                    # Data anomaly check: response count cannot be greater than request count
                    if M55113C00002_value > M55113C00001_value:
                        self.new_dict[kpi_key][timestamp] = 'Error, Need Check'
                    elif M55113C00002_value == 0 and M55113C00001_value == 0:
                        self.new_dict[kpi_key][timestamp] = '-'
                    else:
                        # Calculate success ratio percentage
                        self.new_dict[kpi_key][timestamp] = str(100 * M55113C00002_value / M55113C00001_value) + '%'
                    M55113C00002_value_total += M55113C00002_value
                    M55113C00001_value_total += M55113C00001_value
                if M55113C00001_value_total > 0:
                    self.new_dict[kpi_key]['total'] = \
                        str(100 * M55113C00002_value_total / M55113C00001_value_total)
                else:
                    self.new_dict[kpi_key]['total'] = '-'
        if kpi_id == 'swap':
            M55118C10502_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55118C10502/')
            M55118C10501_key = self.get_key_with_regexp(pattern=f'{counter_object_pattern}.*/M55118C10501/')
            M55118C10502_value_total, M55118C10501_value_total = 0, 0
            if M55118C10502_key and M55118C10501_key:
                timestamp_list = self.new_dict[M55118C10502_key].keys()

                for timestamp in timestamp_list:
                    M55118C10502_value = self.new_dict[M55118C10502_key][timestamp]  # Success count
                    M55118C10501_value = self.new_dict[M55118C10501_key][timestamp]  # Request count

                    # Data anomaly check: success count cannot be greater than request count
                    if M55118C10502_value > M55118C10501_value:
                        self.new_dict[kpi_key][timestamp] = 'Error, Need Check'
                    elif M55118C10502_value == 0 and M55118C10501_value == 0:
                        self.new_dict[kpi_key][timestamp] = '-'
                    else:
                        # Calculate success ratio percentage
                        self.new_dict[kpi_key][timestamp] = str(100 * M55118C10502_value / M55118C10501_value) + '%'
                    M55118C10502_value_total += M55118C10502_value
                    M55118C10501_value_total += M55118C10501_value
                if M55118C10501_value_total > 0:
                    self.new_dict[kpi_key]['total'] = \
                        str(100 * M55118C10502_value_total / M55118C10501_value_total)
                else:
                    self.new_dict[kpi_key]['total'] = '-'


def oam_get_pm_counters(bts_host, counter_ids):
    """
    Get performance counter data via OAM API

    Args:
        bts_host (str): BTS host address
        counter_ids (str): Counter ID list (comma-separated)

    Returns:
        dict: Counter data dictionary
    """
    counter_data = {}
    connection = None

    try:
        # Connect to BTS
        connection = api.connect_to(bts_host=bts_host)
        # Get counter data
        counter_data = api.get_pm_counters(counter_ids=counter_ids, connection=connection)
    except Exception as e:
        print('Connection or counter retrieval error:' + str(e))
    finally:
        # Ensure connection is properly closed
        try:
            if connection:
                api.teardown(connection=connection)
        except Exception as e:
            print('Disconnect error:' + str(e))

    return counter_data


def calculate_kpi_via_counter(bts_host, counter_object_patterns, output_path, counter_ids=None, kpi_ids=None,
                              filename='kpi', calculate_kpi=True):
    """
    Calculate KPIs via counter data and export to CSV file

    Args:
        bts_host (str): BTS host address
        kpi_ids (str): KPI ID list to calculate (comma-separated)
        counter_object_patterns (str): Object pattern list (comma-separated)
        output_path (str): Output folder path
        filename (str): Output filename prefix

    Returns:
        dict: {'output_filename': output_file, 'flatten_dict': flatten_dict}

    Process:
    1. Get required counter ID list based on KPI IDs
    2. Retrieve raw counter data from BTS
    3. Flatten nested counter data
    4. Calculate each KPI based on formulas
    5. Export results to CSV file
    """
    # 1. Get counter ID list
    if counter_ids is None:
        counter_ids = get_counter_ids_by_kpi(kpi_ids=kpi_ids)
    else:
        calculate_kpi = False

    # 2. Get raw counter data from BTS
    counter_data = oam_get_pm_counters(bts_host=bts_host, counter_ids=counter_ids)

    # 3. Create counter object and process data
    counter_obj = CounterObject()
    counter_obj.setCounterData(counter_dict=counter_data)
    counter_obj.flatten_dict(nested_dict=counter_data)

    # 4. Calculate KPIs
    if calculate_kpi:
        counter_obj.calculate_kpi_by_ids(counter_object_patterns=counter_object_patterns, kpi_ids=kpi_ids)

    flatten_dict = counter_obj.get_flatten_dict()

    kpi_dict = counter_obj.getValidKpiData()

    # 5. Export to CSV
    output_file = counter_obj.flatten_conter_to_csv(output_path=output_path, filename=filename)
    print(f'KPI results saved to: {output_file}')

    return {'output_file': output_file, 'flatten_dict': flatten_dict, 'kpi_dict': kpi_dict}


if __name__ == '__main__':
    pass
