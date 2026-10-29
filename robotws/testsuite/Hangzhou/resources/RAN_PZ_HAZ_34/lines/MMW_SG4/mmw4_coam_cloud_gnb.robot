*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library             taf.gnb.oam.coam.vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu        WITH NAME    cu
Library     taf.converters.eventdecoder    WITH NAME    ctti
Library     taf.collectors.tcpdump    WITH NAME    tcpdump
Library     taf.collectors.l2stream3    WITH NAME    l2stream3
Library     taf.collectors.core    WITH NAME    core







*** Variables ***
${download_http}    https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${vdu_namespace}      ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${vcu_namespace}      ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
${DU_core_username}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
${DU_core_password}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}

*** Keywords ***
########### DU common KW #################
vDU Login
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0  ${connection}=DU_CON
    [Documentation]  login vdu webem.
    ${vdu_connection}    vdu.connect_to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  port=${EMPTY}
    ...  secure=${True}
    ...  connection_name=${connection}
    [Return]    ${vdu_connection}

vDU Logout
    [Arguments]  ${connection}=DU_CON
    [Documentation]  vDU Rest Logout
    vdu.disconnect    vdu_connection=${connection}

Update RAD Debug Parameter
    [Arguments]    ${para_list}    ${persistency}=persistent    ${domain_name}=L2PS    ${vdu_index}=0  ${gnb_index}=0  ${connection}=DU_CON
    [Documentation]    Update RAD debug parameter.
    ...    parameter:persistency (str) – should be persistent, notPersistent or oneReset.
    vDU Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}    connection=${connection}
    ${update_params}    vdu.update_rad_debug_params    persistency=${persistency}   domain_name=${domain_name}    parameters=${para_list}
    ...    vdu_connection=${connection}
    sleep  15s
    ${current_update_operation}    vdu.get_rad_debug_params_update_operation    operation_id=${update_params['operation_id']}
    ...    vdu_connection=${connection}
    ${rad_debug_params}    vdu.get_rad_debug_params_summary    vdu_connection=${connection}
    Should Be Equal    '${rad_debug_params}'   'True'
    [Teardown]  vDU Logout    connection=${connection}

Upload Plan Operation Should Be As Expected
    [Arguments]  ${upload_action_id}    ${expected_status}=success    ${connection}=DU_CON
    [Documentation]   checking upload plan operation status should as expected
    ${upload_operation_response}=  vdu.get_upload_plan_operation_status  operation_id=${upload_action_id}    vdu_connection=${connection}
    should be equal as strings  ${upload_operation_response['status']}  ${expected_status}

Validate Plan Operation Should Be As Expected
    [Arguments]  ${plan_id}  ${action_id}    ${expected_status}=success    ${connection}=DU_CON
    [Documentation]   checking validate plan operation status should be as expected
    ${validate_plan_response}=  vdu.get_validate_plan_operation_status  plan_id=${plan_id}  operation_id=${action_id}   vdu_connection=${connection}
    should be equal as strings  ${validate_plan_response['status']}  ${expected_status}

Activate Plan Operation Should Be As Expected
    [Arguments]  ${plan_id}  ${action_id}    ${expected_status}=success    ${connection}=DU_CON
    [Documentation]   checking activate plan operation status should be as expected
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  plan_id=${plan_id}  operation_id=${action_id}   vdu_connection=${connection}
    should be equal as strings  ${activate_plan_response['status']}  ${expected_status}

Validate Delta Plan Status Should Be Expected
    [Arguments]   ${plan_id}    ${action_id}   ${expected_status}=success  ${connection}=DU_CON
    ${out}   vdu.Get_Validate_Delta_Plan_Operation_Status   action_id=${action_id}   delta_plan_id=${plan_id}    vdu_connection=${connection}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Activate Delta Plan Status Should Be Expected
    [Arguments]  ${plan_id}   ${operation_id}    ${expected_status}  ${connection}=DU_CON
    ${out}   vdu.Get_Activate_Delta_Plan_Operation_Status   operation_id=${operation_id}   delta_plan_id=${plan_id}    vdu_connection=${connection}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

vDU Full Commssion By Rest
    [Arguments]    ${scf_path}   ${vdu_index}=0  ${gnb_index}=0  ${connection}=DU_CON
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    log to console  \n*** start send commission on vdu ***
    ${response}    vdu.perform_commissioning    scf_file=${scf_path}    vdu_connection=${connection}
    ${status}    set variable    ${response['status']}
    Should be True    'success'=='${status}'
    [Teardown]    vDU Logout    connection=${connection}

vDU Full Commssion By Rest with upload Plan file
    [Arguments]  ${scf_path}   ${vdu_index}=0  ${gnb_index}=0  ${connection}=DU_CON
    [Documentation]   send commission on one vdu, including upload validate and activate scf
    log to console  \n*** start send commission on vdu ***
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${upload_plan_response}=  vdu.upload_plan    path_to_plan_file=${scf_path}    vdu_connection=${connection}
    wait until keyword succeeds  2min  5s  Upload Plan Operation Should Be As Expected  upload_action_id=${upload_plan_response['action_id']}
    ...    expected_status=success    connection=${connection}
    ${validate_plan_response}=  vdu.validate_plan   plan_id=${upload_plan_response['plan_id']}    vdu_connection=${connection}
    wait until keyword succeeds  2min  5s  Validate Plan Operation Should Be As Expected    plan_id=${upload_plan_response['plan_id']}
    ...  action_id=${validate_plan_response['action_id']}    expected_status=success    connection=${connection}
    ${activate_plan_response}=  vdu.activate_plan  plan_id=${upload_plan_response['plan_id']}    vdu_connection=${connection}
    sleep  90s
    wait until keyword succeeds  10min  20s  Activate Plan Operation Should Be As Expected    plan_id=${upload_plan_response['plan_id']}
    ...  action_id=${activate_plan_response['id']}    expected_status=success    connection=${connection}
    [Teardown]    vDU Logout    connection=${connection}

Validate Delta Plan By REST
    [Arguments]  ${plan_id}    ${connection}=DU_CON
    [Documentation]   Validate Delta Plan By REST
    ${out}  vdu.Validate_Delta_Plan   delta_plan_id=${plan_id}    vdu_connection=${connection}
    ${action_id}   Set Variable  ${out["action_id"]}
    ${out}  Wait Until Keyword Succeeds  20   2    Validate Delta Plan Status Should Be Expected
    ...    plan_id=${plan_id}    action_id=${action_id}   expected_status=success    connection=${connection}
    ${validation_id}  Set Variable   ${out["validation_id"]}
    [Return]   ${validation_id}

Logging vDU Delta Plan Validation Error
  [Arguments]  ${plan_id}  ${validation_id}    ${connection}=DU_CON
  [Documentation]    Validation Delta Plan Error
  ${validation_result}   vdu.get_delta_plan_validation_results   plan_id=${plan_id}  validation_id=${validation_id}
  ...    vdu_connection=${connection}
  log dictionary   ${validation_result}

Activate Delta Plan By REST
    [Arguments]  ${plan_id}    ${timeout}=300    ${connection}=DU_CON
    [Documentation]   Activate Delta Plan By REST
    log to console    unUsed variable: timeout-${timeout}
    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}    vdu_connection=${connection}
    ${operation_id}   Set Variable  ${out['id']}
    ${rtn}   Wait until keyword succeeds  300  30s    Activate Delta Plan Status Should Be Expected
    ...    plan_id=${plan_id}   operation_id=${operation_id}    expected_status=success  connection=${connection}

vDu Get software version
    [Arguments]  ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    [Documentation]    Get software version
    log to console  \n*** Get software version ***
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${vdu_info}    vdu.get_vdu_state_data    vdu_connection=${connection}
    ${software_version}    set variable    ${vdu_info['software_version']}
    [Teardown]  vDU Logout    connection=${connection}
    [Return]    ${software_version}

vDU Get Active Alarms
    [Arguments]  ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    [Documentation]    Get Active Alarms
    log to console  \n*** Get Active Alarms ***
    @{fault_id_list}    create list
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${active_alarms}  vdu.vdu_get_active_alarms  vdu_connection=${connection}
    ${alarm_list}    set variable    ${active_alarms['alarms']}
    FOR  ${alarm}  IN  @{alarm_list}
        append to list  ${fault_id_list}  ${alarm['fault_id']}
    END
    [Teardown]  vDU Logout    connection=${connection}
    [Return]    ${fault_id_list}

vDU Get Historical Alarms
    [Arguments]    ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    [Documentation]    Get Historical Alarms
    log to console  \n*** Get Historical Alarms ***
    @{fault_id_list}    create list
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${historical_alarms}  vdu.vdu_get_historical_alarms  vdu_connection=${connection}
    ${alarm_list}    set variable    ${historical_alarms['alarms']}
    FOR  ${alarm}  IN  @{alarm_list}
        append to list  ${fault_id_list}  ${alarm['fault_id']}
    END
    [Teardown]  vDU Logout    connection=${connection}
    [Return]    ${fault_id_list}

