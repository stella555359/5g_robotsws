*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-jing.ye
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{1416}
...    @{CA_enable}
...    @{CA_REL}
...    @{8290}
...    @{MimoMode_Para}
...    @{CA_REL_AA39}
...    @{CA_REL_AA47}

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=false
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRCELL-1:chBw=80MHz
...    NRCELL-2:chBw=80MHz
...    NRCELL-3:chBw=80MHz
...    NRCELL-1:freqBandIndicatorNR=77
...    NRCELL-2:freqBandIndicatorNR=77

@{8290}
...    NRCELL-14:gscnOrSsPbchArfcn=4860
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=390000
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=374000
...    NRCELL-14/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-14:type0CoresetConfigurationIndex=2
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRCELL-13:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-13:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-13:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-13:reportAmountA6MeasSCellSwap=r4
...    NRCELL-13:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-13:thresholdSCellSwapSourceRsrp=66
...    NRCELL-13:thresholdSCellSwapSourceRsrq=67
...    NRCELL-14:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-14:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-14:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-14:reportAmountA6MeasSCellSwap=r4
...    NRCELL-14:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-14:thresholdSCellSwapSourceRsrp=66
...    NRCELL-14:thresholdSCellSwapSourceRsrq=67

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRCELL-14:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-14:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=41
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1

@{CA_enable}
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:carrierAggregationSupportList=${CAlist}
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa

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


@{CA_REL}
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:isRplCellForPSCell=true
...    NRCELL-11/NRREL-13:gNbId=1
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-13:sCellPrio=1
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:isRplCellForPSCell=true
...    NRCELL-11/NRREL-14:gNbId=1
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:sCellPrio=2
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:isRplCellForPSCell=true
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:isRplCellForPSCell=true
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
...    NRCELL-11/NRREL-3:isRplCellForPSCell=true
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{CA_REL_AA39}
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:isRplCellForPSCell=true
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-4:isRplCellForPSCell=true
...    NRCELL-3/NRREL-4:gNbId=1
...    NRCELL-3/NRREL-4:gNbIdLength=22
...    NRCELL-3/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-4:removeNotAllowed=false
...    NRCELL-3/NRREL-4:lcrId=4
...    NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-13:isRplCellForPSCell=true
...    NRCELL-3/NRREL-13:gNbId=1
...    NRCELL-3/NRREL-13:gNbIdLength=22
...    NRCELL-3/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-13:removeNotAllowed=false
...    NRCELL-3/NRREL-13:lcrId=13
...    NRCELL-3/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-13:sCellPrio=1
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-14:isRplCellForPSCell=true
...    NRCELL-3/NRREL-14:gNbId=1
...    NRCELL-3/NRREL-14:gNbIdLength=22
...    NRCELL-3/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-14:removeNotAllowed=false
...    NRCELL-3/NRREL-14:lcrId=14
...    NRCELL-3/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-14:sCellPrio=2
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms

@{CA_REL_AA47}
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:isRplCellForPSCell=true
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:isRplCellForPSCell=true
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-4/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-11:isRplCellForPSCell=true
...    NRCELL-4/NRREL-11:gNbId=1
...    NRCELL-4/NRREL-11:gNbIdLength=22
...    NRCELL-4/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-11:removeNotAllowed=false
...    NRCELL-4/NRREL-11:lcrId=11
...    NRCELL-4/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:isRplCellForPSCell=true
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4:a1MeasSCellAddEnabled=rsrp
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-4:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-4:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms

@{AA47_Online_nrrel_8311}
...    delete:NRCELL-3/NRREL-1
...    delete:NRCELL-3/NRREL-13
...    delete:NRCELL-3/NRREL-14
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-11:isRplCellForPSCell=true
...    NRCELL-3/NRREL-11:gNbId=1
...    NRCELL-3/NRREL-11:gNbIdLength=22
...    NRCELL-3/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-11:removeNotAllowed=false
...    NRCELL-3/NRREL-11:lcrId=11
...    NRCELL-3/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-11:sCellOperationalMode=dlOnly
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMeasBasedSCellAdditionNsa=true

@{AA47_online_blind}
...    NRCELL-3/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-4:sCellAdditionMethod=blind

@{AA47_online_A1}
...    NRCELL-3/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRBTS:actMfbiNrCaSupportFr1=true

@{AA47_recovery}
...    delete:NRCELL-3/NRREL-11
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:isRplCellForPSCell=true
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-13:isRplCellForPSCell=true
...    NRCELL-3/NRREL-13:gNbId=1
...    NRCELL-3/NRREL-13:gNbIdLength=22
...    NRCELL-3/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-13:removeNotAllowed=false
...    NRCELL-3/NRREL-13:lcrId=13
...    NRCELL-3/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-13:sCellPrio=1
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-14:isRplCellForPSCell=true
...    NRCELL-3/NRREL-14:gNbId=1
...    NRCELL-3/NRREL-14:gNbIdLength=22
...    NRCELL-3/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-14:removeNotAllowed=false
...    NRCELL-3/NRREL-14:lcrId=14
...    NRCELL-3/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-14:sCellPrio=2
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actSCellReleaseForInactiveSCell=disabled
...    NRBTS:actMfbiNrCaSupportFr1=false
...    NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRBTS:actMeasBasedSCellAdditionNsa=false

@{A1_TDD_threshold}
...    a1-Threshold rsrp : 90
...    QoS Routing Table

@{A1_FDD_threshold}
...    a1-Threshold rsrp : 70
...    QoS Routing Table

@{A1_FDD_threshold_AA39_2}
...    a1-Threshold rsrp : 70
...    rrcReconfigurationComplete

@{A1_FDD_threshold_AA39}
...    EventA1: Threshold: RSRP 70

${A1_TDD_threshold_AA47}
...    a1-Threshold rsrp : 90

@{N66_N77_N77_CA_succ}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:0
...    freqBandIndicatorNR 77

@{N77_N2_CA_succ}
...    rrcReconfigurationComplete
...    pcid:62, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 2
...    a1-Threshold rsrp : 90
...    SCellIndex 1 activated successfully

@{N77_N77_N41_N25_CA_succ}
...    rrcReconfigurationComplete
...    pcid:62, scellIdx:3
...    pcid:53, scellIdx:2
...    pcid:50, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 77
...    freqBandIndicatorNR 41
...    freqBandIndicatorNR 25
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    SCellIndex 3 activated successfully

@{Scell_swap_succ_cell13_cell14_AA39}
...    pcid:63, scellIdx:2
...    pcid:52, scellIdx:0
...    rrcReconfigurationComplete
...    SCellIndex 2 activated successfully

@{Scell_swap_succ_cell14_cell13_AA39}
...    pcid:62, scellIdx:1
...    pcid:52, scellIdx:0
...    rrcReconfigurationComplete
...    SCellIndex 1 activated successfully

@{Scell_swap_succ_cell13_cell14_AA39_4CC}
...    rrcReconfigurationComplete
...    pcid:63, scellIdx:4
...    pcid:52, scellIdx:0
...    SCellIndex 4 activated successfully

@{Scell_swap_succ_cell14_cell13_AA39_4CC}
...    rrcReconfigurationComplete
...    pcid:62, scellIdx:3
...    pcid:52, scellIdx:0
...    SCellIndex 3 activated successfully

