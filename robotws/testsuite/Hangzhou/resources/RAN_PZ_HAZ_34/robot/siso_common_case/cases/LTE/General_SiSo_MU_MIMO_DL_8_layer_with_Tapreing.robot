*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/scf_comm_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/ttilog_check.robot
*** Variables ***

*** Keywords ***
General_SiSo_MU_MIMO_DL_8_layer_with_Tapreing
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to operational 4G BTS, verify activated CA function.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.02.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_index}=${None}  ${cell_id}=${None}
    ...    ${ue_num_for_call_per_cell}=2    ${dl_tp}=123.2  ${ul_tp}=11.6
    ...    ${duration}=${600}    ${protocol}=udp    ${check_wait_time}=60
    ...    ${target_avg_percent}=0.3    ${min_percent}=0.1    ${tool_path}=/home/ute/tti_tool
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _${TEST_TAGS}[0].xml
    Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    ${cell_id_list}    Get All Cell Id    ru_index=${ru_index}    cell_type=${cell_type}
    ${cell_list}    run keyword if    '${cell_id}'=='${None}'    set variable    ${cell_id_list}
    ...    ELSE    create list    ${cell_id}
    ${cell_list}    run keyword if    '${cell_list}'=='${None}'    create list    ${1}
    ...    ELSE    set variable    ${cell_list}
    ${ue_index_list}    create list
    ${ue_index_list}    ${cell_id_list}    Obtain UE List for Given Cell List    cell_list=${cell_list}
    ...    scf_path=${SCF_Path}    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
    should not be empty    ${ue_index_list}
    ...    msg=Please add ue mapping in __init__.py under robotws/commissionings/HGZ/{testline_name}}, refer to 7_5_UTE5G402T319
    wait until keyword succeeds    3x    30sec    UE L3 CAll and Verfify Tti Log    ue_index_list=${ue_index_list}
    ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    duration=${duration}   protocol=${protocol}    check_wait_time=${check_wait_time}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${SCF_Path}
    [Teardown]  Commissioning SCF And Check On Air for Common    scf_path=${Golden_SCF_Path}

Verfify Tti Log
    [Arguments]  ${tool_path}=/home/ute/tti_tool
    download and unzip pstools    SW=${Active_SW_version}    tool_path=${tool_path}
    sleep    3min
    start to captured tti log    eNB_IP_Addr=${sbts_addr}    captured_time=30    tool_path=${tool_path}
    check dl column values in tti csv file    tool_path=${tool_path}
    check ul column values in tti csv file    tool_path=${tool_path}

UE L3 CAll and Verfify Tti Log
    [Arguments]    ${ue_index_list}    ${dl_tp}    ${ul_tp}
    ...    ${duration}=60    ${protocol}=udp    ${check_wait_time}=60    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${scf_path}=${Golden_SCF_Path}
    ...    ${mobile_network_system}=LTE    ${tool_path}=/home/ute/tti_tool
    Simple Ue Prepare    ue_index_list=${ue_index_list}    scf_path=${SCF_Path}
    ${ue_num}    get length    ${ue_index_list}
    ${start_traffic_duration}    evaluate    ${duration}+${ue_num}*100+180
    ${start_traffic_dl}    evaluate    ${dl_tp}*1.25
    ${start_traffic_ul}    evaluate    ${ul_tp}*1.5
    Simple Ue Attach and Start Traffic    ue_index_list=${ue_index_list}    dl_tp=${start_traffic_dl}    ul_tp=${start_traffic_ul}
    ...    duration=${duration}    check_wait_time=${check_wait_time}    protocol=${protocol}
    ...    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
    run keyword and continue on failure    Verfify Tti Log    tool_path=${tool_path}
    Simple Ue Collect Tput    ue_index_list=${ue_index_list}    duration=${duration}    ignore_time=${check_wait_time}
    Simple Ue Stop DL UL Traffic    ue_index_list=${ue_index_list}    protocol=${protocol}
    Simple UE Verify Peak Throughput    ue_index_list=${ue_index_list}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${SCF_Path}    mobile_network_system=LTE
    [Teardown]  run keywords  Simple Ue Stop DL UL Traffic    ue_index_list=${ue_index_list}    protocol=${protocol}    AND
    ...    Simple Ue Detach    ue_index_list=${ue_index_list}
