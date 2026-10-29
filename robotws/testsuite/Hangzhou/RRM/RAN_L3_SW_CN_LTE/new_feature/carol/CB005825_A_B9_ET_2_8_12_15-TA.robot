*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Case setup
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS24R1    team-CN3ET    owner-carol.an
Resource          ../../resources/DevHZ5_resource.robot

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
...    @{IFHO}
...    @{SERVICE_BASED_HO}

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

${Uec_TUecRadMaxValueOfNrPciCounter}    0x1300DA
${Uec_TUecRadMaxSizeOfNrPciCounters}    0x1300DB
${Uec_TUecRadAnrNrNbrRelRemPeriodicCheckTimer}    0x1300E2
${AaSysLogOutputMode}     0x10041    #0=none,1=all,2=udp,3=sic,4=stdout, 5=local, 6=remote
${AaSysLogOutputLevel}     0x10040    #1=DBG,2=INF(default),3=WRN,4=ERR,5=VIP,6=NoPrints
${AaSysLogInputLevel}    0x1003F    #1=DBG,2=INF(default),3=WRN,4=ERR,5=VIP,6=NoPrints
${TRromRadDebugLogEnabledCommon}    0x120006
${TRromRadDebugLogEnabledGlobal}    0x120004
${TRromRadDebugLogEnabledRrom}    0x120005
${TUecRadDebugLogEnabledGlobal}    0x130020
${TUecRadDebugLogEnabledUec}    0x130021
${TUecRadDebugLogEnabledCommon}    0x13001E
${TUecRadDebugLogEnabledCommonCodec}    0x13001F
${NRARFCN2036667}    2036672
${GSCN22325}    22325
${numConsideredB2PerUe}    0x1300F1

@{BASE_LNHOIF_MODPR}
...    LNBTS:actSelMobPrf=false
...    LNBTS/MODPR-0:freqLayEndcHoList:freqLayer=1500
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1500
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-100
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-150
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-100
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-150

@{SERVICE_BASED_HO}
...    LNBTS:actIfHo=enabled
...    LNBTS/LNBTS_FDD-0:actInterFreqServiceBasedHo=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNCEL:iFServiceBasedHoRetryTimer=15
...    LNBTS/MODPR-0:freqLayListServiceBasedHo=1600
...    LNBTS/MODPR-0:freqLayListLte=1400,1500,1600
...    LNBTS/LNBTS_FDD-0:actDedVoLteInterFreqHo=false
...    @{BASE_LNHOIF_MODPR}

@{PARAMS_FOR_CB006607}
...    LNBTS:actEndcHo=disabled
...    LNBTS:actUeCapEndcHo=false
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNCEL:iFEndcHoRetryTimer=10

@{LNRELGNBCELL115969}
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{IFHO}
...    LNBTS:actIfHo=enabled
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=1600
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-2:ecgiLcrId=1
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1500
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-1:removeAllowed=false
...    LNCEL-2/LNREL-1:handoverAllowed=allowed



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
...    0x26ef

@{CB005825}
...    LNCEL-1:measQuantityNr=RSRP
...    LNCEL-1:t304InterRATN=500ms
...    LNCEL-1:a2TimeToTriggerActNRMeas=320ms
...    LNCEL-1:threshold2NR=25
...    LNCEL-1:hysThreshold2NR=0
...    @{CB007742}
...    LNBTS:actUeBasedAnrNrHo=true
...    LNBTS:actUeBasedAnrNr=false
...    LNBTS:actX2gNB128=true
...    LNBTS:maxNumNrCellgNB=1024
...    LNBTS:maxNumNrCell=32768
...    @{CB005825_ANR}
...    LNCEL-1:actDrx=true
...    LNBTS/NRMEASDPR-0:measGapEnabledNRMeas=FR1AndFR2
...    LNBTS:rrcGuardTimer=200

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
...    LNCEL-1/LNHON-1:ssbSubcarrierSpacing=120kHz
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

@{restore_case2}
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS:qciTab8:drxProfileIndex=3
...    LNBTS:qciTab6:drxProfileIndex=3
...    LNBTS:qciTab7:drxProfileIndex=3
...    LNCEL-1/DRX-0:drxProfile3:drxProfilePriority=30
...    LNCEL-1/DRX-0:drxProfile6:drxProfilePriority=40
...    LNCEL/DRX-0:drxProfile3:drxProfilePriority=30
...    LNCEL/DRX-0:drxProfile3:drxInactivityT=10
...    LNCEL/DRX-0:drxProfile3:drxLongCycle=80ms
...    LNCEL/DRX-0:drxProfile3:drxOnDuratT=6
...    LNCEL/DRX-0:drxProfile3:drxRetransT=4
...    LNCEL-1:drxProfile105:drxProfilePriority=30
...    LNCEL-1:drxProfile105:drxInactivityT=20
...    LNCEL-1:drxProfile105:drxLongCycle=320ms
...    LNCEL-1:drxProfile105:drxOnDuratT=10
...    LNCEL-1:drxProfile105:drxRetransT=16
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-511
...    delete:LNCEL-1/LNRELN-254
...    delete:LNADJN-510

