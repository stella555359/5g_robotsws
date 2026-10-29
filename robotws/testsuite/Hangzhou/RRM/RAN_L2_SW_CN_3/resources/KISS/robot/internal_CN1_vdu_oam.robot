*** Settings ***
#Library    taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu

*** Keywords ***
VDU Login
    [Arguments]    ${restapi_version}=cuoam_21b    ${vdu_index}=0    ${gnb_index}=0    ${alias}=default    ${delay}=${EMPTY}
    [Documentation]    login vdu webem by restful api.
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | restapi_version | No | value only is cuoam_21b or cuoam_19b, default is cuoam_21b |
    ...    | vdu_index | No | the index of vdu, default value is 0 |
    ...    | gnb_index | No | the index of gnb, default value is 0 |
    ...    | alias | No | connect name |
    ...    | delay | No | whether is there need Sleep, default is ${EMPTY} means not Sleep |
    ...    *Return*
    ...    None
    ...    *Example*
    ...    | vDU Rest Login | cuoam_21b | 0 | 0 | defualt | ${EMPTY} |
    ...    | vDU Rest Login | cuoam_19b | 0 | 0 | defualt | 10s |
    ${oam_httpaddr}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    Set Variable If    ':' in '''${oam_httpaddr}'''    [${oam_httpaddr}]    ${oam_httpaddr}
    Run Keyword And Ignore Error    VDU Logout    alias=${alias}    vdu_index=${vdu_index}
    ${password}    Set Variable If    '${SW_BRANCH}'=='Trunk'    Nokia@123    nemuuser
    ${vdu_connection}=    Run Keyword If    '${restapi_version}'=='cuoam_21b'    vdu.Connect To
    ...    host=${oam_web_ip}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...    password=${password}
    ...    secure=True
    ...    connection_name=${alias}
    ...    ELSE    vdu.Connect To
    ...    host=${oam_web_ip}
    ...    port=8081
    ...    username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...    password=${password}
    Run Keyword If    "${delay}"!="${EMPTY}"    Sleep    ${delay}

VDU Logout
    [Arguments]    ${vdu_index}=0    ${alias}=default
    [Documentation]    vDU Rest Logout
    ...    *Argument Decription*
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu index, default is 0 |
    ...    | alias | No | The alias of connect vdu with rest api |
    ...    *Example*
    ...    | vDU Rest Login |
    ...    | vDU Rest Logout |
    vdu.Disconnect    ${alias}

VDU Full Commssion
    [Arguments]    ${vdu_scfc_path}
    [Documentation]    Full Commission SCF On VDU
    ...    | Input Parameters    | Man. | Description |
    ...    | vdu_scfc_path | no | scf_file with path    |
    ...    Example
    ...    | VDU Full Commssion |
    ...
    Modify vDU VlanId In SCF File    ${vdu_scfc_path}
    VDU Login
    Log To Console    --> Upload vDU SCF File:${vdu_scfc_path}
    ${Upload Plan_response}=    vdu.Upload Plan    path_to_plan_file=${vdu_scfc_path}
    Wait Until Keyword Succeeds    2min    30s    Upload Plan Operation Should Be Successful
    ...    ${Upload Plan_response['action_id']}
    Log To Console    --> Upload vDU plan success and start to validate plan
    ${Validate Plan_response}=    vdu.Validate Plan    plan_id=${Upload Plan_response['plan_id']}
    Log To Console    --> response: ${Upload Plan_response['plan_id']}
    Wait Until Keyword Succeeds    2min    30s    Validate Plan Operation Should Be Successful
    ...    ${Upload Plan_response['plan_id']}    ${Validate Plan_response['action_id']}
    Log To Console    --> Start activiation with plan_id: ${Upload Plan_response['plan_id']}
    ${Activate Plan_response}=    vdu.Activate Plan    plan_id=${Upload Plan_response['plan_id']}
    Log To Console    --> Checking plan activation status in vDU side
    Wait Until Keyword Succeeds    15min    5min    Activate Plan Operation Should Be Successful
    ...    ${Upload Plan_response['plan_id']}    ${Activate Plan_response['id']}
    [teardown]    Run Keyword And Ignore Error    VDU Logout

