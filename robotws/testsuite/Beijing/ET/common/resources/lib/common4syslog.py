# -*- coding: utf-8 -*-
"""
2022/05/22 first version by @author: xiang.5.li@nokia-sbell.com
"""

import json_file
import os
import re
from logger_et import LoggingEt
from exception_et import RaiseExceptionEt
# import logging


class CheckSyslog(object):
    def __init__(self, log_path, syslog, cfg_path):
        self.syslog = syslog
        self.cfg_path = cfg_path
        self.log_path = log_path
        __logger_name = os.path.basename(__file__)
        self.log = LoggingEt(self.log_path, __logger_name).log()
        # self.log = LoggingEt(self.log_path, __name__, "on").log()
        self.raise_exception = RaiseExceptionEt(self.log_path)
        # Logging().logger.setLevel(logging.DEBUG)
        self.results = {"expect": {},
                        "error": {},
                        "legacy_error": {}
                        }
        self.log.info("syslog type:%s" % (type(syslog)))
        self.find_gnb_sys_log()
        self.is_syslog_log_exist()
        self.ok_cnt = 0
        self.error_cnt = 0
        self.case_flag = None

    def find_gnb_sys_log(self):
        log = []
        for folder in self.syslog:
            if os.path.isdir(folder):
                file_name_lst = os.listdir(folder)
                for file in file_name_lst:
                    if re.search(r"Gnb_syslog_\d+_\d+", file):
                        file_abs = folder + os.path.sep + file
                        if file_abs not in log:
                            log.append(file_abs)
            elif os.path.isfile(folder) and folder not in log:
                log.append(folder)
        self.syslog = log
        self.log.debug("syslog list:%s" % self.syslog)

    def is_syslog_log_exist(self):
        """
        if the syslog log is exist
        :return: True
        """
        if len(self.syslog) == 0:
            self.raise_exception.case_fail("The syslog info is empty:%s!" % self.syslog)
        elif not os.path.isfile(self.syslog[0]):
            self.raise_exception.case_fail("The syslog path error:%s!" % self.syslog)
        else:
            return True

    def is_syslog_null(self):
        """
        if the syslog log is not NULL
        :return: True
        """
        with open(self.syslog[0]) as f:
            lines = f.readlines()
            if len(lines) == 0:
                return False
            else:
                return True

    def _get_cfg(self):
        self.cfg = json_file.ReadCfg(self.cfg_path).json_cfg()

    def check_expect(self, line):
        for item, _ in self.cfg['expect'].items():
            if item in line:
                if item in self.results['expect']:
                    self.results['expect'][item] += 1
                else:
                    self.results['expect'][item] = 1

    def check_legacy_error(self, line):
        flag = False
        for item in self.cfg['legacy_error']:
            if item in line:
                flag = True
                if item in self.results['legacy_error']:
                    self.results['legacy_error'][item] += 1
                else:
                    self.results['legacy_error'][item] = 1
        return flag

    def check_error(self, line):
        for item in self.cfg['error']:
            if item in line:
                self.log.debug(line)
                if item in self.results['error']:
                    self.results['error'][item] += 1
                else:
                    self.results['error'][item] = 1

    def printf_results(self):
        self.log.info("Log check config:%s" % self.cfg)
        self.log.info("Log check results:%s" % self.results)

    def check_result_expect(self):
        if len(self.cfg['expect']) != 0:
            if len(self.results['expect']) < len(self.cfg['expect']):
                self.error_cnt += 1
                self.log.error("There is some item not found in the syslog log, \nexpect:%s, log:%s"
                               % (self.cfg['expect'], self.results['expect']))
                self.raise_exception.case_fail("The result item less than expect items!")
            for item, value in self.cfg['expect'].items():

                if len(self.results['expect']) == len(self.cfg['expect']):
                    if value == -1:
                        if self.results['expect'][item] > 0:
                            self.ok_cnt += 1
                        else:
                            self.error_cnt += 1
                            self.log.error("The expect '%s' should be greater than 0, log count: %s"
                                           % (item, self.results['expect'][item]))
                            self.raise_exception.case_fail("The expect info not found!")
                    elif value != -1:
                        if self.results['expect'][item] == value:
                            self.ok_cnt += 1
                        else:
                            self.error_cnt += 1
                            self.log.error("The expect '%s' should be equal: %s, log count: %s"
                                           % (item, value, self.results['expect'][item]))
                            self.raise_exception.case_fail("The expect info not enough!")
                    else:
                        self.error_cnt += 1
                        self.log.error("Invalid config: please refer the json_file_example.json")
                        self.raise_exception.case_invalid("Not find match info!")

    def check_result_error(self):
        if len(self.results['error']) > 0:
            self.error_cnt += 1
            self.log.error("There is error in the log:%s" % self.syslog)
            self.raise_exception.case_fail("There is ERROR in the log!")

    def check_results(self):
        self.check_result_expect()
        self.check_result_error()
        self.log.info("ok count:%s, error count:%s" % (self.ok_cnt, self.error_cnt))
        if self.ok_cnt > 0 and self.error_cnt == 0:
            self.case_flag = True
            self.raise_exception.case_pass("The syslog pass!")
        elif self.error_cnt != 0 or self.ok_cnt == 0:
            self.case_flag = False
            self.raise_exception.case_fail("The syslog not match expect or have error!")
        else:
            self.case_flag = False
            self.raise_exception.case_fail("Fail with unknown reason!")

    def main(self):
        # print("Start syslog checker".center(78, "="))
        self._get_cfg()
        for log in self.syslog:
            with open(log) as f:
                lines = f.readlines()
                for line in lines:
                    self.check_expect(line)
                    exist_flag = self.check_legacy_error(line)
                    if not exist_flag:
                        self.check_error(line)
        self.printf_results()
        self.check_results()
        self.raise_exception.case_pass("The syslog check PASS!")


def syslog_checker_py(log_path, syslog, cfg_path):
    syslog_obj = CheckSyslog(log_path=log_path, syslog=syslog, cfg_path=cfg_path)
    syslog_obj.main()

    return syslog_obj.case_flag


if __name__ == "__main__":
    log_path = r'C:\work\data\017-Feature\5G\7601\auto_lvbin\CB007601-B_1-1_TC001_20220427132212357'
    syslog_path = [r'C:\work\data\017-Feature\5G\7601\auto_lvbin\CB007601-B_1-1_TC001_20220427132212357']
    cfg_path = r'C:\et\common\resources\lib\json_file4syslog.json'
    result = syslog_checker_py(log_path, syslog_path, cfg_path)
    print("final result", result)
