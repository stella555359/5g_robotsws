*** Settings ***
Documentation    Suite description
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot

*** Variables ***
${EXP_DL_INDIV}    ${None}
${EXP_UL_INDIV}    ${None}


*** Keywords ***
UE attach and verify Scell addition in tcpdump log
    [Documentation]    Author: Ding Binmei
    ...    ${scell_index_ul}: scell index for UL CA. Example value: 1,2    ${None} means no ul CA.
    ...    ${scell_index_dl}: scell index for DL CA. Example value: 1,2    ${None} means no dl CA.
    ...    ${scell_addition_method}: blind, covBasedA1
    ...    ${actBufferBasedScellAddition}:  indicate whether to enbale 8311. values: disabled, oneShot_Dl_Fr1
    ...    ${connection}: For cloud, refers to cu connection:OAM_CU${gnb_index}; For classical: GNB_OAM
    [Arguments]    ${scell_index_ul}=${None}    ${scell_index_dl}=${None}    ${tcpdump_log_name}=basic_l3_call
    ...    ${scell_addition_method}=blind   ${ue_index}=${0}   ${NSA_SA}=${NSA_SA}    ${pcell_id}=${PCELL_ID}    ${connection}=GNB_OAM
    ...    ${gnb_index}=${0}    ${actBufferBasedScellAddition}=disabled
    ${4G_check}    Set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    run keyword if   '${NSA_SA}'=='NSA'       Start X2 log capture from eNB    log_name=nsa_x2_debug_${tcpdump_log_name}
    Start capture F1AP log   gnb_id=${gnb_index}    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp

    run keyword and continue on failure    Retry commercial ue attach if failed     prepare_ue_needed=${False}    4G_check=${4G_check}
    ...    ue_index=${ue_index}    connection=${connection}
    ${ute_log_path_f1ap}    logs.Stop capture F1AP log    gnb_id=${gnb_index}    tcpdump_collector_name=${tcpdump_log_name}

    run keyword if   '${NSA_SA}'=='NSA'      Stop X2 log capture from eNB    log_name=nsa_x2_debug_${tcpdump_log_name}

    Verify ue is attached to the expected cell    log_path_f1ap_ute=${ute_log_path_f1ap}
    ...    cell_id_for_attach=${pcell_id}    connection_alias=${connection}

    run keyword and continue on failure    run keyword if    '${scell_addition_method}'=='blind' and '${actBufferBasedScellAddition}'=='disabled'
    ...    Verify scell addition from f1ap log    log_file_path=${ute_log_path_f1ap}
    ...            scell_index_ul=${scell_index_ul}    scell_index_dl=${scell_index_dl}
    ...    ELSE IF   '${scell_addition_method}'=='covBasedA1'    run keywords
    ...            Verify no scell addition from f1ap log    log_path_pcap=${ute_log_path_f1ap}
    ...            AND     Verify A1 event configed in F1AP log    log_path_pcap=${ute_log_path_f1ap}
    ...    ELSE IF    '${actBufferBasedScellAddition}'=='oneShot_Dl_Fr1'    Verify no scell addition from f1ap log
    ...        log_path_pcap=${ute_log_path_f1ap}

    [Return]    ${ute_log_path_f1ap}
    [Teardown]    run keyword and ignore error    run keywords
    ...     logs.Teardown F1AP log capture    gnb_id=${gnb_index}    tcpdump_collector_name=${tcpdump_log_name}    AND
    ...     run keyword if   '${NSA_SA}'=='NSA'    Stop trace capturing    log_prefix=nsa_x2_debug_${tcpdump_log_name}    connection_alias=ENB

Cloud CA UE attach and check Scell addition in tcpdump log
    [Documentation]    Author: dandan fang
    ...    ${scell_index_ul}: scell index for UL CA. Example value: 1,2    ${None} means no ul CA.
    ...    ${scell_index_dl}: scell index for DL CA. Example value: 1,2    ${None} means no dl CA.
    ...    ${actBufferBasedScellAddition}:  indicate whether to enbale 8311. values: disabled, oneShot_Dl_Fr1
    [Arguments]
    ...    ${gnb_index}=${0}  ${cu_oam_connection}=OAM_CU${gnb_index}
    ...    ${pcell_id}=${PCELL_ID}
    ...    ${scell_index_ul}=${SCELL_ID_UL_ADD}    ${scell_index_dl}=${SCELL_ID_DL_ADD}
    ...    ${tcpdump_log_name}=cloud_ue_attach_with_ca
    ...    ${scell_addition_method}=blind    ${actBufferBasedScellAddition}=disabled
    ...    ${ue_index}=${0}   ${NSA_SA}=${NSA_SA}
    UE attach and verify Scell addition in tcpdump log
    ...   scell_index_ul=${scell_index_ul}    scell_index_dl=${scell_index_dl}     gnb_index=${gnb_index}  pcell_id=${pcell_id}
    ...   scell_addition_method=${scell_addition_method}    actBufferBasedScellAddition=${actBufferBasedScellAddition}
    ...   tcpdump_log_name=${tcpdump_log_name}
    ...   ue_index=${ue_index}      NSA_SA=${NSA_SA}   connection=${cu_oam_connection}

