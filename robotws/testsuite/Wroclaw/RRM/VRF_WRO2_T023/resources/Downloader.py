"""
:copyright: Nokia Networks
:author: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:maintainer: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:version: 0.1
"""

import os
import re
import requests
import shutil
from robot.api import logger


class Downloader:

    @property
    def authorization_bearer_token(self):

        """
        Gets and returns authorization token for artifactory.

        :return Authorization token for artifactory.
        """
        with open("/etc/token/ca_ute_artifactory_readonly") as cert_file:
            return {"Authorization": "Bearer " + cert_file.read().strip()}

    @staticmethod
    def is_software_trunk(sw_version):

        """
        Checks if given SW is TRUNK SW or not. Uses following regexp
        list to verify software pattern:
        [r"vDUCNF[0-9][0-9]R[1-9]_0\\.*",
                             "vDUCNF00*",
                             r"vCUCNF[0-9][0-9]R[1-9]_0\\.*",
                             "vCUCNF00*",
                             "SBTS[1-9][0-9]R[1-9]_ENB_9999_*",
                             "SBTS00_*"]

        :param sw_version: Version of SW that needs to be checked.
               e.g. vDUCNF00_0.300.25389
        :return True if SW is TRUNK and False otherwise.
        """
        regexp_sw_version = [r"vDUCNF[0-9][0-9]R[1-9]_0\.*",
                             "vDUCNF00*",
                             r"vCUCNF[0-9][0-9]R[1-9]_0\.*",
                             "vCUCNF00*",
                             "SBTS[1-9][0-9]R[1-9]_ENB_9999_*",
                             "SBTS00_*"]
        return any([re.search(current_regexp, sw_version) for current_regexp in regexp_sw_version])

    def downloader(self, url, download_path, chunk_size=128):

        """
        Downloads file from given link.

        :param url: URL to file that should be downloaded.
        :param download_path: Absolute path where file should
               be saved, e.g. "/home/ute/Downloads/test/file.deb"
        :param chunk_size: The number of bytes that should be read into
               memory at a time during SACK downloading. Default value: 128
        """

        if os.path.isfile(download_path):
            logger.debug(f"File already exists at {download_path}.")
            return
        r = requests.get(url, headers=self.authorization_bearer_token, stream=True)
        if r.status_code == 200:
            logger.debug("File exists at {}. Starting download"
                         " to path {}".format(url, download_path))
            with open(download_path, 'wb') as fd:
                logger.debug(f"{fd}")
                shutil.copyfileobj(r.raw, fd, length=16 * 1024 * 1024)
        else:
            logger.debug("File not found at {}".format(url))
            logger.debug(r.status_code)
            raise Exception("File not found at URL: {}".format(url))

    @staticmethod
    def check_and_create_dest_dir(destination_dir):

        """
        Checks if given directory exists and creates it if it does not.

        :param destination_dir: Absolute path to directory.
        """

        if not os.path.exists(destination_dir):
            logger.debug("Creating directory for downloading file {}".format(destination_dir))
            logger.console("Creating directory for downloading file {}".format(destination_dir))
            os.system("mkdir -p {}".format(destination_dir))

    def _modify_sw_version(self, sw_version):

        """
        Modifies given SW version depending on product used. It is used for trunk SW to replace strings
        like '25R1' with '00'. If SW version does not exist in dictionary an error will be raised.
        Dictionary for replacing of regular expressions:
        {r"vDUCNF[0-9][0-9]R[1-9]_0\\.*": "vDUCNF00_0.",
        "vDUCNF00*": "vDUCNF00",
        r"vCUCNF[0-9][0-9]R[1-9]_0\\.*": "vCUCNF00_0.",
        "vCUCNF00*": "vCUCNF00",
        "SBTS[1-9][0-9]R[1-9]_ENB_9999_*": "SBTS00_ENB_9999_",
        "SBTS00_*": "SBTS00_"}

        :param sw_version: sw_version: Version of SW that needs to be modified.
               e.g. vDUCNF23R4_0.300.25389
        :return Modified software version.
        """

        regexp_sw_dict = {r"vDUCNF[0-9][0-9]R[1-9]_0\.*": "vDUCNF00_0.",
                          "vDUCNF00*": "vDUCNF00",
                          r"vCUCNF[0-9][0-9]R[1-9]_0\.*": "vCUCNF00_0.",
                          "vCUCNF00*": "vCUCNF00",
                          "SBTS[1-9][0-9]R[1-9]_ENB_9999_*": "SBTS00_ENB_9999_",
                          "SBTS00_*": "SBTS00_"}
        for pattern, replacement in regexp_sw_dict.items():
            if re.search(pattern, sw_version):
                return re.sub(pattern, replacement, sw_version)
        raise Exception("SW version {} was not found in available regexp versions: {}".format(sw_version,
                                                                                              regexp_sw_dict.keys()))

    def check_and_modify_sw_version(self, sw_version):

        """
        Checks if given SW version is TRUNK SW and modifies it in such case.
        If SW version is not from TRUNK it does not modify it.

        :param sw_version: sw_version: Version of SW that needs to be checked and modified.
               e.g. vDUCNF23R4_0.300.25389
        :return Modified software version.
        """

        if self.is_software_trunk(sw_version):
            return self._modify_sw_version(sw_version)
        else:
            return sw_version

    def get_release_from_sw_version(self, sw_version):

        """
        Gets SW release based on given SW version.

        :param sw_version: sw_version: Version of SW for which release needs to be returned.
               e.g. vDUCNF23R4_0.300.25389
        :return SW release.
        """

        return re.search(r'([A-Za-z0-9]+?)_', sw_version).group(1)

    def download_tti_dec(self, sw_version, destination_dir, chunk_size=128):

        """
        Downloads tti-dec from
        https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/
        System_Release/<release>/<sw_version>/
        for vDU builds or
        https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/
        build/<release>/<sw_version>/
        for SBTS builds.

        :param sw_version: Version of SW for which tti-dec should be downloaded.
               e.g. vDUCNF00_0.300.25389
        :param destination_dir: Absolute path to directory where tti-dec should
               be saved, e.g. "/home/ute/Downloads/test"
        :param chunk_size: The number of bytes that should be read into
               memory at a time during SACK downloading. Default value: 128
        :return Absolute path to downloaded file.
        """

        self.check_and_create_dest_dir(destination_dir)
        sw_version = self.check_and_modify_sw_version(sw_version)
        release = self.get_release_from_sw_version(sw_version)
        if 'vDUCNF' in release:
            url = "https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/" \
                  "System_Release/{}/{}/{}_tti-dec.deb".format(release, sw_version, sw_version)
        elif 'SBTS' in release:
            url = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/" \
                  "build/{}/{}/{}_tti-dec.deb".format(release, sw_version, sw_version)
        else:
            logger.debug("Incorrect SW release: {}.".format(release))
            raise Exception("Incorrect SW release: {}.".format(release))
        download_path = os.path.join(destination_dir, "{}_tti-dec.deb".format(sw_version))
        self.downloader(url, download_path, chunk_size)

        return download_path
