'''
    author: Fuzengz
    contact: fuzeng.zhu@nokia-sbell.com
    Feature: CB005858
'''

from taf.selenium.sbts import *
from collections import OrderedDict
import pprint
from json import loads, dumps
from xml.dom.minidom import parse
import time
import datetime
import os
from pyvirtualdisplay import Display
from taf.selenium.sbts.common.exceptions import UnexpectedElementState
from taf.gnb.oam.coam.admin import *
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait as Wait
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchAttributeException, InvalidElementStateException
import tempfile
import sys
from robot.api import logger
from taf.selenium.sbts import sbts
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_ASIR_Selenium import *
'''
Constants for Selenium recognize elements
'''
_LOCK_STATUS = "Cell Unblock"
_UNLOCK_STATUS = "Cell Block"
_LOCK_OR_UNLOCK_BUTTON_XPATH = '//div[@dist-name="operationDistName"]//ui-button'
_LOCK_BUTTON_XPATH = '//ui-button[contains(@a-text,"Block Cell")]'
_UNLOCK_BUTTON_XPATH = '//ui-button[contains(@a-text,"Unblock")]'
_MODAL_XPATH = '//div[@class="modal-content"]'
_ADMINISTRATIVE_STATE_XPATH = '//td[contains(text(), "Blocking state")]//following-sibling::td'
_ACTIVATION_PLAN_EXECUTE_BUTTON_XPATH = '//div[@class="modal-content"]//ui-button[@a-text="Execute"]/button'
_FEEDBACK_TEXT_XPATH = '//div[@class="modal-content"]//div[@class="feedback-section"]/div[2]'
_ACTIVATE_PLAN_BUTTON_XPATH = '//deploy-action-button//button'
_ASIRMGR_PARAMETER_HUBMOD_NODES = '//span[contains(@class,"node-name")][contains(text(),"HUBMOD-")]'
_ASIRMGR_PARAMETER_BTS_NODES = '//span[contains(@class,"node-name")][contains(text(),"BTS-")]'
_ASIRMGR_PARAMETER_BTS_ID_INPUT = '//tr[contains(@id,"btsId")]//input'
_BTS_LOCK_UNLOCK_BUTTON_XPATH = "//site-block-unblock//ui-button"
_BTS_LOCK_FIELD = 'Block Site'
_BTS_UNLOCK_FIELD = 'Unblock Site'

selenium_coam = sbts()

'''
Function webem_logout_lte:
This function to logout LTE WebEm
Input parameters:
 virtual_enable:  Bool flag for if enable virtual display
'''


def webem_logout_lte(virtual_enable=True):
    selenium_coam.logout()
    if virtual_enable:
        selenium_coam.disable_virtual_display()


'''
Function lock_cell_lte:
This function to Lock/Unlock a cell on LTE WebEm
Input parameters:
 cell_id:  cell id
 to_lock:  True for Lock and False for unlock
 timeout:  Timeout seconds for selenium recognize element
'''


def lock_cell_lte(cell_id, to_lock=True, timeout=60):
    cell_id = int(cell_id)
    coam = selenium_coam.store.get()
    coam.bts_status.cells.navigate_to()
    dbg = coam.debug
    cell_xpath, _ = coam.bts_status.cells._get_cell_xpath_and_info_by_id(
        cell_id)
    coam.bts_status.cells._view_panel.show_detail_panel(cell_xpath)
    status = _LOCK_STATUS if to_lock else _UNLOCK_STATUS
    button_text = dbg.get_text_by_xpath(_LOCK_OR_UNLOCK_BUTTON_XPATH, timeout)
    if status == button_text:
        raise UnexpectedElementState("Current oper of cell is {}, no need to {}".format(
            button_text, 'Lock' if to_lock else 'Unlock'))
    dbg.click_enabled_element_after_visible(
        (By.XPATH, _LOCK_OR_UNLOCK_BUTTON_XPATH), timeout)
    dbg.wait_for_visibility((By.XPATH, _MODAL_XPATH), timeout)
    oper_path = _LOCK_BUTTON_XPATH if to_lock else _UNLOCK_BUTTON_XPATH
    dbg.click_enabled_element((By.XPATH, oper_path), timeout)
    dbg.wait_for_text_present_in_element(
        (By.XPATH, _ADMINISTRATIVE_STATE_XPATH), 'Blocked' if to_lock else 'Unblocked', timeout)


