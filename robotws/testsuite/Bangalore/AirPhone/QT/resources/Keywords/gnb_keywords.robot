*** Settings ***
Documentation    This contains basic wts related keywords which are needed to run the Airphone TC.

Library    DateTime
Library    OperatingSystem
Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    ../../../AP_P1/Resources/Python/DeltaStore.py    WITH NAME    delta_store
Library    ../../../AP_P1/Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Library    ${CURDIR}/../ute/python_keywords.py


*** Variables ***
&{NRDRB_LIST_PARAMS_DEFAULT}        nsa3xBearerAllowed=true    dlDataSplitMode=dlOverF1U    ulDataPath=ulOverNr
    ...    initialDLTrafficRouting=initDLoverX2U    actPrioritizeX2AfterInactivity=true    dlDataSplitBufferBuildUpThreshold=5
    ...    dlDataSplitBufferBuildUpThresholdPrioritizeX2=5    dlDataSplitGainThreshold=5    inactivityThresholdForPrioritizeX2=300
    ...    inactivityThresholdForRestartPrioritizeX2=100    prioritizeX2Period=500    ulDataSplitThreshold=infinity
    ...    actX2DuplicateTxNSA3x=false    dlNumOfCongOrGainDdds=2

*** Keywords ***
Recommission GNB With Delta
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    admin.Setup admin
    admin.Perform Delta Recommissioning    delta_file=${delta_file}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}   timeout=${timeout}
    [Teardown]    admin.Teardown admin

Set BTS ID and DIST_NAME
    ${gnb_bts_id}    admin_helper.get bts id
    Set Global Variable    ${BTS_ID}    ${gnb_bts_id}
    Set Global Variable    ${NRBTS_DISTNAME}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    Set Global Variable    ${NRCELL1_DISTNAME}    ${NRBTS_DISTNAME}/NRCELL-1
    Set Global Variable    ${NRCELL2_DISTNAME}    ${NRBTS_DISTNAME}/NRCELL-2

Update NRDRB profile
    [Documentation]    This keyword is used to update the NRDRB profile.This keyword will add the parameters to the
    ...                delta store. This keyword needs to be followed with "Recommission GNB With Delta" to commission the gnb.
    ...                 Modified Date: 03-Sept-2020
    ...                 Last Modified by: merin.varghese@nokia.com
    [Arguments]    ${dist_name}    &{kwargs}
    ${nsadrb_list_params}     ${nrdrb_params}    _Segregate parameters categorized under list type For NRDRB Profile    &{kwargs}
    _Update NRDRB profile non list type parameters    ${dist_name}    ${nrdrb_params}
    _Update NRDRB profile list type parameters     ${dist_name}    ${nsadrb_list_params}

_Segregate parameters categorized under list type For NRDRB Profile
    [Documentation]    Internal keyword, not to be used outside.
    ...                 Modified Date: 03-Sept-2020
    ...                 Last Modified by: merin.varghese@nokia.com
    [Arguments]    &{kwargs}
    &{nsadrb_list_params}    create dictionary
    &{nrdrb_params}    create dictionary
    FOR    ${key}    IN    @{kwargs.keys()}
        ${status}    run keyword and return status    dictionary should contain key    ${NRDRB_LIST_PARAMS_DEFAULT}    ${key}
        run keyword if    ${status}    set to dictionary    ${nsadrb_list_params}    ${key}    ${kwargs["${key}"]}
        ...    ELSE    set to dictionary    ${nrdrb_params}    ${key}    ${kwargs["${key}"]}
    END
    [Return]    ${nsadrb_list_params}     ${nrdrb_params}

_Update NRDRB profile non list type parameters
    [Documentation]    Internal keyword, not to be used outside.
    ...                 Modified Date: 03-Sept-2020
    ...                 Last Modified by: merin.varghese@nokia.com
    [Arguments]    ${dist_name}    ${nrdrb_params}
    delta_store.update managed object and parameter to delta    dist_name=${dist_name}    &{nrdrb_params}

_Update NRDRB profile list type parameters
    [Documentation]    Internal keyword, not to be used outside.
    ...                 Modified Date: 03-Sept-2020
    ...                 Last Modified by: merin.varghese@nokia.com
    [Arguments]    ${dist_name}    ${nsadrb_list_params}
    FOR    ${key_in_nsadrb_list_params}    IN    @{nsadrb_list_params.keys()}
        Set To Dictionary    ${NRDRB_LIST_PARAMS_DEFAULT}    ${key_in_nsadrb_list_params}
        ...    ${nsadrb_list_params["${key_in_nsadrb_list_params}"]}
    END
    delta_store.add_list_parameters_to_delta    dist_name=${dist_name}    list_name=nsaDrbParam    &{NRDRB_LIST_PARAMS_DEFAULT}

