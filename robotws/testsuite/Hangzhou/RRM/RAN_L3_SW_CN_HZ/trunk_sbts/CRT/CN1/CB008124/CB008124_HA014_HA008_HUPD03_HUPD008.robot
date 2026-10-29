*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-xiaowen.xu
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS24R4
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG}
...    @{bitmap_level}
...    @{ULCG_TYPE2}

@{bitmap_level}
...    0x58057A=3
@{ULCG_TYPE2}
...    0x58057E=0x200

@{PARAMS_IN_SCF}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    @{interFreqintragnbANR}
...    @{8124_ulcg}
@{interFreqintragnbANR}
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480

...    NRBTS/NRANR-1:actAutoEutraNbRemoval=false
...    NRBTS/NRANR-1:actAutoNrNbRemoval=true
...    NRBTS/NRANR-1:consecHoFailThres=0
...    NRBTS/NRANR-1:consecHoFailThresEutra=3
...    NRBTS/NRANR-1:consecXnResolveFailThres=3
...    NRBTS/NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRBTS/NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRBTS/NRANRPR-2:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-2:anrThresRsrqNbCell=-48
...    NRBTS/NRANRPR-2:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-2:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRBTS/NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-2:nrarfcn=636666
...    NRBTS/NRANRPR-2:ssbFrequency=636576

...    NRBTS:actDedicatedAnrDrxProfile=true
...    delete:NRCELL-1/NRREL-1
...    NRCELL-1:drxProfileNrAnr:drxControl=intraNRSAinterFreq
...    NRCELL-1:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-1:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-1:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-1:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfileNrAnr:drxRetransTimerUl=0slot

...    NRCELL-1:nrarfcn=634600
...    NRCELL-1:gscnOrSsPbchArfcn=7859
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=636576
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=6

@{8124_ulcg}
...    NRCELL:actUlCgType2=true
...    NRCELL:actCDrx=true
...    NRCELL:drxProfile1:drxInactivityTimer=50ms
...    NRCELL:drxProfile1:drxLongCycle=40ms
...    NRCELL:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
#...    NRCELL:ulConfiguredGrantType2:cgDrxHarqRttTimerUl=14       #cg
#...    NRCELL:ulConfiguredGrantType2:cgDrxRetransTimerUl=slots2     #cg
...    NRCELL:drxProfile1:drxHarqRttTimerUl=14symbols
...    NRCELL:drxProfile1:drxRetransTimerUl=2slot
...    NRCELL:actDrxRetransTimerSupport=true
...    NRBTS/NRDRB-17:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-22:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-23:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-24:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-25:cellAggrLevel=Not FR1 CA eligible
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=12
...    NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=104
...    NRCELL:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=8
...    NRCELL:maxGBRTrafficLimit=3
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actGBRAdmissionControl=GBRService
...    NRBTS:actFdmScheduling=true
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:maxNumPdschAllocationPerSlot=16
...    NRCELL:maxNumPuschAllocationPerSlot=16
...    NRBTS/NRX2LINK_TRUST-257:ipV4Addr=10.0.1.12
...    NRBTS/NRX2LINK_TRUST-257:x2LinkTrustCtrl=gnbControlled

...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=15000
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-4:grantedPacketSize=15000
...    NRBTS/NRULCG_PROFILE-4:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-4:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-6:grantedPacketSize=3000
...    NRBTS/NRULCG_PROFILE-6:maxNumPrbs=20
...    NRBTS/NRULCG_PROFILE-6:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-7:grantedPacketSize=3000
...    NRBTS/NRULCG_PROFILE-7:maxNumPrbs=20
...    NRBTS/NRULCG_PROFILE-7:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-8:grantedPacketSize=3000
...    NRBTS/NRULCG_PROFILE-8:maxNumPrbs=20
...    NRBTS/NRULCG_PROFILE-8:periodicity=ms10

...    NRBTS/NRDRB-22:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2    #2
...    NRBTS/NRDRB-24:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-4    #4
...    NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-6    #6
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-7    #71
...    NRBTS/NRDRB-18:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-8    #80

...    NRBTS/NRDRB_5QI-71:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_5QI-71:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-80:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-18
...    NRBTS/NRDRB_5QI-80:fiveqiValueList=80
...    NRBTS/NRDRB_5QI-22:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-22
...    NRBTS/NRDRB_5QI-22:fiveqiValueList=2
...    NRBTS/NRDRB_5QI-23:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-23
...    NRBTS/NRDRB_5QI-23:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-24:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-24
...    NRBTS/NRDRB_5QI-24:fiveqiValueList=4

