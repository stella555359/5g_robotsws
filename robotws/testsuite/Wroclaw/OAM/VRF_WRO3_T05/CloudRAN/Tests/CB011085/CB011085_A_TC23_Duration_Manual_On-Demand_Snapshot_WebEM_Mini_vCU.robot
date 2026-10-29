*** Settings ***
Documentation
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is used to verify the troubleshooting data collection duration KPI for a manually triggered on-demand snapshot - mini vCU.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 17.12.2024 - Initial creation


*** Variables ***
${N_snapshots}          10   # number snapshot collections
${KPI_target}           600  # base KPI target in seconds
@{snapshot_durations}        # list to store local snapshot operation durations


*** Keywords ***
CB011085_A_TC23_Duration_Manual_On-Demand_Snapshot_WebEM_Mini_vCU
    Step 0: Preconditions
    Step 1: Collect ${N_snapshots} vCU Local Snapshot(s)
    Step 2: Check Average Snapshot Duration


Step 0: Preconditions
    [Documentation]    Description:    Creates a directory to which snapshots will be downloaded to and waits 1 hour to ensure the recommended
    ...                                test precondition of 1 hour TL uptime.

    Log To Console    \nStep 0: Preconditions
    Create Directory    ${Test_Results_Dir}/test_snapshots
    Log To Console    Sleeping 60m
    Sleep    60m    # BTS should be up and running for at least 1 hour


Step 1: Collect ${N_snapshots} vCU Local Snapshot(s)
    [Documentation]    Description:    Collects a defined number of snapshots, retrieves the operation duration of each snapshot in seconds and
    ...                                appends each duration time to list. Also checks if each time is below the defined KPI target.

    Log To Console    \nStep 1: Collect ${N_snapshots} vCU Local Snapshot(s)
    FOR    ${i}    IN RANGE    ${N_snapshots}
        Log To Console    \nTriggering local snapshot ${${i}+1}/${N_snapshots}
        vcu_admin.get local snapshot    directory=${Test_Results_Dir}/test_snapshots    connection=${vcu_connection}
        ${duration}=    Get Duration Of Last Local Snapshot Operation
        Log To Console    Snapshot ${${i}+1} duration = ${duration}
        Run Keyword And Continue On Failure    Should Be True    ${duration} < ${KPI_target}
        Append To List    ${snapshot_durations}    ${duration}
    END


Step 2: Check Average Snapshot Duration
    [Documentation]    Description:    Calculates the average duration time and compares it to the KPI target.

    Log To Console    \nStep 2: Check Average Snapshot Duration
    ${average}=    Calculate Average Time From List    ${snapshot_durations}
    Log To Console    Average local snapshot duration = ${average}
    Should Be True    ${average} < ${KPI_target}


Get Duration Of Last Local Snapshot Operation
    [Documentation]    Description:    Gets the duration of the last 'trigger local snapshot' operation from WebEM Operations List.
    ...                Output:         duration = operation duration in seconds

    Sleep    10s    # Sleep to allow operation to appear in WebEM Operations History
    ${operation}=    Get Operation History    hw_type=vCU    remove_login_operations=${TRUE}    operation_name=Trigger local snapshot
    ${duration}=     Get Operation Duration    ${operation}[0]    output_format=seconds
    [Return]    ${duration}


Calculate Average Time From List
    [Documentation]    Description:    Calculates the average time from a list of times (seconds).
    ...                Input:          kpi_list = list containing times (seconds)
    ...                Output:         average  = average time from list (seconds)

    [Arguments]    ${kpi_list}
    ${total}=    Set Variable    0
    FOR    ${time}    IN    @{kpi_list}
        ${total}=    Set Variable    ${total} + ${time}
    END
    ${average}=    Evaluate    (${total}) / len(${kpi_list})
    [Return]    ${average}
