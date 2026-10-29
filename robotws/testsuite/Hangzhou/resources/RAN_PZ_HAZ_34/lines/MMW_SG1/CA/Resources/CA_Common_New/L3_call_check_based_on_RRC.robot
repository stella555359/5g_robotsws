*** Settings ***
Documentation    Author: Ding Binmei
...    L3 call check based on RRC message
Resource    ./Check_CA_via_tcpdump_log.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_gnb_classical.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/vran40/cloud_gnb.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot

*** Variables ***
&{EMPTY_DICT}


*** Keywords ***
__Keyword_for_filter
    Convert from cell pci to cell index
    Get expected info for traffic verification
    Generate ca info for traffic verification with no CA exist
    L3 call with traffic check via RRC message
    Verify tput based on RRC message
    L3 call without traffic checked

Convert from cell pci to cell index
    [Documentation]  Author: Ding Binmei
    ...    :param ${list_cell_pci}: should be in list format, or can be string like: 1,2,3
    ...    If cell_mapping has value, then use it directly, otherwise will re-get from GNB based on provided connection
    ...    Return the cell index value as a list based on cell pci. E.G: ['1', '2']
    [Arguments]    ${list_cell_pci}    ${connection}=GNB_OAM    ${cell_mapping}=${None}
    ${list_cell_pci}    string2list    input_str=${list_cell_pci}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${cell_mapping}    Run keyword if    ${cell_mapping}    Set variable    ${cell_mapping}
    ...    ELSE IF    ${has_cbts}    cloud_gnb.get_relation_mapping_between_cell_and_others    vdu_connection=${connection}
    ...    ELSE    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
   @{list_cell_index}    Create List
    FOR    ${cell_pci}    IN    @{list_cell_pci}
        ${cell_index}    _Get cell index from cell maping based on pci    pci=${cell_pci}    cell_mapping=${cell_mapping}
        Append to list    ${list_cell_index}    ${cell_index}
    END
    [Return]  ${list_cell_index}

_Get cell index from cell maping based on pci
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${pci}    ${cell_mapping}
    @{list_cell_index_all}    Get Dictionary Keys    ${cell_mapping}
    ${cell_index}    Set variable    ${None}
    FOR    ${cell_index}    IN    @{list_cell_index_all}
        ${pci_act}    Evaluate    str(${cell_mapping[${cell_index}]['physicalCellId']})
        Return From Keyword If    '${pci}'=='${pci_act}'    ${cell_index}
    END

Calculate expected tput value based on actual max MIMO layer
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${initial_max_MIMO_layers}    ${initial_tput}    ${actual_max_MIMO_layers}
    ${initial_max_MIMO_layers}    Evaluate    int(${initial_max_MIMO_layers})
    ${actual_max_MIMO_layers}    Evaluate    int(${actual_max_MIMO_layers})
    Return from keyword if    '${actual_max_MIMO_layers}'=='-1'    ${-1}
    Return from keyword if    '${actual_max_MIMO_layers}'=='0'    ${0}
    ${expected_tput}    run keyword if    '${initial_max_MIMO_layers}'=='${actual_max_MIMO_layers}'
    ...    Evaluate    round(float(${initial_tput}), 2)
    ...    ELSE    Evaluate    round(float(${initial_tput})/${initial_max_MIMO_layers}*${actual_max_MIMO_layers}, 2)
    [Return]    ${expected_tput}

