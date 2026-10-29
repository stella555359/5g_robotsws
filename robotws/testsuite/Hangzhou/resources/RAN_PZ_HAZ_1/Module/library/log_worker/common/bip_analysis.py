# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Contacts: renhui-david.liu@nokia-sbell.com
Description: this script is used to analyze BIP logs
"""
import re
import os.path
import glob

from log_metadata import *
from common_utils import run_local_command, get_current_date_time, extract_files_from_zip_file
from process_csv_file import filter_csv_rows_using_and_conditions, filter_csv_rows_using_or_conditions, \
    check_statistics_using_and_conditions, check_statistics_using_or_conditions

MCSHARK_TOOL_LINK = "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark"
MCSHARK_PATH_PREFIX = "/home/ute/artifactory/wslte5g_plugins-local/MCShark"
DEFAULT_ROW_COUNT = 10


def filter_bip_logs(log_path, analysis_dict):
    """
    *Usage:*
        - Keyword
        - This keyword is used to filter content from BIP logs to a CSV file based on specific conditions.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    csv_file_path = convert_bip_to_csv_using_mcshark(log_path, analysis_dict)
    return csv_file_path


def check_bip_logs(log_path, analysis_dict):
    """
    *Usage:*
        - Keyword
        - First, filter the content from BIP logs based on specific conditions and save it to a CSV file.
        - Secondly, verify the CSV file against the conditions specified in the analysis_dict.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    csv_file_path = convert_bip_to_csv_using_mcshark(log_path, analysis_dict)

    if "check_rules" not in analysis_dict or not analysis_dict["check_rules"]:
        raise Exception('check_rules not existing or empty')

    check_rules = analysis_dict["check_rules"]
    if "basic_rules" not in check_rules or not check_rules["basic_rules"]:
        raise Exception('basic_rules not existing or empty')
    basic_rules = check_rules["basic_rules"]
    logic_operation = basic_rules.pop(0)
    if logic_operation not in ["and", "or"]:
        raise Exception('The operator in basic_rules is not and/or')
    matching_rows = []
    row_nums = []
    if logic_operation == "and":
        matching_rows, row_nums = filter_csv_rows_using_and_conditions(csv_file_path, basic_rules)
    if logic_operation == "or":
        matching_rows, row_nums = filter_csv_rows_using_or_conditions(csv_file_path, basic_rules)
    if not matching_rows:
        return False, None
    row_count = DEFAULT_ROW_COUNT
    if "row_count" in analysis_dict:
        row_count = analysis_dict["row_count"]
    if "statistics_rules" not in check_rules or not check_rules["statistics_rules"]:
        if len(matching_rows) < row_count:
            return [matching_rows, row_nums]
        else:
            return True, matching_rows[:row_count], row_nums[:row_count + 1]

    statistics_rules = check_rules["statistics_rules"]
    logic_operation_2 = statistics_rules.pop(0)
    result = False
    if logic_operation_2 == "and":
        result = check_statistics_using_and_conditions(matching_rows, statistics_rules)
    if logic_operation_2 == "or":
        result = check_statistics_using_or_conditions(matching_rows, statistics_rules)

    if len(matching_rows) < row_count:
        return result, [matching_rows, row_nums]
    else:
        return result, matching_rows[:row_count], row_nums[:row_count + 1]


def prepare_mcshark_plugins(log_path):
    """
    *Usage:*
        - Used to prepare the McShark plugins locally, ensuring they match the BTS (Base Transceiver Station) version.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    bts_version_in_url = get_bts_version_in_url(log_path)

    download_plugin_cmd = f"cd /home/ute/; wget -r -np -nH {MCSHARK_TOOL_LINK}/{bts_version_in_url}/ -P /home/ute/"
    run_local_command(download_plugin_cmd)

    output = run_local_command("tshark -v |grep TShark")
    matched = re.findall(r"v(\d{1,3}\.\d{1,3})\.\d{1,3}", output)
    tshark_version = matched[0] if matched else None
    ute_plugin_path = f"/home/ute/.local/lib/wireshark/plugins/{tshark_version}/epan/mcshark-*.so"
    if glob.glob(ute_plugin_path):
        return
    path = f"/usr/lib/x86_64-linux-gnu/wireshark/plugins/{tshark_version}/epan"
    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)
    mcshark_files = f"{path}/mcshark-*buster.so"
    run_local_command(f"sudo rm -rf {mcshark_files}")
    mcshark_path = os.path.join(MCSHARK_PATH_PREFIX, f"{bts_version_in_url}/mcshark-*buster.so")
    run_local_command(f"sudo cp {mcshark_path} {path}")


def convert_bip_to_csv_using_mcshark(log_path, analysis_dict):
    """
    *Usage:*
        - Used to filter the content from BIP logs based on specific conditions and save it to a CSV file.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    prepare_mcshark_plugins(log_path)

    log_directory = get_log_directory(log_path)
    if log_path.endswith('.zip'):
        log_paths = extract_files_from_zip_file(log_path, log_directory, postfix='.pcap')
        log_path = log_paths[0]

    first_field = "-e _ws.col.No."
    text_output_format = "fields"
    csv_format = "-E header=y -E separator=, -E quote=d -E occurrence=a"
    cmd = f"tshark -r {log_path} -Y '{analysis_dict['filter_conditions']}'"

    field_names = analysis_dict['output_field_names']
    names = ["-e " + name for name in field_names]
    cmd_part = " ".join(names)

    date_time = get_current_date_time()
    csv_file_path = os.path.join(log_directory, f"bip_{date_time}.csv")
    cmd = f"{cmd} -T {text_output_format} {first_field} {cmd_part} {csv_format} > {csv_file_path}"

    print(f"The tshark command: {cmd}")
    run_local_command(cmd)
    return csv_file_path
