"""
Snapshot Analyzer module for analyzing snapshot logs for One Way Delay Measurement.
It checks for session timeouts, t12Min and t34Min values, No Response from RU,
Periodic No Response from RU, No Response for.
It also checks for received late logs and clears errors if a later log line,
with the same session ID and meas ID is found.

Example:
    time_from_test_start = datetime.now()
    .
    .
    .
    Test Case
    .
    .
    .
    snapshot_analyzer = SnapshotAnalyzer(
        snapshot_file_path=snapshot_file_path,
        snapshot_tgz_files_to_check=['_syslog.tgz', '_L1_logs.tgz', '_crash.tgz'],
        time_from_test_start=time_from_test_start,
        snapshot_txt_file_list='snapshot_file_list.txt',
        tmin_minimum_value=1,
        tmin_maximum_value=1_000_000
    )
    snapshot_analyzer.analyze_l1_logs_in_snapshot()

    if any(result['found'] for result in snapshot_analyzer.results.values()):
        raise SnapshotAnalysisFailedError(
            f"Snapshot analysis failed: with file: {snapshot_file_path}"
        )

:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
:maintainer: mateusz.potoniec@nokia.com
"""

import gzip
import re
import tarfile
import zipfile

from datetime import datetime
from dataclasses import dataclass, field
from typing import List, Dict, Generator, Optional

from robot.api import logger
from robot.api.deco import keyword


@dataclass
class LogEntry:
    line: str
    line_with_errors: Optional[bool] = False
    error_cleared_by_receiving_later: Optional[bool] = False
    timestamp: Optional[datetime] = None
    session_id: Optional[str] = None
    meas_id: Optional[str] = None
    t12Min: Optional[int] = None
    t34Min: Optional[int] = None
    _error_phrases: Optional[List[str]] = field(default_factory=list)

    def __post_init__(self):
        self._set_timestamp()

    def is_specific_error(self, error_phrase: str) -> bool:
        """
        Check if the log line contains a specific error phrase.

        :param error_phrase: The error phrase to check for.
        :return: True if the error phrase is found, False otherwise.
        """
        return any(error_phrase in phrase for phrase in self._error_phrases)

    @property
    def error_phrases(self) -> Optional[List[str]]:
        return self._error_phrases

    @error_phrases.setter
    def error_phrases(self, value: str):
        self._error_phrases.append(value)
        self.line_with_errors = True

    def _set_timestamp(self) -> None:
        """
        Set the timestamp from the log line.
        It extracts the timestamp from the log line and converts it to a datetime object.
        If the timestamp cannot be parsed, it sets the timestamp to None.
        """

        try:
            timestamp_str = self.line.split('T')[0] + 'T' + self.line.split('T')[1][:8]
            self.timestamp = datetime.strptime(timestamp_str, '%Y-%m-%dT%H:%M:%S')
        except (ValueError, IndexError):
            self.timestamp = None

    def __str__(self):
        if self.line_with_errors:
            errors = f"Line session ID: {self.session_id} | meas ID: {self.meas_id} with errors: {self.error_phrases}"
            return f"{errors}\n{self.line}"
        else:
            return f"Line session ID: {self.session_id} | meas ID: {self.meas_id}\n{self.line}"


