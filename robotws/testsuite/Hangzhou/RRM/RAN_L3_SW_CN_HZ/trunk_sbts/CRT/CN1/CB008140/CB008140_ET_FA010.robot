*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN1_SG14
...    owner-jun.3.ye    release-SBTS23R3    CRT    RAN_5G_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}


@{LOLO_Golden_Changes_GNB1}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{LOLO_Golden_Changes_GNB2}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1


@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{LOLO_Golden_Changes_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{LOLO_Golden_Changes_GNB2}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRBTS:actFdmEnhancedScheduling=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-1:maxNumScellsDlFr1=3
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:actPciBasedCsiImRandomization=false
...    NRCELL-1:actPerCsiReportBundlingTddFr1=false
...    NRCELL-1:reqMinNumPuschPrb=253

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
@{PARAMS_FOR_GNB2}
...    @{AP_Limitation}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-3:gscnOrSsPbchArfcn=8055
...    NRCELL-3:actBeamforming=true
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=10
...    NRCELL-11:weightForSCellSelection=40
...    NRCELL-12:weightForSCellSelection=20

#AP_Limitation: scell csiReportPeriodicity should less or equal than pcell
@{AP_Limitation}
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots80

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

${GNB_DU_SCELL_3_ADMI_REQ_SA}    M55139C03001
${IGNB_CA_ATT_3_SCELL_SA}    M55118C11003
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001   M55175C00001   #Obsolete, replace with M55199C00001
${IGNB_CA_ADD_REQ_SA_ADJ}    M55199C00001
${IGNB_CA_ATT_3_SCELL_SA_SUCC}    M55118C11006
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502

${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002

@{PM_Counters_Check_priGNB}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=2
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_3_SCELL_SA}=2
...    NRCELL-1:NCAC:${IGNB_CA_ATT_3_SCELL_SA_SUCC}=2

@{PM_Counters_Check_extGNB}
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=0
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRBTS-2:AGNBM:${IGNB_CA_ADD_REQ_SA_ADJ}=2

@{unexpectedMeasurementInfor}
...    eventId eventA1
...    physCellId 53
...    measObjectId 4
...    ssbFrequency 153370

@{unexpectedA1Infor}
...    eventId eventA1

@{activatedSuccessfullyAirphoneCheck}
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

*** Test Cases ***
CB008140_ET_FA010_Verify_Successful_Partial_SCell_addition_with_partial_SCell_candidates_are_admitted_at_prime-gNB-DU_TTFF_PUCCH
    [Documentation]
    ...    this case is to test successful partial SCell addition with partial scell candidates are admitted at -prime-gNB-DU due to pucch resources
    ...    reached for inter-gNB with 4CC(TDD-TDD-FDD-FDD) DL CA.
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_17899, fully covered
    ...    It is about CB008140-FA#B1 CB008140-FA#B3: Partial SCell addition success for one SA connection when there are more than one SCell
    ...    candidate to be added partial SCell candidates are admitted at prime-gNB-DU
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8055 chBw=100MHz weightForSCellSelection=10
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz weightForSCellSelection=10
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz weightForSCellSelection=40
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz weightForSCellSelection=20
    ...    2.Test Case Steps:
    ...         Step a. UE1-28 Register And PDU Session Setup On Cell1_1
    ...         Step b. UE28 Register And PDU Session Setup On Cell1_1
    ...         Step c. UE28 Run Traffic And Verify Throughput
    ...         Step d. UE28 Send A1 Trigger 4CC Scell Activation And Verify Throughput
    ...         Step e. Send A2 release UE28 all SCell
    ...         Step f. Ue29 Register And PDU Session Setup Without Scell Addition
    ...         Step g. UE29 Send A1 Trigger 4CC Scell Activation
    ...         Step h. UE29 Run Traffic And Verify Throughput
    ...         Step i. Send A2 release UE29 all SCell
    ...         Step j. stop all UE traffic and deregister UE
    ...         Step k. wireshark logs and counters check
    ...    3. Expected Results:
    ...         Step a: UE1-28 Register And PDU Session Setup On Cell1_1 is Successfully
    ...         Step b: UE28 Register And PDU Session Setup On Cell1_1 is Successfully
    ...         Step c. UE28 Run Traffic And Verify Throughput is ok
    ...         Step d. UE28 adds Scell CELL2_3 and CELL2_11 successfully, fails to setup CELL2_12 as Scell with cause No Radio Resources
    ...         Available due to PUCCH resource not enough And Verify Throughput is OK
    ...         Step e: UE28 all SCell release is Successfully, UE is in PCell only state.
    ...         Step f: Ue29 Register And PDU Session Setup Without Scell Addition is Successfully
    ...         Step g: UE29 adds Scell CELL2_3 successfully,fails to setup CELL2_11 and CELL2_12 as Scell with cause No Radio Resources
    ...         Available due to PUCCH resource not enough
    ...         Step h: UE29 Run Traffic And Verify Throughput is OK
    ...         Step i: UE29 all SCell release is Successfully
    ...         Step j. stop all UE traffic and deregister UE is OK
    ...         Step k. wireshark logs and counters check:
    ...           1).
    ...         1. gNB-1-CU sends to gNB-1-DU the F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message asking to prepare Cell2_3, Cell2_11 and
    ...         Cell2_12 addition.
    ...         2. gNB-1-DU replies with the F1AP: IGNB CA UE CONTEXT MODIFICATION RESPONSE.
    ...         3. gNB-1-CU sends to gNB-2-CU XnAP: IGNB CA ADDITION REQUEST message.
    ...         4. gNB-2-CU forwards the request to gNB-2-DU via F1AP: IGNB CA UE CONTEXT SETUP REQUEST message.
    ...         5. gNB-2-DU replies to gNB-2-CU with an F1AP: IGNB CA UE CONTEXT SETUP RESPONSE message
    ...         6. gNB-2-CU replies to gNB-1-CU by sending the XnAP: IGNB-CA UE ADDITION REQUEST ACKNOWLEDGE message
    ...         7. gNB-1-CU forwards the received SCells configuration to gNB-1-DU via F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message
    ...         8.gNB-1-DU allocates PUCCH resource(s) to Cell2_3 and Cell2_11 (only Cell2_3 for step 7) successfully, and failed to allocate PUCCH
    ...         resource(s) for Cell2_12 (Cell2_11 and Cell2_12 for step 7).
    ...         gNB-1-DU sends response to gNB-1-CU via F1AP: IGNB CA UE CONTEXT MODIFICATON RESPONSE message. This message carries the PUCCH
    ...         configuration Information for Cell2_3 and Cell2_11 (only Cell2_3 for step 7) and with Cell2_12 (Cell2_11 and Cell2_12 for step 7)
    ...         in the 'IgNB-CA SCell Failed to Setup List' with cause "RadioNetworkLayer: No Radio Resources Available".
    ...         9.gNB-1-CU sends to gNB-2-CU the XnAP: IGNB CA UE CONTEXT MODIFICATION REQUEST message carrying the PUCCH Configuration Information
    ...         received from gNB-1-DU and with SCels failed be allocated with PUCCH resource in 'SCell to Be Removed List'.
    ...         10.gNB-2-CU forwards the message received from gNB-1-CU to gNB-2-DU via F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message,
    ...         SCell rejected by gNB-1-DU are in 'IgNB-CA SCell to Be Removed List'.
    ...         11. gNB-2-DU replies with the F1AP: IGNB CA UE CONTEXT MODIFICATION RESPONSE message
    ...         12. gNB-2-CU replies to gNB-1-CU sending the XnAP: IGNB CA MODIFICATION REQUEST ACKNOWLEDGE message confirming SCells addition, do
    ...         corresponding rollback for the rejected SCells.
    ...         13. gNB-1-CU sends to gNB-1-DU F1AP: DL RRC MESSAGE TRANSFER/UL RRC MESSAGE TRANSFER with RRC RECONFIGURATION message.
    ...         14. gNB-1-CU sends to gNB-1-DU the F1AP:UE CONTEXT MODIFICATION REQUEST message including the RRCReconfigurationCompleteIndicator
    ...         IE, to which gNB-1-DU replies with the F1AP: UE CONTEXT MODIFICATION RESPONSE message, as per legacy handling.
    ...         15. Finally, gNB-1-CU triggers the F1AP UE Context Modification procedure to fetch the current UE RRC configuration by sending to
    ...         gNB-1-DU the F1AP: UE CONTEXT MODIFICATION REQUEST message including the GNB-DU Configuration Query IE to which gNB-1-DU replies
    ...         with the F1AP: UE CONTEXT MODIFICATION RESPONSE message, as per legacy handling.
    ...           2).
    ...            M55139C03001 GNB_DU_SCELL_3_ADMI_REQ_SA for cell1_1
    ...            M55118C11003 IGNB_CA_ATT_3_SCELL_SA for Cell1_1
    ...            M55138C03501 IGNB_CA_SCELL_ADMI_REQ_SA and M55138C03502 IGNB_CA_SCELL_ADMI_SUCC_SA for Cell2_3,Cell2_11 and Cell2_12
    ...            M55175C00001 IGNB_CA_ADD_REQ_SA_NRADJ for gNB-1
    ...            M55139C01001 GNB_DU_SCELL_ADMI_REQ_SA forCell2_3,Cell2_11 and Cell2_12
    ...            M55118C11006 IGNB_CA_ATT_3_SCELL_SA_SUCC for Cell1_1
    ...            M55139C01502 GNB_DU_SCELL_2_ADMI_SUCC_SA for Cell1_1
    ...            M55139C01004 GNB_DU_SCELL_1_ADMI_SUCC_SA for Cell1_1
    ...            M55139C01002 GNB_DU_SCELL_ADMI_SUCC_SA for Cell2_3 twice and Cell2_11 once and Cell2_12 0 time

    [Tags]    QC_252592    FA010
    Clear Counter Files for 2GNB
    Trigger UE-1-28 Register
    UE28 Register and Scell Addition and Scell release
    UE29 Register and Scell Addition and Scell release
    Stop PDU and release UE
    Check Counters    ${PM_Counters_Check_priGNB}
    Check Counters GNB2    ${PM_Counters_Check_extGNB}
    Check WireShark Log    ${CURDIR}${/}A2A_FA_010${/}a2a.ini    wait_string=UEContextModificationResponse::75
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_FA_010${/}a2a_gnb2.ini    wait_string=IgNBCAReleaseRequestAcknowledge::2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    ${set_cell3_gscn}    catenate
    ...    set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=653400:653400
    ...    mandatory_for_activation=off gscn=8055
    Update Cfg    ${set_cell3_gscn}

