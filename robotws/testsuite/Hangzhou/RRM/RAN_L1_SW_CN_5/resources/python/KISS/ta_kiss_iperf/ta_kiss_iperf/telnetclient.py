# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import logging as log
import telnetlib


class TelnetClient(object):
    """ telnet
    """

    def __init__(self,
                 host,
                 username='',
                 password='',
                 port=23,
                 prompt=' >',
                 timeout=10):

        self.host = host
        self.port = int(port)
        self.prompt = prompt
        self.user = username
        self.passwd = password

        self.timeout = float(timeout)
        self.tn = None
        if self._connect():
            log.info("Telnet socket setup success!")
        else:
            log.info("Telnet socket setup failure!")
            raise Exception("Telnet socket setup failure!")

    def _connect(self):
        """Setup telnet connection
            Input parameters:
                n/a
            Output parameters:
                1. True if success.
                    False if failed.

        """
        tn = None

        try:
            tn = telnetlib.Telnet(self.host, self.port)
        except Exception as err:
            log.info("Open telnet connection error because of " + err)
            return False

        try:
            login_prompt = 'ogin: '
            log.info("Recv:" + tn.read_until(login_prompt, self.timeout))
            log.info("send: %s" % self.user)
            tn.write(str(self.user + '\r\n'))

            password_prompt = 'assword: '
            log.info("Recv:" + tn.read_until(password_prompt, self.timeout))
            log.info("send: %s" % self.passwd)
            tn.write(str(self.passwd + '\r\n'))

            log.info("Recv:" + tn.read_until(self.prompt, self.timeout))
            self.tn = tn

            return True
        except Exception as err:
            return False

    def _check_conn_status(self):
        """Check telnet connection status
            Input:
                N/A
            Output:
                'True' if connection is alive
                'False' if connection is down
        """
        if not self.tn:
            return False
        else:
            return True

    def execute(self, command):
        """ Execute command on locally.

        :param String command: command string
        """
        if not self._check_conn_status():
            log.info("Non telnet connection!")
            return False

        if command is None or command is False:
            log.info("No valid command to run.")
            return True
        else:
            command = str(command) + "\r\n"
            log.info(self.prompt + command)

        try:
            self.tn.write(command)
            log.info("send: %s" % command)
            p_Output = self.tn.read_until(self.prompt, self.timeout)
            log.info(p_Output)
            return p_Output

        except Exception as _err:
            log.info("Write command failure")
            return False

    def write(self, text):
        """ Write text locally.

        :param String text: text string
        """
        self.tn.write(text + '\r\n')

    def read_until_regexp(self, expect, timeout=60):
        """ Read until expect matches output.

        :param String expect: read until expect
        :param Integer timeout: read until timeout (default is 60)
        """
        return self.tn.read_until(expect, timeout)

    def get_file(self, src, destination):
        """ Get file locally.

        :param String src: source file
        :param String destination: destination file
        """
        log.info('get')

    def close(self):
        """ Close.
        """
        if self.tn:
            return self.tn.close()
        else:
            return True

    def read(self):
        """ Read all output locally.
        """
        return self.tn.read()

    def put_file(self, src, destination):
        """ Put file locally.

        :param String src: source file
        :param String destination: destination file
        """
        log.info('put')
