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
...    @{CB007334}
...    @{inactive_timer}
...    @{LTE5226}
...    @{LTE4549}
...    @{CA}
...    @{CB005825}
...    @{CB007333}

@{PARAMS_IN_SWCONFIG}
...    ${Uec_TUecRadMaxValueOfNrPciCounter}=20
...    ${Uec_TUecRadMaxSizeOfNrPciCounters}=20
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
${NRARFCN2036667}    2036672    #258
${GSCN22325}    2036539     #
${NRARFCN630000}    629984     #78
${NRARFCN524100}    524128     #41
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
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbSubcarrierSpacing=120kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:nrCarPrio=8
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:carrierFreqNrCell=${NRARFCN524100}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:freqBandIndicatorNrL:freqBandIndicatorNr=41
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:ssbSubcarrierSpacing=120kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:nrCarPrio=8
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
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:nrPciNbrRelAddHyst=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:nrPciNbrRelAddThresh=5
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:nrPciNbrRelAddHyst=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:nrPciNbrRelAddThresh=5
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:quantityConfigId=0

@{CB007333}
...    LNBTS:actEndcAutoX2Setup=true
@{CB007334}
...    LNBTS:actUeBasedAnrNr=true
...    LNBTS/ANR-0:actAutoNrNeighRemoval=true
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelRemThresh=50000
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/ANR-0:anrNrNbrRelRemGuardTime=72
...    LNBTS/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mnc=3|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelRemThresh=50000
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0
...    LNBTS:actX2gNB128=true
...    LNBTS:maxNumNrCellgNB=256
...    LNBTS:maxNumNrCell=32768
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:gNBIdLength=22|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:paramMeasConfId=1|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:paramPlmnId=0|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:gNBIdLength=22|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:paramMeasConfId=1|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:paramPlmnId=0|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|carrierFreqNrCell=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:gNBIdLength=22|carrierFreqNrCell=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:paramMeasConfId=1|carrierFreqNrCell=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:paramPlmnId=0|carrierFreqNrCell=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|carrierFreqNrCell=${NRARFCN524100}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN524100}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:gNBIdLength=24|carrierFreqNrCell=${NRARFCN524100}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:paramMeasConfId=1|carrierFreqNrCell=${NRARFCN524100}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:paramPlmnId=0|carrierFreqNrCell=${NRARFCN524100}

@{set_guardtimer_RemThresh}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelRemThresh=380000
...    LNBTS/ANR-0:anrNrNbrRelRemGuardTime=2
...    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=2
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelRemThresh=380000
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddHyst=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddThresh=5
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddHyst=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddThresh=5

@{LNRELN_254}
...    LNCEL-1/LNRELN-254:plmnId:mcc=262

@{measParamId2}
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=56|paramMeasConfId=2
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-10|paramMeasConfId=2
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:carrierFreqNrCell=${NRARFCN2036667}|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:gNBIdLength=22|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:frqNrCarSelect=Single Carrier|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:paramMeasConfId=2|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamList:carrierFreqNrCell=123456|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamList:gNBIdLength=22|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamList:frqNrCarSelect=Single Carrier|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamList:paramMeasConfId=1|paramPlmnId=1

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
...    0x771b
...    0x7654
...    0x7699
...    0x769A
...    0x769B
...    0x76B4
...    0x76B5
...    0x750A
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
...    @{CB005825_ANR}
...    LNCEL-1:actDrx=true

@{CB005825_ANR}
...    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=72
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS/ANR-0:consec5gHoFailThres=15
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=true
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mnc=3|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=1
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=22|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=24|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=23|carrierFreqNrCell=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN524100}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=1|carrierFreqNrCell=${NRARFCN524100}


