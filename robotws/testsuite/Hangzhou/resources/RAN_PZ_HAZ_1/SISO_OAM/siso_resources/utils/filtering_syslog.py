import datetime
import os
import re
import time
import glob
import logging
import paramiko
from threading import Thread
from traceback import format_exc
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.aliasing import aliasing_scope


builtin = BuiltIn()


def robot_var(variable_name):
    return builtin.get_variable_value("${{{}}}".format(variable_name))


class ExcThread(Thread):
    def __init__(self, target, args=(), kwargs=None):
        super(ExcThread, self).__init__()
        if kwargs is None:
            kwargs = {}
        self.function = target
        self.args = args
        self.kwargs = kwargs
        self.exit_code = 0
        self.exception = None
        self.exe_traceback = ""

    def run(self):
        try:
            self._run()
        except Exception as e:
            self.exit_code = 1
            self.exception = e
            self.exe_traceback = format_exc

    def _run(self):
        try:
            self.function(*self.args, **self.kwargs)
        except Exception as e:
            raise e


class LocalFile(object):
    def __init__(self):
        self.stop_flag = False

    def stop_read_file(self):
        self.stop_flag = True

    @staticmethod
    def _get_new_syslog_file(log_path="/tmp/btslog2"):
        syslogs = glob.glob("{}/SYSLOG_*.LOG".format(log_path))
        if not syslogs:
            raise Exception("no syslog in path({})".format(log_path))
        syslogs.sort(key=lambda fn: os.path.getmtime(fn))
        return syslogs[-1]

    def read_file(self):
        path = self._get_new_syslog_file()
        f = open(path, "r")
        f.seek(0, 2)
        while True:
            if self.stop_flag:
                break

            curr_position = f.tell()
            line = f.readline()
            if line == "":
                time.sleep(0.1)
                line = f.readline()
            if line == "":
                path2 = self._get_new_syslog_file()
                if path2 != path:
                    f.close()
                    path = path2
                    f = open(path, "r")
                    f.seek(0, 1)
            elif not line.endswith("\n"):
                f.seek(curr_position)
            else:
                yield line
        try:
            f.close()
        except Exception:
            print("file handler has been closed")


class RemoteFile(object):
    def __init__(self, host, username, password):
        self.stop_flag = False
        self.host = host
        self.username = username
        self.password = password
        self.ssh = None
        self.sftp = None
        self.connect()

    def stop_read_file(self):
        self.stop_flag = True

    def connect(self):
        try:
            self.ssh = paramiko.SSHClient()
            self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.ssh.connect(self.host, username=self.username, password=self.password)
            transport = self.ssh.get_transport()
            self.sftp = paramiko.SFTPClient.from_transport(transport)
        except Exception as e:
            raise e

    def _get_new_syslog_file(self, log_path="/tmp/btslog2"):
        syslogs = self.sftp.listdir(log_path)
        syslogs = [os.path.join(log_path, syslog) for syslog in syslogs if re.match(r"SYSLOG_(\d+).LOG", syslog)]
        if not syslogs:
            raise Exception("no syslog in path({})".format(log_path))
        syslogs.sort(key=lambda fn: re.match(r"{}/SYSLOG_(\d+).LOG".format(log_path), fn).group(1))
        return syslogs[-1]

    def read_file(self):
        path = self._get_new_syslog_file()
        f = self.sftp.open(path, "r")
        f.seek(0, 2)
        while True:
            if self.stop_flag:
                break

            curr_position = f.tell()
            line = f.readline()
            if line == "":
                time.sleep(0.1)
                line = f.readline()
            if line == "":
                path2 = self._get_new_syslog_file()
                if path2 != path:
                    f.close()
                    path = path2
                    f = self.sftp.open(path, "r")
                    f.seek(0, 1)
            elif not line.endswith("\n"):
                f.seek(curr_position)
            else:
                yield line
        try:
            f.close()
        except Exception:
            print("file handler has been closed")

    def close(self):
        if hasattr(self.sftp, "close") and callable(self.sftp.close):
            self.sftp.close()
        if hasattr(self.ssh, "close") and callable(self.ssh.close):
            self.ssh.close()


class FilteringSyslogRealtime(object):

    def __init__(self, logfile="", host=None, username="ute", password="ute"):
        self.filtered_log = ""
        self.filter = ""
        self.thread = None
        if host is None:
            self.file = LocalFile()
        else:
            self.file = RemoteFile(host, username, password)
        self.logger = ""
        if logfile:
            self.logger = self._get_logger(logfile)

    @staticmethod
    def _get_logger(logfile):
        now_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        logger = logging.getLogger("logger_{}".format(now_time))
        logger.setLevel(level=logging.DEBUG)

        handler = logging.FileHandler(logfile, mode='w')
        formatter = logging.Formatter("%(message)s")
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        return logger

    def filter_syslog(self):
        for line in self.file.read_file():
            if re.search(self.filter, line):
                self.filtered_log += line
                if self.logger:
                    self.logger.info(line.strip("\n"))

    def start_filter_log(self, filter):
        self.filter = filter
        self.thread = ExcThread(target=self.filter_syslog)
        self.thread.setDaemon(True)
        self.thread.start()
        time.sleep(1)

    def stop_filter_log(self):
        self.file.stop_read_file()
        while self.thread.is_alive():
            time.sleep(0.1)
        if hasattr(self.file, "close") and callable(self.file.close):
            self.file.close()

    def get_filtered_log(self):
        if self.thread.exit_code != 0:
            raise self.thread.exception
        return self.filtered_log

    def clear_filtered_log(self):
        self.filtered_log = ""

    def change_filter_value(self, filter):
        self.filter = filter
        self.filtered_log = ""

    def wait_for_filtered_log(self, timeout):
        timeout = int(timeout)
        while timeout >= 0:
            if self.thread.exit_code != 0:
                raise self.thread.exception
            if self.filtered_log:
                log = self.filtered_log
                self.clear_filtered_log()
                return log
            time.sleep(1)
            timeout -= 1
        raise Exception("filter({}) log do not find!".format(self.filter))


class filtering_syslog(object):
    lookup_handler, store = aliasing_scope(lookup_arg='alias', lookup_type=FilteringSyslogRealtime)

    def start_filter_log(self, filter, host=None, username="ute", password="ute", logfile="", alias="default"):
        syslog_runtime = FilteringSyslogRealtime(logfile, host, username, password)
        syslog_runtime.start_filter_log(filter)
        self.store.add(syslog_runtime, alias)
        self.lookup_handler.store = self.store

    @lookup_handler.implicit_lookup
    def stop_filter_log(self, alias="default"):
        alias.stop_filter_log()

    @lookup_handler.implicit_lookup
    def get_filtered_log(self, alias="default"):
        return alias.get_filtered_log()

    @lookup_handler.implicit_lookup
    def clear_filtered_log(self, alias="default"):
        alias.clear_filtered_log()

    @lookup_handler.implicit_lookup
    def change_filter_value(self, filter, alias="default"):
        alias.change_filter_value(filter)

    @lookup_handler.implicit_lookup
    def wait_for_filtered_log(self, timeout=60, alias="default"):
        return alias.wait_for_filtered_log(timeout)
