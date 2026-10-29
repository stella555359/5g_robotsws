# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""

import os
import sys
import time
import logging
import paramiko

logger = logging.getLogger()


class c_smf_client(object):

    def __init__(self, host='', port=22, username='ipsl', password='system123', ipslip='10.69.67.169'):
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.conn = None
        self.shell = None
        self.interval = 2
        self.ipslip = ipslip
        self.diameter_peer = ''
        self.config_p1 = 'configure mobile-gateway profile diameter-peer'

    def connect(self):
        logger.info(f'Connect SMF: {self.host}')
        if self.conn is None:
            self.conn = paramiko.SSHClient()
            self.conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.conn.connect(self.host, self.port, self.username, self.password)
            self.shell = self.conn.invoke_shell()
        return self

    def disconnect(self):
        if self.conn:
            self.conn.close()

    def exec_command(self, command='', delay=0):
        if self.shell:
            logger.info('--- >  ' + command)
            self.shell.send(command + '\n')
            if delay:
                time.sleep(delay)
            else:
                time.sleep(self.interval)
            resp = self.shell.recv(9999).decode('iso-8859-1')
            for line in resp.splitlines():
                logger.info('<----  ' + line)
            return resp

    def logout(self):
        self.exec_command('logout')

    def show_status(self):
        show_s = 'show mobile-gateway pdn ref-point-peers gx peer'
        output = self.exec_command(f'{show_s} {self.ipslip} port 13868').splitlines()
        lines = [x for x in output if 'Dia Peer Prof'.lower() in x.lower()]
        if lines:
            self.diameter_peer = lines[0].split(':')[-1].strip()
            logger.info(f'Found diameter_peer: {self.diameter_peer}')

    def shutdown_ipsl(self):
        self.exec_command(f'{self.config_p1} "{self.diameter_peer}" peer {self.ipslip} port 13868 shutdown', 3)

    def start_ipsl(self):
        self.exec_command(f'{self.config_p1} "{self.diameter_peer}" peer {self.ipslip} port 13868 no shutdown', 3)

    def restart_ipsl(self):
        self.connect()
        try:
            self.show_status()
            self.shutdown_ipsl()
            self.show_status()
            self.start_ipsl()
            self.show_status()
        finally:
            self.logout()
            self.disconnect()


if __name__ == '__main__':
    # SmfClient('10.110.163.34').restart_ipsl()
    # SmfClient('10.70.123.2').restart_ipsl()  # 10.70.123.67
    client = SmfClient('10.110.163.34')
    client.connect()
    client.show_status()
    client.disconnect()
