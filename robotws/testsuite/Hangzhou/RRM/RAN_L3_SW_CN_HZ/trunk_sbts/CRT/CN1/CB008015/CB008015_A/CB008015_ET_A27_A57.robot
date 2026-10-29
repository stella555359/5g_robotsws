*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BLLL_AP_LOO
...    owner-baijie.zhu    owner-jianfen.shen    team-SG2    release-5G22R2    CB008015
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F
${CA_support_list}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa

@{PARAMS_IN_SCF}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true

...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}

...    NRBTS-1/NRCELL:pucchModeSelect=longPucch

...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actCDrx=true
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL-1:msg1FrequencyStart=19
...    NRCELL-2:msg1FrequencyStart=19
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13

...    NRCELL-12/NRREL:sCellAdditionMethod=covBasedA1

...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

...    NRCELL-11/NRREL:sCellAdditionMethod=covBasedA1

...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

...    NRCELL-13/NRREL:sCellAdditionMethod=covBasedA1

...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:nrDcAllowed=false
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:nrDcAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:nrDcAllowed=false
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:nrDcAllowed=false
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=20
...    NRCELL-1:weightForSCellSelection=40
...    NRCELL-2:weightForSCellSelection=90
...    NRCELL-12:weightForSCellSelection=30

@{Delta_Commission_A57}
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0

...    NRBTS-1/NRCELL-12:actAperCsi=true
...    NRBTS-1/NRCELL-11:actAperCsi=true
...    NRBTS-1/NRCELL-13:actAperCsi=true

...    MRBTS-1/NRBTS-1/NRCELL-12:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12/NRHOIF-3:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-3:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-3:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-3:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-3:ssbFrequency=427970
...    NRCELL-12/NRHOIF-3:a4MeasEnDcSteeringEnabled=none
...    NRCELL-12/NRHOIF-3:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-12/NRHOIF-3:a4MeasNrDcEnabled=none
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp

...    MRBTS-1/NRBTS-1/NRCELL-13:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeashoEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-13/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-13/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=126750
...    NRCELL-13/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-13/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-13/NRHOIF-1:a4MeasNrDcEnabled=none
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160


${ue_id_81}    81

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970

&{CELLS_PHYCELL_ID}
...     1=50
...     2=51
...     11=60
...     12=61
...     13=62

*** Test Cases ***
CB008015-ET-A27_A_B4_A1 scell selection based on different weighted scell bandwidth when TDD scell weight higher than FDD
    [Documentation]
    ...    1. The purpose of this test case is to check SCell selection based on different weighted SCell bandwidth when TDD scell weight higher
    ...       than FDD - mixed Mode of FDD-FR1 TDD CA and FDD-FDD CA
    ...       UE 81:
    ...       SA_Capa_Full: TDD: n41 n78 FDD: n66 n71
    ...       3CC: n41+n78+n66 n41+n66+n71 n41+n66+n66 n41+n71+n71 n66+n66+n71 n66+n71+n71 n78+n66+n71
    ...       2CC: n66+n71 n41+n71 n41+n78 n41+n66 n66+n71 n66+n78 n78+n71
    ...       Final weight order in Cell 2 > (Cell 11+ Cell 13) > cell 13 > Cell 1 > Cell 11 of cell 12 is P(S) cell
    ...    2. Test Case Steps:
    ...       a.Make SA UE-81 attach to cell 12 , start data transfer
    ...       b.check A1 meas config in RRC Reconfig
    ...       c.A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE81
    ...       d.Release the call and lock cell 2, make a new call again with PDU session for data transferring
    ...       e.A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE81
    ...       f.Release the call and lock cell1 and cell 2, make a new call again with PDU session for data transferring
    ...       g.A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE81
    ...       h.Release the call and unlock Cell 1 and Cell 2
    ...       i.All cells are unlocked.make a new call again with PDU session for data transferring
    ...       j.check A1 meas config in RRC Reconfig
    ...       k.A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD but lower than
    ...       a1ThresholdSCellAddSsbRsrpTDD for SA UE81
    ...       l.A2 scell Release trigger
    ...       m.release the call for SA UE81
    ...    3. Expected Results:
    ...       Step c: cell2 is added as bFDD-FR1 TDD 2CC CA,A1 measurement is deactivated after SCell addition is done
    ...       Step d: Call release and cell2 lock are successfully
    ...       Step e: cell1 is added as FDD-FR1 TDD 2CC CA,A1 measurement is deactivated after SCell addition is done
    ...       Step f: Call release and cell1 and cell 2 lock are successfully
    ...       Step g: cell11 and cell13 is added as FDD-FR1 TDD 3CC CA
    ...       Step h: Release the call and unlock Cell 1 and Cell 2
    ...       Step k: cell11 and cell13 is added as FDD-FR1 TDD 3CC CA,A1 measurement for SCell addition is reconfigured with higher threshold
    ...       after SCell addition is done
    ...       Step l: SCell release successfully
    ...       Step m: ue release successfully
    [Tags]    CB008015-ET-A27    QC_128164
    [Timeout]    2 hours
    Change UE Location And Start Call
    SCell_2 Addition based on A1 RSRP higher than Threshold for both TDD and FDD
    Release Call And Lock Cell2
    Change UE Location And Start Call
    SCell_1 Addition based on A1 RSRP higher than Threshold for both TDD and FDD
    Release Call And Lock Cell1
    Change UE Location And Start Call
    SCell_11 and SCell_13 Addition based on A1 RSRP higher than Threshold for both TDD and FDD
    Unlock Cell2 and Cell1
    SCell_11 and SCell_13 Addition based on A1 RSRP between Threshold for TDD and FDD

