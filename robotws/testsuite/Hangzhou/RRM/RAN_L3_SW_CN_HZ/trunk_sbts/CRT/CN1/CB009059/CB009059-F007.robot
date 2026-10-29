*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-Tingjian.Mao    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=10
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_CB008246}
...    @{PARAMS_FOR_CA}
...    @{VONR}
...    @{AperCsi}
...    @{8290_Enable}
...    @{PCMD_related}
...    @{PARAMS_FOR_8290_SCellSwap_enable}
...    NRCELL-1/NRCELL_FDD-1:nrarfcnDl=125180
...    NRCELL-1/NRCELL_FDD-1:nrarfcnUl=134380
...    NRCELL-1/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-1/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-1:gscnOrSsPbchArfcn=1564
...    NRCELL-1:type0CoresetConfigurationIndex=0
...    NRCELL-3/NRCELL_FDD-1:nrarfcnDl=125180
...    NRCELL-3/NRCELL_FDD-1:nrarfcnUl=134380
...    NRCELL-3/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-3/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-3:gscnOrSsPbchArfcn=1564
...    NRCELL-3:type0CoresetConfigurationIndex=0

@{PARAMS_FOR_9059}
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA
...    NRBTS/NRDRB-10:cellAggrLevel=FR1 CA eligible    #5QI-5
...    NRBTS/NRDRB-11:cellAggrLevel=FR1 CA eligible    #5QI-6
...    NRBTS/NRDRB-12:cellAggrLevel=Not FR1 CA eligible    #5QI-7
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA eligible    #5QI-8
...    NRBTS/NRDRB-14:cellAggrLevel=FR1 CA eligible    #5QI-9
...    NRBTS:sCellActivationMethod=bufferBased

@{PARAMS_FOR_CB008246}
...    NRCELL-1:actLAForHiReliab=false
...    NRCELL-2:actLAForHiReliab=true
...    NRCELL-2:ulMcsDowngradeForHr=disabled
...    NRCELL-2:dlMcsDowngradeForHr=disabled
...    NRCELL-4:actLAForHiReliab=true
...    NRCELL-4:ulMcsDowngradeForHr=disabled
...    NRCELL-4:dlMcsDowngradeForHr=disabled
...    NRCELL-3:actLAForHiReliab=false
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
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-2/NRPDSCHHRLA-1    #5QI-7
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-2/NRPUSCHHRLA-1    #5QI-7
...    NRBTS/NRDRB-14:nrPdschHRLaDN=MRBTS-1/NRBTS-2/NRPDSCHHRLA-1    #5QI-9
...    NRBTS/NRDRB-14:nrPuschHRLaDN=MRBTS-1/NRBTS-2/NRPUSCHHRLA-1    #5QI-9
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

@{PCMD_related}
...    @{TCE}
...    @{NRMTRACECU}
...    @{CellTrace_enable}
...    @{traceAll}
...    @{PCMD_enable}
...    @{PeriodicUeMeas}
...    @{PCMD_DU_enable}
...    @{NRSTRACECU}

@{TCE}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${TCE_IP}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=${TCE_PORT}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false
...    NRBTS/NRCTRLTS-1

@{NRMTRACECU}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1

@{CellTrace_enable}
...    NRBTS:actCellTraceReport=true
...    NRBTS:actSubscriberTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all

@{PCMD_enable}
...    NRBTS:actPCMDReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true

@{traceAll}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all

@{PeriodicUeMeas}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly

@{PCMD_DU_enable}
...    NRBTS/NRDU-1/NRCTRLTSDU-1
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:actPCMDReporting=true
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:jobType=TraceOnly
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrTceIdentifier=1
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:scope=allResources
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:traceId=1

@{NRSTRACECU}
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:nrStraceCuId=1
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:applyDefNrTceForAllSessions=true
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:certTypeForTlsAuth=RSA
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:defaultNrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:nrTcePortNumber=49100
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:tlsEnabled=false

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

@{PARAMS_FOR_8290_SCellSwap_enable}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL:weightForSCellSelection=50
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67

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
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
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
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
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

# HRDRB dl-64QAM-MCS-TableAlt
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

@{PDU_SETUP}
...    reportConfigToAddModList
...    eventA1
...    Setup QosFlow with QFI:1 5QI:6
...    QoS Routing Table

@{NO_A1_Configuration}
...    reportConfigToAddModList
...    eventA1

@{qos7_8_add}
...    Added QosFlow with QFI:3 5QI:8
...    Added QosFlow with QFI:2 5QI:7
...    QoS Routing Table

@{qos9_add}
...    Added QosFlow with QFI:2 5QI:9
...    QoS Routing Table

@{qos9_add_UE1}
...    Added QosFlow with QFI:4 5QI:9
...    QoS Routing Table

@{scell_add}
...    pcid:60, scellIdx:1] configure_1_1
...    pcid:50, scellIdx:0] configure_1_1
...    PhysCellId: 60] SCellIndex 1 activated successfully at airphone
...    rrcReconfigurationComplete

@{scell_swap}
...    pcid:61, scellIdx:2] configure_1_1
...    pcid:50, scellIdx:0] configure_1_1
...    PhysCellId: 61] SCellIndex 2 activated successfully at airphone
...    rrcReconfigurationComplete

@{PM_Counters_F007}
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${DL_RRC_FSCELL_REL_ATT_SA}=1
...    NRCELL-2:${DL_RRC_FSCELL_REL_SUC_SA}=1

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039    #Number of times SCell addition is allowed for a UE due to DRB profile-based CA
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040    #Number of times SCell addition is prevented for a UE due to DRB profile-based CA
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034
# This counter measures the number of SCells to be released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035
#This counter measures the number of SCells released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042
#This counter measures the number of full SCell release attempts in DL in the PCell for SA. It considers only full SCell
#releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
#This counter measures the number of successful full SCell release attempts in DL in the PCell for SA. It considers only full
#SCell releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.

