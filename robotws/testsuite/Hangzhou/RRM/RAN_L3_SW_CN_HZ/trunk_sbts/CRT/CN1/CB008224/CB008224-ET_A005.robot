*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_FDD    SBTS00    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...            owner-yige.g.zhang    team-CN1ET    release-SBTS24R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}    4681
@{PARAMS_IN_SCF}
...    @{freqency_A005_PRI}
...    @{CB007552_CB008541_useDedicatedBwp_pri}
...    @{7219}
...    @{PARAMS_FOR_8224_GNB1}
...    @{PARAMS_FOR_CA}
...    NRCELL:actSib1ForNsaCell=true
...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=25
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:actNgcFlexSaMode=true
#...    NRBTS:actSlowPrbPooling=true
#...    NRBTS:actConnRrcPooling=true
#...    NRBTS:actScheUePooling=true


@{PARAMS_IN_SCF_GNB2}
...    @{CB007552_CB008541_useDedicatedBwp_ext}
...    @{7219}
...    @{1416}
...    @{PARAMS_FOR_8224_GNB2}
...    @{PARAMS_FOR_CA}
...    NRCELL:actSib1ForNsaCell=true
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS:actNgcFlexSaMode=true
#...    NRBTS:actSlowPrbPooling=true
#...    NRBTS:actConnRrcPooling=true
#...    NRBTS:actScheUePooling=true
...    NRCELL-1:fPdcchMonOccsnPo=2
...    NRCELL-2:fPdcchMonOccsnPo=2


@{freqency_A005_PRI}
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=432500
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=352500
...    NRCELL-11:gscnOrSsPbchArfcn=5404


@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
@{1416}
#...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS/NRSYSINFO_PROFILE-3:addHystSfHigh=dB-2
...    NRBTS/NRSYSINFO_PROFILE-3:addHystSfMedium=dB-2
...    NRBTS/NRSYSINFO_PROFILE-3:nCellChangeHigh=16
...    NRBTS/NRSYSINFO_PROFILE-3:nCellChangeMedium=14
...    NRBTS/NRSYSINFO_PROFILE-3:qHyst=dB0
...    NRBTS/NRSYSINFO_PROFILE-3:siWindowLength=s40
...    NRBTS/NRSYSINFO_PROFILE-3:systemInformationTargetRate=500
...    NRBTS/NRSYSINFO_PROFILE-3:tEvaluation=s30
...    NRBTS/NRSYSINFO_PROFILE-3:tHystNormal=s30
...    NRBTS/NRSYSINFO_PROFILE-3:tReselectionEutra=0
...    NRBTS/NRSYSINFO_PROFILE-3:threshServingLowP=0

...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType2

...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType3

...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType4

...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType5

...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType6

...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType7

...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType8

...    NRBTS/NRSYSINFO_PROFILE-3/NRIAFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-3/NRIAFIM-1:sIntraSearchP=22
...    NRBTS/NRSYSINFO_PROFILE-3/NRIAFIM-1:tReselectionNr=1


...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:dlCarrierFreq=127180
...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:dssCellsDeployed=false
...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:freqBandIndicatorNR=2
...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:qOffsetFreq=-4dB
...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:ssbScs=15KHz
...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:tReselectionNr=1
...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:threshXHighP=30
...    NRBTS/NRSYSINFO_PROFILE-3/NRIRFIM-1:threshXLowP=22

...    NRBTS/NRSYSINFO_PROFILE-3/NRLIM-1:allowedMeasBw=mbw100
...    NRBTS/NRSYSINFO_PROFILE-3/NRLIM-1:carrierFreq=40890
...    NRBTS/NRSYSINFO_PROFILE-3/NRLIM-1:pMaxEutra=23
...    NRBTS/NRSYSINFO_PROFILE-3/NRLIM-1:presenceAntPort1=false
...    NRBTS/NRSYSINFO_PROFILE-3/NRLIM-1:qQualMin=-34
...    NRBTS/NRSYSINFO_PROFILE-3/NRLIM-1:qRxLevMin=-22
...    NRBTS/NRSYSINFO_PROFILE-3/NRLIM-1:threshXHigh=2
...    NRBTS/NRSYSINFO_PROFILE-3/NRLIM-1:threshXLow=0



