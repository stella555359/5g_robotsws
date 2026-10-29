*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-jean.jing    release-SBTS24R2    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
# set SA CA Ue Id
${SA_UE1_ID}    81

@{PARAMS_IN_SCF}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:actCDrx=true
...    NRCELL:actAperCsi=false
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-3:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
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
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
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
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=2
...    @{A012_parameter_update}
...    @{tddFrameStructure_tdlte_semiStatic3vs7_semiStatic3vs7}
...    NRCELL-3:numberOfRxBeamforming=4Rx
...    NRCELL-3:nrCellType=8DL4UL
...    @{add_2RX2TX_2_tdd_cells_gnb1_LCELNR}
@{add_2RX2TX_2_tdd_cells_gnb1_LCELNR}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-5
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-6
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-7
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-8

@{A012_parameter_update}
...    NRCELL-1:actUlSrsBm=false
...    NRCELL-2:actUlSrsBm=false
...    NRCELL-3:actUlSrsBm=false
...    NRCELL-1:actDlSrsBm=false
...    NRCELL-2:actDlSrsBm=false
...    NRCELL-3:actDlSrsBm=true
...    NRCELL-3:dftBeamDiffThresholdH=15
...    NRCELL-3:dftBeamDiffThresholdV=15
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
...    NRBTS-1/NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:actPerCsiReportBundlingTddFr1=true
...    NRCELL-2:actPerCsiReportBundlingTddFr1=true
...    NRCELL-3:actPerCsiReportBundlingTddFr1=true
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-6:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELL-2:beamSet:basicBeamSet=beamSet_6
...    NRCELL-3:beamSet:basicBeamSet=beamSet_6
...    @{sCellActivationMethod_A012}
...    @{NRCELL_3_NRREL_covBasedA1}

@{tddFrameStructure_tdlte_semiStatic3vs7_semiStatic3vs7}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-1:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-2:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-2:prachConfigurationIndex=98
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4
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

@{sCellActivationMethod_A012}
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

#supportedBandCombinationList-v1540 bandList-v1540 ca-ParametersNR-v1540 simultaneousCSI-ReportsAllCC 8
#csi-RS-IM-ReceptionForFeedbackPerBandComb maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC 16
#CSIRS_AllCC_16_allreports_8_band77_band41_band41_band71_band66
${SA_Capa_3T2F_CSIRS_AllCC_16_allreports_8}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C4
...    71E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B2ABB08873E238F11C7A067D813E
...    31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040E1E0
...    27FFC00001FFF000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010
...    B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0AC5C4C000E230
...    00711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC5C28000E230007
...    11800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4C00000E1617593850001C28
...    000E20800710400389800001C2C3F593850001C41000E2080071180038980000202C0BC1C28000012160205E0E2080000A0B0102F071180000
...    50580817838980000242C040803808D00A202640411740101150B428913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448
...    913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A0
...    40D8E7C09502040810206CB5E1C8810204081B2D78722040810206CB5E1C089B1CF870206C00004081B000010206C0000001F1618C6318C631
...    8C6318C6318C6318DE82E003C00281C1401C0C02500700060240040603E0900200000001000002008000000040000080200000801000006008
...    0000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C01000812048020000300C
...    E54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652404000065949410000296525040000E594901000049652404
...    000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2A8BA5555
...    4AAAE95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A05028140A05028140A0502814002820201803
...    00801002101002008040300610080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820
...    2004010080100440100200404008010100C018040300601002004802004008080600C02018030080600C020040080040080300080600C3543E
...    00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

