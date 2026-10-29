*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${UE_TYPE}    huawei_sigspark

*** Keywords ***
Prepare and attach UE
    [Arguments]    ${ue_id}=1
    Prepare UEs    ue_ids=${ue_id}    get_spark_license=${get_spark_license}
    Attach UE    ue_id=${ue_id}

Prepare UEs
    [Documentation]    After prepare UEs, all UEs will be in detach state.
    ...    For mutiple UEs, suggest to use this keyword at first, and then attach UEs. Otherwise
    ...        1) maybe some of UEs are attached unexpected,
    ...        2) spark GUI log will be cleared after power_ue.Prepare UE
    ...    Note: cell signal must be opened before this keyword, otherwise at command will have no repsonse
    [Arguments]    ${ue_ids}=1,2    ${get_spark_license}=${true}
    @{ues}    Split String    ${ue_ids}    ,
    FOR    ${ue_id}    IN    @{ues}
        wait until keyword succeeds    6x    10s
        ...    power_ue.Prepare UE    ue_type=${UE_TYPE}
        ...                           ue_index=${${ue_id}-1}
        ...                           get_spark_license=${get_spark_license}
        ...                           force_check_ue=${True}
        spark.enable_ue_data_service    UE_${${ue_id}-1}
    END

Attach UE
    [Arguments]    ${ue_id}=1
    power_ue.UE Attach    ue_type=${UE_TYPE}    ue_index=${${ue_id}-1}    log_type=aasyslog
    power_ue.Verify Attach    ue_type=${UE_TYPE}   ue_index=${${ue_id}-1}

Detach UE
    [Arguments]    ${ue_id}=1
    power_ue.UE Detach    ue_type=${UE_TYPE}
    ...                   ue_index=${${ue_id}-1}

Start UL Traffic
    [Arguments]    ${ue_id}=1
    ...            ${send_traffic}=100M
    ...            ${send_duration}=7200
    ...            ${apn_address}=mdrbnokiacom
    ...            ${iperf_port}=default
    power_ue.Start traffic    ue_type=${UE_TYPE}
    ...                       direction=ul
    ...                       ue_index=${${ue_id}-1}
    ...                       throughput=${send_traffic}bits/sec
    ...                       duration=${send_duration}
    ...                       apn_address=${apn_address}
    ...                       iperf_port=${iperf_port}

Start DL Traffic
    [Arguments]    ${ue_id}=1
    ...            ${send_traffic}=500M
    ...            ${send_duration}=7200
    ...            ${apn_address}=mdrbnokiacom
    ...            ${iperf_port}=default
    run keyword and ignore error    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    power_ue.Start traffic    ue_type=${UE_TYPE}
    ...                       direction=dl
    ...                       throughput=${send_traffic}bits/sec
    ...                       duration=${send_duration}
    ...                       ue_index=${${ue_id}-1}
    ...                       apn_address=${apn_address}
    ...                       iperf_port=${iperf_port}

Start UL And DL traffic
    [Arguments]    ${ue_id}=1
    ...            ${send_traffic_ul}=100M
    ...            ${send_traffic_dl}=500M
    ...            ${send_duration}=7200
    ...            ${apn_address}=mdrbnokiacom
    ...            ${iperf_port}=default
    power_ue.Start traffic    ue_type=${UE_TYPE}
    ...                       direction=ul
    ...                       ue_index=${${ue_id}-1}
    ...                       throughput=${send_traffic_ul}bits/sec
    ...                       duration=${send_duration}
    ...                       apn_address=${apn_address}
    ...                       iperf_port=${iperf_port}
    power_ue.Start traffic    ue_type=${UE_TYPE}
    ...                       direction=dl
    ...                       throughput=${send_traffic_dl}bits/sec
    ...                       duration=${send_duration}
    ...                       ue_index=${${ue_id}-1}
    ...                       apn_address=${apn_address}
    ...                       iperf_port=${iperf_port}

