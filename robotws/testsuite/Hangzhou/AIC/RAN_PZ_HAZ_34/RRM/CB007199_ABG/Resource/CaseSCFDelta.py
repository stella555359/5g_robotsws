import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# modify CB007199_A01 SCF
# CU
PARAMS_TO_DELETE_CU_7199_A01 = [
    # NSA parameters
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SERVEDAMF-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SNSSAI-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/TRACKINGAREA-1", list_name="snssaiDNList"),
]

MOs_TO_ADD_CU_7199_A01 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRPLMNSET_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1/NRPLMNSET_NSA-1",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPLMNSET_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2/NRPLMNSET_NSA-1",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRMEASCFG_IF",
        dist_name="MRBTS-10550/NRBTS-10550/NRMEASCFG_IF-1",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRMOPRMA_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-1",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRMOPRMA_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-2",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRMOPRMA_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-3",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRMOPR_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-1",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRMOPR_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-2",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRMOPR_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-3",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPLMN",
        dist_name="MRBTS-10550/NRBTS-10550/NRPLMN-2",
        version="NRBTSCU23R1_2219_100",
    ),
]

PARAMS_TO_MODIFY_CU_7199_A01 = [
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="actIntraFreqIntraGnbMobilityNSA",
    ),
    dict(
        value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actMobilityProfile"
    ),
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actRanSharing"),
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actSPID"),
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actUeInitRlf"),
    dict(
        value="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="nrDefMoPrNsaDN",
    ),
    dict(
        value="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="nrDefMoPrNsaDN",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10550/NRBTS-10550/NRMEASCFG_IF-1",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10550/NRBTS-10550/NRMEASCFG_IF-1",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="78",
        dist_name="MRBTS-10550/NRBTS-10550/NRMEASCFG_IF-1",
        p_name="freqBandIndicatorNR",
    ),
    dict(
        value="636000",
        dist_name="MRBTS-10550/NRBTS-10550/NRMEASCFG_IF-1",
        p_name="ssbFrequency",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-1",
        p_name="mobilityProfilePriority",
    ),
    dict(
        value="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-1",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-1",
        p_name="nrMoPrNsaDN",
    ),
    dict(value="1", dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-1", p_name="spid"),
    dict(
        value="10",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-1",
        p_name="spidLast",
    ),
    dict(
        value="2",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-2",
        p_name="mobilityProfilePriority",
    ),
    dict(
        value="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-2",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-2",
        p_name="nrMoPrNsaDN",
    ),
    dict(value="1", dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-2", p_name="spid"),
    dict(
        value="10",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-2",
        p_name="spidLast",
    ),
    dict(
        value="3",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-3",
        p_name="mobilityProfilePriority",
    ),
    dict(
        value="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-3",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-3",
        p_name="nrMoPrNsaDN",
    ),
    dict(value="12", dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-3", p_name="spid"),
    dict(
        value="15",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-3",
        p_name="spidLast",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-1",
        p_name="a1MeashoEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-1",
        p_name="a2MeashoEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-2",
        p_name="a1MeashoEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-2",
        p_name="a2MeashoEnabled",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-3",
        p_name="a1MeashoEnabled",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-3",
        p_name="a2MeashoEnabled",
    ),
    dict(value="310", dist_name="MRBTS-10550/NRBTS-10550/NRPLMN-2", p_name="mcc"),
    dict(value="260", dist_name="MRBTS-10550/NRBTS-10550/NRPLMN-2", p_name="mnc"),
    dict(value="3", dist_name="MRBTS-10550/NRBTS-10550/NRPLMN-2", p_name="mncLength"),
    dict(
        value="15min", dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1", p_name="miNrNRMOP"
    ),
    # NSA parameters
    dict(value="false", dist_name="MRBTS-10550/NRBTS-10550", p_name="actNgcFlexSaMode"),
    dict(value="NSA", dist_name="MRBTS-10550/NRBTS-10550", p_name="gNbCuType"),
    dict(
        value="NSA", dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="cellDepType"
    ),
    dict(
        value="NSA", dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="cellDepType"
    ),
]


LIST_PARAMS_TO_MODIFY_CU_7199_A01 = []


LIST_TO_ADD_CU_7199_A01 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1/NRPLMNSET_NSA-1",
        list_name="nrPlmnDNList",
        elements=["MRBTS-10550/NRBTS-10550/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2/NRPLMNSET_NSA-1",
        list_name="nrPlmnDNList",
        elements=["MRBTS-10550/NRBTS-10550/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-1",
        list_name="nrPlmnDNList",
        elements=["MRBTS-10550/NRBTS-10550/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-2",
        list_name="nrPlmnDNList",
        elements=["MRBTS-10550/NRBTS-10550/NRPLMN-2"],
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPRMA_NSA-3",
        list_name="nrPlmnDNList",
        elements=["MRBTS-10550/NRBTS-10550/NRPLMN-1"],
    ),
    # dict(dist_name='MRBTS-10550/NRBTS-10550/NRMOPR_NSA-1', list_name='nrMeasCfgIfDNList',
    #      elements=['MRBTS-10550/NRBTS-10550/NRMEASCFG_IF-1']),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-2",
        list_name="nrMeasCfgIfDNList",
        elements=["MRBTS-10550/NRBTS-10550/NRMEASCFG_IF-1"],
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRMOPR_NSA-3",
        list_name="nrMeasCfgIfDNList",
        elements=["MRBTS-10550/NRBTS-10550/NRMEASCFG_IF-1"],
    ),
]


# DU

PARAMS_TO_DELETE_DU_7199_A01 = [
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="configuredEpsTac"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="configuredEpsTac"),
    # NSA parameters
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SNSSAI-1", list_name="f1Uplane"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/TRACKINGAREA-1", list_name="snssaiDNList"),
]

MOs_TO_ADD_DU_7199_A01 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRPLMNSET_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1/NRPLMNSET_NSA-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPLMNSET_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2/NRPLMNSET_NSA-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPLMN",
        dist_name="MRBTS-10550/NRBTS-10550/NRPLMN-2",
        version="NRBTSVDU23R1_2219_100",
    ),
]

PARAMS_TO_MODIFY_DU_7199_A01 = [
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actRanSharing"),
    dict(
        value="20200",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1/NRPLMNSET_NSA-1",
        p_name="configuredEpsTac",
    ),
    dict(
        value="20200",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2/NRPLMNSET_NSA-1",
        p_name="configuredEpsTac",
    ),
    dict(value="310", dist_name="MRBTS-10550/NRBTS-10550/NRPLMN-2", p_name="mcc"),
    dict(value="260", dist_name="MRBTS-10550/NRBTS-10550/NRPLMN-2", p_name="mnc"),
    dict(value="3", dist_name="MRBTS-10550/NRBTS-10550/NRPLMN-2", p_name="mncLength"),
    # NSA parameters
    dict(
        value="false",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="actSACallProcessingDU",
    ),
    dict(value="NSA", dist_name="MRBTS-10550/NRBTS-10550", p_name="gNbCuType"),
    dict(
        value="NSA", dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="cellDepType"
    ),
    dict(
        value="NSA", dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="cellDepType"
    ),
]

LIST_PARAMS_TO_MODIFY_DU_7199_A01 = []

LIST_TO_ADD_DU_7199_A01 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1/NRPLMNSET_NSA-1",
        list_name="nrPlmnDNList",
        elements=["MRBTS-10550/NRBTS-10550/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2/NRPLMNSET_NSA-1",
        list_name="nrPlmnDNList",
        elements=["MRBTS-10550/NRBTS-10550/NRPLMN-1"],
    ),
]
