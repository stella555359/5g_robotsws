import datetime
import re

# [Documentation]
# Author: Damian Kotula
# Maintainer: Damian Kotula
# This script is used to search an input log file, identifying all lines that contain "VIP/" or "ERR/" in line
# and were printed within the specified time period.
# Lines fulfilling those conditions are saved to output file.


def extract_lines(log_file, output_file, start_time_str, end_time_str):
    start_time = datetime.datetime.strptime(start_time_str, '%Y-%m-%dT%H:%M:%S.%fZ')
    end_time = datetime.datetime.strptime(end_time_str, '%Y-%m-%dT%H:%M:%S.%fZ')

    timestamp_regex = r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}Z"

    qualifying_lines = []
    with open(log_file, 'r') as f:
        for line in f:
            timestamp_match = re.search(timestamp_regex, line)
            if timestamp_match:
                timestamp_str = line[timestamp_match.start():timestamp_match.end()]
                try:
                    timestamp = datetime.datetime.strptime(timestamp_str, '%Y-%m-%dT%H:%M:%S.%fZ')
                    if start_time <= timestamp <= end_time and ('VIP/' in line or 'ERR/' in line):
                        qualifying_lines.append(line)
                        # print(f"Qualifying line: {line}")  # Print qualifying lines
                except ValueError:
                    pass  # Ignore lines with invalid timestamps

    with open(output_file, 'w') as f:
        f.writelines(qualifying_lines)
