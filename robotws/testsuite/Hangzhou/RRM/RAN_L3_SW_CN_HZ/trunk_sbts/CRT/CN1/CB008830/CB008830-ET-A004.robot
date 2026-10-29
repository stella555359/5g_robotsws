*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-PZ3_7
...     owner-susana.yan    release-SBTS24R2     CNI117836    release-SBTS24R3    CB008830    CRT
Resource     ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{IntragNB_HO_relate}
...    @{CB008830}
...    @{enableBeamforming}
...    @{BWPmodify}
...    NRCELL:nrofHARQProcessesForPDSCH=16
...    NRCELL:maxNumPdschAllocationPerSlot=16
...    NRCELL:actPdschAtSsbSlots=true
...    NRCELL:actAdaptiveReTxResMcs=true
...    NRCELL:actDlLowPAPRoptimizedPrecoding=true
...    NRCELL:actPdschRmCsirsForTracking=true
...    NRCELL:actEnhancedPDSCHSchSplSlot=true
...    NRCELL:minPctResourceReservedMcsDl=50
...    NRCELL:minPctResourceReservedMcsUl=50
...    NRCELL:targetPctResourceReservedMcsDl=75
...    NRCELL:targetPctResourceReservedMcsUl=75
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRCELL:actDlMuMimoEnh=false
...    NRCELL:actVoNR=false
...    NRCELL:actLAForHiReliab=false

@{BWPmodify}
...    NRBTS/BWP_PROFILE-5:bwpType=initial
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-54:bwpType=dedicated
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-54/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8


@{enableBeamforming}
...    NRCELL:actBeamforming=true
...    NRCELL:nrCellType=4DL4UL
...    NRCELL:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams
...    NRCELL:beamSet:basicBeamSet=beamSet_4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    NRBTS/NRSYSINFO_PROFILE-1:systemInformationTargetRate=157

@{CELL1_NRHOIF}
...    NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=0

@{CELL2_NRHOIF}
...    NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRBTS-1/NRCELL-2:measGapSelectionSA=favourUeThroughput

@{IntragNB_HO_relate}
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS-1/NRCELL:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL:absThreshSsbRsrqConsolidation=1
...    NRBTS-1/NRCELL:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRCELL-1/NRREL:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL:gNbId=35
...    NRBTS-1/NRCELL-1/NRREL:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL:lcrId=2
...    NRBTS-1/NRCELL-1/NRREL:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRREL:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL:gNbId=35
...    NRBTS-1/NRCELL-2/NRREL:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL:gnbPlmn:mncLength=3
...    @{CELL1_NRHOIF}
...    @{CELL2_NRHOIF}
...    @{Inter_fre}

@{CELL1_NRHOIF}
...    NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=0

@{CELL2_NRHOIF}
...    NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRBTS-1/NRCELL-2:measGapSelectionSA=favourUeThroughput

@{Inter_fre}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRSACU=5min
...    NRCELL-2:nrarfcn=633372
...    NRCELL-2:gscnOrSsPbchArfcn=7847
...    NRBTS-1/NRCELL:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRBTS-1/NRCELL:a1MeashoEnabled=rsrp
...    NRBTS-1/NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=30
...    NRBTS-1/NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms64
...    NRBTS-1/NRCELL:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS-1/NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=30
...    NRBTS-1/NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRBTS-1/NRCELL:a2MeashoEnabled=rsrp
...    NRBTS-1/NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=20
...    NRBTS-1/NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms64
...    NRBTS-1/NRCELL:a2MeashoEnabledSA=rsrp
...    NRBTS-1/NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRBTS-1/NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRBTS-1/NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64

@{CB008830}
...    NRCELL:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL:dlDMRSAdditionalPosition=No additional DMRS
...    NRBTS-1/NRCELL-1:dlDmrsType=Type1
...    NRBTS-1/NRCELL-2:dlDmrsType=Type2

@{CELL1_Online_Change_dlDmrsType2}
...    NRBTS-1/NRCELL-1:dlDmrsType=Type2

@{CELL1_Online_Change_dlDmrsType1}
...    NRBTS-1/NRCELL-1:dlDmrsType=Type1


#SA UE1:
#UE-NR-Capability->phy-Parameters->phy-ParametersFRX-Diff->supportedDMRS-TypeDL    set to type1And2
#featureSetsDownlinkPerCC->maxNumberMIMO-LayersPDSCH set to fourLayers
#UE-NR-Capability->fr1-Add-UE-NR-Capabilities->phy-ParametersFRX-Diff->supportedDMRS-TypeDL    NOT set

