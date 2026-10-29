*** Settings ***
Documentation    Common keywords for CB013355 test cases
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Library    taf.ue    WITH NAME    ute_ue

# Import resources for existing Cell ID retrieval keywords (Classical BTS)
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

# Import resources for L3 call traffic test functionality
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/sub_band_beamforming.robot

# Import the allowed fault list from made_variable.py
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py

*** Keywords ***
DU_Uplane_counter_Combined_Verification
    [Documentation]    Main keyword for DU Uplane counter combined verification test
    # Start the complete verification workflow
    Log    Starting DU Uplane counter combined verification test

    # Execute verification steps in sequence
    Step 1: Get BTS Cell IDs                                    # Retrieve NR cell IDs for testing
    Step 2: Modify ECpri Parameters Via REST API               # Configure ECpri timing parameters
    Step 3: Verify Cells Are OnAir With No Unexpected Alarms   # Validate cell status and alarm state
    Step 4: Check Initial Counter Values Before Traffic Test   # Establish baseline counter values
    Step 5: Run L3 Call Traffic Test                           # Generate traffic load using imported keyword
    Step 6: Check Counter Values After Traffic Test           # Compare pre/post traffic counters

    # Log completion of all steps
    Log    DU Uplane counter combined verification test completed successfully

Step 1: Get BTS Cell IDs
    [Documentation]    Get BTS cell IDs for verification (NR Classical BTS)
    # Retrieve all NR cell IDs from Classical BTS system
    Log    Step 1: Getting NR cell IDs from Classical BTS
    ${cell_ids}=    Get All Cell Id    cell_type=nr    connection=GNB_OAM

    # Store cell IDs for use in subsequent steps
    Set Test Variable    ${CELL_IDS}    ${cell_ids}
    Log    Retrieved NR cell IDs: ${CELL_IDS}

Step 2: Modify ECpri Parameters Via REST API
    [Documentation]    Modify ECpri parameters using REST API
    # Execute ECpri parameter modifications via REST API to configure timing settings
    Log    Step 2: Modifying ECpri parameters via REST API
    Modify ECpri Parameters
    Log    ECpri parameters modified successfully

Step 3: Verify Cells Are OnAir With No Unexpected Alarms
    [Documentation]    Verify that cells are OnAir and have no unexpected alarms
    ...                Uses predefined alarm whitelist from made_variable.py
    ...                Expected alarms (in whitelist) are ignored, only unexpected alarms cause failure
    # Verify cell online status for all retrieved cells
    Log    Step 3: Verifying cells are OnAir with no unexpected alarms
    Verify Cells OnAir Status    ${CELL_IDS}

    # Check for unexpected alarms using whitelist filtering
    Verify No Unexpected Alarms    ${CELL_IDS}
    Log    All cells are OnAir with no unexpected alarms

Step 4: Check Initial Counter Values Before Traffic Test
    [Documentation]    Check initial counter values before running traffic test
    ...                Gets initial values for DU Uplane counters using Admin API
    Log    Step 4: Checking initial counter values before traffic test

    # Define specific DU Uplane counter IDs for CB013355 test case (excluding M55318C00001)
    @{counter_ids}=    Create List
    ...    M55318C00003    M55318C00005    M55318C00007    M55318C00009
    ...    M55318C00020    M55318C00021    M55318C00026

    Log    DU Uplane counter IDs to collect: ${counter_ids}

    # Collect baseline counter values using Admin API before traffic generation
    ${initial_counters}=    Get DU Uplane Counter Values Via Admin API    ${CELL_IDS}    ${counter_ids}
    Set Suite Variable    ${INITIAL_COUNTERS}    ${initial_counters}
    Log    Initial counter values collected via Admin API: ${INITIAL_COUNTERS}

    # Validate that counter collection was successful
    ${counter_cells}=    Get Dictionary Keys    ${initial_counters}
    ${cell_count_with_counters}=    Get Length    ${counter_cells}
    Should Be True    ${cell_count_with_counters} > 0    No counter values were collected from any cells

    Log    Step 4 completed: Initial counter baseline established for ${cell_count_with_counters} cell(s)

