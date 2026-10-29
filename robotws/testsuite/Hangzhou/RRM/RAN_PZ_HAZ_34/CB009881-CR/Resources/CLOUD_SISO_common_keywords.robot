*** Settings ***
Documentation    This is for CLOUD SISO related common keywords.
...              Please do not modify the file without notification to author
...              Author:jia-rebecca.liu@nokia-sbell.com
...              Squard: HZ PZ4 SG3


Library           DateTime
Library           String
Library           taf.gnb.oam.coam.cu                                     WITH NAME           cu
Library           taf.gnb.oam.coam.vdu                                    WITH NAME           vdu
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/AIC_common.py
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.py

*** Variables ***
${TS_LOG_PATH_BASE}       ${OUTPUT DIR}/Case_Logs
${test_info_path}         /opt/workspace/SCF/
${test_info_file}         SiSo_test_info.yml


*** Keywords ***
get_test_round_info
    Create suite log path for cloud
#    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Set Suite Variable    ${epc_log_path}    ${SUITE_LOG_PATH}/${time_stamp}/
#    Create directory    ${epc_log_path}
    ${test_info}=    get_info_from_file    file_path=${test_info_path}${test_info_file}
    Set Suite Variable    ${test_round}    ${test_info}[test_round]

Create suite log path for cloud
    [Documentation]    Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]     ${cu_index}=${0}    ${du_index}=${0}
    ${cu_sw_version} =    Get_CU_build_version    cu_index=${cu_index}
    set suite variable    ${cu_sw_version}
    ${vdu_sw_version} =    Get_DU_build_version    cu_index=${cu_index}    du_index=${du_index}
    set suite variable    ${vdu_sw_version}
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${cu_sw_version}_${vdu_sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}


Get_CU_build_version
    [Arguments]    ${cu_index}=${0}
    cu.connect_to     host=${tl.gnbs[${cu_index}].cu.oam_http_connection_details.addr}
    ...               port=443
    ...               username=${tl.gnbs[${cu_index}].cu.oam_http_connection_details.username}
    ...               password=${tl.gnbs[${cu_index}].cu.oam_http_connection_details.password}
    ...               secure=${True}
    ...               alias=vcu_${cu_index}
    ${cu_sw_version}=    cu.get_active_software_version    connection=vcu_${cu_index}
    [Return]     ${cu_sw_version}
    [Teardown]    run keyword and ignore error    cu.disconnect    connection=vcu_${cu_index}

Get_DU_build_version
    [Arguments]    ${du_index}=0    ${cu_index}=0
    vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
    ...               port=${EMPTY}
    ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
    ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
    ...               secure=True
    ...               connection_name=vdu_${du_index}
    ${vdu_state_data}=    vdu.get_vdu_state_data    vdu_connection=vdu_${du_index}
    ${vdu_sw_version}=    set variable    ${vdu_state_data['software_version']}
    [Return]     ${vdu_sw_version}
    [Teardown]  run keyword and ignore error    vdu.disconnect    vdu_connection=vdu_${du_index}


get_cu_du_nums_from_init
    ${cu_nums}    get length    ${tl.gnbs}
    BuiltIn.Set Suite Variable    ${cu_nums}
    log to console    \n *** ${tl.gnbs[0].cu.instance_id} have ${cu_nums} cu *** \n
    FOR    ${i}    IN RANGE    ${cu_nums}
        ${vdu_nums}    get length    ${tl.gnbs[${i}].dus}
        BuiltIn.Set Suite Variable    ${cu_${i}_vdu_nums}    ${vdu_nums}
        log to console    \n *** cu_${i} have ${CU${i}_vdu_nums} du *** \n
    END

reset_all_vdus_on_vdu
    FOR    ${cu_index}    IN RANGE    ${cu_nums}
        reset_vdu_on_vdu    cu_index=${cu_index}
    END

reset_vdu_on_vdu
    [Arguments]    ${cu_index}    ${timeout}=${600}
    FOR    ${du_index}    IN RANGE    ${cu_${cu_index}_vdu_nums}
        vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
        ...               port=${EMPTY}
        ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
        ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
        ...               secure=True
        ...               connection_name=vdu_${du_index}
        vdu.reset_vdu     timeout=${timeout}    vdu_connection=vdu_${du_index}
        vdu.disconnect    vdu_connection=vdu_${du_index}
    END

get_and_check_all_vdus_historical_alarms
    [Arguments]    ${current_time}
    FOR    ${cu_index}    IN RANGE    ${cu_nums}
        get_historical_alarms_on_vdu    cu_index=${cu_index}    current_time=${current_time}
    END

