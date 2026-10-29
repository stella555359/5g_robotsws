*** Settings ***
Documentation
...    Author: Lan Shifu
...    contact: shifu.lan@nokia-sbell.com
...    squad group: VRF_HAZ4_T04

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/sub_band_beamforming.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012532_SG4/Resource/CB012532_variables.py


*** Keywords ***
SiSo_Online_Change_72A_72E_OnAir_L3Call
    [Documentation]    Perform online parameter change from 72A to 72E and make L3 call
    ...    This keyword first configures 72A parameters on all cells, checks they're OnAir, runs L3 call
    ...    Then configures 72E parameters, checks OnAir again, and runs another L3 call
    [Arguments]    ${ru_index}=${None}    ${duration}=${300}    ${with_call}=${True}
    ...    ${with_peak}=${False}    ${ue_num_each_call}=1
    ...    ${suite_name}=default    ${test_name}=default    ${upload_tp}=${True}
    ...    ${upload_duration}=${True}

    # Step 1: Get all cells in BTS
    Log To Console    \nStep 1: Get all cells in BTS
    ${cell_list}    Get All Cell Id    ru_index=${ru_index}

    # Step 2: Configure 72A parameters for all cells online
    Log To Console    \nStep 2: Configure 72A parameters for all cells online
    Modify Parameters Via Rest API    cell_list=${cell_list}    mode=72a    timeout=${300}

    # Step 3: Check if all cells are OnAir
    Log To Console    \nStep 3: Check if all cells are OnAir
    Verify Cells If OnAir

    # Step 4: Make L3 call and check throughput
    Log To Console    \nStep 4: Make L3 call and check throughput
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    upload_tp=${upload_tp}
    ...    upload_duration=${upload_duration}    suite_name=${suite_name}    test_name=${test_name}
    ...    ue_num_each_call=${ue_num_each_call}

    # Step 5: Configure 72E parameters for all cells online
    Log To Console    \nStep 5: Configure 72E parameters for all cells online
    Modify Parameters Via Rest API    cell_list=${cell_list}    mode=72e    timeout=${300}

    # Step 6: Check if all cells are OnAir
    Log To Console    \nStep 6: Check if all cells are OnAir
    Verify Cells If OnAir

    # Step 7: Make L3 call and check throughput
    Log To Console    \nStep 7: Make L3 call and check throughput
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    upload_tp=${upload_tp}
    ...    upload_duration=${upload_duration}    suite_name=${suite_name}    test_name=${test_name}
    ...    ue_num_each_call=${ue_num_each_call}

Modify Parameters Via Rest API
    [Documentation]    Modify cell parameters via REST API
    ...    Updates multiple parameters for specified cells using the given parameter mode
    ...    For 72a mode, also updates BTS-level parameters
    [Arguments]    ${cell_list}=${None}    ${mode}=72e    ${timeout}=${300}    ${connection}=GNB_OAM

    Log To Console    \nOnline modify parameters to ${mode} mode
    ${mode_config}    Get From Dictionary    dictionary=${ecpri_parameters_dict}    key=${mode}
    ${parameters_to_update_via_api}    Create List

    # Update Cell-level parameters
    ${cell_level_params}    Get From Dictionary    dictionary=${mode_config}    key=cell_level
    FOR    ${cell_id}    IN    @{cell_list}
        ${cell_dist_name}    Set Variable    NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        FOR    ${parameter_dict}    IN    @{cell_level_params}
            ${parameter_copy}    Copy Dictionary    dictionary=${parameter_dict}
            Set To Dictionary    dictionary=${parameter_copy}    dist_name=${cell_dist_name}
            Append To List    ${parameters_to_update_via_api}    ${parameter_copy}
        END
    END

    # Add BTS-level parameters
    ${bts_level_params}    Get From Dictionary    dictionary=${mode_config}    key=bts_level
    ${has_bts_params}    Get Length    ${bts_level_params}
    IF    ${has_bts_params} > 0
        Log To Console    \nAdding ${has_bts_params} BTS-level parameters for ${mode} mode
        FOR    ${parameter_dict}    IN    @{bts_level_params}
            ${parameter_copy}    Copy Dictionary    dictionary=${parameter_dict}
            Append To List    ${parameters_to_update_via_api}    ${parameter_copy}
        END
    END

    # Update all parameters via REST API
    ${total_params}    Get Length    ${parameters_to_update_via_api}
    Log To Console    \nTotal parameters to update: ${total_params}
    Connect to gnb coam via ssl    connection=${connection}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update_via_api}
    ...    skip_parameter_relation_errors=${False}    timeout=${timeout}    connection=${connection}

