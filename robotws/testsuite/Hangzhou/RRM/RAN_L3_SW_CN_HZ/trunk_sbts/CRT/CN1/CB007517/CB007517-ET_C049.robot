*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-dandan.chen
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS-1/NRCELL-2:actCDrx=true
...    NRBTS-1/NRCELL-12:actCDrx=true
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
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfg5qiRange=6-9
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=490
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:nrPmqapId=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfg5qiRange=6-9
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgArpRange=15
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgProfType=both
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:nrPmqapId=2
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfg5qiRange=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfgProfType=both
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:nrPmqapId=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfg5qiRange=5
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfgProfType=both
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:nrPmqapId=11
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfg5qiRange=5
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgProfType=NSA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:nrPmqapId=4

@{A4_Config}
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=12
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=7
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
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=30
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=12
...    @{A3_Meas_enable_for_NRHOIF-2_under_NRCELL-12}

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
...    NRCELL-12/NRHOIF-10:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
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
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-12/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=15KHz
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
...    NRCELL-12/NRHOIF-13:ifhoSsbScs=30 KHz
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

${SA_Capa_Support_FR2_perUE}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F
...    11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC0
...    9F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F
...    28581C0E1E13FFE00000FFF80000088000E0540B40378E3086800A8F3F1424045ED98AA9001E3C0087104184540A3F7F204BEF108001800F
...    78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000002160562
...    E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C28000E
...    20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2
...    300070A0000020001183A0000001C1009011A014404D808304003505C83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1
...    CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0890204
...    0D8E7C08103639F000B878C6318C6318C6318C630F413003C002C1C1401C0C02500700060240040603E09002000000010000020080000000
...    400000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500
...    200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED03410000096525040000659494100002
...    96524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E59494100
...    00C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1202F012A05028140A05028140A0
...    5028140A05028140A0502800384040300601002004202004010080600C20100200404030060100C018202018030080600C20100200404030
...    0601002004402018030080600C020180304040080201002008002004010D50F8000810182030385058606880889098A0C0C8D8E0E8F90929
...    3139414951697A0A0C1680

