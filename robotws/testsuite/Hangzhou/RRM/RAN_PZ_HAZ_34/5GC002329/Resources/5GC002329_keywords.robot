*** Settings ***
Resource     5GC002329_variables.robot
Variables    commissionings/HGZ/${testline_name}/__init_2329__.py
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/PCell_selection_and_DistName.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_variables.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot


Documentation
...   This is for T+F CA feature 5GC002329 keywords.
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1

*** Variables ***
${BIP_CAP_ON_BB_SLOT_1}    ${True}
${BIP_CAP_ON_BB_SLOT_2}    ${False}


*** Keywords ***
Import NIDD variables for 2329
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    connect to gnb coam via ssl
    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_rest_api_2329.py

    log    set variable indicating whether capture bip log on slot as suite variable
    ${abil_idx_of_pcell}    set variable    ${PCELL_LIST[${CA_GROUP_INDEX}]['abil_idx']}
    ${BIP_CAP_ON_BB_SLOT_1}    set variable if    '${abil_idx_of_pcell}'=='1'    true     false
    ${BIP_CAP_ON_BB_SLOT_2}    set variable if    '${abil_idx_of_pcell}'=='2'    true     false
    set suite variable    ${BIP_CAP_ON_BB_SLOT_1}
    set suite variable    ${BIP_CAP_ON_BB_SLOT_2}

2329 Suite preparation
    [Arguments]    ${NSA_SA}=${NSA_SA}    ${enb_default_scf_file}=${None}
    ...    ${is_pdl_checking_needed}=${False}
    Import NIDD variables for 2329
    set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_DEFAULT}
    set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_DEFAULT}
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT_20M_100M_1116_0}
    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
    ...     is_pdl_checking_needed=${is_pdl_checking_needed}

Mobility suite preparation
    Import NIDD variables for 2329
    import variables        ${CURDIR}/../TestData/mobility_nidd_modify_scf.py
    COAM Create log directory    is_set_to_test_case_level=${False}

    log to console    Start to commission adjacent gNB...
    ${adj_gnb_scf_template_processed}    scfpro.SCFProcess    scf_template_path=${ADJ_SCF_DEFAULT_FILE_PATH}    scf_process_folder=${SUITE_LOG_PATH}
    ...    list_para_to_modify=${SCF_TGT_GNB_MODIFY_DEFAULT_MOBILITY}
    Preparation with swconfig modification and comissioning
    ...    swconfig_modify=${None}    swconfig_template_path=${ADJ_SWCONFIG_DEFAULT_FILE_PATH}
    ...    scf_modify=${PARAMS_TO_MODIFY_SCF}    scf_template_path=${adj_gnb_scf_template_processed}
    ...    gnb_index=${1}    connection=${ADJ_GNB_OAM_ALIAS}    alias=${ADJ_GNB_ASIK_ALIAS}

    Enable cplane debug log on gNB
    set suite variable    ${PARAMS_TO_ADD}       ${SCF_ADD_MO_DEFAULT_MOBILITY}
    set suite variable    ${PARAMS_TO_MODIFY}    ${SCF_MODIFY_DEFAULT_MOBILITY}
    set suite variable    ${PARAMS_TO_DELETE}    ${SCF_DELETE_DEFAULT_MOBILITY}

    CA Suite preparation

    Connect to gnb coam via ssl    gnb_index=${1}    connection=${ADJ_GNB_OAM_ALIAS}
    &{ADJ_GNB_NR_CELL_ID_MAPPING}  coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids  connection_alias=${ADJ_GNB_OAM_ALIAS}
    Set suite variable    ${ADJ_GNB_NR_CELL_ID_MAPPING}
    Wait until cluster ready based on NSA_SA type
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=2    gnb_index=${1}
    ...    connection=${ADJ_GNB_OAM_ALIAS}    timeout=${TIMER_FOR_MODIFY_VIA_API}

    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${ADJ_GNB_OAM_ALIAS}

Mobility case teardown
    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F_T}
    Common case teardown    detach_ue=${True}
    Collect logs in teardown    is_btslog_required=${False}    gnb_index=${1}    connection=${ADJ_GNB_OAM_ALIAS}

    Kill tcpdump on asik slave or asib master    gnb_index=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}    asik_slave_alias=${ADJ_GNB_ASIK_ALIAS}_SLAVE
    COAM Teardown gnb connections    connection=${ADJ_GNB_OAM_ALIAS}
    ssh.disconnect    connection=${ADJ_GNB_ASIK_ALIAS}
    ssh.reset_cache

