*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-Tingjian.Mao
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{cell_frequency}
...    @{1416}
...    @{MimoMode_Para}
...    @{CB007552_CB008541}
...    @{PARAMS_HO}
...    @{7219}

@{cell_frequency}
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-1:gscnOrSsPbchArfcn=7832
...    NRCELL-1:nrarfcn=633000
...    NRCELL-1:type0CoresetConfigurationIndex=10

@{PARAMS_HO}
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:sMeasConfigSsbRsrp=80
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3OffsetSsbRsrq=20|a3TimeToTriggerSsbRsrq=ms64
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:handoverAllowedSARedCap=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:sCellActivationMethod=blind

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=true

@{CB007552_CB008541}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-7:bwpType=dedicated
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=n133
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb0
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
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
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
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-7/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77       #alternative
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=25       #alternative
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=25
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1

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

${DC_AB16}    SEPARATOR=         #UE11_capa_nr
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623805506C18D608C21A08107CA090195B262AC4873E
...    238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC0000044000702A8D899AC1184341020E90480B2D931543439F11C7A067D813
...    E31CF9863CA16070387817003FF001C00FFC00110001C0AA3626EB04610D04083A41202CB64C550D0E7C471E819F604F8C73E618F28581C0E
...    1E05C00FFC007003FF000440007000DE0E0C0000000B0102F0F0600038980000082C040BC3C18000E268000030B010200E00C400180990134
...    3501280E044D8E7C3851226C73E1C28913639F0C003818C63F413003C00281C1401C0C02500700060240040603E0380200000001000002008
...    00002004000018020000100100000A008000060040000380EC0CAC0DAC98AC9DAC19AC18AC0DACA9A0382000012CA4A080000CB2928200005
...    2CA4A080001CB29282000092CA4A080002CB292820000D2CA4A080003CB29280EA075540F2A94D5527CAA0D9541AAA81E552ACA12009001A0
...    50001800401002000802004101004008040400808080200402010020D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139
...    414951697A0A0C1680
${Capa_LTE_DC_AB16}    SEPARATOR=         #UE11_capa
...    BD1FF81BC5C1800068200C1000000588C178B830001C4C000608000082C460BC7C18000E2680034100608000042C460805082012000C01880
...    9901344D002C81C4893A76C73E1C4891276C73E1C6891274ED8E7C3009018C630064DE6804201004008000201000080460200801008040080
...    001008000402201004008040400800008040

${DC_AB17}    SEPARATOR=         #UE11_capa_nr
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623805506C01D608C21A08107CA090195B262AC4873E
...    238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC0000044000702A8D899AC1184341020E90480B2D931543439F11C7A067D813
...    E31CF9863CA16070387817003FF001C00FFC00110001C0AA3626EB04610D04083A41202CB64C550D0E7C471E819F604F8C73E618F28581C0E
...    1E05C00FFC007003FF000440007000DE0E008000000B0102F0F0040038980000082C040BC3C01000E268000030B010200E00C400180990134
...    3501280E044D8E7C3851226C73E1C28913639F0C003818C63F413003C00281C1401C0C02500700060240040603E0380200000001000002008
...    00002004000018020000100100000A008000060040000380EC0CAC0DAC98AC9DAC19AC18AC0DACA9A0382000012CA4A080000CB2928200005
...    2CA4A080001CB29282000092CA4A080002CB292820000D2CA4A080003CB29280EA075540F2A94D5527CAA0D9541AAA81E552ACA12009001A0
...    50001800401002000802004101004008040400808080200402010020D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139
...    414951697A0A0C1680
${Capa_LTE_DC_AB17}    SEPARATOR=         #UE11_capa
...    BD1FF81BC5C0100068200C1000000588C178B802001C4C000608000082C460BC7C01000E2680034100608000042C460805082012000C01880
...    9901344D002C81C4893A76C73E1C4891276C73E1C6891274ED8E7C3009018C630064DE6804201004008000201000080460200801008040080
...    001008000402201004008040400800008040

@{pm_couter_AB16}
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1
...    NRCELL-1:${SCELL_CONF_ALT_BAND_NSA}=2

@{pm_couter_AB17}
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-1:${SCELL_CONF_ALT_BAND_NSA}=3

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

@{nsa_ue_attach_expect}
...    pcid:62, scellIdx:8
...    Successfully reconfigured dual connectivity
...    reported successful RA
...    PhysCellId: 50] SCellIndex 9 activated successfully at airphone

