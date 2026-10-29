*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Jazz_SGT&A    owner-Delun.li
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
...    @{CA_Config}
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
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1,MRBTS-1/NRBTS-1/NRMEASCFG_IF-3,
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-4,MRBTS-1/NRBTS-1/NRMEASCFG_IF-5,MRBTS-1/NRBTS-1/NRMEASCFG_IF-6

@{OnlineParam_C051}
...    NRBTS-1/NRMOPR_SA-1:nrMeasCfgIfDNList=MRBTS-1/NRBTS-1/NRMEASCFG_IF-5
...    NRBTS-1/NRMEASCFG_IF-1:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-4:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-5:a3MeasEnabled=rsrpAndRsrq
...    NRBTS-1/NRMEASCFG_IF-6:a3MeasEnabled=rsrqCombined

@{OnlineParam_C051_recover}
...    NRBTS-1/NRMOPR_SA-1:nrMeasCfgIfDNList=${MEASCFG_list}
...    NRBTS-1/NRMEASCFG_IF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-4:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-5:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-6:a3MeasEnabled=none

@{A4_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=10
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
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
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
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=14
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
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
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrq:a3OffsetSsbRsrq=14
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
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
...    NRCELL-1/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=14
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
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
...    NRCELL-1/NRHOIF-5:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrq:a3OffsetSsbRsrq=16
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
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
...    NRBTS-1/NRMEASCFG_IF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=3
...    NRBTS-1/NRMEASCFG_IF-1:freqBandIndicatorNR=257
...    NRBTS-1/NRMEASCFG_IF-1:ssbFrequency=2079163
...    NRBTS-1/NRMEASCFG_IF-2
...    NRBTS-1/NRMEASCFG_IF-2:a4MeasHigherPrioFreqEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-2:a4PriorityForHigherPrioFreqHo=20
...    NRBTS-1/NRMEASCFG_IF-2:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-2:ssbFrequency=518910
...    NRBTS-1/NRMEASCFG_IF-3
...    NRBTS-1/NRMEASCFG_IF-3:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-3:a4PriorityForHigherPrioFreqHo=2
...    NRBTS-1/NRMEASCFG_IF-3:freqBandIndicatorNR=71
...    NRBTS-1/NRMEASCFG_IF-3:ssbFrequency=126750
...    NRBTS-1/NRMEASCFG_IF-4
...    NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-4:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-4:a4PriorityForHigherPrioFreqHo=3
...    NRBTS-1/NRMEASCFG_IF-4:freqBandIndicatorNR=78
...    NRBTS-1/NRMEASCFG_IF-4:ssbFrequency=633216
...    NRBTS-1/NRMEASCFG_IF-5
...    NRBTS-1/NRMEASCFG_IF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-5:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-5:a4PriorityForHigherPrioFreqHo=3
...    NRBTS-1/NRMEASCFG_IF-5:freqBandIndicatorNR=66
...    NRBTS-1/NRMEASCFG_IF-5:ssbFrequency=427970
...    NRBTS-1/NRMEASCFG_IF-6
...    NRBTS-1/NRMEASCFG_IF-6:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-6:a3MeasEnabled=none
...    NRBTS-1/NRMEASCFG_IF-6:a4PriorityForHigherPrioFreqHo=3
...    NRBTS-1/NRMEASCFG_IF-6:freqBandIndicatorNR=66
...    NRBTS-1/NRMEASCFG_IF-6:ssbFrequency=424090
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
...    NRBTS-1/NRMOPR_SA-1:nrMeasCfgIfDNList=${MEASCFG_list}
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


@{CA_Config}
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-13:sCellAdditionMethod=blind
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-11:msg1FrequencyStart=14
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-12:msg1FrequencyStart=14
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-13:msg1FrequencyStart=14
...    NRCELL-14:actK1Opt=intra-gNB
...    NRCELL-14:msg1FrequencyStart=14
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-5:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-1
...    NRBTS-1/NRMEASCFG_IF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-3
...    NRBTS-1/NRMEASCFG_IF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-3:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-4
...    NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-6
...    NRBTS-1/NRMEASCFG_IF-6:a4MeasHigherPrioFreqEnabled=rsrp

${CA_support_list}  ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa

@{PM_Counters_Check_C053_C051}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
${A4_IEF_IADU_HO_EX_ATT_SA}    M55184C00003
#This counter measures the number of A4 triggered handover execution attempts related to inter-frequency
#Intra-gNB Intra-DU handover for SA.
${A4_IEF_IADU_HO_EX_SUC_SA}    M55184C00004
#This counter measures the number of A4 triggered successful handover execution attempts related to
#inter-frequency Intra-gNB Intra-DU handover for SA.

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

#${SA_Capa_Support_FR2_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E0540B40378E3086800A8F3F1424045ED98AA9001E3C0087104184540A3F7F204BEF128000C00
...    13C3C4D000E208000010B010210740000003804808D00A2026C04182001E803202851226C73E1C081B0C38000E043183D04C00F000F07050
...    0703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000
...    C00800007004002000000080000800400004802000030010000140080000B004002048120080000C0339535953582958195833582B594B59
...    33580B581B580958115CAD0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E
...    594901000089652404000265949010000A96524040002E5949410000C965240400030594900CD2AABA55554AA2E95455058AA0B1541A2A94
...    C55268AA031540A2A935559628480BC04A8140A05028140A05028140A05028140A05028140A000E10100C018040080108080100402018030
...    804008010100C018040300608080600C02018030804008010100C018040080110080600C02018030080600C101002008040080200080F01C
...    3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${SA_Capa_Support_FR2_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F
...    11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC0
...    9F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F
...    28581C0E1E13FFE00000FFF80000088000E0540B40378E3086800A8F3F1424045ED98AA9001E3C0087104184540A3F7F204BEF1080018003
...    78789A001C4100000216020420E8000000768385000000C2C000120234028809B010608006A02301C28913639F0E040D861C08103639F000
...    070318C7E8260078007838280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C0100000800
...    8000050040020080200800006004000038020010000000400004002000024010000180080000A004000058020010240900400006019CA9AC
...    A9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AE5681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000
...    B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000182CA480669555D2AAAA5
...    5174AA2A82C55058AA0D154A62A93455018AA051549AAACB142405E02540A05028140A05028140A05028140A05028140A05000708080600C
...    02004008404008020100C018402004008080600C020180300040080210080100202018030080100220100C01804030060100C01820200401
...    0080100400101E0386A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${SA_Capa_Support_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E0540B40378E3086800A8F3F1424045ED98AA9001E3C0087104184540A3F7F204BEF128000C0013C3C
...    4D000E208000010B0102B070A0000038581009011A014404D808304003D0064050A244D8E7C38113639F6C01C086307A09801E001E0E0A00E
...    0601280380030120020301F048010000000080000100400000002000004010000040080000300400002002000014010008020080200001801
...    00000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B0
...    16B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA48
...    0800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A934
...    55018AA051549AAA83C5090178095028140A05028140A05028140A05028140A0502814001C202018030080100210100200804030061008010
...    0202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010040010020086A87C00
...    04080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${ue_id}    81
${ue_id_2}    82
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${Cell1_phycellid}    50
${Cell2_phycellid}    51
${BTS_STARTUP_RETRY}    4

*** Test Cases ***
CB007517-ET-C051_A4_deconfigured_after_A2_then_A1_with_A4_HO_immediately_with_low_prio_A4_mobilityProfile
    [Documentation]
    ...    1. This user scenario describes the behaviour, A4 deconfigured for first circulation after receiving
    ...    inter-freq A2 MR and keep deconfigured until receiving A1 MR and keep circulation without receiving A4 MR
    ...    then during A4 active receiving inter-freq A2 MR then A1 MR then A4 MR before reach maxNum and inter-frq
    ...    intra-DU HO succeed at last with A4 MR with low prio received after ICS
    ...    (UEcapaperFR_A4MGperFR1_interfreqA2Target3FR1)(ICS_woPDU_multiPDU_DRX_CA_Uebc-_gNB+_actHigherPrioFreqHo_SA_
    ...    _target1_FR1_UEcapaPerFR_priority_alldiff_MobilityProfile)

	...    2. Configuration
	...         a. cell1 band is FR1, target cell for A4 should contain both FR1
	...         b. enable mobility profile
	...         c. SA Inter-frequency mobility is enabled
	...         d. CB0007517 feature is activated in the gNB for SA
	...           UE capability support independent MG
	...           DRX: enable
    ...         e. mobility profile configuration:
    ...           NRBTS.NRCELL.NRHOIF_5.a4MeasHigherPrioFreqEnabled = 2            Priority = 20
    ...           from NRMEASCFG_IF
    ...           IF_5.a4MeasHigherPrioFreqEnabled = 4       Priority = 4             measID = 2
    ...         f. gNB CA is enabled

    ...    3. Test Case Steps:
    ...         a. Make one CA call which UE support CA
    ...             UE registers successfully without PDU session is setup successfully on cell 1.
    ...         b. Setup multi PDU session.
    ...         c. Send A2 MR within first SupervisionTimer(a4RetryTimer = 10s)
    ...         d. Send A1 MR after 10s(a4RetryTimer = 10s)
    ...         e. Send A2 MR within second SupervisionTimer(a4RetryTimer = 10s)
    ...         f. Send A1 MR again after 10s(a4RetryTimer = 10s)
	...         g. Send A4 MR to tirgger HO.
    ...         h. UE deregister should be successfully.
    ...     4. Expect result:
    ...          a. CA call made success and Non CA UE registers successfully
    ...          b. PDU session is setup successfully, and start retry timer, check A4/MG configured correctly in
    ...          rrc reconfiguration msg after retryTimer expire
    ...          c. A1/A3 has been configured, A2/A4 has been deconfigured.Meas gap allocation or release is not needed.
    ...          d. A1/A3 has been removed, A2/A4 has been configuration.MG configured A4MGperFR, DRX has been released.
    ...          e. A1/A3 has been configured, A2/A4 has been deconfigured.Meas gap allocation or release is not needed.
    ...          f. A1/A3 has been removed, A2/A4 has been configuration.MG configured A4MGperFR, DRX has been released.
    ...          g. HO is triggered immediately after receive A4 meas, gapUE is release
    ...          h. UE deregister is successfully
	[Tags]    QC_194583    owner-Delun.Li    C051
	Clear Counter Files
	OnlineParamChange    ${OnlineParam_C051}
	CA UE For Two PDUs Attach To Target Cell
	Trigger_A2_MR_after_first_a4_configured    phycell_id=50    carrierfreq=518910    event_type=A2
	Trigger_A2_MR_Again_after_A4_configured    phycell_id=50    carrierfreq=518910    event_type=A2
	Trigger A4 Measurement Report For Two PDUs and HO successfully    phycell_id=62    carrierfreq=427970    event_type=A4
	UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C051${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_Check_C053_C051}
    [Teardown]    Recover Env And Test Teardown with recover for C051

CB007517-ET-C053_A4_deconfigured_after_A2_then_A1_with_A4_HO_with_multi_A4_with_all_prio_same_mobilityProfile
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios: A4 deconfigured for non-first circulation
    ...       after receiving inter-freq A2 MR and keep deconfigured until receiving A1 MR and keep circulation then
    ...       receiving A4 MR before reach maxNum and inter-frq intra-DU HO success immediately success at last with A4
    ...       MR received when all prio same after ICS(UEcapaperFR_A4MGperFR1_interfreqA2Target7FR2)
    ...       (ICS_optimized_DRX_CA_Uebc-_gNB+_actHigherPrioFreqHo_SA_target3_FR1_UEcapaPerFR_priority_
    ...       allsame_MobilityProfile)
	...    2. Configuration
	...         a.configuration on cell 1
    ...           mobility profile configuration:
    ...           NRBTS.NRMEASCFG_IF_4.a4MeasHigherPrioFreqEnabled = rsrqCombined config Priority = 3
    ...           NRBTS.NRMEASCFG_IF_5.a4MeasHigherPrioFreqEnabled = rsrq config Priority = 3
    ...           NRBTS.NRMEASCFG_IF_6.a4MeasHigherPrioFreqEnabled = rsrp config Priority = 3

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
	...         b.gNB CA is enabled

    ...    3. Test Case Steps:
    ...         a. CA call made success and UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Check throughput should be OK.
    ...             1. A4 measurement configuration has been done after A4retrytimer expired and A4 MG configured
    ...             A4MGperFR.and DRX has been released.
    ...             2. A4 measurement configuration has been deconfigured and DRX has been configured, after
    ...             a4SupervisionTimer expires
    ...             3. A4 measurement configuration has been done after A4retrytimer expired and A4 MG configured
    ...             A4MGperFR.and DRX has been released.
    ...         c. Send A2 MR after the second time A4 configured. A1/A3 has been configured, A2/A4 has been
    ...             deconfigured, meas gaps Released
    ...         d. Send A1 MR after 10s (a4RetryTimer),A1/A3 has been removed. A2/A4 measurement configuration has been
    ...             done after A4retrytimer expiredand A4 MG configured A4MGperFR. DRX has been released
    ...         e. Send MR to trigger H4 Handover, UE handover to cell 13 after supervisionTimer timeout.
    ...         f. Check throughput should be OK.
    ...         g. UE deregister should be successfully.
	[Tags]    QC_194584    owner-Delun.Li    C053
	Clear Counter Files
	CA UE Attach To Target Cell
    NonCA UE Attach To Target Cell    cell_id=1
	Send And Verify Throughput
	Trigger_A2_MR_after_second_a4_configured
	Trigger_A1_MR_to_reconfigure_A4
	Trigger A4 Measurement Report and HO successfully    phycell_id=62    carrierfreq=427970    event_type=A4
	UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C053${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    ${PM_Counters_Check_C053_C051}

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

UE Deregister From gNB
    [Arguments]    ${ue_id}
	Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

NonCA UE Attach To Target Cell
    [Arguments]    ${cell_id}
    Update UE capa    ${SA_Capa_Support_FR2_CA}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

NonCA UE For Two PDUs Attach To Target Cell
    [Arguments]    ${cell_id}=1
    Update UE capa    ${SA_Capa_Support_CA}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    sleep   5s    #sleep 5s is better to check the a4RetryTimer expire
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=${nwslice}    QoS Routing Table
    sleep   3s    #sleep 5s is better to check the a4RetryTimer expire
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=${nwslice}    QoS Routing Table
    Send Two PDUs And Verify Throuput

Trigger_A2_MR_after_first_A4_configured
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=     Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=rrcReconfigurationComplete
    ...    fail_regexp=eventA4
    Trigger_A1_MR_to_reconfigure_A4    phycell_id=50    carrierfreq=518910    event_type=A1

Trigger_A2_MR_after_second_a4_configured
    sleep   22s    reason=sleep timer must bigger than a4PeriodicMeasControlSA a4RetryTimer to wait a4RetryTimer expire
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=rrcReconfigurationComplete
    ...    fail_regexp=eventA4

Trigger_A1_MR_to_reconfigure_A4
    [Arguments]    ${phycell_id}=50    ${carrierfreq}=518910    ${event_type}=A1
    sleep    25s    reason=wait timer
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=     Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=11 srsrq_nr=11
    ...    rrcReconfigurationComplete

OnlineParamChange
  [Arguments]  ${Online_Param}
  Delta Commission Parameters  ${Online_Param}
  wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

CA UE For Two PDUs Attach To Target Cell
    [Arguments]    ${ue_id_2}=82    ${target_cells}=1
    Update UE2 capa    ${SA_Capa_Support_FR2}
    Execute Egate Command    ue_change_location id=${ue_id_2} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id_2}    #NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id_2} pdu=4 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=4 ue=${ue_id_2} nwslice=1 gw=4
    Execute Egate Command    trf_data_start ue=${ue_id_2} pdu=4 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id_2} pdu=4 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    trf_data_start ue=${ue_id_2} pdu=4 qfi=1 dir=dl mbps=150 trf_id=3
    Execute Egate Command    trf_data_start ue=${ue_id_2} pdu=4 qfi=1 dir=ul mbps=10 trf_id=1
    Verify Throuput on Pscell and Scell    ${ue_id_2}
    NonCA UE For Two PDUs Attach To Target Cell

CA UE Attach To Target Cell
    [Arguments]    ${ue_id_2}=82    ${target_cells}=1
    Update UE2 capa    ${SA_Capa_Support_FR2}
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    ue_change_location id=${ue_id_2} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id_2}    #NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id_2} pdu=4 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=4 ue=${ue_id_2} nwslice=1 gw=4    Initial Context Setup Successful
    Execute Egate Command    trf_data_start ue=${ue_id_2} pdu=4 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id_2} pdu=4 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    trf_data_start ue=${ue_id_2} pdu=4 qfi=1 dir=dl mbps=150 trf_id=3
    Execute Egate Command    trf_data_start ue=${ue_id_2} pdu=4 qfi=1 dir=ul mbps=10 trf_id=1
    Verify Throuput on Pscell and Scell    ${ue_id_2}
    UE Deregister From gNB    ue_id=${ue_id_2}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}    ${pcell_dl}=240    ${scell_dl}=70    ${ul}=9
    sleep    10s     #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > ${pcell_dl}
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > ${scell_dl}

