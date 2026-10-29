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
...    @{PS_FOR_7X24}
...    @{CB008800}
...    @{Load_Threshold}
...    @{CELL1_CELL2_CELL3_IN_PSGRP1}
...    @{LTE1103}
...    @{LTE1203}
...    @{CB008745}
...    @{Others1}

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
...    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=4
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS/ANR-0:consec5gHoFailThres=15
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=true
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=All|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=22|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=${NRARFCN2036667}|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=0
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
...    LNBTS/MODPR-0:freqLayListPsHoNR=${NRARFCN2036667}
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
...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=300000
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

@{delete_MO_teardown}
...    delete:LNADJN-511
...    delete:LNADJN-510
...    delete:LNADJN-0
...    delete:LNADJN-1
...    delete:LNCEL-1/LNRELN-0
...    delete:LNCEL-1/LNRELN-1
...    delete:LNCEL-1/LNRELN-5
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-253

@{MOs_case7_2}
...    LNADJN-1:arfcnValueNR=2036672
...    LNADJN-1:multiFrequencyBandList=258
...    LNADJN-1:physCellIdNr=1
...    LNADJN-1/LNADJNL-1:cellIdentity=115969
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=4
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=4
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2

...    LNADJN-1/LNADJNL-2:cellIdentity=115969
...    LNADJN-1/LNADJNL-2:gnbIdLength=22
...    LNADJN-1/LNADJNL-2:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-2:gNBplmnId:mnc=5
...    LNADJN-1/LNADJNL-2:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-2:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-2:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-2:plmnIdList:mnc=5
...    LNADJN-1/LNADJNL-2:plmnIdList:mncLength=2

...    LNADJN-3:arfcnValueNR=2036672
...    LNADJN-3:multiFrequencyBandList=258
...    LNADJN-3:physCellIdNr=1
...    LNADJN-3/LNADJNL-3:cellIdentity=115969
...    LNADJN-3/LNADJNL-3:gnbIdLength=22
...    LNADJN-3/LNADJNL-3:gNBplmnId:mcc=262
...    LNADJN-3/LNADJNL-3:gNBplmnId:mnc=6
...    LNADJN-3/LNADJNL-3:gNBplmnId:mncLength=2
...    LNADJN-3/LNADJNL-3:trackingAreaCodeNR=33
...    LNADJN-3/LNADJNL-3:plmnIdList:mcc=262
...    LNADJN-3/LNADJNL-3:plmnIdList:mnc=6
...    LNADJN-3/LNADJNL-3:plmnIdList:mncLength=2

...    LNADJN-8:arfcnValueNR=2036672
...    LNADJN-8:multiFrequencyBandList=258
...    LNADJN-8:physCellIdNr=1
...    LNADJN-8/LNADJNL-8:cellIdentity=115969
...    LNADJN-8/LNADJNL-8:gnbIdLength=22
...    LNADJN-8/LNADJNL-8:gNBplmnId:mcc=262
...    LNADJN-8/LNADJNL-8:gNBplmnId:mnc=11
...    LNADJN-8/LNADJNL-8:gNBplmnId:mncLength=2
...    LNADJN-8/LNADJNL-8:trackingAreaCodeNR=33
...    LNADJN-8/LNADJNL-8:plmnIdList:mcc=262
...    LNADJN-8/LNADJNL-8:plmnIdList:mnc=11
...    LNADJN-8/LNADJNL-8:plmnIdList:mncLength=2

...    LNADJN-5:arfcnValueNR=2036672
...    LNADJN-5:multiFrequencyBandList=258
...    LNADJN-5:physCellIdNr=2
...    LNADJN-5/LNADJNL-5:cellIdentity=115969
...    LNADJN-5/LNADJNL-5:gnbIdLength=22
...    LNADJN-5/LNADJNL-5:gNBplmnId:mcc=262
...    LNADJN-5/LNADJNL-5:gNBplmnId:mnc=8
...    LNADJN-5/LNADJNL-5:gNBplmnId:mncLength=2
...    LNADJN-5/LNADJNL-5:trackingAreaCodeNR=33
...    LNADJN-5/LNADJNL-5:plmnIdList:mcc=262
...    LNADJN-5/LNADJNL-5:plmnIdList:mnc=8
...    LNADJN-5/LNADJNL-5:plmnIdList:mncLength=2

