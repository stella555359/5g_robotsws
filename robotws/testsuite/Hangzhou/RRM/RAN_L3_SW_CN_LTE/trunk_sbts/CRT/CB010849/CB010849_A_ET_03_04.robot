*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
...    if test case check failed, can check BTSLOG first, wireshark log can not check UE reject,
...    BTSLOG print:
...    RacException 'Cell capacity exceeded. No preemption possible: feature deactivated'
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_2MAPO_2CUS
...               release-SBTS24R2    team-CN3ET   owner-feng.2.chen
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
#disable wireshark to improve performance
${WIRESHARK_FLAG}    ${False}
${UTE_WIRESHARK_FLAG}    ${False}

@{PARAMS_IN_SCF}
...    @{CB010849}
...    @{CA1}
...    @{CB009228}

@{CB010849}
...    @{active_10849}
...    LNCEL/LNCEL_FDD-0:ulChBw=3 MHz
...    LNCEL/LNCEL_FDD-0:dlChBw=3 MHz
...    LNBTS:actBbPooling=true
...    LNBTS:actCompChecks=true
...    LNBTS:actDynMBMSRes=true
...    LNBTS:actLTES1Ho=false
...    LNBTS:actMBMS=true
...    LNBTS:actMBMSPS=true
...    LNBTS:actMultGbrBearers=false
...    LNBTS:actMultipleCarrier=2_carrierOperation
...    LNBTS:actQCIPLMNIDProfiles=false
...    LNBTS:actRedirect=disabled
...    LNBTS:actS1OlHandling=true
...    LNBTS:anrOmExtEnable=true
...    LNBTS:bbPoolEvalPeriod=50
...    LNBTS:caUlIntraBandAmpr=enabled
...    LNBTS:dlCaPreferred=DLonly
...    LNBTS:dynBlacklistingHoTimer=60s
...    LNBTS:enbName=2-16-CLOUD1047
...    LNBTS:geranDtmCap=true
...    LNBTS:ilGrantGapTcpBoostTxSkip=10
...    LNBTS:ilGrantGapTxSkip=10
...    LNBTS:ilMinDatvolUlTcpBoost=560
...    LNBTS:ilReacTimerUlTcpBoost=10
...    LNBTS:ilReacTimerUlTcpBoostTxSkip=10
...    LNBTS:ilReacTimerUlTxSkip=0
...    LNBTS:maxEUTRANCapabilitySize=0
...    LNBTS:maxNumOfLnadjLimit=256
...    LNBTS:mcc=214
...    LNBTS:mnc=40
...    LNBTS:nConsecHOPrepTimeouts=5
...    LNBTS:nCqiDtx=250
...    LNBTS:prioTopoHO=all equal
...    LNBTS:pwrFallbackCa=true
...    LNBTS:rrcGuardTimer=20
...    LNBTS:s1InducedCellDeactDelayTime=900
...    LNBTS:sCellActivationCyclePeriod=0.001s
...    LNBTS:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS:sibUpdateRateThreshold=25
...    LNBTS:tHalfRrcCon=3000
...    LNBTS:tLteNrDualConnectPrep=500
...    LNBTS:tOverbookingAc=2000
...    LNBTS:tS1RelPrepL=500
...    LNBTS:tS1RelPrepU=2000
...    LNBTS:tX2RelocPrep=500
...    LNBTS:timeConnFailureThreshold=2000
...    LNBTS:cipherPrefL:eea1=9
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=emergency
...    LNBTS:estCauseArpMapConfig:arpPriority=2|estCause=highPriorityAccess
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=highPriorityAccess
...    LNBTS:estCauseArpMapConfig:arpPriority=3|estCause=mt-Access
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=mt-Access
...    LNBTS:estCauseArpMapConfig:arpPriority=4|estCause=mo-Signalling
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=mo-Signalling
...    LNBTS:estCauseArpMapConfig:arpPriority=5|estCause=mo-Data
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=mo-Data
...    LNBTS:estCauseArpMapConfig:arpPriority=6|estCause=delayTolerantAccess-v1020
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=delayTolerantAccess-v1020
...    LNBTS:integrityPrefL:eia0=0
...    LNBTS:pdcpProf1:tDiscard=infinity
...    LNBTS:pdcpProf101:tDiscard=150ms
...    LNBTS:qciTab1:maxGbrUl=256
...    LNBTS:qciTab1:maxGbrDl=256
...    LNBTS:qciTab2:maxGbrUl=840
...    LNBTS:qciTab2:maxGbrDl=840
...    LNBTS:qciTab5:lcgid=3
...    LNBTS:qciTab6:rlcProfIdx6cc7cc=8
...    LNBTS:qciTab7:pdcpProfIdx=2
...    LNBTS:qciTab7:rlcProfIdx6cc7cc=8
...    LNBTS:qciTab7:lcgid=3
...    LNBTS:qciTab70:rlcProfIdx6cc7cc=8
...    LNBTS:qciTab70:dscp=30
...    LNBTS:qciTab8:rlcProfIdx6cc7cc=8
...    LNBTS:qciTab8:rlcProfIdx=2
...    LNBTS:qciTab9:rlcProfIdx6cc7cc=8
...    LNBTS:rlcProf1:pollPdu=infinity
...    LNBTS:rlcProf7:tReord=15ms
...    LNBTS/ACBPR-1:acBarSkipForMMTELVideo=true
...    LNBTS/ACBPR-1:eCallAcBarredAuto=barred
...    LNBTS/ANRPRL-0:anrThresRSRPNbCell=-100
...    LNBTS/ANRPRL-0:nrLimitIntraFreq=32
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS/LNBTS_FDD-0:actPubSafetyBearers=true
...    LNBTS/LNBTS_FDD-0:skipPsQciUeReleaseCheck=false
...    LNCEL-1:a3Offset=6
...    LNCEL-1:a3ReportInterval=640ms
...    LNCEL-1:a3TimeToTrigger=320ms
...    LNCEL-1:a5ReportInterval=640ms
...    LNCEL-1:a5TimeToTrigger=320ms
...    LNCEL-1:actDlsOldtc=false
...    LNCEL-1:actModulationSchemeDl=64QAM
...    LNCEL-1:actModulationSchemeUL=64QAMand16QAMHighMCS
...    LNCEL-1:actUlpcMethod=PuschOLPucchOL
...    LNCEL-1:defPagCyc=128rf
...    LNCEL-1:dlsDciCch=DCI format 1A
...    LNCEL-1:enableLowAgg=false
...    LNCEL-1:harqMaxMsg3=5
...    LNCEL-1:harqMaxTrDl=5
...    LNCEL-1:ilReacTimerUl=0
...    LNCEL-1:iniMcsUl=5
...    LNCEL-1:lcrId=1
...    LNCEL-1:maxBitrateUl=110000
...    LNCEL-1:maxCrRa4Dl=12
...    LNCEL-1:mobStateParamNCelChgHgh=10
...    LNCEL-1:mobStateParamNCelChgMed=5
...    LNCEL-1:mobStateParamTEval=30s
...    LNCEL-1:mobStateParamTHystNorm=30s
...    LNCEL-1:nbIoTMode=disabled
...    LNCEL-1:nbIotLinkedCellId=1
...    LNCEL-1:p0NomPucch=-116
...    LNCEL-1:p0NomPusch=-80
...    LNCEL-1:pMax=370
...    LNCEL-1:pdcchAggMsg4=8
...    LNCEL-1:phyCellId=11
...    LNCEL-1:raContResoT=64ms
...    LNCEL-1:t304IntraLte=1000ms
...    LNCEL-1:t304eNaccGsm=4000ms
...    LNCEL-1:tPeriodicBsr=10ms
...    LNCEL-1:tac=33
...    LNCEL-1:threshold1=90
...    LNCEL-1:threshold2InterFreq=40
...    LNCEL-1:threshold2a=64
...    LNCEL-1:threshold3=24
...    LNCEL-1:threshold3a=26
...    LNCEL-1:threshold4=18
...    LNCEL-1:ulamcAllTbEn=false
...    LNCEL-1:ulsFdPrbAssignAlg=MixedFD
...    LNCEL-1:dFListPucch:dFpucchF1b=3
...    LNCEL-1:drxProfile101:drxLongCycle=160ms
...    LNCEL:drxProfile101:drxRetransT=6
...    LNCEL-1:drxProfile102:drxInactivityT=20
...    LNCEL-1:a2TimeToTriggerActWcdmaMeas=40ms
...    LNCEL-1:harqMaxTrVoLteDl=8
...    LNCEL-1:hysThreshold2Wcdma=0
...    LNCEL-1:measQuantityUtra=cpichRSCP
...    LNCEL-1:t304InterRAT=500ms
...    LNCEL-1:threshold2Wcdma=25
...    LNCEL/DRX-0:drxProfile2:drxRetransT=6
...    LNCEL/DRX-0:drxProfile3:drxRetransT=6
...    LNCEL-1/DRX-0:drxProfile4:drxOnDuratT=10
...    LNCEL-1/DRX-0:drxProfile5:drxOnDuratT=10
...    LNCEL-1/DRX-0:drxProfile6:drxRetransT=6
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:addNumDrbRadioReasHo=90
...    LNCEL-1/LNCEL_FDD-0:addNumDrbTimeCriticalHo=135
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbRadioReasHo=16
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbTimeCriticalHo=16
...    LNCEL-1/LNCEL_FDD-0:cqiAperPollT=10
...    LNCEL-1/LNCEL_FDD-0:dlChBw=3 MHz
...    LNCEL/LNCEL_FDD-0:maxNumActDrb=300
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=120
...    LNCEL-2/LNCEL_FDD-0:maxNumActUE=60
...    LNCEL-3/LNCEL_FDD-0:maxNumActUE=60
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=50
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=36
...    LNCEL-1/LNCEL_FDD-0:prachCS=1
...    LNCEL-1/LNCEL_FDD-0:prachConfIndex=3
...    LNCEL-1/LNCEL_FDD-0:prachFreqOff=24
...    LNCEL-1/LNCEL_FDD-0:syncSigTxMode=SingleTx
...    LNCEL-1/LNCEL_FDD-0:twoLayerMimoAvSpectralEff=2
...    LNCEL-1/LNCEL_FDD-0:ulChBw=3 MHz
...    LNCEL-1/LNCEL_FDD-0:ulpcRarespTpc=2
...    LNCEL-1/LNCEL_FDD-0:mimoOlConfig:mimoOlCqiThD=10
...    LNCEL-1/LNCEL_FDD-0:mimoOlConfig:mimoOlCqiThU=20
...    LNCEL-1/LNCEL_FDD-0:mimoOlConfig:mimoOlRiThU=40
...    LNCEL-1/LNCEL_FDD-0:mimoOlConfig:mimoOlRiThD=20
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=0
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=0
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=0
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=0
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=0
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:pucchArRateEvalWinLength=0
...    LNCEL-1/SDRX-0:drxSmartProfile2:drxShortCycle=40ms
...    LNCEL-1/SDRX-0:drxSmartProfile2:drxRetransT=6
...    LNCEL-2/SDRX-0:drxSmartProfile2:drxRetransT=6
...    LNCEL-3/SDRX-0:drxSmartProfile2:drxRetransT=6
...    LNCEL/SDRX-0:drxSmartProfile3:drxRetransT=6
...    LNCEL-1/SDRX-0:drxSmartProfile6:drxRetransT=6
...    LNCEL/SIB-0:autoAcBarringStartTimer=60
...    LNCEL/SIB-0:autoAcbPlmnRmvlStopTimer=900
...    LNCEL/SIB-0:cellReSelPrio=0
...    LNCEL/SIB-0:intraPresAntP=false
...    LNCEL/SIB-0:preambTxMax=200
...    LNCEL/SIB-0:qHyst=2dB
...    LNCEL/SIB-0:qrxlevmin=-130
...    LNCEL/SIB-0:qrxlevminintraF=-140
...    LNCEL/SIB-0:siWindowLen=40ms
...    LNCEL/SIB-0:t300=400ms
...    LNCEL/SIB-0:t301=400ms
...    LNCEL/SIB-0:t311=3000ms
...    LNCEL/SIB-0:threshSrvLow=4
...    LNCEL/SIB-0:ulpcIniPrePwr=-96 dBm
...    LNCEL/SIB-0:sib2Scheduling:siMessagePeriodicity=640ms
...    LNCEL/SIB-0:sib3Scheduling:siMessagePeriodicity=640ms
...    LNCEL/SIB-0:mbmsNeighCellConfigIntraF=00
...    LNBTS/LNMCE-0:mceName=1
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:maxSyncSubfrPShare=2.500%
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=3 MHz
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:syncAreaId=1
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:maxSubfrPShare=2.500%
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbsfnAreaId=0
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbsfnStartingSF=1
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:signallingMCS=n7
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbmsSaiList=1
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mchInfo:dataMCS=1
...    LNBTS/LNMME-0:mmeRatSupport=Wideband-LTE and NB-IoT
...    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1:bbPoolSizeLte=extended
...    delete:LNBTS/CRGPR-1
...    delete:LNCEL-1/LNRELG-1
...    delete:LNCEL-1/GFIM-1/GNFL-1
...    delete:LNCEL-1/GFIM-1
...    delete:LNCEL-1/CDFIM-1
...    LNCEL:drxProfile104:drxRetransT=6
...    LNCEL-2:redBwRbUlConfig:redBwMaxRbUl=15
...    LNCEL-3:redBwRbUlConfig:redBwMaxRbUl=15
...    LNBTS/M1SYNC-0:mbmsSyncPeriod=8
...    LNBTS/M1SYNC-0:mbmsSyncRef:fractionalSecs=1
...    LNBTS/M1SYNC-0:mbmsSyncRef:integralSecs=1
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mchInfo:mchSchedulingPeriod=rf8
...    LNCEL-1/MBSFNCEL-0:mbsfnAreaInUseList=0
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageSibType=SIB13
...    LNCEL:inactivityTimerPubSafety=30000
...    LNCEL-1:t301Guard=300
...    LNCEL-1:redBwRbUlConfig:redBwMaxRbUl=15
...    LNBTS/CRGPR-1:groupShareList:groupShare=75|groupId=0
...    LNBTS/CRGPR-1:groupShareList:groupShare=25|groupId=1
...    LNBTS/CRGPR-1:plmnGroupList:mcc=214|groupId=0
...    LNBTS/CRGPR-1:plmnGroupList:mnc=40|groupId=0
...    LNBTS/CRGPR-1:plmnGroupList:mcc=262|groupId=1
...    LNBTS/CRGPR-1:plmnGroupList:mnc=3|groupId=1
...    LNCEL/BBPOOLALLOC-0:bbPoolLogicalGroupId=${EMPTY}
...    LNCEL/BBPOOLALLOC-0:bbPoolTargetId=${EMPTY}
...    LNCEL/LNCEL_FDD-0:actMixedMimoTMs=false
@{CB009228}
...    LNCEL:actPttOverbooking=true
...    LNCEL:actModulationSchemeUL=QPSK
...    LNBTS:qciTab65:gbrOverbookingFactorUl=50
...    LNBTS:qciTab66:gbrOverbookingFactorUl=50
...    LNBTS:qciTab65:gbrOverbookingFactorDl=0
...    LNBTS:qciTab66:gbrOverbookingFactorDl=0
...    LNBTS-1:actMultGbrBearers = true
...    LNCEL:maxGbrTrafficLimit = 45
...    LNCEL:addGbrTrafficRrHo = 5
...    LNCEL:addGbrTrafficTcHo = 10
...    LNCEL:cellResourceScellMode=NoScellDefaultGroupUsage
...    LNBTS:actERabModify = true
...    LNBTS:actNonGbrServiceDiff=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS-1/LNBTS_FDD-0:actPubSafetyBearers = true
...    LNBTS-1/LNBTS_FDD-0:skipPsQciUeReleaseCheck=false
...    LNCEL:redBwMaxRbDl=50
...    LNBTS:actERabModifyQci66and65 = true
...    LNBTS:qciTab65:qciSupp = ENABLE
...    LNCEL:inactivityTimerPubSafety=1200
...    LNBTS:qciTab65:enforceTtiBundling = false
...    LNBTS:qciTab65:maxGbrDl = 256
...    LNBTS:qciTab65:maxGbrUl = 256
...    LNBTS:qciTab65:prio=7
...    LNBTS:qciTab65:qciSupp=ENABLE
...    LNBTS:qciTab66:enforceTtiBundling = false
...    LNBTS:qciTab66:maxGbrDl = 256
...    LNBTS:qciTab66:maxGbrUl = 256
...    LNBTS:qciTab66:prio=20
...    LNBTS:qciTab66:qciSupp=ENABLE
...    LNBTS:qciTab2:maxGbrDl = 256
...    LNBTS:qciTab2:maxGbrUl = 256
...    LNBTS:qciTab3:maxGbrDl = 256
...    LNBTS:qciTab3:maxGbrUl = 256
...    LNBTS:qciTab4:maxGbrDl = 256
...    LNBTS:qciTab4:maxGbrUl = 256