@{restore_case8}
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNCEL:inactivityTimer=1000
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=12000
...    LNBTS/MODPR-0/MODRED-0:redirRAT=utraFDD
...    LNBTS/MODPR-0/MODRED-1:redirRAT=utraFDD

@{restore_case12}
...    LNBTS:actUeBasedAnrNr=false
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    delete:LNCEL-1/LNRELN-255
...    delete:LNADJN-511
...    delete:LNCEL-1/LNRELN-254
...    delete:LNADJN-510
...    delete:LNCEL-1/LNRELN-0
...    delete:LNADJN-1

@{addLNADJL_N_LNRELN0_CGI1}
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
...    LNADJN-1/LNADJNL-1:cellIdentity=115969
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=3
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=3
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2

${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208030
...    4218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820610
...    40105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E000
...    20406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A00000061000880014207F80226A02
# above support both 7334 NRANR and 7742 HO to 5GSA

${ue_nr_capabilities}    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000C039
...    F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D802802010040118028030100401004
...    600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064104208
...    000210410809A55334A262B9515DA8AEC4
${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B02004040C1803A020000000FD00000000081B8981002020E2680000103F400000000206E360400818103071340000101FA0000000010370B0200E8080000
...    303F400000000206E26040081838040000100FD0000000008100800803004809B0008041800040200010080004020200400880002010000804040080118000
...    40200010080004020200400840002010100200440001008000402020040080

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

@{LNADJNL_CGI}
...    LNADJN-511/LNADJNL-11:cellIdentity=115970
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=3


@{LNADJNL_CGI2}
...    LNADJN-510/LNADJNL-11:cellIdentity=114719
...    LNADJN-510/LNADJNL-11:gnbIdLength=22
...    LNADJN-510/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-510/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-510/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-510/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-510/LNADJNL-11:plmnIdList:mcc=262|mnc=3

@{LNADJNL_CGI_69}
...    LNADJN-511/LNADJNL-11:cellIdentity=115969
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=3

@{LNRELN_CGI1_69}
...    LNCEL-1/LNRELN-255:cellIdentity=115969
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNRELN_CGI}
...    LNCEL-1/LNRELN-255:cellIdentity=115970
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNRELN_114719_254}
...    LNCEL-1/LNRELN-254:cellIdentity=114719
...    LNCEL-1/LNRELN-254:psHoAllowed=allowed
...    LNCEL-1/LNRELN-254:removeAllowed=true
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=3
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2

@{LNADJNL_CGI2}
...    LNADJN-511/LNADJNL-11:cellIdentity=115970
...    LNADJN-511/LNADJNL-11:gnbIdLength=22
...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262
...    LNADJN-511/LNADJNL-11:plmnIdList:mnc=3
...    LNADJN-511/LNADJNL-11:plmnIdList:mncLength=2
...    LNADJN-510/LNADJNL-10:cellIdentity=114719
...    LNADJN-510/LNADJNL-10:gnbIdLength=22
...    LNADJN-510/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-510/LNADJNL-10:gNBplmnId:mnc=3
...    LNADJN-510/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-510/LNADJNL-10:trackingAreaCodeNR=33
...    LNADJN-510/LNADJNL-10:plmnIdList:mcc=262
...    LNADJN-510/LNADJNL-10:plmnIdList:mnc=3
...    LNADJN-510/LNADJNL-10:plmnIdList:mncLength=2

@{OnlineCh_DRXpriority40}
...    LNBTS:qciTab8:drxProfileIndex=3
...    LNCEL/DRX-0:drxProfile3:drxProfilePriority=40

@{Online_ChParams_case2}
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS:qciTab8:drxProfileIndex=3
...    LNBTS:qciTab6:drxProfileIndex=3
...    LNBTS:qciTab7:drxProfileIndex=3
...    LNBTS:qciTab9:drxProfileIndex=3
...    LNCEL/DRX-0:drxProfile3:drxProfileIndex=3
...    LNCEL/DRX-0:drxProfile3:drxProfilePriority=30
...    LNCEL-1:drxProfile105:drxProfilePriority=20
...    @{CB007266_CB007172_disable}

@{drx105_priority_50}    LNCEL-1:drxProfile105:drxProfilePriority=50
@{drx105_priority_20}    LNCEL-1:drxProfile105:drxProfilePriority=20

@{drx3drx105to40}
...    LNCEL-1:drxProfile105:drxProfilePriority=40
...    LNCEL/DRX-0:drxProfile3:drxProfilePriority=30
...    LNCEL/DRX-0:drxProfile3:drxInactivityT=20
...    LNCEL/DRX-0:drxProfile3:drxLongCycle=40ms
...    LNCEL/DRX-0:drxProfile3:drxOnDuratT=5
...    LNCEL/DRX-0:drxProfile3:drxRetransT=2

@{drx105change}
...    LNCEL-1:drxProfile105:drxInactivityT=200
...    LNCEL-1:drxProfile105:drxLongCycle=640ms
...    LNCEL-1:drxProfile105:drxOnDuratT=20
...    LNCEL-1:drxProfile105:drxRetransT=8

@{enable_CB007266}
...    LNCEL:actB1ReturnTo5GSA=true
@{CB007266_b1NrRedirectTimer}
...    LNBTS:b1NrRedirectTimer=2000

