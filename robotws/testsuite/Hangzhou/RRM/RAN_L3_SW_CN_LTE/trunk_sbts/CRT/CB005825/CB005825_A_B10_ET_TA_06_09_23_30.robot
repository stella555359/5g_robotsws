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
...    @{LTE5003}
...    @{LTE4549}
...    @{CA}
...    @{CB005825}
...    @{CB007333}

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
${NRARFCN2036667}    2036672    #B258 F1 FR2
${GSCN22325}    2036539    #B258 F3 FR2
${NRARFCN630000}    629984     #B78 F2 FR1
${NRARFCN524100}    524128     #B41 F4 FR1
${NRARFCN636666}    636704    #B78 F5 FR1

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
...    LNBTS/ANR-0:actAutoNrNeighRemoval=false
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

@{LNADJGNB}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22

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
${nci-115969}    0x1C501
${nci-115970}    0x1C502
${nci-114719}    0x1C01F
${nci-115975}    0x1C507

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
...    LNCEL:measQuantityNr=RSRP
...    LNCEL:t304InterRATN=500ms
...    LNCEL:a2TimeToTriggerActNRMeas=320ms
...    LNCEL:threshold2NR=25
...    LNCEL:hysThreshold2NR=0
...    @{CB007742}
...    LNBTS:actUeBasedAnrNrHo=true
...    @{CB005825_ANR}
...    LNCEL:actDrx=true

@{LTE5003}
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNCEL:actFlowCtrlEnh=true

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
...    @{ANR_F1}
...    @{ANR_F2}
...    @{ANR_F3}
...    @{ANR_F4}
...    @{ANR_F5}

@{ANR_F1}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=22|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=${NRARFCN2036667}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=${NRARFCN2036667}
@{ANR_F3}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=24|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=${GSCN22325}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=${GSCN22325}
@{ANR_F2}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=23|carrierFreqNrCell=${NRARFCN630000}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=${NRARFCN630000}
@{ANR_F4}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN524100}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=${NRARFCN524100}
@{ANR_F5}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|carrierFreqNrCell=${NRARFCN636666}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|carrierFreqNrCell=${NRARFCN636666}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=${NRARFCN636666}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:gNBIdLength=24|carrierFreqNrCell=${NRARFCN636666}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramMeasConfId=1|carrierFreqNrCell=${NRARFCN636666}
...    MRBTS-1/LNBTS-1/ANR-0:anrNrHoParamList:paramPlmnId=0|carrierFreqNrCell=${NRARFCN636666}

@{no_ANR_F2_F3_F4_Single}
...    @{ANR_F1}

@{CB007742}
...    LNBTS:actHOtoNR=true
...    LNBTS:actSelMobPrf=true
...    LNBTS:tS1RelOvDeltN=5000
...    LNBTS:tS1RelPrepN=5000
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actFlexQCIARPPMProfiles=true
...    LNBTS/MODPR-0:freqLayListPsHoNR=${NRARFCN2036667},${GSCN22325},${NRARFCN630000},${NRARFCN524100},629999,629998
...    LNBTS/MODPR-0:freqLayListPsHoNRVoLte=${NRARFCN2036667},${GSCN22325},${NRARFCN630000},${NRARFCN524100},629999,629998
...    @{CB007742_LNHON}

@{CB007742_LNHON}
...    @{LNHON_1_cell1}
...    @{LNHON_2_cell1}
...    @{LNHON_3_cell1}
...    @{LNHON_4_cell1}

@{LNHON_1_cell1}
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
...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=300000
...    LNCEL-1/LNHON-1:nrPciHoNbrCounterDecay=0
@{LNHON_2_cell1}
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
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:nrPciHoNbrCounterDecay=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:nrPciHoNbrRelAddThresh=5
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-2:nrPciHoNbrRelRemThresh=300000
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

@{LNHON_3_cell1}
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:b2Threshold2RsrpNr=56
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:carrierFreqNr=${GSCN22325}
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:hysB2NrThresholdRsrp=4
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:nrCarPrio5GSACapMobility=1
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:nrPciHoNbrCounterDecay=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:nrPciHoNbrRelAddThresh=5
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-3:nrPciHoNbrRelRemThresh=300000
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
@{LNHON_4_cell1}
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:b2Threshold2RsrpNr=56
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:carrierFreqNr=${NRARFCN524100}
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:hysB2NrThresholdRsrp=4
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:nrCarPrio5GSACapMobility=1
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:nrPciHoNbrCounterDecay=0
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:nrPciHoNbrRelAddThresh=5
...    MRBTS-1/LNBTS-1/LNCEL-1/LNHON-4:nrPciHoNbrRelRemThresh=300000
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
...    E00020406080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C0600002404061304D0A1E01BFE000005000000
...    3080044000A103FC02135010A00
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
${ue_eutra_capabilities_without_ANR}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C10820803
...    04218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820
...    61040105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E
...    71E00020406080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C0600002404061304D0A1E01BFE00000500000
...    030800440008103FC02135010A00
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

@{extend_anrNrCoverageConfirmTimer}
...    LNBTS-1/ANR-0:anrNrCoverageConfirmTimer=12000

@{active_5825}
...    LNBTS:actUeBasedAnrNrHo=true
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=true

@{deactive_5825}
...    LNBTS:actUeBasedAnrNrHo=false
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=false

@{active_7334}
...    LNBTS:actUeBasedAnrNr=true
...    LNBTS/ANR-0:actAutoNrNeighRemoval=true

@{active_7334 and timer set}
...    @{active_7334}
...    LNBTS-1/ANR-0:anrNrInactivityTimer=5

@{deactive_7334}
...    LNBTS:actUeBasedAnrNr=false
...    LNBTS/ANR-0:actAutoNrNeighRemoval=false

