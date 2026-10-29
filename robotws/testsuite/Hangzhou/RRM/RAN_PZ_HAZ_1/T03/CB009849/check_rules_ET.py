import csv

import os


def find_all_csv_file(directory, direction='dl'):
    """
    查找指定目录下所有以 direction+.csv 结尾的文件，并返回其路径列表。
    """
    csv_list = []
    for filename in os.listdir(directory):
        if filename.endswith(f'{direction}.csv'):
            csv_list.append(os.path.join(directory, filename))
    return csv_list


def check_rules(csv_dir, input_mcs1, input_mcs2, input_mcs3, direction='dl'):
    # Find all CSV files in decoded_log folder
    csv_files = find_all_csv_file(csv_dir, direction=direction)
    if not csv_files:
        print(f"No downlink CSV files found in '{csv_dir}'.")
        return False
    else:
        print(f"Found {len(csv_files)} downlink CSV files in '{csv_dir}'.")
    # Check all CSV files in decoded_log folder
    any_violated = False
    for csv_file in csv_files:
        print(f"Using CSV file: {csv_file}")
        with open(csv_file, newline='') as csvfile:
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
                    mcs = parse_int(row.get('dlFdSchedData.rrmDlScaledMcs', '0'))
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
