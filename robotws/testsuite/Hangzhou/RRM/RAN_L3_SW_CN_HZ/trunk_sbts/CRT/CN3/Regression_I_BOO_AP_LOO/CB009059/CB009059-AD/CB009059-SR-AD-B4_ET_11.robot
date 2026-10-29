*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-pei.han    team-CN3ET    release-SBTS24R2
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${AP_BIP_FLAG}    ${False}
${GNB_BIP_FLAG}    ${False}

@{PARAMS_IN_SCF}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=10
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_CB008311}
...    @{PARAMS_FOR_CB008246}
...    @{PARAMS_FOR_CA}
...    @{VONR}
...    @{AperCsi}
...    @{8290_Enable}
...    NRCELL-1/NRCELL_FDD-1:nrarfcnDl=125180
...    NRCELL-1/NRCELL_FDD-1:nrarfcnUl=134380
...    NRCELL-1/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-1/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-1:gscnOrSsPbchArfcn=1564
...    NRCELL-1:type0CoresetConfigurationIndex=0
...    NRCELL-3/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-3/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-3/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-3/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-3:gscnOrSsPbchArfcn=1589
...    @{PARAMS_TO_USE_RECOMMAND_FOR_PDCCH}

@{PARAMS_TO_USE_RECOMMAND_FOR_PDCCH}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|coresetId=0
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRCELL-1:dlMcsDowngradeForHr=disabled
...    NRCELL-1:ulMcsDowngradeForHr=disabled
...    NRCELL-1:cellBwpList:actPdcchCceFragmentControl=false|actUpperThrAckNackFiltering=false
...    NRCELL-1:cellBwpList:actUpperThrAckNackHrFiltering=true|actUpperThrAckNackFiltering=true
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-14|actUpperThrAckNackFiltering=true
...    NRCELL-1:cellBwpList:cellBwpId=1|actUpperThrAckNackFiltering=true
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-2:actLAForHiReliab=false
...    NRCELL-2:increasePUSCHPrepTimeULCA=false
...    NRCELL-3:dlMcsDowngradeForHr=disabled
...    NRCELL-3:ulMcsDowngradeForHr=disabled
...    NRCELL-4:actLAForHiReliab=false
...    NRCELL-4:increasePUSCHPrepTimeULCA=false
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDU-1:flexibleCAMode=NumberCellAmount

@{PARAMS_FOR_9059}
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA
...    NRBTS/NRDRB-10:cellAggrLevel=Not FR1 CA eligible    #5QI-5
...    NRBTS/NRDRB-11:cellAggrLevel=FR1 CA eligible    #5QI-6
...    NRBTS/NRDRB-12:cellAggrLevel=Not FR1 CA eligible    #5QI-7
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA incompatible    #5QI-8
...    NRBTS/NRDRB-14:cellAggrLevel=FR1 CA eligible    #5QI-9

@{PARAMS_FOR_CB008311}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=5
...    NRCELL:dlSCellConfigLevelNum=5
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:sCellInactivityReleaseTimer=300
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actSCellReleaseForInactiveSCell=disabled

@{PARAMS_FOR_CB008246}
...    NRCELL:actLAForHiReliab=true
...    NRCELL:scalingStepdownHREnabled=true
...    NRCELL:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL:pdschHrLaConfig:dllaIniMcsHR=3
...    NRCELL:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMaxHR=15
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMinHR=-30
...    NRCELL:puschHrLaConfig:ullaDeltaSinrStepdownHR=2
...    NRCELL:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL:puschHrLaConfig:ullaSinrOffsetHR=2
...    NRBTS/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-2/NRPDSCHHRLA-1    #5QI-6
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-2/NRPUSCHHRLA-1    #5QI-6
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-2/NRPDSCHHRLA-1    #5QI-7
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-2/NRPUSCHHRLA-1    #5QI-7
...    NRBTS/NRDRB-13:nrPdschHRLaDN=MRBTS-1/NRBTS-2/NRPDSCHHRLA-1    #5QI-8
...    NRBTS/NRDRB-13:nrPuschHRLaDN=MRBTS-1/NRBTS-2/NRPUSCHHRLA-1    #5QI-8
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=10
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=10
...    NRBTS/NRPUSCHHRLA-1:ullaBlerTargetHR=10
...    NRBTS/NRPUSCHHRLA-2:ullaBlerTargetHR=10
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-14/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Fdd_Sa_WithUl

