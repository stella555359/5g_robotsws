*** Settings ***
Documentation
...              tingting.zhong@nokia-sbell.com

Library          ./sleepingcell_rollback_if_needed.py
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
*** Variables ***
${ul_power_port_list}     ${tl.ues[0].iperf_details.ports[0]}
${dl_power_port_list}     ${tl.ues[0].iperf_details.ports[3]}

*** Keywords ***
Generate new Peak Dict
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    ...    cell_list: [1] or [1,2],
    ...    if cell list not mapping ue in init file, ue_index=0
    ...    send tpup 50% theoretical tput, except get tput 80%
    [Arguments]
    ...    ${cell_list}
    ...    ${ue_num_each_call}=1
    ...    ${duration}=${60}
    ...    ${send_rate}=0.5
    ...    ${target_avg_percent}=0.8
    ...    ${min_percent}=0.7
    ...    ${check_wait_time}=30
    ...    ${gnb_index}=0
    ...    ${connection}=GNB_OAM
    ...    ${loop_times}=${2}
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}
    ...    connection=${connection}    duration=${duration}
    ...    l3_avg_rate=${target_avg_percent}    l3_min_rate=${min_percent}
    FOR    ${cell_id}    IN    @{cell_list}
           ${dl_tp}    evaluate    ${cell_and_peak_info['${cell_id}']['dl_exp']}*${send_rate}
           set to dictionary    ${cell_and_peak_info['${cell_id}']}    dl_tp    ${dl_tp}M
           set to dictionary    ${cell_and_peak_info['${cell_id}']}    dl_exp    ${dl_tp}
           ${ul_tp}    evaluate    ${cell_and_peak_info['${cell_id}']['ul_exp']}*${send_rate}
           set to dictionary    ${cell_and_peak_info['${cell_id}']}    ul_tp    ${ul_tp}M
           set to dictionary    ${cell_and_peak_info['${cell_id}']}    ul_exp    ${ul_tp}
    END
    log to console    new cell_and_peak_info:${cell_and_peak_info}
    [Return]    ${cell_and_peak_info}    ${ue_index_list}

Make L3 Call
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]
    ...    ${cell_list}
    ...    ${loop_times}=${2}
    ${cell_and_peak_info}    ${ue_index_list}    Generate new Peak Dict    cell_list=${cell_list}
    run keyword if  ${ue_index_list}!=${None}  L3 call with Check Throughput
    ...    ue_index_list=${ue_index_list}
    ...    cell_list=${cell_list}
    ...    loop_times=${loop_times}
    ...    cell_and_peak_info=${cell_and_peak_info}
    ...    ELSE  log to console  no ue on ${cell_list}!!!

Make L3 Call With RU List
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]
    ...    ${ru_index_list}
    ...    ${connection}=GNB_OAM
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        Make L3 Call   cell_list=${cell_list}
    END

Detach All Ues in Init
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    ${ue_num}    get length    ${tl.ues}
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END

Get cell nrCellIdentity list
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]   ${cell_group_id}
    Connect to gnb coam via ssl
    ${nrcell_info}     get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${nrcell_id_list}    create list
    ${dic_value}    get dictionary values    ${nrcell_info}
    FOR    ${item}    IN    @{dic_value}
        ${cell_group}    get from dictionary    ${item}    cell_group_id
        ${nr_cell}    get from dictionary    ${item}    nrCellIdentity
        run keyword if    '${cell_group}'=='${cell_group_id}'
        ...    append to list      ${nrcell_id_list}    ${nr_cell}
    END
    [Teardown]    COAM Teardown gnb connections
    [Return]    ${nrcell_id_list}

Attach power ue
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}   ${gnb_index}=${0}    ${ue_index}=${0}
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False    gnb_index=${gnb_index}

Start power ue traffic ul and dl
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ul_throughput}=150M    ${dl_throughput}=2048M     ${ue_type}=samsung
    ...    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp
    log to console      Start traffic    console=yes
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=${ue_type}    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=@{ul_power_port_list}
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl
    ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=${ue_type}    protocol=${protocol}
    ...    iperf_port=@{dl_power_port_list}

Stop power ue traffic ul and dl
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp
    log to console     Stop traffic    console=yes
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=samsung    iperf_type=${protocol}
    ...    protocol=${protocol}     iperf_port=@{ul_power_port_list}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=samsung
    ...    protocol=${protocol}     iperf_port=@{dl_power_port_list}

Check throughput power ue
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]    ${dl_nrcell_id}  ${ul_nrcell_id}  ${ue_type}=samsung    ${dl_throughput}=500    ${ul_throughput}=70
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    ignore_time=10s
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${dl_nrcell_id}    target_throughput=${dl_throughput}    target_avg_percent=0.5    min_percent=0.05
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${ul_nrcell_id}    target_throughput=${ul_throughput}    target_avg_percent=0.5    min_percent=0.05

Detach power ue
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=samsung