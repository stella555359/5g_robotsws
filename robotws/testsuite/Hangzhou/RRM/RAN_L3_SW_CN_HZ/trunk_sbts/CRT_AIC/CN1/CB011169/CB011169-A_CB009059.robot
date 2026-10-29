*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G   RAN_Aic    master_vDU    CRT    vDUCNF00    team-HAZ3_SG7
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    release-SBTS24R3    owner-wen.y.xu

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T

@{PARAMS_IN_SCF_CU}    @{PARAMS_FOR_9059}    @{PARAMS_FOR_NRREL}    @{CU_MixedMode_CA}    @{PARAMS_FOR_Handover}    @{BWP_PROFILE}
@{PARAMS_IN_SCF_DU1}    @{PARAMS_FOR_9059}    @{DU1_CELL}    @{BWP_PROFILE}    @{BWP_DU}
@{PARAMS_IN_SCF_DU2}    @{PARAMS_FOR_9059}    @{DU2_CELL}    @{BWP_PROFILE}    @{BWP_DU}

@{PARAMS_FOR_9059}
...    NRDRB-11:cellAggrLevel=FR1 CA eligible    #5qi=6
...    NRDRB-12:cellAggrLevel=Not FR1 CA eligible    #5qi=7
...    NRDRB-13:cellAggrLevel=FR1 CA incompatible   #5qi=8
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA
...    NRCELL:chBw=40MHz

@{PARAMS_FOR_NRREL}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
#vDU1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
#vDU2
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-4:gNbId=1
...    NRCELL-2/NRREL-4:lcrId=4
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-4:sCellOperationalMode=dlOnly

@{CU_MixedMode_CA}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRCELL-3:nrarfcn=518580
...    NRCELL-3:freqBandIndicatorNR=41
...    NRCELL-4:nrarfcn=508620
...    NRCELL-4:freqBandIndicatorNR=41
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-2:actConnectedModeMobilityCA=true
...    NRDU-2:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRDU-2:actInterNumerologyCa=true
...    NRDU-2:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actCDrx=false
...    NRCELL:actAperCsi=false
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations

@{PARAMS_FOR_Handover}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=95
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=34
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=90
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=41
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=40
...    NRBTS/NRPMRNL-1:miNrCABMCCP=disabled

@{DU1_CELL}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRCELL:dlSCellConfigLevel=2
...    NRCELL:dlSCellConfigLevelNum=5
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-1/NRREL-2
...    NRCELL-1/NRREL-3
...    NRCELL-3:nrarfcn=518580
...    NRCELL-3:gscnOrSsPbchArfcn=6486
...    NRCELL-3:freqBandIndicatorNR=41

@{DU2_CELL}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRCELL:dlSCellConfigLevel=2
...    NRCELL:dlSCellConfigLevelNum=5
...    NRDU-2:actConnectedModeMobilityCA=true
...    NRDU-2:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRDU-2:actInterNumerologyCa=true
...    NRDU-2:flexibleCAMode=ConfigurationIndependent
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-2/NRREL-1
...    NRCELL-2/NRREL-4
...    NRCELL-4:nrarfcn=508620
...    NRCELL-4:gscnOrSsPbchArfcn=6357
...    NRCELL-4:freqBandIndicatorNR=41

@{BWP_PROFILE}
...    BWP_PROFILE-0:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-0:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=crb0

@{BWP_DU}
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=1
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1

...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2

...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=3
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3

...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=4
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4

...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5

...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=6
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6

...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7

...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceId=8
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8

...    BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRCELL:msg1FrequencyStart=23

# delta commission
@{bufferbase_and_A1_CU}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA1

@{bufferbase_DU}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRBTS:sCellActivationMethod=bufferBased

# Check point
@{5QI7_6_scell}
...    Setup QosFlow with QFI:1 5QI:7
...    Setup QosFlow with QFI:2 5QI:6
...    SCellIndex 1 activated successfully at airphone

@{5QI6_7_a1}
...    eventId eventA1
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:2 5QI:7
...    QoS Routing Table

@{del_5QI6_del_scell}
...    sCellToReleaseList
...    Removed FiveQi:Qfi mapping fiveQi 6

@{add_5QI6_add_scell}
...    Added QosFlow with QFI:2 fiveQI:6
...    SCellIndex 1 activated successfully at airphone

@{5QI6_8}
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:2 5QI:8
...    QoS Routing Table

