*** Settings ***
Documentation    Suite documentation
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    owner-susana.yan    release-SBTS23R3    team-L3CN1_SG14
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}


@{LOLO_Golden_Changes_GNB2}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1


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
...    @{LOLO_Golden_Changes_GNB2}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3
@{PARAMS_FOR_GNB1}
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
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
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
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
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=2
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=2
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-13:gNbId=2
...    NRCELL-12/NRREL-13:gNbIdLength=22
...    NRCELL-12/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-13:lcrId=13
...    NRCELL-12/NRREL-13:removeNotAllowed=false
...    NRCELL-12/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-14:gNbId=2
...    NRCELL-12/NRREL-14:gNbIdLength=22
...    NRCELL-12/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:removeNotAllowed=false
...    NRCELL-12/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:weightForSCellSelection=1
...    NRCELL-2:weightForSCellSelection=1
...    NRCELL-13:weightForSCellSelection=100
...    NRCELL-14:weightForSCellSelection=80
...    NRCELL-13:maxNumOfUsersPerNRCell=1
...    NRCELL-13:maxNumOfUsersPerCell=1
...    NRCELL-13:maxNumOfCaUsersNRCell=1
...    NRCELL-13:maxNumOfRrcSA=1
...    NRCELL-13:maxNumOfNrDcSnUsers=1
...    NRCELL-13:maxNumOfSCellAlloc=1
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms

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
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004