#SA UE2
#UE-NR-Capability->phy-Parameters->phy-ParametersFRX-Diff->supportedDMRS-TypeDL    set to type1
${ue2_nr_cap}    SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008685800C40340260300C0700CA8D851AC10143404B2CA261E003D6C10101070EF1C39061C001032
...    78FAB80027800E0009E00151B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28
...    987800F5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D54000
...    014000000420E268000000010134640000E010113D86C003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA86800
...    7000B000000040080118B130001020304050607080B101112131921252627284A0

#NSA UE31
#UE-NR-Capability->phy-Parameters->phy-ParametersFRX-Diff->supportedDMRS-TypeDL    NOT set
#featureSetsDownlinkPerCC->maxNumberMIMO-LayersPDSCH set to fourLayers
#UE-NR-Capability->fr1-Add-UE-NR-Capabilities->phy-ParametersFRX-Diff->supportedDMRS-TypeDL    set to type1And2
${ue31_nr_cap}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFEC0301F78017FFE00002C7807E290401B
...    FFEF0BFFEBC00E54D00158800000000023003CAA08

${ue31_MRDC_cap}    SEPARATOR=
...    BD1BA063058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C03058100713400
...    001018060B0600E268000020300C9BCD00C20002010080100257001004020080401008020100402008040100802010040200804010080201004020
...    1004020080401008000000402008040000000000040200000000000000004020080401008020100000008040100800000000000804000000000000
...    0000804010080201004020080400000020100402008040000000000000000804000000000000000000001009C00202008040080801010000000404
...    0080800000000000404000000000000000040201004010080201004020080401008020100402008040100802010040200808020100202000000080
...    8010100000004040000000000020200000000000101004020040400808000000202004040000000000020200404000000000002020000000000000
...    0002027001008020100402000000100802010000000804000000000004020000000000020100402008040000002010040200000010080000000000
...    0804000000000004010080201004020080401008020100402008040100802010040200804010080401008020100000008040100800000040200000
...    0100800000040200000000000201000000000001009C00202004040080801010020200000008080101002020000000000010100000004040080801
...    0100202004040000001010020200404000000000002020000000808010100202004040080800000020200404008080000000000040400000010080
...    2010040200804010080201004020080401008020100402008040100802010040200804010080401700100801010000000404008080000000000000
...    0008080000000000000000000020100202000000080801010000000000000000101000000000000000000000402004040000001010020200000000
...    00000000202000000000000000000000804008080000002020040400808000000000004040000001010020200000000000000002020000000809C4
...    0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008
...    0180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008018
...    0100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008010800040202004008400040101002004

@{failIf_DMRStype2}
...    dmrs-Type type2
@{default_fail_regexp}    ${EMPTY}