...    NRBTS/NRDRB-25:actDddsReduction=false
...    NRBTS/NRDRB-25:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-25:actLostPduFastRetx=false
...    NRBTS/NRDRB-25:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-25:discardTimer=100ms
...    NRBTS/NRDRB-25:dlAllowMinDelayLinkXxCalib=false
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

...    NRBTS/NRDRB-17:actDddsReduction=false
...    NRBTS/NRDRB-17:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-17:actLostPduFastRetx=false
...    NRBTS/NRDRB-17:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-17:discardTimer=100ms
...    NRBTS/NRDRB-17:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-17:dlFlowControlAlgo=none
...    NRBTS/NRDRB-17:dscp=46
...    NRBTS/NRDRB-17:durationThresDiscardDl=50
...    NRBTS/NRDRB-17:durationThresDiscardUl=20
...    NRBTS/NRDRB-17:endMarkerTimer=2000
...    NRBTS/NRDRB-17:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-17:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-17:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-17:numSduDiscard=1
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_UM
...    NRBTS/NRDRB-17:rlcPduDelayThCa=30
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:volThresDiscardDl=8000
...    NRBTS/NRDRB-17:volThresDiscardUl=800
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=35

...    NRBTS/NRDRB-18:actDddsReduction=false
...    NRBTS/NRDRB-18:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-18:actLostPduFastRetx=false
...    NRBTS/NRDRB-18:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-18:discardTimer=infinity
...    NRBTS/NRDRB-18:dlAllowMinDelayLinkXxCalib=false
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
...    delete:NRBTS/NRDRB-18.nsaDrbParam-1.dlPreferredPath
...    NRBTS/NRDRB-18:nsaDrbParam:ulDataSplitThreshold=infinity

...    NRBTS/NRDRB-22:actDddsReduction=false
...    NRBTS/NRDRB-22:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-22:actLostPduFastRetx=false
...    NRBTS/NRDRB-22:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-22:discardTimer=100ms
...    NRBTS/NRDRB-22:dlAllowMinDelayLinkXxCalib=false
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
...    NRBTS/NRDRB-23:dlAllowMinDelayLinkXxCalib=false
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
...    NRBTS/NRDRB-24:dlAllowMinDelayLinkXxCalib=false
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


${UL_CG_ACT_ATT}    M55308C00020    #This counters provides the number of initial activation attempts of
#UL grant Type 2 scheduling sent through the PDCCH in DCI format 0_1.
${UL_CG_ACT_ATT_SUCC}    M55308C00021    #This counters provides the number of successful activation attempts of
#UL grant Type 2 scheduling sent through the PDCCH in DCI format 0_1.
${UL_CG_DEACT_ATT}    M55308C00022     #This counters provides the number of initial deactivation attempts of
#UL grant Type 2 scheduling sent through the PDCCH in DCI format 0_0.
${UL_CG_DEACT_ATT_SUCC}    M55308C00023     #This counters provides the number of successful deactivation attempts of
#UL grant Type 2 scheduling sent through the PDCCH in DCI format 0_0.
${CG_INI_TX_PUSCH_UNSUCC}    M55308C00027    #The counter provides the sum of CG initial transmissions on the
#PUSCH unsuccessfully received by the gNB during the measurement period.
${CG_RE_TX_PUSCH_SUCC}    M55308C00029     #The counter provides the sum of CG retransmissions on the PUSCH
#successfully received on the gNB during the measurement period.
${CG_RE_TX_PUSCH_UNSUCC}    M55308C00030    #The counter provides the sum of CG retransmissions on the PUSCH
#unsuccessfully received on the gNB during the measurement period.

${STA_UNAVAIL_NRREL_HO_FAILS}    M55147C00022
#Handover Failure due to dynamic unavailability per NR neighbour relationship

@{Counters_for_CG_activated_and_ANR_failed}
...    NRCELL-1:NMOCU:${STA_UNAVAIL_NRREL_HO_FAILS}=1
...    NRCELL-2:NMOCU:${STA_UNAVAIL_NRREL_HO_FAILS}=0
...    NRCELL-1:${UL_CG_ACT_ATT_SUCC}=1

