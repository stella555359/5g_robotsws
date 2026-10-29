*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS
...               release-SBTS23R3    team-CN3ET    owner-qi.zheng
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{others}
...    @{LTE4088}
...    @{LTE4193}
...    @{inactive_timer}
...    @{CB006613}
...    @{CB009338}

@{PARAMS_IN_SWCONFIG}
...    ${maxvalure}
...    ${maxsize}
...    ${AnrNrNbrRelRemPeriodicCheckTimer}
...    ${TUecRadDebugLogEnabledGlobal}
...    ${TUecRadDebugLogEnabledUec}
...    ${TUecRadDebugLogEnabledCommon}
...    ${TUecRadDebugLogEnabledCommonCodec}
...    ${ERadCcs_AaSysLogOutputMode}
...    ${ERadCcs_AaSysLogOutputLevel}
...    ${ERadCcs_AaSysLogInputLevel}
${maxvalure}    0x1300DA=10
${maxsize}    0x1300DB=5
${AnrNrNbrRelRemPeriodicCheckTimer}    0x1300E2=1
${TUecRadDebugLogEnabledGlobal}    0x130020=1
${TUecRadDebugLogEnabledUec}    0x130021=1
${TUecRadDebugLogEnabledCommon}    0x13001E=1
${TUecRadDebugLogEnabledCommonCodec}    0x13001F=1
${ERadCcs_AaSysLogOutputMode}    0x10041=5
${ERadCcs_AaSysLogOutputLevel}    0x10040=1
${ERadCcs_AaSysLogInputLevel}    0x1003F=1

@{CB006613}
...    LNBTS:actEndcDropMonitor=true
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:endcNrDropThreshTimer=60s
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:endcNrDropWaitTimer=100
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:endcNrDropThresh=7
@{CB009338}
...    LNBTS:actEndcBlockPerCauseValue=15

@{X2_MOCs}
...    @{LNADJGNB}
...    @{LNRELGNBCELL}

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
@{others}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1800
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19800
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

@{LNADJGNB}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
@{LNRELGNBCELL}
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=115970
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
@{inactive_timer}
...    LNCEL-1:inactivityTimer=1000

@{Case1_config}
...    LNBTS:actEndcBlockPerCauseValue=1

${Case1_restore}
...    LNBTS:actEndcBlockPerCauseValue=15

@{HO_para}
...    LNBTS-1:actHoWoSnChg=intraEnbAndX2HoEnabled
...    LNBTS-1/LNADJ-255:rlfBasedRCRsupported=true
...    LNBTS-1:actSnChangeSnInit=true
...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNBTS-1:actIfHo=enabled              
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw50
...    LNCEL-2/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:ecgiLcrId=3
...    LNCEL-2/LNREL-2:handoverAllowed=allowed
...    LNCEL-2/LNREL-2:removeAllowed=false
...    LNCEL-2/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=1800
...    LNCEL-2/LNHOIF-2:measurementBandwidth=mbw50
...    LNCEL-3/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-3/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-3/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-3/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-2:ecgiLcrId=2
...    LNCEL-3/LNREL-2:handoverAllowed=allowed
...    LNCEL-3/LNREL-2:removeAllowed=false
...    LNCEL-3/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-3/LNHOIF-2:eutraCarrierInfo=1600
...    LNCEL-3/LNHOIF-2:measurementBandwidth=mbw50

@{Case6_restore}
...    delete:LNBTS-1/NRDCPR-0
...    delete:LNBTS-1/NRDCPR-1
...    delete:LNBTS-1/NRDCPR-2

@{Case6_remove_CELL1_ENDCDMEASCONF1}
...    delete:LNBTS-1/NRDCPR-0/ENDCMEASCONF-1

