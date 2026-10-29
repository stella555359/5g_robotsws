*** Settings ***
Documentation    CB009169 T+F ULCA common keywords
Resource     CB009169_variables.robot
Variables    commissionings/HGZ/${testline_name}/__init_9169__.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/Check_CA_via_tcpdump_log.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/ca_specifical_step.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/Parameters_modify_lib.py    WITH NAME    param_modify_lib
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/online_nidd_process.py    WITH NAME    nidd_modify

*** Variables ***
&{fault_4383}    faultId=${4383}    #alarm_ID 7101, Internal BTS processes autonomous reset as recovery action
&{fault_61524}    faultId=${61524}    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
&{fault_61074}    faultId=${61074}    #CRL Update Failure
&{fault_4654}    faultId=${4654}    source=SMOD_R-1     #Ethernet port security is disabled
&{fault_4655}    faultId=${4655}    #Service account root access is enabled
&{fault_61649}    faultId=${61649}    source=SMOD       #LMP access via port 443
@{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}     &{fault_4654}    &{fault_4655}    &{fault_61649}    &{fault_61074}

*** Keywords ***
Import NIDD variables for 9169
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    Connect to gnb coam via ssl
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids

    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_rest_api_9169.py
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

9169 Suite preparation
    [Documentation]  Author: Liu Zheng
    ...    exp_cc_num_in_use: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    ...    ToDo: ${ca_group_mapping} can be removed when all cases has removed this param
    [Arguments]    ${enb_default_scf_file}=${None}    ${cell_chbw_config}=4CC_T100M_F20M_F10M_T60M
    ...    ${swconfig_modify}=${None}    ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}
    ...    ${pa_values_mapping}=${INIT_PA_T1_F1_T3_F2}    ${ca_group_mapping_3cc}=${T1_F1_F2_3CC_CA_GROUP_COMMON}
    ...    ${ca_group_mapping_4cc}=${T1_F1_T3_F2_4CC_CA_GROUP_COMMON}    ${exp_cc_num_in_use}=${None}    ${frame_structure}=1070
    Decode CA group mapping and set global variable    is_called_in_suite_level=${True}
    ...    ca_group_mapping_3cc=${ca_group_mapping_3cc}    ca_group_mapping_4cc=${ca_group_mapping_4cc}    exp_cc_num_in_use=${exp_cc_num_in_use}


    Import NIDD variables for 9169
    run keyword if    '${cell_chbw_config}'!='${None}'    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_${cell_chbw_config}.py

    ${MODIFY_SCF_DEFAULT}    set variable if    '${frame_structure}' == '1070'    ${MODIFY_SCF_DEFAULT_1070}    ${MODIFY_SCF_DEFAULT_1116}
    ${ADD_SCF_DEFAULT}    set variable if    '${frame_structure}' == '1070'    ${ADD_SCF_SCELL_ADDITION_8311}     ${ADD_SCF_DEFAULT}

    Set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_DEFAULT}
    Set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_DEFAULT}
    Set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT}

    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
    ...    swconfig_modify=${swconfig_modify}
    ...    prepare_ue=${True}
    ...    scf_modify_parameters=${scf_modify_parameters}
    ...    pa_values_mapping=${pa_values_mapping}

    Prepare NRREL under specific cell    ca_group_mapping=${CA_GROUP_MAPPING}

Get CC num in use based on UE type from test line config file
    [Documentation]  Author: Ding Binmei
    ...    exp_cc_num_in_use: 3CC, 4CC, ${None}
    ...    if set as 3CC or 4CC will return the input value directly, otherwise will judge based on ue type.
    ...    sdx65: 3CC
    ...    sdx70: 4CC
    ...    return: 3CC / 4CC
    [Arguments]  ${exp_cc_num_in_use}=${None}
    @{supported_cc_num}    Create List    3CC    4CC
    ${act_cc_num_in_use}    Run keyword if    '${exp_cc_num_in_use}' in @{supported_cc_num}
    ...    Set variable    ${exp_cc_num_in_use}
    ...    ELSE IF    'sdx75' in @{tl.ues[0].capabilities}    Set variable    4CC
    ...    ELSE IF    'sdx70' in @{tl.ues[0].capabilities}    Set variable    4CC
    ...    ELSE IF    'sdx65' in @{tl.ues[0].capabilities}    Set variable    3CC
    ...    ELSE    Set variable    3CC
    [Return]  ${act_cc_num_in_use}

