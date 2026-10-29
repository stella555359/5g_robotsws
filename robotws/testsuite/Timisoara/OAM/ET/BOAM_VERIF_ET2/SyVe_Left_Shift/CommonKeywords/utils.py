"""
:copyright: Nokia Networks
:author: Damian Muszynski
:contact: damian.muszynski@nokia.com
:maintainer: I_EXT_5G_IV_WRO_OAM3_GMS

This module contains robot framework utility keywords.
"""

from robot.libraries.BuiltIn import BuiltIn, ExecutionFailed
from robot.utils import text as text_utils
import os.path


def patch_max_error_log(max_lines=100, max_length=300):
    """
    It so happens that error log message is cut by robot and so we can't properly use functionality of
    'Run keyword and expect error'. This extends limit of max lines and length of lines.
    This dynamically override Robot Framework mechanisms.

    USE WITH CAUTION - monkey patching is unpredictable.

    :param max_lines: number of error lines
    :param max_length: max length of error line
    """
    text_utils._MAX_ERROR_LINES = int(max_lines)
    text_utils._MAX_ERROR_LINE_LENGTH = int(max_length)


def wait_until_keyword_fails(retry, retry_interval, name, *args):
    BuiltIn().wait_until_keyword_succeeds(retry, retry_interval, keyword_fails.__name__, name, *args)


def keyword_fails(name, *args):
    try:
        BuiltIn().run_keyword(name, *args)
    except ExecutionFailed:
        return True
    else:
        raise AssertionError("Keyword '{}' did not fail".format(name))


def get_dict_that_has_value(dict_list, value):
    for dictionary in dict_list:
        if value in dictionary.values():
            return dictionary


def get_sw_file_name_with_suffix(build, special_build_nr, special_suffix):
    if special_build_nr in build:
        return build + special_suffix
    return build


def check_if_sw_already_exists(path):
    exists = os.path.exists(path)
    return exists


def slugify_path(path):
    return path.replace(' ', '_') \
        .replace('.', '_') \
        .replace(',', '_') \
        .replace(':', '_') \
        .replace('-', '_') \
        .replace('>', '_') \
        .replace('<', '_') \
        .replace('|', '_') \
        .replace('\\', '_') \
        .replace('?', '_') \
        .replace('(', '') \
        .replace(')', '') \
        .replace('*', '_')
