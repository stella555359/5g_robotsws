*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   common.robot
Library     taf.gnb.oam.coam.vdu   WITH NAME   coam_vdu

*** Keywords ***
COAM VDU Login
    [Arguments]   ${gnb_index}=${0}   ${vdu_index}=${vdu_index}   ${alias}=COAM_VDU

    # ${du_webem_addr}   Get Variable Value   ${ALL_GNBS_DETAIL[${gnb_index}]["all_dus_detail"][${vdu_index}]["du_webem_addr"]}
    # ${du_webem_username}   Get Variable Value   ${ALL_GNBS_DETAIL[${gnb_index}]["all_dus_detail"][${vdu_index}]["du_webem_username"]}
    # ${du_webem_password}   Get Variable Value   ${ALL_GNBS_DETAIL[${gnb_index}]["all_dus_detail"][${vdu_index}]["du_webem_password"]}
    ${vdu_webem_addr}   Get Variable Value   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${vdu_webem_username}   Get Variable Value   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ${vdu_webem_password}   Get Variable Value   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    coam_vdu.connect to
    ...  host=${vdu_webem_addr}
    ...  port=${EMPTY}
    ...  username=${vdu_webem_username}
    ...  password=${vdu_webem_password}
    ...  vdu_version=cuoam_25r3
    ...  secure=${True}
    ...  connection_name=${alias}


COAM VDU Logout
    [Arguments]   ${connection}=COAM_VDU
    coam_vdu.disconnect  vdu_connection=${connection}


COAM VDU Check All Cell Status
    [Arguments]   ${connection}=COAM_VDU
    ${cells_status}   coam_vdu.get_vdu_cells_status   vdu_connection=${connection}
    # Log To Console   ${cells_status}

    FOR   ${cell_info}   IN   @{cells_status}
        ${administrative_state}   Get Variable Value   ${cell_info["administrative_state"]}
        ${operational_state}   Get Variable Value   ${cell_info["operational_state"]}
        ${availability_status}   Get Variable Value   ${cell_info["availability_status"]}
        ${procedural_status}   Get Variable Value   ${cell_info["procedural_status"]}

        Should Be Equal   ${administrative_state}   Unlocked
        Should Be Equal   ${operational_state}      enabled
        Should Be Equal   ${availability_status}    on line
        Should Be Equal   ${procedural_status}      configured

    END

    # ${cells_summary}   coam_vdu.get_vdu_cells_summary   vdu_connection=${connection}
    # Log To Console   ${cells_summary}
    # Run Keyword And Continue On Failure   Should Be Equal As Integers
    # ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}   0   Some Cells Are Shutting Down!
    # Run Keyword And Continue On Failure   Should Be Equal As Integers
    # ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}   0   Some Cells Are Locked!
    # Run Keyword And Continue On Failure   Should Be Equal As Integers
    # ...    ${cells_summary["basic_cells_summary"]["operational_state"]["disabled"]}   0   Some Cells Are Disabled!

    # Run Keyword And Continue On Failure   Should Be Equal As Integers
    # ...    ${cells_summary["basic_cells_summary"]["operational_state"]["enabled"]}   ${cell_numbers}   Some Cells Are Disabled!
    # Run Keyword And Continue On Failure   Should Be Equal As Integers
    # ...    ${cells_summary["availability_status"]["on_line"]}   ${cell_numbers}   Some Cells Are Not Online!


COAM VDU Check All Cell Status Blocked
    [Arguments]   ${connection}=COAM_VDU
    ${cells_status}   coam_vdu.get_vdu_cells_status   vdu_connection=${connection}
    # Log To Console   ${cells_status}

    FOR   ${cell_info}   IN   @{cells_status}
        ${administrative_state}   Get Variable Value   ${cell_info["administrative_state"]}
        ${operational_state}   Get Variable Value   ${cell_info["operational_state"]}
        ${availability_status}   Get Variable Value   ${cell_info["availability_status"]}
        ${procedural_status}   Get Variable Value   ${cell_info["procedural_status"]}
        ${blocking_state}   Get Variable Value   ${cell_info["blocking_state"]}

        Should Be Equal   ${administrative_state}   Unlocked
        Should Be Equal   ${operational_state}      disabled
        Should Be Equal   ${availability_status}    off line
        Should Be Equal   ${procedural_status}      configured
        Should Be Equal   ${blocking_state}         Blocked

    END


