*** Settings ***
Documentation
    ...    Test executes steps 2 to 5 for a specified number of iterations.
    ...    Each iteration involves resetting vCU, retrieving logs, checking cells deactivation and activation timestamps, and performing KPI checks.
    ...    The average KPI result is calculated at the end of the test.
    ...    Author:    Jakub Kokoszka
    ...    Contact:   jakub.kokoszka@nokia.com

Resource    ../../Resources/unpacking.robot
Library     _CB012796_CA_TC07_Reset_time_WebEM_vCU.py

*** Variables ***
${KPI_1e_target}          600    #target in seconds
${KPI_1d_target}          660    #target in seconds
${KPI_UPUE_target}        120   #target in seconds
@{kpi_result_1e_list}
@{kpi_result_1d_list}
@{kpi_result_UPUE_list}
${number_of_iterations_TC07}    3
@{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}
${syslog_merged_file_name}    merged_syslog
${logs_to_delete}    ${TRUE}

*** Keywords ***
CB012796_CA_TC07_Reset_time_WebEM_vCU
    Step 1: Precondition
    FOR    ${index}    IN RANGE    ${number_of_iterations_TC07}
        ${index}    Evaluate    ${index} + 1
        Log    \n--- Execution loop: ${index} ---    console=${True}
        Step 2: Performing vCU reset
        Step 3: Generating and downloading logs from the vCU    ${index}
        Step 4: Retrieving information from the syslog about cell activation times    ${index}
        Step 5: Checking KPIs for targets 1e, 1d and UPUE    ${index}
        Log    \n--- Loop ${index}: Completed ---    console=${True}
    END
    Step 6: Checking the average KPI result from ${number_of_iterations_TC07} executions for targets 1e, 1d and UPUE

Step 1: Precondition
    [Documentation]
    ...  This step retrieving the list of NR cell identities.

    Log    \nStep 1: Precondition    console=${True}
    ${cells_info}=    Get nr cell identity
    Set Test Variable    ${cells_info}

Step 2: Performing vCU reset
    [Documentation]
    ...  This step performs a vCU reset operation and waits until vCU is online.
    ...  It first triggers the reset, verifies the reset status, and records the reset time as cells down time.

    Log    \nStep 2: Performing vCU reset   console=${True}
    Log    reset ongoing...    console=${True}
    ${out}   vcu_admin.reset cu    connection=${VCU_CONNECTION}
    Should Be Equal    ${out['status']}    ongoing
    ${reset_time_all_cells_down_time}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Set Test Variable  ${reset_time_all_cells_down_time}
    Sleep    10s
    Wait Until Keyword Succeeds    ${KPI_UPUE_target} seconds    1 second    Check UPUE Are Running
    Wait Until Keyword Succeeds    ${KPI_UPUE_target} seconds    1 second    Check UPUE Are Ready
    ${UPUE_up_time}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Set Test Variable  ${UPUE_up_time}

    ${vdu_state}=    vdu_admin.Get Vdu State Data    vdu_connection=${VDU_CONNECTION}
    Log    vDU operational state is "${vdu_state["operational_state"]}"    console=${True}

    Should Be True    '${vdu_state["operational_state"].lower()}' in ["configured", "integrated to ran", "onair"]


    Wait Until Keyword Succeeds  30m  30s  cloud_frame.Check vCU state    ${VCU_CONNECTION}
    Wait Until Keyword Succeeds  30m  30s  cloud_frame.Check Cell States On vCU   ${VCU_CONNECTION}
    Wait Until Keyword Succeeds  30m  30s  cloud_frame.Check Cell States On vDU    ${VDU_CONNECTION}
    Log    reset completed successfully, vCU and vDU are online...    console=${True}

