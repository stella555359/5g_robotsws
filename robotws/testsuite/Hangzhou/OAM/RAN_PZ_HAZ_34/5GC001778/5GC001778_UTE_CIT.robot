*** Settings ***
Documentation
...  author: Heng Liangliang
...  contact: jingmin.he@nokia-sbell.com   liangliang.heng@nokia-sbell.com
# Resource   Resource/5GC001778_B_003_keywords.robot
# Resource   Resource/collect_log.robot
# Library    ./libraries/emil_messages.py

# Force Tags   SG_07   CA_5G_OAM    CIT_20B   CIT_21A   CIT   master_classicalbts_all   CIT_21B   CIT_22R1
# ...    PY36
# ...   5G_RAN_TDD   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEQN_NETACT   STATE_SW_UPLOADED   5G_RAN   SBTS00
# ...   RAN_5G   RAN_5G_TDD

# Suite Setup    test suite setup
# Suite Teardown    Cell Trace Suite Teardown   collect_log=${False}
# Test Setup   Case Common Setup
# Test Teardown   Case Common Teardown
# Test Timeout   6h

# *** Variables ***
# @{005_key_error}    NRBTS.distname equal to NRRESOURCECU-1.resourceDN
#                ...   quantity of NRRESOURCECU equal to 1
# @{004_key_error}   TCE-* having NRMTRACECU-1.nrTceIdentifier (value: 1) equal to TCE.tceIdentifier
#                ...   There should exist such an instance of TCE for which
# @{009_key_error}    NRBTS.distname equal to NRRESOURCEDU-1.resourceDN
#                 ...   quantity of NRRESOURCEDU equal to 1
# @{message_not_traced_list_010}    UL-CCCH-Message    UL-DCCH-Message    DL-DCCH-Message    DL-CCCH-Message    XNAP-PDU    X2AP-PDU
# @{message_not_traced_list_007}    NGAP-PDU    XNAP-PDU    X2AP-PDU
# @{017_key_error}   Whenever NRRESOURCECU-1 having NRRESOURCECU-1.typeNrCu (value: cell) equal to cell, it is required that embedded assertion valid
#          ...   Whenever NRRESOURCEDU-1 having NRRESOURCEDU-1.typeNrDu (value: cell) equal to cell, it is required that embedded assertion valid
# @{018_key_error}   the number of MOs NRRESOURCECU-* under MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCTRLTS-1/NRMTRACECU-1 equal to 0
#                ...   the number of MOs NRRESOURCEDU-* under MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1 equal to 0
# *** Test Cases ***
# [1]5GC001778_A_005_SA_Classical_Cell_Trace_PDU_Session_Setup_and_release
#     [Documentation]  This case is to check SA basical L3call masseges of PDU session setup and release can be collectly traced.
#     [Setup]     robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     ${target_file}   Get Test Json File
#     check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
#     ...   AND   CI_interface.Common Case Teardown

# [1]5GC001778_A_006_SA_Classical_Cell_Trace_SA_basical_L3call
#     [Documentation]  This case is to check SA basical L3call masseges can be collectly traced.
#     [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     ${target_file}   Get Test Json File
#     check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
#     ...   AND   CI_interface.Common Case Teardown

# [1]5GC001778_A_013_SA_Classical_Cell_Trace_SA_messages_RRCRelease
#     [Documentation]  This case is to check SA basical L3call massege of RRCRelease can be collectly traced.
#     [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     ${target_file}   Get Test Json File
#     check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
#     ...   AND   CI_interface.Common Case Teardown

# [1]5GC001778_B_006_SA_ClassicalgNB_Cell_Trace_Session_Not_Possiable_with_actCellTraceReporting_False
#     [Documentation]  If actCellTraceReport is set to false, there will be no cell trace session created.
#     [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     Close Web Startup View Window
#     Feature flag set to False
#     Wait Until Keyword Succeeds   1m   10s   Check Session Setup   setup=${false}
#     ${trace_file_before}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#     Sleep   15 min
#     ${trace_file_after}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#     Should Be Equal    ${trace_file_before}    ${trace_file_after}
#     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
#     ...   AND   CI_interface.Common Case Teardown

