*** Settings ***
Documentation    T+F CA
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009169/Resources/CB009169_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006137/Resources/CB006137_powerSplit_keywords.robot
Force Tags        5G_RRM   PY36    RF50

Suite Setup        Suite preparation    frame_structure=1116
Suite Teardown     run keyword and ignore error    CA Suite teardown

*** Variables ***
${A1_HYS_SCELL_ADD_SSB_RSRP_BC_7}    0
${A1_THRES_SCELL_ADD_SSB_RSRP_TDD_BC_7}    77
${A1_THRES_SCELL_ADD_SSB_RSRP_FDD_BC_7}    78
${A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP_BC_7}   320ms

${A2_HYS_SCELL_REL_SSB_RSRP_BC_7}    0
${A2_THRES_SCELL_REL_SSB_RSRP_BC_7}    40
${A2_TIME_TO_TRIGGER_SCELL_REL_SSB_RSRP_BC_7}    2560ms

*** Test Cases ***
CB009169-SR_BC_B7_007_FR1_Radio_link_quality_based_SCell_deactivation_in_UL_CA_BufferBased_2TDD_2FDD_cells
    [Documentation]    author: Liu Zheng \n
    ...    This case use CELL-1,CELL-2,CELL-3,CELL-4 for 9169 CA test\n
    ...    scelladditionmethod is covbasedA1,  the A1 based scell addition verification can be verified by
    ...    CB009169-SR_BE_B8_015_ABIO_TDD_100Mhz_FDD_20Mhz_Reset_L2_RT_A1_ScellAddition_A2_ScellReleased_BF_Enable ,
    ...    So this case  will not adjust PA from bad to good to verify A1 scell addition again. Sells can be added in step1.
    ...    This case to check UL rlq status for ULCA.\n
    ...      1) UE attach and verify scell addition\.n
    ...        Start UL and DL traffic and verify UL and DL throughput, check throughput.\n
    ...      2) adjust the pcell siginal to a little worse to avoid PingPong. \n
    ...      3) Adjust scell with UL attunation to bigger value to simulate UE move from cell center to cell edge,
    ...         check UL suspend and DL still have throughput. \n
    ...      4) Adjust attunation to smaller value to simulate UE move from cell edge to cell center,
    ...         move in of the UL coverage of joint DL/UL SCell again. scell UL recovered. \n
    ...      5) repeat step3, scell UL suspend again. \n
    ...      6) continue to rwmove UE to cell adge, move out of the DL coverage of joint DL/UL scell,  the DL is also suspend
    ...          wait for some time, this scell deactive permanent. \n
    ...      7) continue to adjust all scells signal to worse value to make all scells A2 release. \n
    ...      8) adjust all cells throughout to good, A1 scell addition again. \n
    [Setup]    9169 Case setup    dict_params_to_modify=${MODIFY_SCF_BC_B7_007_RLQ_API}
    ...    ca_group_mapping_4cc=${T1_F1_T2_F2_4CC_CA_GROUP_COMMON}
    Perform cell lock via rest api    cell_idx=${5}
    # by default, the UL 200M, DL 2700M, iperf traffic duration 3000s
    log to console    ***step1: L3 call check throughput***\n
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1116}    exp_dl_indiv=${EXP_DL_INDIV_1116}
    ...    tput_duration=60s   is_need_to_stop_traffic=${False}

    log to console     ***step2:set pcell signal worse to not reach to A1 scell addition to avoid PingPong***\n
    Set attenuator ports of specified RUs to same value    exp_pa_value=${10}    ru_idx_list=0

    log to console     ***step3:set scell which with ul CA signal bad and check UL suspend and DL still have throughput***\n
    Run keyword and continue on failure    Adjust scell with UL signal to bad gradualy and check UL suspend and DL still have throughput
    ...    messageInfo=ul scell rlq turn to bad   aasyslog_name=step3_aasyslog_check_ul_suspend.txt

    log to console     ***step4:set scell which with ul CA signal good and check UL scheduling recovered***\n
    Run keyword and continue on failure    Adjust scell with UL signal to good and check UL scheduling recovered
    ...    pa_value=${0}    messageInfo=ul scell rlq turn to good
    ...    aasyslog_name=step4_aasyslog_ul_scheduling_recovered.txt

    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_UL_RECOVER}    exp_dl_indiv=${EXP_DL_INDIV_UL_RECOVER}   exp_dl=1   exp_ul=1   data_transfer_direction=both
    ...    min_percent=0.4    tput_duration=30s    check_tput_ignore_time=10s

    log to console     ***step5: repeat step3 and UL suspend***\n
    Run keyword and continue on failure    Adjust scell with UL signal to bad gradualy and check UL suspend and DL still have throughput
    ...    messageInfo=ul scell rlq turn to bad   aasyslog_name=step5_aasyslog_check_ul_suspend.txt

    log to console     ***ste6: set the scell which with ul CA signal even worse and check the DL is also suspend***\n
