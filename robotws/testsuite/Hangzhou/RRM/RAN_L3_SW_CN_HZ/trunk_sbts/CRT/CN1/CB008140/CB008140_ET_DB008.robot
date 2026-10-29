*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    owner-alex.2.wang    release-SBTS23R4    CRT    team-L3CN1_SG14
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${CA_SUPPORT_LIST}    SEPARATOR=,
...    ca_Fr1Tdd_Fdd_Sa
...    ca_Fr1Tdd_Any_Sa
...    ca_Fr1Tdd_Sa
...    ca_Fdd_Fr1Tdd_Sa
...    ca_Fdd_Any_Sa
...    ca_Fdd_Fdd

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
...    NRBTS:weightForIgnbCaSelection=50
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3
@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB
@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=35
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
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
...    NRBTS/NRADJNRCELL-54:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-54:fiveGsTac=200
...    NRBTS/NRADJNRCELL-54:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-54:gNbId=35
...    NRBTS/NRADJNRCELL-54:gNbIdLength=22
...    NRBTS/NRADJNRCELL-54:lcrId=1
...    NRBTS/NRADJNRCELL-54:nrarfcn=636666
...    NRBTS/NRADJNRCELL-54:physCellId=54
...    NRBTS/NRADJNRCELL-54:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-54:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-54:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-55:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-55:fiveGsTac=200
...    NRBTS/NRADJNRCELL-55:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-55:gNbId=35
...    NRBTS/NRADJNRCELL-55:gNbIdLength=22
...    NRBTS/NRADJNRCELL-55:lcrId=2
...    NRBTS/NRADJNRCELL-55:nrarfcn=153500
...    NRBTS/NRADJNRCELL-55:physCellId=55
...    NRBTS/NRADJNRCELL-55:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-55:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-55:gnbPlmn:mncLength=3
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
...    NRCELL-1/NRREL-54:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-54:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-54:gNbId=35
...    NRCELL-1/NRREL-54:gNbIdLength=22
...    NRCELL-1/NRREL-54:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-54:lcrId=1
...    NRCELL-1/NRREL-54:removeNotAllowed=false
...    NRCELL-1/NRREL-54:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-54:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-54:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-54:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-55:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-55:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-55:gNbId=35
...    NRCELL-1/NRREL-55:gNbIdLength=22
...    NRCELL-1/NRREL-55:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-55:lcrId=2
...    NRCELL-1/NRREL-55:removeNotAllowed=false
...    NRCELL-1/NRREL-55:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-55:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-55:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-55:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=10
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=320ms
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=320ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=45
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=320ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=320ms
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
@{PARAMS_FOR_OTHERS}
...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

${IGNB_CA_ATT_3_SCELL_SA}           M55118C11003
${IGNB_CA_ATT_3_SCELL_SA_SUCC}      M55118C11006
${GNB_DU_SCELL_3_ADMI_REQ_SA}       M55139C03001
${GNB_DU_SCELL_3_ADMI_SUCC_SA}      M55139C03002
${IGNB_CA_ADD_REQ_SA_NRADJ}         M55175C00001
${IGNB_CA_SCELL_ADMI_REQ_SA}        M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}       M55138C03502
${GNB_DU_SCELL_ADMI_REQ_SA}         M55139C01001
${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}    M55139C01002
@{PM_Counters_Check_GNB1}
...    NRCELL-1:NCAC:${IGNB_CA_ATT_3_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_3_SCELL_SA_SUCC}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_SUCC_SA}=1
@{PM_Counters_Check_GNB2}
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=2
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}=2
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}=2
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}=1
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=0
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=0
...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=0
...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_REQ_SUCC_SA}=0

