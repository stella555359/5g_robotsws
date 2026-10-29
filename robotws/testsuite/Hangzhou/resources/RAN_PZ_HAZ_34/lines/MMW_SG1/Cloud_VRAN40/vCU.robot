*** Settings ***
Documentation
...    Author: Ding Binmei
...    Main functions are related with cloud vCU

Library    taf.gnb.oam.coam.cu    WITH NAME    cu
Library    BuiltIn
Library    taf.rfrl.cbts.devices.vcu.base.vcu_cm_base.vCUCM    WITH NAME    rfrl_vcu_cm_base
Library    taf.rfrl.cbts.devices.vcu.business.vcu_cm_business    WITH NAME   rfrl_vcu_cm_business
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/vran40/cloud_gnb.py


*** Keywords ***
_Main Functions for search
    Connect to vcu via rest api
    Teardown vcu connection
    Commission on vcu
    Wait for vcu ready and cells are on air
    Get vCU Version via rest api
    Get vCU Program via rest api
    Get gNbType SA or NSA via vCU rest api
    Get VCU Parameter Value In Current PLan
    VCU Collect Snapshot To Local

Connect to vcu via rest api
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${gnb_index}=${0}    ${connection}=OAM_CU${gnb_index}
    cu.connect to    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=${connection}
    [Return]  ${connection}

Teardown vcu connection
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${connection}=OAM_CU0
    cu.disconnect    connection=${connection}

Get vCU Version via rest api
    [Documentation]    Author: Dandan Fang
    ...                Get vCU Version by rest api and return the vCU version
    [Arguments]  ${connection}=OAM_CU0
    ${vcu_version}=     cu.get_active_software_version    connection=${connection}
    [Return]    ${vcu_version}

Get vCU Program via rest api
    [Documentation]    Author: Dandan Fang
    ...                Get vCU Program Version, like master, or 24R2 , 24R1
    [Arguments]  ${connection}=OAM_CU0
    ${vcu_version}=      Get vCU Version via rest api   connection=${connection}
    @{vcu_version}    Get regexp matches    ${vcu_version}    vCUCNF(.*?)_    1
    ${vcu_version}       Strip string    ${vcu_version[0]}
    ${program_version}     Set variable if    '${vcu_version}'=='vCUCNF00'   master    ${vcu_version}
    [Return]    ${program_version}

Get gNbType SA or NSA via vCU rest api
    [Documentation]    Author: Dandan Fang
    ...                Description: get gNB type by rest api, gNB type:SA,NSA,both
    [Arguments]  ${gnb_index}=0      ${connection}=OAM_CU${gnb_index}    ${parameter_name}=gNbCuType
    ${MRBTS_Instance}    set variable     ${tl.gnbs[${gnb_index}].cu.instance_id}
    ${NRBTS_Instance}    set variable     ${tl.gnbs[${gnb_index}].cu.global_bts_id}
    ${gNbType}     Get VCU Parameter Value In Current PLan    distname=MRBTS-${MRBTS_Instance}/NRBTS-${NRBTS_Instance}
    ...        parameter_name=${parameter_name}      connection=${connection}    gnb_index=${gnb_index}
    [Return]   ${gNbType}

Get VCU Parameter Value In Current PLan
    [Documentation]    Author: Dandan Fang
    ...                Description: get one vcu parameters value in current plan
   [Arguments]       ${distname}   ${parameter_name}   ${gnb_index}=0  ${connection}=OAM_CU${gnb_index}
   ${para_result}    cu.search_parameters_of_current_plan    parameter_name=${parameter_name}   connection=${connection}
   ${result_length}          get length    ${para_result['items']}
   ${param_index}    set variable  ${None}
   FOR    ${tmp_index}    IN RANGE    ${result_length}
       ${tmp_distname}    set variable    ${para_result['items'][${tmp_index}]['distname']}
       ${tmp_para}        set variable    ${para_result['items'][${tmp_index}]['parameter_name']}
       ${param_index}     Run Keyword If    "${tmp_distname}" == "${distname}" and "${tmp_para}" == "${parameter_name}"
       ...                Set Variable    ${tmp_index}
       exit for loop if    "${tmp_distname}" == "${distname}" and "${tmp_para}" == "${parameter_name}"
   END

   ${para_value}    Run Keyword If    "${param_index}"!="${None}"
   ...       set variable    ${para_result['items'][${param_index}]['parameter']['simple_parameter']['value']}
   [Return]   ${para_value}