@{PARAMS_FOR_CA}
...    @{NRREL}
...    NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:dlToUlContributionRatio=101
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:weightForSCellSelection=50
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBcsCheck=disabled
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518670
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=636576
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gNbId=2
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-1:sCellPrio=1
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:gNbId=2
...    NRCELL-2/NRREL-2:lcrId=3
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-2:sCellPrio=2

@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRBTS/NRDRB-15:discardTimer=1500ms
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1
#...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_PDCP-3:maxCidAllowed=${EMPTY}
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=${EMPTY}
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible

@{AperCsi}
...    NRCELL:actAperCsi=true

@{8290_Enable}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66

${UE_Capa_Support_HRLA}    SEPARATOR=
...    F9A0700047D0FFA17DF8E6BC520001A0349CF9A44F3E005800C41FE03E0300FC700FBCF89A01EF7ADC341914083800001D708800A2D92D502
...    C09F21CFA023C639F30C7942C0E070F0527FC9FF1C20001B280002800001BCE08201EF7ADC341914083800001D708800A2D92D502C09F21CF
...    A023C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C220028B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF85001E
...    F7ADC341914083800001D708800A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF1C20001B2800028000002941E140006134000
...    0120561C1401C4D000002120541E2300060A00004120541C2301C28000006120400E1400000450788C00184D0002848158708C07134000030
...    48150788C001C4D00000E130158788C001C28000010130150788C0018460004808380380510136020C0461D4000DE0A853A76C73E1C29D3B6
...    39F0E14E9DB1CF870A74ED8E7C3813B639F0E14E9DB1CF870A74ED8E7C3853A76C73E1C20D8E7C3841B1CF86002214318C60318C6303F8000
...    00230003E002B1C1401C0FC24007030006000F80872D0000070072D0000170072D0000270072D0000370072D00004700023282F2A2B032B29
...    2B0328060C000000C000300002830000C000100C0003000060300001B94417CAA0AE070572982878008802783C1E0F0780002420200400808
...    0200010100200004010020808030060200400040401800010020040020100204040280301004000202014000080200410500A00E00C01C028
...    03050020060100240100208080500602004008404028030100A0006A01C000810181C6C949C93C0A0300A400

${UE_Capa_Support_HRLA_NoCapa_AperCsi_When_FTCA}    SEPARATOR=
...    F9A0700047D0FFA17DF8E6BC520001A0349CF9A44F3E005800C41FE03E0300FC700FBCF89A01EF7ADC341914083800001D708800A2D92D502
...    C09F21CFA023C639F30C7942C0E070F0527FC9FF1C20001B280002800001BCE08201EF7ADC341914083800001D708800A2D92D502C09F21CF
...    A023C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C220028B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF85001E
...    F7ADC341914083800001D708800A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF1C20001B2800028000001541E140006134000
...    0120561C1401C4D000002120541E2300060A00004120541C2301C28000006120400E1400000400700A2026C041808C3A8000EC0B0A74ED8E7
...    C3853A76C73E1C29D3B609F0E14E9DB1CF870276C73E1802C146318C007F000000460007C005638280381F84800E06000C001F010E5A00000
...    E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046505E54560656525606500C1800000180006000050600018000201800060000C
...    060000372882F95415C0E0AE53050F0011004F0783C1E0F0000404040080101004000202004000080200410100600C0400800080803000020
...    040080040200408080500602008000404028000100400820A01401C018038050060A00400C0200480200410100A00C04008011A8070002040
...    6071B252724F0280C0290