CA_L3_call_tput_DL_UL_Bi
    [Documentation]     Author: Wu Rong
    ...    This keyword check tput with Ul/DL and Bi
    ...    1. Check CA in f1ap log
    ...    2. Start traffic and check TPUT of pcell and scell in DL, stop traffic in DL
    ...    3. Start traffic and check TPUT of pcell and scell in UL
    ...    4. Start traffic in DL, Check TPUT of pcell and scell in Bi
    ...    There is only one attach for three times tput
    [Arguments]    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${duration}=3000s    ${protocol}=udp    ${NSA_SA}=${NSA_SA}
    ...    ${cell_index}=${PCELL_ID},${SCELL_ID}     ${exp_ul_indiv}=${PCELL_EXP_UL},-1
    ...    ${exp_dl_indiv}=${PCELL_EXP_DL},${SCELL_EXP_DL}    ${tput_duration}=${DURATION_OF_TPUT_CHECK}
    ...    ${check_scell_activation}=${False}    ${ENB_Cellid}=${4}

    #Check CA and Ul tput
    UE attach to Pcell and verify CA    NSA_SA=${NSA_SA}    ENB_Cellid=${ENB_Cellid}
    run keyword if    ${check_scell_activation}    Prepare and start aasyslog
    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}    protocol=${protocol}
    ...    duration=${duration}   data_transfer_direction=ul
    run keyword if   ${check_scell_activation}    Run keyword and continue on failure
    ...    Stop aasyslog to check scell activation
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=1min    filter=L2Lo
    run keyword and continue on failure    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}
    ...    direction=ul    cell_index=${cell_index}    exp_dl=0
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...    customized_log_name=CA_tput_ul_1    bip_log_name=CA_tput_ul_1

    run keyword and continue on failure     Stop data transfer based on direction    data_transfer_direction=ul    protocol=${protocol}

    #Check Dl tput
    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}    protocol=${protocol}
    ...    duration=${duration}    data_transfer_direction=dl
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}   ignore_time=1min    filter=L2Lo
    run keyword and continue on failure     Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}
    ...    direction=dl    cell_index=${cell_index}    exp_ul=0
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...    customized_log_name=CA_tput_dl_2    bip_log_name=CA_tput_dl_2

    #Check Bi tput
    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}    protocol=${protocol}
    ...    data_transfer_direction=ul    duration=${duration}
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=1min    filter=L2Lo
    ${Bi_tput_result}    Run keyword and return status    Check tput with UL rank1 issue ignored for T+F TDD cell
    ...    tput_log_path=${tput_log}    direction=both    cell_index=${cell_index}
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...    customized_log_name=CA_tput_Bi_3    bip_log_name=CA_tput_Bi_3

    ##TCP tput failed, then try to do UDP traffic for Bi
    run keyword if    '${Bi_tput_result}'=='${False}' and '${protocol}'=='tcp'
    ...    Run keywords    Run keyword and continue on failure    Stop data transfer based on direction
    ...    data_transfer_direction=both    protocol=tcp    AND
    ...    Verify UDP traffic for Bi    dl_tput=${dl_tput}     ul_tput=${ul_tput}    duration=${duration}
    ...    cell_index=${cell_index}    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...    bip_log_name=CA_tput_Bi_4    customized_log_name=CA_tput_Bi_4

    [Teardown]  Run keyword and ignore error    Stop data transfer and detach UE
    ...    data_transfer_direction=both    ue_index=${ue_index}

Verify UDP traffic for Bi
    [Documentation]     Author: Wu Rong
    ...    This keyword is WA for TCP tput fail.
    [Arguments]    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${duration}=3000s    ${cell_index}=${PCELL_ID},${SCELL_ID}     ${exp_ul_indiv}=${PCELL_EXP_UL},-1
    ...    ${exp_dl_indiv}=${PCELL_EXP_DL},${SCELL_EXP_DL}    ${customized_log_name}=${None}
    ...    ${tput_duration}=300s    ${bip_log_name}=tput_validation_failed

    Start data transfer based on direction    dl_tput=${dl_tput}    duration=${duration}
    ...        ul_tput=${ul_tput}    protocol=udp    data_transfer_direction=both
    ${tput_log}    power_ue.Collect Tput    duration=${tput_duration}    ue_type=${UE_TYPE}   ignore_time=1min    filter=L2Lo
    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}
    ...    cell_index=${cell_index}    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    direction=both
    ...    customized_log_name=${customized_log_name}    bip_log_name=${bip_log_name}

