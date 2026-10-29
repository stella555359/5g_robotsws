*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   common.robot


*** Keywords ***
COAM CU Login
    [Arguments]   ${gnb_index}=${0}   ${alias}=COAM_CU

    ${cu_webem_addr}   Get Variable Value   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ${cu_webem_username}   Get Variable Value   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ${cu_webem_password}   Get Variable Value   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}

    coam_cu.connect_to
    ...   host=${cu_webem_addr}
    ...   port=${EMPTY}
    ...   username=${cu_webem_username}
    ...   password=${cu_webem_password}
    ...   cu_version=cuoam_24r2
    ...   secure=${True}
    ...   alias=${alias}

COAM CU Logout
    [Arguments]   ${connection}=COAM_CU
    coam_cu.disconnect   connection=${connection}


COAM CU Check All Cell Status
    [Arguments]   ${connection}=COAM_CU
    ${cells_status}   coam_cu.get_cells_statuses   connection=${connection}
    # Log To Console   ${cells_status}

    FOR   ${cell_info}   IN   @{cells_status}
        ${administrative_state}   Get Variable Value   ${cell_info["administrative_state"]}
        ${operational_state}   Get Variable Value   ${cell_info["operational_state"]}

        Should Be Equal   ${administrative_state}   Unlocked
        Should Be Equal   ${operational_state}      enabled
    END


COAM CU Check All Cell Status Locked
    [Arguments]   ${connection}=COAM_CU
    ${cells_status}   coam_cu.get_cells_statuses   connection=${connection}
    # Log To Console   ${cells_status}

    FOR   ${cell_info}   IN   @{cells_status}
        ${administrative_state}   Get Variable Value   ${cell_info["administrative_state"]}
        ${operational_state}   Get Variable Value   ${cell_info["operational_state"]}

        Should Be Equal   ${administrative_state}   Locked
        Should Be Equal   ${operational_state}      disabled

    END


COAM CU Backup Current SCF
    [Arguments]   ${path}=${OUTPUT_DIR}/old_commission_cu.xml   ${connection}=COAM_CU
    coam_cu.get_current_plan_file   path=${path}   connection=${connection}

# COAM CU Backup All Plan SCF
#     [Arguments]   ${scf_dir}=${OUTPUT_DIR}   ${connection}=COAM_CU
#     @{plan_infos}   coam_cu.get_plan_info   connection=${connection}
#     @{plan_files_name}   Create List
#     FOR   ${plan_info}   IN   @{plan_infos}
#        ${plan_id}   Set Variable   ${plan_info.to_dict()['plan_id']}
#        coam_cu.get_plan_file   plan_id=${plan_id}   path=${scf_dir}/${plan_id}.xml   connection=${connection}
#        Append To List   ${plan_files_name}   ${scf_dir}/${plan_id}.xml
#     END
#     [Return]   ${plan_files_name}

COAM CU Upload Plan File
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/old_commission_cu.xml   ${connection}=COAM_CU
    ${operation_info}   coam_cu.upload_plan_file   path_to_plan_file=${scf_path}   connection=${connection}
    ${plan_id}   Set Variable   ${operation_info['plan_id']}
    ${operation_id}   Set Variable   ${operation_info['action_id']}
    Wait Until Keyword Succeeds   1m   5s   __COAM CU Check Upload Plan File Status   operation_id=${operation_id}
    [Return]   ${plan_id}


__COAM CU Check Upload Plan File Status
    [Arguments]  ${operation_id}   ${connection}=COAM_CU
    ${operation_status}   coam_cu.get_operation_state_of_uploading_plan   ${operation_id}   connection=${connection}
    Should Be Equal   ${operation_status["status"]}   success


COAM CU Validate Plan File
    [Arguments]   ${plan_id}   ${connection}=COAM_CU
    ${operation_info}   coam_cu.plan_validation   plan_id=${plan_id}   connection=${connection}
    ${operation_id}   Set Variable   ${operation_info['action_id']}
    Wait Until Keyword Succeeds   1m   5s   __COAM CU Check Validate Plan File Status   plan_id=${plan_id}   operation_id=${operation_id}


__COAM CU Check Validate Plan File Status
    [Arguments]   ${plan_id}   ${operation_id}   ${connection}=COAM_CU
    ${operation_status}   coam_cu.get_operation_state_of_validating_plan   plan_id=${plan_id}   operation_id=${operation_id}
    ...   connection=${connection}
    Should Be Equal   ${operation_status["status"]}   success