Get expected info for traffic verification
    [Documentation]    Author: Ding Binmei
    ...    If maxMIMO_layers is -1, it means no layer info found for this cell. Skip the check tput for this cell
    ...    If maxMIMO_layers is 0, it means will check tput for this cell, but tput for this cell should < 2M
    ...    ${exp_cell_tput_mapping}: expected tput mapping for each cell
    ...        E.G: {'2': {'bandwidth': '20M', 'maxMIMO_layers_ul': '1', 'ul_tput': 78.9, 'maxMIMO_layers_dl': '2', 'dl_tput': 213}}
    ...    ${ca_info_from_rrc}: Output from keyword: Get CA info from rrc reconfiguration msg
    ...        E.G:{    'pcell_info': {'pcell_pci': '937', 'pcell_maxMIMO_layers_ul': '1', 'pcell_maxMIMO_layers_dl': '2'},
    ...                         'scell_addition_info': {'ul_ca_scell_pci': ['936'], 'dl_ca_scell_pci': ['938', '940', '936']}
    ...                         'scell_info': {'938': {'scell_maxMIMO_layers_ul': '-1', 'scell_maxMIMO_layers_dl': '2'},
    ...                                        '940': {'scell_maxMIMO_layers_ul': '-1', 'scell_maxMIMO_layers_dl': '4'},
    ...                                        '936': {'scell_maxMIMO_layers_ul': '1', 'scell_maxMIMO_layers_dl': '4'}
    ...                                        }
    ...             }
    ...    Return bellow dict info for traffic verification.E.G:
    ...        {'cell_index': [1, 3, 5, 2],
    ...          'ul_tput_total': 156.0,
    ...          'dl_tput_total': 2691.0,
    ...          'exp_ul_indiv': [77.1, -1, -1, 78.9],
    ...          'exp_dl_indiv': [1493.0, 106.0, 879.0, 213.0]}
    [Arguments]    ${exp_cell_tput_mapping}    ${ca_info_from_rrc}
    &{cell_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    @{scell_pci}    Get dictionary keys    ${ca_info_from_rrc['scell_info']}
    ${all_cell_pci}    Copy list    ${scell_pci}
    Append to list    ${all_cell_pci}    ${ca_info_from_rrc['pcell_info']['pcell_pci']}
    ${list_cell_index}    Convert from cell pci to cell index    list_cell_pci=${all_cell_pci}    cell_mapping=${cell_mapping}
    @{exp_ul_indiv}    Create List
    @{exp_dl_indiv}    Create List
    ${ul_ca_scell_pci}    Set variable    ${ca_info_from_rrc['scell_addition_info']['ul_ca_scell_pci']}
    ${dl_ca_scell_pci}    Set variable    ${ca_info_from_rrc['scell_addition_info']['dl_ca_scell_pci']}
    ${ul_tput_total}    Set variable    ${0}
    ${dl_tput_total}    Set variable    ${0}
    FOR    ${cell_index}    IN    @{list_cell_index}
        ${pci}    Evaluate    str(${cell_mapping[${cell_index}]['physicalCellId']})
        ${act_max_MIMO_layers_ul}    Run keyword if    '${pci}'=='${ca_info_from_rrc['pcell_info']['pcell_pci']}'
        ...    Set variable    ${ca_info_from_rrc['pcell_info']['pcell_maxMIMO_layers_ul']}
        ...    ELSE    Set variable    ${ca_info_from_rrc['scell_info']['${pci}']['scell_maxMIMO_layers_ul']}
        ${exp_ul_tput}    Calculate expected tput value based on actual max MIMO layer
        ...    initial_max_MIMO_layers=${exp_cell_tput_mapping[${cell_index}]['maxMIMO_layers_ul']}
        ...    initial_tput=${exp_cell_tput_mapping[${cell_index}]['ul_tput']}    actual_max_MIMO_layers=${act_max_MIMO_layers_ul}
        Append to list    ${exp_ul_indiv}    ${exp_ul_tput}
        ${act_max_MIMO_layers_dl}    Run keyword if    '${pci}'=='${ca_info_from_rrc['pcell_info']['pcell_pci']}'
        ...    Set variable    ${ca_info_from_rrc['pcell_info']['pcell_maxMIMO_layers_dl']}
        ...    ELSE    set variable    ${ca_info_from_rrc['scell_info']['${pci}']['scell_maxMIMO_layers_dl']}
        ${exp_dl_tput}    Calculate expected tput value based on actual max MIMO layer
        ...    initial_max_MIMO_layers=${exp_cell_tput_mapping[${cell_index}]['maxMIMO_layers_dl']}
        ...    initial_tput=${exp_cell_tput_mapping[${cell_index}]['dl_tput']}      actual_max_MIMO_layers=${act_max_MIMO_layers_dl}
        Append to list    ${exp_dl_indiv}    ${exp_dl_tput}
        ${ul_tput_total}    Run keyword if    '${exp_ul_tput}'!='-1'    Evaluate    ${ul_tput_total}+${exp_ul_tput}
        ...    ELSE    Set variable    ${ul_tput_total}
        ${dl_tput_total}    Run keyword if    '${exp_dl_tput}'!='-1'    Evaluate    ${dl_tput_total}+${exp_dl_tput}
        ...    ELSE    Set variable    ${dl_tput_total}
    END
    &{exp_tput_info}    Create Dictionary    cell_index=${list_cell_index}    ul_tput_total=${ul_tput_total}    dl_tput_total=${dl_tput_total}
    ...   exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    [Return]    ${exp_tput_info}

Verify tput based on RRC message
    [Documentation]    Author: Ding Binmei
    ...    ${exp_cell_tput_mapping}: expected tput mapping for each cell
    ...        E.G: {'2': {'bandwidth': '20M', 'maxMIMO_layers_ul': '1', 'ul_tput': 78.9, 'maxMIMO_layers_dl': '2', 'dl_tput': 213}}
    ...    ${f1ap_log_file_path}: f1ap log file path. Should contain the log for ue attach and scell addition if exists
    ...    ${ca_info_rrc}: CA info from rrc reconfiguration msg. If not provided, will get from f1ap log
    [Arguments]    ${exp_cell_tput_mapping}    ${tput_log_path}    ${f1ap_log_file_path}=${None}    ${ca_info_rrc}=${EMPTY_DICT}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${customized_log_name}=L3_call_with_CA    ${data_transfer_direction}=both
    ...    ${is_analysis_log_captured}=${False}    ${bip_log_name}=tput_validation_failed    ${bip_capture_time}=10s    ${connection}=GNB_OAM
    ${ca_info_rrc}    Run keyword if    ${ca_info_rrc}    Set variable    ${ca_info_rrc}
    ...    ELSE    Get CA info from rrc reconfiguration msg    log_file_path=${f1ap_log_file_path}
    ${exp_tput_info}    Get expected info for traffic verification  exp_cell_tput_mapping=${exp_cell_tput_mapping}  ca_info_from_rrc=${ca_info_rrc}
    Check tput via power UE optimized    cell_index=${exp_tput_info['cell_index']}     tput_log_path=${tput_log_path}
    ...    direction=${data_transfer_direction}    exp_ul=${exp_tput_info['ul_tput_total']}    exp_dl=${exp_tput_info['dl_tput_total']}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    exp_ul_indiv=${exp_tput_info['exp_ul_indiv']}
    ...    exp_dl_indiv=${exp_tput_info['exp_dl_indiv']}    connection=${connection}    customized_log_name=${customized_log_name}
    ...    is_need_to_fail_keyword=${True}    is_analysis_log_captured=${is_analysis_log_captured}    bip_log_name=${bip_log_name}
    ...    bip_capture_time=${bip_capture_time}

L3 call with traffic check via RRC message
    [Documentation]  Author: Ding Binmei
    ...    ${exp_cell_tput_mapping}: expected tput mapping for each cell
    ...        E.G: {'2': {'bandwidth': '20M', 'maxMIMO_layers_ul': '1', 'ul_tput': 78.9, 'maxMIMO_layers_dl': '2', 'dl_tput': 213}}
    ...    ${pcell_id}: cell id for ue attach
    ...    ${tcpdump_log_name}: Refer to the f1ap log captured during ue attach phase, if CA exists, need to include scell addition phase
    ...    ${NSA_SA}: SA, NSA. Can define this as a global variable in feature
    ...    ${connection}: Refer to the SSL connection alias for GNB.
    ...    ${data_transfer_direction}: ul, dl, both
    ...    ${dl_tput_iperf}/${dl_tput_iperf}: ul/dl tput started on iperf. e.g: 1800M
    ...    ${protocol}: udp, tcp
    ...    ${iperf_duration}: duration for iperf process startup.   e.g: 3000s
    ...    ${tput_duration}: duration for check tput
    ...    ${check_tput_ignore_time}: ignore time for check tput to wait for tput stable
    ...    ${UE_TYPE}: Suite varaible defined in suite setup. Get from : ue.translate_power_ue_type_from_testline
    ...    ${customized_log_name}: For generated tput image file name
    ...    ${is_analysis_log_captured}: ${True} / ${False}
    [Arguments]    ${exp_cell_tput_mapping}    ${pcell_id}
    ...    ${ue_index}=${0}   ${NSA_SA}=SA    ${connection}=GNB_OAM    ${gnb_index}=${0}
    ...    ${data_transfer_direction}=both    ${dl_tput_iperf}=${DL_TPUT_IPERF}    ${ul_tput_iperf}=${UL_TPUT_IPERF}
    ...    ${protocol}=udp    ${iperf_duration}=3000s    ${tput_duration}=60s
    ...    ${tcpdump_log_name}=basic_l3_call_${data_transfer_direction}
    ...    ${check_tput_ignore_time}=30s    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${customized_log_name}=L3_call_with_CA
    ...    ${is_analysis_log_captured}=${False}    ${bip_log_name}=tput_validation_failed    ${bip_capture_time}=10s
    ...    ${is_need_to_stop_traffic}=${True}
    ${f1ap_log_path_verify_scell_addition}    ${tput_log_path}    L3 call without traffic checked    ue_index=${ue_index}   NSA_SA=${NSA_SA}
    ...    connection=${connection}    gnb_index=${gnb_index}    ${data_transfer_direction}=both    ${dl_tput_iperf}=${DL_TPUT_IPERF}
    ...    ul_tput_iperf=${ul_tput_iperf}    protocol=${protocol}    iperf_duration=${iperf_duration}   tput_duration=${tput_duration}
    ...    tcpdump_log_name=${tcpdump_log_name}    check_tput_ignore_time=${check_tput_ignore_time}
    ...    is_need_to_stop_traffic=${is_need_to_stop_traffic}
    Run keyword and continue on failure   Verify ue is attached to the expected cell    log_path_f1ap_ute=${f1ap_log_path_verify_scell_addition}
    ...    cell_id_for_attach=${pcell_id}    connection_alias=${connection}
    Verify tput based on RRC message    exp_cell_tput_mapping=${exp_cell_tput_mapping}    f1ap_log_file_path=${f1ap_log_path_verify_scell_addition}
    ...    tput_log_path=${tput_log_path}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    customized_log_name=${customized_log_name}    data_transfer_direction=${data_transfer_direction}
    ...    is_analysis_log_captured=${is_analysis_log_captured}
    ...    bip_log_name=${bip_log_name}    bip_capture_time=${bip_capture_time}    connection=${connection}

L3 call without traffic checked
    [Documentation]  Author: Ding Binmei
    ...    ${tcpdump_log_name}: Refer to the f1ap log captured during ue attach phase, if CA exists, need to include scell addition phase
    ...    ${NSA_SA}: SA, NSA. Can define this as a global variable in feature
    ...    ${connection}: Refer to the SSL connection alias for GNB.
    ...    ${data_transfer_direction}: ul, dl, both
    ...    ${dl_tput_iperf}/${dl_tput_iperf}: ul/dl tput started on iperf. e.g: 1800M
    ...    ${protocol}: udp, tcp
    ...    ${iperf_duration}: duration for iperf process startup.   e.g: 3000s
    ...    ${tput_duration}: duration for check tput
    ...    ${check_tput_ignore_time}: ignore time for check tput to wait for tput stable
    ...    ${UE_TYPE}: Suite varaible defined in suite setup. Get from : ue.translate_power_ue_type_from_testline
    ...    Return with f1ap log path and tput log path
    [Arguments]    ${ue_index}=${0}   ${NSA_SA}=SA    ${connection}=GNB_OAM    ${gnb_index}=${0}
    ...    ${data_transfer_direction}=both    ${dl_tput_iperf}=${DL_TPUT_IPERF}    ${ul_tput_iperf}=${UL_TPUT_IPERF}
    ...    ${protocol}=udp    ${iperf_duration}=3000s    ${tput_duration}=60s
    ...    ${tcpdump_log_name}=basic_l3_call_${data_transfer_direction}
    ...    ${check_tput_ignore_time}=30s
    ...    ${is_need_to_stop_traffic}=${True}    ${is_need_to_prepare_ue}=${False}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${tcpdump_log_name}    Set variable    ${tcpdump_log_name}_${timestamp}
    Start capture F1AP log   gnb_id=${gnb_index}    tcpdump_collector_name=${tcpdump_log_name}
    ${4G_check}    Set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    run keyword and continue on failure    Retry commercial ue attach if failed     prepare_ue_needed=${is_need_to_prepare_ue}
    ...    4G_check=${4G_check}    ue_index=${ue_index}    connection=${connection}
    Start data transfer based on direction    dl_tput=${dl_tput_iperf}     ul_tput=${ul_tput_iperf}    protocol=${protocol}
    ...    duration=${iperf_duration}    data_transfer_direction=${data_transfer_direction}
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=${check_tput_ignore_time}
    ...    filter=L2Lo
    ${f1ap_log_path_verify_scell_addition}    logs.Stop capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    [Return]    ${f1ap_log_path_verify_scell_addition}    ${tput_log_path}
    [Teardown]  Run keyword and ignore error    Run keywords    run keyword if    '${is_need_to_stop_traffic}'=='${True}'
    ...    Stop data transfer and detach UE    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}    AND
    ...    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}

