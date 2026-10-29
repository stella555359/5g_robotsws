*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-xiaowen.xu
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:gnbOvlProtMode=classical
...    NRBTS-1:cuOvlHa:ovlSaA4TimerDiscard=enabled
...    NRBTS-1:cuOvlHa:ovlSaMeasDiscard=enabled
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{A4_Config}
...    @{ANR_IRAT_config}

@{ANR_IRAT_config}
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:actSaUeBasedAnrEutra=true
...    NRBTS-1:maxNumNrAnrMoiAllowed=10

...    MRBTS-1/NRBTS-1/NRANR-1:actAutoEutraNbRemoval=false
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoNrNbRemoval=false
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThres=3
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThresEutra=3
...    MRBTS-1/NRBTS-1/NRANRPRE-1:anrThresRsrpEutraNbCell=-100
...    MRBTS-1/NRBTS-1/NRANRPRE-1:anrThresRsrqEutraNbCell=-24
...    MRBTS-1/NRBTS-1/NRANRPRE-1:anrThresholdSelectorEutra=RSRP
...    MRBTS-1/NRBTS-1/NRANRPRE-1:consecRecheckForEutraNbRemoval=5
...    MRBTS-1/NRBTS-1/NRANRPRE-1:idleTimeForEutraNbRemoval=72
...    MRBTS-1/NRBTS-1/NRANRPRE-1:maxNumAnrNrrelePerCell=50
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80
...    NRCELL-11:actCDrx=true
...    NRCELL-11:drxProfileNrAnr:drxControl=interRATeUTRA

