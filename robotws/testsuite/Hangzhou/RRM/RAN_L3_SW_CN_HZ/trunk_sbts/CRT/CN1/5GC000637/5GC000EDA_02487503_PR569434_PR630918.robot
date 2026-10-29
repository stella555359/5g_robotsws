*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-DevHZ5_SG2
...    owner-xianjiao.xie    release-5G19A    CRT    
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_DELETE_CELL1_WITH_NRCELLGRP-0}
...    @{PARAMS_Delete_CELL1_PART1}
...    @{PARAMS_Delete_CELL1_PART2_WITH_NRCELLGRP-0}

@{PARAMS_DELETE_CELL1_WITH_NRCELLGRP-2}
...    @{PARAMS_Delete_CELL1_PART1}
...    @{PARAMS_Delete_CELL1_PART2_WITH_NRCELLGRP-2}

@{PARAMS_Delete_CELL1_PART1}
...    NRBTS/NRDU-1:refNrCellGroup=1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-1
...    delete:NRCELL-1/NRREDRT-1
...    delete:NRCELL-1/NRREL-1
...    delete:NRCELL-2/NRREL-1

@{PARAMS_Delete_CELL1_PART2_WITH_NRCELLGRP-0}
...    delete:NRCELLGRP-0

@{PARAMS_Delete_CELL1_PART2_WITH_NRCELLGRP-2}
...    delete:NRCELLGRP-2

@{PARAMS_IN_SCF_CELL1_WITH_NRCELLGRP-2}
...    @{PARAMS_ADD_CELL1_PART1}
...    @{PARAMS_Update_CELL1_WITH_NRCELLGRP-2}

@{PARAMS_IN_SCF_CELL1_WITH_NRCELLGRP-0}
...    @{PARAMS_ADD_CELL1_PART1}
...    @{PARAMS_Recovery_CELL1_WITH_NRCELLGRP-0}


