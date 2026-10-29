*** Settings ***
Documentation
...    author:  keyun.ma@nokia-sbell.com
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-lingyan.zhou    release-SBTS24R2    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
#${GNB_BIP_FLAG}    True
#
${SA_UE1_ID}    81
${SA_UE2_ID}    82
${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa_WithUl

@{parameter_dlToUlContributionRatio}
...    NRDU-1:dlToUlContributionRatio=80

@{parameter_dlToUlContributionRatio20}
...    NRDU-1:dlToUlContributionRatio=20

@{PARAMS_IN_SCF}
...    BBMOD-1:prodCodePlanned=475266A.104
...    BBMOD-2:prodCodePlanned=475266A.104
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRCELL:actOptimizedFlowControl=optimizedAllUe
...    NRCELL:actEnhancedPDSCHSchSplSlot=false
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
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
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    @{CELL_pucchF3_andothers}
...    @{tddFrameStructure_NRCELL-1_semiStatic3vs7}
...    @{parameter_p_cell1_3T2F}
...    @{parameter_covBasedA1_related}
...    @{dedicated_bwp_profile_56_NRCELL-1_chbw30M}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actSegUeCapUl=true
...    NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:timingAdvanceOffset=n25600
...    NRDU-1:dlToUlContributionRatio=20
...    NRCELL-1:chBw=30MHz
...    NRCELL-1:reqMinNumPuschPrb=68
...    NRSCTP-1:sctpProfile:sctpRtoInit=30000
...    NRSCTP-1:sctpProfile:sctpRtoMin=30000
...    NRCELL:actDl256Qam=false
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-56
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true

@{dedicated_bwp_profile_56_NRCELL-1_chbw30M}
...    NRBTS/BWP_PROFILE-56:bwpType=dedicated
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-56/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=4|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=19|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=20|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDSCH-1:pdschRat0RbgConfig=config1

@{CELL_pucchF3_andothers}
...    NRCELL:pucchF3MaxCodeRate=zeroDot15
...    NRCELL:pucchF3ModulationScheme=qpsk_4psk
...    NRBTS:actBcsCheck=disabled
...    NRCELL:actCDrx=true
...    NRCELL:actAperCsi=false
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=2 beams
...    NRDU-1:actNonBfAndBfCa=true
...    NRCELL:actPucchAdditionalDmrs=false
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
...    NRCELL-3:nrCellType=4DL2UL
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=4DL2UL
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

@{tddFrameStructure_NRCELL-1_semiStatic3vs7}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-1:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols
...    delete:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:guardPeriodLength=6Symbols
...    delete:NRCELL-3:tddFrameStructure:ulDlDataSlotRatio
...    NRCELL-4:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-4:tddFrameStructure:guardPeriodLength=6Symbols
...    delete:NRCELL-4:tddFrameStructure:ulDlDataSlotRatio

# Parameter For TDD+TDD+TDD+FDD+FDD CA_n41(2A)-n66A-n71A-n78
@{parameter_p_cell1_3T2F}
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
...    NRCELL-4/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-3:sCellOperationalMode=dlOnly
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
...    NRCELL-4/NRREL-11:sCellOperationalMode=dlAndUl
...    NRCELL-4/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-12:gNbId=1
...    NRCELL-4/NRREL-12:gNbIdLength=22
...    NRCELL-4/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-4/NRREL-12:lcrId=12
...    NRCELL-4/NRREL-12:nrDcAllowed=false
...    NRCELL-4/NRREL-12:removeNotAllowed=false
...    NRCELL-4/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-4:maxNumScellsDlFr1=4
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=blind

@{parameter_covBasedA1_related}
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:a1MeasSCellAddEnabled=rsrp
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms


@{PM_Counters_B015_4cc}
...    NRCELL-4:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-4:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-4:RSACU:${GNB_SCELL_3_ADMI_REQ_SA}=0
...    NRCELL-4:RSACU:${GNB_SCELL_3_ADMI_SUCC_SA}=0
...    NRCELL-4:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}=0
...    NRCELL-1:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}=0
...    NRCELL-3:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}=0
...    NRCELL-11:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}=0
...    NRCELL-12:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}=0
...    NRCELL-4:NCAC:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}=0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-12:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-4:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=0
...    NRCELL-4:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=0
...    NRCELL-4:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=0
...    NRCELL-4:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=0
...    NRCELL-4:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=1
...    NRCELL-4:RSADU:${GNB_DU_SCELL_3_ADMI_SUCC_SA}=1
...    NRCELL-4:NCAC:${RRC_RECONF_ADD3DLSCELL_ATT_SA}=1
...    NRCELL-4:NCAC:${RRC_RECONF_ADD3DLSCELL_SUCC_SA}=1

