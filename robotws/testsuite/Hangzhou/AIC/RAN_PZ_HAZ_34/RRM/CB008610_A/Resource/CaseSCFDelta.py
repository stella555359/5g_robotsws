import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# modify CB008610_7552 SCF
# CU
PARAMS_TO_DELETE_CU_8610_7552 = [
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", list_name="cellBwpList"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", list_name="cellBwpList"),
    # NSA parameters
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SERVEDAMF-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SNSSAI-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/TRACKINGAREA-1", list_name="snssaiDNList"),
]

MOs_TO_ADD_CU_8610_7552 = [
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52",
        version="NRBTSCU23R1_2219_100",
    ),
]

PARAMS_TO_MODIFY_CU_8610_7552 = [
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="actIntraFreqIntraGnbMobilityNSA",
    ),
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actUeInitRlf"),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="actMultipleDedicatedBWPs",
    ),
    dict(
        value="initial",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50",
        p_name="bwpType",
    ),
    dict(
        value="dedicated",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51",
        p_name="bwpType",
    ),
    dict(
        value="dedicated",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52",
        p_name="bwpType",
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


LIST_PARAMS_TO_MODIFY_CU_8610_7552 = []


LIST_TO_ADD_CU_8610_7552 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="n133"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="n273"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="n133"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50", cellBwpId="0"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51", cellBwpId="1"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52", cellBwpId="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50", cellBwpId="0"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51", cellBwpId="1"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52", cellBwpId="2"),
    ),
]


# DU

PARAMS_TO_DELETE_DU_8610_7552 = [
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", list_name="cellBwpList"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", list_name="cellBwpList"),
    # NSA parameters
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SNSSAI-1", list_name="f1Uplane"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/TRACKINGAREA-1", list_name="snssaiDNList"),
]

MOs_TO_ADD_DU_8610_7552 = [
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDSCH",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDSCH-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        version="NRBTSVDU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDSCH",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDSCH-1",
        version="NRBTSVDU23R1_2219_100",
    ),
]

PARAMS_TO_MODIFY_DU_8610_7552 = [
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="actMultipleDedicatedBWPs",
    ),
    dict(
        value="34",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="msg1FrequencyStart",
    ),
    dict(
        value="34",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="msg1FrequencyStart",
    ),
    dict(
        value="initial",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50",
        p_name="bwpType",
    ),
    dict(
        value="static",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1",
        p_name="alSelection",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1",
        p_name="dciDedicatedAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1",
        p_name="dciPagingAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1",
        p_name="dciRaCompletionAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1",
        p_name="dciRaMsg2AggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1",
        p_name="dciSiAggregationLevel",
    ),
    dict(
        value="notAllowed",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1",
        p_name="downgradeAL16toAL8",
    ),
    dict(
        value="dedicated",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51",
        p_name="bwpType",
    ),
    dict(
        value="static",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1",
        p_name="alSelection",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1",
        p_name="dciDedicatedAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1",
        p_name="dciPagingAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1",
        p_name="dciRaCompletionAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1",
        p_name="dciRaMsg2AggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1",
        p_name="dciSiAggregationLevel",
    ),
    dict(
        value="notAllowed",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1",
        p_name="downgradeAL16toAL8",
    ),
    dict(
        value="config1",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDSCH-1",
        p_name="pdschRat0RbgConfig",
    ),
    dict(
        value="dedicated",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52",
        p_name="bwpType",
    ),
    dict(
        value="static",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1",
        p_name="alSelection",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1",
        p_name="dciDedicatedAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1",
        p_name="dciPagingAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1",
        p_name="dciRaCompletionAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1",
        p_name="dciRaMsg2AggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1",
        p_name="dciSiAggregationLevel",
    ),
    dict(
        value="notAllowed",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1",
        p_name="downgradeAL16toAL8",
    ),
    dict(
        value="config1",
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDSCH-1",
        p_name="pdschRat0RbgConfig",
    ),
    dict(
        value="longPucch",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="pucchModeSelect",
    ),
    dict(
        value="longPucch",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="pucchModeSelect",
    ),
    dict(
        value="useInitialBwp",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="ueConnectionEstablishmentMode",
    ),
    dict(
        value="useInitialBwp",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="ueConnectionEstablishmentMode",
    ),
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

LIST_PARAMS_TO_MODIFY_DU_8610_7552 = []