@{CB007172}
...    LNCEL:actReturnTo5GSA=at end of RRC or voice calls
...    MODPR-0:autoAdapt=false
...    LNBTS:actSelMobPrf=true
...    LNBTS:moProfileSelect=combined
...    LNCEL/REDRT-1:redirRat=nr
...    LNCEL/REDRT-1:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=15kHz
...    delete:LNCEL/REDRT-1:csFallBPrio
...    LNBTS-1/MODPR-0/MODRED-0:redirectPrio=8
...    LNBTS-1/MODPR-0/MODRED-1:redirectPrio=5
...    delete:LNBTS-1/MODPR-0/MODRED-0:csFallBPrio
...    delete:LNBTS-1/MODPR-0/MODRED-0:emerCallPrio
...    delete:LNBTS-1/MODPR-0/MODRED-1:csFallBPrio
...    delete:LNBTS-1/MODPR-0/MODRED-1:emerCallPrio
...    LNBTS/MODPR-0/MODRED-1:redirNrCarFrq:ssbSubcarrierSpacing=30kHz
...    LNBTS/MODPR-0/MODRED-1:redirNrCarFrq:carrierFreqNrCell=629984
...    LNBTS/MODPR-0/MODRED-0:redirNrCarFrq:ssbSubcarrierSpacing=120kHz
...    LNBTS/MODPR-0/MODRED-0:redirNrCarFrq:carrierFreqNrCell=${NRARFCN2036667}

@{MODREDredirRAT}
...    LNBTS/MODPR-0/MODRED-0:redirRAT=nr
...    LNBTS/MODPR-0/MODRED-1:redirRAT=nr

@{CB007266andANRtimer}
...    LNCEL-1:actB1ReturnTo5GSA=true
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=2500

@{Online_ChParams_case8}
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL:inactivityTimer=10
...    LNBTS/ANR-0:anrNrInactivityTimer=5
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=12000
...    @{CB007172}
...    @{enable_CB007266}
...    @{CB007266_b1NrRedirectTimer}
...    LNBTS:actIfHo=enabled
...    @{LNRELGNBCELL115969}

@{CB007266_CB007172_disable}
...    LNCEL:actB1ReturnTo5GSA=false
...    LNCEL:actReturnTo5GSA=disabled

@{Online_ChParams_case12}
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=12000
...    @{PARAMS_FOR_CB006607}
...    @{LNRELGNBCELL115969}

@{Online_ChParams_case15}
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=5000
...    @{PARAMS_FOR_CB006607}
...    @{LNRELGNBCELL115969}

@{X2shouldup}
...    LNBTS-1/LNADJGNB-1:x2ToGnbLinkStatus=available

@{caseWithMOC}
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

${InactivityTimerOut}    10s
${anrInactivityTimerOut}    5s

*** Test Cases ***
CB005825-SR-A-B9_ET_02_01_subsequent ENDC bear with higher drx create and release for RSC and CGI cross with drx105 priority online change when
    [Tags]    QC_
    [Documentation]
    ...    CB005825-SR-A-B9_ET_02_01_subsequent ENDC bear with higher drx create and release for RSC and CGI cross with drx105 priority online
    ...    change when actDRX is True and measurement gap is not need
    Online change case2 config
    UE1 send 6 times B2-NR reports PCI1a2
    UE11 triggered RSC via online change DRXpriority
    UE12 triggered ANR via online change DRXpriority
    UE2 triggered ANR and check moc
    [Teardown]    case2_teardown

CB005825-SR-A-B9_ET_08_01_blind redirection performedafter the completion of NR ANR when redirection based B1 is disabled
    [Tags]    QC_
    UE1 send 6 times B2-NR reports PCI1
    Online change case8 config
    attach UE and report B1 to trigger ENDC    ue_id=3
    UE3 triggered RSC and Redirection
    Delta Commission Parameters    ${CB007266andANRtimer}
    UE4 triggered ENDC
    UE4 no RRCcomplete message received and Redirection
    [Teardown]    case8_teardown

CB005825-SR-A-B9_ET_12_01_eNB deactivates NR-RSC measurement when receiving A2 MR which will trigger inter-frequency A3 A5
    [Tags]    QC_
    UE 2-5 send B2-NR reports PCI2-5
    UE1 send 6 times B2-NR reports PCI1a2    pci2=6
    Online change case12 config
    Attach UE setupENDC and check Gap DRX    ue_id=6
    UE6 keep A3andA5
    UE13 trigger tuple to verified
    UE14 keep A3andA5 no B1
    [Teardown]    case12_teardown

CB005825-SR-A-B9_ET_15_01_eNB keeps inter-frequency A4 measurement when receive invalid NR-RSC report or RSC supervision timer expire
    [Tags]    QC_
    UE 2-5 send B2-NR reports PCI2-5
    Delta Commission Parameters    ${caseWithMOC}
    Online change case15 config
    Delta Commission Parameters    ${addLNADJL_N_LNRELN0_CGI1}
    attach UE and report B1 to trigger ENDC    ue_id=7
    UE7 invalid A4 HO not trigger
    attach UE and report B1 to trigger ENDC    ue_id=8
    UE8 noRSC MR and valid A4 HO trigger
    attach UE and report B1 to trigger ENDC    ue_id=9
    UE9 RSC MR and valid A4 HO trigger
    [Teardown]    case12_teardown