...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:maxSyncSubfrPShare=2.500%
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=3 MHz
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:syncAreaId=1
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:maxSubfrPShare=2.500%
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbsfnAreaId=0
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbsfnStartingSF=1
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:signallingMCS=n7
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbmsSaiList=1
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mchInfo:dataMCS=1

@{active_10849}
...    LNBTS/LNCEL/LNCEL_FDD-0:actEnhMaxNumActUe3MHz=true

@{PARAMS_IN_SWCONFIG}
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

${AaSysLogOutputMode}     0x10041     #0=none,1=all,2=udp,3=sic,4=stdout, 5=local, 6=remote
${AaSysLogOutputLevel}     0x10040    #1=DBG,2=INF(default),3=WRN,4=ERR,5=VIP,6=NoPrints
${AaSysLogInputLevel}      0x1003F    #1=DBG,2=INF(default),3=WRN,4=ERR,5=VIP,6=NoPrints
${TRromRadDebugLogEnabledCommon}    0x120006
${TRromRadDebugLogEnabledGlobal}    0x120004
${TRromRadDebugLogEnabledRrom}    0x120005
${TUecRadDebugLogEnabledGlobal}    0x130020
${TUecRadDebugLogEnabledUec}    0x130021
${TUecRadDebugLogEnabledCommon}    0x13001E
${TUecRadDebugLogEnabledCommonCodec}    0x13001F

