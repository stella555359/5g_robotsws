*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/big_delta.robot

Documentation
...  TEST NAME:     MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin
...  AUTHORS:       artur.lebek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Test is performing two delta commissionings to delete and restore 1000 LN objects configured on eNB
...  with status checking in between.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  25.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Legacy test - New tempate adaptation
...  31.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-403 - robotws migration and small hotfixes
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin

    MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin.Test_Step:0 Test Preparation
    MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin.Test_Step:1 Commission 1000 neighbouring objects
    MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin.Test_Step:2 Delete 1000 neighbouring objects

MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    SCF Backup

MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin.Test_Step:1 Commission 1000 neighbouring objects
    Log to console    \n========================================
    Log  Step: 1 Commission 1000 neighbouring objects  console=${True}
    Log to console    ========================================
    Generate And Activate Big Delta Plan Removal - LTE Neighbouring Objects
    Generate And Activate Big Delta Plan - LTE Neighbouring Objects

MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin.Test_Step:2 Delete 1000 neighbouring objects
    Log to console    \n========================================
    Log  Step: 2 Delete 1000 neighbouring objects  console=${True}
    Log to console    ========================================
    Generate And Activate Big Delta Plan Removal - LTE Neighbouring Objects
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Changed  WARN

MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
