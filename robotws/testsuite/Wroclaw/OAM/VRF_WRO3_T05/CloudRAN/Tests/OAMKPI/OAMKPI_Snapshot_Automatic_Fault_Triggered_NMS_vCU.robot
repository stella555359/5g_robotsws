*** Settings ***
Documentation    Test case to verify duration of autonomous fault triggered snapshot upload from vCU to NMS.
...              Author:    damian.kotula@nokia.com
...              Change history:
...              17.04.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-18400 - Initial creation
...              08.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23346 - Full TC Refactor

*** Variables ***
${CELL_IS_BLOCKED}               ${False}          #Used to track if cell was blocked during test
${TRIGGER_ADDED}                 ${False}          #Used to track if fault snapshot trigger was added during test
${INTERVAL_BETWEEN_TRIGGERS}     910               #15 minutes (900s) + 10s buffer, per DNG ID 11710223
@{BTS_KPI_RESULTS}                                 #list to store BTS KPI results
@{UPLOAD_KPI_RESULTS}                              #list to store UPLOAD KPI results
@{SNAPSHOT_SIZES}                                  #list to store Collected Snapshot Sizes
@{TARGETS_FOR_SNAPSHOTS}                           #list to store choosen targets for snapshot sizes.

*** Keywords ***
OAMKPI_Snapshot_Automatic_Fault_Triggered_NMS_vCU
    [Documentation]
    ...    This keyword verifies the KPI duration of autonomous fault triggered snapshot upload from vCU to NMS.
    ...    It performs the following steps:
    ...    1. Integrates vCU with NMS lab and sets snapshot destination to nms, configures snapshot trigger for fault 7104.
    ...    2. Blocks a random cell on vDU to trigger the snapshot collection.
    ...    3. Waits for the snapshot collection to complete and the upload to NMS to finish.
    ...    4. Calculates the KPI results based on the time taken for the snapshot collection and upload.
    ...    5. Downloads the snapshot from NMS, checks its size and validates the KPI results against the targets.
    ...    6. Checks the average KPI results and compares them against the targets.
    ...    7. Generates a results file containing the KPI results, averages and target values.
    ...    Input:    test_iterations = number of iterations to run the test
    ...              nms_lab = NMS lab number to use (e.g. 1019)
    [Arguments]    ${test_iterations}    ${nms_lab}
    ${USED_NMS_LAB}=     Set Variable    ${srnclab${nms_lab}}
    ${TRBLCADM_DN}=      Set Variable    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/TRBLCADM-1
    Set Test Variable    ${USED_NMS_LAB}
    Set Test Variable    ${TRBLCADM_DN}
    Preconditions
    FOR   ${i}    IN RANGE    ${test_iterations}
        Log    \n--- Execution loop: ${i + 1} ---\n    console=${True}
        Block Cell To Trigger Autonomous Snapshot
        Wait For Snapshot To Collect And Get Results
        Download Snapshot From NMS And Verify KPI Results

        #Assure 15 minutes has passed between snapshot triggers - DNG ID 11710223
        ${iteration_finished_time}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
        ${seconds_passed}=    Subtract Time From Time    ${iteration_finished_time}    ${FAULT_RAISED_TIME}
        ${seconds_passed}=    Evaluate    round(${seconds_passed})
        ${remaining_time}=    Evaluate    ${INTERVAL_BETWEEN_TRIGGERS} - ${seconds_passed}
        IF    ${i + 1} < ${test_iterations} and ${remaining_time} > 0
            Log    Sleeping for ${remaining_time}s before next iteration    console=${True}
            Sleep    ${remaining_time}s
        END
    END
    Check Averages And Create Results File
    [Teardown]    Custom Test Teardown


