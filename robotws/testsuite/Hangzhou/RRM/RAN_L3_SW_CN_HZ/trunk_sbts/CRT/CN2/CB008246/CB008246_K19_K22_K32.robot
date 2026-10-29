*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CB008246    release-SBTS24R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS:actFullPlmnList=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{5qi80_related_modification}

...    @{5qi4_related_modification}
...    @{8246_related_modification}
...    @{8124_related_modification}
...    @{ca_related}
...    @{scell_swap}
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actDl256Qam=false
...    NRCELL:actUl256Qam=false

@{ca_related}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrUlHarqOne=5min
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-3:actK1Opt=intra-gNB
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-3:increasePUSCHPrepTimeULCA=true
...    NRCELL:timingAdvanceOffset=n25600
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-4:ulTReassemblyIBCA=40

...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=40
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=40
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:lcrId=11
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=40
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:lcrId=3
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:lcrId=4
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=40
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:lcrId=3
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3

@{scell_swap}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=10|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=10|a6TimeToTrigSCellSwapSsbRsrq=ms480

@{8246_related_modification}
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-14/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4

...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=3
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=130
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110

...    NRCELL:actCceSplit=false
...    NRCELL:actLAForHiReliab=true
...    NRCELL:scalingStepdownHREnabled=true
...    NRCELL:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK2HR=25
...    NRCELL:puschHrLaConfig:ullaSinrOffsetHR=20
#5qi-6
...    NRBTS/NRDRB-11:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
#5qi-7
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
#5qi-4
...    NRBTS/NRDRB-18:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-18:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-18:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1

@{8124_related_modification}
...    NRCELL-12:pucchModeSelect=longPucch
...    NRCELL-12:actUlCgType2=true
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #5qi=80
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRCELL-12:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-12:ulConfiguredGrantType2:ulCgPrbStartOffset=0

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
...    NRBTS/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    delete:NRBTS/NRDRB-18:nsaDrbParam:dlPreferredPath
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

@{5qi80_related_modification}
...    NRBTS/NRDRB-17:discardTimer=100ms
...    NRBTS/NRDRB-17:dlFlowControlAlgo=none
...    NRBTS/NRDRB-17:dscp=46
...    NRBTS/NRDRB-17:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-17:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-17:rlcMode=RLC_UM
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-17:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=80
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{Onlinemod_K32}
...    NRCELL-3:actLAForHiReliab=false
...    NRCELL-4:actLAForHiReliab=false

${UE_Capa_Support_HRLA_CG2}    SEPARATOR=
...    E9A09000577F0140502D098B0041E210002C1262E003387A1201364D873E618F28581C130180623807DC6C28C0D608C21A08107483401B5
...    B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8002E0000702A0D883AC1184341020F1068032B64C5
...    5890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000B80001C0AA3626EB04610D04083A41A00C2D931544439F11
...    C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00170000381506C46D608C21A0810788340195B262AC4873E238F604F8C48
...    E3C873EA39F30C7942C0E070F09FFF000007FFC000005C0000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E20
...    8000030B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001
...    C41000E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001
...    C41000E230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B0
...    1045D002EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E0448102
...    06C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A0
...    B800F000A070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008
...    004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958
...    195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A5949010000396524040001259490100005965240
...    40001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55
...    154162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A05000608080600C0200
...    4008404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C01804030060808
...    0100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${UE_Capa_Support_HRLA_n71_n41_ulca_cg}    SEPARATOR=
...    E9A09000577F0140502D098B0041E210002C1262E003387A1201364D873E618F28581C130180623807DC6C28C0D608C21A08107483401B5
...    B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8002E0000702A0D883AC1184341020F1068032B64C5
...    5890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000B80001C0AA3626EB04610D04083A41A00C2D931544439F11
...    C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001700003815C7C46D608C21A08107CA0D00556C98AB0A1CF88E3C6000000
...    0000000000002070F013FFE00000FFF800000B80001C00F78789A001C4100000216020541E14000711800000858158788C001C410000061
...    60561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C
...    28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C
...    46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C046805101360208BA00
...    5D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C0
...    8902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F417001E00
...    140E0A00E0601280380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100080200
...    8020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B
...    056B296B266B016B036B012B022B07681A0800004B29202000032CA480800014B29202000072CA480800024B292020000B2CA480800034B
...    292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA4806795517CAA0AA55174AA2A82C5
...    70582A83455298AA4D154062A8145526AAA0F142C02F012A05028140A05028140A05028140A05028140A050280030404030060100200420
...    2004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C02018030404008020
...    10020086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