@{PARAMS_ADD_CELL1_PART1}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
...    
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    NRCELL-1:a1MeashoEnabled=none
...    NRCELL-1:a1MeashoEnabledSA=none
...    NRCELL-1:a1MeashoPrefNRLayerEnabled=none
...    NRCELL-1:a1MeashoPrefNRLayerEnabledSA=none
...    NRCELL-1:a2MeasRedirectEnabled=none
...    NRCELL-1:a2MeashoEnabled=none
...    NRCELL-1:a2MeashoEnabledSA=none
...    NRCELL-1:a3MeasEnabled=none
...    NRCELL-1:a5MeasEnabled=none
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRCELL-1:actARPBasedAC=off
...    NRCELL-1:actAdaptVoipTbs=false
...    NRCELL-1:actAdaptiveReTxResMcs=false
...    NRCELL-1:actAdaptiveSr=false
...    NRCELL-1:actAperCsi=false
...    NRCELL-1:actBeamforming=false
...    NRCELL-1:actBlankDlSymbBorderCoord=false
...    NRCELL-1:actCDrx=false
...    NRCELL-1:actCDrxVoNR=false
...    NRCELL-1:actCaAwarePsCellSelectionFr1=false
...    NRCELL-1:actCceSplit=true
...    NRCELL-1:actCellCsiRsImTddNonBf=false
...    NRCELL-1:actCellCsirsTddOnSsbBf=false
...    NRCELL-1:actCsiMeasEthFlowControl=CSIMeasBasedAllUe
...    NRCELL-1:actCsirsMultiplexing=false
...    NRCELL-1:actDataForwardingForVoNr=deactivated
...    NRCELL-1:actDl256Qam=false
...    NRCELL-1:actDlInterferenceAvoidance=false
...    NRCELL-1:actDlLaDynBlerTarget=false
...    NRCELL-1:actDlLowPAPRoptimizedPrecoding=false
...    NRCELL-1:actDlMuMimo=false
...    NRCELL-1:actDlMuMimoEnh=false
...    NRCELL-1:actDlPaWarmUp=false
...    NRCELL-1:actDlRankAdpAndSRB1McsLimDurHO=false
...    NRCELL-1:actDlRbgRandomization=disabled
...    NRCELL-1:actDlSrsBm=false
...    NRCELL-1:actDlVoNrLimMaxMcsAndLayer=false
...    NRCELL-1:actDownSampling=false
...    NRCELL-1:actDtxOptimizedScheduler=false
...    NRCELL-1:actDynUlDataSplitMode=false
...    NRCELL-1:actDynUlResAlloc=false
...    NRCELL-1:actEirpControl=false
...    NRCELL-1:actEmergencyCall=false
...    NRCELL-1:actEnhMultipleDedicatedBWPs=false
...    NRCELL-1:actEnhancedPDSCHSchSplSlot=false
...    NRCELL-1:actEnhancedVoNR=false
...    NRCELL-1:actExternalAntennaBF=false
...    NRCELL-1:actFullPwrMode=false
...    NRCELL-1:actGBRAdmissionControl=off
...    NRCELL-1:actGbrLoadRepDss=false
...    NRCELL-1:actHighSpeedCell=false
...    NRCELL-1:actIncreasedFdmUsersPerSlot=false
...    NRCELL-1:actInfTddFrameMuting=false
...    NRCELL-1:actK1Opt=disabled
#...    NRCELL-1:actK1OptForDPA=false
...    NRCELL-1:actLongPucchF1F3BfOnOranExtT6=false
...    NRCELL-1:actLongPucchPhase2=false
...    NRCELL-1:actMcsPrbReductionFdmUl=false
#...    NRCELL-1:actMprAwareUlla=false
...    NRCELL-1:actNonVoNRGbrService=false
...    NRCELL-1:actNrDualConnectivity=disabled
...    NRCELL-1:actNrRim=disabled
...    NRCELL-1:actORuBeamforming=false
...    NRCELL-1:actORuFlexibleBeamGrpMapping=false
...    NRCELL-1:actORuFlexibleBeamIdMapping=false
...    NRCELL-1:actPRBBlanking=false
...    NRCELL-1:actPciBasedCsiImRandomization=false
...    NRCELL-1:actPcsiOnF2Fdm=false
...    NRCELL-1:actPdschAtSsbSlots=false
...    NRCELL-1:actPdschRmCsirsForTracking=false
...    NRCELL-1:actPerCsiReportBundlingTddFr1=false
...    NRCELL-1:actPowerSavingBWP=false
...    NRCELL-1:actPrachMultiplexing=true
...    NRCELL-1:actPriorityAccess=false
...    NRCELL-1:actProactUlScheduling=true
...    NRCELL-1:actPucchAdditionalDmrs=false
...    NRCELL-1:actPusch12Sb10MhzFddLongPucch=false
...    NRCELL-1:actRrcReconfigAtBeamSwitch=false
...    NRCELL-1:actServiceAwareConfig=false
...    NRCELL-1:actSharedSr=false
...    NRCELL-1:actSib1ForNsaCell=false
...    NRCELL-1:actSpecificBwpSize=false
...    NRCELL-1:actSpeculativeDtx=shortPUCCHMode
...    NRCELL-1:actSuperCell=false
...    NRCELL-1:actUca=false
...    NRCELL-1:actUl256Qam=false
...    NRCELL-1:actUlCgType2=false
...    NRCELL-1:actUlClosedLoopPwrCtrl=disabled
...    NRCELL-1:actUlDftSOfdm=false
...    NRCELL-1:actUlMuMimo=false
...    NRCELL-1:actUlSrsBm=false
...    NRCELL-1:actUlTxSkip=false
...    NRCELL-1:actVoNR=false
...    NRCELL-1:actVoNrMobilityThresholds=off
...    NRCELL-1:actVoipPacketAggr=false
...    NRCELL-1:addNumOfGBRBearers=0
...    NRCELL-1:adjustPowerControlOffset=0
...    NRCELL-1:adjustPrachThresholdOffset=0
...    NRCELL-1:administrativeState=Unlocked
...    NRCELL-1:aggregationLevel=4CCEs
...    NRCELL-1:arpPrioEmergencyCall=1
...    NRCELL-1:bufferThesholdSCellDePrioritize=200
...    NRCELL-1:caBlockingLoadLevel=100
...    NRCELL-1:cbraPreamblesPerSsb=n64
...    NRCELL-1:ccLoadThreshold=50
...    NRCELL-1:cellBarred=notBarred
...    NRCELL-1:cellDepType=SA+NSA
...    NRCELL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1:cellReselectionPriority=0
...    NRCELL-1:cellReservedForOperatorUse=notReserved
...    NRCELL-1:cellReservedForOtherUse=FALSE
...    NRCELL-1:cellTechnology=TDD
...    NRCELL-1:chBw=100MHz
...    NRCELL-1:configuredEpsTac=200
...    NRCELL-1:dedicatedSib1=false
...    NRCELL-1:deliveryDelayThWithDataSplit=5
...    NRCELL-1:dlDMRSAdditionalPosition=No additional DMRS
...    NRCELL-1:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL-1:dlMuMaxNumPairedUEs=8
...    NRCELL-1:dlQam256PowerBackoffSub6=15
...    NRCELL-1:dllaBlerTarget=10
...    NRCELL-1:dllaDeltaCqiMax=30
...    NRCELL-1:dllaDeltaCqiMin=-30
...    NRCELL-1:dllaDeltaCqiStepdown=250
...    NRCELL-1:dllaIniMcs=0
...    NRCELL-1:dmrsTypeAPosition=pos2
...    NRCELL-1:drxWactDlEnabled=false
...    NRCELL-1:drxWactUlEnabled=false
...    NRCELL-1:duratScgFailures=0ms
...    NRCELL-1:eirpControlTimeAveragingWindow=6
...    NRCELL-1:eirpControlTimeAveragingWindowStepSize=100
...    NRCELL-1:emergencyCallFails=false
...    NRCELL-1:emergencyCallLimServ=false
...    NRCELL-1:enDcSyncStatus=synchronous
...    NRCELL-1:expectedCellSize=15km
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:filterCoeffSsbRsrq=fc4
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-1:gapOffset=0
...    NRCELL-1:gscnOrSsPbchArfcn=7880
...    NRCELL-1:ifhoSsbSmtcOffset=0
...    NRCELL-1:initialPreambleReceivedTargetPower=-118
...    NRCELL-1:intraFreqReselection=allowed
...    NRCELL-1:lcrId=1
...    NRCELL-1:longPucchConfigType=duActCaPucchConfig
...    NRCELL-1:lteNrDssMode=none
...    NRCELL-1:lteToNrTimeOffset=0
...    NRCELL-1:maxNumOfCaUsersNRCell=250
...    NRCELL-1:maxNumOfGBRBearersSA=10
...    NRCELL-1:maxNumOfNonGBRBearersSA=550
...    NRCELL-1:maxNumOfNrDcSnNonGBRBearers=550
...    NRCELL-1:maxNumOfNrDcSnUsers=275
...    NRCELL-1:maxNumOfRrcSA=275
...    NRCELL-1:maxNumOfSCellAlloc=250
...    NRCELL-1:maxNumOfUsersPerNRCell=275
...    NRCELL-1:maxNumOfUsersPerCell=275
...    NRCELL-1:maxNumPdschAllocationPerSlot=1
...    NRCELL-1:maxNumPuschAllocationPerSlot=1
...    NRCELL-1:maxNumberUesPowerSaving=400
...    NRCELL-1:maxNumberVoNRPowerSaving=250
...    NRCELL-1:mcsIndexForArtificialLoad=0
...    NRCELL-1:measGapSelection=favourUeThroughput
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:modPeriodCoeff=n2
...    NRCELL-1:msg1FrequencyStart=0
...    NRCELL-1:msg3DeltaPreamble=1
...    NRCELL-1:n310=n10
...    NRCELL-1:n311=n1
...    NRCELL-1:nUeCtxForCceSplitDeactivation=0
...    NRCELL-1:nbrOfBlankedPRBsHighEdgeDL=0
...    NRCELL-1:nbrOfBlankedPRBsHighEdgeUL=0
...    NRCELL-1:nbrOfBlankedPRBsLowEdgeDL=0
...    NRCELL-1:nbrOfBlankedPRBsLowEdgeUL=0
...    NRCELL-1:nbrOfSsbPerRachOccasion=one
...    NRCELL-1:nrCellType=2DL2UL
...    NRCELL-1:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-1
...    NRCELL-1:nrOfScgFailures=0
...    NRCELL-1:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
...    NRCELL-1:nrarfcn=636666
...    NRCELL-1:nrofHARQProcessesForPDSCH=10
...    NRCELL-1:numOfPagingFrames=quaterT
...    NRCELL-1:numOfRadioResReservForEmergency=0
...    NRCELL-1:numOfSubSectors=0sub-sector
...    NRCELL-1:numPagingOccsnPagingFrame=one
...    NRCELL-1:numberOfRxBeamforming=2Rx
...    NRCELL-1:openLoopScheme=Automatic
...    NRCELL-1:pMax=260
...    NRCELL-1:pMaxNROwnCell=23
...    NRCELL-1:pagingOffset=1
...    NRCELL-1:pagingTargetRate=pagingDciAggregation
...    NRCELL-1:payloadSizeProactiveDrx=64
...    NRCELL-1:payloadSizeProactiveNonDrx=16
...    NRCELL-1:pduHoSliceRelease=false
...    NRCELL-1:physCellId=50
...    NRCELL-1:powerRampingStep=dB2
...    NRCELL-1:powerRampingStepHighPriorityCfra=dB2
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-1:prachRootSequenceIndex=0
...    NRCELL-1:prachSequenceType=Unrestricted
...    NRCELL-1:preambleTransMax=n10
...    NRCELL-1:primaryPathMaxQueueingDelay=10
...    NRCELL-1:pucchDataDtxNumOfSamples=30
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot15
...    NRCELL-1:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:puschDataDtxNumOfSamples=30
...    NRCELL-1:puschMappingType=TypeB
...    NRCELL-1:qRxLevMin=-65
...    NRCELL-1:raContentionResolutionTmr=sf64
...    NRCELL-1:raResponseWindow=sl80
...    NRCELL-1:rangeExtension=1x_range
...    NRCELL-1:rateMatchedCsiImInMsg2Slot=true
...    NRCELL-1:reportAmount=r4
...    NRCELL-1:reportAmountCA=r4
...    NRCELL-1:reportAmountHoPrefNRLayer=r2
...    NRCELL-1:reportAmountHoPrefNRLayerSA=r2
...    NRCELL-1:reportAmountNrDc=r4
...    NRCELL-1:reportInterval=ms120
...    NRCELL-1:reportIntervalCA=ms1024
...    NRCELL-1:reportIntervalHoPrefNRLayer=ms1024
...    NRCELL-1:reportIntervalHoPrefNRLayerSA=ms1024
...    NRCELL-1:reportIntervalNrDc=ms1024
...    NRCELL-1:reportOnLeave=false
...    NRCELL-1:reqMinNumPuschPrb=19
...    NRCELL-1:rlResumeBackOffTmr=2000
...    NRCELL-1:rlfPsccTrigThresholdRsrp=42
...    NRCELL-1:rloConsecDtxThreshold=1
...    NRCELL-1:rloDtxRatioThreshold=1
...    NRCELL-1:rloPathLossThreshold=100
...    NRCELL-1:rloSinrThreshold=-45
...    NRCELL-1:rlpDetCsiBsiThreshold=10
...    NRCELL-1:rlpDetDlHarqThreshold=35
...    NRCELL-1:rlpRecCsiBsiThreshold=2
...    NRCELL-1:rlpRecDlHarqThreshold=5
...    NRCELL-1:rsrpThresholdSSB=11
...    NRCELL-1:sCellActivationLevel=1TTI
...    NRCELL-1:sCellActivationLevelUL=1TTI
...    NRCELL-1:sCellActivationMinDataThreshold=6000
...    NRCELL-1:sCellBadChannelQualityThUL=4
...    NRCELL-1:sCellBadChannelQualityThreshold=4
...    NRCELL-1:sCellChannelEstimationPeriod=2000
...    NRCELL-1:sCellDePrioritizeEvalPeriod=50
...    NRCELL-1:sCellDeactivationTimerGNB=ms1280
...    NRCELL-1:sCellGoodChannelQualityThreshold=8
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-1:scellBlockingLoadLevel=100
...    NRCELL-1:secondaryPathMaxQueueingDelay=10
...    NRCELL-1:siChangeIndDuration=0
...    NRCELL-1:skipSsbToMeas=false
...    NRCELL-1:slotLAUseHighBlerAckNack=true
...    NRCELL-1:slotLAUseLowBlerAckNack=true
...    NRCELL-1:srPeriodicity=slots80
...    NRCELL-1:ssPbchBlockPower=0
...    NRCELL-1:ssbScs=30 KHz
...    NRCELL-1:t300=2000ms
...    NRCELL-1:t301=2000ms
...    NRCELL-1:t310=2000ms
...    NRCELL-1:t311=30000ms
...    NRCELL-1:t319=400ms
...    NRCELL-1:targetSUOMeNBULSubframes=0Percent
...    NRCELL-1:targetTotalLoad=0
...    NRCELL-1:timeRestrictionForIntfMeas=notConfigured
...    NRCELL-1:timingAdvanceOffset=n25600
...    NRCELL-1:totalNumberOfRAPreambles=64
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-1:trsMutingInBlankedPRBsEnabled=false
...    NRCELL-1:type0CoresetConfigurationIndex=10
...    NRCELL-1:type0SearchSpaceConfigurationIndex=4
...    NRCELL-1:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-1:ueSplitPowerAdjStep=170
...    NRCELL-1:ulDMRSAdditionalPosition=No additional DMRS
...    NRCELL-1:ulLimitedMcsStepupSizeBler=0
...    NRCELL-1:ulMcsDowngradeMaxReduction=0
...    NRCELL-1:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL-1:ulProGrantTimer=1200
...    NRCELL-1:ulRank1to2Thresh=170
...    NRCELL-1:ulRank2to1Thresh=150
...    NRCELL-1:ulSchedTimeInterval=200
...    NRCELL-1:ullaBlerTarget=10
...    NRCELL-1:ullaDeltaSinrMax=30
...    NRCELL-1:ullaDeltaSinrMin=-300
...    NRCELL-1:ullaDeltaSinrStepdown=250
...    NRCELL-1:ullaIniMcs=0
...    NRCELL-1:voiceFBMode=disabled
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-1:weightRatioOfUePwrScellVsPcell=WeightRatio 1
...    NRCELL-1:zeroCorrelationZoneConfig=15
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=39
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL-1:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=36
...    NRCELL-1:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-1:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-1:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-1:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-1:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL-1:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL-1:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL-1:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL-1:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL-1:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a2MeashoSsbRsrq:a2HysteresishoSsbRsrq=1
...    NRCELL-1:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31
...    NRCELL-1:a2MeashoSsbRsrq:a2TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    NRCELL-1:beamSet:leftEdgeAngle=60
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:beamSet:rightEdgeAngle=60
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54
...    NRCELL-1:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-1:csirsBeamMgmt:csirsBmMgmtReIndex=0
...    NRCELL-1:csirsBeamMgmt:csirsBmMgmtSubband=aboveSSPBCHBlock
...    NRCELL-1:csirsForTracking:csirsTrackingPeriod=80ms
...    NRCELL-1:csirsForTracking:firstRE=0
...    NRCELL-1:csirsForTracking:rbAllocation=BWP
...    NRCELL-1:csirsForTracking:startRB=0
...    NRCELL-1:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-1:dlDataDmrsFdm:dlDataDmrsFdmThres256QamMcs=20
...    NRCELL-1:dlDataDmrsFdm:dlDataDmrsFdmThres64QamMcs=20
...    NRCELL-1:dlPtrs:actDlPtrs=false
...    NRCELL-1:dlPtrs:dlPtrsFreqDensityThresNrb0=277
...    NRCELL-1:dlPtrs:dlPtrsFreqDensityThresNrb1=24
...    NRCELL-1:dtxOptimizedScheduler:dtxDelaySinceLastScheduling=0
...    NRCELL-1:dtxOptimizedScheduler:dtxMaxRetentionDelay=50
...    NRCELL-1:dtxOptimizedScheduler:dtxPrbThreshold=100
...    NRCELL-1:fPdcchMonOccsnPo=0
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
#...    NRCELL-1:rModDNList=MRBTS-1/EQM-1/APEQM-1/RMOD-1
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-1:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-1:ulDataDmrsFdm:ulDataDmrsFdmThres256QamMcs=20
...    NRCELL-1:ulDataDmrsFdm:ulDataDmrsFdmThres64QamMcs=20
...    NRCELL-1:ulPowerControlCommon:actUlOpenLoopPwrCtrl=true
...    NRCELL-1:ulPowerControlCommon:alpha=al1
...    NRCELL-1:ulPowerControlCommon:alphaSrs=alpha1
...    NRCELL-1:ulPowerControlCommon:p0NominalPucch=-80
...    NRCELL-1:ulPowerControlCommon:p0NominalPucchF1F3=-108
...    NRCELL-1:ulPowerControlCommon:p0NominalPusch=-74
...    NRCELL-1:ulPowerControlCommon:p0NominalSrs=-80
...    NRCELL-1:ulPowerControlCommon:p0UePusch=0
...    NRCELL-1:ulPowerControlCommon:pucchF1DeltaF=-10
...    NRCELL-1:ulPowerControlCommon:pucchF3DeltaF=0
...    NRCELL-1:ulPtrs:actUlPtrs=true
...    NRCELL-1:ulPtrs:ulPtrsFreqDensityThresNrb0=277
...    NRCELL-1:ulPtrs:ulPtrsFreqDensityThresNrb1=24
...    NRCELL-1:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-1:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb1=36
...    NRCELL-1:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb2=36
...    NRCELL-1:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb3=270
...    NRCELL-1:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb4=270
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=35
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=15
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodePi2Bpsk=true
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrePi2BpskPwrBoost=false
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-1:a1MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-1:a1MeasSCellAddSsbRsrp=${EMPTY}
...    NRCELL-1:a1MeasSCellAddSsbRsrq=${EMPTY}
...    NRCELL-1:a1MeashoPrefNRLayerSsbRsrp=${EMPTY}
...    NRCELL-1:a1MeashoPrefNRLayerSsbRsrpSA=${EMPTY}
...    NRCELL-1:a1MeashoPrefNRLayerSsbRsrq=${EMPTY}
...    NRCELL-1:a1MeashoPrefNRLayerSsbRsrqSA=${EMPTY}
...    NRCELL-1:a1MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-1:a1MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-1:a2MeasSCellRelSsbRsrp=${EMPTY}
...    NRCELL-1:a2MeasSCellRelSsbRsrq=${EMPTY}
...    NRCELL-1:a2MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-1:a2MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-1:a3MeasSsbRsrq=${EMPTY}
...    NRCELL-1:a4PeriodicMeasControlNSA=${EMPTY}
...    NRCELL-1:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-1:a6MeasSCellSwapSsbRsrp=${EMPTY}
...    NRCELL-1:a6MeasSCellSwapSsbRsrq=${EMPTY}
...    NRCELL-1:cellCsiImLocationList=${EMPTY}
...    NRCELL-1:cellCsiRsLocationList=${EMPTY}
...    NRCELL-1:dlInterferenceAvoidance=${EMPTY}
...    NRCELL-1:drxProfile1=${EMPTY}
...    NRCELL-1:drxProfile2=${EMPTY}
...    NRCELL-1:drxProfileNrAnr=${EMPTY}
#...    NRCELL-1:dynPdcchTdMgt=${EMPTY}
...    NRCELL-1:eirpControl=${EMPTY}
...    NRCELL-1:eirpControlPowerReductionFactorList=${EMPTY}
...    NRCELL-1:emergencyAreaIdList=${EMPTY}
...    NRCELL-1:emergencyCallRestrictions=${EMPTY}
...    NRCELL-1:infTddFrameStructure=${EMPTY}
...    NRCELL-1:nrhoirDNList=${EMPTY}
...    NRCELL-1:pciExcludeList=${EMPTY}
...    NRCELL-1:pdcchAutoConfig=${EMPTY}
...    NRCELL-1:plmnIndvSelAssisInfoList=${EMPTY}
#...    NRCELL-1:ranAreaConfigList=${EMPTY}
...    NRCELL-1:srsForBeamMgmt=${EMPTY}
...    NRCELL-1:uacAcCatList=${EMPTY}
...    NRCELL-1:uacAcContParSetList=${EMPTY}
...    NRCELL-1:a1MeasSCellAddEnabled=${EMPTY}
...    NRCELL-1:a2MeasSCellRelEnabled=${EMPTY}
...    NRCELL-1:adaptiveSrBlockingMinimization=${EMPTY}
...    NRCELL-1:adaptiveSrLoadThresholdDown=${EMPTY}
...    NRCELL-1:adaptiveSrLoadThresholdUp=${EMPTY}
...    NRCELL-1:idleMMEnDcSteeringPercentageOfUes=${EMPTY}
...    NRCELL-1:idleMMSteeringWRREnabled=${EMPTY}
...    NRCELL-1:mMimoAntArrayMode=${EMPTY}
...    NRCELL-1:maxGBRTrafficLimit=${EMPTY}
...    NRCELL-1:n310VoNR=${EMPTY}
...    NRCELL-1:preferredVoNrSrPeriod=${EMPTY}
...    NRCELL-1:srPeriodicityMin=${EMPTY}
...    NRCELL-1:t310VoNR=${EMPTY}
...    NRCELL-1:vonrReservation=${EMPTY}
...    
...    NRCELL-1/NRREDRT-1:redirFreqNr=633364
...    NRCELL-1/NRREDRT-1:redirPrio=1
...    NRCELL-1/NRREDRT-1:redirRat=nr
...    NRCELL-1/NRREDRT-1:redirSsbScs=30 KHz
...    
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:removeNotAllowed=true
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:removeNotAllowed=true
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{PARAMS_Update_CELL1_WITH_NRCELLGRP-2}
...    NRCELLGRP-2:actLoadCsiPeriodicity=false
...    NRCELLGRP-2:actNackDtxFloodControlDetection=false
...    NRCELLGRP-2:addNumOfHoUsers=0
...    NRCELLGRP-2:addNumOfNonGBRBearersCGRPSAHo=0
...    NRCELLGRP-2:addNumOfNonGBRBearersHo=0
...    NRCELLGRP-2:addNumOfRrcCGRPSAHo=0
...    NRCELLGRP-2:beamformingGridSel=ABFG90
...    NRCELLGRP-2:loadBasedCsiPerThreshold=50Percent
...    NRCELLGRP-2:maxDlHarqTx=4
...    NRCELLGRP-2:maxHarqMsg3Tx=5
...    NRCELLGRP-2:maxNumOfNonGBRBearers=550
...    NRCELLGRP-2:maxNumOfNonGBRBearersCGRPSA=550
...    NRCELLGRP-2:maxNumOfNrDcSnNonGBRBearersCGRP=550
...    NRCELLGRP-2:maxNumOfNrDcSnUsersCGRP=275
...    NRCELLGRP-2:maxNumOfRrcCGRPSA=275
...    NRCELLGRP-2:maxNumOfUsers=550
...    NRCELLGRP-2:maxUlHarqTx=5
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELLGRP-2:pucchF2MaxCodeRate=zeroDot15
...    NRCELLGRP-2:scs=30 KHz
...    NRCELLGRP-2:spCellChangeEnabled=false
...    NRCELLGRP-2:ssBurstSetPeriod=20
...    NRCELLGRP-2:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-2:nackFloodControlF1:dataFlowResumeThrFR2=20
...    NRCELLGRP-2:nackFloodControlF1:forgettingRatioFR1=50
...    NRCELLGRP-2:nackFloodControlF1:forgettingRatioFR2=50
...    NRCELLGRP-2:nackFloodControlF1:maxNackFloodBurstSizeFR1=10
...    NRCELLGRP-2:nackFloodControlF1:maxNackFloodBurstSizeFR2=40
...    NRCELLGRP-2:nrCellList=1

