# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Contacts: renhui-david.liu@nokia-sbell.com
Description: this script is used to find and download right files from a remote linux server.
"""

import os
import math
import time
from taf.transport.ssh import ssh
from datetime import datetime as dt
from datetime import timedelta


class RemoteFileDownloader(object):
    """
    To download files from a remote linux server.
    """
    ssh_manager = ssh()

    def concatenate_directory_parts(self, dir_prefix, dir_parts):
        dirs = []
        for part in dir_parts:
            dirs.append(os.path.join(dir_prefix, part))
        return dirs

    @classmethod
    def download_remote_file(cls, connection, local_file_path, remote_file_path):
        """
        *Usage:*
            - used to download a remote file.
        *Args:*
            - connection: an alias for ssh connection
            - local_file_path: the path to a local file
            - remote_file_path: the path to a remote file
        *Returns:*
            - local_file_path: the path to a local file
        *Example:*
            - download_remote_file()
        """
        cls.ssh_manager.download_file(remote_path=remote_file_path, local_path=local_file_path, connection=connection)
        return local_file_path

    @classmethod
    def compress_remote_files(cls, connection, remote_files_path, timeout=300):
        """
        *Usage:*
            - used to compress one or multiple files in a remote linux server.
        *Args:*
            - remote_files_path: type list
        """
        directory = os.path.dirname(remote_files_path[0])
        now = dt.now()
        timestamp = now.strftime("%Y%m%d%H%M%S")
        compressed = "compressed_file_{}.tar.gz".format(timestamp)
        compressed_file_path = os.path.join(directory, compressed)
        cmd_front = "cd {}; tar -czvf {}".format(directory, compressed)
        cmd = cmd_front + " " + " ".join(remote_files_path)
        cls.ssh_manager.send_command(cmd, connection=connection, timeout=timeout)
        output = cls.ssh_manager.read_output(connection=connection).strip()
        print("compress_remote_files:\n", output)
        return compressed_file_path

    def decompress_local_file(self, local_file_path):
        """
        *Usage:*
            - used to decompress a compressed file.
        """
        directory = os.path.dirname(local_file_path)
        cmd = "cd {}; tar -xzvf {}".format(directory, local_file_path)
        self.run_local_command(cmd)

    @classmethod
    def remove_remote_file(cls, connection, remote_file):
        """
        *Usage:*
            - used to remove a remote file.
        *Args:*
            - connection: an alias for ssh connection
            - remote_file: the path to a remote file
        """
        cmd = "rm -rf {}".format(remote_file)
        cls.ssh_manager.execute(command=cmd, connection=connection)

    @staticmethod
    def run_local_command(command):
        """
        *Usage:*
            - used to run a linux command locally.
        *Args:*
            - command: a linux command
        """
        import subprocess
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        print("stdout:\n", stdout.decode())
        if stderr:
            print("stderr:\n", stderr.decode())

    @classmethod
    def remote_directory_exists(cls, connection, remote_directory, timeout=60):
        """
        *Usage:*
            - used to check if a directory exists in a remote linux server.
        *Returns:*
            - bool type
        """
        cmd = "[ -d '{}' ] && echo 'Directory exists' || echo 'Directory does not exist'".format(remote_directory)
        cls.ssh_manager.send_command(cmd, connection=connection, timeout=timeout)
        output = cls.ssh_manager.read_output(connection=connection).strip()
        if output == "Directory exists":
            return True
        else:
            return False


class TimedRemoteFileDownloader(RemoteFileDownloader):
    """
    To download remote files inside two-level directory, like 20240206/0000, 20240206/0015 ... 20240206/2345.
    """

    def __init__(self, first_level="%Y%m%d", second_level="%H%M", date_time_format="%Y%m%d%H%M%S", minute_interval=15):
        self.dir_gen = TimedDirectoryGenerator(first_level, second_level)
        self.date_time_format = date_time_format
        self.minute_interval = minute_interval

    def get_remote_server_datetime(self, connection):
        """
        *Usage:*
            - Keyword
            - This keyword is used to get a remote server's current datetime.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        """
        cmd = "date +{}".format(self.date_time_format)
        string = self.ssh_manager.execute(command=cmd, connection=connection).strip()
        date_time = dt.strptime(string, self.date_time_format)
        return date_time

    def get_remote_server_rounded_datetime(self, connection):
        """
        *Usage:*
            - Keyword
            - This keyword is used to get a remote server's rounded datetime based on current datetime.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        """
        date_time = self.get_remote_server_datetime(connection)
        replaced_date_time = TimedDirectoryGenerator.replace_flooring_minute(date_time, self.minute_interval)
        rounded_date_time = TimedDirectoryGenerator.reset_second(replaced_date_time)
        return rounded_date_time

    def calculate_waiting_time(self, connection, log_collection_end_time):
        """
        *Usage:*
            - Keyword
            - This keyword is used to calculate the waiting time for target files from a remote server.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
            - log_collection_end_time: the end time of log collection
        """
        expected = TimedDirectoryGenerator.calculate_datetime_with_rounded_minute(log_collection_end_time,
                                                                                  self.minute_interval)
        current = self.get_remote_server_datetime(connection)
        time_delta = expected - current
        return math.ceil(time_delta.total_seconds())

    def are_remote_files_ready(self, connection, log_collection_end_time):
        """
        *Usage:*
            - Keyword
            - This keyword is used to check if remote files are ready to download.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - log_collection_end_time: the end time of log collection
        """
        waiting_seconds = self.calculate_waiting_time(connection, log_collection_end_time)
        if waiting_seconds > 0:
            is_ready = False
        else:
            is_ready = True
        return is_ready

    def download_timed_remote_files(self, connection, local_dir, remote_dir, filename_pattern, log_collection_end_time,
                                    interval_num=2, timeout=600):
        """
        *Usage:*
            - used to download timed remote files from a remote server. It requires the files are ready to download.
        *Args:*
            - connection: an alias for ssh connection
            - local_dir: local directory to store downloaded files
            - remote_dir: the directory in a remote linux server to download right files
            - filename_pattern: the patter to find right files
            - log_collection_end_time: datetime.datetime type, the end time of log collection
            - interval_num: the number of minute intervals to capture logs backwards from log_collection_end_time
        """
        is_ready = self.are_remote_files_ready(connection, log_collection_end_time)
        if not is_ready:
            raise Exception("The timed remote files are not ready to download")

        remote_files = self.find_timed_remote_files_path(connection, remote_dir, filename_pattern,
                                                         log_collection_end_time, interval_num)
        remote_compressed_file = self.compress_remote_files(connection, remote_files, timeout=timeout)
        local_compressed_file = os.path.join(local_dir, os.path.basename(remote_compressed_file))
        self.download_remote_file(connection, local_compressed_file, remote_compressed_file)
        self.decompress_local_file(local_compressed_file)
        self.remove_remote_file(connection, remote_compressed_file)
        timed_local_files = [os.path.join(local_dir, remote_file.lstrip('/')) for remote_file in remote_files]
        return timed_local_files

    def wait_and_download_timed_remote_files(self, connection, local_dir, remote_dir, filename_pattern,
                                             log_collection_end_time,
                                             interval_num=2, extra_wait=30, timeout=600):
        """
        *Usage:*
            - Keyword
            - This keyword is used to download timed remote files from a remote server.
            - It checks if the files are ready.
            - If not ready, it will calculate the waiting time and
            - wait for the calculated waiting time plus extra_wait time.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
            - local_dir: local directory to store downloaded files
            - remote_dir: the directory in a remote linux server to download right files
            - filename_pattern: the patter to find right files
            - log_collection_end_time: datetime.datetime type, the end time of log collection
            - interval_num: the number of minute intervals to capture logs backwards from log_collection_end_time
            - extra_wait: in seconds
        """
        is_ready = self.are_remote_files_ready(connection, log_collection_end_time)
        if not is_ready:
            waiting_time = self.calculate_waiting_time(connection, log_collection_end_time)
            print("Sleeping {} seconds ... until the timed logs are ready".format(waiting_time))
            time.sleep(waiting_time + extra_wait)

        timed_local_files = self.download_timed_remote_files(connection, local_dir, remote_dir, filename_pattern,
                                                             log_collection_end_time,
                                                             interval_num=interval_num, timeout=timeout)
        return timed_local_files

    def find_timed_remote_files_path(self, connection, remote_dir, filename_pattern, log_collection_end_time,
                                     interval_num):
        """
        *Usage:*
            - Keyword
            - This keyword is used to find timed file paths from a remote server.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        """
        file_paths = []
        remote_full_dirs = self.generate_timed_remote_directory(remote_dir, log_collection_end_time, interval_num)
        for dir in remote_full_dirs:
            if not TimedRemoteFileDownloader.remote_directory_exists(connection, dir):
                exception = "The remote directory {} does not exist".format(dir)
                raise Exception(exception)
            cmd = "find {} -maxdepth 1 -type f -name '{}'".format(dir, filename_pattern)
            self.ssh_manager.send_command(cmd, connection=connection, timeout=60)
            lines = self.ssh_manager.read_output(connection=connection)
            paths = lines.strip().splitlines()
            if paths:
                file_paths.extend(paths)
            else:
                exception = "The remote directory {} does not have target files now".format(dir)
                raise Exception(exception)
        return file_paths

    def generate_timed_remote_directory(self, remote_dir, log_collection_end_time, interval_num):
        """
        *Usage:*
            - Keyword
            - This keyword is used to generate timed directories for a remote server.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        """
        dir_parts = self.dir_gen.generate_directory(log_collection_end_time, interval_num, self.minute_interval)
        return self.concatenate_directory_parts(remote_dir, dir_parts)

    def tce_action(self, connection, tce_action, oam_ip, sudo_password):
        """
        *Usage:*
            - used to connect and disconnection network from gnb to dcap.
        *Args:*
            - connection: an alias for ssh connection
            - tce_action: -I is disconnection and -D is connection
            - oam_ip: gnb oam ip
        """
        cmd = "echo '{}' |sudo -S iptables {} INPUT -s {} -j DROP ".format(sudo_password, tce_action, oam_ip)
        self.ssh_manager.send_command(cmd, connection=connection)
        output = self.ssh_manager.read_output(connection=connection).strip()
        print("The tce action result:\n", output)
        return cmd


