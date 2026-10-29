import os
import re

from datetime import datetime

from robot.libraries.BuiltIn import BuiltIn
from robot.running.context import EXECUTION_CONTEXTS
from robot.utils import is_truthy

__all__ = ["resolve_logs_directory_path"]

ROBOT_LIBRARY_DOC_FORMAT = "reST"

_RE_INVALID_NAME = re.compile("[^-0-9A-Z_a-z]")
_RE_INVALID_PATH = re.compile("[^-0-9A-Z_a-z/]")


def _sanitize(value, sanitize_regexp):
    """Replaces troublesome characters with underscores and dashes"""
    sanitized_path = sanitize_regexp.sub("-", str(value).replace(" ", "_"))
    return sanitized_path


def resolve_logs_directory_path(subdir="", add_timestamp=True):
    """Returns path to store logs in, that depends on current execution context.

    An extra subdirectory can be added to the resulting path using ``subdir`` argument.
    Note that non alphanumeric characters will be replaced with dashes and underscores.

    By default, current timestamp is appended to the path (or used instead of ``subdir``
    if not provided). This can be changed by setting ``add_timestamp=False``.
    """
    testcase = EXECUTION_CONTEXTS.current.test
    teardown = EXECUTION_CONTEXTS.current.in_suite_teardown

    if not testcase:
        if teardown:
            dynamic_part = "Suite_logs/Teardown"
        else:
            dynamic_part = "Suite_logs/Setup"
    else:
        dynamic_part = "TC_" + _sanitize(testcase, _RE_INVALID_NAME)

    extra_part = os.path.normpath(str(subdir)).strip("/") if subdir else ""
    timestamp = datetime.strftime(datetime.now(), "%Y%m%d_%H%M%S")
    if is_truthy(add_timestamp):
        extra_part = "_".join([part for part in [extra_part, timestamp] if part])

    return os.path.join(
        BuiltIn().replace_variables("${OUTPUT_DIR}"),
        dynamic_part,
        _sanitize(extra_part, _RE_INVALID_PATH),
    )
