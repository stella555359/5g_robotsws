*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO
...               team-CN1ET    owner-ruifang.zhu    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/2cells_1T1F
${AIRPHONE_NAME}    IPHY_AEQE.xml

@{PARAMS_IN_SCF}    @{TDD_cell_info}    @{CA}
...    @{PARAMS_FOR_9059}
...    @{TDD_cell_BWPs}
...    @{actPRBBlanking_cell2}
...    @{enableBeamforming_srs}

@{TDD_cell_info}
...    NRCELL-2:chBw = 80MHz
...    NRCELL-1:type0CoresetConfigurationIndex = 7
...    NRCELL-2:type0CoresetConfigurationIndex = 12
...    NRCELL-2:type0SearchSpaceConfigurationIndex = 5
...    NRCELL-2:msg1FrequencyStart = 36
#1116 Frame Structure
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:prachConfigurationIndex=96
...    NRCELL-2:actCsirsMultiplexing=true
...    NRCELL:actGbrRacTdEnhResourcePriority=true
...    NRCELL:actGBRAdmissionControl=off
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRCELL-1:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRBTS:actTddCsiRsOpt=false

@{PARAMS_FOR_9059}
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA
...    NRBTS/NRDRB-10:cellAggrLevel=Not FR1 CA eligible    #5QI-5
...    NRBTS/NRDRB-11:cellAggrLevel=FR1 CA eligible    #5QI-6
...    NRBTS/NRDRB-12:cellAggrLevel=FR1 CA incompatible    #5QI-7
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA incompatible    #5QI-8
...    NRBTS/NRDRB-14:cellAggrLevel=FR1 CA eligible    #5QI-9

@{PARAMS_FOR_beams}
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRCELL-2:periodicCsiAcquisition:csirsPower=-4
...    NRCELL-2:actCellCsirsTddOnSsbBf=false
...    NRCELL-2:actCellCsiRsImTddNonBf=false
...    NRCELL-2:actCsirsMultiplexing=true
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-2:actAperCsi=true
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_5_1
...    NRCELL-2:beamSet:beamsMuted=0
...    NRCELL-2:beamSet:tiltOffset=0
...    NRCELL-2:beamSet:leftEdgeAngle=60
...    NRCELL-2:beamSet:rightEdgeAngle=60

@{CA}
...    @{NRREL}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{NRREL}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=2
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly

@{TDD_cell_BWPs}
...    BWP_PROFILE-5:bwpProfileId=2
...    BWP_PROFILE-5:bwpType=initial
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n133
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb44
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-5/PDCCH-1:alSelection=static
...    BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-5/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type2
...    BWP_PROFILE-54:bwpProfileId=54
...    BWP_PROFILE-54:bwpType=dedicated
...    BWP_PROFILE-54:locationAndBandwidthDl:cRbSizeDl=n217
...    BWP_PROFILE-54:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-54:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-54:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-54/PDCCH-1:alSelection=static
...    BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-54/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDSCH-1:pdschId=1
...    BWP_PROFILE-54/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-5|cellBwpId=0
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-54|cellBwpId=1

@{actPRBBlanking_cell2}
...    NRCELL-2:actPRBBlanking=true
...    NRCELL-2:nbrOfBlankedPRBsHighEdgeDL = 10
...    NRCELL-2:nbrOfBlankedPRBsHighEdgeUL = 10
...    NRCELL-2:nbrOfBlankedPRBsLowEdgeDL = 44
...    NRCELL-2:nbrOfBlankedPRBsLowEdgeUL = 44
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n133
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb44
...    BWP_PROFILE-54:locationAndBandwidthDl:cRbSizeDl=n217
...    BWP_PROFILE-54:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=48
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    BWP_PROFILE-62:bwpProfileId=62
...    NRBTS/BWP_PROFILE-62:bwpType=dedicated
...    NRBTS/BWP_PROFILE-62:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-62:locationAndBandwidthDl:cRbStartDl=crb44
...    NRBTS/BWP_PROFILE-62:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-62:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-62/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=48
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=72
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-5|cellBwpId=0
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-54|cellBwpId=1
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-62|cellBwpId=2

