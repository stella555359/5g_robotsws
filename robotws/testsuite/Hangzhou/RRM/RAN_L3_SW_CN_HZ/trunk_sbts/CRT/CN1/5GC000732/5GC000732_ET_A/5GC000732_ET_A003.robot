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
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRPMRNL:miNrRelReportCu=15min
...    NRBTS-1:tWaitingRlRecover=4000ms


@{PM_Counters_Check_5GC000732A003}
...    NRDU-1:${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRDU-1:${RRC_REESTAB_ACC_OTHER_FAIL_DU}=2
...    NRCELL-11:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-12:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-12:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-11:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-12:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-11:${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}=5
...    NRCELL-12:${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}=3
...    NRCELL-11:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}=5
...    NRCELL-12:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}=3
...    NRCELL-12:${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}=2
...    NRCELL-11:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=11
...    NRCELL-12:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=2
...    NRCELL-11:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=2
...    NRCELL-12:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=1
...    NRCELL-11:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=2
...    NRCELL-12:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=1
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}=7
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}=7


${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503    #Number of RRC Re-establishment Request caused by other failure
${RRC_REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512    #Number of accepted RRC Re-establishment when reestablishment cause is other failure
${RRC_REESTAB_OTHER_FAILURE}       M55124C00505    #Number of RRC Re-establishment Request caused by HO failure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #Number of RRC reconfiguration successful in RRC reestablishment procedure
${REESTAB_ADMISSION_CRTL}    M55124C00519    #Number of admission control triggered in CU by RRC reestablishment procedure
${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001    #Number of outgoing UE CONTEXT MODIFICATION REQUEST sent to gNB-DU
${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002    #Number of incoming UE CONTEXT MODIFICATION RESPONSE received from gNB-DU
${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501    #Number of DL RRC Message Transfer sent.
${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502    #Number of UL RRC Message Transfer received.
${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}    M55124C03001    #Number of RRC RECONFIGURATION sent
${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002    #Number of RRC RECONFIGURATION COMPLETE received
${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}    M55135C00505    #Number of Bearer Context Modification Request sent by gNB-CU-CP
${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}    M55135C00506    #Number of Bearer Context Modification Response received at gNB-CU-CP


${ReconfigurationFailure}    otherFailure
${ue_id}    81
${gw_id}    1

*** Test Cases ***
5GC000732-ET-A003_RRC_reestablish_succ_to_new_cell_due_to_otherFailure_with_valid_UE_context
    [Documentation]    TThis case will test RRC reestablish to ori_cell due to otherFailure with valid UE context.
    ...    Case steps:
    ...    1.Trigger normal call with cell 12
    ...    2.Trgger RRC reestablish from cell 12 to cell 11
    ...    3.Check cause and counters
    ...    REESTAB_RRCRECONFIG_SUCC: Number of RRC reconfiguration successful in RRC reestablishment procedure 
    ...    (Counter ID: M55124C00516)
    ...    REESTAB_ADMISSION_CRTL: (M55124C00519)
    ...    M55113C00001: EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT
    ...    M55113C00002: EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED
    ...    M55113C00501: This counter provides the number of DL RRC Message Transfer sent to gNB-DU.
    ...    M55113C00502: EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER
    ...    M55124C03001: RRC RECONFIGURATION is sent to 5G UE
    ...    M55124C03002: EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD
    ...    M55135C00505: EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT
    ...    M55135C00506: EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD
    ...    M5512400505: RRC_REESTAB_OTHER_FAILURE: If reestablishmentCause IE is otherFailure
    ...    M55127C00512: REESTAB_ACC_OTHER_FAIL_DU: If reestablishmentCause IE is otherFailure
    [Tags]    QC_142240 
    Clear Counter Files
    Ue Register And Pdu Session Setup At FDD Cell-11
    Start To Capture Wireshark Log    A00300
    Trigger RRC Reestablish with cause    12    ${ReconfigurationFailure}
    sleep    42    reason=wait finished
    Check Wireshark Log    ${CURDIR}${/}a2a_A003_00${/}a2a.ini    name=A00300    wait_string=UEContextModificationResponse::6
    Start To Capture Wireshark Log    A00301	
    Trigger RRC Reestablish with cause    11    ${ReconfigurationFailure}
    Verify Throughput And Deregister    sleep_time=40s
    Check Counters    ${PM_Counters_Check_5GC000732A003}
    Check Wireshark Log    ${CURDIR}${/}a2a_A003_01${/}a2a.ini    name=A00301    wait_string=UEContextReleaseComplete::4
    [Teardown]    Common Test Teardown And Stop Capture Logs

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F
	
Ue_Deregister
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Trigger RRC Reestablish with cause
    [Arguments]    ${cell_id}    ${cause}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
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