COAM CU Activate Plan File
    [Arguments]   ${plan_id}   ${connection}=COAM_CU
    ${operation_info}   coam_cu.plan_activation   plan_id=${plan_id}   connection=${connection}
    ${operation_id}   Set Variable   ${operation_info['id']}
    Wait Until Keyword Succeeds   20m   1m   __COAM CU Check Activate Plan File Status   plan_id=${plan_id}   operation_id=${operation_id}


__COAM CU Check Activate Plan File Status
    [Arguments]   ${plan_id}   ${operation_id}   ${connection}=COAM_CU
    ${operation_status}   coam_cu.get_operation_state_of_activating_plan   plan_id=${plan_id}   operation_id=${operation_id}
    ...   connection=${connection}
    Should Be Equal   ${operation_status["status"]}   success


COAM CU Perform Commission
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/old_commission_cu.xml   ${connection}=COAM_CU
    ${plan_id}   COAM CU Upload Plan File   scf_path=${scf_path}   connection=${connection}
    COAM CU Validate Plan File   plan_id=${plan_id}   connection=${connection}
    COAM CU Activate Plan File   plan_id=${plan_id}   connection=${connection}


COAM CU Save Local Snapshot
    [Arguments]   ${connection}=COAM_CU
    ${cu_snapshot_tmp_dir}   Set Variable   ${OUTPUT_DIR}/snapshot_tmp_dir_cu
    OperatingSystem.Create Directory   ${cu_snapshot_tmp_dir}

    ${status}   coam_cu.check_snapshot_status   connection=${connection}
    Run Keyword If   '${status}'=='idle'
    ...   coam_cu.get_local_snapshot   directory=${cu_snapshot_tmp_dir}   connection=${connection}
    ...   ELSE IF   '${status}'=='local-ongoing'
    ...   __COAM CU Save Local Ongoing Snapshot   directory=${cu_snapshot_tmp_dir}   connection=${connection}

    ${snapshot_number}   OperatingSystem.Count Files In Directory   ${cu_snapshot_tmp_dir}
    Should Be Equal   ${snapshot_number}   ${1}
    ${snapshot_list}   OperatingSystem.List Files In Directory   ${cu_snapshot_tmp_dir}
    ${snapshot_name}   Set Variable   ${snapshot_list[0]}
    ${source}   OperatingSystem.Join Path   ${cu_snapshot_tmp_dir}   ${snapshot_name}
    ${destination}   OperatingSystem.Join Path   ${OUTPUT_DIR}   ${snapshot_name}
    OperatingSystem.Move File   ${source}   ${destination}
    [Return]   ${destination}


__COAM CU Save Local Ongoing Snapshot
    [Arguments]   ${directory}=${OUTPUT_DIR}   ${connection}=COAM_CU
    ${information}   coam_cu.get_snapshot_operations_information
    FOR   ${info}   IN   @{information}
        ${operation_id}   Set Variable   ${info['operation_id']}
        coam_cu.get_local_snapshot_by_id
        ...   directory=${directory}
        ...   operation_id=${operation_id}
        ...   use_m2m=${True}
        ...   operation_timeout=${600}
        ...   connection=${connection}
    END


COAM CU Reset
    [Arguments]   ${connection}=COAM_CU
    ${output}   coam_cu.reset_cu   connection=${connection}
    ${error_msg}   Set Variable   ${output["error_message"]}
    Should Be Equal   ${error_msg}   ${None}
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   60s   3s   __COAM CU Check Reset Status   operation_id=${operation_id}   connection=${connection}


__COAM CU Check Reset Status
    [Arguments]   ${operation_id}   ${connection}=COAM_CU
    Log    ${operation_id}    ${connection}
    Sleep   120s
    # ${output}    coam_cu.get_reset_cu_operation_status    operation_id=${operation_id}   connection=${connection}   timeout=${30}
    # Should Be True   "${output["status"]}"=="ongoing"



COAM CU Reset Cell
    [Arguments]   ${cell_dn}   ${connection}=COAM_CU
    Log To Console   //TODO: ${cell_dn}
    Log    ${connection}
#     ${output}   coam_cu.reset_cell   cell_dn=${cell_dn}   timeout=${60}   connection=${connection}
#     ${operation_id}   Set Variable   ${output["id"]}
#     Wait Until Keyword Succeeds   10m   1m   __COAM CU Check Reset RU Status   operation_id=${operation_id}   connection=${connection}