vDU Set Expect Cell Status
    [Documentation]   Set several common cell states
    ${onair_status}=  Create Dictionary    administrative_state=Unlocked    availability_status=on line
    ...    blocking_state=Unblocked    operational_state=enabled    procedural_status=configured
    ${block_status}=  Create Dictionary    administrative_state=Unlocked    availability_status=on line
    ...    blocking_state=blocked    operational_state=enabled    procedural_status=configured
    ${lock_status}=  Create Dictionary    administrative_state=Unlocked    availability_status=on line
    ...    blocking_state=Unblocked    operational_state=enabled    procedural_status=configured
    ${expected_cell_status_dict}  Create Dictionary    onair_status=${onair_status}    block_status=${block_status}    lock_status=${lock_status}
    [Return]    ${expected_cell_status_dict}

vDU Set Expect Rmod Status
    [Documentation]   Set several common Rmod states
    ${onair_status}=  Create Dictionary    administrative_state=Unlocked    availability_status=on line
    ...    operational_state=enabled    procedural_status=configured
    ${lock_status}=  Create Dictionary    administrative_state=Locked    availability_status=on line
    ...    operational_state=enabled    procedural_status=configured
    ${expected_cell_status_dict}  Create Dictionary    onair_status=${onair_status}    lock_status=${lock_status}
    [Return]    ${expected_cell_status_dict}

vDU Verify Cells Status Should Be Onair
    [Arguments]  ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    [Documentation]    vDU Verify Cells Status Should Be Onair
    log to console    vDU Verify Cells Status Should Be Onair
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${expected_cell_status_dict}    vDU Set Expect Cell Status
    ${expected_status_dict}    set variable    ${expected_cell_status_dict['onair_status']}
    Wait Until Keyword Succeeds    20 min   30s    vDU Verify Cells Status Should Be As Expect    expected_status_dict=${expected_status_dict}
    ...    cell_id_list=${EMPTY}    connection=${connection}
    [Teardown]  vDU Logout    connection=${connection}

vDU Verify Cells Status Should Be As Expect
    [Arguments]  ${expected_status_dict}    ${cell_id_list}=${EMPTY}     ${connection}=DU_CON
    [Documentation]    vDU Verify Cells Status Should Be As Expect
    ...    param: cell_id_list (list), cell id should be int, if empty, check all cells
    log to console  \n*** Check Cell Status ***
    ${cell_len}    get length    ${cell_id_list}
    @{cell_id_list_1}    run keyword if   ${cell_len}==${0}    Create list    ELSE    set variable    ${cell_id_list}
    ${vdu_cells_status}=  vdu.get_vdu_cells_status  vdu_connection=${connection}
    @{vdu_cells_status_tmp}    create list
    FOR  ${cell_info}  IN  @{vdu_cells_status}
        run keyword if    ${cell_info['id']} in ${cell_id_list_1}    append to list    ${vdu_cells_status_tmp}    ${cell_info}
    END
    ${tmp_list}    Get length    ${vdu_cells_status_tmp}
    ${check_vdu_cells_status}    set variable if    ${tmp_list}==${0}    ${vdu_cells_status}    ${vdu_cells_status_tmp}
    FOR  ${cell}  IN  @{check_vdu_cells_status}
        run keyword and continue on failure  Check Single Cell Or RU Status    single_vdu_cells_status=${cell}
        ...   expected_status=${expected_status_dict}
    END
    [Return]    ${vdu_cells_status}

Check Single Cell Or RU Status
    [Arguments]    ${single_vdu_cells_status}    ${expected_status}    ${if_cell}=${True}
    [Documentation]    Check Single Cell Or RU Status
    ...    param: expected_status (dict) – expect single cell status
    ...    example: {'administrative_state': 'Unlocked', 'availability_status': 'on line', 'blocking_state': 'Unblocked',
    ...    'operational_state': 'enabled', 'procedural_status': 'configured'}
    should be equal as strings  ${single_vdu_cells_status['administrative_state']}  ${expected_status['administrative_state']}
    should be equal as strings  ${single_vdu_cells_status['availability_status']}  ${expected_status['availability_status']}
    run keyword if    ${if_cell}    should be equal as strings  ${single_vdu_cells_status['blocking_state']}  ${expected_status['blocking_state']}
    should be equal as strings  ${single_vdu_cells_status['operational_state']}  ${expected_status['operational_state']}
    should be equal as strings  ${single_vdu_cells_status['procedural_status']}  ${expected_status['procedural_status']}

vDU Block or Unblock Cells
    [Arguments]  ${cell_id_list}    ${is_block}    ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    [Documentation]    VDU Block or Unblock Cells
    ${operation}    set variable if    ${is_block}    block    unblock
    log to console  \n*** Start ${operation} cell ***
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    FOR  ${cell}  IN  @{cell_id_list}
        ${operation_info}  run keyword if    ${is_block}    vdu.block_cell    cell_id=${cell}    vdu_connection=${connection}
        ...    ELSE    vdu.unblock_cell    cell_id=${cell}    vdu_connection=${connection}
    END
    ${expected_cell_status_dict}    vDU Set Expect Cell Status
    ${expected_status_dict}    set variable if    ${is_block}    ${expected_cell_status_dict['block_status']}
    ...    ${expected_cell_status_dict['onair_status']}
    wait until keyword succeeds  10s  5s    vDU Verify Cells Status Should Be As Expect    expected_status_dict=${expected_status_dict}
    ...    cell_id_list=${cell_id_list}     connection=${connection}
    [Teardown]  vDU Logout    connection=${connection}

vDU lock or Unlock Cells
    [Arguments]  ${cell_id_list}    ${is_lock}    ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    [Documentation]    VDU lock or unlock Cells
    ${operation}    set variable if    ${is_lock}    lock    unlock
    log to console  \n*** Start ${operation} cell ***
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${operation_info}  run keyword if    ${is_lock}    vdu.lock_cells    cell_id_list=${cell_id_list}    vdu_connection=${connection}
    ...    ELSE    vdu.unlock_cells    cell_id_list=${cell_id_list}    vdu_connection=${connection}
    ${expected_cell_status_dict}    vDU Set Expect Cell Status
    ${expected_status_dict}    set variable if    ${is_lock}    ${expected_cell_status_dict['lock_status']}
    ...    ${expected_cell_status_dict['onair_status']}
    wait until keyword succeeds  10s  5s    vDU Verify Cells Status Should Be As Expect    expected_status_dict=${expected_status_dict}
    ...    cell_id_list=${cell_id_list}     connection=${connection}
    [Teardown]  vDU Logout    connection=${connection}

vDU Verify Rmods Status Should Be As Expect
    [Arguments]  ${expected_status_dict}=${EMPty}    ${rmod_id_list}=${EMPTY}     ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    [Documentation]    vDU Verify Rmods Status Should Be As Expect
    ...    param: rmod_id_list (list), cell id should be int, if empty, check all rmods
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    log to console  \n*** Check Rmod Status ***
    ${list_len}    get length    ${rmod_id_list}
    @{rmod_id_list_1}    run keyword if   ${list_len}==${0}    Create list    ELSE    set variable    ${rmod_id_list}
    ${vdu_rmods_status}=  vdu.get_rmods_status  vdu_connection=${connection}
    @{vdu_rmods_status_tmp}    create list
    FOR  ${rmod_info}  IN  @{vdu_rmods_status}
        run keyword if    ${rmod_info['id']} in ${rmod_id_list_1}    append to list    ${vdu_rmods_status_tmp}    ${rmod_info}
    END
    ${tmp_list}    Get length    ${vdu_rmods_status_tmp}
    ${check_vdu_rmod_status}    set variable if    ${tmp_list}==${0}    ${vdu_rmods_status}    ${vdu_rmods_status_tmp}
    FOR  ${rmod}  IN  @{check_vdu_rmod_status}
        run keyword and continue on failure  Check Single Cell Or RU Status    single_vdu_cells_status=${rmod}
        ...    expected_status=${expected_status_dict}    if_cell=${False}
    END
    [Return]    ${vdu_rmods_status}
    [Teardown]  vDU Logout    connection=${connection}

vDU lock or Unlock Rmods
    [Arguments]  ${rmod_id_list}    ${is_lock}    ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    [Documentation]    VDU lock or unlock Rmod
    ${operation}    set variable if    ${is_lock}    lock    unlock
    log to console  \n*** Start ${operation} rmod ***
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${operation_info}  run keyword if    ${is_lock}    vdu.lock_rmods    rmod_id_list=${rmod_id_list}    vdu_connection=${connection}
    ...    ELSE    vdu.unlock_rmods    rmod_id_list=${rmod_id_list}    vdu_connection=${connection}
    ${expected_rmod_status_dict}    vDU Set Expect Rmod Status
    ${expected_status_dict}    set variable if    ${is_lock}    ${expected_rmod_status_dict['lock_status']}
    ...    ${expected_rmod_status_dict['onair_status']}
    wait until keyword succeeds  120s  10s    vDU Verify Rmods Status Should Be As Expect    expected_status_dict=${expected_status_dict}
    ...    rmod_id_list=${rmod_id_list}     connection=${connection}
    [Teardown]  Run Keyword And Ignore Error    vDU Logout    connection=${connection}

