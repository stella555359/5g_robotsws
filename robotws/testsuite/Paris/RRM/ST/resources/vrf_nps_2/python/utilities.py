#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
"""
import os
import json
import re
import datetime
import pytz
from robot.api import logger as robot_logger
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.internal.wireshark import installation as wireshark_installer


def update_json_file(json_file_path, dist_name, **parameters_values):
    """
    Updates a JSON file with a new value for a given parameterName.

    Args:
        file_path (str): The path to the JSON file.
        parameterName (str): The name of the parameter to update.
        value (any): The new value for the parameter.

    Returns:
        None
    """

    with open(json_file_path, 'r+') as f:
        data = json.load(f)

        # Find the parameter in the 'parameters' list

        for item in data:
            if item['distName'] == dist_name:
                for parameterName, value in parameters_values.items():
                    # Find the parameter in the 'parameters' list
                    for parameter in item['parameters']:
                        if parameter['parameterName'] == parameterName:
                            parameter['value'] = value
                            break

        # Rewind the file pointer to the beginning
        f.seek(0)
        # Write the updated data back to the file
        json.dump(data, f, indent=4, ensure_ascii=False)


def extract_version(content, plugin_name):
    """Extracts the version number from a string using a regular expression.

      Args:
        text: The string to search.

      Returns:
        The extracted version number as a string, or None if no match is found.
      """
    match = re.search(r'{}-([0-9.]+)'.format(plugin_name), content)
    if match:
        return match.group(1)
    else:
        return 'latest'


def install_wireshark_plugin(build_version, force=False):
    # wireshark_installer.SCRIPT_TARGET_DIR = os.path.expanduser("~")
    # getting info
    content = wireshark_installer._get_url_content(f"https://wft.int.net.nokia.com/ext/build_content/{build_version}")
    nsetap_version = extract_version(
        content,
        wireshark_installer.AVAILABLE_SCRIPT_PLUGINS_TO_SCRIPT_OPTION["nsetap"]['plugin_name']
    )
    nsetapx_version = extract_version(
        content,
        wireshark_installer.AVAILABLE_SCRIPT_PLUGINS_TO_SCRIPT_OPTION["nsetapx"]['plugin_name']
    )
    # Installation of plugin
    wireshark_installer.install_mcshark(build_version, force=force)
    wireshark_installer.install_plugin(
        wireshark_installer.AVAILABLE_SCRIPT_PLUGINS_TO_SCRIPT_OPTION["nsetap"]['plugin_name'],
        version=nsetap_version,
        force=force
    )
    wireshark_installer.install_plugin(
        wireshark_installer.AVAILABLE_SCRIPT_PLUGINS_TO_SCRIPT_OPTION["nsetapx"]['plugin_name'],
        version=nsetapx_version,
        force=force
    )


def number_open_files(user):
    p1 = os.popen("lsof -u {}".format(user))
    p1 = p1.read()
    p2 = p1.count("\n")
    return p2


def all_system_open_files():
    p1 = os.popen("lsof /dev/null")
    p1 = p1.read()
    p2 = p1.count("\n")
    return p2


def is_ute_cm_execution():
    return bool(os.environ.get("CM_EXECUTION_ID"))


def print_openfile_log(keyword):
    robot_logger.debug("{} number of openfiles for ute: {}".format(keyword, number_open_files("ute")))
    robot_logger.debug("{} number of openfiles for root: {}".format(keyword, number_open_files("root")))
    robot_logger.debug("{} number of /dev/null openfiles: {}".format(keyword, all_system_open_files()))


def get_folder_from_path(file_path):
    """
    Gets the folder path from a given file path.

    Args:
        file_path (str): The path to the file.

    Returns:
        str: The folder path.
    """
    return os.path.dirname(file_path)


def get_configured_cells_info(bts_info, rantype='nr'):
    cellsInfo = []
    for cell in bts_info['cells'][rantype]:
        if cell['status'].get('proceduralStatus', '').lower() == 'configured':
            cellsInfo.append({cell['id']['configuration']: cell['status']})
    return cellsInfo


def get_online_cells_info(bts_info, rantype='nr'):
    online_cell = {'administrativeState': 'Unlocked',
                   'operationalState': 'enabled',
                   'proceduralStatus': 'configured',
                   'usageState': 'Active'}
    cellsInfo = []
    for cell in bts_info['cells'][rantype]:
        if cell['status'].get('operationalState', '').lower() == 'enabled' and \
                cell['status'].get('usageState', '').lower() == 'active' and \
                cell['status'].get('administrativeState', '').lower() == 'unlocked' and \
                cell['status'].get('proceduralStatus', '').lower() == 'configured':
            cellsInfo.append({cell['id']['configuration']: cell['status']})
    return cellsInfo


def get_local_Timestamp():
    # Get the current local time
    return datetime.datetime.now(pytz.utc).isoformat()
