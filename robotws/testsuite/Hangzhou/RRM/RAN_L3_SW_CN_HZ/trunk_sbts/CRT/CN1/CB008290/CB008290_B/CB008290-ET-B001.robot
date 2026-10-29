*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-jia.pan
...    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G   
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS-1:actFdmEnhancedScheduling=true
...    MRBTS-1/NRBTS-1/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    @{PARAMS_FOR_IODT_ABIO_4T2F}
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{HoSA_A2A3A5}    
...    @{IRAT_config}

@{IRAT_config}
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:actInterRatHoFromEutraToSA=true
...    NRBTS-1:nonContentRachAcFullConfigHo=true
...    NRBTS-1:tNgRelocExecDeltL=5000
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:dtxOptimizedScheduler:dtxDelaySinceLastScheduling=0
...    NRCELL-11:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-11:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-11:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRCELL-11/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-11/NRRELE-1:eutranCellExcluded=false
...    NRCELL-11/NRRELE-1:lcrId=1
...    NRCELL-11/NRRELE-1:eNodeBId=18
...    NRCELL-11/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-11/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-11/NRRELE-1:ecgiPlmn:mncLength=3
...    NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRHOIR-1:earfcnValue=1
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eNodeBId=18
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=0
...    MRBTS-1/NRBTS-1/NRADJECELL-1:earfcnValue=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:physCellId=11
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3

@{HoSA_A2A3A5}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=128890
...    NRCELL-11/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-2:ssbFrequency=648096
...    NRCELL-11/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-3:ssbFrequency=508110
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-11/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-2:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-11/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-11/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-11/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-3:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-3:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-11/NRHOIF-3:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-11/NRHOIF-3:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-11/NRHOIF-3:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms160
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=60
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1

@{NRREL}
...    NRCELL-12/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-5:gNbId=1
...    NRCELL-12/NRREL-5:gNbIdLength=22
...    NRCELL-12/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-5:removeNotAllowed=false
...    NRCELL-12/NRREL-5:lcrId=11
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:lcrId=4
...    NRCELL-12/NRREL-4:sCellPrio=2
...    NRCELL-12/NRREL-4:handoverAllowedSA=forbidden
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:sCellPrio=1
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:sCellPrio=2
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:sCellPrio=1
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-5:gNbId=1
...    NRCELL-11/NRREL-5:gNbIdLength=22
...    NRCELL-11/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-5:removeNotAllowed=false
...    NRCELL-11/NRREL-5:lcrId=12
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=4
...    NRCELL-11/NRREL-4:sCellPrio=2
...    NRCELL-11/NRREL-4:handoverAllowedSA=forbidden
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:sCellPrio=1
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed

@{8290_enable}
...    MRBTS-1/NRBTS-1/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=100
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-5:sCellAdditionMethod=covBasedA1

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=8000
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=648000
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1610
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127900
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136000

