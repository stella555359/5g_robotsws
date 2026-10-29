# -*- coding: UTF-8 -*-

import re
import os
from time import time
import string
from six.moves import range
from functools import reduce
import logging
import glob

err_ignore = [
    'WRN/cp_rt/L2PsUserConfigurationIEBuilder.cpp:#864',
    'WRN/cp_rt/NiddSctpConfigStore.cpp:#283',
    'L2-PS/src/debuglog/DebugLogProducer']
wrn_title = ['wrn\\/.*l2-ps\\/', 'wrn\\/cp_rt']
err_title = ['.*l2_ps.*err\\/']


class check_btslog():

    def __init__(self):
        self._log = logging.getLogger(__name__)

    def find_btslog_log_path(self, fpath, tag):
        btslog_list = []
        for fpathe, dirs, fs in os.walk(fpath):
            for f in fs:
                log = os.path.join(fpathe, f)
                if tag in log:
                    btslog_list.append(log)
        return btslog_list

    def check_err_wrn_in_btslog(self, fpath, tag):
        wrn_num_list = []
        err_num_list = []
        btslog_list = self.find_btslog_log_path(fpath, tag)
        if len(btslog_list) > 0:
            for i in range(0, len(btslog_list)):
                file_path = btslog_list[i]
                print('********************************************************')
                print('btslog log path:{}'.format(file_path))
                num_wrn = self.check_wrn(file_path)
                err_wrn = self.check_err(file_path)
                wrn_num_list.append(num_wrn)
                err_num_list.append(err_wrn)
        wrn_number = reduce(lambda x, y: x + y, wrn_num_list)
        err_number = reduce(lambda x, y: x + y, err_num_list)
        if err_number > 0:
            raise AssertionError("error:bts log wrn and err check fail")

    def check_err(self, file_path):
        err_list = []
        reg = re.compile('<.*')
        with open(file_path, 'r')as f:
            for line in f:
                line.strip('\n')
                for i in err_title:
                    value = len(re.findall(i, line.lower()))
                    if value != 0:
                        j = self.judge_whether_exist_err(line)
                        if j == 0:
                            err_list.append(line)
                            print(reg.search(line).group(0))
            print('above {} err exist'.format(len(err_list)))
            print('========================================================')
            return len(err_list)

    def check_wrn(self, file_path):
        wrn_list = []
        reg = re.compile('<.*')
        with open(file_path, 'r')as f:
            for line in f:
                line.strip('\n')
                for i in wrn_title:
                    value = len(re.findall(i, line.lower()))
                    if value != 0:
                        j = self.judge_whether_exist_err(line)
                        if j == 0:
                            wrn_list.append(line)
                            print(reg.search(line).group(0))
            print('above {} wrn exist'.format(len(wrn_list)))
            print('========================================================')
            return len(wrn_list)

    def judge_whether_exist_err(self, line):
        j = 0
        for judge_err in err_ignore:
            if judge_err in line:
                j += 1
                print(line)
            else:
                j += 0
        return j

    def check_specific_word_in_btslog(self, file_path, words):
        files = glob.glob(file_path)
        for path in files:
            with open(path, 'r') as file:
                content = file.read()
                if words in content:
                    print('words found')
                    return True
                else:
                    print('words not found')
                    return False

    def get_position_from_sos(self, file_path, field):
        with open(file_path, 'r') as file:
            content = file.read()
            start_index = content.find(field)
            if start_index != -1:
                end_index = content.find("\n", start_index)
                if end_index != -1:
                    result = content[start_index + len(field):end_index].strip()
                    match1 = re.search(r'azimuth=(\d+)', result)
                    if match1:
                        azimuth = match1.group(1)
                    match2 = re.search(r'elevation=(\d+)', result)
                    if match1:
                        elevation = match2.group(1)
                    return azimuth, elevation
