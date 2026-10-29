*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-christine.chen
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    5GC000732-F    release-5G22R4
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
...    NRBTS-1/NRADJNRCELL-1:physCellId=381
...    NRBTS-1/NRADJNRCELL-1:gNbId=35
...    @{HO_Config}
...    @{A4_Config}
...    @{NRHOIF_Config}
...    @{NRREL_Config}
...    @{Mobility_Profile_Config}
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
...    NRBTS-1/NRPMRNL-1/NRPMQAP-12:cfgProfType=both
...    NRBTS-1/NRPMRNL-1/NRPMQAP-12:nrPmqapId=12
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfg5qiRange=6-9
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgSliceId:sd=13714341
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgSliceId:sst=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgArpRange=10
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgProfType=SA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:nrPmqapId=20
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfg5qiRange=6-9
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgSliceId:sd=13714340
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgSliceId:sst=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgProfType=SA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:nrPmqapId=10

@{HO_Config}
...    NRBTS-1/NRCELL:actCDrx=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min

@{A4_Config}
...    NRCELL-2:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL-2:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=50
...    NRCELL-2:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms64
...    NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=20
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=30
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80

...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=8000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4RetryTimer=10
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=8000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=10

@{NRHOIF_Config}
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
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=633216
...    NRCELL-1/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=30
...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=513150
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=1

...    NRCELL-1/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-4:ssbFrequency=126750
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-4:a4PriorityForHigherPrioFreqHo=4

...    NRCELL-1/NRHOIF-5:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-5:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-5:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-5:ssbFrequency=427970
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=20

...    NRCELL-1/NRHOIF-6:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-6:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-6:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-6:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-6:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-6:ssbFrequency=424090
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-6:a4PriorityForHigherPrioFreqHo=20
...    NRCELL-1/NRHOIF-7:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-7:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-7:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-7:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-7:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-7:ssbFrequency=2071675
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-7:a4PriorityForHigherPrioFreqHo=6


@{NRREL_Config}
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
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=35
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=1
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
...    NRBTS-1/NRMEASCFG_IF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=2
...    NRBTS-1/NRMEASCFG_IF-1:freqBandIndicatorNR=257
...    NRBTS-1/NRMEASCFG_IF-1:ssbFrequency=2079163
...    NRBTS-1/NRMEASCFG_IF-2
...    NRBTS-1/NRMEASCFG_IF-2:a4MeasHigherPrioFreqEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-2:a4PriorityForHigherPrioFreqHo=20
...    NRBTS-1/NRMEASCFG_IF-2:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-2:ssbFrequency=518910
...    NRBTS-1/NRMEASCFG_IF-3
...    NRBTS-1/NRMEASCFG_IF-3:a4MeasHigherPrioFreqEnabled=rsrpAndRsrq
...    NRBTS-1/NRMEASCFG_IF-3:a4PriorityForHigherPrioFreqHo=20
...    NRBTS-1/NRMEASCFG_IF-3:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-3:ssbFrequency=513150
...    NRBTS-1/NRMEASCFG_IF-4
...    delete:NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled
...    NRBTS-1/NRMEASCFG_IF-4:a4PriorityForHigherPrioFreqHo=1
...    NRBTS-1/NRMEASCFG_IF-4:freqBandIndicatorNR=71
...    NRBTS-1/NRMEASCFG_IF-4:ssbFrequency=126750
...    NRBTS-1/NRMEASCFG_IF-5
...    NRBTS-1/NRMEASCFG_IF-5:a4MeasHigherPrioFreqEnabled=rsrpCombined
...    NRBTS-1/NRMEASCFG_IF-5:a4PriorityForHigherPrioFreqHo=4
...    NRBTS-1/NRMEASCFG_IF-5:freqBandIndicatorNR=66
...    NRBTS-1/NRMEASCFG_IF-5:ssbFrequency=427970
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
...    NRBTS-1/NRMOPR_SA-1:nrMeasCfgIfDNList=${DNL_list}
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