@{NSA_PCELL3}
...    Successfully reconfigured dual connectivity
...    reported successful RA
...    pcid:52, scellIdx:8

@{NSA_CA_CELL3_CELL4}
...    pcid:52, scellIdx:8
...    pcid:53, scellIdx:9
...    freqBandIndicatorNR 41
...    SCellIndex 9 activated successfully at airphone.

${band77_scell3}
...    pcid:52, scellIdx:3

@{N25_N66_CA_succ_cell13}
...    rrcReconfigurationComplete
...    pcid:62, scellIdx:1
...    pcid:60, scellIdx:0
...    freqBandIndicatorNR 25
...    eventId eventA6

@{Scell_swap_succ_cell13_cell14}
...    pcid:63, scellIdx:2
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete

@{Scell_swap_succ_cell14_cell13}
...    pcid:62, scellIdx:1
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete

@{N66_N77_N77_N77_CA_succ}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:52, scellIdx:3
...    pcid:60, scellIdx:0
...    freqBandIndicatorNR 77

@{CA_check_cell1_cell11}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:0
...    pcid:60, scellIdx:1
...    freqBandIndicatorNR 66
...    a1-Threshold rsrp : 90

@{CA_check_cell1_cell11_cell4}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:0
...    pcid:53, scellIdx:1
...    pcid:60, scellIdx:2
...    freqBandIndicatorNR 66
...    freqBandIndicatorNR 41

@{CA_check_cell4_cell1_cell11}
...    rrcReconfigurationComplete
...    pcid:53, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:60, scellIdx:2
...    freqBandIndicatorNR 77
...    freqBandIndicatorNR 66

@{CA_check_cell3_cell4_cell11}
...    rrcReconfigurationComplete
...    pcid:52, scellIdx:0
...    pcid:53, scellIdx:1
...    pcid:60, scellIdx:2
...    freqBandIndicatorNR 41
...    freqBandIndicatorNR 66
...    SCellIndex 2 activated successfully
...    SCellIndex 1 activated successfully

${fail_cell4}
...    pcid:53

@{OnlineParam_enable_7219}
...    NRBTS:actMfbiNrCaSupportFr1=true

@{OnlineParam_disable_7219}
...    NRBTS:actMfbiNrCaSupportFr1=false

@{delete_alternative_band_cell3}
...    delete:NRCELL-3:nrConnectModeProfileDN
...    delete:NRCELL-3:nrMultibandInfoProfileDN

@{Lock_CELL3_And_Add_alternative_band_77_cell3}
...    NRCELL-3:administrativeState=Locked
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

@{Unlock_CELL3}
...    NRCELL-3:administrativeState=Unlocked

@{OnlineParam_recover_AA08}
...    NRBTS:actMfbiNrCaSupportFr1=false
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

@{AA39_8311}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRBTS:actMfbiNrCaSupportFr1=false

@{AA39_8311_recovery}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actSCellReleaseForInactiveSCell=disabled
...    NRBTS:actMfbiNrCaSupportFr1=false

${N66A_N77(3A)_and_N66A_N77(2A)_and_N66A_N78A_and_N25A_N66A}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E09804062380DDC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C
...    790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FFF80
...    0003FFE00000260001C0AA3626EB04610D04083A41202CB64C550D0E7C471E819F604F8C73E618F28581C0E1E05C00FFC007003FF0004C000381506C18D608C21A08
...    107CA090195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000004C0003815C6C25D608C21A08107482406D6C98AB1A1CF88E3D033E
...    C09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A8D899AC1184341020E90480B2D931543439F11C7A067D813E31CF9863CA160703878170
...    03FF001C00FFC00130000E0541B11B582308682041F28240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E008BC3C4
...    1000E230000000B0102F0F09400389A0000042C040BC5C28000E20800711800001058081787830001C41000006160205E1E14000713400002058081707850001C410
...    0000A160205E1E20800711800003058081787882001C4D00000E160205E2E1400071040038820000202C040BC5C28000E2300071180000485808178B882001C41000
...    E2300000A0B0102F1710400388C001C46000016160205E1E2300071340000605808178F830001C41000E2080071040000685808178F882001C4C000E260007130000
...    0705808178B882001C4C000E2600000F0B0102F1F104003882001C4D000E268000100B01020120234028809B010602607A06C84614489B1CF870A244D8E7C3891224
...    4D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C28913639F0E34489
...    1226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8600C888C6318C6318C6318C6318CF413003C00281C1401C0C02500700060240040603E04002000000
...    0100000200800002004000018020000100100000A0080000600400003802000020086065654D64C5646D60CD60C56065654D654D01C1000009652504000065949410
...    000296525040000E594941000049652504000165949410000696525040001E5949407503AAA555549AAA91E5506CAA0D5540F2A956509004800D0280040202004008
...    0801002101008010040100210080200402004008080100210100A0140403807080803006020080104040100201002004202010020080100210100200404010021008
...    020040200400808010022010040080400801010020044020040080801002020040088040080101002004040080108080100202008010C0C0300680500A0600400C00
...    801030020060040081808011004008602004008080800402020010080800420100E00404048030101200C60201C00808070020202401808090063543E00020406080
...    C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${N41A_N77(2A)_and_N2A_N77(2A)_and_N25(2A)_N77(2A)_and_N25A_N41A_N77(2A)}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47017B8D85181AC1184341020E9068036B64C558D0E7C471E819F604F8C48
...    E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FF
...    C00001FFF00000170000381506C01D608C21A08107CA0D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001700003815C6C25
...    D608C21A08107483401B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8002E0000702A8D899AC1184341020E906802CB64C5
...    50D0E7C471E819F604F8C73E618F28581C0E1E05C00FFC007003FF0005C0000E0541B06358260868204788340195B262AC4873EC09F11C78C48E3C873EA39F30C794
...    2C0E070F09FFF000007FFC000005C0000E007BC3C41000E230000000B0102F0F0A00038980000042C040BC5C28000E2080071180000105808178B802001C4C000E26
...    0000030B0102F0F0A00038500000102C040B83C28000E208000050B0102F0F10400388C0000182C040BC3C41000E140000070B0102F170A0003882001C4100001016
...    0205E2E14000711800388C0000242C040BC5C41000E2080071180000505808178B882001C46000E2300000B0B0102F0F1180038980000302C040BC7C18000E0C0007
...    1300038980000342C040BC7C18000E1400071300038980000382C040803808D00A2026C04117400BF07C28913639F0E14489B1CF871224489B1CF871224489B1CF87
...    0A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871224489B1CF871224489B1CF871224489B1CF870A244D8E7C38D1224489B1CF871A2448913
...    639F0C0170F18C6318C6318C6318C61E82E003C00281C1401C0C02500700060240040603E02002000000010000020080000200400001802000010046065654564C56
...    46D606D0101000009652504000065949410000296525040000E594941000049653501140EAA9555526AAA479540F285801200340A000E08080100202004008404010
...    020100400840200801008010020200400880402805010040080401002080803006020080104040100201002004202010020080100210100200404010021008020040
...    200400808010022010040080400801010020044020040080801002020040088040080101002004040080108080100202008010C04008010100200404010020100400
...    860200400808020040200801008020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47017B8D85181AC1184341020E9068036B64C558D0E7C471E819F604F8C48
...    E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FF
...    C00001FFF00000170000381506C01D608C21A08107CA0D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001700003815C6C25
...    D608C21A08107483401B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8002E0000702A8D899AC1184341020E906802CB64C5
...    50D0E7C471E819F604F8C73E618F28581C0E1E05C00FFC007003FF0005C0000E0541B06358260868204788340195B262AC4873EC09F11C78C48E3C873EA39F30C794
...    2C0E070F09FFF000007FFC000005C0000E007BC3C41000E230000000B0102F0F0A00038980000042C040BC5C28000E2080071180000105808178B802001C4C000E26
...    0000030B0102F0F0A00038500000102C040B83C28000E208000050B0102F0F10400388C0000182C040BC3C41000E140000070B0102F170A0003882001C4100001016
...    0205E2E14000711800388C0000242C040BC5C41000E2080071180000505808178B882001C46000E2300000B0B0102F0F1180038980000302C040BC7C18000E0C0007
...    1300038980000342C040BC7C41000E1400071300038980000382C040803808D00A2026C04117400BF07C28913639F0E14489B1CF871224489B1CF871224489B1CF87
...    0A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871224489B1CF871224489B1CF871224489B1CF870A244D8E7C38D1224489B1CF871A2448913
...    639F0C0170F18C6318C6318C6318C61E82E003C00281C1401C0C02500700060240040603E02002000000010000020080000200400001802000010046065654564C56
...    46D606D0101000009652504000065949410000296525040000E594941000049653501140EAA9555526AAA479540F285801200340A000E08080100202004008404010
...    020100400840200801008010020200400880402805010040080401002080803006020080104040100201002004202010020080100210100200404010021008020040
...    200400808010022010040080400801010020044020040080801002020040088040080101002004040080108080100202008010C04008010100200404010020100400
...    860200400808020040200801008020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${MRDC_N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}    SEPARATOR=
...    BD1FF81BC5C41082E2080030000000162305E3E140007104003898000C0000008588C1789800070A00038820000082C460805082012000C018809900A05D000B2071
...    22449DB1CF871A244893B639F0E24E8913639F0C02406318C019379A010804008010100200400020118080200402004008080200400010088000201010040080400801

