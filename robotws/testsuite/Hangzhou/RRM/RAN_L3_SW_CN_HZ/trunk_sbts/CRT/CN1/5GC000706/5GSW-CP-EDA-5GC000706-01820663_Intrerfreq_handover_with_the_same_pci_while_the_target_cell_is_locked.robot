*** Settings ***
Documentation
...    crt_author: kema
...    contact: kema
...    squad group: CN3SG02
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     CP Common Test Teardown for EDA
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...               owner-selena.ye    release-5G20A    5GC000706    CB012121
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_ENV_SWCONFIG}    classical::::::0x890062=5
@{PARAMS_IN_SCF}
...    @{5GC000706_Base}
...    @{NRCELL}
#...    @{NRADJNRCELL}
...    @{NRHOIF}
...    @{NRADJGNB}
#...    @{NRREL}
...    @{NRDRB}
...    @{DELETE_NRREL}
...    @{ANR}
...    NRCELL:bestCellWaitTimer=200
...    NRBTS:actMeasurementStrategy=cellQuality
...    delete:NRCELL:a2MeasRedirectSsbRsrp
...    delete:NRCELL:a2MeasRedirectSsbRsrq
@{ANR}
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
...    NRBTS/NRANRPR-2:nrarfcn=636666
...    NRBTS/NRANRPR-2:ssbFrequency=636000
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
...    NRBTS/NRANRPR-4:nrarfcn=636666
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

...    NRBTS/NRANRPR-5:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-5:anrThresRsrqNbCell=-48
...    NRBTS/NRANRPR-5:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-5:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-5:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-5:idleTimeForNrNbRemoval=2
...    NRBTS/NRANRPR-5:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-5:nrarfcn=646666
...    NRBTS/NRANRPR-5:ssbFrequency=646656
@{DELETE_NRREL}
...    delete:NRBTS/NRCELL-1/NRREL-1
...    delete:NRBTS/NRCELL-2/NRREL-1
@{5GC000706_Base}
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
#...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.122
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
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms100
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=5
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
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
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=2
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=15
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=636666
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7874

...    MRBTS-1/NRBTS-1/NRCELL-3:a1MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-3:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-3:a2MeashoEnabled=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-3:a2MeashoEnabledSA=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-3:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-3:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=2
...    MRBTS-1/NRBTS-1/NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    MRBTS-1/NRBTS-1/NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    MRBTS-1/NRBTS-1/NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    MRBTS-1/NRBTS-1/NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-3:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    MRBTS-1/NRBTS-1/NRCELL-3:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    MRBTS-1/NRBTS-1/NRCELL-3:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasSsbRsrq:a3OffsetSsbRsrq=15
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
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

@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=636666
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=51
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=635232

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
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=636000
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
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:ssbFrequency=646656
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

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
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrq
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:ssbFrequency=634656
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=30
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=20
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms160
@{NRREL}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=-6dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=-8dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=-6dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=-8dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=-6dB
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=-8dB
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1:gNbId=1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
#...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3


@{org_xnlink_delete}
...    delete:MRBTS-1/NRBTS-1/XNLINK-1
...    delete:MRBTS-1/NRBTS-1/NRADJNRCELL-12288
...    delete:MRBTS-1/NRBTS-1/NRADJGNB-1
#...    delete:MRBTS-1/NRBTS-1/NRADJGNB-2
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-255
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-256
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREL-256
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=636666
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=51
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=635232
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=-6dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=-8dB
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:rsrpOffsetRplCellForPSCell
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:rsrqOffsetRplCellForPSCell
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:sCellOperationalMode
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:sCellAdditionMethod

${UE_CAPA_B_UE1}    SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2
...    403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B133582028680965944C2403D6C10101
...    070EF1C39061C00103278FAB80027800E0009E00151B137582028680965944C2403D6C10101070EF1C3906
...    1C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C00103278F
...    AA8000028000000841C4D000000002026878003804044F613003200281C1401C0C026007000683E0000000
...    000000E54D000100000965950034AAA84801C002C00000010020046AC4C0004080C1014181C202C4044484
...    C648494989CA129C4DA0

@{DELTA_PARAS}
...    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Locked
@{DELTA_PARAS_unlock}
...    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Unlocked
@{PM_Counters_Check_HO}
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLM}==1
...    MRBTS-1/NRBTS-1/NRCELL-2/PLMN-PLMN/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLM}==0
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}==1
...    MRBTS-1/NRBTS-1/NRCELL-2/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}==0
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}==2
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}==2
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}==1
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}==2
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IC_INTER_GNB_HO_SA_PLMN}==2
...    MRBTS-1/NRBTS-1/NRCELL-1:${TOT_INTER_FREQ_HO_DECISION_A3}==4
...    MRBTS-1/NRBTS-1/NRCELL-2:${TOT_INTER_FREQ_HO_DECISION_A3}==1