@{expect_regexp}
...    maxPayloadSize 24
...    maxCodeRate zeroDot25
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:62, scellIdx:4
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{PM_Counters_Check}
...    NRCELL-3:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=2
...    NRCELL-3:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=2
...    NRCELL-3:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-13:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=2
...    NRCELL-3:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=2
...    NRCELL-3:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=2
...    NRCELL-3:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=2
...    NRBTS-1:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRBTS-1:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRBTS-1:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRBTS-1:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRBTS-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRBTS-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>0

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
${UE_PCELL_3_CONF_SCELL_DL_SA}    M55118C09501
#This counter indicates the total number of CA UEs in the current cell configured as a PCell with exactly 3 configured SCells in DL in SA mode.
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as a PCell with 2
#configured SCells in DL in SA mode.
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as a PCell with 1
#configured SCell in DL
${UE_SCELL_3_CONF_SCELL_DL_SA}    M55118C11009
#The sum of samples for total number of CA UEs in the current cell configured as an SCell while pegged in the secondary cell,
#which have three configured SCells in DL in SA mode.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as an SCell with 2
#configured SCells in DL in SA mode. The counter is pegged in the secondary cell.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as an SCell with 1
#configured SCell in DL in SA mode. The counter is pegged in the secondary cell.

*** Test Cases ***
CB009855-ET-A012_B3a_3T2F_peak_UCI_load_on_PUCCH_or_PUSCH_pCSI_bundling_enabled_then_A2scellrelease
    [Documentation]
    ...    1. The purpose of this test case is peak UCI load on PUCCH/PUSCH, interworking with pCSI bundling
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                   Cell-1    Cell-2    Cell-3    Cell-11    Cell-12    Cell-13    cell-14
    ...    Technology       TDD      TDD      TDD        FDD         FDD         FDD       FDD
    ...          Band       n41      n41      n77        n71         n71        n66        n66
    ...     Bandwidth        60      60       100        10          10         10         20
    ...            BF        Yes     Yes      Yes         NO          NO         No       No
    ...    Beam Refinement    Yes      Yes    Yes         No          No         No       No
    ...    beamset            6       6       6         1            1          1         1
    ...    ssbfreq        504990     531870    632736    127450     127450     424090    427970
    ...    pucchF3Modul    Pcell cell-3 pi2bpsk
    ...    pucchF3MaxCode    pcell cell-3 zeroDot08
    ...    weightForSCellSelection    all cells are 50
    ...    2. Test Case Steps:
    ...         a. UE-SA_Capa_3T2F_CSIRS_AllCC_16_allreports_8 attach to cell-3
    ...            trigger scell add (CA_cell3_cell1_cell2_cell-11_cell_13), trffic is ok.
    ...         b. trigger scell release with index 1243, then trigger scelladd again. release UE..
    ...    4. Expected Results:
    ...         a. UE is attch to pcell nrcell-3
    ...            IE: PUCCH resource set[1] and PUCCH resource set[2] are configured for UE; 8 PUCCH resources are
    ...                included in PUCCH resource set[1]; pcell csirsreport and beamreport are bundle
    ...                TDD use 2 CSIRS, each FDD use 1 CSIRS.maxPayloadSize of PUCCH resource set[1] is set to 24;
    ...                maxCodeRate of PUCCH format3 is set to a value >= 0.25
    ...         b. trigger scell release with index 1243:
    ...                 CA_cell3_cell2_cell-11_cell_13: maxpayloadSize is 16. maxCodeRate is zeroDot25
    ...                 CA_cell3_cell-11_cell_13: 1T2F maxpayloadSize is 12. maxCodeRate is zeroDot15.
    ...                 CA_cell3_cell_11: 1T1F maxpayloadSize is 8. maxCodeRate is zeroDot15.
    ...                 CA_cell3: 1T maxpayloadSize is 8. maxCodeRate is zeroDot08.
    ...            after A1MR, UE is configured with 3T2F CA_cell3_cell1_cell2_cell-11_cell_13. traffic is ok.
    ...            Ue released successfully.
    [Tags]    QC_47156    CA_LABEL-TTTFF(100Mhz_TDD_n77+60Mhz_TDD_n41+60Mhz_TDD_n41+10Mhz_FDD_n71+10Mhz_FDD_n66)
    Clear Counter files    True
    UE 5CC 3T2F DL AND 1T1F UL CA check
    trigger A2 scellrelease1243 and addback scell
    Release UEs    ue_type=all
    Check WireShark Log And Counter

