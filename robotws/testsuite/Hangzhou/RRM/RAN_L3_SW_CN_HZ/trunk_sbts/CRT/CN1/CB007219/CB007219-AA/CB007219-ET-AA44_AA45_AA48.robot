*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-jing.ye
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{732}
...    @{7219}
...    @{1416}
...    @{Scell_Rel}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{CB008225_CB006597}
...    @{Samll_BWP}
...    @{IRAT_config}    #AA48
...    @{Scell_Rel_AA48}    #AA48

@{732}
...    NRBTS:rrcReestabTypeSA=sameGNB

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=25
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=41

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=25

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1

@{CA_enable}
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:carrierAggregationSupportList=${CAlist}
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS-1:sCellActivationMethod=blind
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd

@{MimoMode_Para}
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:nrCellType=4DL4UL
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=4DL4UL
...    NRCELL-13:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:nrCellType=4DL4UL
...    NRCELL-14:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-14:nrCellType=4DL4UL
...    NRCELL-11:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-11:nrCellType=4DL4UL
...    NRCELL-12:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:nrCellType=4DL4UL

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

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:resourceDN

@{Scell_Rel}
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-1/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-13:gNbId=1
...    NRCELL-1/NRREL-13:gNbIdLength=22
...    NRCELL-1/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-13:removeNotAllowed=false
...    NRCELL-1/NRREL-13:lcrId=13
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlOnly

...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{CB008225_CB006597}
...    NRBTS:act3gppBL23R1=true
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:ranPagingCycle=v32
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:t380=5min
...    NRBTS:tRanPagingGuard=4
...    NRBTS:timerReleasePreferenceProhibit=s3

@{Samll_BWP}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:bwpType=dedicated
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n217
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-1:actEnhMultipleDedicatedBWPs=true
...    NRCELL-1:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-13:actEnhMultipleDedicatedBWPs=true
...    NRCELL-1:msg1FrequencyStart=25
...    NRCELL-2:msg1FrequencyStart=20

@{IRAT_config}
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:actInterRatHoFromEutraToSA=true
...    NRBTS-1:nonContentRachAcFullConfigHo=true
...    NRBTS-1:tNgRelocExecDeltL=5000
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:actCDrx=true
...    NRCELL-2:dtxOptimizedScheduler:dtxDelaySinceLastScheduling=0
...    NRCELL-2:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-2:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-2:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
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
...    MRBTS-1/NRBTS-1/NRCELL-2/NRRELE-1:cellIndividualOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-2/NRRELE-1:eNodeBId=18
...    MRBTS-1/NRBTS-1/NRCELL-2/NRRELE-1:eutranCellExcluded=false
...    MRBTS-1/NRBTS-1/NRCELL-2/NRRELE-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRRELE-1:removeNotAllowed=false
...    MRBTS-1/NRBTS-1/NRCELL-2/NRRELE-1:ecgiPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-2/NRRELE-1:ecgiPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-2/NRRELE-1:ecgiPlmn:mncLength=3

@{Scell_Rel_AA48}
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=1
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlOnly

@{OnlineParam_enable_7219}
...    NRBTS:actMfbiNrCaSupportFr1=true

@{OnlineParam_disable_7219}
...    NRBTS:actMfbiNrCaSupportFr1=false

@{8225_disable}
...    NRBTS:actRrcInactState=none
...    NRBTS:outOfConnectedPreference=idle

@{OnlineParam_enable_7219_and_recover_8225}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:outOfConnectedPreference=inactive

@{PDU_with_A1}
...    QoS Routing Table
...    eventId eventA1
...    freqBandIndicatorNR 2

@{CA_check_CELL13_CELL1}
...    eventId eventA2
...    freqBandIndicatorNR 77
...    locationAndBandwidth 16499    #30KHz,80M
...    pcid:62, scellIdx:0
...    pcid:50, scellIdx:1
...    PhysCellId: 50] SCellIndex 1 activated successfully at airphone

@{CA_check_CELL1_CELL13}
...    eventId eventA2
...    freqBandIndicatorNR 2
...    locationAndBandwidth 28875    #15KHz,20M
...    pcid:50, scellIdx:0
...    pcid:62, scellIdx:1
...    PhysCellId: 62] SCellIndex 1 activated successfully at airphone

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    UE81: Is INACTIVE

