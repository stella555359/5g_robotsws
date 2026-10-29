*** Settings ***
Documentation    Cloud parameters keywords.
...              Authors:    Patryk Tatarek, Jagoda Kubacka
...              Contact:    patryk.tatarek@nokia.com, jagoda.kubacka@nokia.com

Resource    ../connections/connections.robot
Resource    taf/rfrl/cbts/robot/vcu/vcu_cm.robot
Resource    taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource    taf/rfrl/cbts/robot/parameters.robot

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     taf.config.scf          WITH NAME    scf
Library     ./parameters.py
Library     OperatingSystem
Library     Collections
Library     String

*** Keywords ***

#################################################### Main  Keywords ####################################################

Check Parameter Object Via Value on BTS
    [Documentation]    Description:    This KW allows to get the object of parameter that has specific value
    ...                Input:          param_value=param_value=10.42.126.153
    ...                                hw_type = vCU/vDU
    ...                Output:         object_name=MRBTS-8445/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-1/IPADDRESSV4_R-1
    ...                                Or (in case when value is repeated in SCF):
    ...                                object_name=['MRBTS-8445/NRBTS-8445/NRDU-1',
    ...                                'MRBTS-8445/TNLSVC-1/TNL-6/IPNO-1/IPIF-2/IPADDRESSV4-1/IPADDRESSV4_R-1']IPADDRESSV4-1/IPADDRESSV4_R-1
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${param_value}     ${hw_type}=${NONE}
    ${object_name}=    Run Keyword If    '${hw_type}'=='vCU'    _Check Parameter Object Via Value on vCU
    ...                                                         param_value=${param_value}
    ...                ELSE IF           '${hw_type}'=='vDU'    _Check Parameter Object Via Value on vDU
    ...                                                         param_value=${param_value}
    ...    ELSE        FAIL               hw_type doesn't exist
    [Return]           ${object_name}

Delete Delta Plan
    [Documentation]    Description:    Delete created delta plan on vCU/vDU
    ...                Input:          hw_type = vCU/vDU
    ...                                delta_plan_id = can be found in the output of TAF delta plan creation keyword
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${delta_plan_id}    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Delete vCU Delta Plan    plan_id=${delta_plan_id}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Delete vDU Delta Plan    plan_id=${delta_plan_id}
    ...    ELSE        FAIL                  hw_type doesn't exist

Change Parameters on BTS Using XML File
    [Documentation]    Description:    Update or create any number of parameters using preexisting XML file
    ...                Input:          hw_type = vCU/vDU
    ...                                xml = path to the XML file
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${xml}    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Change Parameters on BTS Using XML File on vCU     xml=${xml}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Change Parameters on BTS Using XML File on vDU     xml=${xml}
    ...    ELSE        FAIL                  hw_type doesn't exist

Adjust XML to specific TL
    [Documentation]    Description:    Changes BTS number inside XML to the one from init file
    ...                Input:          xml_path = path to the XML file
    ...                                hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${xml_path}     ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Adjust XML to specific TL on vCU    xml_path=${xml_path}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Adjust XML to specific TL on vDU    xml_path=${xml_path}
    ...    ELSE        FAIL                  hw_type doesn't exist

################################################ Supplementary Keywords ################################################

_Create Delta JSON object for single parameter operation
    [Arguments]           ${dist_name}    ${param_name}    ${param_value}    ${dist_operation}    ${param_operation}
    &{param_dict}=        Create Dictionary    parameterName=${param_name}
    ...                                        value=${param_value}
    ...                                        operation=${param_operation}
    @{param_list}=        Create List          ${param_dict}
    &{change_dict}=       Create Dictionary    distName=${dist_name}
    ...                                        operation=${distoperation}
    ...                                        parameters=@{param_list}
	@{delta}=             Create List          ${change_dict}
	${delta_json}=        Evaluate             json.dumps(${delta})    json
	[Return]              ${delta_json}

