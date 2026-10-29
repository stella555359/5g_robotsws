*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    RAN_5G_FDD    CRT
...    team-L3CN1_SG14    owner-jun.3.ye    release-SBTS23R4    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
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
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumOfCaUsersNRCell=250
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxNumOfNonGBRBearersSA=550
...    NRCELL:maxNumOfRrcSA=275
...    NRCELL:maxNumOfSCellAlloc=250
...    NRCELL:maxNumOfUsersPerNRCell=275
...    NRCELL:maxNumOfUsersPerCell=275

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrqCombined
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=50
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
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
...    NRCELL-1:chBw=40MHz
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
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
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
@{PARAMS_FOR_GNB2}
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
...    NRCELL-3:chBw=40MHz
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
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

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
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1

@{PM_Counters_Check_extGNB}
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1


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
CB008140_ET_CA022_Verify_IgnbCA_CovbasedA1_ScellAdd_for_a1MeasSCellAddEnabled_Set_As_RSRQ_Combined_And_Success
    [Documentation]
    ...    this case is to test CA is configured when RSRQ greater than threshold and successful TDD+TDD+TDD 3CC inter-GNB covbased scell 
    ...    addition for SA UE
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=40MHz
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=40MHz weightForSCellSelection=10
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz weightForSCellSelection=10
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz weightForSCellSelection=40
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=20MHz weightForSCellSelection=20
    ...    2.Test Case Steps:
    ...         Step a. UE1 Register And PDU Session Setup On Cell1_1
    ...         Step b. UE1 Start Traffic And Verify Throughput
    ...         Step c. UE1 Send A1 with RSRQ is greater than the a1ThresholdSCellAddSsbRsrq and RSRP is greater than the 
    ...                 a1ThresholdSCellAddSsbRsrpTDD
    ...         Step d. stop traffic and deregister UE
    ...         Step e. wireshark logs and counters check
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful
    ...         Step b: UE1 Traffic And Throughput is OK
    ...         Step c. UE1 Send A1 successful and Scell Addition and Activation successfully,Scell Cell2_3,Cell2_4 as Activation and with A1 
    ...         measurements are deconfigured and A2 measurements is configured
    ...         Step d: UE deregister successfully
    ...         Step e: 
    ...           1). During setup of the first PDU session, 5G-UE is configured with event A1 measurement for SCell addition using 
    ...               a1ThresholdSCellAddSsbRsrpFDD threshold. 
    ...           2). inter-GNB Scell addition is not triggered for the first time:
    ...            M55139C01501 GNB_DU_SCELL_2_ADMI_REQ_SA for Cell1_1
    ...            M55118C11002 IGNB_CA_ATT_2_SCELL_SA for Cell1_1
    ...            M55138C03501 IGNB_SCELL_ADMI_REQ_SA and M55138C03502 IGNB_SCELL_ADMI_SUCC_SA for Cell2_3 and Cell2_4
    ...            M55175C00001 IGNB_CA_ADD_REQ_SA_NRADJ for Cell1_1
    ...            M55139C01001 GNB_DU_SCELL_ADMI_REQ_SA for Cell1_1
    ...            M55118C11005 IGNB_CA_ATT_2_SCELL_SA_SUCC for Cell1_1
    ...            M55139C01502 GNB_DU_SCELL_2_ADMI_SUCC_SA for Cell1_1
    ...            M55139C01002 GNB_DU_SCELL_ADMI_SUCC_SA for Cell2_3 and Cell2_4
    ...            M55118C09501 UE_PCELL_2_CONF_SCELL_DL_SA for Cell1_1
    [Tags]    QC_224227    CA022
    Clear Counter Files for 2GNB
    Ue Register And PDU Session Setup Without Scell Addition
    Run Traffic And Verify Throughput
    UE Send A1 Trigger 3CC Scell Activation And Verify Throughput
    Stop PDU and release UE
    Check Counters    ${PM_Counters_Check_priGNB}
    Check Counters GNB2    ${PM_Counters_Check_extGNB}
    Check WireShark Log    ${CURDIR}${/}A2A_CA_022${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_CA_022${/}a2a_gnb2.ini    wait_string=UEContextRelease::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_n77_3A_CA}
    ${set_cell3_gscn}    catenate
    ...    set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=653400:653400
    ...    mandatory_for_activation=off gscn=8055
    Update Cfg    ${set_cell3_gscn}

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    Should Not Contain    ${ret1}    physCellId 52
    Should Not Contain    ${ret1}    physCellId 53
    Sleep    5s    #wait all sysinfo

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Run Keywords    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=1    Tput_dl=210    Tput_ul=45

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=270    ${Tput_ul}=45    ${sleep_time}=15s
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

Stop PDU and release UE
    Execute Egate Command    trf_data_stop ue=1 pdu=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Release UEs    ue_type=all

UE Send A1 Trigger 3CC Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${scell1pci}=52    ${scell2pci}=53
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRQ\ 50
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=52
    ...    pass_regexp=SCellIndex 2 activated successfully at airphone
    Should Not Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone	
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId${scell2pci}
    Sleep    5s    #wait all sysinfo
    Verify Throughput    ${ue_id}
