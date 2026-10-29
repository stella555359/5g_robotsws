*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN1ET    owner-jun.3.ye    release-5G24R2     CB008322
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}
...    @{1208_Frame_Structure}
...    @{1208_bwp_80M_GNB1}
...    @{intergNB_IntraFreq_HO}

@{PARAMS_IN_SCF_GNB2}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}
...    @{1208_Frame_Structure}
...    @{1208_bwp_80M_GNB2}
...    @{intergNB_IntraFreq_HO_GNB2}

@{enableBeamforming}
...    NRCELL:beamSet:basicBeamSet=beamSet_6
...    NRCELL:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    delete:NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL:periodicCsiAcquisition:csirsPower
...    delete:NRCELL:periodicCsiAcquisition:maxCsirsNumber
...    NRCELL:nrCellType=8DL4UL
...    NRCELL:beamSet:lowerEdgeAngle=120
...    NRCELL:beamSet:upperEdgeAngle=60
...    NRCELLGRP:numberOfTransmittedSsBlocks=6 beams

@{CB008322}
...    NRBTS:actCarrierAggregation=false
...    NRBTS:actCoverageNonCoherentUes=false
...    NRDU-1:actInterNumerologyCa=false
...    NRCELLGRP:ssBurstSetPeriod=20
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actCDrx=false
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL:actDl256Qam=true
...    NRCELL:actPdschAtSsbSlots=false
...    NRBTS:actFdmScheduling=true
...    NRCELL:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:actCsirsMultiplexing=false
...    NRCELL:actDlSrsSubbandBm=true
...    NRCELL:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL:srsForSubbandBm:maxNumUeSrs=4
...    NRCELL:srsForSubbandBm:srsPowerThreshold=-1350
...    NRCELL:srsForSubbandBm:srsUePeriodicityInput=slots20
...    NRCELL:wbSbSrsSwitch:channelStabilityHysteresis=100
...    NRCELL:wbSbSrsSwitch:channelStabilityThreshold=30
...    NRCELL:wbSbSrsSwitch:enableSbSrsVolatilityCheck=false
...    NRCELL:wbSbSrsSwitch:maxWbSbSwitch=10
...    NRCELL:wbSbSrsSwitch:numWbSrsConfigSample=10
...    NRCELL:wbSbSrsSwitch:numWbSrsReleaseSample=10
...    NRCELL:wbSbSrsSwitch:prbRatioHysteresis=1
...    NRCELL:wbSbSrsSwitch:prbRatioThreshold=2
...    NRCELL:wbSbSrsSwitch:prbSampleHighLowPercentage=60
...    NRCELL:wbSbSrsSwitch:rankHysteresis=4
...    NRCELL:wbSbSrsSwitch:rankThreshold=1
...    NRCELL:wbSbSrsSwitch:rlqBadPercentage=50
...    NRCELL:wbSbSrsSwitch:rlqGoodPercentage=20
...    NRCELL:wbSbSrsSwitch:seHysteresis=100
...    NRCELL:wbSbSrsSwitch:seThreshold=1
...    NRCELL:wbSbSrsSwitch:sortingMetric=DL Spectral Efficiency
...    NRCELL:wbSbSrsSwitch:wbSrsConfigProhibitTimer=100
...    NRCELL:wbSbSrsSwitch:wbSrsPowerHysteresis=100
...    NRCELL:wbSbSrsSwitch:wbSrsPowerThreshold=-1160
...    NRCELL:wbSbSrsSwitch:wbSrsReleaseProhibitTimer=1000

@{srsConfig}
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRCELL:actUlSrsBm=true
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
...    NRCELL:actDlSrsBm=true
...    NRCELL:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL:srsForBeamMgmt:cSRS=51
...    NRCELL:srsForBeamMgmt:bSRS=0
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL:srsForBeamMgmt:comb=comb2

@{1208_Frame_Structure}
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL:prachConfigurationIndex=98
...    delete: NRCELL:tddFrameStructure:lteToNrFrameShift
...    NRCELL:pdcchAutoConfig:cellCoverageLevel=normal
...    NRCELL:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL:pdcchAutoConfig:startCRBOfCoreset0=12
...    NRCELL:pdcchAutoConfig:pucchSize=46
...    NRCELL:chBw=80MHz
...    NRBTS:actTdraFallback=false
...    NRCELL:actInfTddFrameMuting=false
...    NRBTS:actMultipleDedicatedBWPs=false
...    NRCELL:actPowerSavingBWP=false
...    NRCELL:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL:type0SearchSpaceConfigurationIndex=5
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=3
...    NRBTS:cipherPrefL:nea2_128=6
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=3
...    NRBTS:integrityProtPrefL:nia2_128=6
...    NRBTS:integrityProtPrefL:nia3_128=9