@{Case6_LNRELGNBCELL}
...    LNCEL-1/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-3:nrCellId=115971
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2
...    LNCEL-1/LNRELGNBCELL-4:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-4:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-4:nrCellId=115973
...    LNCEL-1/LNRELGNBCELL-4:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-4:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-4:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115970
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-2:nrCellId=115971
...    LNCEL-2/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-3:nrCellId=115972
...    LNCEL-2/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2
...    LNCEL-3/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-1:nrCellId=115971
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-3/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-2:nrCellId=115972
...    LNCEL-3/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-3/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-3:nrCellId=115973
...    LNCEL-3/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2

@{Case6_config_part1}
...    @{HO_para}
...    @{Case6_LNRELGNBCELL}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-1:dynTriggerLteNrDcConfList:lcrId=2
...    LNBTS/NRDCPR-1:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-2:dynTriggerLteNrDcConfList:lcrId=3
...    LNBTS/NRDCPR-2:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=120kHz
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:nrCarPrio=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:carrierFreqNrCell=${GSCN22325}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbOffset=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbSubcarrierSpacing=120kHz
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:nrCarPrio=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:carrierFreqNrCell=${GSCN7812}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbOffset=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:carrierFreqNrCell=${NRARFCN650000}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:ssbOffset=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-3:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:carrierFreqNrCell=${GSCN22325}
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:ssbSubcarrierSpacing=120kHz
...    LNBTS/NRDCPR-1/ENDCMEASCONF-0:nrCarPrio=8
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:carrierFreqNrCell=${GSCN7812}
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:quantityConfigId=0
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:ssbOffset=1
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-1/ENDCMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:quantityConfigId=0
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:ssbOffset=1
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-1/ENDCMEASCONF-2:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:carrierFreqNrCell=${GSCN7812}
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCPR-2/ENDCMEASCONF-0:nrCarPrio=8
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:quantityConfigId=0
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:ssbOffset=1
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-2/ENDCMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:b1ThresholdNrRsrp=56
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:carrierFreqNrCell=${NRARFCN650000}
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:quantityConfigId=0
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:ssbOffset=1
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-2/ENDCMEASCONF-2:ssbSubcarrierSpacing=30kHz

@{Case6_config_part2}
...    LNBTS/NRDCPR-0/ENDCMEASCONF:endcNrDropThreshTimer=60s
...    LNBTS/NRDCPR-0/ENDCMEASCONF:endcNrDropWaitTimer=100
...    LNBTS/NRDCPR-0/ENDCMEASCONF:endcNrDropThresh=7
...    LNBTS/NRDCPR-1/ENDCMEASCONF:endcNrDropThreshTimer=60s
...    LNBTS/NRDCPR-1/ENDCMEASCONF:endcNrDropWaitTimer=100
...    LNBTS/NRDCPR-1/ENDCMEASCONF:endcNrDropThresh=7
...    LNBTS/NRDCPR-2/ENDCMEASCONF:endcNrDropThreshTimer=60s
...    LNBTS/NRDCPR-2/ENDCMEASCONF:endcNrDropWaitTimer=100
...    LNBTS/NRDCPR-2/ENDCMEASCONF:endcNrDropThresh=7

@{Case7_config}
...    LNBTS:actSnChangeSnInit=true
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL-1/LNRELGNBCELL-5:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-5:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-5:nrCellId=132358
...    LNCEL-1/LNRELGNBCELL-5:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-5:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-5:nrCgiPlmnId:mncLength=2

@{pm_counters_IUEC1_NSQV0_TNA0_NRRA0_RMNS0}
...    ${SGNB_ADD_PREP_REJECT_IUEC}=1
...    ${SGNB_ADD_PREP_REJECT_NSQV}=0
...    ${SGNB_ADD_PREP_REJECT_TNA}=0
...    ${SGNB_ADD_PREP_REJECT_NRRA}=0
...    ${SGNB_ADD_PREP_REJECT_RMNS}=0

@{pm_counters_IUEC0_NSQV1_TNA0_NRRA0_RMNS0}
...    ${SGNB_ADD_PREP_REJECT_IUEC}=0
...    ${SGNB_ADD_PREP_REJECT_NSQV}=1
...    ${SGNB_ADD_PREP_REJECT_TNA}=0
...    ${SGNB_ADD_PREP_REJECT_NRRA}=0
...    ${SGNB_ADD_PREP_REJECT_RMNS}=0