@{PM_Counters_Check_K19}
...    NRCELL-1:NCAC:${BAD_RLQ_REL_SCELL_ATT_SA}=0
...    NRCELL-1:NCAC:${BAD_RLQ_REL_SCELL_SUC_SA}=0
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1ULSCELL_ATT_SA}=0
...    NRCELL-1:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=0
...    NRCELL-1:NDLHQ:${PDSCH_INITX_64TBL_BR}>1000
...    NRCELL-1:NDLHQ:${PDSCH_SUCC_INI_64TBL_BR}>1000
...    NRCELL-1:NDLHQ:${PDSCH_SUCC_ANY_64TBL_BR}>1000
...    NRCELL-1:NDLHQ:${PDSCH_UNSUCC_64TBL_BR}=0
...    NRCELL-1:DHQLSE:${PDSCH_INITX_LOWSE_HRD_PRFL1}=0
...    NRCELL-1:DHQLSE:${PDSCH_SUCC_INI_LOWSE_HRD_PRFL1}=0
...    NRCELL-1:DHQLSE:${PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1}=0
...    NRCELL-1:DHQLSE:${PDSCH_UNSUCC_LOWSE_HRD_PRFL1}=0
...    NRCELL-11:NCAC:${BAD_RLQ_REL_SCELL_ATT_SA}=0
...    NRCELL-11:NCAC:${BAD_RLQ_REL_SCELL_SUC_SA}=0
...    NRCELL-11:NCAC:${A2MEAS_REL1DLSCELL_ATT_SA}=0
...    NRCELL-11:NCAC:${A2MEAS_REL1DLSCELL_SUCC_SA}=0
...    NRCELL-11:NCAC:${A2MEAS_REL1ULSCELL_ATT_SA}=0
...    NRCELL-11:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=0
...    NRCELL-11:NDLHQ:${PDSCH_INITX_64TBL_BR}>1000
...    NRCELL-11:NDLHQ:${PDSCH_SUCC_INI_64TBL_BR}>1000
...    NRCELL-11:NDLHQ:${PDSCH_SUCC_ANY_64TBL_BR}>1000
...    NRCELL-11:NDLHQ:${PDSCH_UNSUCC_64TBL_BR}<10
...    NRCELL-11:DHQLSE:${PDSCH_INITX_LOWSE_HRD_PRFL1}=0
...    NRCELL-11:DHQLSE:${PDSCH_SUCC_INI_LOWSE_HRD_PRFL1}=0
...    NRCELL-11:DHQLSE:${PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1}=0
...    NRCELL-11:DHQLSE:${PDSCH_UNSUCC_LOWSE_HRD_PRFL1}=0