Stop DL Traffic
    [Arguments]    ${ue_id}=1    ${apn_address}=mdrbnokiacom
    power_ue.Stop traffic    ue_type=${UE_TYPE}
    ...                      direction=dl
    ...                      ue_index=${${ue_id}-1}
    ...                      apn_address=${apn_address}

Stop UL Traffic
    [Arguments]    ${ue_id}=1    ${apn_address}=mdrbnokiacom
    power_ue.Stop traffic    ue_type=${UE_TYPE}
    ...                      direction=ul
    ...                      ue_index=${${ue_id}-1}
    ...                      apn_address=${apn_address}

Stop UL And DL traffic
    [Arguments]    ${ue_id}=1    ${apn_address}=mdrbnokiacom
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${UE_TYPE}
    ...                      direction=dl
    ...                      ue_index=${${ue_id}-1}
    ...                      apn_address=${apn_address}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${UE_TYPE}
    ...                      direction=ul
    ...                      ue_index=${${ue_id}-1}
    ...                      apn_address=${apn_address}

Collect And Check Tput
    [Arguments]    ${cells}
    ...            ${dl_target_tp}=${EMPTY}
    ...            ${ul_target_tp}=${EMPTY}
    ...            ${ue_id}=1
    ...            ${duration}=60
    ...            ${dl_target_avg_percent}=0.98
    ...            ${dl_min_percent}=0.8
    ...            ${ul_target_avg_percent}=${dl_target_avg_percent}
    ...            ${ul_min_percent}=${dl_min_percent}
    power_ue.Collect Tput    ue_type=${UE_TYPE}
    ...                      duration=${duration}
    ...                      check_source=aasyslog
    Run Keyword If    '${dl_target_tp}' != '${EMPTY}'
    ...    run keyword and continue on failure    power_ue.Check Tput
    ...                           ue_type=${UE_TYPE}
    ...                           ue_index=${${ue_id}-1}
    ...                           cells=${cells}
    ...                           direction=dl
    ...                           target_throughput=${dl_target_tp}
    ...                           target_avg_percent=${dl_target_avg_percent}
    ...                           min_percent=${dl_min_percent}
    ...                           check_source=aasyslog
    Run Keyword If    '${ul_target_tp}' != '${EMPTY}'
    ...    run keyword and continue on failure    power_ue.Check Tput
    ...                           ue_type=${UE_TYPE}
    ...                           ue_index=${${ue_id}-1}
    ...                           cells=${cells}
    ...                           direction=ul
    ...                           target_throughput=${ul_target_tp}
    ...                           target_avg_percent=${ul_target_avg_percent}
    ...                           min_percent=${ul_min_percent}
    ...                           check_source=aasyslog

#Attach and Check peak tput
#    [Arguments]    ${cell_id}    ${target_avg_percent}=0.98    ${min_percent}=0.8
#    adjust pa for cell    cell_id=${cell_id}
#    ${active_scf}    download scf
#    ${theoretical_dl}    ${theoretical_ul}    throughput_computation.get_theoretical_throughput
#    ...                                       scf_path=${active_scf}
#    ...                                       cell_id=${cell_id}
#    ${traffic_ul}    Evaluate    int(float(${theoretical_ul})) + 100
#    ${traffic_dl}    Evaluate    int(float(${theoretical_dl})) + 100
#    Prepare and attach UE
#    Start UL And DL traffic    send_traffic_ul=${traffic_ul}M
#    ...                        send_traffic_dl=${traffic_dl}M
#    ${tput_log}    power_ue.collect tput    ue_type=${UE_TYPE}    duration=5m
#    power_ue.check tput    ue_type=${UE_TYPE}
#    ...                    log=${tput_log}
#    ...                    cells=${cell_id}
#    ...                    direction=dl
#    ...                    target_throughput=${theoretical_dl}
#    ...                    target_avg_percent=${target_avg_percent}
#    ...                    min_percent=${min_percent}