${UE_Capa_Support_HRLA_lch-ToSCellRestriction}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC520001A0349CF9A44F3E005800C41FE03E0300FC700FBCF89A01EF7ADC341914083800001D708800A2D92D502
...    C09F21CFA023C639F30C7942C0E070F0527FC9FF1C20001B280002800001BCE08201EF7ADC341914083800001D708800A2D92D502C09F21CF
...    A023C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C220028B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF85001E
...    F7ADC341914083800001D708800A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF1C20001B2800028000002941E140006134000
...    0120561C1401C4D000002120541E2300060A00004120541C2301C28000006120400E1400000450788C00184D0002848158708C07134000030
...    48150788C001C4D00000E130158788C001C28000010130150788C0018460004808380380510136020C0461D4000DE0A853A76C73E1C29D3B6
...    39F0E14E9DB1CF870A74ED8E7C3813B639F0E14E9DB1CF870A74ED8E7C3853A76C73E1C20D8E7C3841B1CF86002214318C60318C6303F8000
...    00230003E002B1C1401C0FC24007030006000F80872D0000070072D0000170072D0000270072D0000370072D00004700023282F2A2B032B29
...    2B0328060C000000C000300002830000C000100C0003000060300001B94417CAA0AE070572982878008802783C1E0F0780002420200400808
...    0200010100200004010020808030060200400040401800010020040020100204040280301004000202014000080200410500A00E00C01C028
...    03050020060100240100208080500602004008404028030100A0006A01C000810181C6C949C93C0A0300A400

@{Online_For_Case02}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRCELL-2:actLAForHiReliab=false
...    NRCELL-4:actLAForHiReliab=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    delete:NRCELL-1/NRREL-3
...    NRCELL-2:increasePUSCHPrepTimeULCA=false
...    NRCELL-4:increasePUSCHPrepTimeULCA=false
@{Online_For_Case07}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRCELL:actLAForHiReliab=true
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    delete:NRCELL-1/NRREL-3
...    NRCELL-2:increasePUSCHPrepTimeULCA=false
...    NRCELL-4:increasePUSCHPrepTimeULCA=false

@{Online_For_Case07_2}
...    NRCELL-2:actLAForHiReliab=false
...    NRCELL-4:actLAForHiReliab=false

@{Online_For_Case09}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRCELL-2:actLAForHiReliab=false
...    NRCELL-4:actLAForHiReliab=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    delete:NRCELL-1/NRREL-3
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-4:increasePUSCHPrepTimeULCA=true

@{Online_For_Case11}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRCELL-2:actLAForHiReliab=true
...    NRCELL-4:actLAForHiReliab=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    delete:NRCELL-1/NRREL-3
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-4:increasePUSCHPrepTimeULCA=true

@{Online_For_Case12}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRCELL-2:actLAForHiReliab=true
...    NRCELL-3:actLAForHiReliab=true
...    NRCELL-4:actLAForHiReliab=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-4:increasePUSCHPrepTimeULCA=true


*** Test Cases ***
CB009059-SR-AD-B4_ET_11_01_DRB profile based Carrier Aggregation interaction with HRDRB when SCell selection during SCell Addition
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    DRB profile based Carrier Aggregation interaction with HRDRB when SCell selection during SCell Addition.
    ...    2. Test Case Steps:
    ...         Step A. online change Scell TDD Cell-2: actLAForHiReliab=true, Scell TDD Cell-4: actLAForHiReliab=false.
    ...         Step B. UE-1 attach to Cell-1 with FR1 CA eligible high reliability DRB;
    ...         Step C. UE-2 without Lch-ToSCellRestriction capability, attach with FR1 CA eligible normal DRB and
    ...                 Not FR1 CA eligible HRDRB,
    ...         Step D. UE-3 with Lch-ToSCellRestriction capability, attach with FR1 CA eligible normal DRB and
    ...                 Not FR1 CA eligible HRDRB,
    ...    3. Expected Results:
    ...         Step A: site is onair;
    ...         Step B: UL CA setup successfully, TDD Cell-2 as Scell;
    ...         Step C: DL CA setup successfully, TDD Cell-4 as Scell;
    ...         Step D: UL CA setup successfully, TDD Cell-4 as Scell;
    [Tags]    CA_LABLE-FFTT(10MHz_FDD_n71+10MHz_FDD_n71+20MHz_TDD_n41+60MHz_TDD_n78)
    OnlineParamChange    ${Online_For_Case11}
    UE Register    qos_flow=1
    UE PDU Session Setup and Scell selection
    Release UEs    ue_type=all
    UE Register    ue_id=2    qos_flow=2
    UE PDU Session Setup and DL Scell selection    ue_id=2    fiveQi_1=7    PCI=51
    Release UEs    ue_type=all
    UE Register    ue_id=3    qos_flow=2    ue_nr_capabilities=${UE_Capa_Support_HRLA_lch-ToSCellRestriction}
    UE PDU Session Setup and Scell selection    ue_id=3    fiveQi_1=7    PCI=51

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T

