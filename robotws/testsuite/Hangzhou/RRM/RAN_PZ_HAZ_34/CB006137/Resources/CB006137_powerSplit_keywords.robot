*** Settings ***
Documentation    keywords for power split

*** Keywords ***
#Adjust Pcell Scell signal and check powerState
#    [Documentation]    Author: Wang Yixiang
#    ...    Collect TTI log and check power state in tti log
#    ...    powerStateInfo:is collector name for tti log, and A2A check point file name, can be:
#    ...        pcellsuspend, pcellresume, scellsuspend, scellresume
#    ...    exp_pa_value is set to the same pa value of listed RUs at once
#    ...    pa_value_list is set to same PA value of each RU one by one(one RU's PA values is set at same time)
#    ...    check_flag: is use to determin check TTI log or not.
#    ...    adjust_pa_slowly, True means adjust PA step by step, False mean adjust PA to the at once.
#    ...    ${start_pa_value}=${TDD_PA_SUSPEND}  ${TDD_PA_SUSPEND} is from __init__6137__.py of commission folder
#    [Arguments]    ${powerStateInfo}    ${cell_idx_list}   ${pa_value_list}=${None}   ${exp_pa_value}=${None}
#    ...    ${sleep_time}=2s    ${check_flag}=${True}    ${adjust_pa_slowly}=${False}   ${start_pa_value}=${TDD_PA_SUSPEND}
#    log to console   Adjust PA and check power state:${powerStateInfo}.
#    ${pa_value_list}    string2list    ${pa_value_list}
#    ${cell_idx_list}    string2list    ${cell_idx_list}
#    ${ru_idx_list}    Get RU index list by cell ID    cell_idx_list=${cell_idx_list}
#    Start Ttitrace With Streaming Mode    collector_names=${powerStateInfo}
#    run keyword if    ${exp_pa_value}==${None}    Adjust attenuator for RU one by one
#    ...   pa_value_list=${pa_value_list}    ru_idx_list=${ru_idx_list}
#    run keyword if    ${exp_pa_value}!=${None} and ${adjust_pa_slowly}==${False}    Set attenuator ports of specified RUs to same value
#    ...   exp_pa_value=${exp_pa_value}    ru_idx_list=${ru_idx_list}
#    run keyword if    ${exp_pa_value}!=${None} and ${adjust_pa_slowly}==${False}    Set attenuator ports of specified RUs to same value
#    ...   exp_pa_value=${exp_pa_value}    ru_idx_list=${ru_idx_list}
#    run keyword if    ${exp_pa_value}!=${None} and ${adjust_pa_slowly}    Adjust PA value step by step
#    ...    start_value=${start_pa_value}    end_value=${exp_pa_value}    ru_idx_list=${ru_idx_list}
#    Sleep   ${sleep_time}
#    Stop Ttitrace    collector_names=${powerStateInfo}
#    ${tti_csv_file_path}    Decode Ttitrace Log    collector_names=${powerStateInfo}
#    Run keyword if    ${check_flag}    A2A Check TTI CSV File    ini_path=${CURDIR}/../TestData/A2A/ttitrace_${powerStateInfo}.ini
#    ...   tti_csv_file_path=${tti_csv_file_path}
#
#Adjust Pcell Scell signal and check RLQ state
#    [Documentation]    Author: Wang Yixiang
#    ...    Ajust Pcell Scell sinal and check RLQ status from tti log
#    ...    name:is collector name for tti log, and A2A check point file name, should be align with name of A2A check point file:
#    ...        ul_rlq_bad, ul_rlq_good
#    ...    exp_pa_value is set to the same pa value of listed RUs at once
#    [Arguments]    ${name}    ${exp_pa_value}
#    ...    ${sleep_time}=2s
#    log to console   Adjust PA and check RLQ state:${name}.
#    ${ru_idx_list}    Get RU index list by cell ID    cell_idx_list=${CELL_INDEX_LIST}
#    Start Ttitrace With Streaming Mode    collector_names=${name}
#    Set attenuator ports of specified RUs to same value    exp_pa_value=${exp_pa_value}    ru_idx_list=${ru_idx_list}
#    Sleep   ${sleep_time}
#    Stop Ttitrace    collector_names=${name}
#    ${tti_csv_file_path}    Decode Ttitrace Log    collector_names=${name}
#    A2A Check TTI CSV File    ini_path=${CURDIR}/../TestData/A2A/ttitrace_${name}.ini
#    ...   tti_csv_file_path=${tti_csv_file_path}

