*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS24R1    team-CN3ET    owner-tom.li
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
...    @{LNRELGNBCELL}
...    @{LNADJGNB2}
...    @{LNRELGNBCELL2}
...    @{CB005825}
...    @{LTE4281andLTE5348}
...    @{handover}
...    @{ENDC_HO}
...    @{LTE5603}
...    @{SET_DRX_ON}
...    @{CB010379}
...    LNBTS-1:actSnChangeSnInit=true
...    LNBTS-1/NRMEASDPR-0:measGapEnabledNRMeas=FR1AndFR2

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
...    ${AnrNrNbrHoRelVerifyPeriod}=0
...    ${AnrNrNbrHoFail2H}=20
...    ${numConsideredB2PerUe}=100
${numConsideredB2PerUe}    0x1300F1
${Uec_TUecRadMaxValueOfNrPciCounter}    0x1300DA
${Uec_TUecRadMaxSizeOfNrPciCounters}    0x1300DB
${Uec_TUecRadAnrNrNbrRelRemPeriodicCheckTimer}    0x1300E2
${AaSysLogOutputMode}     0x10041
${AaSysLogOutputLevel}     0x10040
${AaSysLogInputLevel}      0x1003F
${TRromRadDebugLogEnabledCommon}    0x120006
${TRromRadDebugLogEnabledGlobal}    0x120004
${TRromRadDebugLogEnabledRrom}    0x120005
${TUecRadDebugLogEnabledGlobal}    0x130020
${TUecRadDebugLogEnabledUec}    0x130021
${TUecRadDebugLogEnabledCommon}    0x13001E
${TUecRadDebugLogEnabledCommonCodec}    0x13001F
${AnrNrNbrHoRelVerifyPeriod}    0x1300EE
${AnrNrNbrHoFail2H}    0x1300EF
${numConsideredB2PerUe}    0x1300F1

@{LTE4088}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:tS1eRABModInd=50
...    LNBTS-1:actTransmittedBelowGap=false
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS-1:tLteNrDualConnectPrep=10000
...    LNBTS-1:pdcpProf1001:pdcpProfileId=1001
...    LNBTS-1:pdcpProf1001:snSizeDl=18bit
...    LNBTS-1:pdcpProf1001:snSizeUl=18bit
...    LNBTS-1:pdcpProf1001:statusRepReq=0
...    LNBTS-1:pdcpProf1001:tDiscard=300ms
...    LNBTS-1:nrRestrictionOverride=disabled
@{LTE4193}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
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
...    LNBTS-1/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS-1/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS-1/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS-1/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS-1/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=120kHz
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=1
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=656736
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=8
@{others}
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:caSchedFairFact=0
...    LNBTS-1:mcc=262
...    LNBTS-1:mnc=3
...    LNBTS-1:mncLength=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:lnBtsId=100000
...    LNBTS-1/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1:harqMaxTrVoLteDl=4
...    LNCEL-2:harqMaxTrVoLteDl=4
...    LNCEL-3:harqMaxTrVoLteDl=4
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1:tac=33
...    LNCEL-2:tac=33
...    LNCEL-3:tac=33
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    delete:LNCEL-1/MBSFNCEL-0
...    LNBTS-1:actAmbrModCaTrigger=false

@{LTE5411}
...    LNBTS-1:actLteNrFastNbrRelAdd=false
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddHyst=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddThresh=5
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddHyst=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddThresh=5
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0

@{LNADJGNB}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
@{LNADJGNB2}
...    LNBTS-1/LNADJGNB-2:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
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
@{LNRELGNBCELL2}
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=132363
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
@{inactive_timer}
...    LNCEL-1:inactivityTimer=10000
...    LNCEL-1:inactivityTimerPubSafety=10000
...    LNBTS-1/ANR-0:anrNrInactivityTimer=5
...    LNCEL-1/SIB-0:t301=2000ms
...    LNCEL-1/SIB-0:t311=10000ms
...    LNBTS-1/ANR-0:anrNrCoverageConfirmTimer=9000

@{LTE5226}
...    LNBTS-1/NRMEASDPR-0:mrWaitTimer=2000

@{LTE4549}
...    LNBTS-1:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS-1:enableBwCombCheck=true
...    LNBTS-1/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS-1/NRDCDPR-0:allowedBcSelectMethod=no preference
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
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=0
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

