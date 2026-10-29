*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Case setup
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS24R1    team-CN3ET    owner-feng.2.chen
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
${numConsideredB2PerUe}    0x1300F1
${Uec_TUecRadMaxValueOfNrPciCounter}    0x1300DA
${Uec_TUecRadMaxSizeOfNrPciCounters}    0x1300DB
${Uec_TUecRadAnrNrNbrRelRemPeriodicCheckTimer}    0x1300E2
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
${NRARFCN630000}    629984

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
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=8
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
${nci-115974}    0x1C506
${nci-115969}    0x1C501
${nci-115970}    0x1C502
@{PARAMS_IN_EMIL}
...    0x400e
...    0x7509
...    0x75ce
...    0x771b

@{CB005825}
...    LNCEL-1:measQuantityNr=RSRP
...    LNCEL-1:t304InterRATN=500ms
...    LNCEL-1:a2TimeToTriggerActNRMeas=320ms
...    LNCEL-1:threshold2NR=25
...    LNCEL-1:hysThreshold2NR=0
...    @{CB007742}
...    LNBTS:actUeBasedAnrNrHo=true
...    @{CB005825_ANR}
...    LNCEL-1:actDrx=true

@{CB005825_ANR}
...    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=72
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS/ANR-0:consec5gHoFailThres=15
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=true
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=All|carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=22|carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=FR1|carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=22|carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mnc=3|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=1

@{CB007742}
...    LNBTS:actHOtoNR=true
...    LNBTS:actSelMobPrf=true
...    LNBTS:tS1RelOvDeltN=5000
...    LNBTS:tS1RelPrepN=5000
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actFlexQCIARPPMProfiles=true
...    LNBTS/MODPR-0:freqLayListPsHoNR=${NRARFCN2036667},${NRARFCN630000}
...    LNBTS/MODPR-0:freqLayListPsHoNRVoLte=${NRARFCN2036667},${NRARFCN630000}
...    @{CB007742_LNHON}
...    @{CB007742_LNHON1}

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
...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=100000
...    LNCEL-1/LNHON-1:nrPciHoNbrCounterDecay=1000

@{CB007742_LNHON1}
...    LNCEL-1/LNHON-2:carrierFreqNr=${NRARFCN630000}
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
...    LNCEL-1/LNHON-2:nrPciHoNbrRelRemThresh=100000
...    LNCEL-1/LNHON-2:nrPciHoNbrCounterDecay=1000

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
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
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