...    LNADJN-5/LNADJNL-6:cellIdentity=115969
...    LNADJN-5/LNADJNL-6:gnbIdLength=22
...    LNADJN-5/LNADJNL-6:gNBplmnId:mcc=262
...    LNADJN-5/LNADJNL-6:gNBplmnId:mnc=9
...    LNADJN-5/LNADJNL-6:gNBplmnId:mncLength=2
...    LNADJN-5/LNADJNL-6:trackingAreaCodeNR=33
...    LNADJN-5/LNADJNL-6:plmnIdList:mcc=262
...    LNADJN-5/LNADJNL-6:plmnIdList:mnc=9
...    LNADJN-5/LNADJNL-6:plmnIdList:mncLength=2

...    LNCEL-1/LNRELN-1:cellIdentity=115969
...    LNCEL-1/LNRELN-1:psHoAllowed=allowed
...    LNCEL-1/LNRELN-1:removeAllowed=true
...    LNCEL-1/LNRELN-1:plmnId:mcc=262
...    LNCEL-1/LNRELN-1:plmnId:mnc=4
...    LNCEL-1/LNRELN-1:plmnId:mncLength=2

...    LNCEL-1/LNRELN-4:cellIdentity=115969
...    LNCEL-1/LNRELN-4:psHoAllowed=allowed
...    LNCEL-1/LNRELN-4:removeAllowed=true
...    LNCEL-1/LNRELN-4:plmnId:mcc=262
...    LNCEL-1/LNRELN-4:plmnId:mnc=7
...    LNCEL-1/LNRELN-4:plmnId:mncLength=2

...    LNCEL-1/LNRELN-6:cellIdentity=115969
...    LNCEL-1/LNRELN-6:psHoAllowed=allowed
...    LNCEL-1/LNRELN-6:removeAllowed=true
...    LNCEL-1/LNRELN-6:plmnId:mcc=262
...    LNCEL-1/LNRELN-6:plmnId:mnc=9
...    LNCEL-1/LNRELN-6:plmnId:mncLength=2

...    LNCEL-1/LNRELN-7:cellIdentity=115969
...    LNCEL-1/LNRELN-7:psHoAllowed=allowed
...    LNCEL-1/LNRELN-7:removeAllowed=true
...    LNCEL-1/LNRELN-7:plmnId:mcc=262
...    LNCEL-1/LNRELN-7:plmnId:mnc=10
...    LNCEL-1/LNRELN-7:plmnId:mncLength=2

...    LNCEL-2/LNRELN-1:cellIdentity=115969
...    LNCEL-2/LNRELN-1:psHoAllowed=allowed
...    LNCEL-2/LNRELN-1:removeAllowed=true
...    LNCEL-2/LNRELN-1:plmnId:mcc=262
...    LNCEL-2/LNRELN-1:plmnId:mnc=4
...    LNCEL-2/LNRELN-1:plmnId:mncLength=2

...    LNCEL-2/LNRELN-3:cellIdentity=115969
...    LNCEL-2/LNRELN-3:psHoAllowed=allowed
...    LNCEL-2/LNRELN-3:removeAllowed=true
...    LNCEL-2/LNRELN-3:plmnId:mcc=262
...    LNCEL-2/LNRELN-3:plmnId:mnc=6
...    LNCEL-2/LNRELN-3:plmnId:mncLength=2

...    LNCEL-2/LNRELN-8:cellIdentity=115969
...    LNCEL-2/LNRELN-8:psHoAllowed=allowed
...    LNCEL-2/LNRELN-8:removeAllowed=false
...    LNCEL-2/LNRELN-8:plmnId:mcc=262
...    LNCEL-2/LNRELN-8:plmnId:mnc=11
...    LNCEL-2/LNRELN-8:plmnId:mncLength=2