@{1208_bwp_80M_GNB1}
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
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
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
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
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
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
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
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
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
...    NRCELL:msg1FrequencyStart=14
...    NRCELL:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5|cellBwpId=0
...    NRCELL:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-55|cellBwpId=1

@{1208_bwp_80M_GNB2}
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
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
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
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
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
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
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
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
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
...    NRCELL:msg1FrequencyStart=14
...    NRCELL:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-5|cellBwpId=0
...    NRCELL:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-55|cellBwpId=1

@{intergNB_IntraFreq_HO}


...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnUeProcGuard=6000
...    NRBTS:timerXnDataFwdGuard=250
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRCELL:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=2
...    NRBTS/NRADJNRCELL-1:nrarfcn=636666
...    NRBTS/NRADJNRCELL-1:physCellId=52
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL/NRREL-1:gNbId=2
...    NRCELL/NRREL-1:gNbIdLength=22
...    NRCELL/NRREL-1:lcrId=2
...    NRCELL/NRREL-1:gnbPlmn:mcc=311
...    NRCELL/NRREL-1:gnbPlmn:mnc=489
...    NRCELL/NRREL-1:gnbPlmn:mncLength=3

@{intergNB_IntraFreq_HO_GNB2}


...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnUeProcGuard=6000
...    NRBTS:timerXnDataFwdGuard=250
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRCELL:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=636666
...    NRBTS/NRADJNRCELL-1:physCellId=51
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL/NRREL-1:gNbId=1
...    NRCELL/NRREL-1:gNbIdLength=22
...    NRCELL/NRREL-1:lcrId=1
...    NRCELL/NRREL-1:gnbPlmn:mcc=311
...    NRCELL/NRREL-1:gnbPlmn:mnc=489
...    NRCELL/NRREL-1:gnbPlmn:mncLength=3

#${rdMinSrsUePeriodicity}    0x5901E6
${rdMaxSrsResPerSpecialSym1208}    0x5901EC
${rdMaxSrsResPerSpecialSym1070}    0x5901ED
${rdMaxSrsResPerSpecialSym1116}    0x5901EE
${rdMaxSrsResPerSym1208}    0x5900FD
${rdMaxSrsResPerSym1070}    0x590127
${rdMaxSrsResPerSym1116}    0x590128
${rdSubbandBfMethod}    0x5901BD    #MMSE 0
${rdSubBandSectorNumber}    0x5901DC
${rdSrsAllocMethod}    0x5901B6     #subband first 0
${rdSrsCodebookAndTas}    0x590103
${rdPriorSrsForDlBm}    0x590104
${rdEnableSrsSwitchScheduler}    0x5805ae
${rdNumSrsCheck}    0x5805b5
#${rdWbSrsSeProh}    0x580766
#${rdWbSrsRankProh}    0x580767
#${rdWbSrsQualProh}    0x580768
#${rdWbSrsCorrProh}    0x580769
#${rdWbSrsRankTresh}    0x580763
#${rdWbSrsSeTresh}    0x580762
#${rdWbSrsPrbTresh}    0x58076c

@{PARAMS_IN_SWCONFIG}
...    ${rdSrsCodebookAndTas}=2
...    ${rdPriorSrsForDlBm}=1
#...    ${rdMinSrsUePeriodicity}=20
...    ${rdMaxSrsResPerSpecialSym1208}=3
...    ${rdSubBandSectorNumber}=3
...    ${rdSrsAllocMethod}=0
...    ${rdMaxSrsResPerSpecialSym1116}=3
...    ${rdMaxSrsResPerSpecialSym1070}=3
...    ${rdMaxSrsResPerSym1208}=5
...    ${rdMaxSrsResPerSym1116}=5
...    ${rdMaxSrsResPerSym1070}=5
...    ${rdSubbandBfMethod}=0
...    ${rdEnableSrsSwitchScheduler}=1
...    ${rdNumSrsCheck}=100
#...    ${rdWbSrsSeProh}=100
#...    ${rdWbSrsRankProh}=4
#...    ${rdWbSrsQualProh}=100
#...    ${rdWbSrsCorrProh}=100
#...    ${rdWbSrsRankTresh}=1
#...    ${rdWbSrsSeTresh}=1
#...    ${rdWbSrsPrbTresh}=1
#CB009496 flag
...    0x600013=1     #9496 BOAM_RAT_ADAPT
...    0x19040F=1     #9496 BOAM_FRONTHAUL
...    0x88004b=0     #L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496;  3 for SKTMVP
...    0x580789=1     #rdEnableNiddFor8322

