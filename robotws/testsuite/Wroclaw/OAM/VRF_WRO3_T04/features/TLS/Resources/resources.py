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


def find_ciphers(xml_path):
    logger.console("Collecting ciphersuites in pcap")
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/field[@name="tls.handshake"]/'
                          'field[@name="tls.handshake.ciphersuites"]/field[@name="tls.handshake.ciphersuite"]'):
        cert1.append(i.attrib)
    return cert1


def find_supported_groups(xml_path):
    logger.console("Collecting supported groups in pcap")
    cert = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/field[@name="tls.handshake"]/'
                          'field[@name="tls.handshake.extension"]/'
                          'field[@name="tls.handshake.extensions_supported_groups"]/'
                          'field[@name="tls.handshake.extensions_supported_group"]'):
        logger.console(i.attrib)
        logger.console(i.tag)
        cert.append(i.attrib)
    return cert


def get_certificate_from_pcap(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/field[@name="tls.handshake"]/'
                          'field[@name="tls.handshake.certificates"]/field[@name="tls.handshake.certificate"]/'
                          'field[@name="x509af.signedCertificate_element"]/field[@name="x509af.subject"]/'
                          'field[@name="x509af.rdnSequence"]'):
        cert1.append(i.attrib)
    return cert1


def get_cn(issuedTo):
    place = issuedTo.find("CN = ")
    return issuedTo[place + 5:].split(",")[0]