@{Counters_for_CG_HA008}
...    NRCELL-2:${UL_CG_ACT_ATT_SUCC}=1

@{Counters_for_CG_UPD003}
...    NRCELL-1:${UL_CG_ACT_ATT_SUCC}=7
...    NRCELL-2:${UL_CG_ACT_ATT_SUCC}=1
...    NRCELL-1:${UL_CG_DEACT_ATT_SUCC}>=1

@{Counters_for_CG_UPD008}
...    NRCELL-1:${UL_CG_ACT_ATT_SUCC}>=2

@{expect}
...    QoS Routing Table
...    configuredGrantConfig setup

@{pass_regexp_ANR}
...    PDU Session Resource Setup with PDU Session ID 2 was unsuccessful due to RAN xn handover triggered
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
...    drx-Config setup
...    drx-RetransmissionTimerUL sl2
...    drx-HARQ-RTT-TimerUL 14

@{online_modify_UPD03_HO_CG_DRB_8698}
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=634560
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms1024
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=6
...    NRBTS/NRCELL:addGbrTrafficHo=0
...    NRBTS/NRCELL:measGapSelectionSA=favourUeThroughput

...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=104
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=8
...    NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=20
...    NRCELL:maxGBRTrafficLimit=17
...    NRBTS/NRULCG_PROFILE-10:grantedPacketSize=2000
...    NRBTS/NRULCG_PROFILE-10:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-10:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-3:grantedPacketSize=1875
...    NRBTS/NRULCG_PROFILE-3:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-3:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-4:grantedPacketSize=7500
...    NRBTS/NRULCG_PROFILE-4:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-4:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-6:grantedPacketSize=6750
...    NRBTS/NRULCG_PROFILE-6:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-6:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-7:grantedPacketSize=8000
...    NRBTS/NRULCG_PROFILE-7:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-7:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-8:grantedPacketSize=7000
...    NRBTS/NRULCG_PROFILE-8:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-8:periodicity=ms20
...    NRBTS/NRDRB-12:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-7
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-8
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-10
...    NRBTS/NRDRB-23:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-3
...    delete:NRBTS/NRDRB-18:nrDrbUlCgDN
...    delete:NRBTS/NRDRB-22:nrDrbUlCgDN
...    NRBTS/NRDRB_5QI-70:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_5QI-70:fiveqiValueList=170
...    delete:NRBTS/NRDRB_5QI-71

...    NRBTS/NRDRB-17:discardTimer=infinity
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-17:dscp=0
...    NRBTS/NRDRB-17:durationThresDiscardDl=40
...    delete:NRBTS/NRDRB-17:maxDataRateGbrDl
...    delete:NRBTS/NRDRB-17:maxDataRateGbrUl
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2

...    NRBTS/NRDRB-17:resType=nonGBR
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

...    NRBTS:actUserPreemption=true
...    NRBTS:actDrbPreemption=true
...    NRBTS:maxNumOfPreemptions=20
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=0
...    NRBTS/NRCELL:allowEmergencyReservForTempUse=false
...    NRBTS/NRCELL:numOfRadioResReservForTempUse=0
...    NRBTS/NRCELL:preferNsaPreemption=false


@{online_recovery_UPD03}
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=12
...    NRCELL:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=8
...    NRCELL:maxGBRTrafficLimit=3
...    NRBTS/NRULCG_PROFILE-4:grantedPacketSize=15000
...    NRBTS/NRULCG_PROFILE-4:maxNumPrbs=52
...    NRBTS/NRULCG_PROFILE-4:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-6:grantedPacketSize=3000
...    NRBTS/NRULCG_PROFILE-6:maxNumPrbs=20
...    NRBTS/NRULCG_PROFILE-6:periodicity=ms10
...    NRBTS/NRULCG_PROFILE-7:grantedPacketSize=3000
...    NRBTS/NRULCG_PROFILE-7:maxNumPrbs=20
...    NRBTS/NRULCG_PROFILE-7:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-8:grantedPacketSize=3000
...    NRBTS/NRULCG_PROFILE-8:maxNumPrbs=20
...    NRBTS/NRULCG_PROFILE-8:periodicity=ms10
...    NRBTS/NRDRB-22:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2    #2
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-7    #71
...    NRBTS/NRDRB-18:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-8    #80
...    delete:NRBTS/NRDRB-12:nrDrbUlCgDN
...    delete:NRBTS/NRDRB-13:nrDrbUlCgDN
...    delete:NRBTS/NRDRB-23:nrDrbUlCgDN
...    NRBTS/NRDRB_5QI-71:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_5QI-71:fiveqiValueList=71
...    delete:NRBTS/NRDRB_5QI-70

