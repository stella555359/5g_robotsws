# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)
GNB_NRDRB4 = MR_NR_BTS_NAME + "/NRDRB-4"
NRCELL1 = MR_NR_BTS_NAME + "/NRCELL-1"

ALLOWED_FAULT = [
    {"faultId": 61652},
    {"faultId": 61524},
    {"faultId": 61649},
    {"faultId": 9000},
    {"faultId": 4592},
    {"faultId": 4527},
    {"faultId": 1932},
    {"faultId": 4334},
    {"faultId": 61074},
    {"faultId": 61618},
    {"faultId": 4687},
    {"faultId": 4654},
    {"faultId": 4655},
    {"faultId": 8150},
    {"faultId": 7300},
    {"faultId": 7319},
]

MODIFY_Parameter_FOR_SPLIT_MODE_X2U = [
    dict(
        dist_name=GNB_NRDRB4,
        parameter="nsaDrbParam",
        value=[
            {
                "dlDataSplitMode": "dlOverX2U",
                # "dlPreferredPath": 'F1-U',
                "ulDataPath": "ulOverLte",
                "actPrioritizeX2AfterInactivity": "true",
                "actX2DuplicateTxNSA3x": "false",
                "dlDataSplitBufferBuildUpThreshold": "5",
                "dlDataSplitBufferBuildUpThresholdPrioritizeX2": "5",
                "dlDataSplitGainThreshold": "5",
                "dlNumOfCongOrGainDdds": "2",
                "inactivityThresholdForPrioritizeX2": "300",
                "inactivityThresholdForRestartPrioritizeX2": "100",
                "initialDLTrafficRouting": "initDLoverX2U",
                "nsa3xBearerAllowed": "true",
                "prioritizeX2Period": "500",
                "ulDataSplitThreshold": "infinity",
            }
        ],
    )
]

MODIFY_Parameter_FOR_SPLIT_MODE_F1U = [
    dict(
        dist_name=GNB_NRDRB4,
        parameter="nsaDrbParam",
        value=[
            {
                "dlDataSplitMode": "dlOverF1U",
                # "dlPreferredPath": 'F1-U',
                "ulDataPath": "ulOverNr",
                "actPrioritizeX2AfterInactivity": "true",
                "actX2DuplicateTxNSA3x": "false",
                "dlDataSplitBufferBuildUpThreshold": "5",
                "dlDataSplitBufferBuildUpThresholdPrioritizeX2": "5",
                "dlDataSplitGainThreshold": "5",
                "dlNumOfCongOrGainDdds": "2",
                "inactivityThresholdForPrioritizeX2": "300",
                "inactivityThresholdForRestartPrioritizeX2": "100",
                "initialDLTrafficRouting": "initDLoverX2U",
                "nsa3xBearerAllowed": "true",
                "prioritizeX2Period": "500",
                "ulDataSplitThreshold": "infinity",
            }
        ],
    )
]

MODIFY_Parameter_disable_GnbInitRlf = [
    dict(dist_name=MR_NR_BTS_NAME, parameter="actGnbInitRlf", value="false")
]

MODIFY_Parameter_enable_GnbInitRlf = [
    dict(dist_name=MR_NR_BTS_NAME, parameter="actGnbInitRlf", value="true")
]

# MODIFY_Parameter_physCellId = [
#      dict(dist_name=NRCELL1, parameter='physCellId', value='229', operation='update')]

# Recover_Parameter_physCellId = [
#      dict(dist_name=NRCELL1, parameter='physCellId', value='225', operation='update')]

