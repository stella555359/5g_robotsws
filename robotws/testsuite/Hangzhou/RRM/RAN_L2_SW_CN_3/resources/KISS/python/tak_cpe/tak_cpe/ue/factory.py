# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
from .spark_cpe import SparkCpe


class Ue(object):
    """ Ue factory class """
    ue_class_map = {"SPARK_CPE": SparkCpe}

    def __new__(cls, ue_info, **kwargs):
        try:
            ue_type = ue_info.type.upper()
            kwargs.update(ue_info)
            return cls.ue_class_map[ue_type](ue_info.address, **kwargs)
        except Exception as error:
            raise Exception(
                "the ue type '%s' is not supported now ! error: %s" %
                (ue_type, error))
