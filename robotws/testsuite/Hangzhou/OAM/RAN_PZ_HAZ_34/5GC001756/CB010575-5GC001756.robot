*** Settings ***
Documentation
...  author: Jiang Shengyuan
...  contact: shengyuan.jiang@nokia-sbell.com

Resource   ./Resource/Common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot

Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
...    PY36
...   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEQN_NETACT   SBTS00

Test Timeout   4h

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

*** Variables ***
${ue_index}   ${0}
@{ALL_TEST_STATUS}
*** Test Cases ***
#test fallbac
##    Log To Console   ${ue}
#    Log To Console   ${emil_host}
#    Log To Console   ${emil_user}
#    Log To Console   ${emil_password}

#CB010575-SR-E_001_SA_ClassicalgNBPCMD_Configuration_And_Activation_From_WebEM
#    [Setup]   Case Setup: B_3
#    B_3_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_WebEM
#    [Teardown]   Case Teardown: B_3
#
#Make L3CALL After PCMD Activation
#    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#    ${emil_last_file}   Get Latest Trace File Name By BTSID
#    Set Suite Variable   ${emil_last_file}
#
#    COAM Remove And Add CUUP PCMD Object
#
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    ${iperf_port}   Set Variable If   '${ue_type}'=='nokia_fastmile' or '${ue_type}'=='askey'    58092
#    ...   ${tl.ues[${ue_index}].iperf_details.port}>${50000}   ${tl.ues[${ue_index}].iperf_details.port}
#    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
#    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
#    Run Keyword And Ignore Error   Make L3CALL And Get ALL PCMD MSG   command=tcpdump -i any tcp port 49148 or sctp port 38472   port=${iperf_port}
#
###    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
###    ${file_list}   Get Newest Trace Files By BTSID   bts_id=${MRBTS_ID}   latest_skip_file=${emil_last_file}   local_dir=${OUTPUT_DIR}
###    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
##    Set Suite Variable   ${TXT_FILE}   /home/ute/jsy/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Emil_20231009_1110.txt
##    ${empty_msg_count}   check_empty_pcmd_msg   source_file=${txt_file}
##    Run Keyword If   ${empty_msg_count}>0   Log   PCMD EMPTY MSG COUNT: ${empty_msg_count}. Please Manual Check.   WARN
##    ${all_pcmd_msg}   get_all_pcmd_msgs   source_file=${txt_file}
##    Set Suite Variable   ${ALL_PCMD_MSG}
##    Set Suite Variable   ${TCPDUMP_PATH}   /home/ute/jsy/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/TCPDUMP_20231009_1106.pcap
#
#
##
#CB010575-SR-E_002_SA_ClassicalgNB_StreamingPCMD_Cell_Trace_combined
#    [Setup]   Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND   Case Setup: D_14
#    D_14_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined
#    [Teardown]   Case Teardown: D_14
##
#CB010575-SR-E_003_SA_ClassicalgNB_StreamingPCMD_gNBDU_records
#    [Setup]   Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND   Case Setup: SR-E_003
#    CB010575-SR-E_003_SA_ClassicalgNB_StreamingPCMD_gNBDU_records
#    [Teardown]   Case Teardown: SR-E_003
#
#CB010575-SR-E_004_SA_ClassicalgNB_StreamingPCMD_GnbCU-CP_records
#    [Setup]   Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND   Case Setup: SR-E_004
#    CB010575-SR-E_004_SA_ClassicalgNB_StreamingPCMD_GnbCU-CP_records
#    [Teardown]   Case Teardown: SR-E_004

CB010575_5GC001756_CRT
    [Timeout]    10h
    [Setup]     robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#    List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
    Run Keyword And Continue On Failure    CB010575-SR-E_001_SA_ClassicalgNBPCMD_Configuration_And_Activation_From_WebEM
    Run Keyword And Ignore Error    Make L3CALL After PCMD Activation
    Run Keyword And Continue On Failure    CB010575-SR-E_002_SA_ClassicalgNB_StreamingPCMD_Cell_Trace_combined
    Run Keyword And Continue On Failure    Test_Case_CB010575-SR-E_003_SA_ClassicalgNB_StreamingPCMD_gNBDU_records
    Run Keyword And Continue On Failure    Test_Case_CB010575-SR-E_004_SA_ClassicalgNB_StreamingPCMD_GnbCU-CP_records
    [Teardown]    robot_common_operations.Common Case Teardown

*** Keywords ***
Common Suite Setup
     Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    ${TEST_NAME}   Set Variable   Suite_Setup
#    ${RU3_PA}   Create List   14   13  28   13
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=2   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=3   value=37
    Common Setup 1756
    Get PCMD Value
    ${Reset_Reason}   Get Last Reset from Blackbox
    Set Suite Variable   ${RESET_REASON}
#    Remove And Add PCMD Object
#    ${emil_last_file}   Get Latest Trace File Name By BTSID
#    Set Suite Variable   ${emil_last_file}
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    ${iperf_port}   Set Variable If   '${ue_type}'=='nokia_fastmile' or '${ue_type}'=='askey'    58092
#    ...   ${tl.ues[${ue_index}].iperf_details.port}>${50000}   ${tl.ues[${ue_index}].iperf_details.port}
#    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
#    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
#    Make L3CALL And Get ALL PCMD MSG      command=tcpdump -i any tcp port 49148 or sctp port 38472   port=${iperf_port}
#    ${all_pcmd_timestamp}   get_all_pcmd_timestamp   source_file=${TXT_FILE}
#    Set Suite Variable   ${ALL_PCMD_TIMESTAMP}

Common Suite Teardown
    Run Keyword And Ignore Error   COAM WEBUI Logout
#    Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM
    Common Teardown 1756

CB010575-SR-E_001_SA_ClassicalgNBPCMD_Configuration_And_Activation_From_WebEM
    Case Setup: B_3
    B_3_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_WebEM
    [Teardown]   Case Teardown: B_3

Make L3CALL After PCMD Activation
    ${emil_last_file}   Get Latest Trace File Name By BTSID
    Set Suite Variable   ${emil_last_file}

    COAM Remove And Add CUUP PCMD Object

    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ini_port}    Get Variable Value    ${tl.ues[${ue_index}].iperf_details.port}
    ...    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ${iperf_port}   Set Variable If   '${ue_type}'=='nokia_fastmile' or '${ue_type}'=='askey'    58092
    ...   ${ini_port}>${50000}   ${ini_port}
    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
    Run Keyword And Ignore Error   Make L3CALL And Get ALL PCMD MSG   command=tcpdump -i any tcp port 49148 or sctp port 38472   port=${iperf_port}

CB010575-SR-E_002_SA_ClassicalgNB_StreamingPCMD_Cell_Trace_combined
    Case Setup: D_14
    D_14_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined
    [Teardown]   Case Teardown: D_14
#
Test_Case_CB010575-SR-E_003_SA_ClassicalgNB_StreamingPCMD_gNBDU_records
    Case Setup: SR-E_003
    CB010575-SR-E_003_SA_ClassicalgNB_StreamingPCMD_gNBDU_records
    [Teardown]   Case Teardown: SR-E_003

Test_Case_CB010575-SR-E_004_SA_ClassicalgNB_StreamingPCMD_GnbCU-CP_records
    Case Setup: SR-E_004
    CB010575-SR-E_004_SA_ClassicalgNB_StreamingPCMD_GnbCU-CP_records
    [Teardown]   Case Teardown: SR-E_004