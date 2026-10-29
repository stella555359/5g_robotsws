# -*- coding: utf-8 -*-
"""
:created on: 2020-01-11

:copyright: Nokia
:author: Yao Yonna
:contact: yonna.yao@nokia-sbell.com
"""

import logging
from contextlib import contextmanager
from .sshconnection import SshConnection


class tak_core(object):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self._log = logging.getLogger(__name__)

    def execute(self, cmd, host=None, user='ute', pwd='ute', port=22):
        with self._sshconnection(host, user, pwd, port) as ssh_client:
            out, err, rc = ssh_client.execute(cmd)
            self._log.debug("out:{}; err:{}; rc:{}".format(out, err, rc))
            return out, err, rc

    def read(self, host=None, user='ute', pwd='ute', port=22):
        with self._sshconnection(host, user, pwd, port) as ssh_client:
            return ssh_client.read()

    def read_command_output(self, return_stdout=True, return_stderr=False, return_rc=False,
                            host=None, user='ute', pwd='ute', port=22):
        with self._sshconnection(host, user, pwd, port) as ssh_client:
            return ssh_client.read_command_output(return_stdout, return_stderr, return_rc)

    def read_until_regex(self, regex, timeout=None, host=None, user='ute', pwd='ute', port=22):
        with self._sshconnection(host, user, pwd, port) as ssh_client:
            return ssh_client.read_until_regex(regex, timeout)

    def start_command(self, cmd, host=None, user='ute', pwd='ute', port=22):
        with self._sshconnection(host, user, pwd, port) as ssh_client:
            ssh_client.start_command(cmd)

    def write(self, text, host=None, user='ute', pwd='ute', port=22):
        """write command"""
        with self._sshconnection(host, user, pwd, port) as ssh_client:
            ssh_client.write(text)

    def get_file(self, src, dst, host=None, user='ute', pwd='ute', port=22):
        """get file"""
        with self._sshconnection(host, user, pwd, port) as ssh_client:
            return ssh_client.get_file(src, dst)

    def put_file(self, src, dst, host=None, user='ute', pwd='ute', port=22):
        """put file"""
        with self._sshconnection(host, user, pwd, port) as ssh_client:
            return ssh_client.put_file(src, dst)

    @contextmanager
    def _sshconnection(self, host, user, psw, port):
        """ssh connection operation.
                """
        host = '127.0.0.1' if host is None else host
        logging.info("host:{}".format(host))
        ssh_client = SshConnection(host, user, psw, port)
        try:
            ssh_client._setup()
            yield ssh_client
        finally:
            ssh_client._teardown()
