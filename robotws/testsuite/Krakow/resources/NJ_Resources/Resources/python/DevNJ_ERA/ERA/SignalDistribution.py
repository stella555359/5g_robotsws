# -*- coding: utf-8 -*-
"""
:author: longmei.zhao
:contact: longmei.zhao@nokia-sbell.com
"""
import time
from selenium.webdriver.support.ui import WebDriverWait as Wait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.common.by import By
from robot.api import logger


class SignalDistribution(object):
    def __init__(self, driver, ui_timeout=5):
        self._driver = driver
        self.ui_timeout = ui_timeout

    def navigate_to(self):
        """
        Main Function:
           This keyword is for navigate to signal distribution button.
        """
        _xpath_main = "//div[contains(@id, 'bs-main-navbar')]"
        _xpath_system_distribution = "//div[@id='bs-main-navbar-collapse']//a[contains(text(), 'Signal Distribution')]"

        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH, _xpath_main)))
        self._driver.find_element(By.XPATH, _xpath_system_distribution).click()

    _xpath_signal_set = "//div[contains(@class, 'panel-signal-sets')]"
    _xpath_signal_sources = "//div[contains(@id, 'signal-sources')]"
    _xpath_signal_sets = "{}//div//div[contains(@class, 'signal-sets')]"
    _xpath_signal_name = "{0}//div[contains(@sig-name, '{1}')]"
    _xpath_save_button = "//div//a[contains(@id, 'save')]"
    _xpath_success_feedback = "//div//span[text()='Success']"

    def modify_signal_set(self, sig_name, channel_info_list):
        """
        Main Function:
           This Keyword is for modify signal set.
        Arguments:
           :param sig_name: signal set name
           :param channel_info_list: a list for channel info
        Return Value:
           None
        Examples:
        Example 1:
           ${para_dict_1}  Create Dictionary  port_id=R1.1  mimo=AP1
           ${para_dict_2}  Create Dictionary  port_id=R1.1  mimo=AP0
           ${para_list}  Create List  ${para_dict_1}  ${para_dict_2}
           | modify_signal_set | sig_name=nr0 | channel_info_list=${para_list} |
        Example 2:
           ${para_dict_1}  Create Dictionary  port_id=R1.1  mimo=AP1  downlink=2667.0 MHz
           ${para_dict_2}  Create Dictionary  port_id=R1.1  mimo=AP0  downlink=2667.0 MHz
           ${para_list}  Create List  ${para_dict_1}  ${para_dict_2}
           | modify_signal_set | sig_name=nr0 | channel_info_list=${para_list} |
        """
        _xpath_add_signal_name = "//div[contains(@class, 'create-new-set')]//a"
        _xpath_signal_edit = "//ul[@class='toolbox-tabs']//li[contains(@class, 'function-edit')]"

        find_signames = self._driver.find_elements(By.XPATH, self._xpath_signal_sets.format(self._xpath_signal_sources
                                                                                            ))
        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH, self._xpath_signal_set)))
        for each_signame in find_signames:
            if sig_name in each_signame.get_attribute('sig-name').strip():
                logger.info("Signal name: {} has been existed".format(sig_name), also_console=True)
                self._driver.find_element(By.XPATH, self._xpath_signal_name.format(self._xpath_signal_sources,
                                                                                   sig_name)).click()
                Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((
                    By.XPATH, _xpath_signal_edit))).click()
                self._mapping_signal_channels(channel_info_list=channel_info_list)
                break
        else:
            self._driver.find_element(By.XPATH, _xpath_add_signal_name).click()
            self._add_new_signal_name(sig_name=sig_name)
            self._mapping_signal_channels(channel_info_list=channel_info_list)

    def _add_new_signal_name(self, sig_name):
        """
        Main Function:
           This Keyword is for add new signal name.
        Arguments:
           :param sig_name: signal set name
        Return Value:
           None
        Examples:
           | _add_new_signal_name | sig_name=nr0 |
        """
        _xpath_locate_name = "//*[contains(@name, 'signalSetName')]"
        new_signame_elem = self._driver.find_element(By.XPATH, _xpath_locate_name)
        logger.info("Add new signal name:{}".format(sig_name), also_console=True)
        new_signame_elem.clear()
        new_signame_elem.send_keys(sig_name)

    def _mapping_signal_channels(self, channel_info_list):
        """
        Main Function:
           This Keyword is for mapping signal channels info.
        Arguments:
           :param channel_info_list: a list for channel info
        Return Value:
           None
        Examples:
        Example 1:
           ${para_dict_1}  Create Dictionary  port_id=R1.1  mimo=AP1
           ${para_dict_2}  Create Dictionary  port_id=R1.1  mimo=AP0
           ${para_list}  Create List  ${para_dict_1}  ${para_dict_2}
           | _mapping_signal_channels | channel_info_list=${para_list} |
        Example 2:
           ${para_dict_1}  Create Dictionary  port_id=R1.1  mimo=AP1  downlink=2667.0 MHz
           ${para_dict_2}  Create Dictionary  port_id=R1.1  mimo=AP0  downlink=2667.0 MHz
           ${para_list}  Create List  ${para_dict_1}  ${para_dict_2}
           | _mapping_signal_channels | channel_info_list=${para_list} |
        """
        _xpath_channel_row = "//tbody[@id='added']//tr"
        _xpath_choose_channel_row = "//tr[contains(@data-port, '{0}')]"

        flag = {}
        channel_rows = self._driver.find_elements(By.XPATH, _xpath_channel_row)
        for tr in channel_rows:
            if 'row_selected' in tr.get_attribute('class').strip():
                logger.info("Remove the selected channel", also_console=True)
                tr.click()

        logger.info("start to click", also_console=True)
        for each_channel_info in channel_info_list:
            for tr_c in self._driver.find_elements(By.XPATH, _xpath_choose_channel_row.format(
                    each_channel_info.get('port_id'))):
                for k, v in each_channel_info.items():
                    flag[k] = False
                    for td_c in tr_c.find_elements(By.XPATH, ".//td"):
                        if each_channel_info.get(k) in td_c.get_attribute('textContent').strip():
                            flag[k] = True
                if all(flag.values()):
                    logger.info("flag:{} is as expected".format(flag))
                    tr_c.click()
                else:
                    logger.info("flag:{} is not as expected".format(flag))

        self._driver.find_element(By.XPATH, self._xpath_save_button).click()
        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH,
                                                                                    self._xpath_success_feedback)))

    def populate_carrier_mapping_info(self, sig_name, ap):
        """
        Main Function:
           This Keyword is for populate carrier mapping info.
        Arguments:
           :param sig_name: signal set name
           :param ap: it can support str and list
        Return Value:
           None
        Examples:
        Example 1: Mapping carrier with ap=L1.1a and ap=L1.2a
           | populate_carrier_mapping_info | sig_name=nr0 | ap=L1.1a L1.2a |
        Example 2: Mapping carrier with ap=L1.1a
           | populate_carrier_mapping_info | sig_name=nr0 | ap=L1.1a |
        """
        find_signames = self._driver.find_elements(By.XPATH, self._xpath_signal_sets.format(self._xpath_signal_sources
                                                                                            ))
        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH, self._xpath_signal_set)))
        for each_signame in find_signames:
            if sig_name in each_signame.get_attribute('sig-name').strip():
                logger.info("Start to click signal name: {}".format(sig_name), also_console=True)
                self._driver.find_element(By.XPATH, self._xpath_signal_name.format(self._xpath_signal_sources,
                                                                                   sig_name)).click()
                self._mapping_ap(ap=ap)
                break
        else:
            logger.error("No signal {} exists".format(sig_name))

    def _mapping_ap(self, ap):
        """
        Main Function:
           This Keyword is for populate carrier mapping info.
        Arguments:
           :ap: it can support str and list
        Return Value:
           None
        Examples:
        Example 1: Mapping carrier with ap=L1.1a and ap=L1.2a
           | _mapping_ap | sig_name=nr0 | ap=L1.1a L1.2a |
        Example 2: Mapping carrier with ap=L1.1a
           | _mapping_ap | sig_name=nr0 | ap=L1.1a |
        """
        _xpath_slot_uap = "//div[contains(@class, 'device-slot slot-uap ')]"
        _xpath_uap_locate = "{}//span[contains(@class, 'signal-active')]".format(_xpath_slot_uap)

        if isinstance(ap, str):
            ap = ap.split()
        uaps_slots = self._driver.find_elements(By.XPATH, _xpath_slot_uap)
        for i, tr in enumerate(uaps_slots):
            for retry_times in range(5):
                try:
                    if 'signal-assigned' in tr.get_attribute('class').strip():
                        logger.info("Remove the selected UAP", also_console=True)
                        tr.click()
                        break
                except StaleElementReferenceException as e:
                    logger.info("Retry...", also_console=True)
                    uaps_slots = self._driver.find_elements(By.XPATH, _xpath_slot_uap)
                    tr = uaps_slots[i]
                    continue
        logger.info("start to click corresponding UAP", also_console=True)
        for ap_each in ap:
            uaps_rows = self._driver.find_elements(By.XPATH, _xpath_uap_locate)
            for i, tr_c in enumerate(uaps_rows):
                for retry_times in range(5):
                    try:
                        if ap_each in tr_c.get_attribute('textContent').strip():
                            tr_c.click()
                            break
                    except StaleElementReferenceException as e:
                        logger.info("Retry...", also_console=True)
                        uaps_rows = self._driver.find_elements(By.XPATH, _xpath_uap_locate)
                        tr_c = uaps_rows[i]
                        continue
        self._driver.find_element(By.XPATH, self._xpath_save_button).click()
        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH,
                                                                                    self._xpath_success_feedback)))

    def delete_signal_set(self, sig_name):
        """
        Main Function:
           This Keyword is for delete signal set.
        Arguments:
           :param sig_name: signal set name
        Return Value:
           None
        Examples:
           | modify_signal_set | sig_name=nr0 |
        """
        _xpath_signal_edit = "//ul[@class='toolbox-tabs']//li[contains(@class, 'function-edit')]"
        _xpath_delete_button = "//div//a[contains(@id, 'delete')]"

        find_signames = self._driver.find_elements(By.XPATH, self._xpath_signal_sets.format(self._xpath_signal_sources
                                                                                            ))
        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH, self._xpath_signal_set)))
        for each_signame in find_signames:
            if sig_name in each_signame.get_attribute('sig-name').strip():
                logger.info("Start to delete {} signal set".format(sig_name), also_console=True)
                self._driver.find_element(By.XPATH, self._xpath_signal_name.format(self._xpath_signal_sources,
                                                                                   sig_name)).click()
                Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((
                    By.XPATH, _xpath_signal_edit))).click()
                Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((
                    By.XPATH, _xpath_delete_button))).click()
                try:
                    alert = self._driver.switch_to_alert()
                    alert.accept()
                except Exception as e:
                    pass
                Wait(self._driver, self.ui_timeout).until(
                    EC.visibility_of_element_located((By.XPATH, self._xpath_signal_set)))
                try:
                    self._driver.find_element(By.XPATH, self._xpath_signal_name.format(self._xpath_signal_sources,
                                                                                       sig_name)).click()
                    raise Exception("Failed to delete {} signal set".format(sig_name))
                except Exception as ex:
                    if "no such element:" in ex.msg:
                        logger.info("{} signal set is deleted successfully".format(sig_name), also_console=True)
                break
        else:
            raise Exception("Signal name: {} is not existed".format(sig_name))
