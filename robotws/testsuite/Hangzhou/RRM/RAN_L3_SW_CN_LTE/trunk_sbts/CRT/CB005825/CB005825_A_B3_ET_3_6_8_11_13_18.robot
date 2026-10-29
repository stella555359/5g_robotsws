*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Case setup
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS24R1    team-DevHZ5_SG1    owner-feng.2.chen
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
#...    ${numConsideredB2PerUe}=6
#${numConsideredB2PerUe}    0x1300F1
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

${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}',
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120,
...    ssb_mtc_periodicity_and_offset: 'sf5:0', ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000,
...    ss_rssi_end_symbol: 2}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '${GSCN22325}:${GSCN22325}',
...    meas_timing_carrier_freq: ${GSCN22325}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell3}    SEPARATOR=
...    {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x503', nr_arfcn: '${GSCN7812}:${GSCN7812}',
...    meas_timing_carrier_freq: ${GSCN7812}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell4}    SEPARATOR=
...    {id: 74, technology: nr , tac: 33, pci: '1:1', nrci: '0x504', nr_arfcn: '${NRARFCN630000}:${NRARFCN630000}',
...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz30,
...    ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell5}    SEPARATOR=
...    {id: 75, technology: nr , tac: 33, pci: '1:2', nrci: '0x1F', nr_arfcn: '${NRARFCN650000}:${NRARFCN650000}',
...    meas_timing_carrier_freq: ${NRARFCN650000}, ssb_subcarrier_spacing: kHz30,
...    ssb_mtc_periodicity_and_offset: 'sf5:0',
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

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
${nci-115974}    0x1C506
${nci-115975}    0x1C507

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
...      @{CB005825_ANR}

@{CB005825_ANR}
...    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=72
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS/ANR-0:consec5gHoFailThres=15
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=false
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=All|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=22|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=2036672|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=All|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=24|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=2036672|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=false|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=enabled|paramPlmnId=2
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mnc=3|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=2
...    LNBTS/ANR-0:anrNrParamPlmnList:mnc=4|paramPlmnId=2
...    LNBTS/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=2

@{change_actLnadjnGnbPlmnId_enable_disable}
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=All|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=22|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=2036672|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=true|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=disabled|paramPlmnId=1
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=24|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=2036672|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=false|paramPlmnId=2
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=enabled|paramPlmnId=2

@{plmn_0}
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:paramMeasConfId=1|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:gNBIdLength=24|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=2036672|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:anrDefRelPsHoAllowed=false|paramPlmnId=0
...    LNBTS/ANR-0:anrNrHoParamList:actLnadjnGnbPlmnId=enabled|paramPlmnId=0
...    LNBTS-1:maxNumAnrMoiAllowed=4000

@{CB007742}
...    LNBTS:actHOtoNR=true
...    LNBTS:actSelMobPrf=true
...    LNBTS:tS1RelOvDeltN=5000
...    LNBTS:tS1RelPrepN=5000
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actFlexQCIARPPMProfiles=true
...    LNBTS/MODPR-0:freqLayListPsHoNR=2036672
...    LNBTS/MODPR-0:freqLayListPsHoNRVoLte=2036672
...    @{CB007742_LNHON}

@{CB007742_LNHON}
...    LNCEL-1/LNHON-1:carrierFreqNr=2036672
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


@{LNRELN_CGI1}
...    LNCEL-1/LNRELN-255:cellIdentity=115970
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNRELN_CGI1_114719}
...    LNCEL-1/LNRELN-255:cellIdentity=114719
...    LNCEL-1/LNRELN-255:psHoAllowed=allowed
...    LNCEL-1/LNRELN-255:removeAllowed=true
...    LNCEL-1/LNRELN-255:plmnId:mcc=262
...    LNCEL-1/LNRELN-255:plmnId:mnc=3
...    LNCEL-1/LNRELN-255:plmnId:mncLength=2

