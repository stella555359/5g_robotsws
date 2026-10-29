*** Settings ***
Documentation
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-jun.15.zhang    release-5G24R2     CB008322
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}
...    @{1070_40M_bwp}
...    @{FDD_20M_bwp}
...    @{PARAMS_FOR_VoNR}
...    @{PARAMS_FOR_CA}

@{enableBeamforming}
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELL-1:beamSet:lowerEdgeAngle=120
...    NRCELL-1:beamSet:upperEdgeAngle=60
...    NRCELL-1:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-0:ssBurstSetPeriod=20
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_6
...    NRCELL-2:beamSet:lowerEdgeAngle=120
...    NRCELL-2:beamSet:upperEdgeAngle=60
...    NRCELL-2:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-1:ssBurstSetPeriod=20

@{srsConfig}
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled

...    NRCELL-1:physCellId=52
...    NRCELL-1:chBw=40MHz
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-1:actDlSrsSubbandBm=true
...    NRCELL-1:nrCellType=8DL4UL
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-1:actUeCsirsCoexistCellCsirs=true
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-1:srsForBeamMgmt:comb=comb4
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-1:srsForBeamMgmt:cSRS=24
...    NRCELL-1:srsForBeamMgmt:bSRS=2
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
...    NRCELL-1:wbSbSrsSwitch:channelStabilityHysteresis=100
...    NRCELL-1:wbSbSrsSwitch:channelStabilityThreshold=30
...    NRCELL-1:wbSbSrsSwitch:enableSbSrsVolatilityCheck=false
...    NRCELL-1:wbSbSrsSwitch:maxWbSbSwitch=10
...    NRCELL-1:wbSbSrsSwitch:numWbSrsConfigSample=10
...    NRCELL-1:wbSbSrsSwitch:numWbSrsReleaseSample=10
...    NRCELL-1:wbSbSrsSwitch:prbRatioHysteresis=15
...    NRCELL-1:wbSbSrsSwitch:prbRatioThreshold=1
...    NRCELL-1:wbSbSrsSwitch:prbSampleHighLowPercentage=60
...    NRCELL-1:wbSbSrsSwitch:rankHysteresis=4
...    NRCELL-1:wbSbSrsSwitch:rankThreshold=1
...    NRCELL-1:wbSbSrsSwitch:rlqBadPercentage=50
...    NRCELL-1:wbSbSrsSwitch:rlqGoodPercentage=20
...    NRCELL-1:wbSbSrsSwitch:seHysteresis=100
...    NRCELL-1:wbSbSrsSwitch:seThreshold=1
...    NRCELL-1:wbSbSrsSwitch:sortingMetric=DL Spectral Efficiency
...    NRCELL-1:wbSbSrsSwitch:wbSrsConfigProhibitTimer=100
...    NRCELL-1:wbSbSrsSwitch:wbSrsPowerHysteresis=100
...    NRCELL-1:wbSbSrsSwitch:wbSrsPowerThreshold=-1160
...    NRCELL-1:wbSbSrsSwitch:wbSrsReleaseProhibitTimer=1000
#1070 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-1:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-1:prachConfigurationIndex=98