Generate ca info for traffic verification with no CA exist
    [Documentation]    Author: Ding Binmei
    ...    Generate ca_info_no_ca based on the input from ca_info_from_rrc which is get from RRC reconfiguration message when CA exist.
    ...    For ca_info_no_ca: pcell layer info will be replaced by the layer info from exp_cell_tput_mapping,
    ...        Since layer info is different between CA and no CA. So make sure layer info in exp_cell_tput_mapping stands for no CA
    ...    If maxMIMO_layers is -1, it means no layer info found for this cell. Skip the check tput for this cell
    ...    If maxMIMO_layers is 0, it means will check tput for this cell, but tput for this cell should < 2M
    ...    ${exp_cell_tput_mapping}: expected tput mapping for each cell
    ...        E.G: {'2': {'bandwidth': '20M', 'maxMIMO_layers_ul': '1', 'ul_tput': 78.9, 'maxMIMO_layers_dl': '2', 'dl_tput': 213}}
    ...    ${ca_info_from_rrc}: Output from keyword: Get CA info from rrc reconfiguration msg
    ...        E.G:{    'pcell_info': {'pcell_pci': '937', 'pcell_maxMIMO_layers_ul': '1', 'pcell_maxMIMO_layers_dl': '2'},
    ...                         'scell_addition_info': {'ul_ca_scell_pci': ['936'], 'dl_ca_scell_pci': ['938', '940', '936']}
    ...                         'scell_info': {'938': {'scell_maxMIMO_layers_ul': '-1', 'scell_maxMIMO_layers_dl': '2'},
    ...                                        '940': {'scell_maxMIMO_layers_ul': '-1', 'scell_maxMIMO_layers_dl': '4'},
    ...                                        '936': {'scell_maxMIMO_layers_ul': '1', 'scell_maxMIMO_layers_dl': '4'}
    ...                                        }
    ...             }
    ...    Return bellow dict info for traffic verification.E.G:
    ...        E.G:{    'pcell_info': {'pcell_pci': '937', 'pcell_maxMIMO_layers_ul': '1', 'pcell_maxMIMO_layers_dl': '2'},
    ...                         'scell_addition_info': {'ul_ca_scell_pci': ['936'], 'dl_ca_scell_pci': ['938', '940', '936']}
    ...                         'scell_info': {'938': {'scell_maxMIMO_layers_ul': '-1', 'scell_maxMIMO_layers_dl': '0'},
    ...                                        '940': {'scell_maxMIMO_layers_ul': '-1', 'scell_maxMIMO_layers_dl': '0'},
    ...                                        '936': {'scell_maxMIMO_layers_ul': '0', 'scell_maxMIMO_layers_dl': '0'}
    ...                                        }
    ...             }
    [Arguments]    ${exp_cell_tput_mapping}    ${ca_info_from_rrc}
    ${ca_info_no_ca}    Copy Dictionary    ${ca_info_from_rrc}    deepcopy=${True}
    ${cell_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ${cell_index_pcell_list}    Convert from cell pci to cell index    list_cell_pci=${ca_info_from_rrc['pcell_info']['pcell_pci']}
    ...    cell_mapping=${cell_mapping}
    ${cell_index_pcell}    Set variable    ${cell_index_pcell_list[0]}
    Set To Dictionary    ${ca_info_no_ca['pcell_info']}
    ...    pcell_maxMIMO_layers_ul=${exp_cell_tput_mapping[${cell_index_pcell}]['maxMIMO_layers_ul']}
    Set To Dictionary    ${ca_info_no_ca['pcell_info']}
    ...    pcell_maxMIMO_layers_dl=${exp_cell_tput_mapping[${cell_index_pcell}]['maxMIMO_layers_dl']}
    FOR    ${scell_pci}    IN    @{ca_info_no_ca['scell_addition_info']['dl_ca_scell_pci']}
        ${scell_maxMIMO_layers_dl_no_ca}    Set variable    ${ca_info_no_ca['scell_info']['${scell_pci}']['scell_maxMIMO_layers_dl']}
        ${scell_maxMIMO_layers_dl_no_ca}    Set variable if    '${scell_maxMIMO_layers_dl_no_ca}'!='-1'    0    -1
        Set to dictionary    ${ca_info_no_ca['scell_info']['${scell_pci}']}    scell_maxMIMO_layers_dl=${scell_maxMIMO_layers_dl_no_ca}
        ${scell_maxMIMO_layers_ul_no_ca}    Set variable    ${ca_info_no_ca['scell_info']['${scell_pci}']['scell_maxMIMO_layers_ul']}
        ${scell_maxMIMO_layers_ul_no_ca}    Set variable if    '${scell_maxMIMO_layers_ul_no_ca}'!='-1'    0    -1
        Set to dictionary    ${ca_info_no_ca['scell_info']['${scell_pci}']}    scell_maxMIMO_layers_ul=${scell_maxMIMO_layers_ul_no_ca}
    END
    [Return]    ${ca_info_no_ca}
