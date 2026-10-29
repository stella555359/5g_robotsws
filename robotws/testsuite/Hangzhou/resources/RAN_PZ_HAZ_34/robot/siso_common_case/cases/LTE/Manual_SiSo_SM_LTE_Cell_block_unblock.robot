*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

*** Variables ***

*** Keywords ***
Manual_SiSo_SM_LTE_Cell_block_unblock
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify cell block/ unblock functionality.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.06.2022 - - Created
    ...    *******************
    ...    Owner_tong.chen@nokia-sbell.com
    [Arguments]  ${with_call}=${False}  ${call_duration}=${60}
    ...    ${ue_num_for_call_per_cell}=1    ${dl_tp}=128  ${ul_tp}=12
    ...    ${duration}=${60}    ${protocol}=udp    ${check_wait_time}=30    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.5    ${min_percent}=0.1
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}
    ${cell_id_list}  Get All Cell Id    cell_type=${cell_type}
    ${cell_num}    get length  ${cell_id_list}
    FOR  ${block_id}  IN  @{cell_id_list}
        ${operate_list}    create list    ${block_id}
        SBTS Block cells and check status    block_list=${operate_list}
        SBTS UnBlock Cells and check status    block_list=${operate_list}
    END
    run keyword if  ${cell_num}>1    SBTS Block and UnBlock Cells    block_list=${cell_id_list}
    run keyword if  ${with_call}    Make All RUs L3 Call And Throughput   ${cell_id_list}
    ...    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    duration=${duration}    protocol=${protocol}    check_wait_time=${check_wait_time}    log=${log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}  
    [Teardown]   Selenium Logout And Close Browser

Make All RUs L3 Call And Throughput
    [Arguments]   ${cell_id_list}   ${ue_num_for_call_per_cell}=1   ${dl_tp}=128  ${ul_tp}=12
    ...    ${duration}=${60}    ${protocol}=udp    ${check_wait_time}=30    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.5    ${min_percent}=0.1
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Simple UE L3 Call And Throughput      cell_list=${cell_id_list}
        ...    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
        ...    duration=${duration}    protocol=${protocol}    check_wait_time=${check_wait_time}    log=${log}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   allowed_no_ue=${True}
        sleep    3s
    END