...    NRCELL-2:physCellId=53
...    NRCELL-2:chBw=40MHz
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:actDlSrsSubbandBm=true
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-2:actUeCsirsCoexistCellCsirs=true
...    NRCELL-2:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-2:srsForBeamMgmt:comb=comb4
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-2:srsForBeamMgmt:cSRS=24
...    NRCELL-2:srsForBeamMgmt:bSRS=2
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
...    NRCELL-2:wbSbSrsSwitch:channelStabilityHysteresis=100
...    NRCELL-2:wbSbSrsSwitch:channelStabilityThreshold=30
...    NRCELL-2:wbSbSrsSwitch:enableSbSrsVolatilityCheck=false
...    NRCELL-2:wbSbSrsSwitch:maxWbSbSwitch=10
...    NRCELL-2:wbSbSrsSwitch:numWbSrsConfigSample=10
...    NRCELL-2:wbSbSrsSwitch:numWbSrsReleaseSample=10
...    NRCELL-2:wbSbSrsSwitch:prbRatioHysteresis=1
...    NRCELL-2:wbSbSrsSwitch:prbRatioThreshold=2
...    NRCELL-2:wbSbSrsSwitch:prbSampleHighLowPercentage=60
...    NRCELL-2:wbSbSrsSwitch:rankHysteresis=4
...    NRCELL-2:wbSbSrsSwitch:rankThreshold=1
...    NRCELL-2:wbSbSrsSwitch:rlqBadPercentage=50
...    NRCELL-2:wbSbSrsSwitch:rlqGoodPercentage=20
...    NRCELL-2:wbSbSrsSwitch:seHysteresis=100
...    NRCELL-2:wbSbSrsSwitch:seThreshold=1
...    NRCELL-2:wbSbSrsSwitch:sortingMetric=DL Spectral Efficiency
...    NRCELL-2:wbSbSrsSwitch:wbSrsConfigProhibitTimer=100
...    NRCELL-2:wbSbSrsSwitch:wbSrsPowerHysteresis=100
...    NRCELL-2:wbSbSrsSwitch:wbSrsPowerThreshold=-1160
...    NRCELL-2:wbSbSrsSwitch:wbSrsReleaseProhibitTimer=1000
#1070 Frame Structure
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-2:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-2:prachConfigurationIndex=98

...    NRCELL-11:msg1FrequencyStart=11
...    NRCELL-11:timingAdvanceOffset=n25600
...    NRCELL-11:filterCoeffSsbRsrp=fc4
...    NRCELL-11:filterCoeffSsbRsrq=fc4
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:csirsPower=3
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-2:periodicCsiAcquisition:csirsPower=3
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-1:actCsirsMultiplexing=true
...    NRCELL-2:actCsirsMultiplexing=true

@{CB008322}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actCoverageNonCoherentUes=false
...    NRBTS:actFdmScheduling=true

...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actDl256Qam=true
...    NRCELL:actPdschAtSsbSlots=false
...    NRCELL:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL:srsForSubbandBm:maxNumUeSrs=2
...    NRCELL:srsForSubbandBm:srsPowerThreshold=-1350
...    NRCELL:srsForSubbandBm:srsUePeriodicityInput=slots20

@{1070_40M_bwp}
...    NRBTS/BWP_PROFILE-7:bwpType=initial
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-77:bwpType=dedicated
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-77/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    delete: NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetCommon
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7|cellBwpId=0
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-77|cellBwpId=1
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7|cellBwpId=0
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-77|cellBwpId=1

@{FDD_20M_bwp}
...    NRBTS/BWP_PROFILE-4:bwpType=initial
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-4/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-31:bwpType=dedicated
...    NRBTS/BWP_PROFILE-31:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-31:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-31:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-31:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-31/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-31/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    delete: NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetCommon
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL-11:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=0
...    NRCELL-11:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-31|cellBwpId=1

@{PARAMS_FOR_VoNR}
...    NRBTS:actNormVCFallback=false


...    NRULCLPC_PROFILE-1:nrUlClpcProfileId=1
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:srPeriodicityMin=slots20
...    NRCELL:actUlClosedLoopPwrCtrl=puschSrs
...    NRCELL:nrUlClpcProfileDN=NRULCLPC_PROFILE-1
...    NRCELL:srPeriodicity=slots40
...    NRCELL:actVoipPacketAggr=true
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=NRDRB_MAC-4
...    NRBTS/NRDRB-10:nrDrbPdcpDN=NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:cellAggrLevel=FR1 CA eligible
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
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=0
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
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

${CA_support_list}
...    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:dlToUlContributionRatio=50
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:fr1UlCaPreferred=dataRatePreferred
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRDRX-4:drxInactivityTimer=40ms
...    NRDRX-4:drxLongCycle=80ms
...    NRDRX-4:drxOnDurationTimer=60ms
...    NRDRX-4:drxRetransTimerDl=16slot
...    NRDRX-4:drxRetransTimerUl=16slot
...    NRCELL:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:lcrId=11
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlAndUl

${rdSrsCodebookAndTas}    0x590103
${rdSubBandSectorNumber}    0x5901DC
${rdSrsAllocMethod}    0x5901B6
${rdMaxSrsResPerSpecialSym1208}    0x5901EC
${rdMaxSrsResPerSpecialSym1070}    0x5901ED
${rdMaxSrsResPerSpecialSym1116}    0x5901EE
${rdMaxSrsResPerSym1208}    0x5900FD
${rdMaxSrsResPerSym1070}    0x590127
${rdMaxSrsResPerSym1116}    0x590128
${rdSubbandBfMethod}    0x5901BD
${rdEnableSrsSwitchScheduler}    0x5805ae
${rdNumSrsCheck}    0x5805b5
${rdNumberOfUeCsirsSymbol}    0x580265
${rdCsiRsReconfigCellToUE}    0x590179
${BOAM_RAT_ADAPT}    0x600013
${BOAM_FRONTHAUL}    0x19040F
${rdEnableSktMvp}    0x88004b
${rdBwvTxOpportunities}    0x880031

@{PARAMS_IN_SWCONFIG}
...    ${rdSrsCodebookAndTas}=0
...    ${rdSubBandSectorNumber}=3
...    ${rdSrsAllocMethod}=0
...    ${rdMaxSrsResPerSpecialSym1208}=1
...    ${rdMaxSrsResPerSpecialSym1116}=1
...    ${rdMaxSrsResPerSpecialSym1070}=1
...    ${rdMaxSrsResPerSym1208}=1
...    ${rdMaxSrsResPerSym1116}=1
...    ${rdMaxSrsResPerSym1070}=1
...    ${rdSubbandBfMethod}=0
...    ${rdEnableSrsSwitchScheduler}=1
...    ${rdNumSrsCheck}=100
...    ${rdNumberOfUeCsirsSymbol}=4
...    ${rdCsiRsReconfigCellToUE}=1
...    ${BOAM_RAT_ADAPT}=1
...    ${BOAM_FRONTHAUL}=1
...    ${rdEnableSktMvp}=0
...    ${rdBwvTxOpportunities}=14

