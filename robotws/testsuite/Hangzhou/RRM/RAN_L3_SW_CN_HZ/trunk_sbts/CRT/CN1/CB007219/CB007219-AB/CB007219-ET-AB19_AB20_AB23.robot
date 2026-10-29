*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-ha.zheng    owner-zora.wang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{1416}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{Scell_Rel}

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:chBw=70 MHz
...    NRCELL-3:chBw=40MHz
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

...    NRCELL-13:freqBandIndicatorNR=25
...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=2
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
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS:sCellActivationMethod=blind
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:carrierAggregationSupportList=${CAlist}
...    NRCELL:sCellDeactivationTimerGNB=infinity
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa

@{Scell_Rel}
...    NRCELL-2/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-14:gNbId=1
...    NRCELL-2/NRREL-14:gNbIdLength=22
...    NRCELL-2/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-14:removeNotAllowed=false
...    NRCELL-2/NRREL-14:lcrId=14
...    NRCELL-2/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-14:sCellOperationalMode=dlOnly

@{MimoMode_Para}
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL:nrCellType=4DL4UL

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

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
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

${N2_N77_and_N2_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D803AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A8360C6B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070009E1E00800713000000058081787802001C4D00000216020401C018800301320268BA000D80A14489B1CF
...    870A244D8E7C3003810C60F417001E00140E0A00E0601280380030120020301F01C01000000008000010040000100200000C010000080080
...    00050040000300200001C076065606D64C564CD60CD60C5606D654D01C1000009652504000065949410000296525040000E5949410000496
...    52504000165949410000696525040001E5949407703A6B81E55C9A9AE4D95506CAA0D5540F2A95650B002400681400021010020040402003
...    0808020020200C018D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${5_66_66_N2_N77and_5_66_66_N2_N78}    SEPARATOR=
...    BD1FF813C8C1001A08034100E008007130000000588C179182003410068201C01000E268000010B11820140204180030062026404D174002
...    481489D3A74489B1CF872274E9D1226C73E1807010C6064DE680240000804000201000080404008010100800C80001008000402000100808
...    020020200C0180

${N66_N77_and_N66_N78_no_ul_FSEI_of_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D803AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A8360C6B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070009E1E00800713000000058081787802001C4D00000216020401C018800301320268BA000D80A14489B1CF
...    870A244D8E7C3003810C60F417001E00140E0A00E0601280380030120020301F01C01000000008000010040000100200000C010000080080
...    00050040000300200001C076065606D64C564CD60CD60C5606D654D01C1000009652504000065949410000296525040000E5949410000496
...    52504000165949410000696525040001E5949407703A6B81E55C9A9AE4D95506CAA0D5540F2A95650B002400681400021010020040402003
...    08080200202010000D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${5_66_66_N2_N77and_5_66_66_N2_N78_no_ul_FSEI_of_N78}    SEPARATOR=
...    BD1FF813C8C1001A08034100E008007130000000588C179182003410068201C01000E268000010B11820140204180030062026404D174002
...    481489D3A74489B1CF872274E9D1226C73E1807010C6064DE680240000804000201000080404008010100800C80001008000402000100808
...    02002020100000

${DC_5A-66A-66A-n2A-n77A}    SEPARATOR=         #UE1_capa_nr
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701FB8D85181AC1184341020E9068036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C4
...    71E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F
...    30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C0
...    0FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE000B9
...    0001C006CA0000A00000A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C0A83600EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C011
...    787882001C46000000160205E1E1280071340000085808178B850001C41000E230000020B0102F17060003882001C4D000006160205E1E1400
...    0713400002058081707850001C4100000A160205E1E20800711800003058081787882001C4D00000E160205E2E1400071040038820000202C0
...    40BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E2300071340000605808
...    178F830001C41000E2300071300000685808178F882001C4C000E2600071300000705808178B882001C4D000E2680000F0B0102F1F10400388
...    2001C4D000E268000100B01020120234028809B01060260BA006D84614489B1CF870A244D8E7C38912244D8E7C38912244D8E7C3851226C73E
...    1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C68912244D8E7C38
...    D1224489B1CF871224489B1CF871A2448913639F0C00C888C6318C6318C6318C6318CF417001E00140E0A00E0601280380030120020301F020
...    01000000008000010040000100200000C01000008008000050040000300200001C01000010043032B282B262B236B066B062B036B2A6B27680
...    E0800004B29282000032CA4A0800014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A03A81D552AAAA515548F2
...    A8365506AAA07954AB285801200340A0010080801002020040084040200401004008402008010080100202004008804028050100E01C040400
...    808080300602008010404010020100200420201002008010021010020040401002100802004020040080801002201004008040080101002004
...    4020040080801002020040088040080101002004040080108080100202008010C0C0300680500A0600400C0080103002006004008180801100
...    400860600400C038010301000A008010180300701200C0C0180380900620100E00404048030101200C60201C00808070020202401808090063
...    543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${Capa_LTE_DC_5A-66A-66A-n2A-n77A}    SEPARATOR=         #UE1_capa
...    A11FF813C4D040389A001C01000000162205E268201C4C000E008000010B1102012023402800701060268BA000F40A24E8913639F0E24E8913
...    639F0C00380863030022000080404010030100E004400010080808004020040080

@{PM_Counters_Check_AB19_1}
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0

@{PM_Counters_Check_AB19_2}
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1

@{PM_Counters_Check_AB20}
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1

@{pm_couter_AB23}
...    NRCELL-14:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-14:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1


${SCELL_CONF_ALT_BAND_NSA}    M55118C01006    #This counter provides the number of current cell configurations as an NSA
#SCell in an alternative band.
${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501    #The number of radio admission requests for NSA user when admission is requested on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502    #This counter provides the number of admitted NSA users when radio admission is done on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_DU_NSA_ADMISS_MFBI_REQ}    M55115C01501    #This counter provides the number of radio admission requests with MFBI for the NSA user.
#Updated to the PS-Cell in the DU whenever CP-RT receives radio admission request for UE Context Setup or UE Context Modification request.
${SGNB_DU_NSA_ADMISS_MFBI_SUCC}    M55115C01502    #This counter provides the number of radio admitted NSA users with alternative band.
#Updated to the PS-Cell in the DU whenever CP-RT makes successful radio admission for UE Context Setup or UE Context Modification request.
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #This counter indicates the total number of CA UEs in the current cell configured as an S-Cell,
#which have 1 configured S-Cell in DL in NSA 3x mode.

@{nsa_ue_attach_expect}
...    pcid:51, scellIdx:8
...    pcid:63, scellIdx:9
...    SCellIndex 9 activated successfully at airphone
...    Successfully reconfigured dual connectivity
...    reported successful RA

@{N78_succ}
...    rrcConnectionReconfigurationComplete
...    pcid:50, scellIdx:8
...    frequencyBandList.*\{.*78.*\}\.

@{N77_succ}
...    rrcConnectionReconfigurationComplete
...    pcid:50, scellIdx:8
...    frequencyBandList.*\{.*77.*\}\.

@{OnlineParam_AB20_1}
...    NRBTS:actMfbiNrCaSupportFr1=false

@{OnlineParam_AB20_2}
...    NRBTS:actMfbiNrCaSupportFr1=true

*** Test Cases ***
CB007219-ET-AB19_Successful EN-DC setup with a PSCell but configured without candidate NR Scells interaction with mobility
    [Documentation]
    ...    1. This user scenario describes the successful setup of EN-DC when the target PSCell can be configured both
    ...    in native and in alternative band.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 40 70 40 20
    ...    DL MIMO Layers 4L 4L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N71 N25 N2 N78 N78 N38 N38
    ...    Alternative band NA NA N2 NA N77 N77 N41 N41
    ...    UE11 capability: 
    ...    NR bands         LTE bands           
    ...    BC#1: DC_5A-66A-66A-n2A-n77A        n2    n77                               
    ...    DL FSEI#1:       DL MIMO layers     2L     4L     2L     4L     4L        
    ...    DL ChBw (MHz)                       20    40                                  
    ...    UL FSEI#1:       UL MIMO layers     2L     2L                                  
    ...    UL ChBw (MHz)                       20    40                                  
    ...    BC#2: DC_5A-66A-66A-n2A-n78A        n2    n78                               
    ...    DL FSEI#2:       DL MIMO layers     4L     2L     2L     4L     4L        
    ...    DL ChBw (MHz)                       20    40                                  
    ...    UL FSEI#2:       UL MIMO layers     2L     2L                                  
    ...    UL ChBw (MHz)                       40    20                               
    ...    UE12 capability:
    ...    NR bands         LTE bands           
    ...    BC#1: DC_5A-66A-66A-n2A-n77A        n2    n77                               
    ...    DL FSEI#1:       DL MIMO layers     2L     4L     2L     4L     4L        
    ...    DL ChBw (MHz)                       20    40                                  
    ...    UL FSEI#1:       UL MIMO layers     2L     2L                                  
    ...    UL ChBw (MHz)                       20    40                                  
    ...    BC#2: DC_5A-66A-66A-n2A-n78A        n2    n78                               
    ...    DL FSEI#2:       DL MIMO layers     4L     4L     2L     4L     4L        
    ...    DL ChBw (MHz)                       20    40                                 
    ...    UL FSEI#2:       UL MIMO layers     2L     -                                     
    ...    UL ChBw (MHz)                       40    -                                                            
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell1 and trigger EN-DC setup toward the SgNB, Start DL/UL traffic
    ...    b. check counters.
    ...    c. attach UE12 to LTE cell1 and trigger EN-DC setup toward the SgNB, Start DL/UL traffic
    ...    d. check counters.
    ...    4. Expectation:
    ...    a. NR cell3 is PSCell. BC#2FSEI#1 is selected.
    ...    BC#2: DC_5A-66A-66A-n2A-n78A     n2 n78
    ...    DL FSEI#1: DL MIMO layers        4L 2L 2L 4L 4L
    ...    DL ChBw (MHz)                    20 40
    ...    UL FSEI#1: UL MIMO layers        2L 2L 2L 4L 4L
    ...    UL ChBw (MHz)                    20 40
    ...    c. NR cell3 is PSCell. BC#1FSEI#1 is selected.
    ...    BC#1: DC_5A-66A-66A-n2A-n77A     n2 n77
    ...    DL FSEI#1: DL MIMO layers        2L 4L 2L 4L 4L
    ...    DL ChBw (MHz)                    20 40
    ...    UL FSEI#1: UL MIMO layers        2L 2L
    ...    UL ChBw (MHz)                    20 40
    [Tags]    ha.zheng    QC_322185    AB19
    Clear Counter Files    wait=${False}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=11    cell=1    target_cells=1
    ...    SA_Capa_perUE_Full=${N2_N77_and_N2_N78}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${5_66_66_N2_N77and_5_66_66_N2_N78}    pass_CA=${N78_succ}
    Check Traffic should be ok
    Check Counters    ${PM_Counters_Check_AB19_1}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=12    cell=1    target_cells=1
    ...    SA_Capa_perUE_Full=${N66_N77_and_N66_N78_no_ul_FSEI_of_N78}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${5_66_66_N2_N77and_5_66_66_N2_N78_no_ul_FSEI_of_N78}    pass_CA=${N77_succ}
    Check Traffic should be ok    ue_id=12
    Check Counters    ${PM_Counters_Check_AB19_2}
    Check Wireshark Log    ${CURDIR}${/}A2A_AB19${/}a2a_gnb.ini    wait_string=UEContextReleaseComplete::4

CB007219-ET-AB20_Successful EN-DC setup with a PSCell but configured without candidate NR Scells interaction with mobility and 7219 disabled
    [Documentation]
    ...    1. This user scenario describes the successful setup of EN-DC when the target PSCell can be configured both
    ...    in native and in alternative band.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to false
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 40 70 40 20
    ...    DL MIMO Layers 4L 4L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N71 N25 N2 N78 N78 N38 N38
    ...    Alternative band NA NA N2 NA N77 N77 N41 N41
    ...    UE11 capability: 
    ...    NR bands         LTE bands           
    ...    BC#1: DC_5A-66A-66A-n2A-n77A        n2    n77                               
    ...    DL FSEI#1:       DL MIMO layers     2L     4L     2L     4L     4L        
    ...    DL ChBw (MHz)                       20    40                                  
    ...    UL FSEI#1:       UL MIMO layers     2L     2L                                  
    ...    UL ChBw (MHz)                       20    40                                  
    ...    BC#2: DC_5A-66A-66A-n2A-n78A        n2    n78                               
    ...    DL FSEI#2:       DL MIMO layers     4L     2L     2L     4L     4L        
    ...    DL ChBw (MHz)                       20    40                                  
    ...    UL FSEI#2:       UL MIMO layers     2L     2L                                  
    ...    UL ChBw (MHz)                       40    20                               
    ...    UE12 capability:
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell1 and trigger EN-DC setup toward the SgNB, Start DL/UL traffic
    ...    b. check counters.
    ...    4. Expectation:
    ...    a. Cell3 as PSCell in band n77 with respective measurement object configured also in band n77
    ...    and gNB-DU has selected BC#1 and FSEI#1.
    ...    BC#1: DC_5A-66A-66A-n2A-n77A n2 n77
    ...    DL FSEI#1: DL MIMO layers    2L 4L 2L 4L 4L
    ...    DL ChBw (MHz)                20 40
    ...    UL FSEI#1: UL MIMO layers    2L 2L 2L 4L 4L
    ...    UL ChBw (MHz)                20 40
    [Tags]    ha.zheng    QC_322184    AB20
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_AB20_1}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=11    cell=1    target_cells=1
    ...    SA_Capa_perUE_Full=${N2_N77_and_N2_N78}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${5_66_66_N2_N77and_5_66_66_N2_N78}    pass_CA=${N77_succ}
    Check Traffic should be ok
    Check Counters    ${PM_Counters_Check_AB20}
    Check Wireshark Log    ${CURDIR}${/}A2A_AB20${/}a2a_gnb.ini    wait_string=UEContextReleaseComplete::2
    [Teardown]    AB20_Teardown

CB007219-ET-AB23_Verify successful EN-DC setup when NR CA is supported only with the PSCell in alternative band
    [Documentation]
    ...    1. Purpose:This user scenario describes the successful setup of EN-DC when NR CA with the target PSCell is
    ...     supported only in the alternative band of the PSCell.5G_RAN_USR_RRM_22078
    ...    2. Configuration
    ...    a. NRCELL-2 TDD native:N78 alternative:N77 70Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-14 FDD N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    b.ue capability:
    ...    BC#1: DC_5A-66A-66A-n2A-n78A    n2    n78
    ...    DL FSEI#1    DL MIMO layers    4L    2L
    ...                 DL ChBw (MHz)     20    60
    ...    UL FSEI#1    UL MIMO layers    2L    2L
    ...                 UL ChBw (MHz)     20    60
    ...    BC#2: DC_5A-66A-66A-n2A-n77A    n2    n77
    ...    DL FSEI#1    DL MIMO layers    2L    4L
    ...                  DL ChBw (MHz)    20    70
    ...    UL FSEI#1    UL MIMO layers    2L    2L
    ...                  UL ChBw (MHz)    20    70
    ...    3. Test Case Steps:
    ...    a. UE11 attach to LTE1 cell1 NRCELL-2.Then cell 14 add as scell.Then BC2#FS1(N77_N2) selected.
    ...    b. detach UEs. check counter. check wireshark log.
    [Tags]     QC_322182    AB23    CA_LABEL-TF(70MHZ_TDD_n77+20MHZ_FDD_n2)    zora
    clear counter files
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    SA_Capa_perUE_Full=${DC_5A-66A-66A-n2A-n77A}
    ...    ue_mrdc_cap=${Capa_LTE_DC_5A-66A-66A-n2A-n77A}    target_cells=2    bc_list_mrdc=2:1|1:1    pass_CA=${nsa_ue_attach_expect}
    Check Traffic should be ok    times=6    mbps=175    cell_num=2    dl=750
    Check Wireshark Log    ${CURDIR}${/}A2A_AB23${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    check counters    pm_counters_expression=${pm_couter_AB23}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_N66_N71_2N78_2N38    ue_count=10

Modify Cfg
    ${C_1}    catenate
    ...    set_cell id=1 enb=1 eci=0x1234601 pci=4:0 tac=222 proxy=$DAEMON_IP:12219|$DAEMON_IP:8889
    ...    earfcn=66886:132422 mandatory_for_activation=off
    ${C_2}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=4:1 tac=222 proxy=$DAEMON_IP:12220|$DAEMON_IP:8890
    ...    earfcn=3100:21100 mandatory_for_activation=off
    ${C_3}    catenate
    ...    set_cell id=3 enb=1 eci=0x1234603 pci=4:2 tac=222 proxy=$DAEMON_IP:12221|$DAEMON_IP:8891
    ...    earfcn=300:18300 mandatory_for_activation=off
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    ${C_3}

NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${cell}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    ...    ${bc_list_mrdc}=1:1|2:1    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${pass_CA}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_CA}    timeout=20s

Check Traffic should be ok
    [Arguments]    ${ue_id}=11    ${times}=3    ${mbps}=90    ${cell_num}=1    ${dl}=250
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=${cell_num}    dl=${dl}
    Release Ues    ue_type=all

Update UE capa
    [Arguments]    ${ue_id}=16    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_mrdc_cap}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

AB20_Teardown
    OnlineParamChange    ${OnlineParam_AB20_2}
    Common Test Teardown And Stop Capture Logs

Check Traffic
    [Arguments]     ${ue_id}=11    ${cell_num}=1    ${dl}=250    ${ul}=8
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=8-11 type=pdsch    Throughput
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    8    ${cell_num}+8
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 20
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}