@{PM_Counters_Check_K22}
...    NRCELL-12:NCAC:${HRDRB_TRIGG_REL_SCELL_ATT_SA}=0
...    NRCELL-12:NCAC:${HRDRB_TRIGG_REL_SCELL_SUC_SA}=0
...    NRCELL-12:NCAC:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-12:NCAC:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-12:NCAC:${DL_RRC_FEXTSCELL_REL_ATT_SA}=0
...    NRCELL-12:NCAC:${DL_RRC_FEXTSCELL_REL_SUC_SA}=0
...    NRCELL-12:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-12:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-12:NCAC:${UL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-12:NCAC:${UL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-12:NDLHQ:${PDSCH_INITX_64TBL_BR}>1000
...    NRCELL-12:NDLHQ:${PDSCH_SUCC_INI_64TBL_BR}>1000
...    NRCELL-12:NDLHQ:${PDSCH_SUCC_ANY_64TBL_BR}>1000
...    NRCELL-12:NDLHQ:${PDSCH_UNSUCC_64TBL_BR}<10
...    NRCELL-12:DHQLSE:${PDSCH_INITX_LOWSE_HRD_PRFL1}=0
...    NRCELL-12:DHQLSE:${PDSCH_SUCC_INI_LOWSE_HRD_PRFL1}=0
...    NRCELL-12:DHQLSE:${PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1}=0
...    NRCELL-12:DHQLSE:${PDSCH_UNSUCC_LOWSE_HRD_PRFL1}=0

${HRDRB_TRIGG_REL_SCELL_ATT_SA}    M55118C00038    #The number of SCells to be released on SA PCell due to High-Reliability reasons
${HRDRB_TRIGG_REL_SCELL_SUC_SA}    M55118C00039
${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042    #The number of DL Full SCell Release attempts on PCell for SA
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
${DL_RRC_FEXTSCELL_REL_ATT_SA}    M55118C00044    #The number of DL Full ext-SCell Release attempts on PCell for SA
${DL_RRC_FEXTSCELL_REL_SUC_SA}    M55118C00045
${DL_RRC_1SCELL_REL_ATT_SA}    M55118C10503    #The number of DL 1 SCell Release attempts on PCell for SA
${DL_RRC_1SCELL_REL_SUC_SA}    M55118C10504
${UL_RRC_1SCELL_REL_ATT_SA}    M55118C10505    #The number of UL 1 SCell Release attempts on PCell for SA
${UL_RRC_1SCELL_REL_SUC_SA}    M55118C10506
${PDSCH_INITX_64TBL_BR}    M55300C00033    #PDSCH initial transmissions with 64QAM MCS table using NRCELL.dllaBlerTarget as LA BLER Target
${PDSCH_SUCC_INI_64TBL_BR}    M55300C00034
${PDSCH_SUCC_ANY_64TBL_BR}    M55300C00035    #Successful PDSCH transmissions with 64QAM MCS table using NRCELL.dllaBlerTarget as LA BLER Target
${PDSCH_UNSUCC_64TBL_BR}    M55300C00036
${PDSCH_INITX_LOWSE_HRD_PRFL1}    M55366C00001    #PDSCH initial transmissions with LowSE MCS table using LA BLER Target from NRPDSCHHRLA Profile1
${PDSCH_SUCC_INI_LOWSE_HRD_PRFL1}    M55366C00002
${PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1}    M55366C00005
${PDSCH_UNSUCC_LOWSE_HRD_PRFL1}    M55366C00006
${BAD_RLQ_REL_SCELL_ATT_SA}    M55118C10515    #The number of SCells to be released on PCell due to bad SCell radio link quality for SA
${BAD_RLQ_REL_SCELL_SUC_SA}    M55118C10516    #The number of SCells released on PCell due to bad SCell radio link quality for SA
${A2MEAS_REL1DLSCELL_ATT_SA}    M55118C06501
${A2MEAS_REL1DLSCELL_SUCC_SA}    M55118C06502
${A2MEAS_REL1ULSCELL_ATT_SA}    M55118C10003
${A2MEAS_REL1ULSCELL_SUCC_SA}    M55118C10004

*** Test Cases ***
CB008246_K19_SA_Scell_Swap_FAF_Activated_Pcell_Activated_Target_Swap_Scell_Alt18
    [Documentation]
    ...    1. HR DRB setup before/after Intra-GNB scell swap/scell change, FAF deactivated/activated on pcell or scell
    ...    2. Configuration
    ...    a.SA+NSA,FDD and TDD
    ...    b.UE1, pcell NRCELL-11 FAF deactivated,scell NRCELL-3/NRCELL-4 FAF activated.
    ...      UE2, pcell NRCELL-1 FAF deactivated, scell NRCELL-3/NRCELL-11 are FAF activated.
    ...    c.drb 5QI_7 is UL HR; drb 5QI_4 is HR GBR, drb 5QI_8 is BR.
    ...    d.UE1 and UE2 are capable of High Reliability.
    ...    3. Test Case Steps:
    ...    a.UE1 attach on NRCELL-11, UE2 attach on NRCELL-1, 5QI-7 and 5QI-8 are default DRB.
    ...    b.trigger A1 for UE1 to add scell, NRCELL-3 is chosed as scell for UE1.
    ...    c.trigger A6 for UE1 to make scell swap, NRCELL-4 is chosed as scell for UE1 instead of NRCELL-3
    ...    d.HR DRB operation for UE1.
    ...    e.trigger A1 for UE2 to add scell,NRCELL-11 is chosed as scell for UE2.
    ...    f.trigger A1 for UE2 to add scell again,NRCELL-3 is chosed as scell for UE2.
    ...    g.trigger A2 for UE2 to release one scell.
    ...    h.release UEs.
    [Tags]    QC_324086    owner-kexin.bao
    Prepare for Test K19
    UE Attach To Target Cell    ue_id=1    cell_id=11    pass_regexp=mcs-Table:::1
    UE1 CA and Scell Swap
    UE Attach To Target Cell without PDU    ue_id=2    cell_id=1    pass_regexp=mcs-Table:::1
    UE2 CA and Scell Change
    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    check wireshark log    ${CURDIR}${/}a2a_CB008246_K19${/}a2a.ini    wait_string=UEContextReleaseComplete::12
    Check Counters    ${PM_Counters_Check_K19}

CB008246_K22_SA_Blind_Scell_Addition_FT_FAF_Activated_Pcel_Scell_ULCA_Before_nonGBR_HRDRB_Setup_Alt0
    [Documentation]
    ...    1. HR DRB setup before/after Intra-GNB UL CA, FAF activated on pcell and scell
    ...    2. Configuration
    ...    a.SA+NSA,FDD and TDD
    ...    b.UE3 and UE4, pcell NRCELL-12 FAF activated,scell NRCELL-3 FAF activated.
    ...    c.drb 5QI_7 is UL HR; drb 5QI_4 is HR GBR, drb 5QI_8 is BR,drb 5QI_80 is CG2 DRB.
    ...    d.UE3 and UE4 are capable of High Reliability and CG2.
    ...    3. Test Case Steps:
    ...    a.UE3 attach on NRCELL-12, 5QI-5 and 5QI-80 are default DRB.
    ...    b.trigger A1 for UE3 to add scell, NRCELL-3 is chosed as scell for UE3.
    ...    c.setup 5QI-4, then setup 5QI-7.
    ...    d.UE4 attach on NRCELL-12, 5QI-5 and 5QI-7 are default DRB.
    ...    e.trigger A1 for UE4 to add scell, NRCELL-3 is chosed as scell for UE4.
    ...    f.setup 5QI-6.
    ...    g.release UEs.
    [Tags]    QC_324147    owner-kexin.bao
    UE3 Attach and ULCA
    UE4 Attach HR and ULCA
    UE Deregister From gNB    ue_id=3
    UE Deregister From gNB    ue_id=4
    check wireshark log    ${CURDIR}${/}a2a_CB008246_K22${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${PM_Counters_Check_K22}

CB008246_K32_SA_Blind_Scell_Addition_FT_FAF_Activated_Pcel_Deactivated_Scells_ULCA_Before_nonGBR_HRDRB_Setup_Alt1
    [Documentation]
    ...    1. HR DRB setup before/after Intra-GNB UL CA, FAF activated on pcell and scell
    ...    2. Configuration
    ...    a.SA+NSA,FDD and TDD
    ...    b.UE3, pcell NRCELL-12 FAF activated,scell NRCELL-3 FAF deactivated.
    ...    c.drb 5QI_7 is UL HR; drb 5QI_4 is HR GBR, drb 5QI_8 is BR,drb 5QI_80 is CG2 DRB.
    ...    d.UE3 is capable of High Reliability and CG2.
    ...    3. Test Case Steps:
    ...    a.UE3 attach on NRCELL-12, 5QI-5 and 5QI-80 are default DRB.
    ...    b.trigger A1 for UE3 to add scell, NRCELL-3 is chosed as scell for UE3.
    ...    c.setup 5QI-4, then setup 5QI-7.
    ...    d.release UE.
    [Tags]    QC_324822    owner-kexin.bao
    OnlineParamChange    ${Onlinemod_K32}
    UE Attach and ULCA
    UE Deregister From gNB    ue_id=3
    check wireshark log    ${CURDIR}${/}a2a_CB008246_K32${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=4000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6 default=on
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=9 5qi=80
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_Capa_Support_HRLA_CG2}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_Capa_Support_HRLA_CG2}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE_Capa_Support_HRLA_n71_n41_ulca_cg}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${UE_Capa_Support_HRLA_n71_n41_ulca_cg}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${pass_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_regexp}

UE Attach To Target Cell without PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${pass_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    amf_param empty_pdu_session_list=on id=1
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=${pass_regexp}
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} by=amf cause=RN_successful_handover    Received UE Context Release Complete
    Execute Egate Command    amf_ue_ics_param id=1 include_ue_capabilities=on
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    pass_regexp=${pass_regexp}

UE Attach To Target Cell w Fail Regexp
    [Arguments]    ${ue_id}    ${cell_id}    ${fail_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    fail_regexp=${fail_regexp}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A1 Event
    [Arguments]    ${ue_id}    ${carrierfreq}    ${rsrp}    ${pass_regexp}    ${fail_regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrp}
    Sleep    1s    sleep for add scell
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Trigger A2 Event
    [Arguments]    ${ue_id}    ${carrierfreq}    ${scell}    ${scell_rsrp}    ${fail_regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell} scell_rsrp=${scell_rsrp}
    Execute Egate Command    ${cmd}    fail_regexp=${fail_regexp}

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=508110    ${nrsrp_nr}=30    ${ue_id}=81    ${fail_regexp}=mcs-Table
    ...    ${scell_id}=1    ${phycell_id}=53
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrp_nr}
    Execute Egate Command    ${cmd}    fail_regexp=${fail_regexp}

Send Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=2    UE ${ue_id}: UDP UL

Verify Throuput For 2CC
    [Arguments]    ${scell_id}=1    ${ue_id}=1    ${total_dl_tput}=270    ${ul_tput}=9
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul_tput}

Verify Throuput For UL 2CC
    [Arguments]    ${scell_id}=1    ${ue_id}=1    ${dl_tput}=270    ${ul_tput}=9
    ${pcell_ul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${pcell_ul}/1000 > 0
    ${total_ul}    Set Variable    ${pcell_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pusch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_ul}    Evaluate    ${scell1_tput}+${total_ul}
    Should Be True    ${total_ul}/1000>${ul_tput}
    ${dl_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${dl_tput}

Prepare for Test K19
    Clear Counter Files
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7

UE1 CA and Scell Swap
    Trigger A1 Event    ue_id=1    carrierfreq=125050    rsrp=100    pass_regexp=sCellToAddModList    fail_regexp=mcs-Table
    Send Throuput    ue_id=1    pdu_id=1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 2CC    scell_id=1    ue_id=1    total_dl_tput=400    ul_tput=20
    Trigger ScellSwap    event_type=A6    carrierfreq=508110    nrsrp_nr=30    ue_id=1
    ...    scell_id=1    phycell_id=53    fail_regexp=mcs-Table
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 2CC    scell_id=2    ue_id=1    total_dl_tput=400    ul_tput=20
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=7 by=amf    fail_regexp=mcs-Table
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=4 by=amf    pass_regexp=mcs-Table:::2

UE2 CA and Scell Change
    Trigger A1 Event    ue_id=2    carrierfreq=632736    rsrp=50    pass_regexp=sCellToAddModList    fail_regexp=mcs-Table
    Send Throuput    ue_id=2    pdu_id=1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 2CC    scell_id=1    ue_id=2    total_dl_tput=530    ul_tput=90
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=4 by=amf    pass_regexp=mcs-Table:::1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 2CC    scell_id=1    ue_id=2    total_dl_tput=530    ul_tput=90
    Trigger A1 Event    ue_id=2    carrierfreq=632736    rsrp=80    pass_regexp=sCellToAddModList        fail_regexp=mcs-Table
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 2CC    scell_id=2    ue_id=2    total_dl_tput=650    ul_tput=90
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=6 by=amf    fail_regexp=mcs-Table
    Trigger A2 Event    ue_id=2    carrierfreq=508110    scell=2    scell_rsrp=20    fail_regexp=mcs-Table

UE3 Attach and ULCA
    clear counter files
    Execute Egate Command    qosflow_modify default=on qos_flow=5 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=9
    UE Attach To Target Cell w Fail Regexp    ue_id=3    cell_id=12    fail_regexp=mcs-Table
    Trigger A1 Event    ue_id=3    carrierfreq=126750    rsrp=100    pass_regexp=sCellToAddModList    fail_regexp=mcs-Table
    Send Throuput    ue_id=3    pdu_id=1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For UL 2CC    scell_id=1    ue_id=3    dl_tput=120    ul_tput=130
    Execute Egate Command    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=4 by=amf    pass_regexp=mcs-Table:::1
    Execute Egate Command    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=7 by=amf    pass_regexp=mcs-Table:::1

UE4 Attach HR and ULCA
    Execute Egate Command    qosflow_modify default=on qos_flow=5 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    UE Attach To Target Cell    ue_id=4    cell_id=12    pass_regexp=mcs-Table:::1
    Trigger A1 Event    ue_id=4    carrierfreq=126750    rsrp=100    pass_regexp=mcs-Table:::2    fail_regexp=onetwo
    Send Throuput    ue_id=4    pdu_id=1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For UL 2CC    scell_id=1    ue_id=4    dl_tput=60    ul_tput=20
    Execute Egate Command    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_add=6 by=amf    fail_regexp=mcs-Table

UE Attach and ULCA
    clear counter files
    Execute Egate Command    qosflow_modify default=on qos_flow=5 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=9
    UE Attach To Target Cell w Fail Regexp    ue_id=3    cell_id=12    fail_regexp=mcs-Table
    Trigger A1 Event    ue_id=3    carrierfreq=126750    rsrp=100    pass_regexp=sCellToAddModList    fail_regexp=mcs-Table
    Send Throuput    ue_id=3    pdu_id=1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For UL 2CC    scell_id=1    ue_id=3    dl_tput=120    ul_tput=130
    Execute Egate Command    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=4 by=amf    pass_regexp=mcs-Table:::1
    Execute Egate Command    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=7 by=amf    fail_regexp=mcs-Table
