*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-SGT&A    owner-dandan.chen
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G   
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${UTE_WIRESHARK_FLAG}    False
@{PARAMS_IN_SCF}
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1/NRCELL-2:actCDrx=true
...    NRBTS-1/NRCELL-12:actCDrx=true
...    NRBTS-1/NRCELL-13:actCDrx=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    @{A4_Config}
...    @{NRHOIF_NRREL_config_for_NRCELL-2}
...    @{NRHOIF_for_NRCELL12}
...    @{NRREL_for_NRCELL12}
...    @{A1_A2_Meas_enable_for_NRCELL12}
...    @{A1_A2_Meas_enable_for_NRCELL2}
...    @{NRPMQAP_config}

@{NRPMQAP_config}
...    NRBTS-1:actNrpmqapProfiles=true
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:nrPmqapId=1

@{A4_Config}
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=12
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=7
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=8
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-13:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-13:a4PeriodicMeasControlSA:a4RetryTimer=9
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-14:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-14:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=10000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=10000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-11:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-12:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-12:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-13:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=10000
...    NRCELL-13:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRCELL-13:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-13:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-14:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=10000
...    NRCELL-14:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRCELL-14:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-14:a4PeriodicMeasControlNSA:a4RetryTimer=20

@{NRHOIF_NRREL_config_for_NRCELL-2}
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=126750
...    NRCELL-2/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-1:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=12

@{OnlineParam_For_C049}
...    NRBTS-1/NRCELL-12:actCDrx=true
...    NRBTS-1:cuOvlHa:ovlSaA4TimerDiscard=enabled
...    NRBTS-1:cuOvlHa:ovlSaMeasDiscard=enabled
...    NRBTS-1:gnbOvlProtMode=classical
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=30
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=25
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-13:a4PeriodicMeasControlSA:a4RetryTimer=25
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    @{A3_Meas_enable_for_NRHOIF-2_under_NRCELL-12}

@{OnlineParam_For_Cell2}
...    @{NRHOIF_for_NRCELL2}
...    @{NRREL_for_NRCELL2}

@{OnlineParam_For_Cell13}
...    @{NRHOIF_for_NRCELL13}
...    @{NRREL_for_NRCELL13}

@{NRHOIF_for_NRCELL12}
...    NRCELL-12/NRHOIF-10:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-10:freqBandIndicatorNR=257
...    NRCELL-12/NRHOIF-10:ifhoSsbScs=120 KHz
...    NRCELL-12/NRHOIF-10:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-10:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-12/NRHOIF-10:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-10:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-10:ssbFrequency=2079163
...    NRCELL-12/NRHOIF-10:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-10:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-10:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-12/NRHOIF-10:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-10:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-10:a4MeasSsbRsrq:a4ThresholdSsbRsrq=21
...    NRCELL-12/NRHOIF-10:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-10:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=518910
...    NRCELL-12/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-12/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-2:ssbFrequency=633216
...    NRCELL-12/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrpCombined
...    NRCELL-12/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-12/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=22
...    NRCELL-12/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-2:a4PriorityForHigherPrioFreqHo=30
...    NRCELL-12/NRHOIF-11:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-11:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-11:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-11:ssbFrequency=424090
...    NRCELL-12/NRHOIF-11:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrq:a4ThresholdSsbRsrq=22
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-11:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-12/NRHOIF-13:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-13:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-13:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-13:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-13:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-13:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-13:ssbFrequency=427970
...    NRCELL-12/NRHOIF-13:a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-13:a4PriorityForHigherPrioFreqHo=25
...    NRCELL-12/NRHOIF-27:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-27:freqBandIndicatorNR=257
...    NRCELL-12/NRHOIF-27:ifhoSsbScs=120 KHz
...    NRCELL-12/NRHOIF-27:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-27:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-27:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-27:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-27:ssbFrequency=2071675
...    NRCELL-12/NRHOIF-27:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-27:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-27:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-12/NRHOIF-27:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-12/NRHOIF-27:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-27:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-12/NRHOIF-27:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-27:a4PriorityForHigherPrioFreqHo=6
...    NRCELL-12/NRHOIF-28:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-28:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-28:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-28:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-28:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-28:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-28:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-28:ssbFrequency=513150
...    NRCELL-12/NRHOIF-28:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-28:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-28:a4MeasSsbRsrp:a4ThresholdSsbRsrp=21
...    NRCELL-12/NRHOIF-28:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-28:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-28:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-12/NRHOIF-28:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-28:a4PriorityForHigherPrioFreqHo=3