${gnb7_cell6}    SEPARATOR=
...    {id: 76, technology: nr , tac: 33, pci: '2:0', nrci: '0x506', nr_arfcn: '${NRARFCN630000}:${NRARFCN630000}',
...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

@{deletersc_rsrq}
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=${EMPTY}|paramMeasConfId=1
@{deletersc_rsrp_addrsrq}
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=${EMPTY}|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1

@{restore_threshold}
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-253
...    delete:LNCEL-1/LNRELN-252
...    delete:LNADJN-511
...    delete:LNADJN-510

@{delete created MO}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-511

@{LTE2051}
...    LNBTS:actMeasBasedIMLB=true
...    LNBTS:actIdleLB=true
...    LNBTS:actSelMobPrf=false
...    LNCEL:loadSettings:cellCapClass=1
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=10
...    LNCEL-1:loadSettings:targetLoadGbrDl=10
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=10
...    LNCEL-1:loadSettings:targetLoadPdcch=10
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=0
...    LNCEL:idleLBCapThresh=100
...    LNCEL:cellResourceSharingMode=none
...    LNCEL:targetSelMethod=SIB_based
...    LNCEL:idleLBPercentageOfUes=100
...    LNCEL-1/IRFIM-1:dlCarFrqEut=1600
...    LNCEL-1/IRFIM-1:intFrNCList:physCellIdNcl=2
...    LNCEL-1/IRFIM-1:eutCelResPrio=7
...    LNCEL-2:loadSettings:nomNumPrbNonGbr=1
...    LNCEL-2:loadSettings:targetLoadGbrDl=50
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-2:loadSettings:targetLoadPdcch=90
...    LNCEL-3:loadSettings:nomNumPrbNonGbr=1
...    LNCEL-3:loadSettings:targetLoadGbrDl=50
...    LNCEL-3:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-3:loadSettings:targetLoadPdcch=90
...    delete:LNCEL-1/GFIM-1
...    delete:LNCEL-1/CDFIM-1:rttBdClList:idleLBRttCelResPrio
...    delete:LNCEL-1/CDFIM-1:rttBdClList:idleLBRttCelResWeight

@{active_IMLB_change_inactivitytimer}
...    @{LTE2051}
...    LNCEL-1:inactivityTimer=10
...    LNBTS-1/ANR-0:anrNrInactivityTimer=9

@{restore_inactivity timer}
...    LNCEL-1:inactivityTimer=10
...    LNBTS-1/ANR-0:anrNrInactivityTimer=5
...    LNBTS:actMeasBasedIMLB=false
...    LNBTS:actIdleLB=false

@{change_inactivity_timer}
...    LNCEL-1:inactivityTimer=1000
...    LNBTS-1/ANR-0:anrNrInactivityTimer=5


@{LNRELN_CGI1}
...    LNCEL-1/LNRELN-255:cellIdentity=115970
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2
...    LNCEL-1/LNRELN-254:cellIdentity=115970
...    LNCEL-1/LNRELN-254:psHoAllowed=allowed
...    LNCEL-1/LNRELN-254:removeAllowed=true
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=4
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2

@{LNRELN_CGI3}
...    LNCEL-1/LNRELN-255:cellIdentity=115969
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{Manual_Created_LNADJN_CGI1}
...    LNADJN-0:arfcnValueNR=2036672
...    LNADJN-0:multiFrequencyBandList=258
...    LNADJN-0:physCellIdNr=1
@{Manual_Created_LNADJNL_CGI1}
...    LNADJN-0/LNADJNL-0:cellIdentity=115970
...    LNADJN-0/LNADJNL-0:gnbIdLength=22
...    LNADJN-0/LNADJNL-0:gNBplmnId:mcc=262
...    LNADJN-0/LNADJNL-0:gNBplmnId:mnc=3
...    LNADJN-0/LNADJNL-0:gNBplmnId:mncLength=2
...    LNADJN-0/LNADJNL-0:trackingAreaCodeNR=33
...    LNADJN-0/LNADJNL-0:plmnIdList:mcc=262
...    LNADJN-0/LNADJNL-0:plmnIdList:mnc=3
...    LNADJN-0/LNADJNL-0:plmnIdList:mncLength=2
@{Manual_Created_LNRELN_CGI1}
...    LNCEL-1/LNRELN-0:cellIdentity=115970
...    LNCEL-1/LNRELN-0:psHoAllowed=allowed
...    LNCEL-1/LNRELN-0:removeAllowed=true
...    LNCEL-1/LNRELN-0:plmnId:mcc=262
...    LNCEL-1/LNRELN-0:plmnId:mnc=3
...    LNCEL-1/LNRELN-0:plmnId:mncLength=2

@{Manual_Created_CGI1}
...    @{Manual_Created_LNADJN_CGI1}
...    @{Manual_Created_LNADJNL_CGI1}
#...    @{Manual_Created_LNRELN_CGI1}

@{LNADJN_CGI1}
...    LNADJN-511:arfcnValueNR=2036672
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=1

@{LNADJNL_CGI1}
...    LNADJN-511/LNADJNL-11:cellIdentity=115970
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-511/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2
...    LNADJN-511/LNADJNL-10:cellIdentity=115970
...    LNADJN-511/LNADJNL-10:gnbIdLength=22
...    LNADJN-511/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-10:gNBplmnId:mnc=4
...    LNADJN-511/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-10:trackingAreaCodeNR=33
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=4
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=1
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=2
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=5
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=6
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=9
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=12
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=10
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=13

@{LNADJNL_CGI3}
...    LNADJN-511/LNADJNL-11:cellIdentity=115969
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-511/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2

@{LNRELN_CGI2}
...    LNCEL-1/LNRELN-253:cellIdentity=115970
...    LNCEL-1/LNRELN-253:psHoAllowed=allowed
...    LNCEL-1/LNRELN-253:removeAllowed=true
...    LNCEL-1/LNRELN-253:plmnId:mcc=262
...    LNCEL-1/LNRELN-253:plmnId:mnc=17
...    LNCEL-1/LNRELN-253:plmnId:mncLength=2
...    LNCEL-1/LNRELN-252:cellIdentity=115970
...    LNCEL-1/LNRELN-252:psHoAllowed=allowed
...    LNCEL-1/LNRELN-252:removeAllowed=true
...    LNCEL-1/LNRELN-252:plmnId:mcc=262
...    LNCEL-1/LNRELN-252:plmnId:mnc=16
...    LNCEL-1/LNRELN-252:plmnId:mncLength=2

@{LNADJN_CGI2}
...    LNADJN-510:arfcnValueNR=2036672
...    LNADJN-510:multiFrequencyBandList=258
...    LNADJN-510:physCellIdNr=2

@{LNADJNL_CGI2}
...    LNADJN-510/LNADJNL-11:cellIdentity=115970
...    LNADJN-510/LNADJNL-11:gnbIdLength=22
...    LNADJN-510/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-510/LNADJNL-11:gNBplmnId:mnc=17
...    LNADJN-510/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-510/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-510/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-510/LNADJNL-11:plmnIdList:mnc=17
...    LNADJN-510/LNADJNL-11:plmnIdList:mncLength=2
...    LNADJN-510/LNADJNL-10:cellIdentity=115970
...    LNADJN-510/LNADJNL-10:gnbIdLength=22
...    LNADJN-510/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-510/LNADJNL-10:gNBplmnId:mnc=16
...    LNADJN-510/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-510/LNADJNL-10:trackingAreaCodeNR=33
...    LNADJN-510/LNADJNL-10:plmnIdList:mcc=262
...    LNADJN-510/LNADJNL-10:plmnIdList:mnc=16
...    LNADJN-510/LNADJNL-10:plmnIdList:mncLength=2

@{anrNrNbrHoRelVerifyPeriod_0}
...    LNBTS-1/ANR-0:anrNrNbrHoRelVerifyPeriod=0min

@{delete_LNADJNL_LNRELN}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-0/LNADJNL-0
#...    delete:LNCEL-1/LNRELN-0

@{create_LNADJNL_LNRELN}
...    @{Manual_Created_LNADJNL_CGI1}
...    @{Manual_Created_LNRELN_CGI1}
...    @{LNRELN_CGI2}

@{LNRELN_CGI2_created_case7}
...    LNCEL-1/LNRELN-255:cellIdentity=115969
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=4
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNRELN_CGI2_created_case7_2}
...    LNCEL-1/LNRELN-255:cellIdentity=115970
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2
...    LNCEL-1/LNRELN-254:cellIdentity=115969
...    LNCEL-1/LNRELN-254:psHoAllowed=allowed
...    LNCEL-1/LNRELN-254:removeAllowed=true
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=4
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2

