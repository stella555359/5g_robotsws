*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify 5G MultiRAT behavior through WebEM & NetAct in situation of main power
...  break recovery (power break simulated by EAC).
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  17.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-58 - TC refactoring
...  17.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-115 - backup list fix
...  08.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-126 - Adaptation Inteligent shutdown on ASOE
...  29.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-202 - KWs "Get wcdma cells id for multiple cells" used
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario

    PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:0 Test Preparation
    PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:1 Activate Intelligent Shutdown feature
    PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:2 Trigger alarm via EAC
    PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:3 Cancelling alarm via EAC
    PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:4 Final Recovery and Checkpoint

PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check which RAT are on given TestLine
    Check which technology have to be chosen
    Select Cells And Delete IntShutdownTimeout LTE

PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:1 Activate Intelligent Shutdown feature
    Log to console    \n========================================
    Log  Step: 1 Activate Intelligent Shutdown feature  console=${True}
    Log to console    ========================================
    ${1st_WNCEL_ID_A}  IF  '${IF_WCDMA_EXIST}'=='EXIST'  Get WCDMA Cells Id For Multiple Cells  ${1st_WNCEL_ID}
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Set Test Variable  ${1st_WNCEL_ID_A}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Turn ON Or OFF Feature  intShutdownInUse  true
    IF  '${IF_NR_EXIST}'=='EXIST'  Set intShutdownTimeout  NR  5min
    IF  '${IF_LTE_EXIST}'=='EXIST'  Set intShutdownTimeout LTE  LTE  4min
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Set intShutdownTimeout  WCDMA  3min
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:2 Trigger alarm via EAC
    Log to console    \n========================================
    Log  Step: 2 Trigger alarm via EAC  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Allow Fault In Watchdog  faultID=37  #fault_name: Mains power break, running battery backup
    Set Parameter Under EAC Object  polarity  Normally_closed
    Wait For Active Fault  faultID=37  timeout=2min
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:3 Cancelling alarm via EAC
    Log to console    \n========================================
    Log  Step: 3 Cancelling alarm via EAC  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Parameter Under EAC Object  polarity  Normally_open
    Turn ON Or OFF Feature  intShutdownInUse  false
    Sleep	2 minutes 10 seconds    Wait for a reply
    Disallow Fault In Watchdog  faultID=37  #fault_name: Mains power break, running battery backup
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
#    ${status}  Run Keyword And Return Status  L3 Call
#    Run Keyword If  not ${status}  Teardown if call failed

PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test_Step:4 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 4 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    IF  '${IF_NR_EXIST}'=='EXIST'  Delete IntShutdownTimeout  ${nrCellIds}  NR
    IF  '${IF_LTE_EXIST}'=='EXIST'  Delete IntShutdownTimeout  ${lnCellIds}  LTE
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Delete IntShutdownTimeout  ${wnCellIds}  WCDMA
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Turn ON Or OFF Feature  intShutdownInUse  false
    Run Keyword And Ignore Error  Set Parameter Under EAC Object  polarity  Normally_open
    IF  '${IF_NR_EXIST}'=='EXIST'  Run Keyword And Ignore Error  Delete IntShutdownTimeout  ${nrCellIds}  NR
    IF  '${IF_LTE_EXIST}'=='EXIST'  Run Keyword And Ignore Error  Delete IntShutdownTimeout  ${lnCellIds}  LTE
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Run Keyword And Ignore Error  Delete IntShutdownTimeout  ${wnCellIds}  WCDMA
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test Specific Teardown