Verify Cells If OnAir
    [Documentation]    Verify all cells are OnAir and no unexpected alarms exist
    ...    Waits for cells to come online and checks for alarm absence
    Log To Console    \nCheck if all cells are OnAir
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}
    Should Be True    ${history_alarm_status}

Run L3 Call With SubBand Beamforming Check
    [Documentation]    Run L3 call traffic test and verify SubBand Beamforming configuration
    ...    1. Start capturing AASyslog with filter
    ...    2. Run L3 call traffic test on specified cells
    ...    3. Verify SubBand Beamforming configuration through AASyslog
    ...    4. Stop L3 call and detach UEs
    ...    5. Final verification of AASyslog content
    [Arguments]    ${cell_list}=${None}    ${duration}=${900}    ${direction}=DL
    ...    ${check_duration}=${60}    ${ue_num_each_call}=1    ${suite_name}=default
    ...    ${test_name}=default    ${filter}=L2-PS    ${log_name}=Aasys_SrsSubbandBm.txt
    # Step 1: Start AASyslog capture with filter
    Log To Console    \nStep 1: Start AASyslog capture with ${filter} filter
    Start To Capture AASyslog    filter=${filter}    log_name=${log_name}
    # Step 2: Run L3 call traffic and verify peak throughput
    Log To Console    \nStep 2: Run L3 call traffic and verify peak throughput
    Run L3 Call Traffic Test    cell_list=${cell_list}    duration=${duration}    check_duration=${check_duration}
    ...    ue_num_each_call=${ue_num_each_call}    suite_name=${suite_name}    test_name=${test_name}    direction=${direction}
    # Step 3: Verify SubBand Beamforming if present in AASyslog
    Log To Console    \nStep 3: Verify SubBand Beamforming if present in AASyslog
    Verify AASyslog Via Filter    filter_param=reason WIDEBAND
    # Step 4: Start AASyslog capture with filter again
    Log To Console    \nStep 4: Starting AASyslog capture with ${filter} filter
    Start To Capture AASyslog    filter=${filter}    log_name=${log_name}
    # Step 5: Stop traffic
    Log To Console    message=\nStep 5: Stopping traffic
    Stop L3 Call Traffic Test
    # Step 6: Verify SubBand Beamforming if present in AASyslog
    Log To Console    message=\nStep 6: Verify SubBand Beamforming if present in AASyslog
    Verify AASyslog Via Filter    filter_param=reason SUBBAND

4CC_10Mhz_with_CB009527
    [Documentation]    Implementation of 4CC 10MHz with CB009527 feature test
    ...                Iterates through each cell in cell_list to run SubBand Beamforming Check
    [Arguments]    ${ru_index}=${None}    ${suite_name}=default    ${test_name}=default    ${duration}=${900}
    ...    ${check_duration}=${90}    ${ue_num_each_call}=${1}    ${with_call}=${True}    ${ignored_cell_list}=${None}
    # Step 1: Get all cells in BTS
    ${cell_list}    Get All Cell Id    ru_index=${ru_index}
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List
    ...    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    IF    "${ignored_cell_list}" != "${None}"
        ${cell_list}    Evaluate    [x for x in ${cell_list} if x not in ${ignored_cell_list}]
    END
    Log    Cell list: ${cell_list}
    # Step 2: Verify cell is OnAir
    Log    message=Step 2: Verifying cell is OnAir
    Verify Cell If OnAir
    # Step 3: Iterate through each cell and run SubBand Beamforming Check
    IF    ${with_call}
        ${check_result_list}    Create List
        FOR    ${cell_id}    IN    @{cell_list}
            Log    Processing cell: ${cell_id}
            ${single_cell_list}    Create List    ${cell_id}
            # Log the current cell being tested
            Log To Console    \nRunning SubBand Beamforming Check for cell: ${cell_id}
            # Run the SubBand Beamforming Check for this cell using the input test_name directly
            ${cell_result}    Run Keyword And Return Status
            ...    Run L3 Call With SubBand Beamforming Check
            ...    cell_list=${single_cell_list}
            ...    duration=${duration}
            ...    check_duration=${check_duration}
            ...    ue_num_each_call=${ue_num_each_call}
            ...    suite_name=${suite_name}
            ...    test_name=${test_name}
            # Record the result for this cell
            Append To List    ${check_result_list}    ${cell_result}
        END
        Run Keyword If    ${False} in ${check_result_list}    Fail    msg=Exist cell sub-Band beamforming check failed: ${check_result_list}
    END
