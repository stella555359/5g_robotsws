*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-jiangping.cao    release-5G24R2     CB008322
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}
...    @{1116_3ms_bwp}
...    @{1116_3_Frame_Structure}
...    @{PARAMS_FOR_VoNR}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_NRHOIF}
...    @{FDD_CELL11_Config}
...    @{FDD_CELL_bwp}

@{PARAMS_IN_IPHY_XML}
...    vcell:phy_cell_id=51|cell=2.1
...    vcell:dlFeatures=pmiBeams|cell=2.1
...    vcell:phy_cell_id=52|cell=2.2
...    vcell:dlFeatures=pmiBeams|cell=2.2

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
...    NRCELL-1:actFlexGapOffset=none
...    NRCELL:ulMimoMode=Closed loop Spatial Multiplexing (2x2)

@{srsConfig}
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
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
...    NRDRX-4:drxInactivityTimer=40ms
...    NRDRX-4:drxLongCycle=80ms
...    NRDRX-4:drxOnDurationTimer=6ms
...    NRDRX-4:drxRetransTimerDl=16slot
...    NRDRX-4:drxRetransTimerUl=16slot
...    NRCELL-1:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:csirsPower=3
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-1:srsForBeamMgmt:comb=comb4
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
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
...    NRDRX-1:drxInactivityTimer=40ms
...    NRDRX-1:drxLongCycle=160ms
...    NRDRX-1:drxOnDurationTimer=100ms
...    NRDRX-1:drxRetransTimerDl=16slot
...    NRDRX-1:drxRetransTimerUl=16slot
...    NRCELL-2:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
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

@{CB008322}
...    NRBTS:actCoverageNonCoherentUes=false
...    NRBTS:actFdmScheduling=true
...    NRDU-1:actInterNumerologyCa=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actDl256Qam=true
...    NRCELL:actPdschAtSsbSlots=false
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:srsForSubbandBm:srsUePeriodicityInput=slots160
...    NRCELL-2:srsForSubbandBm:srsUePeriodicityInput=slots40
...    NRCELL:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL:srsForSubbandBm:maxNumUeSrs=4
...    NRCELL:srsForSubbandBm:srsPowerThreshold=-1350
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRCELL-1:srsForSubbandBm:actTasSrsForCriticalBandCombo=true
...    NRCELL-1:srsForSubbandBm:cbcTasConflictPolicy=TAS SRS first
...    NRCELL-1:srsForSubbandBm:dynamicSrsRmMode=mode1

@{1116_3_Frame_Structure}
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:prachConfigurationIndex=98

@{1116_3ms_bwp}
...    NRBTS/BWP_PROFILE-8:bwpType=initial
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-8/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=7|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=7|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-87:bwpType=dedicated
...    NRBTS/BWP_PROFILE-87:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-87:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-87:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-87:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-87/PDSCH-1:pdschId=1
#...    NRBTS/BWP_PROFILE-87/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-87/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-87/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-87/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-87/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-87/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-87/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-87/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=7|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=7|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    delete: NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetCommon
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL-1:msg1FrequencyStart=14
...    NRCELL-2:msg1FrequencyStart=14
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8|cellBwpId=0
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-87|cellBwpId=1
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8|cellBwpId=0
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-87|cellBwpId=1

@{FDD_CELL11_Config}
...    NRCELL-11:drxWactUlEnabled=false
...    NRCELL-11:drxWactDlEnabled=false
...    NRDRX-2:drxInactivityTimer=40ms
...    NRDRX-2:drxLongCycle=80ms
...    NRDRX-2:drxOnDurationTimer=6ms
...    NRDRX-2:drxRetransTimerDl=16slot
...    NRDRX-2:drxRetransTimerUl=16slot
...    NRCELL-11:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRCELL-11:actUlSrsBm=false
...    NRCELL-11:actDlSrsBm=false
...    NRCELL-11:actDlSrsSubbandBm=false
...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-11:nrCellType=2DL2UL
...    NRCELL-11:prachConfigurationIndex=39
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-11:timingAdvanceOffset=n25600

