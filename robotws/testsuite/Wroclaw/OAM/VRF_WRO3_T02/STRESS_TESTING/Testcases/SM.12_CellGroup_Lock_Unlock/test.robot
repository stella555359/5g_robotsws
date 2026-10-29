*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot

Documentation
...  TEST NAME:     SM.12_CellGroup_Lock_Unlock
...  AUTHORS:       artur.lebek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform Lock/Unlock operations for random CellGroup on RAN eNodeB,
...  and check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  24.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Test creation
...  02.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-196 - Test adaptation to CNI-61110
...  15.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-283 - add KW Assert for checking if Locking operation is completed
...  24.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-431 - robotws migration and small hotfixes
...  02.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-569 - add energysaving states to be considered in Step 2 during cell states check
...  11.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26903 - Check only administrative state if cell is switchingOff
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${NRCELL_locked_disabled}=  administrativeState=regex"(?i)Locked", operationalState=regex"(?i)Disabled"

*** Keywords ***
SM.12_CellGroup_Lock_Unlock

    SM.12_CellGroup_Lock_Unlock.Test_Step:0 Test Preparation
    SM.12_CellGroup_Lock_Unlock.Test_Step:1 Select Cells Group
    SM.12_CellGroup_Lock_Unlock.Test_Step:2 Lock Cells Group
    SM.12_CellGroup_Lock_Unlock.Test_Step:3 Unlock Cells Group

SM.12_CellGroup_Lock_Unlock.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Resolve Locked Cells Group
    Check If NLWG Cells Are OnAir
    SCF Backup

SM.12_CellGroup_Lock_Unlock.Test_Step:1 Select Cells Group
    Log to console    \n========================================
    Log  Step: 1 Select Cells Group  console=${True}
    Log to console    ========================================
    ${bts_info}  admin.get bts info
    ${cellsgroups}  Set Variable  ${bts_info['cellsGroup']}
    ${group_dict}   Evaluate  random.choice(${cellsgroups})  random
    ${nrcellgrp_dn}  Replace String  ${group_dict['id']['internal']}  search_for=_A  replace_with=
    ${ignore}  ${nrcellgrp}  Split String From Right  ${nrcellgrp_dn}  separator=/  max_split=1
    Set Test Variable  ${selected_group}  ${group_dict['id']['internal']}
    Set Test Variable  ${selected_cell}   ${group_dict['nrCellList'][0]}
    Set Test Variable  ${nrcellgrp}
    Log To Console  Selected cellsGroup: ${nrcellgrp}
    Log To Console  Selected cell: ${selected_cell}

SM.12_CellGroup_Lock_Unlock.Test_Step:2 Lock Cells Group
    Log to console    \n========================================
    Log  Step: 2 Lock Cells Group  console=${True}
    Log to console    ========================================
    Log To Console  Lock Cells Group: ${nrcellgrp}
    ${status}  Run Keyword And Return Status  admin.lock cell group  ${selected_group}  timeout=360
    Run Keyword If  not ${status}  admin.lock cell group  ${selected_group}  timeout=360
    ${NRCELL_to_NRCELL_R}  Mapping NRCELL to NRCELL_R
    ${NRCELL_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${NRCELL_R}  Get From Dictionary  ${NRCELL_to_NRCELL_R}  ${NRCELL_DN}
    Wait Until Keyword Succeeds  1min  5sec  admin.Assert  NRCEL  ${NRCELL_R}  ${NRCELL_locked_disabled}
    ${nrcells}  admin.get cells info  cell_type=nr
    Log To Console  Checking if selected NRCEL has reached the expected state: administrativeState=Locked, operationalState=Disabled  no_newline=true
    Log To Console  ${SPACE}the rest of the NRCELs should be administrativeState=Unlocked, operationalState=Enabled.  no_newline=true
    Log To Console  ${SPACE}Cells with energySavingState=EnergySaving are expected to have: administrativeState=Unlocked, operationalState=Disabled
    FOR  ${nrcell}  IN  @{nrcells}
        ${values}       Get Dictionary Values  ${nrcell}
        ${cell_states}             Get From Dictionary  ${nrcell}       status
        ${energysaving_state}      Get From Dictionary  ${nrcell}       energySavingState
        ${administrative_state}    Get From Dictionary  ${cell_states}  administrativeState
        ${operational_state}       Get From Dictionary  ${cell_states}  operationalState
        ${is_energysaving}  Run Keyword And Return Status  Should Be Equal As Strings  ${energysaving_state}  EnergySaving  ignore_case=True
        ${is_switchingOff}  Run Keyword And Return Status  Should Match Regexp  ${energysaving_state}  SwitchingOff  flags=IGNORECASE
        Run Keyword If  '${nrcell['id']['configuration']}'=='${NRCELL_DN}'  Run Keywords
        ...                       Should Be Equal As Strings  ${administrative_state}  Locked    ignore_case=True
        ...  AND                  Should Be Equal As Strings  ${operational_state}     Disabled  ignore_case=True
        ...  ELSE IF  ${is_energysaving}  Run Keywords
        ...                       Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
        ...  AND                  Should Be Equal As Strings  ${operational_state}     Disabled  ignore_case=True
        ...  ELSE IF  ${is_switchingOff}
        ...                       Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
        ...  ELSE   Run Keywords
        ...                       Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
        ...  AND                  Should Be Equal As Strings  ${operational_state}     Enabled   ignore_case=True
        Log To Console  State of ${nrcell['id']['configuration']} is correct
    END

SM.12_CellGroup_Lock_Unlock.Test_Step:3 Unlock Cells Group
    Log to console    \n========================================
    Log  Step: 3 Unlock Cells Group  console=${True}
    Log to console    ========================================
    Log To Console  Unlock Cells Group: ${nrcellgrp}
    ${status}  Run Keyword And Return Status  admin.unlock cell group  ${selected_group}  timeout=360
    Run Keyword If  not ${status}  admin.unlock cell group  ${selected_group}  timeout=360
    Log To Console  Unlock Cells Group is done
    Check If NLWG Cells Are OnAir
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN

SM.12_CellGroup_Lock_Unlock.Test Specific Teardown
    [Documentation]  Test teardown which unlock selected cells group.
    admin.setup admin  admin_api_log_dir=${RESULTS}/specific_teardown/admin_api/  alias=${ute_admin_alias}
    Log To Console With Time  Trying to unlock cells group: ${nrcellgrp}
    Run Keyword And Ignore Error  admin.unlock cell group  ${selected_group}  timeout=360
    Sleep  10s
    admin.teardown admin  alias=${ute_admin_alias}

SM.12_CellGroup_Lock_Unlock.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
    Run Keyword If Test Failed  SM.12_CellGroup_Lock_Unlock.Test Specific Teardown
