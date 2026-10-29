import os
import tempfile
import time
import subprocess
import shutil
import traceback
from functools import wraps
from pprint import pprint
from robot.api import logger
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait as Wait
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from collections import OrderedDict
from moler.util.moler_test import MolerTest
from taf.selenium.sbts import sbts
from functools import partial


GROUP_SHUB = 'sHUBs'
GROUP_PRRH = 'pRRHs'
HUB_MOD = 'HUBMOD'
ANT_MOD = 'ANTMOD'
UNIT_MAPPING = {
    GROUP_SHUB: HUB_MOD,
    GROUP_PRRH: ANT_MOD
}

BAND_CLASS = {
    'AWHHC': {
        41: 'ARHHB'
    },
    'AWHHIQB': {
        78: 'ARHQF',
        4: 'ARIC',
        66: 'ARIC',
        7: 'ARHC'
    },
    'AHENB': {
        3: 'AREC',
        40: 'ARNB'
    },
    'AHFHIA': {
        2: 'ARFA',
        25: 'ARFA',
        4: 'ARIA',
        66: 'ARIA',
        7: 'ARHA'
    },
    'AHFIH': {
        2: 'ARFB',
        25: 'ARFB',
        4: 'ARIB',
        66: 'ARIB',
    },
    'AHGEA': {
        1: 'ARGA',
        3: 'AREB'
    },
    'AWHGEQK': {
        1: 'ARGD',
        3: 'AREE',
        78: 'ARHQU'
    },
    'AWHQT': {
        77: 'ARHQS'
    },
    'AWHQK': {
        78: 'ARHQK'
    },
    'AWHENHD': {
        3: 'AREG',
        40: 'ARND',
        41: 'ARHHD'
    },
    'AWHQB': {
        78: 'ARHQB'
    }
}


def catch_exception(func):
    """
    Decorator for keywords need to catch exception and save screenshot
    """

    @wraps(func)
    def interface_func(*args, **kwargs):
        try:
            outcome = func(*args, **kwargs)
        except UserWarning:
            instance = args[0]
            instance.save_screenshot('{}.png'.format(func.__name__))
            raise
        except Exception as e:
            logger.error("Exception:{}".format(str(e)))
            instance = args[0]
            instance.save_screenshot('{}.png'.format(func.__name__))
            raise
        return outcome

    return interface_func


def switch_to_tab(tab, wait_after_switch=True):
    """
    Decorator for keywords that need to switch to spefified tab
    """

    def switch_to_tab_decorator(func):
        @wraps(func)
        def wrapped_function(self, *args, **kwargs):
            self.switch_to_dedicated_tab(tab, wait_after_switch)
            return func(self, *args, **kwargs)

        return wrapped_function

    return switch_to_tab_decorator


class LoginFailException(Exception):
    """Exception raised for failed login attempts."""
    pass


class LoginChangePasswordException(Exception):
    """Exception raised for changing toor4nsn default password, allowAsiDefaultPassword = false."""
    pass


class DowngradedPrivilegesBannerMissingException(Exception):
    """Exception raised for lack of 'Downgraded privileges' banner in the case of Read-only login."""
    pass


