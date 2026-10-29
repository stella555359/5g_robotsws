*** Settings ***
Documentation
...    author:  dandan.chen@nokia-sbell.com
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-jiadan.wu
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{1416}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{CNI-75210}
...    @{CB008001}
...    @{Scell_Rel_B001}
...    @{Inter_frequency_HO}

@{CB008001}
...    NRBTS:actBcsCheck=disabled

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-4
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRCELL-14:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-14:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRBTS/NRCELL-4:freqBandIndicatorNR=38
...    NRBTS/NRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRCELL-1:chBw=40MHz
...    NRBTS/NRCELL-2:nrarfcn=640000
...    NRBTS/NRCELL-2:gscnOrSsPbchArfcn=7920
...    NRBTS/NRCELL-2:chBw=40MHz
...    NRBTS/NRCELL-3:chBw=40MHz
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=391660
...    NRBTS/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=377460
...    NRBTS/NRCELL-13:gscnOrSsPbchArfcn=4892
...    NRBTS/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=391660
...    NRBTS/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=377460
...    NRBTS/NRCELL-14:gscnOrSsPbchArfcn=4892
...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=25
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=41
...    NRBTS/NRCONNECTMODE_PROFILE-4:multiFreqBandIndicatorNR=78

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
...    NRBTS-1:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRCELL-3:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRDU-1:carrierAggregationSupportList=${CAlist}
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

...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:antPortId=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:antPortId=4
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

...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:antPortId=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:antPortId=4
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

@{CNI-75210}
...    NRBTS:actExtN77Support=true
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-4
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-4        #for n77E
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-4        #for n77E
...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

#FDD, small bwp 15M
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS:actMultipleDedicatedBWPs=true
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
...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8

...    MRBTS-1/NRBTS-1/NRCELL-1:fPdcchMonOccsnPo=2
...    MRBTS-1/NRBTS-1/NRCELL-2:fPdcchMonOccsnPo=2
...    MRBTS-1/NRBTS-1/NRCELL-3:fPdcchMonOccsnPo=2
...    MRBTS-1/NRBTS-1/NRCELL-4:fPdcchMonOccsnPo=2

@{Scell_Rel_B001}
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
...    NRCELL-11/NRREL-2:sCellPrio=1

...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
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

...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
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
...    NRCELL-11/NRREL-3:sCellPrio=2

...    NRCELL-11/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-3:ssbFrequency=640416
...    NRCELL-11/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-11/NRHOIF-3:a1BasedPCellSwitchEnabled=true

...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=632736
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-4

...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0

...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms


@{Inter_frequency_HO}
...    NRBTS:actHoOptimizationCa=true
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=480ms

...    NRCELL-2:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=480ms

...    NRCELL-3:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=480ms

...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL-2:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-2:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=3
...    NRCELL-2:reportAmountA6MeasSCellSwap=r4
...    NRCELL-2:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL-2:thresholdSCellSwapSourceRsrp=66

...    NRCELL-3:a6MeasSCellSwapEnabled=rsrqCombined
...    NRCELL-3:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=3
...    NRCELL-3:a6MeasSCellSwapSsbRsrq:a6OffsetSCellSwapSsbRsrq=3
...    NRCELL-3:reportAmountA6MeasSCellSwap=r4
...    NRCELL-3:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL-3:thresholdSCellSwapSourceRsrp=66
...    NRCELL-3:thresholdSCellSwapSourceRsrq=66

...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-3:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=80

...    NRCELL-3/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrqOffset=0dB
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

...    NRCELL-3/NRHOIF-11:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-11:freqBandIndicatorNR=66
...    NRCELL-3/NRHOIF-11:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-3/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-11:ssbFrequency=424090
...    NRCELL-3/NRHOIF-11:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-3/NRHOIF-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-3/NRHOIF-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-3/NRHOIF-11:a2BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-11:a2BasedPCellSwitchPriority=1
...    NRCELL-3/NRHOIF-11:thresholdPCellSwitchTargetRsrp=50
...    NRCELL-3/NRHOIF-11:thresholdPCellSwitchTargetRsrq=50

...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-2:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=80

...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly

...    NRCELL-2/NRHOIF-11:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-11:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-11:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-11:ssbFrequency=424090
...    NRCELL-2/NRHOIF-11:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-2/NRHOIF-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-2/NRHOIF-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-11:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-11:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-11:thresholdPCellSwitchTargetRsrp=50
...    NRCELL-2/NRHOIF-11:thresholdPCellSwitchTargetRsrq=50

...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms


@{7219-B_false}
...    NRBTS:actMfbiNrCaMeasConfResolv=false

@{7219-B_true}
...    NRBTS:actMfbiNrCaMeasConfResolv=true

@{online_disable_cell2_scell_swap}
...    NRCELL-2:a6MeasSCellSwapEnabled=none

@{online_enable_cell2_scell_swap}
...    NRCELL-2:a6MeasSCellSwapEnabled=rsrp

@{B001_recovery}
...    NRCELL-2:a6MeasSCellSwapEnabled=rsrp
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRCELL-11/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=632736
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true

@{online_delete_NRHOIF_cell3_alter_band}
...    delete:NRCELL-11/NRHOIF-3:nrConnectModeProfileDN
...    delete:NRCELL-11/NRHOIF-1

@{B004_online_enable_8311}
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRCELL-2/NRREL-11:lcrId=13
...    NRCELL-2/NRHOIF-11:freqBandIndicatorNR=2
...    NRCELL-2/NRHOIF-11:ssbFrequency=391450
...    NRCELL-2/NRHOIF-11:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

@{B004_recovery}
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actSCellReleaseForInactiveSCell=disabled
...    NRCELL-2/NRHOIF-11:ssbFrequency=424090
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRHOIF-11:freqBandIndicatorNR=66
...    delete:NRCELL-2/NRHOIF-11:nrConnectModeProfileDN

@{B006_online_NRREL}
...    NRBTS:actMfbiNrCaMeasConfResolv=true
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrqOffset=0dB
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
...    NRCELL-3/NRHOIF-13:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-13:freqBandIndicatorNR=2
...    NRCELL-3/NRHOIF-13:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-13:ifhoSsbSmtcDuration=sf2
...    NRCELL-3/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-13:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-13:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-13:ssbFrequency=391450
...    NRCELL-3/NRHOIF-13:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-3/NRHOIF-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-3/NRHOIF-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-3/NRHOIF-13:a2BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-13:a2BasedPCellSwitchPriority=1
...    NRCELL-3/NRHOIF-13:thresholdPCellSwitchTargetRsrp=50
...    NRCELL-3/NRHOIF-13:thresholdPCellSwitchTargetRsrq=50
...    NRCELL-3/NRHOIF-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-3/NRHOIF-11:a2BasedPCellSwitchPriority=2
...    NRCELL-3/NRHOIF-11:ssbFrequency=432030
...    NRCELL-3/NRREL-11:lcrId=12
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-3:ssbFrequency=640416
...    NRCELL-12/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-12/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-12/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-14:gNbId=1
...    NRCELL-3/NRREL-14:gNbIdLength=22
...    NRCELL-3/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-14:removeNotAllowed=false
...    NRCELL-3/NRREL-14:lcrId=14
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-14/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-3:gNbId=1
...    NRCELL-14/NRREL-3:gNbIdLength=22
...    NRCELL-14/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-3:removeNotAllowed=false
...    NRCELL-14/NRREL-3:lcrId=3
...    NRCELL-14/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-14/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-14/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-14/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-3:ssbFrequency=640416
...    NRCELL-14/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-14/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-14/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-14/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-14/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-14:a1MeasSCellAddEnabled=rsrp
...    NRCELL-14:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-14:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-14:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-14:a1MeashoEnabledSA=rsrp
...    NRCELL-14:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-14:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-14:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-14:a2MeashoEnabledSA=rsrp
...    NRCELL-14:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-14:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-14:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-14:measGapSelectionSA=favourUeThroughput

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
...    NRCELL-13/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-13/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-3:ssbFrequency=640416
...    NRCELL-13/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-13/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-13/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

@{B007_online_NRREL}
...    NRBTS:actMfbiNrCaMeasConfResolv=true
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-12/NRHOIF-13:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-13:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-13:freqBandIndicatorNR=2
...    NRCELL-12/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-12/NRHOIF-13:ssbFrequency=391450
...    NRCELL-12/NRHOIF-13:thresholdPCellSwitchTargetRsrp=50
...    NRCELL-12/NRHOIF-13:thresholdPCellSwitchTargetRsrq=50
...    NRCELL-12/NRHOIF-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-12/NRHOIF-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-12/NRREL-13:gNbId=1
...    NRCELL-12/NRREL-13:lcrId=13
...    NRCELL-12/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3

...    NRCELL-12/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-12/NRHOIF-3:ssbFrequency=640416
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-13:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=50
...    NRCELL-3:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=480ms

@{B006_recovery}
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRCELL-3/NRHOIF-11:a2BasedPCellSwitchPriority=1
...    delete:NRCELL-3/NRREL-13
...    delete:NRCELL-3/NRHOIF-13
...    NRCELL-3/NRREL-11:lcrId=11
...    NRCELL-3/NRHOIF-11:ssbFrequency=424090
...    delete:NRCELL-12/NRREL-3
...    delete:NRCELL-12/NRHOIF-3
...    NRCELL-12:a1MeasSCellAddEnabled=none
...    delete:NRCELL-3/NRREL-14
...    delete:NRCELL-12:measGapSelectionSA
...    delete:NRCELL-14/NRREL-3
...    delete:NRCELL-14/NRHOIF-3
...    NRCELL-14:a1MeasSCellAddEnabled=none
...    NRCELL-14:a1MeashoEnabledSA=none
...    NRCELL-14:a2MeashoEnabledSA=none
...    delete:NRCELL-14:measGapSelectionSA
...    delete:NRCELL-13/NRREL-3
...    delete:NRCELL-13/NRHOIF-3