*** Test Cases ***
CB008830-ET-A004_Verify_DL_DMRS_type_2_support_In_Case_Intra_gNB_HO_SA_NSA_UE
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    Activation/Deactivation for DL DMRS type 2 and Basic/Full DL DMRS type 2 support.
    ...    2. [Configuration]:
    ...       NRCELL/actDlDataDmrsFdm=False
    ...       NRCELL/dlDMRSAdditionalPosition="No Additional DMRS
    ...       NRCELL-1/dlDmrsType=Type1
    ...       NRCELL-2/dlDmrsType=Type2
    ...    3. Test Case Steps:
    ...        a.UE2 which support only DMRS Type1 attach to cell2 and start traffic.
    ...        b.UE1 attach to CELL-1 and start traffic
    ...        c.perform intra gnb HO to CELL-2 and HO back
    ...        d.online change cell1 NIDD dlDmrsType to Type2 and lock unlock cell.
    ...        e.reattach UE1 and repeat step b.
    ...        f.Use UE11 instead of UE1 and repeat stepa~stepe, stepd online change without lock unlock and then release UE.
    ...    4. Expected Results:
    ...        a.UE2 attach successfully and traffic is stable.
    ...        b.UE1 attached successfully, UE2, UE1 traffic is stable.
    ...          Checking RRC: DMRSType is omit indicate DMRSType1 for UE1
    ...          Check PsUser_UserSetupReq/PsUser_UserModifyReq: dmrsType is set to 1 for UE1
    ...        c.HO performed successfully, UE1 and UE2 traffic is stable.
    ...          Checking RRC: DMRSType is set to Type2 when HO to CELL2, omit indicate DMRSType1 when back to CELL1.
    ...          Check PsUser_UserSetupReq: dmrsType is set to 2 when HO to CELL2, set to 1 when back to CELL1.
    ...        d.Online change performed successfully,UE1 released, no impact to UE2 and still Stable DL throughput is achieved.
    ...        e.as same as expected result. DMRSType in rrc and syscom indicate type2 except initial access PsUser_UserSetupReq msg.
    ...          UE1 and UE2 traffic is stable.
    ...        f.as same as expected result. stepd ue31 not release, both UE with stable traffic before UE release.
    [Tags]    A004    QC_362447
    SA UE attach With Traffic    ue_id=2    cell=2    fail_regexp=${failIf_DMRStype2}
    SA UE attach With Traffic and Perform Inter-Freq HO and HO back    ue_id=1    fail_regexp=${failIf_DMRStype2}
    Delta Commission Parameters Lock Unlock Cell and Check TP SA    deltaparam=${CELL1_Online_Change_dlDmrsType2}    ue_id=1    ue_type=sa
    SA UE attach With Traffic and Perform Inter-Freq HO and HO back
    Delta Commission Parameters    ${CELL1_Online_Change_dlDmrsType1}
    NSA UE attach With Traffic and Perform Inter-Freq HO and HO back    fail_regexp=${failIf_DMRStype2}
    Delta Commission Parameters Check TP and Release UEs NSA    deltaparam=${CELL1_Online_Change_dlDmrsType2}    ue_id=31    ue_type=nsa
    NSA UE attach With Traffic and Perform Inter-Freq HO and HO back
    check wireshark log    ${CURDIR}${/}A2A_CB008830-A04${/}a2a.ini    wait_string=UEContextRelease::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${set_cell2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=100 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633372:633372 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_cell2}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue2_nr_cap}
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue31_nr_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue31_MRDC_cap}

NSA UE attach
    [Arguments]    ${ue_id}=11    ${target_cells}=1    ${fail_regexp}=${default_fail_regexp}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA    fail_regexp=${fail_regexp}

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${fail_regexp}=${default_fail_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1
    ...    pass_regexp=Initial Context Setup Successful    fail_regexp=${fail_regexp}

NSA UE Send And Verify Throuput
    [Arguments]    ${ue_id}=11    ${expectedTput_dl}=255    ${expectedTput_ul}=9
    Send Traffic NSA    ue_id=${ue_id}
    Verify Throuput NSA    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}

Send Traffic NSA
    [Arguments]    ${ue_id}=11
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=1    pass_regexp=traffic
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    pass_regexp=traffic
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    pass_regexp=UDP UL

Verify Throuput NSA
    [Arguments]    ${ue_id}=11    ${sleep_time}=10s    ${expectedTput_dl}=255    ${expectedTput_ul}=9
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>${expectedTput_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${expectedTput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${expectedTput_dl}=255    ${expectedTput_ul}=9
    Send Traffic    ue_id=${ue_id}
    Verify Throuput    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}

Send Traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=10 trf_id=1
    ...    pass_regexp=Started Uplink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=3
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic

Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s    ${expectedTput_dl}=255    ${expectedTput_ul}=9
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_dl}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${expectedTput_ul}

Trigger UE Inter-Frequency Intra-gNB HO SA
    [Arguments]    ${ue_id}=1    ${targetpci}=51    ${sourcecell}=1    ${targetcell}=2    ${sourcefreq}=636576    ${targetfreq}=633408
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA3)
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A3
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${targetpci} nrsrp_nr=80
    Execute Egate Command    ${hocommand}
    ...    pass_regexp=(rrcReconfigurationComplete|UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${sourcecell} to EXT_ENB-2.${targetcell} performed)
    Check UE Location    ue_id=${ue_id}    enb=2    cell=${targetcell}

Trigger UE Inter-Frequency Intra-gNB HO NSA
    [Arguments]    ${ue_id}=31    ${targetpci}=51    ${sourcecell}=1    ${targetcell}=2    ${sourcefreq}=636576    ${targetfreq}=633408
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA3)
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A3
    ${ssbindex}=    Evaluate    int(${targetcell})-1
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${targetpci} nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=${ssbindex} nrs_result=30:30:30
    Execute Egate Command    ${hocommand}    pass_regexp=(reported successful RA|eNB 2 cell ${targetcell})

