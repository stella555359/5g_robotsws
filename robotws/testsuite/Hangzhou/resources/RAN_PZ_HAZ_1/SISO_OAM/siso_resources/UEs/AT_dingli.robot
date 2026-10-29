*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              author: Zhou Qiang
...              Contact: qiang.1.zhou@nokia-sbell.com
...              Verified equipment: default ue
Library    taf.ue    WITH NAME    ute_ue
Library           ../utils/others.py

*** Variables ***
${IP_EXP_STRING}    ((25[0-5]\\.|2[0-5]\\d\\.|1\\d+\\.|[1-9]\\d?\\.){3}(25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d))
${iperf_server_ip}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${iperf_server_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
${iperf_server_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
${iperf_server_network_interface}    ${tl.appserver.iperf_details.network_interface_address}
${appserver_log_path}    /home/tdlte-tester/UDP
${ue_pc_log_path}    /home

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${index}=${0}    ${reset_sol}=${True}    &{kwargs}
    [Documentation]    This kw is used to Prepare android UE
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ue_index=${0}  |
    ...
    ${ue_config}   get_ue_common_config   ue_info=${tl.ues[${ue_index}]}    index=${index}
    set suite variable    ${cpc_ip}     ${ue_config['cpc_ip']}
    set suite variable    ${cpc_username}    ${ue_config['cpc_username']}
    set suite variable    ${cpc_password}    ${ue_config['cpc_password']}
    ute_ue.require ue    ue_alias=UE_${ue_index}   capabilities=${ue_config["capabilities"][0]}

    Run Keyword If    '${reset_sol}'=='${True}'  AT_dingli.Reset    ue_index=${ue_index}

UE Attach
    [Arguments]    ${bts_id}    ${require_attach_cell_id}    ${ue_index}=${0}    &{kwargs}
    Log    ${bts_id}
    Run Keyword And Ignore Error    AT_dingli.Execute AT    AT+CFUN=0   ue_index=${ue_index}    timeout=${30}

#    Run Keyword And Ignore Error    ute_ue.detach_ue   UE_${ue_index}
    Wait Until Keyword Succeeds    1 min    10 sec    AT_dingli.Execute AT    AT+CFUN=1   ue_index=${ue_index}    timeout=${30}
#    Wait Until Keyword Succeeds    1 min    10 sec    AT_dingli.Execute AT    AT+CGATT=1   ue_index=${ue_index}    timeout=${30}
    sleep    2 sec
    AT_dingli.PPPOE    ue_index=${ue_index}
#    Wait Until Keyword Succeeds    2 min    10 sec    ute_ue.attach_ue   ue_index=${ue_index}
    ${ue_ip}    AT_dingli.Get Ue IP     ue_index=${ue_index}
    ${cell_id}    AT_dingli.Get Cell PCI     ue_index=${ue_index}
    #${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IP
#    ${enb_id}    ute_ue.Get Ue Info     UE_${ue_index}    ENB_ID
#    Log    bts_id: ${enb_id}, Attach cell: ${cell_id}    console=yes
#    should be equal    ${enb_id}    ${bts_id}
    Should Be Equal    ${cell_id}    ${require_attach_cell_id}
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="FAIL"    AT_dingli.Reset    ue_index=${ue_index}

AT_dingli.PPPOE
    [Arguments]    ${ue_index}=${0}    ${timeout}=30
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=at$qcrmcall=1,1,3   timeout=${timeout}
    ${status}    Run Keyword And Return Status    should be equal    ${ret[-1]}    OK
    Run Keyword If    not ${status}    should be equal    ${ret[-2]}    NO CARRIER
    ...    ELSE    Should Be True    ${status}

AT_dingli.Reset
    [Arguments]    ${ue_index}=${0}
#    AT_dingli.Execute AT    at+cfun=15    ue_index=${ue_index}    timeout=${30}
#    Wait Until Keyword Succeeds  3 min  10 sec  AT_dingli.Execute AT  AT  ue_index=${ue_index}  timeout=${30}
    Run Keyword And Ignore Error    ute_ue.software_reset    UE_${ue_index}
    ${count}    Set Variable    ${10}
    WHILE    ${count} != 0
        ${status}    Run Keyword And Return Status    AT_dingli.Execute AT  AT  ue_index=${ue_index}  timeout=${30}
        Exit For Loop If    ${status}
        ${count}    Evaluate    ${count} - 1
        sleep    5s
    END
    Should Be True    ${status}


AT_dingli.Execute AT
    [Arguments]    ${cmd}    ${ue_index}=${0}    ${timeout}=${4}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=${cmd}   timeout=${timeout}
    should be equal    ${ret[-1]}    OK
    [Return]   ${ret[1]}

AT_dingli.Get Ue IP
    [Arguments]    ${ue_index}=${0}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+CGPADDR=1
    should be equal    ${ret[-1]}    OK
    ${ue_ip}    should match regexp    ${ret[1]}    ${IP_EXP_STRING}
    [Return]    ${ue_ip[0]}

AT_dingli.Get Cell PCI
    [Arguments]    ${ue_index}=${0}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+GTCCINFO?
    should be equal    ${ret[-1]}    OK
    ${cell_info}    Split String    ${ret[3]}    ,
    ${pci}    Convert To Integer    ${cell_info[7]}    base=16
    ${pci}    Convert To String    ${pci}
    [Return]    ${pci}


################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    ${bts_id}    ${require_attach_cell_id}    ${ue_index}=${0}    &{kwargs}

    Log    ${bts_id}
    ${ue_ip}    AT_dingli.Get Ue IP     ue_index=${ue_index}
    ${cell_id}    AT_dingli.Get Cell PCI     ue_index=${ue_index}
#    ${enb_id}    ute_ue.Get Ue Info     UE_${ue_index}    ENB_ID
#    Log    bts_id: ${enb_id}, Attach cell: ${cell_id}    console=yes
#    should be equal    ${enb_id}    ${bts_id}
    Should Be Equal    ${cell_id}    ${require_attach_cell_id}

################################## STEP3: START DATA TRANSFER ##################################
Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${tag}
	...            ${require_attach_cell_id}    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1024B
    ...            ${protocol}=udp    ${data_amount}=1M
    ...            &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    Log    ${interval}
    Log    ${buffer_size}
    Log    ${protocol}
    Log    ${data_amount}
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22
    ${ue_pc_info}    Create List    ${cpc_ip}     ${cpc_username}    ${cpc_password}    22
    ${UL_log_path}    Set Variable  ${appserver_log_path}${/}${require_attach_cell_id}_udp_ul_${tag}.log
    ${local_UL_log_path}    Set Variable    ${test_logs_dir_path}${/}${require_attach_cell_id}_udp_ul_${tag}.log
    ${DL_log_path}    Set Variable    ${ue_pc_log_path}${/}${require_attach_cell_id}_udp_dl_${tag}.log

    ${ue_ip}    AT_dingli.Get Ue IP     ue_index=${ue_index}


    Run Keyword If    '${direction}' == 'dl'    Run Keywords    siso_data.Start UDP Iperf Server
    ...                                                                     ${ue_pc_info}
    ...                                                                     ${iperf_port}
    ...                                                                     ${DL_log_path}
    ...                                                                     buffer_size=82.0K
    ...                                                                     bind_host=${ue_ip}
    ...                                                                     alias=dl_server
    ...    AND        siso_data.Start UDP Iperf Client                      ${iperf_pc_info}
    ...                                                                     ${ue_ip}
    ...                                                                     ${iperf_port}
    ...                                                                     band_width=${throughput}
    ...                                                                     duration=${duration}
    ...                                                                     bind_host=${iperf_server_network_interface}
    ...                                                                     ttl=64
    ...                                                                     alias=dl_client
    ...    AND    Set Test Variable    ${DL_PORT}    ${iperf_port}
    ...    ELSE IF    '${direction}' == 'ul'    Run Keywords    siso_data.Start UDP Iperf Server
    ...                                                                     ${iperf_pc_info}
    ...                                                                     ${iperf_port}
    ...                                                                     ${UL_log_path}
    ...                                                                     ${iperf_server_network_interface}
    ...                                                                     buffer_size=82.0K
    ...                                                                     alias=ul_server
    ...    AND        siso_data.Start UDP Iperf Client                      ${ue_pc_info}
    ...                                                                     ${iperf_server_network_interface}
    ...                                                                     ${iperf_port}
    ...                                                                     band_width=${throughput}M
    ...                                                                     bind_host=${ue_ip}
    ...                                                                     ttl=64
    ...                                                                     duration=120
    ...                                                                     alias=ul_client
    ...    AND    Set Test Variable    ${UL_PORT}    ${iperf_port}

Check Peak Throughput
    [Arguments]    ${theory_dl_peak}    ${theory_ul_peak}    ${tag}    ${require_attach_cell_id}
    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...            ${acceptable_tput_percentage}=5%    ${is_need_to_capture_log}=${False}
    [Documentation]    Check throughput from started traffic.
    ...  :param  theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
    ...  :param  theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec  E.G 262.0
    ...  :param  total_time: is the duration time in which the throughput need to be checked. The time unit is second.
    ...  :param  interval: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...  :param  duration_time_for_once: is the duration time for calculating average tput in one capturing
    ...  :param  acceptable_tput_percentage: The acceptable tput percentage of throughput.
    ...                                      Will check if Throughput > theory * acceptable_tput_percentage.
    ...  :param  is_need_to_capture_log: will capture event trace log if set to ${True}
    Log    ${total_time}
    Log    ${interval}
    Log    ${is_need_to_capture_log}
    ${UL_log_path}    Set Variable  ${appserver_log_path}${/}${require_attach_cell_id}_udp_ul_${tag}.log
    ${local_UL_log_path}    Set Variable    ${test_logs_dir_path}${/}${require_attach_cell_id}_udp_ul_${tag}.log
    ${DL_log_path}    Set Variable    ${ue_pc_log_path}${/}${require_attach_cell_id}_udp_dl_${tag}.log
    ${local_DL_log_path}    Set Variable    ${test_logs_dir_path}${/}${require_attach_cell_id}_udp_dl_${tag}.log
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22
    ${ue_pc_info}    Create List    ${cpc_ip}     ${cpc_username}    ${cpc_password}    22
    sleep    ${duration_time_for_once}
    Sftp Download    ${iperf_server_ip}    22
    ...              ${iperf_server_username}    ${iperf_server_password}
    ...              ${UL_log_path}    ${local_UL_log_path}
    ${real_ul_tput}=    Get Iperf Throughput    ${local_UL_log_path}
    Log    ${real_ul_tput}
    Sftp Download    ${cpc_ip}    22
    ...              ${cpc_username}    ${cpc_password}
    ...              ${DL_log_path}    ${local_DL_log_path}
    ${real_dl_tput}=    Get Iperf Throughput    ${local_DL_log_path}
    Log    ${real_dl_tput}
    ${acceptable_tput_percentage}    Strip String    ${acceptable_tput_percentage}    characters=%

    ${check_ul}    Evaluate    ${theory_ul_peak} * 1024 * (1-${acceptable_tput_percentage}/100)
    ${check_dl}    Evaluate    ${theory_dl_peak} * 1024 * (1-${acceptable_tput_percentage}/100)

    Should Be True    ${real_ul_tput} > ${check_ul}
    Should Be True    ${real_dl_tput} > ${check_dl}

    [Return]    ${real_dl_tput}    ${real_ul_tput}
    [Teardown]    Run Keywords    AT_dingli.Stop traffic    dl    ${DL_PORT}
    ...    AND    AT_dingli.Stop traffic    ul    ${UL_PORT}
    ...    AND    Remote Execute Cmd    ${iperf_pc_info}    rm -rf ${UL_log_path}
    ...    AND    Remote Execute Cmd    ${ue_pc_info}    rm -rf ${DL_log_path}

AT_dingli.Stop traffic
    [Arguments]    ${direction}     ${iperf_port}=default    ${iperf_type}=via_command    ${protocol}=udp    &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    Log    ${iperf_type}
    Log    ${protocol}
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22
    ${ue_pc_info}    Create List    ${cpc_ip}     ${cpc_username}    ${cpc_password}    22
    Run Keyword If    '${direction}' == 'dl'    Run Keywords    siso_data.Stop Iperf Server    ${ue_pc_info}
    ...    ${iperf_port}    alias=dl_server
    ...    AND    siso_data.Stop Iperf Client    ${iperf_pc_info}    ${iperf_port}    alias=dl_client
    ...    ELSE IF    '${direction}' == 'ul'    Run Keywords    siso_data.Stop Iperf Server    ${iperf_pc_info}
    ...    ${iperf_port}    alias=ul_server
    ...    AND    siso_data.Stop Iperf Client    ${ue_pc_info}    ${iperf_port}    alias=ul_client

#Start traffic
#    [Arguments]    ${direction}    ${duration}   ${throughput}    ${tag}
#	...            ${require_attach_cell_id}    ${iperf_port}=default
#    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1024B
#    ...            ${protocol}=udp    ${data_amount}=1M
#    ...            &{kwargs}
#    [Documentation]    Start data transfer for L3 call test.
#    ...  :param  direction: The traffic direction, ul or dl.
#    ...  :param  duration: Duration of traffic
#    ...  :param  throughput: Throughput of new data transfer
#    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
#    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
#    ${ue_ip}    AT_dingli.Get Ue IP     ue_index=${ue_index}
#    ${cell_id}    AT_dingli.Get Cell PCI     ue_index=${ue_index}
#    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+CGMM
#    Sleep     5s
#
#    ${out_current_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_${direction}
#    Run Keyword And Continue On Failure    ute_ue.Start Data Transfer    ${out_current_dt_id}
#    ...    UE_${ue_index}    ${direction}    duration=${duration}    protocol=udp
#    ...    throughput=${throughput}    port=${iperf_port}   packet_size=${buffer_size}
#
#
#Check Peak Throughput
#    [Arguments]    ${theory_dl_peak}    ${theory_ul_peak}    ${tag}    ${require_attach_cell_id}
#    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
#    ...            ${acceptable_tput_percentage}=5%    ${is_need_to_capture_log}=${False}
#    [Documentation]    Check throughput from started traffic.
#    ...  :param  theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
#    ...  :param  theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec  E.G 262.0
#    ...  :param  total_time: is the duration time in which the throughput need to be checked. The time unit is second.
#    ...  :param  interval: refers to the sleep time between tput checking, can be mins, hours, or secs
#    ...  :param  duration_time_for_once: is the duration time for calculating average tput in one capturing
#    ...  :param  acceptable_tput_percentage: The acceptable tput percentage of throughput.
#    ...                                      Will check if Throughput > theory * acceptable_tput_percentage.
#    ...  :param  is_need_to_capture_log: will capture event trace log if set to ${True}
#    ${out_current_dl_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_dl
#    ${out_current_ul_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_ul
##    ute_ue.Check Data Transfer Is Alive    ${out_current_dl_dt_id}
##    ute_ue.Check Data Transfer Is Alive    ${out_current_ul_dt_id}
#    ute_ue.Await Data Transfer Finish    ${out_current_dl_dt_id}
#    ute_ue.Await Data Transfer Finish    ${out_current_ul_dt_id}
#    ${ul_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_ul_dt_id}
#    ${dl_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_dl_dt_id}
#
#
#    Ue Review Iperf Reports    ${out_current_dl_dt_id}
#    Ue Review Iperf Reports    ${out_current_ul_dt_id}
#    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
#    ...    ${out_current_dl_dt_id}    ${theory_dl_peak}Mbits/sec    ${acceptable_tput_percentage}
#
#    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
#    ...    ${out_current_ul_dt_id}    ${theory_ul_peak}Mbits/sec    ${acceptable_tput_percentage}
#
#    Log    Avarage throughput(${require_attach_cell_id}): ${ul_avg_throughput} Kbits/sec,${dl_avg_throughput} Kbits/sec
#    ...    console=yes
#
#    [Return]    ${ul_avg_throughput}    ${dl_avg_throughput}
#    [Teardown]   Run Keywords   ute_ue.Stop Data Transfer    ${out_current_dl_dt_id}   AND
#    ...     ute_ue.Stop Data Transfer    ${out_current_ul_dt_id}

UE Detach
    [Arguments]    ${ue_index}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for detach
    ute_ue.detach_ue    UE_${ue_index}
