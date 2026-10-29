*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-qianqian.guo
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008246    release-SBTS24R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL:cellDepType=SA
...    delete:NRCELL:configuredEpsTac
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actUl256Qam=false
...    NRCELL:actDl256Qam=false
...    @{5qi76_related_modification}
...    @{5qi3_related_modification}
...    @{8246_related}
...    @{rac}
...    @{8698_related}

@{8698_related}
...    NRBTS:actDrbPreemption=true
...    NRCELL:actARPBasedAC=on
...    NRBTS:maxNumOfPreemptions=20
...    NRCELL:numOfRadioResReservForTempUse=1
...    NRCELL:preferNsaPreemption=false
...    NRCELL:allowEmergencyReservForTempUse=false
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120

@{8246_related}
...    @{bwp_profile}
...    @{PDSCHHRLA_PUSCHHRLA}
...    @{8246_cell_configuration}

@{bwp_profile}
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-14/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-1/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-14/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-54/PDCCH-1:alSelection=static

@{PDSCHHRLA_PUSCHHRLA}
#5qi=6
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
#5QI-76
...    NRBTS/NRDRB-18:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-18:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1

...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=130
...    NRBTS/NRPUSCHHRLA-1:ullaBlerTargetHR=1
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh64qam=7000
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-2:ullaBlerTargetHR=6
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh64qam=7000

#5qi=7
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
#5QI-8
...    NRBTS/NRDRB-13:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-13:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
#5QI-3
...    NRBTS/NRDRB-19:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-19:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2

...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=10
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=30
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=130
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=10
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=30
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=2
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=110

@{8246_cell_configuration}
...    NRCELL:actCceSplit=false
...    NRCELL:actLAForHiReliab=true
...    NRCELL:scalingStepdownHREnabled=true
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

@{5qi76_related_modification}
...    NRBTS/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
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
...    NRBTS/NRDRB-18:l2OHFactorUl=33
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
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=76
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

@{5qi3_related_modification}
...    NRBTS/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-19:actDddsReduction=false
...    NRBTS/NRDRB-19:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-19:actLostPduFastRetx=false
...    NRBTS/NRDRB-19:discardTimer=100ms
...    NRBTS/NRDRB-19:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-19:dlFlowControlAlgo=none
...    NRBTS/NRDRB-19:dscp=46
...    NRBTS/NRDRB-19:durationThresDiscardDl=40
...    NRBTS/NRDRB-19:durationThresDiscardUl=20
...    NRBTS/NRDRB-19:endMarkerTimer=2000
...    NRBTS/NRDRB-19:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-19:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-19:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-19:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-19:maxTransferDelayGbr=20
...    NRBTS/NRDRB-19:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-19:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-19:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-19:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-19:numSduDiscard=1
...    NRBTS/NRDRB-19:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-19:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-19:resType=GBR
...    NRBTS/NRDRB-19:rlcMode=RLC_UM
...    NRBTS/NRDRB-19:schedulWeight=1
...    NRBTS/NRDRB-19:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-19:volThresDiscardDl=8000
...    NRBTS/NRDRB-19:volThresDiscardUl=800
...    NRBTS/NRDRB-19:l2OHFactorDl=16
...    NRBTS/NRDRB-19:l2OHFactorUl=35
...    NRBTS/NRDRB-19:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-19:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-19:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-19:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-19:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-19:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-19:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-19:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-19:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-19:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-19:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB_5QI-9:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-19
...    NRBTS/NRDRB_MAC-6:delayTarget=50
...    NRBTS/NRDRB_MAC-6:lcgid=5
...    NRBTS/NRDRB_MAC-6:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-6:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-6:schedulPrio=5
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
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{rac}
...    NRCELL:actGBRAdmissionControl=GBRService
...    NRCELL:maxGBRTrafficLimit=30
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:maxNumPdschAllocationPerSlot=16
...    NRCELL:maxNumPuschAllocationPerSlot=16

@{regexp_1}
...    mcs-Table qam64LowSE
...    Setup QosFlow with QFI:1 5QI:5
...    Setup QosFlow with QFI:2 5QI:3

@{regexp_2}
...    AMF-1: UE CONTEXT RELEASE COMPLETE:
...    UE1: IS IDLE

@{regexp_3}
...    mcs-Table qam64LowSE
...    Setup QosFlow with QFI:1 5QI:5
...    Setup QosFlow with QFI:2 5QI:76

@{regexp_4}
...    mcs-Table qam64LowSE
...    AMF-1: UE CONTEXT RELEASE REQUEST:
...    Setup QosFlow with QFI:1 5QI:5
...    Setup QosFlow with QFI:2 5QI:3
...    UE2: IS IDLE

@{regexp_5}
...    AMF-1: UE CONTEXT RELEASE COMPLETE:
...    UE2: IS IDLE

@{regexp_6}
...    AMF-1: Received Initial Context Setup Failure from GNB-2 with cause RAN radio resources not available
...    AMF-1: UE CONTEXT RELEASE REQUEST:
...    AMF-1: UE CONTEXT RELEASE COMPLETE:

${UE_Capa_Support_HR_PDSCH_PUSCH}    SEPARATOR=
...    EDA09000575F5A13160003C420005824C5C00670F424026C9B0E7CC31E50B038260300C47007B8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B11B582308682041F28340125B262A82873E238
...    F180000000000000000009FFF000007FFC000005C0000E000BC3C46000E140000000B01020060234028174001300C68912244D8E7C3005011
...    9E82C003C1C1401C0C025007000602400406020000000003E008020000000100000200B036B2A68020800004B29282000032CA4A00A81D552
...    AAA16004800D028000020200400808020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

