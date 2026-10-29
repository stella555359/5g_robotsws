import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# modify CB009789 SCF
# CU
PARAMS_TO_DELETE_CU_9789 = []

MOs_TO_ADD_CU_9789 = []

PARAMS_TO_MODIFY_CU_9789 = []


LIST_PARAMS_TO_MODIFY_CU_9789 = []


LIST_TO_ADD_CU_9789 = []


# DU

PARAMS_TO_DELETE_DU_9789 = []

MOs_TO_ADD_DU_9789 = []

PARAMS_TO_MODIFY_DU_9789 = []

LIST_PARAMS_TO_MODIFY_DU_9789 = []

LIST_TO_ADD_DU_9789 = []


# CU 9789_DF28
PARAMS_TO_DELETE_CU_9789_DF28 = [
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1/NRREL-1"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1/NRREL-2"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1/NRREL-3"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1/NRREL-4"),
]

MOs_TO_ADD_CU_9789_DF28 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRANRPR",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        version="NRBTSCU23R4_2315_100",
    ),
]

PARAMS_TO_MODIFY_CU_9789_DF28 = [
    dict(value="true", dist_name="MRBTS-10548/NRBTS-10548", p_name="actSaUeBasedAnrNr"),
    dict(value="true", dist_name="MRBTS-10548/NRBTS-10548", p_name="actIntraFreqHoSA"),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actDisableUlProactGrantAnr",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actEnhanceIntraNrIntraFreqAnr",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actSaIntraFreqAnrDrxProf",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actDedicatedAnrDrxProfile",
    ),
    dict(
        value="5min",
        dist_name="MRBTS-10548/NRBTS-10548/NRPMRNL-1",
        p_name="miNrRelReportCu",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-2",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-4",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-2",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-4",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="RSRP",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-1",
        p_name="anrThresholdSelector",
    ),
    dict(
        value="RSRP",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-2",
        p_name="anrThresholdSelector",
    ),
    dict(
        value="-90",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="anrThresRsrpNbCell",
    ),
    dict(
        value="RSRP",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="anrThresholdSelector",
    ),
    dict(
        value="SA+NSA",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="cellDepMode",
    ),
    dict(
        value="5",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="consecRecheckForNrNbRemoval",
    ),
    dict(
        value="72",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="idleTimeForNrNbRemoval",
    ),
    dict(
        value="50",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="maxNumAnrNrrelAllowed",
    ),
    dict(
        value="636000", dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3", p_name="nrarfcn"
    ),
    dict(
        value="636000",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="ssbFrequency",
    ),
]


LIST_PARAMS_TO_MODIFY_CU_9789_DF28 = [
    # dict(
    #     dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1",
    #     list_name="a3MeasSsbRsrp",
    #     elements=[
    #         dict(p_name="a3HysteresisSsbRsrp", value="8", index=0),
    #         dict(p_name="a3OffsetSsbRsrp", value="-21", index=0),
    #         dict(p_name="a3TimeToTriggerSsbRsrp", value="ms640", index=0),
    #     ],
    # ),
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1",
        list_name="a5MeasSsbRsrp",
        elements=[
            dict(p_name="a5HysteresisSsbRsrp", value="0", index=0),
            dict(p_name="a5Threshold1SsbRsrp", value="96", index=0),
            dict(p_name="a5Threshold2SsbRsrp", value="71", index=0),
            dict(p_name="a5TimeToTriggerSsbRsrp", value="ms512", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRDRB-1",
        list_name="nsaDrbParam",
        elements=[
            dict(p_name="ulDataPath", value="ulOverLteNr_PrimaryPathOverNr", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRDRB-2",
        list_name="nsaDrbParam",
        elements=[
            dict(p_name="ulDataPath", value="ulOverLteNr_PrimaryPathOverNr", index=0),
        ],
    ),
]


LIST_TO_ADD_CU_9789_DF28 = [
    # dict(
    #     dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1",
    #     list_name="drxProfileNrAnr",
    #     elements=dict(drxControl="any", drxLongCycle="640ms"),
    # ),
]

# DU CB009789 DF28

PARAMS_TO_DELETE_DU_9789_DF28 = []

MOs_TO_ADD_DU_9789_DF28 = []

PARAMS_TO_MODIFY_DU_9789_DF28 = [
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actDedicatedAnrDrxProfile",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1",
        p_name="actSib1ForNsaCell",
    ),
]

LIST_PARAMS_TO_MODIFY_DU_9789_DF28 = []

LIST_TO_ADD_DU_9789_DF28 = [
    # dict(
    #     dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1",
    #     list_name="drxProfileNrAnr",
    #     elements=dict(
    #         drxControl="any",
    #         drxLongCycle="640ms",
    #         drxOnDurationTimer="10ms",
    #         drxInactivityTimer="10ms",
    #         drxRetransTimerDl="0slot",
    #         drxRetransTimerUl="0slot",
    #     ),
    # ),
]


# CU 9789_DF14
PARAMS_TO_DELETE_CU_9789_DF14 = [
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1/NRREL-1"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1/NRREL-2"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1/NRREL-3"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1/NRREL-4"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-2/NRREL-1"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-2/NRREL-2"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-2/NRREL-3"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-2/NRREL-4"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3/NRREL-1"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3/NRREL-2"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3/NRREL-3"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3/NRREL-4"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-4/NRREL-1"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-4/NRREL-2"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-4/NRREL-3"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-4/NRREL-4"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5/NRREL-1"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5/NRREL-2"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5/NRREL-3"),
    dict(dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5/NRREL-4"),
]

MOs_TO_ADD_CU_9789_DF14 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRANRPR",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        version="NRBTSCU23R4_2315_100",
    ),
]

PARAMS_TO_MODIFY_CU_9789_DF14 = [
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actDisableUlProactGrantAnr",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actEnhanceIntraNrIntraFreqAnr",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actIntraFreqIntraGnbMobilityNSA",
    ),
    dict(
        value="true", dist_name="MRBTS-10548/NRBTS-10548", p_name="actNsaUeBasedAnrNr"
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actDedicatedAnrDrxProfile",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="sgnbRelForNoHandoverEnabled",
    ),
    dict(
        value="disabled",
        dist_name="MRBTS-10548/NRBTS-10548/NRPMRNL-1",
        p_name="miNrRelReportCu",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-2",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-4",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-1",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-2",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-4",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="RSRP",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-1",
        p_name="anrThresholdSelector",
    ),
    dict(
        value="RSRP",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-2",
        p_name="anrThresholdSelector",
    ),
    dict(
        value="-90",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="anrThresRsrpNbCell",
    ),
    dict(
        value="RSRP",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="anrThresholdSelector",
    ),
    dict(
        value="SA+NSA",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="cellDepMode",
    ),
    dict(
        value="5",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="consecRecheckForNrNbRemoval",
    ),
    dict(
        value="72",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="idleTimeForNrNbRemoval",
    ),
    dict(
        value="50",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="maxNumAnrNrrelAllowed",
    ),
    dict(
        value="636000", dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3", p_name="nrarfcn"
    ),
    dict(
        value="636000",
        dist_name="MRBTS-10548/NRBTS-10548/NRANRPR-3",
        p_name="ssbFrequency",
    ),
]