@{PM_Counters_Check_B001}
...    NRCELL-11:${SCELL_SWAP_1_ATT_SA}=11
...    NRCELL-11:${SCELL_SWAP_1_SUCC_SA}=11
...    NRCELL-12:${SCELL_SWAP_1_ATT_SA}=10
...    NRCELL-12:${SCELL_SWAP_1_SUCC_SA}=10
...    NRCELL-12:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-3:${GNB_DU_SCELL_ADMI_REQ_SA}=7
...    NRCELL-3:${GNB_DU_SCELL_ADMI_SUCC_SA}=7
...    NRCELL-4:${GNB_DU_SCELL_ADMI_REQ_SA}=7
...    NRCELL-4:${GNB_DU_SCELL_ADMI_SUCC_SA}=7
...    NRCELL-1:${GNB_DU_SCELL_ADMI_REQ_SA}=6
...    NRCELL-1:${GNB_DU_SCELL_ADMI_SUCC_SA}=6
...    NRCELL-11:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-11:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-2:${GNB_DU_SCELL_ADMI_REQ_SA}=6
...    NRCELL-2:${GNB_DU_SCELL_ADMI_SUCC_SA}=6
...    NRCELL-11:${GNB_DU_SCELL_1_ADMI_REQ_SA}=11
...    NRCELL-11:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=11
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_REQ_SA}=11
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=11
...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-11:${GNB_DU_SCELL_2_ADMI_REQ_SA}=2
...    NRCELL-11:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=2
...    NRCELL-11:${SCELL_CHANGE_ATT_SA}=1
...    NRCELL-11:${SCELL_CHANGE_SUCC_SA}=1
...    NRCELL-12:${SCELL_CHANGE_ATT_SA}=1
...    NRCELL-12:${SCELL_CHANGE_SUCC_SA}=1
...    NRCELL-11:${GNB_SCELL_1_ADMI_REQ_SA}=11
...    NRCELL-11:${GNB_SCELL_1_ADMI_SUCC_SA}=11
...    NRCELL-12:${GNB_SCELL_1_ADMI_REQ_SA}=11
...    NRCELL-12:${GNB_SCELL_1_ADMI_SUCC_SA}=11
...    NRCELL-12:${GNB_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-11:${GNB_SCELL_2_ADMI_REQ_SA}=3
...    NRCELL-11:${GNB_SCELL_2_ADMI_SUCC_SA}=2
...    NRCELL-11:${NRRCC_RRC_RECONF_SENT}=17
...    NRCELL-11:${NRRCC_RRC_RECONF_CMP_RECD}=17
...    NRCELL-12:${NRRCC_RRC_RECONF_SENT}=15
...    NRCELL-12:${NRRCC_RRC_RECONF_CMP_RECD}=15

${SCELL_SWAP_1_ATT_SA}    M55118C10501
#The total number of SCell swap attempts for 1 SCell in the PCell for SA mode.
${SCELL_SWAP_1_SUCC_SA}    M55118C10502
#The total number of successful SCell swap attempts for 1 SCell in the PCell for SA mode.
${GNB_SCELL_1_ADMI_REQ_SA}    M55138C01501
#This counter describes the number of radio admission requests for exactly 1 SCell before
#the CA configuration on RRC. It is measured in PCell in SA mode only.
${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502
#This counter describes the number of successful radio admission requests for exactly 1 SCell 
#before the CA configuration on RRC. It is measured in PCell in SA mode only.
${GNB_SCELL_2_ADMI_REQ_SA}    M55138C02501
#This counter describes the number of radio admission requests for exactly 2 SCells 
#before the CA configuration on RRC. It is measured in PCell in SA mode only.
${GNB_SCELL_2_ADMI_SUCC_SA}    M55138C02502
#This counter describes the number of successful radio admission requests for exactly 2 SCells 
#before the CA configuration on RRC. It is measured in PCell in SA mode only.
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter describes the total number of radio admission requests for SCell 
#before the CA configuration on RRC. It is measured in SCell in SA mode in DU only.
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
#This counter describes the total number of successful radio admission requests for SCell 
#before the CA configuration on RRC. It is measured in SCell in SA mode in DU only.
${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
#This counter describes the number of radio admission requests for exactly 1 SCell before 
#the CA configuration on RRC. It is measured in PCell in SA mode in DU only.
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
#This counter describes the number of successful radio admission requests for exactly 1 SCell 
#before the CA configuration on RRC. It is measured in PCell in SA mode in DU only.
${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
#The number of radio admission requests for 2 S-Cells in addition of PS-Cell. Updated to the PS-Cell 
#whenever there is an admission request for the UE
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502
#This counter describes the number of successful radio admission requests for exactly 1 SCell 
#before the CA configuration on RRC. It is measured in PCell in SA mode in DU only.
${NRRCC_RRC_RECONF_SENT}    M55124C03001
#This counter provides the number of RRC: RRC RECONFIGURATION messages sent from gNB-CU.
${NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002
#This counter provides the number of RRC: RRC RECONFIGURATION COMPLETE messages received at gNB-CU.
${SCELL_CHANGE_ATT_SA}    M55118C06506
#The total number of RRC Reconfiguration Request messages changing SCell(s) in SA mode.
${SCELL_CHANGE_SUCC_SA}    M55118C06507
#The total number of successful RRC Reconfiguration Changing current SCell(s) in SA mode.

${CA_support_list}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

${SA_Capa_Support}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11
...    C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F1
...    8E7CC31E50B0381C3C17003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931561439F11C78C00000000000000000040E1E02
...    7FFC00001FFF00000110001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040000085
...    8158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268007118
...    00388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800
...    388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602086A0BB07C28913639F0E14489B1CF870A
...    244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF8112040
...    81B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381804A00E000C0480080C07C1
...    20040000000200000401000000008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004
...    002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA068200
...    0012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202
...    000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405
...    E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C020180304040300
...    60100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C
...    8D8E0E8F909293139414951697A0A0C168

${pdu_id}    1
${gw_id}    1
${nwslice}    1

@{PARAMS_IN_SWCONFIG}
...    ${oam_debug}
${oam_debug}    0x300001=1

*** Test Cases ***
CB008290-ET-B001_Verify_A6_scell_swap_successfully_for_FTT
    [Documentation]
    ...    1. This user scenario describes A6 configuration and swap with FTT CA.
    ...    2. Configuration 
    ...        pcell(cell11):   
    ...        SCell Frequency          SCELL      Priority    a6MeasSCellSwapEnabled    
    ...        F2-TDD                   SCell1         1             rsrp                    
    ...                                 SCell2         2             rsrp                  
    ...        F3-TDD                   SCell3         1             rsrq                    
    ...                                 SCell4         2             rsrp           
    ...        F4-FDD                   SCell12                              
    ...        pcell(cell12):   
    ...        SCell Frequency          SCELL      Priority    a6MeasSCellSwapEnabled      
    ...        F2-TDD                   SCell1         1             rsrp            
    ...                                 SCell2         2             rsrp                 
    ...        F3-TDD                   SCell3         1             rsrq             
    ...                                 SCell4         2             rsrp       
    ...        F4-FDD                   SCell11 
    ...        SCell1 and scell2 have the same channel bandwidths and NRBTS/NRCELL.weightForSCellSelection
    ...        SCell3 and scell4 have the same channel bandwidths and NRBTS/NRCELL.weightForSCellSelection
    ...        NRBTS/NRCELL.weightForSCellSelection are same.
    ...    2. Test Case Steps:
    ...         a. Attach UE-1, UE-2,UE-3,UE-4 to the TDD NR cell5 and setup non-GBR SA call
    ...         b. Attach UE-5 to the FDD NR cell1 and setup non-GBR SA call
    ...             SA calls setup successfully, A1 meas for scell addition configured, mobility A2/A3/A5 configured
    ...         c. When the PCell quality goes above the threshold for the configured A1 measurement event
    ...            5G UE/Airphone sends RRC: Measurement report to the gNB for A1 event, higher than
    ...            a1ThresholdSCellAddSsbRsrpTDD, Start UL/DL data
    ...         d. A6 for scell swap measurement report from 5G-UE
    ...         e. A2 for scell4 release measurement report from UE
    ...         f. Attach UE-6, UE-7,UE-8,UE-9 to the TDD NR cell3 and setup non-GBR SA call
    ...         g. A1 for scell change measurement report from 5G-UE
    ...         h. release UE1,2,3,4 in cell5 and UE6,7,8,9 in cell3
    ...         i. A1 for scell change measurement report from 5G-UE
    ...         j. A6 for scell(CELL3) swap measurement report from 5G-UE
    ...         k. A6 for scell(CELL5) swap measurement report from 5G-UE
    ...         l. repeat step j and step k for 5 times
    ...         m. A2 for mobility measurement report from 5G-UE
    ...         n. A3 for mobility measurement report from 5G-UE, the quantity is lower than 
    ...            a1ThresholdSCellAddSsbRsrpTDD, higher than a1ThresholdSCellAddSsbRsrpFDD
    ...         o. A1 for scell change measurement report from 5G-UE
    ...         p. A6 for scell(CELL3) swap measurement report from 5G-UE
    ...         q. A6 for scell(CELL5) swap measurement report from 5G-UE
    ...         r. repeat step p and step q for 5 times
    ...         s. A2 for scell release measurement report from UE, and release ue
    [Tags]    owner-jia.pan    B001    QC_244330
    UE Attach To Target Cell1 and cell11 and trigger A1MR
    Trigger ScellSwap and ScellRelease 
    UE Attach To Target Cell3 and trigger A1MR
    UE Deregister cell1 and cell3 and trigger A1MR
    Trigger ScellSwap 5times for pcell11
    Trigger A2A3A1 for cell11 
    Trigger ScellSwap 5times for pcell12
    Trigger ScellRelease and UE Deregister
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B001${/}a2a.ini    wait_string=UEContextReleaseComplete::32
    Check Counters    ${PM_Counters_Check_B001}    

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    fddtdd_sansa_cmwv/L1B/6cells_4T2F

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=${SA_Capa_Support}    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell1 and cell11 and trigger A1MR
    Clear Counter files    True
    UE Attach To Target    1    1
    UE Attach To Target    1    2
    UE Attach To Target    1    3
    UE Attach To Target    1    4
    UE Attach To Target 
    Send Throuput
    Verify Throuput on Pscell	
    Trigger A1MR
    Verify Throuput 3CC on Pscell and Scell

UE Attach To Target Cell3 and trigger A1MR 
    UE Attach To Target    3    5
    UE Attach To Target    3    6
    UE Attach To Target    3    7
    UE Attach To Target    3    8
    Trigger A1MR With No scellchange
    Verify Throuput 2CC on Pscell and Scell	
	
UE Attach To Target 
    [Arguments]    ${cell_id}=11    ${ue_id}=81
    Update UE capa    ue_id=${ue_id}   
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=9    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=10    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=11    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Verify Throuput 3CC on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=50    ${scell_dl1}=100    ${scell_dl2}=50    ${ul}=5    ${scell_id1}=1    ${scell_id2}=2
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id1}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput1}/1000 > ${scell_dl1}
    ${scell_tput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id2}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput2}/1000 > ${scell_dl2}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput 2CC on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=50    ${scell_dl}=50    ${ul}=5    ${scell_id}=2   
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput1}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=50    ${ul}=5
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
	
Trigger A2A3A1 for cell11
    Trigger A2MR
    Verify Throuput on Pscell    #scell traffic may be reduced due to MG setup causing CSIRS conflict
    Trigger A3MR    nrsrp_nr=80    nrsrq_nr=80    
    Verify Throuput 2CC on Pscell and Scell    scell_id=1
    Trigger A1MR    carrierfreq=128890    srsrp_nr=100
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=2    scell_id2=3    

Trigger A2MR
    [Arguments]    ${event_type}=A2    ${carrierfreq}=125050    ${srsrp_nr}=20    ${srsrq_nr}=20    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger A3MR
    [Arguments]    ${event_type}=A3    ${carrierfreq}=128890    ${nrsrp_nr}=50    ${nrsrq_nr}=50    ${ue_id}=81
    ...    ${phycell_id}=61
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger A1MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=125050    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger A1MR With No scellchange
    [Arguments]    ${event_type}=A1    ${carrierfreq}=125050    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=EGATE
	
Trigger ScellSwap 5times for pcell11
    Trigger ScellSwap    carrierfreq=648096    phycell_id=51
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=3 
    Trigger ScellSwap    scell_id=3
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    
    Trigger ScellSwap    carrierfreq=648096    phycell_id=50    scell_id=2
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id2=3
    Trigger ScellSwap    phycell_id=52
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=3 	
    Trigger ScellSwap    carrierfreq=648096    phycell_id=51    scell_id=3 
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100
    Trigger ScellSwap    scell_id=2 
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id2=3
    Trigger ScellSwap    carrierfreq=648096    phycell_id=50 
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=3	
    Trigger ScellSwap    phycell_id=52    scell_id=3 
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100
    Trigger ScellSwap    carrierfreq=648096    phycell_id=51    scell_id=2
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id2=3	
    Trigger ScellSwap  
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=3

Trigger ScellSwap 5times for pcell12
    Trigger ScellSwap    carrierfreq=648096    phycell_id=51    scell_id=2
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=1    scell_id2=3    
    Trigger ScellSwap    scell_id=3
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=1    scell_id2=2
    Trigger ScellSwap    carrierfreq=648096    phycell_id=50
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=3    scell_id2=2    
    Trigger ScellSwap    phycell_id=52    scell_id=2
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=3    scell_id2=1	
    Trigger ScellSwap    carrierfreq=648096    phycell_id=51    scell_id=3
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=2    scell_id2=1
    Trigger ScellSwap
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=2    scell_id2=3	
    Trigger ScellSwap    carrierfreq=648096    phycell_id=50    scell_id=2
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=1    scell_id2=3	
    Trigger ScellSwap    phycell_id=52    scell_id=3
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=1    scell_id2=2
    Trigger ScellSwap    carrierfreq=648096    phycell_id=51
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=3    scell_id2=2    
    Trigger ScellSwap    scell_id=2
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id1=3    scell_id2=1

Trigger ScellSwap and ScellRelease
    Trigger ScellSwap
    Verify Throuput 3CC on Pscell and Scell    scell_id1=3
    Trigger ScellRelease
    Verify Throuput 2CC on Pscell and Scell    

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=508110    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=53
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
	
Trigger ScellRelease
    [Arguments]    ${event_type}=A2    ${carrierfreq}=508110    ${scell_rsrp}=7    ${scell_rsrq}=7    ${ue_id}=81    ${scell_id}=3
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    scell=${scell_id} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
	
Trigger ScellRelease and UE Deregister
    Trigger ScellRelease    carrierfreq=648096
    Verify Throuput 2CC on Pscell and Scell    scell_dl=100    scell_id=1    
    Trigger ScellRelease    scell_id=1 
    Verify Throuput on Pscell
    UE Deregister From gNB	
    
UE Deregister cell1 and cell3 and trigger A1MR
    UE Deregister From gNB    1
    UE Deregister From gNB    2
    UE Deregister From gNB    3
    UE Deregister From gNB    4
    UE Deregister From gNB    5
    UE Deregister From gNB    6
    UE Deregister From gNB    7
    UE Deregister From gNB    8
    Trigger A1MR
    Verify Throuput 3CC on Pscell and Scell    scell_dl1=130    scell_dl2=100    scell_id2=3

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