@{NRHOIF_for_NRCELL13}
...    NRCELL-13/NRHOIF-10:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-10:freqBandIndicatorNR=257
...    NRCELL-13/NRHOIF-10:ifhoSsbScs=120 KHz
...    NRCELL-13/NRHOIF-10:ifhoSsbSmtcDuration=sf1
...    NRCELL-13/NRHOIF-10:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-13/NRHOIF-10:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-10:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-10:ssbFrequency=2079163
...    NRCELL-13/NRHOIF-10:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-10:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-10:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-13/NRHOIF-10:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-13/NRHOIF-10:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-13/NRHOIF-10:a4MeasSsbRsrq:a4ThresholdSsbRsrq=21
...    NRCELL-13/NRHOIF-10:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-13/NRHOIF-10:a4PriorityForHigherPrioFreqHo=6
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=518910
...    NRCELL-13/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-13/NRHOIF-1:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-13/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-13/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-2:ssbFrequency=633216
...    NRCELL-13/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrpCombined
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=22
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-13/NRHOIF-2:a4PriorityForHigherPrioFreqHo=30
...    NRCELL-13/NRHOIF-11:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-11:freqBandIndicatorNR=66
...    NRCELL-13/NRHOIF-11:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-11:ssbFrequency=424090
...    NRCELL-13/NRHOIF-11:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-11:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-11:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-13/NRHOIF-11:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-13/NRHOIF-11:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-13/NRHOIF-11:a4MeasSsbRsrq:a4ThresholdSsbRsrq=22
...    NRCELL-13/NRHOIF-11:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-13/NRHOIF-11:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-13/NRHOIF-12:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-12:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-12:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-12:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-12:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-12:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-12:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-12:ssbFrequency=126750
...    NRCELL-13/NRHOIF-12:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-12:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-12:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-13/NRHOIF-12:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-13/NRHOIF-12:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-13/NRHOIF-12:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-13/NRHOIF-12:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-13/NRHOIF-12:a4PriorityForHigherPrioFreqHo=25
...    NRCELL-13/NRHOIF-27:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-27:freqBandIndicatorNR=257
...    NRCELL-13/NRHOIF-27:ifhoSsbScs=120 KHz
...    NRCELL-13/NRHOIF-27:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-27:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-27:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-27:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-27:ssbFrequency=2071675
...    NRCELL-13/NRHOIF-27:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-27:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-27:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-13/NRHOIF-27:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-13/NRHOIF-27:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-13/NRHOIF-27:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-13/NRHOIF-27:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-13/NRHOIF-27:a4PriorityForHigherPrioFreqHo=6
...    NRCELL-13/NRHOIF-28:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-28:freqBandIndicatorNR=41
...    NRCELL-13/NRHOIF-28:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-28:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-28:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-28:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-28:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-28:ssbFrequency=513150
...    NRCELL-13/NRHOIF-28:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-28:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-28:a4MeasSsbRsrp:a4ThresholdSsbRsrp=21
...    NRCELL-13/NRHOIF-28:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-13/NRHOIF-28:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-13/NRHOIF-28:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-13/NRHOIF-28:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-13/NRHOIF-28:a4PriorityForHigherPrioFreqHo=3

