*** Settings ***
Documentation
    ...    Test executes steps 2 to 6 for a specified number of iterations.
    ...    Each iteration involves resetting vDU, retrieving logs, checking cells deactivation and activation timestamps, and performing KPI checks.
    ...    Waiting time is introduced between iterations to avoid backoff time during continuous CNF resetting.
    ...    The average KPI result is calculated at the end of the test.
    ...    Author:    Jakub Kokoszka
    ...    Contact:   jakub.kokoszka@nokia.com

Resource    ../../Resources/unpacking.robot
Library     _CB012796_CA_TC07_Reset_time_WebEM_vCU.py

*** Variables ***
${KPI_52_target_TDD}          450    #target in seconds
${KPI_52e_target_TDD}         420    #target in seconds
${KPI_52_target_FDD}          300    #target in seconds
${KPI_52e_target_FDD}         270    #target in seconds
${KPI_52_target_MIX}          750    #target in seconds
${KPI_52e_target_MIX}         720    #target in seconds
@{kpi_result_52_list}
@{kpi_result_52e_list}
${number_of_iterations_TC01_02}           3
@{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}
${syslog_merged_file_name}    merged_syslog
${logs_to_delete}    ${TRUE}


*** Keywords ***
CB012796_CB_TC01_02_Reset_time_WebEM_vDU_FDD_or_TDD

    Step 1: Precondition
    FOR    ${index}    IN RANGE   ${number_of_iterations_TC01_02}
        ${index}    Evaluate    ${index} + 1
        Log    \n--- Execution loop: ${index} ---    console=${True}
        Step 2: Performing vDU Reset    ${index}
        Step 3: Generating And Downloading Logs From The vDU    ${index}
        Step 4: Retrieving Information From The Syslog About Cells Deactivation Times    ${index}
        Step 5: Checking KPIs For Targets 52 And 52e    ${index}
        Log    \n--- Loop ${index}: Completed ---    console=${True}
    END
    Step 6: Checking The Average KPI Result From ${number_of_iterations_TC01_02} Executions For Targets 52 and 52e

Step 1: Precondition
    [Documentation]
    ...  This step retrieves the list of NR cell identities, checks the technology of each cell (FDD or TDD),
    ...  and sets the KPI target based on the technology.

    Log    \nStep 1: Precondition    console=${True}
    ${cells_info}=    Get Nr Cell Identity
    Set Test Variable  ${cells_info}
    ${cells_status}     vdu.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${cells_id}    Evaluate    [item['id'] for item in ${cells_status}]
    ${cells_technology}    Evaluate    [item['technology'] for item in ${cells_status}]
    ${fdd_or_tdd}    Check If All Cells Are FDD or TDD    ${cells_technology}
    ${count}  Get Length    ${cells_id}
    Set Test Variable  ${count}
    IF    '${fdd_or_tdd}' == 'TDD'
        Run Keyword    Set TDD KPI target
    ELSE IF    '${fdd_or_tdd}' == 'FDD'
        Run Keyword    Set FDD KPI target
    ELSE IF    '${fdd_or_tdd}' == 'MIX'
        Run Keyword    Set MIX KPI target
    ELSE
        Fail    Unsupported configuration: Fatal error.
    END

