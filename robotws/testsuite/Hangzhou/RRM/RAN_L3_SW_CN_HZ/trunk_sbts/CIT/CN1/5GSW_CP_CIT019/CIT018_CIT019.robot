*** Settings ***
Documentation    Suite documentation
...    author:  keyun.ma@nokia-sbell.com
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-dandan.chen    release-SBTS24R2    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB_BIP_FLAG}    True
${GNB_BIP_SIZE}    2000
${TTITRACE_FLAG}    True
${DEBUG_LOG_LEVEL}    4
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
${dci0010}    dciFormat=formats0-0-And-1-0
${dci0111}    dciFormat=formats0-1-And-1-1
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_NRRELs}
...    @{PARAMS_FOR_DRX}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_Frame_Structure}
...    @{GNB_A1sCellAdd_for_NRCELL}
...    @{GNB_A2sCellRel_for_NRCELL}
...    @{GNB_A2pCellChange_for_NRCELL_1}
...    @{Enable_CB007552}
...    @{Enable_Cell1_CB008541_5GC000937}
...    NRSCTP-1:sctpProfile:sctpRtoInit=6000
...    NRSCTP-1:sctpProfile:sctpRtoMin=1000
...    NRCELL-1:actPucchAdditionalDmrs=false
...    NRCELL-13:type0CoresetConfigurationIndex=1
...    NRCELL-14:type0CoresetConfigurationIndex=0
...    NRCELL-13:gscnOrSsPbchArfcn=5332
${CaSup}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl

@{PARAMS_FOR_CA}
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRBTS/NRSYSINFO_PROFILE-1:systemInformationTargetRate=157
...    NRBTS/NRSYSINFO_PROFILE-2:systemInformationTargetRate=157
...    NRDU-1:fr1UlCaPreferred=ulCaPreferred
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:maxNumScellsDl=7
...    NRBTS:maxNumScellsUl=7
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=${CaSup}
...    MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:maxNumScellsDlFr1=4
...    @{PARAMS_For_B007}
...    NRCELL-11:gscnOrSsPbchArfcn=5288
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-13:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-14:periodicCsiAcquisition:csiReportPeriodicity=slots80


@{PARAMS_For_B007}
...    NRCELL-1:actEnhancedPDSCHSchSplSlot=true
...    NRCELL-2:actEnhancedPDSCHSchSplSlot=true
...    NRCELL-1:actAdaptiveReTxResMcs=true
...    NRCELL-2:actAdaptiveReTxResMcs=true
...    NRCELL:bufferThesholdSCellDePrioritize=500000
...    NRCELL:actAdaptiveReTxResMcs=true
...    NRCELL:minPctResourceReservedMcsDl=50
...    NRCELL:targetPctResourceReservedMcsDl=75
...    NRCELL:minPctResourceReservedMcsUl=50
...    NRCELL:targetPctResourceReservedMcsUl=75
...    NRCELL:timingAdvanceOffset=n25600

@{PARAMS_FOR_NRRELs}
...    @{NRREL_for_NRCELL_1}
...    @{NRREL_for_NRCELL_11}
...    NRCELL/NRREL:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL:gNbId=1
...    NRCELL/NRREL:gNbIdLength=22
...    NRCELL/NRREL:handoverAllowedSA=allowed
...    NRCELL/NRREL:removeNotAllowed=false
...    NRCELL/NRREL:gnbPlmn:mcc=311
...    NRCELL/NRREL:gnbPlmn:mnc=489
...    NRCELL/NRREL:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL:sCellAdditionMethod=blind
...    NRCELL/NRREL:sCellOperationalMode=dlOnly

@{NRREL_for_NRCELL_1}
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly

...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly

...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly

...    NRCELL-1/NRREL-13:lcrId=13
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-13:gNbId=1
...    NRCELL-1/NRREL-13:gNbIdLength=22
...    NRCELL-1/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-13:removeNotAllowed=false
...    NRCELL-1/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlOnly

@{NRREL_for_NRCELL_11}
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly

...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly

...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=1
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly

...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=1
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly

@{PARAMS_FOR_OTHERS}
...    NRBTS:actExtN77Support=false


