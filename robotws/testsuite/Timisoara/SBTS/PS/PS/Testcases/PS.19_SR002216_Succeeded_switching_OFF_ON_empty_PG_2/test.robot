*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2
...  AUTHORS:       mateusz.gadek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The feature SR002216 LTE3330 improves the energy efficiency introduced
...  by LTE1103 Load-Based Power Saving operation mode by allowing switching off unused hardware baseband
...  processing resources and further reducing the energy consumption figures.
...  *****************
...  Pre-conditions
...  *****************
...  Test requires ASIB + ABIA configuration with empty power group. This test is dedicated for TL: 101046.
...  ******************
...  History of changes
...  ******************
...  26.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-130 - TC transfer from Siso
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2

    PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:0 Test Preparation
    PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:1 Feature Activation
    PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:2 Check Powergroup State After Feature Activation
    PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:3 Feature Deactivation
    PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:4 Check Powergroup State After Feature Deactivation
    PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:5 Final Recovery and Checkpoint

PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${LNCELs}=  Create List  LNCEL-48131  LNCEL-48132  LNCEL-48133
    Set Test Variable  ${LNCELs}
    Set bbPoolAllocMode To Automatic
    Check If NLWG Cells Are OnAir
    ${POWERGROUP_DN}=  Find Empty POWERGROUP
    ${BBMOD_ID}=   Evaluate  re.search(r'BBMOD_R-(\\d+)','''${POWERGROUP_DN}''').group(1)  re
    Set Test Variable  ${BBMOD_ID}
    Set Test Variable  ${POWERGROUP_DN}  ${POWERGROUP_DN[0]}
    IF  '${BBMOD_ID}'!='[]'  Log To Console  Empty Power Group is on BBMOD_R-${BBMOD_ID}

PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:1 Feature Activation
    Log to console    \n========================================
    Log  Step:1 Feature Activation  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under LNBTS/NRBTS Via NA  actLBPowerSaving  true  LNBTS
    Set Feature Under FEATLADM Via NA  actLBBbPowerSaving  true
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:2 Check Powergroup State After Feature Activation
    Log to console    \n========================================
    Log  Step:2 Check Powergroup State After Feature Activation  console=${True}
    Log to console    ========================================
    Check Powergroup  ${POWERGROUP_DN}  DISABLED

PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:3 Feature Deactivation
    Log to console    \n========================================
    Log  Step:3 Feature Deactivation  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under FEATLADM Via NA  actLBBbPowerSaving  false
    Set Feature Under LNBTS/NRBTS Via NA  actLBPowerSaving  false  LNBTS
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:4 Check Powergroup State After Feature Deactivation
    Log to console    \n========================================
    Log  Step:4 Check Powergroup State After Feature Deactivation  console=${True}
    Log to console    ========================================
    ${POWERGROUP_DNs}=  Get POWERGROUP List
    FOR  ${POWERGROUP_DN}  IN  @{POWERGROUP_DNs}
        Wait Until Keyword Succeeds  1min  30s  Check Powergroup  ${POWERGROUP_DN}  ENABLED
    END

PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test_Step:5 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step:5 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    Set bbPoolAllocMode To Manual
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    ${status}  Run Keyword And Return Status  L3 Call
    IF  not ${status}  Teardown if call failed

PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Set bbPoolAllocMode To Manual
    Check If NLWG Cells Are OnAir
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test Case Teardown
    Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact
    Run Keyword If Test Failed  PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2.Test Specific Teardown