@{precondition_case23}
...    @{deactive_7334}
...    @{active_5825}
...    @{extend_anrNrCoverageConfirmTimer}
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=0min
...    LNBTS-1/ANR-0:anrNrHoNbrRelRemGuardTime=72
...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=460000
...    LNBTS-1/ANR-0:anrNrInactivityTimer=5

@{precondition_case30}
...    @{deactive_7334}
...    @{active_5825}
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=10min
...    LNBTS-1/ANR-0:anrNrHoNbrRelRemGuardTime=2
...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=400000
...    @{extend_anrNrCoverageConfirmTimer}
...    LNBTS-1/ANR-0:anrNrInactivityTimer=5

@{anrNrNbrHoRelVerifyPeriod_10min}
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=10min

@{anrNrNbrHoRelVerifyPeriod_0min}
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=0min
@{extend_anrNrCoverageConfirmTimer}
...    LNBTS-1/ANR-0:anrNrCoverageConfirmTimer=12000

@{precondition_case6}
...    @{active_7334}
...    @{active_5825}
...    @{extend_anrNrCoverageConfirmTimer}
...    @{LNADJN_1_PCI1}
...    @{LNADJNL_1_115969}
...    @{LNRELN_1_115969}
...    @{LNADJN_2_PCI2}
...    @{LNADJNL_2_115970}
...    @{LNRELN_2_115970}
...    LNBTS-1/ANR-0:anrNrInactivityTimer=10
...    @{LNRELGNBCELL_CGI1}
...    @{LNRELGNBCELL_CGI2}
...    @{LNADJGNB}

@{precondition_case9}
...    @{active_7334}
...    @{active_5825}
...    @{extend_anrNrCoverageConfirmTimer}
...    @{F1_PCI2_MO_cell1_cell2}
...    @{F2_PCI3_MO_cell1_cell2}
...    LNBTS-1/ANR-0:anrNrInactivityTimer=5

@{F1_PCI2_MO_cell1_cell2}
...    @{LNADJN_1_PCI2}
...    @{LNADJNL_1_CGI1_114719}
...    @{LNRELN_1_CGI1_114719}
...    @{LNRELN_2_CGI1_114719_cell2}

@{F2_PCI3_MO_cell1_cell2}
...    @{LNADJN_2_PCI3}
...    @{LNADJNL_2_CGI3}
...    @{LNRELN_2_CGI3_cell1}
...    @{LNRELN_3_CGI3_cell2}

@{LNADJN_1_PCI2}
...    LNADJN-1:arfcnValueNR=2036672
...    LNADJN-1:multiFrequencyBandList=258
...    LNADJN-1:physCellIdNr=2

@{LNADJNL_1_CGI1_114719}
...    LNADJN-1/LNADJNL-1:cellIdentity=114719
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=8
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=8
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2

@{LNRELN_1_CGI1_114719}
...    LNCEL-1/LNRELN-1:cellIdentity=114719
...    LNCEL-1/LNRELN-1:psHoAllowed=allowed
...    LNCEL-1/LNRELN-1:removeAllowed=true
...    LNCEL-1/LNRELN-1:plmnId:mcc=262
...    LNCEL-1/LNRELN-1:plmnId:mnc=8
...    LNCEL-1/LNRELN-1:plmnId:mncLength=2

@{LNADJNL_4_CGI4_114719}
...    LNADJN-4/LNADJNL-4:cellIdentity=114719
...    LNADJN-4/LNADJNL-4:gnbIdLength=22
...    LNADJN-4/LNADJNL-4:gNBplmnId:mcc=262
...    LNADJN-4/LNADJNL-4:gNBplmnId:mnc=10
...    LNADJN-4/LNADJNL-4:gNBplmnId:mncLength=2
...    LNADJN-4/LNADJNL-4:trackingAreaCodeNR=33
...    LNADJN-4/LNADJNL-4:plmnIdList:mcc=262
...    LNADJN-4/LNADJNL-4:plmnIdList:mnc=10
...    LNADJN-4/LNADJNL-4:plmnIdList:mncLength=2

@{LNRELN_4_CGI4_114719}
...    LNCEL-1/LNRELN-4:cellIdentity=114719
...    LNCEL-1/LNRELN-4:psHoAllowed=allowed
...    LNCEL-1/LNRELN-4:removeAllowed=true
...    LNCEL-1/LNRELN-4:plmnId:mcc=262
...    LNCEL-1/LNRELN-4:plmnId:mnc=10
...    LNCEL-1/LNRELN-4:plmnId:mncLength=2

@{LNRELN_2_CGI1_114719_cell2}
...    LNCEL-2/LNRELN-2:cellIdentity=114719
...    LNCEL-2/LNRELN-2:psHoAllowed=allowed
...    LNCEL-2/LNRELN-2:removeAllowed=true
...    LNCEL-2/LNRELN-2:plmnId:mcc=262
...    LNCEL-2/LNRELN-2:plmnId:mnc=8
...    LNCEL-2/LNRELN-2:plmnId:mncLength=2

@{LNADJN_2_PCI3}
...    LNADJN-2:arfcnValueNR=629984
...    LNADJN-2:multiFrequencyBandList=258
...    LNADJN-2:physCellIdNr=3

@{LNADJNL_2_CGI3}
...    LNADJN-2/LNADJNL-2:cellIdentity=114719
...    LNADJN-2/LNADJNL-2:gnbIdLength=22
...    LNADJN-2/LNADJNL-2:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-2:gNBplmnId:mnc=9
...    LNADJN-2/LNADJNL-2:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-2:trackingAreaCodeNR=33
...    LNADJN-2/LNADJNL-2:plmnIdList:mcc=262
...    LNADJN-2/LNADJNL-2:plmnIdList:mnc=9
...    LNADJN-2/LNADJNL-2:plmnIdList:mncLength=2

