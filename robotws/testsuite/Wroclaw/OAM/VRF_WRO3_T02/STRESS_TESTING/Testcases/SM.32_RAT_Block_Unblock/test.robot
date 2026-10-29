*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.32_RAT_Block_Unblock
...  AUTHORS:       pawel.bartkowiak@nokia.com,
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform RAT BLOCK/UNBLOCK operations for every RAT on RAN eNodeB,
...  check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  23.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-582 - Test creation

...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Keywords ***
SM.32_RAT_Block_Unblock
    SM.32_RAT_Block_Unblock.Test_Step:0 Test Preparation
    SM.32_RAT_Block_Unblock.Test_Step:1 Block/Unblock RATs
    SM.32_RAT_Block_Unblock.Test_Step:2 Final Checkpoint

SM.32_RAT_Block_Unblock.Test_Step:0 Test Preparation
    Log To Console  \n========================================
    Log To Console  Step: 0 Test Preparation
    Log To Console  ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    ${rats}  Evaluate  random.sample(${rats}, len(${rats}))  random
    Resolve Blocked RAT
    Check If NLWG Cells Are OnAir
    SCF Backup


SM.32_RAT_Block_Unblock.Test_Step:1 Block/Unblock RATs
    Log To Console  \n========================================
    Log To Console  Step: 1 Block/Unblock RATs
    Log To Console  ========================================
    FOR  ${rat}  IN  @{rats}
        Allow Fault In Watchdog  faultID=4614    #rat blocked
        ${rat_upper}  Convert To Upper Case  ${rat}
        Log To Console  \nBlocking ${rat_upper}...
        admin.block_rat    ${rat_upper}    timeout=180
        Wait Until keyword Succeeds  4x  20s    Check If All RAT Cells Are In Expected State  ${rat}  DISABLED
        Wait For Active Fault    4614    timeout=180 sec
        Check If NLWG Cells Are OnAir for Rat Block    ${rat}
        Sleep    10s
        admin.unblock_rat    ${rat_upper}    timeout=180
        Wait For Inactive Fault    4614    timeout=180 sec
        Disallow Fault In Watchdog  faultID=4614    #rat blocked
    END


SM.32_RAT_Block_Unblock.Test_Step:2 Final Checkpoint
    Log To Console  \n========================================
    Log To Console  Step: 2 Final Checkpoint
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


SM.32_RAT_Block_Unblock.Test Case Teardown
    ${rats}  Evaluate  random.sample(${rats}, len(${rats}))  random
    FOR  ${rat}  IN  @{rats}
        ${rat}  Convert To Upper Case  ${rat}
        Run Keyword And Ignore Error    admin.unblock_rat  ${rat}
    END
    common.Common Test Teardown - MEMORY

##### TEST SPECYFIC KEYWORDS ########################
Check If All RAT Cells Are In Expected State
    [Arguments]   ${rat_id}    ${expected_operationalState}
    Log  \n  console=True
    ${cells_list}  admin.get cell list
    ${rat_cell_list}    Set Variable    ${cells_list['cells']['${rat_id}']}
    FOR  ${cell}  IN  @{rat_cell_list}
        ${cell_id}  Get from dictionary  ${cell}  id
        ${cell_path}  Get from dictionary  ${cell_id}  internal
        ${operational_state}  Evaluate  "${cell['status']['operationalState']}".upper()
        Log   Cell: ${cell_path} checked if ${expected_operationalState}    INFO   console=True
        Log   Cell's states: ${operational_state}    INFO   console=True
    END

Check If NLWG Cells Are OnAir for Rat Block
    [Arguments]  ${rat}    ${GSM_AvailabilityStatus_check}=True
    ${GSM_DEPLOYED}=    admin.get ids for all  GNCEL
    ${WCDMA_DEPLOYED}=  admin.get ids for all  WNCEL
    ${LTE_DEPLOYED}=    admin.get ids for all  LNCEL
    ${NR_DEPLOYED}=     admin.get ids for all  NRCEL

    Run Keyword If  ${GSM_DEPLOYED}!=[] and '${rat}'!='gsm'    Check GNCELs  ${GSM_AvailabilityStatus_check}
    Run Keyword If  ${WCDMA_DEPLOYED}!=[] and '${rat}'!='wcdma'  Check WNCELs
    Run Keyword If  ${LTE_DEPLOYED}!=[] and '${rat}'!='lte'
    ...    Wait Until Keyword Succeeds  2min  30s  Check LNCEL/NRCELL OnAir Or EnergySaving State  lte
    Run Keyword If  ${NR_DEPLOYED}!=[] and '${rat}'!='nr'   Wait Until Keyword Succeeds  2min  30s  Check LNCEL/NRCELL OnAir Or EnergySaving State  nr