VDu Get PM Counters
    [Arguments]    ${counter_id_dict}    ${dist_name}    ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    Log to console    get ${dist_name} counters from webui.
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${counter_id_list}    get dictionary keys    ${counter_id_dict}
    ${counter_value}    Create dictionary
    FOR    ${counter_name}    IN    @{counter_id_list}
        ${counter_id}    set variable    ${counter_id_dict}[${counter_name}]
        ${last_word}    String.Fetch From Right    ${counter_name}    marker=_
        ${counter_dist_name}     set variable if    'PMQAP' in '${counter_name}'    ${dist_name}/${last_word}    ${dist_name}
        ${counter_result}    vdu.get_counter_values
        ...    counter_id=${counter_id}
        ...    dimension_dn=${counter_dist_name}
        ...    vdu_connection=${connection}
        set to dictionary    ${counter_value}    ${counter_name}=${counter_result}
    END
    [Return]   ${counter_value}
    [Teardown]    run keyword and ignore error    vDU Logout    connection=${connection}

Generate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}   ${connection}=DU_CON
    [Documentation]   Generate Delta Status Should Be Expected
    ${out}   vdu.Get_Delta_Plan_Generated_Action_Status   action_id=${action_id}   vdu_connection=${connection}
    Should Be True  "${out["status"]}"=="${expected_status}"

Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    [Arguments]   ${connection}=DU_CON
    [Documentation]   Check Maximum Delta Plan Number And delete one if reach Maximum number
    ${all_plans}   vdu.Get_Delta_Plan_Info_List  vdu_connection=${connection}
    Run Keyword If  ${all_plans.__len__()}==1   Delete Delta Plan By Plan Id   plan_id=${all_plans[0]["plan_id"]}  connection=${connection}

Delete Delta Plan By Plan Id
    [Arguments]  ${plan_id}  ${connection}=DU_CON
    [Documentation]   Delete Delta Plan By Plan Id
    ${out}    vdu.delete_delta_plan_file   plan_id=${plan_id}  vdu_connection=${connection}
    wait until keyword succeeds  60   5   Make Sure Delta Plan Is Deleted Once  connection=${connection}

Make Sure Delta Plan Is Deleted Once
    [Arguments]  ${connection}=DU_CON
    ${all_plans}   vdu.Get_Delta_Plan_Info_List  vdu_connection=${connection}
    Should Be True  ${all_plans.__len__()}==0

Generate Delta Plan
    [Arguments]    ${plan_name}  ${delete_old_one}=${True}   ${connection}=DU_CON
    [Documentation]   Generate Delta Plan
    run keyword if  "${delete_old_one}"=="${True}"   Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ...    connection=${connection}
    ${out}  vdu.Generate_Delta_Plan  plan_name=${plan_name}  vdu_connection=${connection}
    ${plan_id}   Set Variable  ${out["plan_id"]}
    ${action_id}   Set Variable  ${out["action_id"]}
    Wait Until Keyword Succeeds  30   3    Generate Delta Plan Status Should Be Expected    action_id=${action_id}
    ...    expected_status=success   connection=${connection}
    [Return]   ${plan_id}   ${action_id}

Update Delta Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}   ${connection}=DU_CON
    [Documentation]    Update Delta Plan Parameter Should Be Expected
    ${out}   vdu.get_update_paras_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}    vdu_connection=${connection}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Get Current Plan Parameters On Multiple MO
    [Arguments]    ${para_dict_list}   ${connection}=DU_CON
    @{output_list}    Create List
    FOR  ${para_dict}  IN  @{para_dict_list}
        ${current_para_dict}    Get Current Plan Parameters On One Mo    para_dict=${para_dict}    connection=${connection}
        Append To List    ${output_list}    ${current_para_dict}
    END
    [Return]    ${output_list}

Get Current Plan Parameters On One Mo
    [Arguments]    ${para_dict}    ${connection}=DU_CON
    ${current_para_value}    Create Dictionary
    ${mo_dn}    Get from dictionary    ${para_dict}    mo_dn
    ${updated_paras_dict}    Get from dictionary    ${para_dict}    updated_paras_dict
    ${para_list}    Get dictionary keys    ${updated_paras_dict}
    FOR  ${para_name}  IN  @{para_list}
        ${status}    Run Keyword And Return Status    Should Contain    ${para_name}    /
        ${para_name_tmp}    ${value_index}    Run Keyword If    ${status}    Get Current Plan Parameters Path On One Mo
        ...    para_name=${para_name}
        ${act_para_name}    Set Variable If    ${status}    ${para_name_tmp}    ${para_name}
        ${current_value}    vdu.search_parameter_of_current_plan    mo_dn=${mo_dn}    para_name=${act_para_name}    vdu_connection=${connection}
        ${current_value}    Set Variable If    ${status}    ${current_value[${value_index}]}    ${current_value}
        set to dictionary    ${current_para_value}    ${para_name}=${current_value}
    END
    ${current_para_dict}    Create Dictionary    mo_dn=${mo_dn}    updated_paras_dict=${current_para_value}
    [Return]    ${current_para_dict}

Get Current Plan Parameters Path On One Mo
    [Arguments]    ${para_name}
    ${para_name_list}    String.Split String    ${para_name}    /
    ${para_path_len}    Get Length    ${para_name_list}
    ${value_index}    Convert To Integer     ${para_name_list[${-1}]}
    ${act_para_name}    Set Variable If    '${para_path_len}'=='2'    ${para_name_list[-1]}    ${para_name_list[-2]}
    [Return]    ${act_para_name}    ${value_index}

VDu Compare The Current And Update Parameters Value
    [Arguments]    ${updated_paras_list}
    @{result_list}    Create List
    ${current_para_list}    Get Current Plan Parameters On Multiple MO    para_dict_list=${updated_paras_list}
    ${list_length}    Get Length    ${updated_paras_list}
    FOR  ${i}  IN RANGE  ${list_length}
        ${update_para_value}    Get From Dictionary    ${updated_paras_list[${i}]}    updated_paras_dict
        ${current_para_value}    Get From Dictionary    ${current_para_list[${i}]}    updated_paras_dict
        ${result}    Run Keyword And Return Status    Should Be Equal    ${update_para_value}    ${current_para_value}
        Append to list    ${result_list}    ${result}
    END
    [Return]    ${result_list}

Update Delta Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30   ${connection}=DU_CON
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.update_vdu_parameter_of_delta_plan   plan_id=${plan_id}  mo_dn=${mo_dn}    vdu_connection=${connection}
     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}    wait until keyword succeeds  20   2    Update Delta Plan Parameter Should Be Expected   plan_id=${plan_id}
    ...    action_id=${action_id}   expected_status=success    connection=${connection}
    [Return]  ${out}

Get VDU Parameter Value Online
    [Arguments]  ${mo_dn}   ${para_name}    ${timeout}=60   ${connection}=DU_CON
    [Documentation]   Get VDU Parameter Value Online
    ...   *Example*
    ...   | ${connection} | vdu rest login | gnb_index=0 | vdu_index=1 |
    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233 | para_name=btsName | vdu_connection=${connection} |
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}  vdu_connection=${connection}
    [Return]  ${out}

VDU Online Change Parameters By Delta Plan REST Multiple MO
    [Arguments]  ${plan_id}   ${updated_paras_list}    ${connection}=DU_CON
    FOR   ${one_mo_dict}   IN   @{updated_paras_list}
        ${mo_dn}  Get From Dictionary  ${one_mo_dict}   mo_dn
        ${updated_paras_dict}    Get From Dictionary    ${one_mo_dict}   updated_paras_dict
        ${operation}  Get From Dictionary  ${one_mo_dict}   operation
        Update Delta Plan Parameter  plan_id=${plan_id}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_dict}   operation=${operation}
        ...    connection=${connection}
    END

VDU Online Change Parameters Activate
    [Timeout]    20min
    [Arguments]    ${updated_paras_list}    ${vdu_index}=0  ${gnb_index}=0    ${connection}=DU_CON
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${updated_paras_json_str}    evaluate    json.dumps(${updated_paras_list})
    ${response}    vdu.perform_delta_recommissioning    delta_file=${updated_paras_json_str}    vdu_connection=${connection}
    ${status}    set variable    ${response['status']}
    Should be True    'success'=='${status}'
    [Teardown]    Run Keyword And Ignore Error    vDU Logout    connection=${connection}

VDU Online Change Parameters By Delta Plan Activate
    [Timeout]    20min
    [Arguments]    ${plan_name}    ${updated_paras_list}    ${vdu_index}=0  ${gnb_index}=0    ${connection}=DU_CON
    vDU Login    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${plan_id}   ${action_id}    Generate Delta Plan    plan_name=${plan_name}   connection=${connection}
    VDU Online Change Parameters By Delta Plan REST Multiple MO    plan_id=${plan_id}   updated_paras_list=${updated_paras_list}
    ...    connection=${connection}
    ${result_list}    VDu Compare The Current And Update Parameters Value    updated_paras_list=${updated_paras_list}
    ${compare_result}    Run Keyword And Return Status    List Should Contain Value    ${result_list}    ${False}
    ${validation_id}  Run Keyword If    ${compare_result}    Validate Delta Plan By REST  plan_id=${plan_id}
    Run Keyword If    ${compare_result}    Logging vDU Delta Plan Validation Error   plan_id=${planid}  validation_id=${validation_id}
    ...    connection=${connection}
    Run Keyword If    ${compare_result}    Activate Delta Plan By REST  plan_id=${plan_id}   timeout=60    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout    connection=${connection}

