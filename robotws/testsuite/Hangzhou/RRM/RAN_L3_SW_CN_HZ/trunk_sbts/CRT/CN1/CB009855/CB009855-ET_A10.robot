*** Settings ***
Documentation    Suite documentation
...    author:  keyun.ma@nokia-sbell.com
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-jean.jing    release-SBTS23R3    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
# set SA CA Ue Ids
${SA_UE1_ID}    81
${SA_UE2_ID}    82

@{PARAMS_IN_SCF}
...    NRCELL-1:gscnOrSsPbchArfcn=7866
...    NRCELL-1:nrarfcn=636666
...    NRCELL:actEnhancedPDSCHSchSplSlot=false
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actLteNrDss=false
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-2:maxNumScellsDlFr1=4
...    NRCELL-3:maxNumScellsDlFr1=4
...    NRCELL-4:maxNumScellsDlFr1=4
...    NRCELL-11:maxNumScellsDlFr1=4
...    NRCELL-12:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    @{CELL_pucchF3_andothers}
...    @{tddFrameStructure_3_semiStatic3vs7}
...    @{parameter_p_cell1_3T2F}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{CELL_pucchF3_andothers}
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
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
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-2:prachConfigurationIndex=98
...    NRCELL-3:prachConfigurationIndex=98
...    NRCELL:actCDrx=false
...    NRCELL:actAperCsi=false
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:actBeamforming=false
...    NRCELL:actPucchAdditionalDmrs=false
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL2UL
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL2UL
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:nrCellType=4DL2UL
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=4DL2UL
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:channelId=5
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:channelId=6
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

@{tddFrameStructure_3_semiStatic3vs7}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-1:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-2:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-3:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-3:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=3/7
...    delete:NRCELL-3:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-3:tddFrameStructure:tdLteUlDlConfig

# Parameter For TDD+TDD+TDD+FDD+FDD CA_n41-n66A-n71A-n78(2A)
@{parameter_p_cell1_3T2F}
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

@{parameter_covBasedA1_related}
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-1:maxNumScellsDlFr1=4

@{OnlineParam_Change_maxNumSCellsDlFr1_Value_3}
...    NRCELL-1:maxNumScellsDlFr1=3

@{OnlineParam_Change_maxNumSCellsDlFr1_Value_4}
...    NRCELL-1:maxNumScellsDlFr1=4

@{OnlineParam_del_NRREL_3}
...    delete:NRCELL-1/NRREL-3

@{Recover_A10}
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
...    NRCELL-1:maxNumScellsDlFr1=4


@{PM_Counters_Check}
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_REQ_SA}=3
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=3
...    NRCELL-1:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-12:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=3
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=3
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=3
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=3

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

@{UE_4Scells_expect}
...    pcid:50, scellIdx:0
...    pcid:51, scellIdx:1
...    pcid:52, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:61, scellIdx:4
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{UE1_3Scells_expect}
...    pcid:50, scellIdx:0
...    pcid:51, scellIdx:1
...    pcid:52, scellIdx:2
...    pcid:60, scellIdx:3
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

@{UE2_3Scells_expect}
...    pcid:50, scellIdx:0
...    pcid:51, scellIdx:1
...    pcid:52, scellIdx:2
...    pcid:61, scellIdx:3
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

@{UE_del_3Scells_expect}
...    pcid:50, scellIdx:0
...    pcid:51, scellIdx:1
...    pcid:60, scellIdx:2
...    pcid:61, scellIdx:3
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

