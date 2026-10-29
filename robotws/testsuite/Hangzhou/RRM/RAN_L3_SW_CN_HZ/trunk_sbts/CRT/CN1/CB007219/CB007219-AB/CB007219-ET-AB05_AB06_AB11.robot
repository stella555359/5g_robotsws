*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-ha.zheng
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{1416}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{CA_REL_AB05}
...    @{CNI-81817}
...    @{CB007552_CB008541}
...    @{CA_REL_AB11}

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:chBw=40MHz
...    NRCELL-3:chBw=40MHz
...    NRCELL-3:nrarfcn=519000
...    NRCELL-3:gscnOrSsPbchArfcn=6462
...    NRCELL-3:type0CoresetConfigurationIndex=10
...    NRCELL-3:msg1FrequencyStart=20
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

@{CNI-81817}
...    NRBTS:actHighestEstNrTputBcSel=true

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
...    NRCELL:actDl256Qam=false
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:carrierAggregationSupportList=${CAlist}
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,

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

@{CB007552_CB008541}
...    NRBTS:actMultipleDedicatedBWPs=false
...    NRCELL:actEnhMultipleDedicatedBWPs=false
...    NRBTS/BWP_PROFILE-7:bwpType=initial
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8:bwpType=dedicated
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=n106
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-8/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-9:bwpType=dedicated
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-9/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDSCH-1:pdschRat0RbgConfig=config1

...    NRBTS/BWP_PROFILE-10:bwpType=dedicated
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthDl:cRbSizeDl=n217
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthUl:cRbSizeUl=n217
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-10/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-10/PDSCH-1:pdschRat0RbgConfig=config1

@{CA_REL_AB05}
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
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:isRplCellForPSCell=true
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:isRplCellForPSCell=true
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:lcrId=2
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms

@{CA_REL_AB11}
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:isRplCellForPSCell=true
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
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
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms

@{N2_N77_CA_succ}
...    rrcConnectionReconfigurationComplete
...    pcid:50, scellIdx:9
...    pcid:62, scellIdx:8
...    frequencyBandList.*\{.*2.*\}\.
...    frequencyBandList.*\{.*77.*\}\.
...    reported successful RA

@{OnlineParam_AB06_1}
...    NRBTS:actAllowedBcListMrdcPrioBcSel=true

@{OnlineParam_AB06_2}
...    NRBTS:actAllowedBcListMrdcPrioBcSel=false

@{PM_Counters_Check_AB05}
...    NRCELL-1:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_AB06}
...    NRCELL-1:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>0

@{OnlineParam_AB11_1}
...    NRCELL-1:chBw=100MHz
...    NRCELL-2:chBw=100MHz
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS:actHighestEstNrTputBcSel=false
#...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbStartDl=crb0
...    NRCELL-3:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8
...    NRCELL-3:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-9
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-10
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-2:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-10

@{OnlineParam_AB11_2}
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:chBw=40MHz
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS:actMultipleDedicatedBWPs=false
...    NRCELL:actEnhMultipleDedicatedBWPs=false
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRCELL-3:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-6
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4

@{N78_N38_CA_succ}
...    rrcConnectionReconfigurationComplete
...    pcid:50, scellIdx:8
...    pcid:52, scellIdx:9
...    frequencyBandList.*\{.*78.*\}\.
...    frequencyBandList.*\{.*38.*\}\.
...    reported successful RA

@{N77_PCell}
...    rrcConnectionReconfigurationComplete
...    frequencyBandList.*\{.*77.*\}\.
...    pcid:51, scellIdx:8
...    reported successful RA

@{N41_SCell}
...    rrcConnectionReconfigurationComplete
...    frequencyBandList.*\{.*41.*\}\.
...    pcid:51, scellIdx:8
...    pcid:52, scellIdx:9
...    SgNB Modification Confirm

@{PM_Counters_Check_AB11}
...    NRCELL-3:${SCELL_CONF_ALT_BAND_NSA}=1
...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL}>0

