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
...    @{1416}
...    @{Scell_Rel_AA04_UE1}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{AA33}
...    @{8225}
...    @{AA25_bwp}
...    @{Scell_Rel_AA25}
...    @{Scell_Rel_AA28}
...    @{A2pCellChange_for_NRCELL_1}

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-11:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-11:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

...    NRCELL-12:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-12:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=25
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=5

...    NRBTS/NRCELL-11:freqBandIndicatorNR=26

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=25

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=5
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=5
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=26
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=26

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
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd

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
...    NRCELL-16:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-11:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-11:nrCellType=4DL4UL
...    NRCELL-12:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:nrCellType=4DL4UL
...    NRCELL-13:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:nrCellType=4DL4UL
...    NRCELL-14:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-14:nrCellType=4DL4UL
...    NRCELL-15:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-15:nrCellType=4DL4UL
...    NRCELL-16:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-16:nrCellType=4DL4UL

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

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-15/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16/CHANNELGROUP-1/CHANNEL-8:resourceDN

@{Scell_Rel_AA04_UE1}
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-13:gNbId=1
...    NRCELL-12/NRREL-13:gNbIdLength=22
...    NRCELL-12/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-13:removeNotAllowed=false
...    NRCELL-12/NRREL-13:lcrId=13
...    NRCELL-12/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-13:sCellOperationalMode=dlOnly

...    NRCELL-12/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-14:gNbId=1
...    NRCELL-12/NRREL-14:gNbIdLength=22
...    NRCELL-12/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:removeNotAllowed=false
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-14:sCellOperationalMode=dlOnly

...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-14:a2MeasSCellRelEnabled=rsrp
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{AA33}
...    NRBTS:actIdleMMSteering=true
...    NRBTS/NRCAIMP-1:pCellConfig:nrarfcnDl=176640
...    NRBTS/NRCAIMP-1/NRCAIMS-1:sCellConfig:nrarfcnDl=388040
...    NRBTS/NRCAIMP-2:pCellConfig:nrarfcnDl=424000
...    NRBTS/NRCAIMP-2/NRCAIMS-1:sCellConfig:nrarfcnDl=392000
...    NRCELL:idleMMSteeringAlgo=CA aware
...    NRCELL:idleMMSteeringPercentageOfUes=100
...    NRCELL:idleMMSteeringWRREnabled=false
...    NRCELL-11:cellReselectionPriority=2
...    NRCELL-11:cellReselectionSubPriority=oDot2
...    NRCELL-11:idleMMServCelResWeight=77
...    NRCELL-11:t320=min10
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:cellReselectionPriority=3
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:cellReselectionSubPriority=oDot2
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:idleMMNrCelResWeight=5
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:ssbScs=15KHz
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:cellReselectionPriority=4
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:cellReselectionSubPriority=oDot2
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:dlCarrierFreq=176640
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:freqBandIndicatorNR=5
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:idleMMNrCelResWeight=4
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:qOffsetFreq=-4dB
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:ssbScs=15KHz
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:threshXHighQ=${EMPTY}
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:threshXLowQ=${EMPTY}

@{8225}
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:timerReleasePreferenceProhibit=s3
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:srbInactivityTimerSA=10
...    NRBTS:maxUeRrcInactTime=1
...    NRBTS:rrcInactIMMSteeringEnabled=true
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:t380=60min
...    NRBTS:actPaging=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:ranPagingCycle=v32
...    NRCELL-11:ranAC=0
...    NRBTS:activityNotificationLevelSA=ue
...    NRBTS:act3gppBL23R1=true

@{AA25_bwp}
...    NRCELL-16:gscnOrSsPbchArfcn=6591
...    NRCELL-16/NRCELL_FDD-1:nrarfcnDl=527520
...    NRCELL-16/NRCELL_FDD-1:nrarfcnUl=503520
...    NRCELL-15/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-15/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-16:actEnhMultipleDedicatedBWPs=true
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-7:bwpType=dedicated
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=14
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=15
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=42
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=17|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=18|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-16:msg1FrequencyStart=20
...    NRCELL-16:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-16:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3
...    NRCELL-16:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7

@{Scell_Rel_AA25}
...    NRCELL-16/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-16/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-16/NRREL-15:gNbId=1
...    NRCELL-16/NRREL-15:gNbIdLength=22
...    NRCELL-16/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-16/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-16/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-16/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-16/NRREL-15:removeNotAllowed=false
...    NRCELL-16/NRREL-15:lcrId=15
...    NRCELL-16/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-16/NRREL-15:sCellOperationalMode=dlOnly

