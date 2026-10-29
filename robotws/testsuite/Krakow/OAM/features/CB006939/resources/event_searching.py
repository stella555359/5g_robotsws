"""
Module with tools designed for searching events in syslog.
Also provides functions for start and stop of btslog2 program
"""
import os
import re
import datetime
import robot.api.logger as logger
from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import GnbBtslogCollector

ISO_DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.%fZ'
ISO_TIME_FORMAT = '%H:%M:%S.%f'


class BtsLogHandler:
    def __init__(self):
        self.btslog = GnbBtslogCollector()

    def start_collecting_btslog(self):
        """
        Starts collection of the syslog to the specified folder by btslog2 program
        :return:
        """
        self.btslog.start_collecting_btslog()
        logger.info('SYSLOG collection started')

    def stop_collecting_btslog(self):
        """
        Stops collection of the syslog by btslog2 program
        :return:
        """
        self.btslog.stop_collecting_btslog()
        logger.info('SYSLOG collection stopped')

    def find_all_message_occurrences(self, msg, syslog_dir='/tmp/btslog2'):
        """
        Finds all message occurrences in SYSLOG and returns list of it
        :return: List of found message occurrences
        """
        found_lines = []
        for line in _get_syslog_lines(syslog_dir=syslog_dir):
            if msg in line and "192.168.255.129" in line:
                logger.debug("Found msg {} in line {}".format(msg, line))
                found_lines.append(line)
        return found_lines


class SyslogSearcher(object):
    """Provides tools for searching through collected syslog"""

    def __init__(self, messages_to_find, btslog_path='/tmp/btslog2', use_regex=False, cu_syslog=False):
        """
        Creates GnbLog instance and assigns messages to find to variable in class
        :param messages_to_find: Syslog messages that should be passed in a form of
        a string, it will be transferred to SyslogMessage objects
        :param use_regex: If regex is set as true, then regex value will be used for searching in SysLog
        """
        self.btslog_path = btslog_path
        if use_regex:
            msg_object = RegexSyslogMessage
        else:
            msg_object = SyslogMessage
        self.messages_to_find = [msg_object(msg, cu_syslog) for msg in messages_to_find]

    def search_for_messages_in_btslog(self):
        """
        Searches btslog folder for messages saved in self
        :return: None
        """
        for line in _get_syslog_lines(self.btslog_path):
            if not self._are_all_messages_found():
                self._check_line_for_msgs(line)
            else:
                break

    def calculate_duration_between_msgs(self, start_msg_ind, end_msg_ind):
        """
        Calculates duration between two events in self.messages_to_find
        :param start_msg_ind: Start message as SyslogMessage object
        :param end_msg_ind: End message as SyslogMessage object
        :return: duration expressed by number of seconds (int)
        """
        try:
            start_msg = self.messages_to_find[start_msg_ind]
            end_msg = self.messages_to_find[end_msg_ind]
            if start_msg.msg_time and end_msg.msg_time:
                duration = end_msg.msg_time - start_msg.msg_time
                return duration.total_seconds()
            else:
                logger.error('Not all messages have been found in SYSLOG start_msg: {} end_msg: {}'.format(
                    start_msg.found_msg, end_msg.found_msg))
                raise ValueError('Not all messages have been found in SYSLOG')

        except IndexError:
            raise ValueError('Incorrect indexes passed to calculate_duration_between_msgs start_msg_ind {} '
                             'end_msg_ind {}'.format(start_msg_ind, end_msg_ind))

    def _are_all_messages_found(self):
        """
        Return True if all messages are found in
        :return: True if all searched messages are found, False otherwise
        """
        return all([msg.is_msg_found() for msg in self.messages_to_find])

    def _check_line_for_msgs(self, line):
        """
        Checks if message is available in line, if it is, then save this information to self.messages_to_find
        :param line: Line in syslog
        :return: None
        """
        for msg in self.messages_to_find:
            msg.check_line_for_msg(line)


class SyslogMessage(object):
    """Object used in SySlogSearcher, provides tools for storing and transferring single SYSLOG message"""

    def __init__(self, msg_to_find, cu_syslog):
        self.msg_to_find = msg_to_find
        self.found_msg = None
        self.msg_time = None
        self.cu_syslog = cu_syslog

    def is_msg_found(self):
        """
        :return: True if message has been found in syslog, False otherwise
        """
        return True if self.found_msg else False

    def check_line_for_msg(self, line):
        """
        Checks line for message, if found set found_msg and msg_time
        :return: None
        """
        if self.found_msg is None and self.msg_time is None:
            if self._is_msg_in_line(line):
                logger.debug('Message {} found in line {}, saving it'.format(self.msg_to_find, line))
                self.found_msg = line
                self._save_time_for_syslog_line()

    def _is_msg_in_line(self, line):
        """
        Checks self.msg_to_find is present in a given line
        :param line: Line to check
        :return: True or false based on information if msg is present in line
        """
        return self.msg_to_find in line

    def _save_time_for_syslog_line(self):
        """
        Reads time from syslog line and save it to self.msg_time
        :return: None
        """
        if self.cu_syslog:
            syslog_date_re = r'\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01]).*[+]'
            datetime_format = '%Y-%m-%dT%H:%M:%S.%f+'
        else:
            syslog_date_re = r'<\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01]).*>'
            datetime_format = '<%Y-%m-%dT%H:%M:%S.%fZ>'

        date_str = re.search(syslog_date_re, self.found_msg).group(0)
        logger.debug('Saving time for line: {} date_str: {}'.format(self.found_msg, date_str))
        self.msg_time = datetime.datetime.strptime(date_str, datetime_format)


class RegexSyslogMessage(SyslogMessage):
    """Extended SyslogMessage class that provides regex method of comparing message in line"""

    def _is_msg_in_line(self, line):
        """
        Checks if regex self.msg_to_find is found in line
        :param line: Line to check
        :return: True or False based on the information if regex is found in line
        """
        match = re.search(self.msg_to_find, line)
        return True if match else False


def _get_syslog_lines(syslog_dir='/tmp/btslog2'):
    """
    Gets syslog file from local machine and return SYSLOG lines for it
    :param syslog_dir:
    :return:
    """
    for filename in os.listdir(syslog_dir):
        with open(syslog_dir + '/' + filename, 'r') as file_content:
            for line in file_content:
                yield line