Modify Cfg
    Update Cfg    ue_param id=1-30 ue_nr_capabilities=${UE_Capa_Support_HRLA} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=5
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=6
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5,6 qos_rules=1,2 default=on ue=1-30 amf=1

Set UE Parameters Before Attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${qos_flow}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

UE Register
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${qos_flow}=1    ${ue_nr_capabilities}=${UE_Capa_Support_HRLA}
    Set UE Parameters Before Attach    ${ue_id}    ${cell_id}    ${qos_flow}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    pass_regexp=UE now in NG RM Register

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${fiveQi}=6    ${pdu}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${ue_id}
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1

UE PDU Session Setup and Scell selection
    [Arguments]    ${ue_id}=1    ${additional_qosflow}=4    ${fiveQi_1}=6    ${fiveQi_2}=9    ${PCI}=50
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${additional_qosflow}
    @{Blind_ULCA}    create list
    ...    mcs-Table qam64LowSE
    ...    cqi-Table table1
    ...    sCellToAddModList
    ...    downlinkConfigCommon
    ...    uplinkConfigCommon
    ...    pcid:${PCI}, scellIdx:1
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ${cmd}    pass_regexp=${Blind_ULCA}

UE PDU Session Setup and DL Scell selection
    [Arguments]    ${ue_id}=2    ${additional_qosflow}=4    ${fiveQi_1}=6    ${fiveQi_2}=9    ${PCI}=50
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${additional_qosflow}
    @{Blind_DLCA}    create list
    ...    mcs-Table qam64LowSE
    ...    cqi-Table table1
    ...    sCellToAddModList
    ...    downlinkConfigCommon
    ...    pcid:${PCI}, scellIdx:1
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
    @{ULCA}    create list
    ...    uplinkConfigCommon
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ${cmd}    pass_regexp=${Blind_DLCA}    fail_regexp=${ULCA}

UE PDU Session Setup and F-F CA setup
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125090    ${phycell_id}=60
    @{PDU_setup}    create list
    ...    mcs-Table qam64LowSE
    ...    cqi-Table table1
    ...    Created FiveQi:Qfi mapping fiveQi 6 qfi 1
    ...    QoS Routing Table
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ${cmd}    pass_regexp=${PDU_setup}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=65 srsrq_nr=40
    @{F-F_CA}    create list
    ...    sCellToAddModList
    ...    pcid:61, scellIdx:1
    Execute Egate Command    ${A1_Scell_addition}    pass_regexp=${F-F_CA}

UE PDU Session Setup with Multi Qosflow and F-F CA setup
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125090    ${phycell_id}=60
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    @{Multi_Qosflow}    create list
    ...    mcs-Table qam64LowSE
    ...    cqi-Table table1
    ...    Created FiveQi:Qfi mapping fiveQi 9 qfi 1
    ...    Created FiveQi:Qfi mapping fiveQi 7 qfi 2
    ...    QoS Routing Table
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ${cmd}    pass_regexp=${Multi_Qosflow}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=65 srsrq_nr=40
    @{F-F_CA}    create list
    ...    sCellToAddModList
    ...    pcid:61, scellIdx:1
    Execute Egate Command    ${A1_Scell_addition}    pass_regexp=${F-F_CA}

Pcell A1 report to trigger Scell Change and ULCA setup
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125090    ${phycell_id}=60    ${pci}=50
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_change}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    @{Scell_change_ULCA}    create list
    ...    sCellToAddModList
    ...    downlinkConfigCommon
    ...    uplinkConfigCommon
    ...    pcid:${pci}, scellIdx:2
   Execute Egate Command    ${A1_Scell_change}    pass_regexp=${Scell_change_ULCA}

Pcell A1 report to trigger Scell Change and DLCA setup
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125090    ${phycell_id}=60    ${pci}=51
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_change}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    @{Scell_change_CA}    create list
    ...    sCellToAddModList
    ...    downlinkConfigCommon
    ...    pcid:${pci}, scellIdx:2
    @{no_ULCA}    create list
    ...    uplinkConfigCommon
   Execute Egate Command    ${A1_Scell_change}    pass_regexp=${Scell_change_CA}    fail_regexp=${no_ULCA}


UE PDU Session Setup and Scell blind add failed
    [Arguments]    ${ue_id}=1    ${fiveQi}=6    ${pdu}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${ue_id}
    ...    fail_regexp=sCellToAddModList
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1