...    NRBTS/NRDRB-17:discardTimer=100ms
...    NRBTS/NRDRB-17:dlFlowControlAlgo=none
...    NRBTS/NRDRB-17:dscp=46
...    NRBTS/NRDRB-17:durationThresDiscardDl=50
...    NRBTS/NRDRB-17:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-17:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U

...    NRBTS:actUserPreemption=false
...    NRBTS:actDrbPreemption=false
...    delete:NRDU-1:numOfDrbsReservForTempUse
...    delete:NRCELL:allowEmergencyReservForTempUse
...    delete:NRCELL:numOfRadioResReservForTempUse
...    delete:NRCELL:preferNsaPreemption

...    delete:NRCELL-2/NRHOIF-1
...    NRCELL-2:a1MeashoEnabledSA=none
...    NRCELL-2:a2MeashoEnabledSA=none

@{online_modify_init_GBR_resource_HUPD008}
...    NRCELL:maxGBRTrafficLimit=1
...    delete:NRBTS/NRDRB-18:nrDrbUlCgDN    #5qi80

@{online_modify_HUPD008}
...    NRCELL:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=30
...    NRCELL:maxGBRTrafficLimit=12
...    NRBTS:actDrbPreemption=true
...    NRBTS:actUserPreemption=true
...    NRBTS:maxNumOfPreemptions=20
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=0
...    NRBTS/NRCELL:allowEmergencyReservForTempUse=false
...    NRBTS/NRCELL:numOfRadioResReservForTempUse=0
...    NRBTS/NRCELL:preferNsaPreemption=false
...    NRBTS/NRULCG_PROFILE-4:grantedPacketSize=3750
...    NRBTS/NRDRB_5QI-70:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-25
...    NRBTS/NRDRB_5QI-70:fiveqiValueList=72

@{online_recover_HUPD008}
...    NRCELL:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=8
...    NRCELL:maxGBRTrafficLimit=3
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRBTS/NRDRB-18:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-8    #80
...    delete:NRBTS:maxNumOfPreemptions
...    delete:NRBTS/NRDU-1:numOfDrbsReservForTempUse
...    delete:NRBTS/NRCELL:allowEmergencyReservForTempUse
...    delete:NRBTS/NRCELL:numOfRadioResReservForTempUse
...    delete:NRBTS/NRCELL:preferNsaPreemption
...    NRBTS/NRULCG_PROFILE-4:grantedPacketSize=15000
...    delete:NRBTS/NRDRB_5QI-70

