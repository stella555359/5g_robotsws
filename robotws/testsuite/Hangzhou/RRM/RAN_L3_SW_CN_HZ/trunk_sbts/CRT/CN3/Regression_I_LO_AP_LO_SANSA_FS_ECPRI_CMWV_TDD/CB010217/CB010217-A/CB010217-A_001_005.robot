*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    team-SG2    release-SBTS23R4
...    owner-ying.5.chen    owner-teana.wang    owner-jianfen.shen    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}         tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_5QI2}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_A1}
...    @{PARAMS_FOR_A2}
...    @{PARAMS_FOR_A3}
...    @{PARAMS_FOR_InterFreq_IntraFreq_HO}
...    @{PARAMS_FOR_XN}
...    @{PARAMS_FOR_PMQAP}
...    @{PARAMS_FOR_5GC000784}
...    @{PARAMS_FOR_5GC000710}
...    @{DISABLE_CB010217}
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    MRBTS-1/NRBTS-1/NRDRB-16:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1

@{PARAMS_FOR_SECURITY}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-2:actVoNR=false
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
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:discardTimer=1500ms
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

@{Intra_freq_ANR-PCI}
...    NRBTS:actSaUeBasedAnrNr=true
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoEutraNbRemoval=false
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoNrNbRemoval=true
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThres=3
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThresEutra=3
...    MRBTS-1/NRBTS-1/NRANR-1:consecXnResolveFailThres=3
...    MRBTS-1/NRBTS-1/NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    MRBTS-1/NRBTS-1/NRANR-1:nrAnrId=1
...    MRBTS-1/NRBTS-1/NRANRPR-1:anrThresholdSelector=RSRP
...    MRBTS-1/NRBTS-1/NRANRPR-1:anrThresRsrpNbCell=-90
...    MRBTS-1/NRBTS-1/NRANRPR-1:anrThresRsrqNbCell=-12
...    MRBTS-1/NRBTS-1/NRANRPR-1:cellDepMode=SA+NSA
...    MRBTS-1/NRBTS-1/NRANRPR-1:consecRecheckForNrNbRemoval=5
...    MRBTS-1/NRBTS-1/NRANRPR-1:idleTimeForNrNbRemoval=72
...    MRBTS-1/NRBTS-1/NRANRPR-1:maxNumAnrNrrelAllowed=50
...    MRBTS-1/NRBTS-1/NRANRPR-1:nrAnrPrId=1

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


...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:timerXnUeProcGuard=6000
...    NRBTS-1/NRCELL-1:nrarfcn=633364
...    NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7845
...    NRBTS-1/NRCELL-2:nrarfcn=633508
...    NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7847
...    NRBTS-1/NRCELL-1/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL-1:lcrId=2
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-1/NRREL-2:gNbId=35
...    NRBTS-1/NRCELL-1/NRREL-2:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL-2:lcrId=1
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
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
...    NRBTS-1/NRCELL-2/NRREL-2:gNbId=35
...    NRBTS-1/NRCELL-2/NRREL-2:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL-2:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssBurstSetPeriod=40
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=633408
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64

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

@{PARAMS_FOR_PMQAP}
...    NRBTS-1:actNrpmqapProfiles=true
...    NRBTS-1:actIpThpt=true
...    NRPMRNL-1:miNrNGCC=15min
...    NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
...    NRPMRNL-1:miNrNgInterfaceNrpmqap=15min
...    NRPMRNL-1:miNrNsaAcCuNrpmqap=15min
...    NRPMRNL-1:miNrPdcpCellNrpmqap=15min
...    NRPMRNL-1:miNrSaCuNrpmqap=15min
...    NRPMRNL-1:miNrUeStatNrpmqap=15min
...    NRPMRNL-1:miNrX2ccNrpmqap=15min
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=both
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=1-15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1:miNrRelReportCu=15min

@{PARAMS_FOR_5GC000784}
...    NRCELL-1:arpPrioEmergencyCall=2
...    NRCELL-1:actEmergencyCall=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true

@{PARAMS_FOR_5GC000710}
...    delete:NRCELL/NRREDRT-1
...    NRBTS:actNormVCFallback=true
...    NRBTS:actRedirect=true
...    NRBTS:actMobilityProfile=true
...    NRBTS:actSPID=true
...    NRBTS/NRMOPR_NSA-1:a1MeashoEnabled=none
...    NRBTS/NRMOPR_NSA-1:a2MeashoEnabled=none
...    NRBTS/NRMOPR_NSA-1:a3MeasEnabled=none
...    NRBTS/NRMOPR_NSA-1:a5MeasEnabled=none
...    NRCELL:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRBTS/NRMOPR_SA-1:nrMoRedDNList=MRBTS-1/NRBTS-1/NRMORED-1
...    NRBTS/NRMOPR_SA-1:voiceFBMode=redirection
...    NRBTS/NRMORED-1:redirFreqEutra=39750
...    NRBTS/NRMORED-1:redirRat=eutra
...    NRBTS/NRMORED-1:redirPrio=2

