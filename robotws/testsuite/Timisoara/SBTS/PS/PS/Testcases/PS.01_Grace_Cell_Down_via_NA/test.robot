*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.01_Grace_Cell_Down_via_NA
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Operator changes the cell administrative state to "shutting down" for LTE and NR cells depending on the
...  configuration, via plan file download and activation.
...  ENB triggers graceful shutdown procedure and sends State Change Event Report with new Administrative state
...  "shutting down" for each affected cell to NetAct and WebEM. If more than one cell shall be shutdown
...  with one plan file, the power reduction procedure will be triggered and performed in parallel for all affected
...  cells. ENB calculates power reduction and time per step from operator configurable parameters and start
...  reducing DL output power step by step until lowest power level is reached. ENB waits additional 10 seconds to
...  give time for finishing handover activities. ENB triggers cell deactivation procedure. This implicitly clears
...  S1 and UW resources in eNB and MME. eNB sends State Change Event Report with new Administrative State value
...  "locked" and Operational State value "disabled" to NeAct and WebEM.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  21.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-52 - TC refactoring
...  28.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-69 - Step 2 correction due to adaptation to CNI-61110
...  22.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-117 - Change logic in test and switch to TAF library
...  25.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-113 - TC adaptation for KW Select Two Random
...  01.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-195 - TC adaptation for LTE and NR configurations
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.01_Grace_Cell_Down_via_NA

    PS.01_Grace_Cell_Down_via_NA.Test_Step:0 Test Preparation
    PS.01_Grace_Cell_Down_via_NA.Test_Step:1 Enable feature LTE914/5GC000501 flag
    PS.01_Grace_Cell_Down_via_NA.Test_Step:2 Start Shutting Down Cell
    PS.01_Grace_Cell_Down_via_NA.Test_Step:3 Final Recovery and Checkpoint

PS.01_Grace_Cell_Down_via_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    Check which RAT are on given TestLine
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Select Two Random LTE Cells
        Log  Selected 1st LNCEL DN: ${1st_LNCEL_DN}  console=${True}
        Log  Selected 2nd LNCEL DN: ${2nd_LNCEL_DN}  console=${True}
        Select Random NR Cell
        Log  Selected 1st NRCELL DN: ${1st_NRCELL_DN}  console=${True}
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Select Two Random LTE Cells
        Log  Selected 1st LNCEL DN: ${1st_LNCEL_DN}  console=${True}
        Log  Selected 2nd LNCEL DN: ${2nd_LNCEL_DN}  console=${True}
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Select Random NR Cell
        Log  Selected 1st NRCELL DN: ${1st_NRCELL_DN}  console=${True}
    END

PS.01_Grace_Cell_Down_via_NA.Test_Step:1 Enable feature LTE914/5GC000501 flag
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log to console    \n========================================
        Log  Step: 1a Enable feature LTE914 flag  console=${True}
        Log to console    ========================================
        Log  Activation enableGrflShdn flag  console=${true}
        Set Feature Under LNBTS/NRBTS Via NA  enableGrflShdn  1  LNBTS
        Log to console    \n========================================
        Log  Step: 1b Enable feature 5GC000501 flag  console=${True}
        Log to console    ========================================
        Log  Activation actGrflShdn flag  console=${true}
        Set Feature Under LNBTS/NRBTS Via NA  actGrflShdn  True  NRBTS
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log to console    \n========================================
        Log  Step: 1 Enable feature LTE914 flag  console=${True}
        Log to console    ========================================
        Log  Activation enableGrflShdn flag  console=${true}
        Set Feature Under LNBTS/NRBTS Via NA  enableGrflShdn  1  LNBTS
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Log to console    \n========================================
        Log  Step: 1 Enable feature 5GC000501 flag  console=${True}
        Log to console    ========================================
        Log  Activation actGrflShdn flag  console=${true}
        Set Feature Under LNBTS/NRBTS Via NA  actGrflShdn  True  NRBTS
    END
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.01_Grace_Cell_Down_via_NA.Test_Step:2 Start Shutting Down Cell
    Log to console    \n========================================
    Log  Step: 2 Start Shutting Down Cell  console=${True}
    Log to console    ========================================
    IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST'
        Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  2  ${1st_LNCEL_ID}  LNBTS
        Check Expected LTE Cell State  ${1st_LNCEL_DN}
        Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  2  ${2nd_LNCEL_ID}  LNBTS
        Check Expected LTE Cell State  ${2nd_LNCEL_DN}
        Change Administrative State For LNCELL/NRCELL Via NA  NRCELL  administrativeState  1  ${1st_NRCELL_ID}  NRBTS
        Check Expected NR Cell State  ${1st_NRCELL_DN}
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  2  ${1st_LNCEL_ID}  LNBTS
        Check Expected LTE Cell State  ${1st_LNCEL_DN}
        Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  2  ${2nd_LNCEL_ID}  LNBTS
        Check Expected LTE Cell State  ${2nd_LNCEL_DN}
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Change Administrative State For LNCELL/NRCELL Via NA  NRCELL  administrativeState  1  ${1st_NRCELL_ID}  NRBTS
        Check Expected NR Cell State  ${1st_NRCELL_DN}
    END

