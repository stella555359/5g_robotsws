*** Settings ***
Documentation
...    crt_author: kema
...    contact: kema
...    squad group: VRF3SG07
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     CP Common Test Teardown for EDA
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO    team-SG7
...               owner-keyun.ma    04375589    5GC000706    PR806727
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${EMIL_FLAG}    ${True}
@{PARAMS_IN_ENV_SWCONFIG}
...    classical::::::0x890062=5
...    classical::::::0x890003=0
...    classical::::::0x890005=0
@{PARAMS_IN_SCF}
...    @{5GC000706_Base}
...    @{NRCELL}
...    @{NRHOIF}
...    @{NRDRB}
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=10
@{ANR_DELETE_NRREL}
...    @{ANR}
...    @{DELETE_NRREL}
@{ANR}
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    NRCELL:actCDrx=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRDRX-3:drxInactivityTimer=80ms
...    NRDRX-3:drxLongCycle=320ms
...    NRDRX-3:drxOnDurationTimer=20ms
...    NRDRX-3:drxRetransTimerDl=0slot
...    NRDRX-3:drxRetransTimerUl=0slot
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
...    NRBTS/NRANRPR-2:idleTimeForNrNbRemoval=2
...    NRBTS/NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-2:nrarfcn=636306
...    NRBTS/NRANRPR-2:ssbFrequency=635904
...    NRBTS/NRANRPR-1:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-1:anrThresRsrqNbCell=-48
...    NRBTS/NRANRPR-1:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-1:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-1:idleTimeForNrNbRemoval=2
...    NRBTS/NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-1:nrarfcn=635614
...    NRBTS/NRANRPR-4:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-4:anrThresRsrqNbCell=-48
...    NRBTS/NRANRPR-4:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-4:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-4:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-4:idleTimeForNrNbRemoval=2
...    NRBTS/NRANRPR-4:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-4:nrarfcn=636306
...    NRBTS/NRANRPR-4:ssbFrequency=635232

...    NRBTS/NRANRPR-3:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-3:anrThresRsrqNbCell=-48
...    NRBTS/NRANRPR-3:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-3:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-3:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-3:idleTimeForNrNbRemoval=2
...    NRBTS/NRANRPR-3:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-3:nrarfcn=635614
...    NRBTS/NRANRPR-3:ssbFrequency=634656
@{DELETE_NRREL}
...    delete:NRBTS/NRCELL-1/NRREL-1
...    delete:NRBTS/NRCELL-2/NRREL-1
@{5GC000706_Base}
...    NRCELL-2:administrativeState=Locked
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea1_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea2_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia0=0
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia1_128=0
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia2_128=9
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia3_128=0
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true

...    MRBTS-1/NRBTS-1:actInterRatHoSA=false
...    MRBTS-1/NRBTS-1:actInterRatHoSADlDataForward=false
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=false
...    MRBTS-1/NRBTS-1:gNbCuType=SA+NSA
...    MRBTS-1/MNL-1/MNLENT-1/SYNC-1/CLOCK-1:outputConfiguration1Pps=EnabledWithBtsInputReference
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250
@{NRCELL}
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabled=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=635614
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7860
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-1:mgta=ms0dot5
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-1:gapOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:ifhoSsbSmtcOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:reportIntervalSA=ms120
...    MRBTS-1/NRBTS-1/NRCELL-1:reportOnLeave=false
...    MRBTS-1/NRBTS-1/NRCELL-1:reportAmountSA=r4
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms100
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=15
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40

...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoEnabled=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoEnabledSA=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-2:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=36
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=35
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=36
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=35
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=15
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=636306
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7874

@{NRDRB}
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:dlDataSplitGainThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:dlPreferredPath=F1-U
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:nsa3xBearerAllowed=false
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:prioritizeX2Period=500
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:ulDataPath=ulOverNr
...    MRBTS-1/NRBTS-1/NRDRB-1:nsaDrbParam:ulDataSplitThreshold=infinity

...    MRBTS-1/NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    MRBTS-1/NRBTS-1/NRDRB-15:dscp=46
...    MRBTS-1/NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    MRBTS-1/NRBTS-1/NRDRB-15:numSduDiscard=1
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    MRBTS-1/NRBTS-1/NRDRB-15:resType=GBR
...    MRBTS-1/NRBTS-1/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    MRBTS-1/NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    MRBTS-1/NRBTS-1/NRDRB-15:schedulWeight=1
...    MRBTS-1/NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    MRBTS-1/NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    MRBTS-1/NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    MRBTS-1/NRBTS-1/NRDRB-15:l2OHFactorUl=35
...    MRBTS-1/NRBTS-1/NRDRB-15:l2OHFactorDl=35
...    MRBTS-1/NRBTS-1/NRDRB-15:discardTimer=50ms
...    MRBTS-1/NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    MRBTS-1/NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    MRBTS-1/NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    MRBTS-1/NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:lcgid=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:schedulPrio=5
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    MRBTS-1/NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    MRBTS-1/NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false


