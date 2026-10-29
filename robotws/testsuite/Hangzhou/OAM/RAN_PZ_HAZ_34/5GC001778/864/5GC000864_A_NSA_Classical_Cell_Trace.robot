*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com

# Resource   ../Resource/5GC000864_common.robot

# Force Tags   SG_07   CA_5G_OAM    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABILB1_AEQV_ENB   RAN_5G   RAN_5G_TDD   CRT_UTE
# ...    PY36
# Suite Setup        Cell Trace Suite Setup
# Suite Teardown     Cell Trace Suite Teardown
# Test Setup   Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}   AND
# ...   Test Common Setup
# Test Teardown   Test Common Teardown
# Test Timeout   3h
# *** Variables ***
# ${ENB_PATH}   MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
# @{ALL_TEST_STATUS}

# *** Test Cases ***
# [1]5GC000864_A_002_NSA_ClassicalgNB_Cell_Trace_Session_Configuration_and_Activation_Basic_L3_Call_1ASIK
#     Test Common Step

# [1]5GC000864_A_007_NSA_ClassicalgNB_gNB_Restart_during_Cell_Trace
#     Log To Console    Start BTS Site reset ...
#     ${emil_last_file}   Get Latest Trace File Name
#     selenium_coam.reset_site
#     Sleep   180 sec
#     wait until keyword succeeds   5m   10s   Try Connect gNB
#     wait until keyword succeeds   15m   20s   COAM Check All Cells Onair
#     Test Common Step   emil_last_file=${emil_last_file}

# [1]5GC000864_A_014_NSA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_X2
#     log to console   Set rrc=none x2=all
#     ${cu_remove}   Run keyword and Return Status  selenium_coam.remove_object   object_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
#     Run keyword If   ${cu_remove}   Validate and Activate Plan
#     ${emil_last_file}   Get Latest Trace File Name
#     Log to Console   Start to Add NRMTRACECU with x2 only
#     Add Cell Trace Object of NRMTRACECU   NRCTRLTS=${false}
#     Set Cell Trace CU Flag   celltrace_cu=true   rrc=none    x2=all   xn=none  ngap=none
#     Set PCMD CU Flag   pcmd_flag=false
#     Modify Parameter actCellTraceReport To True
#     Validate and Activate Plan
#     Test Common Step   emil_last_file=${emil_last_file}

# [1]5GC000864_A_021_NSA_ClassicalgNB_Cell_Trace_Secondary_RAT_Data_Usage_Report_by_MN_initiate_SGNB_Release
#     Run Keyword   secondary data usage report Enable
#     Commission Cell Trace CU and PCMD CU Flags
#     Test Common Step   type=file_name
#     [Teardown]   Run Keyword   secondary data usage report Disable

# [1]5GC000864_A_025_NSA_ClassicalgNB_Cell_Trace_SgNBAdditionRequestReject_Msg
#     ${max_users_per_cell}   Get Cell MAX of User
#     Set Cell MAX of User   ue_num=0
#     Commission Cell Trace CU and PCMD CU Flags
#     Test Common Step   type=file_name
#     Set Cell MAX of User   ue_num=${max_users_per_cell}
#     Commission Cell Trace CU and PCMD CU Flags
#     Test Common Step

# [1]5GC000864_A_006_NSA_ClassicalgNB_Cell_Trace_Session_Deactivation_by_Resetting_Feature_Flag
#     Commission Cell Trace CU and PCMD CU Flags
#     Run Keyword   Modify Parameter actCellTraceReport To False
#     Validate and Activate Plan
#     Check Session Setup   setup=${false}
#     Test Common Step   found=${false}
#     [Teardown]   Run Keywords   Modify Parameter actCellTraceReport To True
#     ...   AND   Validate and Activate Plan
#     ...   AND   Test Common Teardown

# [1]5GC000864_A_005_NSA_ClassicalgNB_Cell_Trace_Session_Deactivation_by_Deleting_Object_Instance
#     selenium_coam.remove_object   object_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1
#     Validate and Activate Plan
#     Check Session Setup   setup=${false}
#     ${emil_last_file}   Get Latest Trace File Name
#     Test Common Step   found=${false}   emil_last_file=${emil_last_file}

# [1]5GC000864_A_011_NSA_ClassicalgNB_ClassicBTS_Cell_Trace_Session_TCP_link_lost_with_TCE_1ASIK
#     :FOR   ${cell_trace}   ${PCMD}   IN
#     ...   false   true
#     ...   true   true
#     ...   true   false
#        Commission Cell Trace CU and PCMD CU Flags   cell_trace_flag=${cell_trace}   PCMD_flag=${PCMD}
#        Fault 8000 Create and Delete
#     END
#     [Teardown]   Run Keywords   Tracer Connection Operation
#     ...   AND   Test Common Teardown

# [1]5GC000864_A_051_NSA_ClassicalgNB_Cell_Trace_Deactivation_after_TCP_link_lost
#     Tracer Connection Operation   action=stop
#     Run Keyword and Ignore Error   Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists
#     Commission Cell Trace CU and PCMD CU Flags   session_setup=${false}
#     Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists
#     Run Keyword   Modify Parameter actCellTraceReport To False
#     Validate and Activate Plan
#     Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists   should_exist=${false}
#     Run Keyword   Modify Parameter actCellTraceReport To True
#     Validate and Activate Plan
#     Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists
#     Log to console   Remove MO NRCTRLTS
#     selenium_coam.remove_object   object_name=${INSID}/NRCTRLTS-1
#     Validate and Activate Plan
#     Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists   should_exist=${false}
#     Log to console   Add MO NRCTRLTS
# 	Add Cell Trace Object of NRMTRACECU
# 	Set Cell Trace CU Flag   celltrace_cu=true   rrc=all    x2=all   xn=all  ngap=all
#     Validate and Activate Plan
#     Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists
#     Log to Console   Restore TCE server connection
#     Tracer Connection Operation
#     Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists   should_exist=${false}
#     [Teardown]   Run Keywords   Tracer Connection Operation
#     ...   AND   Test Common Teardown

