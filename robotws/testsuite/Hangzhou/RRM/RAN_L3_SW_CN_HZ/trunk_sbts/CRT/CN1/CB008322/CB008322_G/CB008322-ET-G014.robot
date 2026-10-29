*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-susana.yan    release-5G24R2     CB008322
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}
...    @{1208_bwp_80M}
...    @{1116_0ms_bwp}
...    @{PARAMS_FOR_HO}
...    @{PARAMS_FOR_CA}
...    @{MGconfig}
...    @{PARAMS_FOR_VoNR}

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
...    NRBTS/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRCELL-1:physCellId=51
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
...    NRCELL-1:srsForBeamMgmt:comb=comb4
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-1:srsForBeamMgmt:cSRS=49
...    NRCELL-1:srsForBeamMgmt:bSRS=2
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
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
...    NRCELL-1:wbSbSrsSwitch:rankHysteresis=1
...    NRCELL-1:wbSbSrsSwitch:rankThreshold=2
...    NRCELL-1:wbSbSrsSwitch:rlqBadPercentage=50
...    NRCELL-1:wbSbSrsSwitch:rlqGoodPercentage=20
...    NRCELL-1:wbSbSrsSwitch:seHysteresis=100
...    NRCELL-1:wbSbSrsSwitch:seThreshold=1
...    NRCELL-1:wbSbSrsSwitch:sortingMetric=DL Spectral Efficiency
...    NRCELL-1:wbSbSrsSwitch:wbSrsConfigProhibitTimer=100
...    NRCELL-1:wbSbSrsSwitch:wbSrsPowerHysteresis=100
...    NRCELL-1:wbSbSrsSwitch:wbSrsPowerThreshold=-1160
...    NRCELL-1:wbSbSrsSwitch:wbSrsReleaseProhibitTimer=1000
#1208 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:prachConfigurationIndex=98
...    delete: NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    NRCELL-2:physCellId=52
...    NRCELL-2:chBw=80MHz
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:actDlSrsSubbandBm=true
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-2:actCsirsMultiplexing=true
...    NRCELL-2:actUeCsirsCoexistCellCsirs=true
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
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
...    NRCELL-2:wbSbSrsSwitch:rankHysteresis=1
...    NRCELL-2:wbSbSrsSwitch:rankThreshold=2
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
...    NRCELL-11:timingAdvanceOffset=n25600

@{1208_bwp_80M}
...    NRBTS/BWP_PROFILE-5:bwpType=initial
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-55:bwpType=dedicated
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-55/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=1|searchSpaceId=6
...    delete: NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetCommon
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL-1:msg1FrequencyStart=0
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5|cellBwpId=0
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-55|cellBwpId=1

@{CB008322}
...    NRBTS:actCoverageNonCoherentUes=false
...    NRBTS:actFdmScheduling=true
...    NRBTS:actSlowPrbPooling=false
...    NRBTS:actConnRrcPooling=false
...    NRBTS:actScheUePooling =false
...    NRBTS:allowSlowPrbPoolingStatNdmSrs=false
...    NRBTS:actBbPoolTddFr1=false
...    NRBTS:actBbPoolTddFr1AlgEnh=false
#actBbPoolExtensionTddFr1=true
...    NRCELL-1:actShortBsrLimitAdaptation=true
...    NRCELL-2:actShortBsrLimitAdaptation=true
...    NRCELL-1:actInfTddFrameMuting=true
...    NRCELL-2:actInfTddFrameMuting=true
...    NRCELL-1:infTddFrameStructure:infTddFrameMutingBiAgreement=true
...    NRCELL-1:infTddFrameStructure:infFrameStructureType=tdLte
...    NRCELL-1:infTddFrameStructure:infLteToNrFrameShift=0ms
...    NRCELL-1:infTddFrameStructure:infScs=30 KHz
...    NRCELL-1:infTddFrameStructure:infGuardPeriodLength=4Symbols
...    NRCELL-1:infTddFrameStructure:infTdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:infTddFrameStructure:infTddFrameMutingBiAgreement=true
...    NRCELL-2:infTddFrameStructure:infFrameStructureType=tdLte
...    NRCELL-2:infTddFrameStructure:infLteToNrFrameShift=0ms
...    NRCELL-2:infTddFrameStructure:infScs=30 KHz
...    NRCELL-2:infTddFrameStructure:infGuardPeriodLength=4Symbols
...    NRCELL-2:infTddFrameStructure:infTdLteUlDlConfig=tdLteConfig2
...    NRCELL-11:maxNumPdschAllocationPerSlot=2
...    NRDU-1:actInterNumerologyCa=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actDl256Qam=true
...    NRCELL:actPdschAtSsbSlots=false
...    NRCELL:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:srsForSubbandBm:srsUePeriodicityInput=slots40
...    NRCELL-11:srsForSubbandBm:srsUePeriodicityInput=slots20
...    NRCELL-2:srsForSubbandBm:srsUePeriodicityInput=slots80
...    NRCELL:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL:srsForSubbandBm:maxNumUeSrs=4
...    NRCELL:srsForSubbandBm:srsPowerThreshold=-1350
...    NRCELL:srsForSubbandBm:actTasSrsForCriticalBandCombo=false
...    NRCELL:srsForSubbandBm:dynamicSrsRmMode=mode2

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

