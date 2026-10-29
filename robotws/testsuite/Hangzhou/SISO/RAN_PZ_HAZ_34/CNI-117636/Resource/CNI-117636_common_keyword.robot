*** Settings ***
Documentation    Common keywords for CNI-117636 test cases
...              All the keywords are designed for fault 4598 testing

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/loop_prach.robot
Variables   ${CURDIR}/../TestData/variables.py
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_gnb_classical.py

Library     Collections
Library     String
Library     DateTime


*** Keywords ***
Trigger_Fault_4598_By_Modify_Cell_TiltOffset_Parameter
    [Documentation]    Modifies cell TiltOffset parameter to trigger fault 4598
    ...
    ...               Steps:
    ...               1. Get all BTS cell IDs
    ...               2. Configure frame structure for all cells
    ...               3. Configure mMIMO_muting parameters via REST API
    ...               4. Verify all cells are OnAir with no alarms
    ...               5. Test fault 4598 trigger and clear for each beamSet
    [Arguments]    ${prach_index_list}    ${band}=${None}    ${frame_structure}=${None}
    ...            ${ru_index}=${None}    ${fault_id}=4598

    # Step 1: Get all BTS cell IDs
    ${cell_list}=    Get_All_BTS_Cell_IDs    ru_index=${ru_index}

    # Make cell_list available to other keywords in the same test
    Set Test Variable    ${cell_list}

    # Step 2: Configure frame structure if specified
    Run Keyword If    '${frame_structure}' != '${None}'    Modify_Frame_Structure_Via_Rest_API
    ...    prach_index_list=${prach_index_list}
    ...    band=${band}
    ...    frame_structure=${frame_structure}

    # Step 3: Configure mMIMO_muting parameters via REST API
    ${muting_params_list}=    Generate_Rest_Parameters_For_MIMO_Muting    ${muting_parameters_dict}
    Modify_Parameters_Via_Rest_API    parameters_list=${muting_params_list}

    # Step 4: Verify cells are OnAir with no alarms
    &{case_fault}     Create Dictionary     faultId=${fault_id}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${case_fault}
    Set Test Variable    ${ALLOWED_HISTORY_FAULT}
    Verify_Cells_Are_OnAir_And_No_Alarms

    # Step 5: Test fault 4598 trigger and clear
    Test_Fault_Trigger_And_Clear    fault_id=${fault_id}

Get_All_BTS_Cell_IDs
    [Documentation]    Retrieves all BTS cell IDs from the system
    ...               Returns a list of cell identifiers for further operations
    [Arguments]    ${ru_index}=${None}

    ${cell_list}=    Get All Cell Id    ru_index=${ru_index}
    [Return]    ${cell_list}

Test_Fault_Trigger_And_Clear
    [Documentation]    Tests fault trigger and clear for each beamSet in the beamset_list
    ...               This keyword supports testing different fault IDs by passing the fault ID as a parameter
    [Arguments]    ${connection}=GNB_OAM    ${fault_id}=4598

    # Get cell index to nrCellIdentity mapping
    ${cell_mapping}=    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ...    connection_alias=${connection}

    # Make cell_mapping available to other keywords in the same test
    Set Test Variable    ${cell_mapping}

    # Get beamSet list from fault parameters dictionary
    ${beamset_list}=    Set Variable    ${fault_parameters_dict["beamset_list"]}

    # Test each beamSet
    FOR    ${beamset}    IN    @{beamset_list}
        Log    Testing beamSet: ${beamset}

        # Get trigger and clear parameters for this beamSet
        ${trigger_params}=    Set Variable    ${fault_parameters_dict["${beamset}"]["trigger_fault"]}
        ${clear_params}=    Set Variable    ${fault_parameters_dict["${beamset}"]["clear_fault"]}

        # Generate and apply parameters to trigger fault
        ${trigger_params_list}=    Generate_Rest_Parameters_For_Beamset
        ...    beamset_parameters_dict=${trigger_params}

        Modify_Parameters_Via_Rest_API    parameters_list=${trigger_params_list}

        # Verify fault is triggered
        Wait Until Keyword Succeeds    10 min    30 sec    Expect Fault Should Present    faultId=${fault_id}

        # Generate and apply parameters to clear fault
        ${clear_params_list}=    Generate_Rest_Parameters_For_Beamset
        ...    beamset_parameters_dict=${clear_params}

        Modify_Parameters_Via_Rest_API    parameters_list=${clear_params_list}

        # Verify fault is cleared
        Wait Until Keyword Succeeds    10 min    30 sec    Expect Fault Should Absent    faultId=${fault_id}
    END

Modify_Parameters_Via_Rest_API
    [Documentation]    Modifies base station parameters online via REST API
    ...               Establishes a secure connection to gNB COAM and updates specified parameters
    [Arguments]    ${parameters_list}    ${timeout}=${300}    ${connection}=GNB_OAM

    # Connect to gNB COAM
    Connect to gnb coam via ssl

    # Update parameters via REST API
    COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameters_list}
    ...    skip_parameter_relation_errors=${False}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Sleep    60

Verify_Cells_Are_OnAir_And_No_Alarms
    [Documentation]    Verifies all cells are in OnAir state with no unexpected alarms
    ...               Fails if cells are not OnAir or if unexpected alarms are present

    # Check all cells are OnAir
    Wait Until Keyword Succeeds    10 min    30 sec    Check all cells info should be onair

    # Check for unexpected alarms
    ${alarm_status}=    Run Keyword And Return Status    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}    Unexpected alarms detected

    # Check for unexpected history alarms
    ${history_alarm_status}=    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}
    Should Be True    ${history_alarm_status}    Unexpected history alarms detected

