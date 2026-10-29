*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Case setup
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS24R1    team-CN3ET    owner-carol.an
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
...    ${TUecRadAnrNrNbrHoRelVerifyPeriod}=50
...    ${TUecRadAnrNrNbrHoFail2H}=30

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
${GSCN22325}    22325
${TUecRadAnrNrNbrHoRelVerifyPeriod}    0x1300EE
${TUecRadAnrNrNbrHoFail2H}    0x1300EF

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tS1eRABModInd=50
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
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
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=629984    #${GSCN22325}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=30kHz
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
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
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
...    LNCEL:inactivityTimer=1000
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
${nci-115969}    0x1C501
${nci-115970}    0x1C502
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
...    LNCEL-1:measQuantityNr=RSRP
...    LNCEL-1:t304InterRATN=500ms
...    LNCEL-1:a2TimeToTriggerActNRMeas=320ms
...    LNCEL-1:threshold2NR=25
...    LNCEL-1:hysThreshold2NR=0
...    @{CB007742}
...    LNBTS:actUeBasedAnrNrHo=true
...    LNBTS:actX2gNB128=true
...    LNBTS:maxNumNrCellgNB=1024
...    LNBTS:maxNumNrCell=32768
...    @{CB005825_ANR}
...    LNCEL-1:actDrx=true
...    LNBTS/NRMEASDPR-0:measGapEnabledNRMeas=FR1AndFR2

@{CB005825_ANR}
...    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=72
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS/ANR-0:consec5gHoFailThres=15
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=true
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=All|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=22|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=${NRARFCN2036667}|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=enabled|paramPlmnId=0

...    LNBTS-1/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamList:carrierFreqNrCell=629984|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamList:gNBIdLength=22|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamList:frqNrCarSelect=All|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamList:paramMeasConfId=1|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=enabled|paramPlmnId=1

...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=56|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-10|paramMeasConfId=1
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
...    LNBTS/MODPR-0:freqLayListPsHoNR=${NRARFCN2036667},629984
...    LNBTS/MODPR-0:freqLayListPsHoNRVoLte=${NRARFCN2036667},629984
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
...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=100000
...    LNCEL-1/LNHON-1:nrPciHoNbrCounterDecay=1000
...    LNCEL-1/LNHON-2:carrierFreqNr=629984
...    LNCEL-1/LNHON-2:freqBandIndicatorListNr=78
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

@{Online_ChParams_caseb1}
...    LNCEL-1:t304InterRAT=500ms
...    LNCEL-1/SIB-0:t311=10000ms
...    LNCEL-1/SIB-0:t301=2000ms
...    LNCEL-1/SDRX-0:drxSmartProfile3:drxLongCycle=80ms
...    LNBTS/ANR-0:consec5gHoFailThres=0
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS-1:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL:actPeriodicB1NRMeas=disabled
...    @{addLNRELN0_noLNADJNL_CGI1}

@{addLNRELN0_noLNADJNL_CGI1}
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=enabled|paramPlmnId=0
...    LNCEL-1/LNRELN-0:cellIdentity=114719
...    LNCEL-1/LNRELN-0:psHoAllowed=allowed
...    LNCEL-1/LNRELN-0:removeAllowed=true
...    LNCEL-1/LNRELN-0:plmnId:mcc=262
...    LNCEL-1/LNRELN-0:plmnId:mnc=3
...    LNCEL-1/LNRELN-0:plmnId:mncLength=2

@{restore_caseb1}
...    LNCEL-1/SIB-0:t311=30000ms
...    LNBTS/ANR-0:consec5gHoFailThres=15
...    LNBTS-1:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-0
...    delete:LNCEL-1/LNRELN-254
...    delete:LNADJN-511

@{addLNRELN0_CGI1}
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=enabled|paramPlmnId=0
...    LNCEL-1/LNRELN-0:cellIdentity=115969
...    LNCEL-1/LNRELN-0:psHoAllowed=allowed
...    LNCEL-1/LNRELN-0:removeAllowed=true
...    LNCEL-1/LNRELN-0:plmnId:mcc=262
...    LNCEL-1/LNRELN-0:plmnId:mnc=3
...    LNCEL-1/LNRELN-0:plmnId:mncLength=2
...    LNADJN-1:arfcnValueNR=2036672
...    LNADJN-1:multiFrequencyBandList=258
...    LNADJN-1:physCellIdNr=1
...    LNADJN-1/LNADJNL-11:cellIdentity=115969
...    LNADJN-1/LNADJNL-11:gnbIdLength=22
...    LNADJN-1/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-1/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-1/LNADJNL-11:plmnIdList:mncLength=2

