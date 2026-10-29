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
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-2:actCDrx=true
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


${MEASCFG_list}    SEPARATOR=
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1,MRBTS-1/NRBTS-1/NRMEASCFG_IF-2,MRBTS-1/NRBTS-1/NRMEASCFG_IF-3,
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-4,MRBTS-1/NRBTS-1/NRMEASCFG_IF-5,MRBTS-1/NRBTS-1/NRMEASCFG_IF-6,
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-7

@{A4_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
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
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
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
...    NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=2
...    NRBTS-1/NRMEASCFG_IF-1:freqBandIndicatorNR=257
...    NRBTS-1/NRMEASCFG_IF-1:ssbFrequency=2079163
...    NRBTS-1/NRMEASCFG_IF-2
...    NRBTS-1/NRMEASCFG_IF-2:a4MeasHigherPrioFreqEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-2:a4PriorityForHigherPrioFreqHo=20
...    NRBTS-1/NRMEASCFG_IF-2:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-2:ssbFrequency=518910
...    NRBTS-1/NRMEASCFG_IF-3
...    delete:NRBTS-1/NRMEASCFG_IF-3:a4MeasHigherPrioFreqEnabled
...    NRBTS-1/NRMEASCFG_IF-3:a4PriorityForHigherPrioFreqHo=20
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

@{OnlineParam_For_C052}
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=8000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=30
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=12
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRBTS-1/NRCELL-2:actCDrx=true
...    NRBTS-1/NRCELL-12:actCDrx=true
...    NRBTS-1/NRCELL-12:a3MeasEnabled=rsrp
...    @{Mobility_Profile_Config_forNRCELL12}
...    @{OnlineParam_Update_Othercell}
...    @{A1_A2_Meas_enable_for_NRCELL12}
...    @{A1_A2_Meas_enable_for_NRCELL2}
...    @{NRHOIF_for_NRCELL2}

@{OnlineParam_Update_Othercell}
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=9
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3OffsetSsbRsrp=9
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40

@{OnlineParam_For_enable_NRMEASCFG_2_6}
...    NRBTS-1/NRMEASCFG_IF-2:a4MeasHigherPrioFreqEnabled=rsrpCombined
...    NRBTS-1/NRMEASCFG_IF-6:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=50

@{OnlineParam_For_enable_NRMEASCFG_1_7}
...    NRBTS-1/NRMEASCFG_IF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-7:a4MeasHigherPrioFreqEnabled=rsrpAndRsrq

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
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=518910
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrq
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
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
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-2:ssbFrequency=633216
...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=9
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
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
...    NRCELL-12/NRHOIF-11:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12/NRHOIF-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=9
...    NRCELL-12/NRHOIF-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-11:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...    NRCELL-12/NRHOIF-11:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL-12/NRHOIF-11:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
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

@{NRHOIF_for_NRCELL2}
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

@{Mobility_Profile_Config_forNRCELL12}
...    NRBTS-1/NRMEASCFG_IF-1
...    NRBTS-1/NRMEASCFG_IF-1:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-1:a4MeasHigherPrioFreqEnabled=none
...    NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=2
...    NRBTS-1/NRMEASCFG_IF-1:freqBandIndicatorNR=257
...    NRBTS-1/NRMEASCFG_IF-1:ssbFrequency=2079163
...    NRBTS-1/NRMEASCFG_IF-2
...    NRBTS-1/NRMEASCFG_IF-2:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-2:a4MeasHigherPrioFreqEnabled=none
...    NRBTS-1/NRMEASCFG_IF-2:a4PriorityForHigherPrioFreqHo=3
...    NRBTS-1/NRMEASCFG_IF-2:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-2:ssbFrequency=518910
...    NRBTS-1/NRMEASCFG_IF-3
...    NRBTS-1/NRMEASCFG_IF-3:a3MeasEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-3:a4PriorityForHigherPrioFreqHo=3
...    NRBTS-1/NRMEASCFG_IF-3:freqBandIndicatorNR=78
...    NRBTS-1/NRMEASCFG_IF-3:ssbFrequency=633216
...    NRBTS-1/NRMEASCFG_IF-4
...    NRBTS-1/NRMEASCFG_IF-4:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-4:a4PriorityForHigherPrioFreqHo=34
...    NRBTS-1/NRMEASCFG_IF-4:freqBandIndicatorNR=66
...    NRBTS-1/NRMEASCFG_IF-4:ssbFrequency=424090
...    NRBTS-1/NRMEASCFG_IF-5
...    NRBTS-1/NRMEASCFG_IF-5:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-5:a4MeasHigherPrioFreqEnabled=rsrqCombined
...    NRBTS-1/NRMEASCFG_IF-5:a4PriorityForHigherPrioFreqHo=35
...    NRBTS-1/NRMEASCFG_IF-5:freqBandIndicatorNR=66
...    NRBTS-1/NRMEASCFG_IF-5:ssbFrequency=427970
...    NRBTS-1/NRMEASCFG_IF-6
...    NRBTS-1/NRMEASCFG_IF-6:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-6:a4MeasHigherPrioFreqEnabled=none
...    NRBTS-1/NRMEASCFG_IF-6:a4PriorityForHigherPrioFreqHo=20
...    NRBTS-1/NRMEASCFG_IF-6:freqBandIndicatorNR=257
...    NRBTS-1/NRMEASCFG_IF-6:ssbFrequency=2071675
...    NRBTS-1/NRMEASCFG_IF-7
...    NRBTS-1/NRMEASCFG_IF-7:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-7:a4MeasHigherPrioFreqEnabled=none
...    NRBTS-1/NRMEASCFG_IF-7:a4PriorityForHigherPrioFreqHo=30
...    NRBTS-1/NRMEASCFG_IF-7:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-7:ssbFrequency=513150
...    NRBTS-1/NRMOPR_SA-12:a1MeashoEnabledSA=rsrq
...    NRBTS-1/NRMOPR_SA-12:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-12:a2MeashoEnabledSA=rsrq
...    NRBTS-1/NRMOPR_SA-12:a3MeasEnabled=none
...    NRBTS-1/NRMOPR_SA-12:a5MeasEnabled=none
...    NRBTS-1/NRMOPR_SA-12:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-12:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-12:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-12:nrMeasCfgIfDNList=${MEASCFG_list}
...    NRCELL-12:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-12

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

@{PM_Counters_Check_C052}
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
CB007517-ET-C052_A4_deconfigured_after_A2_then_A1_with_A4_HO_with_multi_A4_with_diff_and_same_low_prio_diff_high_mobilityProfile
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios: A4 deconfigured for first circulation after
    ...     receiving inter-freq A2 MR and keep deconfigured until receiving A1 MR and keep circulation without receiving
    ...     A4 MR then during A4 active receiving inter-freq A2 MR then A1 MR then A4 MR before reach maxNum and
    ...    inter-frq intra-DU HO succeed at last with multi A4 MR with diff and same low prio diff high received after ICS
    ...    (UEcapaperFR_A4MGperUE_interfreqA2Target7FR1FR2)
    ...    (ICS_optimized__DRX__CA_Ue+_gNB_turnoff__actHigherPrioFreqHo_SA+NSA__
    ...    A4_target7_FR1FR2__UEcapaPerFR__priority_somesame__MobilityProfile)(2 common NRHOIF: A3 A4)
    ...    2. Configuration
    ...    a.configuration on cell 12
    ...    mobility profile configuration:
    ...    NRMEASCFG_IF-1 freqband 257 ssb 2079163 HigherPrio 2 FreqEnabled none_3_rsrp
    ...    NRMEASCFG_IF-2 freqband 41 ssb 518910 HigherPrio 20 FreqEnabled none_2_rsrpCombined
    ...    NRMEASCFG_IF-3 freqband 78 ssb 633216 HigherPrio 3 FreqEnabled rsrp
    ...    NRMEASCFG_IF-4 freqband 66 ssb 424090 HigherPrio 34 FreqEnabled rsrp
    ...    NRMEASCFG_IF-5 freqband 66 ssb 427970 HigherPrio 35 FreqEnabled rsrqCombined
    ...    NRMEASCFG_IF-6 freqband 257 ssb 2071675 HigherPrio 20 FreqEnabled none_2_rsrq
    ...    NRMEASCFG_IF-7 freqband 41 ssb 513150 HigherPrio 30 FreqEnabled none_3_rsrpAndRsrq
    ...    NRHOIF configuration:
    ...    NRHOIF-10 freqband 257 ssb 2079163 HigherPrio 1 FreqEnabled rsrp a4Rsrp 20 a4Rsrq 21 a3MeasEnabled none
    ...    NRHOIF-1 freqband 41 ssb 518910 HigherPrio 7 FreqEnabled rsrp a4Rsrp 34 a4Rsrq 20 a3MeasEnabled rsrq
    ...    NRHOIF-2 freqband 78 ssb 633216 HigherPrio 30 FreqEnabled rsrpCombined a4Rsrp 20 a4Rsrq 22 a3MeasEnabled rsrp
    ...    NRHOIF-11 freqband 66 ssb 424090 HigherPrio 2 FreqEnabled rsrp a4Rsrp 45 a4Rsrq none a3MeasEnabled none
    ...    NRHOIF-13 freqband 66 ssb 427970 HigherPrio 25 FreqEnabled rsrpAndRsrq a4Rsrp 15 a4Rsrq 23 a3MeasEnabled none
    ...    NRHOIF-27 freqband 257 ssb 2071675 HigherPrio 6 FreqEnabled rsrp a4Rsrp 15 a4Rsrq 23 a3MeasEnabled none
    ...    NRHOIF-28 freqband 41 ssb 513150 HigherPrio 3 FreqEnabled rsrp a4Rsrp 21 a4Rsrq 23 a3MeasEnabled none
    ...    DRX: enable
    ...    b.configuration on cell 2
    ...    NRBTS.NRCELL.NRHOIF_1.a4MeasHigherPrioFreqEnabled rsrp Priority = 7
    ...    DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 12. throughput should be OK
    ...         b. after first a4retrytimer expire, eventA4 config, and when first a4supervison expire, eventA4 deconfig
    ...         c. after second a4retrytimer expire, eventA4 config, and enable 2 Freq for A4, and when second
    ...            a4supervison expire, eventA4 deconfig
    ...         d. after third a4retrytimer expire, two more eventA4 config, and during third
    ...            a4supervison, trigger A2MR, no a4 will configure as A1A3 configure
    ...         e. after third a4retrytimer timer expire, will restart a4retrytimer timer, and then trigger A1MR
    ...            and enable 2 Freq for A4
    ...         f. after the retry a4retrytimer timer expire, check A4 event config contain new add two Freq
    ...         g. during the fourth a4supervison, trigger N A4 MR, and HO to cell-2, throughput should be OK
    ...         h. on Target cell2, when first a4retrytimer timer expire, eventA4 configure
    ...         i. UE deregister should be successfully.
    [Tags]    QC_194093    owner-dandan.chen    C052
    Clear Counter Files
    OnlineParamChange For Case C052
    UE Attach To Target Cell    12    ${SA_Capa_Support_FR2_perFR}
    Send And Verify Throughput
    Check A4 timer working after Ue attach
    Trigger A2 On Third Supervison And Then Trigger A1 To Deconfig A1A3
    Trigger N Duplicated Low Prio A4 On Third Supervison Timer To Do HO
    UE Deregister From gNB    ue_id=${ue_id}
    Check Counters    ${PM_Counters_Check_C052}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C052${/}a2a.ini    wait_string=UEContextRelease::12

*** Keywords ***
OnlineParamChange For Case C052
    OnlineParamChange    ${NRREL_for_NRCELL12}
    OnlineParamChange    ${NRHOIF_for_NRCELL12}
    OnlineParamChange    ${OnlineParam_For_C052}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Check A4 timer working after Ue attach
    Check Measid After Fist A4retrytimer Expire
    Check Measid After Fist A4Fr1SupervisionTimer Expire
    Check Measid After Second A4retrytimer Expire
    Enable 2A4 Freq and Check Measid After Second A4Fr1SupervisionTimer start and before Third A4retrytimer Expire
    Check Measid After Third A4retrytimer Expire

Trigger A2 On Third Supervison And Then Trigger A1 To Deconfig A1A3
    Trigger A2MR During Third A4Fr2SupervisionTimer
    Check No EventA4 Config When Third A4Fr2SupervisionTimer Expire
    Wait Fourth A4retrytimer Expire And No EventA4 Config As A1A3 Config
    Fourth A4retrytimer Expire And Restart And Trigger A1MR Before Expire Then A1A3 Deconfig

Trigger N Duplicated Low Prio A4 On Third Supervison Timer To Do HO
    Trigger N A4 Duplicate Low Prio MR During Third A4Fr2SupervisionTimer Then HO Happen Later
    After A4retrytimer Expire On Target Cell A4 Configure
    Verify Throughput

Check Measid After Fist A4retrytimer Expire
    sleep    24s    reason=wait Fist A4retrytimer Expire
    ${list_of_query_conditions}    Create List
    ${query1}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    ${query2}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F424090}    event_type=A4
    ${query3}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F427970}    event_type=A4
    Append To List    ${list_of_query_conditions}    ${query1}    ${query2}    ${query3}
    ${meas_ids}=    Get Nr Meas Ids For Specific Type And Frequency    list_of_query_conditions=${list_of_query_conditions}
    Should Be True    ${meas_ids[0]}<${meas_ids[1]}<${meas_ids[2]}