get_historical_alarms_on_vdu
    [Arguments]    ${current_time}    ${cu_index}=${cu_index}    ${timeout}=${600}
    FOR    ${du_index}    IN RANGE    ${cu_${cu_index}_vdu_nums}
        vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
        ...               port=${EMPTY}
        ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
        ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
        ...               secure=True
        ...               connection_name=vdu_${du_index}
        ${vdu_alarms_list}    vdu.vdu_get_historical_alarms    timeout=${timeout}    vdu_connection=vdu_${du_index}
        ${historical_alarms_num}    get length    ${vdu_alarms_list}[alarms]
        get_appear_time_from_historical_alarm    historical_alarms_num=${historical_alarms_num}
        ...                                      vdu_alarms_list=${vdu_alarms_list}
        ...                                      current_time=${current_time}
        vdu.disconnect    vdu_connection=vdu_${du_index}
    END

get_appear_time_from_historical_alarm
    [Arguments]    ${historical_alarms_num}    ${vdu_alarms_list}    ${current_time}
    FOR    ${n}    IN RANGE    ${historical_alarms_num}
        ${alarm_appear_time_pre}    Split String    ${vdu_alarms_list}[alarms][${n}][appear_time]    .
        ${alarm_appear_time}    String.Replace String    ${alarm_appear_time_pre}[0]    T    ${SPACE}
        log to console    ${alarm_appear_time}
        ${appear_timer}    DateTime.Convert Date    ${alarm_appear_time}    result_format=epoch
        Should Be True    ${appear_timer} < ${current_time}
    END

get_and_check_all_vdus_active_alarms
    FOR    ${cu_index}    IN RANGE    ${cu_nums}
        get_active_alarms_on_vdu    cu_index=${cu_index}
    END

get_active_alarms_on_vdu
    [Arguments]    ${cu_index}=${cu_index}    ${timeout}=${600}
    FOR    ${du_index}    IN RANGE    ${cu_${cu_index}_vdu_nums}
        vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
        ...               port=${EMPTY}
        ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
        ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
        ...               secure=True
        ...               connection_name=vdu_${du_index}
        ${vdu_alarms_list}    vdu.vdu_get_active_alarms    timeout=${timeout}    vdu_connection=vdu_${du_index}
        BuiltIn.Should Be Equal As Strings    '${vdu_alarms_list}[total]'    '${0}'
        vdu.disconnect    vdu_connection=vdu_${du_index}
    END

check_cells_status_after_reset
    FOR    ${cu_index}    IN RANGE    ${cu_nums}
        get_cells_status_with_vdu    cu_index=${cu_index}
    END

get_cells_status_with_vdu
    [Arguments]    ${cu_index}
    FOR    ${du_index}    IN RANGE    ${cu_${cu_index}_vdu_nums}
        cell_status_get    cu_index=${cu_index}    du_index=${du_index}
    END

cell_status_get
    [Arguments]    ${cu_index}    ${du_index}
    vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
    ...               port=${EMPTY}
    ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
    ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
    ...               secure=True
    ...               connection_name=vdu_${du_index}
    ${vdu_cells_status_list}    vdu.get_vdu_cells_status    vdu_connection=vdu_${du_index}
    ${cell_num}    get length    ${vdu_cells_status_list}
    get_vdu_cell_status    vdu_cells_status_list=${vdu_cells_status_list}
    [Teardown]    vdu.disconnect    vdu_connection=vdu_${du_index}

get_vdu_cell_status
    [Arguments]    ${vdu_cells_status_list}
    FOR    ${cell}  IN  @{vdu_cells_status_list}
        BuiltIn.Should Be Equal As Strings    '${cell}[availability_status]'    'on line'
    END

check_ru_status_after_reset
    FOR    ${cu_index}    IN RANGE    ${cu_nums}
        get_ru_status_with_ids    cu_index=${cu_index}
    END

get_ru_status_with_ids
    [Arguments]    ${cu_index}
    FOR    ${du_index}    IN RANGE    ${cu_${cu_index}_vdu_nums}
        ru_status_get    cu_index=${cu_index}    du_index=${du_index}
    END

ru_status_get
    [Arguments]    ${cu_index}    ${du_index}
    vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
    ...               port=${EMPTY}
    ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
    ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
    ...               secure=True
    ...               connection_name=vdu_${du_index}
    ${vdu_status}    vdu.get_rmods_status    vdu_connection=vdu_${du_index}
    ${ru_nums}    get length    ${vdu_status}
    get_ru_status    ru_nums=${ru_nums}    vdu_status=${vdu_status}
    [Teardown]    vdu.disconnect    vdu_connection=vdu_${du_index}


get_ru_status
    [Arguments]    ${ru_nums}    ${vdu_status}
    FOR    ${n}    IN RANGE    ${ru_nums}
        BuiltIn.Should Be Equal As Strings    '${vdu_status}[${n}][availability_status]'    'on line'
    END

