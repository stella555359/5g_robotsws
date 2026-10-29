*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     SM.41_Site_Reset_without_RU_Reset_via_NA
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This User Scenario describes how to perform site reset without RU reset from NetAct by using Open API.
...  *****************
...  Pre-conditions
...  *****************
...  BTS-NetAct M-Plane connection is working
...  ACTIONS NIDD adaptation is supported by SW releases on both NetAct and BTS
...  SRNCLAB with "pure trunk base"
...  NetActTrunk - NetAct - 99.23.04.0.96 (or higher)
...  BTS is configured with at least one RU supporting site reset without RU reset.
...  ******************
...  History of changes
...  ******************
...  03.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-603 - TC creation
...  23.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-610 - Rework TC to check upTime on all RUs
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${SUPPORTED_SW_REGEX}       2[5-9]R|[3-9][0-9]R
@{RU_PARAMS_LIST}           upTime

*** Keywords ***
SM.41_Site_Reset_without_RU_Reset_via_NA
    SM.41_Site_Reset_without_RU_Reset_via_NA.Test_Step:0 Test Preparation
    SM.41_Site_Reset_without_RU_Reset_via_NA.Test_Step:1 Resetting Site
    SM.41_Site_Reset_without_RU_Reset_via_NA.Test_Step:2 Final Checkpoint

SM.41_Site_Reset_without_RU_Reset_via_NA.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log to console  Test_Step: 0 Test Preparation
    Log to console  ========================================
    Should Match Regexp  ${SW_TYPE}  ${SUPPORTED_SW_REGEX}  msg=${SW_TYPE} does not support Site Reset without RU reset.
    ${NO_RESET_VALID_RUS}  Get RUs Supporting closeVirtualConnection
    Set Test Variable  ${NO_RESET_VALID_RUS}
    Run Keyword If  ${NO_RESET_VALID_RUS}==[]  Fail  msg=There is no RU in configuration, that supports "Site Reset without RU reset"
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    ${ru_params_before_reset}  Get RUs Parameters Values  ${RU_PARAMS_LIST}
    Set Test Variable  ${ru_params_before_reset}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}

SM.41_Site_Reset_without_RU_Reset_via_NA.Test_Step:1 Resetting Site
    Log to console  \n========================================
    Log to console  Test_Step: 1 Resetting Site
    Log to console  ========================================
    Run Keyword If  'nr' in $rats  Run Keywords  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                   ...      AND  Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                   ...      AND  Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    @{parameters}    Create List    btsResetType=btsResetWithoutRuReset    gracefulCellShutdown=false
    Log To Console  Site is resetting...
    ${time_before_reset}  Get Current Date
    netact.Reset NE  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  parameters=${parameters}  verbose=True
    ${time_after_reset}  Get Current Date
    ${time_diff}  Subtract Date From Date  ${time_after_reset}  ${time_before_reset}
    Log To Console  Site reset is done and it took ${time_diff} seconds
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check If ALDs Are Connected And Achieved Expected State
	common.Check BTS State  ${BTS_expected_states}
    ${ru_params_after_reset}  Get RUs Parameters Values  ${RU_PARAMS_LIST}
	Check If NLWG Cells Are OnAir
    Wait Until Keyword Succeeds  2x  5s  Check Cells State In Netact
    Run Keyword If  'nr' in $rats  Run Keywords  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
                                   ...      AND  Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                   ...      AND  Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                   ...      AND  Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ${ru_params_diff_dict}  Compare RUs upTime  ${ru_params_before_reset}  ${ru_params_after_reset}
    ${unexpected_diffs}  Create List
    FOR  ${ru}  IN  @{ru_params_diff_dict}
        ${params}  Get From Dictionary  ${ru_params_diff_dict}  ${ru}
        Run Keyword If  '${ru}' in $NO_RESET_VALID_RUS and ${params['upTime_diff']}<=0
               ...      Append To List  ${unexpected_diffs}  ${ru}: reset detected (upTime difference: ${params['upTime_diff']})
        ...    ELSE IF  '${ru}' not in $NO_RESET_VALID_RUS and ${params['upTime_diff']}>=0
               ...      Append To List  ${unexpected_diffs}  ${ru}: no reset detected (upTime difference: ${params['upTime_diff']})
    END
    FOR  ${diff_msg}  IN  @{unexpected_diffs}
        Log To Console  ${diff_msg}
        Run Keyword If  '${diff_msg}'=='${unexpected_diffs[-1]}'  Fail  msg=${ru_params_diff_dict}
    END
    Should Be True  ${time_diff}<360  #OM_GEN_SFS_PERF_CAP.26203

SM.41_Site_Reset_without_RU_Reset_via_NA.Test_Step:2 Final Checkpoint
    Log to console  \n========================================
    Log to console  Test_Step: 2 Final Checkpoint
    Log to console  ========================================
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check If ALDs Are Connected And Achieved Expected State
	common.Check BTS State  ${BTS_expected_states}
	${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${0}<${counter_diff}<${2}  Log To Console  BTS Reset Counter Incremented +${counter_diff}
    ...       ELSE  Log  BTS Reset Counter Incremented +${counter_diff}  WARN
	Check If NLWG Cells Are OnAir
    Wait Until Keyword Succeeds  2x  5s  Check Cells State In Netact
