*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD 
...    owner-jia.pan    release-SBTS24R3    team-CN1ET
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_GNB1}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:resourceDN

...    NRCELL-11:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-11:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-12:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-12:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=25


...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=25

@{PARAMS_FOR_GNB2}
...    MRBTS-1/NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRCELL:chBw=40MHz
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{PARAMS_FOR_OTHERS}
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actExtN77Support=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:weightForIgnbCaSelection=50
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
...    NRBTS:actMfbiNrCaMeasConfResolv=true
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
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actIncXn=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRDU-1:carrierAggregationSupportList=${CAlist}
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,
...    ca_Fr1Tdd_Fdd_Nsa

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRBTS/NRCELL-14:gscnOrSsPbchArfcn=5381
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=350000
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=430000
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=633356
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:ssbFrequency=633312

...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=647444
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:ssbFrequency=647424
...    NRBTS/NRADJNRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2

...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=643416
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-3:ssbFrequency=643392
...    NRBTS/NRADJNRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=639360
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-4:ssbFrequency=639360

...    NRCELL-13/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-13/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-3:ssbFrequency=643392
...    NRCELL-13/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-13/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=1dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=1dB
...    NRCELL-13/NRREL-1:gNbId=2
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=1dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=1dB
...    NRCELL-13/NRREL-3:gNbId=2
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-3:lcrId=3
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms


@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRCELL-1:nrarfcn=633356
...    NRBTS/NRCELL-1:gscnOrSsPbchArfcn=7846
...    NRBTS/NRCELL-1:freqBandIndicatorNR=77

...    NRBTS/NRCELL-2:nrarfcn=647444
...    NRBTS/NRCELL-2:gscnOrSsPbchArfcn=7993
...    NRBTS/NRCELL-2:freqBandIndicatorNR=77

...    NRBTS/NRCELL-3:nrarfcn=643416
...    NRBTS/NRCELL-3:gscnOrSsPbchArfcn=7951
...    NRBTS/NRCELL-3:freqBandIndicatorNR=78

...    NRBTS/NRCELL-4:nrarfcn=639360
...    NRBTS/NRCELL-4:gscnOrSsPbchArfcn=7909
...    NRBTS/NRCELL-4:freqBandIndicatorNR=78

#CNI-75210
...    NRBTS:actExtN77Support=true
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-3
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-2
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-3
...    NRSYSINFO_PROFILE-2/NRIAFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-3        #for n77E
...    NRSYSINFO_PROFILE-2/NRIRFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-3        #for n77E

...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-1
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-2

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=25

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=390000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=2
...    NRBTS/NRADJNRCELL-11:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-3
...    NRCELL-3:measGapSelectionSA=favourUeThroughput

...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=395000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=2
...    NRBTS/NRADJNRCELL-12:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-3

...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=1
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=424000
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=66
...    NRBTS/NRADJNRCELL-13:ssbFrequency=424090

...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=1
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=430000
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=66

...    NRCELL-3/NRHOIF-13:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-13:freqBandIndicatorNR=66
...    NRCELL-3/NRHOIF-13:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-13:ifhoSsbSmtcDuration=sf2
...    NRCELL-3/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-13:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-13:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-13:ssbFrequency=424090
...    NRCELL-3/NRHOIF-13:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-3/NRHOIF-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-3/NRHOIF-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40

...    NRCELL-3/NRREL-13:cellIndividualSsbRsrpOffset=1dB
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrqOffset=1dB
...    NRCELL-3/NRREL-13:gNbId=1
...    NRCELL-3/NRREL-13:gNbIdLength=22
...    NRCELL-3/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-13:lcrId=13
...    NRCELL-3/NRREL-13:removeNotAllowed=false
...    NRCELL-3/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-13:sCellOperationalMode=dlOnly

...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms



@{CB007219_B_disabled}
...    NRBTS:actMfbiNrCaMeasConfResolv=false

@{CB007219_B_enabled}
...    NRBTS:actMfbiNrCaMeasConfResolv=true

@{Online_remove_alternative_band}
...    delete:NRCELL-13/NRHOIF-3:nrConnectModeProfileDN

@{Online_add_alternative_band_and_enable_7219B}
...    NRBTS:actMfbiNrCaMeasConfResolv=true
...    NRCELL-13/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