@{MOs_case5_LNADJNL}
...    LNADJN-1:arfcnValueNR=2036672
...    LNADJN-1:multiFrequencyBandList=258
...    LNADJN-1:physCellIdNr=1
...    LNADJN-1/LNADJNL-1:cellIdentity=115969
...    LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNADJN-1/LNADJNL-1:gNBplmnId:mnc=4
...    LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNADJN-1/LNADJNL-1:plmnIdList:mnc=4
...    LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2
@{MOs_case5_LNRELN}
...    LNCEL-1/LNRELN-1:cellIdentity=115969
...    LNCEL-1/LNRELN-1:psHoAllowed=allowed
...    LNCEL-1/LNRELN-1:removeAllowed=true
...    LNCEL-1/LNRELN-1:plmnId:mcc=262
...    LNCEL-1/LNRELN-1:plmnId:mnc=4
...    LNCEL-1/LNRELN-1:plmnId:mncLength=2

@{active_powersaving}
...    LNBTS:actLbpsCtrlLogicEnh=true
...    LNBTS:actLBPowerSaving=true

@{disable_powersaving}
...    LNBTS:actLbpsCtrlLogicEnh=false
...    LNBTS:actLBPowerSaving=false

@{PS_FOR_7X24}
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Mon
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Mon
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Mon
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Mon
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Tue
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Tue
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Tue
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Tue
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Wed
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Wed
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Wed
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Wed
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Thu
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Thu
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Thu
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Thu
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Fri
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Fri
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Fri
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Fri
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Sat
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Sat
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Sat
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Sat

@{Others1}
...    PSGRP-1:lbpsCSONCtlEnabled=false
...    LNCEL-1/SIB-0:ulpcIniPrePwr=-106 dBm
...    LNCEL:actModulationSchemeDl=64QAM
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=1
...    LNCEL:mbrSelector=ueCapability

@{CELL1_CELL2_CELL3_IN_PSGRP1}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=false|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=false|lnCelId=2
@{Load_Threshold}
...    PSGRP-1:lbpsLastCellSOEnabled=false
...    PSGRP-1:lbpsLastCellMinLoad=0
...    PSGRP-1:lbpsLastCellRTXMinLoad=2
...    PSGRP-1:lbpsMinLoad=21
...    PSGRP-1:lbpsRTXMinLoad=3
...    PSGRP-1:lbpsMaxLoad=25
...    PSGRP-1:lbpsRTXMaxLoad=5
@{CB008800}
...    LNBTS:actExtCellSOMethod=false
@{LTE1103}
...    LNBTS:actLBPowerSaving=false
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:nomNumPrbNonGbr=1
@{LTE1203}
...    LNBTS:actLBRTXPowerSaving=false
...    LNBTS:actOnlineTXSwitch=false
@{CB008745}
...    LNBTS:actLbpsCtrlLogicEnh=false
...    LNBTS/PSGRP-1:lbpsLoadCalcMethod=Max(G_N_combined, P)
...    LNBTS/PSGRP-1:lbpsMonWinForCellSOff=${lbpsMonWinForCellSOff}
...    LNBTS/PSGRP-1:lbpsMonWinForCellSOn=${lbpsMonWinForCellSOn}
...    LNBTS/PSGRP-1:lbpsMonWinForRtxSOff=${lbpsMonWinForRtxSOff}
...    LNBTS/PSGRP-1:lbpsMonWinForRtxSOn=${lbpsMonWinForRtxSOn}
...    LNBTS/PSGRP-1:lbpsSOffTrRule=SlidingAverageMethod
...    LNBTS/PSGRP-1:lbpsSOnTrRule=SlidingAverageMethod
...    LNBTS/PSGRP-1:lbpsPdcchLoadOffset=0

