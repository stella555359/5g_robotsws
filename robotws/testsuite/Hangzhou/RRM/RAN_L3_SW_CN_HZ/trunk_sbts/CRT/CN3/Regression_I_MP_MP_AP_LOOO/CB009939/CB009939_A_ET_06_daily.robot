*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    team-VRF3_8    owner-lola.ren    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot
    
*** Variables ***
${BTS_STARTUP_RETRY}    0
${SOS_REPORT_FLAG}    pass:False,fail:False
${SNAPSHOT_FLAG}     pass:False,fail:False
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:False
${GNB_CONFIG}    fddtdd_sansa_cmwv/2cell_gnb1_2F_gnb2_2F
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:xnLinkReestabTmr=900
...    @{SIM_NRADJGNB_NRADJNRCELL}
...    @{CB009939_gnb1_forced_active}
...    @{gnb1_CellActivationAlarmTimer}
@{PARAMS_IN_SCF_GNB2}
...    MRBTS-2/NRBTS-2:xnLinkReestabTmr=900
...    @{CB009939_gnb2_standby}
...    @{gnb2_CellActivationAlarmTimer}
@{CB009939_gnb1_forced_active}
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=forced active
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{CB009939_gnb1_active}
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=active
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{CB009939_gnb2_standby}
...    MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=standby
...    MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{CB009939_gnb1_standby}
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=standby
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{CB009939_gnb2_active}
...    MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=active
...    MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{GNB1_Disabled_CB009939}
...    delete:MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1
@{GNB2_Disabled_CB009939}
...    delete:MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1

@{PAPAMS_ADD_CELL11}
...    NRCELL-11:actLowGbrNumHandlingEnh=false
...    NRCELL-11:actShortBsrLimitAdaptation=true
...    NRCELL-11:configuredEpsTac=222
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11:actAsiDistMimoNr=false
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-1:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-1:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4:resourceDN=${EMPTY}

...    NRCELL-11:a2MeasRedirectEnabled=none
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:absThreshSsbRsrqConsolidation=10
...    NRCELL-11:actAdaptiveSr=false
...    NRCELL-11:actDl256Qam=true
...    NRCELL-11:actEnhancedVoNR=false
...    NRCELL-11:actGBRAdmissionControl=off
...    NRCELL-11:actVoNR=false
...    NRCELL-11:cellDepType=SA+NSA
...    NRCELL-11:cellTechnology=FDD
...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-11:dlMuLowSinrThreshold=-60
...    NRCELL-11:dlMuMaxNumPairedUEs=8
...    NRCELL-11:dlMuNeighborThreshold=80
...    NRCELL-11:dlMuPairingThreshold=5
...    NRCELL-11:dlQam256PowerBackoffAbove6=40
...    NRCELL-11:dlQam256PowerBackoffSub6=30
...    NRCELL-11:dllaIniMcs=13
...    NRCELL-11:drxWactDlEnabled=false
...    NRCELL-11:drxWactUlEnabled=false
...    NRCELL-11:duratScgFailures=0ms
...    NRCELL-11:emergencyFBMode=redirection
...    NRCELL-11:enDcSyncStatus=synchronous
...    NRCELL-11:expectedCellSize=5km
...    NRCELL-11:freqBandIndicatorNR=71
...    NRCELL-11:gscnOrSsPbchArfcn=1587
...    NRCELL-11:ifhoSsbSmtcOffset=0
...    NRCELL-11:initialPreambleReceivedTargetPower=-150
...    NRCELL-11:lcrId=11
...    NRCELL-11:lteToNrTimeOffset=30
...    NRCELL-11:maxNumPuschAllocationPerSlot=4
...    NRCELL-11:mcsIndexForArtificialLoad=0
...    NRCELL-11:measGapSelectionSA=balancedChoice
...    NRCELL-11:mgta=ms0
...    NRCELL-11:msg1FrequencyStart=13
...    NRCELL-11:nrOfScgFailures=0
...    NRCELL-11:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-2
...    NRCELL-11:nrarfcn=633372
...    NRCELL-11:nrofHARQProcessesForPDSCH=16
...    NRCELL-11:pMax=190
...    NRCELL-11:pMaxNROwnCell=23
...    NRCELL-11:pagingOffset=1
...    NRCELL-11:pagingTargetRate=MCS9_SF0
...    NRCELL-11:physCellId=60
...    NRCELL-11:prachConfigurationIndex=13
...    NRCELL-11:preambleTransMax=n200
...    NRCELL-11:pucchDataDtxNumOfSamples=30
...    NRCELL-11:puschDataDtxNumOfSamples=30
...    NRCELL-11:raResponseWindow=sl20
...    NRCELL-11:ranAC=0
...    NRCELL-11:reqMinNumPuschPrb=96
...    NRCELL-11:rloConsecDtxThreshold=2
...    NRCELL-11:rloDtxRatioThreshold=50
...    NRCELL-11:rloPathLossThreshold=130
...    NRCELL-11:rloSinrThreshold=-45
...    NRCELL-11:rlpDetDlHarqThreshold=500
...    NRCELL-11:rsrpThresholdSSB=37
...    NRCELL-11:sCellBadChannelQualityThreshold=14
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellGoodChannelQualityThreshold=18
...    NRCELL-11:siChangeIndDuration=2
...    NRCELL-11:ssPbchBlockPower=15
...    NRCELL-11:ssbScs=15KHz
...    NRCELL-11:t300=600ms
...    NRCELL-11:targetTotalLoad=0
...    NRCELL-11:timingAdvanceOffset=n0
...    NRCELL-11:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-11:type0CoresetConfigurationIndex=7
...    NRCELL-11:type0SearchSpaceConfigurationIndex=5
...    NRCELL-11:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-11:ulDMRSAdditionalPosition=One additional DMRS
...    NRCELL-11:ulSchedTimeInterval=2000
...    NRCELL-11:ullaDeltaSinrMin=-150
...    NRCELL-11:voiceFBMode=redirection
...    NRCELL-11:weightForSCellSelection=45
...    NRCELL-11:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-11:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-11:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3
...    NRCELL-11:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-11:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3

