*** Settings ***
Documentation      Author: xiaodan.li@nokia-sbell.com
...                squad group: SG_03
...                feature : CB011169-CR-A(CB008227_Cloud)


Suite Setup    Common Suite Setup for Cloud

Suite Teardown    PA recover

Resource    ../Resources/HO_common_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008227/Resources/CB008227_common_keywords.robot


*** Variables ***
${atten_ip}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${max_attenuation_value}    ${127}
${vendor}    ${tl.attenuators[0].vendor}
${dl_throughput}    500M
${dl_port_5QI7}    ${53239}
${dl_port_5QI8}    ${55238}
@{dl_ports}    ${dl_port_5QI7}    ${dl_port_5QI8}
@{ue_index_list_239}    ${8}    ${8}
${file_name_EA003}    8227_EA003_non_NBR
${file_name_EA003_NBR}    8227_EA003_NBR
${control_pc_ip}    ${tl.ues[9].ssh_connection_details.addr}
${Golden_SCF_Path}    /opt/workspace/SCF/8227/

*** Test Cases ***
[1]CB008227_EA_03_B1_NBR_interworking_with_slice_Aware_Scheduler_and_NBR_congestion_Bbpooling_multi_BWP
    [Documentation]
    ...    This user scenario describes the gNB behaviour for Online modification Nominal Bit Rate parameters.
    ...    the case test base 8227 NBR working.
    [Timeout]     120 minutes
    [Tags]    CRT_TRUNK
    [Setup]
#    BTS preparation    vdu_count=${2}    cu_count=${1}    vdu_from_gnb2=${EMPTY}
#    Check GNB status and collect logs    vcu_ALLOWED_FAULT=${vcu_ALLOWED_FAULT}    vdu_ALLOWED_FAULT=${vdu_ALLOWED_FAULT}
    PA preparation
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1    ue_index=${8}
    Set APN point for sanmsungS22
    wait until keyword succeeds    3X    10s
    ...    set apn with special method    usedapn=${apn_muiltdrb}    location_apn=${location_apn}    ue_index=${8}
    wait until keyword succeeds    3X    10s    Attach and check NBR SA    ue_index=${8}
    [Teardown]    Run keywords
    ...    wait until keyword succeeds    3X    10s
    ...    set apn with special method    usedapn=${apn_weistatic}    location_apn=${location_apn}    ue_index=${8}
    ...    AND    Run keyword and ignore error    UE Detach with power UE    ue_index=${8}

*** Keywords ***
Attach and check NBR SA
    [Arguments]    ${ue_index}=${9}
    PA preparation
    multi_ues_operation_exe_with_threading    action=attach
    ...    pc_ip=${control_pc_ip}    ue_number=partial    ue_sn_txt=partial_ue_sn_8227.txt
    sleep    60s
    ${Gap1}    Check NBR SA
    ...    file_name=${file_name_EA003}    min_5QI7=${190}    min_5QI8=${190}    max_5QI7=${400}    max_5QI8=${400}
    Should be true    ${0}<=${Gap1}<=${20}
    FOR    ${index}    IN RANGE    ${23}    ${35}
        ${vakue_list_PA}    Create List    ${index}    ${index}    ${index}    ${index}
        set PA port on one cell    value=${vakue_list_PA}
        ${status_1}    Run keyword and return status    Check NBR SA
        ...    file_name=${file_name_EA003_NBR}    min_5QI7=${30}    min_5QI8=${100}    max_5QI7=${70}    max_5QI8=${110}
        Exit For Loop If    '${status_1}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    [Teardown]    UE Detach with power UE    ue_index=${ue_index}

Check NBR SA
    [Arguments]    ${file_name}    ${min_5QI7}    ${min_5QI8}    ${max_5QI7}    ${max_5QI8}
    ...    ${ue_index_list}=${ue_index_list_239}
    Start Traffic And Download the listened traffic    file_name_DL=${file_name}
    ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
    ...    ue_index_iperf=${ue_index_list}    ue_index=${8}    capabilities=samsungS21
    ${average_QCI7}    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI7}.txt    value_min=${min_5QI7}    value_max=${max_5QI7}
    ${average_QCI8}    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI8}.txt    value_min=${min_5QI8}    value_max=${max_5QI8}
    ${average_QCI7}    Convert To Integer    ${average_QCI7}
    ${average_QCI8}    Convert To Integer    ${average_QCI8}
    ${Gap1}    Evaluate    abs(${average_QCI7}-${average_QCI8})
    [Return]    ${Gap1}

Set APN point for sanmsungS22
    Set Suite Variable    ${apn_muiltdrb}    106 628
    Set Suite Variable    ${apn_weistatic}    106 845
    Set Suite Variable    ${location_apn}    380 1060