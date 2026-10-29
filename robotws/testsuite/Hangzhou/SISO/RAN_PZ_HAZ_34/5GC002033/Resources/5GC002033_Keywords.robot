*** Settings ***
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002033/Resources/5GC002033_Variables.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    ../../5GC001596_F/Resources/5GC001596_F_Keywords.robot
Resource    ../../5GC001596_D/Resources/5GC001596_D_Keywords.robot
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB005887/TestData/CB005887_SCF_modify.py
*** Keywords ***
Suite preparation for 4cc
    [Documentation]    author: Zhang Ningning
    [Timeout]    20 min
    [Arguments]  ${SCF_DEFAULT_FILE_PATH}
    set suite variable     ${PARAMS_TO_DELETE}    ${CASE_ABIL_4CC}
    Suite common setup preparation    is_pdl_checking_needed=${False}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
    ...  scf_template_path=${SCF_DEFAULT_FILE_PATH}   prepare_ue=${True}
    Get the ru index list and cell index list and cell group index list and set to suite variable

Suite preparation for 8cc
    [Documentation]    author: Zhang Ningning
    [Timeout]    20 min
    [Arguments]  ${SCF_DEFAULT_FILE_PATH}
    set suite variable     ${PARAMS_TO_DELETE}    ${ABIO_DEL}
    Suite common setup preparation    is_pdl_checking_needed=${False}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
    ...  scf_template_path=${SCF_DEFAULT_FILE_PATH}   prepare_ue=${True}
    Get the ru index list and cell index list and cell group index list and set to suite variable


common case teardown with 2033
    [Documentation]    author: Fang Ludan
    [Timeout]    20 min
    [Arguments]  ${operation}  ${is_log_required}=${IS_LOG_CAPTURED_CASE_LEVEL}
    run Keyword and ignore Error    Make SgNBAddition on specific cell
    ...     gnb_ps_cell_index=${1}     alias=enblte
    Run Keyword And Ignore Error    Recovery env for many sectors if case failed with operations    operation=${operation}
    run Keyword and ignore Error    Common case teardown   is_log_required=${True}  detach_ue=${True}

2033 Call case with QCOM UE and record throughput info for many cells many times
    [Documentation]    Author: Zhang Ningning
    ...    ${GNB_PS_CELL_INDEX_LIST} is the cell list which can do attach. it is set in variables.robot.
    [Arguments]   ${para_update_timeout}=6 min    ${repeat_times}=${TEST_REPEAT_TIMES}
    ...    ${duration_time}=${3000}    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}
    ...    ${cell_index_list}=${CELL_INDEX_LIST}    ${exp_tput_percentage}=1
    ...    ${verify_duration}=${30}
    ...    ${sgnb_addition_on_spec_cell_needed}=${True}
    ...    ${actCarrierAggregation}=${False}
    ...    ${ignore_time}=${30}

    FOR    ${cell_index}    IN    @{cell_index_list}
        run keyword if   '${cell_index}' in @{GNB_PS_CELL_INDEX_LIST}
        ...    run keywords    Retry commercial ue detach if failed    AND
        ...    Call case with QCOM UE and record throughput info on specific cell for many times
        ...    gnb_ps_cell_index=${cell_index}    duration_time=${duration_time}
        ...    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}    repeat_times=${repeat_times}
        ...    exp_tput_percentage=${exp_tput_percentage}    verify_duration=${verify_duration}    ignore_time=${ignore_time}
        ...    sgnb_addition_on_spec_cell_needed=${sgnb_addition_on_spec_cell_needed}
        ...    actCarrierAggregation=${actCarrierAggregation}
        ...    ELSE    log to console    ${cell_index} not in \${GNB_PS_CELL_INDEX_LIST} [${GNB_PS_CELL_INDEX_LIST}], no need to do traffic test.
    END

