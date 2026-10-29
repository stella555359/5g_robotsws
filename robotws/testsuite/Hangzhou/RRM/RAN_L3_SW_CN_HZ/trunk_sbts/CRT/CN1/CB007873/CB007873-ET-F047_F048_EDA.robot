*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-L3CN3_SG2    owner-Song.xiuli    release-5G22R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F

@{PARAMS_IN_SCF}
...    @{Common_Configuration}
...    @{CELL12}
...    @{CELL14}
...    @{CELL2}
...    @{change_golden_wrong_BWP}

@{change_golden_wrong_BWP}
...    delete:BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=4|searchSpaceType=UE-Specific
...    BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific


@{delta_commision_EDA}
...    @{CELL12_CELL1}
...    @{CELL12_CELL2}
...    @{CELL2_CELL12}

@{delta_commision_F047_F048}
...    delete:NRCELL-12/NRREL-3
...    delete:NRCELL-12/NRHOIF-2
...    delete:NRCELL-2/NRREL-1
...    delete:NRCELL-2/NRHOIF-1
...    @{CELL12_CELL1}
...    @{CELL14_CELL1}
...    @{CELL12_CELL14}
...    @{CELL14_CELL12}

@{Common_Configuration}
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:srb3SupportEnabled=false
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRDU-1:actConnectedModeMobilityCA=true
#...    NRCELL-11:msg1FrequencyStart=9
#...    NRCELL-12:msg1FrequencyStart=12
#...    NRCELL-13:msg1FrequencyStart=11
#...    NRCELL-14:msg1FrequencyStart=13
${CA_support_list}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa

@{CELL2}
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:actCDrx=true
...    NRCELL-2:cbraPreamblesPerSsb=n60
...    NRCELL-2:rsrpThresholdSSB=15
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-2:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480

...    NRCELL-2:actK1Opt=intra-gNB


@{CELL12}
...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:actCDrx=true
...    NRCELL-12:cbraPreamblesPerSsb=n60
...    NRCELL-12:rsrpThresholdSSB=15
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-12:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480

...    NRCELL-12:actK1Opt=intra-gNB

@{CELL14}
...    NRCELL-14:a2MeashoEnabled=rsrp
...    NRCELL-14:a1MeashoEnabled=rsrp
...    NRCELL-14:actCDrx=true
...    NRCELL-14:cbraPreamblesPerSsb=n60
...    NRCELL-14:rsrpThresholdSSB=15
...    NRCELL-14:sMeasConfigSsbRsrp=1
...    NRCELL-14:absThreshSsbRsrpConsolidation=1
...    NRCELL-14:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-14:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-14:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-14:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-14:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-14:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
#...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136100
#...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-14:gscnOrSsPbchArfcn=1590
#...    NRCELL-14:type0CoresetConfigurationIndex=0

@{CELL12_CELL1}
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false

@{CELL12_CELL14}
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:lcrId=14
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    delete:NRCELL-12/NRREL-2:sCellAdditionMethod
...    delete:NRCELL-12/NRREL-2:sCellOperationalMode
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-12/NRHOIF-1:cellDepType=NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ssbFrequency=127230
...    NRCELL-12/NRHOIF-1:scs=15 KHz

@{CELL14_CELL1}
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:removeNotAllowed=false

@{CELL14_CELL12}
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-2:gNbId=1
...    NRCELL-14/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-2:lcrId=12
...    NRCELL-14/NRREL-2:gNbIdLength=22
...    NRCELL-14/NRREL-2:removeNotAllowed=false
...    delete:NRCELL-14/NRREL-2:sCellAdditionMethod
...    delete:NRCELL-14/NRREL-2:sCellOperationalMode
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-14/NRHOIF-1:cellDepType=NSA
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-14/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-14/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-14/NRHOIF-1:ssbFrequency=126750
...    NRCELL-14/NRHOIF-1:scs=15 KHz



@{CELL12_CELL2}
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:lcrId=2
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:removeNotAllowed=false

...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-12/NRHOIF-2:cellDepType=NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ssbFrequency=633216
...    NRCELL-12/NRHOIF-2:scs=30 KHz

@{CELL2_CELL12}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:lcrId=12
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:removeNotAllowed=false

