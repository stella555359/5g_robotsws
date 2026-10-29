*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS24R1    team-CN3ET    owner-lixia.zhou
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{others}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE5411}
...    @{inactive_timer}
...    @{LTE5226}
...    @{LTE4549}
...    @{CA}
...    @{LNADJGNB}
...    @{CB005825}


@{PARAMS_IN_SWCONFIG}
...    ${Uec_TUecRadMaxValueOfNrPciCounter}=10
...    ${Uec_TUecRadMaxSizeOfNrPciCounters}=5
...    ${Uec_TUecRadAnrNrNbrRelRemPeriodicCheckTimer}=1
...    ${Uec_TUecRadAnrNrHoNbrRelRemPeriodicCheckTimer}=1
...    ${Rrom_TRromRadParamAnrNrHoNbrRelRemPeriodicCheckTimer}=1
...    ${TUecRadDebugLogEnabledGlobal}=1
...    ${TUecRadDebugLogEnabledUec}=1
...    ${TUecRadDebugLogEnabledCommon}=1
...    ${TUecRadDebugLogEnabledCommonCodec}=1
...    ${AaSysLogOutputMode}=5
...    ${AaSysLogOutputLevel}=1
...    ${AaSysLogInputLevel}=1
...    ${TRromRadDebugLogEnabledCommon}=1
...    ${TRromRadDebugLogEnabledGlobal}=1
...    ${TRromRadDebugLogEnabledRrom}=1
...    ${numConsideredB2PerUe}=6
...    ${AnrNrNbrHoFail2H}=20
${AnrNrNbrHoFail2H}    0x1300EF
${numConsideredB2PerUe}    0x1300F1
${Uec_TUecRadMaxValueOfNrPciCounter}    0x1300DA
${Uec_TUecRadMaxSizeOfNrPciCounters}    0x1300DB
${Uec_TUecRadAnrNrNbrRelRemPeriodicCheckTimer}    0x1300E2    #7334 remove hour to minutes
${Uec_TUecRadAnrNrHoNbrRelRemPeriodicCheckTimer}    0x1300F0    #5825 remove hour to minutes
${Rrom_TRromRadParamAnrNrHoNbrRelRemPeriodicCheckTimer}    0x120134
${AaSysLogOutputMode}     0x10041    #0=none,1=all,2=udp,3=sic,4=stdout, 5=local, 6=remote
${AaSysLogOutputLevel}     0x10040    #1=DBG,2=INF(default),3=WRN,4=ERR,5=VIP,6=NoPrints
${AaSysLogInputLevel}      0x1003F    #1=DBG,2=INF(default),3=WRN,4=ERR,5=VIP,6=NoPrints
${TRromRadDebugLogEnabledCommon}    0x120006
${TRromRadDebugLogEnabledGlobal}    0x120004
${TRromRadDebugLogEnabledRrom}    0x120005
${TUecRadDebugLogEnabledGlobal}    0x130020
${TUecRadDebugLogEnabledUec}    0x130021
${TUecRadDebugLogEnabledCommon}    0x13001E
${TUecRadDebugLogEnabledCommonCodec}    0x13001F
${NRARFCN2036667}    2036672
${GSCN22325}    22325

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tS1eRABModInd=50
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNBTS:pdcpProf1001:pdcpProfileId=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms
...    LNBTS:nrRestrictionOverride=disabled

@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=120kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${GSCN22325}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=120kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=8

@{others}
...    LNBTS:actMultBearers=true
...    LNBTS:caSchedFairFact=0
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    LNBTS/CAGENB-0:caClusterEnbList:lnBtsId=100000
...    LNBTS/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL:harqMaxTrVoLteDl=4
...    LNCEL/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL:tac=33
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    delete:LNCEL-1/MBSFNCEL-0
...    LNBTS-1:actAmbrModCaTrigger=false

@{LTE5411}
...    LNBTS:actLteNrFastNbrRelAdd=false
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddHyst=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddThresh=5
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddHyst=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddThresh=5
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0

@{LNADJGNB}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11

@{inactive_timer}
...    LNCEL-1:inactivityTimer=1000
...    LNBTS/ANR-0:anrNrInactivityTimer=5

@{LTE5226}
...    LNBTS/NRMEASDPR-0:mrWaitTimer=2000

@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference

@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL:caPoolId=1
...    LNCEL:maxNumScells=1
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1800
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19800
...    LNCEL:actFlowCtrlEnh=true
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    delete:LNBTS-1/LNADJ-255
...    LNCEL-1/CAREL-1:scellPrio=3
...    LNBTS-1:actFlexCaMgmt=true
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    delete:LNCEL-2/CAREL-1:beamformingInScellAllowed
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=10
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=10
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-2/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-1:scellPrio=3
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:scellPrio=3

${nci-114719}    0x1C01F

@{PARAMS_IN_EMIL}
...    0x400e
...    0x7509
...    0x75ce
...    0x76b4
...    0x76b5
...    0x771b
...    0x774c
...    0x774b

@{CB005825}
...    LNCEL:measQuantityNr=RSRP
...    LNCEL:t304InterRATN=500ms
...    LNCEL:a2TimeToTriggerActNRMeas=320ms
...    LNCEL:threshold2NR=25
...    LNCEL:hysThreshold2NR=0
...    @{CB007742}
...    LNBTS:actUeBasedAnrNrHo=true
...    @{CB005825_ANR}
...    LNCEL-1:actDrx=true

@{CB005825_ANR}
...    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=3
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS/ANR-0:consec5gHoFailThres=1
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=true
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=22|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=${NRARFCN2036667}|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=enabled|paramPlmnId=0
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=10000

@{CB007742}
...    LNBTS:actHOtoNR=true
...    LNBTS:actSelMobPrf=true
...    LNBTS:tS1RelOvDeltN=5000
...    LNBTS:tS1RelPrepN=5000
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actFlexQCIARPPMProfiles=true
...    LNBTS/MODPR-0:freqLayListPsHoNR=${NRARFCN2036667},2036673,2036674,2036675
...    LNBTS/MODPR-0:freqLayListPsHoNRVoLte=${NRARFCN2036667}
...    @{CB007742_LNHON}