*** Test Cases ***
CB008140-ET-DB008_Verify_Inter-gNB_CA_reselect_to_other_gnb_after_scell_full_release
    [Documentation]
    ...    The successful blind inter-gNB CA SCell addition for SA UE context having several candidate SCells hosted by different gNBs.
    ...    3 gNB max 4CC Config in use, Scell reselection after scell full release.
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz weightForSCellSelection=50
    ...    nrCellIdentifier=16385
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8055 chBw=100MHz weightForSCellSelection=10
    ...    nrCellIdentifier=32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz weightForSCellSelection=10
    ...    nrCellIdentifier=32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n28 nr_arfcn=349400:368400 gscn=4605 chBw=15MHz weightForSCellSelection=50
    ...    nrCellIdentifier=32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=143400:153400 gscn=1916 chBw=10MHz weightForSCellSelection=50
    ...    nrCellIdentifier=32780
    ...    sim gNB:
    ...    Cell id=1 gnb=4 pci=18:0 tac=200 tdd_cell=on band=n78 nr_arfcn=636666:636666 gscn=7880 chBw=40MHz weightForSCellSelection=10
    ...    nrCellIdentifier=573441
    ...    Cell id=2 gnb=4 pci=18:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143500:153500 gscn=1916 chBw=15MHz weightForSCellSelection=10
    ...    nrCellIdentifier=573442
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On Cell2_1 and trigger A1 MR to setup 4CCs CA with Cell2_3/Cell2_11/Cell2_12
    ...         b. UE1 Start Traffic And Verify Throughput
    ...         c. Trigger A2 MR to release scells one by one
    ...         d. Trigger A1 MR to setup 3CCS with Cell2_11/Cell2_12
    ...         e. UE1 Start Traffic And Verify Throughput
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful, 4CCS CA setup scuccessfully
    ...         Step B: UE1 Traffic And Throughput is OK
    ...         Step C: Scells are released one by one successfully
    ...         Step D: 3CCs setup scuccessfully
    ...         Step E: UE1 Traffic And Throughput is OK
    [Tags]    QC_251538    DB008
    Clear Counter Files for 2GNB
    Setup XpAP Link
    Set Sim gNB ignb CA Addition Param
    Ue Register And PDU Session Setup Without Scell Addition
    UE Send A1 To Trigger 4CC CA setup
    Run Traffic And Verify Throughput     Tput_dl=630
    trigger A2 MR to release scell    scell=1    cellfreq=655008
    trigger A2 MR to release scell    scell=2    cellfreq=368430 
    trigger A2 MR to release scell    scell=3    cellfreq=153370
    UE Send A1 To Trigger 3CC CA setup
    Run Traffic And Verify Throughput    Tput_dl=405
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_Check_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_GNB2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Setup XpAP Link
    Execute Egate Command    sim_trace enb=4 protocol=xp,xn on
    Execute Egate Command    enb_xp_param xp_peers=2 id=4

Modify Cfg
    ${gNB4_sim_configuration}  	 catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on xn=10.0.1.124
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell1_sim_configuration}    catenate
    ...    set_cell id=1 gnb=4 pci=18:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    nr_scs=30kHz bs_channel_bandwidth=40MHz mandatory_for_activation=off gscn=7880
    ${gNB4_Cell2_sim_configuration}    catenate
    ...    set_cell id=2 gnb=4 pci=18:1 tac=200 nrci=0x02 tdd_cell=off proxy=10.0.2.90:9998 nr_arfcn=143500:153500
    ...    nr_scs=30kHz bs_channel_bandwidth=15MHz mandatory_for_activation=off gscn=1916
    Update Cfg    ${gNB4_Cell1_sim_configuration}
    Update Cfg    ${gNB4_Cell2_sim_configuration}

Perform Steps After Onair
    Get Correct Xp XgU Version

Get Correct Xp XgU Version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    Set Suite Variable    ${IgNBCAXpVersion}    ${IgNBCAXpProtocol_Version}
    Set Suite Variable    ${IgNBCAXgUVersion}    ${IgNBCAXgUProtocol_Version}

Set Sim gNB ignb CA Addition Param
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes
    ...    location_bw_ul=1:2 location_bw_dl=3:4 Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000
    ...    IgNBCAXpProtocolVersion=${IgNBCAXpVersion} IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ${gNB4_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=1 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=10
    Execute Egate Command    gnb_cell_param gnb=4 id=2 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=10
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    pass_regexp=Sent to GNB-2

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=QoS Routing Table    fail_regexp=activated successfully at airphone


UE Send A1 To Trigger 4CC CA setup
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${scell1pci}=52    ${scell2pci}=60    ${scell3pci}=61
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}
    ...    event_type=A1    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=120
    ...    pass_regexp=activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId${scell2pci}
    Should Contain    ${ret1}    sCellIndex3,sCellConfigCommon{physCellId${scell3pci}

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=405    ${Tput_ul}=45
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=5 protocol=tcp mbps=100 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    ${Tput_dl}    ${Tput_ul}
    [Teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=4
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=5
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1
    ...    pass_regexp=Stopping Uplink Internal traffic on Ue

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}   qfi=${qfi}   direction=dl   rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}   qfi=${qfi}   direction=ul   rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

trigger A2 MR to release scell
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${scell}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}
    ...    event_type=A2
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell} scell_rsrp=20
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToReleaseList{${scell}

UE Send A1 To Trigger 3CC CA setup
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${scell1pci}=60    ${scell2pci}=61
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}
    ...    event_type=A1    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=40
    ...    pass_regexp=activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId${scell2pci}