*** Keywords ***
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
    FOR    ${ue_id}    IN RANGE    3    21
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
    FOR    ${ue_id}    IN RANGE    3    21
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
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    Update Yaml    UEs/UE_sets/11     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/12     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/13     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/14     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/15     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/16     bearer: bearer_set_2

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}

    Update Yaml    UEs/UE_sets/17     bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/18     bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/19     bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/20     bearer: bearer_set_3


    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...       type: simulated
    ...       plmn: '262:03'
    ...       s1: 10.0.1.3
    ...       cells:
    ...       - {id: 21, technology: lte, tac: 33, pci: '9:0', earfcn: '1400:19400', bw: 20}
    ...       - {id: 22, technology: lte, tac: 33, pci: '9:1', earfcn: '5920:23920', bw: 20}
    ...       - {id: 23, technology: lte, tac: 33, pci: '9:2', earfcn: '8770:26770', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...       type: simulated
    ...       enb_id_macro: 0x0000A
    ...       plmn: '262:03'
    ...       s1: 10.0.1.4
    ...       cells:
    ...        - {id: 31, technology: lte, tac: 33, pci: '2:1', eci: '0x0000A1F', earfcn: '1400:19400', bw: 20}

    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...       gnb_id: '0x00007'
    ...       type: simulated
    ...       plmn: '262:03'
    ...       s1u: 10.0.1.11
    ...       x2_peers: 1
    ...       cells:
    ...       - ${gnb7_cell1}
    ...       - ${gnb7_cell2}
    ...       - ${gnb7_cell3}
    ...       - ${gnb7_cell4}
    ...       - ${gnb7_cell5}

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

clean CB005825 verification list
    Block Cell1
    Unblock Cell1

UE1 send 6 times B2-NR reports PCI1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    report B2 6times to make tuple tobeverified    ue_id=${ue_id}    pci=1    narfcn=${NRARFCN2036667}

UE2 triggered ANR and check moc
    Attach UE Check PCI2 RSC and CGI delay should trigger    ue_id=2    delay=500    nrcell_id=${nci-114719}    pci=2
    Object Should Exist    ${LNRELN_CGI}
    Object Should Exist    ${LNADJNL_CGI}
    Object Should Exist    ${LNADJNL_CGI2}
    Object Should Exist    ${LNRELN_114719_254}

UE11 with online change DRXpriority and add QCI7
    [Arguments]    ${ue_id}=11
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((s-Measure eq 75) and (onDurationTimer eq "psf6")) as GAPoff_DRXon
    ...    alias=GAPrelease_DRXsetUP    overall_timeout=16
    Expect Message Will Not Occur
    ...    ${RSC_RRC}
    ...    alias=noNRRSC_RRC    overall_timeout=43
    UE attach to cell1    ue_id=11
    Flow Occurred As Expected    alias=GAPrelease_DRXsetUP
    Delta Commission Parameters    ${OnlineCh_DRXpriority40}
    Run Uex Command    bearer_add ue=11 qci=7
    Flow Not Occurred For Message    alias=noNRRSC_RRC

UE11 triggered RSC via online change DRXpriority
    UE11 with online change DRXpriority and add QCI7
    Delta Commission Parameters    ${drx105_priority_50}
    DRX105priority50 UE active

DRX105priority50 UE active
    [Arguments]    ${ue_id}=11
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=NRRSC_RRC    overall_timeout=56
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measGapConfig is not present) and (onDurationTimer eq "psf6")) as noGAP_DRXon
    ...    alias=noGAP_DRXon    overall_timeout=58
    Set RSC auto report    ue_id=11    nrsrp=56    nrsrq=88
    start traffic and check cleanup    ue_id=11    qci=6    #UE11 is active
    Execute Uex Command    trf_data_stop ue=11
    Delta Commission Parameters    ${drx105_priority_20}
    Flow Occurred As Expected    alias=NRRSC_RRC
    Flow Occurred As Expected    alias=noGAP_DRXon

start traffic and check cleanup
    [Arguments]    ${ue_id}=1    ${qci}=8
    Expect message flow    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drx-Config is not present) as ueactive_RRC
    ...    alias=ueactive_RRC    overall_timeout=10
    UE start traffic    ue_id=${ue_id}    qci=${qci}
    Flow Occurred As Expected    alias=ueactive_RRC

UE12 triggered ANR via online change DRXpriority
    [Arguments]    ${ue_id}=12
    Delta Commission Parameters    ${drx3drx105to40}
    set RSC CGI auto report and delay    ue_id=12    delay=100    nrcell_id=${nci-115970}
    ${drxChange}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((s-Measure eq 75) and (onDurationTimer eq "psf5") and (drx-RetransmissionTimer eq "psf2"))
    Expect message flow
    ...    ${drxChange}
    ...    alias=GAPrel_DRXsetUpANDchange    overall_timeout=25
    Attach UE Check RSC and CGI delay should trigger    ue_id=12    delay=500    nrcell_id=${nci-115970}
    Flow Occurred As Expected    alias=GAPrel_DRXsetUpANDchange
    Delta Commission Parameters    ${drx105change}

