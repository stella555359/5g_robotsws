"""
:copyright: Nokia Networks
:author: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:maintainer: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:version: 0.1
"""

import os
import zipfile
import requests
import re
import subprocess
from robot.api import logger


class LuaHandling:

    def __init__(self):
        pass

    def download_luashark(self, sw_version, destination_dir, tmp_dir="/tmp/luashark", chunk_size=128,
                          user_url=None):
        """
        Downloads luashark from https://artifactory-espoo1.int.net.nokia.com/artifactory/
        mnp5g-central-public-local/System_Release or user defined URL.

        :param sw_version: Version of SW for which luashark should be downloaded.
               e.g. 5G21B_GNB_0000_000800_003537
        :param destination_dir: Absolute path to directory where luashark should
               be saved, e.g. "/home/ute/Downloads/test"
        :param tmp_dir: Absolute path to directory where luashark should
               be downloaded. Default value: "/tmp/luashark"
        :param chunk_size: The number of bytes that should be read into
               memory at a time during luashark downloading. Default value: 128
        :param user_url: User defined URL. Optional alternative URL to luashark
               ZIP file, e.g. https://artifactory-espoo1.int.net.nokia.com/artifactory/
               mnp5g-central-public-local/System_Release/11.800.324/luashark-11.800.324.zip
        """
        tmp_luashark_dir = self._download_file(
            sw_version, tmp_dir, chunk_size, user_url)
        self._unzip_file(tmp_luashark_dir, os.path.join(
            destination_dir, "luashark"))

    @staticmethod
    def download_mcshark(sw_version, destination_dir, file_name=None, tmp_dir="/tmp/mcshark",
                         chunk_size=128, user_url=None):
        """
        Downloads MCShark from https://artifactory-hz1.int.net.nokia.com/
        artifactory/mcshark-local/ or user defined URL. At the beginning
        all files in destination_dir that match regular expression:
        '.*mcshark.*' (case insensitive) will be removed. If user_url
        is not used it checks version of tshark with 'tshark --version'
        command and based on the output it downloads respective version of MCShark.

        :param sw_version: Version of SW for which MCShark should be downloaded.
               e.g. 5G21B_GNB_0000_000800_003537
        :param destination_dir: Absolute path to directory where MCShark should
               be saved, e.g. "/home/ute/Downloads/test"
        :param file_name: Name of MCShark file which should be downloaded,
               e.g. "mcshark-3.4-1.14.1-SBTS00_ENB_9999_220201_000005+buster.so"
        :param tmp_dir: Absolute path to directory where MCShark should
               be downloaded. Default value: "/tmp/mcshark"
        :param chunk_size: The number of bytes that should be read into
               memory at a time during MCShark downloading. Default value: 128
        :param user_url: User defined URL. Optional alternative URL to MCShark
               file, e.g. https://artifactory-espoo1.int.net.nokia.com/artifactory/
               mnp5g-central-public-local/System_Release/11.800.324/luashark-11.800.324.zip
        """

        # removing old MCShark files
        file_paths = [
            os.path.join(root, f_name)
            for root, dirs, files in os.walk(destination_dir)
            for f_name in files
            if re.findall(".*mcshark.*", f_name, re.IGNORECASE)
        ]
        logger.debug("file path = {}".format(file_paths))
        if len(file_paths) == 0:
            logger.debug("There were no files found with name "
                         "matching regex '.*mcshark.*' (case insensitive)"
                         " in destination directory: {}. Now downloading"
                         " will be performed.".format(destination_dir))
        else:
            for file_path in file_paths:
                logger.debug("Removing file: {}".format(file_path))
                logger.console("Removing file: {}".format(file_path))
                os.system("sudo rm {}".format(file_path))
            file_paths = [
                os.path.join(root, f_name)
                for root, dirs, files in os.walk(destination_dir)
                for f_name in files
                if re.findall(".*mcshark.*", f_name, re.IGNORECASE)
            ]
            logger.debug("file path = {}".format(file_paths))
            if len(file_paths) != 0:
                raise Exception("Unable to remove MCShark files "
                                "from destination directory: {}\n"
                                "Files list:".format(destination_dir, file_paths))
            else:
                logger.debug("Old MCShark files were successfully removed "
                             "from destination directory.")
                logger.console("Old MCShark files were successfully removed "
                               "from destination directory.")
        # creating url
        if user_url:
            url = user_url
        else:
            url_part = "https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/{}/"\
                .format(sw_version)
            if file_name:
                mcshark_file = file_name
            else:
                tshark_version_stdout = subprocess.check_output(
                    "tshark -v", shell=True, stderr=subprocess.STDOUT)
                logger.debug(
                    "Output from \'tshark -v\':\n{}".format(tshark_version_stdout))
                tshark_version = re.findall(r'TShark.+\s(\d+\.\d+)',
                                            tshark_version_stdout.splitlines()[0].decode('utf-8'))[0]
                logger.console("TShark version: {}".format(tshark_version))
                logger.debug("TShark version: {}".format(tshark_version))

                logger.debug(url_part)
                logger.console(url_part)
                r = requests.get(url_part)
                if r.status_code == 200:
                    url_text = r.text
                    logger.debug("url_text = {}".format(url_text))
                    mcshark_files = re.findall("href.+so\"\\>(mcshark-{}-.+\\+buster"
                                               "\\.so)\\<\\/a\\>".format(tshark_version), url_text)
                    logger.console("match = {}".format(mcshark_files))
                    size = len(mcshark_files)
                    if size == 1:
                        mcshark_file = mcshark_files[0]
                    elif size == 0:
                        logger.debug('No match found')
                        raise Exception("Match for regular expression: 'href.+so\"\\>"
                                        "(mcshark.+\\+buster\\.so)\\<\\/a\\>"
                                        "was not found inside string: {}".format(url_text))
                    elif size > 1:
                        logger.debug('Too many matching files.')
                        raise Exception("Too many matching files were found "
                                        "for regular expression: 'href.+so\"\\>"
                                        "(mcshark.+\\+buster\\.so)\\<\\/a\\>"
                                        "inside string: {}".format(url_text))
            url = "{}/{}".format(url_part, mcshark_file)

        # downloading MCShark
        logger.debug("url = {}".format(url))
        logger.console("url = {}".format(url))
        r = requests.get(url, stream=True)
        logger.debug("r = {}".format(r))
        if not os.path.exists(tmp_dir):
            os.makedirs(tmp_dir)
        if r.status_code == 200:
            try:
                mcshark_file
            except NameError:
                mcshark_file = url.split("/")[-1]
                logger.debug(
                    "File name extracted from url: {}".format(mcshark_file))
            logger.debug("File exists at {}. Starting download"
                         " to path {}/{}".format(url, tmp_dir, mcshark_file))
            with open(os.path.join(tmp_dir, mcshark_file), 'wb') as fd:
                for chunk in r.iter_content(chunk_size=chunk_size):
                    fd.write(chunk)
        else:
            logger.debug("File not found at {}".format(url))
            logger.debug(r.status_code)
            raise Exception("MCShark file not found at URL: {}".format(url))

        logger.debug("Copying file to destination directory. "
                     "Destination file path: {}".format(os.path.join(
                         destination_dir, mcshark_file)))
        os.system("sudo scp {} {}".format(os.path.join(tmp_dir, mcshark_file),
                                          os.path.join(
                                              destination_dir, mcshark_file)
                                          )
                  )

    @staticmethod
    def find_xpshark(luashark_dir):
        """
        Find absolute path for xpshark.lua.

        :param luashark_dir: Absolute path to one of parent directories
               under which xpshark.lua can be found.
        :return absolute path to xpshark.lua
        """
        file_path = [
            os.path.join(root, file_name)
            for root, dirs, files in os.walk(luashark_dir)
            for file_name in files if file_name == "xpshark.lua"
        ]
        try:
            file_path[0]
        except IndexError:
            logger.debug("There were no paths found to xpshark.lua.")
            raise Exception("There were no paths found to xpshark.lua.")
        else:
            try:
                file_path[1]
            except IndexError:
                logger.debug(
                    "Localization of xpshark.lua: {}".format(file_path[0]))
                logger.console(
                    "Localization of xpshark.lua: {}".format(file_path[0]))
            else:
                logger.debug("There were multiple paths found to xpshark.lua.")
                raise Exception(
                    "There were multiple paths found to xpshark.lua.")
        return file_path[0]

    @staticmethod
    def _download_file(sw_version, tmp_dir="/tmp/luashark", chunk_size=128, user_url=None):
        if user_url:
            url = user_url
        else:
            url = "http://files.ute.nsn-rdnet.net/builds/enb/base/{}/{}_luashark.zip".format(
                sw_version, sw_version)

        logger.debug("url = {}".format(url))
        logger.console("url = {}".format(url))
        r = requests.get(url, stream=True)
        logger.debug("r = {}".format(r))
        if not os.path.exists(tmp_dir):
            os.makedirs(tmp_dir)
        if r.status_code == 200:
            logger.debug("File exists at {}. Starting download"
                         " to path {}/luashark-{}.zip".format(url, tmp_dir, sw_version))
            with open(os.path.join(tmp_dir, "luashark-{}.zip".format(sw_version)), 'wb') as fd:
                for chunk in r.iter_content(chunk_size=chunk_size):
                    fd.write(chunk)
        else:
            logger.debug("File not found at {}".format(url))
            logger.debug(r.status_code)
            raise Exception("Luashark file not found at URL: {}".format(url))

        return os.path.join(tmp_dir, "luashark-{}".format(sw_version))

    @staticmethod
    def _unzip_file(tmp_luashark_dir, luashark_dir):
        with zipfile.ZipFile("{}.zip".format(tmp_luashark_dir), 'r') as zip_ref:
            zip_ref.extractall(tmp_luashark_dir)

        if os.path.exists(luashark_dir):
            logger.debug("Removing luashark from {}".format(luashark_dir))
            logger.console("Removing luashark from {}".format(luashark_dir))
            os.system("sudo rm -rf {}".format(luashark_dir))

        if not os.path.exists(luashark_dir):
            logger.debug("Creating luashark directory {}".format(luashark_dir))
            logger.console(
                "Creating luashark directory {}".format(luashark_dir))
            os.system("sudo mkdir -p {}".format(luashark_dir))
        logger.debug("Copying luashark from {} to {}".format(
            tmp_luashark_dir, luashark_dir))
        logger.console("Copying luashark from {} to {}".format(
            tmp_luashark_dir, luashark_dir))
        os.system("sudo scp -r {} {}".format(tmp_luashark_dir, luashark_dir))
