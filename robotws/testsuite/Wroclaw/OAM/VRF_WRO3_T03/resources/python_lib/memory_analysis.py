import json
import os
import re
import shutil
import time
import zipfile
from pathlib import Path
from datetime import datetime
from robot.api import logger


"""
Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    MN_RAN_RD_VRF_WRO3_1
...  *****************
...  Basic information
...  *****************
...  This resource contains functions used to run the CCS SysInfoParser mechanism
...  for performing memory leak analysis.
...  ******************
...  History of changes
...  ******************
...  19.12.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-11469 - resource creation
...  10.02.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-14901 - adding start/end timestamp for filtering
...  the analysis and memory_leak_threshold (in % for detecting memory leaks)
...  23.04.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-20034 - adaptation of memory_leak_analyzer
...  due to tlda changes
"""


ccs_repository_url = "gerrit-mn-essl1.int.net.nokia.com:29418/MN/RPSW/CCS/ccs"
uphwapi_repository_url = "gerrit-mn-essl1.int.net.nokia.com:29418/MN/RPSW/UPHWAPI/tlda"
SMOD_runtime_regex = r".*[1|2]011_runtime_sysinfo\.zip"
SMOD_pm_regex = r".*[1|2]011_pm_\d+_sysinfo\.zip"
SMOD_BBMOD_runtime_regex = r".*_([12]011|[12][234]0[B-D]|[12][234][345689]D)_runtime_sysinfo\.zip"
SMOD_BBMOD_pm_regex = r".*_([12]011|[12][234]0[B-D]|[12][234][345689]D)_pm_\d+_sysinfo\.zip"
CCS_repo_path = "/home/ute/CCS_repository"
# SysInfoParser_reports_path = "/home/ute/SysInfoParser_reports"
header_json = "CCS_SysInfoParser.header.json"


def search_nested_archives(source_zip_path, destination_folder=None,
                           regex_type='SMOD_BBMOD', file_type='runtime') -> list:
    """
    Searches for nested ZIP archives within a source ZIP file that match a specified regex pattern and extracts them.

    Args:
        source_zip_path (str): The path to the source ZIP file to be searched.
        destination_folder (str, optional): The folder where extracted files will be saved.
        If None, a timestamped folder will be created in the same directory as the source ZIP file.
        regex_type (str): The type of regex pattern to use for matching files. Must be one of 'SMOD' or 'SMOD_BBMOD'.
        file_type (str): The type of files to search for. Must be one of 'runtime' or 'pm'.

    Returns:
        list: A list of paths to the extracted files that match the regex pattern.

    Raises:
        ValueError: If the provided source_zip_path is not a valid ZIP file or if an
        invalid combination of regex_type and file_type is provided.
    """
    if not zipfile.is_zipfile(source_zip_path):
        raise ValueError(f"The provided path '{source_zip_path}' is not a valid snapshot path.")
    if destination_folder is None:
        timestamp = time.strftime("%Y%m%d-%H%M%S")
        destination_folder = os.path.join(os.path.dirname(source_zip_path), f"{file_type}_files", f"{timestamp}")
    os.makedirs(destination_folder, exist_ok=True)
    if regex_type == 'SMOD' and file_type == 'runtime':
        zip_pattern = re.compile(SMOD_runtime_regex)
    elif regex_type == 'SMOD' and file_type == 'pm':
        zip_pattern = re.compile(SMOD_pm_regex)
    elif regex_type == 'SMOD_BBMOD' and file_type == 'runtime':
        zip_pattern = re.compile(SMOD_BBMOD_runtime_regex)
    elif regex_type == 'SMOD_BBMOD' and file_type == 'pm':
        zip_pattern = re.compile(SMOD_BBMOD_pm_regex)
    else:
        raise ValueError("Invalid combination of regex_type and file_type. "
                         "Choose 'SMOD' or 'SMOD_BBMOD' for regex_type and 'runtime' or 'pm' for file_type.")
    extracted_files = []

    def extract_matching_archives(current_zip_path, current_level):
        try:
            with zipfile.ZipFile(current_zip_path, 'r') as zip_ref:
                for item in zip_ref.namelist():
                    if zip_pattern.match(item) and item.endswith('.zip'):
                        extracted_path = os.path.join(destination_folder, os.path.basename(item))
                        with zip_ref.open(item) as source, open(extracted_path, 'wb') as target:
                            shutil.copyfileobj(source, target)
                            extracted_files.append(extracted_path)
                    elif item.endswith('.zip'):
                        temp_folder = os.path.join(destination_folder, f"temp_{current_level}")
                        os.makedirs(temp_folder, exist_ok=True)
                        temp_zip_path = os.path.join(temp_folder, os.path.basename(item))
                        with zip_ref.open(item) as source, open(temp_zip_path, 'wb') as target:
                            shutil.copyfileobj(source, target)
                        extract_matching_archives(temp_zip_path, current_level + 1)
        except zipfile.BadZipFile:
            logger.info(f"Bad ZIP file encountered: {current_zip_path}", also_console=True)
    extract_matching_archives(source_zip_path, 0)
    if not extracted_files:
        raise FileNotFoundError("No files matching the regex pattern were found in the archive.")
    for folder in os.listdir(destination_folder):
        if folder.startswith("temp_"):
            shutil.rmtree(os.path.join(destination_folder, folder))
    return extracted_files