Step 2: Performing vDU Reset
    [Documentation]
    ...  This step performs the vDU reset operation and waits until both vCU and vDU are online.
    ...  The API is polled at very short intervals to record the times at which each cell is fully operational
    [Arguments]    ${index}

    Log    \nStep 2: Performing vDU Reset   console=${True}
    Log    reset ongoing...    console=${True}
    ${out}   vdu_admin.Reset vDU    vdu_connection=${vdu_connection}
    Should Be Equal    ${out['status']}    ongoing
    Log    waiting for the moment when all cells become in operational state    console=${True}
    ${time_list}=    Create List
    Set Test Variable    ${time_list}
    ${to_save_in_file}=    Create List
    Set Test Variable    ${to_save_in_file}
    ${checked_cells}=    Create List
    Set Test Variable    ${checked_cells}
    Wait Until Keyword Succeeds  20m  5s    Check vDU states    ${vdu_connection}
    Wait Until Keyword Succeeds  20m  20ms    Check All Cells Enabled for vDU    ${index}
    Wait Until Keyword Succeeds  10m  30s    cloud_frame.Check vCU state    ${vcu_connection}
    Wait Until Keyword Succeeds  10m  30s    cloud_frame.Check Cell States On vDU    ${vdu_connection}
    Log    all cells become in operational state    console=${True}
    Log    reset completed successfully, vCU and vDU are online...    console=${True}

Step 3: Generating And Downloading Logs From The vDU
    [Documentation]
    ...  This step generates and downloads logs from the vDU.
    ...  It uses the `issh.Execute` keyword to execute a curl command on the vDU to retrieve the syslog data.
    ...  The data is then downloaded to the test suite logs directory.
    [Arguments]    ${index}

    Log    \nStep 3: Generating And Downloading Logs From The vDU   console=${True}
    Run    mkdir -p ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted/syslog_to_check
    ${alias_cu}=    common_vdu.Connect To vDU K8s Master Node With Tenant
    ${cmd}   Set Variable    kubectl get po -n ${CRAN_VDU} -l app.kubernetes.io/name=logservice -o=jsonpath='{..podIP}'
    ${output}   issh.Execute  command=${cmd}   alias=${alias_cu}
    ${ip_address}   Get Regexp Matches  ${output}  \\d+.\\d+.\\d+.\\d+
    ${output_2}   issh.Execute
    ...  curl -X GET "${ip_address[0]}:50108/api/trc/v1/log_data" -H "accept: application/octet-stream" -o syslog_all_test.zip    alias=${alias_cu}
    ${cmd}=    Catenate    SEPARATOR=
    ...    sshpass -p '${SSH_K8S_PASSWORD}' rsync -avz${SPACE}
    ...    --remove-source-files core@${SSH_VDU_IP}:/var/home/core/syslog_all_test.zip${SPACE}
    ...    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}
    Run    ${cmd}
    Run Keyword And Ignore Error  Disconnect Interactive Connection
    unpacking.Unpack Archive Content To Directory  ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/syslog_all_test.zip
    ...  ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted
    ${files}=    OperatingSystem.List Files In Directory   ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted    *.zip
    FOR    ${file}    IN    @{files}
        ${is_latest}=    Run Keyword And Ignore Error    Should Contain    ${file}    latest
        ${status1}=    Get From List    ${is_latest}    0
        ${is_err}=    Run Keyword And Ignore Error    Should Contain    ${file}    err_
        ${status2}=    Get From List    ${is_err}    0
        Run Keyword If    '${status1}' == 'FAIL' and '${status2}' == 'FAIL'    Extract Zip File
        ...  ${file}    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted/syslog_to_check    ${index}
        Run Keyword If    '${status1}' == 'PASS' and '${status2}' == 'FAIL'    Extract Zip File
        ...  ${file}    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted/syslog_to_check    ${index}
    END

    ${file_list}=    OperatingSystem.List Files In Directory    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted/syslog_to_check
    Collections.Sort List    ${file_list}
    Collections.Reverse List    ${file_list}

    ${result}=    file_operation.Merge Text Files
    ...  ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted/syslog_to_check
    ...  ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted/syslog_to_check/${syslog_merged_file_name}
    ...  "ISO-8859-1"
    Set Test Variable    ${syslog_to_check}    ${syslog_merged_file_name}