@{enableBeamforming_srs}
...    NRBTS-2/NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...    NRBTS-2:actFdmEnhancedScheduling =true
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-2:beamSet:basicBeamSet=beamSet_5_1
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-2:beamSet:lowerEdgeAngle=135
...    NRCELL-2:beamSet:upperEdgeAngle=80
...    NRCELL-2:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRCELL-2:periodicCsiAcquisition:csirsPower=-4
...    NRCELL-2:actUeCsirsCoexistCellCsirs=false
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1

${UE_small_bwp_50M_CSI4}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C001F00070007C0005C0000E0741B13703582308682041D20D00656C98AB121CF
...    B027C471E31238F21CFA8E7CC31E50B0381C3C27F605F001FD817C00170000381506C46D608C21A0810788340195B262AC4873EC09F11C78
...    C48E3C873EA39F30C7942C0E070F09FC0000007F00000005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F21CF
...    A8E7CC31E50B0381C3C27F02AAAA9FC0AAAAA1700003800CA07118100000581507050071180000085815878500018460001058158389A100
...    00C041D61E2680061340008020EA17104003882001C4600000A120E00E0234028800101045D0010C0D0276C73E1C29D3B639F0E1449DB0C8
...    870226C73E1C2893B639F0E2400D8E7C302C186318C637A0B800F000A070500703009001C090010180F82400800000004000008020000000
...    100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200100C030040000
...    500200002C01000812048020000300C64ED652D60A5606560CD60AD652D64CD602D606D6025604560ED03410000096525040000659494100
...    00296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E59494
...    10000C96524040000C594900C52AABA55554AA2E95455058AA071541A2A94C55268AA031540A2A93555078A160178095028140A05028140A
...    05028140A05028140A0502814001400203C030404008000100C0182020040100806000001018008202004010080100020100C01804030060
...    100C0186A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05041A80

@{TF_CA_add}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:0
...    pcid:60, scellIdx:1
...    eventA2
...    t-Reassembly ms30
...    sCellToAddModList
...    locationAndBandwidth 12925
...    locationAndBandwidth 14025
...    nrofPorts p8
...    nzp-CSI-RS-ResourceToReleaseList.*\{.*182,.*183.*\}\.

@{qos_add}
...    sCellToReleaseList
...    reportConfigToRemoveList
...    measIdToRemoveList
...    nzp-CSI-RS-ResourceId 182
...    nrofPorts p8
...    nzp-CSI-RS-ResourceId 183
...    t-Reassembly ms15
...    offsetToCarrier 44
...    subcarrierSpacing kHz30
...    carrierBandwidth 133
...    sCellToReleaseList

@{A2_release}
...    eventId eventA1
...    measIdToRemoveList
...    measIdToAddModList
...    nzp-CSI-RS-ResourceId 182
...    nrofPorts p8
...    nzp-CSI-RS-ResourceId 183
...    t-Reassembly ms15
...    offsetToCarrier 44
...    subcarrierSpacing kHz30
...    carrierBandwidth 133
...    sCellToReleaseList

@{SMALL_BWP_CHECK}
...    QoS Routing Table
...    Initial Context Setup Successful
...    locationAndBandwidth 36344


*** Test Cases ***

