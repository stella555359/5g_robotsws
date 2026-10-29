# -*- coding: utf-8 -*-
"""
:created on: 2021-03-24

:copyright: Nokia
:author: Wen chao Zhang
:contact: wenchao.zhang@nokia-sbell.com
this function is private, only use to SG11 testing.
if you need it, please contact leo.y.wang@nokia-sbell.com, he will provide public keyword like this.
"""
import fileinput
import glob
import re
import os
import logging
import sys


class handle_syslog(object):
    def __init__(self, path, syslog_end):
        """
        init
        :param path: syslogs path
        :param syslog_end: log suffix
        """
        self.path = path
        self.syslog_end = syslog_end
        self.sys_files = []
        self.keyword = re.compile(b'ERR/*.?|WRN/*.?')

    def find_syslog(self):
        """
        find syslogs
        :return: syslog list
        """
        sys_files = []
        for sys_file in glob.glob(os.path.join(self.path, self.syslog_end)):
            sys_files.append(sys_file)
        self.sys_files = sys_files
        return self.sys_files

    def check_keyword(self):
        """
        check syslog keyword via re
        :return: None
        """
        fault_logs = []
        if 'gz' in self.syslog_end:
            f = fileinput.input(self.sys_files, openhook=fileinput.hook_compressed)
        else:
            f = fileinput.input(self.sys_files)
        for line in f:
            if f.isfirstline():
                rows, columns = os.popen('stty size', 'r').read().split()  # get windows width
                width_length = int(((int(columns) - len(f.filename().split('/')[-1])) / 2))
                filename = '=' * width_length + f.filename().split('/')[-1] + '=' * width_length + '\n'
                fault_logs.append(filename)
            if re.findall(self.keyword, line):
                fault_logs.append(line.decode('utf-8'))
        f.close()
        if len(fault_logs) > 2:
            logging.info(''.join(fault_logs))
            for fault in fault_logs:
                if 'EAaErrorFatality_Fatal' in fault:
                    logging.warning(fault)


def display_syslog_error_warning(path, syslog_end="*.tar.gz"):
    """
    display syslog error and warn printer
    :param path: syslog files path
    :param syslog_end: check log suffix
    :return: None
    """
    handle_sys = handle_syslog(path=path, syslog_end=syslog_end)
    handle_sys.find_syslog()
    handle_sys.check_keyword()


if __name__ == '__main__':
    display_syslog_error_warning(sys.argv[1])
    pass
