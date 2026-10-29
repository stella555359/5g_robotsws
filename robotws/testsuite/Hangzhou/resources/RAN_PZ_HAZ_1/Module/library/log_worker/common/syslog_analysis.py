# -*- coding: utf-8 -*-
"""
Author: Xiang, Liangliang
Contacts: liang.xiang@nokia-sbell.com
Description: this script is used to analyze syslog logs
"""
import os.path

from log_metadata import *
from common_utils import find_files_with_postfix, \
    get_custom_elements_using_regular_expression, extract_files_from_tgz_file


def filter_syslog_logs(log_path, analysis_dict):
    """
    *Usage:*
        - Keyword
        - This keyword is used to filter content from syslog logs based on specific conditions.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    syslog_path = ""
    output = []
    if os.path.isfile(log_path):
        syslog_path = log_path
    else:
        paths = find_files_with_postfix(log_path, ".tgz")
        syslog_path = paths[0]
    log_directory = get_log_directory(syslog_path)

    filter_conditions = analysis_dict["filter_conditions"]
    line_regex = filter_conditions["line_regex"] if "line_regex" in filter_conditions else None
    element_regex = filter_conditions["element_regex"] if "element_regex" in filter_conditions else None
    extracted_file_paths = extract_files_from_tgz_file(syslog_path, log_directory, postfix=".LOG", substring="SYSLOG")
    for path in extracted_file_paths:
        matches = get_custom_elements_using_regular_expression(path, line_regex, element_regex)
        for match in matches:
            output.extend(match)

    return output