CB008015-ET-A57_A_B10_Online modification of weightForSCellSelection
    [Documentation]
    ...    1. The purpose of this test case is to check SCell selection is correct with Online modification parameter weightForSCellSelection
    ...       UE 81:
    ...       SA_Capa_Full:TDD: n41 n78 FDD: n66 n71
    ...       3CC: n41+n78+n66 n41+n66+n71 n41+n66+n66 n41+n71+n71 n66+n66+n71 n66+n71+n71 n78+n66+n71
    ...       2CC: n66+n71 n41+n71 n41+n78 n41+n66 n66+n71 n66+n78 n78+n71
    ...       Final weight order in Cell 2 > (Cell 11 + Cell 13) > Cell 13 > Cell 1 > Cell 11 of cell 12 is P(S) cell
    ...       actAperCsi=True in cell11,12,13;actAperCsi=False in cell1,2;actHoOptimizationCa=true
    ...    2. Test Case Steps:
    ...       a.Make SA UE-81 attach to cell 12 , start data transfer
    ...       b.check A1 meas config in RRC Reconfig
    ...       c.A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE81
    ...       d.Online modification parameter weightForSCellSelection to (Cell 11+ cell 13) > cell 1 > cell 2 = cell 13 > cell 11
    ...       e.A2 scell release trigger for UE81, A2 measurement report based SCell release is triggered, rsrp value lower than
    ...       a2ThresholdSCellRelSsbRsrp for SA UE81
    ...       f.A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE81
    ...       g.intra-freq HO to cell3, and ho back to cell1
    ...       h.A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD for SA UE81
    ...       i.Online modification parameter weightForSCellSelection to Cell 2 > (Cell 11 + Cell 13) > Cell 13 > Cell 1 > Cell 11
    ...       j.A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE81
    ...       k.A2 scell Release trigger
    ...       l.release the call for SA UE81
    ...     3. Expected Results:
    ...        Step c: cell2 is added as FDD-FR1 TDD 2CC CA,A1 measurement is deactivated after SCell addition is done
    ...        Step e: SCell release successfully
    ...        Step f: cell1 is added as FDD-FR1 TDD 2CC CA,A1 measurement is deactivated after SCell addition is done
    ...        Step g: intra-freq HO to cell13 and ho back to cell12 is successfully
    ...        Step j: cell2 is added as FDD-FR1 TDD 2CC CA,A1 measurement is deactivated after SCell addition is done
    ...        Step k: SCell release successfully
    ...        Step l: Step m: ue release successfully
    [Tags]    CB008015-ET-A57    QC_128178
    [Timeout]    2 hours
    Delta Commission For A57
    Change UE Location And Start Call
    SCell_2 Addition based on A1 RSRP higher than Threshold for both TDD and FDD
    Online Modify weightForSCellSelection And Release SCell_2
    SCell_1 Addition based on A1 RSRP higher than Threshold for both TDD and FDD
    Inter-freq HO to Cell13 and HO back to Cell12
    Online Modify weightForSCellSelection For Cell2    90
    SCell_2 Addition based on A1 RSRP higher than Threshold for both TDD and FDD    scell_index=3
    Release SCell_2 And Release Call


