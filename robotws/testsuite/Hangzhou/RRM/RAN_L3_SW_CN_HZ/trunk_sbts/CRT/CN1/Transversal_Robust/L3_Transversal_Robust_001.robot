*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    owner-chen.yili    release-SBTS00    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${AP_UDPLOG_FLAG}    ${False}
${BTSLOG_FLAG}    ${False}
${WIRESHARK_FLAG}    ${False}

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
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true

@{PARAMS_FOR_GNB1}
...    NRBTS:timerRRCGuard=6000
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRDU-1:flexibleCAMode=ConfigurationIndependent

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
...    NRBTS:timerRRCGuard=6000
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
...    NRDU-1:flexibleCAMode=NumberCellAmount

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

${SA_Capa_NOTSupport_CA}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623809DC6C06C0D608C21A0810748046D6C
...    98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000280381506C02D608C21A081078804656C98AB12
...    1CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000500702A8D899AC1184341020E9008C2D931544439F11C788E
...    3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000500702A0D837AC1184341020F1008CAD931562439F11C7B027C62471E439F
...    51CF9863CA1607038784FFF800003FFE000000A00E0551B1375823086800001001185B24CA88873E238F20C7A067D813E01CF9863CA16
...    07038782F55555553D55555540A00E0062C5C02000C010181B0002058158F8040018060303606134000A160562E01000606C0C2600018
...    2C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02
...    000C030181B00060581587836001C4C00001A160562E2600060080C0D800402C0AC7C4D000C01018060303600110B0201200DC0068099
...    000A02682A990644891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73
...    E1C4891226C73E1C28913639F0E2448913639F0E344891226C73E181B1218C6318C6318C6318C6318C1E81601E00140E0601C0C01501C
...    0018090010180F82400800000004002000000080000300400000802000008010000060080000400400002802001004010040000300200
...    001C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652DE4CD
...    E02D606D6025604560ED0341000009652504000065949810000196524040000E594901000049652404000165949810000696524040001
...    E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A
...    2A94C55268AA031540A2A93555078A022F012A05028140A05028140A05028140A05028140A05028008840400801010020044020040080
...    801002020040088040300501002004040080118080600A020180280801002020040088040400501010014040580B18080600C02018028
...    080600C02004008804030050100C014040080108080600A02004008404030050100C014202018030080600C10100C0180403005080806
...    00A02018028804030050100C018040300508080600C020040088040080101002004040300518080100202004008080600A02018028804
...    008010100C018040300618080100202018028080600C02018028D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139
...    414951697A0A0C1680

${pdu_id}    1

@{default MG setup}
...    gapUE setup
...    mgl ms6
...    mgrp ms80
...    mgta ms0

${UE1_expect}    UE-1 PDU SESSION ID-1 setup/reestablishment complete

@{UE3_expect}
...    pcid:50, scellIdx:0
...    pcid:52, scellIdx:1
...    pcid:53, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

${LOOP}    5

*** Test Cases ***
L3_Transversal_Robust_001_Verify gNB RRM service when XN link break and recover
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
    ...    Step 1    delta commission two gNB to enable the 5GC000706, 5GC000732 and CB008140, the scell addition and activation method are blind    
    ...    Step 2    In egate, attach below UEs to gNB-1 Cell-1 UE-1(no CA capability) with non-GBR trafficUE-2 with VONR trafficUE-3 (CA capability)
    ...              with non-GBR traffic
    ...    Step 3    trigger UE-1 HO to gNB-2 Cell-11 but block the RrcConfigurationComplete msg sending
    ...    Step 4    ssh to gNB-1, use iptables command to block gNB-2 IP and send the RrcConfigurationComplete in egate
    ...    Step 5    ssh to gNB-1, recover the iptables to unblock the gNB-2 IP
    ...    Step 6    Attach the UE-3 to gNB-1 cell-1
    ...    Step 7    trigger XN HO for UE-2 and UE-3 to gNB-2 cell-11
    ...    Step 8    trigger XN HO for UE-1, UE-2, UE-3 to gNB-1 cell-1
    ...    Step 9    repeat
    ...    3.expected results:
    ...    Step 1    two gNBs are on air, XN link between two gNBs are established
    ...    Step 2    UE-1attach succeed with traffic UE-2 attach succeed with VONR call 
    ...              UE-3 CA setup with gNB-2 Cell-11 as scell succeed, scell and pcell traffic is OK.
    ...    Step 3    UE-1 attach to gNB-2 Cell-2 and traffic is OK
    ...    Step 4    XN link is down, UE-2 no impact, UE-3 is released, UE-1 context should be released at gNB-1(5G_CP_MM_5009,5G_CP_MM_4199). 
    ...              UE-1 should still connected in gNB-3 cell-11
    ...    Step 5    After sometime, the XN link should recover to normal
    ...    Step 6    UE-3 setup the CA with gNB-2 cell-11 and Pcell and Scell both traffic OK
    ...    Step 7    UE-2 and UE-3 HO to gNB-2 Cell-11 succeed
    ...    Step 8    UE-1, UE-2, UE-3 HO to gNB-1 cell-1 succeed. UE-3 CA setup succeed, Pcell and Scell both traffic is OK
    [Tags]    QC_47194
    Start to capture UDP Logs
    UE1 without CA with non-GBR traffic
    UE2 with VONR traffic
    UE3 with CA with non-GBR traffic
    delay RrcConfigurationComplete and trigger UE-1 HO then kill XN
    Recover XN and attach UE1 UE2 UE3
    Stop to capture UDP Logs
    Handover Between GNB1 and GNB2 5 times
    Execute Case Step For Loop
    [Teardown]    STOP all Logs

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Start to capture UDP Logs
    [Arguments]
    ...    ${AP_UDPLOG_FLAG}=True
    ...    ${BTSLOG_FLAG}=True
    ...    ${WIRESHARK_FLAG}=True
    ...    ${BTSlog}=GNB1_BTSlog
    ...    ${UDPlog}=AP_UDPlog
    ...    ${BTSlog2}=GNB2_BTSlog
    ...    ${Wireshark1}=Wireshark_gnb1
    ...    ${Wireshark2}=Wireshark_gnb2 
    Start To Capture BTS UdpLogs    ${BTSlog}
    Start To Capture BTS UdpLogs GNB2    ${BTSlog2}
    Start To Capture Iphy Udplog    ${UDPlog}
    Start To Capture Wireshark Log    ${Wireshark1}
    start to capture wireshark log gnb2    ${Wireshark2}

