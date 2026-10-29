*** Settings ***
Documentation
...    author:  susana.yan@nokia-sbell.com
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-PZ3_7
...     owner-susana.yan    release-SBTS24R3     CNI108979
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SWCONFIG_GNB2}
...    @{rdEnableDynamicBetaOffsets}

@{rdEnableDynamicBetaOffsets}
...    0x5900D4=0

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_VoNR}
...    @{PARAMS_FOR_5GC000545}
...    @{PARAMS_FOR_CB008236}
...    @{PARAMS_FOR_A3}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{CNI108979}
...    @{bwpfix1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_VoNR}
...    @{PARAMS_FOR_5GC000545}
...    @{PARAMS_FOR_CB008236}
...    @{PARAMS_FOR_A3}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{CNI108979}
...    @{bwpfix2}

@{bwpfix1}
...    NRCELL-12:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-12:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL:pdcchAutoConfig:cellCoverageLevel=normal
...    NRCELL:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL:pdcchAutoConfig:fineTuneMode=disabled

@{bwpfix2}
...    NRCELL-14:cellBwpList:cellBwpId=0|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-1
...    NRCELL-14:cellBwpList:cellBwpId=1|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4:bwpType=dedicated
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-4/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-4/PDCCH-1:downgradeALProactive=false
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL:pdcchAutoConfig:cellCoverageLevel=normal
...    NRCELL:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL:pdcchAutoConfig:fineTuneMode=disabled

@{CNI108979}
...    NRCELL:actUlTransPreEnhHo=true
...    NRCELL:ulPtrs:actUlPtrs=false
...    NRCELL:actDl256Qam=true
...    NRCELL:actUl256Qam=true

@{PARAMS_FOR_VoNR}
...    NRBTS:actNormVCFallback=false
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:srPeriodicity=slots40
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL:actVoipPacketAggr=true
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=NRDRB_MAC-4
...    NRBTS/NRDRB-10:nrDrbPdcpDN=NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-4:lcgid=0
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_PDCP-2:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-2:tReorderingUl=ms100
...    NRBTS/NRDRB_RLC_AM-2:ulMaxRetxThreshold=t16

@{PARAMS_FOR_5QI1}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=NRDRB_MAC-3
...    NRBTS/NRDRB-15:nrDrbPdcpDN=NRDRB_PDCP-2
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=0
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

@{PARAMS_FOR_5GC000545}
...    NRBTS:actTdraFallback=false
...    NRCELL:actUlDftSOfdm=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:puschMappingType=TypeB
...    NRCELL:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180

@{PARAMS_FOR_CB008236}
...    NRCELL:actUlSlotAgg=Disabled
...    NRCELL:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL:maxHarqBundlesUlSlotAgg=10
...    NRCELL:minTbsUlSlotAgg=384
...    NRCELL:maxNumPuschAllocationPerSlot=2

@{PARAMS_FOR_A3}
...    NRBTS:actIncXn=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.3
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:ssbFrequency=368430
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gNbId=2
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gNbIdLength=22
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:handoverAllowedSARedCap=forbidden
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:isRplCellForPSCell=false
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:lcrId=13
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:nrDcAllowed=false
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:removeNotAllowed=false
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gnbPlmn:mncLength=3

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.2
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=368430
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gNbId=1
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gNbIdLength=22
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:handoverAllowedSARedCap=forbidden
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:isRplCellForPSCell=false
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:lcrId=11
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:nrDcAllowed=false
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:removeNotAllowed=false
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gnbPlmn:mncLength=3

${SA_Capa_Support_SAG}    SEPARATOR=
...    E9A09000575F5A13560003C5280016005000002018093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB02
...    7C62471E439F51CF9863CA1607038782E007FE0038002F8003600001C0A836016B04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB00
...    0000FEC000000D80000702A8D899AC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B00000E0541B06F5823086820
...    41E21100195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006C0000381546C4DD608C21A00000404400616C932A221CF88E3C831E819F60
...    4F8073E618F28581C0E1E0BD5555554F55555550D800007004961E26000713000000058158B898001C4C000E260000010B02B17008003098061300004160563E01000606C0C2
...    60184C0001858158B8040018020303600040B02B1F00800300C0606C0C26800142C0AC5C02000C0D8184C0003058158780400184C00038581587804001802000405815878360
...    0181B000485815878040018060005058158780C00181B0005858158B80400180603036000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89800184C0300
...    40606C001E160562E2600060080C0D800402C0AC7C4D000C01018060303600110B0201200DC0068099000A0268DA001D212851226C73E1C4891226C73E1C4891226C73E1C689
...    12244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226
...    C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D07C001E00140E0A00E0601280380030120020301F048010000000080040000
...    001000006008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A0040000580200102409
...    00400006019CA9ACA9AC14AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29302000032CA48080001CB29202000092CA48080002CB293020000
...    D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A814
...    5526AAA0F143C00BC04A8140A05028140A05028140A05028140A05028140A0022101002004040080110080100202004008080100220100C01404008010100200460201802808
...    0600A02004008080100220101001404040050101602C602018030080600A02018030080100220100C014040300501002004202018028080100210100C014040300508080600C
...    02018030404030060100C014202018028080600A20100C01404030060100C014202018030080100220100200404008010100C014602004008080100202018028080600A20100
...    200404030060100C018602004008080600A02018030080600A3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{TP_activate_check}
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationList setup
...    criticalExtensions rrcReconfigurationComplete

