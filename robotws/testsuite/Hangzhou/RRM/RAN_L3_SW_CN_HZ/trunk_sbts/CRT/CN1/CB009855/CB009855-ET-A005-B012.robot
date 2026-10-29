*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-jolin.fan    release-SBTS24R2    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${CaSup}    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Any_Sa
@{PARAMS_IN_SCF}
...    @{tddFrameStructure_configuration}
...    @{CA_basic_config}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:actPucchAdditionalDmrs=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL:actDl256Qam=false

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
...    NRCELL-4:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-4:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4

# Parameter For TDD+TDD+TDD+FDD+FDD CA_n41-n66A-n71A-n78(2A)
@{CA_basic_config}
...    NRCELL:actEnhancedPDSCHSchSplSlot=false
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:actMeasBasedSCellAdditionSa=disabled
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CaSup}
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
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
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
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
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:nrDcAllowed=false
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-12:timingAdvanceOffset=n25600
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRBTS-1/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS-1/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

@{Case_A005_configuration}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlAndUl
...    NRCELL:actCDrx=true
...    NRCELL:actAperCsi=false
...    NRCELL:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-1:actBeamforming=true
...    NRCELL-2:actBeamforming=true
...    NRCELL-3:actBeamforming=true
...    NRCELL-4:actBeamforming=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-2:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-3:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-4:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=6 beams
...    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    MRBTS-1/NRBTS-1/NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    MRBTS-1/NRBTS-1/NRCELL-3:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-2:csirsBeamMgmt:csirsBmMgmtReIndex=0
...    NRCELL-2:csirsBeamMgmt:csirsBmMgmtSubband=aboveSSPBCHBlock
...    NRCELL-4:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-4:csirsBeamMgmt:csirsBmMgmtReIndex=0
...    NRCELL-4:csirsBeamMgmt:csirsBmMgmtSubband=aboveSSPBCHBlock
...    NRCELL-1:srPeriodicity=slots20
...    NRCELL-2:srPeriodicity=slots20
...    NRCELL-3:srPeriodicity=slots20
...    NRCELL-4:srPeriodicity=slots20

@{Case_B012_configuration}
...    NRCELL-1:actInfTddFrameMuting=false
...    NRCELL-1:infTddFrameStructure:infFrameStructureType=semiStatic
...    NRCELL-1:infTddFrameStructure:infTddFrameMutingBiAgreement=false
...    NRCELL-1:infTddFrameStructure:infUlDlDataSlotRatio=1/4
...    NRCELL-1:infTddFrameStructure:infGuardPeriodLength=2Symbols
...    NRCELL-1:infTddFrameStructure:infScs=30 KHz
...    NRCELL-2:infTddFrameStructure:infFrameStructureType=semiStatic
...    NRCELL-2:infTddFrameStructure:infTddFrameMutingBiAgreement=false
...    NRCELL-2:infTddFrameStructure:infUlDlDataSlotRatio=1/4
...    NRCELL-2:infTddFrameStructure:infGuardPeriodLength=2Symbols
...    NRCELL-2:infTddFrameStructure:infScs=30 KHz
...    NRCELL-3:infTddFrameStructure:infFrameStructureType=semiStatic
...    NRCELL-3:infTddFrameStructure:infTddFrameMutingBiAgreement=false
...    NRCELL-3:infTddFrameStructure:infUlDlDataSlotRatio=1/4
...    NRCELL-3:infTddFrameStructure:infGuardPeriodLength=2Symbols
...    NRCELL-3:infTddFrameStructure:infScs=30 KHz
...    NRCELL-4:infTddFrameStructure:infFrameStructureType=semiStatic
...    NRCELL-4:infTddFrameStructure:infTddFrameMutingBiAgreement=false
...    NRCELL-4:infTddFrameStructure:infUlDlDataSlotRatio=1/4
...    NRCELL-4:infTddFrameStructure:infGuardPeriodLength=2Symbols
...    NRCELL-4:infTddFrameStructure:infScs=30 KHz
@{2CC_disable_actInfTddFrameMuting}
...    NRCELL-1:actInfTddFrameMuting=false
...    NRCELL-1:actBlankDlSymbBorderCoord=false
...    NRCELL-2:actInfTddFrameMuting=false
...    NRCELL-2:actBlankDlSymbBorderCoord=false
...    NRCELL-3:actInfTddFrameMuting=false
...    NRCELL-3:actBlankDlSymbBorderCoord=false
...    NRCELL-4:actInfTddFrameMuting=false
...    NRCELL-4:actBlankDlSymbBorderCoord=false
...    delete:NRCELL-1/NRREL-3
...    delete:NRCELL-1/NRREL-11
...    delete:NRCELL-1/NRREL-12