Trigger UE Inter-Freq Intra-gNB HO and HO back With Traffic Check NSA
    [Arguments]    ${ue_id}=31
    Trigger UE Inter-Frequency Intra-gNB HO NSA
    ...    ue_id=${ue_id}    targetpci=51    sourcecell=1    targetcell=2    sourcefreq=636576    targetfreq=633408
    Verify Throuput NSA    ue_id=${ue_id}
    Verify Throuput    ue_id=2
    Trigger UE Inter-Frequency Intra-gNB HO NSA
    ...    ue_id=${ue_id}    targetpci=50    sourcecell=2    targetcell=1    sourcefreq=633408    targetfreq=636576
    Verify Throuput NSA    ue_id=${ue_id}
    Verify Throuput    ue_id=2

Trigger UE Inter-Freq Intra-gNB HO and HO back With Traffic Check SA
    [Arguments]    ${ue_id}=1
    Trigger UE Inter-Frequency Intra-gNB HO SA
    ...    ue_id=${ue_id}    targetpci=51    sourcecell=1    targetcell=2    sourcefreq=636576    targetfreq=633408
    Verify Throuput    ue_id=${ue_id}
    Verify Throuput    ue_id=2
    Trigger UE Inter-Frequency Intra-gNB HO SA
    ...    ue_id=${ue_id}    targetpci=50    sourcecell=2    targetcell=1    sourcefreq=633408    targetfreq=636576
    Verify Throuput    ue_id=${ue_id}
    Verify Throuput    ue_id=2

Check UE Location
    [Arguments]    ${ue_id}=1    ${enb}=2    ${cell}=1
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${real_enb_id}    ${real_cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${real_enb_id}    ${enb}
    Should Be Equal    ${real_cell_id}    ${cell}

SA UE attach With Traffic
    [Arguments]    ${ue_id}=2    ${cell}=1    ${expectedTput_dl}=255    ${expectedTput_ul}=9    ${fail_regexp}=${default_fail_regexp}
    SA UE attach    ue_id=${ue_id}    cell_id=${cell}    fail_regexp=${fail_regexp}
    Send And Verify Throuput    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}

SA UE attach With Traffic and Perform Inter-Freq HO and HO back
    [Arguments]    ${ue_id}=1    ${cell}=1    ${fail_regexp}=${default_fail_regexp}
    SA UE attach    ue_id=${ue_id}    cell_id=${cell}    fail_regexp=${fail_regexp}
    Send And Verify Throuput    ue_id=${ue_id}
    Verify Throuput    ue_id=2
    Trigger UE Inter-Freq Intra-gNB HO and HO back With Traffic Check SA

NSA UE attach With Traffic and Perform Inter-Freq HO and HO back
    [Arguments]    ${ue_id}=31    ${target_cells}=1    ${fail_regexp}=${default_fail_regexp}
    NSA UE attach    ue_id=${ue_id}    target_cells=${target_cells}    fail_regexp=${fail_regexp}
    NSA UE Send And Verify Throuput    ue_id=${ue_id}
    Verify Throuput    ue_id=2
    Trigger UE Inter-Freq Intra-gNB HO and HO back With Traffic Check NSA

Delta Commission Parameters Lock Unlock Cell and Check TP SA
    [Arguments]    ${ue_id}=1    ${dmrstype1ue_id}=2    ${ue_type}=sa    ${expectedTput_dl}=255    ${expectedTput_ul}=9    ${cellidex}=1
    ...    ${deltaparam}=${CELL1_Online_Change_dlDmrsType2}
    Lock Cell${cellidex}
    Delta Commission Parameters    ${deltaparam}
    Unlock Cell${cellidex}
    Cells Should Be Onair    ${cellidex}
    Verify Throuput    ue_id=${dmrstype1ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}

Delta Commission Parameters Check TP and Release UEs NSA
    [Arguments]    ${ue_id}=1    ${ue_type}=sa    ${expectedTput_dl}=255    ${expectedTput_ul}=9
    ...    ${deltaparam}=${CELL1_Online_Change_dlDmrsType2}
    Delta Commission Parameters    ${deltaparam}
    Verify Throuput NSA    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}
    Release ues    ue_id=${ue_id}    ue_type=${ue_type}

