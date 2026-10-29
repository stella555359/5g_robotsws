from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support import ui
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.features.classical.CB009842.resources.test_constants import \
    LMF_CONNECTION_DETAILS


class NlsPage:
    chrome_options = Options()
    chrome_options.add_argument('--ignore-ssl-errors=yes')
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--ignore-certificate-errors')
    chrome_options.add_argument('--no-sandbox')

    def __init__(self):
        self.driver = webdriver.Chrome(chrome_options=self.chrome_options,
                                       executable_path="/opt/ute/chromedriver/chromedriver")
        self.driver_wait = ui.WebDriverWait(self.driver, 30)
        self.login_input = (By.ID, "username")
        self.password_input = (By.ID, "password")
        self.combobox_dropdown = (By.CSS_SELECTOR, "[id='selectitem-component-input'][role='combobox']")
        self.initial_values = {}

    def log_to_nls(self):
        self.driver.get(f"https://{LMF_CONNECTION_DETAILS['hostname']}:8080/mals60_term/configuration/parameters")
        log_info_to_console("Logging to NLS")
        login_input = self.driver_wait.until(EC.visibility_of_element_located(self.login_input))
        login_input.send_keys('root')
        self.driver.find_element(*self.password_input).send_keys('nls72NSN' + Keys.ENTER)

    def go_to_parameters(self, parameters_query):
        combobox = self.driver_wait.until(EC.visibility_of_element_located(self.combobox_dropdown))
        combobox.click()
        parameters_query_button = self.driver_wait.until(EC.visibility_of_element_located(
            (By.XPATH, f"//*[@role='option' and contains(., '{parameters_query}')]")))
        parameters_query_button.click()

    def change_parameter_value(self, parameter_name, value):
        parameter_row_selector = (By.XPATH, f"//div[@role='row' and .//div[@role='gridcell'"
                                            f" and contains(., '{parameter_name}')]]")
        parameter_row = self.driver_wait.until(EC.visibility_of_element_located(parameter_row_selector))
        parameter_input = parameter_row.find_element(By.XPATH, ".//input")
        parameter_value = parameter_input.get_attribute("value")
        log_info_to_console(f"Current Value of {parameter_name} : {parameter_value}")
        save_button = (By.XPATH, ".//button[@aria-label='save-changes']")
        if parameter_value != value:
            if not self.initial_values.get("parameter_name"):
                self.initial_values[parameter_name] = parameter_value
            log_info_to_console(f"Changing Value of {parameter_name} to {value}")
            input_value_lenght = len(parameter_input.get_attribute("value"))
            parameter_input.click()
            for _ in range(input_value_lenght):
                parameter_input.send_keys(Keys.BACKSPACE)
                parameter_input.send_keys(Keys.DELETE)
            parameter_input.send_keys(value)
            button = ui.WebDriverWait(parameter_row, 5).until(EC.visibility_of_element_located(save_button))
            button.click()
        new_value = parameter_input.get_attribute("value")
        assert new_value == value, f"Value of {parameter_name} was not changed to {value}"

    def restore_initial_parameters(self):
        if self.initial_values:
            log_info_to_console("Restoring original values to all changed nls parameters")
            for parameter, value in self.initial_values.items():
                self.change_parameter_value(parameter, value)

    def close(self):
        self.restore_initial_parameters()
        log_info_to_console("Closing NLS connection")
        self.driver.quit()