@{B012_para_recover}
...    delete:NRCELL-1/infTddFrameStructure
...    NRCELL-1:actInfTddFrameMuting=false
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:nrDcAllowed=false
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
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
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:nrDcAllowed=false
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3

@{PM_Counters_Check}
...    NRCELL-1:${GNB_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-1:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${GNB_DU_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-1:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=1
...    NRCELL-1:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=1
...    NRCELL-1:${UE_PCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-12:${UE_SCELL_1_CONF_SCELL_UL_SA}>0

@{PM_Counters_Check_5CC}
...    NRCELL-1:${GNB_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-1:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${GNB_DU_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-1:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=1
...    NRCELL-1:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=1

@{PM_Counters_Check_2CC}
...    NRCELL-1:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
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
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
# This counter is updated with the current number of PCell UEs with 1 configured SCell in UL when the sample timer expires.
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
# This counter is updated with the current number of SCell UEs with 1 configured SCell in UL when the sample timer expires.
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
# The current number of PCell UEs with 1 configured SCell in DL is calculated when the sample timer expires.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
# The current number of SCell UEs with 1 configured SCell in DL is calculated when the sample timer expires.

#N78_N71 Support UL CA:
# featureSetsUplinkPerCC {
#     mimo-CB-PUSCH {maxNumberMIMO-LayersCB-PUSCH oneLayer,
#                    maxNumberSRS-ResourcePerSet 1}}
${SA_Capa_3T2F_Full_ULCa}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EB8D851AC1184341020E9068036B665B68D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000
...    00170000381546C4DD608C21A0810748340185B2ECB08873E238F11C7A067D813E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00
...    AAD931561439F11C78C0000000000000000007FFFE027FFC00001FFF0000017000038020F0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C
...    0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E230007
...    11800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C4600
...    0E140000040B02B0F11800388C00000C2C0ACBC28000E20800710400388C001C4D000E268000070B0B803808D00A2026C04117400CD08428913639F0E14489B1CF870A244
...    D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF81120408
...    1B1CF810A040D8E7C09502040810206CB5E18191018C6318C6318C6318C6301E82E003C00281C1401C0C02500700060240040603E09002000000010000020080000000400
...    000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C01000812048020000300C
...    E54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652404000065949410000296524040000E59490100004965240400016594901000069652404
...    0001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2A8BA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A935
...    55078A160178095028140A05028140A05028140A05028140A0502814001C2020180300801002101002008040300610080100202018030080600C10100C018040300610080
...    100202018030080100220100C01804030060100C018202004010080100450100200404030060100C01804030060100200404008011AA1F000102030406070A0B0C0D10111
...    2131418191B1C1D1F2125262728292A2D2F414182D

@{4Scells_expect}
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    SCellIndex 3 activated successfully
...    SCellIndex 4 activated successfully
...    pcid:50, scellIdx:0
...    pcid:51, scellIdx:1
...    pcid:52, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:61, scellIdx:4

${2CC_expect}
...    PhysCellId: 51] SCellIndex 1 activated successfully

@{Scell_deactive}
...    PhysCellId:51] SCellIndex 1 deactivated successfully
...    PhysCellId:52] SCellIndex 2 deactivated successfully
...    PhysCellId:60] SCellIndex 3 deactivated successfully
...    PhysCellId:61] SCellIndex 4 deactivated successfully