def clone_repository(repository_target_path: str) -> None:
    """
    Clones the CCS and UPHWAPI repositories into the specified target path if they do not already exist.
    Additionally, copies the `tlda_common` directory from the UPHWAPI repository to the CCS repository.

    Args:
        repository_target_path (str): The target directory where the repositories will be cloned.

    Returns:
        str: The path to the `CCS_SysInfoParser.py` script within the cloned CCS repository.

    Raises:
        OSError: If there is an error during the cloning or copying process.
    """
    if not os.path.isdir(repository_target_path) or not os.listdir(repository_target_path):
        os.system(f'git clone --depth 1 "ssh://{ccs_repository_url}" "{repository_target_path}/ccs"')
        os.system(f'git clone --depth 1 "ssh://{uphwapi_repository_url}" "{repository_target_path}/uphwapi"')
        shutil.copytree(
            f'{repository_target_path}/uphwapi/T_Tools/SC_UPHWAPI/Technical_Log_Decoder_Analyzer/common/tlda_common',
            f'{repository_target_path}/ccs/T_Tools/SC_CCS/Technical_Log_Decoder_Analyzer/common/tlda_common')
    sysinfo_parser_path = f'{repository_target_path}/' \
                          f'ccs/T_Tools/SC_CCS/Technical_Log_Decoder_Analyzer/common/CCS_SysInfoParser.py'
    return sysinfo_parser_path


def analyze_files(path_to_sysinfo: str, path_to_logs: str, SysInfoParser_py_path: str,
                  startpoint: str = None, endpoint: str = None) -> None:
    """
    Analyzes sysinfo files using the SysInfoParser script and outputs the results to a specified logs directory.

    This function takes a path to a sysinfo file, a path to a logs directory, and a path to the SysInfoParser script.
    It extracts the node name from the sysinfo file path, creates a corresponding directory in the logs path, and
    runs the SysInfoParser script to analyze the sysinfo file. The results are stored in the logs directory.

    Args:
        path_to_sysinfo (str): The file path to the sysinfo file (runtime or pm) that needs to be analyzed.
        path_to_logs (str): The directory path where the analysis results will be stored.
        SysInfoParser_py_path (str): The file path to the SysInfoParser Python script.
        startpoint (str, optional): The start timestamp for filtering the analysis.
        endpoint (str, optional): The end timestamp for filtering the analysis.

    Returns:
        None

    Raises:
        AttributeError: If the node name cannot be extracted from the sysinfo file path.
        OSError: If there is an error creating the logs directory or running the SysInfoParser script.
    """
    match = re.search(r'_(\w{4})_(pm|runtime)', path_to_sysinfo)
    node_name = match.group(1)
    path_to_logs = Path(path_to_logs) / node_name

    filter_arg = ""
    if startpoint and endpoint:
        filter_arg = f'filter SYSINFOPARSER_FILTER={startpoint},{endpoint}'
    elif startpoint:
        filter_arg = f'filter SYSINFOPARSER_FILTER={startpoint},'
    elif endpoint:
        filter_arg = f'filter SYSINFOPARSER_FILTER=,{endpoint}'

    logger.info(f"Starting memory analysis with SysInfoParser for node {node_name}...", also_console=True)
    os.system(
        f'SYSINFOPARSER_CONF=verbose,{filter_arg} python3 "{SysInfoParser_py_path}" --analyze "{path_to_sysinfo}" '
        f'--output "{path_to_logs}" > /dev/null 2>&1')


