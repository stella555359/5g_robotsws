*** Settings ***
Documentation
...   This is for 1200 throughput checking keywords with Viavi UE
...   squad group: mmW_SG1

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Library     taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot


*** Keywords ***
# tput > exp_value
Evaluate throughput for NR data transfer
    [Documentation]    Author: Cui Lingxue
    ...    Description: evaluate ul data tranfer by check throughput on cobham
    [Arguments]    ${direction}    ${ue_index}=${0}    ${rb_id}=${6}    ${log_path}=${TS_CASE_LOG_PATH}
    ...    ${ul_data_transfer_exp}=${0}    ${dl_data_transfer_exp}=${0}
    ${nr_tput}     Get values on cobham by executing check GNB throughput command    throughput_log_file_path=${log_path}
    ...    ue_index=${ue_index}    rb_id=${rb_id}
    ${nr_ul_tput}    set variable    ${nr_tput['ul_tput_on_rb']}
    ${nr_dl_tput}    set variable    ${nr_tput['dl_tput_on_rb']}
    run keyword if    '${direction}'=='ul'
    ...      should be true    ${nr_ul_tput} > ${ul_data_transfer_exp}    msg='There is no traffic on NR UL leg'
    ...    ELSE IF    '${direction}'=='dl'
    ...      should be true    ${nr_dl_tput} > ${dl_data_transfer_exp}    msg='There is no traffic on NR DL leg'
    ...    ELSE     fail    msg='${direction}' is either ul or dl, please input correct value.
    [Return]    ${nr_tput}

Evaluate throughput for LTE data transfer
    [Documentation]    Author: Cui Lingxue
    ...                Description: Evaluate throughput for LTE UL data transfer, it is expected to be below some value
    ...                             if the ul data split mode set to NRLTE.
    [Arguments]    ${direction}    ${ue_index}=${0}    ${rb_id}=${6}    ${log_path}=${TS_CASE_LOG_PATH}
    ...    ${ul_data_transfer_exp}=${0}    ${dl_data_transfer_exp}=${0}
    ${lte_tput}     Get values on cobham by executing check ENB throughput command    throughput_log_file_path=${log_path}
    ...    ue_index=${ue_index}
    ${lte_ul_tput}    set variable    ${lte_tput['ul_average_tput']}
    ${lte_dl_tput}    set variable    ${lte_tput['dl_average_tput']}
    run keyword if    '${direction}'=='ul'
    ...      should be true    ${lte_ul_tput} > ${ul_data_transfer_exp}    msg='There is no traffic on LTE UL leg'
    ...    ELSE IF    '${direction}'=='dl'
    ...      should be true    ${lte_dl_tput} > ${dl_data_transfer_exp}    msg='There is no traffic on LTE DL leg'
    ...    ELSE     log to console    '${direction}' is either ul or dl, please input correct value.
    [Return]    ${lte_tput}

There should exist traffic on each DRB
    [Arguments]    ${rb_list}    ${ue_index}=${0}    ${log_path}=${TS_CASE_LOG_PATH}
    FOR    ${rb_id}    IN    @{rb_list}
        run keyword and continue on failure    Evaluate throughput for NR data transfer    direction=ul    ue_index=${ue_index}    rb_id=${rb_id}
        ...    log_path=${log_path}    ul_data_transfer_exp=${1}
        Evaluate throughput for NR data transfer    direction=dl    ue_index=${ue_index}    rb_id=${rb_id}    log_path=${log_path}
        ...    dl_data_transfer_exp=${1}
    END

There should exist traffic for each UE
    [Arguments]    ${number_of_ue}    ${log_path}=${TS_CASE_LOG_PATH}
	FOR    ${ue_index}    IN RANGE    ${number_of_ue}
        run keyword and continue on failure    Evaluate throughput for NR data transfer    direction=dl    dl_data_transfer_exp=${1}
        ...    ue_index=${ue_index}    log_path=${log_path}    dl_data_transfer_exp=${1}
        run keyword and continue on failure    Evaluate throughput for NR data transfer    direction=ul    ul_data_transfer_exp=${1}
        ...    ue_index=${ue_index}    log_path=${log_path}    ul_data_transfer_exp=${1}
    END
