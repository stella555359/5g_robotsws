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
...    LNBTS-1:actSnChangeSnInit=true

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
...    ${numConsideredB2PerUe}=10
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
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=629984
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=78
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
${nci-114712}    0x1C018
${nci-114713}    0x1C019
${nci-114715}    0x1C01B
${nci-114716}    0x1C01C
${nci-114717}    0x1C01D
${nci-114718}    0x1C01E
${nci-114719}    0x1C01F
${nci-114720}    0x1C020
${nci-114721}    0x1C021
${nci-114722}    0x1C022
${nci-114723}    0x1C023
${nci-114724}    0x1C024

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

@{A_B6_C_case9}
...    @{LNADJN-PCI2}
...    @{LNADJNL-PCI2_1}
...    @{LNADJNL-PCI2_2}
...    @{LNADJNL-PCI2_3}
...    @{LNADJNL-PCI2_4}
...    @{LNADJN-PCI2_2}
...    @{LNADJNL-PCI2_11}
...    @{LNADJNL-PCI2_12}
...    @{LNADJNL-PCI2_13}
...    @{LNADJNL-PCI2_14}
...    @{LNADJNL-PCI2_15}
...    @{LNADJN-PCI7}
...    @{LNADJNL-PCI7_5}
...    @{LNADJNL-PCI7_6}
...    @{LNADJNL-PCI7_7}
...    @{LNADJN-PCI7_2}
...    @{LNADJNL-PCI7_8}
...    @{LNADJNL-PCI7_9}
...    @{LNADJNL-PCI7_10}
...    @{LNRELN1}
...    @{LNRELN5}
...    @{LNRELN6}
...    @{LNRELN8}
...    @{LNRELN9}
...    @{LNRELN10}
...    @{LNRELN11}
...    @{LNRELN12}
...    @{LNRELN1_cell2}
...    @{LNRELN8_cell2}

@{CB005825_ANR}
...    LNBTS-1/ANR-0:anrNrHoNbrRelRemGuardTime=72
...    LNBTS-1/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS-1/ANR-0:consec5gHoFailThres=1
...    LNBTS-1/ANR-0:actAutoNrHoNeighRemoval=true
...    LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=All|carrierFreqNrCell=629984
...    LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=629984
...    LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=22|carrierFreqNrCell=629984
...    LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=629984
...    LNBTS-1/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=629984
...    LNBTS-1/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=629984
...    LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=FR1|carrierFreqNrCell=633333
...    LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=633333
...    LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=22|carrierFreqNrCell=633333
...    LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=633333
...    LNBTS-1/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=633333
...    LNBTS-1/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=633333
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
...    LNBTS-1/MODPR-0:freqLayListPsHoNR=629984
...    LNBTS-1/MODPR-0:freqLayListPsHoNRVoLte=629984
...    @{CB007742_LNHON}

@{CB007742_LNHON}
...    LNCEL-1/LNHON-1:carrierFreqNr=629984
...    LNCEL-1/LNHON-1:freqBandIndicatorListNr=78
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
...    LNCEL-2/LNHON-1:carrierFreqNr=629984
...    LNCEL-2/LNHON-1:freqBandIndicatorListNr=78
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
...    LNCEL-1/LNHON-2:carrierFreqNr=633333
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

@{LNADJN-PCI2}
...    LNADJN-1:arfcnValueNR=633333
...    LNADJN-1:multiFrequencyBandList=78
...    LNADJN-1:physCellIdNr=2

@{LNADJNL-PCI2_1}
...    LNADJN-1/LNADJNL-1:cellIdentity=114711
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=1
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=11
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=1|mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2|mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=1|mcc=211
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2|mcc=211

@{LNADJNL-PCI2_2}
...    LNADJN-1/LNADJNL-2:cellIdentity=114712
...    LNADJN-1/LNADJNL-2:gnbIdLength=22
...    LNADJN-1/LNADJNL-2:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-2:gNBplmnId:mnc=2
...    LNADJN-1/LNADJNL-2:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-2:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-2:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-2:plmnIdList:mnc=2
...    LNADJN-1/LNADJNL-2:plmnIdList:mncLength=2

@{LNADJNL-PCI2_3}
...    LNADJN-1/LNADJNL-3:cellIdentity=114713
...    LNADJN-1/LNADJNL-3:gnbIdLength=22
...    LNADJN-1/LNADJNL-3:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-3:gNBplmnId:mnc=3
...    LNADJN-1/LNADJNL-3:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-3:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-3:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-3:plmnIdList:mnc=3
...    LNADJN-1/LNADJNL-3:plmnIdList:mncLength=2

@{LNADJNL-PCI2_4}
...    LNADJN-1/LNADJNL-4:cellIdentity=114714
...    LNADJN-1/LNADJNL-4:gnbIdLength=22
...    LNADJN-1/LNADJNL-4:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-4:gNBplmnId:mnc=4
...    LNADJN-1/LNADJNL-4:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-4:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-4:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-4:plmnIdList:mnc=4
...    LNADJN-1/LNADJNL-4:plmnIdList:mncLength=2

@{LNADJN-PCI2_2}
...    LNADJN-4:arfcnValueNR=633333
...    LNADJN-4:multiFrequencyBandList=78
...    LNADJN-4:physCellIdNr=2

@{LNADJNL-PCI2_11}
...    LNADJN-4/LNADJNL-11:cellIdentity=114721
...    LNADJN-4/LNADJNL-11:gnbIdLength=22
...    LNADJN-4/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-4/LNADJNL-11:gNBplmnId:mnc=11
...    LNADJN-4/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-4/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-4/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-4/LNADJNL-11:plmnIdList:mnc=11
...    LNADJN-4/LNADJNL-11:plmnIdList:mncLength=2