@{NRHOIF_for_NRCELL2}
...    NRCELL-2/NRHOIF-10:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-10:freqBandIndicatorNR=257
...    NRCELL-2/NRHOIF-10:ifhoSsbScs=120 KHz
...    NRCELL-2/NRHOIF-10:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-10:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-2/NRHOIF-10:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-10:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-10:ssbFrequency=2079163
...    NRCELL-2/NRHOIF-10:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-10:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-10:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-2/NRHOIF-10:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-10:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-10:a4MeasSsbRsrq:a4ThresholdSsbRsrq=21
...    NRCELL-2/NRHOIF-10:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-10:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=518910
...    NRCELL-2/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-1:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-2/NRHOIF-11:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-11:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-11:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-11:ssbFrequency=424090
...    NRCELL-2/NRHOIF-11:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrq:a4ThresholdSsbRsrq=22
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-11:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-2/NRHOIF-12:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-12:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-12:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-12:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-12:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-12:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-12:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-12:ssbFrequency=126750
...    NRCELL-2/NRHOIF-12:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-12:a4PriorityForHigherPrioFreqHo=25
...    NRCELL-2/NRHOIF-13:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-13:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-13:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-13:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-13:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-13:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-13:ssbFrequency=427970
...    NRCELL-2/NRHOIF-13:a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-13:a4PriorityForHigherPrioFreqHo=25
...    NRCELL-2/NRHOIF-27:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-27:freqBandIndicatorNR=257
...    NRCELL-2/NRHOIF-27:ifhoSsbScs=120 KHz
...    NRCELL-2/NRHOIF-27:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-27:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-27:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-27:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-27:ssbFrequency=2071675
...    NRCELL-2/NRHOIF-27:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-27:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-27:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-2/NRHOIF-27:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-27:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-27:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-2/NRHOIF-27:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-27:a4PriorityForHigherPrioFreqHo=6
...    NRCELL-2/NRHOIF-28:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-28:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-28:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-28:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-28:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-28:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-28:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-28:ssbFrequency=513150
...    NRCELL-2/NRHOIF-28:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-28:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-28:a4MeasSsbRsrp:a4ThresholdSsbRsrp=21
...    NRCELL-2/NRHOIF-28:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-28:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-28:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-2/NRHOIF-28:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-28:a4PriorityForHigherPrioFreqHo=3

@{NRREL_for_NRCELL12}
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-13:gNbId=1
...    NRCELL-12/NRREL-13:gNbIdLength=22
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-13:removeNotAllowed=false
...    NRCELL-12/NRREL-13:lcrId=13
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-14:gNbId=1
...    NRCELL-12/NRREL-14:gNbIdLength=22
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:removeNotAllowed=false
...    NRCELL-12/NRREL-14:lcrId=14

@{NRREL_for_NRCELL13}
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:lcrId=2
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-11:gNbId=1
...    NRCELL-13/NRREL-11:gNbIdLength=22
...    NRCELL-13/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-11:removeNotAllowed=false
...    NRCELL-13/NRREL-11:lcrId=11
...    NRCELL-13/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-12:gNbId=1
...    NRCELL-13/NRREL-12:gNbIdLength=22
...    NRCELL-13/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-12:removeNotAllowed=false
...    NRCELL-13/NRREL-12:lcrId=12
...    NRCELL-13/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-14:gNbId=1
...    NRCELL-13/NRREL-14:gNbIdLength=22
...    NRCELL-13/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-14:removeNotAllowed=false
...    NRCELL-13/NRREL-14:lcrId=14

@{NRREL_for_NRCELL2}
...    delete:NRBTS-1/NRCELL-2/NRREL-2
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=1
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=1
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-14:gNbId=1
...    NRCELL-2/NRREL-14:gNbIdLength=22
...    NRCELL-2/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-14:removeNotAllowed=false
...    NRCELL-2/NRREL-14:lcrId=14

@{A1_A2_Meas_enable_for_NRCELL12}
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80

@{A1_A2_Meas_enable_for_NRCELL2}
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80

@{A3_Meas_enable_for_NRHOIF-2_under_NRCELL-12}
...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

${SA_Capa_Support_FR2_perFR}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C47013B8D85181AC1184341020E90186D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E
...    7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE0000016001C0A816806F1C610D00151E7E281845ED98AA9001E3C0087104184540A3F7F204BEF0A800C007BC3C4D000
...    E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00038820000042C0AC3C4D000E230000010B02B1711800388
...    2001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B1713400388C001C46000004160562E14000710400388C
...    0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C46000004160562E2680071180038500
...    000100008C1D0000000E0804808D00A2026C04182000E9720F851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C48912
...    26C73E1C28103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0204
...    0D8E7C002E1E318C6318C6318C6318C3D04C00F000F07050070300740380030120020301F048010000000080000100400000002000004010
...    00004008000030040000200200001401000802008020000180100000E0080040000001000010008000090040000180200002801000016008
...    00409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000
...    072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202
...    000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50505E02540A05028140A05028140A05028140A
...    05028140A05000708080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008
...    804030060100C018040300608080100402004010004008021AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2
...    D2F414182D

@{OnlineParam_ovlSaMeasDiscard_F}
...    NRBTS-1:cuOvlHa:ovlSaMeasDiscard=disabled

@{OnlineParam_ovlSaA4TimerDiscard_F}
...    NRBTS-1:cuOvlHa:ovlSaA4TimerDiscard=disabled