Step 3: Generating and downloading logs from the vCU
    [Documentation]
    ...  This step retrieves logs from the vCU and downloads them to the local drive.
    ...  It connects to the vCU Kubernetes master node, fetches log service details,
    ...  extracts logs, and transfers them to the designated local directory.
    ...  Finally, it unpacks and merges the logs for further processing.
    [Arguments]    ${index}

    Log    \nStep 3: Generating and downloading logs from the vCU   console=${True}
    Run    mkdir -p ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/extracted
    ${alias_cu}=    common_vcu.Connect To vCU K8s Master Node With Tenant    0    600
    ${cmd}   set variable    kubectl get po -n ${CRAN_VCU} -l app.kubernetes.io/name=logservice -o=jsonpath='{..podIP}'
    ${output}   issh.Execute  command=${cmd}   alias=${alias_cu}
    ${ip_address}   Get Regexp Matches  ${output}  \\d+.\\d+.\\d+.\\d+
    ${logservice_cmd}    Set variable    kubectl get pod -n ${CRAN_VCU} | grep "${CRAN_VCU}-logservice" | awk '{print $1}'
    ${logservice}   issh.Execute  command=${logservice_cmd}   alias=${alias_cu}
    ${logservice}    Clean Logservice Output    ${logservice}

    ${cmd2}=    Catenate    SEPARATOR=
    ...    kubectl exec -n ${CRAN_VCU} -c ctr-${CRAN_VCU}-logprocessor${SPACE}
    ...    ${logservice} -- curl -X GET "http://${ip_address[0]}:50108/api/trc/v1/log_data" -H "Accept-Encoding: gzip" >${SPACE}
    ...    /var/home/core/syslog_all_test.zip

    issh.Execute    command=${cmd2}    alias=${alias_cu}
    ${cmd_download}=    Catenate    SEPARATOR=
    ...    sshpass -p '${SSH_K8S_PASSWORD}' rsync -avz --remove-source-files${SPACE}
    ...    core@${SSH_VCU_IP}:/var/home/core/syslog_all_test.zip${SPACE}
    ...    ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/

    Run  ${cmd_download}
    Run Keyword And Ignore Error  Disconnect Interactive Connection

    unpacking.Unpack Archive Content To Directory  ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/syslog_all_test.zip
    ...  ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/extracted
    ${files}=    OperatingSystem.List Files In Directory   ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/extracted    *.zip
    FOR    ${file}    IN    @{files}
      ${is_latest}=    Run Keyword And Ignore Error    Should Contain    ${file}    latest
      ${status1}=    Get From List    ${is_latest}    0
      ${is_err}=    Run Keyword And Ignore Error    Should Contain    ${file}    err_
      ${status2}=    Get From List    ${is_err}    0
      Run Keyword If    ('${status1}' == 'FAIL' and '${status2}' == 'FAIL') or ('${status1}' == 'PASS' and '${status2}' == 'FAIL')    Extract Zip File
      ...  ${file}    ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/extracted/syslog_to_check    ${index}
    END

    ${result}=    file_operation.Merge Text Files
    ...  ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/extracted/syslog_to_check
    ...  ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/extracted/syslog_to_check/${syslog_merged_file_name}
    ...  "ISO-8859-1"

Step 4: Retrieving information from the syslog about cell activation times
    [Documentation]
    ...  This step extracts and processes information about cell activation times from the syslog.
    ...  It searches for relevant log entries, filters them, and determines the activation timestamps.
    ...  The extracted data is sorted and stored for further use.
    [Arguments]    ${index}

    Log    \nStep 4: Retrieving information from the syslog about cell activation times   console=${True}
    ${cell_up_time_stamp}=    Create List
    FOR    ${cell}    IN    @{cells info}
        Run    mkdir -p ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}
        ${grep_1}=    Catenate    SEPARATOR=
        ...   grep -E "cp_nb" ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/extracted/syslog_to_check/${syslog_merged_file_name} >${SPACE}
        ...   ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/grep_cpnb_cellToActivateList.txt
        ${grep_2}=    Catenate    SEPARATOR=
        ...   grep -E "OAMConfigurationHandler" ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/grep_cpnb_cellToActivateList.txt >${SPACE}
        ...   ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/grep_OAMConfigurationHandler_up.txt
        ${grep_3}=    Catenate    SEPARATOR=
        ...   grep -E "cellToActivateList" ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/grep_OAMConfigurationHandler_up.txt >${SPACE}
        ...   ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/grep_cellToActivateList_up.txt
        ${grep_4}=    Catenate    SEPARATOR=
        ...   grep -E "${cell}" ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/grep_cellToActivateList_up.txt >${SPACE}
        ...   ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/grep_cpnb_cell_${cell}_up.txt
        Run    ${grep_1}
        Run    ${grep_2}
        Run    ${grep_3}
        Run    ${grep_4}
        Filter Lines From File
        ...   ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/grep_cpnb_cell_${cell}_up.txt
        ...   ${cell}
        ...   "cellToActivateList": []
        ...   up
        ...   ${index}
        ${cell_time_stamp}    Take the Last Entry
        ...   ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/filtered_grep_cpnb_cell_${cell}_up.txt
        ...   ${cell}
        ...   up
        ...   ${index}
        Append To List  ${cell_up_time_stamp}  ${cell_time_stamp}
        Should Not Be Empty    ${cell_up_time_stamp}    cells up time stamp list are empty
        Run    rm -rf ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}
    END
    Sort List    ${cell_up_time_stamp}
    Set Test Variable  ${cell_up_time_stamp}

Step 5: Checking KPIs for targets 1e, 1d and UPUE
    [Documentation]
    ...  This step calculates and verifies Key Performance Indicators (KPIs) for targets 1e, 1d an UPUE.
    ...  It determines the time taken for cell recovery after reset and compares the results against predefined KPI thresholds.
    ...  If KPI targets are exceeded, the test fails with an appropriate message.
    [Arguments]    ${index}

    Log    \nStep 5: Checking KPIs for targets 1e, 1d and UPUE   console=${True}
    ${kpi_result_1e}=    DateTime.Subtract Time From Time    ${cell_up_time_stamp}[0]     ${reset_time_all_cells_down_time}
    ${kpi_result_1d}=    DateTime.Subtract Time From Time    ${cell_up_time_stamp}[-1]    ${reset_time_all_cells_down_time}
    ${kpi_result_UPUE}=    DateTime.Subtract Time From Time    ${UPUE_up_time}     ${reset_time_all_cells_down_time}

    Append To List  ${kpi_result_1e_list}  ${kpi_result_1e}
    Append To List  ${kpi_result_1d_list}  ${kpi_result_1d}
    Append To List  ${kpi_result_UPUE_list}  ${kpi_result_UPUE}

    ${minutes_1e}    ${seconds_1e}    Convert Seconds To Minutes And Seconds    ${kpi_result_1e}
    ${minutes_1d}    ${seconds_1d}    Convert Seconds To Minutes And Seconds    ${kpi_result_1d}
    ${minutes_UPUE}    ${seconds_UPUE}    Convert Seconds To Minutes And Seconds    ${kpi_result_UPUE}

    IF    ${kpi_result_1e} <= ${KPI_1e_target}
          Log    KPI 1e: ${minutes_1e} minutes ${seconds_1e} seconds. KPI target is met.    console=${True}
    ELSE
          Run Keyword And Continue On Failure    Fail    KPI 1e is exceeding the target. Result: ${minutes_1e} minutes ${seconds_1e} seconds.
          Run Keyword And Continue On Failure    vcu_admin.Get Local Snapshot
          ...    directory=${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/    connection=${VCU_CONNECTION}    compressed=${True}
          Run Keyword And Continue On Failure    vdu_admin.Get Local Snapshot
          ...    directory=${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/    vdu_connection=${VDU_CONNECTION}   compressed_or_not=${True}
          IF    ${FHGW_OBJ}
              Collect FHGW Snapshot    local_dir=${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/
          END
    Set Test Variable    ${logs_to_delete}    ${FALSE}
    END

    IF    ${kpi_result_1d} <= ${KPI_1d_target}
          Log    KPI 1d: ${minutes_1d} minutes ${seconds_1d} seconds. KPI target is met.    console=${True}
    ELSE
          Run Keyword And Continue On Failure    Fail    KPI 1d is exceeding the target. Result: ${minutes_1d} minutes ${seconds_1d} seconds.
          Run Keyword And Continue On Failure    vcu_admin.Get Local Snapshot
          ...    directory=${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/    connection=${VCU_CONNECTION}    compressed=${True}
          Run Keyword And Continue On Failure    vdu_admin.Get Local Snapshot
          ...    directory=${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/    vdu_connection=${VDU_CONNECTION}   compressed_or_not=${True}
          IF    ${FHGW_OBJ}
              Collect FHGW Snapshot    local_dir=${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/
          END
    Set Test Variable    ${logs_to_delete}    ${FALSE}
    END

    IF    ${kpi_result_UPUE} <= ${KPI_UPUE_target}
          Log    KPI UPUE: ${minutes_UPUE} minutes ${seconds_UPUE} seconds. KPI target is met.    console=${True}

    ELSE
          Run Keyword And Continue On Failure    Fail    KPI UPUE is exceeding the target. Result: ${minutes_UPUE} minutes ${seconds_UPUE} seconds.
          Run Keyword And Continue On Failure    vcu_admin.Get Local Snapshot
          ...    directory=${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/    connection=${VCU_CONNECTION}    compressed=${True}
          Run Keyword And Continue On Failure    vdu_admin.Get Local Snapshot
          ...    directory=${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/    vdu_connection=${VDU_CONNECTION}   compressed_or_not=${True}
          IF    ${FHGW_OBJ}
              Collect FHGW Snapshot    local_dir=${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/
          END
    Set Test Variable    ${logs_to_delete}    ${FALSE}
    END

    Run Keyword If    ${logs_to_delete}    Run Keyword
    ...    OperatingSystem.Remove Directory    ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}    recursive=${True}
    Set Test Variable    ${logs_to_delete}    ${TRUE}

Step 6: Checking the average KPI result from ${number_of_iterations_TC07} executions for targets 1e, 1d and UPUE
    [Documentation]
    ...  This step calculates the average Key Performance Indicator (KPI) results for targets 1e, 1d and UPUE
    ...  based on ${number_of_iterations_TC07} test executions.
    ...  It then compares the average values against predefined KPI thresholds.
    ...  If the average KPI exceeds the target, the test fails.

    Log    \nStep 6: Checking the average KPI result from ${number_of_iterations_TC07} executions for targets 1e, 1d and UPUE   console=${True}
    ${average_1e_result}=    Calculate Average    @{kpi_result_1e_list}
    ${average_1d_result}=    Calculate Average    @{kpi_result_1d_list}
    ${average_UPUE_result}=    Calculate Average    @{kpi_result_UPUE_list}

    ${minutes_1e}    ${seconds_1e}    Convert Seconds To Minutes And Seconds    ${average_1e_result}
    ${minutes_1d}    ${seconds_1d}    Convert Seconds To Minutes And Seconds    ${average_1d_result}
    ${minutes_UPUE}    ${seconds_UPUE}    Convert Seconds To Minutes And Seconds    ${average_UPUE_result}

    IF    ${average_1e_result} <= ${KPI_1e_target}
          Log    The average KPI 1e score from ${number_of_iterations_TC07} executions: ${minutes_1e} minutes ${seconds_1e} seconds.  console=${True}
          Log    Average KPI target is met.    console=${True}
    ELSE
          Run Keyword And Continue On Failure
          ...    Fail
          ...    The average KPI 1e, ${number_of_iterations_TC07} iterations are exceeding the target. Result: ${minutes_1e}min ${seconds_1e}sec.
    END

    IF    ${average_1d_result} <= ${KPI_1d_target}
          Log    The average KPI 1d score from ${number_of_iterations_TC07} executions: ${minutes_1d} minutes ${seconds_1d} seconds.   console=${True}
          Log    Average KPI target is met.    console=${True}
    ELSE
          Run Keyword And Continue On Failure
          ...    Fail
          ...    The average KPI 1d, ${number_of_iterations_TC07} iterations are exceeding the target. Result: ${minutes_1d}min ${seconds_1d}sec.
    END

    IF    ${average_UPUE_result} <= ${KPI_UPUE_target}
          Log    The average KPI UPUE score from ${number_of_iterations_TC07} executions: ${minutes_UPUE} min ${seconds_UPUE} sec.   console=${True}
          Log    Average KPI target is met.    console=${True}
    ELSE
          Run Keyword And Continue On Failure
          ...   Fail
          ...   The average KPI UPUE, ${number_of_iterations_TC07} iterations are exceeding the target. Result: ${minutes_UPUE}min ${seconds_UPUE}sec.
    END

    ${results}=     Create List     KPI 1e:    @{kpi_result_1e_list}   KPI 1d:    @{kpi_result_1d_list}   KPI UPUE:    @{kpi_result_UPUE_list}
    ${averages}=    Create List     KPI 1e: ${average_1e_result}s      KPI 1d: ${average_1d_result}s    KPI UPUE:    ${average_UPUE_result}s
    ${targets}=     Create List     KPI 1e: ${KPI_1e_target}s       KPI 1d: ${KPI_1d_target}s    KPI UPUE:    ${KPI_UPUE_target}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}



Extract Zip File
    [Documentation]
    ...  This keyword extracts the contents of a ZIP archive to a specified destination directory.
    ...  It is used for processing log files retrieved from the vCU system.
    ...
    ...  Arguments:
    ...  - ${zip_file}: Name of the ZIP file to be extracted.
    ...  - ${dest_dir}: Destination directory where the extracted files will be stored.
    ...  - ${index}: Test iteration index, used to organize logs in separate directories.
    ...
    ...  Example Usage:
    ...  Extract Zip File    syslog_all_test.zip    ${SUITE_LOGS_DIR_PATH}/processed_logs
    [Arguments]    ${zip_file}    ${dest_dir}    ${index}

    Log    Extracting ${zip_file} to ${dest_dir}
    unpacking.Unpack Archive Content To Directory    ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/extracted/${zip_file}    ${dest_dir}

Calculate Average
    [Documentation]
    ...  This keyword calculates the average value from a list of KPI results.
    ...  It is used to compute the mean time for KPI measurements across multiple test iterations.
    ...
    ...  Arguments:
    ...  - @{kpi_list}: A list of numerical KPI values (e.g., time measurements in seconds).
    ...
    ...  Returns:
    ...  - ${average_kpi}: The calculated average value.
    ...
    ...  Example Usage:
    ...  ${average}=    Calculate Average    @{kpi_result_1e_list}
    ...  Log    The average KPI result is ${average}
    [Arguments]    @{kpi_list}

    ${total}=    Set Variable    0
    FOR    ${result}    IN    @{kpi_list}
           ${total}=    Evaluate    ${total} + ${result}
    END
    ${count}=    Get Length    ${kpi_list}
    ${average_kpi}=    Evaluate    ${total} / ${count}
    [Return]    ${average_kpi}

Filter Lines From File
    [Documentation]
    ...  This keyword filters specific lines from a text file based on a given filter string.
    ...  It removes lines containing the filter string and saves the remaining content to a new file.
    ...  This is useful for extracting relevant log data for further analysis.
    ...
    ...  Arguments:
    ...  - ${input_file}: The path to the input file to be filtered.
    ...  - ${cell}: Identifier for the cell whose data is being filtered.
    ...  - ${filtr}: The string used to filter out lines from the file.
    ...  - ${down_or_up}: A flag indicating whether the lines to be filtered are for "down" or "up" events.
    ...  - ${index}: Test iteration index, used for organizing the output files.
    ...
    ...  Example Usage:
    ...  Filter Lines From File    ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_1/extracted/syslog_to_check    cell123    "OAMConfigurationHandler"    up    1
    [Arguments]    ${input_file}    ${cell}    ${filtr}    ${down_or_up}    ${index}

    ${content}=    OperatingSystem.Get File    ${input_file}
    ${lines}=    Split String    ${content}    ${\n}
    ${filtered_lines}=    Evaluate    [line for line in ${lines} if '${filtr}' not in line]    modules=builtins
    ${filtered_content}=    Evaluate    '\\n'.join(${filtered_lines})    modules=builtins
    Create File    ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/filtered_grep_cpnb_cell_${cell}_${down_or_up}.txt    ${filtered_content}

Take the Last Entry
    [Documentation]
    ...  This keyword retrieves the last non-empty line from a given text file.
    ...  It is used to extract the most recent log entry for a specific cell and event type (up/down).
    ...  The line is saved to a new file, and the timestamp is extracted for further analysis.
    ...
    ...  Arguments:
    ...  - ${input_file}: The path to the input file from which the last entry will be extracted.
    ...  - ${cell}: Identifier for the cell whose log is being processed.
    ...  - ${down_or_up}: A flag indicating whether the line corresponds to "down" or "up" event.
    ...  - ${index}: Test iteration index, used to organize the output files.
    ...
    ...  Returns:
    ...  - ${cell_time_stamp}: The timestamp extracted from the last non-empty log line.
    ...
    ...  Example Usage:
    ...  ${time_stamp}=    Take the Last Entry    ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_1/extracted/syslog_to_check    cell123    up    1
    ...  Log    The timestamp of the last entry is ${time_stamp}
    [Arguments]    ${input_file}    ${cell}    ${down_or_up}    ${index}

    ${content}=    OperatingSystem.Get File    ${input_file}
    ${lines}=      Split String    ${content}    ${\n}
    ${non_empty_lines}=    Evaluate    [line for line in ${lines} if line.strip()]
    ${last_line}=  Get From List    ${non_empty_lines}    -1
    Create File    ${SUITE_LOGS_DIR_PATH}/vCU_syslog_ex_${index}/cell_${cell}/last_record_${cell}_${down_or_up}.txt    ${last_line}
    ${cell_time_stamp}    Fetch Timestamp    ${last_line}
    [Return]       ${cell_time_stamp}

Fetch Timestamp
    [Documentation]
    ...  This keyword extracts a timestamp from a log line in the ISO 8601 format.
    ...  The timestamp should be in the form of "YYYY-MM-DDTHH:MM:SS.sssZ", and the keyword removes the trailing 'Z'.
    ...  If no valid timestamp is found, the keyword fails.
    ...
    ...  Arguments:
    ...  - ${line}: The log line from which the timestamp will be extracted.
    ...
    ...  Returns:
    ...  - ${formatted_time}: The extracted timestamp, formatted as "HH:MM:SS.sss".
    ...
    ...  Example Usage:
    ...  ${timestamp}=    Fetch Timestamp    2025-02-28T14:30:45.123Z
    ...  Log    The extracted timestamp is ${timestamp}
    [Arguments]    ${line}

    ${matches}=    Get Regexp Matches    ${line}    \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d+Z
    Run Keyword If    ${matches}    Log    Found timestamps: ${matches}    ELSE    Fail    No timestamp with 'Z' found in line: ${line}
    ${timestamp_with_z}=    Get From List    ${matches}    0
    ${raw_time}=      Evaluate    '${timestamp_with_z}'.split("T")[1]
    ${formatted_time}=    Replace String    ${raw_time}    Z    ${EMPTY}
    [Return]         ${formatted_time}

Get nr cell identity
    [Documentation]
    ...  This keyword retrieves a list of NR cell identities from the system.
    ...  It queries the status of the cells, extracts the "nr_cell_identity" from the response, and returns it as a list.
    ...
    ...  Arguments:
    ...  - None
    ...
    ...  Output:
    ...  - A list of NR cell identities extracted from the cell statuses.
    ...
    ...  Example Usage:
    ...  ${nr_cell_identity}=    Get nr cell identity
    ...  Log    Retrieved NR cell identities: ${nr_cell_identity}

    ${nr_cell_identity}=    Create List
    ${cells_info}=    vcu_admin.get_cells_statuses    connection=${VCU_CONNECTION}
    FOR    ${cell_info}    IN    @{cells_info}
          Append To List    ${nr_cell_identity}    ${cell_info["nr_cell_identity"]}
    END
   [Return]    ${nr_cell_identity}

Clean Logservice Output
        [Documentation]
    ...  Description: This keyword processes the input text and filters out the lines that contain the keyword "logservice".
    ...  It returns the first line that contains the word "logservice", or fails if no such line is found.
    ...
    ...  Arguments:
    ...  - ${text}: The raw input text that needs to be filtered.
    ...
    ...  Output:
    ...  - The first line from the input text that contains the word "logservice".
    ...
    ...  Example Usage:
    ...  ${logservice_line}=    Clean Logservice Output    ${log_output_text}
    ...  Log    The filtered logservice line: ${logservice_line}
    [Arguments]    ${text}

    ${lines} =    String.Split To Lines    ${text}
    ${filtered_lines} =    Evaluate    [line for line in ${lines} if "logservice" in line]
    ${result} =    Set Variable    ${filtered_lines}[0]
    [Return]    ${result}

Check UPUE Are Running
        [Documentation]
    ...  This keyword verifies whether UPUE pods are in a running state within the specified Kubernetes namespace.
    ...  It retrieves the pod status using a kubectl command and ensures that all instances are in the "Running" state.
    ...
    ...  Arguments:
    ...  - None
    ...
    ...  Output:
    ...  - None; the keyword passes if all UPUE pods are running and fails otherwise.
    ...
    ...  Example Usage:
    ...  Check UPUE Are Running

    ${alias_cu}=    common_vcu.Connect To vCU K8s Master Node With Tenant    0    600
    ${cmd}   set variable    kubectl get pod -n ${CRAN_VCU} | grep upue | awk '{print $3}'
    ${output}=   issh.Execute  command=${cmd}   alias=${alias_cu}
    ${UPUE_status}    Remove Ansi Escape Codes    ${output}
    ${lines}=    Split To Lines    ${UPUE_status}
    Should Not Be Empty    ${lines}
    ${non_empty_UPUE_lines}=    Create List
    FOR    ${line}    IN    @{lines}
        Run Keyword If    '${line}' != '' and '@' not in '${line}'    Append To List    ${non_empty_UPUE_lines}    ${line}
    END
    Should Not Be Empty    ${non_empty_UPUE_lines}
    log to console    ${non_empty_UPUE_lines}
    FOR    ${line}    IN  @{non_empty_UPUE_lines}
        Should Be Equal    ${line}    Running
    END
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection

Check UPUE Are Ready
        [Documentation]
    ...  This keyword verifies whether UPUE pods are in a ready state within the specified Kubernetes namespace.
    ...  It retrieves the readiness status using a kubectl command and ensures that all instances are fully ready.
    ...
    ...  Arguments:
    ...  - None
    ...
    ...  Output:
    ...  - None; the keyword passes if all UPUE pods are ready and fails otherwise.
    ...
    ...  Example Usage:
    ...  Check UPUE Are Ready

    ${alias_cu}=    common_vcu.Connect To vCU K8s Master Node With Tenant    0    600
    ${cmd}   set variable    kubectl get pod -n ${CRAN_VCU} | grep upue | awk '{print $2}'
    ${output}=   issh.Execute  command=${cmd}   alias=${alias_cu}
    ${UPUE_ready}    Remove Ansi Escape Codes    ${output}
    ${lines}=    Split To Lines    ${UPUE_ready}
    Should Not Be Empty    ${lines}
    ${non_empty_UPUE_lines}=    Create List
    FOR    ${line}    IN    @{lines}
        Run Keyword If    '${line}' != '' and '@' not in '${line}'    Append To List    ${non_empty_UPUE_lines}    ${line}
    END

    Should Not Be Empty    ${non_empty_UPUE_lines}
    log to console    ${non_empty_UPUE_lines}
    FOR    ${item}    IN    @{non_empty_UPUE_lines}
        ${parts}=    Split String    ${item}    /
        ${first}=    Convert To Integer    ${parts}[0]
        ${second}=    Convert To Integer    ${parts}[1]
        Should Be Equal As Numbers    ${first}    ${second}
    END
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection

Convert Seconds To Minutes And Seconds
        [Documentation]
    ...  This keyword converts a given number of seconds into minutes and seconds.
    ...
    ...  Arguments:
    ...  - ${total_seconds}: The total number of seconds to be converted.
    ...
    ...  Output:
    ...  - Two values: minutes and remaining seconds.
    ...
    ...  Example Usage:
    ...  ${minutes}    ${seconds}=    Convert Seconds To Minutes And Seconds    125
    ...  Log    Time: ${minutes} minutes and ${seconds} seconds
    [Arguments]    ${total_seconds}

    ${minutes}    Evaluate    int(${total_seconds}) // 60
    ${seconds}    Evaluate    int(${total_seconds}) % 60
    [Return]    ${minutes}    ${seconds}

Remove Ansi Escape Codes
        [Documentation]
    ...  This keyword removes ANSI escape codes from a given output string.
    ...
    ...  Arguments:
    ...  - ${output}: The string potentially containing ANSI escape codes.
    ...
    ...  Output:
    ...  - The cleaned string without ANSI escape codes.
    ...
    ...  Example Usage:
    ...  ${clean_output}=    Remove Ansi Escape Codes    ${log_output}
    ...  Log    Cleaned output: ${clean_output}
    [Arguments]    ${output}

    ${no_ansi}=    Replace String Using Regexp    ${output}    \x1B\[[0-9;?]*[a-zA-Z]    ${EMPTY}
    [Return]    ${no_ansi}