#@{RD_Counters_AA08}
#...    NRCELL-3:SCELL_CONF_ALT_BAND_SA=2
#...    NRCELL-13:SCELL_CONF_ALT_BAND_SA=4
#...    NRCELL-14:SCELL_CONF_ALT_BAND_SA=2

@{PM_Counters_Check_AA08}
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-13:${SCELL_CONF_ALT_BAND_SA}=4
...    NRCELL-14:${SCELL_CONF_ALT_BAND_SA}=2

#@{RD_Counters_AA39}
#...    NRCELL-1:SCELL_CONF_ALT_BAND_SA=0
#...    NRCELL-4:SCELL_CONF_ALT_BAND_SA=1
#...    NRCELL-13:SCELL_CONF_ALT_BAND_SA=2
#...    NRCELL-14:SCELL_CONF_ALT_BAND_SA=1

@{PM_Counters_Check_AA39}
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-4:${SCELL_CONF_ALT_BAND_SA}=1
...    NRCELL-13:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-14:${SCELL_CONF_ALT_BAND_SA}=1
...    NRCELL-3:${SCELL_SWAP_1_ATT_SA}=4
...    NRCELL-3:${SCELL_SWAP_1_SUCC_SA}=4

@{PM_Counters_Check_AA47}
...    NRCELL-4:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-4:${SCELL_CONF_ALT_BAND_NSA}=1

#@{RD_Counters_AA47}
#...    NRCELL-4:SCELL_CONF_ALT_BAND_SA=2
#...    NRCELL-4:SCELL_CONF_ALT_BAND_NSA=1

${SCELL_CONF_ALT_BAND_SA}    M55118C01005
#This counter provides the number of current cell configurations as an SA SCell in an alternative band
${SCELL_CONF_ALT_BAND_NSA}    M55118C01006    #This counter provides the number of current cell configurations as an NSA
#SCell in an alternative band.
${SCELL_SWAP_1_ATT_SA}    M55118C10501
#This counter is updated on the PCell for a single SCell which is swapped during SCell Swap procedure due to A6 measurements.
#It is incremented when F1AP: DL RRC Message Transfer is sent from CU with encapsulated RRC Reconfiguration for SCell Swap procedure only.
${SCELL_SWAP_1_SUCC_SA}    M55118C10502
#This counter is updated on the PCell for a single SCell which is successfully swapped during SCell Swap procedure due to A6 measurements.
#It is incremented when F1AP: UL RRC Message Transfer is received by CU with encapsulated RRC Reconfiguration Complete for SCell Swap procedure only.