${lbpsMonWinForCellSOn}    110
${lbpsMonWinForRtxSOn}    70
${lbpsMonWinForCellSOff}    60
${lbpsMonWinForRtxSOff}    90
${SWITCH_TIMEOUT_ES}    1 min 30 s

@{unlockcell}
...    LNCEL-1:administrativeState=unlocked
@{lockcell}
...    LNCEL-1:administrativeState=locked

*** Test Cases ***
CB005825-SR-A-B8_ET_01_01_mantain verification list with exist tuple entrys with different status after cell lock unlock
    [Tags]
    [Documentation]
    ...    precondition:
    ...    2036672-PCI1 is tobeverified
    ...    2036672-PCI2 is verifying
    ...    2036672-PCI3 is verified
    ...    2036672-PCI4 is suspend
    ...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=300000
    ...    LNCEL-1/LNHON-1:nrPciHoNbrCounterDecay=0
    ...    LNBTS-1/ANR-0:anrNrHoNbrRelRemGuardTime=2
    ...    anrNrNbrHoRelVerifyPeriod=960min
    ...    step1: trigger cell lock for 1min, then cell unlock: 2036672-PCI3 nrpcicount is 5, status is tobeverified
    ...    step2: UE 1-4 send B2-NR reports with carrierFreq: 629984 1 time for each PCI1-PCI4
    ...    step3: attach UE do ANR, check RSC can be triggered
    ...    step4: sleep 5min, check 2036672-PCI1 1*0.9^3+initial; 2036672-PCI2 0.9^2+initial
    ...    2036672-PCI3 (1+5*0.9^2)*0.9+tobeverified; 2036672-PCI4 is removed
    ...    step5: sleep 1min, 2036672-PCI3 is suspend, LNRELN for PCI3 is deleted
    ...    step6: attach UE and verify PCI4 is OK
    Change anrNrHoNbrRelRemGuardTime to be 2
    prepare tuple with verifying verified suspend and tobeverified state
    trigger cell1 lock 1min
    report B2 1 times for 4 tuples
    RSC triggered after UE AnrInactivity indication received    ue_id=11
    check tuple status after two and half anrNrHoNbrRelRemGuardTime
    MO is deleted after triple anrNrHoNbrRelRemGuardTime and tuple is suspend
    make tuple verified by 5GHO with MO    nrarfcn=${NRARFCN2036667}    pci=4
    RSC not triggered for no tobeverified in list    ue_id=13
    [Teardown]    Delete MO for case teardown

CB005825-SR-A-B8_ET_05_01_mantain verification list after cell powersaving with anrNrNbrHoRelVerifyPeriod set to 0
    [Tags]
    [Documentation]
    ...    precondition:
    ...    2036672-PCI1 is tobeverified(exist LNADJN-1/LNADJNL-1)
    ...    2036672-PCI2 is verifying
    ...    2036672-PCI5 is verified
    ...    2036672-PCI4 is suspend
    ...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=450000
    ...    LNCEL-1/LNHON-1:nrPciHoNbrCounterDecay=0
    ...    LNBTS-1/ANR-0:anrNrHoNbrRelRemGuardTime=3
    ...    LNBTS-1/ANR-0:anrNrNbrHoRelVerifyPeriod=0min
    ...    step1: trigger cell powersaving, 2036672-PCI3 nrpcicount is 5, LNADJN-1 is deleted
    ...    step2: create LNRELN for PCI1
    ...    step3: B2-NR reports with carrierFreq: 2036672 1 time for each PCI1-PCI4
    ...    2036672-PCI1 1*0.9^3+initial; 2036672-PCI2 0.9^2+initial
    ...    2036672-PCI5 (1+5*0.9^2)*0.9+verified; 2036672-PCI4 suspend+1
    ...    step4: attach UE do anr, check no RSC triggered
    ...    step5: wait anrNrHoNbrRelRemGuardTime, LNRELN for PCI3 is deleted, LNRELN-1 is deleted
    ...    step6: wait anrNrHoNbrRelRemGuardTime, LNADJN for PCI3 is deleted
    ...    step7: attach UE do anr and verify PCI2 OK
    Change anrNrHoNbrRelRemGuardTime to be 3 and anrNrNbrHoRelVerifyPeriod to be 0
    prepare tuple with verifying verified suspend and tobeverified for case5
    trigger cell powersaving
    LNADJN-1 is deleted for orphan
    create LNRELN for PCI1
    report B2 1 times for 4 tuples
    RSC not triggered for no tobeverified in list    ue_id=13
    LNRELN is deleted after anrNrHoNbrRelRemGuardTime
    LNADJN is deleted after anrNrHoNbrRelRemGuardTime
    make tuple verified by 5GHO with MO for PCI2    nrarfcn=${NRARFCN2036667}
    [Teardown]    Delete MO for case teardown


