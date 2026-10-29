*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.27_CB008800_Overlapping_Cell_Periods
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case to check if cells with same switching off methods and overlapping periods remain in,
...  energySaving.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  06.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-293 - Test case creation
...  21.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-292 - Time increased for LTE1103 and LTE1203 activation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.27_CB008800_Overlapping_Cell_Periods

    PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:0 Test Preparation
    PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:1 Disable Feature Before Test
    PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:2 Activate Load-Based Extended Power Saving
    PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:3 Configure Load-Based Extended Power Saving
    PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:4 Check if selected cells reach applicable states
    PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:5 Final Recovery and Checkpoint

PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:0 Test Preparation
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


PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:1 Disable Feature Before Test
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

PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:2 Activate Load-Based Extended Power Saving
    Log to console  \n========================================
    Log  Step: 2 Activate Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:3 Configure Load-Based Extended Power Saving
    Log to console  \n========================================
    Log  Step: 3 Configure Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    Create And Activate PSGRP For CB008800  ${1st_ES_LNCEL_DN}  ${1st_RES_LNCEL_DN}  PSGRP-88  30min  CB008800_Overlap
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:4 Check if selected cells reach applicable states
    Log to console  \n========================================
    Log  Step: 4 Check if selected cells reach applicable states  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Log To Console  \nWaiting for ENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID}
    Wait Until keyword Succeeds  14min  15sec  Check Power Saving  ${1st_ES_LNCEL_ID}  DISABLED  ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Sleep  240
    Get Time And Date With Minute Offset  0
    Log  Check if LNCEL_R-${1st_ES_LNCEL_ID} is in energySaving ${start_hour}:${start_minutes}.  console=${true}
    Check Power Saving  ${1st_ES_LNCEL_ID}  DISABLED  ENERGYSAVING
    Log To Console  \nWaiting for REDUCEDENERGYSAVING on LNCEL_R-${1st_RES_LNCEL_ID}
    Wait Until keyword Succeeds  4.5min  15sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Get Time And Date With Minute Offset  0
    Log  Check if ${1st_RES_LNCEL_ID} is in REDUCEDENERGYSAVING ${start_hour}:${start_minutes}.  console=${true}
    Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Log To Console  Cells reach applicable states
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    Log To Console  \nWaiting for NOTENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID} and LNCEL_R-${1st_RES_LNCEL_ID}
    Wait Until keyword Succeeds  15min  30sec  Check Power Saving  ${1st_ES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Wait Until keyword Succeeds  15min  30sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING

PS.27_CB008800_Overlapping_Cell_Periods.Test_Step:5 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 6 Final Recovery and Checkpoint  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Check If Unexpected Alarms Are Raised  ${skip_fault}
#    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.27_CB008800_Overlapping_Cell_Periods.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  true
    admin.teardown admin  alias=${ute_admin_alias}

PS.27_CB008800_Overlapping_Cell_Periods.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.27_CB008800_Overlapping_Cell_Periods.Test Specific Teardown