@{LNRELN_CGI2}
...    LNCEL-1/LNRELN-254:cellIdentity=115970
...    LNCEL-1/LNRELN-254:psHoAllowed=forbidden
...    LNCEL-1/LNRELN-254:removeAllowed=true
...    LNCEL-1/LNRELN-254:plmnId:mcc=262
...    LNCEL-1/LNRELN-254:plmnId:mnc=4
...    LNCEL-1/LNRELN-254:plmnId:mncLength=2
@{LNADJN_CGI1}
...    LNADJN-511:arfcnValueNR=2036672
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=1
@{LNADJN_CGI1_114719}
...    LNADJN-511:arfcnValueNR=2036672
...    LNADJN-511:multiFrequencyBandList=258
...    LNADJN-511:physCellIdNr=5

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

@{LNADJN_CGI2}
...    LNADJN-510:arfcnValueNR=2036672
...    LNADJN-510:multiFrequencyBandList=258
...    LNADJN-510:physCellIdNr=2
...    LNADJN-510:gNBplmnId:mcc=262
...    LNADJN-510:gNBplmnId:mnc=1
...    LNADJN-510:gNBplmnId:mncLength=2

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

@{LNADJNL_CGI2}
...    LNADJN-511/LNADJNL-10:cellIdentity=115970
...    LNADJN-511/LNADJNL-10:gnbIdLength=24
...    LNADJN-511/LNADJNL-10:gNBplmnId:mcc=262
...    LNADJN-511/LNADJNL-10:gNBplmnId:mnc=4
...    LNADJN-511/LNADJNL-10:gNBplmnId:mncLength=2
...    LNADJN-511/LNADJNL-10:trackingAreaCodeNR=33
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=4
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=5
...    LNBTS/LNADJN-511/LNADJNL-10:plmnIdList:mcc=262|mnc=6