Check Measid After Fist A4Fr1SupervisionTimer Expire
    sleep    5s    reason=wait Fist A4Fr2SupervisionTimer Expire

Check Measid After Second A4retrytimer Expire
    sleep    30s    reason=wait Second A4retrytimer Expire
    ${list_of_query_conditions}    Create List
    ${query1}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    ${query2}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F424090}    event_type=A4
    ${query3}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F427970}    event_type=A4
    Append To List    ${list_of_query_conditions}    ${query1}    ${query2}    ${query3}
    ${meas_ids}=    Get Nr Meas Ids For Specific Type And Frequency    list_of_query_conditions=${list_of_query_conditions}
    Should Be True    ${meas_ids[0]}<${meas_ids[1]}<${meas_ids[2]}
	sleep    7s    reason=wait Second A4retrytimer Expire
	Run Keyword And Ignore Error    Get Nr Meas Ids For Specific Type And Frequency    list_of_query_conditions=${list_of_query_conditions}

Enable 2A4 Freq and Check Measid After Second A4Fr1SupervisionTimer start and before Third A4retrytimer Expire
    OnlineParamChange    ${OnlineParam_For_enable_NRMEASCFG_2_6}

Check Measid After Third A4retrytimer Expire
    #sleep    44s    reason=wait Third A4retrytimer expire
    ${list_of_query_conditions}    Create List
    ${query1}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    ${query2}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F424090}    event_type=A4
    ${query3}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F427970}    event_type=A4
    Append To List    ${list_of_query_conditions}    ${query1}    ${query2}    ${query3}
	Wait Until Keyword Succeeds    52s    1s    Get Nr Meas Ids For Specific Type And Frequency
    ...    list_of_query_conditions=${list_of_query_conditions}	