@{CB007742}
...    LNBTS:actHOtoNR=true
...    LNBTS:actSelMobPrf=true
...    LNBTS:tS1RelOvDeltN=5000
...    LNBTS:tS1RelPrepN=5000
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actFlexQCIARPPMProfiles=true
...    LNBTS/MODPR-0:freqLayListPsHoNR=${NRARFCN2036667},${GSCN22325},${NRARFCN630000},${NRARFCN524100}
...    LNBTS/MODPR-0:freqLayListPsHoNRVoLte=${NRARFCN2036667},${GSCN22325},${NRARFCN630000},${NRARFCN524100}
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
...    LNCEL-1/LNHON-1:ssbDuration=sf2
...    LNCEL-1/LNHON-1:ssbOffset=0
...    LNCEL-1/LNHON-1:ssbPeriodicity=sf10-r15
...    LNCEL-1/LNHON-1:ssbSubcarrierSpacing=30kHz
...    LNCEL-1/LNHON-1:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    LNCEL-1/LNHON-1:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    LNCEL-1/LNHON-1:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    LNCEL-1/LNHON-1:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4
...    LNCEL-1/LNHON-1:nrPciHoNbrRelAddThresh=5
...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=380000
...    LNCEL-1/LNHON-1:nrPciHoNbrCounterDecay=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b1HysThresholdRsrp=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b1HysThresholdRsrq=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b1ReportAmount=r1
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b1ReportInterval=60min
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b1ThresholdRsrp=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b1TimeToTriggerRsrp=256ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b1TimeToTriggerRsrq=256ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b1TriggerQuantity=RSRP
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b2NrBeamReportQuantity=None
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b2NrCellReportQuantity=RSRP
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b2NrReportIntervalRsrp=480ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b2NrTimeToTriggerRsrpMeas=320ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b2Threshold1RsrpNr=40
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:b2Threshold2RsrpNr=56
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:carrierFreqNr=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:hysB2NrThresholdRsrp=4
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:nrCarPrio5GSACapMobility=1
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:nrPciHoNbrCounterDecay=1000
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:nrPciHoNbrRelAddThresh=5
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:nrPciHoNbrRelRemThresh=100000
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:nrQuantityConfigSetId=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:offsetFreqNr=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:ssbDuration=sf2
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:ssbOffset=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:ssbPeriodicity=sf10-r15
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:ssbSubcarrierSpacing=30kHz
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:freqBandIndicatorListNr=78
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4

...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:b2Threshold2RsrpNr=56
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:carrierFreqNr=${GSCN22325}
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:hysB2NrThresholdRsrp=4
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:nrCarPrio5GSACapMobility=1
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:nrPciHoNbrCounterDecay=1000
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:nrPciHoNbrRelAddThresh=5
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:nrPciHoNbrRelRemThresh=100000
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:nrQuantityConfigSetId=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:offsetFreqNr=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:ssbDuration=sf2
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:ssbOffset=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:ssbPeriodicity=sf10-r15
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:ssbSubcarrierSpacing=30kHz
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:freqBandIndicatorListNr=258
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:b2Threshold2RsrpNr=56
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:carrierFreqNr=${NRARFCN524100}
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:hysB2NrThresholdRsrp=4
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:nrCarPrio5GSACapMobility=1
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:nrPciHoNbrCounterDecay=1000
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:nrPciHoNbrRelAddThresh=5
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:nrPciHoNbrRelRemThresh=100000
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:nrQuantityConfigSetId=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:offsetFreqNr=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:ssbDuration=sf2
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:ssbOffset=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:ssbPeriodicity=sf10-r15
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:ssbSubcarrierSpacing=30kHz
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:freqBandIndicatorListNr=41
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:rsrqB2NrMobilityParams:b2NrReportIntervalRsrqNr=640ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:rsrqB2NrMobilityParams:b2NrTimeToTrigRsrqMeasNr=480ms
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:rsrqB2NrMobilityParams:b2Threshold1RsrqNr=8
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:rsrqB2NrMobilityParams:hysB2NrThresholdRsrqNr=4

${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C10820803
...    04218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B08200828410518208384100414208206
...    1040105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0
...    B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71
...    E00020406080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C0600002404061304D0A1E01BFE0000050000003
...    080044000A103FC02135010A00
# above support both 7334 NRANR and 7742 HO to 5GSA
${ue_eutra_capabilities_without_ANR}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C10820803
...    04218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820
...    61040105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E
...    71E00020406080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C0600002404061304D0A1E01BFE00000500000
...    030800440008103FC02135010A00

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
...    {id: 75, technology: nr , tac: 33, pci: '1:2', nrci: '0x1F', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}',
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

@{LNRELN_CGI1_114719}
...    LNCEL-1/LNRELN-255:cellIdentity=114719
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNRELN_CGI1_114719_B1}
...    @{LNRELN_CGI1_114719}
...    LNCEL-1/LNRELN-254:cellIdentity=115970
...    LNCEL-1/LNRELN-254:psHoAllowed=allowed
...    LNCEL-1/LNRELN-254:removeAllowed=true
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=5
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2

@{LNADJN_CGI1_114719}
...    LNADJN-511:arfcnValueNR=2036672
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=5

@{LNADJN_CGI1_114719_PCI3}
...    LNADJN-511:arfcnValueNR=2036672
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=3

@{LNADJNL_CGI1_114719}
...    LNADJN-511/LNADJNL-11:cellIdentity=114719
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-511/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2

@{LNADJNL_CGI1_114719_B1}
...    LNADJN-511/LNADJNL-11:cellIdentity=114719
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNBTS/LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=3
...    LNBTS/LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=4
...    LNADJN-511/LNADJNL-10:cellIdentity=115970
...    LNADJN-511/LNADJNL-10:gnbIdLength=22
...    LNADJN-511/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-10:gNBplmnId:mnc=5
...    LNADJN-511/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-10:trackingAreaCodeNR=33
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=5
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=6