${ERadParam_EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1

@{PARAMS_IN_IPHY_XML}
...    vcell:phy_cell_id=52|cell=2.1
...    vcell:dlFeatures=pmiBeams|cell=2.1
...    vcell:phy_cell_id=53|cell=2.2
...    vcell:dlFeatures=pmiBeams|cell=2.2

#SA UE1:
#SA UE1 support n71A_n78(2A), T+F DL/UL CA bandcombination:
#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n1
#n71A_n78(2A): t1r4 maxNumberSRS-Ports-PerResource=n1
${ue_nr_cap_SA_UE1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E439F
...    51CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FFF000007FFC0000
...    07400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04610D04083C4220032B
...    64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88E3C831E819F604F8073E618F
...    28581C0E1E0BD5555554F55555550E8000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082C0AC7C02000C0D8184C0309800030B
...    02B170080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C
...    0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680061340E2300000E0B02B1F130003098060080C0D8003C
...    2C0AC5C4C000C010181B0008058158F89A0018020300C0606C0022160561E26800711800009058158F80400181B0309A0613400261617009006E003404C808D0134750008081
...    85214285B1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891216C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1
...    C28913639F0E2448913639F0E14489B1CF871214285B1CF871A2448913639F0E2448913639F0E342891226C73E1C28D1B639F0E344890A16C73E180E8A0C6318C6318C6318C6
...    318C6318F4230003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000
...    C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D040
...    000259490100001965260400006594941000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504000
...    3259490100003165240334AA2E955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814004C202
...    0040080801002201002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060
...    1002004402018028080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C020180284040
...    300601002004402004008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008080600C30
...    100C01404030060100200404008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

#SA UE2:
#SA UE2 support n71A_n78A, n71A_n78(2A) T+F DL/UL CA bandcombinatio:
#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n2
#n71A_n78(2A): t1r4 maxNumberSRS-Ports-PerResource=n1
${ue_nr_cap_SA_UE2}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E439F
...    51CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FFF000007FFC0000
...    07400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04610D04083C4220032B
...    64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88E3C831E819F604F8073E618F
...    28581C0E1E0BD5555554F55555550E8000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082C0AC7C02000C0D8184C0309800030B
...    02B170080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C
...    0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680061340E2300000E0B02B1F130003098060080C0D8003C
...    2C0AC5C4C000C010181B0008058158F89A0018020300C0606C0022160561E26800711800009058158F80400181B0309A0613400261617009006E003404C808D0134750008081
...    8521468DB1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891216C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1
...    C28913639F0E2448913639F0E14489B1CF871214285B1CF871A2448913639F0E2448913639F0E342891226C73E1C28D1B639F0E344890A16C73E180E8A0C6318C6318C6318C6
...    318C6318F4230003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000
...    C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D040
...    000259494100001965260400006594941000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504000
...    3259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814004C202
...    0040080801002201002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060
...    1002004402018028080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C020180284040
...    300601002004402004020080100802018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008080600C30
...    100C01404030060100200404008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

#SA UE3 support n71_n78(2A) T+T+F bandcombination:
#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n2    maxNumberOfPeriodicSrsPerBwp=n4
#n71_n78(2A): t1r4-t2r4 maxNumberSRS-Ports-PerResource=n2    maxNumberOfPeriodicSrsPerBwp=n4
${ue_nr_cap_SA_UE3}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E439F5
...    1CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FFF000007FFC000007
...    400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04610D04083C4220032B64C
...    55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88E3C831E819F604F8073E618F2858
...    1C0E1E0BD5555554F55555550E8000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082C0AC7C02000C0D8184C0309800030B02B17
...    0080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C0
...    2000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680061340E2300000E0B02B1F130003098060080C0D8003C2C0AC5C
...    4C000C010181B0008058158F89A0018020300C0606C0022160561E26800711800009058158F80400181B0309A0613400261617009006E003404C808D013475000808185214285
...    B1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891216C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639
...    F0E2448913639F0E14489B1CF871234685B1CF871A2448913639F0E2448913639F0E342891226C73E1C28D1B639F0E344890A16C73E180E8A0C6318C6318C6318C6318C6318F4
...    230003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C0080000700
...    400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D040000255494100
...    001965260400006594941000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003
...    165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814004C20200400808010022
...    01002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060100200440201802
...    8080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840403006010020044020
...    04008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008080600C30100C0140403006010
...    0200404008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

#SA UE4 support n78(2A) T+T bandcombination:
#BAND78: t2r4 maxNumberSRS-Ports-PerResource=n2    maxNumberOfPeriodicSrsPerBwp=n8
#n78(2A): t1r4-t2r4 maxNumberSRS-Ports-PerResource=n1     maxNumberOfPeriodicSrsPerBwp=n8
${ue_nr_cap_SA_UE4}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E439F5
...    1CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FFF000007FFC000007
...    400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04610D04083C4220032B64C
...    55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88E3C831E819F604F8073E618F2858
...    1C0E1E0BD5555554F55555550E8000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082C0AC7C02000C0D8184C0309800030B02B17
...    0080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C0
...    2000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680061340E2300000E0B02B1F130003098060080C0D8003C2C0AC5C
...    4C000C010181B0008058158F89A0018020300C0606C0022160561E26800711800009058158F80400181B0309A0613400261617009006E003404C808D013475000808185214489
...    B1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891216C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639
...    F0E2448913639F0E14489B1CF871234685B1CF871A2448913639F0E2448913639F0E342891226C73E1C28D1B639F0E344890A16C73E180E8A0C6318C6318C6318C6318C6318F4
...    230003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C0080000700
...    400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D040000257494100
...    00196526040000A574901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003
...    165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814004C20200400808010022
...    01002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060100200440201802
...    8080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840403006010020044020
...    04018080100602018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008080600C30100C0140403006010
...    0200404008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

#NSA UE11,12:
#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n2
${ue_MRDC_cap}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000002C040BC4C0C03882001C460000
...    02160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C041809A3A0001720F1274A89B1CF871274289B1CF871274489B1CF871
...    274489B1CF87127448931CFA34E891224C73E893A24498E7C18051000040202004010080600C2000080404008020100C01860001008080600C02018030080600C200008040400
...    8020100200820001008080600C100008040403006

${ue_nr_full_cap}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E439F51
...    CF9863CA1607038782E007FE0038002F8003A00000E0541B107582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000740
...    0001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0AE3E236B04610D04083E508800AAD93156
...    1439F11C78C00000000000000000000000027FFC00001FFF000001D000007003DE1E26800710400000858081507850001C46000002160561E230007104000018581587850001C4
...    1000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A001C46000E230000020B02B170A
...    0003882001C46000004160562E1400071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E230000020B02B1713400388C001C28000008160561E23000
...    7118000018581007011A014404D80823A8002EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206
...    C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A11C001F001400180E0A00E060128038003
...    0120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E00800400000010000100080000900400001
...    8020000280100001600800409024010000180672A6B2A6B052B2A6B066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA48080
...    0024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058
...    AA0D154A62A93455018AA051549AAA83C50F002F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C20100200404030060100C
...    018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0
...    A4A8B4BD05060B40

@{UE1_A1_expect}
#DL CA: configure_1_1
...    pcid:52, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:2] configure_1_1
#UL CA: configure_0_1
...    pcid:60, scellIdx:2] configure_0_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{UE1_A1_unexpect}
...    usage antennaSwitching