*** Test Cases ***
CB007219-ET-AA08_Verify online modification FAF and alternative bands for intra-gNB CA
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when the feature activation flag of CB007219 is modified online. 
    ...    The modified values will not make an impact on the UEs already connected to the gNB(till the next trigger for scell addition/change/swap)
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1=false
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 80 80 80 80
    ...    Small BWP
    ...    DL MIMO Layers 2L 2L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N66 N2 N2 N77 N77 N78 N38
    ...    Alternative band NA NA N25 N25 NA NA N77 N41
    ...    The frequency for cell13=cell14. SCell Priority for cell13 is 0, for cell14 is 1. A6 for scell swap is configred in cell13 and cell14.
    ...    NRBTS/NRCELL.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpTDD > NRBTS/NRCELL.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpFDD
    ...    in Cell 11.
    ...    CA relation: cell11+cell13+cell14+cell1+cell2+cell3, A1 scell addition
    ...    UE Capability:
    ...    BC#1: N66A_N77(3A)
    ...    BC#2: N66A_N77(2A)
    ...    BC#3: N66A_N78A
    ...    BC#4: N25A_N66A
    ...    3. Test Case Steps:
    ...    1). Attach UE81 to cell11, trigger A1 for scell additon(above FDD Threshold), Start DL/UL traffic.
    ...    2). Trigger A1 for scell additon(above TDD Threshold).
    ...    3). Online modify NRBTS/actMfbiNrCaSupportFr1 from false to true.
    ...    4). Attach UE82 to cell11. and trigger A1 for scell additon(above FDD threshold).    
    ...    5). Trigger A6 for scell swap from cell13 to cell14 and swap back.
    ...    6). Online modify NRBTS/actMfbiNrCaSupportFr1 from true to false.
    ...    7). Trigger A6 for scell swap from cell13 to cell14.
    ...    8). Online modify NRBTS/actMfbiNrCaSupportFr1 from false to true.
    ...    9). Trigger A6 for scell swap from cell13 to cell14 and swap back.
    ...    10). Release all scells for UE81 one by one with 7219 disable then enable 7219. 
    ...    11). Trigger A1 for scell additon(above FDD Threshold) for UE81.
    ...    12). Online delete alternative band for cell3. 
    ...    13). Attach UE83 to cell11, and trigger A1 for scell additon(above TDD Threshold). Start UL/DL traffic.
    ...    14). Lock cell3, online add alternative band n77 for cell3. then unlock cell3.
    ...    15). Attach UE84 to cell11, and trigger A1 for scell additon(above TDD Threshold). Start UL/DL traffic.
    ...    16). Release all scells for UE3 one by one.
    ...    17). Trigger A1 for scell additon(above TDD Threshold) for UE83.
    ...    18). check counters.
    ...    4. Expectation:
    ...    1). UE81 attach successfully, A1 is configured with TDD threshold. FDD scell should not be added.
    ...    2). BC#2 is selected, cell 1 and cell2 are added as scell. Traffic is OK.
    ...    3). Online modification is successful.
    ...    4). UE82 attach successfully, A1 is configured with FDD threshold. BC#4 is selected. cell13 is added as scell, A6 is configured.
    ...    5). Scell swap from cell13 to cell14 successfully and swap back successfully. Traffic is OK.
    ...    6). Online modification is successful.
    ...    7). Scell swap won't be triggered.
    ...    8). Online modification is successful.
    ...    9). Scell swap from cell13 to cell14 successfully and swap back successfully. Traffic is OK.
    ...    10). Scell release one by one successfully for UE81.
    ...    11). BC#4 is selected. cell13 is added as scell. Traffic is OK.
    ...    12). Alternative band n77 delete successfully for cell3.
    ...    13). UE83 attach successfully. BC#2 is selected, cell 1 and cell2 are added as scell. Traffic is OK.
    ...    14). Alternative band n77 add successfully for cell3.
    ...    15). UE84 attach successfully. BC#1 is selected, cell 1, cell2 and cell3 are added as scell. Traffic is OK.
    ...    16). Scell release one by one successfully for UE83.
    ...    17). BC#1 is selected, cell 1, cell2 and cell3 are added as scell for UE83. Traffic is OK.
    ...    18). SCELL_CONF_ALT_BAND_SA are updated for cell3, cell13 and cell14.
    [Tags]    QC_46755    jing.ye    AA08    CA_LABEL-FF(20MHZ_FDD_n66+20MHZ_FDD_n25)
    ...    CA_LABEL-FTT(20MHZ_FDD_n66+80MHZ_TDD_n77(2A))    CA_LABEL-FTTT(20MHZ_FDD_n66+80MHZ_TDD_n77(3A))
    Clear Counter Files    wait=${False}
    Only Native Band Can Be Scell When 7219 is disabled    ue_id=81
    Alternative Band Can Be Scell When 7219 is enabled
    Scell Swap Fail When 7219 is Disable
    Test With 7219 Enable
    Test With Alternative Band Is Delete For Cell3
    Test After Alternative Band Is Added For Cell3
    Release Ues    ue_type=all
    Check Counters    pm_counters_expression=${PM_Counters_Check_AA08}
    [Teardown]    AA08_Teardown

CB007219-ET-AA39_Verify online modification FAF and alternative bands for intra-gNB CA with PCell in alter band
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when the feature activation flag of CB007219 is modified online. 
    ...    The modified values will not make an impact on the UEs already connected to the gNB(till the next trigger for scell addition/change/swap)
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1=false
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 80 80 80 80
    ...    Small BWP
    ...    DL MIMO Layers 2L 2L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N66 N2 N2 N77 N77 N78 N38
    ...    Alternative band NA NA N25 N25 NA NA N77 N41
    ...    The frequency for cell13=cell14. SCell Priority for cell13 is 0, for cell14 is 1. A6 for scell swap is configred in cell13 and cell14.
    ...    NRBTS/NRCELL.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpTDD > NRBTS/NRCELL.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpFDD
    ...    in Cell 3.
    ...    CA relation: cell3+cell13+cell14+cell1+cell4, A1 scell addition
    ...    UE Capability:
    ...    BC#1 :n41A_n77(2A)
    ...    BC#2: n2A_n77(2A)
    ...    BC#3: n25(2A)_n77(2A)
    ...    BC#4: n25A_n41A_n77(2A)
    ...    3. Test Case Steps:
    ...    1). online enable 8311. Attach UE81 to cell3
    ...    2). release UE and online modify actMfbiNrCaSupportFr1 from false to true.
    ...    3). Attach UE81 to cell3
    ...    4). online modify actMfbiNrCaSupportFr1 from true to false. trigger A1(above FDD Threshold)
    ...    and Data buffer overflow condition is satisfied at gNB-DU-UP.
    ...    5). online modify actMfbiNrCaSupportFr1 from false to true. trigger A1(above FDD Threshold)
    ...    and Data buffer overflow condition is satisfied at gNB-DU-UP.
    ...    6). online modify actMfbiNrCaSupportFr1 from true to false. trigger scell swap.
    ...    7). online modify actMfbiNrCaSupportFr1 from false to true. trigger scell swap and swap back.
    ...    8). online modify actMfbiNrCaSupportFr1 from true to false. release scell13.
    ...    9). online modify actMfbiNrCaSupportFr1 from false to true. Attach UE81 to cell3 again.
    ...    10). trigger A1(above TDD Threshold), but Data buffer overflow condition is not satisfied at gNB-DU-UP.
    ...    11). online modify actMfbiNrCaSupportFr1 from true to false. increase traffic and Data buffer overflow condition is satisfied at gNB-DU.
    ...    12). trigger A1(above TDD Threshold), online modify actMfbiNrCaSupportFr1 from false to true.
    ...    increase traffic and Data buffer overflow condition is satisfied at gNB-DU. 
    ...    stop some traffic and trigger A1 again and Data buffer overflow condition is satisfied at gNB-DU.
    ...    13). trigger scell swap
    ...    14). online modify actMfbiNrCaSupportFr1 from true to false. trigger scell swap back.
    ...    15). online modify actMfbiNrCaSupportFr1 from false to true. trigger scell swap back.
    ...    16). release all TDD scells.
    ...    17). release all scells.
    ...    18). check counters.
    ...    4. Expectation:
    ...    1). UE81 attach successfully, And no A1 for scell addiiton is configued to UE as pcell is in alternative band.
    ...    2). UE81 is released successfully and online modification successfully.
    ...    3). UE81 attach to cell3 successfully with n77. and A1 for scell addition is configured to UE with FDD threshold.
    ...    4). no scell added as FAF false and pcell in alternative band.
    ...    5). cell13 is added as scell in n2 and BC2 is selcted. A6 for scell swap is configured in cell13 in n2.
    ...    A1 for scell change is configured with TDD threshold.
    ...    6). scell swap cancled as pcell in alternative band and actMfbiNrCaSupportFr1 false.
    ...    7). Scell swap successfully.
    ...    8). scell released and no A1 for scell addition configured.
    ...    9). UE81 attach to cell3 successfully with n77. and A1 for scell addition is configured to UE with FDD threshold.
    ...    10). no scell added as Data buffer overflow condition is not satisfied at gNB-DU-UP.
    ...    11). no scell added as pcell in alternative band and actMfbiNrCaSupportFr1 false.
    ...    12). no scell added at first.
    ...    add cell13 in n25, cell4 in n41, cell1 in n77 as scells when 2nd A1 triggered.
    ...    BC#4 is selected. A6 for scell swap is configured in cell13 in n25.
    ...    13). scell swap successfully.
    ...    14). scell swap cancled as pcell and scell are in alternative band actMfbiNrCaSupportFr1 false.
    ...    15). scell swap back successfully.
    ...    16). all TDD scells released succefully.
    ...    17). all scells released successfully and A1 for scell addition is configured with FDD threshold.
    ...    18). SCELL_CONF_ALT_BAND_SA are updated for cell1, cell4, cell13 and cell14.
    [Tags]    QC_46775    jiadan.wu    AA39    CA_LABEL-TF(80MHZ_TDD_n77+20MHZ_FDD_n2)
    ...    CA_LABEL-TTTF(80MHZ_TDD_n77+80MHZ_TDD_n77+20MHZ_TDD_n41_20MHZ_FDD_n25)
    UE attch and check no A1 configured    ue_id=81
    Online enable 7219 A1 configured then disable 7219 no scell add
    Online enable 7219 scell add
    Online disable 7219 swap fail then enable 7219 swap success
    Online disable 7219 no A1 configured after scell release
    Online enable 7219 reattache UE and scell addition
    Scell swap success then online disable 7219 swap failed then enbale 7219 swap back success
    Online disable 7219 release all TDD scells no A1 for scell change configured
    Online enbale 7219 release all scells A1 for scell addition configured
    Check Counters    pm_counters_expression=${PM_Counters_Check_AA39}
    [Teardown]    AA39_Teardown