CB005825-SR-A-B8_ET_07_01_mantain MOCs with orphan LNRELN or orphan LNADJNL after cell lock unlock
     [Tags]
    [Documentation]
    ...    precondition:
    ...    LNCELL-1:
    ...    2036672-PCI1: nrpcicount is 5*0.9^6
    ...    LNADJN-1
    ...    LNADJNL-1/LNRELN-1
    ...    LNADJNL-2/no LNRELN-2
    ...    LNADJN-3
    ...    LNADJNL-3/no LNRELN-3
    ...    LNRELN-4/no LNADJNL-4
    ...    LNADJN-8
    ...    LNADJNL-8/no LNRELN-8
    ...    2036672-PCI2:nrpcicount is 6
    ...    LNADJN-5
    ...    LNADJNL-5/no LNRELN-5
    ...    LANDJN-6/LNRELN-6
    ...    LNRELN-7/no LNADJNL-7
    ...    LNCELL-2:
    ...    2036672-PCI1:nrpcicount is 5*0.9^6
    ...    LNRELN-1
    ...    LNRELN-3
    ...    LNRELN-8,removeallowed is false
    ...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=300000
    ...    LNCEL-1/LNHON-1:nrPciHoNbrCounterDecay=0
    ...    LNCEL-2/LNHON-1:nrPciHoNbrRelRemThresh=300000
    ...    LNCEL-2/LNHON-1:nrPciHoNbrCounterDecay=0
    ...    LNBTS-1/ANR-0:anrNrHoNbrRelRemGuardTime=2
    ...    step1: decay pcicount on cell1 and cell2
    ...    step1: wait 1min then trigger cell1 lock for 1min, then cell unlock
    ...    LNRELN-1, LNRELN-3 LNADJN-1/LNADJNL-2 LNADJN-5/LNADJNL-5 is deleted for orphan
    ...    step2: wait 1min, LNRELN-4 and LNRELN-7 is not deleted for cell1 is lock 1min
    ...    step3: wait 1min, LNADJN-3 LNCEL-1/LNRELN-1 is deleted
    ...    step4: wait 2min, LNADJN-1 is deleted
    Create MO for case7
    Change anrNrHoNbrRelRemGuardTime to be 4
    make pcicount less than RemThresh on cell1
    make pcicount less than RemThresh on cell2
    trigger cell1 lock 2min after half anrNrHoNbrRelRemGuardTime
    make pcicount less than RemThresh on cell1
    check orphan LNRELN and orphan LNADJNL is deleted after cell lock unlock
    check orphan LNRELN is deleted after anrNrHoNbrRelRemGuardTime
    check LNRELN is deleted for decay anrNrHoNbrRelRemGuardTime after lock
    check orphan LNADJNL and LNADJN is deleted after anrNrHoNbrRelRemGuardTime

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
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${cellid}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cellid}
    ${ret1}=    Execute Uex Command    ${V_1}

UE attach to cell2
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
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

Report B2 multiple times to make tuple tobeverified on cell2
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ...    ${times}=6
    UE attach to cell2    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    ${times}+1
    Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    END
    UE detach    ue_id=${ue_id}

