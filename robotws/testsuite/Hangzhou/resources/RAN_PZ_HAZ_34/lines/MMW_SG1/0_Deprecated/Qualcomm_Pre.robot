*** Settings ***
Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: SG_04
...   this is mainly for qualcomm UE

Resource     ../SISO_Pre.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/qualcomm_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Keywords ***
#Call case with Qualcomm UE and record throughput info
#    [Documentation]  Author: Liu Zheng
#    ...              Description: duration_time: Duration Time for checking  throughput, time unit is seconds
#    ...                           interval_time: wait time for checking next throughput, time unit is seconds
#    ...              Export collected tput data to csv file, csv file will be stored in test case log folder
#    ...              with file name like: throughput_records_${timestamp}.csv
#    [Arguments]    ${duration_time}    ${interval_time}    ${ue_index}=${0}    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}
#    ...    ${tput_csv_file_folder}=${TS_CASE_LOG_PATH}
#    Retry ue attach if failed    is_pb_exist=${False}
#    ${ue_addr}    android_common_keyword.Get the UE Ip address    ue_index=${0}
#    Close the iperf process on Qualcomm    ue_index=${ue_index}
#    ${traffic_time}    Evaluate    ${duration_time}*10
#    Data Transfer    DT_Name=dt1    UE_alias=UE_${ue_index}    direction=dl    Expected_Tput=${DL_THROUGHPUT}    Duration=${traffic_time}
#    ...    Data_Type=udp    Packet_Size=${DL_LENGTH}
#    Data Transfer    DT_Name=dt2    UE_alias=UE_${ue_index}    direction=ul    Expected_Tput=${UL_THROUGHPUT}    Duration=${traffic_time}
#    ...    Data_Type=udp    Packet_Size=${UL_LENGTH}
#    sleep    10s
#    @{list_tput_info}    Run keyword and continue on failure    Verify UL and DL Throughput For some time    ue_index=${0}
#    ...    capture_time=${duration_time}    interval=${interval_time}    ul_expect=${ul_exp_tput}
#    ...    dl_expect=${dl_exp_tput}    ul_port=${UL_PORT}     dl_port=${DL_PORT}
#    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
#    ${csv_log_file_path}    Join path    ${tput_csv_file_folder}    throughput_records_${timestamp}.csv
#    export_to_csv.write_data_to_csv    input_data=${list_tput_info}    csv_file_path=${csv_log_file_path}
#    [Return]    ${list_tput_info}

Call case with QCOM UE and record throughput info for many cells many times
    [Documentation]    Author: Liu Zheng
    ...    ${GNB_PS_CELL_INDEX_LIST} is the cell list which can do attach. it is set in variables.robot.
    [Arguments]   ${para_update_timeout}=6 min    ${repeat_times}=${TEST_REPEAT_TIMES}
    ...    ${duration_time}=${3000}    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}
    ...    ${cell_index_list}=${CELL_INDEX_LIST}    ${exp_tput_percentage}=1
    ...    ${verify_duration}=${30}
    ...    ${sgnb_addition_on_spec_cell_needed}=${True}
    ...    ${actCarrierAggregation}=${False}
    ...    ${ignore_time}=${30}

    FOR    ${cell_index}    IN    @{cell_index_list}
        run keyword if   '${cell_index}' in @{GNB_PS_CELL_INDEX_LIST}
        ...    Call case with QCOM UE and record throughput info on specific cell for many times
        ...    gnb_ps_cell_index=${cell_index}    duration_time=${duration_time}
        ...    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}    repeat_times=${repeat_times}
        ...    exp_tput_percentage=${exp_tput_percentage}    verify_duration=${verify_duration}    ignore_time=${ignore_time}
        ...    sgnb_addition_on_spec_cell_needed=${sgnb_addition_on_spec_cell_needed}
        ...    actCarrierAggregation=${actCarrierAggregation}
        ...    ELSE    log to console    ${cell_index} not in \${GNB_PS_CELL_INDEX_LIST} [${GNB_PS_CELL_INDEX_LIST}], no need to do traffic test.
    END

