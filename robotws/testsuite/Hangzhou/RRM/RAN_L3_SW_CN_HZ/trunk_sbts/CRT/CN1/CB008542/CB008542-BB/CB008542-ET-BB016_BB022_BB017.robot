*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  TestTearDown to restore scf to default
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-lingyan.zhou    release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${UTE_WIRESHARK_FLAG}  ${False}
${BTS_STARTUP_RETRY}    2
@{PARAMS_IN_SWCONFIG_AP}  ${EnableSrsBasedBeamForming}=1
${EnableSrsBasedBeamForming}    0x70690
${candidate_cells_mn_hex_for_menb_ho_to_PCI51}    0926A6002198
${candidate_cells_mn_hex_for_menb_ho_to_PCI50}    091FABF82190
@{PARAMS_IN_SCF}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-13/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=1
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:lcrId=13
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-10:lcrId=12
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf4
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-1/NRHOIF-1:scs=30 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=633216
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-2/NRHOIF-1:cellDepType=NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf4
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-2/NRHOIF-1:scs=30 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=518910
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:weightForSCellSelection=90
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8


${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd


@{OnlineParam_BB016}
...    NRBTS:srb3SupportEnabled=false
...    NRCELL-2:actCDrx=false

@{OnlineParam_BB022}
...    NRBTS:srb3SupportEnabled=true
...    NRCELL-2:actCDrx=true

#delete cell-2 NRREL cell-12
@{OnlineParam_BB017}
...    delete:NRCELL-2/NRREL-2

@{OnlineParam_BB017_recover}
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3

@{PM_Counters_Check_BB016}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-2:NX2CC:${X2_SGNB_MOD_REQ_ACK_SNT}=1
...    NRCELL-2:NX2CC:${X2_SGNB_MOD_REQ_RECEIVD}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}=0
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:NX2CC:${X2_SGNB_MOD_REQ_ACK_SNT}=1
...    NRCELL-1:NX2CC:${X2_SGNB_MOD_REQ_RECEIVD}=1

@{PM_Counters_Check_BB022}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:NX2CC:${X2_SGNB_ADD_REQ_INTR_MENB_HO}=1
...    NRCELL-1:NX2CC:${X2_SGNB_ADD_REQ_ACK_INTRENB_HO}=1
...    NRCELL-2:NX2CC:${X2_SGNB_ADD_REQ_INTR_MENB_HO}=1
...    NRCELL-2:NX2CC:${X2_SGNB_ADD_REQ_ACK_INTRENB_HO}=1

@{PM_Counters_Check_BB017}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0

