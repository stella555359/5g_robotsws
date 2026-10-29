*** Settings ***
Documentation
...   author: Tong Chen
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02
Resource     Resources/Resource_common_keywords.robot

*** Keywords ***
Try huawei sigspark attach
    [Timeout]    10 min
    [Documentation]    Author: Chen Tong
    ...   Description: try attach via sigspark
    ...   ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${prepare_ue_needed}=${True}    #${retry_time}=5
    ...            ${attach_mode}=5G_SA    ${power_reset}=False    #${4G_check}=True
    ADB Reboot UE    ue_index=${ue_index}
    Sleep    30s
    #spark.restartapp
    run keyword if    ${prepare_ue_needed}==${True}     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    reset_sol=True
    spark.enable_ue_data_service    ue_alias=UE_${ue_index}
    ${attach_status}    run keyword and return status    power_ue.UE Attach    ue_type=${ue_type}
    ...                                                                        ue_index=${ue_index}
    ...                                                                        attach_mode=${attach_mode}
    ...                                                                        power_reset=${power_reset}
    sleep    1 min
    run keyword if  not ${attach_status}    wait until keyword succeeds    3x   10s
    ...                                       Retry huawei sigspark attach if failed    ue_type=${ue_type}
    ...                                                                                 ue_index=${ue_index}
    ...                                                                                 attach_mode=${attach_mode}

Retry huawei sigspark attach if failed
    [Timeout]    10 min
    [Documentation]    Author: Chen Tong
    ...   Description: try attach via sigspark
    ...   ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    [Arguments]    ${ue_type}    ${ue_index}=${0}    #${retry_time}=5
    ...            ${attach_mode}=5G_SA    #${4G_check}=True
    run keyword and ignore error    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True
    sleep    30s
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}    power_reset=True
    sleep    1 min

Call case with huawei sigspark and record throughput info
    [Documentation]  Author: Chen Tong
    ...              Description:
    ...              ${duration_time}: is the duration time for calculating average tput in one capturing
    ...              ${total_time}: is the duration time in which the throughput need to be checked. The time unit is second.
    ...              ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    [Arguments]    ${duration_time}    ${total_time}    ${ul_exp_tput}=${UL_EXPECT}    ${ue_type}=${UE_TYPE}    #${interval_time}
    ...    ${dl_exp_tput}=${DL_EXPECT}    ${tput_percentage}=${EXP_TPUT_PERCENTAGE}    ${retry_time}=3    ${iperf_ul}=${None}    #${iperf_dl}=${None}
    ...    ${ul_buffer_size}=1400    ${dl_buffer_size}=1400    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${apn_address}=wap1nokiacom
    ...    ${ul_throughput}=${UL_THROUGHPUT}    ${dl_throughput}=${DL_THROUGHPUT}    ${ue_mode}=SA    #${is_need_to_capture_log}=${False}
    ...    ${data_transfer_direction}=both    ${prepare_ue_needed}=${True}    ${4G_check}=True    ${min_percent}=0.85    ${attach_mode}=5G_SA
    Try huawei sigspark attach    retry_time=${retry_time}    ue_type=${ue_type}    attach_mode=${attach_mode}
    ...                           prepare_ue_needed=${prepare_ue_needed}    4G_check=${4G_check}    ue_index=${ue_index}
    ${traffic_time}    Evaluate    ${total_time}*10
    ${iperf_ul}    Set variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    run keyword if  not '${data_transfer_direction}'=='dl'    Wait until keyword succeeds    5X    3 s    power_ue.Start traffic
    ...    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    ue_mode=${ue_mode}    apn_address=${apn_address}
    ...    duration=${traffic_time}    buffer_size=${ul_buffer_size}    iperf_port=${iperf_ul}    ue_index=${ue_index}    dt_name=dt_ul
    run keyword if  not '${data_transfer_direction}'=='ul'    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_throughput}   duration=${traffic_time}    buffer_size=${dl_buffer_size}    apn_address=${apn_address}
    ...    ue_index=${ue_index}    dt_name=dt_dl    ue_mode=${ue_mode}
    sleep    15s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    ue_alias=${ue_alias}
    run keyword if  not '${data_transfer_direction}'=='ul'    power_ue.Check Tput    ue_index=${ue_index}
    ...                    ue_type=${ue_type}    direction=DL    cells=${ue_alias}    log=${tput_log}
    ...                    target_throughput=${dl_exp_tput}    target_avg_percent=${tput_percentage}    min_percent=${min_percent}
    run keyword if  not '${data_transfer_direction}'=='dl'    power_ue.Check Tput    ue_index=${ue_index}
    ...                    ue_type=${ue_type}    direction=UL    cells=${ue_alias}    log=${tput_log}
    ...                    target_throughput=${ul_exp_tput}    target_avg_percent=${tput_percentage}    min_percent=${min_percent}