Trigger UE-1-28 Register
    FOR    ${id}    IN RANGE    1    28
        Ue Register And PDU Session Setup Without Scell Addition    ue_id=${id}    gateway=${id}    enb_id=2    cell_id=1
    END

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Regist
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Run Keywords    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=${ue_id}    Tput_dl=410    Tput_ul=45

Verify Throughput With 3CC
    [Arguments]    ${ue_id}=1    ${Tput_dl}=270    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    #Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    ${Pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=current
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=current
    Should Be True    ${Pcell_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000>${Tput_dl}
    Should Be True    ${dl_throughput}/1000>100
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=270    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}


Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

UE28 Send A1 Trigger 3CC Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${scell1pci}=52    ${scell2pci}=60    ${scell3pci}=61
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=52
    ...    pass_regexp=${activatedSuccessfullyAirphoneCheck}    fail_regexp=${unexpectedMeasurementInfor}
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId${scell2pci}
    Should Not Contain    ${ret1}    sCellToAddModList{{sCellIndex3,sCellConfigCommon{physCellId${scell3pci}
    Sleep    5s    #wait all sysinfo
    Verify Throughput With 3CC        ue_id=${ue_id}    Tput_dl=410    Tput_ul=45

Send A2 release UE28 all SCell
    [Arguments]    ${ue_id}=1    ${carrierfreq1}=653376    ${carrierfreq2}=368430    ${sleep_time}=15s
    ${meas_id1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq1}    event_type=A2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id1} event=A2 scell=1 scell_rsrp=30 scell_rsrq=0
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToReleaseList{1}
    ${meas_id2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq2}    event_type=A2
    ${ret2}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id2} event=A2 scell=2 scell_rsrp=30 scell_rsrq=0
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret2}=    Remove String    ${ret2}    \r    \n    ${SPACE}
    Should Contain    ${ret2}    sCellToReleaseList{2}

