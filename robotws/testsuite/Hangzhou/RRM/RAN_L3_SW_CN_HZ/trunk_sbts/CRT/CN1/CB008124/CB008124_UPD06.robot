*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-christine.chen
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG}
...    @{bitmap_level}
...    @{ULCG_TYPE2}
...    @{rdOverloadHysteresis}
@{bitmap_level}
...    0x58057A=3
@{ULCG_TYPE2}
...    0x58057E=0x200
@{rdOverloadHysteresis}
...    0x5901DF=0x4B

@{PARAMS_IN_SCF}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    @{8124_ulcg}
...    @{HO}
...    NRCELL:actUl256Qam=true
...    NRCELL:actDl256Qam=true

@{HO}
...    NRBTS:actIntraFreqHoSA=true
...    NRCELL:a3MeasEnabled=rsrp
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:addGbrTrafficHo=0

@{8124_ulcg}
...    NRBTS:actDrbPreemption=true
...    NRBTS:maxNumOfPreemptions=4
...    NRCELL:allowEmergencyReservForTempUse=true
...    NRCELL:numOfRadioResReservForTempUse=10
...    NRCELL:preferNsaPreemption=false
...    NRDU-1:numOfDrbsReservForTempUse=10
...    NRCELL:actUlCgType2=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actNonVoNRGbrService=true 
...    NRCELL:actGBRAdmissionControl=GBRService
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=104
...    NRBTS:actFdmScheduling=true
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:maxNumPdschAllocationPerSlot=16
...    NRCELL:maxNumPuschAllocationPerSlot=16
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=8
...    NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=21
...    NRCELL:maxGBRTrafficLimit=20
...    NRBTS/NRX2LINK_TRUST-257:ipV4Addr=10.0.1.12
...    NRBTS/NRX2LINK_TRUST-257:x2LinkTrustCtrl=gnbControlled
...    NRBTS/NRULCG_PROFILE-10:grantedPacketSize=2000
...    NRBTS/NRULCG_PROFILE-10:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-10:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=3750
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-3:grantedPacketSize=1250
...    NRBTS/NRULCG_PROFILE-3:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-3:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-4:grantedPacketSize=3750
...    NRBTS/NRULCG_PROFILE-4:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-4:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-6:grantedPacketSize=7500
...    NRBTS/NRULCG_PROFILE-6:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-6:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-7:grantedPacketSize=10000
...    NRBTS/NRULCG_PROFILE-7:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-7:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-8:grantedPacketSize=2500
...    NRBTS/NRULCG_PROFILE-8:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-8:periodicity=ms20
...    NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-6
...    NRBTS/NRDRB-12:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-7
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-8
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-10
...    NRBTS/NRDRB-24:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-4
...    NRBTS/NRDRB-25:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-3
...    NRBTS/NRDRB_5QI-70:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_5QI-70:fiveqiValueList=170
...    NRBTS/NRDRB_5QI-80:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-18
...    NRBTS/NRDRB_5QI-80:fiveqiValueList=80
...    NRBTS/NRDRB_5QI-22:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-22
...    NRBTS/NRDRB_5QI-22:fiveqiValueList=2
...    NRBTS/NRDRB_5QI-23:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-23
...    NRBTS/NRDRB_5QI-23:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-24:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-24
...    NRBTS/NRDRB_5QI-24:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-25:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-25
...    NRBTS/NRDRB_5QI-25:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-26:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-26
...    NRBTS/NRDRB_5QI-26:fiveqiValueList=72
...    NRBTS/NRDRB-17:actDddsReduction=false
...    NRBTS/NRDRB-17:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-17:actLostPduFastRetx=false
...    NRBTS/NRDRB-17:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-17:discardTimer=infinity
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-17:dscp=0
...    NRBTS/NRDRB-17:durationThresDiscardDl=40
...    NRBTS/NRDRB-17:durationThresDiscardUl=20
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
...    NRBTS/NRDRB-17:rlcPduDelayThCa=30
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:volThresDiscardDl=8000
...    NRBTS/NRDRB-17:volThresDiscardUl=800
...    NRBTS/NRDRB-17:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-17:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-17:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-17:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-17:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-17:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-17:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-17:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-17:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-17:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-17:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-18:actDddsReduction=false
...    NRBTS/NRDRB-18:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-18:actLostPduFastRetx=false
...    NRBTS/NRDRB-18:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-18:discardTimer=infinity
...    NRBTS/NRDRB-18:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-18:dscp=0
...    NRBTS/NRDRB-18:durationThresDiscardDl=40
...    NRBTS/NRDRB-18:durationThresDiscardUl=20
...    NRBTS/NRDRB-18:endMarkerTimer=2000
...    NRBTS/NRDRB-18:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-18:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-18:maxTransferDelayGbr=20
...    NRBTS/NRDRB-18:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-18:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-18:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-18:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-18:numSduDiscard=1
...    NRBTS/NRDRB-18:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-18:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-18:resType=nonGBR
...    NRBTS/NRDRB-18:rlcMode=RLC_UM
...    NRBTS/NRDRB-18:rlcPduDelayThCa=30
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
...    NRBTS/NRDRB-22:actDddsReduction=false
...    NRBTS/NRDRB-22:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-22:actLostPduFastRetx=false
...    NRBTS/NRDRB-22:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-22:discardTimer=100ms
...    NRBTS/NRDRB-22:dlFlowControlAlgo=none
...    NRBTS/NRDRB-22:dscp=46
...    NRBTS/NRDRB-22:durationThresDiscardDl=50
...    NRBTS/NRDRB-22:durationThresDiscardUl=20
...    NRBTS/NRDRB-22:endMarkerTimer=2000
...    NRBTS/NRDRB-22:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-22:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-22:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-22:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-22:maxTransferDelayGbr=20
...    NRBTS/NRDRB-22:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-22:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-22:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-22:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-22:numSduDiscard=1
...    NRBTS/NRDRB-22:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-22:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-22:resType=GBR
...    NRBTS/NRDRB-22:rlcMode=RLC_UM
...    NRBTS/NRDRB-22:rlcPduDelayThCa=30
...    NRBTS/NRDRB-22:schedulWeight=1
...    NRBTS/NRDRB-22:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-22:volThresDiscardDl=8000
...    NRBTS/NRDRB-22:volThresDiscardUl=800
...    NRBTS/NRDRB-22:l2OHFactorDl=16
...    NRBTS/NRDRB-22:l2OHFactorUl=35
...    NRBTS/NRDRB-23:actDddsReduction=false
...    NRBTS/NRDRB-23:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-23:actLostPduFastRetx=false
...    NRBTS/NRDRB-23:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-23:discardTimer=100ms
...    NRBTS/NRDRB-23:dlFlowControlAlgo=none
...    NRBTS/NRDRB-23:dscp=46
...    NRBTS/NRDRB-23:durationThresDiscardDl=50
...    NRBTS/NRDRB-23:durationThresDiscardUl=20
...    NRBTS/NRDRB-23:endMarkerTimer=2000
...    NRBTS/NRDRB-23:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-23:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-23:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-23:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-23:maxTransferDelayGbr=20
...    NRBTS/NRDRB-23:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-23:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-23:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-23:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-23:numSduDiscard=1
...    NRBTS/NRDRB-23:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-23:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-23:resType=GBR
...    NRBTS/NRDRB-23:rlcMode=RLC_UM
...    NRBTS/NRDRB-23:rlcPduDelayThCa=30
...    NRBTS/NRDRB-23:schedulWeight=1
...    NRBTS/NRDRB-23:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-23:volThresDiscardDl=8000
...    NRBTS/NRDRB-23:volThresDiscardUl=800
...    NRBTS/NRDRB-23:l2OHFactorDl=16
...    NRBTS/NRDRB-23:l2OHFactorUl=35
...    NRBTS/NRDRB-24:actDddsReduction=false
...    NRBTS/NRDRB-24:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-24:actLostPduFastRetx=false
...    NRBTS/NRDRB-24:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-24:discardTimer=100ms
...    NRBTS/NRDRB-24:dlFlowControlAlgo=none
...    NRBTS/NRDRB-24:dscp=46
...    NRBTS/NRDRB-24:durationThresDiscardDl=50
...    NRBTS/NRDRB-24:durationThresDiscardUl=20
...    NRBTS/NRDRB-24:endMarkerTimer=2000
...    NRBTS/NRDRB-24:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-24:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-24:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-24:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-24:maxTransferDelayGbr=20
...    NRBTS/NRDRB-24:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-24:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-24:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-24:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-24:numSduDiscard=1
...    NRBTS/NRDRB-24:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-24:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-24:resType=GBR
...    NRBTS/NRDRB-24:rlcMode=RLC_UM
...    NRBTS/NRDRB-24:rlcPduDelayThCa=30
...    NRBTS/NRDRB-24:schedulWeight=1
...    NRBTS/NRDRB-24:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-24:volThresDiscardDl=8000
...    NRBTS/NRDRB-24:volThresDiscardUl=800
...    NRBTS/NRDRB-24:l2OHFactorDl=16
...    NRBTS/NRDRB-24:l2OHFactorUl=35
...    NRBTS/NRDRB-25:actDddsReduction=false
...    NRBTS/NRDRB-25:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-25:actLostPduFastRetx=false
...    NRBTS/NRDRB-25:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-25:discardTimer=100ms
...    NRBTS/NRDRB-25:dlFlowControlAlgo=none
...    NRBTS/NRDRB-25:dscp=46
...    NRBTS/NRDRB-25:durationThresDiscardDl=50
...    NRBTS/NRDRB-25:durationThresDiscardUl=20
...    NRBTS/NRDRB-25:endMarkerTimer=2000
...    NRBTS/NRDRB-25:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-25:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-25:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-25:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-25:maxTransferDelayGbr=20
...    NRBTS/NRDRB-25:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-25:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-25:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-25:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-25:numSduDiscard=1
...    NRBTS/NRDRB-25:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-25:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-25:resType=GBR
...    NRBTS/NRDRB-25:rlcMode=RLC_UM
...    NRBTS/NRDRB-25:rlcPduDelayThCa=30
...    NRBTS/NRDRB-25:schedulWeight=1
...    NRBTS/NRDRB-25:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-25:volThresDiscardDl=8000
...    NRBTS/NRDRB-25:volThresDiscardUl=800
...    NRBTS/NRDRB-25:l2OHFactorDl=16
...    NRBTS/NRDRB-25:l2OHFactorUl=35
...    NRBTS/NRDRB-26:actDddsReduction=false
...    NRBTS/NRDRB-26:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-26:actLostPduFastRetx=false
...    NRBTS/NRDRB-26:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-26:discardTimer=100ms
...    NRBTS/NRDRB-26:dlFlowControlAlgo=none
...    NRBTS/NRDRB-26:dscp=46
...    NRBTS/NRDRB-26:durationThresDiscardDl=50
...    NRBTS/NRDRB-26:durationThresDiscardUl=20
...    NRBTS/NRDRB-26:endMarkerTimer=2000
...    NRBTS/NRDRB-26:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-26:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-26:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-26:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-26:maxTransferDelayGbr=20
...    NRBTS/NRDRB-26:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-26:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-26:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-26:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-26:numSduDiscard=1
...    NRBTS/NRDRB-26:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-26:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-26:resType=GBR
...    NRBTS/NRDRB-26:rlcMode=RLC_UM
...    NRBTS/NRDRB-26:rlcPduDelayThCa=30
...    NRBTS/NRDRB-26:schedulWeight=1
...    NRBTS/NRDRB-26:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-26:volThresDiscardDl=8000
...    NRBTS/NRDRB-26:volThresDiscardUl=800
...    NRBTS/NRDRB-26:l2OHFactorDl=16
...    NRBTS/NRDRB-26:l2OHFactorUl=35
...    NRBTS/NRDRB_MAC-4:lcgid=5
...    NRBTS/NRDRB_MAC-4:delayTarget=50
...    NRBTS/NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-4:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_PDCP-3:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-3:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms80
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms80
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{online_modify_init_GBR_resource}
...    NRCELL:maxGBRTrafficLimit=1
@{online_modify_init_GBR_resource_recovery}
...    NRCELL:maxGBRTrafficLimit=20

