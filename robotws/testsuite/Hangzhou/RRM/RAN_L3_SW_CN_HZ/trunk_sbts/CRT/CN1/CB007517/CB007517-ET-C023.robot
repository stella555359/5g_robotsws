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
...    @{A4_Config_Cell}
...    @{A4_Config_HOIF}
...    @{NRREL}
...    @{actCDrx}
...    @{A3InterFre}
...    @{enable_CA_blind}
...    @{Mobility_Profile_Config}
...    @{RRE_Config}
...    @{intergnb_HO}

@{intergnb_HO}
...    NRADJNRCELL-1:physCellId=381
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=35
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=1

@{enable_CA_blind}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actCarrierAggregation=true
...    NRCELL-13/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly

@{CA_coverbased}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly

@{actCDrx}
...    NRCELL-1:actCDrx=true
...    NRCELL-11:actCDrx=true
...    NRCELL-12:actCDrx=true
...    NRCELL-1:drxProfileNrAnr:drxControl=interRATeUTRA
...    NRCELL-11:drxProfileNrAnr:drxControl=interRATeUTRA
...    NRCELL-12:drxProfileNrAnr:drxControl=interRATeUTRA

@{A4_Config_Cell}
...    NRBTS-1:actIntraFreqHoSA=false
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=1
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRCELL-13:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlSA:a4MeasMaxNumber=5
...    NRCELL-14:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlNSA:a4RetryTimer=10
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlNSA:a4RetryTimer=10
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-11:a4PeriodicMeasControlNSA:a4RetryTimer=10
...    NRCELL-12:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-12:a4PeriodicMeasControlNSA:a4MeasMaxNumber=1
...    NRCELL-12:a4PeriodicMeasControlNSA:a4RetryTimer=10
...    NRCELL-13:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-13:a4PeriodicMeasControlNSA:a4RetryTimer=10
...    NRCELL-14:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-14:a4PeriodicMeasControlNSA:a4RetryTimer=10

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=2
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=1
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:lcrId=2
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:lcrId=13
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-14/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-3:gNbId=1
...    NRCELL-14/NRREL-3:gNbIdLength=22
...    NRCELL-14/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-3:removeNotAllowed=false
...    NRCELL-14/NRREL-3:lcrId=2
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-2:gNbId=1
...    NRCELL-14/NRREL-2:gNbIdLength=22
...    NRCELL-14/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-2:removeNotAllowed=false
...    NRCELL-14/NRREL-2:lcrId=13

@{A4_Config_HOIF}
...    NRCELL-1/NRHOIF-1:cellDepType=SA
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
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=15
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=20
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
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-3:cellDepType=SA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=427970
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=10
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=10
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=11
...    NRCELL-1/NRHOIF-4:cellDepType=SA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-4:ssbFrequency=424090
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4ThresholdSsbRsrp=12
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrq:a4ThresholdSsbRsrq=12
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-4:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-5:cellDepType=SA
...    NRCELL-1/NRHOIF-5:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-5:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-5:ssbFrequency=513150
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-2/NRHOIF-2:cellDepType=SA
...    NRCELL-2/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-2:ssbFrequency=126750
...    NRCELL-2/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-2/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-2/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-2:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-11/NRHOIF-2:cellDepType=SA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-2:ssbFrequency=518910
...    NRCELL-11/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-11/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-11/NRHOIF-2:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-12/NRHOIF-3:cellDepType=SA
...    NRCELL-12/NRHOIF-3:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-3:ssbFrequency=427970
...    NRCELL-12/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=10
...    NRCELL-12/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-12/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-3:a4PriorityForHigherPrioFreqHo=11
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=633216
...    NRCELL-12/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-13/NRHOIF-2:cellDepType=SA
...    NRCELL-13/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-2:ssbFrequency=126750
...    NRCELL-13/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-13/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-13/NRHOIF-2:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-14/NRHOIF-3:cellDepType=SA
...    NRCELL-14/NRHOIF-3:freqBandIndicatorNR=66
...    NRCELL-14/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-14/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-3:ssbFrequency=427970
...    NRCELL-14/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-14/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-14/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=10
...    NRCELL-14/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-14/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-14/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-14/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-14/NRHOIF-3:a4PriorityForHigherPrioFreqHo=11
...    NRCELL-14/NRHOIF-1:cellDepType=SA
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-1:ssbFrequency=633216
...    NRCELL-14/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrq
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-14/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-14/NRHOIF-1:a4PriorityForHigherPrioFreqHo=20