${SCELL_CONF_ALT_BAND_NSA}    M55118C01006    #This counter provides the number of current cell configurations as an NSA
#SCell in an alternative band.
${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501    #The number of radio admission requests for NSA user when admission is requested on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502    #The number of admitted NSA users when radio admission is done on the alternative band.
#Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_DU_NSA_ADMISS_MFBI_REQ}    M55115C01501    #The number of radio admission requests with MFBI for NSA user. Updated to the PS-Cell in the DU
#whenever CP-RT receives radio admission request for UE Context Setup or UE Context Modification request.
${SGNB_DU_NSA_ADMISS_MFBI_SUCC}    M55115C01502    #The number of radio admitted NSA users with alternative band. Updated to the PS-Cell in the DU
#whenever CP-RT makes successful radio admission for UE Context Setup or UE Context Modification request.
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #This counter indicates the total number of CA UEs in the current cell configured as an S-Cell,
#which have 1 configured S-Cell in DL in NSA 3x mode.

${N2_N77_and_N2_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D803AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A8360C6B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070011E0E0C0000000B0102F0700400000858081787802001C4C000004160205E1E0080071340000185808100
...    70062000C04C809A2E8005A048113639F0E044D8E7C3851226C73E1C28913639F0C1208318C63D05C0078005038280381804A00E000C0480
...    080C07C07004000000020000040100000400800003004000020020000140100000C0080000701D819581B5931593358335831581B5953407
...    04000025949410000196525040000A594941000039652504000125949410000596525040001A594941000079652501D40EAA81E5529AAA53
...    9541B2A8355503CAA55942C009001A05000180040100200080200410300400A0040081803007008010206008014008010300600E010020D5
...    0F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${N25_66_66_5_and_N2_66_66_5_and_N2_N77_66_66_5_and_N2_N78_66_66_5}    SEPARATOR=
...    BD1FF823C7C1800068200D040182000000B1182F1F004001A08034100608000002C460BC9C01000E260003410068200C1000008588C17938
...    02001C4D00068200D040182000010B11820142080480030062026404D17400428246893A74ED8E7C38D1274E9DB1CF87222449D3A76C73E1
...    C8891274E9DB1CF86009020C631864DE680430100400800020100008040002012018020050020040C0180380400804010080201020080401
...    008100402000002000200808010020

${N38_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D84BAC1184341020F901A00CAD93156243
...    9F604F88E3C62471E439F51CF9863CA1607038784FFFFFE003FFFFF8002E0000702A0D851AC1184341020F941A00CAD931562439F11C7B02
...    7C62471E439F51CF9863CA1607038784FFFFFE003FFFFF8002E0000702A8D899AC1184341020E906802CB64C550D0E7C471E819F604F8C73
...    E618F28581C0E1E05C00FFC007003FF0005C0000E0551B137582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C
...    0B801FF800E007FE000B80001C00178784A001C4D00000016020401C025805101320268BA000780614489B1CF8602808CF417001E00140E0
...    A00E0601280380030120020301F01C01000000008000010040000100200000C01000008008000050040000300200001C076465646D654565
...    4D6525652D606D654D01C1000009652504000065949410000296525040000E594941000049652504000165949410000696525040001E5949
...    407523AAA47954AAAA9565529AAA539540F2A95650B0024006814000010500400A00400C010020500C01A010024018031AA1F00010203040
...    6070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

${N38_N78_1_3}    SEPARATOR=
...    BD1FF80BC7C25000E2680030000604000002C46080500000A012C028809901345D0004A031A2449D3B639F0C01402319379A000C14010028
...    01003004008140100280400900600C10020100402008041002010040200804

${N41_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D84BAC1184341020E8068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13801FF800E007FE000B80001C0A836146B04610D04083A41A00CAD931562439F11C7B027
...    C62471E439F51CF9863CA1607038784E007FE003801FF8002E0000702A8D899AC1184341020E906802CB64C550D0E7C471E819F604F8C73E
...    618F28581C0E1E05C00FFC007003FF0005C0000E0551B137582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0
...    B801FF800E007FE000B80001C0027838980000002C040BC3C28000E260000010B010200E012C028809901345D00064050226C73E1C289136
...    39F0C01C086307A0B800F000A070500703009401C0018090010180F80E008000000040000080200000801000006008000040040000280200
...    00180100000E03B232B236B292B296B066B062B036B2A680E0800004B29282000032CA4A0800014B29282000072CA4A0800024B292820000
...    B2CA4A0800034B292820000F2CA4A03A91D5523CAA53554A72A8365506AAA07954AB285801200340A000100080400810100400804020041A
...    A1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

${N77_1_3_and_N41_N77_1_3}    SEPARATOR=
...    BD1FF813C5C4C00060000C0800000588C178F850001C4C00060000C0800008588C100A000014025805101320268BA001040A2449D3B639F0
...    E344893A76C73E18003808630326F3401100804008000100800040230100400804020040000804000201

*** Test Cases ***
CB007219-ET-AB05_Verify successful EN-DC setup and NR CA configuration with MFBI and CNI-81817 is enabled
    [Documentation]
    ...    1. This user scenario describes the successful EN-DC setup and NR CA configuration when the target PSCell and
    ...    NR SCell operate in multiple bands when CNI-81817 is enabled.At equal maximum aggregated channel bandwidth,
    ...    when CNI-81817 is active but CNI-80045 is not, gNB-CU selects the band combinations and all its associated FSEIs
    ...    with lowest position in the UE MRDC capability.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    CNI-81817:NRBTS/actHighestEstNrTputBcSel=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 40 40 40 20
    ...    DL MIMO Layers 2L 2L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N71 N2 N2 N78 N78 N38 N38
    ...    Alternative band NA NA N25 NA N77 N77 N41 NA
    ...    UE1 capability: LTE cell1 + NR cell11+ NR cell3+NR cell4, blind scell addition
    ...    NR bands LTE bands
    ...    BC#1: DC_66A-n25A            n25 LTE-66 LTE-66 LTE-5
    ...    FSEI#1: DL MIMO layers       4L 4L
    ...    DL ChBw (MHz)                20
    ...    BC#2: DC_5A_66A_66A_n2A      n2
    ...    FSEI#1: DL MIMO layers       4L 4L 4L 4L
    ...    DL ChBw (MHz)                20
    ...    BC#3: DC_5A-66A-66A-n2A-n77A n2 n77
    ...    FSEI#1: DL MIMO layers       4L 2L 2L 4L 4L
    ...    DL ChBw (MHz)                20 40
    ...    FSEI#2: DL MIMO layers       2L 4L 2L 2L 4L
    ...    DL ChBw (MHz)                20 40
    ...    BC#4: DC_5A-66A-66A-n2A-n78A n2 n78
    ...    FSEI#1: DL MIMO layers       4L 2L 2L 4L 4L
    ...    DL ChBw (MHz)                20 40
    ...    FSEI#2: DL MIMO layers       2L 4L 2L 2L 4L
    ...    DL ChBw (MHz)                20 40
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell1 and trigger EN-DC setup toward the SgNB to NR cell13, Start DL/UL traffic
    ...    b. check counters.
    ...    4. Expectation:
    ...    a. NR cell13 is PSCell and cell1 is added as scell. BC#3FSEI#2 is selected.(Lowest position index in
    ...    supportedBandCombination and max Data Rate)
    ...    BC#3: DC_5A-66A-66A-n2A-n77A n2 n77
    ...    FSEI#2: DL MIMO layers       2L 4L 2L 2L 4L
    ...    DL ChBw (MHz)                20 40
    [Tags]    ha.zheng    QC_322191    AB05    CA_LABEL-FT(20MHZ_FDD_n2+40MHZ_TDD_n77)
    Clear Counter Files    wait=${False}
    blind CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=11    cell=1    target_cells=13    SA_Capa_perUE_Full=${N2_N77_and_N2_N78}    bc_list_mrdc=2:1|3:1|4:2|3:2|4:1|1:1
    ...    ue_mrdc_cap=${N25_66_66_5_and_N2_66_66_5_and_N2_N77_66_66_5_and_N2_N78_66_66_5}    pass_CA=${N2_N77_CA_succ}
    Check Counters    ${PM_Counters_Check_AB05}
    Check Wireshark Log    ${CURDIR}${/}A2A_AB05${/}a2a_gnb.ini    wait_string=UEContextReleaseComplete::2

CB007219-ET-AB06_Successful EN-DC setup with NR CA configuration with MFBI and both CNI-81817 and CNI-80045 are enabled
    [Documentation]
    ...    1. This user scenario describes the successful EN-DC setup and NR CA configuration when the target PSCell and
    ...    NR SCell operate in multiple bands when CNI-81817 and CNI-80045 are enabled.When both CNI-81817 and CNI-80045
    ...    are enabled, at equal maximum aggregated channel, gNB-CU selects the cell combination associated to the first
    ...    band combination which is first in the allowedBC-ListMRDC received from MeNB with all associated FSEIs.
    ...    Besides, when there is the choice between two carriers in the same band, gNB-CU selects the one with lower
    ...    NRCELL MOC instance value. gNB-DU selects the band combination and FSEI which provides highest data throughput.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    CNI-81817:NRBTS/actHighestEstNrTputBcSel=true
    ...    CNI-80045:NRBTS:actAllowedBcListMrdcPrioBcSel=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 40 40 40 20
    ...    DL MIMO Layers 2L 2L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N71 N2 N2 N78 N78 N38 N38
    ...    Alternative band NA NA N25 NA N77 N77 N41 NA
    ...    UE1 capability: LTE cell1 + NR cell11+ NR cell3+NR cell4, blind scell addition
    ...    NR bands LTE bands
    ...    BC#1: DC_66A-n25A            n25 LTE-66 LTE-66 LTE-5
    ...    FSEI#1: DL MIMO layers       4L 4L
    ...    DL ChBw (MHz)                20
    ...    BC#2: DC_5A_66A_66A_n2A      n2
    ...    FSEI#1: DL MIMO layers       4L 4L 4L 4L
    ...    DL ChBw (MHz)                20
    ...    BC#3: DC_5A-66A-66A-n2A-n77A n2 n77
    ...    FSEI#1: DL MIMO layers       4L 2L 2L 4L 4L
    ...    DL ChBw (MHz)                20 40
    ...    FSEI#2: DL MIMO layers       2L 4L 2L 2L 4L
    ...    DL ChBw (MHz)                20 40
    ...    BC#4: DC_5A-66A-66A-n2A-n78A n2 n78
    ...    FSEI#1: DL MIMO layers       4L 2L 2L 4L 4L
    ...    DL ChBw (MHz)                20 40
    ...    FSEI#2: DL MIMO layers       2L 4L 2L 2L 4L
    ...    DL ChBw (MHz)                20 40
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell1 and trigger EN-DC setup toward the SgNB to NR cell13, Start DL/UL traffic
    ...    b. check counters.
    ...    4. Expectation:
    ...    a. NR cell13 is PSCell and cell1 is added as scell. BC#3FSEI#2 is selected.(Lowest position index in
    ...    CG-ConfigInfo->configRestrictInfo->allowedBC-ListMRDC and max Data Rate)
    ...    BC#3: DC_5A-66A-66A-n2A-n77A n2 n77
    ...    FSEI#2: DL MIMO layers       2L 4L 2L 2L 4L
    ...    DL ChBw (MHz)                20 40
    [Tags]    ha.zheng    QC_322195    AB06    CA_LABEL-FT(20MHZ_FDD_n2+40MHZ_TDD_n77)
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_AB06_1}
    blind CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=11    cell=1    target_cells=13    SA_Capa_perUE_Full=${N2_N77_and_N2_N78}    bc_list_mrdc=2:1|3:1|4:2|3:2|4:1|1:1
    ...    ue_mrdc_cap=${N25_66_66_5_and_N2_66_66_5_and_N2_N77_66_66_5_and_N2_N78_66_66_5}    pass_CA=${N2_N77_CA_succ}
    Check Counters    ${PM_Counters_Check_AB06}
    Check Wireshark Log    ${CURDIR}${/}A2A_AB06${/}a2a_gnb.ini    wait_string=UEContextReleaseComplete::2
    [Teardown]    AB06_Teardown

CB007219-ET-AB11_Successful EN-DC setup and NR CA with the NR Cell in the native band with small dedicated BWP
    [Documentation]
    ...    1. This user scenario describes the successful setup of EN-DC setup and NR CA configuration when the NR SCell
    ...    is selected to operate in the alternative band with a dedicated small BWP. (USCB007219-AB#B9)
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    CB007552:actMultipleDedicatedBWPs=true
    ...    CB008541:actEnhMultipleDedicatedBWPs=true
    ...    alternative band configuration as below:
    ...    cell_11 cell_12 cell_13 cell_14 cell_1 cell_2 cell_3 cell_4
    ...    Technology type     FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency           F0 F1 F2 F3 F4 F5 F6 F7
    ...    chbw                20 20 20 20 100 100 40 20
    ...    Small BWP                       80 80 20
    ...    DL MIMO Layers      2L 2L 4L 4L 4L 4L 4L 4L
    ...    Native band         n66 n71 n2 n2 n78 n78 n38 n38
    ...    Alternative band           n25    n77 n77 n41
    ...    UE1 capability: LTE cell3 + NR cell1+ NR cell3, blind scell addition
    ...    NR bands LTE bands
    ...    BC#1: DC_1A-3A-n38A- n78A    n38 n78 LTE-1 LTE-3
    ...    FSEI#1: DL MIMO layers       4L 4L 4L 4L
    ...    DL ChBw (MHz)                20 80
    ...    FSEI#2: DL MIMO layers       2L 4L 2L 2L
    ...    DL ChBw (MHz)                20 100
    ...    FSEI#3: DL MIMO layers       4L 2L 4L 4L
    ...    DL ChBw (MHz)                20 100
    ...    UE2 capability: LTE cell3 + NR cell2+ NR cell3, A1 scell addition
    ...    NR bands LTE bands
    ...    BC#1: DC_1A-3A-n77A          n77
    ...    FSEI#1: DL MIMO layers       4L 4L 4L
    ...    DL ChBw (MHz)                80
    ...    BC#2: DC_1A-3A-n41-n77A      n41 n77
    ...    FSEI#1 DL MIMO layers        4L 4L 2L 2L
    ...    DL ChBw (MHz)                20 80
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell3 and trigger EN-DC setup toward the SgNB to NR cell1, Start DL/UL traffic
    ...    b. attach UE12 to LTE cell3 and trigger EN-DC setup toward the SgNB to NR cell2, Start DL/UL traffic
    ...    b. check counters.
    ...    4. Expectation:
    ...    a. NR cell1 is PSCell and cell3 is added as scell. BC#1FSEI#2 is selected.
    ...    b. NR cell2 is PSCell and cell3 is added as scell. BC#2FSEI#1 is selected.
    [Tags]    ha.zheng    QC_322202    AB11    CA_LABEL-TT(20MHZ_TDD_n38+100MHZ_TDD_n78)    CA_LABEL-TT20MHZ_TDD_n41+80MHZ_TDD_n77)
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_AB11_1}
    Enable testmode for TT
    blind CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=11    cell=3    target_cells=1    SA_Capa_perUE_Full=${N38_N78}    bc_list_mrdc=1:1|1:3|1:2
    ...    ue_mrdc_cap=${N38_N78_1_3}    pass_CA=${N78_N38_CA_succ}    times=4    min_dl_tput=550
    covBasedA1 CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=12    cell=3    target_cells=2    SA_Capa_perUE_Full=${N41_N77}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${N77_1_3_and_N41_N77_1_3}    carrierfreq=648096
    ...    pass_PCell=${N77_PCell}    pass_SCell=${N41_SCell}
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_AB11${/}a2a_gnb.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_Check_AB11}
    [Teardown]    AB11_Teardown

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
    ${C_4}    catenate
    ...    set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=519000:519000 gscn=6462 mandatory_for_activation=off bwp_arfcn=517020:517020
    ${C_5}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=648000:648000 gscn=8000 mandatory_for_activation=off bwp_arfcn=647328:647328
    ${C_6}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633000:633000 gscn=7840 mandatory_for_activation=off bwp_arfcn=632328:632328
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    ${C_3}
    Update Cfg    ${C_4}
    Update Cfg    ${C_5}
    Update Cfg    ${C_6}