*** Test Cases ***
CB009855-ET-A010_B2a_Deactivation_5CC_CA_as_maxNumScellsDlFr1_limit_or_Scell_candidates_limit
    [Documentation]
    ...    1. The purpose of this test case is to validate the conditions to enable 3T + 2F CA and deactivation of 3T + 2F
    ...       on CA_n78(2A)-n41A-66A-n71A.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                   gNB
    ...                   Cell1    Cell2    Cell3    Cell4    Cell11    Cell12
    ...    Technology        TDD      TDD    TDD      TDD      FDD       FDD
    ...          Band        n78      n78    n41      n41      n66       n71
    ...     Bandwidth        100      100    80        80       20       20
    ...     Supercell        NO        No    No        NO      No        No
    ...            BF         No       No    No          NO          NO         No
    ...    Beam Refinement    No       No         No            No           No         No
    ...    numberOfTransmittedSsBlocks    1    1    1    1      1       1
    ...    pucchF3ModulationScheme    pi2bpsk    pi2bpsk    pi2bpsk    pi2bpsk    pi2bpsk    pi2bpsk
    ...    pucchF3MaxCodeRate    zeroDot08    zeroDot08    zeroDot08    zeroDot08    zeroDot08
    ...    weightForSCellSelection    80    70    60    50    45    40
    ...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
    ...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
    ...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
    ...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
    ...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
    ...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7
    ...    NRCELL-3:tddFrameStructure:frameStructureType=semiStatic
    ...    NRCELL-3:tddFrameStructure:guardPeriodLength=2Symbols
    ...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=3/7
    ...    NRCELL-4:tddFrameStructure:frameStructureType=tdlte
    ...    NRCELL-4:tddFrameStructure:guardPeriodLength=2Symbols
    ...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4
    ...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-3:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-4:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-12:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
    ...    3. Test Case Steps:
    ...         a. attach UE81 to cell1. trigger A1MR to add scell
    ...         b. online change NRBTS/NRCELL. maxNumSCellsDlFr1 to 3 for cell1.trigger A2 scell release of UE81, then
    ...            trigger A1 scelladd again for UE81.
    ...         c. attach UE82 to cell1. trigger A1MR to add scell
    ...         d. online change NRBTS/NRCELL. maxNumSCellsDlFr1 back to 4 for cell1.
    ...         e. trigger A2 scell release of UE81, then trigger A1 scelladd again for UE81
    ...         f. dettach UE82, attach UE82, trigger A1MR to add scell
    ...         g. Release UE81, UE82
    ...         h. online change: remove one NRREL of cell1(cell3; Physical layer cell ID:52; TDD band41)
    ...         i. attach UE81 to cell1, trigger A1MR to add scell
    ...         f. Release UE81
    ...    4. Expected Results:
    ...         a. UE81 is configured with 3T + 2F 5CC CA(Pcell--cell1+Scell-cell2,cell3,cell11,cell12). traffic is ok.
    ...         b. online change successfully.UE81 are configured with 3T + 1F CA(Pcell--cell1+Scell-cell2,cell3,cell11)
    ...         c. UE82 are configured with 3T + 1F CA(Pcell--cell1+Scell-cell2,cell3,cell12)
    ...         d. online change successfully.
    ...         e. UE81 are configured with 3T + 2F CA(Pcell--cell1+Scell-cell2,cell3,cell11,cell12)
    ...         f. UE82 are configured with 3T + 2F CA(Pcell--cell1+Scell-cell2,cell3,cell11,cell12)
    ...         g. Release UE81, UE82 successfully
    ...         h. online change successfully
    ...         i. UE81 are configured with 2T + 2F CA(Pcell--cell1+Scell-cell2,cell11,cell12)
    ...         f. Release UE81
    [Tags]    QC_268343   A010    CA_LABEL-TTFF(100Mhz_TDD_n78+100Mhz_TDD_n78+80Mhz_TDD_n41+20Mhz_FDD_n66+20Mhz_FDD_n71)
    Clear Counter files    True
    OnlineParamChange    ${parameter_covBasedA1_related}
    UE1 Check For Exist UE When maxNumSCellsDlFr1 From Four To Three
    UE2 Check For New UE When maxNumSCellsDlFr1 Is Three
    UE1 Check For Exist UE When maxNumSCellsDlFr1 From Three To Four
    UE2 Check For New UE When maxNumSCellsDlFr1 Is Four
    Check Counters    ${PM_Counters_Check}
    UE1 Check For New UE When NRREL Del
   # Check WireShark Log    ${CURDIR}${/}A2A_A_010${/}a2a.ini    wait_string=UEContextRelease::36
    [Teardown]    A10 TestTeardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71

Modify Cfg
    Update Cfg    ue_param id=${SA_UE1_ID} ue_nr_capabilities=${CB009855_A_Capa_5CC_n78_n78_n41_n66_n71}
    Update Cfg    ue_param id=${SA_UE2_ID} ue_nr_capabilities=${CB009855_A_Capa_5CC_n78_n78_n41_n66_n71}

Sa CA UE Register
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=${wait_timer}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}

Traffic Send Small
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE ${ue_id}: UDP UL

Traffic Send Large
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE ${ue_id}: UDP UL

trigger A2 MR to release one scell
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${carrierfreq}=648096    ${scell_index}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20 scell_rsrq=20
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToReleaseList{${scell_index}}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

SA CA UE Setup PDU Session
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=0.5    ${expect_regexp}=QoS Routing Table
    [Return]    ${RAN_UE_NGAP_ID[0]}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}
    ...    sleep_time=${wait_timer}
    ${RAN_UE_NGAP_ID}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    [Return]    ${RAN_UE_NGAP_ID}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=1
    ${RAN_UE_NGAP_ID}    SA CA UE Setup PDU Session    ue_id=${ue_id}

