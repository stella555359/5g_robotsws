*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_FDD    SBTS00    CRT
...            CLOUD_5G_I_BOO_AP_LOO    owner-Sherry.zhang    team-CN1ET    release-SBTS24R1
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}
...    4681

@{PARAMS_IN_SCF}
...    @{BWP_PROFILE_config}
...    @{actPRBBlanking_cell11}
...    @{actPRBBlanking_cell12}
...    @{actPRBBlanking_cell13}
...    @{NRREL}
...    @{cell14 overlapping}

@{cell14 overlapping}
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=124900
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=134100
...    MRBTS-1/NRBTS-1/NRCELL-14:gscnOrSsPbchArfcn=1559

@{NRREL}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly

@{BWP_PROFILE_config}
...    NRCELL:actFlexGapOffset=SR_and_DRX_and_CSIRS
...    NRCELL:reqMinNumPuschPrb=19
...    BWP_PROFILE-7:bwpProfileId=7
...    BWP_PROFILE-7:bwpType=initial
...    BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=n80
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb26
...    BWP_PROFILE-7/PDCCH-1:alSelection=static
...    BWP_PROFILE-7/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-7/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-7/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type2
...    BWP_PROFILE-8:bwpProfileId=8
...    BWP_PROFILE-8:bwpType=dedicated
...    BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-8/PDCCH-1:alSelection=static
...    BWP_PROFILE-8/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-8/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=102
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDSCH-1:pdschId=1
...    BWP_PROFILE-8/PDSCH-1:pdschRat0RbgConfig=config1
...    BWP_PROFILE-9:bwpProfileId=9
...    BWP_PROFILE-9:bwpType=initial
...    BWP_PROFILE-9:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-9:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-9:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-9:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-9/PDCCH-1:alSelection=static
...    BWP_PROFILE-9/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-9/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-9/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-9/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-9/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-9/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-9/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-9/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type2
...    BWP_PROFILE-10:bwpProfileId=10
...    BWP_PROFILE-10:bwpType=dedicated
...    BWP_PROFILE-10:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-10:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-10:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-10:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-10/PDCCH-1:alSelection=static
...    BWP_PROFILE-10/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-10/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-10/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-10/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-10/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-10/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-10/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-10/PDSCH-1:pdschId=1
...    BWP_PROFILE-10/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-13:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7|cellBwpId=0
...    NRCELL-13:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8|cellBwpId=1
...    NRCELL-14:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-9|cellBwpId=0
...    NRCELL-14:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-10|cellBwpId=1

@{actPRBBlanking_cell11}
...    NRCELL-11:actPRBBlanking=true
...    NRCELL-11:nbrOfBlankedPRBsLowEdgeUL=21
...    BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=n31
...    BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb21

@{actPRBBlanking_cell12}
...    NRCELL-12:actPRBBlanking=true
...    NRCELL-12:nbrOfBlankedPRBsHighEdgeUL=26
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=n53
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=crb0

@{actPRBBlanking_cell13}
...    NRCELL-13:actPRBBlanking=true
...    NRCELL-13:nbrOfBlankedPRBsLowEdgeUL=26
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=n80
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb26

@{actPRBBlanking_cell14}
...    NRCELL-14:actPRBBlanking=true
...    NRCELL-14:nbrOfBlankedPRBsHighEdgeUL=26
...    BWP_PROFILE-9:locationAndBandwidthUl:cRbSizeUl=n53
...    BWP_PROFILE-9:locationAndBandwidthUl:cRbStartUl=crb0

@{disable_PRBBlanking_cell12}
...    NRCELL-12:actPRBBlanking=false
...    NRCELL-12:nbrOfBlankedPRBsHighEdgeUL=0
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=crb0

${pdu_id}    1
${gw_id}    1
${nwslice}    1

