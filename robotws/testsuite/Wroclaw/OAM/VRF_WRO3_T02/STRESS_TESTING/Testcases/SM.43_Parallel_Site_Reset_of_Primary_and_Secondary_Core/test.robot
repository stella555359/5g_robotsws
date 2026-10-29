*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot
Resource    ../../../resources_mem/ald.robot

Documentation
...  TEST NAME:     SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    RAN_VRF_WRO_3_T01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform Parallel Site Reset operation (actDualCoreParallelReset feature enabled), check BTS status after
...  operation is finished and measure KPI for operation time.
...  *****************
...  Pre-conditions
...  *****************
...  Dual Core configuration with SW supporting actDualCoreParallelReset feature.
...  ******************
...  History of changes
...  ******************
...  05.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-602 - TC creation
...  17.03.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-17486 - TC adaptation with TMO config (MRBTS-8288)
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${SMODS_ALLOWED_REGEX}      ASI.\+ASI.
${SUPPORTED_SW_REGEX}       2[5-9]R|[3-9][0-9]R


*** Keywords ***
SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core
    SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test_Step:0 Test Preparation
    SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test_Step:1 Perfom Site Reset
    SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test_Step:2 Check BTS

SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test_Step:0 Test Preparation
    Log to console  \n==========================================
    Log To Console  Step: 0 Test Preparation
    Log to console  ==========================================
    Should Match Regexp  ${SMOD_COMPOSITION}  ${SMODS_ALLOWED_REGEX}  msg=${SMOD_COMPOSITION} is not dual core or consists of unsupported SMOD.
    Should Match Regexp  ${SW_TYPE}  ${SUPPORTED_SW_REGEX}            msg=${SW_TYPE} does not support actDualCoreParallelReset feature
    Set Parameter To Expected Value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
                              ...    parameter=actDualCoreParallelReset
                              ...    expected_value=true
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    SCF Backup

SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test_Step:1 Perfom Site Reset
    Log To Console  \n==========================================
    Log To Console  Step: 1 Perfom Site Reset
    Log to console  ==========================================
    Run Keyword If  'nr' in $rats  Run Keywords  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                   ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                   ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
                                   ...    AND    Allow Fault In Watchdog  faultID=6150  #GTP-U Path Failure
    ${time_before_reset}  Get Current Date
    ${reset_status}  Run Keyword And Return Status  admin.reset site  timeout=700
    ${time_after_reset}  Get Current Date
    ${time_diff}  Subtract Date From Date  ${time_after_reset}  ${time_before_reset}
    Log To Console  Site is resetting...
    Set Test Variable  ${time_diff}
    Run Keyword If  '${reset_status}'=='False'  Run Keywords  Log To Console  BTS is not reachable after Site Reset
                                                ...      AND  Log To Console  Disabling EcoLab
                                                ...      AND  Run  sudo touch /etc/ute/disable_ecolab
                                                ...     ELSE  Log To Console  Site reset is done and it took ${time_diff} seconds

SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test_Step:2 Check BTS
    Log to console  \n==========================================
    Log To Console  Step: 2 Check BTS
    Log to console  ==========================================
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Run Keyword If  'nr' in $rats  Run Keywords  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
                                   ...    AND    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                   ...    AND    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                   ...    AND    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
                                   ...    AND    Disallow Fault In Watchdog  faultID=6150  #GTP-U Path Failure
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${0}<${counter_diff}<${2}  Log To Console  BTS Reset Counter Incremented +${counter_diff}
                                  ...    ELSE  Log  BTS Reset Counter Incremented +${counter_diff}  WARN
    ${reset_timestamp_dict}  Get RESET_HISTORY Timestamp
    ${fct_2011_timestamp}    Get From Dictionary  ${reset_timestamp_dict}  FCT-2011
    ${fct_1011_timestamp}    Get From Dictionary  ${reset_timestamp_dict}  FCT-1011
    ${fct_reset_delay_diff}  Subtract Date From Date  ${fct_2011_timestamp}  ${fct_1011_timestamp}
    ${delay_diff_abs}  Evaluate  abs(${fct_reset_delay_diff})
    Should Be True  ${delay_diff_abs}<10  msg=Reset delay between FCTs was longer than expected.  #no specified requirement
    Should Be True  ${time_diff}<360  #OM_GEN_SFS_PERF_CAP.26203

SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test Case Teardown
    Run Keyword  common.Common Test Teardown
