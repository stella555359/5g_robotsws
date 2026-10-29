# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Jacek Kozmic
:contact: jacek.kozmic@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from robot.libraries.BuiltIn import BuiltIn
from taf.collectors.syscomdump import syscomdump
from taf.collectors.tcpdump import tcpdump
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_console


class LogsNotSupportedError(Exception):
    pass


def _get_collector_dict(logs_type):
    logs_to_collector_mapping = {'syscomdump': {'collector': syscomdump(),
                                                'collector_function': syscomdump.create_syscomdump_collector},
                                 'tcpdump': {'collector': tcpdump(),
                                             'collector_function': tcpdump.create_tcpdump_collector},
                                 }
    try:
        return logs_to_collector_mapping[logs_type]
    except KeyError:
        raise LogsNotSupportedError('Provided logs type: {} is unsupported!'.format(logs_type))


def start_logs_capturing_via_taf(logs_types,
                                 hostname="192.168.255.129",
                                 username="toor4nsn",
                                 password="oZPS0POrRieRtu",
                                 **kwargs):
    """
    Starts capturing logs using TAF libraries.

    :param logs_types: a string or a list of strings, that are defined in _get_collector_dict function
    :param hostname: hostname of session on which the logs should be captured
    :param username: username of session on which the logs should be captured
    :param password: password of session on which the logs should be captured
    :return: None
    """
    if not all([hostname, username, password]):
        executor = None
    else:
        executor = {'host': hostname, 'user': username, 'password': password}
    if type(logs_types) is not list:
        logs_types = [logs_types]
    for logs_type in logs_types:
        collector_dict = _get_collector_dict(logs_type)
        collector = collector_dict['collector']
        collector_function = collector_dict['collector_function']
        logger_console('Starting {} logs capture.'.format(logs_type))
        collector_function(self=collector, name=logs_type, executor=executor, **kwargs)
        collector.setup_collectors(names=logs_type)
        collector.start_collectors(names=logs_type)
        collector.set_suite_alias(logs_type)


def stop_logs_capturing_via_taf(logs_types, output_dir=None):
    """
    Stops capturing logs using TAF libraries and copies it to output_dir/logs_type dire

    :param logs_types: a string or a list of strings, that are defined in _get_collector_dict function
    :param output_dir: general directory at which the folders with logs should be stored
    :return: None
    """
    if type(logs_types) is not list:
        logs_types = [logs_types]
    if output_dir is None:
        output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
    for logs_type in logs_types:
        collector_dict = _get_collector_dict(logs_type)
        collector = collector_dict['collector']
        logger_console("Stopping {} logs capture.".format(logs_type))
        collector.stop_collectors(names=logs_type)
        logger_console("Logs copied to {}.".format(output_dir))
        collector.collect_collectors(names=logs_type, target_dir=output_dir)
        collector.teardown_collectors(names=logs_type)
