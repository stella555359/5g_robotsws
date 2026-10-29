*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_Aic    master_vDU    CRT    vDUCNF00    team-DevHZ5_SG02
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    SANSA_FS_ECPRI_CMWV_TDD_CPRI_CMWV_FDD    owner-jianfen.shen    release-5G24R3

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
@{FAULTS_EXCLUDED_CHECKING}
...    4681
${SYSCOM_FLAG}    ${True}
${UTE_WIRESHARK_FLAG}    ${False}

${SA_UE_ID_1}    1
${SA_UE_ID_2}    2
${NSA_UE_ID_1}    31
${NSA_UE_ID_2}    32

@{PARAMS_IN_SCF_CU}
...    @{CA_COMMON}
...    @{NRREL_CU}
...    @{Cell_parameters}
...    @{Cell_BWPs}
...    @{BWPs_CU}

@{PARAMS_IN_SCF_DU1}
...    @{CA_COMMON}
...    @{NRREL_DU}
...    @{UL_CA_enable_DU}
...    @{Cell_parameters}
...    @{Cell_BWPs}
...    @{BWPs_DU}


@{CA_COMMON}
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:actConnectedModeMobilityCA=true

@{NRREL_CU}
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-1:lcrId=2
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-1:isRplCellForPSCell=true
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-4/NRREL-1:isRplCellForPSCell=true
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlAndUl

@{NRREL_DU}
...    NRCELL-3/NRREL-1
...    NRCELL-4/NRREL-1

@{UL_CA_enable_DU}
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS-1/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS-1/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

@{Cell_parameters}
...    NRCELL:actPRBBlanking=false
...    NRCELL-2:chBw=50MHz
...    NRCELL-3/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-3/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-4/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-4/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-1:maxNumOfCaUsersNRCell=130
...    NRCELL-2:maxNumOfCaUsersNRCell=130

@{Cell_BWPs}
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-87
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-82
...    NRCELL-3:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8
...    NRCELL-4:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-12
...    NRCELL-4:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-13

@{BWPs_CU}
...    @{BWP_PROFILE_3_CU}
...    @{BWP_PROFILE_87_CU}
...    @{BWP_PROFILE_5_CU}
...    @{BWP_PROFILE_82_CU}
...    @{BWP_PROFILE_7_CU}
...    @{BWP_PROFILE_8_CU}
...    @{BWP_PROFILE_12_CU}
...    @{BWP_PROFILE_13_CU}

@{BWPs_DU}
...    @{BWP_PROFILE_3_DU}
...    @{BWP_PROFILE_87_DU}
...    @{BWP_PROFILE_5_DU}
...    @{BWP_PROFILE_82_DU}
...    @{BWP_PROFILE_7_DU}
...    @{BWP_PROFILE_8_DU}
...    @{BWP_PROFILE_12_DU}
...    @{BWP_PROFILE_13_DU}
...    NRCELL-1:msg1FrequencyStart=0
...    NRCELL-2:msg1FrequencyStart=0
...    NRCELL:maxNumPdschAllocationPerSlot=4
...    NRCELL:maxNumPuschAllocationPerSlot=4

@{BWP_PROFILE_3_CU}
...    BWP_PROFILE-3:bwpProfileId=3
...    BWP_PROFILE-3:bwpType=initial
...    BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-3:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-3:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-3:locationAndBandwidthUl:cRbStartUl=sameAsDl

@{BWP_PROFILE_3_DU}
...    BWP_PROFILE-3:bwpProfileId=3
...    BWP_PROFILE-3:bwpType=initial
...    BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-3:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-3:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-3:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-3/PDCCH-1:alSelection=static
...    BWP_PROFILE-3/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-3/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-3/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-3/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-3/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-3/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-3/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-3/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-3/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2

@{BWP_PROFILE_87_CU}
...    BWP_PROFILE-87:bwpProfileId=87
...    BWP_PROFILE-87:bwpType=dedicated
...    BWP_PROFILE-87:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-87:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-87:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-87:locationAndBandwidthUl:cRbStartUl=sameAsDl

@{BWP_PROFILE_87_DU}
...    BWP_PROFILE-87:bwpProfileId=87
...    BWP_PROFILE-87:bwpType=dedicated
...    BWP_PROFILE-87:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-87:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-87:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-87:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-87/PDCCH-1:alSelection=static
...    BWP_PROFILE-87/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-87/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-87/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-87/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-87/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-87/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-87/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-87/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-87/PDSCH-1:pdschId=1
...    BWP_PROFILE-87/PDSCH-1:pdschRat0RbgConfig=config1