CB009059-ET-BG05_Interaction_with_small_bandwidth_parts_cRBStartUl_and_cRBStartDl
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This user scenario validates that UE setup call with small BWP, and add scell with CA eligible DRBs,
    ...    and when setup incompatible DRB, trigger scell release, if an SCell Release triggers (CB002200)CSI-RS reconfiguration,
    ...    the gNB includes the DownlinkChannelBW-PerSCS-List IE with the offsetToCarrier IE.
    ...    2.Test Case Steps:
    ...         Step A. The UE attaches to Cell-1 TDD cell. setup NRDRB-1
    ...         Step B. A1 scell addtion MR send from UE.
    ...         Step C. A2 scell deletion trigger, and then A1 scell addtion trigger
    ...         Step D. add NRDRB-3 incompatible DRB
    ...         Step E. repeat stepA-D
    ...         Step F. UE is released
    ...    3. Expected Results:
    ...         Step A: One FR1 CA eligible DRB establish with small BWP, CSI-RS Resource Set3(4 CSI-RS)configured,
    ...             port8(CB002200) in pcell,A1 scell addition measconfig to UE
    ...         Step B: gNB configures 2CC CA to the UE with Cell-2 FDD as the SCells. 
     ...                2 CSI-RS(PCell From 4 CSI-RS downgrade to 2 CSI-RS) in Pcell and 1 CSI-RS in
    ...               scell, Data transmission for DRB-1 non-GBR DL data is on the PCell and SCells.
    ...         Step C: releases CA and configures CSI reporting, check offsetToCarrier and then scell add successfully
    ...         Step D: incompatible DRB establish, releases CA and Pcell will configures back to 4 CSI-RS reporting,
    ...                 the gNB includes the uplinkChannelBW-PerSCS-List IE with the offsetToCarrier IE = cRbStartUl - 1,
    ...                 the gNB includes the DownlinkChannelBW-PerSCS-List IE with the offsetToCarrier IE = cRbStartDl - 1
    ...         Step E: result same as stepA-D
    ...         Step F: UE is released successful
    [Tags]    QC_46747    CA_LABEL-TF(50M_n41_10M_n71)
    Lock And Unlock cell1 to make sure cell on air
    Ues Attach with Small BWP    cell_id=2    ue_id_start=1    ue_id_end_before=6
    Release Ues    ue_type=all


*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Modify Cfg
    Update Cfg    ue_param id=1-6 ue_nr_capabilities=${UE_small_bwp_50M_CSI4}
    Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=5
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5 qos_rules=1 default=on ue=1-30 amf=1

Lock And Unlock cell1 to make sure cell on air
    Lock Cell2
    Unlock Cell2
    Cells Should Be Onair    2

Register For Normal Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
  Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

UE ICS with Samll BWP
    [Arguments]    ${ue_id}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    pass_regexp=${SMALL_BWP_CHECK}

Ues Attach with Small BWP
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
        UE ICS with Samll BWP    ${ue_id}
        trigger A1 scell addtion    ue_id=${ue_id}    pass_CA=${TF_CA_add}    A2_CA=${A2_release}
        Sent Throughput and Verify Throughput with DRB1    ue_id=${ue_id}
        Drb ADD    ue_id=${ue_id}    qos_add=${qos_add}
    END

trigger A1 scell addtion
    [Arguments]    ${ue_id}=1    ${Pf}=518670    ${Sf}=127210    ${srsrp_nr}=90    ${srsrq_nr}=90    ${pass_CA}=none    ${A2_CA}=none
    ${A1_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Pf}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A1_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...    pass_regexp=${pass_CA}
    ${A2_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Sf}    event_type=A2
    sleep    5s
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2_id} event=A2 scell=1 scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=${A2_CA}
    ${A1_2_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Pf}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A1_2_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...    pass_regexp=${pass_CA}

Drb ADD
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${DRB_add}=2    ${qos_add}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${DRB_add} by=amf
    ...    pass_regexp=${qos_add}

Sent Throughput and Verify Throughput with DRB1
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Sent Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify Throughput pcell and scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    stop Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}

Sent Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink
    sleep    15s    Wait For DL Transmission

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=118    ${Tput_ul}=15    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000> 0
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${ue_index}    Convert To String    ${ue_id}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_index}    scell_id=0    type=pdsch    rate_type=ave
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_index}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > 0
    ${ue_dl_tput}    Evaluate    ${pcell_tput}+${scell1_tput}
    Should Be True    ${ue_dl_tput}/1000 >${Tput_dl}

stop Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=${qfi_id} dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=${qfi_id} dir=ul