LIST_TO_ADD_DU_8610_7552 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="n133", cRbStartDl="crb0"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl", cRbStartUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="coresetDedicated",
        elements=dict(
            cRbStart="0",
            cceToRegMapping="nonInterleaved",
            coresetId="1",
            duration="1",
            interleaverSize="none",
            regBundleSize="n6",
            size="120",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="1",
            searchSpaceType="Type3",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="1",
            dciFormat="formats0-1-And-1-1",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n5",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="2",
            searchSpaceType="UE-Specific",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="n273", cRbStartDl="crb0"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl", cRbStartUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="3",
            searchSpaceType="Type1",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="coresetDedicated",
        elements=dict(
            cRbStart="0",
            cceToRegMapping="nonInterleaved",
            coresetId="1",
            duration="1",
            interleaverSize="none",
            regBundleSize="n6",
            size="120",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="4",
            searchSpaceType="Type3",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="1",
            dciFormat="formats0-1-And-1-1",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n5",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="5",
            searchSpaceType="UE-Specific",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="n133", cRbStartDl="crb0"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl", cRbStartUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="6",
            searchSpaceType="Type1",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="coresetDedicated",
        elements=dict(
            cRbStart="0",
            cceToRegMapping="nonInterleaved",
            coresetId="4",
            duration="1",
            interleaverSize="none",
            regBundleSize="n6",
            size="120",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="7",
            searchSpaceType="Type3",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="4",
            dciFormat="formats0-1-And-1-1",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n5",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="8",
            searchSpaceType="UE-Specific",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50", cellBwpId="0"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51", cellBwpId="1"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52", cellBwpId="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-50", cellBwpId="0"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-51", cellBwpId="1"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        list_name="cellBwpList",
        elements=dict(bwpDN="MRBTS-10550/NRBTS-10550/BWP_PROFILE-52", cellBwpId="2"),
    ),
]


# modify CB008610_6127 SCF
# CU
PARAMS_TO_DELETE_CU_8610_6127 = [
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="nrSysInfoProfileDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="nrSysInfoProfileDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIAFIM-1"),
    # NSA parameters
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SERVEDAMF-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SNSSAI-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/TRACKINGAREA-1", list_name="snssaiDNList"),
]

MOs_TO_ADD_CU_8610_6127 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRANR",
        dist_name="MRBTS-10550/NRBTS-10550/NRANR-1",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRANRPR",
        dist_name="MRBTS-10550/NRBTS-10550/NRANRPR-1",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRSYSINFO_PROFILE",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRIAFIM",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        version="NRBTSCU23R1_2219_100",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRIRFIM",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        version="NRBTSCU23R1_2219_100",
    ),
]