Adjust Pcell Scell signal and check RLQ state aasyslog
    [Documentation]    Author: Wang Yixiang
    ...    collect aasyslog and check ul rlq state
    ...    messageInfo can be:
    ...       ul scell rlq turn to bad with rnti
    ...       ul scell rlq turn to good with rnti
    ...    exp_pa_value is set to the same pa value of listed RUs at once
    [Arguments]    ${messageInfo}    ${pa_start}    ${pa_end}    ${pa_interval}=5
    ...    ${aasyslog_name}=aasyslog_RLQ.txt
    log to console   Adjust PA and check RLQ state:${messageInfo}.
    ${ru_idx_list}    Get RU index list by cell ID    cell_idx_list=${CELL_INDEX_LIST}
    Prepare and start aasyslog    log_name=${aasyslog_name}
    Adjust PA gradually for specified RUs    pa_start=${pa_start}    pa_end=${pa_end}    pa_interval=${pa_interval}    ru_idx_list=${ru_idx_list}
    Run Keyword And Ignore Error    Check messageInfo in aasyslog   messageInfo=${messageInfo}    timeout=90s    aasyslog_name=${aasyslog_name}
    [Teardown]    Teardown the Aasyslog save progress

Adjust attenuator for RU one by one
    [Documentation]    Author: Wang Yixiang
    ...    exp_pa_value is pa value,means all ru set to same PA value, for example:exp_pa_value=10
    ...    ru_idx_list can be ru index in testline init file, for example:ru_idx_list=0,1
    [Arguments]    ${pa_value_list}    ${ru_idx_list}    ${gnb_index}=${0}
    FOR    ${index}    ${ru_index}    IN ENUMERATE    @{ru_idx_list}
        ${pa_value}    set variable   ${pa_value_list}[${index}]
        Initialize attenuator for specified RU   exp_pa_value=${pa_value}    ru_index=${ru_index}   multi-ports=${True}    gnb_index=${gnb_index}
    END

#Collect and check TTI logs
#    [Documentation]    Author: Wang Yixiang
#    ...    collect and check tti logs
#    [Arguments]    ${ini_path}    ${tti_csv_file_name}=tcpdump_ttitrace_ul.csv
#    ...    ${pcell_idx}=${PCELL_ID}    ${scell_idx}=@{SCELL_ID_UL_ADD}[0]
#    ...    ${collector_names}=l2stream3_ttitrace    ${duration}=3
#    ${tti_csv_file_name}    Capture And Decode TTitrace    collector_names=${collector_names}    duration=${duration}
#    A2A Check TTI CSV File    ini_path=${ini_path}    tti_csv_file_path=${tti_csv_file_path}
#    ...    tti_csv_file_name=${tti_csv_file_name}
#    ...    pcell_idx=${pcell_idx}    scell_idx=${scell_idx}