COAM VDU Backup Current SCF
    [Arguments]   ${local_dir_path}=${OUTPUT_DIR}   ${filename}=old_commission_vdu.xml   ${connection}=COAM_VDU
    coam_vdu.get_current_plan_file   local_dir_path=${local_dir_path}   filename=${filename}   vdu_connection=${connection}


COAM VDU Upload Plan File
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/old_commission_vdu.xml   ${connection}=COAM_VDU
    ${operation_info}   coam_vdu.upload_plan   path_to_plan_file=${scf_path}   vdu_connection=${connection}
    ${plan_id}   Set Variable   ${operation_info['plan_id']}
    ${operation_id}   Set Variable   ${operation_info['action_id']}
    Wait Until Keyword Succeeds   1m   5s   __COAM VDU Check Upload Plan File Status   operation_id=${operation_id}
    [Return]   ${plan_id}

__COAM VDU Check Upload Plan File Status
    [Arguments]   ${operation_id}   ${connection}=COAM_VDU
    ${operation_status}   coam_vdu.get_upload_plan_operation_status   operation_id=${operation_id}   vdu_connection=${connection}
    Should Be Equal   ${operation_status["status"]}   success


COAM VDU Validate Plan File
    [Arguments]   ${plan_id}   ${connection}=COAM_VDU
    ${operation_info}   coam_vdu.validate_plan   plan_id=${plan_id}   vdu_connection=${connection}
    ${operation_id}   Set Variable   ${operation_info['action_id']}
    Wait Until Keyword Succeeds   1m   5s   __COAM VDU Check Validate Plan File Status   plan_id=${plan_id}   operation_id=${operation_id}


__COAM VDU Check Validate Plan File Status
    [Arguments]   ${plan_id}   ${operation_id}   ${connection}=COAM_VDU
    ${operation_status}   coam_vdu.get_validate_plan_operation_status   plan_id=${plan_id}   operation_id=${operation_id}
    ...   vdu_connection=${connection}
    Should Be Equal   ${operation_status["status"]}   success


COAM VDU Validate Delta Plan File
    [Arguments]   ${plan_id}   ${connection}=COAM_VDU
    ${operation_info}   coam_vdu.validate_delta_plan   delta_plan_id =${plan_id}   vdu_connection=${connection}
    ${action_id}   Set Variable   ${operation_info['action_id']}
    Wait Until Keyword Succeeds   1m   5s   __COAM VDU Check Validate Plan File Status
    ...   delta_plan_id=${delta_plan_id}   action_id=${action_id}


__COAM VDU Check Validate Delta Plan File Status
    [Arguments]   ${delta_plan_id}   ${action_id}   ${connection}=COAM_VDU
    ${operation_status}   coam_vdu.get_validate_delta_plan_operation_status   delta_plan_id=${delta_plan_id}   action_id=${action_id}
    ...   vdu_connection=${connection}
    Should Be Equal   ${operation_status["status"]}   success


COAM VDU Activate Plan File
    [Arguments]   ${plan_id}   ${connection}=COAM_VDU
    ${operation_info}   coam_vdu.activate_plan   plan_id=${plan_id}   vdu_connection=${connection}
    ${operation_id}   Set Variable   ${operation_info['id']}
    Wait Until Keyword Succeeds   20m   1m   __COAM VDU Check Activate Plan File Status   plan_id=${plan_id}   operation_id=${operation_id}


__COAM VDU Check Activate Plan File Status
    [Arguments]   ${plan_id}   ${operation_id}   ${connection}=COAM_VDU
    ${operation_status}   coam_vdu.get_activate_plan_operation_status   plan_id=${plan_id}   operation_id=${operation_id}
    ...   vdu_connection=${connection}
    Should Be Equal   ${operation_status["status"]}   success