@{LNRELGNBCELL_CGI1_114719}
...    LNCEL-1/LNRELGNBCELL-255:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-255:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-255:nrCellId=114719
...    LNCEL-1/LNRELGNBCELL-255:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-255:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-255:nrCgiPlmnId:mncLength=2

@{LNADJGNB_CGI1_114719}
...    LNADJGNB-127:adjGnbId=7
...    LNADJGNB-127:administrativeState=unlocked
...    LNADJGNB-127:cPlaneIpAddrCtrl=enbControlled
...    LNBTS-1/LNADJGNB-127:x2ToGnbLinkStatus=available

@{case_created_MO}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELGNBCELL-255
...    delete:LNADJN-511
...    delete:LNADJN-1
...    delete:LNADJGNB-127
...    delete:LNCEL-1/LNRELN-1

@{RSRP_1_RSRQ_2}
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=${EMPTY}|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=${EMPTY}|paramMeasConfId=2
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-10|paramMeasConfId=2

@{ParamPlmnId}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=2
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamList:paramPlmnId=1
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamPlmnList:mcc=262|mnc=3
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamPlmnList:paramPlmnId=1|mnc=3
...    MRBTS-1/LNBTS-1/ANR-0:anrNrParamPlmnList:paramPlmnId=2|mnc=4

@{LNRELN_CGI1_114719_PLMN4}
...    LNCEL-1/LNRELN-255:cellIdentity=114719
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=4
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNADJNL_CGI1_114719_B1_PLMN4}
...    LNADJN-511/LNADJNL-11:cellIdentity=114719
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=4
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNBTS/LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=3
...    LNBTS/LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=4

@{gnbblacklist}
...    LNBTS-1/ANR-0:glNbGnbIdBlackList:gnbId=1
...    LNBTS-1/ANR-0:glNbGnbIdBlackList:gnbIdRange=7
...    LNBTS-1/ANR-0:glNbGnbIdBlackList:mcc=262
...    LNBTS-1/ANR-0:glNbGnbIdBlackList:mnc=3

@{LNRELN_CGI1_115970_PLMN4}
...    LNCEL-1/LNRELN-255:cellIdentity=115970
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=4
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNADJN_CGI1_114719_PCI4}
...    LNADJN-511:arfcnValueNR=2036672
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=4

@{LNADJNL_CGI1_115970_B1_PLMN4_2}
...    LNADJN-511/LNADJNL-11:cellIdentity=115970
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=4
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNBTS/LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=6
...    LNBTS/LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=4

@{LNADJN_case26_after}
...    LNADJN-511:arfcnValueNR=2036672
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=6

@{5825_MO}
...    LNADJN-511:arfcnValueNR=2036672
...    LNCEL-1/LNRELN-255:plmnId:mcc=262

@{7334_MO}
...    LNCEL-1/LNRELGNBCELL-254:nrCgiPlmnId:mcc=262

@{LNADJNL_case26_after}
...    LNADJN-511/LNADJNL-11:cellIdentity=114719
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-511/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2

@{LNRELN_case26_after}
...    LNCEL-1/LNRELN-255:cellIdentity=114719
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2


*** Test Cases ***
CB005825-A-B11_ET_26_01_RSC procedure blackcellslist should exclude all NR ANR verlication list
    [Tags]
    [Documentation]
    ...     precondition:
    ...     "NR-report-CGI verification list"
    ...    F1/PCI5 tobeverified
    ...    F1/PCI2 tobeverified
    ...    F1/PCI4 verified
    ...    F1/PCI3 verified
    ...    F1/PCI9 initial
    ...    F2/PCI2 tobeverified
    ...    F3/PCI3 tobeverified
    ...    F2/PCI10 inital
    ...    "NR-report-CGI verification list for 5GHo"
    ...    F1/PCI4 verified
    ...    F1/PCI1 verified
    ...    F1/PCI6 tobeverified
    ...    F1/PCI7 tobeverified
    ...    F1/PCI8 initial
    ...    F2/PCI5 tobeverified
    ...    F3/PCI3 tobeverified
    ...    F2+PCI9 initial
    ...    step1:attach UE to verify F1/PCI1, blacklist is 3,4,1,8,9
    ...    step2:attach UE to verify F1/PCI6, blacklist is 1,4,5,8,9
    create verification list for 5GHO and ENDC
    Attach UE11 to verify tuple PCI5 and check MO
    Attach UE12 to verify tuple PCI6 and check MO
    [Teardown]    restore for case and common teardown