@{BWP_PROFILE_5_CU}
...    BWP_PROFILE-5:bwpProfileId=5
...    BWP_PROFILE-5:bwpType=initial
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=sameAsDl

@{BWP_PROFILE_5_DU}
...    BWP_PROFILE-5:bwpProfileId=5
...    BWP_PROFILE-5:bwpType=initial
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-5/PDCCH-1:alSelection=static
...    BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-5/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-5/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2

@{BWP_PROFILE_82_CU}
...    BWP_PROFILE-82:bwpProfileId=82
...    BWP_PROFILE-82:bwpType=dedicated
...    BWP_PROFILE-82:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-82:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-82:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-82:locationAndBandwidthUl:cRbStartUl=sameAsDl

@{BWP_PROFILE_82_DU}
...    BWP_PROFILE-82:bwpProfileId=82
...    BWP_PROFILE-82:bwpType=dedicated
...    BWP_PROFILE-82:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-82:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-82:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-82:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-82/PDCCH-1:alSelection=static
...    BWP_PROFILE-82/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-82/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-82/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-82/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-82/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-82/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-82/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-82/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-82/PDSCH-1:pdschId=1
...    BWP_PROFILE-82/PDSCH-1:pdschRat0RbgConfig=config1

@{BWP_PROFILE_7_CU}
...    BWP_PROFILE-7:bwpProfileId=7
...    BWP_PROFILE-7:bwpType=initial
...    BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb0

@{BWP_PROFILE_7_DU}
...    BWP_PROFILE-7:bwpProfileId=7
...    BWP_PROFILE-7:bwpType=initial
...    BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-7/PDCCH-1:alSelection=static
...    BWP_PROFILE-7/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-7/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-7/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-7/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2

@{BWP_PROFILE_8_CU}
...    BWP_PROFILE-8:bwpProfileId=8
...    BWP_PROFILE-8:bwpType=dedicated
...    BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=sameAsDl

@{BWP_PROFILE_8_DU}
...    BWP_PROFILE-8:bwpProfileId=8
...    BWP_PROFILE-8:bwpType=dedicated
...    BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-8/PDCCH-1:alSelection=static
...    BWP_PROFILE-8/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-8/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-8/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-8/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-8/PDSCH-1:pdschId=1
...    BWP_PROFILE-8/PDSCH-1:pdschRat0RbgConfig=config1

@{BWP_PROFILE_12_CU}
...    BWP_PROFILE-12:bwpProfileId=12
...    BWP_PROFILE-12:bwpType=initial
...    BWP_PROFILE-12:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-12:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=crb0

@{BWP_PROFILE_12_DU}
...    BWP_PROFILE-12:bwpProfileId=12
...    BWP_PROFILE-12:bwpType=initial
...    BWP_PROFILE-12:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-12:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-12/PDCCH-1:alSelection=static
...    BWP_PROFILE-12/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-12/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-12/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-12/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-12/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-12/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-12/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-12/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-12/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2

@{BWP_PROFILE_13_CU}
...    BWP_PROFILE-13:bwpProfileId=13
...    BWP_PROFILE-13:bwpType=dedicated
...    BWP_PROFILE-13:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-13:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbStartUl=sameAsDl

@{BWP_PROFILE_13_DU}
...    BWP_PROFILE-13:bwpProfileId=13
...    BWP_PROFILE-13:bwpType=dedicated
...    BWP_PROFILE-13:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-13:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-13/PDCCH-1:alSelection=static
...    BWP_PROFILE-13/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-13/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-13/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDSCH-1:pdschId=1
...    BWP_PROFILE-13/PDSCH-1:pdschRat0RbgConfig=config1

@{actPRBBlanking_cell2_CU}
...    NRCELL-2:actPRBBlanking=true
...    NRCELL-2:nbrOfBlankedPRBsHighEdgeDL = 10
...    NRCELL-2:nbrOfBlankedPRBsHighEdgeUL = 10
...    NRCELL-2:nbrOfBlankedPRBsLowEdgeDL = 2
...    NRCELL-2:nbrOfBlankedPRBsLowEdgeUL = 2

@{actPRBBlanking_cell2_DU}
...    NRCELL-2:actPRBBlanking=true
...    NRCELL-2:nbrOfBlankedPRBsHighEdgeDL = 10
...    NRCELL-2:nbrOfBlankedPRBsHighEdgeUL = 10
...    NRCELL-2:nbrOfBlankedPRBsLowEdgeDL = 2
...    NRCELL-2:nbrOfBlankedPRBsLowEdgeUL = 2
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=6
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=114

