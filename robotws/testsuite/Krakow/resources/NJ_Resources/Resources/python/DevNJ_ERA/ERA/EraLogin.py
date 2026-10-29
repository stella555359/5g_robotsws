# -*- coding: utf-8 -*-
"""
:author: longmei.zhao
:contact: longmei.zhao@nokia-sbell.com
"""
from robot.api import logger
from selenium.webdriver.common.by import By
import time
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait as Wait
import os
import subprocess


class EraLogin(object):
    def __init__(self, driver=None):
        self._driver = driver

    def login(self, url, user_name, user_password):
        """
        Login ERA Web page
        """
        logger.info("DevNJ_CDD_ERA login", also_console=True)
        _xpath_login_username = "//div[contains(@class, 'login')]//input[@id='inputUsername1']"
        _xpath_login_password = "//div[contains(@class, 'login')]//input[@id='inputPassword1']"

        self._driver.implicitly_wait(15)
        try:
            self._driver.get(url)
        except Exception as e:
            logger.info("Retry driver.get after exception {}".format(str(e)), also_console=True)
            self.clean_browser()
            time.sleep(5)
            self._driver.get(url)
        self._driver.find_element(By.XPATH, _xpath_login_username).send_keys(user_name)
        self._driver.find_element(By.XPATH, _xpath_login_password).send_keys(user_password + '\n')

    def logout(self, timeout=5):
        """
        Logout ERA Web page
        """
        logger.info("DevNJ_CDD_ERA logout", also_console=True)
        Wait(self._driver, timeout).until(EC.element_to_be_clickable(
            (By.XPATH, "//*[contains(@class, 'dropdown-toggle')]"))).click()
        try:
            Wait(self._driver, timeout).until(EC.element_to_be_clickable((By.XPATH, "//*[@title='Log Out']"))).click()
        except Exception as e:
            logger.info("Failed to logout", also_console=True)
        self._driver.quit()

    def clean_browser(self, browser='chrome'):
        """
        Clean browser
        """
        if browser == 'chrome':
            logger.info("open browser to avoid welcome modal", also_console=True)
            subprocess.Popen("google-chrome")
            time.sleep(1)
        cmd = "ps -ef | grep -v 'grep' | grep {} | awk '{{print $2}}' | sudo xargs kill -9".format(
            browser)
        logger.info(cmd, also_console=True)
        os.system(cmd)
