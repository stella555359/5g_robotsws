*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           CRT    RAN_5G_FDD    RAN_5G    GQC_PLAN:DESIGNER:sukl    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Radu Turcu
...              :contact: radu.turcu@nokia.com

Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
#Library       resources/CB008529-lib.py
Library      ta5g_tshark
#Library      ta5g_setups_and_teardowns
#Variables    ta5g_global_var
Library      ta5g_ue_mobility
Library      ute_tshark
Variables    ta5g_global_var
Library       ta5g_pm_counters
Library       ute_reporting_portal

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes

*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_EXAMPLE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU}   delta_vdu=${DELTA_VDU}
${DELTA_VCU}     ${CURDIR}/configs/delta_vcu.xml
${DELTA_VDU}     ${CURDIR}/configs/delta_vdu.json
${setup_srb_drb_InactivityTimers}       ${CURDIR}/configs/setup_srb_drb_InactivityTimers.json
@{PM_OBJECTS_LIST_VCU}           NNGCC    NRRCC    NF1CC      NE1US
@{PM_OBJECTS_LIST_VDU}           NF1CD

${F1AP_UE_CONTEXT_RELEASE_REQUEST}      f1ap.UEContextReleaseRequest_element
${F1AP_UE_CONTEXT_RELEASE_COMMAND}      f1ap.UEContextReleaseCommand_element
${F1AP_UE_CONTEXT_RELEASE_COMPLETE}     f1ap.UEContextReleaseComplete_element

${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}      e1ap.BearerContextReleaseCommand_element
${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}     e1ap.BearerContextReleaseComplete_element

${NGAP_UE_CONTEXT_RELEASE_COMPLETE}     ngap.UEContextReleaseComplete_element
${NGAP_UE_CONTEXT_RELEASE_REQUEST}      ngap.UEContextReleaseRequest_element
${NGAP_UE_CONTEXT_RELEASE_COMMAND}      ngap.UEContextReleaseCommand_element

${TimerNGSignalingConnGuard}=       2500

*** Test Cases ***
5GC000728_H_12_No_NG_Response_For_Ue_Context_Release_Request_Handling
    [Documentation]    Despite no response for NGAP: UE CONTEXT RELEASE REQUEST, UE context is released after TimerNGSignalingConnGuard
    ...     Requirement ID:                            config=&{CONFIG_EXAMPLE}
    [Setup]    Test Case Setup    reach_on_air=without_x2_link        reboot_after_config=no
    Log to console     start test
    Upload delta vcu    ${setup_srb_drb_InactivityTimers}
    ${inactivity_time}    set variable      50
    Configure Amf To Not Send Response For Ue Context Release
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    Sleep   20
    ta5g_ue_mobility.Attach Ue    ue_id=1
    ta5g_ue_mobility.Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Sleep    ${inactivity_time}
    Verify UE Context Is Released Without NG Response
    Verify Release Is Triggered After Expiration Of TimerNGSignalingConnGuard
    stop tcpdump on remote interface

    ${dirpath}  Set Variable   ${OUTPUT DIR}/Logs/${TEST NAME}/
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    &{pm_files_dict}    get_next_vran_unpacked_full_pm_counters_files    output_dirpath=${dirpath}     timeout=3600      expected_interval=5

    verify last counters in file
    ...  M55125C00501   0       NNGCC_UE_CTXT_REL_CMD_RECD
    ...  M55125C00502   0       NNGCC_UE_CTXT_REL_CMP_SENT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
#    ...  measurement_type=NNGCC

    verify last counters in file
    ...  M55124C00001   1       NRRCC_RRC_RELEASE_SENT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NRRCC

    verify last counters in file
    ...  M55113C01009   1       NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010   1       NF1CC_UE_CTXT_REL_CMP_RECD
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NF1CC

    verify last counters in file
    ...  M55117C01010   1       NF1CD_UECTXT_REL_CMPSENT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...  file_path=${pm_files_dict.vdu}
    ...  measurement_type=NF1CD

    verify last counters in file
    ...  M55133C00001     1       NE1US_CTXT_REL_CMD_RECD
    ...  M55133C00002     1       NE1US_CTXT_REL_CMP_SENT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NE1US

    Report pm counter    M55125C00501  1           Passed
	Report pm counter    M55125C00502  1           Passed
	Report pm counter    M55124C00001  1           Passed
	Report pm counter    M55113C01009  1           Passed
	Report pm counter    M55113C01010  1           Passed
	Report pm counter    M55117C01010  1           Passed
	Report pm counter    M55133C00001  1           Passed
	Report pm counter    M55133C00002  1           Passed

	Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate

*** Keywords ***
Configure Amf To Not Send Response For Ue Context Release
    Execute Egate Command    cmd=amf_ue_ctx_release_param id=1 action=no_response

Should Be Equal As Miliseconds
    [Arguments]    ${time_in_seconds}    ${time_in_miliseconds}    ${tolerance}=6
    ${diff}=     Evaluate    abs(${time_in_Seconds}*1000-${time_in_miliseconds})
    Run Keyword If    ${diff} > ${tolerance}    Fail    Time difference ${diff}ms is greater than given tolerance ${tolerance}ms
#
Verify Release Is Triggered After Expiration Of TimerNGSignalingConnGuard
#    ${TimerNGSignalingConnGuard}=    Get Admin Object Parameter Value    parameter_name=timerNGSignalingConnGuard
    ${time_between_ngap_release_request_and_f1ap_release_complete}=    Time Between Two Tshark Messages
    ...    alias=tshark_testcase_aic    #${DEFAULT_TCPDUMP_ALIAS}
    ...    filter1=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    ...    filter2=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    ...    output_pdml_filepath1=${OUTPUT_DIR}/${TEST_NAME}/ngap_ue_context_release_request.pdml
    ...    output_pdml_filepath2=${OUTPUT_DIR}/${TEST_NAME}/f1ap_ue_context_release_command.pdml
    ...    pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    Should Be Equal As Miliseconds    ${time_between_ngap_release_request_and_f1ap_release_complete}    ${TimerNGSignalingConnGuard}



Verify UE Context Is Released Without NG Response
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_UE_CONTEXT_RELEASE_REQUEST}
    ...     pass_criteria= ==0
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    ...     pass_criteria= ==1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    ...     pass_criteria= ==1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    ...     pass_criteria= ==1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}
    ...     pass_criteria= ==1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    ...     pass_criteria= ==1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    ...     pass_criteria= ==0
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    ...     pass_criteria= ==0
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10
