*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF   SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-zora.wang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{cell_frequency}
...    @{1416}
...    @{MimoMode_Para}
...    @{CB007552_CB008541}
...    @{intra_HO}

@{cell_frequency}
...    NRCELL-1:chBw=50MHz
...    NRCELL-1:type0CoresetConfigurationIndex=10
...    NRCELL-1:freqBandIndicatorNR=77
...    NRCELL-1:gscnOrSsPbchArfcn=7832
...    NRCELL-1:msg1FrequencyStart=11
...    NRCELL-2:freqBandIndicatorNR=77
...    NRCELL-2:gscnOrSsPbchArfcn=7832
...    NRCELL-2:nrarfcn=633000
...    NRCELL-2:type0CoresetConfigurationIndex=10

@{intra_HO}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:sMeasConfigSsbRsrp=80
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3OffsetSsbRsrq=20|a3TimeToTriggerSsbRsrq=ms64

...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:handoverAllowedSARedCap=allowed
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=2

...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:handoverAllowedSARedCap=allowed
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false

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
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-2:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true

...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=41       #alternative
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78       #alternative
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=25       #alternative
...    NRBTS/NRCONNECTMODE_PROFILE-4:multiFreqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

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

${DC_5A-66A-66A-n2A-n77A_and_5A-66A-66A-n2A-n78A}    SEPARATOR=         #UE1_capa_nr
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701FB8D85181AC1184341020E9068036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C4
...    71E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F
...    30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C0
...    0FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE000B8
...    0001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A8360
...    0EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C011787882001C4600
...    0000160205E1E1280071340000085808178B850001C41000E230000020B0102F17060003882001C4D000006160205E1E140007134000020580
...    81707850001C4100000A160205E1E20800711800003058081787882001C4D00000E160205E2E1400071040038820000202C040BC5C28000E23
...    00071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E2300071340000605808178F830001C410
...    00E2300071300000685808178F882001C4C000E2600071300000705808178B882001C4D000E2680000F0B0102F1F104003882001C4D000E268
...    000100B01020120234028809B01060260BA006D84614489B1CF870A244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C28913639F0E1
...    4489B1CF870A244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C68912244D8E7C38D1224489B1CF87
...    1224489B1CF871A2448913639F0C00C888C6318C6318C6318C6318CF417001E00140E0A00E0601280380030120020301F02001000000008000
...    010040000100200000C01000008008000050040000300200001C01000010043032B2A2B262B236B066B062B036B2A6B27680E0800004B29282
...    000032CA4A0800014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A03A81D552AAAA4F5548F2A8365506AAA079
...    54AB285801200340A0010080801002020040084040200401004008402008010080100202004008804028050100E01C04040080808030060200
...    801040401002010020042020100200801002101002004040100210080200402004008080100220100400804008010100200440200400808010
...    02020040088040080101002004040080108080100202008010C0C0300680500A0600400C0080103002006004008180801100400860600400C0
...    38010301000A008010180300701200C0C0180380900620100E00404048030101200C60201C00808070020202401808090063543E0002040608
...    0C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${DC_5A-66A-66A-n2A-n77A_and_5A-66A-66A-n2A-n78A_7103}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701FB8D85181AC1184341020E9068036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C4
...    71E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748360165B262A86873E238F40CFB027C639F
...    30C7942C0E070F0030000C02E007FE003801FF8002F00007000502A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51C
...    F9863CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C794
...    2C0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D80596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C00C000301
...    3801FF800E007FE000BC0001C00140A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE000
...    00FFF800000B80001C0A83600EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000
...    B80001C011787882001C46000000160205E1E1280071340000085808178B850001C41000E230000020B0102F17060003882001C4D000006160
...    205E1E14000713400002058081707850001C4100000A160205E1E20800711800003058081787882001C4D00000E160205E2E14000710400388
...    20000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E230007134
...    0000605808178F830001C41000E2300071300000685808178F882001C4C000E2600071300000705808178B882001C4D000E2680000F0B0102F
...    1F104003882001C4D000E268000100B01020120234028809B01060260BA006D84614489B1CF870A244D8E7C38912244D8E7C38912244D8E7C3
...    851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C68912
...    244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0C00C888C6318C6318C6318C6318CF417001E00140E0A00E0601280380030120
...    020301F02001000000008000010040000100200000C01000008008000050040000300200001C01000010043032B2A2B262B236B066B062B036
...    B2A6B27680E0800004B29282000032CA4A0800014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A03A81D552AA
...    AA4F5548F2A8365506AAA07954AB285801200340A0010080801002020040084040200401004008402008010080100202004008804028050100
...    E01C04040080808030060200801040401002010020042020100200801002101002004040100210080200402004008080100220100400804008
...    01010020044020040080801002020040088040080101002004040080108080100202008010C0C0300680500A0600400C008010300200600400
...    8180801100400860600400C038010301000A008010180300701200C0C0180380900620100E00404048030101200C60201C0080807002020240
...    1808090063543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${Capa_LTE_DC_5A-66A-66A-n2A-n77A_and_5A-66A-66A-n2A-n78A}    SEPARATOR=         #UE1_capa
...    A11FF813C4D040389A001C01000000162205E268201C4C000E008000010B1102012023402800701060268BA000F40A24E8913639F0E24E8913
...    639F0C003808630300220000804040400801002004400010080809006020040080