@{deleteCreatedMO}
...    delete:LNCEL-1/LNRELN-255

@{restore_caseb2}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-511
...    delete:LNCEL-1/LNRELN-0
...    delete:LNADJN-1

@{restore_caseb4}
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=10min
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-0
...    delete:LNADJN-511
...    delete:LNADJN-1

@{Online_ChParams_caseb4}
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=2500
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=enabled|paramPlmnId=0
...    @{addLNRELN0_CGI1}

@{Online_anrNrNbrHoRelVerifyPeriod}
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=0min

@{Online_ChParams_caseb7}
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=0min
...    LNBTS-1/ANR-0:consec5gHoFailThres=2
...    LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=1
...    @{LNADJN-PCI7}

@{LNADJN-PCI7}
...    LNADJN-2:arfcnValueNR=629984
...    LNADJN-2:multiFrequencyBandList=78
...    LNADJN-2:physCellIdNr=5
...    LNADJN-2/LNADJNL-1:cellIdentity=115988
...    LNADJN-2/LNADJNL-1:gnbIdLength=22
...    LNADJN-2/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-1:gNBplmnId:mnc=5
...    LNADJN-2/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-2/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-2/LNADJNL-1:plmnIdList:mnc=5
...    LNADJN-2/LNADJNL-1:plmnIdList:mncLength=2
...    LNADJN-2/LNADJNL-11:cellIdentity=114719
...    LNADJN-2/LNADJNL-11:gnbIdLength=22
...    LNADJN-2/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-2/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-2/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-2/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-2/LNADJNL-11:plmnIdList:mncLength=2

@{restore_caseb7}
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS/ANR-0:consec5gHoFailThres=15
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-254
...    delete:LNADJN-511
...    delete:LNADJN-2

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
...    {id: 75, technology: nr , tac: 33, pci: '1:2', nrci: '0x01F', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}',
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

@{LNADJNL_CGI3a2}
...    LNADJN-510/LNADJNL-11:cellIdentity=115970
...    LNADJN-510/LNADJNL-11:gnbIdLength=22
...    LNADJN-510/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-510/LNADJNL-11:gNBplmnId:mnc=4
...    LNADJN-510/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-510/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-510/LNADJNL-11:plmnIdList:mcc=262|mnc=4

@{LNADJNL1011_CGI3a2}
...    LNADJN-1/LNADJNL-10:cellIdentity=115970
...    LNADJN-1/LNADJNL-10:gnbIdLength=22
...    LNADJN-1/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-10:gNBplmnId:mnc=4
...    LNADJN-1/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-10:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-10:plmnIdList:mcc=262|mnc=4

@{LNADJNL_CGI1}
...    LNADJN-511/LNADJNL-11:cellIdentity=114719
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=3

@{LNADJNL_CGI2_4}
...    LNADJN-1/LNADJNL-10:cellIdentity=115970
...    LNADJN-1/LNADJNL-10:gnbIdLength=22
...    LNADJN-1/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-10:gNBplmnId:mnc=4
...    LNADJN-1/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-10:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-10:plmnIdList:mcc=262|mnc=4

@{LNADJNL_CGI4}
...    LNADJN-1/LNADJNL-10:cellIdentity=115970
...    LNADJN-1/LNADJNL-10:gnbIdLength=22
...    LNADJN-1/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-10:gNBplmnId:mnc=4
...    LNADJN-1/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-10:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-10:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-10:plmnIdList:mnc=4
...    LNADJN-1/LNADJNL-10:plmnIdList:mncLength=2

@{LNADJNL_CGI3}
...    LNADJN-1/LNADJNL-10:cellIdentity=114719
...    LNADJN-1/LNADJNL-10:gnbIdLength=22
...    LNADJN-1/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-10:gNBplmnId:mnc=3
...    LNADJN-1/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-10:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-10:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-10:plmnIdList:mnc=3
...    LNADJN-1/LNADJNL-10:plmnIdList:mncLength=2

