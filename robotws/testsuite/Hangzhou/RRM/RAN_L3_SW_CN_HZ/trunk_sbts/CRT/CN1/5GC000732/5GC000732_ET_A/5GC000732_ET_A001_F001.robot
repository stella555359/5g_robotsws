*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    team-SG2
...               owner-ying.chen    release-5G20A    5GC000732
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000732_Base}
@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS:actFdmScheduling=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRPMRNL:miNrRelReportCu=15min
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:actCDrx=true
...    NRCELL-11:pucchModeSelect=longPucch
...    NRCELL-11:absThreshSsbRsrpConsolidation=1
...    NRCELL-11:absThreshSsbRsrqConsolidation=1
...    NRCELL-11:sMeasConfigSsbRsrp=1
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz

@{PM_Counters_Check_5GC000732A001F001}
...    NRDU-1:${RRC_REESTAB_RECONF_FAILURE_DU}=2
...    NRDU-1:${REESTAB_ACC_RECONF_FAIL_DU}=2
...    NRCELL-11:${RRC_REESTAB_RECONF_FAILURE}=2
...    NRCELL-11:${REESTAB_ACC_RECONF_FAIL}=2
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=2
...    NRCELL-11:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}=20
...    NRCELL-11:${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}=15
...    NRCELL-11:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=7
...    NRCELL-11:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=7
...    NRCELL-11:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}=3
...    NRCELL-11:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}=3
...    NRCELL-11:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}=3
...    NRCELL-11:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=3
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}=7
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}=7
...    NRCELL-11:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=17

${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501    #Number of RRC Re-establishment Request caused by reconfiguration failure
${REESTAB_ACC_RECONF_FAIL_DU}    M55127C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${RRC_REESTAB_RECONF_FAILURE}       M55124C00503    #Number of RRC Re-establishment Request caused by reconfiguration failure
${REESTAB_ACC_RECONF_FAIL}          M55124C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #Number of RRC reconfiguration successful in RRC reestablishment procedure
${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002    #Number of incoming UE CONTEXT MODIFICATION RESPONSE received from gNB-DU
${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501    #Number of DL RRC Message Transfer sent.
${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502    #Number of UL RRC Message Transfer received.
${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}    M55124C03001    #Number of RRC RECONFIGURATION sent
${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002    #Number of RRC RECONFIGURATION COMPLETE received
${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}    M55135C00505    #Number of Bearer Context Modification Request sent by gNB-CU-CP
${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}    M55135C00506    #Number of Bearer Context Modification Response received at gNB-CU-CP
${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}    M55139C00001    #The number of radio admission requests for SA user in DU
${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}    M55139C00002    #The number of radio admitted UEs for SA user in DU
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003    #The number of non-GBR DRB radio admission requests for SA user in DU
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004    #The number of radio admitted non-GBR DRBs for SA user in DU

${ReconfigurationFailure}     reconfigurationFailure
${ue_id}    81
${gw_id}    2

*** Test Cases ***
5GC000732-ET-A001_RRC_reestablish_succ_to_ori_cell_due_to_reconfigFailure_with_valid_UE_context_one_DRB
    [Documentation]    This case will test RRC reestablish to ori_cell due to reconfigfailure with 1 drb,
    ...    combine with A001 and F001 with feature 1390 blind to ori Pcell DRX enabled no meas.
    ...    preconditions:
    ...        1. configure F+T
    ...    Case steps:
    ...        1.Setup CA(FDD+TDD) successfully
    ...        2.Trigger Normal call on Cell-11
    ...        3.Trigger scell add
    ...        4.Trgger RRC reestablish
    ...        5.RRC reestablish should successfully
    ...        6.check cause reconfigurationFailure in rrcReestablishmentRequest wiresahrk msg
    ...          and DRB,SRB,cellgroup should be recovered
    ...        7.check counter:
    ...        RRC_REESTAB_RECONF_FAILURE_DU:If reestablishmentCause IE is reconfigurationFailure (Counter ID: M55127C00501)
    ...        RRC_REESTAB_RECONF_FAILURE:If reestablishmentCause IE is reconfigurationFailure (Counter ID: M55124C00503)
    ...        REESTAB_ACC_RECONF_FAIL_DU:If reestablishmentCause IE is reconfigurationFailure (Counter ID: M55127C00510)
    ...        REESTAB_ACC_RECONF_FAIL:If reestablishmentCause IE is reconfigurationFailure (Counter ID: M55124C00510)
    ...        REESTAB_RRCRECONFIG_SUCC: Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...        (Counter ID: M55124C00516)
    ...       M55113C00002:EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED
    ...       M55113C00501:EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER
    ...       M55113C00502:EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER
    ...       M55124C03001:EPmCounterId_5G_NRRCC_RRC_RECONF_SENT
    ...       M55124C03002 :EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD
    ...       M55135C00505 :EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT
    ...       M55135C00506:EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD
    ...       M55139C00001 :EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ
    ...       M55139C00002 :EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC
    ...       M55139C00003 :EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ
    ...       M55139C00004 :EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC
    [Tags]    QC_142242
    Clear Counter Files
    Ue Register And Pdu Session Setup At FDD Cell-11
    Start To Capture Wireshark Log    A00100
    Trigger RRC Reestablish with cause    ${ReconfigurationFailure}
    sleep    42    reason=wait finished
    Check Wireshark Log    ${CURDIR}${/}a2a_A001_00${/}a2a.ini    name=A00100    wait_string=UEContextModificationResponse::10
    Start To Capture Wireshark Log    A00101
    Trigger RRC Reestablish with cause    ${ReconfigurationFailure}
    Verify Throughput And Deregister    sleep_time=40s
    Check Counters    ${PM_Counters_Check_5GC000732A001F001}
    Check Wireshark Log    ${CURDIR}${/}a2a_A001_01${/}a2a.ini    name=A00101    wait_string=UEContextReleaseComplete::4
    [Teardown]    Common Test Teardown And Stop Capture Logs

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F

Ue_Deregister
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Trigger RRC Reestablish with cause
    [Arguments]    ${cause}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=11 cause=${cause}
    ...    NR RRC Reestablishment sucessfully completed    timeout=20s

Ue Register And Pdu Session Setup At FDD Cell-11
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink

Verify Throughput And Deregister
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=60    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Ue_Deregister