@{TP_disable}
...    criticalExtensions rrcReconfiguration
...    transformPrecoder disabled
...    criticalExtensions rrcReconfigurationComplete

@{HO_With_TP_On}
    ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.transformPrecoderInd == 1 @0
    ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.transformPrecoderInd == 2 @0
    ...    (itf_l2_ps_user_UserSetupReq_t.tpStateInSourceCell_item == 1) && !(itf_l2_ps_user_UserSetupReq_t.sagStateInSourceCell_item == 1) @1

@{HO_With_TP_Off}
    ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.transformPrecoderInd == 1 @0
    ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.transformPrecoderInd == 2 @0
    ...    (itf_l2_ps_user_UserSetupReq_t.tpStateInSourceCell_item == 0) && !(itf_l2_ps_user_UserSetupReq_t.sagStateInSourceCell_item == 1) @1

@{expect_HOToGNB2}
...    transformPrecoder enabled
...    pusch-TimeDomainAllocationList setup
...    Inter-eNB handover from EXT_ENB-2.11 to EXT_ENB-3.13 performed
...    Setup QosFlow with QFI:1 SEID:1
...    Setup QosFlow with QFI:1 SEID:2
...    Setup QosFlow with QFI:2 SEID:2
...    tp-pi2BPSK enabled

@{expect_HOToGNB1}
...    transformPrecoder disabled
...    pusch-TimeDomainAllocationList setup
...    Inter-eNB handover from EXT_ENB-3.13 to EXT_ENB-2.11 performed
...    Setup QosFlow with QFI:1 SEID:1
...    Setup QosFlow with QFI:1 SEID:2
...    Setup QosFlow with QFI:2 SEID:2

*** Test Cases ***
CNI108979-ET-002_Verify_TP_Keep_On_After_Inter_Gnb_HO_with_feature_Enabled_Without_dedicated_RRC_ReConfiguration_For_VONR
    [Documentation]
    ...    1.This scenario describes gNB behavior When a UE in poor RF coverage and configured with PUSCH DFT-s-OFDM at a cell with CNI-108979 enabled
    ...      perform inter gnb HO with target cell CNI-108979 enabled. Upon completion of the handover, the UE at the target cell continues configured
    ...      for PUSCH DFT-s-OFDM (without the need for additional, dedicated RRC Reconfiguration)
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_25544, partially covered
    ...    CNI-108979#1: PUSCH Transform Precoder Continues at Target Cell
    ...    2.[Configuration]:
    ...    Cell id=11 gnb=1 pci=20:0 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz Cellid=0x800b/32779 ssbFrequency=368430
    ...    Cell id=12 gnb=1 pci=20:1 tdd_cell=off band=n28 nr_arfcn=145000:156000 gscn=1950 chBw=15MHz Cellid=0x800c/32780 ssbFrequency=156030
    ...    Cell id=13 gnb=2 pci=20:2 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz Cellid=0x800b/32779 ssbFrequency=368430
    ...    Cell id=14 gnb=2 pci=21:0 tdd_cell=off band=n71 nr_arfcn=136100:126900 gscn=1584 chBw=15MHz Cellid=0x800d/32780 ssbFrequency=126750
    ...    3. Test Case Steps:
    ...         a. Trigger UE1 normal call with 5QI6 with traffic and VONR Call then trigger TP on.
    ...         b. UE1 perform inter gnb HO from gnb1 CELL11 to gnb2 CELL13
    ...         c. UE1 adjust SINR to make TP off and TP on some times and stay on TP off state.
    ...         d. Handover UE1 back to CELL1.
    ...         e. UE1 releases.
    ...    4. Expect result:
    ...         a. UE attach successfully with stable traffic, transformPrecoder set to true.
    ...         b. Handover successfully.
    ...          1)check on PsUser_UserSetupReq tpStateInSourceCell should be enabled
    ...          2)Upon receipt of RrcReconfigurationComplete from UE for HO completion, no dedicated RRC ReConfiguration procedure for TP.
    ...         c. TP can be enable or disable successfully.
    ...          1)Verify transformPrecoder set to disabled when tp off
    ...          2)Verify transformPrecoder set to enabled when tp on
    ...         d. Handover successfully.
    ...          1)check on PsUser_UserSetupReq tpStateInSourceCell should be disabled.
    ...          2)Upon receipt of RrcReconfigurationComplete from UE for HO completion, no dedicated RRC ReConfiguration procedure for TP.
    ...         e. Deregister successfully.
    [Tags]    002    004    QC_47185
    UE Trigger Normal Call with Traffic and VONR Call Then Trigger TP On
    UE Tirgger Intra-Freq Inter-GNB HO By Event A3    targetgnbWirsharkdir=gnb2    targetpci=62    wiresharkchecklist=${HO_With_TP_On}
    Trigger TP Off and On multi times and stay on TP off state
    UE Tirgger Intra-Freq Inter-GNB HO By Event A3    targetpci=60    wiresharkchecklist=${HO_With_TP_Off}    expect_IntergNBHO=${expect_HOToGNB1}
    ...    fail_regexp=tp-pi2BPSK enabled

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fdd_sansa_cmwv/FS/4cells_gnb1_2F_gnb2_2F    ue_count=2