CB007219-ET-AA47_online change for flag IWK with scell addition and change with pcell in alter band
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour when MFBI is enabled on a potential 
    ...    candidate SCells and A1 measurement report for SCell change is received for a UE.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1=false
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 80 80 80 80
    ...    Small BWP
    ...    DL MIMO Layers 2L 2L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N66 N2 N2 N77 N77 N78 N38
    ...    Alternative band NA NA N25 N25 NA NA N77 N41
    ...    UE1/2/3:
    ...    BC#1: N66(2A)
    ...    BC#2: N41A_N66A_N77A
    ...    BC#3: N41A_N66A
    ...    UE1: cell1+cell11+cell4, A1 scell addition.
    ...    UE2: cell4+cell11+cell1, A1 scell addition.
    ...    UE3: cell3+cell11+cell4, bufferbased A1 scell addition
    ...    UE4: NSA UE, cell3+cell11+cell4, bufferbased A1 scell addition
    ...    BC#1: DC_1A-N66(2A)
    ...    BC#2: DC_1A-N41A_N66A_N77A
    ...    BC#3: DC_1A-N41A_N66A
    ...    Test Case Steps:
    ...    UE1:
    ...    a. attach UE1 to cell 1 with 7219 enabled. A1 for scell addition is configured.
    ...    b. disable 7219, trigger A1. only cell11 is added as scell as UE only supports alter band for cell4. A1 for scell change configured.
    ...    c. trigger A1 for scell change. no scell change happen.
    ...    e. trigger A2 scell release for cell11. A1 for scell addition is configured.
    ...    f. enable 7219, trigger A1 for scell addition. cell11 and cell4 added as scell. no A1 for scell change is configured.
    ...    g. disable 7219, trigger scell release for cell4. no A1 for scell change is configured.
    ...    h. trigger scell release for cell11. A1 for scell addition is configured to UE.
    ...    UE2:
    ...    a. attach UE2 to cell4 with 7219 disabled. no A1 for scell addition is configured as pcell in alter band and 7219 disabled.
    ...    b. release UE2 and enable 7219.
    ...    c. attach UE2 to cell4. cell1 and cell11 are added as scell. no A1 for scell change configured.
    ...    d. disable 7219, release scell1. no A1 for scell change is configured as pcell in alter band and 7219 disabled.
    ...    f. release scell11. no A1 for scell addition is configured as pcell in alter band and 7219 disabled.
    ...    UE3:
    ...    a. attach UE3 to cell3 with 7219 enabled. A1 for scell addition is configured.
    ...    b. disable 7219, trigger traffic to meet data buffer overflow condition. then trigger A1. no scell added.
    ...    c. enable 7219. trigger A1 again. cell4 and cell11 are added as scell.
    ...    d. release UE3. and online modify scell addition method from A1 to blind.
    ...    f. attach UE3 to cell3 with 7219 enabled.
    ...    g. disable 7219, trigger traffic to meet data buffer overflow condition. no scell added.
    ...    UE4:
    ...    a. attach NSA UE4 to cell3 with 7219 enabled with blind scell addition.
    ...    b. disable 7219, trigger traffic to meet data buffer overflow condition. no scell added.
    ...    c. release UE4 and online modify scell addition method from blind to A1.
    ...    d. attach NSA UE4 to cell3. A1 for scell addition is configured.
    ...    e. disable 7219, trigger traffic to meet data buffer overflow condition. then trigger A1. no scell added.
    ...    f. enable 7219, trigger A1 again. cell4 is added as scell. no A1 for scell change configured.
    [Tags]    QC_46774    jiadan.wu    AA47    CA_LABEL-TF(80MHZ_TDD_n77+20MHZ_FDD_n66)    CA_LABEL-TFT(80MHZ_TDD_n77+20MHZ_FDD_n66+20MHz_TDD_N41)
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_enable_7219}
    UE1 A1 scell addition interaction with FAF online modification
    UE2 A1 scell addition interaction with FAF online modification
    UE3 bufferbased A1 scell addition interaction with FAF online modification
    UE4 bufferbased A1 scell addition interaction with FAF online modification
    Check Counters    pm_counters_expression=${PM_Counters_Check_AA47}
    [Teardown]    AA47_Teardown
    
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_2N66_3N78_N38    ue_count=15

AA08_Teardown
    OnlineParamChange    ${OnlineParam_recover_AA08}
    Common Test Teardown And Stop Capture Logs
    
AA39_Teardown
    OnlineParamChange    ${AA39_8311_recovery}
    Common Test Teardown And Stop Capture Logs

AA47_Teardown
    OnlineParamChange    ${AA47_recovery}
    Common Test Teardown And Stop Capture Logs
    
UE attch and check A1 configured
    [Arguments]    ${ue_id}=81    ${pass_check}=${EMPTY}
    Attach UE to Target Cell    ue_id=${ue_id}    cell_id=3
    ...    UE_capability=${N41A_N77(2A)_and_N2A_N77(2A)_and_N25(2A)_N77(2A)_and_N25A_N41A_N77(2A)}
    ${cmd}    catenate    ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}
    
UE attch and check no A1 configured
    [Arguments]    ${ue_id}=81
    Clear Counter Files    wait=${True}
    OnlineParamChange    ${AA39_8311}
    Attach UE to Target Cell and no A1    ue_id=${ue_id}    cell_id=3
    ...    UE_capability=${N41A_N77(2A)_and_N2A_N77(2A)_and_N25(2A)_N77(2A)_and_N25A_N41A_N77(2A)}
    Release Ues    ue_type=all
    
Online enable 7219 A1 configured then disable 7219 no scell add
    OnlineParamChange    ${OnlineParam_enable_7219}
    UE attch and check A1 configured    ue_id=81    pass_check=${A1_FDD_threshold_AA39}
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger MR scelladd    rsrp=80    ue_id=81    carrierfreq=640416    pass_check=measurementReport
    Send Throughput    ue_id=81    times=3
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    fail_regexp=SCellIndex 1 activated successfully
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=440    min_ul_tput=8
    Execute Egate Command    trf_data_stop ue=81 dir=dl pdu=1
    Execute Egate Command    trf_data_stop ue=81 dir=ul pdu=1