*** Keywords ***
Modify Cfg
    Update Cfg    ue_param id=${ue_id_81} ue_nr_capabilities=${SA_Capa_perUE_Full}

Change UE Location
    [Arguments]    ${ue_id}    ${target_cell}
    ${return1}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}    location
    Should Contain Any    ${return1}    location updated    already there

UE Attach and Start L3 Call
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    ...                      pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=5
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 dir=ul mbps=5
    ...                      pass_regexp=UE${ue_id}: Started Uplink Internal traffic

Triggered Scell Addition by A1 Event
    [Arguments]    ${ue_id}    ${rsrp}    ${rsrq}    ${scell_num}
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency
    ...           ${ue_id}    carrierfreq=${pcell_carrier_freq}    event_type=A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

Check Scell Number
    [Arguments]    ${ue_id}    ${expected_scell_num}
    ${meas_obj}     Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_obj}
    ${meas_obj_num}    Get Length      ${meas_data['nr_measurment_objects']}
    ${real_scell_num}    Evaluate    ${meas_obj_num}-1
    Should Be Equal As Integers     ${expected_scell_num}    ${real_scell_num}

Release Scell
    [Arguments]    ${ue_id}      @{scell_list}
    ${scell_index}    set variable    1
    FOR    ${scell}    IN    @{scell_list}
        ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell}
        ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${carrier_freq}    A2
        ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
        ...    scell=${scell_index} scell_rsrp=20 scell_rsrq=20
        Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
        ${scell_index}    evaluate    ${scell_index}+1
    END

UE Detach
   [Arguments]    ${ue_id}
   Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off
   ...                     pass_regexp=UE${ue_id}: detached

Change UE Location And Start Call
    [Arguments]    ${ue_id}=${ue_id_81}
    Change UE Location    ${ue_id}    12
    UE Attach and Start L3 Call    ${ue_id}

### kws for A27 ###
SCell_2 Addition based on A1 RSRP higher than Threshold for both TDD and FDD
    [Arguments]    ${ue_id}=${ue_id_81}    ${rrc_log_tag}=SCell_2_Higher    ${scell_index}=1
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ${ue_id}    rsrp=120    rsrq=8    scell_num=${scell_index}
    Check Scell Number    ${ue_id}    expected_scell_num=1
    ${phycell_id}    Get From Dictionary    ${CELLS_PHYCELL_ID}    2
    Rrc Should Contain    sCellToAddModList    physCellId ${phycell_id}

Release Call And Lock Cell${number}
    Release Scell    ${ue_id_81}    ${number}
    UE Detach    ${ue_id_81}
    Change UE Location    ${ue_id_81}    12
    Lock Cell${number}

SCell_1 Addition based on A1 RSRP higher than Threshold for both TDD and FDD
    [Arguments]    ${ue_id}=${ue_id_81}    ${rrc_log_tag}=SCell_1_Higher
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ${ue_id}    rsrp=120    rsrq=8    scell_num=1
    Check Scell Number    ${ue_id}    expected_scell_num=1
    ${phycell_id}    Get From Dictionary    ${CELLS_PHYCELL_ID}    1
    Rrc Should Contain    sCellToAddModList    physCellId ${phycell_id}

