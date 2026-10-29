*** Settings ***
Documentation
...    author:  dandan.chen@nokia-sbell.com
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-christine.chen
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{1416}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{CA_REL}
...    @{BWP_Para}
...    @{bwp_change}

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRCELL-1:gscnOrSsPbchArfcn=7899
...    NRCELL-1:nrarfcn=639362
...    NRCELL-2:gscnOrSsPbchArfcn=7852
...    NRCELL-2:nrarfcn=633920
...    NRCELL-3:gscnOrSsPbchArfcn=7899
...    NRCELL-3:msg1FrequencyStart=7
...    NRCELL-3:nrarfcn=639362
...    NRCELL-1:type0CoresetConfigurationIndex=0
...    NRCELL-2:type0CoresetConfigurationIndex=0
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:chBw=40MHz
...    NRCELL-3:chBw=100MHz
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-2:freqBandIndicatorNR=77
...    NRCELL-3:freqBandIndicatorNR=78
...    NRCELL-14:gscnOrSsPbchArfcn=4860
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=390000
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=374000
...    NRCELL-14:type0CoresetConfigurationIndex=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRSYSINFO_PROFILE-2/NRIAFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-4
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-4

...    NRCELL-14:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-4
...    NRCELL-14:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-4

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=41
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=78
...    NRBTS/NRCONNECTMODE_PROFILE-4:multiFreqBandIndicatorNR=25

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
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=25

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=2

@{CA_enable}
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRDU-1:actInterNumerologyCa=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:carrierAggregationSupportList=${CAlist}
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,
...    ca_Fr1Tdd_Fdd_Nsa

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
...    NRBTS-1:actHoOptimizationCa=true
...    NRCELL-13:measGapSelectionSA=favourUeThroughput

...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:lcrId=3
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly

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

...    NRCELL-13/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=638400
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-13/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-13/NRHOIF-1:a1BasedPCellSwitchEnabled=true

...    NRCELL-1:measGapSelectionSA=favourUeThroughput

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

...    NRCELL-1/NRHOIF-13:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-13:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-13:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-13:freqBandIndicatorNR=2
...    NRCELL-1/NRHOIF-13:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-13:ifhoSsbSmtcDuration=sf3
...    NRCELL-1/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-13:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-13:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-13:ssbFrequency=388830
...    NRCELL-1/NRHOIF-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-1/NRHOIF-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-4
...    NRCELL-1/NRHOIF-13:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-13:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-13:thresholdPCellSwitchTargetRsrp=80
...    NRCELL-1/NRHOIF-13:thresholdPCellSwitchTargetRsrq=80

...    NRCELL-3:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=480ms

...    NRCELL-13:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-13:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-13:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0|a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70|a2TimeToTriggerPCellSwitchSsbRsrp=480ms

...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0|a1ThresholdhoSsbRsrp=40|a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0|a2ThresholdhoSsbRsrp=34|a2TimeToTriggerhoSsbRsrp=ms40

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
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=crb0
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
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n133
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
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-3:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-1:msg1FrequencyStart=20
...    NRCELL-2:msg1FrequencyStart=20
...    NRCELL-3:msg1FrequencyStart=25
#FDD, small bwp 15M
...    NRBTS/BWP_PROFILE-8:bwpType=dedicated
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-8/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=14
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=42
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
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=18|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-14:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-14:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3
...    NRCELL-14:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8

@{bwp_change}
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-10:bwpType=dedicated
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthDl:cRbSizeDl=n273
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthUl:cRbSizeUl=n273
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-10/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-10/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-10032:bwpType=dedicated
...    NRBTS/BWP_PROFILE-10032:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-10032:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-10032:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-10032:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-10032/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-10072:bwpType=dedicated
...    NRBTS/BWP_PROFILE-10072:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-10072:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-10072:locationAndBandwidthUl:cRbSizeUl=n133
...    NRBTS/BWP_PROFILE-10072:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-10072/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-11:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-11:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-11:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-11:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-11/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-12:bwpType=dedicated
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=n106
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-12/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbSizeUl=n133
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-9/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRCELL-1:msg1FrequencyStart=7
...    NRCELL-1:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-1:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-11:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-11:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-12:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-12:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-11
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-12
...    NRCELL-13:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-13:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-14:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-11
...    NRCELL-14:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-12
...    NRCELL-14:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-10032
...    NRCELL-14:pdcchAutoConfig:bwpChBwDedicated2=15MHz
...    NRCELL-14:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-14:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-2:msg1FrequencyStart=7
...    NRCELL-2:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-2:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-3:msg1FrequencyStart=22
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-9
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-10
...    NRCELL-3:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-10072
...    NRCELL-3:pdcchAutoConfig:bwpChBwDedicated2=50MHz
...    NRCELL-3:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-3:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-4:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-4:pdcchAutoConfig:initialBWPMode=sameAsCoreset0

