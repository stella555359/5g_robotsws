*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs And Recovery RD parameter
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-jun.15.zhang    release-5G24R2     CB008322
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}
...    @{1070_bwp}
...    @{1116_0ms_bwp}
...    @{PARAMS_FOR_VoNR}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_PCellSwitch}

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
...    NRCELL-1:chBw=80MHz
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-1:actDlSrsSubbandBm=true
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=8DL4UL
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-1:actCsirsMultiplexing=true
...    NRCELL-1:actUeCsirsCoexistCellCsirs=true
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:csirsPower=3
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-1:srsForBeamMgmt:comb=comb4
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-1:srsForBeamMgmt:cSRS=49
...    NRCELL-1:srsForBeamMgmt:bSRS=2
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
...    NRCELL-1:wbSbSrsSwitch:channelStabilityHysteresis=100
...    NRCELL-1:wbSbSrsSwitch:channelStabilityThreshold=30
...    NRCELL-1:wbSbSrsSwitch:enableSbSrsVolatilityCheck=false
...    NRCELL-1:wbSbSrsSwitch:maxWbSbSwitch=10
...    NRCELL-1:wbSbSrsSwitch:numWbSrsConfigSample=10
...    NRCELL-1:wbSbSrsSwitch:numWbSrsReleaseSample=10
...    NRCELL-1:wbSbSrsSwitch:prbRatioHysteresis=1
...    NRCELL-1:wbSbSrsSwitch:prbRatioThreshold=2
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
...    NRCELL-2:chBw=80MHz
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:actDlSrsSubbandBm=true
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-2:actCsirsMultiplexing=true
...    NRCELL-2:actUeCsirsCoexistCellCsirs=true
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-2:periodicCsiAcquisition:csirsPower=3
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-2:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-2:srsForBeamMgmt:comb=comb4
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots80
...    NRCELL-2:srsForBeamMgmt:cSRS=49
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
#1116_0 Frame Structure
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/9
...    NRCELL-2:prachConfigurationIndex=97

@{CB008322}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actCoverageNonCoherentUes=false
...    NRBTS:actFdmScheduling=true

...    NRDU-1:actInterNumerologyCa=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actDl256Qam=true
...    NRCELL:actPdschAtSsbSlots=false
...    NRCELL:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL:srsForSubbandBm:maxNumUeSrs=2
...    NRCELL:srsForSubbandBm:srsPowerThreshold=-1350
...    NRCELL:srsForSubbandBm:srsUePeriodicityInput=slots40

@{1070_bwp}
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7|cellBwpId=0
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-77|cellBwpId=1

@{1116_0ms_bwp}
...    NRBTS/BWP_PROFILE-6:bwpType=initial
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-6/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=3
...    NRBTS/BWP_PROFILE-67:bwpType=dedicated
...    NRBTS/BWP_PROFILE-67:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-67:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-67:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-67:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-67/PDSCH-1:pdschId=1
#...    NRBTS/BWP_PROFILE-67/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-67/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    delete: NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetCommon
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-6|cellBwpId=0
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-67|cellBwpId=1

@{PARAMS_FOR_VoNR}
...    NRBTS:actNormVCFallback=false


...    NRULCLPC_PROFILE-1:nrUlClpcProfileId=1
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=false
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

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:lcrId=11
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
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
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly

@{PARAMS_FOR_PCellSwitch}
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=60
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:chBw=10MHz
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=127210
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=10
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=9
...    NRCELL-1/NRHOIF-2:chBw=80MHz
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=628320
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=10

@{Delta_Params_For_E030}
...    NRBTS:sCellActivationMethod=blind
...    NRCELL-1:actUeCsirsCoexistCellCsirs=false
...    NRCELL-2:actUeCsirsCoexistCellCsirs=false

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