@{resum_success_cell13}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResumeComplete
...    pcid:62, scellIdx:0
...    eventId eventA1
...    freqBandIndicatorNR 2
...    rrcReconfigurationComplete

@{pdu_setup_success_without_A1}
...    pcid:62, scellIdx:0
...    freqBandIndicatorNR 25
...    QoS Routing Table

@{pdu_setup_success_A1_config}
...    pcid:62, scellIdx:0
...    freqBandIndicatorNR 2
...    eventId eventA1
...    QoS Routing Table

@{RRE_to_cell13}
...    rrcReestablishmentComplete
...    eventId eventA1
...    pcid:62, scellIdx:0
...    rrcReconfigurationComplete

@{RRE_to_cell13_7219_enable}
...    rrcReestablishmentComplete
...    freqBandIndicatorNR 2
...    eventId eventA1
...    pcid:62, scellIdx:0
...    rrcReconfigurationComplete

@{RRE_to_cell1_7219_disable}
...    rrcReestablishmentComplete
...    pcid:50, scellIdx:0
...    rrcReconfigurationComplete

@{RRE_to_cell1_7219_enable}
...    rrcReestablishmentComplete
...    freqBandIndicatorNR 77
...    eventId eventA1
...    pcid:50, scellIdx:0
...    rrcReconfigurationComplete

@{RRE_to_cell13_7219_disable}
...    rrcReestablishmentComplete
...    freqBandIndicatorNR 25
...    pcid:62, scellIdx:0
...    rrcReconfigurationComplete

@{resum_success_cell13_without_A1}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResumeComplete
...    pcid:62, scellIdx:0
...    freqBandIndicatorNR 25

@{resum_success_cell1_without_A1}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResumeComplete
...    pcid:50, scellIdx:0
...    freqBandIndicatorNR 77

@{resum_success_cell1}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResumeComplete
...    pcid:50, scellIdx:0
...    eventId eventA1
...    freqBandIndicatorNR 77
...    rrcReconfigurationComplete
@{CA_check_cell2_cell13}
...    eventId eventA2
...    freqBandIndicatorNR 2
...    pcid:62, scellIdx:1
...    PhysCellId: 62] SCellIndex 1 activated successfully at airphone

@{PDU_with_n78}
...    freqBandIndicatorNR 78
...    pcid:51, scellIdx:0
...    QoS Routing Table

@{HO_back_with_7219_enabled}
...    freqBandIndicatorNR 78
...    Inter-eNB handover from ENB-5.1 to EXT_ENB-2.2 performed
...    rrcReconfigurationComplete 
...    pcid:51, scellIdx:0

@{HO_back_with_7219_disabled}
...    freqBandIndicatorNR 77
...    Inter-eNB handover from ENB-5.1 to EXT_ENB-2.2 performed
...    rrcReconfigurationComplete 
...    pcid:51, scellIdx:0

@{fail_check_n78_A1}
...    freqBandIndicatorNR 78
...    eventId eventA1

@{gap_stepup_check}
...    gapFR1 setup
...    rrcReconfigurationComplete

@{PM_Counters_Check_for_AA44}
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_REQ}=1
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_REQ}=1
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=2
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_REQ}=2
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=2


@{PM_Counters_Check_for_AA45}
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_REQ}=2
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_SUCC}=2
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_REQ}=2
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=2
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_REQ}=2
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=2
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=3

@{PM_Counters_Check_for_AA48}
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-2:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=1
...    NRCELL-2:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=1