*** Keywords ***
UE 5CC 3T2F DL AND 1T1F UL CA check
    Set UE Capability    ue_id=${SA_UE1_ID}    UE_Capabilities=${SA_Capa_3T2F_CSIRS_AllCC_16_allreports_8}
    SA CA UE Register to Cell3
    SA CA UE Setup PDU Session And Check CA Addition Successfully For 3T2F covbasedA1    expect_passlog=${expect_regexp}
    Traffic Send    ue_id=${SA_UE1_ID}
    Verify Throughput    ue_id=${SA_UE1_ID}    Tput_dl=810

trigger A2 scellrelease1243 and addback scell
    ${rrc}    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=504990    scell_index=1
    Check MaxPayLoad And MaxCodeRate Release Scell Index1    ${rrc}
    ${rrc}    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=531870    scell_index=2
    Check MaxPayLoad And MaxCodeRate Release Scell Index2    ${rrc}
    ${rrc}    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=424090    scell_index=4
    Check MaxPayLoad And MaxCodeRate Release Scell Index4    ${rrc}
    ${rrc}    trigger A2 MR to release one scell    ue_id=${SA_UE1_ID}    carrierfreq=127450    scell_index=3
    Check MaxPayLoad And MaxCodeRate Release Scell Index3    ${rrc}
    UE Send A1 Trigger Scell Activation    ue_id=${SA_UE1_ID}    cellfreq=632736    pass_reg_ca=${expect_regexp}
    Verify Throughput    ue_id=${SA_UE1_ID}    Tput_dl=810

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

Sa CA UE Register
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=${wait_timer}

SA CA UE Register to Cell3
    Sa CA UE Register    ue_id=${SA_UE1_ID}    gnb_id=2    cell_id=3

SA CA UE Setup PDU Session And Check CA Addition Successfully For 3T2F covbasedA1
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2    ${expect_passlog}=QoS Routing Table
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
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=9 mbps=10    UE ${ue_id}: UDP UL

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 >= 0

Throughput Check
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=1    ${sleep_time}=15s    ${CC_num}=5
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
   

Verify Throughput
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=5
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex-4

Set UE Capability
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${UE_Capabilities}=${SA_Capa_perUE_Full}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

trigger A2 MR to release one scell
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${carrierfreq}=648096    ${scell_index}=1
    [Return]    ${ret1}
    ${meas_id_scell1}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell1} event=A2 scell=${scell_index} scell_rsrp=20 scell_rsrq=20
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    ${ret2}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret2}    sCellToReleaseList{${scell_index}}
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0

Check MaxPayLoad And MaxCodeRate Release Scell Index1
    [Arguments]    ${ret1}    ${maxPayload_size}=16    ${maxCodeRate}=25
    Should Contain    ${ret1}    maxPayloadSize ${maxPayload_size}
    Should Not Contain    ${ret1}    maxCodeRate zeroDot${maxCodeRate}

Check MaxPayLoad And MaxCodeRate Release Scell Index2
    [Arguments]    ${ret1}    ${maxPayload_size}=12    ${maxCodeRate}=15
    Should Contain    ${ret1}    maxPayloadSize ${maxPayload_size}
    Should Contain    ${ret1}    maxCodeRate zeroDot${maxCodeRate}

Check MaxPayLoad And MaxCodeRate Release Scell Index4
    [Arguments]    ${ret1}    ${maxPayload_size}=8    ${maxCodeRate}=15
    Should Contain    ${ret1}    maxPayloadSize ${maxPayload_size}
    Should Not Contain    ${ret1}    maxCodeRate zeroDot${maxCodeRate}

Check MaxPayLoad And MaxCodeRate Release Scell Index3
    [Arguments]    ${ret1}    ${maxPayload_size}=8    ${maxCodeRate}=08
    Should Not Contain    ${ret1}    maxPayloadSize ${maxPayload_size}
    Should Contain    ${ret1}    maxCodeRate zeroDot${maxCodeRate}

Check WireShark Log And Counter
    Check Counters    ${PM_Counters_Check}
    #Check WireShark Log    ${CURDIR}${/}A2A_A_012${/}a2a.ini    wait_string=UEContextRelease::12