vDu Commssion And Check Cell On Air
    [Arguments]    ${scf_path}   ${vdu_index}=0  ${gnb_index}=0  ${connection}=DU_CON
    vDU Full Commssion By Rest    scf_path=${scf_path}   vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    vDU Verify Cells Status Should Be Onair    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${active_fault_id_list}    vDU Get Active Alarms    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${active_fault_num}    Get Length    ${active_fault_id_list}
    Should Be Equal as Integers  ${active_fault_num}  0

vDu Change Parameters And Check Cell On Air
    [Timeout]    20min
    [Arguments]    ${updated_paras_list}    ${vdu_index}=0    ${gnb_index}=0    ${connection}=DU_CON
    VDU Online Change Parameters Activate    updated_paras_list=${updated_paras_list}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ...    connection=${connection}
    vDU Verify Cells Status Should Be Onair    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${active_fault_id_list}    vDU Get Active Alarms    vdu_index=${vdu_index}  gnb_index=${gnb_index}  connection=${connection}
    ${active_fault_num}    Get Length    ${active_fault_id_list}
    Should Be Equal as Integers  ${active_fault_num}  0

Wait Until Wget Process Done
    [Arguments]   ${package_name}
    ${output}   Run   cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}

Download TTI Decoder Tool
    [Timeout]    10min
    [Arguments]    ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    ${software}    vDu Get software version    vdu_index=${vdu_index}     gnb_index=${gnb_index}     connection=${connection}
    ${software}    String.Split String    ${software}    _
    ${version_list}    String.Split String    ${software[${-1}]}    .
    ${release_list}    String.Split String    ${software[${0}]}    CNF
    ${release}    Run keyword if   '${version_list[${0}]}'=='0'      set variable   vDUCNF00
    ...   ELSE   set variable   vDUCNF${release_list[${-1}]}
    ${package_download_path}    Set Variable    ${download_http}/${release}/${release}_${software[${-1}]}/${release}_${software[${-1}]}_tti-dec.deb
    Create Directory    /home/ute/Downloads
    Run    sudo rm -rf /home/ute/Downloads*
    Run    sudo rm -rf /home/ute/wget-log*
    Wait Until Keyword Succeeds   30s   3s   OperatingSystem.File Should Not Exist   /home/ute/wget-log*
    Log    \n Start to Download Package From WFT!    INFO
    Run   wget -b ${package_download_path} -P /home/ute/Downloads
    Wait Until Keyword Succeeds   60s   10s   mmw4_coam_cloud_gnb.Wait Until wget process done    ${release}_${software[${-1}]}_tti-dec.deb
    Wait Until Keyword Succeeds   30s   3s    OperatingSystem.File Should Exist
    ...    /home/ute/Downloads/${release}_${software[${-1}]}_tti-dec.deb
    ${tti_dec_path}    set variable    /home/ute/Downloads/${release}_${software[${-1}]}_tti-dec.deb
    Log To Console    Download Package Finished!
    Run   export https_proxy="http://87.254.212.120:8080/"; sudo dpkg -i ${tti_dec_path}
#    Run   sudo gdebi ${tti_dec_path}
    [Return]    ${tti_dec_path}

Collect vdu snapshot
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0    ${connection}=DU_COAM
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}
    vDU Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}    connection=${connection}
    Log to console    save vdu snapshot
    ${snapshot_path}    vdu.get_local_snapshot    directory=${OUTPUT_DIR}/${TEST NAME}/    vdu_connection=${connection}
    ...    compressed_or_not=${True}
    Log to console    vdu snapshot saved in ${snapshot_path}
    [Return]    ${snapshot_path}
    [Teardown]    Run keyword and ignore error    vDU Logout    connection=${connection}

########### CU common KW #################
CU Login
    [Arguments]     ${gnb_index}=0   ${connection}=CU_CON
    [Documentation]    Create session to connect CU
    cu.connect to    port=${EMPTY}    secure=${True}    alias=${connection}
    ...    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}

CU Logout
    [Arguments]  ${connection}=CU_CON
    [Documentation]  Teardown rest session to CU.
    cu.disconnect   connection=${connection}

CU Check Plan Upload Status Should Be As Expected
   [Arguments]  ${operation_id}   ${expected_status}=success    ${connection}=CU_CON
   [Documentation]   Check plan upload status should be as expected.
   ${operation_response}=  cu.get_operation_state_of_uploading_plan    ${operation_id}    ${connection}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Validate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}=success   ${connection}=CU_CON
   [Documentation]   Check plan validate status should be as expected.
   ${operation_response}=  cu.get_operation_state_of_validating_plan     ${plan_id}    ${operation_id}    ${connection}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Activate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}=success   ${connection}=CU_CON
   [Documentation]   Check plan activate status should be as expected.
   ${operation_response}=  cu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}    ${connection}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Full Commssion By Rest
    [Arguments]    ${path_of_commission_file}    ${gnb_index}=0    ${connection}=CU_CON
    CU Login  gnb_index=${gnb_index}    connection=${connection}
    log to console   \n*** Start plan upload operation on VCU***
    ${response}    cu.perform_commissioning    scf_file=${path_of_commission_file}    connection=${connection}
    ${status}    set variable    ${response['status']}
    Should be True    'success'=='${status}'
    [Teardown]    CU Logout    connection=${connection}

CU Full Commssion By Rest with upload Plan file
    [Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0    ${connection}=CU_CON
    [Documentation]   Send BTS commission via rest.
     CU Login  gnb_index=${gnb_index}    connection=${connection}
     log to console   \n*** Start plan upload operation on VCU***
     ${upload_operation_info}=   cu.upload_plan_file     path_to_plan_file=${path_of_commission_file}   plan_name=${plan_name}
     ...    connection=${connection}
     log to console   \n*** Wait plan upload operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
     ...    operation_id=${upload_operation_info["action_id"]}    expected_status=success    connection=${connection}
     log to console   \n*** Start plan validate operation ***
     ${validate_operaition_info}=  cu.plan_validation    plan_id=${upload_operation_info["plan_id"]}    connection=${connection}
     log to console   \n*** Wait plan validate operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected    plan_id=${upload_operation_info["plan_id"]}
     ...   operation_id=${validate_operaition_info["action_id"]}    expected_status=success    connection=${connection}
     log to console   \n*** Start plan activate operation ***
     ${activate_operaition_info}=  cu.plan_activation   plan_id=${upload_operation_info["plan_id"]}    connection=${connection}
     log to console   \n*** Wait plan activate operation success in 5 mins ***
     wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected    connection=${connection}
     ...    plan_id=${upload_operation_info["plan_id"]}  operation_id=${activate_operaition_info["id"]}    expected_status=success
     [Teardown]    run keyword and ignore error   CU Logout    connection=${connection}

CU Generating Delta Plan Operation Should Be As Expected
    [Arguments]   ${action_id}   ${expected_status}=success    ${connection}=CU_CON
    [Documentation]   _Generating Delta Plan Operation Should Be Successful
	${res}   cu.get_action_state_of_generating_delta_plan   action_id=${action_id}   connection=${connection}
	should be equal as strings  ${res['status']}  ${expected_status}

CU Update Parameters Operation Should Be As Expected
    [Arguments]   ${plan_id}  ${action_id}   ${expected_status}=success    ${connection}=CU_CON
    [Documentation]   CU Online Parameter Change By Rest
	${res}=  cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
	...   connection=${connection}
	should be equal as strings  ${res['status']}  ${expected_status}

CU Validating Delta Plan Operation Should Be As Expected
    [Arguments]  ${plan_id}  ${action_id}   ${expected_status}=success    ${connection}=CU_CON
    [Documentation]   _Validating Delta Plan Operation Should Be Successful
    ${res}=    cu.get_action_state_of_validating_delta_plan   plan_id=${plan_id}  action_id=${action_id}   connection=${connection}
	should be equal as strings  ${res['status']}  ${expected_status}

Activating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}    ${connection}=CU_CON
    [Documentation]   _Activating Delta Plan Operation Should Be Successful
    Log to console    UnUsed variable: operation_id-${operation_id}
    ${res}=   cu.get_delta_plan_list   connection=${connection}
    FOR   ${r}   IN   @{res}
        ${r_plan_id}   Set Variable   ${r['plan_id']}
        Should Not Be Equal As Strings   ${r_plan_id}   ${plan_id}
    END

CU Validate Delta Plan
    [Arguments]  ${plan_id}    ${connection}=CU_CON
    [Documentation]   Validate Delta Plan By REST
    ${validate_res}=   cu.validate_delta_plan   plan_id=${plan_id}  connection=${connection}
    ${action_id}   Set Variable  ${validate_res["action_id"]}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s  CU Validating Delta Plan Operation Should Be As Expected
    ...	 plan_id=${plan_id}  action_id=${action_id}    expected_status=success    connection=${connection}

CU Activate Delta Plan
    [Arguments]  ${plan_id}    ${connection}=CU_CON
    ${active_res}=   cu.activate_delta_plan   plan_id=${plan_id}  connection=${connection}
	run keyword and continue on failure   Wait until keyword succeeds  10x  30s    Activating Delta Plan Operation Should Be Successful
	...    plan_id=${plan_id}  operation_id=${active_res['operation_id']}    connection=${connection}