Preconditions
    [Documentation]    Description:    This keyword integrates vCU to NMS lab, sets snapshot destination to nms,
    ...                                configures snapshot trigger for fault 7104.

    mantaray.Check NMS Status On Cloud BTS    expected_status=N/A    hw_type=vCU
    mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${USED_NMS_LAB}    hw_type=vCU
    ${snap_destination}=    parameters.Check Parameter Value   dist_name=${TRBLCADM_DN}
    ...                                                         param_name=diagSnapDestination    hw_type=vCU
    IF    '${snap_destination[0]}' != 'nms'
        Log    Changing snapshot destination to nms    console=${True}
        parameters.Change Parameter on BTS    dist_name=${TRBLCADM_DN}    param_name=diagSnapDestination
        ...                                   param_value=nms    hw_type=vCU    pre-connection=${vcu_connection}
    ELSE
        Log    Snapshot destination is set to nms    console=${True}
    END
    Configure Snapshot Trigger For Fault 7104 on vCU

Block Cell To Trigger Autonomous Snapshot
    [Documentation]    Description:    This keyword blocks a random cell on vDU to trigger the autonomous snapshot.

    ${random_cell}=    Get vDU Random Cell ID
    Set Test Variable    ${RANDOM_CELL_ID}    ${random_cell}
    vdu_admin.Block Cell    cell_id=${RANDOM_CELL_ID}    vdu_connection=${vdu_connection}
    Log    Cell ${RANDOM_CELL_ID} is blocked on vDU.    console=${True}
    Set Test Variable    ${CELL_IS_BLOCKED}    ${True}

Wait For Snapshot To Collect And Get Results
    [Documentation]    Description:    This keyword waits for the snapshot collection to complete and saves KPI results.

    Wait Until Keyword Succeeds    2m    1s    Alarm Should be Active    alarm=7104    hw_type=vCU    pre-connection=${vcu_connection}
    ${fault_raised_time}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Set Test Variable    ${FAULT_RAISED_TIME}
    Log    Fault 7104 is raised.    console=${True}
    Wait Until Keyword Succeeds    2m    1s    Check DiagSnapState on vCU    expected_state=Collection ongoing
    Wait Until Keyword Succeeds    ${KPI_UP_TO_2GB_target}    1s    Check DiagSnapState on vCU    expected_state=Collection ready
    ${collection_ready_time}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Wait Until Keyword Succeeds    ${KPI_UPLOAD_TO_NMS_target}    1s    Check DiagSnapState on vCU    expected_state=Upload completed
    ${upload_completed_time}=    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    ${bts_kpi_result}=       Subtract Time From Time    ${collection_ready_time}    ${fault_raised_time}    exclude_millis=${True}
    ${upload_kpi_result}=    Subtract Time From Time    ${upload_completed_time}    ${fault_raised_time}    exclude_millis=${True}
    Set Test Variable    ${bts_kpi_result}
    Set Test Variable    ${upload_kpi_result}
    Append To List    ${BTS_KPI_RESULTS}       ${bts_kpi_result}
    Append To List    ${UPLOAD_KPI_RESULTS}    ${upload_kpi_result}
    ${bts_kpi_result_log}=    Convert Time     ${bts_kpi_result}    result_format=verbose    exclude_millis=${True}
    ${upload_kpi_result_log}=    Convert Time    ${upload_kpi_result}    result_format=verbose    exclude_millis=${True}
    Log    BTS KPI result: ${bts_kpi_result_log}, Upload KPI result: ${upload_kpi_result_log}    console=${True}