...    NRBTS/NRDU-1:refNrCellGroup=2,1

@{PARAMS_Recovery_CELL1_WITH_NRCELLGRP-0}
...    NRCELLGRP-0:actLoadCsiPeriodicity=false
...    NRCELLGRP-0:actNackDtxFloodControlDetection=false
...    NRCELLGRP-0:addNumOfHoUsers=0
...    NRCELLGRP-0:addNumOfNonGBRBearersCGRPSAHo=0
...    NRCELLGRP-0:addNumOfNonGBRBearersHo=0
...    NRCELLGRP-0:addNumOfRrcCGRPSAHo=0
...    NRCELLGRP-0:beamformingGridSel=ABFG90
...    NRCELLGRP-0:loadBasedCsiPerThreshold=50Percent
...    NRCELLGRP-0:maxDlHarqTx=4
...    NRCELLGRP-0:maxHarqMsg3Tx=5
...    NRCELLGRP-0:maxNumOfNonGBRBearers=550
...    NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=550
...    NRCELLGRP-0:maxNumOfNrDcSnNonGBRBearersCGRP=550
...    NRCELLGRP-0:maxNumOfNrDcSnUsersCGRP=275
...    NRCELLGRP-0:maxNumOfRrcCGRPSA=275
...    NRCELLGRP-0:maxNumOfUsers=550
...    NRCELLGRP-0:maxUlHarqTx=5
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam
...    NRCELLGRP-0:pucchF2MaxCodeRate=zeroDot15
...    NRCELLGRP-0:scs=30 KHz
...    NRCELLGRP-0:spCellChangeEnabled=false
...    NRCELLGRP-0:ssBurstSetPeriod=20
...    NRCELLGRP-0:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-0:nackFloodControlF1:dataFlowResumeThrFR2=20
...    NRCELLGRP-0:nackFloodControlF1:forgettingRatioFR1=50
...    NRCELLGRP-0:nackFloodControlF1:forgettingRatioFR2=50
...    NRCELLGRP-0:nackFloodControlF1:maxNackFloodBurstSizeFR1=10
...    NRCELLGRP-0:nackFloodControlF1:maxNackFloodBurstSizeFR2=40
...    NRCELLGRP-0:nrCellList=1

