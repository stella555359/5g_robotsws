"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>
"""
import os
import re
import time

from robot.libraries.BuiltIn import BuiltIn
from ta5g_syslog.interface import ta5g_syslog
from datetime import datetime


class short_syslog(object):
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self.test_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}', os.getcwd())
        try:
            self.interface = BuiltIn().get_library_instance('ta5g_syslog')
        except Exception:
            self.interface = ta5g_syslog()
        self.started_syslog_aliases = []
        self.filtered_lines = {}

    def start_collecting_syslog(self, prefix=None, filtered_lines=None):
        time_part = re.sub(r':', '', str(datetime.now().strftime("%H:%M:%S")))
        prefix = prefix if prefix is not None else ""
        name = "{}_{}.txt".format(time_part, prefix)
        if name not in self.started_syslog_aliases:
            self.interface.start_syslog(log_dir=self.test_dir, log_name=name, alias=name)
            self.started_syslog_aliases.append(name)
        else:
            raise Exception('Such syslog already started!')
        if filtered_lines is not None:
            self.filtered_lines[name] = [line.strip() for line in str(filtered_lines).strip().split(',')]

    def stop_collecting_syslog(self):
        while len(self.started_syslog_aliases):
            sys_name = self.started_syslog_aliases.pop(0)
            self.interface.stop_syslog(alias=sys_name)
            if sys_name in self.filtered_lines:
                print('Filtering over phrases:\n{}'.format(self.filtered_lines[sys_name]))
                filtering_start = time.time()
                new_lines = []
                with open("{}".format(os.sep.join([self.test_dir, sys_name])), 'r') as file:
                    for line in file.readlines():
                        for phrase in self.filtered_lines[sys_name]:
                            if phrase in line and line not in new_lines:
                                new_lines.append(line)
                with open('{}'.format(os.sep.join([self.test_dir, 'filtered_{}'.format(sys_name)])), 'a')\
                        as to_write_file:
                    to_write_file.writelines(new_lines)
                elapsed_time = time.time() - filtering_start
                print('Write new file with filtered: {} lines. It took: {} s'.format(len(new_lines), elapsed_time))
                del self.filtered_lines[sys_name]

    def _end_test(self, name, attr):
        self.stop_collecting_syslog()