@{LNRELN_2_CGI3_cell1}
...    LNCEL-1/LNRELN-2:cellIdentity=114719
...    LNCEL-1/LNRELN-2:psHoAllowed=allowed
...    LNCEL-1/LNRELN-2:removeAllowed=true
...    LNCEL-1/LNRELN-2:plmnId:mcc=262
...    LNCEL-1/LNRELN-2:plmnId:mnc=9
...    LNCEL-1/LNRELN-2:plmnId:mncLength=2

@{LNRELN_3_CGI3_cell2}
...    LNCEL-2/LNRELN-3:cellIdentity=114719
...    LNCEL-2/LNRELN-3:psHoAllowed=allowed
...    LNCEL-2/LNRELN-3:removeAllowed=true
...    LNCEL-2/LNRELN-3:plmnId:mcc=262
...    LNCEL-2/LNRELN-3:plmnId:mnc=9
...    LNCEL-2/LNRELN-3:plmnId:mncLength=2

@{LNADJN_1_PCI1}
...    LNADJN-1:arfcnValueNR=2036672
...    LNADJN-1:multiFrequencyBandList=258
...    LNADJN-1:physCellIdNr=1
@{LNADJN_4_PCI4}
...    LNADJN-4:arfcnValueNR=2036672
...    LNADJN-4:multiFrequencyBandList=258
...    LNADJN-4:physCellIdNr=4
@{LNADJN_2_PCI2_F2}
...    LNADJN-2:arfcnValueNR=629984
...    LNADJN-2:multiFrequencyBandList=258
...    LNADJN-2:physCellIdNr=2
@{LNADJN_3_PCI3_F3}
...    LNADJN-3:arfcnValueNR=${GSCN22325}
...    LNADJN-3:multiFrequencyBandList=258
...    LNADJN-3:physCellIdNr=3
@{LNADJNL_3_115970}
...    LNADJN-3/LNADJNL-3:cellIdentity=115970
...    LNADJN-3/LNADJNL-3:gnbIdLength=22
...    LNADJN-3/LNADJNL-3:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-3:gNBplmnId:mnc=13
...    LNADJN-3/LNADJNL-3:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-3:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-3:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-3:plmnIdList:mnc=13
...    LNADJN-3/LNADJNL-3:plmnIdList:mncLength=2
@{LNADJNL_orphan}
...    LNADJN-11/LNADJNL-11:cellIdentity=115988
...    LNADJN-11/LNADJNL-11:gnbIdLength=22
...    LNADJN-11/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-11/LNADJNL-11:gNBplmnId:mnc=11
...    LNADJN-11/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-11/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-11/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-11/LNADJNL-11:plmnIdList:mnc=11
...    LNADJN-11/LNADJNL-11:plmnIdList:mncLength=2
...    LNADJN-11:arfcnValueNR=${GSCN22325}
...    LNADJN-11:multiFrequencyBandList=258
...    LNADJN-11:physCellIdNr=11
@{LNRELN_3_115970}
...    LNCEL-1/LNRELN-3:cellIdentity=115970
...    LNCEL-1/LNRELN-3:psHoAllowed=allowed
...    LNCEL-1/LNRELN-3:removeAllowed=true
...    LNCEL-1/LNRELN-3:plmnId:mcc=262
...    LNCEL-1/LNRELN-3:plmnId:mnc=13
...    LNCEL-1/LNRELN-3:plmnId:mncLength=2
@{LNADJNL_1_115969}
...    LNADJN-1/LNADJNL-1:cellIdentity=115969
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=3
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=3
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2
@{LNRELN_1_115969}
...    LNCEL-1/LNRELN-1:cellIdentity=115969
...    LNCEL-1/LNRELN-1:psHoAllowed=allowed
...    LNCEL-1/LNRELN-1:removeAllowed=true
...    LNCEL-1/LNRELN-1:plmnId:mcc=262
...    LNCEL-1/LNRELN-1:plmnId:mnc=3
...    LNCEL-1/LNRELN-1:plmnId:mncLength=2
@{LNADJN_2_PCI2}
...    LNADJN-2:arfcnValueNR=2036672
...    LNADJN-2:multiFrequencyBandList=258
...    LNADJN-2:physCellIdNr=2

@{LNADJNL_2_115970}
...    LNADJN-2/LNADJNL-2:cellIdentity=115970
...    LNADJN-2/LNADJNL-2:gnbIdLength=22
...    LNADJN-2/LNADJNL-2:gNBplmnId:mcc=262
...    LNADJN-2/LNADJNL-2:gNBplmnId:mnc=3
...    LNADJN-2/LNADJNL-2:gNBplmnId:mncLength=2
...    LNADJN-2/LNADJNL-2:trackingAreaCodeNR=33
...    LNADJN-2/LNADJNL-2:plmnIdList:mcc=262
...    LNADJN-2/LNADJNL-2:plmnIdList:mnc=3
...    LNADJN-2/LNADJNL-2:plmnIdList:mncLength=2
@{LNRELN_2_115970}
...    LNCEL-1/LNRELN-2:cellIdentity=115970
...    LNCEL-1/LNRELN-2:psHoAllowed=allowed
...    LNCEL-1/LNRELN-2:removeAllowed=true
...    LNCEL-1/LNRELN-2:plmnId:mcc=262
...    LNCEL-1/LNRELN-2:plmnId:mnc=3
...    LNCEL-1/LNRELN-2:plmnId:mncLength=2
@{LNRELN_orphan}
...    LNCEL-1/LNRELN-11:cellIdentity=115998
...    LNCEL-1/LNRELN-11:psHoAllowed=allowed
...    LNCEL-1/LNRELN-11:removeAllowed=true
...    LNCEL-1/LNRELN-11:plmnId:mcc=262
...    LNCEL-1/LNRELN-11:plmnId:mnc=11
...    LNCEL-1/LNRELN-11:plmnId:mncLength=2
@{LNRELGNBCELL_CGI1}
...    LNCEL-1/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-3:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2