UE PDU Session Setup with Multi Qosflow and Scell blind add failed
    [Arguments]    ${ue_id}=2    ${additional_qosflow}=4    ${fiveQi_1}=6    ${fiveQi_2}=9
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${additional_qosflow}
    @{Multi_Qosflow}    create list
    ...    mcs-Table qam64LowSE
    ...    cqi-Table table1
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
    @{no_scell}    create list
    ...    sCellToAddModList
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ${cmd}    pass_regexp=${Multi_Qosflow}    fail_regexp=${no_scell}

CA setup failed with FR1 CA eligible HRDRB when Scell does not support HRDRB
    [Arguments]    ${ue_id}=1    ${fiveQi}=6
    UE Register    ${ue_id}    qos_flow=1
    UE PDU Session Setup and Scell blind add failed    ${ue_id}    ${fiveQi}

CA setup failed with FR1 CA eligible Normal DRB and FR1 CA eligible HRDRB when Scell does not support HRDRB
    [Arguments]    ${ue_id}=2
    UE Register    ${ue_id}    qos_flow=1
    UE PDU Session Setup with Multi Qosflow and Scell blind add failed    ${ue_id}


UE PDU Session Setup with AperCsi
    [Arguments]    ${pdu}=1    ${fiveQi}=6    ${ue_id}=1
    @{ICS_with_AperCsi}    create list
    ...    cqi-Table table2
    ...    betaOffsets dynamic
    ...    aperiodicTriggerStateList setup
    ...    QoS Routing Table
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${ue_id}
    ...    pass_regexp=${ICS_with_AperCsi}

Pcell A1 report to trigger Scell Addition to release AperCsi
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125090    ${phycell_id}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    @{Scell_Addition_release_AperCsi}    create list
    ...    csi-ReportConfigToReleaseList
    ...    aperiodicTriggerStateList release : NULL
    ...    sCellToAddModList
    ...    pcid:50, scellIdx:1
    Execute Egate Command    ${A1_Scell_addition}    pass_regexp=${Scell_Addition_release_AperCsi}

Pcell A1 report to trigger ULCA setup
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125090    ${phycell_id}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    @{ULCA}    create list
    ...    sCellToAddModList
    ...    downlinkConfigCommon
    ...    uplinkConfigCommon
    ...    scellIdx:1
    Execute Egate Command    ${A1_Scell_addition}    pass_regexp=${ULCA}

UE Attach with Normal DRB and trigger ULCA
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${qos_flow}=4    ${ue_nr_capabilities}=${UE_Capa_Support_HRLA}
    UE Register    ${ue_id}    ${cell_id}    ${qos_flow}    ${ue_nr_capabilities}
    UE PDU Session Setup    ${ue_id}    fiveQi=9
    Pcell A1 report to trigger ULCA setup    ${ue_id}

UE PDU Session Modify to Add incompatible HRDRB
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=8
    @{Scell_Release}    create list
    ...    mcs-Table qam64LowSE
    ...    uci-OnPUSCH setup
    ...    betaOffsets semiStatic
    ...    cqi-Table table1
    ...    csi-ReportConfigToReleaseList
    ...    aperiodicTriggerStateList setup
    ...    sCellToReleaseList
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=3 by=amf
    ...    pass_regexp=${Scell_Release}

UE PDU Session Modify to Del incompatible HRDRB
    [Arguments]    ${ue_id}=1    ${pdu}=1
    @{incompatible_HRDRB_release}    create list
    ...    pdsch-Config setup
    ...    mcs-Table qam256
    ...    uci-OnPUSCH setup
    ...    betaOffsets dynamic
    ...    cqi-Table table2
    ...    Removed FiveQi:Qfi mapping fiveQi 8 qfi 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=3 by=amf
    ...    pass_regexp=${incompatible_HRDRB_release}

Pcell A1 report to trigger Scell Addition
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125090    ${phycell_id}=60    ${srsrp}=80
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=${srsrp} srsrq_nr=40
    @{Scell_Addition}    create list
    ...    sCellToAddModList
    ...    scellIdx:1
    Execute Egate Command    ${A1_Scell_addition}    pass_regexp=${Scell_Addition}

