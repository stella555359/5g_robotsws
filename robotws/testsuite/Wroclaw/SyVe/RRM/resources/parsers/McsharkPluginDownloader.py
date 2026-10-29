from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from contextlib import contextmanager
from html.parser import HTMLParser
import requests
import re


@contextmanager
def mcshark_artifactory_parser():
    parser = _McSharkArtifactoryParser()
    try:
        yield parser
    finally:
        parser.close()


def download_file_from_url(url, destination_path):
    Logger.warning("Mcshark plugin file {} downloaded from: {}".format(destination_path, url))
    with open(destination_path, 'wb') as downloader:
        downloader.write(requests.get(url, allow_redirects=True, headers=Os().authorization_bearer_token).content)


class McsharkPluginDownloader:
    def __init__(self):
        self.mcshark_plugins_dir = "/home/ute/.local/lib/wireshark/plugins/"
        self.plugins_root_url = "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/"
        self.bts_sw_version = Env.BUILD_SW_VERSION
        self.plugin_major_version = "mcshark-4.4"

    def check_mcshark_plugin_exists_and_try_to_download_otherwise(self):
        plugins_dir = self._get_plugins_dir_path()
        all_plugins = [str(path) for path in Os.list_files_in_the_directory(plugins_dir)]
        mcshark_plugins = list(filter(lambda plugin: 'mcshark' in plugin, all_plugins))
        if not mcshark_plugins:
            url_source = self.try_to_get_mcshark_plugin_page_content_with_minor_version_decrease_retries()
            if url_source is not None:
                self._download_the_mcshark_plugin(url_source, plugins_dir)
        else:
            Logger.info(f"Mcshark plugin(s) {mcshark_plugins} found!")

    def _get_plugins_dir_path(self):
        plugins_dirs = Os.list_files_in_the_pattern_directory(self.mcshark_plugins_dir, "*.*/epan")
        try:
            plugins_dir = plugins_dirs[0]
            Logger.info(plugins_dir)
        except IndexError:
            plugins_dir = Os.join_path_elements(self.mcshark_plugins_dir, "3.6/epan")
            Os.make_dir(plugins_dir)
        return plugins_dir

    def _download_the_mcshark_plugin(self, url_source, plugins_dir):
        with mcshark_artifactory_parser() as parser:
            parser.feed(url_source)
            so_lib_filenames = parser.get_so_files()
        debian_name = Os().get_debian_name()
        so_files = [so_file for so_file in so_lib_filenames if debian_name in so_file and so_file.endswith("so")
                    and self.plugin_major_version in so_file]
        assert len(so_files) == 1, f"Many *.so files found {so_files} in the provided url!" \
                                   f"Couldn't determine the correct one to download"
        so_file = so_files[0]
        download_file_from_url(self.plugins_root_url + self.bts_sw_version + "/" + so_file,
                               f"{plugins_dir}/{so_file}")

    def try_to_get_mcshark_plugin_page_content_with_minor_version_decrease_retries(self):
        cannot_download_plugin_msg = "Couldn't find mcshark plugin for {}, cases using the plugin will fail"
        bts_sw_version_list = self.bts_sw_version.split("_")
        bts_sw_minor_version = bts_sw_version_list[-1].lstrip("0")
        if not bts_sw_minor_version:
            bts_sw_minor_version = "0"
        minor_version_length = len(bts_sw_version_list[-1])
        decreasing_minor_versions_to_included_zero = range(int(bts_sw_minor_version), -1, -1)
        for minor_version in decreasing_minor_versions_to_included_zero:
            new_minor_version = str(minor_version).rjust(minor_version_length, "0")
            bts_sw_version_list[-1] = new_minor_version
            self.bts_sw_version = "_".join(bts_sw_version_list)
            try:
                return self.get_url_source_code(url=self.plugins_root_url + self.bts_sw_version)
            except AssertionError:
                Logger.debug(f"Retry to find mcshark plugin for {self.bts_sw_version} has failed")
        Logger.warning(cannot_download_plugin_msg.format(self.bts_sw_version))
        return None

    def get_url_source_code(self, url):
        if not self.check_url_exists(url=url):
            raise AssertionError(f"URL does not exist: {url}, cannot download mcshark plugin, cases using it may fail")

        Logger.debug(f"Returning source code of the {self.bts_sw_version} website {url}")
        response = requests.get(url, allow_redirects=True, headers=Os().authorization_bearer_token)
        return response.content.decode("utf-8")

    @staticmethod
    def check_url_exists(url):
        return True if requests.get(url, allow_redirects=True,
                                    headers=Os().authorization_bearer_token).status_code == 200 else False


class _McSharkArtifactoryParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self._text = []
        self._so_file = ".so"
        self._so_files = []

    def handle_data(self, data):
        text = data.strip()
        if len(text) > 0:
            text = re.sub('[ \t\r\n]+', ' ', text)
            self._text.append(text + ' ')

            if self._so_file in text:
                self._so_files.append(text)

    def handle_starttag(self, tag, attrs):
        if tag == 'p':
            self._text.append('\n\n')
        elif tag == 'br':
            self._text.append('\n')

    def handle_startendtag(self, tag, attrs):
        if tag == 'br':
            self._text.append('\n\n')

    def text(self):
        return ''.join(self._text).strip()

    def get_so_files(self):
        return self._so_files
