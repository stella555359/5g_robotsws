*** Settings ***
Documentation
    ...    This resource is used to verify the operational state of cells in vCU and vDU CNFs.
    ...    History of changes:    04.07.2025 - Review fixes and new naming convention
    ...                           01.06.2025 - Initial creation
    ...    Author:         lukasz.lechowicz@nokia.com
Library     CellStatus.py

*** Keywords ***

Verify All vCU Cells Are Enabled
    [Documentation]    Description:    Verifies that all cells in the vCU are in an enabled state.
    ...                Input:          connection = vCU connection object coming from connection setup
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]        ${connection}
    ${cell_list}=    vcu_admin.Get Cells Summary    connection=${connection}
    All Cells Should Be Enabled    ${cell_list}

Verify All vCU Cells Are Disabled
    [Documentation]    Description:    Verifies that all cells in the vCU are in a disabled state.
    ...                Input:          connection = vCU connection object coming from connection setup
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]        ${connection}
    ${cell_list}=    vcu_admin.Get Cells Summary    connection=${connection}
    All Cells Should Be Disabled    ${cell_list}

Verify At Least One vCU Cell Is Disabled
    [Documentation]    Description:    Verifies that at least one cell in the vCU is in a disabled state.
    ...                Input:          connection = vCU connection object coming from connection setup
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]        ${connection}
    ${cell_list}=    vcu_admin.Get Cells Summary   connection=${connection}
    At Least One Cell Should Be Disabled   ${cell_list}

Verify At Least One vCU Cell Is Enabled
    [Documentation]    Description:    Verifies that at least one cell in the vCU is in an enabled state.
    ...                Input:          connection = vCU connection object coming from connection setup
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]        ${connection}
    ${cell_list}=    vcu_admin.Get Cells Summary   connection=${connection}
    At Least One Cell Should Be Enabled   ${cell_list}

Check vCU Cell Operational State
    [Documentation]    Description:    Verifies the operational state of a specific cell in the vCU.
    ...                Input:          connection = vCU connection object coming from connection setup
    ...                                cell_id = ID of the cell to check
    ...                                expected_operational_state = expected operational state of the cell (default is enabled)
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]    ${connection}
    ...            ${cell_id}=1
    ...            ${expected_operational_state}=enabled
    ${cell_list}=    vcu_admin.Get Cells Statuses   connection=${connection}
    Assert Cell Operational State    cell_list=${cell_list}
    ...                              cell_id=${cell_id}
    ...                              expected_operational_state=${expected_operational_state}

Verify All vDU Cells Are Enabled
    [Documentation]    Description:    Verifies that all cells in the vDU are in an enabled state.
    ...                Input:          connection = vDU connection object coming from connection setup
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]        ${vdu_connection}
    ${cell_list}=    vdu_admin.Get vDU Cells Summary    vdu_connection=${vdu_connection}
    All Cells Should Be Enabled    ${cell_list}

Verify All vDU Cells Are Disabled
    [Documentation]    Description:    Verifies that all cells in the vDU are in a disabled state.
    ...                Input:          connection = vDU connection object coming from connection setup
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]        ${vdu_connection}
    ${cell_list}=    vdu_admin.Get vDU Cells Summary    vdu_connection=${vdu_connection}
    All Cells Should Be Disabled    ${cell_list}

Verify At Least One vDU Cell Is Disabled
    [Documentation]    Description:    Verifies that at least one cell in the vDU is in a disabled state.
    ...                Input:          connection = vDU connection object coming from connection setup
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]        ${vdu_connection}
    ${cell_list}=    vdu_admin.Get vDU Cells Summary   vdu_connection=${vdu_connection}
    At Least One Cell Should Be Disabled   ${cell_list}

Verify At Least One vDU Cell Is Enabled
    [Documentation]    Description:    Verifies that at least one cell in the vDU is in an enabled state.
    ...                Input:          connection = vDU connection object coming from connection setup
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]        ${vdu_connection}
    ${cell_list}=    vdu_admin.Get vDU Cells Summary   vdu_connection=${vdu_connection}
    At Least One Cell Should Be Enabled   ${cell_list}

Check vDU Cell Operational State
    [Documentation]    Description:    Verifies the operational state of a specific cell in the vDU.
    ...                Input:          connection = vDU connection object coming from connection setup
    ...                                cell_id = ID of the cell to check
    ...                                expected_operational_state = expected operational state of the cell (default is enabled)
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]    ${vdu_connection}
    ...            ${cell_id}=1
    ...            ${expected_operational_state}=enabled
    ${cell_list}=    vdu_admin.Get vDU Cells Status   vdu_connection=${vdu_connection}
    Assert Cell Operational State    cell_list=${cell_list}
    ...                              cell_id=${cell_id}
    ...                              expected_operational_state=${expected_operational_state}

Get vDU Random Cell ID
    [Documentation]    Description:    This keyword picks random cell ID from all cells on vDU.
    ...                Output:         Random cell ID, for example: 12
    ...                Author:         damian.kotula@nokia.com
    ${cell_id_list}=    Create List
    ${cells info}=    vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}    timeout=60
    FOR    ${cell_info}    IN    @{cells_info}
          Append To List    ${cell_id_list}    ${cell_info["id"]}
    END
    ${random_cell_id}=    Evaluate    random.choice(${cell_id_list})    modules=random
    Log    Random Cell ID: ${random_cell_id}
    [Return]    ${random_cell_id}