PARAMS_TO_MODIFY_CU_8610_6127 = [
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="actEnhanceIntraNrIntraFreqAnr",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="actIntraFreqIntraGnbMobilityNSA",
    ),
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actUeInitRlf"),
    dict(
        value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actNsaUeBasedAnrNr"
    ),
    dict(
        value="rsrq",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="rsrq",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="absThreshSsbRsrqConsolidation",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="absThreshSsbRsrqConsolidation",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10550/NRBTS-10550/NRANR-1",
        p_name="actAutoEutraNbRemoval",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550/NRANR-1",
        p_name="actAutoNrNbRemoval",
    ),
    dict(
        value="3",
        dist_name="MRBTS-10550/NRBTS-10550/NRANR-1",
        p_name="consecHoFailThres",
    ),
    dict(
        value="3",
        dist_name="MRBTS-10550/NRBTS-10550/NRANR-1",
        p_name="consecHoFailThresEutra",
    ),
    dict(
        value="-140",
        dist_name="MRBTS-10550/NRBTS-10550/NRANRPR-1",
        p_name="anrThresRsrpNbCell",
    ),
    dict(
        value="-70",
        dist_name="MRBTS-10550/NRBTS-10550/NRANRPR-1",
        p_name="anrThresRsrqNbCell",
    ),
    dict(
        value="RSRQ",
        dist_name="MRBTS-10550/NRBTS-10550/NRANRPR-1",
        p_name="anrThresholdSelector",
    ),
    dict(
        value="NSA", dist_name="MRBTS-10550/NRBTS-10550/NRANRPR-1", p_name="cellDepMode"
    ),
    dict(
        value="5",
        dist_name="MRBTS-10550/NRBTS-10550/NRANRPR-1",
        p_name="consecRecheckForNrNbRemoval",
    ),
    dict(
        value="2",
        dist_name="MRBTS-10550/NRBTS-10550/NRANRPR-1",
        p_name="idleTimeForNrNbRemoval",
    ),
    dict(
        value="50",
        dist_name="MRBTS-10550/NRBTS-10550/NRANRPR-1",
        p_name="maxNumAnrNrrelAllowed",
    ),
    dict(
        value="dB-6",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        p_name="addHystSfHigh",
    ),
    dict(
        value="dB-4",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        p_name="addHystSfMedium",
    ),
    dict(
        value="2",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        p_name="nCellChangeHigh",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        p_name="nCellChangeMedium",
    ),
    dict(
        value="dB0",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        p_name="qHyst",
    ),
    dict(
        value="s30",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        p_name="tEvaluation",
    ),
    dict(
        value="s30",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        p_name="tHystNormal",
    ),
    dict(
        value="0",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        p_name="tReselectionEutra",
    ),
    dict(
        value="0",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        p_name="threshServingLowP",
    ),
    dict(
        value="-40",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="qRxLevMin",
    ),
    dict(
        value="22",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="sIntraSearchP",
    ),
    dict(
        value="0",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="sIntraSearchQ",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="tReselectionNr",
    ),
    dict(
        value="oDot2",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="cellReselectionSubPriority",
    ),
    dict(
        value="7874",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="dlCarrierFreq",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="dssCellsDeployed",
    ),
    dict(
        value="78",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="freqBandIndicatorNR",
    ),
    dict(
        value="-20dB",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="qOffsetFreq",
    ),
    dict(
        value="-65",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="qRxLevMin",
    ),
    dict(
        value="30 KHz",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="ssbScs",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="tReselectionNr",
    ),
    dict(
        value="30",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="threshXHighP",
    ),
    dict(
        value="2",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="threshXHighQ",
    ),
    dict(
        value="22",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="threshXLowP",
    ),
    dict(
        value="0",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="threshXLowQ",
    ),
    dict(
        value="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="nrSysInfoProfileDN",
    ),
    dict(
        value="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="nrSysInfoProfileDN",
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


LIST_PARAMS_TO_MODIFY_CU_8610_6127 = []


LIST_TO_ADD_CU_8610_6127 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRANR-1",
        list_name="gNbIdLengthConfig",
        elements=dict(
            gNbIdLength="22",
            nciEnd="172851210",
            nciStart="172851200",
            priorityIndex="1",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        list_name="a3MeasSsbRsrq",
        elements=dict(
            a3HysteresisSsbRsrq="0",
            a3OffsetSsbRsrq="-30",
            a3TimeToTriggerSsbRsrq="ms256",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        list_name="a3MeasSsbRsrq",
        elements=dict(
            a3HysteresisSsbRsrq="0",
            a3OffsetSsbRsrq="-30",
            a3TimeToTriggerSsbRsrq="ms256",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="notBroadcasting",
            sibPeriodicity="rf512",
            sibScope="cellSpecific",
            sibType="sibType2",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="notBroadcasting",
            sibPeriodicity="rf512",
            sibScope="cellSpecific",
            sibType="sibType3",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="notBroadcasting",
            sibPeriodicity="rf512",
            sibScope="cellSpecific",
            sibType="sibType4",
        ),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="notBroadcasting",
            sibPeriodicity="rf512",
            sibScope="cellSpecific",
            sibType="sibType5",
        ),
    ),
]


# DU

PARAMS_TO_DELETE_DU_8610_6127 = [
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="nrSysInfoProfileDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="nrSysInfoProfileDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE-1/NRIAFIM-1"),
    # NSA parameters
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SNSSAI-1", list_name="f1Uplane"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/TRACKINGAREA-1", list_name="snssaiDNList"),
]

MOs_TO_ADD_DU_8610_6127 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRSYSINFO_PROFILE_NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE_NSA-1",
        version="NRBTSVDU23R1_2219_100",
    ),
]

PARAMS_TO_MODIFY_DU_8610_6127 = [
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="actEnhanceIntraNrIntraFreqAnr",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="actSib1ForNsaCell",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="actSib1ForNsaCell",
    ),
    dict(
        value="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE_NSA-1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="nrSysInfoNsaProfileDN",
    ),
    dict(
        value="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE_NSA-1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="nrSysInfoNsaProfileDN",
    ),
    dict(
        value="0",
        dist_name="MRBTS-10550/NRBTS-10550/NRSYSINFO_PROFILE_NSA-1",
        p_name="systemInformationTargetRate",
    ),
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

LIST_PARAMS_TO_MODIFY_DU_8610_6127 = []

LIST_TO_ADD_DU_8610_6127 = []