Perform RU Lock and Unlock for Classical gNB
    [Documentation]    Performs RU Lock and Unlock
    [Arguments]    ${alias}=cOAM
    ${NUMBER_OF_RUs}    Get number of RUs
    Set Test Variable    ${NUMBER_OF_RUs}
    Log To Console    Number of RUs:${NUMBER_OF_RUs}
    Log To Console    RU lock started
    Lock_RU    ${alias}
    Log To Console    RU Locked
    Sleep    10s
    Log To Console    RU Unlock started
    Unlock_RU    ${alias}
    Sleep    180s
    Log To Console    RU unlocked

Get number of RUs
    Get Coam SCF
    scf.load_scf  file_path=${coamSCF}
    ${RU_List}    scf.get_all_dist_names_of_specific_class   com.nokia.srbts.eqm:RMOD
    Set Test Variable    ${RU_List}
    ${RU_count}=    Get length    ${RU_List}
    [return]    ${RU_count}

Lock_RU
    [Arguments]         ${alias}
    admin.connect to   bts_host=${GNB_BTS_IP}
    ...               bts_port=443  name=${alias}
    ${scf_content}=    admin.get_current_scf_content    connection=${alias}    timeout=${30}
    ${RU_count}    Get length    ${RU_List}
    ${RU_count}    Evaluate    ${NUMBER_OF_RUs}-1
    Log To Console    Going To Lock only ${RU_count} RUs
    FOR    ${RU_index}    IN RANGE    ${NUMBER_OF_RUs}-1
        ${RU_dist}    Set Variable    ${RU_List}[${RU_index}]
        admin.Perform Parameter Recommissioning        dist_name=${RU_dist}    connection=${alias}
        ...          parameter=administrativeState
        ...          operation=update
        ...          value=Locked
        ...          skip_parameter_relation_errors=True
        ...          timeout=100
        ...          should_activate=True
        Log To Console    ${RU_dist} locked
    END
    [Teardown]    admin.teardown    connection=${alias}

Unlock_RU
    [Arguments]      ${alias}
    admin.connect to   bts_host=${GNB_BTS_IP}
    ...               bts_port=443  name=${alias}
    FOR    ${RU_index}    IN RANGE    ${NUMBER_OF_RUs}-1
        ${RU_dist}    Set Variable    ${RU_List}[${RU_index}]
        admin.Perform Parameter Recommissioning        dist_name=${RU_dist}    connection=${alias}
        ...          parameter=administrativeState
        ...          operation=update
        ...          value=Unlocked
        ...          skip_parameter_relation_errors=True
        ...          timeout=100
        ...          should_activate=True
        Log To Console     ${RU_dist} unlocked
    END
    [Teardown]    admin.teardown    connection=${alias}

Perform Cell Block Unblock for Classical gNB
    [Documentation]    Performs Cell block and Unblock for Classical gNB
    ...                Modified Date: 01-Sep-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    [Arguments]    ${alias}=cOAM
    Get Cell Info and Distname
    Log To Console    Cell block Operation started
    Cell Block Operation on gNB Classical    ${alias}
    Log To Console    Cell Blocked
    Sleep    10s
    Log To Console    Cell Unblock started
    Cell Unblock Operation on gNB Classical    ${alias}
    Sleep    60s
    Log To Console    Cell Unblock finished

Get Cell Info and Distname
    Get Coam SCF
    scf.load_scf  file_path=${coamSCF}
    ${Cell_List}    scf.get_all_dist_names_of_specific_class   com.nokia.srbts.nrbts:NRCELL
    ${Cell_Count}    Get Length    ${Cell_List}
    Set Test Variable    ${Cell_List}
    Set Test Variable    ${Cell_Count}

Cell Block Operation on gNB Classical
    [Arguments]      ${alias}
    admin.connect to   bts_host=${GNB_BTS_IP}
    ...               bts_port=443  name=${alias}
    FOR    ${Cell_index}    IN RANGE    ${Cell_Count}-1
        ${Cell_dist}    Set Variable    ${Cell_List}[${Cell_index}]
        admin.block_cell    dist_name=${Cell_dist}    timeout=300    detailed_output=True    connection=${alias}
        Sleep    10s
        ${cell_info}   admin.get_cells_info    connection=${alias}
        ${cell_status}    python_keywords.get_cell_blocking_state    ${cell_info}    ${Cell_dist}
        Should Be Equal As Strings    ${cell_status}    Blocked    ignore_case=${TRUE}
        Log To Console     ${Cell_dist} Blocked
    END
    [Teardown]    admin.teardown    connection=${alias}

