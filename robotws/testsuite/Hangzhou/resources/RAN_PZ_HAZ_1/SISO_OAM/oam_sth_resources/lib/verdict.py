# -*- coding: utf-8 -*-

import warnings

from robot.api import logger
from robot.errors import ExecutionFailed
from robot.libraries.BuiltIn import BuiltIn
# from tabulate import tabulate
from ute_common_converter.to_bool import to_bool

__all__ = [
    "verdict", "STATUS_VARIABLE_NAME", "VERDICT_VARIABLE_NAME",
    "ENV_ERRORS_ALLOWED"
]

STATUS_VARIABLE_NAME = "${TEST STATUS}"
VERDICT_VARIABLE_NAME = "${TEST VERDICT}"
ENV_ERRORS_ALLOWED = "${ENV ERRORS ALLOWED}"


def format_message_width(message, width=88):
    """
    Format message with END OF LINE signs to make every line have fixed size

    :param message: Message string
    :type message: str
    :param width: Size of line
    :type width: int
    :return: Formatted message
    :rtype: str
    """
    words = message.split()
    msg = ""
    line = words[0]
    for word in words[1:]:
        if len(line) + len(word) < width:
            line += " " + word
        else:
            msg += line + "\n"
            line = word
    msg += line
    return msg


class verdict(object):
    ROBOT_LIBRARY_SCOPE = "TEST CASE"
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self._builtin = BuiltIn()
        self.errors = list()
        self.warnings = list()
        self.norun = True
        self.blocked = False
        self.ROBOT_LIBRARY_LISTENER = self
        self.pass_type_collection = ["passed_with_restriction", "passed"]

    def set_test_blocked(self, message):
        """
        Mark the test as blocked and skip to teardown.

        | **Author:** dariusz.suszczewicz@nokia.com
        | **Maintainer:** alona.kulieshova@nokia.com
        | **Released with version:** ---

        **Input Parameters:**

        +------------------+------+------------------------+
        | Parameter name   | Man. | Description            |
        +==================+======+========================+
        | message          | yes  | blocking reason        |
        +------------------+------+------------------------+

        **Example**

        .. code-block:: robotframework

            Set Test Blocked   Verification was not completed due to timeout or some unit indicates a faulty state.

        """
        self.blocked = True
        self.set_test_failed(message, fail_fast=True)

    def set_test_norun(self, message, fail_test=True):
        """
        Mark test as not run and skip to teardown.

        | **Author:** dariusz.suszczewicz@nokia.com
        | **Maintainer:** alona.kulieshova@nokia.com
        | **Released with version:** ---

        **Input Parameters:**

        +------------------+------+------------------------+
        | Parameter name   | Man. | Description            |
        +==================+======+========================+
        | message          | yes  | no run reason          |
        +------------------+------+------------------------+
        | fail_test        | no   | fail test if True      |
        +------------------+------+------------------------+

        **Example**

        .. code-block:: robotframework

            Set Test Norun  Test case doesn't support this configuration.

        """
        self.norun = True
        if fail_test:
            self.set_test_failed(message, fail_fast=True)
        else:
            self.set_test_restriction(message)
            self._builtin.pass_execution(message)

    def set_test_restriction(self, message):
        """
        Add restriction to passed test.

        | **Author:** dariusz.suszczewicz@nokia.com
        | **Maintainer:** alona.kulieshova@nokia.com
        | **Released with version:** ---

        **Input Parameters:**

        +------------------+------+------------------------+
        | Parameter name   | Man. | Description            |
        +==================+======+========================+
        | message          | yes  | restriction message    |
        +------------------+------+------------------------+

        **Example**

        .. code-block:: robotframework

            Set Test Restriction  Active alarms exist.

        """
        self.warnings.append(message)
        self._builtin.log(message, level="WARN", console=True)

    def set_test_failed(self, message, fail_fast=False):
        """
        Mark the test as failed, but do not go to teardown
        if fail_fast is not True.

        | **Author:** dariusz.suszczewicz@nokia.com
        | **Maintainer:** alona.kulieshova@nokia.com
        | **Released with version:** ---

        **Input Parameters:**

        +------------------+------+------------------------+
        | Parameter name   | Man. | Description            |
        +==================+======+========================+
        | message          | yes  | failure reason         |
        +------------------+------+------------------------+
        | fail_test        | no   | fail test if True      |
        +------------------+------+------------------------+

        **Example**

        .. code-block:: robotframework

            Set Test Failed  Critical fail while checking alarms.

        """
        self.errors.append(message)
        self._builtin.log(message, level="ERROR", console=True)
        err = ExecutionFailed(message)
        if not to_bool(fail_fast):
            err.continue_on_failure = True

        raise err

    def set_preconditions_passed(self):
        """
        Set the preconditions as passed, which means that the test has started.

        | **Author:** dariusz.suszczewicz@nokia.com
        | **Maintainer:** alona.kulieshova@nokia.com
        | **Released with version:** ---

        """
        self.norun = False

    def get_test_verdict(self):

        robot_status = self._builtin.get_variable_value(STATUS_VARIABLE_NAME)
        if self.blocked:
            verdict = "blocked"
        elif self.norun:
            verdict = "norun"
        elif self._is_failed(robot_status):
            verdict = "failed"
        elif self._is_passed_with_restriction(robot_status):
            verdict = "passed_with_restriction"
        else:
            verdict = "passed"
        return verdict

    def align_verdicts(self):
        """
        Fail the test if resolved verdict indicate a failure.

        | **Author:** dariusz.suszczewicz@nokia.com
        | **Maintainer:** alona.kulieshova@nokia.com
        | **Released with version:** ---

        """
        verdict = self.get_test_verdict()
        self._builtin.set_suite_variable(VERDICT_VARIABLE_NAME, verdict)
        self._builtin.log(
            "Calculated execution verdict: {0:s}".format(verdict),
            level="DEBUG",
            console=True)
        if verdict not in self.pass_type_collection:
            self._builtin.fail(
                "Calculated execution verdict: {0:s}".format(verdict))

    def log_verdict_messages(self):
        """
        Log all verdicts messages.

        | **Author:** jaroslaw.piszczala@nokia.com
        | **Maintainer:** alona.kulieshova@nokia.com
        | **Released with version:** 1.5.0

        """
        if self.warnings:
            self._log_list("Restrictions", self.warnings)
        if self.errors:
            self._log_list("Errors", self.errors)

    def _get_env_errors_allowed(self):
        return self._builtin.get_variable_value(ENV_ERRORS_ALLOWED, "False")

    def _is_failed(self, robot_status):
        test_failed = (self.errors or robot_status == "FAIL")
        env_errors_not_allowed = (self._get_env_errors_allowed() != "True")
        return test_failed and env_errors_not_allowed

    def _is_passed_with_restriction(self, robot_status):
        env_errors_allowed = (self._get_env_errors_allowed() == "True")
        test_failed = (robot_status == "FAIL")
        return self.warnings or env_errors_allowed and test_failed

    @staticmethod
    def _log_list(name, entries):
        header = [name]
        rows = [[format_message_width(item, 120)] for item in entries]
        # table_obj = tabulate(rows, header, tablefmt="rst")
        # logger.info(table_obj, also_console=True)


if __name__ == '__main__':
    pass