${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C1082080
...    304218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B082008284105182083841004142082
...    061040105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B
...    82E0B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668
...    003E71E00020406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A
...    00000061000880014207F80226A02
# above support both 7334 NRANR and 7742 HO to 5GSA

${ue_nr_capabilities}    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000
...    C039F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D802802010040118028030
...    100401004600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C008000110410
...    82000064104208000210410809A55334A262B9515DA8AEC4
${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B02004040C1803A020000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA
...    0000000010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B00080418000402000
...    1008000402020040088000201000080404008011800040200010080004020200400840002010100200440001008000402020040080

@{B3_restore_config}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-254
...    delete:LNADJN-511

@{case11_restore_config}
...    delete:LNCEL-1/LNRELN-255
...    delete:LNCEL-1/LNRELN-254
...    delete:LNCEL-1/LNRELN-253
...    delete:LNCEL-1/LNRELN-252
...    delete:LNCEL-1/LNRELN-251
...    delete:LNCEL-1/LNRELN-250
...    delete:LNCEL-1/LNRELN-249
...    delete:LNCEL-1/LNRELN-248
...    delete:LNCEL-1/LNRELN-247
...    delete:LNCEL-1/LNRELN-246
...    delete:LNCEL-1/LNRELN-245
...    delete:LNCEL-1/LNRELN-244
...    delete:LNCEL-1/LNRELN-243
...    delete:LNCEL-1/LNRELN-242
...    delete:LNCEL-1/LNRELN-241
...    delete:LNCEL-1/LNRELN-240
...    delete:LNCEL-1/LNRELN-239
...    delete:LNCEL-1/LNRELN-238
...    delete:LNCEL-1/LNRELN-237
...    delete:LNCEL-1/LNRELN-236
...    delete:LNCEL-1/LNRELN-235
...    delete:LNCEL-1/LNRELN-234
...    delete:LNCEL-1/LNRELN-233
...    delete:LNCEL-1/LNRELN-232
...    delete:LNADJN-510
...    delete:LNADJN-511

@{case25_restore_config}
...    delete:LNADJN-1
...    delete:LNCEL-1/LNRELN-255




*** Test Cases ***
CB005825-A-B3_ET_03_01_Verification NR-PCI NR-carrier pair create LNADJN LNADJNL and LNRELN
    [Tags]
    [Documentation]
    ...    precondition: no LNADJN LNADJNL and LNRELN MO existed
    ...     attach UE, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report, report CGI is triggered
    ...    send valid CGI report, tuple is verified, one pair of LNADJN LNADJNL and LNRELN is created
    report B2 to make tuple tobeverified    pci=5
    set RSC CGI auto report with CGI1    ue_id=11
    UE attach to cell1    ue_id=11
    Wait CGI process succeed
    Object Should Exist    ${LNRELN_CGI1_114719}
    Object Should Exist    ${LNADJN_CGI1_114719}
    Object Should Exist    ${LNADJNL_CGI1_114719}
    Do HO to created MO succeed    pci=5    nrarfcn=2036672    ue_id=1
    ue detach    ue_id=11
    [Teardown]    restore for case and common teardown    ${B3_restore_config}

CB005825-A-B3_ET_06_01_no valid NR-CGI report and change to tobeverified
    [Tags]
    [Documentation]
    ...    precondition: no LNADJN LNADJNL and LNRELN MO existed
    ...     attach UE, wait ANRInactivitytimer expired, RSC triggered,send valid RSC report,report CGI is triggered
    ...    (obsoleted due to UDP008&014)1 send invalid CGI report,no freqbandlist in report,discard, tuple change back to be tobeverified
    ...    (obsoleted due to UDP008&014)2 send invalid CGI report,no freqbandlist in report,with nosib1,discard,tuple change back to be tobeverified
    ...    3 send invalid CGI report,plmn in cgi-info is depulicated,discard,tuple change back to be tobeverified
    report B2 to make tuple tobeverified
    set RSC CGI auto report with depulicated plmn    ue_id=12
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=12
    ue detach    ue_id=12

CB005825-A-B3_ET_08_01_multiple NR-CGIs for a NR cell in RAN sharing no match
    [Tags]
    [Documentation]
    ...    precondition: no LNADJN LNADJNL and LNRELN MO existed
    ...     attach UE, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report, report CGI is triggered
    ...    send valid CGI report, tuple is verified, 2 pair of LNADJN LNADJNL and LNRELN is created
    Delta Commission Parameters    ${change_actLnadjnGnbPlmnId_enable_disable}
    report B2 to make tuple tobeverified    pci=1    narfcn=2036672
    RSC CGI auto report with cgi-Info-r15 with 2 PLMN matched    ue_id=11    pci=1
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=11
    2 LNRELN and 2 LNADJNL should be created
    ue detach    ue_id=11
    [Teardown]    restore for case and common teardown    ${B3_restore_config}

CB005825-A-B3_ET_11_01_multiple NR-CGIs in RAN sharing maxmal 12 LNRELN can be created
    [Tags]
    [Documentation]
    ...    precondition: no LNADJN LNADJNL and LNRELN MO existed
    ...     attach UE, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report, report CGI is triggered
    ...    send valid CGI report inncluding 12 cgi_plmn, tuple is verified, 12 pair of LNADJNL and LNRELN are created
    Delta Commission Parameters    ${plmn_0}
    report B2 to make tuple tobeverified    pci=1    narfcn=2036672
    report B2 to make tuple tobeverified    pci=2    narfcn=2036672
    set RSC CGI auto report cgi-Info-r15 with 12 PLMN NCI 115970    ue_id=11    pci=1
    set RSC CGI auto report cgi-Info-r15 with 12 PLMN NCI 115969    ue_id=12    pci=2
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=11
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=12    pci=2
    12 LNRELN and 12 LNADJNL are created    cellIdentity=115970
    12 LNRELN and 12 LNADJNL are created later    cellIdentity=115969
    Detach UEs    11    12
    [Teardown]    restore for case and common teardown    ${case11_restore_config}

CB005825-A-B3_ET_13_01_MO creation verification when maxNumAnrMoiAllowed-1 is reached
    [Tags]
    [Documentation]
    ...    precondition: no LNADJN LNADJNL and LNRELN MO existed
    ...    there's 18 ANR MO existed already, max number of ANRMO is 23, so 5 MO can be created
    ...    attach UE, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report, report CGI is triggered
    ...    send valid CGI report, tuple is verified, 1 pair of LNRELN LNADJNL and LNRELN are created, left 2 MO can be created
    ...    attach another UE to verify another tuple
    ...    tuple is verified, 1 pair of LNRELN LNADJNL and LNRELN need to be created, but 3 MO can't be created

    modify maxMumAnrMoiAllowed to be 23
    report B2 to make tuple tobeverified    ue_id=1    pci=6    narfcn=2036672
    report B2 to make tuple tobeverified    ue_id=2    pci=7    narfcn=2036672
    Attach UE and verify PCI6 tuple    ue_id=11    pci=6
    LNRELN and LNADJNL are created for PCI6
    Attach UE and verify PCI7 tuple    ue_id=12    pci=7
    LNRELN and LNADJNL are not created for PCI7
    Detach UEs    11    12
    [Teardown]    restore for case and common teardown    ${B3_restore_config}

CB005825-A-B3_ET_18_01_MO creation verification when maxNum of LNADJNL is reached
    [Tags]
    [Documentation]
    ...    precondition: no LNADJN LNADJNL and LNRELN MO existed
    ...    maxNum of LNADJNL is 12 for per LNADJN, create 12 LNADJNL with PLMN 1~12
    ...    attach UE, wait ANRInactivitytimer expired, RSC triggered, send valid RSC report, report CGI is triggered
    ...    send valid CGI report with PLMN6, tuple is verified, LNADJN and LNADJNL existed, so LNRELN created
    ...    attach another UE to verify this tuple again
    ...    send valid CGI report with PLMN14, tuple is verified, no LNADJN and LNADJNL existed, need to create new ones
    ...    but the maxmun of LNADJNL is reached, so no MO created
    Delta Commission Parameters    ${plmn_0}
    Create 12 LNADJNL
    report B2 to make tuple tobeverified    pci=1    narfcn=2036672
    Attach UE and verify PCI1 with PLMN6    ue_id=13    pci=1
    Object Should Exist    LNCEL-1/LNRELN-255:cellIdentity=115970
    Attach UE and verify PCI1 with PLMN14    ue_id=14    pci=1
    Object Should Not Exist    LNCEL-1/LNRELN-254:cellIdentity=115970
    Detach UEs    13    14
    [Teardown]    restore for case and common teardown    ${case25_restore_config}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Perform Steps After Onair
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create UE Alias for mulipule UEs
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB     enb_id=7    id_type=wts
    Set UE parameters for ENDC capability

Create UE Alias for mulipule UEs
    FOR    ${ue_id}    IN RANGE    11    17
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Case setup
    Common Test Setup And Start To Capture Logs
    clean CB005825 verification list

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Uex Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=11 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=2 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=11 nr_supported_bands=78,258
    Set ENDC capability
    Config UE11 to UE16 support NRANR

Config UE11 to UE16 support NRANR
    FOR    ${ue_id}    IN RANGE    11    17
        Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        Execute Uex Command    ue_param id=${ue_id} nr_supported_bands=78,258
    END

Set ENDC capability
    Execute Egate Command    ue_enb_param id=1,2,11,12,13,14,15,16 spid=34
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=4:1

Perform Steps After Onair
    @{lnadj}    Create List    LNADJ:cPlaneIpAddr=10.0.1.3    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj}

Modify Yaml
    Update Yaml    UEs/UE_sets/1    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_eutra_nr_capabilities}
    Update Yaml    UEs/UE_sets/2    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_eutra_nr_capabilities}
    Update Yaml    UEs/UE_sets/11    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_eutra_nr_capabilities}
    Update Yaml    UEs/UE_sets/12    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_eutra_nr_capabilities}
    Update Yaml    UEs/UE_sets/13    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_eutra_nr_capabilities}
    Update Yaml    UEs/UE_sets/14    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_eutra_nr_capabilities}
    Update Yaml    UEs/UE_sets/15    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_eutra_nr_capabilities}
    Update Yaml    UEs/UE_sets/16    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_eutra_nr_capabilities}

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 4, precedence: 4}
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
    ...        - {id: 31, technology: lte, tac: 33, pci: '1:2', eci: '0x0000A1F', earfcn: '1400:19400', bw: 20}

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