Cell Unblock Operation on gNB Classical
    [Arguments]    ${alias}
    admin.connect to   bts_host=${GNB_BTS_IP}
    ...               bts_port=443  name=${alias}
    FOR    ${Cell_index}    IN RANGE    ${Cell_Count}-1
        ${Cell_dist}    Set Variable    ${Cell_List}[${Cell_index}]
        admin.unblock_cell    dist_name=${Cell_dist}    timeout=300    detailed_output=True    connection=${alias}
        Sleep    10s
        ${cell_info}   admin.get_cells_info    connection=${alias}
        ${cell_status}    python_keywords.get_cell_blocking_state    ${cell_info}    ${Cell_dist}
        Should Be Equal As Strings    ${cell_status}    Unblocked    ignore_case=${TRUE}
        Log To Console     ${Cell_dist} Unblocked
    END
    [Teardown]    admin.teardown    connection=${alias}

Perform Soft Cell Reset via Param Update for Classical gNB
    Cell Delete and setup via param update
    Sleep    30s
    ${new_component_carrier}    Evaluate    ${component_carrier}-1
    Run Keyword If    ${component_carrier} > 1    Set Test Variable    ${component_carrier}    ${new_component_carrier}
    AP Cell Setup should be Successful for multiple cellsetup    count=2
    Revert Param Value For Cell Setup
    Sleep    30s
    AP Cell Setup should be Successful for multiple cellsetup    count=3
    Return From Keyword If    ${component_carrier} == 1
    ${new_component_carrier}    Evaluate    ${component_carrier}+1
    Run Keyword If    ${component_carrier} > 1    Set Test Variable    ${component_carrier}    ${new_component_carrier}

Cell Delete and setup via param update
    [Arguments]    ${alias}=cOAM
    Get Cell Info and Distname
    @{param_list}    Create List    dlMimoMode
    admin.connect to   bts_host=${GNB_BTS_IP}
    ...               bts_port=443  name=${alias}
    ${Cell_Count}    Set Variable If    ${Cell_Count} > 1    ${Cell_Count-1}    ${Cell_Count}
    Log To Console     CellCountToDelete:${Cell_Count}
    @{restore_cell_value}    Create List
    FOR    ${Cell_index}    IN RANGE    ${Cell_Count}
        ${Cell_dist}    Set Variable    ${Cell_List}[${Cell_index}]
        ${cur_value}    admin.get_parameter_by_distname    dist_name=${Cell_dist}    parameter_list=${param_list}
        ...    timeout=180    connection=${alias}
        Append To List    ${restore_cell_value}    ${cur_value}[0][parameters][dlMimoMode]
        ${param_value}    Set Variable    ${cur_value}[0][parameters][dlMimoMode]
        ${new_value}    Evaluate
        ...    "${param_value}".replace("Closed", "Open") if "Closed" in "${param_value}" else "${param_value}".replace("Open", "Closed")
        admin.Perform Parameter Recommissioning        dist_name=${Cell_dist}    connection=${alias}
        ...          parameter=dlMimoMode
        ...          operation=update
        ...          value=${new_value}
        ...          skip_parameter_relation_errors=True
        ...          timeout=180
        ...          should_activate=True
        Log To Console     Cell ${Cell_index+1} Deleted and setup via dlMimoMode param update
    END
    Set Test Variable    ${restore_cell_value}
    [Teardown]    admin.teardown    connection=${alias}

Revert Param Value For Cell Setup
    [Arguments]    ${alias}=cOAM
    admin.connect to   bts_host=${GNB_BTS_IP}
    ...               bts_port=443  name=${alias}
    delta_store.initialise_delta_store
    ${Cell_Count}    Set Variable If    ${Cell_Count} > 1    ${Cell_Count-1}    ${Cell_Count}
    FOR    ${Cell_index}    IN RANGE    ${Cell_Count}
        ${Cell_dist}    Set Variable    ${Cell_List}[${Cell_index}]
        delta_store.add_param_to_delta    dist_name=${Cell_dist}    param_name=dlMimoMode
        ...    value=${restore_cell_value}[${Cell_index}]
    END
    ${delta_value}    delta_store.collect_delta_store
    admin.Perform Delta Recommissioning    delta_file=${delta_value}    skip_parameter_relation_errors=True
    ...    should_activate=True   timeout=300    connection=${alias}
    [Teardown]    admin.teardown    connection=${alias}