L3 call with UL or DL CA exist
    [Documentation]  Author: Ding Binmei
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
    ...    ${scell_index_ul}: scell index for UL CA. Example value: 1,2    ${None} means no ul CA.
    ...    ${scell_index_dl}: scell index for DL CA. Example value: 1,2    ${None} means no dl CA.
    ...    ${tcpdump_log_name}: Refer to the f1ap log captured during ue attach phase
    ...    ${scell_addition_method}: blind, covBasedA1
    ...    ${NSA_SA}: SA, NSA. Can define this as a global variable in feature
    ...    ${connection}: Refer to the SSL connection alias for GNB. For cloud, this filed is not used
    ...    ${dl_tput_iperf}/${dl_tput_iperf}: ul/dl tput started on iperf. e.g: 1800M
    ...    ${protocol}: udp, tcp
    ...    ${iperf_duration}: duration for iperf process startup.   e.g: 3000s
    ...    ${data_transfer_direction}: ul, dl, both
    ...    ${UE_TYPE}: Suite varaible defined in suite setup. Get from : ue.translate_power_ue_type_from_testline
    ...    ${tput_duration}: duration for check tput
    ...    ${check_tput_ignore_time}: ignore time for check tput to wait for tput stable
    ...    ${customized_log_name}: For generated tput image file name
    ...    ${actBufferBasedScellAddition}:  indicate whether to enbale 8311. values: disabled, oneShot_Dl_Fr1
    ...    ${is_analysis_log_captured}: ${True} / ${False}
    [Arguments]    ${cell_index}    ${exp_ul_indiv}=${EXP_UL_INDIV}    ${exp_dl_indiv}=${EXP_DL_INDIV}
    ...    ${scell_index_ul}=${SCELL_ID_UL_ADD}    ${scell_index_dl}=${SCELL_ID_DL_ADD}    ${pcell_id}=${PCELL_ID}
    ...    ${tcpdump_log_name}=basic_l3_call    ${exp_ul}=1    ${exp_dl}=1
    ...    ${scell_addition_method}=blind   ${ue_index}=${0}   ${NSA_SA}=${NSA_SA}    ${connection}=GNB_OAM
    ...    ${dl_tput_iperf}=${DL_TPUT_IPERF}    ${ul_tput_iperf}=${UL_TPUT_IPERF}    ${protocol}=udp    ${iperf_duration}=3000s
    ...    ${data_transfer_direction}=both    ${tput_duration}=60s    ${check_tput_ignore_time}=30s    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${customized_log_name}=L3_call_with_CA
    ...    ${is_need_to_stop_traffic}=${True}  ${gnb_index}=${0}   ${du_index}=${0}    ${actBufferBasedScellAddition}=disabled
    ...    ${is_analysis_log_captured}=${False}    ${bip_log_name}=tput_validation_failed    ${bip_capture_time}=10s
    ...    ${process_num}=${IPERF_PROCESS_NUM}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${connection}    set variable if  '${has_cbts}'=='${True}'    OAM_CU${gnb_index}    ${connection}
    ${ute_log_path_f1ap_attach}    UE attach and verify Scell addition in tcpdump log
    ...    scell_index_ul=${scell_index_ul}    scell_index_dl=${scell_index_dl}
    ...    pcell_id=${pcell_id}    tcpdump_log_name=${tcpdump_log_name}    scell_addition_method=${scell_addition_method}    ue_index=${ue_index}
    ...    NSA_SA=${NSA_SA}    connection=${connection}
    ...    gnb_index=${gnb_index}    actBufferBasedScellAddition=${actBufferBasedScellAddition}

    Run keyword if    '${actBufferBasedScellAddition}'=='oneShot_Dl_Fr1' and '${data_transfer_direction}'!='ul'
    ...    Start capture F1AP log   gnb_id=${gnb_index}    tcpdump_collector_name=${tcpdump_log_name}_verify_scell_addition_when_8311_enabled
    ...        options=-i any sctp
    Start data transfer based on direction    dl_tput=${dl_tput_iperf}     ul_tput=${ul_tput_iperf}    protocol=${protocol}
    ...    duration=${iperf_duration}    data_transfer_direction=${data_transfer_direction}    process_num=${process_num}

    ${tput_log_path}       run keyword if    '${has_cbts}'=='${True}'
    ...    Cloud Standard Capturing Kubectl Throughput
    ...       gnb_index=${gnb_index}   vdu_index=${du_index}
    ...       duration=${tput_duration}    check_tput_ignore_time=${check_tput_ignore_time}
    ...    ELSE        power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}
    ...                   ignore_time=${check_tput_ignore_time}    filter=L2Lo
    run keyword and ignore error    check iperf process on appserver
    ${f1ap_log_path_verify_scell_addition_if_8311_is_enabled}
    ...    Run keyword if    '${actBufferBasedScellAddition}'=='oneShot_Dl_Fr1' and '${data_transfer_direction}'!='ul'
    ...        logs.Stop capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}_verify_scell_addition_when_8311_enabled    gnb_id=${gnb_index}

    Run keyword and continue on failure   Run keyword if   '${actBufferBasedScellAddition}'=='oneShot_Dl_Fr1' and '${data_transfer_direction}'!='ul'
    ...    Verify scell addition from f1ap log    log_file_path=${f1ap_log_path_verify_scell_addition_if_8311_is_enabled}
    ...    scell_index_ul=${scell_index_ul}    scell_index_dl=${scell_index_dl}
    ${connection}    set variable if  '${has_cbts}'=='${True}'      OAM_gnb${gnb_index}_du${du_index}     ${connection}
    Check tput via power UE optimized    cell_index=${cell_index}     tput_log_path=${tput_log_path}    direction=${data_transfer_direction}
    ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    connection=${connection}
    ...    customized_log_name=${customized_log_name}    is_need_to_fail_keyword=${True}
    ...    is_analysis_log_captured=${is_analysis_log_captured}    bip_log_name=${bip_log_name}    bip_capture_time=${bip_capture_time}
    ...    gnb_index=${gnb_index}    du_index=${du_index}
    [Return]    ${ute_log_path_f1ap_attach}
    [Teardown]  Run keyword and ignore error    Run keywords    run keyword if    '${is_need_to_stop_traffic}'=='${True}'
    ...    Stop data transfer and detach UE    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}    AND
    ...    Run keyword if    '${actBufferBasedScellAddition}'=='oneShot_Dl_Fr1' and '${data_transfer_direction}'!='ul'
    ...        logs.Teardown F1AP log capture    gnb_id=${gnb_index}
    ...        tcpdump_collector_name=${tcpdump_log_name}_verify_scell_addition_when_8311_enabled

