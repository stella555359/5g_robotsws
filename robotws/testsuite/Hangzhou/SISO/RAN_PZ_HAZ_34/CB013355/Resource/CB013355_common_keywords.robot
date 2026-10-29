*** Settings ***
Documentation    Common keywords for CB013355 test cases
...              These keywords support verification of eCPRI U-Plane & Fast-C-Plane counters
...              in single user single cell (SiSo) scenarios

Library          String
Library          Collections
Library          DateTime
Library          taf.sbts.oam.coam.admin    WITH NAME    coam
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Common_setup_and_teardown.robot
Variables        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Variables        ../TestData/variables.py


*** Variables ***
# Symmetric computation tolerance (1%)
${SYMMETRIC_TOLERANCE}    ${0.01}


*** Keywords ***
DU_Uplane_Counter_Combined_Verification
    [Documentation]    Verifies eCPRI U-Plane & Fast-C-Plane counter values with and without L3 call
    ...    This keyword performs a complete verification flow with the following steps:
    ...    1. Get all BTS cell IDs
    ...    2. Modify eCPRI parameters via REST API
    ...    3. Wait for counter initialization and verify all cells are OnAir
    ...    4. Check M55318 counter values before L3 call
    ...    5. Perform L3 call traffic test if requested
    ...    6. Check M55318 counter values after L3 call
    [Arguments]    ${with_call}=${True}    ${with_peak}=${False}    ${duration}=900
    ...            ${upload_tp}=${True}    ${upload_duration}=${True}
    ...            ${ue_num_each_call}=1    ${suite_name}=default    ${test_name}=default

    # Step 1: Get all BTS Cell IDs and mapping for ru with cell IDs
    Get All BTS Cell IDs
    Get All RU Indexes And Cell Mappings

    # Step 2: Modify eCPRI parameters via REST API
    Modify Parameters Via Rest API    parameters_list=${ecpri_parameters_list}
    Perform BTS Site Reset And Wait Onair

    # Step 3: Wait 15 minutes and verify all cells are OnAir
    Sleep    15 minutes    reason=Waiting for counter initialization after parameter change
    Verify Cells Are OnAir And No Alarms

    # Get UE list for cells and set as test variable
    ${call_ue_index_list}    ${call_cell_list}=    Get UE List for Given Cell List
    ...    cell_list=${cell_list}
    ...    ue_num_each_call=${ue_num_each_call}

    Set Test Variable    ${call_cell_list}

    # Step 4: Check M55318 counter values before L3 call
    Check CB013355 Counters    with_call=${False}

    # Step 5: Perform L3 call traffic test for 15 minutes if requested
    Run Keyword If    ${with_call}    Run L3 Call Traffic Test
    ...    cell_list=${cell_list}
    ...    duration=${duration}
    ...    with_peak=${with_peak}
    ...    upload_tp=${upload_tp}
    ...    upload_duration=${upload_duration}
    ...    ue_num_each_call=${ue_num_each_call}
    ...    suite_name=${suite_name}
    ...    test_name=${test_name}

    # Step 6: Check M55318 counter values after L3 call
    Run Keyword If    ${with_call}    Check CB013355 Counters    with_call=${True}

Get All BTS Cell IDs
    [Documentation]    Gets all cell IDs from the BTS and sets them as a global variable
    ...                Returns the list of cell IDs for use in subsequent test steps

    ${cell_list}    Get All Cell Id
    Set Test Variable    ${cell_list}
    Log To Console    Found cell IDs: ${cell_list}

Modify Parameters Via Rest API
    [Documentation]    Modifies multiple parameters via REST API
    ...                Takes a list of parameters, replaces placeholder values with actual IDs,
    ...                and applies changes through COAM REST API interface
    [Arguments]    ${parameters_list}    ${timeout}=300    ${connection}=GNB_OAM

    Log To Console    \nModifying parameters via REST API
    # Create a copy of the parameters list to avoid modifying the original
    @{updated_params}    Create List

    # Process each parameter entry - replace NRBTS-ID with actual NRBTS-${NRBTS_ID}
    FOR    ${param}    IN    @{parameters_list}
        ${dist_name}    Get From Dictionary    ${param}    dist_name
        ${updated_dist_name}    Replace String    ${dist_name}    NRBTS-ID    NRBTS-${NRBTS_ID}

        ${parameter}    Get From Dictionary    ${param}    parameter
        ${value}    Get From Dictionary    ${param}    value

        ${updated_param}    Create Dictionary
        ...    dist_name=${updated_dist_name}
        ...    parameter=${parameter}
        ...    value=${value}

        Append To List    ${updated_params}    ${updated_param}
    END

    # Connect to gNB COAM
    Connect to gnb coam via ssl    connection=${connection}

    # Update parameters via REST API
    COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${updated_params}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    skip_parameter_relation_errors=${False}

    Log To Console    Parameters updated successfully

Verify Cells Are OnAir And No Alarms
    [Documentation]    Verifies all cells are OnAir and no unexpected alarms are present

    # Check all cells are OnAir
    Wait Until Keyword Succeeds    10 min    30 sec
    ...    Check all cells info should be onair

    # Check no unexpected alarms
    ${alarm_status}    Run Keyword And Return Status
    ...    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}    Unexpected alarms detected

    # Check no unexpected history alarms
    ${history_alarm_status}    Run Keyword And Return Status
    ...    Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    Should Be True    ${history_alarm_status}    Unexpected history alarms detected

Get Value For Multiple Counter IDs
    [Documentation]    Gets values for multiple counter IDs
    [Arguments]    ${counter_ids}    ${connection}=GNB_OAM

    Connect to gnb coam via ssl    connection=${connection}
    ${counters}    coam.get_pm_counters
    ...    counter_ids=${counter_ids}
    ...    connection=${connection}
    [Return]    ${counters}

Get Recent Value For Multiple Counter IDs
    [Documentation]    Gets the most recent values for multiple counter IDs
    ...                Optional index parameter allows fetching specific values instead of just the latest
    [Arguments]    ${counters}    ${index}=-1

    ${counter_values}    Create Dictionary
    ${counter_id_list}    Get Dictionary Keys    ${counters}

    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_data_dict}    Get From Dictionary    ${counters}    ${counter_id}
        ${counter_data_list}    Get Dictionary Values    ${counter_data_dict}
        ${value}    Get From List    ${counter_data_list}    ${index}
        Set To Dictionary    ${counter_values}    ${counter_id}    ${value}
    END

    [Return]    ${counter_values}

Run L3 Call Traffic Test
    [Documentation]    Performs L3 call traffic test for specified duration and checks peak traffic
    ...    Gets UEs from init file and makes call with specified parameters
    ...    Verifies traffic flow and throughput against expected values
    [Arguments]    ${cell_list}=${None}    ${with_peak}=${False}
    ...            ${duration}=300    ${upload_tp}=${True}    ${upload_duration}=${True}
    ...            ${ue_num_each_call}=1    ${suite_name}=default    ${test_name}=default

    Log To Console    \nStarting L3 call traffic test for ${duration} seconds

    # Run traffic test with throughput verification
    Get UE From Init File and Make call
    ...    cell_list=${cell_list}
    ...    ue_num_each_call=${ue_num_each_call}
    ...    duration=${duration}
    ...    with_peak=${with_peak}
    ...    upload_tp=${upload_tp}
    ...    upload_duration=${upload_duration}
    ...    suite_name=${suite_name}
    ...    test_name=${test_name}

    Log To Console    L3 call traffic test completed successfully

