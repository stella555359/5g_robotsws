*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to suspend extended  power paving, and check If cells which energy saving state is energySaving and
...  reducedEnergySaving start to switching on.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  14.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-141 - Test case creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080

    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:0 Test Preparation
    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:1 Disable Feature Before Test
    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:2 Activate Load-Based Extended Power Saving
    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:3 Configure Load-Based Extended Power Saving
    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:4 Check if selected cells reach applicable states
    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:5 Suspend Extended Power Saving
    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:6 Final Recovery and Checkpoint

PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    @{feature_flags}=  Create List  actExtCellSOMethod  actLBPowerSaving  actLBRTXPowerSaving
    Set Test Variable  ${feature_flags}
    Select Random LTE Cell
    Set Test Variable  ${1st_ES_LNCEL_ID}  ${1st_LNCEL_ID}
    Set Test Variable  ${1st_ES_LNCEL_DN}  ${1st_LNCEL_DN}
    ${cell_list}=  Get LNCEL List Without SingleTX And mMIMO
    ${1st_RES_LNCEL_ID}  ${1st_RES_LNCEL_DN}  Select One Random LNCEL For ReducedEnergySanving  ${cell_list}
    Set Test Variable  ${1st_RES_LNCEL_ID}
    Set Test Variable  ${1st_RES_LNCEL_DN}
    ${selected_cells_IDs}=  Create List  ${1st_ES_LNCEL_ID}  ${1st_RES_LNCEL_ID}
    Set Test Variable  ${selected_cells_IDs}
    Log To Console  Reduced Energy Saving for LNCEL_R-${1st_RES_LNCEL_ID}
    Log To Console  Energy Saving for LNCEL_R-${1st_ES_LNCEL_ID}
    Check Power Saving  ${1st_ES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    ${selected_cells_DNs}=  Create List  ${1st_ES_LNCEL_DN}  ${1st_RES_LNCEL_DN}
    Set Test Variable  ${selected_cells_DNs}
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}

PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:1 Disable Feature Before Test
    Log to console  \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:2 Activate Load-Based Extended Power Saving
    Log to console  \n========================================
    Log  Step: 2 Activate Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:3 Configure Load-Based Extended Power Saving
    Log to console  \n========================================
    Log  Step: 3 Configure Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    Create And Activate PSGRP For CB008800  ${1st_ES_LNCEL_DN}  ${1st_RES_LNCEL_DN}  PSGRP-88  25min  CB008800
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:4 Check if selected cells reach applicable states
    Log to console  \n========================================
    Log  Step: 4 Check if selected cells reach applicable states  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Log To Console  \nWaiting for ENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID}
    Wait Until Keyword Succeeds  20min  15sec  Check Power Saving  ${1st_ES_LNCEL_ID}  DISABLED  ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  \nWaiting for REDUCEDENERGYSAVING on LNCEL_R-${1st_RES_LNCEL_ID}
    Wait Until Keyword Succeeds  10min  15sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  Cells reach applicable states
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:5 Suspend Extended Power Saving
    Log to console  \n========================================
    Log  Step: 5 Suspend Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Suspend PowerSaving  PSGRP-88
    Log To Console  \nWaiting for NOTENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID}
    Wait Until Keyword Succeeds  3min  10sec  Check Power Saving  ${1st_ES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \nWaiting for NOTENERGYSAVING on LNCEL_R-${1st_RES_LNCEL_ID}
    Wait Until Keyword Succeeds  8min  10sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
#    ${status}  Run Keyword And Return Status  L3 Call
#    IF  not ${status}  Teardown if call failed

PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test_Step:6 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 6 Final Recovery and Checkpoint  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test Specific Teardown
