*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS24R1    team-DevHZ5_SG1    owner-carol.an
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
...    ${maxvalure}
...    ${maxsize}
...    ${AnrNrNbrRelRemPeriodicCheckTimer}
...    ${TUecRadDebugLogEnabledGlobal}
...    ${TUecRadDebugLogEnabledUec}
...    ${TUecRadDebugLogEnabledCommon}
...    ${TUecRadDebugLogEnabledCommonCodec}
${maxvalure}    0x1300DA=10
${maxsize}    0x1300DB=5
${AnrNrNbrRelRemPeriodicCheckTimer}    0x1300E2=1
${TUecRadDebugLogEnabledGlobal}    0x130020=1
${TUecRadDebugLogEnabledUec}    0x130021=1
${TUecRadDebugLogEnabledCommon}    0x13001E=1
${TUecRadDebugLogEnabledCommonCodec}    0x13001F=1

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
@{PARAMS_IN_EMIL}
...    0x400e
...    0x7509
...    0x75ce

@{CB005825}
...    LNCEL-1:measQuantityNr=RSRP
...    LNCEL-1:t304InterRATN=500ms
...    LNCEL-1:a2TimeToTriggerActNRMeas=320ms
...    LNCEL-1:threshold2NR=25
...    LNCEL-1:hysThreshold2NR=0
...    @{CB007742}
...    LNBTS:actUeBasedAnrNrHo=true
...    @{CB005825_ANR}

@{CB005825_ANR}
...    LNBTS/ANR-0:anrNrHoNbrRelRemGuardTime=72
...    LNBTS/ANR-0:anrNrNbrHoRelVerifyPeriod=960min
...    LNBTS/ANR-0:consec5gHoFailThres=15
...    LNBTS/ANR-0:actAutoNrHoNeighRemoval=false
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
...    LNCEL-1/LNHON-1:nrPciHoNbrRelRemThresh=100000
...    LNCEL-1/LNHON-1:nrPciHoNbrCounterDecay=1000

@{case13change}
...    LNCEL-1:actDrx=true
...    LNCEL-1:drxProfile105:drxProfilePriority=30
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${invalidfreq}
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=Single Carrier|paramPlmnId=0

@{Restore_case13change}
...    LNBTS/ANR-0:anrNrHoParamList:carrierFreqNrCell=${NRARFCN2036667}|paramPlmnId=0

${invalidfreq}    2070831

@{Online_params_for_case23}
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=56|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-10|paramMeasConfId=1

@{restore_case23}
...    LNCEL-1:actDrx=false
...    LNBTS/ANR-0:anrNrHoParamList:frqNrCarSelect=All|paramPlmnId=0
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1

@{Online_params_for_case9}
...    LNCEL:actPeriodicB1NRMeas=basic
...    LNBTS-1/NRMEASDPR-0:supervisionTimerB1NR=3
...    LNBTS-1/NRMEASDPR-0:mrWaitTimer=300
...    LNBTS-1/NRMEASDPR-0:retryTimerB1NR=20

@{Online_params_for_case10}
...    LNBTS-1:qciTab6:lteNrDualConnectSupport=disabled
...    LNBTS-1:qciTab8:arpEnDcMask=0
...    delete:LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrq

@{Restore_params_for_case10}
...    LNBTS-1:qciTab8:arpEnDcMask=65534
...    LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    delete:LNADJN-511
...    delete:LNADJN-510

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

*** Test Cases ***
CB005825-A-B2_ET_07_01_Do NR-reportStrongestCells succeed with HRL and MG but reportCGI fail
    [Tags]
    report B2 to make 5 tuple pair tobeverified
    Attach UE with HRL with NRrestrictedinEPSasSecondaryRAT and RSC triggered    ue_id=1
    [Teardown]    case7_teardown

CB005825-A-B2_ET_09_01_Do NR-reportStrongestCells succeed after supervisionTimerB1NR and mrWaitTimer expired
    [Tags]
    Online change to configure retryTimerB1NR
    report B2 to make tuple tobeverified    pci=1    narfcn=${NRARFCN2036667}
    UE1 attach and check RSC triggered after supervisionTimerB1NR timeout
    [Teardown]    case9_teardown

