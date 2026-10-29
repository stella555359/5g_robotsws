*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

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
...    @{5qi1_related_modification}
...    @{5qi2_related_modification}
...    @{ho_related}

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actUlCgType2=true
...    NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-3    #5qi=6
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #5qi=8
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2    #5qi=80
...    NRBTS/NRDRB-18:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2    #5qi=4
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=2000
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=12
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms5
...    NRBTS/NRULCG_PROFILE-3:grantedPacketSize=800
...    NRBTS/NRULCG_PROFILE-3:maxNumPrbs=12
...    NRBTS/NRULCG_PROFILE-3:periodicity=ms80
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=36
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=20
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=36
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
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=80
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

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

@{5qi1_related_modification}
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
...    NRBTS/NRDRB-19:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-19:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-19:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-19:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-19:maxTransferDelayGbr=20
...    NRBTS/NRDRB-19:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-19:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-19:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-4
...    NRBTS/NRDRB-19:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-19:numSduDiscard=1
...    NRBTS/NRDRB-19:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-19:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-19:resType=GBR
...    NRBTS/NRDRB-19:rlcMode=RLC_UM
...    NRBTS/NRDRB-19:schedulWeight=1
...    NRBTS/NRDRB-19:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-19:volThresDiscardDl=8000
...    NRBTS/NRDRB-19:volThresDiscardUl=800
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
...    NRBTS/NRDRB_5QI-9:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-19
...    NRBTS/NRDRB_MAC-6:delayTarget=50
...    NRBTS/NRDRB_MAC-6:lcgid=4
...    NRBTS/NRDRB_MAC-6:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-6:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-6:schedulPrio=5

@{5qi2_related_modification}
...    NRBTS/NRDRB_5QI-10:fiveqiValueList=2
...    NRBTS/NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-20
...    NRBTS/NRDRB-20:discardTimer=300ms
...    NRBTS/NRDRB-20:l2OHFactorDl=16
...    NRBTS/NRDRB-20:l2OHFactorUl=35
...    NRBTS/NRDRB-20:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-20:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-20:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-20:maxTransferDelayGbr=20
...    NRBTS/NRDRB-20:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-20:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-20:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-20:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-20:resType=GBR
...    NRBTS/NRDRB-20:rlcMode=RLC_UM
...    NRBTS/NRDRB-20:schedulWeight=1
...    NRBTS/NRDRB-20:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS/NRDRB-20:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:delayTarget=50

@{ho_related}
...    NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min

...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=8
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{OnlineParam_for_H06}
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms40
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=8

@{OnlineParam_for_H04_recover}
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2    #5qi=80

@{OnlineParam_for_H04}
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #5qi=80

${UE_Capa_Support_CG2_mac_phy}    SEPARATOR=
...    E1A03000076E0140502D018F0041C19000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261201EB608080838778E
...    1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A
...    8D89BAC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261201EB60808083
...    8778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000000000
...    0072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

${UE_Capa_Support_CG2_n78}    SEPARATOR=
...    E1A03000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C
...    00103278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00551B1375
...    82028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E000900C04200600A8D89DAC10143404B2CA261201EB60
...    8080838778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000
...    0000000072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

${RRC_RECONF_CMP_CG_SETUP_RCVD}    M55166C00005    #No of RRC reconfiguration complete received with UL configured grant type2 setup
${RRC_RECONF_CMP_CG_RELEASE_RCVD}    M55166C00006    #No of RRC reconfiguration complete received with UL configured grant type2 release
${CG_RES_ALLO_ATT_DU}    M55139C00017    #the total number of UL-configured grant Type2 resource allocation attempts during the admission control

@{PM_Counters_Check_H03}
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=1
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=0
...    NRCELL-1:RSADU:${CG_RES_ALLO_ATT_DU}=1

@{PM_Counters_Check_H06}
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=2
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=1
...    NRCELL-1:RSADU:${CG_RES_ALLO_ATT_DU}=2

@{PM_Counters_Check_H04}
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=2
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=1
...    NRCELL-2:RSADU:${CG_RES_ALLO_ATT_DU}=2

${SYSCOM_FLAG}    ${True}

@{cg_active_regexp}
...    logicalChannelSR-Mask TRUE
...    cs-RNTI setup
...    configuredGrantConfig setup

@{cg_release_regexp}
...    cs-RNTI release
...    configuredGrantConfig release

@{OnlineParam_for_HU01}
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-1:maxGBRTrafficLimit=10

@{partial_fail_result}
...    Deleted QoSFlow with QFI 1
...    RRC Reconfiguration failed
...    Deleted Unsuccessful QosFlow QFI:3

@{HO_with_cg_release_regexp}
...    @{cg_release_regexp}
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

@{PM_Counters_Check_HU01}
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=1
...    NRCELL-1:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=0
...    NRCELL-1:RSADU:${CG_RES_ALLO_ATT_DU}=1
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=0
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=1
...    NRCELL-2:RSADU:${CG_RES_ALLO_ATT_DU}=0

