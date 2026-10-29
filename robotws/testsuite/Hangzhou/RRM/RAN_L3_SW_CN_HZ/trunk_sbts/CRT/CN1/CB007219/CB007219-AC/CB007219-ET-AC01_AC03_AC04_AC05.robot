*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-christine.chen
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{CB010378}
...    @{1416}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{CA_REL}
...    @{BWP_Para}

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRCELL-2:nrarfcn=642052
...    NRCELL-2:gscnOrSsPbchArfcn=7927
...    NRCELL-2:type0CoresetConfigurationIndex=0
...    NRCELL-3:nrarfcn=646676
...    NRCELL-3:gscnOrSsPbchArfcn=7985
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:chBw=40MHz
...    NRCELL-3:chBw=100MHz
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-2:freqBandIndicatorNR=78
...    NRCELL-3:freqBandIndicatorNR=77
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS:actBcsCheck=disabled

@{CB010378}
...    NRBTS:actExt2N77Support=true

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRSYSINFO_PROFILE-3/NRIAFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=41
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=78

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41

...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=2

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
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:antPortId=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:cIBAdvance=0
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:dcVoltage=OFF
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:hdlcCommunicationAllowed=false
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:ulDelay=0

...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:antPortId=4
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:cIBAdvance=0
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:dcVoltage=OFF
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:hdlcCommunicationAllowed=false
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:ulDelay=0

...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:antPortId=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:cIBAdvance=0
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:dcVoltage=OFF
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:hdlcCommunicationAllowed=false
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:ulDelay=0

...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:antPortId=4
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:cIBAdvance=0
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:dcVoltage=OFF
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:hdlcCommunicationAllowed=false
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:ulDelay=0

...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:nrCellType=4DL4UL
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=4DL4UL
...    NRCELL-11:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-11:nrCellType=4DL4UL
...    NRCELL-12:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:nrCellType=4DL4UL
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

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:resourceDN

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
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
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
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
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
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly

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

...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:isRplCellForPSCell=true
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly

...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:isRplCellForPSCell=true
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:isRplCellForPSCell=true
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{BWP_Para}
#CB008541:
...    NRCELL-11:actEnhMultipleDedicatedBWPs=true

#BWP #CB007552:
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-7:bwpType=dedicated
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n217
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
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
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
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
...    NRCELL-1:msg1FrequencyStart=20
...    NRCELL-2:msg1FrequencyStart=20
...    NRCELL-3:msg1FrequencyStart=25

#TDD, small bwp 20M, for AC04
...    NRBTS/BWP_PROFILE-8:bwpType=dedicated
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-8/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=17|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=18|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDSCH-1:pdschRat0RbgConfig=config1

@{online_delete_NRREL1_for_CELL11}
...    delete:NRCELL-11/NRREL-1
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-3:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7

@{online_add_NRREL1_for_CELL11}
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
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    delete:NRCELL-3:nrConnectModeProfileDN

@{online_modify_for_AC04}
...    NRBTS:actBcsCheck=enabled_FR1
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    delete:NRCELL-3/NRREL-1
...    NRCELL-2:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-2:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-3:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7

@{online_recover_for_AC04}
...    NRBTS:actBcsCheck=disabled
...    NRCELL-3:nrConnectModeProfileDN=${EMPTY}
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:isRplCellForPSCell=true
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4

@{online_NRREL_for_AC05}
...    delete:NRCELL-2/NRREL-1
...    delete:NRCELL-3/NRREL-1
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRBTS:actMeasBasedSCellAdditionNsa=true

@{online_recovery_for_AC05}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:isRplCellForPSCell=true
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
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
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRBTS:actMeasBasedSCellAdditionNsa=false

${disable_actBcsCheck}
...    NRBTS:actBcsCheck=disabled

@{CA_succ_for_UE1}
...    rrcReconfigurationComplete
...    pcid:52, scellIdx:2
...    pcid:51, scellIdx:1
...    pcid:60, scellIdx:0

@{CA_succ_for_UE2}
...    rrcReconfigurationComplete
...    pcid:51, scellIdx:2
...    pcid:50, scellIdx:1
...    pcid:60, scellIdx:0

@{CA_succ_for_UE3}
...    rrcReconfigurationComplete
...    pcid:52, scellIdx:2
...    pcid:50, scellIdx:1
...    pcid:60, scellIdx:0

@{CA_succ_for_UE4}
...    rrcReconfigurationComplete
...    pcid:51, scellIdx:2
...    pcid:50, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 77

@{CA_succ_for_UE5}
...    rrcReconfigurationComplete
...    pcid:52, scellIdx:2
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:0
...    freqBandIndicatorNR 77

@{UE_register_and_A1_configured}
...    QoS Routing Table
...    eventA1

@{CA_succ_N77_N78_20M}
...    rrcReconfigurationComplete
...    pcid:52, scellIdx:0
...    pcid:51, scellIdx:1
...    locationAndBandwidth 13750