UE3 triggered RSC and Redirection
    [Arguments]    ${ue_id}=3
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    ${mvRSCaddB1}    catenate
    ...    measIdToRemoveList contains (
    ...    32
    ...    )
    ...    and
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18
    ...    )
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${mvRSCaddB1})
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (redirectedCarrierInfo is present)
    ...    alias=redirected    overall_timeout=40
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (purpose eq 'reportCGI') as noCGI
    ...    alias=noCGI    overall_timeout=16
    Expect message flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (radioNetwork eq 'user-inactivity')
    ...    ${RSC_RRC}
    ...    alias=SgnbRel_addRSC    overall_timeout=20
    UE3 command to triggered RSC and Redirection    ue_id=${ue_id}
    Flow Occurred As Expected    alias=SgnbRel_addRSC
    Flow Not Occurred For Message    alias=noCGI
    Flow Occurred As Expected    alias=redirected
    sleep    23s    #AdminAPi Response

UE3 command to triggered RSC and Redirection
    [Arguments]    ${ue_id}=3
    sleep    ${InactivityTimerOut}       #InactivityTimer timeout
    Set B1NR auto report    ue_id=${ue_id}    pci=1    nrsrp=58    nrsrq=88
    Delta Commission Parameters    LNCEL-1:actB1ReturnTo5GSA=false    background=true
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}

UE4 triggered ENDC
    attach UE and report B1 to trigger ENDC    ue_id=4
    sleep    ${InactivityTimerOut}       #InactivityTimer timeout

UE4 no RRCcomplete message received and Redirection
    [Arguments]    ${ue_id}=4
     ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')
    ...    and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    ${mvRSCaddB1}    catenate
    ...    measIdToRemoveList contains (
    ...    32
    ...    )
    ...    and
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18
    ...    )
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (redirectedCarrierInfo is present) as redirected
    ...    alias=redirected    overall_timeout=50
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${mvRSCaddB1}) as mvRSC_addB1
    ...    alias=mvRSC_addB1    overall_timeout=25
    Expect message flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (radioNetwork eq 'user-inactivity') as UEinactivity
    ...    ${RSC_RRC}
    ...    alias=SgnbRel_addRSC    overall_timeout=20
    UE Release and B1 without RRCcomplete    ue_id=${ue_id}
    Flow Occurred As Expected    alias=SgnbRel_addRSC
    Flow Occurred As Expected    alias=redirected
    sleep    23s    #AdminAPi Response

UE Release and B1 without RRCcomplete
    [Arguments]    ${ue_id}=4
    Delta Commission Parameters    LNCEL-1:actB1ReturnTo5GSA=false    background=true
    Execute Uex Command    ue_rrc_reconf_param id=${ue_id} nth=3 action=drop
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}

Attach UE setupENDC and check Gap DRX
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((gp0 eq 19) and (drx-Config is not present))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measGapConfig is present) and (onDurationTimer eq "psf6") and (s-Measure is not present))
    ...    alias=gap_drx    overall_timeout=8
    attach UE and report B1 to trigger ENDC    ue_id=${ue_id}
    Flow Occurred As Expected    alias=gap_drx

UE6 keep A3andA5
    [Arguments]    ${ue_id}=6
    ${mvRSCandA2_addA3A5}    catenate
    ...    measIdToRemoveList contains (
    ...    7,
    ...    32
    ...    )
    ...    and
    ...    eventA3 contains (
    ...    a3-Offset eq 6
    ...    )
    ...    and
    ...    eventA5 contains (
    ...    a5-Threshold1 contains (threshold-RSRP eq 24)
    ...    )
    ...    and
    ...    eventB2-NR-r15 contains (
    ...    b2-Threshold1-r15 contains (threshold-RSRP eq 40)
    ...    )
    ...    and
    ...    measIdToAddModList contains (
    ...    measId eq 14,
    ...    measId eq 15,
    ...    measId eq 16,
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19
    ...    )
    ...    and
    ...    (
    ...    s-Measure eq 75
    ...    )
    ...    and
    ...    (
    ...    drx-Config is not present
    ...    )
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${mvRSCandA2_addA3A5})
    ...    alias=addA3A5    overall_timeout=15
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (eventB1-NR-r15 is present) as noB1
    ...    alias=noB1    overall_timeout=20
    trigger ENDC release and A2    ue_id=${ue_id}
    Flow Occurred As Expected    alias=addA3A5
    Flow Not Occurred For Message    alias=noB1

trigger ENDC release and A2
    [Arguments]    ${ue_id}=6
    ${blacklist}    catenate
    ...    excludedCellsToAddModList-r15 contains (
    ...    physCellId-r15 eq 2,
    ...    physCellId-r15 eq 3,
    ...    physCellId-r15 eq 4,
    ...    physCellId-r15 eq 5
    ...    )
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (${blacklist})
    ...    and (purpose eq 'reportStrongestCells') and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (radioNetwork eq 'user-inactivity')
    ...    ${RSC_RRC}
    ...    alias=SgnbRel_addRSC    overall_timeout=10    
    sleep    2s       #InactivityTimer timeout
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}
    Flow Occurred As Expected    alias=SgnbRel_addRSC
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}    srsrp=0    srsrq=34

