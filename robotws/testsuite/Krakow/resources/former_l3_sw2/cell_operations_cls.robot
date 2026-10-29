*** Settings ***
Documentation
...            Keywords for cell operations and checking cell states
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    ta5g_cell_operations    WITH NAME    cellop
Library    ./Python/utilities_obj.py      WITH NAME     utilities_obj

*** Keywords ***
Wait for All Cells to be Enabled
    [Documentation]    Waits for all cells to be in Enabled state.
    ...                - ``timeout``: Maximum time to wait in seconds, Default: 180
    [Arguments]    ${timeout}=180
    Log to Console    Waiting ${timeout}s for all cells to be in state: Enabled
    cellop.wait_for_all_cells_to_be_enabled    timeout=${timeout}

Wait for All Cells to be Disabled
    [Documentation]    Waits for all cells to be in Enabled state.
    ...                - ``timeout``: Maximum time to wait in seconds, Default: 180
    [Arguments]    ${timeout}=180
    Log to Console    Waiting ${timeout}s for all cells to be in state: Disabled
    utilities_obj.wait for cells to be disabled        timeout=${timeout}

Wait for All Cells to be Locked
    [Documentation]    Waits for all cells to be in Locked state.
    ...                - ``timeout``: Maximum time to wait in seconds, Default: 180
    [Arguments]    ${timeout}=180
    Log to Console    Waiting ${timeout}s for all cells to be in state: Locked
    cellop.wait_for_all_cells_to_be_locked    timeout=${timeout}

Wait for All Cells to be Configured
    [Documentation]    Waits for all cells to be in Configured state.
    ...                - ``timeout``: Maximum time to wait in seconds, Default: 180
    [Arguments]    ${timeout}=180
    Log to Console    Waiting ${timeout}s for all cells to be in state: Configured
    cellop.wait_for_all_cells_to_be_configured    timeout=${timeout}

Wait for All Cells to be in Correct State
    [Documentation]    Waits for all cells to be in Configured, Enabled or Locked state.
    ...                - ``state``: Configured / Enabled / Locked
    ...                - ``timeout``: Maximum time to wait in seconds, Default: 180
    [Arguments]    ${state}    ${timeout}=180
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${state}' in ('Configured','Enabled','Locked')   msg=Invalid KW parameter: state
    #---------------------------------------------------------------------------------------------------------------
    Run Keyword    Wait for All Cells to be ${state}    timeout=${timeout}

Wait for Single Cell to be in Locked State
    [Documentation]    Waits for single cell to be in Locked state.
    ...                - ``timeout``: Maximum time to wait in seconds, Default: 180
    ...                - ``id``: Cell ID
    [Arguments]    ${id}=1    ${timeout}=180
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${id}) is int    msg=Invalid KW parameter: id
    #---------------------------------------------------------------------------------------------------------------
    Log to Console    Waiting ${timeout}s for single cell-${id} to be in state: Locked
    cellop.wait_for_cell_to_be_locked    cell_id=${id}    timeout=${timeout}

Wait for Single Cell to be in not Locked State
    [Documentation]    Waits for single cell to be in not Locked state.
    ...                - ``timeout``: Maximum time to wait in seconds, Default: 180
    ...                - ``id``: Cell ID
    [Arguments]    ${id}=1    ${timeout}=180
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${id}) is int    msg=Invalid KW parameter: id
    #---------------------------------------------------------------------------------------------------------------
    Log to Console    Waiting ${timeout}s for single cell-${id} to be in state: Unlocked
    cellop.wait_for_cell_to_be_not_locked    cell_id=${id}    timeout=${timeout}

Wait for All Cells to be in not Locked State
    [Documentation]    Waits for all cells to be in not Locked state.
    ...                - ``timeout``: Maximum time to wait in seconds, Default: 180
    ...                - ``id``: Cell ID
    [Arguments]    ${timeout}=180
    Log to Console    Waiting ${timeout}s for all cells to be in state: Unlocked
    cellop.wait_for_all_cells_to_be_not_locked    timeout=${timeout}

Lock All Cells
    [Documentation]    Sends COAM API command to lock all cells.
    cellop.lock_all_cells

Unlock All Cells
    [Documentation]    Sends COAM API command to unlock all cells.
    cellop.unlock_all_cells

Lock Single Cell
    [Documentation]    Sends COAM API command to lock single cell.
    ...                - ``id``: Cell ID
    [Arguments]    ${id}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${id}) is int    msg=Invalid KW parameter: id
    #---------------------------------------------------------------------------------------------------------------
    cellop.lock_single_cell    cell_id=${id}

Unlock Single Cell
    [Documentation]    Sends COAM API command to unlock single cell.
    ...                - ``id``: Cell ID
    [Arguments]    ${id}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${id}) is int    msg=Invalid KW parameter: id
    #---------------------------------------------------------------------------------------------------------------
    cellop.unlock_single_cell    cell_id=${id}

Block All Cells
    [Documentation]    Sends COAM API command to block all cells.
    cellop.block_all_cells

Unblock All Cells
    [Documentation]    Sends COAM API command to unblock all cells.
    cellop.unblock_all_cells

Block Single Cell
    [Documentation]    Sends COAM API command to block single cell.
    ...                - ``id``: Cell ID
    [Arguments]    ${id}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${id}) is int    msg=Invalid KW parameter: id
    #---------------------------------------------------------------------------------------------------------------
    cellop.block_single_cell    cell_id=${id}

Unblock Single Cell
    [Documentation]    Sends COAM API command to unblock single cell.
    ...                - ``id``: Cell ID
    [Arguments]    ${id}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${id}) is int    msg=Invalid KW parameter: id
    #---------------------------------------------------------------------------------------------------------------
    cellop.unblock_single_cell    cell_id=${id}
