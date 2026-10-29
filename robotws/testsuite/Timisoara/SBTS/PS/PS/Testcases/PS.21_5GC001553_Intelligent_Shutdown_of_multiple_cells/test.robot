*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify eNB behavior after shutting down cells by the Operator with Intelligent
...  Cell Shutdown feature enabled.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  18.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-62 - TC refactoring
...  17.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-115 - backup list fix
...  08.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-126 - Adaptation Inteligent shutdown on ASOE
...  29.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-202 - KWs "Get wcdma cells id for multiple cells" used
...  03.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-348 - Extend timeout in KW "Wait For Active Fault" - FID: 4395
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells

    PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test_Step:0 Test Preparation
    PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test_Step:1 Activate Intelligent Shutdown feature
    PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test_Step:2 Trigger alarm via EAC and check alarms on Netact
    PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test_Step:3 Final Recovery and Checkpoint

PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check which RAT are on given TestLine
    Check which technology have to be chosen
    Select Cells And Delete IntShutdownTimeout LTE

PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test_Step:1 Activate Intelligent Shutdown feature
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
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test_Step:2 Trigger alarm via EAC and check alarms on Netact
    Log to console    \n========================================
    Log  Step: 2 Trigger alarm via EAC and check alarms on Netact  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Allow Fault In Watchdog  faultID=37    #fault_name: Mains power break, running battery backup
    Allow Fault In Watchdog  faultID=1400  #fault_name: Alarm 37
    Allow Fault In Watchdog  faultID=4395  #fault_name: Cells shutdown due to mains power break
    Set Parameter Under EAC Object  polarity  Normally_closed
    Wait For Active Fault  faultID=37  timeout=2min
    Wait For Active Fault  faultID=4395  timeout=5min
    IF  '${IF_GSM_EXIST}'=='EXIST'  Check Cells Status After Expected Timer For Selected Technology  ${1st_GNCEL_DN}  gsm
    ...  expected_operational_state=DISABLED  repetition=30
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Check Cells Status After Expected Timer For Selected Technology  ${1st_WNCEL_DN}  wcdma
    ...  expected_operational_state=DISABLED  repetition=30
    IF  '${IF_LTE_EXIST}'=='EXIST'  Check Cells Status After Expected Timer For Selected Technology  ${1st_LNCEL_DN}  lte
    ...  expected_operational_state=DISABLED  repetition=30
    IF  '${IF_NR_EXIST}'=='EXIST'  Check Cells Status After Expected Timer For Selected Technology  ${1st_NRCELL_DN}  nr
    ...  expected_operational_state=DISABLED  repetition=30
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test_Step:3 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Turn ON Or OFF Feature  intShutdownInUse  false
    Set Parameter Under EAC Object  polarity  Normally_open
    IF  '${IF_NR_EXIST}'=='EXIST'  Delete IntShutdownTimeout  ${nrCellIds}  NR
    IF  '${IF_LTE_EXIST}'=='EXIST'  Delete IntShutdownTimeout  ${lnCellIds}  LTE
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Delete IntShutdownTimeout  ${wnCellIds}  WCDMA
    Disallow Fault In Watchdog  faultID=37    #fault_name: Mains power break, running battery backup
    Disallow Fault In Watchdog  faultID=1400  #fault_name: Alarm 37
    Disallow Fault In Watchdog  faultID=4395  #fault_name: Cells shutdown due to mains power break
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
#    ${status}  Run Keyword And Return Status  L3 Call
#    IF  not ${status}  Teardown if call failed

PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test Specific Teardown
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

PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test Case Teardown
    Run Keyword  common.Common Test Teardown
    Run Keyword If Test Failed  PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test Specific Teardown
