*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources_aic/DevHZ5_resource_aic_ST.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    throughput_computation

*** Variables ***
${UE_TYPE}    huawei_sigspark

*** Keywords ***
Prepare UEs
    [Documentation]    After prepare UEs, all UEs will be in detach state.
    ...    For mutiple UEs, suggest to use this keyword at first, and then attach UEs. Otherwise
    ...        1) maybe some of UEs are attached unexpected,
    ...        2) spark GUI log will be cleared after power_ue.Prepare UE
    ...    Note: cell signal must be opened before this keyword, otherwise at command will have no repsonse
    [Arguments]    ${ue_ids}=1,2    ${get_spark_license}=${true}
#    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
    @{ues}    Split String    ${ue_ids}    ,
    FOR    ${ue_id}    IN    @{ues}
        wait until keyword succeeds    6x    10s
        ...    power_ue.Prepare UE    ue_type=${UE_TYPE}
        ...                           ue_index=${${ue_id}-1}
        ...                           get_spark_license=${get_spark_license}
        ...                           force_check_ue=${True}
    END

Prepare and attach UE
    [Documentation]    this keyword includes prepare ue and attach ue. For single UE, suggest to use this keyword.
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${get_spark_license}=${true}    ${apn}=mdrb.nokia.com
    Prepare UEs    ue_ids=${ue_id}    get_spark_license=${get_spark_license}
    run keyword and ignore error    start to capture gnb bip log aic   attach_ue${ue_id}
    Attach UE    ${ue_id}    ${attach_mode}     ${apn}
    [Teardown]    run keyword and ignore error    stop to capture gnb bip log aic    attach_ue${ue_id}

Attach UE
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${apn}=mdrb.nokia.com
    # fix AT command stuck issue,AT+QRNRU must be set to 1 after firmware update
    run keyword and ignore error    Execute AT Command    AT+QRNRU=1    ${ue_id}
    # set APN
    Execute AT Command    AT+CGDCONT=1,"IPV4V6","${apn}"    ${ue_id}
    # set attach mode
     Run Keyword If    '${attach_mode}' == '5G_SA'     Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",2    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",NR5G    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '5G_NSA'    Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",1    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",auto    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '4G'       Execute AT Command    AT+QNWPREFCFG="mode_pref",LTE    ue_id=${ue_id}
    ...    ELSE    Fail    not support attach_mode=${attach_mode}
#    wait until keyword succeeds    ${retry_times}x    10s    _Attach For Once    ${ue_id}    ${attach_mode}    ${apn}
    ${attach_status1}    run keyword and return status    _Attach With AT POPO    ${ue_id}    ${attach_mode}    ${apn}
    return from keyword if    ${attach_status1}
    _Attach With AT Reboot    ${ue_id}    ${attach_mode}    ${apn}


Attach UE Should Fail
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${apn}=mdrb.nokia.com
    # fix AT command stuck issue,AT+QRNRU must be set to 1 after firmware update
    run keyword and ignore error    Execute AT Command    AT+QRNRU=1    ${ue_id}
    # set APN
    Execute AT Command    AT+CGDCONT=1,"IPV4V6","${apn}"    ${ue_id}
    # set attach mode
     Run Keyword If    '${attach_mode}' == '5G_SA'     Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",2    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",NR5G    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '5G_NSA'    Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",1    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",auto    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '4G'       Execute AT Command    AT+QNWPREFCFG="mode_pref",LTE    ue_id=${ue_id}
    ...    ELSE    Fail    not support attach_mode=${attach_mode}
    ${attach_status}    run keyword and return status    _Attach With AT POPO    ${ue_id}    ${attach_mode}    ${apn}
    should not be true    ${attach_status}

_Print Events
    [Arguments]     ${ue_id}=1
#    run keyword and ignore error    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    ${event}    create list    SA PDU Establish Accept
    run keyword and ignore error    spark.get_event_count_on_ue    index=${${ue_id}-1}
    ...                                                            event_name=${event}
    ...                                                            ue_alias=UE_${${ue_id}-1}

