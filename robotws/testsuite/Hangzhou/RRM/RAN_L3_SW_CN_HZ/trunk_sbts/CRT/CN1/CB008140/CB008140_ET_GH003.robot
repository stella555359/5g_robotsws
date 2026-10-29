*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-blues
...    owner-zhang.yige    release-SBTS23R3    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_Inter_Freq_HO_For_GNB1}
...    @{Emergency_Call_GNB}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_for_NRCELL_11}
...    @{PARAMS_FOR_Inter_Freq_HO_For_GNB2}
...    @{Emergency_Call_GNB}

@{Emergency_Call_GNB}

...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL:numOfRadioResReservForEmergency=10
...    NRDU-1:numOfDrbsReservForEmergency=10
...    NRCELL:pduHoSliceRelease=true
...    NRCELL:arpPrioEmergencyCall=1
...    NRCELL:emergencyCallFails=false
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:addNumOfGBRBearers=0

@{PARAMS_FOR_Inter_Freq_HO_For_GNB1}
...    NRCELL-1:ifhoSsbSmtcOffset=0
...    NRCELL-1:gapOffset=0
...    NRCELL-1:mgta=ms0
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=49
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL-1:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL-1:absThreshSsbRsrqConsolidation=20
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=3
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=368430
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=6

@{PARAMS_FOR_Inter_Freq_HO_For_GNB2}
...    NRCELL-11:ifhoSsbSmtcOffset=0
...    NRCELL-11:gapOffset=0
...    NRCELL-11:mgta=ms0
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRCELL-11:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=49
...    NRCELL-11:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL-11:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-11:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-11:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=663360
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms1024
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=6

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:ssbFrequency=655008
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:ssbFrequency=648096
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:ssbFrequency=153370
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly


@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=30
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{GNB2_CA_for_NRCELL_11}
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=3
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=2
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=4
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=40ms

@{PM_Counters_Check_GNB1}
...    NRCELL-1:${XN_HO_REQ_SENT}=${LOOP}
...    NRBTS-1:${HO_REQ_PDU_SESS_RES_SENT_SLICE}=${LOOP}
...    NRCELL-1:${XN_HO_REQ_ACK_RECEIVED}=${LOOP}
...    NRCELL-1:${ATT_HO_NRREL}=${LOOP}
...    NRCELL-1:${SUCC_HO_NRREL}=${LOOP}
...    NRCELL-1:${XN_HO_REQ__RECEIVED}=${LOOP}
...    NRCELL-1:${NF1CC_UECTXT_STP_REQSENT}=${1+${LOOP}}
...    NRCELL-1:${NF1CC_UECTXT_STP_RESPRECD}=${1+${LOOP}}
...    NRCELL-1:${XN_HO_REQ_ACK_SENT}=${LOOP}
...    NRCELL-1:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}=${LOOP}
...    NRCELL-1:${IGNB_CA_ATT_SA_REL}=${LOOP}

@{PM_Counters_Check_GNB2}
...    NRCELL-11:${XN_HO_REQ_SENT}=${LOOP}
...    ${HO_REQ_PDU_SESS_RES_SENT_SLICE}=${LOOP}
...    NRCELL-11:${XN_HO_REQ_ACK_RECEIVED}=${LOOP}
...    NRCELL-11:${ATT_HO_NRREL}=${LOOP}
...    NRCELL-11:${SUCC_HO_NRREL}=${LOOP}
...    NRCELL-11:${XN_HO_REQ__RECEIVED}=${LOOP}
...    NRCELL-11:${NF1CC_UECTXT_STP_REQSENT}=${LOOP}
...    NRCELL-11:${NF1CC_UECTXT_STP_RESPRECD}=${LOOP}
...    NRCELL-11:${XN_HO_REQ_ACK_SENT}=${LOOP}
...    NRCELL-11:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}=${LOOP}

${IGNB_CA_ATT_SA_REL}    M55118C11008      #Counts the number of inter gNB CA addition attempts released for SA.
${XN_HO_REQ_SENT}     M55143C00004
#Counted by the number of XnAP:IgNB CA UE CONTEXT RELEASE ACKNOWLEDGE message received from ext-gNB to prime-gNB-CU for SA.
#The counter is incremented in the P-Cell.
${HO_REQ_PDU_SESS_RES_SENT_SLICE}     M55149C02004
#The counter is incremented by the total number of PDU sessions included in pduSessionResourcesToBeSetup-List
#sent in XnAP: Handover Request message Updated in the source cell.
${XN_HO_REQ_ACK_RECEIVED}     M55143C00001
#The reception of an XnAP: Handover Request Acknowledge. Updated to the source cell
${ATT_HO_NRREL}     M55153C00001
#The transmission of an RRC Reconfiguration message sent by the gNB to UE for handover to target cell as per neighbor relation.
#This is updated per neighbor relation at the source side. Note: Inter-gNB NG based HO is not counted.
${SUCC_HO_NRREL}     M55153C00002
#The reception of an RRC Reconfiguration Complete message from UE in case of Intra-gNB HO or receipt of
#XnAP: UE Context release in case of Inter-gNB HO. This is updated per neighbor relation at the source side.
${XN_HO_REQ__RECEIVED}      M55143C00005    #he reception of an XnAP: Handover Request message. Updated to target cell
${NF1CC_UECTXT_STP_REQSENT}      M55113C01001     #Incremented when F1AP: UE CONTEXT SETUP REQUEST is sent by gNB-CU.
${NF1CC_UECTXT_STP_RESPRECD}      M55113C01002     #Incremented when F1AP: UE CONTEXT SETUP RESPONSE is received at gNB-CU.
${XN_HO_REQ_ACK_SENT}      M55143C00006      #The sending of an XnAP: Handover Request Acknowledge. Updated in target gNB
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}      M55145C00361
#When XnAP: Handover Request Acknowledge is sent by the target gNB. Updated to the target cell.
#Note: Inter-gNB NG based HO is not counted.

