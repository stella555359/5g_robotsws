*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.47_BBMOD_Power_Reset_via_WebEM
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    VRF_WRO3_T02
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform BBMOD power reset operation on randomly selected BBMOD
...  and check BTS status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  Available since 24R3 - CB010883 (OM_GEN_SFS_SYSM.5282)
...  Granular BBMOD/FSP reset is allowed only when there is no GSM/WCDMA cell and the FSP reset is supported by HW (CB010883-7314)
...  ******************
...  History of changes
...  ******************
...  19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-618 - Test creation

...  *******************
...  RAN PZ3 WRO1 TEMPLATE



*** Keywords ***
SM.47_BBMOD_Power_Reset_via_WebEM
    SM.47_BBMOD_Power_Reset_via_WebEM.Test_Step:0 Test Preparation
    SM.47_BBMOD_Power_Reset_via_WebEM.Test_Step:1 BBMOD Power Reset
    SM.47_BBMOD_Power_Reset_via_WebEM.Test_Step:2 KPI Time Measurement
    SM.47_BBMOD_Power_Reset_via_WebEM.Test_Step:3 Final Checkpoint

SM.47_BBMOD_Power_Reset_via_WebEM.Test_Step:0 Test Preparation
    Log To Console  \n========================================
    Log To Console  Step 0: Test Preparation
    Log To Console  ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    SCF Backup
    ${BBMODs_R}  Get Resettable BBMOD
    ${selected_bbmod_r}  Evaluate  random.choice(${BBMODs_R})  random
    ${bbmods_mapping}  BBMOD Mapping
    ${selected_bbmod}  Get From Dictionary  ${bbmods_mapping}  ${selected_bbmod_r}
    ${lte_cells}  admin.Assert Any  LNCEL
    ${nr_cells}   admin.Assert Any  NRCEL
    ${lte_cells_count}  Get Length  ${lte_cells}
    ${nr_cells_count}   Get Length  ${nr_cells}
    ${affected_cells}   Get Cell Mapping By Module Id  ${selected_bbmod_r}
    ${affected_nr_cells_count}   Evaluate  len([cell for cell in ${affected_cells} if 'NRCEL' in cell])
    ${affected_lte_cells_count}  Evaluate  len([cell for cell in ${affected_cells} if 'LNCEL' in cell])
    ${all_nr_affected}           Evaluate  ${affected_nr_cells_count}==${nr_cells_count}
    ${all_lte_affected}          Evaluate  ${affected_lte_cells_count}==${lte_cells_count}
    Set Test Variable  ${selected_bbmod}
    Set Test Variable  ${all_nr_affected}
    Set Test Variable  ${all_lte_affected}


SM.47_BBMOD_Power_Reset_via_WebEM.Test_Step:1 BBMOD Power Reset
    Log To Console  \n========================================
    Log To Console  Step 1: BBMOD Power Reset
    Log To Console  ========================================
    Run Keyword If  ${all_nr_affected}   Run Keywords
                         ...             Allow Fault In Watchdog  faultID=7319  #No X2 link available for a specific LTEENB
                         ...       AND   Allow Fault In Watchdog  faultID=7300  #No X2 link available
    Run Keyword If  ${all_lte_affected}  Allow Fault In Watchdog  faultID=7107  #Cell problem due to associated X2/NG/E1 link unavailability
    Log To Console  Resetting ${selected_bbmod}
    admin.Reset Unit  ${selected_bbmod}  reset_type=PowerReset  timeout=240  graceful_cell_shutdown=False
    Log To Console  BBMOD power reset is done.
    Check BBMODs State  ${BBMOD_expected_states}  10s  5s
    Check If NLWG Cells Are OnAir
    Run Keyword If  ${all_nr_affected}   Run Keywords
                         ...             Disallow Fault In Watchdog  faultID=7319  #No X2 link available for a specific LTEENB
                         ...       AND   Disallow Fault In Watchdog  faultID=7300  #No X2 link available
    Run Keyword If  ${all_lte_affected}  Disallow Fault In Watchdog  faultID=7107  #Cell problem due to associated X2/NG/E1 link unavailability


SM.47_BBMOD_Power_Reset_via_WebEM.Test_Step:2 KPI Time Measurement
    Log To console  \n========================================
    Log To Console  Step: 3 KPI Time Measurement
    Log To console  ========================================
    Run Keyword And Ignore Error  Calculate KPI14  ${ITERATION_INDEX}


SM.47_BBMOD_Power_Reset_via_WebEM.Test_Step:3 Final Checkpoint
    Log To Console  \n========================================
    Log To Console  Step 2: Final Checkpoint
    Log To Console  ========================================
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}


SM.47_BBMOD_Power_Reset_via_WebEM.Test Case Teardown
    common.Common Test Teardown - MEMORY