*** Test Cases ***
CB008124_HA014_inter-freq ANR DRX setup after non-GBR DRB with CG profile setup
    [Documentation]
    ...    1. This scenario describes the gNB behaviour associated with blocking of ANR NRCGI measurements activation
    ...    for UE with Configured Grant Type 2 already setup.
    ...    Configuration for ANR DRX Shall be failed as CG type2 already configured for UE.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_6 is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU and then setup PDU session.5QI_6 is setup with CG2.
    ...    b.UE CGconfigured.
    ...    c.only start DL traffic , no cg activated.
    ...    d.trigger interFreANR.
    ...    e.HO failed , A2 reconfigured .
    ...    f.start ul traffic , cg activated.
    ...    g.UE detach.
    [Tags]    QC_280317    owner-xiaowen.xu    HA14
    clear counter files    wait=${False}
    ICS Without PDU    ue_id=1    cell_id=1
    Send DL Throughput and no CGACTIVATED     ue_id=1    pdu=1    qfi=1
    Trigger interFreANR Failure    ue_id=1
    Send UL Throughput    ue_id=1    pdu=1    qfi=1
    UE Deregister From gNB    ue_id=1
    check counters    ${Counters_for_CG_activated_and_ANR_failed}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_HA14${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_HA008_non-GBR DRB with CG profile setup rejected within inter-freq ANR HO
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behaviour needed to configure Configured Grant Type 2 for UE
    ...    which already has activated ANR NRCGI measurements.
    ...    gnb shall reject PDU Session Resource Setup during ANR PCI resolution.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_6 and drb 5QI_80 is associated with NRULCG_PROFILE.drb 5QI_7 is not
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach to cell1 without PDU and then setup PDU session.5QI_7 is setup without CG2.
    ...    b.UE try to trigger intraNRinterFreq ANR HO to cell2.
    ...      Make UE to send_pdu_session_with_DRB80 during PCI resolution.
    ...      The second PDU should be reject due on going PCI resolution (after reportCGI received)
    ...      ANR HO should be no impact and successfully.
    ...      check DRX setup and no cg
    ...    c.Trigger 5QI-80 setup with new pdu , CG should configured and activated , and DRX no changed.
    [Tags]    QC_280323    owner-xiaowen.xu    HA08
    clear counter files
    ICS Without PDU    ue_id=1    cell_id=1    qos_flow=7    pdu=1
    ...    pass_regexp=QoS Routing Table    fail_regexp=configuredGrantConfig setup
    Send DL Throughput     ue_id=1    pdu=1    qfi=1
    Trigger interFreANR with the concurrency    ue_id=1
    Send UL Throughput    ue_id=1    pdu=1    qfi=1
    PDU_Session_setup    ue_id=1    qos_flow=80    pdu=3    pass_regexp=configuredGrantConfig setup
    ...    fail_regexp=drx-Config setup
    UE Deregister From gNB    ue_id=1
    check counters    ${Counters_for_CG_HA008}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_HA08${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_UPD003_multi_CG2_HO_preemption
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behavior when Configured Grant Type 2 
    ...    PRB usage need to be reduced prior to existing bearer preemption to allow GBR admission.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.online modify SCF: HO related, CG configuration and DRB configuration, and enable 8698
    ...      online moddify CGF:qos_flow=2 gfbr_ul=20000,qos_flow=3 gfbr_ul=1500,qos_flow=4 gfbr_ul=6000 and preempable
    ...    b.GBR UE5/6/7 attach to cell1 and cell2
    ...      UE5 attach to cell1 w 5QI_80.add nww DRB w 5QI_2. UL. CG not configured
    ...      UE6 attach to cell2 w 5QI_80. add new DRB w 5QI_3. DL. CG configured.
    ...      UE7 attach to cell2 w 5QI_80. add new DRB w 5QI_4. DL. CG configured and activated
    ...    c.non-GBR UE1/2/3/4 attach to cell1
    ...      UE1 w 5QI_6 and UL. CG configured and activated.
    ...      UE2 w 5QI_7 and UL. CG configured and activated.
    ...      UE3 w 5QI_8 and UL. CG configured and activated.
    ...      UE4 attach to cell1 w 5QI_170 and DL. CG configured.
    ...    d.UE6 HO from cell2 to cell, no preemption happens. CG configured for UE6. others no change.
    ...    e.UE7 HO from cell2 to cell, preemption heppens. CG deactived for UE1 and UE2.
    ...    f.start UL traffic for UE4 and UE6. CG not actived as suspend in step e
    ...    g.modify GFBR for UE7
    ...      decrease UL GFBR for UE7 from 6000 to 1000, CG for UE1/2/4/6 activated.
    ...      release UE4 and UE6 to release some TD resources for next step.
    ...      increase UL GFBR from 1000 to 1500, preemption heppens. CG deactived for UE1.
    ...    h.release all UEs
    [Tags]    QC_285026    owner-jiadan.wu    UPD003
    clear counter files
    Online Modify SCF and CFG
    UE5GBR without CG UE6UE7GBR with CGconfig
    UE1UE2UE3UE4 NoneGBR with CGconfig
    UE6 HO from cell2 to cell1
    UE7 HO from cell2 to cell1
    UE4UE6 Send UlTraffic
    Modify GFBR for UE7
    Check Counters AND Wireshark
    [Teardown]    OlineRcoverySCFandCFG

CB008124-ET-HUPD008_GBR preemption with cg2 prb larger than GFBR
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behavior when Configured Grant Type 2 PRB usage need to be reduced 
    ...    prior to existing bearer preemption to allow GBR admission.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE1UE2 attach to cell-1 with 5QI-80 as default DRB1, then add GBR DRB2 with 5QI-71,and start UL traffic on this DRB2.
    ...    Due to insufficient resources, trigger gbrCgType2Action suspend to init GBR resource then deregister UE1UE2.
    ...    b.UE1 attach to cell-1 with 5QI-80 as default DRB1, then add GBR DRB2 with qosflow4,5QI-4
    ...    and NRULCG_PROFILE-4 with grantedPacketSize 3750.
    ...    start UL traffic on this DRB2.CG configured and activate.
    ...    c.UE2 attach to cell-1 with 5QI-80 as default DRB1, then add GBR DRB2 with qosflow10,5QI-71
    ...    and NRULCG_PROFILE-7 with grantedPacketSize 3000.start UL traffic on this DRB2.
    ...     DRB2 setup successfully,no CG active due to CG is smaller than GFBR18000.
    ...    d.UE3 attach to cell-1 with 5QI-80 as default DRB1, then add GBR DRB2 with qosflow11,5QI-72
    ...    no CG profile and start UL traffic on this DRB2.
    ...     check UE1 released,DRB2 setup successfully,no CG configured on UE3 and gbrCgType2Action suspend.
    ...    e.UE4 attach to cell-1 with non-GBR DRB1,qosflow6,5QI-6
    ...    and NRULCG_PROFILE-6 with grantedPacketSize 3000 and start UL traffic on this DRB1.
    ...    CG configured and activate.nonGBR CG will not be affected by gbrCgType2Action suspend.
    [Tags]    QC_285022    owner-jia.pan    HUPD008
    clear counter files
    Online Modify SCF and CFG for UPD008 init
    UE1GBR with CG active
    UE2GBR without CG
    UE3GBR with CG
    UE4nonGBR with CG active
    check counters    ${Counters_for_CG_UPD008}
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_HUPD008${/}a2a.ini    wait_string=UEContextReleaseComplete::28
    Oline Rcovery SCF and CFG for UPD008

*** Keywords ***
Online Modify SCF and CFG for UPD008 init
    Delta Commission Parameters    ${online_modify_init_GBR_resource_HUPD008}
    ICS without CG    1    1    9
    ADD new DRB for init
    Send UL Throughput kbps    1    2    18000
    ICS without CG    2    1    9
    ADD new DRB for init    2    10
    Send UL Throughput kbps    2    2    18000
    Release UEs    ue_type=all
    Online Modify SCF and CFG for UPD008

Online Modify SCF and CFG for UPD008
    Delta Commission Parameters    ${online_modify_HUPD008}
    Modify Cfg UPD008

Oline Rcovery SCF and CFG for UPD008
    Delta Commission Parameters    ${online_recover_HUPD008}
    Cfg Recovery UPD008

UE1GBR with CG active
    ICS without CG    1    1    9
    ADD new DRB    1    4
    Send UL Throughput kbps    1    2    3000 
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL kbps    1    2    2400

UE2GBR without CG
    ICS without CG    2    1    9
    ADD new DRB    2    10
    Send UL Throughput kbps    2    2    18000  
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL kbps    2    2    14400

UE3GBR with CG
    ICS without CG    3    1    9
    ADD new DRB    3    11
    Send UL Throughput kbps    3    2    3000 
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL kbps    3    2    2400

UE4nonGBR with CG active
    ICS with CG    4    1    6
    Send UL Throughput kbps    4    1    2400 
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL kbps    4    1    1920

Send UL Throughput kbps
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${ul}=4    
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} dir=ul kbps=${ul} trf_id=1    UE ${ue_id}: UDP UL

Check Throughput for UL kbps
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${TP_ul}=1
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput} >= ${TP_ul}

