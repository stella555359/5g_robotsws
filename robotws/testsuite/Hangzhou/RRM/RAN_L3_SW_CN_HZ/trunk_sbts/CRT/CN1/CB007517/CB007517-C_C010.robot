*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-jing.ye
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
...    @{A4_Config}
...    @{Mobility_Profile_Config}
...    @{NRPMQAP_config}
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-2:actCDrx=true


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
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=3000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=0
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=3000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=12
...    NRCELL-2:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL-2:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=50
...    NRCELL-2:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms64
...    NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms40
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
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=2079163
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=427970
...    NRCELL-1/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=30
...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=126750
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-4:ssbFrequency=633216
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=rsrqCombined
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-4:a4PriorityForHigherPrioFreqHo=30
...    NRCELL-1/NRHOIF-5:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-5:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-5:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-5:ssbFrequency=424090
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=20
...    NRCELL-1/NRHOIF-6:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-6:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-6:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-6:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-6:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-6:ssbFrequency=2071675
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-6:a4PriorityForHigherPrioFreqHo=6
...    NRCELL-1/NRHOIF-7:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-7:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-7:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-7:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-7:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-7:ssbFrequency=513150
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-7:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-13:gNbId=1
...    NRCELL-1/NRREL-13:gNbIdLength=22
...    NRCELL-1/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-13:removeNotAllowed=false
...    NRCELL-1/NRREL-13:lcrId=13
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-14:gNbId=1
...    NRCELL-1/NRREL-14:gNbIdLength=22
...    NRCELL-1/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-14:removeNotAllowed=false
...    NRCELL-1/NRREL-14:lcrId=14
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
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
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=1

@{Mobility_Profile_Config}
...    NRBTS-1:actMobilityProfile=true
...    NRBTS-1:actRanSharing=true
...    delete:NRBTS-1/NRCELL:configuredEpsTac
...    delete:NRBTS-1/NRCELL:trackingAreaDN
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=518910
...    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-11/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
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
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=518910
...    NRCELL-13/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-13/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-14/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-1:ssbFrequency=518910
...    NRCELL-14/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-14/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=20
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=30
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80
...    NRCELL/NRPLMNSET_SA-1
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    NRCELL/NRPLMNSET_NSA-1
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRMEASCFG_IF-1
...    delete:NRBTS-1/NRMEASCFG_IF-1:a4MeasHigherPrioFreqEnabled
...    NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=20
...    NRBTS-1/NRMEASCFG_IF-1:freqBandIndicatorNR=257
...    NRBTS-1/NRMEASCFG_IF-1:ssbFrequency=2079163
...    NRBTS-1/NRMEASCFG_IF-2
...    NRBTS-1/NRMEASCFG_IF-2:a4MeasHigherPrioFreqEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-2:a4PriorityForHigherPrioFreqHo=20
...    NRBTS-1/NRMEASCFG_IF-2:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-2:ssbFrequency=518910
...    NRBTS-1/NRMEASCFG_IF-3
...    delete:NRBTS-1/NRMEASCFG_IF-3:a4MeasHigherPrioFreqEnabled
...    NRBTS-1/NRMEASCFG_IF-3:a4PriorityForHigherPrioFreqHo=2
...    NRBTS-1/NRMEASCFG_IF-3:freqBandIndicatorNR=71
...    NRBTS-1/NRMEASCFG_IF-3:ssbFrequency=126750
...    NRBTS-1/NRMOPR_NSA-1
...    NRBTS-1/NRMOPR_NSA-1:a3MeasEnabled=none
...    NRBTS-1/NRMOPR_SA-1:a1MeashoEnabledSA=rsrq
...    NRBTS-1/NRMOPR_SA-1:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-1:a2MeashoEnabledSA=rsrq
...    NRBTS-1/NRMOPR_SA-1:a3MeasEnabled=none
...    NRBTS-1/NRMOPR_SA-1:a5MeasEnabled=none
...    NRBTS-1/NRMOPR_SA-1:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-1:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-1:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-1:nrMeasCfgIfDNList=MRBTS-1/NRBTS-1/NRMEASCFG_IF-1,MRBTS-1/NRBTS-1/NRMEASCFG_IF-3
...    NRBTS-1/NRMOPR_SA-2:a1MeashoEnabledSA=rsrq
...    NRBTS-1/NRMOPR_SA-2:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-2:a2MeashoEnabledSA=rsrq
...    NRBTS-1/NRMOPR_SA-2:a3MeasEnabled=none
...    NRBTS-1/NRMOPR_SA-2:a5MeasEnabled=none
...    NRBTS-1/NRMOPR_SA-2:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-2:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-2:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-2:nrMeasCfgIfDNList=MRBTS-1/NRBTS-1/NRMEASCFG_IF-2
...    NRCELL:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-1:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-1
...    NRCELL-2:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-2
...    NRCELL-11:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-2
...    NRCELL-12:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-2
...    NRCELL-13:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-2
...    NRCELL-14:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-2

@{PM_Counters_Check_C010}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-1:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-2:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRBTS-1:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRBTS-1:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=2

