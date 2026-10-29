*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT
...    owner-ying.5.chen    team-SG2    release-5G20B    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SOS_REPORT_FLAG}    pass:False,fail:False
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:False
${SNAPSHOT_FLAG}     pass:False,fail:False

${UE1_Capabilities}    SEPARATOR=
...    E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB28986801EB608080838778E1C830E000
...    8193C7D5C0013C0070004F000A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D
...    012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261A007AD8202020E1DE38720C380020
...    64F1F55000005000000108389A00000000404D1700007008089EC2E003E00281C1401C0C026007000683E0000000000000E54D000100000965
...    950034AAA85800E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094E26D0

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_5QI2}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_A3}
...    @{PARAMS_FOR_A1}
...    @{PARAMS_FOR_A2}
...    @{PARAMS_FOR_InterFreq_IntraFreq_HO}
...    @{PARAMS_FOR_XN}
...    @{Intra_freq_ANR-PCI}
...    @{other}

@{other}
...    NRCELL-1:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrRelReportCu=disabled
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:discardTimer=1500ms

@{PARAMS_FOR_SECURITY}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4

@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-2:actVoNR=true
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=6000
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false

@{PARAMS_FOR_5QI2}
...    NRBTS/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-16:dscp=46
...    NRBTS/NRDRB-16:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:numSduDiscard=1
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-16:resType=nonGBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=24
...    NRBTS/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4

@{PARAMS_FOR_A3}
...    NRBTS/NRCELL-1:a3MeasEnabled=rsrp
...    NRBTS/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRBTS/NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRBTS/NRCELL-1:sMeasConfigSsbRsrp=1
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRBTS/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...    NRBTS/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRBTS/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRBTS/NRCELL-2:a3MeasEnabled=rsrp
...    NRBTS/NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRBTS/NRCELL-2:absThreshSsbRsrqConsolidation=1
...    NRBTS/NRCELL-2:sMeasConfigSsbRsrp=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRBTS/NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS/NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRBTS/NRCELL-2:measGapSelectionSA=favourUeThroughput

@{PARAMS_FOR_InterFreq_IntraFreq_HO}
#...    delete:NRCELL-1/NRREL-1
#...    delete:NRCELL-2/NRREL-1


...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:timerXnUeProcGuard=6000
...    NRBTS-1/NRCELL-1:nrarfcn=633364
...    NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7845
...    NRBTS-1/NRCELL-2:nrarfcn=633508
...    NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7847
...    NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=40
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
#...    NRBTS/NRCELL-1/NRREL-2:gNbId=35
#...    NRBTS/NRCELL-1/NRREL-2:gNbIdLength=22
#...    NRBTS/NRCELL-1/NRREL-2:lcrId=1
#...    NRBTS/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
#...    NRBTS/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
#...    NRBTS/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-1/NRHOIF-2:cellDepType=SA
...    NRBTS-1/NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf3
...    NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-1/NRHOIF-2:ssBurstSetPeriod=40
...    NRBTS-1/NRCELL-1/NRHOIF-2:ssbFrequency=633408
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
#...    NRBTS/NRCELL-1/NRREL-1:gNbId=1
#...    NRBTS/NRCELL-1/NRREL-1:gNbIdLength=22
#...    NRBTS/NRCELL-1/NRREL-1:lcrId=2
#...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
#...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
#...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
#...    NRBTS/NRCELL-2/NRREL-1:gNbId=1
#...    NRBTS/NRCELL-2/NRREL-1:gNbIdLength=22
#...    NRBTS/NRCELL-2/NRREL-1:lcrId=1
#...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
#...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
#...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssBurstSetPeriod=40
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=633216
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
...    NRBTS/NRCELL-2/NRREL-2:gNbId=35
...    NRBTS/NRCELL-2/NRREL-2:gNbIdLength=22
...    NRBTS/NRCELL-2/NRREL-2:lcrId=1
...    NRBTS/NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRBTS/NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRBTS/NRCELL-2/NRREL-2:gnbPlmn:mncLength=3

@{PARAMS_FOR_A1}
...    NRBTS/NRCELL-1:a1MeashoEnabled=rsrp
...    NRBTS/NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-2:a1MeashoEnabled=rsrp
...    NRBTS/NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480