ADD new DRB for init
    [Arguments]    ${ue_id}=1    ${qos}=10
    ${ret}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=${qos} by=amf    Adding QosFlow

ADD new DRB
    [Arguments]    ${ue_id}=5    ${qos}=2
    ${ret}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=${qos} by=amf    Added QosFlow

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    Update Cfg    ue_param id=1-10 ue_nr_capabilities=${SA_Capa_nonca_FULL}
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    ${qosflow2}    catenate    set_qosflow id=2 5qi=2 gfbr_ul=12000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ...    pci=may_trigger_pre_emption pvi=pre_emptable priority=2
    Update Cfg    ${qosflow2}
    ${qosflow3}    catenate    set_qosflow id=3 5qi=3 gfbr_ul=12000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ...    pci=may_trigger_pre_emption pvi=pre_emptable priority=3
    Update Cfg    ${qosflow3}
    ${qosflow4}    catenate    set_qosflow id=4 5qi=4 gfbr_ul=12000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ...    pci=may_trigger_pre_emption pvi=pre_emptable priority=4
    Update Cfg    ${qosflow4}
    ${qosflow10}    catenate    set_qosflow id=10 5qi=71 gfbr_ul=18000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ...    pci=may_trigger_pre_emption pvi=pre_emptable priority=2
    Update Cfg    ${qosflow10}
    ${qosflow11}    catenate    set_qosflow id=11 5qi=72 gfbr_ul=3000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ...    pci=may_trigger_pre_emption pvi=pre_emptable priority=1
    Update Cfg    ${qosflow11}
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6 pci=may_trigger_pre_emption pvi=pre_emptable default=on priority=8
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=9 5qi=80 pci=may_trigger_pre_emption pvi=pre_emptable priority=8
    Update Cfg    set_qosflow id=17 5qi=170 pci=may_trigger_pre_emption pvi=pre_emptable #UPD003

