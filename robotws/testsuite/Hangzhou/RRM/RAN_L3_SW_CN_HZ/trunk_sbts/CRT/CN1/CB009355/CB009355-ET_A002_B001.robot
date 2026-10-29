*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-PZ3_6
...    owner-dandan.chen    release-SBTS24R3    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SA_UE1_ID}    3
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actLteNrDss=false
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-2:maxNumScellsDlFr1=4
...    NRCELL-3:maxNumScellsDlFr1=4
...    NRCELL-4:maxNumScellsDlFr1=4
...    NRCELL-11:maxNumScellsDlFr1=4
...    NRCELL-12:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    @{Mobility_related}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL-3:ssPbchBlockPower=20
...    NRCELL-1:ssPbchBlockPower=20    
...    @{9355}
...    NRCELL-1:nrCellType=4DL4UL
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    NRCELL-2:nrCellType=4DL4UL
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    NRCELL-1:fPdcchMonOccsnPo=2
...    NRCELL-2:fPdcchMonOccsnPo=2
...    NRCELL-3:fPdcchMonOccsnPo=2
...    NRCELL-4:fPdcchMonOccsnPo=2

@{9355}
...    NRBTS:actBbPoolTddFr1=false
#CB009007
...    NRCELL-3:actEnhancedPDSCHSchSplSlot=true
...    NRCELL-4:actEnhancedPDSCHSchSplSlot=true
...    NRCELL-3:actAdaptiveReTxResMcs=true
...    NRCELL-4:actAdaptiveReTxResMcs=true
...    NRCELL-3:minPctResourceReservedMcsDl=50
...    NRCELL-4:minPctResourceReservedMcsDl=50
...    NRCELL-3:minPctResourceReservedMcsUl=50
...    NRCELL-4:minPctResourceReservedMcsUl=50
...    NRCELL-3:targetPctResourceReservedMcsDl=75
...    NRCELL-4:targetPctResourceReservedMcsDl=75
...    NRCELL-3:targetPctResourceReservedMcsUl=75
...    NRCELL-4:targetPctResourceReservedMcsUl=75

...    NRCELL-3:actDynUlResAlloc=true
...    NRCELL-3:actCceSplit=true
...    NRCELL-3:actDynPdcchTdMode=largestBWP
...    NRCELL-3:dmrsTypeAPosition=pos3
...    NRCELL-3:actLongPucchResourceOpt=false

...    NRCELL-4:actDynUlResAlloc=true
...    NRCELL-4:actCceSplit=true
...    NRCELL-4:actDynPdcchTdMode=largestBWP
...    NRCELL-4:dmrsTypeAPosition=pos3
...    NRCELL-4:actLongPucchResourceOpt=false

...    NRCELL-1:chBw=20MHz
...    NRCELL-1:type0CoresetConfigurationIndex=4
...    NRCELL-1:msg1FrequencyStart=20

...    NRCELL-3:chBw=15MHz
...    NRCELL-3:prachConfigurationIndex=96
...    NRCELL-3:type0CoresetConfigurationIndex=4
...    NRCELL-3:type0SearchSpaceConfigurationIndex=4
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-3:msg1FrequencyStart=5
...    NRCELL-3:nrCellType=4DL4UL

...    NRCELL-4:chBw=15MHz
...    NRCELL-4:prachConfigurationIndex=96
...    NRCELL-4:type0CoresetConfigurationIndex=4
...    NRCELL-4:type0SearchSpaceConfigurationIndex=4
...    NRCELL-4:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-4:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-4:msg1FrequencyStart=5
...    NRCELL-4:nrCellType=4DL4UL
...    NRCELL-4:expectedCellSize=5km
...    NRCELL-4:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-3
...    NRCELL-4:nrOfScgFailures=0

...    NRDU-1:actNonBfAndBfCa=true
...    NRCELL-3:actDl256Qam=true
...    NRCELL-3:beamSet:basicBeamSet=beamSet_2
...    NRCELL-3:numberOfRxBeamforming=4Rx
...    NRCELL-3:actBeamforming=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS-1/NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams
...    NRBTS/NRCELL-3:measGapSelectionSA=favourUeThroughput
...    NRBTS/NRCELL-4:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL-4:gscnOrSsPbchArfcn=6351
...    NRCELL-4:nrarfcn=508020

