"""
SyslogParserLibrary
-------------------

A Robot Framework library for filtering and analyzing timestamped syslog files.

Usage:
    from SyslogParserLibrary import SyslogParserLibrary

    parser = SyslogParserLibrary()
    # Filter a log file for entries matching keywords, components, and time range
    output_file = parser.filter_log_file(
        file_path="syslog.log",
        component="oamconfig",
        keyword="K8sClusterSupervisor.cpp,populateGlobalStatePods",
        exclude="DEBUG",
        start_time_str="2024-06-01T00:00:00",
        end_time_str="2024-06-02T00:00:00",
        match_all_keywords=False,
        case_sensitive=False
    )

    # Get the timestamp of the first or last event in a log file
    first_ts = parser.get_timestamp_of_event(output_file, mode="first")
    last_ts = parser.get_timestamp_of_event(output_file, mode="last")

Notes:
    - Supports Unicode (UTF-8) log files.
    - Returns filtered log entries to a new file.
    - Raises FileNotFoundError if no entries match the filter.
"""

import re
from datetime import datetime, timezone


class SyslogParserLibrary:
    """Robot Framework library for filtering and analyzing timestamped log files."""

    def __init__(self):
        self.timestamp_regex = re.compile(r"<(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2}))>")

    def _parse_timestamp(self, ts_str):
        formats = [
            "%Y-%m-%dT%H:%M:%S.%fZ",
            "%Y-%m-%d %H:%M:%S.%fZ",
            "%Y-%m-%dT%H:%M:%S.%f",
            "%Y-%m-%d %H:%M:%S.%f",
            "%Y-%m-%dT%H:%M:%S",
            "%Y-%m-%d %H:%M:%S",
        ]
        for fmt in formats:
            try:
                dt = datetime.strptime(ts_str, fmt)
                return dt.replace(tzinfo=timezone.utc)
            except ValueError:
                continue
        raise ValueError(f"Unsupported timestamp format: {ts_str}")

    def _entry_matches(self, entry_lines, component, keywords, excludes, match_all, case_sensitive):
        joined_entry = "".join(entry_lines)
        if not case_sensitive:
            joined_entry = joined_entry.lower()
        if component and not any(component in line for line in entry_lines):
            return False
        if keywords:
            if match_all and not all(k in joined_entry for k in keywords):
                return False
            if not match_all and not any(k in joined_entry for k in keywords):
                return False
        if excludes and any(e in joined_entry for e in excludes):
            return False
        return True

    def _normalize_param(self, value):
        if isinstance(value, str):
            return [v.strip() for v in value.split(",") if v.strip()]
        elif isinstance(value, list):
            return value
        elif value is None:
            return []
        else:
            return [str(value)]

    def filter_log_file(self, file_path, component=None, keyword=None, exclude=None,
                        start_time_str=None, end_time_str=None, match_all_keywords=False, case_sensitive=True):
        """Filters a log file based on given criteria and returns output file path or a message."""
        keywords = self._normalize_param(keyword)
        excludes = self._normalize_param(exclude)

        if not case_sensitive:
            keywords = [k.lower() for k in keywords]
            excludes = [e.lower() for e in excludes]

        start_time = self._parse_timestamp(start_time_str) if start_time_str else None
        end_time = self._parse_timestamp(end_time_str) if end_time_str else None

        output_lines = []
        with open(file_path, "r", encoding="utf-8", errors="replace") as file:
            entry_lines = []
            entry_timestamp = None
            is_valid_entry = True

            for line in file:
                match = self.timestamp_regex.search(line)
                if match:
                    if entry_lines and is_valid_entry and entry_timestamp:
                        if self._entry_matches(entry_lines, component, keywords, excludes, match_all_keywords,
                                               case_sensitive):
                            if (not start_time or entry_timestamp >= start_time) and \
                                    (not end_time or entry_timestamp <= end_time):
                                output_lines.extend(entry_lines)
                    entry_lines = [line]
                    is_valid_entry = True
                    try:
                        entry_timestamp = datetime.fromisoformat(match.group(1).replace("Z", "+00:00"))
                    except ValueError:
                        is_valid_entry = False
                        entry_timestamp = None
                else:
                    entry_lines.append(line)

            if entry_lines and is_valid_entry and entry_timestamp:
                if self._entry_matches(entry_lines, component, keywords, excludes, match_all_keywords, case_sensitive):
                    if (not start_time or entry_timestamp >= start_time) and \
                            (not end_time or entry_timestamp <= end_time):
                        output_lines.extend(entry_lines)

        if not output_lines:
            raise FileNotFoundError("No entries matched the given parameters.")

        start_label = start_time.strftime("%Y-%m-%d_%H-%M-%S") if start_time else "start"
        end_label = end_time.strftime("%Y-%m-%d_%H-%M-%S") if end_time else "end"
        output_filename = f"syslog_parsed_{start_label}_{end_label}.log"

        with open(output_filename, "w", encoding="utf-8") as out_file:
            out_file.writelines(output_lines)

        return output_filename

    def get_timestamp_of_event(self, file_path, mode="first"):
        """Returns first or last timestamp from a filtered log file."""
        timestamps = []
        with open(file_path, "r", encoding="utf-8", errors="replace") as file:
            for line in file:
                match = self.timestamp_regex.search(line)
                if match:
                    try:
                        ts = datetime.fromisoformat(match.group(1).replace("Z", "+00:00"))
                        timestamps.append(ts)
                    except ValueError:
                        continue
        if not timestamps:
            raise ValueError("No timestamps found in file.")
        selected_ts = timestamps[0] if mode == "first" else timestamps[-1]
        return selected_ts.strftime("%Y-%m-%d %H:%M:%S.%f")
