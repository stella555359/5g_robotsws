import os
import tempfile
import time
from functools import wraps
from pprint import pprint
from robot.api import logger
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait as Wait
from pyvirtualdisplay import Display
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.common.action_chains import ActionChains
from collections import OrderedDict
from moler.util.moler_test import MolerTest
import subprocess
from taf.selenium.sbts import sbts
from functools import partial


class Dev_ASIR_Selenium(object):
    """ Library for ASIR WebEm Test with Selenium
    This Library is for open and login to the ASIR WebEM and do operations
    """

    """The Scope for the library imported in Robot Framework"""

    # The other 2 options is 'TEST CASE' and 'GLOBAL'
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

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

    def __init__(self, virtual_enable=False, ui_delay=1, ui_timeout=5, debug=False, wd=None):
        """
        Init function

        :param virtual_enable: True for Chrome is visible while False Chrome is invisible
        :param ui_delay: A delay time (in seconds) for WebEm UI, if feel the WebEM respond slow, can enlarge this value
        :param ui_delay: A timeout time (in seconds) waiting for WebEm UI response, if feel the WebEM respond slow,
            can enlarge this value
        :param debug: For debug purpose, that run the python file without robotframework

        Examples:
        Library    /home/ute/robotws/testsuite/Krakow/resources/asir/selenium/Dev_ASIR_Selenium.py
        virtual_enable=${FALSE}
        """

        self.ui_delay = ui_delay
        self.ui_timeout = ui_timeout
        self.virtual_enable = virtual_enable
        self.selenium_coam = None
        self.wd = wd
        self.debug = debug
        self.chrome_driver = r"/opt/ute/chromedriver/chromedriver"
        self.firefox_driver = r"/opt/ute/geckodriver"
        self.options = webdriver.ChromeOptions()
        self.firefox_options = webdriver.FirefoxOptions()
        self.options.add_argument('--ignore-certificate-errors')
        self.options.add_argument("--start-maximized")
        self.options.add_argument("--window-size=1920,1080")
        self.options.add_argument("--window-position=0,0")
        self.screenshot_dir = tempfile.mkdtemp(
            prefix='{}_screenshots_'.format(self.__class__.__name__))
        logger.info("Dev_ASIR_Selenium Init, virtual_enable is {}, screenshot dir {}"
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
        clean_browser function,  clean reamined webdriver and chrome process,
            usually used in Suite Setup
        :param browser: browser process partial name
        Examples:
        | clean_browser |
        """

        if self.wd:
            try:
                self.wd.quit()
            except Exception as e:
                logger.info("{}: {}".format(__name__, str(e)))
            self.wd = None
        if self.selenium_coam:
            self.selenium_coam = None
        if browser == 'chrome':
            logger.info("open browser to avoid welcome modal", also_console=True)
            subprocess.Popen("google-chrome")
            time.sleep(1)
        cmd = "ps -ef | grep -v 'grep' | grep {} | awk '{{print $2}}' | sudo xargs kill -9".format(
            browser)
        logger.info(cmd, also_console=True)
        os.system(cmd)
        time.sleep(20)

    @catch_exception
    def login(self, url='https://192.168.255.129:3601', user_name='Nemuadmin', user_password='nemuuser',
              online_mode=True, timeout=20, browser=None, browser_version='Chrome'):
        """
        login function,  usually used in Suite Setup

        :param url: URL of the ASIR WebEm
        :param user_name: user name
        :param user_password: user password
        :param online_mode: flag to indicate ASIR WebEM running with online or offline mode

        Examples:
        | login | url=https//192.168.255.129:3601 | user_name=Nemuadmin | user_password=nemuuser |
        | Suite Setup | Run Keywords | login | AND | enter_config_man | overwrite=$True |
        """
        logger.info("Dev_ASIR_Selenium login", also_console=True)
        _xpath_login_username = "//div[@id='usernameForm']//input"
        _xpath_login_password = "//div[@id='passwordForm']//input"
        _xpath_config_man_header = "//div[@id='commissioning-header']"

        xpath_legal_info = "//div[@class='modal-panel']//div[contains(text(), 'Legal information')]"
        xpath_accept_button = "//div[@id='legal-info-modal']//button[text()='Accept']"

        # below xpath used for handle exception
        xpath_read_only_btn = "//button[contains(text(), 'Read-only log in')]"
        xpath_session_exceed = "//div[@id='errorAuthLogin' and contains(text(), 'exceeded')]"

        logger.info("virtual_enable:{}".format(self.virtual_enable), also_console=True)

        if browser:
            self.wd = browser
        else:
            if self.debug:
                logger.info("debug Selenium adopted", also_console=True)
                if browser_version == "Chrome":
                    self.wd = webdriver.Chrome(
                        self.chrome_driver, chrome_options=self.options)
                elif browser_version == "Firefox":
                    self.wd = webdriver.Firefox(
                        self.firefox_driver, firefox_options=self.firefox_options)
                else:
                    raise Exception(f"Unsupported browser: '{browser_version}'. Supported browsers are: 'Chrome' and "
                                    f"'Firefox'")
            else:
                logger.info("taf Selenium adopted", also_console=True)
                if not self.selenium_coam:
                    self.selenium_coam = sbts()
                    if self.virtual_enable:
                        logger.info("enable_virtual_display", also_console=True)
                        self.selenium_coam.enable_virtual_display()
                    self.wd = self.selenium_coam._configure_before_login(browser_version, None,
                                                                         "/home/ute/Downloads", None)._driver
            self.wd.implicitly_wait(15)

        try:
            if self.wd.window_handles:
                self.wd.execute_script("window.open()")
                self.wd.switch_to_window(self.wd.window_handles[-1])
            self.wd.get(url)

        except Exception as Ex:
            logger.info("Retry wd.get operation after exception {0}".format(str(Ex)), also_console=True)
            self.clean_browser()
            time.sleep(20)
            self.wd.get(url)

        # add online_mode parameter to support offline mode ASIR WebEM tool
        if online_mode:
            logger.info("ASIR WebEM running with online mode!", also_console=True)
            wait = Wait(self.wd, timeout)
            time.sleep(3)

            self.wd.find_element(
                By.XPATH, _xpath_login_username).send_keys(user_name)
            self.wd.find_element(By.XPATH, _xpath_login_password).send_keys(
                user_password + '\n')

            time.sleep(self.ui_delay)
            read_buttons = self.wd.find_elements(By.XPATH, xpath_read_only_btn)
            read_button = read_buttons[0] if read_buttons else None
            if read_button:  # read only button
                read_button.click()
                logger.info("You will get ASIR webEM read only permission.", also_console=True)

            else:
                logger.info("You will get ASIR webEM read write permission.", also_console=True)

            try:
                wait.until(EC.visibility_of_element_located((By.XPATH, xpath_legal_info)))

            except Exception as Ex:

                max_session = self.wd.find_element(By.XPATH, xpath_session_exceed)
                if max_session:
                    raise Exception("Maximum number of sessions is exceeded.")

            accept_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_accept_button)))
            accept_button.click()
        else:
            logger.info("ASIR WebEM running with offline mode!", also_console=True)
            time.sleep(6)
            Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located(
                (By.XPATH, _xpath_config_man_header)))

    @catch_exception
    def asir_webem_login(self, browser=None, browser_version="Chrome"):
        for _ in range(5):
            try:
                self.login(browser=browser, browser_version=browser_version)
            except Exception as e:
                self.clean_browser()
                # browser = None
                MolerTest.sleep(10)
            else:
                return

    @catch_exception
    def logout(self, online_mode=True):
        """
        logout function, usually used in Suite Teardown
        :param online_mode: flag to indicate ASIR WebEM running with online or offline mode
        Examples:
        | logout |
        | Suite Teardown | logout |
        """
        logger.info("Dev_ASIR_Selenium logout", also_console=True)
        if online_mode:
            self.wd.find_element(By.XPATH, "//*[@id='user-information']").click()
            try:
                Wait(self.wd, 5).until(EC.element_to_be_clickable((By.XPATH, "//*[@id='log_out']"))).click()
            except Exception as e:
                logger.info("Failed to logout", also_console=True)
        self.wd.quit()
        if self.virtual_enable and self.selenium_coam:
            self.selenium_coam.disable_virtual_display()
        self.selenium_coam = None
        time.sleep(35)

    @catch_exception
    def enter_config_man(self, sub_menu="Edit", overwrite=True, timeout=60, returned_time_cost={}):
        """
        enter_config_man keyword, enter configuration manager page after login, usually used in Suite Setup
        :param overwrite: True for overwrite last modification, False for continue with last modification
        :param timeout: Maximum seconds for waiting for the configuration manangement page available
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None
        Examples:
        | enter_config_man |
        | Suite Setup | Run Keywords | login | AND | enter_config_man | overwrite=$True |
        """
        timeout = int(timeout)
        logger.info("Dev_ASIR_Selenium enter_config_man", also_console=True)
        dict_sub_menu_to_button_id = {
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
            'accounts': 'accountsStartButton'
        }
        start_button_id = dict_sub_menu_to_button_id.get(sub_menu.lower())
        assert (start_button_id is not None), "Failed to find start button id of '{}'".format(sub_menu)
        _xpath_config_man_button = "//*[@href='#/commissioning/cards']"
        _xpath_config_man_start_button = "//*[@id='{}']".format(start_button_id)
        _xpath_config_man_overwrite_button = "//div[@id='overwrite-modal']//button[text()='Overwrite']"
        _xpath_config_man_continue_button = "//*[@id='continueCurrentContinueButton']"
        _xpath_config_man_header = "//div[@id='commissioning-header']"
        _xpath_stepper_cancel_button = "//button[contains(@id,'cancel-button')]"
        _xpath_icon_backup_prepared = "//app-backup-prepared//mat-icon[@svgicon='doneIcon']"
        self.wd.find_element(By.XPATH, _xpath_config_man_button).click()

        if overwrite:
            config_man_start_button = \
                Wait(self.wd, self.ui_delay * 5).until(
                    EC.element_to_be_clickable((By.XPATH, _xpath_config_man_start_button)))
            config_man_start_button.click()

            try:
                Wait(self.wd, self.ui_delay * 5).until(
                    EC.invisibility_of_element_located((By.XPATH, _xpath_config_man_start_button)))
            except Exception as e:
                logger.warn("config management start button not appeared after clicked, retry once".format(str(e)))
                config_man_start_button = \
                    Wait(self.wd, self.ui_delay * 5).until(
                        EC.element_to_be_clickable((By.XPATH, _xpath_config_man_start_button)))
                config_man_start_button.click()

            try:
                overwrite_btn = Wait(self.wd, self.ui_delay).until(EC.element_to_be_clickable(
                    (By.XPATH, _xpath_config_man_overwrite_button)))
                overwrite_btn.click()
            except Exception as e:
                logger.info("overwrite button not clicked: {}".format(str(e)))

        else:
            self.wd.find_element(
                By.XPATH, _xpath_config_man_continue_button).click()

        dt_start = time.time()
        time.sleep(self.ui_delay)
        config_man_header_str = None
        while time.time() < dt_start + timeout:
            config_man_header = self.wd.find_elements(By.XPATH, _xpath_config_man_header)
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
            Wait(self.wd, timeout).until(EC.visibility_of_element_located(
                (By.XPATH, _xpath_icon_backup_prepared)))
        else:
            Wait(self.wd, timeout).until(EC.element_to_be_clickable(
                (By.XPATH, _xpath_stepper_cancel_button)))

        time_cost = round(time.time() - dt_start, 3)
        logger.info("enter_config_man time cost {}s".format(time_cost), also_console=True)
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
        wait_loading_visible = Wait(self.wd, 1)
        wait_loading_invisible = Wait(self.wd, 5)
        list_step_button_text = []
        list_step_button_active = []

        index_cur_active_tab = -1
        for i, step_button in enumerate(self.wd.find_elements(By.XPATH, _xpath_tabs)):
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
            Wait(self.wd, timeout).until(EC.element_to_be_clickable((By.XPATH, _xpath_button_to_click))).click()
            _xpath_active_tab = \
                "//div[@id='stepper-buttons']//button[contains(@id,'step-button') and contains(@class, 'active')]"
            cur_active_tab = \
                Wait(self.wd, timeout).until(EC.element_to_be_clickable((By.XPATH, _xpath_active_tab))).get_attribute(
                    'textContent').lower().strip()
            index_cur_active_tab = list_step_button_text.index(cur_active_tab)

        else:
            logger.info("tab '{}' is already active in all tabs {}".format(tab, list_step_button_text))
            if wait_after_switch:
                time.sleep(self.ui_delay * 3)

    @catch_exception
    def import_detected_configuration(self, mode):
        """
        import_detected_configuration keyword, click button 'Import Detected Configuration',
        and choose the import mode
        :param mode: complete or incremental
        Examples:
        | import_detected_configuration | mode=complete |
        | import_detected_configuration | mode=incremental |
        """
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
        self.wd.find_element(By.XPATH, xpath_import_detected_btn).click()
        self.wd.find_element(By.XPATH, xpath_select_mode).click()
        self.wd.find_element(By.XPATH, xpath_continue_btn).click()

    @switch_to_tab('Parameter editor')
    @catch_exception
    def prevalidate(self, timeout=120, returned_time_cost={}):
        """
        prevalidate keyword, switch to tab 'Parameter editor', click button 'Prevalidate' on tab 'Parameter editor',
        :param timeout: Maxium seconds for prevalidation
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None
        Examples:
        | ${dict_res_prevalidate} | prevalidate |
        :return dict_res_prevalidate: A dictionary of the prevalidate result
        """
        timeout = int(timeout)
        dict_ret = {}
        xpath_prevalidate_btn = "//button[@id='run-prevalidation-btn']"
        xpath_all_error_nav_a_with_errors = "//div[@id='parameter-editor-tabs']//a[contains(text(),'errors')]//div[" \
                                            "contains(@class,'error-value')]/.. "
        xpath_error_table_rows = "//div[@id='parameter-editor-tab-content']//app-errors-table/*/*/table/tbody/tr"

        wait = Wait(self.wd, timeout)
        try:
            prevalidate_btn = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_prevalidate_btn)))
            prevalidate_btn.click()
        except Exception as e:
            logger.info("try to click prevalidate button, due to exception {}".format(str(e)), also_console=True)
            prevalidate_btn = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_prevalidate_btn)))
            prevalidate_btn.click()

        dt_start = time.time()
        xpath_toast_prevalidate_result = "//div[@id='toast-container']//div[contains(text(),'Prevalidation finished')]"

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
        error_navs = self.wd.find_elements(
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
            error_rows = self.wd.find_elements(
                By.XPATH, xpath_error_table_rows)
            cur_severity = None
            cur_mo = None
            cur_affected_par = None
            cur_desc = None
            logger.info('error row cnt: {}'.format(
                len(error_rows)), also_console=True)
            for i, err_row in enumerate(error_rows):
                all_tds = err_row.find_elements(By.XPATH, ".//td")
                for td in all_tds:
                    # find the error
                    if 'mat-column-severity' in td.get_attribute('class').lower():
                        span_severities = td.find_elements(By.XPATH, ".//span")
                        if span_severities:
                            cur_severity = span_severities[0].text

                    # find the mo
                    elif 'mat-column-managed-object' in td.get_attribute('class').lower():
                        div_mo = td.find_elements(By.XPATH, './/div')
                        if div_mo:

                            mo_name = div_mo[0].text.strip()
                            if mo_name:
                                if mo_name != cur_mo:  # MO changed
                                    cur_mo = mo_name
                                    cur_affected_par = None
                                    cur_desc = None
                            if cur_mo and cur_mo not in dict_errs_in_nav:
                                dict_errs_in_nav[cur_mo] = {}
                    # find the affected parameters
                    elif 'mat-column-affected-parametersexpanded' in td.get_attribute('class').lower():
                        div_affected_par = td.find_elements(By.XPATH, './/div')
                        if div_affected_par:
                            affected_par = div_affected_par[0].text.strip()
                            if affected_par:
                                if affected_par not in dict_errs_in_nav[cur_mo]:
                                    dict_errs_in_nav[cur_mo][affected_par] = {}
                                dict_errs_in_nav[cur_mo][affected_par]['desc'] = cur_desc
                                dict_errs_in_nav[cur_mo][affected_par]['severity'] = cur_severity
                    # find the desc
                    elif 'mat-column-detailed-error-description' in td.get_attribute('class').lower():
                        if td.text.strip():
                            cur_desc = td.text.strip()

        pprint(dict_ret)
        return dict_ret

    @catch_exception
    def sync_config_with_gnb(self):
        logger.info("enter_config_man", also_console=True)
        self.enter_config_man()
        logger.info("switch_to_dedicated_tab", also_console=True)
        self.switch_to_dedicated_tab('Profiles')
        logger.info("import_detected_configuration", also_console=True)
        self.import_detected_configuration('complete')
        logger.info("switch_to_dedicated_tab", also_console=True)
        self.switch_to_dedicated_tab('Cells')

        self.import_detected_configuration('complete')
        self.switch_to_dedicated_tab('Cells')
        # find the cell list table
        time.sleep(self.ui_delay * 5)
        cell_list_table = self.wd.find_element_by_id('cell-list-table')
        cell_list_items = cell_list_table.find_elements_by_tag_name('tr')
        for cell_item in cell_list_items:
            cell_item.click()
            time.sleep(self.ui_delay * 3)
        self.switch_to_dedicated_tab('Parameter editor')
        self.import_detected_configuration('complete')
        self.switch_to_dedicated_tab('Activation')
        self.activate()
        return {'res': True}

    @catch_exception
    def sync_config_with_gnb_dss(self):
        """
        Note: Before 22R3 release, if you want to call sync_config_with_gnb_dss function, please refer to the this
              keyword. But from 22R3 release, please call sync_config_with_gnb function instead of
              sync_config_with_gnb_dss function.
        """
        _ASIRMGR_PARAMETER_HUBMOD_NODES = '//span[contains(@class,"node-name")][contains(text(),"HUBMOD-")]'
        _ASIRMGR_PARAMETER_BTS_NODES = '//span[contains(@class,"node-name")][contains(text(),"BTS-")]'
        _ASIRMGR_PARAMETER_BTS_ID_INPUT = '//tr[contains(@id,"btsId")]//input'
        dict_ret = {}
        logger.info("enter_config_man", also_console=True)
        self.enter_config_man()
        logger.info("switch_to_dedicated_tab", also_console=True)
        self.switch_to_dedicated_tab('Profiles')
        logger.info("import_detected_configuration", also_console=True)
        self.import_detected_configuration('complete')
        logger.info("switch_to_dedicated_tab", also_console=True)
        self.switch_to_dedicated_tab('Cells')
        self.import_detected_configuration('complete')
        self.switch_to_dedicated_tab('Cells')
        # find the cell list table
        time.sleep(self.ui_delay * 5)
        cell_list_table = self.wd.find_element_by_id('cell-list-table')
        cell_list_items = cell_list_table.find_elements_by_tag_name('tr')
        for cell_item in cell_list_items:
            cell_item.click()
            time.sleep(self.ui_delay * 3)
        self.switch_to_dedicated_tab('Parameter editor')
        self.import_detected_configuration('complete')

        hub_nodes = self.wd.find_elements_by_xpath(_ASIRMGR_PARAMETER_HUBMOD_NODES)
        bts_nodes = self.wd.find_elements_by_xpath(_ASIRMGR_PARAMETER_BTS_NODES)
        bts_ids = []
        for bts_node in bts_nodes:
            print(bts_node.text)
            bts_ids.append(bts_node.text.split('-')[-1])
        print('BTS IDs {}'.format(bts_ids))
        print('hub nodes number {}'.format(len(hub_nodes)))
        if len(bts_ids) > 1:
            for hub_node in hub_nodes:
                print('click on hub node')
                hub_node.click()
                time.sleep(self.ui_delay * 5)
                btsId_inputs = self.wd.find_elements_by_xpath(
                    _ASIRMGR_PARAMETER_BTS_ID_INPUT)
                print('btsId inputs number {}'.format(len(btsId_inputs)))
                if len(btsId_inputs) > 1:
                    for i, btsId_input in enumerate(btsId_inputs):
                        print('clear input {}'.format(i))
                        btsId_input.clear()
                        btsId_input.send_keys(bts_ids[i])
                        time.sleep(self.ui_delay)
        bts_nodes[0].click()
        self.wd.find_element_by_id('run-prevalidation-btn').click()
        time.sleep(self.ui_delay * 5)

        self.switch_to_dedicated_tab('Activation')
        self.activate()
        return {'res': True}

    def activate(self, as_full_configuration=None, timeout=180, returned_time_cost={}):
        """
        activate keyword, switch to tab 'Activation',
            toggle/untoggle the checkbox 'as_full_configuration', click button 'Activate'
        :param as_full_configuration: None for neglect the Full Configuration checkbox,
                                      True for activate as full configuration
                                      False for activate not as full configuration
        :param timeout: waiting timeout seconds for button or dialog apprearance
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None
        Examples:
        | activate |
        | activate | as_full_configuration=${True} |
        | ${dict_res} | activate | as_full_configuration=${False} |
        :return dict_res_prevalidate: A dictionary of the activation result
        """
        return self._activate_common(as_full_configuration, timeout, returned_time_cost)

    @switch_to_tab('Activation')
    @catch_exception
    def _activate_common(self, as_full_configuration=None, timeout=180, returned_time_cost={}):

        timeout = int(timeout)
        dict_ret = {}
        xpath_activate_btn = "//button[@id='run-activation-btn']"
        xpath_full_checkbox = "//input[@id='activate-as-full-checkbox-input']"
        xpath_full_checkbox_outer = "//mat-checkbox[@id='activate-as-full-checkbox']"
        xpath_validation_modal = "//div[@id='validation-config-error-modal']"
        xpath_validation_modal_close_btn = "{}//button[contains(text(),'Close')]".format(
            xpath_validation_modal)
        xpath_next_btn = "//button[@id='stepper-next-button']"
        xpath_finish_btn = "//button[@id='stepper-finish-button']"
        xpath_validating_label \
            = "//div[@class ='commissioning-stepper']//app-operation-progress[contains(@operationtitle, 'Validating')]"

        logger.info('Activate with Full Configuration {}'.format(
            as_full_configuration))
        # User activate regardless the mode
        if as_full_configuration is not None:
            # see if the mode checkbox is disabled or not
            checkbox_mode = self.wd.find_element(By.XPATH, xpath_full_checkbox)
            checkbox_mode_disabled = 'cdk-visually-hidden' in checkbox_mode.get_attribute(
                'class').split()  # mat-checkbox-input cdk-visually-hidden

            # if the checkbox is disabled, omit the specified mode
            if not checkbox_mode_disabled:
                logger.info('Activate Mode Checkbox is enabled')
                is_full_checked = checkbox_mode.get_attribute('value')
                if is_full_checked != str(as_full_configuration).lower():
                    logger.info('Change Activate Mode to {}'.format(
                        as_full_configuration))
                    self.wd.find_element(
                        By.XPATH, xpath_full_checkbox_outer).click()
                    is_full_checked = checkbox_mode.get_attribute(
                        'value')
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
        is_full_checked = self.wd.find_element(
            By.XPATH, xpath_full_checkbox).get_attribute('value')
        logger.info('Activate Mode on Checkbox is {}'.format(is_full_checked))
        dt_start = time.time()
        self.wd.find_element(By.XPATH, xpath_activate_btn).click()

        header_validating = None
        try:
            wait = Wait(self.wd, 5)
            header_validating = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_validating_label)))
            logger.info('Header of "Validating config" appeared', also_console=True)

        except TimeoutException:
            logger.info('Header of "Validating config" not appear', also_console=True)

        if header_validating:
            try:
                wait = Wait(self.wd, timeout)
                wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_validating_label)))
                logger.info('Header of "Validating config" disappeared', also_console=True)
            except TimeoutException:
                logger.info('Header of "Validating config" cannot disappear', also_console=True)

        returned_time_cost['time_cost_validation'] = time.time() - dt_start
        logger.info('validation time cost {:.03f}'
                    .format(returned_time_cost['time_cost_validation']), also_console=True)

        modal_validation = None
        try:
            wait = Wait(self.wd, 10)
            modal_validation = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_validation_modal)))
        except TimeoutException:
            logger.info('Validation ERR Modal not appear')

        if modal_validation is None:
            wait = Wait(self.wd, timeout)
            dict_ret['ret'] = True

            if is_full_checked == 'true':  # full need next and finish
                next_btn = wait.until(
                    EC.element_to_be_clickable((By.XPATH, xpath_next_btn)))
                next_btn.click()
            dt_start = time.time()
            finish_btn = None
            try:
                next_btn = wait.until(
                    EC.element_to_be_clickable((By.XPATH, xpath_next_btn)))
                next_btn.click()
            except Exception as e:
                pass
        #   below comment due to lack of Finish button
        #     try:
        #         finish_btn = wait.until(
        #             EC.element_to_be_clickable((By.XPATH, xpath_finish_btn)))
        #        finish_btn.click()
        #         returned_time_cost['time_cost_next_to_finish'] = time.time() - dt_start
        #     except Exception as e:
        #         screenshot_name = 'activate_finish_button_not_clickable.png'
        #         logger.warn('Finish button not clickable in {} seconds, screenshot:{}'.format(
        #             timeout, screenshot_name))
        #         raise e

        else:
            dict_ret['ret'] = False
            dict_ret['info'] = self.wd.find_element(
                By.XPATH, "{}//div[@class='content']".format(xpath_validation_modal)).text
            self.wd.find_element(
                By.XPATH, xpath_validation_modal_close_btn).click()

        return dict_ret

    def _find_element_and_match_stripped_text(self, xpath, text, attr='textContent',
                                              compare_method=lambda x, y: x.strip() == y.strip(), timeout=2):
        """
        _find_element_and_match_stripped_text function, using for find element that match attribute
        :param xpath: the xpath to locate the web element
        :param text: the text for accurate match with parameter 'attr'
        :param attr: the attribute for compare with parameter 'text'
        :param compare_method: lambda method for comparision
        :param timeout: waiting timeout seconds for web elements' apprearance
        Examples:
        hub_row = self._find_element_and_match_stripped_text(
            xpath_hub_row, 'HUBMOD-{}'.format(hub_mod_id), compare_method=lambda x, y: x.strip().endswith(y.strip()))
        :return: The web element object or None if not found
        """
        timeout = int(timeout)
        elems = None
        start_time = time.time()
        while not elems and time.time() < start_time + timeout:
            try:
                elems = self.wd.find_elements(By.XPATH, xpath)
                for elem in elems:
                    elem_info = elem.get_attribute(attr)
                    logger.info(elem_info)
                    if compare_method(elem_info, text):
                        return elem
            except StaleElementReferenceException as e:
                elems = None
                continue
        return None

    """
    Some xpath of web element for several keywords
    """
    _xpath_formatter_prrhs_hub_row = "//div[@id='antennas-list-table']//tbody//tr[contains(@id,'HUBMOD-{}')]"
    _xpath_formatter_ant_row = "//tr[@id='antport-{}']"
    _xpath_formatter_ant_checkbox_configure_outer = "{}//mat-checkbox[contains(@class,'configurePrrh')]"
    _xpath_formatter_ant_checkbox_configure \
        = _xpath_formatter_ant_checkbox_configure_outer + "//input[@type='checkbox']"

    @switch_to_tab('pRRHs')
    @catch_exception
    def add_prrh_to_hub(self, hub_mod_id, ant_port_id, prrh_type=None, prrh_label=None, chained_prrh_type=None,
                        chained_prrh_label=None, returned_time_cost={}):
        """
        add_prrh_to_hub keyword, switch to tab 'pRRHs', add a pRRH to a HUB,
            The input will remains no change if its parameter is None
            will fail if the ant_port_id already configured in the table
        :param hub_mod_id: HUB MOD ID
        :param ant_port_id: Antenna port number
        :param prrh_type: pRRH Module type, eg. AWHHC
        :param prrh_label: pRRH user label
        :param chained_prrh_type: chained pRRH Module type, eg. AHENA
        :param chained_prrh_label: chained pRRH user label
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None
        Examples:
        | add_prrh_to_hub | 1 | 5 | AWHHC | add prrh label 5 | AHGEDA | add chained prrh label 5 |
        """
        xpath_hub_row = self._xpath_formatter_prrhs_hub_row.format(hub_mod_id)
        xpath_ant_row = self._xpath_formatter_ant_row.format(ant_port_id)
        xpath_ant_checkbox_configure = self._xpath_formatter_ant_checkbox_configure.format(
            xpath_ant_row)

        hub_row = self._find_element_and_match_stripped_text(
            xpath_hub_row, 'HUBMOD-{}'.format(hub_mod_id), attr="id",
            compare_method=lambda x, y: y.strip() in x.split('/'))
        hub_row.click()
        time.sleep(self.ui_delay)

        checkbox_configure = self.wd.find_element(
            By.XPATH, xpath_ant_checkbox_configure)
        assert (checkbox_configure.get_attribute('value') ==
                'false'), 'Failed to add, Antport ID {} Already Exists'.format(ant_port_id)
        self.update_prrh_in_hub(hub_mod_id, ant_port_id, prrh_type,
                                prrh_label, chained_prrh_type, chained_prrh_label, returned_time_cost)

    @switch_to_tab('pRRHs')
    @catch_exception
    def modify_prrh_in_hub(self, hub_mod_id, ant_port_id, prrh_type=None, prrh_label=None, chained_prrh_type=None,
                           chained_prrh_label=None):
        """
        modify_prrh_in_hub keyword, switch to tab 'pRRHs', modify a pRRH in a HUB,
            The input will remains no change if its parameter is None
            will fail if the ant_port_id not configured in the table
        :param hub_mod_id: HUB MOD ID
        :param ant_port_id: Antenna port number
        :param prrh_type: pRRH Module type, eg. AWHHC
        :param prrh_label: pRRH user label
        :param chained_prrh_type: chained pRRH Module type, eg. AHENA
        :param chained_prrh_label: chained pRRH user label
        Examples:
        | modify_prrh_in_hub | 1 | 5 | AWHHC | modify prrh label 5 | AHGEDA | modify chained prrh label 5 |
        """
        xpath_hub_row = self._xpath_formatter_prrhs_hub_row.format(hub_mod_id)
        xpath_ant_row = self._xpath_formatter_ant_row.format(ant_port_id)
        xpath_ant_checkbox_configure = self._xpath_formatter_ant_checkbox_configure.format(
            xpath_ant_row)

        hub_row = self._find_element_and_match_stripped_text(
            xpath_hub_row, 'HUBMOD-{}'.format(hub_mod_id), attr="id",
            compare_method=lambda x, y: y.strip() in x.split('/'))
        hub_row.click()
        time.sleep(self.ui_delay)

        checkbox_configure = self.wd.find_element(
            By.XPATH, xpath_ant_checkbox_configure)
        assert (checkbox_configure.get_attribute('aria-checked') ==
                'true'), 'Failed to modify Antport ID {} does not Exist'.format(ant_port_id)
        self.update_prrh_in_hub(hub_mod_id, ant_port_id, prrh_type,
                                prrh_label, chained_prrh_type, chained_prrh_label)

    @switch_to_tab('pRRHs')
    @catch_exception
    def update_prrh_in_hub(self, hub_mod_id, ant_port_id, prrh_type=None, prrh_label=None, chained_prrh_type=None,
                           chained_prrh_label=None, returned_time_cost={}, wait_for_spinner=True):
        """
        update_prrh_in_hub keyword, switch to tab 'pRRHs',
            create (if not exists) or modify (if exists) a pRRH in a HUB,
            The input will remains no change if its parameter is None
        :param hub_mod_id: HUB MOD ID
        :param ant_port_id: Antenna port number
        :param prrh_type: pRRH Module type, eg. AWHHC
        :param prrh_label: pRRH user label
        :param chained_prrh_type: chained pRRH Module type, eg. AHENA
        :param chained_prrh_label: chained pRRH user label
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None
        Examples:
        | update_prrh_in_hub | 1 | 5 | AWHHC | modify prrh label 5 | AHGEDA | modify chained prrh label 5 |
        """
        xpath_hub_row = self._xpath_formatter_prrhs_hub_row.format(hub_mod_id)
        xpath_ant_row = self._xpath_formatter_ant_row.format(ant_port_id)
        xpath_ant_checkbox_configure = self._xpath_formatter_ant_checkbox_configure.format(
            xpath_ant_row)
        xpath_ant_checkbox_configure_outer = self._xpath_formatter_ant_checkbox_configure_outer.format(
            xpath_ant_row)

        xpath_rel_ant_prrh_type_selector = "{}//mat-select[contains(@class, 'module-type-1')]".format(
            xpath_ant_row)
        xpath_rel_ant_chained_prrh_type_selector = "{}//mat-select[contains(@class, 'module-type-2')]".format(
            xpath_ant_row)

        xpath_ant_prrh_type_selector_panel = "//div[contains(@id, 'mat-select')]"

        xpath_ant_prrh_type_option = "{}//mat-option//span[contains(text(),'{}')]".format(
            xpath_ant_prrh_type_selector_panel, prrh_type)
        xpath_ant_chained_prrh_type_option = "{}//mat-option//span[contains(text(),'{}')]".format(
            xpath_ant_prrh_type_selector_panel, chained_prrh_type)

        xpath_ant_prrh_user_label = "{}//input[contains(@class, 'user-label-1')]".format(
            xpath_ant_row)
        xpath_ant_chained_prrh_user_label = "{}//input[contains(@class, 'user-label-2')]".format(
            xpath_ant_row)

        time.sleep(self.ui_delay * 2)
        # hub_row = self._find_element_and_match_stripped_text(
        #     xpath_hub_row, 'HUBMOD-{}'.format(hub_mod_id), compare_method=lambda x, y: x.strip().endswith(y.strip()))
        hub_row = self._find_element_and_match_stripped_text(
            xpath_hub_row, 'HUBMOD-{}'.format(hub_mod_id), attr="id",
            compare_method=lambda x, y: y.strip() in x.split('/'))
        hub_row.click()

        wait = Wait(self.wd, 1)
        try:
            xpath_div_spinner_container = "//div[@class='spinner-container']"
            loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        except TimeoutException:
            loading_spinner = None
        if loading_spinner:
            wait = Wait(self.wd, 20)
            wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))

        time.sleep(self.ui_delay * 2)

        checkbox_configure = self.wd.find_element(
            By.XPATH, xpath_ant_checkbox_configure)

        if checkbox_configure.get_attribute('value') != 'true':
            Wait(self.wd, self.ui_timeout).until(EC.element_to_be_clickable(
                (By.XPATH, xpath_ant_checkbox_configure_outer)))
            self.wd.find_element(
                By.XPATH, xpath_ant_checkbox_configure_outer).click()
        else:
            logger.info("Ant port {} already exists, modify it".format(
                ant_port_id), also_console=True)
        time.sleep(self.ui_delay)
        if prrh_type:
            self.wd.find_element(
                By.XPATH, xpath_rel_ant_prrh_type_selector).click()

            rrh_type_option = self._find_element_and_match_stripped_text(
                xpath_ant_prrh_type_option, prrh_type)
            logger.info("try to scroll to view", also_console=True)
            self.wd.execute_script("arguments[0].scrollIntoView();", rrh_type_option)
            time.sleep(self.ui_delay)
            rrh_type_option = self._find_element_and_match_stripped_text(
                xpath_ant_prrh_type_option, prrh_type)
            try:
                rrh_type_option.click()
            except Exception as e:
                logger.info("try to scroll to view again due to exception {}".format(str(e)), also_console=True)
                self.wd.execute_script("arguments[0].scrollIntoView();", rrh_type_option)
                time.sleep(self.ui_delay)
                logger.info("try to scroll to view, click it again", also_console=True)
                rrh_type_option = self._find_element_and_match_stripped_text(
                    xpath_ant_prrh_type_option, prrh_type)
                self.wd.execute_script('arguments[0].click();', rrh_type_option)
            time.sleep(self.ui_delay)
        else:
            logger.info("Skip prrh_type, due to None")

        if prrh_label is not None:
            prrh_type_selector = self.wd.find_element(
                By.XPATH, xpath_rel_ant_prrh_type_selector)
            if prrh_type_selector.text.strip():
                elem_prrh_label = self.wd.find_element(
                    By.XPATH, xpath_ant_prrh_user_label)
                elem_prrh_label.click()
                elem_prrh_label.clear()
                if prrh_label:
                    elem_prrh_label.send_keys(prrh_label)
                    time.sleep(self.ui_delay)
            else:
                logger.warn(
                    "Can not input prrh_label, due to prrh type is empty")
        else:
            logger.info("Skip prrh_label, due to None")

        if chained_prrh_type:
            self.wd.find_element(
                By.XPATH, xpath_rel_ant_chained_prrh_type_selector).click()
            chained_rrh_type_option = self._find_element_and_match_stripped_text(
                xpath_ant_chained_prrh_type_option, chained_prrh_type)
            assert (chained_rrh_type_option is not None), 'chained_rrh_type_option is None'
            self.wd.execute_script("arguments[0].scrollIntoView();", chained_rrh_type_option)
            time.sleep(self.ui_delay)
            chained_rrh_type_option = self._find_element_and_match_stripped_text(
                xpath_ant_chained_prrh_type_option, chained_prrh_type)
            assert (chained_rrh_type_option is not None), 'chained_rrh_type_option is None after scroll'
            try:
                chained_rrh_type_option.click()
            except Exception as e:
                logger.info("try to scroll to view again due to exception {}".format(str(e)), also_console=True)
                self.wd.execute_script("arguments[0].scrollIntoView();", chained_rrh_type_option)
                logger.info("try to scroll to view, click it again", also_console=True)
                chained_rrh_type_option = self._find_element_and_match_stripped_text(
                    xpath_ant_chained_prrh_type_option, chained_prrh_type)
                time.sleep(self.ui_delay)
                chained_rrh_type_option.click()

            time.sleep(self.ui_delay)
        else:
            logger.info("Skip chained_prrh_type, due to None")

        if chained_prrh_type and chained_prrh_label is not None:
            chained_prrh_type_selector = self.wd.find_element(
                By.XPATH, xpath_rel_ant_chained_prrh_type_selector)
            if chained_prrh_type_selector.text.strip():
                elem_chained_prrh_label = self.wd.find_element(
                    By.XPATH, xpath_ant_chained_prrh_user_label)
                elem_chained_prrh_label.click()
                elem_chained_prrh_label.clear()
                if chained_prrh_label:
                    elem_chained_prrh_label.send_keys(chained_prrh_label)
            else:
                logger.warn(
                    "Can not input chained prrh_label, due to chained prrh type is empty")
        else:
            logger.info("Skip chained_prrh_label, due to None")

        dt_start = time.time()
        if wait_for_spinner:
            xpath_div_spinner_container = "//div[@class='spinner-container']"
            xpath_div_antennas_list_content = "//div[@id='antennas-list-content']"
            self.wd.find_element(
                By.XPATH, xpath_div_antennas_list_content).click()
            loading_spinner = None
            wait = Wait(self.wd, 1)
            try:
                loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            except TimeoutException:
                loading_spinner = None

            if loading_spinner is None:
                logger.info("No loading spinner appeared")
                returned_time_cost['time_cost'] = 0
                return
            wait = Wait(self.wd, 60)
            wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        returned_time_cost['time_cost'] = time.time() - dt_start

    @switch_to_tab('pRRHs')
    @catch_exception
    def delete_prrh_from_hub(self, hub_mod_id, ant_port_id, check_exists=False):
        """
        delete_prrh_from_hub keyword, switch to tab 'pRRHs', delete a pRRH from a HUB MOD
        :param hub_mod_id: HUB MOD ID
        :param ant_port_id: Antenna port number
        :param check_exists: if True, the keyword will firstly check if the ant_port_id already exists
        Examples:
        | delete_prrh_from_hub | 1 | 5 | check_exists=${FALSE} |
        """
        xpath_hub_row = self._xpath_formatter_prrhs_hub_row.format(hub_mod_id)
        xpath_ant_row = self._xpath_formatter_ant_row.format(ant_port_id)
        xpath_ant_checkbox_configure = self._xpath_formatter_ant_checkbox_configure.format(
            xpath_ant_row)
        xpath_ant_checkbox_configure_outer = self._xpath_formatter_ant_checkbox_configure_outer.format(
            xpath_ant_row)

        hub_row = self._find_element_and_match_stripped_text(
            xpath_hub_row, 'HUBMOD-{}'.format(hub_mod_id), attr="id",
            compare_method=lambda x, y: y.strip() in x.split('/'))
        hub_row.click()
        time.sleep(self.ui_delay)

        checkbox_configure = self.wd.find_element(
            By.XPATH, xpath_ant_checkbox_configure)

        if check_exists:
            assert (checkbox_configure.get_attribute('value') ==
                    'true'), 'Failed to delete, Antport ID {} does not Exist'.format(ant_port_id)

        if checkbox_configure.get_attribute('value') != 'false':
            Wait(self.wd, self.ui_timeout).until(
                EC.element_to_be_clickable((By.XPATH, xpath_ant_checkbox_configure_outer)))
            self.wd.find_element(
                By.XPATH, xpath_ant_checkbox_configure_outer).click()
        else:
            logger.info("Ant port {} already empty, do nothing".format(
                ant_port_id), also_console=True)

        assert (checkbox_configure.get_attribute('value') == 'false')

    @switch_to_tab('pRRHs')
    @catch_exception
    def bulk_edit_prrhs(self, hub_mod_id, ant_port_id_list, prrh_type=None, prrh_label=None, chained_prrh_type=None,
                        chained_prrh_label=None):
        """
        bulk_edit_prrhs keyword, switch to tab 'pRRHs', select several antenna ports and do bulk edit
            The input will remains no change if its parameter is None
        :param hub_mod_id: HUB MOD ID
        :param ant_port_id_list: A list of Antenna port numbers
        :param prrh_type: pRRH Module type, eg. AWHHC
        :param prrh_label: pRRH user label
        :param chained_prrh_type: chained pRRH Module type, eg. AHENA
        :param chained_prrh_label: chained pRRH user label
        Examples:
        ${ant_port_id_list}  create list  3  4  5
        bulk_edit_prrhs | hub_mod_id=1 | ant_port_id_list=${ant_port_id_list} | prrh_type=AWHHC
        | prrh_label=prrh label 345
        ... | chained_prrh_type=AHGEDA | chained_prrh_label=chained label 345
        """
        assert (ant_port_id_list), "No ant port id selected"
        assert (not (
                prrh_type is None and prrh_label is None
                and chained_prrh_type is None and chained_prrh_label is None)), \
            "No bulk edit items specified"

        xpath_formatter_ant_checkbox_bulkedit_outer = "{}//mat-checkbox[contains(@class,'bulkEdit')]"
        xpath_formatter_ant_checkbox_bulkedit = \
            xpath_formatter_ant_checkbox_bulkedit_outer + \
            "//input[@type='checkbox']"
        xpath_bulkedit_btn = "//button[@id='antennas-bulk-edit-button']"
        xpath_bulkedit_modal = "//div[@id='bulk-edit-modal']"

        xpath_hub_row = self._xpath_formatter_prrhs_hub_row.format(hub_mod_id)

        hub_row = self._find_element_and_match_stripped_text(
            xpath_hub_row, 'HUBMOD-{}'.format(hub_mod_id), attr="id",
            compare_method=lambda x, y: y.strip() in x.split('/'))
        hub_row.click()
        time.sleep(self.ui_delay)

        for ant_port_id in ant_port_id_list:
            xpath_ant_row = self._xpath_formatter_ant_row.format(ant_port_id)
            xpath_ant_checkbox_bulkedit = xpath_formatter_ant_checkbox_bulkedit.format(
                xpath_ant_row)
            xpath_ant_checkbox_bulkedit_outer = xpath_formatter_ant_checkbox_bulkedit_outer.format(
                xpath_ant_row)
            checkbox_bulkedit = self.wd.find_element(
                By.XPATH, xpath_ant_checkbox_bulkedit)
            if checkbox_bulkedit.get_attribute('value') != 'true':
                logger.info("Select Ant port {} for bulk edit".format(
                    ant_port_id), also_console=True)
                Wait(self.wd, self.ui_timeout).until(EC.element_to_be_clickable(
                    (By.XPATH, xpath_ant_checkbox_bulkedit_outer)))
                self.wd.find_element(
                    By.XPATH, xpath_ant_checkbox_bulkedit_outer).click()
            else:
                logger.info("Ant port {} bulk edit already selected, skip it".format(
                    ant_port_id), also_console=True)

        self.wd.find_element(By.XPATH, xpath_bulkedit_btn).click()

        tr_ids = ["prrh-module-type-group",
                  "prrh-user-label-group",
                  "chained-prrh-module-type-group",
                  "chained-prrh-user-label-group"]

        check_box_xpath_template = "//div[@id='bulk-edit-modal']//tr[@id='{}']//mat-checkbox"
        input_box_xpath_template = "//div[@id='bulk-edit-modal']//tr[@id='{}']//input[@type='string']"
        select_box_xpath_template = "//div[@id='bulk-edit-modal']//tr[@id='{}']//mat-select"
        dict_ctrl_getter = dict.fromkeys(tr_ids)

        for k in dict_ctrl_getter.keys():
            dict_ctrl_getter[k] = {
                "checkbox": partial(self.wd.find_element, By.XPATH, check_box_xpath_template.format(k)),
                "input": partial(self.wd.find_element, By.XPATH, input_box_xpath_template.format(k)),
                "select": partial(self.wd.find_element, By.XPATH, select_box_xpath_template.format(k)),
                "input_type": "input" if "label" in k else "select"
            }
        list_getters = list(dict_ctrl_getter.values())
        for i, val in enumerate([prrh_type, prrh_label, chained_prrh_type, chained_prrh_label]):
            if val is None:
                continue
            getters = list_getters[i]
            getters["checkbox"]().click()
            if getters["input_type"] == "input":
                getters[getters["input_type"]]().clear()
                if val:
                    getters[getters["input_type"]]().send_keys(val)

            elif getters["input_type"] == "select":  # select value
                self._select_value_in_mat_select(getters[getters["input_type"]], val,
                                                 lambda x, y: x.strip() == y)
            else:
                pass

        xpath_modal_apply_btn = "{}//button[text()='Apply']".format(
            xpath_bulkedit_modal)
        Wait(self.wd, self.ui_timeout).until(
            EC.element_to_be_clickable((By.XPATH, xpath_modal_apply_btn)))
        time.sleep(2)
        self.wd.find_element(By.XPATH, xpath_modal_apply_btn).click()

    _xpath_formatter_profiles_hub_row = "//div[@id='antenna-profile-list-content']//tr[contains(@id,'HUBMOD-{}')]"
    _xpath_profile_id_text = "//div[@id='antenna-profile-parameters']//div[contains(@class,'profileId')]//span[" \
                             "contains(@class,'text-value')] "

    def _edit_profile(self, profile_label=None, prrh_type=None, ant_port_list=[], returned_time_cost={}):
        """
        _edit_profile function, switch to tab 'Profiles', edit profile info
        :param profile_label: profile label
        :param prrh_type: pRRH Module type, eg. AWHHC
        :param ant_port_list: list of pRRH port-chain position
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None
        Examples:
        self._edit_profile(profile_label, prrh_type, ant_port_list)
        """
        prrh_type = prrh_type if prrh_type else ''
        xpath_input_user_label = "//input[contains(@class,'userLabel')]"
        xpath_module_type_selector = "//div[@id='antenna-profile-parameters']//mat-select"
        xpath_module_type_option = "//mat-option//span[contains(text(),'{}')]".format(prrh_type)
        xpath_all_tr_avail_prrh = "//app-antenna-profile-assignment//tbody/tr"

        input_user_label = self.wd.find_element(
            By.XPATH, xpath_input_user_label)
        if profile_label is not None:
            input_user_label.send_keys(Keys.CONTROL + 'a')
            input_user_label.send_keys(Keys.BACKSPACE)

            if profile_label:
                input_user_label.send_keys(profile_label)

        if prrh_type:
            self.wd.find_element(By.XPATH, xpath_module_type_selector).click()
            time.sleep(2)
            self.wd.find_element(By.XPATH, xpath_module_type_option).click()
            time.sleep(2)

        all_prrh_lines = self.wd.find_elements(
            By.XPATH, xpath_all_tr_avail_prrh)
        for prrh_line in all_prrh_lines:
            prrh_pos_text = prrh_line.find_element(
                By.XPATH,
                ".//td//div[contains(@class,'portChain')]//span[contains(text(),'{}')]".format(prrh_type)).text.strip()
            split_pos_text = prrh_pos_text.split()

            prrh_checkbox = prrh_line.find_element(
                By.XPATH, ".//td//input[@type='checkbox']")
            prrh_checkbox_outer = prrh_line.find_element(
                By.XPATH, ".//td//mat-checkbox[@type='checkbox']")
            prrh_checkbox_aria_checked = str(prrh_checkbox.is_selected()).lower()
            prrh_should_be_checked = str(
                split_pos_text[1] in ant_port_list).lower()
            if prrh_should_be_checked != prrh_checkbox_aria_checked:
                prrh_checkbox_outer.click()
            prrh_checkbox_aria_checked = str(prrh_checkbox.is_selected()).lower()
            assert (prrh_should_be_checked == prrh_checkbox_aria_checked), '{} Checked failed to be set {}'.format(
                split_pos_text, prrh_should_be_checked)

        dt_start = time.time()
        xpath_div_spinner_container = "//div[@class='spinner-container']"
        xpath_thead_antennas_profile_list = "//thead[@id='dynamic-table-head-panel']"
        self.wd.find_element(
            By.XPATH, xpath_thead_antennas_profile_list).click()
        loading_spinner = None
        wait = Wait(self.wd, 1)
        try:
            loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        except TimeoutException:
            loading_spinner = None

        if loading_spinner is None:
            logger.info("No loading spinner appeared")
            returned_time_cost['time_cost'] = 0
            return
        wait = Wait(self.wd, 60)
        wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        returned_time_cost['time_cost'] = time.time() - dt_start

    @switch_to_tab('Profiles')
    @catch_exception
    def create_profile(self, hub_mod_id, profile_label=None, prrh_type=None, ant_port_list=[], returned_time_cost={}):
        """
        create_profile keyword, switch to tab 'Profiles', create a profile
        :param hub_mod_id: HUB MOD ID
        :param profile_label: profile label
        :param prrh_type: pRRH Module type, eg. AWHHC
        :param ant_port_list: list of pRRH port-chain position
        Examples:
        | ${ant_port_list} | create list | 2-1 | 4-1 |
        | ${new_profile_id} | create_profile | 1 | new profile label | AWHHC | ${ant_port_list}
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: the new created profile id
        """
        xpath_create_profile_button = "//button[@id='add-profile-button']"

        xpath_hub_row = self._xpath_formatter_profiles_hub_row.format(
            hub_mod_id)

        hub_row = self._find_element_and_match_stripped_text(
            xpath_hub_row, 'HUBMOD-{}'.format(hub_mod_id), attr="id",
            compare_method=lambda x, y: y.strip() in x.split('/'))
        hub_row.click()
        wait = Wait(self.wd, self.ui_delay * 2)
        btn_create_profile = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_create_profile_button)))
        btn_create_profile.click()
        time.sleep(self.ui_delay)
        wait = Wait(self.wd, 1)
        try:
            xpath_div_spinner_container = "//div[@class='spinner-container']"
            loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        except TimeoutException:
            loading_spinner = None
        if loading_spinner:
            wait = Wait(self.wd, 10)
            wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        new_created_profile_id = self.wd.find_element(
            By.XPATH, self._xpath_profile_id_text).text.strip()
        logger.info('New profile {} created'.format(
            new_created_profile_id), also_console=True)
        self._edit_profile(profile_label, prrh_type, ant_port_list, returned_time_cost=returned_time_cost)
        return new_created_profile_id

    @switch_to_tab('Profiles')
    @catch_exception
    def modify_profile(self, profile_id, profile_label=None, prrh_type=None, ant_port_list=[]):
        """
        create_profile keyword, switch to tab 'Profiles', modify a profile
        :param profile_id: profile ID
        :param profile_label: profile label
        :param prrh_type: pRRH Module type, eg. AWHHC
        :param ant_port_list: list of pRRH port-chain position
        Examples:
        | ${ant_port_list} | create list | 3-1 | 5-1 |
        | modify_profile | ${g_new_profile_id} | modify profile label | AWHHC | ${ant_port_list}
        """
        profile_id = str(profile_id)
        xpath_table_profile_id = "//div[@id='antenna-profile-list-content']//tr//td//div[contains(@class," \
                                 "'profileId')]//span[contains(text(),'{}')]".format(profile_id)
        span_profile_id = self._find_element_and_match_stripped_text(
            xpath_table_profile_id, profile_id)
        span_profile_id.click()
        time.sleep(self.ui_delay)
        cur_profile_id = self.wd.find_element(
            By.XPATH, self._xpath_profile_id_text).text.strip()
        assert cur_profile_id == profile_id, \
            "profile id:[{}], current profile id:[{}]".format(profile_id, cur_profile_id)
        self._edit_profile(profile_label, prrh_type, ant_port_list)

    @switch_to_tab('Profiles')
    @catch_exception
    def delete_profile(self, profile_id, timeout=60, returned_time_cost={}):
        """
        delete_profile keyword, switch to tab 'Profiles', delete a profile
        :param profile_id: profile ID
        :param timeout: timeout for UI
        :param returned_time_cost: dictionary for carrying out the time cost
        Examples:
        | delete_profile | 1 |
        """
        wait = Wait(self.wd, timeout)
        profile_id = str(profile_id)
        xpath_delete_profile_button = "//button[@id='delete-selected-profile-button']"
        xpath_table_profile_id = "//div[@id='antenna-profile-list-content']//tr//td//div[contains(@class," \
                                 "'profileId')]//span[contains(text(),'{}')]".format(profile_id)
        xpath_delete_confirm_button = "//div[@id='delete-profile-modal']//button[text()='Delete']"
        xpath_div_spinner_container = "//div[@class='spinner-container']"
        wait.until_not(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        span_profile_id = self._find_element_and_match_stripped_text(
            xpath_table_profile_id, profile_id, timeout=timeout)

        span_profile_id.click()
        time.sleep(self.ui_delay)
        cur_profile_id = self.wd.find_element(By.XPATH, self._xpath_profile_id_text).text.strip()
        assert cur_profile_id == profile_id, \
            "profile id:[{}], current profile id:[{}]".format(profile_id, cur_profile_id)
        dt_start = time.time()
        delete_profile_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_delete_profile_button)))
        delete_profile_button.click()
        self.wd.find_element(By.XPATH, xpath_delete_confirm_button).click()
        wait.until_not(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        while time.time() < dt_start + timeout:
            span_profile_id = self._find_element_and_match_stripped_text(
                xpath_table_profile_id, profile_id, timeout=timeout)
            if span_profile_id is None:
                break
        assert (span_profile_id is None), 'failed to delete profile {}'.format(
            profile_id)
        returned_time_cost['time_cost'] = time.time() - dt_start
        logger.info('Profile {} deleted'.format(profile_id), also_console=True)

    @switch_to_tab('Cells')
    @catch_exception
    def auto_cell_mapping_info(self, bts_id, cell_id, timeout=60):
        timeout = int(timeout)
        xpath_cell_tr_in_cell_list_content \
            = "//div[@id='cells-list-content']//tr[contains(@id,'/BTS-{}/CELL-{}')]".format(bts_id, cell_id)
        Wait(self.wd, timeout).until(EC.element_to_be_clickable((By.XPATH,
                                                                 xpath_cell_tr_in_cell_list_content))).click()
        xpath_div_spinner_container = "//div[@class='spinner-container']"
        try:
            loading_spinner = Wait(self.wd, 1) \
                .until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        except Exception as e:
            loading_spinner = None
        if loading_spinner:
            Wait(self.wd, timeout) \
                .until_not(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))

    @switch_to_tab('Cells')
    @catch_exception
    def delete_cell_mapping_info(self, bts_id, cell_id, profile_id, band_class='(Clear)'):
        """
        delete_cell_mapping_info keyword, switch to tab 'Cells', delete a profile mapping
        :param bts_id: BTS ID
        :param cell_id: Cell ID
        :param profile_id: Profile ID
        Examples:
        | delete_cell_mapping_info | bts_id=1 | cell_id=1 | profile_id=2 |
        """
        return self.populate_cell_mapping_info(bts_id, cell_id, profile_id, band_class)

    @switch_to_tab('Cells')
    @catch_exception
    def populate_cell_mapping_info(self, bts_id, cell_id, profile_id, band_class, antl1=None, antl2=None,
                                   antl3=None, antl4=None, returned_time_cost={}, spinner_check=True):
        """
        populate_cell_mapping_info keyword, switch to tab 'Cells', delete a profile mapping
            Input remains unchanged if its parameter is None
        :param bts_id: BTS ID
        :param cell_id: Cell ID
        :param profile_id: Profile ID
        :prarm band_class: Module type (band class), eg. ARHHB or ARHHB (Band 41)
        :prarm antl1: select sHUB ANTL1
        :prarm antl2: select sHUB ANTL2
        :prarm antl3: select sHUB ANTL3
        :prarm antl4: select sHUB ANTL4
        :param returned_time_cost: dictionary for carrying out the time cost
        :param spinner_check: flag used to determine whether spinner container check is required or not
        :return: None
        Examples:
        | populate_cell_mapping_info | bts_id=1 | cell_id=1 | profile_id=2 | band_class=ARHHB
        ... | antl1=(Clear) | antl2=ANTL3 | antl3=ANTL2 | antl4=(Clear) |
        | populate_cell_mapping_info | bts_id=1 | cell_id=1 | profile_id=2 | band_class=ARHHB (Band 41)
        ... | antl1=(Clear) | antl2=ANTL3 | antl3=ANTL2 | antl4=(Clear) |
        """
        xpath_cell_tr_in_cell_list_content \
            = "//div[@id='cells-list-content']//tr[contains(@id,'/BTS-{}/CELL-{}')]".format(bts_id, cell_id)
        xpath_div_cell_mapping = "//div[@id='cell-details-mapping-content']"
        xpath_profile_tr_in_mapping_table = "{}//tbody//tr[contains(@id,'/ANTMODPR-{}')]" \
            .format(xpath_div_cell_mapping, profile_id)
        xpath_rel_mat_select_module_type = ".//mat-select[contains(@class,'profileBandClass')]"
        xpath_formatter_rel_mat_select_antl = ".//mat-select[contains(@class,'profileHubAntl-{}')]"

        try:
            self.wd.find_element(
                By.XPATH, xpath_cell_tr_in_cell_list_content).click()
        except Exception as e:
            logger.info('Failed to Click {}, exception {}'.format(xpath_cell_tr_in_cell_list_content, str(e)))
            time.sleep(self.ui_delay * 5)
            self.wd.find_element(
                By.XPATH, xpath_cell_tr_in_cell_list_content).click()
        # time.sleep(self.ui_delay * 2)
        Wait(self.wd, self.ui_delay * 5).until(EC.visibility_of_element_located
                                               ((By.XPATH, xpath_profile_tr_in_mapping_table)))
        tr_profile = self.wd.find_element(
            By.XPATH, xpath_profile_tr_in_mapping_table)

        mat_select_module_type = tr_profile.find_element(
            By.XPATH, xpath_rel_mat_select_module_type)

        # ARHHB (Band 41)
        # ARHHB
        # (Band 41)
        if len(band_class.split()) > 1 and not band_class.strip().startswith('('):
            def lambda_band_class_compare(x, y):
                return x.strip() == y
        else:
            def lambda_band_class_compare(x, y):
                return y in x.strip().split(' ', 1)

        self._select_value_in_mat_select(
            mat_select_module_type, band_class, lambda_band_class_compare)
        if band_class == '(Clear)' or band_class == '<No select>':
            logger.info('BTS-{}/CELL-{} Profile {} cleared'.format(bts_id,
                                                                   cell_id, profile_id), also_console=True)
        else:
            for i, antl in enumerate([antl1, antl2, antl3, antl4]):
                if antl:
                    antl_select = tr_profile.find_element(
                        By.XPATH, xpath_formatter_rel_mat_select_antl.format(i + 1))
                    self._select_value_in_mat_select(antl_select, antl, lambda x, y: x.strip() == y)
            logger.info("Populated cell mapping info BTS-{}/CELL-{} with profile {}"
                        .format(bts_id, cell_id, profile_id), also_console=True)

        if spinner_check:
            dt_start = time.time()
            xpath_div_spinner_container = "//div[@class='spinner-container']"
            xpath_div_antennas_profile_list_content = "//div[@id='cells-list-content']"
            self.wd.find_element(
                By.XPATH, xpath_div_antennas_profile_list_content).click()
            loading_spinner = None
            wait = Wait(self.wd, 1)
            try:
                loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            except TimeoutException:
                loading_spinner = None

            if loading_spinner is None:
                logger.info("No loading spinner appeared")
                returned_time_cost['time_cost'] = 0
                return
            wait = Wait(self.wd, 60)
            wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            returned_time_cost['time_cost'] = time.time() - dt_start

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
        input_search = self.wd.find_element(By.XPATH, xpath_search_par)

        for para in list_para:
            input_search.clear()
            input_search.send_keys(para['para_abbr'] + '\n')
            time.sleep(self.ui_delay * 2)  # flush previous result
            table_search_result = self.wd.find_element(
                By.XPATH, xpath_search_table)

            last_shown_mo_abbrs = []
            tm_start = time.time()
            while time.time() < tm_start + self.ui_timeout:
                if self.wd.find_elements(By.XPATH, xpath_search_table + "//tr"):
                    break
                time.sleep(self.ui_delay)
            else:
                raise Exception("No entry in search result")

            mo_td_found_in_search_result = None
            while not mo_td_found_in_search_result:
                cur_shown_mo_abbrs = []
                retry_times = 0  # retry for stale element occasionally
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
                                break  # found, jump out of for iteration
                            cur_shown_mo_abbrs.append(mo_td.text.strip())
                            last_mo_td = mo_td
                        else:
                            logger.info("cur_shown_mo_abbrs: {}".format(cur_shown_mo_abbrs))
                            logger.info("last_shown_mo_abbrs: {}".format(last_shown_mo_abbrs))
                            if cur_shown_mo_abbrs == last_shown_mo_abbrs:
                                raise Exception("No entry in search result after rolled")
                            last_shown_mo_abbrs = cur_shown_mo_abbrs
                            logger.info("Target MO not shown, need to scroll")
                            self.wd.execute_script("arguments[0].scrollIntoView();", last_mo_td)
                        break  # no exception, jump out of while retry_time iteration
                    except Exception as e:
                        logger.info("retry time {}: {}".format(retry_times, str(e)))
                        continue  # encouter exception, retry

            if not mo_td_found_in_search_result:
                raise Exception("No matched entry in search result")

            mo_td_found_in_search_result.click()
            time.sleep(self.ui_delay * 2)  # flush previous result
            table_para_edit = self.wd.find_element(By.XPATH, xpath_edit_table)

            # find the mo abbr match in edit table
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
            # find the edit field of the para
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
        Wait(self.wd, 5).until_not(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        dyn_elem().find_element(By.XPATH, './/..').click()
        time.sleep(self.ui_delay)
        all_mat_options = self.wd.find_elements(By.XPATH, "//mat-option")
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

    @switch_to_tab('pRRHs', wait_after_switch=False)
    @catch_exception
    def check_quantity_of_detected_prrhs(self, hub_mod_id, expected_quantity, greater_than_or_equal=True, timeout=10,
                                         returned_time_cost={}):
        """
        check_quantity_of_detected_prrhs keyword, switch to tab 'pRRHs', click a HUB,
        then check if the detected prrh match the expected quantity
        :param hub_mod_id: HUB MOD ID
        :param expected_quantity: detected prrh count
        :param greater_than_or_equal: compare method, if True means '>=', False means ==
        :param timeout: waiting timeout seconds for web elements' apprearance
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | check_quantity_of_detected_prrhs | 1 | 5 | 10 |
        """
        timeout = int(timeout)
        expected_quantity = int(expected_quantity)
        xpath_hub_row = self._xpath_formatter_prrhs_hub_row.format(hub_mod_id)

        hub_row = self._find_element_and_match_stripped_text(
            xpath_hub_row, 'HUBMOD-{}'.format(hub_mod_id), attr="id",
            compare_method=lambda x, y: y.strip() in x.split('/'))
        hub_row.click()

        xpath_prrh_mat_icon_detected = "//mat-icon[contains(@class,'detected-10')  and contains(@style,'okay-green')]"
        prrh_cnt = 0
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            detected_icons = self.wd.find_elements(By.XPATH, xpath_prrh_mat_icon_detected)
            if detected_icons:
                prrh_cnt = len(detected_icons)
                if greater_than_or_equal:
                    if prrh_cnt >= expected_quantity:
                        logger.info('HUBMOD-{} has {} prrh equals to expected quantity {}'
                                    .format(hub_mod_id, prrh_cnt, expected_quantity), also_console=True)
                        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
                        logger.info("check_quantity_of_detected_prrhs time cost {}s"
                                    .format(returned_time_cost['time_cost']), also_console=True)
                        return
                else:
                    if prrh_cnt == expected_quantity:
                        logger.info('HUBMOD-{} has {} prrh greater than or equal to expected quantity {}'
                                    .format(hub_mod_id, prrh_cnt, expected_quantity), also_console=True)
                        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
                        logger.info("check_quantity_of_detected_prrhs time cost {}s"
                                    .format(returned_time_cost['time_cost']), also_console=True)
                        return

            else:
                prrh_cnt = 0
        if greater_than_or_equal:
            assert (prrh_cnt >= expected_quantity), \
                'HUBMOD-{} has {} prrh not greater than or equal to expected quantity {}'.format(hub_mod_id, prrh_cnt,
                                                                                                 expected_quantity)
        else:
            assert (prrh_cnt == expected_quantity), \
                'HUBMOD-{} has {} prrh not equal to expected quantity {}'.format(hub_mod_id, prrh_cnt,
                                                                                 expected_quantity)

    @switch_to_tab('Cells', wait_after_switch=False)
    @catch_exception
    def check_quantity_of_detected_cells(self, bts_id, expected_quantity, greater_than_or_equal=True, timeout=10,
                                         returned_time_cost={}):
        """
        check_quantity_of_detected_cells keyword, switch to tab 'Cells', click a BTS,
        then check if the detected cells match the expected quantity
        :param bts_id: BTS ID
        :param expected_quantity: detected cells' count
        :param greater_than_or_equal: compare method, if True means '>=', False means ==
        :param timeout: waiting timeout seconds for web elements' apprearance
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | check_quantity_of_detected_cells | 1 | 5 | 10 |
        """
        timeout = int(timeout)
        expected_quantity = int(expected_quantity)
        xpath_cell_tr_in_cell_list_content \
            = "//div[@id='cells-list-content']//tr[contains(@id,'/BTS-{}/CELL-')]".format(bts_id)
        cell_cnt = 0
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            cell_rows = self.wd.find_elements(By.XPATH, xpath_cell_tr_in_cell_list_content)
            if cell_rows:
                cell_cnt = len(cell_rows)
                if greater_than_or_equal:
                    if cell_cnt >= expected_quantity:
                        logger.info('BTS-{} has {} cells greater than or equal to expected quantity {}'
                                    .format(bts_id, cell_cnt, expected_quantity), also_console=True)
                        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
                        logger.info("check_quantity_of_detected_cells time cost {}s"
                                    .format(returned_time_cost['time_cost']), also_console=True)
                        return
                else:
                    if cell_cnt == expected_quantity:
                        logger.info('BTS-{} has {} cells equals to expected quantity {}'
                                    .format(bts_id, cell_cnt, expected_quantity), also_console=True)
                        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
                        logger.info("check_quantity_of_detected_cells time cost {}s"
                                    .format(returned_time_cost['time_cost']), also_console=True)
                        return returned_time_cost['time_cost']

            else:
                cell_cnt = 0
        if greater_than_or_equal:
            assert (cell_cnt >= expected_quantity), \
                'BTS-{} has {} cells not greater than or equal to  expected quantity {}'.format(bts_id, cell_cnt,
                                                                                                expected_quantity)
        else:
            assert (cell_cnt == expected_quantity), \
                'BTS-{} has {} cells not equal to  expected quantity {}'.format(bts_id, cell_cnt, expected_quantity)

    @catch_exception
    def _check_time_needed_to_expand_ASI_object(self, expected_node_names=['PM-1', 'SECPRM-1', 'PMCADM-1'],
                                                timeout=20, returned_time_cost={}):
        """
        _check_time_needed_to_expand_ASI_object keyword,
        then check if the ASI tree node appeared in timeout
        :param expected_node_names: expected node nodes list, e.g. ['PM-1', 'SECPRM-1', 'PMCADM-1']
        :param timeout: waiting timeout for expand and display
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | ${expected_node_names} | create list | PM-1 | SECPRM-1 | PMCADM-1 |
        | _check_time_needed_to_expand_ASI_object | expected_expanded_items=${expected_expanded_items} |
        | ... timeout=20   |  returned_time_cost=${time_cost} |
        """
        timeout = int(timeout)
        wait = Wait(self.wd, timeout)
        xpath_asi_node = "//app-tree//div[starts-with(@id, 'ASI-') and not( contains(@id, '/'))]"
        xpath_asi_node_expand_button = "{}//mat-icon".format(xpath_asi_node)
        asi_node = self.wd.find_element(By.XPATH, xpath_asi_node)
        asi_node_expand_button = self.wd.find_element(By.XPATH, xpath_asi_node_expand_button)
        if asi_node_expand_button.get_attribute('svgicon') == 'expand':
            asi_node_expand_button.click()
        xpath_asi_node_expand_button += "[@svgicon='arrowRight']"
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_asi_node_expand_button))).click()
        xpath_node = "//app-tree//span[@class='node-name']"
        dt_start = time.time()

        while time.time() < dt_start + timeout and expected_node_names:
            retry_times = 0
            while True:
                try:
                    displayed_nodes = self.wd.find_elements(By.XPATH, xpath_node)
                    displayed_node_names = [node.get_attribute('textContent').strip() for node in displayed_nodes]
                    break
                except StaleElementReferenceException as e:
                    retry_times += 1
                    if retry_times > 3:
                        raise e

            expected_node_names = list(set(expected_node_names) - set(displayed_node_names))
            if expected_node_names:
                logger.info("{} still not found, scroll ...".format(expected_node_names))
                self.wd.execute_script("arguments[0].scrollIntoView();", displayed_nodes[-1])

        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
        logger.info("_check_time_needed_to_expand_ASI_object time cost {}s"
                    .format(returned_time_cost['time_cost']), also_console=True)

        commissioning_header_text = self.wd.find_element(By.XPATH, "//div[@id='commissioning-header']") \
            .get_attribute("textContent")
        if 'edit' in commissioning_header_text.lower():
            wait.until(EC.element_to_be_clickable((By.XPATH, "//button[@id='run-prevalidation-btn']")))

    @switch_to_tab('Parameter editor', wait_after_switch=False)
    def check_time_needed_to_expand_ASI_object_in_param_editor(self,
                                                               expected_node_names=['PM-1', 'SECPRM-1', 'PMCADM-1'],
                                                               timeout=20, returned_time_cost={}):
        """
        check_time_needed_to_expand_ASI_object_in_param_editor keyword, switch to tab 'Parameter editor',
        then check if the ASI tree node appeared in timeout
        :param expected_node_names: expected node nodes list, e.g. ['PM-1', 'SECPRM-1', 'PMCADM-1']
        :param timeout: waiting timeout for expand and display
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | ${expected_node_names} | create list | PM-1 | SECPRM-1 | PMCADM-1 |
        | check_time_needed_to_expand_ASI_object_in_param_editor | expected_expanded_items=${expected_expanded_items} |
        | ... timeout=20   |  returned_time_cost=${time_cost} |
        """
        self._check_time_needed_to_expand_ASI_object(expected_node_names, timeout, returned_time_cost)

    @catch_exception
    def _check_time_needed_to_expand_object(self, mo_path, expected_expanded_items=None, timeout=20,
                                            returned_time_cost={}):

        """
        _check_time_needed_to_expand_object
        then check if the ASI tree node appeared in timeout
        :param mo_path: MO path to expand
        :param expected_expanded_items: list of expected items displayed after expanded
        :param timeout: waiting timeout seconds for expand and display
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None
        """
        timeout = int(timeout)
        wait = Wait(self.wd, timeout)
        xpath_asi_node = "//app-tree//div[starts-with(@id, 'ASI-') and not( contains(@id, '/'))]"
        xpath_asi_node_expand_button = "{}//mat-icon".format(xpath_asi_node)
        asi_node = self.wd.find_element(By.XPATH, xpath_asi_node)
        asi_node_name = asi_node.get_attribute('id')
        asi_node_expand_button = self.wd.find_element(By.XPATH, xpath_asi_node_expand_button)
        if asi_node_expand_button.get_attribute('svgicon') == 'expand':
            asi_node_expand_button.click()
        xpath_asi_node_expand_button += "[@svgicon='arrowRight']"
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_asi_node_expand_button))).click()

        node_path_list = mo_path.split('/')
        first_node_name = node_path_list[0]
        xpath_node = "//app-tree//span[@class='node-name']"
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            retry_times = 0
            while True:
                try:
                    displayed_nodes = self.wd.find_elements(By.XPATH, xpath_node)
                    displayed_node_names = [node.get_attribute('textContent').strip() for node in displayed_nodes]
                    if first_node_name not in displayed_node_names:
                        logger.info("{} still not found, scroll ...".format(first_node_name))
                        self.wd.execute_script("arguments[0].scrollIntoView();", displayed_nodes[-1])
                    else:
                        self.wd.execute_script("arguments[0].scrollIntoView();",
                                               displayed_nodes[displayed_node_names.index(first_node_name)])
                    break
                except StaleElementReferenceException as e:
                    retry_times += 1
                    if retry_times > 3:
                        raise e

        node_path_list = mo_path.split('/')
        logger.info("node_path_list : {}".format(node_path_list))
        mo_name = node_path_list[-1]
        logger.info("mo_name : {}".format(mo_name))
        node_path = asi_node_name
        while node_path_list:
            node_path = "{}/{}".format(node_path, node_path_list.pop(0))
            logger.info("Try to find node {}".format(node_path))
            node = self.wd.find_element(By.XPATH, "//div[@id='{}']".format(node_path))
            if node_path_list:
                node.find_element(By.XPATH, ".//mat-icon[@svgicon='arrowRight']").click()

        node_expand_btn = node.find_element(By.XPATH, ".//mat-icon[@svgicon='arrowRight']")
        assert node_expand_btn is not None, '{} can not expand'.format(mo_path)

        dt_start = time.time()
        node_expand_btn.click()
        wait = Wait(self.wd, 1)
        while time.time() < dt_start + timeout and expected_expanded_items:
            for expected_item in expected_expanded_items:
                xpath_expected_item = "//div[@id='{}/{}']".format(node_path, expected_item)
                try:
                    wait.until(EC.visibility_of_element_located((By.XPATH, xpath_expected_item)))
                    expected_expanded_items.remove(expected_item)
                except TimeoutException as e:
                    continue
        else:
            assert len(expected_expanded_items) == 0, \
                'Can not see expected items {} after {}s'.format(expected_expanded_items, timeout)

        wait = Wait(self.wd, timeout)
        xpath_selected_mo = "//span[@id='selected-mo-class' and text()='{}']".format(mo_name)
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_selected_mo)))

        xpath_selected_mo = "//div[@id='details-header-title']//span[text()='{}']".format(mo_name)
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_selected_mo)))

        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
        logger.info("_check_time_needed_to_expand_object time cost {}s"
                    .format(returned_time_cost['time_cost']), also_console=True)

    @switch_to_tab('Parameter editor', wait_after_switch=False)
    def check_time_needed_to_expand_ANTMOD_object_in_param_editor(
            self, ant_mod_id, expected_expanded_items=['ANTETHPORT-1', 'ANTRFSM-1'], timeout=20,
            returned_time_cost={}):
        """
        check_time_needed_to_expand_ANTMOD_object_in_param_editor keyword,
        check time needed to expand ANTMOD object in parameter editor
        :param ant_mod_id: ANTMOD ID
        :param expected_expanded_items: list of expected items displayed after expanded
        :param timeout: waiting timeout for expand and display
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | ${expected_expanded_items} | create list | ANTETHPORT-1 | ANTRFSM-1 |
        | check_time_needed_to_expand_ANTMOD_object_in_param_editor | ant_mod_id=1 |
        | ...   expected_expanded_items=${expected_expanded_items} |  returned_time_cost=${time_cost} |
        """
        mo_path = "ANTMOD-{}".format(ant_mod_id)
        return self._check_time_needed_to_expand_object(mo_path, expected_expanded_items, timeout, returned_time_cost)

    @switch_to_tab('Parameter editor', wait_after_switch=False)
    def check_time_needed_to_expand_HUBMOD_object_in_param_editor(
            self, hub_mod_id, expected_expanded_items=['ANTPORT-1', 'SFPPORT-1'], timeout=20, returned_time_cost={}):
        """
        check_time_needed_to_expand_HUBMOD_object_in_param_editor keyword,
        check time needed to expand HUBMOD object in parameter editor
        :param hub_mod_id: HUBMOD ID
        :param expected_expanded_items: list of expected items displayed after expanded
        :param timeout: waiting timeout for expand and display
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | ${expected_expanded_items} | create list | ANTPORT-1 | SFPPORT-1 |
        | check_time_needed_to_expand_HUBMOD_object_in_param_editor | hub_mod_id=1 |
        | ...   expected_expanded_items=${expected_expanded_items} |  returned_time_cost=${time_cost} |
        """
        mo_path = "HUBMOD-{}".format(hub_mod_id)
        return self._check_time_needed_to_expand_object(mo_path, expected_expanded_items, timeout, returned_time_cost)

    @switch_to_tab('Parameter editor', wait_after_switch=False)
    def check_time_needed_to_expand_CELL_object_in_param_editor(
            self, bts_id, cell_id, expected_expanded_items=['CHANNELGROUP-1'], timeout=20, returned_time_cost={}):
        """
        check_time_needed_to_expand_CELL_object_in_param_editor keyword,
        check time needed to expand cell object in parameter editor
        :param bts_id: BTS id
        :param cell_id: Cell id
        :param expected_expanded_items: list of expected items displayed after expanded
        :param timeout: waiting timeout for expand and display
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | ${expected_expanded_items} | create list | CHANNELGROUP-1 |
        | check_time_needed_to_expand_CELL_object_in_param_editor | bts_id=1 | cell_id=1 |
        | ...   expected_expanded_items=${expected_expanded_items} |  returned_time_cost=${time_cost} |
        """

        mo_path = "BTS-{}/CELL-{}".format(bts_id, cell_id)
        logger.info("mo_path: {}".format(mo_path))
        return self._check_time_needed_to_expand_object(mo_path, expected_expanded_items, timeout, returned_time_cost)

    @switch_to_tab('Parameter editor', wait_after_switch=False)
    @catch_exception
    def check_time_needed_to_modify_specific_parameter_in_param_editor(self, mo_path, para_abbr, para_value,
                                                                       timeout=10, returned_time_cost={}):
        """
        check_time_needed_to_modify_specific_parameter_in_param_editor keyword,
        check time needed to modify a specific paramter in parameter editor
        :param mo_path: MO path of the parameter
        :param para_abbr: abbr of the parameter
        :param para_value: parameter value
        :param timeout: waiting timeout for modification
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | check_time_needed_to_modify_specific_parameter_in_param_editor | mo_path=ANTMOD-144 |
        | ...  para_abbr=antModPrId | para_value=2 | timeout=10 | returned_time_cost=${time_cost} |
        """
        timeout = int(timeout)
        wait = Wait(self.wd, timeout)

        xpath_asi_node = "//app-tree//div[starts-with(@id, 'ASI-') and not( contains(@id, '/'))]"
        xpath_asi_node_expand_button = "{}//mat-icon".format(xpath_asi_node)
        asi_node_expand = self.wd.find_element(By.XPATH, xpath_asi_node)
        asi_node_name = asi_node_expand.get_attribute('id')
        asi_node_expand_button = self.wd.find_element(By.XPATH, xpath_asi_node_expand_button)
        if asi_node_expand_button.get_attribute('svgicon') == 'arrowRight':
            asi_node_expand_button.click()
        xpath_asi_node_expand_button += "[@svgicon='expand']"
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_asi_node_expand_button)))

        node_path_list = mo_path.split('/') if mo_path else []
        if not node_path_list or node_path_list[0] != asi_node_name:
            node_path_list.insert(0, asi_node_name)

        if len(node_path_list) > 1:
            first_node_name = node_path_list[1]
            xpath_node = "//app-tree//span[@class='node-name']"
            dt_start = time.time()
            while time.time() < dt_start + timeout:
                retry_times = 0
                while True:
                    try:
                        displayed_nodes = self.wd.find_elements(By.XPATH, xpath_node)
                        displayed_node_names = [node.get_attribute('textContent').strip() for node in displayed_nodes]
                        break
                    except StaleElementReferenceException as e:
                        retry_times += 1
                        if retry_times > 3:
                            raise e
                if first_node_name not in displayed_node_names:
                    logger.info("{} still not found, scroll ...".format(first_node_name))
                    self.wd.execute_script("arguments[0].scrollIntoView();", displayed_nodes[-1])
                else:
                    self.wd.execute_script("arguments[0].scrollIntoView();",
                                           displayed_nodes[displayed_node_names.index(first_node_name)])

        xpath_mo_div = "//div[@id='{}']"
        for level, node_name in enumerate(node_path_list):
            if level == 0 and len(node_path_list) > 1:
                continue
            mo_div_id = '/'.join(node_path_list[0:level + 1])
            mo_xpath = xpath_mo_div.format(mo_div_id)
            mo_node = wait.until(EC.element_to_be_clickable((By.XPATH, mo_xpath)))
            if level == len(node_path_list) - 1:  # reach the final mo
                logger.info('Reach mo {}, click to edit parameter'.format(mo_div_id), also_console=True)
                mo_node.click()
            else:
                logger.info('Find mo {}, continue to expand'.format(mo_div_id), also_console=True)
                expand_btn = mo_node.find_elements(By.XPATH, ".//mat-icon")
                assert (len(expand_btn) > 0), " no expand button on {} ".format(mo_div_id)
                expand_btn = expand_btn[0]
                expand_btn_svg_icon = expand_btn.get_attribute('svgicon')
                if expand_btn_svg_icon == 'arrowRight':
                    expand_btn.click()
                else:
                    logger.info('mo {} already expanded'.format(mo_div_id), also_console=True)

        wait_loading = Wait(self.wd, 1)
        xpath_div_loading_spinner_overlay = "//app-parameters-view//div[@class='loading-spinner-overlay']"
        div_loading_spinner_overlay = None
        try:
            div_loading_spinner_overlay = \
                wait_loading.until(EC.visibility_of_element_located((By.XPATH, xpath_div_loading_spinner_overlay)))
            logger.info('div_loading_spinner_overlay appeared', also_console=True)
        except TimeoutException:
            logger.info('no div_loading_spinner_overlay', also_console=True)
        if div_loading_spinner_overlay:
            wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_loading_spinner_overlay)))
            logger.info('div_loading_spinner_overlay disappeared', also_console=True)

        xpath_para_edit_field = \
            "//app-parameters-view//tbody//tr[@id='{}']//*[contains(@class,'parameterValue')]".format(para_abbr)
        try:
            para_edit_field = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_para_edit_field)))
            edit_tag_name = para_edit_field.tag_name
            logger.info('Found edit field type of {}'.format(para_edit_field.tag_name), also_console=True)
        except Exception as e:
            time.sleep(1)
            logger.error('Retry get tag name due to Exception:{}'.format(str(e)))
            para_edit_field = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_para_edit_field)))
            edit_tag_name = para_edit_field.tag_name
            logger.info('Found edit field type of {}'.format(para_edit_field.tag_name), also_console=True)
        dt_start = time.time()

        if edit_tag_name == 'mat-select':
            try:
                self._select_value_in_mat_select(para_edit_field, para_value, lambda x, y: x.strip() == y.strip())
            except Exception as e:
                logger.error('Retry select due to Exception:{}'.format(str(e)), also_console=True)
                para_edit_field = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_para_edit_field)))
                self._select_value_in_mat_select(para_edit_field, para_value, lambda x, y: x.strip() == y.strip())
        else:

            try:
                assert ('true' != para_edit_field.get_attribute(
                    'disabled')), "Text parameter value is disabled"
                para_edit_field.clear()
            except Exception as e:
                logger.error('Retry clear due to Exception:{}'.format(str(e)), also_console=True)
                para_edit_field.clear()
            try:
                para_edit_field.send_keys(para_value)
            except Exception as e:
                logger.error('Retry send_keys due to Exception:{}'.format(str(e)), also_console=True)
                para_edit_field.send_keys(para_value)

        logger.info('Click the edit area header to leave the focus', also_console=True)
        xpath_mo_header = "//span[@id='selected-mo-class' and text()='{}']".format(node_path_list[-1])
        mo_header = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_mo_header)))
        mo_header.click()
        xpath_mat_icon_edited = \
            "//app-parameters-view//tbody//tr[@id='{}']//*[contains(@class,'parameterValue')]//ancestor::td//mat-icon"\
            .format(para_abbr)
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_mat_icon_edited)))
        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)

        if len(node_path_list) == 1 and para_abbr == 'asiId':  # ASI
            logger.info('asiID modification, need to check tree', also_console=True)
            xpath_asi_root_node = "//div[@id='ASI-{}']".format(para_value)
            wait.until(EC.visibility_of_element_located((By.XPATH, xpath_asi_root_node)))
            returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)

        logger.info("check_time_needed_to_modify_specific_parameter_in_param_editor time cost {}s"
                    .format(returned_time_cost['time_cost']), also_console=True)

    @catch_exception
    def check_time_needed_to_display_topology_view_upon_login(self, expected_diagram_count=2, timeout=30,
                                                              returned_time_cost={}):
        """
        check_time_needed_to_display_topology_view_upon_login keyword,
        :param expected_diagram_count: expected diagram count on topology view
        :param timeout: waiting timeout seconds for display
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | check_time_needed_to_display_topology_view_upon_login | expected_diagram_count=2 | timeout=60 |
        | ...  returned_time_cost=${time_cost} |
        """
        expected_diagram_count = int(expected_diagram_count)
        timeout = int(timeout)
        xpath_topo_view_header = "//span[@id='topology-title' and contains(text(),'Topology view')]"
        xpath_cables_svg = "//*[name()='svg' and @id='cablesSVG']"
        dt_start = time.time()
        wait = Wait(self.wd, timeout)
        topo_view_header = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_topo_view_header)))
        assert (topo_view_header is not None and xpath_cables_svg), \
            "Topology view is not visible after {}s".format(timeout)
        xpath_diagrams = "//div[@id='topologyContainer']//app-collapsible-group"
        diagrams = []
        while time.time() < dt_start + timeout:
            diagrams = self.wd.find_elements(By.XPATH, xpath_diagrams)
            if len(diagrams) >= expected_diagram_count:
                break
        logger.info('{} diagrams found'.format(len(diagrams)), also_console=True)
        assert len(diagrams) >= expected_diagram_count, "Diagrams count < {}".format(expected_diagram_count)
        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
        logger.info("check_time_needed_to_display_topology_view_upon_login time cost {}s"
                    .format(returned_time_cost['time_cost']),
                    also_console=True)

    @catch_exception
    def enter_topology_view(self, timeout=10):
        """
        enter_topology_view keyword, enter topology view page
        :param timeout: Maximum seconds for waiting for the topology view page page available
        Examples:
        | enter_topology_view |
        """
        timeout = int(timeout)
        logger.info("Dev_ASIR_Selenium enter_topology_view", also_console=True)
        _xpath_topology_button = "//*[@href='#/topology']"
        _xpath_topology_header = "//span[@id='topology-title']"
        topology_button = self.wd.find_element(By.XPATH, _xpath_topology_button)
        if 'selected' not in topology_button.get_attribute('class'):
            topology_button.click()
        else:
            logger.info('topology_button already selected', also_console=True)
        Wait(self.wd, timeout).until(EC.visibility_of_element_located(
            (By.XPATH, _xpath_topology_header)))

    @catch_exception
    def check_time_needed_to_expand_specific_group_in_topology_view(self, group_name, timeout=30,
                                                                    returned_time_cost={}):
        """
        check_time_needed_to_expand_specific_group_in_topology_view keyword,
        expand specific group in topology view and record the time cost
        :param group_name: group name that unit belongs to, e.g. sHUBs pRRHs
        :param timeout: waiting timeout seconds for expand
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        check_time_needed_to_expand_specific_group_in_topology_view('CELLs', timeout, returned_time_cost)
        """
        timeout = int(timeout)
        xpath_app_tab_cells = "//app-tabs[@id='topology-tabs']//a[contains(text(),'Cells')]"

        wait = Wait(self.wd, timeout)
        app_tab_cells = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_app_tab_cells)))
        app_tab_cells.click()

        xpath_group_header = \
            "//div[@class='topology-view-columns-container']//div[contains(@class,'group-header')]//" \
            "span[text()='{}']" .format(group_name)
        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class,'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(xpath_group_header)

        view_column = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_view_column)))

        xpath_span_units_total_number = "{}//span[contains(@class, 'units-total-number')]".format(xpath_view_column)
        span_units_total_number = self.wd.find_elements(By.XPATH, xpath_span_units_total_number)
        units_total_number = 0
        for span_unit in span_units_total_number:
            element_cnt = int(span_unit.get_attribute('textContent').split()[0])
            units_total_number += element_cnt
        logger.info('before expand, view column has {} elements'.format(units_total_number), also_console=True)
        app_unit_in_view_column = view_column.find_elements(By.XPATH, ".//app-unit")
        app_unit_cnt_before_expand = len(app_unit_in_view_column)
        logger.info('before expand, view column has {} app units'.format(app_unit_cnt_before_expand),
                    also_console=True)

        dt_start = time.time()
        expand_header_button = \
            view_column.find_element(
                By.XPATH, ".//mat-icon[@svgicon='expand' and contains(@class,'expand-header-icon')]")
        expand_header_button.click()

        app_unit_cnt_expected = units_total_number
        while time.time() < dt_start + timeout:
            app_unit_in_view_column = view_column.find_elements(By.XPATH, ".//app-unit")
            app_unit_cnt_after_expand = len(app_unit_in_view_column)
            if app_unit_cnt_after_expand >= app_unit_cnt_expected:
                logger.info('after expand, view column has {} app units'.format(app_unit_cnt_after_expand),
                            also_console=True)
                expand_header_button = view_column.find_element(
                    By.XPATH, ".//mat-icon[@svgicon='collapse' and contains(@class,'expand-header-icon')]")
                expand_header_button.click()
                returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
                logger.info(
                    "check_time_needed_to_expand_specific_group_in_topology_view time cost {}s"
                    .format(returned_time_cost['time_cost']), also_console=True)
                return

        logger.info('after expand, view column has {} app units'.format(app_unit_cnt_after_expand), also_console=True)
        assert app_unit_cnt_after_expand >= app_unit_cnt_expected, \
            "{} app units appeared after expand, while expects {}, cost {}s" \
            .format(app_unit_cnt_after_expand, app_unit_cnt_expected, timeout)

    def check_time_needed_to_expand_sHUBs_group_in_topology_view(self, timeout=30, returned_time_cost={}):
        """
        check_time_needed_to_expand_sHUBs_group_in_topology_view keyword,
        expand sHUBs group in topology view and record the time cost
        :param timeout: waiting timeout seconds for expand
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | check_time_needed_to_expand_sHUBs_group_in_topology_view | timeout=60 | returned_time_cost=${time_cost} |
        """
        return self.check_time_needed_to_expand_specific_group_in_topology_view('sHUBs', timeout, returned_time_cost)

    def check_time_needed_to_expand_pRRHs_group_in_topology_view(self, timeout=30, returned_time_cost={}):
        """
        check_time_needed_to_expand_pRRHs_group_in_topology_view keyword,
        expand pRRHs group in topology view and record the time cost
        :param timeout: waiting timeout seconds for expand
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | check_time_needed_to_expand_pRRHs_group_in_topology_view | timeout=60 | returned_time_cost=${time_cost} |
        """
        return self.check_time_needed_to_expand_specific_group_in_topology_view('pRRHs', timeout, returned_time_cost)

    def check_time_needed_to_expand_CELLs_group_in_topology_view(self, timeout=30, returned_time_cost={}):
        """
        check_time_needed_to_expand_CELLs_group_in_topology_view keyword,
        expand CELLs group in topology view and record the time cost
        :param timeout: waiting timeout seconds for expand
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | check_time_needed_to_expand_CELLs_group_in_topology_view | timeout=60 | returned_time_cost=${time_cost} |
        """
        return self.check_time_needed_to_expand_specific_group_in_topology_view('CELLs', timeout, returned_time_cost)

    @catch_exception
    def oper_unit(self, group_name, unit_id, operation, check_state_name, check_state_values, timeout=300,
                  returned_time_cost={}):
        """
        oper_unit keyword,
        operate an unit, with unit ID specified
        :param group_name: group name that unit belongs to, e.g. sHUBs pRRHs
        :param unit_id: unit id, it can be string or list
        :param operation: operation, 'block', 'unblock' or 'reset'
        :param timeout: waiting timeout seconds for operation done
        :param check_state_name: state name to check
        :param check_state_values: state value list to change
        :param returned_time_cost: dictionary for carrying out the time cost.
               for multi units, the data structure is as follows.
               returned_time_cost: {'time_cost_display': {'1': xxx, '2': xxx},
                                    'time_cost_refresh': {'1': xxx, '2': xxx},
                                    'time_cost_button_recovered': {'1': xxx, '2': xxx}}
               for single unit, the data structure is as follows.
               returned_time_cost: {'time_cost_display': xxx,
                                    'time_cost_refresh': xxx,
                                    'time_cost_button_recovered': xxx}
        :return: None

        Examples:
        oper_unit('sHUBs', hub_mod_id, 'reset', 'Hardware state', ['resetting','working'], timeout, returned_time_cost)

        """
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
        if not isinstance(check_state_values, list):
            check_state_values = [check_state_values]
        check_state_values = [x.lower() for x in check_state_values]
        unit_prefix = dict_group_to_unit_prefix[group_name]
        self.enter_topology_view()
        wait = Wait(self.wd, timeout)
        xpath_group_header = \
            "//div[@class='topology-view-columns-container']//div[contains(@class,'group-header')]//" \
            "span[text()='{}']" .format(group_name)
        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class,'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(xpath_group_header)
        view_column = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_view_column)))
        expand_header_button = view_column.find_element(By.XPATH, ".//mat-icon[contains(@class,'expand-header-icon')]")
        if 'expand' == expand_header_button.get_attribute('svgicon'):
            expand_header_button.click()

        time_cost_display_dict = {}

        def _click_dedicated_unit(unitid, check_state_name):
            xpath_app_unit = "{}//app-unit//div[contains(@class,'description-label') and contains(text(),'({}-{})')]" \
                .format(xpath_view_column, unit_prefix, unitid)
            print('xpath_app_unit: {}'.format(xpath_app_unit))
            app_unit = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_app_unit)))
            app_unit.click()

            xpath_span_paired_managed_object = XPATH_TEMPLATE_STATE_VALUE.format('paired managed object')
            print('xpath_app_unit: {}'.format(xpath_span_paired_managed_object))

            if not time_cost_display_dict.get(str(unitid)):
                time_cost_display_dict[str(unitid)] = []
            dt_start = time.time()
            while time.time() < dt_start + timeout:
                span_paired_managed_object = self.wd.find_elements(By.XPATH, xpath_span_paired_managed_object)
                if span_paired_managed_object \
                        and span_paired_managed_object[0].get_attribute('textContent').split('/')[-1] == '{}-{}' \
                        .format(unit_prefix, unitid):
                    break
            else:
                assert False, "Paired managed object '{}-{} not appear after {}s".format(unit_prefix, unitid, timeout)

            xpath_span_state_value = XPATH_TEMPLATE_STATE_VALUE.format(check_state_name)
            print('xpath_span_state_value: {}'.format(xpath_span_state_value))
            span_state_value = self.wd.find_element(By.XPATH, xpath_span_state_value)

            time_cost_display = round(time.time() - dt_start, 3)
            logger.info(
                "{}-{} time_cost_display: {}s".format(unit_prefix, unitid, time_cost_display), also_console=True)
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
                    self.wd.find_element(By.XPATH, xpath_span_state_value)
                    logger.info("{} has changed to {} ...".format(check_state_name, check_state_value),
                                also_console=True)
                    break
                except Exception as e:
                    empty_panels = self.wd.find_elements(By.XPATH, xpath_div_empty_panel)
                    if empty_panels:
                        topo_container = self.wd.find_element(By.XPATH, "//div[@id='topologyContainer']")
                        ActionChains(self.wd).move_to_element_with_offset(topo_container, 1,
                                                                          1).click().perform()
                        app_unit = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_app_unit)))
                        app_unit.click()
            else:
                assert False, "state {} not reached after {}s".format(check_state_value, timeout)
            time_cost_refresh_dict[str(unitid)][check_state_value] = round(time.time() - dt_start_dic.get(str(id)), 3)
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
                class_button_usm_oper = self.wd.find_element(By.XPATH, "//button[@id='usm-{}']"
                                                             .format(operation.lower())).get_attribute('class')
            except StaleElementReferenceException as e:
                logger.info("StaleElementReferenceException, Try again ...")
                class_button_usm_oper = self.wd.find_element(By.XPATH, "//button[@id='usm-{}']"
                                                             .format(operation.lower())).get_attribute('class')

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

    def block_ANTMOD(self, ant_mod_id, timeout=300, returned_time_cost={}):
        """
        block_ANTMOD keyword,
        block an ANTMOD, with ANTMOD ID specified
        :param ant_mod_id: ANTMOD ID to block
        :param timeout: waiting timeout seconds for ANTMOD blocked
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | block_ANTMOD  | ant_mod_id=144 | returned_time_cost=${time_cost} |
        | Should Be True | ${time_cost['time_cost']} <= ${10} |
        """
        self.oper_unit('pRRHs', ant_mod_id, 'block', 'Local state', 'blocked', timeout, returned_time_cost)

    def unblock_ANTMOD(self, ant_mod_id, timeout=300, returned_time_cost={}):
        """
        unblock_ANTMOD keyword,
        unblock an ANTMOD, with ANTMOD ID specified
        :param ant_mod_id: ANTMOD ID to unblock
        :param timeout: waiting timeout seconds for ANTMOD unblocked
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | unblock_ANTMOD  | ant_mod_id=144 | returned_time_cost=${time_cost} |
        | Should Be True | ${time_cost['time_cost']} <= ${10} |
        """
        self.oper_unit('pRRHs', ant_mod_id, 'unblock', 'Local state', ['unblocked'], timeout, returned_time_cost)

    def reset_HUBMOD(self, hub_mod_id, timeout=300, returned_time_cost={}):
        """
        reset_HUBMOD keyword,
        reset an HUBMOD, with HUBMOD ID specified
        :param hub_mod_id: HUBMOD ID to unblock
        :param timeout: waiting timeout seconds for HUBMOD reset
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | reset_HUBMOD  | ant_mod_id=144 | returned_time_cost=${time_cost} |
        | Should Be True | ${time_cost['time_cost']} <= ${10} |
        """
        self.oper_unit(
            'sHUBs', hub_mod_id, 'reset', 'Hardware state', ['resetting', 'working'], timeout, returned_time_cost)

    def reset_ANTMOD(self, ant_mod_id, timeout=300, returned_time_cost={}):
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
            'pRRHs', ant_mod_id, 'reset', 'Hardware state', ['resetting', 'working'], timeout, returned_time_cost)

    def check_time_needed_to_expand_ASI_object_in_view_configuration(
            self, expected_node_names=['PM-1', 'SECPRM-1', 'PMCADM-1'], timeout=20,
            running=False, returned_time_cost={}):
        """
        check_time_needed_to_expand_ASI_object_in_view_configuration keyword,
        then check if the ANTMOD tree node appeared in timeout
        :param expected_node_names: expected node after expand
        :param timeout: waiting timeout seconds for web elements' apprearance
        :param running: Check running status ASI-R_id
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${expected_node_names} | create list | PM-1 | SECPRM-1 | PMCADM-1 |
        | ${time_cost} | Create Dictionary |
        | check_time_needed_to_expand_ASI_object_in_view_configuration |
        | ...  expected_node_names=${expected_node_names} | returned_time_cost=${time_cost} |
        | Should Be True | ${time_cost['time_cost']} <= ${10} |
        """
        if running:
            # xpath_asi_node = "//app-tree//div[starts-with(@id, 'ASI-') and not( contains(@id, '/'))]"
            # asi_node = self.wd.find_element(By.XPATH, xpath_asi_node)
            # asi_node_name = asi_node.get_attribute('id')
            mo_path = "ASI_R-{}".format(1)
            return self._check_time_needed_to_expand_object(mo_path, expected_node_names, timeout,
                                                            returned_time_cost)
        else:
            return self._check_time_needed_to_expand_ASI_object(expected_node_names, timeout, returned_time_cost)

    def check_time_needed_to_expand_ANTMOD_object_in_view_configuration(
            self, ant_mod_id, expected_expanded_items=['ANTETHPORT-1', 'ANTRFSM-1'], timeout=20, running=False,
            returned_time_cost={}):
        """
        check_time_needed_to_expand_ANTMOD_object_in_view_configuration keyword,
        then check if the ANTMOD tree node appeared in timeout
        :param ant_mod_id: ANTMOD ID to expand
        :param expected_expanded_items: expected node after expand
        :param timeout: waiting timeout seconds for web elements' apprearance
        :param running: Check running status ANTMOD, for example: ANTMOD_R-1
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${expected_expanded_items_under_ant_mod} | create list | ANTRFSM-1 | ANTRFSM-2 |
        | ${time_cost} | Create Dictionary |
        | check_time_needed_to_expand_ANTMOD_object_in_view_configuration | ant_mod_id=144 |
        | ...  expected_expanded_items=${expected_expanded_items_under_ant_mod} | returned_time_cost=${time_cost} |
        | Should Be True | ${time_cost['time_cost']} <= ${10} |
        """
        if running:
            # xpath_asi_node = "//app-tree//div[starts-with(@id, 'ASI-') and not( contains(@id, '/'))]"
            # asi_node = self.wd.find_element(By.XPATH, xpath_asi_node)
            # asi_node_name = asi_node.get_attribute('id')
            mo_path = "ASI_R-{}/ANTMOD_R-{}".format(1, ant_mod_id)
        else:
            mo_path = "ANTMOD-{}".format(ant_mod_id)
        return self._check_time_needed_to_expand_object(mo_path, expected_expanded_items, timeout, returned_time_cost)

    @catch_exception
    def reset_configuration(self, timeout=60, returned_time_cost={}, clear_shub_password=False):
        """
        reset_configuration keyword,
        Reset Configuration
        :param timeout: Maximum seconds to waiting expected count
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | reset_configuration | timeout=60 | returned_time_cost=${time_cost} |
        """
        timeout = int(timeout)
        wait = Wait(self.wd, timeout)
        self.enter_config_man(sub_menu="Reset", timeout=timeout)
        xpath_continue_button = "//app-config-reset//button[@id='continue-button']"
        xpath_finish_button = "//app-config-reset//button[@id='finish-button']"
        xpath_checkbox_clear_shub_passwords = "//app-config-reset//input[contains(@id," \
                                              "'clear-passwords-checkbox-input')]"
        try:
            checkbox_clear_shub_password_btn = self.wd.find_element(By.XPATH, xpath_checkbox_clear_shub_passwords)
            if clear_shub_password is not False:
                logger.info("Start to click Clear ASiController storage of sHUB passwords", also_console=True)
                self.wd.execute_script("arguments[0].click();", checkbox_clear_shub_password_btn)
        except Exception as e:
            logger.error("No checkbox to be clicked")

        time.sleep(2)
        self.wd.find_element(By.XPATH, xpath_continue_button).click()
        logger.info("Continue button clicked", also_console=True)
        dt_start = time.time()
        xpath_div_success = \
            "//app-config-reset//div[contains(text(),'successfully reset') or contains(text(),'has been reset')]"
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_success)))
        self.wd.find_element(By.XPATH, xpath_finish_button).click()
        logger.info("Finish button clicked", also_console=True)
        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
        logger.info("reset_configuration time cost {}s".format(returned_time_cost['time_cost']), also_console=True)

    @catch_exception
    def check_unit_available(
            self, group_name, expected_total_count=0, expected_green_count=0,
            go_to_tab_cells=False, timeout=3600, returned_time_cost={}):
        """
        check_unit_available keyword,
        check unit available of a group on topology view, groups can be sHUBs, pRRHs, CELLs
        :param group_name: groups on topology view,  can be sHUBs, pRRHs, CELLs
        :param expected_total_count: expected total units count
        :param expected_green_count: expected green units count
        :param go_to_tab_cells: if need to go to tab "CELLs"
        :param timeout: Maxium seconds to waiting expected count
        :param returned_time_cost: dictionary for carrying out the time cost
        :return: None

        Examples:
        | ${time_cost} | Create Dictionary |
        | check_unit_available | group_name=pRRHs | expected_total_count=100 |
        | ...  expected_green_count=40 | go_to_tab_cells=${True} |
        """
        logger.info("check_unit_available group {}, expected green count {}, expected total count {}"
                    .format(group_name, expected_green_count, expected_total_count),
                    also_console=True)
        timeout = int(timeout)
        expected_green_count = int(expected_green_count)
        expected_total_count = int(expected_total_count)
        dt_start = time.time()
        self.enter_topology_view()
        wait = Wait(self.wd, timeout)
        if go_to_tab_cells or group_name.lower() == 'Cells'.lower():
            xpath_app_tab_cells = "//app-tabs[@id='topology-tabs']//a[contains(text(),'Cells')]"
            app_tab_cells = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_app_tab_cells)))
            app_tab_cells.click()

        xpath_group_header = \
            "//div[@class='topology-view-columns-container']//div[contains(@class,'group-header')]//span[text()=" \
            "'{}']" .format(group_name)
        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class,'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(xpath_group_header)
        view_column = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_view_column)))
        expand_header_button = view_column.find_element(By.XPATH, ".//mat-icon[contains(@class,'expand-header-icon')]")
        if 'expand' != expand_header_button.get_attribute('svgicon'):
            expand_header_button.click()

        xpath_span_units_total_number = "{}//span[contains(@class,'units-total-number')]".format(xpath_view_column)
        xpath_span_green_units_number = \
            "{}//div[contains(@mattooltip, 'in operational')]//span[contains(@class,'units-number')]" \
            .format(xpath_view_column)
        total_units_count = 0
        green_units_count = 0

        while time.time() < dt_start + timeout:
            time.sleep(1)
            total_units_count = 0
            green_units_count = 0
            span_units_number = self.wd.find_elements(By.XPATH, xpath_span_green_units_number)
            if span_units_number:
                green_units_count = int(span_units_number[0].get_attribute('textContent').strip())

            span_units_number = self.wd.find_elements(By.XPATH, xpath_span_units_total_number)
            if span_units_number:
                total_units_count = int(span_units_number[0].get_attribute('textContent').strip().split()[0])

            logger.info("green_units_count: {}  total_units_count: {}".format(green_units_count, total_units_count))
            if total_units_count >= expected_total_count and green_units_count >= expected_green_count:
                break

        assert (total_units_count >= expected_total_count and green_units_count >= expected_green_count), \
            "expected green count is {} total count is {}, while green count is {} total count is, after {}s" \
            .format(expected_green_count, expected_total_count, green_units_count, total_units_count, timeout)
        returned_time_cost['time_cost'] = round(time.time() - dt_start, 3)
        logger.info("check_unit_available time cost {}s".format(returned_time_cost['time_cost']), also_console=True)

    @catch_exception
    def save_scf(self, download_dir='/home/ute/Downloads', timeout=30):
        """
        keyword save_scf,
        save scf file to specified location
        :param download_dir: scf download location
        :param timeout: waiting timeout seconds for web elements' apprearance
        :return: saved scf path
        Examples:
        | ${backup_folder} | set variable | /home/ute/Downloads/ |
        | ${scf_backup} | save_scf | download_dir=${backup_folder} |
        """
        timeout = int(timeout)
        wait = Wait(self.wd, timeout)

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
                return list_scf_after_download[-1]
        assert False, 'Failed to save backup scf'

    @catch_exception
    def load_scf(self, scf_path, timeout=180, returned_time_cost={}, cancel=False):
        """
        keyword load_scf,
        Load scf file and activation
        :param scf_path: expected node after expand
        :param timeout: waiting timeout seconds for web elements' apprearance
        :param returned_time_cost: dictionary for carrying out the time cost
        :param cancel: cancels the load window
        :return: None

        Examples:
        | ${scf_path}  | set variable | /home/ute/Downloads/Configuration_111.xml |
        | ${time_cost} | Create Dictionary |
        | load_scf | scf_path=${scf_path} | returned_time_cost=${time_cost} |
        """
        logger.info(scf_path, also_console=True)
        timeout = int(timeout)
        wait = Wait(self.wd, timeout)
        self.enter_config_man(sub_menu="load file", timeout=timeout)
        xpath_select_file_button = "//app-upload-configuration//button[@id='file-select-button']"
        wait.until(EC.element_to_be_clickable((By.XPATH, xpath_select_file_button)))

        js = "arguments[0].removeAttribute(\"hidden\");"
        input_file = self.wd.find_element(By.XPATH, "//input[@id='file']")
        self.wd.execute_script(js, input_file)
        input_file.send_keys(scf_path)
        dt_start = time.time()
        xpath_next_btn = "//button[@id='stepper-next-button']"
        xpath_activate_button = "//button[@id='run-activation-btn']"
        wait = Wait(self.wd, 1)
        try:
            next_btn = Wait(self.wd, self.ui_delay * 5).until(EC.element_to_be_clickable((By.XPATH, xpath_next_btn)))
            if next_btn:
                next_btn.click()
        except Exception as e:
            logger.info("configuration migration is not required!", also_console=True)
        if cancel is True:
            try:
                xpath_cancel = "//button[@id='stepper-cancel-button']"
                xpath_cancel = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_cancel)))
                xpath_cancel.click()
            except Exception as e:
                logger.info("cancel click failed!", also_console=True)
        else:
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
            wait = Wait(self.wd, timeout)
            wait.until(EC.element_to_be_clickable((By.XPATH, xpath_activate_button)))
            returned_time_cost['time_cost_load_scf'] = time.time() - dt_start
            returned_time_cost_activate = {}
            ret_activate = self._activate_common(
                as_full_configuration=True, timeout=timeout, returned_time_cost=returned_time_cost_activate)
            assert ret_activate.get('ret') is True, ret_activate.get('info')
            returned_time_cost['returned_time_cost_activate'] = returned_time_cost_activate

    @catch_exception
    def get_asi_id(self):
        """
        keyword get_asi_id, get ASI ID
        :return: ASI ID
        Examples:
        | ${asi_id} | get_asi_id |
        """
        xpath_asi_node = "//app-tree//div[starts-with(@id, 'ASI-') and not( contains(@id, '/'))]"
        asi_node = self.wd.find_element(By.XPATH, xpath_asi_node)
        return asi_node.get_attribute('id').split('-')[-1]

    @catch_exception
    def get_faults_on_topology_view(self, timeout=120):
        """
        keyword get_faults_on_topology_view,
        Collect faults on topology view
        :param timeout: Maximum seconds for collecting faults
        :return: Dictionary of faults info
        Examples:
        | ${faults_begin} |  get_faults_on_topology_view |
        | sleep | 60s |
        | ${faults_end} |  get_faults_on_topology_view |
        | ${new_faults} | calc_new_faults | ${faults_begin} | ${faults_end} |
        """
        timeout = int(timeout)
        self.enter_topology_view()
        xpath_fault_row_head = "//app-faults-table//tr[contains(@class,'mat-header-row')]"
        xpath_fault_row = "//app-faults-table//tr[contains(@class,'mat-row')]"
        xpath_span_fault_time = "{}//th[contains(@class,'mat-column-Time')]//span[contains(@class,'n-icon')]" \
            .format(xpath_fault_row_head)
        wait = Wait(self.wd, timeout)
        order_by_time_icon = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_span_fault_time)))
        order_by_time_icon.click()

        order_by_time_icon = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_span_fault_time)))
        order_by_time_icon.click()
        fault_str_list = []

        dt_start = time.time()
        while time.time() < dt_start + timeout:
            last_fault_len = len(fault_str_list)
            retry_time = 0
            while True:
                try:
                    displayed_faults_rows = self.wd.find_elements(By.XPATH, xpath_fault_row)

                    for tr in displayed_faults_rows:
                        cur_fault = [td.get_attribute('textContent').strip()
                                     for td in tr.find_elements(By.XPATH, ".//td")]
                        cur_fault = '##'.join([cur_fault[0], cur_fault[2], cur_fault[3]])
                        if cur_fault not in fault_str_list:
                            fault_str_list.append(cur_fault)

                    else:
                        self.wd.execute_script("arguments[0].scrollIntoView();", displayed_faults_rows[-1])
                    break
                except StaleElementReferenceException as e:
                    retry_time += 1
                    if retry_time >= 3:
                        raise e

            if len(fault_str_list) == last_fault_len:
                break
            last_fault_len = len(fault_str_list)

        fault_list = [fault_str.split('##') for fault_str in fault_str_list]
        return {'fault_count': len(fault_list), 'fault_list': fault_list}

    def calc_new_faults(self, fault_info_before, fault_info_after):
        """
        keyword calc_new_faults,
        Compare 2 faults info, calculate the new faults
        :param fault_info_before: fault info before
        :param fault_info_after: fault info after
        :return: Dictionary of new faults info

        Examples:
        | ${faults_begin} |  get_faults_on_topology_view |
        | sleep | 60s |
        | ${faults_end} |  get_faults_on_topology_view |
        | ${new_faults} | calc_new_faults | ${faults_begin} | ${faults_end} |
        """
        fault_info_before_fault_str_list = ['##'.join(fault) for fault in fault_info_before['fault_list']]
        fault_info_after_fault_str_list = ['##'.join(fault) for fault in fault_info_after['fault_list']]
        fault_info_new_fault_str_list = \
            [fault_str for fault_str in fault_info_after_fault_str_list
             if fault_str not in fault_info_before_fault_str_list]
        fault_info_new_fault_list = [fault_str.split('##') for fault_str in fault_info_new_fault_str_list]
        return {'fault_count': len(fault_info_new_fault_list), 'fault_list': fault_info_new_fault_list}

    @switch_to_tab('pRRHs', wait_after_switch=False)
    @catch_exception
    def bulk_get_hubmod_prrh_info(self, hub_mod_id=None, timeout=10):
        """
        keyword bulk_get_hubmod_prrh_info, get all pRRH info of 1 HUBMOD or all HUBMOD
        :param hub_mod_id: HUBMOD ID, or None for All HUBMODs
        :param timeout: Maximum timeout seconds for UI operation
        :return: Dictionary of HUBMOD's pRRHs info

        Examples:
        | ${dict_all_prrhs_info} |  bulk_get_hubmod_prrh_info |
        | ${dict_all_prrhs_info} |  bulk_get_hubmod_prrh_info | hub_mod_id=1 |
        """
        timeout = int(timeout)
        xpath_prrhs_hub_row = "//div[@id='antennas-list-table']//tbody//tr[contains(@id,'HUBMOD')]"
        if hub_mod_id is not None:
            xpath_prrhs_hub_row = "//div[@id='antennas-list-table']//tbody//tr[ends-with(@id,'HUBMOD-{}')]" \
                .format(hub_mod_id)

        dict_hub_prrh_info = OrderedDict()
        list_hub_row = self.wd.find_elements(By.XPATH, xpath_prrhs_hub_row)
        for hub_row in list_hub_row:
            hub_mod_id = hub_row.find_element(By.XPATH, ".//div[contains(@class,'hubModDn')]//span") \
                .get_attribute('textContent').strip()
            hub_row.click()
            xpath_div_spinner_container = "//div[@class='spinner-container']"
            wait = Wait(self.wd, 1)
            try:
                loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            except TimeoutException:
                loading_spinner = None
            if loading_spinner:
                wait = Wait(self.wd, timeout)
                wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            xpath_ant_port_row = "//div[@id='antports-assignment']//tbody//tr"
            ant_port_rows = self.wd.find_elements(By.XPATH, xpath_ant_port_row)
            list_ant_port_info = []
            dict_useful_td_headers = {1: 'ant_port_id', 2: 'configure', 3: 'prrh_type', 4: 'prrh_label',
                                      6: 'chained_prrh_type', 7: 'chained_prrh_label'}
            for ant_port_row in ant_port_rows:
                ant_port_info = {}
                td_list = ant_port_row.find_elements(By.XPATH, ".//td")
                ant_port_configurePrrh = ant_port_row.find_element(By.XPATH,
                                                                   ".//mat-checkbox[contains(@class,'configurePrrh')]")
                antenna_port_id = ant_port_row.get_attribute('id').strip()
                if 'disabled' in ant_port_configurePrrh.get_attribute('class').strip():
                    logger.info("Antenna {0} in {1} is in disabled state"
                                .format(antenna_port_id, hub_mod_id), also_console=True)
                    continue
                for i, td in enumerate(td_list):
                    useful_k = dict_useful_td_headers.get(i)
                    if useful_k is None:
                        continue
                    elif useful_k == 'configure':
                        checkbox = td.find_element(By.XPATH, ".//input[@type='checkbox']")
                        ant_port_info[useful_k] = True
                        if checkbox.get_attribute('aria-checked') != 'true':
                            ant_port_info[useful_k] = False
                            break
                    elif useful_k == 'ant_port_id':
                        ant_port_info[useful_k] = td.get_attribute('textContent').strip()
                    elif 'prrh_type' in useful_k:
                        ant_port_info[useful_k] = td.get_attribute('textContent').strip()
                        if 'select' in ant_port_info[useful_k].lower():
                            ant_port_info[useful_k] = ''
                    elif 'prrh_label' in useful_k:
                        try:
                            ant_port_info[useful_k] = td.find_element(By.XPATH, ".//input").get_attribute('value') \
                                .strip()
                        except Exception as e:
                            logger.info("td.find_element exception: {}".format(str(e)))
                            time.sleep(1)
                            ant_port_info[useful_k] = td.find_element(By.XPATH, ".//input").get_attribute('value') \
                                .strip()
                    else:
                        pass
                list_ant_port_info.append(ant_port_info)
            dict_hub_prrh_info[hub_mod_id] = list_ant_port_info
        return dict_hub_prrh_info

    @switch_to_tab('Profiles')
    @catch_exception
    def bulk_get_profile_info(self, profile_id=None, timeout=10):
        """
        keyword bulk_get_profile_info, get 1 profile info or all profiles' info
        :param profile_id: Profile ID, or None for All Profiles
        :param timeout: Maximum timeout seconds for UI operation
        :return: Dictionary of profile inf

        Examples:
        | ${dict_all_profiles_info} |  bulk_get_profile_info |
        | ${dict_all_profiles_info} |  bulk_get_profile_info | profile_id=1 |
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
            "//input[@type='checkbox' and @aria-checked='true']//ancestor::tr"

        if profile_id:
            xpath_table_profile_id += "[normalize-space(text())='{}']".format(profile_id)

        list_span_profile_id = self.wd.find_elements(By.XPATH, xpath_table_profile_id)
        dict_profile_info = OrderedDict()
        for span_profile_id in list_span_profile_id:
            span_profile_id.click()
            wait = Wait(self.wd, 1)
            try:
                loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            except TimeoutException:
                loading_spinner = None
            if loading_spinner:
                wait = Wait(self.wd, timeout)
                wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            retry_times = 0
            while retry_times < 3:
                try:
                    profile_id = self.wd.find_element(By.XPATH, xpath_details_profile_id) \
                        .get_attribute('textContent').strip()
                    hubmod_dn = self.wd.find_element(By.XPATH, xpath_details_shub).get_attribute('textContent').strip()
                    user_label = self.wd.find_element(By.XPATH, xpath_details_user_label) \
                        .get_attribute('value').strip()
                    module_type = self.wd.find_element(By.XPATH, xpath_details_module_type) \
                        .get_attribute('textContent').strip().split()[0]
                    break
                except Exception as e:
                    logger.info("get profile parameters {}: {}".format(retry_times, str(e)), also_console=True)
                    retry_times += 1
                    if retry_times >= 3:
                        raise e
                    continue
            retry_times = 0
            while retry_times < 3:
                try:
                    assigned_prrh_rows = self.wd.find_elements(By.XPATH, xpath_assigned_prrh_row)
                    list_assigned_prrhs = []
                    for prrh_row in assigned_prrh_rows:
                        prrh_name = prrh_row.find_element(By.XPATH, ".//td[2]") \
                            .get_attribute("textContent").strip().split('/')[-1]
                        ant_port_id, slot = prrh_row.find_element(By.XPATH, ".//td[4]") \
                            .get_attribute("textContent").strip().split()[-1].split('-')
                        chained = slot == '2'
                        list_assigned_prrhs.append({'prrh': prrh_name, 'ant_port_id': ant_port_id, 'chained': chained})
                    break
                except Exception as e:
                    logger.info("get assigned ant port retry times {}: {}".format(retry_times, str(e)))
                    retry_times += 1
                    if retry_times >= 3:
                        raise e
                    continue

            dict_profile_info[profile_id] = {'hubmod': hubmod_dn, 'user_label': user_label, 'module_type': module_type,
                                             'assigned_prrhs': list_assigned_prrhs}

        return dict_profile_info

    @switch_to_tab('pRRHs')
    @catch_exception
    def batch_add_prrhs_to_hub(self, hub_mod_id, prrh_infos, returned_time_cost={}):
        """
        keyword batch_add_prrhs_to_hub to add several pRRH to specified HUBMOD ID
        :param hub_mod_id: HUBMOD ID
        :param prrh_infos: list of pRRH info
        :param returned_time_cost: dictionary of time cost for each pRRH adding
        :return: None

        Examples:
        | ${prrh_info_1} | Create Dictionary | ant_port_id=1 | prrh_type=AWHHC | prrh_label=label1 |
        ...  | chained_prrh_type=AWHHIQB | chained_prrh_label=chained label |
        | ${prrh_info_2} | Create Dictionary | ant_port_id=2 | prrh_type=AWHHC | prrh_label=label2 |
        ...  | chained_prrh_type=AWHHIQB | chained_prrh_label=chained label2 |
        | ${list_prrh_info} | Create List | ${prrh_info_1} | ${prrh_info_2} |
        | batch_add_prrhs_to_hub | hub_mod_id=1 | prrh_infos=${list_prrh_info} |
        """

        for prrh_info in prrh_infos:
            ant_port_id = prrh_info.get('ant_port_id')
            prrh_type = prrh_info.get('prrh_type')
            prrh_label = prrh_info.get('prrh_label')
            chained_prrh_type = prrh_info.get('chained_prrh_type')
            chained_prrh_label = prrh_info.get('chained_prrh_label')
            configured = prrh_info.get('configure', True)
            if configured:
                returned_time_cost[ant_port_id] = {}
                self.update_prrh_in_hub(hub_mod_id, ant_port_id, prrh_type, prrh_label,
                                        chained_prrh_type, chained_prrh_label, returned_time_cost[ant_port_id],
                                        wait_for_spinner=False)

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
        cell_tab_btn = Wait(self.wd, self.ui_delay * 2).until(
            EC.element_to_be_clickable((By.XPATH, xpath_cell_tab)))
        if cell_tab_btn:
            cell_tab_btn.click()

        mat_icon_btn = self.wd.find_element(By.XPATH, xpath_cell_mat_icon)
        if mat_icon_btn and mat_icon_btn.get_attribute('svgicon') == 'expand':
            mat_icon_btn.click()

        cell_item_list = self.wd.find_elements(By.XPATH, xpath_cell_label.format(xpath_cell_sub_tab))
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
            search_result = self.wd.find_element(By.XPATH, xpath_indicator_color.format(cell_item))
            if search_result:
                dict_cell_color[cell_item] = search_result.get_attribute('class').split()[2].split('-')[1]
        return dict_cell_color

    @catch_exception
    def _compare_status(self, check_list, status, timeout):
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
                    time.sleep(10)
                    break
                else:
                    check_success_counter += 1
            if check_success_counter == len(cell_status_dict):
                break

        return dict_check_result

    @catch_exception
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_asir_cell_status(self, cell_type, id_list=None, expected_status='Green', timeout=120):
        """
        keyword check_asir_cell_status
        Get ASIR cell status via selenium and check whether status is expected or not
        :param cell_type: cell type, BTS, RFC or ALL
        :param id_list: cell id list, format should be similar to 1.2  2.1  2.2
        :param expected_status: expected status with one value of Green/Yellow/Red
        :param timeout: waiting timeout seconds for check operation done

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
                tmp_list = id_list if isinstance(id_list, list) else str(id_list).split()
            check_cell_list = ['BTS' + item for item in tmp_list]

        elif cell_type.lower() == 'rfc':
            if id_list is None:
                tmp_list = rfc_cell_list
            else:
                tmp_list = id_list if isinstance(id_list, list) else str(id_list).split()
            check_cell_list = ['RFC-' + item for item in tmp_list]

        else:
            raise Exception("cell type {0} is not supported.".format(cell_type))

        assert check_cell_list, "To be checked asir cell list is empty."
        logger.info("To be checked asir cell list : {0}".format(check_cell_list))
        check_result = self._compare_status(check_list=check_cell_list,
                                            status=expected_status,
                                            timeout=timeout)

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
        logger.info("Dev_ASIR_Selenium check_rfc_type", also_console=True)
        xpath_cell_tab = "//app-tabs[@id='topology-tabs']//a[contains(text(),'Cells')]"
        xpath_rfc_label = "//div[contains(@class,'group-label')]//span[text()='RFCs']"
        xpath_rfc_mat_icon = "{0}//..//..//mat-icon"
        xpath_rfc_type = "//app-unit//div[contains(@class,'description-label') and contains(text(),'RFC-{0}')]"
        dict_check_result = {'check_result': True, 'check_details': {}}

        self.enter_topology_view()
        cell_tab_btn = Wait(self.wd, self.ui_delay * 2).until(
            EC.element_to_be_clickable((By.XPATH, xpath_cell_tab)))
        if cell_tab_btn:
            cell_tab_btn.click()

        rfc_mat_icon = self.wd.find_element(By.XPATH, xpath_rfc_mat_icon.format(xpath_rfc_label))
        if rfc_mat_icon and rfc_mat_icon.get_attribute('svgicon') == 'expand':
            rfc_mat_icon.click()

        try:
            rfc_elem = self.wd.find_element(By.XPATH, xpath_rfc_type.format(rfc_id))
            rfc_type = rfc_elem.text.split(' ')[0]
            logger.info("RFC-{0} type : {1}".format(rfc_id, rfc_type), also_console=True)

        except Exception as ex:
            if "no such element:" in ex.msg:
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
    def create_cell_manually(self, cell_type, type_id):
        """
        keyword create_cell_manually
        Create BTS or RFC cell under cells tab
        :param cell_type: cell type, BTS or RFC
        :param type_id: cell type identifier

        Example:
        | create cell manually | cell_type=BTS | type_id=1 |
        """
        logger.info("Dev_ASIR_Selenium create_cell_manually", also_console=True)
        xpath_create_cell_btn = "//app-wrapping-button[@id='create-cell-button']"
        xpath_cell_type_locator = "{0}//tr[contains(@id,'{1}-{2}') and not (contains(@id,'CELL'))]"
        xpath_generated_cell_finder = "{0}//tr[contains(@id,'{1}-{2}/') and contains(@class,'selected')]"

        ret_dict = {}
        cell_type_upper = cell_type.strip().upper()
        assert (cell_type_upper in ['BTS', 'RFC']), 'cell type {0} is not supported!'.format(cell_type)
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self._xpath_cell_list_table)))
        try:
            self.wd.find_element(By.XPATH, xpath_cell_type_locator.
                                 format(self._xpath_cell_list_locator, cell_type_upper, type_id)).click()
            time.sleep(1)

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to select {0}-{1} cell type, check its existence!"
                                .format(cell_type_upper, type_id))

        create_cell_btn = self.wd.find_element(By.XPATH, "{0}//div[contains(@class,'button')]".
                                               format(xpath_create_cell_btn))
        if create_cell_btn and 'disabled' not in create_cell_btn.get_attribute('class'):
            logger.info("Start to create {0} cell".format(cell_type_upper), also_console=True)
            self.wd.find_element(By.XPATH, xpath_create_cell_btn).click()
            time.sleep(3)

            cell_elem = self.wd.find_element(By.XPATH, xpath_generated_cell_finder.
                                             format(self._xpath_cell_list_locator, cell_type_upper, type_id))
            if cell_elem:
                cell_item = cell_elem.get_attribute('id').split('/')[-1]
                logger.info("{0} created under {1}-{2}".format(cell_item, cell_type_upper, type_id), also_console=True)
                if '-' and 'CELL' in cell_item:
                    ret_dict['cell_type'] = cell_type
                    ret_dict['id'] = cell_item.split('-')[-1]
                    ret_dict['attach_to'] = "{0}-{1}".format(cell_type, type_id)
                return ret_dict

        else:
            raise Exception("Failed to create CELL due to generated cell button is in disabled status!")

    @catch_exception
    @switch_to_tab('Cells')
    def populate_cell_details(self, cell_type, type_id, cell_id, para_dict):
        """
        keyword populate_cell_details
        modify/update cell parameter attribute/value under cells tab
        :param cell_type: cell type, BTS or RFC
        :param type_id: cell type identifier
        :param cell_id: cell identifier under specific cell type
        :param para_dict: dictionary of parameter:value pair

        Note : It is suggested to refer to below para_to_locator_dict "key" value when you require to
        update some parameters value. for example when you need to change 'cell technology', maybe the web page
        displag as 'Cell Technology' you'd better aligh with para_to_locator_dict and use 'Cell technology'
        since FE may often change some parameter name start with upper/lower letter.

        Example:
        ${para_dict}  Create Dictionary  Radio Access Technology=5G TDD
        ...                              IQ compression=no
        ...                              Frame Structure Type=tdLteConfig2_3ms
        ...                              Guard Period length=6Symbols
        ...                              Number of TX/RX=4T2R
        ...                              Timing Advance Offset=n39936
        | populate_cell_details | cell_type=RFC | type_id=1 | cell_id=2 | para_dict=${para_dict} |
        """
        logger.info("Dev_ASIR_Selenium populate_cell_details", also_console=True)
        xpath_cell_property = "//div[@id='cell-properties']"
        xpath_cell_locator = "{0}//tr[contains(@id,'{1}-{2}/{3}-{4}')]"
        xpath_para_common_locator = "{0}//*[contains(@class,'{1}')]"
        para_to_locator_dict = {
            'Cell technology': 'cellTechnology',
            'AirScale local cell identifier': 'LocalCellId',
            'AirScale cell identifier': 'airScaleCellId',
            'Double Tx power': 'doubleTxPower',
            'NB IOT mode': 'nbIoTMode',
            'Distributed DL-Mimo': 'distributedDlMimo',
            'Radio Access Technology': 'technology',
            'Frequency Band': 'band',
            'Downlink Bandwidth': 'dlBandwidth',
            'Downlink Center Frequency': 'dlCenterFreq',
            'Uplink Bandwidth': 'ulBandwidth',
            'Uplink Center Frequency': 'ulCenterFreq',
            'Maximum output power': 'pMax',
            'RF Switch TX Main': 'rfSwitchTxMain',
            'RF Switch TX Diversity': 'rfSwitchTxDiv',
            'Mode Selection': 'modeSelection',
            'IQ compression': 'iqCompression',
            'Frame Structure Type': 'frameStructureType',
            'Guard Period length': 'guardPeriodLength',
            'Number of TX/RX': 'numOfTxRx',
            'Timing Advance Offset': 'timingAdvanceOffset',
            'Position of the First Antenna Carrier Container': 'posAxC',
            'Position of Main Antenna Carrier Container': 'posAxCMain',
            'Position of Diversity Antenna Carrier Container': 'posAxCDiv'}

        cell_type_upper = cell_type.strip().upper()
        assert (cell_type_upper in ['BTS', 'RFC']), 'cell type {0} is not supported!'.format(cell_type)
        cell_str = 'CELL' if cell_type_upper == 'BTS' else 'RFCCELL'
        try:
            self.wd.find_element(By.XPATH, xpath_cell_locator.format(self._xpath_cell_list_locator,
                                                                     cell_type_upper,
                                                                     type_id,
                                                                     cell_str,
                                                                     cell_id)).click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate CELL : {0}-{1}/{2}-{3}, check its existence!"
                                .format(cell_type_upper, type_id, cell_str, cell_id))

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_cell_property)))
        for para_key in para_dict.keys():
            if 'radioaccess' in para_key.strip().lower().replace(' ', ''):
                logger.info("Update parameter {0} firstly.".format(para_key), also_console=True)
                time.sleep(2)
                rat_elem = self.wd.find_element(By.XPATH, xpath_para_common_locator.format(
                    xpath_cell_property, para_to_locator_dict.get(para_key)))
                if rat_elem and rat_elem.tag_name == 'mat-select':
                    logger.info("Update mat-select parameter {0} value to {1}".format(
                        para_key, para_dict.get(para_key)), also_console=True)
                    rat_elem = self.wd.find_element(By.XPATH, xpath_para_common_locator.format(
                        xpath_cell_property, para_to_locator_dict.get(para_key)))
                    self._select_value_in_mat_select(rat_elem,
                                                     para_dict.get(para_key),
                                                     lambda x, y: x.strip() == y.strip(),
                                                     check_required=False)
                    time.sleep(2)
                    break

        converted_dict_keys = [item.strip().lower().replace(' ', '') for item in para_to_locator_dict.keys()]
        for para, value in para_dict.items():
            para_str = para.strip().lower().replace(' ', '')
            if para_str not in converted_dict_keys:
                logger.info("parameter {0} is not exist to update!".format(para), also_console=True)
                continue

            if 'radioaccess' in para_str:
                logger.info("parameter {0} has already been updated!".format(para), also_console=True)
                continue

            time.sleep(3)
            para_elem = self.wd.find_element(By.XPATH, xpath_para_common_locator.format(
                xpath_cell_property, para_to_locator_dict.get(para)))
            if para_elem and para_elem.tag_name == 'mat-select':
                logger.info("Update mat-select parameter {0} value to {1}".format(para, value), also_console=True)
                self._select_value_in_mat_select(para_elem,
                                                 value,
                                                 lambda x, y: x.strip() == y.strip())

            elif para_elem and para_elem.tag_name == 'input' and value:
                logger.info("Update input parameter {0} value to {1}".format(para, value), also_console=True)
                para_elem.clear()
                para_elem.send_keys(value)

            elif para_elem and para_elem.tag_name == 'mat-checkbox':
                checkbox = para_elem.find_element(By.XPATH, ".//input[@type='checkbox']")
                if checkbox:
                    chbox_status = checkbox.get_attribute('aria-checked')
                    checked_status = 'yes' if chbox_status == 'true' else 'no'
                    if checked_status != value.strip().lower():
                        logger.info("Update checkbox parameter {0} value to {1}"
                                    .format(para, value), also_console=True)
                        para_elem.click()
                    else:
                        logger.info("checkbox parameter {0} is already in {1} status."
                                    .format(para, value), also_console=True)

            else:
                raise Exception("parameter with {0} tag name is unsupported.".format(para_elem.tag_name))

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
        logger.info("Dev_ASIR_Selenium delete_cell_manually", also_console=True)
        xpath_cell_locator = "{0}//tr[contains(@id,'{1}-{2}/{3}-{4}')]"
        xpath_warp_del_btn = "//app-wrapping-button[@id='delete-selected-cell-button']"
        xpath_warn_modal = "//div[@class='modal-panel']//div[@class='header-text' and contains(text(),'Delete')]"
        xpath_modal_del_btn = "//button[text()='Delete']"
        xpath_cell_finder = "{0}//tr[contains(@id,'{1}-{2}/')]"

        cell_type_upper = cell_type.strip().upper()
        assert (cell_type_upper in ['BTS', 'RFC']), 'cell type {0} is not supported!'.format(cell_type)
        cell_str = 'CELL' if cell_type_upper == 'BTS' else 'RFCCELL'
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self._xpath_cell_list_table)))

        def _cell_id_finder(xpath_locator):
            found_elements = self.wd.find_elements(By.XPATH, xpath_locator)
            ret_list = [item.get_attribute('id').split('/')[-1] for item in found_elements]
            return ret_list

        try:
            self.wd.find_element(By.XPATH, xpath_cell_locator.format(
                self._xpath_cell_list_locator, cell_type_upper, type_id, cell_str, cell_id)).click()
            time.sleep(1)

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate CELL : {0}-{1}/{2}-{3}, check its existence!"
                                .format(cell_type_upper, type_id, cell_str, cell_id))

        delete_cell_btn = self.wd.find_element(By.XPATH, "{0}//div[contains(@class,'button')]".
                                               format(xpath_warp_del_btn))
        if delete_cell_btn and 'disabled' not in delete_cell_btn.get_attribute('class'):
            logger.info("Start to delete {0} cell".format(cell_type_upper), also_console=True)
            self.wd.find_element(By.XPATH, xpath_warp_del_btn).click()

            Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_warn_modal)))
            Wait(self.wd, self.ui_delay * 3).until(EC.element_to_be_clickable((By.XPATH, xpath_modal_del_btn)))

            self.wd.find_element(By.XPATH, xpath_modal_del_btn).click()
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

        Example:
        ${chan_dict}  Create Dictionary  1=TXRX  2=TX  3=RX  4=TXRX
        |populate_radio_antenna_mapping | cell_type=bts | type_id=1 | cell_id=1 | hubmod_id=1 | chan_dict=${chan_dict}|
        """
        logger.info("Dev_ASIR_Selenium populate_radio_antenna_mapping", also_console=True)
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
            self.wd.find_element(By.XPATH, xpath_cell_locator.format(cell_type_upper,
                                                                     type_id,
                                                                     cell_str,
                                                                     cell_id)).click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate {0}-{1}/{2}-{3}, check its existence!"
                                .format(cell_type_upper, type_id, cell_str, cell_id))

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_antenna_header)))
        ante_hdr = self.wd.find_element(By.XPATH, "{0}//span".format(xpath_antenna_header))
        if ante_hdr and 'RFC' in ante_hdr.text.strip():
            logger.info("RFC Channel appear!", also_console=True)
        else:
            logger.info("HUB Antenna appear!", also_console=True)

        timeout = 30
        antenna_map_chan = None
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            try:
                antenna_map_chan = self.wd.find_element(By.XPATH, xpath_map_chan_locator.format(hubmod_id))
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
            logger.info("Successfully populate {0}-{1} Ant Channel map!".format(cell_str, cell_id), also_console=True)

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
        :param band_class: Module type(band class), eg. ARHHB or ARHHB (Band 41)
        :param chan_dict: dictionary of channel_id & channel_value pair

        Example:
        ${chan_dict}  Create Dictionary  1=ANTL1  2=ANTL2  3=ANTL3  4=ANTL4
        | populate_rfc_cell_mapping_info | cell_type=BTS | type_id=1 | cell_id=2 | profile_id=1
        ...                              | band_class=ARHQC (Band 78)| chan_dict=${chan_dict} |
        """
        logger.info("Dev_ASIR_Selenium populate_rfc_cell_mapping_info", also_console=True)
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
            self.wd.find_element(By.XPATH, xpath_cell_locator.format(cell_type_upper,
                                                                     type_id,
                                                                     cell_str,
                                                                     cell_id)).click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate {0}-{1}/{2}-{3}, check its existence!"
                                .format(cell_type_upper, type_id, cell_str, cell_id))

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_cell_mapping_hdr)))
        timeout = 30
        rfc_profile_chan = None
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            try:
                rfc_profile_chan = self.wd.find_element(By.XPATH, xpath_profile_mapping_locator.format(profile_id))
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
        logger.info("Dev_ASIR_Selenium create_rfc_by_import_file", also_console=True)
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

        import_rfc_button = Wait(self.wd, self.ui_delay * 5).until(
            EC.element_to_be_clickable((By.XPATH, xpath_import_rfc_button)))
        if import_rfc_button:
            self.wd.find_element(By.XPATH, xpath_input_file_label).send_keys(rfc_config_file)

        time.sleep(3)
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_rfc_details)))
        try:
            rfc_elem = self.wd.find_element(By.XPATH, xpath_created_rfc_locator.format(self._xpath_rfc_list))
            if rfc_elem:
                rfc_item = rfc_elem.get_attribute('id').split('/')[-1]
                logger.info("{0} created by import RFC file {1}".format(rfc_item, file_name), also_console=True)
                if '-' in rfc_item and rfc_item.startswith('RFC'):
                    ret_dict['type'] = rfc_item.split('-')[0]
                    ret_dict['id'] = rfc_item.split('-')[-1]
                return ret_dict

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Failed to import RFC file {0}".format(file_name))

    @catch_exception
    @switch_to_tab('RFCs')
    def create_rfc_manually(self):
        """
        keyword create_rfc_manually
        Create RFC manually under RFCs tab

        Example:
        | create_rfc_manually |
        """
        logger.info("Dev_ASIR_Selenium create_rfc_manually", also_console=True)
        xpath_create_rfc_btn = "//button[@id='create-rfc-manually-button']"
        xpath_created_rfc_locator = "{0}//tr[contains(@id,'RFC-') and contains(@class,'selected')]"

        ret_dict = {}
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, self._xpath_rfc_list)))
        create_rfc_btn = self.wd.find_element(By.XPATH, xpath_create_rfc_btn)
        if create_rfc_btn and 'disabled' not in create_rfc_btn.get_attribute('class'):
            logger.info("Start to create RFC", also_console=True)
            create_rfc_btn.click()
            time.sleep(3)

            rfc_elem = self.wd.find_element(By.XPATH, xpath_created_rfc_locator.format(self._xpath_rfc_list))
            if rfc_elem:
                rfc_item = rfc_elem.get_attribute('id').split('/')[-1]
                logger.info("{0} created".format(rfc_item), also_console=True)
                if '-' in rfc_item and rfc_item.startswith('RFC'):
                    ret_dict['type'] = rfc_item.split('-')[0]
                    ret_dict['id'] = rfc_item.split('-')[-1]
                return ret_dict

        else:
            raise Exception("Failed to create RFC due to generated RFC button is in disabled status!")

    @catch_exception
    @switch_to_tab('RFCs')
    def populate_rfc_details(self, rfc_id, para_dict):
        """
        keyword populate_rfc_details
        Modify/update RFC specific parameter value under RFCs tab
        :param rfc_id: RFC identifier
        :param para_dict: dictionary of parameter:value pair

        Example:
        ${parameter_dict}  Create Dictionary  Serial number=87654321  RF converter type=APHB
        | populate_rfc_details | rfc_id=1 | para_dict=${parameter_dict} |
        """
        logger.info("Dev_ASIR_Selenium populate_rfc_details", also_console=True)
        xpath_para_header = "//div[@id='rfc-header-parameters']"
        xpath_rfc_para_locator = "{0}//*[contains(@class,'{1}')]"
        rfc_para_to_locator_dict = {
            'RF converter name': 'rfcName',
            'Serial number': 'rfcSn',
            'RF converter type': 'rfcType'}

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, self._xpath_rfc_list)))
        assert (rfc_id and para_dict), "Empty mandatory input parameter rfc_id or para_dict!"
        try:
            self.wd.find_element(By.XPATH, self._xpath_rfc_locator.format(self._xpath_rfc_list, rfc_id)).click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate RFC-{0}, check its existence!".format(rfc_id))

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_para_header)))
        converted_dict_keys = [item.strip().lower().replace(' ', '') for item in rfc_para_to_locator_dict.keys()]
        for para, value in para_dict.items():
            if para.strip().lower().replace(' ', '') not in converted_dict_keys:
                logger.info("RFC parameter {0} is not exist to update!".format(para), also_console=True)
                continue

            time.sleep(2)
            assert value, "key {0} associated value is empty!".format(para)
            para_elem = self.wd.find_element(By.XPATH, xpath_rfc_para_locator.
                                             format(xpath_para_header, rfc_para_to_locator_dict.get(para)))
            if para_elem and para_elem.tag_name == 'mat-select':
                logger.info("Update RFC mat-select parameter {0} value to {1}".format(para, value), also_console=True)
                self._select_value_in_mat_select(para_elem, value, lambda x, y: x.strip() == y.strip())

            elif para_elem and para_elem.tag_name == 'input':
                logger.info("Update RFC input parameter {0} value to {1}".format(para, value), also_console=True)
                para_elem.clear()
                para_elem.send_keys(value)

            else:
                raise Exception("RFC parameter with {0} tag name is unsupported.".format(para_elem.tag_name))

    @catch_exception
    @switch_to_tab('RFCs')
    def map_rfc_to_shub(self, rfc_id, rfc_port_id, hubmod_id, sfp_port_id):
        """
        keyword map_rfc_to_shub
        Map selected RFC to specific smart Hub.
        :param rfc_id: RFC identifier
        :param rfc_port_id: RFC port id
        :param hubmod_id: Hub module id which the RFC want to connect to
        :param sfp_port_id: SFP port which the RFC connect to Hub module

        Example:
        | map_rfc_to_shub | rfc_id=1 | rfc_port_id=2 | hubmod_id=2 | sfp_port_id=4 |
        """
        logger.info("Dev_ASIR_Selenium map_rfc_to_shub", also_console=True)
        xpath_rfc_config = "//div[@id='rfc-port-configuration-assignment']"
        xpath_rfc_port_locator = "{0}//tr[contains(@id,'port_{1}')]"
        xpath_rfc_hubmod_locator = "{0}//mat-select[contains(@class,'Hubmod')]"
        xpath_rfc_sfp_port = "{0}//mat-select[contains(@class,'Port')]"

        if not all([rfc_id, rfc_port_id, hubmod_id, sfp_port_id]):
            raise Exception("please provide all mandatory parameters!")
        hub_locator = xpath_rfc_hubmod_locator.format(xpath_rfc_port_locator.format(xpath_rfc_config, rfc_port_id))
        sfp_port_locator = xpath_rfc_sfp_port.format(xpath_rfc_port_locator.format(xpath_rfc_config, rfc_port_id))

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, self._xpath_rfc_list)))
        try:
            self.wd.find_element(By.XPATH, self._xpath_rfc_locator.format(self._xpath_rfc_list, rfc_id)).click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate RFC-{0}, check its existence!".format(rfc_id))

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_rfc_config)))
        shub_item = self.wd.find_element(By.XPATH, hub_locator)
        if shub_item:
            self._select_value_in_mat_select(shub_item,
                                             "HUBMOD-{0}".format(hubmod_id),
                                             lambda x, y: x.strip() == y.strip(),
                                             check_required=False)
        Wait(self.wd, self.ui_delay * 3).until(EC.element_to_be_clickable((By.XPATH, sfp_port_locator)))
        sfp_port_item = self.wd.find_element(By.XPATH, sfp_port_locator)
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
        logger.info("Dev_ASIR_Selenium delete_rfc", also_console=True)
        xpath_del_rfc_btn = "//button[@id='delete-selected-rfc-button']"
        xpath_wrap_del_btn = "{0}//..//..//div[contains(@class,'wrapping-button')]"
        xpath_warn_modal = "//div[@class='modal-panel']//div[@class='header-text' and contains(text(),'Delete RFC')]"
        xpath_warn_del_btn = "//button[text()='Delete']"

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, self._xpath_rfc_list)))
        try:
            self.wd.find_element(By.XPATH, self._xpath_rfc_locator.format(self._xpath_rfc_list, rfc_id)).click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate RFC-{0}, check its existence!".format(rfc_id))

        time.sleep(2)
        warp_del_rfc_btn = self.wd.find_element(By.XPATH, xpath_wrap_del_btn.format(xpath_del_rfc_btn))
        assert ('disabled' not in warp_del_rfc_btn.get_attribute('class')), "Delete RFC button is in disabled status!"
        logger.info("Start to delete RFC-{0}".format(rfc_id), also_console=True)
        self.wd.find_element(By.XPATH, xpath_del_rfc_btn).click()

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_warn_modal)))
        Wait(self.wd, self.ui_delay * 3).until(EC.element_to_be_clickable((By.XPATH, xpath_warn_del_btn)))
        time.sleep(2)
        self.wd.find_element(By.XPATH, xpath_warn_del_btn).click()
        time.sleep(2)

        try:
            self.wd.find_element(By.XPATH, self._xpath_rfc_locator.format(self._xpath_rfc_list, rfc_id)).click()
            raise Exception("Failed to delete RFC-{0}".format(rfc_id))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("RFC-{0} deleted".format(rfc_id), also_console=True)

    """
    xpath for BTS manipulation under BTSes tab
    """
    _xpath_bts_list_table = "//div[@id='bts-list-table']"
    _xpath_bts_locator = "{0}//tr[contains(@id,'BTS-{1}')]"

    @catch_exception
    @switch_to_tab('BTSes')
    def create_bts_manually(self):
        """
        Main Function:
            This keyword is used to create BTS manually under BTSes tab.
        Arguments:
            None
        Return Value:
            :return ret_dict: A dictionary of parameter: Created type & ID
        Examples:
            | create_bts_manually |
        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 1.0.0 | 2022/2/15 | First approved version by VA |
            | Zhao Longmei | 1.0.1 | 2022/3/11 | 1.Add checking spinner appearance & disappearance after creating BTS|
                                               | 2.Add raising Exception if creating BTS failed|
        """

        logger.info("Dev_ASIR_Selenium create_bts_manually", also_console=True)
        xpath_create_bts_btn = "//button[@id='create-bts-manually-button']"
        xpath_created_bts_located = "{0}//tr[contains(@id,'BTS-') and contains(@class,'selected')]"

        ret_dict = {}
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self._xpath_bts_list_table)))
        create_bts_btn = self.wd.find_element(By.XPATH, xpath_create_bts_btn)
        if create_bts_btn and 'disabled' not in create_bts_btn.get_attribute('class'):
            logger.info("Start to create BTS", also_console=True)
            create_bts_btn.click()
            time.sleep(1)

            wait = Wait(self.wd, 1)
            try:
                xpath_div_spinner_container = "//div[@class='spinner-container']"
                loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            except TimeoutException:
                loading_spinner = None
            if loading_spinner:
                wait = Wait(self.wd, 5)
                wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))

            bts_elem = self.wd.find_element(By.XPATH, xpath_created_bts_located.format(self._xpath_bts_list_table))
            if bts_elem:
                bts_elem = bts_elem.get_attribute('id').split('/')[-1]
                logger.info("{0} created".format(bts_elem), also_console=True)
                if '-' in bts_elem and bts_elem.startswith('BTS'):
                    ret_dict['type'] = bts_elem.split('-')[0]
                    ret_dict['id'] = bts_elem.split('-')[-1]
                    return ret_dict
            else:
                raise Exception("Failed to create BTS")

        else:
            raise Exception("Failed to create BTS due to generated BTS button is in disabled status!")

    @catch_exception
    @switch_to_tab('BTSes')
    def delete_bts_manually(self, bts_id, timeout=10):
        """
        Main Function:
            This keyword is used to delete one specific BTS under BTSes tab.
        Arguments:
            :param bts_id: BTS identifier
            :timeout:waiting timeout seconds for spinner's elements disappearance
        Return Value:
            None
        Examples:
            | delete_bts_manually | bts_id=1 |
        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 1.0.0 | 2022/2/15 | First approved version by VA |
        """

        logger.info("Dev_ASIR_Selenium delete_bts_manually", also_console=True)
        xpath_del_bts_btn = "//button[@id='delete-selected-bts-button']"
        xpath_wrap_del_btn = "{0}//..//..//div[contains(@class, 'wrapping-button')]"
        xpath_warn_modal = "//div[@class='modal-panel']//div[text()=' Delete BTS ']"
        xpath_warn_del_btn = "//div[@class='modal-panel']//button[text()='Delete']"

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self._xpath_bts_list_table)))
        try:
            self.wd.find_element(By.XPATH, self._xpath_bts_locator.format(self._xpath_bts_list_table, bts_id)).click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate BTS-{0}, check its existence!".format(bts_id))

        wrap_del_bts_btn = self.wd.find_element(By.XPATH, xpath_wrap_del_btn.format(xpath_del_bts_btn))
        xpath_div_spinner_container = "//div[@class='spinner-container']"
        Wait(self.wd, timeout).until_not(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))

        if 'disable' in wrap_del_bts_btn.get_attribute('class'):
            logger.error("Delete BTS button is in disabled status!")

        self.wd.find_element(By.XPATH, xpath_del_bts_btn).click()

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_warn_modal)))
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_warn_del_btn)))

        time.sleep(1)
        self.wd.find_element(By.XPATH, xpath_warn_del_btn).click()
        time.sleep(1)

        try:
            self.wd.find_element(By.XPATH, self._xpath_bts_locator.format(self._xpath_bts_list_table, bts_id)).click()
            raise Exception("Failed to delete BTS-{0}".format(bts_id))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("BTS-{0} deleted".format(bts_id), also_console=True)

    @catch_exception
    @switch_to_tab('BTSes')
    def populate_bts_details(self, bts_id, para_dict):
        """
        Main Function:
            This keyword is used to modify/update BTS specific parameter value under BTSes tab.
        Arguments:
            :param bts_id: BTS identifier
            :param para_dict: dictionary of parameter:value pair
        Return Value:
            None
        Examples:
            | populate_bts_details | bts_id=1 | para_dict=${parameter_dict} |
            ${parameter_dict}  Create Dictionary  MRBTS ID=1
            ...                                   Target BTS ID=1
            ...                                   Technology=5G
            ...                                   User label=test
            ...                                   MCC=460
            ...                                   MNC=6
            ...                                   MNC length=2
            Note: The keys of ${parameter_dict} must be same as the sample.
        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 1.0.0 | 2022/2/15 | First approved version by VA |
            | Zhao Longmei | 1.0.1 | 2022/5/23 | It is modified due to CB006119 |
        """

        logger.info("Dev_ASIR_Selenium details", also_console=True)
        xpath_bts_details = "//div[@id='bts-details-parameters']"
        xpath_bts_para_locator = "{0}//*[contains(@class,'{1}')]"
        xpath_warn_technology_btn = "//div[text()=' Change BTS technology ']"
        xpath_technology_confirm_btn = "//div[@class='modal-panel']//button[text()='Confirm']"
        bts_para_to_locator_dict = {
            'MRBTS ID': 'mrbtsId',
            'Target BTS ID': 'targetBtsId',
            'Technology': 'technology',
            'User label': 'userLabel',
            'MCC': 'mcc',
            'MNC': 'mnc',
            'MNC length': 'mncLength'}

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self._xpath_bts_list_table)))
        assert (bts_id and para_dict), "Empty mandatory input parameter bts_id or para_dict!"
        try:
            self.wd.find_element(By.XPATH, self._xpath_bts_locator.format(self._xpath_bts_list_table, bts_id)).click()

        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate BTS-{0}, check its existence!".format(bts_id))

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_bts_details)))
        converted_dict_keys = [item.strip().lower().replace(' ', '') for item in bts_para_to_locator_dict.keys()]
        for para, value in para_dict.items():
            if para.strip().lower().replace(' ', '') not in converted_dict_keys:
                logger.info("BTS parameter {0} is not exist to update".format(para), also_console=True)
                continue

            time.sleep(1)
            if not value:
                logger.error("key {0} associated value is empty!".format(para))

            para_elem = self.wd.find_element(By.XPATH, xpath_bts_para_locator.
                                             format(xpath_bts_details, bts_para_to_locator_dict.get(para)))
            if para_elem and para_elem.tag_name == 'mat-select':
                logger.info("Update BTS mat-select parameter {0} value to {1}".format(para, value), also_console=True)
                self._select_value_in_mat_select(para_elem, value, lambda x, y: x.strip() == y.strip())

                try:
                    Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located
                                                           ((By.XPATH, xpath_warn_technology_btn)))
                    time.sleep(1)
                    Wait(self.wd, self.ui_delay * 3).until(EC.element_to_be_clickable
                                                           ((By.XPATH, xpath_technology_confirm_btn))).click()

                except Exception as ex:
                    if "no such element:" in ex.msg:
                        continue

            elif para_elem and para_elem.tag_name == 'input':
                logger.info("Update BTS input parameter {0} value to {1}".format(para, value), also_console=True)
                try:
                    para_elem = self.wd.find_element(By.XPATH, xpath_bts_para_locator.
                                                     format(xpath_bts_details, bts_para_to_locator_dict.get(para)))
                    para_elem.clear()
                    para_elem.send_keys(value)
                except Exception as e:
                    logger.error('Retry send_keys due to Exception:{}'.format(str(e)))
                    para_elem = self.wd.find_element(By.XPATH, xpath_bts_para_locator.
                                                     format(xpath_bts_details, bts_para_to_locator_dict.get(para)))
                    para_elem.clear()
                    para_elem.send_keys(value)

            else:
                raise Exception("BTS parameter with {0} tag name is unsupported.".format(para_elem.tag_name))

    """
    xpath for sHUB manipulation under sHUBs tab
    """
    _xpath_shub_list_table = "//div[@id='hub-list-table']"
    _xpath_shub_locator = "{0}//tr[contains(@id,'HUBMOD-{1}')]"
    _xpath_shub_detail = "//div[@id='hub-configuration-details-content']"

    @catch_exception
    @switch_to_tab('sHUBs')
    def create_shub_manually(self):
        """
        Main Function:
            This keyword is used to create sHUB manually under sHUBs tab.
        Arguments:
            None
        Return Value:
            :return ret_dict: A dictionary of parameter: Created type & ID
        Examples:
            | create_shub_manually |
        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 1.0.0 | 2022/2/25 | First approved version by VA |
        """

        logger.info("Dev_ASIR_Selenium create_shub_manually", also_console=True)
        xpath_create_shub_btn = "//button[@id='create-hub-manually-button']"
        xpath_created_shub_located = "{0}//tr[contains(@id,'HUBMOD-') and contains(@class,'selected')]"

        ret_dict = {}
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self._xpath_shub_list_table)))
        create_shub_btn = self.wd.find_element(By.XPATH, xpath_create_shub_btn)
        if create_shub_btn and 'disabled' not in create_shub_btn.get_attribute('class'):
            logger.info("Start to create shub", also_console=True)
            create_shub_btn.click()
            time.sleep(1)

            wait = Wait(self.wd, 1)
            try:
                xpath_div_spinner_container = "//div[@class='spinner-container']"
                loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
            except TimeoutException:
                loading_spinner = None
            if loading_spinner:
                wait = Wait(self.wd, 10)
                wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))

            shub_elem = self.wd.find_element(By.XPATH, xpath_created_shub_located.format(self._xpath_shub_list_table))
            if shub_elem:
                shub_elem = shub_elem.get_attribute('id').split('/')[-1]
                logger.info("{0} created".format(shub_elem), also_console=True)
                if '-' in shub_elem and shub_elem.startswith('HUBMOD'):
                    ret_dict['type'] = shub_elem.split('-')[0]
                    ret_dict['id'] = shub_elem.split('-')[-1]
                    return ret_dict
            else:
                raise Exception("Failed to create SHUB")

        else:
            raise Exception("Failed to create shub due to generated SHUB button is in disabled status!")

    @catch_exception
    @switch_to_tab('sHUBs')
    def populate_shub_details(self, hubmod_id, para_dict, timeout=10):
        """
        Main Function:
            This keyword is used to modify/update sHUB specific parameter value under sHUBs tab.
        Arguments:
            :param hubmod_id: hubmod identifier
            :param para_dict: dictionary of parameter:value pair
            :timeout:waiting timeout seconds for sHUB detail's element appearance
        Return Value:
            None
        Examples:
            | populate_shub_details | hubmod_id=1 | para_dict=${parameter_dict} |
            ${parameter_dict}  Create Dictionary  sHUB type=APHG
            ...                                   User label=test
            ...                                   Enable the Gen2 RFC support=yes
            Note: The keys of ${parameter_dict} must be same as the sample.
        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 1.0.0 | 2022/3/25 | First approved version by VA |
        """

        logger.info("Dev_ASIR_Selenium populate_shub_details", also_console=True)
        xpath_shub_para_locator = "{0}//*[contains(@class,'{1}')]"
        shub_para_to_locator_dict = {
            'sHUB type': 'hubType',
            'User label': 'userLabel',
            'Enable the Gen2 RFC support': 'enableGen2RfcSupport'}

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self._xpath_shub_list_table)))
        assert (hubmod_id and para_dict), "Empty mandatory input parameter hubmod_id or para_dict!"
        try:
            self.wd.find_element(By.XPATH, self._xpath_shub_locator.format(self._xpath_shub_list_table,
                                                                           hubmod_id)).click()
        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate HUBMOD-{}, check its existence!".format(hubmod_id))

        Wait(self.wd, timeout).until(EC.visibility_of_element_located((By.XPATH, self._xpath_shub_detail)))

        converted_dict_keys = [item.strip().lower().replace(' ', '') for item in shub_para_to_locator_dict.keys()]
        for para, value in para_dict.items():
            if para.strip().lower().replace(' ', '') not in converted_dict_keys:
                logger.info("SHUB parameter {0} is not exist to update".format(para), also_console=True)
                continue

            time.sleep(1)
            if not value:
                logger.error("key {0} associated value is empty!".format(para))

            para_elem = self.wd.find_element(By.XPATH, xpath_shub_para_locator
                                             .format(self._xpath_shub_detail, shub_para_to_locator_dict.get(para)))
            if para_elem and para_elem.tag_name == 'input':
                logger.info("Update input parameter {0} value to {1}".format(para, value), also_console=True)
                para_elem.clear()
                para_elem.send_keys(value)

            elif para_elem and para_elem.tag_name == 'mat-select':
                logger.info("Update sHUB mat-select parameter {0} value to {1}".format(para, value), also_console=True)
                para_elem.click()
                xpath_shub_type_option = "//div[contains(@id, 'mat-select')]//mat-option" \
                                         "//span[contains(text(),'{0}')]".format(value)
                sHUB_type_option = self._find_element_and_match_stripped_text(xpath_shub_type_option, value)
                sHUB_type_option.click()

            elif para_elem and para_elem.tag_name == 'mat-checkbox':
                rfc_checkbox = para_elem.find_element(By.XPATH, ".//input[@type='checkbox']")
                if rfc_checkbox:
                    rfc_chbox_status = rfc_checkbox.get_attribute('aria-checked')
                    rfc_checked_status = 'yes' if rfc_chbox_status == 'true' else 'no'
                    if rfc_checked_status != value.strip().lower():
                        if 'disabled' in para_elem.get_attribute('class').strip():
                            logger.error("Gen2 RFC is in disabled state")
                        else:
                            logger.info("Update checkbox parameter {0} value to {1}"
                                        .format(para, value), also_console=True)
                            para_elem.click()
                    else:
                        logger.info("checkbox parameter {0} is already in {1} status.".format(para, value),
                                    also_console=True)

            else:
                raise Exception("sHUB parameter with {0} tag name is unsupported.".format(para_elem.tag_name))

    @catch_exception
    @switch_to_tab('sHUBs')
    def populate_hubmod_to_bts_asirmod_mapping(self, hubmod_id, index, bts_id, asirmod_id=None):
        """
         Main Function:
             This keyword is used to map hubmod to BTS ASIRMOD under sHUBs tab.
         Arguments:
             :param hubmod_id: hubmod identifier
             :param index: ID identifier
             :param bts_id: bts identifier
             :param asirmod_id: asirmod identifier
         Return Value:
             None
         Examples:
             | populate_hubmod_to_bts_asirmod_mapping | hubmod_id=1 | index=1 | bts_id=1 | asirmod_id=1 |
         Version:
             | Author | Version | Delivery Date | Comments |
             | Zhao Longmei | 1.0.0 | 2022/3/25 | First approved version by VA |
         """

        logger.info("Dev_ASIR_Selenium populate_hubmod_to_bts_asirmod_mapping", also_console=True)
        xpath_hubmod_config = "//div[@id='hub-mapping-configuration-assignment']"
        xpath_index_port_locator = "{0}//tr[contains(@id,'hub_{1}')]"
        xpath_hub_bts_locator = "{0}//mat-select[contains(@class,'btsId')]"
        xpath_hub_asir_locator = "{0}//input[contains(@class,'asiRmodId')]"

        bts_locator = xpath_hub_bts_locator.format(xpath_index_port_locator.format(xpath_hubmod_config, index))
        asirmod_locator = xpath_hub_asir_locator.format(xpath_index_port_locator.format(xpath_hubmod_config, index))

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self._xpath_shub_list_table)))
        try:
            self.wd.find_element(By.XPATH, self._xpath_shub_locator
                                 .format(self._xpath_shub_list_table, hubmod_id)).click()
        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate HUBMOD-{0}, check its existence!".format(hubmod_id))
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_hubmod_config)))
        bts_item = self.wd.find_element(By.XPATH, bts_locator)
        if bts_item:
            if bts_id == '(Clear)' or bts_id == '<No select>':
                self._select_value_in_mat_select(bts_item, "{}".format(bts_id),
                                                 lambda x, y: x.strip() == y.strip(), check_required=False)
            else:
                self._select_value_in_mat_select(bts_item, "BTS-{0}".format(bts_id),
                                                 lambda x, y: x.strip() == y.strip(), check_required=False)

        if asirmod_id:
            Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, asirmod_locator)))
            asirmod_item = self.wd.find_element(By.XPATH, asirmod_locator)
            if asirmod_item:
                assert ('field-error' or 'ng-valid' in asirmod_item.get_attribute('class')), "ASIRMOD ID is disabled!"
                try:
                    asirmod_item.send_keys(Keys.CONTROL, 'a')
                    asirmod_item.send_keys(Keys.BACKSPACE)
                    asirmod_item.send_keys(asirmod_id)
                    asirmod_item.send_keys(Keys.ENTER)
                except Exception as e:
                    logger.error('Retry send_keys due to Exception:{}'.format(str(e)))
                    asirmod_item = self.wd.find_element(By.XPATH, asirmod_locator)
                    asirmod_item.send_keys(Keys.CONTROL, 'a')
                    asirmod_item.send_keys(Keys.BACKSPACE)
                    asirmod_item.send_keys(asirmod_id)
                    asirmod_item.send_keys(Keys.ENTER)

        else:
            logger.info("BTS ID is clear, no ASIRMOD ID required", also_console=True)

    @catch_exception
    @switch_to_tab('sHUBs')
    def delete_shub_manually(self, hubmod_id, timeout=10):
        """
        Main Function:
            This keyword is used to delete one specific sHUB under sHUBs tab.
        Arguments:
            :param hubmod_id: HUBMOD identifier
            :timeout:waiting timeout seconds for spinner's elements disappearance
        Return Value:
            None
        Examples:
            | delete_shub_manually | hubmod_id=1 |
        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 1.0.0 | 2022/3/30 | First approved version by VA |
        """

        logger.info("Dev_ASIR_Selenium delete_sHUB_manually", also_console=True)
        xpath_del_shub_btn = "//button[@id='delete-selected-hub-button']"
        xpath_wrap_del_btn = "{0}//..//..//div[contains(@class, 'wrapping-button')]"
        xpath_warn_modal = "//div[@class='modal-panel']//div[contains(text(), 'Delete sHUB')]"
        xpath_warn_del_btn = "//div[@class='modal-panel']//button[text()='Delete']"

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self._xpath_shub_list_table)))
        try:
            self.wd.find_element(By.XPATH, self._xpath_shub_locator
                                 .format(self._xpath_shub_list_table, hubmod_id)).click()
        except Exception as ex:
            if "no such element:" in ex.msg:
                raise Exception("Unable to locate HUBMOD-{0}, check its existence!".format(hubmod_id))

        xpath_div_spinner_container = "//div[@class='spinner-container']"
        Wait(self.wd, timeout).until_not(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))

        wrap_del_shub_btn = self.wd.find_element(By.XPATH, xpath_wrap_del_btn.format(xpath_del_shub_btn))
        if 'disable' in wrap_del_shub_btn.get_attribute('class'):
            logger.error("Delete sHUB button is in disabled status!")

        self.wd.find_element(By.XPATH, xpath_del_shub_btn).click()

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_warn_modal)))
        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_warn_del_btn)))

        time.sleep(1)
        self.wd.find_element(By.XPATH, xpath_warn_del_btn).click()

        wait = Wait(self.wd, 1)
        try:
            xpath_div_spinner_container = "//div[@class='spinner-container']"
            loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        except TimeoutException:
            loading_spinner = None
        if loading_spinner:
            wait = Wait(self.wd, 10)
            wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))

        try:
            self.wd.find_element(By.XPATH, self._xpath_shub_locator
                                 .format(self._xpath_shub_list_table, hubmod_id)).click()
            raise Exception("Failed to delete HUBMOD-{0}".format(hubmod_id))

        except Exception as ex:
            if "no such element:" in ex.msg:
                logger.info("HUBMOD-{0} deleted".format(hubmod_id), also_console=True)

    @catch_exception
    @switch_to_tab('Activation')
    def check_as_full_configuration_checkbox_status(self, type, checkbox_clickable, checkbox_value):
        """
        Main Function:
            This keyword is used to check full configuration if clickable and config checkbox.
        Arguments:
            :param type: Save or Activate
            :param checkbox_clickable: checkbox if clickable, Y or N
            :param checkbox_value: Set full configuration to True or False
        Return Value:
            None
        Examples:
            | check_as_full_configuration_checkbox_status | type=Save | checkbox_clickable=Y | checkbox_value=True |
        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 1.0.0 | 2022/08/09 | First approved version by VA |
        """

        logger.info("Dev_ASIR_Selenium check_as_full_configuration_checkbox_status", also_console=True)
        xpath_full_configuration_outer = "//mat-checkbox[contains(@id, '{}')]"
        xpath_full_configuration_checkbox_configure = "{0}//input[@id= '{1}-as-full-checkbox-input']"
        full_configuration_btn = self.wd.find_element(By.XPATH, xpath_full_configuration_outer.format(type.lower()))
        checkbox_configure = self.wd.find_element(By.XPATH, xpath_full_configuration_checkbox_configure.format(
            xpath_full_configuration_outer.format(type.lower()), type.lower()))

        is_full_checked = checkbox_configure.get_attribute('aria-checked')
        full_configuration_mode = full_configuration_btn.get_attribute('class')

        checkbox_clickable_dict = {
            'n': 'disable',
            'y': 'valid'}
        checkbox_clickable_key = checkbox_clickable_dict.get(checkbox_clickable.lower())

        if checkbox_clickable_key in full_configuration_mode:
            if is_full_checked == str(checkbox_value).lower():
                logger.info("{0} full configuration checkbox is {1} clickable and checkbox value is as expected {2}"
                            .format(type, checkbox_clickable, checkbox_value), also_console=True)
            assert (is_full_checked == str(checkbox_value).lower()), \
                '{0} full configuration checkbox value is not as expected {1}'.format(type, checkbox_value)
        assert (checkbox_clickable_key in full_configuration_mode), \
            '{0} full configuration checkbox is {1} clickable not as expected'.format(type, checkbox_clickable)

    @catch_exception
    def login_with_kpi_collection(self, url='https://192.168.255.129:3601', user_name='Nemuadmin',
                                  user_password='nemuuser', timeout=30, returned_time_cost={}):
        """
        Main Function:
        login function for CB008091, normally it's used for KPI collection and not for regular usage

        Note: please use below keys to get corresponding time duration
        load_login_page_dura - this key used to get duration from type url into browser to login page visiable
        load_legal_page_dura - this key used to get duration from login button click to legal page appear
        load_topo_page_dura - this key used to get duration from accept button click to topology page visiable

        Arguments:
            :param url: URL of the ASIR WebEM
            :param user_name: user name
            :param user_password: user password
            :param timeout: waiting timeout second for successful login
            :param returned_time_cost: dictionary for carrying out the time cost

        Return Value:
            None for regular scenario, otherwise exception string

        Examples:
        ${tm_cost}  Create Dictionary
        Login With Kpi Collection  timeout=20  returned_time_cost=${tm_cost}

        Version:
        | Author | Version | Delivery Date | Comments |
        | Sun Jingang | 1.0.0 | 2022/03/15 | initial version |
        """
        logger.info("Dev_ASIR_Selenium login_with_kpi_collection", also_console=True)

        xpath_login_panel = "//div[@class='login-panel']"
        xpath_login_button = "//button[contains(@class, 'button-primary')]"
        xpath_login_username = "//div[@id='usernameForm']//input"
        xpath_login_password = "//div[@id='passwordForm']//input"
        xpath_legal_info = "//div[@class='modal-panel']//div[contains(text(), 'Legal information')]"
        xpath_accept_button = "//div[@id='legal-info-modal']//button[text()='Accept']"
        xpath_topo_view_header = "//span[@id='topology-title' and contains(text(),'Topology view')]"
        xpath_topo_view_container = "//div[@id='topologyContainer']"
        xpath_app_item = "//div[@id='topologyContainer']//app-collapsible-group"
        # below xpath used for handle exception
        xpath_read_only_btn = "//button[contains(text(), 'Read-only log in')]"
        xpath_session_exceed = "//div[@id='errorAuthLogin' and contains(text(), 'exceeded')]"

        timeout = int(timeout)
        if self.debug:
            logger.info("debug Selenium adopted", also_console=True)
            self.wd = webdriver.Chrome(
                self.chrome_driver, chrome_options=self.options)
        else:
            logger.info("taf Selenium adopted", also_console=True)
            if not self.selenium_coam:
                self.selenium_coam = sbts()

                if self.virtual_enable:
                    logger.info("enable_virtual_display", also_console=True)
                    self.selenium_coam.enable_virtual_display()

                self.wd = self.selenium_coam._configure_before_login("Chrome", None,
                                                                     "/home/ute/Downloads", None)._driver

        try:
            if self.wd.window_handles:
                self.wd.execute_script("window.open()")
                self.wd.switch_to_window(self.wd.window_handles[-1])
            self.wd.get(url)

        except Exception as Ex:
            logger.info("Retry wd.get operation after exception {0}".format(str(Ex)), also_console=True)
            self.wd.get(url)

        dt_start = time.time()
        wait = Wait(self.wd, timeout)

        login_panel = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_login_panel)))
        login_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_login_button)))
        assert (login_panel and login_button), "Login panel and login button is not ready after {0}s".format(timeout)
        returned_time_cost['load_login_page_dura'] = round(time.time() - dt_start, 3)

        self.wd.find_element(By.XPATH, xpath_login_username).send_keys(user_name)
        self.wd.find_element(By.XPATH, xpath_login_password).send_keys(user_password)
        login_button.click()

        time.sleep(self.ui_delay)
        read_buttons = self.wd.find_elements(By.XPATH, xpath_read_only_btn)
        read_button = read_buttons[0] if read_buttons else None
        if read_button:  # read only button
            read_button.click()
            logger.info("You will get ASIR webEM read only permission.", also_console=True)

        else:
            logger.info("You will get ASIR webEM read write permission.", also_console=True)

        dt_start = time.time()
        try:
            wait.until(EC.visibility_of_element_located((By.XPATH, xpath_legal_info)))

        except Exception as Ex:
            max_session = self.wd.find_element(By.XPATH, xpath_session_exceed)
            if max_session:
                logger.info("Maximum number of sessions is exceeded.")
                return max_session.text

        accept_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_accept_button)))
        assert (accept_button is not None), "Legal alert and accept button is not ready after {0}s".format(timeout)
        returned_time_cost['load_legal_page_dura'] = round(time.time() - dt_start, 3)

        accept_button.click()
        dt_start = time.time()
        topo_header = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_topo_view_header)))
        topo_container = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_topo_view_container)))
        assert (topo_header and topo_container), "topology view is not ready after {0}s".format(timeout)
        app_item_list = []
        while time.time() < dt_start + timeout:
            app_item_list = self.wd.find_elements(By.XPATH, xpath_app_item)
            if len(app_item_list) == 4:
                break
        assert (len(app_item_list) >= 4), "app item count {0} less than expect!".format(len(app_item_list))
        returned_time_cost['load_topo_page_dura'] = round(time.time() - dt_start, 3)

    @catch_exception
    def _get_concurrent_session_info(self, timeout=10):
        """
        Internal method used to get detailed user session info,
        both session number and detailed login info are included.

        :param timeout: timeout to wait expect item appear.
        """
        xpath_user_menu = "//a[@id='user-information']//span[contains(text(), 'Nemuadmin')]"
        xpath_dropdown_table = "//div[@id= 'user-dropdown-content']"
        xpath_session_info_locator = "//a[contains(text(), 'Session information')]"
        xpath_login_number = "//div[@class='users-number']"
        xpath_session_table = "//div[@class='table-container']"
        xpath_close_button = "//button[contains(text(), 'Close')]"

        user_menu = None
        timeout = int(timeout)
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            try:
                user_menu = self.wd.find_element(By.XPATH, xpath_user_menu)
                if user_menu:
                    break
            except Exception as Ex:
                if "no such element" in Ex.msg:
                    time.sleep(2)
                    continue

        assert (user_menu is not None), "unable to locate user login menu after 10s."
        user_menu.click()

        user_session = None
        wait = Wait(self.wd, 10)
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_dropdown_table)))
        user_session = self.wd.find_element(By.XPATH, xpath_session_info_locator)
        assert (user_session is not None), "Unable to locate user session item under dropdown table."
        user_session.click()

        login_session_dict = {'detail_session': []}
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_session_table)))
        time.sleep(2)
        session_element = self.wd.find_element(By.XPATH, xpath_login_number)
        if session_element:
            session_str = session_element.get_attribute('textContent')
            login_session_dict['session_number'] = session_str.split(':')[1].strip()

        user_session_items = self.wd.find_elements(By.XPATH, "{0}//tbody//tr".format(xpath_session_table))
        for session_item in user_session_items:
            tmp_dict = {}
            td_list = session_item.find_elements(By.XPATH, ".//td")
            for td_item in td_list:
                td_session = td_item.find_elements(By.XPATH, ".//span")
                td_span_num = len(td_session)
                td_span_context = td_session[0].get_attribute('textContent').strip() if td_span_num == 1 else \
                    os.path.join(td_session[0].get_attribute('textContent').strip(),
                                 td_session[1].get_attribute('textContent').strip())

                if 'admin' in td_span_context.lower():
                    tmp_dict['login_name'] = td_span_context
                elif 'read' in td_span_context.lower():
                    tmp_dict['access'] = td_span_context
                else:
                    tmp_dict['ip_addr'] = td_span_context
            login_session_dict['detail_session'].append(tmp_dict)

        close_button = None
        close_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_close_button)))
        if close_button:
            close_button.click()
        assert (int(login_session_dict['session_number']) == len(login_session_dict['detail_session'])), \
            "login session number is not equal to the detailed session info!"

        return login_session_dict

    @catch_exception
    def get_concurrent_session_number(self):
        """
        Main function:
        This method used to get total concurrent session number which based on the output of internal
        private method '_get_concurrent_session_info()'

        Arguments:
            None

        return value:
            currently login session number

        Example:
        ${session_number}  Get Concurrent Session Number

        Version:
        | Author | Version | Delivery Date | Comments |
        | Sun Jingang | 1.0.0 | 2022/03/15 | initial version |
        """
        logger.info("Dev_ASIR_Selenium get_concurrent_session_number", also_console=True)
        input_dict = self._get_concurrent_session_info()
        assert input_dict, "Unable to get session number due to empty dictionary!"
        return input_dict.get('session_number')

    @catch_exception
    def get_session_detail_info(self):
        """
        Main function:
        This method used to get detailed session info which based on the output of internal
        private method '_get_concurrent_session_info()'

        Arguments:
            None

        return value:
            list of the detail session info

        Example:
        ${session_info}  Get Session Detail Info

        Version:
        | Author | Version | Delivery Date | Comments |
        | Sun Jingang | 1.0.0 | 2022/03/15 | initial version |
        """
        logger.info("Dev_ASIR_Selenium get_concurrent_session_number", also_console=True)
        input_dict = self._get_concurrent_session_info()
        assert input_dict, "Unable to get detail session info due to empty dictionary!"
        return input_dict.get('detail_session')

    @catch_exception
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_expect_user_number(self, expect_item, expect_value, expect_number, input_list):
        """
        Main function:
        This method used to check one specific item corresponding value number
        whether is equal to expect number.

        Arguments:
            :param expect_item: one value of login_name/access/ip_addr
            :param expect_value: expect value of expect item
            :param expect_number: expect number of expect value
            :param input_list: input list which normally is the return value of get_session_detail_info()

        return value:
            N/A

        Example:
        ${session_info}  Get Session Detail Info
        Check Expect User Number  expect_item=login_name  expect_value=Nemuadmin/(me)  expect_number=1
        ...                       input_list=${session_info}

        Version:
        | Author | Version | Delivery Date | Comments |
        | Sun Jingang | 1.0.0 | 2022/03/15 | initial version |
        """
        logger.info("Dev_ASIR_Selenium check_expect_user_number", also_console=True)
        if not all([expect_item, expect_value, expect_number, input_list]):
            raise Exception("please provide all mandatory parameters for session check!")

        check_result = {'check_result': True, 'check_details': {}}
        filter_list = list(filter(lambda x: x.get(expect_item) == expect_value, input_list))
        logger.info("filter list : {0}".format(filter_list))
        if len(filter_list) != int(expect_number):
            check_result['check_result'] = False
            check_result['check_details'] = filter_list

        if not check_result['check_result']:
            MolerTest.error("{0} expect number check failure {1}!".format(expect_item, check_result))
        MolerTest.steps_end()

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
        """
        Main Function:
            This keyword is used to change account password.
        Arguments:
            :param account_type: Hub User Accounts or NE3S User Account
            :param user_passwd_dict: dictionary of parameter:value pair
        Return Value:
            None
        Examples:
            ${password_dict}  Create Dictionary  toor4nsn=Nokia6666@124!  hubapp=Nokia@126!
            | Change Accounts Password | account_type=Hub User Accounts | user_passwd_dict=${password_dict} |
        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 1.0.0 | 2022/11/30 | First approved version by VA |
            | Dai Min      | 1.0.1 | 2023/01/17 | It is modified due to CB008906-D_sHub |
        """
        logger.info("Dev_ASIR_Selenium Change Accounts Password", also_console=True)
        xpath_new_password_locator = "{}//input[contains(@class, 'newPassword')]"
        xpath_confirm_password_locator = "{}//input[contains(@class, 'confirmPassword')]"
        xpath_password_validator = "{}//ul[contains(@class, 'validators-info')]//li"

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self.xpath_configuration_accounts)))
        account_type_elem = self.wd.find_element(By.XPATH, self.xpath_account_type_locator)
        if account_type == account_type_elem.get_attribute('textContent').strip():
            logger.info("Account Type:{} is as expected".format(account_type), also_console=True)
        else:
            logger.info("Change Account Type to {}".format(account_type), also_console=True)
            self._select_value_in_mat_select(account_type_elem, account_type, lambda x, y: x.strip() == y.strip(),
                                             check_required)
        for para, value in user_passwd_dict.items():
            Wait(self.wd, self.ui_delay * 3).until(
                EC.visibility_of_element_located((By.XPATH, self.xpath_user_form.format(para))))
            new_password_elem = self.wd.find_element(By.XPATH, xpath_new_password_locator.format(
                self.xpath_user_form.format(para)))
            new_password_elem.clear()
            new_password_elem.send_keys(value)
            password_validator_elem = self.wd.find_elements(By.XPATH, xpath_password_validator.format(
                self.xpath_user_form.format(para)))
            validator_content_list = []
            for each_password_validator_elem in password_validator_elem:
                if "validator-info-error" in each_password_validator_elem.get_attribute('class'):
                    validator_content = each_password_validator_elem.get_attribute('textContent')
                    validator_content_list.append(validator_content)
            assert (not validator_content_list), "Password:{} does not comply with password rules, due to {}".format(
                value, validator_content_list)
            confirm_password_elem = self.wd.find_element(By.XPATH, xpath_confirm_password_locator.format(
                self.xpath_user_form.format(para)))
            confirm_password_elem.clear()
            confirm_password_elem.send_keys(value)

        continue_btn = self.wd.find_elements(By.XPATH, self.xpath_continue)
        if continue_btn[0]:
            continue_btn[0].click()
        Wait(self.wd, self.ui_delay * 60).until(EC.visibility_of_element_located((By.XPATH,
                                                                                  self.xpath_pwd_change_done)))
        try:
            Wait(self.wd, self.ui_delay * 2).until(EC.visibility_of_element_located((By.XPATH,
                                                                                     self.xpath_pwd_change_ok)))
            self.wd.find_element(By.XPATH, self.xpath_pwd_finish).click()
        except Exception as e:
            Wait(self.wd, self.ui_delay * 2).until(EC.visibility_of_element_located((By.XPATH,
                                                                                     self.xpath_pwd_change_nok)))
            elems = self.wd.find_elements(By.XPATH, self.xpath_error_tip)
            elem = elems[0]
            elem_info = elem.get_attribute('textContent')
            logger.info("Modify error info: {}".format(elem_info), also_console=True)

            if "Hub System Administrator password is the same as one of" in elem_info and \
                    "Hub Application Administrator password is the same as one of" in elem_info:
                self.wd.find_element(By.XPATH, self.xpath_pwd_retry).click()
                raise UserWarning("Modify toor4nsn and hubapp password failed due to duplicate password")
            if "Hub System Administrator password is the same as one of" in elem_info and \
                    "User name: toor4nsn" in elem_info:
                self.wd.find_element(By.XPATH, self.xpath_pwd_retry).click()
                raise UserWarning("Modify toor4nsn password failed due to duplicate password")
            if "Hub Application Administrator password is the same as one of" in elem_info and \
                    "User name: hubapp" in elem_info:
                self.wd.find_element(By.XPATH, self.xpath_pwd_retry).click()
                raise UserWarning("Modify hubapp password failed due to duplicate password")
            else:
                raise Exception("Modify password failed due to {}".format(e))

    @catch_exception
    def reset_accounts_password_to_default(self, account_type, user, check_required=True):
        """
        Main Function:
            This keyword is used to reset accounts password.
        Arguments:
            :param account_type: Hub User Accounts or NE3S User Account
            :param user: It can support string or list. The user is toor4nsn or hubapp.
        Return Value:
            None
        Examples:
        Example 1: Reset toor4nsn user password
            | Reset Accounts Password To Default | account_type=Hub User Accounts | user=toor4nsn |
        Example 2: Reset accounts toor4nsn and hubapp password
            | Reset Accounts Password To Default | account_type=Hub User Accounts | user=toor4nsn hubapp |
        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 1.0.0 | 2022/11/30 | First approved version by VA |
        """
        logger.info("Dev_ASIR_Selenium Reset Accounts Password To Default", also_console=True)
        xpath_reset_password = "{}//mat-checkbox//input[contains(@id, 'mat-checkbox')]"

        Wait(self.wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH,
                                                                                 self.xpath_configuration_accounts)))
        account_type_elem = self.wd.find_element(By.XPATH, self.xpath_account_type_locator)
        if account_type == account_type_elem.get_attribute('textContent').strip():
            logger.info("Account Type:{} is as expected".format(account_type), also_console=True)
        else:
            logger.info("Change Account Type to {}".format(account_type), also_console=True)
            self._select_value_in_mat_select(account_type_elem, account_type, lambda x, y: x.strip() == y.strip(),
                                             check_required)

        if isinstance(user, str):
            user = user.split()
        for user_each in user:
            reset_pwd_btn = self.wd.find_element(By.XPATH, xpath_reset_password.format(
                self.xpath_user_form.format(user_each)))
            if reset_pwd_btn.get_attribute('aria-checked') == 'true':
                logger.info("User:{} has been choose to reset to default".format(user_each), also_console=True)
            else:
                logger.info("Start to click user:{} to reset to default".format(user_each), also_console=True)
                self.wd.execute_script("arguments[0].click();", reset_pwd_btn)
        continue_btn = self.wd.find_elements(By.XPATH, self.xpath_continue)
        if continue_btn[0]:
            continue_btn[0].click()
        time.sleep(2)
        Wait(self.wd, self.ui_delay * 60).until(EC.visibility_of_element_located((By.XPATH, self.xpath_pwd_change_ok)))
        self.wd.find_element(By.XPATH, self.xpath_pwd_finish).click()


def asir_18hub_function_test_1():
    asir_sel = Dev_ASIR_Selenium(debug=True)
    asir_sel.login()

    print("-" * 10 + " Test save_scf " + "-" * 10)
    asir_sel.save_scf()

    print("-" * 10 + " Test reset_configuration " + "-" * 10)
    tm_cost = {}
    asir_sel.reset_configuration(timeout=120, returned_time_cost=tm_cost)
    print("reset_configuration time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_unit_available " + "-" * 10)
    tm_cost = {}
    asir_sel.check_unit_available(group_name='sHUBs', expected_green_count=2, timeout=180, returned_time_cost=tm_cost)
    print("check_unit_available time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test reset_configuration " + "-" * 10)
    tm_cost = {}
    asir_sel.reset_configuration(timeout=120, returned_time_cost=tm_cost)
    print("reset_configuration time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_unit_available " + "-" * 10)
    tm_cost = {}
    asir_sel.check_unit_available(group_name='pRRHs', expected_green_count=2, timeout=180, returned_time_cost=tm_cost)
    print("check_unit_available time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test Configuration management detect prrh and cells" + "-" * 10)
    tm_cost = {}
    asir_sel.enter_config_man(sub_menu='detect', overwrite=True, returned_time_cost=tm_cost)
    print("enter_config_man detect time cost {:.3f}s".format(tm_cost['time_cost']))

    tm_cost = {}
    asir_sel.check_quantity_of_detected_prrhs(1, 1, returned_time_cost=tm_cost)
    print("check_quantity_of_detected_prrhs on hubmod 1 time cost {:.3f}s".format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_quantity_of_detected_prrhs(2, 1, returned_time_cost=tm_cost)
    print("check_quantity_of_detected_prrhs on hubmod 2 time cost {:.3f}s".format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_quantity_of_detected_cells(1, 2, returned_time_cost=tm_cost)
    print("check_quantity_of_detected_cells on bts 1 time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test prevalidate and activate " + "-" * 10)
    tm_cost = {}
    asir_sel.enter_config_man(sub_menu='edit', overwrite=True, returned_time_cost=tm_cost)
    print("enter_config_man detect time cost {:.3f}s".format(tm_cost['time_cost']))

    tm_cost = {}
    ret_prevalidate = asir_sel.prevalidate(returned_time_cost=tm_cost)
    print("prevalidate result {} time cost {:.3f}s"
          .format(ret_prevalidate.get('ret'), tm_cost.get('time_cost')))

    tm_cost = {}
    ret_activate = asir_sel.activate(as_full_configuration=True, returned_time_cost=tm_cost)
    print("activate result {} time cost of validation {:.3f}s, time cost between next to finsish {:.3f}s"
          .format(ret_activate.get('ret'), tm_cost.get('time_cost_validation', 0),
                  tm_cost.get('time_cost_next_to_finish', 0)))

    print("-" * 10 + " Test check_time_needed_to_expand_ASI_object_in_param_editor " + "-" * 10)
    tm_cost = {}
    asir_sel.enter_config_man(sub_menu='edit', overwrite=True, returned_time_cost=tm_cost)
    print("enter_config_man detect time cost {:.3f}s".format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_ASI_object_in_param_editor(timeout=20)
    print("check_time_needed_to_expand_ASI_object_in_param_editor time cost {:.3f}s".format(tm_cost['time_cost']))

    tm_cost = {}
    asir_sel.enter_config_man(sub_menu='edit', overwrite=True, returned_time_cost=tm_cost)
    print("enter_config_man detect time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_time_needed_to_expand_ANTMOD_object_in_param_editor " + "-" * 10)
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_ANTMOD_object_in_param_editor(1, timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_ANTMOD_object_in_param_editor time cost {:.3f}s".format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_ANTMOD_object_in_param_editor(
        2, 'ANTETHPORT-1 ANTRFSM-1', timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_ANTMOD_object_in_param_editor time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_time_needed_to_expand_HUBMOD_object_in_param_editor " + "-" * 10)
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_HUBMOD_object_in_param_editor(1, timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_HUBMOD_object_in_param_editor time cost {:.3f}s".format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_HUBMOD_object_in_param_editor(
        2, 'ANTPORT-4 HUBANTL-4', timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_HUBMOD_object_in_param_editor time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_time_needed_to_expand_CELL_object_in_param_editor " + "-" * 10)
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_CELL_object_in_param_editor(
        1, 'CHANNELGROUP-1', timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_CELL_object_in_param_editor time cost {:.3f}s".format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_CELL_object_in_param_editor(
        2, 'CHANNELGROUP-1', timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_CELL_object_in_param_editor time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_time_needed_to_modify_specific_parameter_in_param_editor " + "-" * 10)
    tm_cost = {}
    asir_sel.enter_config_man(sub_menu='edit', overwrite=True, returned_time_cost=tm_cost)
    print("enter_config_man detect time cost {:.3f}s".format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_time_needed_to_modify_specific_parameter_in_param_editor(
        'ASI-1/ANTMOD-1', 'antModPrId', 2, timeout=20, returned_time_cost=tm_cost)
    print(
        "check_time_needed_to_modify_specific_parameter_in_param_editor ASI-1/ANTMOD-1 antModPrId 1, time cost {:.3f}s"
        .format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_time_needed_to_modify_specific_parameter_in_param_editor(
        'ASI-1/ANTMOD-2/ANTETHPORT-1', 'administrativeState', 'locked', timeout=20, returned_time_cost=tm_cost)

    print("check_time_needed_to_modify_specific_parameter_in_param_editor ASI-1/ANTMOD-2/ANTETHPORT-1 "
          "administrativeState locked, time cost {:.3f}s".format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_time_needed_to_modify_specific_parameter_in_param_editor(
        'ASI-1', 'asiId', 3, timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_modify_specific_parameter_in_param_editor ASI-1 asiId 3, time cost {:.3f}s"
          .format(tm_cost['time_cost']))

    print("-" * 10 + " Test load_scf " + "-" * 10)
    tm_cost = {}
    asir_sel.load_scf(returned_time_cost=tm_cost)
    returned_time_cost_activate = tm_cost.get("returned_time_cost_activate")
    print("load_scf time_cost_load_scf {:.3f}s time_cost_validation {:.3f}s time_cost_next_to_finish {:.3f}s"
          .format(tm_cost['time_cost'], returned_time_cost_activate['time_cost_validation'],
                  returned_time_cost_activate['time_cost_next_to_finish']))
    asir_sel.logout()


def asir_18hub_function_test_2():
    asir_sel = Dev_ASIR_Selenium(debug=True)
    asir_sel.login()

    tm_cost = {}
    asir_sel.enter_config_man(sub_menu='view', returned_time_cost=tm_cost)
    print("enter_config_man detect time cost {:.3f}s".format(tm_cost['time_cost']))

    tm_cost = {}
    asir_sel.check_time_needed_to_expand_ASI_object_in_view_configuration(timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_ASI_object_in_view_configuration time cost {:.3f}s"
          .format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_time_needed_to_expand_ANTMOD_object_in_view_configuration " + "-" * 10)
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_ANTMOD_object_in_view_configuration(1, timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_ANTMOD_object_in_view_configuration time cost {:.3f}s"
          .format(tm_cost['time_cost']))
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_ANTMOD_object_in_view_configuration(
        2, 'ANTETHPORT-1 ANTRFSM-1', timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_ANTMOD_object_in_view_configuration time cost {:.3f}s"
          .format(tm_cost['time_cost']))
    asir_sel.logout()

    asir_sel.login()
    print("-" * 10 + " Test check_time_needed_to_display_topology_view_upon_login " + "-" * 10)
    tm_cost = {}
    asir_sel.check_time_needed_to_display_topology_view_upon_login(expected_diagram_count=2, timeout=20,
                                                                   returned_time_cost=tm_cost)
    print("check_time_needed_to_display_topology_view_upon_login time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_time_needed_to_expand_sHUBs_group_in_topology_view " + "-" * 10)
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_sHUBs_group_in_topology_view(timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_sHUBs_group_in_topology_view time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_time_needed_to_expand_pRRHs_group_in_topology_view " + "-" * 10)
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_pRRHs_group_in_topology_view(timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_pRRHs_group_in_topology_view time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test check_time_needed_to_expand_CELLs_group_in_topology_view " + "-" * 10)
    tm_cost = {}
    asir_sel.check_time_needed_to_expand_CELLs_group_in_topology_view(timeout=20, returned_time_cost=tm_cost)
    print("check_time_needed_to_expand_CELLs_group_in_topology_view time cost {:.3f}s".format(tm_cost['time_cost']))

    print("-" * 10 + " Test block antmod " + "-" * 10)
    tm_cost = {}
    asir_sel.block_ANTMOD(1, timeout=20, returned_time_cost=tm_cost)
    print("block_ANTMOD display time cost {:.3f}s refresh time cost {:.3f}s"
          .format(tm_cost['time_cost_display'], tm_cost['time_cost_refresh']))
    print("-" * 10 + " Test unblock antmod " + "-" * 10)
    tm_cost = {}
    asir_sel.unblock_ANTMOD(1, timeout=20, returned_time_cost=tm_cost)
    print("unblock_ANTMOD display time cost {:.3f}s refresh time cost {:.3f}s"
          .format(tm_cost['time_cost_display'], tm_cost['time_cost_refresh']))
    print("-" * 10 + " Test reset hubmod " + "-" * 10)
    tm_cost = {}
    asir_sel.reset_HUBMOD(1, timeout=180, returned_time_cost=tm_cost)
    print("reset_HUBMOD display time cost {:.3f}s refresh time cost {:.3f}s"
          .format(tm_cost['time_cost_display'], tm_cost['time_cost_refresh']))

    print("-" * 10 + " Test Configuration management view " + "-" * 10)
    tm_cost = {}
    asir_sel.enter_config_man(sub_menu='view', overwrite=True, returned_time_cost=tm_cost)
    print("enter_config_man view time cost {:.3f}s".format(tm_cost['time_cost']))

    asir_sel.logout()


def bulk_edit_prrh_test():
    asir_sel = Dev_ASIR_Selenium(debug=True)
    asir_sel.login()
    asir_sel.enter_config_man(overwrite=True)
    asir_sel.bulk_edit_prrhs(hub_mod_id=1,
                             ant_port_id_list=[3, 4, 5],
                             prrh_type='AWHHC',
                             prrh_label='prrh label 345',
                             chained_prrh_type='AHGEDA',
                             chained_prrh_label='chained prrh label 345')


def asir_configuration_function_test():
    asir_sel = Dev_ASIR_Selenium(debug=True)
    asir_sel.login()
    asir_sel.enter_config_man(overwrite=True)

    print('=' * 10 + ' Test_switch_to_dedicated_tab ' + '=' * 10)
    tabs = ['RFC', 'pRRHs', 'pRRHs', 'Parameter editor',
            'Cells', 'Activation', 'Profiles']
    for tab in tabs:
        time.sleep(1)
        asir_sel.switch_to_dedicated_tab(tab)

    print('=' * 10 + ' Test add_prrh_to_hub ' + '=' * 10)
    asir_sel.add_prrh_to_hub(
        2, 5, 'AWHHC', 'add prrh label 5', 'AHGEDA', 'add chained prrh label 5')

    print('=' * 10 + ' Test delete_prrh_from_hub ' + '=' * 10)
    asir_sel.delete_prrh_from_hub(2, 5)

    print('=' * 10 + ' Test add_prrh_to_hub with no chained type' + '=' * 10)
    asir_sel.add_prrh_to_hub(
        2, 5, 'AWHHC', 'add prrh label 5')

    print('=' * 10 + ' Test delete_prrh_from_hub ' + '=' * 10)
    asir_sel.delete_prrh_from_hub(2, 5)

    print('=' * 10 + ' Test modify_prrh_in_hub ' + '=' * 10)
    asir_sel.add_prrh_to_hub(
        2, 5, 'AWHHC', 'add prrh label 5', 'AHGEDA', 'add chained prrh label 5')
    asir_sel.modify_prrh_in_hub(
        2, 5, 'AWHHC', 'modify prrh label 5', 'AHGEDA', 'modify chained prrh label 5')
    asir_sel.delete_prrh_from_hub(2, 5)

    print('=' * 10 + ' Test create_profile ' + '=' * 10)
    asir_sel.add_prrh_to_hub(
        2, 2, 'AWHHC', 'prrh label 2', 'AHGEDA', 'chained prrh label 2')
    asir_sel.add_prrh_to_hub(
        2, 3, 'AWHHC', 'prrh label 3', 'AHGEDA', 'chained prrh label 3')
    asir_sel.add_prrh_to_hub(
        2, 4, 'AWHHC', 'prrh label 4', 'AHGEDA', 'chained prrh label 4')
    asir_sel.add_prrh_to_hub(
        2, 5, 'AWHHC', 'prrh label 5', 'AHGEDA', 'chained prrh label 5')
    new_profile_id = asir_sel.create_profile(
        2, 'new profile label', 'AWHHC', ['2-1', '3-1', '4-1'])

    print('=' * 10 + ' Test modify_profile ' + '=' * 10)
    asir_sel.modify_profile(new_profile_id, 'new profile label', 'AWHHC', [
        '1-1', '3-1', '5-1'])
    print('=' * 10 + ' Test delete_profile ' + '=' * 10)
    asir_sel.delete_profile(new_profile_id)

    print('=' * 10 + ' Test populate_cell_mapping_info ' + '=' * 10)
    asir_sel.populate_cell_mapping_info(
        bts_id=1, cell_id=2, profile_id=1, band_class='ARHHB (Band 41)', antl1='ANTL4',
        antl2='ANTL3', antl3='ANTL2', antl4='ANTL1')
    print('=' * 10 + ' Test delete_cell_mapping_info ' + '=' * 10)
    asir_sel.delete_cell_mapping_info(bts_id=1, cell_id=2, profile_id=1)

    print('=' * 10 + ' Test populate_cell_mapping_info ' + '=' * 10)
    asir_sel.populate_cell_mapping_info(bts_id=1, cell_id=2, profile_id=1, band_class='ARHHB (Band 41)',
                                        antl1='(Clear)',
                                        antl2='ANTL3', antl3='ANTL2', antl4='(Clear)')
    print('=' * 10 + ' Test delete_cell_mapping_info ' + '=' * 10)
    asir_sel.delete_cell_mapping_info(bts_id=1, cell_id=2, profile_id=1)

    print('=' * 10 + ' Test populate_cell_mapping_info ' + '=' * 10)
    asir_sel.populate_cell_mapping_info(
        bts_id=1, cell_id=2, profile_id=1, band_class='ARHHB (Band 41)', antl1='ANTL2', antl4='ANTL3')
    print('=' * 10 + ' Test delete_cell_mapping_info ' + '=' * 10)
    asir_sel.delete_cell_mapping_info(bts_id=1, cell_id=2, profile_id=1)

    print('=' * 10 + ' Test populate_cell_mapping_info ' + '=' * 10)
    asir_sel.populate_cell_mapping_info(bts_id=1, cell_id=1, profile_id=2, band_class='ARHHB', antl1='ANTL2',
                                        antl2='ANTL1')
    print('=' * 10 + ' Test delete_cell_mapping_info ' + '=' * 10)
    asir_sel.delete_cell_mapping_info(bts_id=1, cell_id=1, profile_id=2)

    print('=' * 10 + ' Test populate_cell_mapping_info ' + '=' * 10)
    asir_sel.populate_cell_mapping_info(bts_id=1, cell_id=1, profile_id=2, band_class='ARHHB', antl1='ANTL2',
                                        antl2='ANTL1', antl3='ANTL1')
    print('=' * 10 + ' Test delete_cell_mapping_info ' + '=' * 10)
    asir_sel.delete_cell_mapping_info(bts_id=1, cell_id=1, profile_id=2)

    print('=' * 10 + ' Test import_detected_configuration complete' + '=' * 10)
    asir_sel.import_detected_configuration('complete')
    print('=' * 10 + ' Test import_detected_configuration incremental' + '=' * 10)
    asir_sel.import_detected_configuration('incremental')
    print('=' * 10 + ' Test activate' + '=' * 10)
    ret_activate = asir_sel.activate(as_full_configuration=True)
    print(ret_activate)
    print('=' * 10 + ' Test prevalidate' + '=' * 10)
    asir_sel.add_prrh_to_hub(
        2, 5, 'AWHHC', 'prrh label 5', 'AHGEDA', 'chained prrh label 5')
    ret_prevalidate = asir_sel.prevalidate()
    print(ret_prevalidate)

    print('=' * 10 + ' Test modify_parameter' + '=' * 10)
    asir_sel.modify_parameter(
        [{'para_mo': 'ASI-1/ANTMODPR-2', 'para_abbr': 'prodCode', 'value': '123456'}])

    asir_sel.modify_parameter(
        [{'para_mo': 'ASI-1/CMCADM-1', 'para_abbr': 'planFileActivationMode', 'value': 'noServiceLossAllowed'}])
    print('=' * 10 + ' Test logout' + '=' * 10)

    asir_sel.bulk_edit_prrhs(hub_mod_id=1,
                             ant_port_id_list=[3, 4, 5],
                             prrh_type='AWHHC',
                             prrh_label='prrh label 345',
                             chained_prrh_type='AHGEDA',
                             chained_prrh_label='chained prrh label 345')
    asir_sel.bulk_edit_prrhs(hub_mod_id=1,
                             ant_port_id_list=[3, 4, 5],
                             prrh_type='AWHHC',
                             prrh_label='modify chained prrh label 678')
    asir_sel.bulk_edit_prrhs(hub_mod_id=1,
                             ant_port_id_list=[3, 4, 5],
                             chained_prrh_type='AHGEDA',
                             chained_prrh_label='')
    asir_sel.logout()


if __name__ == '__main__':
    bulk_edit_prrh_test()
    # asir_sel = Dev_ASIR_Selenium(debug=True)
    # asir_sel.login()
    # asir_sel.enter_config_man(overwrite=False)

    # dict_hubmod_1_prrh = asir_sel.get_hubmod_prrh_info(hub_mod_id=1)
    # print('dict_hubmod_1_prrh:')
    # print('='*20)
    # pprint(dict_hubmod_1_prrh)
    # print('='*20)

    # dict_hubmod_2_prrh = asir_sel.get_hubmod_prrh_info(hub_mod_id=2)
    # print('dict_hubmod_2_prrh:')
    # print('='*20)
    # pprint(dict_hubmod_2_prrh)
    # print('='*20)
    #
    # dict_all_hubmod_prrh = asir_sel.get_hubmod_prrh_info()
    # print('All dict_all_hubmod_prrh:')
    # print('='*20)
    # pprint(dict_all_hubmod_prrh)
    # print('='*20)
    # dict_all_profile_info = asir_sel.get_profile_info()
    # print('All get_profile_info:')
    # print('='*20)
    # pprint(dict_all_profile_info)
    # print('='*20)
    # pass