${N66_2N77_and_N66_N77_and_N66_2N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A83600EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C00378B882001C4C000E260000000B0102F0F1040038980000042C040BC5C41000E26800713400001058081009011A014404D8083
...    01305D080A4071224489B1CF870A244D8E7C38912244D8E7C301C0C63180C07A0B800F000A070500703009401C0018090010180F81000800
...    000004000008020000080100000600800004004000028020000180100000E0080000802181B5933591B591958335833581B5953595340704
...    000025949410000196525040000A594941000039652504000125949410000596525040001A594941000079652501D40EAA9365526AAA4755
...    41B2A8355503CAA55942C009001A05000108040080101004008040100208080100202008010804008010100400804010021AA1F000102030
...    406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

${N66_2N77_and_N66_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A83600EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C00378B882001C4C000E260000000B0102F0F1040038980000042C040BC5C01000E1400070A000001058081009011A014404D8083
...    01305D080A4071224489B1CF870A244D8E7C38912244D8E7C301C0C63180C07A0B800F000A070500703009401C0018090010180F81000800
...    000004000008020000080100000600800004004000028020000180100000E0080000802181B5933591B591958335833581B5953595340704
...    000025949410000196525040000A594941000039652504000125949410000596525040001A594941000079652501D40EAA9365526AAA4755
...    41B2A8355503CAA55942C009001A05000108040080101004008040100208080100202008010804008010100400804010021AA1F000102030
...    406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

@{UE_register_and_A1_configured}
...    QoS Routing Table
...    eventA1
...    eventA2
...    freqBandIndicatorNR 66

@{CA_check_CELL1_CELL3}
...    pcid:50
...    scellIdx:1
...    pcid:52
...    scellIdx:2
...    freqBandIndicatorNR 77
...    eventId eventA2
...    ssbFrequency 633312
...    frequencyBandList.*\{.*77.*\}\.
...    rrcReconfigurationComplete

@{CA_check_CELL1_CELL3_for_UE2}
...    pcid:50
...    scellIdx:1
...    pcid:52
...    scellIdx:2
...    freqBandIndicatorNR 77
...    eventId eventA2
...    ssbFrequency 643392
...    ssbFrequency 633312
...    frequencyBandList.*\{.*77.*\}\.
...    measId 5
...    measId 6
...    rrcReconfigurationComplete

@{CA_check_CELL1_CELL3_for_B005}
...    pcid:50
...    scellIdx:1
...    pcid:52
...    scellIdx:2
...    freqBandIndicatorNR 77
...    eventId eventA2
...    ssbFrequency 643392
...    ssbFrequency 633312
...    frequencyBandList.*\{.*77.*\}\.
...    measId 3
...    measId 4
...    rrcReconfigurationComplete

@{MG_setup}
...    eventId eventA3
...    eventId eventA1
...    freqBandIndicatorNR 78
...    gapUE setup
...    rrcReconfigurationComplete

@{MG_setup_for_UE2}
...    eventId eventA3
...    eventId eventA1
...    freqBandIndicatorNR 77
...    gapUE setup
...    rrcReconfigurationComplete

@{MG_setup_with_band77}
...    eventId eventA3
...    eventId eventA1
...    freqBandIndicatorNR 77
...    gapUE setup
...    rrcReconfigurationComplete

@{No_MG_setup_with_band77}
...    measIdToRemoveList
...    rrcReconfigurationComplete
...    rrcReconfigurationComplete

@{MG_setup_with_band78_for_UE3UE4}
...    eventId eventA3
...    eventId eventA1
...    freqBandIndicatorNR 78
...    gapUE setup
...    measIdToRemoveList\\s\+\{\\s\+1,\\s\+4\\s\+\}
...    rrcReconfigurationComplete

@{MG_setup_with_band78}
...    eventId eventA3
...    eventId eventA1
...    freqBandIndicatorNR 78
...    gapUE setup
...    rrcReconfigurationComplete

@{MG_setup_with_band78_and_A2_remove}
...    eventId eventA3
...    eventId eventA1
...    freqBandIndicatorNR 78
...    gapUE setup
...    measIdToRemoveList\\s\+\{\\s\+7,\\s\+8\\s\+\}
...    rrcReconfigurationComplete

@{MG_setup_with_band78_reconfig}
...    eventId eventA3
...    eventId eventA1
...    gapUE setup
...    measObjectId 3
...    freqBandIndicatorNR 78
...    measIdToRemoveList\\s\+\{\\s\+7,\\s\+4\\s\+\}
...    rrcReconfigurationComplete

@{MG_setup_with_band78_reconfig_again}
...    eventId eventA3
...    eventId eventA1
...    gapUE setup
...    measObjectId 3
...    freqBandIndicatorNR 78
...    measIdToRemoveList\\s\+\{\\s\+10,\\s\+11\\s\+\}
...    rrcReconfigurationComplete

@{MG_setup_with_noband_config}
...    eventId eventA3
...    eventId eventA1
...    gapUE setup
...    rrcReconfigurationComplete

@{pass_A1_mobility_check}
...    eventId eventA2
...    freqBandIndicatorNR 77
...    gapUE release
...    rrcReconfigurationComplete
...    measId 8

@{pass_A1_mobility_check_for_B02}
...    eventId eventA2
...    freqBandIndicatorNR 77
...    gapUE release
...    rrcReconfigurationComplete
...    measId 17

@{pass_A1_mobility_with_band_change}
...    eventId eventA2
...    freqBandIndicatorNR 77
...    gapUE release
...    measIdToRemoveList\\s\+\{\\s\+8,\\s\+9\\s\+\}
...    measId 10
...    measId 11
...    rrcReconfigurationComplete

@{pass_A1_mobility_and_no_band_change}
...    eventId eventA2
...    gapUE release
...    rrcReconfigurationComplete

@{A3_HO_to_cell3_check}
...    freqBandIndicatorNR 78
...    eventId eventA2
...    eventId eventA1
...    pcid:52, scellIdx:0
...    gapUE release
...    Inter-eNB handover from EXT_ENB-2.13 to EXT_ENB-3.3 performed

@{A3_HO_to_cell3_check_for_UE2}
...    freqBandIndicatorNR 77
...    eventId eventA2
...    eventId eventA1
...    pcid:52, scellIdx:0
...    gapUE release
...    Inter-eNB handover from EXT_ENB-2.13 to EXT_ENB-3.3 performed

@{A3HO_to_cell3_and_scell_add}
...    pcid:62
...    scellIdx:1
...    freqBandIndicatorNR 78
...    freqBandIndicatorNR 66
...    eventId eventA2
...    pcid:52, scellIdx:0
...    gapUE release
...    Inter-eNB handover from EXT_ENB-2.13 to EXT_ENB-3.3 performed

@{A3_HO_to_cell13_check}
...    freqBandIndicatorNR 66
...    eventId eventA2
...    eventId eventA1
...    gapUE release
...    pcid:62, scellIdx:0
...    Inter-eNB handover from EXT_ENB-3.3 to EXT_ENB-2.13 performed

@{A3HO_to_cell13_and_scell_add}
...    freqBandIndicatorNR 66
...    pcid:50
...    scellIdx:1
...    pcid:52
...    scellIdx:2
...    freqBandIndicatorNR 77
...    eventId eventA2
...    gapUE release
...    pcid:62, scellIdx:0
...    Inter-eNB handover from EXT_ENB-3.3 to EXT_ENB-2.13 performed
...    measId 19
...    measId 18
...    rrcReconfigurationComplete

@{A3HO_to_cell3_and_scell_for_UE5}
...    pcid:62
...    scellIdx:1
...    freqBandIndicatorNR 77
...    freqBandIndicatorNR 66
...    eventId eventA2
...    pcid:52, scellIdx:0
...    gapUE release
...    Inter-eNB handover from EXT_ENB-2.13 to EXT_ENB-3.3 performed
...    rrcReconfigurationComplete

@{A3HO_to_cell13_and_scell_for_UE5}
...    freqBandIndicatorNR 66
...    pcid:50
...    scellIdx:1
...    pcid:52
...    scellIdx:2
...    freqBandIndicatorNR 77
...    eventId eventA2
...    gapUE release
...    pcid:62, scellIdx:0
...    Inter-eNB handover from EXT_ENB-3.3 to EXT_ENB-2.13 performed
...    rrcReconfigurationComplete

@{A2_scell_release}
...    eventId eventA1
...    rrcReconfigurationComplete

@{no_A3_and_MG_config}
...    eventId eventA1
...    eventId eventA3
...    gapUE setup

@{PM_Counters_Check_B002_gnb2}
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=3

@{PM_Counters_Check_B005_gnb2}
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=7

${SCELL_CONF_ALT_BAND_SA}    M55118C01005
#This counter provides the number of current cell configurations as an SA SCell in an alternative band

*** Test Cases ***
CB007219-ET-B002_SA_inter_gnb_CA_Interaction_with_inter-frequency_mobility_with_Scell_is_added_when_inter-freq_mobility_is_configured
    [Documentation]
    ...    This user scenario describes the gNB behavior when an MFBI SCell is to be added on alternative band when a UE is already configured with
    ...    inter-frequency mobility measurements on the same frequency of the SCell with native band USCB007219-B#B2.3
    ...    [Configuration]:
    ...    CB008140: NRDU:actInterGnbCa=DLOnly,NRCELL:actK1Opt=intraAndInter-gNB,NRBTS/NRDU/DlToUlContributionRatio is set to "101"
    ...    CB007219: NRBTS/actMfbiNrCaSupportFr1 is set to "true" in gnb-2 and gnb-1.
    ...    CB007219-B feature is enabled on prime-gNB (NRBTS/actMfbiNrCaMeasConfResolv = true)
    ...    5GC001416: NRBTS/actMultiFrequencyBandIndicatorNRSupport=true for both gNB-1 and gNB-2.
    ...    CNI-75210:MRBTS/NRBTS/actExtN77Support=true
    ...    Cell2_1 operates in the frequency range of 3450MHz<= F4 <=3550MHz
    ...    Cell2_2 operates in the frequency range of 3650MHz<= F5 <=3980MHz
    ...    Cell1_11    Cell1_12    Cell1_13    Cell1_14    Cell2_1    Cell2_2    Cell2_3    Cell2_4
    ...    Technology type    FDD    FDD    FDD    FDD    TDD    TDD    TDD    TDD
    ...    Frequency    F0    F1    F2    F3    F4    F5    F6    F7
    ...    Common channel bandwidth    20    20    20    20    40    40    40    40
    ...    DL MIMO Layers    4L    4L    4L    4L    4L    4L    4L    4L
    ...    Native band    N2    N2    N66    N66    N77    N77    78    N78
    ...    Alternative band    N25    N25    NA    NA    N78    N78    N77    N77
    ...    UE1 capability:5G-UE indicates support of the lower extended band 77 in USA(UE-NR-Capability->RF-Parameters->extendedBand-n77-r16).
    ...    CA relation:cell1_13+cell2_1+cell2_3, A1 scell addition.inter-freq HO to cell2_3 is configured.
    ...    BC#1:N66A_N77(2A)
    ...    BC#2:N66A_N77A
    ...    BC#3:N66A_N78A
    ...    UE2:the same as UE1 but not support BC#3
    ...    2.Test Case Steps:
    ...         a. attach UE1 to cell1_13 and trigger A2 for MG setup.
    ...         b. attach UE2 to cell1_12 and trigger A1. Start DL/UL traffic.
    ...         c. trigger A3 HO to cell2_3. and HO back.
    ...         d. trigger A2 for MG setup.
    ...         e. trigger A1 for scell addition.
    ...         f. trigger A1 for mobility.
    ...         g. trigger A2 scell release.
    ...         h. attach UE2 to cell1_13 and trigger A2 for MG setup.
    ...         i. trigger A1 for scell addition.
    ...         j. trigger A2 for scell release.
    ...         k. trigger A3 HO to cell2_3 and HO back.
    ...    3.Expectation:
    ...         a. MG setup successfully. A3/A5 is configured with n78.
    ...         b. cell2_1 and cell2_3 is added as scell successfully.Cell1_13 in band n66 and Cell2_1 and cell2_3 in band n77. BC#1 is selected.
    ...    A2 for scell release is only configured in scell2_1. NOT for Scell2_3. measurement object for cell2_3 remains with native band N78.
    ...         c. HO to cell2_3 successfully. and HO back successfully.
    ...         d. MG setup successfully. A3/A5 is configured with n78.
    ...         e. cell2_1 and cell2_3 is added as scell successfully.Cell1_13 in band n66 and Cell2_1 and cell2_3 in band n77. BC#1 is selected.
    ...     A2 for scell release is only configured in scell2_1. NOT for Scell2_3. measurement object for cell2_3 remains with native band N78.
    ...         f. gNB removes A3/A5 measurement configuration and releases measurement gaps. gNB reconfigures the measurement object with N77 for
    ...     A2 scell release scell2_3.
    ...         g. scell release successfully.
    ...         h. MG setup successfully. A3/A5 is configured with n77.
    ...         i. cell2_1 and cell2_3 is added as scell successfully. Cell1_13 in band n66 and Cell2_1 and cel2_3 in band n77. BC#1 is selected.
    ...     A2 for scell release is configured in scell2_1 and scell2_3 with n77.
    ...         j. scell release successfully.
    ...         k. HO successfully.
    [Tags]    QC_46815    christine.chen    B002    CA_LABEL-FTT(20MHZ_FDD_n66+40MHZ_TDD_n77+40MHZ_TDD_n77)
    Clear Counter Files for 2GNB for B002
    B002 stepA-B
    B002 stepC-D
    B002 stepE-G
    B002 stepH-J
    B002 stepK
    Release Ues    ue_type=all
    Check Counters GNB2    ${PM_Counters_Check_B002_gnb2}    wait=True

CB007219-ET-B005_Successful_NSA_CA_setup_with_contiguous_frequencies_in_N78_and_N77
    [Documentation]
    ...    This user scenario describes the gNB behavior when A2 measurement report for mobility is received when a UE is configured CA with at
    ...    least one MFBI SCell is configured on alternative band and an inter-frequency target cell configured with native band exists which
    ...    shares the same frequency of SCell configured with alternative band USCB007219-B#B1.4.
    ...    [Configuration]:
    ...    CB008140: NRDU:actInterGnbCa=DLOnly,NRCELL:actK1Opt=intraAndInter-gNB,NRBTS/NRDU/DlToUlContributionRatio is set to "101"
    ...    CB007219: NRBTS/actMfbiNrCaSupportFr1 is set to "true" in gnb-2 and gnb-1.
    ...    CB007219-B feature is disabled on prime-gNB and external gnb(NRBTS/actMfbiNrCaMeasConfResolv = false)
    ...    5GC001416: NRBTS/actMultiFrequencyBandIndicatorNRSupport=true for both gNB-1 and gNB-2.
    ...    CNI-75210:MRBTS/NRBTS/actExtN77Support=true
    ...    Cell2_1 operates in the frequency range of 3450MHz<= F4 <=3550MHz
    ...    Cell2_2 operates in the frequency range of 3650MHz<= F5 <=3980MHz
    ...    Cell1_11    Cell1_12    Cell1_13    Cell1_14    Cell2_1    Cell2_2    Cell2_3    Cell2_4
    ...    Technology type    FDD    FDD    FDD    FDD    TDD    TDD    TDD    TDD
    ...    Frequency    F0    F1    F2    F3    F4    F5    F6    F7
    ...    Common channel bandwidth    20    20    20    20    40    40    40    40
    ...    DL MIMO Layers    4L    4L    4L    4L    4L    4L    4L    4L
    ...    Native band    N2    N2    N66    N66    N77    N77    78    N78
    ...    Alternative band    N25    N25    NA    NA    N78    N78    N77    N77
    ...    UE1/2/3/4 capability:5G-UE indicates support of the lower extended band 77 in USA(UE-NR-Capability->RF-Parameters->extendedBand-n77-r16).
    ...    CA relation:cell1_13+cell2_1+cell2_3, A1 scell addition.inter-freq HO to cell2_3 is configured.
    ...    BC#1:N66A_N77(2A)
    ...    BC#2:N66A_N77A
    ...    BC#3:N66A_N78A
    ...    UE5:the same as UE1 but not support BC#3
    ...    2.Test Case Steps:
    ...         a. attach UE1/2/3/4 to cell1_13 and trigger A1 for scell addition.
    ...         b. trigger A2 for MG setup for UE1 and UE2.
    ...         c. online enable NRBTS/actMfbiNrCaMeasConfResolv = true in prime gNB, trigger A2 for MG setup for UE3 and UE4
    ...         d. trigger A1 for UE1 and UE3.
    ...         e. trigger A2 scell release for UE1 and UE3.
    ...         f. online disable NRBTS/actMfbiNrCaMeasConfResolv = false in prime gnb, trigger A1 for UE2 and UE4.
    ...         g. online enable NRBTS/actMfbiNrCaMeasConfResolv =true in prime gnb.
    ...         h. trigger A2 for MG setup for UE2.
    ...         i. trigger A1 for UE2.
    ...         j. trigger A2 for MG setup for UE2 and UE4.
    ...         k. trigger A3 for UE2 towards cell2_3 and meet the condition for scell addition.
    ...         l. trigger HO back to cell1_13 for UE2 and meet the condition for scell addition.
    ...         m. attach UE5 to cell1_13 and trigger A1 for scell addition.
    ...         n. trigger A2 for MG setup for UE5.
    ...         o. trigger A2 scell release for UE5.
    ...         p. trigger A3 HO to cell2_3. and HO back.
    ...         q. online remove alternative band n77 for cell2_3. and trigger A2 for MG setup for UE5.
    ...    3.Expectation:
    ...         a. cell2_1 and cell2_3 is added as scell successfully.Cell1_13 in band n66 and Cell2_1 and cell2_3 in band n77. BC#1 is selected.
    ...    A2 for scell release is configured with n77. A2 for inter-freq HO is configured to UE.
    ...         b. MG setup successfully. A3/A5 is configured with n77
    ...         c. online modification successfully. MG setup for UE3/UE4. and A3/A5 is reconfigured with n78. A2 for scell release is released.
    ...         d. for UE1 and UE3, gNB removes A3/A5 measurement configuration and releases measurement gaps. for UE1, A2 measurement for SCell
    ...    release remains with N77 ( it was never removed ). for UE3, gNB reconfigures the measurement object with N77 for A2 scell release.
    ...         e.scell release successfully.
    ...         f. online modification successfully. for UE2 and UE4, gNB removes A3/A5 measurement configuration and releases measurement gaps.
    ...    for UE2, A2 measurement for SCell release remains with N77 (it was never removed). for UE4, gNB reconfigures the measurement object
    ...    with N77 for A2 scell release.
    ...         g. online modification successfully.
    ...         h. MG setup for UE2. and A3/A5 is reconfigured with n78. A2 for scell release is released.
    ...         i. gNB removes A3/A5 measurement configuration and releases measurement gaps. gNB reconfigures the measurement object with N77
    ...    for A2 scell release.
    ...         j. MG setup for UE2 and UE4. A3/A5 is reconfigured with n78. A2 for scell release is released.
    ...         k. UE2 HO to cell2_3 successfully. cell1_13 is added as scell. A2 for mobility is configured with n78.
    ...         l. HO to cell1_13 successfully. cell2_1 and cell2_3 is added as scell successfully. Cell1_13 in band n66 and Cell2_1 and cell2_3 in
    ...    band n77. BC#1 is selected. A2 for scell release is configured with n77. A2 for inter-freq HO is configured to UE.
    ...         m. cell2_1 and cell2_3 is added as scell successfully.Cell1_13 in band n66 and Cell2_1 and cell2_3 in band n77. BC#1 is selected.
    ...    A2 for scell release is configured with n77. A2 for inter-freq HO is configured to UE.
    ...         n.MG setup successfully. A3/A5 is configured with n77.
    ...         o. scell release successfully for UE5.
    ...         p. HO to cell2_3 successfully. cell1_13 is added as scell. A2 for mobility is configured with n77.when HO back, HO to cell1_13
    ...    successfully. cell2_1 and cell2_3 is added as scell successfully. Cell1_13 in band n66 and Cell2_1 and cell2_3 in band n77. BC#1 is
    ...    selected. A2 for scell release is configured with n77. A2 for inter-freq HO is configured to UE.
    ...         q. online modification successfully. and no MG setup and no A3/A5 configured.
    [Tags]    QC_46817    christine.chen    B005    CA_LABEL-FTT(20MHZ_FDD_n66+40MHZ_TDD_n77+40MHZ_TDD_n77)
    ...    CA_LABEL-TF(40MHZ_TDD_n77+20MHZ_FDD_n66)
    Clear Counter Files for 2GNB and online modify para for B005
    B005 stepA-C
    B005 stepD-G
    B005 stepH-L
    Stop traffic
    B005 stepM-P
    B005 stepQ
    Release Ues    ue_type=all
    Check Counters GNB2    ${PM_Counters_Check_B005_gnb2}    wait=True
    [Teardown]    B005_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env     tl_type=fddtdd_sansa_cmwv/8cells_gnb1_4F_gnb2_4T    ue_count=15

OnlineParamChange_gNB1
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

OnlineParamChange_gNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters gnb2    ${Online_Param}
    Cells Should Be Onair GNB2

Ue register and pdu setup and A1 is configure
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=1    ${cell_id}=2    ${enb}=2
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${UE_register_and_A1_configured}

Trigger MR scelladd
    [Arguments]    ${scell_added_log}    ${ue_id}=81    ${carrierfreq}=650016
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${scell_added_log}

Trigger MR scelladd with error check
    [Arguments]    ${scell_added_log}    ${fail_check}    ${ue_id}=81    ${carrierfreq}=650016
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${scell_added_log}    fail_regexp=${fail_check}

Trigger A2 ScellRelease
    [Arguments]    ${carrierfreq}=508110    ${ue_id}=81    ${scell_id}=3    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=${pass_check}

Scell release one by one
    [Arguments]    ${ue_id}=1
    Trigger A2 ScellRelease    ue_id=${ue_id}    carrierfreq=643392    scell_id=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=2    min_dl_tput=150
    Trigger A2 ScellRelease    ue_id=${ue_id}    carrierfreq=633312    scell_id=1    pass_check=${A2_scell_release}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=1    min_dl_tput=50

Clear Counter Files for 2GNB for B002
    Clear Counter Files    ${False}
    Clear Counter Files GNB2    ${False}

Clear Counter Files for 2GNB and online modify para for B005
    Clear Counter Files
    Clear Counter Files GNB2
    OnlineParamChange_gNB1    ${CB007219_B_disabled}
    OnlineParamChange_gNB2    ${CB007219_B_disabled}

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=${N66_N77_and_N66_N78}    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=1    ${min_dl_tput}=360    ${min_ul_tput}=8
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 10
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Send Throughput
    [Arguments]    ${ue_id}=1    ${times}=3
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=${I}    UE ${ue_id}: UDP DL
    END

Trigger A2 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=${pass_check}

Trigger A2 measurement report with traffic check
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete    ${cell_num}=3
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=${pass_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=${cell_num}    min_dl_tput=250

Trigger A2 measurement report with traffic and error check
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete    ${cell_num}=3
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=${pass_check}
    should not contain    ${ret1}    freqBandIndicatorNR 78
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=${cell_num}    min_dl_tput=250

Trigger A2 measurement report with error check
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete    ${cell_num}=2
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${V2}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ${ret1}=    Execute Egate Command    ${V2}    pass_regexp=${pass_check}
    should not contain any    ${ret1}    @{no_A3_and_MG_config}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=${cell_num}    min_dl_tput=250

Trigger A3 Measurement Report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}    ${pass_check}    ${nrsrp_nr}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId} nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrp_nr}
    Execute Egate Command    ${V3}    pass_regexp=${pass_check}

