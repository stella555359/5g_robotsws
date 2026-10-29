*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fdd_sansa_cmwv/2cells
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL-2:cellDepType=SA
...    delete:NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=60MHz
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actVoNR=true
...    @{8124_related_modification}
...    @{5qi80_related_modification}
...    @{5qi4_related_modification}
...    @{IntergNB_HO_relate}
...    @{HO_PARAMS_H13}
...    @{cipherPrefL}
...    @{CFRA_CONF}
...    @{SNSSAI}
...    @{TRACKINGAREA}
...    @{PLMN}

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:actUlCgType2=true
...    NRCELL-2:actUlCgType2=false
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #5qi=8
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #5qi=80
...    NRBTS/NRDRB-18:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2    #5qi=4
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=12
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms80
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=12
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=20
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=32
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=0

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

@{5qi4_related_modification}
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
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=4
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

@{IntergNB_HO_relate}
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:timerXnDataFwdGuard=250
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2:absThreshSsbRsrpConsolidation=0
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=35
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1
...    @{NRADJGNB}
...    @{NRADJNRCELL}
...    @{XN_Link}

@{NRADJGNB}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=35
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=2
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=71
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=126530
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=71
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=126530

@{XN_Link}
...    NRBTS:actIncXn=true
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.122
...    NRBTS/XNLINK-2:cPlaneIpAddrCtrl=oamControlled

@{HO_PARAMS_H13}
...    NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=11
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms320
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{SNSSAI}
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1
${SNSSAIDNLIST}    MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-2

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{CFRA_CONF}
...    NRBTS-1/NRCELL-1:cbraPreamblesPerSsb=n60
...    NRBTS-1/NRCELL-1:rsrpThresholdSSB=15

@{cipherPrefL}
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=3
...    NRBTS-1:cipherPrefL:nea2_128=6
...    NRBTS-1:cipherPrefL:nea3_128=9
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=3
...    NRBTS-1:integrityProtPrefL:nia2_128=6
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{OnlineParam_for_H05}
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms2
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=12
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms40
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=8
...    NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2    #5qi=6

@{OnlineParam_for_H05_recover}
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms80
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=12

@{OnlineParam_for_H13}
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2    #5qi=80
...    NRBTS/NRDRB-18:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #5qi=4
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=3000
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=12
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms2
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=100
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=12
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms80

${UE_Capa_Support_CG2_mac_phy}    SEPARATOR=
...    E1A01000016F0140502F01816041032001208367130F8509009B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D262A08FE59
...    49328240416C9824060C78C7FE618F28581C0E1E026761D86761D802001800000000388C00000000841808DC9A1F00E41000000A4100000
...    2A41000004A494000069805C0DBC8DADD200A0800004B29202000032CA480800014B29202000072CA4A0800024B292120000AA5949004D0
...    38BA471742A269544576204803C00D0080400000000001002004288A0

${UE_Capa_Support_CG2_mac_n71}    SEPARATOR=
...    E1A01000016F0140502F01816001032001208367130F8509009B0083FF30C7942C0E09804062280C0298C00A83E236B0C6D1D262A08FE59
...    49328240416C9824060C78C7FE618F28581C0E1E026761D86761D81201008401000C000000001C4600000000420C046E4D0F80720800000
...    520800001520800002524A000034C02E06DE46D6E900504000025949010000196524040000A594901000039652504000125949090000552
...    CA4802681C5D238BA15134AA22BB102401E006804020000000000080100214450

@{cg_active_regexp}
...    logicalChannelSR-Mask TRUE
...    cs-RNTI setup
...    configuredGrantConfig setup

@{cg_release_regexp}
...    cs-RNTI release
...    configuredGrantConfig release

@{PM_Counters_Check_H05}
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=2
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=1
...    NRCELL-1:RSADU:${CG_RES_ALLO_ATT_DU}=2

@{PM_Counters_Check_H08}
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=1
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=0
...    NRCELL-1:RSADU:${CG_RES_ALLO_ATT_DU}=1
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=0
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=0
...    NRCELL-2:RSADU:${CG_RES_ALLO_ATT_DU}=0

@{PM_Counters_Check_H13}
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=2
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=1
...    NRCELL-1:RSADU:${CG_RES_ALLO_ATT_DU}=2

