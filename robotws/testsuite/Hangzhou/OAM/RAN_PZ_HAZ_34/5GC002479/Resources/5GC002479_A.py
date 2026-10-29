from selenium import webdriver
from taf.selenium.gnb.oam.core.webdrivers import CustomWebDriverFirefox
from taf.selenium.gnb.oam.core.common import PagePart
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from pyvirtualdisplay import Display
from selenium.webdriver.common.keys import Keys
import time

username_xpath = '//input[@placeholder="Username"]'
password_xpath = '//input[@placeholder="Password"]'
login_button_xpath = '//div[@class="login-buttons"]//button[contains(text(), "Login")]'
# login_button_xpath = '//div[@class="login-btn-container"]//span[contains(text(), "Login")]'
# option_xpath_sbts = '//*[contains(@class, "container")]//*[@*="Options"]'
option_xpath_sbts = '//*[@*="Options"]'
port_xpath_sbts = '//*[text()="Port"]//following-sibling::input'
# login_button_xpath_sbts = '//div[@class="login-btn-container"]//span[contains(text(), "Login")]'
# login_button_xpath_sbts = '//div[@class="ot-buttongroup"]//span[contains(text(), "Login")]'
login_button_xpath_sbts = '//span[contains(text(), "Login")]'
legal_statement_xpath = '//div[@class="modal-content"]'
confirm_button_xpath = '//div[@class="modal-content"]//ui-button[@a-text="Confirm"]/button'
user_count_view_xpath = '//user-account-management'
logout_xpath = '//div[@class="user-account-view"]//ui-button[@a-text="Logout"]'
dir = '/home/ute'


def createDiplay(width=1920, height=1280):
    return Display(visible=0, size=(width, height))


def enableDisplay(display):
    display.start()


def disableDisplay(display):
    display.stop()


def createDriver():
    return CustomWebDriverFirefox(dir)


def createPagePart(driver):
    return PagePart(driver)


def input_usr_and_pwd_then_click_login_button(driver, pagePart, url, usr, pwd, stream='gnb'):
    driver.get(url)
    if stream == 'sbts':
        pagePart.insert_text_to_enable_element((By.XPATH, username_xpath), usr, 60)
        pagePart.insert_text_to_enable_element((By.XPATH, password_xpath), pwd, 60)
#        pagePart.click_enabled_element((By.XPATH, option_xpath_sbts), 60)
#        pagePart.insert_text_to_enable_element((By.XPATH, port_xpath_sbts), 443, 60)
        pagePart.click_enabled_element((By.XPATH, login_button_xpath_sbts), 60)
    else:
        pagePart.insert_text_to_enable_element((By.XPATH, username_xpath), usr, 60)
        pagePart.insert_text_to_enable_element((By.XPATH, password_xpath), pwd, 60)
        pagePart.click_enabled_element((By.XPATH, login_button_xpath), 60)


def waitLegalStatementApper(pagePart, timeout=60):
    pagePart.wait_for_visibility((By.XPATH, legal_statement_xpath), timeout)


def confirmLegalStatement(pagePart):
    pagePart.click_enabled_element((By.XPATH, confirm_button_xpath), 60)


def logout(driver, pagePart):
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, user_count_view_xpath)))
    pagePart.wait_for_visibility((By.XPATH, user_count_view_xpath), 60)
    pagePart.click_enabled_element((By.XPATH, user_count_view_xpath), 60)

    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, logout_xpath)))
    pagePart.wait_for_visibility((By.XPATH, logout_xpath), 60)
    pagePart.click_enabled_element((By.XPATH, logout_xpath), 60)

    driver.close()


def SG1_coam_driver_open():
    display = createDiplay()
    enableDisplay(display)
    driver = createDriver()
    pagePart = createPagePart(driver)
    return display, driver,  pagePart


def SG1_coam_driver_close(driver, display):
    driver.close()
    display.stop()


def inputurl_and_wait_element(driver, pagePart, url):
    driver.get(url)
    pagePart.wait_for_visibility((By.XPATH, username_xpath), 60)


def waitForStartupPage(pagePart, timeout=60):
    _START_UP_VIEW_MODE = '//div[@class="modal-content"]//ui-modal[@*="BTS Start-up View"]'
    pagePart.wait_for_visibility((By.XPATH, _START_UP_VIEW_MODE), timeout)


def waitForRunTimeView(pagePart, timeout=60):
    _START_UP_VIEW_MODE = '//div[@class="system-section-content"]'
    pagePart.wait_for_visibility((By.XPATH, _START_UP_VIEW_MODE), timeout)
    _START_UP_VIEW_MODE = '//div[@class="radio-section"]'
    pagePart.wait_for_visibility((By.XPATH, _START_UP_VIEW_MODE), timeout)


def CLoseStartupPage(pagePart, timeout=60):
    _CLOSE_BUTTON_XPATH = '//div[@class="modal-content"]//ui-button[@a-text="Close"]/button'
    pagePart.click_enabled_element((By.XPATH, _CLOSE_BUTTON_XPATH), timeout)


def CreateWebDriver():
    display = createDiplay()
    enableDisplay(display)
    driver = webdriver.Firefox()
    PagePart = createPagePart(driver)
    return driver, PagePart


def NewTabAndLogin(driver, PagePart, index, url, usr, pwd, stream='gnb'):
    driver.execute_script("window.open('');")
    driver.switch_to.window(driver.window_handles[index])
    driver.get(url)
    try:
        if stream == 'sbts':
            PagePart.insert_text_to_enable_element((By.XPATH, username_xpath), usr, 60)
            PagePart.insert_text_to_enable_element((By.XPATH, password_xpath), pwd, 60)
#            pagePart.click_enabled_element((By.XPATH, option_xpath_sbts), 60)
#            pagePart.insert_text_to_enable_element((By.XPATH, port_xpath_sbts), 443, 60)
            PagePart.click_enabled_element((By.XPATH, login_button_xpath_sbts), 60)
        else:
            PagePart.insert_text_to_enable_element((By.XPATH, username_xpath), usr, 60)
            PagePart.insert_text_to_enable_element((By.XPATH, password_xpath), pwd, 60)
            PagePart.click_enabled_element((By.XPATH, login_button_xpath), 60)
    finally:
        print("exception")
    time.sleep(60)
