# -*- coding: utf-8 -*-
"""
:created on: 09-12-2020

:copyright: Nokia
:author: leo wang
:contact: leo.y.wang@nokia-sbell.com
"""

import time
import os
import glob
import logging
from robot.libraries.BuiltIn import BuiltIn


class log_directory(object):
    """Create log directory
    """
    time_stamp = time.strftime("%Y%m%d%H%M%S", time.localtime())

    def __init__(self):
        self.suite_name = ""
        self.test_name = ""
        self.output_dir = ""
        self.log_save_path = "/tmp/log_save_path"
        self._log = logging.getLogger(__name__)

    def __str__(self):
        """create and return the log save path
        """
        self._get_suite_name()
        self._get_test_case_name()
        self.output_dir = self._get_robot_variable_value('OUTPUT_DIR')
        self._indicate_log_save_path()
        return self._create_log_save_path()

    def _create_log_save_path(self):
        """create the log saved path
        """
        if not os.path.exists(self.log_save_path):
            os.makedirs(self.log_save_path)
        return self.log_save_path

    def _indicate_log_save_path(self):
        """this keyword need implement by subclass
        """
        pass

    def _make_dir(self, path):
        """none
        """
        if not os.path.exists(path):
            os.makedirs(path)

    def _get_robot_variable_value(self, name):
        """none
        """
        try:
            ret = BuiltIn().get_variable_value('${%s}' % name)
            if not ret:
                ret = "default_kiss"
        except Exception as et:
            ret = "default_kiss"
            print("TEST_NAME EXCEPTION: %s" + str(et))
        finally:
            return ret.strip().replace(" ", "_")

    def _get_test_case_name(self):
        """get test case name
        """
        self.test_name = self._get_robot_variable_value('TEST_NAME')
        return self.test_name

    def _get_suite_name(self):
        """get test suite name
        """
        self.suite_name = self._get_robot_variable_value('SUITE_NAME')
        return self.suite_name


SUITE_ADD_CASE_NAME_MAX_LENGTH = 150


class test_log_dir(log_directory):
    """Create the test log directory for saving TA log. The test case log directory
    is under ${OUTPUT_DIR}/log/${SUITE_NAME}_timestamp/${TEST_NAME}.
    If the character length of ${SUITE_NAME}_timestamp/${TEST_NAME} is greater than 150,
    only keep the first 150 characters.
    """
    def _indicate_log_save_path(self):
        """Give the test log saved path for suite or test case, such as suite_timestamp/test_case_name
        """
        suite_name_with_timestamp = self.suite_name + "_" + test_log_dir.time_stamp
        sep = os.path.sep
        if self.test_name == "default_kiss":
            self.log_save_path = os.path.join(os.path.join(self.output_dir, "log"), suite_name_with_timestamp)
        else:
            path_result = glob.glob("{}{}{}{}{}".format(self.output_dir, sep, "log", sep, suite_name_with_timestamp))
            if path_result:
                self.log_save_path = os.path.join(path_result[0], self.test_name)
            else:
                self.log_save_path = os.path.join(os.path.join(os.path.join(self.output_dir, "log"),
                                                               suite_name_with_timestamp), self.test_name)
            max_path_length = len(self.output_dir+sep + "log" + sep) + SUITE_ADD_CASE_NAME_MAX_LENGTH
            if len(self.log_save_path) > max_path_length:
                self.log_save_path = self.log_save_path[:max_path_length]
        self.log_save_path += sep
        self.log_save_path = (self.log_save_path).replace('[', '_').replace(']', '_')
        self._log.debug("Test Log Directory:{}".format(self.log_save_path))


class kiss_debug_log_dir(log_directory):
    """Create the test log directory for saving TA tool debug log. The test debug log directory is under
    ${OUTPUT_DIR}/log/${SUITE_NAME}_timestamp/${TEST_NAME}/kiss_debug_logs.
    """
    def _indicate_log_save_path(self):
        """Give the case log directory for saving TA tool debug log under the suite or test case log directory.
        """
        suite_name_with_timestamp = self.suite_name + "_" + kiss_debug_log_dir.time_stamp
        sep = os.path.sep
        if self.test_name == "default_kiss":
            path_result = glob.glob("{}{}{}{}{}".format(self.output_dir, sep, "log", sep, suite_name_with_timestamp))
            if path_result:
                self.log_save_path = os.path.join(path_result[0], "kiss_debug_logs")
            else:
                self.log_save_path = os.path.join(os.path.join(os.path.join(self.output_dir, "log"),
                                                  suite_name_with_timestamp), "kiss_debug_logs")
        else:
            case_name = self.test_name
            suite_add_case_name = suite_name_with_timestamp + sep + self.test_name
            if len(suite_add_case_name) > SUITE_ADD_CASE_NAME_MAX_LENGTH:
                suite_add_case_name = suite_add_case_name[:SUITE_ADD_CASE_NAME_MAX_LENGTH]
                case_name = suite_add_case_name.split(sep)[-1]
            suite_path_result = glob.glob("{}{}{}{}{}".format(self.output_dir, sep, "log", sep,
                                                              suite_name_with_timestamp))
            if suite_path_result:
                case_path_result = glob.glob("{}{}{}". format(suite_path_result[0], sep, case_name))
                self.log_save_path = os.path.join(case_path_result[0], "kiss_debug_logs") if case_path_result else os.\
                    path.join(os.path.join(suite_path_result[0], case_name), "kiss_debug_logs")
            else:
                self.log_save_path = os.path.join(os.path.join(os.path.join(os.path.join(self.output_dir, "log"),
                                                                            suite_name_with_timestamp), case_name),
                                                  "kiss_debug_logs")
        self.log_save_path += sep
        self._log.debug("Kiss Debug Log Directory: {}".format(self.log_save_path))


def test_log_directory():
    """return a test log directory.

    :return: the test log directory.
    :rtype: string
    """
    return "{}".format(test_log_dir())


def kiss_debug_log_directory():
    """return a test log debug directory.

    :return: the test log debug directory.
    :rtype: string
    """
    return "{}".format(kiss_debug_log_dir())
