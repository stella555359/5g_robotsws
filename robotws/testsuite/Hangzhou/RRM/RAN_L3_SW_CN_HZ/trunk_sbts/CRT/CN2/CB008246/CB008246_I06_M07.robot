*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008246    release-SBTS23R4
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${EMIL_FLAG}    ${False}

${SNAPSHOT_FLAG}    pass:False,fail:False
${SOS_REPORT_FLAG}    pass:False,fail:False
${DEBUG_LOG_LEVEL}    0

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL-2:cellDepType=SA
...    delete:NRCELL-2:configuredEpsTac
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actUl256Qam=false
...    NRCELL:actDl256Qam=false
...    @{5qi80_related_modification}
...    @{5qi71_related_modification}
...    @{5qi4_related_modification}
...    @{8246_related}
...    @{rac}
...    @{bwp_pdcch}

@{8246_related}
...    @{bwp_profile}
...    @{PDSCHHRLA_PUSCHHRLA}
...    @{8246_cell_configuration}

@{bwp_profile}
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-14/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4

@{bwp_pdcch}
...    BWP_PROFILE/PDCCH-1:alSelection=dynamic
...    BWP_PROFILE/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl16HR=159
...    BWP_PROFILE/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl8HR=159
...    BWP_PROFILE/PDCCH-1:dynamicAggregationLevelHRSet:pCqiErasureActTimerHR=50
...    BWP_PROFILE/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=50

@{PDSCHHRLA_PUSCHHRLA}
#5QI-71
...    NRBTS/NRDRB-18:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
#5QI-4
...    NRBTS/NRDRB-20:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-20:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
#5qi=6
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
#5qi=7
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
#5qi=80
...    NRBTS/NRDRB-17:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-17:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2

...    MRBTS-1/NRBTS-1/NRPDCCHHRLA-1:nrPdcchHRLaId=1
...    NRBTS/NRDRB-18:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-20:cellAggrLevel=FR1 CA incompatible

...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=10
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=30
#focus
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=2
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=200

...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=10
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=30
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=2
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=101

...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-1:ullaBlerTargetHR=2
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh64qam=7000

...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=200
...    NRBTS/NRPUSCHHRLA-2:ullaBlerTargetHR=2
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh64qam=7000

@{8246_cell_configuration}
...    NRCELL:actCceSplit=false
...    NRCELL:actLAForHiReliab=true
...    NRCELL:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL:pdschHrLaConfig:dllaIniMcsHR=3
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20
...    NRCELL:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMaxHR=150
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMinHR=-300
...    NRCELL:puschHrLaConfig:ullaDeltaSinrStepdownHR=20
...    NRCELL:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK2HR=25
...    NRCELL:puschHrLaConfig:ullaSinrOffsetHR=20

@{5qi80_related_modification}
...    NRBTS/NRDRB-17:actDddsReduction=false
...    NRBTS/NRDRB-17:actLostPduFastRetx=false
...    NRBTS/NRDRB-17:discardTimer=infinity
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-17:dscp=0
...    NRBTS/NRDRB-17:endMarkerTimer=2000
...    NRBTS/NRDRB-17:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-17:numSduDiscard=1
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:resType=nonGBR
...    NRBTS/NRDRB-17:rlcMode=RLC_UM
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-17:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-17:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-17:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-17:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-17:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-17:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-17:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-17:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-17:nsaDrbParam:ulDataSplitThreshold=infinity
...    delete:NRBTS/NRDRB-17:nrPdschHRLaDN
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=80
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{5qi71_related_modification}
...    NRBTS/NRDRB-18:actDddsReduction=false
...    NRBTS/NRDRB-18:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-18:actLostPduFastRetx=false
...    NRBTS/NRDRB-18:discardTimer=50ms
...    NRBTS/NRDRB-18:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-18:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-18:dscp=0
...    NRBTS/NRDRB-18:durationThresDiscardDl=40
...    NRBTS/NRDRB-18:durationThresDiscardUl=20
...    NRBTS/NRDRB-18:endMarkerTimer=2000
...    NRBTS/NRDRB-18:l2OHFactorDl=16
...    NRBTS/NRDRB-18:l2OHFactorUl=35
...    NRBTS/NRDRB-18:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-18:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-18:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-18:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-18:maxTransferDelayGbr=20
...    NRBTS/NRDRB-18:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-18:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-18:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-4
...    NRBTS/NRDRB-18:numSduDiscard=1
...    NRBTS/NRDRB-18:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-18:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-18:resType=GBR
...    NRBTS/NRDRB-18:rlcMode=RLC_AM
...    NRBTS/NRDRB-18:schedulWeight=1
...    NRBTS/NRDRB-18:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-18:volThresDiscardDl=8000
...    NRBTS/NRDRB-18:volThresDiscardUl=800
...    NRBTS/NRDRB-18:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-18:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-18:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-18:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-18:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-18:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-18:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-18:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-18:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-18:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-18:nsaDrbParam:ulDataSplitThreshold=infinity
...    delete:NRBTS/NRDRB-18:nrPdschHRLaDN
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-18
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=7
...    NRBTS/NRDRB_PDCP-4:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-4:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-4:tReorderingDl=ms8
...    NRBTS/NRDRB_PDCP-4:tReorderingUl=ms8
...    NRBTS/NRDRB_PDCP-4:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_AM-4:dlMaxRetxThreshold=t16
...    NRBTS/NRDRB_RLC_AM-4:dlPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:dlPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:dlTPollRetr=ms100
...    NRBTS/NRDRB_RLC_AM-4:dlTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassemblyIBCA=30
...    NRBTS/NRDRB_RLC_AM-4:duFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-4:ulMaxRetxThreshold=t32
...    NRBTS/NRDRB_RLC_AM-4:ulPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:ulPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:ulTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-4:ulTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassemblyIBCA=${EMPTY}

