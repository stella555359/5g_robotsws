# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
from robot.api import logger

from .config import CONSOLES
from .local import LocalConsole
from .ssh import SshConsole, FspConsole, BbmodConsole, FsmConsole, IphyConsole
from .telnet import TelnetConsole, AaShellConsole


class Console(object):
    """ Consoles factory class """

    def __new__(cls, console_name, **kwargs):
        """ Factory-like creation of console handler
        :param str console_name: name of console
        :return: specific instance of console handler
        :rtype: LocalConsole|TelnetConsole|AaShellConsole|SshConsole|FspConsole|FsmConsole|BbmodConsole|IphyConsole
        """
        console_name_key = console_name.split('-')[0]
        logger.debug('Console name key: {}'.format(console_name_key))
        handler = globals()[CONSOLES.get(console_name_key).get('handler')](console_name=console_name, **kwargs)
        logger.debug('Resolved console handler: {}'.format(type(handler)))
        return handler