Download Snapshot From NMS And Verify KPI Results
    [Documentation]    Description:    This keyword downloads snapshot from NMS, checks its size and
    ...                                validates the KPI results against the targets.

    ${snapshot_name}=    vcu_admin.Search Parameters Of Current Plan    parameter_name=diagSnapFilename
    ...                                                                 connection=${vcu_connection}
    ${snap_file_name}=    Get From Dictionary    ${snapshot_name['items'][0]['parameter']['simple_parameter']}    value
    ${snapshot_path}=    Set Variable    /d/oss/global/diagsnap/ne3sws/${snap_file_name}
    ssh.Connect To    hostname=${USED_NMS_LAB}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    Wait Until Keyword Succeeds    2m    2s    Check If Snapshot Is On NMS lab    path=${snapshot_path}
    ${snapshot_size}=    ssh.Execute    stat -c '%s' ${snapshot_path} | awk '{print $1/1024/1024}'
    ${snapshot_size}=    Convert To Number    ${snapshot_size}
    Append To List    ${SNAPSHOT_SIZES}    ${snapshot_size}
    Log    Snapshot size is: ${snapshot_size} MB    console=${True}
    ssh.Download File    remote_path=${snapshot_path}    local_path=${TEST_RESULTS_DIR}/${snap_file_name}
    ssh.Execute    rm -rf ${snapshot_path}
    ssh.Disconnect
    ${bts_kpi_target}=    common_keywords.Get KPI Target Based On Snapshot Size    ${snapshot_size}
    Append To List    ${TARGETS_FOR_SNAPSHOTS}    BTS Target for size ${snapshot_size}MB snapshot: ${bts_kpi_target}s
    ${is_bts_kpi_in_limits}=       Evaluate   ${bts_kpi_result} <= ${bts_kpi_target}
    Run Keyword And Continue On Failure    Should Be True    ${is_bts_kpi_in_limits}
    ...                                    msg=BTS KPI value ${bts_kpi_result} exceeds ${bts_kpi_target}
    ${is_upload_kpi_in_limits}=    Evaluate    ${upload_kpi_result} <= ${KPI_UPLOAD_TO_NMS_target}
    Run Keyword And Continue On Failure    Should Be True    ${is_upload_kpi_in_limits}
    ...                                    msg=Upload KPI value ${upload_kpi_result} exceeds ${KPI_UPLOAD_TO_NMS_target}
    vdu_admin.Unblock Cell    cell_id=${RANDOM_CELL_ID}    vdu_connection=${vdu_connection}
    Set Test Variable    ${CELL_IS_BLOCKED}    ${False}

Check Averages And Create Results File
    [Documentation]    Description:    This keyword calculates and checks average BTS KPI, Upload KPI and Snapshot size
    ...                                from all iterations and creates results file.

    ${average_bts_result}=       Evaluate    sum([int(x) for x in @{BTS_KPI_RESULTS}]) / len(@{BTS_KPI_RESULTS})
    ${average_upload_result}=    Evaluate    sum([int(x) for x in @{UPLOAD_KPI_RESULTS}]) / len(@{UPLOAD_KPI_RESULTS})
    ${average_snapshot_size}=    Evaluate    sum([float(x) for x in @{SNAPSHOT_SIZES}]) / len(@{SNAPSHOT_SIZES})
    Log    \nAverage BTS result: ${average_bts_result}s.            console=${True}
    Log    \nAverage Upload result: ${average_upload_result}s.      console=${True}
    Log    \nAverage Snapshot size: ${average_snapshot_size} MB.    console=${True}
    ${results}=    Create List    BTS KPI RESULTS:       @{BTS_KPI_RESULTS}s
    ...                           UPLOAD KPI RESULTS:    @{UPLOAD_KPI_RESULTS}s
    ...                           SNAPSHOT SIZES:        @{SNAPSHOT_SIZES} MB
    ${averages}=   Create List    BTS KPI: ${average_bts_result}s
    ...                           Upload KPI: ${average_upload_result}s
    ...                           Snapshot Size: ${average_snapshot_size} MB
    ${targets}=    Create List    @{TARGETS_FOR_SNAPSHOTS}    Upload Target: ${KPI_UPLOAD_TO_NMS_TARGET}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}
    ${average_bts_kpi_target}=    common_keywords.Get KPI Target Based On Snapshot Size    ${average_snapshot_size}

    ${is_avg_bts_kpi_in_limits}=       Evaluate    ${average_bts_result} <= ${average_bts_kpi_target}
    Run Keyword And Continue On Failure     Should Be True    ${is_avg_bts_kpi_in_limits}
    ...                                     msg=Average BTS KPI value ${average_bts_result} exceeds ${average_bts_kpi_target}
    ${is_avg_upload_kpi_in_limits}=    Evaluate    ${average_upload_result} <= ${KPI_UPLOAD_TO_NMS_target}
    Run Keyword And Continue On Failure     Should Be True    ${is_avg_upload_kpi_in_limits}
    ...                                     msg=Upload KPI value ${average_upload_result} exceeds ${KPI_UPLOAD_TO_NMS_target}