Decode CA group mapping and set global variable
    [Documentation]  Author: Ding Binmei
    ...    exp_cc_num_in_use: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    [Arguments]  ${exp_cc_num_in_use}=${None}    ${ca_group_mapping_3cc}=${None}
    ...    ${ca_group_mapping_4cc}=${None}    ${is_called_in_suite_level}=${False}
    ${CC_NUM}    Get CC num in use based on UE type from test line config file    exp_cc_num_in_use=${exp_cc_num_in_use}
    ${ca_group_mapping_in_use}    Set variable if    '${CC_NUM}'=='3CC'    ${ca_group_mapping_3cc}
    ...    ${ca_group_mapping_4cc}

    ${pcell_id_list}    create list    ${ca_group_mapping_in_use['pcell_id']}
    ${CELL_INDEX_LIST}    combine lists    ${pcell_id_list}    ${ca_group_mapping_in_use['verify_scell_add_dl']}

    run keyword if    ${is_called_in_suite_level}    Run keywords
    ...    Set suite variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping_in_use}    AND
    ...    Set suite variable    ${PCELL_ID}    ${ca_group_mapping_in_use['pcell_id']}    AND
    ...    Set suite variable    ${SCELL_ID_UL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_ul']}    AND
    ...    Set suite variable    ${SCELL_ID_DL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_dl']}    AND
    ...    Set suite variable    ${CELL_INDEX_LIST}    AND
    ...    Set suite variable    ${CC_NUM}
    ...    ELSE    Run keywords
    ...    Set test variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping_in_use}    AND
    ...    Set test variable    ${PCELL_ID}    ${ca_group_mapping_in_use['pcell_id']}    AND
    ...    Set test variable    ${SCELL_ID_UL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_ul']}    AND
    ...    Set test variable    ${SCELL_ID_DL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_dl']}    AND
    ...    Set test variable    ${CELL_INDEX_LIST}    AND
    ...    Set test variable    ${CC_NUM}

9169 Case setup
    [Documentation]    Author: liu Zheng
    ...    If ca relationship need to be modified, input by ${ca_group_mapping}, NRREL will be updated accordingly.
    ...    If other NIDD parameters need to be modified, input by ${dict_params_to_modify}.
    ...    ${exp_cc_num_in_use}: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    [Arguments]    ${dict_params_to_modify}=${None}    ${is_log_required}=${IS_LOG_CAPTURED_CASE_LEVEL}
    ...    ${ca_group_mapping_3cc}=${T1_F1_F2_3CC_CA_GROUP_COMMON}
    ...    ${ca_group_mapping_4cc}=${T1_F1_T3_F2_4CC_CA_GROUP_COMMON}    ${exp_cc_num_in_use}=${None}
    Common case setup    is_log_required=${is_log_required}    NSA_SA=${NSA_SA}
    Decode CA group mapping and set global variable    is_called_in_suite_level=${False}
    ...    ca_group_mapping_3cc=${ca_group_mapping_3cc}    ca_group_mapping_4cc=${ca_group_mapping_4cc}    exp_cc_num_in_use=${exp_cc_num_in_use}
    run keyword if    ${dict_params_to_modify}!=${None}    Modify NIDD by rest api and wait onair
    ...    parameters=${dict_params_to_modify}


Prepare NRREL under specific cell
    [Documentation]    Author: Liu Zheng
    ...    Generate and activate parameters for nrrel update based on ca_group_mapping.
    [Arguments]    ${ca_group_mapping}    ${timeout_restapi}=${TIMER_FOR_MODIFY_VIA_API}    ${connection}=GNB_OAM
    ...    ${prepare_nrrel}=T+F_4CC
    &{dict_nrrel_params}    run keyword if    '${prepare_nrrel}' == 'F+T_4CC'
    ...   param_modify_lib.get_nrrel_params_for_online_update_based_on_ca_group_mapping_config
    ...    ca_group_mapping=${ca_group_mapping}    program=${PROGRAM}
    ...    ELSE    param_modify_lib.get_nrrel_params_for_online_update_based_on_ca_group_mapping_no_increasePUSCHPrepTimeULCA
    ...    ca_group_mapping=${ca_group_mapping}    program=${PROGRAM}

    ${result}    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_nrrel_params}
    ...    skip_parameter_relation_errors=${False}    should_activate=${True}    connection=${connection}    timeout=${timeout_restapi}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
    [Return]    ${result}

ULCA_peak_tput_verification_with_8311_enabled
    [Documentation]    Author: Liu Zheng
    ...    This keyword is to verify UE can reach peak throughput for ul only direction, dl only direction and bi-direction.
    ...    The execution order will be:
    ...      1) attach and start UL traffic, due to CB008311 enabled in suite setup, when check throughput,
    ...         no UL CA, and pcell UL 2 layers.
    ...      2) Stop UL traffic
    ...      3) Start DL traffic and verify DL throughput
    ...      4) Start UL traffic and verify bi-direction throughput
    ...      5) Stop data transmission and detach UE.
    [Arguments]    ${cell_index}
    ...    ${exp_ul_indiv}=${EXP_UL_INDIV}    ${exp_dl_indiv}=${EXP_DL_INDIV}
    ...    ${exp_ul}=1    ${exp_dl}=1
    ...    ${connection}=GNB_OAM
    ...    ${dl_tput_iperf}=${DL_TPUT_IPERF}    ${ul_tput_iperf}=${UL_TPUT_IPERF}    ${protocol}=udp    ${iperf_duration}=3000s
    ...    ${tput_duration}=300s    ${check_tput_ignore_time}=1min    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85

    # UE attach, start UL traffic and verify
    log to console    step1: attach and start UL traffic, due to CB008311 enabled in suite setup, when check throughput,
    ...        there will be no UL CA, and pcell UL 2 layers. /n
    run keyword and continue on failure    Retry commercial ue attach if failed     prepare_ue_needed=${False}    4G_check=${False}

    # start UL traffic and verify
    Start data transfer based on direction    data_transfer_direction=ul    protocol=${protocol}
    ...    dl_tput=${dl_tput_iperf}    ul_tput=250M    duration=${iperf_duration}

    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}
    ...    ignore_time=${check_tput_ignore_time}    filter=L2Lo
    run keyword and ignore error    check iperf process on appserver
    run keyword and continue on failure     Check tput via power UE optimized     cell_index=${cell_index}    direction=ul
    ...    tput_log_path=${tput_log_path}    connection=${connection}
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070_ENABLE_8311_${MRBTS_ID}}    exp_ul_indiv=${EXP_UL_INDIV_1070_ENABLE_8311}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    customized_log_name=ULCA_tput_UL_only

    log to console    step2: stop UL traffic. /n
    run keyword and continue on failure     Stop data transfer based on direction    data_transfer_direction=ul    protocol=${protocol}

    #start bip
    run keyword and continue on failure     Collect Interface Mirroring Bip Collector    target_file_name=scell_data_debug
                                          ...    mirroring_filter=${None}
                                          ...    gnb_index=${0}
    # start DL traffic and verify
    log to console    step3: Start DL traffic and verify DL throughput. /n
    Start data transfer based on direction    data_transfer_direction=dl    protocol=${protocol}
    ...    dl_tput=${dl_tput_iperf}     ul_tput=${ul_tput_iperf}    duration=${iperf_duration}
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}
    ...    ignore_time=${check_tput_ignore_time}    filter=L2Lo
    ${bip_log}    Get Bip Log Via Interface Mirroring Collector    target_file_name=scell_data_debug
    run keyword and ignore error    check iperf process on appserver
    run keyword and continue on failure     Check tput via power UE optimized     cell_index=${cell_index}    direction=dl
    ...    tput_log_path=${tput_log_path}    connection=${connection}
    ...    exp_dl=${exp_dl}    exp_dl_indiv=${exp_dl_indiv}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    customized_log_name=ULCA_tput_DL_only

    # Start UL traffic and verify bi-direction traffic
    log to console    step4: Start UL traffic and verify bi-direction throughput. /n
    Start data transfer based on direction    data_transfer_direction=ul    protocol=${protocol}
    ...    dl_tput=${dl_tput_iperf}     ul_tput=${ul_tput_iperf}    duration=${iperf_duration}
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}
    ...    ignore_time=${check_tput_ignore_time}    filter=L2Lo
    run keyword and ignore error    check iperf process on appserver
    Check tput via power UE optimized     cell_index=${cell_index}    direction=both
    ...    tput_log_path=${tput_log_path}    connection=${connection}
    ...    exp_dl=${exp_dl}    exp_dl_indiv=${exp_dl_indiv}    exp_ul=${exp_ul}    exp_ul_indiv=${exp_ul_indiv}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    customized_log_name=ULCA_tput_Bi_diretion
    [Teardown]  Run keyword and ignore error    Stop data transfer and detach UE    data_transfer_direction=both