*** Test Cases ***
CB008124_H_03_ICSwoCG2_addVONR_addDRB1wCG2_delVONRaddDRB2wCG2simul
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour associated with setup of Configured UL Grants Type 2 for
    ...    UE for which VONR(5qi=1) bearer is being released, and blocking setup of Configured UL Grants Type 2 for UE
    ...    for which VONR(5qi=1) bearer is already setup
    ...    2. Configuration
    ...    a.SA+NSA,TDD,NRCELL-1
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.drb 5QI_8 is associated with NRULCG_PROFILE-1, and 5QI_4 is associated with NRULCG_PROFILE-2.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session without CG2.
    ...    b.setup VONR.
    ...    c.setup 5QI_8, whose CG2 cannot be setup.
    ...    d.delete VONR and setup 5QI_4 at the sametime, CG2 for 5QI_8 is setup.
    ...    e.UE detach.
    [Tags]    QC_281160    owner-kexin.bao
    Prepare For Test H03
    ICS Without PDU H03    ue_id=1    cell_id=1    regexp=QoS Routing Table
    Setup DRB    ue_id=1    qfi=2    qosflow=1    5qi=1
    Setup DRB    ue_id=1    qfi=3    qosflow=8    5qi=8
    Send And Verify Throuput    ue_id=1    qfi=3    pdu=1    send_dl=5    send_ul=2    sleep_time=10s
    Delete VONR and Setup DRB    ue_id=1    regexp=${cg_active_regexp}    qosflow=4
    Verify Throuput    ue_id=1    qfi=3    pdu=1    Tput_dl=5*0.9    Tput_ul=2*0.9    sleep_time=10s
    UE Deregister From gNB    ue_id=1
    Check Counters    ${PM_Counters_Check_H03}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_H03${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_H_04_ICSwoPDU_DRB1wCG2DRB2simul_addVONRDRB3wCG2simul_delVONR
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour associated with releasing of Configured UL Grants Type 2
    ...    for UE for which VONR(5qi=1) bearer is being setup , and setup of Configured UL Grants Type 2 for UE for
    ...    which VONR(5qi=1) bearer is being released
    ...    2. Configuration
    ...    a.SA,TDD,NRCELL-2
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.drb 5QI_8 and 5QI_80 are associated with NRULCG_PROFILE-1.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU session.
    ...    b.setup 5QI_8 and 5QI_7 at the same time, CG2 for 5QI_8 is setup.
    ...    c.setup VONR and 5QI_80 at the same time, CG2 for 5QI_8 is released.
    ...    d.delete VONR, CG2 for 5QI_8 is setup.
    ...    e.UE detach.
    [Tags]    QC_281158    owner-kexin.bao
    Prepare For Test H04
    ICS Without PDU H04    ue_id=1    cell_id=2    regexp=${cg_active_regexp}
    Send And Verify Throuput    ue_id=1    qfi=1    pdu=1    send_dl=10    send_ul=2    sleep_time=10s
    Setup VONR and DRB    ue_id=1    qosflow=9    regexp=${cg_release_regexp}
    Delete VONR and Verify Tput H04    ue_id=1    pdu=1    regexp=${cg_active_regexp}
    UE Deregister From gNB    ue_id=1
    OnlineParamChange    ${OnlineParam_for_H04_recover}
    Check Counters    ${PM_Counters_Check_H04}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_H04${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_H_06_ICSwoPDU_1stPDUDRB1wCG2_2ndPDUaddVONR_1stPDUaddDRB2wCG2_delVONR
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour associated with releasing of Configured UL Grants Type 2
    ...    for UE for which VONR(5qi=1) bearer is being setup, setup of Configured UL Grants Type 2 for UE for which
    ...    VONR(5qi=1) bearer is being released, and blocking setup of Configured UL Grants Type 2 for UE for which
    ...    VONR(5qi=1) bearer is already setup
    ...    2. Configuration
    ...    a.SA+NSA,TDD,NRCELL-1
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.5QI_80 is associated with NRULCG_PROFILE-1, and 5QI_6 is associated with NRULCG_PROFILE-2.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU session.
    ...    b.setup 5QI_6 on 1st PDU, CG2 for 5QI_6 is setup.
    ...    c.setup VONR on 2nd PDU, CG2 for 5QI_6 is released.
    ...    d.setup 5QI_80 on 1st PDU, CG2 for 5QI_80 cannot be setup.
    ...    e.delete VONR, CG2 for 5QI_80 is setup.
    ...    f.UE detach.
    [Tags]    QC_281157    owner-kexin.bao
    Prepare For Test H06
    ICS Without PDU H06    ue_id=1    cell_id=1    regexp=${cg_active_regexp}
    Send And Verify Throuput    ue_id=1    qfi=1    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Setup VONR    ue_id=1    pdu=2    regexp=${cg_release_regexp}
    Setup DRB    ue_id=1    qfi=2    qosflow=9    5qi=80
    Send And Verify Throuput    ue_id=1    qfi=2    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Delete VONR and Verify Tput H06    ue_id=1    pdu=2    regexp=${cg_active_regexp}
    UE Deregister From gNB    ue_id=1
    Check Counters    ${PM_Counters_Check_H06}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_H06${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_HU01_ICSDRB1wCG_addDRB2_addGBRdelDRB1partialfail_intragNBHO
    [Documentation]
    ...    1. CG Type2 configuration could not be released for UE along with CG associated DRB release during PDU
    ...    Session Modify which simultaneously adds and deletes one or more Qos flows in single message - due to DRB
    ...    addition failure at Gnb-DU.
    ...    2. Configuration
    ...    a.SA+NSA,TDD,NRCELL-1
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.drb 5QI_8 is associated with NRULCG_PROFILE-1, and 5QI_4 is associated with NRULCG_PROFILE-2.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach with default 5QI_8, CG2 is setup.
    ...    b.setup 5QI_7.
    ...    c.setup 5QI_4 and delete 5QI-8, 5QI_4 cannot be setup due to RAC. CG2 should not be released.
    ...    d.intragNB HO, CG2 is released.
    ...    e.UE detach.
    [Tags]    QC_284973    owner-kexin.bao
    Prepare For Test HU01
    ICS Without PDU H03    ue_id=2    cell_id=1    regexp=QoS Routing Table
    Setup DRB And Send Tput    ue_id=2    qfi=2    qosflow=4    5qi=4    send_dl=50    send_ul=30
    ICS Without PDU H03    ue_id=1    cell_id=1    regexp=${cg_active_regexp}
    Setup DRB And Send Tput    ue_id=1    qfi=2    qosflow=7    5qi=7    send_dl=5    send_ul=2
    Add DRB Fail and Delete Success    ue_id=1    qosflow_1=4    qosflow_2=8    pass_regexp=${partial_fail_result}
    Trigger A3    ue_id=1    carrierfreq=636576    phycell_id=51
    ...    pass_regexp=${HO_with_cg_release_regexp}
    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    Check Counters    ${PM_Counters_Check_HU01}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_HU01${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=400 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7 default=on
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=9 5qi=80

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Prepare For Test H03
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_n78}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=5 priority=1
    Clear Counter Files

Prepare For Test H04
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_phy}
    OnlineParamChange    ${OnlineParam_for_H04}
    Clear Counter Files

Prepare For Test H06
    OnlineParamChange    ${OnlineParam_for_H06}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_phy}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Clear Counter Files

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

ICS Without PDU H03
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${regexp}
    Execute Egate Command    amf_param id=1 send_ics_registration=off

ICS Without PDU H04
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${regexp}
    Execute Egate Command    amf_param id=1 send_ics_registration=off

ICS Without PDU H06
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${regexp}
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    qosflow_modify default=on qos_flow=5 priority=1
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1    QoS Routing Table

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
    [Arguments]    ${ue_id}    ${pdu}    ${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=1 by=amf    pass_regexp=${regexp}

Delete VONR and Verify Tput H04
    [Arguments]    ${ue_id}    ${pdu}    ${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=1 by=amf    pass_regexp=${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=1    pdu=1    Tput_dl=10*0.9    Tput_ul=2*0.9    sleep_time=10s

Setup DRB
    [Arguments]    ${ue_id}    ${qfi}    ${qosflow}    ${5qi}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflow} by=amf
    ...    pass_regexp=Added QosFlow with QFI:${qfi} 5QI:${5qi}

Delete VONR and Setup DRB
    [Arguments]    ${ue_id}    ${regexp}    ${qosflow}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=1 qosflows_to_add=${qosflow} by=amf
    ...    pass_regexp=${regexp}

Setup VONR and DRB
    [Arguments]    ${ue_id}    ${qosflow}    ${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1,${qosflow} by=amf
    ...    pass_regexp=${regexp}

Delete VONR and Verify Tput H06
    [Arguments]    ${ue_id}    ${pdu}    ${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=1 by=amf    pass_regexp=${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=1    pdu=1    Tput_dl=5*0.9    Tput_ul=3*0.9    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=2    pdu=1    Tput_dl=5*0.9    Tput_ul=3*0.9    sleep_time=10s

Prepare For Test HU01
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_n78}
    OnlineParamChange    ${OnlineParam_for_HU01}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_ul=200
    Clear Counter Files

Add DRB Fail and Delete Success
    [Arguments]    ${ue_id}    ${qosflow_1}    ${qosflow_2}    ${pass_regexp}
    ${cmd}    catenate    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflow_1} qosflows_to_del=${qosflow_2} by=amf
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

Trigger A3
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}    ${pass_regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=40
    ...    phycell_id=${phycell_id} nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Verify Throuput    ${ue_id}    qfi=2    pdu=1    Tput_dl=4.5    Tput_ul=0.1    sleep_time=10s

Setup DRB And Send Tput
    [Arguments]    ${ue_id}    ${qfi}    ${qosflow}    ${5qi}    ${send_dl}    ${send_ul}
    Setup DRB    ue_id=${ue_id}    qfi=${qfi}    qosflow=${qosflow}    5qi=${5qi}
    Send And Verify Throuput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    send_dl=${send_dl}    send_ul=${send_ul}    sleep_time=10s