class SnapshotAnalyzer:
    def __init__(self, snapshot_file_path: str,
                 snapshot_tgz_files_to_check: List[str],
                 time_from_test_start: datetime,
                 snapshot_txt_file_list: str = 'snapshot_file_list.txt',
                 tmin_minimum_value: int = 1,
                 tmin_maximum_value: int = 1_000_000) -> None:
        """
        Initialize the SnapshotAnalyzer.

        :param snapshot_file_path: Path to the snapshot file.
        :param snapshot_tgz_files_to_check: List of .tgz files to check inside the snapshot.
        :param time_from_test_start: Time from the start of the test to filter log lines.
        :param snapshot_txt_file_list: Name of the file list inside the snapshot (default: 'snapshot_file_list.txt').
        :param tmin_minimum_value: Minimum value for t12Min/t34Min (default: 1).
        :param tmin_maximum_value: Maximum value for t12Min/t34Min (default: 1_000_000).
        """

        self._snapshot_file_path = snapshot_file_path
        self._snapshot_tgz_files_to_check = snapshot_tgz_files_to_check
        self._time_from_test_start = time_from_test_start
        self._snapshot_txt_file_list = snapshot_txt_file_list

        self._tmin_minimum_value = tmin_minimum_value
        self._tmin_maximum_value = tmin_maximum_value

        self._one_way_delay_pattern = re.compile(r'\bOneWayDelayMeasurement\b')
        self._session_id_pattern = re.compile(r'sessionId\s*(?:=\s*)?(\d+)', re.IGNORECASE)
        self._received_late_pattern = re.compile(r'\breceived late\b')
        self._meas_id_pattern = re.compile(r'measId\s*(?:=\s*)?(\d+)', re.IGNORECASE)

        self._lines_with_received_late = []

        self._one_way_delay_count = 0
        self._lines_checked = 0

        self._session_timeout_pattern = re.compile("Delay measurement result: session timeout")
        self._periodic_no_response_from_ru_pattern = re.compile("Periodic measurement failure, no response from RU,")
        self._no_response_from_ru_pattern = re.compile("No response from RU:")
        self._no_response_for_pattern = re.compile("Periodic delay measurement result: no responses for")
        self._t12min_pattern = re.compile(rf'\bt12Min\b\s+(\d+)')
        self._t34min_pattern = re.compile(rf'\bt34Min\b\s+(\d+)')

        self._lines_with_errors = []
        self._lines_with_no_response_errors = []
        self._lines_with_no_response_from_ru = []

        self._results = {
            self._session_timeout_pattern.pattern: {'found': False, 'count': 0},
            self._periodic_no_response_from_ru_pattern.pattern: {'found': False, 'count': 0},
            self._no_response_from_ru_pattern.pattern: {'found': False, 'count': 0},
            self._no_response_for_pattern.pattern: {'found': False, 'count': 0},
            "Incorrect t12Min": {'found': False, 'count': 0},
            "Incorrect t34Min": {'found': False, 'count': 0},
        }

    @property
    def results(self) -> Dict[str, Dict[str, bool]]:
        """
        Get the results of the analysis.

        :return: Dictionary with the results of the analysis.
        """
        logger.info(f"===============================================================================")
        logger.info(f"Number of lines checked: {self._lines_checked}")
        logger.info(f"Number of One Way Delay logs: {self._one_way_delay_count}")
        logger.info(f"Number of Recieved Late logs: {len(self._lines_with_received_late)}")
        logger.info(f"===============================================================================")
        for error, result in self._results.items():
            logger.info(f"Error: {error} Found: {result['found']}, Count: {result['count']}")
        logger.info(f"===============================================================================")
        return self._results

    @keyword()
    def analyze_l1_logs_in_snapshot(self) -> Dict[str, bool]:
        """
        Check snapshot logs for session timeout and t12Min/t34Min values.

        :return: Dictionary with analyze results.
        """

        for log_path in self._get_snapshot_logs_paths():
            logger.debug(f"==================== Checking log path: {log_path} ====================")
            if log_path.endswith('_syslog.tgz'):
                for log_line in self._read_snapshot_l1_syslog_logs(log_path):
                    if self._is_log_line_older_than_time_from_test_start(log_line):
                        continue
                    self._check_if_line_is_one_way_delay(log_line)
                    self._check_if_errors_exists_in_log_line(log_line)
            elif log_path.endswith('_L1_logs.tgz') or log_path.endswith('_crash.tgz'):
                for log_line in self._read_snapshot_l1_crash_logs(log_path):
                    if self._is_log_line_older_than_time_from_test_start(log_line):
                        continue
                    self._check_if_line_is_one_way_delay(log_line)
                    self._check_if_errors_exists_in_log_line(log_line)
        self._check_results()

    def _check_results(self) -> None:
        self._check_no_response_from_ru_error_logs()
        self._check_no_responses_error_logs()
        self._check_error_logs()

    def _check_no_response_from_ru_error_logs(self) -> None:
        """
        Check if there are any errors in the logs with no response from RU.
        It checks if the error is cleared by receiving a later log line with the same session ID and meas ID.
        """

        for error_log_line in self._lines_with_no_response_from_ru:
            for received_late_log_line in self._lines_with_received_late:
                if error_log_line.session_id == received_late_log_line.session_id:
                    if error_log_line.meas_id and received_late_log_line.meas_id:
                        error_log_line.error_cleared_by_receiving_later = True
                        logger.info(f"Received late log line: {received_late_log_line}\nSame session ID & meas ID\n"
                                    f"{error_log_line}")
                        break
            if not error_log_line.error_cleared_by_receiving_later:
                self._lines_with_errors.append(error_log_line)

    def _check_no_responses_error_logs(self) -> None:
        """
        Check if there are any errors in the logs with no responses.
        It checks if the error is cleared by receiving a later log line with the same session ID.
        """

        for error_log_line in self._lines_with_no_response_errors:
            for no_respose_from_ru_log_line in self._lines_with_no_response_from_ru:
                if error_log_line.session_id == no_respose_from_ru_log_line.session_id:
                    if no_respose_from_ru_log_line.error_cleared_by_receiving_later:
                        error_log_line.error_cleared_by_receiving_later = True
                        logger.info(f"No Response from RU, session ID: {no_respose_from_ru_log_line.session_id}, "
                                    f"meas ID: {no_respose_from_ru_log_line.meas_id}\nSame session ID as\n"
                                    f"{error_log_line}")
                        break
            if not error_log_line.error_cleared_by_receiving_later:
                self._lines_with_errors.append(error_log_line)

    def _check_error_logs(self) -> None:
        """
        Check if there are any errors in the logs.
        It checks for session timeout, periodic no response from RU, no response from RU,
        no response for, t12Min and t34Min incorrect values.
        It logs the errors and counts them.
        """

        for error_log_line in self._lines_with_errors:
            logger.error(error_log_line)
            for error in error_log_line.error_phrases:
                if "Incorrect t12Min" in error or "Incorrect t34Min" in error:
                    error = error.split(":")[0]
                self._results[error]['found'] = True
                self._results[error]['count'] += 1

    def _check_if_line_is_one_way_delay(self, log_line: LogEntry) -> None:
        """
        Check if the line is a One Way Delay.
        It checks for the presence of the One Way Delay pattern.

        :param line: Line from logs file.
        """

        if self._one_way_delay_pattern.search(log_line.line):
            self._one_way_delay_count += 1
        self._lines_checked += 1

    def _get_session_id(self, log_line: LogEntry) -> None:
        """
        Calculate session ID from the log line.
        It extracts the session ID from the log line using a regex pattern.

        :param log_line: LogEntry object containing the log line.
        """

        match = self._session_id_pattern.search(log_line.line)
        if match:
            log_line.session_id = match.group(1)

    def _get_meas_id(self, log_line: LogEntry) -> None:
        """
        Calculate meas ID from the log line.
        It extracts the meas ID from the log line using a regex pattern.

        :param log_line: LogEntry object containing the log line.
        """

        match = self._meas_id_pattern.search(log_line.line)
        if match:
            log_line.meas_id = match.group(1)

    def _check_if_line_is_received_late(self, log_line: LogEntry) -> None:
        """
        Check if the line contains 'received late' phrase.
        It checks for the presence of the received late pattern.

        :param log_line: LogEntry object containing the log line.
        """

        if self._received_late_pattern.search(log_line.line):
            self._get_session_id(log_line)
            self._get_meas_id(log_line)
            self._lines_with_received_late.append(log_line)

    def _check_if_errors_exists_in_log_line(self, log_line: LogEntry) -> None:
        """
        Check if errors exist in the log line.
        It checks for session timeout and t12Min/t34Min values.

        :param line: Line from logs file.
        """

        self._check_session_timeout_in_line(log_line=log_line)
        self._check_periodic_no_response_from_ru_in_line(log_line=log_line)
        self._check_no_response_from_ru_in_line(log_line=log_line)
        self._check_no_response_for_in_line(log_line=log_line)
        self._check_tmin_in_line(log_line=log_line, tmin_pattern=self._t12min_pattern, tmin_type='t12Min')
        self._check_tmin_in_line(log_line=log_line, tmin_pattern=self._t34min_pattern, tmin_type='t34Min')
        if log_line.line_with_errors:
            self._process_error_log_line(log_line)
        else:
            self._check_if_line_is_received_late(log_line)

    def _process_error_log_line(self, log_line: LogEntry) -> None:
        """
        Process the log line with errors.

        :param log_line: LogEntry object containing the log line with errors.
        """

        self._get_session_id(log_line)
        self._get_meas_id(log_line)
        if log_line.is_specific_error(self._periodic_no_response_from_ru_pattern.pattern):
            self._lines_with_no_response_errors.append(log_line)
        elif log_line.is_specific_error(self._no_response_for_pattern.pattern):
            self._lines_with_no_response_errors.append(log_line)
        elif log_line.is_specific_error(self._no_response_from_ru_pattern.pattern):
            self._lines_with_no_response_from_ru.append(log_line)
        else:
            self._lines_with_errors.append(log_line)

    def _check_session_timeout_in_line(self, log_line: LogEntry) -> None:
        """
        Check if session timeout exists in the log line.

        :param line: Line from logs file.
        """

        if self._session_timeout_pattern.search(log_line.line):
            log_line.error_phrases = self._session_timeout_pattern.pattern

    def _check_periodic_no_response_from_ru_in_line(self, log_line: LogEntry) -> None:
        """
        Check if no response from RU exists in the log line.

        :param line: Line from logs file.
        """

        if self._periodic_no_response_from_ru_pattern.search(log_line.line):
            log_line.error_phrases = self._periodic_no_response_from_ru_pattern.pattern

    def _check_no_response_from_ru_in_line(self, log_line: LogEntry) -> None:
        """
        Check if no response from RU exists in the log line.

        :param line: Line from logs file.
        """

        if self._no_response_from_ru_pattern.search(log_line.line):
            log_line.error_phrases = self._no_response_from_ru_pattern.pattern

    def _check_no_response_for_in_line(self, log_line: LogEntry) -> None:
        """
        Check if no response for exists in the log line.

        :param line: Line from logs file.
        """

        if self._no_response_for_pattern.search(log_line.line):
            log_line.error_phrases = self._no_response_for_pattern.pattern

    def _check_tmin_in_line(self, log_line: LogEntry, tmin_pattern: re.Pattern, tmin_type: str) -> None:
        """
        Check t12Min or t34Min values in line.

        :param line: Line from logs file.
        :param tmin_pattern: Regular expression pattern to match t12Min or t34Min values.
        """

        match = tmin_pattern.search(log_line.line)
        if match:
            tmin_value = int(match.group(1))
            if tmin_value < self._tmin_minimum_value or tmin_value > self._tmin_maximum_value:
                if tmin_type == 't12Min':
                    log_line.t12Min = tmin_value
                    log_line.error_phrases = f"Incorrect t12Min: {tmin_value}"
                elif tmin_type == 't34Min':
                    log_line.t34Min = tmin_value
                    log_line.error_phrases = f"Incorrect t34Min: {tmin_value}"

    def _read_snapshot_l1_crash_logs(self, log_file_path: str) -> Generator[str, None, None]:
        """
        Check crash logs for session timeout and t12Min/t34Min values.

        :param log_file_path: Path to the log file inside the snapshot.
        """
        parts = log_file_path.split('/')
        inner_zip_name, tgz_name = parts[0], parts[1]

        with zipfile.ZipFile(self._snapshot_file_path, 'r') as outer_zip:
            with outer_zip.open(inner_zip_name) as inner_zip_file:
                with zipfile.ZipFile(inner_zip_file, 'r') as inner_zip:
                    with inner_zip.open(tgz_name) as tgz_file:
                        with tarfile.open(fileobj=tgz_file, mode='r:gz') as outer_tgz:
                            for member in outer_tgz.getmembers():
                                if member.name.endswith('_journal.txt.gz'):
                                    logger.debug(f"Checking file: {tgz_name}/{member.name}")
                                    inner_tgz_member = outer_tgz.getmember(member.name)
                                    inner_tgz = outer_tgz.extractfile(inner_tgz_member)
                                    if inner_tgz:
                                        with gzip.GzipFile(fileobj=inner_tgz) as decompressed_file:
                                            for line in decompressed_file:
                                                yield self._decode_log_line(line)

    def _read_snapshot_l1_syslog_logs(self, log_file_path: str) -> Generator[str, None, None]:
        """
        Python Generator. Reads syslog logs from snapshot file list line by line, decodes it and yelds it.

        :param log_file_path: Path to the log file inside the snapshot.

        :return: Yields each line from the syslog logs.
        """

        parts = log_file_path.split('/')
        inner_zip_name, tgz_name, txt_file_name = parts[0], parts[1], './journal.txt'

        with zipfile.ZipFile(self._snapshot_file_path, 'r') as outer_zip:
            with outer_zip.open(inner_zip_name) as inner_zip_file:
                with zipfile.ZipFile(inner_zip_file, 'r') as inner_zip:
                    logger.debug(f"Checking file: {tgz_name}")
                    with inner_zip.open(tgz_name) as tgz_file:
                        with tarfile.open(fileobj=tgz_file, mode='r:gz') as tgz:
                            txt_member = tgz.getmember(txt_file_name)
                            txt_file = tgz.extractfile(txt_member)
                            if txt_file:
                                for line in txt_file:
                                    yield self._decode_log_line(line)

    def _get_snapshot_logs_paths(self) -> List[str]:
        """
        Get logs paths from snapshot file list.

        :return: List of logs paths.
        """

        logs_paths = []
        snapshot_file_list_content = self._get_snapshot_file_list()
        for key, values in snapshot_file_list_content.items():
            for value in values:
                for file_name in self._snapshot_tgz_files_to_check:
                    if value.endswith(file_name):
                        logs_paths.append(f"{key}/{value}")
        return logs_paths

    def _get_snapshot_file_list(self) -> Dict[str, List[str]]:
        """
        Reads snapshot file list and returns a dictionary with the content.

        :return: Dictionary with the content of the snapshot file list.
        """

        snapshot_file_list_content = dict()
        for line in self._read_snapshot_file_list():
            if line == "" or line.endswith('.txt') or line.endswith('.ims2'):
                continue
            if line.endswith(":"):
                current_key = line[:-1]
                snapshot_file_list_content[current_key] = []
            else:
                snapshot_file_list_content[current_key].append(line)
        return snapshot_file_list_content

    def _read_snapshot_file_list(self) -> Generator[str, None, None]:
        """
        Python Generator. Reads snapshot file list line by line, decodes it and yelds it.

        :return: Yields each line from the snapshot file list.
        """

        with zipfile.ZipFile(self._snapshot_file_path, 'r') as zip_ref:
            with zip_ref.open(self._snapshot_txt_file_list) as file:
                for line in file:
                    yield self._decode_line(line)

    def _is_log_line_older_than_time_from_test_start(self, line: str) -> bool:
        """
        Check if the log line is older than the time from test start.

        :param line: Log line to check.

        :return: True if the log line is older than the time from test start, False otherwise.
        """

        if line.timestamp is None:
            return True
        if line.timestamp < self._time_from_test_start:
            return True
        return False

    def _decode_line(self, line: bytes) -> str:
        """
        Decode a line from bytes to string using UTF-8 or ISO-8859-1 as fallback.

        :param line: The raw byte line to decode.
        :return: Decoded and stripped string.
        """
        try:
            return line.decode('utf-8').strip()
        except UnicodeDecodeError:
            return line.decode('ISO-8859-1').strip()

    def _decode_log_line(self, log_line: str) -> LogEntry:
        """
        Decode a log line from bytes to string using UTF-8 or ISO-8859-1 as fallback.
        And then returns it as LogEntry object.

        :param log_line: The raw byte log line to decode.
        :return: Decoded and stripped string.
        """
        try:
            line = log_line.decode('utf-8').strip()
        except UnicodeDecodeError:
            line = log_line.decode('ISO-8859-1').strip()
        return LogEntry(line=line)