Check CB013355_B Counters
    [Documentation]    Checks M55318 counter values for CB013355_B feature
    ...                Verifies counter values meet expected criteria and compares values before/after traffic
    [Arguments]    ${with_call}=${False}    ${zero_counters}=${zero_counters_for_13355_b_08}
    ...    ${positive_counters}=${positive_counters_for_13355_b_08}

    Log To Console    \nChecking CB013355_B counters (with_call=${with_call})

    # Get counter values
    ${counters}    Get Value For Multiple Counter IDs    counter_ids=${counter_ids_for_13355_b}

    # Create dictionary to store counter values if not exists
    ${recent_counter_values_dict_exists}    Run Keyword And Return Status    Variable Should Exist    ${recent_counter_values_dict}
    Run Keyword If    not ${recent_counter_values_dict_exists}    Set Test Variable    ${recent_counter_values_dict}    Create Dictionary

    # Initialize storage dictionaries for with_call/without_call conditions
    ${with_call_dict_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${recent_counter_values_dict}    with_call
    ${without_call_dict_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${recent_counter_values_dict}    without_call

    Run Keyword If    not ${with_call_dict_exists}    Set To Dictionary    ${recent_counter_values_dict}    with_call    Create Dictionary
    Run Keyword If    not ${without_call_dict_exists}    Set To Dictionary    ${recent_counter_values_dict}    without_call    Create Dictionary

    # Check counters for each cell
    FOR    ${cell_id}    IN    @{cell_list}
        Log To Console    Checking counters for cell ${cell_id}

        # Get counters for current cell using path navigation
        ${counter_path}    Set Variable    BTS/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}/NECUP
        ${counter_key_list}    Split String    ${counter_path}    /

        # Navigate through nested dictionary using the keys
        ${current_dict}    Set Variable    ${counters}
        FOR    ${key}    IN    @{counter_key_list}
            ${current_dict}    Set Variable    ${current_dict['${key}']}
        END
        ${cell_counters}    Set Variable    ${current_dict}

        # Store counter values based on with_call condition
        # Get most recent counter values with different index based on with_call condition
        ${index_value}=    Set Variable If    ${with_call}    -2    -1
        ${cell_recent_counter}=    Get Recent Value For Multiple Counter IDs    counters=${cell_counters}    index=${index_value}

        Run Keyword If    ${with_call}
        ...    Set To Dictionary    ${recent_counter_values_dict}[with_call]    ${cell_id}    ${cell_recent_counter}
        ...    ELSE
        ...    Set To Dictionary    ${recent_counter_values_dict}[without_call]    ${cell_id}    ${cell_recent_counter}

        # Validation 1: Check counter value should meet specific rules at all timestamp
        Validate Counter Values    counters=${cell_counters}    zero_counters=${zero_counters}    positive_counters=${positive_counters}

        # Validation 2: Check counter value growth if with_call is True
        FOR    ${counter_id}    IN    @{positive_counters}
            Run Keyword If    ${with_call}
            ...    Check Single Counter Value Between Initial And Traffic
            ...    cell_id=${cell_id}    counter_id=${counter_id}
        END
    END

    Log To Console    CB013355_B counters validation passed

Check Single Counter Value Between Initial And Traffic
    [Documentation]    Verifies a single counter ID has increased by at least the expected rate after traffic
    ...                Compares counter values before and after traffic to ensure proper increase
    [Arguments]    ${cell_id}    ${counter_id}    ${rate}=0.5
    # Increase rate with 50% provided by gaofan.shi@nokia-sbell.com only, it's not the standard from official CFAM/CUDO
    IF    ${cell_id} not in ${call_cell_list}
        Log To Console    Cell ${cell_id} is not in call cell list: ${call_cell_list}, skipping counter verification for this cell
        RETURN
    END
    Log To Console    \nChecking counter ${counter_id} for cell ${cell_id} with expected growth rate ${rate}

    # Get counter values before and after traffic
    ${cell_counters_without_call}    Get From Dictionary    ${recent_counter_values_dict}[without_call]    ${cell_id}
    ${counter_without_call}    Get From Dictionary    ${cell_counters_without_call}    ${counter_id}

    ${cell_counters_with_call}    Get From Dictionary    ${recent_counter_values_dict}[with_call]    ${cell_id}
    ${counter_with_call}    Get From Dictionary    ${cell_counters_with_call}    ${counter_id}

    # Calculate expected minimum value after traffic
    ${expected_min_value}    Evaluate    ${counter_without_call} * (1 + ${rate})

    # Verify counter value has increased by at least the expected rate
    ${increase_msg}    Set Variable    Before: ${counter_without_call}, After: ${counter_with_call}, Expected after: > ${expected_min_value}
    Should Be True    ${counter_with_call} > ${expected_min_value}
    ...    msg=Counter ${counter_id} did not increase by expected rate. ${increase_msg}

    Log To Console    Counter ${counter_id} verification passed. Before: ${counter_without_call}, After: ${counter_with_call}

Validate Counter Values
    [Documentation]    Validates counter values according to specific rules
    ...                1. All counter IDs should have the same number of timestamps
    ...                2. M55318C00001/C00005/C00007/C00009 should be 0
    ...                3. M55318C00003/C00020/C00021/C00026 should be > 0
    ...                4. M55318C00003 + M55318C00005 + M55318C00007 = M55318C00026
    ...                5. M55318C00021 - M55318C00020 = M55318C00027
    [Arguments]    ${counters}    ${zero_counters}    ${positive_counters}

    Log To Console    \nValidating counter values...

    # Get all counter IDs
    ${counter_ids}    Get Dictionary Keys    ${counters}
    Log To Console    Found counter IDs: ${counter_ids}

    # Check timestamp consistency - get timestamp count from first counter
    ${first_counter_id}    Get From List    ${counter_ids}    0
    ${first_counter_data}    Get From Dictionary    ${counters}    ${first_counter_id}
    ${timestamps}    Get Dictionary Keys    ${first_counter_data}
    ${timestamp_count}    Get Length    ${timestamps}
    Log To Console    Timestamp count: ${timestamp_count}

    # Verify timestamp consistency and counter values
    FOR    ${counter_id}    IN    @{counter_ids}
        ${counter_data}    Get From Dictionary    ${counters}    ${counter_id}
        ${counter_timestamps}    Get Dictionary Keys    ${counter_data}
        ${counter_timestamp_count}    Get Length    ${counter_timestamps}

        # Verify timestamp count consistency
        Should Be Equal As Numbers    ${counter_timestamp_count}    ${timestamp_count}
        ...    msg=Counter ${counter_id} has ${counter_timestamp_count} timestamps, expected ${timestamp_count}

        # For each timestamp, verify the counter value
        FOR    ${timestamp}    IN    @{timestamps}
            ${value}    Get From Dictionary    ${counter_data}    ${timestamp}

            # Check if value should be zero
            ${is_zero_counter}    Run Keyword And Return Status    List Should Contain Value    ${zero_counters}    ${counter_id}
            Run Keyword If    ${is_zero_counter}    Should Be Equal As Numbers    ${value}    0
            ...    msg=Counter ${counter_id} at timestamp ${timestamp} should be 0 but got ${value}

            # Check if value should be positive
            ${is_positive_counter}    Run Keyword And Return Status    List Should Contain Value    ${positive_counters}    ${counter_id}
            Run Keyword If    ${is_positive_counter}    Should Be True    ${value} > 0
            ...    msg=Counter ${counter_id} at timestamp ${timestamp} should be greater than 0 but got ${value}
        END
    END

    # Verify formula 1: M55318C00003 + M55318C00005 + M55318C00007 = M55318C00026
    FOR    ${timestamp}    IN    @{timestamps}
        ${c00003_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counters}    M55318C00003
        ${c00005_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counters}    M55318C00005
        ${c00007_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counters}    M55318C00007
        ${c00026_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counters}    M55318C00026

        IF    ${c00003_exists} and ${c00005_exists} and ${c00007_exists} and ${c00026_exists}
            ${c00003_value}=    Get From Dictionary    ${counters['M55318C00003']}    ${timestamp}
            ${c00005_value}=    Get From Dictionary    ${counters['M55318C00005']}    ${timestamp}
            ${c00007_value}=    Get From Dictionary    ${counters['M55318C00007']}    ${timestamp}
            ${c00026_value}=    Get From Dictionary    ${counters['M55318C00026']}    ${timestamp}
            ${sum}=    Evaluate    ${c00003_value} + ${c00005_value} + ${c00007_value}
            ${sum_msg}    Set Variable    C00003(${c00003_value}) + C00005(${c00005_value}) + C00007(${c00007_value}) = ${sum}
            Should Be Equal As Numbers    ${sum}    ${c00026_value}
            ...    msg=At timestamp ${timestamp}: ${sum_msg}, expected ${c00026_value}
        END
    END

    # Verify formula 2: M55318C00021 - M55318C00020 = M55318C00027
    #FOR    ${timestamp}    IN    @{timestamps}
    #    ${c00020_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counters}    M55318C00020
    #    ${c00021_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counters}    M55318C00021
    #    ${c00027_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counters}    M55318C00027
    #
    #    IF    ${c00020_exists} and ${c00021_exists} and ${c00027_exists}
    #        ${c00020_value}=    Get From Dictionary    ${counters['M55318C00020']}    ${timestamp}
    #        ${c00021_value}=    Get From Dictionary    ${counters['M55318C00021']}    ${timestamp}
    #        ${c00027_value}=    Get From Dictionary    ${counters['M55318C00027']}    ${timestamp}
    #        ${diff}=    Evaluate    ${c00021_value} - ${c00020_value}
    #        ${diff    _msg}    Set Variable    C00021(${c00021_value}) - C00020(${c00020_value}) = ${diff}
    #        Should Be Equal As Numbers    ${diff}    ${c00027_value}
    #        ...    msg=At timestamp ${timestamp}: ${diff_msg}, expected ${c00027_value}
    #    END
    #END

    Log To Console    Counter validation completed successfully

DU_Counters_Fault_Cancellation_Test
    [Documentation]    Tests DU counters with fault 4706/4707 cancellation
    ...                This keyword performs the complete fault test workflow:
    ...                1. Get all cells
    ...                2. Configure parameters via REST API
    ...                3. Add test flags to swconfig file
    ...                4. Restart BTS to activate flags
    ...                5. Verify cells and check counters
    ...                6. Verify cells are Degraded with alarm 4707
    ...                7. Remove test flags
    ...                8. Restart BTS to cancel the fault condition
    &{fault_4707}     Create Dictionary     faultId=${4707}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_4707}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4707}
    Set Test Variable    ${ALLOWED_FAULT}
    Set Test Variable    ${ALLOWED_HISTORY_FAULT}

    # Step 1: Get all BTS Cell IDs
    Get All BTS Cell IDs

    # Step 2: Configure NIDD parameters via REST API
    Modify Parameters Via Rest API    parameters_list=${ecpri_parameters_list}

    # Step 3: Modify swconfig file to add test flags, restart BTS to activate flags
    Add Test Flags To Swconfig

    # Step 4: Wait for cells to be OnAir and check counters
    Sleep    10 minutes    reason=Waiting for counter initialization after parameter change
    Wait Until Keyword Succeeds    10 min    30 sec    Verify Cells Are OnAir With Allowed Alarms

    # Step 5: Check M55318 counter values before L3 call
    Check CB013355_B Counters    with_call=${False}    zero_counters=${zero_counters_for_13355_b_09}
    ...    positive_counters=${positive_counters_for_13355_b_09}

    # Step 6: Verify cells are in Degraded status with alarm 4707
    Verify Cells Have Degraded Status And Alarm 4707 Exists