Check vnfc status are as expected on vcu
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${exp_operational_state}=enabled    ${exp_availability_status}=on line    ${connection}=OAM_CU0
    @{list_cu_vnfc}    cu.get_vnfcs_states    connection=${connection}
    FOR  ${vnfc}  IN  @{list_cu_vnfc}
        Run keyword and continue on failure    should be equal as strings  ${vnfc['operational_state']}    ${exp_operational_state}
        ...    msg=pod ${vnfc['name']} operational state check failed    ignore_case=${True}
        Run keyword and continue on failure    should be equal as strings  ${vnfc['availability_status']}    ${exp_availability_status}
        ...    msg=pod ${vnfc['name']} availability status check failed    ignore_case=${True}
    END

Check F1 link is up on vcu
    [Documentation]  Author: Ding Binmei
    ...    Based on the return data from get_du_state, only 1 DU is supported.
    [Arguments]  ${connection}=OAM_CU0
    &{du_status}    cu.get_du_state    connection=${connection}
    Run keyword and continue on failure    Should Be Equal As Numbers  ${du_status['administrative_state']['locked']}    0
    Run keyword and continue on failure    Should Be Equal As Numbers  ${du_status['f1_link_status']['unavailable']}    0

Check X2 status on vcu
    [Documentation]  Author: Ding Binmei
    ...    exp_x2_link_status: supported values: available, unavailable
    ...    exp_x2_link_lock: supported values: locked, unlocked
    [Arguments]  ${connection}=OAM_CU0    ${exp_x2_link_status}=available    ${exp_x2_link_lock}=unlocked
    &{x2_status}    cu.get_x2_links_info    connection=${connection}
    @{list_x2_status}    set variable    ${x2_status['created']}
    ${len_x2}    Get length    ${list_x2_status}

    FOR    ${x2_link}    IN    @{list_x2_status}
        run keyword and continue on failure    should be equal as strings    ${x2_link['x2_link_status']}    ${exp_x2_link_status}
        ...    ignore_case=${True}
        run keyword and continue on failure    should be equal as strings    ${x2_link['x2_link_lock']}    ${exp_x2_link_lock}
        ...    ignore_case=${True}
    END

Check all cells are on cell on air status on vcu
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${connection}=OAM_CU0
    @{list_cell_info}    cu.get_cells_statuses    connection=${connection}
    FOR    ${cell_info}    IN    @{list_cell_info}
        Run keyword and continue on failure    should be equal as strings  ${cell_info['operational_state']}    enabled
        ...    msg=Cell status check failed for ${cell_info['dist_names']['config']}    ignore_case=${True}
        Run keyword and continue on failure    should be equal as strings  ${cell_info['administrative_state']}    Unlocked
        ...    msg=Cell status check failed for ${cell_info['dist_names']['config']}    ignore_case=${True}
    END

Check cell status are as expected based on cell id on vcu
    [Documentation]  Author: Ding Binmei
    ...    ${cell_id}: like 1
    ...    ${administrative_state}: unlocked / locked
    ...    ${operational_state}: enabled / disabled
    [Arguments]  ${cell_id}    ${administrative_state}    ${operational_state}    ${connection}=OAM_CU0
    ${cell_id}    Evaluate    int(${cell_id})
    &{cu_cell_mapping}    cloud_gnb.get_relation_mapping_between_cell_and_others_from_cu    connection=${connection}
    Dictionary Should Contain Key    ${cu_cell_mapping}    ${cell_id}    msg=cell_id ${cell_id} doesn't exist, please check if your input is correct
    ${cell_info_for_specific_cell_id}    Set variable    ${cu_cell_mapping[${cell_id}]['detail_cells_info']}
    ${act_cell_administrative_state}    Set variable    ${cell_info_for_specific_cell_id['administrative_state']}
    ${act_cell_operational_state}    Set variable    ${cell_info_for_specific_cell_id['operational_state']}
    Run keyword and continue on failure    Should Be Equal As Strings    ${act_cell_administrative_state}    ${administrative_state}
    ...    msg=Cell status check failed for ${cell_id}    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings    ${act_cell_operational_state}    ${operational_state}
    ...    msg=Cell status check failed for ${cell_id}    ignore_case=${True}

