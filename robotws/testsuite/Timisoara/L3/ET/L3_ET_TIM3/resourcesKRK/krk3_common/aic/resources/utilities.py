"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Marcin Duplaga, Mateusz Michalik, Bartosz Bednarczyk
"""

from robot.api import logger
from datetime import datetime
import requests
import time
import os
import yaml
import json


class UrlDoesNotExistException(Exception):
    pass


def logger_console(msg, prefix=" [Console] ", timestamp=True):
    date = datetime.today().strftime('%Y/%m/%d %H:%M:%S') if timestamp is True else ""
    msg_final = "{}{}{}".format(date, prefix, msg)
    logger.console(msg_final)


def logger_console_info(msg, prefix_console=" [Console] ", prefix_info="[Info] ", timestamp=True):
    logger_console(msg, prefix=prefix_console, timestamp=timestamp)
    logger.info("{}{}".format(prefix_info, msg))


def logger_warning(msg, timestamp=True):
    date = datetime.today().strftime('%Y/%m/%d %H:%M:%S') if timestamp is True else ""
    msg_final = "{} {}".format(date, msg)
    logger.warn(msg_final)


def check_url_exists(url):
    """
    It checks if the given url exists and returns proper working code.

    :author: Mateusz Rzeczyca
    :param file_path: an url to check
    :return: nothing
    """
    request = requests.get(url)
    if request.status_code == 200:
        return True
    else:
        return False


def get_url_source_code(url):
    if not check_url_exists(url=url):
        raise UrlDoesNotExistException("URL does not exist: {}".format(url))

    logger_console("Returning source code of website {}".format(url))
    response = requests.get(url)
    return response.content.decode("utf-8")


def download_file_from_url(url, destination_path):
    logger_console("Downloading file {} from url {}".format(destination_path, url))
    resp = requests.get(url, allow_redirects=True)
    with open(destination_path, 'wb') as downloader:
        downloader.write(resp.content)


def sleep_with_msg(msg, period):
    """
    Sleeps for period due to some action

    :param msg: message of action
    :param period: period of time
    :return: nothing
    """
    logger_console('Will sleep for {}s due to *{}*'.format(period, msg))
    time.sleep(period)


def get_newest_file_in_vm_directory(directory):
    """Get newest file in VM directory

    :param directory
    :return: output with newest file in directory
    """
    files = os.listdir(directory)
    paths = [os.path.join(directory, basename) for basename in files]
    return max(paths, key=os.path.getctime)


def get_yaml_as_dict(yaml_path):
    with open(yaml_path, 'r') as stream:
        data_loaded = yaml.safe_load(stream)
    return data_loaded


def get_ip_for_external_network(yaml_path, component_type, vl_name):
    data_loaded = get_yaml_as_dict(yaml_path)
    return [i for i in data_loaded["global"]["externalNetwork"][component_type]["vlanInfo"]
            if i['vlName'] == vl_name][0]["ipInfo"][0]["rangeStart"]


def get_build_info_from_aicdockerknife_json():
    with open(
        "/home/ute/testline_init_results/config_files/aicdockerknife_params.json"
    ) as aicdockerknife_params:
        aicdockerknife_params = json.load(aicdockerknife_params)

    return {
        'vdu': {
            'build': aicdockerknife_params['vdu_build'],
            'major': aicdockerknife_params['vdu_build'].split('.')[0],
            'minor': aicdockerknife_params['vdu_build'].split('.')[1]
        },
        'vcu': {
            'build': aicdockerknife_params['vcu_build'],
            'major': aicdockerknife_params['vcu_build'].split('.')[0],
            'minor': aicdockerknife_params['vcu_build'].split('.')[1]
        }
    }