${UL_CG_ACT_ATT_SUCC}    M55308C00021
${UL_CG_DEACT_ATT_SUCC}    M55308C00023

@{Counters_for_CG_UPD06}
...    NRCELL-1:${UL_CG_DEACT_ATT_SUCC}=1
...    NRCELL-1:${UL_CG_ACT_ATT_SUCC}=2

@{expect}
...    QoS Routing Table
...    configuredGrantConfig setup

@{pduModifyCheck}
...    NAS Transport Message
...    UE4: IS IDLE

@{pduModifyCheck1}
...    NAS Transport Message
*** Test Cases ***
CB008124_UPD006_1_multi_DRB_HO_RRE_preemption
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behavior when Configured Grant Type 2 PRB usage need to be reduced prior to existing
    ...    bearer preemption to allow GBR admission.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_6 is associated with NRULCG_PROFILE.
    ...    d.UE1 with GBR 5QI80+5QI2, cg is not config
    ...    e.UE2 with GBR 5QI80+5QI72, cg is not config
    ...    f.UE3 with non-GBR 5QI7, cg is config
    ...    g.UE4 with GBR 5QI80+5QI72, cg is not config
    ...    h.maxGBRAndCgType2TrafficLimit=21 and NRCELL:maxGBRTrafficLimit=20
    ...    i.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE1 attach cell1, UE2 attach cell1. UE3 attach cell1
    ...    b.UE4 attach cell1
    ...    c.Modify 5QI-2 on UE1 to increase GFBR to GFBR2'.
    ...    d.Modify 5QI-2 on UE1 to decrease GFBR2' to GFBR.
    ...    e.UE detach.
    ...    4. Expect result:
    ...    a.UE1 UE2 UE3 attach successful, cg avtived for UE3.
    ...    b.UE3 CG deactived because UE4 attach and need more GbrUlResource, so UE4 will preemption nonGBR cg2 resource.
    ...    c.UE4 release because UE1 GFBR increased and 5QI2 has high priority, so UE1 will preemption low priority gbr resource.
    ...    d.UE3 CG actived because UE1 GFBR decreased and GbrUlResource is released, so UE3 cg2 resource resume.
    ...    e.UE detach.
    [Tags]    owner-christine.chen    UPD06_1    QC_285028
    clear counter files    wait=${False}
    UE1 UE2 GBR without CG config
    UE3 NoneGBR with CG config
    UE4 GBR 5QI72 without CG config
    Modify gfbr for UE1 big
    Modify gfbr for UE1 small
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_UPD06${/}a2a.ini    wait_string=UEContextReleaseComplete::20
    check counters    ${Counters_for_CG_UPD06}
    [Teardown]    Online Modify SCF and CFG for UPD006