Verify throughput as expect
    [Documentation]  Author: Wang Yixiang
    ...   The keyword is for no peak case checking.
    ...   No peak paras:
    ...      ${TPUT_AVG_PERCENT_COMMON}=0.7     ${TPUT_MIN_PERCENT_COMMON}=0.5
    ...   Peak paras:
    ...      ${TPUT_AVG_PERCENT_COMMON}=0.95     ${TPUT_MIN_PERCENT_COMMON}=0.85
    ...   ${cell_index}: global cell id, can be 1 or 1,2
    ...   ${exp_ul}/${exp_dl}: expected tput of UL/DL, Can only be single value.
    ...   ${exp_ul_indiv}/${exp_dl_indiv}:
    ...        If not to check for individual cells, then remain it as ${None}
    ...        If check, then input tput should be set for each cell. like: 90,100
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput
    ...        0: Means tput should < 2M
    ...       Negative value: Means tput should < exp_value
    ...       Positive value: Means tput should >= exp_value
    ...    ${connection}: Refer to the SSL connection alias for GNB
    ...    ${data_transfer_direction}: ul, dl, both
    ...    ${UE_TYPE}: Suite varaible defined in suite setup. Get from : ue.translate_power_ue_type_from_testline
    ...    ${tput_duration}: duration for check tput
    ...    ${check_tput_ignore_time}: ignore time for check tput to wait for tput stable
    ...    ${customized_log_name}: For generated tput image file name
    [Arguments]    ${cell_index}    ${exp_ul_indiv}=${EXP_UL_INDIV}    ${exp_dl_indiv}=${EXP_DL_INDIV}
    ...    ${exp_ul}=1    ${exp_dl}=1    ${ue_index}=${0}   ${connection}=GNB_OAM
    ...    ${data_transfer_direction}=both    ${tput_duration}=60s    ${check_tput_ignore_time}=30s
    ...    ${target_avg_percent}=${TPUT_AVG_PERCENT_COMMON}
    ...    ${min_percent}=${TPUT_MIN_PERCENT_COMMON}    ${customized_log_name}=check_throughput
    ...    ${is_need_to_stop_traffic}=${False}    ${is_analysis_log_captured}=${False}
    ...    ${bip_log_name}=tput_validation_failed    ${bip_capture_time}=10s

    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}
    ...    ignore_time=${check_tput_ignore_time}    filter=L2Lo
    run keyword and ignore error    check iperf process on appserver
    Check tput via power UE optimized     cell_index=${cell_index}     tput_log_path=${tput_log_path}    direction=${data_transfer_direction}
    ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    connection=${connection}
    ...    customized_log_name=${customized_log_name}    is_need_to_fail_keyword=${True}
    ...    is_analysis_log_captured=${is_analysis_log_captured}    bip_log_name=${bip_log_name}    bip_capture_time=${bip_capture_time}
    [Teardown]  Run keyword and ignore error    run keyword if    '${is_need_to_stop_traffic}'=='${True}'
    ...    Stop data transfer and detach UE    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}


