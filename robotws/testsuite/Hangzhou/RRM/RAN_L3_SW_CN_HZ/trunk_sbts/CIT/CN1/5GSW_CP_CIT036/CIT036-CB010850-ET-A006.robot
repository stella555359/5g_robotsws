*** Settings ***
Documentation
...    author: Chen Dandan
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_FDD    SBTS00    CIT
...            CLOUD_5G_I_BOO_AP_LOO    team-CN1ET    owner-Sherry.zhang    release-SBTS24R1
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}
...    4681
@{PARAMS_IN_SWCONFIG}
...    0x890073=3

@{PARAMS_IN_SCF}
...    @{NRREL}
...    @{UL_CA_enable}
...    @{Multiple_dedicated_BWPs}
...    @{TDD_cell_BWPs}
...    @{cell3 overlapping}
...    NRCELL-1:fPdcchMonOccsnPo=2
...    NRCELL-2:fPdcchMonOccsnPo=2
...    NRCELL-3:fPdcchMonOccsnPo=2
...    NRCELL-4:fPdcchMonOccsnPo=2
...    NRCELL-3:msg1FrequencyStart=0
...    NRCELL-4:msg1FrequencyStart=11
...    NRBTS:actBcsCheck=disabled

@{cell3 overlapping}
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw = 20MHz
...    MRBTS-1/NRBTS-1/NRCELL-3:chBw = 20MHz
...    MRBTS-1/NRBTS-1/NRCELL-3:nrarfcn=646954
...    MRBTS-1/NRBTS-1/NRCELL-3:gscnOrSsPbchArfcn=7988
...    NRCELL-3:type0SearchSpaceConfigurationIndex = 4
...    NRCELL-3:type0CoresetConfigurationIndex = 2
...    NRCELL-3:msg1FrequencyStart = 5

@{TDD_cell_BWPs}
...    MRBTS-1/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=5min
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    BWP_PROFILE-13:bwpProfileId=13
...    BWP_PROFILE-13:bwpType=initial
...    BWP_PROFILE-13:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-13:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-13/PDCCH-1:alSelection=static
...    BWP_PROFILE-13/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-13/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-13/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type2
...    BWP_PROFILE-14:bwpProfileId=14
...    BWP_PROFILE-14:bwpType=dedicated
...    BWP_PROFILE-14:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-14:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-14:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-14:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-14/PDCCH-1:alSelection=static
...    BWP_PROFILE-14/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-14/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-14/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-14/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-14/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-14/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-14/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-14/PDSCH-1:pdschId=1
...    BWP_PROFILE-14/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-3:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-13|cellBwpId=0
...    NRCELL-3:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-14|cellBwpId=1

@{Multiple_dedicated_BWPs}
...    NRCELL:actFlexGapOffset=SR_and_DRX_and_CSIRS
...    NRCELL:reqMinNumPuschPrb=19
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL-14:actEnhMultipleDedicatedBWPs=false
...    NRCELL-14:msg1FrequencyStart=12
...    BWP_PROFILE-11:bwpProfileId=11
...    BWP_PROFILE-11:bwpType=initial
...    BWP_PROFILE-11:locationAndBandwidthDl:cRbSizeDl=n133
...    BWP_PROFILE-11:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-11:locationAndBandwidthUl:cRbSizeUl=n133
...    BWP_PROFILE-11:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-12:bwpProfileId=12
...    BWP_PROFILE-12:bwpType=dedicated
...    BWP_PROFILE-12:locationAndBandwidthDl:cRbSizeDl=n216
...    BWP_PROFILE-12:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=n216
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-15:bwpProfileId=15
...    BWP_PROFILE-15:bwpType=dedicated
...    BWP_PROFILE-15:locationAndBandwidthDl:cRbSizeDl=n133
...    BWP_PROFILE-15:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-15:locationAndBandwidthUl:cRbSizeUl=n133
...    BWP_PROFILE-15:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-15/PDCCH-1:alSelection=static
...    BWP_PROFILE-15/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-15/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDSCH-1:pdschId=1
...    BWP_PROFILE-15/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-14:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-11
...    NRCELL-14:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-12
...    NRCELL-14:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-15

@{NRREL}
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:lcrId=4
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-12/NRREL-1:isRplCellForPSCell=true
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-13/NRREL-1:isRplCellForPSCell=true
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlAndUl

@{UL_CA_enable}
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-4:increasePUSCHPrepTimeULCA=true
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS-1/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS-1/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

@{actPRBBlanking_cell4}
...    NRCELL-4:actPRBBlanking=true
...    NRCELL-4:nbrOfBlankedPRBsHighEdgeDL = 10
...    NRCELL-4:nbrOfBlankedPRBsHighEdgeUL = 10
...    NRCELL-4:nbrOfBlankedPRBsLowEdgeDL = 2
...    NRCELL-4:nbrOfBlankedPRBsLowEdgeUL = 2
...    NRCELL-4:type0SearchSpaceConfigurationIndex = 4