...    NRCELL-11:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-11:csirsForTracking:firstRE=0
...    NRCELL-11:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-11:dlPtrs:dlPtrsFreqDensityThresNrb0=3
...    NRCELL-11:dlPtrs:dlPtrsFreqDensityThresNrb1=3
...    NRBTS/NRDRX-0:drxInactivityTimer=80ms
...    NRBTS/NRDRX-0:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-0:drxRetransTimerUl=0slot
...    NRCELL-11:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-11:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-11:fPdcchMonOccsnPo=0
...    NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-11:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-11:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-11:ulPowerControlCommon:p0NominalPucch=-90
...    NRCELL-11:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-11:ulPowerControlCommon:p0NominalSrs=-96
...    NRCELL-11:ulPtrs:ulPtrsFreqDensityThresNrb0=3
...    NRCELL-11:ulPtrs:ulPtrsFreqDensityThresNrb1=3
...    NRCELL-11:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-11:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=35
...    NRCELL-11:a1MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-11:a1MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-11:a1MeasSCellAddSsbRsrp=${EMPTY}
...    NRCELL-11:a1MeasSCellAddSsbRsrq=${EMPTY}
...    NRCELL-11:a1MeashoPrefNRLayerSsbRsrp=${EMPTY}
...    NRCELL-11:a1MeashoPrefNRLayerSsbRsrpSA=${EMPTY}
...    NRCELL-11:a1MeashoPrefNRLayerSsbRsrq=${EMPTY}
...    NRCELL-11:a1MeashoPrefNRLayerSsbRsrqSA=${EMPTY}
...    NRCELL-11:a1MeashoSsbRsrp=${EMPTY}
...    NRCELL-11:a1MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-11:a1MeashoSsbRsrq=${EMPTY}
...    NRCELL-11:a1MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeasRedirectSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeasRedirectSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeasReleaseSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeasReleaseSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeasSCellRelSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeasSCellRelSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeashoSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-11:a2MeashoSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-11:a3MeasSsbRsrp=${EMPTY}
...    NRCELL-11:a3MeasSsbRsrq=${EMPTY}
...    NRCELL-11:a4PeriodicMeasControlNSA=${EMPTY}
...    NRCELL-11:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-11:a5MeasSsbRsrp=${EMPTY}
...    NRCELL-11:a5MeasSsbRsrq=${EMPTY}
...    NRCELL-11:a6MeasSCellSwapSsbRsrp=${EMPTY}
...    NRCELL-11:a6MeasSCellSwapSsbRsrq=${EMPTY}
...    NRCELL-11:beamSet=${EMPTY}
...    NRCELL-11:cellCsiImLocationList=${EMPTY}
...    NRCELL-11:cellCsiRsLocationList=${EMPTY}
...    NRCELL-11:dlInterferenceAvoidance=${EMPTY}
...    NRCELL-11:drxProfileNrAnr=${EMPTY}
...    NRCELL-11:eirpControl=${EMPTY}
...    NRCELL-11:eirpControlPowerReductionFactorList=${EMPTY}
...    NRCELL-11:emergencyAreaIdList=${EMPTY}
...    NRCELL-11:emergencyCallRestrictions=${EMPTY}
...    NRCELL-11:fiveQiDrbDrxList=${EMPTY}
...    NRCELL-11:lcsToGcsTranslate=${EMPTY}
...    NRCELL-11:nGRanAccessPointPosition=${EMPTY}
...    NRCELL-11:infTddFrameStructure=${EMPTY}
...    NRCELL-11:ulBler=${EMPTY}
...    NRCELL-11:nrhoirDNList=${EMPTY}
...    NRCELL-11:pciExcludeList=${EMPTY}
...    NRCELL-11:pdcchAutoConfig=${EMPTY}
...    NRCELL-11:pdschHrLaConfig=${EMPTY}
...    NRCELL-11:plmnIndvSelAssisInfoList=${EMPTY}
...    NRCELL-11:puschHrLaConfig=${EMPTY}
...    NRCELL-11:srsForBeamMgmt=${EMPTY}
...    NRCELL-11:srsForSubbandBm=${EMPTY}
...    NRCELL-11:tddFrameStructure=${EMPTY}
...    NRCELL-11:uacAcCatList=${EMPTY}
...    NRCELL-11:uacAcContParSetList=${EMPTY}
...    NRCELL-11:wbSbSrsSwitch=${EMPTY}
...    NRCELL-11:adaptiveSrBlockingMinimization=${EMPTY}
...    NRCELL-11:adaptiveSrLoadThresholdDown=${EMPTY}
...    NRCELL-11:adaptiveSrLoadThresholdUp=${EMPTY}
...    NRCELL-11:chBw=${EMPTY}
...    NRCELL-11:idleMMEnDcSteeringPercentageOfUes=${EMPTY}
...    NRCELL-11:idleMMSteeringWRREnabled=${EMPTY}
...    NRCELL-11:mMimoAntArrayMode=${EMPTY}
...    NRCELL-11:maxGBRTrafficLimit=${EMPTY}
...    NRCELL-11:n310VoNR=${EMPTY}
...    NRCELL-11:preferredVoNrSrPeriod=${EMPTY}
...    NRCELL-11:slotLAUseHighBlerAckNack=${EMPTY}
...    NRCELL-11:slotLAUseLowBlerAckNack=${EMPTY}
...    NRCELL-11:srPeriodicityMin=${EMPTY}
...    NRCELL-11:t310VoNR=${EMPTY}
...    NRCELL-11:vonrReservation=${EMPTY}
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELLGRP-0:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-0:nrCellList=11
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11:actCsiResAllocOptList=sCellCsiAllocAlgoOpt