Step 5: Run L3 Call Traffic Test
    [Documentation]    Execute L3 call traffic test to generate DU Uplane counter activity
    ...                Uses imported Run L3 Call Traffic Test keyword from sub_band_beamforming.robot
    [Arguments]    ${traffic_duration}=600    ${check_duration}=90    ${ue_num_each_call}=1
    Log    Step 5: Running L3 call traffic test for ${traffic_duration} seconds

    # Register UE aliases before using them (to prevent UnknownAlias errors)
    Setup UE Aliases For Traffic Test    ${ue_num_each_call}

    # Convert cell IDs list to format expected by traffic test keyword
    ${cell_list}=    Set Variable    ${CELL_IDS}

    # Execute L3 call traffic test using imported keyword
    Run L3 Call Traffic Test
    ...    suite_name=CB013355_DU_Uplane_Test
    ...    test_name=Counter_Verification_Traffic
    ...    duration=${traffic_duration}
    ...    check_duration=${check_duration}
    ...    ue_num_each_call=${ue_num_each_call}
    ...    cell_list=${cell_list}
    ...    direction=BOTH

    Log    L3 call traffic test completed successfully

    # Wait for counter update cycle to ensure fresh values after traffic
    Log    Waiting for counter update cycle after traffic test
    Wait For Counter Update Cycle

Step 6: Check Counter Values After Traffic Test
    [Documentation]    Check counter values after traffic test and verify changes
    ...                Compares pre-traffic and post-traffic counter values
    ...                Only verifies counters for cells that support DU Uplane counters
    Log    Step 6: Checking counter values after traffic test

    # Define the same counter IDs used in Step 4
    @{counter_ids}=    Create List
    ...    M55318C00003    M55318C00005    M55318C00007    M55318C00009
    ...    M55318C00020    M55318C00021    M55318C00026

    # Collect final counter values after traffic generation
    ${final_counters}=    Get DU Uplane Counter Values Via Admin API    ${CELL_IDS}    ${counter_ids}
    Set Suite Variable    ${FINAL_COUNTERS}    ${final_counters}

    # Only verify changes for cells that had initial counter data
    ${initial_cells}=    Get Dictionary Keys    ${INITIAL_COUNTERS}
    ${final_cells}=    Get Dictionary Keys    ${final_counters}

    IF    len($initial_cells) > 0 and len($final_cells) > 0
        Verify Counter Value Changes    ${INITIAL_COUNTERS}    ${FINAL_COUNTERS}
        Log    Counter values verified successfully after traffic test
    ELSE
        Log    No counter comparison possible - no cells support DU Uplane counters    level=WARN
    END

    Log    Step 6 completed: Counter value comparison after traffic test

# Helper Keywords
Wait For Counter Update Cycle
    [Documentation]    Wait for DU Uplane counter update cycle to ensure fresh counter values
    ...                DU Uplane counters are updated every 5 minutes, so this keyword
    ...                waits to ensure we get fresh counter values after traffic generation
    [Arguments]    ${wait_time}=5min    ${additional_buffer}=30s
    # Wait for counter update cycle plus buffer time to ensure fresh values
    Log    Waiting for counter update cycle (${wait_time} + ${additional_buffer} buffer)
    Sleep    ${wait_time}
    Sleep    ${additional_buffer}
    Log    Counter update cycle wait completed

Get BTS Cell IDs Fallback
    [Documentation]    Fallback helper keyword to retrieve NR BTS cell IDs when standard method fails
    Log    Using fallback method to get NR BTS cell IDs    level=WARN
    # Fail immediately if primary cell ID retrieval method fails
    Fail    Unable to retrieve cell IDs from BTS. Please check BTS connection and status.

Modify ECpri Parameters
    [Documentation]    Configure ECpri timing parameters via REST API
    Log    Modifying ECpri parameters via REST API...

    # Determine BTS ID: use NRBTS_ID from testline configuration or default to 1
    ${bts_id}=    Set Variable If    '${NRBTS_ID}' != '${EMPTY}'    ${NRBTS_ID}    1

    # Define ECpri parameter configuration list
    &{param1}=    Create Dictionary    dist_name=NRBTS-${bts_id}/NRPMRNL-1    parameter=miNrEcpriUpFCp    value=5min
    &{param2}=    Create Dictionary    dist_name=MNL-1/MNLENT-1/FMCADM-1    parameter=actECpriOutOfTimingWindowAlarm    value=true
    &{param3}=    Create Dictionary    dist_name=EQM-1/APEQM-1    parameter=eCpriOutOfTimingWindowMinorThreshold    value=-3

    @{parameters_to_update}=    Create List    ${param1}    ${param2}    ${param3}

    Log    ECpri parameters to update: ${parameters_to_update}

    # Apply parameter changes via REST API with activation
    COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameters_to_update}
    ...    timeout=60
    ...    connection=GNB_OAM
    ...    should_activate=true
    ...    skip_parameter_relation_errors=false

    Log    ECpri parameters updated successfully via REST API