@{pm_counters_IUEC1_NSQV1_TNA1_NRRA1_RMNS0}
...    ${SGNB_ADD_PREP_REJECT_IUEC}=1
...    ${SGNB_ADD_PREP_REJECT_NSQV}=1
...    ${SGNB_ADD_PREP_REJECT_TNA}=1
...    ${SGNB_ADD_PREP_REJECT_NRRA}=1
...    ${SGNB_ADD_PREP_REJECT_RMNS}=0

@{pm_counters_NRRA1_cell3}
...    ${SGNB_ADD_PREP_REJECT_NRRA}=0
...    ${SGNB_ADD_PREP_REJECT_NRRA_CELL2}=0
...    ${SGNB_ADD_PREP_REJECT_NRRA_CELL3}=1

${SGNB_ADD_PREP_REJECT_IUEC}    LNCEL-1:M8080C158
${SGNB_ADD_PREP_REJECT_NSQV}    LNCEL-1:M8080C159
${SGNB_ADD_PREP_REJECT_TNA}    LNCEL-1:M8080C160
${SGNB_ADD_PREP_REJECT_NRRA}    LNCEL-1:M8080C161
${SGNB_ADD_PREP_REJECT_RMNS}    LNCEL-1:M8080C162
${SGNB_ADD_PREP_REJECT_NRRA_CELL2}    LNCEL-2:M8080C161
${SGNB_ADD_PREP_REJECT_NRRA_CELL3}    LNCEL-3:M8080C161


@{X2shouldup}
...    LNBTS-1/LNADJGNB-1:x2ToGnbLinkStatus=available
@{PARAMS_IN_EMIL}
...    0x400e
...    0x7509
...    0x75ce

