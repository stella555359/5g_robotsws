*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/2cells_ecpri
@{PARAMS_DELETE_CELL1_WITH_NRCELLGRP-0}
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
...    delete:NRCELLGRP-0

@{PARAMS_RECOVER_CELL1_WITH_NRCELLGRP-2}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    NRCELL-1:a2MeasRedirectEnabled=none
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:actAdaptiveSr=false
...    NRCELL-1:actEnhancedVoNR=false
...    NRCELL-1:actGBRAdmissionControl=off
...    NRCELL-1:actProactUlScheduling=true
...    NRCELL-1:actVoNR=false
...    NRCELL-1:ccLoadThreshold=50
...    NRCELL-1:configuredEpsTac=200
...    NRCELL-1:dlDMRSAdditionalPosition=No additional DMRS
...    NRCELL-1:dlMuMaxNumPairedUEs=8
...    NRCELL-1:dlQam256PowerBackoffSub6=15
...    NRCELL-1:dllaDeltaCqiMax=30
...    NRCELL-1:dllaDeltaCqiMin=-30
...    NRCELL-1:dllaIniMcs=0
...    NRCELL-1:dmrsTypeAPosition=pos2
...    NRCELL-1:drxWactDlEnabled=false
...    NRCELL-1:drxWactUlEnabled=false
...    NRCELL-1:duratScgFailures=0ms
...    NRCELL-1:enDcSyncStatus=synchronous
...    NRCELL-1:gscnOrSsPbchArfcn=7880
...    NRCELL-1:ifhoSsbSmtcOffset=0
...    NRCELL-1:initialPreambleReceivedTargetPower=-118
...    NRCELL-1:mcsIndexForArtificialLoad=0
...    NRCELL-1:nrOfScgFailures=0
...    NRCELL-1:nrarfcn=636666
...    NRCELL-1:pMaxNROwnCell=23
...    NRCELL-1:pagingOffset=1
...    NRCELL-1:payloadSizeProactiveDrx=64
...    NRCELL-1:payloadSizeProactiveNonDrx=16
...    NRCELL-1:physCellId=50
...    NRCELL-1:pucchDataDtxNumOfSamples=30
...    NRCELL-1:pucchModeSelect=shortPucch
...    NRCELL-1:puschDataDtxNumOfSamples=30
...    NRCELL-1:reqMinNumPuschPrb=19
...    NRCELL-1:rloConsecDtxThreshold=1
...    NRCELL-1:rloDtxRatioThreshold=1
...    NRCELL-1:rloPathLossThreshold=100
...    NRCELL-1:rloSinrThreshold=-45
...    NRCELL-1:rlpDetCsiBsiThreshold=10
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-1:t300=2000ms
...    NRCELL-1:t301=2000ms
...    NRCELL-1:t311=30000ms
...    NRCELL-1:targetTotalLoad=0
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-1:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-1:ulDMRSAdditionalPosition=No additional DMRS
...    NRCELL-1:ullaDeltaSinrMax=30
...    NRCELL-1:zeroCorrelationZoneConfig=15
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=39
...    NRCELL-1:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=36
...    NRCELL-1:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-1:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL-1:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL-1:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL-1:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrq:a2HysteresishoSsbRsrq=1
...    NRCELL-1:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31
...    NRCELL-1:a2MeashoSsbRsrq:a2TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54
...    NRCELL-1:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-1:csirsForTracking:firstRE=0
...    NRCELL-1:csirsForTracking:startRB=0
...    NRCELL-1:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-1:dlPtrs:actDlPtrs=true
...    NRCELL-1:dtxOptimizedScheduler:dtxDelaySinceLastScheduling=0
...    NRCELL-1:fPdcchMonOccsnPo=0
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:rModDNList=MRBTS-1/EQM-1/APEQM-1/RMOD-1
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-1:ulPowerControlCommon:p0NominalPucch=-80
...    NRCELL-1:ulPowerControlCommon:p0NominalPusch=-74
...    NRCELL-1:ulPowerControlCommon:p0NominalSrs=-80
...    NRCELL-1:ulPtrs:actUlPtrs=true
...    NRCELL-1:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=35
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
...    NRCELL-1:drxProfileAnrEutra=${EMPTY}
...    NRCELL-1:drxProfileAnrNrIntraFreq=${EMPTY}
...    NRCELL-1:drxProfileNrAnr=${EMPTY}
...    NRCELL-1:dynPdcchTdMgt=${EMPTY}
...    NRCELL-1:eirpControl=${EMPTY}
...    NRCELL-1:eirpControlPowerReductionFactorList=${EMPTY}
...    NRCELL-1:emergencyAreaIdList=${EMPTY}
...    NRCELL-1:emergencyCallRestrictions=${EMPTY}
...    NRCELL-1:infTddFrameStructure=${EMPTY}
...    NRCELL-1:nrhoirDNList=${EMPTY}
...    NRCELL-1:pciExcludeList=${EMPTY}
...    NRCELL-1:pdcchAutoConfig=${EMPTY}
...    NRCELL-1:plmnIndvSelAssisInfoList=${EMPTY}
...    NRCELL-1:ranAreaConfigList=${EMPTY}
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
...    NRCELLGRP-2:maxDlHarqTx=4
...    NRCELLGRP-2:scs=30 KHz
...    NRCELLGRP-2:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-2:nrCellList=1
...    NRBTS/NRDU-1:refNrCellGroup=2,1


*** Test Cases ***
Test Case
    delta commission parameters    ${PARAMS_DELETE_CELL1_WITH_NRCELLGRP-0}
    delta commission parameters    ${PARAMS_RECOVER_CELL1_WITH_NRCELLGRP-2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}