@{NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=635904
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=12
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:ssbFrequency=635232
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrq
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=634656
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=30
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=20
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms160

@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Locked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=2
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrCABMCCP=disabled
...    NRBTS:maxNumXnSetupRetry=5
...    MRBTS-1/NRBTS-1/XNLINK-2:cPlaneIpAddr=10.0.1.142
@{NRADJGNB_UNLOCK}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
@{xnlink}
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.122

${UE_CAPA_B_UE1}    SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2
...    403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B133582028680965944C2403D6C10101
...    070EF1C39061C00103278FAB80027800E0009E00151B137582028680965944C2403D6C10101070EF1C3906
...    1C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C00103278F
...    AA8000028000000841C4D000000002026878003804044F613003200281C1401C0C026007000683E0000000
...    000000E54D000100000965950034AAA84801C002C00000010020046AC4C0004080C1014181C202C4044484
...    C648494989CA129C4DA0


@{PM_Counters_Check_HO}
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${NRRCC_RRC_STPSUCC_TOT_PLMN}==1
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${NG_UE_CTXT_STP_REQ_REC_PLMN}==1
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_NGBR_DRB_SETUP_SA_PLMN}==1
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_SETUP_USER_SA_PLMN}>=1
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${RA_UE_SA_PLMN}>=1
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLM}==0
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}==0
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}==2
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}==2
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}==0
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}==2
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IC_INTER_GNB_HO_SA_PLMN}==2
...    MRBTS-1/NRBTS-1/NRCELL-1:${TOT_INTER_FREQ_HO_DECISION_A3}==2

${ATT_IF_INTRA_DU_HO_SA_PLM}    M55145C00321
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322
${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}    M55145C00323
${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}    M55145C00351
${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}    M55145C00352
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361
${SUCC_IC_INTER_GNB_HO_SA_PLMN}    M55145C00362
${TOT_INTER_FREQ_HO_DECISION_A3}    M55147C00024
${SUCC_NGBR_DRB_SETUP_SA_PLMN}    M55145C00220
${SUCC_SETUP_USER_SA_PLMN}    M55145C00223
${RA_UE_SA_PLMN}    M55145C00501
${NRRCC_RRC_STPSUCC_TOT_PLMN}    M55145C04027
${NG_UE_CTXT_STP_REQ_REC_PLMN}    M55145C04029




*** Test Cases ***
5GSW_CP_EDA_04375589_PR806727_Intrerfreq_handover_with_ANR_when_sctp_down
    [Documentation]
    ...                                nrarfcn    gscn   ssbFrequency   phycell_id
    ...    GNB-2(id=1)     CELL-1       635614     7860         634656          50
    ...                    CELL-2       636306     7874         635904          51
    ...    sim-GNB(id=35)  CELL-1       636306     7866         635232          52
    ...    step1:set xn setup response delay
    ...    step2:online modify to add xnlink
    ...    Step3:set sctp down while sctpWaitTimeInitSeqRetry=10
    ...    Step4:online modify to add ANR parsamters
    ...    Step5:Create L3 call
    ...    Step6:Handover from GNB-2 CELL-1(pci 50) to GNB-35 CELL-1(pci 52) failed
    ...    Step7:Set sctp up
    ...    Step8:Handover from GNB-2 CELL-1(pci 50) to GNB-35 CELL-1(pci 52) succeed
    ...    Step9:Handover from GNB-35 CELL-1(pci 52) to GNB-2 CELL-1(pci 50)succeed
    ...    step10:set xnlink abort
    ...    step11:online modify NRADJGNB xnLinkRef to 2 for making xnLinkStatus of NRADJGNB.xnLinkRef is not set to 'available'
    ...    step12:Check Fault 7307 Raised
    ...    step13:set xn_listening_socket enabled
    ...    step14:Handover from GNB-2 CELL-1(pci 50) to GNB-35 CELL-1(pci 52) succeed
    ...    step15:Handover from GNB-35 CELL-1(pci 52) to GNB-2 CELL-1(pci 50)succeed
    ...    step16:Check counters
    ...    note: sctpWaitTimeInitSeqRetry=10
    [Tags]    QC_XXXXX
    Clear Counter Files
    BuiltIn.Log    case start...     console=${True}
    Execute Egate Command    gnb_xn_setup_param id=3 action=delayed_rsp time_to_wait=v60s
    Delta Commission Parameters    ${xnlink}
    sleep    2s
    Set sctp down
    sleep    300s
    Delta Commission Parameters    ${ANR_DELETE_NRREL}
    Ue Attach To Cell
    Trigger A2 and A3 from CELL-1 of real GNB to CELL-3 of sim-GNB failed
    Set sctp up
    Sleep    60s
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 by ANR
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell1 with A3
    Set gNB3 simulator with xnlink abort
    Delta Commission Parameters    ${NRADJGNB}
    Delta Commission Parameters    ${NRADJGNB_UNLOCK}
    Wait Until Keyword Succeeds    330s    5s    Check Fault 7307 Raised    nradjgnb_id=1
    Set xn_listening_socket enabled
    sleep    15s
    Trigger UE1 With A2 Measurement Report_634656
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell1 with A3
    Wait Until Keyword Succeeds    10s    2s    Traffic Should Be Correct
    Check Counters    ${PM_Counters_Check_HO}
