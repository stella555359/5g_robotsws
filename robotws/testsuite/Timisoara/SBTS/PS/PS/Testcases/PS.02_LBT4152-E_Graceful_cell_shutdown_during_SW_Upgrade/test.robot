*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of the test is to activate feature 'LTE914 Graceful cell shutdown' or
...  '5GC000501 Graceful cell shutdown' depending on the configuration and test a graceful cell
...  shutdown scenario in case of reset after SW upgrade. After resetting required message
...  "RromGracefulCellShutdown" should be found in syslog.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  10.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-53 - TC refactoring
...  25.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-164 - Change logic in test and switch to TAF solutions
...  01.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-195 - TC adaptation for LTE and NR configurations
...  18.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-217 - Change logic in test
...  04.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-379 - Wait for reset added
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade

    PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test_Step:0 Test Preparation
    PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test_Step:1 Enable feature LTE914/5GC000501 flag
    PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test_Step:2 Download and Update Software and Check Syslog For Gracefull Shutdown
    PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test_Step:3 Final Recovery and Checkpoint

PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================

PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test_Step:1 Enable feature LTE914/5GC000501 flag
    Check which RAT are on given TestLine
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

PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test_Step:2 Download and Update Software and Check Syslog For Gracefull Shutdown
    Log to console    \n========================================
    Log  Step: 2 Download and Update Software and Check Syslog For Gracefull Shutdown  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${SW_PACKAGE_PATH}=  Download Expected SW Package  ${SW_PACKAGE}
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    BTS Software Update  ${SW_PACKAGE_PATH}
    ${reset_start_date}  Get Current Date
    ${reset_end_date}  Add Time To Date  ${reset_start_date}  240s
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Check Syslog For Gracefull Shutdown Messages  LTE/NR
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Check Syslog For Gracefull Shutdown Messages  LTE
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Check Syslog For Gracefull Shutdown Messages  NR
    END
    Wait for date  ${reset_end_date}
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check If ALDs Are Connected And Achieved Expected State
	common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Sleep  30s
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}==${0}  Log  Reset Counter not incremented
#    ...  ELSE IF  ${counter_diff}>${1}  Fail  msg=Reset Counter incremented (more than 1 unexpected reset)
#    ...  ELSE IF  ${counter_diff}==${1}  Log  msg=Reset Counter incremented +1

PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test_Step:3 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    SW Package Delete
    Check If NLWG Cells Are OnAir
    ${status}  Run Keyword And Return Status  L3 Call
    IF  not ${status}  Teardown if call failed
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
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test Case Teardown
    Run Keywords  common.Common Test Teardown
#    Run Keyword If Test Failed  PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test Specific Teardown