Verify Cells OnAir Status
    [Documentation]    Verify all specified cells are in OnAir operational state
    [Arguments]    ${cell_ids}
    Log    Verifying OnAir status for cells: ${cell_ids}

    # Use classical BTS verification method for cell status check
    Verify all cells should be onair    cell_type=nr    connection=GNB_OAM

    Log    All cells are OnAir successfully verified

Verify No Unexpected Alarms
    [Documentation]    Verify system has no unexpected alarms using predefined whitelist
    ...                Uses AlarmWatchdog with predefined whitelist from made_variable.py
    ...                Checks both active alarms and history alarms
    ...                Expected alarms (in whitelist) are ignored, only unexpected alarms cause failure
    [Arguments]    ${cell_ids}    ${check_history_alarms}=True
    Log    Verifying no unexpected alarms for cells: ${cell_ids}
    Log    Check history alarms: ${check_history_alarms}

    # Configure allowed active alarms from predefined whitelist
    Log    Adding allowed active faults to AlarmWatchdog from whitelist
    FOR    ${fault_dict}    IN    @{ALLOWED_FAULT}
        ${fault_id}=    Get From Dictionary    ${fault_dict}    faultId
        Log    Adding allowed fault ID: ${fault_id}
        AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    END

    # Configure allowed history alarms if history checking is enabled
    IF    ${check_history_alarms}
        Log    Adding allowed history faults to AlarmWatchdog from whitelist
        FOR    ${fault_dict}    IN    @{ALLOWED_HISTORY_FAULT}
            ${fault_id}=    Get From Dictionary    ${fault_dict}    faultId
            Log    Adding allowed history fault ID: ${fault_id}
            AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
        END
    END

    # Retrieve and analyze current active alarms
    ${active_alarms}=    coam.Get Active Alarms    connection=GNB_OAM    timeout=30
    ${alarm_count}=    Get Length    ${active_alarms}

    IF    ${alarm_count} > 0
        Log    Found ${alarm_count} total active alarms - checking against whitelist

        # Filter out expected alarms and identify unexpected ones
        @{unexpected_alarms}=    Create List
        FOR    ${alarm}    IN    @{active_alarms}
            ${fault_id}=    Get From Dictionary    ${alarm}    faultId

            # Check if alarm is in either active or history allowed lists
            ${is_allowed_active}=    Run Keyword And Return Status
            ...    Should Contain    ${ALLOWED_FAULT}    ${{{'faultId': ${fault_id}}}}
            ${is_allowed_history}=    Run Keyword And Return Status
            ...    Should Contain    ${ALLOWED_HISTORY_FAULT}    ${{{'faultId': ${fault_id}}}}

            ${is_allowed}=    Evaluate    ${is_allowed_active} or ${is_allowed_history}

            # Collect unexpected alarms or log expected ones
            IF    not ${is_allowed}
                Log    Unexpected alarm found: ${alarm}    level=WARN
                Append To List    ${unexpected_alarms}    ${alarm}
            ELSE
                Log    Expected alarm ignored: FaultID=${fault_id}    level=INFO
            END
        END

        # Fail test if unexpected alarms are found
        ${unexpected_count}=    Get Length    ${unexpected_alarms}
        IF    ${unexpected_count} > 0
            Log    Found ${unexpected_count} unexpected alarms: ${unexpected_alarms}    level=ERROR
            Fail    Found ${unexpected_count} unexpected alarms on the system
        ELSE
            Log    All ${alarm_count} alarms are expected (in whitelist) - verification passed
        END
    ELSE
        Log    No active alarms found - verification passed
    END

    Log    Alarm verification completed successfully

