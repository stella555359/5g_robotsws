*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-dandan.chen
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
...    NRBTS-1:actEnhanceIntraNrIntraFreqAnr=true
...    NRBTS-1:actSaIntraFreqAnrDrxProf=true
...    NRBTS-1/NRCELL-12:actCDrx=true
...    NRBTS-1/NRCELL-14:actCDrx=true
...    NRBTS-1/NRCELL-11:actCDrx=false
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1/NRCELL-13:maxNumOfRrcSA=0
...    NRBTS-1/NRCELL-14:maxNumOfRrcSA=0
...    NRBTS-1/NRCELL-13:gscnOrSsPbchArfcn=5300
...    NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    NRBTS-1/NRCELL-13:type0CoresetConfigurationIndex=7
...    NRBTS-1/BWP_PROFILE-3:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    @{A4_Config}
...    @{NRHOIF_NRREL_config_for_NRCELL-12}
...    @{NRHOIF_NRREL_config_for_NRCELL-14}
...    @{NRHOIF_NRREL_config_for_NRCELL-11}
...    @{intra_freq_A3_Meas_enable}
...    @{NRCGI_config}
...    @{GAP_Conf_sf10}

@{GAP_Conf_sf10}
...    NRCELL:ifhoSsbSmtcOffset=8
...    NRCELL:gapOffset=8

@{A4_Config}
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=9000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=0
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=25
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=12
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=9000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=0
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=25
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=9000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=0
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=23
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-13:a4PeriodicMeasControlSA:a4RetryTimer=9
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=8000
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-14:a4PeriodicMeasControlSA:a4MeasMaxNumber=0
...    NRCELL-14:a4PeriodicMeasControlSA:a4RetryTimer=70
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=9000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-11:a4PeriodicMeasControlNSA:a4RetryTimer=25
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

@{NRHOIF_NRREL_config_for_NRCELL-12}
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
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:lcrId=1
...    NRCELL-12/NRHOIF-11:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-11:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-11:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-11:ssbFrequency=424090
...    NRCELL-12/NRHOIF-11:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrq:a4HysteresisSsbRsrq=1
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-12/NRHOIF-11:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms64
...    NRCELL-12/NRHOIF-11:a4PriorityForHigherPrioFreqHo=17
...    NRCELL-12/NRREL-22:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-22:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-22:gNbId=1
...    NRCELL-12/NRREL-22:gNbIdLength=22
...    NRCELL-12/NRREL-22:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-22:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-22:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-22:removeNotAllowed=false
...    NRCELL-12/NRREL-22:lcrId=11

@{OnlineParam1_For_C044}
...    NRBTS-1/NRCELL-14:maxNumOfRrcSA=275

@{OnlineParam2_For_C044}
...    NRBTS-1/NRCELL-12:maxNumOfRrcSA=0

@{OnlineParam3_For_C044}
...    NRBTS-1/NRCELL-12:maxNumOfRrcSA=275


@{NRHOIF_NRREL_config_for_NRCELL-14}
...    NRCELL-14/NRHOIF-11:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-11:freqBandIndicatorNR=257
...    NRCELL-14/NRHOIF-11:ifhoSsbScs=30 KHz
...    NRCELL-14/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-11:ssbFrequency=2071675
...    NRCELL-14/NRHOIF-11:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-14/NRHOIF-11:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-14/NRHOIF-11:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-14/NRHOIF-11:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-14/NRHOIF-11:a4MeasSsbRsrq:a4HysteresisSsbRsrq=1
...    NRCELL-14/NRHOIF-11:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-14/NRHOIF-11:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms64
...    NRCELL-14/NRHOIF-11:a4PriorityForHigherPrioFreqHo=17
...    NRCELL-14/NRREL-22:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-22:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-22:gNbId=35
...    NRCELL-14/NRREL-22:gNbIdLength=22
...    NRCELL-14/NRREL-22:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-22:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-22:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-22:removeNotAllowed=false
...    NRCELL-14/NRREL-22:lcrId=1

