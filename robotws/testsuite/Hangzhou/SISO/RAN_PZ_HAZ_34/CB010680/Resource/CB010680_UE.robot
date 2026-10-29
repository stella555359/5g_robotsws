*** Settings ***
Documentation
...   author: pengliang.wu@nokia-sbell.com
...   contact: pengliang.wu@nokia-sbell.com

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_BIP.robot



*** Variables ***
${ul_iperf_port_list}      ${tl.ues[0].iperf_details.ports[0:3]}
${dl_iperf_port_list}      ${tl.ues[0].iperf_details.ports[3:6]}
${xiaomi12_ui_version}    Mi12UI13.0.28

*** Keywords ***
UE Attach
    [Arguments]    ${gnb_index}    ${ue_index}
    Log To Console    UE Attach for UE_${ue_index} in GNB_${gnb_index}
    ${ue_sn}    set variable    ${tl.ues[${ue_index}].serial_number}
    log to console       Prepare UE_${ue_index},SN:${ue_sn}
    ${ue_type}    set variable    ${tl.ues[${ue_index}].capabilities}[${-1}]
    ${ui_version}    set variable if    '${ue_type}'=='xiaomi'    ${xiaomi12_ui_version}    default
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    ui_version=${ui_version}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    sleep    5s

UE Start Traffic
    [Arguments]    ${ue_index}    ${dl_tput_sent}    ${ul_tput_sent}    ${duration}=1800
    ...    ${if_dl}=${True}    ${if_ul}=${True}
    Log to console    Strat Traffic UE_${ue_index}
    ${ue_type}    set variable    ${tl.ues[${ue_index}].capabilities}[${-1}]
    Run Keyword If    ${if_dl}    UE UDP DL Trafic with ip filter    ue_index=${ue_index}
    ...    dl_tput_sent=${dl_tput_sent}M    ip_filter=172.    duration=${duration}
    ...    iperf_port=${dl_iperf_port_list}[${ue_index}]
    Run Keyword If    ${if_ul}    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    duration=${duration}
    ...    iperf_port=${ul_iperf_port_list}[${ue_index}]    direction=ul    throughput=${ul_tput_sent}M
    ...    iperf_type=via_command

UE UDP DL Trafic with ip filter
    [Arguments]    ${ue_index}    ${dl_tput_sent}    ${iperf_port}    ${process_num}=1    ${duration}=1800    ${ip_filter}=172
    ...    ${buffer_size}=1400B
    ${ue_type}    set variable    ${tl.ues[${ue_index}].capabilities}[${-1}]
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${UE_SN}    set variable    ${tl.ues[${ue_index}].serial_number}
    ${command}    set variable
    ...    adb -s ${UE_SN} shell ip -f inet addr |grep ${ip_filter}| cut -d '/' -f 1 |tail -n -1 |head -1 |awk '{print $2}'
    csn.send_command    command=${command}      connection=cygwin
    ${UE_IP_output}    csn.Read Output    connection=cygwin
    ${UE_IP_strip}    Strip String    ${UE_IP_output}
    ${UE_IP}    set variable if      '${UE_IP_strip}'==''    127.0.0.1    ${UE_IP_strip}
    Log to console    UE ip: ${UE_IP}
    Should Not Start With      ${UE_IP}      192.168
    Should Not Start With      ${UE_IP}      127.0.0.1
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep    2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    sleep    2s
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${duration} -i 1 -p ${iperf_port} -P ${process_num} -f m -b ${dl_tput_sent} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    sleep    3s
    csn.execute    command=ps -ef|grep iperf    connection=EPCAPP
    ${iperf_process}    ssh.read_output    connection=EPCAPP
    log to console    iperf process: ${iperf_process}
    log to console    .....UE_${ue_index} udp dl iperf start....
    [Teardown]    csn.disconnect      connection=cygwin

UE Check Tput
    [Arguments]    ${gnb_index}    ${dl_tput_expected}    ${ul_tput_expected}    ${ue_index}=${0}    ${log_time}=60s
    ...    ${if_dl}=${True}    ${if_ul}=${True}    ${min_percent}=0.85    ${target_avg_percent}=0.95
    ...    ${dl_cells_list}=${1}    ${ul_cells_list}=${1}    ${ignore_time}=10s
    Log to console    Check tput...
    ${ue_type}    set variable    ${tl.ues[${ue_index}].capabilities}[${-1}]
    ${log_path}    power_ue.Collect Tput     ue_type=${ue_type}    duration=${log_time}    gnb_index=${gnb_index}
    ...    log_dir=${OUTPUT_DIR}/${TEST NAME}/    ignore_time=${ignore_time}
    ${dl_output}    run keyword and continue on failure    Run Keyword If    ${if_dl}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=dl    target_throughput=${dl_tput_expected}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${dl_cells_list}    log=${log_path}
    ...    actCarrierAggregation=${True}
    ${ul_output}    run keyword and continue on failure    Run Keyword If    ${if_ul}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=ul    target_throughput=${ul_tput_expected}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${ul_cells_list}    log=${log_path}
    ...    actCarrierAggregation=${True}
    Run Keyword If    ${if_dl}    Log to console    DL: ${dl_output}
    Run Keyword If    ${if_ul}    Log to console    UL: ${ul_output}