@{actPRBBlanking_cell3_CU}
...    NRCELL-3:actPRBBlanking=true
...    NRCELL-3:nbrOfBlankedPRBsHighEdgeDL = 0
...    NRCELL-3:nbrOfBlankedPRBsHighEdgeUL = 0
...    NRCELL-3:nbrOfBlankedPRBsLowEdgeDL = 0
...    NRCELL-3:nbrOfBlankedPRBsLowEdgeUL = 26
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=n53
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb26
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=crb0

@{actPRBBlanking_cell3_DU}
...    NRCELL-3:actPRBBlanking=true
...    NRCELL-3:nbrOfBlankedPRBsHighEdgeDL = 0
...    NRCELL-3:nbrOfBlankedPRBsHighEdgeUL = 0
...    NRCELL-3:nbrOfBlankedPRBsLowEdgeDL = 0
...    NRCELL-3:nbrOfBlankedPRBsLowEdgeUL = 26
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=n53
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb26
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=crb0

@{actPRBBlanking_cell4_CU}
...    NRCELL-4:actPRBBlanking=true
...    NRCELL-4:nbrOfBlankedPRBsHighEdgeDL = 0
...    NRCELL-4:nbrOfBlankedPRBsHighEdgeUL = 26
...    NRCELL-4:nbrOfBlankedPRBsLowEdgeDL = 0
...    NRCELL-4:nbrOfBlankedPRBsLowEdgeUL = 0
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=n80
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbStartUl=crb0

@{actPRBBlanking_cell4_DU}
...    NRCELL-4:actPRBBlanking=true
...    NRCELL-4:nbrOfBlankedPRBsHighEdgeDL = 0
...    NRCELL-4:nbrOfBlankedPRBsHighEdgeUL = 26
...    NRCELL-4:nbrOfBlankedPRBsLowEdgeDL = 0
...    NRCELL-4:nbrOfBlankedPRBsLowEdgeUL = 0
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=n80
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=102

@{actPRBBlanking_disabled_CU}
...    NRCELL:actPRBBlanking=false
...    NRCELL:nbrOfBlankedPRBsLowEdgeDL=0
...    NRCELL:nbrOfBlankedPRBsHighEdgeDL=0
...    NRCELL:nbrOfBlankedPRBsLowEdgeUL=0
...    NRCELL:nbrOfBlankedPRBsHighEdgeUL=0
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbStartUl=sameAsDl

@{actPRBBlanking_disabled_DU}
...    NRCELL:actPRBBlanking=false
...    NRCELL:nbrOfBlankedPRBsLowEdgeDL=0
...    NRCELL:nbrOfBlankedPRBsHighEdgeDL=0
...    NRCELL:nbrOfBlankedPRBsLowEdgeUL=0
...    NRCELL:nbrOfBlankedPRBsHighEdgeUL=0
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

@{SA_FT scell2 addition}
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:60, scellIdx:0] configure_0_1

@{SA_FT scell1 addition}
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:50, scellIdx:1] configure_0_1
...    pcid:61, scellIdx:0] configure_1_1
...    pcid:61, scellIdx:0] configure_0_1

@{NSA_FT scell2 addition}
...    sCellToAddModList
...    pcid:60, scellIdx:1
...    pcid:51, scellIdx:2
...    reported successful RA

@{NSA_FT scell1 addition}
...    sCellToAddModList
...    pcid:61, scellIdx:1
...    pcid:50, scellIdx:2
...    reported successful RA

@{PM_Counters_Check_A006_DU}
...    last NRCELL-3:NCELA:${UL_PRB_UTIL_SLOT_MAX}=100
...    last NRCELL-3:NCELA:${MAX_SCHED_UE_PUSCH}=2
...    last NRCELL-4:NCELA:${UL_PRB_UTIL_SLOT_MAX}=100
...    last NRCELL-4:NCELA:${MAX_SCHED_UE_PUSCH}=2

${PRB_AVAIL_PUSCH}    M55308C10004     #PRBs available for PUSCH
${UL_PRB_UTIL_SLOT_MAX}    M55308C36002     #Maximum UL PRB Utilization per slot
${MAX_SCHED_UE_PUSCH}    M55308C18002     #Maximum number of scheduled (FDM and MU-MIMO) UEs on PUSCH per slot