@{NRHOIF_NRREL_config_for_NRCELL-11}
...    NRCELL-11/NRHOIF-11:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-11:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-11:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-11:ssbFrequency=126750
...    NRCELL-11/NRHOIF-11:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-11/NRHOIF-11:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-11:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-11/NRHOIF-11:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-11:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-11/NRHOIF-11:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-11/NRHOIF-11:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-11/NRHOIF-11:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-11/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-11:gNbId=1
...    NRCELL-11/NRREL-11:gNbIdLength=22
...    NRCELL-11/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-11:removeNotAllowed=false
...    NRCELL-11/NRREL-11:lcrId=12
...    NRCELL-11/NRHOIF-22:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-22:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-22:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-22:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-22:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-22:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-22:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-22:ssbFrequency=633216
...    NRCELL-11/NRHOIF-22:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-11/NRHOIF-22:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-22:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-11/NRHOIF-22:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-22:a4MeasSsbRsrq:a4HysteresisSsbRsrq=1
...    NRCELL-11/NRHOIF-22:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-11/NRHOIF-22:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms64
...    NRCELL-11/NRHOIF-22:a4PriorityForHigherPrioFreqHo=17
...    NRCELL-11/NRREL-111:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-111:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-111:gNbId=1
...    NRCELL-11/NRREL-111:gNbIdLength=22
...    NRCELL-11/NRREL-111:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-111:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-111:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-111:removeNotAllowed=false
...    NRCELL-11/NRREL-111:lcrId=2

@{intra_freq_A3_Meas_enable}
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-14:a3MeasEnabled=rsrq
...    NRCELL-14:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRCELL-14:a3MeasSsbRsrq:a3OffsetSsbRsrq=12
...    NRCELL-14:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
...    NRCELL-11:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms128
...    NRCELL-11:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRCELL-11:a3MeasSsbRsrq:a3OffsetSsbRsrq=20
...    NRCELL-11:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms640

@{NRCGI_config}
...    NRBTS-1:actSaUeBasedAnrNr=true
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoEutraNbRemoval=false
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoNrNbRemoval=true
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThres=3
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThresEutra=3
...    MRBTS-1/NRBTS-1/NRANR-1:consecXnResolveFailThres=3
...    MRBTS-1/NRBTS-1/NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    MRBTS-1/NRBTS-1/NRANR-1:nrAnrId=1
...    MRBTS-1/NRBTS-1/NRANRPR-1:anrThresholdSelector=RSRP
...    MRBTS-1/NRBTS-1/NRANRPR-1:anrThresRsrpNbCell=-90
...    MRBTS-1/NRBTS-1/NRANRPR-1:anrThresRsrqNbCell=-12
...    MRBTS-1/NRBTS-1/NRANRPR-1:cellDepMode=SA+NSA
...    MRBTS-1/NRBTS-1/NRANRPR-1:consecRecheckForNrNbRemoval=5
...    MRBTS-1/NRBTS-1/NRANRPR-1:idleTimeForNrNbRemoval=72
...    MRBTS-1/NRBTS-1/NRANRPR-1:maxNumAnrNrrelAllowed=50
...    MRBTS-1/NRBTS-1/NRANRPR-1:nrAnrPrId=1

@{OnlineParam_for_C044_Recover}
...    NRBTS-1/NRCELL-14:maxNumOfRrcSA=0
...    NRBTS-1/NRCELL-12:maxNumOfRrcSA=275
...    delete:NRBTS-1/NRCELL-12/NRREL-256
...    delete:NRBTS-1/NRCELL-14/NRREL-256

${SA_Capa_Support_NRCGI}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033
...    EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9
...    863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC0
...    07003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E0540
...    B40378E3086800A8F3F1424045ED98AA9001E3C0087104184540A3F7F204BEF128000C007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C
...    46000E208000030B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41
...    000E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E2300000
...    20B02B170A000388C001C46000004160562E2680071180038500000100008C1D0000000E0804808D00A2026C04182001E81720F851226C73E1C2891363
...    9F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F022408103639F022408103639F022408103639F0224081036
...    39F022408103639F022408103639F02040D8E7C002E1E318C6318C6318C6318C3D04C00F800F070500703009401C0018090010180F8240080000000400
...    0008020000000100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000
...    140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A594901
...    000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504000325949010000316
...    5240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28480BC04A8140A05028140A05028140A05028140A05028140A000E1
...    0100C018040080108080100402018030804008010100C018040300608080600C02018030804008010100C018040080110080600C02018030080600C101
...    00200804008020008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${BTS_STARTUP_RETRY}    4