@{B007_recovery}
...    delete:NRCELL-12/NRREL-3
...    delete:NRCELL-12/NRHOIF-3
...    delete:NRCELL-12/NRREL-13
...    delete:NRCELL-12/NRHOIF-13
...    NRCELL-13:a1MeasPCellSwitchEnabled=none
...    NRCELL-12:a1MeasSCellAddEnabled=none
...    NRBTS:actMfbiNrCaMeasConfResolv=false

@{CA_check_CELL11_CELL1_CELL2}
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    a1-Threshold rsrp : 50
...    a2-Threshold rsrp : 40
...    a6-Offset rsrp : 3
...    frequencyBandList\\s\+\{\\s\+77\\s\+\}
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 77
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully

@{CA_check_CELL11_CELL1_CELL2_initial_access}
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    a1-Threshold rsrp : 50
...    a2-Threshold rsrp : 40
...    a6-Offset rsrp : 3
...    frequencyBandList\\s\+\{\\s\+77\\s\+\}
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 77
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    measId 3
...    measId 4
...    measId 5
...    measId 6
...    measId 7

@{CA_check_CELL11_CELL1_CELL2_B003_UE1_scell_addition}
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    a1-Threshold rsrp : 50
...    a2-Threshold rsrp : 40
...    frequencyBandList\\s\+\{\\s\+77\\s\+\}
...    rrcReconfigurationComplete
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully

@{fail_n78}
...    freqBandIndicatorNR 78

@{fail_n78_and_A2_B001_UE3}
...    freqBandIndicatorNR 78
...    measId 12

@{fail_n78_and_A1}
...    freqBandIndicatorNR 78
...    measId 28

@{fail_n78 and A6}
...    freqBandIndicatorNR 78
...    a6-Offset rsrp : 3
...    measId 19


@{MG_setup_with_n66}
#...    freqBandIndicatorNR 66    # no measObjectId if it already configured to UE before
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{MG_setup_with_n77}
...    freqBandIndicatorNR 77
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{MG_setup_with_n78}
...    freqBandIndicatorNR 78
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{MG_setup_with_n78_UE2_A2_setup}
...    freqBandIndicatorNR 78
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete
...    measIdToRemoveList\\s\+\{\\s\+33,\\s\+34,\\s\+28\\s\+\}

@{MG_setup_with_n78_B001_UE4}
...    freqBandIndicatorNR 78
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete
...    measIdToRemoveList\\s\+\{\\s\+13,\\s\+17,\\s\+11\\s\+\}

@{MG_setup_with_n78_UE2_B001}
...    freqBandIndicatorNR 78
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete
...    measIdToRemoveList\\s\+\{\\s\+6,\\s\+14,\\s\+11\\s\+\}

@{MG_setup_with_n78_B001_UE3UE4}
...    freqBandIndicatorNR 78
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete
...    reportConfigToRemoveList\\s\+\{\\s\+1,\\s\+\5\\s\+\}

@{MG_setup_with_n2}
...    freqBandIndicatorNR 2
# ...    freqBandIndicatorNR 78
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{MG_setup_no_reconfig}
#...    freqBandIndicatorNR 78
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{fail_n25}
...    freqBandIndicatorNR 25

@{fail_n2}
...    freqBandIndicatorNR 2,

@{MG_setup}
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{fail_n77}
...    freqBandIndicatorNR 77

@{MG_release_no_reconfig}
...    a2-Threshold rsrp : 25
...    gapUE release
...    rrcReconfigurationComplete

@{MG_release_A1_remove}
...    a2-Threshold rsrp : 25
...    gapUE release
...    rrcReconfigurationComplete
...    measIdToRemoveList\\s\+\{\\s\+8,\\s\+9,\\s\+10\\s\+\}

@{fail_n77_and_A1}
...    freqBandIndicatorNR 77
...    measIdToRemoveList\\s\+\{\\s\+4,\\s\+8,\\s\+9,\\s\+10\\s\+\}

@{MG_release_reconfig_n77_B001_UE3_after_A1}
...    a2-Threshold rsrp : 25
...    a6-Offset rsrp : 3
...    gapUE release
...    freqBandIndicatorNR 77
...    rrcReconfigurationComplete
...    reportConfigToRemoveList\\s\+\{\\s\+6,\\s\+7\\s\+\}
...    measId 11
...    measId 13
...    measId 14

@{MG_release_reconfig_n77_B001_UE4_after_A1}
...    a2-Threshold rsrp : 25
...    a6-Offset rsrp : 3
...    gapUE release
...    freqBandIndicatorNR 77
...    rrcReconfigurationComplete
...    reportConfigToRemoveList\\s\+\{\\s\+6,\\s\+7\\s\+\}
...    measId 11
...    measId 12
...    measId 13
...    measId 14

@{MG_release_reconfig_n77_B003_UE1_HO_in}
...    a2-Threshold rsrp : 25
...    a6-Offset rsrp : 3
...    gapUE release
...    freqBandIndicatorNR 77
...    rrcReconfigurationComplete
...    measId 29
...    measId 30

@{MG_release_reconfig_n77_no_A6}
...    a2-Threshold rsrp : 25
...    gapUE release
...    freqBandIndicatorNR 77
...    rrcReconfigurationComplete

@{MG_release_with_n25}
...    a2-Threshold rsrp : 25
...    gapUE release
...    freqBandIndicatorNR 25
...    rrcReconfigurationComplete

@{CA_check_CELL11_CELL3}
...    pcid:60, scellIdx:0
...    pcid:52, scellIdx:3
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 77
...    a6-Offset rsrq : 3
...    sCellIndex 3
...    physCellId 52

@{CA_check_CELL11_CELL3_UE2_after_swap}
...    pcid:60, scellIdx:0
...    pcid:52, scellIdx:3
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 77
...    a6-Offset rsrq : 3
...    sCellIndex 3
...    physCellId 52
...    measIdToRemoveList\\s\+\{\\s\+7,\\s\+4\\s\+\}

@{CA_check_CELL11_CELL3_UE4_after_swap}
...    pcid:60, scellIdx:0
...    pcid:52, scellIdx:3
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 77
...    a6-Offset rsrq : 3
...    sCellIndex 3
...    physCellId 52
...    measIdToRemoveList\\s\+\{\\s\+14,\\s\+12\\s\+\}

@{CA_check_CELL3_CELL11}
...    pcid:52, scellIdx:0
...    pcid:60, scellIdx:1
...    a2-Threshold rsrp : 25
...    a1-Threshold rsrp : 70
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 78
...    frequencyBandList\\s\+\{\\s\+78\\s\+\}
...    frequencyBandList\\s\+\{\\s\+66\\s\+\}
...    gapUE release
#...    SCellIndex 1 activated successfully

@{CA_check_CELL3_CELL11_n77}
...    pcid:52, scellIdx:0
...    pcid:60, scellIdx:1
...    a2-Threshold rsrp : 25
...    a1-Threshold rsrp : 70
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 77
...    frequencyBandList\\s\+\{\\s\+77\\s\+\}
...    frequencyBandList\\s\+\{\\s\+66\\s\+\}
...    gapUE release
#...    SCellIndex 1 activated successfully

@{CA_check_CELL11_CELL2}
...    pcid:60, scellIdx:0
...    pcid:51, scellIdx:2
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 77
...    a6-Offset rsrp : 3
...    sCellIndex 2
...    physCellId 51

@{CA_check_CELL2_CELL11}
...    pcid:51, scellIdx:0
...    pcid:60, scellIdx:1
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 78
...    a2-Threshold rsrp : 25
...    a1-Threshold rsrp : 70
#...    SCellIndex 1 activated successfully
...    a2-Threshold rsrp : 80
...    a2-Threshold rsrp : 40
...    gapUE release

@{fail_check_MG}
...    eventA1
...    gapUE setup

@{CA_check_CELL2_CELL13}
...    pcid:62, scellIdx:1
...    pcid:51, scellIdx:0
...    rrcReconfigurationComplete
...    SCellIndex 1 activated successfully
...    frequencyBandList\\s\+\{\\s\+25\\s\+\}

@{fail_A2_scell_release}
...    freqBandIndicatorNR 25
...    a2-Threshold rsrp : 40

@{rrcReconfigurationComplete}
...    rrcReconfigurationComplete

#003
@{MG_setup_with_n78_and_n77}
...    freqBandIndicatorNR 78
...    freqBandIndicatorNR 77
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{CA_check_CELL11_CELL1_CELL2_B003_UE2_scell_addition}
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    a1-Threshold rsrp : 50
...    a2-Threshold rsrp : 40
...    a6-Offset rsrp : 3
...    frequencyBandList\\s\+\{\\s\+77\\s\+\}
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 77
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    measId 6
...    measId 7
...    measId 8
...    measId 9
...    measId 10

@{CA_check_CELL11_CELL1_CELL2_B003_UE2_HO_IN}
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    a1-Threshold rsrp : 50
...    a2-Threshold rsrp : 40
...    a6-Offset rsrp : 3
...    frequencyBandList\\s\+\{\\s\+77\\s\+\}
...    rrcReconfigurationComplete
...    freqBandIndicatorNR 77
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    measId 22
...    measId 23
...    measId 24
...    measId 25
...    measId 26


@{fail_n78_and_n77_and_A6_B003_UE1_scell_addition}
#...    freqBandIndicatorNR 78
#...    freqBandIndicatorNR 77
...    a6-Offset rsrp : 3
...    measId 7
...    measId 9
...    measId 10

@{fail_n78_and_n77_and_A6_B003_UE1_after_HO_in}
#...    freqBandIndicatorNR 78
#...    freqBandIndicatorNR 77
...    a6-Offset rsrp : 3
...    measId 23
...    measId 25
...    measId 26

@{pcell_cell11}
...    pcid:60, scellIdx:0
...    a2-Threshold rsrp : 25
...    a1-Threshold rsrp : 90
...    freqBandIndicatorNR 66
...    gapUE release
...    rrcReconfigurationComplete

