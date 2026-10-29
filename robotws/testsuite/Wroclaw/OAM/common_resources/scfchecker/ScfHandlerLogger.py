import logging
from datetime import datetime
import sys
from robot.api import logger as loggerrobot

"""
Documentation
...  AUTHORS:       sebastian.suwada@nokia.com
...  MAINTAINER:    MN_RAN_RD_VRF_WRO3_2
...  *****************
...  Basic information
...  *****************
...  The scfHandler library is designed to facilitate the retrieval and verification of information within SCF files.
...  Its primary use case is to assist users during testing by identifying missing parameters that can be configured
...  on the test line. This ensures a more streamlined and efficient testing process
...  by providing actionable insights into parameter settings.
...  Defined logger for scfHandler library.
...  ******************
...  History of changes
...  ******************
...  https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26930 - Creation of library
"""


class ScfHandlerLogger:
    ''' Global logger for all of files '''
    _logger = None

    def __init__(self):
        if ScfHandlerLogger._logger is None:
            ScfHandlerLogger._logger = self.initialize_logger()
        self.logger = ScfHandlerLogger._logger

    def info(self, msg):
        self.logger.info(f"{self._t_stamp()} - [SCF-Checker]: {msg}")

    def error(self, msg):
        self.logger.error(f"{self._t_stamp()} - [SCF-Checker]: {msg}")

    def warn(self, msg):
        self.logger.warning(f"{self._t_stamp()} - [SCF-Checker]: {msg}")

    def info_robot(self, msg):
        loggerrobot.info(f"{self._t_stamp()} - [SCF-Checker]: {msg}")

    def error_robot(self, msg):
        loggerrobot.error(f"{self._t_stamp()} - [SCF-Checker]: {msg}")

    def warn_robot(self, msg):
        loggerrobot.warn(f"{self._t_stamp()} - [SCF-Checker]: {msg}")

    @staticmethod
    def _t_stamp() -> str:
        return str(datetime.now()).split(".")[0]

    @staticmethod
    def initialize_logger() -> logging.Logger:

        formatter = logging.Formatter(fmt='%(asctime)s %(levelname)s:BTS %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
        logger = logging.getLogger(__name__)
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(formatter)

        logger.addHandler(console_handler)
        logger.setLevel(logging.DEBUG)
        logger.propagate = False

        return logger