${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C1082080304218018018200C100608
...    430030022104002D1F5518502038410041460821610401051820A30410B082008284105182083841004142082061040105902E0B82E0B82E0B82E0B82E0B82E0B82E0
...    B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C
...    3C3C3C3C3887878787000045F830000081010440668003E71E00020406080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C06000024040
...    61304D0A1E01BFE0000050000003080044000A103FC0113501

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
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '${GSCN22325}:${GSCN22325}', 
...    meas_timing_carrier_freq: ${GSCN22325}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell3}    SEPARATOR=
...    {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x503', nr_arfcn: '${GSCN7812}:${GSCN7812}', 
...    meas_timing_carrier_freq: ${GSCN7812}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell4}    SEPARATOR=
...    {id: 74, technology: nr , tac: 33, pci: '1:1', nrci: '0x504', nr_arfcn: '${NRARFCN630000}:${NRARFCN630000}', 
...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell5}    SEPARATOR=
...    {id: 75, technology: nr , tac: 33, pci: '1:2', nrci: '0x505', nr_arfcn: '${NRARFCN650000}:${NRARFCN650000}', 
...    meas_timing_carrier_freq: ${NRARFCN650000}, ssb_subcarrier_spacing: kHz30, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb8_cell1}    SEPARATOR=
...    {id: 81, technology: nr , tac: 33, pci: '6:0', nrci: '0x506', nr_arfcn: '${GSCN22325}:${GSCN22325}', 
...    meas_timing_carrier_freq: ${GSCN22325}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

*** Test Cases ***
CB009338-SR-A-B1_ET_01_01_freq_is_blocked_after_ENDC_setup_rejected
    [Documentation]
    ...     == Precondition: ==
    ...     actEndcBlockPerCauseValue=1
    ...
    ...     == Requirement: ==
    ...     ENB shall block B1NR for the frequency contained in SgNBAdditionRequest
    ...     only when rejected with reason defined in actEndcBlockPerCauseValue
    [Tags]
    Delta Commission Parameters    ${Case1_config}
    Attach UE1 and check B1 blocked by reason RN_insufficient_ue_capabilities
    Make UE1 report B1NR for unblocked freq and ENDC established
    Attach UE2 and check B1 not blocked by reason RN_not_supported_QCI_value
    [Teardown]    case1_teardown

CB009338-SR-A-B1_ET_06_01_freq_is_still_blocked_after_ENDC_setup_rejected_then_intra_Enb_ho_cross_with_reestablish
    [Documentation]
    ...     == Precondition: ==
    ...     == actEndcBlockPerCauseValue=15
    ...     == For simplification, each NR frequency matched one letter as below:
    ...     == A:2036672:measobj id=3==2
    ...     == B:2036539:measobj id=4==3
    ...     == C:630048:measobj id=5==4
    ...     == D:629984:measobj id=9
    ...     == E:650048:measobj id=6==5
    ...     == CELL1 configured to be install B1NR for freq A, B, C, E
    ...     == CELL2 configured to be install B1NR for freq B, C, D
    ...     == CELL3 configured to be install B1NR for freq C, D, E
    ...
    ...     == Requirement: ==
    ...     intra-enb handover or intra-enb reestablishment shall keep blocking the B1NR frequencies
    ...     if blocked for CB009338 reasons.
    [Tags]
    [Setup]    case6_setup
    Attach UE1 and check freq ABCE B1 blocked by all four reasons
    Clear Counter files    ${False}
    Remove freq B B1 related config for CELL1
    Make UE ho to cell2 and check freq BD B1 configured
    Make UE ho to cell3 and check freq DE B1 configured
    Make UE report freq E B1 and check it blocked by reason RN_no_radio_resources_available
    Make UE ho to cell2 and check freq BD B1 configured
    Make UE reestablish to cell1 and check freq AE configured
    Check Counters    ${pm_counters_NRRA1_cell3}
    [Teardown]    case6_teardown

CB009338-SR-A-B1_ET_07_01_reason_Insufficient_UE_Capabilities_kept_in_sgnb_change_refuse_message
    [Documentation]
    ...     == Precondition: ==
    ...     == actEndcBlockPerCauseValue=15
    ...     CELL1 configured to be able to install B1NR for GNB7 CELL1, CELL2, GNB8 CELL1
    ...
    ...     == Requirement: ==
    ...     newly introduces cause values are forwarded in SgNB Change Refuse
    [Tags]
    Delta Commission Parameters    ${Case7_config}
    Clear Counter files
    Attach UE1 and establish ENDC with GNB8
    Make SGNB change to GNB7 fail
    Make UE release ENDC then establish ENDC successfully
    Check Counters    ${pm_counters_IUEC1_NSQV0_TNA0_NRRA0_RMNS0}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Create enb alias    alias=gNB8    enb_id=8    id_type=wts
    Set UE parameters for ENDC capability
    Perform Steps After Onair

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Uex Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=2 nr_supported_bands=78,258
    Execute Egate Command    ue_enb_param id=1,2 spid=34
    Config gnb

Config gnb
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=4:1
    Execute Egate Command    gnb_endc_param id=8 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=8 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=8 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=8 selected_band_combination_nr=4:1

Perform Steps After Onair
    Configure LNADJGNB and LNRELGNBCELL
    X2 link should be available

Configure LNADJGNB and LNRELGNBCELL
    Delta Commission Parameters    ${X2_MOCs}

X2 link should be available
    @{lnadj}    Create List    LNADJ:cPlaneIpAddr=10.0.1.3    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj}
    Object Should Exist    params=${X2shouldup}    timeout=300

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
    ...        - {id: 21, technology: lte, tac: 33, pci: '9:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '9:1', earfcn: '5920:23920', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '9:2', earfcn: '8770:26770', bw: 20}
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
    [Arguments]    ${ue_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    ${ret1}=    Execute Uex Command    ${V_1}

UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

Set sgnb addition request reject
    [Documentation]    Possible reasons are:
    ...    RN_insufficient_ue_capabilities
    ...    RN_not_supported_QCI_value
    ...    RN_target_not_allowed
    ...    RN_no_radio_resources_available
    ...    RN_tDCprep_expiry
    [Arguments]    ${gnb_id}=7    ${reason}=RN_insufficient_ue_capabilities
    ${cmd}    catenate
    ...    link_x2_management_abnormal_cases id=${gnb_id} partner=1 sgnb_addition_rsp=reject 
    ...    sgnb_addition_failure_cause=${reason}
    Execute Egate Command    ${cmd}

Reset sgnb addition request reject
    [Arguments]    ${gnb_id}=7
    ${cmd}    catenate
    ...    link_x2_management_abnormal_cases id=${gnb_id} partner=1 reset
    Execute Egate Command    ${cmd}

UE report B1NR to setup ENDC
    [Arguments]    ${ue_id}=1    ${meas_id_blacklist}=18    ${pci}=1
    Execute Uex Command    ue_measurement_send id=${ue_id} meas_id_blacklist=${meas_id_blacklist} srsrp=79 phycell_id=${pci} nrsrp=58 event=B1_NR
    sleep    1    #wait ENDC establish finish

Make UE reestablish to enb1 cell1
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} cell=1 enb=1 cause=otherFailure

Make SGNB change to GNB7
    Execute Egate Command    gnb_ue_dc_change ue=1 gnb=7 target_sgnb_cells=71 cause=RN_sCG_Mobility    SgNBChangeRefuse

Make UE ho to enb1 cell2
    Execute Uex Command    ue_ho id=1 cell=2 enb=1

Make UE ho to enb1 cell3
    Execute Uex Command    ue_ho id=1 cell=3 enb=1

Make UE ENDC release
    Execute Egate Command    enb_dc_ue_release by=gnb bearer=1 cause=RN_user_inactivity ue=1    UEContextRelease 

case1_teardown
    Delta Commission Parameters    ${Case1_restore}
    Common Test Teardown And Stop Capture Logs

case6_setup
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${Case6_config_part1}
    Delta Commission Parameters    ${Case6_config_part2}

case6_teardown
    UE detach    ue_id=1
    Delta Commission Parameters    ${Case6_restore}
    Common Test Teardown And Stop Capture Logs

Attach UE1 and check B1 blocked by reason RN_insufficient_ue_capabilities
    Set sgnb addition request reject    reason=RN_insufficient_ue_capabilities
    Clear Counter files
    UE attach to cell1
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17))
    ...    alias=RRC    overall_timeout=5
    UE report B1NR to setup ENDC    meas_id_blacklist=18    pci=1
    Flow Occurred As Expected    alias=RRC
    Check Counters    ${pm_counters_IUEC1_NSQV0_TNA0_NRRA0_RMNS0}