@{OnlineParam_ovl_T}
...    NRBTS-1:cuOvlHa:ovlSaMeasDiscard=enabled
...    NRBTS-1:cuOvlHa:ovlSaA4TimerDiscard=enabled

@{OnlineParam_ovl_F}
...    NRBTS-1:cuOvlHa:ovlSaMeasDiscard=disabled
...    NRBTS-1:cuOvlHa:ovlSaA4TimerDiscard=disabled

@{OnlineParam_ovlSaMeasDiscard_T}
...    NRBTS-1:cuOvlHa:ovlSaMeasDiscard=enabled

@{PM_Counters_Check_C049}
...    NRCELL-12/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-12:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12:NRANS:${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}=0
...    NRCELL-12:NRANS:${FAI_IF_INTRADU_HOP_OTH_SA_PLMN}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-2:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-13/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-13/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-13:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=0
...    NRCELL-13:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=0
...    NRCELL-12:NRREL:${ATT_HO_NRREL}=1
...    NRCELL-12:NRREL:${SUCC_HO_NRREL}=1
...    NRCELL-12:NRREL:${FAIL_HO_NRREL_PREP}=0
...    NRCELL-2:NRREL:${ATT_HO_NRREL}=1
...    NRCELL-2:NRREL:${SUCC_HO_NRREL}=1
...    NRCELL-2:NRREL:${FAIL_HO_NRREL_PREP}=0
...    NRBTS-1:NSL:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRBTS-1:NSL:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRCELL-12:NRRCC:${NRRCC_SA_MEAS_DISCARD_OVLCP}=1
...    NRCELL-2:NRRCC:${NRRCC_SA_MEAS_DISCARD_OVLCP}=2
...    NRCELL-13:NRRCC:${NRRCC_SA_MEAS_DISCARD_OVLCP}=1

