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
...    @{545_config}

@{545_config}
...    NRCELL:actUlDftSOfdm=true
...    NRCELL:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=150
...    NRCELL:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=100
...    NRCELL:ulTransPrecodeCtl:ulTransPrePi2BpskPwrBoost=true
...    NRCELL:actUl256Qam=true
...    NRCELL:actDl256Qam=true
...    NRBTS:actMultiDrbNSA=true

@{8246_related_modification}
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
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-12:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS/NRDRB-3:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-3:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-3:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-4:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-4:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-4:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1

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
...    NRBTS:rrcReestabTypeSA=sameGNB

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

${UE_Capa_Support_HRLA_DL_UL}    SEPARATOR=
...    EDA09000575F5A13160003C320016093170019C3D09009B26C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C6247
...    1E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C639F30C7942C0E
...    070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF0
...    0000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00038820000042C0AC3C4D000E23000001
...    0B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B1713400388C001C46000004160562E14000710
...    400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C46000004160562E26800711800385000
...    00102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8
...    E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005
...    C3C6318C6318C6318C63187A09801E00140E0A00E060128038003012002030140000000001200400C1F0480100000000800001004000000020000040
...    1000004008000030040000200200001401000802008020000180100000E0080040000001000010008000090040000180200002801000016008004090
...    24010000180662A5152814406206502A8A544CA01501A80440420740D04000025949410000196525040000A594901000039652404000125949010000
...    596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240330AAB0AA90AA30AA1016
...    1016101A10A6109A1006100A109A901E02405E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C0184
...    02004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030
...    385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${UE_Eutra_NR_Capabilities}     SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000
...    002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C0
...    41809A1E80B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E01A0718C63
...    18C60C02080002010100200804030061000040202004008080600C3000080404030060100C018040300610000402020040100801004000000
...    00

*** Test Cases ***
CB008246_05_SA_ICS_256QAM_BR_HR_DRBs_setup_CP_swich_DFT_swich_CP
    [Documentation]
    ...    1. This user scenario validates interworking of Link adaptation for high reliability DRB with DFT-s-OFDM for PUSCH
    ...    2. Configuration
    ...    a.SA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.HR is setup.
    ...    b.Decrease SINR to trigger TP enabled
    ...    c.Increase SINR to trigger TP disabled
    ...    d.UE detach.
    [Tags]    QC_324704
    PREPARE FOR TESTJ5
    ICS With PDU    ue_id=1    cell_id=2
    Verify Throuput    ue_id=1
    DECREASE SINR TO TRIGGER TP ENABLED
    Verify Throuput    ue_id=1
    DRB ADD and release
    INCREASE SINR TO TRIGGER TP DISABLED
    Verify Throuput    ue_id=1
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_J5${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_09_NSA_ICS_256QAM_BR_HR_DRBs_setup_CP_swich_DFT_swich_CP
    [Documentation]
    ...    1. This user scenario validates interworking of Link adaptation for high reliability DRB with DFT-s-OFDM for PUSCH
    ...    2. Configuration
    ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to NSA or both
    ...    3. Test Case Steps:
    ...    a.UE attach and sgNB addition is successful.HR is setup.
    ...    b.Decrease SINR to trigger TP enabled
    ...    c.Increase SINR to trigger TP disabled
    ...    d.UE detach.
    [Tags]    QC_324701
    PREPARE FOR TESTJ9
    UE Attach To Target Cell via NSA    ue_id=31    cell_id=2    bearer_id=2
    DECREASE SINR TO TRIGGER TP ENABLED FOR NSA
    INCREASE SINR TO TRIGGER TP DISABLED FOR NSA
    Verify All Nsa Throuput
    UE Detach    ue_id=31
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_J9${/}a2a.ini    wait_string=UEContextReleaseComplete::2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Send All Nsa Throuput
    [Arguments]    ${ue_id}=31
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=1    UDP DL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=1    UDP UL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} id=4 dir=dl mbps=1    UDP DL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} id=4 dir=ul mbps=1    UDP UL TRF

Verify All Nsa Throuput
    [Arguments]    ${ue_id}=31    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${dl_throughput2}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=4    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput2}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=4    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput1}/100>9
    Should Be True    ${ul_throughput1}/100>9
    Should Be True    ${dl_throughput2}/100>9
    Should Be True    ${ul_throughput2}/100>9