${RRC_RECONF_CMP_CG_SETUP_RCVD}    M55166C00005
#No of RRC reconfiguration complete received with UL configured grant type2 setup
${RRC_RECONF_CMP_CG_RELEASE_RCVD}    M55166C00006
#No of RRC reconfiguration complete received with UL configured grant type2 release
${CG_RES_ALLO_ATT_DU}    M55139C00017
#the total number of UL-configured grant Type2 resource allocation attempts during the admission control

*** Test Cases ***
CB008124_H_08_FDDCG2off_DRB1CG2_VONR_intergNBHO_FDDCG2on_delVONR
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour associated with releasing of Configured UL Grants Type 2
    ...    for UE for which VONR(5qi=1) bearer is being setup, setup of Configured UL Grants Type 2 for UE for which
    ...    VONR(5qi=1) bearer is being released, and blocking setup of Configured UL Grants Type 2 for UE for which
    ...    VONR(5qi=1) bearer is already setup
    ...    2. Configuration
    ...    a.SA,FDD,NRCELL-2;SA+NSA,FDD,NRCELL-1
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL-1.actUlCgType2=true,NRBTS/NRCELL-2.actUlCgType2=false
    ...    c.5QI_8 is associated with NRULCG_PROFILE-1.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach on NRCELL-2.
    ...    b.setup 5QI_8 ,CG2 cannot be setup since feature is disabled on NRCELL-2.
    ...    c.setup VONR.
    ...    d.send A3 measurement, intergNB Xn HO to simGNB and HO back to NRCELL-1 successfully.
    ...    e.delete VONR, CG2 for 5QI_8 is setup.
    ...    f.UE detach.
    [Tags]    QC_281156    owner-kexin.bao
    Prepare For Test H08
    UE Attach To Target Cell    ue_id=1    cell_id=2
    Setup DRB wo CG    ue_id=1    qfi=2    pdu=1    qosflow=6    5qi=8    fail_regexp=configuredGrantConfig setup
    Setup VONR    ue_id=1     qfi=3    nextqfi=4    pdu=1
    Handover From gNB to Sim Should Success    ue_id=1    carrierfreq=126530    event_id=A3    phycell_id=381
    ...    regexp=Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed
    Handover From Sim to gNB Should Success    ue_id=1    carrierfreq=126530    event_id=A3    phycell_id=60
    ...    regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Delete VONR and Verify Tput    ue_id=1    pdu=1    qos_vonr=3    regexp=${cg_active_regexp}
    UE Deregister From gNB    ue_id=1
    Check Counters    ${PM_Counters_Check_H08}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_H08${/}a2a.ini    wait_string=UEContextReleaseComplete::6