@{del_5QI8_add_scell}
...    Removed FiveQi:Qfi mapping fiveQi 8 qfi 2
...    SCellIndex 1 activated successfully at airphone

@{add_5QI8_del_scell}
...    Added QosFlow with QFI:2 fiveQI:8
...    QoS Routing Table
...    sCellToReleaseList

@{5QI6_a1}
...    eventId eventA1
...    pcid:50, scellIdx:0
...    Setup QosFlow with QFI:1 5QI:6
...    rrcReconfigurationComplete

@{5QI7}
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{scell}
...    SCellIndex 1 activated successfully at airphone

@{HO_scell}
...    Intra-eNB handover
...    SCellIndex 1 activated successfully at airphone

@{HO_eventA1}
...    eventId eventA1
...    Intra-eNB handover

@{PM_Counters_Blind_1}
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-1:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-1:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-1:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-1:${DL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-1:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-1:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=1
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=1
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-2:${DL_RRC_1SCELL_REL_ATT_SA}=1
...    NRCELL-2:${DL_RRC_1SCELL_REL_SUC_SA}=1
...    NRCELL-2:${DL_RRC_FSCELL_REL_ATT_SA}=1
...    NRCELL-2:${DL_RRC_FSCELL_REL_SUC_SA}=1

@{PM_Counters_Blind_2}
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=1
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=1
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-1:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-1:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2
...    NRCELL-1:${DL_RRC_1SCELL_REL_ATT_SA}=1
...    NRCELL-1:${DL_RRC_1SCELL_REL_SUC_SA}=1
...    NRCELL-1:${DL_RRC_FSCELL_REL_ATT_SA}=1
...    NRCELL-1:${DL_RRC_FSCELL_REL_SUC_SA}=1
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1
...    NRCELL-2:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-2:${DL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-2:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-2:${DL_RRC_FSCELL_REL_SUC_SA}=0

@{PM_Counters_A1_1}
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-1:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-1:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0

@{PM_Counters_A1_2}
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-1:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-1:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039    #Number of times SCell addition is allowed for a UE due to DRB profile-based CA
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040    #Number of times SCell addition is prevented for a UE due to DRB profile-based CA
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034    #Number of SCells to be released on PCell due to addition of CA-incompatible DRB for SA
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035    #Number of SCells released on PCell due to addition of CA-incompatible DRB for SA
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036    #Number of SCells to be released on PCell due to release of the last CA-eligible DRB
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037    #Number of SCells released on PCell due to release of the last CA-eligible DRB
${DL_RRC_1SCELL_REL_ATT_SA}    M55118C10503    #The number of DL 1 SCell Release attempts on PCell for SA
${DL_RRC_1SCELL_REL_SUC_SA}    M55118C10504    #The number of successful DL 1 SCell Release attempts on PCell for SA
${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042    #The number of DL Full SCell Release attempts on PCell for SA
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043    #The number of successful DL Full SCell Release attempts on PCell for SA

*** Test Cases ***
CB011169-ET-A001-CB009059_inter-du_HO_with_least_one_CA_eligible_DRB_and_No_CA_incompatible_DRB
    [Documentation]
    ...    1 non-GBR AM 0:FR1 CA eligible
    ...    2 non-GBR AM 1:Not FR1 CA eligible
    ...    3 non-GBR AM 2:FR1 CA incompatible
    ...    vDU1
    ...    Pcell1:band=n78, nrarfcn=636666, gscn=7880, ssbFrequency=636576, bandwith=40M
    ...    Scell3:band=n41, nrarfcn=518580, gscn=6486, ssbFrequency=518910, bandwith=40M
    ...    vDU2
    ...    Pcell2:band=n78, nrarfcn=636666, gscn=7880, ssbFrequency=636576, bandwith=40M
    ...    Scell4:band=n41, nrarfcn=508620, gscn=6357, ssbFrequency=508590, bandwith=40M
    [Tags]    CA_LABEL-TTTT(40MHz_TDD_n78_n41)    QC_46984
    Blind Verify UE State after kinds handover
    Online modify Bufferbase and A1
    covBasedA1 Verify UE State after kinds handover

*** Keywords ***
Modify Cfg Aic
    Update Cfg Param Aic    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE_Full} nr_usage_setting=voice_centric
    Update Cfg Aic    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg Aic    set_qosflow id=1 5qi=6 default=on
    Update Cfg Aic    set_qosflow id=2 5qi=7
    Update Cfg Aic    set_qosflow id=3 5qi=8
    Update Cfg Aic    set_qosflow id=4 5qi=9
    Update Cfg Aic    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg Aic    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg Param Aic    set_nwslice id=1 qos_flows=1,2,3,4 qos_rules=1,2 default=on

Online modify Bufferbase and A1
    run keyword and ignore error    delta commission parameters cu    ${bufferbase_and_A1_CU}    # CU restart
    delta commission parameters du    ${bufferbase_DU}
    delta commission parameters du2    ${bufferbase_DU}
    cells should be onair du    check_sib=${False}    timeout=300
    cells should be onair du2    check_sib=${False}

UE Register and PDU1 Session Setup with Multi Qosflow
    [Arguments]    ${def_qos}=1    ${add_qos}=none    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=1    UE now in NG RM Register
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=${def_qos} default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${add_qos}
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Trigger A1 and Check Scell addition and activate
    [Arguments]    ${pass_regexp}=SCellIndex 1 activated successfully at airphone    ${fail_regexp}=none
    ${A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=636576    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${A1} event=A1 srsrq_nr=70 srsrp_nr=90
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

intra-gnb inter-DU HO From Cell1 to Cell2
    [Arguments]    ${pass_regexp}=Intra-eNB handover    ${fail_regexp}=none
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${A3_measid} event=A3 srsrp_nr=30 phycell_id=51 nrsrp_nr=80
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

intra-gnb inter-DU HO From Cell2 to Cell1
    [Arguments]    ${pass_regexp}=Intra-eNB handover    ${fail_regexp}=none
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${A3_measid} event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

UE Register and PDU1 Setup with 1 Qosflow and PDU2 Setup with 2 Qosflow
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Register
    Execute Egate Command    smf_param id=1 reset
    #PDU1: qos1_qfi1_5QI6
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=${5QI6_a1}
    #PDU2: qos2_qfi2_5QI7
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=2 gw=1 nwslice=1    pass_regexp=${5QI7}

Sent Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=150 trf_id=1    Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=150 trf_id=2    Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=50 trf_id=1    Started Uplink

Stop Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=2 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=ul

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=332    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000 > 0
    Should Be True    ${ul_throughput}/1000 > ${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${ue_dl_tput}    Evaluate    ${dl_throughput}+${scell1_tput}
    Should Be True    ${ue_dl_tput}/1000 > ${Tput_dl}

Verify Throughput pcell and no TP in scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=167    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000 > ${Tput_dl}
    Should Be True    ${ul_throughput}/1000 > ${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 == 0

Sent and Verify Throughput pcell and scells
    [Arguments]    ${pdu_id}=1    ${qfi_id}=1
    Sent Throughput    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify Throughput pcell and scells    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Stop Throughput    pdu_id=${pdu_id}    qfi_id=${qfi_id}

Verify no Scell
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=167    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-3 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Sent and Verify Throughput pcell and no TP in scells
    [Arguments]    ${pdu_id}=1    ${qfi_id}=1
    Sent Throughput    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify Throughput pcell and no TP in scells    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Stop Throughput    pdu_id=${pdu_id}    qfi_id=${qfi_id}

DEL DRB
    [Arguments]    ${ue_id}=1    ${qos_id}=1    ${pass_regexp}=Removed FiveQi:Qfi
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

ADD DRB
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qos_id}=1    ${pass_regexp}=Added QosFlow
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

Online modify actDrbProfileForCellAggrLevel value
    [Arguments]    ${para_value}=FR1_SA
    delta commission parameters cu    NRBTS:actDrbProfileForCellAggrLevel=${para_value}
    delta commission parameters du    NRBTS:actDrbProfileForCellAggrLevel=${para_value}
    delta commission parameters du2    NRBTS:actDrbProfileForCellAggrLevel=${para_value}

Blind Verify UE State after inter-du handover with Not FR1 CA eligible DRB DEL ADD CA eligible DRB
    Clear Counter files Cu Aic    wait=${False}
    UE Register and PDU1 Session Setup with Multi Qosflow    def_qos=2    add_qos=1    pass_regexp=${5QI7_6_scell}    #qos2_qfi1_5QI7;qos1_qfi2_5QI6
    Sent and Verify Throughput pcell and no TP in scells    qfi_id=1
    Sent and Verify Throughput pcell and scells    qfi_id=2
    intra-gnb inter-DU HO From Cell1 to Cell2    pass_regexp=${HO_scell}
    Sent and Verify Throughput pcell and no TP in scells    qfi_id=1
    Sent and Verify Throughput pcell and scells    qfi_id=2
    DEL DRB    qos_id=1    pass_regexp=${del_5QI6_del_scell}
    intra-gnb inter-DU HO From Cell2 to Cell1    fail_regexp=${scell}
    ADD DRB    qos_id=1    pass_regexp=${add_5QI6_add_scell}
    Sent and Verify Throughput pcell and no TP in scells    qfi_id=1
    Sent and Verify Throughput pcell and scells    qfi_id=2
    release ues    ue_type=all
    Check Counters Cu Aic    ${PM_Counters_Blind_1}

Blind Verify UE State after inter-du handover with CA eligible DRB DEL ADD incompatible DRB
    Clear Counter files Cu Aic    wait=${False}
    UE Register and PDU1 Session Setup with Multi Qosflow    def_qos=1    add_qos=3    pass_regexp=${5QI6_8}    fail_regexp=${scell}
    intra-gnb inter-DU HO From Cell1 to Cell2    fail_regexp=${scell}
    DEL DRB    qos_id=3    pass_regexp=${del_5QI8_add_scell}
    Sent and Verify Throughput pcell and scells    qfi_id=1
    intra-gnb inter-DU HO From Cell2 to Cell1    pass_regexp=${HO_scell}
    Sent and Verify Throughput pcell and scells    qfi_id=1
    ADD DRB    qos_id=3    pass_regexp=${add_5QI8_del_scell}
    release ues    ue_type=all
    Check Counters Cu Aic    ${PM_Counters_Blind_2}

covBasedA1 Verify UE State after inter-du handover with multiple PDU
    Clear Counter files Cu Aic    wait=${False}
    UE Register and PDU1 Setup with 1 Qosflow and PDU2 Setup with 2 Qosflow
    Sent Throughput    pdu_id=1
    Trigger A1 and Check Scell addition and activate
    Verify Throughput pcell and scells    pdu_id=1
    Stop Throughput    pdu_id=1
    Sent Throughput    pdu_id=2
    Verify Throughput pcell and no TP in scells    pdu_id=2
    intra-gnb inter-DU HO From Cell1 to Cell2    pass_regexp=${HO_eventA1}
    Trigger A1 and Check Scell addition and activate    pass_regexp=physCellId 51    fail_regexp=${scell}
    Verify no Scell    pdu_id=2
    Sent Throughput    pdu_id=1
    Verify Throughput pcell and scells    pdu_id=1
    release ues    ue_type=all
    Check Counters Cu Aic    ${PM_Counters_A1_1}

covBasedA1 Verify UE State after inter-du handover with actDrbProfileForCellAggrLevel disable
    Clear Counter files Cu Aic    wait=${False}
    UE Register and PDU1 Session Setup with Multi Qosflow    add_qos=2    pass_regexp=${5QI6_7_a1}
    Sent Throughput
    Trigger A1 and Check Scell addition and activate
    Verify Throughput pcell and scells
    intra-gnb inter-DU HO From Cell1 to Cell2    pass_regexp=${HO_eventA1}
    Trigger A1 and Check Scell addition and activate
    Verify Throughput pcell and scells
    Online modify actDrbProfileForCellAggrLevel value    para_value=disabled
    Verify Throughput pcell and scells
    ADD DRB    qos_id=3
    Verify Throughput pcell and scells
    intra-gnb inter-DU HO From Cell2 to Cell1    pass_regexp=${HO_eventA1}
    Trigger A1 and Check Scell addition and activate
    Verify Throughput pcell and scells
    release ues    ue_type=all
    Check Counters Cu Aic    ${PM_Counters_A1_2}

Blind Verify UE State after kinds handover
    Blind Verify UE State after inter-du handover with Not FR1 CA eligible DRB DEL ADD CA eligible DRB
    Blind Verify UE State after inter-du handover with CA eligible DRB DEL ADD incompatible DRB

covBasedA1 Verify UE State after kinds handover
    covBasedA1 Verify UE State after inter-du handover with multiple PDU
    covBasedA1 Verify UE State after inter-du handover with actDrbProfileForCellAggrLevel disable