${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001   #Obsolete, replace with M55198C00001
${IGNB_CA_ADD_REQ_SA_ADJ}    M55199C00001
${IGNB_CA_SCELL_ADMI_UNSUCC_SA}    M55138C03503

@{PM_Counters_Check_priGNB}
...    NRCELL-12:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-12:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-12:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-12:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1

@{PM_Counters_Check_extGNB}
...    NRCELL-14:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-14:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-2:AGNBM:${IGNB_CA_ADD_REQ_SA_ADJ}=1
...    NRCELL-14:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-14:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-13:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-13:RSACU:${IGNB_CA_SCELL_ADMI_UNSUCC_SA}=1

@{RD_COUNTER_CHECK_GNB1}
...    NRCELL-12:IGNB_CA_ATT_1_SCELL_SA_SUCC=1


@{RD_COUNTER_CHECK_GNB2}
    ...    NRCELL-13:IGNB_CA_SCELL_ADMI_UNSUCC_SA=1

#ue cap Based on golden UE1 capability exclude 4CC cap
${SA_Capa_Support_3CC_Not_Support_4CC_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482C036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F000540001C0A836016B04610D04083C4160195B262AC4873EC
...    09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000540001C0AA36266B04610D04083A4160185B262A88873E238F11C7A0
...    67D813E31CF9863CA1607038782E007FE003801FF8002A0000E0541B06F582308682041E20B00CAD931562439F11C7B027C62471E439F51
...    CF9863CA1607038784FFF800003FFE000002A0000E0551B137582308680000100B00C2D926544439F11C79063D033EC09F00E7CC31E50B0
...    381C3C17AAAAAAA9EAAAAAAA1500007004D61E26000713000000058158B898001C4C000E260000010B02B17008003098061300004160563
...    E01000606C0C260184D0001858158B8040018020303600040B02B1F00800300C0606C0C26800142C0AC5C02000C0D8184C0003058158780
...    400184C000385815878040018020004058158783600181B000485815878040018060005058158780C00181B0005858158B8040018060303
...    6000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89A00184C030040606C001E160562E2600060080C0D800402C0AC
...    7C4D000C01018060303600110B02B0F1340038040800482C08048037001A0264002809A2280F509C28913639F0E2448913639F0E2448913
...    639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C385122
...    6C73E1C4891226C73E1C28913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C3851226C73E1801B1318C6318C
...    6318C6318C6318C7E8260078005038280381804A00E000C0480080C07C12004000000020010000000400001802000004010000040080000
...    30040000200200001401000802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010
...    000180672A6B2A6B052B032B066B056B296F066F016B036B012B022B07681A0800004B29282000032CA4C080000CB29202000072CA48080
...    0024B292020000B2CA4C0800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA4
...    80669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A050
...    281400482020040080801002201002004040080101002004402018028080100202004008C04030050100C01404008010100200440202002
...    8080800A0202C058C04030060100C014040300601002004402018028080600A020040084040300501002004202018028080600A10100C01
...    8040300608080600C02018028404030050100C014402018028080600C020180284040300601002004402004008080100202018028C04008
...    010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008081200A3543E0002040608
...    0C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{expectedUE2ScellAddition}
...    SCellIndex 2 activated successfully at airphone
...    physCellId 63

@{unexpectedUE2ScellAddition}
...    SCellIndex 1 activated successfully at airphone
...    physCellId 62

@{unexpectedUE2RegisterString}
...    physCellId 62
...    physCellId 63

*** Test Cases ***
CB008140-ET-FA001_Verify_Successful_Partial SCell addition with partial SCell candidates are admitted at ext-gNB-CU FFF maxNumOfUsersPerNRCell
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    this case is to test successful partial SCell addition with partial scell candidates are admitted
    ...    at ext-Gnb-CU due to maxNumOfUsersPerNRCell reached for inter-gNB with 3CC(FDD-FDD-FDD) DL CA.
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz weightForSCellSelection=1
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz weightForSCellSelection=1
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz weightForSCellSelection=100
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz weightForSCellSelection=80
    ...    Weight for Cell 13 and Cell 14 has higher weight than other 3CC band combinations.
    ...    2.Test Case Steps:
    ...         Step a. PreUE UE1 Register And PDU Session Setup On Cell3_13 to occupy radio resource of extGnb.
    ...         Step b. UE2 Register And PDU Session Setup On Cell2_12
    ...         Step c. UE2 Start Traffic
    ...         Step d. Send A1 To Trigger 3CC Scell Addition
    ...         Step e. Verify Throughput
    ...         Step f. Send A2 to Release scell CELL3_14.
    ...         Step g. Stop PDU and release UE
    ...         Step h. PM_Counters and wireshark logs check
    ...    3. Expected Results:
    ...         Step a: PreUE UE1 Register And PDU Session Setup Successfully
    ...                 maxNumOfUsersPerNRCell of CELL3_13 reaches.
    ...         Step b: UE2 Register And PDU Session Setup Successfully
    ...         Step c: Traffic Start successfully.
    ...         Step d: A1 Add Cell3_14 as scell successfully and failed to setup Cell3_13
    ...         Step e: Traffic throughput is as expected.
    ...         Step f: scell release successfully.
    ...         Step g: PDU and UE deregister successfully
    ...         Step h:
    ...           1). xn xp interfaces setup successfully, xn xp CA setup successfully, inter-gnb CA addition successfully, prime GNB-cu will
    ...               add the Cell3_14 as scell and fail to add Cell3_13.
    ...           2). the following counters will be updated correctly:
    ...               M55139C01501 GNB_DU_SCELL_2_ADMI_REQ_SA for cell2_12
    ...               M55118C11002 IGNB_CA_ATT_2_SCELL_SA for Cell2_12.
    ...               M55138C03501 IGNB_CA_SCELL_ADMI_REQ_SA and M55138C03502 IGNB_CA_SCELL_ADMI_SUCC_SA for Cell3_14
    ...               M55138C03501 IGNB_CA_SCELL_ADMI_REQ_SA and M55138C03503 IGNB_CA_SCELL_ADMI_UNSUCC_SA for Cell3_13
    ...               M55175C00001 IGNB_CA_ADD_REQ_SA_NRADJ(replace with IGNB_CA_ADD_REQ_SA_ADJ) for gNB-1.
    ...               M55139C01001 GNB_DU_SCELL_ADMI_REQ_SA for Cell3_14.
    ...               M55118C11004 IGNB_CA_ATT_1_SCELL_SA_SUCC for Cell2_12.
    ...               M55139C01004 GNB_DU_SCELL_1_ADMI_SUCC_SA for Cell2_12.
    ...               M55139C01002 GNB_DU_SCELL_ADMI_SUCC_SA for Cell3_14.
    [Tags]    QC_47074    FA001
    Clear Counter Files for 2GNB
    PreUe to Occupy NRCELL Radio Resources    cell_id=13
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=2    unexpectedString=@{unexpectedUE2RegisterString}
    Run Traffic    ue_id=2
    UE Send A1 To Trigger Scell Partial Addition    ue_id=2    expectedString=@{expectedUE2ScellAddition}
    ...    unexpectedString=@{unexpectedUE2ScellAddition}
    Verify Throughput    ue_id=2    Tput_dl=153    Tput_ul=45
    Release Scell    scell_index=2
    Stop PDU and release UE
    Check Counters    ${PM_Counters_Check_priGNB}
    Check Counters GNB2    ${PM_Counters_Check_extGNB}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_3CC_Not_Support_4CC_CA}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

PreUe to Occupy NRCELL Radio Resources
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=3    ${cell_id}=13
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=2    ${gateway}=2    ${enb_id}=2    ${cell_id}=12    ${unexpectedString}=${None}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    ...    fail_regexp=${unexpectedString}

UE Send A1 To Trigger Scell Partial Addition
    [Arguments]    ${expectedString}    ${unexpectedString}=${None}    ${ue_id}=2    ${cellfreq}=373970
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${expectedString}    fail_regexp=${unexpectedString}
    Sleep    5s    #wait all sysinfo

Run Traffic
    [Arguments]    ${ue_id}=1
    ${ret1}=    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=170 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul

Verify Throughput
    [Arguments]    ${ue_id}=2    ${Tput_dl}=0    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Release Scell
    [Arguments]      ${carrier_freq}=153370    ${scell_index}=2    ${ue_id}=2
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${carrier_freq}    A2
    ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
    ...    scell=${scell_index} scell_rsrp=20 scell_rsrq=20
    ${ret1}=    Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToReleaseList{${scell_index}}

Stop PDU and release UE
    Execute Egate Command    trf_data_stop ue=2 pdu=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Release UEs    ue_type=all