@{Intra_LTE1_CELL2}
...    Intra-eNB handover from ENB-1.1 to ENB-1.2
...    reported successful RA
...    PhysCellId: 50] SCellIndex 9 activated successfully at airphone

@{Intra_LTE1_CELL1}
...    Intra-eNB handover from ENB-1.2 to ENB-1.1
...    reported successful RA
...    PhysCellId: 50] SCellIndex 9 activated successfully at airphone

@{Inter_LTE11_CELL1}
...    Inter-eNB handover from ENB-1.1 to ENB-11.1
...    reported successful RA
...    PhysCellId: 50] SCellIndex 9 activated successfully at airphone

@{Inter_LTE1_CELL1}
...    Inter-eNB handover from ENB-11.1 to ENB-1.1
...    reported successful RA
...    PhysCellId: 50] SCellIndex 9 activated successfully at airphone

@{actMfbiNrCaSupportFr1_false}
...    NRBTS:actMfbiNrCaSupportFr1=false
...    NRBTS:actMfbiNrCaMeasConfResolv=false

@{actMfbiNrCaSupportFr1_true}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=true

*** Test Cases ***
CB007219-ET-AB16_Verify_MFBI_NSA_CA_Interaction_with_inter-eNB_or_intra-MeNB_handover_without_SgNB_change
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       This user scenario describes the SgNB behavior during an inter-MeNB or intra-MeNB handover without SgNB change
    ...    2. Configuration
    ...    a. NRCELL-1 TDD native:N78 alternative:N77 100Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-13 FDD native:N2 alternative:N25 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-1 is configured as blind scell for NRCELL-13
    ...    b.CB007552 enable:set actMultipleDedicatedBWPs=true; CB008541 enable:actEnhMultipleDedicatedBWPs=true
    ...      5GC001416 enable:actMultiFrequencyBandIndicatorNRSupport=true; CB007219:actMfbiNrCaSupportFr1=true.
    ...      LTE1 is configured with 2 cells. cell1 is band 66 , cell2 is band 5
    ...      LTE2 is configured with 1 cell. cell1 is band 5.
    ...    c.ue capability:
    ...    BC#3: DC_5A-66A-n25A-n78A      n25    n78
    ...    DL FSEI#1    DL MIMO layers    4L    4L
    ...                 DL ChBw (MHz)     20    50
    ...    BC#2: DC_5A-n25A-n77A          n25    n77
    ...    DL FSEI#1    DL MIMO layers    4L    4L
    ...                 DL ChBw (MHz)     20    100
    ...    BC#1: DC_5A-66A-n25A           n25
    ...    DL FSEI#1    DL MIMO layers    4L
    ...                 DL ChBw (MHz)     20
    ...    3. Test Case Steps:
    ...     a. Attach UE to LTE1 cell1 and trigger EN-DC setup with NRCELL-13
    ...     b. trigger intra-MeNB HO from LTE1 cell1 to cell2.
    ...     c. trigger intra-MeNB HO from LTE1 cell2 to cell1.
    ...     d. trigger inter-MeNB HO from LTE1 cell1 to LTE2 cell1.
    ...     e. trigger inter-MeNB HO from LTE2 cell1 to LTE1 cell1.
    ...     f. check counters and A2A
    ...    4. Expected Results:
    ...     a. NR cell13 is PSCell and cell1 is added as scell. BC#3FSEI#1 is selected. traffic is OK.
    ...     b. NR cell13 is PSCell and cell1 is added as scell. BC#2FSEI#1 is selected. traffic is OK.
    ...     c. NR cell13 is PSCell and cell1 is added as scell. BC#3FSEI#1 is selected. traffic is OK.
    ...     d. NR cell13 is PSCell and cell1 is added as scell. BC#2FSEI#1 is selected. traffic is OK.
    ...     e. NR cell13 is PSCell and cell1 is added as scell. BC#3FSEI#1 is selected. traffic is OK.
    ...     f. check counters and A2A successfully
    [Tags]    QC_322200    AB16    CA_LABEL-FT(20MHZ_FDD_n25+100MHZ_TDD_n77)    CA_LABEL-FT(20MHZ_FDD_n25+50MHZ_TDD_n78)
    Setup X2 lINK and Allowed ENDC on with eNB
    clear counter files    wait=${False}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    SA_Capa_perUE_Full=${DC_AB16}
    ...    ue_mrdc_cap=${Capa_LTE_DC_AB16}
    Trigger intra-MeNB HO    enb_id=1    CELL_id=2    mrdc_id=3:1|2:1|1:1    ho_expect=${Intra_LTE1_CELL2}
    Trigger intra-MeNB HO    enb_id=1    CELL_id=1    mrdc_id=3:1|1:1    ho_expect=${Intra_LTE1_CELL1}
    Trigger inter-MeNB HO    enb_id=11    CELL_id=1    mrdc_id=3:1|2:1|1:1    ho_expect=${Inter_LTE11_CELL1}
    Trigger inter-MeNB HO    enb_id=1    CELL_id=1    mrdc_id=3:1|1:1    ho_expect=${Inter_LTE1_CELL1}
    Release Ues    ue_type=nsa    ue_id=11
    Check Wireshark Log    ${CURDIR}${/}A2A_AB16${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    check counters    pm_counters_expression=${pm_couter_AB16}

CB007219-ET-AB17_Verify_MFBI_NSA_CA_Interaction_with_inter-eNB_or_intra-MeNB_handover_without_SgNB_change_with_online_modification
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       This user scenario describes the SgNB behavior during an inter-MeNB or intra-MeNB handover without SgNB change
    ...    2. Configuration
    ...    a. NRCELL-1 TDD native:N78 alternative:N77 100Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-13 FDD native:N2 alternative:N25 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-1 is configured as blind scell for NRCELL-13
    ...    b.CB007552 enable:set actMultipleDedicatedBWPs=true; CB008541 enable:actEnhMultipleDedicatedBWPs=true
    ...      5GC001416 enable:actMultiFrequencyBandIndicatorNRSupport=true; CB007219:actMfbiNrCaSupportFr1=true.
    ...      LTE1 is configured with 2 cells. cell1 is band 66 , cell2 is band 5
    ...      LTE2 is configured with 1 cell. cell1 is band 5.
    ...    c.ue capability:
    ...    BC#3: DC_5A-66A-n2A-n78A       n2    n78
    ...    DL FSEI#1    DL MIMO layers    4L    4L
    ...                 DL ChBw (MHz)     20    50
    ...    BC#2: DC_5A-66A-n2A-n77A           n2    n77
    ...    DL FSEI#1    DL MIMO layers    4L    4L
    ...                 DL ChBw (MHz)     20    100
    ...    BC#1: DC_5A-66A-n2 A           n2
    ...    DL FSEI#1    DL MIMO layers    4L
    ...                 DL ChBw (MHz)     20
    ...    3. Test Case Steps:
    ...     a. Attach UE to LTE1 cell1 and trigger EN-DC setup with NRCELL-13 then online modify NRBTS/actMfbiNrCaSupportFr1 from true to false
    ...     b. trigger intra-MeNB HO from LTE1 cell1 to cell2.
    ...     c. trigger intra-MeNB HO from LTE1 cell2 to cell1.
    ...     d. online modify NRBTS/actMfbiNrCaSupportFr1 from false to true
    ...     e. trigger inter-MeNB HO from LTE1 cell1 to LTE2 cell1.
    ...     f. trigger inter-MeNB HO from LTE2 cell1 to LTE1 cell1.
    ...     g. check counters and A2A
    ...    4. Expected Results:
    ...     a. NR cell13 is PSCell and cell1 is added as scell. BC#2FSEI#1 is selected. traffic is OK.
    ...        online modification successfully.
    ...     b. NR cell13 is PSCell and cell1 is added as scell. BC#3FSEI#1 is selected. traffic is OK.
    ...     c. NR cell13 is PSCell and cell1 is added as scell. BC#3FSEI#1 is selected. traffic is OK.
    ...     d. Online modification successfully.
    ...     e. NR cell13 is PSCell and cell1 is added as scell. BC#2FSEI#1 is selected. traffic is OK.
    ...     f. NR cell13 is PSCell and cell1 is added as scell. BC#2FSEI#1 is selected. traffic is OK.
    ...     g. check counters and A2A successfully
    [Tags]    QC_322199    AB17    CA_LABEL-FT(20MHZ_FDD_n2+100MHZ_TDD_n77)    CA_LABEL-FT(20MHZ_FDD_n2+50MHZ_TDD_n78)
    Setup X2 lINK and Allowed ENDC on with eNB
    clear counter files
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    SA_Capa_perUE_Full=${DC_AB17}
    ...    ue_mrdc_cap=${Capa_LTE_DC_AB17}    mrdc_id=3:1|2:1|1:1
    OnlineParamChange    ${actMfbiNrCaSupportFr1_false}
    Trigger intra-MeNB HO    enb_id=1    CELL_id=2    mrdc_id=3:1|2:1|1:1    ho_expect=${Intra_LTE1_CELL2}
    Trigger intra-MeNB HO    enb_id=1    CELL_id=1    mrdc_id=3:1|2:1|1:1     ho_expect=${Intra_LTE1_CELL1}
    OnlineParamChange    ${actMfbiNrCaSupportFr1_true}
    Trigger inter-MeNB HO    enb_id=11    CELL_id=1    mrdc_id=3:1|2:1|1:1    ho_expect=${Inter_LTE11_CELL1}
    Trigger inter-MeNB HO    enb_id=1    CELL_id=1    mrdc_id=3:1|2:1|1:1     ho_expect=${Inter_LTE1_CELL1}
    Release Ues    ue_type=nsa    ue_id=11
    Check Wireshark Log    ${CURDIR}${/}A2A_AB17${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    check counters    pm_counters_expression=${pm_couter_AB17}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_N66_N71_2N78_2N38    ue_count=10

Modify Cfg
    ${C_1}    catenate
    ...    set_cell id=1 enb=1 eci=0x1234601 pci=4:0 tac=222 proxy=$DAEMON_IP:12219|$DAEMON_IP:8889
    ...    earfcn=66886:132322 mandatory_for_activation=off
    ${C_2}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=4:1 tac=222 proxy=$DAEMON_IP:12220|$DAEMON_IP:8890
    ...    earfcn=2525:20525 mandatory_for_activation=off
    ${C_3}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:0 tac=222 proxy=$DAEMON_IP:12227|$DAEMON_IP:8887
    ...    earfcn=2525:20525 mandatory_for_activation=off
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    ${C_3}
    ${C_4}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633000:633000 gscn=7832 mandatory_for_activation=off bwp_arfcn=631320:631320
    Update Cfg    ${C_4}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${ue_id}=11    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

Setup X2 lINK and Allowed ENDC on with eNB
    [Arguments]    ${ue_id}=11    ${enb_id_1}=1    ${enb_id_2}=11
    Execute Egate Command    ue_enb_endc_param id=${ue_id} reset
    Execute Egate Command    ue_enb_param id=${ue_id} reset
    Execute Egate Command    enb_endc_param id=1 reset
    Execute Egate Command    enb_endc_param id=11 reset
    Execute Egate Command    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_x2_link_up enb=${enb_id_1} target=2    pass_regexp=ENB-1: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=${enb_id_2} target=2    pass_regexp=ENB-11: X2AP Link with GNB-2

NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${target_gnb}=2    ${target_cells}=13    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none
    ...    ${mrdc_id}=3:1|1:1
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_perUE_Full}    Capa_LTE=${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${mrdc_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    pass_regexp=${nsa_ue_attach_expect}    timeout=10s
    Send Throuput
    Verify Throuput

Send Throuput
    [Arguments]    ${ue_id}=11
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL

Verify Throuput
    [Arguments]    ${ue_id}=11    ${dl}=300    ${ul}=40
    sleep    10s    sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000>0
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
    ${ue_dl_tput}    Evaluate    ${scell8_tput}+${scell9_tput}
    Should Be True    ${ue_dl_tput}/1000 >${dl}

Trigger intra-MeNB HO
    [Arguments]    ${ue_id}=11    ${mrdc_id}=3:1|2:1|1:1    ${enb_id}=1    ${CELL_id}=2    ${ho_expect}=none
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${mrdc_id}
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${CELL_id} allow_endc=on
    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${enb_id} cell=${CELL_id} rsrp=60:67    pass_regexp=${ho_expect}
    Verify Throuput

Trigger inter-MeNB HO
    [Arguments]    ${ue_id}=11    ${mrdc_id}=3:1|2:1|1:1    ${enb_id}=1    ${CELL_id}=2    ${ho_expect}=none
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${mrdc_id}
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${CELL_id} allow_endc=on
    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${enb_id} cell=${CELL_id} rsrp=60:67    pass_regexp=${ho_expect}
    Verify Throuput