Update UE capa
    [Arguments]    ${ue_id}=16    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_mrdc_cap}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair

AB06_Teardown
    OnlineParamChange    ${OnlineParam_AB06_2}
    Common Test Teardown And Stop Capture Logs

AB11_Teardown
    Execute Egate Command    ue_testmode_set_nr id=11,12 testmode=csi_override action=activate profile_id=2 scell=8
    sleep    1s    #sleep for stable traffic
    OnlineParamChange    ${OnlineParam_AB11_2}
    Common Test Teardown And Stop Capture Logs

blind CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${cell}=1    ${target_gnb}=2    ${target_cells}=13    ${bearer_id}=2
    ...    ${bc_list_mrdc}=2:1|3:1|4:1|3:2|4:2|1:1    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${pass_CA}=none
    ...    ${times}=3    ${min_dl_tput}=420
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_CA}    timeout=20s
    Send Throughput    ue_id=${ue_id}    times=${times}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    min_dl_tput=${min_dl_tput}
    Release Ues    ue_type=all

covBasedA1 CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${cell}=1    ${target_gnb}=2    ${target_cells}=13    ${bearer_id}=2    ${carrierfreq}=648096
    ...    ${bc_list_mrdc}=2:1|3:1|4:1|3:2|4:2|1:1    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${pass_PCell}=none
    ...    ${pass_SCell}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_PCell}    timeout=20s
    Send Throughput    ue_id=${ue_id}
    Add gNB Cell1 As Scell By A1    ue_id=${ue_id}    carrierfreq=${carrierfreq}    pass_CA=${pass_SCell}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=92    ${carrierfreq}=648096    ${srsrp_nr}=90    ${srsrq_nr}=90    ${pass_CA}=none
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...    pass_regexp=${pass_CA}

Send Throughput
    [Arguments]    ${ue_id}=11    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Check Traffic
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

Enable testmode for TT
    [Arguments]    ${ue_id}=11,12
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1    pass_regexp=numOfCri
    sleep    1s    #sleep for stable traffic
    Execute Egate Command    csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3    pass_regexp=numOfCri
    sleep    1s    #sleep for stable traffic
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=8
    sleep    1s    #sleep for stable traffic