@{PARAMS_FOR_5GC000749}
...    NRBTS:actNormVCFallback=true
...    NRBTS:actRedirect=true
...    NRCELL:voiceFBMode=redirection
...    NRCELL/NRREDRT-1:redirPrio=1
...    NRCELL/NRREDRT-1:redirFreqEutra=38100
...    NRCELL/NRREDRT-1:redirRat=eutra
...    delete:NRCELL/NRREDRT-1:redirSsbScs
...    delete:NRCELL/NRREDRT-1:redirFreqNr

@{DISABLE_CB010217}
...    NRBTS:actVoiceFallbackDuringHOPrep=disabled

@{ENABLE_CB010217}
...    NRBTS:actVoiceFallbackDuringHOPrep=voiceFallbackDuringXnHOPrep

@{UES_ON_CELL2_A001}    1    2    3    4
@{UES_ON_CELL1_A001}    5    6    7
@{UES_WITH_VONR_A001}    2    3    4    6    7

@{Setup_5QI5_Success}
...    Setup QosFlow with QFI:1 5QI:5
...    rrcReconfigurationComplete
...    QoS Routing Table

@{Add_5QI1_Success}
...    Added QosFlow with QFI:2 fiveQI:1
...    rrcReconfigurationComplete
...    QoS Routing Table

@{HO_Success}
...    Inter-eNB handover from EXT_ENB-2.* to ENB-3.1 performed
...    Setup QosFlow with QFI:1
...    PATH SWITCH REQUEST ACK

#cause33: xn-handover-triggered
@{Add_5QI1_failed_and_HO_Success}
...    Adding QosFlow with QFI.* 5QI:1
...    PDU Session Resource Modify Unsuccessful Transfer
...    PDU SESSION RESOURCE MODIFY RESPONSE Modify Item with cause 33
...    Deleted Unsuccessful QosFlow QFI:2
...    @{HO_Success}

@{Setup_5QI1_Failed_and_HO_Success}
...    Setup QosFlow with QFI.* fiveQI:1
...    PDU Session Resource Setup with PDU Session ID .* was unsuccessful due to RAN xn handover triggered
...    @{HO_Success}

#cause 36: IMS voice EPS fallback or RAT fallback triggered
@{Add_5QI1_failed_and_Redirect_to_LTE}
...    Adding QosFlow with QFI.* 5QI:1
...    PDU Session Resource Modify Unsuccessful Transfer
...    PDU SESSION RESOURCE MODIFY RESPONSE Modify Item with cause 36
...    Deleted Unsuccessful QosFlow QFI:2
...    Re-direction to 4G/LTE cell
...    Received UE Context Release Complete from GNB-2
...    UE.*IS IDLE

@{Delta_for_A005}
...    NRCELL-2:actVoNR=true
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREL-2
...    @{Intra_freq_ANR-PCI}
...    @{ENABLE_CB010217}
...    @{PARAMS_FOR_5GC000749}

@{OnlineParam_for_ANR_Recover}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREL-256

@{pass_regexp_ANR}
...    Adding QosFlow with QFI:2 5QI:1
...    PDU Session Resource Modify Unsuccessful Transfer
...    Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed

@{pass_regexp_HO_CELL2_SIMCELL1}
...    Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