Cu Generate Delta Plan
    [Arguments]    ${plan_name}    ${connection}=CU_CON
    ${delta_plan_list}     cu.get_delta_plan_list  connection=${connection}
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  plan_id=${delta_plan_list[0]['plan_id']}  connection=${connection}
    ${delta_res}=  cu.generate_delta_plan  plan_name=${plan_name}  connection=${connection}
    ${plan_id}=  Set Variable  ${delta_res['plan_id']}
    ${action_id}=  Set Variable  ${delta_res['action_id']}
	run keyword and continue on failure   Wait until keyword succeeds  3x  2s  CU Generating Delta Plan Operation Should Be As Expected
	...    action_id=${action_id}    expected_status=success    connection=${connection}
	[Return]   ${plan_id}   ${action_id}

Get CU Specifical MO UUID
    [Arguments]   ${plan_id}  ${mo_dn}   ${connection}=CU_CON
    [Documentation]   _Get CU Specifical MO UUID
    @{name_list}=   split_string    ${mo_dn}   /
    set suite variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
        ${mouuid}  Get CU Specifical MO UUID via DN Name   plan_id=${plan_id}  name=${name}   connection=${connection}
    END
    [Return]   ${mouuid}

Get CU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}   ${connection}=CU_CON
    [Documentation]  _Get CU Specifical MO UUID via DN Name
    &{delta_plan_tree}   cu.get_delta_plan_tree_diff   plan_id=${plan_id}   connection=${connection}
    @{plan_tree}=  Set Variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
        run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'
        ...  run keywords  set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
        run keyword if  '${mo_info["parent_mo_uuid"]}'=='None' and '${mo_info["name"]}'=='${name}'  run keywords
        ...    set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}

CU Update Delta Plan Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}   ${parameter_change_list}   ${connection}=CU_CON
	[Documentation]   CU Update Delta Plan Should Be Successful
    ...    | &{gNbCuName} | create dictionary | operation_type=add | parameter_path=/gNbCuName | value=cu_8 |
    ...    | &{para_nsaInactivityTimer} | create dictionary |  operation_type=replace | parameter_path=/nsaInactivityTimer | value=100 |
    ...    | @{mcc_Para_list}= | Create List | ${gNbCuName}  ${para_nsaInactivityTimer}|
    ...    | CU Update Delta Plan Should Be Successful | plan_id=${delta_plan_id}  |
    ...    | ...  mo_dn=MRBTS-1/NRBTS-1 | parameter_change_list=${mcc_Para_list} |
    ${uuid}    Get CU Specifical MO UUID    plan_id=${plan_id}  mo_dn=${mo_dn}   connection=${connection}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${parameter_change_list}   connection=${connection}
    ${action_id}  set variable  ${update_res['action_id']}
    run keyword and continue on failure  Wait until keyword succeeds  10x  5s    CU Update Parameters Operation Should Be As Expected
    ...    plan_id=${plan_id}  action_id=${action_id}    expected_status=success    connection=${connection}
    [Return]    ${update_res}

CU Get Delta Plan Parameters Status On Multiple MO
    [Arguments]    ${plan_id}    ${para_dict_list}    ${connection}=CU_CON
    @{output_list}    Create List
    FOR  ${para_dict}  IN  @{para_dict_list}
        ${status_list}    CU Get Delta Plan Parameters Status On One Mo    plan_id=${plan_id}    para_dict=${para_dict}    connection=${connection}
        Append To List    ${output_list}    ${status_list}
    END
    [Return]    ${output_list}

CU Get Delta Plan Parameters Status On One Mo
    [Arguments]    ${plan_id}    ${para_dict}    ${connection}=CU_CON
    @{status_list}    Create List
    ${parameter_change_list}    Get from dictionary    ${para_dict}    parameter_change_list
    FOR  ${parameter_dict}  IN  @{parameter_change_list}
        ${para_path}    Get from dictionary    ${parameter_dict}    parameter_path
        @{para_path_1}    String.Split String    ${para_path}    /
        ${para_path_len}    Get Length    ${para_path_1}
        ${para_name}    set variable if    ${para_path_len}==2    ${para_path_1[-1]}    ${para_path_1[-2]}
        ${value}   cu.search_parameters_of_delta_plan    plan_id=${plan_id}    parameter_name=${para_name}    connection=${connection}
        ${state}    CU Get Parameter State     para_list=${value['items']}    dist_name=${para_dict['mo_dn']}
        Append To List    ${status_list}    ${state}
    END
    [Return]    ${status_list}

CU Get Parameter State
    [Arguments]    ${para_list}    ${dist_name}
    FOR  ${para_info}  IN  @{para_list}
        ${state}    Run Keyword If    '${dist_name}'=='${para_info['distname']}'    Set Variable    ${para_info['state']}
        Run Keyword If    '${state}'!='None'    Exit For Loop
    END
    [Return]    ${state}

CU Parameters Should Be Changed
    [Arguments]    ${status_list}
    FOR  ${one_mo_para_state}  IN  @{status_list}
        ${result}    Run Keyword And Return Status    List Should Contain Value    ${one_mo_para_state}    changed
        Run Keyword If    '${result}'=='${True}'    Exit For Loop
    END
    [Return]    ${result}

CU Online Change Parameters By Delta Plan REST Multiple MO
    [Arguments]  ${plan_id}   ${updated_paras_list}    ${connection}=DU_CON
    FOR   ${one_mo_dict}   IN   @{updated_paras_list}
        ${mo_dn}  Get From Dictionary  ${one_mo_dict}   mo_dn
        ${parameter_change_list}    Get From Dictionary    ${one_mo_dict}   parameter_change_list
        CU Update Delta Plan Should Be Successful    plan_id=${plan_id}    mo_dn=${mo_dn}   parameter_change_list=${parameter_change_list}
        ...    connection=${connection}
    END

CU Online Change Parameters Activate
    [Arguments]  ${updated_paras_list}     ${connection}=CU_CON
    [Documentation]   CU Online Change Single Mo Parameters via rest.
    CU Login    connection=${connection}
    ${updated_paras_json_str}    evaluate    json.dumps(${updated_paras_list})
    ${response}    cu.perform_delta_recommissioning    delta_file=${updated_paras_json_str}    connection=${connection}
    ${status}    set variable    ${response['status']}
    Should be True    'success'=='${status}'
    [Teardown]    CU Logout    connection=${connection}

CU Online Change Parameters By Delta Plan Activate
    [Arguments]  ${updated_paras_list}     ${plan_name}=delta_plan   ${connection}=CU_CON
    [Documentation]   CU Online Change Single Mo Parameters via rest.
    CU Login    connection=${connection}
    ${plan_id}   ${action_id}    Cu Generate Delta Plan    plan_name=${plan_name}    connection=${connection}
    CU Online Change Parameters By Delta Plan REST Multiple MO    plan_id=${plan_id}   updated_paras_list=${updated_paras_list}
    ...    connection=${connection}
    ${status_list}    CU Get Delta Plan Parameters Status On Multiple MO    plan_id=${plan_id}    para_dict_list=${updated_paras_list}
    ${result}    CU Parameters Should Be Changed    status_list=${status_list}
    Run Keyword If    ${result}    CU Validate Delta Plan    plan_id=${plan_id}    connection=${connection}
    Run Keyword If    ${result}    CU Activate Delta Plan    plan_id=${plan_id}    connection=${connection}
    [Teardown]    CU Logout    connection=${connection}

CU Get Alarm
    [Arguments]  ${connection}=CU_CON
    [Documentation]   Check Alarm On Cu
    CU Login    connection=${connection}
    @{fault_id_list}  create list
    @{alarm_id_list}  create list
    ${out}    cu.get_active_alarms    connection=${connection}
    @{alarm_list}    get from dictionary    ${out}    alarms
    FOR  ${item}  IN  @{alarm_list}
        Append to list    ${fault_id_list}    ${item['fault_id']}
        Append to list    ${alarm_id_list}    ${item['alarm_id']}
    END
    [Return]    ${fault_id_list}  ${alarm_id_list}
    [Teardown]    CU Logout    connection=${connection}

Check CU on Air
    [Arguments]    ${gnb_index}=0    ${connection}=CU_CON
    CU Login    gnb_index=${gnb_index}    connection=${connection}
    ${x2_link_info_list}    Wait Until Keyword Succeeds   20m    30s  Get X2 Link    connection=${connection}
    FOR  ${x2_info}   IN  @{x2_link_info_list}
        Should Be Equal As Strings    ${x2_info['x2_link_status']}    available
    END
    [Teardown]    CU Logout    connection=${connection}

Get X2 Link
    [Arguments]    ${connection}=CU_CON
    [Documentation]   Get X2 Link
    ${x2_link}    cu.get_x2_links_info    connection=${connection}
    ${x2_link_info_list}    Set Variable    ${x2_link['created']}
    ${info_len}    Get Length    ${x2_link_info_list}
    Should Be True    ${info_len}>${0}
    [Return]    ${x2_link_info_list}

Check vDU And CU On Air
    [Arguments]    ${CU_connection}=CU_CON    ${DU_connection}=DU_CON    ${if_X2_check}=${True}
    Run Keyword if    ${if_X2_check}    Check CU on Air    connection=${CU_connection}
    ${cu_fault_id_list}  ${cu_alarm_id_list}    CU Get Alarm    connection=${CU_connection}
    ${cu_fault_num}    Get Length    ${cu_fault_id_list}
    Should Be Equal As Integers    ${cu_fault_num}    0
    vDU Verify Cells Status Should Be Onair    connection=${DU_connection}
    ${active_fault_id_list}    vDU Get Active Alarms  connection=${DU_connection}
    ${active_fault_num}    Get Length    ${active_fault_id_list}
    Should Be Equal as Integers  ${active_fault_num}  0