_Create Delta JSON object for single parameter delete
    [Arguments]           ${dist_name}    ${param_name}    ${dist_operation}    ${param_operation}
    &{param_dict}=        Create Dictionary    parameterName=${param_name}
    ...                                        operation=${param_operation}
    @{param_list}=        Create List          ${param_dict}
    &{change_dict}=       Create Dictionary    distName=${dist_name}
    ...                                        operation=${dist_operation}
    ...                                        parameters=@{param_list}
	@{delta}=             Create List          ${change_dict}
	${delta_json}=        Evaluate             json.dumps(${delta})    json
	[Return]              ${delta_json}

_Add change to Delta
    [Arguments]           ${dist_name}    ${param_name}    ${param_value}
    ...                   ${dist_operation}    ${param_operation}    ${delta}
    &{param_dict}=        Create Dictionary    parameterName=${param_name}
    ...                                        value=${param_value}
    ...                                        operation=${param_operation}
    @{param_list}=        Create List          ${param_dict}
    &{change_dict}=       Create Dictionary    distName=${dist_name}
    ...                                        operation=${dist_operation}
    ...                                        parameters=@{param_list}
	@{delta_list}=        Create List          ${change_dict}
	${delta}=             Combine Lists        ${delta}             ${delta_list}
	[Return]              ${delta}

_Add deleting of parameter to Delta
	[Arguments]           ${dist_name}    ${param_name}    ${dist_operation}    ${param_operation}    ${delta}
    &{param_dict}=        Create Dictionary    parameterName=${param_name}
    ...                                        operation=${param_operation}
    @{param_list}=        Create List          ${param_dict}
    &{change_dict}=       Create Dictionary    distName=${dist_name}
    ...                                        operation=${dist_operation}
    ...                                        parameters=@{param_list}
	@{delta_list}=        Create List          ${change_dict}
	${delta}=             Combine Lists        ${delta}    ${delta_list}
	[Return]              ${delta}

_Add change in single object to Delta
    [Arguments]           ${param_name}    ${param_value}    ${param_operation}    ${delta}
    &{param_dict}=        Create Dictionary    parameterName=${param_name}
    ...                                        value=${param_value}
    ...                                        operation=${param_operation}
    @{param_list}=        Create List          ${param_dict}
	${delta}=             Combine Lists        ${delta}    ${param_list}
	[Return]              ${delta}

_Add delete change in single object to Delta
    [Arguments]           ${param_name}    ${param_operation}    ${delta}
    &{param_dict}=        Create Dictionary    parameterName=${param_name}
    ...                                        operation=${param_operation}
    @{param_list}=        Create List          ${param_dict}
	${delta}=             Combine Lists        ${delta}    ${param_list}
	[Return]              ${delta}

_Check If vCU Delta Plan Was Created
    [Arguments]        ${id}    ${conn}
    ${output}=         vcu_admin.get_action_state_of_generating_delta_plan    action_id=${id}    connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Get vCU Specifical MO UUID
    [Arguments]      ${plan_id}    ${mo_dn}    ${conn}
    @{name_list}=    Split String    ${mo_dn}    /
    Set Suite Variable    ${parent_mouuid}    ${EMPTY}
    FOR    ${name}    IN    @{name_list}
        ${mouuid}=    _Get CU Specifical MO UUID via DN Name    ${plan_id}    ${name}    conn=${conn}
    END
    [Return]    ${mouuid}

_Get CU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}    ${name}    ${conn}
    &{delta_plan_tree}=    vcu_admin.get_delta_plan_tree_diff    plan_id=${plan_id}    connection=${conn}
    @{plan_tree}=    Set Variable    ${delta_plan_tree["created"]}
    FOR    ${mo_info}    IN    @{plan_tree}
        Run Keyword If    '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'
        ...    Run Keywords    Set Suite Variable    ${parent_mouuid}    ${mo_info["mo_uuid"]}    AND    Exit For Loop
        Run Keyword If    '${mo_info["parent_mo_uuid"]}'=='None' and '${mo_info["name"]}'=='${name}'
        ...    Run Keywords    Set Suite Variable    ${parent_mouuid}    ${mo_info["mo_uuid"]}    AND    Exit For Loop
    END
    [Return]    ${parent_mouuid}