Step 4: Retrieving Information From The Syslog About Cells Deactivation Times
    [Documentation]
    ...  This step retrieves information from the syslog about cells deactivation times.
    ...  It iterates through each cell in the list of cells and searches for the deactivation timestamp in the syslog.
    ...  The timestamp is then stored in a list.
    [Arguments]    ${index}

    Log    \nStep 4: Retrieving Information From The Syslog About Cells Deactivation Times  console=${True}
    ${cell_down_time_stamp}=    Create List
    ${cell_down_time_to_file}=    Create List
    FOR    ${cell}    IN    @{cells info}
        ${grep_1}=    Catenate    SEPARATOR=
        ...   grep -E "cp_rt" ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted/syslog_to_check/${syslog_to_check} >${SPACE}
        ...   ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_${cell}/grep_cprt.txt
        ${grep_2}=    Catenate    SEPARATOR=
        ...    grep -E "AntennaCarrierDeactivationResp - OK" ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_${cell}/grep_cprt.txt >${SPACE}
        ...    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_${cell}/grep_AntennaCarrierDeactivationResp.txt
        ${grep_3}=    Catenate    SEPARATOR=
        ...    grep -E "${cell}" ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_${cell}/grep_AntennaCarrierDeactivationResp.txt >${SPACE}
        ...    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_${cell}/grep_cell_${cell}.txt
        Run    mkdir -p ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_${cell}
        Run    ${grep_1}
        Run    ${grep_2}
        Run    ${grep_3}
        ${cell_time_stamp}  ${cell_id}    Take The Last Entry
        ...    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_${cell}/grep_cell_${cell}.txt   ${cell}    ${index}
        Append To List  ${cell_down_time_stamp}  ${cell_time_stamp}
        Append To List    ${cell_down_time_to_file}  down time:${cell_time_stamp} cell:${cell_id}
        Should Not Be Empty    ${cell_down_time_stamp}    cells down time stamp list are empty
    END
    Sort List    ${cell_down_time_stamp}
    Set test variable  ${cell_down_time_stamp}
    Sort List    ${cell_down_time_to_file}
    ${formatted_to_save_in_file}=    Evaluate    "\\n".join(${cell_down_time_to_file})
    OperatingSystem.Create File    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_down_time.txt    ${formatted_to_save_in_file}

