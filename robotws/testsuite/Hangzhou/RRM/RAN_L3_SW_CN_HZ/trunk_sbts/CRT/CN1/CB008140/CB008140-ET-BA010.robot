*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_[BO][BO]_AP_[KLLL]_SANSA_L1B_CPRI_CMWV_FDD
...               release-SBTS23R1    owner-jolin.fan    team-jazz    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{CA_basic_config}
...    @{CB008140_config_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_config_GNB2}
...    @{CA_basic_config}

@{CB008140_config_GNB1}
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:iGnbCaXnSetupReqTmr=30
...    NRBTS:sCellActivationMethod=blind
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=2
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:lcrId=13
...    NRBTS/NRADJNRCELL-2:nrarfcn=368400
...    NRBTS/NRADJNRCELL-2:physCellId=62
...    NRBTS/NRADJNRCELL-2:ssbFrequency=368430
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS/NRCELL-12:a1MeasSCellAddEnabled=rsrpCombined
...    NRBTS/NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=5
...    NRBTS/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRBTS/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=22
...    NRBTS/NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRBTS/NRCELL-12:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=3
...    NRBTS/NRCELL-12:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=70
...    NRBTS/NRCELL-12:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=64ms
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=2
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-10:lcrId=13
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly
...    NRBTS/NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRBTS/NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=5
...    NRBTS/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRBTS/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=22
...    NRBTS/NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=2
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly

@{CB008140_config_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=11
...    NRBTS/NRADJNRCELL-1:nrarfcn=364000
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=12
...    NRBTS/NRADJNRCELL-2:nrarfcn=374000
...    NRBTS/NRADJNRCELL-2:physCellId=61
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRBTS/NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRBTS/NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRBTS/NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRBTS/NRCELL-13:a2MeasSCellRelEnabled=rsrq
...    NRBTS/NRCELL-13:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=2
...    NRBTS/NRCELL-13:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=35
...    NRBTS/NRCELL-13:a2MeasSCellRelSsbRsrq:a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRBTS:iGnbCaXnSetupReqTmr=40


@{CA_basic_config}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:actChannelMapVal=Disabled
...    NRBTS:actRanSharing=false
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupRespTmr=1
...    NRBTS:weightForIgnbCaSelection=1

...    NRBTS:intGnbScellTempBlockTmr=60
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    delete:NRCELL/NRPLMNSET_NSA-1
...    delete:NRCELL/NRPLMNSET_SA-1
...    NRCELL:configuredEpsTac=200
...    NRCELL:actCDrx=false

@{PM_Counters_BA010}
...     NRCELL-11:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...     NRCELL-11:${GNB_DU_SCELL_1_ADMI_SUCC_SA}==1
...     NRCELL-11:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...     NRCELL-11:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=1
...     NRCELL-11:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507

@{PM_Counters_BA010_GNB2}
...     NRCELL-1:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...     NRCELL-1:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...     NRCELL-1:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...     NRCELL-1:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...     ${IGNB_CA_ADD_REQ_SA_NRADJ}=1

${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004




*** Test Cases ***
CB008140-ET-CB008140-ET-BA010_Blind_Inter-gNB_FT_CA_Scell_addition_with_a2MeasSCellRelEnabled
    [Documentation]
    ...    [purpose]:
    ...         When scellAdditionMethod is set to 'blind', this case is to varify the successful blind inter-gNB CA SCell addition for a SA UE,
    ...         without event A2 measurement for SCell release configuration.
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 BA
	...    [Configuration]:
	...    GNB-1 Prime: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(PCI61)
	...    GNB-2 ext: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51)	 cell13-FDD(n3)(pci:62) cell14-FDD(n3)(pci:63)
    ...    [Test Case Steps]
    ...         a.UE register to gnb1-cell11
	...         b.PDU session setup
    ...         c.run dl/ul traffic for UE
    ...         d.UE context release
	...         e.Check counters and logs
	...    [Expected Results]:
    ...         ue register to GNB-1 CELL-11, and PDU session is setup successfully, scell added, A2 not configured.

    [Tags]    BA010    QC_220770    jifan
    Ue register and pdu session setup with blind scell addition    ue_id=1    gateway=1
    Run traffic to activate scell    ue_id=1
    Verify Throughput    ue_id=1    Tput_dl=120    Tput_ul=8
    release_ues    ue_type=sa    ue_id=1
    Check Counters    ${PM_Counters_BA010}
    Check Counters GNB2    ${PM_Counters_BA010_GNB2}
    Check WireShark Log    ${CURDIR}${/}A2A_BA_010${/}a2a.ini    wait_string=UEContextReleaseComplete::3
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_BA_010${/}a2a_gnb2.ini    wait_string=IgNBCAReleaseRequestAcknowledge::1

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Ue register and pdu session setup with blind scell addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${cmd_regexp}=UE now in NG RM Registere    ${cmd_pdu_regexp}=SCellIndex 1 activated successfully
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${cmd_pdu_regexp}

Run traffic to activate scell
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
