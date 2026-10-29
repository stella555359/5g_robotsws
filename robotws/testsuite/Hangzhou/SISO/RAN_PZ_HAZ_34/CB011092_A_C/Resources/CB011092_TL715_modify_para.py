# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

NRBTS_ID = (
    "MRBTS-" + str(tl.gnbs[0].instance_id) + "/NRBTS-" + str(tl.gnbs[0].instance_id)
)
MRBTS_NRDU = NRBTS_ID + "/NRDU-1"
GNB_NRCELL_ID = NRBTS_ID + "/NRCELL-"
GNB_SMOD_SFP = (
    "MRBTS-" + str(tl.gnbs[0].instance_id) + "/EQM-1/APEQM-1/CABINET-1/SMOD-1"
)
ALARM_RU_NAME = (
    "[TL726" + "] MRBTS-" + str(tl.gnbs[0].instance_id) + "/EQM-1/APEQM-1/RMOD-"
)
SMOD_TYPE = (
    "MRBTS-" + str(tl.gnbs[0].instance_id) + "/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1"
)
# modify parameter

para_chBw_1 = [
    dict(
        dist_name=GNB_NRCELL_ID + "0",
        parameter="chBw",
        value="60MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1",
        parameter="chBw",
        value="60MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "2",
        parameter="chBw",
        value="60MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "3",
        parameter="chBw",
        value="60MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="chBw",
        value="60MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "5",
        parameter="chBw",
        value="60MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "0",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-9",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-90",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-9",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-90",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "2",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-9",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-90",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "3",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-9",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-90",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-9",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-90",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "5",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-9",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": NRBTS_ID + "/BWP_PROFILE-90",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
]
para_chBw_2 = [
    dict(
        dist_name=GNB_NRCELL_ID + "0",
        parameter="chBw",
        value="20MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1",
        parameter="chBw",
        value="20MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "2",
        parameter="chBw",
        value="20MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "3",
        parameter="chBw",
        value="20MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="chBw",
        value="20MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "5",
        parameter="chBw",
        value="20MHz",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "0",
        parameter="type0CoresetConfigurationIndex",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1",
        parameter="type0CoresetConfigurationIndex",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "2",
        parameter="type0CoresetConfigurationIndex",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "3",
        parameter="type0CoresetConfigurationIndex",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="type0CoresetConfigurationIndex",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "5",
        parameter="type0CoresetConfigurationIndex",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "0",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-10",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-100",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-10",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-100",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "2",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-10",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-100",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "3",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-10",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-100",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-10",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-100",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "5",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-10",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-100",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
]

para_smodtype = [
    dict(
        dist_name=SMOD_TYPE,
        parameter="smodBoardConfigType",
        value="NRFDD_NRTDD",
        operation="update",
    ),
]

supercell_for_3super2sub = {
    "NRCELL-1": [
        "Subcell-2 (DL)",
        "Subcell-2 (UL)",
        "Subcell-3 (DL)",
        "Subcell-3 (UL)",
    ],
    "NRCELL-3": [
        "Subcell-4 (DL)",
        "Subcell-4 (UL)",
        "Subcell-5 (DL)",
        "Subcell-5 (UL)",
    ],
    "NRCELL-0": [
        "Subcell-0 (DL)",
        "Subcell-0 (UL)",
        "Subcell-1 (DL)",
        "Subcell-1 (UL)",
    ],
}

supercell_for_2super3sub = {
    "NRCELL-1": [
        "Subcell-3 (DL)",
        "Subcell-3 (UL)",
        "Subcell-4 (DL)",
        "Subcell-4 (UL)",
        "Subcell-5 (DL)",
        "Subcell-5 (UL)",
    ],
    "NRCELL-0": [
        "Subcell-0 (DL)",
        "Subcell-0 (UL)",
        "Subcell-1 (DL)",
        "Subcell-1 (UL)",
        "Subcell-2 (DL)",
        "Subcell-2 (UL)",
    ],
}

supercell_for_2super5sub = {
    "NRCELL-1": [
        "Subcell-0 (DL)",
        "Subcell-0 (UL)",
        "Subcell-1 (DL)",
        "Subcell-1 (UL)",
        "Subcell-2 (DL)",
        "Subcell-2 (UL)",
    ],
    "NRCELL-4": [
        "Subcell-3 (DL)",
        "Subcell-3 (UL)",
        "Subcell-4 (DL)",
        "Subcell-4 (UL)",
    ],
}

supercell_for_1super6sub = {
    "NRCELL-1": [
        "Subcell-0 (DL)",
        "Subcell-0 (UL)",
        "Subcell-1 (DL)",
        "Subcell-1 (UL)",
        "Subcell-2 (DL)",
        "Subcell-2 (UL)",
        "Subcell-3 (DL)",
        "Subcell-3 (UL)",
        "Subcell-4 (DL)",
        "Subcell-4 (UL)",
        "Subcell-5 (DL)",
        "Subcell-5 (UL)",
    ]
}

supercell_for_1super3sub = {
    "NRCELL-1": [
        "Subcell-0 (DL)",
        "Subcell-0 (UL)",
        "Subcell-1 (DL)",
        "Subcell-1 (UL)",
        "Subcell-2 (DL)",
        "Subcell-2 (UL)",
    ]
}

supercell_for_E2E_2super3sub = {
    "NRCELL-4": [
        "Subcell-3 (DL)",
        "Subcell-3 (UL)",
        "Subcell-4 (DL)",
        "Subcell-4 (UL)",
        "Subcell-5 (DL)",
        "Subcell-5 (UL)",
    ],
    "NRCELL-1": [
        "Subcell-0 (DL)",
        "Subcell-0 (UL)",
        "Subcell-1 (DL)",
        "Subcell-1 (UL)",
        "Subcell-2 (DL)",
        "Subcell-2 (UL)",
    ],
}