'''
Function lte_activate_plan_click_button_execute:
This function to click execute button on Modal dialog after activation,
Because LTE WebEm has 2 steps' execute
Input parameters:
 timeout:  Timeout seconds for selenium recognize element
'''


def lte_activate_plan_click_button_execute(timeout=60):
    coam = selenium_coam.store.get()
    dbg = coam.debug
    dbg.click_enabled_element_after_visible(
        (By.XPATH, _ACTIVATE_PLAN_BUTTON_XPATH), timeout)
    dbg.click_enabled_element_after_visible(
        (By.XPATH, _ACTIVATION_PLAN_EXECUTE_BUTTON_XPATH), timeout)
    time.sleep(30)
    dbg.click_enabled_element_after_visible(
        (By.XPATH, _ACTIVATION_PLAN_EXECUTE_BUTTON_XPATH), timeout)
    time.sleep(30)


def _switch_to_dedicated_tab(wd, tab, timeout=8):
    """
    _switch_to_dedicated_tab function, enter specified tab after keyword _enter_config_man
    :param wd: web driver instance
    :param tab: tab name
    :param timeout: Maximum waiting seconds before clicking the tab's button
    Note: Due to ASIR WebEM GUI is changed, the method of _switch_to_dedicated_tab will be also changed.
          Please DO NOT call _switch_to_dedicated_tab function in this file again, you can refer to
          switch_to_dedicated_tab function in DevNJ_ASIR_Selenium.py file.
    """
    time.sleep(timeout)
    _xpath_tab = "//button[contains(text(), '{}')]".format(tab)
    tab_btn = wd.find_element(By.XPATH, _xpath_tab)
    if 'active' in tab_btn.get_attribute('class'):
        logger.info("tab '{}' is already active".format(tab))

    else:
        tab_btn.click()
        time.sleep(3)
        assert ('active' in tab_btn.get_attribute('class')
                ), "Failed to switch to tab '{}'".format(tab)
        logger.info("tab '{}' is switched to be active".format(tab))