@{meas_id_31}
...    measId 31

@{meas_id_28}
...    measId 28

@{meas_id_47}
...    measId 47


#B006
@{MG_setup_with_n2_back}
...    freqBandIndicatorNR 2
...    a1-Threshold rsrp : 40
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{CA_check_CELL3_CELL12_CELL13}
...    pcid:62, scellIdx:2
...    pcid:61, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 66
...    freqBandIndicatorNR 25
...    eventId eventA2
...    a2-Threshold rsrp : 80
...    a2-Threshold rsrp : 40
...    measId 3
...    measId 4
...    measId 5
...    rrcReconfigurationComplete

@{MG_setup_with_n2_B06}
...    freqBandIndicatorNR 2
...    freqBandIndicatorNR 78
...    eventId eventA1
...    eventId eventA3
...    measIdToRemoveList\\s\+\{\\s\+9,\\s\+12\\s\+\}
...    gapUE setup
...    rrcReconfigurationComplete

@{HO_CA_check_CELL3_CELL12_CELL13}
...    freqBandIndicatorNR 78
...    pcid:62, scellIdx:2
...    pcid:61, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 66
...    eventId eventA2
...    a2-Threshold rsrp : 80
...    a2-Threshold rsrp : 40
...    measId 11
...    measId 12
...    measId 13
...    rrcReconfigurationComplete

@{pcell_change_to_cell12_and_scell3}
...    freqBandIndicatorNR 78
...    eventId eventA2
...    eventId eventA1
...    pcid:61, scellIdx:0
...    pcid:52, scellIdx:1
...    rrcReconfigurationComplete

@{pcell_change_to_cell13_and_scell3_UE2}
...    freqBandIndicatorNR 78
...    eventId eventA2
...    eventId eventA1
...    pcid:62, scellIdx:0
...    pcid:52, scellIdx:1
...    rrcReconfigurationComplete

@{pcell_change_to_cell3_and_scell13_UE5}
...    freqBandIndicatorNR 78
...    freqBandIndicatorNR 2
...    eventId eventA2
...    a2-Threshold rsrp : 80
...    a2-Threshold rsrp : 40
...    measId 10
...    measId 11
...    pcid:62, scellIdx:1
...    pcid:52, scellIdx:0
...    rrcReconfigurationComplete

@{HO_to_cell14}
...    freqBandIndicatorNR 78
...    eventId eventA2
...    eventId eventA1
...    pcid:63, scellIdx:0
...    pcid:52, scellIdx:1
...    rrcReconfigurationComplete

@{HO_to_cell3}
...    freqBandIndicatorNR 78
...    pcid:62, scellIdx:2
...    pcid:61, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 66
...    eventId eventA2
...    a2-Threshold rsrp : 80
...    a2-Threshold rsrp : 40
...    measId 25
...    measId 26
...    measId 27
...    rrcReconfigurationComplete

@{CA_check_CELL3_CELL13}
...    pcid:62, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 25
...    eventId eventA2
...    a2-Threshold rsrp : 40
...    measId 3
...    rrcReconfigurationComplete

@{CA_check_CELL3_CELL13_with_7219B_false}
...    pcid:62, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 25
...    eventId eventA2
...    a2-Threshold rsrp : 40
...    a2-Threshold rsrp : 80
...    measId 3
...    measId 4
...    rrcReconfigurationComplete

@{CA_check_CELL3_CELL13_with_7219B_false_UE5}
...    pcid:62, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 2
...    eventId eventA2
...    a2-Threshold rsrp : 40
...    a2-Threshold rsrp : 80
...    measId 3
...    measId 4
...    rrcReconfigurationComplete

@{CA_check_CELL3_CELL13_UE5}
...    pcid:62, scellIdx:1
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 2
...    eventId eventA2
...    a2-Threshold rsrp : 40
...    measId 3
...    rrcReconfigurationComplete

@{fail_n2_and_A2pcellchange_not_config}
...    freqBandIndicatorNR 2,
...    a2-Threshold rsrp : 80

@{fail_n25_and_A2pcellchange_not_config}
...    freqBandIndicatorNR 25
...    a2-Threshold rsrp : 80

@{pcell_change_to_cell13_and_scell3}
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 78
...    eventId eventA2
...    eventId eventA1
...    pcid:62, scellIdx:0
...    pcid:52, scellIdx:1
...    rrcReconfigurationComplete

#B007
@{CA_check_CELL12_CELL13_CELL3}
...    pcid:62, scellIdx:2
...    pcid:61, scellIdx:0
...    pcid:52, scellIdx:1
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 78
...    eventId eventA2
...    eventId eventA1
...    a1-Threshold rsrp : 50
...    a2-Threshold rsrp : 40
...    measId 2
...    measId 4
...    measId 5
...    rrcReconfigurationComplete

@{fail_A1_pcellchange_cfg}
...    freqBandIndicatorNR 2,
...    measId 3

@{CA_check_CELL12_CELL13_CELL3_UE2}
...    pcid:62, scellIdx:2
...    pcid:61, scellIdx:0
...    pcid:52, scellIdx:1
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 78
...    eventId eventA2
...    eventId eventA1
...    a1-Threshold rsrp : 50
...    a2-Threshold rsrp : 40
...    measId 2
...    measId 3
...    measId 4
...    measId 5
...    rrcReconfigurationComplete

@{A1Pcell_change_to_cell13}
...    freqBandIndicatorNR 25
...    pcid:62, scellIdx:0
...    rrcReconfigurationComplete

@{PM_Counters_Check_for_B001}
...    NRCELL-2:${SCELL_CONF_ALT_BAND_SA}=11
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=0
...    NRCELL-2:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=0
...    NRCELL-3:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=1
...    NRCELL-2:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=0
...    NRCELL-3:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=1
...    NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_1_CONF_SCELL_DL_SA}>0

@{PM_Counters_Check_for_B004}
...    NRCELL-13:${SCELL_CONF_ALT_BAND_SA}=2

@{PM_Counters_Check_for_B006}
...    NRCELL-13:${SCELL_CONF_ALT_BAND_SA}=9

@{PM_Counters_Check_for_B007}
...    NRCELL-13:${SCELL_CONF_ALT_BAND_SA}=4

@{PM_Counters_Check_for_B003}
...    NRCELL-2:${SCELL_CONF_ALT_BAND_SA}=6
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=0
...    NRCELL-2:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=0
...    NRCELL-3:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=1
...    NRCELL-2:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=0
...    NRCELL-3:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=1
...    NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_1_CONF_SCELL_DL_SA}>0