@{LNADJNL-PCI2_12}
...    LNADJN-4/LNADJNL-2:cellIdentity=114722
...    LNADJN-4/LNADJNL-2:gnbIdLength=22
...    LNADJN-4/LNADJNL-2:gNBplmnId:mcc=262
...    LNADJN-4/LNADJNL-2:gNBplmnId:mnc=12
...    LNADJN-4/LNADJNL-2:gNBplmnId:mncLength=2
...    LNADJN-4/LNADJNL-2:trackingAreaCodeNR=33
...    LNADJN-4/LNADJNL-2:plmnIdList:mcc=262
...    LNADJN-4/LNADJNL-2:plmnIdList:mnc=12
...    LNADJN-4/LNADJNL-2:plmnIdList:mncLength=2

@{LNADJNL-PCI2_13}
...    LNADJN-4/LNADJNL-3:cellIdentity=114723
...    LNADJN-4/LNADJNL-3:gnbIdLength=22
...    LNADJN-4/LNADJNL-3:gNBplmnId:mcc=262
...    LNADJN-4/LNADJNL-3:gNBplmnId:mnc=13
...    LNADJN-4/LNADJNL-3:gNBplmnId:mncLength=2
...    LNADJN-4/LNADJNL-3:trackingAreaCodeNR=33
...    LNADJN-4/LNADJNL-3:plmnIdList:mcc=262
...    LNADJN-4/LNADJNL-3:plmnIdList:mnc=13
...    LNADJN-4/LNADJNL-3:plmnIdList:mncLength=2

@{LNADJNL-PCI2_14}
...    LNADJN-4/LNADJNL-4:cellIdentity=114724
...    LNADJN-4/LNADJNL-4:gnbIdLength=22
...    LNADJN-4/LNADJNL-4:gNBplmnId:mcc=262
...    LNADJN-4/LNADJNL-4:gNBplmnId:mnc=14
...    LNADJN-4/LNADJNL-4:gNBplmnId:mncLength=2
...    LNADJN-4/LNADJNL-4:trackingAreaCodeNR=33
...    LNADJN-4/LNADJNL-4:plmnIdList:mcc=262
...    LNADJN-4/LNADJNL-4:plmnIdList:mnc=14
...    LNADJN-4/LNADJNL-4:plmnIdList:mncLength=2

@{LNADJNL-PCI2_15}
...    LNADJN-4/LNADJNL-5:cellIdentity=114725
...    LNADJN-4/LNADJNL-5:gnbIdLength=22
...    LNADJN-4/LNADJNL-5:gNBplmnId:mcc=262
...    LNADJN-4/LNADJNL-5:gNBplmnId:mnc=15
...    LNADJN-4/LNADJNL-5:gNBplmnId:mncLength=2
...    LNADJN-4/LNADJNL-5:trackingAreaCodeNR=55
...    LNADJN-4/LNADJNL-5:plmnIdList:mnc=15|mcc=262
...    LNADJN-4/LNADJNL-5:plmnIdList:mncLength=2|mcc=262
...    LNADJN-4/LNADJNL-5:plmnIdList:mnc=15|mcc=255
...    LNADJN-4/LNADJNL-5:plmnIdList:mncLength=2|mcc=255

@{LNADJN-PCI7}
...    LNADJN-2:arfcnValueNR=629984
...    LNADJN-2:multiFrequencyBandList=78
...    LNADJN-2:physCellIdNr=7

@{LNADJNL-PCI7_5}
...    LNADJN-2/LNADJNL-5:cellIdentity=114715
...    LNADJN-2/LNADJNL-5:gnbIdLength=22
...    LNADJN-2/LNADJNL-5:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-5:gNBplmnId:mnc=5
...    LNADJN-2/LNADJNL-5:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-5:trackingAreaCodeNR=33
...    LNADJN-2/LNADJNL-5:plmnIdList:mcc=262
...    LNADJN-2/LNADJNL-5:plmnIdList:mnc=5
...    LNADJN-2/LNADJNL-5:plmnIdList:mncLength=2

@{LNADJNL-PCI7_6}
...    LNADJN-2/LNADJNL-6:cellIdentity=114716
...    LNADJN-2/LNADJNL-6:gnbIdLength=22
...    LNADJN-2/LNADJNL-6:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-6:gNBplmnId:mnc=6
...    LNADJN-2/LNADJNL-6:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-6:trackingAreaCodeNR=66
...    LNADJN-2/LNADJNL-6:plmnIdList:mnc=6|mcc=262
...    LNADJN-2/LNADJNL-6:plmnIdList:mncLength=2|mcc=262
...    LNADJN-2/LNADJNL-6:plmnIdList:mnc=1|mcc=466
...    LNADJN-2/LNADJNL-6:plmnIdList:mncLength=2|mcc=466

@{LNADJNL-PCI7_7}
...    LNADJN-2/LNADJNL-7:cellIdentity=114717
...    LNADJN-2/LNADJNL-7:gnbIdLength=22
...    LNADJN-2/LNADJNL-7:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-7:gNBplmnId:mnc=7
...    LNADJN-2/LNADJNL-7:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-7:trackingAreaCodeNR=33
...    LNADJN-2/LNADJNL-7:plmnIdList:mcc=262
...    LNADJN-2/LNADJNL-7:plmnIdList:mnc=7
...    LNADJN-2/LNADJNL-7:plmnIdList:mncLength=2

@{LNADJN-PCI7_2}
...    LNADJN-3:arfcnValueNR=629984
...    LNADJN-3:multiFrequencyBandList=78
...    LNADJN-3:physCellIdNr=7

@{LNADJNL-PCI7_8}
...    LNADJN-3/LNADJNL-8:cellIdentity=114718
...    LNADJN-3/LNADJNL-8:gnbIdLength=22
...    LNADJN-3/LNADJNL-8:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-8:gNBplmnId:mnc=8
...    LNADJN-3/LNADJNL-8:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-8:trackingAreaCodeNR=88
...    LNADJN-3/LNADJNL-8:plmnIdList:mnc=8|mcc=262
...    LNADJN-3/LNADJNL-8:plmnIdList:mncLength=2|mcc=262
...    LNADJN-3/LNADJNL-8:plmnIdList:mnc=1|mcc=468
...    LNADJN-3/LNADJNL-8:plmnIdList:mncLength=2|mcc=468

