from taf.selenium.sc.pages.view import ViewPanel
from taf.selenium.sc.pages.navigatable_page import NavigatablePage
from taf.selenium.sc.pages.configuration_management.edit_configuration import ManagedObjectsPanel
from taf.selenium.sc.pages.configuration_management.configuration_menu import ConfigurationMenu
from taf.selenium.sc.common.exceptions import ActivateException
from taf.selenium.sc.pages.modals import ValidationErrorOccurred
from taf.selenium.sc.pages.login_management import LoginPage
from robot.libraries.BuiltIn import BuiltIn
from selenium.common.exceptions import TimeoutException, ElementClickInterceptedException
from selenium.webdriver.common.by import By
import logging
import time


builtin = BuiltIn()
username = builtin.get_variable_value("${tl.gnbs[0].cu.oam_http_connection_details.username}")
password = builtin.get_variable_value("${tl.gnbs[0].cu.oam_http_connection_details.password}")


class AsirWebEMOperations:
    def __init__(self):
        self.activation = None
        self.parameterEditor = None
        self.login = None
        self.screenshot_dir = builtin.get_variable_value("${OUTPUTDIR}")

    def setup(self, driver):
        self.activation = AsirActivationPage(driver)
        self.parameterEditor = AsirParameterEditorPage(driver)
        self.login = AsirLoginPage(driver, self.screenshot_dir)

    def set_asir_parameter_value(self, dist_name, abbreviation, new_value, prevalidate=False, timeout=60):
        self.parameterEditor.navigate_to()
        self.parameterEditor.set_parameter(dist_name, abbreviation, new_value, prevalidate=prevalidate,
                                           timeout=int(timeout))
        time.sleep(5)
        self.activation.navigate_to()
        return self.activation.activate_parameter()

    def close_no_rw_session_allowed_warning_window(self, timeout=60):
        return self.activation.close_warning_window(timeout=timeout)

    def enter_login_credentials(self):
        self.login.enter_login_credentials(username, password)


class AsirParameterEditorPage(NavigatablePage):
    _TARGET_TAB_XPATH = '//button[@id="paramEditor-step-button"]'
    _MENU_ROUTE_LIST = ["commissioning", "Edit", _TARGET_TAB_XPATH]

    def __init__(self, driver):
        super(AsirParameterEditorPage, self).__init__(driver, ConfigurationMenu)
        self._managed_object_panel = ManagedObjectsPanel(driver)
        self._edit_configuration_panel = AsirParameterEditorPanel(driver)

    def _get_route_list(self):
        return self._MENU_ROUTE_LIST

    def set_parameter(self, dist_name, abbreviation, new_value, prevalidate=False, timeout=60):
        self._managed_object_panel.go_to_target_object(dist_name, timeout)
        self._edit_configuration_panel.edit_parameter(abbreviation, new_value, timeout)
        if prevalidate:
            self._edit_configuration_panel.prevalidate()


class AsirParameterEditorPanel(ViewPanel):
    _EDIT_BASE_XPATH = '//*[@id="{}"]'
    _EDIT_INPUT = _EDIT_BASE_XPATH + '//*[contains(@class, "parameterValue")]'
    _EDIT_SELECT = _EDIT_BASE_XPATH + '//mat-select'
    _SELECT_OPTION = '//mat-option[contains(@id, "parameter")]//*[contains(text(), "{}")]'
    _MOUSE_DOWN_SCRIPT = 'document.getElementById("{}").dispatchEvent(new Event("mousedown"))'

    _PREVALIDATION_BUTTON = '//*[@id="run-prevalidation-btn"]/div'

    def __init__(self, driver):
        super(AsirParameterEditorPanel, self).__init__(driver)

    def edit_parameter(self, abbreviation, new_value, timeout):
        self.wait_for_visibility((By.XPATH, self._EDIT_BASE_XPATH.format(abbreviation)))
        elem = self.wait_for_enable((By.XPATH, self._EDIT_BASE_XPATH.format(abbreviation)))
        self.driver.execute_script("arguments[0].scrollIntoView();", elem)
        time.sleep(1)
        self.driver.execute_script(self._MOUSE_DOWN_SCRIPT.format(abbreviation))

        time.sleep(1)
        if self.element_exists((By.XPATH, self._EDIT_SELECT.format(abbreviation))):
            self._select_target_parameter(abbreviation, new_value, timeout)
        else:
            self.insert_text_to_enabled_element((By.XPATH, self._EDIT_INPUT.format(abbreviation)), new_value)
        time.sleep(1)

    def _select_target_parameter(self, abbreviation, new_value, timeout):
        self.select_element_from_dropdown_list_by_text_and_click(
            new_value,
            (By.XPATH, self._EDIT_SELECT.format(abbreviation, new_value)),
            (By.XPATH, self._SELECT_OPTION.format(new_value)),
            timeout
        )

    def prevalidate(self):
        self.click_enabled_element(locator=(By.XPATH, self._PREVALIDATION_BUTTON), timeout=10)