${SCELL_CONF_ALT_BAND_SA}    M55118C01005    #This counter provides the number of current cell configurations as an SA SCell in an alternative band
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501    #This counter provides the number of radio admission requests for the SA user, where admission is
#requested on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502    #This counter provides the number of admitted radio admission requests for the SA user,
#where admission is done on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001    #This counter provides the number of radio admission requests with MFBI for the SA user.
#The counter is updated to the PCell on DU.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002    #This counter provides the number of radio-admitted UEs for the SA user using the alternative
#band.The counter is updated to the PCell on DU.
${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503    #radio admission HO requests for SA user where admission is requested on the alternative band.
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504    #admitted HO radio admissions for SA user where admission is done on the alternative band.
${GNB_SA_DU_HO_ADMISS_MFBI_REQ}    M55139C02005    #The number of radio admission HO requests on alternative band for SA users.
${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}    M55139C02006    #The number of radio admitted HO radio resources on alternative band for SA users.

${N2_N77_and_N25_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D85181AC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA
...    39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B007582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF0000017
...    0000381546C4CD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A0092D93154143
...    9F11C78C0000000000000000004FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC
...    007003FF0005C0000E0013C3C01000E260000010B0102F0F0600038980000102C040803808D00A2026C041174001B01428913639F0E14489B1CF860070218C1E82E003C00281
...    C1401C0C02500700060240040603E01802000000010000020080000200400001806CA5ACA4AC0DAC0CA0182000012CA4A080000CB29282000052CA4A080001CB292806A53554
...    A6AA81D5503AA16004800D02800342020040080801002101008010040080110080200402004008080100220100200404010020100400820200C0180801002101004008040080
...    10808040080200400840400801010040084020080100801002020040088040100201002004040080110080100202004008080100220100200404008010100200420200400808
...    020042010020040400801010040086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05064B5288000108

${N2_N78_and_N2_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D89981AC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA
...    39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B007582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD80000017
...    0000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D88DAC1184341020F1068032B64C55
...    890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A816806F1C610D00151E7E2868022F6CC554800F1E00438820C22A051FBF9025F78B40
...    001800278789A001C01000002160205E1E26000700400001058081009011A014404D808304005D0006C050A244D8E7C3851226C73E1801C086307A0B800F000F070500703009
...    401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000
...    4802000030010000140080000B004002048120080000C0339515953582958195833582B594B5933580B581B580958115CAD03410000096525040000659494100002965240400
...    00E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C965240400030594900CD2AABA55554AA2E
...    95455058AA0B1541A2A94C55268AA031540A2A9355596285805E02540A05028140A05028140A05028140A05028140A05000708080600C02004008404008010100C0182020080
...    08080600C10100C018040300610080100202018030080100220100C01804030060100C018202004010080100400101E0386A87C0004080C10181C282C30344044484C5060646
...    C70747C8494989CA0A4A8B4BD05060B4

*** Test Cases ***
CB007219_AA44_Verify_CB007219_Interaction_with_RRCResume
    [Documentation]
    ...    1. This user scenario describes the interaction of CB007219 with RRCResume when the PCell is configured with native and alternative bands
    ...    and the UE supports both bands. It also describes the behaviour for CA configuration and the effects of online modification of the
    ...    CB007219 FAF.
    ...    2. Configuration
    ...    CB007219: NRBTS/actMfbiNrCaSupportFr1=true
    ...    5GC001416: NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    CB008225: NRBTS/actRrcInactState=intra-gNB
    ...    CB006597: NRBTS:actRrcReleasePreference=true
    ...    CB008541: actEnhMultipleDedicatedBWPs=true and actMultipleDedicatedBWPs=true
    ...    Cell configuration:
    ...                        cell_11    cell_12    cell_13    cell_14    cell_1    cell_2    cell_3    cell_4
    ...    Technology type     FDD        FDD        FDD        FDD        TDD       TDD       TDD       TDD   
    ...    Frequency           F2         F3         F0         F1         F6        F7        F4        F5    
    ...    chbw                20         20         20         20         100       100       40        20    
    ...    Small BWP                                                       80	                    
    ...    DL MIMO Layers      2L         2L         4L         4L         4L        4L        4L        4L    
    ...    Native band         n66        n71        n2         n2         n78       n78       n38       n38   
    ...    Alternative band                          n25                   n77       n77       n41             
    ...    all UEs supports UAI. 
    ...    UE1 capability: CA relation: cell1+cell13 and cell13+cell1, A1 scell addition
    ...    BC#1: n2A-n77A                  N2    n77	   
    ...    DL FSEI#1:    DL MIMO layers    2L    4L	   
    ...    DL ChBw (MHz)                   20    80	   
    ...    UL FSEI#1:    UL MIMO layers    2L    2L	   
    ...    UL ChBw (MHz)                   20    80	   
    ...    BC#2: n25A-n77A                 N25    N77	   
    ...    DL FSEI#1:    DL MIMO layers    4L     4L	   
    ...    DL ChBw (MHz)                   20     80	   
    ...    UL FSEI#1:    UL MIMO layers    2L     2L		   
    ...    UL ChBw (MHz)                   20     80
    ...    3. Test Case Steps:
    ...    a. Attach UE81 to cell13, and trigger A1 for scell addition. Start DL/UL traffic.
    ...    b. Trigger UE1 inactive, then resume to cell13. Trigger A1 for scell addition.
    ...    c. Trigger UE1 inactive. online modify NRBTS/actMfbiNrCaSupportFr1 from true to false, then resume to cell13.
    ...    d. Trigger UE1 inactive. Online modify NRBTS/actMfbiNrCaSupportFr1 from false to true, then RRC Resume to cell13.
    ...    e. Online modify NRBTS/actMfbiNrCaSupportFr1 from true to false, then trigger A1.
    ...    f: trigger UE1 inactive, then RRC Resume to cell1.
    ...    g: online modify NRBTS/actMfbiNrCaSupportFr1 from false to true. Trigger UE1 inactive, then RRC Resume to cell1. Trigger A1.
    ...    h: Check counters
    ...    Expected Result:
    ...    a. Scell addition successfully. Pcell Cell13 in n2. Scell cell1 in n77. BC#1FSEI#1 is selected.
    ...    b. UE is transitioned to RRC_INACTIVE state. Then resume with PCell cell13 in band n2. A1 for scell addition is configured to UE. 
    ...       Scell addition successfully. Pcell cell13 in n2. Scell cell1 in n77. BC#1FSEI#1 is selected.
    ...    c. UE is transitioned to RRC_INACTIVE state. UE resume with PCell cell13 in band n25.A1 measurement for SCell addition is not configured.
    ...    d. UE is transitioned to RRC_INACTIVE state. UE resume with PCell cell13 in band n2. A1 for scell addition is configured to UE.
    ...    e. On receiving A1 measurement for SCell addition, gNB will not add CA configuration as UE can not support the native band n78 of Cell1.
    ...    f. UE is transitioned to RRC_INACTIVE state. UE resume with PCell cell1 in band n77. but no A1 for scell addition is configured to UE.
    ...    g: UE is transitioned to RRC_INACTIVE state. UE resume with PCell cell1 in band n77. A1 for scell addition is configured to UE.
    ...       Scell addition successfully. Pcell cell1 in n77. Scell cell13 in n2. BC#1FSEI#1 is selected(As 81817 is disable, 
    ...       CU will only send BC#1 to DU).
    ...    h: Counters are updated correctly.
    [Tags]    QC_341727    jing.ye    AA44    CA_LABEL-FT(20MHZ_FDD_n2+80MHZ_TDD_n77)    CA_LABEL-TF(80MHZ_TDD_n77+20MHZ_FDD_n2)
    Clear Counter Files    wait=${False}
    UE attach and add scell successfully
    Scell Addition Successful after Resume
    A1 Should Not Configured When 7219 is Disabled After Resume
    A1 is Configured After 7219 is Enabled After Resume
    Scell Should Not Be Added When 7219 is Disabled
    A1 is not Configured After Resume to Another Cell
    Scell Addition Successful When 7219 is Enabled After Resume
    Release Ues    ue_type=all
    Check Counters    ${PM_Counters_Check_for_AA44}  
    [Teardown]    AA44_Teardown

CB007219_AA45_Verify_CB007219_Interaction_with_RRC-Reestablishment
    [Documentation]
    ...    1. This user scenario describes the interaction of CB007219 with RRC-Reestablishment when the PCell is configured with native and
    ...    alternative bands and the UE supports both bands. It also describes the behaviour for CA configuration and the effects of online
    ...    modification of the CB007219 FAF.
    ...    2. Configuration
    ...    CB007219: NRBTS/actMfbiNrCaSupportFr1=true
    ...    5GC001416: NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    5GC000732:NRBTS/rrcReestabTypeSA=sameGNB
    ...    CB008541: actEnhMultipleDedicatedBWPs=true and actMultipleDedicatedBWPs=true
    ...    Cell configuration:
    ...                        cell_11    cell_12    cell_13    cell_14    cell_1    cell_2    cell_3    cell_4
    ...    Technology type     FDD        FDD        FDD        FDD        TDD       TDD       TDD       TDD
    ...    Frequency           F2         F3         F0         F1         F6        F7        F4        F5
    ...    chbw                20         20         20         20         100       100       40        20
    ...    Small BWP                                                       80
    ...    DL MIMO Layers      2L         2L         4L         4L         4L        4L        4L        4L
    ...    Native band         n66        n71        n2         n2         n78       n78       n38       n38
    ...    Alternative band                          n25                   n77       n77       n41
    ...    all UEs supports UAI.
    ...    UE1 capability: CA relation: cell1+cell13 and cell13+cell1, A1 scell addition
    ...    BC#1: n2A-n77A                  N2    n77
    ...    DL FSEI#1:    DL MIMO layers    2L    4L
    ...    DL ChBw (MHz)                   20    80
    ...    UL FSEI#1:    UL MIMO layers    2L    2L
    ...    UL ChBw (MHz)                   20    80
    ...    BC#2: n25A-n77A                 N25    N77
    ...    DL FSEI#1:    DL MIMO layers    4L     4L
    ...    DL ChBw (MHz)                   20     80
    ...    UL FSEI#1:    UL MIMO layers    2L     2L
    ...    UL ChBw (MHz)                   20     80
    ...    3. Test Case Steps:
    ...    1). attach UE1 to cell13, and trigger A1 for scell addition. Start DL/UL traffic.
    ...    Expect scell addition successfully. Cell113 in n2. cell1 in n77. BC#1FSEI#1 is selected.
    ...    2). trigger UE1 RRCReestablishment request to Cell13
    ...    Expect UE1 RRCReestablishment successfully. Cell13 in n2. and A1 for scell additon is configured to UE.
    ...    3). trigger A1 for scell addition.
    ...    Expect scell addition successfully. Cell13 in n2. cell1 in n77. BC#1FSEI#1 is selected
    ...    4). online modify NRBTS/actMfbiNrCaSupportFr1 from true to false.
    ...    Expect online modification successfully.
    ...    5). trigger UE1 RRCReestablishment request to Cell13.
    ...    Expect UE1 RRCReestablishment successfully. Cell13 in n25. and no A1 for scell additon is configured to UE.
    ...    6). online modify NRBTS/actMfbiNrCaSupportFr1 from false to true.
    ...    Expect online modification successfully.
    ...    7). trigger UE1 RRCReestablishment request to Cell13.
    ...    Expect UE1 RRCReestablishment successfully. Cell13 in n2. and A1 for scell additon is configured to UE.
    ...    8). online modify NRBTS/actMfbiNrCaSupportFr1 from true to false.
    ...    Expect online modification successfully.
    ...    9). trigger A1
    ...    Expect receiving A1 measurement for SCell addition, gNB will not add CA configuration as UE can not support the native band n78 of Cell1.
    ...    10). release UE1 and UE1 is released successfully.
    ...    11). attach UE1 to cell13. Start DL/UL traffic
    ...    Expect UE connects to Cell13 with band n25, A1 measurement for SCell addition is NOT configured on the UE.
    ...    12). online modify NRBTS/actMfbiNrCaSupportFr1 from false to true.
    ...    Expect online modification successfully.
    ...    13). trigger UE1 RRCReestablishment request to Cell13
    ...    Expect UE1 RRCReestablishment successfully. Cell13 in n2. and A1 for scell additon is configured to UE.
    ...    14). trigger A1 for scell addition.
    ...    Expect scell addition successfully. Cell13 in n2. cell1 in n77. BC#1FSEI#1 is selected.
    ...    15). online modify NRBTS/actMfbiNrCaSupportFr1 from true to false
    ...    Expect online modification successfully.
    ...    16). trigger UE1 RRCReestablishment request to Cell1.
    ...    Expect UE1 RRCReestablishment successfully. Cell1 is in n77. no A1 for scell additon is configured to UE.
    ...    17). online modify NRBTS/actMfbiNrCaSupportFr1 from false to true.
    ...    Expect online modification successfully.
    ...    18). trigger UE1 RRCReestablishment request to Cell1.
    ...    Expect UE1 RRCReestablishment successfully. Cell1 is in n77. and A1 for scell additon is configured to UE.
    ...    19). trigger A1.
    ...    Expect scell addition successfully. Cell13 in n2. cell1 in n77. BC#1FSEI#1 is selected because native band will be selected first.
    ...    20). check counters.
    [Tags]    QC_341728    christine.chen    AA45    CA_LABEL-FT(20MHZ_FDD_n2+80MHZ_TDD_n77)    CA_LABEL-TF(80MHZ_TDD_n77+20MHZ_FDD_n2)
    Clear Counter and online change param and update UE Capa
    AA45 step 1-5
    AA45 step 6-10
    AA45 step 10-15
    AA45 step 16-20
    Check Counters    ${PM_Counters_Check_for_AA45}   
    [Teardown]    AA45_Teardown