@{LNADJNL-PCI7_8_update}
...    LNADJN-3/LNADJNL-8:cellIdentity=114718
...    LNADJN-3/LNADJNL-8:gnbIdLength=22
...    LNADJN-3/LNADJNL-8:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-8:gNBplmnId:mnc=8
...    LNADJN-3/LNADJNL-8:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-8:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-8:plmnIdList:mnc=8|mcc=262
...    LNADJN-3/LNADJNL-8:plmnIdList:mncLength=2|mcc=262

@{LNADJNL-PCI7_9}
...    LNADJN-3/LNADJNL-9:cellIdentity=114719
...    LNADJN-3/LNADJNL-9:gnbIdLength=22
...    LNADJN-3/LNADJNL-9:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-9:gNBplmnId:mnc=9
...    LNADJN-3/LNADJNL-9:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-9:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-9:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-9:plmnIdList:mnc=9
...    LNADJN-3/LNADJNL-9:plmnIdList:mncLength=2

@{LNADJNL-PCI7_10}
...    LNADJN-3/LNADJNL-10:cellIdentity=114720
...    LNADJN-3/LNADJNL-10:gnbIdLength=22
...    LNADJN-3/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-10:gNBplmnId:mnc=10
...    LNADJN-3/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-10:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-10:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-10:plmnIdList:mnc=10
...    LNADJN-3/LNADJNL-10:plmnIdList:mncLength=2

@{LNADJNL-PCI7_create_2}
...    LNADJN-3/LNADJNL-11:cellIdentity=114712
...    LNADJN-3/LNADJNL-11:gnbIdLength=22
...    LNADJN-3/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-11:gNBplmnId:mnc=2
...    LNADJN-3/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-11:plmnIdList:mnc=2
...    LNADJN-3/LNADJNL-11:plmnIdList:mncLength=2
@{LNADJNL-PCI7_create_3}
...    LNADJN-3/LNADJNL-7:cellIdentity=114713
...    LNADJN-3/LNADJNL-7:gnbIdLength=22
...    LNADJN-3/LNADJNL-7:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-7:gNBplmnId:mnc=3
...    LNADJN-3/LNADJNL-7:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-7:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-7:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-7:plmnIdList:mnc=3
...    LNADJN-3/LNADJNL-7:plmnIdList:mncLength=2
@{LNADJNL-PCI7_create_5}
...    LNADJN-3/LNADJNL-6:cellIdentity=114715
...    LNADJN-3/LNADJNL-6:gnbIdLength=22
...    LNADJN-3/LNADJNL-6:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-6:gNBplmnId:mnc=5
...    LNADJN-3/LNADJNL-6:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-6:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-6:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-6:plmnIdList:mnc=5
...    LNADJN-3/LNADJNL-6:plmnIdList:mncLength=2
@{LNADJNL-PCI7_create_11}
...    LNADJN-3/LNADJNL-5:cellIdentity=114721
...    LNADJN-3/LNADJNL-5:gnbIdLength=22
...    LNADJN-3/LNADJNL-5:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-5:gNBplmnId:mnc=11
...    LNADJN-3/LNADJNL-5:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-5:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-5:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-5:plmnIdList:mnc=11
...    LNADJN-3/LNADJNL-5:plmnIdList:mncLength=2
@{LNADJNL-PCI7_create_12}
...    LNADJN-3/LNADJNL-4:cellIdentity=114722
...    LNADJN-3/LNADJNL-4:gnbIdLength=22
...    LNADJN-3/LNADJNL-4:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-4:gNBplmnId:mnc=12
...    LNADJN-3/LNADJNL-4:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-4:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-4:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-4:plmnIdList:mnc=12
...    LNADJN-3/LNADJNL-4:plmnIdList:mncLength=2
@{LNADJNL-PCI7_create_13}
...    LNADJN-3/LNADJNL-3:cellIdentity=114723
...    LNADJN-3/LNADJNL-3:gnbIdLength=22
...    LNADJN-3/LNADJNL-3:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-3:gNBplmnId:mnc=13
...    LNADJN-3/LNADJNL-3:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-3:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-3:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-3:plmnIdList:mnc=13
...    LNADJN-3/LNADJNL-3:plmnIdList:mncLength=2
@{LNADJNL-PCI7_create_14}
...    LNADJN-3/LNADJNL-2:cellIdentity=114724
...    LNADJN-3/LNADJNL-2:gnbIdLength=22
...    LNADJN-3/LNADJNL-2:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-2:gNBplmnId:mnc=14
...    LNADJN-3/LNADJNL-2:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-2:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-2:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-2:plmnIdList:mnc=14
...    LNADJN-3/LNADJNL-2:plmnIdList:mncLength=2