#${SCELL_CONF_ALT_BAND_SA}    M55118C01005    #This counter provides the number of current cell configurations as an SA SCell in an alternative band
${SCELL_CONF_ALT_BAND_SA}    M55316C00041    #This counter provides the number of current cell configurations as an SA SCell in an alternative band
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501    #The number of radio admission requests for SA user where admission is requested on the alter band.
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502    #Number of admitted radio admission requests for SA user where admission is done on the alter band.
${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503    #Number of radio admission HO requests for SA user where admission is requested on the alter band.
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504    #Number of SA user-admitted HO radio admissions where admission is done on alternative band.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001    #The number of radio admission requests with MFBI for SA user.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002    #The number of radio admitted UEs for SA user using alternative band.
${GNB_SA_DU_HO_ADMISS_MFBI_REQ}    M55139C02005    #Number of radio admission handover requests on alternative band for SA users.
${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}    M55139C02006    #Number of radio-admitted handover radio resources on alternative band for SA users.
${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}    M55139C02007    #Number of intra DU radio resource modification requests on alternative band for SA users.
${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}    M55139C02008    #Number of successful intra DU radio resource modifications on alternative band for SA users.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002    #Sum of CA UEs in the current cell configured as an SCell with 2 configured SCells in DL.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508    #Sum of CA UEs in the current cell configured as an SCell with 1 configured SCells in DL.

${N66_N77_N77_and_N66_N77_and_N66_N78_and_N77EUSA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C00E787882001C4C000000160205E1E1280071340000085808178B882001C4C000E260000020B0102F17060003830001C18000006
...    160205E1E14000713400002058081707850001C4100000A160205E1E20800711800003058081787882001C4D00000E160205E2E140007104
...    0038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E23
...    00071340000605808178F830001C41000E23000713000006858081007011A014404D80822E8415E0E851226C73E1C28913639F0E24489136
...    39F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E2448913639F0E2448913639F0E2448913639
...    F0E14489B1CF871A2448913639F0C2A1C318C6318C6318C63180603F7FFFFE17001E00140E0A00E0601280380030120020301F01C0100000
...    0008000010040000100200000C01000008008000050040000300200001C076065654564C5646D60CD60C5606D654D01C1000009652504000
...    065949410000296525040000E594941000049652504000165949410000696525040001E5949407503AAA555549AAA91E5506CAA0D5540F2A
...    95650B0024006814001A1010020040401002080804008020080108040080101004008040100210080700E0201C038080700E10100600C040
...    1002080802004020040084040200401002004202004008080200420100400804008010100200440200801008010020200400880400801010
...    020040400801100801002020040080801002101002004040100218180600D00A0140C008018010020600400C0080103010022008010D50F8
...    000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${N66_N77_N77_and_N66_N77_and_N77EUSA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C00E787882001C4C000000160205E1E1280071300000085808178B882001C4C000E260000020B0102F17060003830001C18000006
...    160205E1E14000713000002058081707850001C4100000A160205E1E20800711800003058081787882001C4C00000E160205E2E140007104
...    0038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E23
...    00071300000605808178F830001C41000E23000713000006858081007011A014404D80822E8415E0E851226C73E1C28913639F0E24489136
...    39F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E2448913639F0E2448913639F0E2448913639
...    F0E14489B1CF871A2448913639F0C2A1C318C6318C6318C63180603F7FFFFE17001E00140E0A00E0601280380030120020301F01C0100000
...    0008000010040000100200000C01000008008000050040000300200001C076065654564C5646D60CD60C5606D654D01C1000009652504000
...    065949410000296525040000E594941000049652504000165949410000696525040001E5949407503AAA555549AAA91E5506CAA0D5540F2A
...    95650B0024006814001A1010020040401002080804008020080108040080101004008040100210080700E0201C038080700E10100600C040
...    1002080802004020040084040200401002004202004008080200420100400804008010100200440200801008010020200400880400801010
...    020040400801100801002020040080801002101002004040100218180600D00A0140C008018010020600400C0080103010022008010D50F8
...    000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${N2_N77_and_N25_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B007582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C00E787802001C4C000000160205E1E1280071340000085808178B882001C4C000E260000020B0102F17060003830001C18000006
...    160205E1E14000713400002058081707850001C4100000A160205E1E20800711800003058081787830001C4D00000E160205E2E140007104
...    0038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E23
...    00071340000605808178F830001C41000E23000713000006858081007011A014404D80822E8415E0E851226C73E1C28913639F0E24489136
...    39F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E2448913639F0E2448913639F0E2448913639
...    F0E14489B1CF871A2448913639F0C2A1C318C6318C6318C63180603F7FFFFE17001E00140E0A00E0601280380030120020301F01C0100000
...    0008000010040000100200000C01000008008000050040000300200001C076065654564C5646D60CD60C5606D654D01C1000009652504000
...    065949410000296525040000E594941000049652504000165949410000696525040001E5949407503AAA555549AAA91E5506CAA0D5540F2A
...    95650B0024006814001A1010020040401002080804008020080108040080101004008040100210080700E0201C038080700E10100600C040
...    1002080802004020040084040200401002004202004008080200420100400804008010100200440200801008010020200400880400801010
...    020040400801100801002020040080801002101002004040100218180600D00A0140C008018010020600400C0080103010022008010D50F8
...    000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${N2_N66_and_N2_N78_and_N25_N66_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B007582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C003787802001C4D000000160205E1E2080070040000305808178B89A001C41000E0C0000080B010200E0234028809B01045D0809
...    C070A244D8E7C3851226C73E1C4891226C73E181C0C63180C07EFFFFFC2E003C00281C1401C0C02500700060240040603E03802000000010
...    0000200800002004000018020000100100000A008000060040000380EC0CACA8AC98AC8DAC19AC18AC0DACA9A0382000012CA4A080000CB2
...    9282000052CA4A080001CB29282000092CA4A080002CB292820000D2CA4A080003CB29280EA07554AAAA9355523CAA0D9541AAA81E552ACA
...    16004800D02800342020040080802004101008010040100210080100202008010080200420100E01C04038070100E01C20200C0180802004
...    1010040080400801080804008020040084040080101004008402008010080100202004008804010020100200404008011008010020200400
...    80801002201002004040080101002004202004008080200430300C01A01402818010030020040C0080180100206020044010021AA1F00010
...    2030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

${N25_N66_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B007582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C003787882001C4D000000160205E1E2080071040000305808178B89A001C41000E0C0000080B010200E0234028809B01045D0809
...    C070A244D8E7C3851226C73E1C4891226C73E181C0C63180C07EFFFFFC2E003C00281C1401C0C02500700060240040603E03802000000010
...    0000200800002004000018020000100100000A008000060040000380EC0CACA8AC98AC8DAC19AC18AC0DACA9A0382000012CA4A080000CB2
...    9282000052CA4A080001CB29282000092CA4A080002CB292820000D2CA4A080003CB29280EA07554AAAA9355523CAA0D9541AAA81E552ACA
...    16004800D02800342020040080802004101008010040100210080100202008010080200420100E01C04038070100E01C20200C0180802004
...    1010040080400801080804008020040084040080101004008402008010080100202004008804010020100200404008011008010020200400
...    80801002201002004040080101002004202004008080200430300C01A01402818010030020040C0080180100206020044010021AA1F00010
...    2030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

${N2_N66_and_N2_N78_and_N25_N66_N78_noN2UL}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B007582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C0037870020713400000058081787882001801000305808178B89A001C41000E0C0000080B010200E0234028809B01045D0809C07
...    0A244D8E7C3851226C73E1C4891226C73E181C0C63180C07EFFFFFC2E003C00281C1401C0C02500700060240040603E03802000000010000
...    0200800002004000018020000100100000A008000060040000380EC0CACA8AC98AC8DAC19AC18AC0DACA9A0382000012CA4A080000CB2928
...    2000052CA4A080001CB29282000092CA4A080002CB292820000D2CA4A080003CB29280EA07554AAAA9355523CAA0D9541AAA81E552ACA160
...    04800D02800342020040000802004101008010040100210080100202008010080200420100E01C04038070100E01C20200C0180802004101
...    0040080400801080804008020040004040080101004008402008010080100202004008804010020100200404008011008010020200400808
...    01002201002004040080101002004202004008080200430300C01A01402818010030020040C0080180100206020044010021AA1F00010203
...    0406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${N2_N78_and_N25_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B007582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C003787802001C4D000000160205E1E2080070040000085808178789A001C1800000416020401C046805101360208BA101380E144
...    89B1CF870A244D8E7C3851226C73E18003818C630180FDFFFFF85C0078005038280381804A00E000C0480080C07C07004000000020000040
...    100000400800003004000020020000140100000C0080000701D81959515931591B58135831581B5953407040000259494100001965250400
...    00A594941000039652504000125949410000596525040001A594941000079652501D40EAA9555526AAA479540B2A8355503CAA55942C0090
...    01A05000104040280501010020202010020080100210101002004038071AA1F000102030406070A0B0C0D101112131418191B1C1D1F21252
...    62728292A2D2F414182D

${N2_N78_and_N25_N78_noN2UL}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B007582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C0037870020713400000058081787882001801000085808178789A001C1800000416020401C046805101360208BA101380E14489B
...    1CF870A244D8E7C3851226C73E18003818C630180FDFFFFF85C0078005038280381804A00E000C0480080C07C07004000000020000040100
...    000400800003004000020020000140100000C0080000701D81959515931591B58135831581B595340704000025949410000196525040000A
...    594941000039652504000125949410000596525040001A594941000079652501D40EAA9555526AAA479540B2A8355503CAA55942C009001A
...    05000104040380001010020202010020080100010101002004038071AA1F000102030406070A0B0C0D101112131418191B1C1D1F21252627
...    28292A2D2F414182D0

*** Test Cases ***
CB007219-ET-B001_SA_Interaction_with_inter-frequency_mobility_with_A2_for_mobility_received_when_SCell_is_configured
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when the feature activation flag of CB007219-B is modified online.
    ...    USCB007219-B#B5
    ...    This user scenario describes the gNB behaviour when inter-frequency mobility has to be configured on an MFBI SCell
    ...    configured in alternative band or vice versa.
    ...    USCB007219-B#B11.2(UE3)
    ...    USCB007219-B#B11(UE2)
    ...    USCB007219-B#B11.4(UE2)
    ...    This user scenario describes the gNB behavior when A2 measurement report for mobility is received when a UE is
    ...    configured CA with at least one MFBI SCell is configured on alternative band and an inter-frequency target cell
    ...    configured with native band exists which shares the same frequency of SCell configured with alternative band
    ...    USCB007219-B#B1.2(UE3/UE4)
    ...    USCB007219-B#B1(UE2)
    ...    USCB007219-B#B1.1(UE5)
    ...    USCB007219-B#B1.1.1(UE5)
    ...    2. Configuration
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true", 7219-B: NRBTS/actMfbiNrCaMeasConfResolv=false
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    CNI-75210:NRBTS.actExtN77Support=true
    ...    NRBTS/actBcsCheck is disabled.
    ...    PCell: NRCELL-11, N66, 20MHz
    ...    SCell1: NRCELL-1, N77EUSA, 40MHz
    ...    SCell2: NRCELL-2, N78/N77, 40MHz
    ...    SCell3: NRCELL-3, N78/N77, 40MHz, the frequency is the same as NRCELL-2, but NRCELL-2 has higher priority.
    ...    UE1/2/3/4: cell11+cell1+cell2+cell3, A1 scell addition. supports lower extended band 77 in USA.
    ...    BC#1 : N66A_N77(2A)
    ...    BC#2 : N66A_N77A
    ...    BC#3 : N66A_N78A
    ...    UE5: cell11+cell1+cell2, A1 scell addition. supports lower extended band 77 in USA.
    ...    BC#1 : N66A_N77(2A)
    ...    BC#2 : N66A_N77A
    ...    3. Test Case Steps:
    ...    a. attach UE1/2/3/4 to cell11 and trigger A1 for scell addition.
    ...    expected: cell1 and cell2 are added as scells and BC#1 is selected. A2 for inter-freq HO is configured with n66.
    ...    for scell1: A2 for scell release, A1 for pcell switch is configured with n77.
    ...    for scell2, A2 for scell release, A1 for pcell switch, A6 for swap is configured with n77.
    ...    b. trigger A2 for MG setup for UE1 and UE2.
    ...    expected: MG setup successfully. A3 is still configured with n77 for scell1 and scell2. A2 mobility is removed. A1 mobility configured.
    ...    c. online enable NRBTS/actMfbiNrCaMeasConfResolv = true, trigger A2 for MG setup for UE3 and UE4.
    ...    expected: MG sutup. A3 is reconfigured with n78 for scell2. A2/A1/A6 are released for scell2.
    ...    A2 mobility is removed. A1 mobility configured. scell1 measurement configuration unchanged.
    ...    d. trigger A1 mobility for UE1 and UE3.
    ...    expected: for UE1 and UE3, A3/A1 removed. A2 mobiltiy configured. MG release.
    ...    for UE1: CA related measurement configuration unchanged for scell1 and scell2. A1 for pcell switch is remained with n77.
    ...    but A1 for pcell switch will be ingored when A1 is triggered.
    ...    for UE3: A2 for scell release, A6 for swap is configured with n77 for scell2, no A1 for pcell switch is configured for scell2.
    ...    scell1 unchanged.
    ...    e. trigger scell release for UE1 and UE3.
    ...    expected: scell release successfully. only A2 mobility is remained.
    ...    f. online disable NRBTS/actMfbiNrCaMeasConfResolv = false, trigger A1 for UE2 and UE4.
    ...    expected: for UE2 and UE4, A3/A1 removed. A2 mobiltiy configured. MG release.
    ...    for UE2: CA related measurement configuration unchanged for scell1 and scell2.
    ...    for UE4: A2 for scell release, A6 for swap and A1 for pcell switch is configured with n77 for scell2.
    ...    scell1 unchanged.
    ...    g. online enable NRBTS/actMfbiNrCaMeasConfResolv =true. triggier scell swap for UE2 and UE4 and swap back.
    ...    expected: scell swap successfully. A1 for pcell switch for scell2 will be removed for UE2 and UE4.
    ...    h. trigger A2 for MG settup for UE2. then online disable scell swap on cell2 NRBTS/NRCELL/ a6MeasSCellSwapEnabled = false.
    ...    expected: MG setup. A3 configured with n78. A1 mobility configured, A2 mobility is removed. A2/A1/A6 are released for scell2.
    ...    i. trigger A1 for UE2. and online enable scell swap on cell2.
    ...    expected: MG released. A1/A3 removed. A2 mobility configured. A2 for scell release is configured for scell2 with n77.
    ...    no A1 for pcell switch and A6 for scell swap configured for scell2. scell1 unchanged.
    ...    j. trigger inter freq A3 HO for UE2 and UE4 to scell2 and meet the condition to add scell.
    ...    expected: pcell change to cell2 successfully. cell11 is added as scell with BC#3. A2 for pcell change is configured with n78.
    ...    k. trigger A2 pcell change for UE2 and UE4 to cell11 and meet the condition to add scell.
    ...    expected: pcell change to cell11 successfully. cell1 and cell2 are added scells. BC#1 is selected. A2 for inter-freq HO is configured.
    ...    for scell1: A2/A1 is configured.
    ...    for scell2: A2/A6 is configured. no A1 for pcell switch.
    ...    l. trigger A2 for MG setup for UE2.
    ...    expected: MG setup. A3 is reconfigured with n78. A1 mobility is configured. A2/A6 is removed for scell2. scell1 unchanged.
    ...    m. trigger A3 for UE2 to cell3 and meet the condition for scell addition.
    ...    expected: HO to cell3 successfully. cell11 is added as scell with BC#3. A2 for mobility and A2 for pcell change is configured with n78.
    ...    n. HO back to cell11 and meet the condition for scell addition.
    ...    expected: cell1 and cell2 are added scells. BC#1 is selected. A2 for inter-freq HO is configured.
    ...    for scell1: A2/A1 is configured.
    ...    for scell2: A2/A6 is configured. no A1 for pcell switch.
    ...    o. attach UE5 to cell11 and trigger A1 for scell addition.
    ...    expected: cell1 and cell2 are added as scells and BC#1 is selected. A2 for inter-freq HO is configured with n66.
    ...    for scell1: A2 for scell release, A1 for pcell switch is configured with n77.
    ...    for scell2: A2 for scell release, A1 for pcell switch, A6 for swap is configured with n77.
    ...    p. trigger A2 for MG setup.
    ...    expected: A3 is configured with n77. A1 mobility is configured. A2 is removed. measurement for scell1 and scell2 unchanged.
    ...    q. trigger scell release for UE5.
    ...    expected: scell release successfully.
    ...    r. trigger A3 HO to cell3.
    ...    expected: HO to cell3 successfully. cell11 is added as scell with BC#2. A2 for mobility and A2 for pcell change is configured with n77.
    ...    s. HO back to cell11.
    ...    expected:cell1 and cell2 are added as scells and BC#1 is selected. A2 for inter-freq HO is configured with n66.
    ...    for scell1: A2 for scell release, A1 for pcell switch is configured with n77.
    ...    for scell2, A2 for scell release, A1 for pcell switch, A6 for swap is configured with n77.
    ...    t. online remove NRHOIF for scell3 and NRHOIF.nrConnectModeProfileDN for scell2. and trigger A2 for MG setup for UE5.
    ...    expected: no MG setup. A2 is removed. and no A1 is configured.
    ...    u.check counters.
    [Tags]    QC_46818    jiadan.wu    B001    CA_LABEL-FTT(20MHZ_FDD_n66+40MHZ_TDD_n77+40MHZ_TDD_n77)    CA_LABEL-TF(40MHZ_TDD_n78+20MHZ_FDD_n66)
    ...    CA_LABEL-TF(40MHZ_TDD_n77+20MHZ_FDD_n66)
    Clear Counter Files    wait=${False}
    UE1UE2UE3UE4 attach and Scell addition with 7219-B disabled
    Trigger A2 measurement report for UE1UE2 with 7219-B disabled
    Online enable 7219-B and trigger A2 for UE3UE4 and A1 for UE1UE3
    Trigger A2 ScellRelease for UE1UE3
    Online disable 7219-B and trigger A1 for UE2UE4
    Online enable 7219-B and trigger A6 for UE2UE4
    UE2 SCell swap with online change
    Trigger A3 HO or A2 PCell Change for UE2UE4
    Trigger inter-freq for UE2
    UE5 Scell addition Release and HO
    check counters    pm_counters_expression=${PM_Counters_Check_for_B001}
    [Teardown]    B001_Teardown

CB007219-ET-B004_Interaction_with_data_activity_aware_NR_SCell_addition_and_release
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when data activity triggered SCell addition in an alternative happens when
    ...    inter-frequency mobility measurements are already configured.
    ...    2. Configuration
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true", 7219-B: NRBTS/actMfbiNrCaMeasConfResolv=false
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    PCell: NRCELL-2, TDD, N78/N77, 40MHz, DL MIMO Layers 4L
    ...    SCell: NRCELL-13, FDD, N2/N25, 20MHz, DL MIMO Layers 4L
    ...    UE capability: cell2+cell13, bufferbased A1.
    ...    BC#1: n2A_n77A
    ...    BC#2: n25A_n78A
    ...    3. Test Case Steps:
    ...    a. attach UE to cell2 with n78.
    ...    b. trigger A2 for MG setup with object n2.
    ...    c. online enable 7219-B#.
    ...    d. trigger scell addition. scell is added with n25. measurement object still keeps as n2. no A2 for scell release configured.
    ...    (When SCells are to be added in a band different than already configured inter-frequency mobility measurements on the same frequency,
    ...    then A2/A6 measurements on SCell will not be configured on those SCells)
    ...    e. decrease traffic to release scell. A1 for scell addition is configured.
    ...    f. trigger A1 mobility. measurement object still keeps as n2. no A2 for scell release configured.
    ...    g. trigger A2 for MG setup with object n2.
    ...    h. trigger A1 for scell addition. scell is added with n25. measurement object still keeps as n2. no A2 for scell release configured.
    ...    i. trigger A1 for mobility. measurement object reconfigured with n25. (frequency now in n25 which scell added,
    ...    then A2/A6 measurements on SCell can be configured on those SCells)
    ...    A2 for scell release configured.
    ...    j. trigger A2 for scell release.
    [Tags]    QC_344434    jiadan.wu    B004    CA_LABEL-TF(40MHZ_TDD_n78+20MHZ_FDD_n25)    not-ready
    Clear Counter Files
    OnlineParamChange    ${B004_online_enable_8311}
    UE attach and A2 mobility online enable 7219-B then scell addition
    UE decrease traffic to scell release and trigger A1 then A2 mobility then scell addition
    Trigger A1 mobility and scell release
    check counters    pm_counters_expression=${PM_Counters_Check_for_B004}
    [Teardown]    B004_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_2N66_3N78_N38    ue_count=15

B001_Teardown
    OnlineParamChange    ${B001_recovery}
    Common Test Teardown And Stop Capture Logs

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE1UE2UE3UE4 attach and Scell addition with 7219-B disabled
    UE1UE2UE3UE4 attach and check traffic with 7219-B disabled
    UE1UE2UE3UE4 SCell addition and check traffic with 7219-B disabled

UE1UE2UE3UE4 attach and check traffic with 7219-B disabled
    Ue register and pdu session setup    ${N66_N77_N77_and_N66_N77_and_N66_N78_and_N77EUSA}    ue_id=81    cell_id=11
    Ue register and pdu session setup    ${N66_N77_N77_and_N66_N77_and_N66_N78_and_N77EUSA}    ue_id=82    cell_id=11
    Ue register and pdu session setup    ${N66_N77_N77_and_N66_N77_and_N66_N78_and_N77EUSA}    ue_id=83    cell_id=11
    Ue register and pdu session setup    ${N66_N77_N77_and_N66_N77_and_N66_N78_and_N77EUSA}    ue_id=84    cell_id=11
    UE1UE2UE3UE4 check traffic for Pcell

UE1UE2UE3UE4 check traffic for Pcell
    Send Throughput    ue_id=81    times=6
    Send Throughput    ue_id=82    times=6
    Send Throughput    ue_id=83    times=6
    Send Throughput    ue_id=84    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=35    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=1    min_dl_tput=35    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=1    min_dl_tput=35    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=84    cell_num=1    min_dl_tput=35    min_ul_tput=8

UE1UE2UE3UE4 SCell addition and check traffic with 7219-B disabled
    Trigger MR scelladd    ${CA_check_CELL11_CELL1_CELL2_initial_access}    ue_id=81    carrierfreq=424090    srsrp_nr=100    fail_check=${fail_n78}
    ...    threshold=90
    Trigger MR scelladd    ${CA_check_CELL11_CELL1_CELL2_initial_access}    ue_id=82    carrierfreq=424090    srsrp_nr=100    fail_check=${fail_n78}
    ...    threshold=90
    Trigger MR scelladd    ${CA_check_CELL11_CELL1_CELL2_initial_access}    ue_id=83    carrierfreq=424090    srsrp_nr=100    fail_check=${fail_n78}
    ...    threshold=90
    Trigger MR scelladd    ${CA_check_CELL11_CELL1_CELL2_initial_access}    ue_id=84    carrierfreq=424090    srsrp_nr=100    fail_check=${fail_n78}
    ...    threshold=90
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=135    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=135    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=3    min_dl_tput=135    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=84    cell_num=3    min_dl_tput=135    min_ul_tput=8

Trigger A2 measurement report for UE1UE2 with 7219-B disabled
    @{no_measobject}    create list    MeasObjectToAddMod
    Trigger A2 measurement report    ue_id=81    carrierfreq=424090    pass_check=${MG_setup_with_n66}    fail_check=${no_measobject}
    Trigger A2 measurement report    ue_id=82    carrierfreq=424090    pass_check=${MG_setup_with_n66}    fail_check=${no_measobject}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=110    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=110    min_ul_tput=8

Online enable 7219-B and trigger A2 for UE3UE4 and A1 for UE1UE3
    OnlineParamChange    ${7219-B_true}
    Trigger A2 measurement report    ue_id=83    carrierfreq=424090    pass_check=${MG_setup_with_n78_B001_UE3UE4}    fail_check=${fail_n77}
    Trigger A2 measurement report    ue_id=84    carrierfreq=424090    pass_check=${MG_setup_with_n78_B001_UE3UE4}    fail_check=${fail_n77}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=3    min_dl_tput=100    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=84    cell_num=3    min_dl_tput=100    min_ul_tput=8
    Trigger A1 measurement report    ue_id=81    carrierfreq=424090    pass_check=${MG_release_A1_remove}    fail_check=${fail_n77_and_A1}
    Trigger A1 measurement report    ue_id=83    carrierfreq=424090    pass_check=${MG_release_reconfig_n77_B001_UE3_after_A1}
    ...    fail_check=${fail_n78_and_A2_B001_UE3}
    Trigger A1 or A2 PCell Change with fail regexp    ue_id=81    carrierfreq=640416    scell_id=2    event_type=A1
    ...    threshold=80    pass_check=measurementReport    fail_check=rrcReconfigurationComplete
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=100    min_ul_tput=8
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=3    min_dl_tput=100    min_ul_tput=8

Trigger A2 ScellRelease for UE1UE3
    Trigger A2 ScellRelease    carrierfreq=640416    ue_id=81    scell_id=2
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=85    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=632736    ue_id=81    scell_id=1
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=35    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=640416    ue_id=83    scell_id=2
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=2    min_dl_tput=85    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=632736    ue_id=83    scell_id=1
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=1    min_dl_tput=35    min_ul_tput=8

Online disable 7219-B and trigger A1 for UE2UE4
    OnlineParamChange    ${7219-B_false}
    Trigger A1 measurement report    ue_id=82    carrierfreq=424090    pass_check=${MG_release_no_reconfig}    fail_check=${fail_n77}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=135    min_ul_tput=8
    Trigger A1 measurement report    ue_id=84    carrierfreq=424090    pass_check=${MG_release_reconfig_n77_B001_UE4_after_A1}
    ...    fail_check=${fail_n78}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=84    cell_num=3    min_dl_tput=135    min_ul_tput=8

Online enable 7219-B and trigger A6 for UE2UE4
    OnlineParamChange    ${7219-B_true}
    Trigger ScellSwap Success    ue_id=82     phycell_id=52    pass_check=${CA_check_CELL11_CELL3_UE2_after_swap}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After Scell Swap    ue_id=82    total_dl_tput=135    ul=8    scell_id=3
    Trigger ScellSwap Success    ue_id=82     phycell_id=51    scell_id=3    pass_check=${CA_check_CELL11_CELL2}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=135    min_ul_tput=8
    Trigger ScellSwap Success    ue_id=84     phycell_id=52    pass_check=${CA_check_CELL11_CELL3_UE4_after_swap}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After Scell Swap    ue_id=84    total_dl_tput=135    ul=8    scell_id=3
    Trigger ScellSwap Success    ue_id=84     phycell_id=51    scell_id=3    pass_check=${CA_check_CELL11_CELL2}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=84    cell_num=3    min_dl_tput=135    min_ul_tput=8

UE2 SCell swap with online change
    Trigger A2 measurement report    ue_id=82    carrierfreq=424090    pass_check=${MG_setup_with_n78_UE2_B001}    fail_check=${fail_n77}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=135    min_ul_tput=8
    OnlineParamChange    ${online_disable_cell2_scell_swap}
    Trigger A1 measurement report    ue_id=82    carrierfreq=424090    pass_check=${MG_release_reconfig_n77_no_A6}    fail_check=${fail_n78 and A6}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=135    min_ul_tput=8
    OnlineParamChange    ${online_enable_cell2_scell_swap}

Trigger A3 HO or A2 PCell Change for UE2UE4
    Trigger A2 measurement report    ue_id=82    carrierfreq=424090    pass_check=${MG_setup_with_n78}    fail_check=${fail_n77}
    Trigger A3 Measurement Report    ue_id=82    carrierfreq=640416    phycelId=51    pass_check=${CA_check_CELL2_CELL11}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=2    min_dl_tput=85    min_ul_tput=8
    Trigger A2 measurement report    ue_id=84    carrierfreq=424090    pass_check=${MG_setup_with_n78_B001_UE4}    fail_check=${fail_n77}
    Trigger A3 Measurement Report    ue_id=84    carrierfreq=640416    phycelId=51    pass_check=${CA_check_CELL2_CELL11}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=84    cell_num=2    min_dl_tput=85    min_ul_tput=8
    Trigger A1 or A2 PCell Change with error check    ue_id=82    carrierfreq=640416    scell_id=1    event_type=A2
    ...    threshold=80    pass_check=${CA_check_CELL11_CELL1_CELL2}    fail_check=${meas_id_31}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=135    min_ul_tput=8
    Trigger A1 or A2 PCell Change with error check    ue_id=84    carrierfreq=640416    scell_id=1    event_type=A2
    ...    threshold=80    pass_check=${CA_check_CELL11_CELL1_CELL2}    fail_check=${meas_id_28}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=84    cell_num=3    min_dl_tput=135    min_ul_tput=8

Trigger inter-freq for UE2
    Trigger A2 measurement report    ue_id=82    carrierfreq=424090    pass_check=${MG_setup_with_n78_UE2_A2_setup}    fail_check=${fail_n77}
    Trigger A3 Measurement Report    ue_id=82    carrierfreq=640416    phycelId=52    pass_check=${CA_check_CELL3_CELL11}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=2    min_dl_tput=85    min_ul_tput=8
    Trigger A2 measurement report    ue_id=82    carrierfreq=640416    pass_check=${MG_setup}    fail_check=${fail_n77}
    Trigger A3 Measurement Report with fail check    ue_id=82    carrierfreq=424090    phycelId=60    pass_check=${CA_check_CELL11_CELL1_CELL2}
    ...    fail_check=${meas_id_47}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=135    min_ul_tput=8
    Release Ues    ue_type=all

UE5 Scell addition Release and HO
    UE5 attach and scell addition then trigger A2
    UE5 SCell release and HO
    OnlineParamChange    ${online_delete_NRHOIF_cell3_alter_band}
    Trigger A2 measurement report but no MG setup    ue_id=85    carrierfreq=424090    fail_check=${fail_check_MG}

UE5 attach and scell addition then trigger A2
    Ue register and pdu session setup    ${N66_N77_N77_and_N66_N77_and_N77EUSA}    ue_id=85    cell_id=11
    Send Throughput    ue_id=85    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=1    min_dl_tput=140    min_ul_tput=8
    Trigger MR scelladd    ${CA_check_CELL11_CELL1_CELL2_initial_access}    ue_id=85    carrierfreq=424090    srsrp_nr=100    fail_check=${fail_n78}
    ...    threshold=90
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Trigger A2 measurement report    ue_id=85    carrierfreq=424090    pass_check=${MG_setup}    fail_check=${fail_n78}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=3    min_dl_tput=400    min_ul_tput=8

UE5 SCell release and HO
    Trigger A2 ScellRelease    carrierfreq=640416    ue_id=85    scell_id=2
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=2    min_dl_tput=250    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=632736    ue_id=85    scell_id=1
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=1    min_dl_tput=140    min_ul_tput=8
    Trigger A3 Measurement Report    ue_id=85    carrierfreq=640416    phycelId=52    pass_check=${CA_check_CELL3_CELL11_n77}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=2    min_dl_tput=200    min_ul_tput=8
    Trigger A2 measurement report    ue_id=85    carrierfreq=640416    pass_check=${MG_setup}    fail_check=${fail_n78}
    Trigger A3 Measurement Report    ue_id=85    carrierfreq=424090    phycelId=60    pass_check=${CA_check_CELL11_CELL1_CELL2}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=3    min_dl_tput=450    min_ul_tput=8

Trigger ScellSwap Success
    [Arguments]    ${event_type}=A6    ${carrierfreq}=640416    ${nrsrp_nr}=63    ${nrsrq_nr}=63    ${ue_id}=81    ${scell_id}=2
    ...    ${phycell_id}=52    ${pass_check}=${EMPTY}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}

Check Traffic After Scell Swap
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=135    ${ul}=8    ${scell_id}=3
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 0
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell0_tput}+${scell1_tput}+${scell3_tput}
    Should Be True     ${total_dl}/1000 > ${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Trigger A1 or A2 PCell Change with error check
    [Arguments]    ${event_type}=A1    ${carrierfreq}=640416    ${scell_rsrp}=100    ${scell_rsrq}=100    ${ue_id}=81
    ...    ${scell_id}=2    ${pass_check}=rrcReconfigurationComplete    ${threshold}=50    ${fail_check}=none
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    ${ret}    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}
    should not contain any    ${ret}    @{fail_check}

Trigger A1 or A2 PCell Change with fail regexp
    [Arguments]    ${event_type}=A1    ${carrierfreq}=640416    ${scell_rsrp}=100    ${scell_rsrq}=100    ${ue_id}=81
    ...    ${scell_id}=2    ${pass_check}=rrcReconfigurationComplete    ${threshold}=50    ${fail_check}=none
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}    fail_regexp=${fail_check}

Trigger A1 or A2 PCell Change
    [Arguments]    ${event_type}=A1    ${carrierfreq}=640416    ${scell_rsrp}=100    ${scell_rsrq}=100    ${ue_id}=81
    ...    ${scell_id}=2    ${pass_check}=rrcReconfigurationComplete    ${threshold}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}

Ue register and pdu session setup
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=1    ${cell_id}=2    ${gw_id}=1
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gw_id}    pass_regexp=QoS Routing Table

Trigger MR scelladd
    [Arguments]    ${scell_added_log}    ${fail_check}    ${ue_id}=81    ${carrierfreq}=650016    ${srsrp_nr}=100    ${threshold}=70
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ...    threshold=${threshold}
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=52
    ...    pass_regexp=${scell_added_log}
    should not contain any    ${ret}    @{fail_check}

Trigger MR scelladd with fail regexp
    [Arguments]    ${scell_added_log}    ${fail_check}    ${ue_id}=81    ${carrierfreq}=650016    ${srsrp_nr}=100    ${threshold}=70
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ...    threshold=${threshold}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=52
    ...    pass_regexp=${scell_added_log}    fail_regexp=${fail_check}

Trigger A2 ScellRelease
    [Arguments]    ${carrierfreq}=508110    ${ue_id}=81    ${scell_id}=3
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=rrcReconfigurationComplete


Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    2    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=1    ${min_dl_tput}=20    ${min_ul_tput}=8
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
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


Trigger A2 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${fail_check}    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=10 srsrq_nr=10
    ...    pass_regexp=${pass_check}
    should not contain any    ${ret}    @{fail_check}

Trigger A2 measurement report but no MG setup
    [Arguments]    ${ue_id}    ${carrierfreq}    ${fail_check}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=10 srsrq_nr=10
    ...    pass_regexp=rrcReconfigurationComplete
    should not contain any    ${ret}    @{fail_check}

Trigger A1 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${fail_check}    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=${pass_check}
    should not contain any    ${ret}    @{fail_check}


Trigger A3 Measurement Report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}    ${pass_check}    ${nrsrp_nr}=100    ${nrsrq_nr}=100
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${V3}    pass_regexp=${pass_check}

Trigger A3 Measurement Report with fail check
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}    ${pass_check}    ${nrsrp_nr}=100    ${nrsrq_nr}=100    ${fail_check}=none
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret}    Execute Egate Command    ${V3}    pass_regexp=${pass_check}
    should not contain any    ${ret}    @{fail_check}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