@{PM_Counters_B015_5cc}
...    NRCELL-4:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-4:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-4:RSACU:${GNB_SCELL_3_ADMI_REQ_SA}=0
...    NRCELL-4:RSACU:${GNB_SCELL_3_ADMI_SUCC_SA}=0
...    NRCELL-4:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-12:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-4:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-4:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-4:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=1
...    NRCELL-4:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=1

${GNB_SCELL_4_ADMI_REQ_SA}    M55138C00048
#GNB_SCELL_4_ADMI_REQ_SA    This counter describes the number of radio admission requests for exactly 4 SCells before the
#CA configuration on RRC.
${GNB_SCELL_4_ADMI_SUCC_SA}    M55138C00049
#GNB_SCELL_4_ADMI_SUCC_SA    This counter describes the number of successful radio admission requests for exactly 4 SCells
#before the CA configuration on RRC
${GNB_SCELL_3_ADMI_REQ_SA}    M55138C03001
#GNB_SCELL_3_ADMI_REQ_SA    This counter describes the number of radio admission requests for exactly 3 SCells before the
#CA configuration on RRC.
${GNB_SCELL_3_ADMI_SUCC_SA}    M55138C03002
#GNB_SCELL_3_ADMI_SUCC_SA    This counter describes the number of successful radio admission requests for exactly 3 SCells
#before the CA configuration on RRC
${UE_PCELL_4_CONF_SCELL_DL_SA}    M55118C02016
#UE_PCELL_4_CONF_SCELL_DL_SA    The total number of CA UEs in the current cell configured as a PCell that have exactly 4
#configured SCells in DL in SA mode
${UE_SCELL_4_CONF_SCELL_DL_SA}    M55118C07510
#UE_SCELL_4_CONF_SCELL_DL_SA    The sum of samples for the total number of CA UEs in the current cell configured as an
#SCell while pegged in the secondary cell that has four configured SCells in DL in SA mode.
${UE_PCELL_3_CONF_SCELL_DL_SA}    M55118C09501
#UE_PCELL_3_CONF_SCELL_DL_SA    The total number of CA UEs in the current cell configured as a PCell that have exactly 3
#configured SCells in DL in SA mode
${UE_SCELL_3_CONF_SCELL_DL_SA}    M55118C11009
#UE_SCELL_3_CONF_SCELL_DL_SA    The sum of samples for the total number of CA UEs in the current cell configured as an
#SCell while pegged in the secondary cell that has four configured SCells in DL in SA mode.
${GNB_DU_SCELL_4_ADMI_REQ_SA}    M55139C00023
#GNB_DU_SCELL_4_ADMI_REQ_SA    This counter describes the number of radio admission requests for exactly 4 SCells before
#the CA configuration on RRC.
${GNB_DU_SCELL_4_ADMI_SUCC_SA}    M55139C00024
#GNB_DU_SCELL_4_ADMI_SUCC_SA    This counter describes the number of successful radio admission requests for exactly 4
#SCells before the CA configuration on RRC
${RRC_RECONF_ADD4DLSCELL_ATT_SA}    M55118C02015
#RRC_RECONF_ADD4DLSCELL_ATT_SA    This counter indicates the total number of RRC Reconfiguration attempts for 4 SCells
#Addition in DL for SA mode
${RRC_RECONF_ADD4DLSCELL_SUCC_SA}    M55118C02014
#RRC_RECONF_ADD4DLSCELL_SUCC_SA    This counter indicates the total number of successful RRC Reconfiguration attempts for
#4 SCells Addition in DL for SA mode.
${GNB_DU_SCELL_3_ADMI_REQ_SA}    M55139C03001
#GNB_DU_SCELL_3_ADMI_REQ_SA    This counter describes the number of radio admission requests for exactly 3 SCells before
#the CA configuration on RRC.
${GNB_DU_SCELL_3_ADMI_SUCC_SA}    M55139C03002
#GNB_DU_SCELL_3_ADMI_SUCC_SA    This counter describes the number of successful radio admission requests for exactly 3
#SCells before the CA configuration on RRC
${RRC_RECONF_ADD3DLSCELL_ATT_SA}    M55118C09503
#RRC_RECONF_ADD3DLSCELL_ATT_SA    This counter indicates the total number of RRC Reconfiguration attempts for 3 SCells
#Addition in DL for SA mode
${RRC_RECONF_ADD3DLSCELL_SUCC_SA}    M55118C09502
#RRC_RECONF_ADD3DLSCELL_SUCC_SA    This counter indicates the total number of successful RRC Reconfiguration attempts for
#3 SCells Addition in DL for SA mode.
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
#UE_PCELL_1_CONF_SCELL_UL_SA    This counter shows the sum of samples for total number of CA UEs in the current cell
#configured as a PCell, which have 1 configured SCell in UL.
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
#UE_SCELL_1_CONF_SCELL_UL_SA    This counter shows the sum of samples for the total number of CA UEs in the current cell
#configured as UL SCell, while pegged in the secondary cell, which have 1 configured UL SCell in UL.