Add Test Flags To Swconfig
    [Documentation]    Adds test flags to the swconfig file
    ...                This is used to trigger fault conditions for testing

    Log To Console    \nAdding test flags to swconfig file
    # Step 1: Modify swconfig file to add test flags
    Backup and Modify swconfig file    is_called_in_test_case_level=${True}    swconfig_modify=${test_flags}

    # Step 2: Restart BTS to activate flags
    Perform BTS Site Reset And Wait Onair

Remove Test Flags From Swconfig
    [Documentation]    Removes test flags from the swconfig file
    ...                This is used to cancel fault conditions

    Log To Console    \nRemoving test flags from swconfig file
    # Step 1: Modify swconfig file to remove test flags
    Restore Swconfig File

    # Step 2: Restart BTS to cancel the fault condition
    Perform BTS Site Reset And Wait Onair

Perform BTS Site Reset And Wait Onair
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}     ${timeout}=15min
    log    ${timeout}
    Connect to gnb coam via ssl    connection=${connection}   gnb_index=${gnb_index}
    coam.reset_site    connection=${connection}    timeout=${timeout}
    sleep    30s
    COAM Wait gnb And Cells ready    gnb_index=${gnb_index}    timeout=${timeout}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify Cells Are OnAir With Allowed Alarms
    [Documentation]    Verifies all cells are OnAir and only allowed alarms are present
    # Check all cells are OnAir
    Check all cells info should be onair

    # Check no unexpected alarms (only allowed ones exist)
    ${alarm_status}=    Run Keyword And Return Status
    ...    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}

    Should Be True    ${alarm_status}    Unexpected alarms detected

Verify Cells Have Degraded Status And Alarm 4707 Exists
    [Documentation]    Verifies all cells have Degraded availability status
    [Arguments]    ${fault_id}=4707

    Log To Console    \nVerifying cells have Degraded status
    Cell status Should Be Degraded    cell_list=${cell_list}
    Log To Console    All cells have Degraded status as expected

    # Check each cell's raise fault
    FOR    ${cell_id}    IN    @{cell_list}
        Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=${fault_id}    severity=Major
        ...    configObjectName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    END
    Log To Console    All cells have raised fault ${fault_id} as expected

