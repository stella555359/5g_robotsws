# -*- coding: utf-8 -*-
"""
More operation on ASiR WebEM.

:copyright: Nokia Networks
:author: SHI Kun
:contact: I_NJ_SC_SYSTEM_VERF_GMS
:maintainer: I_NJ_SC_SYSTEM_VERF@internal.nsn.com
"""
import datetime
import os
import subprocess
import time
import traceback
from functools import wraps

from moler.util.moler_test import MolerTest
from selenium.webdriver.support.ui import WebDriverWait as Wait
from selenium.webdriver.common.by import By
from selenium.common.exceptions import StaleElementReferenceException, TimeoutException, NoSuchElementException, \
    WebDriverException
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support import expected_conditions as EC
from taf.selenium.sbts import sbts
from testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB008906_ET.resources.Python.helper import\
    GROUP_SHUB, TAB_CELLS, XPATH_TPL_STATE_VALUE, NR, \
    LTE, FDD, get_lte_band, UNIT_MAPPING, \
    XPATH_TL_GROUP_HEADER, TRANS_TEXT, XPATH_DIV_EMPTY_PANEL, TAB_HARDWARE
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_ASIR_Selenium import DevNJ_ASIR_Selenium


def login_logout_decorator(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        self.login()
        try:
            func(*args, **kwargs)
            time.sleep(1)
        finally:
            self.logout()
    return wrapper


class AsirWebEm(DevNJ_ASIR_Selenium):

    def __init__(self, virtual_enable=True):
        super(AsirWebEm, self).__init__(virtual_enable=virtual_enable)

    @DevNJ_ASIR_Selenium.catch_exception
    def login(self, url='https://192.168.255.129:3601', user_name='Nemuadmin', user_password='nemuuser',
              online_mode=True, timeout=10):
        """"Override login"""
        MolerTest.info("ASiR WebEM login")
        _xpath_login_username = "//div[@id='usernameForm']//input"
        _xpath_login_password = "//div[@id='passwordForm']//input"
        _xpath_config_man_header = "//div[@id='commissioning-header']"

        xpath_legal_info = "//div[@class='modal-panel']//div[contains(text(), 'Legal information')]"
        xpath_accept_button = "//div[@id='legal-info-modal']//button[text()='Accept']"

        # below xpath used for handle exception
        xpath_read_only_btn = "//button[contains(text(), 'Read-only log in')]"

        MolerTest.info('virtual_enable:{}'.format(self.virtual_enable))
        MolerTest.info('taf Selenium adopted')
        if not self.selenium_coam:
            self.selenium_coam = sbts()
            if self.virtual_enable:
                MolerTest.info('enable_virtual_display')
                self.selenium_coam.enable_virtual_display()
            self.wd = self.selenium_coam._configure_before_login('Chrome', None,
                                                                 '/home/ute/Downloads', None)._driver
            self.wd.implicitly_wait(10)

        try:
            if self.wd.window_handles:
                self.wd.execute_script('window.open()')
                self.wd.switch_to_window(self.wd.window_handles[-1])
            self.wd.get(url)
        except WebDriverException:
            MolerTest.error('It seems that BTS is rebooting...', raise_exception=True)
        except Exception as e:
            MolerTest.error('Open URL failure: {}'.format(traceback.format_exc()), raise_exception=True)

        # add online_mode parameter to support offline mode ASiR WebEM tool
        if online_mode:
            MolerTest.info('ASiR WebEM running with online mode!')
            wait = Wait(self.wd, timeout)

            self.wd.find_element(
                By.XPATH, _xpath_login_username).send_keys(user_name)
            self.wd.find_element(By.XPATH, _xpath_login_password).send_keys(
                user_password + '\n')

            time.sleep(self.ui_delay)
            read_buttons = self.wd.find_elements(By.XPATH, xpath_read_only_btn)
            read_button = read_buttons[0] if read_buttons else None
            if read_button:  # read only button
                read_button.click()
                MolerTest.info('You will get ASiR webEM read only permission.')

            else:
                MolerTest.info('You will get ASiR webEM read write permission.')
                wait.until(EC.visibility_of_element_located((By.XPATH, xpath_legal_info)))

            accept_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath_accept_button)))
            accept_button.click()
        else:
            MolerTest.info('ASiR WebEM running with offline mode!')
            time.sleep(5)
            Wait(self.wd, self.ui_delay).until(EC.visibility_of_element_located(
                (By.XPATH, _xpath_config_man_header)))

    @DevNJ_ASIR_Selenium.catch_exception
    def logout(self, online_mode=True):
        """"Override logout"""

        MolerTest.info('ASiR WebEM start to logout')
        wait_time_after_logout = 30
        if online_mode:
            try:
                if self.wd:
                    self.wd.find_element(By.XPATH, "//*[@id='user-information']").click()
                    Wait(self.wd, 5).until(EC.element_to_be_clickable((By.XPATH, "//*[@id='log_out']"))).click()
                    MolerTest.info('ASiR WebEM logout successfully.')
            except Exception as e:
                MolerTest.info('Failed to logout: {}'.format(traceback.format_exc()))
                wait_time_after_logout = 3
        try:
            if self.wd:
                self.wd.quit()
            if self.virtual_enable and self.selenium_coam:
                self.selenium_coam.disable_virtual_display()
            MolerTest.info('Quit driver successfully.')
        except Exception as e:
            MolerTest.info('Failed to quit driver: {}'.format(e))

        finally:
            self.wd = None
            self.selenium_coam = None
            cmd = 'ps -ef | grep -v grep | grep chrome'
            MolerTest.info(cmd)
            cmd_process = subprocess.Popen(cmd,
                                           stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                           shell=True)
            output, error = cmd_process.communicate()
            cmd_process.wait()
            MolerTest.info('Found existing Process: {}\n'.format(output.decode()))
            if output.decode().strip():
                cmd = "ps -ef | grep -v 'grep' | grep chrome | awk '{{print $2}}' | sudo xargs kill -9"
                cmd_process = subprocess.Popen(cmd,
                                               stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                               shell=True)
                output, error = cmd_process.communicate()
                cmd_process.wait()
                MolerTest.info('Clean existing Process: {}\n'.format(output.decode()))

            time.sleep(wait_time_after_logout)

    def clean_browser(self, browser='chrome'):
        """Override clean_browser function"""

        if self.wd:
            try:
                self.wd.quit()
            except Exception as e:
                MolerTest.info('{}: {}'.format(__name__, str(e)))
            self.wd = None
        if self.selenium_coam:
            self.selenium_coam = None
        if browser == 'chrome':
            MolerTest.info('open browser to avoid welcome modal')
            subprocess.Popen('google-chrome')
            time.sleep(1)
        cmd = "ps -ef | grep -v 'grep' | grep {} | awk '{{print $2}}' | sudo xargs kill -9".format(
            browser)
        MolerTest.info(cmd)
        os.system(cmd)
        time.sleep(5)

    def search_shub(self, timeout=60):
        """
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
        self.go_to_topo(tab=TAB_CELLS)
        wait = Wait(self.wd, timeout)
        xpath_group_header = \
            "//div[@class='topology-view-columns-container']//div[contains(@class,'group-header')]//" + \
            "span[text()='sHUBs']"
        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class,'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(xpath_group_header)

        view_column = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_view_column)))
        expand_header_button = view_column.find_element(By.XPATH, ".//mat-icon[contains(@class,'expand-header-icon')]")
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
            shub = {'shub_mod_id': shub_id, 'shub_type': shub_type.lower()}
            for field in ('Runtime Managed Object', ):
                xpath_field = './/div[@id="topologyDetailsContainer"]//span[contains(@class,"detail-title") '
                xpath_field += 'and contains(text(), "{}")]/../'.format(field)
                xpath_field += 'span[contains(@class,"detail-text")]'
                value = self.wd.find_element(By.XPATH, xpath_field).text
                if field == 'Runtime Managed Object':
                    shub['runtime_mo'] = value
            MolerTest.info(shub)
            shubs.append(shub)

        cells = self.search_cell_info()
        for shub in shubs:
            runtime_mo = shub['runtime_mo']
            values = self.get_value_from_view(runtime_mo, parameters={'externalRIds': ['asiRmodRId', ]},)
            shub['coam_runtime_mo_id'] = values['externalRIds-asiRmodRId']
            for cell in cells:
                if runtime_mo[6:] in cell['hubmod_in_cell_detail']:
                    shub.update(cell)
                    break
            else:
                MolerTest.error('Not found cell information for this shub: {}'.format(shub))
        MolerTest.info(shubs)
        return shubs

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
        is_commissioned = self.check_site_info()
        self.go_to_topo(TAB_CELLS)
        wd = self.wd
        xpath_cell_label = ".//app-unit//div[contains(@class, 'description-label') and contains(text(), 'BTS')]"
        cells = []

        # get some cell information from 'Cells' of 'Topology view'
        label_results = wd.find_elements_by_xpath(xpath_cell_label)
        MolerTest.info('Labels: {}'.format(label_results))
        if is_commissioned:
            xpath_span_managed_object = XPATH_TPL_STATE_VALUE.format('paired managed object:')
        else:
            xpath_span_managed_object = XPATH_TPL_STATE_VALUE.format('cell technology:')

        for label in label_results:
            # get id
            label_fields = label.text.split('.')
            target_bts_id = int(label_fields[0].replace('BTS', ''))
            target_lcr_id = int(label_fields[1])
            MolerTest.info('Label fields: {}'.format(label_fields))

            cell = {'target_lcr_id': target_lcr_id, 'target_bts_id': target_bts_id}

            # click unit to show properties
            label.click()

            MolerTest.info('Cell details: {}'.format(cell))

            dt_start = time.time()
            while time.time() < dt_start + timeout:
                span_paired_managed_object = wd.find_elements(By.XPATH, xpath_span_managed_object)
                if span_paired_managed_object:
                    managed_object = span_paired_managed_object[0].get_attribute('textContent')
                    MolerTest.info('Got "Paired managed object" : {}'.format(managed_object))
                    for field in ('cell technology', 'hubantl managed object', 'band indicator for 5g nr'):
                        xpath_field = XPATH_TPL_STATE_VALUE.format(field.lower() + ':')
                        values = wd.find_elements(By.XPATH, xpath_field)
                        if 'band indicator' in field:
                            if values:
                                cell['rat'] = NR
                                cell['band'] = int(values[0].get_attribute('textContent'))
                            else:
                                cell['rat'] = LTE
                                if cell['technology'] == FDD:
                                    xpath_field = XPATH_TPL_STATE_VALUE.format('arfcn downlink (fdd):')
                                    values = wd.find_elements(By.XPATH, xpath_field)
                                    earfcn = values[0].get_attribute('textContent')
                                    cell['band'] = get_lte_band(earfcn)
                                else:
                                    MolerTest.error('Need update codes to support other technology')
                        field_value = values[0].get_attribute('textContent')
                        if 'cell technology' in field:
                            cell['technology'] = field_value.lower()
                        elif 'hubantl' in field:
                            cell['hubmod_in_cell_detail'] = '/'.join(field_value.split('/')[:-1])
                    break
            else:
                MolerTest.error('Can not get "managed object" in {}s!'.format(timeout),
                                raise_exception=True)
            cells.append(cell)

        MolerTest.info('Get all Cell Info: {}'.format(cells))

        return cells

    def oper_on_unit(self, group_name, unit_id, operation, check_state_name, init_state_value, timeout=300):
        """
        Reset unit, with unit ID specified.

        :param group_name: group name that unit belongs to, e.g. 'HUBMOD' or 'ANTMOD'
        :param unit_id: unit id, it can be string or list
        :param operation: operation, 'block', 'unblock' or 'reset'
        :param check_state_name: state name to check.
            You can get state name from field 'States' in th properties if unit.
            For example: Operational State, Commissioned, Local State, Hardware State, Software State...
        :param init_state_value: str, initial state value to change.
            For example:
                Operational State: from 'disabled' to 'enabled', init_state_value='disabled'
                Hardware State: from 'resetting' to 'working, init_state_value='resetting'
        :param timeout: waiting timeout seconds for operation done
        :return: None
        """
        if group_name not in UNIT_MAPPING.keys():
            MolerTest.error(
                '{} is not supported! Current supported group name will be in {}'.format(
                    group_name, UNIT_MAPPING.keys()),
                raise_exception=True
            )

        timeout = int(timeout)

        self.go_to_topo(tab=TAB_CELLS)

        wait = Wait(self.wd, timeout)

        unit_ids = unit_id if type(unit_id) is list else str(unit_id).split()

        for unit_id in unit_ids:
            self.click_dedicated_unit(group_name=group_name, unit_id=unit_id)
            try:
                wait.until(EC.element_to_be_clickable((By.XPATH,
                                                       "//button[@id='usm-{}']".format(operation.lower())))).click()
            except StaleElementReferenceException as e:
                MolerTest.info("StaleElementReferenceException, Try again ...")
                wait.until(EC.element_to_be_clickable((By.XPATH, "//button[@id='usm-{}']"
                                                       .format(operation.lower())))).click()

            MolerTest.info("button {} clicked".format(operation))

            self.check_unit_state(group_name=group_name, unit_id=unit_id, check_state_name=check_state_name,
                                  check_state_value=init_state_value)

    def check_site_info(self):
        wd = self.wd
        xpath_status_bar = './/app-status-bar[@id="site-info"]//span[contains(@class, "operational-state")]'
        status_bar = Wait(wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_status_bar)))
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
        wd = self.wd
        unit_prefix = UNIT_MAPPING[group_name]
        wait = Wait(wd, timeout)
        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class, 'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(XPATH_TL_GROUP_HEADER.format(group_name))
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

        xpath_managed_object = XPATH_TPL_STATE_VALUE.format(field_to_search)
        MolerTest.info(xpath_managed_object)
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            managed_object = wd.find_elements(By.XPATH, xpath_managed_object)
            if managed_object \
                    and managed_object[0].get_attribute('textContent').split('/')[-1] == '{}' \
                    .format(field_value):
                break
        else:
            MolerTest.error(
                "Managed object '{} not appear after {}s".format(unit_label, timeout),
                raise_exception=True
            )

    def check_unit_state(self, group_name, unit_id, check_state_name, check_state_value, timeout=300):
        """
        Check the state for specific unit

        :param group_name: group name that unit belongs to, e.g. 'HUBMOD' or 'ANTMOD'
        :param unit_id: unit id, it can be string or list
        :param check_state_name: state name to check.
            You can get state name from field 'States' in th properties if unit.
            For example: Operational State, Commissioned, Local State, Hardware State, Software State...
        :param check_state_value: str, init or target state value to change.
            For example:
                Operational State: from 'disabled' to 'enabled', state_value will be 'disabled' or 'enabled'
                Hardware State: from 'resetting' to 'working, state_value will be 'resetting' or 'working'
        :param timeout: int, waiting timeout seconds for operation done
        :return: None
        """
        self.go_to_topo(TAB_CELLS)
        wd = self.wd
        check_state_name = check_state_name.lower()
        check_state_value = check_state_value.lower()
        unit_prefix = UNIT_MAPPING[group_name]
        wait = Wait(wd, timeout)

        self.click_dedicated_unit(group_name, unit_id)

        xpath_view_column = \
            "{}//ancestor::div[not (contains(@class,'topology-view-columns-container'))" \
            " and contains(@class,'topology-view-column')]".format(XPATH_TL_GROUP_HEADER.format(group_name))
        xpath_app_unit = "{}//app-unit//div[contains(@class,'description-label') and contains(text(),'({}-{})')]" \
            .format(xpath_view_column, unit_prefix, unit_id)
        MolerTest.info("Checking state '{}' change to {} ...".format(check_state_name, check_state_value))
        xpath_span_state_value = (
                XPATH_TPL_STATE_VALUE.format(check_state_name + ':')
                + "//..//span[contains(@class,'detail-text')]//span[{}='{}']".format(TRANS_TEXT, check_state_value))
        MolerTest.info('xpath_span_state_value: {}'.format(xpath_span_state_value))
        dt_start = time.time()
        while time.time() < dt_start + timeout:
            try:
                wd.find_element(By.XPATH, xpath_span_state_value)
                MolerTest.info("'{}' has changed to {} ...".format(check_state_name, check_state_value))
                break
            except Exception as e:
                empty_panels = wd.find_elements(By.XPATH, XPATH_DIV_EMPTY_PANEL)
                if empty_panels:
                    topo_container = wd.find_element(By.XPATH, "//div[@id='topologyContainer']")
                    ActionChains(wd).move_to_element_with_offset(topo_container, 1, 1).click().perform()
                    app_unit = wait.until(EC.visibility_of_element_located((By.XPATH, xpath_app_unit)))
                    app_unit.click()
        else:
            MolerTest.error("State '{}' not reached after {}s".format(check_state_value, timeout),
                            raise_exception=True)

    def check_alarms(self, expected_alarms, unexpected_alarms, timeout=300):
        """
        Check if alarms are expected.

        :param expected_alarms: list, which alarms should be raised.
                For example: [
                    ['minor', 'LMP connectivity detected (61648)', 'ASI-1/ASI_R-1/HUBMOD_R-2']
                    ['major', 'No connection to unit (10)', 'ASI-1/ASI_R-1/HUBMOD_R-1']
                ]
        :param unexpected_alarms: list, which alarms should not be raised.
        :param timeout: waiting timeout seconds for operation done
        :return: None
        """
        MolerTest.info('To check alarms.\nExpected alarms: {}\nUnexpected alarms: {}'.format(
            expected_alarms, unexpected_alarms))
        dt_start = time.time()
        alarms = []
        found_all_expected_alarms = False
        no_unexpected_alarms = False
        while time.time() < dt_start + timeout:
            alarms = self.get_faults_on_topology_view()['fault_list']
            MolerTest.info('Get all faults:\n {}'.format(alarms))
            for expected_alarm in expected_alarms:
                if expected_alarm not in alarms:
                    MolerTest.info('Not found expected alarm: {}. Try again...'.format(expected_alarm))
                    time.sleep(5)
                    break
            else:
                MolerTest.info('Found all expected alarm')
                found_all_expected_alarms = True

            if found_all_expected_alarms:
                for unexpected_alarm in unexpected_alarms:
                    if unexpected_alarm in alarms:
                        MolerTest.info('Found unexpected alarm: {}. Try again...'.format(unexpected_alarm))
                        time.sleep(5)
                        break
                else:
                    MolerTest.info('No unexpected alarm.')
                    no_unexpected_alarms = True

            if found_all_expected_alarms and no_unexpected_alarms:
                break
        else:
            MolerTest.error(
                'Not found all alarms after {}s.\nExpected alarms: {}.\nCurrent alarms on the ASiR WebEM: {}'.format(
                    timeout, expected_alarms, alarms), raise_exception=True)

    def check_cell_color(self, target_bts_ids, expected_color):
        """
        Check if the color of cell with target_bts_id is expected.

        :param target_bts_ids: list of target bts id
        :param expected_color: Green/Yellow/Red
        :Return: bool, True - the result is expected, False - unexpected result
        """
        if not target_bts_ids:
            MolerTest.info('Not provide target bts ids. Skip')
            return True

        self.go_to_topo(TAB_CELLS)
        xpath_indicator_color = ".//app-unit//div[contains(text(), 'BTS{}.')]//..//div[contains(@mattooltip, 'State')]"
        cell_info = {}
        for target_bts_id in target_bts_ids:
            if target_bts_id not in cell_info:
                cell_info[target_bts_id] = []
            xpath_indicator_color = xpath_indicator_color.format(target_bts_id)
            search_results = self.wd.find_elements_by_xpath(xpath_indicator_color)
            for result in search_results:
                cell_color = result.get_attribute('class').split()[2].split('-')[1]
                if cell_color.lower() != expected_color.lower():
                    MolerTest.error(
                        'Cell color ({}) of Target BTS ({}) is not expected ({})!'.format(
                            cell_color, target_bts_id, expected_color)
                    )
                    return False
                else:
                    MolerTest.info(
                        'Cell color ({}) of Target BTS ({}) is expected ({})! '.format(
                            cell_color, target_bts_id, expected_color)
                    )
            else:
                return True
        return False

    def get_cell_info(self, target_bts_ids=[], timeout=300):
        """
        Get all cell ids from 'Cells' tab of 'Topology view'

        :param target_bts_ids: list of target bts id, like [215, 100215]
        :param timeout: waiting timeout seconds for operation done
        :Return: list of cell information
            {
                # target_bts_id: [cell id]
                '100215': [{'id':100215.1, 'managed_object': 'ASI-1/BTS-1/CELL-1'}]
                '215': [215.0]
            }
        """
        MolerTest.info('To check cell info for: {}'.format(target_bts_ids))
        if not target_bts_ids:
            MolerTest.info('No need check cell information.')
            return {}

        self.go_to_topo(TAB_CELLS)
        wd = self.wd
        xpath_cell_label = ".//app-unit//div[contains(@class, 'description-label') and contains(text(), 'BTS')]"
        cell_info = {}

        # get some cell information from 'Cells' of 'Topology view'
        label_results = wd.find_elements_by_xpath(xpath_cell_label)
        MolerTest.info('Labels: {}'.format(label_results))
        for label in label_results:
            # get id
            label_fields = label.text.split('.')
            target_bts_id = int(label_fields[0].replace('BTS', ''))
            target_lcr_id = int(label_fields[1])
            MolerTest.info('Label fields: {}'.format(label_fields))
            if target_bts_ids and target_bts_id not in target_bts_ids:
                MolerTest.info('target_bts_ids: {}, target_bts_id: {}'.format(target_bts_ids, target_bts_id))
                continue

            if target_bts_id not in cell_info:
                cell_info[target_bts_id] = []

            cell_detail = {'targetLcrId': target_lcr_id}

            # click unit to show properties
            label.click()
            xpath_span_paired_managed_object = XPATH_TPL_STATE_VALUE.format('paired managed object:')
            MolerTest.info('Cell details: {}'.format(cell_detail))
            dt_start = time.time()
            while time.time() < dt_start + timeout:
                span_paired_managed_object = wd.find_elements(By.XPATH, xpath_span_paired_managed_object)
                if span_paired_managed_object:
                    managed_object = span_paired_managed_object[0].get_attribute('textContent')
                    MolerTest.info('Got "Paired managed object" : {}'.format(managed_object))
                    cell_detail['managed_object'] = managed_object
                    break
            else:
                MolerTest.error('Can not get "Paired managed object" in {}s!'.format(timeout),
                                raise_exception=True)
            cell_info[target_bts_id].append(cell_detail)

        MolerTest.info('Get all Cell Info: {}'.format(cell_info))
        return cell_info

    def go_to_topo(self, tab=TAB_HARDWARE):
        """
        Open tab of Topology View.

        :return: None
        """
        MolerTest.info("Change tab of topology view to '{}'".format(tab))
        self.enter_topology_view()

        xpath_tab = "//app-tabs[@id='topology-tabs']//a[contains(text(),'{}')]".format(tab)
        MolerTest.info('Xpath tab: {}'.format(xpath_tab))
        time.sleep(10)
        tab_btn = Wait(self.wd, self.ui_delay * 2).until(
            EC.element_to_be_clickable((By.XPATH, xpath_tab)))
        if tab_btn:
            tab_btn.click()

        expand_all_button = self.wd.find_element(
            By.XPATH,
            ".//mat-icon[@data-mat-icon-name='expandAll' and @svgicon='expandAll']")
        expand_all_button.click()

    def get_value_from_view(self, managed_object, parameters):
        """
        Get values from 'View Configuration'

        :param managed_object: str, location of cell. For example: 'ASI-1/BTS-1/CELL-1'
        :param parameters: list, to get the value of these parameters under managed_object
                or
                dict ,  to get the value of these parameters of structured parameter of managed_object, like
                     # 'externalRIds' of 'connectionsInfoList
                     {'externalRIds': ['asiRmodRId', ]},
        :return: dict,
        """
        MolerTest.info('To get value for MO: {}, parameters: {}'.format(managed_object, parameters))
        values = {}
        wd = self.wd
        ui_delay = self.ui_delay * 5
        self.enter_config_man(sub_menu='View')
        self.locate_to_target_mo(managed_object)
        if isinstance(parameters, list) and parameters:
            for para in parameters:
                xpath_para_value = './/tr[@id="{}"]/td[3]//input[contains(@class, "parameterValue")]'.format(para)
                MolerTest.info('xpath of {}: {}'.format(para, xpath_para_value))
                try:
                    Wait(wd, ui_delay).until(EC.visibility_of_element_located((By.XPATH, xpath_para_value)))
                    para_value = wd.find_element(By.XPATH, xpath_para_value).get_attribute('value')
                except TimeoutException:
                    # try other element type
                    xpath_para_value = './/tr[@id="{}"]/td[3]//div[contains(@class, "mat-select-trigger")]'\
                        .format(para)
                    xpath_para_value += '//span[contains(@class, "mat-select-value-text")]/span'
                    MolerTest.info('New xpath of {}: {}'.format(para, xpath_para_value))
                    try:
                        Wait(wd, ui_delay).until(EC.visibility_of_element_located((By.XPATH, xpath_para_value)))
                        para_value = wd.find_element(By.XPATH, xpath_para_value).text
                    except TimeoutException:
                        MolerTest.info('Did not find the value of the expected param: {}'.format(para))
                        para_value = None
                MolerTest.info('{}: {}'.format(para, para_value))
                values[para] = para_value
        elif isinstance(parameters, dict) and parameters:
            for parent, children in parameters.items():
                for para in children:
                    xpath_para_value = './/tr[@id="{}-0-{}"]/td[3]//input[contains(@class, "parameterValue")]'.format(
                        parent, para)
                    MolerTest.info('Check para value: {}'.format(xpath_para_value))
                    Wait(wd, ui_delay).until(EC.visibility_of_element_located((By.XPATH, xpath_para_value)))
                    para_value = wd.find_element(By.XPATH, xpath_para_value).get_attribute('value')
                    MolerTest.info('{}: {}'.format(para, para_value))
                    values[parent + '-' + para] = para_value
        MolerTest.info('Get values: {}'.format(values))
        return values

    def check_view_of_accounts(self):
        self.enter_config_man(sub_menu='Accounts')
        accounts_to_check = ('toor4nsn', 'hubapp')
        wd = self.wd
        ui_delay = self.ui_delay * 10
        for account in accounts_to_check:
            xpath_group = './/form//app-form-group//form[contains(@class, "{}")]'.format(account)
            xpath_to_check = (
                xpath_group + '//app-form-text/div/span[contains(text(), "{}")]'.format(account),
                xpath_group + '//app-form-input/div/div/label[contains(text(), "New password:")]',
                xpath_group + '//app-form-input//mat-checkbox/label//span//input[@type="checkbox"]',
                xpath_group + '//app-form-input//mat-checkbox/label//span[contains(text(), "Reset to default")]',
                xpath_group +
                '//app-form-input/div/div/div/input[contains(@class, "newPassword") and @type="password"]',
                xpath_group + '//app-form-input/div/div/label[contains(text(), "Confirm password:")]',
                xpath_group +
                '//app-form-input/div/div/div/input[contains(@class, "confirmPassword") and @type="password"]',
                xpath_group +
                '//app-form-text/div/label[contains(text(), "Last changed time:")]',
                xpath_group +
                '//app-form-text/div/span[contains(text(), "-")]',
            )
            for xpath in xpath_to_check:
                try:
                    Wait(wd, ui_delay).until(EC.visibility_of_element_located((By.XPATH, xpath)))
                    MolerTest.info("The '{}' exists!".format(xpath))
                except TimeoutException:
                    MolerTest.error("The '{}' does not exist!".format(xpath), raise_exception=True)
                except Exception as e:
                    MolerTest.info(traceback.format_exc())

    def change_password_of_account(self, account='toor4nsn', new_password=None):
        if not new_password:
            new_password = 'asirET@{}'.format(''.join(set([c for c in str(time.time())])))
        self.enter_config_man(sub_menu='Accounts')
        wd = self.wd
        ui_delay = self.ui_delay * 5
        xpath_group = './/form//app-form-group//form[contains(@class, "{}")]'.format(account)
        xpath_new_password = (
                xpath_group +
                '//app-form-input/div/div/div/input[contains(@class, "newPassword") and @type="password"]'
        )
        xpath_confirm_password = (
            xpath_group +
            '//app-form-input/div/div/div/input[contains(@class, "confirmPassword") and @type="password"]'
        )
        for xpath in (xpath_new_password, xpath_confirm_password):
            try:
                password_input = Wait(wd, ui_delay).until(EC.element_to_be_clickable((By.XPATH, xpath)))
                if password_input:
                    password_input.click()
                    password_input.clear()
                    password_input.send_keys(new_password)
            except TimeoutException:
                MolerTest.error('"{}" did not find!'.format(xpath), raise_exception=True)
            except Exception as e:
                MolerTest.error(traceback.format_exc(), raise_exception=True)
        MolerTest.info('Password input. Start to apply new password.')
        last_changed_time_regx = self.apply_new_password()
        last_changed_time = self.get_last_changed_time(last_changed_time_regx)

        return new_password, last_changed_time

    def get_last_changed_time(self, last_changed_time_regx, account='toor4nsn'):
        # then we need check if 'Last changed time' is updated.
        self.enter_config_man(sub_menu='Accounts')
        xpath_group = './/form//app-form-group//form[contains(@class, "{}")]'.format(account)
        xpath_changed_time = (
                xpath_group + '//app-form-text/div/span[contains(text(), "{}")]'.format(last_changed_time_regx)
        )
        try:
            wd = self.wd
            ui_delay = self.ui_delay * 5
            changed_time_label = Wait(wd, ui_delay).until(
                EC.visibility_of_element_located((By.XPATH, xpath_changed_time)))
            last_changed_time = changed_time_label.text
            if not last_changed_time:
                MolerTest.error('No available last changed time.', raise_exception=True)
        except TimeoutException:
            MolerTest.error('"{}" did not find!'.format(xpath_changed_time), raise_exception=True)
        except Exception as e:
            MolerTest.error(traceback.format_exc(), raise_exception=True)

        return last_changed_time

    def apply_new_password(self):
        wd = self.wd
        ui_delay = self.ui_delay * 10
        xpath_btn_cont = './/button[@id="continue-button"]'
        try:
            btn_cont = Wait(wd, ui_delay).until(EC.element_to_be_clickable((By.XPATH, xpath_btn_cont)))
            if btn_cont:
                btn_cont.click()
        except TimeoutException:
            xpath_error = './/div[@id="error-additional-info"]'
            error = ''
            try:
                error = Wait(wd, ui_delay).until(EC.visibility_of_element_located((By.XPATH, xpath_error))).text
            except Exception as e:
                MolerTest.info('Error happened during handling TimeoutException: {}'.format(traceback.format_exc()))
            MolerTest.error('"{}" did not find! Error additional info: {}'.format(xpath_btn_cont, error),
                            raise_exception=True)
        except Exception as e:
            MolerTest.error(traceback.format_exc(), raise_exception=True)

        # new page will be opened to show 'finish' button
        xpath_btn_finish = './/button[@id="finish-button"]'
        try:
            btn_finish = Wait(wd, ui_delay).until(EC.element_to_be_clickable((By.XPATH, xpath_btn_finish)))
            if btn_finish:
                btn_finish.click()
        except TimeoutException:
            MolerTest.error('"{}" did not find!'.format(xpath_btn_finish), raise_exception=True)
        except Exception as e:
            MolerTest.error(traceback.format_exc(), raise_exception=True)

        return (datetime.datetime.now() + datetime.timedelta(hours=2)).strftime('%Y-%m-%dT%H:%M')

    def reset_password_of_account(self, account='toor4nsn'):
        self.enter_config_man(sub_menu='Accounts')
        wd = self.wd
        ui_delay = self.ui_delay * 10
        xpath_group = './/form//app-form-group//form[contains(@class, "{}")]'.format(account)
        xpath_reset_default = (
                xpath_group + '//app-form-input//mat-checkbox/label//span[contains(text(), "Reset to default")]'
        )
        try:
            xpath_reset_default = Wait(wd, ui_delay).until(EC.element_to_be_clickable((By.XPATH, xpath_reset_default)))
            if xpath_reset_default:
                xpath_reset_default.click()
        except TimeoutException:
            MolerTest.error('"{}" did not find!'.format(xpath_reset_default), raise_exception=True)
        except Exception as e:
            MolerTest.error(traceback.format_exc(), raise_exception=True)
        MolerTest.info('Apply default password.')
        last_changed_time_regx = self.apply_new_password()
        return self.get_last_changed_time(last_changed_time_regx)

    def check_last_changed_time(self, last_changed_time, account='toor4nsn'):
        self.enter_config_man(sub_menu='Accounts')
        wd = self.wd
        ui_delay = self.ui_delay * 5
        xpath_group = './/form//app-form-group//form[contains(@class, "{}")]'.format(account)
        xpath_changed_time = (
                xpath_group + '//app-form-text/div/span[contains(text(), "{}")]'.format(last_changed_time)
        )
        try:
            Wait(wd, ui_delay).until(
                EC.visibility_of_element_located((By.XPATH, xpath_changed_time)))
        except TimeoutException:
            MolerTest.error('"{}" was not find!'.format(xpath_changed_time), raise_exception=True)
        except Exception as e:
            MolerTest.error(traceback.format_exc(), raise_exception=True)

        # another account should not be impacted
        if account == 'toor4nsn':
            another_account = 'hubapp'
        else:
            another_account = 'toor4nsn'
        xpath_group = './/form//app-form-group//form[contains(@class, "{}")]'.format(another_account)
        xpath_changed_time = (
                xpath_group + '//app-form-text/div/span[contains(text(), "{}")]'.format(last_changed_time)
        )
        try:
            Wait(wd, ui_delay).until(
                EC.visibility_of_element_located((By.XPATH, xpath_changed_time)))
            MolerTest.error(
                'The account "{}" has a same "Last changed time" ({})!'.format(another_account, last_changed_time),
                raise_exception=True
            )
        except TimeoutException:
            MolerTest.info('The account "{}" was not impacted.'.format(another_account))
        except Exception as e:
            MolerTest.error(traceback.format_exc(), raise_exception=True)

    def locate_to_target_mo(self, managed_object):
        """
        Show 'View' page of 'Configuration management' and locate expected managed object

        :param managed_object: str, location of cell. For example: 'ASI-1/BTS-1/CELL-1'
        :return: None
        """
        mo_fields = managed_object.split('/')
        id_of_node = mo_fields[0]
        if len(mo_fields) > 1:
            for field in mo_fields[1:]:
                id_of_node += '/' + field
                # click node
                self.click_mat_icon_to_expand(id_of_node)

    def click_mat_icon_to_expand(self, id_of_node):
        """
        Expand node

        :param id_of_node: str, which node should be expanded.
        :return: None
        """
        xpath_mat_icon = '//mat-icon[contains(@svgicon, "arrowRight")]'
        xpath_mat_icon = './/div[@id="{}"]'.format(id_of_node) + xpath_mat_icon
        MolerTest.info('XPath of mat icon for id {}: {}'.format(id_of_node, xpath_mat_icon))
        try:
            mat_icon = Wait(self.wd, 1).until(EC.element_to_be_clickable((By.XPATH, xpath_mat_icon)))
            if mat_icon:
                mat_icon.click()
        except TimeoutException:
            # means there is no mat_icon before node, so we can click this node directly
            xpath_no_mat_icon = './/div[@id="{}"]'.format(id_of_node)
            MolerTest.info('XPath of no mat icon for id {}: {}'.format(id_of_node, xpath_no_mat_icon))
            no_mat_icon = Wait(self.wd, 1).until(EC.element_to_be_clickable((By.XPATH, xpath_no_mat_icon)))
            if no_mat_icon:
                no_mat_icon.click()
        except Exception as e:
            MolerTest.info(e)
            MolerTest.info(traceback.format_exc())
        finally:
            MolerTest.info('Node {} is expanded!'.format(id_of_node))

    @DevNJ_ASIR_Selenium.catch_exception
    @DevNJ_ASIR_Selenium.switch_to_tab('BTSes')
    def get_detected_bts(self):
        bts_ids = []
        wd = self.wd
        xpath_bts_list = '//div[@id="bts-list-content"]//tr'
        Wait(wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_bts_list)))
        detected_bts = wd.find_elements_by_xpath(xpath_bts_list)
        MolerTest.info('All detected BTS: {}'.format(detected_bts))
        for bts in detected_bts:
            bts_id = bts.get_attribute('id')
            bts_ids.append(bts_id)
        MolerTest.info('Found all bts ids: {}'.format(bts_ids))
        return bts_ids

    @DevNJ_ASIR_Selenium.catch_exception
    @DevNJ_ASIR_Selenium.switch_to_tab('BTSes')
    def get_detected_bts_detail(self, detected_bts_id):
        """
        Get detected bts detail

        :param detected_bts_id: str, which shown in 'BTS Configuration' of 'BTSes', for example: ASI-1/BTS-2
        """
        MolerTest.info('To check details of {}'.format(detected_bts_id))
        wd = self.wd
        xpath_bts_tr = '//tr[@id="{}"]'.format(detected_bts_id)
        Wait(wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_bts_tr)))
        bts_tr = wd.find_element_by_xpath(xpath_bts_tr)
        bts_tr.click()
        time.sleep(2)
        xpath_tech = '//mat-select[contains(@class, "technology")]/div/div/span/span'
        Wait(wd, self.ui_delay * 3).until(EC.visibility_of_element_located((By.XPATH, xpath_tech)))
        bts_detail = {}
        for field_id in ('mrbtsId', 'targetBtsId', 'rat'):
            if field_id == 'rat':
                xpath_value = '//mat-select[contains(@class, "technology")]/div/div/span/span'
                value = wd.find_element_by_xpath(xpath_value).text
            else:
                xpath_value = '//input[contains(@class, "{}")]'.format(field_id)
                value = wd.find_element_by_xpath(xpath_value).get_attribute('value')
            bts_detail[field_id] = value
        MolerTest.info('Get bts detail: {}'.format(bts_detail))
        return bts_detail

    def import_detected_configuration(self, mode='complete'):
        super(AsirWebEm, self).import_detected_configuration(mode)
        Wait(self.wd, self.ui_delay * 3).until(
            EC.invisibility_of_element_located((By.XPATH, '//div[@id="configuration-scope-modal"]')))
        MolerTest.info('Import detected configuration successfully!')

    @DevNJ_ASIR_Selenium.catch_exception
    @DevNJ_ASIR_Selenium.switch_to_tab('BTSes')
    def populate_bts_details(self, bts_id, para_dict):
        wd = self.wd
        bts_row = wd.find_element_by_xpath('//tr[@id="ASI-1/BTS-{}"]'.format(bts_id))
        bts_row.click()
        super(AsirWebEm, self).populate_bts_details(bts_id, para_dict)

    def modify_parameter(self, para=[]):
        MolerTest.info('Go to change parameter: {}'.format(para))
        self.enter_config_man('Edit')
        para_to_modify = []
        para_to_delete = []
        for item in para:
            if item['value']:
                para_to_modify.append(item)
            else:
                para_to_delete.append(item)
        if para_to_modify:
            super(AsirWebEm, self).modify_parameter(para_to_modify)
        if para_to_delete:
            self.delete_parameter(para_to_delete)

    @DevNJ_ASIR_Selenium.switch_to_tab('Parameter editor')
    @DevNJ_ASIR_Selenium.catch_exception
    def delete_parameter(self, list_para):
        xpath_search_par = "//*[@id='search-input']//input"
        xpath_search_table = "//app-search-results-table"
        xpath_rel_result_row_col_mo = ".//tr/td[1]"

        xpath_edit_table = "//app-parameters-view"
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
                            if cur_shown_mo_abbrs == last_shown_mo_abbrs:
                                raise Exception("No entry in search result after rolled")
                            MolerTest.info('Target MO not shown, need to scroll')
                            self.wd.execute_script("arguments[0].scrollIntoView();", last_mo_td)
                        break  # no exception, jump out of while retry_time iteration
                    except Exception as e:
                        MolerTest.info('retry time {}: {}'.format(retry_times, str(e)))
                        continue  # encouter exception, retry

            if not mo_td_found_in_search_result:
                raise Exception('No matched entry in search result')

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
            # find the button of the para
            mo_tr = mo_td_span_found.find_element(By.XPATH, "ancestor::tr")
            mo_tr_btn_delete = mo_tr.find_element(By.XPATH, ".//*[contains(@class,'parameterActions2')]")
            mo_tr_btn_delete.click()

    def activate_new_plan(self):
        self.enter_config_man('Edit', overwrite=False)
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

    def _select_value_in_mat_select(self, elem_mat_select, option, compare_method, check_required=True, timeout=2):
        """
        Override _select_value_in_mat_select function
        """
        timeout = int(timeout)
        tm_start = time.time()
        while time.time() < tm_start + timeout:
            if 'pulldown' not in elem_mat_select.get_attribute('class'):
                break
        assert ('pulldown' not in elem_mat_select.get_attribute(
            'class')), "Select parameter value is disabled"
        time.sleep(self.ui_delay)
        xpath_div_spinner_container = "//div[@class='spinner-container']"
        Wait(self.wd, 5).until_not(EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        elem_mat_select.find_element(By.XPATH, './/parent::div').click()
        time.sleep(self.ui_delay)
        all_mat_options = self.wd.find_elements(By.XPATH, "//mat-option")
        all_mat_options_text_list = []
        for mat_option in all_mat_options:
            all_mat_options_text_list.append(mat_option.text.strip())
            if compare_method(mat_option.text, option):
                assert (mat_option.get_attribute('aria-disabled') == 'false'), \
                    'Select option {} is disabled'.format(elem_mat_select)
                mat_option.click()

                if check_required:
                    assert (compare_method(elem_mat_select.text, option)), \
                        'Failed to set value to {}, current value is {}'.format(option, elem_mat_select.text.strip())
                break
        else:
            assert (option in all_mat_options_text_list), \
                'Select option {} not in {}'.format(
                    option, all_mat_options_text_list)

    @DevNJ_ASIR_Selenium.catch_exception
    def enter_config_man(self, sub_menu='Edit', overwrite=True, timeout=60):
        """
        Overwrite enter_config_man
        """
        timeout = int(timeout)
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
            self.wd.find_element(
                By.XPATH, _xpath_config_man_start_button).click()
            time.sleep(self.ui_delay)
            overwrite_btn = self.wd.find_elements(
                By.XPATH, _xpath_config_man_overwrite_button)
            if overwrite_btn:
                overwrite_btn[0].click()
        else:
            self.wd.find_element(
                By.XPATH, _xpath_config_man_continue_button).click()

        Wait(self.wd, timeout).until(EC.visibility_of_element_located(
            (By.XPATH, _xpath_config_man_header)))

        if sub_menu.lower() == 'save':
            Wait(self.wd, timeout).until(EC.visibility_of_element_located(
                (By.XPATH, _xpath_icon_backup_prepared)))
        else:
            Wait(self.wd, timeout).until(EC.element_to_be_clickable(
                (By.XPATH, _xpath_stepper_cancel_button)))

    @DevNJ_ASIR_Selenium.catch_exception
    def enter_topology_view(self, timeout=10):
        """
        Overwrite enter_topology_view
        """
        timeout = int(timeout)
        MolerTest.info('Go to topology view')
        _xpath_topology_button = "//*[@href='#/topology']"
        _xpath_topology_header = "//span[@id='topology-title']"
        topology_button = Wait(self.wd, timeout).until(EC.element_to_be_clickable((By.XPATH, _xpath_topology_button)))
        # topology_button = self.wd.find_element(By.XPATH, _xpath_topology_button)
        if 'selected' not in topology_button.get_attribute('class'):
            topology_button.click()
            self.wd.execute_script('window.scrollTo(400, 400)')
        else:
            MolerTest.info('Current view is topology.')
        Wait(self.wd, timeout).until(EC.visibility_of_element_located(
            (By.XPATH, _xpath_topology_header)))