@{LNADJNL11_CGI3}
...    LNADJN-2/LNADJNL-11:cellIdentity=114719
...    LNADJN-2/LNADJNL-11:gnbIdLength=22
...    LNADJN-2/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-2/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-2/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-2/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-2/LNADJNL-11:plmnIdList:mncLength=2

@{LNADJNL11_CGI4}
...    LNADJN-511/LNADJNL-11:cellIdentity=115970
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=3
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2

@{LNRELN_CGI3a2}
...    LNCEL-1/LNRELN-255:cellIdentity=115969
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

@{LNRELN_CGI1}
...    LNCEL-1/LNRELN-0:cellIdentity=114719
...    LNCEL-1/LNRELN-0:psHoAllowed=allowed
...    LNCEL-1/LNRELN-0:removeAllowed=true
...    LNCEL-1/LNRELN-0:plmnId:mcc=262
...    LNCEL-1/LNRELN-0:plmnId:mnc=3
...    LNCEL-1/LNRELN-0:plmnId:mncLength=2

@{LNRELN255_CGI1}
...    LNCEL-1/LNRELN-255:cellIdentity=114719
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNRELN_CGI1_69}
...    LNCEL-1/LNRELN-0:cellIdentity=115969
...    LNCEL-1/LNRELN-0:psHoAllowed=allowed
...    LNCEL-1/LNRELN-0:removeAllowed=true
...    LNCEL-1/LNRELN-0:plmnId:mcc=262
...    LNCEL-1/LNRELN-0:plmnId:mnc=3
...    LNCEL-1/LNRELN-0:plmnId:mncLength=2

@{LNRELN_CGI2}
...    LNCEL-1/LNRELN-255:cellIdentity=115970
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=4
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNRELN_CGI2_254}
...    LNCEL-1/LNRELN-254:cellIdentity=115970
...    LNCEL-1/LNRELN-254:psHoAllowed=allowed
...    LNCEL-1/LNRELN-254:removeAllowed=true
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=4
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2

@{LNRELN_CGI2_254_70}
...    LNCEL-1/LNRELN-254:plmnId:mcc=262

@{LNRELN_CGI2_255_70}
...    LNCEL-1/LNRELN-255:cellIdentity=115970
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNRELN255_CGI4}
...    LNCEL-1/LNRELN-255:cellIdentity=115970
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=4
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

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

${wTUecRadAnrNrNbrHoFail2H}    15
${wTS1RELOCoverallAndFail2H}    25
${WanrNrNbrHoRelVerifyPeriod}    20
${wALLanrNrNbrHoRelVerifyPeriod}    60
${wReestab_Fail}    6

*** Test Cases ***
CB005825-SR-A-B6-b_ET_01_01_re-verification with manual created LNRELN without LNADJN-L can be located after anrNrNbrHoRelVerifyPeriod
    [Tags]
    [Documentation]
    ...    CB005825-SR-A-B6-b_ET_01_01_re-verification with manual created LNRELN without LNADJN-L can be located after anrNrNbrHoRelVerifyPeriod
    ...    elapsed and not trigger with consec5gHoFailThres is 0 but HO failed with TS1RELOCoverall elapsed
    Online change caseb1 config
    UE 1-6 send B2-NR reports PCI1
    Attach UE Check RSC and CGI delay should trigger    ue_id=7    delay=500    nrcell_id=${nci-114719}
    check case1 moc1
    Attach UE and prepare tuple-entry tobeverified
    Attach UE Check RSC and CGI CGI2 should trigger     ue_id=8    delay=500
    Object Should Exist    ${LNRELN_CGI2}
    Object Should Exist    ${LNADJNL_CGI3a2}
    [Teardown]    caseb1_teardown

