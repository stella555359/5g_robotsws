# -*- coding: utf-8 -*-

import os
import unicodedata
import string
import six

from robot.libraries.BuiltIn import BuiltIn


class Testpath(object):
    def get_test_hierarchy(self):
        robot_builtin_keywords = BuiltIn()

        current_test_suite_name = robot_builtin_keywords.get_variable_value("${SUITE_NAME}")
        current_test_case_name = robot_builtin_keywords.get_variable_value("${TEST_NAME}")

        current_test_hierarchy = current_test_suite_name.split('.')
        if not (current_test_case_name is None):
            current_test_hierarchy.append(current_test_case_name)

        current_test_hierarchy = [self._convert_string(test_hier_item) for test_hier_item in current_test_hierarchy]
        return current_test_hierarchy

    def get_test_path(self):
        robot_builtin_keywords = BuiltIn()
        root_log_folder_path = robot_builtin_keywords.get_variable_value("${OUTPUT_DIR}")

        current_test_hierarchy = self.get_test_hierarchy()
        current_test_hierarchy_path = os.path.join(*current_test_hierarchy)

        current_test_log_folder_path = os.path.join(root_log_folder_path, current_test_hierarchy_path)
        current_test_log_folder_path = os.path.normpath(current_test_log_folder_path)

        return current_test_log_folder_path

    def _convert_string(self, value):
        value = unicodedata.normalize('NFKD', six.u(str(value))).encode('ascii', 'ignore')
        valid_chars = "-_.() %s%s" % (string.ascii_letters, string.digits)
        if six.PY2:
            return ''.join(c for c in value if c in valid_chars)
        else:
            return ''.join(chr(c) for c in value if chr(c) in valid_chars)
