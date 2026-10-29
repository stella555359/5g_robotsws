# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
from abc import abstractmethod, ABCMeta
from future.utils import with_metaclass


class BaseConsole(with_metaclass(ABCMeta, object)):
    """ Abstract class for consoles"""

    def __init__(self, console_name='', **kwargs):
        """
        :param str console_name: name of console
        :param kwargs:
        """
        self._console_name = console_name

    @abstractmethod
    def execute_command(self, command):
        """ Abstract placeholder """
        pass