${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021    #The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028    #The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000    #RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000    #Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000    #Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
#The number of radio admission requests for 1 S-Cell in addition of PS-Cell.
#Updated to the PS-Cell whenever there is an admission request for the UE
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015    #The number of successful radio admissions for 1 Scell additions.
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503    #Nbr of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for NSA
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504
#Nbr of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for NSA
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006    #The number of radio admission request for S-Cells. Updated to the S-Cell.
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007    #The number of successful radio admissions for the S-Cell. Updated to the S-Cell.
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002    #The number of admission requests for NSA user
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003   #The number of successful radio admitted NSA users
${X2_SGNB_MOD_REQ_RECEIVD}    M55112C04001    #Number of incoming SGNB MODIFICATION REQUEST received from LTE eNB
${X2_SGNB_MOD_REQ_ACK_SNT}    M55112C04002    #Number of outgoing SGNB MODIFICATION REQUEST ACKNOWLEDGE sent to LTE eNB
${X2_SGNB_ADD_REQ_INTR_MENB_HO}    M55112C03501    #Number of incoming SGNB ADDITION REQUEST received from LTE eNB upon Inter-MeNB HO trigger
${X2_SGNB_ADD_REQ_ACK_INTRENB_HO}    M55112C03502
#Number of successful SgNB Addition Preparation procedures (number of SGNB ADDITION ACKNOWLEDGE sent to LTE eNB) upon Inter-MeNB HO trigger

${SA_Capa_perUE_Full_ue92}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387E0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7
...    C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64C55890E7D813E238
...    F1891C790E7D473E618F28581C0E1E13FB000000FEC00000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C7
...    3E618F28581C0E1E0B801FF800E007FE00078001C0A836236B04610D04083C40E0656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B038
...    1C3C27FFC00001FFF000000F0003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E20800
...    0010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D00
...    0E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E
...    23000711800001058158B89A001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C0410B42EC1F0A244D8E7C3851226C73
...    E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E04
...    4810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E06012803800301200203
...    01F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E00800400000010
...    0001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681
...    A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132C
...    A480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C5
...    090178095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080100202018030080600C101
...    00C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202224262
...    8303236383A3E424A4C4E5052545A5E828305A

${Capa_LTE_ue92}    SEPARATOR=
...    a11ff83bc4c0c03850001c46000000162205e260601c4d000e230000000b1102f130300e26800710400000058881789818070a00038820000
...    002c040bc4c0c03882001c46000002160205e360601c46000e208007104000010580817898180713400385000000c2c040804808d00a001c0
...    41809a1e80b907893a244d8e7c3893a244d8e7c3893a244d8e7c3893a244d8e7c3893a24498e7d1a7448912639f449d1224c73e01a0718c63
...    18c60c02080002010100200804030061000040202004008080600c3000080404030060100c018040300610000402020040100801004000000
...    00

#ue capability BC support T41+T66, not support T78+T66
${Capa_LTE_ue92_BB017}    SEPARATOR=
...    A11FF833C4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E140007104000000580817898180710400388C0000
...    042C040BC6C0C0388C001C41000E208000020B0102F130300E1400070A000001858081009011A014003808301344D005083449D1226C73E1C
...    49D1226C73E1C49D1226C73E1C49D1224C73E8D3A2448931CFA24E8912639F000B030C6318C66010400010080801004020180308000201010
...    0200404030061800040202018030080600C02018030800020101002008040080200000000

*** Test Cases ***
CB008542-ET-BB016_Verify_IntraMeNB_HO_without_SgNB_change_with_PSCell_change_interFreq_from_nonCA_to_CA_with_covBase
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.US CB008542-BB#B5A: Intra-MeNB LTE HO without SgNB change triggering UE reconfiguration with PSCell
    ...           change (CA + NSA Opt 3x)
    ...    2. Test Case Steps:
    ...         Preconditions: NRCELL-2 has NRREL as scell_covbasedA1: NRCELL12, NRCELL13.
    ...                        NRCELL-1 has NRREL as scell_covbasedA1: NRCELL11, NRCELL12, NRCELL13.
     ...        a. CA NSA UE92 attach to NR Cell 1 PCI 50 and no scell is added as no A1.
    ...         b. trigger intra-eNB HO with PScell change to eNB 1 cell 2 and gNB NR Cell 2 PCI 51
    ...         c. Trigger A1 event to add scell PCI 61.
    ...         d. Trigger intra-eNB HO back to NR Cell 1 PCI 50 and no scell is added as no A1.
    ...         e. CA  NSA UE92 Detach.
    ...    3. Expected Results:
    ...         Step a: UE92 no scell added. Traffic is normal.
    ...         Step b: UE92 HO successfully. Traffic is normal. A1 of scell add is configured to UE.
    ...         Step c:  After A1 event, scell PCI 61 added successfully.
    ...                 Traffic is normal.A2 of scell release is configured to UE
    ...         Step d: HO back successfully. UE92 no scell added. Traffic is normal.
	[Tags]    QC_164121    BB016    zhoulingyan
    Precondition UE setting with OnlineParameter Moidification    92    ${OnlineParam_BB016}
	NSA UE attach    92    1
    eNB HO with PScellChange
    Add gNB Cell1 As Scell By A1
    Verify Throuput on Pscell and Scell
    eNB HO with PScellChange    92    1    1    50    1    ${candidate_cells_mn_hex_for_menb_ho_to_PCI50}
    Verify Throuput on Pscell
    NSA UE Detach From GNB
	check wireshark log    ${CURDIR}${/}a2a_BB016${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB016}


CB008542-ET-BB022_Verify_InterMeNB_interFreq_HO_without_SgNB_change_with_PSCell_change_interFreq_from_CA_to_CA_with_covBase
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.US CB008542-BB#B5A: Intra-MeNB LTE HO without SgNB change triggering UE reconfiguration with PSCell
    ...           change (CA + NSA Opt 3x)
    ...    2. Test Case Steps:
    ...         Preconditions: NRCELL-2 has NRREL as scell_covbasedA1: NRCELL12
    ...                        NRCELL-1 has NRREL as scell_covbasedA1: NRCELL12
     ...        a. CA NSA UE92 attach to NR Cell 1 PCI 50 and trigger A1 to add scell NRCELL-12 PCI 61.
    ...         b. trigger inter-eNB HO inter-freq with PScell change to eNB 11 cell 1 and gNB NR Cell 2 PCI 51
    ...         c. Trigger A1 event to add scell PCI 61.
    ...         d. Trigger inter-eNB HO inter-freq HO back to NR Cell 1 PCI 50 and trigger A1 to add scell NRCELL-12 PCI 61
    ...         e. CA  NSA UE92 Detach.
    ...    3. Expected Results:
    ...         Step a: UE92 scell added. Traffic is normal.
    ...         Step b: UE92 HO successfully. Traffic is normal. A1 of scell add is configured to UE.
    ...         Step c:  After A1 event, scell PCI 61 added successfully.
    ...                 Traffic is normal.A2 of scell release is configured to UE
    ...         Step d: HO back successfully. UE92 scell added. Traffic is normal.
	[Tags]    QC_164096    BB022    zhoulingyan
    Precondition UE setting with OnlineParameter Moidification
	NSA UE attach    92    1
	Add gNB Cell1 As Scell By A1 and traffic normal    92    518910
    MeNB1 interFreq HO to MeNB11 with PScellChange from PCI 50 to PCI 51
    Add gNB Cell1 As Scell By A1 and traffic normal
    MeNB11 interFreq HO to MeNB1 with PScellChange from PCI 51 to PCI 50
    Add gNB Cell1 As Scell By A1 and traffic normal    92    518910
    NSA UE Detach From GNB
	check wireshark log    ${CURDIR}${/}a2a_BB022${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB022}

CB008542-ET-BB017_Verify_IntraMeNB_HO_with_PSCell_change_interFreq_from_covBase_ca_to_covBaseCA_but_no_A1_as_not_support_CA_BC
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         The purpose of this test case is to check following scenarios:
    ...           Verify Intra MeNB Handover with PSCell change UE add scell failure on the target PSCell due to
    ...           allowedBC-ListMRDC not including gNB supported CA band combination with FDD SCell.
    ...    2. Test Case Steps:
    ...         Preconditions: NRCELL-2 has NRREL as scell: NRCELL11,
    ...                        NRCELL-1 has NRREL as scell: NRCELL11,
    ...         a. CA NSA UE92 attach to NR Cell 1 PCI 50, A1 configured
    ...         b. trigger A1, scell 11 added.
    ...         c. trigger intra-eNB HO with PScell change to eNB 1 cell 2 and gNB NR Cell 2 PCI 51
    ...         d. Target pcell don't have support BC of UE,  there is no A1 configured
    ...         e. UE deattch.
    ...    3. Expected Results:
    ...         Step a: CA NSA UE92 attach to NR Cell 1 PCI 50, A1 configured.
    ...         Step b: UE92 scell added successfully. Traffic is normal.
    ...         Step c: UE92 HO successfully. Traffic is normal.
    ...         Step d: no A1 configured.
    ...         Step e: ue is OFF.
	[Tags]    QC_164088    BB017    jejing
	Precondition UE setting with OnlineParameter Moidification    Online_Param=${OnlineParam_BB017}    Capa_LTE=${Capa_LTE_ue92_BB017}
	NSA UE attach    92    1
    Add gNB Cell1 As Scell By A1    92    518910    120    120
    eNB HO with PScellChange
    Check No A1 config
	check wireshark log    ${CURDIR}${/}a2a_BB017${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB017}
	[Teardown]    TestTearDown BB017

*** Keywords ***
TestTearDown to restore scf to default
    OnlineParamChange    ${OnlineParam_BB016}
    Common Test Teardown And Stop Capture Logs

MeNB11 interFreq HO to MeNB1 with PScellChange from PCI 51 to PCI 50
    eNB interFreq HO with PScellChange    92    1    1    50    1    ${candidate_cells_mn_hex_for_menb_ho_to_PCI50}

MeNB1 interFreq HO to MeNB11 with PScellChange from PCI 50 to PCI 51
    eNB interFreq HO with PScellChange

eNB HO with PScellChange
    [Arguments]    ${ue_id}=92    ${enb_id}=1    ${enbcell_Target}=2    ${gNB_Target_PCI}=51    ${gNBcell_Target}=2
    ...    ${candidate_cells_mn_hex_for_menb_ho}=${candidate_cells_mn_hex_for_menb_ho_to_PCI51}
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${enbcell_Target} allow_endc=on
    Execute Egate Command    ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
    ${ret1}=    Execute Egate Command    ue_ho id=${ue_id} enb=${enb_id} ho_mode=INTRA_LTE cell=${enbcell_Target}
    ...    handover from
    Should Contain    ${ret1}    physCellId ${gNB_Target_PCI}
    Should Contain    ${ret1}    Proxy (eNB 2 cell ${gNBcell_Target}) reported successful RA

eNB interFreq HO with PScellChange
    [Arguments]    ${ue_id}=92    ${enb_id}=11    ${enbcell_Target}=1    ${gNB_Target_PCI}=51    ${gNBcell_Target}=2
    ...    ${candidate_cells_mn_hex_for_menb_ho}=${candidate_cells_mn_hex_for_menb_ho_to_PCI51}
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:19
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} by=enb cause=RN_action_desirable_for_radio_reasons
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${enbcell_Target} allow_endc=on
    Execute Egate Command    ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${ret1}=    Execute Egate Command    ue_ho id=${ue_id} enb=${enb_id} ho_mode=INTRA_LTE cell=${enbcell_Target}
    ...    handover from
    Should Contain    ${ret1}    physCellId ${gNB_Target_PCI}
    Should Contain    ${ret1}    Proxy (eNB 2 cell ${gNBcell_Target}) reported successful RA
    Execute Egate Command    ue_enb_endc_param id=${ue_id} reset