UE attach to cell1
    [Arguments]    ${ue_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    ${ret1}    Execute Uex Command    ${V_1}

UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

Trigger UE1 to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34
    sleep    1

Trigger UE to send B2-NR for freq with PCI1
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20
    ...    narfcn=${narfcn} amount=1
    Execute Uex Command     ${cmd}

report B2 to make tuple tobeverified
    [Documentation]      new R&D paramter:numConsideredB2PerUe by CB005825-SR-A-UPD005 ,default value 1. UE detach and reattach to make
    ...    nrAnrHoPciCounter updated
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=2036672
    FOR    ${temp}    IN RANGE    1    7
        UE attach to cell1    ue_id=${ue_id}
        Expect message flow
        ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
        ...    alias=B2_RRC_{temp}    overall_timeout=5
        Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
        Flow Occurred As Expected    alias=B2_RRC_{temp}
        Trigger UE to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
        UE detach    ue_id=${ue_id}
    END

clean CB005825 verification list
    Block Cell1
    Unblock Cell1

set RSC CGI auto report with no freqbandlist
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=1 narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nci-115970} tac=33
    Run Uex Command    ${cmd}

set RSC CGI auto report with depulicated plmn
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=1 narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03|${nci-115970} tac=33
    ...    cgi_plmn_group
    ...    cgi=262:04,262:01,262:02,262:05,262:06,262:09,262:03,262:12,262:10,262:13,262:14,262:15|${nci-115970}
    ...    tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