@{PARAMS_IN_EMIL}
...    0x2663


@{CA1}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actDLCAggr=true
...    LNBTS:actFlexCaMgmt=true
...    LNBTS:hpsSessConfig:hpsSessArpMax=4
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemVul=true
...    LNBTS:imsEmerPlmnConfig:emerSessLimServ=false
...    LNBTS:imsEmerPlmnConfig:emerSessMcc=214
...    LNBTS:imsEmerPlmnConfig:emerSessMnc=40
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20
...    delete:LNBTS/CTRLTS-1
...    delete:LNCEL-1/CAREL-1
...    LNCEL:actFlowCtrlEnh=true

@{maxNumActUE_240}
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=240

@{additional_margin}
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=210
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNBTS/LNCEL/LNCEL_FDD-0:actEnhMaxNumActUe3MHz=true


*** Test Cases ***
CB010849-SR-ET_03_01_Check_maximum number of active users per 3 MHz FDD cell with actAcHpsLimits flase
    [Tags]
    Delta Commission Parameters    ${maxNumActUE_240}
    Attach 240 normal UE successfully
    Attach 241th normal UE is rejected
    Detach 10 UE and HO and reestablish 10 UE successfully
    Attach 241th normal UE is rejected

CB010849-SR-ET_04_01_Check_maximum number of active users per 3 MHz FDD cell with automatic PUCCH configurations
    [Tags]
    Delta Commission Parameters    ${additional_margin}
    Attach 210 normal UE successfully
    Attach 211th normal UE is rejected
    Make 5 UEs IDLE and attach another 5 UEs successfully
    Attach 30 Emergency UE successfully
    Attach 31th Emergency UE is rejected
    Attach 10 Emergency Ues firstly and check only 200 normal UE can be active
    Attach another 30 Emergency UE successfully

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=300

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'ulm_pgw3.net'
    ...    devtype: 'tun'
    ...    devname: 'tunPGW3'
    ...    emergency: 'on'

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...      - {qci: 6, default: on, pdn: 1, trf_type: internal}
    ...      - {qci: 7, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 8, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 65, preprovisioned: off, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...      - {qci: 66, preprovisioned: off, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
     ...     - {qci: 6, default: on, pdn: 2}
    ...      - {qci: 1, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31, pdn: 2}
    ...      - {qci: 5, default: on, pdn: 3, priority: 1}
    ...      - {qci: 1, pdn: 3, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31,
    ...         preemption: 1, vulnerability: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    FOR    ${ue_id}     IN RANGE    210    280
        Update Yaml    UEs/UE_sets/${ue_id}    bearer: bearer_set_3
    END


Attach Ues In Cell
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR    ${local_ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id} + 1
        Wait Until Keyword Succeeds    1m    10s    Attach Ue     ue_id=${local_ue_id}
    END

Attach UE
    [Arguments]    ${ue_id}    ${cell_id}=1
    ${ret1}    Execute Uex Command    ue_attach id=${ue_id} cell=${cell_id}

Verify Cell Active Ue Amount
    [Arguments]     ${expected_ue_amount}
    ${ue_count}    Get Active UE count from Cell
    ${expected_ue_amount}    Convert To Integer    ${expected_ue_amount}
    Should Be Equal    ${expected_ue_amount}    ${ue_count}

Get Active UE count from Cell
    ${out}    Execute uex Command    get_ue_summary
    ${length}    get length    ${out["active"]}
    Log    ${length}
    [Return]    ${length}

handover to CELL-1
    [Arguments]    ${ue_id}=1
     ${command}    catenate
     ...    ue_ho id=${ue_id} enb=1 cell=1
    Execute Uex Command    ${command}

Inter cell HO from cell2 to Cell1
    [Arguments]    ${start_ue_id}    ${end_ue_id}
     FOR    ${local_ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id} + 1
          Attach UE    ue_id=${local_ue_id}    cell_id=2
          handover to CELL-1    ue_id=${local_ue_id}
     END

Reestablish several UEs
     [Arguments]    ${start_ue_id}    ${end_ue_id}
     FOR    ${local_ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id} + 1
         Attach UE    ue_id=${local_ue_id}    cell_id=1
         trigger UE RCR to cell1    ue_id=${local_ue_id}    cell_id=1
     END

trigger UE RCR to cell1
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} enb=1 cell=${cell_id}

Detach UEs
     [Arguments]    ${start_ue_id}    ${end_ue_id}
     FOR    ${local_ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id} + 1
        Execute Uex Command    ue_detach id=${local_ue_id}
     END

Attach Emergency Ues In Cell
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR    ${local_ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id} + 1
        Wait Until Keyword Succeeds    1m    10s    Attach UE with emergency on     ue_id=${local_ue_id}
    END

Make UEs IDLE
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR    ${local_ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id} + 1
        Wait Until Keyword Succeeds    1m    10s    Make UE IDLE     ue_id=${local_ue_id}
    END

Make UE IDLE
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_s1_ctx_release id=${ue_id} cause_nas=normal_release    UEContextReleaseComplete

Attach UE with emergency on
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1
    Execute Uex Command    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id} emergency=on establishment_cause=emergency

Attach 240 normal UE successfully
    Attach Ues In Cell    1     240
    Verify Cell Active Ue Amount    240

Attach 210 normal UE successfully
    Attach Ues In Cell    1     210
    Verify Cell Active Ue Amount    210

Attach 241th normal UE is rejected
    Execute Uex Command And Expect Error    ue_attach id=241 cell=1    sErr

Attach 211th normal UE is rejected
    Execute Uex Command And Expect Error    ue_attach id=211 cell=1    sErr

Detach 10 UE and HO and reestablish 10 UE successfully
    Detach UEs    1    10
    Inter cell HO from cell2 to Cell1    1    5
    Reestablish several UEs    6    10
    Verify Cell Active Ue Amount    240

Make 5 UEs IDLE and attach another 5 UEs successfully
    Make UEs IDLE    206    210
    Attach Ues In Cell    211     215

Attach 30 Emergency UE successfully
    Attach Emergency Ues In Cell    216    245
Attach 31th Emergency UE is rejected
    Execute Uex Command And Expect Error    ue_attach id=246 cell=1    sErr
    Verify Cell Active Ue Amount    240
    Detach UEs    1    245

Attach 10 Emergency Ues firstly and check only 200 normal UE can be active
    Attach Emergency Ues In Cell    211    220
    Attach Ues In Cell    1     200
    Execute Uex Command And Expect Error    ue_attach id=201 cell=1    sErr

Attach another 30 Emergency UE successfully
    Attach Emergency Ues In Cell    221    250
    Execute Uex Command And Expect Error    ue_attach id=251 cell=1 emergency=on establishment_cause=emergency    sErr
    Verify Cell Active Ue Amount    240








