"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska, Jacek Kozmic
:maintainer: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
"""

from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh.exceptions import ConnectFailedError
import requests
import os
from file_management import check_path_exists
from file_management import unzip_file
from common_gnb import get_gnb_build
from utilities import check_url_exists, logger_console


class NoLuaSharkFileException(Exception):
    pass


class NoWorkingLuaSharkUrlException(Exception):
    pass


class LuaShark(object):

    def __init__(self, output_dir=BuiltIn().get_variable_value("${OUTPUT_DIR}")):
        self.sran_url = "http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/{}/{}_luashark.zip"
        self.url_end = "System_Release/{}/luashark-{}.zip"
        self.default_url = "https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/{}"
        self.luashark_root_path = BuiltIn().get_variable_value('${LUASHARK_ROOT_PATH}')
        self.lua_path = '{}/luashark'.format(output_dir)
        self.gnb_build = ""
        self.gnb_release = ""
        self.__default_build = "SBTS00_ENB_9999_220303_000001"
        self.__default_release = "SBTS00"

    def get_lua_script(self):
        """
        It provides lua script.
        It checks if the luashark script is already on the VM in /opt/luashark/ directory and unzips it if
        it is found.
        If luashark is not in its usuall directory it downloads it to the output directory and unzips it.
        If it isnt able to find a luashark file with either of those methods it rises NoLuaSharkFileException.
        In variable file it requires following item:
        LUASHARK_ROOT_PATH, usually should be '/opt/luashark/'
        :author: Adrianna Pienkowska
        :returns: path to luashark execution file, e.g. '/home/ute/luashark/generated_luashark/luashark.lua'
        """
        if check_path_exists(self.luashark_root_path):
            path = os.path.join(self.luashark_root_path, 'generated_luashark/luashark.lua')
            logger_console("Returning default path for luashark: {}".format(path))
            return path

        zip_path = self.__download_luashark_for_gnb_build()
        if check_path_exists(zip_path):
            unzip_file(zip_path, self.lua_path)
            path = os.path.join(self.lua_path, 'generated_luashark/luashark.lua')
            logger_console("Returning downloaded path for luashark: {}".format(path))
            return path

        raise NoLuaSharkFileException

    def __try_to_retrieve_gnb_build(self):
        try:
            gnb_build = get_gnb_build(convert_to_trunk=True)
        except ConnectFailedError as e:
            gnb_build = self.__default_build
            logger_console("Issue: {}; Using default build {} at Luashark package".format(e, gnb_build))
        return gnb_build

    def __try_to_retrieve_gnb_release(self):
        if 'SBTS00' in self.gnb_build:
            return self.__default_release
        else:
            return self.gnb_build[:8]

    def __handle_sran_url(self):
        self.gnb_release = self.__try_to_retrieve_gnb_release()
        url_end = self.sran_url.format(self.gnb_release, self.gnb_build)
        return url_end

    def __handle_artifactory_url(self):
        url_end = self.url_end.format(self.gnb_build, self.gnb_build)
        return self.artifactory_url.format(url_end)

    def __get_url_to_luashark(self):
        url = None
        if "SBTS" in self.gnb_build:
            url = self.__handle_sran_url()
        else:
            url = self.__handle_artifactory_url()
        if check_url_exists(url):
            return url
        else:
            raise NoWorkingLuaSharkUrlException('Url is not working: {}'.format(url))

    def __download_luashark_for_gnb_build(self):
        self.gnb_build = self.__try_to_retrieve_gnb_build()
        url = self.__get_url_to_luashark()
        r = requests.get(url, allow_redirects=True)

        OperatingSystem().create_directory(self.lua_path)
        zip_path = os.path.join(self.lua_path, 'luashark.zip')
        with open(zip_path, 'wb') as file_stream:
            file_stream.write(r.content)

        return zip_path