@{online_change_CB007219_B_FAF_to_true}
...    NRBTS:actMfbiNrCaMeasConfResolv=true
#CNI-105411
...    NRBTS:actRtwpMeasurement=true
...    NRCELL-1:actEirpControl=true
...    NRCELLGRP-0:maxHarqMsg3Tx=4
...    NRBTS-1/NRSYSINFO_PROFILE-1:sibSchedulingList:sibPeriodicity=rf16

@{online_change_CB007219_B_FAF_to_false}
...    NRBTS:actMfbiNrCaMeasConfResolv=false
#CNI-105411
...    NRCELLGRP-0:maxDlHarqTx=5

@{N25_succ}
...    rrcConnectionReconfigurationComplete
...    pcid:62, scellIdx:8
...    frequencyBandList.*\{.*25.*\}\.
...    eventId eventA2
...    eventId eventA1
...    a2-Threshold rsrp : 34
...    reported successful RA

@{CA_CELL13_CELL3_B008}
...    frequencyBandList.*\{.*77.*\}\.
...    freqBandIndicatorNR 77
...    eventId eventA2
...    eventId eventA1
...    a2-Threshold rsrp : 40
...    pcid:52, scellIdx:9
...    pcid:62, scellIdx:8
...    Sending SgNB Modification Confirm

@{CA_CELL13_CELL3_after_enable_7219B}
...    frequencyBandList.*\{.*77.*\}\.
...    pcid:52, scellIdx:9
...    pcid:62, scellIdx:8
...    eventId eventA2
...    Sending SgNB Modification Confirm
...    measId 3

@{A1_not_config}
...    eventId eventA1

@{CA_CELL13_CELL3}
...    frequencyBandList.*\{.*77.*\}\.
...    pcid:52, scellIdx:9
...    pcid:62, scellIdx:8
...    Sending SgNB Modification Confirm

@{CA_CELL13_CELL3_B009_UE17}
...    frequencyBandList.*\{.*77.*\}\.
...    pcid:52, scellIdx:9
...    pcid:62, scellIdx:8
...    eventId eventA2
...    a2-Threshold rsrp : 40
...    eventId eventA1
...    measId 5
...    measId 1
...    Sending SgNB Modification Confirm

@{no_PScell_and_A2scell_conf}
...    eventId eventA2
...    eventId eventA1

@{pass_A2_mobility_check_for_cell13}
...    measGapConfig setup
...    eventId eventA1
...    eventId eventA3
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete

@{pass_A2_mobility_check_for_cell13_UE1819}
...    measGapConfig setup
...    freqBandIndicatorNR 78
...    eventId eventA1
...    eventId eventA3
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete
...    measIdToRemoveList\\s\+\{\\s\+1,\\s\+3,\\s\+4\\s\+\}
...    reportConfigToRemoveList\\s\+\{\\s\+1,\\s\+3,\\s\+4\\s\+\}

@{pass_A2_mobility_check_for_cell13_UE16}
...    measGapConfig setup
...    freqBandIndicatorNR 78
...    eventId eventA1
...    eventId eventA3
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete
...    measIdToRemoveList\\s\+\{\\s\+1,\\s\+3\\s\+\}
...    reportConfigToRemoveList\\s\+\{\\s\+1,\\s\+3\\s\+\}

@{pass_A2_mobility_check_for_cell13_B009_UE16}
...    measGapConfig setup
...    freqBandIndicatorNR 78
...    eventId eventA1
...    eventId eventA3
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete

@{pass_A2_mobility_check_for_cell13_B009_UE17}
...    measGapConfig setup
...    freqBandIndicatorNR 77
...    eventId eventA1
...    eventId eventA3
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete

@{pass_A1_mobility_check}
...    measGapConfig release
...    eventId eventA2
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete
...    measIdToRemoveList\\s\+\{\\s\+2,\\s\+4,\\s\+5\\s\+\}
...    reportConfigToRemoveList\\s\+\{\\s\+2,\\s\+4,\\s\+5\\s\+\}

@{pass_A1_mobility_check_UE17}
...    measGapConfig release
...    eventId eventA2
...    pcid:62, scellIdx:8
...    measId 1
...    measId 3
...    measId 4
...    rrcConnectionReconfigurationComplete

