"""
:copyright: Nokia Networks
:author: 5G_SW_WRO
:contact: I_MBB_LTE_DEVWRO1_TEST_GMS <I_MBB_LTE_DEVWRO1_TEST@internal.nsn.com>
"""

import time
from robot.api import logger
from taf.gnb.oam.coam.admin import admin
from robot.errors import ExecutionFailed
# from robot.api import logger
from ta5g_setups_and_teardowns import ta5g_setups_and_teardowns
from ta5g_commissioning import ta5g_commissioning
from ta5g_testline_management import ta5g_testline_management
from ta5g_iphy import ta5g_iphy
from ta5g_tshark import ta5g_tshark
import datetime as dt
import math
from robot.libraries.BuiltIn import BuiltIn
import re
import io

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def start_data_dl_x(ue_id, pdu_id, trf_id1, x):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu={} dir=dl mbps={} trf_id={}'
        .format(ue_id, pdu_id, x, trf_id1),
        timeout='20s',
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:{} Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, pdu_id, trf_id1))