CB005825-A-B11_ET_01_01_both ENDC and 5GHO MO can be created successfully initial with RSC and same measParamId
    [Tags]
    [Documentation]
    ...    step1: report 6 times B2 and 6 times B1 make 2036672+pci5 is in ENDC and 5GHO list
    ...    step2: attach UE, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report, report CGI is triggered
    ...           send CGI report
    ...    step3: ENDC MO for 2036672+pci5 created and do ENDC succeed
    ...           5GHO MO for 2036672+pci5 created and do 5GHO succeed
    ...    step4: report 6 times B2 and 6 times B1 for 2036672+pci4 to make 2036672+pci5 pcicount decay to be less than 3.8
    ...    step5: wait anrNrNbrRelRemGuardTime
    ...    step6: ENDC MO for 2036672+pci5 deleted
    ...           5GHO MO for 2036672+pci5 deleted
    Delta Commission Parameters    ${set_guardtimer_RemThresh}
    report B2 and B1 multuple times to make tuple tobeverified for both ENDC and SAHO    pci=5
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=13    pci=5
    check LNRELGNBCELL LNADJGNB and LNRELN LNADJNL is created correctly
    Do HO to created MO succeed    pci=5    nrarfcn=2036672    ue_id=2
    Do ENDC to created MO succeed    pci=5    nrarfcn=2036672    ue_id=3
    report B2 and B1 multuple times to make tuple tobeverified for both ENDC and SAHO    pci=4
    check LNRELGNBCELL LNADJGNB and LNRELN is deleted after anrNrHoNbrRelRemGuardTime
    [Teardown]    restore for case and common teardown


CB005825-A-B11_ET_08_01_only 5GHO MO can be created successfully initial with B1-reportOnLeave and different measParamId
    [Tags]
    [Documentation]
    ...    precondition: ENDC and 5GHO use different measParamId with different threshold
    ...    step1: report 6 times B2 and 6 times B1 make 2036672+pci5 is in ENDC and 5GHO list
    ...    step2: attach UE, send B1 threshold > 5GHO and < ENDC
    ...    step3: report CGI is triggered and send valid CGI report
    ...    step4: check 5GHO MO for 2036672+pci5 created and ENDC MO for 2036672+pci5 not created
    ...    step5: config thresholdNrRsrp for ENDC and thresholdNrRsrq for SAHO
    ...    step6: repeat step 1-4
    Make ENDC and 5GHO use different measParamId
    report B2 and B1 multuple times to make tuple tobeverified for both ENDC and SAHO    pci=5
    Attach UE and send B1 and CGI report to check only ENDC MO created correctly for threshold1
    delete created MO
    config thresholdNrRsrp for ENDC and thresholdNrRsrq for SAHO
    report B2 and B1 multuple times to make tuple tobeverified for both ENDC and SAHO    pci=5
    Attach UE and send B1 and CGI report to check only ENDC MO created correctly for threshold2
    [Teardown]    restore for case and common teardown

CB005825-A-B11_ET_15_01_no MO created for report CGI timeout for both ENDC and 5GHO
    [Tags]
    [Documentation]
    ...    precondition: ENDC and 5GHO use different measParamId with different threshold
    ...    step1: report 6 times B2 and 6 times B1 make 2036672+pci5 is in ENDC and 5GHO list
    ...    step2: attach UE, send B1 and report CGI is triggered
    ...    step3: wait report CGI timeout
    ...    step4: check neither 5GHO MO nor ENDC MO for 2036672+pci5 for 2036672+pci5 created
    ...    step5: attach UE, send B1 and report CGI report, check MO created
    report B2 and B1 multuple times to make tuple tobeverified for both ENDC and SAHO    pci=3
    Attach UE and check no MO is created for no CGI report received
    Attach UE and check MO is created correctly after send valid report
    [Teardown]    restore for case and common teardown

CB005825-A-B11_ET_19_01_only 5GHO MO can be created successfully when report CGI failed for ENDC
    [Tags]
    [Documentation]
    ...    precondition: ENDC and 5GHO use different ParamPlmnId with different PLMN
    ...    step1: report 6 times B2 and 6 times B1 make 2036672+pci5 is in ENDC and 5GHO list
    ...    step2: attach UE, send B1 and CGI report with 5GHO PLMN
    ...    step3: check 5GHO MO for 2036672+pci5 created and ENDC MO for 2036672+pci5 not created
    ...    step4: delete created MO and repeat step1
    ...    step5: add gnbid 7 into blacklist
    ...    step6: attach UE, send B1 and CGI report with PLMN both for 5GHO and ENDC
    ...    step7: check 5GHO MO for 2036672+pci5 created and ENDC MO for 2036672+pci5 not created
    Make ENDC and 5GHO use different ParamPlmnId
    report B2 and B1 multuple times to make tuple tobeverified for both ENDC and SAHO    pci=5
    Attach UE and send CGI report with 5GHO PLMN
    check 5GHO MO created and ENDC MO is not created for blank PLMN
    Delta Commission Parameters    ${gnbblacklist}
    report B2 and B1 multuple times to make tuple tobeverified for both ENDC and SAHO    pci=4
    Attach UE and send CGI report with 5GHO and ENDC PLMN
    check 5GHO MO created and ENDC MO is not created for gnbidblacklist
    [Teardown]    restore for case and common teardown