@{PM_Counters_Check_C049}
...    NRCELL-12/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-12:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12:NRANS:${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}=0
...    NRCELL-12:NRANS:${FAI_IF_INTRADU_HOP_OTH_SA_PLMN}=0
...    NRCELL-12:NRREL:${ATT_HO_NRREL}=1
...    NRCELL-12:NRREL:${SUCC_HO_NRREL}=1
...    NRCELL-12:NRREL:${FAIL_HO_NRREL_PREP}=0
...    NRBTS-1:NSL:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=1
...    NRBTS-1:NSL:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=1
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
${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${F2079163}    2079163
${F518910}    518910
${F633216}    633216
${F424090}    424090
${F427970}    427970
${F2071675}    2071675
${F513150}    513150
${F126750}    126750
*** Test Cases ***
CB007517-ET-C049_A4_deconfigured_after_A2_then_A1_with_A4_HO_with_duplicate_low_prio_same_measid_A4
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios: A4 deconfigured for non-first circulation
    ...    after receiving inter-freq A2 MR and keep deconfigured until receiving A1 MR and keep circulation then A4 MR
    ...    before reach maxNum and inter-frq intra-DU HO succeed at last with duplicate A4 MR with same measId with low
    ...    prio received after ICS(UEcapaperUE_A4MGperUE_interfreqA2Target7FR1FR2)(ICS_optimized__DRX__CA_Ue+_gNB_
    ...    turnoff__actHigherPrioFreqHo_SA+NSA__target7_FR1FR2__UEcapaPerUE__priority_alldiff__rsrpCombined)
    ...    (common NRHOIF)
    ...    2.Configuration
    ...         a.configuration on cell 12
    ...           NRHOIF configuration and ssb list below
    ...           NRBTS.NRCELL.NRHOIF_10.a4MeasHigherPrio is rsrp and Priority = 1 and freq is 2079163
    ...           NRBTS.NRCELL.NRHOIF_1.a4MeasHigherPrio is rsrp and Priority = 7 and freq is 518910
    ...           NRBTS.NRCELL.NRHOIF_2.a4MeasHigherPrio is rsrpCombined Priority = 30 and freq is 633216
    ...           NRBTS.NRCELL.NRHOIF_11.a4MeasHigherPrio is rsrp and Priority = 2 and freq is 424090
    ...           NRBTS.NRCELL.NRHOIF_13.a4MeasHigherPrio is rsrpAndRsrq and Priority = 25 and freq is 427970
    ...           NRBTS.NRCELL.NRHOIF_27.a4MeasHigherPrio is rsrp and Priority = 6 and freq is 2071675
    ...           NRBTS.NRCELL.NRHOIF_28.a4MeasHigherPrio is rsrp and Priority = 3 and freq is 513150
    ...           DRX: enable
    ...         b.configuration on cell 2
    ...           NRHOIF configuration:
    ...           NRBTS.NRCELL.NRHOIF_1.a4MeasHigherPrio is rsrp and Priority = 7 and freq is 126750
    ...           DRX: enable
    ...    3.Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 12. Throughput is ok.
    ...         b-1. Check after first A4retrytimer expire, eventA4 setup
    ...         b-2. Check after first Supervison expire, eventA4 deconfig
    ...         b-3. Check after second A4retrytimer expire, eventA4 setup
    ...         c-1. On second Supervison start, trigger A2 MR, Event A1A3 config, A2A4 deconfig
    ...         c-2. Check No EventA4 Config When Second A4Fr2SupervisionTimer Expire
    ...         c-3. Wait Third A4retrytimer Expire And No EventA4 Config As A1A3 Config
    ...         c-4. Third A4retrytimer Expire And Restart And Trigger A1MR Before Expire Then A1A3 Deconfig
    ...         c-5. when the A4retrytimer expire again, A4 config, gapue setup
    ...         d-1. Trigger 2 A4 Duplicate Low Prio MR During Third A4Fr2SupervisionTimer Then HO Happen
    ...              when A4Fr2SupervisionTimer timer expire
    ...         d-2. After A4retrytimer Expire On Target Cell A4 Configure, throughput is ok.
    ...         e. UE deregister should be successfully.
    [Tags]    QC_191113    owner-dandan.chen    C049
    OnlineParamChange    ${OnlineParam_For_C049}
    Clear Counter Files
    UE Attach To Target Cell    12    ${SA_Capa_Support_FR2_perUE}
    Send And Verify Throughput
    Check A4 timer working after Ue attach
    Trigger A2 On Second Supervison And Then Trigger A1 To Deconfig A1A3
    Trigger 2 Duplicated Low Prio A4 On Third Supervison Timer To Do HO
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C049${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_Check_C049}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Check A4 timer working after Ue attach
    Check Measid After Fist A4retrytimer Expire
    sleep    6s    reason=wait Fist A4Fr2SupervisionTimer Expire
    Check Measid After Second A4retrytimer Expire

Trigger A2 On Second Supervison And Then Trigger A1 To Deconfig A1A3
    Trigger A2MR During Second A4Fr2SupervisionTimer
    sleep    8s    reason=wait Second A4Fr2SupervisionTimer expire
    sleep    30s    reason=wait Third A4retrytimer Expire
    Third A4retrytimer Expire And Restart And Trigger A1MR Before Expire Then A1A3 Deconfig

Trigger 2 Duplicated Low Prio A4 On Third Supervison Timer To Do HO
    Trigger 2 A4 Duplicate Low Prio MR During Third A4Fr2SupervisionTimer Then HO Happen Later
    After A4retrytimer Expire On Target Cell A4 Configure
    Verify Throughput

Check Measid After Fist A4retrytimer Expire
    sleep    25s    reason=wait Fist A4retrytimer Expire
    Check high prio freq assign to small measid

Check high prio freq assign to small measid
    Get Freq Measid List
    Compare Mesid According Freq

Get Freq Measid List
    ${list_of_query_conditions}    Create List
    ${query1}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F2079163}    event_type=A4
    ${query2}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F424090}    event_type=A4
    ${query3}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F513150}    event_type=A4
    ${query4}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F2071675}    event_type=A4
    ${query5}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A4
    ${query6}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F427970}    event_type=A4
    ${query7}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    Append To List    ${list_of_query_conditions}    ${query1}    ${query2}
    ...    ${query3}    ${query4}    ${query5}    ${query6}    ${query7}
    Set Test Variable    ${list_of_query_conditions}

Compare Mesid According Freq
    ${meas_ids}=    Get Nr Meas Ids For Specific Type And Frequency    list_of_query_conditions=${list_of_query_conditions}
    Should Be True    ${meas_ids[0]}<${meas_ids[1]}<${meas_ids[2]}<${meas_ids[3]}<${meas_ids[4]}<${meas_ids[5]}<${meas_ids[6]}

Check Measid After Second A4retrytimer Expire
    sleep    30s    reason=wait Second A4retrytimer Expire
    Check high prio freq assign to small measid

Trigger A2MR During Second A4Fr2SupervisionTimer
    ${m126750}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F126750}    event_type=A2
    ${ret}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m126750} event=A2 srsrp_nr=20 srsrq_nr=20
    ...    pass_regexp=eventId eventA3
    Should not Contain    ${ret}    gapUE

Third A4retrytimer Expire And Restart And Trigger A1MR Before Expire Then A1A3 Deconfig
    sleep    15s    reason=wait Third A4retrytimer 15s
    ${m126750}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F126750}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m126750} event=A1 srsrp_nr=110 srsrq_nr=110
    ...    pass_regexp=gapUE release
    sleep    9s    reason=wait Third A4retrytimer expire

Trigger 2 A4 Duplicate Low Prio MR During Third A4Fr2SupervisionTimer Then HO Happen Later
    ${m633216}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m633216} event=A4 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m633216} event=A4 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    sleep    7s    reason=wait Third A4Fr2SupervisionTimer expire

After A4retrytimer Expire On Target Cell A4 Configure
    sleep    12s    reason=wait Fist A4retrytimer Expire
    ${m126750}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F126750}    event_type=A4

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