#Number of outgoing Handover Cancel sent to Target gNB
${XN_HO_CANCEL_SENT}    M55143C00003
#HO preparation failure per neighbour cell relation
${FAIL_HO_NRREL_PREP}    M55153C00003
#Number of 5QI-1 QoS Flows setup failure due to Fallback
${NG_FLOW_STP_FAIL_FALBACK_5QI1}    M55125C09519
#Number of PMQAP Profile based QoS Flows released due to voice Fallback for PMQAP Profile
${NG_FLOW_STP_FAIL_FALBACK_PMQAP}    M55163C00501
#Number of RRC Releases with LTE frequency redirection information
${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502
#Number of Xn handover preparations canceled due to EPS fallback
${XN_HO_PREP_CNC_SRC_EPSFB}    M55143C00012
#Number of 5QI-1 QoS Flow setup failures due to ongoing Xn handover
${NG_FLOW_STP_FAIL_HO_5QI1}    M55125C00035
#Number of RRC RELEASE messages sent (CU counter)
${NRRCC_RRC_RELEASE_SENT}    M55124C00001

@{PM_Counters_with_Disable_CB010217}
...    NRCELL-1:${XN_HO_CANCEL_SENT}=0
...    NRCELL-2:${XN_HO_CANCEL_SENT}=0
...    NRCELL-1:NRREL:${FAIL_HO_NRREL_PREP}=0
...    NRCELL-2:NRREL:${FAIL_HO_NRREL_PREP}=0
...    NRCELL-1:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=0
...    NRCELL-2:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=0
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=0
...    NRCELL-2:${NRRCC_RRC_RELEASE_REDIR_LTE}=0
...    NRCELL-1:${XN_HO_PREP_CNC_SRC_EPSFB}=0
...    NRCELL-2:${XN_HO_PREP_CNC_SRC_EPSFB}=0
...    NRCELL-1:${NG_FLOW_STP_FAIL_HO_5QI1}=2
...    NRCELL-2:${NG_FLOW_STP_FAIL_HO_5QI1}=4
...    NRCELL-1:${NRRCC_RRC_RELEASE_SENT}=0
...    NRCELL-2:${NRRCC_RRC_RELEASE_SENT}=0

@{PM_Counters_with_Enable_CB010217}
...    NRCELL-1:${XN_HO_CANCEL_SENT}=3
...    NRCELL-2:${XN_HO_CANCEL_SENT}=3
...    NRCELL-1:NRREL:${FAIL_HO_NRREL_PREP}=3
...    NRCELL-2:NRREL:${FAIL_HO_NRREL_PREP}=3
...    NRCELL-1:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=3
...    NRCELL-2:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=3
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=3
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=4
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=3
...    NRCELL-2:${NRRCC_RRC_RELEASE_REDIR_LTE}=3
...    NRCELL-1:${XN_HO_PREP_CNC_SRC_EPSFB}=3
...    NRCELL-2:${XN_HO_PREP_CNC_SRC_EPSFB}=3
...    NRCELL-1:${NG_FLOW_STP_FAIL_HO_5QI1}=1
...    NRCELL-2:${NG_FLOW_STP_FAIL_HO_5QI1}=1
...    NRCELL-1:${NRRCC_RRC_RELEASE_SENT}=8
...    NRCELL-2:${NRRCC_RRC_RELEASE_SENT}=7

@{PM_Counters_Check_A005}
...    NRCELL-1:${XN_HO_CANCEL_SENT}=0
...    NRCELL-2:${XN_HO_CANCEL_SENT}=0
...    NRCELL-1:NRREL:${FAIL_HO_NRREL_PREP}=0
...    NRCELL-2:NRREL:${FAIL_HO_NRREL_PREP}=0
...    NRCELL-1:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=0
...    NRCELL-2:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=0
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=0
...    NRCELL-2:${NRRCC_RRC_RELEASE_REDIR_LTE}=0
...    NRCELL-1:${XN_HO_PREP_CNC_SRC_EPSFB}=0
...    NRCELL-2:${XN_HO_PREP_CNC_SRC_EPSFB}=0
...    NRCELL-1:${NG_FLOW_STP_FAIL_HO_5QI1}=0
...    NRCELL-2:${NG_FLOW_STP_FAIL_HO_5QI1}=2
...    NRCELL-1:${NRRCC_RRC_RELEASE_SENT}=0
...    NRCELL-2:${NRRCC_RRC_RELEASE_SENT}=0

${SA_UE_VoNR_Capabilities}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3
...    8002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36
...    26EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E
...    1DE38720C38002064F1F55000005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C0000000000
...    001CA9A0002000012CB2A00695550103800580000002004008D58980008101820283038405880889098C909293139425389B40

${UE_Capabilities_with_ANR_VONR}    SEPARATOR=
...    E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB28986801EB608080838778E1C830E000
...    8193C7D5C0013C0070004F000A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D
...    012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261A007AD8202020E1DE38720C380020
...    64F1F55000005000000108389A00000000404D1700007008089EC2E003E00281C1401C0C026007000683E0000000000000E54D000100000965
...    950034AAA85800E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094E26D0

${UE_Capabilities_with_ANR_NoVoNR}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C0010327
...    8FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286809659
...    44C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FAA80
...    00028000000841C4D00000000202682807008089EC1601B00140E0601C0C01601C001A0F8000000000000395340004000025965400D2AAA020
...    7000B000000040080118B130001020304050607080B101112131921252627284A0

*** Test Cases ***
CB010217-ET-A001_verify_actVoiceFallbackDuringHOPrep_disable_or_enable_triggering_EPS_Fallback_during_XN_HO_Preparation
    [Documentation]
    ...    1. The purpose of this test case is to verifies that during the XN-HO preparation phase, after triggering the
    ...       event 5QI-1, EPS fallback behavior can be triggered
    ...    2. Precondition:
    ...         real gnb-2: cell-1: TDD, pci: 50, ssbFrequency=633216
    ...                     cell-2: TDD, pci: 51, ssbFrequency=633408
    ...         sim gnb-3: cell-1: TDD, pci: 381, ssbFrequency=633408
    ...         location on cell2 (Disable VONR): UE 1,2,3,4
    ...         location on cell1 (Enable VONR): UE 5,6,7,10,11
    ...         UE with VONR Capability:          UE 2,3,4,6,7
    ...         actVoiceFallbackDuringHOPrep=disabled
    ...    2. Test Case Steps:
    ...         a. setup XN link up
    ...         b. set hold xn handover complete delay 5s time
    ...         c. UE1-7 attach to target cells -> setup pdus -> trigger A2/A3 to HO -> modify pdus
 	...                     Before HO	                            After HO	                    Expected Result
    ...            UE1/2 setup pdu1(5QI-5)   	                 Add pdu1 (5QI-1)                -> failed, HO success
    ...            UE3 setup pdu1(5QI-5)   	                     Setup pdu2 (5QI-1)              -> failed, HO success
    ...            UE4 setup pdu1(5QI-5)   	                     Add pdu1(5Q1-1+5QI-2)           -> failed, HO success
    ...            UE5 setup pdu1(5QI-5)+ pdu2(5QI-5)	         Add pdu2(5QI-1)                 -> failed, HO success
    ...            UE6 setup pdu1(5QI-5 + 5QI-1)+ PDU2(5Q1-5)    Add pdu2(5QI-1)                 -> failed, HO success
    ...            UE7 setup pdu1(5QI-5 + 5Q1-1)	             Modify pdu1 param(5QI-1) 	     -> failed, HO success
    ...         d. check counter value
    ...         e. update actVoiceFallbackDuringHOPrep=voiceFallbackDuringXnHOPrep to enable feature
    ...         f. UE1-7 HO back from sim cell3-1 to orig cell2-1 or cell2-2.
    ...         g. UE10-11 attach to cell2-1, and setup emergency pdus before HO.
    ...            UE10	   setup pdu1 emergency call(5QI-5)
    ...            UE11	   setup pdu1(5QI-5) + pdu2 emergency call(5QI-5)
    ...         h. UE1-11 trigger A2/A3 to HO -> modify pdus
  	...                    After HO	                             Expected Result
    ...            UE1/2 Add pdu1 (5QI-1)                     -> failed, redirect to LTE
    ...            UE3 Setup pdu2 (5QI-1)                     -> failed, HO success
    ...            UE4 Add pdu1(5Q1-1+5QI-2)                  -> failed, redirect to LTE
    ...            UE5 Add pdu2(5QI-1)                        -> failed, redirect to LTE
    ...            UE6 Add pdu2(5QI-1)                        -> failed, HO success
    ...            UE7 Modify pdu1 param(5QI-1) 	          -> failed, HO success
    ...            UE10	Add emergency pdu1(5QI-5 + 5QI-1)     -> failed, redirect to LTE
    ...            UE11	Add emergency pdu2(5QI-1)             -> failed, redirect to LTE
    ...         i. UEs HO back from sim cell3-1 to orig cell2-1 or cell2-2.
    ...         j. check counter value
    [Tags]    A001    ying.5.chen    teana.wang
    Clear Counter Files    wait=${False}
    Setup Xn Link To gNB
    Delay Response to Xn Handover Preparation
    UE1-7 Attach to Target Cell and Setup PDU Sessions before HO
    Concurrent PDU Modification during HO Preparation Based Feature Disabled
    Concurrent PDU Modification during HO Preparation Based Feature Enabled
    [Teardown]    A001 Recover Params and Test Teardown

CB010217-ET-A005_verify_Rejecting_request_setup_Voice_Service_during_Intra_freq_ANR-PCI_resolution_phase
    [Documentation]
    ...    1. The purpose of this test case is to verify that rejecting the request to setup 5QI1 during the intra-freq ANR-PCI resolution phase
    ...    or during the case where support for VoNR and EPS fallback is disabled in the gNB.
    ...    2. Test Case Steps:
    ...         Real gNB(gNB1) is in source, sim gNB(gNB3) is in target
    ...         cell1 frequency: 633364, cell2 frequency:633508, sim cell frequency: 633508
    ...                     ssb: 633216              ssb: 633408                ssb: 633408
    ...          UE capability:
    ...          CELL1_UE21: COMMON
    ...          CELL2_UE22: ANR
    ...          CELL1_UE23: VONR
    ...          CELL2_UE24: VONR+ANR
    ...         a. setup XN link up.
    ...         b. UE21, UE23 attach to cell1; UE22, UE24 attach to cell2.
    ...         c. Start and check traffic for UE21-UE24.
    ...         d. UEs Trigger Inter-gNB Intra-FreqANR HO And Inter-Freq HO.
    ...             d.1 UE24 Set PCI-ANR resolution time delay of 100ms to wait for pdu session modification to add 5QI1event.
    ...             d.2 UE24 trigger inter-gNB intra-freq HO from real gnb cell2 HO sim gnb cell1.
    ...             d.3 UE21 trigger inter-gNB inter-freq HO from real gnb cell1 HO sim gnb cell1.
    ...         e. Delete Cell2 ANR NRREL related NIDD parameters.
    ...         f. UE22 repeat step d.1-d.2, UE23 repeat d.3
    ...         g. UE21-UE24 HO to original cell.
    ...    3. Expert Result:
    ...         a. XN link setup successful.
    ...         b. UE21, UE23 attach to cell1 successful; UE22, UE24 attach to cell2 successful.
    ...         c. traffic can start successfully,DL/UL traffic are transferred without loss.
    ...         d.
    ...             d.1. Set delay time to wait 5QI1 event successfully.
    ...             d.2. when PCI-ANR parsing, concurrent 5QI1 creation failed. Source gNB continues with the PCI resolution procedure,
    ...                  and PCI-ANR setup successful, UE24 go on HO successful.
    ...             d.3. UE21 HO from real gnb cell1 HO sim gnb cell1 successfully.
    ...         e. Delete Cell2 ANR NRREL related parameters successfully and no error information.
    ...         f. Result as same as the step d.
    ...         g. UE21-UE24 can handover original cell successful and DL/UL traffic are transferred without loss.
    [Tags]    A005
    clear counter files    ${False}
    Case Setup For A005
    Setup Xn Link To gNB
    UE21 UE23 attach to Cell1 and UE22 UE24 attach to Cell2
    UE21 To UE24 Start And Check Traffic
    UEs Trigger Inter-gNB Intra-FreqANR HO And Inter-Freq HO    ue_id1=24    ue_id2=21
    Delete Cell2 ANR NRREL
    UEs Trigger Inter-gNB Intra-FreqANR HO And Inter-Freq HO    ue_id1=22    ue_id2=23
    UE21 to UE24 HO to origin cells
    Check Counters    pm_counters_expression=${PM_Counters_Check_A005}
    Release UEs    ue_type=all

*** Keywords ***
Modify Cfg
    ${set_amf1}    catenate    amf_param id=1 full_nas_auth=on nia=snow3g+zuc+aes+null nea=snow3g+zuc+aes+null
    ...    ims_voice_3gpp=on voice_fallback=on
    Update Cfg    ${set_amf1}
    FOR    ${ue_id}    IN    @{UES_ON_CELL2_A001}
        Update Cfg Param    set_ue simulated id=${ue_id} enb=2 cell=2
    END
    FOR    ${ue_id}    IN    @{UES_WITH_VONR_A001}
        Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${SA_UE_VoNR_Capabilities} nr_usage_setting=voice_centric
        Update Cfg    ue_nr_capabilities id=${ue_id} voice_over_nr=on:on:off
    END
    Update Cfg Param    set_ue simulated id=22 enb=2 cell=2
    Update Cfg Param    set_ue simulated id=24 enb=2 cell=2
    Update Cfg    ue_nr_capabilities id=23-24 voice_over_nr=on:on:off
    ${ue22_param}    catenate    ue_param id=22 ue_nr_capabilities=${UE_Capabilities_with_ANR_NoVoNR} nr_usage_setting=voice_centric
    Update Cfg    ${ue22_param}
    ${ue23_param}    catenate    ue_param id=23 ue_nr_capabilities=${UE_Capabilities_with_ANR_VONR} nr_usage_setting=voice_centric
    Update Cfg    ${ue23_param}
    ${ue24_param}    catenate    ue_param id=24 ue_nr_capabilities=${UE_Capabilities_with_ANR_VONR} nr_usage_setting=voice_centric
    Update Cfg    ${ue24_param}
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4 qos_rules=1,2,3
    ${set_gnb2}    catenate
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
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=633508:633508 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}

