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
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
...    NRBTS/NRDRB-12:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS-1/NRPDSCHHRLA-1:dllaBlerTargetHR=10
...    NRBTS-1/NRPDSCHHRLA-2:dllaBlerTargetHR=10

@{8246_G_related_modification}
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=110
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=3
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=130
...    NRBTS/NRPMRNL-1:miNrUlHarqOne=5min
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20

@{8246_G_5qi3_modification}
...    NRCELL-2:actNonVoNRGbrService=true
...    NRCELL-2:actGBRAdmissionControl=GBRService
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

*** Test Cases ***
CB008246_H_007_FR1_SA_TDD_Scheduling_5G_UE_with_multiple_DRBs_via_PDU_Non_LowSE_MCS_Table_UE
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the gNB behaviour for PDCCH switch between high reliability and basic
    ...    reliability while dynamic AL selection is enabled.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI6 & 5QI7 are associated with NRPDSCHHRLA profile.
    ...      d.UE not support Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE attach to target cell via PDU,5QI6&7 are setup via PDU.
    ...      b.UE detach.
    ...    4.Check Points
    ...      a.two non-GBR QoS Flow (e.g.5QI6, 5QI7) with one PDU session
    ...      b.gNB-DU-CPRT configures puschHrConfig and pdcchHrConfig for 5QI6 and 5QI7 via PsUser_BearerSetupReq.
    ...      c.qam64LowSE should not present in mcs-Table parameter of PDSCH-Config IE and PUSCH-Config IE
    [Tags]    QC_304434    owner-chunlan.yang
    UE Attach To Target Cell via PDU    ue_id=1    cell_id=2
    Send And Verify Throuput    ue_id=1    qfi=1    send_dl=10    send_ul=2    sleep_time=5s    pdu=1
    Send And Verify Throuput    ue_id=1    qfi=2    send_dl=10    send_ul=2    sleep_time=5s    pdu=1
    Smf Param Reset After case finished
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_H_07${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_H_008_FR1_SA_TDD_Scheduling_5G_UE_with_multiple_DRBs_via_PDU_Modify_Non_LowSE_MCS_Table_UE
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the gNB behaviour for PDCCH switch between high reliability and basic
    ...    reliability while dynamic AL selection is enabled.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI6,5QI7 & 5QI3 are associated with NRPDSCHHRLA profile.
    ...      d.UE not support Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.ICS complete with 5qi6
    ...      b.non-GBR QoS Flow 5QI7 and GBR QoS Flow 5QI3 are setup via PDU Modify.
    ...      c.UE detach.
    ...    4.Check Points
    ...      a.two non-GBR QoS Flow (e.g.5QI3, 5QI7) with one PDU session
    ...      b.gNB-DU-CPRT configures puschHrConfig and pdcchHrConfig for 5QI3 and 5QI7 via PsUser_BearerSetupReq.
    ...      c.qam64LowSE should not present in mcs-Table parameter of PDSCH-Config IE and PUSCH-Config IE
    [Tags]    QC_304435    owner-chunlan.yang
    UE Attach To Target Cell via PDU Modify    ue_id=1    cell_id=2
    Send And Verify Throuput    ue_id=1    qfi=1    send_dl=10    send_ul=2    sleep_time=5s    pdu=1
    Send And Verify Throuput    ue_id=1    qfi=2    send_dl=10    send_ul=2    sleep_time=5s    pdu=1
    Smf Param Reset After case finished
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_H_08${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

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

UE Attach To Target Cell via PDU Modify
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=7,3 by=amf    Added QosFlow

UE Attach To Target Cell via PDU
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    QoS Routing Table
    Execute Egate Command    amf_param id=1 send_ics_registration=off

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${send_ul}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}    ${pdu}

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Smf Param Reset After case finished
    Execute Egate Command    smf_param id=1 reset
