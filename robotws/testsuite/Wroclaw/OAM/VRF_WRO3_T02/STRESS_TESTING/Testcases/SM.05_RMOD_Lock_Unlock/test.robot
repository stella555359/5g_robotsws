*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot

Documentation
...  TEST NAME:     SM.05_RMOD_Lock_Unlock
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform Radio Module lock and unlock operations for randomly chosen RM on RAN eNodeB,
...  check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  xx.xx.xxxx - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Legacy test
...  24.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-433 - robotws migration and small hotfixes
...  20.01.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-14652 - addition of verification that RMOD is locked
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
SM.05_RMOD_Lock_Unlock

    SM.05_RMOD_Lock_Unlock.Test_Step:0 Test Preparation
    SM.05_RMOD_Lock_Unlock.Test_Step:1 Select RMOD
    SM.05_RMOD_Lock_Unlock.Test_Step:2 Perform RMOD Lock
    SM.05_RMOD_Lock_Unlock.Test_Step:3 Perform RMOD Unlock

SM.05_RMOD_Lock_Unlock.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Resolve Locked RMOD
    Check If NLWG Cells Are OnAir
    SCF Backup
#    Compare current date with PSGRP/NRPGRP  PSGRP
#    Compare current date with PSGRP/NRPGRP  NRPGRP

SM.05_RMOD_Lock_Unlock.Test_Step:1 Select RMOD
    Log to console    \n========================================
    Log  Step: 1 Select RMOD  console=${True}
    Log to console    ========================================
    Get RMODs
    ${selected_rmod}  Evaluate  random.choice(${rmods})  random
    Log To Console  Selected RMOD: ${selected_rmod}
    Set Test Variable  ${selected_rmod}
    ${mapping_rmod_to_rmod_r}    Mapping RMOD To RMOD_R
    ${selected_rmod_r}    Get From Dictionary    ${mapping_rmod_to_rmod_r}    ${selected_rmod}
    Set Test Variable  ${selected_rmod_r}

SM.05_RMOD_Lock_Unlock.Test_Step:2 Perform RMOD Lock
    Log to console    \n========================================
    Log  Step: 2 Perform RMOD Lock  console=${True}
    Log to console    ========================================
    Log To Console  Lock RMOD: ${selected_rmod}
    ${status}  Run Keyword And Return Status  admin.lock  ${selected_rmod}  timeout=300
    Run Keyword If  not ${status}  admin.lock  ${selected_rmod}  timeout=180
    Log To Console  Checking if selected RMOD has reached the expected state: administrativeState=Locked, the rest of the RMODs should be Unlocked
    Wait Until Keyword Succeeds  80s  10s  admin.assert  RMOD  ${selected_rmod_r}  administrativeState=regex"(?i)Locked"
    ${bts_info}  admin.get bts info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        ${rmod_states}  Get From Dictionary  ${rmod}  status
        ${administrative_state}  Get From Dictionary  ${rmod_states}  administrativeState
        Run Keyword If  '${rmod['id']['configuration']}'=='${selected_rmod}'
        ...                 Should Be Equal As Strings   ${administrative_state}  Locked     ignore_case=True
        ...         ELSE    Should Be Equal As Strings   ${administrative_state}  Unlocked   ignore_case=True
        ${operational_state}  Get From Dictionary  ${rmod_states}  operationalState
        Should Be Equal As Strings  ${operational_state}  Enabled  ignore_case=True
        Log To Console  State of ${rmod['id']['configuration']} is correct
    END

SM.05_RMOD_Lock_Unlock.Test_Step:3 Perform RMOD Unlock
    Log to console    \n========================================
    Log  Step: 3 Perform RMOD Unlock  console=${True}
    Log to console    ========================================
    Log To Console  Unlock RMOD: ${selected_rmod}
    ${status}  Run Keyword And Return Status  admin.unlock  ${selected_rmod}  timeout=180
    Run Keyword If  not ${status}  admin.unlock  ${selected_rmod}  timeout=180
    Wait Until Keyword Succeeds  80s  10s  admin.assert  RMOD  ${selected_rmod_r}  administrativeState=regex"(?i)Unlocked"
    Log To Console  Unlock RMOD is done
    Check If NLWG Cells Are OnAir
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN
#    Reselect Cells For NRPGRP
#    Reselect Cells For PSGRP

SM.05_RMOD_Lock_Unlock.Test Specific Teardown
    [Documentation]  Test teardown which unlock all RMODs.
    Log  \nUnlock All RMODs  console=${True}
    admin.setup admin  admin_api_log_dir=${RESULTS}/specific_teardown/admin_api/  alias=${ute_admin_alias}
    ${rmod_list}=  admin.get ids for all  RMOD
    FOR  ${i}  IN  @{rmod_list}
        Log To Console With Time  Trying to unlock: ${i}
        Run Keyword And Ignore Error  admin.unlock  ${i}  timeout=240
        Sleep  60s
    END
    admin.teardown admin  alias=${ute_admin_alias}

SM.05_RMOD_Lock_Unlock.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
    Run Keyword If Test Failed  SM.05_RMOD_Lock_Unlock.Test Specific Teardown
