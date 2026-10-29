*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false
...  AUTHORS:       mateusz.gadek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  LBT4239 implementation done with LTE BTS supports static power allocation.
...  If LTE2517 feature allows activation of license only for half ABIA board
...  capacity (useFullCapacity = False), then K2 SoC C and D are not used for cells processing
...  (although still consuming energy). LBT4239 allows to switch off the Optional Power Group
...  for energy saving purposes if LTE2517 does not allow their usage (HW license limitation).
...  LTE3330 SR002216 should not interfere with LBT4239 (should not attempt to switch on any Optional Power Group
...  which was switched off by LTE2517 / LBT4239).
...  *****************
...  Pre-conditions
...  *****************
...  Test requires ASIB + ABIA configuration with empty power group. This test is dedicated for TL: 101046.
...  ******************
...  History of changes
...  ******************
...  08.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-131 - TC transfer from Siso
...  13.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-256 - TC addapt for Multi Rat
...  10.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-360 - TC addapt for dedicated TL and differences between BBMOD_R and BBMOD IDs.
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false

    PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:0 Test Preparation
    PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:1 Deactivation useFullCapacity
    PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:2 Feature Activation
    PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:3 Check Powergroup State After Feature Activation
    PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:4 Feature Deactivation
    PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:5 Check Powergroup State After Feature Deactivation
    PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:6 Activate fullCapacity
    PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:7 Final Recovery and Checkpoint

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:0 Test Preparation
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

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:1 Deactivation useFullCapacity
    Log to console    \n========================================
    Log  Step:1 Deactivation useFullCapacity  console=${True}
    Log to console    ========================================
    ${POWERGROUP_DN}=  Find Empty POWERGROUP
    ${BBMOD_ID}=   Evaluate  re.search(r'BBMOD_R-(\\d+)','''${POWERGROUP_DN}''').group(1)  re
    Set Test Variable  ${BBMOD_ID}
    Set Test Variable  ${POWERGROUP_DN}  ${POWERGROUP_DN[0]}
    IF  '${BBMOD_ID}'!='[]'  Log To Console  Empty Power Group is on BBMOD_R-${BBMOD_ID}
    Set Parameter Under BBMOD  BBMOD_ID=${1}  parameter=useFullCapacity  value=false
    Check Powergroup  ${POWERGROUP_DN}  DISABLED

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:2 Feature Activation
    Log to console    \n========================================
    Log  Step:2 Feature Activation  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under LNBTS/NRBTS Via NA  actLBPowerSaving  true  LNBTS
    Set Feature Under FEATLADM Via NA  actLBBbPowerSaving  true
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:3 Check Powergroup State After Feature Activation
    Log to console    \n========================================
    Log  Step:3 Check if Powergroup is disabled  console=${True}
    Log to console    ========================================
    Check Powergroup  ${POWERGROUP_DN}  DISABLED

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:4 Feature Deactivation
    Log to console    \n========================================
    Log  Step:4 Feature Deactivation  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under FEATLADM Via NA  actLBBbPowerSaving  false
    Set Feature Under LNBTS/NRBTS Via NA  actLBPowerSaving  false  LNBTS
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:5 Check Powergroup State After Feature Deactivation
    Log to console    \n========================================
    Log  Step:5 Check Powergroup after feature deactivation  console=${True}
    Log to console    ========================================
    Check Powergroup  ${POWERGROUP_DN}  DISABLED

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:6 Activate fullCapacity
    Log to console    \n========================================
    Log  Step:6 Activate fullCapacity and check if PG is enabled  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Parameter Under BBMOD  BBMOD_ID=${1}  parameter=useFullCapacity  value=true
    Wait Until Keyword Succeeds  1min  30s  Check Powergroup  ${POWERGROUP_DN}  ENABLED
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test_Step:7 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 7 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    Set bbPoolAllocMode To Manual
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    ${status}  Run Keyword And Return Status  L3 Call
    IF  not ${status}  Teardown if call failed

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Set bbPoolAllocMode To Manual
    Run Keyword And Ignore Error  Set Parameter Under BBMOD  BBMOD_ID=${1}  parameter=useFullCapacity  value=true
    Check If NLWG Cells Are OnAir
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test Case Teardown
    Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact
    Run Keyword If Test Failed  PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false.Test Specific Teardown
