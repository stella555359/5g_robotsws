# -*- coding: utf-8 -*-
"""
:created on: 15-04-2017

:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import logging


class Logger(object):

    logger = None

    def __new__(cls, *args, **kwargs):
        if Logger.logger is None:
            Logger.logger = logging.getLogger(__name__)
            return Logger.logger
        return Logger.logger
