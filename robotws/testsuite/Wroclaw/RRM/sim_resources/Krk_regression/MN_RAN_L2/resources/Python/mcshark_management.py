# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:maintainer: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
"""

import os
from html.parser import HTMLParser
from re import sub, findall, search
from contextlib import contextmanager
from subprocess import check_output, call, STDOUT
from packaging import version

from robot.api import logger
from packaging.version import parse
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from taf.transport.ssh.exceptions import ConnectFailedError

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import get_gnb_build
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    get_url_source_code, download_file_from_url, logger_console
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    check_path_exists, check_file_exists, get_latest_file, list_all_files_in_directory
)


class __McSharkArtifactoryParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.__text = []
        self.__so = ".so"
        self.__so_files = []
        self.__lib_so = None

    def handle_data(self, data):
        text = data.strip()
        if len(text) > 0:
            text = sub('[ \t\r\n]+', ' ', text)
            self.__text.append(text + ' ')

            if self.__so in text:
                self.__so_files.append(text)

    def handle_starttag(self, tag, attrs):
        if tag == 'p':
            self.__text.append('\n\n')
        elif tag == 'br':
            self.__text.append('\n')

    def handle_startendtag(self, tag, attrs):
        if tag == 'br':
            self.__text.append('\n\n')

    def text(self):
        return ''.join(self.__text).strip()

    def get_so_files(self):
        return self.__so_files

    def get_mcshark_so_lib(self, version):
        version_string = 'mcshark-' + version
        for so_file in self.__so_files:
            if so_file.endswith(self.__so) and so_file.startswith(version_string):
                self.__lib_so = so_file
                break
        return self.__lib_so


class __PluginArtifactoryParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.__text = []
        self.__plugin_xnap = "nokiaxnap"
        self.__plugin_f1ap = "nokiaf1ap"
        self.__plugin_dirs = []
        self.__so = "buster.so"
        self.__so_files = []
        self.__lib_so = None
        self.__wireshark_version = '4.0'

    def handle_data(self, data):
        text = data.strip()
        if len(text) > 0:
            text = sub('[ \t\r\n]+', ' ', text)
            self.__text.append(text + ' ')
            if self.__plugin_xnap or self.__plugin_f1ap in text:
                self.__plugin_dirs.append(text)
            if self.__so in text:
                self.__so_files.append(text)

    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            self.__text.append('\n')

    def text(self):
        return ''.join(self.__text).strip()

    def get_plugin_so_file(self, plugin_name):
        """
        Searches through html lines in directory, then returns the latest plugin file, that ends with buster.so.

        :return: (str) plugin file with version e.g.  nokiaxnap-4.0-0.0.4-17.3.1-33+buster.so
        """

        regex_pattern = r'(\d+\.\d+)-(\d+\.\d+\.\d+)-(\d+\.\d+\.\d+-\d+)'
        max_sub_ver_1 = '0.0.0'
        max_sub_ver_2 = '0.0.0-0'
        for so_file in self.__plugin_dirs:
            if so_file.endswith(self.__so):
                version = search(regex_pattern, so_file)
                try:
                    assert version.group(1) == self.__wireshark_version
                except AssertionError or AttributeError:
                    continue
                if parse(version.group(2)) > parse(max_sub_ver_1):
                    max_sub_ver_1 = version.group(2)
                    max_sub_ver_2 = version.group(3)
                elif parse(version.group(2)) == parse(max_sub_ver_1) and parse(version.group(3)) > parse(max_sub_ver_2):
                    max_sub_ver_2 = version.group(3)
        return f'{plugin_name}-{self.__wireshark_version}-{max_sub_ver_1}-{max_sub_ver_2}+{self.__so}'

    def get_plugin_newest_release_dir(self, plugin_name):
        """
        Searches through directory, then returns the latest version of given plugins.

        :param plugin_name: (str) either nokiaxnap or nokiaf1ap
        :return: plugin name + newest version. E.g.: nokiaxnap-17.3.1-33
        """

        dir_regex_pattern = fr'\d+\.\d+\.\d+-\d+'
        _plugin_newest_dir = [search(dir_regex_pattern, plugin).group(0) for plugin in self.__plugin_dirs if
                              search(dir_regex_pattern, plugin)]
        _plugin_newest_dir = list(map(parse, _plugin_newest_dir))
        _plugin_newest = f'{plugin_name}-{str(max(_plugin_newest_dir).base_version)}-' \
                         f'{str(max(_plugin_newest_dir).post)}/'
        return _plugin_newest


@contextmanager
def McSharkArtifactoryParser():
    parser = __McSharkArtifactoryParser()
    try:
        yield parser
    finally:
        parser.close()


@contextmanager
def PluginArtifactoryParser():
    parser = __PluginArtifactoryParser()
    try:
        yield parser
    finally:
        parser.close()


class McSharkUrlDoesNotExistException(Exception):
    pass


class WiresharkNotInstalledException(Exception):
    pass


class NoMcSharkPackageException(Exception):
    pass


class McShark(object):

    def __init__(self):
        self.__wireshark_path = "/usr/lib/x86_64-linux-gnu/wireshark/plugins"
        self.__mcshark_artifactory_url = "https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/"
        self.__so_lib_path = None
        self.__so = ".so"
        self.__so_lib_filename = None
        self.__default_build = "SBTS00_ENB_9999_211025_000013"
        self.__wireshark_version = None
        self.__plugin_artifactory_url = "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/"
        self.__install_script_url = 'https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/' \
                                    'tools/install_wslte_plugins.bash'

    def set_wireshark_path(self, new_path):
        logger_console("Setting new wireshark path {}, replacing {}".format(new_path, self.__wireshark_path))
        self.__wireshark_path = new_path

    def __try_to_retrieve_gnb_build(self):
        try:
            gnb_build = get_gnb_build(convert_to_trunk=True)
        except ConnectFailedError as e:
            gnb_build = self.__default_build
            logger_console("Issue: {}; Using default build {} at McShark package".format(e, gnb_build))
        return gnb_build

    def __validate_so_lib(self, so_lib_path):
        msg_1 = "You didnt pass so_lib_path arg!"
        msg_2 = "download_mcshark() keyword hasnt run!"
        msg_3 = "No available McShark .so package!"

        if not so_lib_path:
            if self.__so_lib_path:
                so_lib_path = self.__so_lib_path
                logger_console("{}; using already downloaded {}".format(msg_1, so_lib_path))
            else:
                raise NoMcSharkPackageException("{}; {}; {}".format(msg_1, msg_2, msg_3))

        if not so_lib_path.endswith(self.__so):
            raise NoMcSharkPackageException("{}; Wrong extension (not {}): {}".format(msg_3, self.__so, so_lib_path))
        elif not check_file_exists(so_lib_path):
            raise NoMcSharkPackageException("{}; File does not exist: {}".format(msg_3, so_lib_path))

        return so_lib_path

    def __validate_wireshark_installed(self, wireshark_path=None):
        if not wireshark_path:
            wireshark_path = self.__wireshark_path
        if not check_path_exists(self.__wireshark_path):
            raise WiresharkNotInstalledException("Wireshark path is not existing! Path: {}".format(wireshark_path))

    def __fill_wireshark_version_from_testline(self):
        self.__wireshark_version = get_latest_file(os.path.join(self.__wireshark_path, '*.*')).split('/')[-1]

    def __expand_wireshark_path_with_version_epan(self):
        self.__fill_wireshark_version_from_testline()
        wireshark_path = os.path.join(self.__wireshark_path, self.__wireshark_version, "epan")
        self.__validate_wireshark_installed(wireshark_path=wireshark_path)
        self.__wireshark_path = wireshark_path
        return self.__wireshark_path

    def __remove_old_mcshark_libs(self, wireshark_epan_path):
        OperatingSystem().run("sudo rm {}/mcshark*.so".format(wireshark_epan_path))

    def download_mcshark(self, gnb_build=None):
        self.__validate_wireshark_installed()
        self.__wireshark_version = get_latest_file(os.path.join(self.__wireshark_path, '*.*')).split('/')[-1]
        self.__fill_wireshark_version_from_testline()
        logger_console("Starting McShark download procedure...")
        if gnb_build is None:
            gnb_build = self.__try_to_retrieve_gnb_build()
        download_file_from_url(url=self.__install_script_url, destination_path="/home/ute/install_wslte_plugins.bash")
        cmds = [
            ["chmod 775 install_wslte_plugins.bash"],
            ["./install_wslte_plugins.bash -B {}".format(gnb_build)]
        ]
        for cmd in cmds:
            call(cmd, shell=True, cwd="/home/ute", stderr=STDOUT)

    def ensure_mcshark_package_is_in_wireshark_dir(self):
        if 'epan' not in self.__wireshark_path:
            self.__expand_wireshark_path_with_version_epan()
        files = list_all_files_in_directory(directory=self.__wireshark_path)
        for file in files:
            if 'mcshark' in file:
                return
        raise NoMcSharkPackageException("In {} there is no mcshark package".format(self.__wireshark_path))

    def ensure_plugin_is_present(self, plugin_name):
        """
        :copyright: Nokia Networks
        :author: Michal Mach
        :maintainer: Michal Mach
        :contact: michal.mach@nokia.com

        Function that checks if given plugin is already installed.

        """

        if 'epan' not in self.__wireshark_path:
            self.__expand_wireshark_path_with_version_epan()
        files = list_all_files_in_directory(directory=self.__wireshark_path)
        for file in files:
            result = findall('^{}'.format(plugin_name), file)
            if result:
                logger.debug('Plugin {} file has been found'.format(plugin_name))
                return True
        logger.debug('Plugin {} file has not been found'.format(plugin_name))
        return False

    def prepare_plugin_name_url(self, plugin_name):
        """
        :copyright: Nokia Networks
        :author: Michal Mach
        :maintainer: Michal Mach
        :contact: michal.mach@nokia.com

        Add specific plugin name to artifactory url.

        """

        if plugin_name == 'nokiaf1ap':
            return self.__plugin_artifactory_url + 'Nokia_F1_AP/'
        elif plugin_name == 'nokiaxnap':
            return self.__plugin_artifactory_url + 'Nokia_Xn_AP/'

    def move_plugin_package_to_wireshark_binaries(self, so_lib_path=None):
        """
        :copyright: Nokia Networks
        :author: Michal Mach
        :maintainer: Michal Mach
        :contact: michal.mach@nokia.com

        Function that moves downloaded plugin package to Wireshark library.

        :param so_lib_path: Path to downloaded .so file.

        """

        so_lib_path = self.__validate_so_lib(so_lib_path=so_lib_path)
        wireshark_plugin_path = os.path.join(self.__wireshark_path, self.__so_lib_filename)
        OperatingSystem().run("sudo cp {} {}".format(so_lib_path, wireshark_plugin_path))
        logger.debug("Plugin {} .so file copy to epan path succesfull!".format(self.__so_lib_filename))

    def download_plugin_from_artifactory(self, plugin_name):
        """
        :copyright: Nokia Networks
        :author: Michal Mach
        :maintainer: Michal Mach
        :contact: michal.mach@nokia.com

        Function that checks whether plugin file is present, if not searches for the latest plugin version and downloads
        it to Downloads folder, then copies that file to Wireshark Plugin path.

        :param plugin_name: Only 'nokiaf1ap', 'nokiaxnap' are valid plugin names.

        """

        self.__validate_wireshark_installed()
        if self.ensure_plugin_is_present(plugin_name):
            return
        _plugin_main_dir_url = self.prepare_plugin_name_url(plugin_name)
        url_source = get_url_source_code(url=_plugin_main_dir_url)
        with PluginArtifactoryParser() as parser:
            parser.feed(url_source)
            _plugin_main_dir_url += parser.get_plugin_newest_release_dir(plugin_name)
            url_source = get_url_source_code(url=_plugin_main_dir_url)
            parser.feed(url_source)
            self.__so_lib_filename = parser.get_plugin_so_file(plugin_name)
        output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        self.__so_lib_path = os.path.join(output_dir, self.__so_lib_filename)
        _plugin_so_file_url = _plugin_main_dir_url + self.__so_lib_filename
        download_file_from_url(url=_plugin_so_file_url, destination_path=self.__so_lib_path)
        logger.debug('Plugin {} has been downloaded!'.format(plugin_name))
        self.move_plugin_package_to_wireshark_binaries(so_lib_path=self.__so_lib_path)


def prepare_mcshark_env(gnb_build=None):
    mcshark = McShark()
    mcshark.download_mcshark(gnb_build=gnb_build)


def ensure_mcshark_package_is_installed(mcshark_path=None):
    mcshark = McShark()
    if mcshark_path:
        mcshark.set_wireshark_path(mcshark_path)
    logger_console("Ensuring McShark package exist in wireshark directory...")
    mcshark.ensure_mcshark_package_is_in_wireshark_dir()


def add_wireshark_plugin(plugin_name=None):
    """
    :copyright: Nokia Networks
    :author: Michal Mach
    :maintainer: Michal Mach
    :contact: michal.mach@nokia.com

    Function that downloads Wireshark plugins that are used in CB008140, to validate flow messages.

    :param plugin_name: Only 'nokiaf1ap', 'nokiaxnap' are valid plugin names to download. If nothing is provided, then
    both plugins will be installed.

    """

    if plugin_name is None:
        plugins_f1ap = McShark()
        plugins_f1ap.download_plugin_from_artifactory(plugin_name='nokiaf1ap')
        plugins_xnap = McShark()
        plugins_xnap.download_plugin_from_artifactory(plugin_name='nokiaxnap')
    elif plugin_name:
        plugins = McShark()
        plugins.download_plugin_from_artifactory(plugin_name)


def download_mcshark_if_not_present(gnb_build=None):
    if not check_mcshark_plugin_present():
        prepare_mcshark_env(gnb_build)


def check_mcshark_plugin_present():
    plugins = check_output("tshark -G plugins", shell=True)
    if search('mcshark', str(plugins)):
        logger_console("mcshark is already present")
        return True
    return False
