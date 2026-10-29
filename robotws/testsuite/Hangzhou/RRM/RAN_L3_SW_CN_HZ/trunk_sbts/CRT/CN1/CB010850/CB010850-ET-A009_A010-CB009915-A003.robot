*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_FDD    SBTS00    CRT
...            CLOUD_5G_I_BOO_AP_LOO    team-CN1ET    owner-Sherry.zhang    release-SBTS24R1
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}
...    4681

@{PARAMS_IN_SCF}
...    @{NRREL}
...    @{UL_CA_enable}
...    @{Multiple_dedicated_BWPs}
...    @{TDD_cell_BWPs}
...    @{cell3 overlapping}

@{cell3 overlapping}
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw = 20MHz
...    MRBTS-1/NRBTS-1/NRCELL-3:chBw = 20MHz
...    MRBTS-1/NRBTS-1/NRCELL-3:nrarfcn=646954
...    MRBTS-1/NRBTS-1/NRCELL-3:gscnOrSsPbchArfcn=7988
...    NRCELL-3:type0SearchSpaceConfigurationIndex = 4
...    NRCELL-3:type0CoresetConfigurationIndex = 2
...    NRCELL-3:msg1FrequencyStart = 5

@{TDD_cell_BWPs}
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

@{online_PR729004_2}
...    NRCELL-14:ueConnectionEstablishmentMode=useInitialBwp

@{online_PR729004}
...    NRCELL-14:actSmallestRRCSetup=false
...    NRCELL-14:actPRBBlanking=true
...    NRCELL-14:nbrOfBlankedPRBsHighEdgeDL = 0
...    NRCELL-14:nbrOfBlankedPRBsHighEdgeUL = 55
...    NRCELL-14:nbrOfBlankedPRBsLowEdgeDL = 0
...    NRCELL-14:nbrOfBlankedPRBsLowEdgeUL = 0

...    NRCELL-14:ueConnectionEstablishmentMode=useDedicatedBwp
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=9
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=14|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=9|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=15|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-11/PDSCH-1:pdschId=1
...    BWP_PROFILE-11/PDSCH-1:pdschRat0RbgConfig=config1

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

@{actPRBBlanking_cell14}
...    NRCELL-14:actPRBBlanking=true
...    NRCELL-14:nbrOfBlankedPRBsHighEdgeDL = 0
...    NRCELL-14:nbrOfBlankedPRBsHighEdgeUL = 55
...    NRCELL-14:nbrOfBlankedPRBsLowEdgeDL = 0
...    NRCELL-14:nbrOfBlankedPRBsLowEdgeUL = 0

@{actPRBBlanking_cell3}
...    NRCELL-3:actPRBBlanking=true
...    NRCELL-3:nbrOfBlankedPRBsHighEdgeDL = 12
...    NRCELL-3:nbrOfBlankedPRBsHighEdgeUL = 12
...    NRCELL-3:nbrOfBlankedPRBsLowEdgeDL = 0
...    NRCELL-3:nbrOfBlankedPRBsLowEdgeUL = 0

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

@{NSA_FT scell1 addition}
...    sCellToAddModList
...    sCellIndex 9
...    physCellId 50
...    reported successful RA

@{RRE_pass}
...    NR RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecoverSA=4000ms

@{smallest_RRC}
...    NRCELL-14:actSmallestRRCSetup=true

@{recover_PR729004}
...    NRBTS-1:rrcReestabTypeSA=deactivated
...    NRCELL-14:actSmallestRRCSetup=false
...    NRCELL-14:ueConnectionEstablishmentMode=useDedicatedBwp

${PRB_AVAIL_PUSCH}    M55308C10004     #PRBs available for PUSCH
${UL_PRB_UTIL_SLOT_MAX}    M55308C36002     #Maximum UL PRB Utilization per slot
${MAX_SCHED_UE_PUSCH}    M55308C18002     #Maximum number of scheduled (FDM and MU-MIMO) UEs on PUSCH per slot

${pdu_id}    1
${gw_id}    1
${nwslice}    1

