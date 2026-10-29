*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-liupei.fang
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
${RECREATE_WIRESHARK_FLAG}    ${false}
@{PARAMS_IN_SCF}
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1:timerRRCGuard=6000
...    @{Meas_Config}
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

@{Meas_Config}
#Cell-1: A1,A3 for interfreq HO
#cell-2: A4
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min

...    NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=50
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL-1:a3MeasEnabled=none
...    NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40

...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4RetryTimer=120
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=10

...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=513150
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=1

...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=11

...    NRCELL-2/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-2/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=22
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=424090

...  NRADJNRCELL-1:physCellId=381

...    NRCELL-1:measGapSelection=favourUeThroughput
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=126750
...    NRCELL-1/NRHOIF-2:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=22
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=22
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=633216
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=23
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=20
...    NRCELL-1/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-4:ssbFrequency=424090
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4ThresholdSsbRsrp=24
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-4:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-5:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-5:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-5:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-5:ssbFrequency=127450
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=25
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=4
...    NRCELL-1/NRHOIF-6:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-6:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-6:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-6:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-6:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-6:ssbFrequency=126770
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4ThresholdSsbRsrp=26
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-6:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-1/NRHOIF-7:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-7:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-7:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-7:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-7:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-7:ssbFrequency=518670
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4ThresholdSsbRsrp=27
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-7:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-14/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-14/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-14/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-2:ssbFrequency=518910
...    NRCELL-14/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-14/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-14/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=32
...    NRCELL-14/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-14/NRHOIF-2:a4PriorityForHigherPrioFreqHo=10
...    NRCELL-14/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-10:gNbId=1
...    NRCELL-14/NRREL-10:gNbIdLength=22
...    NRCELL-14/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-10:removeNotAllowed=false
...    NRCELL-14/NRREL-10:lcrId=1