*** Keywords ***
Check Fault 7307 Raised
    [Arguments]    ${nradjgnb_id}
    ${fault}  Create List    fault_id=7307    alarm_id=7107    severity=Major
    ...    alarming_object=MRBTS-1/NRBTS-1/NRADJGNB-${nradjgnb_id}
    ...    fault_name=Xn SCTP setup fail
    Fm Fault Should Be Raised    ${fault}    40
Set gNB3 simulator with xnlink abort
    BuiltIn.Log    Set gNB3 simulator with xnlink abort...     console=${True}
   # Execute Egate Command    gnb_xn_setup_param id=3 action=force_failure nth=1 ntimes=32 cause=cell_not_available
    Execute Egate Command    link_drop link=xn by=gnb:3 to=gnb:2 msg_type=abort
    Execute Egate Command    gnb_param id=3 xn_listening_socket=0 send_xn_setup=false measEvent=A3
Set xn_listening_socket enabled
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=3 reset
    Execute Egate Command    gnb_xn_setup_param id=3 reset
UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=635232    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp
UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 by ANR
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Inter-gnb HO To Cell3...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=635232    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=XnAP Link with GNB-2
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=635232    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp

Set sctp down
    BuiltIn.Log    Set xnlink abort...     console=${True}
    Execute Egate Command    gnb_param id=3 xn_listening_socket=0 send_xn_setup=false measEvent=A3
    Execute Egate Command    link_drop link=xn by=gnb:3 to=gnb:2 msg_type=abort
Set sctp up
    BuiltIn.Log    sctp setup
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=3 reset
    Execute Egate Command    gnb_xn_setup_param id=3 reset
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param}
    BuiltIn.Log    OnlineParamChange to delete org XNLINK
    Delta Commission Parameters     ${Online_Param}
    Cells Should Be Onair    check_sib=${True}
Modify Cfg
    ${V_2}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    eia=null+snow3g+aes eea=null nia=null+snow3g+zuc+aes nea=null+zuc+snow3g sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${V_2}
    ${V_1}    catenate
    ...    ue_param id=1 ue_nr_capabilities=${UE_CAPA_B_UE1}
    Update Cfg    ${V_1}
    ${set_gnb2}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${set_gnb2}
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=635614:635614 gscn=7860 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    ${set_gnb2_cell2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636306:636306 gscn=7874 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell2}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false sib1_period=160ms
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636306:636306
    ...    gscn=7866 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_cell_param id=1 gnb=3 enable_drx_profile_for_anr=on
	${set_gnb4}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.124 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.125 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb4}
    Update Cfg    gnb_param id=4 xn_listening_socket=on send_xn_setup=on sib1_period=160ms
    ${set_gnb4_cell1}    catenate    set_cell id=1 gnb=4 pci=18:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9998 nr_arfcn=636306:636306
    ...    gscn=7866 mandatory_for_activation=off
    Update Cfg    ${set_gnb4_cell1}
    Update Cfg    gnb_cell_param id=1 gnb=4 enable_drx_profile_for_anr=off
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false measEvent=A3

Ue Attach To Cell
    Add UE History Information List
    Attach UE for waiting L3 call OK

UE Deregister From Cell1
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE1: detached

Traffic Should Be Correct
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=2    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>4.0
    Should Be True    ${ul_throughput}/1000>4.0

Attach UE for waiting L3 call OK
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=1    Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
    Execute Egate Command    trf_data_start ue=1 pdu=2 qfi=1 dir=dl mbps=5 trf_id=1    UDP DL TRF
    Execute Egate Command    trf_data_start ue=1 pdu=2 qfi=1 dir=ul mbps=5 trf_id=1    UDP UL TRF

Add UE History Information List
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=96
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=1 ue_history_list=1

Trigger A2 and A3 from CELL-1 of real GNB to CELL-3 of sim-GNB failed
    Trigger UE1 With A2 Measurement Report_634656
    Execute Egate Command    ue_pci_conflict_resolution id=1 nb_id=3
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 for xnlink
    Trigger UE1 With A2 Measurement Report_634656
    Execute Egate Command    ue_pci_conflict_resolution id=1 nb_id=3
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 failed with sctp down
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 failed with ANR LOCK


UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 failed with sctp down
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Inter-gnb HO To Cell3 failed with sctp down...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=635232    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    fail_regexp=handover
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp

UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 failed with ANR LOCK
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Inter-gnb HO To Cell3 failed with ANR LOCK...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=635232    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    fail_regexp=handover
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp


UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 for xnlink
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Inter-gnb HO To Cell3...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=635232    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}     pass_regexp=rrcReconfigurationComplete
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp

UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell1 with A3
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Inter-gnb HO To Cell1...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=634656    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp

CP Common Test Teardown for EDA
    Common Test Teardown And Stop Capture Logs

Trigger UE1 With A2 Measurement Report_${carrierfreq}
    BuiltIn.Log    UE1 The second A2 Measurement Report...    console=${True}
    sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    Execute Egate Command    ${cmd}    rrcReconfiguration    timeout=20s
    Should Contain    ${ret1}=    gapUE setup

