# -*- coding: utf-8 -*-
"""
:author: Bartosz Bugaj
:contact: bartosz.bugaj@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""

from abc import abstractmethod, ABCMeta
from future.utils import with_metaclass


class BaseSmuggler(with_metaclass(ABCMeta, object)):
    """ Abstract class for smugglers"""

    def __init__(self, smuggler_name='', **kwargs):
        """
        :param str smuggler_name: name of smuggler
        :param kwargs: additional parameters
        """
        self._smuggler_name = smuggler_name

    @abstractmethod
    def copy_file(self, source, destination):
        """ Abstract placeholder """
        pass