CB007219_AA48_Successful_inter-RAT_HO_to_a_PCell_supporting_native_and_alternative_bands
    [Documentation]
    ...    1. This user scenario describes the successful inter-RAT HO from EUTRAN to an NR PCell, when both the UE and the target NR PCell support
    ...    the same multiple bands, with the selection of the native band of the NR PCell, even if it provides less data throughput than the
    ...    alternative band.07219 FAF.
    ...    2. Configuration
    ...    inter-RAT config
    ...    CB007219: NRBTS/actMfbiNrCaSupportFr1=true
    ...    5GC001416: NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    CB008541:actEnhMultipleDedicatedBWPs =true, actMultipleDedicatedBWPs=true
    ...    Cell configuration:
    ...                        cell_11    cell_12    cell_13    cell_14    cell_1    cell_2    cell_3    cell_4
    ...    Technology type     FDD        FDD        FDD        FDD        TDD       TDD       TDD       TDD
    ...    Frequency           F2         F3         F0         F1         F6        F7        F4        F5
    ...    chbw                20         20         20         20         100       100       40        20
    ...    Small BWP                                                       80
    ...    DL MIMO Layers      2L         2L         4L         4L         4L        4L        4L        4L
    ...    Native band         n66        n71        n2         n2         n78       n78       n38       n38
    ...    Alternative band                          n25                   n77       n77       n41
    ...    UE1 capability: CA relation: cell2+cell13, A1 scell addition
    ...    BC#1: n2A-n77A                  N2    n77
    ...    DL FSEI#1:    DL MIMO layers    2L    4L
    ...    DL ChBw (MHz)                   20    100
    ...    UL FSEI#1:    UL MIMO layers    2L    2L
    ...    UL ChBw (MHz)                   20    100
    ...    BC#2: n2A-n78A                  N2    N78
    ...    DL FSEI#1:    DL MIMO layers    4L     2L
    ...    DL ChBw (MHz)                   20     100
    ...    UL FSEI#1:    UL MIMO layers    2L     2L
    ...    UL ChBw (MHz)                   20     100
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell2 and trigger A1 for scell addition. Start DL/UL traffic.
    ...    b. trigger B2 MR to HO to LTE
    ...    c. trigger HO back to cell2 from LTE. and trigger A1 for scell addition.
    ...    d. trigger B2 MR to HO to LTE
    ...    e. online disable 7219.
    ...    f: trigger HO back to cell2 from LTE.
    ...    Expected Result:
    ...    a. UE1 attach to cell2 with n78 successfully. and cell13 is addes as scell with n2. BC#2 is selected. traffic is OK.
    ...    b. HO to LTE cell successfully.
    ...    c. HO to cell2 with n78 successfully. and cell13 is addes as scell with n2. BC#2 is selected. traffic is OK.
    ...    d. HO to LTE cell successfully.
    ...    e. online modification successfully.
    ...    f. HO to cell2 with n77 successfully. BC#1 is selected. no A1 for scell addition is configured.UPD010:1416 enabled but 7219 disabled,
    ...    pcell is alternative band, A1 for scell addition will be not configured.
    [Tags]    QC_348464    jiadan.wu    AA48    CA_LABEL-TF(100MHZ_TDD_n78+20MHZ_FDD_n2)
    Clear Counter Files
    UE attach to cell2 and scell addition
    Trigger B2 MR to HO to LTE    ue_id=81    carrierfreq=648096    event_type=B2    pass_check=${gap_stepup_check}
    Trigger HO back from LTE    ue_id=81    pass_check=${HO_back_with_7219_enabled}
    Trigger MR scelladd    ${CA_check_cell2_cell13}    ue_id=81    carrierfreq=648096
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput    Tput_dl=600
    Trigger B2 MR to HO to LTE    ue_id=81    carrierfreq=648096    event_type=B2    pass_check=${gap_stepup_check}
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger HO back from LTE with Error check    ue_id=81    pass_check=${HO_back_with_7219_disabled}    fail_check=${fail_check_n78_A1}
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput    Tput_dl=600
    Check Counters    ${PM_Counters_Check_for_AA48}
    [Teardown]    AA44_Teardown
    
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_N66_N71_2N78_2N38    ue_count=15