${pdu_id}    1
${gw_id}    1
${nwslice}    1

${UE_NR_CAPA_N78_N5_UL_2CC}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670FC24026C830E7CC31E50B038260300C47006A8D89BAC1184341020E9068030B64C55110E7
...    C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0005C0000E0541B013582328682041E5949A20D00656C98AB121CF88E3D81
...    3E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001720003800DA5555255550002F0F1340038080000042C040801800901345D000
...    3C030A244D8E7C30140467A0B800F000A070500703009401C0018090010180F82400800000004000008020000000100000200800002004000
...    018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080
...    000C03395359535829581B5833582B594B5933580B581B58095811583B40D04000025949418000196524040000A5949010000396524040001
...    25949018000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334
...    AAAF954154AA2E95455058BE07055068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A0500
...    0108080600C02004008404008020100C0186A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${UE_MRDC_CAPA_N4_N78_N5}
...    A11FF80BC4C0C0389A001C0400000016220401003800901345D00042031274489B1CF8601402318011000040202004010080600C2000080404008010100C0180


*** Test Cases ***
CB010414_CB010850-ET-A006_Verify_Feature_interaction_with_UL_CA_FT_2CC_in_15MHz_20MHz
    [Documentation]
    ...    This case is migration from classical case: CIT036-CB010850-ET-A006, anc change the band, chbw due to RUs difference
    ...    New parameter for 10850 :
    ...    actPRBBlanking: activates/deactivates 10850
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeDL
    ...    NRCELL.nbrOfBlankedPRBsHighEdgeUL
    ...    NRCELL.nbrOfBlankedPRBsLowEdgeUL
    ...    1. This user scenario describes FDD Cell UL PRB blanking activation successfully and interworking with NSA DL CA and SA UL CA.
    ...    2. Configuration:
    ...           cell id=2 band=n78 chbw=50MHz nbrOfBlankedPRBsHighEdgeUL=10 nbrOfBlankedPRBsHighEdgeDL=10
    ...                                         nbrOfBlankedPRBsLowEdgeUL= 2 nbrOfBlankedPRBsLowEdgeDL =2 BWP_PROFILE-5 BWP_PROFILE-82
    ...           cell id=3 band=n5 chbw=15MHz nbrOfBlankedPRBsHighEdgeUL=0 nbrOfBlankedPRBsLowEdgeUL=26 BWP_PROFILE-7 BWP_PROFILE-8
    ...           cell id=4 band=n5 chbw=20MHz nbrOfBlankedPRBsHighEdgeUL=26 nbrOfBlankedPRBsLowEdgeUL=0 BWP_PROFILE-12 BWP_PROFILE-13
    ...        Configure nrrel Relations:
    ...           cell3-cell2, cell4-cell1
    ...        UE Capability: should support UL CA
    ...    3. Test Case Steps:
    ...       1). Trigger UL prb blanking online activation on FDD cell3 and FDD cell4, and DL UL prb blanking online activation on TDD cell2.
    ...           cell2 on air and longPucchStartPuschPrb and longPucchNumPuschPrb of Dedicated BWP;
    ...           longPucchStartPuschPrb and longPucchNumPuschPrb of Initial BWP in cell2 tf_l2_ps_cell_cellsetupreq is match with NIDD
    ...           cell3 and cell4 on air and initialUplinkBWP configuration in cell3 and cell4 tf_l2_ps_cell_cellsetupreq are match with NIDD
    ...       2). SA UE81 attaches to FDD cell3 and trigger blind SCell Addition to make FT 2CC UL CA.
    ...           SA UE82 attaches to FDD cell4 and trigger blind SCell Addition to make FT 2CC UL CA.
    ...           cell3 add cell2 as scell to make FT 2CC SA UL CA successfully.
    ...           cell4 add cell1 as scell to make FT 2CC SA UL CA successfully.
    ...       3). NSA UE91 attaches to FDD cell3 for blind SCell Addition to make FT 2CC DL CA.
    ...           NSA UE92 attaches to FDD cell4 for blind SCell Addition to make FT 2CC DL CA.
    ...           cell3 add cell2 as scell to make FT 2CC NSA DL CA successfully.
    ...           cell4 add cell1 as scell to make FT 2CC NSA DL CA successfully.
    [Tags]    QC_361846    CA_LABEL-FT(15MHz_FDD_n5+50MHz_TDD_n78)    CA_LABEL-FT(20MHz_FDD_n5+100MHz_TDD_n78)
    Clear Counter Files Du Aic
    Step1 online enable PRBBlanking
    Step2 SA UE attach to cell in FT UL CA
    Step3 NSA UE attach to cell in FT DL CA
    Check WireShark Log Aic    ${CURDIR}${/}a2a_10850${/}a2a.ini    wait_string=SNStatusTransfer::4
    Check initialUplinkBWP Configuration In Syscom
    Check Counters Du Aic    ${PM_Counters_Check_A006_DU}
    [Teardown]     Test Teardown and Recover SCF

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    ue_param id=${SA_UE_ID_1} ue_nr_capabilities=${UE_NR_CAPA_N78_N5_UL_2CC}
    Update Cfg Aic    ue_param id=${SA_UE_ID_2} ue_nr_capabilities=${UE_NR_CAPA_N78_N5_UL_2CC}
    ${nsa_ue1_cmd}    catenate
    ...    ue_param id=${NSA_UE_ID_1} ue_nr_capabilities=${UE_NR_CAPA_N78_N5_UL_2CC} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${UE_MRDC_CAPA_N4_N78_N5}
    Update Cfg Aic    ${nsa_ue1_cmd}
    ${nsa_ue2_cmd}    catenate
    ...    ue_param id=${NSA_UE_ID_2} ue_nr_capabilities=${UE_NR_CAPA_N78_N5_UL_2CC} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${UE_MRDC_CAPA_N4_N78_N5}
    Update Cfg Aic    ${nsa_ue2_cmd}