@{PARAMS_IN_SWCONFIG_GNB2}
...    ${rdSrsCodebookAndTas}=2
...    ${rdPriorSrsForDlBm}=1
#...    ${rdMinSrsUePeriodicity}=20
...    ${rdMaxSrsResPerSpecialSym1208}=3
...    ${rdSubBandSectorNumber}=3
...    ${rdSrsAllocMethod}=0
...    ${rdMaxSrsResPerSpecialSym1116}=3
...    ${rdMaxSrsResPerSpecialSym1070}=3
...    ${rdMaxSrsResPerSym1208}=5
...    ${rdMaxSrsResPerSym1116}=5
...    ${rdMaxSrsResPerSym1070}=5
...    ${rdSubbandBfMethod}=0
...    ${rdEnableSrsSwitchScheduler}=1
...    ${rdNumSrsCheck}=100
#...    ${rdWbSrsSeProh}=100
#...    ${rdWbSrsRankProh}=4
#...    ${rdWbSrsQualProh}=100
#...    ${rdWbSrsCorrProh}=100
#...    ${rdWbSrsRankTresh}=1
#...    ${rdWbSrsSeTresh}=1
#...    ${rdWbSrsPrbTresh}=1
#CB009496 flag
...    0x600013=1     #9496 BOAM_RAT_ADAPT
...    0x19040F=1     #9496 BOAM_FRONTHAUL
...    0x88004b=0     #L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496;  3 for SKTMVP
...    0x580789=1     #rdEnableNiddFor8322

@{srs_setup_for_ue_reconfig_WB}
...    criticalExtensions rrcReconfiguration
...    criticalExtensions rrcReconfigurationComplete

@{ue1_HO_Target_cell2}
...    criticalExtensions measurementReport
...    criticalExtensions rrcReconfiguration
...    eventId eventA3
...    physCellId 52
...    criticalExtensions rrcReconfigurationComplete
...    Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.2 performed
...    PATH SWITCH REQUEST ACK with RAN UE NGAP ID

@{ue1_HO_fallback_cell1}
...    criticalExtensions measurementReport
...    criticalExtensions rrcReconfiguration
...    eventId eventA3
...    physCellId 51
...    criticalExtensions rrcReconfigurationComplete
...    Inter-eNB handover from EXT_ENB-3.2 to EXT_ENB-2.1 performed
...    PATH SWITCH REQUEST ACK with RAN UE NGAP ID

@{NSA_ue_attach}
...    SgNBAdditionRequest
...    SgNBAdditionRequestAcknowledge
...    rrcConnectionReconfiguration
...    RadioBearerConfig
...    Successfully reconfigured dual connectivity
...    rrcConnectionReconfigurationComplete
...    SgNBReconfigurationComplete
...    SNStatusTransfer

@{NSA_srs_reconfig_for_SB_to_WB_CELL2}
...    value SgNBModificationRequired
...    rrcConnectionReconfiguration
...    rrcReconfiguration
...    rrcConnectionReconfigurationComplete
...    SgNBModificationConfirm

