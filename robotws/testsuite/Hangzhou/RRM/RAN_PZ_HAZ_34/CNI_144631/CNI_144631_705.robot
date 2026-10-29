*** Settings ***
Documentation
...    author: yang jiao
...    contact: jiao.1.yang@nokia.com
...    squad group: HAZ7
...    feature : CNI-144631

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CNI_144631/Resources/CNI144631_common_keyword.robot
#Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CNI_144631/Resources/CNI144631_common_keyword.py
#Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CNI_144631/Resources/TLConfigration_CNI144631.py
Library     ./Resources/kpi_check_keyword.py


Suite Setup       CNI144631 Suite setup
Suite Teardown    CNI144631 Suite Teardown


*** Test Cases ***
[1]CNI-144631_06_1F_3T_Scell_swap_CPU_calculation
    [Tags]  CRT_TRUNK
    [Setup]   CNI144631 Common Case Setup
    MTK90 Attach By Power UE And Start Traffic And Check TP    ul_throughput=${0}    dl_throughput=${10}
    ...    ul_list=${cell_id_list[0:1]}    dl_list=${cell_id_list[0:1]}    ue_index=${2}
    ...    target_avg_percent=0.98    log_time=10s    min_percent=0.85    ignore_time=10s
    A6 swap trigger
    MTK90 Stop Traffic And Detach UE    ue_index=${2}    if_ul=${True}    if_dl=${True}
    Sleep    6min
    Generate counter csv file And Check counter
    [Teardown]    CNI144631 Common Case Teardown