Step 5: Checking KPIs For Targets 52 And 52e
    [Documentation]
    ...  This step checks the KPIs for targets 52 and 52e.
    ...  The timestamp is then used to calculate the KPI value.
    [Arguments]    ${index}

    Log    \nStep 5: Checking KPIs For Targets 52 And 52e   console=${True}
    #52 first down last up
    ${kpi_result_52}=    DateTime.Subtract Time From Time    ${time_list}[-1]    ${cell_down_time_stamp}[0]
    #52e - last cell down to first up
    ${kpi_result_52e}=    DateTime.Subtract Time From Time    ${time_list}[0]    ${cell_down_time_stamp}[-1]
    Append To List  ${kpi_result_52_list}  ${kpi_result_52}
    Append To List  ${kpi_result_52e_list}  ${kpi_result_52e}
    ${minutes_52}    Evaluate    int(${kpi_result_52}) // 60
    ${seconds_52}    Evaluate    int(${kpi_result_52}) % 60
    ${minutes_52e}    Evaluate    int(${kpi_result_52e}) // 60
    ${seconds_52e}    Evaluate    int(${kpi_result_52e}) % 60
  IF    ${kpi_result_52} <= ${KPI_52_target}
     Log    KPI 52: ${minutes_52} minutes ${seconds_52} seconds. KPI target is met.    console=${True}
  ELSE
     Run Keyword And Continue On Failure    Fail    KPI 52 is exceeding the target. Result: ${minutes_52} minutes ${seconds_52} seconds.
     Run Keyword And Continue On Failure    vcu_admin.Get Local Snapshot
     ...    directory=${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/    connection=${VCU_CONNECTION}    compressed=${True}
     Run Keyword And Continue On Failure    vdu_admin.Get Local Snapshot
     ...    directory=${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/    vdu_connection=${VDU_CONNECTION}   compressed_or_not=${True}
     IF    ${FHGW_OBJ}
           Collect FHGW Snapshot    local_dir=${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/
     END
     Set Test Variable    ${logs_to_delete}    ${FALSE}
  END

  IF    ${kpi_result_52e} <= ${KPI_52e_target}
     Log    KPI 52e: ${minutes_52e} minutes ${seconds_52e} seconds. KPI target is met.    console=${True}
  ELSE
     Run Keyword And Continue On Failure    Fail    KPI 52e is exceeding the target. Result: ${minutes_52e} minutes ${seconds_52e} seconds.
     Run Keyword And Continue On Failure    vcu_admin.Get Local Snapshot
     ...    directory=${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/    connection=${VCU_CONNECTION}    compressed=${True}
     Run Keyword And Continue On Failure    vdu_admin.Get Local Snapshot
     ...    directory=${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/    vdu_connection=${VDU_CONNECTION}   compressed_or_not=${True}
     IF    ${FHGW_OBJ}
           Collect FHGW Snapshot    local_dir=${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/
     END
     Set Test Variable    ${logs_to_delete}    ${FALSE}
  END

  Run Keyword If    ${logs_to_delete}    Run Keyword
  ...    OperatingSystem.Remove Directory    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}    recursive=${True}
  Set Test Variable    ${logs_to_delete}    ${TRUE}

Step 6: Checking The Average KPI Result From ${number_of_iterations_TC01_02} Executions For Targets 52 and 52e
    [Documentation]
    ...  This step calculates the average KPI result from${number_of_iterations_TC01_02} executions for targets 52 and 52e.
    ...  It iterates through the list of KPI results for each target and calculates the average.

    Log    \nStep 6: Checking The Average KPI Result From ${number_of_iterations_TC01_02} Executions For Targets 52 and 52e   console=${True}
    ${average_52_result}=    Calculate Average    @{kpi_result_52_list}
    ${average_52e_result}=    Calculate Average    @{kpi_result_52e_list}
    ${minutes_52}    Evaluate    int(${average_52_result}) // 60
    ${seconds_52}    Evaluate    int(${average_52_result}) % 60
    ${minutes_52e}    Evaluate    int(${average_52e_result}) // 60
    ${seconds_52e}    Evaluate    int(${average_52e_result}) % 60
    IF    ${average_52_result} <= ${KPI_52_target}
          Log    The average KPI 52 score from${number_of_iterations_TC01_02} executions:   console=${True}
          Log    ${minutes_52} minutes ${seconds_52} seconds. Average KPI target is met.    console=${True}
    ELSE
          Fail  The average KPI 52, ${number_of_iterations_TC01_02} iterations are exceeding the target. Result: ${minutes_52}min ${seconds_52}sec.
    END
    IF    ${average_52e_result} <= ${KPI_52e_target}
          Log    The average KPI 52e score from${number_of_iterations_TC01_02} executions:    console=${True}
          Log    ${minutes_52e} minutes ${seconds_52e} seconds. Average KPI target is met.    console=${True}
    ELSE
          Fail  The average KPI 52e, ${number_of_iterations_TC01_02} iterations are exceeding the target. Result: ${minutes_52e}min ${seconds_52e}sec.
    END

Extract Zip File
    [Documentation]
    ...  This KW extracts the zip file containing the syslog data.
    ...  It uses the `Unzip` keyword to extract the zip file to the test suite logs directory.
    [Arguments]    ${zip_file}    ${dest_dir}    ${index}

    Log    Extracting ${zip_file} to ${dest_dir}
    unpacking.Unpack Archive Content To Directory    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/extracted/${zip_file}    ${dest_dir}

Calculate Average
    [Documentation]
    ...  This KW Calculate Average KPI result
    [Arguments]    @{kpi_list}

    ${total}=    Set Variable    0
    FOR    ${result}    IN    @{kpi_list}
           ${total}=    Evaluate    ${total} + ${result}
    END
    ${count}=    Get Length    ${kpi_list}
    ${average_kpi}=    Evaluate    ${total} / ${count}
    [Return]    ${average_kpi}

Take The Last Entry
    [Documentation]
    ...  This KW takes the last entry from the syslog file.
    [Arguments]    ${input_file}    ${cell}    ${index}

    ${content}=    OperatingSystem.Get File    ${input_file}
    ${lines}=      Split String    ${content}    ${\n}
    ${non_empty_lines}=    Evaluate    [line for line in ${lines} if line.strip()]
    ${last_line}=  Get From List    ${non_empty_lines}    -1
    Create File    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_${cell}/last_record.txt    ${last_line}
    ${cell_time_stamp}    ${cell_id}    Fetch Timestamp    ${last_line}
    [Return]       ${cell_time_stamp}    ${cell_id}

Fetch Timestamp
    [Documentation]
    ...  This KW fetches the timestamp from the last entry in the syslog file.
    [Arguments]    ${line}

    ${matches}=    Get Regexp Matches    ${line}    \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d+Z
    ${cell_id}=    Get Regexp Matches    ${line}    nrCellIdentity:(\\d+)
    Run Keyword If    ${matches}    Log    ${cell_id}: found timestamps: ${matches}    ELSE    Fail    No timestamp with 'Z' found in line: ${line}
    ${timestamp_with_z}=    Get From List    ${matches}    0
    ${raw_time}=      Evaluate    '${timestamp_with_z}'.split("T")[1]
    ${formatted_time}=    Replace String    ${raw_time}    Z    ${EMPTY}
    [Return]         ${formatted_time}    ${cell_id}

Get Nr Cell Identity
    [Documentation]
    ...  This KW retrieves the list of nr cells identity

    ${nr_cell_identity}=    Create List
    ${cells_info}=    vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    FOR    ${cell_info}    IN    @{cells_info}
          Append To List    ${nr_cell_identity}    ${cell_info["nr_cell_identity"]}
    END
   [Return]    ${nr_cell_identity}

Check All Cells Enabled for vDU
    [Documentation]
    ...  This KW checks if all cells of TL are in enabled operational state.
    [Arguments]    ${index}

    ${cells_list}=    vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${expected_state}=    Set Variable    enabled
    All Cell Operational States Should Be Equal    ${cells_list}    ${expected_state}    ${index}

All Cell Operational States Should Be Equal
    [Documentation]
    ...  This KW checks if all operational states of every cell in input list is equal to input string.
    [Arguments]    ${cells_list}    ${expected_state}    ${index}

    FOR    ${cell}    IN    @{cells_list}
        IF    "${cell['operational_state']}" == "${expected_state}" and "${cell['id']}" not in ${checked_cells}
            ${current_time}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
            Log    ${cell['name']} - ${cell['nr_cell_identity']}: Operational cell state matches expected - time: ${current_time}
            Append To List
            ...  ${to_save_in_file}
            ...  up time: ${current_time} cell: ${cell['nr_cell_identity']}
            Append To List    ${time_list}    ${current_time}
            Append To List    ${checked_cells}    ${cell['id']}
        END
        ${total_cells_count}=    Get Length    ${cells_list}
        ${enabled_cells_count}=    Get Length    ${checked_cells}
    END
    IF    "${total_cells_count}" == "${enabled_cells_count}"
        Log    All cells are enabled    console=${TRUE}
    ELSE
        Fail    Not all cells are enabled
    END
    Sort List    ${time_list}
    Set Test Variable    ${time_list}
    ${formatted_to_save_in_file}=    Evaluate    "\\n".join(${to_save_in_file})
    OperatingSystem.Create File    ${SUITE_LOGS_DIR_PATH}/vDU_syslog_ex_${index}/cell_up_time.txt    ${formatted_to_save_in_file}

Set TDD KPI target
    [Documentation]
    ...  This KW sets the TDD KPI target based on the number of cells in the configuration
    ${adjusted_count_TDD}=    Set Variable    0
    ${adjusted_count_TDD}=    Evaluate    ${count} > 3 and ${count} * 15 or 0
    ${KPI_52_target_TDD}=    Evaluate    ${KPI_52_target_TDD} + ${adjusted_count_TDD}
    Set Test Variable    ${KPI_52_target}    ${KPI_52_target_TDD}
    ${KPI_52e_target_TDD}=    Evaluate    ${KPI_52e_target_TDD} + ${adjusted_count_TDD}
    Set Test Variable    ${KPI_52e_target}    ${KPI_52e_target_TDD}

Set FDD KPI target
    [Documentation]
    ...  This KW sets the FDD KPI target based on the number of cells in the configuration
    ${adjusted_count_FDD}=    Set Variable    0
    ${adjusted_count_FDD}=    Evaluate    ${count} > 3 and ${count} * 10 or 0
    ${KPI_52_target_FDD}=    Evaluate    ${KPI_52_target_FDD} + ${adjusted_count_FDD}
    Set Test Variable    ${KPI_52_target}    ${KPI_52_target_FDD}
    ${KPI_52e_target_FDD}=    Evaluate    ${KPI_52e_target_FDD} + ${adjusted_count_FDD}
    Set Test Variable    ${KPI_52e_target}    ${KPI_52e_target_FDD}

Set MIX KPI target
    [Documentation]
    ...  This KW sets the FDD & TDD KPI target based on the number of cells in the configuration
    ${cells_status}     vdu.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${tdd_cells}=    Evaluate    [item['id'] for item in ${cells_status} if item['technology'] == 'TDD']
    ${tdd_cells_count}=    Get Length    ${tdd_cells}
    ${fdd_cells}=    Evaluate    [item['id'] for item in ${cells_status} if item['technology'] == 'FDD']
    ${fdd_cells_count}=    Get Length    ${fdd_cells}
    ${adjusted_count_FDD}=    Set Variable    0
    ${adjusted_count_TDD}=    Set Variable    0
    ${adjusted_count_FDD}=    Evaluate    ${fdd_cells_count} > 3 and ${fdd_cells_count} * 10 or 0
    ${adjusted_count_TDD}=    Evaluate    ${tdd_cells_count} > 3 and ${tdd_cells_count} * 15 or 0
    ${KPI_52_target_MIX}=    Evaluate    ${KPI_52_target_MIX} + ${adjusted_count_FDD} + ${adjusted_count_TDD}
    Set Test Variable    ${KPI_52_target}    ${KPI_52_target_MIX}
    ${KPI_52e_target_MIX}=    Evaluate    ${KPI_52e_target_MIX} + ${adjusted_count_FDD} + ${adjusted_count_TDD}
    Set Test Variable    ${KPI_52e_target}    ${KPI_52e_target_MIX}

Check If All Cells Are FDD or TDD
    [Documentation]
    ...  This KW checks if all cells are FDD or TDD and returns the appropriate value.
    [Arguments]    ${cells_technology}
    ${all_fdd}=    Evaluate    all(item == 'FDD' for item in ${cells_technology})
    ${all_tdd}=    Evaluate    all(item == 'TDD' for item in ${cells_technology})
    Return From Keyword If    ${all_fdd}    FDD
    Return From Keyword If    ${all_tdd}    TDD
    RETURN    MIX

Check vDU states
    [Arguments]        ${connection}=${vdu_connection}
    ${vdu_state}=    vdu_admin.Get Vdu State Data    vdu_connection=${connection}

    Log    vDU operational state is "${vdu_state["operational_state"]}"    console=${True}
    Should Be Equal As Strings    ${vdu_state["operational_state"].lower()}    commissioned