set RSC CGI auto report with no freqbandlist and nosib1
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=1 narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi_plmn_group
    ...    cgi=262:99|${nci-115970} nr_cgi_nosib1=1:1
    Run Uex Command    ${cmd}

RSC CGI auto report with cgi-Info-r15 with 2 PLMN matched
    [Arguments]    ${ue_id}    ${pci}=1    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03|${nci-115970} tac=33
    ...    cgi_plmn_group cgi=262:04,262:05,262:06|${nci-115970} tac=33
    ...    cgi_plmn_group cgi=262:97,262:81|${nci-115969} tac=33
    ...    cgi_plmn_group cgi=262:88|${nci-115970} tac=33
    ...    freq_band_list=258
    Run Uex Command    ${cmd}

set RSC CGI auto report cgi-Info-r15 with 12 PLMN NCI 115970
    [Arguments]    ${ue_id}    ${pci}    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:01|${nci-115970} freq_band_list=258 tac=33
    ...    cgi_plmn_group cgi=262:02|${nci-115970} freq_band_list=259 tac=33
    ...    cgi_plmn_group cgi=262:03|${nci-115970} freq_band_list=1 tac=33
    ...    cgi_plmn_group cgi=262:04|${nci-115970} freq_band_list=2 tac=33
    ...    cgi_plmn_group cgi=262:05|${nci-115970} freq_band_list=3 tac=33
    ...    cgi_plmn_group cgi=262:06|${nci-115970} freq_band_list=4 tac=33
    ...    cgi_plmn_group cgi=262:07|${nci-115970} freq_band_list=5 tac=33
    ...    cgi_plmn_group cgi=262:08|${nci-115970} freq_band_list=6 tac=33
    ...    cgi_plmn_group cgi=262:09|${nci-115970} freq_band_list=7 tac=33
    ...    cgi_plmn_group cgi=262:10|${nci-115970} freq_band_list=8 tac=33
    ...    cgi_plmn_group cgi=262:11|${nci-115970} freq_band_list=9 tac=33
    ...    cgi_plmn_group cgi=262:12|${nci-115970} freq_band_list=10 tac=33
    Run Uex Command    ${cmd}