...    NRCELL-1:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-21
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-22
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-4:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-4:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24

...    NRBTS/BWP_PROFILE-21:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-21:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-21/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=3
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=3
...    NRBTS/BWP_PROFILE-22:bwpType=dedicated
...    NRBTS/BWP_PROFILE-22:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-22:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-22:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-22/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-22/PDSCH-1:pdschRat0RbgConfig=config2
...    NRBTS/BWP_PROFILE-23:bwpType=initial
...    NRBTS/BWP_PROFILE-23:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-23:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-23:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-23:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-23/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-23/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-23/PDCCH-1:downgradeALProactive=false
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=3
...    NRBTS/BWP_PROFILE-24:bwpType=dedicated
...    NRBTS/BWP_PROFILE-24:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-24:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-24:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-24:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-24/PDCCH-1:alSelection=dynamic
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-24/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-24/PDCCH-1:downgradeALProactive=false
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:aggregationLevelList=AL1_AL2_AL4_AL8
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:cqiCorrectionUp=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl1=101
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl2=69
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl4=33
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl8=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl16=0
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:highOlcCqiOffset=100
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:lowOlcCqiOffset=1100
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=160
...    NRBTS/BWP_PROFILE-24/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureReduction=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=36
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=39|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl40|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=39|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl40|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-24/PDSCH-1:pdschRat0RbgConfig=config1

...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL2UL
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL2UL
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

@{Mobility_related}
...    NRBTS:actHoOptimizationCa=false
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:measGapSelectionSA=favorFastMeasurements
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:sCellDeactivationTimerGNB=infinity

...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:sMeasConfigSsbRsrp=1

...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:nrDcAllowed=false
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:nrDcAllowed=false
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-11:timingAdvanceOffset=n25600
...    NRCELL-12:timingAdvanceOffset=n25600
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:nrDcAllowed=false
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-11:gNbId=1
...    NRCELL-3/NRREL-11:gNbIdLength=22
...    NRCELL-3/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-11:lcrId=11
...    NRCELL-3/NRREL-11:nrDcAllowed=false
...    NRCELL-3/NRREL-11:removeNotAllowed=false
...    NRCELL-3/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-11:gnbPlmn:mncLength=3

...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:nrDcAllowed=false
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-4/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-3:gNbId=1
...    NRCELL-4/NRREL-3:gNbIdLength=22
...    NRCELL-4/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-4/NRREL-3:lcrId=3
...    NRCELL-4/NRREL-3:nrDcAllowed=false
...    NRCELL-4/NRREL-3:removeNotAllowed=false
...    NRCELL-4/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-4/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-11:gNbId=1
...    NRCELL-4/NRREL-11:gNbIdLength=22
...    NRCELL-4/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-4/NRREL-11:lcrId=11
...    NRCELL-4/NRREL-11:nrDcAllowed=false
...    NRCELL-4/NRREL-11:removeNotAllowed=false
...    NRCELL-4/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-11:gnbPlmn:mncLength=3

...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:cellDepType=SA
...    NRCELL-3/NRHOIF-1:deriveSsbIndexFromCell=true
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-3/NRHOIF-1:ssbFrequency=632736
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-3/NRHOIF-1:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-3/NRHOIF-1:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-3/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0

...    NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-3:cellDepType=SA
...    NRCELL-1/NRHOIF-3:deriveSsbIndexFromCell=true
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-3:ssbFrequency=508110
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-3:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-1/NRHOIF-3:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0

@{delta_framwork_change_for_NRCELL}
...    @{NRCELL11_scell_conifg}
...    @{NRCELL3_scell_config}
...    @{NRCELL4_frame_config}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterMeNBMobility=true