@{UE2_A1_expect}
#DL CA: configure_1_1
...    pcid:52, scellIdx:1] configure_1_1
...    pcid:53, scellIdx:2] configure_1_1
#UL CA: configure_0_1
...    pcid:53, scellIdx:2] configure_0_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{UE1_unexpect}
...    usage antennaSwitching
...    SCellIndex 1 deactivated successfully at airphone
...    SCellIndex 2 deactivated successfully at airphone

@{UE_unexpect}
...    c-SRS 24
...    SCellIndex 1 deactivated successfully at airphone
...    SCellIndex 2 deactivated successfully at airphone

@{DL_Scell}
...    CellIndex-1
...    CellIndex-2

@{UE_A1_expect}
...    pcid:52, scellIdx:1
...    pcid:60, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{UE4_A1_unexpect}
...    nzp-CSI-RS-ResourceId 181

@{UE3_A1_unexpect}
...    nrofPorts p4

*** Test Cases ***
CB008322-ET-E028_Verify_TDD_FDD_2CC_UL_CA_no_WB_TAS_SRS_shall_be_allocated
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify: Verify no WB TAS SRS configured on SCell for TDD+FDD DL+UL CA
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=17:1 tac=200 tdd_cell=on band=n78 nr_arfcn=636666:636666 gscn=7880 chBw=40MHz sCellOperationalMode=dlOnly
    ...    Cell id=2 gnb=2 pci=17:2 tac=200 tdd_cell=on band=n78 nr_arfcn=628334:628334 gscn=7794 chBw=40MHz sCellOperationalMode=dlAndUl
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134980:127180 gscn=1589 chBw=20MHz sCellOperationalMode=dlAndUl
    ...    2.Test Case Steps:
    ...         a. SA UE1 attach to CELL2 and setup PDU.
    ...         b. UE1 send full DL and UL traffic.
    ...         c. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for UE1.
    ...         d. SA UE2 attach to CELL11 and setup PDU.
    ...         e. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for UE2.
    ...         f. UE2 send full DL and UL traffic.
    ...         g. UE1 stop full DL and UL traffic.
    ...    3. Expected Results:
    ...         Step a: UE1 is configured with Subband 4 1port tas srs resource and 1 1port codebook srs.
    ...                 Codebook resource is not reusing with the first tas srs resource.
    ...         Step b: UE1 is reconfigured with 4 1port Wideband tas srs resource is allocated on pcell.
    ...                 codebook srs is not reusing with its first wideband tas srs resource.
    ...         Step c: UE1 is configured with TDD cell-1 as DL only scell and FDD Cell-11 as DL&UL Scell.
    ...                 UE1 psrs is not configured on scells, pcell srs resouces are not changed.
    ...         Step d: UE2 is configed with 1 1port aperiodic codebook.
    ...         Step e: UE2 is configured with TDD cell-1 as DL only scell and TDD Cell-2 as DL&UL Scell.
    ...                 UE2 is reconfigured with Subband 1 1port periodic codebook and 4 1port tas srs on Scell TDD Cell-2 only.
    ...         Step f: UE2 Wideband procedure is not triggered, Wideband SRS resource is not allocated.
    ...         Step g: UE1 Subband codebook srs resource should keep as not changed. tas srs is not able to allocate.
    ...                 scell is still activated.
    [Tags]    QC_320643    E028    CA_LABEL-TTF(40MHz_TDD_n78+40MHz_TDD_n78+20MHz_FDD_n71)
    SA UE Attach    ue_id=1    cell_id=2
    UE Send And Verify Throughput
    UE Send A1 To Trigger Scell Addition And Add 2 SCells
    Verify Throughput CA
    UE Verify Throughput for UL CA
    SA UE Attach    ue_id=2    cell_id=11
    UE2 Send A1 To Trigger Scell Addition And Add 2 SCells
    UE2 Send And Verify Throughput CA
    UE Verify Throughput for UL CA    ue_id=2
    UE1 Stop Traffic And Verify Scell Still Activated
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_E028${/}a2a.ini    wait_string=UEContextReleaseComplete::8