*** Test Cases ***
CB008246_L_06_High_reliability_DRB_setup_success_IWK_with_ARP_based_preemption
    [Documentation]
    ...    1.Description
    ...    To validates the gNB behavior when existing GBR bearer need to be pre-empted to allow GBR admission.
    ...    2.Configuration
    ...      a.SA,FDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.drb 5QI_76 is associated with NRPUSCHHRLA-1,and 5QI_3 is associated with NRPUSCHHRLA-2.
    ...      d.UE support Ul-64QAM-MCS-TableAlt and Dl-64QAM-MCS-TableAlt.
    ...      e.enable actDrbPreemption=true and actARPBasedAC=on
    ...      f. wtc configure 5qi76 arp=4 and 5qi3 arp=3
    ...    3.Test Steps
    ...      a.UE1 attach to target cell w default DRB 5QI5 and DRB 5qi3(arp=3).
    ...      b.trigger UE1 enter RRC idle
    ...      c.UE2 attach to target cell w default DRB 5QI5 and DRB 5qi76(arp=4).
    ...      d.trigger UE1 exit RRC idle to pre-empt resource of UE2.
    ...    4.Check Points
    ...      4.1 for step b:UE1 release for succesfull-handover
    ...      4.2 for step d:UE2 release due to pre-emption
    [Tags]    QC_323055    owner-qianqian.guo
    UE Attach To Target Cell    ue_id=1    cell_id=1    default_qos=5    regexp=${regexp_1}
    Send And Verify Throuput    ue_id=1    qfi=2    pdu=1    send_dl=10    send_ul=5    sleep_time=10s
    Trigger UE RRC IDLE    ue_id=1    regexp=${regexp_2}
    UE2 Attach To Target Cell    ue_id=2    cell_id=1    default_qos=5    regexp=${regexp_3}
    Trigger UE exit RRC IDLE    ue_id=1    regexp=${regexp_4}
    Send And Verify Throuput    ue_id=1    qfi=2    pdu=1    send_dl=10    send_ul=5    sleep_time=10s
    Release All UEs    ue_id_start=1    ue_id_end=2
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_L_06${/}a2a.ini    wait_string=UEContextReleaseComplete::12

CB008246_L_07_High_reliability_DRB_setup_failed_IWK_with_ARP_based_preemption
    [Documentation]
    ...    1.Description
    ...    To validates the gNB behavior when existing GBR bearer need to be pre-empted to allow GBR admission.
    ...    2.Configuration
    ...      a.SA,FDD
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true
    ...      c.drb 5QI_76 is associated with NRPUSCHHRLA-1,and 5QI_3 is associated with NRPUSCHHRLA-2
    ...      d.UE support Ul-64QAM-MCS-TableAlt and Dl-64QAM-MCS-TableAlt
    ...      e.enable actDrbPreemption=true and actARPBasedAC=on
    ...      f. wtc configure 5qi76 arp=4 and 5qi3 arp=3
    ...    3.Test Steps
    ...      a.UE2 attach to target cell w default DRB 5QI5 and DRB 5qi76(arp=4)
    ...      b.trigger UE2 enter RRC idle
    ...      c.UE1 attach to target cell w default DRB 5QI5 and DRB 5qi3(arp=3)
    ...      d.trigger UE2 exit RRC idle
    ...    4.Check Points
    ...      4.1 for step b:UE2 release for succesfull-handover
    ...      4.2 for step d:UE2 release for RAN radio resources not available
    [Tags]    QC_323412    owner-qianqian.guo
    UE2 Attach To Target Cell    ue_id=2    cell_id=1    default_qos=5    regexp=${regexp_3}
    Send Throuput to Peak    ue_id=2    qfi=2    pdu=1    send_dl=10    send_ul=10    sleep_time=10s
    Trigger UE RRC IDLE    ue_id=2    regexp=${regexp_5}
    UE Attach To Target Cell    ue_id=1    cell_id=1    default_qos=5    regexp=${regexp_1}
    Send Throuput to Peak    ue_id=1    qfi=2    pdu=1    send_dl=30    send_ul=30    sleep_time=10s
    Trigger UE exit RRC IDLE    ue_id=2    regexp=${regexp_6}
    Release All UEs    ue_id_start=1    ue_id_end=2
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_L_07${/}a2a.ini    wait_string=UEContextReleaseComplete::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/2cells_1T1F    ue_count=15

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 default=on priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=10 5qi=76 priority=4 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_Capa_Support_HR_PDSCH_PUSCH}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_Capa_Support_HR_PDSCH_PUSCH}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${default_qos}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${regexp}

Trigger UE RRC IDLE
    [Arguments]    ${ue_id}    ${regexp}
    Execute Egate Command     ue_ng_ctx_release id=${ue_id} by=amf cause=RN_successful_handover    pass_regexp=${regexp}
    Execute Egate Command     amf_ue_ics_param id=${ue_id} include_ue_capabilities=on

UE2 Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${default_qos}    ${regexp}
    sleep    10s    #sleep for UE stable
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=10
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${regexp}

Trigger UE exit RRC IDLE
    [Arguments]    ${ue_id}    ${regexp}
     Execute Egate Command    ue_im_exit id=${ue_id} by=ue    pass_regexp=${regexp}

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

Send Throuput to Peak
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${send_dl}=30    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    sleep    ${sleep_time}    sleep for Tput stable
    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave

Release All UEs
    [Arguments]    ${ue_id_start}    ${ue_id_end}
    FOR    ${i}    IN RANGE    ${ue_id_start}    ${ue_id_end}
        UE Deregister From gNB    ue_id=${i}
    END
