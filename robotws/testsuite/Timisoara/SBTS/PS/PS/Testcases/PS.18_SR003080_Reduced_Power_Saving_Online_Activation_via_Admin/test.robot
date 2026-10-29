*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin
...  AUTHORS:       damian.sliwinski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Test activation and deactivation of energy saving with Tx path switching off and check if cell reaches
...  ReducedEnergySaving state. If there are more than two cells available, then the second cell is added to
...  Power Saving Group and full EnergySaving state is expected. Operation should be done in online mode without
...  cell disabling.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  12.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-248 - TC creation
...  18.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-253 - timeouts fix for PSGRP
...  25.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-401 - extending time of power saving
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin

    PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:0 Test Preparation
    PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:1 Disable Feature Before Test
    PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:2 Configure Load Based Power Saving
    PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:3 Activate Load Based Power Saving
    PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:4 Final Recovery and Checkpoint

PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    @{feature_flags}=  Create List  actOnlineTXSwitch  actLBRTXPowerSaving  actLBPowerSaving
    Set Test Variable  ${feature_flags}
    Select Random LTE Cell
    Set Test Variable  ${1st_ES_LNCEL_ID}  ${1st_LNCEL_ID}
    Set Test Variable  ${1st_ES_LNCEL_DN}  ${1st_LNCEL_DN}
    ${cell_list}=  Get LNCEL List Without SingleTX And mMIMO
    ${1st_RES_LNCEL_ID}  ${1st_RES_LNCEL_DN}  ${2nd_RES_LNCEL_ID}  ${2nd_RES_LNCEL_DN}  Select Two Random LNCEL For ReducedEnergySanving  ${cell_list}
    Set Test Variable  ${1st_RES_LNCEL_ID}
    Set Test Variable  ${1st_RES_LNCEL_DN}
    Set Test Variable  ${2nd_RES_LNCEL_ID}
    Set Test Variable  ${2nd_RES_LNCEL_DN}
    ${selected_cells_IDs}=  Create List  ${1st_ES_LNCEL_ID}  ${1st_RES_LNCEL_ID}  ${2nd_RES_LNCEL_ID}
    Set Test Variable  ${selected_cells_IDs}
    Log To Console  Reduced Energy Saving for LNCEL_R-${1st_RES_LNCEL_ID} and LNCEL_R-${2nd_RES_LNCEL_ID}
    Log To Console  Energy Saving for LNCEL_R-${1st_ES_LNCEL_ID}
    Check Power Saving  ${1st_ES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving  ${2nd_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    ${selected_cells_DNs}=  Create List  ${1st_ES_LNCEL_DN}  ${1st_RES_LNCEL_DN}  ${2nd_RES_LNCEL_DN}
    Set Test Variable  ${selected_cells_DNs}

PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:1 Disable Feature Before Test
    Log to console    \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:2 Configure Load Based Power Saving
    Log to console    \n========================================
    Log  Step: 2 Configure Load Based Power Saving  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    ${if_actExtCellSOMethod}  ${value_actExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actExtCellSOMethod
    Set Test Variable  ${if_actExtCellSOMethod}
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    Create And Activate PSGRP For LTE1203  ${1st_ES_LNCEL_DN}  ${1st_RES_LNCEL_DN}  ${2nd_RES_LNCEL_DN}  PSGRP-38  35min
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:3 Activate Load Based Power Saving
    Log to console    \n========================================
    Log  Step: 3 Activate Load Based Power Saving  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  true
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  \nWaiting for SWITCHINGOFF on LNCEL_R-${1st_ES_LNCEL_ID}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${1st_ES_LNCEL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  == LNCEL_R-${1st_RES_LNCEL_ID} and LNCEL_R-${2nd_RES_LNCEL_ID} are locking ==
    Change Parameter Under LNCEL  administrativeState  locked  ${1st_RES_LNCEL_ID}
    Change Parameter Under LNCEL  administrativeState  locked  ${2nd_RES_LNCEL_ID}
    Log To Console  \nWaiting for ENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${1st_ES_LNCEL_ID}  DISABLED  ENERGYSAVING
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  == LNCEL_R-${1st_RES_LNCEL_ID} and LNCEL_R-${2nd_RES_LNCEL_ID} are unlocking ==
    Change Parameter Under LNCEL  administrativeState  unlocked  ${1st_RES_LNCEL_ID}
    Change Parameter Under LNCEL  administrativeState  unlocked  ${2nd_RES_LNCEL_ID}
    Log To Console  \nWaiting for REDUCEDENERGYSAVING on LNCEL_R-${1st_RES_LNCEL_ID} and LNCEL_R-${2nd_RES_LNCEL_ID}
    ${cell_status_change}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  15min  3sec
    ...  Check Chosen Cells Operational State multiple cells  ${1st_RES_LNCEL_DN}  ${2nd_RES_LNCEL_DN}  lte  DISABLED
    IF  ${cell_status_change}  Fail  msg=cell unexpected reach disabled state
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Wait Until Keyword Succeeds  5min  30sec  Check Power Saving  ${2nd_RES_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  \nWaiting for NOTENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID}, LNCEL_R-${1st_RES_LNCEL_ID} and LNCEL_R-${2nd_RES_LNCEL_ID}
    Wait Until Keyword Succeeds  20min  30sec  Check Power Saving  ${1st_ES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${2nd_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    ${status}  Run Keyword And Return Status  L3 Call
    IF  not ${status}  Teardown if call failed

PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test_Step:4 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 4 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test Specific Teardown