Cloud CA L3 Call
    [Documentation]    Author: Dandan Fang
    ...    Detail parameters explanation, please refer L3 call with UL or DL CA exist
    ...    Global variable ${CELL_INDEX_LIST} ${PCELL_ID} defined by Keyword "Decode CA group mapping and set CA Cell variable"
    [Arguments]
    #gnb cell info
    ...   ${cell_index}=${CELL_INDEX_LIST}   ${gnb_index}=${0}    ${du_index}=${0}    ${cu_oam_connection}=OAM_CU${gnb_index}
    ...   ${pcell_id}=${PCELL_ID}    ${scell_addition_method}=blind
    ...   ${scell_index_ul}=${SCELL_ID_UL_ADD}    ${scell_index_dl}=${SCELL_ID_DL_ADD}
    ...   ${tcpdump_log_name}=cloud_l3_call_with_ca
    #tput check related
    ...   ${exp_ul_indiv}=${EXP_UL_INDIV}    ${exp_dl_indiv}=${EXP_DL_INDIV}
    ...   ${exp_ul}=1    ${exp_dl}=1  ${tput_duration}=60s    ${check_tput_ignore_time}=30s    ${target_avg_percent}=0.95
    ...   ${min_percent}=0.85    ${customized_log_name}=cloud_CA_L3_Call_tput
    #iperf traffic related
    ...    ${dl_tput_iperf}=${DL_TPUT_IPERF}    ${ul_tput_iperf}=${UL_TPUT_IPERF}    ${protocol}=udp    ${iperf_duration}=3000s
    ...    ${data_transfer_direction}=both   ${is_need_to_stop_traffic}=${False}
    #ue related
    ...   ${ue_index}=${0}   ${NSA_SA}=${NSA_SA}
    Run keyword and continue on failure    L3 call with UL or DL CA exist
    #gnb cell info
    ...    cell_index=${cell_index}     gnb_index=${gnb_index}    du_index=${du_index}    connection=${cu_oam_connection}
    ...    pcell_id=${pcell_id}    scell_addition_method=${scell_addition_method}
    ...    scell_index_ul=${scell_index_ul}    scell_index_dl=${scell_index_dl}  tcpdump_log_name=${tcpdump_log_name}
    #tput check related
    ...    exp_ul_indiv=${exp_ul_indiv}   exp_dl_indiv=${exp_dl_indiv}
    ...    exp_ul=${exp_ul}   exp_dl=${exp_dl}    tput_duration=${tput_duration}    check_tput_ignore_time=${check_tput_ignore_time}
    ...    target_avg_percent=${target_avg_percent}     min_percent=${min_percent}   customized_log_name=${customized_log_name}
    #iperf traffic related
    ...    dl_tput_iperf=${dl_tput_iperf}    ul_tput_iperf=${ul_tput_iperf}    protocol=${protocol}
    ...    iperf_duration=${iperf_duration}     data_transfer_direction=${data_transfer_direction}
    ...    is_need_to_stop_traffic=${is_need_to_stop_traffic}
    ...    ue_index=${ue_index}    NSA_SA=${NSA_SA}