${CA_support_list}
...    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:dlToUlContributionRatio=50
...    NRDU-1:fr1UlCaPreferred=dataRatePreferred
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS-1/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS-1/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
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
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=36
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
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
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

@{PARAMS_FOR_VoNR}
...    NRBTS:actNormVCFallback=false
...    NRULCLPC_PROFILE-1:nrUlClpcProfileId=1
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
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

@{MGconfig}
...    NRCELL:actFlexGapOffset=none
...    NRCELL:mgta=ms0
...    NRCELL:gapOffset=0
...    NRCELL:ifhoSsbSmtcOffset=1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20

@{PARAMS_FOR_HO}
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=35
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1/NRHOIF-1:chBw=10MHz
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=127210
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-2:chBw=80MHz
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=628320

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
${rdNumberOfUeCsirsSymbol}    0x580265
${rdCsiRsReconfigCellToUE}    0x590179
${rdSBSrsHighLoadSample}    0x590232
${rdSBSrsLowLoadSample}    0x590233
${rdSBSrsLoadProh}    0x590234
${rdSBSrsHighLoadThresh}    0x590235
${rdSBSrsLoadMeaTimer}    0x590236

@{PARAMS_IN_SWCONFIG}
...    ${rdSBSrsHighLoadSample}=1
...    ${rdSBSrsLowLoadSample}=1
...    ${rdSBSrsLoadProh}=1
...    ${rdSBSrsHighLoadThresh}=100
...    ${rdSBSrsLoadMeaTimer}=5
...    ${rdSrsCodebookAndTas}=1
...    ${rdSubBandSectorNumber}=3
...    ${rdSrsAllocMethod}=0
...    ${rdMaxSrsResPerSpecialSym1208}=1
...    ${rdMaxSrsResPerSpecialSym1116}=1
...    ${rdMaxSrsResPerSpecialSym1070}=1
...    ${rdMaxSrsResPerSym1208}=5
...    ${rdMaxSrsResPerSym1116}=5
...    ${rdMaxSrsResPerSym1070}=5
...    ${rdSubbandBfMethod}=0
...    ${rdNumberOfUeCsirsSymbol}=2
...    ${rdCsiRsReconfigCellToUE}=1

#CB009496 flag
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496; 3 for SKTMVP

