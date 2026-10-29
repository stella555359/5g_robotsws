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
Library     ta_emss

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS:actFullPlmnList=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{5qi80_AM_related_modification}
...    @{5qi4_related_modification}
...    @{8246_related_modification}
...    @{8124_related_modification}
...    @{ca_related}
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actDl256Qam=false
...    NRCELL:actUl256Qam=false
...    NRBTS-1:rrcReestabTypeSA=sameGNB

@{ca_related}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrUlHarqOne=5min
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa
#ca_FFF
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=40
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:lcrId=13
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-14:a1MeasSCellAddEnabled=rsrp
...    NRCELL-14:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=40
...    NRCELL-14:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-14:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:lcrId=11
...    NRCELL-14/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-2:gNbId=1
...    NRCELL-14/NRREL-2:lcrId=13
...    NRCELL-14/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-2:gnbPlmn:mncLength=3
#CA_TFF
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-12:actUlCgType2=false
...    NRCELL-12:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-12:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3

@{8246_related_modification}
...    NRCELL:actLAForHiReliab=true
...    NRCELL-14:actLAForHiReliab=false
...    NRCELL:scalingStepdownHREnabled=true
...    NRCELL:actCceSplit=false
...    NRCELL:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-2/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-3/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
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
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMaxHR=150
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMinHR=-300
...    NRCELL:puschHrLaConfig:ullaDeltaSinrStepdownHR=20
...    NRCELL:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK2HR=25
...    NRCELL:puschHrLaConfig:ullaSinrOffsetHR=20
...    NRCELL:dlMcsDowngradeForHr=disabled
...    NRCELL:ulMcsDowngradeForHr=disabled
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=110
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=3
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=130
...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
#5qi-4
...    NRBTS/NRDRB-18:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-18:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-18:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
#5qi-7 ULHR
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
#5qi-80 DLHR
...    NRBTS/NRDRB-17:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-17:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1

@{8124_related_modification}
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actUlCgType2=true
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:actUlCgType2=true
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #5qi=80
...    NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #5qi=6
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=36
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=20
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=16
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=0

@{5qi80_AM_related_modification}
...    NRBTS/NRDRB-17:discardTimer=100ms
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
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
...    NRBTS/NRDRB-17:rlcMode=RLC_AM
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-17:nsaDrbParam=${EMPTY}
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