CB008124_H_05_ICSwoPDU_DRB1wCG2DRB2wCG2simul_addVONRdelDRB2simul_addDRB3wCG2_delVONR
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour associated with setup of Configured UL Grants Type 2 for
    ...    UE for which VONR(5qi=1) bearer is being released, and blocking setup of Configured UL Grants Type 2 for UE
    ...    for which VONR(5qi=1) bearer is already setup
    ...    2. Configuration
    ...    a.SA+NSA,FDD,NRCELL-1
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.drb 5QI_8 is associated with NRULCG_PROFILE-1, 5QI_4 and 5QI_6 are both associated with NRULCG_PROFILE-2.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session with CG2,default DRB are 5QI_4 and 5QI_6.
    ...    b.setup VONR and delete 5QI_4 at the same time, CG2 is released.
    ...    c.setup 5QI_8, whose CG2 cannot be setup.
    ...    d.delete VONR, CG2 for 5QI_8 is setup.
    ...    e.UE detach.
    [Tags]    QC_281159    owner-kexin.bao
    Prepare For Test H05
    ICS Without PDU H05    ue_id=1    cell_id=1    regexp=${cg_active_regexp}
    Setup VONR And delete DRB    ue_id=1    qfi=3    del_5qi=4    regexp=${cg_release_regexp}
    Setup DRB wo CG    ue_id=1    qfi=2    pdu=1    qosflow=6    5qi=8    fail_regexp=configuredGrantConfig setup
    Delete VONR and Verify Tput    ue_id=1    pdu=1    qos_vonr=3    regexp=${cg_active_regexp}
    UE Deregister From gNB    ue_id=1
    OnlineParamChange    ${OnlineParam_for_H05_recover}
    Check Counters    ${PM_Counters_Check_H05}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_H05${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC log    ${CURDIR}${/}a2a_CB008124_H05${/}a2a.ini
CB008124_H_13_ICSwPDU_addDRB1wCG2_addVONR_intracellHO_addDRB2wCG2_delVONR
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour associated with setup of Configured UL Grants Type 2 for
    ...    UE for which VONR(5qi=1) bearer is being released, and blocking setup of Configured UL Grants Type 2 for UE
    ...    for which VONR(5qi=1) bearer is already setup
    ...    2. Configuration
    ...    a.SA+NSA,FDD,NRCELL-1
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.drb 5QI_80 is associated with NRULCG_PROFILE-2, 5QI_4 is associated with NRULCG_PROFILE-1.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a. SA UE register.
    ...    b. setup 2 PDU on UE1,1st PDU 5QI-5 is set as default DRB, and 2nd PDU 5QI-80 is set as default DRB.
    ...    c. setup 5QI-1, cg should be released.
    ...    d. Intra-Fre, inter-GNB handover and intra-cell handover.
    ...    e. setup 5QI-4.
    ...    f. delete 5QI-1, CG should be setup.
    [Tags]    QC_281155    owner-kexin.bao
    Prepare For Test H13
    SA UE1 register
    setup 2 slices for 2 PDU on UE1
    setup 5QI1    ue_id=1    pdu=1    qosflow=3    regexp=${cg_release_regexp}    qfi_T=1    pdu_T=2
    Verify Throuput    ue_id=1    qfi=1    pdu=2    Tput_dl=4.5    Tput_ul=2.7    sleep_time=2s
    Trigger intra-cell handover and interGNB handover should successed
    setup DRB and delete VONR    ue_id=1    qosflows_to_add=4     qosflows_to_del=3
    Verify Throuput    ue_id=1    qfi=1    pdu=2    Tput_dl=4.5    Tput_ul=2.7    sleep_time=2s
    UE Deregister From gNB    ue_id=1
    Check Counters    ${PM_Counters_Check_H13}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_H13${/}a2a.ini    wait_string=UEContextReleaseComplete::6

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${TL_TYPE_PATH}    ue_count=15
    Check Xn link available

Check Xn link available
    BuiltIn.Log    check expect xnlink setup as expect    console=${True}
    Set xn link up
    Object Should Exist    XNLINK-2:xnLinkStatus=available

Set xn link up
    Execute Egate Command    nb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=3 reset
    Execute Egate Command    gnb_xn_setup_param id=3 reset
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    is up

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=8000 gfbr_dl=8000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=7
    Update Cfg    set_qosflow id=6 5qi=8
    Update Cfg    set_qosflow id=7 5qi=80
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 ue=1
    Update Cfg    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true
    Update Cfg    amf_param id=1 full_nas_auth=on nia=snow3g+zuc+aes nea=null+snow3g+zuc+aes
    BuiltIn.Log    update CFG    console=${True}
    ${GNB3_CFG}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22
    ...    daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg    ${GNB3_CFG}
    ${CELL_381}    Catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999
    ...    nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off
    Update Cfg    ${CELL_381}
    ${UE_1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=snow3g+zuc+aes nea=null+snow3g+zuc+aes
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${UE_1}

Prepare For Test H08
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_phy}
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=3 reset
    Execute Egate Command    gnb_xn_setup_param id=3 reset
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=3 sa_ho=xn_based
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=70

Prepare For Test H05
    OnlineParamChange    ${OnlineParam_for_H05}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_n71}
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=70
    Clear Counter Files

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

ICS Without PDU H05
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=4
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    ${regexp}
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Send And Verify Throuput    ue_id=${ue_id}    qfi=1    pdu=1    send_dl=10    send_ul=3    sleep_time=10s
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    pdu=1    send_dl=10    send_ul=3    sleep_time=10s

