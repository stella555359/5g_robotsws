*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-christine.chen
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS:actMDTTraceReport=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{HO_Config}
...    @{A4_Config}
...    @{NRHOIF_Config}
...    @{NRREL_Config}
...    @{PCMD_related}
...    @{GNB_PMQAP}
...    @{DELETE_XNLINK}

@{DELETE_XNLINK}
...    delete:NRBTS-1/NRADJGNB-1:xnLinkRef
...    delete:NRBTS-1/NRADJGNB-2:xnLinkRef

@{HO_Config}
...    NRBTS-1/NRCELL:actCDrx=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min

@{A4_Config}
...    NRBTS-1/NRCELL:actCDrx=true
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=8000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4RetryTimer=10
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=8000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=10

@{NRHOIF_Config}
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-1/NRHOIF-2:cellDepType=SA
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
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=4
...    NRCELL-1/NRHOIF-3:cellDepType=SA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=633216
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-1/NRHOIF-4:cellDepType=SA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-4:ssbFrequency=427970
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-4:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-5:cellDepType=SA
...    NRCELL-1/NRHOIF-5:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-5:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-5:ssbFrequency=2079163
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=5
...    NRCELL-1/NRHOIF-6:cellDepType=SA
...    NRCELL-1/NRHOIF-6:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-6:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-6:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-6:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-6:ssbFrequency=2071675
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-6:a4PriorityForHigherPrioFreqHo=6
...    NRCELL-1/NRHOIF-7:cellDepType=SA
...    NRCELL-1/NRHOIF-7:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-7:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-7:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-7:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-7:ssbFrequency=513150
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-7:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-12/NRHOIF-1:cellDepType=SA
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
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1

@{NRREL_Config}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=13

...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=35
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=1
...    delete:NRCELL-1/NRREL-4:sCellAdditionMethod


...    NRCELL-1/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-5:gNbId=36
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-5:removeNotAllowed=false
...    NRCELL-1/NRREL-5:lcrId=1
...    delete:NRCELL-1/NRREL-5:sCellAdditionMethod


...    NRBTS-1/NRADJNRCELL-1:physCellId=381
...    NRBTS-1/NRADJNRCELL-1:gNbId=35
...    NRBTS-1/NRADJNRCELL-1:lcrId=1

...    NRBTS-1/NRADJNRCELL-2:physCellId=382
...    NRBTS-1/NRADJNRCELL-2:gNbId=36
...    NRBTS-1/NRADJNRCELL-2:lcrId=1


@{OnlineParam_for_C013}
...    NRBTS-1/NRCELL-11:maxNumOfNonGBRBearersSA=0

@{recover_GBR_resource}
...    NRBTS-1/NRCELL-11:maxNumOfNonGBRBearersSA=550

@{OnlineParam_for_C012}
...    NRBTS-1/NRCELL-1:pciExcludeList:pciRangeValidity=SA
...    NRBTS-1/NRCELL-1:pciExcludeList:physCellId=60
...    delete:NRBTS-1/NRCELL-1:pciExcludeList:range

@{recover_blacklist}
...    delete:NRBTS-1/NRCELL-1:pciExcludeList

@{OnlineParam_for_C069}
...    NRBTS-1/NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=9000
...    NRBTS-1/NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=8
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=rsrp

@{OnlineParam_for_C069_recover}
...    NRBTS-1/NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=8000
...    NRBTS-1/NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=none

@{OnlineParam_for_C011}
...    @{NG_HO_config_enable}
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=4
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-1/NRHOIF-4:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=2

...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=5

...    NRCELL-1/NRHOIF-6:cellDepType=SA
...    NRCELL-1/NRHOIF-6:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-6:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-6:ssbFrequency=513150
...    NRCELL-1/NRHOIF-6:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-7:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-1/NRHOIF-7:cellDepType=SA
...    NRCELL-1/NRHOIF-7:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-7:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-7:ssbFrequency=127230

@{GNB_PMQAP}
...    NRBTS:actNrpmqapProfiles=true
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=1
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=420
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=06
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-3:cfgProfType=NSA
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=489

@{NG_HO_config_enable}
...    NRBTS-1:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:tNgRelocExecDeltN=3000
...    NRBTS-1:tNgRelocPrepN=2000
...    NRBTS-1:tNgRelocOverallN=2000
...    NRBTS-1:tNgRelocCancelN =2000
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true

@{NG_HO_config_disable}
...    NRBTS-1:actIntraNrNgHo=disabled
...    delete:NRBTS-1:tNgRelocExecDeltN


