# -*- coding: utf-8 -*-
"""
:author: longmei.zhao
:contact: longmei.zhao@nokia-sbell.com
"""
import time

from robot.api import logger
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.select import Select
from selenium.webdriver.support.ui import WebDriverWait as Wait
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_ERA.ERA.Get_element_colour\
    import get_elem_main_color


class SystemConfiguration(object):

    def __init__(self, driver, ui_timeout=5):
        self._driver = driver
        self.ui_timeout = ui_timeout

    def navigate_to(self):
        """
        Main Function:
           This keyword is for navigate to system configuration button.
        """
        _xpath_main = "//div[contains(@id, 'bs-main-navbar')]"
        _xpath_system_configuration = "//div[@id='bs-main-navbar-collapse']//a[contains(text(), " \
                                      "'System Configuration')]"
        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH, _xpath_main)))
        self._driver.find_element(By.XPATH, _xpath_system_configuration).click()

    _xpath_choose_file_button = "//*[@id='datafile']"
    _xpath_restore_button = "//*[@id='restoreButton']"

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
        logger.info("Switch tab to {}".format(tab), also_console=True)
        dict_setting_to_button = {'equipment settings': 'equip-settings', 'system settings': 'sys-settings'}

        settings_button = dict_setting_to_button.get(tab.lower())
        _xpath_settings_config = "//div[contains(@class, 'btn-group')]//a[contains(@id, '{}')]".format(settings_button)
        self._driver.find_element(By.XPATH, _xpath_settings_config).click()
        time.sleep(2)

    def choose_cdd_slot(self, cdd_slot):
        """
        Main Function:
           This keyword is for choose which slot.
        Arguments:
           :param cdd_slot: cdd_slot number
        Examples:
           | choose_cdd_slot | cdd_slot=R1 |
        """
        _xpath_device = "//div[@class='device-selector']"
        _xpath_subrack = "{}//a[contains(text(), 'Subrack')]".format(_xpath_device)
        _xpath_slot = "//div[contains(@class, 'rack-column rack-right')]//div[@id='{}']".format(cdd_slot)

        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH, _xpath_device)))
        self._driver.find_element(By.XPATH, _xpath_subrack).click()
        try:
            self._driver.find_element(By.XPATH, _xpath_slot).click()
        except Exception as e:
            if "no such element:" in e.msg:
                raise Exception("Unable to choose {} slot".format(cdd_slot))

    _xpath_save_button = "//div//a[contains(@id, 'save')]"
    _xpath_success_feedback = "//div[contains(@class, 'feedback success')]"

    def choose_backup_and_restore(self, file_name):
        """
        Main Function:
           This keyword is for loading configuration backup to CDD.
        Arguments:
           :param file_name: absolute path and name of the backup zip file
        """
        _xpath_backup_and_restore = "//a[contains(text(), 'Backup and Restore')]"

        self.switch_to_dedicated_settings_under_system_configuration(tab='system settings')
        for retry_times in range(3):
            try:
                self._driver.find_element(By.XPATH, _xpath_backup_and_restore).click()
                new_file_elem = self._driver.find_element(By.XPATH, self._xpath_choose_file_button)
                logger.info("\nAdd new file name:{}".format(file_name), also_console=True)
                new_file_elem.clear()
                new_file_elem.send_keys(file_name)
                self._driver.find_element(By.XPATH, self._xpath_restore_button).click()
                logger.info("\nRestoring the system with reboot - backup {} loading...".format(file_name),
                            also_console=True)
                self._driver.switch_to_alert().accept()
                break
            except Exception as e:
                time.sleep(3)
                if retry_times > 1:
                    raise e

    def modify_card_mode(self, mode):
        """
        Main Function:
           This keyword is for modify card mode after choose slot.
        Arguments:
           :param mode: mode for TDD or FDD
        Examples:
           | modify_card_mode | mode=TDD |
        """
        _xpath_general_properties = "//div[contains(@class, 'container-fluid')]//h3[contains(text(), " \
                                    "'General Properties')]"
        _xpath_config_mode = "//table[contains(@id, 'config-mode')]"
        _xpath_choose_mode = "//input[contains(@id, '{}')]".format(mode.lower())

        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH,
                                                                                    _xpath_general_properties)))
        config_mode_btn = self._driver.find_element(By.XPATH, _xpath_config_mode)
        if str(mode.lower()) in config_mode_btn.get_attribute('original-mode'):
            logger.info("Card Mode {} is as expected".format(mode), also_console=True)
        else:
            logger.info("Change card mode to {}".format(mode), also_console=True)
            self._driver.find_element(By.XPATH, _xpath_choose_mode).click()
            self._driver.find_element(By.XPATH, self._xpath_save_button).click()
            try:
                alert = self._driver.switch_to_alert()
                time.sleep(2)
                alert.accept()
            except Exception as e:
                pass
            Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH,
                                                                                        self._xpath_success_feedback)))

    def choose_port(self, cdd_slot, port):
        """
        Main Function:
           This keyword is for choose which port on slot.
        Arguments:
           :param cdd_slot: cdd_slot number
           :param port: port number
        Examples:
           | choose_port | cdd_slot=R1 | port=2 |
        """
        _xpath_port_row = "//tr[@class='cdd-{0}-port-{1}']".format(cdd_slot, port)
        _xpath_port_num = "{0}//a[contains(text(), '{1}.{2}')]".format(_xpath_port_row, cdd_slot, port)
        _xpath_node_content = "//div[@class='node-content']"

        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH, _xpath_port_row)))
        try:
            self._driver.find_element(By.XPATH, _xpath_port_num).click()
        except Exception as e:
            if "no such element:" in e.msg:
                raise Exception("Unable to choose {0}:{1} port".format(cdd_slot, port))
        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH, _xpath_node_content)))

    def edit_general_properties(self, para_dict):
        """
        Main Function:
           This keyword is for edit port general properties.
        Arguments:
           :param para_dict: a dictionary of parameter
        Examples:
           ${para_dict}  Create Dictionary  Frequency Band=AWS 1700
           ...                              CPRI Rate=7
           ...                              Type=LTE
           ...                              DSS=1.0.R1.3
           | edit_general_properties | para_dict=${para_dict} |
        """
        _xpath_port_para_locator = "//div[@class='form-slot']//select[@id='{}']"
        port_para_to_locator_dict = {
            'Frequency Band': 'freq-band-select',
            'CPRI Rate': 'cpri-rate-select',
            'Type': 'technology-type-select',
            'DSS': 'dss-port-select'}

        converted_dict_keys = [item.strip().lower().replace(' ', '') for item in port_para_to_locator_dict.keys()]
        for para, value in para_dict.items():
            if para.strip().lower().replace(' ', '') not in converted_dict_keys:
                logger.info("Port parameter is not exist to update".format(para), also_console=True)
                continue

            para_elem = self._driver.find_element(By.XPATH, _xpath_port_para_locator.format(
                port_para_to_locator_dict.get(para)))
            if para_elem:
                logger.info("Update input parameter {0} value to {1}".format(para, value), also_console=True)
                para_elem.click()
                Select(para_elem).select_by_visible_text(value)
                para_elem.click()
        time.sleep(2)
        self._driver.find_element(By.XPATH, self._xpath_save_button).click()
        try:
            alert = self._driver.switch_to_alert()
            time.sleep(2)
            alert.accept()
        except Exception as e:
            pass
        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH,
                                                                                    self._xpath_success_feedback)))

    def change_port_status(self, port, turn_port):
        """
        Main Function:
           This keyword is for change port status.
        Arguments:
           :param port: port number
           :param turn_port: turn port to on/off
        Examples:
           | change_port_status | port=2 | turn_port=on |
        """
        _xpath_port_status = "//div[@id='port-{}-onoffswitch']".format(port)
        element = self._driver.find_element(By.XPATH, _xpath_port_status)
        current_colour = get_elem_main_color(wd=self._driver, elem=element)
        turn_port_dict = {
            'on': '#0099CC',
            'off': '#EEEEEE'}
        turn_port_key = turn_port_dict.get(turn_port.lower())
        if turn_port_key == current_colour:
            logger.info("Current port-{} has been turned as expected".format(port), also_console=True)
        else:
            logger.info("Change port-{0} status to be {1}".format(port, turn_port), also_console=True)
            element.click()
            Wait(self._driver, self.ui_timeout).until(
                EC.visibility_of_element_located((By.XPATH, self._xpath_save_button))).click()
            Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH,
                                                                                        self._xpath_success_feedback)))
            change_colour = get_elem_main_color(wd=self._driver, elem=element)
            assert (change_colour != current_colour), "Change port status failed"

    def check_signal_route_status(self, signal_route_status='complete', timeout=5):
        """
        Main Function:
           This keyword is for check signal route status.
        Arguments:
           :param signal_route_status:check signal route status
           :param timeout: wait for signal route status appearing
        Examples:
           | check_signal_route_status |
        """
        _xpath_signal_routing_status = "//a[contains(text(), 'Signal Routing Status')]"
        _xpath_finally_status = "//tr[@role='row']//td[contains(text(), '{}')]"
        _xpath_system_configuration = "//div[@id='bs-main-navbar-collapse']//a[contains(text(), " \
                                      "'System Configuration')]"
        system_config_btn = self._driver.find_element(By.XPATH, _xpath_system_configuration)
        dict_signal_route_status = {
            'complete': 'Complete: Routing Complete',
            'in progress': 'In Progress: Configuration Check Complete'
        }

        signal_route_status = dict_signal_route_status.get(signal_route_status.lower())
        if 'System Configuration' not in system_config_btn.get_attribute('textContent'):
            self.navigate_to()
        self.switch_to_dedicated_settings_under_system_configuration(tab='system settings')
        retry_times = 0
        while True:
            try:
                self._driver.find_element(By.XPATH, _xpath_signal_routing_status).click()
                Wait(self._driver, timeout).until(EC.visibility_of_element_located(
                    (By.XPATH, _xpath_finally_status.format(signal_route_status))))
                break
            except Exception as e:
                time.sleep(3)
                retry_times += 1
                if retry_times > 5:
                    raise e
