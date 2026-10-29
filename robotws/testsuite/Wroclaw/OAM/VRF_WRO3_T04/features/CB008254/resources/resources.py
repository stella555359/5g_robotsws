import re
from robot.api import logger
import xml.etree.ElementTree as ET
from taf.config.scf.interface import scf
import time
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys

scf = scf()


def modify_scf(mrbts, dict_name, base_scf_path):
    scf.load_scf(file_path=base_scf_path)
    if scf.is_list_in_object(dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(mrbts),
                             list_name="remoteSyslogConfig"):
        scf.save_scf("new_scf.xml")
        return "new_scf.xml"
    else:
        scf.add_list_to_scf(dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(mrbts),
                            list_name="remoteSyslogConfig")
        scf.add_item_to_list(dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(mrbts),
                             list_name="remoteSyslogConfig", elements=dict_name)
        scf.save_scf("new_scf.xml")
        return "new_scf.xml"


def compare_serial_numbers(BTS_SN, file_SN):
    SN = file_SN[36:]
    formated_file_SN = SN.replace(":", "")
    return BTS_SN[2:].strip(), formated_file_SN.upper().strip()


def get_cn(issuedTo):
    place = issuedTo.find("CN = ")
    return issuedTo[place + 5:].split(",")[0]


def analyze_xml(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/field[@name="tls.handshake"]/'
                          'field[@name="tls.handshake.certificates"]/field[@name="tls.handshake.certificate"]/'
                          'field[@name="x509af.signedCertificate_element"]/field[@name="x509af.subject"]/'
                          'field[@name="x509af.rdnSequence"]'):
        cert1.append(i.attrib)
    return cert1


def find_ecdhe_ciphers(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/field[@name="tls.handshake"]/'
                          'field[@name="tls.handshake.ciphersuite"]'):
        logger.console(i.attrib)
        logger.console(i.tag)
        cert1.append(i.attrib)
    return cert1


def find_ciphers(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/field[@name="tls.handshake"]/'
                          'field[@name="tls.handshake.ciphersuites"]/field[@name="tls.handshake.ciphersuite"]'):
        cert1.append(i.attrib)
    return cert1


def find_supported_groups(xml_path):
    cert = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/field[@name="tls.handshake"]/'
                          'field[@name=""]/'
                          'field[@name="tls.handshake.extensions_supported_groups"]/'
                          'field[@name="tls.handshake.extensions_supported_group"]'):
        logger.console(i.attrib)
        logger.console(i.tag)
        cert.append(i.attrib)
    return cert


def analyze_xml_operator(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/field[@name="tls.handshake"]/'
                          'field[@name="tls.handshake.certificates"]/field[@name="tls.handshake.certificate"]/'
                          'field[@name="x509af.signedCertificate_element"]/field[@name="x509af.signature_element"]'):
        cert1.append(i.attrib)
    return cert1


def cert_from_bts(path_in_xml):
    cert_bts = path_in_xml.partition("commonName=")[2]
    cert_bts = list(cert_bts.split(','))
    return cert_bts


def check_if_cert_is_expired(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]field[@name="tls.alert_message"]/'
                          'field[@name="tls.alert_message.desc"]'):
        cert1.append(i.attrib)
    return cert1


def strip_release_name(release_name):
    release_name_strip = re.sub(r'\D', '', release_name)
    return release_name_strip


def login_via_webem_with_ldap_credentials(address, login, password, parameter):
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
    WebDriverWait(browser, 60).until(EC.presence_of_element_located((By.XPATH, '//button[@type="button" '
                                                                               'and contains(., "Confirm")]'))).click()
    time.sleep(10)
    address_to_commissioning = address + "/#/configuration/parameters-editor"
    browser.get(address_to_commissioning)
    time.sleep(5)
    param = browser.find_element_by_xpath('//input[@placeholder="Search all"]')
    param.send_keys(parameter)
    param.send_keys(Keys.ENTER)
    browser.find_element_by_xpath('//button[@ui-tooltip="Delete parameter"]').click()
    browser.find_element_by_xpath('//button[@ui-tooltip="Validate Plan"]').click()
    time.sleep(5)
    browser.find_element_by_xpath('//button[@ui-tooltip="Activate Plan"]').click()
    WebDriverWait(browser, 60).until(EC.presence_of_element_located((By.XPATH, '//button[@type="button" '
                                                                               'and contains(., "Execute")]'))).click()
    WebDriverWait(browser, 120).until(EC.element_to_be_clickable((By.XPATH, '//button[@type="button" '
                                                                            'and contains(., "Close")]'))).click()
    browser.close()
    return browser
