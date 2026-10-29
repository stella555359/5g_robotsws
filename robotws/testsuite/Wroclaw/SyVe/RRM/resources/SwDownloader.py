from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from taf.rfrl.utilities.wft_api import WftApi
import requests


class SwDownloader(object):

    def __init__(self):
        sw_dir = "/home/ute/SBTS_BUILD/"
        Os.make_dir(sw_dir)
        self.download_dir = sw_dir
        self._sw_file_name = None
        self._url = None
        self._file_path = Os().join_path_elements(self.download_dir, self.sw_file_name)

    def download_current_software(self):
        """
        Downloads the current software read from robot "ENB_BUILD" variable
        :return: path to the downloaded file
        """
        Logger.info("Downloading {} SW to {}".format(self.sw_file_name, self.download_dir))
        if not Os().is_file_exist(self._file_path):
            self._download_sw_from_url(self.url, self._file_path)
            Os().confirm_file_exists(self._file_path)
        return self._file_path

    def download_specific_software_version(self, sw_version):
        """
        Downloads the given SW version from artifactory
        :return: path to the downloaded file
        """
        file_name = "{}_release_BTSSM_downloadable_A54.zip".format(sw_version)
        file_path = Os().join_path_elements(self.download_dir, file_name)
        stream = file_name.split('_')[0]
        url_path = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/" \
                   "build/{}/{}/{}".format(stream, sw_version, file_name)
        Logger.info("Downloading {} SW to {}".format(file_name, self.download_dir))
        if not Os().is_file_exist(file_path):
            self._download_sw_from_url(url_path, file_path)
            Os().confirm_file_exists(file_path)
        return file_path

    def _get_artifactory_url(self):
        build_dir = "mn-cosi-sran-central-public-local/build"
        proxy_cache_url = f"https://espoo2-proxy-cache-vrf.wroclaw.nsn-rdnet.net/artifactory/{build_dir}"
        url = f"{proxy_cache_url}/{Env.STREAM_SW}/{Env.BUILD_SW_VERSION}/{self.sw_file_name}"
        if not self._file_exists(url):
            Logger.debug("File not found in proxy cache, checking artifactory directly")
            url_base = f"https://artifactory-espoo2.int.net.nokia.com/artifactory/{build_dir}"
            url = f"{url_base}/{Env.STREAM_SW}/{Env.BUILD_SW_VERSION}/{self.sw_file_name}"
            assert self._file_exists(url), f"SW file {self.sw_file_name} not found in artifactory"
        return url

    @staticmethod
    def _file_exists(url):
        response = requests.head(url, allow_redirects=True)
        return response.status_code == 200

    @staticmethod
    def _download_sw_from_url(url, local_filepath):
        with requests.get(url, stream=True, allow_redirects=True, headers=Os().authorization_bearer_token) as url_file:
            url_file.raise_for_status()
            with open(local_filepath, 'wb') as downloaded_file:
                for chunk in url_file.iter_content(chunk_size=10 * 1024):
                    if chunk:
                        downloaded_file.write(chunk)

    @property
    def sw_file_name(self):
        if not self._sw_file_name:
            self._sw_file_name = f"{Env.BUILD_SW_VERSION}_release_BTSSM_downloadable_A54.zip"
        return self._sw_file_name

    @property
    def file_path(self):
        if not Os().is_file_exist(self._file_path):
            self.download_current_software()
        return self._file_path

    @property
    def url(self):
        if self._url is None:
            self._url = self._get_artifactory_url()
        return self._url

    def download_sherpa_correct_version_for_stream(self, sherpa_version):
        sherpa_file_name = "Sherpa_5G_{}.debian10.deb".format(sherpa_version)
        url_sherpa = "https://artifactory-espoo1.int.net.nokia.com/artifactory/sherpa-local/" \
                     "pool/sherpa5g_18_debian10/{}".format(sherpa_file_name)
        sherpa_download_directory = "/tmp/sherpa_download/"
        Os.make_empty_dir(sherpa_download_directory)
        file_path = Os().join_path_elements(sherpa_download_directory, sherpa_file_name)
        self._download_sw_from_url(url_sherpa, file_path)
        Os().confirm_file_exists(file_path)
        return file_path

    @staticmethod
    def get_the_latest_trunk_build():
        return WftApi().get_newest_builds_by_branch_title(branch_title="SBTS00", items_count=1)[0]["version"]