Call case with QCOM UE and record throughput info on specific cell for many times
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${gnb_ps_cell_index}    ${duration_time}=${3000}    ${ul_exp_tput}=${UL_EXPECT}
    ...    ${dl_exp_tput}=${DL_EXPECT}    ${repeat_times}=${TEST_REPEAT_TIMES}    ${para_update_timeout}=6 min
    ...    ${exp_tput_percentage}=1    ${verify_duration}=${30}
    ...    ${sgnb_addition_on_spec_cell_needed}=${True}    ${is_need_to_capture_log}=${False}
    ...    ${retry_time}=3    ${ue_index}=${0}
    ...    ${actCarrierAggregation}=${False}
    ...    ${retry_time}=3    ${ue_index}=${0}    ${ignore_time}=${30}

    FOR    ${run_time}    IN RANGE    ${repeat_times}
        Call case with QCOM UE and record throughput info on specific cell    gnb_ps_cell_index=${gnb_ps_cell_index}
        ...    para_update_timeout=${para_update_timeout}
        ...    traffic_duration=${duration_time}    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}
        ...    exp_tput_percentage=${exp_tput_percentage}    verify_duration=${verify_duration}
        ...    sgnb_addition_on_spec_cell_needed=${sgnb_addition_on_spec_cell_needed}
        ...     retry_time=${retry_time}    ue_index=${ue_index}    exp_tput_percentage=${exp_tput_percentage}
        ...    actCarrierAggregation=${actCarrierAggregation}
        ...     ignore_time=${ignore_time}
        Run keyword and ignore error    SISO_Pre.Close iperf progress
        run keyword and ignore error    wait until keyword succeeds    3x     1s    UE detach should be successed
    END

Call case with QCOM UE and record throughput info on specific cell
    [Documentation]    Author: Liu Zheng
    [Arguments]     ${gnb_ps_cell_index}   ${para_update_timeout}=6 min
    ...    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}
    ...    ${exp_tput_percentage}=1    ${verify_duration}=${30}
    ...    ${sgnb_addition_on_spec_cell_needed}=${True}

    ...    ${ignore_time}=30s    ${data_transfer_direction}=both    ${traffic_duration}=3000s
    ...    ${seg_size}=1350    ${iperf_ul_port}=${None}    ${iperf_dl_port}=${None}    ${buffer_size}=1400B
    ...    ${iperf_type_ul}=via_command    ${window}=16M
    ...    ${ue_type}=${UE_TYPE}    ${retry_time}=3    ${ue_index}=${0}    ${prepare_ue_needed}=${False}
    ...    ${detach_request}=${False}    ${connection}=GNB_OAM    ${is_ue_reboot}=${False}
    ...    ${actCarrierAggregation}=${False}

    ${cell_mapping_gnb_rnb}    run keyword if    ${gnb_ps_cell_index}<=8    set variable    ${gnb_ps_cell_index}
    ...    ELSE IF    8<${gnb_ps_cell_index}<=16    evaluate   ${gnb_ps_cell_index}-6
    ...    ELSE IF    16<${gnb_ps_cell_index}<=24   evaluate   ${gnb_ps_cell_index}-12
    ...    ELSE    Fail    msg=for feature 1596, there should no cells whose cell id is larger than 24
    run keyword if    ${sgnb_addition_on_spec_cell_needed}    Make SgNBAddition on specific cell
    ...     gnb_ps_cell_index=${cell_mapping_gnb_rnb}    para_update_timeout=${para_update_timeout}    alias=enblte