@{PAPAMS_ADD_CELL13}
...    NRCELL-13:actLowGbrNumHandlingEnh=false
...    NRCELL-13:actShortBsrLimitAdaptation=true
...    NRCELL-13:configuredEpsTac=222
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13:actAsiDistMimoNr=false
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-1:antlDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/ANTL-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-1:resourceDN=${EMPTY}
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2:antlDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/ANTL-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2:resourceDN=${EMPTY}
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-3:antlDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/ANTL-2
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-3:resourceDN=${EMPTY}
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4:antlDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/ANTL-2
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4:resourceDN=${EMPTY}

...    NRCELL-13:a2MeasRedirectEnabled=none
...    NRCELL-13:absThreshSsbRsrpConsolidation=0
...    NRCELL-13:absThreshSsbRsrqConsolidation=10
...    NRCELL-13:actAdaptiveSr=false
...    NRCELL-13:actDl256Qam=true
...    NRCELL-13:actEnhancedVoNR=false
...    NRCELL-13:actGBRAdmissionControl=off
...    NRCELL-13:actVoNR=false
...    NRCELL-13:cellDepType=SA+NSA
...    NRCELL-13:cellTechnology=FDD
...    NRCELL-13:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:dlMuLowSinrThreshold=-60
...    NRCELL-13:dlMuMaxNumPairedUEs=8
...    NRCELL-13:dlMuNeighborThreshold=80
...    NRCELL-13:dlMuPairingThreshold=5
...    NRCELL-13:dlQam256PowerBackoffAbove6=40
...    NRCELL-13:dlQam256PowerBackoffSub6=30
...    NRCELL-13:dllaIniMcs=13
...    NRCELL-13:drxWactDlEnabled=false
...    NRCELL-13:drxWactUlEnabled=false
...    NRCELL-13:duratScgFailures=0ms
...    NRCELL-13:emergencyFBMode=redirection
...    NRCELL-13:enDcSyncStatus=synchronous
...    NRCELL-13:expectedCellSize=5km
...    NRCELL-13:freqBandIndicatorNR=71
...    NRCELL-13:gscnOrSsPbchArfcn=1587
...    NRCELL-13:ifhoSsbSmtcOffset=0
...    NRCELL-13:initialPreambleReceivedTargetPower=-150
...    NRCELL-13:lcrId=13
...    NRCELL-13:lteToNrTimeOffset=30
...    NRCELL-13:maxNumPuschAllocationPerSlot=4
...    NRCELL-13:mcsIndexForArtificialLoad=0
...    NRCELL-13:measGapSelectionSA=balancedChoice
...    NRCELL-13:mgta=ms0
...    NRCELL-13:msg1FrequencyStart=13
...    NRCELL-13:nrOfScgFailures=0
...    NRCELL-13:nrSysInfoProfileDN=MRBTS-2/NRBTS-2/NRSYSINFO_PROFILE-2
...    NRCELL-13:nrarfcn=633372
...    NRCELL-13:nrofHARQProcessesForPDSCH=16
...    NRCELL-13:pMax=190
...    NRCELL-13:pMaxNROwnCell=23
...    NRCELL-13:pagingOffset=1
...    NRCELL-13:pagingTargetRate=MCS9_SF0
...    NRCELL-13:physCellId=62
...    NRCELL-13:prachConfigurationIndex=13
...    NRCELL-13:preambleTransMax=n200
...    NRCELL-13:pucchDataDtxNumOfSamples=30
...    NRCELL-13:puschDataDtxNumOfSamples=30
...    NRCELL-13:raResponseWindow=sl20
...    NRCELL-13:ranAC=0
...    NRCELL-13:reqMinNumPuschPrb=96
...    NRCELL-13:rloConsecDtxThreshold=2
...    NRCELL-13:rloDtxRatioThreshold=50
...    NRCELL-13:rloPathLossThreshold=130
...    NRCELL-13:rloSinrThreshold=-45
...    NRCELL-13:rlpDetDlHarqThreshold=500
...    NRCELL-13:rsrpThresholdSSB=37
...    NRCELL-13:sCellBadChannelQualityThreshold=14
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellGoodChannelQualityThreshold=18
...    NRCELL-13:siChangeIndDuration=2
...    NRCELL-13:ssPbchBlockPower=15
...    NRCELL-13:ssbScs=15KHz
...    NRCELL-13:t300=600ms
...    NRCELL-13:targetTotalLoad=0
...    NRCELL-13:timingAdvanceOffset=n0
...    NRCELL-13:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRCELL-13:type0CoresetConfigurationIndex=7
...    NRCELL-13:type0SearchSpaceConfigurationIndex=5
...    NRCELL-13:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-13:ulDMRSAdditionalPosition=One additional DMRS
...    NRCELL-13:ulSchedTimeInterval=2000
...    NRCELL-13:ullaDeltaSinrMin=-150
...    NRCELL-13:voiceFBMode=redirection
...    NRCELL-13:weightForSCellSelection=45
...    NRCELL-13:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-1
...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-3
...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-1
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-3              
...    NRCELL-13:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-13:csirsForTracking:firstRE=0
...    NRCELL-13:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-13:dlPtrs:dlPtrsFreqDensityThresNrb0=3
...    NRCELL-13:dlPtrs:dlPtrsFreqDensityThresNrb1=3
...    NRBTS/NRDRX-0:drxInactivityTimer=80ms
...    NRBTS/NRDRX-0:drxRetransTimerDl=16slot
...    NRBTS/NRDRX-0:drxRetransTimerUl=16slot
...    NRCELL-13:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-13:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-13:fPdcchMonOccsnPo=0
...    NRCELL-13:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-13:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-13:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-13:ulPowerControlCommon:p0NominalPucch=-90
...    NRCELL-13:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-13:ulPowerControlCommon:p0NominalSrs=-96
...    NRCELL-13:ulPtrs:ulPtrsFreqDensityThresNrb0=3
...    NRCELL-13:ulPtrs:ulPtrsFreqDensityThresNrb1=3
...    NRCELL-13:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-13:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=35
...    NRCELL-13:a1MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-13:a1MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-13:a1MeasSCellAddSsbRsrp=${EMPTY}
...    NRCELL-13:a1MeasSCellAddSsbRsrq=${EMPTY}
...    NRCELL-13:a1MeashoPrefNRLayerSsbRsrp=${EMPTY}
...    NRCELL-13:a1MeashoPrefNRLayerSsbRsrpSA=${EMPTY}
...    NRCELL-13:a1MeashoPrefNRLayerSsbRsrq=${EMPTY}
...    NRCELL-13:a1MeashoPrefNRLayerSsbRsrqSA=${EMPTY}
...    NRCELL-13:a1MeashoSsbRsrp=${EMPTY}
...    NRCELL-13:a1MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-13:a1MeashoSsbRsrq=${EMPTY}
...    NRCELL-13:a1MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-13:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-13:a2MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-13:a2MeasRedirectSsbRsrp=${EMPTY}
...    NRCELL-13:a2MeasRedirectSsbRsrq=${EMPTY}
...    NRCELL-13:a2MeasReleaseSsbRsrp=${EMPTY}
...    NRCELL-13:a2MeasReleaseSsbRsrq=${EMPTY}
...    NRCELL-13:a2MeasSCellRelSsbRsrp=${EMPTY}
...    NRCELL-13:a2MeasSCellRelSsbRsrq=${EMPTY}
...    NRCELL-13:a2MeashoSsbRsrp=${EMPTY}
...    NRCELL-13:a2MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-13:a2MeashoSsbRsrq=${EMPTY}
...    NRCELL-13:a2MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-13:a3MeasSsbRsrp=${EMPTY}
...    NRCELL-13:a3MeasSsbRsrq=${EMPTY}
...    NRCELL-13:a4PeriodicMeasControlNSA=${EMPTY}
...    NRCELL-13:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-13:a5MeasSsbRsrp=${EMPTY}
...    NRCELL-13:a5MeasSsbRsrq=${EMPTY}
...    NRCELL-13:a6MeasSCellSwapSsbRsrp=${EMPTY}
...    NRCELL-13:a6MeasSCellSwapSsbRsrq=${EMPTY}
...    NRCELL-13:beamSet=${EMPTY}
...    NRCELL-13:cellCsiImLocationList=${EMPTY}
...    NRCELL-13:cellCsiRsLocationList=${EMPTY}
...    NRCELL-13:dlInterferenceAvoidance=${EMPTY}
...    NRCELL-13:drxProfileNrAnr=${EMPTY}
...    NRCELL-13:eirpControl=${EMPTY}
...    NRCELL-13:eirpControlPowerReductionFactorList=${EMPTY}
...    NRCELL-13:emergencyAreaIdList=${EMPTY}
...    NRCELL-13:emergencyCallRestrictions=${EMPTY}
...    NRCELL-13:fiveQiDrbDrxList=${EMPTY}
...    NRCELL-13:lcsToGcsTranslate=${EMPTY}
...    NRCELL-13:nGRanAccessPointPosition=${EMPTY}
...    NRCELL-13:infTddFrameStructure=${EMPTY}
...    NRCELL-13:ulBler=${EMPTY}
...    NRCELL-13:nrhoirDNList=${EMPTY}
...    NRCELL-13:pciExcludeList=${EMPTY}
...    NRCELL-13:pdcchAutoConfig=${EMPTY}
...    NRCELL-13:pdschHrLaConfig=${EMPTY}
...    NRCELL-13:plmnIndvSelAssisInfoList=${EMPTY}
...    NRCELL-13:puschHrLaConfig=${EMPTY}
...    NRCELL-13:srsForBeamMgmt=${EMPTY}
...    NRCELL-13:srsForSubbandBm=${EMPTY}
...    NRCELL-13:tddFrameStructure=${EMPTY}
...    NRCELL-13:uacAcCatList=${EMPTY}
...    NRCELL-13:uacAcContParSetList=${EMPTY}
...    NRCELL-13:wbSbSrsSwitch=${EMPTY}
...    NRCELL-13:adaptiveSrBlockingMinimization=${EMPTY}
...    NRCELL-13:adaptiveSrLoadThresholdDown=${EMPTY}
...    NRCELL-13:adaptiveSrLoadThresholdUp=${EMPTY}
...    NRCELL-13:chBw=${EMPTY}
...    NRCELL-13:idleMMEnDcSteeringPercentageOfUes=${EMPTY}
...    NRCELL-13:idleMMSteeringWRREnabled=${EMPTY}
...    NRCELL-13:mMimoAntArrayMode=${EMPTY}
...    NRCELL-13:maxGBRTrafficLimit=${EMPTY}
...    NRCELL-13:n310VoNR=${EMPTY}
...    NRCELL-13:preferredVoNrSrPeriod=${EMPTY}
...    NRCELL-13:slotLAUseHighBlerAckNack=${EMPTY}
...    NRCELL-13:slotLAUseLowBlerAckNack=${EMPTY}
...    NRCELL-13:srPeriodicityMin=${EMPTY}
...    NRCELL-13:t310VoNR=${EMPTY}
...    NRCELL-13:vonrReservation=${EMPTY}
...    NRCELL-13/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELLGRP-0:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-0:nrCellList=13
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=11
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:lcrId=11
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13:actCsiResAllocOptList=sCellCsiAllocAlgoOpt