@{CB007742_LNHON}
...    LNCEL-1/LNHON-1:carrierFreqNr=${NRARFCN2036667}
...    LNCEL-1/LNHON-1:freqBandIndicatorListNr=258
...    LNCEL-1/LNHON-1:b1TriggerQuantity=RSRP
...    LNCEL-1/LNHON-1:b1ThresholdRsrp=0
...    LNCEL-1/LNHON-1:b2NrBeamReportQuantity=None
...    LNCEL-1/LNHON-1:b2NrCellReportQuantity=RSRP
...    LNCEL-1/LNHON-1:b2NrReportIntervalRsrp=480ms
...    LNCEL-1/LNHON-1:b2NrTimeToTriggerRsrpMeas=320ms
...    LNCEL-1/LNHON-1:b2Threshold1RsrpNr=40
...    LNCEL-1/LNHON-1:b2Threshold2RsrpNr=56
...    LNCEL-1/LNHON-1:hysB2NrThresholdRsrp=4
...    LNCEL-1/LNHON-1:nrCarPrio5GSACapMobility=1
...    LNCEL-1/LNHON-1:nrQuantityConfigSetId=0
...    LNCEL-1/LNHON-1:offsetFreqNr=0
...    LNCEL-1/LNHON-1:ssbDuration=sf1
...    LNCEL-1/LNHON-1:ssbOffset=0
...    LNCEL-1/LNHON-1:ssbPeriodicity=sf10-r15
...    LNCEL-1/LNHON-1:ssbSubcarrierSpacing=30kHz
...    LNCEL-1/LNHON-1:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    LNCEL-1/LNHON-1:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    LNCEL-1/LNHON-1:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    LNCEL-1/LNHON-1:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4
...    LNCEL-1/LNHON-1:nrPciHoNbrRelAddThresh=5
...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=150000
...    LNCEL-1/LNHON-1:nrPciHoNbrCounterDecay=0
...    LNCEL-2/LNHON-1:nrPciHoNbrRelAddThresh=5
...    LNCEL-2/LNHON-1:nrPciHoNbrRelRemThresh=300000
...    LNCEL-2/LNHON-1:nrPciHoNbrCounterDecay=0
...    LNCEL-2/LNHON-1:carrierFreqNr=${NRARFCN2036667}
...    LNCEL-2/LNHON-1:freqBandIndicatorListNr=258
...    LNCEL-2/LNHON-1:b1TriggerQuantity=RSRP
...    LNCEL-2/LNHON-1:b1ThresholdRsrp=0
...    LNCEL-2/LNHON-1:b2NrBeamReportQuantity=None
...    LNCEL-2/LNHON-1:b2NrCellReportQuantity=RSRP
...    LNCEL-2/LNHON-1:b2NrReportIntervalRsrp=480ms
...    LNCEL-2/LNHON-1:b2NrTimeToTriggerRsrpMeas=320ms
...    LNCEL-2/LNHON-1:b2Threshold1RsrpNr=40
...    LNCEL-2/LNHON-1:b2Threshold2RsrpNr=56
...    LNCEL-2/LNHON-1:hysB2NrThresholdRsrp=4
...    LNCEL-2/LNHON-1:nrCarPrio5GSACapMobility=1
...    LNCEL-2/LNHON-1:nrQuantityConfigSetId=0
...    LNCEL-2/LNHON-1:offsetFreqNr=0
...    LNCEL-2/LNHON-1:ssbDuration=sf1
...    LNCEL-2/LNHON-1:ssbOffset=0
...    LNCEL-2/LNHON-1:ssbPeriodicity=sf10-r15
...    LNCEL-2/LNHON-1:ssbSubcarrierSpacing=30kHz
...    LNCEL-2/LNHON-1:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    LNCEL-2/LNHON-1:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    LNCEL-2/LNHON-1:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    LNCEL-2/LNHON-1:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4


...    LNCEL-1/LNHON-2:carrierFreqNr=2036673
...    LNCEL-1/LNHON-2:freqBandIndicatorListNr=258
...    LNCEL-1/LNHON-2:b1TriggerQuantity=RSRP
...    LNCEL-1/LNHON-2:b1ThresholdRsrp=0
...    LNCEL-1/LNHON-2:b2NrBeamReportQuantity=None
...    LNCEL-1/LNHON-2:b2NrCellReportQuantity=RSRP
...    LNCEL-1/LNHON-2:b2NrReportIntervalRsrp=480ms
...    LNCEL-1/LNHON-2:b2NrTimeToTriggerRsrpMeas=320ms
...    LNCEL-1/LNHON-2:b2Threshold1RsrpNr=40
...    LNCEL-1/LNHON-2:b2Threshold2RsrpNr=56
...    LNCEL-1/LNHON-2:hysB2NrThresholdRsrp=4
...    LNCEL-1/LNHON-2:nrCarPrio5GSACapMobility=1
...    LNCEL-1/LNHON-2:nrQuantityConfigSetId=0
...    LNCEL-1/LNHON-2:offsetFreqNr=0
...    LNCEL-1/LNHON-2:ssbDuration=sf1
...    LNCEL-1/LNHON-2:ssbOffset=0
...    LNCEL-1/LNHON-2:ssbPeriodicity=sf10-r15
...    LNCEL-1/LNHON-2:ssbSubcarrierSpacing=30kHz
...    LNCEL-1/LNHON-2:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    LNCEL-1/LNHON-2:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    LNCEL-1/LNHON-2:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    LNCEL-1/LNHON-2:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4
...    LNCEL-1/LNHON-2:nrPciHoNbrRelAddThresh=5
...    LNCEL-1/LNHON-2:nrPciHoNbrRelRemThresh=150000
...    LNCEL-1/LNHON-2:nrPciHoNbrCounterDecay=0

...    LNCEL-1/LNHON-3:carrierFreqNr=2036674
...    LNCEL-1/LNHON-3:freqBandIndicatorListNr=258
...    LNCEL-1/LNHON-3:b1TriggerQuantity=RSRP
...    LNCEL-1/LNHON-3:b1ThresholdRsrp=0
...    LNCEL-1/LNHON-3:b2NrBeamReportQuantity=None
...    LNCEL-1/LNHON-3:b2NrCellReportQuantity=RSRP
...    LNCEL-1/LNHON-3:b2NrReportIntervalRsrp=480ms
...    LNCEL-1/LNHON-3:b2NrTimeToTriggerRsrpMeas=320ms
...    LNCEL-1/LNHON-3:b2Threshold1RsrpNr=40
...    LNCEL-1/LNHON-3:b2Threshold2RsrpNr=56
...    LNCEL-1/LNHON-3:hysB2NrThresholdRsrp=4
...    LNCEL-1/LNHON-3:nrCarPrio5GSACapMobility=1
...    LNCEL-1/LNHON-3:nrQuantityConfigSetId=0
...    LNCEL-1/LNHON-3:offsetFreqNr=0
...    LNCEL-1/LNHON-3:ssbDuration=sf1
...    LNCEL-1/LNHON-3:ssbOffset=0
...    LNCEL-1/LNHON-3:ssbPeriodicity=sf10-r15
...    LNCEL-1/LNHON-3:ssbSubcarrierSpacing=30kHz
...    LNCEL-1/LNHON-3:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    LNCEL-1/LNHON-3:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    LNCEL-1/LNHON-3:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    LNCEL-1/LNHON-3:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4
...    LNCEL-1/LNHON-3:nrPciHoNbrRelAddThresh=5
...    LNCEL-1/LNHON-3:nrPciHoNbrRelRemThresh=150000
...    LNCEL-1/LNHON-3:nrPciHoNbrCounterDecay=0

