*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CIT    CLOUD_5G_I_BOO_AP_LOO    CB009855
...    owner-cathy.mao    team-SG2    release-5G22R2    CB007877    CB008015    CB006138    CDRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SA_UE1_ID}    81
${SA_UE2_ID}    82


@{PARAMS_IN_SCF}    @{5GC000706}    @{5GC001765_CB007877}    @{CB008015}    @{5GC001390}
...    @{CB009855}    @{other_param}    @{long_pucch_parameter}    @{8246_related_modification_HRDRB}


@{PARAMS_IN_SWCONFIG}
...    0x340002=1
...    0x340006=55139

${NRCELL-1_Freq}    632736
${NRCELL-2_Freq}    648096
${NRCELL-3_Freq}    508110
${NRCELL-4_Freq}    526590
${NRCELL-11_Freq}    424090
${NRCELL-12_Freq}    126750

@{8246_related_modification_HRDRB}
...    NRCELL:cellDepType=SA
...    delete:NRCELL:configuredEpsTac
...    NRCELL:actLAForHiReliab=true
...    NRCELL:actDl256Qam=true
...    NRCELL:actUl256Qam=true
...    NRCELL:dlMcsDowngradeForHr=enabled
...    NRCELL:ulMcsDowngradeForHr=enabled
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
...    NRBTS-1/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS-1/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS-1/NRPDSCHHRLA-1:dllaBlerTargetHR=10
...    NRBTS-1/NRPDSCHHRLA-2:dllaBlerTargetHR=10
...    NRBTS-1/NRPUSCHHRLA-1:ullaBlerTargetHR=10
...    NRBTS-1/NRPUSCHHRLA-2:ullaBlerTargetHR=10
...    NRBTS-1/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-2/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-10/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-11/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-33/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-34/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRCELL:actCceSplit=false

@{Pcell-11_4Scells_expect}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:61, scellIdx:4
...    pcid:60, scellIdx:0
...    SCellIndex 4 activated successfully at airphone

@{PcellChangeTo_Cell-12_expect}
...    Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.12 performed
...    pcid:52, scellIdx:3
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:4
...    SCellIndex 4 activated successfully at airphone

@{PcellChange_From_Cell-1_To_Cell-12_expect}
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.12 performed
...    pcid:52, scellIdx:3
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:4
...    SCellIndex 4 activated successfully at airphone

@{ScellChangeTo_T2T1T3_expect}
...    pcid:52, scellIdx:2
...    pcid:51, scellIdx:0
...    pcid:50, scellIdx:1
...    SCellIndex 2 activated successfully at airphone

@{ScellChangeTo_TDD_expect}
...    pcid:52, scellIdx:3
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    SCellIndex 3 activated successfully at airphone



@{PcellChangeTo_Cell-1_expect}
...    pcid:52, scellIdx:2
...    pcid:61, scellIdx:4
...    pcid:60, scellIdx:3
...    pcid:51, scellIdx:1
...    SCellIndex 4 activated successfully at airphone

@{InterFreq_HO_From_Cell-12_To_Cell-2_expect}
...    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.2 performed
...    pcid:52, scellIdx:2
...    pcid:61, scellIdx:4
...    pcid:60, scellIdx:3
...    pcid:50, scellIdx:1
...    SCellIndex 4 activated successfully at airphone

@{InterFreq_HO_From_Cell-2_To_Cell-11_expect}
...    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.11 performed
...    pcid:52, scellIdx:3
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:61, scellIdx:4
...    SCellIndex 4 activated successfully at airphone


@{5GC000706}
...    NRBTS:actInterFreqHoSA=true
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=58
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=38
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0


@{5GC001765_CB007877}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actHoOptimizationCa=true
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=65
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35

@{CB008015}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellMeasCycle=sf320
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:ssbFrequency=632736
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly

#HO from CELL-2 to CELL-11
...    NRCELL-11/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-2:cellDepType=SA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-2:ssbFrequency=648096
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL-11/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-3:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-3:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-3:cellDepType=SA
...    NRCELL-11/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-3:ssbFrequency=508110
...    NRCELL-11/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-3:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-4:lcrId=12
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly

...    NRCELL-11/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-4:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-4:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-4:cellDepType=SA
...    NRCELL-11/NRHOIF-4:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-4:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-4:ssbFrequency=126750
...    NRCELL-11/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-4:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly

...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-4:lcrId=11
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlOnly

...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:ssbFrequency=632736
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-12/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-12/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30

#HO from CELL-12 to CELL-2
...    NRCELL-12/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-2:cellDepType=SA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-2:ssbFrequency=648096
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-12/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-3:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-3:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-3:cellDepType=SA
...    NRCELL-12/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-3:ssbFrequency=508110
...    NRCELL-12/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-12/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-12/NRHOIF-3:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-12/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-4:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-4:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-4:cellDepType=SA
...    NRCELL-12/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-4:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-4:ssbFrequency=424090
...    NRCELL-12/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-12/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-12/NRHOIF-4:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly

...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:lcrId=11
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL-2/NRREL-4:gNbId=1
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-4:lcrId=12
...    NRCELL-2/NRREL-4:removeNotAllowed=false
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-4:sCellOperationalMode=dlOnly

...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:ssbFrequency=632736
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-2/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-2:a3MeasEnabled=none
...    NRCELL-2/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-2/NRHOIF-2:cellDepType=SA
...    NRCELL-2/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-2:ssbFrequency=508110
...    NRCELL-2/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-2:thresholdPCellSwitchTargetRsrq=30

#HO from CELL-2 to CELL-11
...    NRCELL-2/NRHOIF-3:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-3:a2BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-3:a5MeasEnabled=none
...    NRCELL-2/NRHOIF-3:cellDepType=SA
...    NRCELL-2/NRHOIF-3:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-3:ssbFrequency=424090
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=7

...    NRCELL-2/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-4:a3MeasEnabled=none
...    NRCELL-2/NRHOIF-4:a5MeasEnabled=none
...    NRCELL-2/NRHOIF-4:cellDepType=SA
...    NRCELL-2/NRHOIF-4:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-4:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-4:ssbFrequency=126750
...    NRCELL-2/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-4:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ssbFrequency=648096
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly

...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-2:cellDepType=SA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:ssbFrequency=508110
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=11
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL-1/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-3:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-3:cellDepType=SA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:ssbFrequency=424090
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrq=30

...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=12
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly

...    NRCELL-1/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-4:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-4:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-4:cellDepType=SA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-4:ssbFrequency=126750
...    NRCELL-1/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-4:thresholdPCellSwitchTargetRsrq=30

@{5GC001390}    NRBTS/NRDU-1:actInterNumerologyCa=true


@{CB009855}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS:actCarrierAggregation=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:ifhoSsbSmtcOffset=8
...    NRCELL:gapOffset=8
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRCELL:measGapSelection=favourUeThroughput
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-2:maxNumScellsDlFr1=4
...    NRCELL-3:maxNumScellsDlFr1=4
...    NRCELL-4:maxNumScellsDlFr1=4
...    NRCELL-11:maxNumScellsDlFr1=4
...    NRCELL-12:maxNumScellsDlFr1=4
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=120


@{long_pucch_parameter}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:pucchModeSelect=longPucch

@{other_param}
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:actCDrx=true


${CA_support_list}    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa

#5CC CA_n41A-n66(2A)-n71A-n78(2A) support HRDRB
${CB009855_A_Capa_5CC_n78_n78_n41_n66_n71}    SEPARATOR=
...    EDA09000575F5A13160003C5A0000B0498B800CE1E86801364D873E618F28581C130180623807DC6C28C0D608C21A081074844
...    006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000E80000381506C41D608C21A081
...    07884400656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000001D00000702A8D89BAC1184341
...    020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001D00000702B8F88DAC1184341
...    020F9422002AB64C55850E7C471E300000000000000000010387809FFF000007FFC000007400001C01078789A001C410000021
...    6020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E23000710
...    40038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C28000
...    E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0
...    AC5C4D000E2300070A000002058158788C001C46000006160565E140007104003882001C46000E268007134000038585C01C04
...    68051013602091A00019A10851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F
...    022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF
...    812A0408102040D96BC303220318C6318C6318C6318C603D08C000F000A070500703009401C0018090010180A0000000000D00
...    080183E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001
...    C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D
...    64CD602D606D6025604560ED0341000009652504000065949410000296524040000E5949010000496524040001659490100006
...    96524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2
...    E95455058AA0B1541A2A94C55268AA031540A2A93555078A22002F012A05028140A05028140A05028140A05028140A05028003
...    84040300601002004202004010080600C20100200404030060100C018202018030080600C20100200404030060100200440201
...    8030080600C020180304040080201002008A02004008080600C02018030080600C0200400808010023543E00020406080C0E14
...    16181A2022242628303236383A3E424A4C4E5052545A5E828305A0

# RAC for scell
${GNB_SCELL_4_ADMI_REQ_SA}    M55138C00048
${GNB_SCELL_4_ADMI_SUCC_SA}    M55138C00049
${GNB_DU_SCELL_4_ADMI_REQ_SA}    M55139C00023
${GNB_DU_SCELL_4_ADMI_SUCC_SA}    M55139C00024

# scell release
${A2MEAS_REL1DLSCELL_ATT_SA}    M55118C06501
${A2MEAS_REL1DLSCELL_SUCC_SA}    M55118C06502
${A2MEAS_IMMEDIATE_REL_SCELL}    M55118C06505

# scell change
${SCELL_CHANGE_ATT_SA}    M55118C06506
${SCELL_CHANGE_SUCC_SA}    M55118C06507

# pcell change
${ATT_A1_IF_INTRA_DU_HO_SA_PLMN}    M55145C02001
${SUCC_A1_IF_INTRA_DU_HO_SA_PLMN}    M55145C02002
${ATT_A2_IF_INTRA_DU_HO_SA_PLMN}    M55145C03001
${SUCC_A2_IF_INTRA_DU_HO_SA_PLMN}    M55145C03002
${ATT_A1_IF_INTRA_DU_HO_SLICE}    M55149C01501
${SUCC_A1_IF_INTRA_DU_HO_SLICE}    M55149C01502
${ATT_A2_IF_INTRA_DU_HO_SLICE}    M55149C02501
${SUCC_A2_IF_INTRA_DU_HO_SLICE}    M55149C02502

#HO
${TOT_INTER_FREQ_HO_DECISION_A3}    M55147C00024

#A2HO should not incerase for pcell change
${ATT_IF_INTRA_DU_HO_SA_PLM}    M55145C00321
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551