Trigger A1 measurement report with traffic check
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}    ${phycell_id}=52
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=100 nrsrq_nr=100
    ${ret1}=    Execute Egate Command    ${A1_cmd}    pass_regexp=${pass_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=3    min_dl_tput=250

Trigger A1 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}    ${phycell_id}=52
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=100 nrsrq_nr=100
    ${ret1}=    Execute Egate Command    ${A1_cmd}    pass_regexp=${pass_check}

UE register and trigger A1 scelladd
    [Arguments]    ${ue_id}=1    ${SA_Capa_perUE_Full}=${N66_2N77_and_N66_N77_and_N66_2N78}
    Ue register and pdu setup and A1 is configure    SA_Capa_perUE_Full=${SA_Capa_perUE_Full}    ue_id=${ue_id}    cell_id=13
    Send Throughput    ue_id=${ue_id}    times=4
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=1    min_dl_tput=50
    Trigger MR scelladd    ${CA_check_CELL1_CELL3_for_B005}    ue_id=${ue_id}    carrierfreq=424090
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=3    min_dl_tput=250

B005_Teardown
    OnlineParamChange_gNB1    ${Online_add_alternative_band_and_enable_7219B}
    OnlineParamChange_gNB2    ${CB007219_B_enabled}
    Common Test Teardown And Stop Capture Logs

