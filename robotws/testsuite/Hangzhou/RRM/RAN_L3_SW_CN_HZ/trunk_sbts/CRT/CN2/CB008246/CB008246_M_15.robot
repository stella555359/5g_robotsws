*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-chunlan.yang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008246    release-SBTS24R1
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

@{8246_related_modification}
...    NRCELL-2:cellDepType=SA
...    delete:NRCELL-2:configuredEpsTac
...    NRCELL-2:actLAForHiReliab=true
...    NRCELL-2:actCceSplit=false
...    NRCELL-2:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-2:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL-2:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL-2:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL-2:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL-2:pdschHrLaConfig:dllaIniMcsHR=3
...    NRCELL-2:scalingStepdownHREnabled=true
...    NRCELL-2:cellBwpList:actPdcchCceFragmentControl=false|actUpperThrAckNackFiltering=false
...    NRCELL-2:cellBwpList:actUpperThrAckNackHrFiltering=true|actUpperThrAckNackFiltering=true
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54|actUpperThrAckNackFiltering=true
...    NRCELL-2:cellBwpList:cellBwpId=1|actUpperThrAckNackFiltering=true
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
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-12:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDU-1:carrierAggregationSupportList=none

@{8246_G_related_modification}
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=200
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=3
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=110
...    NRBTS/NRPMRNL-1:miNrUlHarqOne=5min
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20
...    NRCELL-2:actIncreasedFdmUsersPerSlot=true
...    NRCELL-2:maxNumPdschAllocationPerSlot=16
...    NRCELL-2:maxNumPuschAllocationPerSlot=16

@{8246_G_5qi3_modification}
...    NRCELL-2:actNonVoNRGbrService=true
...    NRCELL-2:actGBRAdmissionControl=GBRService
...    NRCELL-2:maxGBRTrafficLimit=6
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

@{8246_H_related_modification}
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRCELL-2:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL-2:puschHrLaConfig:ullaDeltaSinrMaxHR=150
...    NRCELL-2:puschHrLaConfig:ullaDeltaSinrMinHR=-300
...    NRCELL-2:puschHrLaConfig:ullaDeltaSinrStepdownHR=20
...    NRCELL-2:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL-2:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=25
...    NRCELL-2:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=25
...    NRCELL-2:puschHrLaConfig:ullaMcsMax64qamRANK1HR=25
...    NRCELL-2:puschHrLaConfig:ullaMcsMax64qamRANK2HR=25
...    NRCELL-2:puschHrLaConfig:ullaSinrOffsetHR=20
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

${UE_Capa_Support_HRLA_DL_UL}    SEPARATOR=
...    EDA09000575F5A13160003C320016093170019C3D09009B26C39F30C7942C0E088040623807DC2C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A05883AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA1626EB04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381502C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A000388
...    20000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B171
...    3400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A0
...    00388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8E7C385122
...    6C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C7
...    3E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E0601280380030120
...    02030140000000001200400C1F048010000000080000100400000002000004010000040080000300400002002000014010008020080200001
...    80100000E008004000000100001000800009004000018020000280100001600800409024010000180662A5152814406206502A8A544CA0150
...    1A80440420740D04000025949410000196525040000A594901000039652404000125949010000596524040001A59490100007965240400022
...    5949010000996524040002A5949010000B96525040003259490100003165240330AAB0AA90AA30AA10161016101A10A6109A1006100A109A9
...    01E02405E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C0201803
...    0404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889
...    098A0C0C8D8E0E8F909293139414951697A0A0C168