Trigger UE to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34

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
    set RSC CGI auto report with multiple plmn    ue_id=${ue_id}    pci=${pci}
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC
    UE detach    ue_id=${ue_id}

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

set RSC CGI auto report with multiple plmn
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:04|${nci-115969} tac=33
    ...    cgi_plmn_group cgi=262:03|${nci-115970} tac=33
    ...    freq_band_list=258
    Run Uex Command    ${cmd}

Delete MO for case teardown
    Release All Ues
    Delta Commission Parameters    ${delete_MO_teardown}
    Common Test Teardown And Stop Capture Logs

make tuple verified by 5GHO with MO
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    report B2 to make tuple tobeverified    nrarfcn=${nrarfcn}    pci=${pci}
    UE attach to cell1    ue_id=1
    send B1NR report with set CGI auto report    ue_id=1    nrarfcn=${nrarfcn}    pci=${pci}
    Wait CGI process succeed
    UE detach    ue_id=1
    Object Should Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Object Should Exist    LNCEL-1/LNRELN-254:plmnId:mcc=262

make tuple verified by 5GHO with MO for PCI2
    [Arguments]    ${nrarfcn}=${NRARFCN2036667}
    report B2 to make tuple tobeverified    nrarfcn=${nrarfcn}    pci=2
    UE attach to cell1    ue_id=1
    send B1NR report with set CGI auto report    ue_id=1    nrarfcn=${nrarfcn}    pci=2
    Wait CGI process succeed
    UE detach    ue_id=1
    Object Should Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Object Should not Exist    LNCEL-1/LNRELN-254:plmnId:mcc=262

make tuple suspend by 5GHO
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    report B2 to make tuple tobeverified    nrarfcn=${nrarfcn}    pci=${pci}
    set RSC CGI auto report with no freqbandlist    ue_id=11    pci=${pci}
    UE attached and check RSC and CGI triggered failed and cleanup is done    ue_id=11    pci=${pci}

make tuple verifying by 5GHO without MO
    [Arguments]    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    modify maxMumAnrMoiAllowed to be 20
    Report B2 multiple times to make tuple tobeverified    pci=${pci}
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=11    pci=${pci}
    modify maxMumAnrMoiAllowed to be 100

modify maxMumAnrMoiAllowed to be ${NUMBER}
    Delta Commission Parameters    LNBTS-1:maxNumAnrMoiAllowed=${NUMBER}

report B2 to make tuple tobeverified
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ...    ${times}=7
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
    ...    alias=B2_RRC    overall_timeout=20
    Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Flow Occurred As Expected    alias=B2_RRC
    FOR    ${temp}    IN RANGE    1    ${times}
        Trigger UE1 to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${nrarfcn}
    END
    UE detach    ue_id=${ue_id}

send B1NR report with set CGI auto report
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=56 nrsrq=77 cgi_plmn_group cgi=262:3,262:4|${nci-114719} tac=33
    ...    cgi_plmn_group cgi=262:5,262:6|0x1C502 tac=33 freq_band_list=258
    ...    phycell_id=2 narfcn=2036672 nrsrp=25 nrsrq=22 cgi=262:3,262:5|0x1C502 tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

Wait CGI process succeed
    sleep    20s    #wait CGI succeed

trigger cell1 lock 1min
    Delta Commission Parameters    ${lockcell}
    sleep    30s    #lock
    Delta Commission Parameters    ${unlockcell}

trigger cell1 lock 2min
    Delta Commission Parameters    ${lockcell}
    sleep    80s    #lock
    Delta Commission Parameters    ${unlockcell}