Online enable 7219 scell add
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger MR scelladd    rsrp=80    ue_id=81    carrierfreq=640416    pass_check=measurementReport
    Send Throughput    ue_id=81    times=3
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    pass_regexp=${N77_N2_CA_succ}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=440    min_ul_tput=8

Online disable 7219 swap fail then enable 7219 swap success
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger ScellSwap Fail    ue_id=81    scell_id=1    phycell_id=63    fail_check=rrcReconfigurationComplete
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger ScellSwap Success    ue_id=81    pass_check=${Scell_swap_succ_cell13_cell14_AA39}    phycell_id=63    scell_id=1
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After Scell Swap    ue_id=81    total_dl_tput=460    ul=8    scell_id=2
    Trigger ScellSwap Success    ue_id=81    pass_check=${Scell_swap_succ_cell14_cell13_AA39}    phycell_id=62    scell_id=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After Scell Swap    ue_id=81    total_dl_tput=460    ul=8    scell_id=1

Online disable 7219 no A1 configured after scell release
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger A2 ScellRelease and no A1 configured
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=440    min_ul_tput=8

Online enable 7219 reattache UE and scell addition
    OnlineParamChange    ${OnlineParam_enable_7219}
    Release Ues    ue_type=all
    UE attch and check A1 configured    ue_id=81    pass_check=${A1_FDD_threshold_AA39}
    Send Throughput    ue_id=81    times=3
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=240    min_ul_tput=8
    Trigger MR scelladd    rsrp=100    ue_id=81    carrierfreq=640416    pass_check=measurementReport
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=240    min_ul_tput=8
    Online disable 7219 and no scell addition

Online disable 7219 and no scell addition
    OnlineParamChange    ${OnlineParam_disable_7219}
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    fail_regexp=SCellIndex 1 activated successfully
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=440    min_ul_tput=8
    Execute Egate Command    trf_data_stop ue=81 dir=dl pdu=1 trf_id=4
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=320    min_ul_tput=8
    Online enable 7219 and scell addition 4CC

Online enable 7219 and scell addition 4CC
    Trigger MR scelladd    rsrp=100    ue_id=81    carrierfreq=640416    pass_check=measurementReport
    OnlineParamChange    ${OnlineParam_enable_7219}
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    fail_regexp=SCellIndex 1 activated successfully
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=440    min_ul_tput=8
    Execute Egate Command    trf_data_stop ue=81 dir=dl pdu=1 trf_id=4
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=320    min_ul_tput=8
    Trigger MR scelladd    rsrp=100    ue_id=81    carrierfreq=640416    pass_check=measurementReport
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    pass_regexp=${N77_N77_N41_N25_CA_succ}
    Send more traffic
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=4    min_dl_tput=880    min_ul_tput=8

Send more traffic
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=175 trf_id=5
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=175 trf_id=6
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=175 trf_id=7

Scell swap success then online disable 7219 swap failed then enbale 7219 swap back success
    Trigger ScellSwap Success    ue_id=81    pass_check=${Scell_swap_succ_cell13_cell14_AA39_4CC}    phycell_id=63    scell_id=3
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After 4CC Scell Swap    ue_id=81    total_dl_tput=880    ul=8    scell_id=4
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger ScellSwap Fail    ue_id=81    scell_id=4    phycell_id=62    fail_check=rrcReconfigurationComplete
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger ScellSwap Success    ue_id=81    pass_check=${Scell_swap_succ_cell14_cell13_AA39_4CC}    phycell_id=62    scell_id=4
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After 4CC Scell Swap    ue_id=81    total_dl_tput=880    ul=8    scell_id=3

Online disable 7219 release all TDD scells no A1 for scell change configured
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger A2 ScellRelease    carrierfreq=632736    ue_id=81    scell_id=1
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After Scell1 release    ue_id=81    total_dl_tput=690    ul=8
    Trigger A2 ScellRelease    carrierfreq=519870    ue_id=81    scell_id=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After Scell2 release    ue_id=81    total_dl_tput=690    ul=8

Online enbale 7219 release all scells A1 for scell addition configured
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger A2 ScellRelease    carrierfreq=388830    ue_id=81    scell_id=3    pass_check=${A1_FDD_threshold_AA39_2}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=440    min_ul_tput=8
    Release Ues    ue_type=all
    
Only Native Band Can Be Scell When 7219 is disabled
    [Arguments]    ${ue_id}=81
    Attach UE to Target Cell    ue_id=${ue_id}    cell_id=11    pass_check=${A1_TDD_threshold}
    Trigger MR scelladd Only With Error Check    rsrp=80    ue_id=${ue_id}    carrierfreq=424090    fail_check=rrcReconfigurationComplete
    Send Throughput    ue_id=${ue_id}
    Trigger MR scelladd With Error Check    rsrp=100    ue_id=${ue_id}    carrierfreq=424090    pass_check=${N66_N77_N77_CA_succ}
    ...    fail_check=${band77_scell3}    
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=3    min_dl_tput=480    min_ul_tput=8

Alternative Band Can Be Scell When 7219 is enabled
    OnlineParamChange    ${OnlineParam_enable_7219}
    UE Attach and Scell Swap    ue_id=82
    
UE Attach and Scell Swap
    [Arguments]    ${ue_id}=82
    Attach UE to Target Cell    ue_id=${ue_id}    cell_id=11    pass_check=${A1_FDD_threshold}
    Trigger MR scelladd    rsrp=80    ue_id=${ue_id}    carrierfreq=424090    pass_check=${N25_N66_CA_succ_cell13}
    Send Throughput    ue_id=${ue_id}    times=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=2    min_dl_tput=120    min_ul_tput=8
    Scell Swap and Back    ue_id=82

Scell Swap Fail When 7219 is Disable
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger ScellSwap Fail    scell_id=1    phycell_id=63    fail_check=rrcReconfigurationComplete
    
Test With 7219 Enable
    OnlineParamChange    ${OnlineParam_enable_7219}
    Scell Swap and Back    ue_id=82
    OnlineParamChange    ${OnlineParam_disable_7219}
    Scell release one by one For UE81
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger MR scelladd    rsrp=80    ue_id=81    carrierfreq=424090    pass_check=${N25_N66_CA_succ_cell13}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=120    min_ul_tput=8

Scell Swap and Back
    [Arguments]    ${ue_id}=82
    Trigger ScellSwap Success    pass_check=${Scell_swap_succ_cell13_cell14}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After Scell Swap    ue_id=${ue_id}    scell_id=2
    Trigger ScellSwap Success    pass_check=${Scell_swap_succ_cell14_cell13}    phycell_id=62    scell_id=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=2    min_dl_tput=120    min_ul_tput=8

Test With Alternative Band Is Delete For Cell3    
    OnlineParamChange    ${delete_alternative_band_cell3}
    UE83 Attach and Scell Added
    