_Attach With Force Cmd
    [Arguments]    ${ue_id}    ${attach_mode}    ${apn}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${${ue_id}-1}
    ${attach_rc}    power_ue.UE Attach      ue_type=${UE_TYPE}
    ...                                     ue_index=${${ue_id}-1}
    ...                                     attach_mode=${attach_mode}
    should be equal as integers    ${attach_rc}    0
    ${apn}    Remove String    ${apn}    .
    ${ue_mode}    set variable if    '${attach_mode}' == '5G_SA'    SA    ${attach_mode}
    spark.get_ue_ip_on_ue    ue_alias=UE_${${ue_id}-1}
    ...                      apnaddress=${apn}
    ...                      ue_mode=${ue_mode}
    ...                      timeout=60
    Get UE RNTI    ${ue_id}
    [Teardown]    _Print Events    ${ue_id}

_Attach With AT POPO
    [Arguments]    ${ue_id}    ${attach_mode}    ${apn}
    Execute AT Command    AT+CFUN=0   ${ue_id}
    Sleep    30s
    Execute AT Command    AT+CFUN=1   ${ue_id}
    Sleep    30s
    ${apn}    Remove String    ${apn}    .
    ${ue_mode}    set variable if    '${attach_mode}' == '5G_SA'    SA    ${attach_mode}
    spark.get_ue_ip_on_ue    ue_alias=UE_${${ue_id}-1}
    ...                      apnaddress=${apn}
    ...                      ue_mode=${ue_mode}
    ...                      timeout=60
    Get UE RNTI    ${ue_id}
    [Teardown]    _Print Events    ${ue_id}

_Attach With AT Reboot
    [Arguments]    ${ue_id}    ${attach_mode}    ${apn}
    _Run AT Cmd    AT+CFUN=1,1   ${ue_id}
    Sleep    60s
    ${apn}    Remove String    ${apn}    .
    ${ue_mode}    set variable if    '${attach_mode}' == '5G_SA'    SA    ${attach_mode}
    spark.get_ue_ip_on_ue    ue_alias=UE_${${ue_id}-1}
    ...                      apnaddress=${apn}
    ...                      ue_mode=${ue_mode}
    ...                      timeout=60
    Get UE RNTI    ${ue_id}
    [Teardown]    _Print Events    ${ue_id}

_Attach For Once
    [Arguments]    ${ue_id}    ${attach_mode}    ${apn}
#    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${${ue_id}-1}
#    ${attach_rc}    power_ue.UE Attach      ue_type=${UE_TYPE}
#    ...                                     ue_index=${${ue_id}-1}
#    ...                                     attach_mode=${attach_mode}
#    run keyword if  "${attach_rc}" != "0"    Execute AT Command    AT+CFUN=1,1   ${ue_id}
#    run keyword if  "${attach_rc}" != "0"    Sleep    30s
    Execute AT Command    AT+CFUN=1,1   ${ue_id}
    Sleep    60s
    ${ue_mode}    set variable if    '${attach_mode}' == '5G_SA'    SA    ${attach_mode}
#    run keyword and ignore error    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    ${apn}    Remove String    ${apn}    .
    spark.get_ue_ip_on_ue    ue_alias=UE_${${ue_id}-1}
    ...                      apnaddress=${apn}
    ...                      ue_mode=${ue_mode}
    ...                      timeout=60
    Get UE RNTI    ${ue_id}
    [Teardown]    _Print Events    ${ue_id}

_Get UE RNTI For Once
    [Arguments]    ${ue_id}=1
    ${params}    create list    NR CRNTI    NR PCI    NR SSB RSRP[dBm]
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=UE_${${ue_id}-1}    param=${params}
    ${rnti_var_name}    Set Variable   UE${ue_id}_RNTI
    Set Test Variable    ${${rnti_var_name}}    ${value_list[0]}
    Set Test Variable    ${ue_param_value}    ${value_list}
    Run Keyword If    '${value_list[0]}' == ''    Fail    fail to attach UE${ue_id}

Get Params Value From Spark
    [Arguments]    ${ue_id}=1    ${params}=NR PCI
    ${params}    remove empty from list    ${params}
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=UE_${${ue_id}-1}    param=${params}
    [Return]    ${value_list}

Check Serving Cell
    [Arguments]    ${ue_id}    ${cell_id}
    ${pci}    get scf parameter value    NRCELL-${cell_id}:physCellId
    ${value_list}    Get Params Value From Spark    ${ue_id}    params=NR PCI
    should be equal    ${value_list[0]}    ${pci}

Get UE RNTI
    [Arguments]    ${ue_id}=1
    wait until keyword succeeds    12x    10s    _Get UE RNTI for Once    ${ue_id}