@{PARAMS_IN_SWCONFIG}
...    ${rdSrsCodebookAndTas}=1
...    ${rdSubBandSectorNumber}=3
...    ${rdSrsAllocMethod}=0
...    ${rdMaxSrsResPerSpecialSym1208}=3
...    ${rdMaxSrsResPerSpecialSym1116}=3
...    ${rdMaxSrsResPerSpecialSym1070}=3
...    ${rdMaxSrsResPerSym1208}=5
...    ${rdMaxSrsResPerSym1116}=5
...    ${rdMaxSrsResPerSym1070}=5
...    ${rdSubbandBfMethod}=0
...    ${rdEnableSrsSwitchScheduler}=1
...    ${rdNumSrsCheck}=100
...    ${rdNumberOfUeCsirsSymbol}=4
...    ${rdCsiRsReconfigCellToUE}=0
#CB009496 flag
...    0x600013=1     #9496 BOAM_RAT_ADAPT
...    0x19040F=1     #9496 BOAM_FRONTHAUL
...    0x88004b=0     #L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496; 3 for SKTMVP

${ERadParam_EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1

@{PARAMS_IN_IPHY_XML}
...    vcell:phy_cell_id=52|cell=2.1
...    vcell:dlFeatures=pmiBeams|cell=2.1
...    vcell:phy_cell_id=53|cell=2.2
...    vcell:dlFeatures=pmiBeams|cell=2.2

#SA UE1: 
#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n2
#n71_n78(2A): t1r4-t2r4 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E439F
...    51CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FFF000007FFC0000
...    07400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04610D04083C4220032B
...    64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88E3C831E819F604F8073E618F
...    28581C0E1E0BD5555554F55555550E8000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082C0AC7C02000C0D8184C0309800030B
...    02B170080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C
...    0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680061340C23000382C0AC7C4C000C260180203036000F0B
...    02B171300030040606C0020160563E2680060080C030181B0008858158789A0018460009058158F80400181B0309A0613400261617009006E003404C808D0134750008081852
...    14285B1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891216C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28
...    913639F0E2448913639F0E14489B1CF871234685B1CF871A2448913639F0E2448913639F0E342891226C73E1C28D1B639F0E344890A16C73E180E8A0C6318C6318C6318C6318
...    C6318F4230003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C00
...    80000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D040000
...    259494100001965260400006594941000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504000325
...    9490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814004C202004
...    0080801002201002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060100
...    2004402018028080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C020180284040300
...    601002004402004008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008080600C30100
...    C01404030060100200404008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

#SA UE2:
#BAND78: t2r4 maxNumberSRS-Ports-PerResource=n2
#n71_n78(2A): t1r4 maxNumberSRS-Ports-PerResource=n1
#maxNumberSimultaneousNZP_CSI_RS_ActBWP_AllCC=3
#totalnumberportsimultaneousNZP-CSI-RS-ActBWP-AllCC=64
${ue_nr_cap_SA_UE2}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E439F
...    51CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000
...    07400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04610D04083C4220032B
...    64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88E3C831E819F604F8073E618F
...    28581C0E1E0BD5555554F55555550E8000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082C0AC7C02000C0D8184C0309800030B
...    02B170080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C
...    0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680061340C23000382C0AC7C4C000C260180203036000F0B
...    02B171300030040606C0020160563E2680060080C030181B0008858158789A0018460009058158F80400181B0309A0613400261617009006E003404C808D0134750008081852
...    14489B1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891226C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28
...    913639F0E2448913639F0E14489B1CF871214285B08F871A2448913639F0E2448913639F0E344891226C73E1C2850B639F0E344891226C73E180E8A0C6318C6318C6318C6318
...    C6318F4230003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C00
...    80000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D040000
...    259494100001965260400006594941000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504000325
...    9490100003165240334AAAE955552A8BA5515416AA82C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814004C202004
...    0080801002201002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060100
...    2004402018028080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C020180284040300
...    601002004402004020080100802018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202010018080600C30100
...    C01404030060100200404008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

#SA UE3: 
#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n1
#n71_n78(2A): t1r4 maxNumberSRS-Ports-PerResource=n1
#supportedBandCombinationList-v1540 - maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC=1
#supportedBandCombinationList-v1540 - totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllCC=64
${ue_nr_cap_SA_UE3}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E439F
...    51CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000
...    07400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04610D04083C4220032B
...    64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88E3C831E819F604F8073E618F
...    28581C0E1E0BD5555554F55555550E8000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082C0AC7C02000C0D8184C0309800030B
...    02B170080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C
...    0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680061340C23000382C0AC7C4C000C260180203036000F0B
...    02B171300030040606C0020160563E2680060080C030181B0008858158789A0018460009058158F80400181B0309A0613400261617009006E003404C808D0134750008081852
...    14285B00F871224489B00F871224489B00F871A2448913601F0E2448913601F0E344891226C03E1C4891226C03E1C28913601F0E14489B00F870A244D807C3851226C03E1C28
...    913601F0E2448913601F0E14489B00F871214285B00F871A2448913601F0E2448913601F0E344891226C03E1C2850B601F0E344891226C03E180E8A0C6318C6318C6318C6318
...    C6318F4230003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C00
...    80000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D040000
...    259490100001965240400006594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652404000325
...    9490100003165240334AA2E954552A8BA55154162A82C55068AA531549A2A80C55028AA4D1541E28780178095028140A05028140A05028140A05028140A0502814004C202004
...    0200801008201002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060100
...    2004402018028080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C020180284040300
...    601002004402004020080100802018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202010018080600C30100
...    C01404030060100200404008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

@{UE1_expect}
...    pcid:53, scellIdx:1
...    pcid:60, scellIdx:2
@{UE2_expect}
...    pcid:52, scellIdx:1
...    SCellIndex 1 activated successfully at airphone
@{UE2_unexpect}
...    SCellIndex 2 activated successfully at airphone
@{UE3_unexpect}
...    SCellIndex 1 activated successfully at airphone
...    srs-Config setup
@{A2REL_expect}
...    sCellToReleaseList
...    rrcReconfigurationComplete

*** Test Cases ***
CB008322-ET-E029_Verify_correctly_SRS_resource_handling_when_ue_with_WB_TAS_configured_and_Pcell_change_performed
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify correctly SRS resource handling when ue with WB TAS configured and Pcell change performed.
    ...    [Configuration]:
    ...    Cell id=1  gnb=2 pci=17:1 tac=200 tdd_cell=on  band=n78 nr_arfcn=636666:636666 gscn=7880 chBw=80MHz
    ...    Cell id=2  gnb=2 pci=17:2 tac=200 tdd_cell=on  band=n78 nr_arfcn=628334:628334 gscn=7794 chBw=80MHz
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134980:127180 gscn=1589 chBw=10MHz
    ...    2.Test Case Steps:
    ...         a. SA UE1 attach to CELL1 and setup PDU.
    ...         b. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for UE1.
    ...         c. send full DL traffic to SA UE1.
    ...         d. A2 measurement report based PCell change with PCell RSRP below threashold and SCell RSRP is good enough
    ...    3. Expected Results:
    ...         Step a: UE1 is configured with 1 2port codebook srs resource.
    ...         Step b: UE1 is reconfigured with 2 2port subband tas srs and 1 2port codebook srs resource.
    ...                 the fisrt tas srs resource is reusing codebook srs resource.
    ...                 Srs resources are on or close to the end of drx on duration slot.
    ...                 SA UE1 add CELL2 and CELL11 for TDD-TDD-FDD 3CC CA. No tas srs resource allocate on scell.
    ...                 cell specific csirs is allocated(rrc message nrofPorts=p8)
    ...         Step c: UE1 is reconfigured with 2 2port wideband tas srs
    ...                 subband codebook srs resource keep unchanged if no conflict with its wideband srs resource.
    ...                 Scell is activated successfully, no tas srs resource allocate on scell. 
    ...         Step d: UE1 trigger Pcell switch, IFHO trigger from CELL1 to CELL11
    ...                 scell CELL2 released, No periodic srs resource allocate on pcell nor scell.
    ...                 cell specific csirs is allocated(rrc message nrofPorts=p2)
    [Tags]    QC_320642    E029    CA_LABEL-TTF(80MHz_TDD_n78+80MHz_TDD_n78+10MHz_FDD_n71)
    Set radPdcchApplyToSeparateStream for AP
	SA UE Attach    ue_id=1    cell_id=1
    UE1 Send A1 To Trigger Scell Addition And Add 2 SCells
    UE1 Send And Verify Throughput CA
    UE1 Send A2 To Trigger PCell Switch To FDD Cell
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_E029${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008322-ET-E030_Verify_intra-gnb_CA_scell_addition_admission_control_fail_after_WB_TAS_setup
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify when wideband tas srs setup and perform intra gnb CA scell addition fail due to gnb-DU admission control fail,
    ...    srs resource configure back successfully.
    ...    2.Test Case Steps:
    ...         a. SA UE2 attach to CELL2 and setup PDU
    ...         b. UE2 send full DL traffic
    ...         c. A1 measurement report based SCell addition is triggered for SA UE2
    ...         d. A2 measurement report based SCell release is triggered for SA UE2 to release CELL1.
    ...         e. SA UE3 attach to CELL2 and setup PDU
    ...         f. UE3 send full DL traffic
    ...         g. A1 measurement report based SCell addition is triggered for SA UE3
    ...    3. Expected Results:
    ...         Step a: UE2 is configured with 2 2port subband tas srs and 1 2port codebook srs resource.
    ...                 the fisrt tas srs resource is reusing codebook srs resource.
    ...                 Srs resources are on or close to the end of drx on duration slot.
    ...                 CELL spec CSIRS resouce is allocated for UE(Check rrcReconfiguration.csi_MeasConfig IE: nrofPorts=p8).
    ...         Step b: UE2 is reconfigured to wide band with 2 2port wideband tas srs regardless of drx.
    ...                 CELL spec CSIRS resouce is keep allocated for UE2.
    ...         Step c: UE2 is reconfigured 1 1port subband codebook srs resource and 4 1port wideband tas srs resource.
    ...                 UE2 only add CELL1 as scell, another FDD scell add failed due to UE capa limitation.
    ...                 No tas srs resource allocate on scells.
    ...         Step d: UE2 is reconfigured with 2 2port wideband tas srs and 1 2port subband codebook srs.
    ...                 All scells release successfully.
    ...         Step e: UE3 is configured with 4 1port subband tas srs and 1 1port codebook srs resource.
    ...                 the fisrt tas srs resource is reusing codebook srs resource.
    ...                 Srs resources are on or close to the end of drx on duration slot.
    ...                 CELL spec CSIRS resouce is allocated for UE(Check rrcReconfiguration.csi_MeasConfig IE: nrofPorts=p8).
    ...         Step f: UE3 is reconfigured to wide band with 4 1port wideband tas srs regardless of drx.
    ...                 CELL spec CSIRS resouce is keep allocated for UE3.
    ...         Step g: UE3 Scell add failed due to UE capa limitation. UE3 tas and codebook srs resource no update.
    [Tags]    QC_320641    E030    CA_LABEL-TTF(80MHz_TDD_n78+80MHz_TDD_n78+10MHz_FDD_n71)
    Delta Params For E030
    Set radPdcchApplyToSeparateStream for AP
    SA UE Attach    ue_id=2    cell_id=2
    SA UE Send And Verify Throughput    ue_id=2
    UE2 Send A1 To Trigger Scell Addition Only Add Cell1 As SCELL
    Verify Throughput CA    ue_id=2
    UE Send A2 To Trigger Scell Release    ue_id=2
    SA UE Attach    ue_id=3    cell_id=2
    SA UE Send And Verify Throughput    ue_id=3
    UE3 Send A1 To Trigger Scell Addition And No SCELL Added
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_E030${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_2T1F    ue_count=3
	
Common Test Teardown And Stop Capture Logs And Recovery RD parameter
    Common Test Teardown And Stop Capture Logs
	Recovery radPdcchApplyToSeparateStream for AP

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

SA UE Attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    Initial Context Setup Successful

SA UE Send And Verify Throughput
    [Arguments]    ${ue_id}=1
    Send Traffic SA    ue_id=${ue_id}
    Verify Throuput SA    ue_id=${ue_id}    sleep_time=30s

UE1 Send And Verify Throughput CA
    [Arguments]    ${ue_id}=1
    Send Traffic SA CA    ue_id=${ue_id}
    Verify Throughput CA    ue_id=${ue_id}    Tput_dl=800    Tput_ul=2

Send Traffic SA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=175 trf_id=2    pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=175 trf_id=3    pass_regexp=UE${ue_id}: Started Downlink Internal traffic

Send Traffic SA CA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2    pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=3    pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=4    pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=5    pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=6    pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=7    pass_regexp=UE${ue_id}: Started Downlink Internal traffic

Verify Throuput SA
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${sleep_time}=15s    ${Tput_dl}=315
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${Tput_dl}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${Tput_dl}

Verify Throughput CA
    [Arguments]    ${ue_id}=1    ${Tput_dl}=315    ${Tput_ul}=8    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

UE1 Send A1 To Trigger Scell Addition And Add 2 SCells
    [Arguments]    ${ue_id}=1
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A1    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE1_expect}    timeout=20s

UE2 Send A1 To Trigger Scell Addition Only Add Cell1 As SCELL
    [Arguments]    ${ue_id}=2
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=628320    event_type=A1    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE2_expect}    fail_regexp=${UE2_unexpect}    timeout=20s

UE3 Send A1 To Trigger Scell Addition And No SCELL Added
    [Arguments]    ${ue_id}=3
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=628320    event_type=A1    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    fail_regexp=${UE3_unexpect}    timeout=20s

UE1 Send A2 To Trigger PCell Switch To FDD Cell
    [Arguments]    ${ue_id}=1
    ${Switch_A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A2    threshold=RSRP\ 60
    ${PCellSwitch}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Switch_A2} event=A2 srsrp_nr=0 srsrq_nr=0 scell=2 scell_rsrp=115
    ...    scell_rsrq=35
    Execute Egate Command    ${PCellSwitch}    pass_regexp=UE${ue_id}: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.11 performed    timeout=20s

UE Send A2 To Trigger Scell Release
    [Arguments]    ${ue_id}=1
    ${ScellRel_A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A2    threshold=RSRP\ 34
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellRel_A2} event=A2 scell=1 scell_rsrp=20
    ...    pass_regexp=${A2REL_expect}    timeout=20s

Delta Params For E030
    Delta Commission Parameters    ${Delta_Params_For_E030}
    Cells Should Be OnAir

Set radPdcchApplyToSeparateStream for AP
    ${Command_1}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radPdcchApplyToSeparateStreams_AP 
    ...    --value 1 --change-type persistent --timeout 5
    ${Command_2}    catenate
    ...    bsh 2:1 confmgmtdefscli set --domain NrUeDlPhy  --name radPdcchApplyToSeparateStreams_AP 
    ...    --value 1 --change-type persistent --timeout 5
	    ${Command_3}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radIqDumpInSyslog 
    ...    --value 15 --change-type persistent --timeout 5
	${Command_4}    catenate
    ...    bsh 2:1 confmgmtdefscli set --domain NrUeDlPhy  --name radIqDumpInSyslog 
    ...    --value 15 --change-type persistent --timeout 5
    Execute Command On Wts    ${Command_1}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_2}
	Execute Command On Wts    bsh 2:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_3}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_4}
	Execute Command On Wts    bsh 2:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5

Recovery radPdcchApplyToSeparateStream for AP
    ${Command_1}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radPdcchApplyToSeparateStreams_AP 
    ...    --value 0 --change-type persistent --timeout 5
    ${Command_2}    catenate
    ...    bsh 2:1 confmgmtdefscli set --domain NrUeDlPhy  --name radPdcchApplyToSeparateStreams_AP 
    ...    --value 0 --change-type persistent --timeout 5
	    ${Command_3}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radIqDumpInSyslog 
    ...    --value 65535 --change-type persistent --timeout 5
	${Command_4}    catenate
    ...    bsh 2:1 confmgmtdefscli set --domain NrUeDlPhy  --name radIqDumpInSyslog 
    ...    --value 65535 --change-type persistent --timeout 5
    Execute Command On Wts    ${Command_1}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_2}
	Execute Command On Wts    bsh 2:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_3}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_4}
	Execute Command On Wts    bsh 2:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
