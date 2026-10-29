*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot

Documentation
...  TEST NAME:     SM.17_Cell_Reset
...  AUTHORS:       artur.lebek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform cell reset operation for random cell for each existing RAT on a given TL
...  and then check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  27.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-344 - TC creation
...  21.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-460 - change of logic and small hotfixes
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.17_Cell_Reset

    SM.17_Cell_Reset.Test_Step:0 Test Preparation
    SM.17_Cell_Reset.Test_Step:1 Resetting Cell
    SM.17_Cell_Reset.Test_Step:2 Final Checkpoint

SM.17_Cell_Reset.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    SCF Backup
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    ${cells_list}  admin.get cell list
    ${cells_list['cells']['lte']}  Get Cells List Without IoT
    ${selected_cells}  Create List
    FOR  ${rat}  IN  @{rats}
        ${selected_dict}  Run Keyword If  ${cells_list['cells']['${rat}']}!=[]
        ...  Evaluate  random.choice(${cells_list['cells']['${rat}']})  random
        Run Keyword If  '${rat}'=='nr'     Log To Console  Selected NRCEL: ${selected_dict['id']['configuration']}
        ...  ELSE IF    '${rat}'=='lte'    Log To Console  Selected LNCEL: ${selected_dict['id']['configuration']}
        ...  ELSE IF    '${rat}'=='wcdma'  Log To Console  Selected WNCEL: ${selected_dict['id']['configuration']}
        ...  ELSE IF    '${rat}'=='gsm'    Log To Console  Selected GNCEL: ${selected_dict['id']['configuration']}
        Append To List  ${selected_cells}  ${selected_dict['id']['configuration']}
    END
    Set Test Variable    ${selected_cells}

SM.17_Cell_Reset.Test_Step:1 Resetting Cell
    Log to console    \n========================================
    Log  Test_Step:1 Resetting Cell  console=${True}
    Log to console    ========================================
    Log to console  Reset random cell for each existing RAT
    ${if_gsm_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  gsm
    Run Keyword If  ${if_gsm_exist}  Run Keyword  Allow Fault In Watchdog  faultID=4399  #fault_name: One or more carrier groups blocked
    FOR  ${cell}  IN  @{selected_cells}
        Log To Console  Reseting: ${cell}
        admin.reset cell  ${cell}  timeout=180
        Check If NLWG Cells Are OnAir
        Run Keyword If  ${INTEGRATED_TO_NETACT}  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
    END
    Run Keyword If  ${if_gsm_exist}  Run Keyword  Disallow Fault In Watchdog  faultID=4399  #fault_name: One or more carrier groups blocked

SM.17_Cell_Reset.Test_Step:2 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Run Keyword If  ${INTEGRATED_TO_NETACT}  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}

SM.17_Cell_Reset.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