A001 Recover Params and Test Teardown
    Reset Xn Handover Preparation Param
    Set qosflow priority and smf param    priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 mfbr_dl=256 mfbr_ul=256 gfbr_dl=32 gfbr_ul=32
    Common Test Teardown And Stop Capture Logs

Setup Xn Link To gNB
    [Arguments]    ${gnb_id}=3
    execute egate command    gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    execute egate command    gnb_xn_link_up gnb=${gnb_id} target=2    GNB-${gnb_id}: XnAP Link with GNB-2 .* is up

Concurrent PDU Modification during HO Preparation Based Feature Disabled
    UE1-7 Setup or Modify PDU Session during Inter-GNB HO based Feature Disabled
    Check Counters    pm_counters_expression=${PM_Counters_with_Disable_CB010217}

Concurrent PDU Modification during HO Preparation Based Feature Enabled
    Delta Commission Parameters    ${ENABLE_CB010217}
    clear counter files
    UE1-7 HO Back to Origin Cells
    UE1-7 Setup or Modify PDU Session during Inter-GNB HO based Feature Enabled
    UE10-11 Attach to Cell2-1 and Setup Emergency PDU Session before HO
    UE10-11 Modify PDU Session during Inter-GNB HO based Feature Enabled
    UEs HO Back to Origin Cell
    Release UEs    ue_type=all
    Check Counters    pm_counters_expression=${PM_Counters_with_Enable_CB010217}