${nci-114711}    0x1C017
${nci-114719}    0x1C01F
${nci-114720}    0x1C020

@{X2shouldup}
...    LNBTS-1/LNADJGNB-1:x2ToGnbLinkStatus=available
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
...    LNCEL-2:measQuantityNr=RSRP
...    LNCEL-2:t304InterRATN=500ms
...    LNCEL-2:a2TimeToTriggerActNRMeas=320ms
...    LNCEL-2:threshold2NR=25
...    LNCEL-2:hysThreshold2NR=0
...    LNBTS-1:maxNumAnrMoiAllowed=100
...    @{CB007742}
...    LNBTS-1:actUeBasedAnrNrHo=true
...    @{CB005825_ANR}

@{CB005825_ANR}
...    LNBTS-1/ANR-0:anrNrHoNbrRelRemGuardTime=72
...    LNBTS-1/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS-1/ANR-0:consec5gHoFailThres=1
...    LNBTS-1/ANR-0:actAutoNrHoNeighRemoval=true
...    LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=All|carrierFreqNrCell=656736
...    LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=656736
...    LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=22|carrierFreqNrCell=656736
...    LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=656736
...    LNBTS-1/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=656736
...    LNBTS-1/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=656736
...    LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=FR1|carrierFreqNrCell=2036672
...    LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=2036672
...    LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=22|carrierFreqNrCell=2036672
...    LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=2036672
...    LNBTS-1/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=2036672
...    LNBTS-1/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=2036672
...    LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mnc=3|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=1

@{CB007742}
...    LNBTS-1:actHOtoNR=true
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1:tS1RelOvDeltN=5000
...    LNBTS-1:tS1RelPrepN=5000
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1:actEnhAcAndGbrServices=true
...    LNBTS-1:actFlexQCIARPPMProfiles=true
...    LNBTS-1/MODPR-0:freqLayListPsHoNR=656736,2036672
...    LNBTS-1/MODPR-0:freqLayListPsHoNRVoLte=656736,2036672
...    @{CB007742_LNHON}

@{CB007742_LNHON}
...    LNCEL-1/LNHON-1:carrierFreqNr=656736
...    LNCEL-1/LNHON-1:freqBandIndicatorListNr=77
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
...    LNCEL-2/LNHON-1:carrierFreqNr=656736
...    LNCEL-2/LNHON-1:freqBandIndicatorListNr=77
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
...    LNCEL-2/LNHON-1:nrPciHoNbrRelAddThresh=5
...    LNCEL-2/LNHON-1:nrPciHoNbrRelRemThresh=100000
...    LNCEL-2/LNHON-1:nrPciHoNbrCounterDecay=1000
...    LNCEL-1/LNHON-2:carrierFreqNr=2036672
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
...    LNCEL-2/LNHON-2:carrierFreqNr=633333
...    LNCEL-2/LNHON-2:freqBandIndicatorListNr=78
...    LNCEL-2/LNHON-2:b1TriggerQuantity=RSRP
...    LNCEL-2/LNHON-2:b1ThresholdRsrp=0
...    LNCEL-2/LNHON-2:b2NrBeamReportQuantity=None
...    LNCEL-2/LNHON-2:b2NrCellReportQuantity=RSRP
...    LNCEL-2/LNHON-2:b2NrReportIntervalRsrp=480ms
...    LNCEL-2/LNHON-2:b2NrTimeToTriggerRsrpMeas=320ms
...    LNCEL-2/LNHON-2:b2Threshold1RsrpNr=40
...    LNCEL-2/LNHON-2:b2Threshold2RsrpNr=56
...    LNCEL-2/LNHON-2:hysB2NrThresholdRsrp=4
...    LNCEL-2/LNHON-2:nrCarPrio5GSACapMobility=1
...    LNCEL-2/LNHON-2:nrQuantityConfigSetId=0
...    LNCEL-2/LNHON-2:offsetFreqNr=0
...    LNCEL-2/LNHON-2:ssbDuration=sf1
...    LNCEL-2/LNHON-2:ssbOffset=0
...    LNCEL-2/LNHON-2:ssbPeriodicity=sf10-r15
...    LNCEL-2/LNHON-2:ssbSubcarrierSpacing=30kHz
...    LNCEL-2/LNHON-2:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    LNCEL-2/LNHON-2:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    LNCEL-2/LNHON-2:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    LNCEL-2/LNHON-2:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4
...    LNCEL-2/LNHON-2:nrPciHoNbrRelAddThresh=5
...    LNCEL-2/LNHON-2:nrPciHoNbrRelRemThresh=100000
...    LNCEL-2/LNHON-2:nrPciHoNbrCounterDecay=1000

