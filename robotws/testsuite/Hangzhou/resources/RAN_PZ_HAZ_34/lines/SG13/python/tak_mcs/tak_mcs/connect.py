# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Yao Chunhua
:contact: yonna.yao@nokia-sbell.com
"""


import logging
import six
from socket import socket, AF_INET, SOCK_STREAM


class SocketConnect(object):

    def __init__(self, ip, port=18888, timeout=90):
        """init
        """
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self.ip = ip
        self.port = port
        self.timeout = timeout
        self.tcpCli = None

    def connect_socket(self):
        """

        :return:
        """
        self.tcpCli = socket(AF_INET, SOCK_STREAM)
        self.tcpCli.settimeout(self.timeout)
        try:
            self.tcpCli.connect((self.ip, self.port))
        except Exception as e:
            raise Exception("socket connect to {}:{} fail, {}.".format(self.ip, self.port, e))

    def send_command(self, command):
        """

        :param command:
        :return:
        """
        try:
            self._log.debug("send command --> {}.".format(command))
            send_cmd = '{}\r\n'.format(command)
            if six.PY3:
                send_cmd = send_cmd.encode()
            self.tcpCli.send(send_cmd)
        except Exception as e:
            raise Exception(e)

    def receive_command(self):
        """

        :return:
        """
        try:
            received = self.tcpCli.recv(4096)
            self._log.debug("received <-- {}".format(received))
            if six.PY3:
                received = received.decode()
            return received
        except Exception as e:
            raise Exception(e)

    def close_socket(self):
        """

        :return:
        """
        self._log.debug("Close socket.")
        self.tcpCli.close()
