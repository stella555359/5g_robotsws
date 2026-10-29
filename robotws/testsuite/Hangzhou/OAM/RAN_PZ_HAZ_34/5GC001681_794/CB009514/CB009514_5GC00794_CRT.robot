*** Settings ***
Documentation
...    author: Casbo Xing
...    contact: casbo.xing@nokia-sbell.com
...    Fro regression of 5GC000794 parity to CB009514
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/CB009514/Resource.robot


Suite Setup    Run Keywords   common.Common Setup
...   AND    Pre&Post Conditoin: Update Configuration of actEcpri72e     celltype=4t4r
...  AND   run keyword and continue on failure    Cplane log Setup
Suite Teardown    run keywords   CP and UP log Teardown
...   AND   Pre&Post Conditoin: Update Configuration of actEcpri72e     celltype=default

*** Variables ***
${XN_status}
${ZMQ_status}
${CPNRT_status}
${CPRT_status}
${CPIF_status}
${COAM_status}
${CPUE_status}
${NSA_status}
${bbmod_reset_for_1808}    ${false}

*** Test Cases ***
CB009514_5GC000794_ABIP_CRT
    [Setup]  Case Setup: CB009514_CRT
    run keyword and continue on failure   CB009514_1_5GC001808_RRC_XN_NG_ZMQ_and_SYSCOM_via_Emil_1681_RETRY_TEST_for_ABIP
    run keyword and continue on failure   CB009514_2_5GC001808_RRC_XN_NG_ZMQ_and_SYSCOM_via_Emil_1681_RETRY_TEST_for_ABIP
    run keyword and continue on failure   CB009514_3_5GC001808_D_TTI_Trace_Analyses_Tool_Decode_bin_file_for_ABIP
    run keyword and continue on failure   CB009514_4_5GC001808_D_TTI_Trace_Analyses_Tool_Decode_pcap_file_for_ABIP
    run keyword and continue on failure   CB009514_6_Recommission_Type_of_actEcpri72e
    [Teardown]  Case Teardown: CB009514_CRT

*** Keywords ***
CB009514_1_5GC001808_RRC_XN_NG_ZMQ_and_SYSCOM_via_Emil_1681_RETRY_TEST_for_ABIP
    [Timeout]    60min
    Case Setup: CB009514_CRT
    Check SA Msg in the Log    log_path=${output_txt_path}
    [Teardown]  Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"   Collect Snapshot and Screenshot If Keyword Failed


CB009514_2_5GC001808_RRC_XN_NG_ZMQ_and_SYSCOM_via_Emil_1681_RETRY_TEST_for_ABIP
    Case Setup: CB009514_CRT
    Check Xn Msg in the Log    log_path=${output_txt_path}
    Check Zmq Msg in the Log    log_path=${output_txt_path}
    Check CP-NRT Syscom messages    log_path=${output_txt_path}
    Check CP-RT Syscom messages    log_path=${output_txt_path}
    Check CP-IF Syscom messages    log_path=${output_txt_path}
    Check COAM Syscom messages   log_path=${output_txt_path}
    Check CP-UE Syscom messages    log_path=${output_txt_path}
    [Teardown]  Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"   Collect Snapshot and Screenshot If Keyword Failed

CB009514_3_5GC001808_D_TTI_Trace_Analyses_Tool_Decode_bin_file_for_ABIP
    [Timeout]    60min
    Case Setup: CB009514_CRT
    L3 CALL For TTI Bin Prepare
    ${key_TTI}    check snapshot_TTI
    Check TTI Decoder Tool    input_file=${key_TTI}
    [Teardown]  Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"   Collect Snapshot and Screenshot If Keyword Failed

CB009514_4_5GC001808_D_TTI_Trace_Analyses_Tool_Decode_pcap_file_for_ABIP
    [Timeout]    60min
    Case Setup: CB009514_CRT
    ${gnb_custom_profile}   create list    L2Ps_Component
    Cplane and Uplane log Setup For Case   operation=sleep  gnb_custom_profile=${gnb_custom_profile}
    Check TTI Decoder Tool    ${l2ps_log_path}
    [Teardown]  Run keywords
    ...    Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"   Collect Snapshot and Screenshot If Keyword Failed
    ...    AND   CP and UP log Teardown

#CB009514_5_5GC001808_C_CP-Cell_CP-NB_Syscom_messages_can_be_activated_and_deactivated_via_Emil_for_ABIP
#    [Timeout]    60min
#    Case Setup: CB009514_CRT
#    ${gnb_custom_profile}   create list    cp_5g
#    run keyword unless    ${bbmod_reset_for_1808}    Cplane log Setup   operation=resetrat  gnb_custom_profile=${gnb_custom_profile}
#    Check CP-CELL Syscom messages    log_path=${output_txt_path}  # need gnb reboot
#    Check CP-NB Syscom messages    log_path=${output_txt_path}     # need gnb reboot
#    [Teardown]    Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Collect Snapshot and Screenshot If Case Failed

CB009514_6_Recommission_Type_of_actEcpri72e
    [Timeout]    60min
    Case Setup: CB009514_CRT
    Pre&Post Conditoin: Update Configuration of actEcpri72e     celltype=2t4r
    Pre&Post Conditoin: Update Configuration of actEcpri72e     celltype=4t4r
    [Teardown]    Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Collect Snapshot and Screenshot If Keyword Failed


Case Setup: CB009514_CRT
    robot_common_operations.Common Case Setup
    Run Keyword and Ignore Error   Start Syslog Collection

Case Teardown: CB009514_CRT
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown

CP and UP log Teardown
    log to console   \n Cplane and Uplane loge Teardown
    robot_common_operations.Common Suite Teardown
    run keyword and ignore error    Stop DCAP log
    run keyword and ignore error    Dcap delete trace    trace_id=${result_id}
    run keyword and ignore error    Dcap delete bts    bts_id=${dcap_create_id}
    run keyword and ignore error    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}