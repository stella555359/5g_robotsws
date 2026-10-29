*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-Meredith.Ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CB008246    release-SBTS24R1
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
...    @{8246_related_modification}
...    @{8246_G_related_modification}
...    @{8246_G_5qi3_modification}
...    @{8246_G_5qi2_modification}
...    @{8246_H_related_modification}
...    @{8124_related_modification}
...    @{intragnb_interfreq_HO}
...    @{5GC000706_Base}
...    @{NRADJNRCELL}
...    @{NRHOIF}
...    @{NRREL}
...    @{NRADJGNB}

@{8246_related_modification}
...    NRCELL:actUl256Qam=true
...    NRCELL:actDl256Qam=true
...    NRCELL:actLAForHiReliab=true
...    NRCELL:actCceSplit=false
...    NRCELL:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL:pdschHrLaConfig:dllaIniMcsHR=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=20
...    NRBTS/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
...    NRBTS/NRDRB-11:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS/NRDRB-14:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-14:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-14:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1

@{8246_G_related_modification}
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=200
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=3
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=110
...    NRBTS/NRPMRNL-1:miNrUlHarqOne=5min
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20

@{8246_G_5qi3_modification}
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actGBRAdmissionControl=GBRService
...    NRCELL:maxGBRTrafficLimit=6
...    NRBTS/NRDRB-16:discardTimer=100ms
...    NRBTS/NRDRB-16:dscp=46
...    NRBTS/NRDRB-16:l2OHFactorDl=16
...    NRBTS/NRDRB-16:l2OHFactorUl=33
...    NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=true
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:resType=GBR
...    NRBTS/NRDRB-16:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-16:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB-16:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-16:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_MAC-3:delayTarget=50
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=5
...    NRBTS/NRDRB-16:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-16:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-16:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1

@{8246_G_5qi2_modification}
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=2
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB-17:discardTimer=100ms
...    NRBTS/NRDRB-17:dscp=46
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=33
...    NRBTS/NRDRB-17:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-17:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-17:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_UM
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-17:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRCELL:cellBwpList:actUpperThrAckNackHrFiltering=false|cellBwpId=0
...    NRCELL:cellBwpList:actUpperThrAckNackFiltering=false|cellBwpId=0
...    NRCELL:cellBwpList:actUpperThrAckNackHrFiltering=true|cellBwpId=1
...    NRCELL:cellBwpList:actUpperThrAckNackFiltering=true|cellBwpId=1
...    NRCELL:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5|cellBwpId=0
...    NRCELL:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54|cellBwpId=1

@{8246_H_related_modification}
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
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
...    NRCELL:scalingStepdownHREnabled=true
...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerOutagePercentage=50
...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerOutagePeriod=20
...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh64qam=7000
...    NRBTS/NRPUSCHHRLA-1:ullaBlerTargetHR=10
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh64qam=7000
...    NRBTS/NRPUSCHHRLA-2:ullaBlerTargetHR=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=dynamic
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:aggregationLevelListHR=AL2_AL4_AL8
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:cqiCorrectionUpHR=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl16HR=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl1HR=106
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl2HR=74
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl4HR=45
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl8HR=37
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:highOlcCqiOffsetHR=50
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:lowOlcCqiOffsetHR=1100
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:pCqiErasureActTimerHR=160
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:pCqiErasureReductionHR=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelHRSet:pdcchCqiOffsetHR=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:aggregationLevelList=AL2_AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:cqiCorrectionUp=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl1=159
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl16=159
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl2=159
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl4=159
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl8=159
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:highOlcCqiOffset=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:lowOlcCqiOffset=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureReduction=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1:alSelection=dynamic
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:aggregationLevelListHR=AL2_AL4_AL8
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:cqiCorrectionUpHR=2
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl16HR=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl1HR=106
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl2HR=74
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl4HR=45
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl8HR=37
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:highOlcCqiOffsetHR=50
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:lowOlcCqiOffsetHR=1100
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:pCqiErasureActTimerHR=160
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:pCqiErasureReductionHR=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:pdcchCqiOffsetHR=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:aggregationLevelList=AL2_AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:cqiCorrectionUp=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl1=159
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl16=159
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl2=159
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl4=159
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl8=159
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:highOlcCqiOffset=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:lowOlcCqiOffset=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureReduction=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=192
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actUlCgType2=true
...    NRBTS/NRDRB-12:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #5qi=7
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=36
...    NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=20

@{5GC000706_Base}
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250