CB008124_UPD006_2_multi_DRB_HO_RRE_preemption
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behavior when Configured Grant Type 2 PRB usage need to be reduced prior to existing
    ...    bearer preemption to allow GBR admission.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_6 is associated with NRULCG_PROFILE.
    ...    d.UE1 with GBR 5QI80+5QI2, cg is not config
    ...    e.UE2 with GBR 5QI80+5QI72, cg is not config
    ...    f.UE3 with non-GBR 5QI7, cg is config
    ...    g.UE4 with GBR 5QI80+5QI3, cg is not config
    ...    h.maxGBRAndCgType2TrafficLimit=21 and NRCELL:maxGBRTrafficLimit=20
    ...    i.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE1 attach cell1, UE2 attach cell1. UE3 attach cell1,UE4 attach cell1
    ...    b.Modify 5QI-2 on UE1 to increase GFBR to GFBR2'.
    ...    c.Modify 5QI-2 on UE1 to decrease GFBR2' to GFBR.
    ...    d.UE detach.
    ...    4. Expect result:
    ...    a.UE1 UE2 UE3 UE4 attach successful, cg avtived for UE3.
    ...    b.UE3 CG deactived, and UE4 release, because UE1 GFBR increased and 5QI2 has high priority, so UE1 will preemption nonGBR cg2 resource,
    ...    but cg2 resource is not enough, so need simultaneous preemption low priority gbr resource.
    ...    c.UE3 CG actived because UE1 GFBR decreased and GbrUlResource is released, so UE3 cg2 resource resume.
    ...    d.UE detach.
    [Tags]    owner-christine.chen    UPD06_2
    clear counter files
    UE1 UE2 GBR without CG config
    UE3 NoneGBR with CG config
    UE4 GBR 5QI3 without CG config
    Modify gfbr for UE1 big
    Modify gfbr for UE1 small
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_UPD06_2${/}a2a.ini    wait_string=UEContextReleaseComplete::20
    check counters    ${Counters_for_CG_UPD06}
    [Teardown]    Online Modify SCF and CFG for UPD006