COAM VDU Create Single Parameter Delta String
    [Arguments]   ${distName}   ${parameterName}   ${value}
    ${delta_str}   Catenate   SEPARATOR=
    ...   {
    ...       "distName": "${distName}",
    ...       "operation": "update",
    ...       "parameters": [{
    ...           "parameterName": "${parameterName}",
    ...           "value": "${value}",
    ...           "operation": "update"
    ...       }]
    ...   }
    [Return]   ${delta_str}


COAM VDU Perform Delta commission
    [Arguments]   ${delta_file}   ${wait_for_completion}=true
    ...    ${should_activate}=true   ${timeout}=600   ${connection}=COAM_VDU
    ${operation_info}   coam_vdu.Perform Delta Recommissioning    delta_file=${delta_file}    timeout=${timeout}
    ...    wait_for_completion=${wait_for_completion}    should_activate=${should_activate}    vdu_connection=${connection}
    ${operation_id}   Set Variable   ${operation_info['id']}
    Wait Until Keyword Succeeds   20m   1m   __COAM VDU Check Delta commission Status
    ...   operation_id=${operation_id}   connection=${connection}


__COAM VDU Check Delta commission Status
    [Arguments]   ${operation_id}   ${connection}=COAM_VDU
    ${status}   coam_vdu.get_status_of_perform_delta_recommissioning   operation_id=${operation_id}   vdu_connection=${connection}
    ${status}    Set Variable    ${status["status"]}
    Should Be Equal   ${status}   success


COAM VDU Perform Commission
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/old_commission_vdu.xml   ${connection}=COAM_VDU
    ${plan_id}   COAM VDU Upload Plan File   scf_path=${scf_path}   connection=${connection}
    COAM VDU Validate Plan File   plan_id=${plan_id}   connection=${connection}
    COAM VDU Activate Plan File   plan_id=${plan_id}   connection=${connection}


COAM VDU Save Local Snapshot
    [Arguments]   ${connection}=COAM_VDU
    ${vdu_snapshot_tmp_dir}   Set Variable   ${OUTPUT_DIR}/snapshot_tmp_dir_vdu
    OperatingSystem.Create Directory   ${vdu_snapshot_tmp_dir}

    ${status}   coam_vdu.check_snapshot_status   vdu_connection=${connection}
    Run Keyword If   '${status}'=='idle'
    ...   coam_vdu.get_local_snapshot   directory=${vdu_snapshot_tmp_dir}   compressed_or_not=${True}   vdu_connection=${connection}
    ...   operation_timeout=${1200}
    ...   ELSE IF   '${status}'=='local-ongoing'
    ...   __COAM VDU Save Local Ongoing Snapshot   directory=${vdu_snapshot_tmp_dir}   compressed_or_not=${True}   connection=${connection}

    ${snapshot_number}   OperatingSystem.Count Files In Directory   ${vdu_snapshot_tmp_dir}
    Should Be Equal   ${snapshot_number}   ${1}
    ${snapshot_list}   OperatingSystem.List Files In Directory   ${vdu_snapshot_tmp_dir}
    ${snapshot_name}   Set Variable   ${snapshot_list[0]}
    ${source}   OperatingSystem.Join Path   ${vdu_snapshot_tmp_dir}   ${snapshot_name}
    ${destination}   OperatingSystem.Join Path   ${OUTPUT_DIR}   ${snapshot_name}
    OperatingSystem.Move File   ${source}   ${destination}
    [Return]   ${destination}


__COAM VDU Save Local Ongoing Snapshot
    [Arguments]   ${directory}=${OUTPUT_DIR}   ${compressed_or_not}=${True}   ${connection}=COAM_VDU
    ${information}    coam_vdu.get_snapshot_operations_information
    FOR    ${info}    IN    @{information}
        ${operation_id}     Set Variable    ${info['operation_id']}
        coam_vdu.check_local_snapshot_status_and_save_it
        ...   directory=${directory}
        ...   operation_id=${operation_id}
        ...   use_m2m=${True}
        ...   operation_timeout=${600}
        ...   compressed_or_not=${compressed_or_not}
        ...   vdu_connection=${connection}
    END