@{LNRELN1}
...    LNCEL-1/LNRELN-1:cellIdentity=114711
...    LNCEL-1/LNRELN-1:psHoAllowed=allowed
...    LNCEL-1/LNRELN-1:plmnId:mcc=262
...    LNCEL-1/LNRELN-1:plmnId:mnc=1
...    LNCEL-1/LNRELN-1:plmnId:mncLength=2
...    LNCEL-1/LNRELN-1:removeAllowed=false
@{LNRELN5}
...    LNCEL-1/LNRELN-5:cellIdentity=114715
...    LNCEL-1/LNRELN-5:psHoAllowed=forbidden
...    LNCEL-1/LNRELN-5:plmnId:mcc=262
...    LNCEL-1/LNRELN-5:plmnId:mnc=5
...    LNCEL-1/LNRELN-5:plmnId:mncLength=2
...    LNCEL-1/LNRELN-5:removeAllowed=true
@{LNRELN6}
...    LNCEL-1/LNRELN-6:cellIdentity=114716
...    LNCEL-1/LNRELN-6:psHoAllowed=allowed
...    LNCEL-1/LNRELN-6:plmnId:mcc=262
...    LNCEL-1/LNRELN-6:plmnId:mnc=6
...    LNCEL-1/LNRELN-6:plmnId:mncLength=2
...    LNCEL-1/LNRELN-6:removeAllowed=false
@{LNRELN8}
...    LNCEL-1/LNRELN-8:cellIdentity=114718
...    LNCEL-1/LNRELN-8:psHoAllowed=allowed
...    LNCEL-1/LNRELN-8:plmnId:mcc=262
...    LNCEL-1/LNRELN-8:plmnId:mnc=8
...    LNCEL-1/LNRELN-8:plmnId:mncLength=2
...    LNCEL-1/LNRELN-8:removeAllowed=true
@{LNRELN9}
...    LNCEL-1/LNRELN-9:cellIdentity=114719
...    LNCEL-1/LNRELN-9:psHoAllowed=allowed
...    LNCEL-1/LNRELN-9:plmnId:mcc=262
...    LNCEL-1/LNRELN-9:plmnId:mnc=9
...    LNCEL-1/LNRELN-9:plmnId:mncLength=2
...    LNCEL-1/LNRELN-9:removeAllowed=true
@{LNRELN10}
...    LNCEL-1/LNRELN-10:cellIdentity=114720
...    LNCEL-1/LNRELN-10:psHoAllowed=allowed
...    LNCEL-1/LNRELN-10:plmnId:mcc=262
...    LNCEL-1/LNRELN-10:plmnId:mnc=10
...    LNCEL-1/LNRELN-10:plmnId:mncLength=2
...    LNCEL-1/LNRELN-10:removeAllowed=true
@{LNRELN11}
...    LNCEL-1/LNRELN-11:cellIdentity=114721
...    LNCEL-1/LNRELN-11:psHoAllowed=allowed
...    LNCEL-1/LNRELN-11:plmnId:mcc=262
...    LNCEL-1/LNRELN-11:plmnId:mnc=11
...    LNCEL-1/LNRELN-11:plmnId:mncLength=2
...    LNCEL-1/LNRELN-11:removeAllowed=true
@{LNRELN12}
...    LNCEL-1/LNRELN-12:cellIdentity=114722
...    LNCEL-1/LNRELN-12:psHoAllowed=allowed
...    LNCEL-1/LNRELN-12:plmnId:mcc=262
...    LNCEL-1/LNRELN-12:plmnId:mnc=12
...    LNCEL-1/LNRELN-12:plmnId:mncLength=2
...    LNCEL-1/LNRELN-12:removeAllowed=true
@{LNRELN1_cell2}
...    LNCEL-2/LNRELN-1:cellIdentity=114711
...    LNCEL-2/LNRELN-1:psHoAllowed=allowed
...    LNCEL-2/LNRELN-1:plmnId:mcc=211
...    LNCEL-2/LNRELN-1:plmnId:mnc=1
...    LNCEL-2/LNRELN-1:plmnId:mncLength=2
...    LNCEL-2/LNRELN-1:removeAllowed=false
@{LNRELN8_cell2}
...    LNCEL-2/LNRELN-8:cellIdentity=114718
...    LNCEL-2/LNRELN-8:psHoAllowed=allowed
...    LNCEL-2/LNRELN-8:plmnId:mcc=468
...    LNCEL-2/LNRELN-8:plmnId:mnc=1
...    LNCEL-2/LNRELN-8:plmnId:mncLength=2
...    LNCEL-2/LNRELN-8:removeAllowed=true

@{LNRELN2_created}
...    LNCEL-1/LNRELN-255:cellIdentity=114712
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=2
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2
...    LNCEL-1/LNRELN-255:removeAllowed=true

@{LNRELN3_created}
...    LNCEL-1/LNRELN-254:cellIdentity=114713
...    LNCEL-1/LNRELN-254:psHoAllowed=allowed
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=3
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2
...    LNCEL-1/LNRELN-254:removeAllowed=true

@{LNRELN5_created}
...    LNCEL-1/LNRELN-253:cellIdentity=114715
...    LNCEL-1/LNRELN-253:psHoAllowed=allowed
...    LNCEL-1/LNRELN-253:plmnId:mcc=262
...    LNCEL-1/LNRELN-253:plmnId:mnc=5
...    LNCEL-1/LNRELN-253:plmnId:mncLength=2
...    LNCEL-1/LNRELN-253:removeAllowed=true

@{LNRELN11_created}
...    LNCEL-1/LNRELN-252:cellIdentity=114721
...    LNCEL-1/LNRELN-252:psHoAllowed=allowed
...    LNCEL-1/LNRELN-252:plmnId:mcc=262
...    LNCEL-1/LNRELN-252:plmnId:mnc=11
...    LNCEL-1/LNRELN-252:plmnId:mncLength=2
...    LNCEL-1/LNRELN-252:removeAllowed=true

@{LNRELN12_created}
...    LNCEL-1/LNRELN-251:cellIdentity=114722
...    LNCEL-1/LNRELN-251:psHoAllowed=allowed
...    LNCEL-1/LNRELN-251:plmnId:mcc=262
...    LNCEL-1/LNRELN-251:plmnId:mnc=12
...    LNCEL-1/LNRELN-251:plmnId:mncLength=2
...    LNCEL-1/LNRELN-251:removeAllowed=true

@{LNRELN13_created}
...    LNCEL-1/LNRELN-250:cellIdentity=114723
...    LNCEL-1/LNRELN-250:psHoAllowed=allowed
...    LNCEL-1/LNRELN-250:plmnId:mcc=262
...    LNCEL-1/LNRELN-250:plmnId:mnc=13
...    LNCEL-1/LNRELN-250:plmnId:mncLength=2
...    LNCEL-1/LNRELN-250:removeAllowed=true

@{LNRELN14_created}
...    LNCEL-1/LNRELN-249:cellIdentity=114724
...    LNCEL-1/LNRELN-249:psHoAllowed=allowed
...    LNCEL-1/LNRELN-249:plmnId:mcc=262
...    LNCEL-1/LNRELN-249:plmnId:mnc=14
...    LNCEL-1/LNRELN-249:plmnId:mncLength=2
...    LNCEL-1/LNRELN-249:removeAllowed=true

@{LNRELN6_created_case07}
...    LNCEL-1/LNRELN-255:cellIdentity=114716
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=6
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2
...    LNCEL-1/LNRELN-255:removeAllowed=true