${ATT_IF_INTRA_DU_HO_SA_PLM}    M55145C00321
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322
${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}    M55145C00323
${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}    M55145C00351
${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}    M55145C00352
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361
${SUCC_IC_INTER_GNB_HO_SA_PLMN}    M55145C00362
${TOT_INTER_FREQ_HO_DECISION_A3}    M55147C00024

*** Test Cases ***
5GSW_CP_EDA_5GC000706_01820663_Intrerfreq_handover_with_the_same_pci_while_the_target_cell_is_locked_with_ANR
    [Documentation]
    ...                                nrarfcn    gscn   ssbFrequency   phycell_id
    ...    GNB-2(id=1)     CELL-1       635614     7860         634656          50
    ...                    CELL-2       636666     7874         636000          51
    ...                    CELL-3       646666     7885         646656          52
    ...    sim-GNB(id=35)  CELL-1       636666     7866         635232          51
    ...    step1: Create L3 call
    ...    step2: Handover from GNB-2 CELL-1(pci 50) to GNB-2 CELL-2(pci 51)-Cell2 cellQuality higher than cell3
    ...    Step3: Handover from GNB-2 CELL-2(pci 51) to GNB-2 CELL-1(pci 50)
    ...    Step4: Handover from GNB-2 CELL-1(pci 50) to GNB-35 CELL-3(pci 51)
    ...    Step5: Handover from GNB-35 CELL-3(pci 51) to GNB-2 CELL-1(pci 50)
    ...    step6: Lock GNB-2 CELL-2(pci 51)
    ...    Step7: Handover failed from GNB-2 cell-1(pci 50) to GNB-2 CELL-2(pci 51)
    ...    Step8: Handover from GNB-2 CELL-1(pci 50) to GNB-35 CELL-1(pci 51)
    ...    Step9: Handover from GNB-35 CELL-1(pci 51) to GNB-2 CELL-1(pci 50)
    ...    Step10: UE Deregister From Cell1
    ...    Step11: Check Counters
    ...    Step12: delete XNLINK
    ...    step13: Create L3 call again
    ...    step14: Trigger A3 from GNB-2 CELL-1(pci 50) to GNB-2 CELL-3(pci 51) for oamcontrol XNlink
    ...    Step15: Handover from GNB-2 CELL-1(pci 50) to GNB-2 CELL-2(pci 51)-Cell2 cellQuality higher than cell3
    ...    Step16: Abort XNLINK
    ...    step17: Wait FID 7311 raised
    ...    step18: after about 20 min 7311 cancle
    ...    note: add EDA 01820663+03955036+5G_CP_ARC_ALG_12345+CB012121 enhancement
    [Tags]    QC_47219
    Clear Counter Files
    Ue Attach To Cell
    Trigger A2 and A3 from CELL-1 to CELL-2 in real GNB and loopback
    Trigger A2 and A3 from CELL-1 of real GNB to CELL-1 of sim-GNB and loopback
    Lock CELL-2
    Trigger A3 from CELL-1 to CELL-2 in real GNB failed
    Trigger A3 from CELL-1 of real GNB to CELL-1 of sim-GNB succeed and loopback
    UE Deregister From Cell1
    UnLock CELL-2
    Check Counters    ${PM_Counters_Check_HO}
    OnlineParamChange    ${org_xnlink_delete}
    Ue regist To Cell
    Trigger A2 and A3 from CELL-1 of real GNB to CELL-1 of sim-GNB and cell-2 of real GNB for oamcontrol XNlink
    Abort xnlink
    Wait Until Keyword Succeeds    130s    20s    Check Fault 7311 Raised    nradjgnb_id=1
    sleep    1100s
    Wait Until Keyword Succeeds    120s    20s    Check Xnlink not exist    xnlink_id=1
    Fm Fault Should Be Cleared    fault_id=7311

*** Keywords ***

Check cleanup previous NRADJGNB and xnlinks
    [Arguments]    ${pre_nradjgnb}=1    ${xnlink_id}=1
    Check Fault 7311 Raised    nradjgnb_id=${pre_nradjgnb}
    Check Xnlink not exist    xnlink_id=${xnlink_id}
Check Fault 7311 Raised
    [Arguments]    ${nradjgnb_id}
    ${fault}  Create List    fault_id=7311    alarm_id=7107    severity=Major
    ...    alarming_object=MRBTS-1/NRBTS-1/NRADJGNB-${nradjgnb_id}
    ...    fault_name=No Xn link available
    Fm Fault Should Be Raised    ${fault}    40
Check Xnlink not exist
    [Arguments]    ${xnlink_id}
    Object Should Not Exist    XNLINK-${xnlink_id}:cPlaneIpAddrCtrl=oamControlled
Abort xnlink
    Execute Egate Command   gnb_param id=3 xn_listening_socket=off
    Execute Egate Command   link_drop link=xn by=gnb:3 to=gnb:2 msg_type=abort

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param}
    BuiltIn.Log    OnlineParamChange to delete org XNLINK
    Delta Commission Parameters     ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