Test Teardown and Recover SCF
    OnlineParamChange    ${actPRBBlanking_disabled_CU}    ${actPRBBlanking_disabled_DU}
    Common Test Teardown And Stop Capture Logs Aic

OnlineParamChange
    [Arguments]    ${Online_Param_CU}    ${Online_Param_DU}
    Delta Commission Parameters Cu    ${Online_Param_CU}
    Delta Commission Parameters Du    ${Online_Param_DU}
    Cells Should Be Onair Du

Step1 online enable PRBBlanking
    OnlineParamChange    ${actPRBBlanking_cell2_CU}    ${actPRBBlanking_cell2_DU}
    OnlineParamChange    ${actPRBBlanking_cell3_CU}    ${actPRBBlanking_cell3_DU}
    OnlineParamChange    ${actPRBBlanking_cell4_CU}    ${actPRBBlanking_cell4_DU}

Step2 SA UE attach to cell in FT UL CA
    UE Attach To Target Cell    cell_id=3    ue_id=${SA_UE_ID_1}    pass_regexp=${SA_FT scell2 addition}
    Send Throuput For SA    ue_id=${SA_UE_ID_1}
    UE Attach To Target Cell    cell_id=4    ue_id=${SA_UE_ID_2}    pass_regexp=${SA_FT scell1 addition}
    Send Throuput For SA    ue_id=${SA_UE_ID_2}
    Wait Until Keyword Succeeds    30s    10s    Verify SA dl Throuput For UL FT    ue_id=${SA_UE_ID_1}
    Wait Until Keyword Succeeds    30s    10s    Verify SA ul Throuput For UL FT    ue_id=${SA_UE_ID_1}    total_ul_tput=30
    Wait Until Keyword Succeeds    30s    10s    Verify SA dl Throuput For UL FT    ue_id=${SA_UE_ID_2}
    Wait Until Keyword Succeeds    30s    10s    Verify SA ul Throuput For UL FT    ue_id=${SA_UE_ID_2}    total_ul_tput=100

Step3 NSA UE attach to cell in FT DL CA
    NSA UE Attach To Target Cell    cell_id=3    ue_id=${NSA_UE_ID_1}    pass_regexp=${NSA_FT scell2 addition}
    Send Throuput For NSA    ue_id=${NSA_UE_ID_1}
    NSA UE Attach To Target Cell    cell_id=4    ue_id=${NSA_UE_ID_2}    pass_regexp=${NSA_FT scell1 addition}
    Send Throuput For NSA    ue_id=${NSA_UE_ID_2}
    Wait Until Keyword Succeeds    30s    10s    Verify NSA dl Throuput For DL FT    ue_id=${NSA_UE_ID_1}
    Wait Until Keyword Succeeds    30s    10s    Verify NSA ul Throuput For DL FT    ue_id=${NSA_UE_ID_1}
    Wait Until Keyword Succeeds    30s    10s    Verify NSA dl Throuput For DL FT    ue_id=${NSA_UE_ID_2}
    Wait Until Keyword Succeeds    30s    10s    Verify NSA ul Throuput For DL FT    ue_id=${NSA_UE_ID_2}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    pass_regexp=${pass_regexp}