Setup VONR And delete DRB
    [Arguments]    ${ue_id}    ${qfi}    ${del_5qi}    ${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=Added QosFlow with QFI:${qfi} 5QI:5
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 qosflows_to_del=${del_5qi} by=amf
    ...    pass_regexp=${regexp}

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

Setup VONR
    [Arguments]    ${ue_id}    ${qfi}    ${nextqfi}    ${pdu}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf
    ...    pass_regexp=Added QosFlow with QFI:${qfi} 5QI:5
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=3 by=amf
    ...    pass_regexp=Added QosFlow with QFI:${nextqfi} 5QI:1
    Send And Verify Throuput    ue_id=${ue_id}    qfi=${nextqfi}    pdu=${pdu}    send_dl=10    send_ul=3    sleep_time=10s

Delete VONR and Verify Tput
    [Arguments]    ${ue_id}    ${pdu}    ${qos_vonr}    ${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos_vonr} by=amf
    ...    pass_regexp=${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=2    pdu=${pdu}    Tput_dl=9    Tput_ul=2.7    sleep_time=2s

Setup DRB wo CG
    [Arguments]    ${ue_id}    ${qfi}    ${pdu}    ${qosflow}    ${5qi}    ${fail_regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflow} by=amf
    ...    pass_regexp=Added QosFlow with QFI:${qfi} 5QI:${5qi}    fail_regexp=${fail_regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=${qfi}    pdu=${pdu}    send_dl=10    send_ul=3    sleep_time=10s

Handover From gNB to Sim Should Success
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_id}    ${phycell_id}    ${regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_id}
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=20 srsrq_nr=20
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=${regexp}
    Execute Egate Command    ue_disp state=ACTIVE    3.1

Handover From Sim to gNB Should Success
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_id}     ${phycell_id}    ${regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_id}
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=20
    ...    phycell_id=${phycell_id} nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=${regexp}
    Execute Egate Command    ue_disp state=ACTIVE    2.1

Prepare For Test H13
    OnlineParamChange    ${OnlineParam_for_H13}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_phy}
    Clear Counter Files
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=2 priority=1
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=70

SA UE1 register
    Prepare UE History Information
    execute egate command    state_sim_disp
    execute egate command    amf_ue_ics_param id=1 reset
    execute egate command    ue_change_location id=1 cell=1
    Execute Egate Command    ue_register id=1    NG RM Registered

setup 2 slices for 2 PDU on UE1
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1    QoS Routing Table
    Execute Egate Command    qosflow_modify default=on qos_flow=7 priority=1
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=2 nwslice=2 gw=2    ${cg_active_regexp}
    Send And Verify Throuput    ue_id=1    qfi=1    pdu=2    send_dl=5    send_ul=2    sleep_time=10s

Trigger intra-cell handover and interGNB handover should successed
    Handover From gNB to Sim Should Success    ue_id=1    carrierfreq=126530    event_id=A3    phycell_id=381
    ...    regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    sleep    2s    sleep for HO interval
    Verify Throuput    ue_id=1    qfi=1    pdu=2    Tput_dl=4.5    Tput_ul=1.8    sleep_time=2s
    Pre-conditions for intra-cell handover
    Handover From Sim to gNB with intra-cell handover Should Success    ue_id=1    carrierfreq=126530    event_id=A3
    sleep    10s    sleep for HO limitation

Prepare UE History Information
    ${cmd_1}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ${cmd_1}
    ${cmd_2}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ${cmd_2}
    ${cmd_3}    Catenate    ue_history_information_list id=1 action=commit
    Execute Egate Command    ${cmd_3}
    ${cmd_4}    Catenate    ue_enb_param id=1 ue_history_list=1
    Execute Egate Command    ${cmd_4}

Handover From Sim to gNB with intra-cell handover Should Success
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_id}=A3
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_id}
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id} event=${event_id} srsrp_nr=11 srsrq_nr=11 phycell_id=60
    ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=40:40:59
    Execute Egate Command    ${cmd}    pass_regexp=Intra-cell handover
    Execute Egate Command    ue_disp state=ACTIVE    2.1

Pre-conditions for intra-cell handover
    Execute Egate Command    ue_reauth id=1 nr_sec_cap=aes|aes    Reauthentication procedure is complete
    Execute Egate Command    amf_path_switch_param id=1 include_ue_sec_cap=on
    Execute Egate Command    smf_param id=1 security_indication=path_switch:preferred:preferred max_data_rate=20mbps

setup 5QI1
    [Arguments]    ${ue_id}    ${pdu}    ${qosflow}    ${regexp}    ${qfi_T}    ${pdu_T}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflow} by=amf
    ...    pass_regexp=${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=${qfi_T}    pdu=${pdu_T}    send_dl=5    send_ul=3    sleep_time=10s

setup DRB and delete VONR
    [Arguments]    ${ue_id}    ${qosflows_to_add}    ${qosflows_to_del}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows_to_add} by=amf    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qosflows_to_del} by=amf    ${cg_active_regexp}