@{FDD_CELL_bwp}
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
...    delete: NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetDedicated
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
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
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS-1/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS-1/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:lcrId=11
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl

@{PARAMS_FOR_NRHOIF}
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a5MeasEnabled=rsrp
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=628320
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-2:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=30
...    NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=32
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a5MeasEnabled=rsrp
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf40
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

${CA_support_list}
...    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd

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
${rdfakedrx}    0x5901EA
${rdNumberOfUeCsirsSymbol}    0x580265
${rdCsiRsReconfigCellToUE}    0x590179
#Dynamic pool related RD
${rdSBSrsHighLoadSample}    0x590232
${rdSBSrsLowLoadSample}    0x590233
${rdSBSrsLoadProh}    0x590234
${rdSBSrsHighLoadThresh}    0x590235
${rdSBSrsLoadMeaTimer}    0x590236

@{PARAMS_IN_SWCONFIG}
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
...    ${rdfakedrx}=1
...    ${rdNumberOfUeCsirsSymbol}=2
...    ${rdCsiRsReconfigCellToUE}=1
#rdMaxSrsResPerSym1208 : frameStructureType 1028 max srs resource, it impact srs allocation,rule is attach first then deallocation
#Dynamic pool related RD
...    ${rdSBSrsHighLoadSample}=1
...    ${rdSBSrsLowLoadSample}=1
...    ${rdSBSrsLoadProh}=1
...    ${rdSBSrsHighLoadThresh}=10
...    ${rdSBSrsLoadMeaTimer}=15
#CB009496 flag
...    0x600013=1     #9496 BOAM_RAT_ADAPT
...    0x19040F=1     #9496 BOAM_FRONTHAUL
...    0x88004b=0     #L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496;3 for SKTMVP
...    0x580789=1     #rdEnableNiddFor8322


