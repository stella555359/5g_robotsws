*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET    owner-jolin.fan    release-SBTS24R2    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    4
@{PARAMS_IN_SCF}
...    @{tddFrameStructure_configuration}
...    @{CA_basic_config}
...    @{UL_SRS_Configuratin}
...    @{Case_B009_configuration}
...    TNL-1/ETHSVC-1/ETHLK-1:l2IngressRate=10000000
...    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1:l2ShaperRate=10000000
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:actPucchAdditionalDmrs=false
...    NRCELL-1:type0SearchSpaceConfigurationIndex=5
...    NRCELL-2:type0SearchSpaceConfigurationIndex=5
...    NRCELL-3:type0SearchSpaceConfigurationIndex=5
...    NRCELL-1:actBeamforming=true
...    NRCELL-2:actBeamforming=true
...    NRCELL-3:actBeamforming=true
...    delete:NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL-1:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-1:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL-2:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-2:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL-3:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-3:periodicCsiAcquisition:csirsPower
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:prachConfigurationIndex=97
...    NRCELL-2:prachConfigurationIndex=97
...    NRCELL-3:chBw=80MHz
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-3:msg1FrequencyStart=20
...    NRCELL-14:msg1FrequencyStart=12
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    @{PR_Config}

@{PR_Config}
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-1:nrCellType=8DL4UL
...    @{add_2RX2TX_2_tdd_cells_gnb1_LCELNR}

@{add_2RX2TX_2_tdd_cells_gnb1_LCELNR}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1

@{tddFrameStructure_configuration}
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4

@{CA_basic_config}
...    NRCELL:actEnhancedPDSCHSchSplSlot=false
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeashoEnabled=none
...    NRCELL-1:a2MeashoEnabled=none
...    NRCELL-1:actDlSrsBm=false
...    NRCELL-1:actEnhancedPDSCHSchSplSlot=false
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
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
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-13:gNbId=1
...    NRCELL-1/NRREL-13:gNbIdLength=22
...    NRCELL-1/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-13:lcrId=13
...    NRCELL-1/NRREL-13:nrDcAllowed=false
...    NRCELL-1/NRREL-13:removeNotAllowed=false
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-13:gnbPlmn:mncLength=3

@{UL_SRS_Configuratin}
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-1:srsForBeamMgmt:bSRS=3
...    NRCELL-1:srsForBeamMgmt:cSRS=12
...    NRCELL-1:srsForBeamMgmt:comb=comb2
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForUlBm=-120
...    NRCELL-1:beamSet:lowerEdgeAngle=120
...    NRCELL-1:beamSet:upperEdgeAngle=60

@{Case_B009_configuration}
...    NRCELL:actCDrx=true
...    NRCELL:actAperCsi=false
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-6:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRCELL-3:beamSet:basicBeamSet=beamSet_4
...    NRCELL-1:srPeriodicity=slots20
...    NRCELL-2:srPeriodicity=slots20
...    NRCELL-3:srPeriodicity=slots20
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:absThreshSsbRsrpConsolidation=0
...    NRCELL-1:sMeasConfigSsbRsrp=0
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=3
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a1BasedPCellSwitchEnabled=false
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a2BasedPCellSwitchEnabled=false
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=14
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a4MeasEnDcSteeringEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a4MeasNrDcEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:deriveSsbIndexFromCell=true
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:freqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:ssbFrequency=632736
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:a3MeasEnabled=rsrp
...    NRCELL-3:absThreshSsbRsrpConsolidation=0
...    NRCELL-3:measGapSelectionSA=favourUeThroughput
...    NRCELL-3:sMeasConfigSsbRsrp=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a4MeasNrDcEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:deriveSsbIndexFromCell=true
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:freqBandIndicatorNR=41
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf4
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:ssbFrequency=504990
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    MRBTS-1/NRBTS-1/NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:nrDcAllowed=false
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3

@{4Scells_expect}
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    SCellIndex 3 activated successfully
...    SCellIndex 4 activated successfully
...    pcid:50, scellIdx:0
...    pcid:51, scellIdx:1
...    pcid:52, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:62, scellIdx:4

@{HOtoCell3_exp}
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed
...    PhysCellId: 51] SCellIndex 1 activated successfully at airphone
...    rrcReconfigurationComplete:::6

@{HOtoCell1_exp}
...    Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.1 performed
...    rrcReconfigurationComplete:::4