*** Test Cases ***
CB007517-ET-C044_HO_not_executed_and_A4_deconfigured_after_receiving_Inter-freq_A4_MR_and_then_Intra-freq_NRCGI_configured
    [Documentation]
    ...    1. The purpose of this test case is to check the gNB behaviour for a UE on a SA call when the a4SupervisionTimer expires.
    ...    2. Configuration
    ...         a.configuration on cell 12/14
    ...           DRX: enable
    ...           NRHOIF configured for A4
    ...         b.configuration on cell 11
    ...           DRX: disable
    ...           NRHOIF configured for A4
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11. Throughput is ok.
    ...         b-1. Check after first A4retrytimer expire, eventA4 setup, perFR1 MG setup.
    ...         b-2. Trigger intra-freq A3 MR to gNB, check HO fail due to lack resource, CGI measurement configured, no CGI dedicated DRX setup,
    ...              A4 not been removed.
    ...         b-3. Trigger highest A4 MR to gNB, check HO to cell-12 succeed, no traffic loss
    ...         c-1. Check after first A4retrytimer expire, eventA4 setup, perFR1 MG setup.
    ...         c-2. Trigger low priority A4 MR and then intra-freq A3 MR to gNB within supervisionTimer, check CGI measurement configured,
    ...              CGI dedicated DRX setup, A4 deconfigured, MG release, no A4 MR executed, intra-freq HO failed due to lack resource.
    ...         c-3. Check after second A4retrytimer expire, eventA4 setup (super(9)+retry(23))
    ...         c-4. Online modify cell-14 maxNumOfRrcSA = 275, trigger intra-freq A3 MR again to gNB, check HO to cell-14 succeed.
    ...         d-1. Check after first A4retryTimer expire, eventA4 setup, no MG setup.
    ...         d-2. Online modify cell-12 maxNumOfRrcSA = 0, trigger intra-freq A3 MR to gNB, check HO fail due to lack resource, CGI measurement
    ...              configured, CGI dedicated DRX setup, A4 no been removed.
    ...         d-3. Check A4 deconfigure after first supervisionTimer expire, and A4 configure after retryTimer expire.
    ...         d-4. Online modify cell-12 maxNumOfRrcSA = 275. Trigger intra-freq A3 MR again to gNB, check HO to cell-12 succeed.
    ...         e-1. Check after first A4retryTimer expire, eventA4 setup, perFR1 MG setup, DRX release.
    ...         e-2. Check after first A4supervisionTimer expire, eventA4 release, MG release, DRX setup.
    ...         e-3. UE deregister should be successfully.
    ...         configuration
    ...         cell      actCDrx    DRX profile1    DRX frofile2
    ...         cell11(pci=60)    true       Yes             No
    ...         cell12(pci=61)    true       Yes             Yes
    ...         cell13(pci=62)
    ...         cell14(pci=63)    true       Yes             Yes
    ...         cell11  neighbor cell12
    ...         ell12  neighbor cell11
    ...         NRCELL13 and NRCELL14
    ...         maxNumOfRrcSA=0
    ...         Step
    ...         1. UE81 attach Cell1, send traffic, and traffic OK
    ...         2. First HO: Trigger A3 MR and then highest priority A4 MR
    ...            A3 target cell13(PCI=62)
    ...            A4 target cell12(PCI=61)
    ...            A4 handover successfully, UE81 on cell12
    ...         3. Second HO: Trigger low priority MR and then A3 MR
    ...            A4 target cell11(60)
    ...            A3 target cell14(63)
    ...            A3 handover failed due to lack resource
    ...            then set NRCELL-14:maxNumOfRrcSA=275
    ...            triger A3 handover to cell14(63)
    [Tags]    QC_47004    owner-lena.zhuo    C044
    UE Attach To Target Cell    11
    Send And Verify Throughput
    First HO
    Second HO    ${OnlineParam1_For_C044}
    Third HO    ${OnlineParam2_For_C044}    ${OnlineParam3_For_C044}
    UE Deregister From gNB    ue_id=${ue_id}
    #Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C044${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    C044_Teardown

*** Keywords ***
Modify Cfg
    ${C_1}    catenate
    ...     set_cell id=13 gnb=2 pci=20:2 tac=0 nrci=0x0D tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=344000:424000
    ...      gscn=5300 mandatory_for_activation=off
    Update Cfg     ${C_1}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE Attach To Target Cell
    [Arguments]    ${cell_id}
    Update UE capa
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    #Run Keyword And Ignore Error    get nr meas id for specific type and frequency    ${ue_id}     event_type=A3    carrierfreq=424090

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
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_NRCGI}
    Execute Egate Command    ${cmd}

Second HO
    [Arguments]    ${OnlineParam1_For_C044}    ${A3_phycell_id}=63    ${A3_meas_id}=2    ${sleep_time}=32s
    Trigger low priority MR and then A3 MR    ${ue_id}    A3_meas_id=2    A4_meas_id=3
    OnlineParamChange    ${OnlineParam1_For_C044}
    Trigger A3 MR    ue_id=${ue_id}    phycell_id=${A3_phycell_id}    meas_id=1    sleep_time=${sleep_time}
    Verify Throughput