Set qosflow priority and smf param
    [Arguments]     ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Delay Response to Xn Handover Preparation
    Execute Egate Command    gnb_xn_handover_preparation_param id=3 action=delayed_rsp time_to_wait=v5s

Reset Xn Handover Preparation Param
    Execute Egate Command    gnb_xn_handover_preparation_param id=3 reset

Setup PDU Session with 5QI5
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${pass_regexp}=${Setup_5QI5_Success}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1     pass_regexp=${pass_regexp}

UE1-7 Attach to Target Cell and Setup PDU Sessions before HO
    FOR    ${ue_id}    IN RANGE    1    8
        Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    END
    UE1-7 Setup and Modify PDU Sessions before HO

UE1-7 Setup and Modify PDU Sessions before HO
    FOR    ${ue_id}    IN RANGE    1    8
        Setup PDU Session with 5QI5    ue_id=${ue_id}    pdu_id=1    pass_regexp=${Setup_5QI5_Success}
    END
    Execute Egate Command    ue_pdu_session_modify ue=6 pdu=1 qosflows_to_add=2 by=amf    pass_regexp=${Add_5QI1_Success}
    Execute Egate Command    ue_pdu_session_modify ue=7 pdu=1 qosflows_to_add=2 by=amf    pass_regexp=${Add_5QI1_Success}
    Setup PDU Session with 5QI5    ue_id=5    pdu_id=2    pass_regexp=${Setup_5QI5_Success}
    Setup PDU Session with 5QI5    ue_id=6    pdu_id=2    pass_regexp=${Setup_5QI5_Success}