@{pm_couter_AB22}
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=2
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=2
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1

...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1

@{pm_couter_AB21}
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=0

...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=0

${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501    #The number of radio admission requests for NSA user when admission is requested on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502    #This counter provides the number of admitted NSA users when radio admission is done on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_DU_NSA_ADMISS_MFBI_REQ}    M55115C01501    #This counter provides the number of radio admission requests with MFBI for the NSA user.
#Updated to the PS-Cell in the DU whenever CP-RT receives radio admission request for UE Context Setup or UE Context Modification request.
${SGNB_DU_NSA_ADMISS_MFBI_SUCC}    M55115C01502    #This counter provides the number of radio admitted NSA users with alternative band.
#Updated to the PS-Cell in the DU whenever CP-RT makes successful radio admission for UE Context Setup or UE Context Modification request.
${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503    #The number of radio admission requests for handover for NSA user where admission is requested on
#the alternative band.Updated to the strongest PS-Cell(on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504    #The number of admitted NSA users for handovers where radio admission is done on the alternative
#band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.

@{Intra_HO_expect}
...    reported successful RA
...    Sending SgNB Modification Confirm
...    SgNBModificationConfirm

@{nsa_ue_attach_expect}
...    pcid:50, scellIdx:8
...    Successfully reconfigured dual connectivity
...    reported successful RA

@{Deactivate_CB007219}
...    NRBTS:actMfbiNrCaSupportFr1=false

@{7103_C004_online_PARAMS}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=true
...    NRCELL-1:actRel16DmrsForPusch=true
...    NRCELL-2:actRel16DmrsForPusch=true
...    NRCELL-1:actRel16DmrsForPucchF3=true
...    NRCELL-1:pucchF3Rel16Pi2BpskAlwaysOn=false
...    NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-2:actRel16DmrsForPucchF3=true
...    NRCELL-2:pucchF3Rel16Pi2BpskAlwaysOn=false
...    NRCELL-2:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:actUlDftSOfdm=true
...    NRCELL-2:actUlDftSOfdm=true
...    NRCELL-2:freqBandIndicatorNR=78
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-4

@{attach_pass_7103}
...    @{nsa_ue_attach_expect}
#pucch
...    format3 setup
...    maxCodeRate zeroDot15
...    pi2BPSK enabled
#pusch
...    dmrs-UplinkTransformPrecoding-r16 setup
...    transformPrecoder disabled
...    tp-pi2BPSK enabled
#uplinkconfig
...    powerBoostPi2BPSK TRUE

@{ho_pass_7103}
...    @{Intra_HO_expect}
...    format3 setup
...    maxCodeRate zeroDot15
...    pi2BPSK enabled
...    transformPrecoder disabled
...    tp-pi2BPSK enabled
...    powerBoostPi2BPSK FALSE

@{ho_pass_back_7103}
...    @{Intra_HO_expect}
...    format3 setup
...    maxCodeRate zeroDot15
...    pi2BPSK enabled
...    transformPrecoder disabled
...    tp-pi2BPSK enabled
...    powerBoostPi2BPSK TRUE

@{transformPrecoder_enable_1}
...    rrcConnectionReconfigurationComplete
...    transformPrecoder enabled
...    tp-pi2BPSK enabled

@{transformPrecoder_enable_2}
...    rrcConnectionReconfigurationComplete
...    dmrs-UplinkTransformPrecodingPUCCH-r16 enabled
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    powerBoostPi2BPSK TRUE

@{pm_couter_C004}
...    NRCELL-1:${ACC_UE_CONF_DFT_R16_DMRS_PUSCH}>0
...    NRCELL-1:${ACC_UE_CONF_R16_DMRS_PUCCH_F3}>0
...    NRCELL-1:${DEN_1_SEC_UE_SAMPLE}>0
...    NRCELL-1:${PUSCH_SUC_ANY_TX_DFT_R16_DMRS}>0
...    NRCELL-1:${PUSCH_INI_TX_DFT_R16_DMRS}>0
...    NRCELL-1:${PUSCH_SUC_INI_TX_DFT_R16_DMRS}>0
...    NRCELL-1:${PUCCH_F3_NON_DTX_R16_DMRS}>0
...    NRCELL-1:${PUCCH_F3_DTX_R16_DMRS}>=0

${ACC_UE_CONF_DFT_R16_DMRS_PUSCH}    M55165C00036
${ACC_UE_CONF_R16_DMRS_PUCCH_F3}    M55165C00037
${DEN_1_SEC_UE_SAMPLE}    M55118C00054
${PUSCH_SUC_ANY_TX_DFT_R16_DMRS}    M55370C00032
${PUSCH_INI_TX_DFT_R16_DMRS}    M55370C00034
${PUSCH_SUC_INI_TX_DFT_R16_DMRS}    M55370C00035
${PUSCH_UNSUC_TX_DFT_R16_DMRS}    M55370C00036
${PUCCH_F3_NON_DTX_R16_DMRS}    M55370C00033
${PUCCH_F3_DTX_R16_DMRS}    M55370C00037

*** Test Cases ***
CB007219-ET-AB22_Successful EN-DC setup with a PSCell supporting native and alter band but configured without candidate NR Scells and 7219 disabled
    [Documentation]
    ...    1. This user scenario describes the successful setup of EN-DC when the target PSCell can be configured both in
    ...    native and in alternative band, interaction with mobility.When CB007219 is disabled, gNB behavior is as per the legacy behavior
    ...    by PR562529 where the gNB-DU will select the best band combination, feature set pair which provides maximum throughput for the UE,
    ...    in this case BC#2 and FSEI#2. 5G_RAN_USR_RRM_22221
    ...    2. Configuration
    ...    a. NRCELL-1 TDD native:N77 alternative:N78 50Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-2 TDD native:N77 alternative:N78 100Mhz,small bwp:50MHZ, dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-3 TDD native:N38 alternative:N41 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-4 TDD N38 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-11 FDD N66 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-12 FDD N71 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-13 FDD native:N2 alternative:N25 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-14 FDD N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    b.CB007552 enable:set actMultipleDedicatedBWPs=true; CB008541 enable:actEnhMultipleDedicatedBWPs=true
    ...    5GC001416 enable:actMultiFrequencyBandIndicatorNRSupport=true; CB007219:actMfbiNrCaSupportFr1 set to false.
    ...    c.ue capability:
    ...    BC#1: DC_5A-66A-66A-n2A-n78A    n2    n78
    ...    DL FSEI#1    DL MIMO layers    2L    4L
    ...                 DL ChBw (MHz)     20    100
    ...    UL FSEI#1    UL MIMO layers    2L    4L
    ...                 UL ChBw (MHz)     20    100
    ...    BC#2: DC_5A-66A-66A-n2A-n77A    n2    n77
    ...    DL FSEI#1    DL MIMO layers    2L    4L
    ...                  DL ChBw (MHz)    20    50
    ...    UL FSEI#1    UL MIMO layers    2L    2L
    ...                  UL ChBw (MHz)    20    50
    ...    3. Test Case Steps:
    ...    a. UE11 attach to LTE1 cell1 NRCELL-1.traffic should ok.
    ...       cell 1 in N78 50MHZ.
    ...    b. trigger intra-frequency HO from cell1 to cell2.traffic should ok.cell 2 in band N78 100MHZ.
    ...    c. HO back from cell 2 to cell 1 .cell 1 in band N78 50MHZ.
    ...    d. detach UEs. check counter. check wireshark log.
    [Tags]    AB22     QC_322183
    clear counter files    wait=${False}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    SA_Capa_perUE_Full=${DC_5A-66A-66A-n2A-n77A_and_5A-66A-66A-n2A-n78A}
    ...    ue_mrdc_cap=${Capa_LTE_DC_5A-66A-66A-n2A-n77A_and_5A-66A-66A-n2A-n78A}
    Intra HO trigger from cell 1 to cell 2
    HO back from cell 2 to cell 1
    Release Ues    ue_type=nsa    ue_id=11
    Check Wireshark Log    ${CURDIR}${/}A2A_AB22${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    check counters    pm_counters_expression=${pm_couter_AB22}

CB007219-ET-AB21_Successful EN-DC setup with a PSCell supporting native and alternative bands but configured without candidate NR Scells
    [Documentation]
    ...    1. Purpose:This user scenario describes the successful setup of EN-DC when the target PSCell can be
    ...    configured both in native and in alternative band, interaction with mobility.5G_RAN_USR_RRM_22221
    ...    2. Configuration
    ...    a. NRCELL-1 TDD native:N77 alternative:N78 50Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-2 TDD native:N77 alternative:N78 100Mhz smallBWP:50Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-3 TDD native:N38 alternative:N41 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-4 TDD N38 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-11 FDD N66 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-12 FDD N71 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-13 FDD native:N2 alternative:N25 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-14 FDD N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    b.CB007552 enable:set actMultipleDedicatedBWPs=true; CB008541 enable:actEnhMultipleDedicatedBWPs=true
    ...    5GC001416 enable:actMultiFrequencyBandIndicatorNRSupport=true; CB007219:actMfbiNrCaSupportFr1 set to true.
    ...    c.ue capability:
    ...    BC#1: DC_5A-66A-66A-n2A-n78A    n2    n78
    ...    DL FSEI#1    DL MIMO layers    2L    4L
    ...                 DL ChBw (MHz)     20    100
    ...    UL FSEI#1    UL MIMO layers    2L    4L
    ...                 UL ChBw (MHz)     20    100
    ...    BC#2: DC_5A-66A-66A-n2A-n77A    n2    n77
    ...    DL FSEI#1    DL MIMO layers    2L    4L
    ...                  DL ChBw (MHz)    20    50
    ...    UL FSEI#1    UL MIMO layers    2L    2L
    ...                  UL ChBw (MHz)    20    50
    ...    3. Test Case Steps:
    ...    a. online set 7219 related paramter as true.UE11 attach to LTE1 cell1 NRCELL-1.traffic should ok.
    ...       cell 1 in N77 50MHZ.
    ...    b. trigger intra-frequency HO from cell1 to cell2.traffic should ok.cell 2 in band N77 50MHZ.
    ...    c. HO back from cell 2 to cell 1 .cell 1 in band N77 50MHZ.
    ...    d. detach UEs. check counter. check wireshark log.
    [Tags]     AB21    QC_322197
    clear counter files
    OnlineParamChange    ${7219}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    SA_Capa_perUE_Full=${DC_5A-66A-66A-n2A-n77A_and_5A-66A-66A-n2A-n78A}
    ...    ue_mrdc_cap=${Capa_LTE_DC_5A-66A-66A-n2A-n77A_and_5A-66A-66A-n2A-n78A}
    Intra HO trigger from cell 1 to cell 2
    HO back from cell 2 to cell 1
    Release Ues    ue_type=nsa    ue_id=11
    Check Wireshark Log    ${CURDIR}${/}A2A_AB21${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    check counters    pm_counters_expression=${pm_couter_AB21}
    [Teardown]    AB21_Teardown

CB007103-ET-C004_Switching_Between_DMRS_Rel15_to_Rel16_for_PUSCH_and_PUCCH_F3_When_Halfpi_BPSK_and_Is_Not_Always_Switched_On_for_PUCCH_F3_Nsa
    [Documentation]
    ...    1. Purpose: This user scenario describes switching from DMRS Rel15 to DMRS Rel16 for PUSCH and PUCCH F3 in the case when:
    ...    Pi/2-BPSK is configured in NIDD (NIDD NRCELL.pucchF3ModulationScheme = pi2bpsk) for PUCCH F3
    ...    pi/2-BPSK and Rel16 DMRS is not always switched on for PUCCH F3 by NIDD parameter – NRCELL.pucchF3Rel16Pi2BpskAlwaysOn is FALSE
    ...    2. Configuration
    ...    a. NRCELL-1 TDD native:N77 alternative:N78 50Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-2 TDD native:N78 alternative:N77 100Mhz smallBWP:50Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    b.pucchF3ModulationScheme = pi2bpsk; pucchF3Rel16Pi2BpskAlwaysOn=false;
    ...    5GC001416 enable:actMultiFrequencyBandIndicatorNRSupport=true; CB007219:actMfbiNrCaSupportFr1 set to true.
    ...    c.ue capability:
    ...    power class: UE is of PC3 class only on band n77, and not on support n78
    ...    for PUSCH:
    ...    Using pi/2-BPSK modulation for PUSCH (pusch-HalfPi-BPSK is enabled; this is Rel15 capability)
    ...    Using Rel16 low PAPR DMRS sequence for PUSCH (lowPAPR-DMRS-PUSCHwithPrecoding-r16 is enabled)
    ...    for PUCCH:
    ...    Using pi/2-BPSK modulation for PUCCH F3 (pucch-F3-4-HalfPi-BPSK is enabled; this is Rel15 capability)
    ...    Using Rel16 low PAPR DMRS sequence for PUCCH F3 (lowPAPR-DMRS-PUCCH-r16 is enabled)
    ...    for PUSCH and PUCCH :
    ...    Using pi/2-BPSK Power Boosting for PUSCH and PUCCH F3 (powerBoosting-pi2BPSK is enabled; this is Rel15 capability)
    ...    3. Test Case Steps:
    ...    a. UE11 attach to LTE1 cell1 NRCELL-1.traffic should ok.
    ...       cell 1 in N77 50MHZ.
    ...    b. trigger intra-frequency HO from cell1 to cell2.traffic should ok.cell 2 in band N77 50MHZ.
    ...    c. HO back from cell 2 to cell 1 .cell 1 in band N78 50MHZ.
    ...    d. detach UEs. check counter. check wireshark log.
    [Tags]     C004    QC_46963
    clear counter files
    OnlineParamChange    ${7103_C004_online_PARAMS}
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    SA_Capa_perUE_Full=${DC_5A-66A-66A-n2A-n77A_and_5A-66A-66A-n2A-n78A_7103}
    ...    ue_mrdc_cap=${Capa_LTE_DC_5A-66A-66A-n2A-n77A_and_5A-66A-66A-n2A-n78A}    attach_pass=${attach_pass_7103}
    Intra HO trigger from cell 1 to cell 2    pass_ho=${ho_pass_7103}
    Adjust Sinr Target Pathloss    adjust_succ=${transformPrecoder_enable_1}
    sleep    60s    sleep for counter peg
    Execute Egate Command    ue_testmode_set_nr id=11 testmode=ul_sinr action=deactivate profile_id=1
    HO back from cell 2 to cell 1    pass_ho=${ho_pass_back_7103}
    Adjust Sinr Target Pathloss    adjust_succ=${transformPrecoder_enable_2}
    sleep    60s    sleep for counter peg
    Execute Egate Command    ue_testmode_set_nr id=11 testmode=ul_sinr action=deactivate profile_id=1
    check counters    pm_counters_expression=${pm_couter_C004}

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
    ${C_4}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633000:633000 gscn=7832 mandatory_for_activation=off bwp_arfcn=631320:631320
    Update Cfg    ${C_4}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

AB21_Teardown
    OnlineParamChange    ${Deactivate_CB007219}
    Common Test Teardown And Stop Capture Logs

NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2    ${SA_Capa_perUE_Full}=none
    ...    ${ue_mrdc_cap}=none    ${attach_pass}=${nsa_ue_attach_expect}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_perUE_Full}    Capa_LTE=${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=2:1|1:1
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${attach_pass}    timeout=20s
    Send Throuput
    Wait Until Keyword Succeeds    40s    5s    Verify Throuput

Send Throuput
    [Arguments]    ${ue_id}=11
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL

Verify Throuput
    [Arguments]    ${ue_id}=11    ${dl}=150    ${ul}=8
    sleep    10s    sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>${dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Update UE capa
    [Arguments]    ${ue_id}=91    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

Intra HO trigger from cell 1 to cell 2
    [Arguments]    ${phycell_id}=51    ${ue_id}=11    ${pass_ho}=${Intra_HO_expect}
    Execute Egate Command    enb_endc_param id=${ue_id} allowed_bc_list_mrdc=2:1|1:1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=631968    event_type=A3
    ${A3_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ${ret1}=    Execute Egate Command    ${A3_cmd}    pass_regexp=${pass_ho}
    Wait Until Keyword Succeeds    40s    5s    Verify Throuput

HO back from cell 2 to cell 1
    [Arguments]    ${phycell_id}=50    ${ue_id}=11    ${pass_ho}=${Intra_HO_expect}
    Execute Egate Command    enb_endc_param id=${ue_id} allowed_bc_list_mrdc=2:1|1:1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=631968    event_type=A3
    ${A3_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ${ret1}=    Execute Egate Command    ${A3_cmd}    pass_regexp=${pass_ho}
    Wait Until Keyword Succeeds    40s    5s    Verify Throuput

Adjust Sinr Target Pathloss
    [Arguments]    ${ue_id}=11    ${sinr_target_pathloss}=130    ${pusch_type}=typeB    ${adjust_succ}=rrcConnectionReconfigurationComplete
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1
    ...    pass_regexp=${adjust_succ}    timeout=180