#    ${status}    Run keyword and return status    Call case with QCOM UE and verify throughput
#    ...    verify_duration=${verify_duration}    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}
#    ...    cell_id=${gnb_ps_cell_index}    exp_tput_percentage=${exp_tput_percentage}
#    ...    duration_time=${duration_time}    interval_time=${interval_time}
#    ...    is_need_to_capture_log=${is_need_to_capture_log}
    ${status}    Run keyword and return status    L3 call check tput via power UE     cell_id=${gnb_ps_cell_index}
    ...    dl_tput=${DL_THROUGHPUT}    ul_tput=${UL_THROUGHPUT}
    ...    exp_ul=${ul_exp_tput}    exp_dl=${dl_exp_tput}    tput_check_duration=${verify_duration}
    ...    ignore_time=${ignore_time}    actCarrierAggregation=${actCarrierAggregation}
    ...    data_transfer_direction=${data_transfer_direction}
    ...    traffic_duration=${traffic_duration}    protocol=udp    seg_size=${seg_size}
    ...    iperf_ul_port=${iperf_ul_port}    iperf_dl_port=${iperf_dl_port}    buffer_size=${buffer_size}
    ...    iperf_type_ul=${iperf_type_ul}    window=${window}
    ...    ue_type=${ue_type}    retry_time=${retry_time}    ue_index=${ue_index}    prepare_ue_needed=${prepare_ue_needed}
    ...    detach_request=${detach_request}    connection=${connection}    is_ue_reboot=${is_ue_reboot}
    ...    target_avg_percent=${exp_tput_percentage}
    Should be true    '${status}' == '${True}'

UE attach and verify
    [Documentation]      Author: Liu Zheng
    run keyword if    '${UE_TYPE}'=='qct_dx50'    UE attach and verify for QCOM with retry
    ...    ELSE    UE attach and verify for commercial UE

UE attach and verify for QCOM with retry
    [Documentation]      Author: Liu Zheng
    [Arguments]    ${ue_index}=${0}
    ${attach_status}    UE attach and verify for QCOM
    run keyword if    ${attach_status['4G_attach_status']}==${False}    ADB Reboot UE    ue_index=${ue_index}
    run keyword if    ${attach_status['4G_attach_status']}==${False} or ${attach_status['5G_attach_status']}==${False}
    ...    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}
    run keyword if    ${attach_status['4G_attach_status']}==${False} or ${attach_status['5G_attach_status']}==${False}
    ...    UE attach and verify for QCOM

UE attach and verify for QCOM
    [Documentation]      Author: Liu Zheng
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}
    ${attach_status}    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}
    [Return]    ${attach_status}

UE attach and verify for commercial UE
    [Documentation]      Author: Liu Zheng
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}
    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=${False}

Verify SIM card state and reboot UE if SIM not loaded
    [Documentation]   Author: Wang Yixiang
    ...    Verify SIM card state by ADB command, if sim card is not loaded, reboot UE
    [Arguments]    ${ue_index}=${0}    ${sleep_time_before_read_output}=${None}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ${ue_index}
    csn.send command
    ...    command=adb -s ${serial_number} shell getprop gsm.sim.state
    ...    connection=cpc_${ue_index}
    ...    timeout=15
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cpc_${ue_index}
    ${reboot}    run keyword and return status    Should contain  ${result}  LOADED
    run keyword if    ${reboot}==${False}
    ...    run keywords   Commercial UE soft reboot and check
    ...    AND    Log to console    \nINFO: SIM card not found, reset UE successfully.
    [Teardown]     Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}

Commercial UE soft reboot and check
    [Documentation]    Author: Wang Yixiang
    ...    Actions for commercial UE reboot request needed.
    [Arguments]  ${ue_index}=${0}   ${detach_request}=${true}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Check UE device exist    ${ue_index}
    Restart adb server and wait until status ready    ue_index=${ue_index}   serial_number=${serial_number}
    ADB reboot ue    ue_index=${ue_index}   serial_number=${serial_number}
    Log to console    wait for adb startup
    Wait Until Keyword Succeeds    30 sec    1 sec    Check UE device exist    ${ue_index}

