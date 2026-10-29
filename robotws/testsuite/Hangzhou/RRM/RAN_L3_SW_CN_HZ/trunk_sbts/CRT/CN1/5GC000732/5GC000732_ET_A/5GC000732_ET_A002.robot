*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO    team-SG2
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

@{PM_Counters_Check_5GC000732A002}
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=2
...    NRCELL-11:${RRC_REESTAB_HO_FAILURE}=2
...    NRCELL-11:${REESTAB_ACC_HO_FAIL}=2
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=2
...    NRCELL-11:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}=10
...    NRCELL-11:${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}=11
...    NRCELL-11:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=4
...    NRCELL-11:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=4
...    NRCELL-11:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}=3
...    NRCELL-11:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}=3
...    NRCELL-11:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}=6
...    NRCELL-11:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=6
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}=9
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}=9
...    NRCELL-11:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=15

${RRC_REESTAB_HO_FAILURE_DU}    M55127C00502    #Number of RRC Re-establishment Request caused by HO failure
${RRC_REESTAB_HO_FAILURE}       M55124C00504    #Number of RRC Re-establishment Request caused by HO failure
${REESTAB_ACC_HO_FAIL}          M55124C00511    #Number of accepted RRC Re-establishment when reestablishment cause is HO failure
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

${ReconfigurationFailure}     handoverFailure
${ue_id}    81
${gw_id}    1

*** Test Cases ***
5GC000732-ET-A002_RRC_reestablish_succ_to_ori_cell_due_to_hoFailure_with_valid_UE_context_multi_DRBs
    [Documentation]    This case will test RRC reestablish to ori_cell due to hofailure with 2 drbs.
    ...    Case steps:
    ...        1.Enable rrcReestabTypeSA successfully
    ...        2.UE register successfully
    ...        3.Setup two drbs successfully
    ...        4.Trgger RRC reestablish successfully
    ...        5.Trgger RRC reestablish to cell-11 second time successfully
    ...        6.check cause handoverFailure in rrcReestablishmentRequest wiresahrk msg
    ...          and DRB,SRB,cellgroup should be recovered
    ...        7.check counter
    ...         M55127C00502: RRC_REESTAB_HO_FAILURE_DU
    ...         M55124C00504: RRC_REESTAB_HO_FAILURE
    ...         M55124C00511: REESTAB_ACC_HO_FAIL
    ...         M55124C00516: REESTAB_RRCRECONFIG_SUCC
    ...         M55113C00002: EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED
    ...         M55113C00501: This counter provides the number of DL RRC Message Transfer sent to gNB-DU.
    ...         M55139C00002: The number of admitted radio admission requests for SA user Updated in the DU for new setup
    ...         M55113C00502: This counter provides the number of UL RRC Message Transfer received at gNB-CU.
    ...         M55124C03001: RRC RECONFIGURATION is sent to 5G UE
    ...         M55124C03002: Number of RRC RECONFIGURATION COMPLETE received
    ...         M55135C00505: Number of Bearer Context Modification Request sent by gNB-CU-CP
    ...         M55135C00506: Number of Bearer Context Modification Response received at gNB-CU-CP
    ...         M55139C00001: The number of radio admission requests for SA user in DU
    ...         M55139C00003: The number of non-GBR DRB radio admission requests for SA user in DU
    ...         M55139C00004: The number of radio admitted non-GBR DRBs for SA user in DU
    [Tags]    QC_142241 
    Clear Counter Files
    Ue Register And Pdu Session Setup At FDD Cell-11
    Start To Capture Wireshark Log    A00200
    Trigger RRC Reestablish with cause    ${ReconfigurationFailure}
    sleep    42    reason=wait finished
    Check Wireshark Log    ${CURDIR}${/}a2a_A002_00${/}a2a.ini    name=A00200    wait_string=UEContextModificationResponse::6
    Start To Capture Wireshark Log    A00201	
    Trigger RRC Reestablish with cause    ${ReconfigurationFailure}
    Verify Throughput And Deregister    sleep_time=40s
    Check Counters    ${PM_Counters_Check_5GC000732A002}
    Check Wireshark Log    ${CURDIR}${/}a2a_A002_01${/}a2a.ini    name=A00201    wait_string=UEContextReleaseComplete::4
    [Teardown]    Common Test Teardown And Stop Capture Logs

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71
	
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
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    pass_regexp=QoS Routing Table
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