Check CB013355 Counters
    [Documentation]    Checks M55318C&M55604C&M40022C counter values for CB013355 feature
    ...                Verifies counter values meet expected criteria and compares values before/after traffic
    [Arguments]    ${with_call}=${False}

    Log To Console    \nChecking CB013355 counters (with_call=${with_call})

    # Get counter values
    ${counters}    Get Value For Multiple Counter IDs    counter_ids=${counter_ids_for_13355}

    # Validate all RU counters for M55604C&M40022C
    ${validate_ru_result}    Run Keyword And Return Status    Validate All RU Counters    counters=${counters}

    # Validate all cell counters for M55318C
    ${validate_cell_result}    Run Keyword And Return Status    Validate M55318C Counters For All Cells
    ...    counters=${counters}    with_call=${with_call}

    # Validate all counters mapping for RU and cells
    ${validate_mapping_result}    Run Keyword And Return Status    Validate RU Cell Counter Relationships
    ...    counters=${counters}

    ${validate_result_list}    Create List    ${validate_ru_result}    ${validate_cell_result}    ${validate_mapping_result}
    ${msg}    Catenate    SEPARATOR=${SPACE}    Exist counter value check failed: ${validate_result_list},
    ...    the validating RU counters result is ${validate_ru_result},
    ...    the validating cell counters result is ${validate_cell_result},
    ...    the validating RU-Cell mapping counters result is ${validate_mapping_result}
    Run Keyword If    ${False} in ${validate_result_list}    Fail    msg=${msg}
    Log To Console    CB013355_B counters validation passed

Get All RU Indexes And Cell Mappings
    [Documentation]    Gets all RU indexes and establishes RU-Cell mapping relationships
    ...                Uses existing tribe common keywords for reliable RU discovery

    Log To Console    \nGetting all RU indexes and cell mappings

    # Get all RU indexes using existing tribe common keyword
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    Set Test Variable    ${ru_index_list}
    Log To Console    Found RU indexes: ${ru_index_list}

    # Create RU-Cell mapping for each RU
    &{ru_cell_mapping}    Create Dictionary
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${cells_for_ru}    Get All Cell Id    ru_index=${ru_index}    connection=GNB_OAM
        Set To Dictionary    ${ru_cell_mapping}    ${ru_index}    ${cells_for_ru}
        Log To Console    RU ${ru_index} maps to cells: ${cells_for_ru}
    END
    Set Test Variable    ${ru_cell_mapping}

Validate M55604C Counters For All RUs
    [Documentation]    Validates M55604C counter values for all RU modules
    ...                Checks ORTX measurement counters according to CB013355 requirements
    ...
    ...                Parameters:
    ...                - ru_counters_dict: Dictionary containing RU counter data {ru_index: counters}
    ...                - ru_index_list: List of RU indices to validate
    ...
    ...                Validation Rules:
    ...                - All counter IDs must have consistent timestamps
    ...                - M55604C00002/3/4/8/9 should equal 0
    ...                - M55604C00001/6/7 should be greater than 0
    [Arguments]    ${ru_counters_dict}    ${ru_index_list}    ${measurement_name}=M55604C

    Log To Console    \nValidating ${measurement_name} counters for all RUs

    FOR    ${ru_index}    IN    @{ru_index_list}
        Log To Console    Validating ${measurement_name} counters for RU ${ru_index}

        # Get pre-fetched counter data for this RU
        ${counters}    Get From Dictionary    ${ru_counters_dict}    ${ru_index}

        # Validate counter values according to requirements
        Validate Counter Consistency And Values
        ...    counters=${counters}
        ...    zero_counters=${m55604c_zero_counters}
        ...    positive_counters=${m55604c_positive_counters}
        ...    measurement_name=${measurement_name}
        ...    object_name=RU-${ru_index}

        Log To Console    ${measurement_name} validation passed for RU ${ru_index}
    END

    Log To Console    ${measurement_name} counter validation completed for all RUs

Validate M40022C Counters For All RUs
    [Documentation]    Validates M40022C counter values for all RU modules
    ...                Checks RURWS measurement counters according to CB013355 requirements
    ...
    ...                Parameters:
    ...                - ru_counters_dict: Dictionary containing RU counter data {ru_index: counters}
    ...                - ru_index_list: List of RU indices to validate
    ...
    ...                Validation Rules:
    ...                - M40022C0 should be greater than 0
    [Arguments]    ${ru_counters_dict}    ${ru_index_list}    ${measurement_name}=M40022C

    Log To Console    \nValidating ${measurement_name} counters for all RUs

    FOR    ${ru_index}    IN    @{ru_index_list}
        Log To Console    Validating ${measurement_name} counters for RU ${ru_index}

        # Get pre-fetched counter data for this RU
        ${counters}    Get From Dictionary    ${ru_counters_dict}    ${ru_index}

        # Validate ${measurement_name} counter values (should be > 0)
        Validate Counter Consistency And Values
        ...    counters=${counters}
        ...    zero_counters=${m40022c_zero_counters}
        ...    positive_counters=${m40022c_positive_counters}
        ...    measurement_name=${measurement_name}
        ...    object_name=RU-${ru_index}

        Log To Console    ${measurement_name} validation passed for RU ${ru_index}
    END

    Log To Console    M40022C counter validation completed for all RUs