Detach UE
    [Arguments]    ${ue_id}=1
#    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
    ${params}    create list    NR CRNTI    NR Cell ID    NR SSB RSRP[dBm]
    spark.get_parm_value_on_ue       ue_alias=UE_${${ue_id}-1}    param=${params}
#    power_ue.UE Detach    ue_type=${UE_TYPE}
#    ...                   ue_index=${${ue_id}-1}
    Execute AT Command    AT+CFUN=0   ${ue_id}

Start UL Traffic
    [Arguments]    ${ue_id}=1
    ...            ${send_traffic}=100M
    ...            ${send_duration}=7200
    ...            ${ue_mode}=SA
    ...            ${apn_address}=mdrbnokiacom
    ...            ${iperf_port}=default    # get from init file
    ...            ${interval_time}=1
    ...            ${buffer_size_Byte}=1400B
#    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
#    run keyword and ignore error    Get Commercial UE IP     ue_index=${${ue_id}-1}
    run keyword and ignore error    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    power_ue.Start traffic    ue_type=${UE_TYPE}
    ...                       direction=ul
    ...                       ue_index=${${ue_id}-1}
    ...                       ue_mode=${ue_mode}
    ...                       throughput=${send_traffic}bits/sec
    ...                       duration=${send_duration}
    ...                       connection_type=current
    ...                       apn_address=${apn_address}
    ...                       iperf_port=${iperf_port}
    ...                       interval=${interval_time}
    ...                       buffer_size=${buffer_size_Byte}
Start DL Traffic
    [Arguments]    ${ue_id}=1
    ...            ${send_traffic}=500M
    ...            ${send_duration}=7200
    ...            ${ue_mode}=SA
    ...            ${apn_address}=mdrbnokiacom
    ...            ${iperf_port}=default
#    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
#    run keyword and ignore error    Get Commercial UE IP     ue_index=${${ue_id}-1}
    run keyword and ignore error    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    power_ue.Start traffic    ue_type=${UE_TYPE}
    ...                       direction=dl
    ...                       ue_mode=${ue_mode}
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
    ...            ${ue_mode}=SA
    ...            ${apn_address}=mdrbnokiacom
    ...            ${iperf_port}=default
#    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
#    run keyword and ignore error    Get Commercial UE IP     ue_index=${${ue_id}-1}
    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    power_ue.Start traffic    ue_type=${UE_TYPE}
    ...                       direction=ul
    ...                       ue_index=${${ue_id}-1}
    ...                       ue_mode=${ue_mode}
    ...                       throughput=${send_traffic_ul}bits/sec
    ...                       duration=${send_duration}
    ...                       connection_type=current
    ...                       apn_address=${apn_address}
    ...                       iperf_port=${iperf_port}
    power_ue.Start traffic    ue_type=${UE_TYPE}
    ...                       direction=dl
    ...                       ue_mode=${ue_mode}
    ...                       throughput=${send_traffic_dl}bits/sec
    ...                       duration=${send_duration}
    ...                       ue_index=${${ue_id}-1}
    ...                       apn_address=${apn_address}
    ...                       iperf_port=${iperf_port}

Stop DL Traffic
    [Arguments]    ${ue_id}=1    ${apn_address}=mdrbnokiacom
#    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
    power_ue.Stop traffic    ue_type=${UE_TYPE}
    ...                      direction=dl
    ...                      ue_index=${${ue_id}-1}
    ...                      apn_address=${apn_address}

Stop UL Traffic
    [Arguments]    ${ue_id}=1    ${apn_address}=mdrbnokiacom
#    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
    power_ue.Stop traffic    ue_type=${UE_TYPE}
    ...                      direction=ul
    ...                      ue_index=${${ue_id}-1}
    ...                      apn_address=${apn_address}

Stop UL And DL traffic
    [Arguments]    ${ue_id}=1    ${apn_address}=mdrbnokiacom
    #    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${UE_TYPE}
    ...                      direction=dl
    ...                      ue_index=${${ue_id}-1}
    ...                      apn_address=${apn_address}
    #    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${${ue_id}-1}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${UE_TYPE}
    ...                      direction=ul
    ...                      ue_index=${${ue_id}-1}
    ...                      apn_address=${apn_address}

