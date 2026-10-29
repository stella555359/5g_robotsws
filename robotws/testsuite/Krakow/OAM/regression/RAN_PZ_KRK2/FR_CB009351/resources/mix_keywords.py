# -*- coding: utf-8 -*-
"""
Mix keywords for FRSMZ cOAM EI
author: xiaobing.guan@nokia-sbell.com
maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com

"""
import logging
import time
from taf.transport.ssh import ssh

ssh = ssh()


PACKAGE_FORMAT_MAPPING = {r"SBTS00_ENB_(\d+)_(\d+)_(\d+)_.+zip": "SBTS21B_ENB_{preIndex}_{branchIndex}_{buildIndex}",
                          r"AirScale-12.(\d+).(\d+).*.zip": "5G21B_GNB_0012_{branchIndex}_{buildIndex}",
                          r"AirScale-0.(\d+).(\d+).*.zip": "5G22R2_GNB_0000_{branchIndex}_{buildIndex}",
                          r"AirScale-10.(\d+).(\d+).*.zip": "5G20B_GNB_0010_{branchIndex}_{buildIndex}"}


def connect_to_gnb(gnb_ip, username='toor4nsn', passwd='oZPS0POrRieRtu', alias='signature_check'):
    ssh.connect_to(hostname=gnb_ip, username=username, password=passwd, alias=alias)


def disconnect_to_gnb(alias='signature_check'):
    ssh.disconnect(connection=alias)


def get_frip(alias='signature_check'):
    frip = ssh.execute('cat /ffs/run/config/FRIps.txt', connection=alias).split(';')[2]
    return frip


def rename_ru_file(ru_ip, alias='signature_check', user=None, password=None, CMD='ls -al', reboot='reboot'):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    passwd = None
    if password is not None:
        passwd = ''.join((password, '\n'))
    node = '1'
    channel.send('hostname\n')
    time.sleep(1)
    hostname = channel.recv(65536)
    if '4a' in str(hostname):
        node = '2'
    channel.send('lxc-attach -n 0x{}018\n'.format(node))
    time.sleep(2)
    logging.debug('Logging to Node output: {}'.format(channel.recv(65536)))
    if user is None:
        cmd = ''.join(('ssh -o HostKeyAlgorithms=+ssh-rsa ', ru_ip, '\n'))
    else:
        cmd = ''.join(('ssh -o HostKeyAlgorithms=+ssh-rsa ', user, '@', ru_ip, '\n'))
    channel.send(cmd)
    time.sleep(6)
    hostname = channel.recv(65536)
    if 'yes/no/[fingerprint]' in str(hostname):
        channel.send('yes\n')
        hostname = channel.recv(65536)
    logging.debug('SSH on RU output: {}'.format(hostname))
    if passwd is not None:
        channel.send(passwd)
        time.sleep(3)
        logging.debug('RU password output: {}'.format(channel.recv(65536)))
    channel.send(CMD + '\n')
    time.sleep(2)
    logging.debug('Move files command output: {}'.format(channel.recv(65536)))
    channel.send(reboot + '\n')
    time.sleep(2)
    logging.debug('Reboot output: {}'.format(channel.recv(65536)))


def check_fault_signature(alarm_info, fault_id, fault_name, check_sig=True, **signature):
    if isinstance(alarm_info, dict):
        alarm_list = alarm_info['requestMessage']
    elif isinstance(alarm_info, list):
        alarm_list = alarm_info
    else:
        print('Invalid data input!')
        return False
    fault_signature = {}
    for alarm in alarm_list:
        if not check_sig and alarm['faultId'] == int(fault_id):
            return True
        if alarm['faultId'] == int(fault_id) and alarm['faultName'] == fault_name:
            fault_signature = alarm['faultSignature']
    status = set(signature.items()).issubset(fault_signature.items())
    return status