@{LNRELN_CGI2_created_case7_3}
...    LNCEL-1/LNRELN-0:cellIdentity=115970
...    LNCEL-1/LNRELN-0:psHoAllowed=allowed
...    LNCEL-1/LNRELN-0:removeAllowed=true
...    LNCEL-1/LNRELN-0:plmnId:mcc=262
...    LNCEL-1/LNRELN-0:plmnId:mnc=3
...    LNCEL-1/LNRELN-0:plmnId:mncLength=2
...    LNCEL-1/LNRELN-254:cellIdentity=115969
...    LNCEL-1/LNRELN-254:psHoAllowed=allowed
...    LNCEL-1/LNRELN-254:removeAllowed=true
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=4
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2
...    LNCEL-1/LNRELN-253:cellIdentity=115970
...    LNCEL-1/LNRELN-253:psHoAllowed=allowed
...    LNCEL-1/LNRELN-253:removeAllowed=true
...    LNCEL-1/LNRELN-253:plmnId:mcc=262
...    LNCEL-1/LNRELN-253:plmnId:mnc=17
...    LNCEL-1/LNRELN-253:plmnId:mncLength=2
...    LNCEL-1/LNRELN-252:cellIdentity=115970
...    LNCEL-1/LNRELN-252:psHoAllowed=allowed
...    LNCEL-1/LNRELN-252:removeAllowed=true
...    LNCEL-1/LNRELN-252:plmnId:mcc=262
...    LNCEL-1/LNRELN-252:plmnId:mnc=16
...    LNCEL-1/LNRELN-252:plmnId:mncLength=2

@{LNADJNL_CGI2_created_case7}
...    LNADJN-0/LNADJNL-11:cellIdentity=115969
...    LNADJN-0/LNADJNL-11:gnbIdLength=22
...    LNADJN-0/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-0/LNADJNL-11:gNBplmnId:mnc=4
...    LNADJN-0/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-0/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-0/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-0/LNADJNL-11:plmnIdList:mnc=4
...    LNADJN-0/LNADJNL-11:plmnIdList:mncLength=2

@{LNRELGNBCELL}
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115974
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115974
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{delete_all_MOCs_except_LNADJN}
...    @{LNRELGNBCELL}
...    delete:LNCEL-1/LNRELN-0
...    delete:LNCEL-1/LNRELN-252
...    delete:LNCEL-1/LNRELN-253
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-0/LNADJNL-11

${wait_anrNrInactivityTimer_timeout}    5

${wait_traffic_take_effect}    3

@{LNADJN511_LNADJNL11_LNRELN255}
...    LNCEL-1/LNRELN-255:cellIdentity=115974
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=6
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:cellIdentity=115974
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=6
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=6
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2|mnc=6
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=7
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2|mnc=7
...    LNADJN-511:arfcnValueNR=629984
...    LNADJN-511:multiFrequencyBandList=78
...    LNADJN-511:physCellIdNr=6