2033 Perform ru lock unlock and check throughput for many ru many times
    [Documentation]    author: Zhang Ningning
    ...                attach to only one sector, no matter operate on any RU, the call still on the same sector.
    ...   the ${duration time} is traffic time, it can be largr number to make the traffic go on
    ...   because there is kill process if need to stop traffic.
    [Arguments]    ${ru_index_list}=${RU_INDEX_LIST}    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}     ${duration_time}=${3000}
    ...    ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}
    ...    ${repeat_times}=${TEST_REPEAT_TIMES}    ${connection}=GNB_OAM
    ...    ${alarm_check_needed}=${False}    ${allowed_fault_list}=${ALLOWED_FAULT_LIST}
    ...    ${ignore_time}=${30}
    FOR    ${ru_index}    IN    @{ru_index_list}
        2033 Perform ru lock unlock and check throughput for many times    ru_index=${ru_index}    para_update_timeout=${para_update_timeout}
        ...    duration_time=${duration_time}    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}
        ...    repeat_times=${repeat_times}    connection=${connection}    verify_duration=${verify_duration}
        ...    alarm_check_needed=${alarm_check_needed}    allowed_fault_list=${allowed_fault_list}
        ...    ignore_time=${ignore_time}
    END

2033 Perform ru lock unlock and check throughput for many times
    [Documentation]    author: Zhang Ningning
    [Arguments]    ${ru_index}   ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}    ${duration_time}=${3000}
    ...    ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}    ${repeat_times}=${TEST_REPEAT_TIMES}
    ...    ${connection}=GNB_OAM    ${alarm_check_needed}=${False}    ${allowed_fault_list}=${ALLOWED_FAULT_LIST}
    ...    ${ignore_time}=${30}
    FOR    ${run_time}    IN RANGE    ${repeat_times}
        Perform ru lock unlock    ru_index=${ru_index}    alarm_check_needed=${alarm_check_needed}    allowed_fault_list=${allowed_fault_list}
        2033 Call case with QCOM UE and record throughput info for many cells many times   para_update_timeout=${para_update_timeout}
        ...    duration_time=${duration_time}    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}
        ...    repeat_times=${1}    cell_index_list=${GNB_PS_CELL_INDEX_LIST}    verify_duration=${verify_duration}
        ...    ignore_time=${ignore_time}
    END

2033 Perform cell lock unlock and check throughput for many cells many times
    [Documentation]    author: Zhang Ningning
    ...   the ${duration time} is traffic time, it can be largr number to make the traffic go on
    ...   because there is kill process if need to stop traffic.
    [Arguments]    ${cell_index_list}=${CELL_INDEX_LIST}    ${repeat_times}=${TEST_REPEAT_TIMES}    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}
    ...    ${duration_time}=${3000}    ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}
    ...    ${dl_exp_tput}=${DL_EXPECT}    ${connection}=GNB_OAM    ${ignore_time}=${30}
    FOR    ${cell_index}    IN    @{cell_index_list}
        2033 Perform cell lock unlock and check throughput for many times    cell_index=${cell_index}    repeat_times=${repeat_times}
        ...    para_update_timeout=${para_update_timeout}    duration_time=${duration_time}    verify_duration=${verify_duration}
        ...    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${DL_EXPECT}    ignore_time=${ignore_time}
    END

2033 Perform cell lock unlock and check throughput for many times
    [Documentation]    author: Zhang Ningning
    ...    ${GNB_PS_CELL_INDEX_LIST} is the cell list which can do attach. it is set in variables.robot.
    [Arguments]    ${cell_index}    ${repeat_times}=${TEST_REPEAT_TIMES}
    ...   ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}
    ...    ${duration_time}=${3000}    ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}
    ...    ${dl_exp_tput}=${DL_EXPECT}    ${connection}=GNB_OAM    ${ignore_time}=${30}
    ${cell_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ${cellgrp_idx}    set variable    ${cell_mapping[${cell_index}]['cell_group_id']}
    FOR    ${run_time}    IN RANGE    ${repeat_times}
        Perform cell lock via rest api    cell_idx=${cell_index}
        Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked    cell_idx=${cell_index}    cell_group_idx=${cellgrp_idx}
        Perform cell unlock via rest api    cell_idx=${cell_index}
        Wait Until Keyword Succeeds    5 min    3 sec     Cell Should Be Unlocked    cell_idx=${cell_index}        cell_group_idx=${cellgrp_idx}
        Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
        ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}
        Run keyword if    '${cell_index}' in @{GNB_PS_CELL_INDEX_LIST}
        ...    run keywords    Retry commercial ue detach if failed    AND
        ...    Call case with QCOM UE and record throughput info on specific cell for many times    repeat_times=${1}
        ...    gnb_ps_cell_index=${cell_index}    para_update_timeout=${para_update_timeout}    verify_duration=${verify_duration}
        ...    duration_time=${duration_time}    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}    ignore_time=${ignore_time}
    END
