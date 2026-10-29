*** Settings ***
Documentation
...  author: Heng Liangliang
...  contact: jingmin.he@nokia-sbell.com   liangliang.heng@nokia-sbell.com

# Resource   Resource/emil.robot
# Resource   Resource/collect_log.robot
# Resource   Resource/common.robot
# Library    ./libraries/emil_messages.py

# Force Tags   SG_07   CA_5G_OAM     CIT_21B    CIT_20B   CIT_21A   CIT_TRUNK
# ...    PY36
# *** Variables ***

# *** Test Cases ***
# [1]5GC001778_B_001_SA_ClassicalgNB_Cell_Trace_Session_Configuration_and_Activation_Basic_L3_Call
#     [Documentation]  This case is to verify the robustness of flag actCellTraceReport
#     [Setup]    Case Common Setup
#     log to console   Get latest trace file name
#     ${trace_file}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#     Close Web Startup View Window
#     log to console    UE deattach
#     Prepare Power UE   ue_index=${ue_index}
#     log to console   Add Cell Trace Object
#     Add Cell Trace Object Without Activate
#     Feature flag set to True
#     log to console   Modify actCellTraceReport to false
#     Sleep   1 min
#     Feature flag set to False
#     Sleep   1 min
#     log to console   Modify actCellTraceReport to true
#     Feature flag set to True
#     Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   tput=0
#     Repeat Keyword   2x   Call Setup and check tput   tput=0
#     ${file_list}   Get Newest Trace Files   bts_id=${MRBTS_ID}   latest_skip_file=${trace_file}   local_dir=${OUTPUT_DIR}
#     ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
#     ${target_file}   Get Test Json File
#     check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
# #    Remove Cell Trace Object
#     [Teardown]    Case Common Teardown

# *** Keywords ***
# Feature flag set to ${set_actCellTraceReport}
#     Modify Parameter actCellTraceReport to ${set_actCellTraceReport}
#     Validate and Activate Plan
#     Close Web Startup View Window