@{Scell_active}
...    PhysCellId: 51] SCellIndex 1 activated successfully
...    PhysCellId: 52] SCellIndex 2 activated successfully
...    PhysCellId: 60] SCellIndex 3 activated successfully

@{actInfTddFrameMuting_true}
...    NRCELL-1:actInfTddFrameMuting=true
...    NRCELL-1:actBlankDlSymbBorderCoord=true
...    NRCELL-1:infTddFrameStructure:infTddFrameMutingBiAgreement=true
...    NRCELL-2:actInfTddFrameMuting=true
...    NRCELL-2:actBlankDlSymbBorderCoord=true
...    NRCELL-2:infTddFrameStructure:infTddFrameMutingBiAgreement=true
...    NRCELL-3:actInfTddFrameMuting=true
...    NRCELL-3:actBlankDlSymbBorderCoord=true
...    NRCELL-3:infTddFrameStructure:infTddFrameMutingBiAgreement=true
...    NRCELL-4:actInfTddFrameMuting=true
...    NRCELL-4:actBlankDlSymbBorderCoord=true
...    NRCELL-4:infTddFrameStructure:infTddFrameMutingBiAgreement=true
*** Test Cases ***
CB009855-ET-B012_Activation_IWK_UL_slot_mute_TTCA
    [Documentation]
    ...    1. The purpose of this test case is to validate that if there is no bilateral agreement between operators, partial UL slots will be muted
    ...       in the cell interfered by another cell with different frame structure on the same carrier; bundle window will be enlarged accordingly,
    ...       and HARQ-AN bits per bundle window might exceed the maximum allowed HARQ-AN bits on PUCCH. To avoid such situation, C-Plane will check
    ...       whether the maximum number of HARQ-AN bits per bundle window will exceed the maximum allowed HARQ-AN bits on PUCCH, if it is, one SCell
    ...       candidate will be dropped until only 1 SCell candidate is left or maximum HARQ-AN bits per bundle window will not exceed maximum
    ...       HARQ-AN bits allowed on PUCCH. this user scenario intends to verify the SCell candidate dropping check function provided by C-Plane.
    ...    2. Configuration
    ...     gNBs host following cells:
    ...                     Cell1    Cell2    Cell3    Cell4    Cell11    Cell12
    ...     Technology       TDD     TDD      TDD      TDD      FDD       FDD
    ...          Band        n78     n78      n41      n41      n66       n71
    ...     Bandwidth        100     100      80       80       20        20
    ...     Supercell        No      No       No       No       No        No
    ...     Beamforming      No      No       No       No       No        No
    ...    Beam Refinement   No      No       No       No       No        No
    ...    numberOfTransmittedSsBlocks    1    1    1    1      1         1
    ...    pucchF3ModulationScheme    pi2bpsk    pi2bpsk    pi2bpsk    pi2bpsk    pi2bpsk    pi2bpsk
    ...    pucchF3MaxCodeRate    zeroDot08    zeroDot08    zeroDot08    zeroDot08    zeroDot08
    ...    weightForSCellSelection    80    70    60    50    45    40
    ...    CELL tddFrameStructure    see @{tddFrameStructure_configuration}
    ...    3. Test Case Steps:
    ...         a. attach UE81 to cell1. setup PDU session and trigger blind scell addition.
    ...         b. run and check traffic.
    ...         c. release UE81.
    ...         d. online modify NRCELL-1:actInfTddFrameMuting=true to enable UL slot muting.
    ...         e. attach UE81 to cell1 again. setup PDU session and trigger blind scell addition.
    ...         f. run large traffic to tput and check Pcell throughput.
    ...         g. Release UE81.
    ...         h. online modify NRCELL-1:actInfTddFrameMuting=false and delete NRCELL-1/NRREL-3,NRREL-11,NRREL-12.
    ...         i. attach UE81 to cell1 again. setup PDU session and trigger blind scell addition.
    ...         j. run large traffic to tput and check Pcell throughput.
    ...         k. Release UE81.
    ...    4. Expected Results:
    ...         a. UE81 is configured with 3T + 2F 5CC CA(Pcell--cell1+Scell-cell2,cell3,cell11,cell12).
    ...         b. 4 scells are activated, traffic is ok.
    ...         c. UE is released.
    ...         e. Only Scell cell2 is added.
    ...         i. Normal T+T 2CC Scell cell2 is added.
    ...         j. Pcell throughput is larger than it in step f, because if actInfTddFrameMuting=true some slot is muted, and traffic will reduce.
    ...         k. UE is released.
    ...         in this case, C-Plane allowed HARQ-AN bits= 'maxPayloadSize - 1'. according to 5G_UP_ALG_15195.1 if Pcell and TDD scell frame
    ...         structure is 'tdLte', interfering frame structure is 'semi-static4:1', Pcell HAN bits is '6', TDD Scell HAN bits is '6',
    ...         FDD Scell HAN bits is '4'.
    ...         CA Configuration   HARQ-AN   maxPayloadSize-1
    ...         3T+2F              26        23
    ...         3T+F               22        19
    ...         3T                 18        15
    ...         2T+2F              20        11
    ...         2T+F               16        11
    ...         2T                 12        11
    ...         All HARQ-AN of different CA configuration are exceed allowed HARQ-AN bits,so 3 Scell candidates will be dropped until only 1 SCell.
    [Tags]    QC_304664    B012    CA_LABLE-TTTFF(100MHz_TDD_n78+100MHz_TDD_n78+80MHz_TDD_n41+20MHz_FDD_n66+20MHz_FDD_n71)
    [Setup]    Preconfiguration for case B012    ${Case_B012_configuration}
    Ue register and blind 5CC CA successful
    Online Modify actInfTddFrameMuting for Pcell   ${actInfTddFrameMuting_true}
    Ue register and pdu session setup with blind scell addition    ue_id=81    cell_id=1    pass_reg_ca=${2CC_expect}
    ${P_tput1}=    Run Traffic And Verify Throughput return Pcell tput    ue_id=81    tput_dl=1000
    Release UEs    ue_type=all
    Online Modify actInfTddFrameMuting for Pcell    ${2CC_disable_actInfTddFrameMuting}
    Ue register and pdu session setup with blind scell addition    ue_id=81    cell_id=1    pass_reg_ca=${2CC_expect}
    ${P_tput2}=    Run Traffic And Verify Throughput return Pcell tput    ue_id=81    tput_dl=1000
    Should Be True    ${P_tput1}<${P_tput2}
    Release UE then Check WireShark Log And Counter
    [Teardown]  B012 Teardown

