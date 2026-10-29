*** Settings ***
Documentation
...    author: Baijie Zhu
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07

Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G   RAN_Aic    master_vDU    CRT    vDUCNF00    team-HAZ3_SG7
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    release-SBTS25R3    owner-zhubaijie

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T

@{PARAMS_IN_SCF_CU}    @{PARAMS_FOR_9059}    @{PARAMS_FOR_NRREL}    @{CU_MixedMode_CA}    @{PARAMS_FOR_Handover}    @{BWP_PROFILE}
...    @{PCMD_flag_Enable}    @{NRMTRACECU}    @{CellTrace_enable}    @{rrcReestab}    @{xn_setup}    @{NRADJNRCELL}

@{PARAMS_IN_SCF_DU1}    @{PARAMS_FOR_9059}    @{DU1_CELL}    @{BWP_PROFILE}    @{BWP_DU}
...    @{PCMD_flag_Enable}    @{TCE_vDU1}    @{PCMD_DU1_Enable}    @{CellTrace_enable}    @{rrcReestab}

@{PARAMS_IN_SCF_DU2}    @{PARAMS_FOR_9059}    @{DU2_CELL}    @{BWP_PROFILE}    @{BWP_DU}
...    @{PCMD_flag_Enable}    @{TCE_vDU2}    @{PCMD_DU2_Enable}    @{CellTrace_enable}    @{rrcReestab}

@{xn_setup}
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true

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

#sim gnb3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=3
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=1
...    NRCELL-1/NRREL-4:removeNotAllowed=false

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

@{NRADJNRCELL}
#sim gnb3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:gNbId=3
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=280
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

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

# Check point
@{5QI6_a1}
...    pcid:50, scellIdx:0
...    Setup QosFlow with QFI:1 fiveQI:6
...    rrcReconfigurationComplete

@{5QI7}
...    Setup QosFlow with QFI:1 fiveQI:7
...    QoS Routing Table

@{TCE_vCU}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=192.168.100.126
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49152
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1

@{TCE_vDU1}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=192.168.255.126
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49100

@{TCE_vDU2}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=192.168.255.126
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49151

@{PCMD_flag_Enable}
...    NRBTS:actPCMDReport=true

@{CellTrace_enable}
...    NRBTS:actCellTraceReport=true

@{NRMTRACECU}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=false
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceE1Setting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceF1Setting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:tracePCMDSetting=all

@{PCMD_DU1_Enable}
...    NRBTS/NRDU-1/NRCTRLTSDU-1
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:actPCMDReporting=true
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:jobType=TraceOnly
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrTceIdentifier=1
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:scope=allResources
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:traceId=1
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:tracePCMDSetting=all

@{PCMD_DU2_Enable}
...    NRBTS/NRDU-2/NRCTRLTSDU-1
...    NRBTS/NRDU-2/NRCTRLTSDU-1/NRMTRACEDU-1:actPCMDReporting=true
...    NRBTS/NRDU-2/NRCTRLTSDU-1/NRMTRACEDU-1:jobType=TraceOnly
...    NRBTS/NRDU-2/NRCTRLTSDU-1/NRMTRACEDU-1:nrTceIdentifier=1
...    NRBTS/NRDU-2/NRCTRLTSDU-1/NRMTRACEDU-1:scope=allResources
...    NRBTS/NRDU-2/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRDU-2/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRDU-2/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRDU-2/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:traceId=1
...    NRBTS/NRDU-2/NRCTRLTSDU-1/NRMTRACEDU-1:tracePCMDSetting=all

@{rrcReestab}
...    NRBTS:rrcReestabTypeSA=sameGNB

${carrierfreq}    636576
${DU_BEARER_RECORD_F}    nsetapx.DuVendorExtensionRecordDataType == 13

*** Test Cases ***
CB009485-ET_TC02_B2_Verify_sucessful_SA_gNB-DU_bearer_trace_record_for_partial_sucessful_PDU_session_release_and_interGNB_SA_HO_on_cloud
    [Documentation]
    ...    To verify the senario that multi pdu session to delete partial pdu session, and interGNB HO on the cloud GNB.
    ...    And then check the DU bearer trace record of TCE.
    [Tags]    QC_183800
    Start To Capture UTE eth1 Wireshark Aic 1    eth1_trace
    Successful PDU session Resource Release for not all PDU sessions
    Monitoring PCMD content for DU Bearer Trace Record 1
    Start To Capture UTE eth1 Wireshark Aic 2    eth1_trace
    Successful Inter-gNB HO Xn based
    Monitoring PCMD content for DU Bearer Trace Record 2
    Release UEs    ue_type=all

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
    #sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.11 gnb_id=0x3:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.11 nssai=0x1:0xd143a5 amf=1 plmnList=311:489
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb3}
    Update Cfg Aic    ${set_gnb3_cell1}
    Update Cfg Aic    gnb_make_plmnset plmn_set_id=1 dual_conn=off gnb=3 cell=1 tac=280 plmn_id_list=311:489
    Update Cfg Aic    gnb_set_nwslice_per_plmn gnb=3 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x01:0xd143a5
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=on send_xn_setup=false

Successful PDU session Resource Release for not all PDU sessions
    UE Register and PDU1 Setup with 1 Qosflow and PDU2 Setup with 2 Qosflow
    PDU1 release
    PDU1 setup
    Release Ues    ue_id=1

Successful Inter-gNB HO Xn based
    Setup Xn Link To gNB
    Check XN Link is up
    set UE history info
    SA UE register and PDU setup    ue_id=1
    inter-gnb inter-DU intra-plmn HO From real-gNB to sim-gNB3
    UE Tigger Inter-gnb HO From SimGNB to RealGNB    phycell_id=50