#BC 41(2a)+66+71+78, not support 41+78 BC1: 1110110111; not support 66+78 BC2: 1111111101
${SA_Capa_3T2F_simultaneousRxTxInterBandCAPerbandPair}    SEPARATOR=
...    E9E09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607038782E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C0000000000000000007F
...    FFE027FFC00001FFF0000017000038022F0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E2080
...    00010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D0
...    00E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000
...    E23000711800001058158B89A001C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4D00001006175938
...    50001C28000E20800711800389A0000200C0803808D00A2026C04117400DD08C28913639F0E14489B1CF870A244D8E7C3851226C73E1C2891
...    3639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204
...    081B1CF810A040D8E7C09102040810365AF6E4408102040D96BDB00191118C6318C6318C6318C6319E82E003C00281C1401C0C02500700060
...    240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C0100080
...    00000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604
...    560ED0341000009652504000065949010000296524040000E594901000049652404000165949010000696524040001E594901000089652404
...    000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55154AA2E95455058AA0B1541A2A94C55268AA031540A2A93
...    555078A160178095028140A05028140A05028140A05028140A050281400202020180300801002101002008040300610080100202018030080
...    600C10100C018040300610080100202018030080100220100C01804030060100C018202004010080100450100200404030060100C01804030
...    0601002004040080120080100402004010080600C0201803008010021C688800000000002407EDE407FF403543E00020406080C0E1416181A
...    2022242628303236383A3E424A4C4E5052545A5E828305A0

@{UE_3Scells_expect}
...    pcid:53, scellIdx:0
...    pcid:52, scellIdx:1
...    pcid:60, scellIdx:2
...    pcid:61, scellIdx:3
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

@{UE_4Scells_expect}
...    maxCodeRate zeroDot25
...    pcid:53, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:52, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:61, scellIdx:4
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

*** Test Cases ***
CB009855-ET-B015_Activation_3T2F_CA_IWK_simultaneousRxTxInterBandCAPerBandPair_UL_CA_enable_dlToUlContributionRatio_modify
    [Documentation]
    ...    1. The purpose of this test case is to verifies that UE can be or cannot be configured with inter-band CA
    ...       depending on support of simultaneousRxTxInterBandCAPerBandPair IE in UE capabilities and different frame
    ...       structure combinations configured for TDD carriers in gNB.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                   gNB
    ...                   Cell1    Cell2    Cell3    Cell4    Cell11    Cell12
    ...    Technology        TDD      TDD    TDD      TDD      FDD       FDD
    ...          Band        n78      n78    n41      n41      n66       n71
    ...     Bandwidth        30      100    80        80       20       20
    ...     Supercell        NO        No    No        NO      No        No
    ...            BF         No       No    No        Yes     NO        No
    ...    Beam Refinement    No       No         No            No           No         No
    ...    numberOfTransmittedSsBlocks    1    1    1    2      1       1
    ...    pucchF3ModulationScheme    qpsk_4psk  qpsk_4psk   qpsk_4psk   qpsk_4psk   qpsk_4psk   qpsk_4psk
    ...    pucchF3MaxCodeRate    zeroDot15   zeroDot15    zeroDot15    zeroDot15    zeroDot15
    ...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
    ...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
    ...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
    ...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
    ...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols
    ...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
    ...    NRCELL-3:tddFrameStructure:guardPeriodLength=6Symbols
    ...    NRCELL-4:tddFrameStructure:frameStructureType=tdlte
    ...    NRCELL-4:tddFrameStructure:guardPeriodLength=6Symbols
    ...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-12:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
    ...    3. Test Case Steps:
    ...         a. attach UE81 to cell4. trigger A1MR to add scell
    ...         when dlToUlContributionRatio is 20 UL CA is configured (cell11 on n66 band is configured on UL),
    ...         then cell1 on n78 shall not be added as SCell,
    ...         UE should be configured with: cell4 (PCell, n41, 80M) + cell3(DL only SCell, n41, 80M) +
    ...         cell11(dlAndUl SCell, n66, 20M) + cell12(DL only SCell, n71, 20M).
	...         according to 5G_CP_ARC_ALG_6746, aggregated band width for BC2 with 4CC DL and 2CC UL CA should be:
	...         aggrDlUlAvailChBw(n41+n66+n71) = 0.2\*{80 * 0.8 + 20*1.0 + 20*1.0} + 0.8\*{20*0.8(UL ratio according to CP_ALG_8677)}= 33.6
	...         UE is not configured with 5CC DL only because aggrDlUlAvailChBw(n41+n66+n71+n78)=0.2\*{80*0.8+20*1.0 + 20*1.0 + 30*0.7}=25
    ...         b. Release UE81
    ...         c. Online change dlToUlContributionRatio is 80, attach UE81 to cell4 again. UE should be configured with 5CC DL
    ...            cell4 (PCell, n41, 80M) + cell1(DL only SCell, n78, 30M)+cell3(DL only SCell, n41, 80M) +
    ...            cell11(DL only SCell, n66, 20M) + cell12(DL only SCell, n71, 20M) according to 5G_CP_ARC_ALG_6746,
    ...            aggregated band width for BC2 with DL only 5cc CA should be
    ...            0.8\*{80*0.8 + 20*1.0 + 20*1.0 + 30*0.7}=100
    ...            UE is not configured with 4CC DL and 2CC UL because aggrDlUlAvailChBw(n41+n66+n71) =
    ...            0.8\*{80*0.8+20*1.0 + 20*1.0} + 0.2\*{20*0.8}=96
    ...         d. Release UE81
    ...    4. Expected Results:
    ...         a.UE81 is configured with 2T + 2F 4CC DL CA (Pcell--cell4+Scel--cell3,cell11,cell12).traffic is ok.
    ...         T+F 2CC UL CA (Pcell--cell4+Scell--cell11)
    ...         b. Release UE81
    ...         c. UE81 is configured with 3T + 2F 5CC DL CA(Pcell--cell4+Scell--cell1,cell3,cell11,cell12). traffic is ok
    ...         d. Release UE81
    [Tags]    B015    QC_47163    CA_LABEL-TTTFF(80Mhz_TDD_n41+30Mhz_TDD_n78+80Mhz_TDD_n41+20Mhz_FDD_n66+20Mhz_FDD_n71)
    Clear Counter files    False
    Make UE1 4CCDL2CCUL and Traffic normal
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_B015_4cc}
    OnlineParamChange    ${parameter_dlToUlContributionRatio}
    Clear Counter files    True
    Make UE1 again after dlToUlContributionRatio to 80
    Check Counters    ${PM_Counters_B015_5cc}
    [Teardown]    ChangebackdlToUlContributionRatio20

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71

