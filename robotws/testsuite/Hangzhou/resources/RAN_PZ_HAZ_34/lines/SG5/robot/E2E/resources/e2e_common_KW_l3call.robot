*** Settings ***
Documentation    This is common keywords for siso related case steps used in team
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot

*** Variables ***

*** Keywords ***
Check file not Exist in RU
    [Arguments]  ${log_name}=123.txt    ${ru_index}=1
    connect to common unit master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${output}    csn.execute    command=${sudo} ls -l /tmp/${log_name}    connection=RU_${ru_index}
    sleep  2
    log    ${output}
    Should Contain      ${output}      No such file or directory
    [Return]  run keywords  csn.disconnect   connection=RU_${ru_index}    AND
    ...    csn.Disconnect   connection=ASIK Master

Cell block and unblock under specify RU
    [Arguments]   ${cell_list_under_RU}   ${check_alarm}=${False}
#   ...           ${with_call}=${with_call}   ${with_peak}=${with_peak}   ${duration}=${call_duration}
    FOR  ${block_id}  IN  @{cell_list_under_RU}
        ${operate_list}    create list    ${block_id}
#        run keyword if   ${with_call}    Get UE From Init File and Make call    cell_list=${operate_list}
#        ...    with_peak=${with_peak}    duration=${duration}
        Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
#        run keyword if   ${with_call}    Get UE From Init File and Make call    cell_list=${operate_list}
#        ...    with_peak=${with_peak}    duration=${duration}
    END

# **** l3call related KWs for team internal usage ****
_e2e UE L3 Call And Throughput
    [Arguments]   ${cell_id}=1   ${ue_index}=0   ${ue_number}=1   ${duration}=${60}
    ...    ${iperf_type}=via_app   ${protocol}=udp   ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...    ${dl_exp}=60    ${ul_exp}=20    ${target_avg_percent}=0.1    ${min_percent}=0.1
    ...    ${dl_tp}=300M  ${ul_tp}=100M

    _e2e Ue Attach and Start DL UL UDP Traffic    ue_index=${ue_index}  ui_version=${ui_version}   protocol=${protocol}
    ...              cell_id=${cell_id}   ue_number=${ue_number}   iperf_type=${iperf_type}   duration_call=${duration}
    ...              dl_tp=${dl_tp}   ul_tp=${ul_tp}
    teardown the aasyslog save progress
    sleep    ${check_wait_time}
    _e2e UE Verify Peak Throughput    cell_id=${cell_id}   ue_index=${ue_index}   duration_call=${duration}
    ...    dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    _e2e Ue Stop DL UL Traffic and Detach   ue_index=${ue_index}   iperf_type=${iperf_type}    protocol=${protocol}

_e2e UE Verify Peak Throughput
    [Arguments]  ${cell_id}=1   ${ue_index}=0   ${duration_call}=60   ${dl_exp}=300  ${ul_exp}=70
    ...    ${cell_and_peak_info}=${None}    ${target_avg_percent}=0.1    ${min_percent}=0.1
    ...    ${gnb_ssl_connection}=GNB_OAM
    log to console    \nUE Verify Peak Throughput
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${dl_exp}  ${ul_exp}  ${avg_expect_rate}  ${min_expect_rate}  ${duration}    get_verify_traffic_information  cell_id=${cell_id}
    ...    dl_exp=${dl_exp}  ul_exp=${ul_exp}   duration=${duration_call}    avg_expect_rate=${target_avg_percent}
    ...    min_expect_rate=${min_percent}    cell_and_peak_info=${cell_and_peak_info}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${gnb_ssl_connection}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_call}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${gnb_ssl_connection}
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
    ...    dltarget_throughput=${dl_exp}    target_avg_percent=${avg_expect_rate}    min_percent=${min_expect_rate}
    log to console    \n${output}

_e2e Ue Attach and Start DL UL UDP Traffic
    [Arguments]    ${ue_index}=0   ${ui_version}=default   ${protocol}=udp  ${cell_id}=1   ${ue_number}=1
    ...            ${cell_and_peak_info}=${None}   ${duration_call}=60    ${check_wait_time}=30   ${process_num}=default
    ...            ${dl_tp}=300M   ${ul_tp}=70M   ${iperf_type}=via_app

    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}   ui_version=${ui_version}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    ${dl_tp}  ${ul_tp}  ${duration_call}  get_start_traffic_information    cell_id=${cell_id}    ue_number=${ue_number}  dl_tp=${dl_tp}
    ...    ul_tp=${ul_tp}    duration=${duration_call}   cell_and_peak_info=${cell_and_peak_info}
    ...    check_wait_time=${check_wait_time}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}   process_num=${process_num}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}    data_amount=2M

_e2e Ue Stop DL UL Traffic and Detach
    [Arguments]  ${ue_index}=0    ${iperf_type}=via_app    ${protocol}=udp
    log to console    \nUe Stop DL UL Traffic and Detach
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_type=${iperf_type}    protocol=${protocol}
    run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
