# -*- coding: utf-8 -*-
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


def get_pdsch_ue_stats_for_given_cc(ue_id, cc):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pdsch scell={}'
                                                                       .format(ue_id, cc),
                                                                       pass_regexp='UE-{}: NR PDSCH Throughput'
                                                                       .format(ue_id))


def get_pusch_ue_stats_for_given_cc(ue_id, cc):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pusch scell={}'
                                                                       .format(ue_id, cc),
                                                                       pass_regexp='UE-{}: NR PUSCH Throughput'
                                                                       .format(ue_id))


def use_regex_to_get_tput(ue_stats):
    pattern1 = re.compile(r'CellIndex-[0-9].*')
    scell_tput = pattern1.findall(ue_stats)[0]
    scell_tput2 = re.sub(r'CellIndex-[0-9]', '', scell_tput)
    pattern2 = re.compile(r' 0 |\d*\.\d')
    scell_tput3 = float(pattern2.findall(scell_tput2)[0].strip())
    return scell_tput3


def verify_tput_on_scell(ue_id, cc, tput_expected):
    ue_stats = get_pdsch_ue_stats_for_given_cc(ue_id, cc)
    scell_tput = use_regex_to_get_tput(ue_stats)
    logger.info('ue-{}_tput= {}'.format(ue_id, scell_tput), also_console=True)
    logger.info('cell-{}_tput_expected= {}'.format(cc, tput_expected), also_console=False)
    logger.info('cell-{}_tput_expected_type= {}'.format(cc, type(tput_expected)), also_console=False)
    if ((int(scell_tput) == 0) and (not tput_expected)):
        logger.info('\nCheck passed, there is no data transmission on Scell-{}'.format(cc), also_console=True)
    elif (int(scell_tput) > 0 and tput_expected):
        logger.info('\nCheck passed, there is data transmission on Scell-{}'.format(cc), also_console=False)
    else:
        raise Exception("SCell-{} tput {} was expected to be present={}".format(cc, scell_tput, tput_expected))


def verify_ul_tput_on_scell(ue_id, cc, tput_expected):
    ue_stats = get_pusch_ue_stats_for_given_cc(ue_id, cc)
    scell_tput = use_regex_to_get_tput(ue_stats)
    logger.info('ue-{}_tput= {}'.format(ue_id, scell_tput), also_console=True)
    logger.info('cell-{}_tput_expected= {}'.format(cc, tput_expected), also_console=False)
    logger.info('cell-{}_tput_expected_type= {}'.format(cc, type(tput_expected)), also_console=False)
    if ((int(scell_tput) == 0) and (not tput_expected)):
        logger.info('\nCheck passed, there is no data transmission on Scell-{}'.format(cc), also_console=True)
    elif (int(scell_tput) > 0 and tput_expected):
        logger.info('\nCheck passed, there is data transmission on Scell-{}'.format(cc), also_console=False)
    else:
        raise Exception("SCell-{} tput {} was expected to be present={}".format(cc, scell_tput, tput_expected))