${ERadParam_EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1

#SA UE1:
#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t4r4 maxNumberSRS-Ports-PerResource=n4
${ue_nr_cap_SA_UE1}    SEPARATOR=
...    E1A09000575F7A13160003C4A0002C1001018093170019C3D0B004D9061CF9863CA160704C060188E00D51B137582308682041D20F003EB65C558D0E7C471E819F604F8
...    CC8E3C873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0006480007001B280002800003A8D85181AC1184341020E907801F5B2E2AC6873E238F40CFB027C6647
...    1E439F40CFB027D473E618F28581C0E1E2E000BE0038002F8003200003800C3070A0200000718785000184D00008718785000182800010718705007134000018718389A
...    10000038C3C4D000C26800085C00C028809A3200045034089B1CF870A246D8E7C3851226C73E1C29D1B639F0E046D8E7C3851A36C73E181E836001F0014080A00E06012
...    803800301F09C01000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000C00800007004000038020010000000
...    40000400200100C0300400004802000028010008080200200101C0700400005C928010300C2E494000185C928030300C0300C2E49401018060185C928060300C0300C03
...    00C030B9250080601806018061724A01C0C0300C0300C0300C030B825000061724A0000C4E49400818062724A0080C0300C4E094000189C928070300C0300C0300C0300
...    C4E4940181806018062724A0000C0E49403818060180601806018060724A00C0C0300C030382500006060080000D037953595359535819581B5833594B5933580B58095
...    811591B5BA4654D0341000009652504000065949010000296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010
...    000A96524040002E5949410040C0325949410000C965250314AAAA9545D2A8BA55154162A81C55068AA531549A2A80C55028AA47555DA81A017C09E8140A05028140A05
...    028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A050000600101C00C20200C018080300610100600C04008030808030060200C018
...    D50300008101820303A1000

#NSA UE12
#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t2r2 maxNumberSRS-Ports-PerResource=n1
${ue12_MRDC_cap}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882000
...    0002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001
...    C041809A26002E41E24E9513639F0E24E8513639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF8300A20
...    00080404008020100C01840001008080100402018030C0002010100C01804030060100C0184000100808010040200401040002010100C018
...    20001008080600C0

${ue_nr_full_cap}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2873E238F1800000000000000000000
...    00004FFF800003FFE00000260001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040
...    0000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26
...    800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E140
...    00711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602087A05D83E14489B1CF870A24
...    4D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
...    8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C02500700060
...    240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008
...    000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D60256
...    04560ED0341000009652504000065949010000296524040000E594901000049652404000165949010000696524040001E594901000089652
...    404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55154AA2E95455058AA0B1541A2A94C55268AA031540A
...    2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C201002004040300
...    60100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C
...    30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
CB008322-ET-B012_Verify_DU_UP_triggered_Subband_tas_SRS_and_SB_CB_reconfig_to_Wideband_TAS_SRS_and_reused_WB_CB
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    1.This case will verify the wide band TAS SRS configuration algorithm of gNB. gNB will select UEs with channel condition better than some
    ...    threshold, buffer larger than some threshold as candidate subband BF UEs and wide band TAS SRS will be configured to these UEs if there 
    ...    is available SRS resource.
    ...    2.User Scenario CB008322-B#2: Wide band TAS SRS configuration algorithm - L2 UE selection
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_21381,5G_RAN_USR_RRM_20690
    ...    [Configuration]:
    ...    Frame structure 1208, srsForBeamMgmt.srsUePeriodicity = 40slots, srsForBeamMgmt.minSrsUePeriodicity = 20slots
    ...    / is availableSubbandSrsBmResourcesTable, | is availableWidebandSrsBmResourcesTable
    ...    GNB1 resource pool of PCI51:
    ...    |Comb  |cyclicShift| symbol 0 | symbol 1 | symbol 2 | symbol 3 | symbol 4 | symbol 5 | symbol 6 | symbol 7 |
    ...    |     Slot id      |     3    |     8    |    13    |    18    |    23    |    28    |    33    /    38    /
    ...    |  0   |     1     |          |          |    UE1   |    UE1   |     UE1  |    UE1   |          /          /
    ...    |  0   |     5     |          |          |          |          |          |          |          /          /
    ...    |  0   |     3     |          |          |          |          |          |          |          /          /
    ...    |  0   |     7     |          |          |          |          |          /          /          /          /
    ...    |  1   |     1     |  UE1     /    UE1   /    UE1   /          /          /          /  UE1(CB) /   UE1    /
    ...    |  1   |     5     |          /          /          /          /          /          /          /          /
    ...    |  1   |     3     |          /          /          /          /          /          /          /          /
    ...    |  1   |     7     |          /          /          /          /          /          /          /          /
    ...    GNB2 resource pool of PCI52(UE contain SA and NSA):
    ...    |Comb  |cyclicShift| symbol 0 | symbol 1 | symbol 2 | symbol 3 | symbol 4 | symbol 5 | symbol 6 | symbol 7 |
    ...    |     Slot id      |     3    |     8    |    13    |    18    |    23    /    28    /    33    /    38    /
    ...    |  0   |     0     |  UE(CB)  /    UE    /    UE    /    UE    /    UE    /          /          /          /
    ...    |  0   |     4     |          /          /          /          /          /          /          /          /
    ...    |  0   |     2     |          /          /          /          /          /          /          /          /
    ...    |  0   |     6     |          /          /          /          /          /          /          /          /
    ...    |  1   |     0     |          |          /          /          /  NSAUE   |  NSAUE   |  NSAUE   |  NSAUE   /
    ...    |  1   |     4     |          |          |          |          |          |          |          |          |
    ...    |  1   |     2     |          |          |          |          |          |          |          |          |
    ...    |  1   |     6     |          |          |          |          |          |          |          |          |
    ...    2.Test Case Steps:
    ...         Step A.SA UE attach and trigger SRS reconifg from SB to WB
    ...         Step B.Trigger UE1 reconfig to SB SRS by Stop Traffic
    ...         Step C.Trigger UE1 inter gNB HO to GNB2
    ...         Step D.Trigger UE1 reconfig from SB to WB after HO on CELL2
    ...         Step E.Trigger UE1 inter gNB HO back to GNB1
    ...         Step F.NSA UE12 attach and trigger ENDC with GNB2
    ...         Step G.Trigger NSA ue12 SRS reconfig from SB to WB
    ...         Step H.release UE
    ...         Step J.wireshark logs check
    ...    3. Expected Results:
    ...         Step A: 
    ...          1) UE attached sucessfully, only 1 dedicate codebook srs (1 port) and 4 subband tas srs is allocated to UE1
    ...          2) In case of both DL buffer and channel status above threshold,L2PS triggered rrc reconfiguration procedure,
    ...          Cplane configured wide band SRS with periodicity indicated srsUePeriodicitySubbandBm for UE1.
    ...          3) subband codebook resource is released and wideband codebook srs reused the first wideband tas srs resource.
    ...          4) Resourcce position See Configuration in sheet "GNB1 resource pool of PCI51"
    ...         Step B: 
    ...          1) In case on of DL buffer and channel status below threshold,L2PS triggered rrc reconfiguration procedure,
    ...          cplane config 4 subband srs and 1 codebook srs to ue. the wideband tas srs resource shall be released
    ...          2) Resourcce position See Configuration in sheet "GNB1 resource pool of PCI51"
    ...         Step C:
    ...          1) HO performed succesfully
    ...          2) subband psrs resource allocated successfully
    ...          3) original wideband resource set released successfully
    ...          4) Resourcce position See Configuration in sheet "GNB2 resource pool of PCI52(UE contain SA and NSA)"
    ...         Step D: ue reconfigued to wideband tas srs successfully, Resourcce position See Configuration in 
    ...         sheet "GNB2 resource pool of PCI52(UE contain SA and NSA)"
    ...         Step E: 
    ...          1) HO performed succesfully
    ...          2) subband psrs resource allocated successfully
    ...          3) original wideband resource set released successfully
    ...          4) Resourcce position See Configuration in sheet "GNB1 resource pool of PCI51"
    ...         Step F:
    ...          1) NSA UE12 attached sucessfully,only 1 dedicate codebook srs (1 port) and 4 subband tas srs is allocated to UE12
    ...          2) Resourcce position See Configuration in sheet "GNB2 resource pool of PCI52(UE contain SA and NSA)"
    ...         Step G:
    ...          1) In case of both DL buffer and channel status above threshold,L2PS triggered rrc reconfiguration procedure,
    ...          Cplane configured wide band SRS with periodicity indicated srsUePeriodicitySubbandBm for UE12
    ...          2) subband codebook resource is released and wideband codebook srs reused the first wideband tas srs resource.
    ...          3) Resourcce position See Configuration in sheet "GNB2 resource pool of PCI52(UE contain SA and NSA)"
    ...         Step H.UE is release successfully
    ...         Step J: wireshark logs check passed
    [Tags]    QC_320631    B012    B020    B032
    SA UE attach and trigger SRS reconifg from SB to WB
    Trigger UE reconfig to SB SRS by Stop Traffic    ue_id=1
    UE Trigger inter gNB HO to GNB2    ue_id=1
    Trigger UE1 reconfig from SB to WB after HO on CELL2    ue_id=1
    UE Trigger inter gNB HO back to GNB1    ue_id=1
    NSA UE12 attach and trigger ENDC with GNB2    ue_id=12    cell_id=2
    Trigger NSA ue12 SRS reconfig from SB to WB    ue_id=12
    Stop Traffic for all UE and release
    Check WireShark Log    ${CURDIR}${/}A2A_B012${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_B012${/}a2a_gnb2.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Install eNB Package via WEBEM
    [Arguments]    ${bsr_path}=/home/ute/bsr_package
    ...    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
    Execute Cmd On Pc    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc    mkdir ${bsr_path}
    Execute Cmd On Pc    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git ${bsr_path}
    update_software    sw_package=/home/ute/bsr_package/BSR_FILE/${bsr_name}    timeout=20

Install eNB Package via WEBEM In GNB2
    [Arguments]    ${bsr_path}=/home/ute/bsr_package    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
    set suite variable    ${GNB2_PC_IP}    ${tl.test_pcs[1].default_ssh_connection_details.addr}
    Execute Cmd On Pc Gnb2    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc Gnb2    mkdir ${bsr_path}
    Execute Cmd On Pc Gnb2    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git ${bsr_path}
    ${bts_port}    ${use_ssl}    Define Admin Port
    Setup Admin    bts_port=${bts_port}    use_ssl=${use_ssl}    admin_api_log_dir=${SAVE LOG DIRECTORY}/gnb2/admin_logs
    ...    timeout=120    remote_host=${GNB2_PC_IP}    alias=${GNB2_ALIAS}
    update_software    sw_package=/home/ute/bsr_package/BSR_FILE/${bsr_name}    alias=${GNB2_ALIAS}    timeout=20

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Install eNB Package via WEBEM In GNB2
    Setup 2Airphone Env    tdd_sansa_cmwv/FS/2cells_gnb1_1T_gnb2_1T_AQQL    ue_count=5

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    ue_param id=12 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue12_MRDC_cap}

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${enb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${enb_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful

Run Traffic trigger SRS reconifg from SB to WB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=criticalExtensions rrcReconfigurationComplete
    Verify Throughput    ue_id=${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=140    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

UE Trigger inter gNB HO to GNB2
    [Arguments]    ${ue_id}=1    ${source_cell_id}=51    ${target_cell_id}=52
    ${a3_measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${target_cell_id} nrsrp_nr=50 nrsrq_nr=50
    Execute Egate Command    ${cmd_HO}    pass_regexp=${ue1_HO_Target_cell2}

Trigger UE1 reconfig from SB to WB after HO on CELL2
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=criticalExtensions rrcReconfigurationComplete
    Verify Throughput    ue_id=${ue_id}

UE Trigger inter gNB HO back to GNB1
    [Arguments]    ${ue_id}=1    ${source_cell_id}=52    ${target_cell_id}=51
    ${a3_measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${target_cell_id} nrsrp_nr=50 nrsrq_nr=50
    Execute Egate Command    ${cmd_HO}    pass_regexp=${ue1_HO_fallback_cell1}

Trigger UE reconfig to SB SRS by Stop Traffic
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=criticalExtensions rrcReconfigurationComplete

NSA UE12 attach and trigger ENDC with GNB2
    [Arguments]    ${ue_id}=11    ${cell_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=3 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=${NSA_ue_attach}

Trigger NSA ue12 SRS reconfig from SB to WB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=1    pass_regexp=${NSA_srs_reconfig_for_SB_to_WB_CELL2}
    Verify Throuput NSA    ue_id=${ue_id}

Verify Throuput NSA
    [Arguments]    ${ue_id}=11    ${sleep_time}=10s    ${scell_id}=8
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90

SA UE attach and trigger SRS reconifg from SB to WB
    SA UE attach    ue_id=1    cell_id=1    enb_id=2
    Run Traffic trigger SRS reconifg from SB to WB    ue_id=1

Stop Traffic SA UE and release
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached

Stop Traffic NSA UE and release
    [Arguments]    ${ue_id}=92
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

Stop Traffic for all UE and release
    Stop Traffic SA UE and release    ue_id=1
    Stop Traffic NSA UE and release    ue_id=12