${ERadParam_EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1

#SA UE1:
#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n2
#n71_n78(2A): t1r4 maxNumberSRS-Ports-PerResource=n1
${ue_nr_cap_SA_UE1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E
...    439F51CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FFF00000
...    7FFC000007400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04610D04
...    083C4220032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88E3C831E8
...    19F604F8073E618F28581C0E1E0BD5555554F55555550E8000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082C0AC7C0200
...    0C0D8184C0309800030B02B170080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000
...    202C0AC3C1B000C0D800242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680061340E2300000E0B
...    02B1F130003098060080C0D8003C2C0AC5C4C000C010181B0008058158F89A0018020300C0606C0022160561E26800711800009058158F80400181B0309A061340026161
...    7009006E003404C808D01347500080848521468DB1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891216C73E1C4891226C73E1C28913639
...    F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14489B1CF8712142E4006C73E1C68912244D8E7C38912244D8E7C38D0A24489B1CF870A1720
...    03639F0E344890A16C73E1800E8A0C6318C6318C6318C6318C6318F4230003C00281C1401C0C02500700060240040603E09002000000010008000000200000C010000020
...    0800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C033953
...    5953582958195833582B594B7833780B581B58095811583B40D040000259490100001965260400006594941000039652404000125949010000596524040001A594901000
...    079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AA2E955552A8BA55154162A82C55068AA531549A2A80C55028AA4D55
...    41E28780178095028140A05028140A05028140A05028140A0502814004C2020040180801006201002004040080101002004402018028080100202004008C04030050100C
...    014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A020040084040300501002004202018028080600A10100C0
...    18040300608080600C02018028404030050100C014402018028080600C020180284040300601002004402004008080100202018028C04008010100200404030050100C01
...    4402004008080600C02018030C04008010100C01404030060100C014202004008080600C30100C01404030060100200404008011AA1F000102030406070A0B0C0D101112
...    131418191B1C1D1F2125262728292A2D2F414182D0

#SA UE2:
#BAND78: t2r2 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE2}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C6247
...    1E439F51CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD80
...    00007F60000007400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04
...    610D04083C4220032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88
...    E3C831E819F604F8073E618F28581C0E1E0BD5555554F55555550E8000038028B0F13400389A0000002C0AC5C4C000E26000713000000858158B88C00184C030980002
...    0B02B1F008003036061300C260000C2C0AC5C02000C010181B0002058158F8040018060303606134000A161758B80400181B0309800060B02B0F00800309800070B02B
...    0F00800300400080B02B0F06C00303600090B02B0F00800300C000A0B02B0F018003036000B0B02B1700800300C0606C0018160561E0D800713000006858158B89A001
...    C4D000E2300000E0B02B1F130003098060080C0D8003C2C0AC5C4C000C010181B0008058158F89A0018020300C0606C0022160561E26800711800009058158F8040018
...    1B0309A0613400261617009006E003404C808D013475000808185214A95B1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891226C73E1C
...    4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14489B1CF871254A95B1CF871A2448913639F0E2448913639F0E
...    344891226C73E1C2952B639F0E344891226C73E180E8A0C6318C6318C6318C6318C6318FC4015508C000F000E070500703009401C0018090010180F824008000000040
...    02000000080000300400000802000008010000060080000400400002802001004010040000300200001C01000800000020000200100001200800003004000050020000
...    2C01000812048020000300CE54D654D60A560A560CD60AD652DE0CDE02D606D6025604560ED0341000009652504000065949810000196525040000E594901000049652
...    504000165949410000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E9555505AAA0B
...    5541A2A94C55268AA031540A2A93555078A1E005E02540A05028140A05028140A05028140A05028140A050013080801002020040088040080101002004040080110080
...    600A02004008080100230100C014040300501002004040080110080800A02020028080B01630100C01804030050100C018040080110080600A02018028080100210100
...    C014040080108080600A02018028404030060100C018202018030080600A10100C014040300510080600A02018030080600A10100C0180400801100801002020040080
...    80600A30100200404008010100C014040300510080100202018030080600C30100200404030050100C018040300508080400602018030C04030050100C018040080101
...    0020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

${ue_nr_full_cap_n1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C6247
...    1E439F51CF9863CA1607038782FFFFFE003FFE2F8003A00000E0541B11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD80
...    00007F60000007400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A8360DEB04
...    610D04083C4220032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381546C4CD608C21A00000404400616C932A221CF88
...    E3C831E819F604F8073E618F28581C0E1E0BD5555554F55555550E8000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082
...    C0AC7C02000C0D8184C0309800030B02B170080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3
...    C02000C01000202C0AC3C1B000C0D800242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680071
...    3400388C0000382C0AC7C4C000C260180203036000F0B02B171300030040606C0020160563E2680060080C030181B0008858158789A001C46000024160563E01000606
...    C0C268184D00098585C02401B800D0132023404D1D4002020A14851226C73E1C4891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8712
...    24489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C48D1B30B639F0E344891226C73E1C4891226C73E1C
...    68912244D8E7C3851B30B639F0E344891226C73E183A28318C6318C6318C6318C6318C63F555554230003C00381C1401C0C02500700060240040603E09002000000010
...    008000000200000C0100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C01000014008000
...    0B004002048120080000C0339535953582959535833582B594B7833780B581B58095811583B40D04000025949410000196526040000659490100003965240400012594
...    9010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE954552A8BA55154162A95
...    455068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814004C20200400808010022010020040400801010020044020
...    18028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A020040084040
...    300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C02018028404030060100200440200402008010080
...    2018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202010018080600C30100C0140403006010020040
...    4008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

*** Test Cases ***
CB008322-ET-G028_Verify_partial_WB_Pool_Mark_Add_to_SB_Pool_When_SB_High_Load_And_WB_Pool_Unmark_When_SB_Low_Load_When_dynamicSrsRmMode_Equal_To_1
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    This case will verify that gNB will enable dynamic SRS resource management based on number of UEs within the cell that require
    ...    SRS resources.
    ...    The procedure is similar as CB008322-B#3. UE simulator is needed to trigger SRS load.
    ...    should work as expected.
    ...    This case will verify WB TAS SRS handling for TDD+FDD DL and UL CA (CB009169) critical band
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_20920, fully covered
    ...    User Scenario CB008322-G#15: SRS resource pool adjustment.
    ...    5G_RAN_USR_RRM_21927, fully covered
    ...    User Scenario CB008322-G#8: Critical band CA enhancement
    ...    [Configuration]:
    ...    CELL1 Frame structure 1116_3ms, srsForBeamMgmt.srsUePeriodicity = 40slots, srsForBeamMgmt.minSrsUePeriodicity = 160slots,PCI 51
    ...    CELL1 srsForSubbandBm.dynamicSrsRmMode=mode1
    ...    2.Test Case Steps:
    ...       Step a. SA UE1 attach to CELL1
    ...       Step b. after 15s, UE2 attach
    ...       Step c. release all of the UEs and wait for 15s to wideband resourece unmarked
    ...       Step a. SA UE1 attach to CELL1, start traffic
    ...    3. Expected Results:
    ...         Step a: UE1 is configured with 1port subband tas srs and 1 port codebook srs resource.
    ...         Step b: UE2 is configured with 2port subband tas srs used the resource marked from WB resource pool
    ...         Step c: UE released successfully
    ...         Step d: UE1 is configured with 1port subband tas srs and 1 port codebook srs resource
    ...         Step a: WB TAS SRS allocated with 2port wideband tas and 1 port codebook srs resource
    [Tags]    QC_47150    G028    G009
    SA UE attach    ue_id=1
    sleep    20s     #wait for the SBSrsLoadMeaTimer timeout to high load status
    SA UE attach    ue_id=2
    Release ues    ue_type=all
    sleep    20s     #wait for the SBSrsLoadMeaTimer timeout to recover from high load status
    SA UE1 reattach
    Check WireShark Log    ${CURDIR}${/}A2A_CB008322_G028${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_2T1F    ue_count=10

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
    Execute Cmd On Pc    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc    mkdir /home/ute/bsr_package/
    Execute Cmd On Pc    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git /home/ute/bsr_package/
    update_software    sw_package=/home/ute/bsr_package/BSR_FILE/${bsr_name}    timeout=60

Modify Cfg
    Update Cfg Param    set_cell id=1 gnb=2 pci=17:0
    Update Cfg Param    set_cell id=2 gnb=2 pci=17:1
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE2}

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${sleep_time}=15s
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    Initial Context Setup Successful
    sleep    ${sleep_time}

SA UE Send And Verify Throughput
    [Arguments]    ${ue_id}=1    ${trf_count}=3    ${qfi}=1    ${sleep_time}=10s    ${Tput_dl}=140
    Send Traffic SA    ue_id=${ue_id}    trf_count=${trf_count}
    Verify Throuput SA    ue_id=${ue_id}    qfi=${qfi}    sleep_time=${sleep_time}    Tput_dl=${Tput_dl}

Send Traffic SA
    [Arguments]    ${ue_id}=1    ${trf_count}=3
    FOR    ${trf_id}    IN RANGE    1    ${trf_count}+1
        Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=${trf_id}    pass_regexp=Started Downlink Internal traffic
    END
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink Internal traffic

Verify Throuput SA
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${sleep_time}=10s    ${Tput_dl}=400
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${Tput_dl}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${Tput_dl}

SA UE1 reattach
    SA UE attach    ue_id=1
    SA UE Send And Verify Throughput    ue_id=1    trf_count=1