# [1]5GC001778_B_001_SA_ClassicalgNB_Cell_Trace_Session_Configuration_and_Activation_Basic_L3_Call
#     [Documentation]  This case is to verify the robustness of flag actCellTraceReport
#     [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     Close Web Startup View Window
#     ${trace_file}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#     Feature flag set to False
#     Wait Until Keyword Succeeds   1m   10s   Check Session Setup   setup=${false}
#     Feature flag set to True
#     Wait Until Keyword Succeeds   1m   10s   Check Session Setup   setup=${true}
#     Wait Until Keyword Succeeds   3x   10s   Call Setup and check tput   tput=10   tput_expect=0
#     ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${trace_file}   local_dir=${OUTPUT_DIR}
#     ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
#     ${target_file}   Get Test Json File
#     check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}

# [1]5GC001778_B_003_SA_ClassicalgNB_Invalid_Cell_Trace_Session_Parameters_Checking
#     Step1 Set NRMTRACECU-jobType as TraceOnly
#     Step2 Set NRMTRACECU-actCellTraceReporting to false
#     run keyword and continue on failure    Step3 Change TCE IP Address from IPV4 to IPV6
#     Step4 Configure a Non-valid TceID
#     Step5 Check the Relationship of actCellTraceReporting true and Interfaces
#     [Teardown]   Run Keywords   robot_common_operations.Common Case Teardown
#     ...   AND   Run Keyword If Test Failed   Restore WEBUI ENV
#     ...   AND   Run Keyword If Test Passed   COAM WEBUI ReLogin
#     ...   AND   CI_interface.Common Case Teardown

# [1]5GC001778_B_005_SA_ClassicalgNB_Cell_Trace_NRRESOURCECU_Type_is_Central_NRMTRACECU_scope_is_specificResources_PDL_Rules_Check
#     [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     wait until keyword succeeds  3x   30s   Remove Cell Trace Object
#     wait until keyword succeeds   1h   5m   Get Validation Result
#     Close Web Startup View Window
#     Add Cell Trace Object of TCE
# 	Add Cell Trace Object of NRMTRACECU
# 	Add Cell Trace Object of NRRESOURCECU   radio_resoure=central   resource=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
# 	Set PCMD CU Flag   pcmd_flag=false
# 	Modify Parameter actPCMDReport to False
# 	Set Cell Trace CU Flag   scope=specificResources
#     Check PDL Error   undo_changes=${false}
#     Config The Second NRRESOURCECU
# 	Check PDL Error   new_error_num=2   validation_error_check=@{005_key_error}[1]   validation_error_num=2
#     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
#     ...   AND   Run Keyword If Test Failed   Restore WEBUI ENV
#     ...   AND   Run Keyword If Test Passed   COAM WEBUI ReLogin
#     ...   AND   CI_interface.Common Case Teardown

# [1]5GC001778_B_009_SA_ClassicalgNB_Cell_Trace_NRRESOURCEDU_Type_is_Central_NRRESOURCEDU_scope_is_specificResources_PDL_Rules_Check
#     [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     wait until keyword succeeds  3x   30s   Remove Cell Trace Object
#     wait until keyword succeeds   1h   5m   Get Validation Result
#     Add Cell Trace Object of TCE
#     selenium_coam.add_object    object_name=${INSID}/NRDU-1    object_class_name=NRCTRLTSDU   id_value=1
#     ...   is_load_default_values=${true}
#     selenium_coam.add_object   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1    object_class_name=NRMTRACEDU   id_value=1
#     ...   is_load_default_values=${true}
#     Add Cell Trace Object of NRMTRACEDU   radio_resource=specificResources
#     selenium_coam.add_object
# 	...   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1    object_class_name=NRRESOURCEDU   id_value=1
#     ...   is_load_default_values=${true}
#     Add Cell Trace Object of NRRESOURCEDU   du_typeNrDu=central   du_resourceDN=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#     Check PDL Error   validation_error_check=@{009_key_error}[0]   undo_changes=${false}
#     Config The Second NRRESOURCEDU
#     Check PDL Error   new_error_num=2   validation_error_check=@{009_key_error}[1]   validation_error_num=2
#     [Teardown]   Run Keywords   robot_common_operations.Common Case Teardown
#     ...   AND   Run Keyword If Test Failed   Restore WEBUI ENV
#     ...   AND   Run Keyword If Test Passed   COAM WEBUI ReLogin
#     ...   AND   CI_interface.Common Case Teardown