@{pass_A1_mobility_check_UE19}
...    measGapConfig release
...    freqBandIndicatorNR 77
...    a2-Threshold rsrp : 40
...    a2-Threshold rsrp : 34
...    eventId eventA2
...    eventId eventA1
...    measId 1
...    measId 3
...    measId 4
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete

@{pass_A1_mobility_check_for_UE18}
...    measGapConfig release
...    freqBandIndicatorNR 77
...    eventId eventA2
...    measId 3
...    a2-Threshold rsrp : 40
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete

@{pass_A1_mobility_check_B009}
...    measGapConfig release
...    freqBandIndicatorNR 77
...    eventId eventA2
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete

@{HO_to_cell1_with_scell13_B009_UE16}
...    rrcConnectionReconfigurationComplete
...    pcid:62, scellIdx:9
...    pcid:50, scellIdx:8
...    frequencyBandList.*\{.*78.*\}\.
...    frequencyBandList.*\{.*25.*\}\.
...    eventId eventA2
...    a2-Threshold rsrp : 34
...    a2-Threshold rsrp : 40
...    a2-Threshold rsrp : 70

@{HO_to_cell1_with_scell13_B009_UE17}
...    rrcConnectionReconfigurationComplete
...    pcid:62, scellIdx:9
...    pcid:50, scellIdx:8
...    frequencyBandList.*\{.*77.*\}\.
...    frequencyBandList.*\{.*25.*\}\.
...    eventId eventA2
...    a2-Threshold rsrp : 34
...    a2-Threshold rsrp : 70
...    a2-Threshold rsrp : 40

@{HO_to_cell1_with_scell13_B008_UE16}
...    measGapConfig release
...    rrcConnectionReconfigurationComplete
...    freqBandIndicatorNR 78
...    freqBandIndicatorNR 25
...    eventId eventA2
...    a2-Threshold rsrp : 70
...    a2-Threshold rsrp : 40
...    a2-Threshold rsrp : 34
...    pcid:62, scellIdx:9
...    pcid:50, scellIdx:8
...    frequencyBandList.*\{.*78.*\}\.
...    frequencyBandList.*\{.*25.*\}\.

@{HO_to_cell1_with_scell13_B008_UE20}
...    rrcConnectionReconfigurationComplete
...    freqBandIndicatorNR 77
...    freqBandIndicatorNR 25
...    eventId eventA2
...    a2-Threshold rsrp : 34
...    a2-Threshold rsrp : 70
...    a2-Threshold rsrp : 40
...    pcid:62, scellIdx:9
...    pcid:50, scellIdx:8
...    frequencyBandList.*\{.*77.*\}\.
...    frequencyBandList.*\{.*25.*\}\.

@{HO_to_cell13}
...    rrcConnectionReconfigurationComplete
...    freqBandIndicatorNR 25
...    eventId eventA2
...    eventId eventA1
...    pcid:62, scellIdx:8
...    frequencyBandList.*\{.*25.*\}\.

@{HO_to_cell13_B008}
...    measGapConfig release
...    rrcConnectionReconfigurationComplete
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 77
...    eventId eventA2
...    pcid:62, scellIdx:8
...    pcid:52, scellIdx:9
...    frequencyBandList.*\{.*25.*\}\.
...    frequencyBandList.*\{.*77.*\}\.

@{HO_to_cell13_with_scell1}
...    rrcConnectionReconfigurationComplete
...    pcid:52, scellIdx:9
...    pcid:62, scellIdx:8
...    frequencyBandList.*\{.*77.*\}\.
...    frequencyBandList.*\{.*25.*\}\.
...    freqBandIndicatorNR 77
...    freqBandIndicatorNR 25
...    eventId eventA2
...    eventId eventA1
...    a2-Threshold rsrp : 34
...    measId 4

@{pass_A2_mobility_check_for_cell1}
...    measGapConfig setup
...    eventId eventA1
...    eventId eventA3
...    pcid:50, scellIdx:8
...    rrcConnectionReconfigurationComplete

@{A2_scell_release_check}
...    sCellToReleaseList.*\{.*9.*\}\.
...    eventId eventA1
...    pcid:62, scellIdx:8
...    rrcConnectionReconfigurationComplete

${Capa_MRDC_66A_n78A_n25A_and_66A_n77A_n25A}    SEPARATOR=
...    A11FF813C4D040389A001C18000000162205E268201C4C000E0C0000010B1102012023402800701060268BA000F40A24E8913639F0E24E89
...    13639F0C003808630300220000804040400801004008400010080804008020140280