${nrMeasCfgIfDNList_cell1}    SEPARATOR=
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1,MRBTS-1/NRBTS-1/NRMEASCFG_IF-2,MRBTS-1/NRBTS-1/NRMEASCFG_IF-3
...    ,MRBTS-1/NRBTS-1/NRMEASCFG_IF-6

@{Mobility_Profile_Config}
...    NRBTS-1:actMobilityProfile=true
...    NRBTS-1:actRanSharing=true
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
...    NRBTS-1/NRMOPR_NSA-1
...    NRBTS-1/NRMOPR_NSA-1:a3MeasEnabled=rsrp
...    NRCELL-1:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-2:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-11:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-12:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-13:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL-14:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRBTS-1/NRMEASCFG_IF-1
...    NRBTS-1/NRMEASCFG_IF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-1:a4MeasHigherPrioFreqEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=4
...    NRBTS-1/NRMEASCFG_IF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRMEASCFG_IF-1:ssbFrequency=633216
...    NRBTS-1/NRMEASCFG_IF-2
...    NRBTS-1/NRMEASCFG_IF-2:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-2:a4PriorityForHigherPrioFreqHo=2
...    NRBTS-1/NRMEASCFG_IF-2:freqBandIndicatorNR=66
...    NRBTS-1/NRMEASCFG_IF-2:ssbFrequency=424090
...    NRBTS-1/NRMEASCFG_IF-3
#...    NRBTS-1/NRMEASCFG_IF-3:a3MeasEnabled=rsrp
...    NRBTS-1/NRMEASCFG_IF-3:a4MeasHigherPrioFreqEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-3:a4PriorityForHigherPrioFreqHo=20
...    NRBTS-1/NRMEASCFG_IF-3:freqBandIndicatorNR=71
...    NRBTS-1/NRMEASCFG_IF-3:ssbFrequency=126750
...    NRBTS-1/NRMEASCFG_IF-4
...    NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled=none
...    NRBTS-1/NRMEASCFG_IF-4:a4PriorityForHigherPrioFreqHo=2
...    NRBTS-1/NRMEASCFG_IF-4:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-4:ssbFrequency=518910
...    NRBTS-1/NRMEASCFG_IF-5
...    NRBTS-1/NRMEASCFG_IF-5:a4MeasHigherPrioFreqEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-5:a4PriorityForHigherPrioFreqHo=1
...    NRBTS-1/NRMEASCFG_IF-5:freqBandIndicatorNR=66
...    NRBTS-1/NRMEASCFG_IF-5:ssbFrequency=427970
...    NRBTS-1/NRMEASCFG_IF-6
...    NRBTS-1/NRMEASCFG_IF-6:a3MeasEnabled=rsrq
...    NRBTS-1/NRMEASCFG_IF-6:a4MeasHigherPrioFreqEnabled=none
...    NRBTS-1/NRMEASCFG_IF-6:a4PriorityForHigherPrioFreqHo=1
...    NRBTS-1/NRMEASCFG_IF-6:freqBandIndicatorNR=41
...    NRBTS-1/NRMEASCFG_IF-6:ssbFrequency=513150
...    NRBTS-1/NRMOPR_SA-1:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-1:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-1:a2MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-1:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-1:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-1:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-1:nrMeasCfgIfDNList=${nrMeasCfgIfDNList_cell1}
...    NRBTS-1/NRMOPR_SA-2:a1MeashoEnabledSA=none
...    NRBTS-1/NRMOPR_SA-2:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-2:a2MeashoEnabledSA=none
...    NRBTS-1/NRMOPR_SA-2:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-2:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-2:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-2:nrMeasCfgIfDNList=MRBTS-1/NRBTS-1/NRMEASCFG_IF-4
...    NRBTS-1/NRMOPR_SA-3:a1MeashoEnabledSA=none
...    NRBTS-1/NRMOPR_SA-3:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-3:a2MeashoEnabledSA=none
...    NRBTS-1/NRMOPR_SA-3:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-3:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-3:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-3:nrMeasCfgIfDNList=MRBTS-1/NRBTS-1/NRMEASCFG_IF-1,MRBTS-1/NRBTS-1/NRMEASCFG_IF-5
...    NRBTS-1/NRMOPR_SA-4:a1MeashoEnabledSA=none
...    NRBTS-1/NRMOPR_SA-4:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-4:a2MeashoEnabledSA=none
...    NRBTS-1/NRMOPR_SA-4:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-4:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-4:voiceFBMode=disabled
...    NRBTS-1/NRMOPR_SA-4:nrMeasCfgIfDNList=MRBTS-1/NRBTS-1/NRMEASCFG_IF-3
...    NRCELL-1:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-1
...    NRCELL-2:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-4
...    NRCELL-11:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-2
...    NRCELL-12:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-3
...    NRCELL-13:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-4
...    NRCELL-14:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-3