@{Mobility_Profile_Config}
...    NRBTS-1:actMobilityProfile=false
...    NRBTS-1:actRanSharing=true
...    delete:NRBTS-1/NRCELL-1:configuredEpsTac
...    delete:NRBTS-1/NRCELL-2:configuredEpsTac
...    delete:NRBTS-1/NRCELL-11:configuredEpsTac
...    delete:NRBTS-1/NRCELL-12:configuredEpsTac
...    delete:NRBTS-1/NRCELL-13:configuredEpsTac
...    delete:NRBTS-1/NRCELL-14:configuredEpsTac
...    delete:NRBTS-1/NRCELL-1:trackingAreaDN
...    delete:NRBTS-1/NRCELL-2:trackingAreaDN
...    delete:NRBTS-1/NRCELL-11:trackingAreaDN
...    delete:NRBTS-1/NRCELL-12:trackingAreaDN
...    delete:NRBTS-1/NRCELL-13:trackingAreaDN
...    delete:NRBTS-1/NRCELL-14:trackingAreaDN
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:measGapSelection=favourUeThroughput
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:measGapSelection=favourUeThroughput
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:measGapSelection=favourUeThroughput
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRCELL-13:measGapSelection=favourUeThroughput
...    NRCELL-14:measGapSelectionSA=favourUeThroughput
...    NRCELL-14:measGapSelection=favourUeThroughput
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=424090
...    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=24
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=24
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=424090
...    NRCELL-13/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=24
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-13/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-14/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-1:ssbFrequency=424090
...    NRCELL-14/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=24
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-14/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=53
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-2:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-2:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-2:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80
...    NRCELL-11:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-11:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-11:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-11:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRCELL-11:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL-11:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80
...    NRCELL-12:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-12:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-12:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-12:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRCELL-12:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL-12:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80
...    NRCELL-13:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-13:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-13:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-13:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-13:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-13:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-13:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRCELL-13:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL-13:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-13:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL-13:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL-13:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80
...    NRCELL-14:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-14:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-14:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-14:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-14:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-14:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-14:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRCELL-14:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL-14:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-14:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL-14:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL-14:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80
...    NRBTS-1/NRMOPR_NSA-1
...    NRBTS-1/NRMOPR_NSA-1:a3MeasEnabled=none
...    NRBTS-1/NRMOPR_SA-1:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-1:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-1:a2MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-1:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-1:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-1:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-1:nrMeasCfgIfDNList=MRBTS-1/NRBTS-1/NRMEASCFG_IF-1
...    NRBTS-1/NRMOPR_SA-2:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-2:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-2:a2MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-2:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-2:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-2:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-2:nrMeasCfgIfDNList=MRBTS-1/NRBTS-1/NRMEASCFG_IF-1,MRBTS-1/NRBTS-1/NRMEASCFG_IF-2,MRBTS-1/NRBTS-1/NRMEASCFG_IF-3
...    NRBTS-1/NRMOPR_SA-3:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-3:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-3:a2MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-3:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-3:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-3:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-3:nrMeasCfgIfDNList=MRBTS-1/NRBTS-1/NRMEASCFG_IF-4
...    NRCELL-1/NRPLMNSET_SA-1
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    NRCELL-1/NRPLMNSET_NSA-1
...    NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-2/NRPLMNSET_SA-1
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    NRCELL-2/NRPLMNSET_NSA-1
...    NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-11/NRPLMNSET_SA-1
...    NRCELL-11/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-11/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    NRCELL-11/NRPLMNSET_NSA-1
...    NRCELL-11/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL-11/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-12/NRPLMNSET_SA-1
...    NRCELL-12/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-12/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    NRCELL-12/NRPLMNSET_NSA-1
...    NRCELL-12/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL-12/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-13/NRPLMNSET_SA-1
...    NRCELL-13/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-13/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    NRCELL-13/NRPLMNSET_NSA-1
...    NRCELL-13/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL-13/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-14/NRPLMNSET_SA-1
...    NRCELL-14/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-14/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    NRCELL-14/NRPLMNSET_NSA-1
...    NRCELL-14/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL-14/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRMEASCFG_IF-1
...    NRBTS-1/NRMEASCFG_IF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=20
...    NRBTS-1/NRMEASCFG_IF-1:freqBandIndicatorNR=66
...    NRBTS-1/NRMEASCFG_IF-1:ssbFrequency=424090
...    NRBTS-1/NRMEASCFG_IF-2
...    NRBTS-1/NRMEASCFG_IF-2:a4MeasHigherPrioFreqEnabled=none
...    NRBTS-1/NRMEASCFG_IF-2:a4PriorityForHigherPrioFreqHo=3
...    NRBTS-1/NRMEASCFG_IF-2:freqBandIndicatorNR=66
...    NRBTS-1/NRMEASCFG_IF-2:ssbFrequency=427970
...    NRBTS-1/NRMEASCFG_IF-3
...    NRBTS-1/NRMEASCFG_IF-3:a4MeasHigherPrioFreqEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-3:a4PriorityForHigherPrioFreqHo=2
...    NRBTS-1/NRMEASCFG_IF-3:freqBandIndicatorNR=71
...    NRBTS-1/NRMEASCFG_IF-3:ssbFrequency=126750
...    NRBTS-1/NRMEASCFG_IF-4
...    NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-4:a4PriorityForHigherPrioFreqHo=1
...    NRBTS-1/NRMEASCFG_IF-4:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-4:ssbFrequency=518910
...    NRCELL-1:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-1:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-2
...    NRCELL-2:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-2:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-1
...    NRCELL-11:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-11:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-1
...    NRCELL-12:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-12:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-1
...    NRCELL-13:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-13:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-1
...    NRCELL-14:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-14:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-3

@{OnlineParam_for_C021}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=5
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=8
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp

@{OnlineParam_for_C008}
#Handover parameter
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS-1:actMobilityProfile=true
...    NRCELL-1:a3MeasEnabled=none
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=427970
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=21
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-1/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1:actCDrx=true
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:lcrId=14

@{PM_Counters_Check_C008}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-14/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-14/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1:${NRMOP_SA_PROFILE_SELECTED_02}=2
...    NRCELL-14:${NRMOP_SA_PROFILE_SELECTED_03}=1
...    NRBTS-1:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRBTS-1:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=2

${A4_IEF_IADU_HO_EX_ATT_SA}       M55184C00003
#This counter measures the number of A4 triggered handover execution attempts
#related to inter-frequency Intra-gNB Intra-DU handover for SA.
${A4_IEF_IADU_HO_EX_SUC_SA}       M55184C00004
#This counter measures the number of A4 triggered successful handover execution attempts
#related to inter-frequency Intra-gNB Intra-DU handover for SA.
${NRMOP_SA_PROFILE_SELECTED_02}       M55157C00034
#IntragNB or IntergNB Mobility Profile Updated when SA mobility profile 2 is selected after an initial access or #after an handover.
${NRMOP_SA_PROFILE_SELECTED_03}       M55157C00035
#IntragNB or IntergNB Mobility Profile Updated when SA mobility profile 2 is selected after an initial access or #after an handover.
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550
#Attempted Inter-Frequency Intra-gNBIntra-DU HO per PLMN, per slice
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551
#Successful Inter-Frequency Intra-gNBIntra-DU HO, per PLMN, per slice