@{PAPAMS_Recover_Cells_11}
...    @{PAPAMS_ADD_CELL11}
...    NRBTS/NRDU-1:refNrCellGroup=0,1
@{PAPAMS_Recover_Cells_13}
...    @{PAPAMS_ADD_CELL13}
...    NRBTS/NRDU-1:refNrCellGroup=0,1

@{PARAMS_DELETE_CELL11}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-11
...    delete:NRCELL-11/NRCELL_FDD-1
...    delete:NRCELLGRP-0
...    delete:NRREL-1
...    NRBTS/NRDU-1:refNrCellGroup=1

@{PARAMS_DELETE_CELL13}
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-13
...    delete:NRCELL-13/NRCELL_FDD-1
...    delete:NRCELLGRP-0
...    delete:NRREL-1
...    NRBTS/NRDU-1:refNrCellGroup=1
@{SIM_NRADJGNB_NRADJNRCELL}
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=4
...    NRBTS/NRADJGNB-3:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-1:gNbId=4
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=41
...    NRBTS/NRADJNRCELL-1:nrarfcn=368400
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
#...    NRCELL-11/NRREL-1:gNbId=4
#...    NRCELL-11/NRREL-1:removeNotAllowed=false
#...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
#...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
#...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
#...    NRCELL-11/NRREL-1:gNbIdLength=22
#...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
#...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
#...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
#...    NRCELL-11/NRREL-1:lcrId=41
#...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.141
...    NRBTS/XNLINK-2:cPlaneIpAddrCtrl=oamControlled
@{gnb1_CellActivationAlarmTimer}
...    MRBTS-1/NRBTS-1:nsaCellActivationAlarmTimer=10
...    MRBTS-1/NRBTS-1:saCellActivationAlarmTimer=10
@{gnb2_CellActivationAlarmTimer}
...    MRBTS-2/NRBTS-2:nsaCellActivationAlarmTimer=10
...    MRBTS-2/NRBTS-2:saCellActivationAlarmTimer=10
${Wait_For_NR_RAT_Reset}
...    30s