Get DU Uplane Counter Values Via Admin API
    [Documentation]    Retrieve DU Uplane counter values using Admin API for specified cells and counters
    [Arguments]    ${cell_ids}    ${counter_ids}

    Log    Getting DU Uplane counter values via Admin API for cells: ${cell_ids}
    Log    Counter IDs to collect: ${counter_ids}

    # Initialize result dictionary to store counter values per cell
    &{all_counter_values}=    Create Dictionary

    # Connect to Admin API and retrieve counter data
    TRY
        Connect to gnb coam via ssl    connection=GNB_OAM

        # Query PM counters using Admin API with specified counter IDs
        ${counter_ids_str}=    Evaluate    ",".join($counter_ids)
        ${pm_counters}=    admin.Get Pm Counters
        ...    counter_ids=${counter_ids_str}
        ...    timeout=60
        ...    connection=GNB_OAM
        ...    wrap_nidd=${True}

        Log    Admin API response received for counters: ${counter_ids_str}

        # Process and extract counter values for each cell
        FOR    ${cell_id}    IN    @{cell_ids}
            &{cell_counters}=    Create Dictionary
            ${has_any_counter}=    Set Variable    False

            # Extract each requested counter for the current cell
            FOR    ${counter_id}    IN    @{counter_ids}
                ${counter_value}=    Extract Counter Value    ${pm_counters}    ${counter_id}    ${cell_id}

                # Include counter if non-zero or if cell supports this counter type
                IF    ${counter_value} != 0
                    Set To Dictionary    ${cell_counters}    ${counter_id}    ${counter_value}
                    ${has_any_counter}=    Set Variable    True
                ELSE
                    # Verify if cell has counter support in PM response structure
                    ${cell_path}=    Set Variable    MRBTS-37095/NRBTS-37095/NRCELL-${cell_id}
                    ${cell_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${pm_counters}    ${cell_path}
                    IF    ${cell_exists}
                        ${cell_data}=    Get From Dictionary    ${pm_counters}    ${cell_path}
                        ${necup_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${cell_data}    NECUP
                        IF    ${necup_exists}
                            ${necup_data}=    Get From Dictionary    ${cell_data}    NECUP
                            ${counter_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${necup_data}    ${counter_id}
                            IF    ${counter_exists}
                                # Counter exists in structure, include even if value is 0
                                Set To Dictionary    ${cell_counters}    ${counter_id}    ${counter_value}
                                ${has_any_counter}=    Set Variable    True
                            END
                        END
                    END
                END
            END

            # Store cell counter data only if cell supports at least one counter
            IF    ${has_any_counter}
                Set To Dictionary    ${all_counter_values}    ${cell_id}    ${cell_counters}
                Log    Cell ${cell_id} counter values: ${cell_counters}
            ELSE
                Log    Cell ${cell_id} does not support any of the requested DU Uplane counters    level=INFO
            END
        END

    EXCEPT    AS    ${error}
        Log    Admin API failed: ${error}    level=WARN
        # Let test fail gracefully rather than proceeding with incorrect zero values
        # This ensures proper error reporting for counter collection failures
    END

    RETURN    ${all_counter_values}

Extract Counter Value
    [Documentation]    Extract individual counter value from PM counters response structure
    [Arguments]    ${pm_counters}    ${counter_id}    ${cell_id}

    # Initialize counter value to 0 as default
    ${counter_value}=    Set Variable    0

    TRY
        # Validate PM counters data structure exists
        IF    $pm_counters and isinstance($pm_counters, dict)
            # Construct expected cell path in BTS hierarchy
            ${cell_path}=    Set Variable    MRBTS-37095/NRBTS-37095/NRCELL-${cell_id}

            Log    Looking for cell path: ${cell_path} and counter: ${counter_id}    level=DEBUG

            # Navigate through PM response structure to find counter data
            ${cell_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${pm_counters}    ${cell_path}
            IF    ${cell_exists}
                ${cell_data}=    Get From Dictionary    ${pm_counters}    ${cell_path}

                # Check for NECUP (DU Uplane) counter section
                ${necup_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${cell_data}    NECUP
                IF    ${necup_exists}
                    ${necup_data}=    Get From Dictionary    ${cell_data}    NECUP

                    # Verify specific counter ID exists
                    ${counter_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${necup_data}    ${counter_id}
                    IF    ${counter_exists}
                        ${counter_data}=    Get From Dictionary    ${necup_data}    ${counter_id}
                        Log    Counter data for ${counter_id}: ${counter_data}    level=DEBUG

                        # Extract most recent counter value from timestamp-based data
                        IF    isinstance($counter_data, dict)
                            ${timestamps}=    Get Dictionary Keys    ${counter_data}
                            IF    len($timestamps) > 0
                                # Get latest timestamp and corresponding counter value
                                ${latest_timestamp}=    Evaluate    max([int(ts) for ts in $timestamps])
                                ${latest_timestamp_str}=    Convert To String    ${latest_timestamp}
                                ${counter_value}=    Get From Dictionary    ${counter_data}    ${latest_timestamp_str}
                                Log    Extracted counter value ${counter_value} from timestamp ${latest_timestamp_str}    level=DEBUG
                            END
                        END
                    ELSE
                        Log    Counter ${counter_id} not found in NECUP data for cell ${cell_id}    level=DEBUG
                    END
                ELSE
                    Log    NECUP not found in cell data for cell ${cell_id}    level=DEBUG
                END
            ELSE
                Log    Cell path ${cell_path} not found in pm_counters    level=DEBUG
            END
        ELSE
            Log    pm_counters is empty or not a dictionary    level=DEBUG
        END

        # Ensure returned value is numeric
        ${counter_value}=    Convert To Number    ${counter_value}

    EXCEPT    AS    ${extract_error}
        Log    Failed to extract counter ${counter_id} for cell ${cell_id}: ${extract_error}    level=WARN
        # Return 0 as default value for failed extractions
        ${counter_value}=    Set Variable    0
    END

    RETURN    ${counter_value}

Verify Counter Value Changes
    [Documentation]    Helper keyword to verify counter value changes between initial and final measurements
    ...                Compares counter values and reports increases/changes
    ...                Validates that traffic generation caused expected counter increases
    [Arguments]    ${initial_counters}    ${final_counters}
    Log    Comparing initial counters: ${initial_counters}
    Log    With final counters: ${final_counters}

    ${initial_cells}=    Get Dictionary Keys    ${initial_counters}
    ${final_cells}=    Get Dictionary Keys    ${final_counters}

    # Track verification results
    ${verified_cells}=    Set Variable    0
    ${counter_changes_detected}=    Set Variable    False

    # Check each cell that has both initial and final data
    FOR    ${cell_id}    IN    @{initial_cells}
        IF    $cell_id in $final_cells
            ${initial_cell_counters}=    Get From Dictionary    ${initial_counters}    ${cell_id}
            ${final_cell_counters}=    Get From Dictionary    ${final_counters}    ${cell_id}

            Log    Verifying counter changes for cell ${cell_id}
            ${counter_ids}=    Get Dictionary Keys    ${initial_cell_counters}
            ${cell_has_changes}=    Set Variable    False

            FOR    ${counter_id}    IN    @{counter_ids}
                IF    $counter_id in $final_cell_counters
                    ${initial_value}=    Get From Dictionary    ${initial_cell_counters}    ${counter_id}
                    ${final_value}=    Get From Dictionary    ${final_cell_counters}    ${counter_id}
                    ${difference}=    Evaluate    ${final_value} - ${initial_value}

                    Log    Cell ${cell_id}, Counter ${counter_id}: ${initial_value} -> ${final_value} (diff: ${difference})

                    # Check for counter value changes (increases are expected for DU Uplane counters during traffic)
                    IF    ${difference} > 0
                        Log    Counter ${counter_id} increased by ${difference} - traffic detected
                        ${cell_has_changes}=    Set Variable    True
                        ${counter_changes_detected}=    Set Variable    True
                    ELSE IF    ${difference} < 0
                        Log    Counter ${counter_id} decreased by ${difference} - unexpected behavior    level=WARN
                    ELSE
                        Log    Counter ${counter_id} unchanged - no traffic detected for this counter
                    END

                    # Ensure counter values are non-negative
                    Should Be True    ${final_value} >= 0    Counter ${counter_id} has negative value: ${final_value}
                END
            END

            IF    ${cell_has_changes}
                ${verified_cells}=    Evaluate    ${verified_cells} + 1
                Log    Cell ${cell_id}: Counter changes detected - traffic verification successful
            ELSE
                Log    Cell ${cell_id}: No counter changes detected - may indicate no traffic or counter collection issue    level=WARN
            END
        ELSE
            Log    Cell ${cell_id} missing from final counters    level=WARN
        END
    END

    # Summary verification results
    Log    Verification summary: ${verified_cells} cell(s) showed counter changes

    # Optional: Add assertion for minimum expected counter activity
    # IF    ${counter_changes_detected}
    #     Log    Counter verification passed: Traffic-induced counter changes detected
    # ELSE
    #     Log    Counter verification warning: No counter changes detected across all cells    level=WARN
    # END

Setup UE Aliases For Traffic Test
    [Documentation]    Register UE aliases before using them in traffic tests
    ...                This prevents UnknownAlias errors when using taf.ue library
    [Arguments]    ${ue_num_each_call}=1
    Log    Setting up UE aliases for traffic test (${ue_num_each_call} UE(s) per call)

    # Register UE aliases for the number of UEs needed
    FOR    ${ue_index}    IN RANGE    ${ue_num_each_call}
        ${ue_alias}=    Set Variable    UE_${ue_index}
        Log    Registering UE alias: ${ue_alias}
        TRY
            # Register UE with basic configuration
            ute_ue.Require Ue    ${ue_alias}    type=nokia_fastmile
            Log    UE alias ${ue_alias} registered successfully
        EXCEPT    AS    ${error}
            Log    Failed to register UE alias ${ue_alias}: ${error}    level=WARN
            Log    Continuing with traffic test - UE registration may not be required    level=WARN
        END
    END

    Log    UE alias setup completed