Modify_Frame_Structure_Via_Rest_API
    [Documentation]    Modifies frame structure parameters via REST API
    ...               Retrieves a random PRACH index from the provided list
    ...               and calls the Modify Frame Structure via recommission keyword
    [Arguments]    ${prach_index_list}    ${band}=${None}    ${frame_structure}=${None}    ${connection}=GNB_OAM

    # Get a random PRACH index from the list
    ${list_length}=    Get Length    ${prach_index_list}
    ${random_index}=    Evaluate    random.randint(0, ${list_length}-1)    random
    ${prach_index}=    Get From List    ${prach_index_list}    ${random_index}

    # Log the selected PRACH index
    Log    Selected PRACH index: ${prach_index}

    # Modify frame structure using the selected PRACH index
    Modify Frame Structure via recommission
    ...    prach_index=${prach_index}
    ...    band=${band}
    ...    frame_structure=${frame_structure}
    ...    connection=${connection}

Generate_Rest_Parameters_For_MIMO_Muting
    [Documentation]    Generates REST API parameter list for MIMO muting configuration
    ...               Processes NRBTS and NRPGRP parameters and adds appropriate dist_name
    [Arguments]    ${muting_parameters_dict}

    # Initialize parameters list
    @{modify_params_list}=    Create List

    # Process NRBTS parameters
    ${nrbts_parameters_list}=    Run Keyword If    'nrbts' in ${muting_parameters_dict}
    ...    Get From Dictionary    ${muting_parameters_dict}    nrbts
    ...    ELSE    Create List
    FOR    ${param_dict}    IN    @{nrbts_parameters_list}
        ${new_param_dict}=    Copy Dictionary    ${param_dict}
        Set To Dictionary    ${new_param_dict}    dist_name    NRBTS-${NRBTS_ID}
        Append To List    ${modify_params_list}    ${new_param_dict}
    END

    # Process CELLGRP parameters
    ${cellgrp_parameters_list}=    Run Keyword If    'cellgrp' in ${muting_parameters_dict}
    ...    Get From Dictionary    ${muting_parameters_dict}    cellgrp
    ...    ELSE    Create List
    FOR    ${param_dict}    IN    @{cellgrp_parameters_list}
        ${new_param_dict}=    Copy Dictionary    ${param_dict}
        Set To Dictionary    ${new_param_dict}    dist_name    NRBTS-${NRBTS_ID}/NRPGRP-1
        Append To List    ${modify_params_list}    ${new_param_dict}
    END

    # Return processed parameters list
    [Return]    ${modify_params_list}

Generate_Rest_Parameters_For_Beamset
    [Documentation]    Generates REST API parameter list for Beamset configuration
    ...               Processes NRCELL and NRCELLGRP parameters and adds appropriate dist_name
    [Arguments]    ${beamset_parameters_dict}

    # Initialize parameters list
    @{modify_params_list}=    Create List

    # Extract NRCELL and NRCELLGRP parameters
    ${nrcell_parameters_list}=    Run Keyword If    'nrcell' in ${beamset_parameters_dict}
    ...    Get From Dictionary    ${beamset_parameters_dict}    nrcell
    ...    ELSE    Create List
    ${nrcellgrp_parameters_list}=    Run Keyword If    'nrcellgrp' in ${beamset_parameters_dict}
    ...    Get From Dictionary    ${beamset_parameters_dict}    nrcellgrp
    ...    ELSE    Create List

    # Process each cell
    FOR    ${cell}    IN    @{cell_list}
        # Generate cell dist_name
        ${cell_dist_name}=    Set Variable    NRBTS-${NRBTS_ID}/NRCELL-${cell}

        # Process NRCELL parameters
        FOR    ${param_dict}    IN    @{nrcell_parameters_list}
            ${new_param_dict}=    Copy Dictionary    ${param_dict}
            Set To Dictionary    ${new_param_dict}    dist_name    ${cell_dist_name}
            Append To List    ${modify_params_list}    ${new_param_dict}
        END

        # Get cell group ID - 使用完整的关键字名称避免名称冲突
        ${cell_group_id}=    CNI-117636_common_keyword.Get_CellGroupID_Via_CellID    cell_id=${cell}

        # Generate cell group dist_name
        ${cellgrp_dist_name}=    Set Variable    NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_group_id}

        # Process NRCELLGRP parameters
        FOR    ${param_dict}    IN    @{nrcellgrp_parameters_list}
            ${new_param_dict}=    Copy Dictionary    ${param_dict}
            Set To Dictionary    ${new_param_dict}    dist_name    ${cellgrp_dist_name}
            Append To List    ${modify_params_list}    ${new_param_dict}
        END
    END

    # Return processed parameters list
    [Return]    ${modify_params_list}

Get_CellGroupID_Via_CellID
    [Documentation]    Retrieves cell group ID using cell ID
    ...               Extracts the cell group ID from the cell_mapping dictionary
    [Arguments]    ${cell_id}

    # Convert cell_id to integer
    ${cell_id_int}=    Convert To Integer    ${cell_id}

    # Get cell parameters from mapping
    ${cell_parameters_dict}=    Get From Dictionary    ${cell_mapping}    ${cell_id_int}

    # Extract cell group ID
    ${cell_group_index}=    Get From Dictionary    ${cell_parameters_dict}    cell_group_id

    # Return cell group ID
    [Return]    ${cell_group_index}