Wait for vcu ready and cells are on air
    [Timeout]    20 min
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}    ${timeout}=10 min   ${retry_interval}=5 sec
    Log to console    Start to check status for vcu
    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Connect to vcu via rest api    gnb_index=${gnb_index}    connection=${connection}
    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Check vnfc status are as expected on vcu    connection=${connection}
    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Check F1 link is up on vcu    connection=${connection}
    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Check X2 status on vcu    connection=${connection}
    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Check all cells are on cell on air status on vcu    connection=${connection}

Commission on vcu
    [Documentation]  Author: Ding Binmei
    ...    scf_file_path: Input file path for scf commission
    [Arguments]  ${cu_scf_file_path}    ${connection}=OAM_CU0
    ...    ${timeout_commission}=10 min
    Log to console    \n************Start VCU commission*************************
#    Remove extra planned configurations if exist on vcu    connection=${connection}
    cu.perform_commissioning    scf_file=${cu_scf_file_path}    timeout=${timeout_commission}    wait_for_completion=${True}
    ...    should_activate=${True}    connection=${connection}

VCU Collect Snapshot To Local
    [Arguments]     ${snapshot_file_dir}=${TS_CASE_LOG_PATH}/vcu_snapshot
    ...             ${gnb_index}=${0}  ${conn_alias}=OAM_CU${gnb_index}_vcu_snapshot  ${snapshot_time}=900
    ...             ${save_ongoing_snapshot}=${True}   ${compressed}=${True}
    [Documentation]    Gets local snapshot and saves it under given file path.
    ...  author:             dandan.fang@nokia-sbell.com
    ...    *RETURN VALUE*
    ...   The full path file name of snapshot, e.g, ${TS_CASE_LOG_PATH}/vcu_snapshot/Snapshot_20231229-135637.zip
    ...
    ...    Example
    ...    | ${snapshot_file} | VCU Collect Snapshot To Local |
    ...
   Connect to vcu via rest api    gnb_index=${gnb_index}   connection=${conn_alias}
   ${is_folder_exist}    run keyword and return status    directory_should_exist    path=${snapshot_file_dir}
   run keyword if    '${is_folder_exist}'=='False'    create_directory    path=${snapshot_file_dir}
   OperatingSystem.create_directory  path=${snapshot_file_dir}

   ${snapshot_status}   cu.Check_snapshot_status   connection=${conn_alias}
   Run Keyword If  "${snapshot_status}"=="idle"     cu.get_local_snapshot
   ...      directory=${snapshot_file_dir}     connection=${conn_alias}   operation_timeout=${snapshot_time}  compressed=${compressed}
   ...    ELSE IF    "${snapshot_status}"=="local-ongoing" and '${save_ongoing_snapshot}'=='${True}'
   ...    _vCU Save Ongoing Snapshot  snapshot_file_dir=${snapshot_file_dir}    conn_alias=${conn_alias}
   ...    compressed=${compressed}    operation_timeout=${snapshot_time}

   ${file_list}=   List_Directory   ${snapshot_file_dir}
   ${file_num}=   Get Length   ${file_list}
   Should Be True    ${file_num}>0   No snapshot files found in local after saving snapshot operation!
   [Teardown]   Teardown vcu connection   connection=${conn_alias}

_vCU Save Ongoing Snapshot
    [Arguments]    ${snapshot_file_dir}=${TS_CASE_LOG_PATH}/vcu_snapshot     ${conn_alias}=OAM_CU0
    ...           ${operation_timeout}=900    ${compressed}=${True}
    ${snapshot_infor}     cu.get_snapshot_operations_information     connection=${conn_alias}
    FOR    ${info}    IN    @{snapshot_infor}
        ${operation_id}     Set Variable    ${info['operation_id']}
        cu.get_local_snapshot_by_id    directory=${snapshot_file_dir}
        ...                            operation_id=${operation_id}    compressed=${compressed}
        ...                            connection=${conn_alias}   operation_timeout=${operation_timeout}
    END