Update UE2 capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id_2} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Recover Env And Test Teardown with recover for C051
    Delta Commission Parameters    ${OnlineParam_C051_recover}
    Update UE capa    ${SA_Capa_perUE_Full}
    Common Test Teardown And Stop Capture Logs

Trigger_A2_MR_Again_after_A4_configured
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}
    sleep    5s     #sleep for before a4supervision expiredand after a4retrytimer expiredand
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=     Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=rrcReconfigurationComplete
    ...    fail_regexp=eventA4
    Trigger_A1_MR_to_reconfigure_A4

Trigger A4 Measurement Report and HO successfully
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}
    sleep    5s     #sleep for before a4supervision expiredand after a4retrytimer expiredand
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} phycell_id=${phycell_id} nrsrp_nr=70
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.13 performed
    Verify Throughput

Trigger A4 Measurement Report For Two PDUs and HO successfully
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}
    sleep    5s     #sleep for retrytime expiredand
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} phycell_id=${phycell_id} nrsrp_nr=70
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.13 performed
    Verify Two PDUs Throuput

Send Two PDUs And Verify Throuput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=10
    Verify Two PDUs Throuput

Verify Two PDUs Throuput
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=5s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_2_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_2_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Should Be True    ${dl_2_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_2_throughput}/1000>${Tput_ul}