@{A3InterFre}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrq
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms100
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms80
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0    NRCELL-1/NRHOIF-3:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-1/NRHOIF-4:a3MeasEnabled=rsrq
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms128
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0    NRCELL-1/NRHOIF-4:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-1/NRHOIF-5:a3MeasEnabled=rsrq
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0    NRCELL-1/NRHOIF-5:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-2/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-11/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-12/NRHOIF-3:a3MeasEnabled=rsrq
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0    NRCELL-12/NRHOIF-3:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-13/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-13/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-13/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-14/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-14/NRHOIF-3:a3MeasEnabled=rsrq
...    NRCELL-14/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-14/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-14/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-14/NRHOIF-3:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480
...    NRCELL-14/NRHOIF-3:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0    NRCELL-14/NRHOIF-3:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-2:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-2:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-2:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=33
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=20
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=30
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80
...    NRCELL-11:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-11:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-11:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-11:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL-11:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL-11:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-12:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-12:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-12:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-12:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL-12:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL-12:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-13:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-13:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-13:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-13:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL-13:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL-13:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL-14:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL-14:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL-14:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-14:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL-14:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL-14:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80

@{RRE_Config}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=4000ms

${BTS_STARTUP_RETRY}    4
${RECREATE_WIRESHARK_FLAG}    ${False}

*** Test Cases ***

CB007517-ET-C023_Verify_A4_reconfigured_successfully_after_RRE_IWK_732_and_perFR_MG
    [Documentation]
    ...    1.The purpose of this test case is to check the gNB behaviour for a UE on a SA call with RRE and 7517 enabled
    ...    The test checkpoint contain measObject id and reportConfigId and measID allocated .
    ...    2.Test Case Steps:
    ...    2.1 UE81 register to cell 11
    ...    2.2 trigger ue81 1st RRE to cell 1 , check A2,A4 configured and A4 deconfigured
    ...    2.3 trigger ue81 2nd RRE to cell 1 , after A4 configured ,trigger A2 MR ,A1A3 configured
    ...    2.4 trigger ue81 3rd RRE to cell 1 , after A1 configured ,trigger A1 MR
    ...    After A1 re-configured, trigger A4MR with not highest Prio.
    ...    2.5 trigger ue81 4th RRE to cell 1 before A4SupervisionTimer expired.
    ...    after A4 configured ,trigger A2 MR ,trigger A1 MR.
    ...    2.6 trigger ue81 5th RRE to cell 1 , after A4 configured ,trigger A2 MR
    ...    2.7 trigger ue81 6th RRE to cell 12 ,after A4 configured ,trigger A4 HO to cell13, scell added with blind
    ...    2.8 trigger ue81 7th RRE to cell 13 ,no scell added , A4 configured , RRE not support blind CA.
    ...    2.9 trigger ue81 8th RRE to cell 12 ,after A4 configured ,a4MeasMaxNumber =1
    ...    2.10 trigger ue81 9th RRE to cell 12 ,no A4 configured
    ...    2.11 online modify CA to coverbased A1 , attach UE82 to cell 13 , A1 configured and scell can added with A1MR
    ...    2.12 online modify CA to blind , trigger UE 82 RRE to cell 13 , no A1 allocated to UE and A4 configured.
    [Tags]    C023    owner-xiaowen.xu    QC_196051
    RRE_IWK_732_and_perFR_MG    ue_id=81    pdu_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C023${/}a2a.ini    wait_string=InitialULRRCMessageTransfer::30
    CA onlineModify with RRE    ue_id=82    pdu_id=2
    [Teardown]    TestTearDown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

TestTearDown
    onlineparamchange    ${enable_CA_blind}
    Common Test Teardown And Stop Capture Logs

RRE_IWK_732_and_perFR_MG
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    RRE_IWK_732_and_perFR_MG_1    ${ue_id}    ${pdu_id}
    RRE_IWK_732_and_perFR_MG_2    ${ue_id}    ${pdu_id}
    RRE_IWK_732_and_perFR_MG_3    ${ue_id}    ${pdu_id}
    RRE_IWK_732_and_perFR_MG_4    ${ue_id}    ${pdu_id}