@{PM_Counters_Check_CIT032}
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=${Loop_id}
...    NRCELL-2:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=${Loop_id}
...    NRCELL-11:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=${1+${Loop_id}}
...    NRCELL-12:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=${2*${Loop_id}}
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=${Loop_id}
...    NRCELL-2:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=${Loop_id}
...    NRCELL-11:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=${1+${Loop_id}}
...    NRCELL-12:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=${2*${Loop_id}}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=${Loop_id}
...    NRCELL-2:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=${Loop_id}
...    NRCELL-11:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=${1+${Loop_id}}
...    NRCELL-12:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=${2*${Loop_id}}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=${Loop_id}
...    NRCELL-2:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=${Loop_id}
...    NRCELL-11:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=${1+${Loop_id}}
...    NRCELL-12:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=${2*${Loop_id}}
...    NRCELL-12:NCAC:${A2MEAS_REL1DLSCELL_ATT_SA}=${3*${Loop_id}}
...    NRCELL-12:NCAC:${A2MEAS_REL1DLSCELL_SUCC_SA}=${3*${Loop_id}}
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_SA}=${3*${Loop_id}}
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_SA}=${3*${Loop_id}}
...    NRCELL-12:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=0
...    NRCELL-1:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=0
...    NRCELL-12:NCAC:${SCELL_CHANGE_ATT_SA}=${Loop_id}
...    NRCELL-12:NCAC:${SCELL_CHANGE_SUCC_SA}=${Loop_id}
...    NRCELL-2:NCAC:${SCELL_CHANGE_ATT_SA}=${Loop_id}
...    NRCELL-2:NCAC:${SCELL_CHANGE_SUCC_SA}=${Loop_id}
...    NRCELL-11:NRANS:${ATT_A1_IF_INTRA_DU_HO_SA_PLMN}=${Loop_id}
...    NRCELL-11:NRANS:${SUCC_A1_IF_INTRA_DU_HO_SA_PLMN}=${Loop_id}
...    NRCELL-12:NRANS:${ATT_A1_IF_INTRA_DU_HO_SA_PLMN}=${Loop_id}
...    NRCELL-12:NRANS:${SUCC_A1_IF_INTRA_DU_HO_SA_PLMN}=${Loop_id}
...    NRCELL-1:NRANS:${ATT_A2_IF_INTRA_DU_HO_SA_PLMN}=${Loop_id}
...    NRCELL-1:NRANS:${SUCC_A2_IF_INTRA_DU_HO_SA_PLMN}=${Loop_id}
...    NRBTS-1:NSL:${ATT_A1_IF_INTRA_DU_HO_SLICE}=${2*${Loop_id}}
...    NRBTS-1:NSL:${SUCC_A1_IF_INTRA_DU_HO_SLICE}=${2*${Loop_id}}
...    NRBTS-1:NSL:${ATT_A2_IF_INTRA_DU_HO_SLICE}=${Loop_id}
...    NRBTS-1:NSL:${SUCC_A2_IF_INTRA_DU_HO_SLICE}=${Loop_id}
...    NRCELL-12:NMOCU:${TOT_INTER_FREQ_HO_DECISION_A3}=${Loop_id}
...    NRCELL-2:NMOCU:${TOT_INTER_FREQ_HO_DECISION_A3}=${Loop_id}
...    NRCELL-12:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLM}=${Loop_id}
...    NRCELL-12:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=${Loop_id}
...    NRCELL-2:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLM}=${Loop_id}
...    NRCELL-2:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=${Loop_id}
...    NRCELL-11:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLM}=0
...    NRCELL-11:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=0
...    NRCELL-1:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLM}=0
...    NRCELL-1:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=0
...    NRBTS-1:NSL:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=${2*${Loop_id}}
...    NRBTS-1:NSL:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=${2*${Loop_id}}


${DEBUG_LOG_LEVEL}    4
${AP_UDPLOG_LEVEL}    4
${BTS_STARTUP_RETRY}    4
${UTE_WIRESHARK_FLAG}    ${False}
${Loop_id}    5