${n78A_n25A_and_n77A_n25A}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700AA0D831AC1184341020F941A00CAD93156243
...    9F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE000002E0000702A8D899AC1184341020E906802CB64C550D0E7C471E819
...    F604F8C73E618F28581C0E1E05C00FFC007003FF0005C0000E0551B137582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E5
...    0B0381C3C0B801FF800E007FE000B80001C0037838020000002C040BC3C01000E260000190B0102F0F06000389A00000C2C0408038031000
...    6026404D174022501C089B1CF870A244D8E7C3851226C73E180070318C60205E82E003C00281C1401C0C02500700060240040603E0380200
...    000001000002008000020040020180400800004004000028020000180100000E03B032B036B262B2A6B066B062B036B27280E0800004B292
...    82000032CA4A0800014B2928200806014B29282000092CA4A080002CB292820000D2CA4A080003CB29280EA075540F2A935552ACAA0D9541
...    AAA81E5527AA16004800D028000C002008010004010020808020040202004040401002010080106A87C0004080C10181C282C30344044484
...    C5060646C70747C8494989CA0A4A8B4BD05060B4

${Capa_MRDC_66B_n77A_n2A}    SEPARATOR=
...    A11FF80BC4D0403898001C18000002162204024046805000E020C04D174001080C49D1226C73E1805008C600440001008080801002008010
...    8000201010080100402805

@{PM_Counters_Check_B009}
...    NRCELL-3:${SCELL_CONF_ALT_BAND_NSA}=4
...    NRCELL-13:${SCELL_CONF_ALT_BAND_NSA}=2

@{PM_Counters_Check_B008}
...    NRCELL-3:${SCELL_CONF_ALT_BAND_NSA}=7
...    NRCELL-13:${SCELL_CONF_ALT_BAND_NSA}=2

#${SCELL_CONF_ALT_BAND_NSA}    M55118C01006
${SCELL_CONF_ALT_BAND_NSA}    M55316C00042
#This counter provides the number of current cell configurations as an NSA SCell in an alternative band.