AA44_Teardown
    OnlineParamChange    ${OnlineParam_enable_7219}
    Common Test Teardown And Stop Capture Logs

AA45_Teardown
    OnlineParamChange    ${OnlineParam_enable_7219_and_recover_8225}
    Common Test Teardown And Stop Capture Logs

Clear Counter and online change param and update UE Capa
    Clear Counter Files
    OnlineParamChange    ${8225_disable}
    Update UE capa    SA_Capa_perUE_Full=${N2_N77_and_N25_N77}    ue_id=81

UE attach and add scell successfully
    Ue register and pdu session setup with core network assistance info    ${N2_N77_and_N25_N77}    cell_id=13    pass_regrxp=${PDU_with_A1}
    Trigger MR scelladd    ${CA_check_CELL13_CELL1}    ue_id=81    carrierfreq=388830
    Send Throughput
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput

Scell Addition Successful after Resume
    Trigger UE Inactive by UAI
    Trigger RRC Resume Success    cell_id=13
    Trigger MR scelladd    ${CA_check_CELL13_CELL1}    ue_id=81    carrierfreq=388830
    Send Throughput
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput

A1 Should Not Configured When 7219 is Disabled After Resume
    Trigger UE Inactive by UAI
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger RRC Resume Success Without A1    cell_id=13    pass_regexp=${resum_success_cell13_without_A1}
    Send Throughput
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput    Tput_dl=30

