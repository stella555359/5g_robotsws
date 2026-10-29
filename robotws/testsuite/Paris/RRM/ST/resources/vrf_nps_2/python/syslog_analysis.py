#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
Syslog library to analyse syslog files
"""

__version__ = "1.0.2"
__author__ = "Abderrahmane NEZROUK"
__email__ = "abderrahmane.nezrouk@nokia.com"
__maintainer__ = "Abderrahmane NEZROUK"


import os
import re
import zipfile
import tarfile
import json
import logging


# List of patterns to search for in the syslog files
SYSLOG_ERRS_PATTERNS = [
    # List of Error Messages
    r"ERR/",
    r"recovery action",
    r"Fatality",
    r"Fault_signature",
    r"Fault signature",
    r"rfResetFault",
    r"Handling FAULT_REQ_MSG",
    r"recovery alarm",
    r"[AlarmReporter] Reported alarm",
    r"[AlarmReporter] Activating transient alarm",
    r"Invalid memory reference",
    r"Please contact the owner",
    r"fatality",
    r"fatal",
    r"critical",
    r"setup failure",
    r"sw_failure",
    r"Abort signal received",
    r"handleCoreDumpStarted: [IN] AAERROR_CORE_DUMP_STARTED_IND_MSG",
    r"handleCoreDumpCompleted: [IN] AAERROR_CORE_DUMP_COMPLETED_IND_MSG",
    r"INF/coredumper.py",
    r"dumped core",
    r"SEGMENTATION FAULT",
    r"BUS ERROR",
    r"Error Handler exception report",
    r"LINK STATUS CHANGED",
    r"DSP CRASH INFO",
    r"KILLED PROCESS",
    r"Warm reset : Recovery",
    r"Executing recovery action WarmReset",
    r"category = Recovery",
    r"autonomous reset as recovery action",
    r"RESET Warm reset: board = 0xd+, cpu = 0x.*, category =",
    r"resetCause=RecoveryReset",
    r"Diagnostic Files collected",
    r"Assertion error occurred",
    r"BB_CAPACITY is dead",
    r"severity changed to: Critical",
    r"RF Module configuring failed",
    r"Radio Module fail safe mode",
    r"System module site reset : Reconfiguration",
    r"No connection to unit",
    r"unhandled exception caught",
    r"Spurious warm reset",
    r"AAERROR_CORE_DUMP_COMPLETED_IND_MSG",
]

SYSLOG_WARS_PATTERNS = [
    # List of Warnings Messages
    r"WARNING",
    r"WARN",
    r"DEPRECATED",
    r"UNSUPPORTED",
]

SYSLOG_PERFS_PATTERNS = [
    # List of Messages related to performance
    r"HIGH LATENCY",
    r"PACKET LOSS",
    r"THROUGHPUT DEGRADATION",
    r"JITTER",
]

SYSLOG_OPRS_PATTERNS = [
    # List of Messages related to operations
    r"LINK STATUS CHANGED",
    r"CONNECTION LOST",
    r"TIMEOUT",
    r"RETRY",
    r"RESTART",
    r"REBOOT",
    r"OVERLOAD",
    r"RESOURCE EXHAUSTED",
    r"DELAY",
]

SYSLOG_SKIP_PATTERNS = [
    "AAPRO_SUPERVISION_REG_REQ_MSG.*criticality=",
    "AAPRO_SUPERVISION_REG_RESP_MSG.*criticality=",
    "/MRBTS-1/RAT-1/URI-4 , FaultId: 61649",
    "ERR/HWA/INET, [TestPortCreator] DynPort[0-9]+ port [0-9]+",
    "Not fill additionalText5to7 because not find FAULT_SIGNATURE exist",
    "[ CriticalVoltageHighCalculator ] operator()(): translate threshold: 100",
    "[ CriticalVoltageLowCalculator ] operator()(): translate threshold: -100",
    "INF/LFS/LinuxSyslog, VNODE_0.*AaProCmdGetEeCriticalityFromEnv: .*critical",
    "INF/LFS/LinuxSyslog, VNODE_0.* Tried to close",
    "CP-IF cancel fault ignored, sdlkey may be removed already",
    "StartupServiceM ERR/HWA/INET, [TestPortCreator] .* port .* creation",
    "AaProEuSupervisionUpdateEeCriticalEnv: EE criticality env var updated",
    "[SystemCriticalEventLog] constructed!",
    "[registerMiniImsSnapshot] registerFileOnSnapshot,",
    "ERR/CCS/AaSysComGw, ~ControlThread(): Tried to closeisCriticalBand",
    "INF/HWA/RESET, subscribeCoreDumpIndications: AaSysMbSubscribe OK for AAERROR_CORE_DUMP_COMPLETED_IND_MSG",
    "INF/HWA/HWATIME, [HwCapabilitiesScanner] critical_functionality: supported",
    "INF/CCS/AaPro, AaProSupervisionCriticalPidsAdd: Added new critical PID",
    "INF/CCS/AaPro, AaProSystemRaw: oneshot supervision timer registered"
]


def setup_logging(log_file: str) -> logging.Logger:
    """
    Set up logging configuration.

    :param log_file: Path to the log file.
    :return: Configured logger.
    """
    # Create a custom logger
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)

    # Create handlers
    file_handler = logging.FileHandler(log_file)
    console_handler = logging.StreamHandler()

    # Create formatters and add them to handlers
    file_format = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    console_format = logging.Formatter('%(levelname)s - %(message)s')

    file_handler.setFormatter(file_format)
    console_handler.setFormatter(console_format)

    # Add handlers to the logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logger


def stop_logging(logger: logging.Logger) -> None:
    """
    Stop logging.

    :param logger: Logger to stop.
    """
    handlers = logger.handlers[:]
    for handler in handlers:
        handler.close()
        logger.removeHandler(handler)


class syslog_analysis:
    def __init__(self):
        self.log_file = None
        self.results_file = None
        self.log_directory = None
        self.output_directory = None
        self.parsed_lines = {}
        SYSLOG = []
        SYSLOG.extend(SYSLOG_ERRS_PATTERNS)
        # SYSLOG.extend(SYSLOG_WARS_PATTERNS)
        # SYSLOG.extend(SYSLOG_PERFS_PATTERNS)
        # SYSLOG.extend(SYSLOG_OPRS_PATTERNS)
        self.syslog_patterns = [re.compile(pattern) for pattern in SYSLOG]
        self.msg_to_skip = [re.compile(pattern) for pattern in SYSLOG_SKIP_PATTERNS]
        self.logger = None
        self.syslog_fn_pattern = re.compile(r".*(SYSLOG_\d+\.txt|SYSLOG_\d+\.LOG|syslog\.log)$", re.IGNORECASE)

    def run_analysis(self, log_directory: str, output_directory: str = None, custom_patterns: list = None,
                     custom_msg_to_skip: list = None, log_header=None,
                     flush: bool = True) -> None:
        """
        Run the syslog analysis.

        :param log_header: a message to log before starting the analysis
        :param log_directory: Directory containing the log files.
        :param output_directory: Directory to save the output files.
        :param custom_patterns: List of custom patterns to search for.
        :param custom_msg_to_skip: List of custom messages to skip.
        :param flush: Whether to flush the parsed lines before analysis.
        """
        self.log_directory = log_directory
        self.output_directory = output_directory or log_directory
        os.makedirs(self.output_directory, exist_ok=True)
        self.log_file = os.path.join(self.output_directory, 'syslog_analysis_debug.log')
        self.results_file = os.path.join(self.log_directory, 'parsed_lines_with_errors.json')

        # Set up logging
        self.logger = setup_logging(self.log_file)
        if custom_patterns:
            self.syslog_patterns.extend(re.compile(pattern) for pattern in custom_patterns)
        if custom_msg_to_skip:
            self.msg_to_skip.extend(re.compile(pattern) for pattern in custom_msg_to_skip)
        if flush:
            self.flush()
        # Log the header
        if not log_header:
            log_header = "Starting syslog analysis"
        self.log_header_message(log_header)
        self._analyze_directory()
        # Stop logging
        stop_logging(self.logger)

    def flush(self) -> None:
        """Flush the parsed lines."""
        self.parsed_lines = {}

    def line_starts_with_pattern(self, line: str) -> bool:
        pattern = r"^\d{6} \d{2}\.\d{2} \d{2}:\d{2}:\d{2}\.\d{3} \[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\]"
        return bool(re.match(pattern, line))

    def _parse_log_line(self, line: str) -> tuple:
        """
        Parse a single log line.

        :param line: Log line to parse.
        :return: Tuple containing component name and parsed line dictionary.
        """
        parts = line.split(" ")
        if len(parts) > 4:
            ind = 4 if self.line_starts_with_pattern(line) else 0
            try:
                return parts[ind+1], {
                    'component_code': parts[ind],
                    'timestamp': parts[ind+2][1:-1],  # Remove brackets
                    'processing': " ".join(parts[ind+3:])[:-1]
                }
            except Exception:
                return None
        return None

    def is_syslog_file(self, file_name: str) -> bool:
        """
        Check if the file name matches the pattern exp SYSLOG_0001.txt.

        :param file_name: Name of the file to check.
        :return: True if the file name matches the pattern, False otherwise.
        """

        return bool(self.syslog_fn_pattern.match(file_name))

    def _parse_syslog(self, log_file_path: str) -> None:
        """
        Parse a syslog file.

        :param log_file_path: Path to the syslog file.
        """
        file_name = os.path.basename(log_file_path)
        self.parsed_lines[file_name] = {}
        matched_lines = {}
        with open(log_file_path, 'r') as file:
            for line in file:
                parsed_line = self._parse_log_line(line)
                if parsed_line:
                    component_name, parsed_line = parsed_line
                    err_pattern = self._analyze_errors(parsed_line['processing'])
                    if err_pattern:
                        self.logger.info(line)
                        matched_lines.setdefault(err_pattern, []).append({component_name: parsed_line})
            if matched_lines:
                self.parsed_lines[file_name] = matched_lines

    def _parse_zipped_syslog(self, zip_file_path: str) -> None:
        """
        Parse a zipped syslog file.

        :param zip_file_path: Path to the zipped syslog file.
        """
        with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
            for file_name in zip_ref.namelist():
                if self.is_syslog_file(file_name):
                    self.logger.info(f"     {file_name}")
                    self.parsed_lines[file_name] = {}
                    matched_lines = {}
                    with zip_ref.open(file_name) as file:
                        self.logger.debug(f"{'*' * 25} Post processing syslog file: {file_name} {'*' * 25}")
                        for line in file:
                            line = line.decode('utf-8')
                            parsed_line = self._parse_log_line(line)
                            if parsed_line:
                                component_name, parsed_line = parsed_line
                                err_pattern = self._analyze_errors(parsed_line['processing'])
                                if err_pattern:
                                    self.logger.info(line)
                                    matched_lines.setdefault(err_pattern, []).append({component_name: parsed_line})
                    if matched_lines:
                        self.parsed_lines[file_name] = matched_lines

    def _parse_tgz_syslog(self, tgz_file_path: str) -> None:
        """
        Parse a .tgz syslog file.

        :param tgz_file_path: Path to the .tgz syslog file.
        """
        with tarfile.open(tgz_file_path, 'r:gz') as tar_ref:
            for member in tar_ref.getmembers():
                if member.isfile() and self.is_syslog_file(member.name):
                    self.logger.info(f"     {member.name}")
                    self.parsed_lines[member.name] = {}
                    matched_lines = {}
                    file = tar_ref.extractfile(member)
                    if file:
                        self.logger.debug(f"{'*' * 25} Post processing syslog file: {member.name} {'*' * 25}")
                        for line in file:
                            line = line.decode('utf-8')
                            parsed_line = self._parse_log_line(line)
                            if parsed_line:
                                component_name, parsed_line = parsed_line
                                err_pattern = self._analyze_errors(parsed_line['processing'])
                                if err_pattern:
                                    self.logger.info(line)
                                    matched_lines.setdefault(err_pattern, []).append({component_name: parsed_line})
                    if matched_lines:
                        self.parsed_lines[member.name] = matched_lines

    def _analyze_errors(self, processing_msg: str = None) -> str:
        """
        Analyze errors in the processing message.

        :param processing_msg: Processing message to analyze.
        :return: Matched pattern if found, else None.
        """
        for pattern in self.msg_to_skip:
            if pattern.search(processing_msg):
                return None
        for pattern in self.syslog_patterns:
            if pattern.search(processing_msg):
                return pattern.pattern
        return None

    def _analyze_directory(self) -> None:
        """Analyze all files in the log directory."""
        files = [f for f in os.listdir(self.log_directory) if os.path.isfile(os.path.join(self.log_directory, f))]
        for file in files:
            log_file_path = os.path.join(self.log_directory, file)
            if self.is_syslog_file(file):
                self.logger.info(f"Analyzing {file}")
                self._parse_syslog(log_file_path)
            elif file.endswith(".zip"):
                self.logger.info(f"Analyzing zipped file {file}")
                self._parse_zipped_syslog(log_file_path)
            elif file.endswith(".tgz"):
                self.logger.info(f"Analyzing tgz file {file}")
                self._parse_tgz_syslog(log_file_path)
        self._save_results_to_json()

    def _save_results_to_json(self) -> None:
        """Save the parsed lines with errors to a JSON file."""
        with open(self.results_file, 'w') as f:
            json.dump(self.parsed_lines, f, indent=4)

    def results_summary(self) -> str:
        """
        Generate a summary of the results.

        :return: Summary string.
        """
        summary = f"{'*' * 25} \n"
        for log_file_name, errors in self.parsed_lines.items():
            summary += f"  Syslog file processed: \"{log_file_name}\" \n"
            if errors:
                summary += "  Matched patterns found \n"
                for pattern, entries in errors.items():
                    summary += f"    For \"{pattern}\": {len(entries)} entries found \n"
            else:
                summary += f"  No patterns found !!! \n"
            summary += f"{'*' * 25} \n"
        summary += "  Please, refer to the result file for more details \n"
        summary += f"  File: {self.results_file} \n"
        summary += f"{'*' * 25} \n"
        return summary

    def log_header_message(self, message: str) -> None:
        """
        Log a message.

        :param message: Message to log.
        """
        self.logger.info(f" {'*' * 25} \n        {'*' * 25} \n")
        self.logger.info(f" {' ' * 10}{message} \n")
        self.logger.info(f" {'*' * 25} \n        {'*' * 25} \n")
