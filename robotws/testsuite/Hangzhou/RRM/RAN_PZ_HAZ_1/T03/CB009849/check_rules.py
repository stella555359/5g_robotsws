import csv

import os


def find_all_csv_file(directory):
    """
    Searches for a CSV file in the specified directory.
    Returns the path of the first CSV file found, or None if no CSV file is found.
    """
    csv_list = []
    for filename in os.listdir(directory):
        if filename.endswith('.csv'):
            csv_list.append(os.path.join(directory, filename))
    return csv_list


def check_rules(csv_file_path, input_mcs1, input_mcs2, input_mcs3):
    if not os.path.isfile(csv_file_path):
        print(f"Error: File '{csv_file_path}' does not exist.")
        return

    # Find the folder where the csv file exists
    log_folder = os.path.dirname(os.path.abspath(csv_file_path))
    print(f"Log folder: {log_folder}")

    # Find the csv file in decoded_log folder under the log folder
    decoded_log_folder = os.path.join(log_folder, "decoded_log")
    if not os.path.isdir(decoded_log_folder):
        print(f"Error: decoded_log folder '{decoded_log_folder}' does not exist.")
        return

    csv_files = find_all_csv_file(decoded_log_folder)
    if not csv_files:
        print(f"No CSV files found in '{decoded_log_folder}'.")
        return

    # Find and check all CSV files in decoded_log folder
    any_violated = False
    for csv_file_path in csv_files:
        print(f"Using CSV file: {csv_file_path}")
        with open(csv_file_path, newline='') as csvfile:
            reader = csv.DictReader(csvfile)

            def parse_int(val):
                if val is None or val.strip() == '':
                    return 0
                try:
                    return float(val)
                except ValueError:
                    return 0.0

            for idx, row in enumerate(reader, 1):
                try:
                    b1 = parse_int(row.get('dlFdSchedData.scheduledBytesPerBearer[1]', '0'))
                    b2 = parse_int(row.get('dlFdSchedData.scheduledBytesPerBearer[2]', '0'))
                    b5 = parse_int(row.get('dlFdSchedData.scheduledBytesPerBearer[4]', '0'))
                    b6 = parse_int(row.get('dlFdSchedData.scheduledBytesPerBearer[6]', '0'))
                    mcs = parse_int(row.get('dlFdSchedData.rrmDlUsedMcs', '0'))
                    layers = row.get('dlFdSchedData.numOfLayers', '')
                    dciformat = row.get('dlFdSchedData.dciFormat', '')
                    cqi = parse_int(row.get('dlFdSchedData.rrmCorrAvgCqi', '0'))
                except (KeyError, ValueError) as e:
                    print(f"Row {idx}: Error parsing fields: {e}")
                    any_violated = True
                    continue

                violated = False
                # Rule 1
                if (b1 > 0 or b2 > 0):
                    if not (mcs <= input_mcs1 and (layers == 'RANK1' or layers == 'RANK2')):
                        print(f"Row {idx}: Violates Rule 1 | mcs: {mcs}, layers: {layers}")
                        violated = True
                # Rule 2
                elif (b1 == 0 and b2 == 0 and b5 > 0 and dciformat != 'DL_10_FORCE'):
                    if not (mcs <= input_mcs2 and (layers == 'RANK1' or layers == 'RANK2')):
                        print(f"Row {idx}: Violates Rule 2 | mcs: {mcs}, layers: {layers}")
                        violated = True
                # Rule 3
                elif (b1 == 0 and b2 == 0 and b5 == 0 and b6 > 0):
                    if not (mcs <= input_mcs3 and layers == 'RANK1' and cqi <= 15):
                        print(f"Row {idx}: Violates Rule 3 | mcs: {mcs}, layers: {layers}, cqi: {cqi}")
                        violated = True

                if violated:
                    any_violated = True

    if any_violated:
        print("Check done: some rules failed")
        return False
    else:
        print("Check done: All rules passed")
        return True