UE83 Attach and Scell Added
    [Arguments]    ${ue_id}=83
    Attach UE to Target Cell    ue_id=${ue_id}    cell_id=11    pass_check=${A1_FDD_threshold}
    Send Throughput    ue_id=${ue_id}
    Trigger MR scelladd With Error Check    rsrp=100    ue_id=${ue_id}    carrierfreq=424090    pass_check=${N66_N77_N77_CA_succ}
    ...    fail_check=${band77_scell3}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=3    min_dl_tput=480    min_ul_tput=8
    
Test After Alternative Band Is Added For Cell3
    OnlineParamChange Without OnAir Check    ${Lock_CELL3_And_Add_alternative_band_77_cell3}
    OnlineParamChange    ${Unlock_CELL3}
    UE84 Attach and Scell Added
    Scell release one by one For UE83
    Trigger MR scelladd    rsrp=100    ue_id=83    carrierfreq=424090    pass_check=${N66_N77_N77_N77_CA_succ}    
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=83    cell_num=4    min_dl_tput=480    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=100    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=82    cell_num=2    min_dl_tput=100    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=84    cell_num=4    min_dl_tput=450    min_ul_tput=8
    
UE84 Attach and Scell Added
    [Arguments]    ${ue_id}=84
    Attach UE to Target Cell    ue_id=${ue_id}    cell_id=11    pass_check=${A1_FDD_threshold}
    Send Throughput    ue_id=${ue_id}
    Trigger MR scelladd    rsrp=100    ue_id=${ue_id}    carrierfreq=424090    pass_check=${N66_N77_N77_N77_CA_succ}    
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=4    min_dl_tput=480    min_ul_tput=8
    
Trigger ScellSwap Success
    [Arguments]    ${event_type}=A6    ${carrierfreq}=388830    ${nrsrp_nr}=63    ${nrsrq_nr}=20    ${ue_id}=82    ${scell_id}=1
    ...    ${phycell_id}=63    ${pass_check}=${EMPTY}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}

Trigger ScellSwap Fail
    [Arguments]    ${event_type}=A6    ${carrierfreq}=388830    ${nrsrp_nr}=63    ${nrsrq_nr}=20    ${ue_id}=82    ${scell_id}=1
    ...    ${phycell_id}=63    ${fail_check}=${EMPTY}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=${fail_check}

Attach UE to Target Cell
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${UE_capability}=${N66A_N77(3A)_and_N66A_N77(2A)_and_N66A_N78A_and_N25A_N66A}
    ...    ${pass_check}=QoS Routing Table
    Update UE capa    SA_Capa_perUE_Full=${UE_capability}    ue_id=${ue_id}
    Ue register and pdu session setup    pass_check=${pass_check}    ue_id=${ue_id}    cell_id=${cell_id}

Attach UE to Target Cell and no A1 
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${UE_capability}=${N66A_N77(3A)_and_N66A_N77(2A)_and_N66A_N78A_and_N25A_N66A}
    ...    ${pass_check}=QoS Routing Table
    Update UE capa    SA_Capa_perUE_Full=${UE_capability}    ue_id=${ue_id}
    ${ret}    Ue register and pdu session setup    pass_check=${pass_check}    ue_id=${ue_id}    cell_id=${cell_id}
    should not contain    ${ret}    a1-Threshold
    
Ue register and pdu session setup
    [Arguments]    ${pass_check}    ${ue_id}=1    ${cell_id}=2
    [Return]    ${ret}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_check}

Trigger MR scelladd
    [Arguments]    ${rsrp}=80    ${pass_check}=${EMPTY}    ${fail_check}=${EMPTY}    ${ue_id}=81    ${carrierfreq}=424090
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=52
    ...    pass_regexp=${pass_check}
    
Trigger MR scelladd With Error Check
    [Arguments]    ${rsrp}=80    ${pass_check}=${EMPTY}    ${fail_check}=${EMPTY}    ${ue_id}=81    ${carrierfreq}=424090
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=52
    ...    pass_regexp=${pass_check}
    Should Not Contain    ${ret}    ${fail_check}

Trigger MR scelladd With Fail Regexp Check
    [Arguments]    ${rsrp}=80    ${pass_check}=${EMPTY}    ${fail_check}=${EMPTY}    ${ue_id}=81    ${carrierfreq}=424090
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=52
    ...    pass_regexp=${pass_check}    fail_regexp=${fail_check}
    
Trigger MR scelladd Only With Error Check
    [Arguments]    ${rsrp}=80    ${pass_check}=${EMPTY}    ${fail_check}=${EMPTY}    ${ue_id}=81    ${carrierfreq}=424090
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=52
    ...    fail_regexp=${fail_check}
    
Scell release one by one For UE81
    [Arguments]
    Scell2 release    ue_id=81
    Scell1 release    ue_id=81

Scell release one by one For UE83
    [Arguments]
    Scell2 release    ue_id=83
    Scell1 release    ue_id=83    min_dl_tput=20
    
Scell2 release
    [Arguments]    ${ue_id}=81    ${min_dl_tput}=250
    Trigger A2 ScellRelease    carrierfreq=648096    ue_id=${ue_id}    scell_id=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=2    min_dl_tput=${min_dl_tput}

Scell1 release
    [Arguments]    ${ue_id}=81    ${min_dl_tput}=80
    Trigger A2 ScellRelease    carrierfreq=632736    ue_id=${ue_id}    scell_id=1
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=1    min_dl_tput=${min_dl_tput}

    
Check Traffic
    [Arguments]     ${ue_id}=81    ${cell_num}=1    ${min_dl_tput}=20    ${min_ul_tput}=8
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Trigger A2 ScellRelease
    [Arguments]    ${carrierfreq}=508110    ${ue_id}=81    ${scell_id}=3    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=${pass_check}

Trigger A2 ScellRelease and no A1 configured
    [Arguments]    ${carrierfreq}=388830    ${ue_id}=81    ${scell_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=rrcReconfigurationComplete
    should not contain    ${ret}    A1

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
    
OnlineParamChange Without OnAir Check
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    
Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=5
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=${I}    UE ${ue_id}: UDP DL
    END

Check Traffic After Scell Swap
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=135    ${ul}=8    ${scell_id}=1
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 0
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell0_tput}+${scell1_tput}
    Should Be True     ${total_dl}/1000 > ${total_dl_tput}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Check Traffic After 4CC Scell Swap
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=135    ${ul}=8    ${scell_id}=4
    Check DL traffic    ue_id=${ue_id}    total_dl_tput=${total_dl_tput}    scell_id=${scell_id}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Check DL traffic
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=135    ${scell_id}=4
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 0
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell0_tput}+${scell1_tput}+${scell2_tput}+${scell3_tput}
    Should Be True     ${total_dl}/1000 > ${total_dl_tput}

Check Traffic After Scell1 release
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=135    ${ul}=8
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell0_tput}+${scell2_tput}+${scell3_tput}
    Should Be True     ${total_dl}/1000 > ${total_dl_tput}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Check Traffic After Scell2 release
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=135    ${ul}=8
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 0
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell0_tput}+${scell3_tput}
    Should Be True     ${total_dl}/1000 > ${total_dl_tput}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE1 A1 scell addition interaction with FAF online modification
    UE1 A1 scell addition with FAF disabled
    UE1 A1 scell addition with FAF enabled