@{LNRELN7_created_case07}
...    LNCEL-1/LNRELN-254:cellIdentity=114717
...    LNCEL-1/LNRELN-254:psHoAllowed=allowed
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=7
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2
...    LNCEL-1/LNRELN-254:removeAllowed=true

@{LNRELN2_created_case06}
...    LNCEL-1/LNRELN-254:cellIdentity=114712
...    LNCEL-1/LNRELN-254:psHoAllowed=allowed
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=2
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2
...    LNCEL-1/LNRELN-254:removeAllowed=true

@{LNRELN7_created_case06}
...    LNCEL-1/LNRELN-255:cellIdentity=114717
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=7
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2
...    LNCEL-1/LNRELN-255:removeAllowed=true

${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208030
...    4218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820610
...    40105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E000
...    20406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A00000061000880014207F80226A02

${ue_nr_capabilities}    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000C039
...    F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D802802010040118028030100401004
...    600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064104208
...    000210410809A55334A262B9515DA8AEC4
${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B02004040C1803A020000000FD00000000081B8981002020E2680000103F400000000206E360400818103071340000101FA00000
...    00010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B000804180004020001008000402
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

@{A_B6_c_CASE09_manual_mocs_clean_up}
...    delete:LNCEL-1/LNRELN-5
...    delete:LNCEL-1/LNRELN-11
...    delete:LNCEL-1/LNRELN-12

@{A_B6_c_CASE07}
...    @{LNADJN-PCI7_case07}
...    @{LNADJNL-PCI7_1_case07}
...    @{LNADJNL-PCI7_2_case07}
...    @{LNADJN-PCI7_3_case07}
...    @{LNADJNL-PCI7_3_case07}
...    @{LNADJNL-PCI7_4_case07}
...    @{LNADJN-PCI7_5_case07}
...    @{LNADJNL-PCI7_5_case07}
...    @{LNADJNL-PCI7_6_case07}
...    @{LNRELN5}

@{LNADJN-PCI7_case07}
...    LNADJN-1:arfcnValueNR=629984
...    LNADJN-1:multiFrequencyBandList=78
...    LNADJN-1:physCellIdNr=7

@{LNADJNL-PCI7_1_case07}
...    LNADJN-1/LNADJNL-1:cellIdentity=114711
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=1
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=1
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2

@{LNADJNL-PCI7_2_case07}
...    LNADJN-1/LNADJNL-2:cellIdentity=114712
...    LNADJN-1/LNADJNL-2:gnbIdLength=22
...    LNADJN-1/LNADJNL-2:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-2:gNBplmnId:mnc=2
...    LNADJN-1/LNADJNL-2:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-2:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-2:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-2:plmnIdList:mnc=2
...    LNADJN-1/LNADJNL-2:plmnIdList:mncLength=2

@{LNADJN-PCI7_3_case07}
...    LNADJN-3:arfcnValueNR=629984
...    LNADJN-3:multiFrequencyBandList=78
...    LNADJN-3:physCellIdNr=7

@{LNADJNL-PCI7_3_case07}
...    LNADJN-3/LNADJNL-3:cellIdentity=114713
...    LNADJN-3/LNADJNL-3:gnbIdLength=22
...    LNADJN-3/LNADJNL-3:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-3:gNBplmnId:mnc=3
...    LNADJN-3/LNADJNL-3:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-3:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-3:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-3:plmnIdList:mnc=3
...    LNADJN-3/LNADJNL-3:plmnIdList:mncLength=2

@{LNADJNL-PCI7_4_case07}
...    LNADJN-3/LNADJNL-4:cellIdentity=114714
...    LNADJN-3/LNADJNL-4:gnbIdLength=22
...    LNADJN-3/LNADJNL-4:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-4:gNBplmnId:mnc=4
...    LNADJN-3/LNADJNL-4:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-4:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-4:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-4:plmnIdList:mnc=4
...    LNADJN-3/LNADJNL-4:plmnIdList:mncLength=2

@{LNADJN-PCI7_5_case07}
...    LNADJN-5:arfcnValueNR=629984
...    LNADJN-5:multiFrequencyBandList=78
...    LNADJN-5:physCellIdNr=7

@{LNADJNL-PCI7_5_case07}
...    LNADJN-5/LNADJNL-5:cellIdentity=114715
...    LNADJN-5/LNADJNL-5:gnbIdLength=22
...    LNADJN-5/LNADJNL-5:gNBplmnId:mcc=262
...    LNADJN-5/LNADJNL-5:gNBplmnId:mnc=5
...    LNADJN-5/LNADJNL-5:gNBplmnId:mncLength=2
...    LNADJN-5/LNADJNL-5:trackingAreaCodeNR=33
...    LNADJN-5/LNADJNL-5:plmnIdList:mcc=262
...    LNADJN-5/LNADJNL-5:plmnIdList:mnc=5
...    LNADJN-5/LNADJNL-5:plmnIdList:mncLength=2

@{LNADJNL-PCI7_6_case07}
...    LNADJN-5/LNADJNL-6:cellIdentity=114716
...    LNADJN-5/LNADJNL-6:gnbIdLength=22
...    LNADJN-5/LNADJNL-6:gNBplmnId:mcc=262
...    LNADJN-5/LNADJNL-6:gNBplmnId:mnc=6
...    LNADJN-5/LNADJNL-6:gNBplmnId:mncLength=2
...    LNADJN-5/LNADJNL-6:trackingAreaCodeNR=33
...    LNADJN-5/LNADJNL-6:plmnIdList:mcc=262
...    LNADJN-5/LNADJNL-6:plmnIdList:mnc=6
...    LNADJN-5/LNADJNL-6:plmnIdList:mncLength=2

@{LNADJNL-PCI7_create_7_case07}
...    LNADJN-5/LNADJNL-11:cellIdentity=114717
...    LNADJN-5/LNADJNL-11:gnbIdLength=22
...    LNADJN-5/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-5/LNADJNL-11:gNBplmnId:mnc=7
...    LNADJN-5/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-5/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-5/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-5/LNADJNL-11:plmnIdList:mnc=7
...    LNADJN-5/LNADJNL-11:plmnIdList:mncLength=2

@{LNADJNL-PCI7_case06_exist_PLMN}
...    LNADJN-1/LNADJNL-1:cellIdentity=114799
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=2
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=2
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2

@{LNADJNL-PCI7_7_case06}
...    LNADJN-1/LNADJNL-2:cellIdentity=114717
...    LNADJN-1/LNADJNL-2:gnbIdLength=22
...    LNADJN-1/LNADJNL-2:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-2:gNBplmnId:mnc=7
...    LNADJN-1/LNADJNL-2:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-2:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-2:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-2:plmnIdList:mnc=7
...    LNADJN-1/LNADJNL-2:plmnIdList:mncLength=2

@{LNADJNL-PCI7_create_2_case06}
...    LNADJN-1/LNADJNL-11:cellIdentity=114712
...    LNADJN-1/LNADJNL-11:gnbIdLength=22
...    LNADJN-1/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-11:gNBplmnId:mnc=2
...    LNADJN-1/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-11:plmnIdList:mnc=2
...    LNADJN-1/LNADJNL-11:plmnIdList:mncLength=2

@{A_B6_c_CASE06}
...    @{LNADJN-PCI7_case07}
...    @{LNADJNL-PCI7_case06_exist_PLMN}
...    @{LNADJNL-PCI7_7_case06}

${NRARFCN630000}
...    629984

@{contain_MOC_A_B6-c_09}
...    @{LNADJN-PCI2}
...    @{LNADJNL-PCI2_1}
...    @{LNADJN-PCI7}
...    @{LNADJNL-PCI7_6}
...    @{LNADJNL-PCI7_7}
...    @{LNADJN-PCI2_2}
...    @{LNADJNL-PCI2_15}
...    @{LNADJN-PCI7_2}
...    @{LNADJNL-PCI7_8_update}
...    @{LNADJNL-PCI7_9}
...    @{LNADJNL-PCI7_10}
...    @{LNADJNL-PCI7_create_2}
...    @{LNADJNL-PCI7_create_3}
...    @{LNADJNL-PCI7_create_5}
...    @{LNADJNL-PCI7_create_11}
...    @{LNADJNL-PCI7_create_12}
...    @{LNADJNL-PCI7_create_13}
...    @{LNADJNL-PCI7_create_14}
...    @{LNRELN1}
...    @{LNRELN6}
...    @{LNRELN8}
...    @{LNRELN9}
...    @{LNRELN10}
...    @{LNRELN2_created}
...    @{LNRELN3_created}
...    @{LNRELN5_created}
...    @{LNRELN11_created}
...    @{LNRELN12_created}
...    @{LNRELN13_created}
...    @{LNRELN14_created}

@{not_contain_MOC_A_B6-c_09}
...    @{LNADJNL-PCI2_2}
...    @{LNADJNL-PCI2_3}
...    @{LNADJNL-PCI2_4}
...    @{LNADJNL-PCI2_11}
...    @{LNADJNL-PCI2_12}
...    @{LNADJNL-PCI2_13}
...    @{LNADJNL-PCI2_14}
...    @{LNADJNL-PCI7_5}

@{unlockcell}
...    LNCEL-1:administrativeState=unlocked

@{delete_MOCs_CASE09_1}
...    delete:LNCEL-1/LNRELN-1
...    delete:LNCEL-1/LNRELN-6
...    delete:LNCEL-1/LNRELN-8
...    delete:LNCEL-1/LNRELN-9
...    delete:LNCEL-1/LNRELN-10
...    delete:LNCEL-1/LNRELN-249
...    delete:LNCEL-1/LNRELN-250
...    delete:LNCEL-1/LNRELN-251
...    delete:LNCEL-1/LNRELN-252
...    delete:LNCEL-1/LNRELN-253
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-255
...    @{A_B6_c_CASE09_manual_mocs_clean_up}
...    delete:LNADJN-1
...    delete:LNADJN-2
...    delete:LNADJN-3
...    delete:LNADJN-4
...    LNCEL-1:administrativeState=locked

@{contain_MOC_A_B6-c_07}
...    @{LNADJN-PCI7_case07}
...    @{LNADJNL-PCI7_1_case07}
...    @{LNADJNL-PCI7_2_case07}
...    @{LNADJN-PCI7_3_case07}
...    @{LNADJNL-PCI7_3_case07}
...    @{LNADJNL-PCI7_4_case07}
...    @{LNADJN-PCI7_5_case07}
...    @{LNADJNL-PCI7_6_case07}
...    @{LNADJNL-PCI7_create_7_case07}
...    @{LNRELN6_created_case07}
...    @{LNRELN7_created_case07}

@{not_contain_MOC_A_B6-c_07}
...    @{LNADJNL-PCI7_5_case07}
...    @{LNRELN5}

@{delete_MOCs_CASE07_1}
...    delete:LNCEL-1/LNRELN-5
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-1
...    delete:LNADJN-3
...    delete:LNADJN-5

@{contain_MOC_A_B6-c_06}
...    @{LNADJN-PCI7_case07}
...    @{LNADJNL-PCI7_create_2_case06}
...    @{LNADJNL-PCI7_7_case06}
...    @{LNRELN2_created_case06}
...    @{LNRELN7_created_case06}

@{not_contain_MOC_A_B6-c_06}
...    @{LNADJNL-PCI7_case06_exist_PLMN}

@{delete_MOCs_CASE06_1}
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-1
...    delete:LNADJN-511

@{delete_MOCs_UPD008_CASE02_1}
...    delete:LNCEL-1/LNRELN-1
...    delete:LNCEL-1/LNRELN-2
...    delete:LNCEL-1/LNRELN-3
...    delete:LNADJN-1
...    delete:LNADJN-3

@{A_B8_UPD008_case2}
...    @{LNADJN-PCI7_UPD008}
...    @{LNADJNL-PCI7_9_UPD008}
...    @{LNADJNL-PCI7_2_UPD008}
...    @{LNRELN9_UPD008}
...    @{LNRELN2_UPD008}

@{LNADJN-PCI7_UPD008}
...    LNADJN-1:arfcnValueNR=629984
...    LNADJN-1:multiFrequencyBandList=78
...    LNADJN-1:physCellIdNr=7

@{LNADJNL-PCI7_9_UPD008}
...    LNADJN-1/LNADJNL-1:cellIdentity=114719
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=3
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=3
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2

@{LNADJNL-PCI7_2_UPD008}
...    LNADJN-1/LNADJNL-2:cellIdentity=114712
...    LNADJN-1/LNADJNL-2:gnbIdLength=22
...    LNADJN-1/LNADJNL-2:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-2:gNBplmnId:mnc=2
...    LNADJN-1/LNADJNL-2:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-2:trackingAreaCodeNR=66
...    LNADJN-1/LNADJNL-2:plmnIdList:mnc=2|mcc=262
...    LNADJN-1/LNADJNL-2:plmnIdList:mncLength=2|mcc=262
...    LNADJN-1/LNADJNL-2:plmnIdList:mnc=1|mcc=466
...    LNADJN-1/LNADJNL-2:plmnIdList:mncLength=2|mcc=466

@{LNRELN9_UPD008}
...    LNCEL-1/LNRELN-1:cellIdentity=114719
...    LNCEL-1/LNRELN-1:psHoAllowed=allowed
...    LNCEL-1/LNRELN-1:plmnId:mcc=262
...    LNCEL-1/LNRELN-1:plmnId:mnc=3
...    LNCEL-1/LNRELN-1:plmnId:mncLength=2
...    LNCEL-1/LNRELN-1:removeAllowed=true

@{LNRELN2_UPD008}
...    LNCEL-1/LNRELN-2:cellIdentity=114712
...    LNCEL-1/LNRELN-2:psHoAllowed=allowed
...    LNCEL-1/LNRELN-2:plmnId:mcc=262
...    LNCEL-1/LNRELN-2:plmnId:mnc=2
...    LNCEL-1/LNRELN-2:plmnId:mncLength=2
...    LNCEL-1/LNRELN-2:removeAllowed=true

@{create_CGI3}
...    @{LNADJN-PCI7_3}
...    @{LNADJNL-PCI7_3}
...    @{LNRELN3}

@{LNADJN-PCI7_3}
...    LNADJN-3:arfcnValueNR=629984
...    LNADJN-3:multiFrequencyBandList=78
...    LNADJN-3:physCellIdNr=7

@{LNADJNL-PCI7_3}
...    LNADJN-3/LNADJNL-3:cellIdentity=114713
...    LNADJN-3/LNADJNL-3:gnbIdLength=22
...    LNADJN-3/LNADJNL-3:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-3:gNBplmnId:mnc=3
...    LNADJN-3/LNADJNL-3:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-3:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-3:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-3:plmnIdList:mnc=3
...    LNADJN-3/LNADJNL-3:plmnIdList:mncLength=2

@{LNRELN3}
...    LNCEL-1/LNRELN-3:cellIdentity=114713
...    LNCEL-1/LNRELN-3:psHoAllowed=forbidden
...    LNCEL-1/LNRELN-3:plmnId:mcc=262
...    LNCEL-1/LNRELN-3:plmnId:mnc=3
...    LNCEL-1/LNRELN-3:plmnId:mncLength=2
...    LNCEL-1/LNRELN-3:removeAllowed=true

@{contain_MOC_A_B8-UPD008_02}
...    @{LNADJN-PCI7_UPD008}
...    @{LNADJNL-PCI7_9_UPD008}
...    @{LNADJNL-PCI7_2_UPD008}
...    @{LNADJN-PCI7_3}
...    @{LNADJNL-PCI7_3}

@{not_contain_MOC_A_B8-UPD008_02}
...    @{LNRELN9_UPD008}
...    @{LNRELN2_UPD008}
...    @{LNRELN3}

${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}',
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

*** Test Cases ***
CB005825-SR-A-B6-c_ET_09_01_verification with LNADJNL update and removeAllowed is false
    [Tags]
    Delta Commission Parameters    ${A_B6_C_case9}
    set RSC and reportCGI auto report for case09
    Attach UE and check RSC CGI triggered as expected    ue_id=11    pci=7
    Object Should Exist    ${contain_MOC_A_B6-c_09}
    Object Should Not Exist    ${not_contain_MOC_A_B6-c_09}
    [teardown]    delete all MOCs

CB005825-SR-A-B6-c_ET_07_01_verification with exist same number LNADJNLs in LNADJN with same tuple entry
    [Tags]
    Delta Commission Parameters    ${A_B6_c_CASE07}
    report B2 to make tuple tobeverified    ue_id=1    pci=7    narfcn=629984
    set RSC and reportCGI auto report for case07
    Attach UE and check RSC CGI triggered as expected    ue_id=12    pci=7
    Object Should Exist    ${contain_MOC_A_B6-c_07}
    Object Should Not Exist    ${not_contain_MOC_A_B6-c_07}
    [teardown]    delete case07 MOCs

CB005825-SR-A-B6-c_ET_06_01_verification with exist orphan LNADJNL with same PLMN
    [Tags]
    Delta Commission Parameters    ${A_B6_c_CASE06}
    report B2 to make tuple tobeverified    ue_id=1    pci=7    narfcn=629984
    set RSC and reportCGI auto report for case06
    Attach UE and check RSC CGI triggered as expected    ue_id=13    pci=7
    Object Should Exist    ${contain_MOC_A_B6-c_06}
    Object Should Not Exist    ${not_contain_MOC_A_B6-c_06}
    [teardown]    delete case06 MOCs

CB005825-SR-A-B8-UPD008_ET_02_01_re-verification with exist nosib or not and with no TAC in measurement report
    [Tags]
    Delta Commission Parameters    ${A_B8_UPD008_case2}
    set RSC and reportCGI auto report
    Attach UE and check RSC CGI triggered as expected    ue_id=14    pci=7
    Delta Commission Parameters    ${create_CGI3}
    trigger re-verification due to NRHO fail
    Attach UE and check RSC CGI triggered as expected    ue_id=15    pci=7
    Object Should Not Exist    ${not_contain_MOC_A_B8-UPD008_02}
    Object Should Exist    ${contain_MOC_A_B8-UPD008_02}
    report B2 to make tuple tobeverified    ue_id=2    pci=6    narfcn=629984
    Attach UE and check RSC CGI triggered as expected    ue_id=16    pci=6
    [teardown]    delete UPD008_case02 MOCs

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
    Execute Uex Command    ue_param id=1 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=2 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=11-16 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=11-16 nr_supported_bands=78,258
    Execute Egate Command    ue_enb_param id=1,2,11,12,13,14,15,16 spid=34

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
    ...        - {id: 22, technology: lte, tac: 33, pci: '9:1', earfcn: '5920:23920', bw: 20}
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
    ...        - {id: 41, technology: lte, tac: 33, pci: '2:1', eci: '0x0000B20', earfcn: '1400:19400', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 5
    ...      type: simulated
    ...      enb_id_macro: 0x0000C
    ...      plmn: '262:03'
    ...      s1: 10.0.1.6
    ...      cells:
    ...        - {id: 51, technology: lte, tac: 33, pci: '2:0', eci: '0x0000C21', earfcn: '1400:19400', bw: 20}
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
    [Arguments]    ${ue_id}=1    ${cellid}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cellid}
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
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=2036672    ${cellid}=1
    UE attach to cell1    ue_id=${ue_id}    cellid=${cellid}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    7
        Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    END
    UE detach    ue_id=${ue_id}

Attach UE and check RSC CGI triggered as expected
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN630000}    ${pci}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and (purpose eq 'reportStrongestCells'))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and (cellForWhichToReportCGI-r15 eq ${pci}))
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC

delete all MOCs
    Release All UEs
    Delta Commission Parameters    ${delete_MOCs_CASE09_1}
    Delta Commission Parameters    ${unlockcell}
    Cells Should Be Onair
    Common Test Teardown And Stop Capture Logs

delete case07 MOCs
    Release All UEs
    Delta Commission Parameters    ${delete_MOCs_CASE07_1}
    Delta Commission Parameters    ${unlockcell}
    Cells Should Be Onair
    Common Test Teardown And Stop Capture Logs

delete case06 MOCs
    Release All UEs
    Delta Commission Parameters    ${delete_MOCs_CASE06_1}
    Delta Commission Parameters    ${unlockcell}
    Cells Should Be Onair
    Common Test Teardown And Stop Capture Logs

delete UPD008_case02 MOCs
    Release All UEs
    Delta Commission Parameters    ${delete_MOCs_UPD008_CASE02_1}
    Delta Commission Parameters    ${unlockcell}
    Cells Should Be Onair
    Common Test Teardown And Stop Capture Logs

set RSC and reportCGI auto report for case09
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=11 if_contains=purpose with_value=reportStrongestCells action=measurement_send narfcn=629984
    ...    phycell_id=7 nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:01|${nci-114711} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:02|${nci-114712} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:03|${nci-114713} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:05|${nci-114715} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:06|${nci-114716} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:08|${nci-114718} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:09|${nci-114719} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:10|${nci-114720} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:11|${nci-114721} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:12|${nci-114722} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:13|${nci-114723} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:14|${nci-114724} freq_band_list=78 tac=33
    Run Uex Command    ${cmd}