@{LNRELN9_NRHO}
...    LNCEL-1/LNRELN-9:cellIdentity=114719
...    LNCEL-1/LNRELN-9:psHoAllowed=allowed
...    LNCEL-1/LNRELN-9:plmnId:mcc=262
...    LNCEL-1/LNRELN-9:plmnId:mnc=3
...    LNCEL-1/LNRELN-9:plmnId:mncLength=2
...    LNCEL-1/LNRELN-9:removeAllowed=true
@{LNRELN10_NRHO}
...    LNCEL-1/LNRELN-10:cellIdentity=114720
...    LNCEL-1/LNRELN-10:psHoAllowed=allowed
...    LNCEL-1/LNRELN-10:plmnId:mcc=262
...    LNCEL-1/LNRELN-10:plmnId:mnc=3
...    LNCEL-1/LNRELN-10:plmnId:mncLength=2
...    LNCEL-1/LNRELN-10:removeAllowed=true

${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208030
...    4218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820610
...    40105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E000
...    20406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C0209A143C037FC00000A00000061000880014207F80226A02

${ue_eutra_capabilities_N77}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208030
...    4218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820610
...    40105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E000
...    20406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000040200C2609A143C037FC00000A00000061000880
...    014307F8042685026208110000204034102

${ue_nr_capabilities}    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000C039
...    F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D802802010040118028030100401004
...    600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064104208
...    000210410809A55334A262B9515DA8AEC4
${ue_nr_capabilities_N77}    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C4CD010CA1A044083A0C30260220B6480A01000C03
...    9F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D8028020100401180280301004010
...    04600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064104
...    208000210410809A55334A262B9515DA8AEC4
${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B02004040C1803A020000000FD00000000081B8981002020E2680000103F400000000206E360400818103071340000101FA00000
...    00010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B000804180004020001008000402
...    020040088000201000080404008011800040200010080004020200400840002010100200440001008000402020040080
${ue_eutra_nr_capabilities_N77}    SEPARATOR=
...    C10060B71B02004040C1803A020000000FD00000000081B8981002020E2680000103F400000000206E360400818103071340000101FA00000
...    00010370B0200E2600000303F400000000206E26040081838040000100FD0000000008100800803004809B000804180004020001008000402
...    020040088000201000080404008011800040200010080004020200400840002010100200440001008000402020040080

@{LTE4281andLTE5348}
...    LNBTS-1:actHoWoSnChg=intraEnbAndX2HoEnabled
@{handover}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-3:ecgiLcrId=21
...    LNCEL-1/LNREL-3:removeAllowed=false
...    LNCEL-1/LNREL-3:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-3:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-3:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:ecgiLcrId=1
...    LNCEL-2/LNREL-2:removeAllowed=false
...    LNCEL-2/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=2
...    LNCEL-2/LNREL-3:ecgiLcrId=1
...    LNCEL-2/LNREL-3:removeAllowed=false
...    LNCEL-2/LNREL-3:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-3:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-3:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100

${NRARFCN630000}
...    629984

@{unlockcell}
...    LNCEL-1:administrativeState=unlocked

@{delete_MOCs_1}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-511
...    delete:LNCEL-1/LNRELN-1
...    delete:LNCEL-1/LNRELN-9
...    delete:LNCEL-1/LNRELN-10
...    delete:LNADJN-1
...    LNCEL-1:administrativeState=locked

@{ENDC_HO}
...    LNBTS:actEndcHo=enabled
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    MRBTS-1/LNBTS-1/MODPR-0:autoAdapt=false
...    MRBTS-1/LNBTS-1/MODPR-0:freqLayEndcHoList:freqLayer=1500
...    MRBTS-1/LNBTS-1/MODPR-0:freqLayListLte=1600
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNBTS:actUeCapEndcHo=true
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=1600
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=78
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=true
...    LNCEL:iFEndcHoRetryTimer=10
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:actIfHo=enabled
...    MRBTS-1/LNBTS-1/LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    MRBTS-1/LNBTS-1/LNCEL-1/LNREL-2:ecgiLcrId=2
...    MRBTS-1/LNBTS-1/LNCEL-1/LNREL-2:removeAllowed=false
...    MRBTS-1/LNBTS-1/LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...    MRBTS-1/LNBTS-1/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS:blockEndcHoRetryAtHoFromTrg=no blocking
@{LTE5603}
...    MRBTS-1/LNBTS-1:actSelMobPrf=true
...    MRBTS-1/LNBTS-1:reportTimerIFSPIDA5=3000ms
...    MRBTS-1/LNBTS-1/LNCEL-1:actInterFreqSPIDBasedHo=all triggers
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHOIF-1:thresholdRsrpIFSPIDFilter=-140
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHOIF-1:thresholdRsrqIFSPIDFilter=-12
...    MRBTS-1/LNBTS-1/LNCEL-1:moPrMappingList=${EMPTY}
...    MRBTS-1/LNBTS-1/MODPR-0:freqLayListSPIDBasedHo=1600
...    delete:MRBTS-1/LNBTS-1/MOPR-1
...    delete:MRBTS-1/LNBTS-1/MOPR-1/MOIMP-1
...    delete:MRBTS-1/LNBTS-1/MOPR-1/MORED-1
@{SET_DRX_ON}
...    LNCEL:actDrx=true
@{A_B9_case30}
...    @{LNADJN-PCI1}
...    @{LNADJNL-PCI1_1}
...    @{LNRELN9_NRHO}
@{A_B9_case31}
...    @{LNADJN-PCI1_case31}
...    @{LNADJNL-PCI1_1_case31}
...    @{LNRELN10_NRHO}

@{LNADJN-PCI1}
...    LNADJN-1:arfcnValueNR=656736
...    LNADJN-1:multiFrequencyBandList=77
...    LNADJN-1:physCellIdNr=7

@{LNADJNL-PCI1_1}
...    LNADJN-1/LNADJNL-1:cellIdentity=114719
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=3
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=3
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2

@{LNADJN-PCI1_case31}
...    LNADJN-1:arfcnValueNR=2036672
...    LNADJN-1:multiFrequencyBandList=258
...    LNADJN-1:physCellIdNr=1

@{LNADJNL-PCI1_1_case31}
...    LNADJN-1/LNADJNL-1:cellIdentity=114720
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=3
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=3
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2

@{LNADJNL-PCI1_1_case31_ANRupdated}
...    LNADJN-1/LNADJNL-1:cellIdentity=114720
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=3
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262|mnc=3
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2|mnc=3
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262|mnc=4
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2|mnc=4

@{A_B9_case31_ANRupdated}
...    @{LNADJN-PCI1_case31}
...    @{LNADJNL-PCI1_1_case31_ANRupdated}
...    @{LNRELN10_NRHO}

@{CB010379}
...    LNBTS-1:actExt2N77Support=true

@{contain_MOC_A_B9_29}
...    @{LNADJN-PCI7_A_B9_created}
...    @{LNADJNL-PCI7_A_B9_created}
...    @{LNRELN_A_B9_created}
@{LNADJN-PCI7_A_B9_created}
...    LNADJN-511:arfcnValueNR=656736
...    LNADJN-511:multiFrequencyBandList=77
...    LNADJN-511:physCellIdNr=7
@{LNADJNL-PCI7_A_B9_created}
...    LNADJN-511/LNADJNL-11:cellIdentity=114719
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-511/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2

@{LNRELN_A_B9_created}
...    LNCEL-1/LNRELN-255:cellIdentity=114719
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2
...    LNCEL-1/LNRELN-255:removeAllowed=true

@{contain_MOC_A_B9_29_2}
...    @{LNADJN-PCI7_A_B9_created_2}
...    @{LNADJNL-PCI7_A_B9_created}
...    @{LNRELN_A_B9_created}

@{LNADJN-PCI7_A_B9_created_2}
...    LNADJN-511:arfcnValueNR=656736
...    LNADJN-511:multiFrequencyBandList=78
...    LNADJN-511:physCellIdNr=7

@{contain_MOC_A_B9_28}
...    @{LNADJN-PCI7_A_B9_28_created}
...    @{LNADJNL-PCI7_A_B9_28_created}
...    @{LNRELN_A_B9_28_created}

@{LNADJN-PCI7_A_B9_28_created}
...    LNADJN-511:arfcnValueNR=656736
...    LNADJN-511:multiFrequencyBandList=77
...    LNADJN-511:physCellIdNr=7

@{LNADJNL-PCI7_A_B9_28_created}
...    LNADJN-511/LNADJNL-11:cellIdentity=114711
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=1
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-511/LNADJNL-11:plmnIdList:mnc=1
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2

@{LNRELN_A_B9_28_created}
...    LNCEL-1/LNRELN-255:cellIdentity=114711
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=1
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2
...    LNCEL-1/LNRELN-255:removeAllowed=true

${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x20', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}',
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}',
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell3}    SEPARATOR=
...    {id: 76, technology: nr , tac: 33, pci: '2:0', nrci: '0x21', nr_arfcn: '${NRARFCN630000}:${NRARFCN630000}',
...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell4}    SEPARATOR=
...    {id: 77, technology: nr , tac: 33, pci: '2:1', nrci: '0x1F', nr_arfcn: '${NRARFCN630000}:${NRARFCN630000}',
...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell5}    SEPARATOR=
...    {id: 78, technology: nr , tac: 33, pci: '2:2', nrci: '0x508', nr_arfcn: '${NRARFCN630000}:${NRARFCN630000}',
...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell6}    SEPARATOR=
...    {id: 79, technology: nr , tac: 33, pci: '3:0', nrci: '0x509', nr_arfcn: '${NRARFCN630000}:${NRARFCN630000}',
...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell7}    SEPARATOR=
...    {id: 80, technology: nr , tac: 33, pci: '3:1', nrci: '0x50A', nr_arfcn: '${GSCN7812}:${GSCN7812}',
...    meas_timing_carrier_freq: ${GSCN7812}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb8_cell1}    SEPARATOR=
...    {id: 81, technology: nr , tac: 33, pci: '3:2', nrci: '0x21', nr_arfcn: '${NRARFCN630000}:${NRARFCN630000}',
...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${RSC_not_triggered}    6

*** Test Cases ***
CB005825-SR-A-B9_ET_29_01_MO with N77 freq can be updated successfully
    [Tags]
    report B2 to make tuple tobeverified    ue_id=2    pci=7    narfcn=656736
    attach UE1 and UE3 then UE1 triggered ANR
    trigger re-verification due to NRHO fail    ue_id=2    nrarfcn=656736    pci=7
    UE attached and reportCGI triggered as expected    ue_id=1    nrarfcn=656736    pci=7    freqbandlist=78
    Object Should Exist    ${contain_MOC_A_B9_29_2}
    [teardown]    delete all MOCs
CB005825-SR-A-B9_ET_28_01_MO with N77 freq can be created successfully by ANR
    [Tags]
    report B2 to make tuple tobeverified    ue_id=2    pci=7    narfcn=656736
    set RSC and reportCGI auto report
    UE11 anr success and UE12 not triggered RSC    nrarfcn=656736    pci=7
    Object Should Exist    ${contain_MOC_A_B9_28}
    [teardown]    delete all MOCs
CB005825-SR-A-B9_ET_30_01_RSC is deactived when 5GHO B2 is activated during RSC process
    [Tags]
    Delta Commission Parameters    ${A_B9_case30}
    trigger UE attached and RSC triggered    ue_id=13    nrarfcn=656736
    trigger B2NR activated and RSC clean up    ue_id=13    nrarfcn=656736    pci=7
    [teardown]    delete all MOCs
CB005825-SR-A-B9_ET_31_01_NR-ReportCGI measurement report sub-procedure keep running when 5GHO B2 is activated
    [Tags]
    Delta Commission Parameters    ${A_B9_case31}
    set nrho enbsim
    trigger reportCGI activated    ue_id=14    nrarfcn=2036672    pci=1
    trigger B2NR activated and ANR continued    ue_id=14    nrarfcn=2036672    pci=1
    trigger re-verification    ue_id=14    nrarfcn=2036672    pci=1
    trigger reportCGI activated    ue_id=15    nrarfcn=2036672    pci=1
    trigger NRHO fail to reestablish and ANR not continue    ue_id=15    nrarfcn=2036672    pci=1
    [teardown]    delete all MOCs

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Perform Steps After Onair
    Set UEs Alias
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB     enb_id=7    id_type=wts
    Create enb alias    alias=gNB2     enb_id=8    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Set UE parameters for ENDC capability
    X2 link should be available

Set UEs Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_11    ue_id=11    id_type=cus
    Create UE Alias    UE_12    ue_id=12    id_type=cus
    Create UE Alias    UE_13    ue_id=13    id_type=cus
    Create UE Alias    UE_14    ue_id=14    id_type=cus
    Create UE Alias    UE_15    ue_id=15    id_type=cus
    Create UE Alias    UE_16    ue_id=16    id_type=cus

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Set UE param
    Set endc param

Set UE param
    Execute Uex Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=3 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1 nr_supported_bands=78,258,77
    Execute Uex Command    ue_param id=2 nr_supported_bands=78,258,77
    Execute Uex Command    ue_param id=3 nr_supported_bands=78,258,77
    Execute Uex Command    ue_param id=11-16 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=11-16 nr_supported_bands=78,258,77
    Execute Egate Command    ue_enb_param id=1,2,3,11,12,13,14,15,16 spid=34

Set endc param
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=2:1
    Execute Egate Command    gnb_endc_param id=8 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=8 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=8 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=8 selected_band_combination_nr=2:1

Perform Steps After Onair
    @{lnadj}    Create List    LNADJ:cPlaneIpAddr=10.0.1.3    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj}

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
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
    ...        - {id: 21, technology: lte, tac: 33, pci: '9:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '9:1', earfcn: '1600:19600', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '9:2', earfcn: '8770:26770', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      type: simulated
    ...      enb_id_macro: 0x0000A
    ...      plmn: '262:03'
    ...      s1: 10.0.1.4
    ...      cells:
    ...        - {id: 31, technology: lte, tac: 33, pci: '2:1', eci: '0x0000A1F', earfcn: '1400:19400', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 4
    ...      type: simulated
    ...      enb_id_macro: 0x0000B
    ...      plmn: '262:03'
    ...      s1: 10.0.1.5
    ...      cells:
    ...        - {id: 41, technology: lte, tac: 33, pci: '0:1', eci: '0x0000B20', earfcn: '1400:19400', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 5
    ...      type: simulated
    ...      enb_id_macro: 0x0000C
    ...      plmn: '262:03'
    ...      s1: 10.0.1.6
    ...      cells:
    ...        - {id: 51, technology: lte, tac: 33, pci: '3:2', eci: '0x0000C21', earfcn: '1400:19400', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: 1
    ...      cells:
    ...        - ${gnb7_cell1}
    ...        - ${gnb7_cell2}
    ...        - ${gnb7_cell3}
    ...        - ${gnb7_cell4}
    ...        - ${gnb7_cell5}
    ...        - ${gnb7_cell6}
    ...        - ${gnb7_cell7}
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...      gnb_id: '0x00008'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.12
    ...      x2_peers: 1
    ...      cells:
    ...        - ${gnb8_cell1}

UE attach to cell1
    [Arguments]    ${ue_id}=1    ${cellid}=1    ${ue_nr_capab}=${ue_nr_capabilities_N77}    ${ue_eutra_nr_capab}=${ue_eutra_nr_capabilities_N77}
    ...    ${ue_eutra_capab}=${ue_eutra_capabilities_N77}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capab} ue_eutra_nr_capabilities=${ue_eutra_nr_capab}
    ...    ue_eutra_capabilities=${ue_eutra_capab} cell=${cellid}
    ${ret1}=    Execute Uex Command    ${V_1}

UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

Trigger UE1 to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34

Trigger UE1 to send B2-NR for freq with PCI1
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${narfcn} amount=1

X2 link should be available
    Object Should Exist    ${X2shouldup}    timeout=300

report B2 to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=2036672    ${cellid}=1    ${counter}=7
    UE attach to cell1    ue_id=${ue_id}    cellid=${cellid}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    ${counter}
        Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    END
    UE detach    ue_id=${ue_id}

delete all MOCs
    Release All UEs
    Run Uex Command    ue_rrc_reconf_param id=11 reset
    Run Uex Command    ue_rrc_reconf_param id=12 reset
    Execute Egate Command    ue_mme_param id=11-12 reset
    Run Uex Command    ue_rrc_mobility_from_eutra_param id=11 reset
    Delta Commission Parameters    ${delete_MOCs_1}
    Delta Commission Parameters    ${unlockcell}
    Cells Should Be Onair
    Common Test Teardown And Stop Capture Logs

trigger re-verification due to NRHO fail
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN630000}    ${pci}=1
    sleep    15    #wait AnrNrNbrHoFail2H timeout
    UE attach to cell1    ue_id=${ue_id}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    Expect message flow
    ...    MME_1:S1AP_HandoverRequired (HandoverType eq 'eps-to-5gs')
    ...    UE_${ue_id}:RRC_MobilityFromEUTRACommand (mobilityFromEUTRACommand-r8 is present)
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentComplete (rrcConnectionReestablishmentComplete-r8 is present)
    ...    alias=NRHO_FAIL    overall_timeout=20
    Run Uex Command    ue_rrc_mobility_from_eutra_param id=${ue_id} nth=1 action=reestablish cell=1 cause=handoverFailure
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${nrarfcn} amount=1
    Flow Occurred As Expected    alias=NRHO_FAIL
    UE detach    ue_id=${ue_id}

UE attached and reportCGI triggered as expected
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN630000}    ${pci}=1    ${freqbandlist}=78
    ${reportCGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci}))
    Expect message flow
    ...    ${reportCGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22
    ...    cgi_plmn_group cgi=262:03|${nci-114719} freq_band_list=${freqbandlist} tac=33
    Run Uex Command    ${cmd}
    Flow Occurred As Expected    alias=NRANR_RRC

UE11 anr success and UE12 not triggered RSC
    [Arguments]    ${nrarfcn}=${NRARFCN630000}    ${pci}=1
    Expect message flow
    ...    UE_11:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and (purpose eq 'reportStrongestCells'))
    ...    UE_11:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and (cellForWhichToReportCGI-r15 eq ${pci}))
    ...    alias=NRANR_UE11    overall_timeout=20
    Expect Message Will Not Occur
    ...    UE_12:RRC_RRCConnectionReconfiguration (purpose eq 'reportStrongestCells')
    ...    alias=NRANR_UE12    overall_timeout=20
    UE attach to cell1    ue_id=11
    UE attach to cell1    ue_id=12    ue_nr_capab=${ue_nr_capabilities}    ue_eutra_nr_capab=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capab=${ue_eutra_capabilities}
    Flow Occurred As Expected    alias=NRANR_UE11
    Flow Not Occurred For Message    alias=NRANR_UE12

