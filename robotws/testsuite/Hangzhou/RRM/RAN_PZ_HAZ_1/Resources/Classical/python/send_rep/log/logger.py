"""Common logging module
Usage:
    in main thread first run config_logging method
    then use logging.getLogger("pdu.xxx") to get a logger"""

import logging
import os
from .error import *
# from __builtin__ import false


def dir_create_no_logging(dir_name):
    """Create a directory, makes all intermediate-level directories contain the leaf directory.

    Input:[1] dir_full_path: full path name of directory
    Notes: If directory existed, return 1 directly.
    """
    dir_full_path = dir_name
    if os.path.isdir(dir_full_path):
        print("WARN - File %s has existed:" % dir_full_path)
        return ReturnSuccess
    try:
        os.makedirs(dir_full_path)
    except BaseException:
        print("WARN - Create directory %s fail" % dir_full_path)
        return DirFileCreateFail
    print("INFO - Create directory %s OK" % dir_full_path)
    return ReturnSuccess


def file_create_no_logging(file_full_path):
    """Create a file

    Input:[1] p_FileFullName: full path name of file
    Notes: If file existed, return ReturnFailure directly.
           If its parent directory not exist, creat it firstly
    """
    if os.path.isfile(file_full_path):
        print("WARN - File %s has existed" % file_full_path)
        return ReturnSuccess
    # its parent directory exist or not
    parent_dir = os.path.dirname(file_full_path)
    if not os.path.isdir(parent_dir):
        dir_create_no_logging(parent_dir)
        print(
            "INFO - Create parent directory %s ok before Create file %s" %
            (parent_dir, file_full_path))
    try:
        with open(file_full_path, 'w') as _:
            pass
    except IOError:
        print("ERR - Create file %s failed" % file_full_path)
        return DirFileCreateFail
    print("INFO - Create File %s OK" % file_full_path)
    return ReturnSuccess


class Logger:
    LOGGINGLEVELS = {"NOTSET": logging.NOTSET,
                     "DEBUG": logging.DEBUG,
                     "INFO": logging.INFO,
                     "WARN": logging.WARN,
                     "ERROR": logging.ERROR,
                     "FATAL": logging.FATAL,
                     "CRITICAL": logging.CRITICAL}

    def __init__(self):
        self.streamformat = '%(name)s/%(module)s(%(lineno)d)/%(levelname)s(%(process)d): %(message)s'
        self.fileformat = "%(asctime)s %(name)s/%(module)s(%(lineno)d)/%(levelname)s(%(process)d): %(message)s"
        self.logtag = None
        self.stream_loglevel = None
        self.file_loglevel = None
        self.filemode = None
        self.filter_list = []
        self.max_filesize = None
        self.max_filenum = None

    def config_logging(self,
                       logtag="log",
                       stream_loglevel=None,
                       file_loglevel=None,
                       filename="log.log",
                       filemode="w",
                       filter_list=[],
                       max_filesize=1024 * 1024 * 30,
                       max_filenum=100):

        self.logtag = logtag
        self.stream_loglevel = self._check_level(stream_loglevel)
        self.file_loglevel = self._check_level(file_loglevel)
        self.filename = filename
        if not file_create_no_logging(self.filename):
            print("ERR - create log file failed: %s" % self.filename)
        self.filemode = filemode
        self.filter_list = filter_list
        self.max_filesize = max_filesize
        self.max_filenum = max_filenum

        self.logger = logging.getLogger(self.logtag)
        self.logger.setLevel(logging.DEBUG)  # default log level

        for filter_tag in self.filter_list:
            filter = logging.Filter(filter_tag)
            self.logger.addFilter(filter)

        if self.stream_loglevel:
            self._config_streamhandler()

        if file_loglevel:
            self._config_filehandler()

        return True

    def _config_filehandler(self):
        from logging.handlers import RotatingFileHandler
        filehandler = RotatingFileHandler(filename=self.filename,
                                          mode=self.filemode,
                                          maxBytes=self.max_filesize,
                                          backupCount=self.max_filenum)
        filehandler.setLevel(self.file_loglevel)
        filehandler_formatter = logging.Formatter(self.fileformat)
        filehandler.setFormatter(filehandler_formatter)
        self.logger.addHandler(filehandler)

    def _config_streamhandler(self):
        streamhandler = logging.StreamHandler()
        streamhandler.setLevel(self.stream_loglevel)
        streamhandler_formatter = logging.Formatter(self.streamformat)
        streamhandler.setFormatter(streamhandler_formatter)
        self.logger.addHandler(streamhandler)

    def get_logger(self, logtag=""):
        return logging.getLogger(logtag)

    def _check_level(self, level):
        if level is None:
            return level
        try:
            level = str(level)
            if level not in Logger.LOGGINGLEVELS:
                raise ValueError("Unknown level: %r" % level)
            tlevel = Logger.LOGGINGLEVELS[level]
        except Exception as e:
            print("ERROR: ", repr(e))
            raise TypeError("Please input a valid log level: %r" % level)
        return tlevel