B004_Teardown
    OnlineParamChange    ${B004_recovery}
    Common Test Teardown And Stop Capture Logs

UE attach and A2 mobility online enable 7219-B then scell addition
    Ue register and pdu session setup    ${N2_N77_and_N25_N78}    ue_id=81    cell_id=2
    Trigger A2 measurement report    ue_id=81    carrierfreq=640416    pass_check=${MG_setup_with_n2}    fail_check=${fail_n25}
    OnlineParamChange    ${7219-B_true}
    Send Throughput    ue_id=81    times=3    mbps=120
    Trigger MR scelladd with fail regexp    measurementReport    ue_id=81    carrierfreq=640416    srsrp_nr=100
    ...    fail_check=${rrcReconfigurationComplete}
    ${ret}    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    pass_regexp=${CA_check_CELL2_CELL13}
    should not contain any    ${ret}    @{fail_A2_scell_release}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=240    min_ul_tput=8

UE decrease traffic to scell release and trigger A1 then A2 mobility then scell addition
    Execute Egate Command    trf_data_stop ue=81 dir=dl pdu=1    pass_regexp=a1-Threshold
    Trigger A1 measurement report    ue_id=81    carrierfreq=640416    pass_check=${MG_release_no_reconfig}    fail_check=${fail_A2_scell_release}
    Trigger A2 measurement report    ue_id=81    carrierfreq=640416    pass_check=${MG_setup_no_reconfig}    fail_check=${fail_n25}
    Send Throughput    ue_id=81    times=3    mbps=120
    Trigger MR scelladd with fail regexp    measurementReport    ue_id=81    carrierfreq=640416    srsrp_nr=100
    ...    fail_check=${rrcReconfigurationComplete}
    ${ret}    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    pass_regexp=${CA_check_CELL2_CELL13}
    should not contain any    ${ret}    @{fail_A2_scell_release}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=240    min_ul_tput=8