trigger UE attached and RSC triggered
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN630000}
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (purpose eq 'reportStrongestCells'))
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=NRANR_RSC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RSC

trigger B2NR activated and RSC clean up
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN630000}    ${pci}=1
    trigger B2NR actived    ue_id=${ue_id}
    ${noCGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci}))
    Expect message flow
    ...    MME_1:S1AP_HandoverRequired (HandoverType eq 'eps-to-5gs')
    ...    alias=NRHO_FAIL    overall_timeout=20
    Expect Message Will Not Occur
    ...    ${noCGI_RRC}
    ...    alias=noCGI_RRC    overall_timeout=15
    Execute Egate Command    ue_mme_param id=${ue_id} lte_to_nr_ho_preparation_failure=RN_cell_not_available
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${nrarfcn} amount=1
    Flow Occurred As Expected    alias=NRHO_FAIL
    Flow Not Occurred For Message    alias=noCGI_RRC

trigger reportCGI activated
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN630000}    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send narfcn=${nrarfcn}
    ...    phycell_id=${pci} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03,262:04|${nci-114720} freq_band_list=258 tac=33
    Run Uex Command    ${cmd}
    ${cmd1}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportCGI action=delay_next_msg delay=8000
    ...    next_msg=measurementReport
    Run Uex Command    ${cmd1}
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci}))
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (purpose eq 'reportStrongestCells'))
    Expect message flow
    ...    ${RSC_RRC}
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}    ue_nr_capab=${ue_nr_capabilities}    ue_eutra_nr_capab=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capab=${ue_eutra_capabilities}
    Flow Occurred As Expected    alias=NRANR_RRC