Modify Cfg UPD008
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=1500 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720

Cfg Recovery UPD008
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=12000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720

Trigger interFreANR Failure
    [Arguments]    ${ue_id}    ${target_cell}=51
    ${meas_id_A2}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=634560    event_type=A2
    ...    threshold=34
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=10 srsrq_nr=10
    ...    rrcReconfigurationComplete
    ${meas_id_A3}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A3
    ${cmd1}=    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=5 srsrq_nr=5
    ${cmd2}=    Set Variable    phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
    ${cmd_HO}=    Catenate    ${cmd1}    ${cmd2}
    Execute Egate Command    ${cmd_HO}
    ...    pass_regexp=rrcReconfigurationComplete
    ...    fail_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

Trigger interFreANR with the concurrency
    [Arguments]    ${ue_id}    ${target_cell}=51    ${action}=send_nas_pdu_session_setup    ${pduSessionInfo}=2:2:0:1
    ${meas_id_A2}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=634560    event_type=A2
    ...    threshold=34
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=10 srsrq_nr=10
    ...    rrcReconfigurationComplete
    ${meas_id_A3}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A3
    Execute Egate Command    qosflow_modify default=on qos_flow=9
    ${cmd_action}=    Catenate    action=${action} pduSessionInfo=${pduSessionInfo}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=100ms ${cmd_action}
    ${cmd1}=    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=5 srsrq_nr=5
    ${cmd2}=    Set Variable    phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
    ${cmd_HO}=    Catenate    ${cmd1}    ${cmd2}
    Execute Egate Command    ${cmd_HO}    pass_regexp=${pass_regexp_ANR}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

ICS Without PDU
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${qos_flow}=6    ${pdu}=1    ${pass_regexp}=@{expect}    ${fail_regexp}=None
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    PDU_Session_setup    ue_id=${ue_id}    qos_flow=${qos_flow}    pdu=${pdu}
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Execute Egate Command    amf_param id=1 send_ics_registration=off

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

PDU_Session_setup
    [Arguments]    ${ue_id}=1    ${qos_flow}=6    ${pdu}=1    ${pass_regexp}=None    ${fail_regexp}=None
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=${pdu} nwslice=1
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Send DL Throughput and no CGACTIVATED
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Send DL Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}

Send DL Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${mbps}=10    ${TP_dl}=6
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${mbps} trf_id=1    UE ${ue_id}: UDP DL
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for DL    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    TP_dl=${TP_dl}

Send UL Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${mbps}=10    ${TP_ul}=6
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${mbps} trf_id=1    UE ${ue_id}: UDP UL
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    TP_ul=${TP_ul}

Check Throughput for UL
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${TP_ul}=6
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000 >= ${TP_ul}

Check Throughput for DL
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${TP_dl}=6
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throughput}/1000 >= ${TP_dl}

UE5GBR without CG UE6UE7GBR with CGconfig
    ICS without CG    5    1    9
    ADD new DRB    5    2
    Send UL Throughput UDP003    5    2    23000
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    5    2    500
    UE6UE7 GBR with CG config

UE6UE7 GBR with CG config
    ICS without CG    6    2    9
    ADD new DRB    6    3
    Send DL Throughput UDP003    6    2    800
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for DL UPD003    6    2    500
    ICS without CG    7    2    9
    ADD new DRB    7    4
    Send UL Throughput UDP003    7    2    6000
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    7    2    500