...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-2/NRHOIF-1:cellDepType=NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ssbFrequency=126750
...    NRCELL-2/NRHOIF-1:scs=15 KHz

@{PM_Counters_Check_F047}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0

...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-14:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-14:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-14:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-14:${UE_PSCELL_1_CONF_SCELL_DL}>0

...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=3
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_EDA}
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SAMPLES_UE_AMOUNTS}>100
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>100
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-1:${SAMPLES_UE_AMOUNTS}>100
...    NRCELL-2:${SAMPLES_UE_AMOUNTS}>100
...    NRCELL-2:${UE_PSCELL_1_CONF_SCELL_DL}>0


${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SAMPLES_UE_AMOUNTS}    M55118C01000

*** Test Cases ***
CB007873-5G-ET-F047_EDA_PR589396_Verify_intraMeNB_intrafreq_handover_with_PScellchange_inter-freq
    [Documentation]
    ...    HO_intraFreq_intraenb_MENB_initail_InterFreq_IntragNB_pscellchange_withoutSRB3
    ...    Case steps:
    ...    1.CA(F+T pscell12:phycel61,scell cell1:phycel50) and TDD(cell2:phycel51) setup:scell add,drx setup without SRB3
    ...    enb1 cell1 HO to enb1 cell2 Trigger Pscellchage from gnb CA(F+T pscell12,scell cell1)to gnb cell14
    ...    2.TDD(cell2) and CA(F+T pscell12,scell cell1)setup:scell add,drx setup without SRB3
    ...    enb1 cell2 HO to enb1 cell1 Trigger Pscellchage from gnb cell14 to CA(F+T pscell12,scell cell1)
    ...    3.CA(F+T pscell12,scell cell1) and CA(F+T pscell cell14,scell cell1)setup:scell added,drx setup without SRB3
    ...    intraMeNB HO with Pscellchage:enb1 cell1 HO to enb1 cell2,and gnb cell12 to gnb cell14
    ...    4.intraMeNB HO back with Pscellchage:enb1 cell2 to enb1 cell1,and gnb HO from cell14 to gnb cell12
    ...    intraMeNB HO with Pscellchage:enb1 cell1 HO to enb1 cell2,and gnb cell12 to gnb cell14
    [Tags]    QC_89270    F047
    Delta Commission Parameters    ${delta_commision_EDA}
    F-T to T Inter-Freq Intra-gNB HO and back
    Release Ues    ue_type=all
    check wireshark log    ${CURDIR}${/}a2a_EDA${/}a2a.ini
    OnlineParamChange    ${delta_commision_F047_F048}
    F-T to F-T Inter-Freq Intra-gNB HO and back
    Release Ues    ue_type=all
    check wireshark log    ${CURDIR}${/}a2a_F047${/}a2a.ini    name=CAtoCAandBack    wait_string=SgNBModificationConfirm::3

CB007873-5G-ET-F048_Verify_interMeNB_intrafreq_handover_with_PScellchange_inter-freq
    [Documentation]    This case will test interMeNB HO inter_Freq with SRB3
    ...    Case steps:
    ...    1.CA(F+T pscell12,scell cell1) and CA(F+T pscell cell14,scell cell1)setup:scell added,drx setup without SRB3
    ...    2.intraMeNB HO with Pscellchage;enb1 cell1 to enb11 cell1;gnb cell11 to cell12
    ...    3.intraMeNB HO back with Pscellchage;enb11 cell1 to enb1 cell1; gnb cell12 to cell11
    [Tags]    QC_89271    F048
    Delta Commission Parameters    ${delta_commision_F047_F048}
    Setup X2 lINK and Allowed ENDC on with eNB11    enb_id=11
    Ue Attach To gNB and Initial ENDC
    Trigger Inter MeNB Inter Cell HO with PsCellChange from CA to CA    cg-configInfo=0907CB7821F8    eNBId=11
    Trigger Inter MeNB Inter Cell HO with PsCellChange from CA to CA    cg-configInfo=0907BC7821E8    eNBId=1
    Release Ues    ue_type=all
    check wireshark log    ${CURDIR}${/}a2a_F048${/}a2a.ini


*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=${GNB1_CONFIG}