class AsirActivationPage(NavigatablePage):
    _TARGET_TAB_XPATH = '//button[@id="activation-step-button"]'
    _MENU_ROUTE_LIST = ["commissioning", "Edit", _TARGET_TAB_XPATH]

    def __init__(self, driver):
        super(AsirActivationPage, self).__init__(driver, ConfigurationMenu)
        self._activation_panel = ActivationPagePanel(driver)

    def _get_route_list(self):
        return self._MENU_ROUTE_LIST

    def activate_parameter(self, as_full_configuration=False, previous=False, timeout=60):
        return self._activation_panel.activate_parameter(as_full_configuration, previous, timeout)

    def close_warning_window(self, timeout=60):
        return self._activation_panel.close_warning_window(timeout)


class ActivationPagePanel(ViewPanel):
    _ACTIVATE_FULL_CHECKBOX = '//*[@id="activate-as-full-checkbox-input"]'
    _ACTIVATE_FULL_LABEL = '//*[@for="activate-as-full-checkbox-input"]//span[@class="mat-checkbox-label"]'
    _RUN_ACTIVATION_BUTTON = '//button[@id="run-activation-btn"]'
    _ACTIVATED = 'The configuration has been activated'
    _ACTIVATED_XPATH = '//*[@id="commissioning-wrapper"]//*[@class="information-row"]'
    _FINISH_BUTTON = '//*[@id="stepper-finish-button"]'
    _ERROR_TITLE = 'Validation errors occurred'
    _RESET_MSG_TITLE_XPATH = '//*[@id="reset-message-title"]'
    _RESET_TITLE = 'ASiR reset is required to activate this configuration'
    _PREVIOUS = '//button[@id="stepper-previous-button"]'
    _NEXT = '//button[@id="stepper-next-button"]'
    _RESET_ABANDON = 'ASiR reset abandoned'
    _RESET_START = 'ASiR reset will start'
    _ERROR_MSG = 'activate failed, please check the screenshot for detail'
    _CLOSE_BUTTON = "//button[normalize-space(text())='Close']"

    def __init__(self, driver):
        super(ActivationPagePanel, self).__init__(driver)

    def _operate_if_reset_needed(self, previous, timeout=60):
        try:
            self.wait_for_text_present_in_element((By.XPATH, self._RESET_MSG_TITLE_XPATH),
                                                  self._RESET_TITLE,
                                                  timeout)
            logging.info(self._RESET_TITLE)
            if previous:
                self.click_enabled_element((By.XPATH, self._PREVIOUS))
                return self._RESET_ABANDON
            else:
                self.click_enabled_element((By.XPATH, self._NEXT))
                return self._RESET_START
        except TimeoutException:
            return

    def _operate_validation_error_modal(self):
        validation_error_modal = ValidationErrorOccurred(self.driver)
        if validation_error_modal.wait_until_validation_error_modal_appear():
            validation_error_modal.close()
            raise TimeoutException('Validation errors occurred')
        raise ActivateException(self._ERROR_MSG)

    def activate_parameter(self, as_full_configuration=False, previous=False, timeout=60):
        self.wait_for_visibility_by_xpath(self._RUN_ACTIVATION_BUTTON, timeout)
        self.select_checkbox_by_specified_status(as_full_configuration,
                                                 self._ACTIVATE_FULL_CHECKBOX,
                                                 self._ACTIVATE_FULL_LABEL)
        self.click_enabled_element((By.XPATH, self._RUN_ACTIVATION_BUTTON), timeout)

        try:
            self.click_enabled_element((By.XPATH, self._FINISH_BUTTON), 5)
        except ElementClickInterceptedException:
            pass
        except TimeoutException:
            pass

        return self._ACTIVATED

    def close_warning_window(self, timeout=60):
        self.click_enabled_element((By.XPATH, self._CLOSE_BUTTON), timeout)
        try:
            self.click_enabled_element((By.XPATH, self._FINISH_BUTTON), 5)
        except TimeoutException:
            pass


class AsirLoginPage(LoginPage):
    """
    A class manages login page, login function included.
    """
    _INPUT_USERNAME_XPATH = '//input[@*="Username"]'
    _INPUT_PASSWORD_XPATH = '//input[@*="Password"]'
    _LOGIN_BUTTON_XPATH = '//button[contains(text(), "Log in")]'
    _TOPOLOGY_TITLE = '//*[@id="topology-title"]'
    SESSION_LOCKED_XPATH = '//*[text()="Session locked"]'
    PASSWD_INPUT_XPATH = '//input[@id="screen-lock-password-input"]'
    LOGO_XPATH = '//*[@class="logo" and @name="Nokia"]'

    def __init__(self, webdriver, screenshot_dir):
        super(AsirLoginPage, self).__init__(webdriver)
        self._screenshot_dir = screenshot_dir

    def enter_login_credentials(self, username, password, timeout=60):
        self._insert_username((By.XPATH, self._INPUT_USERNAME_XPATH), username, timeout)
        self._insert_password((By.XPATH, self._INPUT_PASSWORD_XPATH), password, timeout)
        self._click_login_button((By.XPATH, self._LOGIN_BUTTON_XPATH), timeout)