...    LNCEL-1/LNHON-4:carrierFreqNr=2036675
...    LNCEL-1/LNHON-4:freqBandIndicatorListNr=258
...    LNCEL-1/LNHON-4:b1TriggerQuantity=RSRP
...    LNCEL-1/LNHON-4:b1ThresholdRsrp=0
...    LNCEL-1/LNHON-4:b2NrBeamReportQuantity=None
...    LNCEL-1/LNHON-4:b2NrCellReportQuantity=RSRP
...    LNCEL-1/LNHON-4:b2NrReportIntervalRsrp=480ms
...    LNCEL-1/LNHON-4:b2NrTimeToTriggerRsrpMeas=320ms
...    LNCEL-1/LNHON-4:b2Threshold1RsrpNr=40
...    LNCEL-1/LNHON-4:b2Threshold2RsrpNr=56
...    LNCEL-1/LNHON-4:hysB2NrThresholdRsrp=4
...    LNCEL-1/LNHON-4:nrCarPrio5GSACapMobility=1
...    LNCEL-1/LNHON-4:nrQuantityConfigSetId=0
...    LNCEL-1/LNHON-4:offsetFreqNr=0
...    LNCEL-1/LNHON-4:ssbDuration=sf1
...    LNCEL-1/LNHON-4:ssbOffset=0
...    LNCEL-1/LNHON-4:ssbPeriodicity=sf10-r15
...    LNCEL-1/LNHON-4:ssbSubcarrierSpacing=30kHz
...    LNCEL-1/LNHON-4:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    LNCEL-1/LNHON-4:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    LNCEL-1/LNHON-4:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    LNCEL-1/LNHON-4:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4
...    LNCEL-1/LNHON-4:nrPciHoNbrRelAddThresh=5
...    LNCEL-1/LNHON-4:nrPciHoNbrRelRemThresh=150000
...    LNCEL-1/LNHON-4:nrPciHoNbrCounterDecay=0