UE Stop Traffic
    [Arguments]    ${ue_index}    ${if_dl}=${True}    ${if_ul}=${True}
    Log to console    Stop Traffic UE_${ue_index}
    ${ue_type}    set variable    ${tl.ues[${ue_index}].capabilities}[${-1}]
    Run keyword if    ${if_dl}    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    ...    iperf_port=${dl_iperf_port_list}[${ue_index}]    iperf_type=via_command
    Run keyword if    ${if_ul}    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...    iperf_port=${ul_iperf_port_list}[${ue_index}]    iperf_type=via_command

UE Detach
    [Arguments]    ${ue_index}
    Log to console    UE Detach UE_${ue_index}
    ${ue_type}    set variable    ${tl.ues[${ue_index}].capabilities}[${-1}]
    ${ui_version}    set variable if    '${ue_type}'=='xiaomi'    ${xiaomi12_ui_version}    default
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    ui_version=${ui_version}
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

All UE Detach
    [Arguments]    ${ue_index_list}
    FOR    ${ue_index}    IN    @{ue_index_list}
        CB010680_UE.UE Detach    ue_index=${ue_index}
    END

UE stop traffic and detach
    [Arguments]    ${ue_index_list}    ${if_dl}=${True}    ${if_ul}=${True}    ${vonr_call_flg}=${None}
    FOR    ${ue_index}    IN    @{ue_index_list}
        Run Keyword If    '${vonr_call_flg}' != '${None}'    UE_start_traffic.Hang up VoNR call    ue_index=${ue_index}
        Run Keyword If    '${vonr_call_flg}' != '${None}'    UE_start_traffic.Hang up VoNR call    ue_index=${ue_index}
        CB010680_UE.UE Stop Traffic    ue_index=${ue_index}    if_dl=${if_dl}    if_ul=${if_ul}
        CB010680_UE.UE Detach    ue_index=${ue_index}
    END

All UE L3 Call And Check BIP SRS
    [Documentation]    UE l3 call and bip Check
    ...    parameters:
    ...    srs_config_dict --key is NRCELL id, value is srsForPositioning.cSRS.
    ...    pci_dict --key is NRCELL id, value is NRCELL.physCellId.
    [Arguments]    ${nrcellId_list}    ${gnb_index}=${0}    ${ue_list}=${None}    ${if_bip_check}=${False}
    ...    ${srs_config_dict}=${None}    ${pci_dict}=${None}    ${vonr_call_flg}=${None}
    ...    ${srs_cell_num_dic}=${None}    ${if_traffic}=${True}
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time_tcpdump}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time_tcpdump}
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=ngc_${log_time_tcpdump}.pcap
    FOR    ${ue_index}    IN    @{ue_list}
        CB010680_UE.UE Attach    gnb_index=${gnb_index}    ue_index=${ue_index}
        Run Keyword If    '${vonr_call_flg}' == 'before_traffic'    UE_start_traffic.Make a VoNR call(+6688)    ue_index=${ue_index}
        ${utc_time}    robot.libraries.DateTime.Get Current Date
        ${log_time}    change_format_for_utr_time    utc_time=${utc_time}
        Set Test Variable    ${log_time}
        Start Common Capture BIP log    target_file_name=bip_srs_ue_${ue_index}_${log_time}
        Trigger SRS Measurement From LMF   ue_index=${ue_index}
        Sleep    3s
        ${pcap_log_path_lst}    End Common Capture BIP log and Download    target_dir=${OUTPUT_DIR}/${TEST NAME}
        ...    target_file_name=bip_srs_ue_${ue_index}_${log_time}
        Run Keyword If    ${if_traffic}    CB010680_UE.UE Start Traffic    ue_index=${ue_index}
        ...    duration=1800    dl_tput_sent=1000    ul_tput_sent=100
        ...    if_dl=${True}    if_ul=${True}
        Run Keyword If    '${vonr_call_flg}' == 'after_traffic'    UE_start_traffic.Make a VoNR call(+6688)    ue_index=${ue_index}
    END
    CB010680_BIP.Stop And Copy TCPDUMP To UTE    filename=ngc_${log_time_tcpdump}.pcap
    Run keyword if    ${if_bip_check}    Bip capture and SRS Check    srs_config_dict=${srs_config_dict}    pci_dict=${pci_dict}
    ...   srs_cell_num_dic=${srs_cell_num_dic}    gnb_index=${gnb_index}
    ${result}    Run Keyword If    ${if_traffic}    Run Keyword And Return Status    CB010680_UE.UE Check Tput
    ...    gnb_index=${gnb_index}    log_time=200s    dl_tput_expected=600    ul_tput_expected=50
    ...    if_dl=${True}    if_ul=${True}
    ...    dl_cells_list=${nrcellId_list}    ul_cells_list=${nrcellId_list}    ignore_time=15s
    Run Keyword If    ${if_traffic}    Should Be True    ${result}
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_list}    vonr_call_flg=${vonr_call_flg}