trigger B2NR activated and ANR continued
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN630000}    ${pci}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    ${cleanup_CGI}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) and
    ...    (gp0 is not present) and (drx-Config is not present))
    Expect message flow
    ...    ${cleanup_CGI}
    ...    alias=reportCGI_RRC    overall_timeout=20
    Execute Egate Command    ue_mme_param id=${ue_id} lte_to_nr_ho_preparation_failure=RN_cell_not_available
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${nrarfcn} amount=1
    Flow Occurred As Expected    alias=reportCGI_RRC
    Object Should Exist    ${A_B9_case31_ANRupdated}

trigger re-verification
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN630000}    ${pci}=1
    sleep    15    #wait AnrNrNbrHoFail2H timeout
    Expect message flow
    ...    MME_1:S1AP_HandoverRequired (HandoverType eq 'eps-to-5gs')
    ...    UE_${ue_id}:RRC_MobilityFromEUTRACommand (mobilityFromEUTRACommand-r8 is present)
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentComplete (rrcConnectionReestablishmentComplete-r8 is present)
    ...    alias=NRHO_FAIL    overall_timeout=20
    Execute Egate Command    ue_mme_param id=${ue_id} reset
    Run Uex Command    ue_rrc_mobility_from_eutra_param id=${ue_id} nth=1 action=reestablish cell=1 cause=handoverFailure
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${nrarfcn} amount=1
    Flow Occurred As Expected    alias=NRHO_FAIL
    Execute Uex Command    ue_rrc_mobility_from_eutra_param id=${ue_id} reset
    UE detach    ue_id=${ue_id}