_Check If vCU Object Was Created
    [Arguments]        ${plan_id}    ${action_id}    ${conn}
    ${output}=         vcu_admin.get_create_managed_object_action_result
    ...                plan_id=${plan_id}    action_id=${action_id}    connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Check If vCU Delta Plan Was Updated
    [Arguments]        ${plan_id}    ${action_id}    ${conn}
    ${output}=         vcu_admin.get_action_state_of_updating_parameters_of_delta_plan
    ...                plan_id=${plan_id}    action_id=${action_id}    connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Check If vCU Validation Ends With Success
    [Arguments]        ${plan_id}    ${action_id}    ${conn}
    ${output}=         vcu_admin.get_action_state_of_validating_delta_plan
    ...                plan_id=${plan_id}    action_id=${action_id}    connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Check If vCU Activation Ends With Success
    [Arguments]   ${plan_id}    ${conn}
    ${result}=    vcu_admin.get_delta_plan_list    connection=${conn}
    FOR   ${r}   IN   @{result}
        ${r_plan_id}=    Set Variable     ${r}[plan_id]
        Should Not Be Equal As Strings    ${r_plan_id}    ${plan_id}
    END

_Check If vDU Delta Plan Was Created
    [Arguments]        ${id}    ${conn}
    ${output}=         vdu_admin.get_delta_plan_generated_action_status    action_id=${id}    vdu_connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Check If vDU Object Was Created
    [Arguments]        ${plan_id}    ${action_id}    ${conn}
    ${output}=         vdu_admin.get_create_vdu_object_action_status_of_delta_plan
    ...                plan_id=${plan_id}    action_id=${action_id}    vdu_connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Check If vDU Delta Plan Was Updated
    [Arguments]        ${plan_id}    ${action_id}    ${conn}
    ${output}=         vdu_admin.get_update_paras_action_status_of_delta_plan
    ...                plan_id=${plan_id}    action_id=${action_id}    vdu_connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Check If vDU Validation Ends With Success
    [Arguments]        ${plan_id}    ${action_id}    ${conn}
    ${output}=         vdu_admin.get_validate_delta_plan_operation_status
    ...                delta_plan_id=${plan_id}    action_id=${action_id}    vdu_connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Check If vDU Activation Ends With Success
    [Arguments]   ${plan_id}    ${conn}
    ${result}=    vdu_admin.get_delta_plan_info_list    vdu_connection=${conn}
    FOR   ${r}   IN   @{result}
        ${r_plan_id}=    Set Variable     ${r}[plan_id]
        Should Not Be Equal As Strings    ${r_plan_id}    ${plan_id}
    END

_Create Parameter Change List For vCU
    [Arguments]        ${operation_type}    ${parameter_path}    ${parameter_value}
    &{change_dict}=    Create Dictionary    operation_type=${operation_type}
    ...                                     parameter_path=${parameter_path}
    ...                                     value=${parameter_value}
	@{change_list}=    Create List          ${change_dict}
	[Return]           @{change_list}

_Create Parameter Change Dict for vDU
    [Arguments]        ${parameter_name}    ${parameter_value}
    &{change_dict}=    Create Dictionary    ${parameter_name}=${parameter_value}
	[Return]           &{change_dict}