UE1 A1 scell addition with FAF disabled
    Attach UE to Target Cell    ue_id=81    cell_id=1    UE_capability=${N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}
    Send Throughput    ue_id=81    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=450    min_ul_tput=8
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger MR scelladd With Error Check    ue_id=81    carrierfreq=632736    rsrp=100    pass_check=${CA_check_cell1_cell11}
    ...    fail_check=${fail_cell4}
    Trigger MR scelladd With Fail Regexp Check    ue_id=81    carrierfreq=632736    rsrp=100    pass_check=measurementReport
    ...    fail_check=rrcReconfigurationComplete
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=450    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=424090    ue_id=81    scell_id=1    pass_check=${A1_FDD_threshold_AA39_2}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=450    min_ul_tput=8

UE1 A1 scell addition with FAF enabled
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger MR scelladd With Error Check    ue_id=81    carrierfreq=632736    rsrp=100    pass_check=${CA_check_cell1_cell11_cell4}
    ...    fail_check=${A1_TDD_threshold_AA47}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=450    min_ul_tput=8
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger A2 ScellRelease and no A1 configured    carrierfreq=519870    ue_id=81    scell_id=1
    Trigger A2 ScellRelease    carrierfreq=424090    ue_id=81    scell_id=2    pass_check=${A1_FDD_threshold_AA39_2}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=450    min_ul_tput=8
    Release Ues    ue_type=all

UE2 A1 scell addition interaction with FAF online modification
    UE2 attch with FAF disabled
    UE2 attch with FAF enabled

UE2 attch with FAF disabled
    Attach UE to Target Cell and no A1    ue_id=81    cell_id=4    UE_capability=${N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}
    Send Throughput    ue_id=81    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=100    min_ul_tput=8
    Release Ues    ue_type=all
    OnlineParamChange    ${OnlineParam_enable_7219}

UE2 attch with FAF enabled
    Attach UE to Target Cell    ue_id=81    cell_id=4    UE_capability=${N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}
    Send Throughput    ue_id=81    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=100    min_ul_tput=8
    Trigger MR scelladd With Error Check    ue_id=81    carrierfreq=519870    rsrp=100    pass_check=${CA_check_cell4_cell1_cell11}
    ...    fail_check=${A1_TDD_threshold_AA47}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=450    min_ul_tput=8
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger A2 ScellRelease and no A1 configured    carrierfreq=632736    ue_id=81    scell_id=1
    Trigger A2 ScellRelease and no A1 configured    carrierfreq=424090    ue_id=81    scell_id=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=100    min_ul_tput=8
    Release Ues    ue_type=all

UE3 bufferbased A1 scell addition interaction with FAF online modification
    UE3 bufferbased A1 scell addition with FAF disabled
    UE3 bufferbased A1 scell addition with FAF enabled
    UE3 bufferbased blind scell addition with FAF disabled

UE3 bufferbased A1 scell addition with FAF disabled
    OnlineParamChange    ${AA47_Online_nrrel_8311}
    Attach UE to Target Cell    ue_id=81    cell_id=3    UE_capability=${N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}
    OnlineParamChange    ${OnlineParam_disable_7219}
    Send Throughput    ue_id=81    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=450    min_ul_tput=8
    Trigger MR scelladd With Fail Regexp Check    ue_id=81    carrierfreq=640416    rsrp=100    pass_check=measurementReport
    ...    fail_check=rrcReconfigurationComplete

UE3 bufferbased A1 scell addition with FAF enabled
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger MR scelladd With Error Check    ue_id=81    carrierfreq=640416    rsrp=100    pass_check=${CA_check_cell3_cell4_cell11}
    ...    fail_check=${A1_TDD_threshold_AA47}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=600    min_ul_tput=8
    Release Ues    ue_type=all

UE3 bufferbased blind scell addition with FAF disabled
    OnlineParamChange    ${AA47_online_blind}
    Attach UE to Target Cell    ue_id=81    cell_id=3    UE_capability=${N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}
    OnlineParamChange    ${OnlineParam_disable_7219}
    Send Throughput    ue_id=81    times=3
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    fail_regexp=SCellIndex 1 activated successfully
    Release Ues    ue_type=all

UE4 bufferbased A1 scell addition interaction with FAF online modification
    UE4 bufferbased blind scell addition with FAF disabled
    UE4 bufferbased A1 scell addition with FAF disabled

UE4 bufferbased blind scell addition with FAF disabled
    OnlineParamChange    ${OnlineParam_enable_7219}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=16    cell=1    target_cells=3    SA_Capa_perUE_Full=${N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}    bc_list_mrdc=1:1|2:1|3:1
    ...    ue_mrdc_cap=${MRDC_N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}    meas_config=${NSA_PCELL3}    fail_check=sCellToAddModList
    OnlineParamChange    ${OnlineParam_disable_7219}
    Send Throughput for NSA UE    ue_id=16    times=3
    Execute Egate Command    trf_data_start ue=16 id=2 dir=dl mbps=100 trf_id=3
    Execute Egate Command    trf_data_start ue=16 id=2 dir=dl mbps=175 trf_id=4    fail_regexp=SCellIndex 9 activated
    Release Ues    ue_type=all

UE4 bufferbased A1 scell addition with FAF disabled
    OnlineParamChange    ${AA47_online_A1}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=16    cell=1    target_cells=3    SA_Capa_perUE_Full=${N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}    bc_list_mrdc=1:1|2:1|3:1
    ...    ue_mrdc_cap=${MRDC_N66(2A)_and_N41A_N66A_N77A_and_N41A_N66A}    meas_config=${NSA_PCELL3}
    OnlineParamChange    ${OnlineParam_disable_7219}
    Send Throughput for NSA UE    ue_id=16    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=16    cell_num=1    min_dl_tput=450    min_ul_tput=8
    Add Scell By A1    ue_id=16    carrierfreq=640416    pass_CA=NRUeReport    fail_CA=rrcReconfigurationComplete
    OnlineParamChange    ${OnlineParam_enable_7219}
    Add Scell By A1    ue_id=16    carrierfreq=640416    pass_CA=${NSA_CA_CELL3_CELL4}    fail_CA=${A1_TDD_threshold_AA47}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=16    cell_num=2    min_dl_tput=450    min_ul_tput=8



NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=16    ${cell}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    ...    ${bc_list_mrdc}=1:1|2:1|3:1    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${meas_config}=none    ${fail_check}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell}
    Update NSA UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${meas_config}    timeout=20s
    should not contain    ${ret1}    ${fail_check}

Update NSA UE capa
    [Arguments]    ${ue_id}=16    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_mrdc_cap}
    Execute Egate Command    ${cmd}

Add Scell By A1
    [Arguments]    ${ue_id}=16    ${carrierfreq}=638976    ${srsrp_nr}=100    ${srsrq_nr}=100    ${pass_CA}=none    ${fail_CA}=none
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...    pass_regexp=${pass_CA}    fail_regexp=${fail_CA}

Send Throughput for NSA UE
    [Arguments]    ${ue_id}=11    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Check Traffic for NSA UE
    [Arguments]     ${ue_id}=11    ${cell_num}=2    ${min_dl_tput}=420    ${min_ul_tput}=8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    8    ${cell_num}+8
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 20
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

