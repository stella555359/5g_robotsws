import os.path
from typing import Union
import robot.api.logger as logger


import glob
import requests
import time


class WFTDownloader(object):
    def __init__(self):
        self.target_sw_dict = {}
        self.wft_access_key = "3zxr4FdcoRcpHzxuz6OhTz3LkQXyDsn1PG0J60GJ"
        self.wft_url = "https://wft.int.net.nokia.com:8091/api/v1/"
        self.artifactory_key = "AKCp8oiHU5YPce4g24nY4H9XxoVHAVzcydFrggjst4Ym8FPW7jnEnLDyTDbkNk6ma5XV2NC95"
        self.artifactory_identity_token_espoo2 = "cmVmdGtuOjAxOjE4MzMxOTQwNTU6YnZWYzRrYWJwYmJhWU85azhHZnZiYXdaajlk"
        self.artifactory_access_token_request_header = {
            "Authorization": f"Bearer {self.artifactory_identity_token_espoo2}",
            "content-type": "application/json"
            }
        self.artifactory_access_token_request_json = {
            "scope": "applied-permissions/user",
            "expires_in": "3600",
            "description": "token for RFS Auto TC sw download",
            "include_reference_token": "true"
            }
        self.artifactory_url_espoo2 = "http://artifactory-espoo2.int.net.nokia.com"
        self.artifactory_server = self.artifactory_url_espoo2.split("//")[1]
        self.knife_url = "https://es-si-s3-z2.eecloud.nsn-net.net/knife-results/"

    @staticmethod
    def test_logger(msg, log_level: str = "INFO", console: bool = True, html: bool = False):
        now = f"{time.strftime('%H:%M:%S')} - " if console else ""
        if log_level.upper() == "INFO":
            logger.info(msg=f"{now}{msg}", also_console=console, html=html)
        elif log_level.upper() == "WARN" or log_level.upper() == "ERROR":
            logger.write(msg=f"{now}{msg}", html=html, level=log_level.upper())
        elif log_level.upper() == "DEBUG":
            logger.debug(msg=f"{now}{msg}", html=html)

    def _get_wft_build_link(self, build_name: str, test_package: Union[str, bool] = False) -> str:
        if "SBTS" in build_name and len(build_name.split("_")[4]) == 7:
            self.test_logger(f"File {build_name} is knife build. Downloading from knife url {self.knife_url} ")
            return f"{self.knife_url}{build_name.split('_')[4]}/{build_name}_release_BTSSM_downloadable_A54.zip"
        elif test_package not in ("T1", "T2"):
            file_name = f"{build_name}_release_BTSSM_downloadable_A54.zip"
        else:
            file_name = f"{build_name}_release_BTSSM_downloadable_testpackage_{test_package}_A54.zip"
        branch = build_name.split("_")[0]
        endpoint = f"{branch}/CI_ENB/builds/{build_name}/storages/results.json?access_key={self.wft_access_key}"

        response = requests.get(url=self.wft_url + endpoint).json()
        self.test_logger(response, log_level="DEBUG")
        download_links = [file_.get("path") for storage in response
                          for file_ in storage["storage"].get("storage-items") if
                          file_name in file_["title"] and
                          self.artifactory_server in file_.get("path")]
        if not download_links:
            raise ValueError(f"No matching file found for build '{build_name}' with file name '{file_name}'. "
                             f"Please verify the build name and that the file exists in WFT.")
        return download_links[0]

    @staticmethod
    def _is_file_size_correct(url: str, file_path: str) -> bool:
        wft_file_size = requests.get(url=url, stream=True, timeout=120).headers.get('Content-Length')
        local_file_size = os.path.getsize(file_path)
        return int(wft_file_size) == int(local_file_size)

    def download_build_from_wft(self, builds_to_download: Union[str, set], download_path: str = None,
                                test_package: Union[str, bool] = False) -> dict:
        """
        Downloads specified builds from the WFT server.
        This method checks if the specified builds are already downloaded to avoid re-downloading.
        If not, it proceeds to download the build(s) from the WFT server, supporting both standard
        release builds and specific test packages.

        :param builds_to_download: A single build name or a set of build names to download.
        :param download_path: The local directory path where the builds should be downloaded. Defaults to None.
        :param test_package: Specifies whether to download a test package (T1, T2) instead of the standard release
        :return: A dictionary with build names as keys and the paths to the downloaded files as values.
        """

        if not isinstance(builds_to_download, set):
            builds_to_download = {builds_to_download}
        for build in builds_to_download:
            if not os.path.exists(download_path):
                os.makedirs(download_path)

            path_to_build = glob.glob(f"{download_path}/{build}*")
            if path_to_build:
                self.test_logger(f"File {build} is already downloaded")
                self.target_sw_dict[build] = path_to_build[0]
            else:
                build_url = self._get_wft_build_link(build, test_package)
                build_file_name = build_url.split("/")[-1]
                self.test_logger(f"Build URL: {build_url}")

                artifactory_auth_header = {}
                if self.artifactory_server in build_url:
                    artifactory_auth_header = self._get_artifactory_auth_header(
                        self.artifactory_url_espoo2,
                        self.artifactory_access_token_request_header,
                        self.artifactory_access_token_request_json)

                if artifactory_auth_header:
                    get_parameters = {
                        "url": build_url,
                        "headers": artifactory_auth_header,
                        "stream": True,
                        "timeout": 120
                    }
                else:
                    get_parameters = {
                        "url": build_url,
                        "stream": True,
                        "timeout": 120
                    }

                with requests.get(**get_parameters) as response:
                    self.test_logger(response.status_code, "debug")
                    if response.status_code == 200:
                        self.test_logger(f"Downloading a {build_file_name} to {download_path}")
                        with open(f"{download_path}/{build_file_name}", "wb") as build_package:
                            for chunk in response.iter_content(chunk_size=1024 * 1024):
                                if chunk:
                                    build_package.write(chunk)
                        if self._is_file_size_correct(build_url, os.path.join(download_path, build_file_name)):
                            self.test_logger(f"Build {build} downloaded correctly")
                            self.target_sw_dict[build] = f"{download_path}/{build_file_name}"
                        else:
                            raise Exception(f"Download build {build} failed")
            return self.target_sw_dict[build]

    def _get_artifactory_auth_header(self, artifactory_url: str, artifactory_access_token_request_header: dict,
                                     artifactory_access_token_request_json: dict) -> dict:
        self.test_logger(f"Artifactory URL: {artifactory_url}")
        artifactory_url_token_request = f"{artifactory_url}:8081/access/api/v1/tokens"
        # self.test_logger(f"Artifactory URL token request: {artifactory_url_token_request}")

        artifactory_auth_header = {}
        try:
            s = requests.Session()
            s.trust_env = False
            artifactory_access_token_response = s.post(url=artifactory_url_token_request,
                                                       headers=artifactory_access_token_request_header,
                                                       json=artifactory_access_token_request_json).json()

            self.test_logger(f"Response from {self.artifactory_server}: {artifactory_access_token_response}")
            if 'errors' in artifactory_access_token_response:
                self.test_logger(f"Token request to {artifactory_url_token_request} unsuccessful.")
                self.test_logger("Trying download without token authentication")
            else:
                artifactory_reference_token = artifactory_access_token_response.get("reference_token")
                artifactory_auth_header = {"X-JFrog-Art-Api": f"{artifactory_reference_token}"}

        except TimeoutError:
            self.test_logger(f"Token request to {artifactory_url_token_request} unsuccessful.")
            self.test_logger("Trying download without token authentication")

        # self.test_logger(f"Artifactory auth header: {artifactory_auth_header}")
        return artifactory_auth_header
