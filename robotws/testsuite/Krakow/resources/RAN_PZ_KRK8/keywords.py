import time

from robot.api import logger
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

USERNAME = "ione-tech"
DEFAULT_CDD_URL = "https://172.16.0.1/"
DEFAULT_CDD_PASSWORD = "EZ4Techs"


class CDD_mng(object):
    ROBOT_LIBRARY_SCOPE = "TEST SUITE"
    _xpath_choose_file_button = "//*[@id='datafile']"
    _xpath_restore_button = "//*[@id='restoreButton']"

    def __init__(self):
        self.driver = None
        self.connected = False
        self.url = None

    def init_driver(self):
        option = webdriver.ChromeOptions()
        option.add_argument("--headless")
        option.add_argument("--ignore-certificate-errors")
        self.driver = webdriver.Chrome(options=option)
        self.driver.implicitly_wait(10)
        self.driver.set_window_position(0, 0)
        self.driver.set_window_size(1920, 1200)
        self.connected = False
        self.url = None

    def connect(self, url, password):
        self.url = url
        self.driver.get(self.url)
        logger.info(f"\n\nCDD IP address = {url}", also_console=True)
        WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located(
                (
                    By.XPATH,
                    "//div[contains(@class,'login')]//input[@id='inputUsername1']",
                )
            )
        )
        self.login(password)

    def login(self, password):
        _xpath_login_username = (
            "//div[contains(@class, 'login')]//input[@id='inputUsername1']"
        )
        _xpath_login_password = (
            "//div[contains(@class, 'login')]//input[@id='inputPassword1']"
        )
        _LOGIN_BUTTON_XPATH = '//*[@id="sign-in"]'
        logger.info(
            f"CDD credentials: username = {USERNAME}, password = {password}\n",
            also_console=True,
        )
        self.driver.find_element_by_xpath(_xpath_login_username).send_keys(USERNAME)
        self.driver.find_element_by_xpath(_xpath_login_password).send_keys(
            password + "\n"
        )
        self.driver.find_element_by_xpath(_LOGIN_BUTTON_XPATH).click()

    def close(self):
        self.driver.quit()

    def choose_backup_and_restore(self, file_name):
        """
        Main Function:
           This keyword is for loading configuration file to CDD.
        Arguments:
           :param file_name: absolute path and name of the config zip file
        """
        _xpath_backup_and_restore = "//a[contains(text(), 'Backup and Restore')]"

        self.switch_to_dedicated_settings_under_system_configuration(
            tab="system settings"
        )
        self.driver.find_element_by_xpath(_xpath_backup_and_restore).click()
        new_file_elem = self.driver.find_element_by_xpath(
            self._xpath_choose_file_button
        )
        logger.info(f"[CDD] Adding new config file: {file_name}", also_console=True)
        new_file_elem.clear()
        new_file_elem.send_keys(file_name)
        self.driver.find_element_by_xpath(self._xpath_restore_button).click()
        logger.info(
            f"[CDD] Restoring the system with reboot - CDD config loading... \n",
            also_console=True,
        )
        self.driver.switch_to_alert().accept()

    def switch_to_dedicated_settings_under_system_configuration(self, tab):
        """
        Main Function:
           This keyword is for switch to tab under system configuration.
        Arguments:
           :param tab: equipment settings or system settings
        Examples:
        Example 1: switch to equipment settings under system configuration
           | switch_to_dedicated_settings_under_system_configuration | tab=equipment settings |
        Example 2: switch to system settings under system configuration
           | switch_to_dedicated_settings_under_system_configuration | tab=system settings |
        """
        logger.info(f"[CDD] Switching tab to '{tab}'", also_console=True)
        dict_setting_to_button = {
            "equipment settings": "equip-settings",
            "system settings": "sys-settings",
        }

        settings_button = dict_setting_to_button.get(tab.lower())
        _xpath_settings_config = f"//div[contains(@class, 'btn-group')]//a[contains(@id, '{settings_button}')]"
        self.driver.find_element_by_xpath(_xpath_settings_config).click()

    def reboot_cdd_system(self):
        """
        Main Function:
           This keyword is for rebooting the whole ERA system.
        """
        _xpath_navigation_panel = "//a[contains(@id, 'nav-user')]"
        _xpath_reboot_system = (
            "//*[contains(@class, 'open')]//a[contains(@id, 'nav-reboot-eng')]"
        )

        self.driver.find_element_by_xpath(_xpath_navigation_panel).click()
        WebDriverWait(self.driver, 5).until(
            EC.element_to_be_clickable((By.XPATH, _xpath_reboot_system))
        ).click()
        logger.info(
            f"[CDD] Rebooting the ERA System... wait a couple of minutes",
            also_console=True,
        )
        self.driver.switch_to_alert().accept()


def cdd_connect_and_load_config_file(
    file_name, cdd_url=DEFAULT_CDD_URL, password=DEFAULT_CDD_PASSWORD
):
    cdd = CDD_mng()
    cdd.init_driver()
    cdd.connect(cdd_url, password)
    cdd.choose_backup_and_restore(file_name)
    time.sleep(10)
    cdd.close()


def reboot_cdd(cdd_url=DEFAULT_CDD_URL, password=DEFAULT_CDD_PASSWORD):
    cdd = CDD_mng()
    cdd.init_driver()
    cdd.connect(cdd_url, password)
    cdd.reboot_cdd_system()
    time.sleep(10)
    cdd.close()


def convert_trunk_sw_version(sw_version):
    return str(sw_version)[:8]
