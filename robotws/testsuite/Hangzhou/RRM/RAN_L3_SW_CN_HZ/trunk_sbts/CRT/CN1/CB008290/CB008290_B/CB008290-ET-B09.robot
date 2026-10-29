*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-xiaowen.xu
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{A1pcellchange}
...    @{A2pcellchange}
...    NRCELL:cellDepType=SA
...    delete:NRCELL:configuredEpsTac

...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    MRBTS-1/NRBTS-1/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    MRBTS-1/NRBTS-1/NRDU-1:actConnectedModeMobilityCA=True
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}    @{NRREL}    @{8290_enable}
...    @{HoSA_A2A3A5}
...    @{actCDrx}
...    @{RRE_Config}

@{RRE_Config}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=4000ms

@{HoSA_A2A3A5}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms160
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=60
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=126750
...    NRCELL-1/NRHOIF-2:cellDepType=SA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=633216
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=424090
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-2:cellDepType=SA
...    NRCELL-2/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-2:ssbFrequency=518910
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-2/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-1:ssbFrequency=518910
...    NRCELL-14/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-14/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30

${CA_support_list}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased

...    NRCELL-1:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-2:a6MeasSCellSwapEnabled=rsrq
...    NRCELL-11:a6MeasSCellSwapEnabled=rsrpAndRsrq
...    NRCELL-12:a6MeasSCellSwapEnabled=rsrqCombined
...    NRCELL-13:a6MeasSCellSwapEnabled=rsrq
...    NRCELL-14:a6MeasSCellSwapEnabled=rsrpCombined
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:weightForSCellSelection=50
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-11:gscnOrSsPbchArfcn=5300
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz

...    MRBTS-1/NRBTS-1/NRCELL-13:gscnOrSsPbchArfcn=5300
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz

@{A1pcellchange}
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    NRCELL-14/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1ThresholdPCellSwitchSsbRsrp=35|a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-1:ssbFrequency=424090
...    NRCELL-14/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-14/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{A2pcellchange}
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=75
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=50

@{actCDrx}
...    NRCELL:actCDrx=false
...    NRCELL-1:actCDrx=true
...    NRCELL-11:actCDrx=true
...    NRCELL-1:drxProfileNrAnr:drxControl=interRATeUTRA
#...    NRCELL-1:drxProfileNrAnr:drxInactivityTimer=80ms
#...    NRCELL-1:drxProfileNrAnr:drxLongCycle=320ms
#...    NRCELL-1:drxProfileNrAnr:drxOnDurationTimer=20ms
#...    NRCELL-1:drxProfileNrAnr:drxRetransTimerDl=0slot
#...    NRCELL-1:drxProfileNrAnr:drxRetransTimerUl=0slot

@{NRREL}
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-5:removeNotAllowed=false
...    NRCELL-1/NRREL-5:lcrId=14
...    NRCELL-1/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-5:sCellPrio=2
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=13
...    NRCELL-1/NRREL-4:sCellPrio=1
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=12
...    NRCELL-1/NRREL-3:sCellPrio=1
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=11
...    NRCELL-1/NRREL-2:sCellPrio=1
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:sCellPrio=1
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-5:gNbId=1
...    NRCELL-2/NRREL-5:gNbIdLength=22
...    NRCELL-2/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-5:removeNotAllowed=false
...    NRCELL-2/NRREL-5:lcrId=14
...    NRCELL-2/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-5:sCellPrio=2
...    NRCELL-2/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-4:gNbId=1
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-4:removeNotAllowed=false
...    NRCELL-2/NRREL-4:lcrId=13
...    NRCELL-2/NRREL-4:sCellPrio=1
...    NRCELL-2/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:lcrId=12
...    NRCELL-2/NRREL-3:sCellPrio=1
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=11
...    NRCELL-2/NRREL-2:sCellPrio=1
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:sCellPrio=1
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-4:gNbId=1
...    NRCELL-14/NRREL-4:gNbIdLength=22
...    NRCELL-14/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-4:removeNotAllowed=false
...    NRCELL-14/NRREL-4:lcrId=13
...    NRCELL-14/NRREL-4:sCellPrio=1
...    NRCELL-14/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-3:gNbId=1
...    NRCELL-14/NRREL-3:gNbIdLength=22
...    NRCELL-14/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-3:removeNotAllowed=false
...    NRCELL-14/NRREL-3:lcrId=11
...    NRCELL-14/NRREL-3:sCellPrio=1
...    NRCELL-14/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-2:gNbId=1
...    NRCELL-14/NRREL-2:gNbIdLength=22
...    NRCELL-14/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-2:removeNotAllowed=false
...    NRCELL-14/NRREL-2:lcrId=2
...    NRCELL-14/NRREL-2:sCellPrio=1
...    NRCELL-14/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:removeNotAllowed=false
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:sCellPrio=1
...    NRCELL-14/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-1:sCellAdditionMethod=covBasedA1

