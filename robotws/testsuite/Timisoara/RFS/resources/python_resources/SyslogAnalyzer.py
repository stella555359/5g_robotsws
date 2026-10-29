import shutil
import os
import datetime
import re
from taf.transport.ssh import ssh


class SyslogAnalyzer(object):
    """
    A class to analyze syslog files for specific error patterns and keywords.

    Searches for fatal errors, invalid memory references, and other
    critical issues within a specified time range.
    """

    # Default error patterns to search for
    DEFAULT_SEARCH_PATTERNS = [
        "FATAL DSPHWAPI ERROR",
        "-=-=",
        "Invalid memory reference",
        "Please contact the owner",
        "fatality",
        "Abort signal received",
        "Bus error",
        "Failed call of",
        "Could not create directory /var/log",
        "No such file or directory: '/var/log"
    ]

    def __init__(self):
        """Initialize the SyslogAnalyzer."""
        self.syslog_file = None
        self.syslog_file_local = None
        self.hostname = None
        self.port = None
        self.username = None
        self.password = None
        self.work_dir = None
        self.start_time = None
        self.end_time = None
        self.search_patterns = []
        self.matches = []
        self.ignored_patterns = []

    def setup_analyzer(self,
                       hostname=None,
                       port='22',
                       username='ute',
                       password='uteUTE!',
                       syslog_file=None,
                       work_dir=None,
                       start_time=None,
                       end_time=None,
                       additional_patterns=None,
                       ignored_patterns=None):
        """
        Setup the SyslogAnalyzer with configuration parameters.

        :param hostname: hostname/IP of the remote VM where Syslog is
                        located. If None, uses local file directly.
                        If IP address provided, the Syslog will be
                        downloaded to local VM via SSH
        :param port: SSH connection port in case of remote VM syslog
        :param username: SSH connection username in case of remote VM syslog
        :param password: SSH connection password in case of remote VM syslog
        :param syslog_file: Full path to the syslog file to analyze
        :param work_dir: Name of the local directory where syslog file
                        will be stored (required when hostname is provided)
        :param start_time: Optional start time for analysis.
                          Format 'YYYY-MM-DD HH:MM:SS'
                          If None, starts from the beginning of the file
        :param end_time: Optional end time for analysis.
                        Format 'YYYY-MM-DD HH:MM:SS'
                        If None, analyzes until the end of the file
        :param additional_patterns: Optional list of additional patterns
                                   to search for
        :param ignored_patterns: Optional list of patterns to
                                ignore/exclude from search
        """
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.syslog_file = syslog_file
        self.work_dir = work_dir
        self.start_time = start_time
        self.end_time = end_time
        self.search_patterns = self.DEFAULT_SEARCH_PATTERNS.copy()
        self.ignored_patterns = ignored_patterns
        self.matches = []

        # Add additional patterns if provided
        if additional_patterns:
            self.search_patterns.extend(additional_patterns)

    def _get_syslog_file(self):
        """Get the syslog file from local or remote VM."""
        if self.hostname is None:
            # Use the file directly without copying
            self.syslog_file_local = self.syslog_file
        else:
            # Remote VM - download the file
            time_now = datetime.datetime.today().strftime('%Y%m%d_%H_%M_%S')
            syslog_name = self.syslog_file.split("/")[-1]
            self.syslog_file_local = (
                '{}/syslog_analyzer_{}_{}'.format(
                    self.work_dir, syslog_name, time_now
                )
            )
            self.syslog_file_local = self.syslog_file_local.replace('//', '/')

            ssh_conn = ssh()
            try:
                ssh_conn.connect_to(self.hostname, self.username)
            except Exception as e:
                msg = ("Cannot open ssh connection in order to transfer "
                       "Syslog File! Error: {}".format(e))
                raise Exception(msg)
            if not ssh_conn.file_exists(self.syslog_file):
                msg = "Searched remote file {} does not exist!".format(
                    self.syslog_file
                )
                raise Exception(msg)
            try:
                ssh_conn.download_file(
                    self.syslog_file, self.syslog_file_local
                )
            except Exception as e:
                msg = "Could not transfer Syslog File! Error: {}".format(e)
                raise Exception(msg)
            ssh_conn.disconnect()

    def _exclude_ignored_patterns(self, list_of_tuple_errors):
        filtered_tuple_list = list_of_tuple_errors.copy()
        for pattern in self.ignored_patterns:
            for match_tuple in list_of_tuple_errors:
                try:
                    if pattern in match_tuple[1]:
                        filtered_tuple_list.remove(match_tuple)
                except (IndexError, ValueError):
                    continue
        return list(set(filtered_tuple_list))

    def _format_found_errors(self, list_of_tuple_errors):
        unique_messages = []
        for pattern in self.search_patterns:
            for error in list_of_tuple_errors:
                try:
                    message = error[1]
                    if pattern in message:
                        timestamp = re.findall(r".*(<\d+-\d+-\d+T\d+:\d+:\d+\.\d+Z>).*", message)
                        error_cleaned = message.split(timestamp[0])
                        unique_messages.append(error_cleaned[1])
                        break
                except (IndexError, ValueError):
                    continue
        return unique_messages

    def analyze(self):
        """
        Analyze the syslog file for matching patterns.

        :return: List of tuples (timestamp, message) for each matched line
        """
        self._get_syslog_file()
        self.matches = []
        date_regex = r".*<(\d+-\d+-\d+T\d+:\d+:\d+).*"

        # Parse start and end times if provided
        datetime_start = None
        datetime_end = None

        if self.start_time:
            try:
                datetime_start = datetime.datetime.strptime(
                    self.start_time, '%Y-%m-%d %H:%M:%S'
                )
            except ValueError:
                msg = ("Invalid start_time format: {}. Expected "
                       "'YYYY-MM-DD HH:MM:SS'".format(self.start_time))
                raise ValueError(msg)

        if self.end_time:
            try:
                datetime_end = datetime.datetime.strptime(
                    self.end_time, '%Y-%m-%d %H:%M:%S'
                )
            except ValueError:
                msg = ("Invalid end_time format: {}. Expected "
                       "'YYYY-MM-DD HH:MM:SS'".format(self.end_time))
                raise ValueError(msg)

        try:
            with open(self.syslog_file_local, 'r',
                      encoding='utf-8', errors='replace') as file_r:
                line_number = 0
                while line := file_r.readline():
                    line_number += 1
                    line = line.rstrip()

                    # Extract timestamp from line
                    timestamp_match = re.findall(date_regex, line)
                    if len(timestamp_match) > 0:
                        timestamp = timestamp_match[0]
                        timestamp = timestamp.replace('T', ' ')

                        try:
                            datetime_line = datetime.datetime.strptime(
                                timestamp, '%Y-%m-%d %H:%M:%S'
                            )
                        except ValueError:
                            datetime_line = None

                        # Check time boundaries
                        if datetime_line:
                            if datetime_start and datetime_line < datetime_start:
                                continue

                            if datetime_end and datetime_line > datetime_end:
                                break
                    else:
                        timestamp = None
                        datetime_line = None

                    # Check if line matches any search pattern
                    for pattern in self.search_patterns:
                        if pattern in line:
                            match_tuple = (
                                timestamp if timestamp else 'N/A', line
                            )
                            self.matches.append(match_tuple)
                            break
        except FileNotFoundError:
            msg = "File {} not found".format(self.syslog_file_local)
            raise Exception(msg)
        except OSError:
            msg = "OS error occurred trying to open {}".format(
                self.syslog_file_local
            )
            raise Exception(msg)
        except Exception:
            msg = "Unexpected error opening {}".format(self.syslog_file_local)
            raise Exception(msg)
        finally:
            # Remove downloaded file if it was from remote VM
            if (self.hostname is not None and self.syslog_file_local and
                    os.path.exists(self.syslog_file_local)):
                try:
                    os.remove(self.syslog_file_local)
                except Exception:
                    pass  # Ignore errors during cleanup

        # Remove ignored patterns if provided
        if self.ignored_patterns:
            self.matches = self._exclude_ignored_patterns(self.matches)

        # Format errors for user logging to console
        simplified_unique_messages = self._format_found_errors(self.matches)

        return self.matches, simplified_unique_messages