UE1-7 Setup or Modify PDU Session during Inter-GNB HO based Feature Disabled
    Modify PDU Session during Inter-GNB Intra-Freq HO    ue_id=1    pdu_id=1    qosflows_action=qosflows_to_add    qos_ids=2
    ...    pass_regexp=${Add_5QI1_failed_and_HO_Success}
    Modify PDU Session during Inter-GNB Intra-Freq HO    ue_id=2    pdu_id=1    qosflows_action=qosflows_to_add    qos_ids=2
    ...    pass_regexp=${Add_5QI1_failed_and_HO_Success}
    Setup PDU Session with 5QI-1 during Inter-GNB Intra-Freq HO    ue_id=3    pdu_id=2
    ...    pass_regexp=${Setup_5QI1_Failed_and_HO_Success}
    Modify PDU Session during Inter-GNB Intra-Freq HO    ue_id=4    pdu_id=1    qosflows_action=qosflows_to_add    qos_ids=2,3
    ...    pass_regexp=${Add_5QI1_failed_and_HO_Success}
    Modify PDU Session during Inter-GNB Inter-Freq HO    ue_id=5    pdu_id=2    qosflows_action=qosflows_to_add    qos_ids=2
    ...    pass_regexp=${Add_5QI1_failed_and_HO_Success}
    Modify PDU Session during Inter-GNB Inter-Freq HO    ue_id=6    pdu_id=2    qosflows_action=qosflows_to_add    qos_ids=2
    ...    pass_regexp=${Add_5QI1_failed_and_HO_Success}
    Modify 5QI-1 Bit Rate during Inter-GNB Inter-Freq HO    ue_id=7    pdu_id=1    pass_regexp=${HO_Success}

UE1-7 Setup or Modify PDU Session during Inter-GNB HO based Feature Enabled
    Modify PDU Session during Inter-GNB Intra-Freq HO    ue_id=1    pdu_id=1    qosflows_action=qosflows_to_add    qos_ids=2
    ...    pass_regexp=${Add_5QI1_failed_and_Redirect_to_LTE}
    Modify PDU Session during Inter-GNB Intra-Freq HO    ue_id=2    pdu_id=1    qosflows_action=qosflows_to_add    qos_ids=2
    ...    pass_regexp=${Add_5QI1_failed_and_Redirect_to_LTE}
    Setup PDU Session with 5QI-1 during Inter-GNB Intra-Freq HO    ue_id=3    pdu_id=3
    ...    pass_regexp=${Setup_5QI1_Failed_and_HO_Success}
    Modify PDU Session during Inter-GNB Intra-Freq HO    ue_id=4    pdu_id=1    qosflows_action=qosflows_to_add    qos_ids=2,3
    ...    pass_regexp=${Add_5QI1_failed_and_Redirect_to_LTE}
    Modify PDU Session during Inter-GNB Inter-Freq HO    ue_id=5    pdu_id=2    qosflows_action=qosflows_to_add    qos_ids=2
    ...    pass_regexp=${Add_5QI1_failed_and_Redirect_to_LTE}
    Modify PDU Session during Inter-GNB Inter-Freq HO    ue_id=6    pdu_id=2    qosflows_action=qosflows_to_add    qos_ids=2
    ...    pass_regexp=${Add_5QI1_failed_and_HO_Success}
    Modify 5QI-1 Bit Rate during Inter-GNB Inter-Freq HO    ue_id=7    pdu_id=1    pass_regexp=${HO_Success}

UE10-11 Attach to Cell2-1 and Setup Emergency PDU Session before HO
    Execute Egate Command    ue_register id=10    NG RM Registered
    Execute Egate Command    ue_register id=11    NG RM Registered
    Setup PDU Session with 5QI5    ue_id=11    pdu_id=1    pass_regexp=${Setup_5QI5_Success}
    Set qosflow priority and smf param     priority=1
    Execute Egate Command    ue_pdu_session_setup ue=10 pdu=1 gw=1 nwslice=1 request_type=initial-emergency-request
    ...     pass_regexp=${Setup_5QI5_Success}
    Execute Egate Command    ue_pdu_session_setup ue=11 pdu=2 gw=2 nwslice=1 request_type=initial-emergency-request
    ...     pass_regexp=${Setup_5QI5_Success}