Verify UL rank in bip log
    [Documentation]    Author: Cui Lingxue
    ...    By checking srsReceiveRespPs message in bip, verify used UL rank is as expected.
    [Arguments]    ${bip_log_path}    ${expect_ul_rank}=1
    log to console    Validate UL rank in bip log.
    pcap.setup    infile=${bip_log_path}    display_filter=uldata_srsreceiverespps
    ${ul_rank}    pcap.get_field_value_by_name    field_name=UlData_srsReceiveRespPsUes_t.ulRank    attribute_name=show
    ${ul_rank}    remove_duplicates    ${ul_rank}
    ${len_ul_rank}    evaluate    len(${ul_rank})
    run keyword and continue on failure    should be true    ${len_ul_rank}==${1}
    should be true    '${ul_rank[${0}]}'=='${expect_ul_rank}'    msg=UL RANK ${ul_rank[${0}]} does not match with expected rank ${expect_ul_rank}.

Check tput with UL rank1 issue ignored for T+F TDD cell
    [Documentation]     Author: Ding Binmei
    ...    For T+F: Since QCOM UE limitation, there will UL rank1 issue in CA sometimes. So add WA
    ...    Current solution is: when tput check failed for UL, will double confirm if ul tput is in range 60-76. If yes, will confirm the
    ...    rank info. If it's rank1, then pass the keyword. If no, will fail the keyword. This WA is valid only for T+F TDD cell
    ...   :param tput_log_path: log path of aasyslog throughput file.
    ...                Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...   :param direction: supported values are: both, ul, dl
    ...   :param cell_index: global cell id, can be 1 or 1,2
    ...   :param exp_ul/exp_dl: expected tput of UL/DL for all cells
    ...   :param exp_ul_indiv/exp_dl_indiv: only valid when actCarrierAggregation is set to ${True}.
    ...        If not to check for individual cells, then remain it as ${None}
    ...        If check, then input tput should be set for each cell. like: 90,100
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput
    ...        0: Means tput should < 2M
    ...       Negative value: Means tput should < exp_value
    ...       Positive value: Means tput should >= exp_value
    ...   :param ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...   :param connection: SSL connection alias, pls create the connection before use the keyword
    ...   :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                              Check_result > target_throughput * target_avg_percent
    ...   :param customized_log_name: For generated tput image file name
    ...   :param local_log_dir: log folder for store the captured bip log

    [Arguments]    ${tput_log_path}    ${direction}    ${cell_index}=${PCELL_ID},${SCELL_ID}     ${exp_ul}=1    ${exp_dl}=1
    ...    ${ue_type}=${UE_TYPE}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${exp_ul_indiv}=${PCELL_EXP_UL},-1    ${exp_dl_indiv}=${PCELL_EXP_DL},${SCELL_EXP_DL}    ${connection}=GNB_OAM
    ...    ${customized_log_name}=${None}    ${bip_log_name}=tput_validation_failed
    ...    ${bip_capture_time}=10s

    ${list_cell_index}    string2list    ${cell_index}
    ${bip_log_path}    Check tput via power UE optimized     cell_index=${cell_index}     tput_log_path=${tput_log_path}    direction=${direction}
    ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}    ue_type=${ue_type}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    connection=${connection}
    ...    customized_log_name=${customized_log_name}    is_need_to_fail_keyword=${False}
    ...    is_analysis_log_captured=${True}    bip_log_name=${bip_log_name}
    ...    bip_capture_time=${bip_capture_time}
    ${len_bip_log_path}    Get length    ${bip_log_path}
    ${initial_result}    Set variable if    ${len_bip_log_path}==0    Pass    Fail
    Run keyword if    '${initial_result}'=='Pass' or '${CA_GROUP_TYPE}'=='F+T' or '${direction}'=='dl'
    ...    Run keywords    Should be True    '${initial_result}'=='Pass'
    ...        msg=Tput check failed, as initial_result is failed and CA_GROUP_TYPE is F+T or direction is dl, so skip the UL rank1 validation WA
    ...    AND    Return from keyword    ${-1}

    ${dl_tput_result}    Run keyword if    '${direction}'=='both'
    ...    Run keyword and return status    Check tput via power UE optimized     cell_index=${cell_index}     tput_log_path=${tput_log_path}
    ...        direction=dl    exp_dl=${exp_dl}    ue_type=${ue_type}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...        exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    connection=${connection}
    ...        customized_log_name=${customized_log_name}    is_need_to_fail_keyword=${True}    is_analysis_log_captured=${False}
    ...    ELSE    Set variable    ${None}
    Run keyword if    '${direction}'=='both' and ${dl_tput_result}==${False}    Fail
    ...    msg=DL tput not reach to the expected value when direction is both

    Log    Pass keyword if UL tput is in range of 60 - 76 and UL rank is rank 1
    ${tdd_cell_index}    Set variable if    '${CA_GROUP_TYPE}'=='F+T'    ${list_cell_index[1]}    ${list_cell_index[0]}
    ${list_tdd_cell_index}    Create list    ${tdd_cell_index}
    ${list_nrCellIdentity}    _Get nrCellIdentity based on cell index    list_cell_index=${list_tdd_cell_index}    connection=${connection}
    ${TDD_nrCellIdentity}    Create list    ${list_nrCellIdentity[0]}
    ${tdd_cell_ul_tput_summary}    ${tdd_cell_ul_tput_detail}    get_aasyslog_throughput    direction=ul    log=${tput_log_path}
    ...    cells=${TDD_nrCellIdentity}    actCarrierAggregation=${False}
    ${tdd_cell_ul_average_tput}    Set variable if    '${direction}'!='dl'    ${tdd_cell_ul_tput_summary[0]['average']}    ${None}
    # Todo: temporary adjust range to 60 - 76, yixiang:change range from 60-76 to 60-80, because of rank1 can reach 79M for X70 UE
    ${ul_tput_result}    Run keyword and return status    Should be true    ${tdd_cell_ul_average_tput}>=60 and ${tdd_cell_ul_average_tput}<=80
    ${ul_rank1_result}    Run keyword if    '${initial_result}'=='Fail' and ${ul_tput_result}==${True}
    ...    Run keyword and return status    Verify UL rank in bip log     bip_log_path=${bip_log_path[0]}
    ...    ELSE    Set variable    ${False}
    Should be True    ${ul_rank1_result}    msg=UL tput validate failed with UL rank1 validation WA checked


