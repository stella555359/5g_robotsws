# -*- coding: utf-8 -*-
"""
Author: Chen Tong
Contacts: tong.chen@nokia-sbell.com
Squard: HGZ SG2

"""
import re
import logging
from enum import IntEnum
import time


class Content(IntEnum):
    timestamp = 0
    avg_tuning_value = 1
    active_tuning_mode = 2
    clk_freq_diff = 3
    pct_of_rejected_phase_samples = 4
    active_sync_ref_source_type = 5
    clk_phase_diff = 6
    active_sync_ref_source = 7


class LogInfo:

    def __init__(self, log_content):
        self.timestamp = log_content[Content.timestamp]
        self.avg_tuning_value = log_content[Content.avg_tuning_value]
        self.active_tuning_mode = log_content[Content.active_tuning_mode]
        self.clk_freq_diff = log_content[Content.clk_freq_diff]
        self.pct_of_rejected_phase_samples = log_content[Content.pct_of_rejected_phase_samples]
        self.active_sync_ref_source_type = log_content[Content.active_sync_ref_source_type]
        self.clk_phase_diff = log_content[Content.clk_phase_diff]
        self.active_sync_ref_source = log_content[Content.active_sync_ref_source]

    def content_of_log_is_not_empty(self):
        for attr, value in vars(self).items():
            logging.info("{}: {}".format(attr, value))
            if value is None:
                raise Exception('Could not find value of {}'.format(attr))


class SyncLog:

    """
        sync log parse function
    """

    def __init__(self):
        self.content_list = [
            'timestamp',
            'Avg tuning value',
            'Active tuning mode',
            'Clk freq diff',
            'Pct. of rejected phase samples',
            'Active Sync ref source type',
            'Clk phase diff',
            'Active ref source',
        ]
        self.content = []

    def _extract_time_stamp(self, content_timestamp):
        timestamp = re.search(r'\d+-\d+-\d+T\d+:\d+:\d+\.\d+', content_timestamp).group()
        return timestamp

    def _check_time_stamp(self, content_list):
        if len(content_list) < 2:
            raise Exception('At least two records are required!')
        for after, before in zip(content_list[1:], content_list[:-1]):
            time1 = re.sub(r'\D', "", re.search(r'T\d+:\d+', after.timestamp).group())
            time2 = re.sub(r'\D', "", re.search(r'T\d+:\d+', before.timestamp).group())
            interval = \
                ((int(time1[:2]) * 60 + int(time1[2:])) + 24 * 60 - (int(time2[:2]) * 60 + int(time2[2:]))) % (24 * 60)
            if interval > 21:
                raise Exception(
                    'RU shall store one record per 20 minutes time period or faster. '
                    'Current interval is {} {}'.format(interval, after.timestamp))

    def _extract_record_from_sync_log_for_analysis(self, log_file):
        with open(log_file) as log_obj:
            info = [None] * (int(Content.active_sync_ref_source)+1)
            for line in log_obj.readlines()[2:]:
                searchobj = re.search(self.content_list[1], line)
                if searchobj is None:
                    continue
                content_line = line.strip().split(',')
                logging.info(">>> {}".format(content_line))
                info[int(Content.timestamp)] = self._extract_time_stamp(content_line[0])
                for content_info in content_line[2:]:
                    v = content_info.strip().split(':')
                    index = self.content_list.index(v[0])
                    # logging.info("Info: {}".format(v[0]))
                    info[index] = v[1]
                log_info_obj = LogInfo(info)
                self.content.append(log_info_obj)
        return self.content

    def confirm_all_content_of_sync_log_is_covered(self, log_file):
        record = self._extract_record_from_sync_log_for_analysis(log_file)
        if not record:
            raise Exception('No record is found in log!')
        for cont in record:
            LogInfo.content_of_log_is_not_empty(cont)
        self._check_time_stamp(record)

    def check_timer_iswork(self, log_file):
        timestamp1 = 0
        timestamp2 = 0
        with open(log_file) as log_obj:
            for line in log_obj.readlines()[2:]:
                if "starting timer" in line:
                    timestamp = self._extract_time_stamp(line)
                    timestamp1 = timestamp.split("T")[0] + ' ' + timestamp.split("T")[1].split(".")[0]
                    timestamp1 = time.strptime(str(timestamp1), "%Y-%m-%d %H:%M:%S")
                    timestamp1 = int(time.mktime(timestamp1))
                elif "selected master dropped" in line:
                    timestamp = self._extract_time_stamp(line)
                    timestamp2 = timestamp.split("T")[0] + ' ' + timestamp.split("T")[1].split(".")[0]
                    timestamp2 = time.strptime(str(timestamp2), "%Y-%m-%d %H:%M:%S")
                    timestamp2 = int(time.mktime(timestamp2)) - 3
            if timestamp2 == timestamp1:
                logging.info("The timer is working!")
