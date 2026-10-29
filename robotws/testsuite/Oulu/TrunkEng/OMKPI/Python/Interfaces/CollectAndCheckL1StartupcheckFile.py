"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
import re
import shutil
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ScriptIssue, EnvironmentIssue)
import testsuite.Oulu.TrunkEng.Common.Python.Resources.GetFileFromArchivedFolder as GetFromArchived
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.exceptions import NoL1StartupCheckpoint, L1StartupCheckpointFailure


class CollectAndCheckL1StartupcheckFile:
    """
    Class for collect and check L1Startupcheck file. This class is called in 'Common Postconditions' KW of
    common_resouces.robot if TAG/Suite Variable ${CHECK_L1_STARTUP_CHECK_LOGS} is set to True.

    The class does the following:
    1) It gets L1StartupcheckLog.txt files from snapshot file collected by COLLECTLOGS library.
    2) It checks that L1StartupcheckLog.txt files contain expected prints after the latest STRTCP_L1PF_RESET_START
    print.
    :raises NoL1StartupCheckpoint: If L1 Startup check file is not found in snapshot
    :raises EnvironmentIssue: If snapshot file is not found
    :raises ScriptIssue: If L1StartupcheckLog.txt file cannot be retrieved
    :raises L1StartupCheckpointFailure: If not all expected prints were found in L1StartupcheckLog files
    """

    first_print_or_rst = "STRTCP_L1PF_RESET_START"

    L1StartupCheckpoints = [
        "STRTCP_L1PF_ALL_APP_STOP",
        "STRTCP_L1PF_FW_BOOT_START",
        "STRTCP_L1PF_UBOOT_START",
        "STRTCP_L1PF_UBOOT_NW_READY",
        "STRTCP_L1PF_KERNEL_START",
        "STRTCP_L1PF_BASIC_TARGET_READY",
        "STRTCP_L1PF_NW_ONLINE_TARGET_READY",
        "STRTCP_L1PF_MULTIUSER_TARGET_READY",
        "STRTCP_L1PF_SYSCOM_TARGET_READY",
        "STRTCP_L1PF_AUTOD_TARGET_READY",
        "STRTCP_L1PF_MIDDLEWARE_TARGET_READY",
        "STRTCP_L1PF_SW_TARGET_READY"
    ]
    power_reset = "STRTCP_L1PF_EXTENDED_MEMORY_TEST"
    file_print_lines = {}

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")

    def _get_l1_tgz_files_from_snapshot(self, path_of_snapshot):
        """
        Get L1 Startup check files from snapshot.

        :param path_of_snapshot: Path of snapshot file
        :return: List of local paths of L1 Startup check tgz files
        :rtype: list
        :raises NoL1StartupCheckpoint: If L1 Startup check file is not found in snapshot
        :raises EnvironmentIssue: If snapshot file is not found
        """
        info("Get L1 Startup check files from snapshot.")
        try:
            found_tgz_files = self.collect_logs.get_file_from_zip_or_tar(
                "011_L1_logs.tgz", archived_path=path_of_snapshot, folder_to_extract=self.logger.log_dir,
                get_multiple_files=True)
            if not found_tgz_files:
                error(f"No files found from snapshot ({path_of_snapshot}) that name has 011_L1_logs.tgz. Unable to get "
                      f"L1StartupCheckpointsLog.txt file.")
                raise NoL1StartupCheckpoint("L1 Startup check file not found in snapshot.")
            info(f"L1Startupcheck tgz files in {path_of_snapshot} are:\n{found_tgz_files}")
            return found_tgz_files
        except EnvironmentIssue as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"Environment issue occurred: {e.__class__.__name__}:{e}")
            raise NoL1StartupCheckpoint(f"Failed to get L1Startupcheck file: {e}")

    def _get_l1_startupcheck_txt_files_to_test_logs(self, found_tgz_files):
        """
        Get L1Startupcheck txt files to test logs.
        :param found_tgz_files: List of local paths of L1 Startup check tgz files
        :return: Path to logger directory where L1Startupcheck txt files are collected
        """
        try:
            all_files = []
            all_ok = True
            for tgz_file in found_tgz_files:
                files_in_folder = GetFromArchived.search_from_tgz_archive(
                    tgz_file, "", file_to_search="L1StartupCheckpointsLog.txt", return_multiple=True,
                    remove_compressed=False)
                if files_in_folder:
                    for txt_file in files_in_folder:
                        if txt_file is None or not os.path.isfile(txt_file):
                            error(f"L1StartupCheckpointsLog.txt file was not found in {tgz_file}.")
                            all_ok = False
                        if txt_file not in all_files:
                            all_files.append(txt_file)
                else:
                    error(f"No L1StartupCheckpointsLog.txt file was found in {tgz_file}.")
                    all_ok = False
            # info(f"L1StartupCheckpointsLog.txt files from {path_of_snapshot} {path_of_snapshot}")
            new_folder = os.path.join(self.logger.log_dir, "L1StartupcheckFiles")
            os.makedirs(new_folder, exist_ok=True)
            info(f"Create folder {new_folder} to which L1StartupcheckLog.txt files will be collected")
            for file_name in all_files:
                parts = os.path.normpath(file_name).split(os.sep)
                new_file_name = os.path.join(new_folder, f"{parts[-3]}_{parts[-1]}")
                shutil.move(file_name, new_file_name)
                info(f"{file_name} file moved to {new_file_name}")
            if not all_ok:
                error("Some L1StartupCheckpointsLog.txt files were not found in tgz archives.")
                raise NoL1StartupCheckpoint("L1 Startup check file not found in some tgz archives.")
            self.logger.debug("Remove temporary extracted tgz files, delete /home/ute/extract_tgz.")
            try:
                shutil.rmtree("/home/ute/extract_tgz", ignore_errors=True)
            except Exception as e:
                info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                warning(f"Could not remove /home/ute/extract_tgz folder: {e}")
            return new_folder
        except Exception as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"An unexpected error occurred: {e.__class__.__name__}:{e}")
            raise ScriptIssue(f"Failed to get L1StartupcheckLog.txt file: {e}")

    def _get_latest_occurrence_of_print_in_file(self, file_path):
        """
        Get last occurrence of print in file.

        :param file_path: Path to file to search
        :return: datetime of the last occurrence of print in file, None if print is not found
        """
        latest_line = None
        latest_time = None
        with open(file_path, "r") as f:
            for line in f:
                if CollectAndCheckL1StartupcheckFile.first_print_or_rst in line:
                    timestamp_str = line.split(',')[0].strip()
                    dt = datetime.strptime(timestamp_str, "%Y-%m-%dT%H:%M:%S.%fZ")
                    if latest_time is None or dt > latest_time:
                        latest_time = dt
                        latest_line = line.strip()
        if latest_line:
            info(f"Last occurrence of {self.first_print_or_rst} in {file_path} is in line:\n\t{latest_line}")
            fname = os.path.basename(file_path)
            if fname not in self.file_print_lines:
                self.file_print_lines[fname] = {self.first_print_or_rst: [line.strip()]}
            else:
                if self.first_print_or_rst not in self.file_print_lines[fname]:
                    self.file_print_lines[fname][self.first_print_or_rst] = [line.strip()]
                else:
                    self.file_print_lines[fname][self.first_print_or_rst].append(line.strip())
            return latest_time
        return None
        # else:
        #     error(f"{CollectAndCheckL1StartupcheckFile.first_print_or_rst} print was not found in {file_path}.")
        #     raise NoL1StartupCheckpoint(f"{CollectAndCheckL1StartupcheckFile.first_print_or_rst} was not found")

    def _go_through_file_and_check_expected_prints(self, file_path, expected_prints, file_to_check, first_reset_time):
        """
        Go through file and check expected prints.
        :param file_path: Path to file to search
        :param expected_prints: List of expected prints to search
        :param file_to_check: Name of the file to check
        :param first_reset_time: Datetime of the first reset time to start checking from
        :return: True if all expected prints are found after first reset time, False otherwise
        :rtype: bool
        """
        try:
            with open(file_path, "r") as f:
                for line in f:
                    for expected_print in expected_prints:
                        if expected_print in line:
                            timestamp_str = line.split(',')[0].strip()
                            dt = datetime.strptime(timestamp_str, "%Y-%m-%dT%H:%M:%S.%fZ")
                            if dt < first_reset_time:
                                continue
                            else:
                                if file_to_check not in self.file_print_lines:
                                    self.file_print_lines[file_to_check] = {expected_print: [line.strip()]}
                                else:
                                    if expected_print not in self.file_print_lines[file_to_check]:
                                        self.file_print_lines[file_to_check][expected_print] = [line.strip()]
                                    else:
                                        self.file_print_lines[file_to_check][expected_print].append(
                                            line.strip())
                                info(f"Found expected print {expected_print} in file {file_to_check}:\n\t"
                                     f"{line.strip()}")
            return True
        except Exception as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"An unexpected error occurred while going through {file_path}: {e.__class__.__name__}:{e}\nCheck if"
                  f" file is corrupted.")
            return False

    def check_l1_startupchecklog_file_contents(self, l1_startupcheck_file_folder, power_reset):
        """
        Check l1 startupcheck file contents checks that L1StartupcheckLog.txt file contains expected prints.

        :param l1_startupcheck_file_folder: Path to logger directory where L1Startupcheck txt files are collected
        :param power_reset: Whether the test is power reset or not, if it is, also STRTCP_L1PF_EXTENDED_MEMORY_TEST
                            print is expected to be found in L1StartupcheckLog.txt file
        """
        all_ok = True
        expected_prints = list(CollectAndCheckL1StartupcheckFile.L1StartupCheckpoints)
        if power_reset:
            expected_prints = expected_prints.append(CollectAndCheckL1StartupcheckFile.power_reset)
        for file_to_check in os.listdir(l1_startupcheck_file_folder):
            if file_to_check.endswith(".txt"):
                file_path = os.path.join(l1_startupcheck_file_folder, file_to_check)
                first_reset_time = self._get_latest_occurrence_of_print_in_file(file_path)
                if first_reset_time:
                    all_ok = self._go_through_file_and_check_expected_prints(file_path, expected_prints, file_to_check,
                                                                             first_reset_time) and all_ok
                else:
                    error(f"{self.first_print_or_rst} print was not found in {file_path}, unable to check that expected"
                          f" prints are found after it.")
                    all_ok = False
        # Now check that all expected prints were found after the latest STRTCP_L1PF_RESET
        # After going through the file, check that all expected prints were found
        expected_prints.append(self.first_print_or_rst)
        missing = {}
        self.logger.debug(f"Prints found in L1StartupCheckpointsLog.txt files are:\n{self.file_print_lines}")
        for file_path, prints_dict in self.file_print_lines.items():
            for expected_print in expected_prints:
                if expected_print not in prints_dict:
                    if file_path not in missing:
                        missing[file_path] = [expected_print]
                    else:
                        if expected_print not in missing[file_path]:
                            missing[file_path].append(expected_print)
                        else:
                            self.logger.debug(f"{expected_print} print is already in missing prints for {file_path}.")
        self.logger.debug(f"Missing prints in L1StartupCheckpointsLog.txt files are:\n{missing}")
        if missing:
            for stc_file, stc_prints in missing.items():
                error(f"File {stc_file} didn't have prints {', '.join(stc_prints)}")
            all_ok = False
        else:
            info("All expected L1 startup check prints are found in all L1StartupCheckpointsLog.txt files. --> OK.")
        if not all_ok:
            BuiltIn().set_suite_variable("${KW_SUCCESS}", False)
            raise L1StartupCheckpointFailure("Not all expected prints were found in L1Startupcheck files. --> FAIL.")

    def get_and_check_l1_startupcheck_files(self, path_of_snapshot=None):
        """
        Get and check l1startupcheck files gets L1StartupcheckLog.txt files from snapshot and checks that content is
        expected.

        :param path_of_snapshot: Path of snapshot file
        :raises EnvironmentIssue: If snapshot file is not found
        :raises ScriptIssue: If L1Startupcheck file cannot be retrieved
        """
        if not path_of_snapshot:
            self.logger.debug("Path of snapshot is not provided, check path given in COLLECTLOGS.")
            if not self.collect_logs.snapshot_file_name or not os.path.isfile(self.collect_logs.snapshot_file_name):
                self.logger.debug("Collecting snapshot as it is not already collected.")
                self.collect_logs.collect_snapshot()
            path_of_snapshot = self.collect_logs.snapshot_file_name
        if not path_of_snapshot:
            error("No snapshot file. Cannot get L1 Startupcheck files.")
            raise EnvironmentIssue("No snapshot file.")
        found_tgz_files = self._get_l1_tgz_files_from_snapshot(path_of_snapshot)
        l1_startupcheck_file_folder = self._get_l1_startupcheck_txt_files_to_test_logs(found_tgz_files)
        power_reset = BuiltIn().get_variable_value("${POWER_RESET_TEST}", default=False)
        self.check_l1_startupchecklog_file_contents(l1_startupcheck_file_folder, power_reset)
        # if not expected_prints_are_found:
        #     error("Not all expected prints were found in L1Startupcheck files.")
        #     raise L1StartupCheckpointFailure("Not all expected prints were found in L1Startupcheck files.")