Stop to capture UDP Logs
    [Arguments]
    ...    ${AP_UDPLOG_FLAG}=True
    ...    ${BTSLOG_FLAG}=True
    ...    ${WIRESHARK_FLAG}=True
    ...    ${BTSlog}=GNB1_BTSlog
    ...    ${UDPlog}=AP_UDPlog
    ...    ${BTSlog2}=GNB2_BTSlog
    ...    ${Wireshark1}=Wireshark_gnb1
    ...    ${Wireshark2}=Wireshark_gnb2
    Stop Capture BTS UdpLogs    ${BTSlog}
    Stop Capture BTS UdpLogs GNB2     ${BTSlog2}
    Stop Capture Iphy Udplog
    Stop Capture Wireshark Log    ${Wireshark1}
    Stop Capture Wireshark Log GNB2    ${Wireshark2}

STOP all Logs
    Run Keyword And Ignore Error    Stop to capture UDP Logs
    Run Keyword And Ignore Error    Stop To Capture GNB BIP Log    tag=gnb_1_bip
    Run Keyword And Ignore Error    Stop To Capture GNB BIP Log GNB2    tag=gnb_2_bip
    Run Keyword And Ignore Error    Stop to capture UDP Logs    GNB1_HO    AP_HO    GNB2_HO    W1_HO    W2_HO

UE1 without CA with non-GBR traffic
    UE Register And Add Pdu    ue_id=1    Expect=UE-1 PDU SESSION ID-1 setup/reestablishment complete
    Run Traffic without CA    ue_id=1    pdu=1    qfi=1
    Verify Throughput    ue_id=1    Tput_dl=8.5    Tput_ul=3.6

UE2 with VONR traffic
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    UE Register And Add Pdu With emergency call    ue_id=2
    PDU Add QoSFlow 5QI1    ue_id=2
    Run Traffic without CA    ue_id=2    pdu=1    qfi=1
    Verify Throughput    ue_id=2    Tput_dl=8.5    Tput_ul=3.6

UE3 with CA with non-GBR traffic
    UE Register And Add Pdu    ue_id=3    Expect=${UE3_expect}
    Run Traffic with CA
    Verify Throughput    ue_id=3    Tput_dl=8.5    Tput_ul=3.6

delay RrcConfigurationComplete and trigger UE-1 HO then kill XN
    [Arguments]    ${ue_id}=1
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=663360    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A2 srsrp_nr=25
    ...    pass_regexp=${default MG setup}
    Execute Egate Command    ue_nr_rrc_reconf_param id=1 if_contains=any delay=1500
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=368430    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=60 nrsrp_nr=80
    ...    PATH SWITCH REQUEST ACK
    Execute Command On Enb    iptables -t filter -A OUTPUT -p sctp --dport 38422 -j DROP
    Execute Command On Enb    ip6tables -t filter -A OUTPUT -p sctp --dport 38422 -j DROP
    ${enb_id}    ${cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${enb_id}    3
    Should Be Equal    ${cell_id}    11
    #Wait Until Keyword Succeeds    30s    2s    Verify UE3 Throughput 0

Recover XN and attach UE1 UE2 UE3
    Execute Command On Enb     iptables -t filter -F OUTPUT
    Execute Command On Enb     ip6tables -t filter -F OUTPUT
    Wait Until Keyword Succeeds    300s    2s    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    Verify Throughput    ue_id=1    Tput_dl=8.5    Tput_ul=3.6
    Verify Throughput    ue_id=2    Tput_dl=8.5    Tput_ul=3.6
    Execute Egate Command    ue_deregister id=3 ue_deregister_type=switch_off    pass_regexp=UE3: detached    timeout=10s
    UE3 with CA with non-GBR traffic
    Inter Freq inter GNB HO From Ncell 11 to Nrcell 1    ue_id=1

Handover Between GNB1 and GNB2 5 times
    FOR    ${index}    IN RANGE    0    5
        Start to capture UDP Logs    GNB1_HO    AP_HO    GNB2_HO    W1_HO    W2_HO
        Start To Capture GNB BIP Log    tag=gnb_1_bip
        Start To Capture GNB BIP Log GNB2    tag=gnb_2_bip
        Inter Freq inter GNB HO From Ncell 1 to Nrcell 11    ue_id=1
        Inter Freq inter GNB HO From Ncell 1 to Nrcell 11    ue_id=2
        Inter Freq inter GNB HO From Ncell 1 to Nrcell 11    ue_id=3
        Verify Throughput    ue_id=1    Tput_dl=8.5    Tput_ul=3.6
        Verify Throughput    ue_id=2    Tput_dl=8.5    Tput_ul=3.6
        Verify Throughput    ue_id=3    Tput_dl=8.5    Tput_ul=3.6
        Inter Freq inter GNB HO From Ncell 11 to Nrcell 1    ue_id=1
        Inter Freq inter GNB HO From Ncell 11 to Nrcell 1    ue_id=2
        Inter Freq inter GNB HO From Ncell 11 to Nrcell 1    ue_id=3
        Verify Throughput    ue_id=1    Tput_dl=8.5    Tput_ul=3.6
        Verify Throughput    ue_id=2    Tput_dl=8.5    Tput_ul=3.6
        Verify Throughput    ue_id=3    Tput_dl=8.5    Tput_ul=3.6
        Stop To Capture GNB BIP Log    tag=gnb_1_bip
        Stop To Capture GNB BIP Log GNB2    tag=gnb_2_bip
        Stop to capture UDP Logs    GNB1_HO    AP_HO    GNB2_HO    W1_HO    W2_HO
    END
    UE Deregister From gNB

UE Deregister From gNB
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    pass_regexp=UE1: detached    timeout=10s
    Execute Egate Command    ue_deregister id=2 ue_deregister_type=switch_off    pass_regexp=UE2: detached    timeout=10s
    Execute Egate Command    ue_deregister id=3 ue_deregister_type=switch_off    pass_regexp=UE3: detached    timeout=10s

Run Traffic without CA
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=10 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=5 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue

Run Traffic with CA
    [Arguments]    ${ue_id}=3    ${pdu}=1    ${qfi}=1
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

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-2] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify UE3 Throughput 0
    [Arguments]    ${ue_id}=3    ${pdu}=1    ${qfi}=1    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Match Regexp    ${scell_tput}    CellIndex-[0-2] *0 *0 *0

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1 ue=1-12
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-12 qos_flows=2,1 qos_rules=1,2 amf=1
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_NOTSupport_CA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_NOTSupport_CA}

UE Register And Add Pdu With emergency call
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${cmd_emergency}=    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ...    request_type=initial-emergency-request
    Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

UE Register And Add Pdu
    [Arguments]    ${ue_id}    ${Expect}
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${cmd}=    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    Execute Egate Command    ${cmd}    pass_regexp=${Expect}

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:1

Inter Freq inter GNB HO From Ncell 1 to Nrcell 11
    [Arguments]    ${ue_id}=1
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=663360    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=25
    ...    pass_regexp=${default MG setup}
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=368430    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=60 nrsrp_nr=80
    ...    PATH SWITCH REQUEST ACK

Inter Freq inter GNB HO From Ncell 11 to Nrcell 1
    [Arguments]    ${ue_id}=1
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=368430    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=25
    ...    eventId eventA3
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=663360    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=50 nrsrp_nr=80
    ...    PATH SWITCH REQUEST ACK

Execute Case Step For Loop
    FOR    ${id}    IN RANGE    1    ${LOOP}
    Start to capture UDP Logs
    UE1 without CA with non-GBR traffic
    UE2 with VONR traffic
    UE3 with CA with non-GBR traffic
    delay RrcConfigurationComplete and trigger UE-1 HO then kill XN
    Recover XN and attach UE1 UE2 UE3
    Stop to capture UDP Logs
    Handover Between GNB1 and GNB2 5 times
    END
