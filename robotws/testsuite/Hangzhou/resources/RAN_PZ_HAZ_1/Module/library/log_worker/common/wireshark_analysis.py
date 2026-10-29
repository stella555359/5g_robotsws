# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Contacts: renhui-david.liu@nokia-sbell.com
Description: This script is designed to analyze Wireshark logs
"""

from common_utils import run_local_command
import subprocess


def filter_wireshark_logs(log_path, analysis_dict):
    """
    *Usage:*
        - Keyword
        - This keyword is used to filter content from Wireshark logs based on specific conditions.
    *Contact:*
        - liang.xiang@nokia-sbell.com
    """
    if log_path.endswith('.gz'):
        # Decompress the .gz file
        decompressed_path = log_path[:-3]  # Remove the .gz extension
        cmd = f"gunzip -c {log_path} > {decompressed_path}"
        subprocess.run(cmd, shell=True, check=True)
        log_path = decompressed_path

    if not log_path.endswith('.pcap'):
        raise ValueError("The decompressed file is not a .pcap file")

    text_output_format = "fields"
    cmd = f"tshark -r {log_path} -Y '{analysis_dict['filter_conditions']}'"

    if "output_field_names" in analysis_dict and analysis_dict["output_field_names"]:
        field_names = analysis_dict['output_field_names']
        names = ["-e " + name for name in field_names]
        cmd_part = " ".join(names)
        cmd = f"{cmd} -T {text_output_format} {cmd_part}"

    if "extra_conditions" in analysis_dict and analysis_dict["extra_conditions"]:
        cmd = f"{cmd} {analysis_dict['extra_conditions']}"

    print(f"The wireshark command: {cmd}")
    return run_local_command(cmd)


def check_wireshark_logs(log_path, analysis_dict):
    """
    *Usage:*
        - Keyword
        - First, filter the content from Wireshark logs based on specific conditions.
        - Secondly, verify that the filtered content is not empty.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    output = ""
    is_pass = False
    has_message_sequences = "message_sequences" in analysis_dict
    if not has_message_sequences:
        output = filter_wireshark_logs(log_path, analysis_dict)
        is_pass = len(output) != 0
    # else:
    # to handle message_sequences
    return is_pass, output
