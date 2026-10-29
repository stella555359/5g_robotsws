*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-CN1ET
...    owner-zhang.yige    release-SBTS23R3    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
#${TTITRACE_FLAG}    ${False}
#${SOS_REPORT_FLAG}    pass:False,fail:False
#${SNAPSHOT_FLAG}    pass:False,fail:False

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_Inter_Freq_HO_For_GNB1}
...    @{Emergency_Call_GNB}
...    @{8311_enable_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_for_NRCELL_11}
...    @{PARAMS_FOR_Inter_Freq_HO_For_GNB2}
...    @{Emergency_Call_GNB}
...    @{8311_enable_GNB2}

@{8311_enable_GNB1}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=5
...    NRCELL:dlSCellConfigLevelNum=6
...    NRCELL-2:dlSCellConfigLevel=6
...    NRCELL-2:dlSCellConfigLevelNum=10
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRBTS:actOverheatingAssistance=true
...    NRBTS:caBackoffTimerUeOh=20
...    NRBTS:timerOverheatIndProhibit=1s
...    NRBTS:timerPostOverheating=5
...    NRBTS:sCellDeactivationBadRlqCount=1      #bad rlq
...    NRCELL:sCellGoodChannelQualityThreshold=10
...    NRCELL:sCellBadChannelQualityThreshold=4
...    NRCELL:sCellChannelEstimationPeriod=2000
...    NRBTS:actSCellReleaseBadSCellRlq=enabled_Fr1
...    NRBTS:sCellExcludelistTimerFr1=30
...    NRCELL:dllaDeltaCqiMax=150
...    NRCELL:dllaDeltaCqiMin=-150

@{8311_enable_GNB2}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=5
...    NRCELL:dlSCellConfigLevelNum=6
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRCELL-12:sCellInactivityReleaseTimer=5
...    NRBTS:sCellDeactivationBadRlqCount=1
...    NRBTS:actSCellReleaseBadSCellRlq=enabled_Fr1    #bad rlq
...    NRBTS:sCellExcludelistTimerFr1=30
...    NRCELL:dllaDeltaCqiMax=150
...    NRCELL:dllaDeltaCqiMin=-150

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
...    NRBTS:sCellActivationMethod=bufferBased
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
...    NRCELL:maxNumScellsDlFr1=3

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:chBw=40MHz

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
...    NRBTS/NRADJNRCELL-3:nrarfcn=648020
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
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
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
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly


@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:sCellDeactivationTimerGNB=ms1280
...    NRCELL-4:sCellDeactivationTimerGNB=ms1280
...    NRCELL-11:sCellDeactivationTimerGNB=ms640
...    NRCELL-12:sCellDeactivationTimerGNB=ms640
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=30
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL-3:chBw=40MHz
...    NRCELL-3:nrarfcn=648020
...    NRCELL-3:gscnOrSsPbchArfcn=8000

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
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=2
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

@{E002_E003_PM_Counters_Check_GNB1}
...    NRCELL-1:${DL_RRC_1EXTSCELL_REL_ATT_SA}=6
...    NRCELL-1:${DL_RRC_1EXTSCELL_REL_SUC_SA}=6
...    NRCELL-1:${INA_PRO_REL_SCELL_ATT_SA}=3
...    NRCELL-1:${INA_PRO_REL_SCELL_SUC_SA}=3
...    NRCELL-1:${INA_OVHT_REL_SCELL_ATT_SA}=3
...    NRCELL-1:${INA_OVHT_REL_SCELL_SUC_SA}=3

#@{E002_E003_PM_Counters_Check_GNB2}
#...    NRCELL-11:${XN_HO_REQ_SENT}=${LOOP}

@{E004_PM_Counters_Check_GNB2}
...    NRCELL-11:${DL_RRC_1EXTSCELL_REL_ATT_SA}=2
...    NRCELL-11:${DL_RRC_1EXTSCELL_REL_SUC_SA}=2
...    NRCELL-11:${INA_PRO_REL_SCELL_ATT_SA}=1
...    NRCELL-11:${INA_PRO_REL_SCELL_SUC_SA}=1
...    NRCELL-11:${BAD_RLQ_REL_SCELL_ATT_SA}=1
...    NRCELL-11:${BAD_RLQ_REL_SCELL_SUC_SA}=1