${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C1082080304
...    218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B082008284105182083841004142082061040
...    105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B
...    82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E0002040
...    6080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A00000061000880014207F80226A02    
# above support both 7334 NRANR and 7742 HO to 5GSA

${ue_nr_capabilities}    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000C039
...    F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D802802010040118028030100401004
...    600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064104208
...    000210410809A55334A262B9515DA8AEC4
${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B02004040C1803A020000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA000000
...    0010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B00080418000402000100800040202
...    0040088000201000080404008011800040200010080004020200400840002010100200440001008000402020040080

${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x1F', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell3}    SEPARATOR=
...    {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x503', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell4}    SEPARATOR=
...    {id: 74, technology: nr , tac: 33, pci: '1:1', nrci: '0x504', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell5}    SEPARATOR=
...    {id: 75, technology: nr , tac: 33, pci: '1:2', nrci: '0x505', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}


@{unlockcell1}
...    LNCEL-1:administrativeState=unlocked

@{lockcell1}
...    LNCEL-1:administrativeState=locked

@{actUeBasedAnrNrHo_false}
...    LNBTS:actUeBasedAnrNrHo=false
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=false

@{actUeBasedAnrNrHo_true}
...    LNBTS:actUeBasedAnrNrHo=true
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=true

@{case_47_MOCs}
...    LNADJN-1:arfcnValueNR=2036672
...    LNADJN-1:multiFrequencyBandList=258
...    LNADJN-1:physCellIdNr=1
...    LNADJN-1/LNADJNL-0:cellIdentity=114719
...    LNADJN-1/LNADJNL-0:gnbIdLength=23
...    LNADJN-1/LNADJNL-0:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-0:gNBplmnId:mnc=1
...    LNADJN-1/LNADJNL-0:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-0:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-0:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-0:plmnIdList:mnc=1
...    LNADJN-1/LNADJNL-0:plmnIdList:mncLength=2
...    LNADJN-2:arfcnValueNR=2036672
...    LNADJN-2:multiFrequencyBandList=258
...    LNADJN-2:physCellIdNr=2   
...    LNADJN-2/LNADJNL-0:cellIdentity=114719
...    LNADJN-2/LNADJNL-0:gnbIdLength=26
...    LNADJN-2/LNADJNL-0:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-0:gNBplmnId:mnc=2
...    LNADJN-2/LNADJNL-0:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-0:trackingAreaCodeNR=33
...    LNADJN-2/LNADJNL-0:plmnIdList:mcc=262
...    LNADJN-2/LNADJNL-0:plmnIdList:mnc=2
...    LNADJN-2/LNADJNL-0:plmnIdList:mncLength=2

@{LNRELN255_CGI1}
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=1
...    LNCEL-1/LNRELN-255:cellIdentity=114719

@{LNADJN1_LNADJNL0_CGI1}
...    LNADJN-1/LNADJNL-0:cellIdentity=114719
...    LNADJN-1/LNADJNL-0:gnbIdLength=23
...    LNADJN-1/LNADJNL-0:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-0:gNBplmnId:mnc=1
...    LNADJN-1/LNADJNL-0:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-0:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-0:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-0:plmnIdList:mnc=1
...    LNADJN-1/LNADJNL-0:plmnIdList:mncLength=2

@{LNRELN254_CGI5}
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=5
...    LNCEL-1/LNRELN-254:cellIdentity=114719

@{LNADJN511_LNADJNL11_CGI5}
...    LNADJN-511/LNADJNL-11:cellIdentity=114719
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=5
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-511/LNADJNL-11:plmnIdList:mnc=5
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2
@{LNADJN511_PCI5}
...    LNADJN-511:arfcnValueNR=2036672
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=5

@{LNRELN253_CGI3}
...    LNCEL-1/LNRELN-253:plmnId:mcc=262
...    LNCEL-1/LNRELN-253:plmnId:mnc=3
...    LNCEL-1/LNRELN-253:cellIdentity=114719

@{LNADJN510_LNADJNL11_CGI3}
...    LNADJN-510/LNADJNL-11:cellIdentity=114719
...    LNADJN-510/LNADJNL-11:gnbIdLength=25
...    LNADJN-510/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-510/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-510/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-510/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-510/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-510/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-510/LNADJNL-11:plmnIdList:mncLength=2

@{LNADJN510_PCI3}
...    LNADJN-510:arfcnValueNR=2036672
...    LNADJN-510:multiFrequencyBandList=258
...    LNADJN-510:physCellIdNr=3

@{LNRELN255_CGI2}
...    LNCEL-1/LNRELN-252:plmnId:mcc=262
...    LNCEL-1/LNRELN-252:plmnId:mnc=2
...    LNCEL-1/LNRELN-252:cellIdentity=114719

@{LNADJN2_PCI2}
...    LNADJN-2:arfcnValueNR=2036672
...    LNADJN-2:multiFrequencyBandList=258
...    LNADJN-2:physCellIdNr=2   

@{LNADJN2_LNADJNL0_PCI2}
...    LNADJN-2/LNADJNL-0:cellIdentity=114719
...    LNADJN-2/LNADJNL-0:gnbIdLength=26
...    LNADJN-2/LNADJNL-0:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-0:gNBplmnId:mnc=2
...    LNADJN-2/LNADJNL-0:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-0:trackingAreaCodeNR=33
...    LNADJN-2/LNADJNL-0:plmnIdList:mcc=262
...    LNADJN-2/LNADJNL-0:plmnIdList:mnc=2
...    LNADJN-2/LNADJNL-0:plmnIdList:mncLength=2

@{anrNrCoverageConfirmTimer_8_and_gNBIdLength_25}
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=8000
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=25|paramPlmnId=0

@{restore}
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=12000
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=22|paramPlmnId=0

@{unlockcell1}
...    LNCEL-1:administrativeState=unlocked
@{lockcell1}
...    LNCEL-1:administrativeState=locked

@{case_11_orphan_MOCs}
...    LNCEL-1/LNRELN-1:cellIdentity=114719
...    LNCEL-1/LNRELN-1:psHoAllowed=allowed
...    LNCEL-1/LNRELN-1:removeAllowed=true
...    LNCEL-1/LNRELN-1:plmnId:mcc=262
...    LNCEL-1/LNRELN-1:plmnId:mnc=1
...    LNCEL-1/LNRELN-1:plmnId:mncLength=2

...    LNADJN-5:arfcnValueNR=2036672
...    LNADJN-5:multiFrequencyBandList=258
...    LNADJN-5:physCellIdNr=5
...    LNADJN-5/LNADJNL-0:cellIdentity=114719
...    LNADJN-5/LNADJNL-0:gnbIdLength=22
...    LNADJN-5/LNADJNL-0:gNBplmnId:mcc=262
...    LNADJN-5/LNADJNL-0:gNBplmnId:mnc=5
...    LNADJN-5/LNADJNL-0:gNBplmnId:mncLength=2
...    LNADJN-5/LNADJNL-0:trackingAreaCodeNR=33
...    LNADJN-5/LNADJNL-0:plmnIdList:mcc=262
...    LNADJN-5/LNADJNL-0:plmnIdList:mnc=5
...    LNADJN-5/LNADJNL-0:plmnIdList:mncLength=2

@{del_MOCs_created_by_case47}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-253
...    delete:LNCEL-1/LNRELN-252
...    delete:LNADJN-511
...    delete:LNADJN-510
...    delete:LNADJN-1
...    delete:LNADJN-2

@{del_MOCs_created_by_case11}
...    delete:LNCEL-1/LNRELN-1
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-5
...    delete:LNADJN-511

@{del_MOCs_created_by_case50}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-511

@{delete_orphan_LNADJN_5}
...    LNADJN-5:arfcnValueNR=2036672
...    LNADJN-5:multiFrequencyBandList=258
...    LNADJN-5:physCellIdNr=5
...    LNADJN-5/LNADJNL-0:cellIdentity=114719
...    LNADJN-5/LNADJNL-0:gnbIdLength=22
...    LNADJN-5/LNADJNL-0:gNBplmnId:mcc=262
...    LNADJN-5/LNADJNL-0:gNBplmnId:mnc=5
...    LNADJN-5/LNADJNL-0:gNBplmnId:mncLength=2
...    LNADJN-5/LNADJNL-0:trackingAreaCodeNR=33
...    LNADJN-5/LNADJNL-0:plmnIdList:mcc=262
...    LNADJN-5/LNADJNL-0:plmnIdList:mnc=5
...    LNADJN-5/LNADJNL-0:plmnIdList:mncLength=2

@{delete_orphan_LNRELN_1}
...    LNCEL-1/LNRELN-1:cellIdentity=114719
...    LNCEL-1/LNRELN-1:psHoAllowed=allowed
...    LNCEL-1/LNRELN-1:removeAllowed=true
...    LNCEL-1/LNRELN-1:plmnId:mcc=262
...    LNCEL-1/LNRELN-1:plmnId:mnc=1
...    LNCEL-1/LNRELN-1:plmnId:mncLength=2

@{delete_suspend_LNRELN}
...    LNCEL-1/LNRELN-254:cellIdentity=114719
...    LNCEL-1/LNRELN-255:cellIdentity=114719
@{unlockcell1}
...    LNCEL-1:administrativeState=unlocked
@{lockcell1}
...    LNCEL-1:administrativeState=locked

@{LNADJN511_LNADJNL11_PCI1}
...    LNADJN-511/LNADJNL-11:cellIdentity=114719
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=1
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-511/LNADJNL-11:plmnIdList:mnc=1
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2

@{LNADJN511_PCI1}
...    LNADJN-511:arfcnValueNR=2036672
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=1

@{LNRELN254_CGI2}
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=2
...    LNCEL-1/LNRELN-254:cellIdentity=114719

@{LNADJN510_LNADJNL11_CGI2}
...    LNADJN-510/LNADJNL-11:cellIdentity=114719
...    LNADJN-510/LNADJNL-11:gnbIdLength=22
...    LNADJN-510/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-510/LNADJNL-11:gNBplmnId:mnc=2
...    LNADJN-510/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-510/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-510/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-510/LNADJNL-11:plmnIdList:mnc=2
...    LNADJN-510/LNADJNL-11:plmnIdList:mncLength=2

@{LNADJN510_PCI2}
...    LNADJN-510:arfcnValueNR=2036673
...    LNADJN-510:multiFrequencyBandList=258
...    LNADJN-510:physCellIdNr=2

@{LNRELN253_CGI3}
...    LNCEL-1/LNRELN-253:plmnId:mcc=262
...    LNCEL-1/LNRELN-253:plmnId:mnc=3
...    LNCEL-1/LNRELN-253:cellIdentity=114719

@{LNADJN509_LNADJNL11_CFI3}
...    LNADJN-509/LNADJNL-11:cellIdentity=114719
...    LNADJN-509/LNADJNL-11:gnbIdLength=22
...    LNADJN-509/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-509/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-509/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-509/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-509/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-509/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-509/LNADJNL-11:plmnIdList:mncLength=2

@{LNADJN509_PCI3}
...    LNADJN-509:arfcnValueNR=2036674
...    LNADJN-509:multiFrequencyBandList=258
...    LNADJN-509:physCellIdNr=3

@{arfcnValueNR_FR3_physCellIdNr_PCI5}
...    LNADJN-511:arfcnValueNR=2036674
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=5

@{LNRELN255_CGI5}
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=5
...    LNCEL-1/LNRELN-255:cellIdentity=114719

@{LNADJN508_LNADJNL11_CGI5_tac_33}
...    LNADJN-508/LNADJNL-11:cellIdentity=114719
...    LNADJN-508/LNADJNL-11:gnbIdLength=22
...    LNADJN-508/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-508/LNADJNL-11:gNBplmnId:mnc=5
...    LNADJN-508/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-508/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-508/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-508/LNADJNL-11:plmnIdList:mnc=5
...    LNADJN-508/LNADJNL-11:plmnIdList:mncLength=2

@{LNADJN508_PCI5}
...    LNADJN-508:arfcnValueNR=2036674
...    LNADJN-508:multiFrequencyBandList=258
...    LNADJN-508:physCellIdNr=5

@{cellIdentity_gNBplmnId}
...    LNADJN-510/LNADJNL-11:cellIdentity=115969
...    LNADJN-510/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-510/LNADJNL-11:plmnIdList:mnc=3

@{delete_LNRELN_254}
...    LNCEL-1/LNRELN-254:cellIdentity=114719

@{delete_LNADJN_510}
...    LNADJN-510:arfcnValueNR=2036673

@{case50_para}
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=2|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=2036673|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=2|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=3
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=2036674|paramPlmnId=3
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=4
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=2036675|paramPlmnId=4
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=5
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=All|paramPlmnId=5
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=2|paramPlmnId=5
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=6
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=FR2|paramPlmnId=6
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=56|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-10|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=56|paramMeasConfId=2
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-10|paramMeasConfId=2
...    LNBTS/ANR-0:anrNrParamPlmnList:mcc=262|mnc=1
...    LNBTS/ANR-0:anrNrParamPlmnList:paramPlmnId=2|mnc=2
...    LNBTS/ANR-0:anrNrParamPlmnList:paramPlmnId=3|mnc=3
...    LNBTS/ANR-0:anrNrParamPlmnList:paramPlmnId=4|mnc=4
...    LNBTS/ANR-0:anrNrParamPlmnList:paramPlmnId=5|mnc=5
...    LNBTS/ANR-0:anrNrParamPlmnList:paramPlmnId=6|mnc=6
@{LNRELN_gNBplmnId}
...    LNCEL-1/LNRELN-253:plmnId:mnc=6

@{delete_LNRELN_253}
...    LNCEL-1/LNRELN-253:cellIdentity=114719

@{delete_LNADJN_509}
...    LNADJN-509:physCellIdNr=3

@{trackingAreaCodeNR}
...    LNADJN-508/LNADJNL-11:trackingAreaCodeNR=55

@{LNADJN508_LNADJNL11_CGI5_tac_55}
...    LNADJN-508/LNADJNL-11:cellIdentity=114719
...    LNADJN-508/LNADJNL-11:gnbIdLength=22
...    LNADJN-508/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-508/LNADJNL-11:gNBplmnId:mnc=5
...    LNADJN-508/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-508/LNADJNL-11:trackingAreaCodeNR=55
...    LNADJN-508/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-508/LNADJNL-11:plmnIdList:mnc=5
...    LNADJN-508/LNADJNL-11:plmnIdList:mncLength=2

*** Test Cases ***
CB005825-SR-A-B10_ET_47_verification online change gNBIdLength for anrNrHoParamList and anrNrCoverageConfirmTimer for ANR
    [Setup]    case47_testSetup
    [Documentation]    
    ...    Precondtion: LNADJN-1(PCI1)/LNADJNL-0(CGI1,gnbIdLength23),LNADJN-2(PCI2)/LNADJNL-0(CGI2,gnbIdLength26)
    ...    1. trigger anr for pci1 plmn1, LNRELN-255(CGI1) create, LNADJN-1/LNADJNL-0 is kept
    ...    2. trigger anr for pci5 plmn5, LNRELN-254(CGI5) LNADJN(PCI5)/LNADJNL(CGI5,gnbIdLength22) create
    ...    3. online change gNBIdLength25 during rsc ,then LNRELN-253(CGI3), LNADJN(PCI3)/LNADJNL(CGI3,gnbIdLength25) create      
    ...    4.trigger anr for pci2 plmn2, LNRELN-252(CGI2) create, LNADJN(PCI2)/LNADJNL(CGI2,gnbIdLength26) kept
    ...    5.make tuple 2036672 PCI1 and PCI5 to tobeverify, and repeat step1 and step2, original kept
    [Tags]
    Trigger ANR with PCI1 PLMN1 then LNRELN CGI1 should be created and LNADJN-1 and LNADJNL-1 should be kept 
    Trigger ANR with PCI5 PLMN5 then LNRELN CGI5 LNADJN PCI5 LNADJNL CGI5 gNBLength 22 should be created
    Online change anrNrCoverageConfirmTime to 8 and gNBIdLength to 25 before anrNrCoverageConfirmTimer timeout
    LNRELN CGI3 LNADJN PCI3 LNADJNL CGI3 gNBLength 25 should be created
    Trigger ANR with PCI2 PLMN2 then LNRELN CGI2 should be created and LNADJN-2 and LNADJNL-2 should be kept
    make tuple PCI1 PCI5 from verified to tobeverified
    Trigger ANR with PCI1 PLMN1 original LNRELN-255 LNADJN-1 and LNADJNL-1 should be kept
    Trigger ANR with PCI5 PLMN5 original LNRELN-254 LNADJN PCI5 LNADJNL CGI5 gNBLength 22 should be kept
    [Teardown]    case47_testTeardown

CB005825-SR-A-B10_ET_11_verification online change actUeBasedAnrNrHo during cell lock-unlock    
    [Setup]    case11_testSetup
    [Documentation]
    ...    Precondtion: PCI1:tobeverified, PCI2:verifying, PCI3:verified, PCI4:suspend, PCI5:initial
    ...    orphan LNRELN-1(CGI1), LNADJN-5(PCI5)/LNADJNL-0(CGI5)
    ...    anr is ok, orphan LNADJN/L are delete after 3min
    ...    During lock, online change flag to false, after unlock, anr will not trigger
    ...    During lock, online change flag to true, after unlock, anr will trigger
    ...    orphan LNRELN-1 is delete after flag true 3min, orphan LNRELN-255/254 due to suspend
    ...    anr will not trigger because of no tobeverified tuple (flag false has cleared) 
    ...    following anr will work
    [Tags]
    prepare tuple with verifying verified suspend initial and tobeverified state
    Delta Commission Parameters    ${case_11_orphan_MOCs}
    UE attached and check RSC is triggered      ue_id=11      
    trigger cell1 lock 3min      
    Online change actUeBasedAnrNrHo to false during lock and anr will not trigger after unlock 
    Online change actUeBasedAnrNrHo to true during lock and anr will trigger after unlock
    Check orphon MOCs should be deleted
    RSC not triggered for anrNrInactivityTimer not configured    ue_id=13
    report B2 multiple times to make tuple tobeverified    pci=4    times=6    
    RSC triggered after UE AnrInactivity indication received    ue_id=14
    [Teardown]    case11_testteardown

CB005825-SR-A-B10_ET_50_verification online change arfcnValueNR and physCellIdNr for LNADJN
    [Setup]    case50_testSetup
    [Documentation]
    ...    precondition:LNRELN-255(CGI1),LNADJN-511(FR1,PCI1)/LNADJNL(CGI1,33);
    ...    LNRELN-254(CGI2),LNADJN-510(FR2,PCI2)/LNADJNL(CGI2,33);LNRELN-253(FR3,CGI3),LNADJN-509(PCI3)/LNADJNL(CGI3,33);
    ...    Modify LNADJN-511 to FR3 PCI5
    ...    ANR for FR3 PCI5 result: create LNADJN-508(FR3,PCI5)/LNADJNL, LNRELN-255 is updated with CGI5(delete then create)
    ...    Modify LNADJN-510 cellIdentity and gNBplmnId plmn3, orginal LNRELN-254 and LNADJN-510 are deleted 
    ...    Modify LNADJN-508/LNADJNL tac to 55
    ...    ANR for FR3 PCI5 result: LNADJN-508/LNADJNL is kept 
    ...    Modify LNRELN-253 gNBplmnId to plmn6, orphan LNADJN-509 and LNRELN-253 are deleted
    [Tags]
    Prepare 5825 MOCs for PCI1 PCI2 PCI3
    Online change LNADJN-511 arfcnValueNR to FR3 and physCellIdNrto PCI5
    Trigger ANR for PCI5 FR3 and MOC created correctlly with tac33    
    Online change LNADJN-510 cellIdentity to 115969 and gNBplmnId to plmn3
    Check LNRELN254 and LNADJN510 should be deleted   
    make tuple FR3 PCI5 from verified to tobeverified 
    Online change LNADJNL tac to 55
    Trigger ANR for PCI5 FR3 and MOC created correctlly with tac55
    Online change LNRELN gNBplmnId to plmn6
    Check LNRELN253 and LNADJN509 should be deleted    
    [Teardown]    case50_testteardown

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias for multi UEs
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Set UE parameters for ENDC capability

Create UE Alias for multi UEs
    FOR    ${ue_id}    IN RANGE    11    17
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Uex Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=2 nr_supported_bands=78,258
    Execute Egate Command    ue_enb_param id=1,2,11,12,13,14,15,16 spid=34
    Config gnb7
    Config UE11 to UE16 support NRANR

Config UE11 to UE16 support NRANR
    FOR    ${ue_id}    IN RANGE    11    17
        Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        Execute Uex Command    ue_param id=${ue_id} nr_supported_bands=78,258
    END

Config gnb7
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=4:1

Perform Steps After Onair
    @{lnadj}    Create List    LNADJ:cPlaneIpAddr=10.0.1.3    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj}

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1, trf_type: external}
    Update Yaml    UEs/UE_sets/11     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/12     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/13     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/14     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/15     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/16     bearer: bearer_set_2
    Update Yaml    BASE_STATIONS/1/cus_config/1    energy_saving_feature: on
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      cells:
    ...      - {id: 21, technology: lte, tac: 33, pci: '9:0', earfcn: '1400:19400', bw: 20}
    ...      - {id: 22, technology: lte, tac: 33, pci: '9:1', earfcn: '5920:23920', bw: 20}
    ...      - {id: 23, technology: lte, tac: 33, pci: '9:2', earfcn: '8770:26770', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      type: simulated
    ...      enb_id_macro: 0x0000A
    ...      plmn: '262:03'
    ...      s1: 10.0.1.4
    ...      cells:
    ...        - {id: 31, technology: lte, tac: 33, pci: '0:1', eci: '0x0000A1F', earfcn: '1400:19400', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: 1
    ...      cells:
    ...      - ${gnb7_cell1}
    ...      - ${gnb7_cell2}
    ...      - ${gnb7_cell3}
    ...      - ${gnb7_cell4}
    ...      - ${gnb7_cell5}

case47_testSetup
    Common Test Setup And Start To Capture Logs
    Prepare tuples PCI1-5 with tobeverified state and precondition MOCs

case47_testTeardown
    Clear MOCs created by case47 
    Delta Commission Parameters    ${restore}
    Online change actUeBasedAnrNrHo to false
    Online change actUeBasedAnrNrHo to true
    Common Test Teardown And Stop Capture Logs

Clear MOCs created by case47 
    Delta Commission Parameters    ${del_MOCs_created_by_case47}

set RSC CGI auto report with CGI1 and delay RSC report
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1    ${plmn}=262:01
    set RSC CGI auto report with CGI1    ue_id=${ue_id}    nrarfcn=${nrarfcn}    pci=${pci}    plmn=${plmn}
    Set RSC MR rrc report delay timer    ue_id=${ue_id}    delay=7000

set RSC CGI auto report with CGI1
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1    ${plmn}=262:01
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=${plmn}|${nci-114719} tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

Set RSC MR rrc report delay timer
    [Arguments]    ${ue_id}=1    ${delay}=8000
    ${cmd}    catenate
    ...     ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=delay_next_msg 
    ...     delay=${delay} next_msg=measurementReport
    Run Uex Command    ${cmd}

Prepare tuples PCI1-5 with tobeverified state and precondition MOCs
    FOR    ${temp}    IN RANGE    1    6
    Report B2 multiple times to make tuple tobeverified    pci=${temp}    times=6
    END
    Delta Commission Parameters    ${case_47_MOCs}

make tuple PCI1 PCI5 from verified to tobeverified 
    Delta Commission Parameters    ${lockcell1}
    Delta Commission Parameters    ${unlockcell1}
    Report B2 multiple times to make tuple tobeverified    pci=1    times=6
    Report B2 multiple times to make tuple tobeverified    pci=5    times=6

UE attached and check RSC and CGI triggered and cleanup is done
    [Arguments]    ${ue_id}    ${pci}=1    ${frequency}=2036672
    ${RSC1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${frequency})
    ...    and (purpose eq 'reportStrongestCells') and (s-Measure eq 0)) as RSC_RRC
    ${CGI1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${frequency})
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI') and (s-Measure eq 75)) as CGI_RRC
    ${cleanup1_message}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) ) as clean_RRC
    Expect message flow
    ...    ${RSC1_messsage}
    ...    ${CGI1_messsage}
    ...    ${cleanup1_message}
    ...    alias=NRANR_RRC    overall_timeout=35
    UE attach to cell    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC
    UE detach    ue_id=${ue_id}

UE attached and check RSC is triggered 
    [Arguments]    ${ue_id}=1    ${timeout}=35    
    ${RSC1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (purpose eq 'reportStrongestCells') and (s-Measure eq 0)) as RSC_RRC
    ${cleanup1_message}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) ) as clean_RRC
    Expect message flow
    ...    ${RSC1_messsage}
    ...    ${cleanup1_message}
    ...    alias=RSC_RRC    overall_timeout=${timeout}
    UE attach to cell    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RSC_RRC
    UE detach    ue_id=${ue_id}

