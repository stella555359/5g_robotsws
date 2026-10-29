# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek
:contact: michal.maczek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_warning, logger_console
)
from subprocess import Popen, PIPE
import shlex
import sys
import re


class StreamDoesNotContainLineException(Exception):
    pass


class QuotasOtherThanExpectedException(Exception):
    pass


class NotExistingCellGivenException(Exception):
    pass


class NotExistingSliceListGivenException(Exception):
    pass


def is_testcase_from_sa_b_suite():
    return '-B' in BuiltIn().get_variable_value('${SUITE_NAME}')


def is_testcase_from_nsa_c_suite():
    return '-C' in BuiltIn().get_variable_value('${SUITE_NAME}')


def is_testcase_vonr():
    return 'VoNR' in BuiltIn().get_variable_value("${TEST_NAME}")


def is_testcase_ca_multiplmn_sa():
    return is_testcase_from_sa_b_suite() and '2CC_TDD_FDD_using' in BuiltIn().get_variable_value("${TEST_NAME}")


def __check_if_param_is_unicode_or_str(param):
    global unicode
    try:
        is_unicode = not sys.version_info[0] >= 3 and isinstance(param, unicode)
    except UnboundLocalError:
        is_unicode = False
    if isinstance(param, str) or is_unicode:
        return True
    return False


def __open_txt_filename(path, split_str):
    cmd = 'cat {}'.format(path)
    cmd_splitted = shlex.split(cmd)
    output = Popen(cmd_splitted, stdout=PIPE)
    output_stream = output.stdout.read()
    decoded_stream = None
    try:
        decoded_stream = output_stream.decode("utf-8")
    except UnicodeDecodeError:
        decoded_stream = output_stream.decode("iso8859-15")
    splitted = enumerate(decoded_stream.split(split_str))
    return splitted


def ensure_it_is_file_stream(path_or_stream, split_str='\n'):
    if __check_if_param_is_unicode_or_str(param=path_or_stream):
        return __open_txt_filename(path_or_stream, split_str=split_str)

    return path_or_stream


def __get_correct_for_loop_generator(stream, text=None, regexp=None):
    if isinstance(stream, enumerate) and text:
        return (line for num, line in stream if text in line)
    elif isinstance(stream, enumerate) and regexp:
        return (re.search(regexp, line) for num, line in stream if re.search(regexp, line))
    if isinstance(stream, list) and text:
        return (line for line in stream if text in line)
    elif isinstance(stream, list) and regexp:
        return (re.search(regexp, line) for line in stream if re.search(regexp, line))
    else:
        logger_warning("Unknown type for stream: {}".format(type(stream)))
        return None


def regexp_in_stream_exists(stream, path, text=None, regexp=None, raise_exception=True):
    gen = __get_correct_for_loop_generator(regexp=regexp, text=text, stream=stream)
    for x in gen:
        return x
    if raise_exception:
        raise StreamDoesNotContainLineException("{} not in {}".format(regexp if regexp else text, path))
    return None


def regexp_in_string_exists(string, text=None, regexp=None, is_slice=None):
    for _string in string:
        if is_slice:
            BuiltIn().set_suite_variable('${PROPER_CELL_SETUP_MSG}', _string)
        if text and text in _string:
            return True
        if regexp and re.search(regexp, _string):
            return re.search(regexp, _string)

    raise StreamDoesNotContainLineException("{} not in {}".format(regexp if regexp else text, string))


def regexp_item_in_stream(regexp, stream, item):
    gen = __get_correct_for_loop_generator(regexp=regexp, stream=stream)
    rtn = [match.group(item) for match in gen]
    return rtn


def regexp_item_equal_values_in_stream(regexp, stream, item=None, values=[]):
    gen = __get_correct_for_loop_generator(regexp=regexp, stream=stream)
    if item is None or len(values) == 0:
        rtn = [match.groupdict() for match in gen]
    else:
        rtn = {match.group(item): match.groupdict() for match in gen if match.group(item) in values}
    return rtn


def convert_enum_to_list(enum, without_first_elem=False):
    rtn = [elem for idx, elem in enum]
    return rtn[1:] if without_first_elem else rtn


def validate_single_quotas(actual, expected):
    msg = 'Min Expected: {}; Min Actual: {}\nMax Expected: {}; Max Actual: {}'.format(
        expected['min'], actual['min'], expected['max'], actual['max']
    )
    if actual['min'] == expected['min'] and actual['max'] == expected['max']:
        logger_console("Quotas equal to expected:\n" + msg)
        return

    raise QuotasOtherThanExpectedException("Quotas different from expected:\n" + msg)


def validate_given_cell(cell):
    proper_cells = [0, 1, 2, 3]
    cell = int(cell)
    if cell is None or cell not in proper_cells:
        msg = "Passed cell ID {}, which does not exist, use {}".format(cell, proper_cells)
        raise NotExistingCellGivenException(msg)
    return cell


def validate_given_slice_list(slice_list, decrease_value=False):
    proper_lists = [0, 1, 2, 3]
    slice_list = int(slice_list)
    if decrease_value:
        slice_list -= 1
    if slice_list not in proper_lists:
        msg = "Passed slice list num {}, which does not exist, use {}".format(slice_list, proper_lists)
        raise NotExistingSliceListGivenException(msg)
    return slice_list