def extract_json_data(file_path: str, memory_leak_threshold: float) -> bool:
    """
    Extracts and prints specific information from a JSON file.

    This function reads a JSON file, searches for flags of type 'process memory',
    and prints relevant details. Additionally, it searches for and prints the path
    to any HTML report files in the same directory as the JSON file.

    Args:
        file_path (str): The path to the JSON file to be processed.
        memory_leak_threshold (float): The threshold value in percentage for detecting memory leaks.

    Returns:
        bool: True if memory leak or memory quota is detected, otherwise False.

    Raises:
        FileNotFoundError: If the specified file does not exist.
        json.JSONDecodeError: If the file is not a valid JSON.
    """
    with open(file_path, 'r') as file:
        data = json.load(file)

    memory_issue_detected = False

    if any(value['Type'] == 'process memory' for flag in data['Flags'] for key, value in flag.items()):
        logger.info("Input file: " + os.path.basename(data['Input Files'][0]), also_console=True)
        folder_path = os.path.dirname(file_path)
        for root, _, files in os.walk(folder_path):
            for file in files:
                if file.endswith('.html'):
                    html_file_path = os.path.join(root, file)
                    logger.info(f"Report: {html_file_path}", also_console=True)
                    break

        memory_quota_data = []
        memory_leak_data = []

        for flag in data['Flags']:
            for key, value in flag.items():
                if value['Type'] == 'process memory':
                    if value['Subtype'] == 'Memory quota exceeded':
                        memory_issue_detected = True
                        details = value['Details'][0].split()
                        pid = details[1].split('_')[0]
                        process_name = details[1].split('_', 1)[1].split('_/')[0]
                        cgroup = details[1].split('/', 1)[1].rsplit('_', 1)[0]
                        pss = details[6]
                        quota = details[8] if len(details) > 8 else "N/A"
                        memory_quota_data.append([pid, process_name, cgroup, pss, quota])
                    elif value['Subtype'] == 'Possible memory leak':
                        for detail in value['Details'][1:]:
                            parts = detail.split()
                            pid = parts[0].split('_')[0]
                            process_name = parts[0].split('_', 1)[1].split('_/')[0]
                            cgroup = parts[0].split('/', 1)[1].rsplit('_', 1)[0]
                            abs_increase = parts[4]
                            rel_increase = float(parts[8].strip('%'))
                            if rel_increase >= memory_leak_threshold:
                                memory_issue_detected = True
                            memory_leak_data.append([pid, process_name, cgroup, abs_increase, rel_increase])

        if memory_quota_data:
            duration = calculate_duration(data['Flags'], 'Memory quota exceeded')
            logger.info(f"\nMemory Quota Analysis after {duration}", also_console=True)
            for flag in data['Flags']:
                for key, value in flag.items():
                    if value['Subtype'] == 'Memory quota exceeded':
                        logger.info(f"Issue start time: {value['Issue start time']}", also_console=True)
                        logger.info(f"Issue end time: {value['Issue end time']}", also_console=True)
            print_table(memory_quota_data, ['PID', 'Process name', 'Cgroup', 'PSS [kB]', 'Quota [kB]'])

        if memory_leak_data:
            duration = calculate_duration(data['Flags'], 'Possible memory leak')
            logger.info(f"\nMemory Leak Analysis after {duration}", also_console=True)
            for flag in data['Flags']:
                for key, value in flag.items():
                    if value['Subtype'] == 'Possible memory leak':
                        logger.info(f"Issue start time: {value['Issue start time']}", also_console=True)
                        logger.info(f"Issue end time: {value['Issue end time']}", also_console=True)
            print_table(memory_leak_data, ['PID', 'Process name', 'Cgroup', 'Abs. increase [kB]', 'Rel. increase [%]'])
            logger.info("\n\n", also_console=True)

    return memory_issue_detected


