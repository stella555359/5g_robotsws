"""
:copyright: Nokia Networks
:author: Aleksander Kleczek, Piotr Smerdzynski
:contact:
:maintainer: None
:contact: None
"""
from __future__ import absolute_import
from builtins import object
from robot.api import logger
from testsuite.Hangzhou.RRM.RAN_L3_SW_CN_LTE.trunk_sbts.CRT.LTE2275.\
    LTE2275_resource.common.common import DISPLAY_STEPS, DISPLAY_TIME
import datetime
import time


class Logger(object):
    ENDC = '\033[0m'
    PINK = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

    def __init__(self):
        now = time.time()
        self.last_run = now

    def log(self, msg, level='INFO', level_color=BOLD, msg_color=''):
        if DISPLAY_TIME:
            now = time.time()
            div_time = now - self.last_run
            current_time = datetime.datetime.now().strftime("%H:%M:%S.%f")
            formatted_msg = "\r[{}]>{:^8.{prec}f}< [ {}{}{} ] {}{}{}"\
                .format(current_time[:-3], div_time, level_color, level,
                        Logger.ENDC, msg_color, msg, Logger.ENDC, prec=2)
            self.last_run = now
        else:
            formatted_msg = "\r[ {}{}{} ] {}{}{}".format(level_color, level, Logger.ENDC, msg_color, msg, Logger.ENDC)
        if DISPLAY_STEPS:
            logger.console(formatted_msg)

    def log_test_setup_start(self, msg):
        self.log(msg=msg, level='Test Setup Start', level_color=Logger.YELLOW)

    def log_test_setup_end(self, msg):
        self.log(msg=msg, level='Test Setup End', level_color=Logger.YELLOW)

    def log_test_teardown_start(self, msg):
        self.log(msg=msg, level='Test Teardown Start', level_color=Logger.YELLOW)

    def log_test_teardown_end(self, msg):
        self.log(msg=msg, level='Test Teardown End', level_color=Logger.YELLOW)

    def log_test_step(self, msg):
        self.log(msg=msg, level='Test Step', level_color=Logger.GREEN)

    def log_param_change(self, msg):
        self.log(msg=msg, level='Parameter change', level_color=Logger.PINK)

    def log_test_step_ok(self, msg):
        self.log(msg=msg, level='Test Step', level_color=Logger.GREEN)

    def log_test_step_not_ok(self, msg):
        self.log(msg=msg, level='Test Step', level_color=Logger.RED)

    def log_step_with_level(self, msg, level, level_color=None):
        self.log(msg=msg, level=level, level_color=Logger.BLUE if level_color is None else level_color)


class TestLogger(Logger):
    pass