...    MRBTS-1/NRBTS-1/NRCELL-1:cbraPreamblesPerSsb=n60
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-1:actCDrx=false
...    MRBTS-1/NRBTS-1/NRCELL-1:gapOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:mgta=ms0dot5
...    MRBTS-1/NRBTS-1/NRCELL-1:reportIntervalSA=ms120
...    MRBTS-1/NRBTS-1/NRCELL-1:reportOnLeave=false
...    MRBTS-1/NRBTS-1/NRCELL-1:reportAmountSA=r4
...    MRBTS-1/NRBTS-1/NRCELL-1:ifhoSsbSmtcOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=10
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms64
...    TRACKINGAREA-200:fiveGsTac=0
...    MRBTS-1/NRBTS-1/XNLINK-3:cPlaneIpAddr=10.0.1.122

@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200

@{NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160

@{NRREL}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-3:xnLinkRef=3
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS:rrcReestabTypeSA=sameGNB

@{intragnb_interfreq_HO}
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7847
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=633330
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:lcrId=2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS:rrcReestabTypeSA=sameGNB

${UE_Capa_Support_HRLA_DL_UL}    SEPARATOR=
...    EDA09000577F0140502D098B0041E19000B0498B800CE1E84804D9361CF9863CA160704C020311C03EE3614606B04610D04083A412036B64C558D0E7
...    C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0004C06038002100301506C41D608C21A0810788240656C98AB121CFB027C4
...    71E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000130180E0008400C0551B137582308682041D2090185B262A88873E238F11C7A067D813
...    E31CF9863CA1607038782E007FE003801FF800260301C001080180A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F2
...    8581C0E1E13FFE00000FFF800000980C0700042006003DE1E26800710400000858081507850001C46000002160561E23000710400001858158785000
...    1C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A00
...    1C46000E230000020B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E2
...    30000020B02B1713400388C001C28000008160561E230007118000018581007011A014404D80821E81760F851226C73E1C28913639F0E14489B1CF87
...    0A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F022408103639F022408103639F022408103639F022408103639F0224081036
...    39F022408103639F0214081B1CF8002E1E318C6318C6318C6318C3D04C00F000A070500703009401C0018090010180A000000000090020060F824008
...    00000004000008020000000100000200800002004000018020000100100000A008004010040100000C00800007004002000000080000800400004802
...    00000C010000140080000B004002048120080000C0331528A940A2031032815452A26500A80D402202103A0682000012CA4A080000CB29282000052C
...    A48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA4808
...    00018B292019855585548551855080B080B080D0853084D08030805084D480F01202F012A05028140A05028140A05028140A05028140A05028003040
...    40300601002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C0201803040
...    400802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

${UE_Capa_not_Support_HRLA}    SEPARATOR=
...    EDA09000577F0140502D098B0041E19000B0498B800CE1E84804D9061CF9863CA160704C020311C03EE3614606B04610D04083A412036B64C558D0E7
...    C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0004C06038002100301506C41D608C21A0810788240656C98AB121CFB027C4
...    71E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000130180E0008400C0551B137582308682041D2090185B262A88873E238F11C7A067D813
...    E31CF9863CA1607038782E007FE003801FF800260301C001080180A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F2
...    8581C0E1E13FFE00000FFF800000980C0700042006003DE1E26800710400000858081507850001C46000002160561E23000710400001858158785000
...    1C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A00
...    1C46000E230000020B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E2
...    30000020B02B1713400388C001C28000008160561E230007118000018581007011A014404D80821E81760F851226C73E1C28913639F0E14489B1CF87
...    0A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F022408103639F022408103639F022408103639F022408103639F0224081036
...    39F022408103639F0214081B1CF8002E1E318C6318C6318C6318C3D04C00F000A070500703009401C00180900101808000000000F824008000000040
...    00008020000000100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010
...    000140080000B004002048120080000C0331528A940A2031032815452A26500A80D402202103A0682000012CA4A080000CB29282000052CA48080001
...    CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292
...    019855585548551855080B080B080D0853084D08030805084D480F01202F012A05028140A05028140A05028140A05028140A05028003040403006010
...    02004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010
...    020086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
CB008246_J16_PDU_modify_CG_DRB_then_HR_DRB_then_intragNB_HO_then_RRE
    [Documentation]
    ...    1. This user scenario the gNB behaviour for the successful interaction of Configured Grants Type2 configuration
    ...    with link adaptation for high reliability in UL
    ...    2. Configuration
    ...    a.SA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.HR and CG are setup.
    ...    b.Trigger Intra-gNB HO.HR and CG are setup.
    ...    c.UE detach.
    [Tags]    QC_324702
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA_DL_UL}
    ICS With PDU    ue_id=1    cell_id=1
    UE Triggers Inter-Frequency Intra-gNB HO
    Trigger RRE
    Verify Throuput    ue_id=1
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_J16${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_J19_ICS_256QAM_setup_CG_DRB_then_PDU_setup_HR_DRB_then_intergNB_NGHO
    [Documentation]
    ...    1. This user scenario the gNB behaviour for the successful interaction of Configured Grants Type2 configuration
    ...    with link adaptation for high reliability in UL
    ...    2. Configuration
    ...    a.SA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.HR and CG are setup.
    ...    b.Trigger Inter-gNB HO.HR and CG are setup.
    ...    c.UE detach.
    [Tags]    QC_324817
    XN setup
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA_DL_UL}
    ICS With PDU    ue_id=1    cell_id=1
    UE Triggers Inter-Frequency Inter-gNB HO
    Verify Throuput    ue_id=1
    UE Deregister From gNB    ue_id=1