# [1]5GC001778_B_007_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NR_RRC
#     [Documentation]  If only interface RRC is set to all, only masseage from RRC interface will be traced.
#     [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     wait until keyword succeeds  3x   30s   Remove Cell Trace Object
#     ${trace_file}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#     Close Web Startup View Window
#     Prepare Power UE   ue_index=${ue_index}
#     Add Cell Trace Object Without Activate   x2=none   xn=none   ngap=none
#     Modify Parameter actCellTraceReport to True
#     Validate and Activate Plan
#     Close Web Startup View Window
#     Run Keyword and Continue On Failure   Wait Until Keyword Succeeds   3x   20s   Call Setup Successfully
#     ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${trace_file}   local_dir=${OUTPUT_DIR}
#     ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
#     ${target_file}   Get Test Json File
#     check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#     :FOR    ${message_not_traced}    IN    @{message_not_traced_list_007}
#         ${filter_res}   Run    cat ${txt_file} | grep ${message_not_traced}
#         Should Be Empty    ${filter_res}
#     END

# [1]5GC001778_B_010_SA_ClassicalgNB_Cell_Trace_Single_Interface_Trace_NGAP
#     [Documentation]  If only interface RRC is set to all, only masseage from RRC interface will be traced.
#     ${trace_file}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#     Close Web Startup View Window
#     Prepare Power UE   ue_index=${ue_index}
#     Add Cell Trace Object Without Activate   x2=none   xn=none   rrc=none
#     Modify Parameter actCellTraceReport to True
#     Validate and Activate Plan
#     Close Web Startup View Window
#     Run Keyword and Continue On Failure   Wait Until Keyword Succeeds   3x   20s   Call Setup Successfully
#     ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${trace_file}   local_dir=${OUTPUT_DIR}
#     ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
#     ${target_file}   Get Test Json File
#     check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#     :FOR    ${message_not_traced}    IN    @{message_not_traced_list_010}
#         ${filter_res}   Run    cat ${txt_file} | grep ${message_not_traced}
#         Should Be Empty    ${filter_res}
#     END

# [1]5GC001778_B_004_SA_ClassicalgNB_Invalid_Cell_Trace_Session_Parameters_Checking_Delete_Referred_NRTCE_Object_Not_Allowed
#     Add Cell Trace Object Without Activate   pcmd_cu=false
# 	Modify Parameter actPCMDReport to False
# 	Get Validation Error Before Modify Parameter
#     Run Keyword   selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120
#     Close Web Startup View Window
#     Delete Object TCEADM and Check PDL Error
#     Close Web Startup View Window

# *** Keywords ***
# test suite setup
#     [Arguments]   ${cell_trace_flag}=true   ${PCMD_flag}=false   ${cell_trace_details}=all   ${l3call}=${true}
#     robot_common_operations.Common Suite Setup
#     COAM Try Connect gNB
#     ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
#     COAM Login
#     Run Keyword If  '${status}' == 'False'  Run Keywords  Catch Snapshot COAM  AND  Fail
#     Case Common Setup
#     set suite variable   ${suite_setup}   ${true}
#     log to console   Get latest trace file name
#     ${trace_file}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#     Commission Cell Trace CU and PCMD CU Flags   cell_trace_flag=${cell_trace_flag}   PCMD_flag=${PCMD_flag}
#     ...   cell_trace_details=${cell_trace_details}
# #    Run Keyword If   ${l3call}   L3CALL Precondition
#     Run Keyword and Ignore Error   Wait Until Keyword Succeeds   3x   10s   Call Setup Successfully
#     Sleep   3m

#     set suite variable   ${suite_setup_pass}   ${true}
#     log to console    Find trace report and analysis
#     ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${trace_file}   local_dir=${OUTPUT_DIR}
#     ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
#     set suite variable   ${txt_file}

# Get Validation Result
#     ${errors}   Get Validation Error Before Modify Parameter
#     [Return]   ${errors}
#     [Teardown]   Run Keyword If   $KEYWORD_STATUS=='FAIL'   Restore gNB ENV

# COAM WEBUI ReLogin
#     COAM WEBUI Logout
#     Sleep   20s
#     COAM WEBUI Login

# Call Setup Successfully
#     Call Setup and check tput   tput=10   tput_expect=0
#     [Teardown]   Run Keyword If   $KEYWORD_STATUS=='FAIL'   Restore gNB ENV

# UE Attach and Detach
#     Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#     Sleep   5s
#     power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

# Feature flag set to ${set_actCellTraceReport}
#     Modify Parameter actCellTraceReport to ${set_actCellTraceReport}
#     Run Keyword   selenium_coam.validate_plan
#     Run Keyword   selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120
#     Close Web Startup View Window