@{NRCELL3_scell_config}  
...    NRCELL-3:actAdaptiveReTxResMcs=true
...    NRCELL-3:actBeamforming=true
...    NRCELL-3:actDynPdcchTdMode=largestBWP
...    NRCELL-3:actDynUlResAlloc=true
...    NRCELL-3:actEnhancedPDSCHSchSplSlot=true
...    NRCELL-3:chBw=15MHz
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:maxNumScellsDlFr1=4
...    NRCELL-3:measGapSelectionSA=favourUeThroughput
...    NRCELL-3:minPctResourceReservedMcsDl=50
...    NRCELL-3:minPctResourceReservedMcsUl=50
...    NRCELL-3:nrCellType=4DL4UL
...    NRCELL-3:numberOfRxBeamforming=4Rx
...    NRCELL-3:prachConfigurationIndex=98
...    NRCELL-3:sMeasConfigSsbRsrp=1
...    NRCELL-3:targetPctResourceReservedMcsDl=75
...    NRCELL-3:targetPctResourceReservedMcsUl=75
...    NRCELL-3:type0CoresetConfigurationIndex=4
...    NRCELL-3:type0SearchSpaceConfigurationIndex=4   
...    NRCELL-3:beamSet:basicBeamSet=beamSet_4
...    NRCELL-3:beamSet:leftEdgeAngle=60
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-3:beamSet:rightEdgeAngle=60
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-3:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-3:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-3:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-3:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-3:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-3:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-3:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-11:gNbId=1
...    NRCELL-3/NRREL-11:gNbIdLength=22
...    NRCELL-3/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-11:isRplCellForPSCell=false
...    NRCELL-3/NRREL-11:lcrId=11
...    NRCELL-3/NRREL-11:nrDcAllowed=false
...    NRCELL-3/NRREL-11:removeNotAllowed=false
...    NRCELL-3/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-11:sCellOperationalMode=dlAndUl
...    NRCELL-3/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-11:gnbPlmn:mncLength=3
...    delete:NRCELL-3/NRREL-1

@{NRCELL4_frame_config}    
...    NRCELL-4:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL-4:a1MeashoEnabledSA=rsrp
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeashoEnabledSA=rsrp
...    NRCELL-4:a3MeasEnabled=rsrp
...    NRCELL-4:actAdaptiveReTxResMcs=true
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:actDynPdcchTdMode=largestBWP
...    NRCELL-4:actDynUlResAlloc=true
...    NRCELL-4:actEnhancedPDSCHSchSplSlot=true
...    NRCELL-4:chBw=15MHz
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:expectedCellSize=5km
...    NRCELL-4:gscnOrSsPbchArfcn=6351
...    NRCELL-4:maxNumScellsDlFr1=4
...    NRCELL-4:measGapSelectionSA=favourUeThroughput
...    NRCELL-4:minPctResourceReservedMcsDl=50
...    NRCELL-4:minPctResourceReservedMcsUl=50
...    NRCELL-4:nrCellType=4DL4UL
...    NRCELL-4:nrOfScgFailures=0
...    NRCELL-4:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-3
...    NRCELL-4:nrarfcn=508020
...    NRCELL-4:numberOfRxBeamforming=4Rx
...    NRCELL-4:prachConfigurationIndex=98
...    NRCELL-4:sMeasConfigSsbRsrp=1
...    NRCELL-4:targetPctResourceReservedMcsDl=75
...    NRCELL-4:targetPctResourceReservedMcsUl=75
...    NRCELL-4:type0CoresetConfigurationIndex=4
...    NRCELL-4:type0SearchSpaceConfigurationIndex=4
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:beamSet:leftEdgeAngle=60
...    NRCELL-4:beamSet:lowerEdgeAngle=120
...    NRCELL-4:beamSet:rightEdgeAngle=60
...    NRCELL-4:beamSet:upperEdgeAngle=60
...    NRCELL-4:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-4:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-4:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-4:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-4:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRCELL-4:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-4:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-4:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-4:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-4:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-24
...    NRCELL-4:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-4:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-4/NRREL-1:isRplCellForPSCell=false
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:nrDcAllowed=false
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRBTS/NRDU-1:actNonBfAndBfCa=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRPMRNL-1:tmpMiNrParam1=5min
...    delete:NRCELL-4/NRREL-11

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fdd_Fdd_Sa_WithUl,
...    ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,
...    ca_Fr1Tdd_Fdd_Nsa


@{NRCELL11_scell_conifg}
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-3:isRplCellForPSCell=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3

@{CELL4_Scell_expect}
...    pcid:53, scellIdx:0
...    pcid:50, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{CELL3_Scell_expect}
...    pcid:52, scellIdx:0
...    pcid:50, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{CELL1_Scell_expect}
...    pcid:50, scellIdx:0
...    pcid:60, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{CELL3_add_Scell11_expect}
...    pcid:52, scellIdx:0
...    pcid:60, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{CELL3_add_Scell11_expect_NSA}
...    pcid:52, scellIdx:8
...    pcid:60, scellIdx:9
...    SCellIndex 9 activated successfully at airphone