*** Test Cases ***
5GSW_CP_CIT032_covBasedA1_CA_of_pcell_scell_addition_release_and_loopback_sucessful
    [Documentation]
    ...    1. The purpose of this test case is to check 5CC CA with follow operation:
    ...    HO,scell's addtion and stepwise release,A1/A2 pcell change, A1 scell change.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                   gNB
    ...                   Cell1    Cell2    Cell3    Cell4    Cell11    Cell12
    ...    Technology        TDD      TDD    TDD      TDD      FDD       FDD
    ...          Band        n78      n78    n41      n41      n66       n71
    ...     Bandwidth       100M     100M    80M      80M      20M       20M
    ...    3.Expect result for each step:
    ...      a.UE register to F11 and A1 scellAddition successfully with CA_F11_F12T1T2T3
    ...      b.A1 Pcell Change To F12, CA_F12_F11T1T2T3
    ...      c.Scell Stepwise Release All TDD SCell, left CA_F12_F11
    ...      d.A1 Scell Change From F11 To TDD Cell,CA_F12_T1T2T3
    ...      e.A1 Pcell Change From FDD Cell-12 To TDD Cell-1,CA_T1_T2T3F11F12
    ...      f.Scell Stepwise Release And Left SCell-12, CA_T1_F12
    ...      g.A2 Pcell Change From TDD Cell-1 To FDD Cell-12,CA_F12_T1T2T3F11
    ...      h.Trigger InterFreq IntraGNB HO From FDD Cell-12 To TDD Cell-2, CA_T2_T1T3F11F12
    ...      i.Scell Stepwise Release 2 TDD SCell,CA_T2_F11F12
    ...      j.Scell Change From FDD Cell To TDD Cell-1,CA_T2_T1
    ...      k.InterFreq IntraGNB HO From TDD Cell-2 To FDD Cell-11,CA_F11_T1T2T3F12
    ...      m.check counter
    ...      n.stop traffic and ue derigester sucessful
    [Tags]    QC_47238
    Clear Counter files
    Ue Register And Pdu Session Setup At FDD Cell-11
    Send And Verify Throughput
    UE Send A1 Trigger Scell Addition    cellfreq=${NRCELL-11_Freq}    pass_regexp=${Pcell-11_4Scells_expect}    ue_id=${SA_UE1_ID}
    Trigger Pcell Change To FDD Cell-12    cellfreq=${NRCELL-12_Freq}    pass_regexp=${PcellChangeTo_Cell-12_expect}
    Trigger Scell Stepwise Release All TDD SCell
    Trigger Scell Change From FDD Cell-11 To TDD Cell    scell_index=4    cellfreq=${NRCELL-12_Freq}
    ...    pass_regexp=${ScellChangeTo_TDD_expect}
    Trigger Pcell Change From FDD Cell-12 To TDD Cell-1    scell_index=1    cellfreq=${NRCELL-1_Freq}
    ...    pass_regexp=${PcellChangeTo_Cell-1_expect}
    Trigger Scell Stepwise Release And Left SCell-12
    Trigger Pcell Change From TDD Cell-1 To FDD Cell-12    scell_index=4    cellfreq=${NRCELL-1_Freq}
    ...    pass_regexp=${PcellChange_From_Cell-1_To_Cell-12_expect}
    Trigger InterFreq IntraGNB HO    src_cellfreq=${NRCELL-12_Freq}    tgt_phycell_id=51    tgt_cellfreq=${NRCELL-2_Freq}     threshold=38
    ...    pass_regexp=${InterFreq_HO_From_Cell-12_To_Cell-2_expect}
    Trigger Scell Stepwise Release 2 TDD SCell
    Trigger Scell Change From FDD Cell To TDD Cell-1    scell_index=1    cellfreq=${NRCELL-2_Freq}
    ...    pass_regexp=${ScellChangeTo_T2T1T3_expect}
    Trigger InterFreq IntraGNB HO    src_cellfreq=${NRCELL-2_Freq}    tgt_phycell_id=60    tgt_cellfreq=${NRCELL-11_Freq}     threshold=38
    ...    pass_regexp=${InterFreq_HO_From_Cell-2_To_Cell-11_expect}
    Execute Case Step For Loop
    Check Counters    ${PM_Counters_Check_CIT032}
    [Teardown]    Teardown Of Ue Deregister


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71

Modify Cfg
    Update Cfg    ue_param id=${SA_UE1_ID} ue_nr_capabilities=${CB009855_A_Capa_5CC_n78_n78_n41_n66_n71}
    Update Cfg    ue_param id=${SA_UE2_ID} ue_nr_capabilities=${CB009855_A_Capa_5CC_n78_n78_n41_n66_n71}

Ue Register And Pdu Session Setup At FDD Cell-11
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    ue_location_change id=${SA_UE1_ID} enb=2 cell=11
    Execute Egate Command    ue_register id=${SA_UE1_ID}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${SA_UE1_ID} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${SA_UE1_ID} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table

