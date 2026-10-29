*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    RAN_5G_FDD    CRT
...    team-L3CN1_SG14    owner-jun 3.ye    release-SBTS23R4    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

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

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
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
...    NRCELL-11:sCellDeactivationTimerGNB=ms1280
...    NRCELL-12:sCellDeactivationTimerGNB=ms1280
@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:iniNumSCellsToActivate=3
...    NRCELL-11:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
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
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:prachConfigurationIndex=158
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=4/6
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:weightForSCellSelection=5
...    NRCELL-2:weightForSCellSelection=5
...    NRCELL-13:weightForSCellSelection=80
...    NRCELL-14:weightForSCellSelection=60
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
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002

${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002
${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001

@{PM_Counters_Check_priGNB}
...    NRCELL-11:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-11:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-11:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-11:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1

@{PM_Counters_Check_extGNB}
...    NRCELL-13:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-13:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-14:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-14:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-13:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-13:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-14:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-14:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1

${SA_Capa_Support_3CC_n77_3A_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482C036B64C558D0E7C471E819F604F8C48E3C873EA3
...    9F30C7942C0E070F05FFFFFC007FFC5F000540001C0A836016B04610D04083C4160195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000540
...    001C0AA36266B04610D04083A4160185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002A0000E0541B06F582308682041E20B00CAD9315624
...    39F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE000002A0000E0551B137582308680000100B00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3
...    C17AAAAAAA9EAAAAAAA1500007005161E26000713000000058158B898001C4C000E260000010B02B17008003098061300004160563E01000606C0C260184C0001858158B8040
...    018020303600040B02B1F00800300C0606C0C26800142C2EB1700800303606130000C160561E010006130000E160561E0100060080010160561E0D800606C0012160561E0100
...    060180014160561E03000606C0016160562E0100060180C0D800302C0AC3C1B000E2600000D0B02B1713000309806008001C160563E2600061300C010181B0007858158B8980
...    018020303600100B02B1F134003004060180C0D800442C0AC3C4D000E010200120B02B1F008003036061340C268004C2C2E01200DC0068099000A02688A04040C290A244D8E7
...    C38912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF87
...    1224489B1CF870A244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E14489B1CF871A2448913639F0C074506318C6318C6318C6318C6318C7A09
...    801E00140E0A00E0601280380030120020301F048010000000080040000001000006008000010040000100200000C01000008008000050040020080200800006004000038020
...    010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5BC19BC05AC0DAC04AC08AC1DA0682000012CA4A0800
...    00CB29302000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA48080001
...    8B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05001308080100202004008
...    8040080101002004040080110080600A02004008080100230100C014040300501002004040080110080800A02020028080B01630100C01804030050100C01804008011008060
...    0A02018028080100210100C014040080108080600A02018028404030060100C018202018030080600A10100C014040300510080600A02018030080600A10100C018040080110
...    080100202004008080600A30100200404008010100C014040300510080100202018030080600C30100200404030050100C018040300508080100202048028C04030050100C01
...    80400801010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

*** Test Cases ***
CB008140_ET_CA021_A1ScellAddition_based_on_weighted_bandwidth_when_a1MeasSCell_is_rsrpandrsrq_and_MR_greater_than_RsrpFDD_and_less_than_RsrpTDD
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    The case is to check CB008140-CA#B3: Event A1 measurement inter-gNB CA SCell addition for one SA connection with 3 candidate SCells 
    ...    located in an external gNB Successful case,when a1MeasSCellAddEnabled equal to rsrpandrsrq and RsrpTDD greater than RsrpFDD and 
    ...    RsrpFDD less than the value of report less than RsrpTDD 
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz weightForSCellSelection=5
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz weightForSCellSelection=5
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz weightForSCellSelection=80
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz weightForSCellSelection=60
    ...    2.Test Case Steps:
    ...         Step a. UE1 Register And PDU Session Setup On Cell1_11
    ...         Step b. UE1 Start Traffic
    ...         Step c. Send A1 To Trigger 3CC Scell Addition and Activation
    ...         Step d. Verify Throughput
    ...         Step e. Stop PDU and release UE
    ...         Step f. wireshark logs check
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful
    ...         Step b: Start Traffic and Verify Throughput is OK
    ...         Step c: A1 Add Cell2_13,Cell2_14 as Scell 3CC Scell Activation
    ...         Step d: Throughput is OK
    ...         Step e: PDU and UE deregister successfully
    ...         Step f: 
    ...          1.After setup of the first PDU session and having selected Cell-11 and Cell-12 as candidate SCells for 5G-UE, gNB-1-CU sends
    ...            to gNB-1-DU the F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message asking to prepare Cell-11 and Cell-12 addition. 
    ...          2.gNB-1-DU replies with the F1AP: IGNB CA UE CONTEXT MODIFICATION RESPONSE message by which it provides the PCell radio 
    ...            configuration, the transport addresses of the nonGBR DRB(s) to split and the allowed radio configuration in ext-gNB. 
    ...            gNB-1-DU increments the PM counter M55139C01501 GNB_DU_SCELL_2_ADMI_REQ_SA for Cell-13.
    ...          3.gNB-1-CU asks gNB-2-CU to configure Cell-11 and Cell-12 as SCells for 5G-UE by sending the XnAP: IGNB CA ADDITION REQUEST 
    ...            message. gNB-1-CU increments the PM counter M55118C11002 IGNB_CA_ATT_2_SCELL_SA for Cell-13.
    ...          4.gNB-2-CU, after successful admission of all candidate SCells, forwards the request to gNB-2-DU via F1AP: IGNB CA UE CONTEXT 
    ...            SETUP REQUEST message. gNB-2-CU increments PM counters M55138C03501 IGNB_SCELL_ADMI_REQ_SA and M55138C03502 
    ...            IGNB_SCELL_ADMI_SUCC_SA for Cell-11 and Cell-12, as well as the PM counter M55175C00001 IGNB_CA_ADD_REQ_SA_NRADJ for gNB-1.
    ...          5.After successful allocation of the radio resources for all candidate SCells, gNB-2-DU replies to gNB-2-CU with an F1AP: 
    ...            IGNB CA UE CONTEXT SETUP RESPONSE message by which it provides the transport addresses of the DRB(s) to split (transport address
    ...            per DRB per SCell is provided) as well as the selected radio configuration for SCells. gnB-2-DU increments the PM M55139C01001 
    ...            GNB_DU_SCELL_ADMI_REQ_SA for Cell-11 and Cell-12.
    ...          6.gNB-2-CU replies to gNB-1-CU by sending the XnAP: IGNB-CA UE ADDITION REQUEST ACKNOWLEDGE message, carrying SCells configuration 
    ...            received from gNB-2-DU. 
    ...          7.gNB-1-CU forwards the received SCells configuration to gNB-1-DU via F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message, with 
    ...            the information received from gNB-2-CU. gNB-1-CU increments the PM counter M55118C11005 IGNB_CA_ATT_2_SCELL_SA_SUCC for Cell-13.
    ...          8.gNB-1-DU reconfigures Cell1_1 if needed, configures the PUCCH to support SCells, prepares the new radio configuration message 
    ...            (cellGroupConfig) for 5G-UE and sends it to gNB-1-CU via F1AP: IGNB CA UE CONTEXT MODIFICATON RESPONSE message. This message 
    ...            carries also the PUCCH configuration Information required by SCells for proper data scheduling and decoding. gNB-1-DU increments
    ...            the PM counter M55139C01502 GNB_DU_SCELL_2_ADMI_SUCC_SA for Cell-13.
    ...          9.gNB-1-CU sends to gNB-2-CU the XnAP: IGNB CA UE CONTEXT MODIFICATION REQUEST message carrying the PUCCH Configuration Information
    ...            received from gNB-1-DU. 
    ...          10.gNB-2-CU forwards the message received from gNB-1-CU to gNB-2-DU via F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message.
    ...          11.gNB-2-DU replies with the F1AP: IGNB CA UE CONTEXT MODIFICATION RESPONSE message confirming SCells addition. gNB-2-DU increments
    ...             the PM counter M55139C01002 GNB_DU_SCELL_ADMI_SUCC_SA for Cell-11 and Cell-12.
    ...          12.gNB-2-CU replies to gNB-1-CU sending the XnAP: IGNB CA MODIFICATION REQUEST ACKNOWLEDGE message confirming SCells addition. 
    ...          13.gNB-1-CU fills out the final RRC:RECONFIGURATION message and sends it to 5G-UE, which acknowledges it through gNB-1-DU via F1AP:
    ...             DL RRC MESSAGE TRANSFER/UL RRC MESSAGE TRANSFER.

    [Tags]    QC_224226    CA021
    Clear Counter Files for 2GNB
    Ue Register And PDU Session Setup Without Scell Addition
    Run Traffic without Scell Addition and Activation and Verify Throughput
    UE Send A1 To Trigger 3CC Scell Addition and Activation
    Verify Throughput    ue_id=1    Tput_dl=260    Tput_ul=45
    Stop PDU and release UE
    Check Counters    ${PM_Counters_Check_priGNB}
    Check Counters GNB2    ${PM_Counters_Check_extGNB}
    Check WireShark Log    ${CURDIR}${/}A2A_CA_021${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_CA_021${/}a2a_gnb2.ini    wait_string=UEContextRelease::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_n77_3A_CA}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    Should Not Contain    ${ret1}    physCellId 62
    Should Not Contain    ${ret1}    physCellId 63

Run Traffic without Scell Addition and Activation and Verify Throughput
    [Arguments]    ${ue_id}=1
    ${ret1}=    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Should Not Contain    ${ret1}    physCellId 62
    Should Not Contain    ${ret1}    physCellId 63
    ${ret1}=    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Should Not Contain    ${ret1}    physCellId 62
    Should Not Contain    ${ret1}    physCellId 63
    ${ret1}=    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Should Not Contain    ${ret1}    physCellId 62
    Should Not Contain    ${ret1}    physCellId 63
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=1    Tput_dl=90    Tput_ul=45

UE Send A1 To Trigger 3CC Scell Addition and Activation
    [Arguments]    ${ue_id}=1    ${cellfreq}=363850    ${scell1pci}=62    ${scell2pci}=63
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=100 srsrq_nr=20
    ...    pass_regexp=SCellIndex 2 activated successfully at airphone
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId${scell2pci}
    Sleep    5s    #wait all sysinfo

Stop PDU and release UE
    Execute Egate Command    trf_data_stop ue=1 pdu=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Release UEs    ue_type=all