Pcell A1 report to trigger DL Scell Addition
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125090    ${phycell_id}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    @{Scell_Addition}    create list
    ...    sCellToAddModList
    ...    scellIdx:1
    @{no_UL_Scell_Addition}    create list
    ...    multiplePHR: True
    ...    uplinkConfigCommon
    Execute Egate Command    ${A1_Scell_addition}    pass_regexp=${Scell_Addition}    fail_regexp=${no_UL_Scell_Addition}

UE PDU Session Modify to Add Not FR1 CA eligible HRDRB and Release FR1 CA eligible HRDRB
    [Arguments]    ${ue_id}=1    ${pdu}=1
    @{Scell_Release}    create list
    ...    mcs-Table qam64LowSE
    ...    uci-OnPUSCH setup
    ...    betaOffsets semiStatic
    ...    cqi-Table table1
    ...    csi-ReportConfigToReleaseList
    ...    sCellToReleaseList
    ...    Removed FiveQi:Qfi mapping fiveQi 9 qfi 1
    ...    Created FiveQi:Qfi mapping fiveQi 7 qfi 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 qosflows_to_del=4 by=amf
    ...    pass_regexp=${Scell_Release}


CA release due to Not FR1 CA eligible HRDRB setup and release FR1 CA eligible DRB
    [Arguments]    ${ue_id}=2    ${fiveQi}=9
    UE Register    ${ue_id}    qos_flow=4
    UE PDU Session Setup    ${ue_id}    ${fiveQi}
    Pcell A1 report to trigger Scell Addition    ${ue_id}
    UE PDU Session Modify to Add Not FR1 CA eligible HRDRB and Release FR1 CA eligible HRDRB    ${ue_id}

CA release due to release FR1 CA eligible HRDRB
    [Arguments]    ${ue_id}=3
    UE Register    ${ue_id}    qos_flow=5
    UE PDU Session Setup with Multi Qosflow    ${ue_id}
    Pcell A1 report to trigger Scell Addition    ${ue_id}
    UE PDU Session Modify to Del FR1 CA eligible HRDRB    ${ue_id}

UE PDU Session Setup with Multi Qosflow
    [Arguments]    ${ue_id}=3    ${additional_qosflow}=1    ${fiveQi_1}=5    ${fiveQi_2}=6
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${additional_qosflow}
    @{Multi_Qosflow}    create list
    ...    mcs-Table qam64LowSE
    ...    cqi-Table table1
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ${cmd}    pass_regexp=${Multi_Qosflow}

UE PDU Session Modify to Del FR1 CA eligible HRDRB
    [Arguments]    ${ue_id}=1    ${pdu}=1
    @{FR1_CA_eligible_HRDRB_release}    create list
    ...    pdsch-Config setup
    ...    mcs-Table qam256
    ...    uci-OnPUSCH setup
    ...    betaOffsets dynamic
    ...    cqi-Table table2
    ...    sCellToReleaseList
    ...    Removed FiveQi:Qfi mapping fiveQi 6 qfi 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=1 by=amf
    ...    pass_regexp=${FR1_CA_eligible_HRDRB_release}

CA release due to Scell does not support HRDRB
    [Arguments]    ${ue_id}=4    ${fiveQi}=9
    UE Register    ${ue_id}    qos_flow=4
    UE PDU Session Setup    ${ue_id}    ${fiveQi}
    Pcell A1 report to trigger Scell Addition    ${ue_id}
    UE PDU Session Modify to Add FR1 CA eligible HRDRB when Scell does not support HRDRB    ${ue_id}

UE PDU Session Modify to Add FR1 CA eligible HRDRB when Scell does not support HRDRB
    [Arguments]    ${ue_id}=4    ${pdu}=1
    @{Scell_Not_Support_HRDRB}    create list
    ...    mcs-Table qam64LowSE
    ...    uci-OnPUSCH setup
    ...    betaOffsets semiStatic
    ...    cqi-Table table1
    ...    sCellToReleaseList
    ...    Created FiveQi:Qfi mapping fiveQi 6 qfi 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=1 by=amf
    ...    pass_regexp=${Scell_Not_Support_HRDRB}

