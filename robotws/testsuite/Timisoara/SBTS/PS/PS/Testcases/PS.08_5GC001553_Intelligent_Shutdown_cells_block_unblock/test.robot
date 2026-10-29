*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to verify that cells shut down with Intelligent shutdown feature will not be
...  unblocked when the main power returnes, if they were previously blocked by user via Admin.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  17.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-59 - TC refactoring
...  02.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-71 - Fault 49 (cell blocked) added to expected faults
...  17.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-115 - backup list fix
...  08.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-126 - Adaptation Inteligent shutdown on ASOE
...  09.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-170 - Relevant information about GSM blocked cell displayed
...  29.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-202 - KWs "Get wcdma cells id for multiple cells" used
...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-211 - adaptation for multiple GSM cells configuration
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock

    PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:0 Test Preparation
    PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:1 Activate Intelligent Shutdown feature
    PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:2 Block GSM and NR cell, trigger alarms via EAC and check alarms on eNB
    PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:3 Unblock NR cell and dismiss alarms triggered via EAC
    PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:4 Final Recovery and Checkpoint

PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check which RAT are on given TestLine
    Check which technology have to be chosen
    Select Cells And Delete IntShutdownTimeout LTE

PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:1 Activate Intelligent Shutdown feature
    Log to console    \n========================================
    Log  Step: 1 Activate Intelligent Shutdown feature  console=${True}
    Log to console    ========================================
    ${1st_WNCEL_ID_A}  IF  '${IF_WCDMA_EXIST}'=='EXIST'  Get WCDMA Cells Id For Multiple Cells  ${1st_WNCEL_ID}
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Set Test Variable  ${1st_WNCEL_ID_A}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Turn ON Or OFF Feature  intShutdownInUse  true
    IF  '${IF_NR_EXIST}'=='EXIST'  Set intShutdownTimeout  NR  3min
    IF  '${IF_LTE_EXIST}'=='EXIST'  Set intShutdownTimeout LTE  LTE  2min
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Set intShutdownTimeout  WCDMA  1min
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:2 Block GSM and NR cell, trigger alarms via EAC and check alarms on eNB
    Log to console    \n========================================
    Log  Step: 2 Block GSM and NR cell, trigger alarms via EAC and check alarms on eNB  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Allow Fault In Watchdog  faultID=49    #fault_name: Cell blocked
    IF  '${IF_GSM_EXIST}'=='EXIST'
        Block Selected Cell  cell_dn=${1st_GNCEL_DN}  timeout=240
    ELSE IF  '${IF_GSM_EXIST}'=='NO'
        Log To Console  \nGSM RAT don't exist in actual configutation, only 5G will be blocked
    END
    Block Selected Cell  cell_dn=${1st_NRCELL_DN}  timeout=240
    Allow Fault In Watchdog  faultID=37    #fault_name: Mains power break, running battery backup
    Allow Fault In Watchdog  faultID=4395  #fault_name: Cells shutdown due to mains power break
    Set Parameter Under EAC Object  polarity  Normally_closed
    Sleep  180s
    Log To Console  Checking NR cells operational state...
    Check Chosen Cells Operational State  ${1st_NRCELL_DN}  nr  DISABLED
    IF  '${IF_GSM_EXIST}'=='EXIST'
        Log To Console  Checking GSM cells operational state...
        Check Chosen Cells Operational State  ${1st_GNCEL_DN}  gsm  DISABLED
    END
    IF  '${IF_WCDMA_EXIST}' == 'EXIST'
        Log To Console  Checking WCMDA cells operational state...
        Check Cells Status After Expected Timer For Selected Technology  ${1st_WNCEL_DN}  wcdma
        ...  expected_operational_state=DISABLED  repetition=10
    END
    IF  '${IF_LTE_EXIST}' == 'EXIST'
        Log To Console  Checking LTE cells operational state...
        Check Cells Status After Expected Timer For Selected Technology  ${1st_LNCEL_DN}  lte
        ...  expected_operational_state=DISABLED  repetition=10
    END
    Wait For Active Fault  faultID=37    timeout=2min
    Wait For Active Fault  faultID=49    timeout=2min
    Wait For Active Fault  faultID=4395  timeout=2min
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:3 Unblock NR cell and dismiss alarms triggered via EAC
    Log to console    \n========================================
    Log  Step: 3 Unblock NR cell and dismiss alarms triggered via EAC  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Unblock Selected Cell  cell_dn=${1st_NRCELL_DN}  timeout=240
    Set Parameter Under EAC Object  polarity  Normally_open
    IF  '${IF_LTE_EXIST}'=='EXIST'
        Log To Console  Checking LTE cells operational state...
        Check Cells Status After Expected Timer For Selected Technology  ${1st_LNCEL_DN}  lte
        ...  expected_operational_state=ENABLED  repetition=3
    END
    IF  '${IF_NR_EXIST}'=='EXIST'
        Log To Console  Checking NR cells operational state...
        Check Cells Status After Expected Timer For Selected Technology  ${1st_NRCELL_DN}  nr
        ...  expected_operational_state=ENABLED  repetition=3
    END
    IF  '${IF_WCDMA_EXIST}'=='EXIST'
        Log To Console  Checking WCDMA cells operational state...
        Check Cells Status After Expected Timer For Selected Technology  ${1st_WNCEL_DN}  wcdma
        ...  expected_operational_state=ENABLED  repetition=1
    END
    IF  '${IF_GSM_EXIST}'=='EXIST'
        Log To Console  Checking GSM cells operational state...
        Repeat Keyword  30 s  Check Chosen Cells Operational State  ${1st_GNCEL_DN}  gsm
        ...  expected_operational_state=DISABLED
    END
    Check If Fault Is Active  faultID=49
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
#    ${status}  Run Keyword And Return Status  L3 Call
#    Run Keyword If  not ${status}  Teardown if call failed

PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test_Step:4 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 4 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    Turn ON Or OFF Feature  intShutdownInUse  false
    Set Parameter Under EAC Object  polarity  Normally_open
    Disallow Fault In Watchdog  faultID=37    #fault_name: Mains power break, running battery backup
    IF  '${IF_GSM_EXIST}'=='EXIST'  Unblock Selected Cell  cell_dn=${1st_GNCEL_DN}  timeout=240
    IF  '${IF_NR_EXIST}'=='EXIST'  Delete IntShutdownTimeout  ${nrCellIds}  NR
    IF  '${IF_LTE_EXIST}'=='EXIST'  Delete IntShutdownTimeout  ${lnCellIds}  LTE
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Delete IntShutdownTimeout  ${wnCellIds}  WCDMA
    Disallow Fault In Watchdog  faultID=49    #fault_name: Cell blocked
    Disallow Fault In Watchdog  faultID=4395  #fault_name: Cells shutdown due to mains power break
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Turn ON Or OFF Feature  intShutdownInUse  false
    Run Keyword And Ignore Error  Set Parameter Under EAC Object  polarity  Normally_open
    Run Keyword And Ignore Error  Unblock Selected Cell  cell_dn=${1st_NRCELL_DN}  timeout=240
    Run Keyword And Ignore Error  Unblock Selected Cell  cell_dn=${1st_GNCEL_DN}  timeout=240
    IF  '${IF_NR_EXIST}'=='EXIST'  Run Keyword And Ignore Error  Delete IntShutdownTimeout  ${nrCellIds}  NR
    IF  '${IF_LTE_EXIST}'=='EXIST'  Run Keyword And Ignore Error  Delete IntShutdownTimeout  ${lnCellIds}  LTE
    IF  '${IF_WCDMA_EXIST}'=='EXIST'  Run Keyword And Ignore Error  Delete IntShutdownTimeout  ${wnCellIds}  WCDMA
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test Specific Teardown