UE13 trigger tuple to verified
    [Arguments]    ${ue_id}=13
    Attach UE Check RSC and CGI delay should trigger    ue_id=${ue_id}    delay=300    nrcell_id=${nci-115969}
    Object Should Exist    ${LNRELN_CGI1_69}
    Object Should Exist    ${LNADJNL_CGI_69}

UE14 keep A3andA5 no B1
    [Arguments]    ${ue_id}=14
    ${blacklist}    catenate
    ...    excludedCellsToAddModList-r15 contains (
    ...    physCellId-r15 eq 1,
    ...    physCellId-r15 eq 2,
    ...    physCellId-r15 eq 3,
    ...    physCellId-r15 eq 4,
    ...    physCellId-r15 eq 5
    ...    )
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (${blacklist})
    ...    and (purpose eq 'reportStrongestCells') and (ss-rsrp eq 'TRUE') and (s-Measure eq 0) and (release is present)) as RSC_RRC
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=SgnbRel_addRSC    overall_timeout=10
    ${mvblacklist}    catenate
    ...    excludedCellsToRemoveList-r15 contains (
    ...    1,
    ...    2,
    ...    3,
    ...    4,
    ...    5
    ...    )
    ${mvRSCandA2_addA3A5}    catenate
    ...    measIdToRemoveList contains (
    ...    7,
    ...    32
    ...    )
    ...    and
    ...    eventA3 contains (
    ...    a3-Offset eq 6
    ...    )
    ...    and
    ...    eventA5 contains (
    ...    a5-Threshold1 contains (threshold-RSRP eq 24)
    ...    )
    ...    and
    ...    eventB2-NR-r15 contains (
    ...    b2-Threshold1-r15 contains (threshold-RSRP eq 40)
    ...    )
    ...    and
    ...    measIdToAddModList contains (
    ...    measId eq 14,
    ...    measId eq 15,
    ...    measId eq 16,
    ...    measId eq 17
    ...    )
    ...    and
    ...    (
    ...    s-Measure eq 75
    ...    )
    ...    and
    ...    (
    ...    drx-Config is not present
    ...    )
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((${mvblacklist}) and (${mvRSCandA2_addA3A5}))
    ...    alias=addA3A5    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=SgnbRel_addRSC
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}    srsrp=0    srsrq=34
    Flow Occurred As Expected    alias=addA3A5

UE7 invalid A4 HO not trigger
    [Arguments]    ${ue_id}=7
    ${mvRSCaddB1}    catenate
    ...    excludedCellsToRemoveList-r15 contains (
    ...    1,
    ...    2,
    ...    3,
    ...    4
    ...    )
    ...    and
    ...    measIdToRemoveList contains (
    ...    32
    ...    )
    ...    and
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18
    ...    )
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${mvRSCaddB1}) as mvRSCaddB1 sf80 : 40
    ...    alias=mvRSCcreatB1    overall_timeout=21
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((mobilityControlInfo contains (targetPhysCellId eq 2)) and (intraLTE is present))
    ...    alias=noInterCellHO    overall_timeout=25
    UE7 trigger and send invalid A4    ue_id=${ue_id}
    Flow Occurred As Expected    alias=mvRSCcreatB1
    Flow Not Occurred For Message    alias=noInterCellHO
    UE detach    ue_id=${ue_id}

UE7 trigger and send invalid A4
    [Arguments]    ${ue_id}=7
    ${addA4}    catenate
    ...    eventA4 contains (
    ...    a4-Threshold contains (threshold-RSRP eq 0)
    ...    )
    ...    and
    ...    measIdToAddModList contains (
    ...    measId eq 31
    ...    )
    ...    and
    ...    (
    ...    measIdToRemoveList is not present
    ...    )
    ...    and
    ...    (
    ...    drx-Config is not present
    ...    )
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${addA4})
    ...    alias=addA4    overall_timeout=18
    UE7 command ENDC release trigger    ue_id=${ue_id}
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31
    Flow Occurred As Expected    alias=addA4
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A4 phycell_id=2 nrsrp=0 nrsrq=20 srsrp=0 srsrq=34

UE7 command ENDC release trigger
    [Arguments]    ${ue_id}=7
    ${blacklist}    catenate
    ...    excludedCellsToAddModList-r15 contains (
    ...    physCellId-r15 eq 2,
    ...    physCellId-r15 eq 3,
    ...    physCellId-r15 eq 4,
    ...    physCellId-r15 eq 5
    ...    )
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (${blacklist})
    ...    and (purpose eq 'reportStrongestCells') and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    Expect message flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (radioNetwork eq 'user-inactivity')
    ...    ${RSC_RRC}
    ...    alias=SgnbRel_addRSC    overall_timeout=15
    sleep    ${anrInactivityTimerOut}       #InactivityTimer timeout
    ${RSCmrDelay}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=delay_next_msg
    ...    delay=2500 next_msg=measurementReport
    Run Uex Command    ${RSCmrDelay}
    Set RSC auto report    ue_id=${ue_id}    nrsrp=55    nrsrq=88
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}
    Flow Occurred As Expected    alias=SgnbRel_addRSC