${A4_IEF_IADU_HO_EX_ATT_SA}    M55184C00003
#This counter measures the number of A4 triggered handover execution attempts related to inter-frequency
#Intra-gNB Intra-DU handover for SA.
${A4_IEF_IADU_HO_EX_SUC_SA}    M55184C00004
#This counter measures the number of A4 triggered successful handover execution attempts related to
#inter-frequency Intra-gNB Intra-DU handover for SA.
${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321
#The number of inter-frequency intra-DU HO execution attempts for SA per PLMN-ID
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322
#The number of successful inter-frequency intra-DU HO executions for SA per PLMN-ID
${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}    M55145C00323
#The number of inter-frequency intra-DU HO preparation failures for SA due to admission control
${FAI_IF_INTRADU_HOP_OTH_SA_PLMN}    M55145C00324
#The number of inter-frequency intra-DU HO preparation failures for SA due to other reasons
${ATT_HO_NRREL}    M55153C00001
#The number of HO attempts per neighbor relation
${SUCC_HO_NRREL}    M55153C00002
#The number of HO Success per neighbor relation
${FAIL_HO_NRREL_PREP}    M55153C00003
#The number of HO preparation Failures per neighbor relation
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550
#The number of Inter-Frequency Intra-gNB Intra-DU HOs attempted for the given slice and PLMN
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551
#The number of Inter-Frequency Intra-gNB Intra-DU HOs successful for the given slice and PLMN
${NRRCC_SA_MEAS_DISCARD_OVLCP}    M55124C04503
#RRC Measurement report in Standalone mode discarded due to C-Plane overload
${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${BTS_STARTUP_RETRY}    4
${F2079163}    2079163
${F518910}    518910
${F633216}    633216
${F424090}    424090
${F427970}    427970
${F2071675}    2071675
${F513150}    513150
${F126750}    126750
*** Test Cases ***
CB007517-ET-ET08_A4MR_interact_with_ovl_during_sTexpire_with_counter_peg
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios: A4 config and deconfig
    ...       ovlSaA4TimerDiscard and ovlSaMeasDiscard both enable, when timer expire, if cpu overload, MR drop, no HO
    ...       ovlSaA4TimerDiscard and ovlSaMeasDiscard both disable, when timer expire, don't check cpu overload
    ...       ovlSaMeasDiscard = true, ovlSaA4TimerDiscard = false, when timer expire, if cpu overload, trigger one MR,
    ...       MR will drop, and the MR before cpu overload will also drop. (the MR before when will be drop? after timer expire?)
    ...    2. Configuration
    ...         a.configuration on cell 12
    ...           NRHOIF configuration and ssb list below
    ...           NRBTS.NRCELL.NRHOIF_10.a4MeasHigherPrio is rsrp and Priority = 7 and freq is 2079163
    ...           NRBTS.NRCELL.NRHOIF_1.a4MeasHigherPrio is rsrp and Priority = 1 and freq is 518910
    ...           NRBTS.NRCELL.NRHOIF_2.a4MeasHigherPrio is rsrpCombined Priority = 30 and freq is 633216
    ...           NRBTS.NRCELL.NRHOIF_11.a4MeasHigherPrio is rsrp and Priority = 2 and freq is 424090
    ...           NRBTS.NRCELL.NRHOIF_13.a4MeasHigherPrio is rsrpAndRsrq and Priority = 25 and freq is 427970
    ...           NRBTS.NRCELL.NRHOIF_27.a4MeasHigherPrio is rsrp and Priority = 6 and freq is 2071675
    ...           NRBTS.NRCELL.NRHOIF_28.a4MeasHigherPrio is rsrp and Priority = 3 and freq is 513150
    ...           DRX: enable
    ...         b.configuration on cell 2
    ...           NRHOIF configuration and ssb list below
    ...           NRBTS.NRCELL.NRHOIF_10.a4MeasHigherPrio is rsrp and Priority = 1 and freq is 2079163
    ...           NRBTS.NRCELL.NRHOIF_1.a4MeasHigherPrio is rsrp and Priority = 7 and freq is 518910
    ...           NRBTS.NRCELL.NRHOIF_11.a4MeasHigherPrio is rsrp and Priority = 2 and freq is 424090
    ...           NRBTS.NRCELL.NRHOIF_12.a4MeasHigherPrio is rsrpCombined Priority = 30 and freq is 126750
    ...           NRBTS.NRCELL.NRHOIF_13.a4MeasHigherPrio is rsrpAndRsrq and Priority = 25 and freq is 427970
    ...           NRBTS.NRCELL.NRHOIF_27.a4MeasHigherPrio is rsrp and Priority = 6 and freq is 2071675
    ...           NRBTS.NRCELL.NRHOIF_28.a4MeasHigherPrio is rsrp and Priority = 3 and freq is 513150
    ...           DRX: enable
    ...         c.configuration on cell 13
    ...           NRHOIF configuration and ssb list below
    ...           NRBTS.NRCELL.NRHOIF_10.a4MeasHigherPrio is rsrp and Priority = 1 and freq is 2079163
    ...           NRBTS.NRCELL.NRHOIF_1.a4MeasHigherPrio is rsrp and Priority = 7 and freq is 518910
    ...           NRBTS.NRCELL.NRHOIF_2.a4MeasHigherPrio is rsrpAndRsrq and Priority = 30 and freq is 633216
    ...           NRBTS.NRCELL.NRHOIF_11.a4MeasHigherPrio is rsrp and Priority = 2 and freq is 424090
    ...           NRBTS.NRCELL.NRHOIF_12.a4MeasHigherPrio is rsrpCombined Priority = 30 and freq is 126750
    ...           NRBTS.NRCELL.NRHOIF_27.a4MeasHigherPrio is rsrp and Priority = 6 and freq is 2071675
    ...           NRBTS.NRCELL.NRHOIF_28.a4MeasHigherPrio is rsrp and Priority = 3 and freq is 513150
    ...           DRX: enable
    ...    3. Test Case Steps:
    ...    a. UE registers successfully and PDU session is setup successfully on cell 12. Throughput is ok.
    ...    b. Supervision ongoing, receive n low A4 MRs, trigger overload, Supervision expire, MR discard, supervision restart
    ...    c. receive highest A4 MR, MR discard, 5G_NRRCC_SA_MEAS_DISCARD_OVLCP +1
    ...    d. modify ovlSaMeasDiscard = false, receive low A4 MR, supervision expire, MR discard, supervision restart
    ...    e. modify ovlSaA4TimerDiscard = false, receive low A4 MR, supervision expire, do HO to cell2 target1
    ...    f. on target1, cancel overload, retry ongoing, modify ovlSaMeasDiscard and ovlSaA4TimerDiscard true
    ...    g. supervision ongoing, receive n low A4 MRs, trigger overload, receive low A4 MR, 5G_NRRCC_SA_MEAS_DISCARD_OVLCP +1
    ...    h. Supervision expire, supervision restart, receive prio2 A4 MR, MR discard, 5G_NRRCC_SA_MEAS_DISCARD_OVLCP +1
    ...    i. modify ovlSaMeasDiscard = false, ovlSaA4TimerDiscard = false, receive prio3 A4 MR, supervision expire, do HO to prio3 cell13(target2)
    ...    j. on target2, cancel overload,retry ongoing, modify ovlSaMeasDiscard = true, ovlSaA4TimerDiscard = false
    ...    k. supervision ongoing,receive n low A4 MRs (prio3 & prio4), trigger overload, receive low A4 MR (prio2),
    ...    5G_NRRCC_SA_MEAS_DISCARD_OVLCP +1 (all MR discard), Supervision expire, no HO
    ...    l. UE deregister should be successfully.
    [Tags]    QC_194401    owner-dandan.chen    E008
    Precondition Setup
    Ue Attach And Fisrt A4 Check After Attach
    Trigger A4 And Check Overload Check On Cell12
    Trigger A4 And Check Overload Check On Cell2
    Trigger A4 And Check Overload Check On Cell13
    UE Deregister From gNB    ue_id=${ue_id}
    Check Counters    ${PM_Counters_Check_C049}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517CET008${/}a2a.ini    wait_string=UEContextRelease::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Precondition Setup
    OnlineParamChange    ${OnlineParam_For_C049}
    OnlineParamChange    ${OnlineParam_For_Cell2}
    OnlineParamChange    ${OnlineParam_For_Cell13}
    OnlineParamChange    ${OnlineParam_ovl_T}
    Get OvlThreshold Prerequisite
    Cancel overload
    Clear Counter Files

Ue Attach And Fisrt A4 Check After Attach
    UE Attach To Target Cell    12    ${SA_Capa_Support_FR2_perFR}
    Send And Verify Throughput
    Check A4 timer working after Ue attach

Trigger A4 And Check Overload Check On Cell12
    Trigger 1 Low Prio A4 On First Supervison Timer and trigger overload
    Trigger highest A4 and check drop count plus 1
    Delta Commission Parameters    ${OnlineParam_ovlSaMeasDiscard_F}
    Trigger Low Prio A4 On next cicle Supervison Timer and no HO happen
    sleep    2s    reason=wait A4supervisontimer expire
    Delta Commission Parameters    ${OnlineParam_ovlSaA4TimerDiscard_F}
    Trigger Low Prio A4 On next cicle Supervison Timer and HO happen

Trigger A4 And Check Overload Check On Cell2
    Cancel overload
    Delta Commission Parameters    ${OnlineParam_ovl_T}
    Verify Throughput    sleep_time=2s
    Trigger A4 MR And Paramter Modify

Trigger A4 MR And Paramter Modify
    Trigger 2 Low Prio A4 on cell2
    Trigger overload on all cell
    Trigger 1 Low Prio of 126750 A4 on cell2
    Trigger 1 Prio 2 of 424090 A4 on cell2
    Delta Commission Parameters    ${OnlineParam_ovl_F}
    sleep    1s    reason=wait A4setup and deconfig
    trigger 1 Prio 3 A4 on cell2 to HO to cell13

Trigger A4 And Check Overload Check On Cell13
    Cancel overload
    Delta Commission Parameters    ${OnlineParam_ovlSaMeasDiscard_T}
    Verify Throughput
    Schedule Low Prio A4 on cell13
    Wait Until Keyword Succeeds    30s    1s    get meaid for P3P4
    Trigger overload on all cell
    Trigger 1 P2 Prio A4 on cell13
    sleep    50s    reason=wait A4setup and deconfig

Cancel overload
    [Arguments]    ${sleep_time}=1s
    Set Ovlthreshold On Specific Cpue Id    a0,b0,c0    20
    Sleep    ${sleep_time}    reason=wait timer

Trigger overload on all cell
    [Arguments]    ${sleep_time}=0s
    Set Ovlthreshold On Specific Cpue Id    a0,b0,c0    0
    Sleep    ${sleep_time}    reason=wait timer

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Check A4 timer working after Ue attach
    Check Measid After Fist A4retrytimer Expire

Check Measid After Fist A4retrytimer Expire
    sleep    23s    reason=wait Fist A4retrytimer Expire
    Check high prio freq assign to small measid

Check high prio freq assign to small measid
    Get Query list
    ${meas_ids}=    Get Nr Meas Ids For Specific Type And Frequency    list_of_query_conditions=${list_of_query_conditions}
    Set Test Variable    ${meas_ids}
    Should Be True    ${meas_ids[0]}<${meas_ids[1]}<${meas_ids[2]}<${meas_ids[3]}<${meas_ids[4]}<${meas_ids[5]}<${meas_ids[6]}

Get Query list
    ${list_of_query_conditions}    Create List
    ${query1}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A4
    ${query2}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F424090}    event_type=A4
    ${query3}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F513150}    event_type=A4
    ${query4}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F2071675}    event_type=A4
    ${query5}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F2079163}    event_type=A4
    ${query6}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F427970}    event_type=A4
    ${query7}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    Append To List    ${list_of_query_conditions}    ${query1}    ${query2}
    ...    ${query3}    ${query4}    ${query5}    ${query6}    ${query7}
    Set Test Variable    ${list_of_query_conditions}

