import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

PARAMS_TO_MODIFY_1008_PB_3 = [
    dict(value="3", dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-1", p_name="sd"),
    dict(value="129", dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-1", p_name="sst"),
]

ADD_MOs = [
    dict(
        class_name="com.nokia.srbts.nrbts:SNSSAI",
        dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-2",
        version="NRBTSCL5G20A_2003_200",
    )
]

ADD_Elements_TO_MO = [
    dict(
        value="Unlocked",
        dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-2",
        p_name="administrativeState",
    ),
    dict(value="1", dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-2", p_name="sd"),
    dict(value="129", dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-2", p_name="sst"),
]

ADD_Lists_TO_MO = [
    dict(dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-2", list_name="nrPlmnDNList")
]

ADD_Elements_TO_List = [
    dict(
        dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-2",
        list_name="nrPlmnDNList",
        elements=["MRBTS-1107/NRBTS-1107/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-1107/NRBTS-1107/TRACKINGAREA-210",
        list_name="snssaiDNList",
        elements=["MRBTS-1107/NRBTS-1107/SNSSAI-2"],
    ),
]

PARAMS_TO_ADD_1008_O_4 = [
    ADD_MOs,
    ADD_Elements_TO_MO,
    ADD_Lists_TO_MO,
    ADD_Elements_TO_List,
]


PARAMS_TO_MODIFY_1008_PC_1 = [
    dict(value="234", dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-1", p_name="sd"),
    dict(value="132", dist_name="MRBTS-1107/NRBTS-1107/SNSSAI-1", p_name="sst"),
]

# ####################################### modify 1008_B_case2 SCF ##############################################
PARAMS_TO_MODIFY_1008_B_case2 = [
    dict(value="5GC001008_B_case2_TA_S1_SA", dist_name="MRBTS-1903", p_name="btsName"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3", p_name="gNbCuType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="cellDepType"),
    # #x2Link
    dict(value="0", dist_name="MRBTS-1903/NRBTS-3", p_name="x2LinkSupervisionTmr"),
]

PARAMS_TO_DELETE_1008_B_case2 = [
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="configuredEpsTac")
]

# ####################################modify 1008_EA_case6 SCF#######################
PARAMS_TO_MODIFY_1008_EA_case6 = [
    dict(value="5GC001008_EA_case6_TA_SA", dist_name="MRBTS-1903", p_name="btsName"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3", p_name="gNbCuType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="cellDepType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="cellDepType"),
    dict(value="0", dist_name="MRBTS-1903/NRBTS-3", p_name="x2LinkSupervisionTmr"),
    dict(
        value="Unlocked",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        p_name="administrativeState",
    ),
    dict(value="1", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2", p_name="sd"),
    dict(value="128", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2", p_name="sst"),
]

PARAMS_TO_DELETE_1008_EA_case6 = [
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="configuredEpsTac"),
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="configuredEpsTac"),
]

ADD_MOs_1008_EA_case6 = [
    dict(
        class_name="com.nokia.srbts.nrbts:SNSSAI",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        version="NRBTSCL5G20A_2003_200",
    ),
]

LIST_TO_ADD_1008_EA_case6 = [
    dict(
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        list_name="nrPlmnDNList",
        elements=["MRBTS-1903/NRBTS-3/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-210",
        list_name="snssaiDNList",
        elements=["MRBTS-1903/NRBTS-3/SNSSAI-2"],
    ),
]

MODIFY_List_1008_EA_case6 = []

# ####################################modify 1008_PC_case7 SCF#######################
PARAMS_TO_MODIFY_1008_PC_case7 = [
    dict(
        value="5GC001008_PC_case7_TA_S11_SA", dist_name="MRBTS-1903", p_name="btsName"
    ),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3", p_name="gNbCuType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="cellDepType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="cellDepType"),
    dict(
        value="Unlocked",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        p_name="administrativeState",
    ),
    dict(value="1", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2", p_name="sd"),
    dict(value="128", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2", p_name="sst"),
    dict(
        value="220", dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-220", p_name="fiveGsTac"
    ),
    # x2Link
    dict(value="0", dist_name="MRBTS-1903/NRBTS-3", p_name="x2LinkSupervisionTmr"),
    dict(
        value="MRBTS-10031/NRBTS-10031/TRACKINGAREA-220",
        dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2",
        p_name="trackingAreaDN",
    ),
]

PARAMS_TO_DELETE_1008_PC_case7 = [
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="configuredEpsTac"),
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="configuredEpsTac"),
]

ADD_MOs_1008_PC_case7 = [
    dict(
        class_name="com.nokia.srbts.nrbts:SNSSAI",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        version="NRBTSCL5G20A_2003_200",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:TRACKINGAREA",
        dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-220",
        version="NRBTSCL5G20A_2003_200",
    ),
]

ADD_Lists_TO_MO_1008_PC_case7 = [
    dict(
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        list_name="nrPlmnDNList",
        elements=["MRBTS-1903/NRBTS-3/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-220",
        list_name="snssaiDNList",
        elements=["MRBTS-1903/NRBTS-3/SNSSAI-2"],
    ),
]

MODIFY_List_1008_PC_case7 = []

# ####################################modify 1008_PC_case8 SCF#######################
PARAMS_TO_MODIFY_1008_PC_case8 = [
    dict(
        value="5GC001008_PC_case8_TA_S11_SA", dist_name="MRBTS-1903", p_name="btsName"
    ),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3", p_name="gNbCuType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="cellDepType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="cellDepType"),
    dict(value="1", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-1", p_name="sd"),
    dict(value="128", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-1", p_name="sst"),
    dict(
        value="Locked",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        p_name="administrativeState",
    ),
    dict(
        value="120",
        dist_name="MRBTS-1903/NRBTS-3",
        p_name="waitForRecovBeforeCellBarringTimer",
    ),
]

PARAMS_TO_DELETE_1008_PC_case8 = [
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="configuredEpsTac"),
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="configuredEpsTac"),
]

ADD_MOs_1008_PC_case8 = [
    dict(
        class_name="com.nokia.srbts.nrbts:SNSSAI",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        version="NRBTSCL5G20A_2003_200",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:TRACKINGAREA",
        dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-220",
        version="NRBTSCL5G20A_2003_200",
    ),
]

LIST_TO_ADD_1008_1008_PC_case8 = [
    dict(
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        list_name="nrPlmnDNList",
        elements=["MRBTS-1903/NRBTS-3/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-220",
        list_name="snssaiDNList",
        elements=["MRBTS-1903/NRBTS-3/SNSSAI-2"],
    ),
]

MODIFY_List_1008_PC_case8 = []

# ####################################modify 1008_EA_case10 SCF#######################
PARAMS_TO_MODIFY_1008_EA_case10 = [
    dict(value="5GC001008_EA_case10_TA_SA", dist_name="MRBTS-1903", p_name="btsName"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3", p_name="gNbCuType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="cellDepType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="cellDepType"),
    dict(value="0", dist_name="MRBTS-1903/NRBTS-3", p_name="x2LinkSupervisionTmr"),
    dict(
        value="Unlocked",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-3",
        p_name="administrativeState",
    ),
    dict(value="123", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-3", p_name="sd"),
    dict(value="129", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-3", p_name="sst"),
    dict(
        value="220", dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-220", p_name="fiveGsTac"
    ),
    dict(
        value="MRBTS-10032/NRBTS-10032/TRACKINGAREA-220",
        dist_name="MRBTS-10032/NRBTS-10032/NRCELL-2",
        p_name="trackingAreaDN",
    ),
]

PARAMS_TO_DELETE_1008_EA_case10 = [
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="configuredEpsTac"),
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="configuredEpsTac"),
]

ADD_MOs_1008_EA_case10 = [
    dict(
        class_name="com.nokia.srbts.nrbts:SNSSAI",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-3",
        version="NRBTSCL5G20A_2003_200",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:TRACKINGAREA",
        dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-220",
        version="NRBTSCL5G20A_2003_200",
    ),
]


LIST_TO_ADD_1008_EA_case10 = [
    dict(
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-3",
        list_name="nrPlmnDNList",
        elements=["MRBTS-1903/NRBTS-3/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-220",
        list_name="snssaiDNList",
        elements=["MRBTS-1903/NRBTS-3/SNSSAI-3"],
    ),
]

MODIFY_List_1008_EA_case10 = []

# ####################################### modify 1008_PD_case10 SCF ##############################################
PARAMS_TO_REMOVE_1008_PD_10 = [
    dict(dist_name="MRBTS-19211/NRBTS-1211/SNSSAI-1", p_name="sd")
]

PARAMS_TO_MODIFY_1008_PD_10 = [
    dict(
        value="5min",
        dist_name="MRBTS-19211/NRBTS-1211/NRPMRNL-1",
        p_name="miNrSlicingCuUp",
    )
]

# ####################################### modify 1008_E_case11 SCF ##############################################
PARAMS_TO_MODIFY_1008_E_case11 = [
    dict(value="5GC001008_E_case11_TA_SA", dist_name="MRBTS-1903", p_name="btsName"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3", p_name="gNbCuType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="cellDepType"),
    dict(value="SA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="cellDepType"),
    dict(value="0", dist_name="MRBTS-1903/NRBTS-3", p_name="x2LinkSupervisionTmr"),
    dict(
        value="Unlocked",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        p_name="administrativeState",
    ),
    dict(value="1", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2", p_name="sd"),
    dict(value="128", dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2", p_name="sst"),
]

PARAMS_TO_DELETE_1008_E_case11 = [
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="configuredEpsTac"),
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="configuredEpsTac"),
]

ADD_MOs_1008_E_case11 = [
    dict(
        class_name="com.nokia.srbts.nrbts:SNSSAI",
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        version="NRBTSCL5G20A_2003_200",
    ),
]

LIST_TO_ADD_1008_E_case11 = [
    dict(
        dist_name="MRBTS-1903/NRBTS-3/SNSSAI-2",
        list_name="nrPlmnDNList",
        elements=["MRBTS-1903/NRBTS-3/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-1903/NRBTS-3/TRACKINGAREA-210",
        list_name="snssaiDNList",
        elements=["MRBTS-1903/NRBTS-3/SNSSAI-2"],
    ),
]
