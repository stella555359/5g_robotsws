# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
"""
import re
from contextlib import contextmanager

from robot.api import logger


class SwConfigFlag(object):
    """Class used to handle and represent swconfig flag"""

    def __init__(self, data, comment=None):
        """
        :param _sre.SRE_Match|dict data: data for flag from regex matches or dict
            in case of dictionary, the format is:
            {'flag': <flag_name>,
            'value': <flag_value>,
            'active': <bool>}

            in case of regex matches, groups are:
            1: flag status (active/non-active)
            2: flag name
            3: flag value
            4: potential inline comment
        :param str comment: comment for flag
        """
        self.flag = None
        self.value = None
        self.active = None
        self.comment = None
        if isinstance(data, dict):
            self._create_from_dict(data, comment)
        else:
            self._inline_comment = None
            self._parse_data(data, comment)

    def _create_from_dict(self, data, comment):
        """Fills flag information from given dictionary

        :param dict data: dictionary with parameters for flag
        :param str comment: comment for flag
        """
        self.flag = data["flag"]
        self.value = data["value"]
        self.active = data["active"]
        self.comment = comment

    def _parse_data(self, data, comment):
        """Parses regex matches to appriopriate attributes

        :param _sre.SRE_Match data: results from re.search
        :param str comment: flag's comment
        """
        self._parse_flag(data)
        self._parse_value(data)
        self._parse_is_active(data)
        self._parse_inline_comment(data)
        self._combine_comments(comment)

    def _parse_flag(self, data):
        """Gets flag name and sets to attribute

        :param _sre.SRE_Match data: results from re.search
        """
        self.flag = data.group(2).strip()

    def _parse_value(self, data):
        """Gets flag value and sets to attribute

        :param _sre.SRE_Match data: results from re.search
        """
        self.value = data.group(3).strip()

    def _parse_is_active(self, data):
        """Gets flag status and sets to attribute

        :param _sre.SRE_Match data: results from re.search
        """
        self.active = False if data.group(1) == "#" else True

    def _parse_inline_comment(self, data):
        """Gets flag's inline comment sets to attribute

        :param _sre.SRE_Match data: results from re.search
        """
        self._inline_comment = data.group(4).strip()

    def _combine_comments(self, comment):
        """Combines possible inline comment with direct comment (above flag) to one comment

        :param str comment: flag's comment
        """
        tmp_comment = "{}{}".format(comment, self._inline_comment) if comment is not None else self._inline_comment
        self.comment = tmp_comment.strip() if tmp_comment != "" else None


def add_swconfig_flag(flag, value, swconfig_path, active=True, comment=None):
    """Modifies given swconfig file by adding specified flag to it

    :param str flag: name of flag, for example: 0x45005a
    :param str value: value of flag, for example: 0x1000000
    :param str swconfig_path: path to swconfig file
    :param bool active: if True - then flag is active, otherwise it's commented out
    :param comment: if set, then given comment will be added above flag
    """
    with swconfig_operations(swconfig_path) as flags_dictionary:
        __add_flag(flags_dictionary, flag, value, active, comment)


def activate_swconfig_flag(flag, swconfig_path):
    """ " Modifies given swconfig file by activating specified flag (uncommenting it)

    :param str flag: name of flag, for example: 0x45005a
    :param str swconfig_path: path to swconfig file
    """
    with swconfig_operations(swconfig_path) as flags_dictionary:
        __change_status_of_flag(flags_dictionary, flag, True)


def deactivate_swconfig_flag(flag, swconfig_path):
    """Modifies given swconfig file by deactivating specified flag (commenting it out)

    :param str flag: name of flag, for example: 0x45005a
    :param str swconfig_path: path to swconfig file
    """
    with swconfig_operations(swconfig_path) as flags_dictionary:
        __change_status_of_flag(flags_dictionary, flag, False)


@contextmanager
def swconfig_operations(swconfig_path):
    """Context manager used to avoid code repetition.
    Operations are:
    - reading swconfig file
    - parsing flags
    -- user operations --
    - saving modified swconfig file

    :param str swconfig_path: path to swconfig file
    """
    swconfig_lines = __read_swconfig_lines(swconfig_path)
    flags = __parse_flags(swconfig_lines)
    yield flags
    __save_swconfig(swconfig_path, flags)


def __change_status_of_flag(flags, flag_name, active):
    """Changes status of flag (activate/deactivate), in case flag is not found in swconfig file then
    warning is displayed

    :param dict flags: dictionary with flag objects parsed from swconfig file
    :param str flag_name: name of flag, for example: 0x45005a
    :param bool active: if True - then flag is active, otherwise it's commented out
    """
    if flag_name in flags:
        flags[flag_name].active = active
    else:
        logger.warn("Flag couldn't be deactivated because it was not found!")


def __add_flag(flags, flag_name, value, active, comment=None):
    """Adds flag object to flags dictionary.
    In case flag already exists in dictionary, its value will be overwritten

    :param str flag_name: name of flag, for example: 0x45005a
    :param str value: value of flag, for example: 0x1000000
    :param bool active: if True - then flag is active, otherwise it's commented out
    :param comment: if set, then given comment will be added above flag
    :return:
    """
    if flag_name in flags:
        logger.warn("Flag `{}` already exists in swconfig. It will be overwritten with new values.".format(flag_name))
    flag = SwConfigFlag({"flag": flag_name, "value": value, "active": active}, comment)
    flags[flag_name] = flag


def __read_swconfig_lines(path):
    """Reads content of swconfig file as lines

    :param str path: path to swconfig file
    :return: list of lines from swconfig
    :rtype: list[str]
    """
    with open(path, "r") as f:
        return f.readlines()


def __parse_flags(file_lines):
    """Parses flags from swconfig file so they can be objectified

    :param list[str] file_lines: list of lines from swconfig file
    :return: dictionary with flag objects (SwConfigFlag), keys are flag names
    :rtype: dict
    """
    flags = {}
    for index, line in enumerate(file_lines):
        flag_data = __get_flag_data_from_line(line)
        if flag_data is not None:
            previous_line = file_lines[index - 1]
            sw_config_flag = __parse_sw_config_flag(flag_data, previous_line)
            flags[sw_config_flag.flag] = sw_config_flag
    return flags


def __get_flag_data_from_line(line):
    """Gets flag data from line by using regex search.

    :param str line: line from swconfig file
    :return: None if flag data is not found in the line, otherwise regex match result. Groups are:
        1: flag status (active/non-active)
        2: flag name
        3: flag value
        4: potential inline comment
    :rtype: _sre.SRE_Match
    """
    matches = re.search(r"^(#?)\s?(\d[xA-Z0-9]*)\s?=\s?([0-9xA-Z]+)(.*)$", line)
    return matches


def __parse_sw_config_flag(flag_data, previous_line):
    """Objectifies flag with result from regex matches and checks for comments in previous line

    :param _sre.SRE_Match flag_data: result from regex search
    :return: Objectified flag from swconfig file
    :rtype: SwConfigFlag
    """
    comment = __get_flag_comment(previous_line)
    sw_config_flag = SwConfigFlag(flag_data, comment)
    return sw_config_flag


def __get_flag_comment(line):
    """Checks if line (previous one) contains flag, if not then it tries to get comment from that line

    :param str line: line from swconfig file
    :return: flag's comment
    :rtype: str
    """
    if __get_flag_data_from_line(line) is None:
        comment = re.search(r"(?:#*\s*)(.*?)(?:\s*#*)$", line).group(1)
        return comment


def __save_swconfig(path, flags):
    """Saves swconfig file with modifications.
    Takes flags dictionary, converts each flag object to string and then whole string block is pushed to swconfig file

    :param str path: path to swconfig file
    :param dict flags: dictionary with flag objects (SwConfigFlag),
    """
    output = ""
    for flag in flags.values():
        output += __fill_flag_template(flag)
    with open(path, "w") as f:
        f.write(output)


def __fill_flag_template(flag):
    """Saves flag data as string. If flag contains comment then it's multiline string.
    Example of created flags:

    ### Some flag ###
    0x45005=0x10000

    ### Another flag ###
    # 123=1

    234=100

    :param SwConfigFlag flag: objectified flag
    :return: flag object as string
    :rtype: str
    """
    flag_template = "{comment}{status}{flag}={value}\n\n"
    output = flag_template.format(
        comment="### {} ###\n".format(flag.comment) if flag.comment is not None else "",
        status="# " if flag.active is False else "",
        flag=flag.flag,
        value=flag.value,
    )
    return output