set RSC CGI auto report with specified plmn    
    [Arguments]    ${ue_id}=1    ${pci}=1    ${plmn}=262:01    ${rsrp}=57    ${rsrq}=78    ${narfcn}=2036672    ${tac}=33
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${narfcn} nrsrp=${rsrp} nrsrq=${rsrq} nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=${plmn}|${nci-114719} tac=${tac}
    ...    freq_band_list=258
    Run Uex Command    ${cmd}

UE attach to cell
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${cellid}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cellid}
    ${ret1}=    Execute Uex Command    ${V_1}

UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

Trigger UE1 to send B2-NR for freq with PCI1
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${narfcn} amount=1

report B2 multiple times to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ...    ${times}=6
    UE attach to cell    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=5
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    ${times}+1
    Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    END
    UE detach    ue_id=${ue_id}

Trigger UE to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34

Online change actUeBasedAnrNrHo to false
    Delta Commission Parameters    ${actUeBasedAnrNrHo_false}

Online change actUeBasedAnrNrHo to true
    Delta Commission Parameters    ${actUeBasedAnrNrHo_true}

Trigger ANR with PCI1 PLMN1 then LNRELN CGI1 should be created and LNADJN-1 and LNADJNL-1 should be kept
    set RSC CGI auto report with specified plmn    ue_id=11    pci=1    plmn=262:01 
    UE attached and check RSC and CGI triggered and cleanup is done     ue_id=11    pci=1      
    Object Should Exist    ${LNRELN255_CGI1}  
    Object Should Exist    ${LNADJN1_LNADJNL0_CGI1}

