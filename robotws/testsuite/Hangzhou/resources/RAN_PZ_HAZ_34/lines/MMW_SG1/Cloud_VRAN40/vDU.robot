*** Settings ***
Documentation
...    Author: Ding Binmei
...    Main functions are related with cloud vDU
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library    taf.gnb.oam.coam.vdu    WITH NAME    vdu
Library    taf.rfrl.cbts.devices.vdu.base.vdu_cm_base.vDUCM    WITH NAME    rfrl_vdu_cm_base
Library    taf.rfrl.cbts.devices.vdu.business.vdu_cm_business      WITH NAME    vdu_cm_business
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/vran40/cloud_gnb.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/online_nidd_process.py


*** Keywords ***
_Main Functions for search
    Connect to vdu via rest api
    Teardown vdu connection
    Commission on vdu
    Wait for vdu ready and cells are on air
    VDU Collect Snapshot To Local
    Perform reset RUs
    Verify RU status are as expected
    Change status for parameter cellBarred on GNB DU

Connect to vdu via rest api
    [Documentation]  *Author:* Ding Binmei
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=OAM_gnb${gnb_index}_du${du_index}
    vdu.connect_to    host=${tl.gnbs[${gnb_index}].dus[${du_index}].oam_http_connection_details.addr}
    ...    port=${EMPTY}    username=${tl.gnbs[${gnb_index}].dus[${du_index}].oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].oam_http_connection_details.password}
    ...    secure=${True}    connection_name=${connection}
    [Return]  ${connection}

Teardown vdu connection
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${connection}=OAM_gnb0_du0
    vdu.disconnect    vdu_connection=${connection}

Check RU status on vdu
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${connection}=OAM_gnb0_du0
    @{list_rmod_info}    vdu.get_rmods_status    vdu_connection=${connection}
    FOR    ${rmod_info}    IN    @{list_rmod_info}
        run keyword and continue on failure    should be equal as strings    ${rmod_info['administrative_state']}    Unlocked
        ...    msg=Check administrative state failed for ${rmod_info['dist_names']}, RU type: ${rmod_info['product_name']}    ignore_case=${True}
        run keyword and continue on failure    should be equal as strings    ${rmod_info['availability_status']}    on line
        ...    msg=Check availability status failed for ${rmod_info['dist_names']}, RU type: ${rmod_info['product_name']}    ignore_case=${True}
        run keyword and continue on failure    should be equal as strings    ${rmod_info['operational_state']}    enabled
        ...    msg=Check operational state failed for ${rmod_info['dist_names']}, RU type: ${rmod_info['product_name']}    ignore_case=${True}
        run keyword and continue on failure    should be equal as strings    ${rmod_info['procedural_status']}    configured
        ...    msg=Check procedural_status failed for ${rmod_info['dist_names']}, RU type: ${rmod_info['product_name']}    ignore_case=${True}
    END

Check vnfc status are as expected on vdu
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${exp_operational_state}=enabled    ${exp_availability_status}=on line    ${connection}=OAM_gnb0_du0
    @{list_du_vnfc}    vdu.get_pods_info    vdu_connection=${connection}
    FOR  ${vnfc}  IN  @{list_du_vnfc}
        Run keyword and continue on failure    should be equal as strings  ${vnfc['operational_state']}    ${exp_operational_state}
        ...    msg=pod ${vnfc['name']} operational state check failed    ignore_case=${True}
        Run keyword and continue on failure    should be equal as strings  ${vnfc['availability_status']}    ${exp_availability_status}
        ...    msg=pod ${vnfc['name']} availability status check failed    ignore_case=${True}
    END

_Check all host status are synced on vdu
    [Documentation]  Author: Ding Binmei    [PRIVATE]
    ...    ptp_sync_output_for_host: output from get_ptp_sync_status_from_plan and select only the host info
    [Arguments]  ${ptp_sync_output_for_host}
    FOR    ${host_sync_info}    IN    @{ptp_sync_output_for_host}
         Run keyword and continue on failure      Should be equal as strings    ${host_sync_info['lock_status']}    Locked    ignore_case=${True}
        ...    msg=Host lock status is incorrect, targetDN: ${host_sync_info['host_targetDN']}
         Run keyword and continue on failure      Should be equal as strings    ${host_sync_info['sync_status']}    Locked    ignore_case=${True}
        ...    msg=Host sync status is incorrect, targetDN: ${host_sync_info['host_targetDN']}
     END

