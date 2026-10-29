import re
from datetime import datetime, timezone
from io import TextIOWrapper

import helper_functions

"""
This module provides a function to efficiently stream and search a syslog file
(e.g., messages.log) located deep within an archive structure (like a .zip or .tar.gz).
It uses regular expressions to find and return all matching log entries, making it
ideal for targeted log analysis without extracting the entire archive.
"""


def parse_syslog_from_archive(syslog_path_in_archive, regex_pattern):
    """
    This function directly streams and processes the target file without
    relying on other high-level search functions. It is optimized for
    parsing a single, known file path within an archive structure.

    Example path: /path/to/snapshot.zip/syslogs.tar.gz/messages.log

    :param syslog_path_in_archive: The full, slash-separated path to the target
                                   syslog file, including the archive path.
    :param regex_pattern: The regex pattern to search for within the syslog file.
    :return: A list of matching lines. Returns an empty list if no matches are
             found or if the file cannot be accessed.
    """
    print(f"Starting syslog parse for pattern '{regex_pattern}' in '{syslog_path_in_archive}'")
    matching_lines = []

    try:
        compiled_pattern = re.compile(regex_pattern)
    except re.error as e:
        print(f"Error: Invalid regex pattern provided: '{regex_pattern}'. Details: {e}")
        return []

    try:
        # Use the stream_file_in_nested_archive helper to get a stream
        # to the target file, handling all nesting and decompression.
        with helper_functions.stream_file_in_nested_archive(syslog_path_in_archive, decompress=True) as file_stream:
            if file_stream is None:
                print(f"Could not get a stream for '{syslog_path_in_archive}'. Aborting search.")
                return []
            # Wrap the byte stream for text-based, line-by-line reading.
            with TextIOWrapper(file_stream, encoding='utf-8', errors='ignore') as text_file:
                for line in text_file:
                    if compiled_pattern.search(line):
                        matching_lines.append(line)
    except Exception as e:
        print(f"An unexpected error occurred while parsing '{syslog_path_in_archive}': {e}")
        return []

    if matching_lines:
        print(f"Success: Found {len(matching_lines)} matching lines in '{syslog_path_in_archive}'.")
    else:
        print(f"Info: No lines matching pattern '{regex_pattern}' were found in '{syslog_path_in_archive}'.")

    return matching_lines


def find_first_timestamp_after_given_time(raw_lines, reference_timestamp):
    """
    Return the first parsed timestamp that occurs strictly after the provided
    reference timestamp (format: YYYY-MM-DD HH:MM:SS). If no matches are found,
    return None.
    """
    fmt_in = "%d.%m %H:%M:%S.%f"
    fmt_out = "%Y-%m-%d %H:%M:%S"
    pattern = re.compile(r"\b\d{2}\.\d{2} \d{2}:\d{2}:\d{2}\.\d{6}\b")
    reference_dt = datetime.strptime(reference_timestamp, fmt_out)

    for line in raw_lines:
        match = pattern.search(line)
        if not match:
            continue
        stamp = datetime.strptime(match.group(), fmt_in).replace(year=reference_dt.year)
        if stamp > reference_dt:
            return stamp.strftime(fmt_out)

    return None
