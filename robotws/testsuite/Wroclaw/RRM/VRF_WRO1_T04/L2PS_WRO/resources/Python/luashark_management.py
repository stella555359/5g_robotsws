"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
import requests
import os
import re
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.file_management import check_path_exists
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.file_management import unzip_file
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb import get_gnb_build
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb import get_gnb_build_release
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.utilities import check_url_exists
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens import Tokens


class NoLuaSharkFileException(Exception):
    pass


class NoWorkingLuaSharkUrlException(Exception):
    pass


class LuaShark(object):

    def __init__(self):
        self.sran_url = "http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/{}/{}_luashark.zip"
        self.url_end = "System_Release/{}/luashark-{}.zip"
        self.default_url = "https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/{}"
        self.luashark_root_path = BuiltIn().get_variable_value('${LUASHARK_ROOT_PATH}')
        self.lua_path = '{}/luashark'.format(BuiltIn().get_variable_value("${OUTPUT_DIR}"))
        self.gnb_build = ""
        self.gnb_release = ""

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
            return os.path.join(self.luashark_root_path, 'generated_luashark/luashark.lua')

        zip_path = self.__download_luashark_for_gnb_build()
        if check_path_exists(zip_path):
            unzip_file(zip_path, self.lua_path)
            return os.path.join(self.lua_path, 'generated_luashark/luashark.lua')

        raise NoLuaSharkFileException

    def __handle_sran_url(self):
        self.gnb_release = get_gnb_build_release(convert_to_trunk=True)
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
        if check_url_exists(url, use_token=True):
            return url
        else:
            raise NoWorkingLuaSharkUrlException('Url is not working: {}'.format(url))

    def __download_luashark_for_gnb_build(self):
        self.gnb_build = get_gnb_build(convert_to_trunk=True)
        url = self.__get_url_to_luashark()
        r = requests.get(url, headers=Tokens().authorization_bearer_token)

        OperatingSystem().create_directory(self.lua_path)
        zip_path = '{}/{}'.format(self.lua_path, 'luashark.zip')
        with open(zip_path, 'wb') as file_stream:
            file_stream.write(r.content)

        return zip_path