CB009855-ET-A005_3T2F_CA_actBeamforming_refinebeam_true_qpsk_zeroDot8_3tdLte_wo_shift_HackAN_18_DRX_scellactivate_bufferbase_scelldeactivate
    [Documentation]
    ...    1. The purpose of this test case is to validate the conditions to enable 3T+2F CA, CA_n78(2A)-n41A-66A-n71A, include UL n78_n71 CA.
    ...    2. Configuration
    ...     gNBs host following cells:
    ...                     Cell1    Cell2    Cell3    Cell4    Cell11    Cell12
    ...     Technology       TDD     TDD      TDD      TDD      FDD       FDD
    ...          Band        n78     n78      n41      n41      n66       n71
    ...     Bandwidth        100     100      80       80       20        20
    ...     Supercell        No      No       No       No       No        No
    ...     Beamforming      Yes     Yes      Yes      Yes      No        No
    ...    Beam Refinement   Yes     Yes      Yes      No      No        No
    ...    numberOfTransmittedSsBlocks    6    6    6    6      1         1
    ...    pucchF3ModulationScheme    qpsk_4psk    qpsk_4psk    qpsk_4psk    qpsk_4psk    qpsk_4psk    qpsk_4psk
    ...    pucchF3MaxCodeRate    zeroDot08    zeroDot08    zeroDot08    zeroDot08    zeroDot08
    ...    weightForSCellSelection    80    70    60    50    45    40
    ...    CELL tddFrameStructure    see @{tddFrameStructure_configuration}
    ...    3. Test Case Steps:
    ...         a. attach UE81 to cell1. trigger A1MR to add scell
    ...         b. start DL traffic for UE, all SCells are activated at the same time when the buffer condition for SCell activation is fulfilled.
    ...         c. after some time, decrease DL data rate, the SCells are deactivated.
    ...         d. after some time, start UL traffic for UE, the SCell cell12 configured in 'dlAndUl' mode is activated.
    ...         e. after some time increase DL data rate, those 'dlOnly' mode SCells are activated again.
    ...         f. Release UE81
    ...    4. Expected Results:
    ...         a. UE81 is configured with 3T + 2F 5CC CA(Pcell--cell1+Scell-cell2,cell3,cell11,cell12).
    ...         b. 4 scells are activated, traffic is ok.
    ...         c. 4 SCells are deactivated, traffic is only run in Pcell.
    ...         d. Scell cell12 is activated, ul traffic is ok.
    ...         e. 3 Scells cell2, cell3, cell11 are activated. UE81 are configured with 3T + 2F CA and traffic is ok.
    ...         f. Release UE81
    ...         in this case , numberOfCSI-RS-Resource value is 6(beam)*4=24,3 TDD CA total CSI-RS-Resource needed is 72.
    ...         UE capability maxNumberCSI-RS-Resource:64. So only 2 TDD cells applied BeamRefinementP2 for 3T+2F 5CC.
    [Tags]    QC_303359    A005    CA_LABLE-TTTFF(100MHz_TDD_n78+100MHz_TDD_n78+80MHz_TDD_n41+20MHz_FDD_n66+20MHz_FDD_n71)
    OnlineParamChange    ${Case_A005_configuration}
    Clear Counter files    True
    Ue register and pdu session setup    ue_id=81
    Run DL Traffic    ue_id=81
    UE Send A1 Trigger Scell Activation And Verify DL Throughput    ue_id=81    cellfreq=632736    pass_reg_ca=${4Scells_expect}    CC_Num=5
    ...    tput_dl=820
    Decrease DL Traffic to deactive scells    ue_id=81
    Run UL Traffic to active dlAndUl Scell    ue_id=81
    Increase DL Traffic to active dlOnly scells and more traffic for stability    ue_id=81
    Check WireShark Log And Counter
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_3T2F_Full_ULCa}