*** Test Cases ***
CB007219-ET-B009_Successful_EN-DC_setup_and_NR_CA_configuration_with_alternative_bands_and_extended_band_77_in_Canada
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when an MFBI SCell is to be added on alternative band when a UE is already configured
    ...    with inter-frequency mobility measurements on the same frequency of the SCell with native band. USCB007219-B#B7,USCB007219-B#B7.1
    ...    USCB007219-B#B7.2
    ...    2. Configuration
    ...    LTE is configured with cell in B66.
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true.
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to true.NRBTS/actMfbiNrCaMeasConfResolv = true.
    ...    alternative band configuration as below:
    ...    cell_11    cell_12    cell_13    cell_14    cell_1    cell_2    cell_3    cell_4
    ...    Technology type    FDD    FDD    FDD    FDD    TDD    TDD    TDD    TDD
    ...    Frequency    F0    F1    F2    F3    F4    F5    F6    F7
    ...    chbw    20    20    20    20    40    40    100    20
    ...    Small BWP    NA    NA    NA    15    NA    NA    50    NA
    ...    DL MIMO Layers    4L    4L    4L    4L    4L    4L    4L    4L
    ...    Native band    n66    n66    n2    n2    n78    n77E    n78    n38
    ...    Alternative band    NA    NA    n25    n25    n77    NA    n77    n41
    ...    "cell1 and cell2 are not contiguous, the frequency of cell1=cell3, the frequency of cell_13=cell_14, F5 is between 3450-3550 MHz"
    ...    UE1 capability: LTE cell1 + NR cell13+NR cell3, A1 scell addition, actHoOptimizationCa=true. A1 for pcell change is configured in scell.
    ...    inter-freq HO configured towards cell1.
    ...    BC#1: B66-n25A-n78A    N25    n78
    ...    FSEI#1: DL MIMO layers    4L    2L
    ...    DL ChBw (MHz)    20    50
    ...    BC#2: B66-n25A-n77A    N25    n77
    ...    FSEI#1:DL MIMO layers    4L    4L
    ...    DL ChBw (MHz)    40    100
    ...    UE2: the same as UE1 but supports BC#2 only.
    ...    2.Test Case Steps:
    ...         a. attach UE1 to LTE cell1 and trigger EN-DC setup toward the SgNB by sending the X2AP: SgNB Addition Request message to NR cell13
    ...    and trigger A2 for mobility.
    ...         b. trigger A1 for scell addition.
    ...         c. trigger A3 HO to cell2 and HO back but condition is not meet to add scell.
    ...         d. trigger A2 for mobility then trigger A1 for scell addition.
    ...         e. trigger A1 for mobility.
    ...         f. trigger A2 for scell release.
    ...         g. attach UE2 to LTE cell1 and trigger EN-DC setup toward the SgNB by sending the X2AP: SgNB Addition Request message to NR cell13
    ...    and trigger A2 for mobility.
    ...         h. trigger A1 for scell addition.
    ...         i. trigger A2 for scell release.
    ...         j. trigger A3 HO to cell1 then HO back and condition is meet to add scell.
    ...    3.Expectation:
    ...         a. A3/A5 is configured with n78 and MG setup.
    ...         b. cell3 is added as scell in n77 with BC#2. cell13 is in n25. no A2 for scell release and A1 for pcell change is configured for
    ...    scell. measurment object is still configured with n78.
    ...         c. HO to cell1 with n78 successfully. HO back to cell13 with n25 successfully. no scell added.
    ...         d. A3/A5 is configured with n78 and MG setup. cell3 is added as scell in n77 with BC#2. cell13 is in n25. no A2 for scell release
    ...    and A1 for pcell change is configured for scell. measurment object is still configured with n78.
    ...         e. gNB removes A3/A5 measurement configuration and releases measurement gaps. gNB reconfigures the measurement object with n77. A2
    ...    for scell release config and A1 for pcell change is not configured with n77 for scell.
    ...         f. scell released successfully. and measurement object for n77 is removed.
    ...         g. A3/A5 is configured with n77 and MG setup.
    ...         h. cell3 is added as scell in n77 with BC#2. cell13 is in n25. A2 for scell release and A1 for pcell change is configured for scell
    ...    with n77.
    ...         i. scell released successfully. and measurement object for n77 is unchanged.
    ...         j. HO to cell1 with n77 successfully, and cell13 added as scell. Then ho back to cell13 successfully, and cell3 with n77 added as
    ...    scell.
    [Tags]    QC_46814    christine.chen    B009    CA_LABEL-FT(20MHZ_FDD_n25+100MHZ_TDD_n77)    CA_LABEL-TF(40MHZ_TDD_n77+20MHZ_FDD_n25)
    ...    CA_LABEL-TF(40MHZ_TDD_n78+20MHZ_FDD_n25)
    onlineparamchange    Online_Param=${online_change_CB007219_B_FAF_to_true}
    Clear Counter Files
    NSA UE attach and trigger A2 then trigger A1 scell add    ue_id=16    pass_A2_mobility=${pass_A2_mobility_check_for_cell13_B009_UE16}
    HO to cell1 and HO back to cell13    ue_id=16    pass_A3HO_check=${HO_to_cell1_with_scell13_B009_UE16}
    ...    pass_A3HO_back=${HO_to_cell13}    cell_num=1
    A2HO and A1 scell add and A1 for mobility
    Trigger A2 scellreelase and check traffic    ue_id=16
    NSA UE attach and trigger A2 then trigger A1 scell add for UE17    ue_id=17    ue_mrdc_cap=${Capa_MRDC_66B_n77A_n2A}
    Trigger A2 scellreelase and check traffic    ue_id=17
    HO to cell1 and HO back to cell13    ue_id=17    pass_A3HO_check=${HO_to_cell1_with_scell13_B009_UE17}
    ...    pass_A3HO_back=${HO_to_cell13_with_scell1}    nrsrp_nr=100
    Release Ues    ue_type=all
    Check Counters    pm_counters_expression=${PM_Counters_Check_B009}
    [Teardown]    B008_B009_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_2N66_3N78_N38    ue_count=15

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${cell}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
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

Modify Cfg
    ${C_1}    catenate
    ...    set_cell id=1 enb=1 eci=0x1234601 pci=4:0 tac=222 proxy=$DAEMON_IP:12219|$DAEMON_IP:8889
    ...    earfcn=66886:132422 mandatory_for_activation=off
    Update Cfg    ${C_1}
    ${cell14_s_bwp}    catenate    set_cell id=14 gnb=2 pci=21:0 tac=200 nrci=0x0e tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=374000:390000 gscn=4860 mandatory_for_activation=off bwp_arfcn=373514:389514
    Update Cfg    ${cell14_s_bwp}
    ${cell3_s_bwp}    catenate    set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=639362:639362 gscn=7899 mandatory_for_activation=off bwp_arfcn=637682:637682
    Update Cfg    ${cell3_s_bwp}