*** Test Cases ***
CB005825-A-B6-g_ET_06_01_RSC fail due to RSC MR threshold not match or PCI not match
    [Tags]
    [Documentation]
    ...    precondition: no LNADJN LNADJNL and LNRELN MO existed, make [2036672 1] [2036672 2] tobeverified
    ...    attach UE11, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report with RSRP and RSRQ smaller
    ...    than threshold, report CGI can not trigger, cleanup is done
    ...    attach UE12, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report with RSRP smaller
    ...    than threshold, report CGI can not trigger, cleanup is done
    ...    attach UE13, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report with RSRP bigger
    ...    than threshold, report CGI triggered, cleanup is done, LNADJN/L LNRELN are created
    ...    attach UE14, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report with RSRQ smaller
    ...    than threshold, report CGI can not trigger, cleanup is done
    ...    attach UE15, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report with RSRQ bigger
    ...    than threshold, report CGI triggered, cleanup is done, LNADJN/L LNRELN are created
    Report B2 to make 2 tuple pair tobeverified
    Set RSC auto report with RSRP RSRQ value smaller than threshold and CGI not triggered    ue_id=11    pci=1
    Set RSC auto report with RSRP value smaller than threshold and CGI not triggered    ue_id=12    pci=1
    Set RSC auto report with RSRP value bigger than threshold and RSC CGI triggered    ue_id=13    pci=1
    MO is created for CGI1
    Set RSC auto report with RSRQ value smaller than threshold and CGI not triggered    ue_id=14    pci=2
    Set RSC auto report with RSRQ value bigger than threshold and RSC CGI triggered    ue_id=15    pci=2
    MO is created for CGI2
    [teardown]    restore threshold config


CB005825-A-B6-g_ET_09_01_RSC fail or not trigger due to UE activity indication received
    [Tags]
    [Documentation]
    ...    precondition: no LNADJN LNADJNL and LNRELN MO existed, make [2036672 1] tobeverified
    ...    attach UE11, wait ANRInactivitytimer expired, RSC triggered, start traffic, RSC is interrupted, cleanup is done
    ...    stop traffic and wait ANRInactivitytimer expired again, ANR can't be triggered for
    ...    only onetime ANR can be triggered for one UE
    ...    attach UE12, start traffic, wait ANRInactivitytimer expired, RSC not triggered
    ...    stop traffic and wait ANRInactivitytimer expired again, ANR is triggered for
    ...    only onetime ANR can be triggered for one UE
    Report B2 to make tuple tobeverified
    RSC failed for UE activity indication received    ue_id=11
    ANR can not be triggered again    ue_id=11
    RSC not triggered for for UE activity indication received    ue_id=12
    ANR can be triggered again    ue_id=12
    [teardown]    Release All UEs and delete created MO

CB005825-A-B6-e_ET_11_01_Clean-up sub-procedure after RSC failed idle mode load balancing measurement before UE release
    [Tags]
    [Documentation]
    ...    precondition: no LNADJN LNADJNL and LNRELN MO existed, make [2036672 1] tobeverified, LTE2051 is active
    ...    attach UE11, wait ANRInactivitytimer expired, RSC triggered, not send RSC report until
    ...    wait anrNrCoverageConfirmTimer expired, RSC failed, cleanup is triggered and A4 is activated
    ...    send valid A4 report, UE released with IMLB frequency info
    Open IMLB and change inactivity timer
    report B2 to make tuple tobeverified
    Attach UE and make RSC failed for guardtimer expired and check A4 is activated after cleanup    ue_id=11
    Send A4 MR and check UE released with A4 frequency    ue_id=11
    [teardown]    Release All UEs and restore inactivity timer

CB005825-SR-A-B6-a_ET_07_01_verification not start with manual created LNRELN with anrNrNbrHoRelVerifyPeriod set to 0
    [Tags]
    [Documentation]
    ...    precondition: anrNrNbrHoRelVerifyPeriod=0
    ...    LNADJN-0/LNADJNL-0 LNRELN-0 for CGI1 is created
    ...    report 6 times B2 to make tuple tobeverified
    ...    attach UE15 to verify tuple and MR report CGI1+CGI2, CGI1 MO keep, CGI2 MO created
    ...    tuple is verified and attach UE12, RSC not triggered
    ...    remove and create LNRELN
    ...    send valid A4 report, UE released with IMLB frequency info
    Change anrNrNbrHoRelVerifyPeriod to be 0 and create MO
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=15
    MO is created and parameter is correct
    Ue attach and check RSC not triggered    ue_id=12
    Remove and add LNRELN back
    Ue attach and check RSC not triggered    ue_id=13
    Report B2 to make tuple tobeverified
#    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=14
    Ue attach and check RSC not triggered    ue_id=14
    MO is not change and parameter is correct
    [teardown]    Release All UEs and change inactivity timer
