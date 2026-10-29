*** Settings ***
Documentation
    ...    This test case is used to verify the KPI 17a (cell block time) and
    ...    KPI 17b (cell unblock time) for vDU.
    ...    History of changes:     17.10.2024 - Initial creation
    ...    29.11.2024 - Changes after review
    ...    21.03.2025 - Watchdog implementation for alarms handling
    ...    28.03.2025 - Added check of cell blockingState when blocking/unblocking cell, instead of only
    ...                 checking operationalState.
    ...    16.04.2025 - Added KW to delete snapshot trigger for fault 49 if it's configured.
    ...    Author:         damian.kotula@nokia.com

Library    random
Resource   ../../Resources/verdicts.robot

*** Variables ***
${CELL_BLOCKED}            ${FALSE}   #flag to track blocking status, used in teardown if needed
${TC19_N}                  10    #number of block/unblock loops
${KPI_17a_target}          20    #base target in seconds
${KPI_17b_target}          20    #base target in seconds
@{KPI_17a_results}         #list to store KPI 17a results
@{KPI_17b_results}         #list to store KPI 17b results
@{Chille_Familly_RUs}      AEHC  AEHB
@{Megatron_Familly_RUs}    AQQE  AQQK  AQQN  AQQL  AQQQA  AQQJ  AQQS
@{Galvatron_Familly_RUs}   AQQC  AQQY  AQQQ


*** Keywords ***
CB011085_C_TC19_Cell_block_unblock_WebEM_vDU
    Step 0: Preconditions
    Step 1: Perform ${TC19_N} Block/Unblock Loops
    Step 2: Verify Results

Step 0: Preconditions
    [Documentation]    Description:    In this step a cell for test is randomly picked form the cell list
    ...                                and the RMOD name on which it's deployed is retrieved

    Log    \nStep 0: Preconditions    console=${True}

    #Temporary solution for watchdog, before it will be implemented inside all TCs
    Start Watchdog    hw_type=vCU    log_dir=${TEST_RESULTS_DIR}
    Start Watchdog    hw_type=vDU    log_dir=${TEST_RESULTS_DIR}

    ${cell_ids}=    Get Cells ID List
    ${cell_id}=    Pick Random Cell ID    ${cell_ids}
    Set Test Variable    ${CELL_ID}    ${cell_id}
    ${rmod_name}=    Get RMOD Name By Cell ID    ${CELL_ID}
    Add Time To Target For Exception RMODs    ${rmod_name}
    Log    Cell with cell_id ${CELL_ID} from RMOD ${RMOD_NAME} will be used in test.    console=${TRUE}
    Remove Snapshot Trigger For Fault 49 If Its Configured

Step 1: Perform ${TC19_N} Block/Unblock Loops
    [Documentation]    Description:    In this step the cell is blocked and unblocked ${TC19_N} times.
        ...                            The average of KPI 17a and 17b is calculated.

    Log    \nStep 1: Perform ${TC19_N} Block/Unblock Loops    console=${True}
    Repeat Keyword  ${TC19_N} times  Block And Unblock Cell
    ${average_KPI_17a}=    Calculate Average KPI    @{KPI_17a_results}
    ${average_KPI_17b}=    Calculate Average KPI    @{KPI_17b_results}
    ${average_KPI_17a}=    Convert To Number    ${average_KPI_17a}    precision=2
    ${average_KPI_17b}=    Convert To Number    ${average_KPI_17b}    precision=2
    Set Test Variable    ${AVERAGE_KPI_17A}    ${average_KPI_17a}
    Set Test Variable    ${AVERAGE_KPI_17B}    ${average_KPI_17b}
    ${results}=     Create List     KPI 17a:    @{KPI_17a_results}    KPI 17b:    @{KPI_17b_results}
    ${averages}=    Create List     KPI 17a: ${average_KPI_17a}s      KPI 17b: ${average_KPI_17b}s
    ${targets}=     Create List     KPI 17a: ${KPI_17a_target}s       KPI 17b: ${KPI_17b_target}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}

Step 2: Verify Results
    [Documentation]    Description:    In this step the average KPI 17a and 17b are compared with the target values.
    ...                                The target values are adjusted based on the exceptions for RMOD families.

    IF    ${average_KPI_17a} <= ${kpi_17a_target}
          Log    Average KPI 17a: ${average_KPI_17a}. KPI target is met.    console=${True}
    ELSE
          verdicts.Set Test Failed    KPI 17a is exceeding the target. Average result: ${average_KPI_17a}.
    END
    IF    ${average_KPI_17b} <= ${kpi_17b_target}
          Log    Average KPI 17b: ${average_KPI_17b}. KPI target is met.    console=${True}
    ELSE
          verdicts.Set Test Failed    KPI 17b is exceeding the target. Average result: ${average_KPI_17b}.
    END
    FOR    ${result}    IN    @{KPI_17a_results}
        IF    ${result} >= ${KPI_17a_target}
              verdicts.Set Test Failed    At least one result of kpi 17a is exceeding the target.
        END
    END
    FOR    ${result}    IN    @{KPI_17b_results}
        IF    ${result} >= ${KPI_17b_target}
              verdicts.Set Test Failed    At least one result of kpi 17b is exceeding the target.
        END
    END

    #Temporary solution for watchdog, before it will be implemented inside all TCs
    Check if Disallowed Alarm was Detected during Watchdog    hw_type=vCU
    Check if Disallowed Alarm was Detected during Watchdog    hw_type=vDU
    Stop Watchdog    hw_type=vCU
    Stop Watchdog    hw_type=vDU

Get Cells ID List
    [Documentation]    Description:    This keyword retrieves the list of cell IDs from the vDU.
    ...                Output:         List of cell IDs
    ${cells_id_list}=    Create List
    ${cells info}=    vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    FOR    ${cell_info}    IN    @{cells_info}
          Append To List    ${cells_id_list}    ${cell_info["id"]}
    END
   [Return]    ${cells_id_list}

Pick Random Cell ID
    [Documentation]    Description:    This keyword picks a random cell ID from the list of cell IDs.
    ...                Input:          List of cell IDs
    ...                Output:         Random cell ID
    [Arguments]    ${cell_id_list}
    ${picked_cell_id}=    Evaluate    random.choice(${cell_id_list})    modules=random
    Log    Random Cell ID: ${picked_cell_id}
    [Return]    ${picked_cell_id}

Get Rmod Name By Cell ID
    [Documentation]    Description:    This keyword retrieves the RMOD name on which the cell is deployed.
    ...                Input:          Cell ID
    ...                Output:         RMOD product name
    [Arguments]    ${cell_id}
    ${rmod_list}=    vdu_admin.Get Rmods Status    vdu_connection=${vdu_connection}
    FOR    ${rmod}    IN    @{rmod_list}
           ${rmod_cell_ids}=    Get From Dictionary    ${rmod}    cell_ids
           Run Keyword If    '${cell_id}' in ${rmod_cell_ids}    Return From Keyword    ${rmod['product_name']}
    END

Add Time To Target For Exception RMODs
    [Documentation]    Description:    This keyword adds time to the target values for the RMOD families that have exceptions.
    ...                Input:          RMOD model name
    [Arguments]    ${rmod}
    IF    '${rmod}' in @{Chille_Familly_RUs}
           Set Test Variable    ${kpi_17a_target}    ${${kpi_17a_target}+30}
           Set Test Variable    ${kpi_17b_target}    ${${kpi_17b_target}+30}
    END
    IF    '${rmod}' in @{Megatron_Familly_RUs} or '${rmod}' in @{Galvatron_Familly_RUs}
           Set Test Variable    ${kpi_17a_target}    ${${kpi_17a_target}+10}
           Set Test Variable    ${kpi_17b_target}    ${${kpi_17b_target}+10}
    END

Block And Unblock Cell
    [Documentation]    Description:    This keyword blocks and unblocks the cell, takes timestamps of start and
    ...                                end of the blocking and unblocking process calculates the time passed and
    ...                                adds the result to the KPI list of results.

    Log    \nBlock And Unblock Cell    console=${True}
    Add Alarm to the Allowed List    fault_id=${FAULT_49}[fault_id]    fault_name=${FAULT_49}[fault_name]
    ...                              severity=${FAULT_49}[severity]    hw_type=vDU
    Add Alarm to the Allowed List    fault_id=${FAULT_7104}[fault_id]    fault_name=${FAULT_7104}[fault_name]
    ...                              severity=${FAULT_7104}[severity]    hw_type=vCU
    ${kpi_17a_start_point}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Log    KPI 17a Start Point: ${kpi_17a_start_point}    console=${True}
    vdu_admin.Block Cell    cell_id=${CELL_ID}    vdu_connection=${vdu_connection}
    Wait Until Keyword Succeeds    2 minutes    20ms    Check Operational State Of Cell    disabled
    ${kpi_17a_end_point}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Wait Until Alarm Appears    fault_id=${FAULT_49}[fault_id]    fault_name=${FAULT_49}[fault_name]
    ...                         severity=${FAULT_49}[severity]    timeout=60    hw_type=vDU
    Log    KPI 17a End Point: ${kpi_17a_end_point}    console=${True}
    ${kpi_17a_result}=    Calculate KPI    ${kpi_17a_start_point}    ${kpi_17a_end_point}
    Log    KPI 17a Result: ${kpi_17a_result}    console=${True}
    Append To List    ${KPI_17a_results}    ${kpi_17a_result}
    ${kpi_17b_start_point}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Log    KPI 17b Start Point: ${kpi_17b_start_point}    console=${True}
    vdu_admin.Unblock Cell    cell_id=${CELL_ID}    vdu_connection=${vdu_connection}
    Wait Until Keyword Succeeds    2 minutes    20ms    Check Operational State Of Cell    enabled
    ${kpi_17b_end_point}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Log    KPI 17b End Point: ${kpi_17b_end_point}    console=${True}
    Wait Until Alarm Disappears    fault_id=${FAULT_49}[fault_id]    fault_name=${FAULT_49}[fault_name]
    ...                            severity=${FAULT_49}[severity]    timeout=60    hw_type=vDU
    Remove Alarm from Allowed List    fault_id=${FAULT_49}[fault_id]    fault_name=${FAULT_49}[fault_name]
    ...                               severity=${FAULT_49}[severity]    hw_type=vDU
    Remove Alarm from Allowed List    fault_id=${FAULT_7104}[fault_id]    fault_name=${FAULT_7104}[fault_name]
    ...                               severity=${FAULT_7104}[severity]    hw_type=vCU
    ${kpi_17b_result}=    Calculate KPI    ${kpi_17b_start_point}    ${kpi_17b_end_point}
    Log    KPI 17b Result: ${kpi_17b_result}    console=${True}
    Append To List    ${KPI_17b_results}    ${kpi_17b_result}