${SA_Capa_Support}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F
...    11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC0
...    9F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F
...    28581C0E1E13FFE00000FFF80000088000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00
...    038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B0
...    2B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02
...    B170A000388C001C46000004160563E268007118003850001C4100000E160561E230007118000018581007011A014404D80821A82F41F0A2
...    44D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C
...    73E044810206C73E044810206C73E044810206C73E0468102040D8E7C0850206C73E0005C3C6318C6318C6318C63187A09801E00140E0A00
...    E0601280380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018
...    0100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B26
...    6B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2
...    CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A6
...    2A93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A0502814001C202018030080100210100200804030061
...    0080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C0182020040100801004301002004
...    04030060100200404030061AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

${pdu_id}    1
${gw_id}    1
${nwslice}    1
${RECREATE_WIRESHARK_FLAG}    ${False}
*** Test Cases ***
CB008290-ET-B09 Verify_A6_scell_swap_successfully_for_TTFF
    [Documentation]
    ...    1. This user scenario describes A6 configuration and swap with 3cc interworking
    ...    configuration: 2T4F, cell1 and cell2 different Frequency, cell11 and cell13 same Frequency diff scellprio,
    ...    cell12 and cell14 same Frequency same scellprio.
    ...    2. Test Steps
    ...    UE attach to cell 1 .
    ...    Trigger A1MR , scell add T2,F11,F12 --> TTFF
    ...    to do scell swap F11<->F13,F12<->F14, repeat 5 times
    ...    to do A2PcellSwitch from cell1 to cell13 , a1ThresholdSCellAddSsbRsrpFDD < threshold < a1ThresholdSCellAddSsbRsrpTDD
    ...    to do F+F CA , F14 + F11
    ...    to do A2A3 interFre HO to cell114 to cell1 ,threshold > a1ThresholdSCellAddSsbRsrpTDD
    ...    scell add T2,F12,F13 --> TTFF
    ...    to do scell swap F12<->F14,F13<->F11, repeat 5 times
    ...    to release F12
    ...    to release F11
    ...    release UE
    [Tags]    owner-xiaowen.xu    B09    QC_222568
    UE attach and trigger 4CC
    Trigger A6swap r1
    Trigger pcellswitch or scellrelease    scell_index=4    threshold=75    scell_rsrp=80    scell_rsrq=55
    Verify Throuput For FF    scellF1_id=1
    trigger mr    event_type=A2    carrierfreq=126750    srsrp_nr=20    srsrq_nr=20    ue_id=81
    Trigger A3MR    event_type=A3    carrierfreq=518910    srsrp_nr=100    srsrq_nr=80    ue_id=81    phycell_id=50
    Verify Throuput For TTFF    scellF1_id=2    scellF2_id=3
    Trigger A6swap r2
    Release FDD scells and deregister UE
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B09${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
UE attach and trigger 4CC
    [Arguments]    ${ue_id}=81
    Update UE capa    ${SA_Capa_Support}    ${ue_id}
    ue attach to target cell    cell_id=1
    trigger mr    event_type=A1    carrierfreq=518910    srsrp_nr=100    srsrq_nr=80
    Send Throuput
    Verify Throuput For TTFF    scellF1_id=2    scellF2_id=3

Release FDD scells and deregister UE
    Trigger pcellswitch or scellrelease     carrierfreq=424090    scell_index=4    threshold=34
    Verify Throuput For TTFF    scellF1_id=2    scellF2_id=2
    Trigger pcellswitch or scellrelease     carrierfreq=126750    scell_index=2    threshold=34
    Verify Throuput For TTFF    scellF1_id=0    scellF2_id=0
    UE Deregister From gNB    81

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Trigger pcellswitch or scellrelease
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${scell_index}=1    ${ue_id}=81    ${scell_rsrp}=10
    ...    ${scell_rsrq}=61    ${threshold}=34
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=${event_type} meas_id=${meas_id} srsrp_nr=50 srsrq_nr=50
    ...    scell=${scell_index} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger MR
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81    ${phycell_id}=62
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${phycell}    Catenate    phycell_id=${phycell_id} nrsrp_nr=110 nrsrq_nr=100
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}     pass_regexp=rrcReconfigurationComplete

Trigger A3MR
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81    ${phycell_id}=62
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${phycell}    Catenate    phycell_id=${phycell_id} nrsrp_nr=110 nrsrq_nr=100
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${cmd_1}    Catenate    ${cmd} ${phycell}
    Execute Egate Command    ${cmd_1}    pass_regexp=Intra-eNB handover

Trigger A6swap
    [Arguments]    ${carrierfreq}=518910    ${scell_index}=1    ${phycell_id}=51    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=A6    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=A6 meas_id=${meas_id} srsrp_nr=60 srsrq_nr=60
    ...    scell=${scell_index} scell_rsrp=10 scell_rsrq=10 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${cmd}    pass_regexp=sCellToReleaseList