${SA_Capa_combination_support_CA_not_Support}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E0028830288230010461814410400823070A000003823071040000402307118000040200E0234
...    028809B01043D00F40B0A244D8E7C3851226C73E1C2810360000214081B000010A040D80000002C146318C607A09801E00140E0A00E06012
...    80380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018010000
...    0E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B
...    036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA4808
...    00044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A9345
...    5018AA051549AAA83C5090178095028140A05028140A05028140A05028140A05028140020202018030080100210100200804030061008010
...    0202018030080600C10100C018040300610080100202018030080100220100C01804030060100C0182020040100801004001002008002018
...    030D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${ue_id}    81
${pdu_id}    1
${gw_id}    1

*** Test Cases ***
CB007517-ET-C021_Verify_A4_measurements_configured_successfully_after_incoming_Xn_based_Inter_freq_Inter_gnb_handover_with_Intra_cell_HO
    [Documentation]
    ...    1. This user scenario describes the target gNB behaviour, when the target gNB receives a XnAP:Handover Request
	...       after handover success. Then starts the a4RetryTimer. Upon expiry of this timer inter-freq A4
	...       measurements for mobility to higher priority NR frequency shall be configured.
    ...    2. Configuration
    ...         a.NRREL,NRADJNRCELL,NRHOIF configuration on cell
    ...           Measurement: A1,A2,A3 config on cell-1,A4 config on cell-2
    ...           DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Trigger HO from gnb-2 cell-1 to simGNB-3 cell-1 should be successfully.
    ...         c. Trigger HO from simGNB-3 cell-1 to gnb-2 Cell-2 should be successfully.
	...         d. wait until retrytimer expiry , A4 RRC's time slot-RRC's DRX time slot =a4RetryTimer
    ...         e. UE deregister should be successfully.
    [Tags]    QC_198815    owner-liupei.fang    C021
	OnlineParamChange    ${OnlineParam_For_C021}
	Trigger Xn Setup From Remote GNB
	UE Attach To Target Cell    cell_id=1    nwslice=1
	Send And Verify Throuput
	Trigger A3 Measurement Report HO to simGNB
	Trigger A3 HO back with AMF sending New Security Context Indicator in NGAP
	Verify Throuput
	UE Deregister From gNB    ue_id=${ue_id}
	Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C021${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB007517-ET-C008_Inter-freq_Intra-DU_HO_succeed_immediately_with_A4_MR_with_highest_prio_received_non-first_circulation
    [Documentation]
	...   1.The purpose of this test case is to check inter-frq HO will be succeed immediately with A4 MR with highest
	...     prio received non-first circulation after ICS and loop handover
	...   2.Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. wait second retrytimer starting.
    ...         c. send MR and trigger HO from cell1 to cell14 in non-first  circulation.
	...         d. send MR and trigger HO from cell14 to cell1 in non-first  circulation.
    ...    3. Expected Results:
    ...         Step a: PDU setup successfully.
    ...                 IE: on wireshark log:
    ...                 drx-Config = 1
    ...                 measIdToAddModList = 2
    ...                 eventId == 3
    ...                 rsrq = 22
    ...                 eventId == 3
    ...                 rsrp = 24
    ...                 gapUE = 1
    ...                 drx-Config = 0
    ...         Step b: wait second retrytimer starting.
    ...                 IE: on wireshark log:
    ...                 drx-Config = 1
    ...                 measIdToAddModList = 2
    ...                 eventId == 3
    ...                 rsrq = 22
    ...                 eventId == 3
    ...                 rsrp = 24
    ...                 gapUE = 1
    ...                 drx-Config = 0
    ...         Step c: trigger HO from cell1 to cell14.
    ...                 IE: on wireshark log:
    ...                 physCellId = 63
    ...                 measIdToAddModList = 1
    ...                 eventId == 3
    ...                 rsrp = 32
    ...                 gapUE = 1
    ...         Step d: trigger HO from cell14 to cell1.
    ...                 IE: on wireshark log:
    ...                 physCellId = 50
    ...                 drx-Config = 1
    ...                 measIdToAddModList = 2
    ...                 eventId == 3
    ...                 rsrq = 22
    ...                 eventId == 3
    ...                 rsrp = 24
    ...                 gapUE = 1
    ...                 drx-Config = 0
	[Tags]    C008    owner-jia.pan    QC_190605
    OnlineParamChange    ${OnlineParam_For_C008}
	Clear Counter Files
    inter-frq intra-DU HO succeed immediately with A4 MR with highest prio    1
	UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C008${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_Check_C008}

*** Keywords ***
inter-frq intra-DU HO succeed immediately with A4 MR with highest prio
    [Arguments]    ${cell_id}=1
    UE Attach To Target Cell with UE modify    ${cell_id}
    Send And Verify Throuput
    Triger inter-frq intra-DU HO from cell1 to cell14
    Verify Throuput
    Triger inter-frq intra-DU HO from cell14 to cell1
    Verify Throuput And Wait A4 Configuration

Triger inter-frq intra-DU HO from cell1 to cell14
    sleep    20    reason=wait second retrytimer starting
    Execute Egate Command    ue_measurement_send_nr event=A4 phycell_id=60 nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=2    EGATE>
    Execute Egate Command    ue_measurement_send_nr event=A4 phycell_id=60 nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=2    EGATE>
    Execute Egate Command    ue_measurement_send_nr event=A4 phycell_id=63 nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=1
    ...    CTRL_RACH_COMPLETE Received

Triger inter-frq intra-DU HO from cell14 to cell1
    Execute Egate Command    ue_measurement_send_nr event=A4 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80 id=${ue_id} meas_id=1
    ...    CTRL_RACH_COMPLETE Received

UE Attach To Target Cell with UE modify
    [Arguments]    ${cell_id}
    Update UE capa    ${SA_Capa_combination_support_CA_not_Support}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}    EGATE>
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}    EGATE>

