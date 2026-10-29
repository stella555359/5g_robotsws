"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
"""

import os
import requests
from pprint import pformat
from datetime import datetime

from robot.api import logger


class UrlDoesNotExistException(Exception):
    pass


def pprint(func):
    """
    Formats msg to pprint format if pprint=True is passed when calling function

    LIMITATION: plain variable should be passed for this to work correctly. If str cointaining variable is passed,
                then whole msg is formatted as str
    """
    def inner(msg, *args, **kwargs):
        if 'pprint' in kwargs.keys():
            msg = '\n' + pformat(msg) if kwargs['pprint'] is True else msg
            kwargs.pop('pprint')
        func(msg, *args, **kwargs)
    return inner


def add_timestamp_to_prefix(prefix=" [Console] ", timestamp=True, newline=False):
    date = datetime.today().strftime('%Y/%m/%d %H:%M:%S') if timestamp is True else ""
    date = '\n' + date if newline else date
    return "{}{}".format(date, prefix)


@pprint
def logger_console(msg, prefix=" [Console] ", timestamp=True, newline=False):
    prefix = add_timestamp_to_prefix(prefix=prefix, timestamp=timestamp, newline=newline)
    logger.console("{}{}".format(prefix, msg))


@pprint
def logger_info(msg, prefix="[Info] "):
    logger.info("{}{}".format(prefix, msg))


@pprint
def logger_debug(msg, prefix="[Debug] "):
    logger.debug("{}{}".format(prefix, msg))


@pprint
def logger_console_info(msg, prefix_console=" [Console] ", prefix_info=" [Info] ", timestamp=True, newline=False):
    logger_console(msg, prefix=prefix_console, timestamp=timestamp, newline=newline)
    logger_info(msg, prefix=prefix_info)


@pprint
def logger_warning(msg, timestamp=True):
    prefix = add_timestamp_to_prefix(prefix="", timestamp=timestamp)
    logger.warn("{} {}".format(prefix, msg))


@pprint
def logger_console_warning(msg, prefix_console=" [Console] ", prefix_info=" [Info] ", timestamp=True, newline=False):
    prefix = add_timestamp_to_prefix(prefix="", timestamp=timestamp)
    logger.warn("{} {}".format(prefix, msg))
    logger_console(msg, prefix=prefix_console, timestamp=timestamp, newline=newline)


def get_current_date():
    return datetime.now().strftime("%d%m%Y_%H%M%S")


def check_url_exists(url):
    """
    It checks if the given url exists and returns proper working code.

    :author: Mateusz Rzeczyca
    :param url: an url to check
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


def get_newest_file_in_vm_directory(directory):
    """Get newest file in VM directory

    :param directory
    :return: output with newest file in directory
    """
    files = os.listdir(directory)
    paths = [os.path.join(directory, basename) for basename in files]
    return max(paths, key=os.path.getctime)