@{PM_Counters_Check}
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=4
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=4
...    NRCELL-1:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-13:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=4
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=4
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=4
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=4
...    NRCELL-3:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_SCELL_1_CONF_SCELL_DL_SA}>0

${GNB_SCELL_4_ADMI_REQ_SA}    M55138C00048
#GNB_SCELL_4_ADMI_REQ_SA    This counter describes the number of radio admission requests for exactly 4 SCells before the
#CA configuration on RRC.
${GNB_SCELL_4_ADMI_SUCC_SA}    M55138C00049
#GNB_SCELL_4_ADMI_SUCC_SA    This counter describes the number of successful radio admission requests for exactly 4 SCells
#before the CA configuration on RRC
${UE_PCELL_4_CONF_SCELL_DL_SA}    M55118C02016
#UE_PCELL_4_CONF_SCELL_DL_SA    The total number of CA UEs in the current cell configured as a PCell that have exactly 4
#configured SCells in DL in SA mode
${UE_SCELL_4_CONF_SCELL_DL_SA}    M55118C07510
#UE_SCELL_4_CONF_SCELL_DL_SA    The sum of samples for the total number of CA UEs in the current cell configured as an
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
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
# The current number of PCell UEs with 1 configured SCell in DL is calculated when the sample timer expires.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
# The current number of SCell UEs with 1 configured SCell in DL is calculated when the sample timer expires.

*** Test Cases ***
CB009855-ET-B009_Activation_3T2F_CA_IWK_SRS_based_beamforming_actUlSrsBm_enable_interfreq_intradu_a3_HO_and_back
    [Documentation]
    ...    1. The purpose of this test case is interworking with SRS based beamforming and interworking with interfreq intradu handover.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                   Cell-1    Cell-2    Cell-3    Cell-11    Cell-12    Cell-13    cell-14
    ...    Technology       TDD      TDD      TDD        FDD         FDD        FDD       FDD
    ...          Band       n41      n41      n77        n71         n71        n66        n66
    ...     Bandwidth        60      60       80         10          10         10         20
    ...            BF        Yes     Yes      Yes         No          No         No       No
    ...    Beam Refinement    No       No      No         No          No         No       No
    ...    beamset            4        4       4         1            1          1         1
    ...    ssbfreq        504990     531870   632736    127450     127450     424090    427970
    ...    weightForSCellSelection    all cells are 50
    ...    CELL tddFrameStructure    see @{tddFrameStructure_configuration}
    ...    3. Test Case Steps:
    ...         a. attach UE81 UE82 to cell1. trigger A1MR to add scells
    ...         b. start traffic for UE, all SCells are activated at the same time when the buffer condition for SCell activation is fulfilled.
    ...         c. UEs send A2 A3 MR to trigger interFreq HO to cell3 one by one.
    ...         d. UEs send A2 A3 MR to trigger interFreq HO back to cell1 one by one.
    ...         e. UEs send A1 MR to trigger scell addition, and start traffic to active scells.
    ...         f. Release UEs
    ...    4. Expected Results:
    ...         a. UE81 and UE82 is configured with 3T + 2F 5CC CA(Pcell--cell1+Scell-cell2,cell3,cell11,cell13).
    ...         b. 4 scells are activated, traffic is ok.
    ...         c. UE81 and UE82 HO to cell3 and blind scell cell2 added successfully.
    ...         d. UE81 and UE82 HO to cell1.
    ...         e. UE81 and UE82 is configured with 3T + 2F 5CC CA again, all scells are activated, traffic is ok.
    ...         f. UEs Release.
    [Tags]    B009    QC_47160    CA_LABLE-TTTFF(60MHz_TDD_n41+60MHz_TDD_n41+80MHz_TDD_n77+20MHz_FDD_n66+10MHz_FDD_n71)
    UEs register and covBasedA1 5CC CA successful
    UEs InterFreq HO to target cell3 and blind 2CC CA setup successful
    UEs InterFreq HO back to cell1 and 5CC CA setup successful
    Release UEs    ue_type=all
   # Check WireShark Log And Counter

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    fddtdd_sansa_cmwv/7cells_3T4F_8pipes