def calculate_duration(flags, subtype):
    for flag in flags:
        for key, value in flag.items():
            if value['Subtype'] == subtype:
                start_time = datetime.fromisoformat(value['Issue start time'].replace('Z', '+00:00'))
                end_time = datetime.fromisoformat(value['Issue end time'].replace('Z', '+00:00'))
                duration = end_time - start_time
                hours, remainder = divmod(duration.total_seconds(), 3600)
                minutes = remainder // 60
                return f"{int(hours)} hours and {int(minutes)} minutes"
    return "N/A"


def print_table(data, headers):
    """
    Prints data in a table format with adjustable column widths.

    Args:
        data (list): The data to be printed, where each item is a list of row values.
        headers (list): The headers for the table columns.

    Returns:
        None
    """
    col_widths = [max(len(str(item)) for item in col) for col in zip(*data, headers)]
    format_str = ' | '.join(f'{{:<{width}}}' for width in col_widths)
    separator = '-+-'.join('-' * width for width in col_widths)

    logger.info(format_str.format(*headers), also_console=True)
    logger.info(separator, also_console=True)
    for row in data:
        logger.info(format_str.format(*row), also_console=True)


def memory_leak_analyzer(snapshot_path: str, regex_type: str, file_type: str, sysinfo_storage_path: str,
                         sysinfo_reports_path: str, memory_leak_threshold: float,
                         startpoint: str = None, endpoint: str = None) -> str:
    """
    Analyzes memory leaks by extracting and processing nested archives from a source ZIP file.

    This function performs the following steps:
    1. Clones the necessary repositories if they do not already exist.
    2. Searches for and extracts nested archives from the provided source ZIP file based on the specified regex
       type and file type.
    3. Analyzes the extracted runtime files using the SysInfoParser script.
    4. Extracts and prints specific information from JSON files found in the analysis results.

    Args:
        snapshot_path (str): The snapshot file path.
        regex_type (str): The type of regex pattern to use for matching files within the ZIP archive.
                          Valid options are 'SMOD' or 'SMOD_BBMOD'.
        file_type (str): The type of files to search for within the ZIP archive.
                         Valid options are 'runtime' or 'pm'.
        sysinfo_storage_path (str): The directory path where the extracted files will be stored.
        sysinfo_reports_path (str): The directory path where the analysis results will be stored.
        memory_leak_threshold (float): The threshold value in percentage for detecting memory leaks.
        startpoint (str, optional): The start timestamp for filtering the analysis.
        endpoint (str, optional): The end timestamp for filtering the analysis.

    Raises:
        ValueError: If sysinfo_storage_path or sysinfo_reports_path is not provided.

    Returns:
        str: 'fail' if memory leak or memory quota is detected, otherwise 'pass'.
    """
    if not sysinfo_storage_path or not sysinfo_reports_path:
        raise ValueError("Both sysinfo_storage_path and sysinfo_reports_path must be provided.")

    SysInfoParser_py_path = clone_repository(CCS_repo_path)
    memory_leak_threshold = float(memory_leak_threshold)
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    sysinfo_storage_path = Path(sysinfo_storage_path) / timestamp
    os.makedirs(sysinfo_storage_path, exist_ok=True)
    archive_paths = search_nested_archives(snapshot_path, sysinfo_storage_path, regex_type, file_type)
    reports_path = Path(sysinfo_reports_path) / timestamp
    os.makedirs(reports_path, exist_ok=True)
    memory_issue_detected = False
    for archive_path in archive_paths:
        analyze_files(archive_path, reports_path, SysInfoParser_py_path, startpoint, endpoint)
    for root, dirs, files in os.walk(reports_path):
        for dir in sorted(dirs):
            subfolder_path = os.path.join(root, dir)
            for sub_root, _, sub_files in os.walk(subfolder_path):
                for file in sub_files:
                    if file == header_json:
                        header_file_path = os.path.join(sub_root, file)
                        if os.path.isfile(header_file_path):
                            if extract_json_data(header_file_path, memory_leak_threshold):
                                memory_issue_detected = True
    return 'fail' if memory_issue_detected else 'pass'