UE10-11 Modify PDU Session during Inter-GNB HO based Feature Enabled
    Modify PDU Session during Inter-GNB Inter-Freq HO    ue_id=10    pdu_id=1    qosflows_action=qosflows_to_add    qos_ids=1,2
    ...    pass_regexp=${Add_5QI1_failed_and_Redirect_to_LTE}
    Modify PDU Session during Inter-GNB Inter-Freq HO    ue_id=11    pdu_id=2    qosflows_action=qosflows_to_add    qos_ids=2
    ...    pass_regexp=${Add_5QI1_failed_and_Redirect_to_LTE}
    Set qosflow priority and smf param     priority=15

Modify PDU Session during Inter-GNB Inter-Freq HO
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qosflows_action}=qosflows_to_add    ${qos_ids}=1    ${pass_regexp}=QoS Routing Table
    Tirgger Inter-GNB Inter-Freq HO from Cell2-1 to Cell3-1    ue_id=${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} ${qosflows_action}=${qos_ids} by=amf
    ...    pass_regexp=${pass_regexp}

Modify PDU Session during Inter-GNB Intra-Freq HO
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qosflows_action}=qosflows_to_add    ${qos_ids}=1    ${pass_regexp}=QoS Routing Table
    Tirgger Inter-GNB Intra-Freq HO from Cell2-2 to Cell3-1    ue_id=${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} ${qosflows_action}=${qos_ids} by=amf
    ...    pass_regexp=${pass_regexp}

Modify 5QI-1 Bit Rate during Inter-GNB Inter-Freq HO
    [Arguments]    ${ue_id}    ${pdu_id}     ${pass_regexp}
    Execute Egate Command    qosflow_modify qos_flow=2 mfbr_dl=128 mfbr_ul=128 gfbr_dl=64 gfbr_ul=64
    Modify PDU Session during Inter-GNB Inter-Freq HO    ue_id=${ue_id}    pdu_id=${pdu_id}    qosflows_action=qosflows_to_add
    ...    qos_ids=2    pass_regexp=${pass_regexp}
    Execute Egate Command    qosflow_modify qos_flow=2 mfbr_dl=256 mfbr_ul=256 gfbr_dl=32 gfbr_ul=32

Setup PDU Session with 5QI-1 during Inter-GNB Intra-Freq HO
    [Arguments]    ${ue_id}    ${pdu_id}    ${pass_regexp}
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Tirgger Inter-GNB Intra-Freq HO from Cell2-2 to Cell3-1    ue_id=${ue_id}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1     pass_regexp=${pass_regexp}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on