Trigger A2MR During Third A4Fr2SupervisionTimer
    ${m126750}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F126750}    event_type=A2
    ${ret}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m126750} event=A2 srsrp_nr=20 srsrq_nr=20
    ...    pass_regexp=eventId eventA3
   Should not Contain    ${ret}    gapFR1

Check No EventA4 Config When Third A4Fr2SupervisionTimer Expire
    sleep    6s    reason=wait Second A4Fr2SupervisionTimer expire

Wait Fourth A4retrytimer Expire And No EventA4 Config As A1A3 Config
    sleep    50s    reason=wait Third A4retrytimer Expire

Fourth A4retrytimer Expire And Restart And Trigger A1MR Before Expire Then A1A3 Deconfig
    sleep    10s    reason=wait Third A4retrytimer
    ${m126750}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F126750}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m126750} event=A1 srsrp_nr=110 srsrq_nr=110
    ...    pass_regexp=gapFR1 release
    OnlineParamChange    ${OnlineParam_For_enable_NRMEASCFG_1_7}

Trigger N A4 Duplicate Low Prio MR During Third A4Fr2SupervisionTimer Then HO Happen Later
    Get Query list
    Wait Until Keyword Succeeds    62s    1s    get a4 measid successful
    Should Be True    ${meas_ids[0]}<${meas_ids[1]}<${meas_ids[2]}<${meas_ids[3]}<${meas_ids[4]}<${meas_ids[5]}<${meas_ids[6]}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[6]} event=A4 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[1]} event=A4 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[2]} event=A4 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[2]} event=A4 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    sleep    6s    reason=wait Third A4Fr2SupervisionTimer expire

Get Query list
    ${list_of_query_conditions}    Create List
    ${query1}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F2079163}    event_type=A4
    ${query2}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A4
    ${query3}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    ${query4}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F2071675}    event_type=A4
    ${query5}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F513150}    event_type=A4
    ${query6}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F424090}    event_type=A4
    ${query7}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F427970}    event_type=A4
    Append To List    ${list_of_query_conditions}    ${query1}    ${query2}    ${query3}    ${query4}
    ...    ${query5}    ${query6}    ${query7}
    Set Test Variable    ${list_of_query_conditions}

get a4 measid successful
    ${meas_ids}=    Get Nr Meas Ids For Specific Type And Frequency    list_of_query_conditions=${list_of_query_conditions}
    Set Test Variable    ${meas_ids}
    
After A4retrytimer Expire On Target Cell A4 Configure
    sleep    13s    reason=wait Fist A4retrytimer Expire
    ${m518910}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A4

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
