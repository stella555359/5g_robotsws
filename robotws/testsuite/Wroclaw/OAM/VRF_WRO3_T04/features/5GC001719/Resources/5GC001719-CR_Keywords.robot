*** Settings ***
Documentation
...  author:     Patryk Tatarek
...  contact:    patryk.tatarek@nokia.com

*** Keywords ***
Lock Cells
    [Documentation]    Description:    Lock cells on vCU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${cell_group_id}    ${conn}
    ${nr}=             Convert to String    ${cell_group_id}
    ${nr_list}=        Create List    ${nr}
    ${cell_operation}=    vcu_admin.lock_cell_group    cell_group_id=${nr_list}    connection=${conn}
    Wait Until Keyword Succeeds    3min    10s    Verify Locking Cells State    ${cell_operation["id"]}    ${conn}
    Wait Until Keyword Succeeds    3min    10s    Check if Cells are Locked    ${conn}

Unlock Cells
    [Documentation]    Description:    Lock cells on vCU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${cell_group_id}    ${conn}
    ${nr}=             Convert to String    ${cell_group_id}
    ${nr_list}=        Create List    ${nr}
    ${cell_operation}=    vcu_admin.unlock_cell_group    cell_group_id=${nr_list}    connection=${conn}
    Wait Until Keyword Succeeds    3min    10s    Verify Unlocking Cells State    ${cell_operation["id"]}    ${conn}
    Wait Until Keyword Succeeds    3min    10s    Check if Cells are Unlocked    ${conn}

Check if Cells are Locked
    [Arguments]          ${conn}
    ${cells_summary}=    vcu_admin.get_cells_summary    connection=${conn}
    Should be Equal as Integers    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}    ${1}

Check if Cells are Unlocked
    [Arguments]          ${conn}
    ${cells_summary}=    vcu_admin.get_cells_summary    connection=${conn}
    Should be Equal as Integers    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}    ${0}

Verify Locking Cells State
    [Arguments]    ${oper_id}    ${conn}
    ${state}=      vcu_admin.get_operation_state_of_locking_cells    operation_id=${oper_id}    connection=${conn}
    Should Be Equal As Strings    ${state["status"]}    success

Verify Unlocking Cells State
    [Arguments]    ${oper_id}    ${conn}
    ${state}=      vcu_admin.get_operation_state_of_unlocking_cells    operation_id=${oper_id}    connection=${conn}
    Should Be Equal As Strings    ${state["status"]}    success
