*** Settings ***
Documentation
...    author: Ma Keyun
...    contact: keyun.ma@nokia.com
...    squal group: SG03
...    feature: CB09489

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...                            AND    Get gnb release info

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009489/Resources/CB009489_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
*** Variables ***
${log_name}    log_name.pcap
${filename_attach_gnb}    filename_attach_gnb.pcap
@{scell_index_list_cell1}    ${1}
@{extgnb_index_gnb1}    ${0}
@{gnb_list}    ${0}
${Send_Tput_DL_T_T}    1000M
${expected_tput_dl_T}    762
${att_ipaddr}    ${tl.attenuator[0].ip_addr}
${UE_TYPE}    ${tl.ues[0].capabilities[0]}
# TL2467
${5GCell_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5GCell_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${5GCell_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[6].port_no}
${5GCell_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[7].port_no}

@{5GCell_ANTS}    ${5GCell_ANT1}    ${5GCell_ANT2}    ${5GCell_ANT3}    ${5GCell_ANT4}
@{5GCell_VALUES}    ${28}    ${28}    ${28}    ${28}

*** Test Cases ***
CB009489_RRM_11_2CC Carrier Aggregation with non_continuse frequency
    [Documentation]
    ...    1. UE attach to TDD cell as pcell
    ...    2. check 2CC Carrier Aggregation with non_continuse frequency
    ...    3. LOCK cell-1
    ...    4. Trigger UE UDP DL/UL Peak Tput. check DL/UL Peak Tput, keep the same.
    ...    5. UE detach

    [Tags]    CB09489    CRT_TRUNK
    Prerequisite
    UE Attach With Traffic
    Check 2CC DL tput     tput_dl_pcell=${expected_tput_dl_T}    tput_dl_scell=${expected_tput_dl_T}
    ...    scellid=1    pcellid=3    gnb_prime=${0}    gnb_external=${0}
    Lock Cell1
    Check peak throughput on DL
    Detach UE
    Unlock FDD LTE Cell
    Unlock Cell1
    [Teardown]    CB009489 Teardown

*** Keywords ***
Lock Cell1
    Delta Commission Parameters  NRCELL-1:administrativeState=Locked
    Cells Should Be OnAir    cell_id=3

Unlock Cell1
    Delta Commission Parameters  NRCELL-1:administrativeState=Unlocked
    Cells Should Be OnAir    cell_id=1
Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,4546,4569
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4546
    AlarmWatchdog.add_allow_alarms    fault_id=4569
    Online modify parmeters     parameters_to_update=${PARAMS_TO_MODIFY_CB009489_for_GNB}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup

Detach UE
    [Arguments]    ${ue_id}=1
    Stop DL Traffic
    ${params}    create list    NR CRNTI    NR Cell ID    NR SSB RSRP[dBm]
    spark.get_parm_value_on_ue       ue_alias=UE_${${ue_id}-1}    param=${params}
    Execute AT Command    AT+CFUN=0   ${ue_id}
Unlock FDD LTE Cell
    Online modify parmeters     parameters_to_update=${Recover_PARAMS_CB009489}    skip_parameter_relation_errors=False
UE Attach With Traffic
    log to console    set attenuation for 5G cell
    log to console    ${att_ipaddr}
    Set the attenuation value of ports simultaneously
    ...    att_ports=${5GCell_ANTS}    values=${5GCell_VALUES}    att_ipaddr=${att_ipaddr}
    log to console    ue attach to 5G cell-3
    Start capture gNB log on master    filename=${log_name}
    Prepare and attach UE For 5G Cell    ue_id=1    attach_mode=5G_SA    apn=dxdata1
    Start DL Traffic
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name}
Prepare and attach UE For 5G Cell
    [Documentation]    this keyword includes prepare ue and attach ue. For single UE, suggest to use this keyword.
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${get_spark_license}=${true}    ${apn}=mdrb.nokia.com
    Prepare UEs For 5G Cell   ue_ids=1    get_spark_license=${get_spark_license}
    Attach UE For 5G Cell    ${ue_id}    ${attach_mode}     ${apn}

Prepare UEs For 5G Cell
    [Documentation]    After prepare UEs, all UEs will be in detach state.
    ...    For mutiple UEs, suggest to use this keyword at first, and then attach UEs. Otherwise
    ...        1) maybe some of UEs are attached unexpected,
    ...        2) spark GUI log will be cleared after power_ue.Prepare UE
    ...    Note: cell signal must be opened before this keyword, otherwise at command will have no repsonse
    [Arguments]    ${ue_ids}=1    ${get_spark_license}=${true}
    @{ues}    Split String    ${ue_ids}    ,
    FOR    ${ue_id}    IN    @{ues}
        wait until keyword succeeds    2x    10s
        ...    power_ue.Prepare UE    ue_type=${UE_TYPE}
        ...                           ue_index=${${ue_id}-1}
        ...                           get_spark_license=${get_spark_license}
        ...                           force_check_ue=${True}
    END

