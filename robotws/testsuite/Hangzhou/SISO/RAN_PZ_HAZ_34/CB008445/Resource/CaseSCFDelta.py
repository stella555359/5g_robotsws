import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

PARAMETER_TO_DELETE_TC01 = []
PARAMETER_TO_MODIFY_TC01 = [
    dict(
        value="21",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1/LNCEL_FDD-0",
        p_name="prachConfIndex",
    ),
]
MOS_TO_ADD_TC01 = []
LIST_TO_ADD_TC01 = []
LIST_PARAMS_TO_MODIFY_TC01 = []

PARAMETER_TO_DELETE_TC02 = []
PARAMETER_TO_MODIFY_TC02 = [
    dict(
        value="9",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1/LNCEL_FDD-0",
        p_name="prachFreqOff",
    ),
]
MOS_TO_ADD_TC02 = []
LIST_TO_ADD_TC02 = []
LIST_PARAMS_TO_MODIFY_TC02 = []

PARAMETER_TO_DELETE_TC03_5M = []
PARAMETER_TO_MODIFY_TC03_5M = [
    dict(
        value="false",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="actDl256Qam",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="actUl256Qam",
    ),
]
MOS_TO_ADD_TC03_5M = []
LIST_TO_ADD_TC03_5M = []
LIST_PARAMS_TO_MODIFY_TC03_5M = []

PARAMETER_TO_DELETE_TC03_10M = []
PARAMETER_TO_MODIFY_TC03_10M = [
    dict(
        value="false",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="actDl256Qam",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="actUl256Qam",
    ),
]
MOS_TO_ADD_TC03_10M = []
LIST_TO_ADD_TC03_10M = []
LIST_PARAMS_TO_MODIFY_TC03_10M = []

PARAMETER_TO_DELETE_TC04_5M = []
PARAMETER_TO_MODIFY_TC04_5M = [
    dict(
        value="false",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="actUl256Qam",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="actDl256Qam",
    ),
]
MOS_TO_ADD_TC04_5M = []
LIST_TO_ADD_TC04_5M = []
LIST_PARAMS_TO_MODIFY_TC04_5M = []

PARAMETER_TO_DELETE_TC04_10M = []
PARAMETER_TO_MODIFY_TC04_10M = [
    dict(
        value="false",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="actUl256Qam",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="actDl256Qam",
    ),
]
MOS_TO_ADD_TC04_10M = []
LIST_TO_ADD_TC04_10M = []
LIST_PARAMS_TO_MODIFY_TC04_10M = []

PARAMETER_TO_DELETE_TC05_5M = []
PARAMETER_TO_MODIFY_TC05_5M = [
    dict(
        value="true", dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1", p_name="actUl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1", p_name="actDl256Qam"
    ),
]
MOS_TO_ADD_TC05_5M = []
LIST_TO_ADD_TC05_5M = []
LIST_PARAMS_TO_MODIFY_TC05_5M = []

PARAMETER_TO_DELETE_TC05_10M = []
PARAMETER_TO_MODIFY_TC05_10M = [
    dict(
        value="true", dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1", p_name="actUl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1", p_name="actDl256Qam"
    ),
]
MOS_TO_ADD_TC05_10M = []
LIST_TO_ADD_TC05_10M = []
LIST_PARAMS_TO_MODIFY_TC05_10M = []

PARAMETER_TO_DELETE_TC06_5M = []
PARAMETER_TO_MODIFY_TC06_5M = [
    dict(
        value="true", dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1", p_name="actUl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1", p_name="actDl256Qam"
    ),
]
MOS_TO_ADD_TC06_5M = []
LIST_TO_ADD_TC06_5M = []
LIST_PARAMS_TO_MODIFY_TC06_5M = []

PARAMETER_TO_DELETE_TC06_10M = []
PARAMETER_TO_MODIFY_TC06_10M = [
    dict(
        value="true", dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1", p_name="actUl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1", p_name="actDl256Qam"
    ),
]
MOS_TO_ADD_TC06_10M = []
LIST_TO_ADD_TC06_10M = []
LIST_PARAMS_TO_MODIFY_TC06_10M = []

PARAMETER_TO_DELETE_TC03_10M_LTE = []
PARAMETER_TO_MODIFY_TC03_10M_LTE = [
    dict(
        value="64QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeDl",
    ),
    dict(
        value="64QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeUL",
    ),
]
MOS_TO_ADD_TC03_10M_LTE = []
LIST_TO_ADD_TC03_10M_LTE = []
LIST_PARAMS_TO_MODIFY_TC03_10M_LTE = []