UE attach cell13 and trigger A1scelladd
    [Arguments]    ${ue_id}=16
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${ue_id}    cell=1    target_cells=13
    ...    SA_Capa_perUE_Full=${n78A_n25A_and_n77A_n25A}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${Capa_MRDC_66A_n78A_n25A_and_66A_n77A_n25A}    meas_config=${N25_succ}
    Add Scell By A1    ue_id=${ue_id}    pass_CA=${CA_CELL13_CELL3_B008}    carrierfreq=388830
    Send Throughput for NSA UE    ue_id=${ue_id}    times=5
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=2    min_dl_tput=150    min_ul_tput=8

UE attach cell13_UE20
    [Arguments]    ${ue_id}=20
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${ue_id}    cell=1    target_cells=13
    ...    SA_Capa_perUE_Full=${n78A_n25A_and_n77A_n25A}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${Capa_MRDC_66B_n77A_n2A}    meas_config=${N25_succ}
    Add Scell By A1    ue_id=${ue_id}    pass_CA=${CA_CELL13_CELL3_B008}    carrierfreq=388830
    Send Throughput for NSA UE    ue_id=${ue_id}    times=5
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=2    min_dl_tput=150    min_ul_tput=8

UE1-UE4 attach cell13 and trigger A1
    UE attach cell13 and trigger A1scelladd    ue_id=16
    UE attach cell13 and trigger A1scelladd    ue_id=17
    UE attach cell13 and trigger A1scelladd    ue_id=18
    UE attach cell13 and trigger A1scelladd    ue_id=19

Trigger A2 measurement report
    [Arguments]    ${ue_id}=16    ${carrierfreq}=388830    ${pass_A2_mobility}=none    ${cell_num}=2
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=disable
    sleep    1s
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=${pass_A2_mobility}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=${cell_num}    min_dl_tput=20

Trigger A2 measurement report and no n78 config
    [Arguments]    ${ue_id}=16    ${carrierfreq}=388830    ${pass_A2_mobility}=none    ${cell_num}=2
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=disable
    sleep    1s
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=${pass_A2_mobility}
    Should Not Contain      ${ret1}     freqBandIndicatorNR 78
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=${cell_num}    min_dl_tput=20

Trigger A2 ScellRelease
    [Arguments]    ${carrierfreq}=508110    ${ue_id}=81    ${scell_id}=9    ${pass_check}=none
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=${pass_check}