_Check all rannic status are synced on vdu
    [Documentation]  Author: Ding Binmei    [PRIVATE]
    ...    ptp_sync_output_for_rannic: output from get_ptp_sync_status_from_plan and select only the rannic info
    [Arguments]  ${ptp_sync_output_for_rannic}
    FOR    ${rannic_sync_info}    IN    @{ptp_sync_output_for_rannic}
        ${is_lock_status_exist}    Run keyword and return status
        ...    Dictionary should contain key    ${rannic_sync_info}    lock_status    ignore_case=${True}
        Run keyword if    ${is_lock_status_exist}
        ...    Run keyword and continue on failure      Should be equal as strings    ${rannic_sync_info['lock_status']}    Locked
        ...        ignore_case=${True}    msg=Host lock status is incorrect, targetDN: ${rannic_sync_info['rannic_targetDN']}
        ...    ELSE    Log to console    Sync type is GPS, skip lock status check for rannic
        Run keyword and continue on failure      Should be equal as strings    ${rannic_sync_info['sync_status']}    Locked    ignore_case=${True}
        ...    msg=Host sync status is incorrect, targetDN: ${rannic_sync_info['rannic_targetDN']}
     END

Check sync status on vdu
    [Documentation]  Author: Ding Binmei
    ...    Check RMOD sync status
    ...    Check host sync status
    ...    Check RANNIC sync status
    [Arguments]    ${connection}=OAM_gnb0_du0
    @{list_rmod_sync_status}    vdu.get_rmods_syncinfolist    vdu_connection=${connection}
    FOR    ${rmod_sync_status}    IN    @{list_rmod_sync_status}
        Run keyword and continue on failure      Should be equal as strings    ${rmod_sync_status['state']}    Locked    ignore_case=${True}
        ...    msg=RMOD is not in sync status for ${rmod_sync_status['dist_name']}
    END
    @{list_ptp_sync_status}    vdu.get_ptp_sync_status_from_plan    vdu_connection=${connection}    mrbts_id=${tl.gnbs[0].dus[0].instance_id}
    FOR    ${ptp_sync}    IN    @{list_ptp_sync_status}
        Run keyword and continue on failure      _Check all host status are synced on vdu    ptp_sync_output_for_host=${ptp_sync['host']}
        Run keyword and continue on failure      _Check all rannic status are synced on vdu    ptp_sync_output_for_rannic=${ptp_sync['rannic']}
    END

Check all cells are on cell on air status on vdu
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${connection}=OAM_gnb0_du0
    @{list_cell_info}    vdu.get_vdu_cells_status    vdu_connection=${connection}
    FOR    ${cell_info}    IN    @{list_cell_info}
        Run keyword and continue on failure    should be equal as strings  ${cell_info['operational_state']}    enabled
        ...    msg=Cell status check failed for ${cell_info['dist_names']['config']}    ignore_case=${True}
        Run keyword and continue on failure    should be equal as strings  ${cell_info['administrative_state']}    Unlocked
        ...    msg=Cell status check failed for ${cell_info['dist_names']['config']}    ignore_case=${True}
        Run keyword and continue on failure    should be equal as strings  ${cell_info['availability_status']}    on line
        ...    msg=Cell status check failed for ${cell_info['dist_names']['config']}    ignore_case=${True}
        Run keyword and continue on failure    should be equal as strings  ${cell_info['procedural_status']}    configured
        ...    msg=Cell status check failed for ${cell_info['dist_names']['config']}    ignore_case=${True}
    END

Wait for vdu ready and cells are on air
    [Timeout]    10 min
    [Documentation]  Author: Ding Binmei.
    ...    After sync method changed in new sw, taf method for vdu.get_ptp_sync_status_from_plan need to be rewrite,
    ...    So not to check for sync part tempolory. https://jiradc.ext.net.nokia.com/browse/TAF-3849
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=OAM_gnb${gnb_index}_du${du_index}
    ...    ${timeout}=10 min   ${retry_interval}=5 sec
    Log to console    Start to check status for vdu
    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Connect to vdu via rest api    gnb_index=${gnb_index}    du_index=${du_index}    connection=${connection}
    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Check vnfc status are as expected on vdu    connection=${connection}
    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Check RU status on vdu    connection=${connection}
#    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
#    ...    Check sync status on vdu    connection=${connection}
    Run keyword and continue on failure    wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Check all cells are on cell on air status on vdu    connection=${connection}

Get Parameter Definition Error
    [Documentation]  Author: Dandan Fang
    ...    ongoing status won't be returned
    ...    param plan_id: staged plan id
    ...    param validation_id: validation id returned from validation operation
    ...    param error_type: parameterRelationError, topologyDefinitionError, occurrenceDefinitionError,
    ...                       parameterDefinitionError, topologyRelationError
    ...                       default is none meaning all of the error types
    ...    param vdu_connection: VduConnection object or string name alias if used
    ...    return: the dict of all of errors or the specific error
    [Arguments]   ${plan_id}  ${validation_id}  ${vdu_connection}=OAM_gnb0_du0
    ${errors}    vdu.get_staged_plan_validation_results    plan_id=${plan_id}    validation_id=${validation_id}
    ...    vdu_connection=${vdu_connection}
    ${error_num}    Set Variable    ${errors["total"]}
    [Return]  ${error_num}