@{PARAMS_FOR_A2}
...    NRBTS/NRCELL-1:a2MeashoEnabled=rsrpAndRsrq
...    NRBTS/NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRBTS/NRCELL-2:a2MeashoEnabled=rsrpAndRsrq
...    NRBTS/NRCELL-2:a2MeashoEnabledSA=rsrpAndRsrq
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480

@{Intra_freq_ANR-PCI}
...    NRCELL:actCDrx=true
...    NRCELL:drxProfile1:drxInactivityTimer=80ms
...    NRCELL:drxProfile1:drxLongCycle=160ms
...    NRCELL:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-1:drxProfileNrAnr:drxControl=intraNRSA
...    NRCELL-1:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-1:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-1:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-1:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS-1:actSaUeBasedInterFreqAnrNr=true
...    NRBTS/NRANR-1:actAutoEutraNbRemoval=false
...    NRBTS/NRANR-1:actAutoNrNbRemoval=true
...    NRBTS/NRANR-1:consecHoFailThres=0
...    NRBTS/NRANR-1:consecHoFailThresEutra=3
...    NRBTS/NRANR-1:consecXnResolveFailThres=3
...    NRBTS/NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRBTS/NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRBTS/NRANRPR-2:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-2:anrThresRsrqNbCell=-48
...    NRBTS/NRANRPR-2:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-2:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRBTS/NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-2:nrarfcn=633508
...    NRBTS/NRANRPR-2:ssbFrequency=633408

@{PARAMS_FOR_XN}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS-1/NRADJNRCELL-1:lcrId=1
...    NRBTS-1/NRADJNRCELL-1:gNbId=35
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=633508
...    NRBTS-1/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS-1/NRADJNRCELL-1:physCellId=381
...    NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJNRCELL-1:ssbFrequency=633408

${ATT_IF_INTER_GNB_HO_SLICE}     M55149C00570    #The number of Inter-Frequency Inter-gNB HOs attempted
${SUCC_OG_IF_INTER_GNB_HO_SLICE}    M55149C00571    #The number of Inter-Frequency Inter-gNB Outgoing HO successful
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550    #The numberof Inter-Frequency Intra-gNB Intra-DU HOs attempted for the given slice and PLMN
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551    #The numberof Inter-Frequency Intra-gNB Intra-DU HOs successful for the given slice and PLMN
${SUCC_HO_NRREL}    M55153C00002    #The number of HO Success per neighbor relation
${ATT_HO_NRREL}    M55153C00001    #The number of HO attempts per neighbor relation

@{PM_Counters_Check_D012}
...    NRBTS-1:NSL:${ATT_IF_INTER_GNB_HO_SLICE}=1
...    NRBTS-1:NSL:${SUCC_OG_IF_INTER_GNB_HO_SLICE}=1
...    NRBTS-1:NSL:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRBTS-1:NSL:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRCELL-1:NRREL:${ATT_HO_NRREL}=2
...    NRCELL-1:NRREL:${SUCC_HO_NRREL}=2
...    NRCELL-2:NRREL:${ATT_HO_NRREL}=2
...    NRCELL-2:NRREL:${SUCC_HO_NRREL}=2

@{pass_regexp_ANR}
...    reportType reportCGI
...    Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1


*** Test Cases ***
5GC000786-ET-D012_Verify VoNR_5QI5_5QI1 Inter-frequency Intra-DU Intra-gNB handover success with muti target cells and per-UE measurement gaps
    [Documentation]
    ...    1. The purpose of this test case is to setup vonr call and check inter-frequency Intra-DU handover successful
    ...    2. Test Case Steps:
    ...         cell1 frequency: 633364, cell2 frequency:633508, sim cell frequency: 633508
    ...                     ssb: 633216              ssb: 633408                ssb: 633408
    ...         a. setup XN link
    ...         b. trigger HO, from cell1 HO to sim cell1, from sim cell1 ho to cell2. form cell2 ho to cell1
    ...         c. trigger HO, from cell1 HO to cell1, from cell2 ho to sim cell1. form sim cell1 ho to cell1
    ...         d. check conuter
    [Tags]    D012    QC_61510
#    Clear Counter Files
    Setup Xn Link To gNB
    Trigger UE MO VoNR Call With PDU
    UE tirgger Intra-Freq Intra-GNB HO by A3
    UE tirgger Reverse handover
    Check Counters    ${PM_Counters_Check_D012}
    Release UEs    ue_type=all