class AsirSelenium(object):
    """ Library for ASIR WebEm Test with Selenium
    This Library is for open and login to the ASIR WebEM and do operations
    """

    """The Scope for the library imported in Robot Framework"""

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    CONFIG_MAN_SUB_MENU_BUTTON_IDS = {
        'edit': 'editCurrentStartButton',
        'edit_offline': 'editSnapshotConfigurationStartButton',
        'detect': 'generateFromDetectedStartButton',
        'view': 'viewCurrentStartButton',
        'view_offline': 'viewSnapshotConfigurationStartButton',
        'reset': 'configResetStartButton',
        'save': 'saveBackupStartButton',
        'load file': 'configFromFileStartButton',
        'airscale': 'importAirScaleStartButton',
        'create new configuration': 'createFromScratchStartButton',
        'continue': 'continueCurrentContinueButton',
        'accounts': 'accountsStartButton',
        'load template': 'createFromTemplateStartButton'
    }
    XPATH_LOGIN_ERROR_MESSAGE = "//div[@id='errorAuthLogin']"
    XPATH_DOWNGRADED_PRIVILEGES_BUTTON = "//*[@id='downgrade-privilege-modal']/div[2]/footer/div/div[2]/div/button"
    XPATH_USER_DROPDOWN_MENU = "//*[@id='user-information']"
    XPATH_USERNAME = "//span[@id='current-user-name']"
    XPATH_USER_ROLE = "//*[@id='user-dropdown-content']/div[1]/div"
    XPATH_USER_ACCESS_MODE = "//div[@id='access-mode']/span"
    XPATH_USER_ACCOUNT_TYPE = "//div[@id='account-type']/span"
    XPATH_USER_LAST_LOGIN_TIME = "//div[@id='last-login-time']/span"
    XPATH_USER_INVALID_LOGIN_ATTEMPTS = "//div[@id='invalid-login-attempts']/span"

    def __init__(self, virtual_enable=False, ui_delay=1, ui_timeout=5, debug=False, wd=None):
        """
        Init function
        :param virtual_enable: True for Chrome is visible while False Chrome is invisible
        :param ui_delay: A delay time (in seconds) for WebEm UI,
                         if you feel the WebEM respond slow, can enlarge this value
        :param ui_timeout: A timeout time (in seconds) waiting for WebEm UI response,
                         if you feel the WebEM respond slow, can enlarge this value
        :param debug: For debug purpose, that run the python file without robotframework
        """

        self.ui_delay = ui_delay
        self.ui_timeout = ui_timeout
        self.virtual_enable = virtual_enable
        self.selenium_coam = None
        self.web_driver = wd
        self.debug = debug
        self.width = 1920
        self.height = 4000
        self.options = webdriver.FirefoxOptions()
        self.options.add_argument("--width=1920")
        self.options.add_argument("--height=1080")
        self.screenshot_dir = tempfile.mkdtemp(
            prefix='{}_screenshots_'.format(self.__class__.__name__))
        self.node_expanded_in_view = ['ASI-1']
        self.check_loading_spinner = True

    def set_virtual_enable(self, virtual_enable, width=1920, height=4000):
        self.virtual_enable = virtual_enable
        self.width = width
        self.height = height

    def save_screenshot(self, screenshot_name):
        """
        save_screenshot function, assits user to save a screenshot
        :param screenshot_name: screenshot file name, e.g. screenshot_1.png
        Examples:
        self.save_screenshot('screenshot_1.png')
        """
        if not os.path.exists(self.screenshot_dir):
            os.makedirs(self.screenshot_dir)
        screenshot_path = os.path.join(self.screenshot_dir, screenshot_name)
        self.web_driver.save_screenshot(screenshot_path)
        logger.info('Screenshot save to {}'.format(
            screenshot_path), also_console=True)

    def clean_browser(self, browser='firefox'):
        """
        clean_browser function,  clean reamined webdriver and chrome process,
            usually used in Suite Setup
        :param browser: browser process partial name
        Examples:
        | clean_browser |
        """

        if self.web_driver:
            try:
                self.web_driver.quit()
            except Exception as e:
                logger.info("{}: {}".format(__name__, str(e)))
            self.web_driver = None
        if self.selenium_coam:
            self.selenium_coam = None
        if browser == 'chrome':
            logger.info("Open browser to avoid welcome modal", also_console=True)
            subprocess.Popen("google-chrome")
            time.sleep(1)
        cmd = "ps -ef | grep -v 'grep' | grep {} | awk '{{print $2}}' | sudo xargs kill -9".format(
            browser)
        logger.info(cmd, also_console=True)
        os.system(cmd)
        time.sleep(5)

    @catch_exception
    def _login(self, url='https://192.168.255.129:3601', user_name='Nemuadmin', user_password='nemuuser',
               online_mode=True, read_only=False):
        _xpath_login_username = "//div[@id='usernameForm']//input"
        _xpath_login_password = "//div[@id='passwordForm']//input"
        _xpath_read_only_login_checkbox = "//mat-checkbox[@id='read-only']"
        _xpath_config_man_header = "//div[@id='commissioning-header']"

        xpath_read_only_btn = "//button[contains(text(), 'Read-only log in')]"

        logger.info("virtual_enable:{}".format(self.virtual_enable), also_console=True)
        logger.info("taf Selenium adopted", also_console=True)
        if not self.selenium_coam:
            self.selenium_coam = sbts()
            if self.virtual_enable:
                logger.info("enable_virtual_display", also_console=True)
                self.selenium_coam.enable_virtual_display(width=self.width, height=self.height)
            self.web_driver = self.selenium_coam._configure_before_login("Firefox", None,
                                                                         "/home/ute/Downloads", None)._driver
            self.web_driver.set_window_position(0, 0)
        self.web_driver.implicitly_wait(15)

        try:
            if self.web_driver.window_handles:
                self.web_driver.execute_script("window.open()")
                self.web_driver.switch_to.window(self.web_driver.window_handles[-1])
            self.web_driver.get(url)

        except Exception as Ex:
            logger.info("Retry web_driver.get operation after exception {0}".format(str(Ex)), also_console=True)
            self.clean_browser()
            time.sleep(20)
            self.web_driver.get(url)
            self.web_driver.manage().window().maximize()

        if not online_mode:
            logger.info("ASIR WebEM running with offline mode!", also_console=True)
            time.sleep(6)
            Wait(self.web_driver, self.ui_delay).until(EC.visibility_of_element_located(
                (By.XPATH, _xpath_config_man_header)))
        else:
            logger.debug("ASIR WebEM running with online mode!")

            if read_only:
                self.web_driver.find_element(By.XPATH, _xpath_read_only_login_checkbox).click()
            self.web_driver.find_element(By.XPATH, _xpath_login_username).send_keys(user_name)
            self.web_driver.find_element(By.XPATH, _xpath_login_password).send_keys(user_password)
            _xpath_login_button = '//button[contains(text(), "Log in")]'
            login_button = self.web_driver.find_elements(By.XPATH, _xpath_login_button)
            login_button = login_button[0] if login_button else None
            login_button.click()

            time.sleep(self.ui_delay)
            login_error_message_item = self.web_driver.find_elements(By.XPATH, AsirSelenium.XPATH_LOGIN_ERROR_MESSAGE)
            if login_error_message_item:
                raise LoginFailException(
                    "Authentication failed with message: {}".format(login_error_message_item[0].text))

            read_buttons = self.web_driver.find_elements(By.XPATH, xpath_read_only_btn)
            read_button = read_buttons[0] if read_buttons else None
            if read_button:
                read_button.click()
                logger.info("You will get ASIR webEM read only permission.")
            else:
                logger.info("You will get ASIR webEM read write permission.")

    @catch_exception
    def accept_legal_info(self, timeout=20):
        xpath_legal_info = "//div[@class='modal-panel']//div[contains(text(), 'Legal information')]"
        xpath_accept_button = "//div[@id='legal-info-modal']//button[text()='Accept']"
        xpath_session_exceed = "//div[@id='errorAuthLogin' and contains(text(), 'exceeded')]"

        wait = Wait(self.web_driver, timeout)
        try:
            wait.until(EC.visibility_of_element_located((By.XPATH, xpath_legal_info)))

        except Exception as e:
            try:
                max_session = self.web_driver.find_element(By.XPATH, xpath_session_exceed)
            except NoSuchElementException:
                raise e
            if max_session:
                raise Exception("Maximum number of sessions is exceeded.")

        accept_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_accept_button)))
        accept_button.click()

    def close_downgraded_privileges_banner(self):
        time.sleep(self.ui_delay)
        downgraded_privileges_buttons = self.web_driver.find_elements(By.XPATH,
                                                                      AsirSelenium.XPATH_DOWNGRADED_PRIVILEGES_BUTTON)
        if downgraded_privileges_buttons:
            downgraded_privileges_buttons[0].click()
            logger.info("'Downgraded privileges' banner closed")
        else:
            raise DowngradedPrivilegesBannerMissingException("Expected 'Downgraded privileges' banner but not present")

    def handle_enforcing_toor4nsn_password_change(self, toor4nsn_new_password=None,
                                                  toor4nsn_correct_regex_password=None, timeout=20):
        _xpath_force_change_password_ = "//div[@id='update-default-password-modal']//app-form-input//input"
        _xpath_force_change_repeat_password_ = "//div[@id='update-default-password-modal']//app-form-input[2]//input"
        xpath_confirm_button = '//*[@id="update-default-password-modal"]/div[2]/footer/div/div[2]/div[1]/button'

        wait = Wait(self.web_driver, timeout)
        time.sleep(self.ui_delay)
        if not toor4nsn_new_password:
            raise LoginFailException("Password change required, but no new passwords provided.")
        else:
            self.web_driver.find_element(
                By.XPATH, _xpath_force_change_password_).send_keys(toor4nsn_new_password)
            self.web_driver.find_element(
                By.XPATH, _xpath_force_change_repeat_password_).send_keys(toor4nsn_new_password)
            try:
                confirm_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_confirm_button)))
                confirm_button.click()
                logger.info("The default password has been changed", also_console=True)
                self.accept_legal_info(timeout=timeout)
            except TimeoutException:
                raise LoginFailException("Incorrect Regex. Unable to click confirm button")

    @catch_exception
    def login(self, url='https://192.168.255.129:3601', user_name='Nemuadmin', user_password='nemuuser',
              online_mode=True, timeout=20):
        self._login(url=url, user_name=user_name, user_password=user_password, online_mode=online_mode, read_only=False)
        if online_mode:
            self.accept_legal_info(timeout=timeout)

    @catch_exception
    def login_with_downgraded_privileges(self, url='https://192.168.255.129:3601', user_name='Nemuadmin',
                                         user_password='nemuuser', read_only_checkbox=True, online_mode=True,
                                         timeout=20):
        """
        Read-only login - with downgraded privileges handling
        :param url: URL
        :param user_name: username
        :param user_password: user password
        :param read_only_checkbox: True for read-only checkbox checked, False for unchecked, default: True
        :param online_mode: flag to indicate ASIR WebEM running with online or offline mode
        :param timeout: timeout for waiting for WebDriver when accepting legal info
        """
        if read_only_checkbox:
            logger.info("Argument read_only_checkbox=True. Will log in with 'read-only session' checkbox",
                        also_console=True)
        else:
            logger.info("Argument read_only_checkbox=False. Will log in without 'read-only session' checkbox",
                        also_console=True)

        self._login(url=url, user_name=user_name, user_password=user_password, online_mode=online_mode,
                    read_only=read_only_checkbox)
        if online_mode:
            self.accept_legal_info(timeout=timeout)
            self.close_downgraded_privileges_banner()

    @catch_exception
    def login_and_return_error_message(self, url='https://192.168.255.129:3601', user_name='Nemuadmin',
                                       user_password='nemuuser', timeout=20):
        try:
            self._login(url=url, user_name=user_name, user_password=user_password, online_mode=True)
        except LoginFailException as e:
            if str(e).startswith("Authentication failed with message: "):
                return str(e).removeprefix("Authentication failed with message: ")
            else:
                raise e

        raise LoginFailException("Fail due to login successful, while expected login rejection.")

    @catch_exception
    def login_with_toor4nsn_password_change(self, toor4nsn_new_password, toor4nsn_correct_regex_password,
                                            url='https://192.168.255.129:3601', user_name='Nemuadmin',
                                            user_password='nemuuser', online_mode=True, timeout=20):
        self._login(url=url, user_name=user_name, user_password=user_password, online_mode=online_mode)
        if online_mode:
            self.handle_enforcing_toor4nsn_password_change(
                toor4nsn_new_password, toor4nsn_correct_regex_password, timeout=timeout)

    @catch_exception
    def login_with_password_handling(self, **kwargs):
        _xpath_force_change_password_ = "//div[@id='update-default-password-modal']//app-form-input//input"
        _xpath_force_change_repeat_password_ = "//div[@id='update-default-password-modal']//app-form-input[2]//input"
        xpath_confirm_button = '//*[@id="update-default-password-modal"]/div[2]/footer/div/div[2]/div[1]/button'
        xpath_legal_info = "//div[@class='modal-panel']//div[contains(text(), 'Legal information')]"
        xpath_accept_button = "//div[@id='legal-info-modal']//button[text()='Accept']"
        try:
            self.login_with_toor4nsn_password_change(**kwargs)
        except LoginFailException as e:
            logger.info(f"Password change failed, {e}", also_console=True)
            toor4nsn_correct_regex_password = kwargs.get('toor4nsn_correct_regex_password', 'oZPS0POrRieRt#2')
            timeout = kwargs.get('timeout', 20)
            wait = Wait(self.web_driver, timeout)
            self.web_driver.find_element(By.XPATH, _xpath_force_change_password_).clear()
            self.web_driver.find_element(By.XPATH, _xpath_force_change_repeat_password_).clear()
            self.web_driver.find_element(
                By.XPATH, _xpath_force_change_password_).send_keys(toor4nsn_correct_regex_password)
            self.web_driver.find_element(
                By.XPATH, _xpath_force_change_repeat_password_).send_keys(toor4nsn_correct_regex_password)
            confirm_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_confirm_button)))
            confirm_button.click()
            logger.info("Correct Regex. The default password has been changed", also_console=True)
            wait.until(EC.visibility_of_element_located((By.XPATH, xpath_legal_info)))
            accept_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_accept_button)))
            accept_button.click()

    @catch_exception
    def logout(self, online_mode=True):
        """
        logout function, usually used in Suite Teardown
        :param online_mode: flag to indicate ASIR WebEM running with online or offline mode
        Examples:
        | logout |
        | Suite Teardown | logout |
        """
        if online_mode:
            self.web_driver.find_element(By.XPATH, "//*[@id='user-information']").click()
            try:
                Wait(self.web_driver, 5).until(EC.element_to_be_clickable((By.XPATH, "//*[@id='log_out']"))).click()
            except Exception as e:
                logger.info("Failed to logout", also_console=True)
        self.web_driver.quit()
        if self.virtual_enable and self.selenium_coam:
            self.selenium_coam.disable_virtual_display()
        self.selenium_coam = None
        time.sleep(35)

    @catch_exception
    def enter_config_man(self, sub_menu="Edit", overwrite=True, timeout=60):
        """
        Enter config
        :param sub_menu: Submenu - one of keys defined in CONFIG_MAN_SUB_MENU_BUTTON_IDS,
                         None for not entering any Submenu,
        :param overwrite: True for overwrite last modification, False for continue with last modification
        :param timeout: Maximum seconds for waiting for the configuration manangement page available
        :return: None
        """
        returned_time_cost = {}
        timeout = int(timeout)
        _xpath_config_man_button = "//*[@href='#/commissioning/cards']"
        _xpath_config_man_overwrite_button = "//div[@id='overwrite-modal']//button[text()='Overwrite']"
        _xpath_config_man_continue_button = "//*[@id='continueCurrentContinueButton']"
        _xpath_config_man_header = "//div[@id='commissioning-header']"
        _xpath_stepper_cancel_button = "//button[contains(@id,'cancel-button')]"
        _xpath_icon_backup_prepared = "//app-backup-prepared//mat-icon[@svgicon='doneIcon']"

        self.web_driver.find_element(By.XPATH, _xpath_config_man_button).click()
        if sub_menu is None:
            return
        start_button_id = AsirSelenium.CONFIG_MAN_SUB_MENU_BUTTON_IDS.get(sub_menu.lower())
        assert (start_button_id is not None), "Failed to find start button id of '{}'".format(sub_menu)
        _xpath_config_man_start_button = "//*[@id='{}']".format(start_button_id)

        if overwrite:
            config_man_start_button = \
                Wait(self.web_driver, self.ui_delay * 5).until(
                    EC.element_to_be_clickable((By.XPATH, _xpath_config_man_start_button)))
            config_man_start_button.click()

            try:
                Wait(self.web_driver, self.ui_delay * 5).until(
                    EC.invisibility_of_element_located((By.XPATH, _xpath_config_man_start_button)))
            except Exception as e:
                logger.warn("config management start button not appeared after clicked, retry once".format(str(e)))
                config_man_start_button = \
                    Wait(self.web_driver, self.ui_delay * 5).until(
                        EC.element_to_be_clickable((By.XPATH, _xpath_config_man_start_button)))
                config_man_start_button.click()

            try:
                overwrite_btn = Wait(self.web_driver, self.ui_delay).until(EC.element_to_be_clickable(
                    (By.XPATH, _xpath_config_man_overwrite_button)))
                overwrite_btn.click()
            except Exception as e:
                logger.debug("overwrite button not clicked: {}".format(str(e)))

        else:
            self.web_driver.find_element(
                By.XPATH, _xpath_config_man_continue_button).click()

        dt_start = time.time()
        time.sleep(self.ui_delay)
        config_man_header_str = None
        while time.time() < dt_start + timeout:
            config_man_header = self.web_driver.find_elements(By.XPATH, _xpath_config_man_header)
            if config_man_header:
                config_man_header_str = config_man_header[0].get_attribute('textContent')
                if "offline" in sub_menu.lower():
                    if sub_menu.split('_')[0].lower() in config_man_header_str.lower():
                        break
                else:
                    if sub_menu.split()[-1].lower() in config_man_header_str.lower():
                        break
            time.sleep(1)
        else:
            raise Exception("Failed to enter ui of [{}]".format(config_man_header_str))

        if sub_menu.lower() == 'save':
            Wait(self.web_driver, timeout).until(EC.visibility_of_element_located(
                (By.XPATH, _xpath_icon_backup_prepared)))
        else:
            Wait(self.web_driver, timeout).until(EC.element_to_be_clickable(
                (By.XPATH, _xpath_stepper_cancel_button)))

        time_cost = round(time.time() - dt_start, 3)
        logger.trace("enter_config_man time cost {}s".format(time_cost))
        returned_time_cost['time_cost'] = time_cost

    @catch_exception
    def switch_to_dedicated_tab(self, tab, wait_after_switch=True, timeout=8):
        """
        switch_to_dedicated_tab keyword, enter specified tab after keyword enter_config_man
        :param tab: tab name
        :param timeout: Maximum waiting seconds before clicking the tab's button
        :param wait_after_switch: Need wait for a while after switch
        Examples:
        | switch_to_dedicated_tab | tab=Cells |
        """
        print("User new function switch_to_dedicated_tab")
        timeout = int(timeout)
        tab = tab.lower().strip()
        _xpath_tabs = "//div[@id='stepper-buttons']//button[contains(@id,'step-button')]"
        xpath_div_loading_spinner_overlay = "//app-parameters-view//div[@class='loading-spinner-overlay']"
        wait_loading_visible = Wait(self.web_driver, 1)
        wait_loading_invisible = Wait(self.web_driver, 5)
        list_step_button_text = []
        list_step_button_active = []

        index_cur_active_tab = -1
        for i, step_button in enumerate(self.web_driver.find_elements(By.XPATH, _xpath_tabs)):
            button_text = step_button.get_attribute('textContent').lower().strip()
            list_step_button_text.append(button_text)
            if 'active' in step_button.get_attribute('class').lower().strip():
                list_step_button_active.append(button_text)
                index_cur_active_tab = i

        assert len(list_step_button_text) > 0, "Empty step buttons"
        assert len(list_step_button_active) in [0, 1], "Active tab not valid: {}".format(list_step_button_active)
        assert tab in list_step_button_text, "target tab not in {}".format(list_step_button_text)
        index_target_active_tab = list_step_button_text.index(tab)

        while index_cur_active_tab != index_target_active_tab:
            spinner = None
            try:
                spinner = wait_loading_visible.until(EC.visibility_of_element_located(
                    (By.XPATH, xpath_div_loading_spinner_overlay)))
            except Exception as e:
                pass
            if spinner:
                wait_loading_invisible.until(EC.invisibility_of_element_located(
                    (By.XPATH, xpath_div_loading_spinner_overlay)))

            _xpath_button_to_click = "//button[@id = 'stepper-next-button']" \
                if index_target_active_tab > index_cur_active_tab else "//button[@id='stepper-previous-button']"
            Wait(self.web_driver, timeout).until(EC.element_to_be_clickable((
                By.XPATH, _xpath_button_to_click))).click()
            _xpath_active_tab = \
                "//div[@id='stepper-buttons']//button[contains(@id,'step-button') and contains(@class, 'active')]"
            cur_active_tab = \
                Wait(self.web_driver,
                     timeout).until(EC.element_to_be_clickable((By.XPATH, _xpath_active_tab))).get_attribute(
                    'textContent').lower().strip()
            index_cur_active_tab = list_step_button_text.index(cur_active_tab)

        else:
            logger.info("tab '{}' is already active in all tabs {}".format(tab, list_step_button_text))
            if wait_after_switch:
                time.sleep(self.ui_delay * 3)

    @switch_to_tab('Parameter editor')
    @catch_exception
    def prevalidate(self, timeout=120):
        """
        prevalidate keyword, switch to tab 'Parameter editor', click button 'Prevalidate' on tab 'Parameter editor',
        :param timeout: Maxium seconds for prevalidation
        :return: None
        Examples:
        | ${dict_res_prevalidate} | prevalidate |
        :return dict_res_prevalidate: A dictionary of the prevalidate result
        """
        returned_time_cost = {}
        timeout = int(timeout)
        dict_ret = {}
        xpath_prevalidate_btn = "//button[@id='run-prevalidation-btn']"
        xpath_all_error_nav_a_with_errors = "//div[@id='parameter-editor-tabs']" \
                                            "//a[contains(text(),'errors')]//div[contains(@class,'error-value')]/.. "
        xpath_error_table_rows = "//div[@id='parameter-editor-tab-content']//app-errors-table/*/*/table/tbody/tr"

        wait = Wait(self.web_driver, timeout)
        try:
            prevalidate_btn = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_prevalidate_btn)))
            prevalidate_btn.click()
        except Exception as e:
            logger.info("try to click prevalidate button, due to exception {}".format(str(e)), also_console=True)
            prevalidate_btn = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_prevalidate_btn)))
            prevalidate_btn.click()

        dt_start = time.time()
        xpath_toast_prevalidate_result = "//div[@id='toast-container']" \
                                         "//div[contains(text(),'Prevalidation finished')]"

        toast_prevalidate_result = \
            wait.until(EC.visibility_of_element_located((By.XPATH, xpath_toast_prevalidate_result)))
        if toast_prevalidate_result:
            text_prevalidate_result = toast_prevalidate_result.get_attribute('textContent')
            logger.info('Prevalidate result: {}'.format(
                text_prevalidate_result), also_console=True)
        returned_time_cost['time_cost'] = time.time() - dt_start

        xpath_prevalidate_btn = "//button[@id='run-prevalidation-btn' and contains(@class, 'success')]"
        try:
            prevalidate_btn = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_prevalidate_btn)))
        except TimeoutException:
            prevalidate_btn = None
        if prevalidate_btn:
            dict_ret['ret'] = True
            return dict_ret
        dict_ret['ret'] = False
        error_navs = self.web_driver.find_elements(
            By.XPATH, xpath_all_error_nav_a_with_errors)
        if not error_navs:
            dict_ret['info'] = 'Failed to pick errors'
            return dict_ret

        for err_nav in error_navs:
            nav_header = err_nav.text.split('\n')[0].strip()
            dict_ret[nav_header] = {}
            dict_errs_in_nav = dict_ret[nav_header]
            err_nav.click()
            logger.info('enter nav: {}'.format(
                err_nav.text), also_console=True)
            error_rows = self.web_driver.find_elements(
                By.XPATH, xpath_error_table_rows)
            cur_severity = None
            cur_mo = None
            cur_desc = None
            logger.info('error row cnt: {}'.format(
                len(error_rows)), also_console=True)
            for i, err_row in enumerate(error_rows):
                all_tds = err_row.find_elements(By.XPATH, ".//td")
                for td in all_tds:
                    if 'mat-column-severity' in td.get_attribute('class').lower():
                        span_severities = td.find_elements(By.XPATH, ".//span")
                        if span_severities:
                            cur_severity = span_severities[0].text

                    elif 'mat-column-managed-object' in td.get_attribute('class').lower():
                        div_mo = td.find_elements(By.XPATH, './/div')
                        if div_mo:

                            mo_name = div_mo[0].text.strip()
                            if mo_name:
                                if mo_name != cur_mo:
                                    cur_mo = mo_name
                                    cur_desc = None
                            if cur_mo and cur_mo not in dict_errs_in_nav:
                                dict_errs_in_nav[cur_mo] = {}
                    elif 'mat-column-affected-parametersexpanded' in td.get_attribute('class').lower():
                        div_affected_par = td.find_elements(By.XPATH, './/div')
                        if div_affected_par:
                            affected_par = div_affected_par[0].text.strip()
                            if affected_par:
                                if affected_par not in dict_errs_in_nav[cur_mo]:
                                    dict_errs_in_nav[cur_mo][affected_par] = {}
                                dict_errs_in_nav[cur_mo][affected_par]['desc'] = cur_desc
                                dict_errs_in_nav[cur_mo][affected_par]['severity'] = cur_severity
                    elif 'mat-column-detailed-error-description' in td.get_attribute('class').lower():
                        if td.text.strip():
                            cur_desc = td.text.strip()

        pprint(dict_ret)
        return dict_ret

    def activate(self, as_full_configuration=None, timeout=180):
        """
        activate keyword, switch to tab 'Activation',
            toggle/untoggle the checkbox 'as_full_configuration', click button 'Activate'
        :param as_full_configuration: None for neglect the Full Configuration checkbox,
                                      True for activate as full configuration
                                      False for activate not as full configuration
        :param timeout: waiting timeout seconds for button or dialog apprearance
        :return: None
        Examples:
        | activate |
        | activate | as_full_configuration=${True} |
        | ${dict_res} | activate | as_full_configuration=${False} |
        :return dict_res_prevalidate: A dictionary of the activation result
        """
        return self._activate_common(as_full_configuration, timeout)

    @switch_to_tab('Activation')
    @catch_exception
    def _activate_common(self, as_full_configuration=None, timeout=180):
        timeout = int(timeout)
        returned_time_cost = {}
        dict_ret = {}
        xpath_activate_btn = "//button[@id='run-activation-btn']"
        xpath_full_checkbox = "//input[@id='activate-as-full-checkbox-input']"
        xpath_full_checkbox_outer = "//mat-checkbox[@id='activate-as-full-checkbox']"
        xpath_validation_modal = "//div[@id='validation-config-error-modal']"
        xpath_validation_modal_close_btn = "{}//button[contains(text(),'Close')]".format(
            xpath_validation_modal)
        xpath_next_btn = "//button[@id='stepper-next-button']"
        xpath_finish_btn = "//button[@id='stepper-finish-button']"
        xpath_validating_label = "//div[@class ='commissioning-stepper']" \
                                 "//app-operation-progress[contains(@operationtitle, 'Validating')]"

        logger.info('Activate with Full Configuration {}'.format(
            as_full_configuration))
        if as_full_configuration is not None:
            checkbox_mode_full = self.web_driver.find_element(By.XPATH, xpath_full_checkbox_outer)
            checkbox_mode_disabled = 'mat-checkbox-disabled' in checkbox_mode_full.get_attribute(
                'class').split()
            if not checkbox_mode_disabled:
                logger.info('Activate Mode Checkbox is enabled')
                is_full_checked = 'mat-checkbox-checked' in checkbox_mode_full.get_attribute('class').split()
                if is_full_checked != as_full_configuration:
                    logger.info('Change Activate Mode to {}'.format(
                        as_full_configuration))
                    self.web_driver.find_element(
                        By.XPATH, xpath_full_checkbox_outer).click()
                    is_full_checked = 'mat-checkbox-checked' in checkbox_mode_full.get_attribute('class').split()
                    assert (is_full_checked == str(as_full_configuration).lower()), \
                        'Failed to set full configuration to be {}'.format(
                            as_full_configuration)
                else:
                    logger.info('Activation Full configuration is already {}, need not change'.format(
                        is_full_checked))
            else:
                logger.info('Activate Mode Checkbox is disabled')
        else:
            logger.info('Activate without Mode Change')
        checkbox_mode_full = self.web_driver.find_element(By.XPATH, xpath_full_checkbox_outer)
        is_full_checked = 'mat-checkbox-checked' in checkbox_mode_full.get_attribute('class').split()
        logger.info('Activate Mode on Checkbox is {}'.format(is_full_checked))
        dt_start = time.time()
        self.web_driver.find_element(By.XPATH, xpath_activate_btn).click()

        header_validating = None
        try:
            wait = Wait(self.web_driver, 5)
            header_validating = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_validating_label)))
            logger.info('Header of "Validating config" appeared', also_console=True)

        except TimeoutException:
            logger.info('Header of "Validating config" not appear', also_console=True)

        if header_validating:
            try:
                wait = Wait(self.web_driver, timeout)
                wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_validating_label)))
                logger.info('Header of "Validating config" disappeared', also_console=True)
            except TimeoutException:
                logger.info('Header of "Validating config" cannot disappear', also_console=True)

        returned_time_cost['time_cost_validation'] = time.time() - dt_start
        logger.info('validation time cost {:.03f}'.format(returned_time_cost['time_cost_validation']))

        modal_validation = None
        try:
            wait = Wait(self.web_driver, 10)
            modal_validation = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_validation_modal)))
        except TimeoutException:
            logger.info('Validation ERR Modal not appear')

        if modal_validation is None:
            wait = Wait(self.web_driver, timeout)
            dict_ret['ret'] = True

            if is_full_checked:
                next_btn = wait.until(
                    EC.element_to_be_clickable((By.XPATH, xpath_next_btn)))
                next_btn.click()
            dt_start = time.time()
            try:
                finish_btn = wait.until(
                    EC.element_to_be_clickable((By.XPATH, xpath_finish_btn)))
                finish_btn.click()
                returned_time_cost['time_cost_next_to_finish'] = time.time() - dt_start
            except Exception as e:
                screenshot_name = 'activate_finish_button_not_clickable.png'
                logger.warn('Finish button not clickable in {} seconds, screenshot:{}'.format(
                    timeout, screenshot_name))
                raise e

        else:
            dict_ret['ret'] = False
            dict_ret['info'] = self.web_driver.find_element(
                By.XPATH, "{}//div[@class='content']".format(xpath_validation_modal)).text
            self.web_driver.find_element(
                By.XPATH, xpath_validation_modal_close_btn).click()

        return dict_ret

    @switch_to_tab('Parameter editor')
    @catch_exception
    def modify_parameter(self, list_para):
        """
        modify_parameter keyword, switch to tab 'Parameter editor', modify the parameter specified in list_para
        :param list_para: the parameter key value list
        Examples:
        | ${text_para_dict_1} | create dictionary | para_mo=ASI-1/ANTMODPR-2 | para_abbr=prodCode | value=123456 |
        | ${text_para_list_to_modify} | create list | ${text_para_dict_1} |
        | modify_parameter | ${text_para_list_to_modify} |
        """
        xpath_search_par = "//*[@id='search-input']//input"
        xpath_search_table = "//app-search-results-table//tbody"
        xpath_rel_result_row_col_mo = ".//tr/td[1]"

        xpath_edit_table = "//app-parameters-view//tbody"
        xpath_edit_table_td_span = ".//tr/td//span"
        input_search = self.web_driver.find_element(By.XPATH, xpath_search_par)

        for para in list_para:
            input_search.clear()
            input_search.send_keys(para['para_abbr'])
            input_search.send_keys(Keys.ENTER)
            time.sleep(self.ui_delay * 2)
            table_search_result = self.web_driver.find_element(
                By.XPATH, xpath_search_table)

            last_shown_mo_abbrs = []
            tm_start = time.time()
            while time.time() < tm_start + self.ui_timeout:
                if self.web_driver.find_elements(By.XPATH, xpath_search_table + "//tr"):
                    break
                time.sleep(self.ui_delay)
            else:
                raise Exception("No entry in search result")

            mo_td_found_in_search_result = None
            while not mo_td_found_in_search_result:
                cur_shown_mo_abbrs = []
                retry_times = 0
                while retry_times < 3:
                    retry_times += 1
                    time.sleep(self.ui_delay)
                    all_mo_tds_in_search_result = table_search_result.find_elements(
                        By.XPATH, xpath_rel_result_row_col_mo)
                    last_mo_td = None
                    try:
                        for mo_td in all_mo_tds_in_search_result:
                            if mo_td.text.strip() == para['para_mo']:
                                mo_td_found_in_search_result = mo_td
                                break
                            cur_shown_mo_abbrs.append(mo_td.text.strip())
                            last_mo_td = mo_td
                        else:
                            logger.info("cur_shown_mo_abbrs: {}".format(cur_shown_mo_abbrs))
                            logger.info("last_shown_mo_abbrs: {}".format(last_shown_mo_abbrs))
                            if cur_shown_mo_abbrs == last_shown_mo_abbrs:
                                raise Exception("No entry in search result after rolled")
                            last_shown_mo_abbrs = cur_shown_mo_abbrs
                            logger.info("Target MO not shown, need to scroll")
                            self.web_driver.execute_script("arguments[0].scrollIntoView();", last_mo_td)
                        break
                    except Exception as e:
                        logger.info("retry time {}: {}".format(retry_times, str(e)))
                        continue

            if not mo_td_found_in_search_result:
                raise Exception("No matched entry in search result")

            mo_td_found_in_search_result.click()
            time.sleep(self.ui_delay * 2)
            table_para_edit = self.web_driver.find_element(By.XPATH, xpath_edit_table)
            tm_start = time.time()
            mo_td_span_found = None
            while not mo_td_span_found and time.time() < tm_start + self.ui_timeout:
                all_mo_td_spans = table_para_edit.find_elements(
                    By.XPATH, xpath_edit_table_td_span)
                for mo_td_span in all_mo_td_spans:
                    if mo_td_span.text.strip() == para['para_abbr']:
                        mo_td_span_found = mo_td_span
                        break

            assert (mo_td_span_found is not None), 'No entry in edit table'
            mo_tr = mo_td_span_found.find_element(By.XPATH, "ancestor::tr")
            mo_tr_edit_field = mo_tr.find_element(
                By.XPATH, ".//*[contains(@class,'parameterValue')]")
            if mo_tr_edit_field.tag_name == 'mat-select':
                self._select_value_in_mat_select(
                    mo_tr_edit_field, para['value'], lambda x, y: x.strip() == y.strip())
            else:
                assert ('true' != mo_tr_edit_field.get_attribute(
                    'disabled')), "Text parameter value is disabled"
                mo_tr_edit_field.clear()
                mo_tr_edit_field.send_keys(para['value'])
                mo_tr_name_field = mo_tr.find_element(By.XPATH, ".//*[contains(@class,'parameterName')]")
                mo_tr_name_field.click()
                time.sleep(2)

    def _select_value_in_mat_select(self, elem_mat_select, option, compare_method, check_required=True, timeout=2):
        """
        _select_value_in_mat_select function, select an option in a mat-select web element
        """
        def dyn_elem():
            return elem_mat_select() if isinstance(elem_mat_select, partial) else elem_mat_select

        timeout = int(timeout)
        tm_start = time.time()
        while time.time() < tm_start + timeout:
            if 'pulldown' not in dyn_elem().get_attribute('class'):
                break
        assert ('pulldown' not in dyn_elem().get_attribute(
            'class')), "Select parameter value is disabled"
        time.sleep(self.ui_delay)
        xpath_div_spinner_container = "//div[@class='spinner-container']"
        Wait(self.web_driver, 5).until_not(EC.visibility_of_element_located((
            By.XPATH, xpath_div_spinner_container)))
        dyn_elem().find_element(By.XPATH, './/..').click()
        time.sleep(self.ui_delay)
        all_mat_options = self.web_driver.find_elements(By.XPATH, "//mat-option")
        all_mat_options_text_list = []
        for mat_option in all_mat_options:
            all_mat_options_text_list.append(mat_option.text.strip())
            if compare_method(mat_option.text, option):
                assert (mat_option.get_attribute('aria-disabled') == 'false'), \
                    'Select option {} is disabled'.format(dyn_elem())
                mat_option.click()

                if check_required:
                    assert (compare_method(dyn_elem().text, option)), \
                        'Failed to set value to {}, current value is {}'.format(option, dyn_elem().text.strip())
                break
        else:
            assert (option in all_mat_options_text_list), \
                'Select option {} not in {}'.format(
                    option, all_mat_options_text_list)

    @catch_exception
    def enter_topology_view(self, timeout=10):
        """
        enter_topology_view keyword, enter topology view page
        :param timeout: Maximum seconds for waiting for the topology view page available
        Examples:
        | enter_topology_view |
        """
        timeout = int(timeout)
        _xpath_topology_button = "//*[@href='#/topology']"
        _xpath_topology_header = "//span[@id='topology-title']"
        topology_button = self.web_driver.find_element(By.XPATH, _xpath_topology_button)
        if 'selected' not in topology_button.get_attribute('class'):
            topology_button.click()
        else:
            logger.info('topology_button already selected')
        Wait(self.web_driver, timeout).until(EC.visibility_of_element_located((By.XPATH, _xpath_topology_header)))

    @catch_exception
    def oper_unit(self, group_name, unit_id, operation, check_state_name, check_state_values, timeout=300):
        """
        oper_unit keyword,
        operate a unit, with unit ID specified
        :param group_name: group name that unit belongs to, e.g. sHUBs pRRHs
        :param unit_id: unit id, it can be string or list
        :param operation: operation, 'block', 'unblock' or 'reset'
        :param timeout: waiting timeout seconds for operation done
        :param check_state_name: state name to check
        :param check_state_values: state value list to change
               for multi units, the data structure is as follows.
               returned_time_cost: {'time_cost_display': {'1': xxx, '2': xxx},
                                    'time_cost_refresh': {'1': xxx, '2': xxx},
                                    'time_cost_button_recovered': {'1': xxx, '2': xxx}}
               for single unit, the data structure is as follows.
               returned_time_cost: {'time_cost_display': xxx,
                                    'time_cost_refresh': xxx,
                                    'time_cost_button_recovered': xxx}
        :return: None

        """
        returned_time_cost = {}
        timeout = int(timeout)
        dict_group_to_unit_prefix = {
            'sHUBs': 'HUBMOD',
            'pRRHs': 'ANTMOD'
        }
        TRANS_TEXT = "translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
        XPATH_TEMPLATE_STATE_VALUE = \
            "//div[@id='topologyDetailsContainer']//span[{}='{}:'" \
            " and contains(@class,'detail-title')]//..//span[contains(@class,'detail-text')]".format(TRANS_TEXT, '{}')

        check_state_name = check_state_name.lower()
        if type(check_state_values) is not list:
            check_state_values = [check_state_values]
        check_state_values = [x.lower() for x in check_state_values]
        unit_prefix = dict_group_to_unit_prefix[group_name]
        self.enter_topology_view()
        wait = Wait(self.web_driver, timeout)
        xpath_group_header = \
            "//div[@class='topology-view-columns-container']//div[contains(@class,'group-header')]//span[text()='{}']"\
            .format(group_name)
        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class,'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(xpath_group_header)
        view_column = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_view_column)))
        expand_header_button = view_column.find_element(By.XPATH, ".//mat-icon[contains(@class,'expand-header-icon')]")
        if 'expand' == expand_header_button.get_attribute('svgicon'):
            expand_header_button.click()

        time_cost_display_dict = {}

        def _click_dedicated_unit(unitid, check_state_name):
            xpath_app_unit = "{}//app-unit//div[contains(@class,'description-label') " \
                             "and contains(text(),'({}-{})')]".format(xpath_view_column, unit_prefix, unitid)
            print('xpath_app_unit: {}'.format(xpath_app_unit))
            app_unit = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_app_unit)))
            app_unit.click()

            xpath_span_paired_managed_object = XPATH_TEMPLATE_STATE_VALUE.format('paired managed object')
            print('xpath_app_unit: {}'.format(xpath_span_paired_managed_object))

            if not time_cost_display_dict.get(str(unitid)):
                time_cost_display_dict[str(unitid)] = []
            dt_start = time.time()
            while time.time() < dt_start + timeout:
                span_paired_managed_object = self.web_driver.find_elements(
                    By.XPATH, xpath_span_paired_managed_object)
                if span_paired_managed_object \
                        and span_paired_managed_object[0].get_attribute('textContent').split('/')[-1] == '{}-{}' \
                        .format(unit_prefix, unitid):
                    break
            else:
                assert False, "Paired managed object '{}-{} not appear after {}s".format(unit_prefix,
                                                                                         unitid, timeout)

            xpath_span_state_value = XPATH_TEMPLATE_STATE_VALUE.format(check_state_name)
            print('xpath_span_state_value: {}'.format(xpath_span_state_value))
            self.web_driver.find_element(By.XPATH, xpath_span_state_value)

            time_cost_display = round(time.time() - dt_start, 3)
            logger.info("{}-{} time_cost_display: {}s".format(
                unit_prefix, unitid, time_cost_display), also_console=True)
            time_cost_display_dict[str(unitid)].append(time_cost_display)
            logger.info("time_cost_display_dict {}".format(time_cost_display_dict))

        time_cost_refresh_dict = {}

        def _check_unit_state(unitid, check_state_name, check_state_value):
            _click_dedicated_unit(unitid=unitid, check_state_name='commissioned')
            xpath_app_unit = "{}//app-unit//div[contains(@class,'description-label') " \
                             "and contains(text(),'({}-{})')]".format(xpath_view_column, unit_prefix, unitid)
            logger.info("checking state {} change to {} ...".format(check_state_name, check_state_value),
                        also_console=True)
            xpath_span_state_value = \
                XPATH_TEMPLATE_STATE_VALUE.format(check_state_name) \
                + "//..//span[contains(@class,'detail-text')]//span[{}='{}']".format(TRANS_TEXT, check_state_value)
            xpath_div_empty_panel = \
                "//div[@id='topologyDetailsContainer']//div[contains(@class,'empty-panel')]"
            if not time_cost_refresh_dict.get(str(unitid)):
                time_cost_refresh_dict[str(unitid)] = {}
            dt_start = time.time()
            while time.time() < dt_start + timeout:
                try:
                    self.web_driver.find_element(By.XPATH, xpath_span_state_value)
                    logger.info("{} has changed to {} ...".format(check_state_name, check_state_value),
                                also_console=True)
                    break
                except Exception as e:
                    empty_panels = self.web_driver.find_elements(By.XPATH, xpath_div_empty_panel)
                    if empty_panels:
                        topo_container = self.web_driver.find_element(By.XPATH, "//div[@id='topologyContainer']")
                        ActionChains(self.web_driver).move_to_element_with_offset(
                            topo_container, 1, 1).click().perform()
                        app_unit = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_app_unit)))
                        app_unit.click()
            else:
                assert False, "state {} not reached after {}s".format(check_state_value, timeout)
            time_cost_refresh_dict[str(unitid)][check_state_value] = round(time.time() - dt_start_dic.get(
                str(id)), 3)
            logger.info("time_cost_refresh_dict {}".format(time_cost_refresh_dict))

        unitid_list = unit_id if type(unit_id) is list else str(unit_id).split()
        dt_start_dic = {}
        for unitid in unitid_list:
            _click_dedicated_unit(unitid=unitid, check_state_name=check_state_name)
            try:
                wait.until(EC.element_to_be_clickable((By.XPATH, "//button[@id='usm-{}']"
                                                       .format(operation.lower())))).click()
            except StaleElementReferenceException as e:
                logger.info("StaleElementReferenceException, Try again ...")
                wait.until(EC.element_to_be_clickable((By.XPATH, "//button[@id='usm-{}']"
                                                       .format(operation.lower())))).click()

            logger.info("button {} clicked".format(operation), also_console=True)
            dt_start_dic[str(id)] = time.time()
            _check_unit_state(unitid=unitid, check_state_name=check_state_name,
                              check_state_value=check_state_values[0])

        if check_state_values[1:]:
            for check_state_value in check_state_values[1:]:
                for unitid in unitid_list:
                    _check_unit_state(unitid=unitid,
                                      check_state_name=check_state_name, check_state_value=check_state_value)

        time_cost_display = {}
        time_cost_refresh = {}
        time_cost_recover = {}
        for unitid in unitid_list:
            time_cost_refresh[str(unitid)] = round(max(time_cost_refresh_dict.get(str(unitid)).values()), 3)
            _click_dedicated_unit(unitid=unitid, check_state_name=check_state_name)
            try:
                class_button_usm_oper = self.web_driver.find_element(
                    By.XPATH, "//button[@id='usm-{}']".format(operation.lower())).get_attribute('class')
            except StaleElementReferenceException as e:
                logger.info("StaleElementReferenceException, Try again ...")
                class_button_usm_oper = self.web_driver.find_element(
                    By.XPATH, "//button[@id='usm-{}']".format(operation.lower())).get_attribute('class')

            assert 'operation-ongoing' not in class_button_usm_oper, \
                'Button {} still on going'.format(operation)
            time_cost_display[str(unitid)] = round(max(time_cost_display_dict.get(str(unitid))), 3)
            time_cost_recover[str(unitid)] = time_cost_refresh.get(str(unitid))
        logger.info("{}-{} time_cost_refresh: {}s".format(unit_prefix, unitid_list, time_cost_refresh),
                    also_console=True)
        logger.info("{}-{} time_cost_button_recovered: {}s".format(unit_prefix, unitid_list, time_cost_recover),
                    also_console=True)

        if len(unitid_list) == 1:
            returned_time_cost['time_cost_display'] = time_cost_display.get(unitid_list[0])
            returned_time_cost['time_cost_refresh'] = time_cost_refresh.get(unitid_list[0])
            returned_time_cost['time_cost_button_recovered'] = time_cost_recover.get(unitid_list[0])
        else:
            returned_time_cost['time_cost_display'] = time_cost_display
            returned_time_cost['time_cost_refresh'] = time_cost_refresh
            returned_time_cost['time_cost_button_recovered'] = time_cost_recover
        logger.info("returned_time_cost: {}".format(returned_time_cost))

    def block_antmod(self, ant_mod_id, timeout=300):
        """
        block_ANTMOD keyword,
        block an ANTMOD, with ANTMOD ID specified
        :param ant_mod_id: ANTMOD ID to block
        :param timeout: waiting timeout seconds for ANTMOD blocked
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | block_ANTMOD  | ant_mod_id=144 | returned_time_cost=${time_cost} |
        | Should Be True | ${time_cost['time_cost']} <= ${10} |
        """
        self.oper_unit('pRRHs', ant_mod_id, 'block', 'Local state', 'blocked', timeout)

    def unblock_antmod(self, ant_mod_id, timeout=300):
        """
        unblock_ANTMOD keyword,
        unblock an ANTMOD, with ANTMOD ID specified
        :param ant_mod_id: ANTMOD ID to unblock
        :param timeout: waiting timeout seconds for ANTMOD unblocked
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | unblock_ANTMOD  | ant_mod_id=144 | returned_time_cost=${time_cost} |
        | Should Be True | ${time_cost['time_cost']} <= ${10} |
        """
        self.oper_unit('pRRHs', ant_mod_id, 'unblock', 'Local state', ['unblocked'], timeout)

    def reset_hubmod(self, hub_mod_id, timeout=300):
        """
        reset_HUBMOD keyword,
        reset an HUBMOD, with HUBMOD ID specified
        :param hub_mod_id: HUBMOD ID to unblock
        :param timeout: waiting timeout seconds for HUBMOD reset
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | reset_HUBMOD  | ant_mod_id=144 | returned_time_cost=${time_cost} |
        | Should Be True | ${time_cost['time_cost']} <= ${10} |
        """
        self.oper_unit('sHUBs', hub_mod_id, 'reset', 'Hardware state', ['resetting', 'working'], timeout)

    def reset_antmod(self, ant_mod_id, timeout=300):
        """
        reset_ANTMOD keyword,
        reset an ANTMOD, with ANTMOD ID specified
        :param ant_mod_id: ANTMOD ID to unblock
        :param timeout: waiting timeout seconds for ANTMOD unblocked
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | reset_ANTMOD  | ant_mod_id=1 | returned_time_cost=${time_cost} |
        | Should Be True | ${time_cost['time_cost']} <= ${10} |
        """
        self.oper_unit(
            'pRRHs', ant_mod_id, 'reset', 'Hardware state', ['resetting', 'working'], timeout)

    @catch_exception
    def reset_configuration(self, timeout=60, clear_shub_password=False):
        """
        reset_configuration keyword,
        Reset Configuration
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | reset_configuration | timeout=60 | returned_time_cost=${time_cost} |
        """
        returned_time_cost = {}
        timeout = int(timeout)
        wait = Wait(self.web_driver, timeout)
        self.enter_config_man(sub_menu="Reset", timeout=timeout)
        xpath_continue_button = "//app-config-reset//button[@id='continue-button']"
        xpath_finish_button = "//app-config-reset//button[@id='finish-button']"
        xpath_checkbox_clear_shub_passwords = "//app-config-reset//input[contains(@id," \
                                              "'clear-passwords-checkbox-input')]"
        try:
            checkbox_clear_shub_password_btn = self.web_driver.find_element(By.XPATH,
                                                                            xpath_checkbox_clear_shub_passwords)
            is_full_checked = checkbox_clear_shub_password_btn.get_attribute('aria-checked')
            if is_full_checked == str(clear_shub_password).lower():
                logger.info("Clear ASiController storage of "
                            "sHUB passwords is as expected {}".format(is_full_checked), also_console=True)
            else:
                logger.info("Start to click Clear ASiController storage of sHUB passwords", also_console=True)
                self.web_driver.execute_script("arguments[0].click();", checkbox_clear_shub_password_btn)
        except Exception as e:
            logger.error("No checkbox to be clicked")

        time.sleep(2)
        self.web_driver.find_element(By.XPATH, xpath_continue_button).click()
        logger.info("Continue button clicked", also_console=True)
        dt_start = time.time()
        xpath_div_success = \
            "//app-config-reset//div[contains(text(),'successfully reset') or contains(text(),'has been reset')]"
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_success)))
        self.web_driver.find_element(By.XPATH, xpath_finish_button).click()
        logger.info("Finish button clicked", also_console=True)
        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
        logger.info("reset_configuration time cost {}s".format(returned_time_cost['time_cost']), also_console=True)

    @catch_exception
    def save_scf(self, download_dir='/home/ute/Downloads/', timeout=30, desired_download_directory="/tmp/"):
        timeout = int(timeout)
        wait = Wait(self.web_driver, timeout)

        self.enter_config_man(sub_menu="Save", timeout=timeout)
        xpath_download_button = "//app-backup-prepared//button[text()='Download']"
        download_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_download_button)))
        list_scf_before_download = []
        for f in os.listdir(download_dir):
            f_path = os.path.join(download_dir, f)
            if not os.path.isdir(f_path) and os.path.splitext(f)[-1].lower() == '.xml':
                list_scf_before_download.append(f_path)
        download_button.click()
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            time.sleep(1)
            list_scf_after_download = []
            for f in os.listdir(download_dir):
                f_path = os.path.join(download_dir, f)
                if not os.path.isdir(f_path) and f_path not in list_scf_before_download \
                        and os.path.splitext(f)[-1].lower() == '.xml':
                    list_scf_after_download.append(f_path)
            if list_scf_after_download:
                file_name = os.path.basename(list_scf_after_download[-1])
                desired_file_path = os.path.join(desired_download_directory, file_name)
                shutil.move(list_scf_after_download[-1], desired_file_path)
                if os.path.isfile(desired_file_path):
                    return desired_file_path
        assert False, 'Failed to save backup scf'

    @catch_exception
    def load_scf(self, scf_path, timeout=180):
        """
        keyword load_scf,
        Load scf file and activation
        :param scf_path: expected node after expand
        :param timeout: waiting timeout seconds for web elements' apprearance
        :return: None

        Examples:
        | ${scf_path}  | set variable | /home/ute/Downloads/Configuration_111.xml |
        | ${time_cost} | Create Dictionary |
        | load_scf | scf_path=${scf_path} | returned_time_cost=${time_cost} |
        """
        returned_time_cost = {}
        timeout = int(timeout)
        wait = Wait(self.web_driver, timeout)
        self.enter_config_man(sub_menu="load file", timeout=timeout)
        xpath_select_file_button = "//app-upload-configuration//button[@id='file-select-button']"
        wait.until(EC.element_to_be_clickable((By.XPATH, xpath_select_file_button)))

        js = "arguments[0].removeAttribute(\"hidden\");"
        input_file = self.web_driver.find_element(By.XPATH, "//input[@id='file']")
        self.web_driver.execute_script(js, input_file)
        input_file.send_keys(scf_path)
        dt_start = time.time()
        xpath_next_btn = "//button[@id='stepper-next-button']"
        xpath_activate_button = "//button[@id='run-activation-btn']"
        wait = Wait(self.web_driver, 1)
        try:
            next_btn = Wait(self.web_driver, self.ui_delay * 5).until(EC.element_to_be_clickable((By.XPATH,
                                                                                                  xpath_next_btn)))
            if next_btn:
                next_btn.click()
        except Exception as e:
            logger.info("configuration migration is not required!", also_console=True)

        while time.time() < dt_start + timeout:
            try:
                wait.until(EC.element_to_be_clickable((By.XPATH, xpath_activate_button)))
                break
            except TimeoutException as e:
                pass

            try:
                next_btn = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_next_btn)))
                next_btn.click()
                break
            except TimeoutException as e:
                pass
        wait = Wait(self.web_driver, timeout)
        wait.until(EC.element_to_be_clickable((By.XPATH, xpath_activate_button)))
        returned_time_cost['time_cost_load_scf'] = time.time()-dt_start
        returned_time_cost_activate = {}
        ret_activate = self._activate_common(as_full_configuration=True, timeout=timeout)
        assert ret_activate.get('ret') is True, ret_activate.get('info')
        returned_time_cost['returned_time_cost_activate'] = returned_time_cost_activate

    @catch_exception
    def _get_cell_list_under_topology_cell(self):
        """
        Internal method _get_cell_list_under_topology_cell
        Get detailed cell list under cell topology view
        Example : _get_cell_list_under_topology_cell()
        """
        xpath_cell_tab = "//app-tabs[@id='topology-tabs']//a[contains(text(),'Cells')]"
        xpath_cell_sub_tab = "//div[contains(@class, 'topology-view')]//span[text()='CELLs']//..//.."
        xpath_cell_label = "{0}//app-unit//div[contains(@class,'description-label')]"
        xpath_cell_mat_icon = "//span[text()='CELLs']//..//mat-icon"

        self.enter_topology_view()
        time.sleep(15)
        cell_tab_btn = Wait(self.web_driver, self.ui_delay * 2).until(
            EC.element_to_be_clickable((By.XPATH, xpath_cell_tab)))
        if cell_tab_btn:
            cell_tab_btn.click()

        mat_icon_btn = self.web_driver.find_element(By.XPATH, xpath_cell_mat_icon)
        if mat_icon_btn and mat_icon_btn.get_attribute('svgicon') == 'expand':
            mat_icon_btn.click()

        cell_item_list = self.web_driver.find_elements(By.XPATH, xpath_cell_label.format(xpath_cell_sub_tab))
        cell_list = [cell_item.text for cell_item in cell_item_list]
        return cell_list

    @catch_exception
    def _get_cell_status(self, cell_list):
        """
        Internal method _get_cell_status
        Get asir cell status with indicator color
        Example : _get_cell_status(cell_list=['BTS1.1', 'BTS1.2'])
        """
        xpath_indicator_color = "//app-unit//div[text()='{0}']//..//div[contains(@mattooltip, 'State')]"
        dict_cell_color = {}
        for cell_item in cell_list:
            search_result = self.web_driver.find_element(By.XPATH, xpath_indicator_color.format(cell_item))
            if search_result:
                dict_cell_color[cell_item] = search_result.get_attribute('class').split()[2].split('-')[1]
        return dict_cell_color

    @catch_exception
    def _compare_status(self, check_list, status, timeout, expected_cell_count=None):
        """
        Internal method _compare_status
        Compare cell status with expected one, return compare result with dict type.
        Example : _compare_status(cell_list=['BTS1.1', 'BTS1.2'], status='yellow', timeout=120s)
        """
        dict_check_result = {'check_result': True, 'check_details': {}}
        timeout = int(timeout)
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            cell_status_dict = self._get_cell_status(check_list)
            logger.info("To be checked cell status : {0}".format(cell_status_dict))
            check_success_counter = 0
            for k, v in cell_status_dict.items():
                if v.lower() != status.lower():
                    dict_check_result['check_result'] = False
                    dict_check_result['check_details'] = cell_status_dict
                    if expected_cell_count:
                        continue
                    else:
                        time.sleep(10)
                        break
                else:
                    check_success_counter += 1
            if check_success_counter == len(cell_status_dict):
                break
            if expected_cell_count:
                if check_success_counter == int(expected_cell_count):
                    dict_check_result['check_result'] = True
                    dict_check_result['check_details'] = cell_status_dict
                    break

        return dict_check_result

    @catch_exception
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_asir_cell_status(self, cell_type, id_list=None, expected_status='Green', timeout=120,
                               expected_cell_count=None):
        """
        keyword check_asir_cell_status
        Get ASIR cell status via selenium and check whether status is expected or not
        :param cell_type: cell type, BTS, RFC or ALL
        :param id_list: cell id list, format should be similar to 1.2  2.1  2.2
        :param expected_status: expected status with one value of Green/Yellow/Red
        :param timeout: waiting timeout seconds for check operation done
        :param expected_cell_count: number of cells with expected status

        Examples:
        Example 1: Check all ASIR cell status with expected 'green' status
        | check_asir_cell_status | cell_type=ALL | expected_status=Green |
        Example 2: Check RFC cell 2.1 2.2 status with expected 'green' status
        | check_asir_cell_status | cell_type=RFC | id_list=2.1 2.2 | expected_status=Green |
        Example 3: Check all BTS cell within 60s with expected 'yellow' status
        | check_asir_cell_status | cell_type=BTS | expected_status=Yellow | timeout=60 |
        """
        cell_list = self._get_cell_list_under_topology_cell()
        bts_cell_list = [item.lstrip("BTS") for item in cell_list if 'bts' in item.lower()]
        rfc_cell_list = [item.lstrip("RFC-") for item in cell_list if 'rfc' in item.lower()]
        logger.info("All cell list : {0}".format(cell_list))

        if cell_type.lower() == 'all':
            check_cell_list = cell_list

        elif cell_type.lower() == 'bts':
            if id_list is None:
                tmp_list = bts_cell_list
            else:
                tmp_list = id_list if type(id_list) is list else str(id_list).split()
            check_cell_list = ['BTS' + item for item in tmp_list]

        elif cell_type.lower() == 'rfc':
            if id_list is None:
                tmp_list = rfc_cell_list
            else:
                tmp_list = id_list if type(id_list) is list else str(id_list).split()
            check_cell_list = ['RFC-' + item for item in tmp_list]

        else:
            raise Exception("cell type {0} is not supported.".format(cell_type))

        assert check_cell_list, "To be checked asir cell list is empty."
        logger.info("To be checked asir cell list : {0}".format(check_cell_list))
        check_result = self._compare_status(check_list=check_cell_list,
                                            status=expected_status,
                                            timeout=timeout,
                                            expected_cell_count=expected_cell_count)

        if not check_result['check_result']:
            MolerTest.error("asir cell status check result: {0}".format(check_result))
        MolerTest.steps_end()

    @catch_exception
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_rfc_type(self, rfc_id, expected_type):
        """
        keyword check_rfc_type
        Check RFC type and compare it with expected type
        :param rfc_id: RFC identifier
        :param expected_type: expected RFC type, APHH/APHB

        Example:
        | check_rfc_type | rfc_id=1 | expected_type=APHH |
        """
        rfc_type = ""
        xpath_cell_tab = "//app-tabs[@id='topology-tabs']//a[contains(text(),'Cells')]"
        xpath_rfc_label = "//div[contains(@class,'group-label')]//span[text()='RFCs']"
        xpath_rfc_mat_icon = "{0}//..//..//mat-icon"
        xpath_rfc_type = "//app-unit//div[contains(@class,'description-label') and contains(text(),'RFC-{0}')]"
        dict_check_result = {'check_result': True, 'check_details': {}}

        self.enter_topology_view()
        cell_tab_btn = Wait(self.web_driver, self.ui_delay * 2).until(
            EC.element_to_be_clickable((By.XPATH, xpath_cell_tab)))
        if cell_tab_btn:
            cell_tab_btn.click()

        rfc_mat_icon = self.web_driver.find_element(By.XPATH, xpath_rfc_mat_icon.format(xpath_rfc_label))
        if rfc_mat_icon and rfc_mat_icon.get_attribute('svgicon') == 'expand':
            rfc_mat_icon.click()

        try:
            rfc_elem = self.web_driver.find_element(By.XPATH, xpath_rfc_type.format(rfc_id))
            rfc_type = rfc_elem.text.split(' ')[0]
            logger.info("RFC-{0} type : {1}".format(rfc_id, rfc_type), also_console=True)

        except Exception as e:
            error_message = str(e)
            if "no such element:" in error_message:
                raise Exception("Unable to locate RFC-{0}, check its existence!".format(rfc_id))

        if rfc_type.strip().lower() != expected_type.strip().lower():
            dict_check_result['check_result'] = False
            dict_check_result['check_details']['actual_type'] = rfc_type.strip()
            dict_check_result['check_details']['expected_type'] = expected_type.strip()

        if not dict_check_result['check_result']:
            MolerTest.error("RFC-{0} type check result: {1}".format(rfc_id, dict_check_result))
        MolerTest.steps_end()

    """
    xpath for cell manipulation under Cells tab
    """
    _xpath_cell_list_table = "//div[@id='cell-list-table']"
    _xpath_cell_list_locator = "//div[@id='cells-list-content']//tbody"

    @catch_exception
    @switch_to_tab('Cells')
    def delete_cell_manually(self, cell_type, type_id, cell_id):
        """
        keyword delete_cell_manually
        Delete one specific type cell under cells tab
        :param cell_type: cell type, BTS or RFC
        :param type_id: cell type identifier
        :param cell_id: cell identifier under specific cell type

        Example:
        | delete cell manually | cell_type=BTS | type_id=1 | cell_id=2 |
        """
        xpath_cell_locator = "{0}//tr[contains(@id,'{1}-{2}/{3}-{4}')]"
        xpath_warp_del_btn = "//app-wrapping-button[@id='delete-selected-cell-button']"
        xpath_warn_modal = "//div[@class='modal-panel']//div[@class='header-text' and contains(text(),'Delete')]"
        xpath_modal_del_btn = "//button[text()='Delete']"
        xpath_cell_finder = "{0}//tr[contains(@id,'{1}-{2}/')]"

        cell_type_upper = cell_type.strip().upper()
        assert (cell_type_upper in ['BTS', 'RFC']), 'cell type {0} is not supported!'.format(cell_type)
        cell_str = 'CELL' if cell_type_upper == 'BTS' else 'RFCCELL'
        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((
            By.XPATH, self._xpath_cell_list_table)))

        def _cell_id_finder(xpath_locator):
            found_elements = self.web_driver.find_elements(By.XPATH, xpath_locator)
            ret_list = [item.get_attribute('id').split('/')[-1] for item in found_elements]
            return ret_list

        try:
            self.web_driver.find_element(By.XPATH, xpath_cell_locator.format(
                self._xpath_cell_list_locator, cell_type_upper, type_id, cell_str, cell_id)).click()
            time.sleep(1)

        except Exception as e:
            error_message = str(e)
            if "no such element:" in error_message:
                raise Exception("Unable to locate CELL : {0}-{1}/{2}-{3}, check its existence!"
                                .format(cell_type_upper, type_id, cell_str, cell_id))

        delete_cell_btn = self.web_driver.find_element(
            By.XPATH, "{0}//div[contains(@class,'button')]".format(xpath_warp_del_btn))
        if delete_cell_btn and 'disabled' not in delete_cell_btn.get_attribute('class'):
            logger.info("Start to delete {0} cell".format(cell_type_upper), also_console=True)
            self.web_driver.find_element(By.XPATH, xpath_warp_del_btn).click()

            Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                             xpath_warn_modal)))
            Wait(self.web_driver, self.ui_delay * 3).until(
                EC.element_to_be_clickable((By.XPATH, xpath_modal_del_btn)))

            self.web_driver.find_element(By.XPATH, xpath_modal_del_btn).click()
            time.sleep(2)
            cell_id_list = _cell_id_finder(xpath_cell_finder.format(
                self._xpath_cell_list_locator, cell_type_upper, type_id))

            if "{0}-{1}".format(cell_str, cell_id) not in cell_id_list:
                logger.info("{0}-{1} under {2}-{3} deleted".format(
                    cell_str, cell_id, cell_type, type_id), also_console=True)
            else:
                raise Exception("Failed to delete {0}-{1} under {2}-{3}".format(
                    cell_str, cell_id, cell_type, type_id))
        else:
            raise Exception("Delete cell button is in disabled status, can't perform delete cell operation!")

    @catch_exception
    @switch_to_tab('Cells')
    def populate_radio_antenna_mapping(self, cell_type, type_id, cell_id, hubmod_id, chan_dict):
        """
        keyword populate_radio_antenna_mapping
        Navigate to Cells tab, do populate operation on specific hub & antenna channel mapping info.
        NOTE : both BTS and RFC are supported(BTS with HUB Antenna while RFC with RFC Channel).
        :param cell_type: cell type, BTS or RFC
        :param type_id: cell type identifier
        :param cell_id: cell identifier under specific cell type
        :param hubmod_id: HUB module identifier
        :param chan_dict: dictionary of channel_id & channel_value pair
        """
        xpath_cell_locator = "//div[@id='cells-list-content']//tr[contains(@id, '{0}-{1}/{2}-{3}')]"
        xpath_antenna_header = "//div[@id='cell-details-hub-antennas-header']"
        xpath_map_chan_locator = \
            "//div[@id='cell-details-hub-antennas-content']//tbody//tr[contains(@id,'/HUBMOD-{0}')]"
        xpath_map_checkbox = ".//mat-checkbox[contains(@class,'HUBMOD-{0}')]"
        xpath_hubant_locator = ".//mat-select[contains(@class,'{0}-{1}')]"

        if not all([cell_type, type_id, cell_id, hubmod_id, chan_dict]):
            raise Exception("please provide all mandatory parameters for hub antenna mapping!")
        cell_type_upper = cell_type.strip().upper()
        assert (cell_type_upper in ['BTS', 'RFC']), 'cell type {0} is not supported!'.format(cell_type)
        cell_str = 'CELL' if cell_type_upper == 'BTS' else 'RFCCELL'
        search_str = 'HUBANTL' if cell_type_upper == 'BTS' else 'Channel'
        try:
            self.web_driver.find_element(By.XPATH, xpath_cell_locator.format(cell_type_upper,
                                                                             type_id, cell_str, cell_id)).click()

        except Exception as e:
            error_message = str(e)
            if "no such element:" in error_message:
                raise Exception("Unable to locate {0}-{1}/{2}-{3}, check its existence!"
                                .format(cell_type_upper, type_id, cell_str, cell_id))

        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                         xpath_antenna_header)))
        ante_hdr = self.web_driver.find_element(By.XPATH, "{0}//span".format(xpath_antenna_header))
        if ante_hdr and 'RFC' in ante_hdr.text.strip():
            logger.info("RFC Channel appear!", also_console=True)
        else:
            logger.info("HUB Antenna appear!", also_console=True)

        timeout = 30
        antenna_map_chan = None
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            try:
                antenna_map_chan = self.web_driver.find_element(By.XPATH, xpath_map_chan_locator.format(hubmod_id))
                if antenna_map_chan:
                    break

            except Exception as ex:
                logger.info("Unable to locate HUBMOD-{0} with exception {1}, continue".format(hubmod_id, ex))
                time.sleep(3)
                continue

        if antenna_map_chan:
            map_checkbox = antenna_map_chan.find_element(By.XPATH, xpath_map_checkbox.format(hubmod_id))
            assert ('disabled' not in map_checkbox.get_attribute('class')), \
                "HUBMOD-{0} mat-checkbox is disabled!".format(hubmod_id)
            if 'checked' not in map_checkbox.get_attribute('class'):
                map_checkbox.click()
                time.sleep(2)
            else:
                logger.info("HUBMOD-{0} mat-checkbox has already checked, skip check operation.".format(hubmod_id))

            for chan_id, chan_value in chan_dict.items():
                chan_sel = antenna_map_chan.find_element(By.XPATH, xpath_hubant_locator.format(search_str, chan_id))
                assert ('pulldown' not in chan_sel.get_attribute('class')), \
                    "sHUB ANTL(Channel)-{0} mat-select is disabled!".format(chan_id)
                self._select_value_in_mat_select(chan_sel, chan_value, lambda x, y: x.strip() == y.strip())
            logger.info("Successfully populate {0}-{1} Ant Channel map!".format(cell_str,
                                                                                cell_id), also_console=True)

        else:
            raise Exception("Unable to locate HUBMOD-{0} antenna channel map info within 30s.".format(hubmod_id))

    @catch_exception
    @switch_to_tab('Cells')
    def populate_rfc_cell_mapping_info(self, cell_type, type_id, cell_id, profile_id, band_class, chan_dict):
        """
        keyword populate_rfc_cell_mapping_info
        Navigate to Cells tab, do populate operation on specific RFC channel map
        :param cell_type: cell type, BTS or RFC
        :param type_id: cell type identifier
        :param cell_id: cell identifier under specific cell type
        :param profile_id: profile identifier
        :param band_class: Module type(band class), e.g. ARHHB or ARHHB (Band 41)
        :param chan_dict: dictionary of channel_id & channel_value pair

        Example:
        ${chan_dict}  Create Dictionary  1=ANTL1  2=ANTL2  3=ANTL3  4=ANTL4
        | populate_rfc_cell_mapping_info | cell_type=BTS | type_id=1 | cell_id=2 | profile_id=1
        ...                              | band_class=ARHQC (Band 78)| chan_dict=${chan_dict} |
        """
        xpath_cell_locator = "//div[@id='cells-list-content']//tr[contains(@id, '{0}-{1}/{2}-{3}')]"
        xpath_cell_mapping_hdr = "//div[@id='cell-details-mapping-header']"
        xpath_profile_mapping_locator = \
            "//div[@id='cell-details-mapping-content']//tbody//tr[contains(@id,'/ANTMODPR-{0}')]"
        xpath_rfc_port = ".//div[contains(@class,'rfcPortId')]//span"
        xpath_module_type = ".//mat-select[contains(@class,'profileBandClass')]"
        xpath_channel_locator = ".//mat-select[contains(@class,'profileHubAntl-{0}')]"

        if not all([cell_type, type_id, cell_id, profile_id, band_class, chan_dict]):
            raise Exception("please provide all mandatory parameters for RFC cell mapping!")
        cell_type_upper = cell_type.strip().upper()
        assert (cell_type_upper in ['BTS', 'RFC']), 'cell type {0} is not supported!'.format(cell_type)
        cell_str = 'CELL' if cell_type_upper == 'BTS' else 'RFCCELL'
        try:
            self.web_driver.find_element(By.XPATH, xpath_cell_locator.format(cell_type_upper,
                                                                             type_id, cell_str, cell_id)).click()

        except Exception as e:
            error_message = str(e)
            if "no such element:" in error_message:
                raise Exception("Unable to locate {0}-{1}/{2}-{3}, check its existence!"
                                .format(cell_type_upper, type_id, cell_str, cell_id))

        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                         xpath_cell_mapping_hdr)))
        timeout = 30
        rfc_profile_chan = None
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            try:
                rfc_profile_chan = self.web_driver.find_element(By.XPATH,
                                                                xpath_profile_mapping_locator.format(profile_id))
                if rfc_profile_chan:
                    break

            except Exception as ex:
                logger.info("Unable to find profile_id {0} with exception {1}, continue".format(profile_id, ex))
                time.sleep(3)
                continue

        if rfc_profile_chan:
            rfc_port = rfc_profile_chan.find_element(By.XPATH, xpath_rfc_port)
            if rfc_port:
                logger.info("profile_id {0} associated with rfc port {1}".format(profile_id, rfc_port.text.strip()))

            module_type = rfc_profile_chan.find_element(By.XPATH, xpath_module_type)
            if band_class == '(Clear)' or band_class == '<No select>':
                def band_class_compare(x, y):
                    return x.strip().lower() == y.strip().lower()
            else:
                if '(' not in band_class:
                    def band_class_compare(x, y):
                        return x.strip() == y.strip()
                else:
                    def band_class_compare(x, y):
                        return y.strip().replace(' ', '').split('(')[0] in x.strip().split()

            self._select_value_in_mat_select(module_type, band_class, band_class_compare)
            if band_class == '(Clear)' or band_class == '<No select>':
                logger.info('profile_id {0} cleared'.format(profile_id), also_console=True)
            else:
                for chan_id, chan_value in chan_dict.items():
                    assert chan_value, "chan_id {0} associated chan_value is empty!".format(chan_id)
                    if chan_value == '(Clear)' or chan_value == '<No select>':
                        def compare_chan_value(x, y):
                            return x.strip().lower() == y.strip().lower()
                    else:
                        if len(chan_value.split()) > 1:
                            def compare_chan_value(x, y):
                                return x.strip() == y.strip().upper()
                        else:
                            def compare_chan_value(x, y):
                                return y.strip().upper() in x.strip().split()

                    chan_select = rfc_profile_chan.find_element(By.XPATH, xpath_channel_locator.format(chan_id))
                    assert ('pulldown' not in chan_select.get_attribute('class')), \
                        "profile_id {0} Channel-{1} mat-select is disabled!".format(profile_id, chan_id)
                    self._select_value_in_mat_select(chan_select, chan_value, compare_chan_value)

                logger.info("Successfully populate profile_id {0} associated RFC profile channel mapping info".
                            format(profile_id), also_console=True)

        else:
            raise Exception("Unable to find profile_id {0} associated RFC channel mapping info.".format(profile_id))

    """
    xpath for RFC manipulation under RFCs tab
    """
    _xpath_rfc_list = "//div[@id='rfc-list-table']"
    _xpath_rfc_locator = "{0}//tr[contains(@id,'RFC-{1}')]"

    @catch_exception
    @switch_to_tab('RFCs')
    def create_rfc_by_import_file(self, file_location, file_name):
        """
        keyword create_rfc_by_import_file
        :param file_location: RFC configuration file location
        :param file_name: RFC configuration file name

        Example:
        | create rfc by import file | file_location=/home/ute/ | file_name=Rfc_test.xml |
        """
        xpath_import_rfc_button = "//button[@id='import-rfc-file-button']"
        xpath_input_file_label = "//input[@id='file']"
        xpath_rfc_details = "//div[@id='rfc-configuration-details-content']"
        xpath_created_rfc_locator = "{0}//tr[contains(@id,'RFC-') and contains(@class,'selected')]"

        ret_dict = {}
        if not all([file_location, file_name]):
            raise Exception("please provide all mandatory parameters for importing rfc file!")

        rfc_config_file = os.path.join(file_location, file_name)
        assert (os.path.exists(rfc_config_file)), \
            "{0} configuration file is not exist under {1}, please check!".format(file_name, file_location)

        import_rfc_button = Wait(self.web_driver, self.ui_delay * 5).until(
            EC.element_to_be_clickable((By.XPATH, xpath_import_rfc_button)))
        if import_rfc_button:
            self.web_driver.find_element(By.XPATH, xpath_input_file_label).send_keys(rfc_config_file)

        time.sleep(3)
        Wait(self.web_driver, self.ui_delay * 3).until(
            EC.visibility_of_element_located((By.XPATH, xpath_rfc_details)))
        try:
            rfc_elem = self.web_driver.find_element(
                By.XPATH, xpath_created_rfc_locator.format(self._xpath_rfc_list))
            if rfc_elem:
                rfc_item = rfc_elem.get_attribute('id').split('/')[-1]
                logger.info("{0} created by import RFC file {1}".format(rfc_item, file_name), also_console=True)
                if '-' in rfc_item and rfc_item.startswith('RFC'):
                    ret_dict['type'] = rfc_item.split('-')[0]
                    ret_dict['id'] = rfc_item.split('-')[-1]
                return ret_dict

        except Exception as e:
            error_message = str(e)
            if "no such element:" in error_message:
                raise Exception("Failed to import RFC file {0}".format(file_name))

    @catch_exception
    @switch_to_tab('RFCs')
    def map_rfc_to_shub(self, rfc_id, rfc_port_id, hubmod_id, sfp_port_id):
        xpath_rfc_config = "//div[@id='rfc-port-configuration-assignment']"
        xpath_rfc_port_locator = "{0}//tr[contains(@id,'port_{1}')]"
        xpath_rfc_hubmod_locator = "{0}//mat-select[contains(@class,'Hubmod')]"
        xpath_rfc_sfp_port = "{0}//mat-select[contains(@class,'Port')]"

        if not all([rfc_id, rfc_port_id, hubmod_id, sfp_port_id]):
            raise Exception("please provide all mandatory parameters!")
        hub_locator = xpath_rfc_hubmod_locator.format(xpath_rfc_port_locator.format(xpath_rfc_config, rfc_port_id))
        sfp_port_locator = xpath_rfc_sfp_port.format(xpath_rfc_port_locator.format(xpath_rfc_config, rfc_port_id))

        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                         self._xpath_rfc_list)))
        try:
            self.web_driver.find_element(By.XPATH, self._xpath_rfc_locator.format(self._xpath_rfc_list,
                                                                                  rfc_id)).click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate RFC-{0}, check its existence!".format(rfc_id))

        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_rfc_config)))
        shub_item = self.web_driver.find_element(By.XPATH, hub_locator)
        if shub_item:
            self._select_value_in_mat_select(shub_item,
                                             "HUBMOD-{0}".format(hubmod_id),
                                             lambda x, y: x.strip() == y.strip(),
                                             check_required=False)
        Wait(self.web_driver, self.ui_delay * 3).until(EC.element_to_be_clickable((By.XPATH, sfp_port_locator)))
        sfp_port_item = self.web_driver.find_element(By.XPATH, sfp_port_locator)
        if sfp_port_item:
            assert ('pulldown' not in sfp_port_item.get_attribute('class')), "select SFP port function is disabled!"
            self._select_value_in_mat_select(sfp_port_item,
                                             sfp_port_id,
                                             lambda x, y: x.strip() == y.strip(),
                                             check_required=False)

    @catch_exception
    @switch_to_tab('RFCs')
    def delete_rfc(self, rfc_id):
        """
        keyword delete_rfc
        Delete one specific RFC under RFCs tab
        :param rfc_id: RFC identifier

        Example:
        | delete_rfc | rfc_id=1 |
        """
        xpath_del_rfc_btn = "//button[@id='delete-selected-rfc-button']"
        xpath_wrap_del_btn = "{0}//..//..//div[contains(@class,'wrapping-button')]"
        xpath_warn_modal = "//div[@class='modal-panel']" \
                           "//div[@class='header-text' and contains(text(),'Delete RFC')]"
        xpath_warn_del_btn = "//button[text()='Delete']"

        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                         self._xpath_rfc_list)))
        try:
            self.web_driver.find_element(
                By.XPATH, self._xpath_rfc_locator.format(self._xpath_rfc_list, rfc_id)).click()

        except Exception as e:
            error_message = str(e)
            if "no such element:" in error_message:
                raise Exception("Unable to locate RFC-{0}, check its existence!".format(rfc_id))

        time.sleep(2)
        warp_del_rfc_btn = self.web_driver.find_element(By.XPATH, xpath_wrap_del_btn.format(xpath_del_rfc_btn))
        assert ('disabled' not in warp_del_rfc_btn.get_attribute(
            'class')), "Delete RFC button is in disabled status!"
        logger.info("Start to delete RFC-{0}".format(rfc_id), also_console=True)
        self.web_driver.find_element(By.XPATH, xpath_del_rfc_btn).click()

        Wait(self.web_driver, self.ui_delay * 3).until(
            EC.visibility_of_element_located((By.XPATH, xpath_warn_modal)))
        Wait(self.web_driver, self.ui_delay * 3).until(EC.element_to_be_clickable((By.XPATH, xpath_warn_del_btn)))
        time.sleep(2)
        self.web_driver.find_element(By.XPATH, xpath_warn_del_btn).click()
        time.sleep(2)

        try:
            self.web_driver.find_element(By.XPATH, self._xpath_rfc_locator.format(
                self._xpath_rfc_list, rfc_id)).click()
            raise Exception("Failed to delete RFC-{0}".format(rfc_id))

        except Exception as e:
            error_message = str(e)
            if "no such element:" in error_message:
                logger.info("RFC-{0} deleted".format(rfc_id), also_console=True)

    """
    xpath for sHUB manipulation under sHUBs tab
    """
    _xpath_shub_list_table = "//div[@id='hub-list-table']"
    _xpath_shub_locator = "{0}//tr[contains(@id,'HUBMOD-{1}')]"
    _xpath_shub_detail = "//div[@id='hub-configuration-details-content']"

    @catch_exception
    @switch_to_tab('sHUBs')
    def delete_shub_manually(self, hubmod_id, timeout=10):
        xpath_del_shub_btn = "//button[@id='delete-selected-hub-button']"
        xpath_wrap_del_btn = "{0}//..//..//div[contains(@class, 'wrapping-button')]"
        xpath_warn_modal = "//div[@class='modal-panel']//div[contains(text(), 'Delete sHUB')]"
        xpath_warn_del_btn = "//div[@class='modal-panel']//button[text()='Delete']"

        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                         self._xpath_shub_list_table)))
        try:
            self.web_driver.find_element(By.XPATH,
                                         self._xpath_shub_locator.format(self._xpath_shub_list_table,
                                                                         hubmod_id)).click()
        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate HUBMOD-{0}, check its existence!".format(hubmod_id))

        xpath_div_spinner_container = "//div[@class='spinner-container']"
        Wait(self.web_driver, timeout).until_not(EC.visibility_of_element_located((By.XPATH,
                                                                                   xpath_div_spinner_container)))

        wrap_del_shub_btn = self.web_driver.find_element(By.XPATH, xpath_wrap_del_btn.format(xpath_del_shub_btn))
        if 'disable' in wrap_del_shub_btn.get_attribute('class'):
            logger.error("Delete sHUB button is in disabled status!")

        self.web_driver.find_element(By.XPATH, xpath_del_shub_btn).click()

        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                         xpath_warn_modal)))
        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                         xpath_warn_del_btn)))

        time.sleep(1)
        self.web_driver.find_element(By.XPATH, xpath_warn_del_btn).click()

        wait = Wait(self.web_driver, 1)
        try:
            xpath_div_spinner_container = "//div[@class='spinner-container']"
            loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        except TimeoutException:
            loading_spinner = None
        if loading_spinner:
            wait = Wait(self.web_driver, 10)
            wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))

        try:
            self.web_driver.find_element(By.XPATH, self._xpath_shub_locator.format(self._xpath_shub_list_table,
                                                                                   hubmod_id)).click()
            raise Exception("Failed to delete HUBMOD-{0}".format(hubmod_id))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("HUBMOD-{0} deleted".format(hubmod_id), also_console=True)

    """
    xpath for Accounts manipulation
    """
    xpath_configuration_accounts = "//div[contains(@class, 'ng-trigger-verticalStepTransition')]"
    xpath_account_type_locator = "//*[contains(@class,'accountType')]"
    xpath_user_form = "//form[contains(@class, '{}')]"
    xpath_continue = "//button[@id='continue-button']"
    xpath_pwd_change_ok = "//div[@class='information-row']//div[contains(text(), 'The password has been changed')]"
    xpath_pwd_finish = "//div//button[@id='finish-button']"
    xpath_pwd_change_done = "//mat-vertical-stepper[@id='update-credentials']"
    xpath_pwd_change_nok = "//div[@id='errorFormLUAC_LLO']//div[@class='information-row']//" \
                           "div[contains(text(), 'Update credentials error')]"
    xpath_pwd_retry = "//div[@id='errorFormLUAC_LLO']//button[@id='retry-button']"
    xpath_error_tip = "//div[@id='error-additional-info']"

    @catch_exception
    def change_accounts_password(self, account_type, user_passwd_dict, check_required=True):
        xpath_new_password_locator = "{}//input[contains(@class, 'newPassword')]"
        xpath_confirm_password_locator = "{}//input[contains(@class, 'confirmPassword')]"
        xpath_password_validator = "{}//ul[contains(@class, 'validators-info')]//li"

        self.web_driver.get("https://192.168.255.129:3601/#/commissioning/cards")
        self.web_driver.find_element(By.ID, "accountsStartButton").click()
        Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located((
            By.XPATH, self.xpath_configuration_accounts)))
        account_type_elem = self.web_driver.find_element(By.XPATH, self.xpath_account_type_locator)
        if account_type == account_type_elem.get_attribute('textContent').strip():
            logger.info("Account Type:{} is as expected".format(account_type), also_console=True)
        else:
            logger.info("Change Account Type to {}".format(account_type), also_console=True)
            self._select_value_in_mat_select(account_type_elem, account_type, lambda x, y: x.strip() == y.strip(),
                                             check_required)
        for para, value in user_passwd_dict.items():
            Wait(self.web_driver, self.ui_delay * 3).until(
                EC.visibility_of_element_located((By.XPATH, self.xpath_user_form.format(para))))
            new_password_elem = self.web_driver.find_element(By.XPATH, xpath_new_password_locator.format(
                self.xpath_user_form.format(para)))
            new_password_elem.clear()
            new_password_elem.send_keys(value)
            password_validator_elem = self.web_driver.find_elements(By.XPATH, xpath_password_validator.format(
                self.xpath_user_form.format(para)))
            validator_content_list = []
            for each_password_validator_elem in password_validator_elem:
                if "validator-info-error" in each_password_validator_elem.get_attribute('class'):
                    validator_content = each_password_validator_elem.get_attribute('textContent')
                    validator_content_list.append(validator_content)
            assert (not validator_content_list), "Password:{} does not comply with password rules, due to {}".format(
                        value, validator_content_list)
            confirm_password_elem = self.web_driver.find_element(By.XPATH, xpath_confirm_password_locator.format(
                self.xpath_user_form.format(para)))
            confirm_password_elem.clear()
            confirm_password_elem.send_keys(value)

        continue_btn = self.web_driver.find_elements(By.XPATH, self.xpath_continue)
        if continue_btn[0]:
            continue_btn[0].click()
        Wait(self.web_driver, self.ui_delay * 60).until(EC.visibility_of_element_located((
            By.XPATH, self.xpath_pwd_change_done)))
        try:
            Wait(self.web_driver, self.ui_delay * 2).until(EC.visibility_of_element_located((
                By.XPATH, self.xpath_pwd_change_ok)))
            self.web_driver.find_element(By.XPATH, self.xpath_pwd_finish).click()
        except Exception as e:
            Wait(self.web_driver, self.ui_delay * 2).until(EC.visibility_of_element_located((
                By.XPATH, self.xpath_pwd_change_nok)))
            elems = self.web_driver.find_elements(By.XPATH, self.xpath_error_tip)
            elem = elems[0]
            elem_info = elem.get_attribute('textContent')
            logger.info("Modify error info: {}".format(elem_info), also_console=True)

            if "Hub System Administrator password is the same as one of" in elem_info and \
                    "Hub Application Administrator password is the same as one of" in elem_info:
                self.web_driver.find_element(By.XPATH, self.xpath_pwd_retry).click()
                raise UserWarning("Modify toor4nsn and hubapp password failed due to duplicate password")
            if "Hub System Administrator password is the same as one of" in elem_info and \
                    "User name: toor4nsn" in elem_info:
                self.web_driver.find_element(By.XPATH, self.xpath_pwd_retry).click()
                raise UserWarning("Modify toor4nsn password failed due to duplicate password")
            if "Hub Application Administrator password is the same as one of" in elem_info and \
                    "User name: hubapp" in elem_info:
                self.web_driver.find_element(By.XPATH, self.xpath_pwd_retry).click()
                raise UserWarning("Modify hubapp password failed due to duplicate password")
            if "Changing Ne3s user password failed: Password is the same as the previous one" in elem_info and \
                    "User name: wsuser" in elem_info:
                self.web_driver.find_element(By.XPATH, self.xpath_pwd_retry).click()
                raise UserWarning("Modify wsuser password failed due to duplicate password")
            else:
                raise Exception("Modify password failed due to {}".format(e))

    @catch_exception
    def reset_accounts_password_to_default(self, account_type, user, check_required=True):
        xpath_reset_password = "{}//mat-checkbox//input[contains(@id, 'mat-checkbox')]"

        self.web_driver.get("https://192.168.255.129:3601/#/commissioning/cards")
        self.web_driver.find_element(By.ID, "accountsStartButton").click()
        Wait(self.web_driver, self.ui_delay * 3).until(
            EC.visibility_of_element_located((By.XPATH, self.xpath_configuration_accounts)))
        account_type_elem = self.web_driver.find_element(By.XPATH, self.xpath_account_type_locator)
        if account_type == account_type_elem.get_attribute('textContent').strip():
            logger.info("Account Type:{} is as expected".format(account_type), also_console=True)
        else:
            logger.info("Change Account Type to {}".format(account_type), also_console=True)
            self._select_value_in_mat_select(account_type_elem, account_type, lambda x, y: x.strip() == y.strip(),
                                             check_required)

        if type(user) is str:
            user = user.split()
        for user_each in user:
            reset_pwd_btn = self.web_driver.find_element(By.XPATH, xpath_reset_password.format(
                self.xpath_user_form.format(user_each)))
            if reset_pwd_btn.get_attribute('aria-checked') == 'true':
                logger.info("User:{} has been choose to reset to default".format(user_each), also_console=True)
            else:
                logger.info("Start to click user:{} to reset to default".format(user_each), also_console=True)
                self.web_driver.execute_script("arguments[0].click();", reset_pwd_btn)
        continue_btn = self.web_driver.find_elements(By.XPATH, self.xpath_continue)
        if continue_btn[0]:
            continue_btn[0].click()
        time.sleep(2)
        Wait(self.web_driver, self.ui_delay * 60).until(
            EC.visibility_of_element_located((By.XPATH, self.xpath_pwd_change_ok)))
        self.web_driver.find_element(By.XPATH, self.xpath_pwd_finish).click()

    """
    xpaths for added elements
    """
    xpath_tl_group_header = ("//div[@class='topology-view-columns-container']//div[contains(@class,'group-header')]"
                             "//span[text()='{}']")
    xpath_tpl_value = ("//div[@id='topologyDetailsContainer']//span[translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ',"
                       "'abcdefghijklmnopqrstuvwxyz')='{}' and contains(@class,'detail-title')]"
                       "//..//span[contains(@class,'detail-text')]")
    xpath_tpl_antmod_runtime = ("//div[@id='topologyDetailsContainer']//div[contains(@class, 'table-container')]"
                                "//tr//td[contains(@class, 'cdk-column-ANTANTL-managed-object')]"
                                "//span[contains(text(), 'ANTMOD_R')]")

    def check_site_info(self):
        xpath_status_bar = './/app-status-bar[@id="site-info"]//span[contains(@class, "operational-state")]'
        status_bar = Wait(self.web_driver, self.ui_delay * 3).until(EC.visibility_of_element_located(
            (By.XPATH, xpath_status_bar)))
        status = status_bar.text
        MolerTest.info('Current site status: {}'.format(status))
        if 'Not commissioned, PnP failed' in status:
            return False
        return True

    def click_dedicated_unit(self, group_name, unit_id, timeout=60):
        """
        Click Unit

        :param group_name: group name that unit belongs to, e.g. 'HUBMOD' or 'ANTMOD'
        :param unit_id: unit id, it can be string or list
        :param timeout: int, waiting timeout seconds for operation done
        :return: None
        """
        is_commissioned = self.check_site_info()
        unit_prefix = UNIT_MAPPING[group_name]
        wait = Wait(self.web_driver, timeout)
        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class, 'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(self.xpath_tl_group_header.format(group_name))
        if is_commissioned:
            field_to_search = 'paired managed object:'
            field_value = '{}-{}'.format(unit_prefix, unit_id)
            unit_label = field_value
        else:
            field_to_search = 'runtime managed object:'
            field_value = '{}_R-{}'.format(unit_prefix, unit_id)
            unit_label = '(' + field_value + ')'

        xpath_app_unit = "{}//app-unit//div[contains(@class,'description-label') and contains(text(), '{}')]" \
            .format(xpath_view_column, unit_label)
        MolerTest.info(xpath_app_unit)
        app_unit = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_app_unit)))

        app_unit.click()

        xpath_managed_object = self.xpath_tpl_value.format(field_to_search)
        MolerTest.info(xpath_managed_object)
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            managed_object = self.web_driver.find_elements(By.XPATH, xpath_managed_object)
            if managed_object \
                    and managed_object[0].get_attribute('textContent').split('/')[-1] == '{}' \
                    .format(field_value):
                break
        else:
            MolerTest.error(
                "Managed object '{} not appear after {}s".format(unit_label, timeout),
                raise_exception=True
            )

    def go_to_topology_view(self, tab):
        """
        Open tab of Topology View.

        :return: None
        """
        MolerTest.info("Change tab of topology view to '{}'".format(tab))
        self.enter_topology_view()

        xpath_tab = "//app-tabs[@id='topology-tabs']//a[contains(text(),'{}')]".format(tab)
        MolerTest.info('Xpath tab: {}'.format(xpath_tab))
        time.sleep(10)
        tab_btn = Wait(self.web_driver, self.ui_delay * 2).until(
            EC.element_to_be_clickable((By.XPATH, xpath_tab)))
        if tab_btn:
            tab_btn.click()

        expand_all_button = self.web_driver.find_element(
            By.XPATH,
            ".//mat-icon[@data-mat-icon-name='expandAll' and @svgicon='expandAll']")
        expand_all_button.click()

    def click_mat_icon_to_expand(self, id_of_node):
        """
        Expand node

        :param id_of_node: str, which node should be expanded.
        :return: None
        """
        # arrow right means the nodes are collapsed
        xpath_arrow_right = './/div[@id="{}"]'.format(id_of_node) + '//mat-icon[contains(@svgicon, "arrowRight")]'
        xpath_node = './/div[@id="{}"]'.format(id_of_node)

        last_field = id_of_node.split('/')[-1]
        if 'CHANNEL_R-' in last_field or 'ANTANTL_R-' in last_field:
            self.node_expanded_in_view.append(id_of_node)

        if id_of_node in self.node_expanded_in_view:
            MolerTest.info('Seems that {} is expanded.'.format(id_of_node))
            try:
                node = Wait(self.web_driver, 5).until(EC.element_to_be_clickable((By.XPATH, xpath_node)))
                self.web_driver.execute_script('arguments[0].scrollIntoView();', node)
                self.web_driver.execute_script("arguments[0].click();", node)
                MolerTest.info('Node "{}" is already expanded so click it!'.format(id_of_node))
            except TimeoutException:
                self.node_expanded_in_view.remove(id_of_node)
                if id_of_node == 'ASI-1':
                    view_collapse_all_button = Wait(self.web_driver, 5).until(EC.element_to_be_clickable(
                        (By.XPATH, './/button[@id="tree-view-collapse-all-button"]')))
                    view_collapse_all_button.click()
                    MolerTest.info('Collapse all in View.')
                    self.node_expanded_in_view = ['ASI-1']
            except Exception as e:
                MolerTest.info('Exception happened during click node: \n{}'.format(traceback.format_exc()))

        if id_of_node not in self.node_expanded_in_view:
            try:
                MolerTest.info('{} is not expanded.'.format(id_of_node))
                arrow_right = Wait(self.web_driver, 5).until(
                    EC.element_to_be_clickable((By.XPATH, xpath_arrow_right)))
                arrow_right.click()
                MolerTest.info('Expand {}!'.format(id_of_node))
                self.node_expanded_in_view.append(id_of_node)
            except TimeoutException:
                MolerTest.info('Try to click node {} (xpath: {})!'.format(id_of_node, xpath_node))
                node = Wait(self.web_driver, 10).until(EC.visibility_of_element_located((By.XPATH, xpath_node)))
                self.web_driver.execute_script('arguments[0].scrollIntoView();', node)
                self.web_driver.execute_script("arguments[0].click();", node)
                # node.click()
                MolerTest.info('Click node {} successfully!'.format(id_of_node))
                self.node_expanded_in_view.append(id_of_node)
            except Exception as e:
                MolerTest.info('Exception happened during expand node: \n{}'.format(traceback.format_exc()))

        if id_of_node != 'ASI-1':
            xpath_span_of_mo = '//span[@id="selected-mo-class" and contains(text(), "{}")]'.format(
                               id_of_node.split('/')[-1])
            MolerTest.info('Wait for "{}" ready.'.format(xpath_span_of_mo))
            Wait(self.web_driver, 5).until(EC.visibility_of_element_located((By.XPATH, xpath_span_of_mo)))

            # need wait for spinner shown and disappeared, then we can read the right value
            if self.check_loading_spinner:
                try:
                    MolerTest.info('Waiting for element app-loading-spinner-overlay')
                    Wait(self.web_driver, 3).until(
                        EC.visibility_of_element_located((By.XPATH, "//app-loading-spinner-overlay")))
                    self.check_loading_spinner = True
                except Exception as e:
                    self.check_loading_spinner = False
                    MolerTest.info('No app-loading-spinner: \n{}'.format(traceback.format_exc()))

    def locate_to_target_mo(self, managed_object, sub_menu='View', overwrite=True):
        """
        Show sub_menu page of 'Configuration management' and locate expected managed object

        :param managed_object: str, location of cell. For example: 'ASI-1/BTS-1/CELL-1'
        :param sub_menu: str, sub menu of 'Configuration management'
        :param overwrite: bool, whether overwrite the existing configuration
        :return: None
        """
        MolerTest.info('To locate target mo: {}'.format(managed_object))
        try_times = 0
        while try_times < 5:
            try:
                self.enter_config_man(sub_menu=sub_menu, overwrite=overwrite)
                if sub_menu == 'Edit':
                    self.switch_to_dedicated_tab(tab='Parameter editor', wait_after_switch=False)
                mo_fields = managed_object.split('/')
                id_of_node = ''
                if len(mo_fields):
                    for field in mo_fields:
                        id_of_node += field
                        # click node
                        self.click_mat_icon_to_expand(id_of_node)
                        id_of_node += '/'
                self.node_expanded_in_view.append(id_of_node)
                break
            except TimeoutException:
                MolerTest.info('Try to locate target mo again due to TimeoutException.')
                try_times += 1
                time.sleep(3)
            except Exception as e:
                MolerTest.info('Try to locate target mo again due to {}'.format(e))
                MolerTest.info(traceback.format_exc())
                try_times += 1
                time.sleep(3)
        else:
            MolerTest.error('It is hard to locate target mo in 5 times: {}'.format(managed_object),
                            raise_exception=True)

    def get_value_from_view(self, managed_object, parameters, xpath_value='', timeout=30):
        """
        Get values from 'View Configuration'

        :param managed_object: str, location of cell. For example: 'ASI-1/BTS-1/CELL-1'
        :param parameters: list, to get the value of these parameters under managed_object
                or
                dict ,  to get the value of these parameters of structured parameter of managed_object, like
                     # 'externalRIds' of 'connectionsInfoList
                     {'externalRIds': ['asiRmodRId', ]},
        :param xpath_value: str, xpath to get value to fast value search
        :param timeout: int or str, time to try
        :return: dict,
        """
        MolerTest.info('To get value for MO: {}, parameters: {}'.format(managed_object, parameters))
        values = {}
        ui_delay = self.ui_delay * 3
        dt_start = time.time()
        while time.time() < dt_start + int(timeout):
            try:
                self.locate_to_target_mo(managed_object)

                xpath_span_of_mo = '//span[@id="selected-mo-class" and contains(text(), "{}")]'.format(
                    managed_object.split('/')[-1])
                xpath_base = xpath_span_of_mo + '/../../'
                Wait(self.web_driver, 5).until(EC.visibility_of_element_located((By.XPATH, xpath_span_of_mo)))
                if isinstance(parameters, list) and parameters:
                    for para in parameters:
                        xpath_base += './/tr[@id="{}"]/td[3]'.format(para)
                        for xpath in (xpath_value,) + (
                                'input[contains(@class, "parameterValue")]',
                                'textarea[contains(@class, "parameterValue")]',
                                'div[contains(@class, "mat-select-trigger")]' +
                                '//span[contains(@class, "mat-select-value-text")]/span'
                        ):
                            if not xpath:
                                continue
                            xpath_para_value = xpath_base + '//' + xpath
                            MolerTest.info('xpath of {}: {}'.format(para, xpath_para_value))
                            try:
                                Wait(self.web_driver, ui_delay).until(EC.visibility_of_element_located(
                                    (By.XPATH, xpath_para_value)))
                                elem_para_value = self.web_driver.find_element(By.XPATH, xpath_para_value)
                                if xpath_para_value.endswith('span'):
                                    para_value = elem_para_value.text
                                else:
                                    para_value = elem_para_value.get_attribute('value')
                                break
                            except (TimeoutException, NoSuchElementException):
                                # try other element type
                                MolerTest.info('To try new element type')
                        else:
                            MolerTest.error('Can not find expected value!', raise_exception=True)
                        MolerTest.info('{}: {}'.format(para, para_value))
                        values[para] = para_value

                if isinstance(parameters, dict) and parameters:
                    for parent, children in parameters.items():
                        for para in children:
                            for elem_type in (xpath_value,) + ('input', 'textarea'):
                                if not elem_type:
                                    continue
                                xpath_para_value = \
                                    './/tr[@id="{}-0-{}"]/td[3]//{}[contains(@class, "parameterValue")]'.format(
                                                       parent, para, elem_type)
                                try:
                                    MolerTest.info('Check para value: {}'.format(xpath_para_value))
                                    Wait(self.web_driver, ui_delay).until(
                                        EC.visibility_of_element_located((By.XPATH, xpath_para_value)))
                                    break
                                except (TimeoutException, NoSuchElementException):
                                    # try other element type
                                    MolerTest.info('To try new element type')
                            para_value = self.web_driver.find_element(By.XPATH,
                                                                      xpath_para_value).get_attribute('value')
                            MolerTest.info('{}: {}'.format(para, para_value))
                            values[parent + '-' + para] = para_value

                break
            except Exception as e:
                MolerTest.info('Found exception during searching values. Try again...')
                self.check_loading_spinner = True
                time.sleep(1)
        else:
            MolerTest.error('Can not get values of {} for {} in 30s!'.format(parameters, managed_object),
                            raise_exception=True)
        MolerTest.info('Get values of {} for {}: {}'.format(parameters, managed_object, values))
        return values

    @catch_exception
    def get_shub_runtime_by_prrh(self, prrh_runtime_mo, timeout=60):
        managed_object = 'ASI-1/ASI_R-1/{}'.format(prrh_runtime_mo)
        parameters = ['antPortRDN']
        port_runtime = self.get_value_from_view(managed_object, parameters, timeout=timeout)['antPortRDN']
        shub_runtime = port_runtime.split('/')[2]
        return 'ASI-1/ASI_R-1/{}'.format(shub_runtime)

    @catch_exception
    def search_rfc_info(self, timeout=60):
        """
        Get all rfc ids from 'Cells' tab of 'Topology view', and map it to shub

        :param timeout: waiting timeout seconds for operation done
        :Return: list of cell information
            {
                # target_bts_id: [cell id]
                '100215': [{'id':100215.1, 'managed_object': 'ASI-1/BTS-1/CELL-1'}]
                '215': [215.0]
            }
        """
        rfc_cells = []
        self.go_to_topology_view("Cells")

        xpath_rfc_label = "//div[@id='topology-view-column-4']//app-unit//div[contains(@class, 'description-label') "
        xpath_rfc_label += "and contains(text(), 'RFC')]"

        # get some cell information from 'Cells' of 'Topology view' for RFC
        MolerTest.info('To search rfc label: {}'.format(xpath_rfc_label))

        label_results = self.web_driver.find_elements_by_xpath(xpath_rfc_label)
        MolerTest.info('Labels: {}'.format(label_results))
        xpath_rfc_value = ("//div[@id='topologyDetailsContainer']//div[contains(@class, 'group')]//"
                           "span[translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='{}' "
                           "and contains(@class,'detail-title')]//..//span[contains(@class,'detail-text')]")
        xpath_rfc_channel = xpath_rfc_value.format('paired managed object:')

        target_rfc_ids = []
        for label in label_results:
            # click unit to show properties
            label.find_element(By.XPATH, './parent::div').click()
            label_text = label.get_attribute('textContent')
            MolerTest.info('Get label text: {}'.format(label_text))
            if not label_text.strip():
                MolerTest.info('Skip "{}"'.format(label))
                continue
            # get id
            label_fields = label_text.split('.')
            target_rfc_id = int(label_fields[0].replace('RFC-', ''))
            if target_rfc_id not in target_rfc_ids:
                target_rfc_ids.append(target_rfc_id)
            target_rfc_cell_id = int(label_fields[1])
            MolerTest.info('Label fields: {}'.format(label_fields))
            rfc_cell = {'target_rfc_id': target_rfc_id, 'target_rfc_cell_id': target_rfc_cell_id, 'channels': {},
                        'target_prrh_runtime': None, 'target_shub_runtime': None}
            MolerTest.info('RFC Cell details: {}'.format(rfc_cell))

            dt_start = time.time()
            while time.time() < dt_start + timeout:
                rfc_channel_pmo = self.web_driver.find_elements(By.XPATH, xpath_rfc_channel)
                if rfc_channel_pmo:
                    for pmo in rfc_channel_pmo:
                        managed_object = pmo.get_attribute('textContent')
                        MolerTest.info('Got "Paired managed object" : {}'.format(managed_object))
                        xpath_channel_dir = pmo.find_element(
                            By.XPATH,
                            "../..//div//span[translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ',"
                            "'abcdefghijklmnopqrstuvwxyz')='target direction:' and contains(@class,'detail-title')]"
                            "//..//span[contains(@class,'detail-text')]")
                        channel_dir = xpath_channel_dir.get_attribute('textContent')
                        rfc_cell['channels'][managed_object] = channel_dir
                        if not rfc_cell['target_prrh_runtime']:
                            span_antantl_mo = pmo.find_element(
                                By.XPATH,
                                "../..//div//td[contains(@class,'cdk-column-ANTANTL-managed-object')]/div")
                            antantl_mo = span_antantl_mo.get_attribute('textContent')
                            # ASI-1/ASI_R-1/ANTMOD_R-2/ANTRFSM_R-1/ANTANTL_R-1
                            target_prrh_runtime = antantl_mo.split('/')[2]
                            rfc_cell['target_prrh_runtime'] = target_prrh_runtime
                    break
            else:
                MolerTest.error('Can not get "managed object" in {}s!'.format(timeout),
                                raise_exception=True)
            rfc_cells.append(rfc_cell)
        for rfc_cell in rfc_cells:
            target_prrh_runtime = rfc_cell['target_prrh_runtime']
            rfc_cell['target_shub_runtime'] = self.get_shub_runtime_by_prrh(target_prrh_runtime)
        MolerTest.info('Get all RFC Cell Info: {}'.format(rfc_cells))
        return rfc_cells

    @catch_exception
    def get_all_shubs(self, timeout=60):
        """
        WARNING: target_bts that is given for the loop may need to be adjusted for the number of BTS objects
        to work correctly with the given plus vaule in the for loop. A solution has been implemented to provide
        dynamic selecting but please be advised that this may not work in all cases.


        Search all sHUBs used for all RATs (NR and LTE)

        :param timeout: int, waiting timeout seconds for operation done
        :return: list,
        For example:
        [
            {
                'shub_mod_id': '1',
                'shub_type': 'APHG',
                'runtime_mo': 'ASI-0/ASI_R-1/HUBMOD_R-1',
                'coam_runtime_mo_id': '2'
            },
            {
                'shub_mod_id': '2',
                'shub_type': 'APHA',
                'runtime_mo': 'ASI-0/ASI_R-1/HUBMOD_R-2',
                'coam_runtime_mo_id': '1'
            }
        ]
        """
        shubs = []
        self.go_to_topology_view(tab="Cells")
        wait = Wait(self.web_driver, timeout)
        xpath_group_header = \
            "//div[@class='topology-view-columns-container']//div[contains(@class,'group-header')]//" + \
            "span[text()='sHUBs']"
        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class,'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(xpath_group_header)

        view_column = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_view_column)))
        expand_header_button = view_column.find_element(
            By.XPATH, ".//mat-icon[contains(@class,'expand-header-icon')]")
        if 'expand' == expand_header_button.get_attribute('svgicon'):
            expand_header_button.click()

        # locate specific sHUB
        view_app_units = Wait(view_column, timeout).until(
            EC.visibility_of_element_located((By.XPATH, ".//div[contains(@class, 'objects-container')]")))
        app_units = view_app_units.find_elements_by_xpath(".//app-unit[contains(@class, 'unit')]")

        for app_unit in app_units:
            desc_label = Wait(app_unit, self.ui_delay * 3).until(
                EC.visibility_of_element_located((By.XPATH, ".//div[contains(@class,'description-label')]")))
            desc_label = desc_label.text
            # like 'APHG (HUBMOD_R-1)'
            shub_id = desc_label.split('-')[-1].replace(')', '')
            shub_type = desc_label.split(' ')[0].strip()
            MolerTest.info('Found sHUB type: {}, shub id: {}'.format(shub_type, shub_id))

            # try to get runtime dn
            self.click_dedicated_unit(group_name=GROUP_SHUB, unit_id=shub_id, timeout=timeout)
            shub = {'shub_mod_id': shub_id, 'shub_type': shub_type.lower(), 'cells': [], 'rfc_cells': []}
            for field in ('Runtime Managed Object',):
                xpath_field = './/div[@id="topologyDetailsContainer"]//span[contains(@class,"detail-title") '
                xpath_field += 'and contains(text(), "{}")]/../'.format(field)
                xpath_field += 'span[contains(@class,"detail-text")]'
                value = self.web_driver.find_element(By.XPATH, xpath_field).text
                if field == 'Runtime Managed Object':
                    shub['runtime_mo'] = value
            MolerTest.info(shub)
            shubs.append(shub)

        cells = self.search_cell_info()

        try:
            rfc_cells = self.search_rfc_info()
        except Exception as e:
            MolerTest.error('Can not get RFC cells information!\b{}'.format(e))
            MolerTest.error(traceback.format_exc())
            rfc_cells = []

        for shub in shubs:
            runtime_mo = shub['runtime_mo']
            values = self.get_value_from_view(runtime_mo, parameters={'externalRIds': ['asiRmodRId', ]})
            shub['coam_runtime_mo_id'] = values['externalRIds-asiRmodRId']
            for cell in cells:
                if runtime_mo[6:] in cell['hubmod_in_cell_detail']:
                    shub['cells'].append(cell)
            for rfc_cell in rfc_cells:
                if runtime_mo in rfc_cell['target_shub_runtime']:
                    shub['rfc_cells'].append(rfc_cell)
            if not shub['cells']:
                MolerTest.error('Not found cell information for this shub: {}'.format(shub))
        MolerTest.info(shubs)
        return shubs

    @catch_exception
    @switch_to_tab('Profiles')
    def bulk_get_profile_info(self, profile_id=None, timeout=10):
        """
        Revise method
        """
        xpath_div_spinner_container = "//div[@class='spinner-container']"
        xpath_table_profile_id = "//div[@id='antenna-profile-list-content']//div[contains(@class,'profileId')]//span"
        xpath_details = "//div[@id='antenna-profile-parameters']"
        xpath_details_profile_id = xpath_details + "//div[contains(@class,'profileId')]//span"
        xpath_details_shub = xpath_details + "//div[contains(@class,'hubmodDn')]//span"
        xpath_details_user_label = xpath_details + "//input[contains(@class,'userLabel')]"
        xpath_details_module_type = xpath_details + "//mat-select[contains(@class,'moduleType')]"
        xpath_assigned_prrh_row = \
            "//app-antenna-profile-assignment//tbody//tr" \
            "//input[@type='checkbox' and @value='true']//ancestor::tr"

        if profile_id:
            xpath_table_profile_id += "[normalize-space(text())='{}']".format(profile_id)

        list_span_profile_id = self.web_driver.find_elements(By.XPATH, xpath_table_profile_id)
        dict_profile_info = OrderedDict()
        for span_profile_id in list_span_profile_id:
            span_profile_id.click()
            wait = Wait(self.web_driver, 1)
            try:
                loading_spinner = wait.until(EC.visibility_of_element_located((
                    By.XPATH, xpath_div_spinner_container)))
            except TimeoutException:
                loading_spinner = None
            if loading_spinner:
                wait = Wait(self.web_driver, timeout)
                wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            retry_times = 0
            while retry_times < 3:
                try:
                    profile_id = self.web_driver.find_element(
                        By.XPATH, xpath_details_profile_id).get_attribute('textContent').strip()
                    hubmod_dn = self.web_driver.find_element(
                        By.XPATH, xpath_details_shub).get_attribute('textContent').strip()
                    user_label = self.web_driver.find_element(
                        By.XPATH, xpath_details_user_label).get_attribute('value').strip()
                    module_type = self.web_driver.find_element(
                        By.XPATH, xpath_details_module_type).get_attribute('textContent').strip().split()[0]
                    break
                except Exception as e:
                    MolerTest.info("get profile parameters {}: {}".format(retry_times, str(e)))
                    retry_times += 1
                    if retry_times >= 3:
                        raise e
                    continue
            retry_times = 0
            while retry_times < 3:
                try:
                    assigned_prrh_rows = self.web_driver.find_elements(By.XPATH, xpath_assigned_prrh_row)
                    list_assigned_prrhs = []
                    for prrh_row in assigned_prrh_rows:
                        prrh_name = prrh_row.find_element(By.XPATH, ".//td[2]") \
                            .get_attribute("textContent").strip().split('/')[-1]
                        ant_port_id, slot = prrh_row.find_element(By.XPATH, ".//td[4]") \
                            .get_attribute("textContent").strip().split()[-1].split('-')
                        chained = slot == '2'
                        list_assigned_prrhs.append({'prrh': prrh_name, 'ant_port_id': ant_port_id,
                                                    'chained': chained})
                    break
                except Exception as e:
                    MolerTest.info("get assigned ant port retry times {}: {}".format(retry_times, str(e)))
                    retry_times += 1
                    if retry_times >= 3:
                        raise e
                    continue

            dict_profile_info[profile_id] = {'hubmod': hubmod_dn, 'user_label': user_label,
                                             'module_type': module_type, 'assigned_prrhs': list_assigned_prrhs}

        return dict_profile_info

    @catch_exception
    def get_prrh(self, hub_mod_index=1, timeout=60):
        prrhs = []
        self.go_to_topology_view(tab="Cells")
        wait = Wait(self.web_driver, timeout)
        xpath_group_header = \
            "//div[@class='topology-view-columns-container']//div[contains(@class,'group-header')]//" + \
            "span[text()='pRRHs']"
        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class,'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(xpath_group_header)

        view_column = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_view_column)))
        expand_header_button = view_column.find_element(
            By.XPATH, ".//mat-icon[contains(@class,'expand-header-icon')]")
        if 'expand' == expand_header_button.get_attribute('svgicon'):
            expand_header_button.click()

        # locate specific sHUB
        view_app_units = Wait(view_column, timeout).until(
            EC.visibility_of_element_located((By.XPATH, ".//div[contains(@class, 'objects-container')]")))
        xpath_hub_description = (".//div[contains(@class, 'description-text') and contains(text(), 'HUBMOD-{}')]".
                                 format(hub_mod_index))
        hub_description = view_app_units.find_element_by_xpath(xpath_hub_description)
        app_units = hub_description.find_elements_by_xpath("../../..//app-unit[contains(@class, 'unit')]")

        for app_unit in app_units:
            desc_label = Wait(app_unit, self.ui_delay * 3).until(
                EC.visibility_of_element_located((By.XPATH, ".//div[contains(@class,'description-label')]")))
            desc_label = desc_label.text
            # like 'AWHHIQB (ANTMOD-1)'
            antmod_id = desc_label.split('-')[-1].replace(')', '')
            antmod_type = desc_label.split(' ')[0].strip()
            MolerTest.info('Found pRRH of HUBMOD-{}: {}, {}, {}'.format(
                hub_mod_index, desc_label, antmod_type, antmod_id))

            # try to get runtime dn
            self.click_dedicated_unit(group_name=GROUP_PRRH, unit_id=antmod_id, timeout=timeout)
            prrh = {'ant_mod_id': antmod_id, 'ant_mod_type': antmod_type.lower(), 'chained_mo': {}}
            for field in ('Runtime managed object', 'Managed object', 'Position in chain'):
                xpath_field = './/div[@id="topologyDetailsContainer"]//span[contains(@class,"detail-title") '
                xpath_field += 'and contains(text(), "{}")]/../'.format(field)
                xpath_field += 'span[contains(@class,"detail-text")]'
                value = self.web_driver.find_element(By.XPATH, xpath_field).text
                if field == 'Runtime managed object':
                    prrh['runtime_mo'] = value
                elif field == 'Managed object':
                    prrh['managed_object'] = value
                elif field == 'Position in chain':
                    prrh['pos_in_chain'] = value
            MolerTest.info(prrh)
            prrhs.append(prrh)

        # Found all prrhs of HUBMOD-1: [
        # {'ant_mod_id': '1', 'ant_mod_type': 'awhhiqb', 'runtime_mo': 'ASI-1/ASI_R-1/ANTMOD_R-1'}
        # ]
        for prrh in prrhs:
            pos_in_chain = str(prrh['pos_in_chain'])
            if pos_in_chain == '1':
                other_prrhs = prrhs.copy()
                other_prrhs.remove(prrh)
                managed_object = prrh['managed_object']
                for other_prrh in other_prrhs:
                    other_managed_object = other_prrh['managed_object']
                    other_runtime_mo = other_prrh['runtime_mo']
                    other_ant_mod_id = other_prrh['ant_mod_id']
                    if managed_object == other_managed_object:
                        prrh['chained_mo'][other_runtime_mo] = other_ant_mod_id

        MolerTest.info('Found all prrhs of HUBMOD-{}: {}'.format(hub_mod_index, prrhs))
        return prrhs

    @catch_exception
    def search_cell_info(self, timeout=60):
        """
        Get all cell ids from 'Cells' tab of 'Topology view', and map it to shub

        :param timeout: waiting timeout seconds for operation done
        :Return: list of cell information
            {
                # target_bts_id: [cell id]
                '100215': [{'id':100215.1, 'managed_object': 'ASI-1/BTS-1/CELL-1'}]
                '215': [215.0]
            }
        """

        def get_lte_band(earfcn):
            earfcn = int(earfcn)
            band = 0
            if 0 <= earfcn <= 599:
                band = 1
            elif 600 <= earfcn <= 1199:
                band = 2
            elif 1200 <= earfcn <= 1949:
                band = 3
            elif 1950 <= earfcn <= 2399:
                band = 4
            elif 2400 <= earfcn <= 2649:
                band = 5
            elif 2650 <= earfcn <= 2749:
                band = 6
            elif 2750 <= earfcn <= 3449:
                band = 7
            elif 3450 <= earfcn <= 3799:
                band = 8
            elif 3800 <= earfcn <= 4149:
                band = 9
            elif 4150 <= earfcn <= 4749:
                band = 10
            elif 4750 <= earfcn <= 4949:
                band = 11
            elif 5010 <= earfcn <= 5179:
                band = 12
            elif 5180 <= earfcn <= 5279:
                band = 13
            elif 5280 <= earfcn <= 5379:
                band = 14
            elif 5730 <= earfcn <= 5849:
                band = 17
            elif 5850 <= earfcn <= 5999:
                band = 18
            elif 6000 <= earfcn <= 619:
                band = 19
            elif 6150 <= earfcn <= 6449:
                band = 20
            elif 6450 <= earfcn <= 6599:
                band = 21
            elif 6600 <= earfcn <= 7399:
                band = 22
            elif 7700 <= earfcn <= 8039:
                band = 24
            elif 8040 <= earfcn <= 8689:
                band = 25
            elif 8690 <= earfcn <= 9039:
                band = 26
            elif 9040 <= earfcn <= 9209:
                band = 27
            elif 9210 <= earfcn <= 9659:
                band = 28
            elif 9660 <= earfcn <= 9769:
                band = 29
            elif 9770 <= earfcn <= 9869:
                band = 30
            elif 9870 <= earfcn <= 9919:
                band = 31
            elif 9920 <= earfcn <= 10359:
                band = 32
            elif 36000 <= earfcn <= 36199:
                band = 33
            elif 38650 <= earfcn <= 39649:
                band = 40
            elif 39650 <= earfcn <= 41589:
                band = 41
            elif 46790 <= earfcn <= 54539:
                band = 46
            elif 55240 <= earfcn <= 56739:
                band = 48
            elif 65536 <= earfcn <= 66435:
                band = 65
            elif 66436 <= earfcn <= 67335:
                band = 66
            elif 67336 <= earfcn <= 67535:
                band = 67
            return band
        is_commissioned = self.check_site_info()

        self.go_to_topology_view("Cells")
        xpath_cell_label = ".//app-unit//div[contains(@class, 'description-label') and contains(text(), 'BTS')]"
        cells = []

        # get some cell information from 'Cells' of 'Topology view'
        label_results = self.web_driver.find_elements_by_xpath(xpath_cell_label)
        MolerTest.info('Labels: {}'.format(label_results))
        if is_commissioned:
            xpath_span_managed_object = self.xpath_tpl_value.format('paired managed object:')
        else:
            xpath_span_managed_object = self.xpath_tpl_value.format('cell technology:')

        # fix for dual-core case
        target_bts_ids = []
        for label in label_results:
            # get id
            label_fields = label.text.split('.')
            target_bts_id = int(label_fields[0].replace('BTS', ''))
            if target_bts_id not in target_bts_ids:
                target_bts_ids.append(target_bts_id)
            target_lcr_id = int(label_fields[1])
            MolerTest.info('Label fields: {}'.format(label_fields))

            cell = {'target_lcr_id': target_lcr_id, 'target_bts_id': target_bts_id}

            # click unit to show properties
            label.click()

            MolerTest.info('Cell details: {}'.format(cell))

            dt_start = time.time()
            while time.time() < dt_start + timeout:
                span_paired_managed_objects = self.web_driver.find_elements(By.XPATH, xpath_span_managed_object)
                if span_paired_managed_objects:
                    for span_paired_managed_object in span_paired_managed_objects:
                        managed_object = span_paired_managed_object.get_attribute('textContent')
                        MolerTest.info('Got "Paired managed object" : {}'.format(managed_object))
                        if 'CHANNELGROUP-' in managed_object:
                            continue
                        cell['cell_managed_object'] = managed_object
                        for field in ('cell technology', 'hubantl managed object', 'band indicator for 5g nr'):
                            xpath_field = self.xpath_tpl_value.format(field.lower() + ':')
                            values = self.web_driver.find_elements(By.XPATH, xpath_field)
                            if 'band indicator' in field:
                                if values:
                                    cell['rat'] = "NR"
                                    cell['band'] = int(values[0].get_attribute('textContent'))
                                else:
                                    cell['rat'] = "LTE"
                                    if cell['technology'] == "fdd":
                                        xpath_field = self.xpath_tpl_value.format('arfcn downlink (fdd):')
                                        values = self.web_driver.find_elements(By.XPATH, xpath_field)
                                        arfcn = values[0].get_attribute('textContent')
                                        cell['band'] = get_lte_band(arfcn)
                                    elif cell['technology'] == "tdd":
                                        xpath_field = self.xpath_tpl_value.format('arfcn (tdd):')
                                        values = self.web_driver.find_elements(By.XPATH, xpath_field)
                                        arfcn = values[0].get_attribute('textContent')
                                        cell['band'] = get_lte_band(arfcn)
                                    else:
                                        MolerTest.error(
                                            'Need update codes to support other technology: {}'.format(
                                                cell['technology']), raise_exception=True)
                            field_value = values[0].get_attribute('textContent')
                            if 'cell technology' in field:
                                cell['technology'] = field_value.lower()
                            elif 'hubantl' in field:
                                cell['hubmod_in_cell_detail'] = '/'.join(field_value.split('/')[:-1])
                        MolerTest.info('To search "{}"'.format(self.xpath_tpl_antmod_runtime))
                        ant_mod_runtime_objs = self.web_driver.find_elements(By.XPATH, self.xpath_tpl_antmod_runtime)
                        cell['ant_mod_runtimes'] = []
                        for obj in ant_mod_runtime_objs:
                            ant_mod_runtime = obj.text.rstrip('/')
                            MolerTest.info('Found ant_mod_runtime: {}'.format(ant_mod_runtime))
                            if ant_mod_runtime not in cell['ant_mod_runtimes']:
                                cell['ant_mod_runtimes'].append(ant_mod_runtime)
                        MolerTest.info(f'Cell added" : {cell}')
                        cells.append(cell)
                    break
            else:
                MolerTest.error('Can not get "managed object" in {}s!'.format(timeout),
                                raise_exception=True)

        # update cell runtime information
        MolerTest.info('Found all BTS: {}'.format(target_bts_ids))  # fix for dual-core case
        MolerTest.info('All Cell info found so far: {}'.format(cells))
        bts_objects = []
        try:
            for cell in cells:
                bts_object = cell["cell_managed_object"].split("/")[1]
                if bts_object not in bts_objects:
                    bts_objects.append(bts_object)
        except KeyError as e:
            MolerTest.error(f"KeyError when parsing bts objects: {e}", raise_exception=False)
        # try 3 times to search all cell runtime and configDN correctly
        bts_objects_number = len(bts_objects) if len(bts_objects) > len(target_bts_ids) else len(target_bts_ids)
        try_times = 0
        while try_times < 3:
            try:
                asir_cell_runtimes = self.search_cell_runtime_and_cfgdn(total_bts=bts_objects_number)
                cell_index = 0
                for cell in cells:
                    cell_mo = cell['cell_managed_object']
                    MolerTest.info(f'Cell_mo:{cell_mo}')
                    cells[cell_index]['cell_runtime'] = asir_cell_runtimes[cell_mo]['cell_runtime']
                    cells[cell_index]['channel_group_runtime'] = asir_cell_runtimes[cell_mo]['channel_group_runtime']
                    cell_index += 1
                break
            except Exception as e:
                logger.info(f'Search Cell Runtime and ConfigDN failure: {e}. Try again...', also_console=True)
                try_times += 1

        if try_times == 3:
            MolerTest.error('Can not get cell runtime and configDN in 3 times!', raise_exception=True)
        MolerTest.info('Get all Cell Info: {}'.format(cells))

        return cells

    @catch_exception
    def search_cell_runtime_and_cfgdn(self, total_bts):
        """
        WARNING: target_bts that is given for the loop may need to be adjusted for the number of BTS objects
        to work correctly with the given plus vaule in the for loop. A solution has been implemented to provide
        dynamic selecting but please be advised that this may not work in all cases.

        To search all cells' runtime with configDN value in View configuration

        :param total_bts: int, total BTS number
        :return dict
        """
        MolerTest.info('Start to search all cell runtime.')
        cell_runtimes = []
        for bts_id in range(1, total_bts + 1):
            bts_runtime_mo = 'ASI-1/ASI_R-1/BTS_R-{}'.format(bts_id)
            self.locate_to_target_mo(bts_runtime_mo)
            cell_runtime_xpath = './/div[contains(@id, "{}/CELL_R")]'.format(bts_runtime_mo)
            elem_cell_runtimes = self.web_driver.find_elements_by_xpath(cell_runtime_xpath)
            for elem_cell_runtime in elem_cell_runtimes:
                cell_runtimes.append(elem_cell_runtime.get_attribute('id'))
        MolerTest.info('Found all cell runtimes: {}'.format(cell_runtimes))

        cell_runtime_mapping = {}
        if cell_runtimes:
            for cell_runtime_mo in cell_runtimes:
                channel_group_of_cell = []
                # search channel group of cell runtime
                self.locate_to_target_mo(cell_runtime_mo)
                channel_group_xpath = './/div[contains(@id, "{}/CHANNELGROUP_R")]'.format(cell_runtime_mo)
                MolerTest.info('To search channel group runtime: {}'.format(channel_group_xpath))
                elem_channel_groups = self.web_driver.find_elements_by_xpath(channel_group_xpath)
                MolerTest.info('All found elements of channelGroup: {}'.format(elem_channel_groups))
                for elem_channel_group in elem_channel_groups:
                    elem_channel_group_id = elem_channel_group.get_attribute('id')
                    MolerTest.info('Found "id" of the element of channelGroup: {}'.format(elem_channel_group_id))
                    channel_group_of_cell.append(elem_channel_group_id)
                # get value of configDN
                config_dn = self.get_value_from_view(
                    cell_runtime_mo,
                    parameters=['configDN'],
                    xpath_value='textarea[contains(@class, "parameterValue")]')['configDN']
                cell_runtime_mapping[config_dn] = {
                    'cell_runtime': cell_runtime_mo,
                    'channel_group_runtime': channel_group_of_cell
                }
        MolerTest.info('Found all cell runtime mapping: {}'.format(cell_runtime_mapping))
        return cell_runtime_mapping

    @catch_exception
    def delete_all_asir_cells(self, coam_cell_info, asir_shubs):
        self.enter_config_man()
        for cell_dn, cell_info in coam_cell_info.items():
            MolerTest.info('To delete cell: {}'.format(cell_dn))
            coam_lcr_id = int(cell_info['lcrid'])
            coam_rat = cell_info['rat'].lower()
            coam_target_bts_id = int(cell_info['target_bts_id'])
            for shub in asir_shubs:
                shub_mod_id = shub['shub_mod_id']
                asir_cells = shub['cells']
                for asir_cell in asir_cells:
                    asir_cell_managed_object = asir_cell['cell_managed_object']
                    asir_rat = asir_cell['rat'].lower()
                    asir_cell_id = asir_cell_managed_object.split('-')[-1]
                    target_lcr_id = int(asir_cell['target_lcr_id'])
                    asir_target_bts_id = int(asir_cell['target_bts_id'])
                    if coam_lcr_id == target_lcr_id and coam_rat == asir_rat and \
                            coam_target_bts_id == asir_target_bts_id:
                        # asir bts id
                        asir_bts_id = asir_cell_managed_object.split('/')[1].split('-')[-1]
                        break
                else:
                    asir_cell_id = None
                    asir_bts_id = None
                if asir_cell_id and asir_bts_id:
                    break
            else:
                MolerTest.error('Can not get available cell id for COAM cell({})!'.format(cell_dn),
                                raise_exception=True)

            MolerTest.info(
                'When delete, shub info: {}, shub_mod_id: {}, asir_cell_id: {}, asir_bts_id(type_id): {}'.format(
                    shub, shub_mod_id, asir_cell_id, asir_bts_id))
            # self.enter_config_man()
            self.delete_cell_manually(cell_type="BTS", type_id=asir_bts_id, cell_id=asir_cell_id)
            # self.activate_new_plan()
        self.activate_new_plan()

    def import_detected_configuration(self, mode='complete'):
        assert (mode.lower() in ['complete', 'incremental']
                ), "parameter {} is not valid, should be in ['complete', 'incremental']".format(mode)
        xpath_import_detected_btn = "//button[@id='import-detected-configuration-button']"
        xpath_modal = "//div[@id='configuration-scope-modal']"
        xpath_complete_import_radio = "{}//b[contains(text(),'Complete')]".format(
            xpath_modal)
        xpath_incremental_import_radio = "{}//b[contains(text(),'Incremental')]".format(
            xpath_modal)
        xpath_continue_btn = "{}//button[contains(text(),'Continue')]".format(
            xpath_modal)
        xpath_select_mode = ''
        if mode.lower() == 'complete':
            xpath_select_mode = xpath_complete_import_radio
        elif mode.lower() == 'incremental':
            xpath_select_mode = xpath_incremental_import_radio
        self.web_driver.find_element(By.XPATH, xpath_import_detected_btn).click()
        self.web_driver.find_element(By.XPATH, xpath_select_mode).click()
        self.web_driver.find_element(By.XPATH, xpath_continue_btn).click()
        Wait(self.web_driver, self.ui_delay * 3).until(
            EC.invisibility_of_element_located((By.XPATH, '//div[@id="configuration-scope-modal"]')))
        MolerTest.info('Import detected configuration successfully!')

    @catch_exception
    def click_all_cells_after_detect(self):
        """
        After clicking 'Import detected configuration',
        all cells need be clicked so that cell information can be sync.
        """
        cell_list_table = self.web_driver.find_element_by_id('cell-list-table')
        cell_list_items = cell_list_table.find_elements_by_tag_name('tr')
        for cell_item in cell_list_items:
            element_id = cell_item.get_attribute('id').strip()
            if not element_id:
                continue
            MolerTest.info('To click element by id: {}'.format(element_id))
            cell_item.click()
            time.sleep(self.ui_delay * 3)

    @catch_exception
    @switch_to_tab('Cells')
    def populate_cell_mapping_info(self, bts_id, cell_id, profile_id, band_class, antl1=None, antl2=None,
                                   antl3=None, antl4=None,  returned_time_cost={}, spinner_check=True):
        """
        Revised
        """
        xpath_cell_tr_in_cell_list_content \
            = "//div[@id='cells-list-content']//tr[contains(@id,'/BTS-{}/CELL-{}')]".format(bts_id, cell_id)
        xpath_div_cell_mapping = "//div[@id='cell-details-mapping-content']"
        xpath_profile_tr_in_mapping_table = "{}//tbody//tr[contains(@id,'/ANTMODPR-{}')]" \
            .format(xpath_div_cell_mapping, profile_id)
        xpath_rel_mat_select_module_type = ".//mat-select[contains(@class,'profileBandClass')]"
        xpath_formatter_rel_mat_select_antl = ".//mat-select[contains(@class,'profileHubAntl-{}')]"

        # ARHHB (Band 41)
        # ARHHB
        # (Band 41)
        if len(band_class.split()) > 1 and not band_class.strip().startswith('('):
            def lambda_band_class_compare(x, y):
                return x.strip() == y
        else:
            def lambda_band_class_compare(x, y):
                return y in x.strip().split(' ', 1)

        cell_tr_in_cell_list_content = Wait(self.web_driver, 30).until(
            EC.element_to_be_clickable((By.XPATH, xpath_cell_tr_in_cell_list_content)))
        cell_tr_in_cell_list_content.click()

        dt_start = time.time()
        while time.time() < dt_start + 30:
            try:
                Wait(self.web_driver, self.ui_delay * 5).until(
                    EC.visibility_of_element_located((By.XPATH, xpath_profile_tr_in_mapping_table)))
                tr_profile = self.web_driver.find_element(By.XPATH, xpath_profile_tr_in_mapping_table)

                mat_select_module_type = tr_profile.find_element(By.XPATH, xpath_rel_mat_select_module_type)

                self._select_value_in_mat_select(
                    mat_select_module_type, band_class, lambda_band_class_compare)

                break
            except Exception as e:
                time.sleep(3)
        else:
            MolerTest.error('Can not get right module type.')

        if band_class == '(Clear)' or band_class == '<No select>':
            MolerTest.info('BTS-{}/CELL-{} Profile {} cleared'.format(bts_id, cell_id, profile_id))
        else:
            for i, antl in enumerate([antl1, antl2, antl3, antl4]):
                if antl:
                    antl_select = tr_profile.find_element(
                        By.XPATH, xpath_formatter_rel_mat_select_antl.format(i + 1))
                    self._select_value_in_mat_select(antl_select, antl, lambda x, y: x.strip() == y)
            MolerTest.info("Populated cell mapping info BTS-{}/CELL-{} with profile {}".format(
                bts_id, cell_id, profile_id))

        if spinner_check:
            dt_start = time.time()
            xpath_div_spinner_container = "//div[@class='spinner-container']"
            xpath_div_antennas_profile_list_content = "//div[@id='cells-list-content']"
            self.web_driver.find_element(By.XPATH, xpath_div_antennas_profile_list_content).click()
            wait = Wait(self.web_driver, 1)
            try:
                loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH,
                                                                               xpath_div_spinner_container)))
            except TimeoutException:
                loading_spinner = None

            if loading_spinner is None:
                MolerTest.info("No loading spinner appeared")
                returned_time_cost['time_cost'] = 0
                return
            wait = Wait(self.web_driver, 60)
            wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            returned_time_cost['time_cost'] = time.time() - dt_start

    def activate_new_plan(self):
        result = self.prevalidate()
        MolerTest.info('Prevalidate result : {}'.format(result))
        if result['ret']:
            MolerTest.info('No error found.')
        else:
            MolerTest.error('Found prevalidate error!', raise_exception=True)
        result = self.activate()
        MolerTest.info('Activate new plan file : {}'.format(result))
        if result['ret']:
            MolerTest.info('Activate successfully.')
        else:
            MolerTest.error('Activation error!', raise_exception=True)

    @catch_exception
    def add_all_asir_cells(self, coam_cell_info, asir_shubs):
        """
        Add ASiR Cells

        :param coam_cell_info: dict, refer to internal_data.py
        :param asir_shubs: dict, refer to internal_data.py

        :return: None
        """
        for shub in asir_shubs:
            shub_mod_id = shub['shub_mod_id']
            shub_mo = 'ASI-1/HUBMOD-{}'.format(shub_mod_id)
            prrhs = self.get_prrh(shub_mod_id, timeout=600)
            MolerTest.info('All prrhs of "{}": {}'.format(shub_mo, prrhs))
            shub['prrhs'] = prrhs

        self.enter_config_man()
        profiles = self.bulk_get_profile_info()
        MolerTest.info('All profile information: {}'.format(profiles))

        MolerTest.info('Start import detected configuration')
        self.switch_to_dedicated_tab(tab='Cells')
        self.import_detected_configuration(mode='incremental')
        self.click_all_cells_after_detect()

        # check and change cell mapping information
        cell_mapping_information = {}
        for cell_dn, cell_info in coam_cell_info.items():
            cell_mapping_information[cell_dn] = {'unused_profile_ids': [], 'used_profile_ids': []}
            coam_lcr_id = int(cell_info['lcrid'])
            coam_rat = cell_info['rat'].lower()
            coam_target_bts_id = int(cell_info['target_bts_id'])
            coam_cell_id = int(cell_info['cell_id'])
            ant_channels = cell_info['ant_channels']
            cell_band_str = cell_info['cell_band'].lower()
            tech = cell_info['tech']
            if cell_band_str.startswith('n'):
                cell_band = int(cell_band_str.replace('n', ''))
            else:
                cell_band = int(cell_band_str.split(' ')[0])

            for shub in asir_shubs:
                shub_mod_id = shub['shub_mod_id']
                shub_mo = 'ASI-1/HUBMOD-{}'.format(shub_mod_id)
                shub_type = shub['shub_type']
                cells = shub['cells']
                coam_runtime_mo_id = shub['coam_runtime_mo_id']

                for cell in cells:
                    cell_mo = cell['cell_managed_object']
                    asir_rat = cell['rat'].lower()
                    ant_mod_runtime_of_cell = cell['ant_mod_runtimes'][0].lower()
                    asir_bts_id = cell_mo.split('/')[1].split('-')[-1]
                    asir_target_bts_id = int(cell['target_bts_id'])
                    target_lcr_id = int(cell['target_lcr_id'])
                    if (target_lcr_id != coam_lcr_id or coam_rat != asir_rat or
                            coam_target_bts_id != asir_target_bts_id):
                        continue
                    MolerTest.info('To search profile for {}'.format(cell_mo))

                    # then to search profile
                    for profile_id, detail in profiles.items():
                        MolerTest.info('Compare "{}" and "{}"'.format(
                            detail['hubmod'], '{} ({})'.format(shub_mo, shub_type.upper())))
                        if detail['hubmod'] != '{} ({})'.format(shub_mo, shub_type.upper()):
                            continue
                        cell_mapping_information[cell_dn]['unused_profile_ids'].append(profile_id)
                        for prrh in shub['prrhs']:
                            runtime_mo = prrh['runtime_mo'].lower()
                            prrh_type = detail['module_type'].upper()
                            MolerTest.info('prrh type Compare "{}" and "{}"'.format(prrh['ant_mod_type'], prrh_type))
                            MolerTest.info('prrh runtime mo "{}" and "{}"'.format(runtime_mo,
                                                                                  ant_mod_runtime_of_cell))
                            if prrh['ant_mod_type'].upper() == prrh_type and runtime_mo.endswith(
                                    ant_mod_runtime_of_cell):
                                for assigned_prrh in detail['assigned_prrhs']:
                                    MolerTest.info('prrh Compare "{}" and "{}"'.format(
                                        'ANTMOD-{}'.format(prrh['ant_mod_id']), assigned_prrh['prrh']))
                                    if 'ANTMOD-{}'.format(prrh['ant_mod_id']) == assigned_prrh['prrh']:
                                        cell_mapping_information[cell_dn]['unused_profile_ids'].remove(profile_id)
                                        cell_mapping_information[cell_dn]['used_profile_ids'].append(profile_id)
                                        cell_mapping_information[cell_dn]['band_class'] = BAND_CLASS[prrh_type][
                                            cell_band]
                                        cell_mapping_information[cell_dn]['bts_id'] = asir_bts_id
                                        cell_mapping_information[cell_dn]['cell_id'] = \
                                            cell_mo.split('/')[-1].split('-')[-1]
            if not cell_mapping_information[cell_dn]['used_profile_ids']:
                MolerTest.error('Can not find profile id for {}'.format(cell_dn))

        MolerTest.info('Cell mapping information: {}'.format(cell_mapping_information))

        for cell_dn, mapping_info in cell_mapping_information.items():
            MolerTest.info('Mapping information of {}: {}'.format(cell_dn, mapping_info))
            bts_id = mapping_info['bts_id']
            cell_id = mapping_info['cell_id']
            band_class = mapping_info['band_class']
            used_profile_ids = mapping_info['used_profile_ids']
            for profile_id in used_profile_ids:
                MolerTest.info('Change cell mapping info with profile {}'.format(profile_id))
                self.populate_cell_mapping_info(
                    bts_id=bts_id, cell_id=cell_id, profile_id=profile_id, band_class=band_class)

            unused_profile_ids = mapping_info['unused_profile_ids']
            for profile_id in unused_profile_ids:
                MolerTest.info('No select cell mapping info with profile {}'.format(profile_id))
                # unselect other profile
                self.populate_cell_mapping_info(
                    bts_id=bts_id, cell_id=cell_id, profile_id=profile_id, band_class='<No select>')

        self.activate_new_plan()

    def disable_energy_saving_status_for_hubs(self, hubs_data, timeout=60):
        hub_status = self.get_energy_saving_status_for_hubs(hubs_data=hubs_data, timeout=timeout)
        self.set_energy_saving_status_for_hubs(hubs_to_modify=hub_status)

    def set_energy_saving_status_for_hubs(self, hubs_to_modify):
        parameter = "actLbEnergySaving"
        value = "false"
        for hub in hubs_to_modify:
            if hub["energy_saving_status"] != "false":
                delta = {
                    'para_mo': hub["hub_dist_name"],
                    'para_abbr': parameter,
                    'value': value
                }
                self.enter_config_man()
                self.modify_parameter(list_para=[delta])
                self.activate_new_plan()
            else:
                logger.info(f"Skipping {hub['hub_dist_name']} due to having actLbEnergySaving set to "
                            f"{hub['energy_saving_status']}")

    def validate_all_hubs_are_not_in_energy_saving_mode(self, hubs_data, timeout=60):
        hub_status = self.get_energy_saving_status_for_hubs(hubs_data=hubs_data, timeout=timeout)
        for hub in hub_status:
            if hub["energy_saving_status"] != "false":
                raise AssertionError(f"HUB {hub['hub_dist_name']} has actLbEnergySaving set to "
                                     f"{hub['energy_saving_status']} while 'false' was expected")

    def get_energy_saving_status_for_hubs(self, hubs_data, timeout=60):
        hub_dist_names = self.prepare_hub_dist_names(hubs_data=hubs_data)
        parameters = ['actLbEnergySaving']
        hub_status = []
        for hub in hub_dist_names:
            energy_saving_status = self.get_value_from_view(hub, parameters, timeout=timeout)["actLbEnergySaving"]
            logger.info(f'Energy saving status for {hub}: {energy_saving_status}')
            hub_status.append({"hub_dist_name": hub, "energy_saving_status": energy_saving_status})
        return hub_status

    @staticmethod
    def prepare_hub_dist_names(hubs_data):
        hub_dist_names = []
        dist_name = "ASI-1/HUBMOD-{}"
        for hub in hubs_data:
            hub_dist_name = dist_name.format(hub["shub_mod_id"])
            if hub_dist_name not in hub_dist_names:
                logger.info(f"New HUB dist name found: {hub_dist_name}")
                hub_dist_names.append(hub_dist_name)
        return hub_dist_names

    @catch_exception
    def get_user_info(self, online_mode=True, timeout=20):
        dict_ret = {}
        if online_mode:
            self.web_driver.find_element(By.XPATH, AsirSelenium.XPATH_USER_DROPDOWN_MENU).click()
            dict_ret['username'] = self.web_driver.find_element(
                By.XPATH, AsirSelenium.XPATH_USERNAME).text
            dict_ret['role'] = self.web_driver.find_element(
                By.XPATH, AsirSelenium.XPATH_USER_ROLE).text
            dict_ret['access_mode'] = self.web_driver.find_element(
                By.XPATH, AsirSelenium.XPATH_USER_ACCESS_MODE).text
            dict_ret['account_type'] = self.web_driver.find_element(
                By.XPATH, AsirSelenium.XPATH_USER_ACCOUNT_TYPE).text
            dict_ret['last_login_time'] = self.web_driver.find_element(
                By.XPATH, AsirSelenium.XPATH_USER_LAST_LOGIN_TIME).text
            dict_ret['invalid_login_attempts'] = self.web_driver.find_element(
                By.XPATH, AsirSelenium.XPATH_USER_INVALID_LOGIN_ATTEMPTS).text
            return dict_ret

    @catch_exception
    def get_config_man_buttons_clickability_status(self, timeout=60):
        """
        Get buttons' statuses in configuration management
        :return: dict with boolean values - True for enabled buttons, False for disabled buttons,
        For example:
        {
            'edit': True,
            'detect': False,
            'view': True,
            'reset': False,
            'save': True,
            'load file': False,
            'continue': False,
            'accounts': True,
            'load template': False
        }
        """
        timeout = int(timeout)
        wait = Wait(self.web_driver, timeout)
        self.enter_config_man(sub_menu=None)
        is_button_active_dict = {}
        for sub_menu, button_id in AsirSelenium.CONFIG_MAN_SUB_MENU_BUTTON_IDS.items():
            button = self.web_driver.find_elements(By.XPATH, "//*[@id='{}']".format(button_id))
            if button:
                is_button_active_dict[sub_menu] = button[0].is_enabled()

        return is_button_active_dict