SCell_11 and SCell_13 Addition based on A1 RSRP higher than Threshold for both TDD and FDD
    [Arguments]    ${ue_id}=${ue_id_81}    ${rrc_log_tag}=SCell_11_13_Higher
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ${ue_id}    rsrp=120    rsrq=8    scell_num=2
    Check Scell Number    ${ue_id}    expected_scell_num=2
    ${phycell_id11}    Get From Dictionary    ${CELLS_PHYCELL_ID}    11
    ${phycell_id13}    Get From Dictionary    ${CELLS_PHYCELL_ID}    13
    Rrc Should Contain    sCellToAddModList    physCellId ${phycell_id11}    physCellId ${phycell_id13}
    Release Scell    ${ue_id}    11    13
    UE Detach    ${ue_id}

SCell_11 and SCell_13 Addition based on A1 RSRP between Threshold for TDD and FDD
    [Arguments]    ${ue_id}=${ue_id_81}    ${rrc_log_tag}=SCell_11_13_Between
    Change UE Location And Start Call    ${ue_id}
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ${ue_id}    rsrp=50    rsrq=8    scell_num=2
    Check Scell Number    ${ue_id}    expected_scell_num=2
    ${phycell_id11}    Get From Dictionary    ${CELLS_PHYCELL_ID}    11
    ${phycell_id13}    Get From Dictionary    ${CELLS_PHYCELL_ID}    13
    Rrc Should Contain    sCellToAddModList    physCellId ${phycell_id11}    physCellId ${phycell_id13}
    Release Scell    ${ue_id}    11    13
    UE Detach    ${ue_id}

Unlock Cell2 and Cell1
    Unlock Cell2
    Unlock Cell1

### kws for A57 ###
Delta Commission For A57
    Delta Commission Parameters    ${Delta_Commission_A57}
    sleep    10s    wait the MIB/SIB for CELL11/12/13 as actAperCsi=true

Online Modify weightForSCellSelection For Cell2
    [Arguments]    ${weight}
    Delta Commission Parameters    NRCELL-2:weightForSCellSelection=${weight}

Online Modify weightForSCellSelection And Release SCell_2
    [Arguments]    ${ue_id}=${ue_id_81}
    Online Modify weightForSCellSelection For Cell2    30
    Release Scell    ${ue_id}    2

Inter-freq HO to Cell13 and HO back to Cell12
     [Arguments]    ${ue_id}=${ue_id_81}
     Tirgger Inter-Frequency Intra-gNB HO To Cell13
     Tirgger Inter-Frequency Intra-gNB HO Back To Cell12

Tirgger Inter-Frequency Intra-gNB HO To Cell13
    Tirgger Inter-Frequency Intra-gNB HO To New Cell    ${ue_id_81}    12    13

Tirgger Inter-Frequency Intra-gNB HO Back To Cell12
    Tirgger Inter-Frequency Intra-gNB HO To New Cell    ${ue_id_81}    13    12

Tirgger Inter-Frequency Intra-gNB HO To New Cell
    [Arguments]    ${ue_id}    ${s_cell}    ${t_cell}
    ${source_cell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${s_cell}
    ${target_cell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${t_cell}
    ${phycell_id}    Get From Dictionary    ${CELLS_PHYCELL_ID}    ${t_cell}
    ${meas_id_a2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${source_cell_carrier_freq}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_a2} event=A2 srsrp_nr=11 srsrq_nr=11
    Execute Egate Command    ${cmd}    rrcReconfigurationComplete
    ${meas_id_a3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${target_cell_carrier_freq}    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_a3} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=20
    Execute Egate Command    ${cmd}    Intra-eNB handover from EXT_ENB-2.${s_cell} to EXT_ENB-2.${t_cell} performed
    Verify Throughput

Verify Throughput
    [Arguments]    ${ue_id}=${ue_id_81}    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Throughput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps

Release SCell_2 And Release Call
    [Arguments]    ${ue_id}=${ue_id_81}    ${scell_index}=3
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     2
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${carrier_freq}    A2
    ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
    ...    scell=${scell_index} scell_rsrp=20 scell_rsrq=20
    Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
    UE Detach    ${ue_id}