#A2A Check TTI CSV File
#    [Documentation]    Author: Wang Yixiang
#    ...    check tti log via A2A
#    ...    ${tti_csv_file_name} is tti csv file name in ${ini_path}, set variable dynamicly
#    ...    ${pcell_physCellId} is pcell id in ${ini_path}, such as ttitrace_pcellsuspend.ini or ttitrace_pcellsuspend.csv
#    [Arguments]    ${ini_path}    ${tti_csv_file_path}   ${tti_csv_file_name}=tcpdump_ttitrace_ul.csv
#    ...    ${pcell_idx}=${PCELL_ID}    ${scell_idx}=@{SCELL_ID_UL_ADD}[0]
#    ${pcell_physCellId}    Get nrPHYCellID based on cell index    cell_index=${pcell_idx}
#    ${scell_physCellId}    Get nrPHYCellID based on cell index    cell_index=${scell_idx}
#    ta_a2a.Check Log With Au2anlysis
#    ...    ini_path=${ini_path}
#    ...    log_need_to_check=i
#    ...    save_log_directory=${tti_csv_file_path}
#    [Teardown]   run keyword and ignore error     Run    rm ${tti_csv_file_path}/tcpdump_ttitrace_dl.csv

Get nrPHYCellID based on cell index
    [Documentation]  Author: Wang Yixiang
    ...    :param ${list_cell_index}: should be in list format
    ...    If cell_mapping has value, then use it directly, otherwise will re-get from GNB based on provided connection
    ...    Return the nrCellIdentity value as a list based on cell index
    [Arguments]    ${cell_index}    ${connection}=GNB_OAM    ${cell_mapping}=${NR_CELL_ID_MAPPING}
    ${cell_mapping}    Run keyword if    ${cell_mapping}    Set variable    ${cell_mapping}
    ...    ELSE    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ${physicalCellId}    Evaluate    str(${cell_mapping[${cell_index}]['physicalCellId']})
    [Return]  ${physicalCellId}

Get RU index list by cell ID
    [Documentation]   Author: Wang Yixiang
    ...    :get ru index list of pcell and scell(contains UL) from NR_CELL_ID_MAPPING
    [Arguments]    ${cell_idx_list}
    ${ru_idx_list}    create list
    FOR    ${cell_idx}    IN    @{cell_idx_list}
        ${ru_index}   set variable    ${NR_CELL_ID_MAPPING[${cell_idx}]['ruIndex_in_init']}
        Append to list    ${ru_idx_list}    ${ru_index}
    END
    [Return]    ${ru_idx_list}

Set weightRatioOfUePwrScellVsPcell via restapi
    [Documentation]  Author: Wang Yixiang
    ...      3) Set weightRatioOfUePwrScellVsPcell:
    ...         In case more UE power is expected to be allocated to P-Cell, a smaller value below 1 need be set,
    ...         and in case more UE power is expected to be allocated to S-Cell, a bigger value above 1 need be set.
    [Arguments]  ${connection}=GNB_OAM    ${value}=WeightRatio 1
    ${nidd_weightRatioOfUePwrScellVsPcell_value}    evaluate
    ...    [dict(dist_name='${DN_NRBTS}/NRCELL-${PCELL_ID}', parameter='weightRatioOfUePwrScellVsPcell', value='${value}')]

    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${nidd_weightRatioOfUePwrScellVsPcell_value}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    connection=${connection}

    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}

#Modify and Add NIDD by rest api and wait onair
#    [Documentation]  Author: Wang Yixiang
#    ...   modify and add nidd prameter via rest api
#    [Arguments]    ${param_to_upd}    ${param_to_add}
#    &{dict_params_to_modify}    Create dictionary
#
#    Set to dictionary    ${dict_params_to_modify}    param_to_upd=${parameters_mod}
#    Set to dictionary    ${dict_params_to_modify}    param_to_add=${parameters_add}
#    run keyword if    ${dict_params_to_modify}!=${None}
#    ...    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
#    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
#
#    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}