${ERadParam_EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1

@{PARAMS_IN_IPHY_XML}
...    vcell:phy_cell_id=51|cell=2.1
...    vcell:dlFeatures=pmiBeams|cell=2.1
...    vcell:phy_cell_id=52|cell=2.2
...    vcell:dlFeatures=pmiBeams|cell=2.2

#SA UE1-5:
#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n1
#n71_n78: t1r4 maxNumberSRS-Ports-PerResource=n1 txSwitchImpactToRx=2 (under n71 element)
${ue_nr_cap_SA_UE}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E439F5
...    1CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FFF000007FFC000007
...    400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04610D04083C4220032B64C
...    55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88E3C831E819F604F8073E618F2858
...    1C0E1E0BD5555554F55555550E8000038028B0F13400389A0000002C0AC5C4C000E26000713000000858158B88C00184C0309800020B02B1F008003036061300C260000C2C0AC
...    5C02000C010181B0002058158F8040018060303606134000A161758B80400181B0309800060B02B0F00800309800070B02B0F00800300400080B02B0F06C00303600090B02B0F
...    00800300C000A0B02B0F018003036000B0B02B1700800300C0606C0018160561E0D800713000006858158B898001C4C000E2300000E0B02B1F130003098060080C0D8003C2C0A
...    C5C4C000C010181B0008058158F89A0018020300C0606C0022160561E26800711800009058158F80400181B0309A0613400261617009006E003404C808D013475000808485214
...    68DB1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891216C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913
...    639F0E2448913639F0E14489B1CF8712142E4006C73E1C68912244D8E7C38912244D8E7C38D0A24489B1CF870A172003639F0E344890A16C73E1800E8A0C6318C6318C6318C63
...    18C6318F4230003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C0
...    080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D040000
...    259490100001965260400006594941000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259
...    490100003165240334AA2E955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814004C20200400
...    80801002201002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060100200
...    4402018028080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840403006010
...    02004402004008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008080600C30100C0140
...    4030060100200404008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

@{UE1_and_UE5_detached}
...    UE1: detached
...    UE4: detached
...    UE5: detached

@{UE4_fail_regexp}
...    srs-ResourceId 1

@{UE3_and_UE4_detached}
...    UE3: detached
...    UE4: detached

${ACC_UE_CONF_PERIOD_CDBK_SRS_DL}    M55196C00001
${ACC_UE_CONF_PERIOD_CDBK_SRS_UL}    M55196C00002
${MAX_UE_CONF_PERIOD_CDBK_SRS_DL}    M55196C00003
${MAX_UE_CONF_PERIOD_CDBK_SRS_UL}    M55196C00004
${ACC_UE_CONF_WITHOUT_SRS_DL}    M55196C00005
${ACC_UE_CONF_WITHOUT_SRS_UL}    M55196C00006
${MAX_UE_CONF_WITHOUT_SRS_DL}    M55196C00007
${MAX_UE_CONF_WITHOUT_SRS_UL}    M55196C00008
${ACC_UE_CONF_WB_BF_TAS_SRS}    M55196C00009
${ACC_UE_CONF_SB_BF_TAS_SRS}    M55196C00010
${MAX_UE_CONF_WB_BF_TAS_SRS}    M55196C00011
${MAX_UE_CONF_SB_BF_TAS_SRS}    M55196C00012
${DENOM_1S_SAMPLING}    M55196C00013

@{pm_Counters}
...     NRCELL-1:${ACC_UE_CONF_PERIOD_CDBK_SRS_DL}>=22
...     NRCELL-1:${ACC_UE_CONF_PERIOD_CDBK_SRS_UL}>=184
...     NRCELL-1:${MAX_UE_CONF_PERIOD_CDBK_SRS_DL}=1
...     NRCELL-1:${MAX_UE_CONF_PERIOD_CDBK_SRS_UL}=5
...     NRCELL-1:${ACC_UE_CONF_WITHOUT_SRS_DL}>=1
...     NRCELL-1:${ACC_UE_CONF_WITHOUT_SRS_UL}>=1
...     NRCELL-1:${MAX_UE_CONF_WITHOUT_SRS_DL}=1
...     NRCELL-1:${MAX_UE_CONF_WITHOUT_SRS_UL}=1
...     NRCELL-1:${ACC_UE_CONF_WB_BF_TAS_SRS}>=90
...     NRCELL-1:${ACC_UE_CONF_SB_BF_TAS_SRS}>=70
...     NRCELL-1:${MAX_UE_CONF_WB_BF_TAS_SRS}=2
...     NRCELL-1:${MAX_UE_CONF_SB_BF_TAS_SRS}=2
...     NRCELL-1:${DENOM_1S_SAMPLING}=300

@{expect_FDD_Scell}
...    pcid:60, scellIdx:1
...    pcid:60, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:1] configure_0_1
...    SCellIndex 1 activated successfully at airphone

@{unexpect_other_Scells}
...    SCellIndex 2 activated successfully at airphone