#    ${PA_END_FOR_DL_SUSPEND}    set variable if    '${MRBTS_ID}'=='255'   ${PA_END_FOR_DL_SUSPEND_255}    ${PA_END_FOR_DL_SUSPEND_1170}
    Run keyword and continue on failure
    ...    Adjust scell with UL signal to bad gradualy and check UL suspend and DL is also suspend and scell permanent deactivate
    ...    pa_start=${PA_END_FOR_UL_SUSPEND}    pa_end=${PA_END_FOR_DL_SUSPEND}
    ...    messageInfo=RlqAlgorithm prepare sending SCellStatusInd with permanent deactivation
    ...    aasyslog_name=step6_aasyslog_check_ul_and_dl_suspend.txt
    ${EXP_UL_INDIV_BAD}    Create List    50    0    -1    -1
    ${EXP_DL_INDIV_BAD}    Create List    1100    0    470    90
    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_BAD}     exp_dl_indiv=${EXP_DL_INDIV_BAD}   exp_dl=1   exp_ul=1   data_transfer_direction=both
    ...    min_percent=0.4    tput_duration=30s    check_tput_ignore_time=10s

    log to console     ***ste7: set all the scells signal bad and reach to the A2 Scell release threshold, all scells released***\n
    Adjust all scells with signal to bad check all scell released

    log to console     ***ste8: set all the cells signal good and A1 scell addition again and throughput can peak***\n
    Adjust Pcell Scell Signal Back To Good To Trigger A1 Scell Addition Again   tcpdump_log_name=Scell_add_again_after_released
    ...    pcell_exp_pa_value=${INIT_PA_T1_F1_T2_F2}    scell_index_ul=${SCELL_ID_UL_ADD}    scell_index_dl=${SCELL_ID_DL_ADD}

    [Teardown]    run keywords    run keyword and ignore error   Perform cell unlock via rest api     cell_idx=${5}
    ...    AND    run keyword and ignore error    Common case teardown    detach_ue=${True}

*** Keywords ***
Suite preparation
    [Arguments]    ${frame_structure}
    set suite variable    ${INIT_PA}    ${INIT_PA_T1_F1_T2_F2}
    9169 Suite preparation    cell_chbw_config=4CC_T100M_F20M_F10M_T60M
    ...    pa_values_mapping=${INIT_PA}
    ...    ca_group_mapping_3cc=${T1_F1_F2_3CC_CA_GROUP_COMMON}
    ...    ca_group_mapping_4cc=${T1_F1_T2_F2_4CC_CA_GROUP_COMMON}
    ...    frame_structure=${frame_structure}
    Set tput expectation for suite level

