*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS
...               release-SBTS24R2    team-CN3ET    owner-qi.zheng
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{LTE5382}
...    @{CB010763}

@{CB010763}
...    LNCEL/CATMCEL-0:actHighHarqInSlimCarrierCatM=true
...    LNCEL/CATMCEL-0:actMultiHarqCatM=true
...    LNCEL/CATMCEL-0:dlsUsePartPrbCatM=sf0 and sf5 used as invalid subframe
...    LNCEL:nbIoTMode=disabled
...    LNCEL/SIB-0:sib2xTransmit=false
...    delete:LNCEL-1/LNHOX-1
...    LNCEL:maxCrSibDl=26
...    delete:LNCEL/CDFIM-1:csfbRegParam1xRtt

@{HighHARQ_HARQBundling}
...    LNCEL/CATMCEL-0:actHighHarqCatM=8 HARQ
...    LNCEL/CATMCEL-0:actHARQBundlingCatM=true
...    LNCEL/CATMCEL-0:harqThrForBundlingCatM=8
...    LNCEL/CATMCEL-0:dlLADownFactorCatM=1
...    LNCEL/CATMCEL-0:dlMcsThrForBundlingCatM=MCS13

@{HighHARQ_disable}
...    LNCEL/CATMCEL-0:actHighHarqCatM=disabled
...    LNCEL/CATMCEL-0:actHARQBundlingCatM=false

@{HO_param}
...    LNBTS/CATMPR-1:inactivityTimerCatM=30
...    LNCEL/CATMCEL-0:actIntraFreqHoCatM=true
...    LNBTS/CATMODPR-0:freqLayListCatM=1400
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:handoverAllowed=allowed

...    LNCEL-2/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-1:handoverAllowed=allowed

...    LNCEL-2/LNREL-3:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-3:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-3:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-3:ecgiLcrId=3
...    LNCEL-2/LNREL-3:handoverAllowed=allowed

...    LNCEL-3/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-3/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-3/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-3/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-2:ecgiLcrId=2
...    LNCEL-3/LNREL-2:handoverAllowed=allowed

@{Enable_reestablish}
...    LNBTS:actRLFbasedRCR=true
...    LNCEL/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL:t301Guard=1990
...    LNBTS:actRLFbasedRCRConfigL1=true
...    LNBTS:actRLFbasedRCREnhanced=true
...    LNBTS:actRLFbasedRCREnhancedIntra=true
...    LNBTS:actRLFbasedRCRTargetCRNTI=true
...    LNBTS:rlfBasedRCRdefault=true

@{LTE907_TTIbundling}
...    LNBTS:qciTab1:enforceTtiBundling=true
...    LNCEL:ttibOperMode=blerBasedNotWithMeasGap
...    LNCEL:actTtiBundling=true
...    LNCEL:a2TimeToTriggerActWcdmaMeas=320ms
...    LNCEL:actUlLnkAdp=eUlLa
...    LNCEL:actUlpcMethod=PuschOLPucchOL
...    LNCEL:dlTargetBler=8
...    LNCEL:eUlLaDeltaMcs=3
...    LNCEL:eUlLaLowMcsThr=1
...    LNCEL:eUlLaLowPrbThr=1
...    LNCEL:harqMaxMsg3=5
...    LNCEL:harqMaxTrDl=5
...    LNCEL:harqMaxTrUlTtiBundling=12
...    LNCEL:harqMaxTrVoLteDl=8
...    LNCEL:inactivityTimer=3600
...    LNCEL:inactivityTimerPubSafety=6000
...    LNCEL:iniMcsDl=4
...    LNCEL:iniMcsUl=4
...    LNCEL:iniPrbsUl=10
...    LNCEL:ttiBundlingBlerTarget=12
...    LNCEL:ttiBundlingBlerThreshold=11
...    LNCEL:ttiBundlingSinrThreshold=12
...    LNCEL:ttibMinDelayAfterBearerSetup=0
...    LNCEL:ttibMinUlPrb=2
...    LNCEL:ttibSinrDwellTimeIn=200
...    LNCEL:ttibSinrDwellTimeOut=200
...    LNCEL:ttibSinrThresholdIn=10
...    LNCEL:ttibSinrThresholdOut=16
...    LNCEL:ttibUlsMinTbs=144
...    LNCEL:ulTargetBler=10
...    LNCEL:ulsFdPrbAssignAlg=MixedFD
...    LNCEL:actTtibAcqi=false
...    LNCEL:actTtibRsc=true
...    LNBTS:actIfHo=disabled
...    delete:LNCEL:a2TimeToTriggerActInterFreqMeas
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actMultBearers=true