*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias for multi UEs
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Set UE parameters for ENDC capability
    trigger X2 UP between enb2 and gnb7
Create UE Alias for multi UEs
    FOR    ${ue_id}    IN RANGE    1    20
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    ue_enb_param id=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 spid=34
    Config gnb7
    Config UE11 to UE20 support NRANR

Config UE11 to UE20 support NRANR
    FOR    ${ue_id}    IN RANGE    11    21
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
    Update Yaml    UEs/UE_sets/17     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/18     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/19     bearer: bearer_set_2

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
    ...        - {id: 31, technology: lte, tac: 33, pci: '1:2', eci: '0x0000A1F', earfcn: '1400:19400', bw: 20}

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

Trigger UE1 to send B2-NR for freq with PCI1
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${narfcn} amount=1

Trigger UE to send B1-NR for freq with PCI
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20
    ...    narfcn=${narfcn} amount=1
    Execute Uex Command     ${cmd}

clean CB005825 verification list
    Block Cell1
    Unblock Cell1

Attach UE and send B1 MR
    [Arguments]    ${ue_id}=1    ${pci}=1
    UE attach to cell1    ue_id=${ue_id}
    UE report B1NR    ue_id=${ue_id}    pci=${pci}

UE report B1NR
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} phycell_id=${pci} nrsrp=98 event=B1_NR
    Run Uex Command    ${cmd}

report B2 to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN2036667}    ${pci}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ...    ${times}=7
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities_without_ANR}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    ${times}
        Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${nrarfcn}
    END
    UE detach    ue_id=${ue_id}

report B2 and B1 multuple times to make tuple tobeverified for both ENDC and SAHO
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=B1_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities_without_ANR}
    Flow Occurred As Expected    alias=B1_RRC
    FOR    ${temp}    IN RANGE    1    7
        Trigger UE to send B1-NR for freq with PCI    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
        sleep    1s    #between B1
    END
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    7
        Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
        sleep    1s    #between B2
    END
    UE detach    ue_id=${ue_id}

Trigger UE to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34    #B2    timeout=5s

Case setup
    Common Test Setup And Start To Capture Logs
    clean CB005825 verification list

set RSC CGI auto report with CGI1
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
        ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nci-114719} tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

Wait CGI process succeed
    sleep    8s    #wait CGI succeed

Do HO to created MO succeed
    [Arguments]    ${pci}=1    ${nrarfcn}=2036672    ${ue_id}=1
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    Expect message flow
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (radioNetwork eq "successful-handover"))
    ...    alias=HO_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    Sleep    1s
    Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Sleep    1s
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${nrarfcn} amount=1
    sleep    2s     #wait HO completed
    Flow Occurred As Expected    alias=HO_RRC
    UE detach    ue_id=${ue_id}


Trigger UE1 to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34

Do ENDC to created MO succeed
    [Arguments]    ${pci}=1    ${nrarfcn}=2036672    ${ue_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    ENB_1:X2AP_SgNBAdditionRequest (qCI eq 8)
    ...    ENB_1:X2AP_SgNBReconfigurationComplete (success-SgNBReconfComp is present)
    ...    alias=ENDC_RRC    overall_timeout=20
    Attach UE and send B1 MR    pci=${pci}    ue_id=${ue_id}
    sleep    5s    #wait CGI complete
    UE detach    ${ue_id}
    Flow Occurred As Expected    alias=ENDC_RRC

delete created MO
    Delta Commission Parameters    ${case_created_MO}

Make ENDC and 5GHO use different measParamId
    Delta Commission Parameters    ${measParamId2}

send B1NR report with set CGI auto report
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrarfcn}=2036672    ${plmn}=3
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=56 nrsrq=77 cgi_plmn_group cgi=262:${plmn},262:4|${nci-114719} tac=33
    ...    cgi_plmn_group cgi=262:5,262:6|0x1C502 tac=33 freq_band_list=258
    ...    phycell_id=2 narfcn=2036672 nrsrp=25 nrsrq=22 cgi=262:3,262:5|0x1C502 tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

send B1NR report with value larger than only one threshold and set CGI auto report
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=2036672 nrsrp=55 nrsrq=76 cgi_plmn_group cgi=262:3,262:4|${nci-114719} tac=33
    ...    cgi_plmn_group cgi=262:5,262:6|0x1C502 tac=33 freq_band_list=258
    ...    phycell_id=2 narfcn=2036672 nrsrp=25 nrsrq=22 cgi=262:3,262:5|0x1C502 tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

Config thresholdNrRsrp for ENDC and thresholdNrRsrq for SAHO
    Delta Commission Parameters    ${RSRP_1_RSRQ_2}