PARAMETER_TO_DELETE_TC04_10M_LTE = []
PARAMETER_TO_MODIFY_TC04_10M_LTE = [
    dict(
        value="64QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeDl",
    ),
    dict(
        value="64QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeUL",
    ),
]
MOS_TO_ADD_TC04_10M_LTE = []
LIST_TO_ADD_TC04_10M_LTE = []
LIST_PARAMS_TO_MODIFY_TC04_10M_LTE = []

PARAMETER_TO_DELETE_TC05_10M_LTE = []
PARAMETER_TO_MODIFY_TC05_10M_LTE = [
    dict(
        value="256QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeDl",
    ),
    dict(
        value="256QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeUL",
    ),
]
MOS_TO_ADD_TC05_10M_LTE = []
LIST_TO_ADD_TC05_10M_LTE = []
LIST_PARAMS_TO_MODIFY_TC05_10M_LTE = []

PARAMETER_TO_DELETE_TC06_10M_LTE = []
PARAMETER_TO_MODIFY_TC06_10M_LTE = [
    dict(
        value="256QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeDl",
    ),
    dict(
        value="256QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeUL",
    ),
]
MOS_TO_ADD_TC06_10M_LTE = []
LIST_TO_ADD_TC06_10M_LTE = []
LIST_PARAMS_TO_MODIFY_TC06_10M_LTE = []

PARAMETER_TO_DELETE_TC03_5M_LTE = []
PARAMETER_TO_MODIFY_TC03_5M_LTE = [
    dict(
        value="64QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeDl",
    ),
    dict(
        value="64QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeUL",
    ),
]
MOS_TO_ADD_TC03_5M_LTE = []
LIST_TO_ADD_TC03_5M_LTE = []
LIST_PARAMS_TO_MODIFY_TC03_5M_LTE = []
PARAMETER_TO_DELETE_TC04_5M_LTE = []
PARAMETER_TO_MODIFY_TC04_5M_LTE = [
    dict(
        value="64QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeDl",
    ),
    dict(
        value="64QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeUL",
    ),
]
MOS_TO_ADD_TC04_5M_LTE = []
LIST_TO_ADD_TC04_5M_LTE = []
LIST_PARAMS_TO_MODIFY_TC04_5M_LTE = []
PARAMETER_TO_DELETE_TC05_5M_LTE = []
PARAMETER_TO_MODIFY_TC05_5M_LTE = [
    dict(
        value="256QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeDl",
    ),
    dict(
        value="256QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeUL",
    ),
]
MOS_TO_ADD_TC05_5M_LTE = []
LIST_TO_ADD_TC05_5M_LTE = []
LIST_PARAMS_TO_MODIFY_TC05_5M_LTE = []

PARAMETER_TO_DELETE_TC06_5M_LTE = []
PARAMETER_TO_MODIFY_TC06_5M_LTE = [
    dict(
        value="256QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeDl",
    ),
    dict(
        value="256QAM",
        dist_name="MRBTS-11101/LNBTS-11101/LNCEL-1",
        p_name="actModulationSchemeUL",
    ),
]
MOS_TO_ADD_TC06_5M_LTE = []
LIST_TO_ADD_TC06_5M_LTE = []
LIST_PARAMS_TO_MODIFY_TC06_5M_LTE = []

PARAMETER_TO_DELETE_TC07 = []
PARAMETER_TO_MODIFY_TC07 = []
MOS_TO_ADD_TC07 = []
LIST_TO_ADD_TC07 = []
LIST_PARAMS_TO_MODIFY_TC07 = []

PARAMETER_TO_DELETE_TC08 = []
PARAMETER_TO_MODIFY_TC08 = []
MOS_TO_ADD_TC08 = []
LIST_TO_ADD_TC08 = []
LIST_PARAMS_TO_MODIFY_TC08 = []

PARAMETER_TO_DELETE_TC09 = []
PARAMETER_TO_MODIFY_TC09 = []
MOS_TO_ADD_TC09 = []
LIST_TO_ADD_TC09 = []
LIST_PARAMS_TO_MODIFY_TC09 = []