reset_ru_with_ids
    [Arguments]    ${cu_index}    ${timeout}=${600}
    FOR    ${du_index}    IN RANGE    ${cu_${cu_index}_vdu_nums}
        vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
        ...               port=${EMPTY}
        ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
        ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
        ...               secure=True
        ...               connection_name=vdu_${du_index}
        ${vdu_status}    vdu.get_rmods_status    vdu_connection=vdu_${du_index}
        ${ru_nums}    get length    ${vdu_status}
        ${ru_id_list}    get_ru_ids    ru_nums=${ru_nums}    vdu_status=${vdu_status}
        vdu.reset_rmods    rmods_list=${ru_id_list}    vdu_connection=vdu_${du_index}    timeout=${timeout}    wait_for_completion=True
        vdu.disconnect    vdu_connection=vdu_${du_index}
    END

get_ru_ids
    [Arguments]    ${ru_nums}    ${vdu_status}
    @{ru_id_list}    create list
    FOR    ${i}    IN RANGE    ${ru_nums}
        ${ru_id}    Set Variable    ${vdu_status}[${i}][id]
        Append To List    ${ru_id_list}    ${ru_id}
    END
    [Return]    ${ru_id_list}

collect_snapshot_on_vdu
    [Arguments]    ${cu_index}    ${Snapshot_path}
    FOR    ${du_index}    IN RANGE    ${cu_${cu_index}_vdu_nums}
        vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
        ...               port=${EMPTY}
        ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
        ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
        ...               secure=True
        ...               connection_name=vdu_${du_index}
        ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
        ${snapshot_file_path}    Set variable    ${Snapshot_path}/snapshot_CU_${cu_index}_Vdu_${du_index}/
        Create directory    ${snapshot_file_path}
        vdu.Get_Local_Snapshot    directory=${snapshot_file_path}    compressed_or_not=True    vdu_connection=vdu_${du_index}
        vdu.disconnect    vdu_connection=vdu_${du_index}
    END

collect_all_vdus_snapshot
    [Arguments]     ${Snapshot_path}=${TS_CASE_LOG_PATH}
    FOR    ${cu_index}    IN RANGE    ${cu_nums}
       collect_snapshot_on_vdu     cu_index=${cu_index}    Snapshot_path=${Snapshot_path}
    END

Create_test_case_log_path_for_cloud
    [Documentation]
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${case_log_path}    Join path    ${SUITE_LOG_PATH}    TC_${tc_name}
    Set test variable    ${TS_CASE_LOG_PATH}    ${case_log_path}
    Create directory    ${TS_CASE_LOG_PATH}

get_cells_ids
    [Arguments]    ${cell_nums}    ${cells_status}
    @{cells_id_list}    create list
    FOR    ${i}    IN RANGE    ${cell_nums}
        ${cell_id}    Set Variable    ${cells_status}[${i}][id]
        Append To List    ${cells_id_list}    ${cell_id}
    END
    [Return]    ${cells_id_list}

lock_cells_on_vdu_with_ids
    [Arguments]    ${cu_index}    ${timeout}=${600}
    FOR    ${du_index}    IN RANGE    ${cu_${cu_index}_vdu_nums}
        vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
        ...               port=${EMPTY}
        ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
        ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
        ...               secure=True
        ...               connection_name=vdu_${du_index}
        ${cells_status}    vdu.get_vdu_cells_status    timeout=${timeout}    vdu_connection=vdu_${du_index}
        ${cell_nums}    get length    ${cells_status}
        ${cells_id_list}    get_cells_ids    cell_nums=${cell_nums}    cells_status=${cells_status}
        vdu.lock_cells    cell_id_list=${cells_id_list}    timeout=${timeout}    vdu_connection=vdu_${du_index}
        vdu.disconnect    vdu_connection=vdu_${du_index}
    END

unlock_cells_on_vdu_with_ids
    [Arguments]    ${cu_index}    ${timeout}=${600}
    FOR    ${du_index}    IN RANGE    ${cu_${cu_index}_vdu_nums}
        vdu.connect_to    host=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.addr}
        ...               port=${EMPTY}
        ...               username=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.username}
        ...               password=${tl.gnbs[${cu_index}].dus[${du_index}].oam_http_connection_details.password}
        ...               secure=True
        ...               connection_name=vdu_${du_index}
        ${cells_status}    vdu.get_vdu_cells_status    timeout=${timeout}    vdu_connection=vdu_${du_index}
        ${cell_nums}    get length    ${cells_status}
        ${cells_id_list}    get_cells_ids    cell_nums=${cell_nums}    cells_status=${cells_status}
        vdu.unlock_cells    cell_id_list=${cells_id_list}    timeout=${timeout}    vdu_connection=vdu_${du_index}
        vdu.disconnect    vdu_connection=vdu_${du_index}
    END