@{CELL4_add_Scell1_expect}
...    pcid:53, scellIdx:0
...    pcid:50, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{CELL11_add_Scell3_expect}
...    pcid:60, scellIdx:0
...    pcid:52, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{PM_Counters}
...    NRCELL-4:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-4:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-3:${GNB_DU_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-3:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=2
...    NRCELL-1:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1

@{PM_Counters_B001}
...    NRCELL-3:${SGNB_DU_NSA_ADMISSION_REQ}=4
...    NRCELL-3:${SGNB_DU_NSA_ADMISSION_SUCC}=4
...    NRCELL-11:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-11:${GNB_DU_SCELL_ADMI_SUCC_SA}=8  
...    NRCELL-3:${GNB_DU_SCELL_1_ADMI_REQ_SA}=8
...    NRCELL-3:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=8
...    NRCELL-1:${GNB_DU_SCELL_ADMI_SUCC_SA}=8  
...    NRCELL-4:${GNB_DU_SCELL_1_ADMI_REQ_SA}=8
...    NRCELL-4:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=8
...    NRCELL-3:${GNB_DU_SCELL_ADMI_SUCC_SA}=1  
...    NRCELL-11:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-11:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-3:${AVG_SIM_USED_OUT_REL_CU}>0
...    NRCELL-3:${AVG_SIM_USED_OUT_REL_DU}>0
...    NRCELL-4:${AVG_SIM_USED_OUT_REL_CU}>0
...    NRCELL-4:${AVG_SIM_USED_OUT_REL_DU}>0
...    NRCELL-11:${AVG_SIM_USED_OUT_REL_CU}>0
...    NRCELL-11:${AVG_SIM_USED_OUT_REL_DU}>0


@{PM_counters_8950related}
...    NRCELL-3:${AVG_SIM_USED_OUT_REL_CU}=0
...    NRCELL-3:${AVG_SIM_USED_OUT_REL_DU}=0
...    NRCELL-4:${AVG_SIM_USED_OUT_REL_CU}=0
...    NRCELL-4:${AVG_SIM_USED_OUT_REL_DU}=0
...    NRCELL-11:${AVG_SIM_USED_OUT_REL_CU}=0
...    NRCELL-11:${AVG_SIM_USED_OUT_REL_DU}=0

${AVG_SIM_USED_OUT_REL_CU}    M55118C00051
#This counter is sampled each second (1s) when the sample timer expires, and updated by the average number of simultaneously
#used outgoing CAREL MOC objects per cell.
${AVG_SIM_USED_OUT_REL_DU}    M55167C00008
#FR1 SA/NSA Avg simultaneous used outgoing CA relations in DU per cell

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003    #Radio admission requests for 1 SCell in DU in SA mode
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004    
#Successful radio admissions for 1 SCell addition in DU in SA mode
#This counter is updated on the PCell when exactly 1 admitted SCell is newly added as part of F1AP
${GNB_DU_SCELL_ADMI_SUCC_SA}     M55139C01002
#Successful radio admissions for the SCell in DU in SA mode
#This counter is updated on the SCell when the admitted SCell is newly added as part of F1AP
${SGNB_DU_NSA_ADMISSION_REQ}     M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}     M55115C00003
${SGNB_DU_SCELL_ADMISSION_SUCC}      M55115C00007    
# The number of successful radio admissions for the Scell
   


