# -*- coding: utf-8 -*-
"""
:author: Bartosz Bugaj
:contact: bartosz.bugaj@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""

from requests import Session
from requests.packages.urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter
from robot.api import logger

from .base import BaseSmuggler


class WebSmuggler(BaseSmuggler):
    """ Class for handling web copying """

    def __init__(self, smuggler_name):
        """

        :param str smuggler_name: name of smuggler
        """
        super(WebSmuggler, self).__init__(smuggler_name)

    def copy_file(self, source, destination):
        """ Copies file from web source to local destination

        :param str source: local source path
        :param str destination: local destination path
        :return: output of command
        :rtype: str
        """
        logger.debug("Copying file from {} to {}".format(source, destination))
        downloaded_file = self.download_file(source, destination)
        return downloaded_file

    @staticmethod
    def download_file(url, destination):
        """ Downloads file to given destination

        :param str url: link location
        :param str destination: local destination
        :return: str local path to downloaded file
        """
        session = Session()
        retries = Retry(
            total=5, backoff_factor=3, status_forcelist=[404, 500, 502, 503, 504]
        )
        session.mount("https://", HTTPAdapter(max_retries=retries))
        session.mount("http://", HTTPAdapter(max_retries=retries))

        response = session.get(url, stream=True)
        response.raise_for_status()

        # log how much data is to be downloaded
        logger.debug(
            "file total size: {0}".format(response.headers.get("content-length"))
        )

        with open(destination, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        return destination
