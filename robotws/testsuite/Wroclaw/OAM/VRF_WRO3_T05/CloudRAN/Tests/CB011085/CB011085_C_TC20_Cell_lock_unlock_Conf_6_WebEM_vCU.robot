*** Settings ***
Documentation
    ...    This test case is used to verify the KPI 16a (cell lock time) and
    ...    KPI 16b (cell unlock time) for vDU.
    ...    History of changes:     25.10.2024 - Initial creation
    ...    29.11.2024 - Changes after review
    ...    Author:         damian.kotula@nokia.com

Library    random

*** Variables ***
${CELL_LOCKED}             ${FALSE}    #used to store state of the cell for teardown purposes
${CELL_ID}                 1     #cell used in test
${TC20_N}                  10    #number of lock/unlock loops
${KPI_16a_target}          80    #base target in seconds for Config 6
${KPI_16b_target}          80    #base target in seconds for Config 6
@{KPI_16a_results}         #list to store KPI 16a results
@{KPI_16b_results}         #list to store KPI 16b results

*** Keywords ***
CB011085_C_TC20_Cell_lock_unlock_Conf_6_WebEM_vCU
    Step 1: Perform ${TC20_N} Lock/Unlock Loops
    Step 2: Verify Results


Step 1: Perform ${TC20_N} Lock/Unlock Loops
    [Documentation]    Description:    In this step the cell is locked and unlocked ${TC20_N} times.
    ...                                The average of KPI 16a and 16b is calculated.

    Log    \nStep 1: Perform ${TC20_N} Lock/Unlock Loops    console=${True}
    Repeat Keyword    ${TC20_N} times    Lock And Unlock Cell
    ${average_KPI_16a}=    Calculate Average KPI    @{KPI_16a_results}
    ${average_KPI_16b}=    Calculate Average KPI    @{KPI_16b_results}
    ${average_KPI_16a}=    Convert To Number    ${average_KPI_16a}    precision=2
    ${average_KPI_16b}=    Convert To Number    ${average_KPI_16b}    precision=2
    Set Test Variable    ${average_KPI_16a}
    Set Test Variable    ${average_KPI_16b}
    ${results}=     Create List     KPI 16a:    @{KPI_16a_results}    KPI 16b:    @{KPI_16b_results}
    ${averages}=    Create List     KPI 16a: ${average_KPI_16a}s      KPI 16b: ${average_KPI_16b}s
    ${targets}=     Create List     KPI 16a: ${KPI_16a_target}s       KPI 16b: ${KPI_16b_target}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}

Step 2: Verify Results
    [Documentation]    Description:    In this step the average KPI 16a and 16b are compared with the target values.

    IF    ${average_KPI_16a} <= ${kpi_16a_target}
          Log    Average KPI 16a: ${average_KPI_16a}. KPI target is met.    console=${True}
    ELSE
          Fail    KPI 16a is exceeding the target. Average result: ${average_KPI_16a}.
    END
    IF    ${average_KPI_16b} <= ${kpi_16b_target}
          Log    Average KPI 16b: ${average_KPI_16b}. KPI target is met.    console=${True}
    ELSE
          Fail    KPI 16b is exceeding the target. Average result: ${average_KPI_16b}.
    END

Lock And Unlock Cell
    [Documentation]    Description:    This keyword locks and unlocks the cell, takes timestamps of start and
    ...                                end of the locking and unlocking process calculates the time passed and
    ...                                adds the result to the KPI list of results.

    Log    \nLock And Unlock Cell    console=${True}
    ${selected_cell}=    Convert To List    ${CELL_ID}
    Set Test Variable    ${SELECTED_CELL}
    ${kpi_16a_start_point}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Log    KPI 16a Start Point: ${kpi_16a_start_point}    console=${True}
    vcu_admin.Lock Cells    cell_ids=${SELECTED_CELL}    connection=${vcu_connection}
    Wait Until Keyword Succeeds    2 minutes    200ms    Check Operational State Of Cell    expected_state=disabled
    ${kpi_16a_end_point}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Log    KPI 16a End Point: ${kpi_16a_end_point}    console=${True}
    ${kpi_16a_result}=    Calculate KPI    ${kpi_16a_start_point}    ${kpi_16a_end_point}
    Log    KPI 16a Result: ${kpi_16a_result}    console=${True}
    Append To List    ${KPI_16a_results}    ${kpi_16a_result}
    ${kpi_16b_start_point}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Log    KPI 16b Start Point: ${kpi_16b_start_point}    console=${True}
    vcu_admin.Unlock Cells    cell_ids=${SELECTED_CELL}    connection=${vcu_connection}
    Wait Until Keyword Succeeds    2 minutes  200ms    Check Operational State Of Cell    expected_state=enabled
    ${kpi_16b_end_point}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Log    KPI 16b End Point: ${kpi_16b_end_point}    console=${True}
    ${kpi_16b_result}=    Calculate KPI    ${kpi_16b_start_point}    ${kpi_16b_end_point}
    Log    KPI 16b Result: ${kpi_16b_result}    console=${True}
    Append To List    ${KPI_16b_results}    ${kpi_16b_result}

Check Operational State Of Cell
    [Documentation]    Description:    This keyword checks if the cell is in the expected operational state.
    ...                Input:          expected state = enabled/disabled
    [Arguments]    ${expected_state}
    ${cells_list}=    vcu_admin.Get Cells Statuses    connection=${vcu_connection}
    FOR    ${cell}    IN    @{cells_list}
        IF    "${cell['id']}" == "${CELL_ID}"
            IF    "${cell['operational_state'].lower()}" == "${expected_state}"
                  Log    Cell is ${expected_state}    console=${True}
                  Run Keyword If    "${expected_state}" == "disabled"    Set Test Variable    ${CELL_LOCKED}    ${True}
                  Run Keyword If    "${expected_state}" == "enabled"    Set Test Variable    ${CELL_LOCKED}    ${False}
                  Exit For Loop
            END
        END
    END
    Run Keyword If    "${expected_state}" == "disabled" and not ${CELL_LOCKED}    Fail    Cell is not ${expected_state}
    Run Keyword If    "${expected_state}" == "enabled" and ${CELL_LOCKED}    Fail    Cell is not ${expected_state}

Calculate KPI
    [Documentation]    Description:    This keyword calculates the KPI based on the start and end timestamps.
    ...                Input:          start_point = timestamp
    ...                                end_point = timestamp
    ...                Output:         kpi_result = time passed in seconds
    [Arguments]    ${start_point}    ${end_point}
    ${kpi_result}=    DateTime.Subtract Time From Time    ${end_point}    ${start_point}
    [Return]    ${kpi_result}

Calculate Average KPI
    [Documentation]    Description:    This keyword calculates the average KPI based on the list of results.
    ...                Input:          kpi_list = list of KPI results from every loop
    ...                Output:         Average time in seconds
    [Arguments]    @{kpi_list}
    ${total}=    Set Variable    0
    FOR    ${result}    IN    @{kpi_list}
           ${total}    Evaluate    ${total} + ${result}
    END
    ${count}=    Get Length    ${kpi_list}
    ${average_kpi}=    Evaluate    ${total} / ${count}
    [Return]    ${average_kpi}

Custom Test Teardown
    [Documentation]    Description:    Unlocks cell if test fails while cell is locked.
    Log    Custom Test Teardown    console=${True}
    Run Keyword If    ${CELL_LOCKED}    vcu_admin.Unlock Cells    cell_ids=${SELECTED_CELL}    connection=${vcu_connection}