Upload Plan Operation Should Be Successful
    [Arguments]    ${upload_action_id}
    [Documentation]    checking upload plan operation status should be successful
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from Upload Plan |
    ${upload_operation_response}=    vdu.Get Upload Plan Operation Status
    ...    operation_id=${upload_action_id}    vdu_connection=default
    Should Be Equal As Strings    ${upload_operation_response['status']}    success
    Log To Console    Upload Plan Success

Validate Plan Operation Should Be Successful
    [Arguments]    ${plan_id}    ${action_id}
    [Documentation]    checking validate plan operation status should be successful
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from validate_plan |
    ${validate_plan_response}=    vdu.Get Validate Plan Operation Status
    ...    plan_id=${plan_id}    operation_id=${action_id}    vdu_connection=default
    Should Be Equal As Strings    ${validate_plan_response['status']}    success
    Log To Console    Validate Plan Success

Activate Plan Operation Should Be Successful
    [Arguments]    ${plan_id}    ${action_id}
    [Documentation]    checking activate plan operation status should be successful
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ${activate_plan_response}=    vdu.Get Activate Plan Operation Status
    ...    plan_id=${plan_id}    operation_id=${action_id}    vdu_connection=default
    Should Be Equal As Strings    ${activate_plan_response['status']}    success
    Log To Console    Activate Plan Success

VDU Get Current Plan File
    [Arguments]    ${log_dir}    ${scf_backup_name}    ${gnb_index}=0
    [Documentation]    This keyword is to save vdu plan file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the path to save scf file |
    ...    | ${scf_backup_name} | Yes | the name for saved scf file,eg. before_suite_vdu_scf.xml |
    ...    | ${gnb_index} | No | gnb index, the default value is 0 |
    ...
    ...    Examples:
    ...    | ${vdu_scf_file} | VDU Get Current Plan File | ${output_dir} | before_suite_vdu_scf.xml |
    VDU Login
    ${vdu_scf_file}=    vdu.get_current_plan_file    local_dir_path=${log_dir}    filename=${scf_backup_name}
    ...                                                include_runtime_data=${False}
    [Teardown]    Run Keyword And Ignore Error    VDU Logout
    [Return]    ${vdu_scf_file}

VDU Collect Snapshot
    [Arguments]    ${save_dir}
    VDU Login
    Log To Console       --> start saving vDU Snapshot log
    vdu.get_local_snapshot    directory=${save_dir}
    [teardown]    Run Keyword And Ignore Error    VDU Logout

VDU Get PM Counter Value
    [Arguments]    ${counter_id}    ${dimension_dn}
    [Documentation]    This keyword is to get the latest value for a dedicated counter
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | yes | the counter id, e.g.M55115C00002 |
    ...    | ${dimension_dn} | yes | the dimension dist name that the counter belongs to, e.g.MRBTS-1111/NRBTS-1111/NRCELL-1 |
    ...
    ...    Examples:
    ...    | ${counter_value} | Get PM Counter Value | M55115C00002 | MRBTS-1111/NRBTS-1111/NRCELL-1 |
    VDU Login
    ${counter_list}    vdu.get_counter_values    counter_id=${counter_id}    dimension_dn=${dimension_dn}
    Run Keyword If    ${counter_list}==[]    Fail    No counter value right now.
    Log    ${counter_list[-1]}
    ${counter_value}    Get From Dictionary    ${counter_list[-1]}    value
    Log To Console    The latest value for counter '${counter_id}': ${counter_value}
    [teardown]    Run Keyword And Ignore Error    VDU Logout
    [Return]    ${counter_value}

_VDU Update User Plane Trace Configuration
    [Arguments]    ${uplane_ip_addr}    ${uplane_port}      ${dscp}=0
    [Documentation]   Update User Plane Trace Configuration
    ...   | Input Parameters    | Man. | Description |
    ...   | uplane_ip_addr      | yes | destination ip for dcap |
    ...   | uplane_port       | yes | user plane trace port in dcap |
    ...   | dscp              | yes | default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    return vdu_connection.update_uplane_configuration(uplane_ip_addr=uplane_ip_addr,
    ...                                   uplane_port=uplane_port,dscp=dscp,timeout=timeout)
    ...
    ...   Example
    ...   | VDU Login |
    ...   | Update User Plane Trace Configuration | uplane_ip_addr=10.110.95.16  |  uplane_port=55900 |
    ...   | VDU Logout |
    VDU Login
    ${uplane_port_1}    Convert To Integer    ${uplane_port}
    ${dscp_1}    Convert To Integer    ${dscp}
    ${res1}    vdu.update_uplane_configuration
    ...    uplane_ip_addr=${uplane_ip_addr}    uplane_port=${uplane_port_1}    dscp=${dscp_1}
    sleep    10s
    ${res2}    vdu.get_trs_api_operation_status    operation_id=${res1}
    [teardown]    Run Keyword And Ignore Error    VDU Logout
    [Return]    ${res2}