CB008246_J20_ICS_256QAM_setup_CG_DRB_then_PDU_modify_HR_DRB_then_release_CG_and_HR_DRB_and_add_HR_DRB
    [Documentation]
    ...    1. This user scenario the gNB behaviour for the successful interaction of Configured Grants Type2 configuration
    ...    with link adaptation for high reliability in UL
    ...    2. Configuration
    ...    a.SA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.HR and CG are setup.
    ...    b.Release HR DRB
    ...    c.Release CG DRB
    ...    d.UE detach.
    [Tags]    QC_324146
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA_DL_UL}
    ICS With PDU    ue_id=1    cell_id=1
    DRB Release
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_J20${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_J21_ICS_256QAM_setup_CG_DRB_then_PDU_modify_HR_DRB_UE_not_capable_UL256QAM_ULqam64lowse
    [Documentation]
    ...    1. This user scenario the gNB behaviour for the successful interaction of Configured Grants Type2 configuration
    ...    with link adaptation for high reliability in UL
    ...    2. Configuration
    ...    a.SA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.HR and CG are setup.
    ...    b.Release HR DRB
    ...    c.Release CG DRB
    ...    d.UE detach.
    [Tags]    QC_324145
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_not_Support_HRLA}
    ICS With PDU UE not capable    ue_id=1    cell_id=1
    Verify Throuput    ue_id=1
    UE Deregister From gNB    ue_id=1

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

XN setup
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=3 sa_ho=xn_based
    Execute Egate Command    smf_param id=1 reset
Trigger RRE
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure    rrcReconfigurationComplete

DRB Release
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=6,7 qosflows_to_add=9 by=amf
    ...    RESOURCE MODIFY RESPONSE

UE Triggers Inter-Frequency Intra-gNB HO
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11    pass_regexp=eventA3
    sleep    2s    for HO procedure
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=5 event=A5 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ${ho_log}    Remove Blank Character    ${ho_log}
    Should Contain    ${ho_log}    spCellConfigCommon{physCellId51

UE Triggers Inter-Frequency Inter-gNB HO
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11    pass_regexp=eventA3
    sleep    3s    for HO interval
    Send A3 MR Then HO
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=qam64LowSE:::3
    sleep    5s    for tput stable

Send A3 MR Then HO
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ${ho_log}    Remove Blank Character    ${ho_log}
    Should Contain    ${ho_log}    spCellConfigCommon{physCellId381
    sleep    3s    for HO interval

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=4000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 default=on
    Update Cfg    set_qosflow id=9 5qi=9
    ${set_gnb2}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${set_gnb2}
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633372:633372
    ...    gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_gnb3_cell2}    catenate    set_cell id=2 gnb=3 pci=127:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell2}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput
    [Arguments]    ${ue_id}
    sleep    10s    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=dl    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>1.8
    Should Be True    ${ul_throughput1}/1000>1.8
    Should Be True    ${dl_throughput2}/1000>1.8
    Should Be True    ${ul_throughput2}/1000>1.8

ICS With PDU
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    Setup QosFlow with QFI
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=6 by=amf    RESOURCE MODIFY RESPONSE
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul mbps=2

ICS With PDU UE not capable
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    fail_regexp=qam64LowSE
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=6 by=amf    fail_regexp=qam64LowSE
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul mbps=2
