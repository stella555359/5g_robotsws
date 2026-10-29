# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Civen Chen
:contact: civen.chen@nokia.com
:maintainer: Civen Chen
:contact: civen.chen@nokia.com
"""

from selenium import webdriver
from taf.selenium.gnb.oam.core.webdrivers import CustomWebDriverFirefox
from taf.selenium.gnb.oam.core.common import PagePart
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from pyvirtualdisplay import Display
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.select import Select
from selenium.webdriver.firefox.options import Options
import time


def rf_diagnostic_test_setup_aeqe(url, username='Nemuadmin', password='nemuuser', technology='nr',
                                  cells='All NR cells'):
    element_existance = True
    options = Options()
    options.add_argument('--headless')
    driver = webdriver.Firefox(options=options)
    driver.get(url)
    driver.find_element_by_id('login-username').send_keys(username)
    driver.find_element_by_id('login-password').send_keys(password)
    time.sleep(5)
    driver.find_element_by_xpath(
        '/html/body/login-root/div/login/div/div/div/div[1]/form/div[3]/p-button/button').click()
    time.sleep(30)
    driver.maximize_window()
    try:
        element = driver.find_element_by_id('modal-title')
    except Exception:
        element_existance = False
    if element_existance:
        driver.find_element_by_xpath(
            '/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div'
            '/ui-footer/div/ui-button[1]/button').click()
    driver.find_element_by_xpath('/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[6]/div/'
                                 'nav-menu-link/span/i[1]').click()
    time.sleep(2)
    tech_id = technology + '-aria'
    driver.find_element_by_xpath('/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[6]/div/'
                                 'ng-transclude/div/div[3]/nav-link/a').click()
    driver.find_element_by_id(tech_id).click()
    time.sleep(2)
    driver.find_element_by_xpath('//*[contains(@class, "rfDiagTestCell")]'
                                 '//*[contains(@class, "selected-label")]').click()
    time.sleep(2)
    driver.find_element_by_link_text(cells).click()
    driver.find_element_by_xpath('//*[contains(@a-text, "Start RF Diagnostic Test")]').click()
    time.sleep(60)
    driver.find_element_by_xpath('/html/body/main-view/div/div[1]/app-header/div[2]/'
                                 'user-account-management/nav-item/div/nav-menu-link/span').click()
    driver.find_element_by_xpath('/html/body/main-view/div/div[1]/app-header/div[2]/'
                                 'user-account-management/nav-item/div/ng-transclude/div/div/div[3]/'
                                 'ui-button[2]/button').click()
    driver.close()