...    NRBTS:actRanSharing=false
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:numNonGbrRlcSduDiscard=5
...    NRBTS:numNonGbrPdcpSduDiscard=5
...    NRBTS:pdcpBufUsageThreshold=95
...    NRBTS:rlcBufUsageThreshold=95
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot15
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    NRCELL-2:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-2:pucchF3MaxCodeRate=zeroDot15
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1

@{PARAMS_FOR_Frame_Structure}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4

@{PARAMS_FOR_DRX}
...    NRCELL:actCDrx=true
#...    NRCELL:drxProfile1:drxInactivityTimer=80ms
#...    NRCELL:drxProfile1:drxLongCycle=160ms
#...    NRCELL:drxProfile1:drxOnDurationTimer=5ms
#...    NRCELL:drxProfile1:drxRetransTimerDl=0slot
#...    NRCELL:drxProfile1:drxRetransTimerUl=0slot

@{GNB_A1sCellAdd_for_NRCELL}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms

@{GNB_A2sCellRel_for_NRCELL}
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=5120ms|a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=35|a2TimeToTriggerSCellRelSsbRsrq=5120ms|a2HysteresisSCellRelSsbRsrq=0

@{GNB_A2pCellChange_for_NRCELL_1}
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    @{PARAMS_FOR_NRHOIF}
...    @{PARAMS_FOR_MeasHO_A1A2}
...    @{PARAMS_FOR_MeasHO_A3A5}

@{PARAMS_FOR_NRHOIF}
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ssbFrequency=127450
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:ssbFrequency=423130
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64

@{PARAMS_FOR_MeasHO_A1A2}
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=10
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64

@{PARAMS_FOR_MeasHO_A3A5}
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64

@{PARAMS_FOR_8311_FOR_B007}
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=20
...    NRCELL-1:actPucchAdditionalDmrs=true
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlAndUl
...    NRDU-1:dlToUlContributionRatio=90

@{Restore_params_For_B007}
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:dlSCellConfigLevel=20
...    NRCELL:dlSCellConfigLevelNum=10
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actSCellReleaseForInactiveSCell=disabled
...    @{online_dlToUlRatio_larger}
...    NRCELL-1:actPucchAdditionalDmrs=false
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot15
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRDU-1:dlToUlContributionRatio=101

@{Enable_Cell1_CB008541_5GC000937}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRCELL-11:msg1FrequencyStart=18
...    NRCELL-12:msg1FrequencyStart=18
...    NRCELL-13:msg1FrequencyStart=18
...    NRCELL-14:msg1FrequencyStart=18
...    NRCELL-1:fPdcchMonOccsnPo=2
...    NRCELL-2:fPdcchMonOccsnPo=2
...    NRCELL-11:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-11:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-11:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-56

@{Enable_CB007552}
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=n52
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-56:bwpType=dedicated
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbSizeDl=n52
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
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n4|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=19|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|${dci0010}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=20|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|${dci0111}
...    NRBTS/BWP_PROFILE-56/PDSCH-1:pdschRat0RbgConfig=config1

@{online_dlToUlRatio_smaller}
...    NRDU-1:dlToUlContributionRatio=30

@{online_dlToUlRatio_larger}
...    NRDU-1:dlToUlContributionRatio=90

&{scell_ssbfreq_dict_for_B007}    1=635616    4=427970

