# -*- coding: utf-8 -*-
"""
2022/06/22 first version by @author: sheng.1.ye@nokia.com
    The InfoChecker class is used to check result of txt file parsed by InfoParser
2022/06/24 add log_path parameter and verified counter, by Ye Sheng
2022/06/29 add function description, by Ye Sheng
2022/07/06 add filter_expression support, by Ye Sheng
"""

import sys
import os
import json
import unittest


try:
    from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
    from testsuite.Beijing.ET.common.resources.lib.logger_et import LoggingEt
except ModuleNotFoundError:
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from info_parser import InfoParser
    from logger_et import LoggingEt


class FailInfo:
    LOAD_JSON_FILE_FAIL = "Load Json file fail:\nFile={json_file}\nError={fail_info}"
    CHECKER_VALIDATION_FAIL = ("Validation Fail: Json File={json_file}, Log File={log_file}, Log Path={log_path}\n"
                               "Check Id={check_id}, Validation Id={validation_id}\nFailed Validation={validation}\n"
                               "Vars:{vars}")
    VALIDATIONS_ARE_MISSING = ("Validations are missing: Json File={json_file}, "
                               "Log File={log_file}, Log Path={log_path}\n, Check Id={check_id}")


class InfoChecker:
    def __init__(self, filename, base_path=''):
        """
        Check if "validations" configured in json file passed
        Keywords in of json file:
            'log_file': logfile name or pattern, e.g. pcap.txt,  pcap*.txt,  logs*/pcap*.txt
            'log_path': logfile path or pattern, e.g  /home/logs/,  ./test/logs*/
                        this 'log_path' will use 'base_path' parameter as base path
            'item_list': item list used for parsing item(used in InfoParser.get_info)
            'filter_pattern': filter_pattern used for filter items(used in InfoParser.get_info)
            'filter_expression': filter_expression used for filter items(used in InfoParser.get_info)
            'validations': validation to check, keys: 'match_id', 'assert_true', 'assert_false', 'var_xyz'
                {'match_id': 0,  'assert_true': 'abc > 0'} in 1st match, abc should great than 0
                {'match_id': 2,  'var_xyz': 'abc + def'} in 3rd match, set var_xyz = abc + def
                {'match_id': 1,  'assert_false': 'var_xyz == www'} in 2nd match, var_xyz should = www
        :param filename:  json file to check, e.g.  /home/test_case/test_case_1_1.json
        :param log_path:  log base folder used in json file, e.g. /home/log/
        """
        self.filename = filename
        self.base_path = base_path
        self.logger = LoggingEt(self.base_path).log()
        self.config = []
        self.variables = {}
        self.id_info = {}
        self.verified = 0

    def run(self):
        self._load()
        self._validate()
        self.logger.info("InfoChecker for %s PASSED: %d" % (os.path.basename(self.filename), self.verified))

    def _load(self):
        with open(self.filename) as rf:
            try:
                self.config = json.load(rf)
            except Exception as e:
                InfoParser.fail_if(True, FailInfo.LOAD_JSON_FILE_FAIL, json_file=self.filename, fail_info=e)
        self.id_info.update(json_file=self.filename)

    def _validate(self):
        self.verified = 0
        for checker in self.config:
            self._check(checker)

    def _check(self, checker):
        log_file = checker.get('log_file', '')
        log_path = checker.get('log_path', '')
        log_path = os.path.join(self.base_path, log_path)
        self.id_info.update({'log_file': log_file, 'log_path': log_path})
        info_parser = InfoParser(filename=log_file, path=log_path)
        checks = checker.get('checks', [])
        for n, check_info in enumerate(checks):
            self.id_info.update({'check_id': n})
            self._verify(check_info, info_parser)

    def _verify(self, check_info, info_parser):
        item_list = check_info.get('item_list', [])
        filter_pattern = check_info.get('filter_pattern', '')
        filter_expression = check_info.get('filter_expression', '')
        validations = check_info.get('validations', [])
        InfoParser.fail_if(not validations, FailInfo.VALIDATIONS_ARE_MISSING, **self.id_info)
        max_count = self._get_max_count(validations)
        info = info_parser.get_info(item_list=item_list, filter_pattern=filter_pattern,
                                    filter_expression=filter_expression, count=max_count)
        for n, v in enumerate(validations):
            self.id_info.update({'validation_id': n, 'validation': v})
            self._verify_item_list(v, info)

    @staticmethod
    def _get_max_count(validations):
        if any(i.get('match_id', -1) == -1 for i in validations):
            return 0
        return max(i.get('match_id', -1) + 1 for i in validations)

    def _verify_item_list(self, verify_info, item_info_list):
        match_id = verify_info.get('match_id', -1)
        if match_id == -1:
            for i in item_info_list:
                self._verify_item(verify_info, i)
        else:
            self._verify_item(verify_info, item_info_list[match_id])
        self.verified += 1

    def _verify_item(self, verify_info, item_info):
        for k, expression in verify_info.items():
            if k == 'assert_true':
                self._assert_true(expression, item_info)
            if k == 'assert_false':
                self._assert_false(expression, item_info)
            elif k.startswith('var_'):
                self._save_var(k, expression, item_info)

    def _assert_true(self, expression, item_info):
        locals().update(item_info)
        locals().update(self.variables)
        InfoParser.fail_if(not eval(expression), FailInfo.CHECKER_VALIDATION_FAIL,
                           **self.id_info, vars=dict(**item_info, **self.variables))

    def _assert_false(self, expression, item_info):
        locals().update(item_info)
        locals().update(self.variables)
        InfoParser.fail_if(eval(expression), FailInfo.CHECKER_VALIDATION_FAIL,
                           **self.id_info, vars=dict(**item_info, **self.variables))

    def _save_var(self, name, expression, item_info):
        locals().update(item_info)
        locals().update(self.variables)
        self.variables[name] = eval(expression)


def check_info(json_file, base_path):
    InfoChecker(json_file, base_path).run()


if __name__ == '__main__':
    if len(sys.argv) == 3:
        json_filename, log_base_path = sys.argv[1], sys.argv[2]
        check_info(json_file=json_filename, base_path=log_base_path)
    else:
        import ut
        unittest.main(module=ut)