CB005825-SR-A-B6-b_ET_04_01_re-verification not start with manual and ANR created LNRELN for one tuple-entry with actLnadjnGnbPlmnId enable
    [Tags]
    [Documentation]
    ...    CB005825-SR-A-B6-b_ET_04_01_re-verification not start with manual and ANR created LNRELN for one tuple-entry with actLnadjnGnbPlmnId
    ...    enable and anrNrNbrHoRelVerifyPeriod set to 0
    Online change caseb4 config
    UE 1-6 send B2-NR reports PCI1
    Attach UE Check RSC and CGI 2CGI should trigger     ue_id=7    delay=500
    Object Should Exist    ${LNADJNL_CGI2_4}
    Object Should Exist    ${LNADJNL_CGI3}
    Object Should Exist    ${LNRELN_CGI1_69}
    Object Should Exist    ${LNRELN_CGI2}
    Online change anrNrNbrHoRelVerifyPeriod config
    sleep    ${wALLanrNrNbrHoRelVerifyPeriod}    #anrNrNbrHoRelVerifyPeriod elapsed
    Trigger UE to send B2-NR 1 time    ue_id=8
    Attach UE Check RSC and CGI delay should not trigger     ue_id=9    delay=500
    Object Should not Exist    ${LNRELN_CGI2_254}
    [Teardown]    caseb4_teardown

CB005825-SR-A-B6-b_ET_07_01_re-verification with ANR created LNRELN after consec5gHoFailThres and two hours reached due to reestablish to source
    [Tags]
    [Documentation]
    ...    CB005825-SR-A-B6-b_ET_07_01_re-verification with ANR created LNRELN after consec5gHoFailThres and two hours reached due to reestablish
    ...    to source cell after RRC-MobilityFromEUTRACommand sent to UE in NR HO failed
    Online change caseb7 config and set
    UE 1-6 send B2-NR reports PCI 629984
    Attach UE Check RSC and CGI PLMN1 should trigger    ue_id=11    nrcell_id=${nci-114719}
    Object Should Exist    ${LNRELN255_CGI1}
    Object Should Exist    ${LNADJNL11_CGI3}
    sleep    10s
    Reestablish to source cell
    Attach UE Check RSC and CGI PLMN1 should trigger    ue_id=12    nrcell_id=${nci-115970}
    Object Should Exist    ${LNADJNL11_CGI4}
    Object Should Exist    ${LNRELN_CGI2_255_70}
    [Teardown]    caseb7_teardown

CB005825-SR-A-B6-b_ET_02_01_re-verification with manual created LNRELN with LNADJN-L can be located with actLnadjnGnbPlmnId enable after
    [Tags]
    [Documentation]
    ...    CB005825-SR-A-B6-b_ET_02_01_re-verification with manual created LNRELN with LNADJN-L can be located with actLnadjnGnbPlmnId
    ...    enable after anrNrNbrHoRelVerifyPeriod elapsed
    Online change manuAddLNRELN config
    UE 1-6 send B2-NR reports PCI1
    Attach UE Check RSC and CGI 2CGI should trigger case2     ue_id=7    delay=500
    check case2 moc1
    Online change manuDelLNRELN config
    sleep    ${wALLanrNrNbrHoRelVerifyPeriod}    #anrNrNbrHoRelVerifyPeriod elapsed
    Trigger UE to send B2-NR 1 time    ue_id=8
    Attach UE Check RSC and CGI CGI2 should trigger     ue_id=9    delay=500
    Object Should Exist    ${LNADJNL1011_CGI3a2}
    Object Should Exist    ${LNRELN255_CGI4}
    Object Should not Exist    ${LNRELN_CGI2_254_70}
    [Teardown]    caseb2_teardown

*** Keywords ***
check case1 moc1
    Object Should Exist    ${LNRELN_CGI1}
    Object Should Exist    ${LNADJNL_CGI1}
    Object Should not Exist    ${LNADJNL_CGI2}
    Object Should not Exist    ${LNRELN_CGI3a2}
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    Execute Egate Command    mme_timer T_UeCtxReleaseCommandDelay=20000

check case2 moc1
    Object Should Exist    ${LNADJNL_CGI3}
    Object Should Exist    ${LNRELN_CGI1_69}
    Object Should Exist    ${LNRELN255_CGI4}
    Object Should Exist    ${LNADJNL_CGI4}

Online change caseb7 config and set
    Online change caseb7 config
    Execute Egate Command    link_x2_management_abnormal_cases id=7 partner=1 reset
    Execute Egate Command    enb_timer T_SgnbAdditionReqAckDelay=0 T_DC_Prep=8000 T_DC_Overall=15000
    Execute Egate Command    gnb_endc_param id=7 include_in_sgnb_modification_required=none