RRE_IWK_732_and_perFR_MG_1
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    SA UE attach    ue_id=${ue_id}    target_cells=11
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=1    sleep_time=20    ue_id=${ue_id}
    Check A4 configured    ue_id=${ue_id}
    Check A4 Deconfigured    ue_id=${ue_id}
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=1    ue_id=${ue_id}
    Check A4 configured    ue_id=${ue_id}
    Trigger MR    event_type=A2    ue_id=${ue_id}

RRE_IWK_732_and_perFR_MG_2
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=1    ue_id=${ue_id}
    sleep    12s    reason=waiting A4RetryTimer expired
    Trigger MR    event_type=A1    srsrp_nr=20    srsrq_nr=20    ue_id=${ue_id}
    Check A4 configured    ue_id=${ue_id}
    Trigger A4 interFre HO    carrierfreq=126750    ue_id=${ue_id}
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=1    ue_id=${ue_id}
    Check A4 configured    ue_id=${ue_id}
    Trigger MR    event_type=A2    ue_id=${ue_id}
    Trigger MR    event_type=A1    srsrp_nr=20    srsrq_nr=20    ue_id=${ue_id}

RRE_IWK_732_and_perFR_MG_3
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=1    ue_id=${ue_id}
    Check A4 configured    ue_id=${ue_id}
    Trigger MR    event_type=A2    ue_id=${ue_id}
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=12    ue_id=${ue_id}
    Check A4 configured    ue_id=${ue_id}
    Trigger A4 interFre HO    carrierfreq=427970    phycell_id=62    ue_id=${ue_id}
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=13    sleep_time=0    ue_id=${ue_id}
    Check A4 configured    ue_id=${ue_id}

RRE_IWK_732_and_perFR_MG_4
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=12    ue_id=${ue_id}
    Check A4 configured    ue_id=${ue_id}
    Check A4 Deconfigured    ue_id=${ue_id}
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=12    ue_id=${ue_id}
    Check A4 should not configured    ue_id=${ue_id}

CA onlineModify with RRE
    [Arguments]    ${ue_id}=82    ${pdu_id}=2
    onlineparamchange    ${CA_coverbased}
    SA UE attach    ue_id=${ue_id}    target_cells=13    pdu_id=${pdu_id}
    Check A4 should not configured    ue_id=${ue_id}
    Trigger MR    event_type=A1    carrierfreq=427970    srsrp_nr=100    ue_id=${ue_id}
    onlineparamchange    ${enable_CA_blind}
    #Wait Until Keyword Succeeds    30s    2s    Get MR
    Trigger RRC reestablishment    RRC_cause=otherFailure    cell_id=13    sleep_time=20    ue_id=${ue_id}
    #Wait Until Keyword Succeeds    30s    2s    Get MR
    Check A4 configured    ue_id=${ue_id}    timeout=40s
    Check A4 Deconfigured    ue_id=${ue_id}    timeout=40s

Check A4 configured
    [Arguments]    ${ue_id}=81    ${timeout}=20
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
    ...    pass_regexp=gapUE setup    timeout=${timeout}

Check A4 Deconfigured
    [Arguments]    ${ue_id}=81    ${timeout}=20
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
    ...    pass_regexp=gapUE release    timeout=${timeout}

Check A4 should not configured
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
    ...    fail_regexp=measIdToAddModList    timeout=30

Trigger MR
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger A4 interFre HO
    [Arguments]    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${phycell_id}=61    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=A4    carrierfreq=${carrierfreq}
    ${cmd_A4}    Catenate    ue_measurement_send_nr id=${ue_id} event=A4 meas_id=${meas_id}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${cmd_A4}    pass_regexp=measurementReport

SA UE attach
    [Arguments]    ${ue_id}=81    ${target_cells}=11    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}    Initial Context Setup Successful
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1

Trigger RRC reestablishment
    [Arguments]    ${RRC_cause}    ${cell_id}    ${sleep_time}=0    ${ue_id}=81
    sleep    ${sleep_time}    sleep for concurrency with A4 configure/deconfigure
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${RRC_cause}
    ...    pass_regexp=rrcReconfigurationComplete

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Get MR
    [Arguments]    ${event_type}=A4    ${carrierfreq}=633216    ${ue_id}=82
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    