Get Parameter Definition Error For CU
    [Documentation]  Author: Dandan Fang
    ...    ongoing status won't be returned
    ...    param plan_id: staged plan id
    ...    param validation_id: validation id returned from validation operation
    ...    param error_type: parameterRelationError, topologyDefinitionError, occurrenceDefinitionError,
    ...                       parameterDefinitionError, topologyRelationError
    ...                       default is none meaning all of the error types
    ...    param connection: VcuConnection object or string name alias if used
    ...    return: the dict of all of errors or the specific error
    [Arguments]   ${plan_id}  ${validation_id}  ${connection}=OAM_CU0
    ${errors}    cu.get_validation_result_of_staged_plan    plan_id=${plan_id}    validation_id=${validation_id}
    ...    connection=${connection}
    ${error_num}    Set Variable    ${errors["total"]}
    Return From Keyword If  ${error_num}==${0}    ${error_num}
    [Return]  ${error_num}

Fix Missed and Mandatory Parameters For vCU
    [Documentation]  Author: Dandan Fang
    ...    fix vcu staged plan error
    [Arguments]    ${plan_id}    ${connection}=OAM_CU0
    ${fix_error_response}=    cu.fix_plan_validation_errors    plan_id=${plan_id}   add_missing_objects=${True}
    ...    fix_mandatory_parameters=${True}    connection=${connection}
    ${action_id}    Set Variable    ${fix_error_response['action_id']}
    wait until keyword succeeds    2min    5s    _Check Fix Errors Status Should Be Expected For vCU
    ...   plan_id=${plan_id}    action_id=${action_id}   connection=${connection}

_Check Fix Errors Status Should Be Expected For vCU
    [Arguments]    ${plan_id}    ${action_id}  ${connection}=OAM_gnb0_du0
    [Documentation]   checking fix errors operation status should be successful
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from fix_plan |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ${fix_error_response}=    cu.get_action_state_of_fix_plan
    ...  plan_id=${plan_id}    action_id=${action_id}    connection=${connection}
    should be equal as strings    ${fix_error_response['status']}    success

#Remove extra planned configurations if exist on vcu
#    [Documentation]  Author: Ding Binmei
#    ...    This is limitation for plan number, so we'll remove extra plans before doing commission / online modification
#    ...    configuration plan: max num is 3
#    [Arguments]    ${connection}=OAM_CU0
#    @{list_planned_config}    cu.get_staged_plans_list    connection=${connection}
#    ${len_plan_config}    Get length    ${list_planned_config}
#    Run keyword if    ${len_plan_config}==0    Log to console   No extra in-active planned configuration exist, no need to remove
#    FOR    ${planned_config}    IN    @{list_planned_config}
#        cu.plan_delete    plan_id=${planned_config['plan_id']}    connection=${connection}
#        Log to console    Remove extra in-active planned configuration with plan name: ${planned_config['plan_name']}
#    END

Download vCU SCF file to Local
    [Documentation]    author: dandan fang
    ...    download cu scf file
    [Arguments]     ${current_time}    ${cu_scf_name}=SCF_mannual_commission_cu
    ...     ${gnb_index}=${0}     ${connection}=OAM_CU${gnb_index}_download_scf    ${local_dir}=${TS_CASE_LOG_PATH}
    ...     ${include_runtime_data}=${False}
    Connect to vcu via rest api    gnb_index=${gnb_index}   connection=${connection}
    ${cu_scf_file_path}     Set Variable    ${local_dir}/${cu_scf_name}_${current_time}.xml
    cu.get_current_plan_file    path=${cu_scf_file_path}    timeout=60   connection=${connection}
    ...             include_runtime_data=${include_runtime_data}
   [Teardown]   Teardown vcu connection   connection=${connection}