Set RSC and CGI auto report with PLMN1
    [Arguments]    ${ue_id}=1    ${nrcell_id}=${nci-114719}
    ${cmd11}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send narfcn=629984
    ...    phycell_id=5 nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi_plmn_group cgi=262:03|${nrcell_id} freq_band_list=78 tac=33
    Execute Uex Command    ${cmd11}

Attach UE Check RSC and CGI PLMN1 should trigger
    [Arguments]    ${ue_id}=1    ${nrcell_id}=${nci-114719}
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq 629984) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=NRRSC_RRC    overall_timeout=16
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=noB1_RRC    overall_timeout=16
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq 629984)
    ...    and (cellForWhichToReportCGI-r15 eq 5) and (purpose eq 'reportCGI') and (s-Measure eq 75) and (onDurationTimer eq "psf10")) as CGI_RRC
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=CGI_RRC    overall_timeout=16
    Set RSC and CGI auto report with PLMN1    ue_id=${ue_id}    nrcell_id=${nrcell_id}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRRSC_RRC
    Flow Occurred As Expected    alias=CGI_RRC
    Flow Not Occurred For Message    alias=noB1_RRC

Attach UE and Trigger A2
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    UE attach to cell1    ue_id=1
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=1

Reestablish to source cell
    Expect Message Flow
    ...    MME_1:S1AP_HandoverCancel (Cause contains (radioNetwork eq "unspecified"))
    ...    alias=Reestab_Fail    overall_timeout=20
    attach UE and Trigger A2
    Run Uex Command    ue_rrc_mobility_from_eutra_param id=1 nth=1 action=reestablish cell=1 cause=handoverFailure
    Execute Uex Command    ue_measurement_send id=1 event=B2_NR phycell_id=5 nrsrp=97 srsrp=0 nsinr=20 narfcn=629984 amount=1
    Flow Occurred As Expected    alias=Reestab_Fail
    sleep    ${wReestab_Fail}
    Run Uex Command    ue_rrc_mobility_from_eutra_param id=1 nth=1 action=reestablish cell=1 cause=handoverFailure
    Execute Uex Command    ue_measurement_send id=1 event=B2_NR phycell_id=5 nrsrp=97 srsrp=0 nsinr=20 narfcn=629984 amount=1
    Flow Occurred As Expected    alias=Reestab_Fail
    sleep    ${wReestab_Fail}
    
Trigger UE to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34

set RSC CGI 2CGI report and attach UE
    [Arguments]    ${ue_id}=1    ${delay}=500    ${nrcell_id2}=${nci-115969}
    Set RSC and CGI auto report with 2CGI    ue_id=${ue_id}    nrcell_id2=${nrcell_id2}    nrsrp=58    nrsrq=88
    Set CGI rrc report delay time    ue_id=${ue_id}    delay=${delay}
    UE attach to cell1    ue_id=${ue_id}

Attach UE Check RSC and CGI 2CGI should trigger case2
    [Arguments]    ${ue_id}=1    ${delay}=500    ${nrcell_id2}=${nci-115969}
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=NRRSC_RRC    overall_timeout=16
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=noB1_RRC    overall_timeout=16
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq 1) and (purpose eq 'reportCGI') and (s-Measure eq 75) and (onDurationTimer eq "psf10")) as CGI_RRC
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=CGI_RRC    overall_timeout=16
    set RSC CGI 2CGI report and attach UE    ue_id=${ue_id}    delay=${delay}    nrcell_id2=${nrcell_id2}
    Flow Occurred As Expected    alias=NRRSC_RRC
    Flow Not Occurred For Message    alias=noB1_RRC
    Flow Occurred As Expected    alias=CGI_RRC

Trigger UE to send B2-NR 1 time
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=5
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    sleep    2    #waite B2 RRC complete

Set RSC and CGI auto report with 2CGI
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrcell_id2}=${nci-115969}    ${nrarfcn}=${NRARFCN2036667}    ${nrsrp}=25    ${nrsrq}=22
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${NRARFCN2036667} nrsrp=${nrsrp} nrsrq=${nrsrq} nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03|${nrcell_id2} tac=33
    ...    cgi_plmn_group cgi=262:04|${nci-115970}
    ...    tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