Trigger 1 Low Prio A4 On First Supervison Timer and trigger overload
    Trigger 1 Low Prio A4 On First Supervison Timer and no HO happen
    Trigger overload on all cell
    sleep    3s    reason=wait Third A4Fr2SupervisionTimer expire

Trigger 1 Low Prio A4 On First Supervison Timer and no HO happen
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[1]} event=A4 phycell_id=60 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR

Trigger Low Prio A4 On next cicle Supervison Timer and no HO happen
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[6]} event=A4 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR

Trigger Low Prio A4 On next cicle Supervison Timer and HO happen
    Wait Until Keyword Succeeds    30s    1s    get m633216 measid
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m633216} event=A4 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    sleep    7s    reason=wait Third A4Fr2SupervisionTimer expire

get m633216 measid
    ${m633216}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    Set Test Variable    ${m633216}

Trigger highest A4 and check drop count plus 1
    ${m518910}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A4
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m518910} event=A4 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    sleep    7s    reason=wait Third A4Fr2SupervisionTimer expire

Trigger 2 Low Prio A4 on cell2
    Wait Until Keyword Succeeds    18s    1s    get measid on cell2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${cell2_meas_ids[2]} event=A4 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${cell2_meas_ids[2]} event=A4 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR

get measid on cell2
    ${list_of_query_conditions}    Create List
    ${query1}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F424090}    event_type=A4
    ${query2}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A4
    ${query3}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F427970}    event_type=A4
    ${query4}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F126750}    event_type=A4
    Append To List    ${list_of_query_conditions}    ${query1}    ${query2}    ${query3}    ${query4}
    ${cell2_meas_ids}=    Get Nr Meas Ids For Specific Type And Frequency    list_of_query_conditions=${list_of_query_conditions}
    Set Test Variable    ${cell2_meas_ids}