${A009_small_BWP}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E09804062380DDC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00089000E00365FFFE5FFFE0541B10758636869315020F2CA4D104
...    80CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FFF800003FFE00000224003800DA55552555501546C4DD608C21A081074
...    8240596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE00088000E0541B063582328682041E5949B28240656C98AB
...    121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000112001C006D2AAA92AAA80AE3612EB04610D04083A412036B64C
...    558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF00044000702A8D899AC1184341020E90480B2D931543439F
...    11C7A067D813E31CF9863CA16070387817003FF001C00FFC00110001C0A836236B04610D04083E50480CAD931562439F11C7B027C62471E43
...    9F51CF9863CA1607038784FFF800003FFE000002200038026F0F10400388C0000002C040BC3C25000E268000010B0102F170A0003882001C4
...    6000004160205E2E0C000710400389A00000C2C040BC3C28000E268000040B0102E0F0A00038820000142C040BC3C41000E230000060B0102
...    F0F10400389A00001C2C040BC5C28000E2080071040000405808178B850001C46000E230000090B0102F17104003882001C46000014160205
...    E2E20800711800388C00002C2C040BC3C46000E2680000C0B0102F1F060003882001C46000E2600000D0B0102F1F104003898001C4C000E26
...    00000E0B0102F1710400389A001C4D00001E160205E3E20800710400389A001C4D00002016020500E14000011003C5C18000E208007094000
...    01858081009011A014404D808301303507784E14489B1CF870A244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C28913639F0E1448
...    9B1CF870A244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C68912244D8E7C38D1224489B1CF8712
...    24489B1CF871A2448913639F0E01B0C3811204081B1CF860D898C6318C6318C6318C6318C63F413003C00281C1401C0C02500700060240040
...    603E040020000000100000200800002004000018020000100100000A008000060040000380200002008E0C5E545E4C5E4CDE0CDE0C5E0CDE5
...    4DE4CD01C1800000180006000040600018000201800060000C060001800040180006000140600018000601800060001C0600007F0682F9541
...    7C9A0BE4705F0482F82417C1A0BE550509004800D02800442020040080801002101008010040100210080200402004008080100220100A014
...    04038070101002020200C01808020041010040080400801080804008020040084040080101004008402008010080100202004008804010020
...    10020040400801100801002020040080801002201002004040080101002004202004008080200430300C01A01402818010030020040C00801
...    801002060200440100218180100300E0040C040028020040600C01C048030300600E024018804038010101200C04048031808070020201C00
...    8080900602024018004010021AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${A003_9915_MIMO_twoLayers}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11
...    C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F1
...    8E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F2858
...    1C0E1E13FFE00000FFF80000088000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0003882
...    0000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B1713
...    400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A00
...    0388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043505D83E14489B1CF870A244D
...    8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7
...    C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C025007000602400
...    40603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C01000800000
...    0200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560E
...    D0341000009652504000065949410000296524040000E594901000049652404000165949410000696524040001E5949010000896524040002
...    65949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B5541A2A94C55268AA031540A2A935550
...    78A1202F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C20100200404030060100C018
...    202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C3034404448
...    4C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
CB010850-ET-A009_A010_Verify_Feature_interworking_with_multiple_dedicated_BWPs_in_40MHz_25MHz
    [Documentation]
    ...    PR729004 EDA CB010850-ET-A010
    ...    New parameter for 10850 :
    ...    actPRBBlanking: activates/deactivates 10850
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeUL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeUL
    ...    1. This user scenario describes FDD Cell UL PRB blanking activation successfully and interworking with multiple dedicated BWPs.
    ...    2. Configuration:
    ...           FDD cell14 support large BWP with bandwidth equal to the cell bandwidth 40MHz and small BWP with bandwidth equal to 25MHz.
    ...           cell id=14 band=n25 chbw=40MHz nbrOfBlankedPRBsHighEdgeUL=55 nbrOfBlankedPRBsLowEdgeUL=0
    ...           BWP_PROFILE-11 BWP_PROFILE-12 BWP_PROFILE-15
    ...        UE83 Capability: should support large BWP for n25
    ...        UE84 Capability: only support small BWP for n25
    ...        NRCELL-14:ueConnectionEstablishmentMode=useDedicatedBwp
    ...    3. Test Case Steps:
    ...       1). Trigger UL prb blanking online activation on FDD cell14.
    ...           Cell14 on air and initialUplinkBWP configuration in cell14 tf_l2_ps_cell_cellsetupreq are match with NIDD
    ...       2). SA UE83 attaches to FDD cell14 and send DL UL traffic.
    ...           UE attach into large BWP successfully.
    ...           SA UE84 attaches to FDD cell14 and send DL UL traffic.
    ...           UE attach into small BWP successfully.
    ...           UE83 and UE84 using small BWP after RRC setup, and UE83 switch to large BWP after RRC reconfiguration
    ...           release both 2 UEs
    ...        3). online change NRCELL-14:ueConnectionEstablishmentMode=useDedicatedBwp to useInitialBwp
    ...           SA UE83 attaches to FDD cell14 and send DL UL traffic.
    ...           UE attach into large BWP successfully.
    ...           SA UE84 attaches to FDD cell14 and send DL UL traffic.
    ...           UE attach into small BWP successfully.
    ...           UE83 and UE84 remains on initial BWP after RRC setup, and UE83 switch to large BWP after RRC reconfiguration
    ...           and UE84 switch to small BWP after RRC reconfiguration
    ...           release both 2 UEs
    ...         4). online open feature 5GC000732 NRBTS-1:rrcReestabTypeSA=sameGNB
    ...           SA UE83 attaches to FDD cell14 and send DL UL traffic.
    ...           UE attach into large BWP successfully.
    ...           UE83 remains on initial BWP after RRC setup, and UE83 switch to large BWP after RRC reconfiguration
    ...         5). trigger UE83 RRC reestablished to NRCELL-14<same cell>
    ...           UE83 remains on initial BWP after RRC Reestablishment, and UE83 switch to large BWP after RRC reconfiguration
    ...         6). online open function smallest RRC NRCELL-14:actSmallestRRCSetup=true
    ...           SA UE83 attaches to FDD cell14 and send DL UL traffic.
    ...           UE attach into large BWP successfully. in RRC setup, there is no any BWP info for UE remains on initial BWP
    ...           UE83 remains on initial BWP after RRC setup, and UE83 switch to large BWP after RRC reconfiguration
    ...         5). trigger UE83 RRC reestablished to NRCELL-14<same cell>
    ...           UE83 remains on initial BWP after RRC Reestablishment, and UE83 switch to large BWP after RRC reconfiguration
    [Tags]    QC_46887    owner-Sherry.zhang    A009    A010    PR729004
    UEs attach To Large and Small BWP    online=${online_PR729004}
    UEs attach To Large and Small BWP    online=${online_PR729004_2}
    UE attach to Large BWP and RRE with Reconfiguration Failure    online=${5GC000732_Base}
    UE attach to Large BWP and RRE with Reconfiguration Failure    online=${smallest_RRC}
    OnlineParamChange    ${recover_PR729004}
    Check Wireshark Log    ${CURDIR}${/}a2a_A009${/}a2a.ini    wait_string=UEContextReleaseComplete::24