Adjust PA value step by step
    [Documentation]  Author: Wang Yixiang
    ...   Adjust PA value step by step
    ...   start_value: start PA value
    ...   ru_idx_list: RU list that need to adjust PA
    ...   end_value: end PA value
    ...   step_interval: adjust PA step one time
    [Arguments]    ${start_value}    ${ru_idx_list}   ${end_value}=0    ${step_interval}=-2

    Set attenuator ports of specified RUs to same value    exp_pa_value=${start_value}    ru_idx_list=${ru_idx_list}
    ${exp_pa_value}    set variable    ${start_value}
    FOR    ${n}    IN RANGE    127
        ${exp_pa_value}    evaluate    ${exp_pa_value} + ${step_interval}
        ${exit_flag}    evaluate    ${exp_pa_value}<${end_value}
        ${set_end_value_flag}    evaluate    ${exp_pa_value}==${end_value}
        Exit For Loop If    ${exit_flag}
        Set attenuator ports of specified RUs to same value    exp_pa_value=${exp_pa_value}    ru_idx_list=${ru_idx_list}
    END
    run keyword if    ${set_end_value_flag}==${False}
    ...    Set attenuator ports of specified RUs to same value    exp_pa_value=${end_value}    ru_idx_list=${ru_idx_list}

#Verify scell data resumed when scell rlq back to good 4cc
#    [Documentation]    Author: Wang Yixiang
#    [Arguments]     ${cell_idx_list}=${SCELL_ID_UL_ADD}        ${pa_scell_rlq_good}=${0}
#    ${ru_idx_list}    Get RU index list by cell ID    cell_idx_list=${cell_idx_list}
#    ${scell_ru_index}    set variable    ${ru_idx_list}[0]
#    #Adjust to Good
#    Initialize attenuator for specified RU     exp_pa_value=${pa_scell_rlq_good}    ru_index=${scell_ru_index}
#    Sleep    10s    reason=Wait for traffic to be stable.
#
#    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
#    ...    exp_ul_indiv=${None}    exp_dl_indiv=${EXP_DL_INDIV}   exp_dl=1   exp_ul=-1   data_transfer_direction=dl

#Verify scell data suspened and not deactivated when scell rlq in bad 4cc
#    [Documentation]    Author: Wang Yixiang
#     ...    Note: sleep time 60s need small than bad_rlq_count*sCellChannelEstimationPeriod/1000,80*2000ms/1000
#    [Arguments]     ${cell_idx_list}=${SCELL_ID_UL_ADD}      ${pa_scell_rlq_bad}=${40}
#    ...             ${scell_deactivation_method}=bufferBased
#    ...             ${log_name}=scell_suspend_no_deactive_when_rlq_go_into_bad.txt
#    ${ru_idx_list}    Get RU index list by cell ID    cell_idx_list=${cell_idx_list}
#    ${scell_ru_index}    set variable    ${ru_idx_list}[0]
#
#    Prepare and start aasyslog   log_name=${log_name}
#    Initialize attenuator for specified RU     exp_pa_value=${pa_scell_rlq_bad}    ru_index=${scell_ru_index}
#
#    Sleep     10s    reason=Wait for Bad RLQ, Scell data suspend
#
#    ${EXP_DL_INDIV_BAD}    Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_F10M_2x2_256QAM_POOL}
#    ...    0    ${EXP_DL_T60M_2x2_256QAM_1070}
#
#    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
#    ...    exp_ul_indiv=${None}    exp_dl_indiv=${EXP_DL_INDIV_BAD}   exp_dl=1   exp_ul=-1   data_transfer_direction=dl
#    ...    min_percent=0.4    tput_duration=30s    check_tput_ignore_time=10s
#
#    #during 30s, no scell deactive happened
#    ${is_scell_deactivated}    Run keyword and return status    Stop aasyslog to check scell deactivation
#    ...                sCelldeactivationMethod=${scell_deactivation_method}   log_name=${log_name}      timeout=30s
#    ...                scell_operator_mode=dlAndUl    scell_id=${SCELL_ID_UL_ADD}[0]
#    should not be true    ${is_scell_deactivated}
#    [Teardown]    run keyword and ignore error    Teardown the Aasyslog save progress