set RSC and reportCGI auto report for case07
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=12 if_contains=purpose with_value=reportStrongestCells action=measurement_send narfcn=629984
    ...    phycell_id=7 nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:06|${nci-114716} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:07|${nci-114717} freq_band_list=78 tac=33
    Run Uex Command    ${cmd}

set RSC and reportCGI auto report for case06
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=13 if_contains=purpose with_value=reportStrongestCells action=measurement_send narfcn=629984
    ...    phycell_id=7 nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:02|${nci-114712} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:07|${nci-114717} freq_band_list=78 tac=33
    Run Uex Command    ${cmd}

set RSC and reportCGI auto report for UE14
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=14 if_contains=purpose with_value=reportStrongestCells action=measurement_send narfcn=629984
    ...    phycell_id=7 nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03|${nci-114719} freq_band_list=78 tac=33
    ...    cgi_plmn_group cgi=262:02,466:01|${nci-114712} freq_band_list=78 tac=66
    Run Uex Command    ${cmd}

set RSC and reportCGI auto report for UE15
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=15 if_contains=purpose with_value=reportStrongestCells action=measurement_send narfcn=629984
    ...    phycell_id=7 nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03|${nci-114719} freq_band_list=78
    Run Uex Command    ${cmd}

set RSC and reportCGI auto report for UE16
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=16 if_contains=purpose with_value=reportStrongestCells action=measurement_send narfcn=629984
    ...    phycell_id=6 nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03|${nci-114719} freq_band_list=78 nr_cgi_nosib1=1:1
    Run Uex Command    ${cmd}

trigger re-verification due to NRHO fail
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    UE attach to cell1    ue_id=1
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=1
    Flow Occurred As Expected    alias=B2_RRC
    Expect message flow
    ...    MME_1:S1AP_HandoverRequired (HandoverType eq 'eps-to-5gs')
    ...    UE_1:RRC_MobilityFromEUTRACommand (mobilityFromEUTRACommand-r8 is present)
    ...    UE_1:RRC_RRCConnectionReestablishmentComplete (rrcConnectionReestablishmentComplete-r8 is present)
    ...    alias=NRHO_FAIL    overall_timeout=20
    Run Uex Command    ue_rrc_mobility_from_eutra_param id=1 nth=1 action=reestablish cell=1 cause=handoverFailure
    Execute Uex Command    ue_measurement_send id=1 event=B2_NR phycell_id=7 nrsrp=97 srsrp=0 nsinr=20 narfcn=629984 amount=1
    Flow Occurred As Expected    alias=NRHO_FAIL

set RSC and reportCGI auto report
    set RSC and reportCGI auto report for UE14
    set RSC and reportCGI auto report for UE15
    set RSC and reportCGI auto report for UE16
