"""
Utility functions for downloading various plugins for wireshark from artifactory.
Currently supported plugins:
- nsetapx
- mcshark
- f1ap

:copyright: Nokia
:author: tomasz.sobania@nokia.com
:maintainer: tomasz.sobania@nokia.com
"""

import re
import shutil
import subprocess
from bisect import bisect
from glob import glob
from operator import itemgetter

import requests
from bs4 import BeautifulSoup
from packaging.version import InvalidVersion, Version

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import \
    logger


class PluginManager:
    def __init__(self):
        self.max_fallback_attempts = 10
        self._wireshark_ver = None
        self._os_release = None
        self._headers_dict = None

    @property
    def wireshark_ver(self) -> str:
        """
        :return: (str) returns wireshark version.
        """
        if self._wireshark_ver is None:
            self._wireshark_ver = \
                ".".join(subprocess.check_output(['wireshark', '-v'], text=True).split(" ")[1].split(".")[:2])
        return self._wireshark_ver

    @property
    def os_release(self) -> str:
        """
        :return: (str) returns OS version.
        """
        if self._os_release is None:
            with open("/etc/os-release", "r") as f:
                for line in f:
                    if "VERSION_CODENAME" in line:
                        self._os_release = line.split("=")[-1].strip()
                        return self._os_release
            raise ValueError("Could not find OS version in /etc/os-release")
        return self._os_release

    @property
    def _headers(self) -> str:
        if self._headers_dict is None:
            with open("/etc/token/ca_ute_artifactory_readonly", "r", errors="ignore") as f:
                key = f.read()
            self._headers_dict = {"Authorization": f"Bearer {key.strip()}"}
        return self._headers_dict

    def prepare_all_plugins(self, silent_fail: bool = True) -> None:
        """
        Prepares all supported plugins
        :param bool silent_fail:   Suppress most expected errors which would occur if no eligible plugin is
                                   avaialble for download, leaving plugins already present on VM intact
        """
        self.prepare_mcshark(silent_fail)
        self.prepare_nsetapx(silent_fail)
        self.prepare_f1ap_plugin(silent_fail)

    def prepare_mcshark(self, silent_fail: bool = True) -> None:
        """
        Downloads the MCShark plugin for the software version found on BTS and removes old plugin versions.
        :param bool silent_fail:   Suppress most expected errors which would occur if no eligible plugin is
                                   avaialble for download, leaving plugins already present on VM intact
        """
        repo_link = "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/"
        plugin_name = "mcshark"
        self.prepare_plugin(repo_link, plugin_name, "soft_ver", silent_fail)

    def prepare_nsetapx(self, silent_fail: bool = True) -> None:
        """
        Downloads the NSETAP_X plugin for the software version found on BTS and removes old plugin versions.
        :param bool silent_fail:   Suppress most expected errors which would occur if no eligible plugin is
                                   avaialble for download, leaving plugins already present on VM intact
        """

        repo_link = "https://artifactory-espoo1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/"
        plugin_name = "nsetapx"
        self.prepare_plugin(repo_link, plugin_name, "newest", silent_fail)

    def prepare_f1ap_plugin(self, silent_fail: bool = True) -> None:
        """
        Downloads the F1AP plugin for the software version found on BTS and removes old plugin versions.
        :param bool silent_fail:   Suppress most expected errors which would occur if no eligible plugin is
                                   avaialble for download, leaving plugins already present on VM intact
        """

        repo_link = "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_F1_AP/"
        plugin_name = "nokiaf1ap"
        self.prepare_plugin(repo_link, plugin_name, "newest", silent_fail)

    def prepare_plugin(
        self, repo_link: str, plugin_name: str, strategy: str = "newest", silent_fail: bool = True
    ) -> None:
        """
        Removes other versions of the plugin selected by provided plugin_name and prepares version downloaded with
        provided strategy.
        :param str repo_link:    link to artifactory containing plugin versions
        :param str plugin_name:  name of the plugin as used in plugin filenames, i.e 'mcshark', 'nokiaf1ap', 'nsetapx'
        :param str strategy:     strategy used to download concrete plugin; Currently supported values are:
                                 - 'newest' -> download newest avaialble plugin (sorted by sem_ver)
                                 - 'soft_ver' -> download plugin designed for active software on your NRBTS
        :param bool silent_fail:   Suppress most expected errors which would occur if no eligible plugin is
                                   avaialble for download, leaving plugins already present on VM intact
        """

        try:
            plugin_link = self._get_link_to_concrete_plugin_based_on_strategy(repo_link, plugin_name, strategy)
            local_plugin_path = self._download_plugin_file(plugin_link)
        except (requests.RequestException, PluginDownloaderError) as e:
            logger.error(f"Failed to download {plugin_name} plugin: {e}")
            if silent_fail:
                return
            else:
                raise
        self._install_plugin(plugin_name, local_plugin_path)

    def _install_plugin(self, plugin_name: str, local_plugin_path: str) -> None:
        left_plugins = self._get_local_plugins(plugin_name)
        self._remove_files(left_plugins)
        self._move_plugin_to_appropriate_directory(local_plugin_path)
        self._assert_plugin_count(plugin_name)

    def _assert_plugin_count(self, plugin_name: str) -> None:
        nr_of_active_plugins = len(self._get_local_plugins(plugin_name))
        assert (
            nr_of_active_plugins == 1
        ), f"{nr_of_active_plugins} {plugin_name} plugins present after prepare_{plugin_name}!"

    def _get_link_to_concrete_plugin_based_on_strategy(self, repo_link: str, plugin_name: str, strategy: str) -> str:
        strategy = strategy.lower()
        if strategy == "newest":
            return self._get_link_to_newest_plugin(repo_link, plugin_name)
        elif strategy == "soft_ver":
            return self._get_link_to_software_specific_plugin(repo_link, plugin_name)
        raise ValueError(
            f"Cannot recognize provided downloading strategy: {strategy}. Supported strategies: 'newest', 'soft_ver'"
        )

    def _get_link_to_software_specific_plugin(self, repo_link: str, plugin_name: str) -> str:
        with Admin5G() as admin:
            soft_ver = self._unify_branch_name(admin.get_sw_version())
        plugin_versions = self._get_all_plugin_versions_from_repo(repo_link, plugin_name)
        if f"{soft_ver}/" in plugin_versions:
            exact_soft_link = self._get_correct_link_for_concrete_plugin_version(repo_link, soft_ver, plugin_name)
            if exact_soft_link is not None:
                return exact_soft_link
            version_edge_point = plugin_versions.index(f"{soft_ver}/")
        else:
            version_edge_point = bisect(plugin_versions, f"{soft_ver}/")

        versions_to_check = reversed(plugin_versions[:version_edge_point][-1 * self.max_fallback_attempts:])
        for plugin_version in versions_to_check:
            plugin_file_link = self._get_correct_link_for_concrete_plugin_version(
                repo_link, plugin_version.strip("/"), plugin_name
            )
            if plugin_file_link is None:
                continue
            return plugin_file_link
        raise PluginDownloaderError(
            f"Could not find eligible plugin version amongst the {self.max_fallback_attempts} {plugin_name}"
            f" plugins newer than {soft_ver}. Checked releases: {versions_to_check}"
        )

    def _get_link_to_newest_plugin(self, repo_link: str, plugin_name: str) -> str:
        all_plugins = self._get_all_plugin_versions_from_repo(repo_link, plugin_name)
        filtered_plugins = self._filter_plugin_versions_and_get_comparable_version_objects(all_plugins, plugin_name)
        if not filtered_plugins:
            raise PluginDownloaderError(f"No {plugin_name} plugins found on repo")
        for plugin in reversed(sorted(filtered_plugins, key=itemgetter(1))[-1 * (self.max_fallback_attempts + 1):]):
            plugin_file_link = self._get_correct_link_for_concrete_plugin_version(repo_link, plugin[0], plugin_name)
            if plugin_file_link is None:
                continue
            return plugin_file_link
        raise PluginDownloaderError(
            f"Could not find eligible plugin version amongst {self.max_fallback_attempts + 1} newest {plugin_name} "
            f"plugins"
        )

    def _get_all_plugin_versions_from_repo(self, repo_link: str, plugin_name: str) -> list:
        html_file = self._get_html_repository_page(repo_link, f"/tmp/{plugin_name}_plugins.html")
        with open(html_file) as html:
            soup = BeautifulSoup(html, "html.parser")

        return [link.get("href") for link in soup.find_all("a")]

    @staticmethod
    def _filter_plugin_versions_and_get_comparable_version_objects(all_plugins: list, plugin_name: str) -> list:
        filtered_plugins = []
        for plugin in all_plugins:
            if plugin_name not in plugin:
                continue
            plugin = plugin.strip("/")
            version_string = plugin.partition("-")[-1]
            version_string = PluginManager._convert_especially_weird_version_names(version_string)
            try:
                version = Version(version_string)
            except InvalidVersion:
                continue
            filtered_plugins.append((plugin, version))
        return filtered_plugins

    @staticmethod
    def _convert_especially_weird_version_names(version_string: str) -> str:
        if "-" in version_string:
            trunk, _, last_part = version_string.partition("-")
            if last_part and last_part[0] == "p":
                version_string = trunk + "-0" + last_part[1:]
        return version_string

    def _get_correct_link_for_concrete_plugin_version(
        self, repo_link: str, plugin_version: str, plugin_name: str
    ) -> str | None:
        plugin_html_file = self._get_html_repository_page(
            f"{repo_link}{plugin_version}/", f"/tmp/{plugin_version}.html"
        )
        plugin_names = self._scrape_matching_plugin_filenames(plugin_name, plugin_html_file)
        if len(plugin_names) > 1:
            logger.warning(
                f"Found {len(plugin_names)} matching plugins - first one will be applied. "
                f"All matching plugins found on repository: {plugin_names}",
            )
        elif not len(plugin_names):
            logger.warning(
                f"No {plugin_version} matching wireshark version {self.wireshark_ver} and os release "
                f"{self.os_release} found!"
            )
            return None
        return repo_link + plugin_version + "/" + plugin_names[0]

    def _scrape_matching_plugin_filenames(self, plugin: str, html_file: str) -> str | None:
        with open(html_file) as html:
            soup = BeautifulSoup(html, "html.parser")
        files_on_repo = [link.get("href") for link in soup.find_all("a")]
        plugin_names = [
            name
            for name in files_on_repo
            if re.match(rf"^{plugin}-{self.wireshark_ver}-.*{self.os_release}\.so$", name)
        ]
        return plugin_names

    def _download_plugin_file(self, plugin_link: str) -> str:
        local_plugin_path = f"/tmp/{plugin_link.split('/')[-1]}"
        with requests.get(url=plugin_link, stream=True, headers=self._headers, timeout=10) as request:
            if request.status_code == 200:
                logger.info(f"Downloading plugin: {plugin_link} to {local_plugin_path}", also_to_console=True)
                with open(local_plugin_path, "wb") as f:
                    shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
            else:
                raise ValueError(f"Invalid plugin link: '{plugin_link}'")
        return local_plugin_path

    def _remove_other_versions_of_plugin(self, plugin: str, plugin_ver: str) -> None:
        local_plugins = self._get_local_plugins(plugin)
        self._remove_files([plugin for plugin in local_plugins if plugin_ver not in plugin])

    def _get_local_plugins(self, plugin: str) -> list:
        return glob(
            f"/usr/lib/x86_64-linux-gnu/wireshark/plugins/{self.wireshark_ver}/epan/{plugin}*{self.os_release}.so"
        )

    def _remove_files(self, file_list: list) -> None:
        for f in file_list:
            subprocess.call(["sudo", "rm", f])

    def _get_html_repository_page(self, repository_link: str, target_file: str) -> str:
        with requests.get(url=repository_link, stream=True, headers=self._headers, timeout=10) as request:
            if request.status_code == 200:
                logger.info(f"Downloading {repository_link} to {target_file}")
                with open(target_file, "wb") as f:
                    shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
            else:
                raise requests.RequestException(
                    f"'get' request error on link {repository_link}, return code = {request.status_code}"
                )
        return target_file

    def _move_plugin_to_appropriate_directory(self, plugin_path: str) -> None:
        subprocess.call(
            ["sudo", "mv", plugin_path, f"/usr/lib/x86_64-linux-gnu/wireshark/plugins/{self.wireshark_ver}/epan/"]
        )

    def _unify_branch_name(self, soft_version: str) -> str:
        if soft_version.split("_")[2] in ["9999", "9990"]:
            return "SBTS00_" + soft_version.split("_", 1)[1]
        return soft_version


class PluginDownloaderError(Exception):
    pass


if __name__ == "__main__":
    logger.set_logging_level("DEBUG")
    pm = PluginManager()
    pm.prepare_all_plugins()
