*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              author: Zhou Qiang
...              Contact: qiang.1.zhou@nokia-sbell.com
...              Verified equipment: default ue
Library    taf.ue    WITH NAME    ute_ue



*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${reset_sol}=${True}    &{kwargs}
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
    ${ue_cap} =    set variable    ${tl.ues[${ue_index}].capabilities[0]}
    ute_ue.require ue    ue_alias=UE_${ue_index}   capabilities=${ue_cap}

    Run Keyword If    '${reset_sol}'=='${True}'  ute_ue.reboot_ue    UE_${ue_index}

UE Attach
    [Arguments]    ${require_attach_cell_id}    ${ue_index}=${0}    &{kwargs}

    Run Keyword And Ignore Error    ute_ue.detach_ue    UE_${ue_index}
    Wait Until Keyword Succeeds    2 min    10 sec    ute_ue.attach_ue    UE_${ue_index}
    ${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IPS
    ${cell_id}    ute_ue.Get Ue Info     UE_${ue_index}    pci
    ute_ue.Get Ue Info     UE_${ue_index}    CELL_INFO
    Log    current cell id: ${cell_id}    console=yes
    Should Be Equal    ${cell_id}    ${require_attach_cell_id}


################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    ${require_attach_cell_id}    ${ue_index}=${0}    &{kwargs}

    ${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IPS
    ${cell_id}    ute_ue.Get Ue Info     UE_${ue_index}    pci
    ute_ue.Get Ue Info     UE_${ue_index}    CELL_INFO
    Log    Attach cell: ${cell_id}    console=yes
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
    Log    ${tag}
    Log    ${require_attach_cell_id}
    Log    ${interval}
#    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
#    ...                                 ${iperf_server_password}    22
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22

    ${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IP

#    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
#    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
#    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}

    Run Keyword If    '${direction}' == 'dl'    siso_data.Start UDP Iperf Client    ${iperf_pc_info}
    ...                                                                             ${ue_ip}
    ...                                                                             ${iperf_port}
    ...                                                                             band_width=${throughput}
    ...                                                                             duration=${duration}
    ...                                                                             ttl=64
    ...                                                                             alias=dl_client
    ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial    time=${duration}
    ...                                                                                            traffic=${throughput}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            iperf_port=${iperf_port}
    ...                                                                                            iperf_type=via_command
    ...                                                                                            protocol=${protocol}
    ...                                                                                            data_amount=${data_amount}
    ...                                                                                            buffer_size=${buffer_size}


Check Peak Throughput
    [Arguments]    ${theory_dl_peak}    ${theory_ul_peak}
    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...            ${acceptable_tput_percentage}=0.95    ${nr_cell_index}=1    ${du_index}=0
    ...            ${gnb_ssl_connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    [Documentation]    Check throughput from started traffic.
    ...  :param  theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
    ...  :param  theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec  E.G 262.0
    ...  :param  total_time: is the duration time in which the throughput need to be checked. The time unit is second.
    ...  :param  interval: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...  :param  duration_time_for_once: is the duration time for calculating average tput in one capturing
    ...  :param  acceptable_tput_percentage: The acceptable tput percentage of throughput.
    ...                                      Will check if Throughput > theory * acceptable_tput_percentage.
    ...  :param  is_need_to_capture_log: will capture event trace log if set to ${True}
    ${real_dl_tput}    ${real_ul_tput}    Verify tput from GNB within duration and record data to csv
    ...                                   total_time=${total_time}
    ...                                   exp_dl_tput=${theory_dl_peak}
    ...                                   exp_ul_tput=${theory_ul_peak}
    ...                                   interval=${interval}
    ...                                   duration_time_for_once=${duration_time_for_once}
    ...                                   nr_cell_index=${nr_cell_index}
    ...                                   tput_percentage=${acceptable_tput_percentage}
    ...                                   is_need_to_capture_log=${is_need_to_capture_log}
    ...                                   du_index=${du_index}
    ...                                   gnb_ssl_connection=${gnb_ssl_connection}
    [Return]    ${real_dl_tput}    ${real_ul_tput}

Stop traffic
    [Arguments]    ${direction}    ${ue_index}    ${iperf_port}=default    ${iperf_type}=via_command    ${protocol}=udp    &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22

    Run Keyword If    '${direction}' == 'dl'    siso_data.Stop Iperf Client    ${iperf_pc_info}    ${iperf_port}
    ...    alias=dl_client
    ...    ELSE IF    '${direction}' == 'ul'    Stop UL traffic and check the TP on EPC    ue_index=${ue_index}
    ...    UL_port=${iperf_port}    iperf_type=${iperf_type}    protocol=${protocol}

UE Detach
    [Arguments]    ${ue_index}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for detach
    ute_ue.detach_ue    UE_${ue_index}