Preconfiguration for case B012
    [Arguments]    ${Online_Param}
    Common Test Setup And Start To Capture Logs
    OnlineParamChange    ${Online_Param}

B012 Teardown
    OnlineParamChange    ${B012_para_recover}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

Online Modify actInfTddFrameMuting for Pcell
    [Arguments]    ${Online_Param}
    OnlineParamChange    ${Online_Param}

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${cmd_regexp}=UE now in NG RM Registere
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=${cmd_pdu_regexp}

Ue register and blind 5CC CA successful
    Ue register and pdu session setup with blind scell addition    ue_id=81    cell_id=1    pass_reg_ca=${4Scells_expect}
    Run Traffic And Verify Throughput    ue_id=81    CC_Num=5    tput_dl=810    tput_ul=9
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_Check_5CC}

Ue register and pdu session setup with blind scell addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${cmd_regexp}=UE now in NG RM Registere
    ...    ${pass_reg_ca}=QoS Routing Table
    Ue register and pdu session setup    ue_id=${ue_id}    cell_id=${cell_id}    cmd_pdu_regexp=${pass_reg_ca}

UE Send A1 Trigger Scell Activation And Verify DL Throughput
    [Arguments]    ${ue_id}=1    ${cellfreq}=632736    ${pass_reg_ca}=activated    ${CC_Num}=5    ${tput_dl}=500
    UE Send A1 Trigger Scell Activation    ${ue_id}    ${cellfreq}    ${pass_reg_ca}
    Check DL Throughput    ue_id=${ue_id}    Tput_dl=${tput_dl}    CC_num=${CC_Num}