@{LNRELGNBCELL_CGI1_new}
...    LNCEL-1/LNRELGNBCELL-255:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-255:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-255:nrCellId=114719
...    LNCEL-1/LNRELGNBCELL-255:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-255:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-255:nrCgiPlmnId:mncLength=2
@{LNRELGNBCELL_CGI2}
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=115970
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
@{LNRELGNBCELL_CGI2_new}
...    LNCEL-1/LNRELGNBCELL-254:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-254:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-254:nrCellId=114719
...    LNCEL-1/LNRELGNBCELL-254:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-254:nrCgiPlmnId:mnc=4
...    LNCEL-1/LNRELGNBCELL-254:nrCgiPlmnId:mncLength=2
@{unlockcell}
...    LNCEL-1:administrativeState=unlocked
@{lockcell}
...    LNCEL-1:administrativeState=locked

@{delete_all_MOs}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-253
...    delete:LNCEL-1/LNRELN-1
...    delete:LNCEL-1/LNRELN-2
...    delete:LNCEL-1/LNRELN-3
...    delete:LNCEL-1/LNRELN-4
...    delete:LNCEL-2/LNRELN-2
...    delete:LNCEL-2/LNRELN-3
...    delete:LNADJN-511
...    delete:LNADJN-510
...    delete:LNADJN-1
...    delete:LNADJN-2
...    delete:LNADJN-3
...    delete:LNADJN-4
...    delete:LNCEL-1/LNRELGNBCELL-2
...    delete:LNCEL-1/LNRELGNBCELL-3
...    delete:LNCEL-1/LNRELGNBCELL-255
...    delete:LNCEL-1/LNRELGNBCELL-254
...    delete:LNADJGNB-127
...    delete:LNADJGNB-3
...    delete:LNADJGNB-1

*** Test Cases ***
CB005825-SR-A-B10_ET_06_online change actUeBasedAnrNrHo from true to false during NR-report-CGI with 7334 enabled
    [Documentation]
    ...    create LNADJGNB LNGNBCELL(F1-PCI1 and F1-PCI2)
    ...    create LNADJN, LNADJNL, LNRELN(F1_PCI1 and F1-PCI2)
    ...    step1: for F1_PCI1, deactive 5825 during CGI, send report noSIB1, 7334 MO created, 5825 not
    ...    for F1_PCI1, deactive 5825 during CGI, send normal CGI report, 7334 MO created, 5825 not
    ...    step2: for F1_PCI2, deactive 5825 during CGI, send report without frequencybandlist, 7334 MO created, 5825 not
    ...    step3: deactive 7334, active 7334
    ...    step4: for F1_PCI1, send CGI report noSIB1, 7334 MO created, 5825 suspend, LNRELN deleted
    ...    step5: for F1_PCI2, send CGI report no frequencybandlist, 7334 MO created, 5825 suspend, LNRELN deleted
    [Tags]
    Online change parameters    ${precondition_case6}
    Deactive actUeBasedAnrNrHo during CGI with report noSIB1 and check 7334 MO is created and 5825 not
    Deactive actUeBasedAnrNrHo during CGI with normal report and check 7334 MO is created and 5825 not
    Deactive actUeBasedAnrNrHo during CGI with report no frequencybandlist and check 7334 MO is created and 5825 not
    Online change parameters    ${deactive_7334}
    Online change parameters    ${active_7334 and timer set}
    LNRELN is deleted and LNRELGNBCELL keep for PCI1 after receive report noSIB1
    LNRELN is deleted and LNRELGNBCELL keep for PCI2 after receive report no frequencybandlist

    
CB005825-SR-A-B10_ET_9_verification CGI with online change actUeBasedAnrNrHo from false to true with 7334 enabled to disable
    [Documentation]
    ...    F1:2036672 F2:629984
    ...    "NR-report-CGI verification list for 5GHo"=F1_PCI2 F2_PCI3 F1_PCI1
    ...    "NR-report-CGI verification list"=F1_PCI1 F1_PCI3 F2_PCI3
    ...    step1: verify F1_PCI2, during CGI deactive 5825, verify fail
    ...    step2: verify F1_PCI1, succeed, 7334 MO created and 5825 not
    ...    step3: Active 5825 and deactive 7334
    ...    step4: verify F2_PCI3, 5825 MO created and 7334 not
    [Tags]
    Online change parameters    ${precondition_case9}
    report B2 and B1 multuple times to make tuple tobeverified for both ENDC and SAHO    narfcn=${NRARFCN2036667}    pci=1
    report B1 to make tuple tobeverified    narfcn=${NRARFCN2036667}    pci=3
    report B1 to make tuple tobeverified    narfcn=${NRARFCN630000}    pci=3
    Deactive actUeBasedAnrNrHo during CGI and check MO not created for 5GHO F1 PCI2
    Verify F1 PCI1 and check MO for ENDC is created
    Active 5825 and deactive 7334
    Verify F2 PCI3 and check MO for 5GHO is created

