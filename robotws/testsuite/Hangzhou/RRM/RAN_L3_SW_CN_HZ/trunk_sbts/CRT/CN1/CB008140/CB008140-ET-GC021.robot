*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_FDD    SBTS00    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...            owner-jean.jing    team-jazz    release-SBTS23R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
${rdEnableUeMappingRemovalFromCpIf}    0x89001E=1

@{PARAMS_IN_SWCONFIG}
...    ${rdEnableUeMappingRemovalFromCpIf}

@{PARAMS_IN_SWCONFIG_GNB2}
...    ${rdEnableUeMappingRemovalFromCpIf}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{gscn_Arfcn}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:actInterGnbCa=DLOnly

@{PARAMS_FOR_GNB1}
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
...    NRCELL-11:maxNumScellsDlFr1=3
...    NRCELL-11:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRCELL-11:a5MeasEnabled=rsrpCombined
...    NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-11:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-11:a5MeasSsbRsrq:a5Threshold1SsbRsrq=50
...    NRCELL-11:a5MeasSsbRsrq:a5Threshold2SsbRsrq=70
...    NRCELL-11:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=364000
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:ssbFrequency=363850
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-14:ssbFrequency=153370
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRMOPR_SA-1:a5MeasEnabled=rsrp
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRCELL-13:a5MeasEnabled=rsrq
...    NRCELL-13:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-13:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-13:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-13:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-13:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-13:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-13:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-13:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=363850
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:ssbFrequency=373970
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=2
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-11:gNbId=1
...    NRCELL-13/NRREL-11:gNbIdLength=22
...    NRCELL-13/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-11:lcrId=11
...    NRCELL-13/NRREL-11:removeNotAllowed=false
...    NRCELL-13/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{gscn_Arfcn}
...    NRCELL-13:gscnOrSsPbchArfcn=4547
...    NRCELL-13/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=364000
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=345000

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

@{PM_Counters_Check_PRIM}
...    NRBTS-1:${ATT_INTER_GNB_HO_SLICE}=1
...    NRBTS-1:${HO_REQ_PDU_SESS_RES_SENT_SLICE}=1
...    NRBTS-1:${SUCC_OG_INTER_GNB_HO_SLICE}=1
...    NRCELL-11:${ATT_OG_INTER_GNB_HO_SA_PLMN}=1
...    NRCELL-11:${SUCC_OG_INTER_GNB_HO_SA_PLMN}=1
...    NRCELL-11:${XN_HO_REQ_ACK_RECEIVED}=1

@{PM_Counters_Check_EXT}
...    NRCELL-13:${NF1CC_UECTXT_STP_REQSENT}=1
...    NRCELL-13:${NF1CC_UECTXT_STP_RESPRECD}=1
...    NRCELL-13:${XN_HO_REQ_ACK_SENT}=1
...    NRCELL-13:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}=1
...    NRCELL-13:${UE_PCELL_1_CONF_SCELL_DL_SA}>0


${ATT_INTER_GNB_HO_SLICE}    M55149C00008
#The number of Intra-Frequency Inter-gNB HOs attempted, for the given slice and PLMN.
${HO_REQ_PDU_SESS_RES_SENT_SLICE}    M55149C02004
#The number of total Xn Handover attempts of PDU session for the given slice and PLMN..
${SUCC_OG_INTER_GNB_HO_SLICE}    M55149C00009
#The number of Intra-Frequency Inter-gNB Outgoing HO successful, for the given slice and PLMN.
${ATT_OG_INTER_GNB_HO_SA_PLMN}    M55145C00341
#The number of outgoing intra-frequency inter-gNB HO execution attempts for SA per PLMN-ID.
${SUCC_OG_INTER_GNB_HO_SA_PLMN}    M55145C00342
#The number of successful outgoing intra-frequency inter-gNB HO executions for SA per PLMN-ID.
${XN_HO_REQ_ACK_RECEIVED}    M55143C00001
#The number of XnAP: Handover Request Acknowledge received.
${NF1CC_UECTXT_STP_REQSENT}    M55113C01001
#Number of F1AP: UE Context Setup ReqUEst messages sent from gNB-CU to gNB-DU
${NF1CC_UECTXT_STP_RESPRECD}    M55113C01002
#Number of F1AP: UE Context Setup Response messages received at gNB-CU from gNB-DU.
${XN_HO_REQ_ACK_SENT}    M55143C00006
#The sending of an XnAP: Handover Request Acknowledge. Updated in target gNB.
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361
#The number of successful incoming inter-gNB HO preparations for SA per PLMN-ID.
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#The sum of samples for total number of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL.

${ue_id}    1
${cell_id}    11
${pdu_id}    1