@{PARAMS_IN_SWCONFIG}
...    ${L2flag}
...    ${TAbsMaxCrLimit}

${L2flag}    0x1E0149=0xC0A00000
${TAbsMaxCrLimit}    0xF0071=17

@{PARAMS_IN_EMIL}
...    0x2381
...    0x2382
...    0x74EB
...    0x74F2
...    0x74F3
...    0x74F4
...    0x2495
...    0x7560
...    0x7561
...    0x7562
...    0x7563
...    0x759C
...    0x759D
...    0x75DC
...    0x75DD
...    0x75DE
...    0x75DF
...    0x75E7
...    0x75E8
...    0x7539
...    0x753A
...    -n mac -e 0x4EE5 -e 0x26AE -e 0x26C6 -e 0x26A2 -e 0x26C2 -e 0x2695 -e 0x269D -e 0x269B

# 0x26AE    PS_RB_ADD_REQ_MSG
# 0x26C6    PS_USER_MODIFY_REQ_MSG
# 0x26A2    PS_HO_UE_ADD_REQ_MSG
# 0x26C2    PS_UE_RECONFIG_REQ_MSG
# 0x2695    PS_BEARER_MODIFY_REQ_MSG

@{LTE5382}
...    LNBTS:integrityPrefL:eia1=0
...    LNBTS:integrityPrefL:eia0=1
...    LNBTS:integrityPrefL:eia3=0
...    LNBTS:integrityPrefL:eia2=0
...    LNBTS:cipherPrefL:eea1=0
...    LNBTS:cipherPrefL:eea0=1
...    LNBTS:cipherPrefL:eea3=0
...    LNBTS:cipherPrefL:eea2=0
...    CATMPR-1:mibRepEnabledCatM=false
...    LNCEL:pdcchAggSib=8
...    LNCEL:actLdPdcch=true
...    LNCEL:adaptPdcchDwellTime=50
...    LNCEL:dlsDciCch=DCI format 1A
...    LNCEL:raPreGrASize=40
...    LNCEL:redBwRbUlConfig:redBwMaxRbUl=25
...    LNCEL:redBwRbUlConfig:redBwMinRbUl=1
...    LNCEL:raSmallMcsUl=2
...    LNCEL/CATMCEL-0:actAmcCatM=Both Downlink and Uplink enabled
...    LNCEL/CATMCEL-0:actDynamicRepMpdcchCatM=true
...    LNCEL/CATMCEL-0:actDynamicRepMpdschCatM=true
...    LNCEL/CATMCEL-0:actDynamicRepMpuschCatM=true
...    LNCEL/CATMCEL-0:actDynamicRepVoLTECatM=true
...    LNCEL/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    delete:LNBTS/LNCEL/CATMCEL-0:threshServingLowQR9CatM
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:actDlSlimCarrier=true
...    LNCEL/LNCEL_FDD-0:actSlimCoexCatM=true
...    LNCEL/LNCEL_FDD-0:blankedPucch=4
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL/LNCEL_FDD-0:numBlankDlPrbsDown=2
...    LNCEL/LNCEL_FDD-0:numBlankDlPrbsUp=2
...    LNCEL/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=2
...    LNCEL:maxPdcchAgg=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL/SIB-0:siWindowLen=20ms
...    delete:LNCEL/SIB-0:threshServingLowQR9
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=5 MHz
...    delete:LNCEL/CAREL-1
...    delete:LNCEL/MBSFNCEL-0