CB005825-SR-A-B10_ET_23_verification entry with different status when online change anrNrNbrHoRelVerifyPeriod during cell lock-unlock
    [Documentation]
    ...    precondition: anrNrNbrHoRelVerifyPeriod=0min, LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=460000 anrNrHoNbrRelRemGuardTime=72
    ...    F1-PCI1 is tobeverified
    ...    F1-PCI2 is verifying
    ...    F1-PCI3 is verified
    ...    F1-PCI4 is suspend
    ...    step1: change anrNrNbrHoRelVerifyPeriod to 10min during cell lock and unlock; F1-PCI3 is tobeverified
    ...    step2: prepare tuple again
    ...    F1-PCI1 is tobeverified
    ...    F1-PCI2 is verifying
    ...    F1-PCI3 is verified
    ...    F1-PCI4 is suspend
    ...    step3: change anrNrNbrHoRelVerifyPeriod to 0min during cell lock and unlock; F1-PCI3 is verified
    ...    step4: create MOC for F1-PCI1 F1-PCI4, both verified
    ...    step5: report B2 for PCI1~4 1 time
    ...    [1 4.374 InRelation Verified]
    ...    [2 0.81 Counting Initialized]
    ...    [3 4.545 InRelation Verified]
    ...    [4 4.645 InRelation Verified]
    ...    step6: sleep 3min, no MOC is deleted
    ...    step7: online change anrNrHoNbrRelRemGuardTime=2
    ...    step8: sleep 1min, LNRELN for PCI1 and PCI3 is deleted
    ...    step9: sleep 2min, LNADJN/L for PCI1 and PCI3 is deleted
    [Tags]
    Online change parameters    ${precondition_case23}
    prepare tuple with verifying verified suspend and tobeverified state for case23
    attach UE and check CGI can triggered    ue_id=11    pci=1
    change anrNrNbrHoRelVerifyPeriod to 10min during cell lock and unlock
    attach UE and check CGI can triggered    ue_id=11    pci=3
    prepare tuple with verifying verified suspend and tobeverified state for case23 again
    change anrNrNbrHoRelVerifyPeriod to 0min during cell lock and unlock
    create MO for PCI1 and PCI4
    Report B2s to make tuple decay
    LNRELN is not deleted for anrNrHoNbrRelRemGuardTime is not reached
    Reduce anrNrHoNbrRelRemGuardTime and check LNRELN and LNADJNL is deleted

CB005825-SR-A-B10_ET_30_verification online change anrNrHoParamList and keep LNHON not changed
    [Documentation]
    ...    precondition: B2 report, F1_PCI1 F2_PCI2 F3_PCI3 tobe verified
    ...    step1: delete ANR anrNrMeasConfList for F2 F3 and F4
    ...    step2: make F2_PCI2 tuple decay and LNRELN is deleted
    ...    step3: verify F1-PCI1 succeed
    ...    step4: add back ANR anrNrMeasConfList for F2, verify F2-PCI2 succeed
    ...    step5: add back ANR anrNrMeasConfList for F3, verify F3-PCI3 succeed
    [Tags]
    Online change parameters    ${precondition_case30}
    prepare tuples for F1_PCI1 F2_PCI2 F3_PCI3
    delete ANR anrNrMeasConfList for F2 F3 and F4
    make tuple verified by 5GHO with MO    nrarfcn=${NRARFCN2036667}    pci=1
    make F2_PCI2 tuple decay and LNRELN is deleted
    Check no tobeverified state
    add back ANR anrNrMeasConfList for F2
    make tuple verified by 5GHO with MO    nrarfcn=${NRARFCN630000}    pci=2
    add back ANR anrNrMeasConfList for F3
    make tuple verified by 5GHO with MO    nrarfcn=${GSCN22325}    pci=3

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias for multi UEs
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Set UE parameters for ENDC capability

Create UE Alias for multi UEs
    FOR    ${ue_id}    IN RANGE    1    17
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    ue_enb_param id=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 spid=34
    Config gnb7
    Config UE1 to UE16 support NRANR

Config UE1 to UE16 support NRANR
    FOR    ${ue_id}    IN RANGE    1    17
        Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        Execute Uex Command    ue_param id=${ue_id} nr_supported_bands=78,258,41
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

set RSC CGI auto report
    [Arguments]    ${ue_id}=1    ${nrcell_id}=${nci-115969}    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nrcell_id} freq_band_list=258 tac=33
    Run Uex Command    ${cmd}

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
    Online change parameters    ${delete_all_MOs}
    @{MOs}    Combine Lists    ${deactive_5825}    ${deactive_7334}
    Online change parameters    ${MOs}
    @{MOs}    Combine Lists    ${active_5825}    ${active_7334}
    Online change parameters    ${MOs}

report B2 to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ...    ${times}=6
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    ${times}+1
        Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    END
    UE detach    ue_id=${ue_id}

report B1 to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=2036672    ${times}=6
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=B1_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities_without_ANR}
    Flow Occurred As Expected    alias=B1_RRC
    FOR    ${temp}    IN RANGE    1    ${times}+1
        Trigger UE to send B1-NR for freq with PCI    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
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
    END
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
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

set RSC CGI auto report with CGI1
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nci-114719}
    ...    tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

set RSC CGI auto report with CGI4
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nci-115975}
    ...    tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

set RSC auto report with CGI1
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    Run Uex Command    ${cmd}

set RSC CGI auto report with CGI1 and delay CGI report
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    set RSC CGI auto report with CGI1    ue_id=${ue_id}    nrarfcn=${nrarfcn}    pci=${pci}
    Set CGI MR rrc report delay timer    ue_id=${ue_id}    delay=15000

set B1 and CGI auto report including noSIB1 and delay CGI report
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    UE attach to cell1    ue_id=${ue_id}
    set B1 and CGI auto report including noSIB1    ue_id=${ue_id}    nrarfcn=${nrarfcn}    pci=${pci}
    Set CGI MR rrc report delay timer    ue_id=${ue_id}    delay=15000

set B1 and CGI auto report not including frequencybandlist and delay CGI report
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=97 nrsrq=22 cgi=262:04|${nci-114719} tac=33
    UE attach to cell1    ue_id=${ue_id}
    Run Uex Command    ${cmd}
    Set CGI MR rrc report delay timer    ue_id=${ue_id}    delay=15000

set B1 and CGI auto report including noSIB1
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=97 nrsrq=22 cgi=262:03|${nci-114719} tac=33 freq_band_list=258
    ...    nr_cgi_nosib1=1:1
    Run Uex Command    ${cmd}

Wait CGI process succeed
    sleep    8s    wait CGI succeed