Set tput expectation for suite level
    [Documentation]    for 9169 cases throughput check, the ${cell_index} is set to [1, 2, 4, 3],
    ...    so the throughput should align the ${cell_index}

    ${EXP_DL_INDIV_1116}    Create List    ${EXP_DL_T100M_4x4_256QAM_1116}    ${EXP_DL_F20M_2x2_256QAM}
    ...    ${EXP_DL_T60M_2x2_256QAM_1116}    ${EXP_DL_F10M_2x2_256QAM}
    ${EXP_UL_INDIV_1116}    Create List    ${EXP_UL_T100M_2x2_64QAM_1116}  ${EXP_UL_F20M_2x2_64QAM_1116}  -1    -1

    ${EXP_DL_INDIV_DL_1116_FOR_UL_SUSPEND}    Create List              1200   20    470   90
    ${EXP_DL_INDIV_DL_1116_FOR_UL_AND_DL_SUSPEND}     Create List      10     0     10    10
    ${EXP_UL_INDIV_1116_SCELL_SUSPEND}    Create List                  50     0     -1    -1

    ${EXP_UL_INDIV_UL_RECOVER}    Create List                          50     40    -1    -1
    ${EXP_DL_INDIV_UL_RECOVER}    Create List                          1100   210   450   90

    Set suite variable    ${EXP_DL_INDIV_1116}
    Set suite variable    ${EXP_UL_INDIV_1116}
    Set suite variable    ${EXP_DL_INDIV_DL_1116_FOR_UL_SUSPEND}
    Set suite variable    ${EXP_DL_INDIV_DL_1116_FOR_UL_AND_DL_SUSPEND}
    Set suite variable    ${EXP_UL_INDIV_1116_SCELL_SUSPEND}
    Set suite variable    ${EXP_UL_INDIV_UL_RECOVER}
    Set suite variable    ${EXP_DL_INDIV_UL_RECOVER}

Adjust scell with UL signal to bad gradualy and check UL suspend
    [Documentation]  Author: Liu Zheng
    [Arguments]   ${messageInfo}=ul scell rlq turn to bad    ${pa_end}=${PA_END_FOR_UL_SUSPEND}
    ...    ${aasyslog_name}=ul_scheduling_suspend.txt    ${list_cell_id}=${SCELL_ID_UL_ADD}

    Prepare and start aasyslog    log_name=${aasyslog_name}
    @{list_ruIndex}    _Get ru index based on input cell index    list_cell_id=${list_cell_id}

    FOR    ${pa_value}    IN RANGE   ${0}    ${pa_end}    ${1}
        Set attenuator ports of specified RUs to same value    exp_pa_value=${pa_value}    ru_idx_list=${list_ruIndex}
    END
    Run Keyword And Ignore Error    Check messageInfo in aasyslog   messageInfo=${messageInfo}    timeout=90s    aasyslog_name=${aasyslog_name}
    [Teardown]    Run keyword and ignore error    Teardown the Aasyslog save progress


Adjust scell with UL signal to bad gradualy and check UL suspend and DL still have throughput
    [Documentation]  Author: Liu Zheng
    [Arguments]   ${messageInfo}=ul scell rlq turn to bad    ${pa_end}=${PA_END_FOR_UL_SUSPEND}
    ...    ${aasyslog_name}=ul_scheduling_suspend.txt    ${list_cell_id}=${SCELL_ID_UL_ADD}

    Run keyword and continue on failure
    ...    Adjust scell with UL signal to bad gradualy and check UL suspend    messageInfo=${messageInfo}    pa_end=${pa_end}
    ...    aasyslog_name=${aasyslog_name}    list_cell_id=${list_cell_id}

    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1116_SCELL_SUSPEND}


Adjust scell with UL signal to good and check UL scheduling recovered
    [Documentation]  Author: Liu Zheng
    [Arguments]   ${pa_value}    ${messageInfo}   ${aasyslog_name}=ul_scheduling_recovered.txt
    ...    ${list_cell_id}=${SCELL_ID_UL_ADD}

    Prepare and start aasyslog    log_name=${aasyslog_name}
    @{list_ruIndex}    _Get ru index based on input cell index    list_cell_id=${list_cell_id}
    Set attenuator ports of specified RUs to same value    exp_pa_value=${pa_value}    ru_idx_list=${list_ruIndex}

    Run Keyword And Ignore Error
    ...    Check messageInfo in aasyslog   messageInfo=${messageInfo}    timeout=90s    aasyslog_name=${aasyslog_name}

    [Teardown]    Run keyword and ignore error    Teardown the Aasyslog save progress