${A4_IEF_IADU_HO_EX_ATT_SA}    M55184C00003  #Building of RRC Reconfiguration into DL RRC Message Transfer (from gNB-CU)
${A4_IEF_IADU_HO_EX_SUC_SA}    M55184C00004  #Reception of RRC Reconfiguration complete and sending UL RRC Message over NR (to gNB-CU)
${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321  #The number of inter-frequency intra-DU HO attempts for SA per PLMN-ID
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322  #The number of successful inter-frequency intra-DU HOs for SA per PLMN-ID
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550  #Attempted Inter-Frequency Intra-gNBIntra-DU HO per PLMN, per slice
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551  #Successful Inter-Frequency Intra-gNBIntra-DU HO, per PLMN, per slice

${SA_Capa_Support_FR2}    SEPARATOR=
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

${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${Cell1_phycellid}    50
${Cell2_phycellid}    51
${BTS_STARTUP_RETRY}    4

*** Test Cases ***
CB007517-ET-C010_Inter-freq_Intra-DU_HO_succeed_with_multi_A4_MR_with_same_low_prio_received_non-first_circulation
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios: UE support CA, but gNB is not support CA, 
	...    inter-frq intra-DU HO succeed with multi A4 MR with same low prio received non-first circulation after ICS.
	...    2. Configuration
	...         a.configuration on cell 1
    ...           mobility profile configuration:
    ...           NRBTS.NRMEASCFG_IF_1.a4MeasHigherPrioFreqEnabled = not config Priority = 20
    ...           NRBTS.NRMEASCFG_IF_3.a4MeasHigherPrioFreqEnabled = not config Priority = 2
	...           NRHOIF configuration:
    ...           NRBTS.NRCELL.NRHOIF_1.a4MeasHigherPrioFreqEnabled = 1 Priority = 1    measID = 1
    ...           NRBTS.NRCELL.NRHOIF_2.a4MeasHigherPrioFreqEnabled = 3 Priority = 30   measID = 6/7
    ...           NRBTS.NRCELL.NRHOIF_3.a4MeasHigherPrioFreqEnabled = 1 Priority = 1    measID = 2
    ...           NRBTS.NRCELL.NRHOIF_4.a4MeasHigherPrioFreqEnabled = 5 Priority = 30   measID = 8
    ...           NRBTS.NRCELL.NRHOIF_5.a4MeasHigherPrioFreqEnabled = 2 Priority = 20   measID = 5
    ...           NRBTS.NRCELL.NRHOIF_6.a4MeasHigherPrioFreqEnabled = 1 Priority = 6    measID = 3
    ...           NRBTS.NRCELL.NRHOIF_7.a4MeasHigherPrioFreqEnabled = 1 Priority = 7    measID = 4
    ...           Notes: ssbfrequency of same ID in NRMEASCFG_IF and NRHOIF is same. 
	...           DRX: enable
    ...         b.configuration on cell 2
    ...           mobility profile configuration:
    ...           NRBTS.NRMEASCFG_IF_1.a4MeasHigherPrioFreqEnabled = 2 Priority = 20
	...           NRHOIF configuration:
    ...           NRBTS.NRCELL.NRHOIF_1.a4MeasHigherPrioFreqEnabled = 1 Priority = 1    measID = 1
	...           DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Check throughput should be OK.
	...         c. Send the lowest priority MRs to trigger H4 handover, UE handover to cell 2 when supervision timer expired.
    ...         d. Check throughput should be OK.
    ...         e. Send highest MR to trigger H4 Handover, UE handover to cell 1 immediately.	
    ...         f. Check throughput should be OK.
    ...         g. UE deregister should be successfully.
	[Tags]    QC_195039    owner-jing.ye    C010
	Clear Counter Files
    UE Attach To Target Cell    cell_id=1
	Send And Verify Throughput
	Send muliti A4 MRs to Trigger A4 HO    ${Cell2_phycellid}    6    7    8    11s    2.1    2.2
	Verify Throughput
	Send Single A4 MR to Trigger A4 HO    ${Cell1_phycellid}    1    11s    2.2    2.1
	Verify Throughput
	UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C010${/}a2a.ini        wait_string=UEContextReleaseComplete::4
	Check Counters    ${PM_Counters_Check_C010}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
	
UE Attach To Target Cell
    [Arguments]    ${cell_id}
    Update UE capa    ${SA_Capa_Support_FR2}
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

Send muliti A4 MRs to Trigger A4 HO
    [Arguments]    ${phycell_id}    ${meas_id1}    ${meas_id2}    ${meas_id3}    ${sleeptime}    ${source_cell}    ${target_cell}
	Sleep    ${sleeptime}    reason=wait for first retrytimer and supervisiontimer timeout
	${cmd}    catenate    ue_measurement_send_nr event=A4 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=${meas_id1}
	${ret0}    Execute Egate Command    ${cmd}    measResultNeighCells measResultListNR
	${cmd}    catenate    ue_measurement_send_nr event=A4 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=${meas_id2}
	${ret1}    Execute Egate Command    ${cmd}    measResultNeighCells measResultListNR
	${cmd}    catenate    ue_measurement_send_nr event=A4 phycell_id=${Cell2_phycellid} nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=${meas_id3}
	${ret2}    Execute Egate Command    ${cmd}    rrcReconfigurationComplete
	Should Contain    ${ret2}    UEC-1: UE${ue_id}: Intra-eNB handover from EXT_ENB-${source_cell} to EXT_ENB-${target_cell} performed
	
Send Single A4 MR to Trigger A4 HO
    [Arguments]    ${phycell_id}    ${meas_id1}    ${sleeptime}    ${source_cell}    ${target_cell}
	#Sleep    ${sleeptime}    reason=wait for first retrytimer and supervisiontimer timeout
	Wait Until Keyword Succeeds    ${sleeptime}    1s    get a4 measid successful
	${cmd}    catenate    ue_measurement_send_nr event=A4 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=${meas_id}
	${ret}    Execute Egate Command    ${cmd}    rrcReconfigurationComplete
	Should Contain    ${ret}    UEC-1: UE${ue_id}: Intra-eNB handover from EXT_ENB-${source_cell} to EXT_ENB-${target_cell} performed
	
UE Deregister From gNB
    [Arguments]    ${ue_id}
	Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
	
Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

get a4 measid successful
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=518910    event_type=A4
    Set Test Variable    ${meas_id}