CB009915-ET-A003_Verify_TDD_PRB_Blanking_in_overlapping_cells_20MHz
    [Documentation]
    ...    New parameter for 9915 :
    ...    actPRBBlanking: activates/deactivates 9915
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeUL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeUL
    ...    1. This user scenario describes TDD Cell PRB blanking activation successfully in overlapping cells.
    ...    2. Configuration:
    ...           cell2 and cell3 are overlapping 4.31MHz.
    ...           cell2 band=n78 chbw=20MHz nrarfcn=648000 gscn=8000
    ...                     nbrOfBlankedPRBsHighEdgeUL=0 nbrOfBlankedPRBsLowEdgeUL=0 BWP_PROFILE-2 BWP_PROFILE-4
    ...           cell3 band=n78 chbw=20MHz nrarfcn=646954 gscn=7988 BWP_PROFILE-13 BWP_PROFILE-14
    ...                     nbrOfBlankedPRBsHighEdgeUL=12 nbrOfBlankedPRBsLowEdgeUL=0
    ...                     nbrOfBlankedPRBsHighEdgeDL=12 nbrOfBlankedPRBsLowEdgeDL=0
    ...    3. Test Case Steps:
    ...       1). Trigger prb blanking online activation on TDD cell3.
    ...           cell3 on air and initialUplinkBWP configuration in cell3 tf_l2_ps_cell_cellsetupreq is match with NIDD
    ...       2). SA UE85 attaches to TDD cell2 and sends DL and UL traffic.
    ...           UE attach to cell2 successfully.
    ...       4). SA UE86 attaches to TDD cell3 and sends DL and UL traffic.
    ...           UE attach to cell3 successfully.
    [Tags]    QC_324792    owner-Sherry.zhang    A003
    Step1 online enable PRBBlanking on cell3
    Step2 UE attach to cell2
    Step3 UE attach to cell3
    Check Wireshark Log    ${CURDIR}${/}a2a_9915_A003${/}a2a.ini    wait_string=GNBDUConfigurationUpdate::18

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N25_2N66_3N78_N38