Recover L2RT
    [Arguments]    ${connection}=GNB_OAM
    ...    ${timeout}=60s    ${retry_interval}=60
    set test variable    ${waiting_interval}      200
    set test variable    ${FaultID}      4383
#    set test variable    ${AlarmID}      7101
    Trigger L2RT SW Reset
#    Run Keyword And Continue On Failure    Wait For Expect Fault Present   faultId=${fault_4383['faultId']}   timeout=300
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds   300 sec   5 sec      Expect Fault Should Present
    ...    faultId=4383    alarmId=7101

    Wait until keyword succeeds     1 min    5 sec    Expect Fault Should Absent
        ...    faultId=${fault_4383['faultId']}
    ${fault_6450}    Create Dictionary    faultId=${6450}
    append to list      ${ALLOWED_FAULT_LIST}    ${fault_6450}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT_LIST}

    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB ABIL status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB RU status    connection=${connection}


Trigger L2RT SW Reset
    Connect to Common Unit Master    alias=ASIK Master
    ${hw_slot}    set variable if    '${MRBTS_ID}' == '255'    ${3}    ${1}
    Connect to Capacity Unit Master    alias=ABIL Master    hw_slot=${hw_slot}
    run keyword if    '${MRBTS_ID}' == '255'
    ...    ssh.send command    command=pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe --startup=nid=0x1930'    connection=ABIL Master
    ...    ELSE    ssh.send command    command=pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe --startup=nid=0x1732'    connection=ABIL Master