UE Send A1 Trigger Scell Addition
    [Arguments]    ${cellfreq}    ${pass_regexp}    ${ue_id}=${SA_UE1_ID}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120 srsrq_nr=52
    ...    pass_regexp=${pass_regexp}
    Verify Throughput When 4 Scells    ue_id=${SA_UE1_ID}    Tput_dl=5

Send And Verify Throughput
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=15    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=15    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=15    UE ${ue_id}: UDP DL
    #Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=6 mbps=10    UE ${ue_id}: UDP UL
    Verify Throughput

Verify Throughput
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${Tput_dl}=40    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    #Should Be True    ${scell_tput}/1000 > 0

Throughput Check
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=1    ${sleep_time}=15s    ${CC_num}=5
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${alldl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
    END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Verify Throughput When 4 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=5
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex-4

Verify Throughput When 3 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=4
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    fail_regexp=CellIndex-4

Verify Throughput When 2 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=3
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    fail_regexp=CellIndex-4


Trigger Pcell Change To FDD Cell-12
    [Arguments]    ${cellfreq}    ${pass_regexp}    ${ue_id}=${SA_UE1_ID}
    Start RRC Log     pcell_change_F11_to_F12
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${A1_Pcell_change_F_To_F}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=11 srsrq_nr=11 scell=4
    ...    scell_rsrp=121 scell_rsrq=121
    ${ret}=    Execute Egate Command    ${A1_Pcell_change_F_To_F}    pass_regexp=${pass_regexp}
    Verify Throughput When 4 Scells    ue_id=${SA_UE1_ID}    Tput_dl=5

Trigger Scell Stepwise Release All TDD SCell
    Trigger Scell Stepwise Release    scell_index=1    cellfreq=${NRCELL-1_Freq}
    Trigger Scell Stepwise Release    scell_index=2    cellfreq=${NRCELL-2_Freq}
    Trigger Scell Stepwise Release    scell_index=3    cellfreq=${NRCELL-3_Freq}

Trigger Scell Stepwise Release 2 TDD SCell
    Trigger Scell Stepwise Release    scell_index=1    cellfreq=${NRCELL-1_Freq}
    Trigger Scell Stepwise Release    scell_index=2    cellfreq=${NRCELL-3_Freq}


Trigger Scell Stepwise Release And Left SCell-12
    Trigger Scell Stepwise Release    scell_index=1    cellfreq=${NRCELL-2_Freq}
    Trigger Scell Stepwise Release    scell_index=2    cellfreq=${NRCELL-3_Freq}
    Trigger Scell Stepwise Release    scell_index=3    cellfreq=${NRCELL-11_Freq}



Trigger Scell Stepwise Release
    [Arguments]    ${scell_index}    ${cellfreq}    ${ue_id}=${SA_UE1_ID}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ${ret3}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 scell=${scell_index} scell_rsrp=34
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret3}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToReleaseList{${scell_index}}


Trigger Scell Change From FDD Cell-11 To TDD Cell
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}    ${ue_id}=${SA_UE1_ID}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 scell=${scell_index} srsrp_nr=120 srsrq_nr=120
    ...    pass_regexp=${pass_regexp}
    Verify Throughput When 3 Scells    ue_id=${SA_UE1_ID}    Tput_dl=5


Trigger Scell Change From FDD Cell To TDD Cell-1
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}    ${ue_id}=${SA_UE1_ID}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${SA_UE1_ID}    carrierfreq=${cellfreq}    event_type=A1
    ${ret9}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${SA_UE1_ID} meas_id=${measid} event=A1 scell=${scell_index} srsrp_nr=120 srsrq_nr=120
    ...    pass_regexp=${pass_regexp}
    Verify Throughput When 2 Scells    ue_id=${SA_UE1_ID}    Tput_dl=5

Trigger Pcell Change From FDD Cell-12 To TDD Cell-1
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}    ${ue_id}=${SA_UE1_ID}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A1 meas_id=${measid} srsrp_nr=11 srsrq_nr=11 scell=${scell_index}
    ...    scell_rsrp=127 scell_rsrq=127
    ${ret5}=    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Verify Throughput When 4 Scells    ue_id=${SA_UE1_ID}    Tput_dl=5