*** Test Cases ***
CB009939-A_ET_05_Pair of redundancy BTSs forced active startup and NG link lock unlock
    [Tags]  
    Verify GNB1 forced active and GNB2 standby after full commission
    Verify NG link lock and Unlock on standby gnb1
    Verify NG link lock and Unlock on standby gnb2
    GNB1 standby and GNB2 active then delete cells
    Verify cell addition on stanby GNB1 and active GNB2
    Lock Unlock BBMOD and change redundancy role
    [Teardown]    Common Test Teardown And Stop Capture Logs and disabled CB009939 and recovery cells
    
*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup 2Airphone Env    tl_type=${GNB_CONFIG}

Modify Cfg
    ${sim_gNB4}    catenate    set_gnb id=4 type=simulated plmn=311:489 xn=10.0.1.141 ng=10.0.1.140 gnb_id=0x04:22
    ...    daemon=$SERVER_IP:$DAEMON_PORT x2_peers=none amf=1 nssai=0x1:0xd143a5 xp=10.0.1.141:32742 xpu=10.0.1.141:32742 xp_management=on
    Update Cfg    ${sim_gNB4}
    Update Cfg    gnb_param id=4 send_xn_setup=false sib1_period=40 xn_listening_socket=on
    ${simgNB4_cell11}    catenate    set_cell id=41 gnb=4 pci=20:0 tac=200 nrci=0x0B tdd_cell=off proxy=10.0.1.140:9999
    ...    nr_arfcn=349400:368400 gscn=4605 nr_scs=15kHz bs_channel_bandwidth=10MHz
    Update Cfg    ${simgNB4_cell11}
    
