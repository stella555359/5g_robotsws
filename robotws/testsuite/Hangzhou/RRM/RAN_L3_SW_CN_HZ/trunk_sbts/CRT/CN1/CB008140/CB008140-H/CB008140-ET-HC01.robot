*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    owner-jia.pan    release-SBTS23R3    team-ROCK
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_BWP}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_BWP}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRCELL:weightForSCellSelection=10
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actBcsCheck=enabled_FR1
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check

@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=ms320

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663400
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{GNB1_BWP}
...    NRBTS-1:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:chBw=40MHz

@{GNB2_BWP}
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-5:bwpType=dedicated
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-5/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-11:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-3
...    NRCELL-11:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-4
...    NRCELL-11:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-5
...    NRCELL-11:msg1FrequencyStart=20
...    NRCELL-11/NRCELL_FDD-1:chBwDl=25MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=25MHz
...    NRCELL-12/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-3:chBw=40MHz
...    NRCELL-4:chBw=40MHz

@{expectpcell_cell11}
...    pcid:60
...    Initial Context Setup Successful for UE with AMF UE ID
...    QoS Routing Table
...    locationAndBandwidth 36300    #25MHz

@{expectpcell_cell1}
...    pcid:50
...    Initial Context Setup Successful for UE with AMF UE ID
...    QoS Routing Table

@{expectca_UE1}
...    sCellIndex 1
...    physCellId 50
...    SCellIndex 1 activated successfully
...    locationAndBandwidth 28875    #40Mhz

@{expectca_UE2}
...    sCellIndex 1
...    physCellId 60
...    sCellIndex 2
...    physCellId 61
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    locationAndBandwidth 36300    #25MHz
...    locationAndBandwidth 21450    #15MHz

@{expectca_UE3}
...    sCellIndex 1
...    physCellId 60
...    sCellIndex 2
...    physCellId 61
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    locationAndBandwidth 28875    #20MHz
...    locationAndBandwidth 21450    #15MHz

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
#The total number of radio admission requests for 1 S-Cell in addition of P-Cell in SA mode. 
#Updated to the P-Cell whenever there is an admission request for the UE in SA mode.