${ue_nr_cap_SA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC118434
...    1020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0
...    541B107582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000
...    00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F02E007FE0038
...    01FF8002E0000702A0D88DAC1184341020F941A0092D931541439F11C78C0000000000000000004FFF800003FFE0
...    00002E00007000DE1E2680070A000000058081787882001C28000002160205E1E20800713400000858081007011A
...    014404D80822E8004E03851226C73E1C28913639F0E14489B1CF86000E06318FD058007838280381804A00E000C0
...    480080C07C010040000000200000401606D654D0041000009652504000065949401503AAA55542C009001A050000
...    8404010020100400820200400808020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E50
...    52545A5E828305A0

${NSA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670FC24026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E90
...    68036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007001DF0005C0000E0541B1075823086
...    82041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608
...    C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D88DAC
...    1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C00F787
...    89A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C4600
...    0002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800
...    388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562
...    E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C046805101360208BA005D
...    83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C0890
...    2040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6
...    318C6318C630F417001E00140E0A00E0601280380030120020301F048010000000080000100400000002000004010000040
...    08000030040000200200001401000802008020000180100000E008004000000100001000800009004000018020000280100
...    00160080040902401000018067226B226B052B032B066B056B296B266B016B036B012B022B07681A0800004B29282000032
...    CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA48080
...    0054B29202000172CA4A0800064B29202000062CA480669155D22AAA55174AA2A82C55058AA0D154A62A93455018AA05154
...    9AAA83C50B00BC04A8140A05028140A05028140A05028140A05028140A000C10100C0180400801080801004020180308040
...    08010100C018040300608080600C02018030804008010100C018040080110080600C02018030080600C1010020080400802
...    1AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D 

${Capa_LTE}    SEPARATOR=
...    a11ff83bc4c0c03850001c46000000162205e260601c4d000e230000000b1102f130300e26800710400000058881789818070a0003
...    8820000002c040bc4c0c03882001c46000002160205e360601c46000e208007104000010580817898180713400385000000c2c0408
...    04808d00a001c041809a1e80b907893a244d8e7c3893a244d8e7c3893a244d8e7c3893a244d8e7c3893a24498e7d1a7448912639f4
...    49d1224c73e01a0718c6318c60c02080002010100200804030061000040202004008080600c3000080404030060100c01804030061
...    000040202004010080100400000000



${cellsetup_15M_nrcell-4}    SEPARATOR=
...    itf_l2_ps_cell_CellSetupReq_t.physCellId == 53 &&
...    itf_l2_ps_pucch_PucchConfigCommon.pucchResourceCommon == 11 &&
...    itf_l2_ps_pucch_PucchConfigCommon.deltaPriList.Length == 6 &&
...    itf_l2_ps_cell_BwpDefinitionUl.bandwidth == 38 &&
...    itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item == 28

${cellsetup_15M_nrcell-3}    SEPARATOR=
...    itf_l2_ps_cell_CellSetupReq_t.physCellId == 52 &&
...    itf_l2_ps_pucch_PucchConfigCommon.pucchResourceCommon == 11 &&
...    itf_l2_ps_pucch_PucchConfigCommon.deltaPriList.Length == 6 &&
...    itf_l2_ps_cell_BwpDefinitionUl.bandwidth == 38 &&
...    itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item == 28

*** Test Cases ***
CB009355-ET-A002_SA_ALT_CB009007_enable_Intragnb_HO_between_diff_CHBW_IWK_scell_select
    [Documentation]
    ...    1. The purpose of this test case is to validate Intra-gNB between handover cells configured between different BW
    ...       Successful UE attachment and traffic SA Mode on FR1 15MHz TDD cell
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                   gNB
    ...                   Cell-1    Cell-3    Cell-4    Cell-11
    ...    Technology        TDD      TDD     TDD        FDD
    ...          Band        n78      n41     n41        n66
    ...     Bandwidth        20       15      15         20
    ...            BF        No       Yes     No         No
    ...    3. Test Case Steps:
    ...         lock and unlock cell4 and cell3 to get cell info
    ...         a. ue1 attach to the SA cell-4, start traffic, trigger a1.
    ...         b. do intrafreq ho from cell-4 to cell-3. trigger a1.
    ...         c. do interfreq ho from cell-3 to cell-1. trigger a1.
    ...         d. do interfreq ho from cell-1 to cell-3. trigger a1
    ...    4. Expected Results:
    ...         a. scell add, CA(CELL-4+CELL-1). traffic is ok.
    ...         b. scell add, CA(CELL-3+CELL-1). traffic is ok.
    ...         c. scell add, CA(CELL-1+CELL-11). traffic is ok.
    ...         d. scell add, CA(CELL-3+CELL-1). traffic is ok.
    [Tags]    QC_362027    A002
    Lock and unlock cell    4
    Lock and unlock cell    3
    Clear Counter files    True
    UE Scell Add With CoverBased
    IntraFreq_intragnb_HandOver
    InterFreq_intragnb_HandOver    carrier_source=508110    carrier_target=632736    phycell_id=50    pass=${CELL1_Scell_expect}
    InterFreq_intragnb_HandOver    carrier_source=632736    carrier_target=508110    phycell_id=52    pass=${CELL3_Scell_expect}
    Check WireShark Log    ${CURDIR}${/}A2A_A002${/}a2a.ini    wait_string=UEContextModificationResponse::48
    check L2PS syscom message
    Check Counters    ${PM_Counters}
    
CB009355-ET-B001_SANSA_MultiUE_IWK_diff_frames_IWK_FT_CA
    [Documentation]
    ...    1. The purpose of this user scenario describes SANSA MultiUE IWK diff frames IWK FT CA.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                   gNB
    ...                   Cell-1    Cell-3    Cell-4    Cell-11
    ...    Technology        TDD      TDD     TDD        FDD
    ...          Band        n78      n41     n41        n66
    ...     Bandwidth        20       15      15         20
    ...            BF        No       Yes     Yes         No
    ...    3. Test Case Steps:
    ...         a. UE1 to UE8 Attach to cell-3 with blind scell addtion
    ...         b. UE 31 NSA call attach to cell-3 with blind scell addtion 
    ...         c. check all traffic on cell-3 should be fine 
    ...         d. UE9 to UE16 Attach to cell-4 with blind scell addtion
    ...         e. Check Traffic For UEs on cell-4
    ...         f. UE17 attach to cell-11 with blind scell addtion and verify traffic
    ...    4. Expected Results:
    ...         a. UE1-8 SA call attach cell-3 successfully and scell-11 add successfully 
    ...         b. UE 31 NSA call attach cell-3 successfully ,scell-11 addtion successfully . 
    ...         c. traffic is ok.
    ...         d. UE9 to UE16 Attach to cell-4 with blind scell-1 addtion successfully
    ...         e. traffic is ok.
    ...         f.UE17 attach to cell-11 with blind scell-3 addtion successfully and traffic is ok.
    [Tags]    QC_46943    B001
    Clear Counter files    True
    OnlineParamChange    ${delta_framwork_change_for_NRCELL}
    UE1 to UE8 Attach to cell-3 with blind scell addtion
    UE 31 NSA call attach to cell-3 with blind scell addtion 
    Check All traffic on cell-3
    UE9 to UE16 Attach to cell-4 with blind scell addtion
    Check Traffic For UEs on cell-4
    UE17 attach to cell-11 with blind scell addtion and verify traffic
    Release Ues    ue_type=all
    #add test steps after EDA of 04040544
    UE 31 NSA call attach to cell-3 with coverbased
    Triigger InterMeNB InterCell HO without SCGChange   ue_id=31    enb_id=11    cell_id=1
    Triigger InterMeNB InterCell HO without SCGChange   ue_id=31    enb_id=1    cell_id=1
    Check Counters    ${PM_Counters_B001}
    Clear Counter files    True
    Check Counters    ${PM_counters_8950related}
    [Teardown]    Test teardown for B001

*** Keywords ***
Test teardown for B001
    OnlineParamChange    NRCELL-3/NRREL-11:sCellAdditionMethod=blind
    Common Test Teardown And Stop Capture Logs


Setup X2 lINK and Allowed ENDC on with eNB11
    [Arguments]    ${enb_id}=1    ${cell_id}=1
    Execute Egate Command    enb_x2_link_up enb=${enb_id} target=2    pass_regexp=ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${cell_id} allow_endc=on

Triigger InterMeNB InterCell HO without SCGChange
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1
    Execute Egate Command    enb_endc_param id=${enb_id} allowed_bc_list_mrdc=1:1
    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${enb_id} cell=${cell_id}    Inter-eNB handover from


Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71

Modify Cfg
    Update Cfg    debug_log level=4
    ${V2}    catenate
    ...    ue_param id=31 ue_nr_capabilities=${NSA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ${V2}
    Update Cfg    ue_param id=1-17 ue_nr_capabilities=${ue_nr_cap_SA}
    ${set_ue1}    catenate    set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 
    ...     nr_arfcn=508020:508020 gscn=6351 mandatory_for_activation=off
    ${V4}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
    ...    type=simulated x2_peers=none
    ${V5}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    mandatory_for_activation=off
    Update Cfg    ${V4}
    Update Cfg    ${V5}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    
OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir


Lock and unlock cell
    [Arguments]    ${Nrcell_indext}
    Lock Cell${Nrcell_indext}
    Unlock Cell${Nrcell_indext}
    Cells Should Be Onair    ${Nrcell_indext}

Sa CA UE Register
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=${wait_timer}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}

SA CA UE Setup PDU Session
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2    ${expect_regexp}=QoS Routing Table
    [Return]    ${RAN_UE_NGAP_ID[0]}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}
    ...    sleep_time=${wait_timer}
    ${RAN_UE_NGAP_ID}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${cell_id}=4
    [Return]    ${RAN_UE_NGAP_ID}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=${cell_id}
    ${RAN_UE_NGAP_ID}    SA CA UE Setup PDU Session    ue_id=${ue_id}

UE Scell Add With CoverBased
    UE Register And PDU Session Setup    ue_id=${SA_UE1_ID}    cell_id=4
    Send Throughput
    UE Send A1 Trigger Scell Addition    ue_id=${SA_UE1_ID}    cellfreq=508110    pass_reg_ca=${CELL4_Scell_expect}
    Verify Throughput

InterFreq_intragnb_HandOver
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${carrier_source}=508110    ${carrier_target}=632736    ${phycell_id}=50
    ...    ${A2_pass_regrxp}=rrcReconfigurationComplete    ${A3_pass_regrxp}=rrcReconfigurationComplete
    ...    ${pass}=${CELL1_Scell_expect}
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrier_source}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=${A2_pass_regrxp}
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrier_target}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=100 phycell_id=${phycell_id} nrsrp_nr=100
    ...    pass_regexp=${A3_pass_regrxp}
    UE Send A1 Trigger Scell Addition    ue_id=${SA_UE1_ID}    cellfreq=${carrier_target}    pass_reg_ca=${pass}
    Verify Throughput