Check tput and return each cells throughput
    [Documentation]    Author: Liu Zheng
    ...    use TPUT check keyword of power ue, and it will draw a tput picture
    ...    it will return the average throughput of each cell.
    ...    :param cell_index: global cell id, can be 1 or 1,2
    ...    :param tput_log_path: log path of aasyslog throughput file.
    ...                Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...    :param direction: only supported value is both
    ...    :param exp_ul/exp_dl: expected tput of UL/DL, Can only be single value.
    ...        If actCarrierAggregation=True, it's the expected UL tput for all cells
    ...        If actCarrierAggregation=False, then each cell should reach with this expected tput
    ...        due to need to return each cell throughput, need to set actCarrierAggregation=False
    ...    :param exp_ul_indiv/exp_dl_indiv:
    ...        If not to check for individual cells, then remain it as ${None}
    ...        If check, then input tput should be set for each cell. like: 90,100
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput
    ...        0: Means tput should < 2M
    ...       Negative value: Means tput should < exp_value
    ...       Positive value: Means tput should >= exp_value
    ...    :param ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...    :param connection: SSL connection alias, pls create the connection before use the keyword
    ...    :param cell_mapping: If cell_mapping has value, then use it directly, otherwise will re-get from GNB based on provided connection
    ...    :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                              Check_result > target_throughput * target_avg_percent
    ...    :param customized_log_name: For generated tput image file name
    ...    e.g:  Check tput and return each cells throughput
    ...    tput_log_path=${tput_log}    direction=both     exp_ul=1    exp_dl=1
    ...    exp_ul_indiv=10,10,0,0     exp_dl_indiv=1000,200,800,100
    ...    customized_log_name=step*_check_throughput
    [Arguments]     ${tput_log_path}    ${direction}=both    ${exp_ul}=-1    ${exp_dl}=-1
    ...    ${ue_type}=${UE_TYPE}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${exp_ul_indiv}=${None}    ${exp_dl_indiv}=${None}    ${connection}=GNB_OAM
    ...    ${customized_log_name}=${None}
    ...    ${cell_mapping}=${None}    ${ca_group_mapping}=${T1_F1_T2_F2_4CC_CA_GROUP_COMMON}

    ${direction}    Convert to lower case    ${direction}
    ${pcell_id_list}    create list    ${ca_group_mapping['pcell_id']}
    ${cell_index_ul}    combine lists    ${pcell_id_list}    ${ca_group_mapping['verify_scell_add_ul']}
    ${cell_index_dl}    combine lists    ${pcell_id_list}    ${ca_group_mapping['verify_scell_add_dl']}


    ${list_cell_index_ul}    string2list    ${cell_index_ul}
    ${list_cell_index_dl}    string2list    ${cell_index_dl}
    @{list_nrCellIdentity_ul}    _Get nrCellIdentity based on cell index    list_cell_index=${list_cell_index_ul}    connection=${connection}
    ...    cell_mapping=${cell_mapping}