UE attached and check RSC and CGI triggered and cleanup is done
    [Arguments]    ${ue_id}    ${pci}=1
    ${RSC1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (purpose eq 'reportStrongestCells') and (s-Measure eq 0))
    ${CGI1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI') and (s-Measure eq 75))
    ${cleanup1_message}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) )
    Expect message flow
    ...    ${RSC1_messsage}
    ...    ${CGI1_messsage}
    ...    ${cleanup1_message}
    ...    alias=NRANR_RRC    overall_timeout=30
    set RSC CGI auto report with CGI1    ue_id=${ue_id}    pci=${pci}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC

trigger X2 UP between enb2 and gnb7
    Execute Egate Command    link_x2_up_enb enb=2 target=7
    Execute Egate Command    enb_conf_update enb=2 mme=1 connected_en_gnb_to_add=7

report B1 multuple times to make tuple tobeverified for ENDC
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}    ${times}=7
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=B1_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities_without_ANR}
    Flow Occurred As Expected    alias=B1_RRC
    FOR    ${temp}    IN RANGE    1    ${times}
        Trigger UE to send B1-NR for freq with PCI    ue_id=${ue_id}    pci=${pci}    narfcn=${nrarfcn}
    END
    UE detach    ue_id=${ue_id}

send B1NR report
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=2036672 nrsrp=56 nrsrq=77
    Run Uex Command    ${cmd}

Make ENDC and 5GHO use different ParamPlmnId
    Delta Commission Parameters    ${ParamPlmnId}

send B1NR report with set CGI auto report of 5GHO PLMN
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=2036672 nrsrp=56 nrsrq=77 cgi_plmn_group cgi=262:4,262:3|${nci-114719} tac=33
    ...    cgi_plmn_group cgi=262:5,262:6|0x1C502 tac=33 freq_band_list=258
    ...    phycell_id=2 narfcn=2036672 nrsrp=25 nrsrq=22 cgi=262:3,262:5|0x1C502 tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

send B1NR report with set CGI auto report of 5GHO and ENDC PLMN
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=2036672 nrsrp=56 nrsrq=77 cgi_plmn_group cgi=262:3|${nci-114719} tac=33
    ...    cgi_plmn_group cgi=262:4,262:6|0x1C502 tac=33 freq_band_list=258
    ...    phycell_id=2 narfcn=2036672 nrsrp=25 nrsrq=22 cgi=262:3,262:5|0x1C502 tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

Make tuple verified by ENDC
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}    ${plmn}=3
    report B1 multuple times to make tuple tobeverified for ENDC    nrarfcn=${nrarfcn}    pci=${pci}
    UE attach to cell1    ue_id=1
    send B1NR report with set CGI auto report    ue_id=1    nrarfcn=${nrarfcn}    pci=${pci}    plmn=${plmn}
    Wait CGI process succeed
    UE detach    ue_id=1

make tuple verified by 5GHO
    [Arguments]    ${nrarfcn}=${NRARFCN2036667}    ${pci}=1
    report B2 to make tuple tobeverified    ue_id=1    nrarfcn=${nrarfcn}    pci=${pci}
    UE attach to cell1    ue_id=1
    send B1NR report with set CGI auto report    ue_id=1    nrarfcn=${nrarfcn}    pci=${pci}
    Wait CGI process succeed
    UE detach    ue_id=1

restore for case and common teardown
    delete created MO
    Common Test Teardown And Stop Capture Logs


create verification list for 5GHO and ENDC
    modify maxMumAnrMoiAllowed to be 19
    make tuple verified by ENDC    nrarfcn=${NRARFCN2036667}    pci=4    plmn=7
    make tuple verified by ENDC    nrarfcn=${NRARFCN2036667}    pci=3    plmn=6
    make tuple verified by 5GHO    nrarfcn=${NRARFCN2036667}    pci=4
    make tuple verified by 5GHO    nrarfcn=${NRARFCN2036667}    pci=1
    make tuples to be verified
    make tuples to initial
    modify maxMumAnrMoiAllowed to be 50

make tuples to be verified
    report B1 multuple times to make tuple tobeverified for ENDC    nrarfcn=${NRARFCN2036667}    pci=5
    report B1 multuple times to make tuple tobeverified for ENDC    nrarfcn=${NRARFCN2036667}    pci=2
    report B1 multuple times to make tuple tobeverified for ENDC    nrarfcn=${GSCN22325}    pci=2
    report B1 multuple times to make tuple tobeverified for ENDC    nrarfcn=${NRARFCN630000}    pci=3
    report B2 to make tuple tobeverified    nrarfcn=${NRARFCN2036667}    pci=6
    report B2 to make tuple tobeverified    nrarfcn=${NRARFCN2036667}    pci=7
    report B2 to make tuple tobeverified    nrarfcn=${GSCN22325}    pci=5
    report B2 to make tuple tobeverified    nrarfcn=${NRARFCN630000}    pci=3