Common Suite Setup And Setup Airphone Env
	Common Suite Setup
	Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
	Delta Commission Parameters    ${Online_Param}
	Cells Should Be Onair    check_sib=${False}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${nwslice}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}    EGATE>
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Trigger A3 Measurement Report HO to simGNB
    [Arguments]   ${target_cell_id}=381
	Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
	Execute Egate Command
	...   ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11
	...   pass_regexp=rrcReconfigurationComplete
	Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
	${ret1}=  Execute Egate Command
	...   ue_measurement_send_nr id=${ue_id} meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${target_cell_id} nrsrp_nr=80 nrsrq_nr=80
	...   pass_regexp=rrcReconfigurationComplete

Verify Throuput And Wait A4 Configuration
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=5s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    sleep    5    reason=wait retrytimer expire

Verify Throuput
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70    EGATE>
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10    EGATE>
    Verify Throuput


Trigger A3 HO back with AMF sending New Security Context Indicator in NGAP
   [Arguments]    ${target_cell_id}=51
   Execute Egate Command     ue_reauth id=${ue_id} nr_sec_cap=aes|aes
   Execute Egate Command     amf_path_switch_param id=1 include_ue_sec_cap=on
   Execute Egate Command     smf_param id=1 security_indication=path_switch:preferred:preferred max_data_rate=6mbps
   Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
   Execute Egate Command
   ...   ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=4 srsrq_nr=11
   ...   pass_regexp=rrcReconfigurationComplete
   Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
   ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A3
   ${ret1}=  Execute Egate Command
   ...   ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${target_cell_id} nrsrp_nr=80 nrsrq_nr=80
   ...   pass_regexp=EGATE>   sleep_time=10


UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Modify Cfg
    [Arguments]     ${gnb_id}=3
    Update Cfg    gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=true
    Update Cfg    amf_param id=1 full_nas_auth=on nia=snow3g+zuc+aes nea=null+snow3g+zuc+aes
    ${C_1}    catenate
    ...   set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999
    ...   nr_arfcn=513234:513234 gscn=6414 mandatory_for_activation=off
    Update Cfg     ${C_1}

Trigger Xn Setup From Remote GNB
    [Arguments]    ${gnb_id}=3
    Execute Egate Command    gnb_param id=${gnb_id} send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=${gnb_id} target=2    GNB-${gnb_id}: XnAP Link with GNB-2
    Execute Egate Command
    ...  ue_history_information_list_add_ngran id=2 cell_type=large nrcgi=311:489|0x01 gnb_id=1 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...  ue_history_information_list_add_ngran id=2 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=98
    Execute Egate Command  ue_history_information_list id=2 action=commit
    Execute Egate Command  ue_enb_param id=2 ue_history_list=2
