"""
:copyright: Nokia
:author: marcin.bednarski@nokia.com
:maintainer: marcin.bednarski@nokia.com
"""

import tarfile
from pathlib import Path

from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console, log_warn_to_console

from testsuite.Wroclaw.RRM.resources.syslog_checker import syslog_checker


def _extract_syslog_from_passed_test() -> list[str]:
    test_dir = Path(f'{BuiltIn().get_variable_value("${OUTPUT_DIR}")}/'
                    f'{BuiltIn().get_variable_value("${TEST_NAME}")}').resolve()
    tgz_files = list(test_dir.rglob("syslog_files*.tgz"))
    extracted_files = []
    if not tgz_files:
        log_info_to_console(f"No syslog archives found in '{test_dir}'.")
        return []
    for tgz_file in tgz_files:
        try:
            with tarfile.open(tgz_file, "r:gz") as tar:
                tar.extractall(path=tgz_file.parent)
                extracted_files.extend([(tgz_file.parent / member.name).resolve() for member in tar.getmembers() if
                                        member.name.endswith('.LOG')])
        except tarfile.TarError as e:
            log_warn_to_console(f"[{tgz_file.parent}] Failed to extract '{tgz_file.name}': {e}")
    return extracted_files


def _remove_extracted_syslog_files(syslog_files: list) -> None:
    for syslog_file in syslog_files:
        try:
            syslog_file.unlink(missing_ok=True)
        except Exception as e:
            log_warn_to_console(f"Failed to remove '{syslog_file}': {e}")


def find_suspicious_prints_in_passed_test() -> None:
    """
    Extracts ``syslog_files*.tgz`` archives, analyzes the logs for suspicious
    prints in the current passed test, and removes the extracted files after analysis.
    """
    log_info_to_console(f"Scanning passed iterations for suspicious syslog prints.")
    syslog_files = _extract_syslog_from_passed_test()
    syslog_checker().find_suspicious_logs()
    _remove_extracted_syslog_files(syslog_files)