UE8 noRSC MR and valid A4 HO trigger
    [Arguments]    ${ue_id}=8
    ${blacklist}    catenate
    ...    excludedCellsToAddModList-r15 contains (
    ...    physCellId-r15 eq 2,
    ...    physCellId-r15 eq 3,
    ...    physCellId-r15 eq 4,
    ...    physCellId-r15 eq 5
    ...    )
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (${blacklist})
    ...    and (purpose eq 'reportStrongestCells') and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    ${mvRSCaddB1}    catenate
    ...    excludedCellsToRemoveList-r15 contains (
    ...    1,
    ...    2,
    ...    3,
    ...    4
    ...    )
    ...    and
    ...    measIdToRemoveList contains (
    ...    32
    ...    )
    ...    and
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18
    ...    )
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${mvRSCaddB1}) as mvRSCaddB1 sf80 : 40
    ...    alias=mvRSCcreatB1    overall_timeout=25
    Expect message flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (radioNetwork eq 'user-inactivity')
    ...    ${RSC_RRC}
    ...    alias=SgnbRel_addRSC    overall_timeout=25
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((mobilityControlInfo contains (targetPhysCellId eq 2)) and (intraLTE is present))
    ...    alias=interCellHO    overall_timeout=25
    ENDC release and QCI1 add A4    ue_id=${ue_id}
    Flow Occurred As Expected    alias=SgnbRel_addRSC
    Flow Occurred As Expected    alias=mvRSCcreatB1
    Flow Occurred As Expected    alias=interCellHO

ENDC release and QCI1 add A4
    [Arguments]    ${ue_id}=8
    sleep    5s       #InactivityTimer timeout
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31
    sleep    2s     #anrNRcoverageTimer timeout
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A4 phycell_id=2 nrsrp=80 nrsrq=34 srsrp=65 srsrq=34

UE9 RSC MR and valid A4 HO trigger
    [Arguments]    ${ue_id}=9
    ${blacklist}    catenate
    ...    excludedCellsToAddModList-r15 contains (
    ...    physCellId-r15 eq 2,
    ...    physCellId-r15 eq 3,
    ...    physCellId-r15 eq 4,
    ...    physCellId-r15 eq 5
    ...    )
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (${blacklist})
    ...    and (purpose eq 'reportStrongestCells') and (ss-rsrp eq 'TRUE') and (s-Measure eq 0)) as RSC_RRC
    ${mvRSCaddB1}    catenate
    ...    excludedCellsToRemoveList-r15 contains (
    ...    1,
    ...    2,
    ...    3,
    ...    4
    ...    )
    ...    and
    ...    measIdToRemoveList contains (
    ...    32
    ...    )
    ...    and
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18
    ...    )
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${mvRSCaddB1}) as mvRSCaddB1 sf80 : 40
    ...    alias=mvRSCcreatB1    overall_timeout=25
    Expect message flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (radioNetwork eq 'user-inactivity')
    ...    ${RSC_RRC}
    ...    alias=SgnbRel_addRSC    overall_timeout=25
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((mobilityControlInfo contains (targetPhysCellId eq 2)) and (intraLTE is present))
    ...    alias=interCellHO    overall_timeout=25
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq 2036672) and (purpose eq 'reportCGI')) as noCGI_RRC
    ...    alias=noCGI_RRC    overall_timeout=30
    ENDC release and QCI1 add RSCdelay A4    ue_id=${ue_id}
    Flow Occurred As Expected    alias=SgnbRel_addRSC
    Flow Occurred As Expected    alias=mvRSCcreatB1
    Flow Occurred As Expected    alias=interCellHO
    Flow Not Occurred For Message    alias=noCGI_RRC

ENDC release and QCI1 add RSCdelay A4
    [Arguments]    ${ue_id}=9
    sleep    5s       #InactivityTimer timeout
    Set RSC auto report    ue_id=${ue_id}    nrsrp=58    nrsrq=88
    ${RSCmrDelay}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=delay_next_msg
    ...    delay=2100 next_msg=measurementReport
    Run Uex Command    ${RSCmrDelay}
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31
    sleep    1s     #anrNRcoverageTimer timeout
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A4 phycell_id=2 nrsrp=80 nrsrq=34 srsrp=65 srsrq=34

UE1 send 6 times B2-NR reports PCI1a2
    [Arguments]    ${ue_id}=1    ${pci2}=2
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    report B2 6times to make tuple tobeverified    ue_id=${ue_id}    pci=1    narfcn=${NRARFCN2036667}
    report B2 6times to make tuple tobeverified    ue_id=${ue_id}    pci=${pci2}    narfcn=${NRARFCN2036667}

UE start traffic
    [Arguments]    ${ue_id}=1    ${qci}=8
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl_and_ul protocol=udp Mbps_dl=150 Mbps_ul=20 qci=${qci}
    Sleep    5s    #wait for eNB load to be High
    Execute Uex Command    ue_stats id=${ue_id} type=dl_mac unit=Mbps

Set B1NR auto report
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrsrp}=56    ${nrsrq}=88
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=measId with_value=18 action=measurement_send
    ...    phycell_id=${pci} nrsrp=${nrsrp} nrsrq=${nrsrq} event=B1_NR
    Run Uex Command    ${cmd}