@{OnlineParam_for_C011_recover}
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=4
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-1/NRHOIF-4:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=5
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=10
...    @{NG_HO_config_disable}

@{PM_Counters_Check_C069}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0

@{PM_Counters_Check_C012}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_PR_F_OTH_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_PR_F_OTH_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_PR_F_OTH_SA}=0
...    NRCELL-1:${FAI_IF_INTRADU_HOP_OTH_SA_PLMN}=1

@{PM_Counters_Check_C013}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_PR_F_AC_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_PR_F_AC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_PR_F_AC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0

@{PM_Counters_Check_C011}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMENP:${A4_IEF_NG_HO_PREP_ATT_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMENP:${A4_IEF_NG_HO_EXEC_ATT_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMENP:${A4_IEF_NG_HO_EXEC_SUC_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMENP:${A4_IEF_NG_HO_PREP_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMENP:${A4_IEF_NG_HO_EXEC_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMENP:${A4_IEF_NG_HO_EXEC_SUC_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMENP:${A4_IEF_NG_HO_PREP_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMENP:${A4_IEF_NG_HO_EXEC_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMENP:${A4_IEF_NG_HO_EXEC_SUC_SRC}=0

@{PCMD_related}    @{TCE}    @{NRMTRACECU}    @{CellTrace_enable}    @{traceAll}    @{PCMD_enable}    @{PeriodicUeMeas}


@{TCE}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${TCE_IP}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=${TCE_PORT}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false
...    NRBTS/NRCTRLTS-1

@{NRMTRACECU}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=100
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1

@{CellTrace_enable}
...    NRBTS:actCellTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true

@{PCMD_enable}
...    NRBTS:actPCMDReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true

@{traceAll}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all

@{PeriodicUeMeas}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=ImmediateMDTAndTrace





${A4_IEF_NG_HO_PREP_ATT_SRC}       M55186C00001
#A4 triggered NG based Inter-frequency Inter-gNB handover preparation attempts on the source cell for SA.
${A4_IEF_NG_HO_EXEC_ATT_SRC}       M55186C00002
#A4 triggered NG based Inter-frequency Inter-gNB handover execution attempts on the source cell for SA.
${A4_IEF_NG_HO_EXEC_SUC_SRC}       M55186C00003
#A4 triggered successful NG based Inter-frequency Inter-gNB handover execution attempts on the source cell for SA.

${A4_IEF_IADU_HO_PR_F_OTH_SA}      M55184C00002
#A4 trigg Other failures for preparation phase of inter-freq Intra-gNB Intra-DU HO for SA
${FAI_IF_INTRADU_HOP_OTH_SA_PLMN}     M55145C00324
#The number of inter-freqintra-DU HO prep failures due to Other Reasons for SA per PLMN-ID
${A4_IEF_IADU_HO_PR_F_AC_SA}       M55184C00001
#This counter measures the number of A4 triggered handover preparation failures due to
#Admission Control (lack of admission) related to inter-frequency Intra-gNB Intra-DU
${A4_IEF_IADU_HO_EX_ATT_SA}       M55184C00003
#This counter measures the number of A4 triggered handover execution attempts
#related to inter-frequency Intra-gNB Intra-DU handover for SA.
${A4_IEF_IADU_HO_EX_SUC_SA}      M55184C00004


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

${SA_Capa_NotSupport_Band66}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810748046D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0003801C0A83621EB04610D04083C40232B64C55890E7D813E238
...    F1891C790E7D473E618F28581C0E1E13FB000000FEC0000003801C0AA3626EB04610D04083A40230B64C55110E7C471E238F40CFB027C63
...    9F30C7942C0E070F05C00FFC007003FF0001C00E0541B11B582308682041E201195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E
...    070F09FFF000007FFC000001C00E007BC3C4D000E218000010B0102A0F0A000388C0000042C0AC3C46000E218000030B02B0F0A00038860
...    000042C0AC3C4D000E230000010B02B17118003886001C4300000A160561E14000713400003058158B89A001C43000E140000040B02B171
...    3400388C001C46000004160562E14000710C00388C0000082C0AC5C28000E21800710C00001058158B89A001C43000E230000020B02B170
...    A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B010C155D83E14489B1CF870A
...    244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C089020
...    40D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F40B00F000A070300E0600A80E00
...    0C0480080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802
...    0010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DA
...    C04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000
...    112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154
...    062A8145526AAA0F14045E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C01840200400
...    8080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F80008101820
...    30385058606880889098A0C0C8D8E0E8F909293139414951697A1A0C1680

${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${BTS_STARTUP_RETRY}    4
${RECREATE_WIRESHARK_FLAG}    ${False}


*** Test Cases ***
CB007517-ET-C069_Verify_lower_priority_A4_MR_will_be_triggered_if_reportOnLeave_received_for_higher_priority_A4_MR_and_IWK_PCMD
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour, when gNB receives a RRC:Measurement report from a UE for event A4 when the
    ...     a4SupervisionTimer is running. if A4 MR for report on leave received for higher priority one, gnb will delete saved 'A4
    ...     Measurement Report. First MR with prio 2/3 receive then MR for reportOnLeave receives then MR with prio 4 receive and
    ...     after supervisionTimer expire, ho for prio4 succeed
    ...    2. Configuration
    ...         a.configuration on cell 1
    ...           UE capability support independent MG
    ...           5GUE supports the band of the inter-frequency configured for A4 measurements
    ...           NRHOIF and NRREL for cell 1, present for cell 11,cell 12,cell 2, cell13 a4PriorityForHigherPrioFreqHo are 2,4,3,1
    ...           NRHOIF and NRREL for cell 12, present for cell 1,a4PriorityForHigherPrioFreqHo are 1
    ...           scell is configed for cell1 NRREL2
    ...           Measurement: A4
    ...           DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Trigger A4 MG and meas_id = 2,3,4 within first SupervisionTimer (a4RetryTimer = 10s)
    ...         c. Trigger A4 MG and meas_id = 2,3 to trigger report onleave within first SupervisionTimer (a4RetryTimer = 10s)
    ...         d. HO is excuted after A4 MG (meas_id = 4) is trigged.
    ...         e. Trigger A4 MG and meas_id = 1 within second SupervisionTimer (a4RetryTimer = 8s,a4Fr1SupervisionTimer=8s).
    ...         f. HO is excuted successful.
    ...         g. UE deregister should be successfully.
    ...     4. Expect result:
    ...          a. PDU session is setup successfully, drx setup, and start retry timer
    ...          c. A4 meas(1,2,3,4,5) is configged, gapUE setup, drx release after retry timer timeout
    ...          d. HO is triggered for prio4 after supervisionTimer expire, A4 meas is released, gapUE is release,
    ...             drx is setup,and start retry timer
    ...          e. A4 meas(1) is configure, gapUE setup, drx release after retry timer timeout.
    ...          f. HO is trigged immediately, A4 meas is released, gapUE is release, drx is setup
    ...          g. UE deregister is successfully
    [Tags]    QC_191461    owner-christine.chen    C069
    Clear Counter Files
    Delta Commission Parameters    ${OnlineParam_for_C069}
    Update UE capa    ${SA_Capa_Support_FR2_with_independent_gap}
    UE Attach To Target Cell    cell_id=1
    Send And Verify Throuput
    Trigger A4 HO
    Verify Throuput
    Trigger A4 HO to cell1
    Verify Throuput
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C069${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    ${PM_Counters_Check_C069}
    [Teardown]    Recover Env And Test Teardown with recover for C069


CB007517-ET-C013_Inter-freq_Intra_DU_HO_fail_due_to_AC_then_receive_A4_MR_in_next_circulation_and_HO_succeed
    [Documentation]
    ...    1. This user scenario describes Handling of HO fail due to AC then receive A4 MR in next circulation
    ...       and HO succeed a4SupervisionTimer expiry
    ...    2. Configuration
    ...         a.NRREL,NHOIF configuration on cell-1, NRCELL-11 with resource not enough,NRCELL-12 with resource enough
    ...         b.Measurement: A4 config on cell-1,A4 config on cell-2
    ...         c.DRX: enable
    ...    3. Test Case Steps:
    ...          precondition: set NonGBR resource to 0 on cell-11
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Trigger HO from cell-1 to cell-11 should be failed for resource not enough.
    ...         c. Trigger HO from cell-1 to cell-12 should be successfully.
    ...         d. check traffic is fine
    ...         e. Trigger HO from cell-12 to cell-1 should be successfully
    ...         f. UE deregister should be successfully.
    [Tags]    QC_191458    owner-liupei.fang    C013
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_for_C013}
    UE Attach To Target Cell    cell_id=1    nwslice=1
    Send And Verify Throuput    sleep_time=5s
    trigger A4 Measurement Report and be discarded and verify throuput     phycell_id=60    carrierfreq=424090
    ...    event_type=A4    source_cell=2.1    target_cell=2.11    time_to_sleep=10s    meas_id=1
    trigger A4 Measurement Report and HO successfully    phycell_id=61      carrierfreq=126750    event_type=A4
    ...    source_cell=2.1    target_cell=2.12
    trigger A4 Measurement Report and HO successfully    phycell_id=50    carrierfreq=518910    event_type=A4
    ...    source_cell=2.12    target_cell=2.1
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C013${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    ${PM_Counters_Check_C013}
    [Teardown]    Recover Env And Test Teardown with recover GBR resource



CB007517-ET-C012_Inter-freq_Intra_DU_HO_fail_due_to_blacklist_then_HO_fail_due_to_invalidTID
    [Documentation]
    ...    1. This user scenario describes Handling of HO fail due to blacklist then receive A4 MR in next circulation
    ...        and HO failed due to invalidTID
    ...    2. Configuration
    ...         a.NRREL,NHOIF configuration on cell-1, NRCELL-11 has sent with blacklist,
    ...           NRCELL-12 has sent with invalidTID after trigger first Handover
    ...         b.Measurement: A4 config on cell-1
    ...         c.DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Trigger HO from cell-1 to cell-11 should be failed for blacklist.
    ...         c. Set UE with invalidTID within supervisionTimer
    ...         d. Trigger HO from cell-1 to cell-12 should be failed with invalidTID.
    ...         e. UE deregister should be successfully.
    [Tags]    QC_191457    owner-liupei.fang    C012
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_for_C012}
    UE Attach To Target Cell    cell_id=1    nwslice=1
    Send And Verify Throuput   sleep_time=5s
    trigger A4 Measurement Report and be discarded and verify throuput     phycell_id=60    carrierfreq=424090    event_type=A4
    ...    source_cell=2.1    target_cell=2.11    time_to_sleep=5s    meas_id=1
    set UE RRC with invalidTID
    trigger A4 Measurement Report and be discarded for mismatch TID    phycell_id=61    carrierfreq=126750    event_type=A4
    ...    source_cell=2.1    target_cell=2.12    time_to_sleep=0s    meas_id=2
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C012${/}a2a.ini    wait_string=UEContextReleaseComplete::10
    Check Counters    ${PM_Counters_Check_C012}
    [Teardown]    Recover Env And Test Teardown with recover blacklist


CB007517-ET-C011_Inter-frq_inter-gNB_NG_HO_succeed_with_multi_A4_MR_with_diff_low_prio_received_non-first_circulation
    [Documentation]
    ...    1. This user scenario describes intergNB interfreq NG HO with muti A4 MR with different prority
    ...    2. Configuration
    ...       configuration on cell 1
    ...       Measurement: inter A4
    ...       DRX: enable
    ...       UE capability not support band 66
    ...       NG handover flag is in scf and cfg file config with NG handover
    ...                 cell11(b66) cell-12(71) cell2(78) cell-13(66) cell-14(257) simGNB1-cell-1(41) simgNB4-cell-1(71)
    ...	        NRHOIF     1           2           3           4            5             6                7
    ...         Priority   2           4           3           1            2             1                3
    ...         meas_id	   NA          4           2           NA           NA            1                3
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Trigger MG setup should be successfully.
    ...         c. Send MR and meas_id = 2,3,4 (ue_schedule_measurement_send_nr id=1...)(measId=2 for rsrq, measId=3 for rsrp)
    ...            within second 13s(next circulation).
    ...         d. A4 NG handover from cell-1 to simGNB4 cell-1(phyid 382) successfully and meas id is 3
    ...         e. NG handover back from simGNB4 cell-1(phyid 382) to real gnb cell1 use A2/A3 event
    ...         f. NG handover back successfully and wait A4 config/deconfig on cell-1
    ...         g. UE deregister should be successfully.
    ...         h. Traffic and counter is always fine
    [Tags]    QC_192635    owner-liupei.fang    C011
    Clear Counter Files
    OnlineParamChange and setup xnlink    ${OnlineParam_for_C011}
    Update UE capa    ${SA_Capa_NotSupport_Band66}
    UE Attach To Target Cell    cell_id=1    nwslice=1
    Send And Verify Throuput    sleep_time=5s
    Trigger schedule A4 Measurement Report for different meas id
    Trigger NG handover back from sim gnb to real gnb
    Verify Throuput    sleep_time=20s
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C011${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    ${PM_Counters_Check_C011}
    [Teardown]    Recover Env And Test Teardown with recover for C011




*** Keywords ***

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
    Start TCE    ${TCE_PORT}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up


Recover Env And Test Teardown with recover GBR resource
    Delta Commission Parameters    ${recover_GBR_resource}
    Common Test Teardown And Stop Capture Logs


Recover Env And Test Teardown with recover blacklist
    Delta Commission Parameters    ${recover_blacklist}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange and setup xnlink
    [Arguments]    ${Online_Param}
    OnlineParamChange    ${Online_Param}
    Execute Egate Command    gnb_param id=4 xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}


UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${nwslice}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Trigger A4 HO
    [Arguments]
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A4 phycell_id=60 nrsrp_nr=50 nrsrq_nr=80 nsinr_nr=80
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A4 phycell_id=51 nrsrp_nr=50 nrsrq_nr=80 nsinr_nr=80
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=4 event=A4 phycell_id=61 nrsrp_nr=50 nrsrq_nr=80 nsinr_nr=80
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A4
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A4
    ...    rrcReconfigurationComplete
    Execute Egate Command    ue_disp


Trigger A4 HO to cell1
    [Arguments]
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A4 phycell_id=50 nrsrp_nr=50 nrsrq_nr=80 nsinr_nr=80
    ...    rrcReconfigurationComplete
    Execute Egate Command    ue_disp

trigger A4 Measurement Report and be discarded and verify throuput
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}    ${source_cell}=2.1
    ...    ${target_cell}=2.11    ${time_to_sleep}=15s    ${meas_id}=1
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToAddModList    timeout=30s
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} phycell_id=${phycell_id} nrsrp_nr=70
    ...    fail_regexp=Intra-eNB handover from EXT_ENB-${source_cell} to EXT_ENB-${target_cell} performed
    Execute Egate Command     ue_disp    pass_regexp=ACTIVE
    Verify Throuput    sleep_time=5s

trigger A4 Measurement Report and be discarded for mismatch TID
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}    ${source_cell}=2.1
    ...    ${target_cell}=2.11    ${time_to_sleep}=15s    ${meas_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} phycell_id=${phycell_id} nrsrp_nr=70
    ...    pass_regexp=Sending RrcReconfigurationComplete with mismatched RRC-TransactionIdentifier
    Execute Egate Command    ue_disp    pass_regexp=IDLE


trigger A4 Measurement Report and HO successfully
    [Arguments]    ${phycell_id}    ${carrierfreq}    ${event_type}    ${source_cell}=2.1
    ...      ${target_cell}=2.12
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToAddModList    timeout=30s
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} phycell_id=${phycell_id} nrsrp_nr=80
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-${source_cell} to EXT_ENB-${target_cell} performed
    Verify Throuput    sleep_time=5s


Verify Throuput
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    Verify Throuput    sleep_time=${sleep_time}


set UE RRC with invalidTID
   sleep    10s    sleep for wait A4 config
   Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=EventA4    sleep_time=0
   Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=invalid_tid       pass_regexp=EGATE>

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Recover Env And Test Teardown with recover for C069
    Delta Commission Parameters    ${OnlineParam_for_C069_recover}
    Update UE capa    ${SA_Capa_perUE_Full}
    Common Test Teardown And Stop Capture Logs

Trigger schedule A4 Measurement Report for different meas id
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToRemoveList    timeout=30s
    ${cmd}    catenate    ue_schedule_measurement_send_nr id=81 action=DELAY_TILL_NR_RRC_RECONF periodicity=1000
    ...    meas_id=2 event=A4 srsrp_nr=100 srsrq_nr=100 phycell_id=51
    ...    meas_id=3 event=A4 srsrp_nr=100 srsrq_nr=100 phycell_id=382
    ...    meas_id=4 event=A4 srsrp_nr=100 srsrq_nr=100 phycell_id=61
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-4.1 performed
    Should not Contain    ${ret1}     meas_id=

Trigger NG handover back from sim gnb to real gnb
    [Arguments]     ${carrierfreq}=518910
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=EventA2
    ${cmd1}    catenate    ue_measurement_send_nr id=81 meas_id=1 event=A2 srsrp_nr=5 srsrq_nr=5
    Execute Egate Command
    ...    ${cmd1}    pass_regexp=Reconfiguration procedure completed successfully
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...       phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command
    ...    ${cmd}    pass_regexp=Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed   timeout=30s
    sleep    15s    sleep for wait A4config and A4 deconfig


Recover Env And Test Teardown with recover for C011
    Delta Commission Parameters    ${OnlineParam_for_C011_recover}
    Update UE capa    ${SA_Capa_perUE_Full}
    Common Test Teardown And Stop Capture Logs


Modify Cfg
    ${C_1}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22
    ...    daemon=$SERVER_IP:$EDAEMON_PORT x2_peers=none amf=1
    Update Cfg    ${C_1}
    Update Cfg    gnb_param id=4 xn_listening_socket=1 send_xn_setup=true
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