Precondition UE setting with OnlineParameter Moidification
    [Arguments]    ${ue_id}=92    ${Online_Param}=${OnlineParam_BB022}    ${SA_Capa_perUE_Full}=${SA_Capa_perUE_Full_ue92}
    ...    ${Capa_LTE}=${Capa_LTE_ue92}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${Capa_LTE}
    Execute Egate Command    ue_enb_endc_param id=${ue_id} reset
    Execute Egate Command    enb_endc_param id=1 reset
    Execute Egate Command    enb_endc_param id=11 reset
    Execute Egate Command    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=1
    OnlineParamChange    ${Online_Param}
	Clear Counter Files

Modify Cfg
    ${cmd}    catenate    set_cell id=1 enb=11 eci=0x1234701 pci=7:0 tac=222 proxy=$CONTAINER_IP:12217|$CONTAINER_IP:8887
    ...  earfcn=2200:20200 mandatory_for_activation=off
    Update Cfg    ${cmd}

OnlineParamChange
  [Arguments]  ${Online_Param}
  Delta Commission Parameters  ${Online_Param}
  Cells Should Be Onair    check_sib=${False}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F    ue_count=1

NSA UE attach
    [Arguments]    ${ue_id}=92    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA
    Execute Egate Command    debug_log level=4
    Send Throuput    ${ue_id}
    Verify Throuput on Pscell    ${ue_id}