@{SIB24}
...    LNBTS:actSIB24=true
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB24
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB24
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=true|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=78|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=0|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=0|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=0|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=5sf|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=111111
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=true|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=78|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=5sf|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=222222
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=true|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=78|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=5sf|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=333333
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=true|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=78|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=5sf|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=444444
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=true|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=78|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=5sf|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=555555
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=true|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=78|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=5sf|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=666666
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=true|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=78|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=5sf|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=777777
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=true|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=78|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=5sf|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=888888
...    LNCEL-1/NRFIM-1:tResNrSF:nrResTiFHM=1
...    LNCEL-1/NRFIM-1:tResNrSF:nrResTiFMM=1
...    LNCEL-1/NRFIM-1:tResNr=1

@{SIB11}
...    LNBTS:actETWS=true
...    LNBTS:pwsWithEmAreaId=true
...    LNCEL-1:emAreaIdList=1,6,7
...    LNCEL-2:emAreaIdList=2,3,7
...    LNCEL-3:emAreaIdList=4,7
...    LNBTS:actCMAS=false
...    LNBTS:actSIB24=false
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB10
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB10
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB11
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB11
...    LNCEL-2/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB10
...    LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB10
...    LNCEL-2/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB11
...    LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB11
...    LNCEL-3/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB10
...    LNCEL-3/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB10
...    LNCEL-3/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB11
...    LNCEL-3/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB11

@{SIB12}
...    LNBTS:actCMAS=true
...    LNBTS:actCmasTransOptimization=false
...    LNBTS:actETWS=false
...    LNBTS:warnAreaCoAllowed=true
...    LNBTS:pwsWithEmAreaId=true
...    LNCEL-1:emAreaIdList=1,6,7
...    LNCEL-2:emAreaIdList=2,3,7
...    LNCEL-3:emAreaIdList=4,7
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB12
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB12
...    LNCEL-2/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB12
...    LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB12
...    LNCEL-3/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB12
...    LNCEL-3/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB12

