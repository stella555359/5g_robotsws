*** Settings ***
Documentation     author: n5liu
...               contact: ning.4.liu@nokia-sbell.com
...               squad group: MMW_SG3
Suite Setup        Run Keyword And Ignore Error       robot_common_operations.Common Suite Setup
Suite Teardown     Run Keyword And Ignore Error       robot_common_operations.Common Suite Teardown

Library     OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...         throughput_computation

Variables   ./Resources/TLConfigration_9514.py
Resource    ./Resources/CB009514_common_keywords.robot



*** Test Cases ***
[1]CB009514_H_05_SA_multi_UE_2TDD_2CC_CA_DL_with_BF_CB007922
    [Tags]    HAZ3_T03
    [Documentation]    2CC TDD+TDD CA
    [Setup]    Case Setup
    Start Traffic And Check Tp    ul_tp_list=${ul_traffic_list[0:2]}    process=${1}    log_time=60s
    ...    exp_ul_tp=4   exp_dl_tp=1500   ul_list=${T928_all_nr_cell_list}    dl_list=${T928_all_nr_cell_list}
    ...    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    if_ul=${False}
    [Teardown]    Case Teardown