CB005825-A-B6-f_ET_13_01_eNB buffer NR ANR inactivity indication when sgNB Addition Modification procedure is ongoing with CA
    [Tags]
    [Documentation]
    ...    tobeverified status should check btslog,can search tobeverified
    ...    buffer status also can be checked from btslog,can search buffer, also can search ANR to check
    Delta Commission Parameters    ${delete_all_MOCs_except_LNADJN}
    report B2 to make tuple tobeverified    ue_id=1    pci=6    narfcn=${NRARFCN630000}
    attach UE and add QCI-8 to support ENDC    ue_id=11
    Trigger ENDC addition failed and reportCGI poped    ue_id=11    pci=6
    attach UE and add QCI-8 to support ENDC    ue_id=12
    trigger sgnb released but ANR not poped due to cleaned by traffic
    attach UE and add QCI-8 to support ENDC    ue_id=13
    trigger sgnb modification fail then sgnb release and RSC poped
    check object created
    Release All UEs

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
    ...     - {qci: 8, pdn: 1}
    Update Yaml    UEs/UE_sets/11     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/12     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/13     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/14     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/15     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/16     bearer: bearer_set_2

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
    ...        - {id: 31, technology: lte, tac: 33, pci: '2:1', eci: '0x0000A1F', earfcn: '1400:19400', bw: 20}

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
    ...      - ${gnb7_cell6}

UE attach to cell1
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    ${ret1}=    Execute Uex Command    ${V_1}

UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

Set RSC auto report with value smaller than threshold
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${NRARFCN2036667} nrsrp=6 nrsrq=6 nsinr=31 strongest=nr5g
    Run Uex Command    ${cmd}

Set RSC auto report with RSRP RSRQ value smaller than threshold and CGI not triggered
    [Arguments]    ${ue_id}=1    ${pci}=1
    Set RSC auto report with value smaller than threshold    ue_id=${ue_id}    pci=${pci}
    Attach UE and check RSC triggered and CGI not triggered    ue_id=${ue_id}    pci=${pci}

Attach UE and check RSC triggered and CGI not triggered
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and
    ...    (purpose eq 'reportStrongestCells')) as RSC_RRC
    ${noCGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci})) as CGI_RRC
    ${cleanup_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) and
    ...    (s-Measure eq 75) and (onDurationTimer eq "psf6")) as cleanup_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=RSC_RRC    overall_timeout=10
    Expect Message Will Not Occur
    ...    ${noCGI_RRC}
    ...    alias=noCGI_RRC    overall_timeout=10
    Expect message flow
    ...    ${cleanup_RRC}
    ...    alias=cleanup_RRC    overall_timeout=10
    Ue attach and wait for RSC    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RSC_RRC
    Flow Not Occurred For Message    alias=noCGI_RRC
    Flow Occurred As Expected    alias=cleanup_RRC
Ue attach and wait for RSC
    [Arguments]    ${ue_id}=1
    UE attach to cell1    ue_id=${ue_id}
    sleep    3s    #wait for RSC

set RSC CGI auto report
    [Arguments]    ${ue_id}=1    ${nrcell_id}=${nci-115969}    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nrcell_id} freq_band_list=258 tac=33
    Run Uex Command    ${cmd}

Trigger UE1 to send B2-NR for freq with PCI1
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${narfcn} amount=1

clean CB005825 verification list
    Block Cell1
    Unblock Cell1

Attach UE and check RSC CGI triggered as expected
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN2036667}    ${pci}=1
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci})) as CGI_RRC
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (purpose eq 'reportStrongestCells')) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=18
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC


report B2 to make 2 tuple pair tobeverified
    report B2 to make tuple tobeverified    pci=1    narfcn=${NRARFCN2036667}
    report B2 to make tuple tobeverified    pci=2    narfcn=${NRARFCN2036667}

report B2 to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=5
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    7
    Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    END
    UE detach    ue_id=${ue_id}

Trigger UE to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34

Case setup
    Common Test Setup And Start To Capture Logs
    clean CB005825 verification list

config only RSRP
    Delta Commission Parameters    ${deletersc_rsrq}

config only RSRQ
    Delta Commission Parameters    ${deletersc_rsrp_addrsrq}

Set RSC auto report with RSRP value smaller than threshold
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${NRARFCN2036667} nrsrp=2 nrsrq=22 nsinr=31 strongest=nr5g
    Run Uex Command    ${cmd}

Set RSC auto report with RSRP value bigger than threshold
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${NRARFCN2036667} nrsrp=20 nrsrq=2 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03|${nci-115970} tac=33
    ...    cgi_plmn_group cgi=262:04,262:01,262:02,262:05,262:06,262:09,262:12,262:10,262:13|${nci-115970}
    ...    tac=33 freq_band_list=258
    Run Uex Command    ${cmd}