@{SIB5}
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB5
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...    LNCEL-1/CATMCEL-0:actEabCatM=None
...    delete:LNCEL-1/IRFIM-1:intFrBCList
...    delete:LNCEL-1/IRFIM-1:intFrNCList
...    LNCEL-1/IRFIM-2:dlCarFrqEut=22000
...    LNCEL-1/IRFIM-2:enableA4IMLB=enabled
...    LNCEL-1/IRFIM-2:eutCelResPrio=5
...    LNCEL-1/IRFIM-2:idleLBEutCelResWeight=100
...    LNCEL-1/IRFIM-2:incMonExSel=R8ListPartPreferred
...    LNCEL-1/IRFIM-2:interFrqThrH=34
...    LNCEL-1/IRFIM-2:interFrqThrL=2
...    LNCEL-1/IRFIM-2:interPresAntP=true
...    LNCEL-1/IRFIM-2:interTResEut=4
...    LNCEL-1/IRFIM-2:mbmsNeighCellConfigInterF=00
...    LNCEL-1/IRFIM-2:measBdw=50mbw
...    LNCEL-1/IRFIM-2:minDeltaRsrpIMLB=0
...    LNCEL-1/IRFIM-2:minDeltaRsrqIMLB=0
...    LNCEL-1/IRFIM-2:minRsrpIMLB=-120
...    LNCEL-1/IRFIM-2:minRsrqIMLB=-120
...    LNCEL-1/IRFIM-2:pMaxInterF=10
...    LNCEL-1/IRFIM-2:qOffFrq=1 dB
...    LNCEL-1/IRFIM-2:qRxLevMinInterF=-68
...    LNCEL-1/IRFIM-2:reducedMeasPerformance=false
...    LNCEL-1/IRFIM-2:intFrBCList:rangeInterPci=n4|startInterPci=20
...    LNCEL-1/IRFIM-2:intFrBCList:rangeInterPci=n8|startInterPci=30
...    LNCEL-1/IRFIM-2:intFrBCList:rangeInterPci=n4|startInterPci=60
...    LNCEL-1/IRFIM-2:intFrNCList:qOffCell=-16 dB|physCellIdNcl=43
...    LNCEL-1/IRFIM-2:intFrNCList:qOffCell=-18 dB|physCellIdNcl=56
...    LNCEL-1/IRFIM-2:interFrqQThrR9:interFrqQThrHighR9=0
...    LNCEL-1/IRFIM-2:interFrqQThrR9:interFrqQThrLowR9=0
...    LNCEL-1/IRFIM-2:tResEutSF:eutResTiFHM=0.5
...    LNCEL-1/IRFIM-2:tResEutSF:eutResTiFMM=0.75
...    LNCEL-1/IRFIM-3:dlCarFrqEut=23000
...    LNCEL-1/IRFIM-3:enableA4IMLB=enabled
...    LNCEL-1/IRFIM-3:eutCelResPrio=5
...    LNCEL-1/IRFIM-3:idleLBEutCelResWeight=100
...    LNCEL-1/IRFIM-3:incMonExSel=R8ListPartPreferred
...    LNCEL-1/IRFIM-3:interFrqThrH=34
...    LNCEL-1/IRFIM-3:interFrqThrL=2
...    LNCEL-1/IRFIM-3:interPresAntP=true
...    LNCEL-1/IRFIM-3:interTResEut=4
...    LNCEL-1/IRFIM-3:mbmsNeighCellConfigInterF=00
...    LNCEL-1/IRFIM-3:measBdw=50mbw
...    LNCEL-1/IRFIM-3:minDeltaRsrpIMLB=0
...    LNCEL-1/IRFIM-3:minDeltaRsrqIMLB=0
...    LNCEL-1/IRFIM-3:minRsrpIMLB=-120
...    LNCEL-1/IRFIM-3:minRsrqIMLB=-120
...    LNCEL-1/IRFIM-3:pMaxInterF=10
...    LNCEL-1/IRFIM-3:qOffFrq=1 dB
...    LNCEL-1/IRFIM-3:qRxLevMinInterF=-68
...    LNCEL-1/IRFIM-3:reducedMeasPerformance=false
...    LNCEL-1/IRFIM-3:intFrBCList:rangeInterPci=n4|startInterPci=70
...    LNCEL-1/IRFIM-3:intFrBCList:rangeInterPci=n8|startInterPci=80
...    LNCEL-1/IRFIM-3:intFrBCList:rangeInterPci=n4|startInterPci=90
...    LNCEL-1/IRFIM-3:intFrNCList:qOffCell=-16 dB|physCellIdNcl=44
...    LNCEL-1/IRFIM-3:intFrNCList:qOffCell=-18 dB|physCellIdNcl=57
...    LNCEL-1/IRFIM-3:interFrqQThrR9:interFrqQThrHighR9=0
...    LNCEL-1/IRFIM-3:interFrqQThrR9:interFrqQThrLowR9=0
...    LNCEL-1/IRFIM-3:tResEutSF:eutResTiFHM=0.5
...    LNCEL-1/IRFIM-3:tResEutSF:eutResTiFMM=0.75
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio2CC
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio3CC
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio4CC
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio5CC

@{SIB5_single_IRFIM}
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB5
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...    LNCEL-1/CATMCEL-0:actEabCatM=None
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=1
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=5
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=9
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=13
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=17
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=21
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=25
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=29
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=33
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=37
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=41
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=45
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=49
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=53
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=57
...    LNCEL-1/IRFIM-1:intFrBCList:rangeInterPci=n4|startInterPci=61
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-16 dB|physCellIdNcl=100
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-18 dB|physCellIdNcl=101
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-18 dB|physCellIdNcl=102
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-18 dB|physCellIdNcl=103
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-18 dB|physCellIdNcl=104
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-18 dB|physCellIdNcl=105
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-18 dB|physCellIdNcl=106
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-18 dB|physCellIdNcl=107
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-18 dB|physCellIdNcl=108
...    LNCEL-1/IRFIM-1:intFrNCList:qOffCell=-18 dB|physCellIdNcl=109
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio2CC
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio3CC
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio4CC
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResPrio5CC
...    delete:LNCEL-1/IRFIM-2
...    delete:LNCEL-1/IRFIM-3
...    delete:LNCEL-1/IRFIM-4