${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
#This counter indicates the number of successful radio admission requests for exactly 1 SCell before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.

${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
#Counts the number of inter gNB CA attempts for SA to add one S-Cell.

${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004
#Counts the number of inter gNB CA addition attempts successful for adding one S-Cell for SA.

${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
#This counter is pegged when the S-Cell setup is requested in the ext-gNB-CU during Inter gNB CA by the XnAP: IgNB CA ADDITION REQUEST message.
#The counter is incremented in the ext-gNB per requested S-Cell.

${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
#Counter is pegged when S-Cell setup requested by the message XnAP: IgNB CA ADDITION REQUEST is successful in the ext-gNB-CU.
#The counter is incremented in the ext-gNB per requested S-Cell.

${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter indicates the total number of radio admission requests for SCell before the CA configuration on RRC.
#It's measured in SCell in SA mode in DU only.

${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
#This counter describes the total number of successful radio admission requests for SCell before the CA configuration on RRC.
#It is measured in SCell in SA mode in DU only.

${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
#Counted by the number of XnAP: IgNB CA ADDITION REQUEST message sent from Prime-gNB CU to ext-gNB CU to add SCell(s) for SA.
#The counter is incremented in the ext-gNB at Adjacent gNB level corresponding to the prime-gNB which sent the Xn message,

${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
#This counter indicates the number of radio admission requests for exactly 2 SCells before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.

${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502
#This counter indicates the number of successful radio admission requests for exactly 2 SCells before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.

${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002
#Counted by the number of XnAP: IgNB CA ADDITION REQUEST message sent from Prime-gNB CU to ext-gNB CU to add two S-Cell for SA.
#The counter is incremented in the P-Cell.

${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005
#Counted by the number of XnAP: IgNB CA UE ADDITION REQUEST ACKNOWLEDGE message from ext-gNB CU to Prime-gNB CU for adding two S-Cell for SA.

${GNB_DU_SCELL_ADM_L_BWP_SUCC}    M55139C04002
#The number of successful radio admissions for SCell addition with all SCells with large bandwidth (BWP).
#Note:
#1) The dedicated BWP with frequency size less than the total cell bandwidth is termed as "small BWP" 
#and the BWP with frequency size equal to total cell bandwidth is termed as "large BWP".
#2) This counter is incremented only when NRCELL.actEnhMultipleDedicatedBWPs (for P(S)Cell) equals to TRUE.

${GNB_DU_SCELL_ADM_S_BWP_SUCC}    M55139C04001
#The number of successful radio admissions for SCell addition with at least one SCell with small bandwidth part (BWP).
#Note:
#1) The dedicated BWP with frequency size less than the total cell bandwidth is termed as "small BWP" 
#and the BWP with frequency size equal to total cell bandwidth is termed as "large BWP".
#2) This counter is incremented only when NRCELL.actEnhMultipleDedicatedBWPs (for P(S)Cell) equals to TRUE.

*** Test Cases ***
CB008140-ET-HC01_Verify_Inter-gNB_CA_SCell_selection_interaction_with_25MHz_cell_bandwidth_FR1_FDD
    [Documentation]
    ...    The purpose of this test case is to verify 25MHz FDD cell could be pcell or added as scell when IgNB CA.
    ...    [Configuration]:
    ...    Cell1_1 is TDD cell, Band N77, Bandwidth 40MHz.
    ...    Cell2_11 is FDD cell, Band N3, Bandwidth 25Mhz, Small BWP is configured as 20MHz.
    ...    Cell2_12 is FDD cell, Band N28, Bandwidth 15MHz. 
    ...    UE1 supports band combination n3A_n77A BCS0 and UE supports 25MHz bandwidth for N3
    ...    UE2 supports band combination n3A_n28A_n77A BCS0 and UE supports 25MHz bandwidth for N3.
    ...    UE3 supports band combination n3A_n28A_n77A BCS0 and UE supports 20MHz bandwidth for N3.
    ...    For UE1, Pcell is cell2_11, Scell is Cell1_1.
    ...    For UE2 and UE3, Pcell is Cell1_1, Scell is Cell2_11 and Cell2_12.
    ...    2.Test Case Steps:
    ...         a. UE1 attach to cell2_11 and trigger A1 scell addition should be Successful.
    ...         b. UE2 attach to cell1_1 and trigger A1 scell addition should be Successful.
    ...         c. UE3 attach to cell1_1 and trigger A1 scell addition should be Successful.
    [Tags]    QC_277546    CA_LABEL-FF (25MHz_FDD_n3+ 40MHz_TDD_n77)    CA_LABEL-TFF (40MHz_TDD_n77+ 25MHz_FDD_n3+ 15MHz_FDD_n28)
    ...    CA_LABEL-TFF (40MHz_TDD_n77+ 20MHz_FDD_n3+ 15MHz_FDD_n28)
    Clear Counter Files
    Clear Counter Files gnb2
    UE1 attach to cell2_11 and trigger A1 scell addition should be Successful
    UE2 attach to cell1_1 and trigger A1 scell addition should be Successful
    UE3 attach to cell1_1 and trigger A1 scell addition should be Successful
    Check Counters in GNB1
    Check Counters in GNB2
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F_AHEGB

UE1 attach to cell2_11 and trigger A1 scell addition should be Successful
    Ue Register And PDU Session Setup With UE Capa Update    ${CB008140_N_Capa_Support_2CC_3CC_n3_n28_n41_n77}    ${expectpcell_cell11}
    ...    1    3    11
    Send Throughput
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput on Pscell
    Trigger A1MR    ${expectca_UE1}    368430    100    100    1
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput 2CC on Pscell and Scell
    Release UEs    ue_type=all

UE2 attach to cell1_1 and trigger A1 scell addition should be Successful
    Ue Register And PDU Session Setup With UE Capa Update    ${CB008140_N_Capa_Support_2CC_3CC_n3_n28_n41_n77}    ${expectpcell_cell1}
    ...    2    2    1
    Send Throughput    2
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput on Pscell    2
    Trigger A1MR    ${expectca_UE2}    ue_id=2
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput 3CC on Pscell and Scell    2
    Release UEs    ue_type=all

UE3 attach to cell1_1 and trigger A1 scell addition should be Successful
    Ue Register And PDU Session Setup    ${expectpcell_cell1}     3    2    1 
    Send Throughput    3
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput on Pscell    3
    Trigger A1MR    ${expectca_UE3}    ue_id=3
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput 3CC on Pscell and Scell    3
    Release UEs    ue_type=all

Trigger A1MR
    [Arguments]    ${expectca}    ${carrierfreq}=663360    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${expectca}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa}    
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa}
    Execute Egate Command    ${cmd}
	
Ue Register And PDU Session Setup With UE Capa Update
    [Arguments]    ${SA_Capa}    ${expectpcell}    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1
    Update UE capa    ${ue_id}    ${SA_Capa}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    pass_regexp=${expectpcell}
	
Ue Register And PDU Session Setup
    [Arguments]    ${expectpcell}    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    pass_regexp=${expectpcell} 

Send Throughput
    [Arguments]    ${ue_id}=1    ${times}=2    ${dl_mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    ${times}     Evaluate    ${times}+2
    FOR    ${i}    IN RANGE    2    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${dl_mbps} trf_id=${i}    UE ${ue_id}: UDP DL
    END

Verify Throughput 3CC on Pscell and Scell
    [Arguments]    ${ue_id}=1    ${total_dl_tput}=270    ${ul_tput}=9
    Verify 3CC DL throughput    ${ue_id}    ${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul_tput}

Verify 3CC DL throughput
    [Arguments]    ${ue_id}=1    ${total_tput}=800
    Execute Egate Command     ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=Average
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 >= 0
    ${total_dl}    Evaluate    ${scell1_tput}+${total_dl}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 >= 0
    ${total_dl}    Evaluate    ${scell2_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_tput}
	
Verify Throughput on Pscell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=100    ${ul}=9  
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throughput 2CC on Pscell and Scell
    [Arguments]    ${ue_id}=1    ${total_tput}=270    ${ul}=9     
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Check Counters in GNB1
    ${pm_counters}    Create List    
    ...    NRCELL-1:${IGNB_CA_SCELL_ADMI_REQ_SA}=1    #UE1
    ...    NRCELL-1:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1    #UE1
    ...    NRCELL-1:${GNB_DU_SCELL_ADMI_REQ_SA}=1    #UE1
    ...    NRCELL-1:${GNB_DU_SCELL_ADMI_SUCC_SA}=1    #UE1
    ...    NRBTS-2:${IGNB_CA_ADD_REQ_SA_NRADJ}=1    #UE1
    ...    NRCELL-1:${GNB_DU_SCELL_ADM_L_BWP_SUCC}=1    #UE2
    ...    NRCELL-1:${GNB_DU_SCELL_2_ADMI_REQ_SA}=2    #UE2&UE3
    ...    NRCELL-1:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=2    #UE2&UE3
    ...    NRCELL-1:${IGNB_CA_ATT_2_SCELL_SA}=2    #UE2&UE3
    ...    NRCELL-1:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=2    #UE2&UE3
    ...    NRCELL-1:${GNB_DU_SCELL_ADM_S_BWP_SUCC}=1    #UE3
    Check Counters    ${pm_counters}

Check Counters in GNB2
    ${pm_counters}    Create List
    ...    NRCELL-11:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1    #UE1
    ...    NRCELL-11:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1    #UE1
    ...    NRCELL-11:${GNB_DU_SCELL_ADM_L_BWP_SUCC}=1    #UE1
    ...    NRCELL-11:${IGNB_CA_ATT_1_SCELL_SA}=1    #UE1
    ...    NRCELL-11:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1    #UE1
    ...    NRCELL-11:${IGNB_CA_SCELL_ADMI_REQ_SA}=2    #UE2&UE3
    ...    NRCELL-12:${IGNB_CA_SCELL_ADMI_REQ_SA}=2    #UE2&UE3
    ...    NRCELL-11:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2    #UE2&UE3
    ...    NRCELL-12:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2    #UE2&UE3
    ...    NRCELL-11:${GNB_DU_SCELL_ADMI_REQ_SA}=2    #UE2&UE3
    ...    NRCELL-12:${GNB_DU_SCELL_ADMI_REQ_SA}=2    #UE2&UE3
    ...    NRCELL-11:${GNB_DU_SCELL_ADMI_SUCC_SA}=2    #UE2&UE3
    ...    NRCELL-12:${GNB_DU_SCELL_ADMI_SUCC_SA}=2    #UE2&UE3	
    ...    NRBTS-1:${IGNB_CA_ADD_REQ_SA_NRADJ}=2    #UE2&UE3
    Check Counters GNB2    ${pm_counters}