CB008322-ET-E027_Verify_succesfully_and_unsuccesfully_WB_TAS_setup_after_inra-gnb_CA_scell_setup
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify:Verify when intra gnb CA scell addition and wideband SRS resouce reconfigure either success or unsuccess based
    ...         on resource pool availability
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=17:1 tac=200 tdd_cell=on band=n78 nr_arfcn=636666:636666 gscn=7880 chBw=40MHz
    ...    Cell id=2 gnb=2 pci=17:2 tac=200 tdd_cell=on band=n78 nr_arfcn=628334:628334 gscn=7794 chBw=40MHz
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134980:127180 gscn=1589 chBw=20MHz
    ...    2.Test Case Steps:
    ...         a. SA UE4 attach to CELL2 and setup PDU.,then trigger TTF CA
    ...         b. Send full DL traffic to SA UE4
    ...         c. SA UE3 attach to CELL2 and setup PDU.,then trigger TTF CA
    ...         d. Send full DL traffic to SA UE3
    ...         e. Stop traffic for SA UE3
    ...         f. Attach NSA UE11 and UE12 on Cell2 to occupy subband srs resource
    ...         g. Stop traffic for SA UE4
    ...    3. Expected Results:
    ...         Step a: Firstly registered, UE4 is configured with aperiodic codebook srs resource,UE4 is reconfigured with 1 1 port
    ...                 subband codebook srs resource and 4 1 port tas srs resources due to ue cap change with scells addition
    ...         Step b: UE4 is reconfigured with 4 1 port wideband tas srs resource, subband codebook srs resource reconfig to asrs as
    ...                 it conflicts with its wideband tas srs resource
    ...         Step c: Firstly registered, UE3 is configured with 4 1 port subband tas srs resource and codebook asrs resource,
    ...                 then 3CCs CA setup, UE3 is reconfigured to aperiodic codebook srs resource, UE specific CSIRS reconfig to CELL
    ...                 specific CSIRS
    ...         Step d: UE3 subband SRS resource is not changed due to wideband srs resource not available
    ...         Step e: Scell is not deactivated, UE3 SRS resource not changed
    ...         Step f: Both NSA UE are configured with 4 1 port subband tas srs resource and asrs codebook
    ...         Step g: UE4 reconfig to asrs subband resource due to 2 NSA UEs attach, there is no available srs subband resource
    [Tags]    QC_47146    E027    CA_LABEL-TTF(40MHz_TDD_n78+40MHz_TDD_n78+20MHz_FDD_n71)
    SA UE Attach    ue_id=4    cell_id=2
    UE Send A1 To Trigger Scell Addition And Add 2 SCells    ue_id=4    expect=${UE_A1_expect}    unexpect=${empty}
    UE Send And Verify DL Throughput
    SA UE Attach    ue_id=3    cell_id=2
    UE Send A1 To Trigger Scell Addition And Add 2 SCells    ue_id=3    expect=${UE_A1_expect}    unexpect=${UE3_A1_unexpect}
    UE Send And Verify DL Throughput    ue_id=3
    UE Stop Traffic    ue_id=3
    NSA UE Attach    ue_id=11    target_cells=2
    NSA UE Attach    ue_id=12    target_cells=2
    UE Stop Traffic    ue_id=4
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_E027${/}a2a.ini    wait_string=UEContextReleaseComplete::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_2T1F    ue_count=4

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
    Execute Cmd On Pc    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc    mkdir /home/ute/bsr_package/
    Execute Cmd On Pc    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git /home/ute/bsr_package/
    update_software    sw_package=/home/ute/bsr_package/BSR_FILE/${bsr_name}    timeout=60