#5CC BC added
${SA_Capa_Support_CA_N66_N66_N72_N77_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748360185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF806400000C000002E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C000000
...    0000000000007FFFE027FFC00001FFF0000017000038020F0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0
...    AC3C28000E208000010B02B0F13000388C0000042C0AC5C46000E208007130000028581587850001C4C00000C160562E26000710400385000
...    00102C0AC5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000
...    082C0AC5C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C41000E208007118003898001C4C
...    00000E1617007011A014404C80822EC019610851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C281036
...    39F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF81220408
...    10206CB5E183220318C6318C6318C6318C60056080000000000000000000000000010000800300003D05C0078005038280381804A00E000C0
...    480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000380200100
...    00000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08
...    AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA4808
...    0004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526
...    AAA0F142C02F012A05028140A05028140A05028140A05028140A0502800384040300601002004202004010080600C20100200404030060100
...    C018202018030080600C201002004040300601002004402018030080600C020180304040080201002008802018030080600C0201803008010
...    0202004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

#scell-2 NRCELL-11 UL only support 10MHZ, so when UL CA made, small BWP choosed
${SA_Capa_Support_CA_n66_UL_support10Mhz}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748360185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF806400000C000002E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C000000
...    0000000000007FFFE027FFC00001FFF0000017000038020F0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0
...    AC3C28000E208000010B02B0F13000388C0000042C0AC5C46000E208007130000028581587850001C4C00000C160562E26000710400385000
...    00102C0AC5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000
...    082C0AC5C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C41000E208007118003898001C4C
...    00000E1617007011A014404C80822EC019610851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C281036
...    39F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF81220408
...    10206CB5E183220318C6318C6318C6318C60056080000000000000000000000000010000800300003D05C0078005038280381804A00E000C0
...    480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000380200100
...    00000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08
...    AC1DA0682000012CA48080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA4808
...    0004CB29202000152CA48080005CB29282000192CA480800018B292019A55174AAAA9545D2A8AA03154162A83455298AA4D154062A8145526
...    AAA0F142C02F012A05028140A05028140A05028140A05028140A0502800384040300601002004202004010080600C20100200404030050100
...    C014202018030080600C201002004040300601002004402018030080600C020180304040080201002008802018028080600A0201803008010
...    0202004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${GNB_SCELL_4_ADMI_REQ_SA}    M55138C00048
${GNB_SCELL_4_ADMI_SUCC_SA}    M55138C00049
${UE_PCELL_4_CONF_SCELL_DL_SA}    M55118C02016
${UE_SCELL_4_CONF_SCELL_DL_SA}    M55118C07510
${GNB_DU_SCELL_4_ADMI_REQ_SA}    M55139C00023
${GNB_DU_SCELL_4_ADMI_SUCC_SA}    M55139C00024
${RRC_RECONF_ADD4DLSCELL_ATT_SA}    M55118C02015
${RRC_RECONF_ADD4DLSCELL_SUCC_SA}    M55118C02014
${UE_PCELL_3_CONF_SCELL_DL_SA}    M55118C09501
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002

@{PM_Counters_Check_B005}
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-12:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-13:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=1
...    NRCELL-11:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-11:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-11:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-11:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-11:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=1
...    NRCELL-11:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=1

@{2T3F_expect_regexp_B005}
...    pcid:51, scellIdx:1
...    pcid:60, scellIdx:2
...    pcid:61, scellIdx:3
...    pcid:62, scellIdx:4
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{3F2T_expect_regexp_B005}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:62, scellIdx:3
...    pcid:63, scellIdx:4
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

*** Test Cases ***
5GSW_CP_CIT018_CIT019_Verify_Classical_NSA_TDDFDD_cmWave_interFreq_HO_with_A5_RSRP_CFRA_is_successful
    [Documentation]    1. The purpose of this test case is to
    ...    Verify inter-GNB inter-Freq handover with A5 RSRP without SRB3, and
    ...    verify intra-GNB inter-Freq handover with A5 RSRP with SRB3 enabled.
    ...    2. Precondition:
    ...    NRBTS:srb3SupportEnabled=false
    ...    simulate gnb4 cell-4: TDD pci=384, band261, ssbFrequency=2071387, nrarfcn=2071591
    ...    real gnb2 cell-1: TDD pci=50, band78, sbFrequency=636576, nrarfcn=636666
    ...    real gnb2 cell-11: FDD pci=60, band66, ssbFrequency=424090, nr_arfcn=344000:424000
    ...    real gnb2 cell-12: FDD pci=61, band71, ssbFrequency=126750, nr_arfcn=136100:126900
    ...    real gnb2 cell-14: FDD pci=63, band71, ssbFrequency=126750, nr_arfcn=136100:126900
    ...    3. Test Step:
    ...    a. UE92 setup ENDC with cell2-1
    ...    b. UE92 interGnb interFreq HO from cell2-1 to cell4-4
    ...    c. UE92 interGnb interFreq HO back to cell2-1
    ...    d. delta commission to configure NRBTS:srb3SupportEnabled=true
    ...    e. UE91 setup ENDC with cell2-11
    ...    f. UE91 intraGnb interFreq HO from cell2-11 to cell2-12
    ...    g. UE91 intraGnb interFreq HO back to cell2-11
	[Tags]  QC_47240    CIT019    CIT018
    Clear Counter Files    ${False}
    Normal Scell addition    ue_id=1    pcell_id=1    carrierfreq=632736    rsrp=85
    Trigger Pcell Change to Cell_11    rsrp=70    ue_id=1    carrierfreq=632736    threshold=RSRP 70    timetotrigger=480 ms
    Stop Traffic And Release UEs    1
   # Check Wireshark Log    ${CURDIR}${/}A2A_B005${/}a2a.ini    wait_string=UEContextRelease::10
    Check Counters    ${PM_Counters_Check_B005}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    fddtdd_sansa_cmwv/6cells_2T4F_2N77_2N71_2N66

test teardown for B007
    delta commission parameters    ${Restore_params_For_B007}
    common test teardown and stop capture logs

Set UE Capability
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${UE_Capabilities}=${SA_Capa_perUE_Full}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

Lock and unlock cell
    [Arguments]    ${Nrcell_indext}
    Lock Cell${Nrcell_indext}
    Unlock Cell${Nrcell_indext}
    Cells Should Be Onair    ${Nrcell_indext}

Normal Scell addition
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${carrierfreq}=632736    ${rsrp}=85
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${SA_Capa_Support_CA_N66_N66_N72_N77_N77}
    Sa Ue Attach    ue_id=${ue_id}    enb_id=2    cell_id=${pcell_id}
    Setup pdu1 session    ue_id=${ue_id}    gateway=1    pdu_id=1    fail_regexp=maxPayloadSize
    trigger A1 MR to add scell    rsrp=${rsrp}    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    Send large traffic and Verify Throuput    ue_id=${ue_id}    Tput_dl=800    Tput_ul=10

BufferBased Scell addition and release
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${carrierfreq}=632736    ${rsrp}=85
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${SA_Capa_Support_CA_n66_UL_support10Mhz}
    Sa Ue Attach    ue_id=${ue_id}    enb_id=2    cell_id=${pcell_id}
    Setup pdu1 session    ue_id=${ue_id}    gateway=1    pdu_id=1
    trigger A1 MR for buffermonitoring    rsrp=${rsrp}    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    Send large traffic and Verify Throuput    ue_id=${ue_id}    Tput_dl=800    Tput_ul=10
    Check UL_without_CA Throughput    ue_id=${ue_id}    Tput_ul=10
    Decrease Traffic and Check SCells    ue_id=${ue_id}    pdu_id=1    trf_range=7

BufferBased Scell addition UL CA expected and mixed release
    [Arguments]    ${ue_id}=1    ${carrierfreq}=632736    ${rsrp}=85
    trigger A1 MR for buffermonitoring    rsrp=${rsrp}    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    Send large traffic and Verify Throuput    ue_id=${ue_id}    Tput_dl=800    Tput_ul=10
    Check ULCA Throughput    ue_id=${ue_id}    Tput_ul=10
    trigger A2 MR for stepwised scellrelease    rsrp=40    ue_id=${ue_id}    pass_regexp=sCellToReleaseList
    Decrease Traffic and Check SCells    ue_id=${ue_id}    pdu_id=1    trf_range=7
    trigger A1 MR for buffermonitoring    rsrp=${rsrp}    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    Send large traffic and Verify Throuput    ue_id=${ue_id}    Tput_dl=800    Tput_ul=10
    Check ULCA Throughput    ue_id=${ue_id}    Tput_ul=10
    Stop Traffic And Release UEs    1

BufferBased Scell addition UL CA expected and release
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${carrierfreq}=632736    ${rsrp}=85
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${SA_Capa_Support_CA_n66_UL_support10Mhz}
    Sa Ue Attach    ue_id=${ue_id}    enb_id=2    cell_id=${pcell_id}
    Setup pdu1 session    ue_id=${ue_id}    gateway=1    pdu_id=1
    trigger A1 MR for buffermonitoring    rsrp=${rsrp}    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    Send large traffic and Verify Throuput    ue_id=${ue_id}    Tput_dl=800    Tput_ul=10
    Check ULCA Throughput    ue_id=${ue_id}    UL_cellindex=2    Tput_ul=10
    Decrease Traffic and Check SCells    ue_id=${ue_id}    pdu_id=1    trf_range=7
    Stop Traffic And Release UEs    2

Check ULCA Throughput
    [Arguments]    ${ue_id}=81    ${Tput_ul}=45    ${sleep_time}=15s    ${UL_cellindex}=2
    sleep    ${sleep_time}    sleep for Tput stable
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    pass_regexp=Average
    ${allul_tput}    set variable    0
    ${cellindex0_tput}    UL Scell Throughput Check    ${ue_id}    0
    ${cellindex2_tput}    UL Scell Throughput Check    ${ue_id}    ${UL_cellindex}
    ${allul_tput}    Evaluate    ${cellindex0_tput}+${cellindex2_tput}
    Should Be True    ${allul_tput}/1000 > ${Tput_ul}

Check UL_without_CA Throughput
    [Arguments]    ${ue_id}=81    ${Tput_ul}=45    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    pass_regexp=Average
    ${allul_tput}    set variable    0
    ${cellindex0_tput}    UL Scell Throughput Check    ${ue_id}    0
    Should Be True    ${cellindex0_tput}/1000 > ${Tput_ul}

UL Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pusch    rate_type=ave
    #Should Be True    ${scell_tput}/1000 > 0

Throughput Check
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=990    ${Tput_ul}=9    ${sleep_time}=15s    ${CC_num}=5
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${alldl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
	END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
#    Should Be True    ${scell_tput}/1000 > 0

Stop Traffic And Release UEs
    [Arguments]    @{args}
    FOR    ${UE}    IN    @{args}
        Stop Traffic and Release PDU    ue_id=${UE}    pdu_id=1
	END
    Release UEs    ue_type=all

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=80    ${ue_id}=1    ${carrierfreq}=368430
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=${2T3F_expect_regexp_B005}

trigger A1 MR for buffermonitoring
    [Arguments]    ${rsrp}=80    ${ue_id}=1    ${carrierfreq}=368430
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    fail_regexp=sCellIndex 4

trigger A2 MR for stepwised scellrelease
    [Arguments]    ${rsrp}=40    ${ue_id}=1    ${pass_regexp}=sCellToReleaseList
    ${kv}=    Get Dictionary Items    ${scell_ssbfreq_dict_for_B007}
    FOR    ${scell_index}    ${ssb_freq}    IN    @{kv}
        ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${ssb_freq}    event_type=A2
        ${mr_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrq_nr=11 srsrp_nr=${rsrp}
         ...    scell=${scell_index} scell_rsrp=60 scell_rsrq=30
        ${ret1}=    Execute Egate Command    ${mr_cmd}    pass_regexp=${pass_regexp}
        ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
        Should Contain    ${ret1}    sCellToReleaseList{${scell_index}}
    END

Trigger Pcell Change to Cell_11
    [Arguments]    ${rsrp}=80    ${ue_id}=1    ${carrierfreq}=368430    ${threshold}=RSRP 70    ${timetotrigger}=480 ms
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ...    threshold=${threshold}    timetotrigger=${timetotrigger}
    ${mr_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrq_nr=11 srsrp_nr=${rsrp}
    ...    scell=2 scell_rsrp=86 scell_rsrq=38 scell=3 scell_rsrp=83 scell_rsrq=25
    ${ret1}=    Execute Egate Command    ${mr_cmd}    pass_regexp=${3F2T_expect_regexp_B005}
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.11 performed
    Throughput Check    ue_id=${ue_id}    Tput_dl=540    Tput_ul=10

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=2     ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu1 session
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${pdu_id}=1    ${fail_regexp}=sCellIndex 1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gateway}
    ...    pass_regexp=Established PDU
    Should not Contain    ${ret1}    ${fail_regexp}

Send large traffic and Verify Throuput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=585    ${Tput_ul}=40
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=28 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}

Stop Traffic and Release PDU
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id}    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}    Successfully released PDU Session

Decrease Traffic and Check SCells
    [Arguments]    ${ue_id}=2    ${pdu_id}=1    ${trf_range}=2
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=ul    Stopping Uplink
    FOR    ${I}    IN RANGE    2    ${trf_range}
        Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=${I}    Traffic was stopped
        Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
        sleep    20s    put time to wait scell inactive release
        Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    END
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pusch    pass_regexp=CellIndex
    Check no scell is added    ue_id=${ue_id}

Check no scell is added
    [Arguments]    ${ue_id}=2
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    Should Not Contain    ${ret0}    CellIndex-1
    Should Not Contain    ${ret0}    CellIndex-2
    Should Not Contain    ${ret0}    CellIndex-3
    Should Not Contain    ${ret0}    CellIndex-4
    ${ret1}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    pass_regexp=Average
    Should Not Contain    ${ret1}    CellIndex-2