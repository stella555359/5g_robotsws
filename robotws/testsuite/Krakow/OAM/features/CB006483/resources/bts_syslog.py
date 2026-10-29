from datetime import datetime, timedelta
import re
import os
import time

from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import GnbBtslogCollector
from robot.api import logger


class BtsSysHandler:
    def __init__(self):
        self.btslog = GnbBtslogCollector()  # TODO: Consider contex-manager and make whole class stateless

    def start_collecting_btslog(self):
        """
        Starts collection of the syslog to the specified folder by btslog2 program
        :return:
        """
        self.btslog.start_collecting_btslog()
        logger.info("SYSLOG collection started")

    def stop_collecting_btslog(self):
        """
        Stops collection of the syslog by btslog2 program
        :return:
        """
        self.btslog.stop_collecting_btslog()
        logger.info("SYSLOG collection stopped")

    @staticmethod
    def has_timeout_exceed(expiration_time):
        """
        Checks if time (at function execution moment) has exceeded time given in argument
        :param expiration_time:
        :return: bool
        """
        return expiration_time <= datetime.now()

    @staticmethod
    def has_log_line_desired_message(log_line, message):
        """
        Checks if part of given log_line has particular message
        :param log_line:
        :param message:
        :return:
        """
        find_mess = re.search(message, log_line)
        if find_mess:
            logger.info('Find message {}'.format(find_mess.group(0)))
            return True

    @staticmethod
    def check_triggered_snapshot_counters(log_line):
        triggering_message = "Sum of all snapshot triggers for 24h"
        re_sum_of_all_snaps = 'Sum of all snapshot triggers for 24h is [0-9]{1,}\\.'
        re_sum_of_redundant_snaps = (
            'Ignoring fault \\([0-9]{1,}\\) due to more than '
            'maxNumSnapByFaultTrigPerDay [0-9]{1,} times in 24 hours'
        )
        if triggering_message in log_line:
            logger.info('Found: {}'.format(triggering_message))
            sum_of_all = re.search(re_sum_of_all_snaps, log_line).group(0)
            sum_of_redundant = re.search(re_sum_of_redundant_snaps, log_line).group(0)
            logger.info(sum_of_all)
            logger.info(sum_of_redundant)

    @staticmethod
    def wait_for_message_in_syslog(regex, file_path="/tmp/btslog2/", timeout=300):
        """
        Waits for first appear of message in btslog file.
        In case the message is found function returns True.
        In case the message is not found (at all or at a certain time) function raises proper Exception
        :param regex: message  to find in desired syslog_file
        :param file_path: absolute path for btslog2 logs directory
        :param timeout: number of seconds specifying the duration of the search
        :return: True if searched message was found, otherwise function raises Exception
        """
        start_time = datetime.now()
        end_time = start_time + timedelta(seconds=timeout)
        syslog_path = BtsSysHandler.get_syslog_file(file_path)
        for line in BtsSysHandler._get_syslog_lines(syslog_path):
            BtsSysHandler.check_triggered_snapshot_counters(line)
            if BtsSysHandler.has_log_line_desired_message(line, regex):
                logger.console('Regex "{}" first matching found at line: {}'.format(regex, line))
                return True
            if BtsSysHandler.has_timeout_exceed(end_time):
                raise Exception("Timeout {} sec. occurred and '{}' has not been found".format(timeout, regex))
        raise Exception("Regex not found in log file")

    @staticmethod
    def get_syslog_file(file_path):
        syslog_file = os.popen(
            'ls -ltr {} | grep -oh "SYSLOG_[0-9]\\+.LOG" | tail -n 1'.format(file_path)
        ).read()
        syslog_file = syslog_file.strip()  # removes unwanted \n due to command execution
        logger.info("Find syslog file {}".format(syslog_file))
        if syslog_file:
            return os.path.join(file_path, syslog_file)
        raise Exception("File not found.")

    @staticmethod
    def _get_syslog_lines(syslog_dir='/tmp/btslog2'):
        with open(syslog_dir, "r") as log_file:
            log_file.seek(0, 0)
            while True:
                line = log_file.readline()
                if not line:
                    time.sleep(0.1)
                    continue
                yield line