Attach UE and check CGI triggered
    [Arguments]    ${pci}=1    ${nrarfcn}=2036672    ${ue_id}=1
    ${CGI1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn})
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI')) as CGI_RRC
    Expect message flow
    ...    ${CGI1_messsage}
    ...    alias=NRANR_RRC    overall_timeout=30
    Flow Occurred As Expected    alias=NRANR_RRC

Set CGI MR rrc report delay timer
    [Arguments]    ${ue_id}=1    ${delay}=8000
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportCGI action=delay_next_msg
    ...    delay=${delay} next_msg=measurementReport
    Run Uex Command    ${cmd}

UE attached and check RSC and CGI and cleanup is done
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
    set RSC CGI auto report with CGI4    ue_id=${ue_id}    pci=${pci}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC

UE attached and check RSC is not triggered
    [Arguments]    ${ue_id}    ${pci}=1    ${narfcn}=${NRARFCN2036667}
    ${RSC1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${narfcn})
    ...    and (purpose eq 'reportStrongestCells') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ${RSC1_messsage}
    ...    alias=RSC_RRC    overall_timeout=30
    UE attach to cell1    ue_id=${ue_id}
    Flow Not Occurred For Message    alias=RSC_RRC
    UE detach    ue_id=${ue_id}

attach UE and check CGI can triggered
    [Arguments]    ${ue_id}    ${pci}=1    ${narfcn}=${NRARFCN2036667}
    ${RSC1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${narfcn})
    ...    and (purpose eq 'reportStrongestCells') and (s-Measure eq 0)) as RSC_RRC
    ${CGI1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${narfcn})
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI') and (s-Measure eq 75)) as CGI_RRC
    Expect message flow
    ...    ${RSC1_messsage}
    ...    ${CGI1_messsage}
    ...    alias=ANR_RRC    overall_timeout=30
    set RSC auto report with CGI1    ue_id=${ue_id}    pci=${pci}    nrarfcn=${narfcn}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=ANR_RRC
    Ue detach    ue_id=${ue_id}

Attach UE and check RSC CGI can triggered
    [Arguments]    ${ue_id}    ${pci}=1    ${narfcn}=${NRARFCN2036667}
    ${RSC1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${narfcn})
    ...    and (purpose eq 'reportStrongestCells') and (s-Measure eq 0)) as RSC_RRC
    ${CGI1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${narfcn})
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI') and (s-Measure eq 75)) as CGI_RRC
    Expect message flow
    ...    ${RSC1_messsage}
    ...    ${CGI1_messsage}
    ...    alias=ANR_RRC    overall_timeout=30
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=ANR_RRC

UE attached and check CGI is triggered and cleanup is done
    [Arguments]    ${ue_id}    ${pci}=1    ${nrarfcn}=${NRARFCN630000}
    ${RSC1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn})
    ...    and (purpose eq 'reportStrongestCells') and (s-Measure eq 0)) as RSC_RRC
    ${CGI1_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn})
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI') and (s-Measure eq 75)) as CGI_RRC
    ${cleanup1_message}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) ) as clean_RRC
    Expect message flow
    ...    ${RSC1_messsage}
    ...    ${CGI1_messsage}
    ...    ${cleanup1_message}
    ...    alias=ANR_RRC    overall_timeout=30
    Expect Message Will Not Occur
    ...    ${CGI1_messsage}
    ...    alias=CGI_RRC    overall_timeout=30
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=ANR_RRC
    UE detach    ue_id=${ue_id}

make tuple verified
    [Arguments]    ${nrarfcn}=${NRARFCN2036667}    ${pci}=1
    set RSC CGI auto report with CGI1    ue_id=11    nrarfcn=${nrarfcn}    pci=${pci}
    UE attach to cell1    ue_id=11
    Wait CGI process succeed
    UE detach    ue_id=11

LNRELGNBCELL is created and LNRELN is not
    Object Should Exist    LNCEL-1/LNRELGNBCELL-255:gnbIdLength=22
    Object Should not Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262

LNRELGNBCELL and LNRELN is not created
    Object Should not Exist    LNCEL-1/LNRELGNBCELL-255:gnbIdLength=22
    Object Should not Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262

Active 5825 and deactive 7334
    @{ac_5825_de_7334}    Combine Lists    ${active_5825}    ${deactive_7334}
    Online change parameters    ${ac_5825_de_7334}


prepare tuple with verifying verified suspend and tobeverified state for case23
    make tuple verifying by 5GHO without MO    nrarfcn=${NRARFCN2036667}    pci=2
    make tuple verified by 5GHO with MO    nrarfcn=${NRARFCN2036667}    pci=3
    make tuple suspend by 5GHO    nrarfcn=${NRARFCN2036667}    pci=4
    Report B2 multiple times to make tuple tobeverified    pci=1

prepare tuple with verifying verified suspend and tobeverified state for case23 again
    make tuple verifying by 5GHO without MO with maxMO is 25    nrarfcn=${NRARFCN2036667}    pci=2
    make tuple verified by 5GHO for tobeverilied tuple    nrarfcn=${NRARFCN2036667}    pci=3
    Report B2 multiple times to make tuple tobeverified    pci=1
    Report B2 multiple times to make tuple tobeverified    pci=4    times=1

make tuple verifying by 5GHO without MO
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    modify maxMumAnrMoiAllowed to be 20
    Report B2 multiple times to make tuple tobeverified    pci=${pci}
    UE attached and check RSC and CGI and cleanup is done    ue_id=11    pci=${pci}
    modify maxMumAnrMoiAllowed to be 100
    ue detach    ue_id=11

make tuple verifying by 5GHO without MO with maxMO is 25
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    modify maxMumAnrMoiAllowed to be 25
    Report B2 multiple times to make tuple tobeverified    pci=${pci}
    UE attached and check RSC and CGI and cleanup is done    ue_id=11    pci=${pci}
    modify maxMumAnrMoiAllowed to be 100
    ue detach    ue_id=11

