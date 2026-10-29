import re
import os
import time
import socket
import tempfile
import paramiko
from functools import wraps
from robot.api import logger
from selenium import webdriver
from taf.ul.selenium.netact import *
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.support.ui import WebDriverWait as Wait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains


class DevNJ_NetAct_Selenium(object):
    """ Library for NetAct WebEm Test with Selenium
    This Library is for open and login to the NetAct WebEM and do operations
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

        :param virtual_enable: True for browser is invisible while False browser is visible
        :param ui_delay: A delay time (in seconds) for WebEm UI, if feel the WebEM respond slow, can enlarge this value
        :param ui_delay: A timeout time (in seconds) waiting for WebEm UI response, if feel the WebEM respond slow,
            can enlarge this value
        :param debug: For debug purpose, that run the python file without robot framework

        Examples:
        Library    ../Resources/python/DevNJ_NetAct_Selenium.py  virtual_enable=${FALSE}
        """

        self.ui_delay = ui_delay
        self.ui_timeout = ui_timeout
        self.virtual_enable = virtual_enable
        self.selenium_netact = netact()
        self.wd = None
        self.debug = debug
        self.firefox_driver = r"/opt/ute/geckodriver/geckodriver"
        self.options = webdriver.FirefoxOptions()
        self.screenshot_dir = tempfile.mkdtemp(
            prefix='{}_screenshots_'.format(self.__class__.__name__))
        logger.info("DevNJ_NetAct_Selenium Init, virtual_enable is {}, screenshot dir {}"
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

    def clean_browser(self, browser='firefox'):
        """
        clean_browser function,  clean reamined webdriver and Firefox process,
            usually used in Suite Setup
        :param browser: browser process partial name
        Examples:
        | clean_browser |
        """
        cmd = "ps -ef | grep -v 'grep' | grep {} | awk '{{print $2}}' | sudo xargs kill -9".format(
            browser)
        logger.info(cmd, also_console=True)
        os.system(cmd)

    def wait_loading_spinner(self, timeout):
        """
        wait_loading_spinner function, wait for the wait spinner appear and disappear.
        :param timeout: minimum time slot to wait for web page response
        """
        _WAIT_SPINNER = '//*[@id="waitingPanelIcon"]'
        wait = Wait(self.wd, timeout)
        try:
            loading_spinner = wait.until(EC.visibility_of_element_located((By.XPATH, _WAIT_SPINNER)))
        except TimeoutException:
            loading_spinner = None
        if loading_spinner:
            wait = Wait(self.wd, timeout)
            wait.until(EC.invisibility_of_element_located((By.XPATH, _WAIT_SPINNER)))

    @catch_exception
    def login_netact(self, url=None, username='omc', password='omc', start_page='Folder'):
        """
        login NetAct Web page function, setup NetAct selenium object and login

        :param url: URL of the NetAct Web Page
        :param username: NetAct Web Page user name
        :param password: NetAct Web Page user password
        :param start_page: Indicates whether to enter the default "Show applications by folder"
             or switch to "Show all applications" after logging in to NetAct. Value could be 'Folder' or 'All'

        Examples:
        | login_netact | url=https://srnclab1013lbwas.srnblr.nsn-rdnet.net/startpage/# |
        | ...  username=omc | password=Medsql!_1893 |
        """
        logger.info("DevNJ_NetAct_Selenium login", also_console=True)
        logger.info("virtual_enable:{}".format(self.virtual_enable), also_console=True)

        if self.debug:
            logger.info("debug Selenium adopted", also_console=True)
            self.wd = webdriver.Firefox(
                self.firefox_driver, firefox_options=self.options)
        else:
            logger.info("taf Selenium adopted", also_console=True)
            self.selenium_netact = netact()
            if self.virtual_enable:
                logger.info("enable_virtual_display", also_console=True)
                self.selenium_netact.enable_virtual_display()
            self.wd = self.selenium_netact._driver

        self.wd.implicitly_wait(15)

        try:
            self.wd.get(url)
        except Exception as e:
            logger.info("Retry wd.get after exception {}".format(str(e)), also_console=True)
            self.clean_browser()
            time.sleep(5)
            self.wd.get(url)

        self.selenium_netact.login(url=url, username=username, password=password)
        self.selenium_netact.switch_to_page(page_name="Start Page")
        # Switch to "Show all applications" page if start_page='all'
        if start_page.lower() == 'all':
            logger.info("Switch to 'Show all applications' page", also_console=True)
            self.selenium_netact.wait_for_visibility(elem_xpath="//a[@id='linkShowAppFolder']")
            self.selenium_netact.click_button(button_xpath="//a[@id='linkShowAppFolder']")
            self.selenium_netact.wait_for_visibility(elem_xpath="//span[text()='Show all applications']")
            self.selenium_netact.click_button(button_xpath="//span[text()='Show all applications']")

    @catch_exception
    def logout_netact(self):
        """
        logout NetAct Web Page function
        Examples:
        | logout_netact |
        """
        logger.info("DevNJ_NetAct_Selenium logout", also_console=True)
        self.selenium_netact.logout()
        if self.virtual_enable and self.selenium_netact:
            self.selenium_netact.disable_virtual_display()

        time.sleep(10)

    @catch_exception
    def get_load_usage_status(self, load_list=None, mo_type="MRBTS", filter_dict=None, timeout=10):
        """
        keyword get_load_usage_status, According to the filter_dict provided by the user,
        In the NetAct Software Manager - Network Operations subpage, firstly filter Mo type,
        then filter Task type and Status, and got the filter results.
        If load in load_list is included in the filter results, MO DN/Task type/Status of the load will be returned;
        otherwise, none will be returned.
        :param load_list: the load list which user want to return task execution status
        :param mo_type: MO Type, default is MRBTS
        :param filter_dict: filter task type and status,
                            e.g. filter_dict = {task_type: [Provision, Download], status: [Ongoing, Queued]}
        :param timeout: Minimum time slot to wait for web page response
        :return: return_result_dict

        Examples:
        Example1:
        | ${task_list} | Create List | Download |
        | ${status_list} | Create List | Failed |
        | ${filter_dict} | Create Dictionary | task_type=${task_list} | status=${status_list} |
        | ${load_list} | Create List | SBTS22R3_ENB_9990_220328_000005 | SBTS22R3_ENB_9990_220328_000006 |
        | ${result} | Get Load Usage Status | load_list=${load_list} | mo_type=MRBTS | filter_dict=${filter_dict} |
        """
        _MO_TYPE = '//input[@id="TViewCombo:cccomboboxField"]'
        _TASK_TYPE = '//*[@id="taskTypeFilterId_comboButton_id"]'
        _STATUS = '//*[@id="taskStatusFilterId_comboButton_id"]'
        _TASK_TYPE_APPLY_BUTTON = '//*[@id="TView:taskTypeFilterId_apply_button"]'
        _STATUS_APPLY_BUTTON = '//*[@id="TView:taskStatusFilterId_apply_button"]'
        _FILTER_TABLE = '//span[@id="TView:pgTableContent"]/div/table'
        _NEXT_PAGE = '//table[@cellpadding="0"]/tbody/tr/td[@class="columnCenter"]' \
                     '/div/table/tbody/tr/td//img[contains(@id,"next")]'

        return_result_dict = {}

        try:
            assert load_list, "load_list is not provided"
            assert filter_dict, "filter_dict is not provided"
            self.selenium_netact.open_configuration_software_manager()
            self.selenium_netact.switch_to_page(page_name='Software Manager')
            self.selenium_netact.switch_to_network_operations()
            self.selenium_netact.wait_for_visibility(elem_xpath=_MO_TYPE)
            self.selenium_netact.write_value_and_enter(input_xpath=_MO_TYPE, value=mo_type)
            self.wait_loading_spinner(timeout=timeout)
            self.selenium_netact.click_button(button_xpath=_TASK_TYPE)
            for task_type_item in filter_dict['task_type']:
                _TASK_TYPE_CHECKBOX = '//table[@id="TView:taskTypeFilterId_multicheckbox_id"]' \
                                      '/tbody/tr/td//label[contains(text(), "{}")]'.format(task_type_item)
                self.selenium_netact.select_checkbox(checkbox_xpath=_TASK_TYPE_CHECKBOX)
            self.selenium_netact.click_button(button_xpath=_TASK_TYPE_APPLY_BUTTON)
            self.wait_loading_spinner(timeout=timeout)
            self.selenium_netact.click_button(button_xpath=_STATUS)
            for status_item in filter_dict['status']:
                _STATUS_CHECKBOX = '//table[@id="TView:taskStatusFilterId_multicheckbox_id"]' \
                                   '/tbody/tr/td//label[contains(text(), "{}")]'.format(status_item)
                self.selenium_netact.select_checkbox(checkbox_xpath=_STATUS_CHECKBOX)
            self.selenium_netact.click_button(button_xpath=_STATUS_APPLY_BUTTON)
            self.wait_loading_spinner(timeout=timeout)

            filter_result_dict = {}
            # find total pages number
            _PAGE_NUMBER = '//table[@cellpadding="0"]/tbody/tr/td[@class="columnCenter"]/div/table/tbody/tr/td/span'
            page_total = self.selenium_netact.get_elem_text(elem_xpath=_PAGE_NUMBER)
            page_list = re.findall(r"\d+", page_total)
            page = int(page_list[0])
            logger.info("Total filtered page number is {}".format(page), also_console=True)

            for page_index in range(page):
                try:
                    filter_table = self.wd.find_element_by_xpath(_FILTER_TABLE)
                    filter_rows = filter_table.find_elements_by_tag_name('tr')
                    rows = len(filter_rows)
                    logger.info("In page {} total rows are {}".format(page_index+1, rows), also_console=True)
                    if rows > 0:
                        for i in range(1, rows + 1):
                            _TASK_TYPE_RESULT = '//span[@id="TView:pgTableContent"]' \
                                                '/div/table/tbody/tr[{}]/td[contains(@id,"colTasksType")]'.format(i)
                            _SW_PACKAGE_RESULT = '//span[@id="TView:pgTableContent"]/div/table/' \
                                                 'tbody/tr[{}]/td[contains(@id,"colTasksVersionId")]'.format(i)
                            _MO_DN_RESULT = '//span[@id="TView:pgTableContent"]' \
                                            '/div/table/tbody/tr[{}]/td[contains(@id,"colTasksDN")]'.format(i)
                            _STATUS_RESULT = '//span[@id="TView:pgTableContent"]' \
                                             '/div/table/tbody/tr[{}]/td[contains(@id,"colTasksStatus")]'.format(i)
                            self.selenium_netact.wait_for_visibility(elem_xpath=_TASK_TYPE_RESULT, timeout=timeout)
                            task_type_result = self.selenium_netact.get_elem_text(elem_xpath=_TASK_TYPE_RESULT)
                            self.selenium_netact.wait_for_visibility(elem_xpath=_SW_PACKAGE_RESULT, timeout=timeout)
                            sw_package_result = self.selenium_netact.get_elem_text(elem_xpath=_SW_PACKAGE_RESULT)
                            self.selenium_netact.wait_for_visibility(elem_xpath=_MO_DN_RESULT, timeout=timeout)
                            mo_dn_result = self.selenium_netact.get_elem_text(elem_xpath=_MO_DN_RESULT)
                            self.selenium_netact.wait_for_visibility(elem_xpath=_STATUS_RESULT, timeout=timeout)
                            status_result = self.selenium_netact.get_elem_text(elem_xpath=_STATUS_RESULT)

                            if sw_package_result:
                                load_name = str(sw_package_result)
                                if not filter_result_dict.get(load_name):
                                    filter_result_dict[load_name] = []
                                filter_result_list = {'task_type': task_type_result, 'MO_DN': mo_dn_result,
                                                      'status': status_result}
                                filter_result_dict[load_name].append(filter_result_list)
                    else:
                        break
                except Exception as e:
                    logger.info("Exception in get filter_result_dict is {}".format(str(e)), also_console=True)
                    break
                self.selenium_netact.wait_for_visibility(elem_xpath=_NEXT_PAGE)
                self.selenium_netact.click_button(button_xpath=_NEXT_PAGE)
                self.wait_loading_spinner(timeout=timeout)
                time.sleep(3)

            if filter_result_dict:
                logger.info("filter_result_dict: {}".format(filter_result_dict))
                for load in load_list:
                    load_alias = load.split("ENB")[-1]
                    load_name = str(load)
                    flag = 0
                    for filter_load in filter_result_dict:
                        filter_load_alias = filter_load.split("ENB")[-1]
                        filter_load_name = str(filter_load)
                        if load_alias == filter_load_alias:
                            return_result_dict[load_name] = filter_result_dict.get(filter_load_name)
                            flag = 1
                    if not flag:
                        return_result_dict[load_name] = None
            else:
                for load in load_list:
                    load_name = str(load)
                    return_result_dict[load_name] = None

            return return_result_dict

        except Exception as ex:
            raise Exception("Exception of get_load_usage_status is {}".format(ex.__class__))

        finally:
            self.selenium_netact.close_page(page_name='Software Manager')

    def delete_load_from_netact_backend_server(self, ip=None, username='omc', password='omc',
                                               load_path='/d/oss/global/swmanager/swm_temp', load_list=None):
        """
        delete_load_from_netact_backend_server function, delete the loads in Netact backend server.

        :param ip: IP of the NetAct Node
        :param username: NetAct ssh user name
        :param password: NetAct ssh user password
        :param load_path: It is usually /d/oss/global/swmanager/swm_temp. if there is a special path,
                          please specify it
        :param load_list: the load list which user want to delete from backend server
        :return: None

        Examples:
        | ${load_list} | Create List | SBTS22R3_ENB_9990_220328_000005 | SBTS22R3_ENB_9990_220328_000006 |
        | Delete Load From Netact Backend Server | ip=10.41.146.68 | username=omc | password=omc |
        | ...  load_list=${load_list} |
        """
        try:
            logger.info("Establishing ssh connection to {}".format(ip), also_console=True)
            netact_server = paramiko.SSHClient()
            netact_server.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            netact_server.connect(hostname=ip, username=username, password=password)
            logger.info("Connected to the server {}".format(ip), also_console=True)

            ftp_client = netact_server.open_sftp()
            listfile = ftp_client.listdir(load_path)
            logger.info("Currently following files are in the NetAct Node path {}: {}".format(load_path, listfile),
                        also_console=True)
            for load in load_list:
                load_alias = load.split("ENB")[-1]
                flag = 0
                for zip_file in listfile:
                    if load_alias in zip_file:
                        logger.info("zip_file {}".format(zip_file), also_console=True)
                        ftp_client.remove(path=load_path+"/"+zip_file)
                        flag = 1
                        break
                if not flag:
                    logger.info("[warn] load {} not found in netact server!".format(load), also_console=True)
                else:
                    logger.info("[delete done] load {} deleted!".format(load), also_console=True)
            ftp_client.close()
            netact_server.close()

        except socket.gaierror:
            logger.error("Target NetAct Server Not Available!")

        except FileNotFoundError:
            logger.error("Target load_path Not Found!")

        except paramiko.ssh_exception.AuthenticationException:
            logger.error("User name or password Error!")

        except Exception as e:
            logger.error("Exception in connecting to the server is {}".format(e.__class__))

    @catch_exception
    def delete_load_from_netact_frontend(self, load_list=None, mo_type="MRBTS", timeout=10):
        """
        delete_load_from_netact_frontend function, delete the loads in Netact Web Page.

        :param load_list: the load list which user want to delete from frontend webpage
        :param mo_type: MO Type, default is MRBTS
        :param timeout: Minimum time slot to wait for web page response
        :return: None

        Examples:
        | ${load_list} | Create List | SBTS22R3_ENB_9990_220328_000005 | SBTS22R3_ENB_9990_220328_000006 |
        | Delete Load From NetAct Frontend | load_list=${load_list} |
        """
        _MO_TYPE = '//input[@id="embTreeFrm:cccomboboxField"]'
        _EXPAND_ALL = '//*[@id="embTreeFrm:swTreeExpandAllButton"]'
        _PACKAGE_TABLE_ID = '//div[@id="embTreeFrm:swTree:#REGULAR__PACKAGES#::remoteRepositoryTreeNode:childs"]'
        _PACKAGE_ALL = '//div[@id="embTreeFrm:swTree:#REGULAR__PACKAGES#' \
                       '::remoteRepositoryTreeNode:childs"]/div/table/tbody/tr/td[3]'
        _DELETE_BUTTON = '//*[@id="embTreeFrm:swTreeDeleteButton"]'
        _CONFIRM_BUTTON = '//input[@id="embTreeFrm:mpConfirmDeletemsgBtnScriptAndActionOk"]'
        _REFRESH_BUTTON = '//input[@id="embTreeFrm:swTreeRefreshButton"]'
        _RETURN_MESSAGE = '//span[@class="rich-messages-label info_application_text"]'

        try:
            assert load_list, "load_list is not provided"
            self.selenium_netact.open_configuration_software_manager()
            self.selenium_netact.switch_to_page(page_name='Software Manager')
            self.selenium_netact.wait_for_enable(elem_xpath="//span[text()='Software Archive']")
            self.selenium_netact.click_button(button_xpath="//span[text()='Software Archive']")
            self.selenium_netact.wait_for_enable(elem_xpath=_MO_TYPE, timeout=12*timeout)
            self.selenium_netact.write_value_and_enter(input_xpath=_MO_TYPE, value=mo_type)
            self.wait_loading_spinner(timeout=timeout)
            self.selenium_netact.wait_for_visibility(elem_xpath=_EXPAND_ALL)
            self.selenium_netact.click_button(button_xpath=_EXPAND_ALL)
            self.wait_loading_spinner(timeout=timeout)

            package_table = self.wd.find_element_by_xpath(_PACKAGE_TABLE_ID)
            package_total = package_table.find_elements_by_tag_name('tbody')
            package_number = len(package_total)

            if package_number > 0:
                for load in load_list:
                    load_alias = load.split("ENB")[-1]
                    flag = 0
                    for i in range(package_number):
                        try:
                            _PACKAGE = _PACKAGE_ALL + '//label[contains(text(), "{}")]'.format(load_alias)
                            check_result = self.selenium_netact.get_elem_text(elem_xpath=_PACKAGE)
                            logger.info("Checking Load:{} In NetAct Software Archive".format(check_result))
                            package = self.wd.find_element(By.XPATH, _PACKAGE)
                            ActionChains(self.wd).move_to_element_with_offset(package, 1, 0).click().perform()
                            self.wait_loading_spinner(timeout=timeout)
                            self.selenium_netact.click_button(button_xpath=_DELETE_BUTTON)
                            wait = Wait(self.wd, timeout)
                            try:
                                confirm_button = wait.until(
                                    EC.visibility_of_element_located((By.XPATH, _CONFIRM_BUTTON)))
                            except TimeoutException:
                                confirm_button = None
                            if not confirm_button:
                                self.selenium_netact.click_button(button_xpath=_DELETE_BUTTON)
                            self.selenium_netact.wait_for_visibility(elem_xpath=_CONFIRM_BUTTON)
                            self.selenium_netact.click_button(button_xpath=_CONFIRM_BUTTON)
                            logger.info("Load {} is being deleted, please wait for the deletion result".format(load),
                                        also_console=True)
                            flag = 1
                            self.selenium_netact.wait_for_visibility(elem_xpath=_RETURN_MESSAGE, timeout=12*timeout)
                            delete_result = self.selenium_netact.get_elem_text(elem_xpath=_RETURN_MESSAGE)
                            rm_char = r'[-­]'
                            delete_result = re.sub(rm_char, "", delete_result)
                            if "deleted successfully" in delete_result:
                                logger.info("{}".format(delete_result), also_console=True)
                            else:
                                logger.info("Software package {} deleted failed".format(load), also_console=True)
                            self.wait_loading_spinner(timeout=timeout)
                            self.selenium_netact.click_button(button_xpath=_REFRESH_BUTTON)
                            self.wait_loading_spinner(timeout=6*timeout)

                        except NoSuchElementException:
                            if flag == 0:
                                logger.info("Load {} is not exist !".format(load), also_console=True)
                            break

                        except TimeoutException:
                            logger.error("NetAct Internal Error")

                        except Exception as e:
                            logger.error("Exception of delete_load_from_netact_frontend is {}".format(e.__class__))

            else:
                logger.info("No Package Load Exist In The NetAct Web Page!", also_console=True)

        finally:
            self.selenium_netact.close_page(page_name='Software Manager')