PARAMETER_TO_DELETE_TC10 = []
PARAMETER_TO_MODIFY_TC10 = []
MOS_TO_ADD_TC10 = []
LIST_TO_ADD_TC10 = []
LIST_PARAMS_TO_MODIFY_TC10 = []

PARAMETER_TO_DELETE_TC11 = []
PARAMETER_TO_MODIFY_TC11 = [
    # dict(value="60", dist_name="MRBTS-11101/NRBTS-11101", p_name="drbInactivityTimerSA"),
]
MOS_TO_ADD_TC11 = []
LIST_TO_ADD_TC11 = []
LIST_PARAMS_TO_MODIFY_TC11 = []

PARAMETER_TO_DELETE_TC11_LTE = []
PARAMETER_TO_MODIFY_TC11_LTE = [
    # dict(value="60", dist_name="MRBTS-11101/NRBTS-11101", p_name="drbInactivityTimerSA"),
]
MOS_TO_ADD_TC11_LTE = []
LIST_TO_ADD_TC11_LTE = []
LIST_PARAMS_TO_MODIFY_TC11_LTE = []

PARAMETER_TO_DELETE_TC12 = []
PARAMETER_TO_MODIFY_TC12 = []
MOS_TO_ADD_TC12 = []
LIST_TO_ADD_TC12 = []
LIST_PARAMS_TO_MODIFY_TC12 = []

PARAMETER_TO_DELETE_TC13 = []
PARAMETER_TO_MODIFY_TC13 = [
    dict(
        value="10",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="dtxMaxRetentionDelay",
    ),
    dict(
        value="4",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="ulSchedTimeInterval",
    ),
    dict(
        value="slots10",
        dist_name="MRBTS-11101/NRBTS-11101/NRCELL-1",
        p_name="srPeriodicityMin",
    ),
]
MOS_TO_ADD_TC13 = []
LIST_TO_ADD_TC13 = []
LIST_PARAMS_TO_MODIFY_TC13 = []

PARAMETER_TO_DELETE_TC14 = []
PARAMETER_TO_MODIFY_TC14 = [
    dict(
        value="sameGNB", dist_name="MRBTS-11101/NRBTS-11101", p_name="rrcReestabTypeSA"
    ),
]
MOS_TO_ADD_TC14 = []
LIST_TO_ADD_TC14 = []
LIST_PARAMS_TO_MODIFY_TC14 = []

PARAMETER_TO_DELETE_TC15 = []
PARAMETER_TO_MODIFY_TC15 = []
MOS_TO_ADD_TC15 = []
LIST_TO_ADD_TC15 = []
LIST_PARAMS_TO_MODIFY_TC15 = []

PARAMETER_TO_DELETE_TC16 = []
PARAMETER_TO_MODIFY_TC16 = []
MOS_TO_ADD_TC16 = []
LIST_TO_ADD_TC16 = []
LIST_PARAMS_TO_MODIFY_TC16 = []

PARAMETER_TO_DELETE_TC17 = []
PARAMETER_TO_MODIFY_TC17 = []
MOS_TO_ADD_TC17 = []
LIST_TO_ADD_TC17 = []
LIST_PARAMS_TO_MODIFY_TC17 = []

PARAMETER_TO_DELETE_TC18 = []
PARAMETER_TO_MODIFY_TC18 = []
MOS_TO_ADD_TC18 = []
LIST_TO_ADD_TC18 = []
LIST_PARAMS_TO_MODIFY_TC18 = []

PARAMETER_TO_DELETE_TC19 = []
PARAMETER_TO_MODIFY_TC19 = []
MOS_TO_ADD_TC19 = []
LIST_TO_ADD_TC19 = []
LIST_PARAMS_TO_MODIFY_TC19 = []

PARAMETER_TO_DELETE_TC20 = []
PARAMETER_TO_MODIFY_TC20 = []
MOS_TO_ADD_TC20 = []
LIST_TO_ADD_TC20 = []
LIST_PARAMS_TO_MODIFY_TC20 = []

PARAMETER_TO_DELETE_TC21 = []
PARAMETER_TO_MODIFY_TC21 = []
MOS_TO_ADD_TC21 = []
LIST_TO_ADD_TC21 = []
LIST_PARAMS_TO_MODIFY_TC21 = []

PARAMETER_TO_DELETE_TC22 = []
PARAMETER_TO_MODIFY_TC22 = []
MOS_TO_ADD_TC22 = []
LIST_TO_ADD_TC22 = []
LIST_PARAMS_TO_MODIFY_TC22 = []
