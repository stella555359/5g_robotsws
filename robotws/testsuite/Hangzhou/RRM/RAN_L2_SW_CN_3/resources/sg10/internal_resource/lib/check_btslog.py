# -*- coding: UTF-8 -*-

import re
import os
from time import time
import string
from six.moves import range
from functools import reduce
import logging

err_ignore = [
    'WRN/cp_rt/L2PsUserConfigurationIEBuilder.cpp:#864',
    'WRN/cp_rt/NiddSctpConfigStore.cpp:#283',
    'l2-ps/uplane/L2-PS/src/debuglog/DebugLogProducer',
    'LogarithmLookUp::tenLogTenPrbsTable: access out of range or unsupported arg 0 274',
    'late fd scheduling',
    'StatsForLateFd',
    '5QI-5 shall be configured into LCG0 as SRB']
wrn_title = ['wrn\\/.*l2-ps\\/', 'wrn\\/cp_rt']
err_title = ['.*l2_ps.*err\\/', '.*please contact l2-ps.*', 'err\\/mlmgmt', 'err\\/aiml', 'err\\/cp_rt']


def get_error(error, fp, log):
    pattern = r'<.*{}.*'.format(error)
    matches = re.findall(pattern, fp.read())
    error_number = len(matches)
    print('********************************************************')
    print('btslog log path:{}'.format(log))
    print(*matches, sep='\n')
    print('above {} #####  {}  ##### exist'.format(error_number, error))
    print('========================================================')
    return error_number


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

    def check_err_wrn_in_btslog(self, fpath, tag, custom_error=[]):
        if isinstance(custom_error, str) and len(custom_error) == 2:
            custom_error = []
        if isinstance(custom_error, str) and len(custom_error) != 2:
            custom_error = eval(custom_error)

        if not isinstance(custom_error, list):
            print("input custom error is {}".format(custom_error))
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
        custom_error_number = self.check_custom_error(custom_error, btslog_list)
        if err_number > 0 or custom_error_number > 0:
            raise AssertionError("error:bts log wrn and err check fail")

    def check_custom_error(self, custom_error, btslog_list):
        custom_error_number = 0
        if custom_error:
            for log in btslog_list:
                for error in custom_error:
                    with open(log, "r", encoding='utf-8', errors='ignore') as fp:
                        custom_error_number += get_error(error, fp, log)
            return custom_error_number
        else:
            print("No custom error")
            return custom_error_number

    def check_err(self, file_path):
        err_list = []
        reg = re.compile('<.*')
        with open(file_path, 'r', encoding='utf-8', errors='ignore')as f:
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
        with open(file_path, 'r', encoding='utf-8', errors='ignore')as f:
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
        return j


if __name__ == "__main__":
    fpath = r"C:\N-20S1PF2SS9Y8-Data\yashao\Desktop\syslog"
    tag = "before_onair"
    custom_error = "[]"
    check_btslog().check_err_wrn_in_btslog(fpath, tag, custom_error)