*** Test Cases ***
CB008140_GC021_Xn_intra-freq_Handover_outgoing_in_IgNB-CA_mode_FFTT_to_gnb2_intra-gNB_CA_coverbased_FT_rsrpCombined_and_back_with_mobility_profile
    [Documentation]
    ...    1. This user scenario describes the inter-gNB handover over Xn of a UE context in IgNB-CA mode.
    ...    2. Configuration
    ...       GNB1 cell1_11, cell1_12 F+F
    ...       GNB2 cell2_1, cell2_2, cell2_13, cell2_14 T+T+F+F
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 CE
    ...    [Configuration]:
    ...    GNB-1 Pri: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(pci:61)
    ...    GNB-2 ext: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51) cell13-FDD(n3)(pci:62) cell14-FDD(n28)(PCI63)
    ...    scell gnb2-cell1 gnb2-cell2 and gnb2-cell14
    ...    [Test Case Steps]
    ...         a.UE register to gnb1-cell11
    ...         b.blind 4CC FFTT scells add successful
    ...         c.UE1 send A5 MR with RSRP satisfied to trigger intra-frequency intergnb handover
    ...         d. coverBased add intraGnb cell as scell
    ...         e. UE1 send A5 MR with NRMOPR_SA RSRP satisfied to trigger intra-frequency intergnb handover back
    ...         f.UE context release
    ...         g.Check counters and logs
    ...    [Expected Results]:
    ...         b.scell: gnb2-cell1 gnb2-cell2 and gnb2-cell14 add successfully, traffic ok
    ...         c.HO from gnb1-cell11 to gnb2-cell13 successfully
    ...         d.scell: gnb2-cell1 add successfully
    ...         e. HO back from gnb2-cell13 to gnb1-cell11 successfully
    [Tags]    QC_253775
    Clear All Counter Files
    UE Attach To Target Cell Then Send And Verify Throughput    ${cell_id}
    Intrafreq InterGNB Handover
    trigger A1 MR to add scell
    Intrafreq InterGNB Handover Back
    UE Deregister From gNB First Time    ue_id=${ue_id}
    Check All Counters
    Check Wireshark Log    ${CURDIR}${/}A2A_GC_021${/}a2a.ini    wait_string=UEContextRelease::18
    Check Wireshark Log GNB2    ${CURDIR}${/}A2A_GC_021${/}a2a_gnb2.ini    wait_string=UEContextRelease::16
    Check userstop cause shall be correct

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Modify Cfg
    ${set_cell13_gscn}    catenate
    ...    set_cell id=13 gnb=3 pci=20:2 tac=200 nrci=0x0D tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=345000:364000
    ...    mandatory_for_activation=off gscn=4547
    Update Cfg    ${set_cell13_gscn}

Clear All Counter Files
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1    QoS Routing Table
    Should Contain    ${ret1}    physCellId 50
    Should Contain    ${ret1}    physCellId 51
    Should Contain    ${ret1}    physCellId 63
    Send And Verify Throuput

Verify Throughput
    [Arguments]    ${Tput_dl}=90    ${Tput_ul}=9.5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify Throughput After Add Scell
    [Arguments]    ${Tput_dl}=585    ${Tput_ul}=9.5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 90
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 450

UE Deregister From gNB First Time
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
    sleep    30s    reason=wait timer

Check All Counters
    Check Counters    ${PM_Counters_Check_PRIM}
    Check Counters GNB2    ${PM_Counters_Check_EXT}

Intrafreq InterGNB Handover
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=62
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=Inter-eNB handover from EXT_ENB
    Verify Throughput

Intrafreq InterGNB Handover Back
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=60
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ${ret1}=    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=scellIdx:3
    Should Contain    ${ret1}    physCellId 50
    Should Contain    ${ret1}    physCellId 51
    Should Contain    ${ret1}    physCellId 63
    Verify Throuput on Pcell and Scell    sleep_time=10s

trigger A1 MR to add scell
    [Arguments]    ${src_cell_ssbfreq}=363850
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${src_cell_ssbfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=110 srsrp_nr=110
    ...    pass_regexp=sCellIndex 1    fail_regexp=scellIdx:2
    Should Contain    ${ret1}    physCellId 50
    Verify Throughput After Add Scell

Send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pcell and Scell    sleep_time=10s

Scell traffic check
    [Arguments]    ${scell1_tput1}    ${scell2_tput2}    ${scell3_tput3}    ${scell1_tput1_except}=30
    ...    ${scell2_tput2_except}=30    ${scell3_tput3_except}=30
    Should Be True    ${scell1_tput1}/1000>${scell1_tput1_except}
    Should Be True    ${scell2_tput2}/1000>${scell2_tput2_except}
    Should Be True    ${scell3_tput3}/1000>${scell3_tput3_except}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${sleep_time}=10s    ${scell1_tput1_except}=470    ${scell2_tput2_except}=180
    ...    ${scell3_tput3_except}=70    ${pcell_tput_except}=70
    sleep    ${sleep_time}
    ${scell1_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    ${scell2_tput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    ${scell3_tput3}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Scell traffic check    ${scell1_tput1}    ${scell2_tput2}    ${scell3_tput3}    ${scell1_tput1_except}
    ...    ${scell2_tput2_except}    ${scell3_tput3_except}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_tput_except}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>9

Check userstop cause shall be correct
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_UserStopReq_t.cause == 3
    should be equal As Numbers    ${number}    2
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap
    ...    itf_l2_ps_user_UserSuspendSchedulingReq_t.ueSuspendCause == 4
    should be equal As Numbers    ${number}    1

