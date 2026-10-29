# -*- coding: utf-8 -*-
"""
This module provides functionalities for automating configuration tasks in a network environment.

:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""

import logging
import os
import time
import requests
from retrying import retry
from robot.libraries.BuiltIn import BuiltIn
from taf.selenium.sbts import sbts
from taf.rfrl.utilities.robot.general import get_builtin_value

__all__ = ['generate_new_scf_via_configuration_automation']

# Base URL for fetching packages
hz_base_url = "https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/"
# API Key for username "ca_5Gauto"
hz_artifactory_api_key = "AKCp5bBh9XG9iCkcCJLwt6CHuVdgHPyJVAuB7V6vSHfet7X6ZXfjZRqEMLxn36rfqRfhoQzKc"
espoo_base_url = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/"
ext_path = "_fce-worker.zip"
tl = get_builtin_value(param_name="tl")


def get_package_version_and_stream(version, convert_to_trunk=True):
    """
    Function to get the package version and stream from the version string.

    :param version: The version string.
    :param convert_to_trunk: Boolean flag to convert to trunk version.
    :return: The package version and stream.
    """
    # WESTLAKE-10625 trunk build contains 'ENB_9990' rather than 'ENB_9999' sometimes
    sbts_trunk = "_ENB_9999_" in version or "_ENB_9990_" in version
    version_split = version.split("_")
    stream = "SBTS00" if sbts_trunk and convert_to_trunk else version_split[0]
    version = version.replace(version_split[0], stream)
    return version, stream


def get_local_fce_file_path(scf_path, package_version):
    """
    Function to get the local file path for the FCE file.

    :param scf_path: The SCF file path.
    :param package_version: The package version.
    :return: The local FCE file path.
    """
    save_path = os.path.dirname(scf_path)
    fce_file_path = os.path.join(save_path, package_version + ext_path)
    return fce_file_path


class DownloadPackage(object):
    """
    Class to handle the downloading of packages.
    """

    def __init__(self, package_version, save_path):
        """
        Constructor for the DownloadPackage class.

        :param package_version: The package version.
        :param save_path: The path to save the downloaded package.
        """
        self.package_version = package_version
        self.save_path = save_path

    def download(self, base_url, api_key=None, timeout=600):
        """
        Method to download the package.

        :param base_url: The base URL for the download request.
        :param api_key: The API key for the download request.
        :param timeout: The timeout for the download request.
        :return: True if the download was successful, False otherwise.
        """
        version, stream = get_package_version_and_stream(self.package_version)
        fce_file = version + ext_path
        url = base_url + stream + "/" + version + "/" + fce_file
        if api_key:
            headers = {'Authorization': f'Bearer {api_key}'}
            r = requests.get(url, headers=headers, stream=True, timeout=timeout)
        else:
            r = requests.get(url, stream=True, timeout=timeout)
        if r.status_code == 200:
            print("request package successful!: {}".format(url))
        else:
            print("request package failed!: {}".format(url))
            return False
        file_path = os.path.join(self.save_path, version + ext_path)
        if not os.path.exists(self.save_path):
            os.makedirs(self.save_path)
        with open(file_path, 'wb') as f:
            for chunk in r.iter_content(1024):
                if chunk:
                    f.write(chunk)
        return True

    def download_package(self):
        """
        This method attempts to download a package from the primary base URL (hz_base_url).
        If it fails, it tries to download the package from the secondary base URL (espoo_base_url).
        If the download is successful, it sets the result to True. If not, it sets the result to False.
        It asserts that the result is True, meaning the download was successful.
        If not, it raises an AssertionError with the message "download package failed".
        """
        try:
            result = self.download(base_url=hz_base_url, api_key=hz_artifactory_api_key)
        except Exception as e:
            result = self.download(base_url=espoo_base_url)
        assert result, "download package failed"


class ConfigurationAutomation(object):
    """
    Class to handle the automation of configuration tasks.
    """

    def __init__(self, scf_path, package_version, download_dir='/home/ute/'):
        """
        Constructor for the ConfigurationAutomation class.

        :param scf_path: The SCF file path.
        :param package_version: The package version.
        :param download_dir: The directory to save the downloaded package.
        """
        self.selenium_coam = self.selenium_select()
        self.scf_path = scf_path
        self.package_version = package_version
        self.download_dir = download_dir
        self.select_plan = self.select_plan()

    def select_plan(self):
        """
        Method to get scf file name from the scf path.
        """
        scf_name = os.path.basename(self.scf_path)
        scf_name = scf_name.split('.')[0]
        _, stream = get_package_version_and_stream(self.package_version, convert_to_trunk=False)
        if stream > 'SBTS25R1':
            return f'CONF-1_{scf_name}'
        else:
            return 'CONF-1'

    def selenium_select(self):
        try:
            selenium_coam = BuiltIn().get_library_instance('selenium_coam')
        except Exception as e:
            selenium_coam = sbts()
        return selenium_coam

    @retry(stop_max_attempt_number=3, wait_fixed=10000)
    def selenium_login(self, ip=tl.gnbs[0].cu.oam_ssh_connection_details.addr, username='Nemuadmin',
                       password='nemuuser', browser='Firefox'):
        """
        Method to login to the Selenium COAM.

        :param ip: The IP address to login to.
        :param username: The username for login.
        :param password: The password for login.
        :param browser: The browser to use for login.
        """
        version, stream = get_package_version_and_stream(self.package_version, convert_to_trunk=False)
        self.selenium_coam.enable_virtual_display()
        url = 'https://' + ip
        self.selenium_coam.login(
            url, username, password, version=stream, browser=browser, timeout=120, download_dir=self.download_dir)
        self.selenium_coam.disable_message_box()
        self.selenium_coam.disable_screen_lock()

    def selenium_logout(self):
        """
        Method to logout from the Selenium COAM.
        """
        self.selenium_coam.logout()
        self.selenium_coam.close_browser()

    def selenium_upload_scf(self):
        """
        Method to upload the SCF file to the Selenium COAM.
        """
        self.selenium_coam.load_commissioning_file_and_check_load_status(file_path=self.scf_path)

    def selenium_install_fce(self):
        """
        Method to install the FCE file to the Selenium COAM.
        """
        version, stream = get_package_version_and_stream(self.package_version)
        fce_file_path = get_local_fce_file_path(scf_path=self.scf_path, package_version=version)
        self.selenium_coam.install_fce(file_path=fce_file_path, select_plan=self.select_plan)

    def selenium_calculate(self):
        """
        This method is used to calculate configurations based on the feature provided.
        Currently, it is set to calculate configurations for the "PDCCH" feature.

        :return: None
        """
        self.selenium_coam.calculate_based_on_configurations(feature="PDCCH")

    def selenium_apply(self):
        """
        This method applies all the configurations that have been set up in the Selenium COAM.
        It does not return any value.
        """
        self.selenium_coam.apply_all_configurations()

    def selenium_save_scf(self):
        """
        This method saves the BTS configuration in the Selenium COAM and returns the file path of the saved
        configuration.

        :return: file_path (str): The path of the saved BTS configuration file.
        """
        file_path = self.selenium_coam.save_bts_configuration()
        return file_path

    def selenium_bts_name(self):
        """
        This method returns the BTS name from the Selenium COAM.

        :return: bts_name (str): The name of the BTS.
        """
        bts_name = self.selenium_coam.get_bts_name(timeout=10)
        return bts_name

    def selenium_generate_new_scf(self):
        """
        This method automates the process of generating a new SCF file using Selenium COAM.
        It performs the following steps:
        1. Login to the Selenium COAM.
        2. Upload the SCF file to the Selenium COAM.
        3. Install the FCE file to the Selenium COAM.
        4. Calculate configurations based on the feature provided.
        5. Apply all the configurations that have been set up in the Selenium COAM.
        6. Save the BTS configuration in the Selenium COAM and get the file path of the saved configuration.
        7. Logout from the Selenium COAM.

        :return: new_file_path (str): The path of the newly generated SCF file.
        """
        try:
            self.selenium_bts_name()
            logging.info('Webem is exist, no need to login.')
            need_login = False
        except Exception as e:
            logging.info('Webem is not exist, start to login.')
            self.selenium_login()
            need_login = True
        try:
            logging.info('Start Upload the SCF file.')
            self.selenium_upload_scf()
            logging.info('Start install the FCE file.')
            self.selenium_install_fce()
            time.sleep(10)
            logging.info('Start calculate configurations based on the feature provided.')
            self.selenium_calculate()
            logging.info('Start apply all the configurations.')
            self.selenium_apply()
            logging.info('Start save the BTS configuration.')
            new_file_path = self.selenium_save_scf()
            logging.info('calculate dynamic pdcch by configuration automation on webem successful!')
            logging.info('save scf to {}'.format(new_file_path))
            return new_file_path
        except Exception as e:
            raise Exception('calculate dynamic pdcch by configuration automation on webem failed!')
        finally:
            if need_login:
                time.sleep(10)
                logging.info('Start to logout for next pdcch calculattion.')
                self.selenium_logout()


@retry(stop_max_attempt_number=2, wait_fixed=60000)
def generate_new_scf_via_configuration_automation(scf_path, package_version):
    """
    This function automates the process of generating a new SCF file using the ConfigurationAutomation class.
    It performs the following steps:
    1. Determines the directory of the SCF file.
    2. Downloads the required package.
    3. Asserts that the download was successful.
    4. Creates an instance of the ConfigurationAutomation class.
    5. Generates a new SCF file using the selenium_generate_new_scf method of the ConfigurationAutomation class.
    6. Logs the success of the operation.
    7. Returns the path of the newly generated SCF file.

    :param scf_path: The path of the SCF file.
    :param package_version: The version of the package to be downloaded.
    :param download_dir: The directory to save the downloaded package.
    :return: new_file_path (str): The path of the newly generated SCF file.
    """
    save_path = os.path.dirname(scf_path)
    download = DownloadPackage(package_version=package_version, save_path=save_path)
    download.download_package()
    automation = ConfigurationAutomation(
        scf_path=scf_path, package_version=package_version)
    new_file_path = automation.selenium_generate_new_scf()
    return new_file_path

# if __name__ == '__main__':
#     new_file_path = generate_new_scf_via_configuration_automation(
#         scf_path='/home/ute/ztt/test.xml',
#         package_version='SBTS24R3_ENB_9999_240428_000008')
