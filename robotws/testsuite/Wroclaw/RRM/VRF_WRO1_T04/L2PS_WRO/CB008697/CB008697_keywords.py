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


def start_data_dl_amount_mbps(ue_id, pdu_id, trf_id1, amount):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu={} dir=dl mbps={} trf_id={}'
        .format(ue_id, pdu_id, amount, trf_id1),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:{} Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, pdu_id, trf_id1))


def set_ue_in_overheated_state_with_max_cc(ue_id, cc):
    ute_wtssim_instance.execute_egate_command(
        cmd='ue_assistance_send_nr ue_id={} forOverheating=yes reducedCCsDL={}'.format(ue_id, cc))


def get_pdsch_ue_stats_for_given_cc(ue_id, cc):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pdsch scell={}'
                                                                       .format(ue_id, cc),
                                                                       pass_regexp='UE-{}: NR PDSCH Throughput'
                                                                       .format(ue_id))


def get_pdsch_ue_stats_for_all_cc(ue_id, last_cc_id):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pdsch scell=0-{}'
                                                                       .format(ue_id, last_cc_id),
                                                                       pass_regexp='UE-{}: NR PDSCH Throughput'
                                                                       .format(ue_id))


def create_csi_profile(profile_id, cqi):
    ute_wtssim_instance.execute_egate_command(cmd='csi_override_testmode_nr profile_id={} cqi={} cqi_mode=fixed'
                                              .format(profile_id, cqi))


def activate_csi_profile_for(ue_id, profile_id, scell):
    ute_wtssim_instance.execute_egate_command(
        cmd='ue_testmode_set_nr id={} testmode=csi_override action=activate profile_id={} scell={}'
        .format(ue_id, profile_id, scell))


def get_current_dl_data_traffic_for_given_cc(ue_id, cc, unit):
    pdsch_ue_stats = get_pdsch_ue_stats_for_given_cc(ue_id, cc)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    current_tput = pattern.findall(pdsch_ue_stats)[0][0]
    return float(current_tput)


def check_how_many_scells_are_not_scheduled(ue_id, last_cc_id, exp_scells):
    scells_tput_lst = []
    pdsch_ue_stats = get_pdsch_ue_stats_for_all_cc(ue_id, last_cc_id)
    for cc in range(int(last_cc_id) + 1):
        pattern = re.compile(r'(CellIndex-{})..(\d+(\.\d+)?)'.format(cc))
        scells_tput_lst.append(pattern.findall(pdsch_ue_stats)[0][1].strip())
    if scells_tput_lst.count('0') == int(exp_scells):
        print("Check passed, {} Scell(s) not scheduled".format(scells_tput_lst.count('0')))
    else:
        raise Exception("{} SCell(s) not scheduled, expected: {}"
                        .format(scells_tput_lst.count('0'), exp_scells))


def verify_there_is_no_tput_on_scell(ue_id, cc):
    pdsch_ue_stats = get_pdsch_ue_stats_for_given_cc(ue_id, cc)
    pattern = re.compile(r'\d')
    new_pattern = re.compile(r'(CellIndex-{})..(\d+(\.\d+)?)'.format(cc))
    scell_tput = new_pattern.findall(pdsch_ue_stats)[0][1]
    if int(scell_tput) == 0:
        print("Check passed, there is no data transmission on Scell")
    else:
        raise Exception("Scell tput {} is higher than 0".format(float(scell_tput)))


def use_regex_to_get_tput(ue_stats):
    pattern1 = re.compile(r'CellIndex-[0-9].*')
    scell_tput = pattern1.findall(ue_stats)[0]
    scell_tput2 = re.sub(r'CellIndex-[0-9]', '', scell_tput)
    pattern2 = re.compile(r' 0 |\d*\.\d')
#    pattern3 = pattern2.strip()
    scell_tput3 = float(pattern2.findall(scell_tput2)[0].strip())
    return scell_tput3