Make UE1 report B1NR for unblocked freq and ENDC established
    Reset sgnb addition request reject
    Expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (18))
    ...    alias=ENDC    overall_timeout=5
    UE report B1NR to setup ENDC    meas_id_blacklist=17    pci=2
    Flow Occurred As Expected    alias=ENDC

Attach UE2 and check B1 not blocked by reason RN_not_supported_QCI_value
    Clear Counter files    ${False}
    Set sgnb addition request reject    reason=RN_not_supported_QCI_value
    UE attach to cell1    ue_id=2
    Expect Message Will Not Occur
    ...    UE_2:RRC_RRCConnectionReconfiguration
    ...    alias=RRC    overall_timeout=5
    UE report B1NR to setup ENDC    ue_id=2    meas_id_blacklist=18    pci=1
    Flow Not Occurred For Message    alias=RRC
    Check Counters    ${pm_counters_IUEC0_NSQV1_TNA0_NRRA0_RMNS0}

Attach UE1 and check freq ABCE B1 blocked by all four reasons
    Clear Counter files
    UE attach to cell1
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17))
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (18))
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (19))
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (20))
    ...    alias=RRC    overall_timeout=30
    Make UE report B1NR for four frequencies and establish ENDC fail
    Flow Occurred As Expected    alias=RRC
    Check Counters    ${pm_counters_IUEC1_NSQV1_TNA1_NRRA1_RMNS0}

