"""
:description: General KWs
:copyright: Nokia Networks
:author: Alexandru Stamp
:contact: alexandru.stamp@nokia.com
:maintainer: I_BTSAUTO_DEV_TSR@internal.nsn.com
:contact: I_BTSAUTO_DEV_TSR@internal.nsn.com
"""

import json
import logging
import re
from unittest.mock import MagicMock
from robot.libraries.BuiltIn import BuiltIn
import zipfile
from lxml import etree
from glob import iglob
from os import path
import subprocess
import datetime
import pytz
import os


def _filter_alarms(alarms_list, filter_patterns, simplified_dictionary=None, use_pattern_once=True):
    """
    Filter Alarms based on a supplied pattern
    :param alarm_list: alarm list
    :param filter_patterns: patterns to filter the alarms
    :param simplified_dictionary: if set, define which keys of alarms should be printed in the report
    :return: alarms that mathced, alarms that were not matched, patterns that were not matched
    """
    matched_alarms = []
    left_patterns = filter_patterns[:]
    left_alarms = alarms_list[:]
    for alarm in alarms_list:
        pretty_alarm = _make_pretty_alarm(alarm, simplified_dictionary) if simplified_dictionary else alarm
        logging.debug('Alarm under test: {}'.format(pretty_alarm))
        for pattern in left_patterns:
            logging.debug('Pattern to match: {}'.format(pattern))
            if _matching_dicts(pattern, alarm):
                logging.debug('Alarm matched pattern')
                matched_alarms.append(alarm)
                left_alarms.remove(alarm)
                if use_pattern_once:
                    left_patterns.remove(pattern)
                break
        else:
            logging.debug('Alarm doesnt match any pattern from: {}'.format(left_patterns))
    return matched_alarms, left_alarms, left_patterns


def _matching_dicts(pattern_dict, source_dict):
    """
    Check if a source dict matches a pattern dict
    :param pattern_dict: pattern dictionary
    :param source_dict: dictionary that will be checked
    :return: boolean based on matching
    """
    for key, value in pattern_dict.items():
        if isinstance(value, dict):
            _match = _matching_dicts(value, source_dict.get(key, {}))
        elif isinstance(value, list):
            _match = value == source_dict.get(key, [])
        else:
            _match = bool(re.search(str('^{}$'.format(value)), str(source_dict.get(key, ''))))
        logging.debug('Key to check: {}, result: {} ({} vs {})'.format(key, _match, str(value),
                                                                       str(source_dict.get(key, ''))))
        if not _match:
            return False
    return True


def _make_pretty_alarm(source_dict, recogn_dict=None):
    """
    Check if a source dict matches a pattern dict
    :param pattern_dict: pattern dictionary
    :param source_dict: dictionary that will be checked
    :return: boolean based on matching
    """
    new_dict = {}
    for key, value in recogn_dict.items():
        if isinstance(value, dict):
            new_dict[key] = _make_pretty_alarm(source_dict.get(key, {}), value)
        else:
            new_dict[key] = str(source_dict.get(key, ''))
    return new_dict


def convert_tuple_to_dict(set_tuple, new_keys=list()):
    """
    Convert tuple to dictionary combining values from set_tuple with keys from new_keys respectively to their
    indexes
    :param set_tuple: given tuple or list
    :param new_keys: list of keys to use, if not set, element's indexes will be used as keys
    :return: Dictionary containing values from set_tuple under keys from new_keys respectively to their indexes
    """
    converted_dict = {}
    for index, element in enumerate(set_tuple):
        new_key = get_list_element(new_keys, index, index)
        converted_dict[new_key] = element

    return converted_dict


def get_list_element(some_list, element_index, default=None):
    """
    Return the element with given index if exist in list, else default. If default is not given, it defaults to
    None, so that this method never raises a IndexError.
    :param some_list: given tuple or list
    :param element_index : element index to get
    :param default : default value of element not existing on list
    :return: list element or default
    """
    try:
        element = some_list[element_index]
    except IndexError:
        element = default
    return element


def list_diff(a, b):
    """
    This method converts two lists into sets and then calculates the difference between them.
    :param a: first given tuple or list
    :param b: second given tuple or list
    :return: list that consists the difference between two provided lists
    """
    return list(item for item in a if item not in b)


def check_if_cloud_run():
    """
    This method checks if the current execution is running in Cloud Manager environment.
    :return: True if the execution is running in Cloud Manager environment, False otherwise
    """
    command = "ps -ef | grep 'agent_robot run' | grep -v grep"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode == 0:
        BuiltIn().set_test_variable('${CM_RUN_ENV}', True)
        return True
    else:
        BuiltIn().set_test_variable('${CM_RUN_ENV}', False)
        return False


def get_tl_from_vm_host():
    command = "hostname | awk -F'-' '{print $1\"_\"$2\"_\"$3}'"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout
    else:
        return 'NA'


def get_cm_context_variables(variable='CM_TOPOLOGY_NAME', context_file_path='/opt/ute/execution.context.json'):
    """
    This method returns requested variable value from *context.json. These files is only relevant
    during Cloud Manager executions.
    :param variable: variable to extract from execution.context.json
    :param context_file_path: variable containing path to *context.json file
    :return: value of variable from execution.context.json or 'NA' if it doesn't exist
    """
    cm_run_env = BuiltIn().get_variable_value('${CM_RUN_ENV}', 'NA')
    if cm_run_env in ['NA', False]:
        return 'NA'
    try:
        with open(context_file_path) as execution_context_file:
            execution_context_variables = json.load(execution_context_file)
            return execution_context_variables[variable]
    except (IOError, KeyError):
        return 'NA'


def create_mock_object():
    """
    This method create a mock object
    """
    return MagicMock()


def get_newest_file_from_directory(path_to_search, pattern):
    return max(iglob(path.join(path_to_search, pattern)),
               key=path.getmtime)


def get_node_attribute_value(node_name, path, path_within_zip):
    zf = zipfile.ZipFile(path, 'r')
    for name in zf.namelist():
        if re.match(r"{}.*\.xml".format(path_within_zip), name):
            file_content = zf.read(name)
            tree = etree.fromstring(file_content)
            value = tree.get(node_name)
            return value
    raise IOError


def get_targetbd_node_attribute_value(node_name, path):
    targetbd_path = "bts_sw/TargetBD"

    try:
        node_value = get_node_attribute_value(node_name, path, targetbd_path)
        logging.info("{} found.".format(path))

    except IOError:
        logging.error("No such file under given path: {}.".format(path))
        return None

    if not node_value:
        logging.error("No such param in TargetBD: {}.".format(node_name))
        return None
    else:
        logging.info("{} = {}".format(node_name, node_value))
        return node_value


def get_timestamp():
    now = datetime.datetime.now(pytz.utc)
    timestamp = now.isoformat()
    return timestamp


def get_cm_decoupling_tags(decoupling_tag="SM_BUILD"):
    cm_tags = json.loads(os.getenv("CM_TAGS", "[]"))
    decoupling_builds = {}
    for cm_tag in cm_tags:
        if cm_tag.split("=")[0] == decoupling_tag:
            if cm_tag.split(":")[-1]:
                decoupling_builds[cm_tag.split(":")[-1]] = cm_tag.split("=")[1].split(":")[0]
    return decoupling_builds


def get_bts_decoupling_build(bts_label, decoupling_tag="SM_BUILD"):
    decoupling_tags = get_cm_decoupling_tags(decoupling_tag=decoupling_tag)
    if bts_label.split("BTS")[1]:
        return decoupling_tags.get(bts_label.split("BTS")[1], "")
