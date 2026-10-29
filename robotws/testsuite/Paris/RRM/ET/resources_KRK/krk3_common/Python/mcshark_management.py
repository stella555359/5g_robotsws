"""
:copyright: Nokia Networks
:author: Mateusz Rzeczyca
:maintainer:  Mateusz Michalik
:contact: mateusz.michalik@nokia.com
"""

from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh.exceptions import ConnectFailedError
from contextlib import contextmanager
from html.parser import HTMLParser
from re import sub
import os
from testsuite.Krakow.RRM.MN_RAN_L2.resources.Python.common_gnb import get_gnb_build
from testsuite.Krakow.RRM.MN_RAN_L2.resources.Python.utilities import (
    check_url_exists, get_url_source_code, download_file_from_url, logger_console
)
from testsuite.Krakow.RRM.MN_RAN_L2.resources.Python.file_management import (
    check_path_exists, check_file_exists, get_latest_file, list_all_files_in
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

            if text.endswith(self.__so) and not self.__lib_so:
                self.__lib_so = text

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

    def get_mcshark_so_lib(self):
        return self.__lib_so


@contextmanager
def McSharkArtifactoryParser():
    parser = __McSharkArtifactoryParser()
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
        self.__default_build = "SBTS00_ENB_9999_220303_000001"

    def __try_to_retrieve_gnb_build(self):
        try:
            gnb_build = get_gnb_build(convert_to_trunk=True)
        except ConnectFailedError as e:
            gnb_build = self.__default_build
            logger_console("Issue: {}; Using default build {} at McShark package".format(e, gnb_build))
        return gnb_build

    @staticmethod
    def __expand_url(url_to_expand, appendix):
        url_to_expand += appendix
        if not check_url_exists(url=url_to_expand):
            raise McSharkUrlDoesNotExistException("URL does not exist! URL: {}".format(url_to_expand))

        return url_to_expand

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

    def __expand_wireshark_path_with_version_epan(self):
        latest_path = get_latest_file(os.path.join(self.__wireshark_path, "*.*/epan"))
        self.__validate_wireshark_installed(wireshark_path=latest_path)
        self.__wireshark_path = latest_path
        return self.__wireshark_path

    def __copy_mcshark_package_to_wireshark_binaries(self, so_lib_path, wireshark_epan_path):
        OperatingSystem().run("sudo cp {} {}".format(so_lib_path, wireshark_epan_path))
        so_lib_epan_path = os.path.join(wireshark_epan_path, os.path.basename(so_lib_path))
        if not check_file_exists(so_lib_epan_path):
            msg = "Could not copy McShark package {} to epan path {}".format(so_lib_path, wireshark_epan_path)
            raise NoMcSharkPackageException(msg)
        logger_console("McShark .so lib copy to epan path succesfull! Now you may use mcshark")

    def download_mcshark(self, output_dir):
        logger_console("Starting McShark download procedure...")
        gnb_build = self.__try_to_retrieve_gnb_build()
        self.__mcshark_artifactory_url = self.__expand_url(url_to_expand=self.__mcshark_artifactory_url,
                                                           appendix=gnb_build + "/")
        url_source = get_url_source_code(url=self.__mcshark_artifactory_url)
        with McSharkArtifactoryParser() as parser:
            parser.feed(url_source)
            self.__so_lib_filename = parser.get_mcshark_so_lib()

        self.__mcshark_artifactory_url = self.__expand_url(url_to_expand=self.__mcshark_artifactory_url,
                                                           appendix=self.__so_lib_filename)
        self.__so_lib_path = os.path.join(output_dir, self.__so_lib_filename)
        download_file_from_url(url=self.__mcshark_artifactory_url, destination_path=self.__so_lib_path)

        logger_console("McShark download procedure has come to an end, returning {} ...".format(self.__so_lib_path))
        return self.__so_lib_path

    def move_package_to_wireshark_binaries(self, so_lib_path=None):
        so_lib_path = self.__validate_so_lib(so_lib_path=so_lib_path)
        self.__validate_wireshark_installed()
        wireshark_epan_path = self.__expand_wireshark_path_with_version_epan()
        self.__copy_mcshark_package_to_wireshark_binaries(so_lib_path=so_lib_path,
                                                          wireshark_epan_path=wireshark_epan_path)

    def ensure_mcshark_package_is_in_wireshark_dir(self):
        if 'epan' not in self.__wireshark_path:
            self.__expand_wireshark_path_with_version_epan()
        files = list_all_files_in(directory=self.__wireshark_path)
        for file in files:
            if 'mcshark' in file:
                return True
        raise NoMcSharkPackageException("In {} there is no mcshark package".format(self.__wireshark_path))


def prepare_mcshark_env(output_dir=BuiltIn().get_variable_value("${OUTPUT_DIR}")):
    mcshark = McShark()
    download_so_package = mcshark.download_mcshark(output_dir=output_dir)
    mcshark.move_package_to_wireshark_binaries(so_lib_path=download_so_package)


def ensure_mcshark_package_is_installed():
    logger_console("Ensuring McShark package exist in wireshark directory...")
    McShark().ensure_mcshark_package_is_in_wireshark_dir()