set RSC CGI auto report cgi-Info-r15 with 12 PLMN NCI 115969
    [Arguments]    ${ue_id}    ${pci}    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:01|${nci-115969} freq_band_list=258 tac=33
    ...    cgi_plmn_group cgi=262:02|${nci-115969} freq_band_list=259 tac=33
    ...    cgi_plmn_group cgi=262:03|${nci-115969} freq_band_list=1 tac=33
    ...    cgi_plmn_group cgi=262:04|${nci-115969} freq_band_list=2 tac=33
    ...    cgi_plmn_group cgi=262:05|${nci-115969} freq_band_list=3 tac=33
    ...    cgi_plmn_group cgi=262:06|${nci-115969} freq_band_list=4 tac=33
    ...    cgi_plmn_group cgi=262:07|${nci-115969} freq_band_list=5 tac=33
    ...    cgi_plmn_group cgi=262:08|${nci-115969} freq_band_list=6 tac=33
    ...    cgi_plmn_group cgi=262:09|${nci-115969} freq_band_list=7 tac=33
    ...    cgi_plmn_group cgi=262:10|${nci-115969} freq_band_list=8 tac=33
    ...    cgi_plmn_group cgi=262:11|${nci-115969} freq_band_list=9 tac=33
    ...    cgi_plmn_group cgi=262:12|${nci-115969} freq_band_list=10 tac=33
    Run Uex Command    ${cmd}

set RSC CGI auto report cgi-Info-r15 with PLMN6
    [Arguments]    ${ue_id}    ${pci}    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:06|${nci-115970} freq_band_list=258 tac=33
    Run Uex Command    ${cmd}

set RSC CGI auto report cgi-Info-r15 with PLMN14 and PLMN6
    [Arguments]    ${ue_id}    ${pci}    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g
    ...    cgi_plmn_group cgi=262:14|${nci-115970} tac=33
    ...    cgi_plmn_group cgi=262:06|${nci-115970} tac=33
    ...    freq_band_list=258
    Run Uex Command    ${cmd}

Wait CGI process succeed
    sleep    8s    #wait CGI succeed

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
    UE attach to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=NRANR_RRC

2 LNRELN and 2 LNADJNL should be created
    Object Should Exist    ${LNRELN_CGI1}
    Object Should Exist    ${LNADJN_CGI1}
    Object Should Exist    ${LNADJNL_CGI1}
    Object Should Exist    ${LNADJNL_CGI2}
    Object Should Exist    ${LNRELN_CGI2}

12 LNRELN and 12 LNADJNL are created
    [Arguments]    ${cellIdentity}
    Object Should Exist    ${LNADJN_CGI1}
    FOR    ${n}    IN RANGE    1    13
        ${n2}     evaluate    12-${n}
        @{LNADJNL}    Create List
        ...    LNADJN-511/LNADJNL-${n2}:cellIdentity=${cellIdentity}
        ...    LNADJN-511/LNADJNL-${n2}:gnbIdLength=24
        ...    LNADJN-511/LNADJNL-${n2}:gNBplmnId:mcc=262
        ...    LNADJN-511/LNADJNL-${n2}:gNBplmnId:mnc=${n}
        ...    LNADJN-511/LNADJNL-${n2}:gNBplmnId:mncLength=2
        ...    LNADJN-511/LNADJNL-${n2}:trackingAreaCodeNR=33
        ...    LNADJN-511/LNADJNL-${n2}:plmnIdList:mcc=262
        ...    LNADJN-511/LNADJNL-${n2}:plmnIdList:mnc=${n}
        ...    LNADJN-511/LNADJNL-${n2}:plmnIdList:mncLength=2
        ${n1}     evaluate    256-${n}
        @{LNRELN}    Create List
        ...    LNCEL-1/LNRELN-${n1}:cellIdentity=${cellIdentity}
        ...    LNCEL-1/LNRELN-${n1}:psHoAllowed=forbidden
        ...    LNCEL-1/LNRELN-${n1}:removeAllowed=true
        ...    LNCEL-1/LNRELN-${n1}:plmnId:mcc=262
        ...    LNCEL-1/LNRELN-${n1}:plmnId:mnc=${n}
        ...    LNCEL-1/LNRELN-${n1}:plmnId:mncLength=2
        Object Should Exist    ${LNRELN}
        Object Should Exist    ${LNADJNL}
    END