Trigger ANR with PCI5 PLMN5 then LNRELN CGI5 LNADJN PCI5 LNADJNL CGI5 gNBLength 22 should be created
    set RSC CGI auto report with specified plmn    ue_id=12    pci=5    plmn=262:05
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=12    pci=5    
    Object Should Exist    ${LNRELN254_CGI5}
    Object Should Exist    ${LNADJN511_LNADJNL11_CGI5}
    Object Should Exist    ${LNADJN511_PCI5}

Online change anrNrCoverageConfirmTime to 8 and gNBIdLength to 25 before anrNrCoverageConfirmTimer timeout 
    Delta Commission Parameters    ${anrNrCoverageConfirmTimer_8_and_gNBIdLength_25}    background=true
    sleep    7s    #for catch the time stamp
    set RSC CGI auto report with CGI1 and delay RSC report    ue_id=14    pci=3    plmn=262:03
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=14    pci=3    

LNRELN CGI3 LNADJN PCI3 LNADJNL CGI3 gNBLength 25 should be created
    sleep    30s    #for delta true
    Object Should Exist    ${LNRELN253_CGI3} 
    Object Should Exist    ${LNADJN510_LNADJNL11_CGI3}
    Object Should Exist    ${LNADJN510_PCI3}

Trigger ANR with PCI2 PLMN2 then LNRELN CGI2 should be created and LNADJN-2 and LNADJNL-2 should be kept
    set RSC CGI auto report with specified plmn    ue_id=13    pci=2    plmn=262:02
    UE attached and check RSC and CGI triggered and cleanup is done     ue_id=13    pci=2    
    Object Should Exist    ${LNRELN255_CGI2}  
    Object Should Exist    ${LNADJN2_PCI2}  
    Object Should Exist    ${LNADJN2_LNADJNL0_PCI2}  