@{A_case4_config1}
...    @{SIB5_single_IRFIM}
...    @{SIB24}
...    LNBTS:actCMAS=false
...    LNBTS:actETWS=false

@{A_case4_config2}
...    @{SIB5}
...    LNBTS:actSIB24=false
...    delete:LNCEL/CDFIM-1

@{A_case7_config1}
...    LNCEL-1/CATMCEL-0:actSf9InvalidLVRBCatM=true
...    LNCEL-2/CATMCEL-0:actSf9InvalidLVRBCatM=false
...    LNCEL:maxCrPgDl=5

@{A_case7_config2}
...    LNCEL:maxCrPgDl=12

@{A_case7_config3}
...    LNCEL:maxCrPgDl=26

@{A_case7_config4}
...    LNCEL:maxCrPgDl=50

@{B_B5_case1_config}
...    @{HighHARQ_HARQBundling}
...    @{HO_param}
...    @{Enable_reestablish}
...    @{LTE907_TTIbundling}

${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080


*** Test Cases ***
CB010763-SR-A-B1_ET_04_01_SIB5_SIB24_shall_not_exceed_maxPDUSizeSIB
    [Documentation]
    ...     == Requirement: ==
    ...     RM_LTE_SFS_RRM.17706
    ...     SIBs message size restriction shall be adopted from the 1.4 MHz cell.
    ...
    ...     == Precondition: ==
    ...     code rate TAbsMaxCrLimit=${TAbsMaxCrLimit}
    ...     maxPDUSizeSIB5=48.595bytes
    ...     maxPDUSizeSIB24=48.595bytes
    ...
    ...     == Test steps: ==
    ...     step1. with variable SIB5_single_IRFIM config, single IRRFIM size exceeds maxPDUSizeSIB5
    ...            so enb shall not broadcast SIB5
    ...            with variable SIB24 config, enb shall broadcast SIB24 with only one nrCarFrq.
    ...     step2. with variable SIB5 config, enb shall broadcast SIB5 with only IRFIM-1, IRFIM-2.
    [Tags]
    Delta Commission Parameters    ${A_case4_config1}
    Check SIB5 not broadcast and SIB24 contains only one dlCarFrqNr
    Delta Commission Parameters    ${A_case4_config2}
    Check SIB5 braodcasted

CB010763-SR-A-B1_ET_06_01_SBI11_SIB12_shall_broadcast_normally
    [Documentation]
    ...     == Requirement: ==
    ...     TF_LTE_SFS_SYS_3065    SIB11-Warning Message Contents Size.
    ...     TF_LTE_SFS_SYS_3066    SIB12-Warning Message Contents Size.
    [Tags]
    Delta Commission Parameters    ${SIB11}
    MME trigger ETWS notification and check content correct
    Delta Commission Parameters    ${SIB12}
    MME trigger CMAS notification and check content correct

CB010763-SR-A-B1_ET_07_01_Paging_record_restriction
    [Documentation]
    ...     == Requirement: ==
    ...     TF_LTE_SFS_UESTATE.3487
    ...     Limited Paging Record List in WB LTE 5MHz Bandwidth cell when CAT-M1 is supported
    ...
    ...     For actSf9InvalidLVRBCatM=true,
    ...     | Paging Code Rate | MAX_PAGE_REC |
    ...     |          5       |      2       |
    ...     |          6       |      3       |
    ...     |          7       |      4       |
    ...     |          8       |      5       |
    ...     |         9-11     |      6       |
    ...     |          12      |      8       |
    ...     |        13-14     |      9       |
    ...     |          15      |      10      |
    ...     |          16      |      11      |
    ...     |          17      |      12      |
    ...     |        18-19     |      13      |
    ...     |        20-21     |      15      |
    ...     |        22-50     |      16      |
    ...
    ...     For actSf9InvalidLVRBCatM=false,
    ...     | Paging Code Rate | MAX_PAGE_REC |
    ...     |          5       |      1       |
    ...     |          6       |      2       |
    ...     |         7-8      |      3       |
    ...     |        9-10      |      4       |
    ...     |        11-12     |      5       |
    ...     |        13-15     |      6       |
    ...     |        16-17     |      8       |
    ...     |        18-19     |      9      |
    ...     |        20-21     |      10      |
    ...     |        22-23     |      12      |
    ...     |        24-26     |      13      |
    ...     |        27-29     |      15      |
    ...     |        30-50     |      16      |
    [Tags]
    Delta Commission Parameters    ${A_case7_config1}
    Start paging and check max record as expected    cell1_max_record=2    cell2_max_record=1    alias=config1
    Delta Commission Parameters    ${A_case7_config2}
    Start paging and check max record as expected    cell1_max_record=8    cell2_max_record=5    alias=config2
    Delta Commission Parameters    ${A_case7_config3}
    Start paging and check max record as expected    cell1_max_record=16    cell2_max_record=13    alias=config3
    Delta Commission Parameters    ${A_case7_config4}
    Start paging and check max record as expected    cell1_max_record=16    cell2_max_record=16    alias=config4

CB010763-SR-B-B5_ET_01_01_three_UE_can_enter_TTIbundling_mode_with_8_HARQ_config
    [Documentation]
    ...     == Requirement: ==
    ...     RM_LTE_SFS_RRM_URSC.6020;RRM_LTE_SFS_RRM_URSC.6035
    ...
    ...     == Precondition: ==
    ...     LNCEL:actTtiBundling=true
    ...     LNCEL/CATMCEL-0:actHighHarqCatM=8 HARQ
    [Tags]
    [Setup]    B_B5_case1_setup
    Attach UE1 UE2 UE3 and make them enter into TTIB mode
    Attach UE4 and check it not enter into TTIB mode
    Release UE1 and check UE4 enter into TTIB mode
    Attach UE to cell2 and make it enter into TTIB mode    ue_id=5
    UE HO to cell1 and check TTIB mode change to OFF    ue_id=5
    Release UE2 and check UE5 enter into TTIB mode
    Attach UE to cell2 and make it enter into TTIB mode    ue_id=6
    Release UE3 and UE6 trigger reestablish to cell1 and check UE6 keep TTIB mode
    [Teardown]    B_B5_case1_teardown

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=10
    Config Alias
    Set UE parameters

Modify Yaml
    Update Yaml    EPC/WS/1    phy_autoexec_file: /opt/cus/etc/autoexecs/autoexec_viterbi_lte_only.mmi
    Update Yaml    BASE_STATIONS/1    noise_level: 8
	Update Yaml    BASE_STATIONS/1/cus_config/1    lmp_ip: '192.168.200.1'    trsw_ip: '10.0.2.2'    sync_source: 'BackplanePPS'
	...    mirroring_l2_on_startup: 1    mirroring_sch_on_startup: 1    mirroring_payload: 1

Config Alias
    Config multiple UE Alias
    Create MME alias    MME_1    mme_id=1    id_type=wts
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create CELL alias    alias=CELL_2    cell_id=2    cell_type=cus
    Create CELL alias    alias=CELL_3    cell_id=2    cell_type=cus

Config multiple UE Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create UE Alias    UE_6    ue_id=6    id_type=cus
    Create UE Alias    UE_7    ue_id=7    id_type=cus

Set UE parameters
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on

Start Paging
    Execute Egate Command    mme_fake_paging_start enbs=1 session_id=1 paging_limit=640    pass_regexp=${None}
    Execute Egate Command    start    pass_regexp=Ambiguous command|S1 link is Up    timeout=120s

Start paging and check max record as expected
    [Arguments]    ${cell1_max_record}    ${cell2_max_record}    ${alias}
    Expect message flow
    ...    CELL_1:RRC_Paging (length(pagingRecordList) eq ${cell1_max_record})
    ...    CELL_2:RRC_Paging (length(pagingRecordList) eq ${cell2_max_record})
    ...    alias=maxrecord_${alias}    overall_timeout=180
    Expect Message Will Not Occur
    ...    CELL_1:RRC_Paging (length(pagingRecordList) gt ${cell1_max_record})
    ...    alias=cell1_maxrecord_plus1_${alias}    overall_timeout=30
    Expect Message Will Not Occur
    ...    CELL_2:RRC_Paging (length(pagingRecordList) gt ${cell2_max_record})
    ...    alias=cell2_maxrecord_plus1_${alias}    overall_timeout=30
    Start Paging
    Flow Occurred As Expected    alias=maxrecord_${alias}
    Flow Not Occurred For Message    alias=cell1_maxrecord_plus1_${alias}
    Flow Not Occurred For Message    alias=cell2_maxrecord_plus1_${alias}

MME trigger ETWS notification and check content correct
    ${cmd}    catenate
    ...    mme_warn_request enb=1 msg_id=4354 warn_msg_contents_length=1800 rep_period=20
    ...    data_coding_scheme=1 type=earthquake_tsunami alert=off popup=off concurrent=off
    ...    eaid=000007 eaid=000008
    Expect message flow
    ...    MME_1:S1AP_WriteReplaceWarningResponse (emergencyAreaID contains ('00 00 07'))
    ...    CELL_1:RRC_SystemInformationBlockType11 (warningMessageSegmentType contains ('lastSegment') and warningMessageSegmentNumber eq 48)
    ...    CELL_2:RRC_SystemInformationBlockType11 (warningMessageSegmentType contains ('lastSegment') and warningMessageSegmentNumber eq 48)
    ...    CELL_3:RRC_SystemInformationBlockType11 (warningMessageSegmentType contains ('lastSegment') and warningMessageSegmentNumber eq 48)
    ...    alias=SIB11    overall_timeout=90
    Execute Egate Command    ${cmd}    pass_regexp=${None}
    Flow Occurred As Expected    alias=SIB11

MME trigger CMAS notification and check content correct
    ${cmd}    catenate
    ...    mme_warn_request enb=1 msg_id=4376 update_number=1 rep_period=15s number=1
    ...    data_coding_scheme=15 warn_msg_contents_length=1800 concurrent=on
    ...    eaid=000002 eaid=000004 eaid=000005
    ${SIB12_Segment}    catenate
    ...    warningMessageSegmentType-r9 contains ('lastSegment') and warningMessageSegmentNumber-r9 eq 53
    Expect message flow
    ...    MME_1:S1AP_WriteReplaceWarningResponse (emergencyAreaID contains ('00 00 02', '00 00 04'))
    ...    CELL_2:RRC_SystemInformationBlockType12-r9 (${SIB12_Segment})
    ...    CELL_3:RRC_SystemInformationBlockType12-r9 (${SIB12_Segment})
    ...    alias=SIB12    overall_timeout=90
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType12-r9
    ...    alias=cell1_no_SIB12    overall_timeout=30
    Execute Egate Command    ${cmd}    pass_regexp=${None}
    Flow Occurred As Expected    alias=SIB12
    Flow Not Occurred For Message    alias=cell1_no_SIB12

Check SIB5 not broadcast and SIB24 contains only one dlCarFrqNr
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType24-r15 (length(carrierFreqListNR-r15) eq 1)
    ...    alias=SIB24    overall_timeout=90
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType5
    ...    alias=SIB5    overall_timeout=30
    Flow Occurred As Expected    alias=SIB24
    Flow Not Occurred For Message    alias=SIB5

Check SIB5 braodcasted
    ${SIB5_query}    catenate
    ...    length(interFreqCarrierFreqList) eq 2
    ...    and
    ...    interFreqCarrierFreqList contains (
    ...    dl-CarrierFreq eq 21000,
    ...    dl-CarrierFreq eq 22000
    ...    )
    ...    and
    ...    interFreqNeighCellList contains (
    ...    physCellId eq 43,
    ...    physCellId eq 56
    ...    )
    ...    and
    ...    interFreqExcludedCellList contains (
    ...    start eq 20,
    ...    start eq 30,
    ...    start eq 60
    ...    )
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType5 (${SIB5_query})
    ...    alias=SIB5    overall_timeout=90
    Flow Occurred As Expected    alias=SIB5

B_B5_case1_setup
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${B_B5_case1_config}
    Cells Should Be OnAir
    Trigger ttiBundling deactivation for UE    ue_id=1-6

B_B5_case1_teardown
    Delta Commission Parameters    ${HighHARQ_disable}
    Cells Should Be OnAir
    Common Test Teardown And Stop Capture Logs

UE attach to cell1
    [Arguments]    ${ue_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    ${ret1}=    Execute Uex Command    ${V_1}

UE attach to cell2
    [Arguments]    ${ue_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    ${ret1}=    Execute Uex Command    ${V_1}

Attach UE and make it enter into TTIB mode
    [Arguments]    ${ue_id}=1
    UE attach to cell1    ue_id=${ue_id}
    Create QCI1 Bearer for UE    ue_id=${ue_id}
    Start data traffic on QCI1 bearer for UE    ue_id=${ue_id}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    Trigger ttiBundling activation for UE    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RRC

Create QCI1 Bearer for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31

Start data traffic on QCI1 bearer for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl_and_ul rate=200 protocol=udp kbps_dl=300 kbps_ul=300 qci=1

Trigger ttiBundling activation for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_ul_power_control id=${ue_id} pathloss=125 cell=both

Trigger ttiBundling deactivation for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_ul_power_control id=${ue_id} pathloss=10

Attach UE4 and check it not enter into TTIB mode
    UE attach to cell1    ue_id=4    #check TTIB meas on
    Create QCI1 Bearer for UE    ue_id=4
    Start data traffic on QCI1 bearer for UE    ue_id=4
    Expect Message Will Not Occur
    ...    UE_4:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=5
    Trigger ttiBundling activation for UE    ue_id=4
    Flow Not Occurred For Message    alias=RRC

Attach UE to cell2 and make it enter into TTIB mode
    [Arguments]    ${ue_id}=1
    UE attach to cell2    ue_id=${ue_id}
    Create QCI1 Bearer for UE    ue_id=${ue_id}
    Start data traffic on QCI1 bearer for UE    ue_id=${ue_id}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    Trigger ttiBundling activation for UE    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RRC

UE HO to cell1 and check TTIB mode change to OFF
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (ttiBundling eq 'FALSE')
    ...    alias=RRC    overall_timeout=5
    UE HO to cell1    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RRC

UE HO to cell1
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1

Release UE1 and check UE4 enter into TTIB mode
    Expect message flow
    ...    UE_4:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    Execute Uex Command    ue_detach id=1
    Flow Occurred As Expected    alias=RRC

Release UE2 and check UE5 enter into TTIB mode
    Expect message flow
    ...    UE_5:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    Execute Uex Command    ue_detach id=2
    Flow Occurred As Expected    alias=RRC

Release UE3 and UE6 trigger reestablish to cell1 and check UE6 keep TTIB mode
    Execute Uex Command    ue_detach id=3
    Expect Message Will Not Occur
    ...    UE_6:RRC_RRCConnectionReconfiguration (ttiBundling eq 'FALSE')
    ...    alias=RRC    overall_timeout=5
    Execute Uex Command    ue_ho id=6 enb=1 cell=1 fail=dest phase=complete_fail
    Flow Not Occurred For Message    alias=RRC

Attach UE1 UE2 UE3 and make them enter into TTIB mode
    Attach UE and make it enter into TTIB mode    ue_id=1
    Attach UE and make it enter into TTIB mode    ue_id=2
    Attach UE and make it enter into TTIB mode    ue_id=3