12 LNRELN and 12 LNADJNL are created later
    [Arguments]    ${cellIdentity}
    Object Should Exist    ${LNADJN_CGI2}
    FOR    ${n}    IN RANGE    1    13
        ${n2}     evaluate    12-${n}
        @{LNADJNL}    Create List
        ...    LNADJN-510/LNADJNL-${n2}:cellIdentity=${cellIdentity}
        ...    LNADJN-510/LNADJNL-${n2}:gnbIdLength=24
        ...    LNADJN-510/LNADJNL-${n2}:gNBplmnId:mcc=262
        ...    LNADJN-510/LNADJNL-${n2}:gNBplmnId:mnc=${n}
        ...    LNADJN-510/LNADJNL-${n2}:gNBplmnId:mncLength=2
        ...    LNADJN-510/LNADJNL-${n2}:trackingAreaCodeNR=33
        ...    LNADJN-510/LNADJNL-${n2}:plmnIdList:mcc=262
        ...    LNADJN-510/LNADJNL-${n2}:plmnIdList:mnc=${n}
        ...    LNADJN-510/LNADJNL-${n2}:plmnIdList:mncLength=2
        ${n1}     evaluate    244-${n}
        @{LNRELN}    Create List
        ...    LNCEL-1/LNRELN-${n1}:cellIdentity=${cellIdentity}
        ...    LNCEL-1/LNRELN-${n1}:psHoAllowed=forbidden
        ...    LNCEL-1/LNRELN-${n1}:removeAllowed=true
        ...    LNCEL-1/LNRELN-${n1}:plmnId:mcc=262
        ...    LNCEL-1/LNRELN-${n1}:plmnId:mnc=${n}
        ...    LNCEL-1/LNRELN-${n1}:plmnId:mncLength=2
        Object Should Exist    ${LNRELN}
        Object Should Exist    ${LNADJNL}
    END

LNRELN and LNADJNL are created for PCI6
    @{LNADJN}    Create List
    ...    LNADJN-511:arfcnValueNR=2036672
    ...    LNADJN-511:multiFrequencyBandList=78
    ...    LNADJN-511:physCellIdNr=6

    @{LNADJNL}    Create List
    ...    LNADJN-511/LNADJNL-11:cellIdentity=115974
    ...    LNADJN-511/LNADJNL-11:gnbIdLength=24
    ...    LNADJN-511/LNADJNL-11:gNBplmnId:mcc=262
    ...    LNADJN-511/LNADJNL-11:gNBplmnId:mnc=3
    ...    LNADJN-511/LNADJNL-11:gNBplmnId:mncLength=2
    ...    LNADJN-511/LNADJNL-11:trackingAreaCodeNR=33
    ...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=3
    ...    LNADJN-511/LNADJNL-11:plmnIdList:mcc=262|mnc=4

    @{LNRELN}    Create List
     ...    LNCEL-1/LNRELN-255:cellIdentity=115974
     ...    LNCEL-1/LNRELN-255:psHoAllowed=forbidden
     ...    LNCEL-1/LNRELN-255:removeAllowed=true
     ...    LNCEL-1/LNRELN-255:plmnId:mcc=262
     ...    LNCEL-1/LNRELN-255:plmnId:mnc=3
     ...    LNCEL-1/LNRELN-255:plmnId:mncLength=2
     Object Should Exist    ${LNRELN}
     Object Should Exist    ${LNADJNL}
     Object Should Exist    ${LNADJN}
     Object Should not Exist    LNADJN-510:gNBplmnId:mcc=262
LNRELN and LNADJNL are not created for PCI7
     Object Should not Exist    LNADJN-510:physCellIdNr=7
     Object Should not Exist    LNCEL-1/LNRELN-254:plmnId:mcc=262