Fix Missed and Mandatory Parameters For vDU
    [Documentation]  Author: Dandan Fang
    ...    fix vdu staged plan error
    [Arguments]    ${plan_id}    ${vdu_connection}=OAM_gnb0_du0
    ${fix_error_response}=    vdu.fix_vdu_staged_plan_error    stage_plan_id=${plan_id}   add_missing_obj=${True}
    ...    vdu_connection=${vdu_connection}
    ${action_id}    Set Variable    ${fix_error_response['action_id']}
    wait until keyword succeeds    2min    5s    _Check Fix Errors Status Should Be Expected   ${plan_id}    ${action_id}

_Check Fix Errors Status Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}  ${connection}=OAM_gnb0_du0
    [Documentation]   checking fix errors operation status should be successful
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from fix_plan |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ${fix_error_response}=    vdu.get_fix_vdu_staged_plan_operation_status
    ...  stage_plan_id=${plan_id}    action_id=${action_id}    vdu_connection=${connection}
    should be equal as strings    ${fix_error_response['status']}    success

Commission on vdu
    [Documentation]  Author: Ding Binmei
    ...    vdu_scf_file_path: Input file path for commission
    [Arguments]  ${du_scf_file_path}    ${gnb_index}=0    ${du_index}=0    ${connection}=OAM_gnb${gnb_index}_du${du_index}
    ...    ${timeout_commission}=10 min
    Log to console    \n************Start VDU commission*************************
#    Remove extra planned configurations if exist on vdu    connection=${connection}
    vdu.perform_commissioning    scf_file=${du_scf_file_path}    timeout=${timeout_commission}    wait_for_completion=${True}
    ...    should_activate=${True}    vdu_connection=${connection}

Get vDU Version via rest api
    [Arguments]  ${vdu_connection}=OAM_gnb0_du0
    ${vdu_data}=    vdu.get_vdu_state_data  vdu_connection=${vdu_connection}
    ${vdu_version}    set variable    ${vdu_data['software_version']}
    [Return]    ${vdu_version}

VDU Collect Snapshot To Local
    [Arguments]     ${snapshot_file_dir}=${TS_CASE_LOG_PATH}/vdu_snapshot   ${compressed_or_not}=${True}
    ...             ${gnb_index}=${0}   ${du_index}=${0}   ${conn_alias}=OAM_gnb${gnb_index}_du${du_index}_snapshot
    ...             ${snapshot_time}=900    ${save_ongoing_snapshot}=${True}
    [Documentation]    Gets local snapshot and saves it under given file path.
    ...  author:             dandan.fang@nokia-sbell.com
    ...    *RETURN VALUE*
    ...   The full path file name of snapshot, e.g, ${TS_CASE_LOG_PATH}/vdu_snapshot/Snapshot_20231229-135637.zip
    ...
    ...    Example
    ...    | ${snapshot_file} | VDU Collect Snapshot To Local |
    ...
   Connect to vdu via rest api   gnb_index=${gnb_index}   du_index=${du_index}    connection=${conn_alias}
   ${is_folder_exist}    run keyword and return status    directory_should_exist    path=${snapshot_file_dir}
   run keyword if    '${is_folder_exist}'=='False'    create_directory    path=${snapshot_file_dir}
   OperatingSystem.create_directory  path=${snapshot_file_dir}

   ${snapshot_status}   vdu.Check_snapshot_status   vdu_connection=${conn_alias}
   Run Keyword If  "${snapshot_status}"=="idle"     vdu.get_local_snapshot
   ...      directory=${snapshot_file_dir}     vdu_connection=${conn_alias}
   ...      operation_timeout=${snapshot_time}   compressed_or_not=${compressed_or_not}
   ...    ELSE IF    "${snapshot_status}"=="local-ongoing" and '${save_ongoing_snapshot}'=='${True}'
   ...    _vDU Save Ongoing Snapshot  snapshot_file_dir=${snapshot_file_dir}    conn_alias=${conn_alias}
   ...   operation_timeout=${snapshot_time}      compressed_or_not=${compressed_or_not}

   ${file_list}=   List_Directory   ${snapshot_file_dir}
   ${file_num}=   Get Length   ${file_list}
   Should Be True    ${file_num}>0   No snapshot files found in local after saving snapshot operation!
   [Teardown]    Teardown vdu connection   connection=${conn_alias}