TL_7_5_UTE5G402T729 = {
    "mmw_dlcell_list": ["186089473", "186089474", "186089475", "186089476"],
    "mmw_ulcell_list": ["186089473", "186089474"],
    "mmw_lcrid_list": ["1", "2", "3", "4"],
    "cmw_dlcell_list": ["186089703"],
    "cmw_ulcell_list": ["186089703"],
    "enb_used_nr_dlcell_list": ["186089703"],
    "enb_used_nr_ulcell_list": ["186089703"],
    "enb_lcrid_list": ["1", "2"],
    "BBMOD_list": ["1", "2", "3"],
    "RMOD_list": ["1", "2", "3", "4", "5"],
    "enb_used_ue_index": 1,
    "mmw_used_ue_index": 0,
    "cmw_used_ue_index": 1,
    "break_SRF": ["3"],
    "tcpdump_interface": "fp0",
    "mmw_tput_dl_peak_sent": "2200M",
    "mmw_tput_ul_peak_sent": "300M",
    "mmw_tput_dl_peak_exp": 2020,
    "mmw_tput_ul_peak_exp": 204,
    "mmw_tput_dl_non_peak_sent": "1600M",
    "mmw_tput_ul_non_peak_sent": "160M",
    "mmw_tput_dl_non_peak_exp": 1600,
    "mmw_tput_ul_non_peak_exp": 160,
}

TL_7_5_UTE5G402T738 = {
    "mmw_dlcell_list": ["12091413", "12091414", "12091415", "12091416"],
    "mmw_ulcell_list": ["12091413", "12091414", "12091415", "12091416"],
    "mmw_lcrid_list": ["21", "22", "23", "24"],
    "cmw_dlcell_list": [],
    "cmw_ulcell_list": [],
    "enb_used_nr_dlcell_list": ["12091413", "12091414", "12091415", "12091416"],
    "enb_used_nr_ulcell_list": ["12091413", "12091414", "12091415", "12091416"],
    "enb_lcrid_list": ["1"],
    "BBMOD_list": ["1", "2"],
    "RMOD_list": ["1", "2", "3"],
    "enb_used_ue_index": 0,
    "mmw_used_ue_index": 0,
    "cmw_used_ue_index": 0,
    "break_SRF": ["1", "2"],
    "tcpdump_interface": "br1",
    "mmw_tput_dl_peak_sent": "2200M",
    "mmw_tput_ul_peak_sent": "600M",
    "mmw_tput_dl_peak_exp": 2020,
    "mmw_tput_ul_peak_exp": 420,
    "mmw_tput_dl_non_peak_sent": "1600M",
    "mmw_tput_ul_non_peak_sent": "300M",
    "mmw_tput_dl_non_peak_exp": 1600,
    "mmw_tput_ul_non_peak_exp": 300,
}

TL_7_5_UTE5G402T700 = {
    "mmw_dlcell_list": ["11469101", "11469102", "11469103"],
    "mmw_ulcell_list": ["11469101", "11469102", "11469103"],
    "mmw_lcrid_list": ["301", "302", "303"],
    "cmw_dlcell_list": ["11469101", "11469102", "11469103"],
    "cmw_ulcell_list": ["11469101", "11469102", "11469103"],
    "enb_used_nr_dlcell_list": ["11469101", "11469102", "11469103"],
    "enb_used_nr_ulcell_list": ["11469101", "11469102", "11469103"],
    "enb_lcrid_list": [],
    "BBMOD_list": ["1", "2"],
    "RMOD_list": ["1", "2", "3"],
    "enb_used_ue_index": 0,
    "mmw_used_ue_index": 0,
    "cmw_used_ue_index": 0,
    "break_SRF": ["1", "2"],
    "tcpdump_interface": "br1",
    "mmw_tput_dl_peak_sent": "2200M",
    "mmw_tput_ul_peak_sent": "600M",
    "mmw_tput_dl_peak_exp": 2020,
    "mmw_tput_ul_peak_exp": 420,
    "mmw_tput_dl_non_peak_sent": "1600M",
    "mmw_tput_ul_non_peak_sent": "300M",
    "mmw_tput_dl_non_peak_exp": 800,
    "mmw_tput_ul_non_peak_exp": 100,
}

TestLineList = {
    "7_5_UTE5G402T729": TL_7_5_UTE5G402T729,
    "7_5_UTE5G402T738": TL_7_5_UTE5G402T738,
    "7_5_UTE5G402T700": TL_7_5_UTE5G402T700,
}