...    NRBTS/NRDU-1:refNrCellGroup=0,1


@{PARAMS_IN_SCF_EDA002}
...    @{Common_params}
...    @{amf2}
...    @{5GC000637}
...    @{NRADJGNB_1}
...    @{XNLINK_1}

@{Common_params}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=30
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=60

@{amf2}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.102
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true


@{5GC000637}
...    MRBTS-1/NRBTS-1:actIncXn=false
...    MRBTS-1/NRBTS-1:maxNumXnSetupRetry=3
...    MRBTS-1/NRBTS-1:retryXnSetupTmr=10
...    MRBTS-1/NRBTS-1:xnLinkReestabTmr=60
#...    MRBTS-1/NRBTS-1:actConflictConfiguration=false


@{NRADJGNB_1}
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNodeBId=35
...    NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    NRADJGNB-1:gnbPlmn:mncLength=3


@{XNLINK_1}
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    XNLINK-1:cPlaneIpAddrCtrl=oamControlled


@{PARAMS_Recovery_EDA002}
...    delete:NRADJGNB-1
...    delete:XNLINK-1


@{XNLINK_2}
...    XNLINK-2:cPlaneIpAddr=10.0.1.123
...    XNLINK-2:cPlaneIpAddrCtrl=oamControlled
...    NRADJGNB-1:xnLinkRef2=2