_vDU Save Ongoing Snapshot
    [Arguments]    ${snapshot_file_dir}     ${conn_alias}=OAM_gnb0_du0   ${compressed_or_not}=${True}
    ...       ${operation_timeout}=900
    ${snapshot_infor}     vdu.get_snapshot_operations_information     vdu_connection=${conn_alias}
    FOR    ${info}    IN    @{snapshot_infor}
        ${operation_id}     Set Variable    ${info['operation_id']}
        vdu.check_local_snapshot_status_and_save_it    directory=${snapshot_file_dir}
        ...                                        operation_id=${operation_id}
        ...                                        vdu_connection=${conn_alias}
        ...                                        compressed_or_not=${compressed_or_not}
        ...                                        operation_timeout=${operation_timeout}
    END

#Remove extra planned configurations if exist on vdu
#    [Documentation]  Author: Ding Binmei
#    ...    This is limitation for plan number, so we'll remove extra plans before doing commission / online modification
#    ...    configuration plan: max num is 3
#    [Arguments]    ${connection}=OAM_gnb0_du0
#    @{list_planned_config}    vdu.get_staged_plans_info_list    vdu_connection=${connection}
#    ${len_plan_config}    Get length    ${list_planned_config}
#    Run keyword if    ${len_plan_config}==0    Log to console   No extra in-active planned configuration exist, no need to remove
#    FOR    ${planned_config}    IN    @{list_planned_config}
#        vdu.delete_staged_plan_file    plan_id=${planned_config['plan_id']}    vdu_connection=${connection}
#        Log to console    Remove extra in-active planned configuration with plan name: ${planned_config['plan_name']}
#    END

Download vDU SCF file to Local
    [Documentation]    author: Dandan Fang
    ...    download vdu scf file
    [Arguments]     ${current_time}    ${gnb_index}=${0}  ${du_index}=${0}
    ...    ${vdu_connection}=OAM_gnb${gnb_index}_du${du_index}_download_scf
    ...    ${local_dir}=${TS_CASE_LOG_PATH}   ${scf_name_suffix}=suite_setup
    Connect to vdu via rest api   gnb_index=${gnb_index}   du_index=${du_index}    connection=${vdu_connection}
    ${filename}     Set Variable    ${vdu_connection}_${scf_name_suffix}_${current_time}.xml
    vdu.get_current_plan_file    local_dir_path=${local_dir}    filename=${filename}
    ...                    timeout=60    vdu_connection=${vdu_connection}
    [Teardown]    Teardown vdu connection   connection=${vdu_connection}

Change status for parameter cellBarred on GNB DU
    [Documentation]  Author: Ding Binmei
    ...    exp_status: supported values: barred, notBarred
    ...    list_cell_ids: can be a list for cell index, and also can be a string, like 1;
    ...                   Default to all: all cells on GNB will be updated
    ...    connection:
    ...    if partially ids are provided, then all these cells will be modified to exp_status, like (barred/notBarred)
    ...    and all the rest cells will be set as oppsite status, like (notBarred/barred)
    [Arguments]    ${exp_status}    ${list_cell_ids}=all    ${gnb_index}=0    ${du_index}=0    ${connection}=OAM_gnb${gnb_index}_du${du_index}
    ...    ${timeout}=${120}
    &{dict_update_param}    coam_gnb_classical.Change status for parameter cellBarred on GNB    exp_status=${exp_status}
    ...    list_cell_ids=${list_cell_ids}    connection=${connection}    gnb_index=${gnb_index}    du_index=${du_index}
    online_nidd_process.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_update_param}
    ...    connection=${connection}    bts_type=du    timeout=${timeout}

Online Modify Parameters through REST API on DU
	[Documentation]
    ...    *AUTHOR* dandan.fang@nokia-sbell.com
    ...    |  Input Parameters          | Man. | Description |
    ...                                     | delta plan name, default value is DELTA-PLAN-1.  |
    ...                                      ``[
    ...                                        ['mo1', {'param1/0/sub_param_1':'value1_1',
    ...                                                 'param1/0/sub_param_2':'value1_2',
    ...                                                  'param2':'value2'}, 'update'],
    ...                                        ['mo2', {'param1':'value1', 'param2':'value2'}, 'update'],
    ...                                     | No | delta plan name, default value is DELTA-PLAN-1.  |
    ...                                       ['mo2', {'param3':'', 'param3/0/sub_param1':'value1'}, 'create'],
    ...                                      | No | delta plan name, default value is DELTA-PLAN-1.  |
    ...                                       ['mo3', {'param3':'', 'param4/0':''}, 'delete']
    ...                                        ]``
    ...    | force_reset              | No | The force reset option (default: true)  |
    ...    | auto_lock_cells          | No | The auto lock cells option (default: true)  |
    ...    | vdu_connection           | No  |  rest api connection alias, default value is 'default'. |
    ...    *RETURN VALUE*
    ...    local_full_dir.
    ...  Only return the original values of those parameters whose operation type is ``replace``.
    ...        It can be used to restore the parameters in case teardown if all of the operation types are ``replace``.
    ...         The data structure is the same as the argument ``delta_data_list``.
    ...    Note:  force_reset if as true, meet " UM service is not available or Connection refused due to NE reset"
    [Arguments]
    ...      ${delta_data_list}=${EMPTY_LIST}
    ...      ${vdu_connection}=OAM_gnb0_du0  ${rest_api_timeout}=${300}
    ...      ${force_reset}=${False}     ${auto_lock_cells}=${True}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${delta_plan_name}     set variable  du_delta_plan_${timestamp}
    run keyword if     ${delta_data_list}      vdu_cm_business.delta_commission_step_by_step
    ...    delta_data_list=${delta_data_list}
    ...    delta_plan_name=${delta_plan_name}    force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}      timeout=${rest_api_timeout}   conn_alias=${vdu_connection}

