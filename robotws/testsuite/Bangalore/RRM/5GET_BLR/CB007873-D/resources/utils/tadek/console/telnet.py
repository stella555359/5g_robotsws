# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
from ..connections import Telnet

from .base import BaseConsole
from .config import ENB_IP


class TelnetConsole(BaseConsole):
    """ Class for handling general telnet console """

    def __init__(self, **kwargs):
        super(TelnetConsole, self).__init__()
        self._host = kwargs.get('address')
        self._port = kwargs.get('port')
        self._prompt = kwargs.get('prompt')

    def execute_command(self, command):
        """ Executes command in telnet console
        :param str command: command that will be executed
        :return: output of command
        :rtype: str
        """
        with Telnet(self._host, self._port, self._prompt).session() as tel:
            return tel.execute_command(command)


class AaShellConsole(TelnetConsole):
    """ Class for handling AaShell (Telnet) console """

    def __init__(self, **kwargs):
        super(AaShellConsole, self).__init__(address=ENB_IP,
                                             port=15007,
                                             prompt='AaShell> ')