B002 stepA-B
    Ue register and pdu setup and A1 is configure    SA_Capa_perUE_Full=${N66_2N77_and_N66_N77_and_N66_2N78}    ue_id=1    cell_id=13
    Send Throughput    ue_id=1    times=4
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=1    min_dl_tput=50
    Trigger A2 measurement report    ue_id=1    carrierfreq=424090    pass_check=${MG_setup}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=1    min_dl_tput=50
    Trigger MR scelladd    ${CA_check_CELL1_CELL3}    ue_id=1    carrierfreq=424090
    #Trigger MR scelladd with error check    ${CA_check_CELL1_CELL3}    measObjectId 2    ue_id=1    carrierfreq=424090
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=3    min_dl_tput=360

B002 stepC-D
    Trigger A3 Measurement Report    ue_id=1    carrierfreq=643392    phycelId=52    pass_check=${A3_HO_to_cell3_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=1    min_dl_tput=50
    Trigger A2 measurement report    ue_id=1    carrierfreq=643392    pass_check=${MG_setup}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=1    min_dl_tput=50
    Trigger A3 Measurement Report    ue_id=1    carrierfreq=424090    phycelId=62    pass_check=${A3_HO_to_cell13_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=1    min_dl_tput=50
    Trigger A2 measurement report    ue_id=1    carrierfreq=424090    pass_check=${MG_setup}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=1    min_dl_tput=50

B002 stepE-G
    Trigger MR scelladd    ${CA_check_CELL1_CELL3}    ue_id=1    carrierfreq=424090
    #Trigger MR scelladd with error check    ${CA_check_CELL1_CELL3}    measObjectId 5    ue_id=1    carrierfreq=424090
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=3    min_dl_tput=360
    Trigger A1 measurement report    ue_id=1    carrierfreq=424090    pass_check=${pass_A1_mobility_check_for_B02}
    Scell release one by one    ue_id=1

B002 stepH-J
    Ue register and pdu setup and A1 is configure    SA_Capa_perUE_Full=${N66_2N77_and_N66_N77}    ue_id=2    cell_id=13
    Send Throughput    ue_id=2    times=4
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=2    cell_num=1    min_dl_tput=50
    Trigger A2 measurement report    ue_id=2    carrierfreq=424090    pass_check=${MG_setup_for_UE2}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=2    cell_num=1    min_dl_tput=50
    Trigger MR scelladd    ${CA_check_CELL1_CELL3_for_UE2}    ue_id=2    carrierfreq=424090
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=2    cell_num=3    min_dl_tput=440
    Scell release one by one    ue_id=2

B002 stepK
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=643392    phycelId=52    pass_check=${A3_HO_to_cell3_check_for_UE2}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=2    cell_num=1    min_dl_tput=50
    Trigger A2 measurement report    ue_id=2    carrierfreq=643392    pass_check=${MG_setup_for_UE2}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=2    cell_num=1    min_dl_tput=50
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=424090    phycelId=62    pass_check=${A3_HO_to_cell13_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=2    cell_num=1    min_dl_tput=50

B005 stepA-C
    UE register and trigger A1 scelladd
    UE register and trigger A1 scelladd    ue_id=2
    UE register and trigger A1 scelladd    ue_id=3
    UE register and trigger A1 scelladd    ue_id=4
    Trigger A2 measurement report with traffic check    ue_id=1    carrierfreq=424090    pass_check=${MG_setup_with_band77}
    Trigger A2 measurement report with traffic check    ue_id=2    carrierfreq=424090    pass_check=${MG_setup_with_band77}
    OnlineParamChange_gNB1    ${CB007219_B_enabled}
    Trigger A2 measurement report with traffic check    ue_id=3    carrierfreq=424090    pass_check=${MG_setup_with_band78_for_UE3UE4}
    Trigger A2 measurement report with traffic check    ue_id=4    carrierfreq=424090    pass_check=${MG_setup_with_band78_for_UE3UE4}

B005 stepD-G
    Trigger A1 measurement report with traffic check    ue_id=1    carrierfreq=424090    pass_check=${pass_A1_mobility_and_no_band_change}
    Trigger A1 measurement report with traffic check    ue_id=3    carrierfreq=424090    pass_check=${pass_A1_mobility_check}
    Scell release one by one    ue_id=1
    Scell release one by one    ue_id=3
    OnlineParamChange_gNB1    ${CB007219_B_disabled}
    Trigger A1 measurement report with traffic check    ue_id=2    carrierfreq=424090    pass_check=${pass_A1_mobility_and_no_band_change}
    Trigger A1 measurement report with traffic check    ue_id=4    carrierfreq=424090    pass_check=${pass_A1_mobility_check}
    OnlineParamChange_gNB1    ${CB007219_B_enabled}

B005 stepH-L
    Trigger A2 measurement report with traffic check    ue_id=2    carrierfreq=424090    pass_check=${MG_setup_with_band78_reconfig}
    Trigger A1 measurement report with traffic check    ue_id=2    carrierfreq=424090    pass_check=${pass_A1_mobility_with_band_change}
    Trigger A2 measurement report with traffic check    ue_id=2    carrierfreq=424090    pass_check=${MG_setup_with_band78_reconfig_again}
    Trigger A2 measurement report with traffic check    ue_id=4    carrierfreq=424090    pass_check=${MG_setup_with_band78_and_A2_remove}
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=643392    phycelId=52    pass_check=${A3HO_to_cell3_and_scell_add}    nrsrp_nr=100
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=2    cell_num=2    min_dl_tput=150
    Trigger A2 measurement report with traffic check    ue_id=2    carrierfreq=643392    pass_check=${MG_setup_with_band78}    cell_num=2
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=424090    phycelId=62    pass_check=${A3HO_to_cell13_and_scell_add}    nrsrp_nr=100
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=2    cell_num=3    min_dl_tput=250

Stop traffic
    Execute Egate Command    trf_data_stop ue=1 dir=dl pdu=1
    Execute Egate Command    trf_data_stop ue=2 dir=dl pdu=1
    Execute Egate Command    trf_data_stop ue=3 dir=dl pdu=1
    Execute Egate Command    trf_data_stop ue=4 dir=dl pdu=1

B005 stepM-P
    UE register and trigger A1 scelladd    ue_id=5    SA_Capa_perUE_Full=${N66_2N77_and_N66_N77}
    Trigger A2 measurement report with traffic and error check    ue_id=5    carrierfreq=424090    pass_check=${MG_setup_with_noband_config}
    Scell release one by one    ue_id=5
    Trigger A3 Measurement Report    ue_id=5    carrierfreq=643392    phycelId=52    pass_check=${A3HO_to_cell3_and_scell_for_UE5}    nrsrp_nr=100
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=5    cell_num=2    min_dl_tput=150
    Trigger A2 measurement report with traffic check    ue_id=5    carrierfreq=643392    pass_check=${MG_setup_with_band77}    cell_num=2
    Trigger A3 Measurement Report    ue_id=5    carrierfreq=424090    phycelId=62    pass_check=${A3HO_to_cell13_and_scell_for_UE5}    nrsrp_nr=100
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=5    cell_num=3    min_dl_tput=250

B005 stepQ
    OnlineParamChange_gNB1    ${Online_remove_alternative_band}
    Trigger A2 measurement report with error check    ue_id=5    carrierfreq=424090    pass_check=${No_MG_setup_with_band77}