@{5qi4_related_modification}
...    NRBTS/NRDRB-20:actDddsReduction=false
...    NRBTS/NRDRB-20:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-20:actLostPduFastRetx=false
...    NRBTS/NRDRB-20:discardTimer=50ms
...    NRBTS/NRDRB-20:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-20:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-20:dscp=0
...    NRBTS/NRDRB-20:durationThresDiscardDl=40
...    NRBTS/NRDRB-20:durationThresDiscardUl=20
...    NRBTS/NRDRB-20:endMarkerTimer=2000
...    NRBTS/NRDRB-20:l2OHFactorDl=16
...    NRBTS/NRDRB-20:l2OHFactorUl=35
...    NRBTS/NRDRB-20:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-20:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-20:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-20:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-20:maxTransferDelayGbr=20
...    NRBTS/NRDRB-20:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-20:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-20:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-4
...    NRBTS/NRDRB-20:numSduDiscard=1
...    NRBTS/NRDRB-20:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-20:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-20:resType=GBR
...    NRBTS/NRDRB-20:rlcMode=RLC_AM
...    NRBTS/NRDRB-20:schedulWeight=1
...    NRBTS/NRDRB-20:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-20:volThresDiscardDl=8000
...    NRBTS/NRDRB-20:volThresDiscardUl=800
...    NRBTS/NRDRB-20:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-20:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-20:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-20:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-20:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-20:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-20:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-20:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-20:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-20:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-20:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-20:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-20:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-20:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-20:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB_5QI-9:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-20

@{rac}
...    NRCELL:actGBRAdmissionControl=GBRService
...    NRCELL:maxGBRTrafficLimit=40

@{online_modify_step1}
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=10
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=20

@{online_modify_step2}
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=18
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=25

${UE_Capa_Support_HR_PUSCH_TypeA_PDSCH_TypeA}    SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C41B4026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C00
...    103278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13758202
...    8680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C0
...    0103278FAA8000028000000841C4D000000002026878003804044F613003000281C1401C0C026007000683E0000000000000E54D00010000
...    0965950034AAA84801C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280

${normal_ue}    SEPARATOR=
...    e1a00000074e5a031e000380a03c1260c80008780818806804c020301c032a36146b04050d012cb2898087ad8202020e1de38720c3800206
...    4f1f570004f001c0013c002a36266b04050d012cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a3626eb04050d01
...    2cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a36276b04050d012cb2898087ad8202020e1de38720c38002064f
...    1f55000005000000108389a00000000404d0103804044f60701800140e020381801c07000683e0000000000000e54d000100000965950034
...    aaa8081c002c000000100200462c4c0004080c1014181c202c4044484c648494989ca128

*** Test Cases ***
CB008246_I_006_FR1_SA_TDD_Scheduling_5G_UE_with_multiple_nonGBR_HR_DRBs_in_UL_via_PDU_Online_Change_dllaMcsMax64qam_param
    [Documentation]
    ...    1.Description
    ...    To validate the gNB behaviour for the setup and release of one GBR High Reliability DRB associated with
    ...    QoS flow with 5QI 2/3/4 and one or more non-GBR High Reliability DRB. It also verifies data transmission in UL.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.5QI_6 is associated with NRPUSCHHRLA-1,and 5QI_7 is associated with NRPUSCHHRLA-2, they are both default DRB.
    ...      d.UE does support Ul-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE1 attach to target cell w default DRB 5QI6&7.
    ...      b.UE2 and UE3 enter idle.
    ...      c.online modify parameters step1, then make UE2 exit idle.
    ...      d.online modify parameters step2, then make UE3 exit idle.
    ...      e.all UE detach.
    ...    4.Check Points
    ...      for stepc:modification take effect on UE1 and UE2.
    ...      for stepd:modification take effect on UE1, UE2 and UE3.
    [Tags]    QC_305532    owner-kexin.bao
    UE Attach To Target Cell    ue_id=2    cell_id=1    pass_regexp=mcs-Table qam64LowSE
    Make UE In Idle    ue_id=3    cell_id=1    pass_regexp=mcs-Table qam64LowSE
    Online Modify Step1
    Make UE In Idle    ue_id=4    cell_id=1    pass_regexp=mcs-Table qam64LowSE
    Online Modify Step2
    Release All UEs    ue_id_start=2    ue_id_end=4