${DL_RRC_1EXTSCELL_REL_ATT_SA}     M55118C10507    #This counter measures the number of 1 ext-SCell release attempts in DL
#in the PCell for SA. It considers both partial and full ext-SCell releases.
${DL_RRC_1EXTSCELL_REL_SUC_SA}    M55118C10508     #This counter measures the number of successful 1 ext-SCell release attempts
#in DL in the PCell for SA. It considers both partial and full ext-SCell releases.
${INA_PRO_REL_SCELL_ATT_SA}    M55118C10511     #This counter measures the number of SCells to be released due to prolonged
#inactivity in the PCell for SA. It considers both partial and full SCell releases.
${INA_PRO_REL_SCELL_SUC_SA}    M55118C10512    #This counter measures the number of SCells released due to prolonged inactivity
#in the PCell for SA. It considers both partial and full SCell releases.
${INA_OVHT_REL_SCELL_ATT_SA}    M55118C10513    #This counter measures the number of SCells to be released due to inactivity while UE
#is overheating in the PCell for SA. It considers both partial and full SCell releases.
${INA_OVHT_REL_SCELL_SUC_SA}    M55118C10514    #This counter measures the number of SCells released due to inactivity while
#UE is overheating in the PCell for SA. It considers both partial and full SCell releases.
${BAD_RLQ_REL_SCELL_ATT_SA}    M55118C10515    #This counter measures the number of SCells to be released due to bad SCell
#radio link quality in the PCell for SA.It considers both partial and full SCell releases.
${BAD_RLQ_REL_SCELL_SUC_SA}    M55118C10516    #This counter measures the number of SCells released due to bad SCell radio
#link quality in the PCell for SA. It considers both partial and full SCell releases.

${pdu_id}    1

${LOOP}    5

${UE_Capa_Support_OH}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C5
...    58D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB1
...    21CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E23
...    8F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F18
...    91C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F
...    00E7CC31E50B0381C3C17AAAAAAA9EAAAAAAA17000038024B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C
...    0309800020B02B1F008003036061300C260000C2C0AC5C02000C010181B0002058158F8040018060303606134000A160562E01000606C
...    0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C02000C03000282C0AC3C06000C0D8002C
...    2C0AC5C02000C030181B00060581587836001C4C00001A160562E2600061300C01000382C0AC7C4C000C260180203036000F0B02B1713
...    00030040606C0020160563E2680060080C030181B00088581009006E003404C800501345D003A4250A244D8E7C38912244D8E7C389122
...    44D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E
...    14489B1CF871224489B1CF870A244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0C06C486318C6318C631
...    8C6318C6307A0B800F000A070500703009401C0018090010180F824008000000040020000000800003004000008020000080100000600
...    80000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C010008120480200
...    00300CE54D654D60A5606560CD60AD652DE4CDE02D606D6025604560ED0341000009652504000065949810000196524040000E5949010
...    00049652404000165949810000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C5
...    94900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A05028140A0502814
...    0A050281400442020040080801002201002004040080101002004402018028080100202004008C04030050100C0140400801010020044
...    02020028080800A0202C058C04030060100C014040300601002004402018028080600A020040084040300501002004202018028080600
...    A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840403006010020044020040080801002020
...    18028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C0146A87C0004080C10181
...    C282C30344044484C5060646C70747C8494989CA0A4A8B4BD050E0B40

*** Test Cases ***
CB008311_ET_E002_E003_4CC_SA_Interworking_with_CB008140_SCell_release_due_to_prolonged_data_inactivity_or_overheat_blind_addition
    [Documentation]
    ...    This case is to Verify inter-GNB ext-scell released triggered by data inactivity or overheat
    ...    [Configuration]:
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=663400:663400 gscn=8159
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on nr_arfcn=658000:658000 gscn=8103
    ...    set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on nr_arfcn=648020:648020 gscn=8000
    ...    set_cell id=4 gnb=3 pci=17:2 tac=200 nrci=0x04 tdd_cell=on nr_arfcn=648000:648000 gscn=8000
    ...    set_cell id=11 gnb=3 pci=20:0 tac=200 nrci=0x0B tdd_cell=off nr_arfcn=349400:368400 gscn=4605
    ...    set_cell id=12 gnb=3 pci=20:1 tac=200 nrci=0x0C tdd_cell=off nr_arfcn=143400:153400 gscn=1916
    ...    2.Test Case Steps:
    ...    a. UE1 Register And Emergency Call Setup <5QI5 then 5QI1> On GNB1 NRCELL-1, blind scell addition GNB2 NRCELL-4,11,12
    ...    b. trigger scell addition with DL data traffic on PDU-1 5qi-5
    ...    c. add PDU-2 with CQI=6
    ...    d. stop DL TP on PDU-1 5qi-5 to trigger 3 SCELL released due to DL data inactivity
    ...    e. trigger scell addition with DL data traffic on PDU-2 5qi-6
    ...    f. trigger 3 SCELL released due to UE overheat,caBackoff timer started with 20 ms
    ...    g. trigger scell addition with DL data traffic on PDU-1 5qi-5 again after cabackoff timer expired,UE in 4CC

    [Tags]    E002    E003    QC_279078    CA_LABEL-TTFF(40Mhz_TDD_n77+40Mhz_TDD_n77+10Mhz_FDD_n3+15Mhz_FDD_n28)
    Prepare Configuration for E002E03
    Setup Call with 2 PDUs and Trigger SCell Addition
    Decrease traffic to trigger scell release
    Trigger IGB Blind Scells Addition and Verify TP     pdu=2    qfi=1
    Trigger Scell Release Due to UE OverHeat
    Trigger IGB Blind Scells Addition and Verify TP     pdu=1    qfi=1
    check wireshark log    ${CURDIR}${/}A2A_E002E003${/}a2a.ini    wait_string=IgNBCAUeContextModificationResponse::14
    Check Counters    ${E002_E003_PM_Counters_Check_GNB1}

CB008311_ET_E004_3CC_FTT_SA_Interworking_with_CB008140_gNB_CU_performs_ext_SCell_release_due_to_bad_RLQ_in_ext_Scell
    [Documentation]
    ...    This case is to Verify inter-GNB ext-scell released triggered by bad rlq. and also check pdu release and re-setup procedure.
    ...    [Configuration]:
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=663400:663400 gscn=8159
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on nr_arfcn=658000:658000 gscn=8103
    ...    set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on nr_arfcn=648020:648020 gscn=8000
    ...    set_cell id=4 gnb=3 pci=17:2 tac=200 nrci=0x04 tdd_cell=on nr_arfcn=648000:648000 gscn=8000
    ...    set_cell id=11 gnb=3 pci=20:0 tac=200 nrci=0x0B tdd_cell=off nr_arfcn=349400:368400 gscn=4605
    ...    set_cell id=12 gnb=3 pci=20:1 tac=200 nrci=0x0C tdd_cell=off nr_arfcn=143400:153400 gscn=1916
    ...    2.Test Case Steps:
    ...    a. UE1 Register And Emergency Call Setup <5QI5 then 5QI1> On GNB2 NRCELL-11, A1 based scell addition GNB1 NRCELL-1,2
    ...    b. trigger scell addition with DL data traffic on PDU-1 5qi-5
    ...    c. Tigger Scell-index 2 released due to bad rlq and scell-index 1 released due to data inactivity
    ...    d. trigger scell addition with DL data traffic on PDU-1 5qi-5 ,add nrcell-1 only, because nrcell-2 is still in blacklist
    ...    e. release last PDU and then re-setup PDU again with bearer 5QI5
    ...    f. start DL data and verify TP
    [Tags]    E004    QC_47059    CA_LABEL-FTT (10Mhz_FDD_n3+40Mhz_TDD_n77+40Mhz_TDD_n77)
    Clear Counter Files for 2GNB
    EC Call on GNB2
    Trigger IGNB A1covBased Scells addition    pdu=1    qfi=1
    Verify Throughput    ue_id=1    pdu=1    qfi=1    Tput_dl=200    Tput_ul=10
    Trigger Bad Rlq Scell Release and Inactivity Scell Release
    Trigger IGNB A1covBased Scells addition    pdu=1    qfi=1
    Verify Throughput    ue_id=1    pdu=1    qfi=1    Tput_dl=100    Tput_ul=10
    Trigger Last PDU Release    ue_id=1    pdu=1
    ReSetup PDU and High DL data    ue_id=1    pdu=1    qfi=1
    Verify Throughput    ue_id=1    pdu=1    qfi=1    Tput_dl=100    Tput_ul=10
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_E004${/}a2a_gnb2.ini    wait_string=IgNBCAUeContextModificationResponse::8
    Check Counters GNB2    ${E004_PM_Counters_Check_GNB2}    wait=${True}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_OH}

Prepare Configuration for E002E03
    Clear Counter Files for 2GNB
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1

Setup Call with 2 PDUs and Trigger SCell Addition
    EC Call
	UE PDU Session Setup    pdu=2    gw=2    fiveQi=6    qfi=1
    Trigger IGNB Blind Scells addition    pdu=1    qfi=1
    Verify Throughput    ue_id=1    pdu=1    qfi=1    Tput_dl=200    Tput_ul=0

Trigger Scell Release Due to UE OverHeat
    Execute Egate Command    ue_assistance_send_nr ue_id=1 forOverheating=yes reducedCCsDL=0
    sleep    15s    #wait for scell release due to UE overheat
    Execute Egate Command    ue_assistance_send_nr ue_id=1 forOverheating=yes

EC Call on GNB2
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_change_location id=1 enb=3 cell=11
    EC Call

Trigger IGB Blind Scells Addition and Verify TP
    [Arguments]     ${pdu}=1    ${qfi}=1
    Trigger IGNB Blind Scells addition    pdu=${pdu}    qfi=${qfi}
    Verify Throughput    ue_id=1    pdu=${pdu}    qfi=${qfi}    Tput_dl=200    Tput_ul=0

Trigger Last PDU Release
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu}
    ...    pass_regexp=Successfully released PDU Session

ReSetup PDU and High DL data
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=1
    ...    pass_regexp=Established PDU session ID=1
    Run Keywords    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl trf_id=1 protocol=udp mbps=50
    ...    pass_regexp=Started Downlink Internal traffic over UDP
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl trf_id=2 protocol=udp mbps=175
    ...    pass_regexp=Started Downlink Internal traffic over UDP
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl trf_id=3 protocol=udp mbps=175
    ...    pass_regexp=Started Downlink Internal traffic over UDP
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl trf_id=4 protocol=udp mbps=175
    ...    pass_regexp=Started Downlink Internal traffic over UDP
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl trf_id=5 protocol=udp mbps=175
    ...    pass_regexp=Started Downlink Internal traffic over UDP    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul trf_id=6 protocol=udp mbps=50
    ...    pass_regexp=Started Uplink Internal traffic over UDP
    sleep    10s    #sleep for stable traffic

Trigger Bad Rlq Scell Release and Inactivity Scell Release
    Trigger Ext Scell Badrlq    scell=2
    Decrease traffic to trigger scell release

Trigger Ext Scell Badrlq
    [Arguments]    ${scell}=2
    Execute Egate Command    bler_testmode_nr profile_id=2 target_mcs=0 num_dl_pkts=10000
    Execute Egate Command    ue_testmode_set_nr id=1 scell=${scell} testmode=bler action=activate profile_id=2
    ...    pass_regexp=SCellIndex 2 deactivated
    sleep    2s    #wait for scell release wait
    Execute Egate Command    ue_testmode_set_nr id=1 scell=${scell} testmode=bler action=deactivate profile_id=2
    Execute Egate Command    bler_testmode_nr delete=true profile_id=2

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Trigger IGNB Blind Scells addition
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Run Keywords    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=5 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=6 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    sleep    10s    #sleep for stable traffic

Trigger IGNB A1covBased Scells addition
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    A1 Based Scell Addition
    Run Keywords    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=5 protocol=tcp mbps=175 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=6 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    sleep    10s    #sleep for stable traffic

Decrease traffic to trigger scell release
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Run Keywords    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1
    ...    pass_regexp=Traffic was stopped
    ...    AND    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2
    ...    pass_regexp=Traffic was stopped
    ...    AND    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3
    ...    pass_regexp=Traffic was stopped
    ...    AND    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4
    ...    pass_regexp=Traffic was stopped
    ...    AND    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=5
    ...    pass_regexp=Traffic was stopped
    sleep    15s    #wait for scell release

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${gw}=1    ${fiveQi}=5    ${qfi}=1
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    QFI:${qfi} 5QI:${fiveQi}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1 ue=1-12
    Update Cfg    set_qosflow id=3 5qi=6
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-12 qos_flows=2,1,3 qos_rules=1,2 amf=1
    Update Cfg    ue_nr_capabilities id=1-12 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g

EC Call
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
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A1 srsrp_nr=100