Modify Cfg
    Update Cfg Param    set_cell id=1 gnb=2 pci=17:1
    Update Cfg Param    set_cell id=2 gnb=2 pci=17:2
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE2}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${ue_nr_cap_SA_UE3}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${ue_nr_cap_SA_UE4}
    Update Cfg    ue_param id=11 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_MRDC_cap}
    Update Cfg    ue_param id=12 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_MRDC_cap}

SA UE Attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    Initial Context Setup Successful

UE Send And Verify Throughput
    [Arguments]    ${ue_id}=1
    Send Traffic SA    ue_id=${ue_id}
    Verify Throuput SA    ue_id=${ue_id}

UE2 Send And Verify Throughput CA
    [Arguments]    ${ue_id}=2
    Send Traffic FDD    ue_id=${ue_id}
    Verify Throughput CA    ue_id=${ue_id}    Tput_dl=270    Tput_ul=30

Send Traffic SA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=3    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=4    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=5    pass_regexp=Started Downlink Internal traffic

Send Traffic FDD
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=3    pass_regexp=Started Downlink Internal traffic

Verify Throuput SA
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${sleep_time}=15s    ${Tput_dl}=50
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${Tput_dl}

Verify Throughput CA
    [Arguments]    ${ue_id}=1    ${Tput_dl}=270    ${Tput_ul}=40    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

UE Verify Throughput for UL CA
    [Arguments]    ${ue_id}=1    ${Target_0}=0    ${Target_2}=0
    ${throughput_0}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${throughput_2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pusch    rate_type=ave
    Should Be True    ${throughput_0}/1000>${Target_0}
    Should Be True    ${throughput_2}/1000>${Target_2}
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    pass_regexp=Throughput    fail_regexp=CellIndex-1
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps

UE Send A1 To Trigger Scell Addition And Add 2 SCells
    [Arguments]    ${ue_id}=1    ${expect}=${UE1_A1_expect}    ${unexpect}=${UE1_A1_unexpect}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=628320    event_type=A1    threshold=RSRP\ 31
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${expect}    fail_regexp=${unexpect}    timeout=10s

UE2 Send A1 To Trigger Scell Addition And Add 2 SCells
    [Arguments]    ${ue_id}=2
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=127210    event_type=A1
    ...    threshold=RSRP\ 111
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE2_A1_expect}    timeout=10s

UE1 Stop Traffic And Verify Scell Still Activated
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Stopped Downlink Internal traffic    fail_regexp=${UE1_unexpect}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=${DL_Scell}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    pass_regexp=CellIndex-2

NSA UE Attach
    [Arguments]    ${ue_id}=11    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    successful RA

UE Stop Traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Stopped Downlink Internal traffic    fail_regexp=${UE_unexpect}

UE Send And Verify DL Throughput
    [Arguments]    ${ue_id}=4
    Send DL Traffic SA    ue_id=${ue_id}
    Verify DL Throuput SA    ue_id=${ue_id}

Send DL Traffic SA
    [Arguments]    ${ue_id}=4
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=175 trf_id=1    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=175 trf_id=2    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=175 trf_id=3    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=175 trf_id=4    pass_regexp=Started Downlink Internal traffic

Verify DL Throuput SA
    [Arguments]    ${ue_id}=4    ${qfi}=1    ${sleep_time}=15s    ${Tput_dl}=50
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${Tput_dl}
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