Set Default Scf
    [Arguments]    ${vdu_index}=0     ${gnb_index}=0     ${connection}=DU_CON
    ${software}    vDu Get software version    vdu_index=${vdu_index}     gnb_index=${gnb_index}     connection=${connection}
    ${software}    String.Split String    ${software}    _
    ${version_list}    String.Split String    ${software[${-1}]}    .
    Set Suite Variable    ${default_cu_scf}   SCF_${version_list[${0}]}.250.xml
    Set Suite Variable    ${default_du_scf}    SCF_${version_list[${0}]}.300.xml
    log to console    ${default_cu_scf}
    log to console    ${default_du_scf}

Collect cu snapshot
    [Arguments]    ${gnb_index}=0    ${connection}=CU_COAM
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}
    CU Login    gnb_index=${gnb_index}    connection=${connection}
    Log to console    save cu snapshot
    ${snapshot_path}    cu.get_local_snapshot    directory=${OUTPUT_DIR}/${TEST NAME}/    connection=${connection}
    ...    compressed=${True}
    Log to console    cu snapshot saved in ${snapshot_path}
    [Return]    ${snapshot_path}
    [Teardown]    Run keyword and ignore error    CU Logout    connection=${connection}

Cu Get PM Counters
    [Arguments]    ${counter_id_dict}    ${gnb_index}=0     ${connection}=CU_COAM
    Log to console    get counters from CU.
    CU Login    gnb_index=${gnb_index}    connection=${connection}
    ${counter_value}    Create dictionary
    ${counter_id_list}    Get Dictionary Keys    ${counter_id_dict}
    FOR  ${counter_name}    IN    @{counter_id_list}
        ${dimension_dn_list}    Get From Dictionary    ${counter_id_dict}    ${counter_name}
        ${value}    Cu Get PM Counter With Sam Counter ID    dimension_dn_list=${dimension_dn_list}    counter_id=${counter_name}
        Set To Dictionary    ${counter_value}    ${counter_name}    ${value}
    END
    [Return]   ${counter_value}
    [Teardown]    Run keyword and ignore error    CU Logout    connection=${connection}

Cu Get PM Counter With Sam Counter ID
    [Arguments]    ${dimension_dn_list}    ${counter_id}    ${connection}=CU_COAM
    @{counter_value_list}    Create List
    FOR  ${dimension_dn}    IN   @{dimension_dn_list}
        ${counter_info}    cu.get_counter    dimension_dist_name=${dimension_dn}    counter_id=${counter_id}
        ...    connection=${connection}    measurement_id=None
        ${value}    Get From Dictionary    ${counter_info}    values
        Append To List    ${counter_value_list}    ${value}
    END
    [Return]    ${counter_value_list}

########### Cloud logs capture #################
Get Pod name
    [Arguments]    ${host_ip}    ${username}    ${password}    ${filter}    ${namespace}    ${connection}=DU
    csn.connect_to   hostname=${host_ip}    username=${username}    password=${password}    alias=${connection}
    sleep    1s
    ${output}    csn.execute    command=kubectl get pods -n ${namespace} | grep ${filter} | awk -F' ' '{print $1}'
    ...    connection=${connection}
    ${pod_name_list}    Split String    string=${output}    separator=\r\n
    Log to console    pod_name: ${pod_name_list[${0}]}
    [Return]    ${pod_name_list[${0}]}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Start Capture SYSLOG on Cloud DU
    [Arguments]    ${pod_filter}=l2rt-a    ${syslog_filename}=L2RT_SYSLOG    ${connection}=DU
    ${pod}    Get Pod name    host_ip=${DU_IP}    username=${DU_username}    password=${DU_password}
    ...    namespace=${vdu_namespace}    connection=${connection}    filter=${pod_filter}
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    csn.send_command
    ...    command=kubectl logs -f -n ${vdu_namespace} ${pod} --since=1s > /tmp/${syslog_filename}.txt &
    ...    connection=${connection}
    sleep    2s
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Stop Capture SYSLOG on Cloud DU
    [Arguments]    ${pod_filter}=l2rt-a    ${connection}=DU
    ${pod}    Get Pod name    host_ip=${DU_IP}    username=${DU_username}    password=${DU_password}
    ...    namespace=${vdu_namespace}    connection=${connection}    filter=${pod_filter}
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    ${output}    csn.execute
    ...    command=ps -ef | grep kubectl | grep '${vdu_namespace} ${pod}' | awk '{print $2}'
    ...    connection=${connection}
    ${trace_id_list}    Strip String    string=${output}
    ${trace_id_list}    Split String    string=${output}    separator=\r\n
    log to console    \nfind pid: ${trace_id_list}
    FOR   ${trace_id}    IN    @{trace_id_list}
        ${output}    Run Keyword If    '${trace_id}'!=''    csn.execute    kill -9 ${trace_id.strip()}    connection=${connection}
        Run Keyword If    '${trace_id}'!=''    log to console    kill id: ${trace_id}
        sleep    1s
    END
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Start Capture tcpdump on Cloud CU
    [Arguments]    ${pod_filter}=cpif    ${pcap_filename}=tcpdump_cplane_cu    ${connection}=CU
    ${pod}    Get Pod name    host_ip=${CU_IP}    username=${CU_username}    password=${CU_password}
    ...    namespace=${vdu_namespace}    connection=${connection}    filter=${pod_filter}
    ${if_namespace_include}    Evaluate    '${vcu_namespace}' in '${pod}'
    ${module}    set variable if    ${if_namespace_include}    ctr-${vcu_namespace}-nwmgmt    ctr-nwmgmt
    csn.connect_to   hostname=${CU_IP}    username=${CU_username}    password=${CU_password}    alias=${connection}
    sleep    1s
    ${pcap_path}    set variable    /var/home/${CU_username}/${pcap_filename}.pcap
    ${command_str}    set variable
    ...    kubectl exec ${pod} -c ${module} -n ${vcu_namespace} -- nohup tcpdump -i any sctp -n -w - > ${pcap_path} &
    csn.send_command    command=${command_str}    connection=${connection}
    sleep    2s
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Stop Capture tcpdump on Cloud CU
    [Arguments]  ${connection}=CU
    csn.connect_to   hostname=${CU_IP}    username=${CU_username}    password=${CU_password}    alias=${connection}
    sleep    1s
    ${output}    csn.execute    command=ps -ef | grep kubectl | awk '{print $2}'    connection=${connection}
    ${trace_id_list}    Strip String    string=${output}
    ${trace_id_list}    Split String    string=${output}    separator=\r\n
    log to console    \nfind pid: ${trace_id_list}
    FOR   ${trace_id}    IN    @{trace_id_list}
        ${output}    Run Keyword If    '${trace_id}'!=''    csn.execute    kill -9 ${trace_id.strip()}    connection=${connection}
        Run Keyword If    '${trace_id}'!=''    log to console    kill id: ${trace_id}
        sleep    1s
    END
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Start Capture tcpdump on Cloud CU Via CU OAM
    [Arguments]    ${pod_filter}=cpif    ${connection}=cu_tcpdump_oam    ${gnb_index}=${0}
    ${pod}    Get Pod name    host_ip=${CU_IP}    username=${CU_username}    password=${CU_password}
    ...    namespace=${vdu_namespace}    connection=${connection}    filter=${pod_filter}
    CU Login    gnb_index=${gnb_index}    connection=${connection}
    ${pod_name}    Create List    ${pod}
    log to console    start capture cu tcpdump on pod:${pod}
    cu.start_ip_traffic_capture    capture_type=pod    measurement_point=NE_Terminated    pod_names=${pod_name}    connection=${connection}
    [Teardown]    run keyword and ignore error    CU Logout    connection=${connection}

Stop And Download Capture tcpdump on Cloud CU Via CU OAM
    [Arguments]    ${pod_filter}=cpif    ${connection}=cu_tcpdump_oam    ${gnb_index}=${0}
    ...    ${local_path}=${OUTPUT_DIR}/${TEST NAME}    ${tcpdump_file_name}=tcpdump_cplane_cu
    ${pod}    Get Pod name    host_ip=${CU_IP}    username=${CU_username}    password=${CU_password}
    ...    namespace=${vdu_namespace}    connection=${connection}    filter=${pod_filter}
    ${pod_name}    Create List    ${pod}
    log to console    stop capture cu tcpdump on pod:${pod}
    CU Login    gnb_index=${gnb_index}    connection=${connection}
    cu.stop_ip_traffic_capture    connection=${connection}
    Wait Until Keyword Succeeds    5min    5s    Check CU Tcpdump status    pod_name=${pod_name}
    ...    status_check=captureCompleted    connection=${connection}
    cu.generate_ip_traffic_capture_files    credentials=${Empty}    connection=${connection}
    ${filename}    Wait Until Keyword Succeeds    5min    5s    Check CU Tcpdump status    pod_name=${pod_name}
    ...    status_check=generationCompleted    connection=${connection}
    ${upload_info}    cu.activated_file_upload_operation    connection=${connection}
    cu.upload_ip_traffic_capture_file    operation_id=${upload_info['operation_id']}    file_name=${filename}    local_path=${local_path}
    ...    connection=${connection}
    cu.delete_file_upload_operation    connection=${connection}
    run    gunzip ${local_path}/${filename}
    ${n_filename}    String.fetch From Left    ${filename}    marker=.
    sleep    3s
    run    mv ${local_path}/${n_filename}.pcap ${local_path}/${tcpdump_file_name}.pcap
    [Return]    ${local_path}/${tcpdump_file_name}.pcap
    [Teardown]    run keyword and ignore error    CU Logout    connection=${connection}