Adjust Pcell Signal Bad to do UE attach and A1 event configured for scell addition
    [Documentation]    Author: Dandan Fang
    [Arguments]    ${tcpdump_log_name}=A1Config_NonCA_When_PCell_Bad      ${NSA_SA}=SA
    ...            ${pcell_exp_pa_value}=${40}       ${pcell_ru_index}=0
    Initialize attenuator for specified RU     exp_pa_value=${pcell_exp_pa_value}    ru_index=${pcell_ru_index}

     ${A1_configured_log_path}    UE attach and verify Scell addition in tcpdump log
    ...            tcpdump_log_name=${tcpdump_log_name}   scell_addition_method=covBasedA1    NSA_SA=${NSA_SA}

    [Return]    ${A1_configured_log_path}

Adjust Pcell Signal as Good To Trigger A1 Report on Pcell and Do Scell Addition
    [Documentation]    Author: Dandan Fang
    ...      Note: It is just called when scell addition method as covBasedA1
    ...      a2_meas_for_scell_released control whether need to check A2 configured for Scell release, False no check
    ...                                         true need to check
    [Arguments]    ${tcpdump_log_name}=CA_A1_Report_When_Pcell_Good
    ...            ${pcell_exp_pa_value}=${0}       ${pcell_ru_index}=${PCELL_RU_INDEX}
    ...            ${a1_rsrp_thres}=${80}     ${a1_meas_id}=${1}
    ...            ${a2_meas_for_scell_released}=${False}
    ...            ${scell_index_ul}=${None}     ${scell_index_dl}=${SCELL_ID}
    Prepare and start aasyslog
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    sleep    1s    msg=Wait tcpdump log start sucess.
    log to console    Tune PA to trigger UE A1 measurement report
    Initialize attenuator for specified RU     exp_pa_value=${pcell_exp_pa_value}    ru_index=${pcell_ru_index}
    sleep    5s    msg=Wait for UE send A1 measurement report.

    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure  Verify A1 measurement report in F1AP log
    ...    log_path_pcap=${ute_log_path}   a1_rsrp_thres=${a1_rsrp_thres}     meas_id=${a1_meas_id}

    # no need to check A2 configured on which cell.
    run keyword if      ${a2_meas_for_scell_released}         Verify A2 event configed in F1AP log
    ...     log_path_pcap=${ute_log_path}

    run keyword and continue on failure    Verify scell addition from f1ap log    log_file_path=${ute_log_path}
    ...     scell_index_ul=${scell_index_ul}    scell_index_dl=${scell_index_dl}

    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    should not be true    ${is_scell_activated}
    [Return]    ${ute_log_path}
    [Teardown]    run keyword and ignore error    Run keywords    Stop Tcpdump via collector
    ...       tcpdump_collector_name=${tcpdump_log_name}    AND
    ...       Teardown the Aasyslog save progress