CB005825-A-B2_ET_10_01_Do NR-reportStrongestCells succeed with arpEnDcMask disable and just config only thresholdNrRsrp
    [Tags]
    Online change QCI6 QCI8 thresholdNrRsrp config
    report B2 to make tuple tobeverified    pci=1    narfcn=${NRARFCN2036667}
    report B2 to make tuple tobeverified    pci=2    narfcn=${NRARFCN2036667}
    Attach UE1 with default QCI8 no support ARP then Wait NRANR timer expire and trigger RSC    #check B1 not active
    Attach UE11 with default QCI6 no support ENDC then Wait NRANR timer expire and trigger RSC    #check B1 not active
    [Teardown]    case10_teardown

CB005825-A-B2_ET_13_01_NR CGI triggered due to B1 reportOnleave for LTE4193 with mrWaitTimer configured
    [Tags]
    Online change drxProfiles config
    clean CB005825 verification list
    report B2 to make tuple tobeverified    ue_id=1    pci=1    narfcn=${NRARFCN2036667}
    Attach UE1 and send B1 MR for 2036667 PCI1 Check ReportCGI should trigger
    [Teardown]    case13_teardown

CB005825-A-B2_ET_23_01_fail to trigger ReportCGI reportOnleave becacause of B1 MR threshold not match or PCI not match
    [Tags]
    Online change thresholdNr config
    report B2 to add tuple PCI1-PCI5 to tobeverified list
    Attach UE1 and Send B1 MR whose rsrp not satisfy
    Attach UE2 and Send B1 MR whose pci not satisfy
    Attach UE3 and Send B1 MR Check ReportCGI should trigger
    [Teardown]    case23_teardown

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_11    ue_id=11    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Set UE parameters for ENDC capability

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Uex Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=11 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=2 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=11 nr_supported_bands=78,258
    Execute Egate Command    ue_enb_param id=1,11 spid=34
    Config gnb7

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
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 4, precedence: 4}
    Update Yaml    UEs/UE_sets/11     bearer: bearer_set_2
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

Set RSC auto report with 5 PCI
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=1 narfcn=${NRARFCN2036667} nrsrp=34 nrsrq=22 nsinr=31 strongest=nr5g
    ...    phycell_id=2 narfcn=${NRARFCN2036667} nrsrp=33 nrsrq=22 nsinr=31 strongest=nr5g
    ...    phycell_id=3 narfcn=${NRARFCN2036667} nrsrp=32 nrsrq=22 nsinr=31 strongest=nr5g
    ...    phycell_id=4 narfcn=${NRARFCN2036667} nrsrp=31 nrsrq=22 nsinr=31 strongest=nr5g
    ...    phycell_id=5 narfcn=${NRARFCN2036667} nrsrp=30 nrsrq=22 nsinr=31 strongest=nr5g
    Run Uex Command    ${cmd}

set RSC CGI auto report
    [Arguments]    ${ue_id}=1    ${nrcell_id}=${nci-115969}    ${pci}=1    ${nrarfcn}=${NRARFCN2036667}
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=25 nrsrq=22 nsinr=31 strongest=nr5g cgi=262:03|${nrcell_id} freq_band_list=258 tac=33
    Run Uex Command    ${cmd}

Trigger UE to send B2-NR for freq with PCI1
    [Arguments]    ${ue_id}    ${pci}    ${narfcn}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_NR phycell_id=${pci} nrsrp=97 srsrp=0 nsinr=20 narfcn=${narfcn} amount=1

Attach UE with HRL with NRrestrictedinEPSasSecondaryRAT
    [Arguments]    ${ue_id}
    Execute Egate Command    mme_ho_restriction_list id=1 restrict_nr_access=on
    Execute Egate Command    ue_mme_param id=${ue_id} ho_restrictions=nr_eps ho_restriction_list_id=1
    UE attach to cell1    ue_id=${ue_id}    #pass_regexp=NRrestrictioninEPSasSecondaryRAT
    Cancel HRL

Cancel HRL
    Execute Egate Command    mme_ho_restriction_list id=1 restrict_nr_access=off
    Execute Egate Command    ue_mme_param id=1 ho_restrictions=nr_eps ho_restriction_list_id=no

Online change to configure retryTimerB1NR
    [Documentation]    related with feature LTE5740
    Delta Commission Parameters    ${Online_params_for_case9}

case7_teardown
    Release All UEs
    Cancel HRL
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

case9_teardown
    Release All UEs
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

Online change QCI6 QCI8 thresholdNrRsrp config
    Delta Commission Parameters    ${Online_params_for_case10}

Online change drxProfiles config
    Delta Commission Parameters    ${case13change}