Adjust scell with UL signal to bad gradualy and check UL suspend and DL is also suspend and scell permanent deactivate
    [Arguments]   ${pa_start}=${PA_END_FOR_UL_SUSPEND}    ${pa_end}=${PA_END_FOR_DL_SUSPEND}
    ...    ${messageInfo}=RlqAlgorithm prepare sending SCellStatusInd with permanent deactivation
    ...    ${aasyslog_name}=aasyslog_check_ul_and_dl_suspend.txt
    ...    ${list_cell_id}=${SCELL_ID_UL_ADD}

    Prepare and start aasyslog    log_name=${aasyslog_name}
    @{list_ruIndex}    _Get ru index based on input cell index    list_cell_id=${list_cell_id}

    FOR    ${pa_value}    IN RANGE   ${pa_start}    ${pa_end}    ${1}
        Set attenuator ports of specified RUs to same value    exp_pa_value=${pa_value}    ru_idx_list=${list_ruIndex}
    END
    ${scell_deactivate_time}  evaluate  ${SCELL_BAD_RLQ_COUNT}*(${SCELL_CHANNEL_ESTIMATION_PERIOD})/1000+40
    sleep    ${scell_deactivate_time}
    Run Keyword And Ignore Error
    ...   Check messageInfo in aasyslog   messageInfo=${messageInfo}    timeout=90s    aasyslog_name=${aasyslog_name}
    [Teardown]    Run keyword and ignore error    Teardown the Aasyslog save progress

_Get ru index based on input cell index
    [Documentation]  Author: Ding Binmei
    ...    ${NR_CELL_ID_MAPPING}: Suite variable set in case suite setup step
    [Arguments]    ${list_cell_id}
    @{list_cell_id}    string_list.string2list    input_str=${list_cell_id}
    @{list_ruIndex}    Create list
    FOR    ${cell_id}    IN    @{list_cell_id}
        Append to list    ${list_ruIndex}    ${NR_CELL_ID_MAPPING[${cell_id}]['ruIndex_in_init']}
    END
    [Return]  ${list_ruIndex}

Adjust all scells with signal to bad check all scell released
    [Arguments]    ${tcpdump_log_name}=CA_A2_Report_When_Scell_Bad
    ...            ${scell_index_list_check}=${None}
    ...            ${cell_list}=${SCELL_ID_DL_ADD}    ${scell_exp_pa_value}=${70}

    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    log to console    Tune scell PA to trigger UE A2 measurement report
    #please adjust pcell signal to not reach to A1 scell addition threshold before execute this step.

    ${ru_idx_list}    Get RU index list by cell ID    cell_idx_list=${cell_list}
    Set attenuator ports of specified RUs to same value    exp_pa_value=${scell_exp_pa_value}    ru_idx_list=${ru_idx_list}
    sleep    5s    msg=Wait for UE send A2 measurement report.
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure     Verify measurement report for multiple cells in F1AP log
    ...    log_path_pcap=${ute_log_path}   cell_id=${cell_list}

    ${scell_id_list}    string2list    ${cell_list}
    ${scell_number}    get length    ${scell_id_list}
    ${scell_index_list}    set variable
    FOR    ${scell_index}    IN RANGE    ${scell_number}
        ${scell_index}    evaluate    ${scell_index}+1
        ${scell_index_list}    run keyword if    ${scell_index}==${1}    set variable    ${scell_index}
        ...    ELSE     catenate    ${scell_index_list}    ,    ${scell_index}
    END

    ${scell_index_list}   set variable if    ${scell_index_list_check}==${None}       ${scell_index_list}
    ...     ${scell_index_list_check}

    run keyword and continue on failure    Verify Scell Released from F1AP log    log_path_pcap=${ute_log_path}    scell_index=${scell_index_list}
    [Teardown]    run keyword and ignore error    Run keywords    Stop Tcpdump via collector
    ...       tcpdump_collector_name=${tcpdump_log_name}    AND
    ...       Teardown the Aasyslog save progress
