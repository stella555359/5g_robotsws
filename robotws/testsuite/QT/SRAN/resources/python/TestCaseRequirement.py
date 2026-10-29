# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Krzysztof Michalek
:contact: krzysztof.michalek@nokia.com
"""

from robot.libraries.BuiltIn import BuiltIn


class TestCaseRequirement(object):
    """
    This class is responsible for the compliance with dependencies between TCs. This results in dependent TC's failing,
    when a prerequisite failed but only a warning message will be displayed if a prerequisite was not run in
    the current scope
    of a testsuite

    The :func:`requires_tc` method is dedicated for use in the TC's [Setup] section.

      :Example:

      | Example dependent TC
      | | [Setup] | Requires TC | required TC
      | | some keywords

    """
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.test_status = {}

    def requires_tc(self, name, force=False):
        """
        :param str name: here goes required TC's name
        :param bool force: fail TC if required TC wasn't executed
        :return: status depending on the required TC's result
        """
        test_name_lower_case = name.lower()
        if test_name_lower_case not in self.test_status:
            if force:
                BuiltIn().fail('required TC not run: {}'.format(name))
            else:
                BuiltIn().log('required TC not run during this testsuite execution: {}'.format(name))
        elif self.test_status[test_name_lower_case] != "PASS":
            BuiltIn().fail('required TC failed: {}'.format(name))

        return True

    def get_test_case_status_by_name(self, name):
        """
        Author: Ding Binmei
        Description: Get test case status by case name
        :param name:
        :return: case status. Available status are: NA, PASS, FAIL, RUNNING
        """
        test_name_lower_case = name.lower()
        # Try to get the current running test from Robot Framework context
        try:
            from robot.running.context import EXECUTION_CONTEXTS
            current_test = EXECUTION_CONTEXTS.current.test
            if current_test and current_test.name.lower() == test_name_lower_case:
                return 'RUNNING'
        except Exception:
            pass
        # If not running, return the result status
        if test_name_lower_case not in self.test_status:
            return 'NA'
        else:
            return self.test_status[test_name_lower_case]

    def _end_test(self, name, args):
        self.test_status[name.lower()] = args['status']
