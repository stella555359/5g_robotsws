# pylint: skip-file
# -*- coding: utf-8 -*-
"""
:created on: 04-22-2021

:copyright: Nokia
:author: Chen jin Emily
:contact: jin_emily.chen@nokia-sbell.com.cn
"""

import os
import time
import logging
from functools import partial
from .xml_files import IphyXmlFileModify
from .ta_parallel import Ta_Parallel
from .paramter_parser import Parameter_Parser
from .ta_process import Ta_Process


class InterfaceBase(object):
    """
    InterfaceBase
    """

    def __init__(self):
        """init
        """
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)


class ta_kiss_common(InterfaceBase, Ta_Parallel, IphyXmlFileModify, Parameter_Parser, Ta_Process):
    """ common operation such as clean up env, modify files
    """

    def __init__(self):
        """init
        """
        InterfaceBase.__init__(self)
        IphyXmlFileModify.__init__(self)
        Ta_Parallel.__init__(self)
        Parameter_Parser.__init__(self)
        Ta_Process.__init__(self)