#    Verify tput from GNB within duration and record data to csv    total_time=${total_time}    exp_dl_tput=${dl_exp_tput}
#    ...    exp_ul_tput=${ul_exp_tput}    interval=${interval_time}    duration_time_for_once=${duration_time}
#    ...    tput_percentage=${tput_percentage}    is_need_to_capture_log=${is_need_to_capture_log}

Try Multi UE Dingli Pioneer attach
    [Arguments]    ${ue_type}    ${nettype}=SA+NSA    ${attach_mode}=5G_SA    ${4G_check}=False    #${ue_mode}=SA
    FOR    ${ue_idx}    IN    @{UE_INDEX}
        power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${ue_idx}
        spark.config_5g_deployment    nettype=${nettype}    ue_alias=UE_${ue_idx}
        Sleep    8s
        Log to Console    "attach_UE${ue_idx}"
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}     attach_mode=${attach_mode}    ue_index=${ue_idx}
        power_ue.Verify attach     ue_type=${ue_type}    4G_check=${4G_check}    5Grach_ed=${5Grach_ed}     ue_index=${ue_idx}
    END

Multi UE Dingli Pioneer Stop Traffic and Detach
    [Arguments]    ${apn_address}='wap1.nokia.com'    ${ue_mode}=SA
    FOR    ${ue_idx}    IN    @{UE_INDEX}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_idx}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_idx}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
        run keyword and ignore error    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_idx}
    END

Call case with Multi UE Dingli Pioneer and record throughput info
    [Arguments]    ${cells}    ${apn_address}='wap1.nokia.com'    ${nettype}=SA+NSA    ${ue_mode}=SA    ${attach_mode}=5G_SA
    ...            ${4G_check}=False    ${ul_throughput}=${UL_THROUGHPUT}    ${dl_throughput}=${DL_THROUGHPUT}
    ...            ${total_time}=300    ${dl_exp_tput}=${DL_EXPECT}    ${ul_exp_tput}=${UL_EXPECT}        ${min_percent}=0.85
    ...            ${data_transfer_direction}=both    ${check_source}=aasyslog    ${dl_tput_percentage}=${EXP_TPUT_PERCENTAGE}
    ...            ${ul_tput_percentage}=${EXP_TPUT_PERCENTAGE}
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${UE_INDEX[0]}
    Set test variable    ${ue_type}
    Try Multi UE Dingli Pioneer attach    ue_type=${ue_type}    ue_mode=${ue_mode}    attach_mode=${attach_mode}
    ...                                   nettype=${nettype}    4G_check=${4G_check}
    ${traffic_time}    Evaluate    ${total_time}*10
    FOR    ${ue_idx}    IN    @{UE_INDEX}
        run keyword if  not '${data_transfer_direction}'=='ul'    power_ue.Start traffic     ue_type=${ue_type}    direction=dl
        ...                   throughput=${dl_throughput}    duration=${traffic_time}     ue_index=${ue_idx}    ue_mode=${ue_mode}
        ...                   apn_address=${apn_address}
        run keyword if  not '${data_transfer_direction}'=='dl'    power_ue.Start traffic     ue_type=${ue_type}    direction=ul
        ...                   throughput=${ul_throughput}    duration=${traffic_time}    ue_index=${ue_idx}    ue_mode=${ue_mode}
        ...                   apn_address=${apn_address}
        Log to Console    "Start_UE${ue_idx}_Traffic"
    END
    sleep    15s
    Multi UE Dingli Pioneer Check throughput    cells=${cells}
    ...                                         dl_exp_tput=${dl_exp_tput}
    ...                                         ul_exp_tput=${ul_exp_tput}
    ...                                         dl_tput_percentage=${dl_tput_percentage}
    ...                                         ul_tput_percentage=${ul_tput_percentage}
    ...                                         min_percent=${min_percent}
    ...                                         data_transfer_direction=${data_transfer_direction}
    ...                                         check_source=${check_source}
    [Teardown]    Multi UE Dingli Pioneer Stop Traffic and Detach    apn_address=${apn_address}    ue_mode=${ue_mode}

Multi UE Dingli Pioneer Check throughput
    [Arguments]    ${cells}    ${dl_exp_tput}    ${ul_exp_tput}    ${dl_tput_percentage}    ${ul_tput_percentage}    ${min_percent}
    ...            ${data_transfer_direction}    ${check_source}=aasyslog
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    check_source=${check_source}
    run keyword if  not '${data_transfer_direction}'=='ul'    power_ue.Check Tput
    ...                    ue_type=${ue_type}    direction=DL    cells=${cells}    log=${tput_log}    check_source=${check_source}
    ...                    target_throughput=${dl_exp_tput}    target_avg_percent=${dl_tput_percentage}    min_percent=${min_percent}
    run keyword if  not '${data_transfer_direction}'=='dl'    power_ue.Check Tput
    ...                    ue_type=${ue_type}    direction=UL    cells=${cells}    log=${tput_log}    check_source=${check_source}
    ...                    target_throughput=${ul_exp_tput}    target_avg_percent=${ul_tput_percentage}    min_percent=${min_percent}
