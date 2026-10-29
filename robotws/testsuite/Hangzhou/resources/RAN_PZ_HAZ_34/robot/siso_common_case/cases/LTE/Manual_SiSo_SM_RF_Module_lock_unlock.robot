*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

*** Variables ***

*** Keywords ***
Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.6.30 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    [Arguments]    ${cell_list}=${None}    ${ue_num_for_call_per_cell}=1    ${dl_tp}=136  ${ul_tp}=12
    ...    ${duration}=${120}    ${protocol}=udp    ${check_wait_time}=30    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.5    ${min_percent}=0.1  ${with_call}=${True}
    ${flag}    run keyword and return status    Should contain    ${TEST_TAGS}[0]    S-
    ${SCF_Path}    run keyword if    ${flag}      Replace String    ${Golden_SCF_Path}    .xml    _${TEST_TAGS}[0].xml
        ...           ELSE    set variable     ${Golden_SCF_Path}
    run keyword if    ${flag}      Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    ${ru_index_list}    get all ru index
    ${cell_list}    get all cell id     cell_type=${cell_type}
    FOR  ${lock_id}  IN  @{ru_index_list}
        ${operate_list}    create list    ${lock_id}
        run keyword if  ${with_call}    Simple UE L3 Call And Throughput    cell_list=${cell_list}
        ...    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
        ...    duration=${duration}    protocol=${protocol}    check_wait_time=${check_wait_time}    log=${log}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${SCF_Path}
        sleep    3s
        Lock all RUs and check status LTE    ru_index_list=${operate_list}
        Unlock all RUs and check status LTE    ru_index_list=${operate_list}
        Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
        sleep    1min
        run keyword if  ${with_call}    Simple UE L3 Call And Throughput    cell_list=${cell_list}
        ...    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
        ...    duration=${duration}    protocol=${protocol}    check_wait_time=${check_wait_time}    log=${log}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${SCF_Path}
        sleep    3s
    END