Trigger Pcell Change From TDD Cell-1 To FDD Cell-12
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}    ${ue_id}=${SA_UE1_ID}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ${A2_Pcell_change_T_To_F}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${measid} srsrp_nr=11 srsrq_nr=11 scell=${scell_index}
    ...    scell_rsrp=127 scell_rsrq=127
    ${ret}=    Execute Egate Command    ${A2_Pcell_change_T_To_F}    pass_regexp=${pass_regexp}
    Verify Throughput When 4 Scells    ue_id=${SA_UE1_ID}    Tput_dl=5

Trigger InterFreq IntraGNB HO
    [Arguments]    ${src_cellfreq}    ${tgt_phycell_id}    ${tgt_cellfreq}    ${pass_regexp}    ${ue_id}=${SA_UE1_ID}    ${threshold}=38
    ${a2_measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${src_cellfreq}    event_type=A2
    ...    threshold=${threshold}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${a2_measid} srsrp_nr=21 srsrq_nr=20
    ...    pass_regexp=rrcReconfigurationComplete
    ${a3_measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${tgt_cellfreq}    event_type=A3
    ${InterF_A3_HO_To_TDD}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A3 meas_id=${a3_measid} srsrp_nr=21 srsrq_nr=20
    ...    phycell_id=${tgt_phycell_id} nrsrp_nr=121 nrsrq_nr=121
    ${ret}=    Execute Egate Command    ${InterF_A3_HO_To_TDD}    pass_regexp=${pass_regexp}
    Verify Throughput When 4 Scells    ue_id=${SA_UE1_ID}    Tput_dl=5

Execute Case Step For Loop
    FOR    ${id}    IN RANGE    1    ${Loop_id}
        Trigger Pcell Change To FDD Cell-12    cellfreq=${NRCELL-12_Freq}    pass_regexp=${PcellChangeTo_Cell-12_expect}
        Trigger Scell Stepwise Release All TDD SCell
        Trigger Scell Change From FDD Cell-11 To TDD Cell    scell_index=4    cellfreq=${NRCELL-12_Freq}
        ...    pass_regexp=${ScellChangeTo_TDD_expect}
        Trigger Pcell Change From FDD Cell-12 To TDD Cell-1    scell_index=1    cellfreq=${NRCELL-1_Freq}
        ...    pass_regexp=${PcellChangeTo_Cell-1_expect}
        Trigger Scell Stepwise Release And Left SCell-12
        Trigger Pcell Change From TDD Cell-1 To FDD Cell-12    scell_index=4    cellfreq=${NRCELL-1_Freq}
        ...    pass_regexp=${PcellChange_From_Cell-1_To_Cell-12_expect}
        Trigger InterFreq IntraGNB HO    src_cellfreq=${NRCELL-12_Freq}    tgt_phycell_id=51    tgt_cellfreq=${NRCELL-2_Freq}     threshold=38
        ...    pass_regexp=${InterFreq_HO_From_Cell-12_To_Cell-2_expect}
        Trigger Scell Stepwise Release 2 TDD SCell
        Trigger Scell Change From FDD Cell To TDD Cell-1    scell_index=1    cellfreq=${NRCELL-2_Freq}
        ...    pass_regexp=${ScellChangeTo_T2T1T3_expect}
        Trigger InterFreq IntraGNB HO    src_cellfreq=${NRCELL-2_Freq}    tgt_phycell_id=60    tgt_cellfreq=${NRCELL-11_Freq}     threshold=38
        ...    pass_regexp=${InterFreq_HO_From_Cell-2_To_Cell-11_expect}
    END

Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1
    ...    Stopped Downlink Internal traffic on Ue:${ue_id} UpfId:1 Pdu:1 Qfi:1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Teardown Of Ue Deregister
    Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    Common Test Teardown And Stop Capture Logs
