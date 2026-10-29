"""
Author: Aberrahmane NEZROUK
Date: 2025-08-13
Description: Library for extracting structured data from syslog files for Debian Linux, designed for Robot
Framework integration.
"""
import re
from typing import List, Dict
import subprocess
from robot.api import logger
from collections import Counter, defaultdict
from pprint import pprint


def get_key_distributions(dict_list, keys_list):
    result = {}
    for key in keys_list:
        values = [d.get(key) for d in dict_list]
        result[key] = dict(Counter(values))
    return result


def get_key_percent_distributions(dict_list, keys_list):
    result = {}
    for key in keys_list:
        values = [d.get(key) for d in dict_list if d.get(key) is not None]
        total = len(values)
        if total == 0:
            result[key] = {}
        else:
            counts = {}
            for v in set(values):
                counts[v] = round(100 * values.count(v) / total, 2)
            result[key] = counts
    return result


def tgs_syslog_filter(tgz_file_path, grep_prog='zgrep', option='-a', grep_patterns=[]):
    if not isinstance(grep_patterns, list):
        grep_patterns = [grep_patterns]
    if not tgz_file_path:
        return []
    if not grep_patterns:
        return []

    ts = []
    cmd = grep_prog + ' ' + option + ' "' + grep_patterns[0] + '" ' + tgz_file_path
    # cmd = compressed_grep + ' -a "' + pattern + '" ' + tgz_syslog_path
    for grep_patterns in grep_patterns[1:]:
        cmd += ' | grep "' + grep_patterns + '"'
    logger.debug('cmd: %s' % cmd)
    try:
        output = subprocess.check_output(
            cmd,
            shell=True,
        )
        if isinstance(output, (bytes, bytearray)):
            output = output.decode("utf-8")
            # logger.debug('output: %s' % output)
        for line in output.splitlines():
            ts.append(line)
    except Exception as e:
        # catch all exceptions
        pass
    return ts


def filter_by(key: str,  csv_dict: List[Dict[str, str]], key_value=0) -> List[Dict[str, str]]:
    """
    Returns a list of dicts where 'key' matches key_value.
    """
    return [entry for entry in csv_dict if entry.get(key) == str(key_value)]


def group_by_keys(key, csv_dict: List[Dict[str, str]]) -> List[List[Dict[str, str]]]:
    """
    Groups elements in data_list by identical values for the specified keys.
    Returns a list of lists, each inner list contains dicts with the same key values.
    """

    grouped = defaultdict(list)
    for elem in csv_dict:
        group_key = str(elem.get(key))
        grouped[group_key].append(elem)
    # Sort the groups by key value (ascending)
    sorted_keys = sorted(grouped.keys(), key=lambda x: (int(x) if x.isdigit() else x))
    return [grouped[k] for k in sorted_keys]


def filter_pattern(syslog_path: str, pattern_list: List[str]) -> List[str]:
    """
    Filters lines in the syslog file that contain all words in pattern_list.
    Returns a list of matched lines.
    """
    try:
        with open(syslog_path, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
    except Exception as e:
        raise IOError(f"Error reading syslog file: {e}")

    filtered = []
    for line in lines:
        if all(word in line for word in pattern_list):
            filtered.append(line.strip())
    return filtered


def extract_csv_data(filtred_lines: List[str], csv_columns: List[str]) -> List[Dict[str, str]]:
    """
    Extracts values for each key in csv_columns from the filtered lines.
    Returns a list of dictionaries mapping keys to extracted values.
    """
    results = []
    key_regex = {}
    muting_clmns = ["muting symbol2 slots", "muting symbol4 slots"]
    # Regex to match key:value pairs, e.g. "l2SubpoolId":1 or "l2SubpoolId":"1"
    for col in csv_columns:
        if col in muting_clmns:
            key_regex[col] = re.compile(rf'{col}:\s*(.*)')  # e.g. muting symbol2 slots: 1,2,3
        else:
            key_regex[col] = re.compile(rf'"?{col}"?\s*[:=\s]\s*([A-Za-z0-9_]+|"[^"]*")')
    for line in filtred_lines:
        entry = {}
        for col, regex in key_regex.items():
            match = regex.search(line)
            if match:
                val = match.group(1)
                if val.startswith('"') and val.endswith('"'):
                    val = val[1:-1]
                entry[col] = val
            else:
                entry[col] = None  # Key not found in line
        results.append(entry)
    return results


def syslog_data_extraction(syslog_path: str, pattern_list: List[str], csv_columns: List[str]) -> List[Dict[str, str]]:
    """
    Main function to extract structured data from syslog file.
    1. Filters lines containing all patterns.
    2. Extracts values for csv_columns from filtered lines.
    Returns a list of dictionaries.
    """
    try:
        filtered_lines = filter_pattern(syslog_path, pattern_list)
        if not filtered_lines:
            return []
        csv_data = extract_csv_data(filtered_lines, csv_columns)
        return csv_data
    except Exception as e:
        # Log error or handle as needed for Robot Framework
        raise RuntimeError(f"syslog_data_extraction failed: {e}")