*** Test Cases ***
CB009059-ET-F007_PCMD_Interaction_with_HRDRB_SCell_selection_during_SCell_Swap
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This user scenario validates that for a UE with a CA eligible DRB and CA is activated, if a new DRB is setup
    ...    which is CA incompatible, CA is released.
    ...    The gNB performs a CA release during a DRB reconfiguration for a UE. For each SCell that is released, the appropriate
    ...    fields for each released SCell are included in the PCMD record. CB008208 (Additional PCMD records for SA and NSA - UE
    ...    mobility SA handovers) and (CB008911 (5G PCMD for Carrier Aggregation and Periodical Timing Advance reporting) define
    ...    the appropriate PCMD fields to be recorded for SCell Release.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value HRDRB
    ...          1 non-GBR AM 0:FR1 CA eligible                 NO
    ...          2 non-GBR AM 1:Not FR1 CA eligible             YES
    ...          3 non-GBR AM 0:FR1 CA eligible                 NO
    ...          4 non-GBR AM 0:FR1 CA eligible                 YES
    ...    2. Test Case Steps:
    ...         Step A. UE1 attaches to Cell-2 and DRB-1 during the UE context setup then sent Throughput
    ...         Step B. UE1 ADD NRDRB-2 and NRDRB-3 then sent A1
    ...         Step C. UE1 trigger A6
    ...         Step D. UE1 ADD NRDRB-4
    ...         Step E. UE2 attaches to Cell-2 and DRB-1 during the UE context setup then sent Throughput
    ...         Step F. UE2 ADD NRDRB-4 then sent A1
    ...         Step G. Release UEs and check counters
    ...    3. Expected Results:
    ...         Step A: UE1 Registration successfully The TP only in PCELL A1 measconfig to UE1
    ...         Step B: DRBS ADD successfully,The gNB configures the UE with 2CC(CELL2+CELL1)
    ...         Step C: Scell SWAP successfully cell1 change to cell3 Throughput normal
    ...         Step D: DRB ADD successfully,The gNB releases SCell configured to the UE(release cell1 due to not support HRDRB)
    ...         Step E: UE2 Registration successfully The TP only in PCELL,A1 measconfig to UE2
    ...         Step F: DRB ADD successfully,sent A1 measconfig to UE2 but NO CA
    ...         Step G: Release UEs and check counters successfully
    [Tags]    QC_349233    CA_LABLE-TF(20MHz_TDD_n41+10MHz_FDD_n71)
    Clear Counter Files    wait=${False}
    Start TCE    ${TCE_PORT}
    Verify UE ScellSwap successfully with PCMD
    Verify UE NO CA when ADD eligible HRDRB
    Check Wireshark Log    ${CURDIR}${/}a2a_F007${/}a2a.ini    wait_string=UEContextReleaseComplete::12
    check counters    ${PM_Counters_F007}

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


Verify UE ScellSwap successfully with PCMD
    UE Register and setup PDU with eligible DRB
    Sent Throughput
    ADD DRB
    Sent Throughput    qfi_id=2
    Sent Throughput    qfi_id=3
    A1 2CC in cell2
    Verify Throughput pcell and scells
    Trigger ScellSwap
    Verify Throughput pcell and scells    scell_id=2


Verify UE NO CA when ADD eligible HRDRB
    ADD DRB    addqos_id=4    pass_regexp=${qos9_add_UE1}
    Verify no Scell
    Release UEs    ue_type=all
    UE Register and setup PDU with eligible DRB    ue_id=2
    Sent Throughput    ue_id=2
    ADD DRB    ue_id=2    addqos_id=4    pass_regexp=${qos9_add}    fail_regexp=${NO_A1_Configuration}
    Sent A1 but NO CA    ue_id=2
    Verify Throughput only pcell    ue_id=2
    Release UEs    ue_type=all

ADD DRB
    [Arguments]    ${ue_id}=1    ${addqos_id}=2,3    ${pass_regexp}=${qos7_8_add}    ${fail_regexp}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${addqos_id} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

A1 2CC in cell2
    [Arguments]    ${ue_id}=1    ${cellfreq}=518670    ${pass_regexp}=${scell_add}
    ${A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A1} event=A1 srsrq_nr=70 srsrp_nr=90
    ...    pass_regexp=${pass_regexp}

Sent A1 but NO CA
    [Arguments]    ${ue_id}=2    ${cellfreq}=518670
    ${A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A1} event=A1 srsrq_nr=70 srsrp_nr=90
    ...    pass_regexp=measurementReport    fail_regexp=rrcReconfigurationComplete

Trigger ScellSwap
    [Arguments]    ${carrierfreq}=125090     ${ue_id}=1    ${event_type}=A6    ${scell_id}=1    ${srsrp_nr}=5
    ...    ${phycell_id}=61    ${nrsrp_nr}=5
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    scell=${scell_id} scell_rsrp=${srsrp_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${scell_swap}

UE Register and setup PDU with eligible DRB
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${qos_flow}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${PDU_SETUP}

Sent Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${Pcell_Tput_Target}=70    ${Scell1_Tput_Target}=70    ${scell_id}=1    ${Tput_ul}=8    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${Pcell_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${Pcell_tput}/1000 > ${Pcell_Tput_Target}
    ${Scell1_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${Scell1_Tput}/1000 > ${Scell1_Tput_Target}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify Throughput only pcell
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=70    ${Tput_ul}=8    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify no Scell
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=7    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}