Verify GNB1 forced active and GNB2 standby after full commission
    Check gnb1 active state
    Check gnb2 standby state
    
Verify NG link lock and Unlock on standby gnb1
    Online commission gnb1 standby and gnb2 active
    ${delta_parameters}    Create List    NRBTS-1/SERVEDAMF-1:administrativeState=Locked    NRBTS-1:actNgcFlexSaMode=true
    Delta Commission Parameters    ${delta_parameters}    
    Wait Until Keyword Succeeds    3min    10s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Locked
    ${delta_parameters}    Create List    NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked    NRBTS-1:actNgcFlexSaMode=true
    Delta Commission Parameters    ${delta_parameters}
    Wait Until Keyword Succeeds    3min    10s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
    Wait Until Keyword Succeeds    3min    30s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active

Verify NG link lock and Unlock on standby gnb2
    Online commission gnb2 standby and gnb1 active
    ${delta_parameters}    Create List    NRBTS-2/SERVEDAMF-1:administrativeState=Locked    NRBTS-2:actNgcFlexSaMode=true
    Delta Commission Parameters gnb2    ${delta_parameters}    
    Wait Until Keyword Succeeds    3min    10s    Object Should Exist gnb2     MRBTS-2/NRBTS-2/SERVEDAMF-1:administrativeState=Locked
    ${delta_parameters}    Create List    NRBTS-2/SERVEDAMF-1:administrativeState=Unlocked    NRBTS-2:actNgcFlexSaMode=true
    Delta Commission Parameters gnb2    ${delta_parameters}
    Wait Until Keyword Succeeds    3min    10s    Object Should Exist gnb2    MRBTS-2/NRBTS-2/SERVEDAMF-1:administrativeState=Unlocked
    Wait Until Keyword Succeeds    3min    30s    Object Should Exist gnb2    MRBTS-2/NRBTS-2/SERVEDAMF-1:ngLinkStatus=Active

