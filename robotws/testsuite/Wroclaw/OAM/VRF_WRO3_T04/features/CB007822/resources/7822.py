import xml.etree.ElementTree as ET
import time
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.chrome.options import Options


def analyze_tls13(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]'):
        cert1.append(i.attrib)
    return cert1


def compare_two_fingerprints(s, t):
    t = list(t)
    try:
        for x in s:
            t.remove(x)
    except ValueError:
        return False
    return not t


def successful_login_via_chrome_asir_webem(address, login, password):
    options = Options()
    options.add_argument('ignore-certificate-errors')
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_experimental_option("detach", True)
    browser = webdriver.Chrome(chrome_options=options)
    browser.get(address)
    time.sleep(1)
    log = browser.find_element_by_xpath('//input[@placeholder="Username"]')
    log.send_keys(login)
    pas = browser.find_element_by_xpath('//input[@type="password"]')
    pas.send_keys(password)
    browser.find_element_by_xpath('//button[@type="button" and contains(., "Login")]').click()
    time.sleep(20)
    # browser.find_element_by_xpath('//button[@type="button" and contains(., "Confirm")]').click()
    # time.sleep(30)
    try:
        browser.find_element_by_xpath('//button[contains(., "Close")]').click()
    except NoSuchElementException:
        time.sleep(1)
    try:
        browser.find_element_by_xpath('//button[contains(., "Accept")]').click()
    except NoSuchElementException:
        time.sleep(1)
    return browser


def lss_server_user(browser, username, newpas, confirmpas):
    # browser.find_element_by_xpath('//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]').click()
    # a = ActionChains(browser)
    # mouse = browser.find_element_by_xpath('//span[text()="Snapshot"]')
    # a.move_to_element(mouse).perform()
    # time.sleep(3)
    browser.find_element_by_xpath('//a[@aria-label="Snapshot Collection"]').click()
    time.sleep(2)
    browser.find_element_by_xpath('//span[text()="LSS User Configuration"]').click()
    user = browser.find_element_by_xpath('//input[@id="username"]')
    user.send_keys(username)
    pas1 = browser.find_element_by_xpath('//input[@id="newPassword"]')
    pas1.send_keys(newpas)
    pas2 = browser.find_element_by_xpath('//input[@id="confirmPassword"]')
    pas2.send_keys(confirmpas)
    time.sleep(5)
    browser.find_element_by_xpath('//span[text()="Save"]').click()
    time.sleep(15)


def lss_server_define(br, ip, port):
    br.find_element_by_xpath('//a[@aria-label="Snapshot Collection"]').click()
    time.sleep(2)
    br.find_element_by_xpath('//span[text()="Snapshot Configuration"]').click()
    # br.find_element_by_tag_name('p-dropdown').click()
    # time.sleep(2)
    # br.find_element_by_xpath('//span[text()="netact"]').click()
    time.sleep(2)
    # br.find_element_by_xpath('//span[text()="lss"]').click()
    adr = br.find_element_by_xpath('//label[contains(.,"Local symptoms server IP address:")]/following::input[1]')
    adr.clear()
    time.sleep(2)
    adr.send_keys(ip)
    p = br.find_element_by_xpath('//label[contains(.,"Local symptoms server IP port number:")]/following::input[1]')
    p.clear()
    time.sleep(2)
    p.send_keys(port)
    if br.find_element_by_xpath('//button[@type="button" and contains(., "Send")]').is_enabled():
        br.find_element_by_xpath('//button[@type="button" and contains(., "Send")]').click()
    time.sleep(30)


def collect_remote_snap(browser):
    browser.find_element_by_xpath('//a[@aria-label="Snapshot Collection"]').click()
    time.sleep(2)
    browser.find_element_by_xpath('//label[text()="Remote"]').click()
    browser.find_element_by_xpath('//button[@type="button" and contains(., "Collect Snapshot")]').click()
    time.sleep(180)
    browser.close()


def local_symptoms_server_configuration(ipaddress, ipport):
    params_list = [
        {"parameterName": "lssConfig",
         "operation": "update",
         "value": [{"lssIPaddress": ipaddress,
                    "lssPortNo": ipport}]}
    ]
    return params_list