_VDU Start Uplane Trace
    [Arguments]    ${target_component}    ${nr_cell_dn_list}    ${trace_type}=Component
    [Documentation]   Start uplane Trace
    ...   | Input Parameters    | Man. | Description |
    ...   | target_component    | yes | which component trace: L2HiRlc/L2Lo/L2Ps|
    ...   | nr_cell_dn_list     | yes | which cell , it's a list. such as @{nr_cell_dn_list}    MRBTS-1/NRBTS-1/NRCELL-1 |
    ...   | trace_type          | yes | which trace type:Component/Sherpa |
    ...
    ...   *RETURN VALUE*
    ...   return trace_id
    VDU Login
    ${res1}    vdu.start_uplane_trace_stream
    ...    target_component=${target_component}    nr_cell_dn_list=${nr_cell_dn_list}    trace_type=${trace_type}
    Log To Console    ${res1}
    sleep    3s
    ${res2}    vdu.get_active_trace_streams
    Log To Console    Active trace id: ${res2[0]['trace_id']}
    [teardown]    Run Keyword And Ignore Error    VDU Logout
    [Return]    ${res2[0]['trace_id']}

VDU Stop Uplane Trace
    [Arguments]    ${trace_id}
    [Documentation]   Stop uplane Trace
    ...   | Input Parameters    | Man. | Description |
    ...   | trace_id            | yes | which component trace |
    VDU Login
    ${res1}    vdu.stop_uplane_trace_stream    trace_id=${trace_id}
    sleep    3s
    Log To Console    ${res1}
    [teardown]    Run Keyword And Ignore Error    VDU Logout


VDU Get NRCELL Dist_Name From Cell Status
    [Arguments]    ${cell_id_list}
    [Documentation]    This keyword is to
    ...
    ...    cell status:
    ...    [{‘id’: ‘1’,
    ...    ’name’: ‘NRCELL-1’,
    ...    ‘administrative_state’: ‘Unlocked’,
    ...    ‘operational_state’: ‘disabled’,
    ...    ‘availability_status’: ‘failed’,
    ...    ‘procedural_status’: ‘initializing’,
    ...    ‘nr_cell_identity’: ‘85819393’,
    ...    ‘band’: ‘n5’,
    ...    ‘p_max’: ‘270’,
    ...    ‘dl_mimo_mode’: ‘2x2 Closed Loop Spatial Multiplexing’,
    ...    ‘ul_mimo_mode’: ‘Closed loop Spatial Multiplexing (2x2)’,
    ...    ‘dist_names’: {‘config’: ‘MRBTS-5238/NRBTS-5238/NRCELL-1’, ‘runtime’: None},
    ...    ‘technology’: ‘FDD’,
    ...    ‘cell_group_id’: ‘0’,
    ...    ‘ch_bw_dl’: ‘5MHz’,
    ...    ‘ch_bw_ul’: ‘5MHz’,
    ...    ‘nrarfcn_dl’: ‘176300’,
    ...    ‘nrarfcn_ul’: ‘167300’, ‘
    ...    blocking_state’: ‘Unblocked’
    ...    }]
    VDU Login
    ${cell_status}    vdu.get_vdu_cells_status
    ${cell_num}    Get Length    ${cell_status}
    Set Test Variable    ${cell_status}
    Set Test Variable    ${cell_num}
    ${all_cell_id}    Evaluate    range(1,int(${cell_num}+1))
    ${cell_id_list}    Set Variable If    '${cell_id_list}'=='All'    ${all_cell_id}    ${cell_id_list}
    Log Many    ${cell_id_list}
    ${dist_name_list}    Create List
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${Dist_Name}    _VDU Get Single NRCELL Dist_Name From Cell Status    ${cell_id}
        Append To List    ${dist_name_list}    ${Dist_Name}
    END
    [teardown]    Run Keyword And Ignore Error    VDU Logout
    [Return]    ${dist_name_list}