LIST_PARAMS_TO_MODIFY_CU_9789_DF14 = [
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3",
        list_name="a3MeasSsbRsrp",
        elements=[
            dict(p_name="a3HysteresisSsbRsrp", value="8", index=0),
            dict(p_name="a3OffsetSsbRsrp", value="-21", index=0),
            dict(p_name="a3TimeToTriggerSsbRsrp", value="ms640", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRDRB-1",
        list_name="nsaDrbParam",
        elements=[
            dict(p_name="ulDataPath", value="ulOverLteNr_PrimaryPathOverNr", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRDRB-2",
        list_name="nsaDrbParam",
        elements=[
            dict(p_name="ulDataPath", value="ulOverLteNr_PrimaryPathOverNr", index=0),
        ],
    ),
]


LIST_TO_ADD_CU_9789_DF14 = [
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3",
        list_name="drxProfileNrAnr",
        elements=dict(drxControl="any", drxLongCycle="640ms"),
    ),
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5",
        list_name="drxProfileNrAnr",
        elements=dict(drxControl="any", drxLongCycle="640ms"),
    ),
]

# DU2 CB009789 DF14

PARAMS_TO_DELETE_DU2_9789_DF14 = []

MOs_TO_ADD_DU2_9789_DF14 = []

PARAMS_TO_MODIFY_DU2_9789_DF14 = [
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actDedicatedAnrDrxProfile",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3",
        p_name="actSib1ForNsaCell",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actDisableUlProactGrantAnr",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actEnhanceIntraNrIntraFreqAnr",
    ),
]

LIST_PARAMS_TO_MODIFY_DU2_9789_DF14 = []

LIST_TO_ADD_DU2_9789_DF14 = [
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-3",
        list_name="drxProfileNrAnr",
        elements=dict(
            drxControl="any",
            drxLongCycle="640ms",
            drxOnDurationTimer="10ms",
            drxInactivityTimer="10ms",
            drxRetransTimerDl="0slot",
            drxRetransTimerUl="0slot",
        ),
    ),
]


# DU4 CB009789 DF14

PARAMS_TO_DELETE_DU4_9789_DF14 = []

MOs_TO_ADD_DU4_9789_DF14 = []

PARAMS_TO_MODIFY_DU4_9789_DF14 = [
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actDedicatedAnrDrxProfile",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5",
        p_name="actSib1ForNsaCell",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actDisableUlProactGrantAnr",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10548/NRBTS-10548",
        p_name="actEnhanceIntraNrIntraFreqAnr",
    ),
]

LIST_PARAMS_TO_MODIFY_DU4_9789_DF14 = []

LIST_TO_ADD_DU4_9789_DF14 = [
    dict(
        dist_name="MRBTS-10548/NRBTS-10548/NRCELL-5",
        list_name="drxProfileNrAnr",
        elements=dict(
            drxControl="any",
            drxLongCycle="640ms",
            drxOnDurationTimer="10ms",
            drxInactivityTimer="10ms",
            drxRetransTimerDl="0slot",
            drxRetransTimerUl="0slot",
        ),
    ),
]
