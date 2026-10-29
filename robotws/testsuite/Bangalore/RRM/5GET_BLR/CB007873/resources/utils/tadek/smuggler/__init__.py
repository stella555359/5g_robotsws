# -*- coding: utf-8 -*-
"""
:author: Bartosz Bugaj
:contact: bartosz.bugaj@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""

from robot.api import logger

from .config import SMUGGLERS
from .git import GitSmuggler
from .local import LocalSmuggler
from .scp import ScpSmuggler, FsmSmuggler, IphySmuggler, FspSmuggler, BbmodSmuggler
from .svn import SvnSmuggler
from .web import WebSmuggler


class Smuggler(object):
    """ Smugglers factory class """

    def __new__(cls, smuggler_name, **kwargs):
        """ Factory-like creation of smuggler handler
        :param str smuggler_name: name of smuggler
        :return: specific instance of smuggler handler
        """
        logger.debug('Smuggler name: {}'.format(smuggler_name))
        handler = globals()[SMUGGLERS.get(smuggler_name).get('handler')](smuggler_name=smuggler_name, **kwargs)
        logger.debug('Resolved smuggler handler: {}'.format(type(handler)))
        return handler