#    @{list_nrCellIdentity_dl}    _Get nrCellIdentity based on cell index    list_cell_index=${list_cell_index_dl}    connection=${connection}
#    ...    cell_mapping=${cell_mapping}
    @{list_nrCellIdentity}    _Get nrCellIdentity based on cell index    list_cell_index=${list_cell_index_dl}

    ${exp_ul}    _Convert expected tput value for checking    exp_tput_value=${exp_ul}
    ${exp_dl}    _Convert expected tput value for checking    exp_tput_value=${exp_dl}

    ${list_exp_ul}    Run keyword if    ${exp_ul_indiv}    string2list    ${exp_ul_indiv}
    ...    ELSE    Set variable    ${None}
    ${list_exp_dl}    Run keyword if    ${exp_dl_indiv}    string2list    ${exp_dl_indiv}
    ...    ELSE    Set variable    ${None}

    &{dict_exp_indv_tput_ul}    Run keyword if    ${exp_ul_indiv}
    ...    _Get individual expected tput value for cells    list_nrCellIdentity=${list_nrCellIdentity}     list_exp_tput=${list_exp_ul}
    ...    ELSE    Set variable    ${None}
    &{dict_exp_indv_tput_dl}    Run keyword if    ${exp_dl_indiv}
    ...    _Get individual expected tput value for cells    list_nrCellIdentity=${list_nrCellIdentity}     list_exp_tput=${list_exp_dl}
    ...    ELSE    Set variable    ${None}

    &{dict_cell_indiv_tput_ul}    Create dictionary
    &{dict_cell_indiv_tput_dl}    Create dictionary
    &{dict_cell_indiv_tput}    Create dictionary

    FOR    ${nrcell_identity_i}    IN    @{list_nrCellIdentity_ul}
        ${nrcell_identity_i_list}    Create List     ${nrcell_identity_i}
        ${tput_result_ul}    Run keyword and continue on failure   power_ue.Check Tput    direction=ul    ue_type=${ue_type}   log=${tput_log_path}
        ...    cells=${nrcell_identity_i_list}    target_throughput=${dict_exp_indv_tput_ul['${nrcell_identity_i}']}
        ...    target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...    actCarrierAggregation=${false}    customized_log_name=${customized_log_name}
        Set to dictionary    ${dict_cell_indiv_tput_ul}    ${nrCellIdentity_i}=${tput_result_ul[0]['average']}
    END

    FOR    ${nrcell_identity_j}    IN    @{list_nrCellIdentity}
        ${nrcell_identity_j_list}    Create List     ${nrcell_identity_j}
        ${tput_result_dl}    Run keyword and continue on failure   power_ue.Check Tput    direction=dl    ue_type=${ue_type}   log=${tput_log_path}
        ...    cells=${nrcell_identity_j_list}    target_throughput=${dict_exp_indv_tput_dl['${nrcell_identity_j}']}
        ...    target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...    actCarrierAggregation=${false}    customized_log_name=${customized_log_name}
        Set to dictionary    ${dict_cell_indiv_tput_dl}    ${nrCellIdentity_j}=${tput_result_dl[0]['average']}
    END
    Set to dictionary    ${dict_cell_indiv_tput}    ul=${dict_cell_indiv_tput_ul}    dl=${dict_cell_indiv_tput_dl}
    [Return]  ${dict_cell_indiv_tput}


compare the throughputs of each cells throughput should no change
    [Arguments]    ${dict_cell_indiv_tput1}    ${dict_cell_indiv_tput2}    ${ca_group_mapping}=${T1_F1_T2_F2_4CC_CA_GROUP_COMMON}

    ${pcell_id_list}    create list    ${ca_group_mapping['pcell_id']}
    ${cell_index_ul}    combine lists    ${pcell_id_list}    ${ca_group_mapping['verify_scell_add_ul']}
    ${cell_index_dl}    combine lists    ${pcell_id_list}    ${ca_group_mapping['verify_scell_add_dl']}

    ${list_cell_index_ul}    string2list    ${cell_index_ul}
    ${list_cell_index_dl}    string2list    ${cell_index_dl}
    @{list_nrCellIdentity_ul}    _Get nrCellIdentity based on cell index    list_cell_index=${list_cell_index_ul}
    @{list_nrCellIdentity_dl}    _Get nrCellIdentity based on cell index    list_cell_index=${list_cell_index_dl}
    @{list_pcell_nrCellIdentity}    _Get nrCellIdentity based on cell index    list_cell_index=${pcell_id_list}
    ${pcell_nrCellIdentity}     set variable     ${list_pcell_nrCellIdentity}