def verify_tput_on_scell(ue_id, cc, tput_expected):
    ue_stats = get_pdsch_ue_stats_for_given_cc(ue_id, cc)
    scell_tput = use_regex_to_get_tput(ue_stats)
    logger.info('cell-{}_tput= {}'.format(cc, scell_tput), also_console=True)
    logger.info('cell-{}_tput_expected= {}'.format(cc, tput_expected), also_console=True)
    logger.info('cell-{}_tput_expected_type= {}'.format(cc, type(tput_expected)), also_console=True)
    if ((int(scell_tput) == 0) and (not tput_expected)):
        logger.info('\nCheck passed, there is no data transmission on Scell-{}'.format(cc), also_console=True)
    elif (int(scell_tput) > 0 and tput_expected):
        logger.info('\nCheck passed, there is data transmission on Scell-{}'.format(cc), also_console=True)
    else:
        raise Exception("SCell-{} tput {} was expected to be present={}".format(cc, scell_tput, tput_expected))


def verify_all_scells_are_added(ue_id):
    for i in range(0, 4):
        ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pdsch scell=0-3'
                                                                    .format(ue_id),
                                                                    pass_regexp='CellIndex-{}'.format(i))
        logger.info('CellIndex={} is in added state!'.format(i), also_console=True)


def verify_two_scells_are_added(ue_id):
    for i in range(0, 2):
        ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pdsch scell=0-3'
                                                                    .format(ue_id),
                                                                    pass_regexp='CellIndex-{}'.format(i))
        logger.info('CellIndex={} is in added state!'.format(i), also_console=True)


def start_very_big_data_dl(ue_id, pdu_id, trf_id1, trf_id2, trf_id3):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu={} dir=dl mbps=175 trf_id={}'
        .format(ue_id, pdu_id, trf_id1),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:{} Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, pdu_id, trf_id1))
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu={} dir=dl mbps=175 trf_id={}'
        .format(ue_id, pdu_id, trf_id2),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:{} Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, pdu_id, trf_id2))
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu={} dir=dl mbps=175 trf_id={}'
        .format(ue_id, pdu_id, trf_id3),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:{} Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, pdu_id, trf_id3))


def start_big_data_dl(ue_id, pdu_id, trf_id1, trf_id2):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu={} dir=dl mbps=175 trf_id={}'
        .format(ue_id, pdu_id, trf_id1),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:{} Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, pdu_id, trf_id1))
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu={} dir=dl mbps=175 trf_id={}'
        .format(ue_id, pdu_id, trf_id2),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:{} Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, pdu_id, trf_id2))


def start_medium_data_dl(ue_id, pdu_id, trf_id1, trf_id2):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu={} dir=dl mbps=100 trf_id={}'
        .format(ue_id, pdu_id, trf_id1),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:{} Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, pdu_id, trf_id1))
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu={} dir=dl mbps=100 trf_id={}'
        .format(ue_id, pdu_id, trf_id2),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:{} Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, pdu_id, trf_id2))


def start_low_data_dl(ue_id, trf_id1, trf_id2):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu=1 dir=dl mbps=1 trf_id={}'
        .format(ue_id, trf_id1),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:1 Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, trf_id1))
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='trf_data_start ue={} pdu=1 dir=dl mbps=1 trf_id={}'
        .format(ue_id, trf_id2),
        pass_regexp='UE{}: Started Downlink Internal traffic Receiver on Ue:{} Pdu:1 Qfi:1 TrfId:{}'
        .format(ue_id, ue_id, trf_id2))


def set_internal_traffic_type(ue_id, pdu_id):
    ute_wtssim_instance.execute_egate_command(cmd='set_pdu_param ue={} pdu={} trf_type=internal'.format(ue_id, pdu_id))


def add_scells(ue_id):
    ute_wtssim_instance.execute_egate_command(
        cmd='ue_measurement_send_nr event=A1 meas_id=1 id={} srsrp_nr=127 srsrq_nr=127 ssinr_nr=127'.format(ue_id))


def stop_all_data_transfer_for_ue(ue_id, pdu_id):
    ute_wtssim_instance.execute_egate_command(cmd='trf_data_stop ue={} pdu={}'.format(ue_id, pdu_id))


def verify_tput_for_4CC(ue_id, cc0_tput, cc1_tput, cc2_tput, cc3_tput):
    verify_tput_on_scell(ue_id, 0, cc0_tput)
    verify_tput_on_scell(ue_id, 1, cc1_tput)
    verify_tput_on_scell(ue_id, 2, cc2_tput)
    verify_tput_on_scell(ue_id, 3, cc3_tput)


def verify_tput_for_2CC(ue_id, cc0_tput, cc1_tput):
    verify_tput_on_scell(ue_id, 0, cc0_tput)
    verify_tput_on_scell(ue_id, 1, cc1_tput)