class Logger_by_time:
    LOGGINGLEVELS = {"NOTSET": logging.NOTSET,
                     "DEBUG": logging.DEBUG,
                     "INFO": logging.INFO,
                     "WARN": logging.WARN,
                     "ERROR": logging.ERROR,
                     "FATAL": logging.FATAL,
                     "CRITICAL": logging.CRITICAL}

    def __init__(self):
        self.streamformat = '%(name)s/%(module)s(%(lineno)d)/%(levelname)s(%(process)d): %(message)s'
        self.fileformat = "%(asctime)s %(name)s/%(module)s(%(lineno)d)/%(levelname)s(%(process)d): %(message)s"
        self.logtag = None
        self.stream_loglevel = None
        self.file_loglevel = None
        self.filemode = None
        self.when = "midnight"
        self.interval = 1
        self.backupCount = 7

    def config_logging(self,
                       logtag="log",
                       stream_loglevel=None,
                       file_loglevel=None,
                       filename="log.log",
                       filemode="w",
                       when="D",
                       interval=1,
                       backupcount=7):
        self.logtag = logtag
        self.stream_loglevel = self._check_level(stream_loglevel)
        self.file_loglevel = self._check_level(file_loglevel)
        self.filename = filename
        if not file_create_no_logging(self.filename):
            print("ERR - create log file failed: %s" % self.filename)
        self.filemode = filemode
        self.when = when
        self.interval = interval
        self.backupCount = backupcount

        self.logger = logging.getLogger(self.logtag)
        self.logger.setLevel(logging.DEBUG)  # ???

        if self.file_loglevel is None and self.stream_loglevel is None:
            return True
        if self.file_loglevel and self.stream_loglevel:
            # ===================================================================
            # logging.basicConfig(format=self.streamformat,
            #                     level=self.stream_loglevel,
            #                     )
            # ===================================================================
            self._config_streamhandler()
            self._config_filehandler()
            return True
        if self.file_loglevel is None and self.stream_loglevel is not None:
            # ===================================================================
            # logging.basicConfig(format=self.streamformat,
            #                     level=self.stream_loglevel,
            #                     )
            # ===================================================================
            self._config_streamhandler()
            return True
        if file_loglevel is not None and stream_loglevel is None:
            self._config_filehandler()
            return True
        return False

    def _config_filehandler(self):
        from logging.handlers import TimedRotatingFileHandler
        filehandler = TimedRotatingFileHandler(self.filename,
                                               when=self.when,
                                               interval=self.interval,
                                               backupCount=self.backupCount,
                                               encoding=None,
                                               delay=False,
                                               utc=False
                                               )
        filehandler.setLevel(self.file_loglevel)
        filehandler_formatter = logging.Formatter(self.fileformat)
        filehandler.setFormatter(filehandler_formatter)
        self.logger.addHandler(filehandler)

    def _config_streamhandler(self):
        streamhandler = logging.StreamHandler()
        streamhandler.setLevel(self.stream_loglevel)
        streamhandler_formatter = logging.Formatter(self.streamformat)
        streamhandler.setFormatter(streamhandler_formatter)
        self.logger.addHandler(streamhandler)

    def get_logger(self, logtag=""):
        return logging.getLogger(logtag)

    def _check_level(self, level):
        if level is None:
            return level
        try:
            level = str(level)
            if level not in Logger.LOGGINGLEVELS:
                raise ValueError("Unknown level: %r" % level)
            tlevel = Logger.LOGGINGLEVELS[level]
        except Exception as e:
            print("ERROR: ", repr(e))
            raise TypeError("Please input a valid log level: %r" % level)
        return tlevel

# if __name__ == "__main__":
#     log = Logger()
#     log.config_logging(logtag="sync_tc",
#                        stream_loglevel="INFO",
#                        file_loglevel="DEBUG",
#                        filename="sync_tc.log",
#                        filemode="w",
#                        max_filesize=1024*1024*10,
#                        max_filenum=10
#                        )
#     logger = logging.getLogger("sync_tc.main")

#     #for i in range(1024):
#     #   logger.info("test...")
#     logger.info("test")

#     logger.debug('This is debug message')
#     logger.info('This is info message')
#     logger.warning('This is warning message')