COAM VDU Reset
    [Arguments]   ${connection}=COAM_VDU
    ${output}   coam_vdu.reset_vdu   timeout=${60}   vdu_connection=${connection}
    ${error_msg}   Set Variable   ${output["error_message"]}
    Should Contain   ${error_msg}   No error
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   60s   3s   __COAM VDU Check Reset Status   operation_id=${operation_id}   connection=${connection}


__COAM VDU Check Reset Status
    [Arguments]   ${operation_id}   ${connection}=COAM_VDU
    ${output}    coam_vdu.get_reset_vdu_operation_status    operation_id=${operation_id}   vdu_connection=${connection}   timeout=${30}
    Should Be True   "${output["status"]}"=="ongoing"


COAM VDU Get RMOD ID List
    [Arguments]   ${connection}=COAM_VDU
    ${rmod_id_list}  Create List
    ${rmods_info}   coam_vdu.get_rmods_status   vdu_connection=${connection}
    FOR  ${rmod}  IN  @{rmods_info}
        Append To List   ${rmod_id_list}   ${rmod["id"]}
    END
    [Return]   ${rmod_id_list}


COAM VDU Reset RU
    [Arguments]   ${rmods_list}   ${connection}=COAM_VDU

    ${output}   coam_vdu.reset_rmods   rmods_list=${rmods_list}   timeout=${60}   vdu_connection=${connection}

    ${error_msg}   Set Variable   ${output["error_message"]}
    Should Be Equal   ${error_msg}   ${None}
    ${operation_id}   Set Variable   ${output["operation_id"]}
    Wait Until Keyword Succeeds   10m   1m   __COAM VDU Check Reset RU Status   operation_id=${operation_id}   connection=${connection}


__COAM VDU Check Reset RU Status
    [Arguments]   ${operation_id}   ${connection}=COAM_VDU
    ${output}    coam_vdu.get_reset_rmods_operation_status   operation_id=${operation_id}   vdu_connection=${connection}   timeout=${30}
    Should Be True   "${output["status"]}"=="success"


COAM VDU Lock RU
    [Arguments]   ${rmod_id_list}   ${connection}=COAM_VDU
    ${output}   coam_vdu.lock_rmods   rmod_id_list=${rmod_id_list}   timeout=${60}   vdu_connection=${connection}
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   10m   1m   __COAM VDU Check Lock RU Status   operation_id=${operation_id}

__COAM VDU Check Lock RU Status
    [Arguments]   ${operation_id}   ${connection}=COAM_VDU
    ${output}   coam_vdu.get_operation_state_of_locking_rmods   operation_id=${operation_id}   vdu_connection=${connection}
    Should Be True  "${output["status"]}"=="success"


COAM VDU Unlock RU
    [Arguments]   ${rmod_id_list}   ${connection}=COAM_VDU
    ${output}   coam_vdu.unlock_rmods   rmod_id_list=${rmod_id_list}   timeout=${60}   vdu_connection=${connection}
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   10m   1m   __COAM VDU Check Unlock RU Status   operation_id=${operation_id}


__COAM VDU Check Unlock RU Status
    [Arguments]   ${operation_id}   ${connection}=COAM_VDU
    ${output}   coam_vdu.get_operation_of_unlocking_rmods   operation_id=${operation_id}   vdu_connection=${connection}
    Should Be True   "${output["status"]}"=="success"


COAM VDU Get RU Status
    [Arguments]   ${connection}=COAM_VDU
    ${rmod_status_list}   coam_vdu.get_rmods_status   vdu_connection=${connection}
    Log To Console   ${rmod_status_list}
    [Return]   ${rmod_status_list}


COAM VDU Reset Cell
    [Arguments]   ${cell_dn}   ${connection}=COAM_VDU
    Log To Console   //TODO: ${cell_dn}
     ${output}   coam_vdu.reset_cells   dist_name=${cell_dn}   timeout=${60}   vdu_connection=${connection}
#     ${operation_id}   Set Variable   ${output["id"]}
#     Wait Until Keyword Succeeds   10m   1m   __COAM VDU Check Reset RU Status   operation_id=${operation_id}   connection=${connection}