def _import_detected_configuration(wd, mode):
    """
    _import_detected_configuration funciton, click button 'Import Detected Configuration',
    and choose the import mode
    :param wd: web driver instance
    :param mode: complete or incremental
    Note: Please DO NOT call _import_detected_configuration function in this file again, you can refer to
          import_detected_configuration function in DevNJ_ASIR_Selenium.py file.
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
    wd.find_element(By.XPATH, xpath_import_detected_btn).click()
    wd.find_element(By.XPATH, xpath_select_mode).click()
    wd.find_element(By.XPATH, xpath_continue_btn).click()


def _enter_config_man(wd, overwrite=True, timeout=5):
    """
    _enter_config_man function, enter configuration manager page after login, usually used in Suite Setup
    :param wd: web driver instance
    :param overwrite: True for overwrite last modification, False for continue with last modification
    :param timeout: Maximum seconds for waiting for the configuration manangement page available
    Note: Please DO NOT call _enter_config_man function in this file again, you can refer to enter_config_man function
          in DevNJ_ASIR_Selenium.py file.
    """
    logger.info("DevNJ_ASIR_Selenium _enter_config_man")
    _xpath_config_man_button = "//*[@href='#/commissioning/cards']"
    _xpath_config_man_start_button = "//*[@id='editCurrentStartButton']"
    _xpath_config_man_overwrite_button = "//div[@id='overwrite-modal']//button[text()='Overwrite']"
    _xpath_config_man_continue_button = "//*[@id='continueCurrentContinueButton']"
    _xpath_config_man_header = "//div[@id='commissioning-header']"
    wd.find_element(By.XPATH, _xpath_config_man_button).click()
    if overwrite:
        wd.find_element(
            By.XPATH, _xpath_config_man_start_button).click()
        time.sleep(2)
        overwrite_btn = wd.find_elements(
            By.XPATH, _xpath_config_man_overwrite_button)
        if overwrite_btn:
            overwrite_btn[0].click()
    else:
        wd.find_element(
            By.XPATH, _xpath_config_man_continue_button).click()

    Wait(wd, timeout).until(EC.visibility_of_element_located(
        (By.XPATH, _xpath_config_man_header)))


def _activate(wd, as_full_configuration=None, timeout=60):
    """
    _activate function, switch to tab 'Activation',
        toggle/untoggle the checkbox 'as_full_configuration', click button 'Activate'
    :param wd: web driver instance
    :param as_full_configuration: None for neglect the Full Configuration checkbox,
                                    True for activate as full configuration
                                    False for activate not as full configuration
    :param timeout: waiting timeout seconds for button or dialog apprearance
    Note: Please DO NOT call _activate function in this file again, you can refer to activate function in
          DevNJ_ASIR_Selenium.py file.
    """

    dict_ret = {}
    xpath_activate_btn = "//button[@id='run-activation-btn']"
    xpath_full_checkbox = "//input[@id='activate-as-full-checkbox-input']"
    xpath_full_checkbox_outer = "//mat-checkbox[@id='activate-as-full-checkbox']"
    xpath_validation_modal = "//div[@id='validation-config-error-modal']"
    xpath_validation_modal_close_btn = "{}//button[contains(text(),'Close')]".format(
        xpath_validation_modal)
    xpath_next_btn = "//button[@id='stepper-next-button']"
    xpath_finish_btn = "//button[@id='stepper-finish-button']"

    logger.info('Activate with Full Configuration {}'.format(
        as_full_configuration))
    # User activate regardless the mode
    if as_full_configuration is not None:
        # see if the mode checkbox is disabled or not
        checkbox_mode = wd.find_element(By.XPATH, xpath_full_checkbox)
        checkbox_mode_disabled = 'mat-checkbox-disabled' in checkbox_mode.get_attribute(
            'class').split()

        # if the checkbox is disabled, omit the specified mode
        if not checkbox_mode_disabled:
            logger.info('Activate Mode Checkbox is enabled')
            is_full_checked = checkbox_mode.get_attribute('aria-checked')
            if is_full_checked != str(as_full_configuration).lower():
                logger.info('Change Activate Mode to {}'.format(
                    as_full_configuration))
                wd.find_element(
                    By.XPATH, xpath_full_checkbox_outer).click()
                is_full_checked = checkbox_mode.get_attribute(
                    'aria-checked')
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
    is_full_checked = wd.find_element(
        By.XPATH, xpath_full_checkbox).get_attribute('aria-checked')
    logger.info('Activate Mode on Checkbox is {}'.format(is_full_checked))
    wd.find_element(By.XPATH, xpath_activate_btn).click()
    # noinspection PyBroadException
    try:
        modal_validation = wd.find_element(
            By.XPATH, xpath_validation_modal)
    except Exception as e:
        modal_validation = None

    if modal_validation is None:
        dict_ret['ret'] = True
        wait = Wait(wd, timeout)
        if is_full_checked == 'true':  # full need next and finish
            next_btn = wait.until(
                EC.element_to_be_clickable((By.XPATH, xpath_next_btn)))
            next_btn.click()

        finish_btn = None
        try:
            finish_btn = wait.until(
                EC.element_to_be_clickable((By.XPATH, xpath_finish_btn)))
        except Exception as e:
            screenshot_name = 'activate_finish_button_not_clickable.png'
            logger.warn('Finish button not clickable in {} seconds, screenshot:{}'.format(
                    timeout, screenshot_name))

        if finish_btn:
            tm_start = time.time()
            while time.time() < tm_start+timeout:
                try:
                    finish_btn.click()
                    logger.info('Finish Button clicked')
                    break
                except Exception as e:
                    logger.error(str(e))
                    time.sleep(1)
            else:
                screenshot_name = 'activate_finish_button_not_clicked.png'
                logger.warn('Finish button not clicked in {} seconds, screenshot:{}'.format(
                    timeout, screenshot_name))

    else:
        dict_ret['ret'] = False
        dict_ret['info'] = wd.find_element(
            By.XPATH, "{}//div[@class='content']".format(xpath_validation_modal)).text
        wd.find_element(
            By.XPATH, xpath_validation_modal_close_btn).click()

    return dict_ret


def selenium_asir_webem_sync_dss(url, user_name, user_password, virtual_enable=True, debug=False):
    """
    selenium_asir_webem_sync_dss function, After Gnb Web EM delta commissioned,
        Open ASIR Web EM to sync the change by selenium operation
    :param url: Gnb Web EM url e.g. https://192.168.255.129
    :param user_name: user name of Gnb Web Em, usually 'Nemuadmin'
    :param user_password: user password of Gnb Web Em, usually 'nemuuser'
    :return a Dictionary of selenium operation result
    Note: 1) Before 22R3 release, if you want to call selenium_asir_webem_sync_dss function, please refer to the this
             keyword. But from 22R3 release, please call selenium_asir_webem_sync function in DevNJ_5GOAM_keywords.py
             file instead of sync_config_with_gnb_dss.
          2) Due to ASIR WebEM GUI is changed, the method of _switch_to_dedicated_tab will be also changed. So call
             sync_config_with_gnb_dss function in DevNJ_ASIR_Selenium.py file instead of _switch_to_dedicated_tab &
             _import_detected_configuration & _activate and other functions.
    """
    logger.info("Login to WebEM {}".format(url))
    steps = []
    func_name = sys._getframe().f_code.co_name
    timeout_wait = 30
    ui_delay = 1

    screenshot_dir = tempfile.mkdtemp(prefix='{}_screenshots_'.format(func_name))
    logger.info("selenium_asir_webem_sync, virtual_enable is {}, screenshot dir {}"
                .format(virtual_enable, screenshot_dir), also_console=True)

    wd = None
    if debug:
        options = webdriver.ChromeOptions()
        options.add_argument('--ignore-certificate-errors')
        options.add_argument('--start-maximized')
        logger.info("debug Selenium adopted", also_console=True)
        chrome_driver = r"/opt/ute/chromedriver/chromedriver"
        wd = webdriver.Chrome(chrome_driver, chrome_options=options)
    else:
        logger.info("taf Selenium adopted", also_console=True)
        selenium_coam = sbts()
        if virtual_enable:
            logger.info("enable_virtual_display", also_console=True)
            selenium_coam.enable_virtual_display()

        wd = selenium_coam._configure_before_login("Chrome", None, "/home/ute/Downloads", None)._driver

    wd.implicitly_wait(15)
    try:
        steps.append("Login to WebEM")
        logger.info("Login to WebEM")
        wd.get(url)
        INPUT_USERNAME_XPATH = '//input[@name="username" or @placeholder="Username"]'
        INPUT_PASSWORD_XPATH = '//input[@name="password" or @placeholder="Password"]'
        wd.find_element(By.XPATH, INPUT_USERNAME_XPATH).send_keys(user_name)
        wd.find_element(By.XPATH, INPUT_PASSWORD_XPATH).send_keys(user_password + '\n')

        wait = Wait(wd, timeout_wait)
        try:
            wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, '[a-text="Confirm"]'))).click()
        except TimeoutException as e:
            logger.info("No Confirm button need to click")
        try:
            wait.until(EC.element_to_be_clickable((By.XPATH, "//div[@class='ui-modal']//ui-button["
                                                             "@a-text='Close']//button"))).click()
        except TimeoutException as e:
            logger.info("No Bts Info's Close button need to click")
        steps.append("Click Button 'Launch ASiR Web EM'")
        logger.info("Click Button 'Launch ASiR Web EM'")
        LAUNCH_ASIR_XPATH = '//ui-button[contains(@a-text,"Launch ASiR")]'
        retry_times = 0
        while retry_times < 3:
            try:
                retry_times += 1
                btnAsir = wait.until(EC.element_to_be_clickable((By.XPATH, LAUNCH_ASIR_XPATH)))
                btnAsir.click()
                break
            except Exception as e:
                logger.error('Click "Launch ASIR" button at {} time, exception: {}'.format(retry_times, str(e)))
                time.sleep(1)
        else:
            raise Exception('Failed to click "Launch ASIR" button after {} times'.format(retry_times))

        time.sleep(ui_delay*10)
        logger.info("Webdriver switch to 'ASIR Web EM'")
        steps.append("Webdriver switch to 'ASIR Web EM'")
        for handle in wd.window_handles:
            wd.switch_to.window(handle)
            if 'asir webem' in wd.title.lower():
                break
        # Call sync_config_with_gnb_dss function in DevNJ_ASIR_Selenium.py instead of the following steps.
        call_sync = DevNJ_ASIR_Selenium(wd=wd)
        call_sync.sync_config_with_gnb_dss()
        # steps.append("_enter_config_man")
        # _enter_config_man(wd)
        # steps.append("_switch_to_dedicated_tab(wd, 'Profiles')")
        # _switch_to_dedicated_tab(wd, 'Profiles')
        # steps.append("_import_detected_configuration(wd, 'complete')")
        # _import_detected_configuration(wd, 'complete')
        # steps.append("_switch_to_dedicated_tab(wd, 'Cells')")
        # _switch_to_dedicated_tab(wd, 'Cells')
        # steps.append("_import_detected_configuration(wd, 'complete')")
        # _import_detected_configuration(wd, 'complete')
        # # find the cell list table
        # time.sleep(ui_delay*5)
        # steps.append("wd.find_element_by_id('cell-list-table')")
        # cell_list_table = wd.find_element_by_id('cell-list-table')
        # cell_list_items = cell_list_table.find_elements_by_tag_name('tr')
        # for cell_item in cell_list_items:
        #     cell_item.click()
        #     time.sleep(ui_delay*3)
        # steps.append("_switch_to_dedicated_tab(wd, 'Parameter editor')")
        # _switch_to_dedicated_tab(wd, 'Parameter editor')
        # steps.append("_import_detected_configuration(wd, 'complete')")
        # _import_detected_configuration(wd, 'complete')
        #
        # hub_nodes = wd.find_elements_by_xpath(_ASIRMGR_PARAMETER_HUBMOD_NODES)
        # bts_nodes = wd.find_elements_by_xpath(_ASIRMGR_PARAMETER_BTS_NODES)
        # bts_ids = []
        # for bts_node in bts_nodes:
        #     print(bts_node.text)
        #     bts_ids.append(bts_node.text.split('-')[-1])
        # print('BTS IDs {}'.format(bts_ids))
        # print('hub nodes number {}'.format(len(hub_nodes)))
        # if len(bts_ids) > 1:
        #     for hub_node in hub_nodes:
        #         print('click on hub node')
        #         hub_node.click()
        #         time.sleep(5)
        #         btsId_inputs = wd.find_elements_by_xpath(
        #             _ASIRMGR_PARAMETER_BTS_ID_INPUT)
        #         print('btsId inputs number {}'.format(len(btsId_inputs)))
        #         if len(btsId_inputs) > 1:
        #             for i, btsId_input in enumerate(btsId_inputs):
        #                 print('clear input {}'.format(i))
        #                 btsId_input.clear()
        #                 btsId_input.send_keys(bts_ids[i])
        #                 time.sleep(1)
        # bts_nodes[0].click()
        # steps.append('Click prevalidation Button')
        # wd.find_element_by_id('run-prevalidation-btn').click()
        # time.sleep(5)
        # steps.append("_switch_to_dedicated_tab(wd, 'Activation')")
        # _switch_to_dedicated_tab(wd, 'Activation')
        # steps.append("activate")
        # _activate(wd)
        return {'res': True}
    except Exception as e:
        screenshot_name = '{}.png'.format(func_name)
        if not os.path.exists(screenshot_dir):
            os.makedirs(screenshot_dir)
        screenshot_path = os.path.join(screenshot_dir, screenshot_name)
        wd.save_screenshot(screenshot_path)
        logger.error('{} Exception {}, screenshot saved to {}'.format(func_name, str(e), screenshot_path))
        return {'res': False, 'exception': e, 'steps': steps}
    finally:
        wd.quit()
        if virtual_enable and selenium_coam:
            selenium_coam.disable_virtual_display()


'''
Function generate_scf_from_template:
open and read a SCF delta template, replace __XXX__ with a dictionary values, and return the new SCF file path
See the example on the bottom, the templates file contains some replacing flags eg. __ENB_BTS_ID__, __GNB_CELL_ID,
the function will extract keys and values in dictionary dict_scf_para_replace,
and if the key matches the replacing flags,
It will replace the flag with the value
Input parameters:
 delta_template_path: Path of template delta SCF file
 dict_scf_para_replace: key/value pair for replacing the content of template SCF file
Return:
 Path of new generated SCF file
Example:
    dict_replace = {'gnb_bts_id':3486, 'enb_bts_id':34861, 'gnb_cell_id':1, 'enb_cell_id':2, 'nr_cell_id':57114625}
    print(generate_scf_from_template('delta_templates/enb_dss_add_and_act_template.xml',dict_replace))
'''


def generate_scf_from_template(delta_template_path, dict_scf_para_replace, format='xml'):
    template_xml = None
    with open(delta_template_path, 'r') as f_delta_template:
        template_xml = f_delta_template.read()

    for k, v in dict_scf_para_replace.items():
        template_xml = template_xml.replace(
            '__{}__'.format(str(k).upper()), str(v))
    current_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")
    delta_scf_dir = os.path.join('/tmp', 'delta_scfs')
    if not os.path.exists(delta_scf_dir):
        os.mkdir(delta_scf_dir)
    delta_scf_file_path = os.path.join(delta_scf_dir, '{}_{}.{}'.format(
        os.path.splitext(os.path.basename(delta_template_path))[0], current_time, format))

    with open(delta_scf_file_path, 'a') as f_delta:
        f_delta.write(template_xml)
    return delta_scf_file_path


def is_alarm_belong_to_cell(alarm, cell_id):
    """
    is_alarm_belong_to_cell function,
    is an assistant function for check to check if an alarm object belong to a cell
    :param alarm: Alarm object (Dictionary)
    :param cell_id: Cell ID
    :return a boolean value that indicates if the alarm belongs to the cell
    """
    for k, v in alarm.items():
        if 'alarming object' in k.lower():
            if v.split('-')[-1] == str(cell_id):
                return True
            # return False
    return False


def lock_bts_lte(timeout=60):
    """
    lock_bts_lte function,
    Executes the block site operation on the WebEm
    :param timeout: Timeout value for selenium operation
    """
    return _change_bts_status(_BTS_LOCK_FIELD, timeout)


def unlock_bts_lte(timeout=60):
    """
    unlock_bts_lte function,
    Executes the unblock site operation on the WebEm
    :param timeout: Timeout value for selenium operation
    """
    return _change_bts_status(_BTS_UNLOCK_FIELD, timeout)


def get_bts_lock_or_unlock_lte(timeout=60):
    """
    get_bts_lock_or_unlock_lte function,
    Get the Block Site/Unblock Site button's realtime text
    :param timeout: Timeout value for selenium operation
    """
    coam = selenium_coam.store.get()
    coam.bts_status.site_view.navigate_to()
    dbg = coam.debug
    return dbg.get_attribute_by_xpath(_BTS_LOCK_UNLOCK_BUTTON_XPATH, "a-title", timeout)


def _change_bts_status(field, timeout):
    """
    _change_bts_status function,
    Do block/unblock site operation, according to the field
    :param field: Timeout value for selenium operation, either _BTS_LOCK_FIELD or _BTS_UNLOCK_FIELD
    :param timeout: Timeout value for selenium operation
    :return a Block Site/Unblock Site button's realtime text after opertion
    """
    _MODAL_XPATH = '//div[@class="modal-content"]'
    _LOCK_OR_UNLOCK_BUTTON_XPATH = '//div[@class="modal-content"]//ui-button[contains(*, "lock")]'
    coam = selenium_coam.store.get()
    coam.bts_status.site_view.navigate_to()
    dbg = coam.debug
    dbg.wait_for_enable((By.XPATH, _BTS_LOCK_UNLOCK_BUTTON_XPATH), timeout)

    try:
        current_status = dbg.get_attribute_by_xpath(_BTS_LOCK_UNLOCK_BUTTON_XPATH, "a-title")
    except NoSuchAttributeException:
        current_status = dbg.get_attribute_by_xpath(_BTS_LOCK_UNLOCK_BUTTON_XPATH, "a-text")
    if field != current_status:
        raise InvalidElementStateException('bts is already {}'.format(field.lower().split(' ')[0]))
    dbg.click_enabled_element((By.XPATH, _BTS_LOCK_UNLOCK_BUTTON_XPATH))
    dbg.wait_for_visibility((By.XPATH, _MODAL_XPATH), timeout)
    dbg.click_enabled_element((By.XPATH, _LOCK_OR_UNLOCK_BUTTON_XPATH), timeout)
    dbg.wait_for_text_not_present_in_element((By.XPATH, _BTS_LOCK_UNLOCK_BUTTON_XPATH), current_status, timeout)
    return dbg.get_attribute_by_xpath(_BTS_LOCK_UNLOCK_BUTTON_XPATH, "a-title")