Check Throughput for UL UPD003
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${TP_ul}=1
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput} >= ${TP_ul}

Check Throughput for DL UPD003
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${TP_dl}=1
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throughput} >= ${TP_dl}
    
Send DL Throughput UDP003
    [Arguments]    ${ue_id}=4    ${qfi}=1    ${dl}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} dir=dl kbps=${dl} trf_id=1    UE ${ue_id}: UDP DL

Send UL Throughput UDP003
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${ul}=4    
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} dir=ul kbps=${ul} trf_id=1    UE ${ue_id}: UDP UL

UE1UE2UE3UE4 NoneGBR with CGconfig
    ICS with CG
    Send UL Throughput UDP003    1    1    2700
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    1    1    500
    ICS with CG    2    1    7
    Send UL Throughput UDP003    2    1    3200
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    2    1    500
    ICS with CG    3    1    8
    Send UL Throughput UDP003    3    1    2800
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    3    1    500
    UE4 NoneGBR with CGconfig

UE4 NoneGBR with CGconfig
    ICS with CG    4    1    17
    Send DL Throughput UDP003    4    1    800
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for DL UPD003    4    1    500

UE4UE6 Send UlTraffic
    Send UL Throughput UDP003    4    1    800
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    4    1    500
    Send UL Throughput UDP003    6    2    1500
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    6    2    500

Modify GFBR for UE7
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=1000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    ue_pdu_session_modify ue=7 pdu=7 qosflows_to_modify=4 by=amf    NAS Transport Message
    Send UL Throughput UDP003    7    2    1000
    sleep    5s    #wait for traffic stable
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    7    2    500
    UE deregister
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=1500 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    ue_pdu_session_modify ue=7 pdu=7 qosflows_to_modify=4 by=amf    NAS Transport Message
    Send UL Throughput UDP003    7    2    1500
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    7    2    1200

UE deregister
    sleep    10s    #wait for last step traffic stable
    UE Deregister From gNB    4
    UE Deregister From gNB    6
    sleep    10s    #wait for last step traffic stable

Trigger HO From Cell2 To Cell1
    [Arguments]    ${ue_id}    ${target_cell}=50
    ${meas_id_A2}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A2
    ...    threshold=34
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=10 srsrq_nr=10
    ...    rrcReconfigurationComplete
    ${meas_id_A3}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=634560    event_type=A3
    ${cmd1}=    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=5 srsrq_nr=5
    ${cmd2}=    Set Variable    phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
    ${cmd_HO}=    Catenate    ${cmd1}    ${cmd2}
    Execute Egate Command    ${cmd_HO}    pass_regexp=rrcReconfigurationComplete

UE6 HO from cell2 to cell1
    Trigger HO From Cell2 To Cell1    ue_id=6
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for DL UPD003    6    2    500

UE7 HO from cell2 to cell1
    Trigger HO From Cell2 To Cell1    ue_id=7
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL UPD003    7    2    500

Modify Cfg UPD003
    Execute Egate Command    qosflow_modify qos_flow=2 gfbr_ul=20000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    qosflow_modify qos_flow=3 gfbr_ul=1500 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=6000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    qosflow_modify qos_flow=7 5qi=7 pci=may_trigger_pre_emption pvi=pre_emptable
    Execute Egate Command    qosflow_modify qos_flow=8 5qi=8 pci=may_trigger_pre_emption pvi=pre_emptable

Cfg Recovery UPD003
    Execute Egate Command    qosflow_modify qos_flow=2 gfbr_ul=12000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    qosflow_modify qos_flow=3 gfbr_ul=12000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=12000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    Execute Egate Command    qosflow_modify qos_flow=7 5qi=7 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Execute Egate Command    qosflow_modify qos_flow=8 5qi=8 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Online Modify SCF and CFG
    Delta Commission Parameters    ${online_modify_UPD03_HO_CG_DRB_8698}
    Modify Cfg UPD003

Oline Rcovery SCF and CFG
    Cfg Recovery UPD003
    Delta Commission Parameters    ${online_recovery_UPD03}
    Common Test Teardown And Stop Capture Logs

Check Counters AND Wireshark
    check counters    ${Counters_for_CG_UPD003}
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_HUPD003${/}a2a.ini    wait_string=UEContextReleaseComplete::28
    
