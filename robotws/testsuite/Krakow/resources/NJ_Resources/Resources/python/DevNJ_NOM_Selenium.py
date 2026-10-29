import os
import time
import tempfile
import subprocess
from functools import wraps
from robot.api import logger
from selenium import webdriver
from taf.selenium.nms.nom import *
from selenium.common.exceptions import StaleElementReferenceException


class DevNJ_NOM_Selenium(object):
    """ Library for NOM Test with Selenium
    This Library is for open and login to the NOM and do operations
    """

    """The Scope for the library imported in Robot Framework"""

    # The other 2 options is 'TEST CASE' and 'GLOBAL'
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def catch_exception(func):
        """
        Decorator for keywords need to catch exception and save screenshot
        """

        @wraps(func)
        def interface_func(*args, **kwargs):
            try:
                outcome = func(*args, **kwargs)
            except Exception as e:
                logger.error("Exception:{}".format(str(e)))
                instance = args[0]
                instance.save_screenshot('{}.png'.format(func.__name__))
                raise
            return outcome

        return interface_func

    def __init__(self, virtual_enable=False, ui_delay=1, ui_timeout=5, debug=False):
        """
        Init function

        :param virtual_enable: True for Chrome is visible while False Chrome is invisible
        :param ui_delay: A delay time (in seconds) for WebEm UI, if feel the WebEM respond slow, can enlarge this value
        :param ui_delay: A timeout time (in seconds) waiting for WebEm UI response, if feel the WebEM respond slow,
            can enlarge this value
        :param debug: For debug purpose, that run the python file without robot framework

        Examples:
        Library    ../Resources/python/DevNJ_NOM_Selenium.py  virtual_enable=${FALSE}
        """

        self.ui_delay = ui_delay
        self.ui_timeout = ui_timeout
        self.virtual_enable = virtual_enable
        self.selenium_nom = nom()
        self.wd = None
        self.debug = debug
        self.chrome_driver = r"/opt/ute/chromedriver/chromedriver"
        self.options = webdriver.ChromeOptions()
        self.screenshot_dir = tempfile.mkdtemp(
            prefix='{}_screenshots_'.format(self.__class__.__name__))
        logger.info("DevNJ_NOM_Selenium Init, virtual_enable is {}, screenshot dir {}"
                    .format(self.virtual_enable, self.screenshot_dir), also_console=True)

    def get_self(self):
        """
        keyword get_self,
        This is a helper for robotframework to get the instance, then can pass into
        other keywords as a parameter
        :return: self
        Examples:
        | ${asir_sel} | get_self |
        | bulk_add_prrh_to_full_configuration  ${asir_sel}
        """
        return self

    def set_virtual_enable(self, virtual_enable):
        self.virtual_enable = virtual_enable

    def save_screenshot(self, screenshot_name):
        """
        save_screenshot function, assits user to save a screenshot
        :param screenshot_name: screenshot file name, eg. screenshot_1.png
        Examples:
        self.save_screenshot('screenshot_1.png')
        """
        if not os.path.exists(self.screenshot_dir):
            os.makedirs(self.screenshot_dir)
        screenshot_path = os.path.join(self.screenshot_dir, screenshot_name)
        self.wd.save_screenshot(screenshot_path)
        logger.info('Screenshot save to {}'.format(
            screenshot_path), also_console=True)

    def clean_browser(self, browser='chrome'):
        """
        clean_browser function,  clean reamined webdriver and Chrome process,
            usually used in Suite Setup
        :param browser: browser process partial name
        Examples:
        | clean_browser |
        """
        if browser == 'chrome':
            logger.info("open browser to avoid welcome modal", also_console=True)
            subprocess.Popen("google-chrome")
            time.sleep(1)
        cmd = "ps -ef | grep -v 'grep' | grep {} | awk '{{print $2}}' | sudo xargs kill -9".format(
            browser)
        logger.info(cmd, also_console=True)
        os.system(cmd)

    def nom_web_login(self, url=None, username='neonetics', password='Nextgen#123'):
        """
        login NOM Web page function, setup NOM selenium object and login

        :param url: URL of the NOM Web Page
        :param username: NOM Web Page user name
        :param password: NOM Web Page user password

        Examples:
        | nom_web_login | url=https://neo-hosting-page.neo0039.dyn.nesc.nokia.net/ |
        | ...  username=neonetics | password=Nextgen#123 |
        """
        logger.info("DevNJ_NOM_Selenium login", also_console=True)
        logger.info("virtual_enable:{}".format(self.virtual_enable), also_console=True)

        logger.info("taf Selenium adopted", also_console=True)
        self.selenium_nom = nom()
        # if self.virtual_enable:
        #     logger.info("enable_virtual_display", also_console=True)
        #     self.selenium_nom.enable_virtual_display()

        self.selenium_nom.login(url=url, username=username, password=password)
        # self.wd = self.selenium_nom._driver

    def nom_web_logout(self):
        """
        logout NOM Web Page function
        Examples:
        | nom_web_logout |
        """
        logger.info("DevNJ_NOM_Selenium logout", also_console=True)
        self.selenium_nom.logout()
        # if self.virtual_enable and self.selenium_nom:
        #     time.sleep(1)
        #     self.selenium_nom.disable_virtual_display()

        time.sleep(10)

    def nom_launch_element_manager(self, object_identifier, is_need_login=True, login_username='Nemuadmin',
                                   login_password='nemuuser'):
        """
        enter_config_man keyword, enter configuration manager page after login, usually used in Suite Setup
        :param object_identifier: str, object identifier, as filter, such as MRBTS-1, ASI-1
        :param is_need_login: bool, is need login after launch, default is True
        :param login_username: str, login username, valid when is_need_login is True
        :param login_password: str, login password, valid when is_need_login is True
        :return: None
        Examples:
        | nom_launch_element_manager | MRBTS-11204 | True | Nemuadmin | nemuuser |
        """

        assert object_identifier, "object_identifier is not provided"

        try:
            self.selenium_nom.launch_element_manager(object_identifier, is_need_login, login_username, login_password)
        except StaleElementReferenceException:
            logger.info("StaleElementReferenceException, Try again ...")
            self.selenium_nom.launch_element_manager(object_identifier, is_need_login, login_username, login_password)
        except Exception as e:
            logger.error("Exception in launch element manager is {}".format(e.__class__))