*** Test Cases ***
CB008322-ET-G014_Verify_CBC_IWK_1208_WB_TAS_allocated_first_then_covbasedA1_Scell_addition_with_cbcTasConflictPolicy_From_CBCFirst_to_TAS_first
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios,Equally cover case G014,G032 and G037:
    ...    a. WB SRS period danamic adaption
    ...    b. dynamic pool adaption between SB SRS pool and WB SRS resouce pool
    ...    c. CBC interworking
    ...    d. CB008322 counter verify
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_20669, 5G_RAN_USR_RRM_22219,5G_PM_1339 fully covered 
    ...    [Configuration]:
    ...    Cell id=1  gnb=2 pci=17:0 tac=200 tdd_cell=on  band=n78 nr_arfcn=636666:636666 gscn=7880 chBw=80MHz
    ...    Cell id=2  gnb=2 pci=17:1 tac=200 tdd_cell=on  band=n78 nr_arfcn=628334:628334 gscn=7794 chBw=80MHz
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134980:127180 gscn=1589 chBw=10MHz
    ...    Cell1: PCI51 Frame structure 1208, srsForBeamMgmt.srsUePeriodicity = 20slots,  srsForBeamMgmt.minSrsUePeriodicity = 40slots
    ...    / \ availableSubbandSrsBmResourcesTable
    ...    | availableWidebandSrsBmResourcesTable
    ...    Comb4  cyclicShift | symbol 0 | symbol 1 | symbol 2   | symbol 3   | symbol 4   | symbol 5   | symbol 6 | symbol 7 |
    ...        Slot id        |      3   |      8   |     13     |     18     |     23     |     28     |     33   |     38   |
    ...    0        0         |          |    UE5   |UE1/UE4/UE2 |UE1/UE4/UE2 |UE1/UE4/UE2 |UE1/UE4/UE2 |          |          |
    ...    0        3         |          |          |            |            |            |            |          |          |
    ...    0        6         |          |          |    UE5     |    UE5     |    UE5     |            |          |          |
    ...    0        9         |          |          |            |            |            |            |          |          |
    ...    3        0         /  UE1(0)  /    UE1   /    UE1     /    UE1     \    UE5     \    UE5     \  UE5(0)  \    UE5   \ freqDomainPosition0
    ...    3        0         /          /    UE2   /    UE2     /    UE3     \    UE3     \    UE3     \    UE2   \  UE2(0)  \ freqDomainPosition2
    ...    3        0         /          /          /            /            \            \            \    UE3   \  UE4(0)  \ freqDomainPosition4
    ...    3        3         /          /          /            /            \            \            \          \          \
    ...    3        6         /          /          /            /            \            \            \          \          \
    ...    3        9         /          /          /            /            \            \            \          \          \
    ...    2.Test Case Steps:
    ...         Step a. SA UE1 and UE5 attach on cell1
    ...         Step b. send full traffic to SA UE1 and UE5
    ...         Step c. SA UE2-UE4 attach to CELL1 and setup PDU
    ...         Step d. Stop traffic for UE1 and UE5, then Release UE1,UE4 and UE5
    ...         Step e. UE4 attach to CELL1 again and setup PDU
    ...         Step f. send full DL traffic to SA UE4 to trigger WB SRS reconfiguration
    ...         Step g. Stop traffic for UE4, then Release UE3 and UE4
    ...         Step h. Send A1 measurement report to trigger UE2 scell addition
    ...         Step i. release all UEs
    ...         Step j. check counters
    ...         Step k. WireShark Log check
    ...    3. Expected Results:
    ...         Step a: UE1 and UE5 attached successfuly with SB psrs allocated
    ...         Step b: UE1 and UE5 is configured with 4 1 port wideband tas srs regardless of DRX, and Fake drx is setup
    ...         Step c: UE2 to UE4 attached successfuly, the UE2 and UE3 can allocated SB resource successfully and UE4 no tas psrs allocated since
    ...                 no available psrs resources
    ...         Step d: UE1,UE4 and UE5 is release successfully
    ...         Step e: UE4 attached successfuly, and tas psrs allocated as all WB srs resource mark and add to subband resource pool
    ...         Step f: UE4 DL traffic is send successfully and No WB TAS reconfiguration performed as all WB srs resource mark and add to subband 
    ...                 resource pool
    ...         Step g. UE4 is release successfully
    ...         Step h. 
    ...                1.NRCELL-11 successfully added as scell
    ...                2.WB TAS SRS released and SB TAS SRS allocated accordingly due to parameter "actTasSrsForCriticalBandCombo" is equal to FALSE
    ...         Step i. UE are release successfully
    ...         Step j. relevance counters updated correctly
    ...         Step k. WireShark Log check is passed
    [Tags]    QC_47149    G014    CA_LABEL-TF(80MHz_TDD_n78+10MHz_FDD_n71)
    Clear Counter Files
    SA UE1 and UE5 attach on cell1
    SA UE1 and UE5 send Traffic
    PreUE attach UE2-3    from_ue_id=2    ue_count=2    cell_id=1
    SA UE4 Attach        cell_id=1    ue_id=4    UE4_fail_regexp=${UE4_fail_regexp}
    SA UE release    ue_id=1,4,5    stop_ue_trf=1,5    detached=${UE1_and_UE5_detached}
    UE4 attach again and send Traffic trrigger WB
    SA UE release    ue_id=3,4    stop_ue_trf=4    detached=${UE3_and_UE4_detached}
    SA UE Send And Verify Throughput    ue_id=2    trf_count=1
    UE2 Send A1 To Trigger Scell Addition
    Release ues    ue_type=all
    Run Keyword And Ignore Error    Check Counters    pm_counters_expression=${pm_Counters}
    Check WireShark Log    ${CURDIR}${/}A2A_CB008322_G014${/}a2a.ini    wait_string=UEContextReleaseComplete::24

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_2T1F    ue_count=6

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
    Execute Cmd On Pc    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc    mkdir /home/ute/bsr_package/
    Execute Cmd On Pc    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git /home/ute/bsr_package/
    update_software    sw_package=/home/ute/bsr_package/BSR_FILE/${bsr_name}    timeout=60