${DNL_list}    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1,MRBTS-1/NRBTS-1/NRMEASCFG_IF-3,MRBTS-1/NRBTS-1/NRMEASCFG_IF-4,MRBTS-1/NRBTS-1/NRMEASCFG_IF-5

@{OnlineParam_for_C009}
...    NRBTS-1/NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRBTS-1/NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=5

@{OnlineParam_for_C009_recover}
...    NRBTS-1/NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=8000
...    NRBTS-1/NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=10

${SA_Capa_Support_FR2_with_independent_gap}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623809DC6C28C0D608C21A0810748046D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0003801C0A83620EB04610D04083C40232B64C55890E7D813E238
...    F1891C790E7D473E618F28581C0E1E13FB000000FEC0000003801C0AA3626EB04610D04083A40230B64C55110E7C471E238F40CFB027C63
...    9F30C7942C0E070F05C00FFC007003FF0001C00E0541B11B582308682041E201195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E
...    070F09FFF000007FFC000001C00E0540B40378E3086800A8F3F140445ED98AA9001E3C0087104184540A3F7F204BEF06803001EF0F13400
...    38820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E
...    208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850001C41000E
...    230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E
...    14000004000230740000003820120234028809B010608002AB907C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2
...    448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1C
...    F810206C73E00170F18C6318C6318C6318C61E81601E001E0E0601C0C01501C0018090010180F8240080000000400000802000000010000
...    0200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C0100001400800
...    00B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A59
...    4901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504000
...    3259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E2808BC04A8140A05028140A0502814
...    0A05028140A05028140A000E10100C018040080108080100402018030804008010100C018040300608080600C02018030804008010100C0
...    18040080110080600C02018030080600C10100200804008020008010043543E00020406080C0E1416181A2022242628303236383A3E424A
...    4C4E5052545A5E828305A

