*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to activate feature 'LTE914 Graceful cell shutdown' or
...  '5GC000501 Graceful cell shutdown' depending on the configuration. Graceful cell shutdown
...  scenario is tested when BTS timezone is changed to GMT-11. This change requires restart it means BTS will
...  reset itself. After resetting eNB required message "RromGracefulCellShutdown" should be found in syslog.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  10.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-54 - TC refactoring
...  22.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-162 - Change logic in test and switch to TAF library
...  01.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-195 - TC adaptation for LTE and NR configurations
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset

    PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test_Step:0 Test Preparation
    PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test_Step:1 Enable feature LTE914/5GC000501 flag
    PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test_Step:2 Final Recovery and Checkpoint

PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================

PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test_Step:1 Enable feature LTE914/5GC000501 flag
    Check which RAT are on given TestLine
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log to console    \n========================================
        Log  Step: 1a Enable feature LTE914 flag  console=${True}
        Log to console    ========================================
        Set Parameters For LTE Graceful And Grep In Syslog
        Log to console    \n========================================
        Log  Step: 1b Enable feature 5GC000501 flag  console=${True}
        Log to console    ========================================
        Set Parameters For NR Graceful And Grep In Syslog
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log to console    \n========================================
        Log  Step: 1 Enable feature LTE914 flag  console=${True}
        Log to console    ========================================
        Set Parameters For LTE Graceful And Grep In Syslog
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Log to console    \n========================================
        Log  Step: 1 Enable feature 5GC000501 flag  console=${True}
        Log to console    ========================================
        Set Parameters For NR Graceful And Grep In Syslog
    END

Set Parameters For LTE Graceful And Grep In Syslog
    [Documentation]  Trigger RromGracefulCellShutdown message in syslog.
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Enabled
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownStepAmount  6
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Set Timezone  (GMT-11) Pacific/Niue
    Log    ==Check Syslog For Gracefull Shutdown==  console=${True}
    Check Syslog For Gracefull Shutdown Messages  LTE
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check If ALDs Are Connected And Achieved Expected State
	common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Sleep  90s
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}==${0}  Fail  msg=Reset Counter not incremented
#    ...  ELSE IF  ${counter_diff}>${1}  Fail  msg=Detected more than 1 expected BTS reset
#    ...  ELSE IF  ${counter_diff}==${1}  Log  Reset Counter incremented +1

Set Parameters For NR Graceful And Grep In Syslog
    [Documentation]  Trigger PSCELL_DL_CELL_SHUTDOWN_REQ_MSG message in syslog.
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  true
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownStepAmount  3
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Set Timezone  (GMT-10) US/Hawaii
    Log  ==Check Syslog For Gracefull Shutdown==  console=${True}
    Check Syslog For Gracefull Shutdown Messages  NR
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check If ALDs Are Connected And Achieved Expected State
	common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Sleep  90s
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}==${0}  Fail  msg=Reset Counter not incremented
#    ...  ELSE IF  ${counter_diff}>${1}  Fail  msg=Detected more than 1 expected BTS reset
#    ...  ELSE IF  ${counter_diff}==${1}  Log  Reset Counter incremented +1

PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test_Step:2 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 2 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    Log    ==Final Recovery and Checkpoint==  console=${True}
#    ${status}  Run Keyword And Return Status  L3 Call
#    Run Keyword If  not ${status}  Teardown if call failed
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
        Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    END
    ${current_timezone}=  Get BTS Timezone
    IF  '${current_timezone}'!='(GMT+2) Europe/Bucharest'
        Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
        Set Timezone  (GMT+2) Europe/Bucharest
        Sleep  90s
        Check SMODs State  ${SMOD_expected_states}
	    Check RMODs State  ${RMOD_expected_states}
	    Check If ALDs Are Connected And Achieved Expected State
	    common.Check BTS State  ${BTS_expected_states}
        Check If NLWG Cells Are OnAir
        Sleep  90s
        Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
        Check If Unexpected Alarms Are Raised  ${skip_fault}
    END

PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check If ALDs Are Connected And Achieved Expected State
	common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    ${current_timezone}=  Get BTS Timezone
    IF  '${current_timezone}'!='(GMT+2) Europe/Bucharest'  Set Timezone  (GMT+2) Europe/Bucharest
    Sleep  20s
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check If ALDs Are Connected And Achieved Expected State
	common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test Specific Teardown
