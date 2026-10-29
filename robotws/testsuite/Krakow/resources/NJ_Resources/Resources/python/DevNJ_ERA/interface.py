# -*- coding: utf-8 -*-
"""
Version:
    | Author | Version | Delivery Date | Comments |
    | Zhao Longmei | 1.0.1 | 2022/9/30 | First approved version by VA |
"""
from .facade import Era
from robot.api import logger
from selenium import webdriver
from taf.selenium.sbts import sbts
from taf.internal.aliasing import aliasing_scope
from .ERA.CatchException import catch_exception


class DevNJ_ERA(object):
    lookup_handler, store = aliasing_scope(name=__name__, lookup_arg='obj_era', lookup_type=Era)

    def __init__(self, driver=None, debug=False, virtual_enable=False):
        self._driver = driver
        self.chrome_driver = r"/opt/ute/chromedriver/chromedriver"
        self.options = webdriver.ChromeOptions()
        self.debug = debug
        self.virtual_enable = virtual_enable

    def set_virtual_enable(self, virtual_enable):
        self.virtual_enable = virtual_enable

    def _create_driver(self):
        if self.debug:
            logger.info("debug Selenium adopted", also_console=True)
            self._driver = webdriver.Chrome(self.chrome_driver, chrome_options=self.options)
        else:
            logger.info("taf Selenium adopted", also_console=True)
            self.selenium_coam = sbts()
            if self.virtual_enable:
                logger.info("enable_virtual_display", also_console=True)
                self.selenium_coam.enable_virtual_display()
            self._driver = self.selenium_coam._configure_before_login("Chrome", None, "/home/ute/Downloads",
                                                                      None)._driver
        obj_era = Era(self._driver)
        return obj_era

    @catch_exception
    def era_login(self, url='https://172.16.0.1/', user_name='ione-tech', user_password='EZ4Techs'):
        """
        Main Function:
           This Keyword is for login era page.
        Arguments:
           :param url: address for era page
           :param user_name: user name for login era
           :param user_password: password for login era
        Return Value:
           None
        Examples:
           | Era Login |
        """
        obj_era = self._create_driver()
        obj_era.login.login(url, user_name, user_password)
        self.store.add(obj_era, alias=None)

    @catch_exception
    @lookup_handler.implicit_lookup
    def era_logout(self, obj_era=None):
        """
        Main Function:
           This Keyword is for logout era page.
        Arguments:
            None
        Return Value:
           None
        Examples:
           | Era Logout |
        """
        obj_era.login.logout()
        if self.virtual_enable and self.selenium_coam:
            self.selenium_coam.disable_virtual_display()

    def clean_browser(self, browser='chrome', obj_era=None):
        """
        Main Function:
           This Keyword is for clean browser.
        Arguments:
            :param browser:
        Return Value:
           None
        Examples:
           | Clean Browser |
        """
        era = Era(self._driver)
        era.login.clean_browser(browser=browser)

    @catch_exception
    @lookup_handler.implicit_lookup
    def switch_to_dedicated_settings_under_system_configuration(self, tab, obj_era=None):
        """
        Main Function:
           This keyword is for switch to tab under system configuration.
        Arguments:
           :param tab: equipment settings or system settings
        Examples:
        Example 1: switch to equipment settings under system configuration
           | Switch To Dedicated Settings Under System Configuration | tab=equipment settings |
        Example 2: switch to system settings under system configuration
           | Switch To Dedicated Settings Under System Configuration | tab=system settings |
        """
        obj_era.system_configuration.navigate_to()
        obj_era.system_configuration.switch_to_dedicated_settings_under_system_configuration(tab=tab)

    @catch_exception
    @lookup_handler.implicit_lookup
    def choose_cdd_slot(self, cdd_slot, obj_era=None):
        """
        Main Function:
           This keyword is for choose which slot.
        Arguments:
           :param cdd_slot: cdd_slot number
        Examples:
           | Choose Cdd Slot | cdd_slot=R1 |
        """
        obj_era.system_configuration.choose_cdd_slot(cdd_slot=cdd_slot)

    @catch_exception
    @lookup_handler.implicit_lookup
    def choose_backup_and_restore(self, file_name, obj_era=None):
        """
        Main Function:
           This keyword is for loading configuration backup to CDD.
        Arguments:
           :param file_name: absolute path and name of the backup zip file
        """
        obj_era.system_configuration.choose_backup_and_restore(file_name=file_name)

    @catch_exception
    @lookup_handler.implicit_lookup
    def modify_card_mode(self, mode, obj_era=None):
        """
        Main Function:
           This keyword is for modify card mode.
        Arguments:
           :param mode: mode for TDD or FDD
        Examples:
           | Modify Card Mode | mode=TDD |
        """
        obj_era.system_configuration.modify_card_mode(mode=mode)

    @catch_exception
    @lookup_handler.implicit_lookup
    def modify_port_parameter(self, cdd_slot, port, para_dict, obj_era=None):
        """
        Main Function:
           This keyword is for modify card mode.
        Arguments:
           :param cdd_slot: cdd_slot number
           :param port: port number
           :param para_dict: a dictionary of parameter
        Examples:
           ${para_dict}  Create Dictionary  Frequency Band=AWS 1700
           ...                              CPRI Rate=7
           ...                              Type=LTE
           ...                              DSS=1.0.R1.3
           | Modify Port Parameter | cdd_slot=R1 | port=1 | para_dict=${para_dict} |
        """
        obj_era.system_configuration.choose_port(cdd_slot=cdd_slot, port=port)
        obj_era.system_configuration.edit_general_properties(para_dict=para_dict)

    @catch_exception
    @lookup_handler.implicit_lookup
    def modify_port_status(self, port, turn_port, obj_era=None):
        """
        Main Function:
           This keyword is for modify port status.
        Arguments:
           :param port: port number
           :param turn_port: turn port to on/off
        Examples:
           | Modify Port Status | port=2 | turn_port=on |
        """
        obj_era.system_configuration.change_port_status(port=port, turn_port=turn_port)

    @catch_exception
    @lookup_handler.implicit_lookup
    def send_task_queue(self, timeout=5, obj_era=None):
        """
        Main Function:
           This keyword is for send tasks.
        Examples:
           | Send Task Queue |
        """
        obj_era.task_queue.send_task_queue(timeout=timeout)

    @catch_exception
    @lookup_handler.implicit_lookup
    def check_signal_route_status(self, signal_route_status='complete', timeout=5, obj_era=None):
        """
        Main Function:
           This keyword is for check signal route status.
        Arguments:
           None
        Examples:
           | Check Signal Route Status |
        """
        obj_era.system_configuration.check_signal_route_status(signal_route_status=signal_route_status,
                                                               timeout=timeout)

    @catch_exception
    @lookup_handler.implicit_lookup
    def modify_signal_set(self, sig_name, channel_info_list, obj_era=None):
        """
        Main Function:
           This Keyword is for modify signal set.
        Arguments:
           :param sig_name: signal set name
           :param channel_info_list: a list for channel info
        Return Value:
           None
        Examples:
           Dictionary of ${para_dict_X}: port_id=R1.1 is mandatory parameter, the remaining set as you expect
        Example 1:
           ${para_dict_1}  Create Dictionary  port_id=R1.1  mimo=AP1
           ${para_dict_2}  Create Dictionary  port_id=R1.1  mimo=AP0
           ${para_list}  Create List  ${para_dict_1}  ${para_dict_2}
           | Modify Signal Set  | sig_name=nr0 | channel_info_list=${para_list} |
        Example 2:
           ${para_dict_1}  Create Dictionary  port_id=R1.1  mimo=AP1  downlink=2667.0 MHz
           ${para_dict_2}  Create Dictionary  port_id=R1.1  mimo=AP0  downlink=2667.0 MHz
           ${para_list}  Create List  ${para_dict_1}  ${para_dict_2}
           | Modify Signal Set | sig_name=nr0 | channel_info_list=${para_list} |
        """
        obj_era.signal_distribution.navigate_to()
        obj_era.signal_distribution.modify_signal_set(sig_name=sig_name, channel_info_list=channel_info_list)

    @catch_exception
    @lookup_handler.implicit_lookup
    def populate_carrier_mapping_info(self, sig_name, ap, obj_era=None):
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
           | Populate Carrier Mapping Info | sig_name=nr0 | ap=L1.1a L1.2a |
        Example 2: Mapping carrier with ap=L1.1a
           | Populate Carrier Mapping Info | sig_name=nr0 | ap=L1.1a |
        """
        obj_era.signal_distribution.navigate_to()
        obj_era.signal_distribution.populate_carrier_mapping_info(sig_name=sig_name, ap=ap)

    @catch_exception
    @lookup_handler.implicit_lookup
    def delete_signal_set(self, sig_name, obj_era=None):
        """
        Main Function:
           This Keyword is for delete signal set.
        Arguments:
           :param sig_name: signal set name
        Return Value:
           None
        Examples:
           | Delete Signal Set | sig_name=nr0 |
        """
        obj_era.signal_distribution.navigate_to()
        obj_era.signal_distribution.delete_signal_set(sig_name=sig_name)