Online change thresholdNr config
    Delta Commission Parameters    ${Online_params_for_case23}

clean CB005825 verification list
    Block Cell1
    Unblock Cell1
    Cells Should Be Onair

Attach UE and check RSC CGI triggered as expected
    [Arguments]    ${ue_id}    ${nrarfcn}    ${pci}    ${nrcell_id}    
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and (purpose eq 'reportStrongestCells')) as RSC_RRC
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${nrarfcn}) and (cellForWhichToReportCGI-r15 eq ${pci})) as CGI_RRC
    ...    alias=NRANR_RRC    overall_timeout=18
    UE attach to cell1    ue_id=${ue_id}
    set RSC CGI auto report    ue_id=${ue_id}    nrcell_id=${nrcell_id}    pci=${pci}    nrarfcn=${nrarfcn}
    Flow Occurred As Expected    alias=NRANR_RRC

Attach UE1 with default QCI8 no support ARP then wait NRANR timer expire and trigger RSC
    Attach UE and check RSC CGI triggered as expected    ue_id=1    nrarfcn=${NRARFCN2036667}    pci=1    nrcell_id=${nci-115970}

Attach UE11 with default QCI6 no support ENDC then wait NRANR timer expire and trigger RSC
    Attach UE and check RSC CGI triggered as expected    ue_id=11    nrarfcn=${NRARFCN2036667}    pci=2    nrcell_id=${nci-115970}

Attach UE with HRL with NRrestrictedinEPSasSecondaryRAT and RSC triggered
    [Documentation]    this kw also check CGI triggered
    [Arguments]    ${ue_id}
    set RSC auto report with 5 pci
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells'))
    ...    UE_${ue_id}:RRC_MeasurementReport (measurementReport is present)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (cellForWhichToReportCGI-r15 eq 1))
    ...    alias=RSC_RRC    overall_timeout=8
    Attach UE with HRL with NRrestrictedinEPSasSecondaryRAT    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RSC_RRC

UE1 attach and check RSC triggered after supervisionTimerB1NR timeout
    [Documentation]
    ...    this kw also check CGI triggered
    ...    measid 17,18 is for B1NR
    ...    measid 32 is for RSC/CGI
    ...     -->after wait supervisionTimerB1NR no B1 report
    ...     -->B1 deactive, then start retryTimerB1NR(20s)
    ...     -->NRANR timer(5s) expired, RSC start, stop retryTimerB1NR
    ...     -->RSC timer expired(2.5s), NRANR cleanup, activate B1, start retryTimerB1NR
    ...     -->supervisionTimerB1NR expired(3s), B1 deactivated
    ...     -->wait retryTimerB1NR expire(20s,since last B1 active)-->B1 activated
    set RSC CGI auto report
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17, 18))
    ...    UE_1:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')) as RSC_RRC
    ...    UE_1:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (cellForWhichToReportCGI-r15 eq 1)) as CGI_RRC
    ...    UE_1:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (32)) and (measIdToAddModList contains (17, 18))) as clean_RRC
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17, 18))
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (17, 18))
    ...    alias=NRANR_RRC    overall_timeout=30
    UE attach to cell1    ue_id=1
    Flow Occurred As Expected    alias=NRANR_RRC

report B2 to make 5 tuple pair tobeverified
    report B2 to make tuple tobeverified    pci=1    narfcn=${NRARFCN2036667}
    report B2 to make tuple tobeverified    pci=2    narfcn=${NRARFCN2036667}
    report B2 to make tuple tobeverified    pci=3    narfcn=${NRARFCN2036667}
    report B2 to make tuple tobeverified    pci=4    narfcn=${NRARFCN2036667}
    report B2 to make tuple tobeverified    pci=5    narfcn=${NRARFCN2036667}

case10_teardown
    Release All UEs
    Delta Commission Parameters    ${Restore_params_for_case10}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

case13_teardown
    Release All UEs
    Delta Commission Parameters    ${Restore_case13change}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

case23_teardown
    Release All UEs
    Delta Commission Parameters    ${restore_case23}
    clean CB005825 verification list
    Common Test Teardown And Stop Capture Logs

Attach UE1 and send B1 MR for 2036667 PCI1
    UE attach to cell1    ue_id=1
    UE report B1NR and check reportCGI meas received    ue_id=1    pci=1

