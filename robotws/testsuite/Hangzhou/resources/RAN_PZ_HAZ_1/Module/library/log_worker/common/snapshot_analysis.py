# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui  Xiang, Liangliang
Contacts: renhui-david.liu@nokia-sbell.com liang.xiang@nokia-sbell.com
Description: this script is used to analyze snapshot logs
"""
import re
import os.path

from log_metadata import *
from common_utils import extract_and_search_files, find_files_with_postfix


def check_snapshot_logs(log_path, analysis_dict):
    """
    *Usage:*
        - Keyword
        - This keyword is used to verify whether specific files are present in the snapshot.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    snapshot_path = ""
    if os.path.isfile(log_path):
        snapshot_path = log_path
    else:
        paths = find_files_with_postfix(log_path, ".zip")
        snapshot_path = paths[0]
    log_directory = get_log_directory(snapshot_path)
    filter_conditions = analysis_dict["filter_conditions"]
    filename = filter_conditions["filename"] if "filename" in filter_conditions else None
    postfix = filter_conditions["postfix"] if "postfix" in filter_conditions else None
    file_paths = extract_and_search_files(snapshot_path, log_directory, postfix=postfix, substring=filename)
    print(f"snapshot file paths: {file_paths}")
    return len(file_paths) > 0, file_paths


if __name__ == '__main__':
    log_path = "/home/ute/Downloads/Snapshot_MRBTS-10069_BTS10069_SBTS25R1_ENB_9999_241014_000022_20241015-1121.zip"
    analysis_dict1 = {
        "filter_conditions": {
            # "filename": 'PM',
            "postfix": 'ANY.xml.gz'
        }
    }
    analysis_dict2 = {
        "filter_conditions": {
            "filename": 'MRBTS',
            "postfix": '.imsc2'
        }
    }
    result1 = check_snapshot_logs(log_path, analysis_dict1)
    print(result1)
    result2 = check_snapshot_logs(log_path, analysis_dict2)
    print(result2)
