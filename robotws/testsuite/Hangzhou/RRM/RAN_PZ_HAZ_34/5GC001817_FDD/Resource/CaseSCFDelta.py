import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# Modify 5GC001817_A_05 SCF
PARAMS_TO_MODIFY_1817_A_05 = [
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actAperCsi"
    ),
    dict(value="false", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actCDrx"),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a2MeashoEnabledSA",
    ),
    dict(
        value="4x4 or 4x2 Closed Loop Spatial Multiplexing",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="dlMimoMode",
    ),
    dict(
        value="longPucch",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="pucchModeSelect",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELLGRP-0",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="7",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="msg1FrequencyStart",
    ),
    dict(
        value="4DL4UL",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="nrCellType",
    ),
    dict(value="SA", dist_name="MRBTS-1353/NRBTS-1353", p_name="gNbCuType"),
    dict(value="0", dist_name="MRBTS-1353/NRBTS-1353", p_name="x2LinkSupervisionTmr"),
    dict(
        value="SA", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="cellDepType"
    ),
    dict(
        value="17",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="reqMinNumPuschPrb",
    ),
    dict(
        value="17",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="reqMinNumPuschPrb",
    ),
    dict(
        value="0",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos3",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="5MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="5MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    dict(
        value="0",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos3",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="5MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="5MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
]

PARAMS_TO_DELETE_1817_A_05 = []

ADD_MOs_1817_A_05 = []

LIST_TO_ADD_1817_A_05 = []

LIST_PARAMS_TO_MODIFY_1817_A_05 = [
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    # BWP_PROFILE DN5/6_5M_ACSI true
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-5", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-6", index=1)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    # BWP_PROFILE DN5/6_5M_ACSI true
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-5", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-6", index=1)
        ],
    ),
]
