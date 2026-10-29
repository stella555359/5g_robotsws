# -*- coding: utf-8 -*-
import paramiko
import logging
import os
from collections import namedtuple
from robot.api import logger
from datetime import datetime
from contextlib import contextmanager
import zipfile
import xml.etree.ElementTree as ET
import subprocess


SNAPSHOT_TIMEOUT = 25 * 60

output_ssh = namedtuple('output_ssh', 'stdout return_code')


class RemoteCommandExecute(object):
    def __init__(self, remote_host, **kwargs):
        self.remote_host = remote_host
        self.ssh_username = kwargs.get('remote_host_username', 'ute')
        self.ssh_password = kwargs.get('remote_host_password', 'ute')
        self.ssh_port = int(kwargs.get('remote_host_ssh_port', 22))

    def _create_connected_ssh_client(self):
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(self.remote_host, self.ssh_port, self.ssh_username, self.ssh_password, timeout=30)
        return ssh_client

    def send_command(self, cmd, exit_prompt='$ '):
        ssh_client = self._create_connected_ssh_client()
        chan = ssh_client.get_transport().open_session()
        chan.exec_command(cmd)
        exit_status_ready = chan.exit_status_ready()
        new_response = chan.recv(8192)

        while not (exit_status_ready or new_response.endswith(('{}'.format(exit_prompt)).encode())):
            logging.debug(('{}'.format(new_response)))
            exit_status_ready = chan.exit_status_ready()
            new_response = chan.recv(8192)
        status = chan.recv_exit_status()
        ssh_client.close()
        return status

    def is_pingable(self, hostname):
        cmd = "ping -c 3 {}".format(hostname)
        return self.send_command(cmd) == 0

    def is_available(self, hostname, timeout):
        cmd = "ping -w {} {}".format(timeout, hostname)
        return self.send_command(cmd) == 0