UE PDU Session Modify to Add Not FR1 CA eligible HRDRB when Scell does not support HRDRB and UE support Lch-ToSCellRestriction capability
    [Arguments]    ${ue_id}=3    ${pdu}=1
    @{Scell_Not_Support_HRDRB_ULCA}    create list
    ...    t-Reassembly ms15
    ...    allowedServingCells
    ...    mcs-Table qam64LowSE
    ...    uci-OnPUSCH setup
    ...    betaOffsets semiStatic
    ...    cqi-Table table1
    ...    Created FiveQi:Qfi mapping fiveQi 7 qfi 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf
    ...    pass_regexp=${Scell_Not_Support_HRDRB_ULCA}

CA release when Add Not FR1 CA eligible HRDRB when Scell does not support HRDRB and UE not support Lch-ToSCellRestriction capability
    [Arguments]    ${ue_id}=4    ${pdu}=1
    @{Scell_Not_Support_HRDRB_ULCA}    create list
    ...    t-Reassembly ms15
    ...    mcs-Table qam64LowSE
    ...    uci-OnPUSCH setup
    ...    betaOffsets semiStatic
    ...    cqi-Table table1
    ...    sCellToReleaseList
    ...    reportConfigToAddModList
    ...    eventA1
    ...    measIdToAddModList
    ...    measObjectToRemoveList
    ...    measIdToRemoveList
    ...    Created FiveQi:Qfi mapping fiveQi 7 qfi 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf
    ...    pass_regexp=${Scell_Not_Support_HRDRB_ULCA}

ULCA check T-put
    [Arguments]    ${ue_id}=3
    Sent Throughput    ue_id=${ue_id}    qfi_id=2
    Verify DL and UL Throughput pcell and no TP in scells    ue_id=${ue_id}
    Sent Throughput    ue_id=${ue_id}    qfi_id=1
    Verify DL and UL Throughput pcell and scells    ue_id=${ue_id}

UE PDU Session Setup with Multi Qosflow_Normal FR1 CA eligible DRB and Not FR1 CA eligible HRDRB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=4
    @{Multi_Qosflow}    create list
    ...    mcs-Table qam64LowSE
    ...    cqi-Table table1
    ...    betaOffsets semiStatic
    ...    cqi-Table table2
    ...    mcs-Table qam256
    ...    Created FiveQi:Qfi mapping fiveQi 7 qfi 1
    ...    Created FiveQi:Qfi mapping fiveQi 9 qfi 2
    ...    sCellToAddModList
    ...    scellIdx:1
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ${cmd}    pass_regexp=${Multi_Qosflow}

Sent Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${Pcell_Tput_Target}=50    ${Scell1_Tput_Target}=140    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${Pcell_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${Pcell_tput}/1000 > ${Pcell_Tput_Target}
    ${Scell1_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${Scell1_Tput}/1000 > ${Scell1_Tput_Target}

Verify Throughput pcell and no TP in scells
    [Arguments]    ${ue_id}=1    ${Pcell_Tput_Target}=50    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${Pcell_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${Pcell_Tput}/1000 > ${Pcell_Tput_Target}
    ${Scell1_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=current
    Should Be True    ${Scell1_Tput}/1000 == 0

Verify DL and UL Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${Pcell_Tput_Target}=50    ${Scell1_Tput_Target}=140    ${sleep_time}=15s
    ...    ${Pcell_UL_Tput_Target}=20    ${Scell1_UL_Tput_Target}=0
    sleep    ${sleep_time}    sleep for Tput stable
    ${Pcell_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${Pcell_tput}/1000 > ${Pcell_Tput_Target}
    ${Scell1_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${Scell1_Tput}/1000 > ${Scell1_Tput_Target}
    ${Pcell_UL_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${Pcell_UL_tput}/1000 > ${Pcell_UL_Tput_Target}
    ${Scell1_UL_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${Scell1_UL_Tput}/1000 == ${Scell1_UL_Tput_Target}

Verify DL and UL Throughput pcell and no TP in scells
    [Arguments]    ${ue_id}=1    ${Pcell_Tput_Target}=50    ${sleep_time}=15s    ${Pcell_UL_Tput_Target}=20
    sleep    ${sleep_time}    sleep for Tput stable
    ${Pcell_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${Pcell_Tput}/1000 > ${Pcell_Tput_Target}
    ${Scell1_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=current
    Should Be True    ${Scell1_Tput}/1000 == 0
    ${Pcell_UL_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${Pcell_Tput}/1000 > ${Pcell_UL_Tput_Target}
    ${Scell1_UL_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=current
    Should Be True    ${Scell1_Tput}/1000 == 0

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir




