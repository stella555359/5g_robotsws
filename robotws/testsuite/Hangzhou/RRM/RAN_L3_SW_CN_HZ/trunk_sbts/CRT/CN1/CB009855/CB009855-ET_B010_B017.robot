*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-dandan.chen    release-SBTS24R2    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    4
${SA_UE1_ID}    81
${CaSup}    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

@{PARAMS_IN_SCF}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    TNL-1/ETHSVC-1/ETHLK-1:l2IngressRate=10000000
...    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1:l2ShaperRate=10000000
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:actCDrx=false
...    NRCELL:actAperCsi=false
...    NRCELL-3:numberOfRxBeamforming=4Rx
...    NRCELL-3:nrCellType=8DL4UL
...    NRCELL-1:actIncreasedFdmUsersPerSlot=true
...    NRCELL-2:actIncreasedFdmUsersPerSlot=true
...    NRCELL-3:actIncreasedFdmUsersPerSlot=true
...    NRCELL-1:actPucchAdditionalDmrs=false
...    NRCELL-2:actPucchAdditionalDmrs=false
...    NRCELL-3:actPucchAdditionalDmrs=false
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-2:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-3:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-12:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-13:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-3:dftBeamDiffThresholdH=15
...    NRCELL-3:dftBeamDiffThresholdV=15
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CaSup}
...    NRCELL-1:actEnhancedPDSCHSchSplSlot=true
...    NRCELL-2:actEnhancedPDSCHSchSplSlot=true
...    NRCELL-3:actEnhancedPDSCHSchSplSlot=true
...    NRCELL-1:actAdaptiveReTxResMcs=true
...    NRCELL-2:actAdaptiveReTxResMcs=true
...    NRCELL-3:actAdaptiveReTxResMcs=true
...    NRCELL-1:minPctResourceReservedMcsDl=50
...    NRCELL-2:minPctResourceReservedMcsDl=50
...    NRCELL-3:minPctResourceReservedMcsDl=50
...    NRCELL-1:minPctResourceReservedMcsUl=50
...    NRCELL-2:minPctResourceReservedMcsUl=50
...    NRCELL-3:minPctResourceReservedMcsUl=50
...    NRCELL-1:targetPctResourceReservedMcsDl=75
...    NRCELL-2:targetPctResourceReservedMcsDl=75
...    NRCELL-3:targetPctResourceReservedMcsDl=75
...    NRCELL-1:targetPctResourceReservedMcsUl=75
...    NRCELL-2:targetPctResourceReservedMcsUl=75
...    NRCELL-3:targetPctResourceReservedMcsUl=75
...    NRCELL-1:type0SearchSpaceConfigurationIndex=5
...    NRCELL-2:type0SearchSpaceConfigurationIndex=5
...    NRCELL-3:type0SearchSpaceConfigurationIndex=5
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-6:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRCELL-3:beamSet:basicBeamSet=beamSet_4
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=4
...    @{B010_parameter_update}
...    @{tddFrameStructure_tdlte_semiStatic3vs7_semiStatic3vs7}
...    @{B017_parameter_update}
...    NRCELL-3:chBw=80MHz
...    NRCELL:timingAdvanceOffset=n25600
...    @{add_2RX2TX_2_tdd_cells_gnb1_LCELNR}

@{add_2RX2TX_2_tdd_cells_gnb1_LCELNR}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/PHYANT-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-5
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-6

@{B010_parameter_update}
...    NRCELL-1:actUlSrsBm=false
...    NRCELL-2:actUlSrsBm=false
...    NRCELL-3:actUlSrsBm=false
...    NRCELL-1:actDlSrsBm=false
...    NRCELL-2:actDlSrsBm=false
...    NRCELL-3:actDlSrsBm=true
...    NRCELL-1:actUeCsirsCoexistCellCsirs=false
...    NRCELL-2:actUeCsirsCoexistCellCsirs=false
...    NRCELL-3:actUeCsirsCoexistCellCsirs=false
...    NRCELL-3:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-3:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-3:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRCELL-3:srsForBeamMgmt:cSRS=12
...    NRCELL-3:srsForBeamMgmt:bSRS=3
...    NRCELL-3:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-3:beamSet:lowerEdgeAngle=120
...    NRCELL-3:beamSet:upperEdgeAngle=60
...    NRCELLGRP:ssBurstSetPeriod=20

@{B017_parameter_update}
...    NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=2
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=2
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

@{tddFrameStructure_tdlte_semiStatic3vs7_semiStatic3vs7}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-1:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-2:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-2:prachConfigurationIndex=98
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-3:prachConfigurationIndex=97

@{NRCELL_3_NRREL_covBasedA1}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
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
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
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
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-13:gNbId=1
...    NRCELL-3/NRREL-13:gNbIdLength=22
...    NRCELL-3/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-13:lcrId=13
...    NRCELL-3/NRREL-13:nrDcAllowed=false
...    NRCELL-3/NRREL-13:removeNotAllowed=false
...    NRCELL-3/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrq
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-13:a2MeasSCellRelEnabled=rsrq
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-13:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-13:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{sCellActivationMethod_bufferBased}
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL-3:sCellDeactivationTimerGNB=ms1280

@{sCellActivationMethod_blind}
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{online_modification_B010}
...    @{sCellActivationMethod_bufferBased}
...    @{NRCELL_3_NRREL_covBasedA1}
...    NRCELL-3:actCDrx=true
...    NRDRX-4:drxLongCycle=160ms
...    NRDRX-4:drxOnDurationTimer=60ms
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots320

@{set_NRCELL_3_actCDrx_false}
...    NRCELL-3:actCDrx=false

@{online_modification_B017}
...    @{sCellActivationMethod_blind}
...    @{NRCELL_3_NRREL_covBasedA1}
...    NRCELL-3:actPerCsiReportBundlingTddFr1=true
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-6:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELL-2:beamSet:basicBeamSet=beamSet_6
...    NRCELL-3:beamSet:basicBeamSet=beamSet_6
...    NRCELL-3:actAperCsi=true
...    NRCELL-3:actCDrx=true
...    NRDRX-4:drxLongCycle=40ms
...    NRDRX-4:drxOnDurationTimer=8ms
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRDU-1:dlToUlContributionRatio=50
...    NRCELL-3:actCsiResAllocOptList=csiRepAllCcHighCsiRs,sCellCsiAllocAlgoOpt
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-13:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-14:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-3:pucchF3ModulationScheme=qpsk_4psk
...    @{add_NRCELL_3_NRREL_14}
...    NRCELL-1:weightForSCellSelection=60
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50

@{online_modification_B017_recover}
...    NRCELL-3:actPerCsiReportBundlingTddFr1=false
...    NRCELL-3:actAperCsi=false
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL-3:actCsiResAllocOptList=sCellCsiAllocAlgoOpt
...    NRCELL-3:pucchF3ModulationScheme=pi2bpsk
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-6:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRCELL-3:beamSet:basicBeamSet=beamSet_4
...    NRCELL:weightForSCellSelection=50
...    delete:NRCELL-3/NRREL-14
...    NRCELL-3:actCDrx=true
...    NRCELL-3/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-13:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-14:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-3:actCsiResAllocOptList=disabled

@{add_NRCELL_3_NRREL_14}
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-14:gNbId=1
...    NRCELL-3/NRREL-14:gNbIdLength=22
...    NRCELL-3/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-14:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-14:lcrId=14
...    NRCELL-3/NRREL-14:nrDcAllowed=false
...    NRCELL-3/NRREL-14:removeNotAllowed=false
...    NRCELL-3/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-14:a2MeasSCellRelEnabled=rsrq
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-14:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-14:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{set_NRCELL_3_NRREL_11_dlAndUl}
...    NRCELL-3/NRREL-11:sCellOperationalMode=dlAndUl

@{online_modification_actUeCsirsCoexistCellCsirs_true}
...    NRCELL-3:actUeCsirsCoexistCellCsirs=true

@{online_modification_actUeCsirsCoexistCellCsirs_false}
...    NRCELL-3:actUeCsirsCoexistCellCsirs=false

#CSIRS_percc_4_AllCC_16_allreports_16_band77_nonCA_t2r4_3T2F_CA_t1r2_ULCA
#for example: supportedBandCombinationList-v1540-bandList-v1540-srs-TxSwitch-supportedSRS-TxPortSwitch t2r4
#ULCA need pcell and UL scell use the featureSetListPerUplinkCC.maxNumberSRS-Ports-PerResource n1 and
#featureSetsUplinkPerCC.element.mimo-CB-PUSCH.maxNumberMIMO-LayersCB-PUSCH oneLayer
${SA_Capa_3T2F_Full_UE1_band77_nonCA_t2r4_CA_t1r2}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040
...    E1E027FFC00001FFF000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E2080
...    00010B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0AC5C4C0
...    00E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC5C28000
...    E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4C00000E16175938
...    50001C28000E20800710400389800001C2C3F593850001C41000E2080071180038980000202C0BC1C28000012160205E0E2080000A0B0102F
...    07118000050580817838980000242C040803808D00A202640411740101130B428913639F0E14489B1CF870A244D8E7C3851226C73E1C28913
...    639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF8112040
...    81B1CF810A040D8E7C09102040810367BF2E4408102040D96BC39102040810365AF0E044D8E7C38103600002040D80000811360000001F161
...    8C6318C6318C6318C6318C6318DE82E003C00281C1401C0C02500700060240040603E09002000000010000020080000000400000802000008
...    010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C010008120
...    48020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652404000065949410000296525040000E59490
...    1000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594
...    900CD2A8BA55554AAAE95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A05028140A05028140A0502
...    81400282020180300801002101002008040300610080100202018030080600C10100C018040300610080100202018030080100220100C0180
...    4030060100C018202004010080100440100200404008010100C018040300601002004802004008080600C02018030080600C0200400800400
...    80300080600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${SA_Capa_3T2F_Full_UE2_band77_nonCA_t2r4_CA_notsupport}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA5AF32D7942C1FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF996BCA160FFFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040
...    E1E027FFC00001FFF000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E2080
...    00010B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0AC5C4C0
...    00E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC5C28000
...    E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4C00000E16175938
...    50001C28000E20800710400389800001C2C3F593850001C41000E2080071180038980000202C0BC1C28000012160205E0E2080000A0B0102F
...    07118000050580817838980000242C040803808D00A202640411740101130B428913639F0E14489B1CF870A244D8E7C3851226C73E1C28913
...    639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF8112040
...    81B1CF810A040D8E7C09102040813B65AF0E4408102040D96BC39102040810365AF0E044D8E7C38103600002040D80000811360000001F161
...    8C6318C6318C6318C6318C6318DE82E003C00281C1401C0C02500700060240040603E09002000000010000020080000000400000802000008
...    010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C010008120
...    48020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652404000065949410000296525040000E59490
...    1000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594
...    900CD2A8BA55554AAAE95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A05028140A05028140A0502
...    81400282020180300801002101002008040300610080100202018030080600C10100C018040300610080100202018030080100220100C0180
...    4030060100C018202004010080100440100200404008010100C018040300601002004802004008080600C02018030080600C0200400800400
...    80300080600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

#ULCA
${SA_Capa_2T3F_CSIRS_percc_8_AllCC_12_allreports_12}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF98E7CA160FFFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040
...    E1E027FFC00001FFF000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E2080
...    00010B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0AC5C4C0
...    00E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC5C28000
...    E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC7C28000E14000710400388C00001C2C2EB1F0A00038
...    50001C41000E208000070B0FD64E140007104003882001C46000E260000080B02F070A0000048580817838820000282C040BC1C4600001416
...    0205E0E260000090B010200E0234028809901045D004043C2D0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244
...    D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E042810
...    3639F02340810206CF7E5C68102040D96BC39102040810365AF1E044D8E7C38103600002040D800008113639F0007C586318C6318C6318C63
...    18C6318C637A0B800F000A070500703009401C0018090010180F8240080000000400000802000000010000020080000200400001802000010
...    0100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535
...    953582958195833582B594B5933580B581B58095811583B40D04000025949010000196525040000A594941000039652404000125949010000
...    596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AA2E955552A
...    ABA55154162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A05000A08080600C0
...    2004008404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C0180403006080
...    80100402004010C04008010100200404030060100C018802004008080600C02018030080600C020040080040080300080600C3543E0002040
...    6080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

@{expect_regexp}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:62, scellIdx:4

@{3T2F_expect_regexp_B017}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:63, scellIdx:4
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{2T3F_expect_regexp_B017}
...    pcid:50, scellIdx:1
...    pcid:60, scellIdx:2
...    pcid:62, scellIdx:3
...    pcid:63, scellIdx:4
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{PM_Counters_Check}
...    NRCELL-3:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=4
...    NRCELL-3:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=4
...    NRCELL-3:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-13:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=4
...    NRCELL-3:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=4
...    NRCELL-3:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=4
...    NRCELL-3:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=4

@{PM_Counters_Check_B017}
...    NRCELL-3:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=4
...    NRCELL-3:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=4
...    NRCELL-3:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-13:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-14:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=4
...    NRCELL-3:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=4
...    NRCELL-3:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=4
...    NRCELL-3:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=4
...    NRCELL-3:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>0

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
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
#UE_PCELL_1_CONF_SCELL_UL_SA    This counter shows the sum of samples for total number of CA UEs in the current cell
#configured as a PCell, which have 1 configured SCell in UL.
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
#UE_SCELL_1_CONF_SCELL_UL_SA    This counter shows the sum of samples for the total number of CA UEs in the current cell
#configured as UL SCell, while pegged in the secondary cell, which have 1 configured UL SCell in UL.
*** Test Cases ***
CB009855-ET-B010 Activation_3T2F_CA_IWK_SRS_based_beamforming_actDlSrsBm_enable_2200_enable_actUeCsirsCoexistCellCsirs_false_then_modify_true
    [Documentation]
    ...    1. The purpose of this test case is Interworking with SRS based beamforming
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                   Cell-1    Cell-2    Cell-3    Cell-11    Cell-12    Cell-13    cell-14
    ...    Technology       TDD      TDD      TDD        FDD         FDD         FDD       FDD
    ...          Band       n41      n41      n77        n71         n71        n66        n66
    ...     Bandwidth        60      60       80        10          10         10         20
    ...            BF        Yes     Yes      Yes         NO          NO         No       No
    ...    Beam Refinement    No       No      No         No          No         No       No
    ...    beamset            4        4       4         1            1          1         1
    ...    ssbfreq        504990     531870   632736    127450     127450     424090    427970
    ...    pucchF3Modul    Pcell cell-3 pi2bpsk
    ...    pucchF3MaxCode  pcell cell-3 zeroDot08
    ...    weightForSCellSelection    all cells are 50
    ...    2. Test Case Steps:
    ...         a. UE-SA_Capa_3T2F_Full_UE1_band77_nonCA_t2r4_CA_t1r2 attach to cell-3
    ...            trigger scell add (CA_cell3_cell1_cell2_cell-11_cell_13), traffic is ok.
    ...            then trigger scell release with index 1234, then trigger scelladd again. release UE.
    ...         b. UE-SA_Capa_3T2F_Full_UE2_band77_nonCA_t2r4_CA_notsupport attach to cell-3
    ...            trigger scell add (CA_cell3_cell1_cell2_cell-11_cell_13), traffic is ok.
    ...            then trigger scell release with index 4321, then trigger scelladd again.release UE.
    ...         c. online_modification_actUeCsirsCoexistCellCsirs_true
    ...         d. UE-SA_Capa_3T2F_Full_UE1_band77_nonCA_t2r4_CA_t1r2 attach to cell-3
    ...            trigger scell add (CA_cell3_cell1_cell2_cell-11_cell_13), traffic is ok.
    ...            then trigger scell release with index 1234, then trigger scelladd again.release UE.
    ...         e. UE-SA_Capa_3T2F_Full_UE2_band77_nonCA_t2r4_CA_notsupport attach to cell-3
    ...            trigger scell add (CA_cell3_cell1_cell2_cell-11_cell_13), traffic is ok.
    ...            then trigger scell release with index 4321, then trigger scelladd again.release UE.
    ...    4. Expected Results:
    ...         a. UE is attch to pcell nrcell-3
    ...            IE: periodic SRS (periodic and antenna switching) in PCell.
    ...                 maxRank is 2. nrofSRS-Ports is ports2. maxpayloadSize is 8. maxCodeRate is zeroDot08
    ...                 cell specific CSIRS used: nrofPorts: P8
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_13. traffic is ok.
    ...            IE: periodic SRS in PCell. maxRank is 1. nrofSRS-Ports is ports1. maxpayloadSize is 24. maxCodeRate is zeroDot25
    ...                 cell specific CSIRS used: nrofPorts: P8
    ...            trigger scell release with index 1234:
    ...                 CA_cell3_cell2_cell-11_cell_13: 2T2F HarqAn 15. maxpayloadSize is 16. maxCodeRate is zeroDot25
    ...                 CA_cell3_cell-11_cell_13: 1T2F HarqAn 9. maxpayloadSize is 12. maxCodeRate is zeroDot15.
    ...                 CA_cell3_cell_13: 1T1F HarqAn 7. maxpayloadSize is 8. maxCodeRate is zeroDot08.
    ...                 CA_cell3: 1T HarqAn 4. maxpayloadSize is 8. maxCodeRate is zeroDot08
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_13. traffic is ok.
    ...             Ue released successfully.
    ...         b. UE is attch to pcell nrcell-3
    ...            IE: periodic SRS (periodic and antenna switching) in PCell.
    ...                 maxRank is 2. nrofSRS-Ports is ports2. maxpayloadSize is 8. maxCodeRate is zeroDot08
    ...                 cell specific CSIRS used: nrofPorts: P8
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_13. traffic is ok.
    ...            IE: Aperiodic SRS in PCell. maxRank is 1. nrofSRS-Ports is ports1. maxpayloadSize is 24. maxCodeRate is zeroDot25
    ...                 cell specific CSIRS used: nrofPorts: P8
    ...            trigger scell release with index 4321:
    ...                 CA_cell3_cell1_cell2_cell-11: 3T1F HarqAn 16. maxpayloadSize is 20. maxCodeRate is zeroDot25
    ...                 CA_cell3_cell1_cell2: 3T HarqAn 14. maxpayloadSize is 16. maxCodeRate is zeroDot25.
    ...                 CA_cell3_cell1: 2T HarqAn 9. maxpayloadSize is 12. maxCodeRate is zeroDot15.
    ...                 CA_cell3: 1T HarqAn 4. maxpayloadSize is 8. maxCodeRate is zeroDot08
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_13. traffic is ok.
    ...             Ue released successfully.
    ...         c. online change actUeCsirsCoexistCellCsirs successfully. cell on air. so from now, ue-specific CSIRS can be working.
    ...         d. UE is attch to pcell nrcell-3
    ...            IE: periodic SRS (periodic and antenna switching) in PCell.
    ...                 maxRank is 2. nrofSRS-Ports is ports2. maxpayloadSize is 8. maxCodeRate is zeroDot08
    ...                 ue specific CSIRS used: nrofPorts: P4
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_13. traffic is ok.
    ...            IE:  periodic SRS in PCell. maxRank is 1. nrofSRS-Ports is ports1. maxpayloadSize is 24. maxCodeRate is zeroDot25
    ...                 pcell use ue specific CSIRS: nrofPorts: P4.
    ...                 scell use cell specific CSIRS: nrofPorts: P8
    ...            trigger scell release with index 1234:
    ...                 CA_cell3_cell2_cell-11_cell_13: 2T2F HarqAn 15. maxpayloadSize is 16. maxCodeRate is zeroDot25
    ...                 CA_cell3_cell-11_cell_13: 1T2F HarqAn 9. maxpayloadSize is 12. maxCodeRate is zeroDot15.
    ...                 CA_cell3_cell_13: 1T1F HarqAn 7. maxpayloadSize is 8. maxCodeRate is zeroDot08.
    ...                 CA_cell3: 1T HarqAn 4. maxpayloadSize is 8. maxCodeRate is zeroDot08
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_13. traffic is ok.
    ...             Ue released successfully.
    ...         e. UE is attch to pcell nrcell-3
    ...            IE: periodic SRS (periodic and antenna switching) in PCell.
    ...                 maxRank is 2. nrofSRS-Ports is ports2. maxpayloadSize is 8. maxCodeRate is zeroDot08
    ...                 ue specific CSIRS used: nrofPorts: P4
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_13. traffic is ok.
    ...            IE: Aperiodic SRS in PCell. maxRank is 1. nrofSRS-Ports is ports1. maxpayloadSize is 24. maxCodeRate is zeroDot25
    ...                 pcell use cell specific CSIRS as Aperiodic SRS assigned: nrofPorts: P8 CSIRS number: 4
    ...                 scell use cell specific CSIRS: nrofPorts: P8
    ...            trigger scell release with index 4321:
    ...                 CA_cell3_cell1_cell2_cell-11: 3T1F HarqAn 16. maxpayloadSize is 20. maxCodeRate is zeroDot25
    ...                 CA_cell3_cell1_cell2: 3T HarqAn 14. maxpayloadSize is 16. maxCodeRate is zeroDot25.
    ...                 CA_cell3_cell1: 2T HarqAn 9. maxpayloadSize is 12. maxCodeRate is zeroDot15.
    ...                 CA_cell3: 1T HarqAn 4. maxpayloadSize is 8. maxCodeRate is zeroDot08,
    ...                 ue pcell change back to ue-specific CSIRS: p4
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_13. traffic is ok.
    ...             Ue released successfully.
    [Tags]    QC_304667    CA_LABEL-TTTFF(80Mhz_TDD_n77+60Mhz_TDD_n41+60Mhz_TDD_n41+10Mhz_FDD_n71+10Mhz_FDD_n66)
    Clear Counter files    True
    OnlineParamChange    ${online_modification_B010}
    UE with UE1 capability Scelladd and a2scellrelease1234
    UE with UE2 capability Scelladd and a2scellrelease4321
    Check Counters    ${PM_Counters_Check}
    OnlineParamChange with object lock and unlock nrcell-3    ${online_modification_actUeCsirsCoexistCellCsirs_true}
    Clear Counter files    True
    UE with UE1 capability Scelladd and a2scellrelease1234
    UE with UE2 capability Scelladd and a2scellrelease4321
    Check Counters    ${PM_Counters_Check}
    Check WireShark Log    ${CURDIR}${/}A2A_B010${/}a2a.ini    wait_string=UEContextRelease::48
    [Teardown]    B010_B017 Teardown    ${online_modification_actUeCsirsCoexistCellCsirs_false}

CB009855-ET-B017 Activation_5CC_CA_IWK_Optimized_PUCCH_resource_allocation_with_actPerCsiReportBundlingFr1Tdd_enable_and_actCDrx_onlinemodify
    [Documentation]
    ...    1. The purpose of this test case is Interworking with Optimized PUCCH resource allocation for 5CC DL CA TDD as Pcell
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                   Cell-1    Cell-2    Cell-3    Cell-11    Cell-12    Cell-13    cell-14
    ...    Technology       TDD      TDD      TDD        FDD         FDD         FDD       FDD
    ...          Band       n41      n41      n77        n71         n71        n66        n66
    ...     Bandwidth        60      60       80        10          10         10         20
    ...            BF        Yes     Yes      Yes         NO          NO         No       No
    ...    Beam Refinement    No       No      No         No          No         No       No
    ...    beamset            4        4       4          1            1          1         1
    ...    weightForSCell    60       50       50         50          50         50        50
    ...    ssbfreq        504990     531870   632736    127450     127450     424090    427970
    ...    pucchF3Modul    Pcell cell-3 qpsk_4psk
    ...    pucchF3MaxCode  pcell cell-3 zeroDot08
    ...    2. Test Case Steps:
    ...         a. UE-SA_Capa_2T3F attach to cell-3
    ...            trigger scell add (CA_cell3_cell1_cell-11_cell_13_cell_14), traffic is ok.
    ...            release UE.
    ...         b. UE-SA_Capa_3T2F attach to cell-3
    ...            trigger scell add (CA_cell3_cell1_cell2_cell-11_cell_14), traffic is ok.
    ...            release UE.
    ...         c. online_modification_Pcell_NRCELL_3_actCDrx_false
    ...         d. UE-SA_Capa_2T3F attach to cell-3
    ...            trigger scell add (CA_cell3_cell1_cell-11_cell_13_cell_14), traffic is ok.
    ...            release UE.
    ...         e. UE-SA_Capa_3T2F attach to cell-3
    ...            trigger scell add (CA_cell3_cell1_cell2_cell-11_cell_14), traffic is ok.
    ...            release UE.
    ...    4. Expected Results:
    ...         a. UE is attch to pcell nrcell-3
    ...            cell specific CSIRS used: nrofPorts: 4 P8 check drx setup
    ...            after A1MR, UE is configured with 2T3F CA_cell3_cell1_cell-11_cell_13_cell_14. traffic is ok.
    ...            IE: maxpayloadSize is 20. maxCodeRate is zeroDot15. CSIRS number: pcell 4 P8 scell-1 2 P8
    ...             Ue released successfully.
    ...         b. UE is attch to pcell nrcell-3
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_14. traffic is ok.
    ...            IE: maxpayloadSize is 24. maxCodeRate is zeroDot25
    ...                 CSIRS number: pcell 4 P8 scell-1 4 P8 scell-2 4 P8
    ...             Ue released successfully.
    ...         c. online set_NRCELL_3_actCDrx_false
    ...         d. UE is attch to pcell nrcell-3
    ...            cell specific CSIRS used: nrofPorts: P8 
    ...            after A1MR, UE is configured with 2T3F CA_cell3_cell1_cell-11_cell_13_cell_14. traffic is ok.
    ...            IE: maxpayloadSize is 20. maxCodeRate is zeroDot15. CSIRS number: pcell 4 P8 scell-1 4 P8
    ...             Ue released successfully.
    ...         e. UE is attch to pcell nrcell-3
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_14. traffic is ok.
    ...            IE: maxpayloadSize is 24. maxCodeRate is zeroDot25
    ...                 CSIRS number: pcell 4 P8 scell-1 4 P8 scell-2 4 P8
    ...             Ue released successfully.
    [Tags]    QC_304661    CA_LABEL-TTTFF(80Mhz_TDD_n77+60Mhz_TDD_n41+60Mhz_TDD_n41+10Mhz_FDD_n71+20Mhz_FDD_n66)
    ...    CA_LABEL-TTFFF(80Mhz_TDD_n77+60Mhz_TDD_n41+10Mhz_FDD_n71+10Mhz_FDD_n66+20Mhz_FDD_n66)
    OnlineParamChange with object lock and unlock all Tdd cell    ${online_modification_B017}
    OnlineParamChange    ${set_NRCELL_3_NRREL_11_dlAndUl}
    Clear Counter files    True
    UE 5CC 2T3F DL AND 1T1F UL CA check
    UE 5CC 3T2F DL AND 1T1F UL CA check
    OnlineParamChange    ${set_NRCELL_3_actCDrx_false}
    UE 5CC 2T3F DL AND 1T1F UL CA check
    UE 5CC 3T2F DL AND 1T1F UL CA check
    Check Counters    ${PM_Counters_Check_B017}
    Check WireShark Log    ${CURDIR}${/}A2A_B017${/}a2a.ini    wait_string=UEContextRelease::48
    [Teardown]    B010_B017 Teardown    ${online_modification_B017_recover}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

B010_B017 Teardown
    [Arguments]    ${Online_Param}
    OnlineParamChange with object lock and unlock all Tdd cell    ${Online_Param}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

OnlineParamChange with object lock and unlock nrcell-3
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Lock and unlock cell    3

OnlineParamChange with object lock and unlock all Tdd cell
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Lock and unlock cell    3
    Lock and unlock cell    2
    Lock and unlock cell    1

Lock and unlock cell
    [Arguments]    ${Nrcell_indext}
    Lock Cell${Nrcell_indext}
    Unlock Cell${Nrcell_indext}
    Cells Should Be Onair    ${Nrcell_indext}

UE with UE1 capability Scelladd and a2scellrelease1234
    Set UE Capability    ue_id=${SA_UE1_ID}    UE_Capabilities=${SA_Capa_3T2F_Full_UE1_band77_nonCA_t2r4_CA_t1r2}
    SA CA UE Setup PDU Session And Check CA Addition Successfully For 3T2F covbasedA1    expect_passlog=${expect_regexp}
    Traffic Send    ue_id=${SA_UE1_ID}
    Throughput Check
    trigger A2 scellrelease1234 and addback scell
    Release Ues    ue_type=sa    ue_id=${SA_UE1_ID}

UE with UE2 capability Scelladd and a2scellrelease4321
    Set UE Capability    ue_id=${SA_UE1_ID}    UE_Capabilities=${SA_Capa_3T2F_Full_UE2_band77_nonCA_t2r4_CA_notsupport}
    SA CA UE Setup PDU Session And Check CA Addition Successfully For 3T2F covbasedA1    expect_passlog=${expect_regexp}
    Traffic Send    ue_id=${SA_UE1_ID}
    Throughput Check
    trigger A2 scellrelease4321 and addback scell
    Release Ues    ue_type=sa    ue_id=${SA_UE1_ID}

trigger A2 scellrelease1234 and addback scell
    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=504990    scell_index=1
    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=531870    scell_index=2
    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=424090    scell_index=4
    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=127450    scell_index=3
    UE Send A1 Trigger Scell Activation    ue_id=${SA_UE1_ID}    cellfreq=632736    pass_reg_ca=${expect_regexp}
    Throughput Check

trigger A2 scellrelease4321 and addback scell
    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=424090    scell_index=4
    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=127450    scell_index=3
    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=531870    scell_index=2
    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=504990    scell_index=1
    UE Send A1 Trigger Scell Activation    ue_id=${SA_UE1_ID}    cellfreq=632736    pass_reg_ca=${expect_regexp}
    Throughput Check

Sa CA UE Register
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=${wait_timer}

SA CA UE Setup PDU Session And Check CA Addition Successfully For 3T2F covbasedA1
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2    ${expect_passlog}=QoS Routing Table
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=3
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=QoS Routing Table    sleep_time=${wait_timer}
    UE Send A1 Trigger Scell Activation    ue_id=${ue_id}    cellfreq=632736    pass_reg_ca=${expect_passlog}

UE Send A1 Trigger Scell Activation
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}

Traffic Send
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=7 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=8 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=9 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=11 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=10 mbps=10    UE ${ue_id}: UDP UL

Throughput Check
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=950    ${Tput_ul}=5    ${sleep_time}=15s    ${CC_num}=5
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
    Should Be True    ${scell_tput}/1000 > 0

Set UE Capability
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${UE_Capabilities}=${SA_Capa_perUE_Full}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

trigger A2 MR to release one scell
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${carrierfreq}=648096    ${scell_index}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20 scell_rsrq=20
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToReleaseList{${scell_index}}
    ${pcell_scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${pcell_scell_tput}    CellIndex-. *0 *0 *0 *0

UE 5CC 3T2F DL AND 1T1F UL CA check
    Set UE Capability    ue_id=${SA_UE1_ID}    UE_Capabilities=${SA_Capa_3T2F_Full_UE1_band77_nonCA_t2r4_CA_t1r2}
    SA CA UE Setup PDU Session And Check CA Addition Successfully For 3T2F covbasedA1    expect_passlog=${3T2F_expect_regexp_B017}
    Traffic Send    ue_id=${SA_UE1_ID}
    Traffic Send for UL
    Check ULCA Throughput    UL_cellindex=3
    Throughput Check    Tput_dl=850    Tput_ul=35
    Release Ues    ue_type=sa    ue_id=${SA_UE1_ID}

UE 5CC 2T3F DL AND 1T1F UL CA check
    Set UE Capability    ue_id=${SA_UE1_ID}    UE_Capabilities=${SA_Capa_2T3F_CSIRS_percc_8_AllCC_12_allreports_12}
    SA CA UE Setup PDU Session And Check CA Addition Successfully For 3T2F covbasedA1    expect_passlog=${2T3F_expect_regexp_B017}
    Traffic Send    ue_id=${SA_UE1_ID}
    Traffic Send for UL
    Check ULCA Throughput
    Throughput Check    Tput_dl=850    Tput_ul=35
    Release Ues    ue_type=sa    ue_id=${SA_UE1_ID}

Traffic Send for UL
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=4 mbps=70    UE ${ue_id}: UDP UL

Check ULCA Throughput
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_ul}=70    ${sleep_time}=15s    ${UL_cellindex}=2
    sleep    ${sleep_time}    sleep for Tput stable
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    pass_regexp=Average
    ${allul_tput}    set variable    0
    ${cellindex0_tput}    UL Scell Throughput Check    ${ue_id}    0
    ${cellindex2_tput}    UL Scell Throughput Check    ${ue_id}    ${UL_cellindex}
    ${allul_tput}    Evaluate    ${cellindex0_tput}+${cellindex2_tput}
    Should Be True    ${allul_tput}/1000 > ${Tput_ul}

UL Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0