Attach and Check peak tput
    [Arguments]    ${cell_id}    ${ue_id}=1    ${target_avg_percent}=0.98    ${min_percent}=0.8    &{mod_params}
    adjust pa for cell    cell_id=${cell_id}
    ${active_scf}    download scf
    ${theoretical_dl}    ${theoretical_ul}    throughput_computation.get_theoretical_throughput
    ...                                       scf_path=${active_scf}
    ...                                       cell_id=${cell_id}
    ...                                       mod_params=${mod_params}
    ${traffic_ul}    Evaluate    int(float(${theoretical_ul})) + 100
    ${traffic_dl}    Evaluate    int(float(${theoretical_dl})) + 100
    Prepare and attach UE
    Start UL And DL traffic    send_traffic_ul=${traffic_ul}M
    ...                        send_traffic_dl=${traffic_dl}M
    ${tput_log}    power_ue.collect tput    ue_type=${UE_TYPE}    duration=5m
    power_ue.check tput    ue_type=${UE_TYPE}
    ...                    ue_index=${${ue_id}-1}
    ...                    log=${tput_log}
    ...                    cells=${cell_id}
    ...                    direction=dl
    ...                    target_throughput=${theoretical_dl}
    ...                    target_avg_percent=${target_avg_percent}
    ...                    min_percent=${min_percent}

Collect And Check Tput
    [Arguments]    ${cells}
    ...            ${ue_id}=1
    ...            ${dl_target_tp}=${EMPTY}
    ...            ${ul_target_tp}=${EMPTY}
    ...            ${duration}=30
    ...            ${dl_target_avg_percent}=0.80
    ...            ${dl_min_percent}=0.50
    ...            ${ul_target_avg_percent}=${dl_target_avg_percent}
    ...            ${ul_min_percent}=${dl_min_percent}
    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    ue_index=${${ue_id}-1}    duration=${duration}
    Run Keyword If    '${dl_target_tp}' != '${EMPTY}'
    ...    run keyword and continue on failure    power_ue.Check Tput
    ...                           ue_type=${UE_TYPE}
    ...                           ue_index=${${ue_id}-1}
    ...                           log=${tput_log}
    ...                           cells=${cells}
    ...                           direction=dl
    ...                           target_throughput=${dl_target_tp.lower().rstrip("m")}
    ...                           target_avg_percent=${dl_target_avg_percent}
    ...                           min_percent=${dl_min_percent}
    Run Keyword If    '${ul_target_tp}' != '${EMPTY}'
    ...    run keyword and continue on failure    power_ue.Check Tput
    ...                           ue_type=${UE_TYPE}
    ...                           ue_index=${${ue_id}-1}
    ...                           log=${tput_log}
    ...                           cells=${cells}
    ...                           direction=ul
    ...                           target_throughput=${ul_target_tp.lower().rstrip("m")}
    ...                           target_avg_percent=${ul_target_avg_percent}
    ...                           min_percent=${ul_min_percent}

_Run AT Cmd
    [Arguments]    ${cmd}    ${ue_id}
    ${ue_index}    Set Variable    ${${ue_id}-1}
    ${resp}    spark.send AT command On UE     command=${cmd}     ue_alias=UE_${ue_index}
    list should contain value    ${resp.split()}    OK
    [Return]    ${resp}

Execute AT Command
    [Arguments]    ${cmd}    ${ue_id}=1
    ${resp}    wait until keyword succeeds    3x    20sec    _Run AT Cmd    ${cmd}    ${ue_id}
    [Return]    ${resp}

Make VONR call
    [Arguments]    ${ue_id}=1
    ${ue_index}    Set Variable    ${${ue_id}-1}
    Execute AT Command     cmd=ATD+6688;     ue_id=${ue_id}
#    ${Vonr_call_status}    spark.get_Vonr_call_status_on_ue
#    ...      ue_alias=UE_${ue_index}   param={"LastEventIndex":0}
#    run keyword if    ${Vonr_call_status}    sleep    10s
#    ...    ELSE  Fail    VONR call failed

Hang Up VoNR Call
    [Arguments]    ${ue_id}=1
    ${ue_index}    Set Variable    ${${ue_id}-1}
    Execute AT Command     cmd=ATH     ue_id=${ue_id}
#    ${Vonr_release_status}    spark.get_Vonr_call_release_status_on_ue
#    ...      ue_alias=UE_${ue_index}   param={"LastEventIndex":0}
#    run keyword if    ${Vonr_release_status}    sleep    10s
#    ...    ELSE  Fail    VONR call release failed