A1 is Configured After 7219 is Enabled After Resume
    Trigger UE Inactive by UAI
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger RRC Resume Success    cell_id=13
    Send Throughput

Scell Should Not Be Added When 7219 is Disabled
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger MR Without Scelladd    ${CA_check_CELL13_CELL1}    ue_id=81    carrierfreq=388830

A1 is not Configured After Resume to Another Cell
    Trigger UE Inactive by UAI
    Trigger RRC Resume Success Without A1    cell_id=1    pass_regexp=${resum_success_cell1_without_A1}
    Send Throughput
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput    Tput_dl=30

Scell Addition Successful When 7219 is Enabled After Resume
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger UE Inactive by UAI
    Trigger RRC Resume Success    cell_id=1    pass_regexp=${resum_success_cell1}
    Trigger MR scelladd    ${CA_check_CELL1_CELL13}    ue_id=81    carrierfreq=632736
	
Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Ue register and pdu session setup with core network assistance info
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=81    ${cell_id}=13    ${pass_regrxp}=QoS Routing Table
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ${core_assis_info}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${core_assis_info}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regrxp}

Trigger MR scelladd
    [Arguments]    ${scell_added_log}    ${ue_id}=81    ${carrierfreq}=650016
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${scell_added_log}
	
Trigger MR Without Scelladd
    [Arguments]    ${scell_added_log}    ${ue_id}=81    ${carrierfreq}=650016
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    fail_regexp=${scell_added_log}    timeout=5s