Modify Cfg
    Update Cfg Param    set_cell id=1 gnb=2 pci=17:0
    Update Cfg Param    set_cell id=2 gnb=2 pci=17:1
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${ue_nr_cap_SA_UE}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${ue_nr_cap_SA_UE}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${ue_nr_cap_SA_UE}

SA UE1 and UE5 attach on cell1
    SA UE Attach    cell_id=1    ue_id=1
    SA UE Attach    cell_id=1    ue_id=5

SA UE Attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    BuiltIn.Log    SA UE${ue_id} Attach...    console=${True}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    Initial Context Setup Successful

SA UE1 and UE5 send Traffic
    SA UE Send And Verify Throughput    ue_id=1    trf_count=1
    SA UE Send And Verify Throughput    ue_id=5    trf_count=1

PreUE attach UE2-3
    [Arguments]    ${from_ue_id}=2    ${ue_count}=1    ${cell_id}=1    ${pdu_id}=1
    FOR    ${ue}    IN RANGE    ${from_ue_id}    ${from_ue_id}+${ue_count}
        SA UE Attach    ue_id=${ue}    cell_id=${cell_id}    pdu_id=${pdu_id}
    END

SA UE4 Attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${UE4_fail_regexp}=${None}
    BuiltIn.Log    SA UE${ue_id} Attach...    console=${True}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    pass_regexp=Initial Context Setup Successful
    ...    fail_regexp=${UE4_fail_regexp}

UE4 attach again and send Traffic trrigger WB
    sleep    5s    #wait for resource release
    SA UE Attach    cell_id=1    ue_id=4
    SA UE Send And Verify Throughput    ue_id=4    trf_count=1

SA UE Send And Verify Throughput
    [Arguments]    ${ue_id}=1    ${trf_count}=3    ${qfi}=1    ${sleep_time}=10s    ${Tput_dl}=148
    Send Traffic SA    ue_id=${ue_id}    trf_count=${trf_count}
    Verify Throuput SA    ue_id=${ue_id}    qfi=${qfi}    sleep_time=${sleep_time}    Tput_dl=${Tput_dl}

SA UE release
    [Arguments]    ${ue_id}=3    ${detached}=${None}    ${stop_ue_trf}=3
    Execute Egate Command    trf_data_stop ue=${stop_ue_trf} pdu=1    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=${detached}

Send Traffic SA
    [Arguments]    ${ue_id}=1    ${trf_count}=3    ${sleep_time}=2s
    FOR    ${trf_id}    IN RANGE    1    ${trf_count}+1
        Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=${trf_id}    pass_regexp=Started Downlink Internal traffic
        sleep    ${sleep_time}    #wait trf stable
    END
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink Internal traffic

Verify Throuput SA
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${sleep_time}=10s    ${Tput_dl}=400
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${Tput_dl}

UE2 Send A1 To Trigger Scell Addition
    [Arguments]    ${ue_id}=2    ${carrierfreq}=636576    ${srsrp_nr}=70
    BuiltIn.Log    SA UE${ue_id} Send A1 To Trigger Scell Addition...    console=${True}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    ...    event_type=A1    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=40
    ...    pass_regexp=${expect_FDD_Scell}    fail_regexp=${unexpect_other_Scells}    timeout=20s