Set RSC auto report with RSRQ value smaller than threshold
    [Arguments]    ${ue_id}=1      ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${NRARFCN2036667} nrsrp=20 nrsrq=2 nsinr=31 strongest=nr5g
    Run Uex Command    ${cmd}

Set RSC auto report with RSRQ value bigger than threshold
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${NRARFCN2036667} nrsrp=2 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:17|${nci-115970} tac=33
    ...    cgi_plmn_group cgi=262:16|${nci-115970}
    ...    tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

start traffic
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate
    ...    trf_data_start ue=${ue_id} dir=dl protocol=udp kbps=100
    Run Uex Command    ${cmd}

stop traffic
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate
    ...    trf_data_stop ue=${ue_id}
    Run Uex Command    ${cmd}

restore threshold config
    Release All UEs
    Delta Commission Parameters    ${restore_threshold}
    Common Test Teardown And Stop Capture Logs

Release All UEs and delete created MO
    Release All UEs
    Delta Commission Parameters    ${delete created MO}
    Common Test Teardown And Stop Capture Logs

Release All UEs and restore inactivity timer
    Release All UEs
    Delta Commission Parameters    ${restore_inactivity timer}
    Common Test Teardown And Stop Capture Logs

Release All UEs and change inactivity timer
    Release All UEs
    Delta Commission Parameters    ${change_inactivity_timer}
    Common Test Teardown And Stop Capture Logs

report A4
    [Arguments]    ${ue_id}=1
    Run Uex Command     ue_measurement_send id=${ue_id} event=A4 srsrp=40 srsrq=10 phycell_id=1 nrsrp=80 nrsrq=30

Set RSC auto report with RSRP value smaller than threshold and CGI not triggered
    [Arguments]    ${ue_id}=1    ${pci}=1
    config only RSRP
    Set RSC auto report with RSRP value smaller than threshold    ue_id=${ue_id}    pci=${pci}
    Attach UE and check RSC triggered and CGI not triggered    ue_id=${ue_id}    pci=${pci}

Set RSC auto report with RSRP value bigger than threshold and RSC CGI triggered
    [Arguments]    ${ue_id}=1    ${pci}=1
    Set RSC auto report with RSRP value bigger than threshold    ue_id=${ue_id}    pci=${pci}
    Attach UE and check RSC CGI triggered as expected    ue_id=${ue_id}    pci=${pci}

Set RSC auto report with RSRQ value smaller than threshold and CGI not triggered
    [Arguments]    ${ue_id}=1    ${pci}=1
    config only RSRQ
    Set RSC auto report with RSRQ value smaller than threshold    ue_id=${ue_id}    pci=${pci}
    Attach UE and check RSC triggered and CGI not triggered    ue_id=${ue_id}    pci=${pci}

Set RSC auto report with RSRQ value bigger than threshold and RSC CGI triggered
    [Arguments]    ${ue_id}=1    ${pci}=1
    Set RSC auto report with RSRQ value bigger than threshold    ue_id=${ue_id}    pci=${pci}
    Attach UE and check RSC CGI triggered as expected    ue_id=${ue_id}    pci=${pci}


Open IMLB and change inactivity timer
    Delta Commission Parameters    ${active_IMLB_change_inactivitytimer}

Attach UE and make RSC failed for guardtimer expired and check A4 is activated after cleanup
    [Arguments]    ${ue_id}=1
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and
    ...    (purpose eq 'reportStrongestCells')) as RSC_RRC
    ${A4_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (a4-Threshold contains (threshold-RSRP eq 0)) as A4_RRC
    ${noCGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq 1)) as CGI_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    ${A4_RRC}
    ...    alias=RSC_A4_RRC    overall_timeout=20
    Expect Message Will Not Occur
    ...    ${noCGI_RRC}
    ...    alias=noCGI_RRC    overall_timeout=12
    UE attach to cell1    ue_id=${ue_id}
    sleep    3s    #wait for RSC
    Flow Occurred As Expected    alias=RSC_A4_RRC
    Flow Not Occurred For Message    alias=noCGI_RRC

Send A4 MR and check UE released with A4 frequency
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (carrierFreq contains (1600)) as IMLB_RRC
    ...    alias=IMLB_RRC    overall_timeout=10
    report A4    ue_id=${ue_id}
    Flow Occurred As Expected    alias=IMLB_RRC

RSC failed for UE activity indication received
    [Arguments]    ${ue_id}=1
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and
    ...    (purpose eq 'reportStrongestCells')) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=RSC_RRC    overall_timeout=10
    Ue attach and wait for RSC     ue_id=${ue_id}
    Flow Occurred As Expected    alias=RSC_RRC
    Start traffic and check cleanup is done    ue_id=${ue_id}

