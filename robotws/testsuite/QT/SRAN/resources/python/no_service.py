#!/usr/bin/python3

import xml.etree.ElementTree as ET
import sys
import uuid
import hashlib
import logging
import subprocess
import hmac
import socket
from time import sleep
from binascii import hexlify
import requests
import argparse


def wait_for_target_to_be_not_reachable(hostname, timeout=200):
    for i in range(int(timeout) // 3 + 1):
        if _is_pingable(hostname):
            logging.debug('Target {} is reachable'.format(hostname))
        else:
            logging.info('Target {} stopped to be reachable'.format(hostname))
            return
    raise RuntimeError('Target did not stop to be reachable in {}'.format(timeout))


def wait_for_target_to_be_reachable(hostname, timeout=200):
    for i in range(int(timeout) // 3 + 1):
        if _is_pingable(hostname):
            logging.debug('Target {} is reachable'.format(hostname))
            return
        else:
            logging.info('Target {} stopped to be reachable'.format(hostname))
    raise RuntimeError('Target did not start to be reachable in {}'.format(timeout))


def _is_pingable(hostname):
    return _run('ping -c 3 {}'.format(hostname))


def _run(cmd):
    proc = subprocess.Popen(cmd,
                            universal_newlines=True,
                            stderr=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            shell=True)
    out, err = proc.communicate()

    logging.info(str(out.strip()))
    if err:
        logging.error(str(err.strip()))
    return proc.returncode == 0


def get_hostname():
    return socket.gethostname()


def generate_nonce():
    """ generate random clientside nonce """
    return uuid.uuid4().hex + uuid.uuid4().hex


def setup_session(client, server):
    """ gets the url from the server ignoring the respone, just to get session cookie set up """
    url = "http://%s/" % server
    response = client.get(url)
    response.raise_for_status()
    # will have to debug this one as without delay here it was throwing a buffering exception on one of the machines
    sleep(1)


def get_server_token(client, server):
    """ retrieves server token """
    url = "http://%s/api/webserver/SesTokInfo" % server
    token_response = client.get(url).text
    root = ET.fromstring(token_response)
    return root.findall('./SesInfo')[0].text


def get_server_token_verification(client, server):
    """ retrieves server token """
    url = "http://%s/api/webserver/SesTokInfo" % server
    token_response = client.get(url).text
    root = ET.fromstring(token_response)
    return root.findall('./TokInfo')[0].text


def get_client_proof(clientnonce, servernonce, password, salt, iterations):
    """ calculates server client proof (part of the SCRAM algorithm) """
    msg = "%s,%s,%s" % (clientnonce, servernonce, servernonce)
    salted_pass = hashlib.pbkdf2_hmac(
        'sha256', password, bytearray.fromhex(salt), iterations)
    client_key = hmac.new(b'Client Key', msg=salted_pass,
                          digestmod=hashlib.sha256)
    stored_key = hashlib.sha256()
    stored_key.update(client_key.digest())
    signature = hmac.new(msg.encode('utf_8'),
                         msg=stored_key.digest(), digestmod=hashlib.sha256)
    client_key_digest = client_key.digest()
    signature_digest = signature.digest()
    client_proof = bytearray()
    i = 0
    while i < client_key.digest_size:
        client_proof.append(client_key_digest[i] ^ signature_digest[i])
        i = i + 1
    return hexlify(client_proof)


def login(client, server, user, password):
    """ logs in to the router using SCRAM method of authentication """
    setup_session(client, server)
    cookie = get_server_token(client, server)
    token = get_server_token_verification(client, server)
    url = "http://%s/api/user/challenge_login" % server
    request = ET.Element('request')
    username = ET.SubElement(request, 'username')
    username.text = user
    clientnonce = generate_nonce()
    firstnonce = ET.SubElement(request, 'firstnonce')
    firstnonce.text = clientnonce
    mode = ET.SubElement(request, 'mode')
    mode.text = '1'
    headers = {'Content-type': 'text/html',
               '__RequestVerificationToken': token}
    response = client.post(url, data=ET.tostring(
        request, encoding='utf8', method='xml'), headers=headers)
    scram_data = ET.fromstring(response.text)
    servernonce = scram_data.findall('./servernonce')[0].text
    salt = scram_data.findall('./salt')[0].text
    iterations = int(scram_data.findall('./iterations')[0].text)
    verification_token = response.headers['__RequestVerificationToken']
    login_request = ET.Element('request')
    clientproof = ET.SubElement(login_request, 'clientproof')
    clientproof.text = get_client_proof(
        clientnonce, servernonce, password, salt, iterations).decode('UTF-8')
    finalnonce = ET.SubElement(login_request, 'finalnonce')
    finalnonce.text = servernonce
    headers = {'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
               '__RequestVerificationToken': verification_token}

    url = "http://%s/api/user/authentication_login" % server
    result = client.post(url, data=ET.tostring(
        login_request, encoding='utf8', method='xml'), headers=headers)
    verification_token = result.headers['__RequestVerificationTokenone']
    return verification_token


def reboot(client, server, user, password):
    """ reboots the router :) """
    verification_token = login(client, server, user, password)
    url = "http://%s/api/device/control" % server
    headers = {'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
               '__RequestVerificationToken': verification_token}
    client.post(
        url, data='<?xml version:"1.0" encoding="UTF-8"?><request><Control>1</Control></request>', headers=headers)
    print("Reboot done")


def change_network_to_3g(client, server, user, password):
    """ change network to 3G """
    verification_token = login(client, server, user, password)
    url = "http://%s/api/net/net-mode" % server
    headers = {'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
               '__RequestVerificationToken': verification_token}
    xml = '<?xml version:"1.0" encoding="UTF-8"?>'
    request = '<NetworkMode>02</NetworkMode><NetworkBand>3FFFFFFF</NetworkBand><LTEBand>7FFFFFFFFFFFFFFF</LTEBand>'
    client.post(
        url, data='{}<request>{}</request>'.format(
            xml, request), headers=headers)


def change_network_to_lte(client, server, user, password, band):
    """ change network to lte """
    verification_token = login(client, server, user, password)
    url = "http://%s/api/net/net-mode" % server
    headers = {'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
               '__RequestVerificationToken': verification_token}
    xml = '<?xml version:"1.0" encoding="UTF-8"?>'
    request = '<NetworkMode>03</NetworkMode><NetworkBand>3FFFFFFF</NetworkBand><LTEBand>{}</LTEBand>'.format(band)
    client.post(
        url, data='{}<request>{}</request>'.format(
            xml, request), headers=headers)


def main():
    """ main method """
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument('--router_ip', default=None)
    parser.add_argument('--username',  default=None)
    parser.add_argument('--password',  default=None)
    parser.add_argument('--lte_band',  default=None)
    args = parser.parse_args()
    password_bytes = bytes(args.password, 'utf-8')
    master = get_hostname()
    _router = args.router_ip
    _user = args.username
    _pass = password_bytes
    _lte_band = args.lte_band

    client = requests.Session()
    change_network_to_3g(client, _router, _user, _pass)
    reboot(client, _router, _user, _pass)
    # sleep(80)
    wait_for_target_to_be_not_reachable(_router, timeout=15)
    # wait_for_target_to_be_reachable(_router, timeout=30)
    sleep(45)
    client = requests.Session()
    change_network_to_lte(client, _router, _user, _pass, _lte_band)


if __name__ == "__main__":
    sys.exit(main())

# /* vim: set ts=4 sw=8 tw=0 noet :*