UE attach to Large BWP and RRE with Reconfiguration Failure
    [Arguments]    ${online}=none
    OnlineParamChange    ${online}
    Step2 SA UE attach into large BWP
    Trigger RRC Reestablish with cause    reconfigurationFailure
    Send Throuput For SA    ue_id=83
    Wait Until Keyword Succeeds    30s    10s    Verify SA Throuput    ue_id=83    Tput_dl=265    Tput_ul=115
    Release ues     ue_type=all

UEs attach To Large and Small BWP
    [Arguments]    ${online}=none
    OnlineParamChange    ${online}
    Step2 SA UE attach into large BWP
    Step3 SA UE attach into small BWP
    Release ues     ue_type=all

Trigger RRC Reestablish with cause
    [Arguments]    ${cause}
    Execute Egate Command    ue_rrc_reestablish id=83 gnb=2 cell=14 cause=${cause}
    ...    pass_regexp=${RRE_pass}    timeout=20s

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=84
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Step1 online enable PRBBlanking on cell3
    OnlineParamChange    ${actPRBBlanking_cell3}

Step2 UE attach to cell2
    Update UE capa    ${A003_9915_MIMO_twoLayers}    85
    UE Attach To Target Cell    cell_id=2    ue_id=85    pass_regexp=QoS Routing Table
    Send Throuput For SA    ue_id=85
    Wait Until Keyword Succeeds    30s    10s    Verify SA Throuput    ue_id=85    Tput_dl=118    Tput_ul=20

Step3 UE attach to cell3
    Update UE capa    ${A003_9915_MIMO_twoLayers}    86
    UE Attach To Target Cell    cell_id=3    ue_id=86    pass_regexp=QoS Routing Table
    Send Throuput For SA    ue_id=86
    Wait Until Keyword Succeeds    30s    10s    Verify SA Throuput    ue_id=86    Tput_dl=85    Tput_ul=12

Step2 SA UE attach into large BWP
    UE Attach To Target Cell    cell_id=14    ue_id=83    pass_regexp=QoS Routing Table
    Send Throuput For SA    ue_id=83
    Wait Until Keyword Succeeds    30s    10s    Verify SA Throuput    ue_id=83    Tput_dl=265    Tput_ul=115

Step3 SA UE attach into small BWP
    Update UE capa    ${A009_small_BWP}    84
    UE Attach To Target Cell    cell_id=14    ue_id=84    pass_regexp=QoS Routing Table
    Send Throuput For SA    ue_id=84
    Wait Until Keyword Succeeds    30s    10s    Verify SA Throuput    ue_id=84    Tput_dl=180    Tput_ul=58

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

Verify SA Throuput
    [Arguments]    ${ue_id}=83    ${Tput_dl}=100    ${Tput_ul}=58
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > ${Tput_dl}
    ${pcell_ul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${pcell_ul}/1000 > ${Tput_ul}