Trigger ANR with PCI1 PLMN1 original LNRELN-255 LNADJN-1 and LNADJNL-1 should be kept
    set RSC CGI auto report with specified plmn    ue_id=12    pci=1    plmn=262:01
    UE attached and check RSC and CGI triggered and cleanup is done     ue_id=12    pci=1    
    Object Should Exist    ${LNRELN255_CGI1}  
    Object Should Exist    ${LNADJN1_LNADJNL0_CGI1}

Trigger ANR with PCI5 PLMN5 original LNRELN-254 LNADJN PCI5 LNADJNL CGI5 gNBLength 22 should be kept
    set RSC CGI auto report with specified plmn    ue_id=13    pci=5    plmn=262:05
    UE attached and check RSC and CGI triggered and cleanup is done     ue_id=13    pci=5     
    Object Should Exist    ${LNRELN254_CGI5}
    Object Should Exist    ${LNADJN511_LNADJNL11_CGI5}
    Object Should Exist    ${LNADJN511_PCI5}

case11_testSetup
    Common Test Setup And Start To Capture Logs
    Online change actUeBasedAnrNrHo to false    
    Online change actUeBasedAnrNrHo to true     

prepare tuple with verifying verified suspend initial and tobeverified state
    make tuple verifying by 5GHO without MO    nrarfcn=${NRARFCN2036667}    pci=2
    make tuple verified by 5GHO with MO    nrarfcn=${NRARFCN2036667}    pci=3
    make tuple suspend by 5GHO    nrarfcn=${NRARFCN2036667}    pci=4
    Report B2 multiple times to make tuple tobeverified    pci=1
    make tuple intial    pci=5    times=3
   
make tuple verifying by 5GHO without MO
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    modify maxMumAnrMoiAllowed to be 22
    Report B2 multiple times to make tuple tobeverified    pci=${pci}
    set RSC CGI auto report with specified plmn    ue_id=11    pci=${pci}    
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=11    pci=${pci}
    modify maxMumAnrMoiAllowed to be 100

make tuple verified by 5GHO with MO
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    report B2 to make tuple tobeverified    nrarfcn=${nrarfcn}    pci=${pci}
    UE attach to cell    ue_id=1
    send B1NR report with set CGI auto report    ue_id=1    nrarfcn=${nrarfcn}    pci=${pci}
    Wait CGI process succeed
    UE detach    ue_id=1
    Object Should Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Object Should Exist    LNCEL-1/LNRELN-254:plmnId:mcc=262

make tuple suspend by 5GHO
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    report B2 to make tuple tobeverified    nrarfcn=${nrarfcn}    pci=${pci}
    set RSC CGI auto report with no freqbandlist    ue_id=11    pci=${pci}
    UE attached and check RSC and CGI triggered failed and cleanup is done    ue_id=11    pci=${pci}

Wait CGI process succeed
    sleep    20s    #wait CGI succeed

send B1NR report with set CGI auto report
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=56 nrsrq=77 cgi_plmn_group cgi=262:3,262:4|${nci-114719} tac=33
    ...    cgi_plmn_group cgi=262:5,262:6|0x1C502 tac=33 freq_band_list=258
    ...    phycell_id=2 narfcn=2036672 nrsrp=25 nrsrq=22 cgi=262:3,262:5|0x1C502 tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

UE attached and check RSC and CGI triggered failed and cleanup is done
    [Arguments]    ${ue_id}    ${pci}=1
    ${RSC1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (purpose eq 'reportStrongestCells') and (s-Measure eq 0)) as RSC_RRC
    ${CGI1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI') and (s-Measure eq 75)) as CGI_RRC
    ${cleanup1_message}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) ) as clean_RRC
    Expect message flow
    ...    ${RSC1_messsage}
    ...    ${CGI1_messsage}
    ...    ${cleanup1_message}
    ...    alias=NRANR_RRC    overall_timeout=30
    UE attach to cell    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC
    UE detach    ue_id=${ue_id}

set RSC CGI auto report with no freqbandlist
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nci-114719} tac=33
    Run Uex Command    ${cmd}

report B2 to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ...    ${times}=7
    UE attach to cell    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=5
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    ${times}
        Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${nrarfcn}
    END
    UE detach    ue_id=${ue_id}

modify maxMumAnrMoiAllowed to be ${NUMBER}
    Delta Commission Parameters    LNBTS-1:maxNumAnrMoiAllowed=${NUMBER}

make tuple intial     
    [Arguments]    ${pci}    ${times}
    report B2 multiple times to make tuple tobeverified    pci=${pci}    times=${times} 

Report B2 multiple times to make tuple tobeverified on cell2
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ...    ${times}=6
    UE attach to cell    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}    cellid=2
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=5
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    ${times}+1
    Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    END
    UE detach    ue_id=${ue_id}

trigger cell1 lock ${time}min
    Delta Commission Parameters    ${lockcell1}
    sleep    ${time}min
    Object Should Not Exist    ${delete_orphan_LNADJN_5}
    
trigger cell1 unlock
    Delta Commission Parameters    ${unlockcell1}

