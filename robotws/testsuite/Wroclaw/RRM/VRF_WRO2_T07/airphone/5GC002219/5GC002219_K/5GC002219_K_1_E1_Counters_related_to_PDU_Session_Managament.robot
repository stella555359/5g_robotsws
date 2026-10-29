*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00
...           CONFIGURED    RAN_5G_TDD    RAN_5G    PY310
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wiśniewska
...              :contact: katarzyna.wisniewska@nokia.com

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Variables    ta5g_global_var

Library      ta5g_egate
Library      ta5g_pm_counters

Suite Setup    Run Keywords     Start Default Logging And Reach Onair
    ...                         lua_cfg_filepath=${CURDIR}/../../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
    ...                         output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...         AND             Perform Parameter Commissioning    parameter=actSeparatePduRelForGtpuError    value=false
    ...         AND             Set Counter Collecting Interval To Five Minutes
    ...         AND             Wait For Next Full Pm Interval
    ...         AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{pdu_ids_list} =    3    4

*** Test Cases ***
5GC002219_K_1_E1_Counters_related_to_PDU_Session_Managament
    [Tags]    CIT    RAN_5G_FDD    SBTS23R1    SBTS22R4
    [Documentation]   Correct handling of E1 counters related to successful Initial Context Setup and PDU Session Resource Setup procedures.
    [Setup]       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=1
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue    ue_id=1
    Establish Multiple Pdu Sessions    pdu_ids_list=@{pdu_ids_list}    ue_id=1
    Verify Ngap Messages    packet_filter=ngap.PDUSessionResourceSetupListCxtRes == 1 && ngap.pDUSessionID == 3
    Release PDU Session    ue_id=1    pdu_id=3    initiator=ue
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55135C00501    +1    NE1CS_CTXT_SETUP_REQ_SENT
        ...    M55135C00502    +1    NE1CS_CTXT_SETUP_RSP_RECD
        ...    M55135C00505    +4    NE1CS_CTXT_MOD_REQ_SENT
        ...    M55135C00506    +4    NE1CS_CTXT_MOD_RSP_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${pm_counter_file}
        ...    report_pm_counter=True
    Verify Any Counters In File
        ...    M55133C01001    +1    NE1US_CTXT_SETUP_REQ_RECD
        ...    M55133C01002    +1    NE1US_CTXT_SETUP_RSP_SENT
        ...    M55133C01004    +4    NE1US_CTXT_MOD_REQ_RECD
        ...    M55133C01005    +4    NE1US_CTXT_MOD_RSP_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
        ...    file_path=${pm_counter_file}
        ...    report_pm_counter=True
    Verify Any Counters In File
        ...    M55125C02501    1    NNGCC_UE_CTXT_STP_REQ_RECD
        ...    M55125C02502    1    NNGCC_UE_CTXT_STP_RESP_SENT
        ...    M55124C03003    1    NRRCC_SEC_MOD_CMD_SENT
        ...    M55124C03004    1    NRRCC_SEC_MOD_CMP_RECD
        ...    M55125C02504    1    NNGCC_PDU_SES_STP_REQ_RECD
        ...    M55125C02505    1    NNGCC_PDU_SES_STP_RESP_SENT
        ...    M55124C03001    4    NRRCC_RRC_RECONF_SENT
        ...    M55124C03002    4    NRRCC_RRC_RECONF_CMP_RECD
        ...    M55125C02507    1    NNGCC_PDU_SES_REL_CMD_RECD
        ...    M55125C02508    1    NNGCC_PDU_SES_REL_RESP_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}
        ...    report_pm_counter=True
    Add Scout External Execution ID To Reporting Portal

5GC002219_K_2_E1_Counters_related_to_752_I_GTPU_Errors_via_Bearer_Error_Indication
    [Tags]    CRT    SBTS23R2    SBTS23R1
    [Documentation]   Correct handling of E1 counters related to GTP-U Error Indication.
    [Setup]       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=2
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=1    gw_id=1
    Send Gtpu Error Indication For Pdu Session By Upf
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log      packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUIRED}
    Verify Tcpdump Log      packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_CONFIRM}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55135C00509    +1    NE1CS_CTXT_MOD_REQD_RECD
        ...    M55135C00510    +1    NE1CS_CTXT_MOD_CONF_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${pm_counter_file}
        ...    report_pm_counter=True
    Verify Any Counters In File
        ...    M55133C01007    +1    NE1US_CTXT_MOD_CONF_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
        ...    file_path=${pm_counter_file}
        ...    report_pm_counter=True
    Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Send Gtpu Error Indication For Pdu Session By Upf
    Execute Egate Command    cmd=ue_pdu_upf_inject_error_ind id=1 ue=2 pdu=1 abnormal_scenario=none