...    NRCELL-16/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-16/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-16/NRREL-11:gNbId=1
...    NRCELL-16/NRREL-11:gNbIdLength=22
...    NRCELL-16/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-16/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-16/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-16/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-16/NRREL-11:removeNotAllowed=false
...    NRCELL-16/NRREL-11:lcrId=11
...    NRCELL-16/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-16/NRREL-11:sCellOperationalMode=dlOnly

...    NRCELL-16:a1MeasSCellAddEnabled=rsrp
...    NRCELL-16:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-16:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-16:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-15:a2MeasSCellRelEnabled=rsrp
...    NRCELL-15:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-15:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{Scell_Rel_AA28}
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-15:gNbId=1
...    NRCELL-1/NRREL-15:gNbIdLength=22
...    NRCELL-1/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-15:removeNotAllowed=false
...    NRCELL-1/NRREL-15:lcrId=15
...    NRCELL-1/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-15:sCellOperationalMode=dlOnly

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

...    NRCELL-13/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-15:gNbId=1
...    NRCELL-13/NRREL-15:gNbIdLength=22
...    NRCELL-13/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-15:removeNotAllowed=false
...    NRCELL-13/NRREL-15:lcrId=15
...    NRCELL-13/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-15:sCellOperationalMode=dlOnly

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

...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-15:a2MeasSCellRelEnabled=rsrp
...    NRCELL-15:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-15:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{A2pCellChange_for_NRCELL_1}
...    NRBTS:actHoOptimizationCa=true
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=100
...    @{PARAMS_FOR_NRHOIF}
...    @{PARAMS_FOR_MeasHO_A1A2}
...    @{PARAMS_FOR_MeasHO_A3A5}

@{PARAMS_FOR_NRHOIF}
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=2
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ssbFrequency=391970
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=7
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:ssbFrequency=530910
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=2

@{PARAMS_FOR_MeasHO_A1A2}
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=10
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64

@{PARAMS_FOR_MeasHO_A3A5}
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64

...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-2:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64

@{OnlineParam_AA04}
...    NRCELL-12/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-14:sCellAdditionMethod=blind

@{OnlineParam_AA04_recovery}
...    NRCELL-12/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-14:sCellAdditionMethod=covBasedA1

@{OnlineParam_AA33}
...    NRBTS/NRCAIMP-1:pCellConfig:nrarfcnDl=176300
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:dlCarrierFreq=176300

@{OnlineParam_AA33_recovery}
...    NRBTS/NRCAIMP-1:pCellConfig:nrarfcnDl=176640
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-2:dlCarrierFreq=176640

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported

@{INACTIVE_check_AA33}
...    t380
...    NR_RRC_INACTIVE

@{PM_Counters_Check_for_AA04}
...    NRCELL-13:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-14:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-12:${GNB_SA_ADMISSION_MFBI_REQ}=2
...    NRCELL-12:${GNB_SA_ADMISSION_MFBI_SUCC}=2
...    NRCELL-12:${GNB_SA_DU_ADMISSION_MFBI_REQ}=2
...    NRCELL-12:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=2

@{PM_Counters_Check_for_AA25}
...    NRCELL-11:${SCELL_CONF_ALT_BAND_SA}=1
...    NRCELL-15:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-16:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-16:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-16:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-16:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-15:${UE_SCELL_2_CONF_SCELL_DL_SA}>0

@{CA_check_CELL16_CELL15_CELL11}
...    pcid:65
...    scellIdx:0
...    pcid:64
...    scellIdx:1
...    pcid:60
...    scellIdx:2

@{CA_check_CELL1_CELL13_CELL15}
...    pcid:50
...    scellIdx:0
...    pcid:62
...    scellIdx:1
...    pcid:64
...    scellIdx:2

@{CA_check_CELL13_CELL1}
...    pcid:62
...    scellIdx:0
...    pcid:50
...    scellIdx:1

@{UE_register_and_A1_configured}
...    QoS Routing Table
...    eventA1

@{PM_Counters_Check_for_AA33}
...    NRCELL-11:${NRRCC_RRC_RELEASE_IMM_NR}>=2

@{PM_Counters_Check_for_AA28}
...    NRCELL-13:${SCELL_CONF_ALT_BAND_SA}=3
...    NRCELL-13:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-13:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-13:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=1
...    NRCELL-13:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=1

