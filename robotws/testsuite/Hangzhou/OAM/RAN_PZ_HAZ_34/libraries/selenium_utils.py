import os
import time
from selenium.webdriver.common.by import By
from taf.selenium.gnb.oam.coam.classical import classical
from taf.selenium.gnb.oam.coam.classical.pages.login_management import CoamLoginPage
from taf.selenium.gnb.oam.core import core
from robot.libraries.BuiltIn import BuiltIn
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC


output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")


def COAM_WEBUI_Click_Button(xpath, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    CoamLoginPage(driver, output_dir).click_enabled_element(
        (By.XPATH, xpath), timeout)


def COAM_WEBUI_Wait_For_Visibility(xpath, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    CoamLoginPage(driver, output_dir).wait_for_visibility(
        (By.XPATH, xpath), timeout)


def COAM_WEBUI_Wait_For_Enable(xpath, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    CoamLoginPage(driver, output_dir).wait_for_enable(
        (By.XPATH, xpath), timeout)


def COAM_WEBUI_Get_Element_Text(xpath, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    return CoamLoginPage(driver, output_dir).get_text_by_xpath(xpath, timeout)


def COAM_WEBUI_Get_Element_Attribute(xpath, attr_name, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    return CoamLoginPage(driver, output_dir).get_attribute_by_xpath(xpath, attr_name, timeout)


def COAM_WEBUI_Move_To_Element(xpath, driver_obj="${driver}"):
    driver = BuiltIn().get_variable_value(driver_obj)
    CoamLoginPage(driver, output_dir).perform_element_hover_by_xpath(xpath)


def COAM_WEBUI_Scroll_To_Element(xpath, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    elem = CoamLoginPage(
        driver, output_dir).driver.find_element_by_xpath(xpath)
    CoamLoginPage(driver, output_dir).driver.execute_script(
        "arguments[0].scrollIntoView();", elem)


def COAM_WEBUI_Input_Value(xpath, text, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    CoamLoginPage(driver, output_dir).insert_text_to_enable_element(
        (By.XPATH, xpath), text, timeout)


def COAM_WEBUI_Input_Value_And_Enter(xpath, text, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    CoamLoginPage(driver, output_dir).insert_text_to_enable_element_and_enter(
        (By.XPATH, xpath), text, timeout)


def COAM_WEBUI_Select_Checkbox(xpath, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    CoamLoginPage(driver, output_dir).select_checkbox_by_xpath(xpath, timeout)


def COAM_WEBUI_Unselect_Checkbox(xpath, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    CoamLoginPage(driver, output_dir).unselect_checkbox_by_xpath(
        xpath, timeout)


def COAM_WEBUI_Execute_Script(script, driver_obj="${driver}", timeout=60):
    driver = BuiltIn().get_variable_value(driver_obj)
    return CoamLoginPage(driver, output_dir).driver.execute_script(script)


def Login_RDNet_Authentication_Portal(url, username='to5gran', password='3edc%TGB', alias='RDNET'):
    # driver = CustomWebDriverFirefox(output_dir)
    # driver.get(url)

    driver = core().create_firefox_web_driver(download_dir=output_dir, name=alias)
    core().set_scope(alias=alias, scope='global')
    driver.get(url)
    WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located((By.XPATH, "//input[@id='user']")))
    userelem = driver.find_element(*(By.XPATH, "//input[@id='user']"))
    userelem.send_keys(Keys.CONTROL + 'a')
    userelem.send_keys(Keys.BACKSPACE)
    userelem.send_keys(username)

    WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located((By.XPATH, "//input[@id='passwd']")))
    passwdelem = driver.find_element(*(By.XPATH, "//input[@id='passwd']"))
    passwdelem.send_keys(Keys.CONTROL + 'a')
    passwdelem.send_keys(Keys.BACKSPACE)
    passwdelem.send_keys(password)

    WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//input[@id='submit']")))
    driver.find_element(*(By.XPATH, "//input[@id='submit']")).click()

    WebDriverWait(driver, 10).until(EC.visibility_of_element_located(
        (By.XPATH, "//div[@id='message_cont']")))


def Logout_RDNet_Authentication_Portal(connection='RDNET'):
    driver = core().get_alias_value(alias=connection)
    driver.close()


if __name__ == "__main__":
    print("used for debug.")