Start traffic and check cleanup is done
    [Arguments]    ${ue_id}=1
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and
    ...    (cellForWhichToReportCGI-r15 eq 1)) as noCGI_RRC
    ${cleanup_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) and (s-Measure eq 75)
    ...    and (onDurationTimer eq "psf6")) as cleanup_RRC
    Expect message flow
    ...    ${cleanup_RRC}
    ...    alias=cleanup_RRC    overall_timeout=10
    Expect Message Will Not Occur
    ...    ${CGI_RRC}
    ...    alias=noCGI_RRC    overall_timeout=10
    start traffic      ue_id=${ue_id}
    Flow Not Occurred For Message    alias=noCGI_RRC
    Flow Occurred As Expected    alias=cleanup_RRC

ANR can not be triggered again
    [Arguments]    ${ue_id}=1
    ${noRSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (purpose eq 'reportStrongestCells')) as RSC_RRC
    Expect Message Will Not Occur
    ...    ${noRSC_RRC}
    ...    alias=noRSC_RRC    overall_timeout=10
    stop traffic    ue_id=${ue_id}
    Flow Not Occurred For Message    alias=noRSC_RRC

RSC not triggered for for UE activity indication received
    [Arguments]    ${ue_id}=1
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
    UE attach to cell1    ue_id=${ue_id}
    sleep    2s    #wait for traffic
    start traffic      ue_id=${ue_id}
    Flow Not Occurred For Message    alias=noRSC_RRC
    Flow Not Occurred For Message    alias=nocleanup_RRC

ANR can be triggered again
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN2036667}    ${pci}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and (purpose eq 'reportStrongestCells')) as RSC_RRC
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and (cellForWhichToReportCGI-r15 eq ${pci})) as CGI_RRC
    ...    alias=NRANR_RRC    overall_timeout=18
    stop traffic    ue_id=${ue_id}
    set RSC CGI auto report    ue_id=${ue_id}    pci=${pci}    nrarfcn=${nrarfcn}
    Flow Occurred As Expected    alias=NRANR_RRC
    Object Should Exist    ${LNRELN_CGI3}
    Object Should Exist    ${LNADJN_CGI1}
    Object Should Exist    ${LNADJNL_CGI3}

MO is created for CGI1
    Object Should Exist    ${LNRELN_CGI1}
    Object Should Exist    ${LNADJN_CGI1}
    Object Should Exist    ${LNADJNL_CGI1}

MO is created for CGI2
    Object Should Exist    ${LNRELN_CGI2}
    Object Should Exist    ${LNADJN_CGI2}
    Object Should Exist    ${LNADJNL_CGI2}

UE attached and check RSC and CGI triggered and cleanup is done
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
    set RSC CGI auto report with multiple plmn    ue_id=${ue_id}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC

Ue attach and check RSC not triggered
    [Arguments]    ${ue_id}=1
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
    UE attach to cell1    ue_id=${ue_id}
    Flow Not Occurred For Message    alias=noRSC_RRC
    Flow Not Occurred For Message    alias=nocleanup_RRC

change anrNrNbrHoRelVerifyPeriod to be 0
    Delta Commission Parameters    ${anrNrNbrHoRelVerifyPeriod_0}

Create LNADJN and LNADJNL for CGI1
    @{LNADJN_LNADJNL}    Combine Lists    ${Manual_Created_LNADJN_CGI1}    ${Manual_Created_LNADJNL_CGI1}
    Delta Commission Parameters    ${LNADJN_LNADJNL}

Create LNRELN for CGI1
    Delta Commission Parameters    ${Manual_Created_LNRELN_CGI1}

set RSC CGI auto report with multiple plmn
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:04|${nci-115969} tac=33
    ...    cgi_plmn_group cgi=262:03|${nci-115970} tac=33
    ...    freq_band_list=258
    Run Uex Command    ${cmd}

MO is created and parameter is correct
    Object Should Exist    ${LNRELN_CGI2_created_case7_2}
    Object Should Exist    ${LNADJNL_CGI2_created_case7}
    Object Should Exist    ${Manual_Created_CGI1}

MO is not change and parameter is correct
    Object Should Exist    ${LNRELN_CGI2_created_case7_3}
    Object Should Exist    ${LNADJNL_CGI2_created_case7}
    Object Should Exist    ${Manual_Created_CGI1}

Remove and add LNRELN back
    delete CGI1 and CGI2 LNADJNL and LNRELN
    Create CGI1 and CGI2 LNADJNL and LNRELN

delete CGI1 and CGI2 LNADJNL and LNRELN
    Delta Commission Parameters    ${delete_LNADJNL_LNRELN}

Create CGI1 and CGI2 LNADJNL and LNRELN
    Delta Commission Parameters    ${create_LNADJNL_LNRELN}

Change anrNrNbrHoRelVerifyPeriod to be 0 and create MO
    change anrNrNbrHoRelVerifyPeriod to be 0
    Create LNADJN and LNADJNL for CGI1
    report B2 to make tuple tobeverified