Trigger 1 Low Prio of 126750 A4 on cell2
    Wait Until Keyword Succeeds    100s    1s    get measid on cell2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${cell2_meas_ids[3]} event=A4 phycell_id=61 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR

Trigger 1 Prio 2 of 424090 A4 on cell2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${cell2_meas_ids[0]} event=A4 phycell_id=60 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR

trigger 1 Prio 3 A4 on cell2 to HO to cell13
    Wait Until Keyword Succeeds    40s    1s    get m427970 measid
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m427970} event=A4 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR

get m427970 measid
    ${m427970}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F427970}    event_type=A4
    Set Test Variable    ${m427970}

Schedule Low Prio A4 on cell13
    ${cmd}    catenate    ue_schedule_measurement_send_nr id=81 action=DELAY_TILL_NR_RRC_RECONF periodicity=5000
    ...    delay=10 meas_id=5 event=A4 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    ${ret0}    Execute Egate Command    ${cmd}    pass_regexp=DELAY_TILL_NR_RRC_RECONF    timeout=20s

get meaid for P3P4
    ${list_of_query_conditions}    Create List
    ${query1}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F424090}    event_type=A4    timeout=0.5
    ${query2}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A4
    ${query3}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    Append To List    ${list_of_query_conditions}    ${query1}    ${query2}    ${query3}
    ${meas_ids}=    Get Nr Meas Ids For Specific Type And Frequency    list_of_query_conditions=${list_of_query_conditions}
    Set Test Variable    ${meas_ids}

Trigger 1 P2 Prio A4 on cell13
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A4 phycell_id=60 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${UE_Capa}
    Update UE capa    ${UE_Capa}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Verify Throughput
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=5s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throughput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    Verify Throughput
	
UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
	
Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}