class TimedDirectoryGenerator(object):
    """
    generates directories with a specific time-based structure
    """

    def __init__(self, first_level, second_level):
        self.first_level = first_level
        self.second_level = second_level

    def generate_directory(self, date_time, interval_num, minute_interval):
        """
        *Usage:*
            - used to generate directories with a specific time-based structure.
        *Args:*
            - date_time: the end time
            - interval_num: the number of minute intervals
        """
        dirs = []
        replaced_date_time = TimedDirectoryGenerator.replace_ceiling_minute(date_time, minute_interval)
        for index in range(interval_num):
            if index != 0:
                replaced_date_time -= timedelta(minutes=minute_interval)
            dirs.append(os.path.join(replaced_date_time.strftime(self.first_level),
                                     replaced_date_time.strftime(self.second_level)))
        return dirs

    @staticmethod
    def calculate_datetime_with_rounded_minute(date_time, minute_interval):
        """
        *Usage:*
            - used to calculate a rounded datetime.
        """
        replaced_date_time = TimedDirectoryGenerator.replace_ceiling_minute(date_time, minute_interval)
        return TimedDirectoryGenerator.reset_second(replaced_date_time)

    @staticmethod
    def ceil_minute(date_time, minute_interval):
        """
        *Usage:*
            - used to round a minute UP to the nearest minute interval.
        *Args:*
            - date_time: datetime.datetime type, the end time
        *Returns:*
            - return a rounded minute
        """
        if minute_interval <= 0:
            raise ValueError("minute_interval must be positive and non-zero.")
        minute = date_time.minute
        second = date_time.second
        m = minute + second / 60
        return math.ceil(m / minute_interval) * minute_interval

    @staticmethod
    def floor_minute(date_time, minute_interval):
        """
        *Usage:*
            - used to round a minute DOWN to the nearest minute interval.
        *Args:*
            - date_time: datetime.datetime type, the end time
        *Returns:*
            - return a rounded minute
        """
        if minute_interval <= 0:
            raise ValueError("minute_interval must be positive and non-zero.")
        minute = date_time.minute
        second = date_time.second
        m = minute + second / 60
        return math.floor(m / minute_interval) * minute_interval

    @staticmethod
    def reset_minute(date_time):
        """
        *Usage:*
            - used to set the minute in date_time to zero.
        *Args:*
            - date_time: datetime.datetime type, the end time
        *Returns:*
            - datetime.datetime type
        """
        return date_time.replace(minute=0)

    @staticmethod
    def reset_second(date_time):
        """
        *Usage:*
            - used to set the second in date_time to zero.
        *Returns:*
            - datetime.datetime type
        """
        return date_time.replace(second=0)

    @staticmethod
    def replace_ceiling_minute(date_time, minute_interval):
        """
        *Usage:*
            - used to replace date_time with ceiling minutes.
        """
        minutes = TimedDirectoryGenerator.ceil_minute(date_time, minute_interval)
        replaced_date_time = TimedDirectoryGenerator.reset_minute(date_time)
        replaced_date_time += timedelta(minutes=minutes)
        return replaced_date_time

    @staticmethod
    def replace_flooring_minute(date_time, minute_interval):
        """
        *Usage:*
            - used to replace date_time with flooring minutes.
        """
        minutes = TimedDirectoryGenerator.floor_minute(date_time, minute_interval)
        replaced_date_time = TimedDirectoryGenerator.reset_minute(date_time)
        replaced_date_time += timedelta(minutes=minutes)
        return replaced_date_time


def convert_to_cross_platform_filename(filename, new_value='-'):
    """
    *Usage:*
        - used to convert a filename to a cross-platform compatible filename. Linux and Windows have some different
        - naming rules.
    """
    dir = os.path.dirname(filename)
    base_name = os.path.basename(filename)
    name = base_name.replace(':', new_value)
    return os.path.join(dir, name)