${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${Cell1_phycellid}    50
${Cell2_phycellid}    381
${BTS_STARTUP_RETRY}    4

@{PM_Counters_Check_C009}
...    NRCELL-1:NNGCC:${NG_PATH_SWITCH_ACK_RECEIVED}=1
...    NRCELL-1:NXNCC:${XN_HO_REQ_ACK_RECEIVED}=1
...    NRCELL-1:NXNCC:${XN_HO_REQ_SENT}=1
...    NRCELL-1:NXNCC:${XN_HO_REQ__RECEIVED}=1
...    NRCELL-1:NXNCC:${XN_HO_REQ_ACK_SENT}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMEXP:${A4_IEF_XN_HO_PR_ATT_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMEXP:${A4_IEF_XN_HO_EX_ATT_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMEXP:${A4_IEF_XN_HO_EX_SUC_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-12:SMEXP:${A4_IEF_XN_HO_PR_ATT_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-12:SMEXP:${A4_IEF_XN_HO_EX_ATT_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-12:SMEXP:${A4_IEF_XN_HO_EX_SUC_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMEXP:${A4_IEF_XN_HO_PR_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMEXP:${A4_IEF_XN_HO_EX_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMEXP:${A4_IEF_XN_HO_EX_SUC_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:SMEXP:${A4_IEF_XN_HO_PR_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:SMEXP:${A4_IEF_XN_HO_EX_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:SMEXP:${A4_IEF_XN_HO_EX_SUC_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-20:SMEXP:${A4_IEF_XN_HO_PR_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-20:SMEXP:${A4_IEF_XN_HO_EX_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-20:SMEXP:${A4_IEF_XN_HO_EX_SUC_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-10:SMEXP:${A4_IEF_XN_HO_PR_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-10:SMEXP:${A4_IEF_XN_HO_EX_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-10:SMEXP:${A4_IEF_XN_HO_EX_SUC_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMEXP:${A4_IEF_XN_HO_PR_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMEXP:${A4_IEF_XN_HO_EX_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMEXP:${A4_IEF_XN_HO_EX_SUC_SRC}=0
...    NRCELL-1:NRANS:${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}=1
...    NRCELL-1:NRANS:${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}=1
...    NRCELL-1:NRANS:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}=1
...    NRCELL-1:NRANS:${SUCC_IC_INTER_GNB_HO_SA_PLMN}=1

${NG_PATH_SWITCH_ACK_RECEIVED}    M55125C01501
#Successful Path Switch Procedure
${XN_HO_REQ_ACK_RECEIVED}    M55143C00001
#Number of incoming Handover Request Acknowledge received from Target gNB
${XN_HO_REQ_SENT}    M55143C00004
#Number of Outgoing Handover Request message
${XN_HO_REQ__RECEIVED}    M55143C00005
#Number of incoming Handover Request message received by gNB
${XN_HO_REQ_ACK_SENT}    M55143C00006
#Number of outgoing Handover Request Acknowledge sent by Target gNB
${A4_IEF_XN_HO_PR_ATT_SRC}    M55185C00001
#A4 trigg Xn based Inter-freq HO prep att on the source cell
${A4_IEF_XN_HO_EX_ATT_SRC}    M55185C00002
#A4 trigg Xn based Inter-freq HO exec att on the source cell
${A4_IEF_XN_HO_EX_SUC_SRC}    M55185C00003
#A4 trigg successful Xn based Inter-freq HO exec att on the source cell
${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}    M55145C00351
#The number of outgoing inter-frequency inter-gNB HO attempts for SA per PLMN-ID
${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}    M55145C00352
#The number of successful outgoing inter-frequency inter-gNB HOs for SA per PLMN-ID
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361
#The number of successful incoming inter-gNB HO preparations for SA per PLMN-ID
${SUCC_IC_INTER_GNB_HO_SA_PLMN}    M55145C00362
#The number of successful incoming inter-gNB HOs for SA per PLMN-ID

*** Test Cases ***
CB007517-ET-C009_Inter-freq_Inter-gNB_Xn_HO_succeed_after_sT_expire_with_A4_MR_with_low_prio_received_first_circulation_wo_pdu
    [Documentation]
    ...    1. This user scenario describes the behaviour, UE support CA, but gNB is not support CA, inter-frq inter-gNB Xn HO succeed
    ...       after SupervisionTimer expire with A4 MR with low prio received first circulation after ICS without PDU.
	...    2. Configuration
	...         a. cell1 band is FR1, target cell for A4 should contain both FR1 and FR2
	...         b. enable mobility profile
	...         c. sim-cell1 should be configured in NRHOIF
	...         d. SA Inter-frequency mobility is enabled
	...         e. CB0007517 feature is activated in the gNB for SA
	...           UE capability support independent MG
	...           DRX: enable
    ...         f. mobility profile configuration:
    ...			  NRBTS.NRMEASCFG_IF_1.a4MeasHigherPrioFreqEnabled = 1            Priority = 2
    ...           NRBTS.NRMEASCFG_IF_3.a4MeasHigherPrioFreqEnabled = 3            Priority = 20      gnb-sim cell1
    ...           NRBTS.NRMEASCFG_IF_4.a4MeasHigherPrioFreqEnabled = not config   Priority = 1
    ...           NRBTS.NRMEASCFG_IF_5.a4MeasHigherPrioFreqEnabled = 4            Priority = 4

    ...           NRBTS.NRCELL.NRHOIF_1.a4MeasHigherPrioFreqEnabled = 1            Priority = 1
    ...           NRBTS.NRCELL.NRHOIF_3.a4MeasHigherPrioFreqEnabled = 1            Priority = 1
    ...           NRBTS.NRCELL.NRHOIF_4.a4MeasHigherPrioFreqEnabled = 2            Priority = 4
    ...           NRBTS.NRCELL.NRHOIF_5.a4MeasHigherPrioFreqEnabled = 2            Priority = 20

    ...           from NRMEASCFG_IF
    ...           IF_1.a4MeasHigherPrioFreqEnabled = 1       Priority = 2             measID = 1
    ...           IF_3.a4MeasHigherPrioFreqEnabled = 3       Priority = 20            measID = 3/4
    ...           IF_5.a4MeasHigherPrioFreqEnabled = 4       Priority = 4             measID = 2

    ...    3. Test Case Steps:
    ...         a. UE registers successfully without PDU session is setup successfully on cell 1.
    ...         b. Trigger meas_id = 2,3,4 within first SupervisionTimer(a4RetryTimer = 10s)
	...         c. HO is excuted after A4 MG (meas_id = 2) is trigged.
    ...         d. Trigger A3 MG and HO back to cell1.
    ...         e. HO is excuted successful.
    ...         f. UE deregister should be successfully.
    ...     4. Expect result:
    ...          a. PDU session is setup successfully, and start retry timer, check A4/MG configured correctly in
    ...          rrc reconfiguration msg after retryTimer expire
    ...          b. A4 meas(1,2,3,4) is configged, gapUE setup, drx release after retry timer timeout
    ...          c. HO is triggered after supervisionTimer timeout, A4 meas is released, gapUE is release, drx is setup
    ...          d. HO is trigged successful
    ...          e. A4 meas(1,2,3,4) is configged, gapUE setup, drx release after retry timer timeout
    ...          f. UE deregister is successfully
	[Tags]    QC_191773    owner-christine.chen    C009
    Clear Counter and XN setup
    UE Attach To Target Cell    cell_id=1
	Send And Verify Throuput
	Trigger A4 HO    ${Cell2_phycellid}    3    4    1s    2.1    3.1
	Verify Throuput
	Send Single A3 MR to Trigger A3 HO    ${Cell1_phycellid}    1    3.1    2.1
	Verify Throuput
	UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C009${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    ${PM_Counters_Check_C009}
    [Teardown]    Recover Env And Test Teardown with recover for C009

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Clear Counter and XN setup
    Clear Counter Files
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=3 reset
    Execute Egate Command    gnb_xn_setup_param id=3 reset
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2

UE Attach To Target Cell
    [Arguments]    ${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Delta Commission Parameters    ${OnlineParam_for_C009}
    Update UE capa    ${SA_Capa_Support_FR2_with_independent_gap}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Verify Throuput
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=6s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    Verify Throuput

Trigger A4 HO
    [Arguments]    ${phycell_id}    ${meas_id1}    ${meas_id2}    ${sleeptime}    ${source_cell}    ${target_cell}
	Sleep    ${sleeptime}    #wait for first retrytimer and supervisiontimer timeout
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id1} event=A4 phycell_id=60 nrsrp_nr=50
    Execute Egate Command    ${cmd}    measResultNeighCells measResultListNR
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id1} event=A4 phycell_id=51 nrsrp_nr=50
    Execute Egate Command    ${cmd}    measResultNeighCells measResultListNR
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id2} event=A4 phycell_id=${phycell_id} nrsrq_nr=50
    Execute Egate Command    ${cmd}    Inter-eNB handover from EXT_ENB-${source_cell} to ENB-${target_cell} performed
    Execute Egate Command    ue_disp

Send Single A3 MR to Trigger A3 HO
    [Arguments]    ${phycell_id}    ${meas_id1}    ${source_cell}    ${target_cell}
	${cmd}    catenate    ue_measurement_send_nr event=A3 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=${meas_id1}
	Execute Egate Command    ${cmd}    Inter-eNB handover from ENB-${source_cell} to EXT_ENB-${target_cell} performed

UE Deregister From gNB
    [Arguments]    ${ue_id}
	Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
	
Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Recover Env And Test Teardown with recover for C009
    Delta Commission Parameters    ${OnlineParam_for_C009_recover}
    Update UE capa    ${SA_Capa_perUE_Full}
    Common Test Teardown And Stop Capture Logs