CA L3 call tput check with UL rank1 issue ignored for T+F TDD cell
    [Documentation]     Author: Ding Binmei
    ...    L3 call check with T+F UL rank1 WA added.
    ...    Current solution is: when tput check failed for UL, will double confirm if ul tput is in range 60-76. If yes, will confirm the
    ...    rank info. If it's rank1, then pass the keyword. If no, will fail the keyword. This WA is valid only for T+F TDD cell
    ...   :param data_transfer_direction: supported values are: both, ul, dl
    ...   :param cell_index: global cell id, can be 1 or 1,2
    ...   :param dl_tput/ul_tput: tput for started traffic
    ...   :param exp_ul/exp_dl: expected tput of UL/DL for all cells
    ...   :param exp_ul_indiv/exp_dl_indiv: only valid when actCarrierAggregation is set to ${True}.
    ...        If not to check for individual cells, then remain it as ${None}
    ...        If check, then input tput should be set for each cell. like: 90,100
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput
    ...        0: Means tput should < 2M
    ...       Negative value: Means tput should < exp_value
    ...       Positive value: Means tput should >= exp_value
    ...   :param sleep_time: wait until tput stable
    ...   :param connection: SSL connection alias, pls create the connection before use the keyword
    ...   :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                              Check_result > target_throughput * target_avg_percent
    ...   :param customized_log_name: For generated tput image file name
    ...    check_scell_activation only valid while sCellActivationMethod=bufferBased
    [Arguments]     ${ue_index}=${0}   ${data_transfer_direction}=both     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${process_num}=${IPERF_PROCESS_NUM}    ${duration}=3000s    ${window}=16M     ${buffer_size}=1400B    ${protocol}=udp    ${seg_size}=1350
    ...    ${cell_index}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=1    ${exp_ul}=1
    ...    ${exp_ul_indiv}=${PCELL_EXP_UL},-1    ${exp_dl_indiv}=${PCELL_EXP_DL},${SCELL_EXP_DL}
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${check_counter}=${False}    ${scell_addition_method}=blind    ${check_scell_activation}=${False}
    ...    ${tcpdump_log_name}=basic_l3_call_CA    ${min_percent}=0.8
    ...    ${target_avg_percent}=0.95      ${NSA_SA}=${NSA_SA}
    ...    ${ENB_Cellid}=${4}    ${is_need_to_stop_traffic}=${False}    ${customized_log_name}=L3_call
    ...    ${connection}=GNB_OAM    ${bip_log_name}=tput_validation_failed
    ...    ${bip_capture_time}=10s
    UE attach to Pcell and verify CA    ue_index=${ue_index}    tcpdump_log_name=${tcpdump_log_name}
    ...    scell_addition_method=${scell_addition_method}    check_counter=${check_counter}    NSA_SA=${NSA_SA}   ENB_Cellid=${ENB_Cellid}
    run keyword if    ${check_scell_activation}    Prepare and start aasyslog
    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}    protocol=${protocol}    window=${window}
    ...    duration=${duration}    process_num=${process_num}   data_transfer_direction=${data_transfer_direction}
    ...    buffer_size=${buffer_size}    seg_size=${seg_size}
    run keyword if   ${check_scell_activation}    Run keyword and continue on failure
    ...    Stop aasyslog to check scell activation
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=${sleep_time}    filter=L2Lo
    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=${data_transfer_direction}
    ...    cell_index=${cell_index}    exp_ul=${exp_ul}    exp_dl=${exp_dl}    target_avg_percent=${target_avg_percent}
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    connection=${connection}
    ...    min_percent=${min_percent}    customized_log_name=${customized_log_name}    bip_log_name=${bip_log_name}
    ...    bip_capture_time=${bip_capture_time}
    [Teardown]  Run keyword and ignore error    run keyword if    '${is_need_to_stop_traffic}'=='${True}'
    ...    Stop data transfer and detach UE    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}
    [Return]  ${tput_log}