Check CU Tcpdump status
    [Arguments]    ${pod_name}    ${status_check}=generationCompleted    ${connection}=cu_tcpdump_oam
    ${state}    cu.get_ip_traffic_capture_status    connection=${connection}
    FOR    ${item}    IN    @{state['pod_status']}
        ${if_pod_name_exists}    Evaluate    '${item['pod_name']}' in ${pod_name}
        ${filename}    set variable    ${item['file_name']}
        ${cap_status}    set variable    ${item['capture_status']}
        Exit For Loop If    ${if_pod_name_exists}
    END
    should be true    '${status_check}'=='${cap_status}'
    [Return]    ${filename}

Download tcpdump from Cloud CU
    [Arguments]    ${pcap_filename}    ${connection}=CU    ${ute_logpath}=${OUTPUT_DIR}/${TEST NAME}
    csn.connect_to   hostname=${CU_IP}    username=${CU_username}    password=${CU_password}    alias=${connection}
    sleep    1s
    ${log_full_path_ute}    set variable     ${ute_logpath}/${pcap_filename}.pcap
    csn.download_file   remote_path=/var/home/${CU_username}/${pcap_filename}.pcap   local_path=${log_full_path_ute}   connection=${connection}
    Wait Until Keyword Succeeds   2min   2s    OperatingSystem.File Should Exist    ${log_full_path_ute}
    #    csn.execute    command=rm /tmp/${filename}.pcap    connection=${connection}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Download syslog from Cloud DU
    [Arguments]    ${syslog_filename}=L2Lo_tput    ${connection}=DU    ${ute_logpath}=${OUTPUT_DIR}/${TEST NAME}
    ...    ${remote_path}=/var/home/core
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    ${log_full_path_ute}    set variable     ${ute_logpath}/${syslog_filename}.txt
    csn.download_file   remote_path=${remote_path}/${syslog_filename}.txt   local_path=${log_full_path_ute}   connection=${connection}
    Wait Until Keyword Succeeds   2min   2s    OperatingSystem.File Should Exist    ${log_full_path_ute}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Convert pcap to text
    [Arguments]    ${pcap_filename}    ${filter}    ${connection}=ute    ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    log to console    covert pcap to text
    ${source}      set variable     ${logpath}/${pcap_filename}.pcap
    ${target}      set variable     ${logpath}/${pcap_filename}.txt
    csn.connect_to   hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    csn.send_command
    ...  command=nice tshark -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    Wait Until Keyword Succeeds   2min   2s    OperatingSystem.File Should Exist    ${target}
    [Return]    ${target}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Get L2stream logs using cOAM cli from Cloud DU
    [Documentation]    https://confluence.ext.net.nokia.com/display/CV/%5Bdeprecated%5D+L2stream3_Collectors+Example
    ...    (L2Lo, L2Ps, L2HiRlc, L2HiPdcp)
    [Arguments]    ${collectors_name}=l2stream    ${component}=L2Ps    ${output_path}=${OUTPUT_DIR}/${TEST NAME}/
    ...    ${cell_dn_list}=${cell_list}
    log to console    start tti
    ${webservice}=  Create Dictionary
    ...  host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...  user=${DU_OAM_username}
    ...  password=${DU_OAM_password}
    ${l2lo_stream_config}=  Create Dictionary
    ...  trace_type=Component
    ...  target_component=${component}
    ...  nr_cell_dn_list=${cell_dn_list}
    @{l2_stream_configuration}    Create List    ${l2lo_stream_config}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth0 udp and dst ${TEST_PC_IP} and dst port 5678
    ...  sudo_password=${TEST_PC_PASSWORD}
    l2stream3.create vdu l2stream collector
    ...  name=${collectors_name}
    ...  webservice=${webservice}
    ...  destination_ip_addr=${TEST_PC_IP}
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  timeout=60
    run keyword and ignore error     core.stop_collectors      names=${collectors_name}
    run keyword and ignore error     core.teardown_collectors      names=${collectors_name}
    core.setup_collectors      names=${collectors_name}
    log to console    start capture.
    core.start_collectors      names=${collectors_name}
    core.set_suite_alias    alias=${collectors_name}
    [Return]    ${output_path}l2stream/tcpdump/tcpdump.pcap

Stop Capture L2TTI Trace for Cloud DU
    [Arguments]    ${collectors_name}=l2stream    ${output_path}=${OUTPUT_DIR}/${TEST NAME}/
    log to console    stop capture
    core.stop_collectors      names=${collectors_name}
    core.collect_collectors      names=${collectors_name}    target_dir=${output_path}
    log to console    end
    [Return]    ${output_path}l2stream/tcpdump/tcpdump.pcap
    [Teardown]    core.teardown_collectors      names=${collectors_name}

Decode TTI Traces from PCAP or BIN for Cloud DU
    [Documentation]    Decodes TTI Traces from PCAP or BIN file to output files in CSV or JSON format.
    ...                Program ``/opt/tti-dec/tti-dec-bin/bin/eventDecoder`` is used for legacyCsv and json conversion.
    ...                Script ``/opt/tti-dec/tti-dec-bin/outputGenerator/excelCsv/ExcelCsvGenerator.py`` is used for
    ...                excelCsv conversion.
    ...                - ``input_filepath``: Path to input PCAP or BIN file
    ...                - ``output_path``: Path to output directory, Default: Same as input file
    ...                - ``output_name``: Prefix name of the output files, Default: ttitrace
    ...                - ``format``: json, legacyCsv or excelCsv, Default: legacyCsv
    ...                - ``conversion_filter``: Regular expression for filtering TTI event type, Default: None
    ...                - ``excel_csv_options``: Options for ExcelCsvGenerator.py script, Default: None
    [Arguments]    ${input_filepath}    ${output_path}=${Empty}    ${output_name}=ttitrace    ${format}=legacyCsv
    ...    ${conversion_filter}=${None}    ${excel_csv_options}=${None}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${input_filepath}
    ${match}    ${dir}    @{rest}    Should Match Regexp    ${input_filepath}    ^(.*/)([^/]+)\\.(pcap|bin)$
    ...    msg=Invalid KW parameter: input_filepath
    Should Be True    '${format}' in ('json','legacyCsv','excelCsv')    msg=Invalid KW parameter: format
    #---------------------------------------------------------------------------------------------------------------
    ${output_path}    Set Variable If    '${output_path}' == ''    ${dir}    ${output_path}
    ${output_file_path}    Set Variable    ${output_path}/${output_name}
    ctti.create_eventdecoder_converter
    ...    name=tti_converter
    ...    input_file_path=${input_filepath}
    ...    output_file_path=${output_file_path}
    ...    output_file_format=${format}
    ...    conversion_filter=${conversion_filter}
    ...    excel_csv_options=${excel_csv_options}
    Log to Console    Decoding TTI Traces...
    ${status}    ${msg}    Run Keyword And Ignore Error    ctti.convert    tti_converter
    Run Keyword If    '${status}' == 'FAIL'    Fail
    ...    Error decoding TTI Traces. Ensure the decoder version matches the BTS build version.${\n}${msg}
    ${ext}    Set Variable If    'Csv' in '${format}'    csv    json
    ${files}    Find Files    ${output_path}   -name    '*.${ext}'    fail_on_empty=yes    return=dict
    [Return]    ${files}

Run Process And Expect Success
    [Documentation]    Runs a process and fails if return status is not 0. Returns result object.
    ...                - ``process``: Process name
    ...                - ``params``: Process parameters as list
    ...                - ``shell``: Specifies whether to run the command in shell, Default: True
    ...                - ``msg``: Custom fail message, Default: Standard message
    ...                - ``config``: Additonal process configuration,\
    ...                See: https://robotframework.org/robotframework/3.1.2/libraries/Process.html#Process%20configuration
    [Arguments]    ${process}    @{params}    ${shell}=${True}    ${msg}=${Empty}    &{config}
    ${result}    Run Process    ${process}    @{params}    shell=${shell}    &{config}
    Log    stdout: ${result.stdout}${\n}stderr: ${result.stderr}${\n}rc: ${result.rc}    level=DEBUG
    ${mlen}    Get Length    ${msg}
    ${msg}    Set Variable If    ${mlen} == 0    Error running ${process} @{params}    ${msg}
    ${msg}    Set Variable    ${msg}${\n}stdout: ${result.stdout}${\n}stderr: ${result.stderr}
    Should Be Equal As Integers    ${result.rc}    0    values=${False}    msg=${msg}
    [Return]    ${result}