Adjust Scells And Pcell Signal as Bad To Trigger A2 Report and Scells Released
    [Documentation]    Author: Dandan Fang
    ...            Note:Pcell and Scell Signal need to be bad at the same time
    [Arguments]    ${tcpdump_log_name}=CA_A2_Report_When_Scell_Bad
    ...            ${pcell_exp_pa_value}=${40}         ${scell_exp_pa_value}=${40}
    ...            ${pcell_id}=${0}      ${scell_id_list}=${SCELL_ID_DL_ADD}   ${scell_index_list_check}=${None}

    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    log to console    Tune PA to trigger UE A2 measurement report
    sleep    1s    msg=Wait for tcpdump log success.

    #please adjust pcell signal together, else pingpong between A1 and A2.
    ${pcell_RU_Index}   set variable    ${NR_CELL_ID_MAPPING[${pcell_id}]['ruIndex_in_init']}
    Initialize attenuator for specified RU     exp_pa_value=${pcell_exp_pa_value}
    ...           ru_index=${pcell_RU_Index}
    FOR    ${scell_id}    IN    @{scell_id_list}
        ${scell_RU_Index}   set variable    ${NR_CELL_ID_MAPPING[${scell_id}]['ruIndex_in_init']}
        Initialize attenuator for specified RU     exp_pa_value=${scell_exp_pa_value}
        ...           ru_index=${scell_RU_Index}
    END
    sleep    15s    msg=Wait for UE send A2 measurement report.
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure     Verify measurement report for multiple cells in F1AP log
    ...    log_path_pcap=${ute_log_path}   cell_id=${scell_id_list}

    ${scell_id_list}    string2list    ${scell_id_list}
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

Adjust Pcell Scell Signal Back To Good To Trigger A1 Scell Addition Again
    [Documentation]    Author: Dandan Fang
    ...            Note:Pcell and Scell Signal need to be bad at the same time
    [Arguments]    ${tcpdump_log_name}=Scell_add_again_after_released
    ...            ${pcell_exp_pa_value}=${INIT_PA_F_T}
    ...            ${scell_index_ul}=${None}     ${scell_index_dl}=${SCELL_ID}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp

    Initialize attenuator values for testline  pa_values_mapping=${pcell_exp_pa_value}

    sleep    5s    msg=Wait for scell addition
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure    Verify scell addition from f1ap log    log_file_path=${ute_log_path}
    ...        scell_index_ul=${scell_index_ul}     scell_index_dl=${scell_index_dl}
    [Teardown]    run keyword and ignore error    Stop Tcpdump via collector        tcpdump_collector_name=${tcpdump_log_name}

Start UL or DL data transfer and verify Scell is activated or not For Bufferbased
    [Documentation]    Author: Dandan Fang
    [Arguments]    ${data_transfer_direction}=both    ${expect_scell_activated}=${False}
    ...            ${ul_tput_iperf}=300M      ${dl_tput_iperf}=2000M
    ...            ${log_name}=check_scell_act.txt
    ...            ${iperf_duration}=3000s
    Prepare and start aasyslog   log_name=${log_name}
    Start data transfer based on direction    data_transfer_direction=${data_transfer_direction}
    ...            ul_tput=${ul_tput_iperf}     dl_tput=${dl_tput_iperf}  duration=${iperf_duration}
    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation  log_name=${log_name}

    run keyword if    '${expect_scell_activated}'=='${True}'    should be true    ${is_scell_activated}
    ...    ELSE      should not be true    ${is_scell_activated}

    [Teardown]    Teardown the Aasyslog save progress

Stop DL or UL traffic stop to check Scell deactivated for Bufferbased
    [Arguments]    ${data_transfer_direction}=both    ${expect_scell_deactivated}=${False}
    ...            ${scell_id}=${SCELL_ID}    ${log_name}=check_scell_deact.txt     ${scell_operator_mode}=dl_only
    [Documentation]    Author: Dandan Fang
    ...    ${scell_id}: scell id, can be 1 or 1,2
    ...    ${scell_operator_mode}: scell operational mode, can be dl_only or dl_only,dlAndUl
    Prepare and start aasyslog   log_name=${log_name}
    Stop data transfer based on direction   data_transfer_direction=${data_transfer_direction}

    ${is_scell_deactivated}     Run keyword and return status    Stop aasyslog to check scell deactivation
    ...           scell_operator_mode=${scell_operator_mode}   log_name=${log_name}    scell_id=${scell_id}    sCelldeactivationMethod=bufferbased
    run keyword if    '${expect_scell_deactivated}'=='${True}'    should be true    ${is_scell_deactivated}
    ...    ELSE      should not be true    ${is_scell_deactivated}