${pdu_id}    1

@{default MG setup}
...    gapUE setup
...    gapOffset 20
...    mgl ms6
...    mgrp ms80
...    mgta ms0

${LOOP}    5

*** Test Cases ***
CB008140-ET-GH003_EC_call_Xn_inter_freq_Handover_outgoing_in_IgNB_CA_mode_TTT_to_ext_gNB2_intra_gNB_CA_FTT_covBasedA1_rsrqCombined
    [Documentation]
    ...    This case is to Verify EC CALL handover, Meaurement Gap interworking with Ignb-CA.
    ...    [Configuration]:
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=663400:663400 gscn=8159
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on nr_arfcn=658000:658000 gscn=8103
    ...    set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on nr_arfcn=653400:653400 gscn=8072
    ...    set_cell id=4 gnb=3 pci=17:2 tac=200 nrci=0x04 tdd_cell=on nr_arfcn=648000:648000 gscn=8000
    ...    set_cell id=11 gnb=3 pci=20:0 tac=200 nrci=0x0B tdd_cell=off nr_arfcn=349400:368400 gscn=4605
    ...    set_cell id=12 gnb=3 pci=20:1 tac=200 nrci=0x0C tdd_cell=off nr_arfcn=143400:153400 gscn=1916
    ...    2.Test Case Steps:
    ...    a. UE1 Register And Eergency Call Setup <5QI5 then 5QI1> On GNB1 NRCELL-1, blind scell addition GNB2 NRCELL-3,4
    ...    b. Inter Freq inter GNB HO from GNB1 NCELL-1 to GNB2 NRCELL-11 as Pcell, Measurement Gap setup when A2 MR report
    ...    c. Coverbased A1 add GNB2 NRCELL-3,4 as Scells
    ...    d. Inter Freq inter GNB HO from GNB2 NRCELL-11 to as GNB1 NCELL-1 Pcell, blind scell addition GNB2 NRCELL-3,4
    ...    and Measurement Gap setup when A2 MR report
    ...    e. repeat stepb-stepd 4 more times
    ...    f. check counters update

    [Tags]    GH003    QC_277930    CA_LABEL-TTT(100Mhz_TDD_n77+100Mhz_TDD_n77+40Mhz_TDD_n77)-FTT(10Mhz_FDD_n3+100Mhz_TDD_n77+40Mhz_TDD_n77)
    Clear Counter Files for 2GNB
    EC and IGNB Blind Scells addition
    Run Traffic And Verify Throughput in GNB1
    Handover Between GNB1 and GNB2 5 times
    Check Counters    ${PM_Counters_Check_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_GNB2}
    check wireshark log    ${CURDIR}${/}A2A_GH_003${/}a2a.ini    wait_string=UEContextRelease::40

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Handover Between GNB1 and GNB2 5 times
    FOR    ${index}    IN RANGE    0    ${LOOP}
        Inter Freq inter GNB HO From Ncell 1 to Nrcell 11
        A1 Based Scell Addition
        Sleep    2s
        Run Traffic And Verify Throughput in GNB2
        Inter Freq inter GNB HO From Ncell 11 to Nrcell 1
        Sleep    2s
        Run Traffic And Verify Throughput in GNB1
    END

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Run Traffic And Verify Throughput in GNB1
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Run Keywords    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    405    45
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Run Traffic And Verify Throughput in GNB2
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${numofrepeat}=7
    FOR    ${i}    IN RANGE    1    ${numofrepeat}
        Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=${i}    UE ${ue_id}: UDP DL
    END
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=20 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    405    15
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${numofrepeat}=7
    FOR    ${i}    IN RANGE    1    ${numofrepeat}
        Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=${numofrepeat}
        ...    pass_regexp=Traffic was stopped
    END
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1
    ...    pass_regexp=Stopping Uplink Internal traffic on Ue

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-2] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1 ue=1-12
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-12 qos_flows=2,1 qos_rules=1,2 amf=1
    Update Cfg    ue_nr_capabilities id=1-12 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g

EC and IGNB Blind Scells addition
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    UE Register And Add Pdu With emergency call    ue_id=1
    PDU Add QoSFlow 5QI1    ue_id=1

UE Register And Add Pdu With emergency call
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${cmd_emergency}=    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ...    request_type=initial-emergency-request
    Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:1

A1 Based Scell Addition
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=368430    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A1 srsrp_nr=80
    ...    eventId

Inter Freq inter GNB HO From Ncell 1 to Nrcell 11
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=663360    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A2 srsrp_nr=25
    ...    pass_regexp=${default MG setup}
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=368430    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=60 nrsrp_nr=80
    ...    PATH SWITCH REQUEST ACK

Inter Freq inter GNB HO From Ncell 11 to Nrcell 1
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=368430    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A2 srsrp_nr=25
    ...    eventId eventA3
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=663360    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=50 nrsrp_nr=80
    ...    PATH SWITCH REQUEST ACK



