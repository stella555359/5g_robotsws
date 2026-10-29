*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of the testcase is to check if cells in shutting down state (also broken cells) are locked in
...  graceful way. Chosen cell is set into shutting down state. After that graceful reboot on eNB should begin.
...  Administrative state of the cell changes into locked.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  10.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-57 - TC refactoring
...  25.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-113 - TC adaptation for KW Select Two Random and backup list fix
...  04.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-234 - Change logic in test and switch to TAF library
...  15.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-362 - Teardown fix - shutdownwindow set to 180s
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin

    PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test_Step:0 Test Preparation
    PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test_Step:1 Enable feature LTE914/5GC000501 flag
    PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test_Step:2 Shutting down CELL and reboot
    PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test_Step:3 Final Recovery and Checkpoint

PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check which RAT are on given TestLine
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Select Random LTE Cell
        Log  Selected 1st LNCEL DN: ${1st_LNCEL_DN}  console=${True}
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

PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test_Step:1 Enable feature LTE914/5GC000501 flag
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log to console    \n========================================
        Log  Step: 1a Enable feature LTE914 flag  console=${True}
        Log to console    ========================================
        Set Parameters For LTE Graceful Cell Shutdown  enableGrflShdn=Enabled  shutdownStepAmount=6  shutdownWindow=180s
        Log to console    \n========================================
        Log  Step: 1b Enable feature 5GC000501 flag  console=${True}
        Log to console    ========================================
        Set Parameters For NR Graceful Cell Shutdown  actGrflShdn=true  shutdownStepAmount=3  shutdownWindow=180s
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log to console    \n========================================
        Log  Step: 1 Enable feature LTE914 flag  console=${True}
        Log to console    ========================================
        Set Parameters For LTE Graceful Cell Shutdown  enableGrflShdn=Enabled  shutdownStepAmount=6  shutdownWindow=180s
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Log to console    \n========================================
        Log  Step: 1 Enable feature 5GC000501 flag  console=${True}
        Log to console    ========================================
        Set Parameters For NR Graceful Cell Shutdown  actGrflShdn=true  shutdownStepAmount=3  shutdownWindow=180s
    END

PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test_Step:2 Shutting down CELL and reboot
    Log to console    \n========================================
    Log  Step: 2 Shutting down CELL and reboot  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log To Console  Changing administrativeState of LNCEL_R-${1st_LNCEL_ID} to shutting down
        Change Parameter Under LNCEL  administrativeState  shutting down  ${1st_LNCEL_ID}
        Log To Console  Changing administrativeState of NRCEL_R-${1st_NRCELL_ID} to shutting down
        Change Parameter Under NRCELL  administrativeState  Shutting Down  ${1st_NRCELL_ID}
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log To Console  Changing administrativeState of LNCEL_R-${1st_LNCEL_ID} to shutting down
        Change Parameter Under LNCEL  administrativeState  shutting down  ${1st_LNCEL_ID}
        Log To Console  Changing administrativeState of LNCEL_R-${2nd_LNCEL_ID} to shutting down
        Change Parameter Under LNCEL  administrativeState  shutting down  ${2nd_LNCEL_ID}
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Log To Console  Changing administrativeState of NRCEL_R-${1st_NRCELL_ID} to shutting down
        Change Parameter Under NRCELL  administrativeState  Shutting Down  ${1st_NRCELL_ID}
    END
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
	Log To Console  BTS Reset site...
	admin.reset site  timeout=700
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check If ALDs Are Connected And Achieved Expected State
	common.Check BTS State  ${BTS_expected_states}
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Wait Until Keyword Succeeds  30x  30s  Check Chosen Cells Administrative State  ${1st_LNCEL_DN}  lte  LOCKED
        Wait Until Keyword Succeeds  30x  30s  Check Chosen Cells Administrative State  ${1st_NRCELL_DN}  nr  LOCKED
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Wait Until Keyword Succeeds  30x  30s  Check Chosen Cells Administrative State  ${1st_LNCEL_DN}  lte  LOCKED
        Wait Until Keyword Succeeds  30x  30s  Check Chosen Cells Administrative State  ${2nd_LNCEL_DN}  lte  LOCKED
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Wait Until Keyword Succeeds  30x  30s  Check Chosen Cells Administrative State  ${1st_NRCELL_DN}  nr  LOCKED
    END
    IF  '${IF_NR_EXIST}'=='EXIST'  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
    Sleep  30s
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}==${0}  Fail  msg=Reset Counter not incremented
#    ...  ELSE IF  ${counter_diff}==${1}  Log  Reset Counter incremented +1
#    ...  ELSE IF  ${counter_diff}==${2}  Log  Reset Counter incremented +2
#    ...  ELSE IF  ${counter_diff}>${2}  Fail  msg=Detected more than 2 times BTS reset

PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test_Step:3 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
        Log To Console  Changing administrativeState of LNCEL_R-${1st_LNCEL_ID} to unlocked
        Change Parameter Under LNCEL  administrativeState  unlocked  ${1st_LNCEL_ID}
        Wait Until Keyword Succeeds  30x  10s  Check Chosen Cells Administrative State  ${1st_LNCEL_DN}  lte  UNLOCKED
        Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
        Log To Console  Changing administrativeState of NRCEL_R-${1st_LNCEL_ID} to unlocked
        Change Parameter Under NRCELL  administrativeState  Unlocked  ${1st_NRCELL_ID}
        Wait Until Keyword Succeeds  30x  30s  Check Chosen Cells Administrative State  ${1st_NRCELL_DN}  nr  UNLOCKED
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
        Log To Console  Changing administrativeState of LNCEL_R-${1st_LNCEL_ID} to unlocked
        Change Parameter Under LNCEL  administrativeState  unlocked  ${1st_LNCEL_ID}
        Log To Console  Changing administrativeState of LNCEL_R-${2nd_LNCEL_ID} to unlocked
        Change Parameter Under LNCEL  administrativeState  unlocked  ${2nd_LNCEL_ID}
        Wait Until Keyword Succeeds  30x  10s  Check Chosen Cells Administrative State  ${1st_LNCEL_DN}  lte  UNLOCKED
        Wait Until Keyword Succeeds  30x  10s  Check Chosen Cells Administrative State  ${2nd_LNCEL_DN}  lte  UNLOCKED
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  60
        Log To Console  Changing administrativeState of NRCEL_R-${1st_LNCEL_ID} to unlocked
        Change Parameter Under NRCELL  administrativeState  Unlocked  ${1st_NRCELL_ID}
        Wait Until Keyword Succeeds  30x  30s  Check Chosen Cells Administrative State  ${1st_NRCELL_DN}  nr  UNLOCKED
    END
#     ${status}  Run Keyword And Return Status  L3 Call
#    Run Keyword If  not ${status}  Teardown if call failed

PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
	common.Check BTS State  ${BTS_expected_states}
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
        Run Keyword And Ignore Error  Change Parameter Under LNCEL  administrativeState  unlocked  ${1st_LNCEL_ID}
        Wait Until Keyword Succeeds  30x  10s  Check Chosen Cells Administrative State  ${1st_LNCEL_DN}  lte  UNLOCKED
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
        Run Keyword And Ignore Error  Change Parameter Under NRCELL  administrativeState  Unlocked  ${1st_NRCELL_ID}
        Wait Until Keyword Succeeds  30x  30s  Check Chosen Cells Administrative State  ${1st_NRCELL_DN}  nr  UNLOCKED
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
        Run Keyword And Ignore Error  Change Parameter Under LNCEL  administrativeState  unlocked  ${1st_LNCEL_ID}
        Run Keyword And Ignore Error  Change Parameter Under LNCEL  administrativeState  unlocked  ${2nd_LNCEL_ID}
        Wait Until Keyword Succeeds  30x  10s  Check Chosen Cells Administrative State  ${1st_LNCEL_DN}  lte  UNLOCKED
        Wait Until Keyword Succeeds  30x  10s  Check Chosen Cells Administrative State  ${2nd_LNCEL_DN}  lte  UNLOCKED
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
        Run Keyword And Ignore Error  Change Parameter Under NRCELL  administrativeState  Unlocked  ${1st_NRCELL_ID}
        Wait Until Keyword Succeeds  30x  30s  Check Chosen Cells Administrative State  ${1st_NRCELL_DN}  nr  UNLOCKED
    END
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test Specific Teardown