IntraFreq_intragnb_HandOver
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${carrier_target}=508110    ${phycell_id}=52
    ...    ${A3_pass_regrxp}=rrcReconfigurationComplete    ${pass}=${CELL3_Scell_expect}
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrier_target}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=100 phycell_id=${phycell_id} nrsrp_nr=100
    ...    pass_regexp=${A3_pass_regrxp}
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=${carrier_target}    pass_reg_ca=${pass}
    Verify Throughput

Verify Throughput
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${pdu}=1    ${qfi}=1    ${Tput_dl}=270    ${Tput_ul}=14
    sleep    10s    sleep for traffic stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tputdl}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${scell_tputul}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Not Match Regexp    ${scell_tputdl}    CellIndex-[0-5] *0 *0 *0 *0 *0
    Should Not Match Regexp    ${scell_tputul}    CellIndex-[0-3] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send Throughput
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=16 trf_id=3    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL

check L2PS syscom message
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${cellsetup_15M_nrcell-4}
    should be equal As Numbers    ${number}    1
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${cellsetup_15M_nrcell-3}
    should be equal As Numbers    ${number}    1
    
UE1 to UE8 Attach to cell-3 with blind scell addtion
    [Arguments]    ${add_scell_expect}=${CELL3_add_Scell11_expect}
    UEs attach to target cell with blind scell addtion    ue_id=1    cell_id=3    pdu=1    add_scell_expect=${CELL3_add_Scell11_expect}
    
    

