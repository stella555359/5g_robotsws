"""
:copyright: Nokia Networks
:author: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:maintainer: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:version: 0.1
"""

import csv
import os
import sys
import re
import shutil
import zipfile
from datetime import datetime

import paramiko
import pexpect
import requests
from robot.api import logger


class Emil:

    def __init__(self):
        pass

    def collect_aatraces(self, logs_collecting_time,
                         sack_path, csv_path,
                         logs_dir, bts_name="4G_SBTS",
                         path_to_run_emil="/opt/nokia/emil/run_emil",
                         emil_name_value="TAEmilLogs",
                         emil_timeout_value="1",
                         current_user="ute"):
        """
        Connects to EMIL and collects aaTraces. This method creates
        logfile.txt with logs from pexpect console and Escript file
        with script used for EMIL. It also moves all logs collected
        by EMIL to directory logs_dir.

        :param logs_collecting_time: Time in seconds for collecting aaTraces
               e.g. "120"
        :param sack_path: Absolute path where EMIL sack directory can be found e.g.
               "/home/ute/Downloads/test/2/SBTS00_IDA_9999_201106_000006"
        :param csv_path: Absolute path to EMIL CSV file with BTS data.
               e.g. "/home/ute/Downloads/test/emil.csv"
        :param logs_dir: Absolute path where logs will be saved,
               e.g. "/home/ute/Downloads/test"
        :param bts_name: Name of BTS in CSV file to which EMIL will be connecting
               Default value: "4G_SBTS"
        :param path_to_run_emil: Absolute path to run_emil execution file. e.g.
               "/opt/nokia/emil/run_emil"
        :param emil_name_value: Name of directory where logs will be saved. Full
               path will look like in example:
               /home/ute/.local/share/Emil/<emil_name_value>_<currently_logged_user>
               Default value: "TAEmilLogs"
        :param emil_timeout_value: Timeout for EMIL (parmater timeout passed in command
               to run EMIL). Timeout of whole emil process is set to be 5 min
               longer. Value in hours. Default value: "1"
        :param current_user: user running EMIL
        """

        process_timeout = int(emil_timeout_value) * 3600 + 300
        # timeout for EMIL process longer than EMIL defined timeout by 5 min

        emil_console_log_path = os.path.join(logs_dir, "logfile.txt")
        script_path = os.path.join(logs_dir, "Escript")
        logger.debug('Creating log file for EMIL')
        f = open(emil_console_log_path, 'w+')
        logger.debug('Creating EMIL script with parameters:csv_path={}, bts_name={}, '
                     'script_path={}, logs_collecting_time={}'.format(csv_path,
                                                                      bts_name, path_to_run_emil,
                                                                      emil_name_value, emil_timeout_value,
                                                                      script_path,
                                                                      logs_collecting_time))
        self._create_emil_script(csv_path, bts_name, script_path,
                                 logs_collecting_time=logs_collecting_time)
        logger.console('\nStarting EMIL')
        logger.debug('Starting EMIL with parameters:path_to_run_emil={}, '
                     'emil_name_value={}, emil_timeout_value={}, sack_path={}, script_path={}, '
                     'process_timeout={}, emil_console_log_path'.format(path_to_run_emil,
                                                                        emil_name_value,
                                                                        emil_timeout_value, sack_path,
                                                                        script_path,
                                                                        process_timeout,
                                                                        emil_console_log_path))
        emil_child = pexpect.spawn("{} --name {} --timeout {} --sackpath {} "
                                   "--script {}".format(path_to_run_emil, emil_name_value,
                                                        emil_timeout_value, sack_path,
                                                        script_path),
                                   timeout=process_timeout, logfile=f, encoding='utf-8')
        emil_child.expect(".*Session timed out, or .exit. requested.*")
        logger.console('\nEMIL stopped')
        f.close()

        source_dir = "/home/ute/.local/share/Emil/{}_{}".format(emil_name_value, current_user)
        destination_dir = os.path.join(logs_dir, "{}_{}".format(emil_name_value, current_user))
        logger.debug('Moving log files from {} to {}'.format(source_dir, destination_dir))
        logger.console('\nMoving log files')
        shutil.move(source_dir, destination_dir)
        logger.console('\nMoving log files finished.')

    @staticmethod
    def _create_emil_script(csv_path, bts_name, script_path, logs_collecting_time):

        """
        Creates script for EMIL.

        :param csv_path: Absolute path to EMIL CSV file with BTS data.
               e.g. "/home/ute/Downloads/test/emil.csv"
        :param bts_name: Name of BTS in CSV file to which EMIL will be connecting
               Default value: "4G_SBTS"
        :param script_path: Absolute path where script will be saved.
               e.g. "/home/ute/Downloads/test/Escript"
        :param logs_collecting_time: Time in seconds for collecting aaTraces
               e.g. "120"
        """

        f = open(script_path, "w+")
        f.write("show all\nimport {}\nconnect {}\nsleep 120\nshow all\nsleep {}\ndisconnect {}\n"
                "files\nexit\n".format(csv_path, bts_name, logs_collecting_time, bts_name))

        f.close()

    @staticmethod
    def download_sack(release, sw_version, destination_dir, tmp_dir="/tmp/EMIL_logs", chunk_size=128):

        """
        Downloads SACK from
        https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build.

        :param sw_version: Version of SW for which SACK should be downloaded.
               e.g. SBTS00_ENB_9999_201118_000013
        :param destination_dir: Absolute path to directory where SACK should
               be saved, e.g. "/home/ute/Downloads/test"
        :param tmp_dir: Absolute path to directory where SACK should
               be downloaded. Default value: "/tmp/EMIL_logs"
        :param chunk_size: The number of bytes that should be read into
               memory at a time during SACK downloading. Default value: 128
        """

        if not os.path.exists(tmp_dir):
            logger.debug("Creating temporary directory for downloading SACKS {}".format(tmp_dir))
            logger.console("Creating temporary directory for downloading SACKS {}".format(tmp_dir))
            os.system("mkdir -p {}".format(tmp_dir))

        url = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/{}/{" \
              "}/{}_ida.zip".format(release, sw_version, sw_version)
        r = requests.get(url, stream=True)
        if r.status_code == 200:
            logger.debug("File exists at {}. Starting download"
                         " to path {}/{}_ida.zip".format(url, tmp_dir, sw_version))
            with open(os.path.join(tmp_dir, "{}_ida.zip".format(sw_version)), 'wb') as fd:
                for chunk in r.iter_content(chunk_size=chunk_size):
                    fd.write(chunk)

            branch, version = sw_version.split("_", 1)
            logger.debug("After split: branch={}, version={}".format(branch, version))
            version = version.replace("ENB_", "")
            logger.debug("After removing 'ENB_' string: branch={}, version={}".format(branch, version))
            sack_dir_name = "{}_IDA_{}".format(branch, version)

            with zipfile.ZipFile(os.path.join(tmp_dir, "{}_ida.zip".format(sw_version)), 'r') as zip_ref:
                zip_files = zip_ref.namelist()
                paths_with_sw_ver = [x for x in zip_files if re.search(".*{}/$".format(version), x)]
                logger.debug(paths_with_sw_ver)
                extract_dir = os.path.join(tmp_dir, sack_dir_name)\
                    if len(paths_with_sw_ver) == 0 else tmp_dir
                logger.debug(extract_dir)
                zip_ref.extractall(extract_dir)
            logger.console("Copying SACKs from {} to {}".format(
                os.path.join(tmp_dir, sack_dir_name), os.path.join(destination_dir, sack_dir_name))
            )
            os.system("sudo scp -r {} {}".format(os.path.join(tmp_dir, sack_dir_name),
                                                 os.path.join(destination_dir, sack_dir_name)
                                                 )
                      )
        else:
            logger.debug("File not found at {}".format(url))
            logger.debug(r.status_code)
            raise Exception("IDA File not found at URL: {}".format(url))

    @staticmethod
    def copy_emil_logs_to_windows(log_dir_path, destination_directory, pc_ip, ssh_username, ssh_password):

        """
        Searches for all EMIL logs and copies them to Windows remote host.

        :param log_dir_path: Absolute path to directory where all EMIL logs
               can be found on local VM, e.g. "/home/ute/Downloads/test"
        :param destination_directory: Absolute path to directory on Windows
               remote host where EMIL aaTraces will be copied,
               e.g. "C:/temp/EMIL_logs"
        :param pc_ip: IP of Windows remote host
        :param ssh_username: Username for Windows remote host
        :param ssh_password: Password for Windows remote host

        """

        file_paths = [
            os.path.join(root, file_name)
            for root, dirs, files in os.walk(log_dir_path)
            for file_name in files if file_name.endswith('.emil')
        ]

        logger.debug("\nfile_paths={}".format(file_paths))

        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        logger.debug("Set missing key policy")
        ssh_client.connect(hostname=pc_ip, username=ssh_username, password=ssh_password)
        logger.debug("Connected to SSH")
        ftp_client = ssh_client.open_sftp()

        # check if directory exists and create new one if not
        try:
            ftp_client.stat(destination_directory)  # Test if remote_path exists
        except IOError:
            ftp_client.mkdir(destination_directory)  # Create remote_path
            ftp_client.stat(destination_directory)

        new_file_paths = []
        for file_path in file_paths:
            file_name = os.path.basename(file_path)
            destination_path = os.path.join(destination_directory, file_name)
            logger.debug("Sending file {} to {}".format(file_path, destination_path))
            ftp_client.put(file_path, destination_path)
            new_file_paths.append(destination_path)

        ftp_client.close()
        return new_file_paths

    @staticmethod
    def copy_lcbin_files_to_windows(log_dir_path, destination_directory, pc_ip, ssh_username, ssh_password):

        """
        Searches for all EMIL logs and copies them to Windows remote host.

        :param log_dir_path: Absolute path to directory where all EMIL logs
               can be found on local VM, e.g. "/home/ute/Downloads/test"
        :param destination_directory: Absolute path to directory on Windows
               remote host where EMIL aaTraces will be copied,
               e.g. "C:/temp/EMIL_logs"
        :param pc_ip: IP of Windows remote host
        :param ssh_username: Username for Windows remote host
        :param ssh_password: Password for Windows remote host
        """

        file_paths = [
            os.path.join(root, file_name)
            for root, dirs, files in os.walk(log_dir_path)
            for file_name in files if file_name.endswith('.lcbin')
        ]

        logger.debug("\nfile_paths={}".format(file_paths))

        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        logger.debug("Set missing key policy")
        ssh_client.connect(hostname=pc_ip, username=ssh_username, password=ssh_password)
        logger.debug("Connected to SSH")
        ftp_client = ssh_client.open_sftp()

        # check if directory exists and create new one if not
        try:
            ftp_client.stat(destination_directory)  # Test if remote_path exists
        except IOError:
            ftp_client.mkdir(destination_directory)  # Create remote_path
            ftp_client.stat(destination_directory)

        new_file_paths = []
        for file_path in file_paths:
            file_name = os.path.basename(file_path)
            destination_path = os.path.join(destination_directory, file_name)
            logger.debug("Sending file {} to {}".format(file_path, destination_path))
            ftp_client.put(file_path, destination_path)
            new_file_paths.append(destination_path)

        ftp_client.close()
        return new_file_paths

    @staticmethod
    def search_for_causes_of_ue_context_release_command(csv_file_path, cause_group, cause_list):

        """
        Searches CSV file for UEContextReleaseCommand messages with cause group
        and cause specified by user.

        :param csv_file_path: Absolute path to CSV file with messages,
               e.g. "/home/ute/Downloads/test"
        :param cause_group: Cause group for UEContextReleaseCommand
               message, e.g. "C:/temp/EMIL_logs"
        :param cause_list: List of causes, e.g.
               [radio-connection-with-ue-lost, radio-resources-not-available]
        :return Boolean value defining if any of causes from cause_list
                and specified cause_group were found. True if any were found
                and False otherwise.
        """

        messages_found = False
        data = []
        with open(csv_file_path) as csvfile:
            reader = csv.reader(csvfile)
            logger.debug(reader)

            maxint = sys.maxsize
            while True:
                # decrease the maxInt value by factor 10
                # as long as the OverflowError occurs.

                try:
                    logger.debug("New field size={}".format(maxint))
                    csv.field_size_limit(maxint)
                    break
                except OverflowError:
                    logger.debug("Field size caused OverflowError. "
                                 "Decreasing field size (int(maxint / 10)).")
                    maxint = int(maxint / 10)
                    if maxint == 0:
                        raise Exception("Field size reached 0.")

            for row in reader:
                data.append(row)
                if "UEContextReleaseCommand" in row:
                    logger.debug(row)
                    logger.debug(row[8])
                    m = re.search('value [Cc]ause.*', row[8])
                    if m:
                        logger.debug(m.group())
                        for cause in cause_list:
                            logger.debug("Checking cause_group={}\n"
                                         "cause={}".format(cause_group, cause))
                            cause_match = re.search('{}.*{}'.format(cause_group, cause), m.group())
                            if cause_match:
                                logger.console("\nMatch found for regular expression: "
                                               "'{}.*{}'".format(cause_group, cause))
                                logger.debug("Match found for regular expression: "
                                             "'{}.*{}'".format(cause_group, cause))
                                logger.debug(cause_match.group())
                                messages_found = True
                            else:
                                logger.debug("No messages found "
                                             "for regular expression: "
                                             "'{}.*{}'".format(cause_group, cause))
                    else:
                        logger.debug('No match found')
                        raise Exception("Match for regular expression: 'value [Cc]ause.*'"
                                        "was not found inside string containing "
                                        "'UEContextReleaseCommand'")
        csvfile.close()
        return messages_found

    @staticmethod
    def extract_logs(file_name, extract_dir="/tmp/dcap_unzipped"):

        """
        Extracts logs to specified directory.

        :param file_name: Name of the ZIP archive.
        :param extract_dir: Absolute path to directory where ZIP logs
               will be extracted. Default value: "/tmp/dcap_unzipped"
        """

        with zipfile.ZipFile(file_name, 'r') as zip_ref:
            zip_ref.extractall(extract_dir)
        logger.console('Logs unzipped to: {}'.format(extract_dir))
        logger.debug('Logs unzipped to: {}'.format(extract_dir))

    def search_and_count_transmission_mode_changes(self, csv_files_paths, merged_file_path,
                                                   start_date_time, end_date_time):

        """
        Searches CSV file for rrcConnectionReconfiguration messages with
        '((transmissionMode-r10 tm4)|(transmissionMode-r10 tm9-v1020)),'
        and counts changes from TM4 to TM9 and from TM9 to TM4 in time frame
        specified by user.

        :param csv_files_paths: List of absolute paths to CSV files with messages,
               e.g. ["/home/ute/Downloads/test/file1.csv", "/home/ute/Downloads/test/file2.csv"]
        :param merged_file_path: Absolute path to location where merged
               CSV file should be saved, e.g. "/home/ute/Downloads/test/merged.csv"
        :param start_date_time: Start of time frame for counting changes
               between transmission modes in format %Y-%m-%d %H:%M:%S.%f,
               e.g. "2023-06-30 18:09:00.000"
        :param end_date_time: End of time frame for counting changes
               between transmission modes in format %Y-%m-%d %H:%M:%S.%f,
               e.g. "2023-06-30 18:12:00.000"
        :return Tuple with number of changes from TM4 to TM9 as first element,
               number of changes from TM9 to TM4 as second element
               and boolean value determining if "UEContextReleaseComplete"
               appeared inside time range defined by user.
               If there was no data in log file (only one row inside file)
               this method will return (None, None, False) instead.
        """

        start_date_time_obj = datetime.strptime(start_date_time, "%Y-%m-%d %H:%M:%S.%f")
        end_date_time_obj = datetime.strptime(end_date_time, "%Y-%m-%d %H:%M:%S.%f")
        logger.console("\nTime constraints: {} - {}".format(start_date_time_obj, end_date_time_obj))
        logger.debug("\nTime constraints: {} - {}".format(start_date_time_obj, end_date_time_obj))
        count_all_changes_in_range = (0, 0)

        self._merge_multiple_files_into_one(csv_files_paths, merged_file_path)
        with open(merged_file_path) as csvfile:
            reader = csv.reader(csvfile)
            logger.debug(reader)

            maxint = sys.maxsize
            while True:
                # decrease the maxInt value by factor 10
                # as long as the OverflowError occurs.

                try:
                    logger.debug("New field size={}".format(maxint))
                    csv.field_size_limit(maxint)
                    break
                except OverflowError:
                    logger.debug("Field size caused OverflowError. "
                                 "Decreasing field size (int(maxint / 10)).")
                    maxint = int(maxint / 10)
                    if maxint == 0:
                        raise Exception("Field size reached 0.")

            tm_list = []              # List for TM changes in specified time range
            all_tm_list = []          # List for all TM changes in connection
            full_all_tm_list = []     # List for all TM changes in all connections
            from_start = False        # Time for first TM reconfiguration was in specified time range from start
            index = 0                 # Counts number of rows. If there is only 1 row, the logs are empty.
            ue_release_inside_range = False    # UEContextReleaseComplete was found inside time range defined by user
            for row in reader:
                index = index + 1
                if "rrcConnectionReconfiguration" in row or "rrcConnectionSetup" in row:
                    new_trace = False
                    logger.debug("\nrow:\n{}".format(row))
                    logger.debug("\n\nrow[0]:\n{}\n\nrow[8]:\n{}".format(row[0], row[8]))

                    m = re.search('((transmissionMode-r10 tm4)|(transmissionMode tm4)'
                                  '|(transmissionMode-r10 tm9-v1020)),', row[8])
                    if m:       # if match is found
                        logger.debug(m.group())
                        all_tm_list.append(m.group())
                        full_all_tm_list.append(m.group())
                        logger.debug("\nall_tm_list={}".format(all_tm_list))
                        current_date_time_obj = datetime.strptime(row[0], "%Y-%m-%d %H:%M:%S.%f")
                        logger.debug("\nCurrent message time={}".format(current_date_time_obj))

                        if start_date_time_obj <= current_date_time_obj <= end_date_time_obj:
                            logger.debug('\nMessage time in time range specified by user.')
                            if 'tm_before' not in locals() and len(all_tm_list) > 1:
                                # set 'tm_before' (last TM value before time constraints) if it didn't exist
                                # and there was at least one before (it is not the first message with TM)
                                logger.debug("\nSaving last TM change before messages"
                                             " entered specified time range.")
                                tm_before = all_tm_list[-2]
                                logger.debug("\ntm_before={}".format(tm_before))
                            elif 'tm_before' not in locals() and len(all_tm_list) == 1:
                                # set 'tm_before' (last TM value before time constraints) to None if
                                # variable 'tm_before' didn't exist
                                # and there was no messages with TM before this one (it is the first message with TM)
                                logger.debug("\nSetting 'tm_before' to None.")
                                tm_before = None
                                from_start = True
                            else:
                                # Do nothing if 'tm_before' existed or for some reason
                                # len(all_tm_list) < 1 which should not happen if we are in this place in code
                                logger.debug("\n'tm_before' already set.")

                            tm_list.append(m.group())
                            logger.debug("\ntm_list={}".format(tm_list))
                        else:
                            logger.debug('\nMessage time outside of time range specified by user.')
                    else:
                        logger.debug("No match found in current row. Match for regular expression: "
                                     "'((transmissionMode-r10 tm4)|(transmissionMode-r10 tm9-v1020))"
                                     "|(transmissionMode tm4)' was not found inside string containing"
                                     " 'rrcConnectionReconfiguration' or 'rrcConnectionSetup'.")

                elif "Time,Message name,From,To,Interface,Protocol,Time diff,Message body" in row:
                    # This is the first line of each merged file. If it appears
                    # it means that this is a separate trace/call
                    # so it should be calculated separately. In case 2 calls are overlapping
                    # in time for some reason the values in time constraints defined by user
                    # will be added. This part also clears lists and deletes 'tm_before'.
                    tm_before_exists = 'tm_before' in locals()
                    if tm_before_exists:
                        count_changes_in_range = self._select_counting_method_for_tm_changes(
                            self, tm_list, tm_before_exists, from_start, index, tm_before)
                    else:
                        count_changes_in_range = self._select_counting_method_for_tm_changes(
                            self, tm_list, tm_before_exists, from_start, index)
                    count_all_changes_in_range = self._add_tuples(count_all_changes_in_range, count_changes_in_range)
                    all_tm_list = []
                    tm_list = []
                    new_trace = True
                    if tm_before_exists:
                        del tm_before

                elif "UEContextReleaseComplete" in row:
                    # If 'UEContextReleaseComplete' message appeared in time range defined by user
                    # 'ue_release_inside_range' variable will be set to True.
                    current_date_time_obj = datetime.strptime(row[0], "%Y-%m-%d %H:%M:%S.%f")
                    logger.debug("\nCurrent message time={}".format(current_date_time_obj))
                    if start_date_time_obj <= current_date_time_obj <= end_date_time_obj:
                        logger.debug("\n'UEContextReleaseComplete' appeared in time range"
                                     " defined by user.")
                        ue_release_inside_range = True

        tm_before_exists = 'tm_before' in locals()
        if tm_before_exists and not new_trace:
            # This part of code will be executed only if file did not end with line signifying new trace
            # ('Time,Message name,From,To,Interface,Protocol,Time diff,Message body'). Variable 'new_trace'
            # traces this status and is used here as part of the condition.
            # This part counts TM changes in the last trace.
            count_changes_in_range = self._select_counting_method_for_tm_changes(
                self, tm_list, tm_before_exists, from_start, index, tm_before)
            count_all_changes_in_range = self._add_tuples(count_all_changes_in_range, count_changes_in_range)
        elif not new_trace:
            count_changes_in_range = self._select_counting_method_for_tm_changes(
                self, tm_list, tm_before_exists, from_start, index)
            count_all_changes_in_range = self._add_tuples(count_all_changes_in_range, count_changes_in_range)
        else:
            logger.debug("\nDid not enter. Last 'rrcConnectionReconfiguration' message"
                         " appeared before last found 'Time,Message name,From,To,"
                         "Interface,Protocol,Time diff,Message body' line (no empty new"
                         " trace at the end of file). There were no additional"
                         " reconfiguration messages to check.")

        logger.debug("\nfull_all_tm_list={}".format(full_all_tm_list))
        logger.console("\nfull_all_tm_list={}".format(full_all_tm_list))

        csvfile.close()

        return count_all_changes_in_range[0], count_all_changes_in_range[1], ue_release_inside_range

    @staticmethod
    def _add_tuples(tuple1, tuple2):

        """
        Adds elements for two tuples.

        :param tuple1: First tuple, e.g. (1, 2)
        :param tuple2: Second tuple, e.g. (2, 7)
        :return Tuple with sum of respective elements of tuples passed as arguments.
        """

        return tuple(map(lambda i, j: i + j, tuple1, tuple2))

    @staticmethod
    def _select_counting_method_for_tm_changes(self, tm_list, tm_before_exists, from_start,
                                               index, tm_before=None):

        """
        Selects how transmission mode changes will be counted or what value will be returned
        based on multiple factors: was CSV file empty? Did any messages with TM changes
        exist before time range defined by user? Were there any changes at all?

        :param tm_list: List with all changes that should be counted.
        :param tm_before_exists: Boolean value defining if "tm_before" exists.
        :param from_start: Boolean value defining if time for first TM reconfiguration
               was in specified time range from start.
        :param index: Integer value representing how many loops were there before
               entering this method. It is used to determine if merged CSV is empty
               (has only headers).
        :param tm_before: String containing the last value of transmission mode
               before time range specified by user or None if there were
               no other values of transmission mode before.
               It should end with ",". Possible values:
               "transmissionMode-r10 tm9-v1020,",
               "transmissionMode-r10 tm4,",
               "transmissionMode tm4,", None.
        :return Tuple with number of changes from TM4 to TM9 as first element
               and number of changes from TM9 to TM4 as second element.
        """

        logger.debug("\nfrom_start={}".format(from_start))
        logger.debug("\ntm_list={}".format(tm_list))
        if tm_before_exists and not from_start:
            # Counts TM changes for defined time range if there were any TM messages in file
            # was outside of time constraints defined by user (specifically: before those constraints)
            count_changes_in_range = self._count_tm_changes(tm_list, tm_before)
        elif tm_before_exists and from_start:
            # Counts TM changes for defined time range if first TM message in file
            # was already in time constraints defined by user
            count_changes_in_range = self._count_tm_changes(tm_list)
        elif index > 1:
            # CSV file was not empty, but there were no changes during time period specified by user
            count_changes_in_range = (0, 0)
        else:
            # CSV file was empty
            count_changes_in_range = (None, None)
        logger.debug("\ncount_changes_in_range={}".format(count_changes_in_range))
        logger.console("\ncount_changes_in_range={}".format(count_changes_in_range))

        return count_changes_in_range

    @staticmethod
    def _merge_multiple_files_into_one(csv_files_paths, merged_file_path):

        """
        Merges multiple CSV files into one. It is important to note that headers
        of files are kept.

        :param csv_files_paths: List of absolute paths to CSV files with messages,
               e.g. ["/home/ute/Downloads/test/file1.csv", "/home/ute/Downloads/test/file2.csv"]
        :param merged_file_path: Absolute path to location where merged
               CSV file should be saved, e.g. "/home/ute/Downloads/test/merged.csv"
        """

        with open(merged_file_path, 'w') as outfile:
            # Iterate through file list
            for names in csv_files_paths:
                # Open each file in read mode
                with open(names) as infile:
                    # read the data from files and write it in merged.csv
                    outfile.write(infile.read())
                # Add '\n' to enter data of next file from next line
                outfile.write("\n")
        outfile.close()

    @staticmethod
    def _count_tm_changes(tm_list, tm_before=None):

        """
        Counts changes from TM4 to TM9 and from TM9 to TM4. It adds
        1 to counted changes for proper counter if tm_before has value
        different than first value on the tm_list (in other words if first
        element of tm_list should be counted as change it will be included).

        :param tm_list: List with all changes that should be counted.
        :param tm_before: String containing the last value of transmission mode
               before time range specified by user or None if there were
               no other values of transmission mode before.
               It should end with ",". Possible values:
               "transmissionMode-r10 tm9-v1020,",
               "transmissionMode-r10 tm4,",
               "transmissionMode tm4,", None.
        :return Tuple with number of changes from TM4 to TM9 as first element
               and number of changes from TM9 to TM4 as second element.
        """

        tm_str = ''.join(tm_list)
        count_4_to_9 = tm_str.count("transmissionMode-r10 tm4,"
                                    "transmissionMode-r10 tm9-v1020,"
                                    ) + tm_str.count("transmissionMode tm4,"
                                                     "transmissionMode-r10 tm9-v1020,")
        count_9_to_4 = tm_str.count("transmissionMode-r10 tm9-v1020,transmissionMode-r10 tm4,")
        logger.debug("\nCounter for changes from TM4 to TM9: {}."
                     "\nCounter for changes from TM9 to TM4: {}.".format(count_4_to_9, count_9_to_4))

        logger.debug("tm_before={}".format(tm_before))
        if (tm_before == "transmissionMode-r10 tm4," or tm_before == "transmissionMode tm4,")\
                and tm_list[0] == "transmissionMode-r10 tm9-v1020,":
            # if there was additional TM change before time range defined
            # by user changes counter will be increased
            # "transmissionMode tm4," appears in "rrcConnectionSetup" messages
            # while "transmissionMode-r10 tm4," and "transmissionMode-r10 tm9-v1020,"
            # appear in "rrcConnectionReconfiguration" messages.
            logger.debug("Incrementing counter for changes from TM4 to TM9.")
            count_4_to_9 = count_4_to_9 + 1
            logger.debug("Counter for changes from TM4 to TM9: {}.".format(count_4_to_9))
        elif tm_before == "transmissionMode-r10 tm9-v1020," and tm_list[0] == "transmissionMode-r10 tm4,":
            logger.debug("Incrementing counter for changes from TM9 to TM4.")
            count_9_to_4 = count_9_to_4 + 1
            logger.debug("Counter for changes from TM9 to TM4: {}.".format(count_9_to_4))

        logger.console("\nCounter for changes from TM4 to TM9: {}."
                       "\nCounter for changes from TM9 to TM4: {}.".format(count_4_to_9, count_9_to_4))
        return count_4_to_9, count_9_to_4

    def check_sip_messages(self, csv_files_paths, merged_file_path, sip_cseq_list=None):

        """
        Searches CSV file for SIP messages with 200 OK and CSeq elements defined
        in 'sip_cseq_list' parameter.
        It first checks for 'ITF_L2LOG_CU_HI_STREAMGTPUTRACEIND_ID' messages,
        then searches for all strings matching regexp:
        'SIP/.{0,4} 200 OK.+?CSeq: \\d+ [A-Za-z]+' after which it checks if each element
        from list 'sip_cseq_list' appeared in matched strings.

        :param csv_files_paths: List of absolute paths to CSV files with messages,
               e.g. ["/home/ute/Downloads/test/file1.csv", "/home/ute/Downloads/test/file2.csv"]
        :param merged_file_path: Absolute path to location where merged
               CSV file should be saved, e.g. "/home/ute/Downloads/test/merged.csv"
        :param sip_cseq_list: List with values which should appear in CSeq in SIP message.
               If value passed here is None it will be set to ["REGISTER", "SUBSCRIBE", "BYE"].
               Default value is None.
        :return Boolean value defining if expected SIP messages were found in file.
                True if all were found and False otherwise.
        """

        sip_cseq_list = ["REGISTER", "SUBSCRIBE", "BYE"] if sip_cseq_list is None else sip_cseq_list
        temp_sip_cseq_list = sip_cseq_list[:]
        if not temp_sip_cseq_list:
            raise Exception("'temp_sip_cseq_list' created from 'sip_cseq_list' is empty."
                            " Please check if 'sip_cseq_list' is not empty.")

        messages_found = False
        data = []
        full_message = ''
        self._merge_multiple_files_into_one(csv_files_paths, merged_file_path)
        with open(merged_file_path) as csvfile:
            reader = csv.reader(csvfile)
            logger.debug(reader)

            maxint = sys.maxsize
            while True:
                # decrease the maxInt value by factor 10
                # as long as the OverflowError occurs.

                try:
                    logger.debug("New field size={}".format(maxint))
                    csv.field_size_limit(maxint)
                    break
                except OverflowError:
                    logger.debug("Field size caused OverflowError. "
                                 "Decreasing field size (int(maxint / 10)).")
                    maxint = int(maxint / 10)
                    if maxint == 0:
                        raise Exception("Field size reached 0.")

            for row in reader:
                data.append(row)
                if "ITF_L2LOG_CU_HI_STREAMGTPUTRACEIND_ID" in row:
                    logger.debug(row)
                    logger.debug(row[3])
                    full_message += row[3]
            logger.debug('\n' * 5)
            logger.debug(full_message)
            logger.debug('\n' * 5)
            matches_list = re.findall(r"SIP/.{0,4} 200 OK.+?CSeq: \d+ [A-Za-z]+",
                                      full_message, flags=re.DOTALL)
            # .+? - lazy quantifier will find first CSeq: \d+ [A-Za-z]+ after SIP/.{0,4} 200 OK
            # flags=re.DOTALL - dot in regexp will also include new lines
            if matches_list:
                for m in matches_list:
                    logger.debug('\n------------------------------------------'
                                 '------------------------------------------\n')
                    logger.debug(m)
                    for cseq in sip_cseq_list:
                        cseq_regexp = 'CSeq: \\d+ ' + cseq + '$'
                        logger.debug("Checking CSeq={}\nRegexp: {}".format(cseq, cseq_regexp))
                        cseq_match = re.search('{}'.format(cseq_regexp), m)
                        if cseq_match:
                            logger.console("\nMatch found for regular expression: "
                                           "'{}'".format(cseq_regexp))
                            logger.debug("Match found for regular expression: "
                                         "'{}'".format(cseq_regexp))
                            logger.debug(cseq_match.group())

                            if cseq in temp_sip_cseq_list:
                                temp_sip_cseq_list.remove(cseq)
                                logger.debug("Current contents of 'temp_sip_cseq_list':"
                                             " {}".format(temp_sip_cseq_list))
                            else:
                                logger.debug("Value {} not found in list. "
                                             "Most likely more than one message"
                                             " has the same value".format(cseq))
                        else:
                            logger.debug("No messages found "
                                         "for regular expression: "
                                         "'{}'".format(cseq_regexp))
            else:
                logger.debug('No match found')
                raise Exception("Match for regular expression: 'SIP/.{0,4} 200 OK.+?CSeq: \\d+ [A-Za-z]+'"
                                "was not found inside string containing "
                                "'ITF_L2LOG_CU_HI_STREAMGTPUTRACEIND_ID'")
            messages_found = True if not temp_sip_cseq_list else False
        csvfile.close()
        return messages_found

    def extract_sacks_from_dcap(self, log_dir_path, destination_directory, dir_search_str="sacks"):

        """
        Searches for SACKS and extracts them. It returns path to unzipped directory.

        :param log_dir_path: Absolute path to directory where all DCAP logs
               can be found on local VM, e.g. "/home/ute/Downloads/test/dcap_unzipped"
        :param destination_directory: Absolute path to directory on Windows
               remote host where SACKS will be copied,
               e.g. "C:/Users/wrodss/Documents/EmilSacks/SBTS00_IDA_0000_001124_000000"
        :param dir_search_str: Directory name used during search for SACKS.
               This should be a parent folder that may have subdirectories,
               but files inside it and any subdirectories need to be SACK .zip files.
               Default value: "sacks"
        :return Absolute path to unzipped SACKS on local VM.
        """

        file_paths = [
            os.path.join(root, file_name)
            for root, dirs, files in os.walk(log_dir_path)
            for file_name in files if os.path.basename(os.path.normpath(root)) == dir_search_str
        ]

        logger.debug("\nfile_paths={}".format(file_paths))

        file_name = os.path.basename(file_paths[0])
        logger.debug("\nfile_name={}".format(file_name))
        sack_dir_name = os.path.basename(os.path.normpath(destination_directory))
        logger.debug("\nsack_dir_name={}".format(sack_dir_name))

        logger.debug("\nlog_dir_path={}".format(log_dir_path))
        unzipped_sack_path = os.path.join(log_dir_path, sack_dir_name)
        logger.debug("\nunzipped_sack_path={}".format(unzipped_sack_path))
        self.extract_logs(file_paths[0], unzipped_sack_path)

        return unzipped_sack_path
