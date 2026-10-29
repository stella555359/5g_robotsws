# -*- coding: utf-8 -*-
"""
2022/05/22 first version by @author: xiang.5.li@nokia-sbell.com
"""

import json_file
import os
from logger_et import LoggingEt
from exception_et import RaiseExceptionEt
# import logging


class CheckEgage(object):
    def __init__(self, log_path, egate_path, cfg_path):
        self.egate_path = egate_path
        self.cfg_path = cfg_path
        self.log_path = log_path
        __logger_name = os.path.basename(__file__)
        self.log = LoggingEt(self.log_path, __logger_name).log()
        # self.log = LoggingEt(self.log_path, __name__).log()
        self.raise_exception = RaiseExceptionEt(self.log_path)
        # Logging().logger.setLevel(logging.DEBUG)
        self.results = {"expect": {},
                        "error": {},
                        "legacy_error": {}
                        }
        self.is_egate_log_exist()
        self.is_egate_null()
        self.ok_cnt = 0
        self.error_cnt = 0
        self.case_flag = None

    def is_egate_log_exist(self):
        """
        if the egate log is exist
        :return: True
        """
        if not os.path.isfile(self.egate_path):
            self.raise_exception.case_fail("The file is not exist:%s!" % self.egate_path)
        else:
            return True

    def is_egate_null(self):
        """
        if the egate log is not NULL
        :return: True
        """
        with open(self.egate_path) as f:
            lines = f.readlines()
            if len(lines) == 0:
                self.raise_exception.case_fail("The file is NULL:%s!" % self.egate_path)
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
                self.log.error("There is some item not found in the egate log, expect:%s, log:%s"
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
            self.log.error("There is error in the log:%s" % self.egate_path)
            self.raise_exception.case_fail("There is ERROR in the log!")

    def check_results(self):
        self.check_result_expect()
        self.check_result_error()
        self.log.info("ok count:%s, error count:%s" % (self.ok_cnt, self.error_cnt))
        if self.ok_cnt > 0 and self.error_cnt == 0:
            self.case_flag = True
            self.raise_exception.case_pass("The egate log Pass!")
        elif self.error_cnt != 0 or self.ok_cnt == 0:
            self.case_flag = False
            self.raise_exception.case_fail("The egate log not match expect or have error!")
        else:
            self.case_flag = False
            self.raise_exception.case_fail("Fail with unknown reason!")

    def main(self):
        # print("Start egate checker".center(78, "="))
        self._get_cfg()
        with open(self.egate_path) as f:
            lines = f.readlines()
            for line in lines:
                self.check_expect(line)
                exist_flag = self.check_legacy_error(line)
                if not exist_flag:
                    self.check_error(line)
        self.printf_results()
        self.check_results()
        self.raise_exception.case_pass("The egate log check PASS!")


def egate_checker_py(log_path, egate_path, cfg_path):
    egate_obj = CheckEgage(log_path=log_path, egate_path=egate_path, cfg_path=cfg_path)
    egate_obj.main()
    return egate_obj.case_flag


if __name__ == "__main__":
    log_path = r'C:\work\data\017-Feature\5G\7601\wyh'
    egate_path = r'C:\work\data\017-Feature\5G\7601\wyh\egate_console.log'
    cfg_path = r'C:\et\common\resources\lib\json_file4egate.json'
    result = egate_checker_py(log_path, egate_path, cfg_path)
    print("final result", result)