Configure Snapshot Trigger For Fault 7104 on vCU
    [Documentation]    Description:    This keyword configures snapshot trigger for fault 7104 with
    ...                                triggerType=onAlarmSend on vCU.
    Log    Configuring snapshot trigger for fault 7104    console=${True}
    &{complex_param_dict}=    Create Dictionary    faultNumber=7104
    ...                                            triggerType=onAlarmSend
    @{complex_param_list}=    Create List          ${complex_param_dict}
    &{param_dict}=            Create Dictionary    parameterName=faultSnapshotTriggers
    ...                                            value=@{complex_param_list}
    ...                                            operation=create
    @{param_list}=            Create List          ${param_dict}
    &{change_dict}=           Create Dictionary    distName=${TRBLCADM_DN}
    ...                                            operation=create
    ...                                            parameters=@{param_list}
    @{delta}=                 Create List          ${change_dict}
    ${delta_json}=            Evaluate             json.dumps(${delta})    json
    vcu_admin.Perform Delta Recommissioning    delta_file=${delta_json}    connection=${vcu_connection}
    Set Test Variable    ${TRIGGER_ADDED}    ${True}

Delete Snapshot Trigger For Fault 7104 on vCU
    [Documentation]    Description:    This keyword deletes snapshot trigger for fault 7104 on vCU.
    &{complex_param_dict}=    Create Dictionary    faultNumber=7104
    ...                                            triggerType=onAlarmSend
    @{complex_param_list}=    Create List          ${complex_param_dict}
    &{param_dict}=            Create Dictionary    parameterName=faultSnapshotTriggers
    ...                                            value=@{complex_param_list}
    ...                                            operation=delete
    @{param_list}=            Create List          ${param_dict}
    &{change_dict}=           Create Dictionary    distName=${TRBLCADM_DN}
    ...                                            operation=update
    ...                                            parameters=@{param_list}
    @{delta}=                 Create List          ${change_dict}
    ${delta_json}=            Evaluate             json.dumps(${delta})    json
    vcu_admin.Perform Delta Recommissioning    delta_file=${delta_json}    connection=${vcu_connection}

Check DiagSnapState on vCU
    [Documentation]    Description:    This keyword passes if the DiagSnapState is equal to the expected state, otherwise fails.
    ...                Input:          expected_state = Collection requested / Collection ongoing / Collection ready /
    ...                                                 Collection failed / Upload completed / Upload failed
    [Arguments]    ${expected_state}
    ${diagSnapState}=    vcu_admin.Search Parameters Of Current Plan    parameter_name=diagSnapState
    ...                                                                 connection=${vcu_connection}
    ${current_state}=    Get From Dictionary    ${diagSnapState['items'][0]['parameter']['simple_parameter']}    value
    Should Be Equal As Strings    ${current_state}    ${expected_state}
     ...    msg=DiagSnapState is '${current_state}', but expected '${expected_state}'.

Check If Snapshot Is On NMS lab
    [Documentation]    Description:    This keyword is used to check if snapshot is on NMS lab.
    [Arguments]    ${path}
    ${snapshot_check_output}=    ssh.Execute    stat -c '%s' ${path}
    Should Not Contain    ${snapshot_check_output}    No such file or directory

Custom Test Teardown
    [Documentation]    Description:    Unblocks cell if blocked, removes fault snapshot trigger if it was added
    ...                during test, deintegrates vCU from NMS lab. Used in test suite.
    Log    Custom Test Teardown    console=${TRUE}
    ${vdu_connection}=   Connect To ADMIN    hw_type=vDU
    Set Test Variable    ${vdu_connection}
    Run Keyword If    ${CELL_IS_BLOCKED}    vdu_admin.Unblock Cell    cell_id=${RANDOM_CELL_ID}    vdu_connection=${vdu_connection}
    Run Keyword If    ${TRIGGER_ADDED}    Delete Snapshot Trigger For Fault 7104 on vCU
    Disconnect from ADMIN    connection=${vdu_connection}    hw_type=vDU
    mantaray.Deintegrate Cloud BTS from NMS Lab    nms_lab_ip=${USED_NMS_LAB}    hw_type=vCU