@{PM_Counters_A005}
#...    last NRCELL-11:NCELA:${PRB_AVAIL_PUSCH}=6150000    #ps counter
...    last NRCELL-11:NCELA:${UL_PRB_UTIL_SLOT_MAX}=100
...    last NRCELL-11:NCELA:${MAX_SCHED_UE_PUSCH}=1
#...    last NRCELL-12:NCELA:${PRB_AVAIL_PUSCH}=10950000    #ps counter
...    last NRCELL-12:NCELA:${UL_PRB_UTIL_SLOT_MAX}=100
...    last NRCELL-12:NCELA:${MAX_SCHED_UE_PUSCH}=1

${PRB_AVAIL_PUSCH}    M55308C10004     #PRBs available for PUSCH
${UL_PRB_UTIL_SLOT_MAX}    M55308C36002     #Maximum UL PRB Utilization per slot
${MAX_SCHED_UE_PUSCH}    M55308C18002     #Maximum number of scheduled (FDM and MU-MIMO) UEs on PUSCH per slot

@{FFF scell addition}
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully

@{FT scell addition}
...    pcid:50, scellIdx:1
...    rrcReconfigurationComplete

*** Test Cases ***
CB010850-ET-A005_Verify_Feature_interaction_with_Carrier_Aggregation_FDD_low_edge_in_10MHz_15MHz_20MHz
    [Documentation]
    ...    New parameter for 10850 :
    ...    actPRBBlanking: activates/deactivates 10850
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeUL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeUL
    ...    1. This user scenario describes FDD Cell UL PRB blanking activation successfully and interworking with DL CA successfully.
    ...    2. Configuration:
    ...           cell id=11 band=n66 chbw=10MHz nbrOfBlankedPRBsHighEdgeUL=0 nbrOfBlankedPRBsLowEdgeUL=21 BWP_PROFILE-1 BWP_PROFILE-2
    ...           cell id=12 band=n71 chbw=15MHz nbrOfBlankedPRBsHighEdgeUL=26 nbrOfBlankedPRBsLowEdgeUL=0 BWP_PROFILE-5 BWP_PROFILE-6
    ...           cell id=13 band=n66 chbw=20MHz nbrOfBlankedPRBsHighEdgeUL=0 nbrOfBlankedPRBsLowEdgeUL=26 BWP_PROFILE-7 BWP_PROFILE-8
    ...        Configure nrrel Relations:
    ...           cell11-cell12--cell13, cell12-cell1
    ...    3. Test Case Steps:
    ...       1). Trigger cell11 lock and unlock
    ...           cell11 on air and initialUplinkBWP configuration in cell11 tf_l2_ps_cell_cellsetupreq is match with NIDD
    ...       2). Trigger cell12 lock and unlock
    ...           cell12 on air and initialUplinkBWP configuration in cell12 tf_l2_ps_cell_cellsetupreq is match with NIDD
    ...       3). SA UE attaches to FDD cell11 and sends A1 MR for SCell Addition to make FFF 3CC CA.
    ...           cell11 add cell12 and cell13 as scell to make FFF 3CC CA successfully.
    ...       4). SA UE attaches to FDD cell12 for blind SCell Addition to make FT 2CC CA.
    ...           cell12 add cell1 as scell to make FT 2CC CA successfully.
    [Tags]    owner-Sherry.zhang    QC_46889    CA_LABEL-FFF(10MHz_FDD_n66+15MHz_FDD_n71+20MHz_FDD_n66)    CA_LABEL-FT(15MHz_FDD_n71+60MHz_TDD_n41)
    Clear Counter Files
    Step1 trigger cell11 lock and unlock
    Step2 trigger cell12 lock and unlock
    Step3 UE attach to cell11 in FFF CA
    Step4 UE attach to cell12 in FT CA
    Check Wireshark Log    ${CURDIR}${/}a2a_A005${/}a2a.ini    wait_string=GNBDUConfigurationUpdate::36
    Check Counters    ${PM_Counters_A005}