@{fault_7307}    fault_id=7307    fault_name=Xn SCTP setup fail

${PM_Counters_Check_EDA004}
...    NRCELL-1:NRTA:${EXP_CELL_SIZE_CFG}=not_existing

${EXP_CELL_SIZE_CFG}    M55307C03001

*** Test Cases ***
5GC000EDA_02487503_Cell_is_on_air_after_update_Cell_group_id
    [Documentation]
    ...    [Purpose]: This case is to verify customer pronto 02487503 that is 
    ...    cell will be on air after update Cell's Group id with different value.
    [Tags]    QC_60618    EDA001
    SA and NSA call should be successful
    Lock NRCELL1
    delta commission parameters    ${PARAMS_DELETE_CELL1_WITH_NRCELLGRP-0}
    delta commission parameters    ${PARAMS_IN_SCF_CELL1_WITH_NRCELLGRP-2}
    wait until keyword succeeds    3 min    10 sec    cells should be on air
    SA and NSA call should be successful
    Lock NRCELL1
    delta commission parameters    ${PARAMS_DELETE_CELL1_WITH_NRCELLGRP-2}
    delta commission parameters    ${PARAMS_IN_SCF_CELL1_WITH_NRCELLGRP-0}
    wait until keyword succeeds    3 min    10 sec    cells should be on air
    SA and NSA call should be successful

