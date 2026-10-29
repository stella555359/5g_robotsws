"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
"""
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import (
    logger_console, logger_console_info, logger_warning
)
import re


def get_regex_matches_from_syslog(regex, syslog_path, group=1, verbose=True):
    matches = []
    with open(syslog_path, "r") as syslog_file:
        for line in syslog_file.read().splitlines():
            match = re.search(pattern=regex, string=line)
            if match:
                if verbose:
                    logger.info("Line matched! {}".format(line))
                matches.append(match.group(group))
    return matches


def verify_syslog(regex_to_match, timeout=30, alias=None):
    """Verify syslog print via regex pattern matching

    :param regex_to_match: regex pattern compatible with POSIX extended (ERE); see for reference:
        https://remram44.github.io/regex-cheatsheet/regex.html
    :type regex_to_match: raw string
    :param timeout: timeout for waiting for the message
    :type timeout: integer
    :param alias: syslog alias provided by ta5g_syslog or ute_syslog library alias store
    :type alias: string, optional
    """
    if alias is None:
        alias = BuiltIn().get_variable_value("${SYSLOG_ALIAS}")
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    logger.info("Waiting for syslog: [{}]".format(regex_to_match))
    ta5g_syslog.wait_for_specified_message_in_syslog(msg_regexp=regex_to_match, timeout=timeout, alias=alias)
    logger.info("Syslog [{}] matched".format(regex_to_match))


def verify_syslog_for_given_number_of_msg(regex_to_match, number_of_messages, alias=None):
    """Verify syslog print via regex pattern matching for specified number of messages

    :param regex_to_match: regex pattern compatible with POSIX extended (ERE); see for reference:
        https://remram44.github.io/regex-cheatsheet/regex.html
    :type regex_to_match: raw string
    :param number_of_messages: number of messages to expect to occur
    :type number_of_messages: integer
    :param alias: syslog alias provided by ta5g_syslog or ute_syslog library alias store
    :type alias: string, optional
    """
    if alias is None:
        alias = BuiltIn().get_variable_value("${SYSLOG_ALIAS}")
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    logger.info("Checking syslog for {} lines of message: [{}]".format(number_of_messages, regex_to_match))
    ta5g_syslog.verify_syslog_for_given_number_of_messages(
        regexp=regex_to_match,
        number_of_messages=number_of_messages,
        alias=alias
    )
    logger.info("Found required number of prints")


def verify_syslog_for_at_least_given_number_of_msg(regex_to_match, number_of_messages, alias=None):
    """Verify syslog print via regex pattern matching for at least specified number of messages

    :param regex_to_match: regex pattern compatible with POSIX extended (ERE); see for reference:
        https://remram44.github.io/regex-cheatsheet/regex.html
    :type regex_to_match: raw string
    :param number_of_messages: number of messages to expect to occur
    :type number_of_messages: integer
    :param alias: syslog alias provided by ta5g_syslog or ute_syslog library alias store
    :type alias: string, optional
    """
    if alias is None:
        alias = BuiltIn().get_variable_value("${SYSLOG_ALIAS}")
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    logger.info("Checking syslog for at least {} lines of message: [{}]".format(number_of_messages, regex_to_match))
    ta5g_syslog.verify_syslog_for_at_least_given_number_of_messages(
        regexp=regex_to_match,
        number_of_messages=number_of_messages,
        alias=alias
    )
    logger.info("Found required number of prints")


def verify_if_no_such_message_in_syslog_occurred(regex_to_match, alias=None):
    """Verify that the syslog print did not occur

    :param regex_to_match: regex pattern compatible with POSIX extended (ERE); see for reference:
        https://remram44.github.io/regex-cheatsheet/regex.html
    :type regex_to_match: raw string
    :param alias: syslog alias provided by ta5g_syslog or ute_syslog library alias store
    :type alias: string, optional
    """
    if alias is None:
        alias = BuiltIn().get_variable_value("${SYSLOG_ALIAS}")
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    logger.info("Checking syslog if line did not occur: [{}]".format(regex_to_match))
    ta5g_syslog.verify_syslog_for_no_messages(regexp=regex_to_match, alias=alias)
    logger.info("Checked print did not occur, which was expected")