@{CA_succ_N77C_40M}
...    rrcReconfigurationComplete
...    pcid:52, scellIdx:0
...    pcid:51, scellIdx:1
...    locationAndBandwidth 28875

@{CA_CELL3_CELL2}
...    pcid:52, scellIdx:8
...    pcid:51, scellIdx:9
...    reported successful RA
...    SNStatusTransfer

@{N77_PCell}
...    freqBandIndicatorNR 77
...    pcid:51, scellIdx:8
...    reported successful RA

@{N78_PCell}
...    freqBandIndicatorNR 78
...    pcid:51, scellIdx:8
...    reported successful RA

@{CA_CELL2_CELL3}
...    freqBandIndicatorNR 77
...    pcid:51, scellIdx:8
...    pcid:52, scellIdx:9
...    Sending SgNB Modification Confirm

${N66_N77_N77_N77_and_N66_N78_N78_and_N66_N77C_Support_ext77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D801AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070015E1E0000071300000005808178B800001C4C000E260000010B0102F1F104003898001C4C000E26000002
...    0B0102F1710400389A001C4D000006160205E1E208007130208020580810070002001404C809A2E8048605851226C73E1C4891226C73E1C6
...    8912244D8E7C38912244D8E7C3851226C73E18160A318C6300040BD05C0078005038280381804A00E000C0480080C07C0800400000002000
...    0040100000400800003004000020020000140100000C008000070040020180E03B032B036B262B266B066B062B036B2A68100800004B2928
...    2000032CA4A0800014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A08020180F2CA4A03A81D5503CAA4D554
...    9B2A8365506AAA07954AB285801200340A00040808020040201002080C010028010020600C01C020040300600E00C018C040080101010020
...    04018030100600C40200801008040080201002040401002010120246A87C0004080C10181C282C30344044484C5060646C70747C8494989C
...    A0A4A8B4BD05060B40

${N66_N77_N77_N77_and_N66_N78_N78_and_N66_N77C_notSupport_ext77}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807506C41D608C21A0810788240656C98AB121CF
...    B027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E0541B003582308682041F28240656C98AB121CF88E3D813E3
...    1238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E0551B133582308682041D2090165B262A86873E238F40CFB027C639F30C
...    7942C0E070F02E007FE003801FF800260001C0AA3626EB04610D04083A41202CB64C550D0E7C471E819F604F8C73E618F28581C0E1E05C00
...    FFC007003FF0004C0003800AF0F0000038980000002C040BC5C00000E2600071300000085808178F882001C4C000E2600071300000105808
...    178B882001C4D000E268000030B0102F0F1040038981040102C0408038001000A026404D0F404302C28913639F0E2448913639F0E3448912
...    26C73E1C4891226C73E1C28913639F0C0B0518C63181E8260078005038280381804A00E000C0480080C07C08004000000020000040100000
...    400800003004000020020000140100000C008000070040020180E03B032B036B262B266B066B062B036B2A68100800004B29282000032CA4
...    A0800014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A08020180F2CA4A03A81D5503CAA4D5549B2A836550
...    6AAA07954AB2848024006814000810100400804020041018020050020040C018038040080600C01C01803180801002020200400803006020
...    0C0188040100201008010040200408080200402024048D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A
...    0A0C1680

${N66_N77_N77_N77_and_N66_N78_N78_Support_ext77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D883AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A836006B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070011E1E0000071300000005808178B800001C4C000E260000010B0102F1F104003898001C4C000E26000002
...    0B0102F1710400389A001C4D00000616020401C000800501320268BA011C81214489B1CF871224489B1CF871A2448913639F0E2448913639
...    F0C004820C63180102F417001E00140E0A00E0601280380030120020301F02001000000008000010040000100200000C0100000800800005
...    0040000300200001C010008060380EC0CAC0DAC98AC99AC19AC18AC0DACA9A0402000012CA4A080000CB29282000052CA4A080001CB29282
...    000092CA4A080002CB292820000D2CA4A080003CB292820080603CB29280EA075540F2A9355526CAA0D9541AAA81E552ACA16004800D0280
...    010202008010080400820300400A00400818030070080100C0180380300630100200404040080100600C0401803100802004020100200804
...    00810100400804048091AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${n77A_78A_and_n77(3A)_and_n77D_and_n77A_n77C_Support_ext77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D801AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070011E1E2600061340000160205E2E2600071300038980000042C040BC1C4C0C3004160205E1E26000713020
...    8020580810070002001404C809A2E8046204851226C73E1C4891226C73E1C089B1CF870A244D8E7C301208318C60040BD05C007800503828
...    0381804A00E000C0480080C07C09004000000020000040100000400800003004000020020000140100000C008000070040020380E0080080
...    701C0701D819581B5931593358335831581B595340904000025949410000196525040000A594941000039652504000125949410000596525
...    040001A5949410000796525040101C0796525040201C0701E5949407503AAA079549AAA9365506CAA0D5540F2A95650B0024006814000810
...    1010020040400010080801002020040080801000101402840200801008040080201002040404008010120246A87C0004080C10181C282C30
...    344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${n66A_78A_and_n66A_77A_and_n66A_n77(2A)_and_n66A_n77C_and_n66A_n78C_Support_ext77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D801AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070015E1E20800713400000058081787882001C4C000002160205E2E2080071300038980000082C040BC3C410
...    00E260410030B0102F0F10400389A1040102C0408038001000A026404D174023F02C28913639F0E14489B1CF871224489B1CF870A244D8E7
...    C3851226C73E1800B0518C631800205E82E003C00281C1401C0C02500700060240040603E048020000000100000200800002004000018020
...    000100100000A008000060040000380200101C030040020200603B032B036B262B266B296B062B036B2A68120800004B29282000032CA4A0
...    800014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A0802038072CA4A0802020072CA4A03A81D5503CAA4D5
...    549B2A94E5506AAA07954AB285801200340A000408080200402010020404010020100A014402008010080500A02010020404010020101402
...    820200801008090123543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${n77A_78A_and_n77C_Support_ext77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C00B78789800184D000005808178B850001C41000E230000020B0102F0F10400389A00000C2C040B83C28000E208000050B0102F0
...    F10400388C0000182C040BC1C4C08200E160205E2E1400071040038820000202C040BC5C28000E2300071180000485808178B882001C4100
...    0E2300000A0B0102F1710400388C001C46000016160205E3E208007104003882001C4100001A16020402404680510136020C04C174028B05
...    C28913639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C089B1CF871224489B1CF871224489B1CF871224489B1CF8712244
...    89B1CF871A2448913639F0C0110B18C6318C6318C60205E82E003C00281C1401C0C02500700060240040603E040020010000100400000802
...    0000080100000600800004004000028020000180100000E008000080219535933591B5953583358315819595359534070401000019652504
...    000065949410000296525040000E594941000049652504000165949410000696525040001E594940752ACAA4D9549AAA9565506CAA0D5540
...    F2A95650B002400681400201010080100401800080804008020080108040100201002004040080108080400802010020404008010100600C
...    2020080100801002101008010040080100080100220100400804008010100200440200801008010020200400880400801010020040400801
...    100801002020040080801002101002004040100218180600D00A0140C008018010020600400C0080103010022008010C0400801010100080
...    4040020101000840201002008040080200C018C04038010100E00404048030101200C6A87C0004080C10181C282C30344044484C5060646C
...    70747C8494989CA0A4A8B4BD05060B40

${Capa_MRDC_5A_66A_n77A_n77A_and_5A_66A_n77C}    SEPARATOR=
...    BD1FF813C5C4C08268200C1000000588C178F898001C4C00068200C1000008588C100A104024001803101320268BA001040A2449D3B639F0
...    E344893A76C73E18003808630326F3401100804008000100800040230100600C04040080000804000201

${Capa_MRDC_5A_66A_n77A_n78A_and_5A_66A_n77C}    SEPARATOR=
...    BD1FF813C5C4C08268200C1000000588C178F89A001C4C00068200C1000008588C100A104024001803101320268BA001040A2449D3B639F0
...    E344893A76C73E18003808630326F3401100804008000100800040230100600C04040080000804000201

${Capa_NR_AC05}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700AA0D803AC1184341020F941A00CAD93156243
...    9F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE000002E0000702A8D899AC1184341020E906802CB64C550D0E7C471E819
...    F604F8C73E618F28581C0E1E05C00FFC007003FF0005C0000E0551B137582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E5
...    0B0381C3C0B801FF800E007FE000B80001C0037838020000002C040BC3C01000E260000020B0102F0F00400389A00000C2C0408038031000
...    6026404D174022501C089B1CF870A244D8E7C3851226C73E180070318C60205E82E003C00281C1401C0C02500700060240040603E0380200
...    000001000002008000020040020180400800004004000028020000180100000E03B032B036B262B2A2B066B062B036B2A280E0800004B292
...    82000032CA4A0800014B2928200806014B29282000092CA4A080002CB292820000D2CA4A080003CB29280EA075540F2A935552ACAA0D9541
...    AAA81E552ACA16004800D028000C002008010004010020808020040202004040401002010080106A87C0004080C10181C282C30344044484
...    C5060646C70747C8494989CA0A4A8B4BD05060B4


*** Test Cases ***
CB007219-ET-AC01_Successful_SA_CA_setup_with_contiguous_frequencies_in_N78_and_N77_extended
    [Documentation]
    ...    1. This user scenario describes the successful setup of CA, when in the list of cells to be aggregated, there is at least one MFBI cell
    ...    configured with native band n78 which is contiguous with another cell in the list configured with native band as n77 extended for Canada,
    ...    where the PCell belongs to a band other than N77 or N78. USCB007219-AC#B1,USCB007219-AC#B1.1,USCB007219-AC#B1.2.
    ...    This user scenario describes the successful setup of CA, when in the list of cells to be aggregated, there is at least one MFBI cell
    ...    configured with native band n78 is contiguous with another cell configured with native band as n77 extended for Canada, where the cell
    ...    with n77 extended band is the PCell, USCB007219-AC#B2.
    ...    This user scenario describes the successful setup of CA, when in the list of cells to be aggregated, there is at least one MFBI cell
    ...    configured with native band n78 is contiguous with another cell configured with native band as n77 extended for Canada, when the UE does
    ...    not support band n78.USCB007219-AC#B3.
    ...    2. Configuration
    ...    NRBTS/actBcsCheck is disabled,5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true.
    ...    CB010378:NRBTS.actExt2N77Support=true, CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to true.
    ...    alternative band configuration as below:
    ...    Cell configuration:    cell_11    cell_12    cell_13    cell_14    cell_1    cell_2    cell_3    cell_4
    ...    Technology type        FDD        FDD        FDD        FDD        TDD       TDD       TDD       TDD
    ...    Frequency              F0         F1         F2         F3         F4        F5        F6        F7
    ...    chbw                   20         20         20         20         40        40        100       20
    ...    DL MIMO Layers         4L         4L         4L         4L         4L        4L        4L        4L
    ...    Native band            n66        n66        n2         n2         n78       n78       n77E      n38
    ...    Alternative band       NA         NA         NA         NA         n77       n77       NA        n41
    ...    cell1 and cell2 are not contiguous, cell2 and cell3 are contiguous, with F5<F6<F7
    ...    cell3 operates in the higher extended frequency range in Canada, i.e. 3650MHz<= F1 <=3980MHz
    ...    UE1 capability: CA relation: cell11+cell1+cell2+cell3, blind scell addition
    ...    5G-UE indicates support of the higher extended band 77 in Canada,capability UE-NR-Capability->RF-Parameters->extendedBand-n77-2-r17.
    ...    BC#1: n66A-n77(3A)       n66    n77    n77    n77
    ...    FSEI#1:DL MIMO layers    2L     4L     2L     2L
    ...    DL ChBw (MHz)            20     100    40     40
    ...    BC#2: n66A-n78(2A)       n66    N78    n78
    ...    FSEI#1:DL MIMO layers    4L     4L     4L
    ...    DL ChBw (MHz)            20     40     40
    ...    BC#3: n66A_n77C          n66    n77    n77
    ...    FSEI#1:DL MIMO layers    4L     4L     4L
    ...    DL ChBw (MHz)            20     40     100
    ...    UE2 capability: the same as UE1 but doesn't support of the higher extended band 77 in Canada
    ...    UE3 capabiltiy: comparing to UE1, UE supports only band combinations BC#1 and BC#2
    ...    UE4 capability: cell3+cell2+cell1, A1 scell addition.
    ...    5G-UE indicates support of the higher extended band 77 in Canada, capability UE-NR-Capability->RF-Parameters->extendedBand-n77-2-r17.
    ...    BC#1: n77A_78A           N77    n78    only n77 supports UL CA for BC#1
    ...    FSEI#1:DL MIMO layers    4L     4L
    ...    DL ChBw (MHz)            100    100
    ...    BC#2: n77(3A)            N77    N77    N77
    ...    FSEI#1:DL MIMO layers    4L     4L     4L
    ...    DL ChBw (MHz)            100    100    100
    ...    BC#3: n77A_n77C          N77    n77    n77
    ...    FSEI#1:DL MIMO layers    4L     4L     4L
    ...    DL ChBw (MHz)            100    100    100
    ...    BC#4: n77D               N77    N77    N77
    ...    SEI#1:DL MIMO layers     4L     4L     4L
    ...    DL ChBw (MHz)            100    100    100
    ...    UE5 capability: the same as UE4. cell2+cell1+cell3, A1 scell addition.
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell11 and try to add scells blindly.Start DL/UL traffic
    ...    b. attach UE2 to cell11 and try to add scells blindly.Start DL/UL traffic.
    ...    c. attach UE3 to cell11 and try to add scells blindly.Start DL/UL traffic.
    ...    d. attach UE4 to cell3 and trigger A1 for scell addition. Start DL/UL traffic.
    ...    e. attach UE5 to cell2 and trigger A1 for scell addition. Start DL/UL traffic.
    ...    4. Expected:
    ...    a. cell2 and cell3 are added as scells.Cell11 in band n66 and Cell2 and cell3 in band n77. BC#3FSEI#1 is selected.
    ...    b. cell1 and cell2 are added as scells.Cell11 in band n66 and Cell1 and cell2 in band n78. BC#2FSEI#1 is selected.
    ...    c. cell1 and cell3 are added as scells.Cell11 in band n66 and Cell1 and cell3 in band n77. BC#1FSEI#1 is selected.
    ...    d. cell1 and cell2 are added as scells.cell3/2/1 in n77. BC#3FSEI#1 is selected.
    ...    e. cell1 and cell3 are added as scells.cell2/1/3 in n77. BC#3FSEI#1 is selected.
    [Tags]    QC_327095    christine.chen    AC01    CA_LABEL-FTT(20MHZ_FDD_n66+40MHZ_TDD_n77+100MHZ_TDD_n77)
    ...    CA_LABEL-TTT(40MHZ_TDD_n77+40MHZ_TDD_n77+100MHZ_TDD_n77)        CA_LABEL-FTT(20MHZ_FDD_n66+40MHZ_TDD_n78+100MHZ_TDD_n78)
    Update UE capa for AC01
    Trigger blind ScellAdd    pass_CA=${CA_succ_for_UE1}    ue_id=1    cell_id=11
    Trigger blind ScellAdd    pass_CA=${CA_succ_for_UE2}    ue_id=2    cell_id=11
    Trigger blind ScellAdd    pass_CA=${CA_succ_for_UE3}    ue_id=3    cell_id=11
    Ue register and pdu session setup    pduModifyCheck=${UE_register_and_A1_configured}    ue_id=4    cell_id=3
    Trigger A1 ScellAdd succ    pass_CA=${CA_succ_for_UE4}    ue_id=4    carrierfreq=646656
    Ue register and pdu session setup    pduModifyCheck=${UE_register_and_A1_configured}    ue_id=5    cell_id=2
    Trigger A1 ScellAdd succ    pass_CA=${CA_succ_for_UE5}    ue_id=5    carrierfreq=641088
    Check Wireshark Log    ${CURDIR}${/}A2A_AC01${/}a2a.ini    wait_string=UEContextReleaseComplete::20

CB007219-ET-AC03_Successful_SA_CA_setup_with_contiguous_frequencies_in_N78_and_N77_extended_when_dedicated_BWP_is_configured
    [Documentation]
    ...    1. This user scenario describes the successful setup of CA, when in the list of cells to be aggregated, there is at least one MFBI cell
    ...    configured with native band n78 is contiguous with another cell configured with native band as n77 extended for Canada, when there is a
    ...    small dedicated BWP configured for the SCell with n77 extended band.
    ...    2. Configuration
    ...    NRBTS/actBcsCheck is disabled, CB007552:actMultipleDedicatedBWPs =true, CB008541:actEnhMultipleDedicatedBWPs=true
    ...    CB010378:NRBTS.actExt2N77Support=true, CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:    cell_11    cell_12    cell_13    cell_14    cell_1    cell_2    cell_3    cell_4
    ...    Technology type        FDD        FDD        FDD        FDD        TDD       TDD       TDD       TDD
    ...    Frequency              F0         F1         F2         F3         F4        F5        F6        F7
    ...    chbw                   20         20         20         20         40        40        100       20
    ...    Small BWP              NA         NA         NA         NA         NA        NA        80        NA
    ...    DL MIMO Layers         4L         4L         4L         4L         4L        4L        4L        4L
    ...    Native band            n66        n66        n2         n2         n78       n78       n77E      n38
    ...    Alternative band       NA         NA         NA         NA         n77       n77       n78       n41
    ...    cell1 and cell2 are not contiguous, cell2 and cell3 are contiguous, with F5<F6<F7
    ...    cell3 operates in the higher extended frequency range in Canada, i.e. 3650MHz<= F1 <=3980MHz
    ...    UE1 capability: CA relation: cell11+cell2+cell3, blind scell addition
    ...    5G-UE indicates support of the higher extended band 77 in Canada, capability UE-NR-Capability->RF-Parameters->extendedBand-n77-2-r17.
    ...    BC#1: n66A_78A           N66    n78
    ...    FSEI#1:DL MIMO layers    4L     4L
    ...    DL ChBw (MHz)            20     40
    ...    BC#2: n66A_77A           N66    N77
    ...    FSEI#1:DL MIMO layers    4L     4L
    ...    DL ChBw (MHz)            20     80
    ...    BC#3: n66A_n77(2A)       N66    n77    N77
    ...    FSEI#1:DL MIMO layers    4L     4L     4L
    ...    DL ChBw (MHz)            20     80     40
    ...    BC#4: n66A_n77C          N66    N77    N77
    ...    FSEI#1:DL MIMO layers    4L     4L     4L
    ...    DL ChBw (MHz)            20     80     40
    ...    BC#5: n66A_n78C          N66    N78    N78
    ...    FSEI#1:DL MIMO layers    4L     4L     4L
    ...    DL ChBw (MHz)            20     100    40
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell11 and try to add scells blindly. Start DL/UL traffic.
    ...    Expected:cell2 and cell3 are added as scells.Cell11 in band n66 and Cell2 and cell3 in band n77. BC#4FSEI#1 is selected. cell3 is 80MHz.
    [Tags]    QC_327096    christine.chen    AC03    CA_LABEL-FTT(20MHZ_FDD_n66+40MHZ_TDD_n77+80MHZ_TDD_n77)
    OnlineParamChange    ${online_delete_NRREL1_for_CELL11}
    Update UE capa    ${n66A_78A_and_n66A_77A_and_n66A_n77(2A)_and_n66A_n77C_and_n66A_n78C_Support_ext77}    ue_id=1
    Trigger blind ScellAdd    pass_CA=${CA_succ_for_UE1}    ue_id=1    cell_id=11
    Check Wireshark Log    ${CURDIR}${/}A2A_AC03${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    AC03_Teardown

CB007219-ET-AC04_Successful SA CA setup with contiguous frequencies in N78 and N77 extended when no matching BCS is found for contiguous CA
    [Documentation]
    ...    1. This user scenario describes the successful setup of CA, when in the list of cells to be aggregated, there is at least one MFBI cell
    ...    configured with native band n78 contiguous with another cell configured with native band as n77 extended for Canada, where there are no
    ...    matching BCS for contiguous CA.
    ...    2. Configuration
    ...    NRBTS/actBcsCheck is enabled, CB007552:actMultipleDedicatedBWPs =true, CB008541:actEnhMultipleDedicatedBWPs=true
    ...    CB010378:NRBTS.actExt2N77Support=true, CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:    cell_11    cell_12    cell_13    cell_14    cell_1    cell_2    cell_3    cell_4
    ...    Technology type        FDD        FDD        FDD        FDD        TDD       TDD       TDD       TDD
    ...    Frequency              F0         F1         F2         F3         F4        F5        F6        F7
    ...    chbw                   20         20         20         20         40        40        100       20
    ...    Small BWP              NA         NA         NA         NA         NA        20        80        NA
    ...    DL MIMO Layers         4L         4L         4L         4L         4L        4L        4L        4L
    ...    Native band            n66        n66        n2         n2         n78       n78       n77E      n38
    ...    Alternative band       NA         NA         NA         NA         n77       n77       n78       n41
    ...    cell1 and cell2 are not contiguous, cell2 and cell3 are contiguous, with F5<F6<F7
    ...    cell3 operates in the higher extended frequency range in Canada, i.e. 3650MHz<= F1 <=3980MHz
    ...    UE1 capability: CA relation: cell3+cell2, blind scell addition
    ...    5G-UE indicates support of the higher extended band 77 in Canada, capability UE-NR-Capability->RF-Parameters->extendedBand-n77-2-r17.
    ...    BC#1: n77A_78A            N77    N78    only n77 supports UL CA class.      
    ...    FSEI#1: DL MIMO layers    4L     4L
    ...    DL ChBw (MHz)             100    20    
    ...    BC#2: n77C                N77    N77    BCS0
    ...    FSEI#1: DL MIMO layers    4L     4L    
    ...    DL ChBw (MHz)             100    40
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell3 and try to add scells blindly. Start DL/UL traffic.
    ...    b. online change NRBTS/actBcsCheck is disabled and release UE1.
    ...    c. attach UE1 to cell3 and try to add scells blindly again. Start DL/UL traffic.
    ...    Expected:
    ...    a. cell2 is added as scells. 5G-UE serving cells and respective measurement objects are configured at 5G-UE to operate as follows: 
    ...       cell3 in n77, cell2 in n78. BC#1FSEI#1 is selected. cell2 is 20MHz.
    ...    b. online modifition is successful.
    ...    c. cell2 is added as scells. 5G-UE serving cells and respective measurement objects are configured at 5G-UE to operate as follows:
    ...       cell3 in n77, cell2 in n77. BC#2FSEI#1 is selected. cell2 is 40MHz.
    [Tags]    QC_327097    jing.ye    AC04    CA_LABEL-TT(100MHZ_TDD_n77+20MHZ_TDD_n78)    CA_LABEL-TT(100MHZ_TDD_n77+40MHZ_TDD_n77)
    OnlineParamChange    ${online_modify_for_AC04}
    Update UE capa    ${n77A_78A_and_n77C_Support_ext77}   
    Ue register and pdu session setup    ${CA_succ_N77_N78_20M}    ue_id=81    cell_id=3
    Send and Verify Throughput
    OnlineParamChange    ${disable_actBcsCheck}
    UE Deregister From gNB    ue_id=81
    Ue register and pdu session setup    ${CA_succ_N77C_40M}    ue_id=81    cell_id=3    fail_regexp=locationAndBandwidth 13750
    Send and Verify Throughput
    Check Wireshark Log    ${CURDIR}${/}A2A_AC04${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    AC04_Teardown

CB007219-ET-AC05_Successful NSA CA setup with contiguous frequencies in N78 and N77
    [Documentation]
    ...    1. This user scenario describes the successful setup of CA, when in the list of cells to be aggregated, there is at least one MFBI cell
    ...    configured with native band n78 is contiguous with another cell configured with native band as n77 extended for Canada in NSA
    ...    configuration with PCell in native band N77 extended.
    ...    USCB007219-AC#B7
    ...    USCB007219-AC#B7.1
    ...    This user scenario describes the successful setup of CA, when in the list of cells to be aggregated, there is at least one MFBI
    ...    cell configured with native band n78 contiguous with another cell configured with native band as n77 extended for Canada in NSA
    ...    configuration with PSCell in alternative band
    ...    USCB007219-AC#B8
    ...    USCB007219-AC#B8.1
    ...    2. Configuration
    ...    NRBTS/actBcsCheck is disabled
    ...    CB010378:NRBTS.actExt2N77Support=true, CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:    cell_11    cell_12    cell_13    cell_14    cell_1    cell_2    cell_3    cell_4
    ...    Technology type        FDD        FDD        FDD        FDD        TDD       TDD       TDD       TDD
    ...    Frequency              F0         F1         F2         F3         F4        F5        F6        F7
    ...    chbw                   20         20         20         20         40        40        100       20
    ...    Small BWP              NA         NA         NA         NA         NA        20        80        NA
    ...    DL MIMO Layers         4L         4L         4L         4L         4L        4L        4L        4L
    ...    Native band            n66        n66        n2         n2         n78       n78       n77E      n38
    ...    Alternative band       NA         NA         NA         NA         n77       n77       n78       n41
    ...    cell1 and cell2 are not contiguous, cell2 and cell3 are contiguous, with F5<F6<F7
    ...    cell3 operates in the higher extended frequency range in Canada, i.e. 3650MHz<= F1 <=3980MHz
    ...    UE1 capability: CA relation: cell3+cell2, blind scell addition
    ...    5G-UE indicates support of the higher extended band 77 in Canada, capability UE-NR-Capability->RF-Parameters->extendedBand-n77-2-r17.
    ...    BC#1: DC_5A_66A_n77A_n77A N77    N77
    ...    FSEI#1: DL MIMO layers    4L     4L
    ...    DL ChBw (MHz)             100    40    
    ...    BC#2: DC_5A_66A_n77C      N77    N77    BCS0
    ...    FSEI#1: DL MIMO layers    4L     4L    
    ...    DL ChBw (MHz)             100    40
    ...    UE2 capability: CA relation: cell3+cell2, blind scell addition
    ...    5G-UE indicates support of the higher extended band 77 in Canada, capability UE-NR-Capability->RF-Parameters->extendedBand-n77-2-r17.
    ...    BC#1: DC_5A_66A_n77A_n78A N77    N78
    ...    FSEI#1: DL MIMO layers    4L     4L
    ...    DL ChBw (MHz)             100    40    
    ...    BC#2: DC_5A_66A_n77C      N77    N77    BCS0
    ...    FSEI#1: DL MIMO layers    4L     4L    
    ...    DL ChBw (MHz)             100    40
    ...    UE3 capability: CA relation: cell2+cell3, A1 scell addition, the same as UE1
    ...    UE4 capability: CA relation: cell2+cell3, A1 scell addition, the same as UE2
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell3 and try to add scells blindly. Start DL/UL traffic.
    ...    b. attach UE2 to cell3 and try to add scells blindly. Start DL/UL traffic.
    ...    c. attach UE3 to cell2 and ttrigger A1 for scell addition. Start DL/UL traffic.
    ...    d. attach UE4 to cell2 and ttrigger A1 for scell addition. Start DL/UL traffic.
    ...    Expected:
    ...    a. cell2 is added as scell. 5G-UE serving cells and respective measurement objects are configured at 5G-UE to operate as follows: 
    ...       cell3 and cell2 in n77. BC#2FSEI#1 is selected.
    ...    b. cell2 is added as scell. 5G-UE serving cells and respective measurement objects are configured at 5G-UE to operate as follows: 
    ...       cell3 in n77, cell2 in n78. BC#1FSEI#1 is selected.
    ...    c. cell3 is added as scell. 5G-UE serving cells and respective measurement objects are configured at 5G-UE to operate as follows:
    ...       cell3 and cell2 in n77. BC#2FSEI#1 is selected.
    ...    d. cell3 is added as scell. 5G-UE serving cells and respective measurement objects are configured at 5G-UE to operate as follows:
    ...       cell2 in n78, cell3 in n77. BC#1FSEI#1 is selected.
    [Tags]    QC_327098    jiadan.wu    AC05    CA_LABEL-TT(40MHZ_TDD_n77(n78)+100MHZ_TDD_n77)
    OnlineParamChange    ${online_NRREL_for_AC05}
    NSA UE1 blind scell addition and check traffic
    NSA UE2 blind scell addition and check traffic
    NSA UE3 A1 scell addition and check traffic
    NSA UE4 A1 scell addition and check traffic
    Check Wireshark Log    ${CURDIR}${/}A2A_AC05${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    [Teardown]    AC05_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_2N66_3N78_N38    ue_count=15

AC04_Teardown
    OnlineParamChange    ${online_recover_for_AC04}
    Common Test Teardown And Stop Capture Logs

Send and Verify Throughput
    [Arguments]    ${ue_id}=81
    Send Throughput    ue_id=${ue_id}     times=11
    Wait Until Keyword Succeeds    30s    5s    Verify Throuput For 2CC    ue_id=${ue_id}

Trigger blind ScellAdd
    [Arguments]    ${ue_id}=81    ${cell_id}=3    ${pass_CA}=${EMPTY}
    Ue register and pdu session setup    ${pass_CA}    ue_id=${ue_id}    cell_id=${cell_id}
    Send Throughput    ue_id=${ue_id}     times=10
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput    ue_id=${ue_id}     Tput_dl=1000    Tput_ul=19
    UE Deregister From gNB    ue_id=${ue_id}

Trigger A1 ScellAdd succ
    [Arguments]    ${ue_id}=81    ${event_type}=A1    ${carrierfreq}=632736
    ...    ${srsrp_nr}=100    ${srsrq_nr}=50    ${pass_CA}=${EMPTY}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_CA}
    Send Throughput    ue_id=${ue_id}     times=10
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput    ue_id=${ue_id}     Tput_dl=1000    Tput_ul=19
    UE Deregister From gNB    ue_id=${ue_id}

AC03_Teardown
    OnlineParamChange    ${online_add_NRREL1_for_CELL11}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Update UE capa for AC01
    Update UE capa    ${N66_N77_N77_N77_and_N66_N78_N78_and_N66_N77C_Support_ext77}    ue_id=1
    Update UE capa    ${N66_N77_N77_N77_and_N66_N78_N78_and_N66_N77C_notSupport_ext77}    ue_id=2
    Update UE capa    ${N66_N77_N77_N77_and_N66_N78_N78_Support_ext77}    ue_id=3
    Update UE capa    ${n77A_78A_and_n77(3A)_and_n77D_and_n77A_n77C_Support_ext77}    ue_id=4
    Update UE capa    ${n77A_78A_and_n77(3A)_and_n77D_and_n77A_n77C_Support_ext77}    ue_id=5

Ue register and pdu session setup
    [Arguments]    ${pduModifyCheck}    ${ue_id}=1    ${cell_id}=2    ${fail_regexp}=locationAndBandwidth 13751
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pduModifyCheck}
    Should Not Contain    ${ret}    ${fail_regexp}

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=7    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=30 trf_id=15    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
#    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=16    ${cell}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    ...    ${bc_list_mrdc}=1:1|2:1|3:1    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${meas_config}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell}
    Update NSA UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${meas_config}    timeout=20s

Update NSA UE capa
    [Arguments]    ${ue_id}=16    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_mrdc_cap}
    Execute Egate Command    ${cmd}


Add Scell By A1
    [Arguments]    ${ue_id}=18    ${carrierfreq}=638976    ${srsrp_nr}=100    ${srsrq_nr}=100    ${pass_CA}=none    ${fail_CA}=none
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...    pass_regexp=${pass_CA}    fail_regexp=${fail_CA}

AC05_Teardown
    OnlineParamChange    ${online_recovery_for_AC05}
    Common Test Teardown And Stop Capture Logs

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
	
Verify Throuput For 2CC
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=1200    ${ul}=24
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 10
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 10
	${total_dl}    Evaluate    ${scell0_tput}+${scell1_tput}
    Should Be True     ${total_dl}/1000 > ${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

NSA UE1 blind scell addition and check traffic
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=16    cell=1    target_cells=3    SA_Capa_perUE_Full=${Capa_NR_AC05}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${Capa_MRDC_5A_66A_n77A_n77A_and_5A_66A_n77C}    meas_config=${CA_CELL3_CELL2}
    Send Throughput for NSA UE    ue_id=16    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=16    cell_num=2    min_dl_tput=720    min_ul_tput=8
    Release Ues    ue_type=all

NSA UE2 blind scell addition and check traffic
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=17    cell=1    target_cells=3    SA_Capa_perUE_Full=${Capa_NR_AC05}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${Capa_MRDC_5A_66A_n77A_n78A_and_5A_66A_n77C}    meas_config=${CA_CELL3_CELL2}
    Send Throughput for NSA UE    ue_id=17    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=17    cell_num=2    min_dl_tput=720    min_ul_tput=8
    Release Ues    ue_type=all

NSA UE3 A1 scell addition and check traffic
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=18    cell=1    target_cells=2    SA_Capa_perUE_Full=${Capa_NR_AC05}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${Capa_MRDC_5A_66A_n77A_n77A_and_5A_66A_n77C}    meas_config=${N77_PCell}
    Add Scell By A1    ue_id=18    pass_CA=${CA_CELL2_CELL3}    carrierfreq=641088
    Send Throughput for NSA UE    ue_id=18    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=18    cell_num=2    min_dl_tput=720    min_ul_tput=8
    Release Ues    ue_type=all

NSA UE4 A1 scell addition and check traffic
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=19    cell=1    target_cells=2    SA_Capa_perUE_Full=${Capa_NR_AC05}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${Capa_MRDC_5A_66A_n77A_n78A_and_5A_66A_n77C}    meas_config=${N78_PCell}
    Add Scell By A1    ue_id=19    pass_CA=${CA_CELL2_CELL3}    carrierfreq=641088
    Send Throughput for NSA UE    ue_id=19    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=19    cell_num=2    min_dl_tput=720    min_ul_tput=8
    Release Ues    ue_type=all
