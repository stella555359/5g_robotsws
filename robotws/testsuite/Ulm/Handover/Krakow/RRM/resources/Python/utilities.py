"""
:copyright: Nokia Networks
:author: Mateusz Plinta, Dawid Krawczuk, Marek Kieltyka
:maintainer: Mateusz Plinta, Dawid Krawczuk, Marek Kieltyka
:contact: mateusz.plinta@nokia.com, dawid.krawczuk@nokia.com, marek.kieltyka@nokia.com
"""
import re
import ast

from robot.libraries.BuiltIn import BuiltIn
from ta5g_enb.html_method_logger import log_method_name
from robot.api import logger
from datetime import datetime
from robot.utils import unic


def logger_console(msg, prefix=" [Console] ", timestamp=True):
    date = datetime.today().strftime('%Y/%m/%d %H:%M:%S') if timestamp is True else ""
    msg_final = "{}{}{}".format(date, prefix, msg)
    logger.console(msg_final)


def logger_console_info(msg, prefix_console=" [Console] ", prefix_info="[Info] ", timestamp=True):
    logger_console(msg, prefix=prefix_console, timestamp=timestamp)
    logger.info("{}{}".format(prefix_info, msg))


def get_current_date():
    return datetime.now().strftime("%d%m%Y_%H%M%S")


def split_to_list(string, separator=','):
    return [s.strip() for s in str(string).strip().split(separator)] if string else []


def split_to_integers_tuple(string, separator=','):
    if not string:
        return None

    tmp_tuple = tuple(int(s) for s in str(
        string).strip().split(separator)) if string else ()
    return tmp_tuple if len(tmp_tuple) > 1 else '({})'.format(tmp_tuple[0])


def create_list_of_the_same_elements(element, list_length):
    return [element]*int(list_length)


def add_to_string(base="", to_add="", separator=','):
    if not base:
        return to_add
    else:
        return "{}{}{}".format(base, separator, to_add)


def add_strings(*items):
    """Similar to BuiltIn.Catenate, catenates the given items together and returns the resulted string.
    Empty items are skipped to not generate multiple spaces.
    """
    if not items:
        return ''
    items = [unic(item) for item in items if item != '']
    if items[0].startswith('SEPARATOR='):
        sep = items[0][len('SEPARATOR='):]
        items = items[1:]
    else:
        sep = ' '
    return sep.join(items)


def demap_string_with_given_mapping(string, mapping, separator=',', return_as_string=True):
    return_as_string = True if str(
        return_as_string).lower() == 'true' else False
    assert isinstance(
        mapping, dict), 'Mapping must be a dict, not: {}'.format(type(mapping))
    string_list = [s.strip() for s in str(string).split(separator)]
    demaped_list = []
    for str_item in string_list:
        assert str_item in mapping, 'Item: {} not present in mapping: {}'.format(
            str_item, list(mapping.keys()))
        demaped_list.append(mapping[str_item])
    if return_as_string:
        return separator.join(demaped_list)
    else:
        return demaped_list


def map_message_value_to_ta_messaging_used_value(value):
    try:
        new_value = int(value)
        return new_value
    except Exception as e:
        pass
    if value[-2:] == "'H":
        return '"0x{}"'.format(value[1:-2])
    elif value[-2:] == "'B":
        return '"0b{}"'.format(re.sub(r'\s', '', value[1:-2]))
    else:
        return '"{}"'.format(value)


def build_messaging_query_for_list_having_the_same_ies(list_in_msg, ie, ie_values):
    query = '('
    for i in range(len(ie_values)):
        query += '({} contains ({} eq {}))'.format(list_in_msg,
                                                   ie, ie_values[i])
        query += ' and ' if i != len(ie_values)-1 else ')'

    return query


def val_to_bool(val):
    try:
        return re.sub(r'\$|\{|\}', '', str(val).lower().strip()) == "true"
    except Exception:
        return False


def val_remove_quotes(val):
    return re.sub(r'\'|\"', '', val)


def convert_to_list_from_json_string(list_string):
    try:
        return ast.literal_eval(list_string)
    except SyntaxError:
        raise AssertionError("Invalid JSON format")


def get_parent_mo_path(dist_name):
    return dist_name[:dist_name.rfind('/')]


def get_last_mo_name_from_path(dist_name):
    return dist_name[dist_name.rfind('/')+1:dist_name.rfind('-')]


def get_last_mo_name_with_id_from_path(dist_name):
    return dist_name[dist_name.rfind('/')+1:]


def get_instance_id_for_mo(dist_name):
    return int(dist_name[dist_name.rfind('-')+1:])


def check_if_counter_value_is_in_range(value, lower, higher):
    r = range(int(lower), int(higher)+1)
    return True if int(value) in r else False


def get_id_index_from_alias(alias):
    ret = re.findall(r'\d+', alias)
    assert len(
        ret) == 1, 'Alias: {} does not have any digit or have mutiple numbers inside'.format(alias)
    return ret[0]


def get_bin_value_from_dec(dec_value, bin_length):
    return bin(int(dec_value))[2:].zfill(int(bin_length))


def convert_first_letter(value, lower=True):
    """
    Coverts first letter to lower (default) or upper (lower=False)
    """
    lower = val_to_bool(lower)
    return "{}{}".format(value[0].upper() if lower is False else value[0].lower(), value[1:])


def convert_to_bin_from_ip(ip, with_format=False, version='ipv4'):
    if version == 'ipv4':
        sign = '.'
        num_of_bits = 8
    elif version == 'ipv6':
        sign = ':'
        num_of_bits = 16
    else:
        raise Exception("Only ipv4 or ipv6 version is supported")

    list_dec = [int(x) for x in ip.split(sign)]
    list_bin = [format(x, 'b').zfill(num_of_bits) for x in list_dec]
    ip_bin = ''.join(list_bin)
    if with_format:
        ip_bin = '0b' + ip_bin
    return ip_bin


def convert_to_ip_from_bin(ip_bin, with_format=False, version='ipv4'):
    if version == 'ipv4':
        sign = '.'
        num_of_bits = 8
    elif version == 'ipv6':
        sign = ':'
        num_of_bits = 16
    else:
        raise Exception("Only ipv4 or ipv6 version is supported")
    if with_format:
        ip_bin = ip_bin[2:]
    ip = ''
    group_of_bits = re.findall('.' * num_of_bits, ip_bin)
    for group in group_of_bits:
        tmp = int(group, base=2)
        ip = ip + str(tmp) + sign
    ip = ip[:-1]
    return ip