Trigger A1 mobility and scell release
    Trigger A1 measurement report    ue_id=81    carrierfreq=640416    pass_check=${MG_release_with_n25}    fail_check=${fail_n2}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=240    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=391450    ue_id=81    scell_id=1
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=210    min_ul_tput=8

B003_Teardown
    OnlineParamChange    ${7219-B_false}
    Common Test Teardown And Stop Capture Logs

UE1 attach then trigger A2 mobility then scell addition with 7219 enabled
    OnlineParamChange    ${7219-B_true}
    Ue register and pdu session setup    ${N66_N77_N77_and_N66_N77_and_N66_N78_and_N77EUSA}    ue_id=81    cell_id=11
    Send Throughput    ue_id=81    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=150    min_ul_tput=8
    Trigger A2 measurement report without fail check    ue_id=81    carrierfreq=424090    pass_check=${MG_setup_with_n78_and_n77}
    Trigger MR scelladd    ${CA_check_CELL11_CELL1_CELL2_B003_UE1_scell_addition}    ue_id=81    carrierfreq=424090    srsrp_nr=100
    ...    fail_check=${fail_n78_and_n77_and_A6_B003_UE1_scell_addition}    threshold=90
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=480    min_ul_tput=8

UE1 HO to cell3 and HO Back
    Trigger A3 Measurement Report    ue_id=81    carrierfreq=640416    phycelId=52    pass_check=${CA_check_CELL3_CELL11}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A2 measurement report    ue_id=81    carrierfreq=640416    pass_check=${MG_setup_with_n78}    fail_check=${fail_n77}
    Trigger A3 Measurement Report    ue_id=81    carrierfreq=424090    phycelId=60    pass_check=${pcell_cell11}    nrsrp_nr=40    nrsrq_nr=40
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=150    min_ul_tput=8

