import selenium
import time
import os
import re
from time import sleep
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from requests.packages import urllib3
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from pyvirtualdisplay import Display


def Start_WebEM_XDisplay():
    # enable browser logging
    display = Display(visible=0, size=(1024, 768))
    display.start()
    d = DesiredCapabilities.CHROME
    d['loggingPrefs'] = {'browser': 'ALL'}
    driver = webdriver.Chrome(desired_capabilities=d)
    # load some site