...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=28

...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-3
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-3
...    NRCELL-13:nrSysInfoProfileDN=MRBTS-1/NRBTS-2/NRSYSINFO_PROFILE-3

...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=25

...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=25

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1


@{CB007552_CB008541_useDedicatedBwp_pri}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true

@{CB007552_CB008541_useDedicatedBwp_ext}
...    NRCELL-13:type0CoresetConfigurationIndex=0
...    NRCELL-13:gscnOrSsPbchArfcn=4876
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true

...    NRBTS/BWP_PROFILE-16:bwpType=initial
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-16/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3

...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-38:bwpType=dedicated
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthUl:cRbSizeUl=n133
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-38/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-37:bwpType=dedicated
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-37/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDSCH-1:pdschRat0RbgConfig=config1
#n66    40Mhz ,25Mhz
...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-16
...    NRCELL-13:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-16

...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-38
...    NRCELL-13:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-38

...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-37
...    NRCELL-13:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-37
...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-16
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-38
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-37



@{OnlineParam_A005_PRI}
...    NRCELL-12:administrativeState=Unlocked
@{OnlineParam_A005_EXT}
...    NRCELL-13:administrativeState=Unlocked
...    NRCELL-14:administrativeState=Unlocked



@{PARAMS_FOR_8224_GNB1}
...    NRCELL-12:administrativeState=Locked     #Sunil will provide the IMprovment
# FDD SDL CELL
...    NRCELL-12:nrCellType=2DL0UL
...    NRCELL-12:cellBarred=barred
...    NRCELL-12:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=0MHz
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-11:pMax=400
...    NRCELL-12:pMax=400
...    NRBTS:actIncXn=true

@{PARAMS_FOR_CA}
...    NRBTS:actRanSharing=false
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:actCDrx=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=2
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:actInterGnbCa=DLOnly

@{PARAMS_FOR_8224_GNB2}
...    NRCELL-13:administrativeState=Locked     #Sunil will provide the IMprovment
...    NRCELL-14:administrativeState=Locked
# FDD SDL CELL
...    NRCELL-13:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-13:nrCellType=4DL0UL
...    NRCELL-13:cellBarred=barred
...    NRCELL-13:intraFreqReselection=notAllowed
...    NRCELL-13/NRCELL_FDD-1:chBwUl=0MHz
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-2
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-3:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-3
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-4
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-14:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-14:nrCellType=4DL0UL
...    NRCELL-14:cellBarred=barred
...    NRCELL-14:intraFreqReselection=notAllowed
...    NRCELL-14/NRCELL_FDD-1:chBwUl=0MHz
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-2:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-2
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-3:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-3
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-4:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-4

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=2
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=392000
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=2
...    NRBTS/NRADJNRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly

...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=forbidden
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly

...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=forbidden
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly

...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind

...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=111
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=320ms

...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRCELL-1:weightForSCellSelection=10
...    NRCELL-2:weightForSCellSelection=10
...    NRCELL-13:weightForSCellSelection=80
...    NRCELL-14:weightForSCellSelection=80

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
...    NRBTS/NRADJNRCELL-11:nrarfcn=431000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=66

...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=431000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=66


...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly

...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

${LOOP}    3