UE Send A1 Trigger Scell Activation
    [Arguments]    ${ue_id}=1    ${cellfreq}=632736    ${pass_reg_ca}=activated
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}

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
        ${cell_tput}    Get Scell Throughput    ${ue_id}    ${scellid}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
	END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Check UL Throughput
    [Arguments]    ${ue_id}=81    ${UL_tput}=120
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    Throughput
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${scell4_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=4    type=pusch    rate_type=ave
    Should Be True    (${scell0_ultput}+${scell4_ultput})/1000>${UL_tput}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Get Scell Throughput
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave


Run DL Traffic
    [Arguments]    ${ue_id}=81
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=7 mbps=10    UE ${ue_id}: UDP DL
    sleep    10s    sleep for Tput stable

Run UL Traffic to active dlAndUl Scell
    [Arguments]    ${ue_id}=81
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=150
    ...    pass_regexp=PhysCellId: 61] SCellIndex 4 activated successfully

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=81    ${CC_Num}=4    ${tput_dl}=810    ${tput_ul}=9
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=7 mbps=10    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=${ue_id}    CC_num=${CC_Num}    Tput_dl=${tput_dl}    Tput_ul=${tput_ul}

Run Traffic And Verify Throughput return Pcell tput
    [Arguments]    ${ue_id}    ${tput_dl}
    [Return]    ${cell_tput}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=7 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=8 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=9 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=10 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=11 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=12 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=13 mbps=10    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=81    CC_num=2    Tput_dl=${tput_dl}    Tput_ul=9
    ${cell_tput}=    Scell Throughput Check    ue_id=81    scell_id=0

Decrease DL Traffic to deactive scells
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6    pass_regexp=${Scell_deactive}
    sleep    15s    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    Throughput
    FOR    ${scellid}    IN RANGE    1    5
        ${scellid}=    convert to string    ${scellid}
        ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
        Should Be Equal As Integers    ${scell_tput}    0
	END

Increase DL Traffic to active dlOnly scells and more traffic for stability
    [Arguments]    ${ue_id}=81
    ${dlTput}    Set Variable    ${130}
    ${trfid}=    Run traffic unitl all scells activated    ue_id=81
    ${new_trfid1}    Evaluate    ${trfid}+1
    ${new_trfid2}    Evaluate    ${trfid}+2
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=${new_trfid1} mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=${new_trfid2} mbps=150    UE ${ue_id}: UDP DL
    ${dlTput}=    Evaluate    ${new_trfid2}*130
    Check DL Throughput    ue_id=81    Tput_dl=${dlTput}    CC_num=5
    Check UL Throughput    ue_id=81    UL_tput=100

Run traffic unitl all scells activated
    [Arguments]    ${ue_id}=81
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    FOR    ${trfid}    IN RANGE    3    8
        ${result}=    Run Keyword And Return Status    start_traffic    ue_id=${ue_id}    trfid=${trfid}
        Run Keyword If    ${result}==True    Return From Keyword    ${trfid}
        Exit For Loop If    ${result}==True
	END

start_traffic
    [Arguments]    ${ue_id}=81    ${trfid}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=${trfid} mbps=150    pass_regexp=${Scell_active}    timeout=5s

Check WireShark Log And Counter
    Check Counters    ${PM_Counters_Check}
    Check WireShark Log    ${CURDIR}${/}A2A_A005${/}a2a.ini    wait_string=UEContextModificationResponse::16

Release UE then Check WireShark Log And Counter
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_B012${/}a2a.ini    wait_string=UEContextRelease::24
    Check Counters    ${PM_Counters_Check_2CC}