Create 12 LNADJNL
    ${delta_params}    Create List    LNADJN-1:arfcnValueNR=2036672
    ...    LNADJN-1:multiFrequencyBandList=258
    ...    LNADJN-1:physCellIdNr=1
    FOR    ${instance}    IN RANGE    0    12
        ${pci_value}    Evaluate    ${instance}+1
        Append To List    ${delta_params}
        ...    LNADJN-1/LNADJNL-${instance}:cellIdentity=115970
        ...    LNADJN-1/LNADJNL-${instance}:gnbIdLength=22
        ...    LNADJN-1/LNADJNL-${instance}:gNBplmnId:mcc=262
        ...    LNADJN-1/LNADJNL-${instance}:gNBplmnId:mnc=${pci_value}
        ...    LNADJN-1/LNADJNL-${instance}:gNBplmnId:mncLength=2
        ...    LNADJN-1/LNADJNL-${instance}:trackingAreaCodeNR=33
        ...    LNADJN-1/LNADJNL-${instance}:plmnIdList:mcc=262
        ...    LNADJN-1/LNADJNL-${instance}:plmnIdList:mnc=${pci_value}
        ...    LNADJN-1/LNADJNL-${instance}:plmnIdList:mncLength=2
    END
    Delta Commission Parameters    ${delta_params}
    Delta Commission Parameters    ${plmn_0}

Attach UE and verify PCI6 tuple
    [Arguments]    ${ue_id}    ${pci}
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    narfcn=2036672 phycell_id=${pci} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi_plmn_group
    ...    cgi=262:03,262:04|${nci-115974}
    ...    freq_band_list=78 tac=33
    Run Uex Command    ${cmd}
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=${ue_id}    pci=${pci}

Attach UE and verify PCI7 tuple
    [Arguments]    ${ue_id}    ${pci}
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    narfcn=2036672 phycell_id=${pci} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi_plmn_group
    ...    cgi=262:03,262:04|${nci-115975}
    ...    freq_band_list=78 tac=33 cgi_plmn_group cgi=262:05,262:06|0x1C508 freq_band_list=78 tac=33
    Run Uex Command    ${cmd}
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=${ue_id}    pci=${pci}

Detach UEs
     [Arguments]    ${start_ue_id}    ${end_ue_id}
     FOR    ${local_ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id} + 1
        Execute Uex Command    ue_detach id=${local_ue_id}
     END

restore for case and common teardown
    [Arguments]    ${restore_parameter}
    Delta Commission Parameters    ${restore_parameter}
    Common Test Teardown And Stop Capture Logs

modify maxMumAnrMoiAllowed to be 23
    Delta Commission Parameters    ${plmn_0}
    Delta Commission Parameters    LNBTS-1:maxNumAnrMoiAllowed=23

Attach UE and verify PCI1 with PLMN14
    [Arguments]    ${ue_id}    ${pci}
    clean CB005825 verification list
    report B2 to make tuple tobeverified    pci=1    narfcn=2036672
    set RSC CGI auto report cgi-Info-r15 with PLMN14 and PLMN6    ue_id=${ue_id}    pci=${pci}
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=${ue_id}    pci=${pci}

Attach UE and verify PCI1 with PLMN6
    [Arguments]    ${ue_id}    ${pci}
    set RSC CGI auto report cgi-Info-r15 with PLMN6    ue_id=${ue_id}    pci=1
    UE attached and check RSC and CGI triggered and cleanup is done    ue_id=${ue_id}    pci=1

set RSC CGI auto report with CGI1
    [Arguments]    ${ue_id}=1    ${nrarfcn}=2036672
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=5 narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nci-114719} tac=33 freq_band_list=258
    Run Uex Command    ${cmd}

Do HO to created MO succeed
    [Arguments]    ${pci}=1    ${nrarfcn}=2036672    ${ue_id}=1
    Execute Egate Command    mme_param id=1 target_enb_id_for_fake_5g_ho=0x0000A
    Execute Egate Command    enb_param id=10 drb_id_begin=4
    Expect message flow
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (radioNetwork eq "successful-handover"))
    ...    alias=HO_RRC    overall_timeout=18
    UE attach to cell1    ue_id=${ue_id}
    Trigger UE1 to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${nrarfcn} amount=1
    Flow Occurred As Expected    alias=HO_RRC