UE report B1NR and check reportCGI meas received
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${cmd}    catenate
    ...    ue_measurement_send id=${ue_id} phycell_id=${pci} nrsrp=98 event=B1_NR
    Run Uex Command    ${cmd}

Attach UE1 and send B1 MR for 2036667 PCI1 Check ReportCGI should trigger
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (cellForWhichToReportCGI-r15 eq 1)) as CGI_RRC
    ...    alias=CGI_RRC    overall_timeout=8
    Expect Message Will Not Occur
    ...    UE_1:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')) as RSC_RRC
    ...    alias=noRSC_RRC    overall_timeout=8
    Attach UE1 and send B1 MR for 2036667 PCI1
    Flow Occurred As Expected    alias=CGI_RRC
    Flow Not Occurred For Message    alias=noRSC_RRC

Attach UE2 and Send B1 MR whose pci not satisfy
    [Arguments]    ${ue_id}=2
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq 1) and (purpose eq 'reportCGI')) as CGI_RRC
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')) as RSC_RRC
    Expect Message Will Not Occur
    ...    ${CGI_RRC}
    ...    alias=noCGI_RRC    overall_timeout=18
    Expect Message Will Not Occur
    ...    ${RSC_RRC}
    ...    alias=noRSC_RRC    overall_timeout=18
    UE attach to cell1    ue_id=2
    ${cmd}    catenate
    ...    ue_measurement_send id=2 phycell_id=6 nrsrp=57 event=B1_NR
    Run Uex Command    ${cmd}
    Flow Not Occurred For Message    alias=noCGI_RRC
    Flow Not Occurred For Message    alias=noRSC_RRC

report B2 to add tuple PCI1-PCI5 to tobeverified list
    [Arguments]    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    report B2 to make tuple tobeverified    ue_id=1    pci=1    narfcn=${NRARFCN2036667}
	
report B2 to make tuple tobeverified
    [Documentation]      new R&D paramter:numConsideredB2PerUe by CB005825-SR-A-UPD005 ,default value 1. UE detach and reattach to make
    ...    nrAnrHoPciCounter updated
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=2036672
    FOR    ${temp}    IN RANGE    1    7
        UE attach to cell1    ue_id=${ue_id}
        Expect message flow
        ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB2-NR-r15 is present))
        ...    alias=B2_RRC_{temp}    overall_timeout=5
        Trigger UE to send A2 measurement with RSRP below threshold2NR    ue_id=${ue_id}
        Flow Occurred As Expected    alias=B2_RRC_{temp}
        Trigger UE to send B2-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
        UE detach    ue_id=${ue_id}
    END

Trigger UE to send A2 measurement with RSRP below threshold2NR
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34    #B2    timeout=5s

Attach UE1 and Send B1 MR whose rsrp not satisfy
    [Arguments]    ${ue_id}=1
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq 1) and (purpose eq 'reportCGI')) as CGI_RRC
    ${RSC_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')) as RSC_RRC
    Expect Message Will Not Occur
    ...    ${CGI_RRC}
    ...    alias=noCGI_RRC    overall_timeout=18
    Expect Message Will Not Occur
    ...    ${RSC_RRC}
    ...    alias=noRSC_RRC    overall_timeout=18
    UE attach to cell1    ue_id=1
    ${cmd}    catenate
    ...    ue_measurement_send id=1 phycell_id=1 nrsrp=55 event=B1_NR
    Run Uex Command    ${cmd}
    Flow Not Occurred For Message    alias=noCGI_RRC
    Flow Not Occurred For Message    alias=noRSC_RRC

Attach UE3 and Send B1 MR Check ReportCGI should trigger
    [Arguments]    ${ue_id}=3
    ${CGI_RRC}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667})
    ...    and (cellForWhichToReportCGI-r15 eq 1) and (purpose eq 'reportCGI')) as CGI_RRC
    Expect message flow
    ...    ${CGI_RRC}
    ...    alias=CGI_RRC    overall_timeout=18
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((carrierFreq-r15 eq ${NRARFCN2036667}) and (purpose eq 'reportStrongestCells')) as RSC_RRC
    ...    alias=noRSC_RRC    overall_timeout=18
    UE attach to cell1    ue_id=3
    ${cmd}    catenate
    ...    ue_measurement_send id=3 phycell_id=1 nrsrp=56 event=B1_NR
    Run Uex Command    ${cmd}
    Flow Not Occurred For Message    alias=noRSC_RRC
    Flow Occurred As Expected    alias=CGI_RRC
