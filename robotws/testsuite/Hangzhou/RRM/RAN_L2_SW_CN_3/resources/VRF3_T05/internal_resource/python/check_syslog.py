# -*- coding: utf-8 -*-
# @Time    : 2025/6/11 16:36
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : check_syslog.py
# @Software: PyCharm
import re
from datetime import datetime


def get_switched_bwp_type_timestamp(syslog_file):
    """
    Check if the syslog file contains the expected switched BWP type.
    """
    pattern = r"postBwpSwitchCompletion.*switched to bwpType="
    pattern2 = r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}Z)'
    pattern3 = r"BWP_ADAPTATION:operator().*switched to bwpType="
    results = {}
    with open(syslog_file, 'r') as file:
        for line in file:
            if re.search(pattern, line) is not None:
                timestamp = re.search(pattern2, line)
                dt = timestamp.group(0)
                dt = datetime.strptime(dt, "%Y-%m-%dT%H:%M:%S.%fZ").timestamp()
                results[dt] = (line.split("switched to bwpType=")[-1].split(" ")[0])
            elif re.search(pattern3, line) is not None:
                timestamp = re.search(pattern2, line)
                dt = timestamp.group(0)
                dt = datetime.strptime(dt, "%Y-%m-%dT%H:%M:%S.%fZ").timestamp()
                results[dt] = (line.split("switched to bwpType=")[-1].split(" ")[0])
    print(results)
    return results


def get_cg_related_results(syslog_file):
    pattern = r"ULCGTYPE2.COMMON.*entering state:"
    entering_state = []
    with open(syslog_file, 'r') as file:
        for line in file:
            if re.search(pattern, line) is not None:
                entering_state.append(line.split("entering state:")[-1].split(",")[0])
    print(entering_state)
    return entering_state


def get_bwp_profile_id(syslog_file):
    pattern = r"ueSupportedBwpProfileId = 20070"
    count = 0
    with open(syslog_file, 'r') as file:
        for line in file:
            if re.search(pattern, line) is not None:
                count += 1
    return count


if __name__ == "__main__":
    get_switched_bwp_type_timestamp(syslog_file="1_192.168.255.129_20250612T073000_start_trace_syslog.log")
    # patterns = [
    #     r"L2HiProxy\.cpp.*QosId\s*=\s*84",
    #     r"ScenarioCommon\.cpp.*BearerSetupReq",
    #     r"BWP_ADAPTATION:postBwpSwitchCompletion.*switched to bwpType=DEDICATED"
    # ]
    # with open('1_192.168.255.129_20250612T073000_start_trace_syslog.log', 'r') as file:
    #     lines = file.readlines()
    #     for line in lines:
    #         for pattern in patterns:
    #             if check_line_with_pattern(line, pattern):
    #                 print(f"Match found: {line.strip()}")