Attach UE For 5G Cell
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${apn}=mdrb.nokia.com    ${attach_way}=popo_atreboot
    run keyword and ignore error    Execute AT Command    AT+QRNRU=1    ${ue_id}
    # set APN
    Execute AT Command    AT+CGDCONT=1,"IPV4V6","${apn}"    ${ue_id}
    # set attach mode
     Run Keyword If    '${attach_mode}' == '5G_SA'     Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",2    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",NR5G    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="ue_capability_band"    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '5G_NSA'    Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",1    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",auto    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="ue_capability_band"    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '4G'       Execute AT Command    AT+QNWPREFCFG="mode_pref",LTE    ue_id=${ue_id}
    ...    ELSE    Fail    not support attach_mode=${attach_mode}
    IF    '${attach_way.lower()}' == 'popo'
        _Attach With AT POPO    ${ue_id}    ${attach_mode}    ${apn}
    ELSE IF    '${attach_way.lower()}' == 'atreboot'
        _Attach With AT Reboot    ${ue_id}    ${attach_mode}    ${apn}
    ELSE
        ${attach_status1}    run keyword and return status    _Attach With AT POPO    ${ue_id}    ${attach_mode}    ${apn}
        return from keyword if    ${attach_status1}
        _Attach With AT Reboot    ${ue_id}    ${attach_mode}    ${apn}
    END
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

Execute AT Command
    [Arguments]    ${cmd}    ${ue_id}=1
    ${resp}    wait until keyword succeeds    3x    20sec    _Run AT Cmd    ${cmd}    ${ue_id}
    [Return]    ${resp}

_Run AT Cmd
    [Arguments]    ${cmd}    ${ue_id}
    ${ue_index}    Set Variable    ${${ue_id}-1}
    ${resp}    spark.send AT command On UE     command=${cmd}     ue_alias=UE_${ue_index}
    list should contain value    ${resp.split()}    OK
    [Return]    ${resp}

_Print Events
    [Arguments]     ${ue_id}=1
    ${event}    create list    LTE RACH Complete
    run keyword and ignore error    spark.get_event_count_on_ue    index=${${ue_id}-1}
    ...                                                            event_name=${event}
    ...                                                            ue_alias=UE_${${ue_id}-1}
Get UE RNTI
    [Arguments]    ${ue_id}=1
    wait until keyword succeeds    16x    10s    _Get UE RNTI for Once    ${ue_id}


_Get UE RNTI For Once
    [Arguments]    ${ue_id}=1
    ${params}    create list    NR CRNTI    NR PCI    NR SSB RSRP[dBm]
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=UE_${${ue_id}-1}    param=${params}
    ${rnti_var_name}    Set Variable   UE${ue_id}_RNTI
    Set Test Variable    ${${rnti_var_name}}    ${value_list[0]}
    Set Test Variable    ${ue_param_value}    ${value_list}
    Run Keyword If    '${value_list[0]}' == ''    Fail    fail to attach UE${ue_id}

Start DL Traffic
    [Arguments]    ${ue_id}=1
    ...            ${send_traffic}=800M
    ...            ${send_duration}=7200
    ...            ${ue_mode}=SA
    ...            ${apn_address}=dxdata1
    ...            ${iperf_port}=default
    run keyword and ignore error    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    power_ue.Start traffic    ue_type=${UE_TYPE}
    ...                       direction=dl
    ...                       ue_mode=${ue_mode}
    ...                       throughput=${send_traffic}bits/sec
    ...                       duration=${send_duration}
    ...                       ue_index=${${ue_id}-1}
    ...                       apn_address=${apn_address}
    ...                       iperf_port=${iperf_port}

Stop DL Traffic
    [Arguments]    ${ue_id}=1    ${apn_address}=dxdata1
    power_ue.Stop traffic    ue_type=${UE_TYPE}
    ...                      direction=dl
    ...                      ue_index=${${ue_id}-1}
    ...                      apn_address=${apn_address}

Check 2CC DL tput
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${scellid}=1   ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${0}    ${ue_type}=${ue_type}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_prime}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}    gnb_index=${gnb_external}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell}    Create list  ${nrcellid_scell}
    ${tput_log_prime}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_prime}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell}

Check peak throughput on DL
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T}    ${pcellid}=1    ${gnb_prime}=${0}    ${ue_type}=${ue_type}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_prime}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${tput_log_prime}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_prime}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}

CB009489 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    AlarmWatchdog.remove_allow_alarms    fault_id=4546
    AlarmWatchdog.remove_allow_alarms    fault_id=4569
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot