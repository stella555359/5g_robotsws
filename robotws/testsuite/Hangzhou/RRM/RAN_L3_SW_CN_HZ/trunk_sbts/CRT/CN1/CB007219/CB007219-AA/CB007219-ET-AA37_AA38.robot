*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD 
...    owner-jia.pan    release-SBTS24R2    team-CN1ET
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_BWP}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-1:gscnOrSsPbchArfcn=7975
...    NRCELL-1:msg1FrequencyStart=20
...    NRCELL-1:nrarfcn=646700
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX

@{PARAMS_ADJ_REL_FOR_GNB1}
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
...    NRBTS/NRADJNRCELL-3:nrarfcn=646700
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=3
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:chBw=50MHz
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRCELL-3:gscnOrSsPbchArfcn=7975
...    NRCELL-3:msg1FrequencyStart=20
...    NRCELL-3:nrarfcn=646700
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-2
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-2
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:resourceDN

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
...    NRBTS/NRADJNRCELL-1:nrarfcn=646700
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-2
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:lcrId=1

@{PARAMS_FOR_OTHERS}
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:suppCnPartialAdNgHo=true
...    NRBTS:actConflictConfiguration=true


...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL:nrCellType=4DL4UL
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms160
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actIncXn=true
...    NRDU-1:carrierAggregationSupportList=${CAlist}
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd

@{GNB1_BWP}
...    NRCELL-1:actEnhMultipleDedicatedBWPs=true
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-5:bwpType=dedicated
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-5/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5

${N66_N77_and_N66_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C002707898001C4100000A160205E1E20800713400003858081007011A014404D80822E8003602851226C73E1C28913639F0C00E0
...    43183D05C0078005038280381804A00E000C0480080C07C07004000000020000040100000400800003004000020020000140100000C00800
...    00701D81959515939591B58335831581B595340704000025949410000196525040000A594941000039652504000125949410000596525040
...    001A594941000079652501D40EAA9555527AAA479541B2A8355503CAA55942C009001A050006840400801010020042020100200802004201
...    004008040080101002004402014028080700E02020040404018030100400820200C018080100210100801004008010808010020200801080
...    4010020100200404008011008020040200400808010022010020040400801010020044020040080801002020040084040080101004008606
...    018034028050300200600400818010030020040C040088020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052
...    545A5E828305A0

@{online_modify_for_AA38_gnb1}
...    NRBTS:actMfbiNrCaSupportFr1=false
...    NRCELL-1/NRREL-11:handoverAllowedSA=XnHoNotAllowed
...    NRBTS:actHighestEstNrTputBcSel=true

@{online_modify_for_AA38_gnb2}
...    NRBTS:actMfbiNrCaSupportFr1=false
...    NRCELL-3/NRREL-1:handoverAllowedSA=XnHoNotAllowed
...    NRBTS:actHighestEstNrTputBcSel=true

@{online_recover_for_AA38_gnb1}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRBTS:actHighestEstNrTputBcSel=false

@{online_recover_for_AA38_gnb2}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRBTS:actHighestEstNrTputBcSel=false

@{UEattach_for_AA37}
...    QoS Routing Table
...    pcid:50
...    freqBandIndicatorNR 77

@{UEattach_for_AA38}
...    QoS Routing Table
...    pcid:50
...    freqBandIndicatorNR 78

@{HO_from_cell1_to_cell3}
...    rrcReconfigurationComplete
...    pcid:52
...    freqBandIndicatorNR 77

@{HO_from_cell3_to_cell1}
...    rrcReconfigurationComplete
...    pcid:50
...    freqBandIndicatorNR 77

@{HO_from_cell1_to_cell3_AA38}
...    rrcReconfigurationComplete
...    pcid:52
...    freqBandIndicatorNR 77

@{HO_from_cell3_to_cell1_AA38}
...    rrcReconfigurationComplete
...    pcid:50
...    freqBandIndicatorNR 78

@{PM_Counters_Check_AA37_gnb1}
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-1:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=0
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0

@{PM_Counters_Check_AA37_gnb2}
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=0

@{PM_Counters_Check_AA38_gnb1}
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=1
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=1

@{PM_Counters_Check_AA38_gnb2}
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=0

${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503    #This counter provides the number of radio admission handover requests
#for an SA user where the admission is requested on an alternative band.The counter is updated to the PCell.
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504    #This counter provides the number of admitted handover radio admissions 
#for an SA user where the admission is done on an alternative band.The counter is updated to the PCell.
${GNB_SA_DU_HO_ADMISS_MFBI_REQ}    M55139C02005    #This counter provides the number of radio admission handover requests 
#on an alternative band for SA users.This counter is updated to the PCell.
${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}    M55139C02006    #This counter provides the number of radio-admitted handover radio 
#resources on an alternative band for SA users.This counter is updated to the PCell.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001    #This counter provides the number of radio admission requests with MFBI for the SA user.
#The counter is updated to the PCell on DU.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002    #This counter provides the number of radio-admitted UEs for the SA user using the alternative
#band.The counter is updated to the PCell on DU.

*** Test Cases ***
CB007219-ET-AA37_Successful RRC connection setup with a PCell supporting native and alternative bands interaction with mobility
    [Documentation]
    ...    The purpose of this test case is to verify the successful setup of an RRC connection when the target PCell can be 
    ...    configured both in native and in alternative band and interaction with mobility to an intra-frequency neighbor cell
    ...    [Configuration]:
    ...    CB007219 is enabled, NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    5GC001416 is enabled, NRBTS/actMultipleDedicatedBWPs is set to true
    ...    Cell1_1 is TDD cell, NativeBand N77, AlternativeBand N78, Bandwidth 100MHz.Small BWP is configured as 50MHz
    ...    Cell2_3 is TDD cell, NativeBand N77, AlternativeBand N78, Bandwidth 50Mhz
    ...    UE1 capability: 
    ...    BC#1: n66A-n77A n66 N77 
    ...    DL FSEI#1: DL MIMO layers 2L 4L 
    ...    DL ChBw (MHz) 20 50 
    ...    UL FSEI#1: UL MIMO layers 2L 2L 
    ...    UL ChBw (MHz) 20 50 
    ...    BC#2: n66A-n78A N66 N78 
    ...    DL FSEI#1: DL MIMO layers 2L 4L 
    ...    DL ChBw (MHz) 20 100 
    ...    UL FSEI#1: UL MIMO layers 2L 2L 
    ...    UL ChBw (MHz) 20 100
    ...    2.Test Case Steps:
    ...         a. UE attach to cell1_1
    ...         b. trigger intra frequency from cell1_1 to cell2_3
    ...         c. HO back to cell1_1
    ...    3.Expectation:
    ...         a. gNB1-DU selects BC#1 and FSEI#1 and gNB1-CU configures measurement objects for pcell in band n77
    ...         b. HO succefully.5G-UE has been configured with Cell2_3 as PCell in band n77 with the respective measurement
    ...         object also in band n77 and gNB2-DU has selected BC#1 and FSEI#1
    ...         c. HO succefully. gNB1-DU selects BC#1 and FSEI#1 and gNB1-CU configures measurement objects for pcell in band n77
    [Tags]    jia.pan    AA37    QC_46777
    Clear Counter Files for 2GNB
    Update UE capa
    Ue register and pdu session setup
    Intra-gNB intra-Freq HO with A3 from TDD cell1-1 to TDD cell2-3
    Intra-gNB intra-Freq HO with A3 from TDD cell2-3 to TDD cell1-1
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_Check_AA37_gnb1}
    Check Counters GNB2    ${PM_Counters_Check_AA37_gnb2}
    Check WireShark Log    ${CURDIR}${/}A2A_AA37${/}a2a.ini    wait_string=UEContextRelease::18
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AA37${/}a2a_gnb2.ini    wait_string=UEContextRelease::8

CB007219-ET-AA38_Successful RRC connection setup with a PCell supporting native and alternative bands interaction with mobility and 7219 disabled
    [Documentation]
    ...    The purpose of this test case is to verify the successful setup of an RRC connection when the target PCell can be 
    ...    configured both in native and in alternative band and interaction with mobility to an intra-frequency neighbor cell
    ...    [Configuration]:
    ...    CB007219 is disabled, NRBTS/actMfbiNrCaSupportFr1 is set to false
    ...    5GC001416 is enabled, NRBTS/actMultipleDedicatedBWPs is set to true
    ...    CNI-81817 is enabled, NRBTS/actHighestEstNrTputBcSel is set as true
    ...    Cell1_1 is TDD cell, NativeBand N77, AlternativeBand N78, Bandwidth 100MHz.Small BWP is configured as 50MHz
    ...    Cell2_3 is TDD cell, NativeBand N77, AlternativeBand N78, Bandwidth 50Mhz
    ...    UE1 capability:  
    ...    BC#1: n66A-n77A	n66	N77	   
    ...    DL FSEI#1:	DL MIMO layers	2L	4L	   
    ...    DL ChBw (MHz)	20	50	   
    ...    UL FSEI#1:	UL MIMO layers	2L	2L	   
    ...    UL ChBw (MHz)	20	50	   
    ...    BC#2: n66A-n78A	N66	N78	   
    ...    DL FSEI#1:	DL MIMO layers	2L	4L	   
    ...    DL ChBw (MHz)	20	100	   
    ...    UL FSEI#1:	UL MIMO layers	2L	2L	   
    ...    UL ChBw (MHz)	20	100
    ...    2.Test Case Steps:
    ...         a. UE attach to cell1_1
    ...         b. trigger intra frequency from cell1_1 to cell2_3
    ...         c. HO back to cell1_1
    ...    3.Expectation:
    ...         a. gNB1-DU selects BC#2 and FSEI#1, Because CB007219 is disabled, gNB behavior is as per the legacy behavior by PR562529 
    ...            where the gNB-DU will select the best band combination and feature set pair which provides maximum throughput for the UE
    ...            in this case BC#2 and FSEI#1.gNB1-CU configures measurement objects for pcell in band n78.
    ...         b. HO succefully.5G-UE has been configured with Cell2_3 as PCell in band n77 with the respective measurement object
    ...         also in band n77 and gNB2-DU has selected BC#1 and FSEI#1 with 50MHz.
    ...         c. HO succefully. gNB1-DU selects BC#2 and FSEI#2 and gNB1-CU configures measurement objects with F0 in band n78 
    ...         with 100MHz.
    [Tags]    jia.pan    AA38    QC_321449
    Online ParamChange AA38
    Clear Counter Files for AA38
    Update UE capa
    Ue register and pdu session setup    ${UEattach_for_AA38}
    Intra-gNB intra-Freq HO with A3 from TDD cell1-1 to TDD cell2-3    ${HO_from_cell1_to_cell3_AA38}
    Intra-gNB intra-Freq HO with A3 from TDD cell2-3 to TDD cell1-1    ${HO_from_cell3_to_cell1_AA38}
    Check Counters for AA38
    Check WireShark for AA38
    [Teardown]    AA38_Teardown
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env     tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F    ue_count=15

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=${N66_N77_and_N66_N78}    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Check Counters for AA38
    Check Counters    ${PM_Counters_Check_AA38_gnb1}
    Check Counters GNB2    ${PM_Counters_Check_AA38_gnb2}

Check WireShark for AA38
    Check WireShark Log    ${CURDIR}${/}A2A_AA38${/}a2a.ini    wait_string=UEContextRelease::10
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AA38${/}a2a_gnb2.ini    wait_string=UEContextRelease::10

Clear Counter Files for AA38
    Clear Counter Files
    Clear Counter Files GNB2

Ue register and pdu session setup
    [Arguments]    ${UEattach}=${UEattach_for_AA37}    ${ue_id}=1    ${cell_id}=1 
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${UEattach}

Intra-gNB intra-Freq HO with A3 from TDD cell1-1 to TDD cell2-3
    [Arguments]    ${Ho}=${HO_from_cell1_to_cell3}    ${ue_id}=1    ${carrierfreq}=645696    ${Target_phycell_id}=52
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${Intra_gNB_HO_OptimizationCa}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=100 nrsrq_nr=100
    Execute Egate Command    ${Intra_gNB_HO_OptimizationCa}    pass_regexp=${Ho}
	
Intra-gNB intra-Freq HO with A3 from TDD cell2-3 to TDD cell1-1
    [Arguments]    ${Ho}=${HO_from_cell3_to_cell1}    ${ue_id}=1    ${carrierfreq}=645696    ${Target_phycell_id}=50
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${Intra_gNB_HO_OptimizationCa}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=100 nrsrq_nr=100
    Execute Egate Command    ${Intra_gNB_HO_OptimizationCa}    pass_regexp=${Ho}
	
OnlineParamChange_gNB1
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

OnlineParamChange_gNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters gnb2    ${Online_Param}
    Cells Should Be OnAir

Online ParamChange AA38
    OnlineParamChange_gNB1    ${online_modify_for_AA38_gnb1}
    OnlineParamChange_gNB2    ${online_modify_for_AA38_gnb2}
	
AA38_Teardown
    Release UEs    ue_type=all
    OnlineParamChange_gNB1    ${online_recover_for_AA38_gnb1}
    OnlineParamChange_gNB2    ${online_recover_for_AA38_gnb2}
    Common Test Teardown And Stop Capture Logs