Add gNB Cell1 As Scell By A1 and traffic normal
    [Arguments]    ${ue_id}=92    ${carrierfreq}=633216    ${srsrp_nr}=120    ${srsrq_nr}=120    ${pcell_dl}=235    ${scell_dl}=70    ${ul}=8
    Add gNB Cell1 As Scell By A1    ${ue_id}    ${carrierfreq}    ${srsrp_nr}     ${srsrq_nr}
    Verify Throuput on Pscell and Scell    ${ue_id}    ${pcell_dl}    ${scell_dl}    ${ul}

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=92    ${carrierfreq}=633216    ${srsrp_nr}=120    ${srsrq_nr}=120
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Start RRC Log    NSA_UE${ue_id}_covBaseA1_scelladd
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...   pass_regexp=SCellIndex 9 activated successfully
    Get RRC Log

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=92    ${pcell_dl}=235    ${scell_dl}=70    ${ul}=8
    sleep    10s     #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > ${pcell_dl}
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > ${scell_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${ul}


Stop Traffic
    [Arguments]    ${ue_id}=92
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=4
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=ul trf_id=1

NSA UE Detach From GNB
    [Arguments]    ${ue_id}=92
    Stop Traffic    ${ue_id}
    Execute Egate Command  ue_detach id=${ue_id}    UE IS OFF



Send Throuput
    [Arguments]    ${ue_id}=92
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=92    ${pcell_dl}=235    ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>${pcell_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${ul}

Update UE capa
    [Arguments]    ${ue_id}=91    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

Check No A1 config
    [Arguments]    ${ue_id}=92
    ${ret1}=    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...    DETAILED INFO
    Should Not Contain    ${ret1}    EventA1

TestTearDown BB017
    OnlineParamChange    ${OnlineParam_BB017_recover}
    Common Test Teardown And Stop Capture Logs