# __COAM VDU Check Reset Cell Status
#     [Arguments]   ${operation_id}   ${connection}=COAM_VDU
#     ${output}    coam_vdu.get_reset_cell_operation_status   operation_id=${operation_id}   vdu_connection=${connection}   timeout=${30}
#     Should Be True   "${output["status"]}"=="success"


COAM VDU Block Cell
    [Arguments]   ${cell_id}   ${connection}=COAM_VDU
    ${output}   coam_vdu.block_cell   cell_id=${cell_id}   vdu_connection=${connection}
    ${error_msg}   Set Variable   ${output["error_message"]}
    Should Contain   ${error_msg}   No error
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   60s   3s   __COAM VDU Check Block Cell Status   operation_id=${operation_id}   connection=${connection}


__COAM VDU Check Block Cell Status
    [Arguments]   ${operation_id}   ${connection}=COAM_VDU
    ${operation_info}    coam_vdu.get_block_cell_operation_status   operation_id=${operation_id}   vdu_connection=${connection}
    Should Be True    "${operation_info["status"]}"=="success"


COAM VDU Unblock Cell
    [Arguments]   ${cell_id}   ${connection}=COAM_VDU
    ${output}   coam_vdu.unblock_cell   cell_id=${cell_id}   vdu_connection=${connection}
    ${error_msg}   Set Variable   ${output["error_message"]}
    Should Contain   ${error_msg}   No error
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   60s   3s   __COAM VDU Check Block Cell Status   operation_id=${operation_id}   connection=${connection}


__COAM VDU Check Unblock Cell Status
    [Arguments]   ${operation_id}   ${connection}=COAM_VDU
    ${operation_info}    coam_vdu.get_unblock_cell_operation_status   operation_id=${operation_id}   vdu_connection=${connection}
    Should Be True   "${operation_info["status"]}"=="success"


COAM VDU Get Rannic Info
    [Arguments]   ${mrbts_id}   ${connection}=COAM_VDU
    ${rannic_info}   coam_vdu.get_rnic_info_from_plan   mrbts_id=${mrbts_id}   vdu_connection=${connection}
    [Return]   ${rannic_info}


COAM VDU Reset Rannic
    [Arguments]   ${rannic_r_dn}   ${connection}=COAM_VDU

    ${output}   coam_vdu.reset_rannic   rannic_r_dn=${rannic_r_dn}   timeout=${60}   vdu_connection=${connection}
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   10m   30s   __COAM VDU Check Reset Rannic Status   operation_id=${operation_id}   connection=${connection}


__COAM VDU Check Reset Rannic Status
    [Arguments]    ${operation_id}   ${connection}=COAM_VDU
    ${operation_info}    coam_vdu.get_rnic_reset_operation   operation_id=${operation_id}   vdu_connection=${connection}
    Should Be True    "${operation_info["status"]}"=="success"


COAM VDU Get Active Alarms
    [Arguments]   ${connection}=COAM_VDU
    ${active_alarms}   coam_vdu.vdu_get_active_alarms   vdu_connection=${connection}   paging=${False}
    [Return]   ${active_alarms}

COAM VDU Get History Alarms
    [Arguments]   ${connection}=COAM_VDU
    ${history_alarms}   coam_vdu.vdu_get_historical_alarms   vdu_connection=${connection}
    [Return]   ${history_alarms}


COAM VDU Change Parameter Online
     [Arguments]   ${dist_name}    ${parameter}    ${operation}    ${value}    ${timeout}=300    ${vdu_connection}=COAM_VDU
     coam_vdu.perform_parameter_recommissioning   dist_name=${dist_name}    parameter=${parameter}    operation=${operation}
     ...    value=${value}    timeout=${timeout}    vdu_connection=${vdu_connection}

COAM VDU Get Parameter Online
     [Arguments]   ${mo_dn}    ${para_name}    ${timeout}=300    ${vdu_connection}=COAM_VDU
     ${output}    coam_vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}    para_name=${para_name}
     ...   timeout=${timeout}    vdu_connection=${vdu_connection}
     [Return]    ${output}