UE29 Send A1 Trigger 2CC Scell Activation
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${scell1pci}=52    ${scell2pci}=60
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=52
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone    fail_regexp=${unexpectedA1Infor}
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Should Not Contain    ${ret1}    sCellToAddModList{{sCellIndex2,sCellConfigCommon{physCellId${scell2pci}

UE29 Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Run Keywords    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=${ue_id}    Tput_dl=360    Tput_ul=45

Send A2 release UE29 all SCell
    [Arguments]    ${ue_id}=1    ${carrierfreq}=653376    ${sleep_time}=15s
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=1 scell_rsrp=30 scell_rsrq=0
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToReleaseList{1}

Stop PDU and release UE
    Execute Egate Command    trf_data_stop ue=29,30 pdu=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Release UEs    ue_type=all

UE28 Register and Scell Addition and Scell release
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=28    enb_id=2    cell_id=1
    Run Traffic And Verify Throughput    ue_id=28
    UE28 Send A1 Trigger 3CC Scell Activation And Verify Throughput    ue_id=28
    Send A2 release UE28 all SCell    ue_id=28

UE29 Register and Scell Addition and Scell release
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=29    enb_id=2    cell_id=1
    UE29 Send A1 Trigger 2CC Scell Activation    ue_id=29
    UE29 Run Traffic And Verify Throughput    ue_id=29
    Send A2 release UE29 all SCell    ue_id=29