Monitoring PCMD content for DU Bearer Trace Record 1
    _Stop Capture UTE Wireshark Aic
    ${bearerrecord}    create list
    ...                bearerRecord/data-r2/trigger=ctxSetup,ctxModification,ctxModification,ctxModification
    ...                setupBearers/DuBearerDataSetupItem/drb-Id=4,5,6
    ...                releasedBearers/DuBearerReleaseItem/drb-Id=4
    ...                setupBearers/DuBearerDataSetupItem/qosInformation=nr-Qos,nr-Qos,nr-Qos

    download and check wireshark fields
    ...                                    tag=ute_wireshark_eth1_releasePDUsession
    ...                                    filter=${DU_BEARER_RECORD_F}
    ...                                    check_fields=${bearerrecord}

Monitoring PCMD content for DU Bearer Trace Record 2
    _Stop Capture UTE Wireshark Aic
    ${bearerrecord}    create list
    ...                bearerRecord/data-r2/trigger=ctxSetup,ctxSetup
    ...                bearerRecord/data-r2/setupBearers=1 item,1 item
    ...                bearerRecord/data-r2/setupBearers/DuBearerDataSetupItem/drb-Id=4,4
    ...                bearerRecord/drbLevelQos/nonDynamicFiveQiDescriptor/fiveQi=6,6
    ...                bearerRecord/drbLevelQos/arp/priorityLevel=15,15
    ...                bearerRecord/drbLevelQos/arp/preemptionCapability=shallNotTriggerPreemption,shallNotTriggerPreemption
    ...                bearerRecord/drbLevelQos/arp/preemptionVulnerability=preemptable,preemptable
    ...                bearerRecord/drbLevelQos/pduSessionId=1,1
    ...                bearerRecord/snssai/sst=01,01
    ...                bearerRecord/snssai/sd=d143a5,d143a5
    ...                bearerRecord/qosFlowsMappedToBearer=1 item,1 item
    ...                bearerRecord/DuQosFlowMappedToBearerItem/qfi=1,1
    ...                bearerRecord/DuQosFlowMappedToBearerItem/fiveQi=6,6
    ...                bearerRecord/DuQosFlowMappedToBearerItem/arp/priorityLevel=15,15
    ...                bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionCapability=shallNotTriggerPreemption,shallNotTriggerPreemption
    ...                bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionVulnerability=preemptable,preemptable
    ...                bearerRecord/DuQosFlowMappedToBearerItem/pduSessionId=1,1

    download and check wireshark fields
    ...                                    tag=ute_wireshark_eth1_HO
    ...                                    filter=${DU_BEARER_RECORD_F}
    ...                                    check_fields=${bearerrecord}

Setup Xn Link To gNB
    [Arguments]    ${gnb_id}=3
    execute egate command    gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    execute egate command    gnb_xn_link_up gnb=${gnb_id} target=2    GNB-${gnb_id}: XnAP Link with GNB-2 .* is up

Check XN Link is up
    object should exist in cu    XNLINK-1:xnLinkStatus=available

Set UE history info
    [Arguments]    ${ue_id}=1
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

UE Tigger Inter-gnb HO From SimGNB to RealGNB
    [Arguments]    ${phycell_id}    ${ue_id}=1
    Start To Capture Logs Aic    Sim-gNB3_To_real-gnb_cell1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V_4}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id}
    ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=     Execute Egate Command
    ...    ${V_4}
    ...    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1
    [Teardown]    Stop To Capture Wireshark Log Vdu

Common Suite Setup And Setup Airphone Env Aic 2DU And Start TCE
    Common Suite Setup And Setup Airphone Env Aic 2DU
    Perform Steps After Onair

Perform Steps After Onair
    Start TCE    ${TCE_PORT}

SA UE register and PDU setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1    QoS Routing Table
    Send Throughput    ${ue_id}
    Verify Throughput    ${ue_id}

inter-gnb inter-DU intra-plmn HO From real-gNB to sim-gNB3
    Start To Capture Logs Aic    real-gNB_cell1_To_sim-gNB3
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=25 phycell_id=381 nrsrp_nr=85    Inter-eNB handover
    [Teardown]    Stop To Capture Wireshark Log Vdu

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

Send Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10    UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=10    UDP DL

Verify Throughput
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9.5
    Should Be True    ${dl_throuput}/1000>9.5

PDU1 release
    PDU Release    pdu=1

PDU1 setup
    #PDU1: qos1_qfi1_5QI6
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=${5QI6_a1}

PDU Release
    [Arguments]    ${ue_id}=1    ${pdu}=1
   Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=amf
  ...    N4 Session Release for PDU Session 1. All ongoing traffic will be stopped

Start To Capture UTE eth1 Wireshark Aic 1
  [Arguments]  ${tag}
  Return From Keyword If  ${UTE_WIRESHARK_FLAG} is not ${True} and 'startup' not in '${tag}'
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  sudo tcpdump -i eth1 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth1_releasePDUsession.pcap>& tmp_1.txt&

Start To Capture UTE eth1 Wireshark Aic 2
  [Arguments]  ${tag}
  Return From Keyword If  ${UTE_WIRESHARK_FLAG} is not ${True} and 'startup' not in '${tag}'
  ${log_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs  ${SAVE LOG DIRECTORY}
  Run Keyword And Ignore Error  Execute Cmd On Pc
  ...  sudo tcpdump -i eth1 -s0 -vvv -w ${log_dir}${/}ute_wireshark_eth1_HO.pcap>& tmp_1.txt&

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    BuiltIn.Log    Check Wireshark...    console=${True}
    ${wireshark_log_path}    Catenate    ${SAVE LOG DIRECTORY}${/}${tag}.pcap
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all