L3 call tput check without CA with UL rank1 issue ignored for T+F TDD cell
    [Documentation]  Author: Ding Binmei
    ...    L3 call check No CA with T+F UL rank1 WA added.
    ...    Current solution is: when tput check failed for UL, will double confirm if ul tput is in range 60-76. If yes, will confirm the
    ...    rank info. If it's rank1, then pass the keyword. If no, will fail the keyword. This WA is valid only for T+F TDD cell
    ...   :param data_transfer_direction: supported values are: both, ul, dl
    ...   :param cell_index: global cell id, can be 1 or 1,2
    ...   :param dl_tput/ul_tput: tput for started traffic
    ...   :param exp_ul/exp_dl: expected tput of UL/DL for all cells
    ...   :param exp_ul_indiv/exp_dl_indiv: only valid when actCarrierAggregation is set to ${True}.
    ...        If not to check for individual cells, then remain it as ${None}
    ...        If check, then input tput should be set for each cell. like: 90,100
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput
    ...        0: Means tput should < 2M
    ...       Negative value: Means tput should < exp_value
    ...       Positive value: Means tput should >= exp_value
    ...   :param sleep_time: wait until tput stable
    ...   :param connection: SSL connection alias, pls create the connection before use the keyword
    ...   :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                              Check_result > target_throughput * target_avg_percent
    ...   :param customized_log_name: For generated tput image file name
    [Arguments]     ${ue_index}=${0}   ${data_transfer_direction}=both     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${process_num}=${IPERF_PROCESS_NUM}    ${duration}=3000s    ${window}=16M     ${buffer_size}=1400B   ${protocol}=udp    ${seg_size}=1350
    ...    ${cell_index}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=1    ${exp_ul}=1
    ...    ${exp_ul_indiv}=${PCELL_EXP_UL},0    ${exp_dl_indiv}=${PCELL_EXP_DL},0
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${tcpdump_log_name}=basic_l3_call_non-CA    ${min_percent}=0.8
    ...    ${target_avg_percent}=0.95      ${NSA_SA}=${NSA_SA}
    ...    ${ENB_Cellid}=${4}    ${is_need_to_stop_traffic}=${False}    ${customized_log_name}=L3_call_no_ca
    ...    ${connection}=GNB_OAM    ${bip_log_name}=tput_validation_failed_no_ca
    ...    ${bip_capture_time}=10s
    UE attach to Pcell and verify NO CA    ue_index=${ue_index}    tcpdump_log_name=${tcpdump_log_name}
    ...   NSA_SA=${NSA_SA}    ENB_Cellid=${ENB_Cellid}
    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}    protocol=${protocol}    window=${window}
    ...    duration=${duration}    process_num=${process_num}   data_transfer_direction=${data_transfer_direction}
    ...    buffer_size=${buffer_size}    seg_size=${seg_size}
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=${sleep_time}    filter=L2Lo
    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=${data_transfer_direction}
    ...    cell_index=${cell_index}    exp_ul=${exp_ul}    exp_dl=${exp_dl}    target_avg_percent=${target_avg_percent}
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    connection=${connection}
    ...    min_percent=${min_percent}    customized_log_name=${customized_log_name}    bip_log_name=${bip_log_name}
    ...    bip_capture_time=${bip_capture_time}
    [Teardown]  Run keyword and ignore error    run keyword if    '${is_need_to_stop_traffic}'=='${True}'
    ...    Stop data transfer and detach UE    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}
