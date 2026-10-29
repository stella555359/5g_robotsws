*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/big_delta.robot

Documentation
...  TEST NAME:     MEM.03_Memory_consumption_veryfication_on_FHS
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  New scenario introduced based on https://jiradc.ext.net.nokia.com/browse/RDI-13656
...  Pronto related with EDA action: 04176381
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  09.01.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-14511 - New test creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${set_memory_threshold_value}    80  #[%]

*** Keywords ***
MEM.03_Memory_consumption_veryfication_on_FHS

    MEM.03_Memory_consumption_veryfication_on_FHS.Test_Step:0 Test Preparation
    MEM.03_Memory_consumption_veryfication_on_FHS.Test_Step:1 Verify memory on FHS
    MEM.03_Memory_consumption_veryfication_on_FHS.Test_Step:2 Check BTS

MEM.03_Memory_consumption_veryfication_on_FHS.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    SCF Backup

MEM.03_Memory_consumption_veryfication_on_FHS.Test_Step:1 Verify Memory on FHS
    Log to console    \n========================================
    Log  Step: 1 Verify memory on FHS  console=${True}
    Log to console    ========================================
    Check Memory Usage On FHS  ${set_memory_threshold_value}

MEM.03_Memory_consumption_veryfication_on_FHS.Test_Step:2 Check BTS
    Log to console    \n========================================
    Log  Step: 2 Check BTS  console=${True}
    Log to console    ========================================
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir

MEM.03_Memory_consumption_veryfication_on_FHS.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
