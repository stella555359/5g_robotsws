"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

from robot.libraries.BuiltIn import BuiltIn
from ta5g_enb.html_method_logger import log_method_name
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens import Tokens
from robot.api import logger
from datetime import datetime
import requests


tokens = Tokens()


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


def get_current_date():
    return datetime.now().strftime("%d%m%Y_%H%M%S")


def check_url_exists(url, use_token=False):
    """
    It checks if the given url exists and returns proper working code.

    :author: Mateusz Rzeczyca
    :param file_path: an url to check
    :param use_token: whether to use bearer token for authentication
    :return: nothing
    """
    headers = tokens.authorization_bearer_token if use_token else None
    request = requests.get(url, headers=headers)
    if request.status_code == 200:
        return True
    else:
        return False


def get_url_source_code(url, use_token=False):

    if not check_url_exists(url=url, use_token=use_token):
        raise UrlDoesNotExistException("URL does not exist: {}".format(url))

    logger_console("Returning source code of website {}".format(url))
    headers = tokens.authorization_bearer_token if use_token else None
    response = requests.get(url, headers=headers)
    return response.content.decode("utf-8")


def download_file_from_url(url, destination_path, use_token=False):
    logger_console("Downloading file {} from url {}".format(destination_path, url))
    headers = tokens.authorization_bearer_token if use_token else None
    resp = requests.get(url, allow_redirects=True, headers=headers)
    with open(destination_path, 'wb') as downloader:
        downloader.write(resp.content)