Validate M55318C Counters For All Cells
    [Documentation]    Validates M55318C counter values for all cells
    ...                Checks NECUP measurement counters according to CB013355 requirements
    ...
    ...                Validation Rules:
    ...                - All counter IDs must have consistent timestamps
    ...                - M55318C00005/6/7/8/9/10/24/25 should equal 0
    ...                - M55318C00003/4/20/21/22/23/26/27 should be greater than 0
    ...                - Mathematical formulas must be satisfied
    [Arguments]    ${counters}    ${measurement_name}=M55318C    ${with_call}=${False}
    Log To Console    \nValidating ${measurement_name} counters for all cells

    # Create dictionary to store counter values if not exists
    ${recent_counter_values_dict_exists}    Run Keyword And Return Status    Variable Should Exist    ${recent_counter_values_dict}
    Run Keyword If    not ${recent_counter_values_dict_exists}    Set Test Variable    ${recent_counter_values_dict}    Create Dictionary

    # Initialize storage dictionaries for with_call/without_call conditions
    ${with_call_dict_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${recent_counter_values_dict}    with_call
    ${without_call_dict_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${recent_counter_values_dict}    without_call

    Run Keyword If    not ${with_call_dict_exists}    Set To Dictionary    ${recent_counter_values_dict}    with_call    Create Dictionary
    Run Keyword If    not ${without_call_dict_exists}    Set To Dictionary    ${recent_counter_values_dict}    without_call    Create Dictionary

    # Check counters for each cell
    FOR    ${cell_id}    IN    @{cell_list}
        Log To Console    Validating ${measurement_name} counters for cell ${cell_id}
        ${cell_counters}    Get Cell Counter Values    cell_id=${cell_id}    counters=${counters}    measurement=NECUP

        # Store counter values based on with_call condition
        # Get most recent counter values with different index based on with_call condition
        ${index_value}=    Set Variable If    ${with_call}    -2    -1
        ${cell_recent_counter}=    Get Recent Value For Multiple Counter IDs    counters=${cell_counters}    index=${index_value}

        Run Keyword If    ${with_call}
        ...    Set To Dictionary    ${recent_counter_values_dict}[with_call]    ${cell_id}    ${cell_recent_counter}
        ...    ELSE
        ...    Set To Dictionary    ${recent_counter_values_dict}[without_call]    ${cell_id}    ${cell_recent_counter}

        # Validate counter values according to requirements
        Validate Counter Consistency And Values
        ...    counters=${cell_counters}
        ...    zero_counters=${m55318c_zero_counters}
        ...    positive_counters=${m55318c_positive_counters}
        ...    measurement_name=${measurement_name}
        ...    object_name=CELL-${cell_id}

        # Validate counter value growth if with_call is True
        FOR    ${counter_id}    IN    @{m55318c_positive_counters}
            Run Keyword If    ${with_call}
            ...    Check Single Counter Value Between Initial And Traffic
            ...    cell_id=${cell_id}    counter_id=${counter_id}
        END

        # Validate mathematical formulas for ${measurement_name}
        Validate M55318C Mathematical Formulas    counters=${cell_counters}    cell_id=${cell_id}

        # For PR855230, symmetric computation validations for BBU and RRU is unexpected due to the start-time of DU and RU is not synced.
        IF    not ${with_call}
            Log To Console    Performing symmetric computation validations for cell ${cell_id}
            Perform Symmetric Computation Validations    counters=${cell_counters}    cell_id=${cell_id}
        ELSE
            Log To Console    Skipping symmetric computation validations for cell ${cell_id} (with_call=True)
        END

        Log To Console    ${measurement_name} validation passed for cell ${cell_id}
    END

    Log To Console    ${measurement_name} counter validation completed for all cells

Get Counter Values For Path
    [Documentation]    Gets counter values for specified counter IDs and path
    ...                Uses TAF COAM admin interface with REST API preference
    [Arguments]    ${counters}    ${counter_path}
    # Navigate to the specific measurement path
    ${path_keys}    Split String    ${counter_path}    /
    ${measurement_counters}    Set Variable    ${counters}

    FOR    ${key}    IN    @{path_keys}
        ${measurement_counters}    Get From Dictionary    ${measurement_counters}    ${key}
    END

    [Return]    ${measurement_counters}

Validate Counter Consistency And Values
    [Documentation]    Validates counter consistency and value requirements
    ...                Checks timestamp consistency and value constraints
    [Arguments]    ${counters}    ${zero_counters}    ${positive_counters}    ${measurement_name}    ${object_name}

    Log To Console    \nValidating ${measurement_name} counters for ${object_name}

    # Get all counter IDs
    ${counter_ids}    Get Dictionary Keys    ${counters}
    Log To Console    Found counter IDs: ${counter_ids}

    # Check timestamp consistency - get timestamp count from first counter
    ${timestamps}    Get Counter Timestamps    counters=${counters}
    ${timestamp_count}    Get Length    ${timestamps}
    Log To Console    Timestamp count: ${timestamp_count}

    # Verify timestamp consistency for all counters
    FOR    ${counter_id}    IN    @{counter_ids}
        ${counter_data}    Get From Dictionary    ${counters}    ${counter_id}
        ${counter_timestamps}    Get Dictionary Keys    ${counter_data}
        ${counter_timestamp_count}    Get Length    ${counter_timestamps}

        ${msg}    Catenate    SEPARATOR=${SPACE}    ${measurement_name} counter ${counter_id} has ${counter_timestamp_count} timestamps,
        ...    expected ${timestamp_count} for ${object_name}
        Should Be Equal As Numbers    ${counter_timestamp_count}    ${timestamp_count}    msg=${msg}
    END

    # Validate counter values for each timestamp
    FOR    ${timestamp}    IN    @{timestamps}
        FOR    ${counter_id}    IN    @{counter_ids}
            ${counter_data}    Get From Dictionary    ${counters}    ${counter_id}
            ${value}    Get From Dictionary    ${counter_data}    ${timestamp}

            # Check if counter should be zero
            ${is_zero_counter}    Run Keyword And Return Status    List Should Contain Value    ${zero_counters}    ${counter_id}
            Run Keyword If    ${is_zero_counter}    Should Be Equal As Numbers    ${value}    0
            ...    msg=${measurement_name} counter ${counter_id} at timestamp ${timestamp} should be 0 but got ${value} for ${object_name}

            # Check if counter should be positive
            ${is_positive_counter}    Run Keyword And Return Status    List Should Contain Value    ${positive_counters}    ${counter_id}
            ${msg}    Catenate    SEPARATOR=${SPACE}    ${measurement_name} counter ${counter_id} at timestamp ${timestamp}
            ...    should be greater than 0 but got ${value} for ${object_name}
            Run Keyword If    ${is_positive_counter}    Should Be True    ${value} > 0    msg=${msg}
        END
    END

    Log To Console    ${measurement_name} counter consistency and value validation passed for ${object_name}

Validate M55318C Mathematical Formulas
    [Documentation]    Validates mathematical formulas for M55318C counters
    ...                Checks specific mathematical relationships between counters
    [Arguments]    ${counters}    ${cell_id}

    Log To Console    \nValidating M55318C mathematical formulas for cell ${cell_id}

    # Get timestamps for validation
    ${timestamps}    Get Counter Timestamps    counters=${counters}

    # Validate mathematical formulas for each timestamp
    FOR    ${timestamp}    IN    @{timestamps}
        # Formula 1: M55318C00003 + M55318C00005 + M55318C00007 + M55318C00009 = M55318C00026
        ${c00003_value}    Get Counter Value At Timestamp    ${counters}    M55318C00003    ${timestamp}
        ${c00005_value}    Get Counter Value At Timestamp    ${counters}    M55318C00005    ${timestamp}
        ${c00007_value}    Get Counter Value At Timestamp    ${counters}    M55318C00007    ${timestamp}
        ${c00009_value}    Get Counter Value At Timestamp    ${counters}    M55318C00009    ${timestamp}
        ${c00026_value}    Get Counter Value At Timestamp    ${counters}    M55318C00026    ${timestamp}

        ${sum_formula1}    Evaluate    ${c00003_value} + ${c00005_value} + ${c00007_value} + ${c00009_value}
        ${msg}    Catenate    SEPARATOR=${SPACE}    Formula 1 failed for cell ${cell_id} at ${timestamp}:
        ...    ${c00003_value}+${c00005_value}+${c00007_value}+${c00009_value}=${sum_formula1}, expected ${c00026_value}
        Should Be Equal As Numbers    ${sum_formula1}    ${c00026_value}    msg=${msg}

        # Formula 2: M55318C00004 + M55318C00006 + M55318C00008 + M55318C00010 + M55318C00023 + M55318C00024 + M55318C00025 = M55318C00027
        ${c00004_value}    Get Counter Value At Timestamp    ${counters}    M55318C00004    ${timestamp}
        ${c00006_value}    Get Counter Value At Timestamp    ${counters}    M55318C00006    ${timestamp}
        ${c00008_value}    Get Counter Value At Timestamp    ${counters}    M55318C00008    ${timestamp}
        ${c00010_value}    Get Counter Value At Timestamp    ${counters}    M55318C00010    ${timestamp}
        ${c00023_value}    Get Counter Value At Timestamp    ${counters}    M55318C00023    ${timestamp}
        ${c00024_value}    Get Counter Value At Timestamp    ${counters}    M55318C00024    ${timestamp}
        ${c00025_value}    Get Counter Value At Timestamp    ${counters}    M55318C00025    ${timestamp}
        ${c00027_value}    Get Counter Value At Timestamp    ${counters}    M55318C00027    ${timestamp}

        ${sum_formula2}    Evaluate
        ...    ${c00004_value} + ${c00006_value} + ${c00008_value} + ${c00010_value} + ${c00023_value} + ${c00024_value} + ${c00025_value}
        ${msg}    Catenate    SEPARATOR=${SPACE}    Formula 2 failed for cell ${cell_id} at ${timestamp}:
        ...    ${c00004_value}+${c00006_value}+${c00008_value}+${c00010_value}+${c00023_value}+${c00024_value}+${c00025_value}=${sum_formula2},
        ...    expected ${c00027_value}
        Should Be Equal As Numbers    ${sum_formula2}    ${c00027_value}    msg=${msg}
    END

    Log To Console    M55318C mathematical formulas validation passed for cell ${cell_id}

Get Counter Value At Timestamp
    [Documentation]    Helper keyword to get counter value at specific timestamp
    [Arguments]    ${counters}    ${counter_id}    ${timestamp}

    ${counter_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counters}    ${counter_id}
    ${value}    Run Keyword If    ${counter_exists}
    ...    Get From Dictionary    ${counters}[${counter_id}]    ${timestamp}
    ...    ELSE    Set Variable    0

    [Return]    ${value}

Perform Symmetric Computation Validations
    [Documentation]    Performs symmetric computation validations with 1% tolerance
    ...                Validates specific percentage-based relationships between counters
    ...
    ...                Validation Rules (A=1%):
    ...                - M55318C00026 / M55318C00022 <= 100% ± A
    ...                - M55318C00020 / (M55318C00023 + M55318C00024 + M55318C00025) <= 100% ± A
    ...                - (M55318C00021 + M55318C00020) / (M55318C00004 + M55318C00006 + M55318C00008) <= 100% ± A
    ...                - M55318C00003 / M55318C00022 <= 100% ± A
    ...                - M55318C00027 / M55318C00021 <= 100% ± A
    [Arguments]    ${counters}    ${cell_id}    ${tolerance}=${0.01}
    ${tolerance}    Set Variable If    ${SYMMETRIC_TOLERANCE}    ${SYMMETRIC_TOLERANCE}    ${tolerance}
    Log To Console    \nPerforming symmetric computation validations with ${tolerance} tolerance for cell ${cell_id}

    # Get timestamps for validation
    ${timestamps}    Get Counter Timestamps    counters=${counters}

    FOR    ${timestamp}    IN    @{timestamps}
        # Validation 1: M55318C00026 / M55318C00022 <= 100% ± A
        Validate Symmetric Ratio
        ...    numerator_counter=M55318C00026
        ...    denominator_counter=M55318C00022
        ...    counters=${counters}
        ...    timestamp=${timestamp}
        ...    cell_id=${cell_id}
        ...    tolerance=${tolerance}

        # Validation 2: M55318C00020 / (M55318C00023 + M55318C00024 + M55318C00025) <= 100% ± A
        Validate Symmetric Ratio With Sum Denominator
        ...    numerator_counter=M55318C00020
        ...    denominator_counters=M55318C00023,M55318C00024,M55318C00025
        ...    counters=${counters}
        ...    timestamp=${timestamp}
        ...    cell_id=${cell_id}
        ...    tolerance=${tolerance}

        # Validation 3: (M55318C00021 - M55318C00020) / (M55318C00004 + M55318C00006 + M55318C00008) <= 100% ± A
        Validate Symmetric Ratio With Subtracted Numerator And Sum Denominator
        ...    numerator_counters=M55318C00021,M55318C00020
        ...    denominator_counters=M55318C00004,M55318C00006,M55318C00008
        ...    counters=${counters}
        ...    timestamp=${timestamp}
        ...    cell_id=${cell_id}
        ...    tolerance=${tolerance}

        # Validation 4: M55318C00003 / M55318C00022 <= 100% ± A
        Validate Symmetric Ratio
        ...    numerator_counter=M55318C00003
        ...    denominator_counter=M55318C00022
        ...    counters=${counters}
        ...    timestamp=${timestamp}
        ...    cell_id=${cell_id}
        ...    tolerance=${tolerance}

        # Validation 5: M55318C00027 / M55318C00021 <= 100% ± A
        Validate Symmetric Ratio
        ...    numerator_counter=M55318C00027
        ...    denominator_counter=M55318C00021
        ...    counters=${counters}
        ...    timestamp=${timestamp}
        ...    cell_id=${cell_id}
        ...    tolerance=${tolerance}
    END

    Log To Console    Symmetric computation validations passed for cell ${cell_id}

    # Log To Console    All symmetric computation validations completed successfully

Calculate Symmetric Ratio
    [Arguments]    ${numerator_value}    ${denominator_value}    ${tolerance}    ${cell_id}
    ...    ${timestamp}    ${numerator_counter}    ${denominator_counter}
    IF    ${denominator_value} == 0
        Log To Console    Skipping symmetric validation due to zero denominator: ${denominator_counter}=${denominator_value}
    END

    ${ratio}=    Evaluate    ${numerator_value} / ${denominator_value}
    ${upper_limit}=    Evaluate    1.0 + ${tolerance}
    ${lower_limit}=    Evaluate    1.0 - ${tolerance}
    ${msg}    Catenate    SEPARATOR=${SPACE}    Symmetric validation failed for cell ${cell_id} at ${timestamp}:
    ...    ${numerator_counter}(${numerator_value})/${denominator_counter}(${denominator_value})=${ratio}
    Should Be True    ${ratio} <= ${upper_limit}    msg=${msg}, should be <= ${upper_limit}
    Should Be True    ${ratio} >= ${lower_limit}    msg=${msg}, should be >= ${lower_limit}

Validate Symmetric Ratio
    [Documentation]    Validates simple ratio within tolerance
    [Arguments]    ${numerator_counter}    ${denominator_counter}    ${counters}    ${timestamp}    ${cell_id}    ${tolerance}

    ${numerator_value}    Get Counter Value At Timestamp    ${counters}    ${numerator_counter}    ${timestamp}
    ${denominator_value}    Get Counter Value At Timestamp    ${counters}    ${denominator_counter}    ${timestamp}

    Calculate Symmetric Ratio
    ...    numerator_value=${numerator_value}    denominator_value=${denominator_value}
    ...    tolerance=${tolerance}    cell_id=${cell_id}    timestamp=${timestamp}
    ...    numerator_counter=${numerator_counter}    denominator_counter=${denominator_counter}

Validate Symmetric Ratio With Sum Denominator
    [Documentation]    Validates ratio with sum of multiple counters as denominator
    [Arguments]    ${numerator_counter}    ${denominator_counters}    ${counters}    ${timestamp}    ${cell_id}    ${tolerance}

    ${numerator_value}    Get Counter Value At Timestamp    ${counters}    ${numerator_counter}    ${timestamp}

    ${denominator_sum}    Set Variable    0
    ${denominator_list}    Split String    ${denominator_counters}    ,
    FOR    ${counter}    IN    @{denominator_list}
        ${counter_value}    Get Counter Value At Timestamp    ${counters}    ${counter}    ${timestamp}
        ${denominator_sum}    Evaluate    ${denominator_sum} + ${counter_value}
    END

    Calculate Symmetric Ratio
    ...    numerator_value=${numerator_value}    denominator_value=${denominator_sum}
    ...    tolerance=${tolerance}    cell_id=${cell_id}    timestamp=${timestamp}
    ...    numerator_counter=${numerator_counter}    denominator_counter=${denominator_counters}

Validate Symmetric Ratio With Subtracted Numerator And Sum Denominator
    [Documentation]    Validates ratio with sum of multiple counters as both numerator and denominator
    [Arguments]    ${numerator_counters}    ${denominator_counters}    ${counters}    ${timestamp}    ${cell_id}    ${tolerance}

    ${numerator_result}    Set Variable    0
    ${numerator_list}    Split String    ${numerator_counters}    ,
    FOR    ${index}    ${counter}    IN ENUMERATE    @{numerator_list}
        ${counter_value}    Get Counter Value At Timestamp    ${counters}    ${counter}    ${timestamp}
        IF    ${index} == 0
            ${numerator_result}    Set Variable    ${counter_value}
        ELSE
            ${numerator_result}    Evaluate    ${numerator_result} - ${counter_value}
        END
    END

    ${denominator_sum}    Set Variable    0
    ${denominator_list}    Split String    ${denominator_counters}    ,
    FOR    ${counter}    IN    @{denominator_list}
        ${counter_value}    Get Counter Value At Timestamp    ${counters}    ${counter}    ${timestamp}
        ${denominator_sum}    Evaluate    ${denominator_sum} + ${counter_value}
    END

    Calculate Symmetric Ratio
    ...    numerator_value=${numerator_result}    denominator_value=${denominator_sum}
    ...    tolerance=${tolerance}    cell_id=${cell_id}    timestamp=${timestamp}
    ...    numerator_counter=${numerator_counters}    denominator_counter=${denominator_counters}

Validate All RU Counters
    [Documentation]    Validates M55604C and M40022C counter values for all RU modules
    ...                This keyword combines validation of both RU counter types
    ...                according to CB013355 requirements
    [Arguments]    ${counters}
    Log To Console    \nValidating all RU counters (M55604C and M40022C)

    # Get all RU indexes if not already available
    ${ru_index_list_exists}    Run Keyword And Return Status    Variable Should Exist    ${ru_index_list}
    Run Keyword If    not ${ru_index_list_exists}    Run Keywords
    ...    ${ru_index_list}    Get All RU Index    connection=${connection}
    ...    AND    Set Test Variable    ${ru_index_list}

    # Fetch M55604C counter data for all RUs
    &{ru_counters_m55604c}    Create Dictionary
    &{ru_counters_m40022c}    Create Dictionary
    FOR    ${ru_index}    IN    @{ru_index_list}
        # Get RU counter values for M55604C and M40022C
        ${single_object_counters_m55604c}    Get RU Counter Values
        ...    ru_index=${ru_index}    counters=${counters}    measurement=RURWS
        Set To Dictionary    ${ru_counters_m55604c}    ${ru_index}    ${single_object_counters_m55604c}
        ${single_object_counters_m40022c}    Get RU Counter Values
        ...    ru_index=${ru_index}    counters=${counters}    measurement=ORTX
        Set To Dictionary    ${ru_counters_m40022c}    ${ru_index}    ${single_object_counters_m40022c}
    END

    # Validate M55604C counters using pre-fetched data
    Validate M55604C Counters For All RUs
    ...    ru_counters_dict=${ru_counters_m55604c}    ru_index_list=${ru_index_list}

    # Validate M40022C counters using pre-fetched data
    Validate M40022C Counters For All RUs
    ...    ru_counters_dict=${ru_counters_m40022c}    ru_index_list=${ru_index_list}

    Log To Console    All RU counter validation completed successfully

Validate RU Cell Counter Relationships
    [Documentation]    Validates RU-Cell counter relationship summations
    ...                This keyword validates that RU counters equal the sum of their corresponding Cell counters
    ...                according to CB013355 requirements:
    ...
    ...                RU-Cell Counter Relationships:
    ...                Sum M55318C00004 = M55604C00001
    ...                Sum M55318C00006 = M55604C00002
    ...                Sum M55318C00008 = M55604C00003
    ...                Sum M55318C00010 = M55604C00004
    ...                Sum M55318C00027 = M55604C00006
    ...                Sum M55318C00022 = M40022C0
    ...                Sum M55318C00023 = M55604C00007
    ...                Sum M55318C00024 = M55604C00008
    ...                Sum M55318C00025 = M55604C00009
    [Arguments]    ${counters}    ${connection}=GNB_OAM
    Log To Console    \nValidating RU-Cell counter relationships

    # Get all RU indexes if not already available
    ${ru_index_list_exists}    Run Keyword And Return Status    Variable Should Exist    ${ru_index_list}
    Run Keyword If    not ${ru_index_list_exists}    Run Keywords
    ...    ${ru_index_list}    Get All RU Index    connection=${connection}
    ...    AND    Set Test Variable    ${ru_index_list}

    # Get all cell IDs if not already available
    ${cell_list_exists}    Run Keyword And Return Status    Variable Should Exist    ${cell_list}
    Run Keyword If    not ${cell_list_exists}    Run Keywords
    ...    ${cell_list}    Get All Cell Id    connection=${connection}
    ...    AND    Set Test Variable    ${cell_list}

    # Validate relationships for each RU
    FOR    ${ru_index}    IN    @{ru_index_list}
        Log To Console    Validating RU-Cell relationships for RU ${ru_index}

        # Get cells mapped to this RU
        ${cells_for_ru}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        Log To Console    RU ${ru_index} is mapped to cells: ${cells_for_ru}

        # Get RU counter values for M55604C and M40022C
        ${ru_counters_m55604c}    Get RU Counter Values
        ...    ru_index=${ru_index}    counters=${counters}    measurement=RURWS
        ${ru_counters_m40022c}    Get RU Counter Values
        ...    ru_index=${ru_index}    counters=${counters}    measurement=ORTX

        # Get cell counter values for M55318C
        &{cell_counters_dict}    Create Dictionary
        FOR    ${cell_id}    IN    @{cells_for_ru}
            ${cell_counters}    Get Cell Counter Values
            ...    cell_id=${cell_id}    counters=${counters}    measurement=NECUP
            Set To Dictionary    ${cell_counters_dict}    ${cell_id}    ${cell_counters}
        END

        # Validate each RU-Cell relationship
        Validate Single RU Cell Relationship
        ...    ru_index=${ru_index}
        ...    cells_for_ru=${cells_for_ru}
        ...    ru_counters_m55604c=${ru_counters_m55604c}
        ...    ru_counters_m40022c=${ru_counters_m40022c}
        ...    cell_counters_dict=${cell_counters_dict}

        Log To Console    RU-Cell relationship validation passed for RU ${ru_index}
    END

    Log To Console    All RU-Cell counter relationship validations completed successfully

Get RU Counter Values
    [Documentation]    Gets counter values for a specific RU and measurement
    [Arguments]    ${ru_index}    ${counters}    ${measurement}

    ${counter_path}    Set Variable    BTS/MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/${measurement}
    ${counter_values}    Get Counter Values For Path    counters=${counters}    counter_path=${counter_path}
    ${counter_values}    Process Counter Data And Convert Timestamp    ${counter_values}
    [Return]    ${counter_values}

Get Cell Counter Values
    [Documentation]    Gets counter values for a specific cell
    [Arguments]    ${cell_id}    ${counters}    ${measurement}=NECUP

    ${counter_path}    Set Variable    BTS/MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}/${measurement}
    ${counter_values}    Get Counter Values For Path    counters=${counters}    counter_path=${counter_path}
    ${counter_values}    Process Counter Data And Convert Timestamp    ${counter_values}
    [Return]    ${counter_values}

Process Counter Data And Convert Timestamp
    [Documentation]    Removes the first timestamp data entry for each counter id and converts timestamp format
    [Arguments]    ${counters}

    # Create new dictionary to store processed data
    ${processed_counters}    Create Dictionary

    # Get all counter IDs
    ${counter_ids}    Get Dictionary Keys    ${counters}

    FOR    ${counter_id}    IN    @{counter_ids}
        Log To Console    \nProcessing counter: ${counter_id}

        # Get timestamp data for current counter
        ${timestamp_data}    Get From Dictionary    ${counters}    ${counter_id}

        # Get all timestamps and sort them (ensure chronological order)
        ${timestamps}    Get Dictionary Keys    ${timestamp_data}
        ${sorted_timestamps}    Evaluate    sorted([int(ts) for ts in $timestamps])

        # Create new dictionary to store processed timestamp data (excluding first entry)
        ${new_timestamp_data}    Create Dictionary

        # Skip first timestamp, process remaining data
        ${timestamps_to_process}    Get Slice From List    ${sorted_timestamps}    1

        FOR    ${timestamp}    IN    @{timestamps_to_process}
            # Convert timestamp format
            ${formatted_timestamp}    Convert Unix Timestamp To Datetime String    ${timestamp}

            # Get corresponding counter value (need to convert to string to match dictionary key)
            ${timestamp_str}    Convert To String    ${timestamp}
            ${counter_value}    Get From Dictionary    ${timestamp_data}    ${timestamp_str}

            # Add to new dictionary
            Set To Dictionary    ${new_timestamp_data}    ${formatted_timestamp}=${counter_value}

            Log To Console    \tTimestamp: ${timestamp} -> ${formatted_timestamp}, Value: ${counter_value}
        END

        # Add processed data to result dictionary
        Set To Dictionary    ${processed_counters}    ${counter_id}=${new_timestamp_data}
    END

    RETURN    ${processed_counters}

Convert Unix Timestamp To Datetime String
    [Documentation]    Converts Unix timestamp to formatted datetime string
    [Arguments]    ${unix_timestamp}

    # Convert timestamp to datetime object, then format to specified format
    ${datetime_string}    Evaluate    datetime.datetime.fromtimestamp(${unix_timestamp}).strftime("%Y-%m-%d %H:%M:%S")    modules=datetime

    RETURN    ${datetime_string}

Get Counter Timestamps
    [Documentation]    Gets timestamps from the first available counter in the provided counters dictionary
    [Arguments]    ${counters}
    # Get all counter IDs
    ${counter_ids}    Get Dictionary Keys    ${counters}
    Log To Console    Found counter IDs: ${counter_ids}
    # Get timestamps from the first counter
    ${first_counter_id}    Get From List    ${counter_ids}    0
    # Get timestamps for validation
    ${first_counter_data}    Get From Dictionary    ${counters}    ${first_counter_id}
    ${timestamps}    Get Dictionary Keys    ${first_counter_data}
    [Return]    ${timestamps}

Validate Single RU Cell Relationship
    [Documentation]    Validates RU-Cell counter relationships for a single RU
    [Arguments]    ${ru_index}    ${cells_for_ru}    ${ru_counters_m55604c}    ${ru_counters_m40022c}    ${cell_counters_dict}

    Log To Console    \nValidating RU-Cell relationships for RU ${ru_index}

    # Get timestamps from the first available counter
    ${timestamps}    Get Counter Timestamps    counters=${ru_counters_m55604c}

    # Define RU-Cell counter mapping relationships
    &{ru_cell_counter_id_mapping}    Create Dictionary
    ...    M55604C00001=M55318C00004
    ...    M55604C00002=M55318C00006
    ...    M55604C00003=M55318C00008
    ...    M55604C00004=M55318C00010
    ...    M55604C00006=M55318C00027
    ...    M55604C00007=M55318C00023
    ...    M55604C00008=M55318C00024
    ...    M55604C00009=M55318C00025

    # Validate M55604C to M55318C relationships
    FOR    ${timestamp}    IN    @{timestamps}
        FOR    ${ru_counter}    ${cell_counter}    IN    &{ru_cell_counter_id_mapping}
            # Get RU counter value
            ${ru_value}    Get Counter Value At Timestamp    ${ru_counters_m55604c}    ${ru_counter}    ${timestamp}

            # Calculate sum of corresponding cell counter values
            ${cell_sum}    Set Variable    0
            FOR    ${cell_id}    IN    @{cells_for_ru}
                ${cell_counters}    Get From Dictionary    ${cell_counters_dict}    ${cell_id}
                ${cell_value}    Get Counter Value At Timestamp    ${cell_counters}    ${cell_counter}    ${timestamp}
                ${cell_sum}    Evaluate    ${cell_sum} + ${cell_value}
            END

            # Validate relationship: Sum M55318C = M55604C
            ${msg}    Catenate    SEPARATOR=${SPACE}    RU-Cell relationship failed for RU ${ru_index} at ${timestamp}:
            ...    Sum of ${cell_counter} from cells ${cells_for_ru} = ${cell_sum}, but ${ru_counter} = ${ru_value}
            Should Be Equal As Numbers    ${cell_sum}    ${ru_value}    msg=${msg}

            ${debug_log}    Catenate    SEPARATOR=${SPACE}    Relationship validated: Sum ${cell_counter}(${cell_sum})
            ...    = ${ru_counter}(${ru_value}) for RU ${ru_index} at ${timestamp}
            Log To Console    ${debug_log}
        END

        # Validate M40022C0 to M55318C00022 relationship
        ${ru_m40022c_value}    Get Counter Value At Timestamp    ${ru_counters_m40022c}    M40022C0    ${timestamp}

        ${cell_m55318c00022_sum}    Set Variable    0
        FOR    ${cell_id}    IN    @{cells_for_ru}
            ${cell_counters}    Get From Dictionary    ${cell_counters_dict}    ${cell_id}
            ${cell_value}    Get Counter Value At Timestamp    ${cell_counters}    M55318C00022    ${timestamp}
            ${cell_m55318c00022_sum}    Evaluate    ${cell_m55318c00022_sum} + ${cell_value}
        END

        # Validate relationship: Sum M55318C00022 = M40022C0
        ${msg}    Catenate    SEPARATOR=${SPACE}    RU-Cell relationship failed for RU ${ru_index} at ${timestamp}:
        ...    Sum of M55318C00022 from cells ${cells_for_ru} = ${cell_m55318c00022_sum}, but M40022C0 = ${ru_m40022c_value}

        Should Be Equal As Numbers    ${cell_m55318c00022_sum}    ${ru_m40022c_value}    msg=${msg}

        ${debug_log}    Catenate    SEPARATOR=${SPACE}    Relationship validated: Sum M55318C00022(${cell_m55318c00022_sum})
        ...    = M40022C0(${ru_m40022c_value}) for RU ${ru_index} at ${timestamp}
        Log To Console    ${debug_log}
    END

    Log To Console    All RU-Cell relationships validated successfully for RU ${ru_index}