Check Operational State Of Cell
    [Documentation]    Description:    This keyword checks if the cell is in the expected operational state
    ...                                and blocking state corresponding to it.
    ...                Input:          expected state = enabled/disabled
    [Arguments]    ${expected_state}
    IF    "${expected_state}" == "enabled"
            ${expected_blocking_st}=    Set Variable    unblocked
    ELSE IF    "${expected_state}" == "disabled"
            ${expected_blocking_st}=    Set Variable    blocked
    END
    ${cells_list}=    vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    FOR    ${cell}    IN    @{cells_list}
        IF    "${cell['id']}" == "${CELL_ID}"
            IF    "${cell['operational_state'].lower()}" == "${expected_state}" and "${cell['blocking_state'].lower()}" == "${expected_blocking_st}"
                  Log    Cell is ${expected_state}    console=${True}
                  Run Keyword If    "${expected_state}" == "disabled"    Set Test Variable    ${CELL_BLOCKED}    ${True}
                  Run Keyword If    "${expected_state}" == "enabled"    Set Test Variable    ${CELL_BLOCKED}    ${False}
                  Exit For Loop
            END
        END
    END
    Run Keyword If    "${expected_state}" == "disabled" and not ${CELL_BLOCKED}    Fail    Cell is not ${expected_state}
    Run Keyword If    "${expected_state}" == "enabled" and ${CELL_BLOCKED}    Fail    Cell is not ${expected_state}

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
           ${total}=    Evaluate    ${total} + ${result}
    END
    ${count}=    Get Length    ${kpi_list}
    ${average_kpi}=    Evaluate    ${total} / ${count}
    [Return]    ${average_kpi}

Remove Snapshot Trigger For Fault 49 If Its Configured
    [Documentation]    Description:    This keyword creates a list with fault snapshot triggers configured on vDU,
    ...                                checks if trigger for fault 49 is configured and removes it.
    ${trblcadm_dn} =    Set Variable    MRBTS-${MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
    Set Test Variable    ${TRBLCADM_DN}    ${trblcadm_dn}
    ${fault_numbers} =    Create List
    FOR    ${index}    IN RANGE    43    #43 is max amount of configured triggers
        ${search_result} =    Run Keyword And Ignore Error    vdu_admin.Search Parameter Of Current Plan
        ...    mo_dn=${TRBLCADM_DN}    para_name=faultSnapshotTriggers/${index}/faultNumber
        ...    vdu_connection=${vdu_connection}
        IF    '${search_result}[0]' != 'FAIL'
            IF    ${search_result}[1] != None
                ${fault_number} =    vdu_admin.Search Parameter Of Current Plan
                ...    mo_dn=${TRBLCADM_DN}    para_name=faultSnapshotTriggers/${index}/faultNumber
                ...    vdu_connection=${vdu_connection}
                Append To List    ${fault_numbers}    ${fault_number}
            END
        ELSE
            Set Test Variable   ${AVAILABLE_INDEX}    ${index}
            Exit For Loop
        END
    END

    ${fault_49_configured} =    Evaluate    '49' in ${fault_numbers}
    IF    ${fault_49_configured}
        Log    Trigger for fault 49 will be removed .    console=${True}
        Delete Snapshot Trigger For Fault 49
    END

Delete Snapshot Trigger For Fault 49
    &{complex_param_dict} =    Create Dictionary    faultNumber=49
    @{complex_param_list} =    Create List          ${complex_param_dict}
    &{param_dict} =            Create Dictionary    parameterName=faultSnapshotTriggers
    ...                                             value=@{complex_param_list}
    ...                                             operation=delete
    @{param_list} =            Create List          ${param_dict}
    &{change_dict} =           Create Dictionary    distName=${TRBLCADM_DN}
    ...                                             operation=update
    ...                                             parameters=@{param_list}
    @{delta} =                 Create List          ${change_dict}
    ${delta_json} =            Evaluate             json.dumps(${delta})    json
    vdu_admin.Perform Delta Recommissioning    delta_file=${delta_json}    vdu_connection=${vdu_connection}

Custom Test Teardown
    [Documentation]    Description:    Unblocks cell if test fails while cell is blocked.
    Log    Custom Test Teardown    console=${TRUE}
    Run Keyword If    ${CELL_BLOCKED}    vdu_admin.Unblock Cell    cell_id=${CELL_ID}    vdu_connection=${vdu_connection}