${SCELL_CONF_ALT_BAND_SA}    M55118C01005    #This counter provides the number of current cell configurations as an SA SCell in an alternative band
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501    #This counter provides the number of radio admission requests for the SA user, where admission is
#requested on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502    #This counter provides the number of admitted radio admission requests for the SA user,
#where admission is done on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001    #This counter provides the number of radio admission requests with MFBI for the SA user.
#The counter is updated to the PCell on DU.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002    #This counter provides the number of radio-admitted UEs for the SA user using the alternative
#band.The counter is updated to the PCell on DU.
${NRRCC_RRC_RELEASE_IMM_NR}    M55124C05501    #Number of RRC RELEASE messages with dedicated cell reselection priorities and NR primary target
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002    #This counter indicates the sum of samples for the total number of CA UEs in the current cell
#configured as an SCell with 2 configured SCells in DL in SA mode. The counter is pegged in the secondary cell.
${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503    #This counter provides the number of radio admission requests during handover procedures in CU 
#for an SA user, in which the admission is requested on the alternative band.The counter is updated on the handover target cell (PCell).
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504    #This counter provides the number of admitted radio admissions during handover procedures in CU 
#for an SA user, in which the admission is made on the alternative band.The counter is updated on the handover target cell (PCell).
${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}    M55139C02007    #This counter provides the number of intra-DU radio resource modification requests on the 
#alternative band for SA users.This counter is updated in the intra-DU handover case when radio resources are requested and updated to the PCell.
${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}    M55139C02008    #This counter provides the number of successful intra-DU radio resource modifications on the 
#alternative band for SA users.This counter is updated in the intra-DU handover case when radio resources are admitted and updated to the PCell.

${N25_N25_N25}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E09804062380DDC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FFF800003FFE00000260001C0AA3626EB04610D04083A41202CB64C550D0E7C471E819F604F8C
...    73E618F28581C0E1E05C00FFC007003FF0004C000381506C18D608C21A08107CA090195B262AC4873E238F604F8C48E3C873EA39F30C7942
...    C0E070F09FFF000007FFC000004C0003815C6C25D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1
...    E0B801FF800E007FE00098000702A8D899AC1184341020E90480B2D931543439F11C7A067D813E31CF9863CA16070387817003FF001C00FF
...    C00130000E0541B11B582308682041F28240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E
...    0073C3C41000E230000000B0102F0F09400389A0000042C040BC5C28000E2080071180000105808178B830001C18000E0C0000030B0102F0
...    F0A000389A0000102C040B83C28000E208000050B0102F0F10400388C0000182C040BC3C41000E268000070B0102F170A0003882001C4100
...    0010160205E2E14000711800388C0000242C040BC5C41000E2080071180000505808178B882001C46000E2300000B0B0102F0F11800389A0
...    000302C040BC7C18000E2080071180038980000342C040803808D00A2026C0410F40AF07428913639F0E14489B1CF871224489B1CF871224
...    489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871224489B1CF871224489B1CF871224489B1CF870A244D
...    8E7C38D1224489B1CF86150E18C6318C6318C6318DE8260078005038280381804A00E000C0480080C07C0700400000002000004010000040
...    0800003004000020020000140100000C0080000701D81959515931591B58335831581B595340704000025949410000196525040000A59494
...    1000039652504000125949410000596525040001A594941000079652501D40EAA9555526AAA479541B2A8355503CAA55942401200340A000
...    D080801002020040084040200401004008402008010080100202004008804038070100E01C04038070808030060200801040401002010020
...    0420201002008010021010020040401002100802004020040080801002201004008040080101002004402004008080100202004008804008
...    0101002004040080108080100202008010C0C0300680500A0600400C008010300200600400818080110040086A87C0004080C10181C282C3
...    0344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

${N5_N25_N66_and_N2_N5_N66_8225}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E09804062380DDC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FFF800003FFE00000260001C0AA3626EB04610D04083A41202CB64C550D0E7C471E819F604F8C
...    73E618F28581C0E1E05C00FFC007003FF0004C000381506C18D608C21A08107CA090195B262AC4873E238F604F8C48E3C873EA39F30C7942
...    C0E070F09FFF000007FFC000004C0003815C6C25D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1
...    E0B801FF800E007FE00098000702A8D899AC1184341020E90480B2D931543439F11C7A067D813E31CF9863CA16070387817003FF001C00FF
...    C00130000E0541B013582308682041F28240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E
...    0073C3C41000E230000000B0102F0F09400389A0000042C040BC5C04000C0C01C41000004160205E2E0C000706000383000000C2C040BC3C
...    28000E268000040B0102E0F0A00038820000142C040BC3C41000E230000060B0102F0F10400389A00001C2C040BC58010300807104000040
...    5808178B850001C46000E230000090B0102F17104003882001C46000014160205E2E20800711800388C00002C2C040BC3C46000E2680000C
...    0B0102F1F060003882001C46000E2600000D0B010200E0234028809B01043D02BC1D0A244D8E7C3851226C73E1C4891226C73E1C4891226C
...    73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C28913639F0
...    E344891226C73E1854386318C6318C6318C637A09801E00140E0A00E0601280380030120020301F01C010000000080000100400001002000
...    00C01000008008000050040000300200001C076065654564C5646D60CD60C5606D654D01C100000965250400006594941000029652504000
...    0E594941000049652504000165949410000696525040001E5949407503AAA555549AAA91E5506CAA0D5540F2A956509004800D0280034202
...    0040080801002101008010040100210080100202004008080100220100200404008010100200420200C01808020041010040080400801080
...    8040080200400840400801010040084020040080801002020040088040100201002004040080110080100202004008080100220100200404
...    0080101002004202004008080200430300C01A01402818010030020040C0080180100206020044010021AA1F000102030406070A0B0C0D10
...    1112131418191B1C1D1F2125262728292A2D2F414192D4A2000042

#2CC CA_n7(2A) CA_n7B CA_n5(2A) CA_n5A-n7A CA_n7A-n26A 3CC CA_n5A-n7(2A)
${N7_N7_and_N5_N5_and_N5_N7_and_N5_N7_N7_and_n7_N26}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E09804062380DDC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D809AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FFF800003FFE00000260001C0AA3626EB04610D04083A41202CB64C550D0E7C471E819F604F8C
...    73E618F28581C0E1E05C00FFC007003FF0004C000381506C19D608C21A08107CA090195B262AC4873E238F604F8C48E3C873EA39F30C7942
...    C0E070F09FFF000007FFC000004C0003815C6C25D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1
...    E0B801FF800E007FE00098000702A8D899AC1184341020E90480B2D931543439F11C7A067D813E31CF9863CA16070387817003FF001C00FF
...    C00130000E0541B01B582308682041F28240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E
...    0073C1C06041000160205E1E0300070180000085808178B850001C41000E230000020B0102F1701000380C001C06000006160205E1E02000
...    701000002058081707808001C0600000A160205E1E03000706400003058081787882001C4D00000E160205E2E1400071040038820000202C
...    040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E2300071340000605
...    808178F830001C41000E23000713000006858081007011A014404D80821E815E0E851226C73E1C28913639F0E2448913639F0E2448913639
...    F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E2448913639F0E2448913639F0E2448913639F0E14489B1CF871
...    A2448913639F0C2A1C318C6318C6318C631BD04C00F000A070500703009401C0018090010180F81000800000004000008020000080100000
...    600800004004000028020000180100000E00800404010076065654564C5646D604D60C5606D654D020100000965250400006594941000029
...    6525040000E594941000049652504000165949410000696525040001E594941004040125949407503AAA555549AAA91E5502CAA0D5540F2A
...    956509004800D0280034002024048404028050100A014402008010080100202004008804038070100A014040280508080700E0201C038404
...    038070100A014202014028080700E10100200404010021008020040200400808010022010040080400801010020044020040080801002020
...    040088040080101002004040080108080100202008010C0C0300680500A0600400C008010300200600400818080110040086A87C0004080C
...    10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${N2_N7_and_N2_N78_and_N7_N25_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B063582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D803AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836036B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C003787802001C06000002160205E1E0080071340000385808178B80C001C18000E268000080B010200E0234028809B01045D0009
...    C070A244D8E7C3851226C73E1C4891226C73E181C0C631FA0B800F000A070500703009401C0018090010180F810008000000040000080200
...    00080100000600800004004000028020000180100000E00800404010076065654564C5646D606D60C5606D654D0201000009652504000065
...    949410000296525040000E594941000049652504000165949410000696525040001E594941004040125949407503AAA555549AAA91E5503C
...    AA0D5540F2A95650B0024006814001A001012024202014028080500A20100400804008010100200440201C038080500A0201402840403807
...    0100E01C20201C038080500A10100A0140403807080801002020080108040080101002004040100210080200402004008080100220100200
...    40400801010020044020040080801002020040084040080101004008606018034028050300200600400818010030020040C0400880200435
...    43E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${N2DlOnly_N7_and_N2DlOnly_N78_and_N7_N25_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B063582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D803AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836036B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C0037870020701800000858081787002071340000385808178B80C001C18000E268000080B010200E0234028809B01045D0009C07
...    0A244D8E7C3851226C73E1C4891226C73E181C0C631FA0B800F000A070500703009401C0018090010180F810008000000040000080200000
...    80100000600800004004000028020000180100000E00800404010076065654564C5646D606D60C5606D654D0201000009652504000065949
...    410000296525040000E594941000049652504000165949410000696525040001E594941004040125949407503AAA555549AAA91E5503CAA0
...    D5540F2A95650B0024006814001A001012024202014000080500A20100400804008010100200440201C038080500A0201402840403807010
...    0E01C20201C038080500A10100A0140403807080801000020080108040080101002004040100210080200402004008080100220100200404
...    00801010020044020040080801002020040084040080101004008606018034028050300200600400818010030020040C040088020043543E
...    00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${N2DlOnly_N7_and_N2DlOnly_N78_and_N7_N25DlOnly_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B063582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D803AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836036B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C0037870020701800000858081787002071340000385808178B80C0018180389A0000202C040803808D00A2026C041174002701C2
...    8913639F0E14489B1CF871224489B1CF86070318C7E82E003C00281C1401C0C02500700060240040603E0400200000001000002008000020
...    04000018020000100100000A00800006004000038020010100401D81959515931591B581B5831581B5953408040000259494100001965250
...    40000A594941000039652504000125949410000596525040001A59494100007965250401010049652501D40EAA9555526AAA479540F2A835
...    5503CAA55942C009001A050006800404809080805000020140288040100201002004040080110080700E02014028080500A10100E01C0403
...    80708080700E02014028404028050100E01C2020040000802004201002004040080001004008402008010080100202004008804008010100
...    20040400801100801002020040080801002101002004040100218180600D00A0140C008018010020600400C0080103010022008010D50F80
...    00810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

*** Test Cases ***
CB007219_AA04_Verify_CA_setup_not_attempted_for_missing_candidate_SCells_in_the_PCell_operating_band
    [Documentation]
    ...    1. This user scenario describes the case when there is no suitable SCell to add to the UE, due to the PCell operating band.
    ...    2. Configuration
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true"
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    cell12 13 14 are contiguous
    ...    BC#1: n25(3A)              N25    N25    N25
    ...    FSEI#1    DL MIMO layers    4L    4L    4L
    ...              DL ChBw (MHz)     20    20    20
    ...    A1 for scell addition is configured in PCell and A2 for scell is configured in SCells.
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell12, start DL/UL traffic.
    ...    expected UE1 attach to cell successfully. no A1 for scell addition is configured to UE since cell12 cell13 cell14 are contiguous.
    ...    traffic is OK.
    ...    b. release UE1, and UE1 is released successfully.
    ...    c. online modidify scell addition method from A1 to blind. And attach UE1 to cell12 again. start DL/UL traffic.
    ...    expected UE1 attach to cell successfully and no scell is added since cell12 cell13 cell14 are contiguous. traffic is OK
    ...    d. check counters.
    [Tags]    QC_320591    christine.chen    AA04
    Clear Counter Files    wait=${False}
    Ue register and pdu setup and A1 is not configure    ${N25_N25_N25}    ue_id=81    cell_id=12
    Send Throuput and check Throuput for pcell    ue_id=81
    UE Deregister From gNB    ue_id=81
    OnlineParamChange    ${OnlineParam_AA04}
    Ue register and pdu setup noscell added    ${N25_N25_N25}    ue_id=81    cell_id=12
    Send Throuput and check Throuput for pcell    ue_id=81
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}A2A_AA04${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${PM_Counters_Check_for_AA04}
    [Teardown]    AA04 TestTeardown

CB007219_AA33_Idle_Mode_Mobility_steering_with_CA_aware_algorithm_when_the_target_PCell_and_candidate_SCells_are_in_native_and_alternative_band
    [Documentation]
    ...    1. This user scenario describes the successful redirection to a CA supportive frequency layer when the applied CA filter contains
    ...    target PCell and candidate SCells in native and alternative band.
    ...    2. Configuration
    ...    CB007516:UE is attached to cell11, F1 Target PCells for re-direction in Cell11, i.e. NR carriers configured with a weight factor in the
    ...    corresponding NRBTS/NRCELL/nrSysInfoProfileDN MOC, have frequency FP1 in band n5 or n26, and frequency FP2 in band n66.
    ...    CA filters for redirection configured in the gNB are as follows:
    ...    FP1 (as target PCell1, in band n5/n26) + FS1 (as candidate SCell1, in band n2/n25)
    ...    FP2 (as target PCell2, in band n66) + FS1 (as candidate SCell1, in band n2/n25)
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true"
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    UE1 capability: attach to cell11
    ...    BC#1: n5A-n25A-n66A    n5    n25    n66
    ...             FSEI#1:DL    yes    yes    yes
    ...                    UL    yes    no     yes
    ...    BC#2: n2A-n5A-n66A    N2    N5    N66
    ...             FSEI#1:DL    yes    yes    yes
    ...                    UL    no     no     yes
    ...    Note: BC#1 supports both target PCell1 and target PCell2, whereas BC#2 supports target PCell2 only
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell11. start UL/DL traffic.
    ...    expected UE1 attach to cell11 successfully. And traffic is OK.
    ...    b. release UE.
    ...    expected The RRC Release message contains cellReselectionPriorities IE listing the frequency of target PCell1 and target Pell2.
    ...    c. online modify target PCell1 is operating at the same frequency of Cell11, and in the native band n26 and alternative band n5.
    ...    expected online modification successfully.
    ...    d. attach UE1 to cell11. start UL/DL traffic.
    ...    expected UE1 attach to cell11 successfully. And traffic is OK.
    ...    e. trigger UE1 inative.
    ...    expected The RRC Release message contains cellReselectionPriorities IE listing the frequency of target PCell1 and target Pell2.
    ...    f. check counters.
    [Tags]    christine.chen    AA33    QC_321446
    Clear Counter Files
    Ue register and pdu setup and A1 is not configure    ${N5_N25_N66_and_N2_N5_N66_8225}    ue_id=81    cell_id=11
    Send Throuput and check Throuput for pcell    ue_id=81    pcell_dl=125    times=4
    UE Deregister From gNB    ue_id=81
    OnlineParamChange    ${OnlineParam_AA33}
    ICS With PDU    ${N5_N25_N66_and_N2_N5_N66_8225}    ue_id=81    cell_id=11
    Send Throuput and check Throuput for pcell    ue_id=81    pcell_dl=125    times=4
    Send UAI to GNB    ue_id=81    state=inactive    pass_regexp=${INACTIVE_check_AA33}
    UEDeregist and wireshark check for AA33
    Check Counters    ${PM_Counters_Check_for_AA33}
    [Teardown]    AA33 TestTeardown

CB007219_AA25_Verify_succ_CA_setup_with_alternative_bands_when_the_PCell_is_configured_with_small_dedicated_BWP-highest_aggregated_channel_bandwidth
    [Documentation]
    ...    1. This user scenario describes the successful setup of CA when some of the aggregated cells are configured with alternative bands and
    ...    the PCell is configured with a dedicated small BWP. successful CA setup with alternative bands when the PCell is configured with small
    ...    dedicated BWP-highest aggregated channel bandwidth.
    ...    2. Configuration
    ...    CB008541:actEnhMultipleDedicatedBWPs =true, actMultipleDedicatedBWPs=true
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true"
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    UE1 capability: CA relation: cell16+cell15+cell11, A1 scell addition
    ...    BC#1: n7B                n7    n7
    ...    FSEI#1:DL MIMO layers    4L    4L
    ...            DL ChBw (MHz)    15    15
    ...    BC#2: n7(2A)             n7    n7
    ...    FSEI#1:DL MIMO layers    4L    4L
    ...            DL ChBw (MHz)    15    15
    ...    BC#3: n5(2A)             n5    n5
    ...    FSEI#1:DL MIMO layers    4L    4L
    ...            DL ChBw (MHz)    20    20
    ...    BC#4:n5A-n7A             n5    n7
    ...    FSEI#1:DL MIMO layers    4L    4L
    ...            DL ChBw (MHz)    20    15
    ...    BC#5: n5A-n7(2A)         n5    n7    n7
    ...    FSEI#1:DL MIMO layers    4L    4L    4L
    ...            DL ChBw (MHz)    20    15    15
    ...    BC#6:n7A-n26A            n7    n26
    ...    FSEI#1:DL MIMO layers    4L    4L
    ...            DL ChBw (MHz)    15    20
    ...    A1 for scell addition is configured in PCell and A2 for scell is configured in SCells.
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell16, and trigger A1 for scell addition. Start DL/UL traffic.
    ...    expected cell15 and cell11 are added as scells successfully. 5G-UE serving cells and respective measurement objects are configured at
    ...    5G-UE to operate as follows: Cell16 in band n7, Cell15 in band n7, Cell11 in band n5. BC#5FSEI#1(bandCombinationIndex is 4) is
    ...    selected. cell16 is configured with
    ...    small BWP.
    ...    b. release UE and check counters.
    [Tags]    christine.chen    AA25    QC_320585    CA_LABEL-FFF(20MHZ_FDD_n5+15MHZ_FDD_n7+15MHZ_FDD_n7)
    Clear Counter Files
    Ue register and pdu setup and A1 is configure    ${N7_N7_and_N5_N5_and_N5_N7_and_N5_N7_N7_and_n7_N26}    ue_id=81    cell_id=16
    Trigger MR scelladd    ${CA_check_CELL16_CELL15_CELL11}    ue_id=81    carrierfreq=527310
    Send Throuput and check Throuput for two scell    ue_id=81    times=6    min_dl_tput=420
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}A2A_AA25${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_Check_for_AA25}

CB007219_AA28_Interaction with A2 measurement based PCell change
    [Documentation]
    ...    1. This user scenario describes the gNB behavior, when a UE for which carrier aggregation is configured and 
    ...    at least one SCell is configured in alternative band. In addition, A2 measurement is enabled on PCell in 
    ...    order to trigger PCell change and UE sends A2 measurement report for PCell. 
    ...    2. Configuration
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true"
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    NRBTS/NRCELL/NRHOIF/a2BasedPCellSwitchPriority of Cell 13 is less than Cell 15
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_15 Cell_16 Cell_1 Cell_2
    ...    Technology type FDD FDD FDD FDD FDD FDD TDD TDD
    ...    channel bandwidth 20 20 20 20 15 20 100 100
    ...    Native band N26 N2 N2 N2 N7 N7 N78 N78
    ...    Alternative band N5 N25 N25 NA NA NA N77 N77
    ...    UE1 capability: CA relation: cell1(pcell)+cell13+cell15, A1 scell addition
    ...    cell13(pcell)+cell15+cell1, A1 scell addition
    ...    BC#1 : n2A_n7A
    ...    BC#2 : n2A_n78A
    ...    BC#3 : n7A_n25A_n78A
    ...    UE2 capability: UE has UL capabilities in band n7, n25 and n78 only. It cannot support UL in band n2. 
    ...    UE3 capability: UE has UL capabilities in band n7 and n78 only. It cannot support UL in band n2 and n25
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell1,UE1 attach to cell1 with band 78 successfully,traffic is OK.
    ...    b. trigger A1 for scell addition,cell13 and cell15 are added as scells with BC3. 
    ...    cell13 is configured with n25,traffic is OK in both pcell and scell. 
    ...    c. trigger A2 for pcell change,PCell change to Cell13 with native band n2 
    ...    (CB007219: for the pcell selection, using native band by default) and 
    ...    cell1 is added scell with BC2(cell_1 BW is bigger than cell_15). traffic is OK. 
    ...    d.attach UE2 to cell1,UE2 attach to cell1 with band 78 successfully,traffic is OK.
    ...    e.trigger A1 for scell addition,cell13 and cell15 are added as scells with BC3. 
    ...    cell13 is configured with n25. traffic is OK in both pcell and scell. 
    ...    f.trigger A2 for pcell change,PCell change to Cell13 with alternative band n25,
    ...    (pcell must have UL capacity, N2 for ue2 has no UL)
    ...    cell1, cell15 is added as scell with BC3. traffic is OK. 
    ...    g. attach UE3 to cell1,UE3 attach to cell1 with band 78 successfully,traffic is OK.
    ...    h. trigger A1 for scell addition,cell13 and cell15 are added as scells with BC3. 
    ...    cell13 is configured with n25,traffic is OK in both pcell and scell. 
    ...    i. trigger A2 for pcell change,PCell change to Cell15 with native band N7.
    ...    (cell_13 cannot be pcell since both N2 and N25 has no UL capacity)  
    ...    no scell added as no CA relation.
    [Tags]    QC_321445    jia.pan    AA28    CA_LABEL-FT(20MHZ_FDD_n2+100MHZ_TDD_n78)    CA_LABEL-FFT(20MHZ_FDD_n25+15MHZ_FDD_n7+100MHZ_TDD_n78)
    Clear Counter Files
    UE register and trigger A1 scelladd
    Trigger Pcell Change with scelladd
    UE register and trigger A1 scelladd    ${N2DlOnly_N7_and_N2DlOnly_N78_and_N7_N25_N78}    ue_id=82   
    Trigger Pcell Change with scelladd    82    ${CA_check_CELL1_CELL13_CELL15}     
    UE register and trigger A1 scelladd    ${N2DlOnly_N7_and_N2DlOnly_N78_and_N7_N25DlOnly_N78}    ue_id=83   
    Trigger Pcell Change	
    Check Wireshark Log    ${CURDIR}${/}A2A_AA28${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${PM_Counters_Check_for_AA28}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_2T6F_2N78_N5_3N2_2N7    ue_count=15

UE register and trigger A1 scelladd
    [Arguments]    ${SA_Capa_perUE_Full}=${N2_N7_and_N2_N78_and_N7_N25_N78}    ${ue_id}=81    ${cell_id}=1
    Ue register and pdu setup and A1 is configure    ${SA_Capa_perUE_Full}    ue_id=${ue_id}    cell_id=${cell_id}
    Trigger MR scelladd    ${CA_check_CELL1_CELL13_CELL15}    ue_id=${ue_id}    carrierfreq=632736
    Send Throuput and check Throuput for two scell    ue_id=${ue_id}    times=8    min_dl_tput=765

Trigger Pcell Change with scelladd
    [Arguments]    ${ue_id}=81    ${CA_CHECK}=${CA_check_CELL13_CELL1} 
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=632736    event_type=A2
    ...    threshold=RSRP 100    timetotrigger=480 ms
    ${mr_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrq_nr=11 srsrp_nr=80
    ...    scell=1 scell_rsrp=90 scell_rsrq=38 scell=2 scell_rsrp=90 scell_rsrq=38
    ${ret1}=    Execute Egate Command    ${mr_cmd}    pass_regexp=${CA_CHECK}
    Send Throuput and check Throuput for one scell    ${ue_id}
    Release Ues    ue_type=all

Trigger Pcell Change
    [Arguments]    ${ue_id}=83
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=632736    event_type=A2
    ...    threshold=RSRP 100    timetotrigger=480 ms
    ${mr_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrq_nr=11 srsrp_nr=80
    ...    scell=1 scell_rsrp=90 scell_rsrq=38 scell=2 scell_rsrp=90 scell_rsrq=38
    ${ret1}=    Execute Egate Command    ${mr_cmd}    pass_regexp=pcid:64
    Send Throuput and check Throuput for pcell    ${ue_id}    pcell_dl=135    times=3       

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UEDeregist and wireshark check for AA33
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}A2A_AA33${/}a2a.ini    wait_string=UEContextReleaseComplete::8

Trigger MR scelladd
    [Arguments]    ${scell_added_log}    ${ue_id}=81    ${carrierfreq}=650016
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${scell_added_log}

AA04 TestTeardown
    OnlineParamChange    ${OnlineParam_AA04_recovery}
    Common Test Teardown And Stop Capture Logs

AA33 TestTeardown
    OnlineParamChange    ${OnlineParam_AA33_recovery}
    Common Test Teardown And Stop Capture Logs

Ue register and pdu setup noscell added
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=1    ${cell_id}=2
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=QoS Routing Table
    Should Not Contain      ${ret}     scellIdx:1

Ue register and pdu setup and A1 is not configure
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=1    ${cell_id}=2
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=QoS Routing Table
    Should Not Contain      ${ret}     eventA1

Ue register and pdu setup and A1 is configure
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=1    ${cell_id}=2
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${UE_register_and_A1_configured}

ICS With PDU
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=1    ${cell_id}=1
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    ${releasePreference_check}

Send UAI to GNB
    [Arguments]    ${ue_id}=1    ${state}=inactive    ${pass_regexp}=${INACTIVE_check_AA33}
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${state}    pass_regexp=${pass_regexp}

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=20    ${ul}=8
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Send Throuput and check Throuput for pcell
    [Arguments]    ${ue_id}=83    ${pcell_dl}=255    ${times}=8
    Send Throughput    ue_id=${ue_id}    times=${times}
    Wait Until Keyword Succeeds    30s    10s    Verify Throuput on Pscell    ue_id=${ue_id}    pcell_dl=${pcell_dl}

Send Throuput and check Throuput for two scell
    [Arguments]    ${ue_id}=83    ${times}=10    ${min_dl_tput}=800
    Send Throughput    ue_id=${ue_id}    times=${times}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=3    min_dl_tput=${min_dl_tput}

Send Throuput and check Throuput for one scell
    [Arguments]    ${ue_id}=81    ${times}=8    ${min_dl_tput}=765
    Send Throughput    ue_id=${ue_id}    times=${times}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=2    min_dl_tput=${min_dl_tput}

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=1    ${min_dl_tput}=20    ${min_ul_tput}=8
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 20
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    2    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