Set RSC auto report
    [Arguments]    ${ue_id}=1    ${nrsrp}=56    ${nrsrq}=88    ${nrcell_id}=${nci-115969}    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${NRARFCN2036667} nrsrp=${nrsrp} nrsrq=${nrsrq} nsinr=31 strongest=nr5g
    Run Uex Command    ${cmd}

Trigger UE to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}    ${srsrp}=0    ${srsrq}=34
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34

Online change case2 config
    Delta Commission Parameters    ${Online_ChParams_case2}

Online change case8 config
    Delta Commission Parameters    ${Online_ChParams_case8}
    Delta Commission Parameters    ${MODREDredirRAT}
    Object Should Exist    ${X2shouldup}

Online change case12 config
    Delta Commission Parameters    ${Online_ChParams_case12}
    Object Should Exist    ${X2shouldup}

Online change case15 config
    Delta Commission Parameters    ${Online_ChParams_case15}
    Object Should Exist    ${X2shouldup}

case2_teardown
    Execute Egate Command    mme_timer reset
    Release All UEs
    Delta Commission Parameters    ${restore_case2}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

case8_teardown
    Execute Egate Command    mme_timer reset
    Release All UEs
    sleep    23s    ##AdminAPi Response
    Delta Commission Parameters    ${restore_case8}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

case12_teardown
    Execute Egate Command    mme_timer reset
    Release All UEs
    Delta Commission Parameters    ${restore_case12}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

UE 2-5 send B2-NR reports PCI2-5
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    report B2 to make tuple nrpcicounter1    ue_id=2    pci=2    narfcn=${NRARFCN2036667}
    report B2 to make tuple nrpcicounter1    ue_id=3    pci=3    narfcn=${NRARFCN2036667}
    report B2 to make tuple nrpcicounter1    ue_id=4    pci=4    narfcn=${NRARFCN2036667}
    report B2 to make tuple nrpcicounter1    ue_id=5    pci=5    narfcn=${NRARFCN2036667}

report B2 to make tuple nrpcicounter1
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=5
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    Trigger UE to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    sleep    2    #waite B2 RRC complete
    UE detach    ue_id=${ue_id}

report B2 6times to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=5
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    7
    Trigger UE to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    END
    sleep    2    #waite B2 RRC complete
    UE detach    ue_id=${ue_id}

attach UE and report B1 to trigger ENDC
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    ENB_1:X2AP_SgNBAdditionRequest (qCI eq 8)
    ...    ENB_1:X2AP_SgNBReconfigurationComplete (success-SgNBReconfComp is present)
    ...    alias=B1_ENDC_RRC    overall_timeout=15
    UE attach to cell1    ue_id=${ue_id}
    Trigger UE to send B1-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    Flow Occurred As Expected    alias=B1_ENDC_RRC

Trigger UE to send B2-NR for freq with PCI1
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${narfcn} amount=1

Trigger UE to send B1-NR for freq with PCI1
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${pci} nrsrp=58 nrsrq=88 narfcn=${narfcn} amount=1

Set CGI MR rrc report delay timer
    [Arguments]    ${ue_id}=1    ${delay}=8000
    ${cmd}    catenate
    ...     ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportCGI action=delay_next_msg delay=${delay} next_msg=measurementReport
    Run Uex Command    ${cmd}

set RSC CGI auto report and delay
    [Arguments]    ${ue_id}=1    ${delay}=8000    ${nrcell_id}=${nci-115969}    ${nrsrp}=58    ${nrsrq}=88    ${pci}=1
    set RSC CGI auto report    ue_id=${ue_id}    nrcell_id=${nrcell_id}    pci=${pci}    nrsrp=${nrsrp} nrsrq=${nrsrq}
    Set CGI MR rrc report delay timer    ue_id=${ue_id}    delay=${delay}

Attach UE Check RSC and CGI delay should trigger
    [Arguments]    ${ue_id}=1    ${delay}=8000    ${nrcell_id}=${nci-115969}    ${pci}=1
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
    ...    alias=CGI_RRC    overall_timeout=20
    set RSC CGI auto report and delay    ue_id=${ue_id}    delay=${delay}    nrcell_id=${nrcell_id}    pci=${pci}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRRSC_RRC
    Flow Not Occurred For Message    alias=noB1_RRC
    Flow Occurred As Expected    alias=CGI_RRC

Attach UE Check PCI2 RSC and CGI delay should trigger
    [Arguments]    ${ue_id}=1    ${delay}=8000    ${nrcell_id}=${nci-115969}    ${pci}=1
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
    ...    and (cellForWhichToReportCGI-r15 eq ${pci}) and (purpose eq 'reportCGI') and (s-Measure eq 75)
    ...    and (onDurationTimer eq "psf20")) as CGI_RRC
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=CGI_RRC    overall_timeout=20
    set RSC CGI auto report and delay    ue_id=${ue_id}    delay=${delay}    nrcell_id=${nrcell_id}    pci=${pci}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRRSC_RRC
    Flow Not Occurred For Message    alias=noB1_RRC
    Flow Occurred As Expected    alias=CGI_RRC