Set RSC and CGI auto report with CGI2
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrcell_id2}=${nci-115970}    ${nrarfcn}=${NRARFCN2036667}    ${nrsrp}=25    ${nrsrq}=22
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${NRARFCN2036667} nrsrp=${nrsrp} nrsrq=${nrsrq} nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:04|${nrcell_id2}
    ...    tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

Attach UE Check RSC and CGI 2CGI should trigger
    [Arguments]    ${ue_id}=1    ${delay}=500
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=NRRSC_RRC    overall_timeout=16
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=noB1_RRC    overall_timeout=16
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq 1) and (purpose eq 'reportCGI') and (s-Measure eq 75) and (onDurationTimer eq "psf10")) as CGI_RRC
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=CGI_RRC    overall_timeout=16
    set RSC CGI 2CGI report and attach UE    ue_id=${ue_id}    delay=${delay}
    Flow Occurred As Expected    alias=NRRSC_RRC
    Flow Not Occurred For Message    alias=noB1_RRC
    Flow Occurred As Expected    alias=CGI_RRC

Set RSC and CGI2 auto report
    [Arguments]    ${ue_id}=1    ${delay}=500    ${nrcell_id2}=${nci-115970}
    Set RSC and CGI auto report with CGI2    ue_id=${ue_id}    nrcell_id2=${nrcell_id2}    nrsrp=58    nrsrq=88
    Set CGI rrc report delay time    ue_id=${ue_id}    delay=${delay}

Attach UE Check RSC and CGI CGI2 should trigger
    [Arguments]    ${ue_id}=1    ${delay}=500    ${nrcell_id2}=${nci-115970}
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=NRRSC_RRC    overall_timeout=16
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=noB1_RRC    overall_timeout=16
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq 1) and (purpose eq 'reportCGI') and (s-Measure eq 75) and (onDurationTimer eq "psf10")) as CGI_RRC
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=CGI_RRC    overall_timeout=16
    Set RSC and CGI2 auto report    ue_id=${ue_id}    delay=${delay}    nrcell_id2=${nrcell_id2}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRRSC_RRC
    Flow Not Occurred For Message    alias=noB1_RRC
    Flow Occurred As Expected    alias=CGI_RRC

Online change caseb1 config
    Delta Commission Parameters    ${Online_ChParams_caseb1}

Online change manuAddLNRELN config
    Delta Commission Parameters    ${addLNRELN0_CGI1}

Online change manuDelLNRELN config
    Delta Commission Parameters    ${deleteCreatedMO}

Online change caseb4 config
    Delta Commission Parameters    ${Online_ChParams_caseb4}

Online change anrNrNbrHoRelVerifyPeriod config
    Delta Commission Parameters    ${Online_anrNrNbrHoRelVerifyPeriod}

Online change caseb7 config
    Delta Commission Parameters    ${Online_ChParams_caseb7}

caseb1_teardown
    Execute Egate Command    mme_timer reset
    Release All UEs
    Delta Commission Parameters    ${restore_caseb1}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

caseb2_teardown
    Execute Egate Command    mme_timer reset
    Release All UEs
    Delta Commission Parameters    ${restore_caseb2}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

caseb4_teardown
    Release All UEs
    Delta Commission Parameters    ${restore_caseb4}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

caseb7_teardown
    Release All UEs
    Delta Commission Parameters    ${restore_caseb7}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

UE 1-6 send B2-NR reports PCI1
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    FOR    ${ue_id}    IN RANGE    1    7
        report B2 to make tuple tobeverified    ue_id=${ue_id}    pci=1    narfcn=${NRARFCN2036667}
    END

UE 1-6 send B2-NR reports PCI 629984
    FOR    ${ue_id}    IN RANGE    1    7
        report B2 to make tuple tobeverified    ue_id=${ue_id}    pci=5    narfcn=629984
    END

Set CGI rrc report delay time
    [Arguments]    ${ue_id}=1    ${delay}=8000
    ${cmd}    catenate
    ...     ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportCGI action=delay_next_msg delay=${delay} next_msg=measurementReport
    Run Uex Command    ${cmd}