Modify Cfg
    ${V2}    catenate
    ...    set_cell id=14 gnb=2 pci=21:0 tac=200 nrci=0x0E tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=136100:126900
    ...    gscn=1590 mandatory_for_activation=off
    ${V4}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
    ...    type=simulated x2_peers=none
    ${V5}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    mandatory_for_activation=off
    Update Cfg    ${V2}
    Update Cfg    ${V4}
    Update Cfg    ${V5}

Setup X2 lINK and Allowed ENDC on with eNB11
    [Arguments]    ${enb_id}=1    ${cell_id}=1
    Execute Egate Command    enb_x2_link_up enb=${enb_id} target=2    pass_regexp=ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${cell_id} allow_endc=on

Ue Attach To gNB and Initial ENDC
    UE attach gNB cell1
    Initial ENDC    ue_id=91    target_gnb=2    target_cells=12    bearer_id=2
    Allowed ENDC on for eNB-1 cell-1 and cell-2
    Send And Verify Throuput    ue_id=91

UE attach gNB cell1
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial ENDC
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Sending SgNB Modification Confirm    timeout=20s
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    SCellIndex 9 activated successfully

Allowed ENDC on for eNB-1 cell-1 and cell-2
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    Execute Egate Command    enb_cell_param enb=1 id=2 allow_endc=on

Send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=100    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE 91: UDP UL
    Verify Throuput    sleep_time=30s

Verify Throuput
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90


Trigger Intra MeNB Inter Cell HO with PsCellChange from CA to CA
    [Arguments]    ${cg-configInfo}    ${eNB_cellId}
    Execute Egate Command    ue_enb_endc_param id=91 candidate_cells_mn_hex_for_menb_ho=${cg-configInfo}
    Execute Egate Command
    ...    ue_ho id=91 ho_mode=INTRA_LTE enb=1 cell=${eNB_cellId}
    ...     reported successful RA
    Verify Throuput

Trigger Inter MeNB Inter Cell HO with PsCellChange from CA to CA
    [Arguments]    ${cg-configInfo}    ${eNBId}
    Execute Egate Command    ue_enb_endc_param id=91 candidate_cells_mn_hex_for_menb_ho=${cg-configInfo}
    Execute Egate Command
    ...    ue_ho id=91 ho_mode=INTRA_LTE enb=${eNBId} cell=1
    ...    Sending SgNB Modification Confirm

F-T to F-T Inter-Freq Intra-gNB HO and back
    Clear Counter files    True
    Start To Capture Wireshark Log    CAtoCAandBack
    Ue Attach To gNB and Initial ENDC
    Trigger Intra MeNB Inter Cell HO with PsCellChange from CA to CA    cg-configInfo=0907C3F821F8    eNB_cellId=2
    Trigger Intra MeNB Inter Cell HO with PsCellChange from CA to CA    cg-configInfo=0907BC7821E8    eNB_cellId=1
    Check Counters    ${PM_Counters_Check_F047}


F-T to T Inter-Freq Intra-gNB HO and back
    Clear Counter files    False
    Ue Attach To gNB and Initial ENDC
    Trigger Intra MeNB Inter Cell HO with PsCellChange from CA to TDD    cg-configInfo=0926A6002198    eNB_cellId=2
    Trigger Intra MeNB Inter Cell HO with PsCellChange from TDD to CA    cg-configInfo=0907BC7821E8    eNB_cellId=1
    Check Counters    ${PM_Counters_Check_EDA}



Trigger Intra MeNB Inter Cell HO with PsCellChange from CA to TDD
    [Arguments]    ${cg-configInfo}    ${eNB_cellId}
    Execute Egate Command    ue_enb_endc_param id=91 candidate_cells_mn_hex_for_menb_ho=${cg-configInfo}
    Execute Egate Command
    ...    ue_ho id=91 ho_mode=INTRA_LTE enb=1 cell=${eNB_cellId}
    ...     reported successful RA


Trigger Intra MeNB Inter Cell HO with PsCellChange from TDD to CA
    [Arguments]    ${cg-configInfo}    ${eNB_cellId}
    Execute Egate Command    ue_enb_endc_param id=91 candidate_cells_mn_hex_for_menb_ho=${cg-configInfo}
    Execute Egate Command
    ...    ue_ho id=91 ho_mode=INTRA_LTE enb=1 cell=${eNB_cellId}
    ...     reported successful RA
    Verify Throuput

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}