_VDU Get Single NRCELL Dist_Name From Cell Status
    [Arguments]    ${cell_id}
    FOR    ${index}    IN RANGE    ${cell_num}
        ${value}    Run Keyword If    '${cell_status[${index}]['id']}'=='${cell_id}'
        ...    Get From Dictionary    ${cell_status[${index}]}     dist_names
        ${status}    Evaluate    isinstance(${value},dict)
        Run Keyword If    '${status}'=='False'    Continue For Loop
        ${dist_names}    Get From Dictionary    ${value}     config
        Log To Console    Dist_Name for Cell ${cell_id}: ${dist_names}
    END
    [Return]    ${dist_names}

VDU Get Software Version
    VDU Login
    &{status_dic}    vdu.get_vdu_state_data
    Set Suite Variable    ${TOTAL_VDU_SW_VERSION}    ${status_dic.software_version}
    Log    VDU Total SW Version: ${TOTAL_VDU_SW_VERSION}    console=${true}
    [teardown]    Run Keyword And Ignore Error    VDU Logout

VDU Online Change Parameters
    [Arguments]    ${mo_dn_list}    ${updated_paras_dict_list}    ${operation}=replace
    ...    ${activate}=${True}    ${force_reset}=${True}    ${auto_lock_cells}=${True}
    ...    ${wait_vdu_up}=${False}    ${timeout}=30
    [Documentation]   VDU Online Modify Parameters By Delta Plan REST
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn_list               | yes |  the mo distname list that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...   | updated_paras_dict_list  | yes | parameters values list, the element type is dict |
    ...   | operation         | no |  the operation - add, replace, remove, revert. The default is replace |
    ...
    ...   Example
    ...   | *** Variables *** |
    ...   | ${MO_DN_1} | MRBTS-1/NRBTS-1/NRCELLGRP-1 |
    ...   | &{UPDATED_PARAS_DICT_1} | ssBurstSetPeriod=10 |
    ...   | ${MO_DN_2} | MRBTS-1/NRBTS-1/NRCELL-1 |
    ...   | &{UPDATED_PARAS_DICT_2} | actPdschAtSsbSlots=false | ulPowerControlCommon/1/p0NominalPucch=-80 |
    ...   | ... | ulPowerControlCommon/1/actUlOpenLoopPwrCtrl=false |
    ...   | @{MO_DN_LIST} | ${MO_DN_1} | ${MO_DN_2} |
    ...   | @{UPDATED_PARAS_DICT_LIST} | ${UPDATED_PARAS_DICT_1} | ${UPDATED_PARAS_DICT_2} |
    ...   | VDU Online Change Parameters | ${MO_DN_LIST} | ${UPDATED_PARAS_DICT_LIST} |
    ...
    VDU Login
    Log To Console    --> Create delta plan
    ${all_plans}    vdu.Get_Delta_Plan_Info_List
    Run Keyword If    ${all_plans.__len__()}==1
    ...               vdu.delete_delta_plan_file    plan_id=${all_plans[0]["plan_id"]}
    ${all_plans}    vdu.Get_Delta_Plan_Info_List    #to check the plan_id delete successfully
    ${out}    vdu.Generate_Delta_Plan    plan_name=delta_plan    plan_description=TA
    ${temp_plan_id}    Set Variable    ${out["plan_id"]}
    ${temp_action_id}    Set Variable    ${out["action_id"]}
    Wait Until Keyword Succeeds    30    3    _Check Delta Plan Status Should Be Expected
    ...    action_id=${temp_action_id}    expected_status=success
    Log To Console    --> update_vdu_parameter_of_delta_plan
    ${timeout}    convert to integer    ${timeout}
    FOR    ${mo_dn}    ${updated_paras_dict}    IN ZIP    ${mo_dn_list}    ${updated_paras_dict_list}
        ${out}    vdu.update_vdu_parameter_of_delta_plan    plan_id=${temp_plan_id}    mo_dn=${mo_dn}
        ...    updated_paras_dict=${updated_paras_dict}    operation=${operation}
        ...    timeout=${timeout}
        ${action_id}    set variable    ${out["action_id"]}
        ${out}    wait until keyword succeeds    20    2
        ...   _Check Delta Plan Parameter Should Be Expected    plan_id=${temp_plan_id}    action_id=${action_id}
        ...   expected_status=success
    END
    Log To Console    --> Validate Delta Plan By REST In vDU
    ${validation_id}    Validate Delta Plan By REST In vDU    plan_id=${temp_plan_id}
    run keyword if    "${activate}"=="${True}"
    ...    Activate Delta Plan By REST In vDU    plan_id=${temp_plan_id}    force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}    wait_vdu_up=${wait_vdu_up}
    [teardown]    Run Keyword And Ignore Error    VDU Logout