*** Keywords ***
Online Modify SCF and CFG for UPD006
    Delta Commission Parameters    ${online_modify_init_GBR_resource}
    ICS without CG    ue_id=1    cell_id=1    qos_flow=18
    ADD new DRB for init    ue_id=1    qos=2
    Send UL Throughput    ue_id=1    qfi=2    ul=15000
    ICS without CG    ue_id=2    cell_id=1    qos_flow=18
    ADD new DRB for init    ue_id=2    qos=20
    Send UL Throughput    ue_id=2    qfi=2    ul=17000
    Release UEs    ue_type=all
    Delta Commission Parameters    ${online_modify_init_GBR_resource_recovery}
    Common Test Teardown And Stop Capture Logs

ADD new DRB for init
    [Arguments]    ${ue_id}=1    ${qos}=2
    ${ret}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=${qos} by=amf    Adding QosFlow

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE3 NoneGBR with CG config
    ICS with CG    ue_id=3    cell_id=1    qos_flow=7
    Send UL Throughput    ue_id=3    qfi=1    ul=8000
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=3    qfi=1    TP_ul=500

UE1 UE2 GBR without CG config
    ICS without CG    ue_id=1    cell_id=1    qos_flow=18
    ADD new DRB    ue_id=1    qos=2
    Send UL Throughput    ue_id=1    qfi=2    ul=15000
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    qfi=2    TP_ul=500
    ICS without CG    ue_id=2    cell_id=1    qos_flow=18
    ADD new DRB    ue_id=2    qos=20
    Send UL Throughput    ue_id=2    qfi=2    ul=17000
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=2    qfi=2    TP_ul=500