UEs register and covBasedA1 5CC CA successful
    Ue register and pdu session setup    ue_id=81    cell_id=1
    Run Traffic    ue_id=81
    UE Send A1 Trigger Scell Activation And Verify Throughput    ue_id=81    cellfreq=504990    pass_reg_ca=${4Scells_expect}    CC_Num=5
    ...    tput_dl=540    tput_ul=9
    Ue register and pdu session setup    ue_id=82    cell_id=1
    Run Traffic    ue_id=82
    UE Send A1 Trigger Scell Activation And Verify Throughput    ue_id=82    cellfreq=504990    pass_reg_ca=${4Scells_expect}    CC_Num=5
    ...    tput_dl=540    tput_ul=9

UEs InterFreq HO to target cell3 and blind 2CC CA setup successful
    UE Send A2 A3 Trigger InterFreq HO to target    ue_id=81    a2cellfreq=504990    a3cellfreq=632736    target_pid=52    expreg_ho=${HOtoCell3_exp}
    Verify Throughput    ue_id=81    Tput_dl=540    Tput_ul=9    CC_num=2
    UE Send A2 A3 Trigger InterFreq HO to target    ue_id=82    a2cellfreq=504990    a3cellfreq=632736    target_pid=52    expreg_ho=${HOtoCell3_exp}
    Verify Throughput    ue_id=82    Tput_dl=540    Tput_ul=9    CC_num=2

UEs InterFreq HO back to cell1 and 5CC CA setup successful
    UE Send A2 A3 Trigger InterFreq HO to target    ue_id=81    a2cellfreq=632736    a3cellfreq=504990    target_pid=50    expreg_ho=${HOtoCell1_exp}
    UE Send A1 Trigger Scell Activation And Verify Throughput    ue_id=81    cellfreq=504990    pass_reg_ca=${4Scells_expect}    CC_Num=5
    ...    tput_dl=540    tput_ul=9
    UE Send A2 A3 Trigger InterFreq HO to target    ue_id=82    a2cellfreq=632736    a3cellfreq=504990    target_pid=50    expreg_ho=${HOtoCell1_exp}
    UE Send A1 Trigger Scell Activation And Verify Throughput    ue_id=82    cellfreq=504990    pass_reg_ca=${4Scells_expect}    CC_Num=5
    ...    tput_dl=540    tput_ul=9

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${cmd_regexp}=UE now in NG RM Registere
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=${cmd_pdu_regexp}

Run Traffic
    [Arguments]    ${ue_id}=81
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=125    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=125    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=125    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=125    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=100    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=7 mbps=10    UE ${ue_id}: UDP UL
    sleep    10s    sleep for Tput stable

UE Send A1 Trigger Scell Activation
    [Arguments]    ${ue_id}=1    ${cellfreq}=632736    ${pass_reg_ca}=activated
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}

UE Send A1 Trigger Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cellfreq}=632736    ${pass_reg_ca}=activated    ${CC_Num}=5    ${tput_dl}=500    ${tput_ul}=40
    UE Send A1 Trigger Scell Activation    ${ue_id}    ${cellfreq}    ${pass_reg_ca}
    Verify Throughput    ue_id=${ue_id}    Tput_dl=${tput_dl}    Tput_ul=${tput_ul}

Verify Throughput
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=150    ${Tput_ul}=120    ${sleep_time}=15s    ${CC_num}=5
    Check DL Throughput    ue_id=${ue_id}    Tput_dl=${Tput_dl}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    Throughput
    ${ul_throughput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Check DL Throughput
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=150    ${sleep_time}=15s    ${CC_num}=5
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    ${alldl_tput}    set variable    0
    FOR    ${scellid}    IN RANGE    0    ${CC_num}
        ${scellid}=    convert to string    ${scellid}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${scellid}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
	END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
#    Should Be True    ${scell_tput}/1000 > 0

UE Send A2 A3 Trigger InterFreq HO to target
    [Arguments]    ${ue_id}=1    ${a2cellfreq}=504990    ${a3cellfreq}=427970    ${target_pid}=63    ${expreg_ho}=rrcReconfigurationComplete
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${a2cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=rrcReconfigurationComplete
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${a3cellfreq}    event_type=A3
    ${result}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${target_pid} nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=${expreg_ho}
    Should Not Contain    ${result}    drx-Config release

Check WireShark Log And Counter
    Check Counters    ${PM_Counters_Check}
    Check WireShark Log    ${CURDIR}${/}A2A_B009${/}a2a.ini    wait_string=UEContextRelease::24