Get active alarms on VDUs
    [Documentation]  Author: Ding Binmei
    ...    du_connection_list: should be a list
    ...    return value with dict as bellow: {du_connection_alias:{alarms:[],total:XX}}
    [Arguments]    ${du_connection_list}
    ${dict_active_alarms}    Create dictionary
    FOR    ${vdu_connection}    IN    @{du_connection_list}
        ${active_alarms}    Run keyword and continue on failure    vdu.vdu_get_active_alarms    vdu_connection=${vdu_connection}
        Set to dictionary    ${dict_active_alarms}    ${vdu_connection}    ${active_alarms}
    END
    [Return]  ${dict_active_alarms}

Perform reset RUs
    [Documentation]  Author: Ding Binmei
    ...    ${rmods_list}: support both string and list. like: '1' or ['1', '2']
    ...    ${expected_status}: available values are: ongoing, success, failed
    ...        success: when RU is up after reset, then it will return with success status
    [Arguments]    ${rmods_list}    ${expected_status}=ongoing    ${timeout}=1min    ${connection}=OAM_gnb0_du0
    ${rmods_list}    string_list.string2list    ${rmods_list}
    ${reset_rmods_result}    vdu.reset_rmods    rmods_list=${rmods_list}    vdu_connection=${connection}
    ${operation_id}    Set variable    ${reset_rmods_result['operation_id']}
    Wait until keyword succeeds    ${timeout}    2sec
    ...    _Verify Reset RU operation status should be as expected    operation_id=${reset_rmods_result['operation_id']}
    ...        expected_status=${expected_status}    connection=${connection}
    [Return]  ${operation_id}

Perform RMOD lock
    [Documentation]  Author: Lingxue Cui
    ...    ${rmods_list}: support both string and list. like: '1' or ['1', '2']
    [Arguments]    ${rmods_list}    ${timeout}=1min    ${connection}=OAM_gnb0_du0
    ${rmods_list_tmp}    string_list.string2list    ${rmods_list}
    ${rmods_list}    create list
    FOR   ${rmod_id}    IN    @{rmods_list_tmp}
        ${rmod_id}    evaluate    str(${rmod_id})
        Append To List    ${rmods_list}    ${rmod_id}
    END

    Log to console    Going to lock RMOD ${rmods_list}!
    ${result}    vdu.lock_rmods    rmod_id_list=${rmods_list}    vdu_connection=${connection}

    Wait until keyword succeeds    ${timeout}    2sec
    ...    _Verify Lock rmods operation status should be as expected    operation_id=${result['id']}
    ...        expected_status=success    connection=${connection}
    Wait until keyword succeeds    ${timeout}    5sec
    ...    Verify RU status are as expected    rmods_list=${rmods_list}    connection=${connection}
    ...    exp_availability_status=on line    exp_operational_state=enabled    exp_administrative_state=locked

Perform RMOD unlock
    [Documentation]  Author: Lingxue Cui
    ...    ${rmods_list}: support both string and list. like: '1' or ['1', '2']
    [Arguments]    ${rmods_list}    ${timeout}=1min    ${connection}=OAM_gnb0_du0
    ${rmods_list_tmp}    string_list.string2list    ${rmods_list}
    ${rmods_list}    create list
    FOR   ${rmod_id}    IN    @{rmods_list_tmp}
        ${rmod_id}    evaluate    str(${rmod_id})
        Append To List    ${rmods_list}    ${rmod_id}
    END

    Log to console    Going to unlock RMOD ${rmods_list}!
    ${result}    vdu.unlock_rmods    rmod_id_list=${rmods_list}    vdu_connection=${connection}

    Wait until keyword succeeds    ${timeout}    2sec
    ...    _Verify Unlock rmods operation status should be as expected    operation_id=${result['id']}
    ...        expected_status=success    connection=${connection}
    Wait until keyword succeeds    ${timeout}    5sec
    ...    Verify RU status are as expected    rmods_list=${rmods_list}    connection=${connection}
    ...    exp_availability_status=on line    exp_operational_state=enabled    exp_administrative_state=unlocked