UE1 trigger A2 mobility then scell addition then A1 mobility
    Trigger A2 measurement report without fail check    ue_id=81    carrierfreq=424090    pass_check=${MG_setup_with_n78_and_n77}
    Trigger MR scelladd    ${CA_check_CELL11_CELL1_CELL2_B003_UE1_scell_addition}    ue_id=81    carrierfreq=424090    srsrp_nr=100
    ...    fail_check=${fail_n78_and_n77_and_A6_B003_UE1_after_HO_in}    threshold=90
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Trigger A1 measurement report    ue_id=81    carrierfreq=424090    pass_check=${MG_release_reconfig_n77_B003_UE1_HO_in}
    ...    fail_check=${fail_n78_and_A1}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=480    min_ul_tput=8

UE1 scell swap and scell release
    Trigger ScellSwap Success    ue_id=81     phycell_id=52    pass_check=${CA_check_CELL11_CELL3}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After Scell Swap    ue_id=81    total_dl_tput=480    ul=8    scell_id=3
    Trigger ScellSwap Success    ue_id=81     phycell_id=51    scell_id=3    pass_check=${CA_check_CELL11_CELL2}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=640416    ue_id=81    scell_id=2
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=632736    ue_id=81    scell_id=1
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=150    min_ul_tput=8
    Release Ues    ue_type=all

UE2 attach then trigger A2 mobility then scell addition with 7219 enabled
    Ue register and pdu session setup    ${N66_N77_N77_and_N66_N77_and_N77EUSA}    ue_id=82    cell_id=11
    Send Throughput    ue_id=82    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=1    min_dl_tput=150    min_ul_tput=8
    Trigger A2 measurement report    ue_id=82    carrierfreq=424090    pass_check=${MG_setup_with_n77}    fail_check=${fail_n78}
    Trigger MR scelladd    ${CA_check_CELL11_CELL1_CELL2_B003_UE2_scell_addition}    ue_id=82    carrierfreq=424090    srsrp_nr=100
    ...    fail_check=${fail_n78}    threshold=90
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=480    min_ul_tput=8

UE2 scell swap and scell release
    Trigger ScellSwap Success    ue_id=82     phycell_id=52    pass_check=${CA_check_CELL11_CELL3}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic After Scell Swap    ue_id=82    total_dl_tput=480    ul=8    scell_id=3
    Trigger ScellSwap Success    ue_id=82     phycell_id=51    scell_id=3    pass_check=${CA_check_CELL11_CELL2}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=640416    ue_id=82    scell_id=2
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A2 ScellRelease    carrierfreq=632736    ue_id=82    scell_id=1
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=1    min_dl_tput=150    min_ul_tput=8

UE2 HO to cell3 and HO Back
    Trigger A3 Measurement Report    ue_id=82    carrierfreq=640416    phycelId=52    pass_check=${CA_check_CELL3_CELL11_n77}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A2 measurement report    ue_id=82    carrierfreq=640416    pass_check=${MG_setup_with_n77}    fail_check=${fail_n78}
    Trigger A3 Measurement Report    ue_id=82    carrierfreq=424090    phycelId=60    pass_check=${CA_check_CELL11_CELL1_CELL2_B003_UE2_HO_IN}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=480    min_ul_tput=8

Trigger A2 measurement report without fail check
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=10 srsrq_nr=10
    ...    pass_regexp=${pass_check}

B006_Teardown
    OnlineParamChange    ${B006_recovery}
    Common Test Teardown And Stop Capture Logs