_Check Delta Plan Status Should Be Expected
    [Arguments]    ${action_id}    ${expected_status}
    ${out}    vdu.Get_Delta_Plan_Generated_Action_Status    action_id=${action_id}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Delta Plan Parameter Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}    ${expected_status}
    ${out}    vdu.get_update_paras_action_status_of_delta_plan    plan_id=${plan_id}    action_id=${action_id}
    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Validate Delta Plan By REST In vDU
    [Arguments]    ${plan_id}
    [Documentation]    Validate Delta Plan By REST
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id  | yes | plan_id |
    ...
    ...   | Return Value | Description |
    ...   | validation_id | Return validation_id |
    ...
    ...   Example
    ...   | Validate Delta Plan By REST In vDU | ${plan_id} |
    ...
    ${out}    vdu.Validate_Delta_Plan    delta_plan_id=${plan_id}
    ${action_id}    Set Variable    ${out["action_id"]}
    ${rtn}    Wait Until Keyword Succeeds    20    2
    ...   _Check Validate Delta Plan Status Should Be Expected
    ...    action_id=${action_id}    plan_id=${plan_id}    expected_status=success
    ${validation_id}    Set Variable    ${out["validation_id"]}
    [Return]    ${validation_id}

_Check Validate Delta Plan Status Should Be Expected
    [Arguments]    ${action_id}    ${expected_status}    ${plan_id}
    ${out}    vdu.Get_Validate_Delta_Plan_Operation_Status    action_id=${action_id}    delta_plan_id=${plan_id}
    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]    ${out}

Activate Delta Plan By REST In vDU
    [Arguments]    ${plan_id}    ${force_reset}=${True}    ${auto_lock_cells}=${True}
    ...            ${wait_vdu_up}=${False}    ${timeout}=60
    [Documentation]   Activate Delta Plan By REST
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | wait_vdu_up      | no | if ${True}, will wait for VDU on-air, default is ${False} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...   | Activate Delta Plan By REST In vDU |  ${plan_id} |
    ...
    Log To Console    --> activate_delta_plan
    ${delta_scf_fullpath}    vdu.save_delta_plan_file    local_path=${TEST_LOG_DIRECTORY()}    local_filename=tmp_delta_plan.xml
    ${out}    vdu.activate_delta_plan    delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}
    ${rtn}    Wait until keyword succeeds    600    30s
     ...   _Check Activate Delta Plan Status Should Be Expected    operation_id=${out['id']}    plan_id=${plan_id}
     ...                                                        expected_status=success
    Run keyword if    "${wait_vdu_up}"=="${True}"    wait until keyword succeeds    600    20
    ...                                            vDU Check All Cells Status Should Be Onair For All DUs

_Check Activate Delta Plan Status Should Be Expected
    [Arguments]    ${operation_id}    ${plan_id}    ${expected_status}
    ${out}    vdu.Get_Activate_Delta_Plan_Operation_Status    operation_id=${operation_id}    delta_plan_id=${plan_id}
    Log    ${out["error_message"]}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

vDU Check All Cells Status Should Be Onair For All DUs
    [Arguments]    ${gnb_index}=${0}
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${i}    IN RANGE    ${du_number}
        vDU Check All Cells Status Should Be Onair    vdu_index=${i}    gnb_index=${gnb_index}
    END

vDU Check All Cells Status Should Be Onair
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    ${cell_number}    VDU Get Cell Number
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${alias}
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    ${on_line}    set variable    ${vdu_cells_summary['availability_status']['on_line']}
    should be true    ${on_line}==${cell_number}
    [Teardown]  vdu.disconnect    ${alias}

Get vDU Number
    [Arguments]    ${gnb_index}=0
    ${vDU_number}    get length    ${tl.gnbs[${gnb_index}].dus}
    [Return]    ${vDU_number}

VDU Get Cell Number
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    VDU Login    ${vdu_index}=0    ${gnb_index}=0
    ${cells_status_list}    vdu.get_vdu_cells_status
    ${cell_number}    Get Length    ${cells_status_list}
    [Teardown]    Run Keyword And Ignore Error    VDU Logout
    [Return]    ${cell_number}