RSC not triggered for no tobeverified in list
    [Arguments]    ${ue_id}=11
    ${noRSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (purpose eq 'reportStrongestCells'))
    ${nocleanup_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32))
    ...    and (s-Measure eq 75) and (onDurationTimer eq "psf6"))
    Expect message Will Not Occur
    ...    ${noRSC_RRC}
    ...    alias=noRSC_RRC    overall_timeout=20
    Expect message Will Not Occur
    ...    ${nocleanup_RRC}
    ...    alias=nocleanup_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    sleep    5s    #wait for traffic
    Flow Not Occurred For Message    alias=noRSC_RRC
    Flow Not Occurred For Message    alias=nocleanup_RRC
    UE detach    ue_id=${ue_id}

RSC triggered after UE AnrInactivity indication received
    [Arguments]    ${ue_id}=11
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (purpose eq 'reportStrongestCells'))
    Expect message flow
    ...    ${RSC_RRC}
    ...    alias=RSC_RRC    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}
    sleep    5s    #wait for traffic
    Flow Occurred As Expected    alias=RSC_RRC
    UE detach    ue_id=${ue_id}

Change anrNrHoNbrRelRemGuardTime to be ${number}
    Delta Commission Parameters    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=${number}

Change anrNrHoNbrRelRemGuardTime to be 3 and anrNrNbrHoRelVerifyPeriod to be 0
    @{MO}    Create List    LNBTS-1/ANR-0:anrNrNbrHoRelVerifyPeriod=0min    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=3
    ...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=450000
    Delta Commission Parameters    ${MO}

set RSC CGI auto report with no freqbandlist
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672    ${pci}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nci-115970} tac=33
    Run Uex Command    ${cmd}

Create MO for case7
    Delta Commission Parameters    ${MOs_case7_2}

create LNADJNL for PCI1
    Delta Commission Parameters    ${MOs_case5_LNADJNL}

create LNRELN for PCI1
    Delta Commission Parameters    ${MOs_case5_LNRELN}

trigger cell powersaving
    Delta Commission Parameters    ${active_powersaving}
    Cell1 Keep In notEnergySaving State
    Wait cells enter into ES and check status
    UE attach to cell1    ue_id=1    cellid=2
    UEs generate load
    Wait cells exit ES
    Delta Commission Parameters    ${disable_powersaving}
    Ue detach    ue_id=1


Cell${number} Keep In notEnergySaving State
    Energy Saving State Should Be    ${number}    notEnergySaving

Cell${number} Enter Into energySaving State
    Wait Until Keyword Succeeds    ${SWITCH_TIMEOUT_ES}    10 s    Energy Saving State Should Be    ${number}    energySaving

Wait cells enter into ES and check status
    Sleep    ${lbpsMonWinForCellSOff}s
    Cell1 Enter Into energySaving State

Energy Saving State Should Be
    [Arguments]    ${lcr}    ${psm_exp}
    ${value}    get_scf_parameter_value    LNCEL-${lcr}:energySavingState
    Should Match Regexp    ${value}    ${psm_exp}

UEs generate load
    [Arguments]    ${ue_id}=1    ${mbps}=150
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=${mbps} trf_id=1 stats=true

Wait cells exit ES
    Sleep    ${${lbpsMonWinForCellSOn}+10}s
    Cell1 Keep In notEnergySaving State

Case setup
    Common Test Setup And Start To Capture Logs
    clean CB005825 verification list

clean CB005825 verification list
    Block Cell1
    Unblock Cell1

prepare tuple with verifying verified suspend and tobeverified state
    make tuple verifying by 5GHO without MO    nrarfcn=${NRARFCN2036667}    pci=2
    make tuple verified by 5GHO with MO    nrarfcn=${NRARFCN2036667}    pci=3
    make tuple suspend by 5GHO    nrarfcn=${NRARFCN2036667}    pci=4
    Report B2 multiple times to make tuple tobeverified    pci=1

report B2 1 times for 4 tuples
    report B2 multiple times to make tuple tobeverified    pci=1    times=1
    report B2 multiple times to make tuple tobeverified    pci=2    times=1
    report B2 multiple times to make tuple tobeverified    pci=3    times=1
    report B2 multiple times to make tuple tobeverified    pci=4    times=1