Third HO
    [Arguments]    ${OnlineParam2_For_C044}    ${OnlineParam3_For_C044}    ${A3_phycell_id}=61    ${A3_meas_id}=2    ${sleep_time}=45s
    OnlineParamChange    ${OnlineParam2_For_C044}
    Check A4Remove    ${ue_id}
    Trigger A3 MR with schedule    ue_id=${ue_id}
    OnlineParamChange    ${OnlineParam3_For_C044}
    Trigger A3 MR    ue_id=${ue_id}    phycell_id=${A3_phycell_id}    meas_id=${A3_meas_id}    sleep_time=${sleep_time}
    sleep    5s
    Verify Throughput
    Check MeasConfig    ${ue_id}


First HO
    Trigger A3 MR and then highest priority A4 MR    ${ue_id}
    Verify Throughput

Trigger A3 MR
    [Arguments]    ${ue_id}    ${phycell_id}=63    ${meas_id}=6    ${sleep_time}=32s
    sleep    ${sleep_time}    sleep for A4 retryTimer+supervisionTimer expire
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}     event_type=A3    carrierfreq=424090    timeout=0.5
    ${C_1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A3 srsrp_nr=50 srsrq_nr=50 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    ${ret}=    Execute Egate Command    ${C_1}    pass_regexp=rrcReconfigurationComplete    #Handover will be triggered using CBRA

Trigger A3 MR with schedule
    [Arguments]    ${ue_id}    ${phycell_id}=61    ${meas_id}=7
    #${meas_id}    get nr meas id for specific type and frequency    ${ue_id}     event_type=A3    carrierfreq=126750
    ${C_1}    catenate
    ...    ue_schedule_measurement_send_nr id=${ue_id} action=DELAY_TILL_NR_RRC_RECONF periodicity=1000 delay=100 meas_id=2 event=A3
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    ${ret}=    Execute Egate Command    ${C_1}    pass_regexp=rrcReconfigurationComplete     timeout=75s


Trigger low priority MR and then A3 MR
    [Arguments]    ${ue_id}    ${A4_phycell_id}=60    ${A4_meas_id}=3    ${A3_phycell_id}=63    ${A3_meas_id}=2    ${time_out}=32s
    Wait Until Keyword Succeeds    30s    0.5s
    ...    get nr meas id for specific type and frequency    ${ue_id}     event_type=A4    carrierfreq=126750    timeout=0.5
    #${A3_meas_id}    get nr meas id for specific type and frequency    ${ue_id}     event_type=A3    carrierfreq=424090    timeout=0.5
    #${A4_meas_id}    get nr meas id for specific type and frequency    ${ue_id}     event_type=A4    carrierfreq=126750    timeout=0.5
    ${C_1}    catenate
    ...    ue_schedule_measurement_send_nr id=${ue_id} action=DELAY_TILL_NR_RRC_RECONF periodicity=1000 delay=100 meas_id=3
    ...    event=A4 phycell_id=${A4_phycell_id} nrsrp_nr=70 nrsrq_nr=70 meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=50
    ...    phycell_id=${A3_phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${C_1}    pass_regexp=measurementReport    timeout=${time_out}


Trigger A3 MR and then highest priority A4 MR
    [Arguments]    ${ue_id}    ${A4_phycell_id}=61    ${A4_meas_id}=3    ${A3_phycell_id}=62    ${A3_meas_id}=2    ${time_out}=31s
    ${C_1}    catenate
    ...    ue_schedule_measurement_send_nr id=${ue_id} action=DELAY_TILL_NR_RRC_RECONF periodicity=3000 delay=100 meas_id=${A3_meas_id}
    ...    event=A3 srsrp_nr=50 srsrq_nr=50 phycell_id=${A3_phycell_id} nrsrp_nr=80 nrsrq_nr=80 meas_id=${A4_meas_id} event=A4
    ...    phycell_id=${A4_phycell_id} nrsrp_nr=70 nrsrq_nr=70
    Execute Egate Command    ${C_1}    pass_regexp=measurementReport    timeout=${time_out}

C044_Teardown
    OnlineParamChange    ${OnlineParam_for_C044_Recover}
    Common Test Teardown And Stop Capture Logs

Check A4Remove
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    pass_regexp=measIdToRemoveList    timeout=80s

Check MeasConfig
    [Arguments]    ${ue_id}
    sleep    40s    sleep for A4 retryTimer+supervisionTimer expire
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
