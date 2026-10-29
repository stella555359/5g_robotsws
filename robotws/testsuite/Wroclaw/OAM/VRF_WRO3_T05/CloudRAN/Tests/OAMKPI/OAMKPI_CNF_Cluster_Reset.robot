*** Settings ***
Documentation
    ...    This test case is used to verify KPI for iLO Cluster reset
    ...    History of changes:     22.08.2025 - Initial creation
    ...    Author:         jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI CNF Cluster Reset
    [Documentation]
    ...    This test case verifies KPI for iLO Cluster reset
    ...    It performs the following steps:
    ...    1. Connects to iLO and performs Force Restart
    ...    2. Downloads iLO event logs to determine server power restore timestamp
    ...    3. Checks vDU and vCU states until on-air
    ...    4. Downloads vCU syslog to check when cells came up
    ...    5. Calculates the KPI as the time difference between last cell up and power restore
    ...    6. Compares individual KPI values with target and 5% threshold
    ...    7. Generates results file with KPI values, average, and targets
    ...    Arguments:
    ...        - ${test_iterations}:      Number of iterations to perform the reset
    ...        - ${KPI_target}:           Target KPI value
    ...        - ${KPI_avg_benchmark}:    Average KPI from previous release
    ...    Returns:
    ...        - Results File

    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...            ${KPI_target}
    ...            ${KPI_avg_benchmark}


    ${mrbts_id}    ${nrbts_id}    Get MRBTS and NRBTS IDs    vDU
    ${iLO_ip_address}  ${iLO_user_name}  ${iLO_password}  Get ILO Data    ${mrbts_id}
    @{KPI_Cluster_reset_results}=    Create List

    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}    Evaluate    ${i} + 1

        Log To Console    \n--- Execution loop: ${index} ---\n
        ${files_from_iteration}=    Set Variable  ${SUITE_LOGS_DIR_PATH}/files_from_${index}_iteration
        OperatingSystem.Create Directory    ${files_from_iteration}

        ${ilo_logs}    ilo_keywords.Reset Servers Parallel    ${iLO_ip_address}    ${iLO_user_name}    ${iLO_password}
        ${iLO_Force_Power_Cycle_time}=    DateTime.Get Current Date    time_zone=UTC
        ${all_timestamps}=    Create List
            FOR    ${ip}    IN    @{ilo_logs.keys()}
            ${server_dict}=    Get From Dictionary    ${ilo_logs}    ${ip}
            ${members}=        Get From Dictionary    ${server_dict}    Members
                FOR    ${item}    IN    @{members}
                ${msg}=    Get From Dictionary    ${item}    Message
                Run Keyword If    '${msg}' == 'Server power restored.'    Append To List    ${all_timestamps}    ${item['Created']}
                END
            END
       Collections.Sort List    ${all_timestamps}
       ${last_timestamp}=    Get From List    ${all_timestamps}    -1
       ${iLO_power_restore_timestamp}=    Convert Date    ${last_timestamp}    result_format=%Y-%m-%d %H:%M:%S

        Log To Console    Checking vDU and vCU state...
        Wait Until Keyword Succeeds  20m  30s    cloud_frame.Check vDU And RMOD states    ${vdu_connection}
        Wait Until Keyword Succeeds  15m  30s    cloud_frame.Check Cell States On vDU     ${vdu_connection}
        Wait Until Keyword Succeeds  15m  30s    cloud_frame.Check Cell States On vCU   ${VCU_CONNECTION}
        Wait Until Keyword Succeeds  15m  30s    cloud_frame.Check vCU state              ${vcu_connection}
        Log To Console    vDU and vCU are onair

        Log To Console    Downloading vCU syslog to check when the cells came up
        ${vCU_syslog_path_cells_up}=    syslog_download_from_vdu_vcu.Download vCU Syslog

        Log To Console    Filtering vCU Syslog Looking For cells up timestamps...
        ${cells_up_syslog_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path_cells_up}
        ...    component=cpnb
        ...    keyword=ConcreteOAMInterface.cpp, cellToDeactivateList:[[]], cellToActivateList:[[{, CellStatusInd
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${iLO_Force_Power_Cycle_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True

        ${last_cell_up}=     Get Timestamp Of Event    ${cells_up_syslog_filtered}    last
        ${KPI_cluster}=    DateTime.Subtract Date From Date    ${last_cell_up}    ${iLO_power_restore_timestamp}
        Append To List    ${KPI_Cluster_reset_results}    ${KPI_cluster}

        ${KPI_check}=    Evaluate    ${KPI_cluster} <= ${KPI_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_check}
        ...                                    msg=KPI value ${KPI_cluster} exceeds ${KPI_target}

        IF    ${KPI_check}==False
              Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
              Collect Logs      ${files_from_iteration}
        ELSE
              Log to console    KPI result: ${KPI_cluster}s in ${index} iteration
              OperatingSystem.Remove Directory    ${files_from_iteration}    recursive=True
        END

    Log To Console    \n--- Execution loop: ${index} ends---\n
    END

    ${KPI_avg}=    Run Keyword And Continue On Failure         Calculate Average KPI Values And Compare With Target
    ...                                                        kpi_results=${KPI_Cluster_reset_results}
    ...                                                        kpi_target=${KPI_target}

    Run Keyword And Continue On Failure    Verify KPI Benchmark    ${KPI_avg}     ${KPI_avg_benchmark}     KPI

    ${KPI_threshold}=    Evaluate    ${KPI_avg} * 1.05
    FOR    ${result}    IN    @{KPI_Cluster_reset_results}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${result} <= ${KPI_threshold}    msg=KPI value ${result} exceeds 5% threshold ${KPI_threshold}
    END

    ${results}=     Create List     KPI:    @{KPI_Cluster_reset_results}
    ${averages}=    Create List     KPI:    ${KPI_avg}s
    ${targets}=     Create List     KPI:    ${KPI_target}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}

Get ILO Data
    [Arguments]    ${SYSTEM_NAME_TO_USE}

    ${SYSTEM_NAME_TO_USE}=    Set Variable    TL${SYSTEM_NAME_TO_USE}
    ${ilo_ip_address}=        Create List
    ${i_user_name}=         Set Variable    ${ilo_user_name}
    ${ilo_password}=          Set Variable    ${ilo_user_password}

    FOR    ${system}    IN    @{systems}
        Run Keyword If    '${system["name"]}' == '${SYSTEM_NAME_TO_USE}'
        ...    Append To List    ${ilo_ip_address}    @{system['ilo_addresses']}
    END

    [Return]    ${iLO_ip_address}    ${iLO_user_name}    ${iLO_password}