Tirgger Inter-GNB Inter-Freq HO from Cell2-1 to Cell3-1
    [Arguments]    ${ue_id}=1    ${pass_regexp}=SNStatusTransfer in WAIT HANDOVER REQUEST
    BuiltIn.Log    Trigger UE${ue_id} InterFreq HO    console=${True}
    ${a2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    ...    pass_regexp=${pass_regexp}

Tirgger Inter-GNB Intra-Freq HO from Cell2-2 to Cell3-1
    [Arguments]    ${ue_id}=1    ${pass_regexp}=SNStatusTransfer in WAIT HANDOVER REQUEST
    BuiltIn.Log    Trigger UE${ue_id} IntraFreq HO    console=${True}
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    ...    pass_regexp=${pass_regexp}

Trigger UE HO Back from Cell3-1 to Cell2-1
    [Arguments]    ${ue_id}
    ${ho_success}    create list
    ...    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    ...    rrcReconfigurationComplete
    ...    PATH SWITCH REQUEST ACK
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
    ...    pass_regexp=${ho_success}

Trigger UE HO Back from Cell3-1 to Cell2-2
    [Arguments]    ${ue_id}
    ${ho_success}    create list
    ...    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.2 performed
    ...    rrcReconfigurationComplete
    ...    PATH SWITCH REQUEST ACK
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=85
    ...    pass_regexp=${ho_success}

UE1-7 HO Back to Origin Cells
    FOR    ${ue_id}     IN    @{UES_ON_CELL1_A001}
        Trigger UE HO Back from Cell3-1 to Cell2-1    ue_id=${ue_id}
    END
    FOR    ${ue_id}     IN    @{UES_ON_CELL2_A001}
        Trigger UE HO Back from Cell3-1 to Cell2-2    ue_id=${ue_id}
    END

UEs HO Back to Origin Cell
    Trigger UE HO Back from Cell3-1 to Cell2-2    ue_id=3
    Trigger UE HO Back from Cell3-1 to Cell2-1    ue_id=6
    Trigger UE HO Back from Cell3-1 to Cell2-1    ue_id=7

Case Setup For A005
    Delta Commission Parameters    ${Delta_for_A005}
    Wait Until Keyword Succeeds    1min    10s    Object Should Not Exist     MRBTS-1/NRBTS-1/NRCELL-2/NRREL-2:gNbId=35

UE21 UE23 attach to Cell1 and UE22 UE24 attach to Cell2
    UE Register With PDU Session_5QI5    ue_id=21
    UE Register With PDU Session_5QI5    ue_id=22
    UE Register With PDU Session_5QI5    ue_id=24
    UE Register With PDU Session_5QI5_5QI1    ue_id=23

UE21 To UE24 Start And Check Traffic
    UE21 to UE24 Start Traffic
    UE21 to UE24 Check Traffic

UE Register With PDU Session_5QI5
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    pass_regexp=${Setup_5QI5_Success}

UE Register With PDU Session_5QI5_5QI1
    [Arguments]    ${ue_id}=23
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    pass_regexp=${Setup_5QI5_Success}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=${Add_5QI1_Success}

UE21 to UE24 Start Traffic
    [Arguments]    ${ue_id}=1
    Send Throuput    ue_id=21
    Send Throuput    ue_id=22
    Send Throuput    ue_id=24
    Trigger 5QI5 and 5QI1 traffic For UE23

UE21 to UE24 Check Traffic
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    Verify Throughput    ue_id=21
    Verify Throughput    ue_id=22
    Verify Throughput    ue_id=24
    Check 5QI5 and 5QI1 traffic For UE23

Send Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=135    ${Tput_ul}=45    ${sleep_time}=15s
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger 5QI5 and 5QI1 traffic For UE23
    [Arguments]    ${ue_id}=23
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 protocol=tcp seconds=6000
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=2 protocol=tcp seconds=6000
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=dl trf_id=1 rtp_codec=amr_wb_18_25 seconds=6000
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=2 rtp_codec=amr_wb_18_25 seconds=6000

Check 5QI5 and 5QI1 traffic For UE23
    [Arguments]    ${ue_id}=23
    execute egate command     qfi_stats ue=${ue_id} pdu=1 qfi=1 dir=dl    pass_regexp=Parameter
    execute egate command     qfi_stats ue=${ue_id} pdu=1 qfi=1 dir=ul    pass_regexp=Parameter
    execute egate command     qfi_stats ue=${ue_id} pdu=1 qfi=2 dir=dl    pass_regexp=Parameter
    execute egate command     qfi_stats ue=${ue_id} pdu=1 qfi=2 dir=ul    pass_regexp=Parameter

UEs Trigger Inter-gNB Intra-FreqANR HO And Inter-Freq HO
    [Arguments]    ${ue_id1}=1    ${ue_id2}=1
    Trigger Inter-gNB Intra-FreqANR HO Concurrency With PDU Session Mofication    ${ue_id1}
    Trigger Inter-gNB Inter-Freq HO From Cell2-1 to Cell3-1    ${ue_id2}

Trigger Inter-gNB Intra-FreqANR HO Concurrency With PDU Session Mofication
    [Arguments]    ${ue_id}    ${target_cell}=381    ${action}=send_nas_pdu_session_modify
    ${meas_id_A3}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    Set PCI-ANR resolution time delay    ${ue_id}    ${action}
    ${cmd1}=    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=5 srsrq_nr=5
    ${cmd2}=    Set Variable    phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
    ${cmd_HO}=    Catenate    ${cmd1}    ${cmd2}
    Execute Egate Command    ${cmd_HO}    pass_regexp=${pass_regexp_ANR}

Set PCI-ANR resolution time delay
    [Arguments]    ${ue_id}    ${action}=send_nas_pdu_session_modify
    ${cmd_action}=    Catenate    action=${action} pduSessionInfo=1:${ue_id}:1:1:1:0 qosflows_to_add=2
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=100ms ${cmd_action}

Trigger Inter-gNB Inter-Freq HO From Cell2-1 to Cell3-1
    [Arguments]    ${ue}=1    ${qosflows_action}=qosflows_to_add    ${Qos_id}=1    ${pass_regexp}=QoS Routing Table
    BuiltIn.Log    Trigger UE1 A2 Measurement Report
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633216    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    execute_egate_command    ${A2_Event}    rrcReconfigurationComplete    timeout=20s
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633408    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid1} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    execute_egate_command    ${A3_Event}    pass_regexp=@{pass_regexp_HO_CELL2_SIMCELL1}    timeout=20s

Delete Cell2 ANR NRREL
    Wait Until Keyword Succeeds    5min    30s    Object Should Exist     MRBTS-1/NRBTS-1/NRCELL-2/NRREL-256:gNbId=35
    Delta Commission Parameters    ${OnlineParam_for_ANR_Recover}
    Wait Until Keyword Succeeds    3min    10s    Object Should Not Exist     MRBTS-1/NRBTS-1/NRCELL-2/NRREL-256:gNbId=35

UE21 to UE24 HO to origin cells
    Trigger UE HO Back from Cell3-1 to Cell2-1    21
    Trigger UE HO Back from Cell3-1 to Cell2-2    22
    Trigger UE HO Back from Cell3-1 to Cell2-1    23
    Trigger UE HO Back from Cell3-1 to Cell2-2    24
    UE21 to UE24 Check Traffic