PS.01_Grace_Cell_Down_via_NA.Test_Step:3 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST'
        Log  Deactivation enableGrflShdn flag  console=${true}
        Set Feature Under LNBTS/NRBTS Via NA  enableGrflShdn  0  LNBTS
        Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  1  ${1st_LNCEL_ID}  LNBTS
        Check Expected LTE Cell States After Recovery  ${1st_LNCEL_DN}
        Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  1  ${2nd_LNCEL_ID}  LNBTS
        Check Expected LTE Cell States After Recovery  ${2nd_LNCEL_DN}
        Log  Deactivation actGrflShdn flag  console=${true}
        Set Feature Under LNBTS/NRBTS Via NA  actGrflShdn  False  NRBTS
        Change Administrative State For LNCELL/NRCELL Via NA  NRCELL  administrativeState  2  ${1st_NRCELL_ID}  NRBTS
        Check Expected NR Cell States After Recovery  ${1st_NRCELL_DN}
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log  Deactivation enableGrflShdn flag  console=${true}
        Set Feature Under LNBTS/NRBTS Via NA  enableGrflShdn  0  LNBTS
        Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  1  ${1st_LNCEL_ID}  LNBTS
        Check Expected LTE Cell States After Recovery  ${1st_LNCEL_DN}
        Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  1  ${2nd_LNCEL_ID}  LNBTS
        Check Expected LTE Cell States After Recovery  ${2nd_LNCEL_DN}
    ELSE IF  '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST'
        Log  Deactivation actGrflShdn flag  console=${true}
        Set Feature Under LNBTS/NRBTS Via NA  actGrflShdn  False  NRBTS
        Change Administrative State For LNCELL/NRCELL Via NA  NRCELL  administrativeState  2  ${1st_NRCELL_ID}  NRBTS
        Check Expected NR Cell States After Recovery  ${1st_NRCELL_DN}
    END
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    ${status}  Run Keyword And Return Status  L3 Call
    IF  not ${status}  Teardown if call failed


PS.01_Grace_Cell_Down_via_NA.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST'
        Log  Test Specific Teardown for NRCELL and LNCELLs  console=${true}
        Run Keyword And Ignore Error  Change Parameter Under LNCEL  administrativeState  unlocked  ${1st_LNCEL_ID}
        Run Keyword And Ignore Error  Change Parameter Under LNCEL  administrativeState  unlocked  ${2nd_LNCEL_ID}
        Run Keyword And Ignore Error  Change Parameter Under NRCELL  administrativeState  Unlocked  ${1st_NRCELL_ID}
        Log  Deactivation enableGrflShdn flag  console=${true}
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Log  Deactivation actGrflShdn flag  console=${true}
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log  Test Specific Teardown for LNCELLs  console=${true}
        Run Keyword And Ignore Error  Change Parameter Under LNCEL  administrativeState  unlocked  ${1st_LNCEL_ID}
        Run Keyword And Ignore Error  Change Parameter Under LNCEL  administrativeState  unlocked  ${2nd_LNCEL_ID}
        Log  Deactivation enableGrflShdn flag  console=${true}
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
    ELSE IF  '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST'
        Log  Test Specific Teardown for NRCELL  console=${true}
        Run Keyword And Ignore Error  Change Parameter Under NRCELL  administrativeState  Unlocked  ${1st_NRCELL_ID}
        Log  Deactivation actGrflShdn flag  console=${true}
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
    END
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.01_Grace_Cell_Down_via_NA.Test Case Teardown
    Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact
    Run Keyword If Test Failed  PS.01_Grace_Cell_Down_via_NA.Test Specific Teardown


Check Expected LTE Cell States After Recovery
    [Arguments]  ${LNCEL_DN}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Log  Checking LTE cell status...  console=${True}
    Wait Until Keyword Succeeds  10x  20s  Check Chosen Cells Administrative State  ${LNCEL_DN}  lte   UNLOCKED
    IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'  Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

Check Expected NR Cell States After Recovery
    [Arguments]  ${NRCELL_DN}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Log  Checking NR cell status...  console=${True}
	Wait Until Keyword Succeeds  10x  20s  Check Chosen Cells Administrative State  ${NRCELL_DN}  nr  UNLOCKED
    Wait Until Keyword Succeeds  10x  5s  Check Chosen Cells Operational State  ${NRCELL_DN}  nr  ENABLED
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

Check Expected LTE Cell State
    [Arguments]  ${LNCEL_DN}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Log  Checking LTE cell status...  console=${True}
    Wait Until Keyword Succeeds  20x  5s   Check Chosen Cells Administrative State  ${LNCEL_DN}  lte  SHUTTINGDOWN
    Wait Until Keyword Succeeds  20x  20s  Check Chosen Cells Administrative State  ${LNCEL_DN}  lte  LOCKED
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

Check Expected NR Cell State
    [Arguments]  ${NRCELL_DN}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Log  Checking NR cell status...  console=${True}
    Wait Until Keyword Succeeds  20x  5s   Check Chosen Cells Administrative State  ${NRCELL_DN}  nr  SHUTTINGDOWN
    Wait Until Keyword Succeeds  20x  20s  Check Chosen Cells Administrative State  ${NRCELL_DN}  nr  LOCKED
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