Modify Cfg
    Update Cfg Param    set_gnb id=2 xn=10.0.1.2
    Update Cfg Param    set_gnb id=3 xn=10.0.1.3
    Update Cfg Param    amf_param id=1 ims_voice_3gpp=on
    Update Cfg Param    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_SAG} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1 amf=1 qos_flows=1,2,3 qos_rules=1,2

UE Trigger Normal Call With PDU Default 5QI6
    [Arguments]    ${ue_id}=1
    Disable UE Testmode    ue_id=${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    qosflow_modify qos_flow=1 default=on ue=${ue_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=Setup QosFlow with QFI:1 5QI:6

UE Trigger VoNR Call Successfully
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on ue=${ue_id}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    pass_regexp=Setup QosFlow with QFI:1 5QI:5
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=3 by=amf    pass_regexp=Added QosFlow with QFI:2 5QI:1

UE Send Throuput On 5QI6
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=20 dir=dl
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=UE 1: UDP UL
    sleep    10s    #sleep for stable traffic


UE Trigger Normal Call with Traffic and VONR Call Then Trigger TP On
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    UE Trigger Normal Call with Traffic and VONR Call Then Trigger TP On...    console=${True}
    Start To Capture Wireshark Log    UE${ue_id}TriggerCallAndTPOn
    UE Trigger Normal Call With PDU Default 5QI6    ue_id=${ue_id}
    UE Send Throuput On 5QI6    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}
    UE Trigger VoNR Call Successfully    ue_id=${ue_id}
    UE Moves Towards Cell Edge to trigger TP ON    ue_id=${ue_id}
    Stop Capture Wireshark Log

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=18    ${Tput_ul}=9    ${sleep_time}=15s    ${pdu}=1
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=1    direction=ul    rate_type=ave
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

Disable UE Testmode
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=30
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=1 action=deactivate
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 delete=1

UE Moves Towards Cell Edge to trigger TP ON
    [Arguments]    ${ue_id}=1    ${expect_CellEdge}=${TP_activate_check}
    ${ret1}=    Run Keyword And Ignore Error    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=120
    ...    pass_regexp=${expect_CellEdge}
    ${ret2}=    Run Keyword And Ignore Error    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=1 action=activate
    ...    pass_regexp=${expect_CellEdge}
    Evaluate    '${ret1[0]} == "PASS" or ${ret2[0]} == "PASS"'
    Verify Throughput    ue_id=${ue_id}    Tput_ul=5

UE Moves Towards Cell Center to trigger TP OFF
    [Arguments]    ${ue_id}=1    ${expect_CellCenter}=${TP_disable}
    ${ret1}=    Run Keyword And Ignore Error    Execute Egate Command     ul_sinr_testmode_nr profile_id=1 pathloss=30
    ...    pass_regexp=@{expect_CellCenter}
    ${ret2}=    Run Keyword And Ignore Error    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=1 action=activate
    ...    pass_regexp=@{expect_CellCenter}
    Evaluate    '${ret1[0]} == "PASS" or ${ret2[0]} == "PASS"'
    Verify Throughput    ue_id=${ue_id}    Tput_ul=9

UE Tirgger Intra-Freq Inter-GNB HO By Event A3
    [Arguments]    ${ue_id}=1    ${targetgnbWirsharkdir}=${Empty}    ${targetpci}=62    ${wiresharkchecklist}=${HO_With_TP_On}
    ...    ${expect_IntergNBHO}=${expect_HOToGNB2}    ${fail_regexp}=${None}
    BuiltIn.Log    UE Trigger HO to cell ${targetpci}...    console=${True}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=368430    event_type=A3
    Start To Capture Wireshark Log    UE${ue_id}HOtoCELL${targetpci}
    Start To Capture Wireshark Log Gnb2    UE${ue_id}HOtoCELL${targetpci}
    ${intra_freq_inter_gnb_A3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${targetpci} nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_inter_gnb_A3}    pass_regexp=@{expect_IntergNBHO}    fail_regexp=${fail_regexp}
    sleep    10s    #check HO done,UE is stable
    Stop Capture Wireshark Log
    Stop Capture Wireshark Log Gnb2
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/${targetgnbWirsharkdir}/wireshark_UE${ue_id}HOtoCELL${targetpci}.pcap
    ...    @{wiresharkchecklist}

Trigger TP Off and On multi times and stay on TP off state
    [Arguments]    ${repeattime}=5
    BuiltIn.Log    Trigger TP Off and On multi times...    console=${True}
    FOR    ${item}    IN RANGE    0    ${repeattime}
        UE Moves Towards Cell Center to trigger TP OFF
        UE Moves Towards Cell Edge to trigger TP ON
    END
    UE Moves Towards Cell Center to trigger TP OFF