_Verify Reset RU operation status should be as expected
    [Documentation]    Author: Ding Binmei
    ...    ${operation_id}: returned from keyword 'Reset RUs and verify reset operation status is as expected'
    ...    ${expected_status}: available values are: ongoing, success, failed
    ...        success: when RU is up after reset, then it will return with success status
    [Arguments]    ${operation_id}    ${expected_status}    ${connection}=OAM_gnb0_du0
    ${reset_status}    vdu.get_reset_rmods_operation_status    operation_id=${operation_id}    vdu_connection=${connection}
    Should be equal as strings    ${reset_status['status']}    ${expected_status}

_Verify Lock rmods operation status should be as expected
    [Documentation]    Author: Lingxue Cui
    ...    ${operation_id}: returned from method 'vdu.lock_rmods'
    ...    ${expected_status}: available values are: ongoing, success, failed
    [Arguments]    ${operation_id}    ${expected_status}    ${connection}=OAM_gnb0_du0
    ${lock_status}    vdu.get_operation_state_of_locking_rmods    operation_id=${operation_id}    vdu_connection=${connection}
    Should be equal as strings    ${lock_status['status']}    ${expected_status}

_Verify Unlock rmods operation status should be as expected
    [Documentation]    Author: Lingxue Cui
    ...    ${operation_id}: returned from method 'vdu.unlock_rmods'
    ...    ${expected_status}: available values are: ongoing, success, failed
    [Arguments]    ${operation_id}    ${expected_status}    ${connection}=OAM_gnb0_du0
    ${unlock_status}    vdu.get_operation_of_unlocking_rmods    operation_id=${operation_id}    vdu_connection=${connection}
    Should be equal as strings    ${unlock_status['status']}    ${expected_status}

Verify RU status are as expected
    [Documentation]  Author: Ding Binmei
    ...    ${rmods_list}: support both string and list. like: '1' or ['1', '2']
    ...    ${exp_availability_status}: supported value: on line, off line, failed, degraded, dependency, not installed, power off...
    ...    ${exp_operational_state}: supported value: enabled, disabled
    ...    ${exp_administrative_state}: supported value: unlocked, locked
    [Arguments]  ${rmods_list}    ${connection}=OAM_gnb0_du0    ${exp_availability_status}=on line
    ...    ${exp_operational_state}=enabled    ${exp_administrative_state}=unlocked
    ${rmods_list}    string_list.string2list    ${rmods_list}
    ${dict_rmod_info}    cloud_gnb.get_ru_info_from_vdu    vdu_connection=${connection}

    FOR    ${rmod_id}    IN    @{rmods_list}
        &{rmod_info}    Set variable    ${dict_rmod_info['${rmod_id}']}
        run keyword and continue on failure
        ...    should be equal as strings    ${rmod_info['availability_status']}    ${exp_availability_status}
        ...        msg=Check availability status failed for RMOD: ${rmod_id}, RU type: ${rmod_info['product_name']}    ignore_case=${True}
        run keyword and continue on failure
        ...    should be equal as strings    ${rmod_info['operational_state']}    ${exp_operational_state}
        ...    msg=Check operational state failed for RMOD: ${rmod_id}, RU type: ${rmod_info['product_name']}    ignore_case=${True}
        run keyword and continue on failure
        ...    should be equal as strings    ${rmod_info['administrative_state']}    ${exp_administrative_state}
        ...    msg=Check operational state failed for RMOD: ${rmod_id}, RU type: ${rmod_info['product_name']}    ignore_case=${True}
    END


Perform Cells block
    [Documentation]  Author: Lingxue Cui
    ...    ${cells_list}: support both string and list. like: '1' or ['1', '2']
    [Arguments]    ${cells_list}    ${timeout}=1min    ${timeout_cell_blocked}=3min    ${connection}=OAM_gnb0_du0
    ${cells_list}    string_list.string2list    ${cells_list}

    FOR    ${cell_id}    IN    @{cells_list}
        ${cell_id}    evaluate    str(${cell_id})
        ${result}    vdu.block_cell    cell_id=${cell_id}    vdu_connection=${connection}
        Wait until keyword succeeds    ${timeout}    2sec
        ...    _Verify Block Cell operation status should be as expected    operation_id=${result['id']}
        ...        expected_status=success    connection=${connection}
        Wait until keyword succeeds    ${timeout_cell_blocked}    5sec
        ...    Verify Cell status are as expected    cells_list=${cell_id}    connection=${connection}
        ...      exp_availability_status=off line    exp_operational_state=disabled    exp_administrative_state=unlocked
        ...      exp_blocking_state=blocked
    END