make tuple verified by 5GHO with MO
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    report B2 to make tuple tobeverified    narfcn=${nrarfcn}    pci=${pci}
    UE attach to cell1    ue_id=1
    send B1NR report with set CGI auto report    ue_id=1    narfcn=${nrarfcn}    pci=${pci}
    Wait CGI process succeed
    UE detach    ue_id=1
    Object Should Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Object Should Exist    LNCEL-1/LNRELN-254:plmnId:mcc=262

make tuple verified by 5GHO for tobeverilied tuple
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    UE attach to cell1    ue_id=1
    send B1NR report with set CGI auto report    ue_id=1    narfcn=${nrarfcn}    pci=${pci}
    Wait CGI process succeed
    UE detach    ue_id=1
    Object Should Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Object Should Exist    LNCEL-1/LNRELN-254:plmnId:mcc=262

send B1NR report with set CGI auto report
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=2036672
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=${narfcn} nrsrp=56 nrsrq=77 cgi_plmn_group cgi=262:3,262:4|${nci-114719} tac=33
    ...    cgi_plmn_group cgi=262:5,262:6|0x1C502 tac=33 freq_band_list=258
    ...    phycell_id=2 narfcn=2036672 nrsrp=25 nrsrq=22 cgi=262:3,262:5|0x1C502 tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

make tuple suspend by 5GHO
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    report B2 to make tuple tobeverified    narfcn=${nrarfcn}    pci=${pci}
    set RSC CGI auto report with no freqbandlist    ue_id=11    pci=${pci}
    UE attached and check RSC and CGI triggered failed and cleanup is done    ue_id=11    pci=${pci}

report B2 multiple times to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ...    ${times}=6
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    ${times}+1
    Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    END
    UE detach    ue_id=${ue_id}

modify maxMumAnrMoiAllowed to be ${NUMBER}
    Online change parameters    LNBTS-1:maxNumAnrMoiAllowed=${NUMBER}

set RSC CGI auto report with no freqbandlist
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nci-115970} tac=33
    Run Uex Command    ${cmd}

UE attached and check RSC and CGI triggered failed and cleanup is done
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
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC
    UE detach    ue_id=${ue_id}

create MO for tuple2
    @{MOs}    Combine Lists    ${LNADJN_2_PCI2_F2}    ${LNADJNL_2_115970}    ${LNRELN_2_115970}
    Online change parameters     ${MOs}

create orphan MOCs
    @{MOs}    Combine Lists    ${LNADJNL_orphan}    ${LNRELN_orphan}
    Online change parameters     ${MOs}

create MO for tuple3
    @{MOs}    Combine Lists    ${LNADJN_3_PCI3_F3}    ${LNADJNL_3_115970}    ${LNRELN_3_115970}
    Online change parameters     ${MOs}

change anrNrNbrHoRelVerifyPeriod to 10min during cell lock and unlock
    Delta Commission Parameters    ${lockcell}
    Delta Commission Parameters    ${anrNrNbrHoRelVerifyPeriod_10min}
    Online change parameters    ${unlockcell}

change anrNrNbrHoRelVerifyPeriod to 0min during cell lock and unlock
    Delta Commission Parameters    ${lockcell}
    Delta Commission Parameters    ${anrNrNbrHoRelVerifyPeriod_0min}
    Online change parameters    ${unlockcell}

create MO for PCI1 and PCI4
    @{MOs}    Combine Lists    ${LNADJN_1_PCI1}    ${LNADJNL_1_CGI1_114719}    ${LNRELN_1_CGI1_114719}
    ...    ${LNADJN_4_PCI4}    ${LNADJNL_4_CGI4_114719}    ${LNRELN_4_CGI4_114719}
    Online change parameters    ${MOs}

Decayed LNRELN is deleted
    Object Should not Exist    LNCEL-1/LNRELN-255:cellIdentity=114719
    Object Should not Exist    LNCEL-1/LNRELN-254:cellIdentity=115970
    Object Should not Exist    LNCEL-1/LNRELN-1:cellIdentity=114719
    Object Should Exist    LNCEL-1/LNRELN-4:cellIdentity=114719

Decayed LNRELN is not deleted
    Object Should Exist    LNCEL-1/LNRELN-255:cellIdentity=114719
    Object Should Exist    LNCEL-1/LNRELN-254:cellIdentity=115970
    Object Should Exist    LNCEL-1/LNRELN-1:cellIdentity=114719
    Object Should Exist    LNCEL-1/LNRELN-4:cellIdentity=114719

Orphan LNADJN and LNADJNL is deleted
    Object Should not Exist    LNADJN-1:physCellIdNr=1
    Object Should not Exist    LNADJN-511:physCellIdNr=3
    Object Should Exist    LNADJN-4:physCellIdNr=4

delete ANR anrNrMeasConfList for F2 F3 and F4
    Online change parameters    ${no_ANR_F2_F3_F4_Single}

LNRELN for F2 is deleted for decay
    Object Should not Exist    LNCEL-1/LNRELN-2:cellIdentity=115970

add back ANR anrNrMeasConfList for F2
    @{MOs}    Combine Lists    ${ANR_F1}    ${ANR_F2}
    Online change parameters    ${MOs}
add back ANR anrNrMeasConfList for F3
    @{MOs}    Combine Lists    ${ANR_F1}    ${ANR_F2}    ${ANR_F3}
    Online change parameters    ${MOs}

set B1 and CGI auto report not including frequencybandlist
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=97 nrsrq=22 cgi=262:03|${nci-115970} tac=33
    UE attach to cell1    ue_id=${ue_id}
    Run Uex Command    ${cmd}

Deactive actUeBasedAnrNrHo during CGI with report noSIB1 and check 7334 MO is created and 5825 not
    Delta Commission Parameters    ${deactive_5825}    background=true
    set B1 and CGI auto report including noSIB1 and delay CGI report    ue_id=1
    Attach UE and check CGI triggered    ue_id=1    pci=1
    sleep    30s    wait background online change valid
    Object Should Exist    ${LNRELGNBCELL_CGI1_new}
    Object Should not Exist    ${LNRELGNBCELL_CGI1}
    Object Should not Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Online change parameters    ${active_5825}