# [1]5GC000864_A_054_NSA_ClassicalgNB_Cell_Trace_Session_Configuration_and_Activation_Several_Times
#     [Timeout]   5h
#     COAM WEBUI Logout
#     Wait Until Keyword Succeeds   5m   20s   COAM WEBUI Login
#     Commission Cell Trace CU and PCMD CU Flags
#     :FOR   ${retry}    IN RANGE    ${10}
#        Run Keyword   Modify Parameter actCellTraceReport To False
#        Validate and Activate Plan
#        Run Keyword   Modify Parameter actCellTraceReport To True
#        Validate and Activate Plan
#     END
#     ${emil_last_file}   Get Latest Trace File Name
#     Test Common Step   emil_last_file=${emil_last_file}

# [1]5GC000864_A_008_NSA_ClassicalgNB_Cell_Locking_and_Unlocking_during_Cell_Trace
#     ${emil_last_file}   Get Latest Trace File Name
#     Cell Lock Unlock and Check Status with index 1
#     Test Common Step   emil_last_file=${emil_last_file}
#     [Teardown]   Run Keywords   Run Keyword If Test Failed   selenium_coam.unlock_cell    cell_idx=1
#     ...   AND   Test Common Teardown

# [1]5GC000864_A_NSA_ClassicalgNB_Cell_Trace_ALL
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL

# *** Keywords ***

# secondary data usage report ${operation}
#     Run Keyword   ENB ${operation} secondary data usage report
#     Run Keyword   gNB ${operation} secondary data usage report

# ENB ${operation} secondary data usage report
#     ${new_set}   Run Keyword If   '${operation.lower()}'=='enable'   Set Variable   true
#     ...   ELSE   Set Variable   false
#     Run Keyword and Ignore Error   COAM WEBUI Logout
#     ${enb_session}   COAM WEBUI Login   url=https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#     ${enb_actEvtSecRatRep}   selenium_coam.get_parameter_value  dist_name=${ENB_PATH}
#     ...   filter_param=Activate non-periodic secondary RAT usage data report for EN-DC
#     ${actSecRatRep}   selenium_coam.get_parameter_value  dist_name=${ENB_PATH}
#     ...   filter_param=Activate secondary RAT usage data report for EN-DC
#     Run Keyword If   '${enb_actEvtSecRatRep}'!='${new_set}'   selenium_coam.set_parameter_value  dist_name=${ENB_PATH}
#     ...                        filter_param=Activate non-periodic secondary RAT usage data report for EN-DC
#     ...                        new_value=${new_set}
#     Run Keyword If   '${actSecRatRep}'!='${new_set}'   selenium_coam.set_parameter_value  dist_name=${ENB_PATH}
#     ...                        filter_param=Activate secondary RAT usage data report for EN-DC
#     ...                        new_value=${new_set}
#     Run Keyword If   '${enb_actEvtSecRatRep}'!='${new_set}' or '${actSecRatRep}'!='${new_set}'
#     ...   Validate and Activate Plan
#     [Teardown]   Run Keywords   Run Keyword And Ignore Error   COAM WEBUI Logout
#     ...   AND   COAM WEBUI Login

# gNB ${operation} secondary data usage report
#     [Documentation]  enable or disable secondary data usage report
#     ${new_set}   Run Keyword If   '${operation.lower()}'=='enable'   Set Variable   true
#     ...   ELSE   Set Variable   false
#     ${gnb_actEvtSecRatRep}   selenium_coam.get_parameter_value  dist_name=${INSID}
#     ...                        filter_param=Activate secondary data usage report
#     ${ratRepTimer}   selenium_coam.get_parameter_value  dist_name=${INSID}
#     ...                        filter_param=Timer for periodical data usage report
#     Run Keyword If   '${gnb_actEvtSecRatRep}'!='${new_set}'   selenium_coam.set_parameter_value  dist_name=${INSID}
#     ...                        filter_param=Activate secondary data usage report
#     ...                        new_value=${new_set}
#     Run Keyword If   '${ratRepTimer}'!='0'   selenium_coam.set_parameter_value  dist_name=${INSID}
#     ...                        filter_param=Timer for periodical data usage report
#     ...                        new_value=0
#     Run Keyword If   '${gnb_actEvtSecRatRep}'!='${new_set}' or '${ratRepTimer}'!='0'   Validate and Activate Plan

# Get Cell MAX of User
#     [Arguments]   ${index}=1
#     ${max_users_per_ue}   selenium_coam.get_parameter_value  dist_name=${INSID}/NRCELL-${index}
#     ...                        filter_param=Maximum number of users in a NR cell for NSA operation
#     [Return]   ${max_users_per_ue}

# Set Cell MAX of User
#     [Arguments]   ${index}=1   ${ue_num}=1
#     selenium_coam.set_parameter_value  dist_name=${INSID}/NRCELL-${index}
#     ...                        filter_param=Maximum number of users in a NR cell for NSA operation
#     ...                        new_value=${ue_num}

# Fault 8000 Create and Delete
#     Tracer Connection Operation   action=stop
#     Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists
#     Tracer Connection Operation
#     Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists   should_exist=${false}