MO is deleted after triple anrNrHoNbrRelRemGuardTime and tuple is suspend
    sleep    1min    #half anrNrHoNbrRelRemGuardTime
    Object Should not Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Object Should not Exist    LNCEL-1/LNRELN-254:plmnId:mcc=262
    RSC not triggered for no tobeverified in list    ue_id=12

prepare tuple with verifying verified suspend and tobeverified for case5
    make tuple verifying by 5GHO without MO    nrarfcn=${NRARFCN2036667}    pci=2
    make tuple verified by 5GHO with MO    nrarfcn=${NRARFCN2036667}    pci=5
    make tuple suspend by 5GHO    nrarfcn=${NRARFCN2036667}    pci=4
    Report B2 multiple times to make tuple tobeverified    pci=1    times=3
    create LNADJNL for PCI1

check orphan LNRELN and orphan LNADJNL is deleted after cell lock unlock
    @{keep_moc}=    Create List
    ...    LNADJN-3:arfcnValueNR=2036672
    ...    LNADJN-8:arfcnValueNR=2036672
    ...    LNCEL-1/LNRELN-1:plmnId:mcc=262
    ...    LNCEL-1/LNRELN-7:plmnId:mcc=262
    Object Should Exist    ${keep_moc}
    Object Should not Exist    LNADJN-1/LNADJNL-2:gNBplmnId:mcc=262
    Object Should not Exist    LNADJN-5/LNADJNL-5:gNBplmnId:mcc=262
    Object Should not Exist    LNCEL-2/LNRELN-1:plmnId:mcc=262
    Object Should not Exist    LNCEL-2/LNRELN-3:plmnId:mcc=262

check orphan LNRELN is deleted after anrNrHoNbrRelRemGuardTime
    sleep     2min    #delete LNRELN-1 LNRELN-7
    Object Should not Exist    LNCEL-1/LNRELN-4:plmnId:mcc=262
    Object Should not Exist    LNCEL-1/LNRELN-7:plmnId:mcc=262

check LNRELN is deleted for decay anrNrHoNbrRelRemGuardTime after lock
    sleep    2min    #half anrNrHoNbrRelRemGuardTime
    Object Should not Exist    LNADJN-3:arfcnValueNR=2036672
    Object Should not Exist    LNCEL-1/LNRELN-1:plmnId:mcc=262

check orphan LNADJNL and LNADJN is deleted after anrNrHoNbrRelRemGuardTime
    sleep    4min    #LNADJN-1
    Object Should not Exist    LNADJN-1:arfcnValueNR=2036672

trigger cell1 lock 2min after half anrNrHoNbrRelRemGuardTime
    sleep    2min    #half anrNrHoNbrRelRemGuardTime
    trigger cell1 lock 2min

LNRELN is deleted after anrNrHoNbrRelRemGuardTime
    sleep    3min    #anrNrHoNbrRelRemGuardTime
    Object Should not Exist    LNCEL-1/LNRELN-255:plmnId:mcc=262
    Object Should not Exist    LNCEL-1/LNRELN-254:plmnId:mcc=262
    Object Should not Exist    LNCEL-1/LNRELN-1:plmnId:mcc=262
    RSC not triggered for no tobeverified in list    ue_id=15

LNADJN is deleted after anrNrHoNbrRelRemGuardTime
    sleep    3min    #anrNrHoNbrRelRemGuardTime
    Object Should not Exist    LNADJN-511:arfcnValueNR=2036672

LNADJN-1 is deleted for orphan
    Object Should not Exist    LNADJN-1:arfcnValueNR=2036672

make pcicount less than RemThresh on cell1
    Report B2 multiple times to make tuple tobeverified    pci=2
make pcicount less than RemThresh on cell2
    Report B2 multiple times to make tuple tobeverified on cell2    pci=2

check tuple status after two and half anrNrHoNbrRelRemGuardTime
    sleep    5min    #2.5 anrNrHoNbrRelRemGuardTime
    report B2 multiple times to make tuple tobeverified    pci=4    times=1