CB008246_M_007_TDD_Mulit_BR_and_HR_DRBs_setup_ICS_with_ue_capabilities_from_RRC_idle_to_connected
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the gNB behaviour for the setup and release of one or more non-GBR High Reliability
    ...    and one or more non-GBR Basic Reliability DRBs and data transmission in DL/UL.
    ...    2.Configuration
    ...      a.TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.5QI_8 is BR,5QI_80 is associated with NRPUSCHHRLA-1 and NRPDSCHHRLA-2,and 5QI_71 is associated with NRPDSCHHRLA-1,
    ...        they are all default DRB.
    ...      d.UE does support Ul-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE1 attach to target cell w default DRB 5QI8&80&71.
    ...      b.UE2 enter idle and exit idle.
    ...      c.UE3 enter idle.
    ...      d.online modify parameters NRCELL:maxGBRTrafficLimit=8, then make UE3 exit idle.
    ...      e.all UE detach.
    ...    4.Check Points
    ...      for stepd:modification take effect on UE3,UE3 ics fail.
    [Tags]    QC_305522    owner-kexin.bao
    ICS Without PDU    ue_id=1    cell_id=2    fail_regexp=mcs-Table qam64LowSE
    Make UE In Idle    ue_id=2    cell_id=2    pass_regexp=mcs-Table qam64LowSE
    Exit idle    ue_id=2
    Make UE In Idle    ue_id=3    cell_id=2    pass_regexp=mcs-Table qam64LowSE
    OnlineParamChange    NRCELL:maxGBRTrafficLimit=8
    Exit idle Fail    ue_id=3
    Release All UEs    ue_id_start=1    ue_id_end=3
    check wireshark log    ${CURDIR}${/}a2a_CB008246_M07${/}a2a.ini    wait_string=UEContextReleaseComplete::16

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=2000 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7 default=on
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=9 5qi=80
    Update Cfg    set_qosflow id=10 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    ue_param id=1 ue_nr_capabilities=${normal_ue}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_Capa_Support_HR_PUSCH_TypeA_PDSCH_TypeA}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE_Capa_Support_HR_PUSCH_TypeA_PDSCH_TypeA}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${UE_Capa_Support_HR_PUSCH_TypeA_PDSCH_TypeA}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${pass_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_regexp}

ICS Without PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${fail_regexp}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=10,9
    Execute Egate Command    qosflow_modify qos_flow=10 gfbr_ul=3000 gfbr_dl=3000
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    fail_regexp=${fail_regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    pdu=1    send_dl=3    send_ul=3    sleep_time=10s

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${pdu}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${send_dl}=30    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${pdu}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

Make UE In Idle
    [Arguments]    ${ue_id}    ${cell_id}    ${pass_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    pdu=1    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} by=amf cause=RN_successful_handover    UE Context Release Complete

Exit idle
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    Initial Context Setup Successful
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    pdu=1    send_dl=5    send_ul=3    sleep_time=10s

Exit idle Fail
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    cause RAN radio resources not available
    Verify Throuput    ue_id=2    qfi=2    pdu=1    Tput_dl=4.5    Tput_ul=2.7    sleep_time=10s
    Verify Throuput    ue_id=2    qfi=3    pdu=1    Tput_dl=4.5    Tput_ul=2.7    sleep_time=10s

Exit idle and Verify Tput
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    Initial Context Setup Successful
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Send And Verify Throuput    ue_id=${ue_id}    qfi=1    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    pdu=1    send_dl=5    send_ul=3    sleep_time=10s

Release All UEs
    [Arguments]    ${ue_id_start}    ${ue_id_end}
    FOR    ${i}    IN RANGE    ${ue_id_start}    ${ue_id_end}
        UE Deregister From gNB    ue_id=${i}
    END

Online Modify Step1
    Start To Capture Wireshark Log    I_06_01
    OnlineParamChange    ${online_modify_step1}
    Exit idle and Verify Tput    ue_id=3
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_I06${/}a2a_I06_01.ini    name=I_06_01    wait_string=ullaMcsMax64qamLowSERANK1HR::2

Online Modify Step2
    Start To Capture Wireshark Log    I_06_02
    OnlineParamChange    ${online_modify_step2}
    Exit idle and Verify Tput    ue_id=4
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_I06${/}a2a_I06_02.ini    name=I_06_02    wait_string=ullaMcsMax64qamLowSERANK2HR::2
