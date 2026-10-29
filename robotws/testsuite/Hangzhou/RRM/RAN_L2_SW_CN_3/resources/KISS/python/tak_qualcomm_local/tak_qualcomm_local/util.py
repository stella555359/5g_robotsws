# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""

LOG_PATH = "C:\\tmp\\Qualcomm"


def write_debug_log_to_file(file_name, content):
    """ Write debug log """
    full_file_name = "{}\\{}".format(LOG_PATH, file_name)
    with open(full_file_name, 'a+', encoding='utf-8') as f:
        f.write("{}\n".format(content))
