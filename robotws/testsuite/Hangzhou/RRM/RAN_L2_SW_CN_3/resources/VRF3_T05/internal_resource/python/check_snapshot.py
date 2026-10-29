# -*- coding: utf-8 -*-
# @Time    : 2025/6/3 11:03
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : check_snapshot.py
# @Software: PyCharm
import subprocess
import pkgutil
import os
from datetime import datetime
import importlib


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package, '-i',
                         'https://artifactory-hz1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple'])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def install_tlda_package():
    try:
        subprocess.call([
            'pip', 'install', '--upgrade', '--index-url',
            "https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/cb-pypi-virtual/simple",
            "tlda_scripts<2.0.0"
        ])
    except Exception as e:
        raise AssertionError(f"Error installing package: {e}")


def download_tlda_zip_and_unzip(snapshot_path, dlta_path="/home/ute/test_results/TLDA.zip"):
    try:
        subprocess.call([
            'tlda_test_runner', '--snapshot', snapshot_path, '--output', '/home/ute/test_results',
            '--only_tlda', '--python3'
        ])
    except Exception as e:
        raise AssertionError(f"Error downloading and unzipping tlda_test_runner: {e}")

    dlta_folder_path = dlta_path.replace(".zip", "")
    try:
        subprocess.call(['unzip', '-o', dlta_path, '-d', dlta_folder_path])
    except Exception as e:
        raise AssertionError(f"Error unzipping tlda_test_runner: {e}")


def is_tlda_installed():
    return bool(pkgutil.find_loader('tlda_test_runner'))


def install_and_download_tlda(snapshot_path, dlta_path="/home/ute/test_results/TLDA.zip"):
    if not is_tlda_installed():
        install_tlda_package()
        download_tlda_zip_and_unzip(snapshot_path, dlta_path)


def tlda_analysis_snapshot(snapshot_path, dlta_snapshot_path, tlda_py_path="/home/ute/test_results/TLDA/tlda.py"):
    try:
        subprocess.call(['python', tlda_py_path, '--techlog_path', snapshot_path, '--output', dlta_snapshot_path])
    except Exception as e:
        raise AssertionError(f"Error analyzing snapshot from tlda: {e}")


def filter_and_count_by_minutes(directory, isMdbvCompliant_col='isMdbvCompliant', minutes_col='minutes',
                                seconds_col='seconds', handle_min_58_59=True):
    try:
        aggregated_result = {}

        # Traverse all CSV files in the directory
        for root, _, files in os.walk(directory):
            for file in files:
                if file == "MdbvStats.csv":
                    file_path = os.path.join(root, file)

                    # Read the CSV file
                    pd = install_and_import_pandas()
                    df = pd.read_csv(file_path)

                    # Filter rows where isMdbvCompliant is 0
                    filtered_df = df[df[isMdbvCompliant_col] == 0]

                    # Adjust minutes based on seconds
                    if handle_min_58_59:
                        filtered_df[minutes_col] = filtered_df.apply(
                            lambda row: row[minutes_col] + 1 if row[seconds_col] in [58, 59] else row[minutes_col],
                            axis=1
                        )

                    # Count occurrences of isMdbvCompliant=0 for each unique minute
                    minute_counts = filtered_df[minutes_col].value_counts()

                    # Aggregate results
                    for minute, count in minute_counts.items():
                        if minute in aggregated_result:
                            aggregated_result[minute] += count
                        else:
                            aggregated_result[minute] = count

        return aggregated_result  # Return aggregated result as a dictionary
    except Exception as e:
        return f"Error processing files: {e}"


def convert_timestamps_to_minutes(data, data2={}):
    converted_data = {}
    for timestamp, count in data.items():
        # Convert timestamp to minute
        minute = datetime.fromtimestamp(int(timestamp)).minute
        converted_data[minute] = count
        for counter_name, counter_data in data2.items():
            converted_data[minute] -= data2[counter_name][timestamp]
    return converted_data


# Example input
data = {
        '1749092460': 0,
        '1749092520': 0,
        '1749092580': 0,
        '1749092640': 0,
        '1749092700': 0,
        '1749092760': 1,
        '1749092820': 10,
        '1749092880': 3,
        '1749092940': 22
}


def assert_common_parts_equal(dict_a, dict_b):
    # Find common keys
    common_keys = set(dict_a.keys()) & set(dict_b.keys())

    # Assert values for common keys are equal
    for key in common_keys:
        assert dict_b[key]-5 <= dict_a[key] <= dict_b[key]+5, \
            f"Value mismatch for target minute '{key}': {dict_a[key]}(from csv) != {dict_b[key]}(from counter)"


def assert_common_parts_equal_handle_5min(dict_a, dict_b):
    # Find common keys
    common_keys = set(dict_a.keys()) & set(dict_b.keys())

    # Assert values for common keys are equal
    for key in common_keys:
        b_key = key//5*5
        assert dict_b[b_key]-5 <= dict_a[key] <= dict_b[b_key]+5, \
            f"Value mismatch for target minute '{key}': {dict_a[key]}(from csv) != {dict_b[key]}(from counter)"


if __name__ == "__main__":
    # install_and_download_tlda("c103_snapshot.zip", "TLDA.zip")
    # tlda_analysis_snapshot("c103_snapshot.zip", "tlda_snapshot")
    # a = filter_and_count_by_minutes(directory="/home/ute/test_results")
    # print(a)
    # b = convert_timestamps_to_minutes(data)
    # print(b)
    # assert_common_parts_equal(a, b)
    print("hope success")