@{actPRBBlanking_cell12}
...    NRCELL-12:actPRBBlanking=true
...    NRCELL-12:nbrOfBlankedPRBsHighEdgeDL = 0
...    NRCELL-12:nbrOfBlankedPRBsHighEdgeUL = 0
...    NRCELL-12:nbrOfBlankedPRBsLowEdgeDL = 0
...    NRCELL-12:nbrOfBlankedPRBsLowEdgeUL = 26
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=n134
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb26

@{actPRBBlanking_cell13}
...    NRCELL-13:actPRBBlanking=true
...    NRCELL-13:nbrOfBlankedPRBsHighEdgeDL = 0
...    NRCELL-13:nbrOfBlankedPRBsHighEdgeUL = 26
...    NRCELL-13:nbrOfBlankedPRBsLowEdgeDL = 0
...    NRCELL-13:nbrOfBlankedPRBsLowEdgeUL = 0
...    BWP_PROFILE-9:locationAndBandwidthUl:cRbSizeUl=n107
...    BWP_PROFILE-9:locationAndBandwidthUl:cRbStartUl=crb0

@{SA_FT scell4 addition}
...    pcid:53, scellIdx:1] configure_1_1
...    pcid:53, scellIdx:1] configure_0_1
...    pcid:61, scellIdx:0] configure_1_1
...    pcid:61, scellIdx:0] configure_0_1

@{SA_FT scell1 addition}
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:50, scellIdx:1] configure_0_1
...    pcid:62, scellIdx:0] configure_1_1
...    pcid:62, scellIdx:0] configure_0_1

@{NSA_FT scell4 addition}
...    sCellToAddModList
...    sCellIndex 9
...    physCellId 53
...    reported successful RA
...    SNStatusTransfer

@{NSA_FT scell1 addition}
...    sCellToAddModList
...    sCellIndex 9
...    physCellId 50
...    reported successful RA
...    SNStatusTransfer

@{PM_Counters_A006}
...    last NRCELL-12:NCELA:${UL_PRB_UTIL_SLOT_MAX}=100
...    last NRCELL-12:NCELA:${MAX_SCHED_UE_PUSCH}=2
...    last NRCELL-13:NCELA:${UL_PRB_UTIL_SLOT_MAX}=100
...    last NRCELL-13:NCELA:${MAX_SCHED_UE_PUSCH}=2

${UL_PRB_UTIL_SLOT_MAX}    M55308C36002     #Maximum UL PRB Utilization per slot
${MAX_SCHED_UE_PUSCH}    M55308C18002     #Maximum number of scheduled (FDM and MU-MIMO) UEs on PUSCH per slot

${pdu_id}    1
${gw_id}    1
${nwslice}    1


*** Test Cases ***
CB010850-ET-A006_Verify_Feature_interaction_with_UL_CA_FT_2CC_in_25MHz_30MHz
    [Documentation]
    ...    New parameter for 10850 :
    ...    actPRBBlanking: activates/deactivates 10850 or 9915
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeUL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeUL
    ...    1. This user scenario describes FDD Cell UL PRB blanking activation successfully and interworking with NSA DL CA and SA UL CA.
    ...       This user scenario also cover interworking with TDD Cell UL and DL PRB blanking activation successfully.
    ...    2. Configuration:
    ...           cell id=4 band=n38 chbw=20MHz nbrOfBlankedPRBsHighEdgeUL=10 nbrOfBlankedPRBsHighEdgeDL=10
    ...                                         nbrOfBlankedPRBsLowEdgeUL= 2 nbrOfBlankedPRBsLowEdgeDL =2 BWP_PROFILE-5 BWP_PROFILE-6
    ...           cell id=12 band=n66 chbw=30MHz nbrOfBlankedPRBsHighEdgeUL=0 nbrOfBlankedPRBsLowEdgeUL=26 BWP_PROFILE-7 BWP_PROFILE-8
    ...           cell id=13 band=n25 chbw=25MHz nbrOfBlankedPRBsHighEdgeUL=26 nbrOfBlankedPRBsLowEdgeUL=0 BWP_PROFILE-9 BWP_PROFILE-10
    ...        Configure nrrel Relations:
    ...           cell12-cell4, cell13-cell1
    ...        UE Capability: should support UL CA
    ...    3. Test Case Steps:
    ...       1). Trigger UL prb blanking online activation on FDD cell12 and FDD cell13, and DL UL prb blanking online activation on TDD cell4.
    ...           cell4 on air and longPucchStartPuschPrb and longPucchNumPuschPrb of Dedicated BWP;
    ...           longPucchStartPuschPrb and longPucchNumPuschPrb of Initial BWP in cell4 tf_l2_ps_cell_cellsetupreq is match with NIDD
    ...           cell12 and cell13 on air and initialUplinkBWP configuration in cell12 and cell13 tf_l2_ps_cell_cellsetupreq are match with NIDD
    ...       2). SA UE81 attaches to FDD cell12 and trigger blind SCell Addition to make FT 2CC UL CA.
    ...           SA UE82 attaches to FDD cell13 and trigger blind SCell Addition to make FT 2CC UL CA.
    ...           cell12 add cell4 as scell to make FT 2CC SA UL CA successfully.
    ...           cell13 add cell1 as scell to make FT 2CC SA UL CA successfully.
    ...       3). NSA UE91 attaches to FDD cell12 for blind SCell Addition to make FT 2CC DL CA.
    ...           NSA UE92 attaches to FDD cell13 for blind SCell Addition to make FT 2CC DL CA.
    ...           cell12 add cell4 as scell to make FT 2CC NSA DL CA successfully.
    ...           cell13 add cell1 as scell to make FT 2CC NSA DL CA successfully.
    [Tags]    QC_47235    owner-Sherry.zhang    A006
    ...    CA_LABEL-FT(30MHz_FDD_n66+20MHz_TDD_n38)    CA_LABEL-FT(25MHz_FDD_n25+100MHz_TDD_n78)
    Clear Counter Files
    Step1 online enable PRBBlanking
    Step2 SA UE attach to cell in FT UL CA
    Step3 NSA UE attach to cell in FT DL CA