UE attach and scell addition then A2 pcell change then A1 pcell change
    Ue register and pdu session setup    ${N2_N66_and_N2_N78_and_N25_N66_N78}    ue_id=81    cell_id=3
    Trigger MR scelladd    ${CA_check_CELL3_CELL12_CELL13}    ue_id=81    carrierfreq=640416    srsrp_nr=100    fail_check=${fail_n2}
    Send Throughput    ue_id=81    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Trigger A2 PCell Change    pass_check=${pcell_change_to_cell12_and_scell3}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A1 or A2 PCell Change    ue_id=81    carrierfreq=640416    scell_id=1    event_type=A1    pass_check=${HO_CA_check_CELL3_CELL12_CELL13}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=480    min_ul_tput=8

UE trigger A2 pcell change and A2 mobility then HO and HO back
    Trigger A2 PCell Change with fail regexp
    Trigger A2 measurement report    ue_id=81    carrierfreq=640416    pass_check=${MG_setup_with_n2_B06}    fail_check=${fail_n25}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Trigger A3 Measurement Report    ue_id=81    carrierfreq=391450    phycelId=63    pass_check=${HO_to_cell14}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A2 measurement report    ue_id=81    carrierfreq=391450    pass_check=${MG_setup_with_n2_back}    fail_check=${fail_n25}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A3 Measurement Report    ue_id=81    carrierfreq=640416    phycelId=52    pass_check=${HO_to_cell3}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Execute Egate Command    trf_data_stop ue=81 dir=dl pdu=1

Trigger A2 PCell Change
    [Arguments]    ${event_type}=A2    ${carrierfreq}=640416    ${scell1_rsrp}=100    ${scell1_rsrq}=100    ${ue_id}=81
    ...    ${pass_check}=rrcReconfigurationComplete    ${threshold}=80    ${scell2_rsrp}=100    ${scell2_rsrq}=100
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=1 scell_rsrp=${scell1_rsrp} scell_rsrq=${scell1_rsrq}
    ...    scell=2 scell_rsrp=${scell2_rsrp} scell_rsrq=${scell2_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}

Trigger A2 PCell Change with fail regexp
    [Arguments]    ${event_type}=A2    ${carrierfreq}=640416    ${scell1_rsrp}=10    ${scell1_rsrq}=10    ${ue_id}=81
    ...    ${fail_check}=rrcReconfiguration    ${threshold}=80    ${scell2_rsrp}=100    ${scell2_rs rq}=100
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=1 scell_rsrp=${scell1_rsrp} scell_rsrq=${scell1_rsrq}
    ...    scell=2 scell_rsrp=${scell2_rsrp} scell_rsrq=${scell2_rsrq}
    Execute Egate Command    ${cmd}    fail_regexp=${fail_check}

Trigger A2 PCell Change with fail regexp for one scell
    [Arguments]    ${event_type}=A2    ${carrierfreq}=640416    ${scell1_rsrp}=100    ${scell1_rsrq}=100    ${ue_id}=81
    ...    ${fail_check}=rrcReconfiguration    ${threshold}=80
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=1 scell_rsrp=${scell1_rsrp} scell_rsrq=${scell1_rsrq}
    Execute Egate Command    ${cmd}    fail_regexp=${fail_check}

UE attach and scell addition then A2 pcell change then A1 pcell change for UE2
    Ue register and pdu session setup    ${N25_N66_N78}    ue_id=82    cell_id=3
    Trigger MR scelladd    ${CA_check_CELL3_CELL12_CELL13}    ue_id=82    carrierfreq=640416    srsrp_nr=100    fail_check=${fail_n2}
    Send Throughput    ue_id=82    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Trigger A2 PCell Change    pass_check=${pcell_change_to_cell13_and_scell3_UE2}    ue_id=82
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A1 or A2 PCell Change    ue_id=82    carrierfreq=640416    scell_id=1    event_type=A1    pass_check=${HO_CA_check_CELL3_CELL12_CELL13}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Execute Egate Command    trf_data_stop ue=82 dir=dl pdu=1

UE attach and scell addition then A2 pcell change then A1 pcell change for UE3
    Ue register and pdu session setup    ${N2_N66_and_N2_N78_and_N25_N66_N78_noN2UL}    ue_id=83    cell_id=3
    Trigger MR scelladd    ${CA_check_CELL3_CELL12_CELL13}    ue_id=83    carrierfreq=640416    srsrp_nr=100    fail_check=${fail_n2}
    Send Throughput    ue_id=83    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Trigger A2 PCell Change    pass_check=${pcell_change_to_cell13_and_scell3_UE2}    ue_id=83
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A1 or A2 PCell Change    ue_id=83    carrierfreq=640416    scell_id=1    event_type=A1    pass_check=${HO_CA_check_CELL3_CELL12_CELL13}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=3    min_dl_tput=480    min_ul_tput=8
    Execute Egate Command    trf_data_stop ue=83 dir=dl pdu=1

UE attach and scell addition then release and 7219B false then re-attach UE4 and scell addition
    Ue register and pdu session setup    ${N2_N78_and_N25_N78}    ue_id=84    cell_id=3
    Trigger MR scelladd    ${CA_check_CELL3_CELL13}    ue_id=84    carrierfreq=640416    srsrp_nr=100
    ...    fail_check=${fail_n2_and_A2pcellchange_not_config}
    Send Throughput    ue_id=84    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=84    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Release Ues    ue_id=84
    OnlineParamChange    ${7219-B_false}
    Ue register and pdu session setup    ${N2_N78_and_N25_N78}    ue_id=84    cell_id=3
    Trigger MR scelladd    ${CA_check_CELL3_CELL13_with_7219B_false}    ue_id=84    carrierfreq=640416    srsrp_nr=100    fail_check=${fail_n2}
    Send Throughput    ue_id=84    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=84    cell_num=2    min_dl_tput=360    min_ul_tput=8

UE attach and scell addition then A2 pcell change then A1 pcell change for UE5
    Ue register and pdu session setup    ${N2_N78_and_N25_N78_noN2UL}    ue_id=85    cell_id=3
    Trigger MR scelladd    ${CA_check_CELL3_CELL13_with_7219B_false_UE5}    ue_id=85    carrierfreq=640416    srsrp_nr=100    fail_check=${fail_n25}
    Send Throughput    ue_id=85    times=6
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A2 PCell Change    pass_check=${pcell_change_to_cell13_and_scell3}    ue_id=85
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=2    min_dl_tput=360    min_ul_tput=8
    Trigger A1 or A2 PCell Change    ue_id=85    carrierfreq=640416    scell_id=1    event_type=A1
    ...    pass_check=${pcell_change_to_cell3_and_scell13_UE5}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=85    cell_num=2    min_dl_tput=360    min_ul_tput=8

A2 Pcell change failed after enable 7219B then re-attach UE5 and scell addition
    OnlineParamChange    ${7219-B_true}
    Trigger A2 PCell Change with fail regexp for one scell    ue_id=84
    Trigger A2 PCell Change with fail regexp for one scell    ue_id=85
    Release Ues    ue_id=85
    Ue register and pdu session setup    ${N2_N78_and_N25_N78_noN2UL}    ue_id=85    cell_id=3
    Trigger MR scelladd    ${CA_check_CELL3_CELL13_UE5}    ue_id=85    carrierfreq=640416    srsrp_nr=100
    ...    fail_check=${fail_n25_and_A2pcellchange_not_config}

B007_Teardown
    OnlineParamChange    ${B007_recovery}
    Common Test Teardown And Stop Capture Logs

UE attach and scell addition for UE1 and UE2 then A1 pcell change
    Ue register and pdu session setup    ${N2_N66_and_N2_N78_and_N25_N66_N78}    ue_id=81    cell_id=12
    Trigger MR scelladd    ${CA_check_CELL12_CELL13_CELL3}    ue_id=81    carrierfreq=432030    srsrp_nr=100    fail_check=${fail_A1_pcellchange_cfg}
    Send Throughput    ue_id=81    times=4
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=250    min_ul_tput=8
    Ue register and pdu session setup    ${N25_N66_N78}    ue_id=82    cell_id=12
    Trigger MR scelladd    ${CA_check_CELL12_CELL13_CELL3_UE2}    ue_id=82    carrierfreq=432030    srsrp_nr=100    fail_check=${fail_n2}
    Send Throughput    ue_id=82    times=4
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=3    min_dl_tput=250    min_ul_tput=8
    Trigger A1 or A2 PCell Change    ue_id=82    carrierfreq=391450    scell_id=2    event_type=A1    pass_check=${A1Pcell_change_to_cell13}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=1    min_dl_tput=50    min_ul_tput=8

UE3 attach and scell addition then A1 pcell change
    Ue register and pdu session setup    ${N2_N66_and_N2_N78_and_N25_N66_N78_noN2UL}    ue_id=83    cell_id=12
    Trigger MR scelladd    ${CA_check_CELL12_CELL13_CELL3_UE2}    ue_id=83    carrierfreq=432030    srsrp_nr=100    fail_check=${fail_n2}
    Send Throughput    ue_id=83    times=4
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=3    min_dl_tput=250    min_ul_tput=8
    Trigger A1 or A2 PCell Change    ue_id=83    carrierfreq=391450    scell_id=2    event_type=A1    pass_check=${A1Pcell_change_to_cell13}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=1    min_dl_tput=50    min_ul_tput=8
    Release Ues    ue_id=81
    OnlineParamChange    ${7219-B_false}

UE1 attach and scell addition then A1 pcell change failed
    Ue register and pdu session setup    ${N2_N66_and_N2_N78_and_N25_N66_N78}    ue_id=81    cell_id=12
    Trigger MR scelladd    ${CA_check_CELL12_CELL13_CELL3_UE2}    ue_id=81    carrierfreq=432030    srsrp_nr=100    fail_check=${fail_n2}
    Send Throughput    ue_id=81    times=4
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=250    min_ul_tput=8
    OnlineParamChange    ${7219-B_true}
    Trigger A2 PCell Change with fail regexp    event_type=A1    ue_id=81    carrierfreq=391450