UE4 GBR 5QI72 without CG config
    ICS without CG    ue_id=4    cell_id=1    qos_flow=18
    ADD new DRB    ue_id=4    qos=20
    Send UL Throughput    ue_id=4    qfi=2    ul=17000
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=4    qfi=2    TP_ul=500
    sleep    5s    #wait for Bitrate=0

UE4 GBR 5QI3 without CG config
    ICS without CG    ue_id=4    cell_id=1    qos_flow=18
    ADD new DRB    ue_id=4    qos=3
    Send UL Throughput    ue_id=4    qfi=2    ul=10500
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=4    qfi=2    TP_ul=500
Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    ${qosflow2}    catenate    set_qosflow id=2 5qi=2 gfbr_ul=15000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ...    pci=may_trigger_pre_emption pvi=pre_emptable priority=1
    Update Cfg    ${qosflow2}
    ${qosflow3}    catenate    set_qosflow id=3 5qi=3 gfbr_ul=10500 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ...    pci=may_trigger_pre_emption pvi=pre_emptable priority=5
    Update Cfg    ${qosflow3}
    ${qosflow4}    catenate    set_qosflow id=4 5qi=4 gfbr_ul=3000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ...    pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    ${qosflow4}
    ${qosflow20}    catenate    set_qosflow id=20 5qi=72 gfbr_ul=17500 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ...    pci=may_trigger_pre_emption pvi=pre_emptable priority=4
    Update Cfg    ${qosflow20}
    Update Cfg    set_qosflow id=5 5qi=5 
    Update Cfg    set_qosflow id=6 5qi=6 pci=may_trigger_pre_emption pvi=pre_emptable default=on
    Update Cfg    set_qosflow id=7 5qi=7 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=8 5qi=8 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=19 5qi=71 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=17 5qi=170 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=18 5qi=80 pci=may_trigger_pre_emption pvi=pre_emptable

ICS with CG
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${qos_flow}=6
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_nonca_FULL}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${ue_id} gw=${ue_id} nwslice=1    pass_regexp=@{expect}
    Execute Egate Command    amf_param id=1 send_ics_registration=off

ADD new DRB
    [Arguments]    ${ue_id}=5    ${qos}=2
    ${ret}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=${qos} by=amf    Added QosFlow

ICS without CG
    [Arguments]    ${ue_id}=7    ${cell_id}=1    ${qos_flow}=80
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_nonca_FULL}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    ${cmd}=    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${ue_id} gw=${ue_id} nwslice=1
    Execute Egate Command    ${cmd}
    ...    pass_regexp=QoS Routing Table
    ...    fail_regexp=configuredGrantConfig setup
    Execute Egate Command    amf_param id=1 send_ics_registration=off

Send UL Throughput
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${ul}=4    
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} dir=ul kbps=${ul} trf_id=1    UE ${ue_id}: UDP UL

Check Throughput for UL
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${TP_ul}=1
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput} >= ${TP_ul}

Modify gfbr for UE1 big
    Execute Egate Command    qosflow_modify qos_flow=2 gfbr_ul=27000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=2 by=amf    pass_regexp=${pduModifyCheck}
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=2 dir=ul kbps=27000 trf_id=1    UE 1: UDP UL
    sleep    5s    #wait for Bitrate=0

Modify gfbr for UE1 small
    Execute Egate Command    qosflow_modify qos_flow=2 gfbr_ul=15000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=2 by=amf    pass_regexp=${pduModifyCheck1}
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=2 dir=ul kbps=15000 trf_id=1    UE 1: UDP UL