#    Check Wireshark Log    ${CURDIR}${/}a2a_A006${/}a2a.ini    wait_string=SNStatusTransfer::4
    Check Counters    ${PM_Counters_A006}


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N25_2N66_3N78_N38

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=84
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Step1 online enable PRBBlanking
    OnlineParamChange    ${actPRBBlanking_cell4}
    OnlineParamChange    ${actPRBBlanking_cell12}
    OnlineParamChange    ${actPRBBlanking_cell13}

Step2 SA UE attach to cell in FT UL CA
    UE Attach To Target Cell    cell_id=12    ue_id=81    pass_regexp=${SA_FT scell4 addition}
    Send Throuput For SA    ue_id=81
    UE Attach To Target Cell    cell_id=13    ue_id=82    pass_regexp=${SA_FT scell1 addition}
    Send Throuput For SA    ue_id=82
    Wait Until Keyword Succeeds    30s    10s    Verify SA dl Throuput For UL FT    ue_id=81
    Wait Until Keyword Succeeds    30s    10s    Verify SA ul Throuput For UL FT    ue_id=81
    Wait Until Keyword Succeeds    30s    10s    Verify SA dl Throuput For UL FT    ue_id=82
    Wait Until Keyword Succeeds    30s    10s    Verify SA ul Throuput For UL FT    ue_id=82

Step3 NSA UE attach to cell in FT DL CA
    NSA UE Attach To Target Cell    cell_id=12    ue_id=91    pass_regexp=${NSA_FT scell4 addition}
    Send Throuput For NSA    ue_id=91
    NSA UE Attach To Target Cell    cell_id=13    ue_id=92    pass_regexp=${NSA_FT scell1 addition}
    Send Throuput For NSA    ue_id=92
    Wait Until Keyword Succeeds    30s    10s    Verify NSA dl Throuput For DL FT    ue_id=91
    Wait Until Keyword Succeeds    30s    10s    Verify NSA ul Throuput For DL FT    ue_id=91
    Wait Until Keyword Succeeds    30s    10s    Verify NSA dl Throuput For DL FT    ue_id=92
    Wait Until Keyword Succeeds    30s    10s    Verify NSA ul Throuput For DL FT    ue_id=92
    sleep    5s

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=81    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    pass_regexp=${pass_regexp}

Send Throuput For SA
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=3    UE ${ue_id}: UDP UL

Verify SA dl Throuput For UL FT
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=250
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tputdl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tputdl}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tputdl}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}

Verify SA ul Throuput For UL FT
    [Arguments]    ${ue_id}=81    ${total_ul_tput}=90
    ${pcell_ul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${pcell_ul}/1000 > 0
    ${total_ul}    Set Variable    ${pcell_ul}
    ${scell1_tputul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${scell1_tputul}/1000 > 0
    ${total_ul}    Evaluate    ${scell1_tputul}+${total_ul}
    Should Be True    ${total_ul}/1000>${total_ul_tput}

NSA UE Attach To Target Cell
    [Arguments]    ${cell_id}=12    ${ue_id}=91    ${pass_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=${pass_regexp}

Send Throuput For NSA
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=100 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=100 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=50 trf_id=3    UE ${ue_id}: UDP UL

Verify NSA dl Throuput For DL FT
    [Arguments]    ${ue_id}=91    ${total_dl_tput}=150
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tputdl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tputdl}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tputdl}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}

Verify NSA ul Throuput For DL FT
    [Arguments]    ${ue_id}=91    ${total_ul_tput}=34
    ${pcell_ul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${pcell_ul}/1000 > 0
    ${total_ul}    Set Variable    ${pcell_ul}
    Should Be True    ${total_ul}/1000>${total_ul_tput}