CB010850-ET-A003_Verify_PRB_Blanking_in_overlapping_cells_15MHz_high_edge_blanking
    [Documentation]
    ...    New parameter for 10850 :
    ...    actPRBBlanking: activates/deactivates 10850
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeUL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeUL
    ...    1. This user scenario describes FDD Cell UL PRB blanking activation successfully and interworking with DL CA successfully.
    ...    2. Configuration:
    ...           cell12 and cell14 are UL overlapping 5MHz.
    ...           cell id=12 band=n71 chbw=15MHz nbrOfBlankedPRBsHighEdgeUL=0 nbrOfBlankedPRBsLowEdgeUL=0 BWP_PROFILE-5 BWP_PROFILE-6
    ...           cell id=14 band=n71 chbw=15MHz nbrOfBlankedPRBsHighEdgeUL=26 nbrOfBlankedPRBsLowEdgeUL=0 BWP_PROFILE-9 BWP_PROFILE-10
    ...        Configure nrrel Relations:
    ...           cell12-cell1
    ...    3. Test Case Steps:
    ...       1). Trigger UL prb blanking online activation on FDD cell14.
    ...           cell14 on air and initialUplinkBWP configuration in cell14 tf_l2_ps_cell_cellsetupreq is match with NIDD
    ...       2). Trigger UL prb blanking online deactivation on FDD cell12.
    ...           cell12 online deactivation prb blanking successfully and cell12 on air.
    ...       3). SA UE attaches to FDD cell14 and sends DL and UL traffic.
    ...           UE attach to cell14 successfully.
    ...       4). SA UE attaches to FDD cell12 for blind SCell Addition to make FT 2CC CA.
    ...           cell12 add cell1 as scell to make FT 2CC CA successfully.
    [Tags]    QC_46888    owner-Sherry.zhang    A003    CA_LABEL-FT(15MHz_FDD_n71+60MHz_TDD_n41)
    Step1 online enable PRBBlanking on cell14
    Step2 online disable PRBBlanking on cell12
    Step3 UE attach to cell14
    Step4 UE attach to cell12 in FT CA
    Check Wireshark Log    ${CURDIR}${/}a2a_A003${/}a2a.ini    wait_string=GNBDUConfigurationUpdate::36

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Step1 online enable PRBBlanking on cell14
    OnlineParamChange    ${actPRBBlanking_cell14}

Step2 online disable PRBBlanking on cell12
    OnlineParamChange    ${disable_PRBBlanking_cell12}

Step3 UE attach to cell14
    UE Attach To Target Cell    cell_id=14    ue_id=84        pass_regexp=QoS Routing Table
    Send Throuput    ue_id=84
    Wait Until Keyword Succeeds    30s    10s    Verify Throuput on Pcell    ue_id=84


Step1 trigger cell11 lock and unlock
    Lock Cell11
    Unlock Cell11

Step2 trigger cell12 lock and unlock
    Lock Cell12
    Unlock Cell12

Step3 UE attach to cell11 in FFF CA
    UE Attach To Target Cell    cell_id=11    ue_id=81    pass_regexp=QoS Routing Table
    Send Throuput
    Wait Until Keyword Succeeds    30s    10s    Verify Throuput on Pcell    ue_id=81
    Trigger ScellAdd
    Wait Until Keyword Succeeds    30s    10s    Verify dl Throuput For FFF    ue_id=81
    Wait Until Keyword Succeeds    30s    10s    Verify ul Throuput    ue_id=81

Step4 UE attach to cell12 in FT CA
    UE Attach To Target Cell    cell_id=12    ue_id=83    pass_regexp=${FT scell addition}
    Send Throuput    ue_id=83
    Wait Until Keyword Succeeds    30s    10s    Verify dl Throuput For FT    ue_id=83
    Wait Until Keyword Succeeds    30s    10s    Verify ul Throuput    ue_id=83

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=81    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    pass_regexp=${pass_regexp}

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    sleep    15s    #sleep for stable traffic

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=75    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${FFF scell addition}

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=65    ${total_ul_tput}=15
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > ${total_dl_tput}
    ${pcell_ul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${pcell_ul}/1000 > ${total_ul_tput}

Verify dl Throuput For FFF
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=295
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${scell2_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}

Verify ul Throuput
    [Arguments]    ${ue_id}=81    ${total_ul_tput}=15
    ${pcell_ul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${pcell_ul}/1000 > ${total_ul_tput}

Verify dl Throuput For FT
    [Arguments]    ${ue_id}=83    ${total_dl_tput}=295
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}