# Check PDL Error
#     [Arguments]   ${new_error_num}=1   ${validation_error_check}=@{005_key_error}[0]   ${validation_error_num}=1
#     ...   ${undo_changes}=${true}
#     ${errors_num}   ${defination_errors}   ${relation_errors}   ${hardware_errors}
#     ...   Validate Plan and Return Error
#     ${new_errors}   Evaluate   ${errors_num}-${errors_num_before}
#     Run Keyword If   ${new_errors} != ${new_error_num}   Log To Console   Validation Error check Failed: ${new_errors}!=${new_error_num}.
#     ${validation_check}   Evaluate   str(@{relation_errors.values()}).count('${validation_error_check}')
#     Run Keyword If      ${validation_check} == ${validation_error_num}      Log To Console  Validation report error which meet case expectation.
#     ...         ELSE    Log To Console  Case Failed!
#     Should Be True      ${new_errors} == ${new_error_num} and ${validation_check} == ${validation_error_num}
#     [Teardown]   Run Keywords   Close Web Startup View Window
#     ...   AND   Run Keyword If   ${undo_changes}   wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes

# Delete Object TCEADM and Check PDL Error
#     ${du_remove}   Run keyword and Return Status  selenium_coam.remove_object   MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1
#     Log To Console  Validate Plan and check expect validation error.
#     ${release}   Get gnb release   host=${WEBUI_ADDR}
#     Run Keyword If   '${release}' >= 'SBTS23R3'    Check PDL Error   validation_error_check=@{004_key_error}[1]
#     ...   ELSE   Check PDL Error   validation_error_check=@{004_key_error}[0]
# #    ${errors_num}   ${defination_errors}   ${relation_errors}   ${hardware_errors}
# #    ...   Validate Plan and Return Error
# #    wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes
# #    ${new_errors}   Evaluate   ${errors_num}-${errors_num_before}
# #    Run Keyword If   ${new_errors} != 1   Log To Console   Validation Error check Failed: ${new_errors}!=1.
# #    ${validation_check}   Evaluate   str(@{relation_errors.values()}).count('${004_key_error}')
# #    Run Keyword If      ${validation_check} == 1      Log To Console  Validation report error which meet case expectation.
# #    ...         ELSE    Log To Console  Case Failed!
# #    Should Be True      ${new_errors} == 1 and ${validation_check} == 1

# Config The Second NRRESOURCECU
#     Run Keyword   selenium_coam.set_parameter_value
# 	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-1
# 	...   filter_param=Resource distinguished name
# 	...   new_value=${INSID}
# 	Run Keyword   selenium_coam.add_object   object_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1   object_class_name=NRRESOURCECU   id_value=2
#     ...   is_load_default_values=${true}
# 	Run Keyword   selenium_coam.set_parameter_value
# 	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-2
# 	...   filter_param=Type of New Radio Resource
# 	...   new_value=central
#     Run Keyword   selenium_coam.set_parameter_value
# 	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-2
# 	...   filter_param=Resource distinguished name
# 	...   new_value=${INSID}

# Config The Second NRRESOURCEDU
#     selenium_coam.set_parameter_value
#     ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1/NRRESOURCEDU-1
#     ...   filter_param=Resource distinguished name
#     ...   new_value=${INSID}
#     selenium_coam.add_object
# 	...   object_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1    object_class_name=NRRESOURCEDU   id_value=2
#     ...   is_load_default_values=${true}
# 	selenium_coam.set_parameter_value
#     ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1/NRRESOURCEDU-2
#     ...   filter_param=Resource distinguished name
#     ...   new_value=${INSID}
#     selenium_coam.set_parameter_value
#     ...   dist_name=${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1/NRRESOURCEDU-2
#     ...   filter_param=Type of New Radio Resource
#     ...   new_value=central

# Restore WEBUI ENV
#     Capature Sreenshot COAM
#     ${restore_scf}   Run Keyword and Return Status   wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes
#     ${webui_available}   Run Keyword and Return Status   Run Keyword If   ${restore_scf}   Pass Execution   WEBUI function normal
#     ...   ELSE   selenium_coam.get_bts_status
#     Run Keyword If   ${webui_available}   Run Keyword and Ignore Error   COAM WEBUI Logout
#     Stop Firefox Pids
#     Sleep   20s
#     COAM WEBUI Login
