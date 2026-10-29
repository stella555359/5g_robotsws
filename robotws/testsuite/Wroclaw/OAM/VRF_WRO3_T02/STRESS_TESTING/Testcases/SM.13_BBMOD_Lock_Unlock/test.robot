*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.13_BBMOD_Lock_Unlock
...  AUTHORS:       aleksandra.trojak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform BBMOD lock and unlock operation for random baseband module on eNB
...  and then check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  11.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-76 - Test creation
...  15.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-93 - Test adaptation to CNI-61110
...  13.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-185 - Added KW Resolve locked BBMODs
...  21.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-425 - robotws migration and small hotfixes
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.13_BBMOD_Lock_Unlock

    SM.13_BBMOD_Lock_Unlock.Test_Step:0 Test Preparation
    SM.13_BBMOD_Lock_Unlock.Test_Step:1 Select BBMOD
    SM.13_BBMOD_Lock_Unlock.Test_Step:2 Perform BBMOD Lock
    SM.13_BBMOD_Lock_Unlock.Test_Step:3 Perform BBMOD Unlock

SM.13_BBMOD_Lock_Unlock.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Resolve Locked BBMOD
    Check If NLWG Cells Are OnAir
    SCF Backup
#    Compare current date with PSGRP/NRPGRP  PSGRP
#    Compare current date with PSGRP/NRPGRP  NRPGRP

SM.13_BBMOD_Lock_Unlock.Test_Step:1 Select BBMOD
    Log to console    \n========================================
    Log  Step: 1 Select BBMOD  console=${True}
    Log to console    ========================================
    Get BBMODs
    ${selected_bbmod}  Evaluate  random.choice(${bbmods})  random
    Log To Console  Selected BBMOD: ${selected_bbmod}
    Set Test Variable  ${selected_bbmod}

SM.13_BBMOD_Lock_Unlock.Test_Step:2 Perform BBMOD Lock
    Log to console    \n========================================
    Log  Step: 2 Perform BBMOD Lock  console=${True}
    Log to console    ========================================
    Log To Console  Lock BBMOD: ${selected_bbmod}
    ${status}  Run Keyword And Return Status  admin.lock  ${selected_bbmod}  timeout=700
    Run Keyword If  not ${status}  admin.lock  ${selected_bbmod}  timeout=700
    Log To Console  Checking if selected BBMOD has reached the expected state: administrativeState=Locked, the rest of the BBMODs should be Unlocked
    ${bts_info}  admin.get bts info
    FOR  ${bbmod}  IN  @{bts_info['basebandModules']}
        ${bbmod_states}  Get From Dictionary  ${bbmod}  status
        ${administrative_state}  Get From Dictionary  ${bbmod_states}  administrativeState
        Run Keyword And Ignore Error    Run Keyword If  '${bbmod['id']['configuration']}'=='${selected_bbmod}'
        ...                 Should Be Equal As Strings   ${administrative_state}  Locked     ignore_case=True
        ...         ELSE    Should Be Equal As Strings   ${administrative_state}  Unlocked   ignore_case=True
        ${operational_state}  Get From Dictionary  ${bbmod_states}  operationalState
        Should Be Equal As Strings  ${operational_state}  Enabled  ignore_case=True
        Log To Console  State of ${bbmod['id']['configuration']} is correct
    END

SM.13_BBMOD_Lock_Unlock.Test_Step:3 Perform BBMOD Unlock
    Log to console    \n========================================
    Log  Step: 3 Perform BBMOD Unlock  console=${True}
    Log to console    ========================================
    Log To Console  Unlock BBMOD: ${selected_bbmod}
    ${status}  Run Keyword And Return Status  admin.unlock  ${selected_bbmod}  timeout=120
    Run Keyword If  not ${status}  admin.unlock  ${selected_bbmod}  timeout=120
    Log To Console  Unlock BBMOD is done
    Check If NLWG Cells Are OnAir
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN
#    Reselect Cells For NRPGRP
#    Reselect Cells For PSGRP

SM.13_BBMOD_Lock_Unlock.Test Specific Teardown
    [Documentation]  Test teardown which unlock all BBMODs.
    Log  \nUnlock all BBMODs  console=${True}
    admin.setup admin  admin_api_log_dir=${RESULTS}/specific_teardown/admin_api/  alias=${ute_admin_alias}
    ${bbmod_list}  admin.get ids for all  BBU
    FOR  ${i}  IN  @{bbmod_list}
        Log To Console With Time  Trying to unlock: ${i}
        Run Keyword And Ignore Error  admin.unlock  ${i}  timeout=240
        Sleep  60s
    END
    admin.teardown admin  alias=${ute_admin_alias}

SM.13_BBMOD_Lock_Unlock.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
    Run Keyword If Test Failed  SM.13_BBMOD_Lock_Unlock.Test Specific Teardown