*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    ${set_ue1}    catenate                 #UE configuration
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${ue1_param}    catenate
    ...    ue_param id=1 ue_nr_capabilities=${UE1_Capabilities} nr_usage_setting=voice_centric
    Update Cfg    ${set_ue1}
    Update Cfg    ${ue1_param}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
#    ${set_ue2}    catenate
#    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
#    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
#    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
#    ${ue2_param}    catenate
#    ...    ue_param id=2 ue_nr_capabilities=${UE1_Capabilities} nr_usage_setting=voice_centric
#    Update Cfg    ${set_ue2}
#    Update Cfg    ${ue2_param}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=on        #5QI configuration
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2,3,4 qos_rules=1,2,3
    ${set_gnb2}    catenate               #Xn
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${set_gnb2}
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=633364:633364 gscn=7845 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    ${set_gnb2_cell2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=633508:633508 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell2}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1 plmnList=311:489
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false measEvent=A3
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633508:633508
    ...    gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}

Setup Xn Link To gNB
    [Arguments]    ${gnb}=3
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    execute egate command    gnb_param id=${gnb} xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    execute egate command    gnb_xn_link_up gnb=${gnb} target=2    GNB-3: XnAP Link with GNB-2 .* is up

Trigger UE MO VoNR Call With PDU
    [Arguments]    ${id}=1
    execute egate command    ue_register id=${id}    UE now in NG RM Registered
    ${out}    execute egate command    ue_pdu_session_setup ue=${id} pdu=1 gw=${id} nwslice=1    QoS Routing Table
    should contain    ${out}    Setup QosFlow with QFI:1 5QI:5

UE tirgger Intra-Freq Intra-GNB HO by A3
    [Arguments]    ${id}=1
    Trigger UE from Cell1 to SIM Cell by A3
    Trigger UE from SIM Cell to Cell2 by A3
    Trigger UE from Cell2 to Cell1 by A3

Trigger UE from Cell1 to SIM Cell by A3
    [Arguments]    ${ue}=1
    BuiltIn.Log    Trigger UE1 A2 Measurement Report
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633216    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    execute_egate_command    ${A2_Event}    rrcReconfigurationComplete    timeout=20s

    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633408    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid1} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=110 nrsrq_nr=110
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=${pass_regexp_ANR}    timeout=20s
    Wait Until Keyword Succeeds    20min    10s    Object Should Exist    NRBTS-1/NRCELL-1/NRREL-256:gNbId=35
    execute egate command    ue_pdu_session_modify ue=${ue} pdu=1 qosflows_to_add=2 by=amf    Added QosFlow with QFI:2 5QI:1

Trigger UE from SIM Cell to Cell2 by A3
    [Arguments]    ${ue}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633408    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=85
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.2    timeout=20s

Trigger UE from Cell2 to Cell1 by A3
    [Arguments]    ${ue}=1
    BuiltIn.Log    Trigger UE1 A2 Measurement Report
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633408    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    execute_egate_command    ${A2_Event}    rrcReconfigurationComplete    timeout=20s
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633216    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid1} event=A3 srsrp_nr=11 phycell_id=50 nrsrp_nr=110 nrsrq_nr=110
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1    timeout=20s

UE tirgger Reverse handover
    Trigger UE from Cell1 to Cell2 by A3
    Trigger UE from Cell2 to SIM Cell by A3
    Trigger UE from SIM Cell to Cell1 by A3

Trigger UE from Cell1 to Cell2 by A3
    [Arguments]    ${ue}=1
    BuiltIn.Log    Trigger UE1 A2 Measurement Report
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633216    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0
    ...    phycell_id=51 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${ret1}=    execute_egate_command    ${A2_Event}    rrcReconfigurationComplete    timeout=20s
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633408    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid1} event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=110
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed    timeout=20s

Trigger UE from Cell2 to SIM Cell by A3
    [Arguments]    ${ue}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633408    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=80
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed    timeout=20s

Trigger UE from SIM Cell to Cell1 by A3
    [Arguments]    ${ue}=1
    BuiltIn.Log    Trigger UE1 A2 Measurement Report
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633216    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid1} event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed    timeout=20s



