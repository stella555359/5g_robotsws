*** Settings ***
Documentation    Test case to verify duration of autonomous fault triggered snapshot upload from vDU to NMS.
...              Author:    damian.kotula@nokia.com
...              Change history:
...              09.12.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-6193 - Initial creation

*** Variables ***
${CELL_IS_BLOCKED}               ${False}          #Used to track if cell was blocked during test
${TRIGGER_ADDED}                 ${False}          #Used to track if fault snapshot trigger was added during test
${USED_NMS_LAB}                  ${srnclab5007}    #IP of used NMS lab. To be moved into suite
${BTS_KPI_TARGET_UP_TO_500MB}    600               #Target in seconds for snapshot up to 500 MB
${BTS_KPI_TARGET_UP_TO_1GB}      900               #Target in seconds for snapshot up to 1 GB
${UPLOAD_TO_NMS_TARGET}          1500              #Target in seconds for upload KPI

*** Keywords ***
CB011085_A_TC25_Duration_Automatic_Fault_Triggered_Snapshot_WebEM_vDU
    Step 0: Preconditions
    Step 1: Block Cell To Trigger Snapshot
    Step 2: Wait For Snapshot Upload
    Step 3: Download Snapshot And Verify KPI Results

Step 0: Preconditions
    [Documentation]    Description:    In this step vDU is integrated to NMS lab, snapshot destination is set to nms,
    ...                                snapshot trigger for fault 49 is configured if not done already.

    Prompt To Console    Step 0: Preconditions
    ${trblcadm_dn} =    Set Variable    MRBTS-${MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
    Set Test Variable    ${TRBLCADM_DN}    ${trblcadm_dn}
    mantaray.Check NMS Status On Cloud BTS    expected_status=N/A    hw_type=vDU
    mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${USED_NMS_LAB}    hw_type=vDU
    ${snap_destination} =    parameters.Check Parameter Value   dist_name=${TRBLCADM_DN}
    ...                                                         param_name=diagSnapDestination    hw_type=vDU
    IF    '${snap_destination}' != 'nms'
        Log    Changing snapshot destination to nms    console=${True}
        parameters.Change Parameter on BTS    dist_name=${TRBLCADM_DN}    param_name=diagSnapDestination
        ...                                   param_value=nms    hw_type=vDU    pre-connection=${vdu_connection}
    ELSE
        Log    Snapshot destination is set to nms    console=${True}
    END
    Check If Trigger For Fault 49 Is Configured


Step 1: Block Cell To Trigger Snapshot
    [Documentation]    Description:    In this step random cell is blocked on vDU to raise fault 49 and
    ...                                trigger autonomous snapshot upload to NMS.

    Prompt To Console    Step 1: Block Cell To Trigger Snapshot
    ${random_cell} =    Get Random Cell ID
    Set Test Variable    ${RANDOM_CELL_ID}    ${random_cell}
    vdu_admin.Block Cell    cell_id=${RANDOM_CELL_ID}    vdu_connection=${vdu_connection}
    Log    Cell ${RANDOM_CELL_ID} is blocked.    console=${True}
    Set Test Variable    ${CELL_IS_BLOCKED}    ${True}

Step 2: Wait For Snapshot Upload
    [Documentation]    Description:    In this step timestamps are taken when fault 49 is raised,
    ...                                when snapshot collection is ready on vDU and when snapshot upload is completed.
    ...                                KPI results are then calculated.

    Prompt To Console    Step 2: Wait For Snapshot Upload
    Wait Until Keyword Succeeds    1m    1s    Check If Fault 49 Is Active
    ${fault_raised_time} =    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Log    Fault 49 is raised.    console=${True}
    Wait Until Keyword Succeeds    2m    1s    Check DiagSnapState    expected_state=Collection ongoing
    Wait Until Keyword Succeeds    15m    1s    Check DiagSnapState    expected_state=Collection ready
    ${collection_ready_time} =    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    Wait Until Keyword Succeeds    25m    1s    Check DiagSnapState    expected_state=Upload completed
    ${upload_completed_time} =    DateTime.Get Current Date    time_zone=UTC    result_format=%H:%M:%S.%f
    ${snapshot_name} =    vdu_admin.Search Parameter Of Current Plan
    ...    mo_dn=${TRBLCADM_DN}/TRBLCADM_R-1    para_name=diagSnapFilename   vdu_connection=${vdu_connection}
    Set Test Variable    ${SNAPSHOT_NAME}    ${snapshot_name}
    ${bts_kpi_result} =       Subtract Time From Time    ${collection_ready_time}    ${fault_raised_time}
    ${upload_kpi_result} =    Subtract Time From Time    ${upload_completed_time}    ${fault_raised_time}
    Set Test Variable    ${BTS_KPI_RESULT}    ${bts_kpi_result}
    Set Test Variable    ${UPLOAD_KPI_RESULT}    ${upload_kpi_result}
    ${BTS_KPI_RESULT} =    Convert Time    ${BTS_KPI_RESULT}    result_format=verbose    exclude_millis=${True}
    ${UPLOAD_KPI_RESULT} =    Convert Time    ${UPLOAD_KPI_RESULT}    result_format=verbose    exclude_millis=${True}
    Log    BTS KPI result: ${BTS_KPI_RESULT}, Upload KPI result: ${UPLOAD_KPI_RESULT}    console=${True}

Step 3: Download Snapshot And Verify KPI Results
    [Documentation]    Description:    In this step snapshot is downloaded from NMS lab to VM.
    ...                                KPI results are verified against the targets based on snapshot size.

    Prompt To Console    Step 3: Download Snapshot And Verify KPI Results
    ${snapshot_path} =    Set Variable    /d/oss/global/diagsnap/ne3sws/${SNAPSHOT_NAME}
    ssh.Connect To    hostname=${USED_NMS_LAB}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    Wait Until Keyword Succeeds    2m    2s    Check If Snapshot Is On NMS lab    path=${snapshot_path}
    ${snapshot_size} =    ssh.Execute    stat -c '%s' ${snapshot_path} | awk '{print $1/1024/1024}'
    ${snapshot_size} =    Convert To Number    ${snapshot_size}
    Log    Snapshot size is: ${snapshot_size} MB    console=${True}
    ssh.Download File    remote_path=${snapshot_path}    local_path=${TEST_RESULTS_DIR}/${SNAPSHOT_NAME}
    ssh.Execute    rm -rf ${snapshot_path}
    ssh.Disconnect
    IF    ${snapshot_size} < 500
        Should Be True    ${BTS_KPI_RESULT} <= ${BTS_KPI_TARGET_UP_TO_500MB}
        ...    msg=BTS KPI result is higher than the target.
    ELSE IF    ${snapshot_size} < 1000
        Should Be True    ${BTS_KPI_RESULT} <= ${BTS_KPI_TARGET_UP_TO_1GB}
        ...    msg=BTS KPI result is higher than the target.
    END
    Should Be True    ${UPLOAD_KPI_RESULT} <= ${UPLOAD_TO_NMS_TARGET}
        ...    msg=Upload to NMS KPI result is higher than the target.

Check DiagSnapState
    [Documentation]    Description:    This keyword passes if the DiagSnapState is equal to the expected state, otherwise fails.
    ...                Input:          expected_state = Collection requested / Collection ongoing / Collection ready /
    ...                                                 Collection failed / Upload completed / Upload failed
    [Arguments]    ${expected_state}
    ${diagSnapState} =    vdu_admin.Search Parameter Of Current Plan
    ...    mo_dn=${TRBLCADM_DN}/TRBLCADM_R-1    para_name=diagSnapState    vdu_connection=${vdu_connection}
    IF    "${diagSnapState}" == "${expected_state}"
        Log    DiagSnapState is equal to the expected state: ${expected_state}    console=${True}
        RETURN    ${True}
    ELSE
        Fail    DiagSnapState is not equal to the expected state: ${expected_state}
    END

Check If Trigger For Fault 49 Is Configured
    [Documentation]    Description:    This keyword creates a dictionary with fault snapshot triggers configured on vDU
    ...                                and check if trigger for fault 49 is already configured with required
    ...                                trigger type and snapshot coverage level. If not, configures it.

    ${fault_numbers} =    Create List
    ${fault_values} =     Create List
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
                ${values} =    Create List
                ${trigger_type} =    vdu_admin.Search Parameter Of Current Plan
                ...    mo_dn=${TRBLCADM_DN}    para_name=faultSnapshotTriggers/${index}/triggerType
                ...    vdu_connection=${vdu_connection}
                Append To List    ${values}    ${trigger_type}
                ${snap_coverage} =    vdu_admin.Search Parameter Of Current Plan
                ...    mo_dn=${TRBLCADM_DN}    para_name=faultSnapshotTriggers/${index}/snapshotCoverageLevel
                ...    vdu_connection=${vdu_connection}
                Append To List    ${values}    ${snap_coverage}
                Append To List    ${fault_values}    ${values}
            END
        ELSE
            Set Test Variable   ${AVAILABLE_INDEX}    ${index}
            Exit For Loop
        END
    END

    &{fault_trigger_dict} =    Create Dictionary
    ${length} =    Get Length    ${fault_numbers}
    FOR    ${i}    IN RANGE    ${length}
        Set to Dictionary    ${fault_trigger_dict}    ${fault_numbers[${i}]}=${fault_values[${i}]}
    END

    ${fault_49_configured} =    Evaluate
    ...    '49' in ${fault_trigger_dict} and ${fault_trigger_dict.get('49')} == ['onFaultDetection', 'Full']
    IF    ${fault_49_configured}
        Log    Trigger for fault 49 is configured properly.    console=${True}
    ELSE
        Log    Trigger for fault 49 will be configured.    console=${True}
        Configure Snapshot Trigger For Fault 49
    END

Configure Snapshot Trigger For Fault 49
    [Documentation]    Description:    This keyword configures snapshot trigger for fault 49 with coverage=full and
    ...                                triggerType=onFaultDetection on vDU.
    &{complex_param_dict} =    Create Dictionary    faultNumber=49
    ...                                             triggerType=onFaultDetection
    ...                                             snapshotCoverageLevel=Full
    @{complex_param_list} =    Create List          ${complex_param_dict}
    &{param_dict} =            Create Dictionary    parameterName=faultSnapshotTriggers
    ...                                             value=@{complex_param_list}
    ...                                             operation=crate
    @{param_list} =            Create List          ${param_dict}
    &{change_dict} =           Create Dictionary    distName=${TRBLCADM_DN}
    ...                                             operation=create
    ...                                             parameters=@{param_list}
    @{delta} =                 Create List          ${change_dict}
    ${delta_json} =            Evaluate             json.dumps(${delta})    json
    vdu_admin.Perform Delta Recommissioning    delta_file=${delta_json}    vdu_connection=${vdu_connection}
    Set Test Variable    ${TRIGGER_ADDED}    ${True}

Check If Fault 49 Is Active
    [Documentation]    Description:    This keyword is used to check if fault 49 is active on vDU.
    ${alarms_list} =    vdu_admin.Vdu Get Active Alarms    vdu_connection=${vdu_connection}
    ${alarms} =         Convert to String    ${alarms_list}
    Should Contain      ${alarms}    'fault_id': '49'

Check If Snapshot Is On NMS lab
    [Documentation]    Description:    This keyword is used to check if snapshot is on NMS lab.
    [Arguments]    ${path}
    ${snapshot_check_output} =    ssh.Execute    stat -c '%s' ${path}
    Should Not Contain    ${snapshot_check_output}    No such file or directory

Get Random Cell ID
    [Documentation]    Description:    This keyword picks random cell ID from all cells on vDU.
    ...                Output:         Random cell ID, for example: 12
    ${cell_id_list} =    Create List
    ${cells info} =    vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    FOR    ${cell_info}    IN    @{cells_info}
          Append To List    ${cell_id_list}    ${cell_info["id"]}
    END
    ${random_cell_id} =    Evaluate    random.choice(${cell_id_list})    modules=random
    Log    Random Cell ID: ${random_cell_id}
    [Return]    ${random_cell_id}

Delete Snapshot Trigger For Fault 49
    &{complex_param_dict} =    Create Dictionary    faultNumber=49
    ...                                             triggerType=onFaultDetection
    ...                                             snapshotCoverageLevel=Full
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
    [Documentation]    Description:    Unblocks cell if blocked, removes fault snapshot trigger if it was added
    ...                during test, deintegrates vDU from NMS lab. Used in test suite.
    Log    Custom Test Teardown    console=${TRUE}
    ${vdu_connection}=   Connect To ADMIN    hw_type=vDU    alias=teardown_vdu_con
    Set Test Variable    ${vdu_connection}
    Run Keyword If    ${CELL_IS_BLOCKED}    vdu_admin.Unblock Cell    cell_id=${RANDOM_CELL_ID}    vdu_connection=${vdu_connection}
    Run Keyword If    ${TRIGGER_ADDED}    Delete Snapshot Trigger For Fault 49
    mantaray.Deintegrate Cloud BTS from NMS Lab    nms_lab_ip=${USED_NMS_LAB}    hw_type=vDU