Find Files
    [Documentation]    Searches for files in directory hierarchy via ``find`` command and returns a list of files.
    ...                WARNING: Do not pass unquoted wildcards into search patterns (Use: ``-name '*.json'``, not: ``-name *.json``).
    ...                Use single-quotes only.
    ...                - ``dir``: Directory to search in
    ...                - ``params``: List of search parameters for ``find`` command, See: https://manpages.org/find
    ...                - ``fail_on_empty``: If keyword should fail when no files are found, Default: no
    ...                - ``return``: Type of return data: list or dict, Default: list
    [Arguments]    ${dir}    @{params}    ${fail_on_empty}=no    ${return}=list
    #--------- Param check -----------------------------------------------------------------------------------------
    Directory Should Exist    ${dir}
    Should Be True    '${fail_on_empty}' in ('yes','no')    msg=Invalid KW parameter: fail_on_empty
    Should Be True    '${return}' in ('list','dict')    msg=Invalid KW parameter: return
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Create List    find    ${dir}    -type    f    @{params}
    ${result}    Run Process And Expect Success    @{cmd}
    ${list}    Split To Lines    ${result.stdout}
    Run Keyword If    '${fail_on_empty}' == 'yes'    Should Not Be Empty    ${list}
    ...    msg=No files were found using command: @{cmd}
    ${dict}    Create Dictionary
    FOR    ${path}    IN    @{list}
      ${dir}    ${filename}    Split Path    ${path}
      ${name}    ${ext}    Split Extension    ${filename}
      #tcpdump_DlDataBurstInfoIndTx in build "vDUCNF26R2_0.300.33278", So add below code to split
      ${new_name}    String.Fetch From Right    ${name}    marker=_
      Set To Dictionary    ${dict}    ${new_name}=${path}
    END
    ${files}    Set Variable If    '${return}' == 'dict'    ${dict}    ${list}
    [Return]    ${files}

Start L1L2bip log for Cloud DU
    [Arguments]    ${component}=po-${vdu_namespace}-l2rt-a-0    ${module}=ctr-${vdu_namespace}-l2rt    ${connection}=DU
    ...    ${port}=0
    Log to console    start bip
    csn.connect_to   hostname=${DU_IP}    username=${DU_core_username}    password=${DU_core_password}    alias=${connection}
    sleep    1s
    csn.send_command
    ...    command=oc exec -it ${component} -c ${module} -n ${vdu_namespace} -- rm -rf /tmp/l1up.pcap
    ...    connection=${connection}    #kubectl
    csn.send_command
    ...    command=oc exec -it ${component} -c ${module} -n ${vdu_namespace} -- hal-cli pdump port ${port} path /tmp
    ...    connection=${connection}    #kubectl
    Sleep    1s    msg=wait for start bip log successfull
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}


Stop L1L2bip log for Cloud DU
    [Arguments]    ${component}=po-${vdu_namespace}-l2rt-a-0    ${module}=ctr-${vdu_namespace}-l2rt    ${connection}=DU
    Log to console    stop bip
    csn.connect_to   hostname=${DU_IP}    username=${DU_core_username}    password=${DU_core_password}    alias=${connection}
    ${cmd}    Catenate    SEPARATOR=${SPACE}    oc exec -it ${component} -c ${module} -n ${vdu_namespace}
    ...    -- bash -c "ps -eo "pid,comm" | grep dpdk-pdump | xargs -n 1 kill -2"
    csn.send_command    command=${cmd}    connection=${connection}
    Sleep    1s    msg=wait for stop bip log successfull
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}


#Stop L1L2bip log for Cloud DU
#    [Arguments]    ${component}=po-${vdu_namespace}-l2rt-a-0    ${module}=ctr-${vdu_namespace}-l2rt    ${connection}=DU
#    Log to console    stop bip
#    csn.connect_to   hostname=${DU_IP}    username=${DU_core_username}    password=${DU_core_password}    alias=${connection}
#    ${output}    csn.execute
#    ...    command=ps -ef | grep '${component}' | grep '${module}' | grep 'hal-cli pdump' | awk '{print $2}'
#    ...    connection=${connection}    #kubectl
#    ${trace_id_list}    Strip String    string=${output}
#    ${trace_id_list}    Split String    string=${output}    separator=\r\n
#    log to console    \nfind pid: ${trace_id_list}
#    FOR   ${trace_id}    IN    @{trace_id_list}
#        ${output}    Run Keyword If    '${trace_id}'!=''    csn.execute    kill -9 ${trace_id.strip()}    connection=${connection}
#        Run Keyword If    '${trace_id}'!=''    log to console    kill id: ${trace_id}
#        sleep    1s
#    END
#    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Download L1L2bip log for Cloud DU
    [Arguments]    ${component}=po-${vdu_namespace}-l2rt-a-0    ${module}=ctr-${vdu_namespace}-l2rt    ${connection}=DU
    ...    ${ute_logpath}=${OUTPUT_DIR}/${TEST NAME}    ${remote_path}=/var/home/core    ${port_name}=l1up    ${log_name}=l1bip
    Log to console    download bip
    csn.connect_to   hostname=${DU_IP}    username=${DU_core_username}    password=${DU_core_password}    alias=${connection}
    csn.send_command
    ...    command=oc cp ${component}:tmp/${port_name}.pcap -c ${module} ${remote_path}/${log_name}.pcap -n ${vdu_namespace}
    ...    connection=${connection}    #kubectl
    sleep    5s
    ${log_full_path_ute}    set variable     ${ute_logpath}/${log_name}.pcap
    csn.download_file   remote_path=${remote_path}/${log_name}.pcap   local_path=${log_full_path_ute}   connection=${connection}
    Wait Until Keyword Succeeds   2min   2s    OperatingSystem.File Should Exist    ${log_full_path_ute}
    Log to console    bip log saved: ${log_full_path_ute}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Covert Pcap To Pdml
    [Arguments]  ${pcap_file}   ${output_file}    ${filter}
    Set Test Variable    ${command}    tshark -V -r ${pcap_file} -Y ${filter} -T pdml > ${output_file}
    Run    ${command}

####### cloud common operation #######
vDU RANNIC Reset And Check cell status
    [Documentation]    rannic_r_dn (str) – RNICMOD_R distname, for example: MRBTS-10778/EQM_R-1/APEQM_R-1/RNICMOD_R-1
    [Arguments]    ${runnic_r_dn}    ${vdu_index}=${0}    ${gnb_index}=${0}    ${connection}=DU
    vDU Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}    connection=${connection}
    ${result}    vdu.reset_rannic    rannic_r_dn=${runnic_r_dn}    graceful_cell_shutdown=${True}    vdu_connection=${connection}
    ${operation_id}    get from dictionary    ${result}    id
    wait until keyword succeeds    10min  20s    Get vDU RANNIC reset status    operation_id=${operation_id}    connection=${connection}
    wait until keyword succeeds    20min  30s    Check vDU And CU On Air
    [Teardown]  Run Keyword And Ignore Error    vDU Logout    connection=${connection}

Get vDU RANNIC reset status
    [Arguments]    ${operation_id}    ${connection}=DU
    log to console    Verify RANNIC reset status...
    ${result}    get_rnic_reset_operation    operation_id=${operation_id}    vdu_connection=${connection}
    ${status}    get from dictionary    ${result}    status
    Should Be Equal As Strings    ${status}    success

vDU RU Reset And Check cell status
    [Documentation]    rmods_list (list(str)) – list of runtime RMOD IDs,
    ...    for example: ['MRBTS-37441/EQM-1/APEQM-1/RMOD-5', 'MRBTS-37441/EQM-1/APEQM-1/RMOD-6']
    [Arguments]    ${rmods_list}    ${vdu_index}=${0}    ${gnb_index}=${0}    ${connection}=DU
    vDU Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}    connection=${connection}
    ${result}    vdu.reset_rmods    rmods_list=${rmods_list}    graceful_cell_shutdown=${True}    vdu_connection=${connection}
    ${operation_id}    get from dictionary    ${result}    operation_id
    wait until keyword succeeds    10min  20s    Get vDU RU reset status    operation_id=${operation_id}    connection=${connection}
    wait until keyword succeeds    20min  30s    Check vDU And CU On Air
    [Teardown]  Run Keyword And Ignore Error    vDU Logout    connection=${connection}

Get vDU RU reset status
    [Arguments]    ${operation_id}    ${connection}=DU
    log to console    Verify RU reset status...
    ${result}    get_reset_rmods_operation_status    operation_id=${operation_id}    vdu_connection=${connection}
    ${status}    get from dictionary    ${result}    status
    Should Be Equal As Strings    ${status}    success

vDU Reset And Check cell status
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}    ${connection}=DU
    vDU Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}    connection=${connection}
    ${result}    vdu.reset_vdu    timeout=${120}    vdu_connection=${connection}
    ${operation_id}    get from dictionary    ${result}    id
    wait until keyword succeeds    10min  10s    Get vDU Reset Status    operation_id=${operation_id}    connection=${connection}
    wait until keyword succeeds    20min  30s    Check vDU And CU On Air
    [Teardown]  Run Keyword And Ignore Error    vDU Logout    connection=${connection}

Get vDU Reset Status
    [Arguments]    ${operation_id}    ${connection}
    log to console    Verify vDU reset status...
    ${result}    get_reset_vdu_operation_status    operation_id=${operation_id}    vdu_connection=${connection}
    ${status}    get from dictionary    ${result}    status
    Should Be Equal As Strings    ${status}    ongoing