#    :FOR    ${nrcell_identity_i}    IN    @{list_nrCellIdentity_ul}
#        ${ul_analysis}    catenate     ${dict_cell_indiv_tput1['ul']['${nrcell_identity_i}']}*0.98 <=
#        ...    ${dict_cell_indiv_tput2['ul']['${nrcell_identity_i}']} <= ${dict_cell_indiv_tput1['ul']['${nrcell_identity_i}']}*1.02
#        run keyword and continue on failure     should be true    ${ul_analysis}
#    END

    FOR    ${nrcell_identity_j}    IN    @{list_nrCellIdentity_dl}
        ${dl_analysis}    catenate     ${dict_cell_indiv_tput1['dl']['${nrcell_identity_j}']}*0.96 <=
        ...    ${dict_cell_indiv_tput2['dl']['${nrcell_identity_j}']} <= ${dict_cell_indiv_tput1['dl']['${nrcell_identity_j}']}*1.04
        run keyword and continue on failure     should be true    ${dl_analysis}
    END

throughput should be increased after due to EnhancedVoNR
    [Arguments]    ${dict_cell_indiv_tput1}    ${dict_cell_indiv_tput2}    ${ca_group_mapping}=${T1_F1_T2_F2_4CC_CA_GROUP_COMMON}
    ...    ${pcell_dl_increace}=60
    ${pcell_id_list}    create list    ${ca_group_mapping['pcell_id']}
    ${cell_index_ul}    combine lists    ${pcell_id_list}    ${ca_group_mapping['verify_scell_add_ul']}
    ${cell_index_dl}    combine lists    ${pcell_id_list}    ${ca_group_mapping['verify_scell_add_dl']}

    ${list_cell_index_ul}    string2list    ${cell_index_ul}
    ${list_cell_index_dl}    string2list    ${cell_index_dl}
    @{list_nrCellIdentity_ul}    _Get nrCellIdentity based on cell index    list_cell_index=${list_cell_index_ul}
    @{list_nrCellIdentity_dl}    _Get nrCellIdentity based on cell index    list_cell_index=${list_cell_index_dl}
    @{list_pcell_nrCellIdentity}    _Get nrCellIdentity based on cell index    list_cell_index=${pcell_id_list}
    ${pcell_nrCellIdentity}     set variable     ${list_pcell_nrCellIdentity[0]}

#    :FOR    ${nrcell_identity_i}    IN    @{list_nrCellIdentity_ul}
#        ${ul_analysis}    catenate     ${dict_cell_indiv_tput1['ul']['${nrcell_identity_i}']}*0.96 <=
#        ...    ${dict_cell_indiv_tput2['ul']['${nrcell_identity_i}']}
#        run keyword and continue on failure     should be true    ${ul_analysis}
#    END

    FOR    ${nrcell_identity_j}    IN    @{list_nrCellIdentity_dl}
        ${dl_analysis}    catenate    ${dict_cell_indiv_tput1['dl']['${nrcell_identity_j}']}*0.98 <=
        ...    ${dict_cell_indiv_tput2['dl']['${nrcell_identity_j}']} <= ${dict_cell_indiv_tput1['dl']['${nrcell_identity_j}']}*1.02
        run keyword if    '${nrcell_identity_j}' == '${pcell_nrCellIdentity}'
        ...    run keyword and continue on failure     should be true
        ...    ${dict_cell_indiv_tput2['dl']['${nrcell_identity_j}']} - ${dict_cell_indiv_tput1['dl']['${nrcell_identity_j}']} >= ${pcell_dl_increace}
        ...    ELSE
        ...    run keyword and continue on failure     should be true    ${dl_analysis}
    END
