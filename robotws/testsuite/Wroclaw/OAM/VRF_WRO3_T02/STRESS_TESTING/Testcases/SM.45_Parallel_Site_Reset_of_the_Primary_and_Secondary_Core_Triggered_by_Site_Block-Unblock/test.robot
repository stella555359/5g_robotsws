*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot
Resource    ../../../resources_mem/ald.robot

Documentation
...  TEST NAME:     SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock
...  AUTHORS:       aleksandra.bereta@nokia.com
...  MAINTAINER:    RAN_VRF_WRO_3_T01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform Parallel Site Reset of the Primary and Secondary Core
...  triggered by Site Block-Unblock operation (actDualCoreParallelReset feature enabled),
...  check BTS status after operation is finished and measure KPI for operation time.
...  *****************
...  Pre-conditions
...  *****************
...  Dual Core configuration with SW supporting actDualCoreParallelReset feature.
...  ******************
...  History of changes
...  ******************
...  13.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-601 - TC creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${SMODS_ALLOWED_REGEX}      ASI.\+ASI.
${SUPPORTED_SW_REGEX}       2[5-9]R|[3-9][0-9]R
${LTE_expected_state_blocked}         blockingState=regex"(?i)Blocked", operationalState=regex"(?i)Disabled"
${NR_expected_state_blocked}          blockingState=regex"(?i)Blocked", operationalState=regex"(?i)Disabled"

*** Keywords ***
SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock
    SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test_Step:0 Test Preparation
    SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test_Step:1 Perfom Site Block
    SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test_Step:2 Perform Site Unblock
    SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test_Step:3 Check if reset was executed in parallel

SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test_Step:0 Test Preparation
    Log to console  \n==========================================
    Log To Console  Step: 0 Test Preparation
    Log to console  ==========================================
    Resolve Blocked BTS
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    ${bts_name}  Get BTS Name
    Set Test Variable  ${bts_name}
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    SCF Backup

SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test_Step:1 Perfom Site Block
    Log To Console  \n==========================================
    Log To Console  Step: 1 Perfom Site Block
    Log to console  ==========================================
    Allow Fault In Watchdog  faultID=50  #fault_name: BTS blocked
    Log To Console  BTS Block site...
    admin.Block  timeout=180
    ${unit_path}  Set Variable  [${bts_name}] MRBTS-${MRBTS_ID}
    ${unit_path}  Evaluate   re.sub('\\[--\\]','','''${unit_path}''')  re
    Wait For Active Fault  faultID=50  unit_path=${unit_path}  timeout=30 sec    #OM_GEN_SFS_FM.3103
    Log To Console  Checking if all cells have reached the expected state: blockingState=Blocked, operationalState=Disabled
    Wait Until Keyword Succeeds  5x  5s  admin.assert every  LNCEL    ${LTE_expected_state_blocked}
    Wait Until Keyword Succeeds  5x  5s  admin.assert every  NRCEL    ${NR_expected_state_blocked}

SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test_Step:2 Perform Site Unblock
    Log To Console    \n========================================
    Log To Console  Step: 2 Perform Site Unblock
    Log To Console      ========================================
    ${if_nr_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    Run Keyword If  ${if_nr_exist}  Run Keywords  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Allow Fault In Watchdog  faultID=6150  #fault_name: GTP-U Path failure can be visible during startup
    Log To Console  BTS Unblock site...
    ${time_before_reset}  Get Current Date
    ${reset_status}  Run Keyword And Return Status  admin.Unblock  timeout=600
    ${time_after_reset}  Get Current Date
    ${time_diff}  Subtract Date From Date  ${time_after_reset}  ${time_before_reset}
    Set Test Variable  ${time_diff}
    Run Keyword If  '${reset_status}'=='False'  Run Keywords  Log To Console  BTS is not reachable after Site Reset
                                                ...      AND  Log To Console  Disabling EcoLab
                                                ...      AND  Run  sudo touch /etc/ute/disable_ecolab
                                                ...     ELSE  Log To Console  Site reset is done and it took ${time_diff} seconds
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Wait Until Keyword Succeeds  10x  1s  Check S1 Link
    Disallow Fault In Watchdog  faultID=6150  #fault_name: GTP-U Path failure can be visible during startup
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=50  #fault_name: BTS blocked
    Run Keyword If  ${if_nr_exist}  Run Keywords  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
                                    ...    AND    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB

SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test_Step:3 Check if reset was executed in parallel
    Log To Console  \n==========================================
    Log To Console  Step: 3 Check if reset was executed in parallel
    Log To Console  ==========================================
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${0}<${counter_diff}<${2}  Log To Console  Reset Counter Incremented +${counter_diff}
                                  ...    ELSE  Log  BTS Reset Counter Incremented +${counter_diff}  WARN
    ${reset_timestamp_dict}  Get RESET_HISTORY Timestamp
    ${fct_2011_timestamp}    Get From Dictionary  ${reset_timestamp_dict}  FCT-2011
    ${fct_1011_timestamp}    Get From Dictionary  ${reset_timestamp_dict}  FCT-1011
    ${fct_reset_delay_diff}  Subtract Date From Date  ${fct_1011_timestamp}  ${fct_2011_timestamp}
    ${delay_diff_abs}  Evaluate  abs(${fct_reset_delay_diff})
    Should Be True  ${delay_diff_abs}<10  msg=Reset delay between FCTs was longer than expected.  #no specified requirement
    Run Keyword If  ${fct_reset_delay_diff}<10    Log To Console  The Site Reset for Primary and Secondary Core was executed in parallel which is OK
                                      ...    ELSE  Log    The Site Reset for Primary and Secondary Core was NOT executed in parallel which is NOK
    Should Be True  ${time_diff}<360  #OM_GEN_SFS_PERF_CAP.26203
    Run Keyword If  ${time_diff}<360    Log To Console    Site reset is done and it took ${time_diff}s which is less than 360s
                                      ...    ELSE  Log    Site reset is done and it took ${time_diff}s which is more than 360s

SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test Specific Setup
    Should Match Regexp  ${SMOD_COMPOSITION}  ${SMODS_ALLOWED_REGEX}  msg=${SMOD_COMPOSITION} is not dual core or consists of unsupported SMOD.
    Should Match Regexp  ${SW_TYPE}  ${SUPPORTED_SW_REGEX}            msg=${SW_TYPE} does not support actDualCoreParallelReset feature
    Setup Admin  admin_api_log_dir=/home/ute/test_results/admin_api/test_setup/parallel_site_block-unblock
    Set Parameter To Expected Value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
                              ...    parameter=actDualCoreParallelReset
                              ...    expected_value=True
    admin.Teardown Admin  alias=${ute_admin_alias}

SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