# __COAM CU Check Reset Cell Status
#     [Arguments]   ${operation_id}   ${connection}=COAM_CU
#     ${output}    coam_cu.get_reset_cell_operation_status   operation_id=${operation_id}   connection=${connection}   timeout=${30}
#     Should Be True   "${output["status"]}"=="success"


COAM CU Lock Cells
    [Arguments]   ${cell_ids}   ${connection}=COAM_CU
    ${output}   coam_cu.lock_cells   cell_ids=${cell_ids}   connection=${connection}
    ${error_msg}   Set Variable   ${output["error_message"]}
    Should Be Equal   ${error_msg}   ${None}
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   60s   3s   __COAM CU Check Lock Cells Status   operation_id=${operation_id}   connection=${connection}


__COAM CU Check Lock Cells Status
    [Arguments]   ${operation_id}   ${connection}=COAM_CU
    ${operation_info}   coam_cu.get_operation_state_of_locking_cells   operation_id=${operation_id}   connection=${connection}
    Should Be True    "${operation_info["status"]}"=="success"


COAM CU Unlock Cells
    [Arguments]   ${cell_ids}   ${connection}=COAM_CU
    ${output}   coam_cu.unlock_cells   cell_ids=${cell_ids}   connection=${connection}
    ${error_msg}   Set Variable   ${output["error_message"]}
    Should Be Equal   ${error_msg}   ${None}
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   60s   3s   __COAM CU Check Unlock Cells Status   operation_id=${operation_id}   connection=${connection}


__COAM CU Check Unlock Cells Status
    [Arguments]   ${operation_id}   ${connection}=COAM_CU
    ${operation_info}    coam_cu.get_operation_state_of_unlocking_cells   operation_id=${operation_id}   connection=${connection}
    Should Be True   "${operation_info["status"]}"=="success"


COAM CU Lock vDUs
    [Arguments]   ${vdu_id_list}   ${connection}=COAM_CU
    ${output}   coam_cu.lock_du   du_id=${vdu_id_list}   connection=${connection}
    # ${error_msg}   Set Variable   ${output["error_message"]}
    # Should Be Equal   ${error_msg}   ${None}
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   60s   3s   __COAM CU Check Lock vDUs Status   operation_id=${operation_id}   connection=${connection}

__COAM CU Check Lock vDUs Status
    [Arguments]   ${operation_id}   ${connection}=COAM_CU
    ${operation_info}   coam_cu.get_opeartion_state_of_locking_du   operation_id=${operation_id}   connection=${connection}
    Should Be True    "${operation_info["status"]}"=="success"


COAM CU Unlock vDUs
    [Arguments]   ${vdu_id_list}   ${connection}=COAM_CU
    ${output}   coam_cu.unlock_du   du_id=${vdu_id_list}   connection=${connection}
    # ${error_msg}   Set Variable   ${output["error_message"]}
    # Should Be Equal   ${error_msg}   ${None}
    ${operation_id}   Set Variable   ${output["id"]}
    Wait Until Keyword Succeeds   60s   3s   __COAM CU Check Unlock vDUs Status   operation_id=${operation_id}   connection=${connection}


__COAM CU Check Unlock vDUs Status
    [Arguments]   ${operation_id}   ${connection}=COAM_CU
    ${operation_info}   coam_cu.get_opeartion_state_of_unlocking_du   operation_id=${operation_id}   connection=${connection}
    Should Be True    "${operation_info["status"]}"=="success"


COAM CU Check All vDUs Locked
    [Arguments]   ${connection}=COAM_CU
    ${output}   coam_cu.get_du_state   connection=${connection}
    ${locked_number}   Get Variable Value   ${output["administrative_state"]["locked"]}
    ${unlocked_number}   Get Variable Value   ${output["administrative_state"]["unlocked"]}
    Should Not Be Equal As Integers   ${locked_number}   0
    Should Be Equal As Integers   ${unlocked_number}   0


COAM CU Check All vDUs Unlocked
    [Arguments]   ${connection}=COAM_CU
    ${output}   coam_cu.get_du_state   connection=${connection}
    ${locked_number}   Get Variable Value   ${output["administrative_state"]["locked"]}
    ${unlocked_number}   Get Variable Value   ${output["administrative_state"]["unlocked"]}
    Should Be Equal As Integers   ${locked_number}   0
    Should Not Be Equal As Integers   ${unlocked_number}   0
