import selenium
from time import sleep
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from requests.packages import urllib3
from pyvirtualdisplay import Display


def Enable_Ipsec_Expert_Mode():
    # browser = webdriver.Firefox()
    display = Display(visible=0, size=(1024, 768))
    display.start()
    browser = webdriver.Chrome()
    # browser.maximize_window()
    browser.get('https://192.168.255.129')
    username = browser.find_element_by_name("userName").send_keys("developer")
    password = browser.find_element_by_name("password").send_keys("$developer#")
    password = browser.find_element_by_name("password").send_keys(Keys.RETURN)
    sleep(40)
    browser.find_element_by_class_name("modal-footer").text
    # browser.find_element_by_class_name("btn.btn-defaultBlue.btn-small").click()
    browser.find_element_by_xpath("/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div"
                                  "/div[3]/div/ui-footer/div/ui-button[1]").click()
    sleep(2)
    browser.find_element_by_xpath("/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[8]").click()
    sleep(2)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[8]/div/ng-transclude/div/div[7]").click()
    sleep(2)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/button[1]").click()
    sleep(10)
    browser.quit()
    return "Ipsec Expert Mode Enabled"


def Configure_Ipsec_Expert_Mode(ipsec_value=""):
    # browser = webdriver.Firefox()
    browser = webdriver.Chrome()
    # browser.maximize_window()
    browser.get('https://192.168.255.129')
    username = browser.find_element_by_name("userName").send_keys("developer")
    password = browser.find_element_by_name("password").send_keys("$developer#")
    password = browser.find_element_by_name("password").send_keys(Keys.RETURN)
    sleep(40)
    browser.find_element_by_class_name("modal-footer").text
    #    browser.find_element_by_class_name("btn.btn-defaultBlue.btn-small").click()
    browser.find_element_by_xpath(
        "/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div["
        "3]/div/ui-footer/div/ui-button[1]").click()
    sleep(2)
    browser.find_element_by_xpath("/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[8]").click()
    sleep(2)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[8]/div/ng-transclude/div/div[7]").click()
    sleep(2)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/div/ui-text-input[1]/div/input").clear()
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/div/ui-text-input[1]/div/input").send_keys(
        ipsec_value)
    sleep(35)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/button[3]").click()
    sleep(10)
    browser.quit()
    return "Ipsec Expert Mode Configuration Successful"


def Configure_Ipsec_Expert_Mode_and_logging_settings(expert_mode="", expert_logging=""):
    #    browser = webdriver.Firefox()
    display = Display(visible=0, size=(1024, 768))
    display.start()
    browser = webdriver.Chrome()
    # browser.maximize_window()
    browser.get('https://192.168.255.129')
    username = browser.find_element_by_name("userName").send_keys("developer")
    password = browser.find_element_by_name("password").send_keys("$developer#")
    password = browser.find_element_by_name("password").send_keys(Keys.RETURN)
    sleep(40)
    browser.find_element_by_class_name("modal-footer").text
    #    browser.find_element_by_class_name("btn.btn-defaultBlue.btn-small").click()
    browser.find_element_by_xpath(
        "/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div["
        "3]/div/ui-footer/div/ui-button[1]").click()
    sleep(2)
    browser.find_element_by_xpath("/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[8]").click()
    sleep(2)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[8]/div/ng-transclude/div/div[7]").click()
    sleep(2)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/div/ui-text-input[1]/div/input").clear()
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/div/ui-text-input[2]/div/input").clear()
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/div/ui-text-input[1]/div/input").send_keys(
        expert_mode)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/div/ui-text-input[2]/div/input").send_keys(
        expert_logging)
    sleep(35)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/button[3]").click()
    sleep(10)
    browser.quit()
    return "Ipsec Expert Mode Configuration Successful"


def Disable_Ipsec_Expert_Mode():
    #    browser = webdriver.Firefox()
    display = Display(visible=0, size=(1024, 768))
    display.start()
    browser = webdriver.Chrome()
    # browser.maximize_window()
    browser.get('https://192.168.255.129')
    username = browser.find_element_by_name("userName").send_keys("developer")
    password = browser.find_element_by_name("password").send_keys("$developer#")
    password = browser.find_element_by_name("password").send_keys(Keys.RETURN)
    sleep(40)
    browser.find_element_by_class_name("modal-footer").text
    # browser.find_element_by_class_name("btn.btn-defaultBlue.btn-small").click()
    browser.find_element_by_xpath(
        "/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div["
        "3]/div/ui-footer/div/ui-button[1]").click()
    sleep(2)
    browser.find_element_by_xpath("/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[8]").click()
    sleep(2)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[8]/div/ng-transclude/div/div[7]").click()
    sleep(2)
    browser.find_element_by_xpath(
        "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/ipsec-expert-mode/fieldset"
        "/button[2]").click()
    sleep(10)
    browser.quit()
    return "Ipsec Expert Mode Disabled"

# Enable_Ipsec_Expert_Mode()
# Configure_Ipsec_Expert_Mode("ipsec{ikelifetime[50]=3600s}")
# Configure_Ipsec_Expert_Mode_and_logging_settings("ipsec{ikelifetime[50]=3600s}","dmn=2|ike=2")
# Disable_Ipsec_Expert_Mode()