#COAM VDU Change Delta Plan Parameter
#    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30
#    ...      ${connection}=COAM_VDU
#    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
#    ${timeout}   convert to integer  ${timeout}
#    ${out}  coam_vdu.update_vdu_parameter_of_delta_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
#     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}
#     ...   vdu_connection=${connection}
#    ${action_id}  set variable  ${out["action_id"]}
#    ${rtn}  wait until keyword succeeds  20   2
#    ...   VDU Change Delta Plan Parameter Should Be Expected  plan_id=${plan_id}   action_id=${action_id}   expected_status=success
#
#VDU Change Delta Plan Parameter Should Be Expected
#    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}    ${connection}=COAM_VDU
#    [Documentation]    Change Delta Plan Parameter Should Be Expected
#    ${out}   coam_vdu.get_update_paras_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}
#    ...   vdu_connection=${connection}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#VDU Get Parameter Value
#    [Arguments]    ${mo_dn}    ${para_name}    ${timeout}=60
#    [Documentation]   Get VDU Parameter Value Online
#    ${timeout}   convert to integer  ${timeout}
#    ${out}  coam_vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
#    [Return]  ${out}
#
#Vdu Generate Delta Plan
#    [Arguments]    ${plan_name}  ${plan_description}=${EMPTY}  ${delete_old_one}=${True}    ${connection}=COAM_VDU
#    [Documentation]   Generate Delta Plan
#    ...
#    run keyword if  "${delete_old_one}"=="${True}"   VDU Check Delta Plan Number And Delete One If Reach Maximum Number
#
#    ${out}  coam_vdu.Generate_Delta_Plan  plan_name=${plan_name}   plan_description=${plan_description}
#    ...   vdu_connection=${connection}
#    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
#    ${temp_action_id}   Set Variable  ${out["action_id"]}
#
#    VDU Generate Delta Plan Status Should Be Successful  action_id=${temp_action_id}
#    [Return]   ${temp_plan_id}   ${temp_action_id}
#
#
#VDU Check Delta Plan Number And Delete One If Reach Maximum Number
#    [Arguments]    ${connection}=COAM_VDU
#    [Documentation]   Check Maximum Delta Plan Number And delete one if reach Maximum number
#    ${all_plans}   coam_vdu.Get_Delta_Plan_Info_List    vdu_connection=${connection}
#
#    #Run Keyword If  ${all_plans.__len__()}==1   vdu.delete_delta_plan_file   plan_id=${all_plans[0]["plan_id"]}
#    Run Keyword If  ${all_plans.__len__()}==1   VDU Delete Delta Plan By Plan Id   plan_id=${all_plans[0]["plan_id"]}
#
#
#VDU Delete Delta Plan By Plan Id
#    [Arguments]  ${plan_id}    ${connection}=COAM_VDU
#    [Documentation]   Delete Delta Plan By Plan Id
#    ${out}    coam_vdu.delete_delta_plan_file   plan_id=${plan_id}    vdu_connection=${connection}
#    wait until keyword succeeds  60   5   VDU Make Sure Delta Plan Is Deleted Once
#
#
#VDU Make Sure Delta Plan Is Deleted Once
#    [Arguments]    ${connection}=COAM_VDU
#    ${all_plans}   coam_vdu.Get_Delta_Plan_Info_List    vdu_connection=${connection}
#    Should Be True  ${all_plans.__len__()}==0
#
#
#_VDU Generate Delta Plan Status Should Be Expected
#    [Arguments]  ${action_id}   ${expected_status}    ${connection}=COAM_VDU
#    [Documentation]   _Generate Delta Status Should Be Expected
#    ...
#    ${out}   coam_vdu.Get_Delta_Plan_Generated_Action_Status   action_id=${action_id}    vdu_connection=${connection}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#
#
#VDU Generate Delta Plan Status Should Be Successful
#    [Arguments]  ${action_id}
#    [Documentation]   Generate Delta Plan Status Should Be Successful
#    Wait Until Keyword Succeeds  30   3
#    ...  _VDU Generate Delta Plan Status Should Be Expected   action_id=${action_id}    expected_status=success