PREPARE FOR TESTJ5
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA_DL_UL}
    Execute Egate Command    ul_sinr_testmode_nr profile_id=2 pathloss=40
    Execute Egate Command    ul_sinr_testmode_nr profile_id=2
    Execute Egate Command    ue_testmode_set_nr id=1 scell=0 testmode=ul_sinr profile_id=2 action=activate
    Execute Egate Command    ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-1043
    Execute Egate Command    cell_testmode_set_nr gnb=2 cell_id=2 testmode=ul_cell_noise action=activate profile_id=2

PREPARE FOR TESTJ9
    Update NSA UE capa    ue_id=31-33    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA_DL_UL}    ue_eutra_nr_capabilities=${UE_Eutra_NR_Capabilities}
    Execute Egate Command    ul_sinr_testmode_nr profile_id=2 pathloss=40
    Execute Egate Command    ul_sinr_testmode_nr profile_id=2
    Execute Egate Command    ue_testmode_set_nr id=31 scell=0 testmode=ul_sinr profile_id=2 action=activate
    Execute Egate Command    ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-1043
    Execute Egate Command    cell_testmode_set_nr gnb=2 cell_id=2 testmode=ul_cell_noise action=activate profile_id=2

DRB ADD and release
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=7 by=amf    RESOURCE MODIFY RESPONSE
    sleep    5s    wait for DRB delete
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=6,7 by=amf    Added QosFlow
    sleep    5s    wait for DRB addition
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=7 by=amf    RESOURCE MODIFY RESPONSE
    sleep    5s    wait for DRB delete
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=2
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=2 dir=ul mbps=0.2
    sleep    5s    sleep for Tput stable

UE Attach To Target Cell via NSA
    [Arguments]    ${ue_id}    ${cell_id}    ${bearer_id}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=${bearer_id} type=split_scg
    ...     successful RA
    Execute Egate Command    bearer_add ue=${ue_id} id=4 filter=0 precedence=0    PGW-initiated Bearer Creation
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=4 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...     Successfully reconfigured dual connectivity
    Send All Nsa Throuput

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Update NSA UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none    ${ue_eutra_nr_capabilities}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
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
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=31 qci=5 pdn=1
    Update Cfg    set_bearer id=4 ue=31 qci=6 pdn=1
    Update Cfg    set_bearer id=5 ue=31 qci=7 pdn=1
    Update Cfg    set_bearer id=6 ue=31 qci=8 pdn=1
    Update Cfg    set_bearer id=7 ue=31 qci=70 pdn=1
    Update Cfg    set_bearer id=2 ue=32 qci=9 pdn=1 ip=4.7.254.210 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=32 qci=5 pdn=1
    Update Cfg    set_bearer id=4 ue=32 qci=6 pdn=1

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput
    [Arguments]    ${ue_id}
    sleep    10s    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${dl_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=dl    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>1.8
    Should Be True    ${dl_throughput2}/1000>1.8

ICS With PDU
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    Initial Context Setup Successful
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul mbps=1
    sleep    5s    sleep for Tput stable

DECREASE SINR TO TRIGGER TP ENABLED
    FOR    ${i}    IN RANGE    125    128    1
        Execute Egate Command    ul_sinr_testmode_nr profile_id=2 pathloss=${i}    fail_regexp=mcs-Table
        sleep    2    sleep for TP enabled
    END
    Execute Egate Command    ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-770    fail_regexp=mcs-Table

INCREASE SINR TO TRIGGER TP DISABLED
    FOR    ${i}    IN RANGE    85    82    -1
        Execute Egate Command    ul_sinr_testmode_nr profile_id=2 pathloss=${i}
        sleep    2    sleep for TP disabled
    END
    Execute Egate Command    ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-1043

INCREASE SINR TO TRIGGER TP DISABLED FOR NSA
    FOR    ${i}    IN RANGE    55    50    -1
        Execute Egate Command    ul_sinr_testmode_nr profile_id=2 pathloss=${i}
        sleep    2    sleep for TP disabled
    END
    Execute Egate Command    ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-1043

DECREASE SINR TO TRIGGER TP ENABLED FOR NSA
    FOR    ${i}    IN RANGE    110    115    1
        Execute Egate Command    ul_sinr_testmode_nr profile_id=2 pathloss=${i}    fail_regexp=mcs-Table
        sleep    2    sleep for TP enabled
    END
    Execute Egate Command    ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-800    fail_regexp=mcs-Table

UE Detach
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s