${UE_Capa_Support_HRLA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B26C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0
...    0038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B
...    02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B0
...    2B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8E
...    7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E04
...    4810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E060128
...    0380030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000
...    E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B0
...    36B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA48080
...    0044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455
...    018AA051549AAA83C5090178095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080100
...    202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080
...    C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${UE_Capa_not_Support_HRLA_support_CG2}    SEPARATOR=
...    E9A09000577F0140502D098B0041E210002C1262E003387A12013641873E618F28581C130180623807DC6C28C0D608C21A08107483401B5B
...    262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8002E0000702A0D883AC1184341020F1068032B64C558
...    90E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000B80001C0AA3626EB04610D04083A41A00C2D931544439F11C78
...    8E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00170000381506C46D608C21A0810788340195B262AC4873E238F604F8C48E3C8
...    73EA39F30C7942C0E070F09FFF000007FFC000005C0000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E2080000
...    30B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000
...    E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E
...    230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01045D002
...    EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044
...    810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A0B800F000A0
...    70500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A00800401004010
...    0000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B59
...    4B5933580B581B58095811583B40D04000025949410000196525040000A594901000039652404000125949010000596524040001A5949010
...    00079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C5506
...    8AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A05000608080600C0200400840400802010
...    0C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50
...    F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${UE_Capa_Support_HRLA_CG2}    SEPARATOR=
...    E9A09000577F0140502D098B0041E210002C1262E003387A1201364D873E618F28581C130180623807DC6C28C0D608C21A08107483401B5B
...    262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8002E0000702A0D883AC1184341020F1068032B64C558
...    90E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000B80001C0AA3626EB04610D04083A41A00C2D931544439F11C78
...    8E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00170000381506C46D608C21A0810788340195B262AC4873E238F604F8C48E3C8
...    73EA39F30C7942C0E070F09FFF000007FFC000005C0000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E2080000
...    30B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000
...    E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E
...    230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01045D002
...    EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044
...    810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A0B800F000A0
...    70500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A00800401004010
...    0000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B59
...    4B5933580B581B58095811583B40D04000025949410000196525040000A594901000039652404000125949010000596524040001A5949010
...    00079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C5506
...    8AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A05000608080600C0200400840400802010
...    0C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50
...    F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

@{scells_add_success}
...    pcid:62, scellIdx:2
...    pcid:60, scellIdx:1

@{PM_Counters_Check_K02}
...    NRCELL-12:NCAC:${HRDRB_TRIGG_REL_SCELL_ATT_SA}=4
...    NRCELL-12:NCAC:${HRDRB_TRIGG_REL_SCELL_SUC_SA}=4
...    NRCELL-12:NCAC:${DL_RRC_FSCELL_REL_ATT_SA}=2
...    NRCELL-12:NCAC:${DL_RRC_FSCELL_REL_SUC_SA}=2
...    NRCELL-12:NCAC:${DL_RRC_FEXTSCELL_REL_ATT_SA}=0
...    NRCELL-12:NCAC:${DL_RRC_FEXTSCELL_REL_SUC_SA}=0
...    NRCELL-12:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-12:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-12:NCAC:${UL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-12:NCAC:${UL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-14:NCAC:${HRDRB_TRIGG_REL_SCELL_ATT_SA}=0
...    NRCELL-14:NCAC:${HRDRB_TRIGG_REL_SCELL_SUC_SA}=0
...    NRCELL-14:NCAC:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-14:NCAC:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-14:NCAC:${DL_RRC_FEXTSCELL_REL_ATT_SA}=0
...    NRCELL-14:NCAC:${DL_RRC_FEXTSCELL_REL_SUC_SA}=0
...    NRCELL-14:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-14:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-14:NCAC:${UL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-14:NCAC:${UL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-14:NDLHQ:${PDSCH_INITX_64TBL_BR}>0
...    NRCELL-14:NDLHQ:${PDSCH_SUCC_INI_64TBL_BR}>0
...    NRCELL-14:NDLHQ:${PDSCH_SUCC_ANY_64TBL_BR}>0
...    NRCELL-14:NDLHQ:${PDSCH_UNSUCC_64TBL_BR}=0
...    NRCELL-12:DHQLSE:${PDSCH_INITX_LOWSE_HRD_PRFL1}>0
...    NRCELL-12:DHQLSE:${PDSCH_SUCC_INI_LOWSE_HRD_PRFL1}>0
...    NRCELL-12:DHQLSE:${PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1}>0
...    NRCELL-12:DHQLSE:${PDSCH_UNSUCC_LOWSE_HRD_PRFL1}=0
...    NRCELL-14:DHQLSE:${PDSCH_INITX_LOWSE_HRD_PRFL1}=0
...    NRCELL-14:DHQLSE:${PDSCH_SUCC_INI_LOWSE_HRD_PRFL1}=0
...    NRCELL-14:DHQLSE:${PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1}=0
...    NRCELL-14:DHQLSE:${PDSCH_UNSUCC_LOWSE_HRD_PRFL1}=0

@{PM_Counters_Check_K16}
...    NRCELL-1:NCAC:${HRDRB_TRIGG_REL_SCELL_ATT_SA}=0
...    NRCELL-1:NCAC:${HRDRB_TRIGG_REL_SCELL_SUC_SA}=0
...    NRCELL-1:NCAC:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-1:NCAC:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-1:NCAC:${DL_RRC_FEXTSCELL_REL_ATT_SA}=0
...    NRCELL-1:NCAC:${DL_RRC_FEXTSCELL_REL_SUC_SA}=0
...    NRCELL-1:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-1:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-1:NCAC:${UL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-1:NCAC:${UL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-1:NCAC:${INA_PRO_REL_SCELL_ATT_SA}=0
...    NRCELL-1:NCAC:${INA_PRO_REL_SCELL_SUC_SA}=0
...    NRCELL-1:NCAC:${INA_OVHT_REL_SCELL_ATT_SA}=0
...    NRCELL-1:NCAC:${INA_OVHT_REL_SCELL_SUC_SA}=0
...    NRCELL-2:NCAC:${HRDRB_TRIGG_REL_SCELL_ATT_SA}=0
...    NRCELL-2:NCAC:${HRDRB_TRIGG_REL_SCELL_SUC_SA}=0
...    NRCELL-2:NCAC:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-2:NCAC:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-2:NCAC:${DL_RRC_FEXTSCELL_REL_ATT_SA}=0
...    NRCELL-2:NCAC:${DL_RRC_FEXTSCELL_REL_SUC_SA}=0
...    NRCELL-2:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-2:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-2:NCAC:${UL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-2:NCAC:${UL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-2:NCAC:${INA_PRO_REL_SCELL_ATT_SA}=0
...    NRCELL-2:NCAC:${INA_PRO_REL_SCELL_SUC_SA}=0
...    NRCELL-2:NCAC:${INA_OVHT_REL_SCELL_ATT_SA}=0
...    NRCELL-2:NCAC:${INA_OVHT_REL_SCELL_SUC_SA}=0

...    NRCELL-1:NDLHQ:${PDSCH_INITX_64TBL_BR}>0
...    NRCELL-1:NDLHQ:${PDSCH_SUCC_INI_64TBL_BR}>0
...    NRCELL-1:NDLHQ:${PDSCH_SUCC_ANY_64TBL_BR}>0
...    NRCELL-1:DHQLSE:${PDSCH_INITX_LOWSE_HRD_PRFL1}=0
...    NRCELL-1:DHQLSE:${PDSCH_SUCC_INI_LOWSE_HRD_PRFL1}=0
...    NRCELL-1:DHQLSE:${PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1}=0
...    NRCELL-1:DHQLSE:${PDSCH_UNSUCC_LOWSE_HRD_PRFL1}=0
...    NRCELL-2:DHQLSE:${PDSCH_INITX_LOWSE_HRD_PRFL1}=0
...    NRCELL-2:DHQLSE:${PDSCH_SUCC_INI_LOWSE_HRD_PRFL1}=0
...    NRCELL-2:DHQLSE:${PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1}=0
...    NRCELL-2:DHQLSE:${PDSCH_UNSUCC_LOWSE_HRD_PRFL1}=0

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
${INA_PRO_REL_SCELL_ATT_SA}    M55118C10511
${INA_PRO_REL_SCELL_SUC_SA}    M55118C10512
${INA_OVHT_REL_SCELL_ATT_SA}    M55118C10513    #The number of SCells to be released on PCell due to inactivity while UE is overheating for SA
${INA_OVHT_REL_SCELL_SUC_SA}    M55118C10514    #The number of SCells released on PCell due to inactivity while UE is overheating for SA

@{recover_online}
...    NRCELL-13:actLAForHiReliab=true
...    NRCELL:actDl256Qam=false
...    NRCELL:actUl256Qam=false

@{enable_256qam}
...    NRCELL-2:actDl256Qam=true
...    NRCELL-2:actUl256Qam=true

@{RRE_pass_regexp}
...    NR RRC Reestablishment sucessfully completed
...    mcs-Table:::3

*** Test Cases ***
CB008246_K02_SA_A1_Scell_Addition_FFF
    [Documentation]
    ...    1. HR DRB setup before/after Intra-GNB CA addition, FAF deactivated/activated on pcell or scell
    ...    2. Configuration
    ...    a.SA+NSA,FDD
    ...    b.UE1, pcell NRCELL-14 FAF deactivated,scell NRCELL-11 and NRCELL-13 FAF activated.
    ...      UE2, pcell NRCELL-12 and scell NRCELL-11/NRCELL-13 are FAF activated.
    ...      UE3, pcell NRCELL-12 and scell NRCELL-11 are FAF activated, scell NRCELL-13 is FAF deactivated.
    ...    c.drb 5QI_7 is UL HR; drb 5QI_80 is DL HR with AM mode; drb 5QI_4 is HR GBR.
    ...    d.UE1 and UE3 are capable of High Reliability, UE2 is normal UE.
    ...    3. Test Case Steps:
    ...    a.UE1 attach on NRCELL-14, UE2 and UE3 attach on NRCELL-12.
    ...    b.trigger A1 for 3 UEs to add scell.
    ...    c.delete and setup HR on 3 UEs.
    ...    d.trigger A1 again for UE3.
    ...    e.release UEs.
    [Tags]    QC_324088    owner-kexin.bao
    Clear Counter Files
    UE1 Attach then Send A1 to Add Scell
    UE2 Attach then Send A1 to Add Scell
    UE3 Attach then Send A1 to Add Scell
    DRB Operation After CA
    2nd CA for 3rd UE
    Release 3UE    ue_id_1=1    ue_id_2=2    ue_id_3=3
    Check Counters    ${PM_Counters_Check_K02}
    check wireshark log    ${CURDIR}${/}a2a_CB008246_K02${/}a2a.ini    wait_string=UEContextReleaseComplete::12
    OnlineParamChange    ${recover_online}

CB008246_K16_SA_Blind_Scell_Addtion_FFF_FAF_Activated_Pcell_Scells_After_nonGBR_CG_DRB_Setup_Alt15
    [Documentation]
    ...    1. CG2 DRB setup before/after Intra-GNB CA addition and HR DRB setup , FAF activated on pcell and scell
    ...    2. Configuration
    ...    a.SA+NSA,TDD/FDD
    ...    b.UE4 which is capable of High Reliability and CG2, pcell NRCELL-1,scell NRCELL-2 and NRCELL-11, blind.
    ...      UE2 which is capable of CG2 only, pcell NRCELL-2 and scell NRCELL-11/NRCELL-12,blind.
    ...      UE5 which is capable of High Reliability and CG2, pcell NRCELL-2 and scell NRCELL-11/NRCELL-12,blind.
    ...    c.NRCELL-1 is 256Qam disabled, NRCELL-2 is 256Qam enabled.
    ...    d.drb 5QI_7 is UL HR; drb 5QI_80 is DL HR with AM mode; drb 5QI_4 is HR GBR.
    ...    e.drb 5QI_80 and 5QI_6 are configured with NRULCG_PROFILE-1.
    ...    3. Test Case Steps:
    ...    a.UE4 attach on NRCELL-1, UE2 and UE5 attach on NRCELL-2, scells are added with blind scelladdtionmethod.
    ...    b.delete and setup HR on 3 UEs.
    ...    c.make UE4 RRE several times.
    ...    d.release UEs.
    [Tags]    QC_324084    owner-kexin.bao
    Prepare for Test
    UE4 Attach and CA Success
    UE4 RRE Twice
    UE4 3rd RRE
    UE Deregister From gNB    ue_id=4
    check wireshark log    ${CURDIR}${/}a2a_CB008246_K16${/}a2a.ini    wait_string=UEContextReleaseComplete::12
    Check Counters    ${PM_Counters_Check_K16}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=4000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7 default=on
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=9 5qi=80
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_Capa_Support_HRLA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_Capa_not_Support_HRLA_support_CG2}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE_Capa_Support_HRLA}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${UE_Capa_Support_HRLA_CG2}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${UE_Capa_Support_HRLA_CG2}

UE Attach To Target Cell with Pass Regexep
    [Arguments]    ${ue_id}    ${cell_id}    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_regexp}

UE Attach To Target Cell with Fail Regexep
    [Arguments]    ${ue_id}    ${cell_id}    ${fail_regexp}=mcs-Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    fail_regexp=${fail_regexp}

Trigger A1 Event
    [Arguments]    ${ue_id}    ${carrierfreq}    ${rsrp}    ${pass_regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrp}
    Sleep    1s    sleep for add scell
    Execute Egate Command    ${cmd}    ${pass_regexp}

Send Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=150 trf_id=9    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=150 trf_id=10    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput For 3CC
    [Arguments]    ${ue_id}=1    ${scell1_id}=1    ${scell2_id}=2    ${total_dl_tput}=270    ${ul_tput}=45
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell1_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell2_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${scell2_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul_tput}

UE1 Attach then Send A1 to Add Scell
    UE Attach To Target Cell with Fail Regexep    ue_id=1    cell_id=14
    Trigger A1 Event    ue_id=1    carrierfreq=126750    rsrp=100    pass_regexp=${scells_add_success}
    Send Throuput    ue_id=1    pdu_id=1    qfi=1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 3CC    ue_id=1    scell1_id=1    scell2_id=2    total_dl_tput=100    ul_tput=20

UE2 Attach then Send A1 to Add Scell
    OnlineParamChange    NRCELL:actDl256Qam=true
    UE Attach To Target Cell with Pass Regexep    ue_id=2    cell_id=12    pass_regexp=mcs-Table:::1
    Trigger A1 Event    ue_id=2    carrierfreq=126750    rsrp=100    pass_regexp=${scells_add_success}
    Send Throuput    ue_id=2    pdu_id=1    qfi=1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 3CC    ue_id=2    scell1_id=1    scell2_id=2    total_dl_tput=100    ul_tput=20

UE3 Attach then Send A1 to Add Scell
    OnlineParamChange    NRCELL-13:actLAForHiReliab=false
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1
    UE Attach To Target Cell with Pass Regexep    ue_id=3    cell_id=12    pass_regexp=mcs-Table:::1
    Trigger A1 Event    ue_id=3    carrierfreq=126750    rsrp=100    pass_regexp=${scells_add_success}
    Send Throuput    ue_id=3    pdu_id=1    qfi=1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 3CC    ue_id=3    scell1_id=1    scell2_id=2    total_dl_tput=100    ul_tput=20

Setup 2nd PDU for 3rd UE
    Execute Egate Command    qosflow_modify default=on qos_flow=7 priority=1
    Execute Egate Command    set_pdu_param ue=3 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=3 pdu=2 gw=2 nwslice=1    pass_regexp=sCellToReleaseList    fail_regexp=mcs-Table

DRB Operation After CA
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=8 qosflows_to_del=7 by=amf    fail_regexp=mcs-Table
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=7 by=amf    fail_regexp=mcs-Table
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=9 qosflows_to_del=7 by=amf    fail_regexp=mcs-Table
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=8 by=amf    fail_regexp=mcs-TableTable
    Execute Egate Command    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=7 by=amf    sCellToReleaseList
    Execute Egate Command    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=4 qosflows_to_del=7 by=amf    pass_regexp=mcs-Table:::1

2nd CA for 3rd UE
    Trigger A1 Event    ue_id=3    carrierfreq=126750    rsrp=100    pass_regexp=${scells_add_success}
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 3CC    ue_id=3    scell1_id=1    scell2_id=2    total_dl_tput=100    ul_tput=10
    Setup 2nd PDU for 3rd UE

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Release 3UE
    [Arguments]    ${ue_id_1}    ${ue_id_2}    ${ue_id_3}
    UE Deregister From gNB    ue_id=${ue_id_1}
    UE Deregister From gNB    ue_id=${ue_id_2}
    UE Deregister From gNB    ue_id=${ue_id_3}

Trigger RRC Reestablish with Pass Regexp
    [Arguments]    ${ue_id}    ${cell_id}    ${cause}    ${RRE_pass_regexp}
   Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}    pass_regexp=${RRE_pass_regexp}    timeout=20s

Trigger RRC Reestablish with Fail Regexp
    [Arguments]    ${ue_id}    ${cell_id}    ${cause}    ${RRE_fail_regexp}
   Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}    fail_regexp=${RRE_fail_regexp}    timeout=20s

UE4 Attach and CA Success
    UE Attach To Target Cell with Pass Regexep    ue_id=4    cell_id=1    pass_regexp=mcs-Table:::1
    Execute Egate Command    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_add=7 by=amf    fail_regexp=mcs-Table
    Send Throuput    ue_id=4    pdu_id=1    qfi=2
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 3CC    ue_id=4    scell1_id=1    scell2_id=2    total_dl_tput=100    ul_tput=20
    Execute Egate Command    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_add=9 by=amf    pass_regexp=mcs-Table:::3
    Execute Egate Command    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_del=6 by=amf    pass_regexp=mcs-Table:::1

UE4 RRE Twice
    Trigger RRC Reestablish with Pass Regexp    ue_id=4    cell_id=1    cause=handoverFailure    RRE_pass_regexp=${RRE_pass_regexp}
    Trigger RRC Reestablish with Pass Regexp    ue_id=4    cell_id=2    cause=handoverFailure    RRE_pass_regexp=${RRE_pass_regexp}
    Execute Egate Command    ue_ng_ctx_release id=4 by=amf cause=RN_successful_handover    UE Context Release Complete
    Execute Egate Command    ue_im_exit id=4 by=ue    mcs-Table:::5
    Execute Egate Command    set_pdu_param ue=4 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_add=5 by=amf    fail_regexp=mcs-Table
    Execute Egate Command    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_add=1,6 by=amf    pass_regexp=mcs-Table:::2

UE4 3rd RRE
    Trigger RRC Reestablish with Fail Regexp    ue_id=4    cell_id=1    cause=otherFailure    RRE_fail_regexp=mcs-Table
    Execute Egate Command    ue_ng_ctx_release id=4 by=amf cause=RN_successful_handover    UE Context Release Complete
    Execute Egate Command    ue_im_exit id=4 by=ue    pass_regexp=mcs-Table:::2
    Execute Egate Command    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_del=1 by=amf    pass_regexp=mcs-Table:::3
    Execute Egate Command    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_del=6,9 by=amf    pass_regexp=mcs-Table:::1

Prepare for Test
    Setup emss     enb_id=1 
    # 13.02.2024 - added to maintain current TC scope, not compliant with latest NIDD (validation error)
    Configure   {'MOC': 'NRDRB', 'ID': 12, 'nrPdschHRLaDN': ''}    
    Configure   {'MOC': 'NRDRB', 'ID': 17, 'nrPuschHRLaDN': ''}    
    OnlineParamChange    ${enable_256qam}
    Clear Counter Files
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