RSC not triggered for anrNrInactivityTimer not configured
    [Arguments]    ${ue_id}=11    ${cellid}=1
    ${noRSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (purpose eq 'reportStrongestCells')) as RSC_RRC
    ${nocleanup_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32))
    ...    and (s-Measure eq 75) and (onDurationTimer eq "psf6")) as clean_RRC
    Expect message Will Not Occur
    ...    ${noRSC_RRC}
    ...    alias=noRSC_RRC    overall_timeout=10
    Expect message Will Not Occur
    ...    ${nocleanup_RRC}
    ...    alias=nocleanup_RRC    overall_timeout=10
    UE attach to cell    ue_id=${ue_id}    cellid=${cellid}
    sleep    5s    #wait for traffic
    Flow Not Occurred For Message    alias=noRSC_RRC
    Flow Not Occurred For Message    alias=nocleanup_RRC
    UE detach    ue_id=${ue_id}

Online change actUeBasedAnrNrHo to false during lock and anr will not trigger after unlock 
    Online change actUeBasedAnrNrHo to false    
    trigger cell1 unlock
    RSC not triggered for anrNrInactivityTimer not configured    ue_id=11
    RSC not triggered for anrNrInactivityTimer not configured    ue_id=11    cellid=2   

Online change actUeBasedAnrNrHo to true during lock and anr will trigger after unlock
    trigger cell1 lock 1min
    Online change actUeBasedAnrNrHo to true     
    trigger cell1 unlock    
    RSC triggered after UE AnrInactivity indication received    ue_id=12
    Report B2 multiple times to make tuple tobeverified on cell2     pci=1    times=6
    RSC triggered after UE AnrInactivity indication received    ue_id=12     cellid=2 

Check orphon MOCs should be deleted
    sleep    3min    orphan LNRELN-1 is deleted
    Object Should Not Exist    ${delete_orphan_LNRELN_1}
    sleep    6mins     3*3=9min
    Object Should Not Exist    ${delete_suspend_LNRELN}

RSC triggered after UE AnrInactivity indication received
    [Arguments]    ${ue_id}=11    ${cellid}=1
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (purpose eq 'reportStrongestCells')) as RSC_RRC
    ${nocleanup_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32))
    ...    and (s-Measure eq 75) and (onDurationTimer eq "psf6")) as clean_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=RSC_RRC    overall_timeout=10
    Expect message Will Not Occur
    ...    ${nocleanup_RRC}
    ...    alias=nocleanup_RRC    overall_timeout=10
    UE attach to cell    ue_id=${ue_id}    cellid=${cellid}
    sleep    5s     wait for traffic
    Flow Occurred As Expected    alias=RSC_RRC
    Flow Not Occurred For Message     alias=nocleanup_RRC
    UE detach    ue_id=${ue_id}

case11_testteardown
    Clear MOCs created by case11
    trigger cell1 unlock
    Online change actUeBasedAnrNrHo to false
    Online change actUeBasedAnrNrHo to true
    Common Test Teardown And Stop Capture Logs

Clear MOCs created by case11
    Delta Commission Parameters    ${del_MOCs_created_by_case11}

Prepare 5825 MOCs for PCI1 PCI2 PCI3
    Report B2 multiple times to make tuple tobeverified    pci=1    times=6    narfcn=2036672
    set RSC CGI auto report with specified plmn    ue_id=11    pci=1    plmn=262:01    narfcn=2036672    tac=33
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=11    pci=1
    Report B2 multiple times to make tuple tobeverified    pci=2    times=6    narfcn=2036673
    set RSC CGI auto report with specified plmn    ue_id=11    pci=2    plmn=262:02    narfcn=2036673    tac=33
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=11    pci=2    frequency=2036673  
    Report B2 multiple times to make tuple tobeverified    pci=3    times=6    narfcn=2036674
    set RSC CGI auto report with specified plmn    ue_id=11    pci=3    plmn=262:03    narfcn=2036674    tac=33
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=11    pci=3    frequency=2036674 
    MOCs should exist after three ANR
    
MOCs should exist after three ANR
    Object Should Exist    ${LNRELN255_CGI1}
    Object Should Exist    ${LNADJN511_LNADJNL11_PCI1}
    Object Should Exist    ${LNADJN511_PCI1}
    Object Should Exist    ${LNRELN254_CGI2}
    Object Should Exist    ${LNADJN510_LNADJNL11_CGI2}
    Object Should Exist    ${LNADJN510_PCI2}
    Object Should Exist    ${LNRELN253_CGI3}
    Object Should Exist    ${LNADJN509_LNADJNL11_CFI3}
    Object Should Exist    ${LNADJN509_PCI3}

Trigger ANR for PCI5 FR3 and MOC created correctlly with tac33
    set RSC CGI auto report with specified plmn    ue_id=12    pci=5    plmn=262:05    narfcn=2036674    tac=33
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=12    pci=5    frequency=2036674
    Object Should Exist    ${LNRELN255_CGI5} 
    Object Should Exist    ${LNADJN508_LNADJNL11_CGI5_tac_33} 
    Object Should Exist    ${LNADJN508_PCI5} 

Trigger ANR for PCI5 FR3 and MOC created correctlly with tac55
    set RSC CGI auto report with specified plmn    ue_id=12    pci=5    plmn=262:05    narfcn=2036674    tac=55
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=12    pci=5    frequency=2036674
    Object Should Exist    ${LNRELN255_CGI5} 
    Object Should Exist    ${LNADJN508_LNADJNL11_CGI5_tac_55} 
    Object Should Exist    ${LNADJN508_PCI5}

case50_testSetup
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${case50_para}

Check LNRELN254 and LNADJN510 should be deleted  
    sleep    3min    orphan MOCs are deleted
    Object Should Not Exist    ${delete_LNADJN_510}
    Object Should Not Exist    ${delete_LNRELN_254}

Check LNRELN253 and LNADJN509 should be deleted  
    sleep    3min    orphan MOCs are deleted
    Object Should Not Exist    ${delete_LNADJN_509}
    Object Should Not Exist    ${delete_LNRELN_253} 
   
make tuple FR3 PCI5 from verified to tobeverified 
    Delta Commission Parameters    ${lockcell1}
    Delta Commission Parameters    ${unlockcell1}

case50_testteardown
    Clear MOCs created by case50
    Online change actUeBasedAnrNrHo to false
    Online change actUeBasedAnrNrHo to true
    Common Test Teardown And Stop Capture Logs

Clear MOCs created by case50
    Delta Commission Parameters    ${del_MOCs_created_by_case50}

Online change LNADJN-511 arfcnValueNR to FR3 and physCellIdNrto PCI5
    Delta Commission Parameters    ${arfcnValueNR_FR3_physCellIdNr_PCI5} 
    Cells Should Be OnAir

Online change LNADJN-510 cellIdentity to 115969 and gNBplmnId to plmn3
    Delta Commission Parameters    ${cellIdentity_gNBplmnId}
    Cells Should Be OnAir

Online change LNADJNL tac to 55
    Delta Commission Parameters    ${trackingAreaCodeNR}
    Cells Should Be OnAir

Online change LNRELN gNBplmnId to plmn6
    Delta Commission Parameters    ${LNRELN_gNBplmnId}