Perform Cells unblock
    [Documentation]  Author: Lingxue Cui
    ...    ${cells_list}: support both string and list. like: '1' or ['1', '2']
    ...    ${timeout}: timeout for cell operation status become success.
    ...    ${timeout_cell_unblocked}: timeout for cell administrative state become 'unblocked'.
    [Arguments]    ${cells_list}    ${timeout}=1min    ${timeout_cell_unblocked}=3min    ${connection}=OAM_gnb0_du0
    ${cells_list}    string_list.string2list    ${cells_list}

    FOR    ${cell_id}    IN    @{cells_list}
        ${cell_id}    evaluate    str(${cell_id})
        ${result}    vdu.unblock_cell    cell_id=${cell_id}    vdu_connection=${connection}
        Wait until keyword succeeds    ${timeout}    2sec
        ...    _Verify Unblock Cell operation status should be as expected    operation_id=${result['id']}
        ...        expected_status=success    connection=${connection}
        Wait until keyword succeeds    ${timeout_cell_unblocked}    5sec
        ...    Verify Cell status are as expected    cells_list=${cell_id}    connection=${connection}
        ...      exp_availability_status=on line    exp_operational_state=enabled    exp_administrative_state=unlocked
        ...      exp_blocking_state=unblocked
    END

Verify Cell status are as expected
    [Documentation]  Author: Lingxue Cui
    ...    ${cells_list}: support both string and list. like: '1' or ['1', '2']
    ...    ${exp_availability_status}: supported value: on line, off line, failed, degraded, dependency, not installed, power off...
    ...    ${exp_operational_state}: supported value: enabled, disabled
    ...    ${exp_administrative_state}: supported value: unlocked, locked, shutting_down
    ...    ${exp_blocking_state}: supported value: unblocked, unblocking, blocked, blocking
    [Arguments]  ${cells_list}    ${connection}=OAM_gnb0_du0    ${exp_availability_status}=on line
    ...    ${exp_operational_state}=enabled    ${exp_administrative_state}=unlocked    ${exp_blocking_state}=unblocked

    ${cells_list}    string_list.string2list    ${cells_list}
    &{dict_cells_info}    get_cells_status_on_vdu    vdu_connection=${connection}

    FOR    ${cell_id}    IN    @{cells_list}
        &{cell_info}    set variable    ${dict_cells_info['${cell_id}']}
        run keyword and continue on failure
        ...    should be equal as strings    ${cell_info['availability_status']}    ${exp_availability_status}
        ...    msg=Check availability status failed for NRCELL: ${cell_id}, NRCELL identity is: ${cell_info['nr_cell_identity']}  ignore_case=${True}
        run keyword and continue on failure
        ...    should be equal as strings    ${cell_info['operational_state']}    ${exp_operational_state}
        ...    msg=Check operational state failed for NRCELL: ${cell_id}, NRCELL identity is: ${cell_info['nr_cell_identity']}    ignore_case=${True}
        run keyword and continue on failure
        ...    should be equal as strings    ${cell_info['administrative_state']}    ${exp_administrative_state}
        ...    msg=Check administrative state failed for NRCELL: ${cell_id}, NRCELL identity is: ${cell_info['nr_cell_identity']}
        ...    ignore_case=${True}
        run keyword and continue on failure
        ...    should be equal as strings    ${cell_info['blocking_state']}    ${exp_blocking_state}
        ...    msg=Check blocking state failed for NRCELL: ${cell_id}, NRCELL identity is: ${cell_info['nr_cell_identity']}    ignore_case=${True}
    END

_Verify Block Cell operation status should be as expected
    [Documentation]    Author: Lingxue Cui
    ...    ${operation_id}: returned from method 'vdu.block_cell'
    ...    ${expected_status}: available values are: ongoing, success, failed
    [Arguments]    ${operation_id}    ${expected_status}    ${connection}=OAM_gnb0_du0
    ${block_status}    vdu.get_block_cell_operation_status    operation_id=${operation_id}    vdu_connection=${connection}
    Should be equal as strings    ${block_status['status']}    ${expected_status}

_Verify Unblock Cell operation status should be as expected
    [Documentation]    Author: Lingxue Cui
    ...    ${operation_id}: returned from method 'vdu.unblock_cell'
    ...    ${expected_status}: available values are: ongoing, success, failed
    [Arguments]    ${operation_id}    ${expected_status}    ${connection}=OAM_gnb0_du0
    ${unblock_status}    vdu.get_unblock_cell_operation_status    operation_id=${operation_id}    vdu_connection=${connection}
    Should be equal as strings    ${unblock_status['status']}    ${expected_status}