*** Test Cases ***
CB008224-ET-A005_include_SDL_band_SDL_cell_and_FDD_band_SDL_cell_in_EN-DC_X2_and_Xn_Interface_adaptation
    [Documentation]
    ...    1. Xn/X2 procedures for SDL cells in SDL bands and FDD bands
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                        GNB1    Cell-11    Cell-12    GNB2    Cell-1    Cell-2    Cell-13    Cell-14
    ...    Technology                    FDD    FDD SDL          TDD     TDD        FDD SDL     FDD SDL
    ...          Band                    n66    n66             n77         n77     n2/n25      n28
    ...           Pci                     60     61             50          51       62         63
    ...     Bandwidth                     15     40             100         40       25,15      15
    ...        Arfcn<DL/UL>       432500/352500    431000    430900/348920     126900/136100     430900/348920     126900/136100
    ...        nrCellType             2DL2UL    2DL0UL    2DL2UL      2DL2UL      4DL0UL    4DL0UL
    ...    NRCELL:actSib1ForNsaCell=true
    ...    3. Test Case Steps:
    ...           a. All CELLs on air except SDL NRCELL-12,13,14
    ...           b. trigger SDL NRCELL-12,13,14 unlocked.
    ...           c. trigger SDL NRCELL-12,13,14 locked and unlocked 3 times
    ...           d. trigger NG link drop which is AMF to both GNBS
    ...    4. Expected Results:
    ...           a. All CELLs on air. bi-directional cells scheduling mib and sibs.SDL cells scheduling only mib.
    ...           b-d. same with step a.
    [Tags]    A005    QC_46905
    Clear Counter Files for 2GNB
    OnlineParamChange    ${OnlineParam_A005_PRI}    ${OnlineParam_A005_EXT}
    SDL CELL LOCK Unlock
    Drop Ng Link         #after PR748896 resolved
    Check cells on Air
    #Check Counters    ${PM_Counters_GA009_PRIM}
    #Check Counters GNB2    ${PM_Counters_GA009_EXT}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2F_N66_gnb2_2T2F_N2_N28

Drop Ng Link
    execute egate command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown    NG Link Drop
    execute egate command    link_drop link=ng by=amf:1 to=gnb:3 msg_type=shutdown    NG Link Drop
    Sleep    30s

SDL CELL LOCK Unlock
    FOR    ${index}    IN RANGE    0    ${LOOP}
         Lock Cell12
         Lock GNB2 Cell1
         Lock GNB2 Cell13
         Lock GNB2 Cell14
         Unlock Cell12
         Unlock GNB2 Cell1
         Unlock GNB2 Cell13
         Unlock GNB2 Cell14
         Check cells on Air
    END

Lock GNB2 Cell${number}
    Delta Commission Parameters GNB2    NRCELL-${number}:administrativeState=Locked
    Cell Should Be Locked GNB2    ${number}

Unlock GNB2 Cell${number}
    Delta Commission Parameters GNB2    NRCELL-${number}:administrativeState=Unlocked
    Cell Should Be Unlocked GNB2    ${number}

Check cells on Air
    Cells Should Be Onair GNB2    cell_id=1    check_sib=${True}    timeout=600
    Cells Should Be Onair GNB2    cell_id=2    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=11    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=12    check_sib=${False}    timeout=600
    Cells Should Be Onair GNB2    cell_id=13    check_sib=${False}    timeout=600
    Cells Should Be Onair GNB2    cell_id=14    check_sib=${False}    timeout=600

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

OnlineParamChange
    [Arguments]    ${Online_Param1}    ${Online_Param2}
    Delta Commission Parameters    ${Online_Param1}
    Delta Commission Parameters GNB2    ${Online_Param2}
    Cells Should Be Onair    cell_id=12    check_sib=${False}    timeout=600
    Cells Should Be Onair GNB2    cell_id=13    check_sib=${False}    timeout=600
    Cells Should Be Onair GNB2    cell_id=14    check_sib=${False}    timeout=600

Modify Cfg
    ${Update_Cfg_Cell_12}    Catenate
    ...    set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=355000:374000 mandatory_for_activation=off gscn=4675 is_fr1sdl_cell=on
    ${Update_Cfg_Cell_13}    Catenate
    ...    set_cell id=13 gnb=3 pci=20:2 tac=200 nrci=0x0D tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=349400:368400 mandatory_for_activation=off gscn=4605 is_fr1sdl_cell=on
    ${Update_Cfg_Cell_14}    Catenate
    ...    set_cell id=14 gnb=3 pci=21:0 tac=200 nrci=0x0E tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=143400:153400 mandatory_for_activation=off gscn=1916 is_fr1sdl_cell=on

    Update Cfg    ${Update_Cfg_Cell_12}
    Update Cfg    ${Update_Cfg_Cell_13}
    Update Cfg    ${Update_Cfg_Cell_14}