check Scell activations M55316C09000 Scell Deactivation due to Buffer M55316C09001
    [Documentation]     author: dandan.fang@nokia-sbell.com
    ...      Following counter will be counted under Scell
    ...      M55316C09000: This counter provides the number of S-Cell activations while pegged in the secondary cell.
    ...      When an S-Cell transition to "active" is triggered
    ...      M55316C09001: This counter provides the number of S-Cell deactivations due to Buffer Status while pegged
    ...      in secondary cell. When an S-Cell transition to "inactive" is triggered.
    [Arguments]       ${starting_log_timestamp}   ${scell_id}=${SCELL_ID}   ${counter_expected_number}=${1}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${scell_id}
    ${list_measurement_ids}    create list    M55316C09000    M55316C09001
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files
    ...      list_file_path=${pm_files_local_path}      list_cell=${cell_check_list}
    ...      list_measurement_ids=${list_measurement_ids}

    ${scell_M55316C09000}    set variable    ${dict_measurements_value['${scell_id}']['M55316C09000']}
    ${scell_M55316C09001}    set variable    ${dict_measurements_value['${scell_id}']['M55316C09001']}
    run keyword and continue on failure   run keywords    Should be true      ${scell_M55316C09000}>=${counter_expected_number}
    ...                                        AND        Should be true      ${scell_M55316C09001}>=${counter_expected_number}

Remove NRREL and verify pcell lock unlock happened
    [Documentation]  Author: Ding Binmei
    ...    1. Change both pcell and scell status to notBarred: In case UE attach to other GNBs when pcell lock unlock after remove NRREL MO
    ...    2. Verify cell lock unlock happened.
    ...        a) Check from webUI directly, if passed then no need for b)step
    ...        b) If a) failed. Then double check from F1AP log during nrrel remove for pcell
    ...    ${scell_list}: can be a string or a list
    [Arguments]    ${file_name_f1ap_lock_unlock}=f1ap_log_check_lock_unlock_cell_happen    ${connection}=GNB_OAM    ${scell_list}=${SCELL_ID_DL_ADD}
    ${scell_list}    string2list    input_str=${scell_list}
    ${msg_reason_for_doing_unbarred_on_GNB}    Catenate    Since on later branches after 21A, remove NRREL will cause pcell lock and unlock
    ...    In case UE will attach to other GNBs, so need to unbar our local GNB cells.
    Log to console    ${msg_reason_for_doing_unbarred_on_GNB}
    Change status for parameter cellBarred on GNB    exp_status=notBarred    connection=${connection}

    Start capture F1AP log    tcpdump_collector_name=${file_name_f1ap_lock_unlock}   options=-i any sctp
    ${list_params_to_delete}    create list
    FOR    ${scell_index}    IN    @{scell_list}
        ${delete_nrrel_mo_rest_api}    coam_gnb_classical.get_remove_nrrel_mo_for_online_update    source_cell_id=${PCELL_ID}
        ...    neighbor_cell_id=${scell_index}
        ...    connection_alias_source=${connection}    connection_alias_neighbor=${connection}
        ${list_params_to_delete}    combine lists    ${list_params_to_delete}    ${delete_nrrel_mo_rest_api}
    END

    COAM delete objects via rest api    objects_to_delete_via_api=${list_params_to_delete}    connection=${connection}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ${is_pcell_unlocked}    Run keyword and return status    Cell Should Be Unlocked    cell_idx=${PCELL_ID}
    ...    cell_group_idx=${NR_CELL_ID_MAPPING[${PCELL_ID}]['cell_group_id']}    connection=${connection}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
    ${tcpdump_log_file_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=${file_name_f1ap_lock_unlock}

    ${is_checking_passed_from_webui}    Run keyword and return status    Should not be true    ${is_pcell_unlocked}
    ...    msg=Expect Pcell lock unlock happen, but actually cell remained in unlocked status

    ${is_checking_passed}    Run keyword if    ${is_checking_passed_from_webui}==${False}
    ...    Run keyword and return status    Verify pcell lock unlock happen from tcpdump log when fail to check status from webUI after nrrel delete
    ...        tcpdump_log=${tcpdump_log_file_path_f1ap}
    ...    ELSE    Set variable    ${True}
    Should be true    ${is_checking_passed}
    [Teardown]    run keyword and ignore error    Stop Tcpdump via collector  tcpdump_collector_name=${file_name_f1ap_lock_unlock}
