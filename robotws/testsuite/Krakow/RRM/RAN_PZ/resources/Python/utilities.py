"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
"""

from robot.libraries.BuiltIn import BuiltIn
from ta5g_enb.html_method_logger import log_method_name
from robot.api import logger
from datetime import datetime


def logger_console(msg, prefix=" [Console] ", timestamp=True):
    date = datetime.today().strftime('%Y/%m/%d %H:%M:%S') if timestamp is True else ""
    msg_final = "{}{}{}".format(date, prefix, msg)
    logger.console(msg_final)


def logger_console_info(msg, prefix_console=" [Console] ", prefix_info="[Info] ", timestamp=True):
    logger_console(msg, prefix=prefix_console, timestamp=timestamp)
    logger.info("{}{}".format(prefix_info, msg))


def get_current_date():
    return datetime.now().strftime("%d%m%Y_%H%M%S")