UE Scell Add With CoverBased
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${expect_regexp}=${UE_4Scells_expect}
    [Return]    ${RAN_UE_NGAP_ID}
    ${RAN_UE_NGAP_ID}    UE Register And PDU Session Setup    ue_id=${ue_id}
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=635232    pass_reg_ca=${expect_regexp}

UE Send A2 Trigger 4 Scells Release
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    trigger A2 MR to release one scell    ue_id=${ue_id}    carrierfreq=648096    scell_index=1
    trigger A2 MR to release one scell    ue_id=${ue_id}    carrierfreq=424090    scell_index=3
    trigger A2 MR to release one scell    ue_id=${ue_id}    carrierfreq=508110    scell_index=2
    trigger A2 MR to release one scell    ue_id=${ue_id}    carrierfreq=126750    scell_index=4

UE Send A2 Trigger 3 Scells Release
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    trigger A2 MR to release one scell    ue_id=${ue_id}    carrierfreq=648096    scell_index=1
    trigger A2 MR to release one scell    ue_id=${ue_id}    carrierfreq=424090    scell_index=3
    trigger A2 MR to release one scell    ue_id=${ue_id}    carrierfreq=508110    scell_index=2

UE Deregister From gNB
    [Arguments]    ${ue_id}=${SA_UE1_ID}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

A10 TestTeardown
    OnlineParamChange    ${Recover_A10}
    Common Test Teardown And Stop Capture Logs

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    #Should Be True    ${scell_tput}/1000 > 0

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

Verify Throughput When 4 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=5
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex-4

Verify Throughput When 3 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=4
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    fail_regexp=CellIndex-4

UE1 Check For Exist UE When maxNumSCellsDlFr1 From Four To Three
    ${RAN_UE_NGAP_ID_1}    UE Scell Add With CoverBased    ue_id=${SA_UE1_ID}
    Set Test Variable    \${RAN_UE_NGAP_ID_1}
    Traffic Send Large    ue_id=${SA_UE1_ID}
    Verify Throughput When 4 Scells    ue_id=${SA_UE1_ID}    Tput_dl=540
    OnlineParamChange    ${OnlineParam_Change_maxNumSCellsDlFr1_Value_3}
    UE Send A2 Trigger 4 Scells Release    ue_id=${SA_UE1_ID}
    UE Send A1 Trigger Scell Addition    ue_id=${SA_UE1_ID}    cellfreq=635232    pass_reg_ca=${UE1_3Scells_expect}
    Verify Throughput When 3 Scells    ue_id=${SA_UE1_ID}    Tput_dl=540

UE2 Check For New UE When maxNumSCellsDlFr1 Is Three
    ${RAN_UE_NGAP_ID_2}    UE Scell Add With CoverBased    ue_id=${SA_UE2_ID}    expect_regexp=${UE2_3Scells_expect}
    Set Test Variable    \${RAN_UE_NGAP_ID_2}
    Traffic Send Small    ue_id=${SA_UE2_ID}
    Verify Throughput When 3 Scells    ue_id=${SA_UE2_ID}    Tput_dl=270

UE1 Check For Exist UE When maxNumSCellsDlFr1 From Three To Four
    OnlineParamChange    ${OnlineParam_Change_maxNumSCellsDlFr1_Value_4}
    UE Send A2 Trigger 3 Scells Release    ue_id=${SA_UE1_ID}
    UE Send A1 Trigger Scell Addition    ue_id=${SA_UE1_ID}    cellfreq=635232    pass_reg_ca=${UE_4Scells_expect}
    Verify Throughput When 4 Scells    ue_id=${SA_UE1_ID}    Tput_dl=540

UE2 Check For New UE When maxNumSCellsDlFr1 Is Four
    UE Deregister From gNB    ue_id=${SA_UE2_ID}
    ${RAN_UE_NGAP_ID_3}    UE Scell Add With CoverBased    ue_id=${SA_UE2_ID}    expect_regexp=${UE_4Scells_expect}
    Set Test Variable    \${RAN_UE_NGAP_ID_3}
    Traffic Send Small    ue_id=${SA_UE2_ID}
    Verify Throughput When 4 Scells    ue_id=${SA_UE2_ID}    Tput_dl=270

UE1 Check For New UE When NRREL Del
    Release UEs    ue_type=all
    OnlineParamChange    ${OnlineParam_del_NRREL_3}
    ${RAN_UE_NGAP_ID_4}    UE Scell Add With CoverBased    ue_id=${SA_UE1_ID}    expect_regexp=${UE_del_3Scells_expect}
    Set Test Variable    \${RAN_UE_NGAP_ID_4}
    Traffic Send Large    ue_id=${SA_UE1_ID}
    Verify Throughput When 3 Scells    ue_id=${SA_UE1_ID}    Tput_dl=540
