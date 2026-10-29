# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:maintainer: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
from subprocess import Popen, PIPE
import shlex
import sys
import re

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_warning


class StreamDoesNotContainLineException(Exception):
    pass


class IncorrectSumOfMinimumQuotas(Exception):
    pass


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
        decoded_stream = output_stream.decode('utf-8')
    except UnicodeDecodeError:
        decoded_stream = output_stream.decode('iso8859-15')
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
        logger_warning('Unknown type for stream: {}'.format(type(stream)))
        return None


def regexp_in_stream_exists(stream, path, text=None, regexp=None, raise_exception=True):
    for x in __get_correct_for_loop_generator(regexp=regexp, text=text, stream=stream):
        return x
    if raise_exception:
        raise StreamDoesNotContainLineException('{} not in {}'.format(regexp if regexp else text, path))
    return None


def regexp_in_string_exists(string, text=None, regexp=None, raise_exception=True):
    if text and text in string:
        return True
    if regexp and re.search(regexp, string):
        return re.search(regexp, string)
    if raise_exception:
        raise StreamDoesNotContainLineException('{} not in {}'.format(regexp if regexp else text, string))
    else:
        return False


def convert_enum_to_list(enum, without_first_elem=False):
    rtn = [elem for idx, elem in enum]
    return rtn[1:] if without_first_elem else rtn


def check_sum_of_min_quotas_and_bwps_ratio(sum_of_min_quotas=0.0):
    rg_params = BuiltIn().get_variable_value('${RESOURCE_GROUP_PARAMS_DICT}')
    bwps_ratio = BuiltIn().get_variable_value('${MULTIPLE_BWPS_RATIO}')
    cell_tech = BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')

    for rg, params in rg_params.items():
        sum_of_min_quotas += float(params['quota']['min']) / float(100)

    bwps_ratio_cell_tech = bwps_ratio[cell_tech]['bwps_ratio']

    msg = 'Sum of min quotas should be bigger than ratio of small and large BWP. ' \
          'Actual values: bwps_ratio_cell_tech {}, sum_of_min_quotas {}'

    if bwps_ratio_cell_tech > sum_of_min_quotas:
        local_msg = msg.format(bwps_ratio_cell_tech, sum_of_min_quotas)
        logger_warning(local_msg)
        raise IncorrectSumOfMinimumQuotas(local_msg)


def regexp_item_in_stream(regexp, stream, item):
    gen = __get_correct_for_loop_generator(regexp=regexp, stream=stream)
    rtn = [match.group(item) for match in gen]
    return rtn


def map_item_id_to_its_content(items_list, item_id_regexp, item=None):
    if item is None:
        item_search = re.search('<(.*?)>', item_id_regexp)
        if item_search:
            item = item_search.group(1)
        else:
            raise ValueError('No items found!')
    item_ids = regexp_item_in_stream(regexp=item_id_regexp, stream=items_list, item=item)
    return {int(item_id): item_content for item_id, item_content in zip(item_ids, items_list)}


def split_by_regexp(regexp, string_to_split):
    return re.split(regexp, string_to_split)