Common Test Teardown And Stop Capture Logs and disabled CB009939 and recovery cells
    Online commission gnb2 disabled and gnb1 disabled
    Add cells
    Check gnb1 active state
    Check gnb2 active state
    Common Test Teardown And Stop Capture Logs
    
Online commission gnb2 disabled and gnb1 disabled
    Log To Console    disable CB009939
    Delta Commission Parameters    ${GNB1_Disabled_CB009939}
    Delta Commission Parameters gnb2    ${GNB2_Disabled_CB009939}
    sleep    ${Wait_For_NR_RAT_Reset}

Online commission gnb2 standby and gnb1 active
    Log To Console    gnb2 standby
    Delta Commission Parameters gnb2    ${CB009939_gnb2_standby}
    Log To Console    gnb1 active
    Delta Commission Parameters    ${CB009939_gnb1_active}
    sleep    ${Wait_For_NR_RAT_Reset}

Online commission gnb1 standby and gnb2 active
    Log To Console    gnb1 standby
    Delta Commission Parameters    ${CB009939_gnb1_standby}
    Log To Console    gnb2 active
    Delta Commission Parameters gnb2    ${CB009939_gnb2_active}
    sleep    ${Wait_For_NR_RAT_Reset}
 
Delete cells
    Log To Console    delete cell
    delta commission parameters    ${PARAMS_DELETE_CELL11}
    delta commission parameters GNB2    ${PARAMS_DELETE_CELL13}
    sleep    20s    #avoid internal procedure influence on next step
    
Add cells 
    delta commission parameters    ${PAPAMS_Recover_Cells_11}
    delta commission parameters GNB2    ${PAPAMS_Recover_Cells_13}
    sleep    20s    #avoid internal procedure influence on next step

Check gnb1 active state
    ${operationalState}    create list    
    ...    MRBTS-1/NRBTS-1/NRCELL-11:operationalState=enabled
    ...    MRBTS-1/NRBTS-1/NRCELL-12:operationalState=enabled
    ${links_params}    create list    
    ...    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    ...    MRBTS-1/NRBTS-1/LTEENB-0:x2LinkStatus=available
    #...    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    ...    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Object Should Exist    ${operationalState}
    Object Should Exist    ${links_params}
    Log To Console    gnb1 active State is OK


