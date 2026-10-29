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

UE CA Attach
    [Arguments]    ${require_attach_cell_ids}    ${ue_index}=${0}    &{kwargs}

    Run Keyword And Ignore Error    ute_ue.detach_ue    UE_${ue_index}
    Wait Until Keyword Succeeds    2 min    10 sec    ute_ue.attach_ue    UE_${ue_index}
    ${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IPS
    ${ip_done}   should_contiain_ip    ${ue_ip}
    Should Be True    ${ip_done}
    ${cell_id}    ute_ue.Get Ue Info     UE_${ue_index}    pci
    ute_ue.Get Ue Info     UE_${ue_index}    CELL_INFO
    Log    current cell id: ${cell_id}    console=yes
    List Should Contain Value    ${require_attach_cell_ids}     ${cell_id}
    [Return]    ${cell_id}

################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    ${require_attach_cell_id}    ${ue_index}=${0}    &{kwargs}

    ${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IPS
    ${cell_id}    ute_ue.Get Ue Info     UE_${ue_index}    pci
    ute_ue.Get Ue Info     UE_${ue_index}    CELL_INFO
    Log    Attach cell: ${cell_id}    console=yes
    Should Be Equal    ${cell_id}    ${require_attach_cell_id}

Verify CA Attach
    [Arguments]    ${require_attach_cell_ids}    ${ue_index}=${0}    &{kwargs}

    ${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IPS
    ${cell_id}    ute_ue.Get Ue Info     UE_${ue_index}    pci
    ute_ue.Get Ue Info     UE_${ue_index}    CELL_INFO
    Log    Attach cell: ${cell_id}    console=yes
    List Should Contain Value    ${require_attach_cell_ids}     ${cell_id}
    [Return]    ${cell_id}
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
    Log    ${protocol}
    Log    ${data_amount}
#    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
#    ...                                 ${iperf_server_password}    22

    ute_ue.Get Ue Info     UE_${ue_index}    CELL_INFO

    ${out_current_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_${direction}
    Run Keyword And Continue On Failure    ute_ue.Start Data Transfer    ${out_current_dt_id}
    ...    UE_${ue_index}    ${direction}    duration=${duration}    protocol=udp
    ...    throughput=${throughput}    port=${iperf_port}   packet_size=${buffer_size}


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
    Log    ${duration_time_for_once}
    Log    ${is_need_to_capture_log}
    ${out_current_dl_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_dl
    ${out_current_ul_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_ul
#    ute_ue.Check Data Transfer Is Alive    ${out_current_dl_dt_id}
#    ute_ue.Check Data Transfer Is Alive    ${out_current_ul_dt_id}

    ute_ue.Await Data Transfer Finish    ${out_current_ul_dt_id}
    ute_ue.Await Data Transfer Finish    ${out_current_dl_dt_id}

    ${ul_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_ul_dt_id}
    ${dl_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_dl_dt_id}


    Ue Review Iperf Reports    ${out_current_dl_dt_id}
    Ue Review Iperf Reports    ${out_current_ul_dt_id}
    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
    ...    ${out_current_dl_dt_id}    ${theory_dl_peak}Mbits/sec    ${acceptable_tput_percentage}

    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
    ...    ${out_current_ul_dt_id}    ${theory_ul_peak}Mbits/sec    10%

    Log    Avarage throughput(${require_attach_cell_id}): ${ul_avg_throughput} Kbits/sec,${dl_avg_throughput} Kbits/sec
    ...    console=yes

    [Return]    ${ul_avg_throughput}    ${dl_avg_throughput}
    [Teardown]   Run Keywords   ute_ue.Stop Data Transfer    ${out_current_dl_dt_id}   AND
    ...     ute_ue.Stop Data Transfer    ${out_current_ul_dt_id}

UE Detach
    [Arguments]    ${ue_index}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for detach
    ute_ue.detach_ue    UE_${ue_index}

