*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.42_Site_Reset_without_RU_Reset_via_WebEM
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    RAN_VRF_WRO_3_T01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform Site Reset operation without RU reset, check eNB status after operation is finished
...  and measure KPI for operation time.
...  *****************
...  Pre-conditions
...  *****************
...  At least one RU in configuration supporting Site Reset without RU reset.
...  ******************
...  History of changes
...  ******************
...  28.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-605 - TC creation
...  23.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-610 - Rework TC to check upTime on all RUs
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${SUPPORTED_SW_REGEX}       2[5-9]R|[3-9][0-9]R
@{RU_PARAMS_LIST}           upTime

*** Keywords ***
SM.42_Site_Reset_without_RU_Reset_via_WebEM
    SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test_Step:0 Test Preparation
    SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test_Step:1 Perfom Site Reset
    SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test_Step:2 Check BTS
    SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test_Step:3 KPI Measurement

SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test_Step:0 Test Preparation
    Log to console  \n==========================================
    Log To Console  Step: 0 Test Preparation
    Log to console  ==========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    SCF Backup
    ${ru_params_before_reset}  Get RUs Parameters Values  ${RU_PARAMS_LIST}
    Set Test Variable  ${ru_params_before_reset}

SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test_Step:1 Perfom Site Reset
    Log To Console  \n==========================================
    Log To Console  Step: 1 Perfom Site Reset without RU reset
    Log to console  ==========================================
    Run Keyword If  'nr' in $rats  Run Keywords  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                   ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                   ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log To Console  Site is resetting...
    ${time_before_reset}  Get Current Date
    ${reset_status}  Run Keyword And Return Status  admin.reset site  reset_without_ru=True  timeout=700
    ${time_after_reset}  Get Current Date
    ${time_diff}  Subtract Date From Date  ${time_after_reset}  ${time_before_reset}
    Set Test Variable  ${time_diff}
    Run Keyword If  '${reset_status}'=='False'  Run Keywords  Log To Console  BTS is not reachable after Site Reset
                                                ...      AND  Log To Console  Disabling EcoLab
                                                ...      AND  Run  sudo touch /etc/ute/disable_ecolab
                                                ...     ELSE  Log To Console  Site reset is done and it took ${time_diff} seconds

SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test_Step:2 Check BTS
    Log to console  \n==========================================
    Log To Console  Step: 2 Check BTS
    Log to console  ==========================================
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    ${ru_params_after_reset}  Get RUs Parameters Values  ${RU_PARAMS_LIST}
    Check If NLWG Cells Are OnAir
    Run Keyword If  'nr' in $rats  Run Keywords  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
                                   ...    AND    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                   ...    AND    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                   ...    AND    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${0}<${counter_diff}<${2}  Log To Console  BTS Reset Counter Incremented +${counter_diff}
                                  ...    ELSE  Log  BTS Reset Counter Incremented +${counter_diff}  WARN
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

SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test_Step:3 KPI Measurement
    Log to console  \n==========================================
    Log To Console  Step: 3 KPI Measurement
    Log to console  ==========================================
    Run Keyword And Ignore Error  Calculate KPI1a KPI1b KPI1c  ${ITERATION_INDEX}

SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test Specific Setup
    Should Match Regexp  ${SW_TYPE}  ${SUPPORTED_SW_REGEX}  msg=${SW_TYPE} does not support Site Reset without RU reset
    Setup Admin  admin_api_log_dir=/home/ute/test_results/admin_api/test_setup/site_reset_without_ru_reset
    ${NO_RESET_VALID_RUS}  Get RUs Supporting closeVirtualConnection
    Set Test Variable  ${NO_RESET_VALID_RUS}
    admin.Teardown Admin  alias=${ute_admin_alias}
    Run Keyword If  ${NO_RESET_VALID_RUS}==[]  Fail  msg=There is no RU in configuration, that supports "Site Reset without RU reset"

SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