Trigger A6swap r1
    trigger a6swap    carrierfreq=424090    scell_index=2    phycell_id=62    ue_id=81    #2->4
    Verify Throuput For TTFF    scellF1_id=4    scellF2_id=3
    trigger a6swap    carrierfreq=126750    scell_index=3    phycell_id=63    ue_id=81    #3->2
    Verify Throuput For TTFF    scellF1_id=4    scellF2_id=2
    trigger a6swap    carrierfreq=424090    scell_index=4    phycell_id=60    ue_id=81    #4->3
    Verify Throuput For TTFF    scellF1_id=3    scellF2_id=2
    trigger a6swap    carrierfreq=126750    scell_index=2    phycell_id=61    ue_id=81    #2->4
    Verify Throuput For TTFF    scellF1_id=3    scellF2_id=4
    Trigger A6swap r1 PART2
    Trigger A6swap r1 PART3

Trigger A6swap r1 PART2
    trigger a6swap    carrierfreq=424090    scell_index=3    phycell_id=62    ue_id=81    #3->2
    Verify Throuput For TTFF    scellF1_id=2    scellF2_id=4
    trigger a6swap    carrierfreq=126750    scell_index=4    phycell_id=63    ue_id=81    #4->3
    Verify Throuput For TTFF    scellF1_id=2    scellF2_id=3
    trigger a6swap    carrierfreq=424090    scell_index=2    phycell_id=60    ue_id=81    #2->4
    Verify Throuput For TTFF    scellF1_id=4    scellF2_id=3
    trigger a6swap    carrierfreq=126750    scell_index=3    phycell_id=61    ue_id=81    #3->2
    Verify Throuput For TTFF    scellF1_id=4    scellF2_id=2

Trigger A6swap r1 PART3
    trigger a6swap    carrierfreq=424090    scell_index=4    phycell_id=62    ue_id=81    #4->3
    Verify Throuput For TTFF    scellF1_id=3    scellF2_id=2
    trigger a6swap    carrierfreq=126750    scell_index=2    phycell_id=63    ue_id=81    #2->4
    Verify Throuput For TTFF    scellF1_id=3    scellF2_id=4

Trigger A6swap r2
    trigger a6swap    carrierfreq=126750    scell_index=2    phycell_id=63    ue_id=81    #2->4
#    Verify Throuput For TTFF    scellF1_id=4    scellF2_id=3
    trigger a6swap    carrierfreq=424090    scell_index=3    phycell_id=60    ue_id=81    #3->2
#    Verify Throuput For TTFF    scellF1_id=4    scellF2_id=2
    trigger a6swap    carrierfreq=126750    scell_index=4    phycell_id=61    ue_id=81    #4->3
    Verify Throuput For TTFF    scellF1_id=3    scellF2_id=2
    trigger a6swap    carrierfreq=424090    scell_index=2    phycell_id=62    ue_id=81    #2->4
    Verify Throuput For TTFF    scellF1_id=3    scellF2_id=4
    Trigger A6swap r2 PART2
    Trigger A6swap r2 PART3

Trigger A6swap r2 PART2
    trigger a6swap    carrierfreq=126750    scell_index=3    phycell_id=63    ue_id=81    #3->2
    Verify Throuput For TTFF    scellF1_id=2    scellF2_id=4
    trigger a6swap    carrierfreq=424090    scell_index=4    phycell_id=60    ue_id=81    #4->3
    Verify Throuput For TTFF    scellF1_id=2    scellF2_id=3
    trigger a6swap    carrierfreq=126750    scell_index=2    phycell_id=61    ue_id=81    #2->4
    Verify Throuput For TTFF    scellF1_id=4    scellF2_id=3
    trigger a6swap    carrierfreq=424090    scell_index=3    phycell_id=62    ue_id=81    #3->2
    Verify Throuput For TTFF    scellF1_id=4    scellF2_id=2

Trigger A6swap r2 PART3
    trigger a6swap    carrierfreq=126750    scell_index=4    phycell_id=63    ue_id=81    #4->3
    Verify Throuput For TTFF    scellF1_id=3    scellF2_id=2
    trigger a6swap    carrierfreq=424090    scell_index=2    phycell_id=60    ue_id=81    #2->4
    Verify Throuput For TTFF    scellF1_id=3    scellF2_id=4
    trigger a6swap    carrierfreq=126750    scell_index=3    phycell_id=61    ue_id=81    #3->2
    Verify Throuput For TTFF    scellF1_id=2    scellF2_id=4

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=9    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput For TTFF
    [Arguments]    ${ue_id}=81    ${pcell_dl}=100    ${scell_dl_F}=0    ${ul}=0    ${scellF1_id}=2    ${scellF2_id}=3
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${pcell_dl}
    ${scellF1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scellF1_id}    type=pdsch    rate_type=ave
    Should Be True    ${scellF1_tput}/1000 > ${scell_dl_F}
    ${scellF2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scellF2_id}    type=pdsch    rate_type=ave
    Should Be True    ${scellF2_tput}/1000 > ${scell_dl_F}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput For FF
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl_F}=0    ${ul}=0    ${scellF1_id}=2
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scellF1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scellF1_id}    type=pdsch    rate_type=ave
    Should Be True    ${scellF1_tput}/1000 > ${scell_dl_F}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