make tuples to initial
    report B1 multuple times to make tuple tobeverified for ENDC    nrarfcn=${NRARFCN2036667}    pci=9    times=3
    report B1 multuple times to make tuple tobeverified for ENDC    nrarfcn=${GSCN22325}    pci=10    times=4
    report B2 to make tuple tobeverified    nrarfcn=${NRARFCN2036667}    pci=8    times=3
    report B2 to make tuple tobeverified    nrarfcn=${GSCN22325}    pci=9     times=4

Attach UE11 to verify tuple PCI5 and check MO
    set RSC CGI auto report with CGI1    ue_id=11    nrarfcn=${NRARFCN2036667}    pci=5
    Attach UE and check RSC CGI triggered as expected and check excludedCellsToRemoveList    ue_id=11    nrarfcn=${NRARFCN2036667}    pci=5
    Object Should Exist    ${LNRELGNBCELL_CGI1_114719}
    Object Should Exist    ${LNADJGNB_CGI1_114719}
    Object Should not Exist    ${5825_MO}
    sleep    2s    #wait message OK
    report B1 multuple times to make tuple tobeverified for ENDC    nrarfcn=${NRARFCN2036667}    pci=9    times=2
    report B2 to make tuple tobeverified    nrarfcn=${NRARFCN2036667}    pci=8    times=2

Attach UE and check RSC CGI triggered as expected and check excludedCellsToRemoveList
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN2036667}    ${pci}=5
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci})) as CGI_RRC
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (purpose eq 'reportStrongestCells') and
    ...    (excludedCellsToAddModList-r15 contains (
    ...    physCellId-r15 eq 9,
    ...    physCellId-r15 eq 3,
    ...    physCellId-r15 eq 4,
    ...    physCellId-r15 eq 8,
    ...    physCellId-r15 eq 1
    ...    )))
    Expect message flow
    ...    ${RSC_RRC}
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC
    verify unique field equals values in message    NRANR_RRC    CGI_RRC    excludedCellsToRemoveList-r15=1,2,3,4,5

Attach UE and RSC CGI triggered and check excludedCellsToRemoveList
    [Arguments]    ${ue_id}=1    ${nrarfcn}=${NRARFCN2036667}    ${pci}=1
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci})) as CGI_RRC
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (purpose eq 'reportStrongestCells') and
    ...    (excludedCellsToAddModList-r15 contains (
    ...    physCellId-r15 eq 9,
    ...    physCellId-r15 eq 8,
    ...    physCellId-r15 eq 1,
    ...    physCellId-r15 eq 4,
    ...    physCellId-r15 eq 5
    ...    )))
    Expect message flow
    ...    ${RSC_RRC}
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC
    verify unique field equals values in message    NRANR_RRC    CGI_RRC    excludedCellsToRemoveList-r15=1,2,3,4,5

Attach UE12 to verify tuple PCI6 and check MO
    set RSC CGI auto report with CGI1    ue_id=12    nrarfcn=${NRARFCN2036667}    pci=6
    Attach UE and RSC CGI triggered and check excludedCellsToRemoveList    ue_id=12    nrarfcn=${NRARFCN2036667}    pci=6
    Object Should Exist    ${LNADJN_case26_after}
    Object Should Exist    ${LNADJNL_case26_after}
    Object Should Exist    ${LNRELN_case26_after}
    Object Should not Exist    ${LNRELN_254}
    Object Should not Exist    ${7334_MO}

Attach UE and send CGI report with 5GHO PLMN
    [Arguments]    ${ue_id}=8    ${nrarfcn}=${NRARFCN2036667}    ${pci}=5
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci}))
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    send B1NR report with set CGI auto report of 5GHO PLMN    ue_id=${ue_id}    pci=${pci}
    Flow Occurred As Expected    alias=NRANR_RRC
    UE detach    ue_id=${ue_id}

check 5GHO MO created and ENDC MO is not created for blank PLMN
    Object Should Exist    ${LNRELN_CGI1_114719_PLMN4}
    Object Should Exist    ${LNADJN_CGI1_114719}
    Object Should Exist    ${LNADJNL_CGI1_114719_B1_PLMN4}
    Object Should not Exist    ${LNRELGNBCELL_CGI1_114719}
    Object Should not Exist    ${LNADJGNB_CGI1_114719}
    delete created MO

Attach UE and send CGI report with 5GHO and ENDC PLMN
    [Arguments]    ${ue_id}=9    ${nrarfcn}=${NRARFCN2036667}    ${pci}=4
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci}))
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    send B1NR report with set CGI auto report of 5GHO and ENDC PLMN    ue_id=${ue_id}    pci=${pci}
    Flow Occurred As Expected    alias=NRANR_RRC
    UE detach    ue_id=${ue_id}

