*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-tao.2.cui
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${TTITRACE_FLAG}    ${True}
${GNB_BIP_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:False,fail:True

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{cell2_parameter}
...    @{8124_related_modification}
...    @{5qi80_related_modification}
...    @{Enable_CB007552}
...    @{Enable_Cell1_CB008541_5GC000937}

@{Enable_Cell1_CB008541_5GC000937}
...    NRCELL-1:actEnhMultipleDedicatedBWPs=true
...    NRCELL-1:actPowerSavingBWP=true
...    NRCELL-1:chBw=80MHz
...    NRCELL-1:msg1FrequencyStart=28
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-6
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-55
...    NRCELL-1:cellBwpList:cellBwpId=3|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-56

@{Enable_CB007552}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-55:bwpType=dedicated
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-55/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n4|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=15|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=16|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-56:bwpType=powerSaving
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-56/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n4|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=20|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=21|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-6:bwpType=initial
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-6/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n4|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actUlCgType2=true
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=12
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=32
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=20
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumUeUl=1

@{cell2_parameter}
...    NRCELL-2:cellDepType=SA
...    NRCELL-2:configuredEpsTac=${EMPTY}
...    NRCELL-2:chBw=60MHz

@{5qi80_related_modification}
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:discardTimer=infinity
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:endMarkerTimer=2000
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=nonGBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-15:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-15:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{OnlineParam_C28}
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=12
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=1000

${UE_Capa_Support_CG2_mac_phy}    SEPARATOR=
...    E1A03000076E0140502D018F0041C19000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261201EB608080838778E
...    1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A
...    8D89BAC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261201EB60808083
...    8778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000000000
...    0072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

${ue_capa_Support_CG2_mac_phy_937}    SEPARATOR=
...    E9A03000076E0140502D018F0041C210003C1260C800087848018906804C060180E01951B0A3582028680965944C3400F5B0404041C3BC
...    70E418700040C9E3EAE0009E00380027800546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB80027800E0009E00
...    151B137582028680965944C3400F5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130D003D6C1010
...    1070EF1C39061C00103278FAA8000028000000841C4D0000000020268B80003804044F617001800140E0A00E0601300380034120020301
...    F000000000000072A68000800004B2CA801A55542C007000B00000004008011AB130001020304050607080B101112131921252627284A228

*** Test Cases ***
CB008124_G01_CG_Type2_Success_Setup_UE_Support_Large_BWP_7552_Enable
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Configured UL Grant Type 2
    ...    configuration for the bearer associated with Configured UL Grants Type 2 profile with CB007552 enabled.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU and then setup PDU session.5QI_80 is setup with CG2.
    ...    b.UE detach.
    [Tags]    QC_277337    owner-tao.2.cui
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${ue_Capa_Support_CG2_mac_phy}
    ICS Without PDU    ue_id=1    cell_id=1    qfi=9    regexp=configuredGrantConfig setup
    Send And Verify Throuput    ue_id=1    qfi=1    send_dl=1    send_ul=1    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=1

CB008124_G03_CG_Type2_Success_Setup_UE_At_Large_BWP_937_Enable
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Configured UL Grant Type 2
    ...    configuration for the bearer associated with Configured UL Grants Type 2 profile that is received as part of
    ...    Initial Context Setup Request procedure with 5GC000937 enabled.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU and then setup PDU session.5QI_80 is setup with CG2.
    ...    b.UE detach.
    [Tags]    QC_277338    owner-tao.2.cui
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${ue_capa_Support_CG2_mac_phy_937}
    ICS Without PDU    ue_id=1    cell_id=1    qfi=9    regexp=configuredGrantConfig setup
    Send And Verify Throuput    ue_id=1    qfi=1    send_dl=1    send_ul=1    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=1

CB008124_C28_Success_CG_Type2_Profile_Parameter_Online_Modification
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Configured UL Grant Type 2
    ...    configuration for the bearer associated with Configured UL Grants Type 2 profile after CG Profile
    ...    on line modification
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU and then setup PDU session.5QI_80 is setup with CG2.
    ...    b.UE detach.
    [Tags]    QC_256231    owner-tao.2.cui
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${ue_Capa_Support_CG2_mac_phy}
    ICS Without PDU    ue_id=1    cell_id=1    qfi=9    regexp=configuredGrantConfig setup
    Send And Verify Throuput    ue_id=1    qfi=1    send_dl=1    send_ul=1    sleep_time=10s    pdu=1
    OnlineParamChange    ${OnlineParam_C28}
    Send And Verify Throuput    ue_id=1    qfi=1    send_dl=1    send_ul=1    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=1
    ICS Without PDU    ue_id=1    cell_id=1    qfi=9    regexp=configuredGrantConfig setup
    Send And Verify Throuput    ue_id=1    qfi=1    send_dl=1    send_ul=1    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=1

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 default=on
    Update Cfg    set_qosflow id=9 5qi=80

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

ICS Without PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}    ${qfi}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qfi} priority=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${retvalue}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Should Contain    ${retvalue}    ${regexp}
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${send_ul}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl} size=100
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul} size=100
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.1    ${send_ul}*0.1    ${sleep_time}    ${pdu}