#    Create LNRELN for CGI1

attach UE and add QCI-8 to support ENDC
    [Arguments]    ${ue_id}=11
    ${B1NR_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (eventB1-NR-r15 is present)
    Expect message flow
    ...    ${B1NR_messsage}
    ...    alias=B1NR_ACT    overall_timeout=30
    UE attach to cell1    ue_id=${ue_id}
    Execute Uex Command    bearer_add ue=${ue_id} qci=8
    Flow Occurred As Expected    alias=B1NR_ACT

Trigger ENDC addition failed and reportCGI poped
    [Arguments]    ${ue_id}=11    ${pci}=6
    ${CGI2_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN630000})
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI')) as CGI_RRC
    ${cleanup2_message}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) ) as clean_RRC
    Expect message flow
    ...    ${CGI2_messsage}
    ...    ${cleanup2_message}
    ...    alias=REPORTCGI_POPED    overall_timeout=30
    Execute Egate Command    enb_timer T_SgnbAdditionReqAckDelay=11000 T_DC_Overall=15000
    Execute Uex Command    ue_measurement_send id=11 event=B1_NR phycell_id=6 narfcn=${NRARFCN630000} nrsrp=25 nrsrq=22
    Flow Occurred As Expected    alias=REPORTCGI_POPED
    Execute Egate Command    link_x2_management_abnormal_cases id=7 partner=1 reset
    Execute Egate Command    enb_timer T_SgnbAdditionReqAckDelay=0 T_DC_Overall=15000

trigger sgnb released but ANR not poped due to cleaned by traffic
    [Arguments]    ${ue_id}=12    ${pci}=6
    trigger ENDC setup
    ${noRSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN630000})
    ...    and (purpose eq 'reportStrongestCells')) as RSC_RRC
    Expect message flow
    ...    ${noRSC_RRC}
    ...    alias=noRSC2_RRC    overall_timeout=20
    Run Uex Command    ue_rrc_reconf_param id=${ue_id} nth=1 delay=3000
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} by=gnb cause=RN_count_reaches_max_value    pass_regexp=SgNB Modification is successful
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp bps=5000
    sleep    ${wait_traffic_take_effect}
    Execute Uex Command    bearer_del ue=${ue_id} qci=8
    Flow Not Occurred For Message    alias=noRSC2_RRC

trigger ENDC setup
    [Arguments]    ${ue_id}=12    ${pci}=6
    ${endc_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17))
    Expect message flow
    ...    ${endc_messsage}
    ...    alias=ENDC_DONE    overall_timeout=10
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${pci} narfcn=${NRARFCN630000} nrsrp=25 nrsrq=22
    Flow Occurred As Expected    alias=ENDC_DONE

trigger sgnb modification fail then sgnb release and RSC poped
    [Arguments]    ${ue_id}=13    ${pci}=6
    trigger ANR timer when ENDC setup
    ${RSC3_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN630000})
    ...    and (purpose eq 'reportStrongestCells') and (s-Measure eq 0)) as RSC_RRC
    ${CGI3_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN630000})
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI') and (s-Measure eq 75)) as CGI_RRC
    ${cleanup3_message}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32))) as clean_RRC
    Expect message flow
    ...    ${RSC3_messsage}
    ...    ${CGI3_messsage}
    ...    ${cleanup3_message}
    ...    alias=NRANR3_RRC    overall_timeout=30
    trigger sgnb refuse and set RSC auto report
    Execute Egate Command    enb_ue_dc_release ue=${ue_id} by=gnb cause=RN_user_inactivity    pass_regexp=UEContextRelease
    Flow Occurred As Expected    alias=NRANR3_RRC
    Execute Egate Command    link_x2_management_abnormal_cases id=7 partner=1 reset

trigger ANR timer when ENDC setup
    [Arguments]    ${ue_id}=13    ${pci}=6
    Execute Egate Command    enb_timer T_SgnbAdditionReqAckDelay=5000 T_DC_Overall=15000
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${pci} narfcn=${NRARFCN630000} nrsrp=25 nrsrq=22
    sleep    ${wait_anrNrInactivityTimer_timeout}

trigger sgnb refuse and set RSC auto report
    [Arguments]    ${ue_id}=13    ${pci}=6
    Execute Egate Command    gnb_endc_param id=7 include_in_sgnb_modification_required=pdcp_change_indication
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} by=gnb cause=RN_count_reaches_max_value    pass_regexp=SgNBModificationRefuse
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${NRARFCN630000} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:06,262:07|${nci-115974} tac=33
    ...    freq_band_list=78
    Run Uex Command    ${cmd}
check object created
    Object Should Exist    ${LNADJN511_LNADJNL11_LNRELN255}