UE9 to UE16 Attach to cell-4 with blind scell addtion
    [Arguments]    ${add_scell_expect}=${CELL4_add_Scell1_expect}
    UEs attach to target cell with blind scell addtion    ue_id=9    cell_id=4    pdu=2    dl=20    ul=2    
    ...    add_scell_expect=${CELL4_add_Scell1_expect}

    
UE17 attach to cell-11 with blind scell addtion and verify traffic  
    [Arguments]    ${ue_id}=17    ${cell_id}=11    ${pdu}=3    ${add_scell_expect}=${CELL11_add_Scell3_expect}  
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=3
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=${ue_id} nwslice=1    pass_regexp=${CELL11_add_Scell3_expect}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=20 trf_id=${ue_id}    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul mbps=2 trf_id=${ue_id}    pass_regexp=Started Uplink
    Verify Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=1    Tput_dl=18    Tput_ul=1.8



UEs attach to target cell with blind scell addtion
    [Arguments]    ${ue_id}=1    ${cell_id}=3    ${pdu}=1    ${dl}=18    ${ul}=2    ${add_scell_expect}=${CELL3_add_Scell11_expect}     
    FOR    ${ue_id}    IN RANGE    ${ue_id}    ${ue_id}+8
         Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
         Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=3
         Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
         Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=${ue_id} nwslice=1    pass_regexp=${add_scell_expect}
         Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=${dl} trf_id=${ue_id}    pass_regexp=Started Downlink
         Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul mbps=${ul} trf_id=${ue_id}    pass_regexp=Started Uplink
    END



