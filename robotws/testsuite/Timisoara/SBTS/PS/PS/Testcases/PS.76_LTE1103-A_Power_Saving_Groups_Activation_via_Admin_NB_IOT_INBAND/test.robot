*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND
...  AUTHORS:       dorin.nadasan@nokia.com
...  MAINTAINER:    RAN_VRF_TSR_1_SG05
...  *****************
...  Basic information
...  *****************
...  Purpose of the test is an activation and deactivation of energy saving for random cells.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  30.10.2025 - Added NbIoT TC
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND

    PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:0 Test Preparation
    PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:1 Disable Feature Before Test
    PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:2 Configure Load Based Power Saving
    PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:3 Activate Load Based Power Saving
    PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:4 Final Recovery and Checkpoint

PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${lnbts_dn}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    @{feature_flags}=  Create List  actLBRTXPowerSaving  actLBPowerSaving
    Set Test Variable  ${feature_flags}
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
#    Select Two Random LTE Cells
#    Select First Two LTE Cells
    Select 2 Cells First NbIotInband
    Log  Selected 1st LNCEL DN: ${1st_LNCEL_DN}  console=${True}
    Log  Selected 2nd LNCEL DN: ${2nd_LNCEL_DN}  console=${True}
    Log  Energy Saving for LNCEL_R-${1st_LNCEL_ID}
    Check Power Saving  ${1st_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log  Energy Saving for LNCEL_R-${2nd_LNCEL_ID}
    Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    ${all_cells}=  Create List Of FDD Cells
    ${selected_cells_DNs}=  Create List  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}
    ${selected_cells_IDs}=  Create List  ${1st_LNCEL_ID}  ${2nd_LNCEL_ID}
    Set Test Variable  ${selected_cells_DNs}
    Set Test Variable  ${selected_cells_IDs}
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}

PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:1 Disable Feature Before Test
    Log to console    \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:2 Configure Load Based Power Saving
    Log to console    \n========================================
    Log  Step: 2 Configure Load Based Power Saving  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    ${if_actExtCellSOMethod}  ${value_actExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actExtCellSOMethod
    Set Test Variable  ${if_actExtCellSOMethod}
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    Create And Activate PSGRP For LTE1103  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  PSGRP-11  25min
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:3 Activate Load Based Power Saving
    Log to console    \n========================================
    Log  Step: 3 Activate Load Based Power Saving  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  true
    Log To Console  Waiting for ENERGYSAVING...
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${1st_LNCEL_ID}  DISABLED  ENERGYSAVING
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${2nd_LNCEL_ID}  DISABLED  ENERGYSAVING
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  Waiting for NOTENERGYSAVING...
    Wait Until Keyword Succeeds  20min  30sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Wait Until Keyword Succeeds  5min  30sec  Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
#    ${status}  Run Keyword And Return Status  L3 Call
#    Run Keyword If  not ${status}  Teardown if call failed

PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test_Step:4 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 4 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  false
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  false
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test Specific Teardown