set RSC CGI auto report and delay
    [Arguments]    ${ue_id}=1    ${delay}=8000    ${nrcell_id}=${nci-115969}
    set RSC CGI auto report    ue_id=${ue_id}    nrcell_id=${nrcell_id}    nrsrp=58    nrsrq=88
    Set CGI rrc report delay time    ue_id=${ue_id}    delay=${delay}

Attach UE Check RSC and CGI delay should trigger
    [Arguments]    ${ue_id}=1    ${delay}=8000    ${nrcell_id}=${nci-115969}
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=NRRSC_RRC    overall_timeout=16
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=noB1_RRC    overall_timeout=16
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq 1) and (purpose eq 'reportCGI') and (s-Measure eq 75) and (onDurationTimer eq "psf10")) as CGI_RRC
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=CGI_RRC    overall_timeout=16
    set RSC CGI auto report and delay    ue_id=${ue_id}    delay=${delay}    nrcell_id=${nrcell_id}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRRSC_RRC
    Flow Not Occurred For Message    alias=noB1_RRC
    Flow Occurred As Expected    alias=CGI_RRC

Attach UE Check RSC and CGI delay should not trigger
    [Arguments]    ${ue_id}=1    ${delay}=8000    ${nrcell_id}=${nci-115969}
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=NRRSC_RRC    overall_timeout=16
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=noB1_RRC    overall_timeout=16
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq 1) and (purpose eq 'reportCGI') and (s-Measure eq 75) and (onDurationTimer eq "psf10")) as CGI_RRC
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=CGI_RRC    overall_timeout=16
    set RSC CGI auto report and delay    ue_id=${ue_id}    delay=${delay}    nrcell_id=${nrcell_id}
    UE attach to cell1    ue_id=${ue_id}
    Flow Not Occurred For Message    alias=NRRSC_RRC
    Flow Not Occurred For Message    alias=noB1_RRC
    Flow Not Occurred For Message    alias=CGI_RRC

Case setup
    Common Test Setup And Start To Capture Logs
    clean CB005825 verification list

Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias for multi UEs
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Set UE parameters for ENDC capability

Create UE Alias for multi UEs
    FOR    ${ue_id}    IN RANGE    3    17
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Uex Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=2 nr_supported_bands=78,258
    Execute Egate Command    ue_enb_param id=1,2,3,7,8,11,12,13,14,15,16 spid=34
    Config gnb7
    Config UE11 to UE16 support NRANR

Config UE11 to UE16 support NRANR
    FOR    ${ue_id}    IN RANGE    3    17
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
    Update Yaml    UEs/UE_sets/3     bearer: bearer_set_2
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

UE attach to cell1
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    ${ret1}=    Execute Uex Command    ${V_1}

UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

set RSC CGI auto report
    [Arguments]    ${ue_id}=1    ${nrcell_id}=${nci-115969}    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}    ${nrsrp}=25    ${nrsrq}=22
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=${nrsrp} nrsrq=${nrsrq} nsinr=31 strongest=nr5g cgi=262:03|${nrcell_id}
    ...    freq_band_list=258 tac=33
    Run Uex Command    ${cmd}

Trigger UE1 to send B2-NR for freq with PCI1
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${narfcn} amount=1

clean CB005825 verification list
    Block Cell1
    Unblock Cell1

report B2 to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=5
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    sleep    2    #waite B2 RRC complete
    UE detach    ue_id=${ue_id}

Attach UE and prepare tuple-entry tobeverified
    sleep    ${wTUecRadAnrNrNbrHoFail2H}    #setup TUecRadAnrNrNbrHoFail2H elapsed and anrNrNbrHoRelVerifyPeriod not elapsed
    Trigger UE to send B2-NR 1 time    ue_id=8    #pci=5
    sleep    ${wTS1RELOCoverallAndFail2H}    #TS1RELOCoverall and TUecRadAnrNrNbrHoFail2H elapsed and anrNrNbrHoRelVerifyPeriod not elapsed
    UE detach    ue_id=8
    sleep    ${WanrNrNbrHoRelVerifyPeriod}    #anrNrNbrHoRelVerifyPeriod elapsed
    Trigger UE to send B2-NR 1 time    ue_id=8
    UE detach    ue_id=8