trigger NRHO fail to reestablish and ANR not continue
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN630000}    ${pci}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    Expect message flow
    ...    MME_1:S1AP_HandoverRequired (HandoverType eq 'eps-to-5gs')
    ...    UE_${ue_id}:RRC_MobilityFromEUTRACommand (mobilityFromEUTRACommand-r8 is present)
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentComplete (rrcConnectionReestablishmentComplete-r8 is present)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (32))
    ...    alias=NRHO_FAIL    overall_timeout=20
    Run Uex Command    ue_rrc_mobility_from_eutra_param id=${ue_id} nth=1 action=reestablish cell=1 cause=handoverFailure
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${nrarfcn} amount=1
    Flow Occurred As Expected    alias=NRHO_FAIL

attach UE1 and UE3 then UE1 triggered ANR
    Expect Message Will Not Occur
    ...    UE_3:RRC_RRCConnectionReconfiguration (purpose eq 'reportStrongestCells')
    ...    alias=NRANR_UE3    overall_timeout=${RSC_not_triggered}
    UE attach to cell1    ue_id=1
    UE attach to cell1    ue_id=3    ue_nr_capab=${ue_nr_capabilities}    ue_eutra_nr_capab=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capab=${ue_eutra_capabilities}
    ${cmd}    catenate
    ...    ue_measurement_send id=1 event=B1_NR phycell_id=7 narfcn=656736 nrsrp=25 nrsrq=22
    ...    cgi_plmn_group cgi=262:03|${nci-114719} freq_band_list=77 tac=33
    Run Uex Command    ${cmd}
    Flow Not Occurred For Message    alias=NRANR_UE3
    Object Should Exist    ${contain_MOC_A_B9_29}
    UE detach    ue_id=1
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4

set RSC and reportCGI auto report
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=11 if_contains=purpose with_value=reportStrongestCells action=measurement_send narfcn=656736
    ...    phycell_id=7 nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:01|${nci-114711} freq_band_list=77 tac=33
    Run Uex Command    ${cmd}

trigger B2NR actived
    [Arguments]    ${ue_id}=1
    ${cleanup_RSC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) and (s-Measure eq 75))
    ${B2_active_clean_RSC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present)
    ...    and (measIdToRemoveList contains (32)) and (s-Measure eq 75))
    Expect message flow
    ...    ${B2_active_clean_RSC}
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC

set nrho enbsim
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000B
    Execute Egate Command    enb_param id=11 drb_id_begin=4