Trigger A2 and A3 from CELL-1 of real GNB to CELL-1 of sim-GNB and cell-2 of real GNB for oamcontrol XNlink
    Trigger UE1 With A2 Measurement Report_634656
    Execute Egate Command    ue_pci_conflict_resolution id=1 nb_id=3
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 for oamcontrol XNlink
    Run Keyword And Ignore Error    Trigger UE1 With A2 Measurement Report_634656
    Execute Egate Command    ue_pci_conflict_resolution id=1 nb_id=2
    UE1 Tirgger Inter-Frequency Intra-DU HO To Cell2 cellQuality higher than cell3 with A3

UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3 for oamcontrol XNlink
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Inter-gnb HO To Cell3...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=635232    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp

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
    ...    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7874 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell2}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false sib1_period=160ms
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=17:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7866 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_cell_param id=1 gnb=3 enable_drx_profile_for_anr=on
	${set_gnb4}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.124 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.125 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb4}
    Update Cfg    gnb_param id=4 xn_listening_socket=on send_xn_setup=on sib1_period=160ms
    ${set_gnb4_cell1}    catenate    set_cell id=1 gnb=4 pci=18:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9998 nr_arfcn=636666:636666
    ...    gscn=7866 mandatory_for_activation=off
    Update Cfg    ${set_gnb4_cell1}
    Update Cfg    gnb_cell_param id=1 gnb=4 enable_drx_profile_for_anr=off

Trigger A3 from CELL-1 to CELL-2 in real GNB failed
    Trigger UE1 With A2 Measurement Report_634656
    Execute Egate Command    ue_pci_conflict_resolution id=1 nb_id=2
    UE1 Inter-Frequency Intra-DU HO To Cell2 with A3 should be failed

Trigger A3 from CELL-1 of real GNB to CELL-1 of sim-GNB succeed and loopback
    Execute Egate Command    ue_pci_conflict_resolution id=1 nb_id=3
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3
    Trigger UE1 With A2 Measurement Report_635232
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell1 with A3

Ue Attach To Cell
    Setup Xn Link To gNB3
    Add UE History Information List
    Attach UE for waiting L3 call OK

Ue regist To Cell
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3
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

Trigger A2 and A3 from CELL-1 to CELL-2 in real GNB and loopback
    Trigger UE1 With A2 Measurement Report_634656
    Execute Egate Command    ue_pci_conflict_resolution id=1 nb_id=2
    UE1 Tirgger Inter-Frequency Intra-DU HO To Cell2 cellQuality higher than cell3 with A3
    Trigger UE1 With A2 Measurement Report_636000
    UE1 Tirgger Inter-Frequency Intra-DU HO To Cell1 with A3
    Traffic Should Be Correct

Trigger A2 and A3 from CELL-1 of real GNB to CELL-1 of sim-GNB and loopback
    Trigger UE1 With A2 Measurement Report_634656
    Execute Egate Command    ue_pci_conflict_resolution id=1 nb_id=3
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3
    Trigger UE1 With A2 Measurement Report_635232
    UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell1 with A3
    Traffic Should Be Correct

UE1 Inter-Frequency Intra-DU HO To Cell2 with A3 should be failed
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Intra-DU HO To Cell1...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=636000    event_type=A3
    sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    fail_regexp=handover
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp

UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell3 with A3
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Inter-gnb HO To Cell3...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=635232    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}     pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp

UE1 Tirgger Inter-Frequency Inter-gnb HO To Cell1 with A3
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Inter-gnb HO To Cell1...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=634656    event_type=A3
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1
    sleep    2s  #Wait HO finished
    Execute Egate Command    ue_disp

UE1 Tirgger Inter-Frequency Intra-DU HO To Cell2 cellQuality higher than cell3 with A3
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Intra-DU HO To Cell2...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=636000    event_type=A3
    sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=646656    event_type=A3
    sleep    2s
    ${cmd}    catenate    ue_schedule_measurement_send_nr id=1 action=SEND_IMMEDIATELY
    ...    meas_id=${mea_id1} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=30 nrsrq_nr=30
    ...    meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=handover
    sleep    2s
    Execute Egate Command    ue_disp
    ${cmd}    catenate    ue_schedule_measurement_send_nr id=1 action=RESET
    Execute Egate Command    ${cmd}
    sleep    2s

UE1 Tirgger Inter-Frequency Intra-DU HO To Cell1 with A3
    BuiltIn.Log    UE1 Tirgger Intra-Frequency Intra-DU HO To Cell1...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=634656    event_type=A3
    sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Intra-eNB handover
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

Lock CELL-2
    Delta Commission Parameters    ${DELTA_PARAS}

UnLock CELL-2
    Delta Commission Parameters    ${DELTA_PARAS_unlock}

Setup Xn Link To gNB3
    BuiltIn.Log    Setup Xn Link Between gNB3 and gNB2...    console=${True}
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2
