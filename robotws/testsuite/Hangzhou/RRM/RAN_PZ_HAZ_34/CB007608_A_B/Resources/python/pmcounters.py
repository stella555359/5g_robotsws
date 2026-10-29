import datetime
import robot.api.logger as logger
import os
import glob
import time
import re
from taf.analyzer.pmcounter.pm_log_reader import PMCounterLogReader


def wait_next_meas_period(meas_period=300, add_time=30, with_console_output=False):
    """Author: Nikolay Shkulepov; Abstraction Level is LOW
    introduced 30s delay time, for writing pm counter files
    :param meas_period -> int
    :param with_console_output -> Boolean (default False)"""
    logger.debug("============================== Begin wait_next_meas_period()")
    logger.debug("wait_next_meas_period: meas_period = {} ".format(meas_period))
    start_time = time.time()
    logger.debug("wait_next_meas_period: start_time='{}' started".format(start_time))
    delta = meas_period
    if with_console_output:
        logger.console(" Wait next measurement period: ({}) ".format(datetime.datetime.fromtimestamp(
            int(time.time()))), newline=False)
    counter = 0
    while delta > 0:
        time.sleep(1)
        delta = meas_period - time.time() + start_time
        if int(time.time() - int(add_time)) % meas_period == 0:   # wait for additional time
            break
        counter += 1
        if counter % 30 == 0 and with_console_output:
            logger.console(".", newline=False)
    if with_console_output:
        logger.console(".done (%s)" % datetime.datetime.fromtimestamp(int(time.time())))
    logger.debug("wait_next_meas_period: start_time='{}' finished with wait of {} min {} sec".format(
        start_time, counter/60, counter % 60))
    logger.debug("============================== End wait_next_meas_period()")