Deactive actUeBasedAnrNrHo during CGI with normal report and check 7334 MO is created and 5825 not
    Delta Commission Parameters    ${deactive_5825}    background=true
    set RSC CGI auto report with CGI1 and delay CGI report    ue_id=11    pci=1
    Attach UE and check RSC CGI can triggered    ue_id=11    pci=1
    sleep    30s    wait background online change valid
    Object Should Exist    ${LNRELGNBCELL_CGI1_new}
    Object Should not Exist    ${LNRELGNBCELL_CGI1}
    Object Should not Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Online change parameters    ${active_5825}

Deactive actUeBasedAnrNrHo during CGI with report no frequencybandlist and check 7334 MO is created and 5825 not
    Delta Commission Parameters    ${deactive_5825}    background=true
    set B1 and CGI auto report not including frequencybandlist and delay CGI report    ue_id=2    pci=2
    Attach UE and check CGI triggered    ue_id=2    pci=2
    sleep    30s    wait background online change valid
    Object Should Exist    ${LNRELGNBCELL_CGI2_new}
    Object Should not Exist    ${LNRELGNBCELL_CGI2}
    Object Should not Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Online change parameters    ${active_5825}

LNRELN is deleted and LNRELGNBCELL keep for PCI1
    Object Should Exist    ${LNRELGNBCELL_CGI1_new}
    Object Should not Exist    LNCEL-1/LNRELN-1:plmnId:mcc=262

LNRELN is deleted and LNRELGNBCELL keep for PCI2
    Object Should Exist    ${LNRELGNBCELL_CGI2}
    Object Should not Exist    LNCEL-1/LNRELN-2:plmnId:mcc=262

LNRELN is deleted and LNRELGNBCELL keep for PCI1 after receive report noSIB1
    Online change parameters    ${LNRELGNBCELL_CGI1}
    UE attach to cell1    ue_id=3
    set B1 and CGI auto report including noSIB1    ue_id=3    pci=1
    Attach UE and check CGI triggered    ue_id=3    pci=1
    LNRELN is deleted and LNRELGNBCELL keep for PCI1

LNRELN is deleted and LNRELGNBCELL keep for PCI2 after receive report no frequencybandlist
    Online change parameters    ${LNRELGNBCELL_CGI2}
    set B1 and CGI auto report not including frequencybandlist    ue_id=4    pci=2
    Attach UE and check CGI triggered    ue_id=4    pci=2
    LNRELN is deleted and LNRELGNBCELL keep for PCI2

Deactive actUeBasedAnrNrHo during CGI and check MO not created for 5GHO F1 PCI2
    Delta Commission Parameters    ${deactive_5825}    background=true
    sleep    3s    wait online change valid during CGI
    set RSC CGI auto report with CGI1 and delay CGI report    nrarfcn=2036672    ue_id=13    pci=2
    UE attached and check CGI is triggered and cleanup is done    nrarfcn=2036672    ue_id=13    pci=2
    sleep    25s    wait backgound onlinchange valid
    LNRELGNBCELL and LNRELN is not created

Verify F1 PCI1 and check MO for ENDC is created
    make tuple verified    nrarfcn=2036672    pci=1
    LNRELGNBCELL is created and LNRELN is not

prepare tuples for F1_PCI1 F2_PCI2 F3_PCI3
    report B2 to make tuple tobeverified    narfcn=${NRARFCN2036667}    pci=1
    report B2 to make tuple tobeverified    narfcn=${GSCN22325}    pci=3
    create MO for tuple2
    create MO for tuple3
    create orphan MOCs

make F2_PCI2 tuple decay and LNRELN is deleted
    report B2 to make tuple tobeverified    narfcn=${NRARFCN630000}    pci=3
    sleep    2min    anrNrHoNbrRelRemGuardTime
    LNRELN for F2 is deleted for decay
    orphan MOs are deleted

orphan MOs are deleted
    Object Should not Exist    ${LNADJNL_orphan}
    Object Should not Exist    ${LNRELN_orphan}

Check no tobeverified state
    set RSC CGI auto report    ue_id=11    nrarfcn=${NRARFCN630000}    pci=2
    UE attached and check RSC is not triggered    ue_id=11    narfcn=${NRARFCN630000}    pci=2
    set RSC CGI auto report    ue_id=12    nrarfcn=${GSCN22325}    pci=3
    UE attached and check RSC is not triggered    ue_id=12    narfcn=${GSCN22325}    pci=3

Report B2s to make tuple decay
    report B2 to make tuple tobeverified    pci=1    times=1
    report B2 to make tuple tobeverified    pci=2    times=1
    report B2 to make tuple tobeverified    pci=3    times=1
    report B2 to make tuple tobeverified    pci=4    times=1
    UE attached and check RSC is not triggered    ue_id=15    pci=1

LNRELN is not deleted for anrNrHoNbrRelRemGuardTime is not reached
    sleep    3min    anrNrHoNbrRelRemGuardTime
    Decayed LNRELN is not deleted

Reduce anrNrHoNbrRelRemGuardTime and check LNRELN and LNADJNL is deleted
    Online change parameters    LNBTS-1/ANR-0:anrNrHoNbrRelRemGuardTime=2
    sleep    1min    one interval
    Decayed LNRELN is deleted
    sleep    2min    anrNrHoNbrRelRemGuardTime
    orphan LNADJN and LNADJNL is deleted

Verify F2 PCI3 and check MO for 5GHO is created
    report B2 to make tuple tobeverified    narfcn=${NRARFCN630000}    pci=2
    make tuple verified    nrarfcn=${NRARFCN630000}    pci=3
    Object Should Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262

Online change parameters
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