check 5GHO MO created and ENDC MO is not created for gnbidblacklist
    Object Should not Exist    ${LNRELGNBCELL_CGI1_114719}
    Object Should not Exist    ${LNADJGNB_CGI1_114719}
    Object Should Exist    ${LNRELN_CGI1_115970_PLMN4}
    Object Should Exist    ${LNADJN_CGI1_114719_PCI4}
    Object Should Exist    ${LNADJNL_CGI1_115970_B1_PLMN4_2}

modify maxMumAnrMoiAllowed to be ${NUMBER}
    Delta Commission Parameters    LNBTS-1:maxNumAnrMoiAllowed=${NUMBER}

check LNRELGNBCELL LNADJGNB and LNRELN is deleted after anrNrHoNbrRelRemGuardTime
    sleep    2min    #anrNrHoNbrRelRemGuardTime=anrNrNbrRelRemGuardTime
    Object Should not Exist    ${LNRELN_CGI1_114719}
    Object Should Exist    ${LNADJN_CGI1_114719}
    Object Should Exist    ${LNADJNL_CGI1_114719}
    Object Should not Exist    ${LNRELGNBCELL_CGI1_114719}
    Object Should not Exist    ${LNADJGNB_CGI1_114719}

check LNRELGNBCELL LNADJGNB and LNRELN LNADJNL is created correctly
    Object Should Exist    ${LNRELN_CGI1_114719}
    Object Should Exist    ${LNADJN_CGI1_114719}
    Object Should Exist    ${LNADJNL_CGI1_114719}
    Object Should Exist    ${LNRELGNBCELL_CGI1_114719}
    Object Should Exist    ${LNADJGNB_CGI1_114719}

Attach UE and send B1 and CGI report to check only ENDC MO created correctly for threshold1
    [Arguments]    ${ue_id}=4    ${nrarfcn}=${NRARFCN2036667}    ${pci}=5
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci}))
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    send B1NR report with value larger than only one threshold and set CGI auto report    ue_id=${ue_id}    pci=${pci}
    Flow Occurred As Expected    alias=NRANR_RRC
    check MOs for case8
    UE detach    ue_id=${ue_id}

check MOs for case8
    Object Should Exist    ${LNRELN_CGI1_114719_B1}
    Object Should Exist    ${LNADJN_CGI1_114719}
    Object Should Exist    ${LNADJNL_CGI1_114719_B1}
    Object Should not Exist    ${LNRELGNBCELL_CGI1_114719}
    Object Should not Exist    ${LNADJGNB_CGI1_114719}

Attach UE and send B1 and CGI report to check only ENDC MO created correctly for threshold2
    [Arguments]    ${ue_id}=5    ${nrarfcn}=${NRARFCN2036667}    ${pci}=5
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci}))
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    send B1NR report with value larger than only one threshold and set CGI auto report    ue_id=${ue_id}    pci=${pci}
    Flow Occurred As Expected    alias=NRANR_RRC
    UE detach    ue_id=${ue_id}
    check MOs for case8

Attach UE and check no MO is created for no CGI report received
    [Arguments]    ${ue_id}=6    ${nrarfcn}=${NRARFCN2036667}    ${pci}=3
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci}))
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    send B1NR report    ue_id=${ue_id}    pci=${pci}
    Flow Occurred As Expected    alias=NRANR_RRC
    UE detach    ue_id=${ue_id}
    check MOs for case15 without CGI report

check MOs for case15 without CGI report
    Object Should not Exist    ${LNRELN_CGI1_114719_B1}
    Object Should not Exist    ${LNADJN_CGI1_114719_PCI3}
    Object Should not Exist    ${LNADJNL_CGI1_114719_B1}
    Object Should not Exist    ${LNRELGNBCELL_CGI1_114719}
    Object Should not Exist    ${LNADJGNB_CGI1_114719}

Attach UE and check MO is created correctly after send valid report
    [Arguments]    ${ue_id}=7    ${nrarfcn}=${NRARFCN2036667}    ${pci}=3
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and
    ...    (cellForWhichToReportCGI-r15 eq ${pci}))
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=NRANR_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    send B1NR report with set CGI auto report    ue_id=${ue_id}    pci=${pci}
    Flow Occurred As Expected    alias=NRANR_RRC
    UE detach    ue_id=${ue_id}
    check Mos for case15 with valid CGI report

check Mos for case15 with valid CGI report
    Object Should Exist    ${LNRELN_CGI1_114719_B1}
    Object Should Exist    ${LNADJN_CGI1_114719_PCI3}
    Object Should Exist    ${LNADJNL_CGI1_114719_B1}
    Object Should Exist    ${LNRELGNBCELL_CGI1_114719}
    Object Should Exist    ${LNADJGNB_CGI1_114719}