Perform RANNIC reset
    [Documentation]    Author: Lingxue Cui
    ...    ${list_rannic_r_dn}: only support list type, should be runtime dn of rannic, for example:
    ...      ['MRBTS-37241/EQM_R-1/APEQM_R-1/RNICMOD_R-1', 'MRBTS-37241/EQM_R-1/APEQM_R-1/RNICMOD_R-2']
    [Arguments]    ${mrbts_dn}    ${list_rannic_r_dn}    ${timeout}=5min    ${connection}=OAM_gnb0_du0
    ${mrbts_id}    fetch_from_right    ${mrbts_dn}     marker=-
    ${mrbts_id}    evaluate    str(${mrbts_id})
    ${len_rannic_list}    get length    ${list_rannic_r_dn}
    Should Not Be Equal As Integers    ${0}   ${len_rannic_list}    msg=There is no RANNIC DN specified, please check!1

    FOR    ${rannic_r_dn}    IN    @{list_rannic_r_dn}
        log to console    Resetting RANNIC ${rannic_r_dn}!
        ${result}    vdu.reset_rannic    rannic_r_dn=${rannic_r_dn}    vdu_connection=${connection}
        Wait until keyword succeeds    ${timeout}    2sec
        ...    _Verify RANNIC reset operation status should be as expected    operation_id=${result['id']}
        ...        expected_status=success    connection=${connection}
        ${rannic_r_dn}    create list    ${rannic_r_dn}
        Wait until keyword succeeds    ${timeout}    5sec
        ...    Verify RANNIC status are as expected    mrbts_dn=${mrbts_dn}    list_rannic_r_dn=${rannic_r_dn}
    END

Verify RANNIC status are as expected
    [Documentation]  Author: Lingxue Cui
    ...    ${list_rannic_r_dn}: only support list type, should be runtime dn of rannic, for example:
    ...      ['MRBTS-37241/EQM_R-1/APEQM_R-1/RNICMOD_R-1', 'MRBTS-37241/EQM_R-1/APEQM_R-1/RNICMOD_R-2']
    ...    ${exp_availability_status}: supported value: on line, off line, failed
    ...    ${exp_operational_state}: supported value: enabled, disabled

    [Arguments]    ${mrbts_dn}    ${list_rannic_r_dn}    ${connection}=OAM_gnb0_du0    ${exp_availability_status}=on line
    ...    ${exp_operational_state}=enabled
    ${mrbts_id}    fetch_from_right    ${mrbts_dn}     marker=-
    ${mrbts_id}    evaluate    str(${mrbts_id})
    @{list_rannic_info}    get_rnic_info_from_plan    mrbts_id=${mrbts_id}    vdu_connection=${connection}

    FOR    ${rannic_r_dn}    IN    @{list_rannic_r_dn}
        FOR    ${cur_rnic_info}    IN    @{list_rannic_info}
            ${cur_rannic_dn}    set variable    ${cur_rnic_info['r_nic_mod_dist_name']}
            Continue For Loop If    '${cur_rannic_dn}'!='${rannic_r_dn}'
            run keyword and continue on failure
            ...    should be equal as strings    ${cur_rnic_info['availability_status']}    ${exp_availability_status}
            ...        msg=Check availability status failed for RANNIC: ${rannic_r_dn}, SN is ${cur_rnic_info['serial_number']}   ignore_case=${True}
            run keyword and continue on failure
            ...    should be equal as strings    ${cur_rnic_info['operational_state']}    ${exp_operational_state}
            ...    msg=Check operational state failed for RANNIC: ${rannic_r_dn}, SN is ${cur_rnic_info['serial_number']}    ignore_case=${True}
        END
    END

_Verify RANNIC reset operation status should be as expected
    [Documentation]    Author: Lingxue Cui
    ...    ${operation_id}: returned from method 'vdu.reset_rannic'
    ...    ${expected_status}: available values are: ongoing, success, failed
    [Arguments]    ${operation_id}    ${expected_status}    ${connection}=OAM_gnb0_du0
    ${block_status}    vdu.get_rnic_reset_operation    operation_id=${operation_id}    vdu_connection=${connection}
    Should be equal as strings    ${block_status['status']}    ${expected_status}

Get RANNIC runtime DN
    [Documentation]    Author: Lingxue Cui
    ...    Get the runtime dist name of all RANNIC on vDU.
    [Arguments]    ${mrbts_dn}    ${connection}=OAM_gnb0_du0
    ${mrbts_id}    fetch_from_right    ${mrbts_dn}     marker=-
    ${mrbts_id}    evaluate    str(${mrbts_id})
    @{list_rannic_info}    get_rnic_info_from_plan    mrbts_id=${mrbts_id}    vdu_connection=${connection}
    @{list_rannic_r_dn}    create list
    FOR    ${cur_rnic_info}    IN    @{list_rannic_info}
        ${cur_rannic_dn}    set variable    ${cur_rnic_info['r_nic_mod_dist_name']}
        Append To List    ${list_rannic_r_dn}    ${cur_rannic_dn}
    END
    [Return]    @{list_rannic_r_dn}
