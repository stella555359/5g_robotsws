*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           CRT    RAN_5G_FDD    RAN_5G    GQC_PLAN:DESIGNER:sukl    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Pawel Gniewek
...              :contact: pawel.gniewek@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_tshark
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Library      ta5g_enb
Library      ta5g_delta

Suite Setup    Run Keywords    Start Default Logging And Reach Onair    lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=setup_srb_drb_InactivityTimers.json
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Run Keywords  Roll Delta Back
...                            initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                            delta_scf_filename=setup_srb_drb_InactivityTimers.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000728_H_12_No_NG_Response_For_Ue_Context_Release_Request_Handling
    [Documentation]    Despite no response for NGAP: UE CONTEXT RELEASE REQUEST, UE context is released after TimerNGSignalingConnGuard
    ${inactivity_time}=   Get Admin Object Parameter Value    parameter_name=drbInactivityTimerSA
    Configure Amf To Not Send Response For Ue Context Release
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Sleep    ${inactivity_time}
    Verify UE Context Is Released Without NG Response
    Verify Release Is Triggered After Expiration Of TimerNGSignalingConnGuard
    Wait For Next Full Pm Interval

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55125C00501  +0  NNGCC_UE_CTXT_REL_CMD_RECD
    ...    M55125C00502  +0  NNGCC_UE_CTXT_REL_CMP_SENT
    ...    M55113C01009  +1  NF1CC_UECTXT_REL_CMDSENT
    ...    M55124C00001  +1  NRRCC_RRC_RELEASE_SENT
    ...    M55113C01010  +1  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...    M55117C01010  +1  NF1CD_UECTXT_REL_CMPSENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...    M55133C00001  +1  NE1US_CTXT_REL_CMD_RECD
    ...    M55133C00002  +1  NE1US_CTXT_REL_CMP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...    file_path=${pm_counter_file}

*** Keywords ***
Verify UE Context Is Released Without NG Response
    Verify Tcpdump Log      packet_filter=${F1AP_UE_CONTEXT_RELEASE_REQUEST}    number_of_messages=0
    Verify Tcpdump Log      packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}    number_of_messages=1
    Verify Tcpdump Log      packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=1
    Verify Tcpdump Log      packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}    number_of_messages=1
    Verify Tcpdump Log      packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}    number_of_messages=1
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}    number_of_messages=1
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}    number_of_messages=0
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=0

Configure Amf To Not Send Response For Ue Context Release
    Execute Egate Command    cmd=amf_ue_ctx_release_param id=1 action=no_response

Should Be Equal As Miliseconds
    [Arguments]    ${time_in_seconds}    ${time_in_miliseconds}    ${tolerance}=6
    ${diff}=     Evaluate    abs(${time_in_Seconds}*1000-${time_in_miliseconds})
    Run Keyword If    ${diff} > ${tolerance}    Fail    Time difference ${diff}ms is greater than given tolerance ${tolerance}ms

Verify Release Is Triggered After Expiration Of TimerNGSignalingConnGuard
    ${TimerNGSignalingConnGuard}=    Get Admin Object Parameter Value    parameter_name=timerNGSignalingConnGuard
    ${time_between_ngap_release_request_and_f1ap_release_complete}=    Time Between Two Tshark Messages
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter1=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    ...    filter2=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    ...    output_pdml_filepath1=${OUTPUT_DIR}/${TEST_NAME}/ngap_ue_context_release_request.pdml
    ...    output_pdml_filepath2=${OUTPUT_DIR}/${TEST_NAME}/f1ap_ue_context_release_command.pdml
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    Should Be Equal As Miliseconds    ${time_between_ngap_release_request_and_f1ap_release_complete}    ${TimerNGSignalingConnGuard}