Check gnb1 standby state
    ${operationalState}    create list    
    ...    MRBTS-1/NRBTS-1/NRCELL-11:operationalState=disabled
    ...    MRBTS-1/NRBTS-1/NRCELL-12:operationalState=disabled
    ${links_params}    create list    
    ...    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    ...    MRBTS-1/NRBTS-1/LTEENB-0:x2LinkStatus=available
    #...    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    ...    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Object Should Exist    ${operationalState}
    Object Should Exist    ${links_params}
    Log To Console    gnb1 standby State is OK

Check gnb1 standby state after delete cell-11
    ${operationalState}    create list    
    #...    MRBTS-1/NRBTS-1/NRCELL-11:operationalState=disabled
    ...    MRBTS-1/NRBTS-1/NRCELL-12:operationalState=disabled
    ${links_params}    create list    
    ...    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    ...    MRBTS-1/NRBTS-1/LTEENB-0:x2LinkStatus=available
    #...    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    ...    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Object Should Exist    ${operationalState}
    Object Should Exist    ${links_params}
    
Check gnb2 active state
    ${operationalState_gnb2}    create list    
    ...    MRBTS-2/NRBTS-2/NRCELL-13:operationalState=enabled
    ...    MRBTS-2/NRBTS-2/NRCELL-14:operationalState=enabled
        ${links_params_gnb2}    create list
    ...    MRBTS-2/NRBTS-2/SERVEDAMF-1:ngLinkStatus=Active
    ...    MRBTS-2/NRBTS-2/LTEENB-0:x2LinkStatus=available
    #...    MRBTS-2/NRBTS-2/XNLINK-1:xnLinkStatus=available
    Object Should Exist GNB2    ${operationalState_gnb2}
    Object Should Exist GNB2    ${links_params_gnb2}
    Log To Console    gnb2 active State OK    

Check gnb2 standby state
    ${operationalState_gnb2}    create list    
    ...    MRBTS-2/NRBTS-2/NRCELL-13:operationalState=disabled
    ...    MRBTS-2/NRBTS-2/NRCELL-14:operationalState=disabled
        ${links_params_gnb2}    create list
    ...    MRBTS-2/NRBTS-2/SERVEDAMF-1:ngLinkStatus=Active
    ...    MRBTS-2/NRBTS-2/LTEENB-0:x2LinkStatus=available
    #...    MRBTS-2/NRBTS-2/XNLINK-1:xnLinkStatus=available
    Object Should Exist GNB2    ${operationalState_gnb2}
    Object Should Exist GNB2    ${links_params_gnb2}
    Log To Console    gnb2 standby State OK
    
Check gnb2 active state after delete cell-13
    ${operationalState_gnb2}    create list    
    ...    MRBTS-2/NRBTS-2/NRCELL-14:operationalState=enabled
        ${links_params_gnb2}    create list
    ...    MRBTS-2/NRBTS-2/SERVEDAMF-1:ngLinkStatus=Active
    ...    MRBTS-2/NRBTS-2/LTEENB-0:x2LinkStatus=available
    #...    MRBTS-2/NRBTS-2/XNLINK-1:xnLinkStatus=available
    Object Should Exist GNB2    ${operationalState_gnb2}
    Object Should Exist GNB2    ${links_params_gnb2}    
    
GNB1 standby and GNB2 active then delete cells 
    Online commission gnb1 standby and gnb2 active
    Check gnb1 standby state
    Check gnb2 active state
    Delete cells
    Check gnb1 standby state after delete cell-11
    Check gnb2 active state after delete cell-13

Verify cell addition on stanby GNB1 and active GNB2
    Add cells
    Check gnb1 standby state
    Check gnb2 active state

Lock BBMOD
    delta commission parameters    MRBTS/EQM-1/APEQM-1/CABINET-1/BBMOD-1:administrativeState=Locked

Unlock BBMOD
    delta commission parameters    MRBTS/EQM-1/APEQM-1/CABINET-1/BBMOD-1:administrativeState=Unlocked

Lock Unlock BBMOD and change redundancy role
    Lock BBMOD
    Online commission gnb2 standby and gnb1 active  
    Unlock BBMOD
    Check gnb1 active state
    Check gnb2 standby state
    Wait Until Keyword Succeeds    3min    10s    check cell has sib Message    enb_id=2    cell_id=11
        
check cell has sib Message
    [Arguments]    ${enb_id}    ${cell_id}
    ${ret}    Execute Egate Command    ib_enb_cell_disp enb=${enb_id} cell=${cell_id}    SIB
    should contain X Times    ${ret}    yes    6