Make UE report B1NR for four frequencies and establish ENDC fail
    Set sgnb addition request reject    gnb_id=7    reason=RN_insufficient_ue_capabilities
    UE report B1NR to setup ENDC    meas_id_blacklist=18,19,20,21    pci=1
    Set sgnb addition request reject    gnb_id=7    reason=RN_not_supported_QCI_value
    UE report B1NR to setup ENDC    meas_id_blacklist=17,19,20,21    pci=2
    Set sgnb addition request reject    gnb_id=7    reason=RN_target_not_allowed
    UE report B1NR to setup ENDC    meas_id_blacklist=17,18,20,21    pci=3
    Set sgnb addition request reject    gnb_id=7    reason=RN_no_radio_resources_available
    UE report B1NR to setup ENDC    meas_id_blacklist=17,18,19,21    pci=5
    

Remove freq B B1 related config for CELL1
    Delta Commission Parameters    ${Case6_remove_CELL1_ENDCDMEASCONF1}

Make UE ho to cell2 and check freq BD B1 configured
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measObjectId eq 3, measObjectId eq 9))
    ...    alias=RRC    overall_timeout=5
    Expect Message Will Not Occur
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measObjectId eq 4))
    ...    alias=NO_MEAS_OBJID_4    overall_timeout=5
    Make UE ho to enb1 cell2
    Flow Occurred As Expected    alias=RRC
    Flow Not Occurred For Message    alias=NO_MEAS_OBJID_4

Make UE ho to cell3 and check freq DE B1 configured
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measObjectId eq 9, measObjectId eq 5))
    ...    alias=RRC    overall_timeout=5
    Expect Message Will Not Occur
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measObjectId eq 4))
    ...    alias=NO_MEAS_OBJID_4    overall_timeout=5
    Make UE ho to enb1 cell3
    Flow Occurred As Expected    alias=RRC
    Flow Not Occurred For Message    alias=NO_MEAS_OBJID_4

Make UE report freq E B1 and check it blocked by reason RN_no_radio_resources_available
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (18))
    ...    alias=RRC    overall_timeout=5
    UE report B1NR to setup ENDC    meas_id_blacklist=17,19    pci=5
    Flow Occurred As Expected    alias=RRC

Make UE reestablish to cell1 and check freq AE configured
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measObjectId eq 2, measObjectId eq 5))
    ...    alias=RRC    overall_timeout=5
    Expect Message Will Not Occur
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measObjectId eq 4))
    ...    alias=NO_MEAS_OBJID_4    overall_timeout=5
    Make UE reestablish to enb1 cell1
    Flow Occurred As Expected    alias=RRC
    Flow Not Occurred For Message    alias=NO_MEAS_OBJID_4

Attach UE1 and establish ENDC with GNB8
    Reset sgnb addition request reject    gnb_id=8
    UE attach to cell1
    Expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (18))
    ...    alias=ENDC    overall_timeout=5
    UE report B1NR to setup ENDC    meas_id_blacklist=17    pci=18
    Flow Occurred As Expected    alias=ENDC

Make SGNB change to GNB7 fail
    [Documentation]
    ...    SgNBChangeRefuse radioNetwork: insufficient-ue-capabilities (53)
    sleep    2    #wait UE1 ENDC establish complete
    Set sgnb addition request reject    gnb_id=7    reason=RN_insufficient_ue_capabilities
    Expect message flow
    ...    ENB_1:X2AP_SgNBChangeRefuse (Cause contains (radioNetwork eq "insufficient-ue-capabilities"))
    ...    alias=SGNB_CHANGE_REFUSE    overall_timeout=5
    Make SGNB change to GNB7
    Flow Occurred As Expected    alias=SGNB_CHANGE_REFUSE

Make UE release ENDC then establish ENDC successfully
    Make UE ENDC release
    Reset sgnb addition request reject    gnb_id=7
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17))
    ...    alias=ENDC    overall_timeout=5
    UE report B1NR to setup ENDC    meas_id_blacklist=18    pci=1
    Flow Occurred As Expected    alias=ENDC