Trigger A3 measurement report
    [Arguments]    ${ue_id}=16    ${carrierfreq}=388830    ${pass_check}=none    ${phycell_id}=50    ${nrsrp_nr}=80
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${A3_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrp_nr} rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${ret1}=    Execute Egate Command    ${A3_cmd}    pass_regexp=${pass_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=1    min_dl_tput=20    min_ul_tput=8

Trigger A3 MR with error check
    [Arguments]    ${ue_id}=16    ${carrierfreq}=388830    ${pass_check}=none    ${phycell_id}=50    ${nrsrp_nr}=80
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${A3_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrp_nr} rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${ret1}=    Execute Egate Command    ${A3_cmd}    pass_regexp=${pass_check}
    Should Not Contain      ${ret1}     eventA1
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=1    min_dl_tput=20    min_ul_tput=8

Trigger A1 measurement report
    [Arguments]    ${ue_id}=16    ${carrierfreq}=388830    ${pass_check}=none    ${phycell_id}=62
    Execute Egate Command    enb_endc_param id=${ue_id} allowed_bc_list_mrdc=2:1|1:1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=100 nrsrq_nr=100
    ${ret1}=    Execute Egate Command    ${A1_cmd}    pass_regexp=${pass_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=1    min_dl_tput=20    min_ul_tput=8

Trigger A1 measurement report and A1 is not configure
    [Arguments]    ${ue_id}=16    ${carrierfreq}=388830    ${pass_check}=none    ${phycell_id}=62
    Execute Egate Command    enb_endc_param id=${ue_id} allowed_bc_list_mrdc=2:1|1:1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=100 nrsrq_nr=100
    ${ret1}=    Execute Egate Command    ${A1_cmd}    pass_regexp=${pass_check}
    Should Not Contain      ${ret1}     eventA1
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=1    min_dl_tput=20    min_ul_tput=8

Add Scell By A1
    [Arguments]    ${ue_id}=18    ${carrierfreq}=638976    ${srsrp_nr}=100    ${srsrq_nr}=100    ${pass_CA}=none    ${Thold}=90
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ...    threshold=${Thold}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrq_nr}
    ...    pass_regexp=${pass_CA}

Add Scell By A1 with error check
    [Arguments]    ${ue_id}=18    ${carrierfreq}=638976    ${srsrp_nr}=100    ${srsrq_nr}=100    ${pass_CA}=none    ${fail_CA}=null    ${Thold}=90
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ...    threshold=${Thold}
    ${A1_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${A1_cmd}    pass_regexp=${pass_CA}
    Should Not Contain any     ${ret1}     @{fail_CA}

B008_B009_Teardown
    onlineparamchange    Online_Param=${online_change_CB007219_B_FAF_to_false}
    Common Test Teardown And Stop Capture Logs

Send Throughput for NSA UE
    [Arguments]    ${ue_id}=11    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Check Traffic for NSA UE
    [Arguments]     ${ue_id}=11    ${cell_num}=2    ${min_dl_tput}=150    ${min_ul_tput}=8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    8    ${cell_num}+8
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 10
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

NSA UE attach and trigger A2 then trigger A1 scell add
    [Arguments]    ${ue_id}=16    ${ue_mrdc_cap}=${Capa_MRDC_66A_n78A_n25A_and_66A_n77A_n25A}
    ...    ${pass_A2_mobility}=${pass_A2_mobility_check_for_cell13_B009_UE17}    ${pass_CA}=${CA_CELL13_CELL3}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${ue_id}    cell=1    target_cells=13
    ...    SA_Capa_perUE_Full=${n78A_n25A_and_n77A_n25A}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${ue_mrdc_cap}    meas_config=${N25_succ}
    Send Throughput for NSA UE    ue_id=${ue_id}    times=5
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=1    min_dl_tput=20    min_ul_tput=8
    Trigger A2 measurement report    ue_id=${ue_id}    carrierfreq=388830    pass_A2_mobility=${pass_A2_mobility}    cell_num=1
    Add Scell By A1 with error check    ue_id=${ue_id}    pass_CA=${pass_CA}    fail_CA=${no_PScell_and_A2scell_conf}    carrierfreq=388830
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=2    min_dl_tput=150    min_ul_tput=8

NSA UE attach and trigger A2 then trigger A1 scell add for UE17
    [Arguments]    ${ue_id}=17    ${ue_mrdc_cap}=${Capa_MRDC_66A_n78A_n25A_and_66A_n77A_n25A}
    ...    ${pass_A2_mobility}=${pass_A2_mobility_check_for_cell13_B009_UE17}    ${pass_CA}=${CA_CELL13_CELL3_B009_UE17}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${ue_id}    cell=1    target_cells=13
    ...    SA_Capa_perUE_Full=${n78A_n25A_and_n77A_n25A}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${ue_mrdc_cap}    meas_config=${N25_succ}
    Send Throughput for NSA UE    ue_id=${ue_id}    times=5
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=1    min_dl_tput=20    min_ul_tput=8
    Trigger A2 measurement report    ue_id=${ue_id}    carrierfreq=388830    pass_A2_mobility=${pass_A2_mobility}    cell_num=1
    Add Scell By A1    ue_id=${ue_id}    pass_CA=${pass_CA}    carrierfreq=388830
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=2    min_dl_tput=150    min_ul_tput=8

HO to cell1 and HO back to cell13
    [Arguments]    ${ue_id}=16    ${pass_A3HO_check}=${HO_to_cell1_with_scell13_B009_UE16}
    ...    ${pass_A2HO_back}=${pass_A2_mobility_check_for_cell1}    ${pass_A3HO_back}=${HO_to_cell13}    ${cell_num}=2    ${nrsrp_nr}=80
    Trigger A3 measurement report    ue_id=${ue_id}    carrierfreq=638400    pass_check=${pass_A3HO_check}    phycell_id=50
    Trigger A2 measurement report    ue_id=${ue_id}    carrierfreq=638400    pass_A2_mobility=${pass_A2HO_back}    cell_num=${cell_num}
    Trigger A3 measurement report    ue_id=${ue_id}    carrierfreq=388830    pass_check=${pass_A3HO_back}    phycell_id=62    nrsrp_nr=${nrsrp_nr}

Trigger A2 scellreelase and check traffic
    [Arguments]    ${ue_id}=17
    Trigger A2 ScellRelease    carrierfreq=638400    ue_id=${ue_id}    pass_check=${A2_scell_release_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=${ue_id}    cell_num=1    min_dl_tput=20    min_ul_tput=8

A2HO and A1 scell add and A1 for mobility
    Trigger A2 measurement report    ue_id=16    carrierfreq=388830    pass_A2_mobility=${pass_A2_mobility_check_for_cell13_B009_UE16}    cell_num=1
    Add Scell By A1 with error check    ue_id=16    pass_CA=${CA_CELL13_CELL3}    fail_CA=${no_PScell_and_A2scell_conf}    carrierfreq=388830
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=16    cell_num=2    min_dl_tput=150    min_ul_tput=8
    Trigger A1 measurement report and A1 is not configure    ue_id=16    carrierfreq=388830    pass_check=${pass_A1_mobility_check_B009}

B008 stepA-E
    UE1-UE4 attach cell13 and trigger A1
    Trigger A2 measurement report and no n78 config    ue_id=16    carrierfreq=388830    pass_A2_mobility=${pass_A2_mobility_check_for_cell13}
    Trigger A2 measurement report and no n78 config    ue_id=17    carrierfreq=388830    pass_A2_mobility=${pass_A2_mobility_check_for_cell13}
    onlineparamchange    Online_Param=${online_change_CB007219_B_FAF_to_true}
    Trigger A2 measurement report    ue_id=18    carrierfreq=388830    pass_A2_mobility=${pass_A2_mobility_check_for_cell13_UE1819}
    Trigger A2 measurement report    ue_id=19    carrierfreq=388830    pass_A2_mobility=${pass_A2_mobility_check_for_cell13_UE1819}
    Trigger A1 measurement report and A1 is not configure    ue_id=16    carrierfreq=388830    pass_check=${pass_A1_mobility_check}
    Trigger A1 measurement report and A1 is not configure    ue_id=18    carrierfreq=388830    pass_check=${pass_A1_mobility_check_for_UE18}

B008 stepF-J
    Trigger A2 ScellRelease    carrierfreq=638400    ue_id=16    pass_check=${A2_scell_release_check}
    Trigger A2 ScellRelease    carrierfreq=638400    ue_id=18    pass_check=${A2_scell_release_check}
    onlineparamchange    Online_Param=${online_change_CB007219_B_FAF_to_false}
    Trigger A1 measurement report    ue_id=17    carrierfreq=388830    pass_check=${pass_A1_mobility_check_UE17}
    Trigger A1 measurement report    ue_id=19    carrierfreq=388830    pass_check=${pass_A1_mobility_check_UE19}
    Trigger A2 ScellRelease    carrierfreq=638400    ue_id=17    pass_check=${A2_scell_release_check}
    Trigger A2 ScellRelease    carrierfreq=638400    ue_id=19    pass_check=${A2_scell_release_check}
    onlineparamchange    Online_Param=${online_change_CB007219_B_FAF_to_true}

B008 stepK-M
    Add Scell By A1 with error check    ue_id=16    pass_CA=${CA_CELL13_CELL3_after_enable_7219B}    fail_CA=${A1_not_config}    carrierfreq=388830
    Wait Until Keyword Succeeds    30s    5s    Check Traffic for NSA UE    ue_id=16    cell_num=2    min_dl_tput=150    min_ul_tput=8
    Trigger A2 measurement report    ue_id=16    carrierfreq=388830    pass_A2_mobility=${pass_A2_mobility_check_for_cell13_UE16}
    Trigger A3 measurement report    carrierfreq=638400    pass_check=${HO_to_cell1_with_scell13_B008_UE16}    phycell_id=50
    Trigger A2 measurement report    ue_id=16    carrierfreq=638400    pass_A2_mobility=${pass_A2_mobility_check_for_cell1}
    Trigger A3 MR with error check    carrierfreq=388830    pass_check=${HO_to_cell13_B008}    phycell_id=62    nrsrp_nr=100

Stop traffic
    Execute Egate Command    trf_data_stop ue=16 dir=dl pdu=1
    Execute Egate Command    trf_data_stop ue=17 dir=dl pdu=1
    Execute Egate Command    trf_data_stop ue=18 dir=dl pdu=1
    Execute Egate Command    trf_data_stop ue=19 dir=dl pdu=1

B008 stepN-Q
    UE attach cell13_UE20
    Trigger A2 measurement report    ue_id=20    carrierfreq=388830    pass_A2_mobility=${pass_A2_mobility_check_for_cell13}
    Trigger A2 ScellRelease    carrierfreq=638400    ue_id=20    pass_check=${A2_scell_release_check}
    Trigger A3 measurement report    ue_id=20    carrierfreq=638400    pass_check=${HO_to_cell1_with_scell13_B008_UE20}    phycell_id=50