Ue register and pdu session setup withoutA1
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${Pass_regrxp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${Pass_regrxp}
    Should Not Contain    ${ret}    eventId eventA1

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=20 trf_id=10    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Verify Throughput
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=240    ${Tput_ul}=16
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Trigger UE Inactive by UAI
    [Arguments]    ${ue_id}=81
    Stop traffic
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive    pass_regexp=${INACTIVE_check}
    sleep    1s    #sleep for inactive procedure complete

Trigger RRC Resume Success
    [Arguments]    ${ue_id}=81    ${cell_id}=13    ${pass_regexp}=${resum_success_cell13}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mo_Data
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

Trigger RRC Resume Success Without A1
    [Arguments]    ${ue_id}=81    ${cell_id}=13    ${pass_regexp}=${resum_success_cell13}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mo_Data
    ${ret}    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}
    should not contain    ${ret}    eventId eventA1

Stop traffic
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul    UE${ue_id}: Stopping
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl    UE ${ue_id}: DL Traffic was stopped

Trigger RRCReestablishment
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${RRE_check}=RRC
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure    pass_regexp=${RRE_check}
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput

Trigger RRCReestablishment withoutA1
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${RRE_check}=RRC
    ${ret}    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure    pass_regexp=${RRE_check}
    Should Not Contain    ${ret}    eventId eventA1
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput

AA45 step 1-5
    Ue register and pdu session setup    SA_Capa_perUE_Full=${N2_N77_and_N25_N77}    ue_id=81    cell_id=13
    ...    pass_regrxp=${pdu_setup_success_A1_config}
    Trigger MR scelladd    ${CA_check_CELL13_CELL1}    ue_id=81    carrierfreq=388830
    Send Throughput
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput
    Trigger RRCReestablishment    ue_id=81    cell_id=13    RRE_check=${RRE_to_cell13}
    Trigger MR scelladd    ${CA_check_CELL13_CELL1}    ue_id=81    carrierfreq=388830
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger RRCReestablishment    ue_id=81    cell_id=13    RRE_check=${RRE_to_cell13_7219_disable}

AA45 step 6-10
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger RRCReestablishment    ue_id=81    cell_id=13    RRE_check=${RRE_to_cell13_7219_enable}
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger MR Without Scelladd    rrcReconfigurationComplete    ue_id=81    carrierfreq=388830
    Release Ues    ue_type=all

AA45 step 10-15
    Ue register and pdu session setup withoutA1    ue_id=81    cell_id=13    Pass_regrxp=${pdu_setup_success_without_A1}
    Send Throughput
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger RRCReestablishment    ue_id=81    cell_id=13    RRE_check=${RRE_to_cell13_7219_enable}
    Trigger MR scelladd    ${CA_check_CELL13_CELL1}    ue_id=81    carrierfreq=388830
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput
    OnlineParamChange    ${OnlineParam_disable_7219}

AA45 step 16-20
    Trigger RRCReestablishment withoutA1    ue_id=81    cell_id=1    RRE_check=${RRE_to_cell1_7219_disable}
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger RRCReestablishment    ue_id=81    cell_id=1    RRE_check=${RRE_to_cell1_7219_enable}
    Trigger MR scelladd    ${CA_check_CELL1_CELL13}    ue_id=81    carrierfreq=632736
    Release Ues    ue_type=all

Modify Cfg
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.15 daemon=10.0.2.1:22222 gnb_id=0x12:28
    ...    nssai=0x01:0xD143A5
    Update Cfg    ${set_gnb5}
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12218 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=true

UE attach to cell2 and scell addition
    Ue register and pdu session setup    SA_Capa_perUE_Full=${N2_N78_and_N2_N77}    pass_regrxp=${PDU_with_n78}
    Trigger MR scelladd    ${CA_check_cell2_cell13}    ue_id=81    carrierfreq=648096
    Send Throughput    times=6
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput    Tput_dl=600

Ue register and pdu session setup
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=81    ${cell_id}=2    ${pass_regrxp}=QoS Routing Table
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regrxp}

Trigger B2 MR to HO to LTE
    [Arguments]    ${ue_id}=81    ${carrierfreq}=648096    ${event_type}=B2    ${pass_check}=gapFR1 setup
    Trigger A2 measurement report    ue_id=81    carrierfreq=${carrierfreq}    pass_check=${pass_check}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=1    event_type=B2    carrierfreq_rat=EUTRAN
    ${meas_para}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${meas_para}    pass_regexp=IRAT Handover from NR to EUTRA completed
    sleep    20s    reason=wait timer

Trigger HO back from LTE
    [Arguments]    ${ue_id}=81    ${pass_check}=ENB-5.1 to EXT_ENB-2.2
    Execute Egate Command    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=2 plmn=311:489
    ...    pass_regexp=${pass_check}

Trigger HO back from LTE with Error check
    [Arguments]    ${fail_check}    ${ue_id}=81    ${pass_check}=ENB-5.1 to EXT_ENB-2.2
    ${ret}=    Execute Egate Command    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=2 plmn=311:489
    ...    pass_regexp=${pass_check}
    should not contain any    ${ret}    @{fail_check}

Trigger A2 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=10 srsrq_nr=10
    ...    pass_regexp=${pass_check}
    
    
