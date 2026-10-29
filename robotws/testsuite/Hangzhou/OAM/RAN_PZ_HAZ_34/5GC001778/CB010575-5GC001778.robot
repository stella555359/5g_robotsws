*** Settings ***
Documentation
...  author: Heng Liangliang
...  contact: jingmin.he@nokia-sbell.com   liangliang.heng@nokia-sbell.com

Resource   Resource/5GC001778_B_003_keywords.robot
Resource   Resource/collect_log.robot
Library    ./libraries/emil_messages.py

Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
...    PY36

Suite Setup    test suite setup
Suite Teardown    Cell Trace Suite Teardown   collect_log=${False}
Test Setup   Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND   Case Common Setup
Test Teardown   Case Common Teardown
Test Timeout   6h

*** Variables ***
@{message_not_traced_list_010}    UL-CCCH-Message    UL-DCCH-Message    DL-DCCH-Message    DL-CCCH-Message    XNAP-PDU    X2AP-PDU
@{message_not_traced_list_007}    NGAP-PDU    XNAP-PDU    X2AP-PDU

@{ALL_TEST_STATUS}
*** Test Cases ***
#CB010575-SR-E_005_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NR_RRC
#    [Documentation]  If only interface RRC is set to all, only masseage from RRC interface will be traced.
#    [Setup]   Case Common Setup
##    wait until keyword succeeds  3x   30s   Remove Cell Trace Object
#    ${trace_file}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#    Close Web Startup View Window
##    Prepare Power UE   ue_index=${ue_index}
#    Add Cell Trace Object Without Activate   x2=none   xn=none   ngap=none
#    Modify Parameter actCellTraceReport to True
#    Validate and Activate Plan
#    Close Web Startup View Window
#    Run Keyword and Continue On Failure   Wait Until Keyword Succeeds   3x   20s   Call Setup Successfully
#    ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${trace_file}   local_dir=${OUTPUT_DIR}
#    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
#    ${target_file}   Get Test Json File
#    check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#    :FOR    ${message_not_traced}    IN    @{message_not_traced_list_007}
#        ${filter_res}   Run    cat ${txt_file} | grep ${message_not_traced}
#        Should Be Empty    ${filter_res}
#    END
#
#CB010575-SR-E_006_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NGAP
#    [Documentation]  If only interface RRC is set to all, only masseage from RRC interface will be traced.
#    ${trace_file}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#    Close Web Startup View Window
##    Prepare Power UE   ue_index=${ue_index}
#    Add Cell Trace Object Without Activate   x2=none   xn=none   rrc=none
#    Modify Parameter actCellTraceReport to True
#    Validate and Activate Plan
#    Close Web Startup View Window
#    Run Keyword and Continue On Failure   Wait Until Keyword Succeeds   3x   20s   Call Setup Successfully
#    ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${trace_file}   local_dir=${OUTPUT_DIR}
#    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
#    ${target_file}   Get Test Json File
#    check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#    :FOR    ${message_not_traced}    IN    @{message_not_traced_list_010}
#        ${filter_res}   Run    cat ${txt_file} | grep ${message_not_traced}
#        Should Be Empty    ${filter_res}
#    END

CB010575_5GC001778_CRT
    [Timeout]    5h
    [Setup]     robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#    List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
    Run Keyword And Continue On Failure    CB010575-SR-E_005_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NR_RRC
    Run Keyword And Continue On Failure    CB010575-SR-E_006_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NGAP
    [Teardown]    robot_common_operations.Common Case Teardown
*** Keywords ***
test suite setup
#    [Arguments]   ${cell_trace_flag}=true   ${PCMD_flag}=false   ${cell_trace_details}=all   ${l3call}=${true}
    robot_common_operations.Common Suite Setup
#    ${RU3_PA}   Create List   14   13  28   13
    Run Keyword And Ignore Error   Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=2   value=127
    Run Keyword And Ignore Error   Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=3   value=37
#    COAM Try Connect gNB
#    COAM Login
#    Case Common Setup
    set suite variable   ${suite_setup}   ${true}

Call Setup Successfully
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ini_port}    Get Variable Value    ${tl.ues[${ue_index}].iperf_details.port}
    ...    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ${iperf_port}   Set Variable If   '${ue_type}'=='nokia_fastmile' or '${ue_type}'=='askey'    58092
    ...   ${ini_port}>${50000}   ${ini_port}
    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
    Call Setup and check tput   tput=10   tput_expect=0   port=${iperf_port}
    [Teardown]   Run Keyword If   $KEYWORD_STATUS=='FAIL'   Restore gNB ENV

CB010575-SR-E_005_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NR_RRC
    [Documentation]  If only interface RRC is set to all, only masseage from RRC interface will be traced.
    Case Common Setup
#    wait until keyword succeeds  3x   30s   Remove Cell Trace Object
    ${trace_file}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
    COAM Add Trace Object
#    Close Web Startup View Window
##    Prepare Power UE   ue_index=${ue_index}
#    Add Cell Trace Object Without Activate   x2='none'   xn='none'   ngap='none'
#    Modify Parameter actCellTraceReport to True
#    Validate and Activate Plan
#    Close Web Startup View Window
    Run Keyword and Continue On Failure   Wait Until Keyword Succeeds   3x   20s   Call Setup Successfully
    ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${trace_file}   local_dir=${OUTPUT_DIR}
    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
    ${target_file}   Get Test Json File   case_name=CB010575-SR-E_005_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NR_RRC
    check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
    FOR    ${message_not_traced}    IN    @{message_not_traced_list_007}
        ${filter_res}   Run    cat ${txt_file} | grep ${message_not_traced}
        Should Be Empty    ${filter_res}
    END
    [Teardown]  Case Common Teardown

CB010575-SR-E_006_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NGAP
    [Documentation]  If only interface RRC is set to all, only masseage from RRC interface will be traced.
    Case Common Setup
    ${trace_file}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
    COAM Add Trace Object     cell_trace_only='rrc'
#    Close Web Startup View Window
##    Prepare Power UE   ue_index=${ue_index}
#    Add Cell Trace Object Without Activate   x2='none'   xn='none'   rrc='none'
#    Modify Parameter actCellTraceReport to True
#    Validate and Activate Plan
#    Close Web Startup View Window
    Run Keyword and Continue On Failure   Wait Until Keyword Succeeds   3x   20s   Call Setup Successfully
    ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${trace_file}   local_dir=${OUTPUT_DIR}
    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
    ${target_file}   Get Test Json File   case_name=CB010575-SR-E_006_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NGAP
    check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
    FOR    ${message_not_traced}    IN    @{message_not_traced_list_010}
        ${filter_res}   Run    cat ${txt_file} | grep ${message_not_traced}
        Should Be Empty    ${filter_res}
    END
    [Teardown]  Case Common Teardown