_Check If vCU Object Was Deleted
    [Arguments]        ${plan_id}    ${action_id}    ${conn}
    ${output}=         vcu_admin.get_delete_managed_object_action_result
    ...                plan_id=${plan_id}    action_id=${action_id}    connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Check If vDU Object Was Deleted
    [Arguments]        ${plan_id}    ${action_id}    ${conn}
    ${output}=         vdu_admin.get_deleting_mo_action_state_of_delta_plan
    ...                delta_plan_id=${plan_id}    action_id=${action_id}    vdu_connection=${conn}
    Should Be True    "${output["status"]}"=="success"

_Check Parameter Object Via Value on vCU
    [Arguments]      ${param_value}
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    ${output_dir}=   Set Variable       ${OUTPUT_DIR}/${TEST_NAME}
    Create Directory    ${output_dir}
    vcu_admin.get_current_plan_file
    ...              path=${output_dir}/scf.xml   include_runtime_data=${True}
    ...              connection=${temp_conn}
    ${dist_name}=    find_elements_with_value    path_to_scf=${output_dir}/scf.xml    searched_value=${param_value}
    [Return]         ${dist_name}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Check Parameter Object Via Value on vDU
    [Arguments]      ${param_value}
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    ${output_dir}=   Set Variable       ${OUTPUT_DIR}/${TEST_NAME}
    Create Directory    ${output_dir}
    vdu_admin.get_current_plan_file
    ...              local_dir_path=${output_dir}    filename=${TEST_NAME}.xml
    ...              include_runtime_data=${True}    vdu_connection=${temp_conn}
    ${dist_name}=    find_elements_with_value    path_to_scf=${output_dir}/${TEST_NAME}.xml
    ...              searched_value=${param_value}
    [Return]         ${dist_name}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Delete vCU Delta Plan
    [Arguments]       ${plan_id}
    ${temp_conn}=     Connect to ADMIN    hw_type=vCU
    vcu_admin.delete_delta_plan    plan_id=${plan_id}    connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    5s    _Check If vCU Activation Ends With Success
    ...                                          plan_id=${plan_id}    conn=${temp_conn}
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Delete vDU Delta Plan
    [Arguments]       ${plan_id}
    ${temp_conn}=     Connect to ADMIN    hw_type=vDU
    vdu_admin.delete_delta_plan_file    plan_id=${plan_id}    timeout=60    vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    5s    _Check If vDU Activation Ends With Success
    ...                                          plan_id=${plan_id}    conn=${temp_conn}
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Change Parameters on BTS Using XML File on vCU
    [Arguments]    ${xml}
    Log            Recommisioning with ${xml} delta on vCU is ongoing    console=True
    vcu_cm.Fast Delta Commissioning With Delta XML File    xml_file_path=${xml}
    Log            Recommisioning with ${xml} delta on vCU ends with success    console=True

_Change Parameters on BTS Using XML File on vDU
    [Arguments]    ${xml}
    Log            Recommisioning with ${xml} delta on vDU is ongoing    console=True
    vdu_cm.Fast Delta Commissioning With Delta XML File    xml_file_path=${xml}
    Log            Recommisioning with ${xml} delta on vDU ends with success    console=True

_Adjust XML to specific TL on vCU
    [Arguments]        ${xml_path}
    ${xml}=            OperatingSystem.Get File    ${xml_path}
    ${xml}=            Replace String Using Regexp    ${xml}    MRBTS-\\d{4}/    MRBTS-${MRBTS_CU}/
    ${xml}=            Replace String Using Regexp    ${xml}    MRBTS-\\d{5}/    MRBTS-${MRBTS_CU}/
    ${xml}=            Replace String Using Regexp    ${xml}    MRBTS-\\d{6}/    MRBTS-${MRBTS_CU}/
    Create File        ${xml_path}    ${xml}

_Adjust XML to specific TL on vDU
    [Arguments]        ${xml_path}
    ${xml}=            OperatingSystem.Get File    ${xml_path}
    ${xml}=            Replace String Using Regexp    ${xml}    MRBTS-\\d{4}    MRBTS-${MRBTS}
    Create File        ${xml_path}    ${xml}