Check Traffic for Each UE
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1    ${total_dl_tput}=0    ${total_ul_tput}=0
    FOR    ${ue_id}    IN RANGE    ${ue_id}    ${ue_id}+8
         sleep    10s    #sleep for wait traffic stable
         ${cell_tput_dl_pcell}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    direction=dl    rate_type=ave
         ${cell_tput_ul_pcell}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    direction=ul    rate_type=ave
         ${total_dl_tput}    Evaluate    ${total_dl_tput}+${cell_tput_dl_pcell}
         ${total_ul_tput}    Evaluate    ${cell_tput_ul_pcell}+${total_ul_tput}
         ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=1-9 type=pdsch    Throughput
 
    END
    [Return]     ${total_dl_tput}      ${total_ul_tput}
    
    
Check Traffic For UEs on cell-4
    [Arguments]     ${ue_id}=9    ${pdu_id}=2    ${min_dl_tput}=145    ${min_ul_tput}=15
    ${total_dl_tput}       ${total_ul_tput}    Check Traffic for Each UE     ue_id=${ue_id}    pdu_id=${pdu_id}  
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${total_ul_tput}/1000 > ${min_ul_tput}



UE 31 NSA call attach to cell-3 with blind scell addtion 
   NSA UE Attach To Target Cell

UE 31 NSA call attach to cell-3 with coverbased
    [Arguments]    ${ue_id}=31
    OnlineParamChange    NRCELL-3/NRREL-11:sCellAdditionMethod=covBasedA1
    Setup X2 lINK and Allowed ENDC on with eNB11    enb_id=11
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=1:1|4:1|4:4|4:3|5:2|6:1|6:2|4:2|5:1|2:1|3:1|7:1|7:2
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=3 bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=508110    pass_reg_ca=${CELL3_add_Scell11_expect_NSA}
    Send Nsa Throuput
    Execute Egate Command    bearer_disp ue=${ue_id} at=enb


Set x2 gnb link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

NSA UE Attach To Target Cell
    [Arguments]    ${ue_id}=31  
    Set x2 gnb link up
    Update Cfg    debug_log level=4
    Execute Egate Command     debug_log level=4
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=1:1|4:1|4:4|4:3|5:2|6:1|6:2|4:2|5:1|2:1|3:1|7:1|7:2
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=3 bearer=2 type=split_scg
    ...    pass_regexp=${CELL3_add_Scell11_expect_NSA}
    Send Nsa Throuput
    Execute Egate Command    bearer_disp ue=${ue_id} at=enb


Send Nsa Throuput
    [Arguments]    ${ue_id}=31    ${sleep_time}=10s
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=20    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=2    UE ${ue_id}: UDP UL
    
    
    
    
Verify Throuput for NSA
    [Arguments]    ${ue_id}=31    ${sleep_time}=7s    
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput_NSA}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput_NSA}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    [Return]     ${ul_throughput_NSA}      ${dl_throughput_NSA}
    

Check All traffic on cell-3
   [Arguments]     ${ue_id}=1    ${pdu_id}=1    ${min_dl_tput}=145    ${min_ul_tput}=16
    ${total_dl_tput}       ${total_ul_tput}    Check Traffic for Each UE     ue_id=${ue_id}    pdu_id=${pdu_id}   
    ${ul_throughput_NSA}      ${dl_throughput_NSA}     Verify Throuput for NSA
    ${total_dl_tput}    Evaluate    ${dl_throughput_NSA}+${total_dl_tput}
    ${total_ul_tput}    Evaluate    ${ul_throughput_NSA}+${total_ul_tput}    
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${total_ul_tput}/1000 > ${min_ul_tput}
    
    
