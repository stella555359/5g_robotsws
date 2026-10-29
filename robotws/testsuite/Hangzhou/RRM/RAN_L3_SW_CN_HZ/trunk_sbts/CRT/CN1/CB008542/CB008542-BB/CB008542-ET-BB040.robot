*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1_TA    owner-jean.jing    release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${UTE_WIRESHARK_FLAG}    ${False}
@{PARAMS_IN_SWCONFIG_AP}    ${EnableSrsBasedBeamForming}=1
${EnableSrsBasedBeamForming}    0x70690
@{PARAMS_IN_SCF}
...    NRBTS:actChannelMapVal=Disabled
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:actCDrx=true
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELL-1:type0SearchSpaceConfigurationIndex=5
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-1:nrCellType=8DL4UL
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:filterCoeffSsbRsrq=fc4
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:actCDrx=false
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELL-2:type0SearchSpaceConfigurationIndex=5
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-2:filterCoeffSsbRsrq=fc4
...    NRCELL-2:prachConfigurationIndex=98
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=11
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-9:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-9:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-10:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-10:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-9:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-9:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-10:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-10:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-11:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-11:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-12:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-12:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-11:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-11:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-12:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-12:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1


...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1



${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa

@{PM_Counters_Check_BB040}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=3
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0

${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021    #The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028    #The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000    #RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000    #Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000    #Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
#The number of radio admission requests for 1 S-Cell in addition of PS-Cell.
#Updated to the PS-Cell whenever there is an admission request for the UE
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015    #The number of successful radio admissions for 1 Scell additions.
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006    #The number of radio admission request for S-Cells. Updated to the S-Cell.
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007    #The number of successful radio admissions for the S-Cell. Updated to the S-Cell.
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002    #The number of admission requests for NSA user
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003   #The number of successful radio admitted NSA users


@{OnlineParam_BB040}
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:absThreshSsbRsrpConsolidation=0
...    NRCELL-1:sMeasConfigSsbRsrp=0
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2:absThreshSsbRsrpConsolidation=0
...    NRCELL-2:sMeasConfigSsbRsrp=0
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:sMeasConfigSsbRsrp=0
...    NRCELL-11:filterCoeffSsbRsrp=fc4
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:absThreshSsbRsrpConsolidation=0
...    NRCELL-12:sMeasConfigSsbRsrp=0
...    NRCELL-12:filterCoeffSsbRsrp=fc4
...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-13:absThreshSsbRsrpConsolidation=0
...    NRCELL-13:sMeasConfigSsbRsrp=0
...    NRCELL-13:filterCoeffSsbRsrp=fc4
...    NRCELL-14:a3MeasEnabled=rsrp
...    NRCELL-14:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-14:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-14:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-14:absThreshSsbRsrpConsolidation=0
...    NRCELL-14:sMeasConfigSsbRsrp=0
...    NRCELL-14:filterCoeffSsbRsrp=fc4

@{OnlineParam_BB040_recover}
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:actHoOptimizationCa=false

${SA_Capa_perUE_Full_ue91}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC11843
...    41020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F10
...    18656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D9315444
...    39F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62
...    471E439F51CF9863CA1607038784FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C410
...    00006160561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B1713400388
...    2001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882
...    001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602083
...    A5D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C0
...    8902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C002
...    81C1401C0C01D00E000C0480080C07C120040000000200000401000000008000010040000100200000C01000008008000050040020080200
...    800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15A
...    CA5AC99AC05AC0DAC04AC08AC1DA0682000012CA48080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA480
...    80003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55174AAAA9545D2A8AA0B154162A8
...    3455298AA4D154062A8145526AAA0F1414178095028140A05028140A05028140A05028140A05028140018202018030080100210100200804
...    0300610080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C0182020040100801004354
...    3E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${Capa_LTE_ue91}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E268007104000000588817898180
...    70A00038820000042C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040
...    804808D00A001C041809A1682E41E24E8913639F0E24E8913639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448
...    931CF80681C6318C631830082000080404008020100C01840001008080100202018030C0002010100C01804030060100C018400010080801
...    0040200401000000000

*** Test Cases ***
CB008542-ET-BB040_Verify_NSA_A3_rsrp_intrafreq_intragNB_HO_from_covBasedA1TF_to_covBasedA1TF_withSRB3_actHoOptimizationCa_enabled
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         Purpose of this US is to validate successful intra-frequency mobility for the UE configured with FR1
    ...         TDD-FDD CA,interworking with SRB3 when actHoOptimizationCa=true
    ...    2. Test Case Steps:
    ...         Preconditions: NRCELL-2 has NRREL as scell_covbasedA1: NRCELL11
    ...                        NRCELL-1 has NRREL as scell_covbasedA1: NRCELL11
    ...         a. CA NSA UE92 attach to NR Cell 1 PCI 50
    ...         b. trigger A1 to add scell NRCELL-11 PCI 60.
    ...         b. trigger intrafreq intraGnb HO from NR cell 1 PCI 50 to NR cell 2 PCI 51
    ...         c. HO back from NR cell 2 PCI 51 to NR cell 1 PCI 50
    ...         e. UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on message: SgNBAdditionRequestAcknowledge
    ...                 check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check srb-Identity = 3
    ...         Step b: FDD scell added. Traffic share on scell.
    ...                 check eventId=1
    ...                 check sCellConfigCommon.physCellId = 60
    ...                 check sCellIndex = 9
    ...         Step c: HO from NR cell 1 PCI 50 to NR cell 2 PCI 51 successfuly. Pcell and scell tput normal
    ...                 IE: on RRC:
    ...                 check nr-rrc.physCell=51 && nr-rrc.physCellId == 60
    ...                 check nr-rrc.sCellIndex = 9
    ...                 check drx-Config = 1
    ...         Step d: HO back from NR cell 2 PCI 51 to NR cell 1 PCI 50 successfuly. Pcell and scell tput normal
    ...                 IE: on RRC:
    ...                 check nr-rrc.physCell=50 && nr-rrc.physCellId == 60
    ...                 check nr-rrc.sCellIndex = 9
    ...         Step e: ALL call can be released successfully.
	[Tags]    QC_164086    BB040    jejing
    Before HO UE precondition
	HO should be succeed
	HO should be succeed    gNB_Target_PCI=50
	Stop Traffic And Detach Ue
	check wireshark log    ${CURDIR}${/}a2a_BB040${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB040}
	[Teardown]    TestTearDown to restore scf to default

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

OnlineParamChange
    [Arguments]  ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA

NSA CA UE Attach To Cell
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full_ue91}    ${Capa_LTE_ue91}
    NSA UE attach    ${ue_id}    ${cell_id}

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Start RRC Log    NSA_UE${ue_id}_covBaseA1_scelladd
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=120
    ...   pass_regexp=SCellIndex 9 activated successfully

Stop Traffic And Detach Ue
    Stop Traffic And Detach Ue for UE91

Stop Traffic And Detach Ue for UE91
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=ul trf_id=1
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=dl trf_id=4
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=dl trf_id=5
    Execute Egate Command    ue_detach id=91    UEC-1: UE91: detached

Send Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1   UE ${ue_id}: UDP UL

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 250
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 50
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>200

Update UE capa
    [Arguments]    ${ue_id}=91    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

Before HO UE precondition
	Clear Counter Files
    OnlineParamChange    ${OnlineParam_BB040}
    NSA CA UE Attach To Cell
	Add gNB Cell1 As Scell By A1
	Send Throuput
	Verify Throuput on Pscell and Scell

HO should be succeed
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910    ${gNB_Target_PCI}=51    ${gNBcell_Target}=2
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${gNB_Target_PCI}
    ...    nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    physCellId ${gNB_Target_PCI}
    Verify Throuput on Pscell and Scell

TestTearDown to restore scf to default
    OnlineParamChange    ${OnlineParam_BB040_recover}
    Common Test Teardown And Stop Capture Logs