5GC000EDA_PR569434_NGRANNodeConfigurationUpdate_Message_should_be_trigger_after_Lock_unlock_NG_link
    [Documentation]
    ...    [Purpose]: The purpose of this case is to verify PR569434 in feature 1979 that NGRANNodeConfigurationUpdate message
    ...     should be triggered after lock unlock amf.
    [Tags]    QC_60695    EDA002
    Start To Capture Wireshark Log
    delta commission parameters    ${PARAMS_IN_SCF_EDA002}
    wait until keyword succeeds    3 min    10 sec    NG and Xn Link Should be active
    wait until keyword succeeds    3 min    10 sec    cells should be on air
    Lock Unlock NG link2
    wait until keyword succeeds    3 min    10 sec    NG and Xn Link Should be active
    wait until keyword succeeds    3 min    10 sec    cells should be on air
    check wireshark log    ${CURDIR}${/}a2a_EDA002${/}a2a.ini    wait_string=NGRANNodeConfigurationUpdateAcknowledge
    SA and NSA call should be successful
    delta commission parameters    ${PARAMS_Recovery_EDA002}

5GC000EDA_PR630918_alarm7307_should_be_cleared_after_NRADJGNB_locked
    [Documentation]
    ...    [Purpose]: The purpose of this case is to verify PR630918 fault 7307 not cleared after NRADJGNB locked in feauture 637
    ...     should be triggered after lock unlock amf.
	...     5GC000EDA_02810270_EXP_CELL_SIZE_CFG_should_be_empty:verify 02810270 counter M55307C03001(EXP_CELL_SIZE_CFG) 
    ...     should_be_empty after cell reconfiguration and lock
	...     https://jiradc.ext.net.nokia.com/browse/FIVEGSWCN2ETEDA-254
    [Tags]    QC_253372    EDA003
    delta commission parameters    ${PARAMS_IN_SCF_EDA002}
    delta commission parameters    ${XNLINK_2}
    wait until keyword succeeds    3 min    10 sec    fm fault should be raised    ${fault_7307}
    Lock NRADJGNB1
    wait until keyword succeeds    3 min    10 sec    fm fault should be cleared    ${fault_7307}	
	SA and NSA call should be successful
	Clear Counter Files
	Reconfigure NRCELL1
	Lock NRCELL1
	Check Counters    ${PM_Counters_Check_EDA004}
	
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    #---------------------------------------------------------------------------------------------------
    # 5GCN CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    Update Cfg    set_amf_region id=1 tac_list=7627107,100,788,200,258,0 plmn=311:489	
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_upf id=1 daemon=10.0.2.1:22222 type=simulated addr=1.2.4.1/24 ngu=10.0.1.1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=off
    Update Cfg    set_backup_amf main=1 backup_amfs=2
    Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=1-6 amf=1-3
    #---------------------------------------------------------------------------------------------------
    # GNB CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    ${cmd_1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2
    ...    gnb_id=0x76C daemon=10.0.2.1:22222 xn=10.0.1.2 x2_peers=none amf=1-3 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${cmd_1}
    #sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3}
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false

  
SA and NSA call should be successful
    BuiltIn.Log    SA and NSA call should be successful...     console=${True}
    sa ue register and pdu setup    ue_id=1
    Traffic Should Be OK    ue_id=1    type=sa
    nsa ue register    ue_id=31
    Traffic Should Be OK    ue_id=31    type=nsa
    release ues    ue_type=all

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    QoS Routing Table

nsa ue register
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA
	
Lock Unlock NG link2
    BuiltIn.Log    Lock and then Unlock NG Link2...     console=${True}
    Delta Commission Parameters    SERVEDAMF-2:administrativeState=Locked
    Delta Commission Parameters    SERVEDAMF-2:administrativeState=Unlocked
	
NG and Xn Link Should be active
    BuiltIn.Log    NG and Xn link should be availabe...     console=${True}
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Active
    Object Should Exist    SERVEDAMF-2:ngLinkStatus=Active
    Object Should Exist    XNLINK-1:xnLinkStatus=available

Lock NRADJGNB1
    BuiltIn.Log    Lock NRADJGNB1...     console=${True}
    Delta Commission Parameters    NRADJGNB-1:administrativeState=Locked

Lock NRCELL1
    BuiltIn.Log    Lock NRCELL1...     console=${True}
    Delta Commission Parameters    NRCELL-1:administrativeState=Locked
	
Reconfigure NRCELL1
    BuiltIn.Log    Log Reconfigure NRCELL1...    console=${True}
	Delta Commission Parameters    NRCELL-1:ullaBlerTarget=20