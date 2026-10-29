# -*- coding: utf-8 -*-

from robot.libraries.BuiltIn import BuiltIn

builtin_listen_obj = BuiltIn()


class keyword_logger(object):
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self, logger_nested_kw_flag=False, test_setup_teardown_logger_flag=False):
        self.keyword_stack = []
        self._setup_id = 0
        self._teardown_id = 0
        self.logger_nested_kw_flag_org = bool(logger_nested_kw_flag)
        self._suite_teardown = None
        self._setup_name = None
        self._teardown_name = None
        self._test_setup_teardown_logger_flag = bool(test_setup_teardown_logger_flag)

    def _get_keyword_name(self, name):
        return name

    def _log_keyword(self, name, attrs):
        keyword_name = self._get_keyword_name(name)
        indent = '    ' * len(self.keyword_stack)
        if attrs['type'].lower() == 'setup':
            self._setup_id = self._setup_id + 1
            self._setup_name = name
            if self._test_setup_teardown_logger_flag is True:
                self.logger_nested_kw_flag = True
            else:
                self.logger_nested_kw_flag = False
        if attrs['type'].lower() == 'teardown':
            self._teardown_id = self._teardown_id + 1
            self._teardown_name = name
            if self._test_setup_teardown_logger_flag is True:
                self.logger_nested_kw_flag = True
            else:
                self.logger_nested_kw_flag = False
        if name.lower().count("suite teardown") != 0 or name.lower().count("suite_teardown") != 0:
            self._suite_teardown = True
        if attrs['type']:
            if len(self.keyword_stack) == 0:
                print(f'\033[1m{indent}{keyword_name}\033[0m')
            elif self._setup_id >= 2 and self._suite_teardown is not True and self.logger_nested_kw_flag is True:
                curr_time = builtin_listen_obj.get_time()
                if len(", ".join(attrs["args"])) > 40:
                    print(f'{indent}%s {keyword_name}  {", ".join(attrs["args"])[:40]}...' % curr_time)
                else:
                    print(f'{indent}%s {keyword_name}  {", ".join(attrs["args"])}' % curr_time)
            else:
                pass

    def start_keyword(self, name, attrs):
        self._log_keyword(name, attrs)
        self.keyword_stack.append(name)

    def end_keyword(self, name, attrs):
        self.keyword_stack.pop()
        if self._test_setup_teardown_logger_flag is not True and self.logger_nested_kw_flag_org is True:
            if name == self._setup_name:
                self.logger_nested_kw_flag = True
            if name == self._teardown_name:
                self.logger_nested_kw_flag = True
        # if len(self.keyword_stack) > 0:
        #     parent_keyword = self.keyword_stack[-1]
        #     self._log_keyword(parent_keyword, attrs)