...    NRCELL-11:dtxOptimizedScheduler:dtxDelaySinceLastScheduling=0
...    NRCELL-11:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-11:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-11:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRHOIR-1:earfcnValue=1400
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
@{A4_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=6
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=8
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-13:a4PeriodicMeasControlSA:a4RetryTimer=9
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-14:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-11:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-12:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-12:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-13:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-13:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-14:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-14:a4PeriodicMeasControlNSA:a4RetryTimer=20

...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=2000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=20
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=633216
...    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-11/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-11/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-2:ssbFrequency=126750
...    NRCELL-11/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-2:a4PriorityForHigherPrioFreqHo=2

@{OnlineParam_for_C020}
...    NRBTS-1:actInterRatHoSA=false
...    NRBTS-1:actSaUeBasedAnrEutra=false
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=1000
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=0
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=40
...    NRBTS-1/NRCELL-11/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-11/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-11/NRREL-1:lcrId=2
...    NRBTS-1/NRCELL-11/NRREL-1:removeNotAllowed=false
...    delete:NRBTS-1/NRCELL-11/NRREL-1:sCellAdditionMethod

@{OnlineParam_for_C020_Recover}
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:actSaUeBasedAnrEutra=true
...    delete:NRBTS-1/NRCELL-11/NRREL-1
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=2000
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=20

@{OnlineParam_for_C031}
...    NRBTS-1:timerHOGuard=6000
...    NRBTS-1:actSaUeBasedAnrEutra=false
...    NRCELL-2:actCDrx=true
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=424090
...    NRCELL-2/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=2
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=2
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=40
...    NRBTS-1/NRCELL-2/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-2/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-2/NRREL-1:lcrId=11
...    NRBTS-1/NRCELL-2/NRREL-1:removeNotAllowed=false
...    delete:NRBTS-1/NRCELL-2/NRREL-1:sCellAdditionMethod

@{OnlineParam_C031_recovery}
...    NRBTS-1:actSaUeBasedAnrEutra=true
...    NRBTS-1:actInterRatHoSA=true
...    NRCELL-2:actCDrx=false
...    NRCELL-2:a1MeashoEnabledSA=none
...    NRCELL-2:a2MeashoEnabledSA=none
...    delete:NRCELL-2/NRHOIF-1
...    delete:NRBTS-1/NRCELL-2/NRREL-1

@{OnlineParam_for_C028}
...    NRBTS-1:timerHOGuard=6000
...    NRBTS-1:timerRRCGuard=2500
...    NRBTS-1/NRCELL-12:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000
...    NRBTS-1/NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRBTS-1/NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=50
...    NRBTS-1/NRCELL-12/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-12/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-12/NRREL-1:lcrId=14
...    NRBTS-1/NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=633216
...    NRCELL-12/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1

@{OnlineParam_C028_recover}
...    delete:NRBTS-1/NRCELL-12/NRREL-1
...    delete:NRBTS-1/NRCELL-12/NRHOIF-1

@{RedirRat}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirFreqNr=633216
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrio=1
...    NRCELL-1:a2MeasRedirectEnabled=rsrp
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:actRedirect=true
...    NRCELL-1:a1MeashoEnabledSA=none
...    NRCELL-1:a2MeashoEnabledSA=none

@{OnlineParam_C047}
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=5000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=1
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=15
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=633216
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=126750
...    NRCELL-1/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=424090
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrqCombined
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=2
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=none
...    NRBTS-1/NRCELL-1/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-1/NRREL-1:lcrId=12
...    NRBTS-1/NRCELL-1/NRREL-1:removeNotAllowed=false
...    delete:NRBTS-1/NRCELL-1/NRREL-1:sCellAdditionMethod
...    @{RedirRat}

@{OnlineParam_C047_recover}
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-2:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=none
...    NRBTS-1:actRedirect=false

@{OnlineParam_C045}
...    NRBTS-1:actIdlMMEnDcSteering=true
...    NRBTS-1:drbInactivityTimerSA=7
...    NRBTS-1:srbInactivityTimerSA=7
...    NRBTS-1:tWaitingRlRecover=60000ms
...    NRBTS-1:timerHOGuard=6000
...    NRSYSINFO_PROFILE-2/NRLIM-1:cellReselectionPriority=6
...    NRSYSINFO_PROFILE-2/NRLIM-1:carrierFreq=300
...    NRSYSINFO_PROFILE-2/NRLIM-1:cellReselectionPriority=6
...    NRSYSINFO_PROFILE-2/NRLIM-1:idleMMEutraCelResWeightEnDc=25
...    NRSYSINFO_PROFILE-2/NRIRFIM-1:cellReselectionPriority=7
...    NRSYSINFO_PROFILE-2/NRIRFIM-1:dlCarrierFreq=147500
...    NRSYSINFO_PROFILE-2/NRIRFIM-1:freqBandIndicatorNR=12
...    NRSYSINFO_PROFILE-2/NRIRFIM-1:ssbScs=30 KHz
...    NRCELL-11:idleMMEnDcSteeringPercentageOfUes=100
...    NRCELL-11:idleMMEnDcSteeringSsbFrequency=2079167
...    NRCELL-11:idleMMEnDcSteeringWRREnabled=true
...    NRCELL-11:a4ReportTimerEnDc=6000
...    NRCELL-11:t320EnDc=min10
...    NRCELL-11:cellReselectionPriority=5
...    NRCELL-11/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-3:deriveSsbIndexFromCell=true
...    NRCELL-11/NRHOIF-3:freqBandIndicatorNR=257
...    NRCELL-11/NRHOIF-3:ifhoSsbScs=120 KHz
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-11/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-3:ssbFrequency=2079167
...    NRCELL-11/NRHOIF-3:a4MeasEnDcSteeringEnabled=rsrp
...    NRCELL-11/NRHOIF-3:a4MeasEnDcSteeringSsbRsrp:a4HysteresisEnDcSteeringSsbRsrp=4
...    NRCELL-11/NRHOIF-3:a4MeasEnDcSteeringSsbRsrp:a4ThresholdEnDcSteeringSsbRsrp=29
...    NRCELL-11/NRHOIF-3:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms40
...    NRCELL-11/NRHOIF-3:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-11/NRHOIF-5:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-5:freqBandIndicatorNR=66
...    NRCELL-11/NRHOIF-5:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-5:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-11/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-5:ssbFrequency=428210
...    NRCELL-11/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-11/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=23
...    NRCELL-11/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-5:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=1
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=1
...    NRCELL-11:a2MeashoEnabledSA=none
...    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-11/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRCELL-11/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-11/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-11/NRREL-1:lcrId=12
...    NRBTS-1/NRCELL-11/NRREL-1:removeNotAllowed=false

@{OnlineParam_C045_recover}
...    delete:NRBTS-1/NRCELL-11/NRREL-1
...    delete:NRBTS-1/NRCELL-11/NRHOIF-3
...    delete:NRBTS-1/NRCELL-11/NRHOIF-4
...    delete:NRBTS-1/NRCELL-11/NRHOIF-5
...    NRBTS-1:actIdlMMEnDcSteering=false
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=2000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=20
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrq

${ue_nr_Capa_support_A4_for_immediateENDC}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F
...    11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC0
...    9F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F
...    28581C0E1E13FFE00000FFF80000088000E0000040041E1E26800710400000858081507850001C46000002160561E2300071040000185815
...    87850001C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000
...    002058158B89A001C46000E230000020B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D000E208007118000
...    01058158B850001C46000E230000020B02B1713400388C001C28000008160561E230007118000018581083A0000001C02404680510136020
...    C1000D418A10851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F02240810
...    3639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF810206C73E0003220318C6318C6318C
...    6318C603D04C00F000A070500703009401C0018090010180F824008000000040000080200000001000002008000020040000180200001001
...    00000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C03395359
...    53582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A594901000039652404000125949010000
...    596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552
...    A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28480BC04A8140A05028140A05028140A05028140A05028140A000E10100C01
...    8040080108080100402018030804008010100C018040300608080600C02018030804008010100C018040080110080600C02018030080600C
...    10100200804008020008010023543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${ue_eutra_nr_Capa_support_A4_for_immediateENDC}    SEPARATOR=
...    110C080160023D0004100000C4000000000204E003580010200806004008180100200804

${ue_id}    81
${cell_id}    11
${pdu_id}    1

*** Test Cases ***
CB007517-ET-C025_A4_not_configured_after_non-first_retryTimer_expire_with_IRAT_EUTRACGI_Report_configured
    [Documentation]
    ...    1. This user scenario porpuse is to check the gNB behaviour for a UE on a SA call
    ...    when system receiving IRAT EUTRACGI Report after non-first 'a4RetryTimer' expire , A4 should not configured.
	...    2. Configuration
	...       configuration on BTS
	...           CA was not enabled
	...           ANR inter-RAT feature is enabled
	...       configuration on cell 11
	...           NRHOIF have cell 2 and cell 12
	...           NO CA releations , and CA was not enabled
	...           DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11. A2 should be configured
    ...         b. waiting for fisrt a4RetryTimer expire, and A4 allocated to UE than removed .
	...         c. Trigger A2 MR in cell11 .
    ...         d. After non fisrt a4RetryTimer expire , B2 was already configured , and no A4 allocated to UE .
    ...         e. UE deregister should be successfully.
	[Tags]    QC_198816    owner-xiaowen.xu    C025
	Start To Capture Wireshark Log    C025_ICS
    UE_register_and_ICS_w_pdu
    Check_A4_Cconfigured
    stop capture wireshark log    C025_ICS
    Trigger_A2_MR_after_first_a4_deconfigured
    Trigger_A1_MR_to_reconfigure_A4
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C025${/}ANR_IRAT_Eutra_report.ini    wait_string=UEContextReleaseComplete::4

CB007517-ET-C020_Inter-freq_HO_not_execute_when_overload_detected_HO_succeed_when_no_overload
    [Documentation]
    ...    1. This test case merged the checkpoint for C020, C024 and C040.
	...         a. C020: This user scenario describes that overload protection check has failed then
    ...            received A4 measurement report should be discarded.
	...         b. C024: The purpose of this test case is to check the gNB behaviour for a UE on a SA call when system overload
	...            after the first a4RetryTimer expires.
	...         c. C040: The purpose of this test case is to check the gNB behaviour for a UE on a SA call when system overload
    ...            after the a4SupervisionTimer expires.
    ...    2. Configuration
    ...         a.configuration on NRBTS
    ...           ovl is enabled
    ...         b.configuration on cell 11
    ...           Measurement: inter A4
	...           DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11.
    ...         b. Set CP-UE in overload state before 1st retrytimer expired, A4 not configured, retrytimer is restart.
    ...         c. Remove overload, A4 can be configured when 2nd retrytimer expired.
    ...         d. Set CP-UE in overload state, then send A4 MR.this A4 MR will be discarded.
	...         e. Remove overload, A4 configued after 3th retrytimer expired, trigger overload, A4 should not be deconfig.
    ...         e. Cancel overload state for CP-UE, then send A4 MR. HO will be successful.
    ...         f. Verify TPUT on target cell.
    ...         g. UE deregister should be successfully.
    [Tags]    QC_198814    owner-jing.ye    C020
    OnlineParamChange    ${OnlineParam_for_C020}
	Get OvlThreshold Prerequisite
	A4 Should Not Be Configured If Overload And Configured After Cancel Overload
	Measurement Report Should Be Discarded If Overload
	A4 Deconfig Should Not Happen If Overload
	Trigger A4 Measurement Report And HO Successfully    phycell_id=51    carrierfreq=633216    event_type=A4
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C020${/}a2a.ini     wait_string=UEContextReleaseComplete::4
	[Teardown]    C020 TestTeardown

CB007517-ET-C031_A4_not_config_after_first_retryTimer_expire_with_Inter-freq_A3_deconfig_ongoing
    [Documentation]
	...   1.The purpose of this test case is to check the gNB behaviour for a UE on a SA call
	...    when the a4RetryTimer expires.
	...   2.Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. trigger A2 MR for HO,and gap setup
	...         c. delay next rrc and trigger A1MR to deconfig A3 emasurement, the deconfigure will cost 5s, so when
	...            retryTimer timeout, the StartA4BasedMobilityA4Configuration
	...         d. check on wirshark, the 7517 A4 configured after deconfig A3 emasurement finished.and after
	...            A4supervison timer expire, the A4 deconfigured.
    ...    3. Expected Results:
    ...         Step a: call setup successfully and start first retryTimer (40s).
    ...                 IE: on wireshark log:
    ...                 drx-Config = 1
    ...         Step b: UE send A2 MR, drx release, gapue setup, eventA1 eventA3 configure
    ...                 IE: on wireshark log:
    ...                 measIdToAddModList = 1
    ...                 eventId == 0 for eventA1, eventId = 2 for eventA3
    ...                 drx-Config = 0
    ...                 gapUE = 1
    ...         Step c: UE send A1 MR, gap release, eventA2 configured, then drx setup
    ...                 IE: on wireshark log:
    ...                 eventId = 1 for eventA2
    ...                 gapUE = 0
    ...                 drx-Config = 1
    ...         Step d-1: 7517 A4 configured after deconfig A3 emasurement finished.
    ...                 IE: on wireshark log:
    ...                 measIdToAddModList = 1
    ...                 eventId == 3 for eventA4
    ...                 drx-Config = 0
    ...                 gapUE = 1
    ...         Step d-2&3: 7517 A4 deconfigured after A4supervision timer expire. gap release, then drx setup
    ...                 IE: on wireshark log:
    ...                 gapUE = 0
    ...                 drx-Config = 1
	[Tags]    C031    owner-dandan.chen    QC_191112
    OnlineParamChange    ${OnlineParam_For_C031}
	Clear Counter Files
    A4 not configured after first retryTimer expire when interfreqA3MR deconfig ongoing
	UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C031${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    C031 TestTeardown

CB007517-ET-C028_A4_not_configured_after_first_retryTimer_expire_when_Intra_DU_Intra-freq_HO_ongoing
    [Documentation]
    ...    1. This user scenario porpuse is to check the gNB behaviour for a UE on a SA call when  intra DU intra-freq
    ...       HO ongoing after the first a4RetryTimer expire.
	...    2. Configuration
	...       configuration on BTS
	...           CA was not enabled
	...       configuration on cell 12
	...           NRRREL is cell 14
	...           NO CA releations , and CA was not enabled
	...           DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11. A2 should be configured
    ...         b. waiting for fisrt a4RetryTimer expire, and A4 allocated to UE than removed .
	...         c. trigger A3 measurement report.
	...         d. set RRC Reconfig timer to delay RRC Reconfiguration Procedure in the first 5s during first retryTimer(10s).
    ...         d. After non fisrt a4RetryTimer expire , no A4 allocated to UE .
    ...         e. UE deregister should be successfully.
	[Tags]    QC_191111    owner-lingyan.zhou    C028
	OnlineParamChange    ${OnlineParam_For_C028}
	SA UE attach
	Verify Throuput
	Trigger A3 MR and HO with 5s delay for RRCreconfigcomplete
	UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C028${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    Restore scf to remove C028 delta

CB007517-ET-C047_A4HO_not_executed_after_receive_InterFre_A4MR_and_then_receive_A2_redirect_execute_A2_redirect_success
    [Documentation]
	...   1.The purpose of this test case is to check the gNB behaviour for a UE on a SA call
	...   when the a4RetryTimer expires.
	...   2.Test Case Steps:
    ...   3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11. A2 should be configured.
    ...         b. waiting for fisrt a4RetryTimer expire, and A4 allocated to UE .
	...         c. trigger A4 measurement report with non highest proity.
	...         d. before a4SupervisionTimer expire , trigger A2 MR .
    ...         d. ue release with redirect , no A4HO triggered.
    ...         e. UE deregister should be successfully.

	[Tags]    C047    owner-xiaowen.xu    QC_191113
    OnlineParamChange    ${OnlineParam_C047}
    SA UE attach    ue_id=82    target_cells=1
    Verify Throuput    ue_id=82
    UE Send Redirection A2 report      ue_id=82
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C047${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    C047_Teardown

CB007517-ET-C045_HO_not_executed_and_A4_deconfigured_after_receiving_Inter-freq_A4_MR_and_then_Inter-freq_A4_for_immediate_ENDC_configured
    [Documentation]
	...   1.The purpose of this test case is to check the gNB behaviour for a UE on a SA call
	...   when receiving A4 for immediateENDC.
	...   2.Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11.
    ...         b. waiting for fisrt a4RetryTimer expire, and A4 allocated to UE .
	...         c. trigger A4 measurement report with non highest proity.
	...         d. set RRC Reconfig timer to delay 5s,A4 for MMENDC setup.A4 for 7517 release.
    ...         e. trigger A4 MR for MMENDC steering
    ...         f. UE deregister should be successfully.

	[Tags]    C045    owner-jia.pan    QC_197223
    OnlineParamChange    ${OnlineParam_C045}
    UE Attach To Target Cell with UE modify    11
    Trigger inter-frq A4 for low priority
    Trigger A4 MR for MMENDC steering with 5s delay for RRCreconfigcomplete
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C045${/}a2a.ini     wait_string=UEContextReleaseComplete::4
    [Teardown]    C045_Teardown

*** Keywords ***
Trigger A4 MR for MMENDC steering with 5s delay for RRCreconfigcomplete
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000    Hit on error
    sleep    4s    reason=ue_nr_rrc_reconf delay timer
    Execute Egate Command    ue_measurement_send_nr event=A4 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=3
    ...    UE81: IS IDLE

Trigger inter-frq A4 for low priority
    sleep    1s    reason=retryTimer
    Execute Egate Command    ue_measurement_send_nr event=A4 phycell_id=61 nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=2    EGATE>

UE Attach To Target Cell with UE modify
    [Arguments]    ${cell_id}
    Update UE capa    ${ue_nr_Capa_support_A4_for_immediateENDC}    ${ue_eutra_nr_Capa_support_A4_for_immediateENDC}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}    EGATE>
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1    QoS Routing Table

Update UE capa
    [Arguments]    ${SA_Capa_NR}=none    ${SA_Capa_EUTRAN}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_NR} ue_eutra_nr_capabilities=${SA_Capa_EUTRAN}
    Execute Egate Command    ${cmd}    EGATE>

C045_Teardown
    OnlineParamChange    ${OnlineParam_C045_recover}
    Common Test Teardown And Stop Capture Logs

UE Send Redirection A2 report
    [Arguments]    ${ue_id}=82
    BuiltIn.Log    Trigger UE${ue_id} send Redirection A2 report
    ...    console=${True}
    ${pass_regexp}    set variable    measurementReport
    ${cmd}    Catenate    ue_schedule_measurement_send_nr id=${ue_id} action=DELAY_TILL_NR_RRC_RECONF delay=1s
    ...    meas_id=3 event=A4 srsrp_nr=15 srsrq_nr=15 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    sleep    2s    reason=smaller than a4Fr1SupervisionTimer
    ${pass_regexp1}    set variable    UE${ue_id}: IS IDLE
    ${cmd1}    Catenate   ue_measurement_send_nr id=${ue_id} event=A2 meas_id=1 srsrp_nr=15 srsrq_nr=15
    ${ret_1}=    Execute Egate Command    ${cmd1}    ${pass_regexp1}
    Run keywords    Should Contain    ${ret_1}=    rrcRelease    AND    Should Contain    ${ret1}=
    ...    carrierFreq 633216

Restore scf to remove C028 delta
    OnlineParamChange    ${OnlineParam_C028_recover}
    Common Test Teardown And Stop Capture Logs

C047_Teardown
    OnlineParamChange    ${OnlineParam_C047_recover}
    Common Test Teardown And Stop Capture Logs

Trigger A3 MR and HO with 5s delay for RRCreconfigcomplete
    [Arguments]    ${ue_id}=81    ${carrierfreq}=126750    ${PCI}=63
    Execute Egate Command  ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate     ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...  phycell_id=${PCI} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.14 performed

SA UE attach
    [Arguments]    ${ue_id}=81    ${target_cells}=12
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    Initial Context Setup Successful
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1

A4 not configured after first retryTimer expire when interfreqA3MR deconfig ongoing
    [Arguments]    ${cell_id}=2
    UE Attach To Target Cell    cell_id=${cell_id}    nwslice=1    gw_id=1
    Send And Verify Throuput
    Trigger interfreq A2 MR
    Execute Egate Command    ue_nr_rrc_reconf_param id=81 if_contains=any delay=5000 action=none
    Trigger A1 MR 2s before first retryTimer expire
    Verify Throuput

Trigger interfreq A2 MR
    [Arguments]    ${ue_id}=81    ${carrierfreq}=633216
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=20 srsrq_nr=20
    ...    pass_regexp=gapUE setup

Trigger A1 MR 2s before first retryTimer expire
    [Arguments]    ${ue_id}=81    ${carrierfreq}=633216
    sleep    18s    reason=wait for a4 retrytimer near to expire
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=gapUE release
    sleep    60s    reason=wait a4 supervison timer finished.

C031 TestTeardown
    OnlineParamChange    ${OnlineParam_C031_recovery}
    Common Test Teardown And Stop Capture Logs

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    Update Cfg    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.129 daemon=10.0.2.1:22222 gnb_id=0x12:28 nssai=0x01:0xD143A5
    ${cell_1}    catenate
    ...    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.1:12218 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    Update Cfg    ${cell_1}
    Update Cfg    gnb_param id=5 xn_listening_socket=off

UE_register_and_ICS_w_pdu
    [Arguments]     ${ue_id}=81     ${cell_id}=11
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id}
    Execute Egate Command    ${cmd}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId ${pdu_id} Created

Check_A4_Cconfigured
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
    ...    pass_regexp=eventA4
    sleep    2s    reason=wait timer

Trigger_A2_MR_after_first_A4_deconfigured
    Start To Capture Wireshark Log    C025_A2_MR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=rrcReconfigurationComplete
    sleep   25s    reason=sleep timer must bigger than a4PeriodicMeasControlSA a4RetryTimer to wait a4RetryTimer expire
    stop capture wireshark log    C025_A2_MR

Trigger_A1_MR_to_reconfigure_A4
    Start To Capture Wireshark Log    C025_A1_MR
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A1    carrierfreq=424090
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    100s    reason=wait timer
    stop capture wireshark log        C025_A1_MR

A4 should not be configured if overload and configured after cancel overload
    UE Attach To Target Cell    cell_id=11    nwslice=1    gw_id=1
	Send And Verify Throuput
    Triger overload
	Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    fail_regexp=eventA4    timeout=30s
	Cancel overload
	Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=eventA4    timeout=40s

Measurement Report Should be discarded If Overload
    Triger overload
	trigger A4 Measurement Report and be discarded    phycell_id=51    carrierfreq=633216    event_type=A4
	Cancel overload

A4 deconfig should not happen if overload
	Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToAddModList    timeout=50s
    Triger overload
	Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    fail_regexp=measIdToRemoveList    timeout=11s
	Cancel overload

Triger overload
    [Arguments]    ${sleep_time}=0s
	Set Ovlthreshold On Specific Cpue Id    20,30,40    0
    Sleep    ${sleep_time}    reason=wait timer

Cancel overload
    [Arguments]    ${sleep_time}=0s
	Set Ovlthreshold On Specific Cpue Id    20,30,40    20
    Sleep    ${sleep_time}    reason=wait timer

C020 TestTeardown
    OnlineParamChange    ${OnlineParam_for_C020_Recover}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${nwslice}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Verify Throuput
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=10s    ${ue_id}=81
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]     ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    Verify Throuput    ue_id=${ue_id}

Trigger A4 Measurement Report and be Discarded
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} phycell_id=${phycell_id} nrsrp_nr=70
    ...    fail_regexp=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.2 performed    timeout=10s

Trigger A4 Measurement Report and HO Successfully
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} phycell_id=${phycell_id} nrsrp_nr=70
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.2 performed
	Send And Verify Throuput

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