Send Throuput For SA
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=3    UE ${ue_id}: UDP UL

Verify SA dl Throuput For UL FT
    [Arguments]    ${ue_id}    ${total_dl_tput}=250
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tputdl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tputdl}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tputdl}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}

Verify SA ul Throuput For UL FT
    [Arguments]    ${ue_id}    ${total_ul_tput}=30
    ${pcell_ul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${pcell_ul}/1000 > 0
    ${total_ul}    Set Variable    ${pcell_ul}
    ${scell1_tputul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${scell1_tputul}/1000 > 0
    ${total_ul}    Evaluate    ${scell1_tputul}+${total_ul}
    Should Be True    ${total_ul}/1000>${total_ul_tput}

NSA UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}    ${pass_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=${pass_regexp}

Send Throuput For NSA
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=100 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=100 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=50 trf_id=3    UE ${ue_id}: UDP UL

Verify NSA dl Throuput For DL FT
    [Arguments]    ${ue_id}    ${total_dl_tput}=100
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tputdl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tputdl}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tputdl}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}

Verify NSA ul Throuput For DL FT
    [Arguments]    ${ue_id}    ${total_ul_tput}=15
    ${pcell_ul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${pcell_ul}/1000 > 0
    ${total_ul}    Set Variable    ${pcell_ul}
    Should Be True    ${total_ul}/1000>${total_ul_tput}

Stop Traffic and UE Detach
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached

Check initialUplinkBWP Configuration In Syscom
    BuiltIn.Log To Console    check initialUplinkBWP configuration in cell2 tf_l2_ps_cell_cellsetupreq
    ${filter_ms1}    catenate
    ...    itf_l2_ps_cell_CellSetupReq_t.physCellId == 51 and itf_l2_ps_cell_Bwp.bwpType == 0 and
    ...    itf_l2_ps_cell_BwpDefinitionUl.location == 40 and itf_l2_ps_cell_BwpDefinitionUl.bandwidth == 48 and
    ...    itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item == 0 and itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item == 48 and
    ...    itf_l2_ps_cell_Bwp.bwpType == 1 and itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item == 15 and
    ...    itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item == 95
    get_wireshark_field_value    pcap_file=${SAVE LOG DIRECTORY}${/}/du_cprt_wireshark.pcap
    ...    field_path=itf_l2_ps_cell_BwpDefinitionUl/location    display_filter=${filter_ms1}
    BuiltIn.Log To Console    initialUplinkBWP configuration in cell3 tf_l2_ps_cell_cellsetupreq
    ${filter_ms2}    catenate
    ...    itf_l2_ps_cell_CellSetupReq_t.physCellId == 60 and itf_l2_ps_cell_Bwp.bwpType == 0 and
    ...    itf_l2_ps_cell_BwpDefinitionUl.location == 26 and itf_l2_ps_cell_BwpDefinitionUl.bandwidth == 53 and
    ...    itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item == 8 and itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item == 37 and
    ...    itf_l2_ps_cell_Bwp.bwpType == 1 and itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item == 34 and
    ...    itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item == 37
    get_wireshark_field_value    pcap_file=${SAVE LOG DIRECTORY}${/}/du_cprt_wireshark.pcap
    ...    field_path=itf_l2_ps_cell_BwpDefinitionUl/location   display_filter=${filter_ms2}
    ${filter_ms3}    catenate
    ...    itf_l2_ps_cell_CellSetupReq_t.physCellId == 61 and itf_l2_ps_cell_Bwp.bwpType == 0 and
    ...    itf_l2_ps_cell_BwpDefinitionUl.location == 0 and itf_l2_ps_cell_BwpDefinitionUl.bandwidth == 80 and
    ...    itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item == 8 and itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item == 64 and
    ...    itf_l2_ps_cell_Bwp.bwpType == 1 and itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item == 8 and
    ...    itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item == 64
    BuiltIn.Log To Console    check initialUplinkBWP configuration in cell4 tf_l2_ps_cell_cellsetupreq
    get_wireshark_field_value    pcap_file=${SAVE LOG DIRECTORY}${/}/du_cprt_wireshark.pcap
    ...    field_path=itf_l2_ps_cell_BwpDefinitionUl/location    display_filter=${filter_ms3}