Modify Cfg
    Update Cfg    ue_param id=${SA_UE1_ID} ue_nr_capabilities=${SA_Capa_3T2F_simultaneousRxTxInterBandCAPerbandPair}
    Update Cfg    ue_param id=${SA_UE2_ID} ue_nr_capabilities=${SA_Capa_3T2F_simultaneousRxTxInterBandCAPerbandPair}

ChangebackdlToUlContributionRatio20
    OnlineParamChange    ${parameter_dlToUlContributionRatio20}
    Common Test Teardown And Stop Capture Logs


Sa CA UE Register
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_3T2F_simultaneousRxTxInterBandCAPerbandPair}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=${wait_timer}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}
    ...    fail_regexp=pucch-ResourceSetId 2


Traffic Send Large
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=7 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=8 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=100    UE ${ue_id}: UDP UL



OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

SA CA UE Setup PDU Session
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${expect_regexp}=QoS Routing Table
    [Return]    ${RAN_UE_NGAP_ID[0]}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}
    ...    sleep_time=${wait_timer}
    ${RAN_UE_NGAP_ID}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    [Return]    ${RAN_UE_NGAP_ID}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=4
    ${RAN_UE_NGAP_ID}    SA CA UE Setup PDU Session    ue_id=${ue_id}

UE Scell Add With CoverBased
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${expect_regexp}=${UE_3Scells_expect}
    [Return]    ${RAN_UE_NGAP_ID}
    ${RAN_UE_NGAP_ID}    UE Register And PDU Session Setup    ue_id=${ue_id}
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=526590    pass_reg_ca=${expect_regexp}


Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Throughput Check
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${sleep_time}=15s    ${CC_number}=4
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pusch
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${alldl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_number}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
	END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Verify Throughput When 3 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_number}=4
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_number=${CC_number}



Verify Throughput When 4 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_number}=5
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_number=${CC_number}


Make UE1 4CCDL2CCUL and Traffic normal
    ${RAN_UE_NGAP_ID_1}    UE Scell Add With CoverBased    ue_id=${SA_UE1_ID}
    Set Test Variable    \${RAN_UE_NGAP_ID_1}
    Traffic Send Large    ue_id=${SA_UE1_ID}
    Verify Throughput When 3 Scells    ue_id=${SA_UE1_ID}    Tput_dl=900    Tput_ul=35

Make UE1 again after dlToUlContributionRatio to 80
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${expect_regexp}=${UE_4Scells_expect}
    UE Scell Add With CoverBased    ${ue_id}    ${expect_regexp}
    Traffic Send Large    ue_id=${SA_UE1_ID}
    Verify Throughput When 4 Scells    ue_id=${SA_UE1_ID}    Tput_dl=900    Tput_ul=20