${UE_Capa_not_Support_HRLA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E088040623807DC2C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A05883AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA1626EB04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381502C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A000388
...    20000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B171
...    3400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A0
...    00388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8E7C385122
...    6C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C7
...    3E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E0601280380030120
...    020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E0080040000
...    00100001000800009004000018020000280100001600800409024010000180662A5152814406206502A8A544CA01501A80440420740D04000
...    025949410000196525040000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040
...    002A5949010000B96525040003259490100003165240330AAB0AA90AA30AA10161016101A10A6109A1006100A109A901E02405E02540A0502
...    8140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C02018030404030060100C01840
...    2004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909
...    293139414951697A0A0C1680

*** Test Cases ***
CB008246_M_15_TDD_BR_setup_ICS_then_add_HRDRB_BRGBR_then_del_HRDRB_increase_GFBR_simul_mcsTable_reconfiguration_rollback
    [Documentation]
    ...    1.Description
    ...      This user scenario validates the gNB behaviour for the release of one or more non-GBR High
    ...      Reliability and increase GFBR of GBR DRB simul and data transmission in DL/UL.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default HR drb 5QI7 are associated with NRPDSCHHRLA and NRPUSCHHRLA profile.
    ...      d.UE support Dl-64QAM-MCS-TableAlt and Ul-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE attach to target cell via ICS, BR 5QI8 is setup via ICS.
    ...      b.Add BR GBR 5QI2 and HR non-GBR 5QI7 via PDU Session Modify.
    ...      c.Release HR non-GBR 5QI7 and increase GFBR of 5QI2 simul.
    ...    4.Check Points
    ...      a.ICS Request procedure complete with 5QI8.
    ...      b.PDU Session Resource Modify procedure complete with 5QI2 and 5QI7 setup
    ...      c.gNB-CU-CP sends UE CONTEXT MODIFICATION REQUEST message to remove 5QI7 and modify GFBR of 5QI2 gNB-DU.
    ...      d.CPRT send PsUser_BearerDeleteReq to gNB-DU-L2PS to delete 5QI7.
    ...      e.CPRT configures cellConfigurationForModification->pdschConfig & puschConfig->mcsTable as "qam64" via PsUser_UserModifyReq.
    ...      f.CPRT checks cell GBR capacity for the new increased GFBR of 5QI2. The Cell GBR capacity is not enough,
    ...        GFBR modification for 5QI2 should be rejected.
    ...      g.CPRT configures cellConfigurationForModification->pdschConfig & puschConfig->mcsTable as
    ...        "cancelMcsTableReconfiguration" via PsUser_UserModifyReq.
    [Tags]    QC_321805    owner-chunlan.yang
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA_DL_UL}
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA_DL_UL}
    Qosflow Modify    gfbr_dl=15000
    UE Attach To Target Cell via ICS    ue_id=1    cell_id=2
    PDU Session Modify 15a    ue_id=1
    Send And Verify Throuput 15    ue_id=1    qfi=2    send_dl=10    sleep_time=10    pdu=1
    Send And Verify Throuput 15    ue_id=1    qfi=3    send_dl=10    sleep_time=10    pdu=1
    Qosflow Modify    gfbr_dl=1000
    UE Attach To Target Cell via ICS    ue_id=2    cell_id=2
    PDU Session Modify 15a     ue_id=2
    Send And Verify Throuput 15    ue_id=2    qfi=2    send_dl=10    sleep_time=5    pdu=1
    Send And Verify Throuput 15    ue_id=2    qfi=3    send_dl=10    sleep_time=5    pdu=1
    PDU Session Modify 15b      ue_id=2
    sleep    15
    Smf Param Reset After case finished
    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_M_15${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

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
    Update Cfg    set_qosflow id=6 5qi=6 default=on
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8

UE Attach To Target Cell via ICS
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Smf Param Reset After case finished
    Execute Egate Command    smf_param id=1 reset

PDU Session Modify 15a
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2,7 by=amf    Added QosFlow

PDU Session Modify 15b
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=2 gfbr_dl=15000
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=7 qosflows_to_modify=2 by=amf    Deleted QoSFlow

Send And Verify Throuput 15
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Verify Throuput 15    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${sleep_time}    ${pdu}

Qosflow Modify
    [Arguments]    ${gfbr_dl}
    Execute Egate Command    qosflow_modify qos_flow=2 gfbr_dl=${gfbr_dl}

Verify Throuput 15
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
