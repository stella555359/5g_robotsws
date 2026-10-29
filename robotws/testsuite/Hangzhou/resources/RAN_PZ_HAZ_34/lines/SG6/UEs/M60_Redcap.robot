*** Settings ***
Documentation    This is for M60 Redcap keywords.
...              Please do not modify the file without notification to author
...              Author: stella.lin@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot

*** Keywords ***
M60_RedCap.Prepare UE
    [Arguments]    ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set test variable    ${ue_type}
    Kill ELT process on ue control pc if exists    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${ue_index}

M60_RedCap.UE Attach
    [Documentation]   Stella.lin@nokia-sbell.com
    [Arguments]    ${wireshark_log_prefix}=cpif_attach
    ...            ${ue_mode}=SA
    ...            ${coam_connection}=GNB_OAM
    ...            ${ue_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${enb_index}=${1}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=15 sec
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${power_reset}=False
    ...            ${attach_mode}=5G_${ue_mode}
    ...            ${ue_alias}=UE_${ue_index}
    ...            ${enb_host}=${None}
    ...            ${enb_user}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${enb_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...            ${expect_attach_cell_index}=1
    ...            ${filter_ports}=port 38472 or port 38412 or port 38462 or port 36422 or port 38422 or port 49148 or port 29211
    ...            ${wireshark_interface}=-p -i any ${filter_ports} -s 0
    ...            ${ue_type}=${ue_type}
    ...            ${timeout}=15
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${coam_connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_name}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ...    options=${wireshark_interface}
    ${enb_in_init_file_existence}    ${output}    Run Keyword And Ignore Error    Set Variable    ${tl.enbs[0]}
    ${enb_ip}    Run Keyword If    '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='FAIL'
    ...    Get ENB IPaddress From GNB    gnb_index=${gnb_index}
    ...    ELSE IF   '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='PASS'
    ...    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If     '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}'    ${enb_ip}    ${enb_host}
    Run Keyword If    '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    ...                                                                        is_multi_rat=${is_multi_rat}
    ...                                                                        gnb_index=${gnb_index}
    ...                                                                        enb_host=${enb_host}
    ...                                                                        enb_user=${enb_user}
    ...                                                                        enb_password=${enb_password}
    Sleep    ${sleep_interval}
    Log To Console    ${\n}INFO:-- start to attach --
    ${timeout}    Evaluate    int(${timeout})
    power_ue.UE Attach    ue_type=${ue_type}
    ...                   ue_index=${ue_index}
    ...                   gnb_index=${gnb_index}
    ...                   hwcheck_index=${hwcheck_index}
    ...                   du_index=${du_index}
    ...                   power_reset=${power_reset}
    ...                   ue_alias=${ue_alias}
    ...                   attach_mode=${attach_mode}
    ...                   timeout=${timeout}
    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    Sleep    ${sleep_interval}
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_name}
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ${attach_cell_index}    Run Keyword And Continue On Failure
    ...                     Get Attach Cell Index From Wireshark
    ...                     cpif_log_path=${cpif_attach_log_on_testPC}
    ...                     connection=${coam_connection}
    ...                     gnb_index=${gnb_index}
    ...                     mode=${ue_mode}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_cell_index}    ${expect_attach_cell_index}
    ...    msg=attached to wrong cell.expect is cell-${expect_attach_cell_index} ,actual is ${attach_cell_index}.
    ${attach_info}    Run Keyword If    '${ue_mode}'=='NSA'
    ...            Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                 attach_cell_index=${attach_cell_index}
    ...                                 enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
    ...    ELSE    Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}    attach_cell_index=${attach_cell_index}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}

M60_Redcap.Get UE IP
    [Arguments]    ${attach_cpif_log}    ${mode}=SA
    ${ue_ip_dict}    Get ALL PDU IP Address From Wireshark    cpif_log_path=${attach_cpif_log}    mode=${mode}
    [Return]    ${ue_ip_dict['data']}

M60_RedCap.Prepare for UL traffic
    [Arguments]    ${ue_ip_addr}    ${ue_index}=${0}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
#    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell mtk_usb_tether_off.sh   connection=cygwin
#    sleep   5s
#    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell mtk_usb_tether_on.sh    connection=cygwin
    ${output}    csn.execute    command=adb shell ifconfig    connection=cygwin
    ${port_lines}    String.Get Lines Containing String    ${output}    Link encap
    ${RX_lines}    String.Get Lines Containing String    ${output}    RX bytes
    ${ports}    String.Get Regexp Matches    ${port_lines}    (\\S+)\\s+Link encap.*    1
    ${RX_bytes}    String.Get Regexp Matches    ${RX_lines}    \\s+RX bytes:(\\d+).*    1
    ${RX_bytes}    Evaluate    [int(x) for x in ${RX_bytes}]
    ${RX_bytes_max}    Evaluate     max(${RX_bytes})
    ${RX_bytes}    Evaluate    [str(x) for x in ${RX_bytes}]
    ${port_index}    Evaluate     ${RX_bytes}.index('${RX_bytes_max}')
    ${wwan_port}    Set Variable    ${ports[${port_index}]}
    csn.send_command    command=adb shell ip addr add ${ue_ip_addr}/24 dev ${wwan_port}    connection=cygwin
    sleep   5s
    csn.send_command    command=adb shell ifconfig ${wwan_port} up    connection=cygwin
    sleep   10s
    csn.send_command    command=adb shell ip route add default dev ${wwan_port}    connection=cygwin
    sleep   10s
    [Teardown]    csn.disconnect      connection=cygwin

M60_RedCap.Start DL traffic
    [Arguments]    ${ue_addr}    ${ue_index}=${0}
    ...            ${dl_throughput}=125MKbits/sec    ${dl_time}=9999
    ...            ${dl_length}=1400B    ${appserver}=APPserver    ${protocol}=udp
    ...            ${process_num}=${2}    ${seg_size}=${1372}    ${window}=2M
    ...            ${dl_port}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_addr}
    ...                                        dl_time=${dl_time}
    ...                                        dl_port=${dl_port}
    ...                                        dl_throughput=${dl_throughput}
    ...                                        dl_length=${dl_length}
    ...                                        appserver=${appserver}
    ...                                        protocol=${protocol}
    ...                                        ue_index=${ue_index}
    ...                                        process_num=${process_num}
    ...                                        seg_size=${seg_size}
    ...                                        window=${window}

M60_RedCap.Start UL traffic
    [Documentation]  This keyword connect to android control pc and start the iperf data.
    ...    2020-03-19 Cui Lingxue: use ${ue_sn} to indicate specific UE; add verification for iperf process
    ...    2020-12-22 Jia Lei: abstract three arguments for cpc_ip, cpc_usrname and cpc_passwd
    [Arguments]    ${ue_ip}    ${ue_index}=${0}    ${ul_time}=9999    ${ul_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...    ${ul_throughput}=100M    ${ul_length}=1400
    ...    ${ue_sn}=${tl.ues[${ue_index}].serial_number}    ${iperf_index}=${1}
    ...    ${iperf_path}=/usr/bin/iperf
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${ue_sn} shell ps |grep iperf |grep -v grep |awk '{print $${iperf_index}}'
    ...    connection=cygwin    timeout=120
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${iperf_process_before}    Run Keyword And Continue On failure    run keyword if    '${output}'!='${EMPTY}'    evaluate    ${output.strip()}
    run keyword if    '${iperf_process_before}'!='${EMPTY}'    csn.send_command
    ...    command=adb -s ${ue_sn} shell kill -9 ${iperf_process_before}
    ...    connection=cygwin
    ${cmd_ul_traffic}     catenate    adb -s ${ue_sn} shell
    ...    ${iperf_path} -c ${appserver_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput}
    ...    -l ${ul_length} -T 64 -B ${ue_ip} &
    csn.send_command    command=${cmd_ul_traffic}    connection=cygwin    timeout=120
    sleep    3s
    csn.send_command    command=adb -s ${ue_sn} shell ps |grep iperf |grep -v grep |awk '{print $${iperf_index}}'
    ...    connection=cygwin    timeout=120
    ${str}    csn.read_output    size=1000    connection=cygwin
    ${iperf_process_id}    evaluate    ${str.strip()}
    should be true    ${iperf_process_id}  > ${0}
    [Teardown]    csn.disconnect      connection=cygwin

M60_RedCap.Close Iperf Process On Android UE
    [Arguments]    ${ue_index}=${0}
    ...            ${ue_sn}=${tl.ues[${ue_index}].serial_number}
    ...            ${iperf_index}=${1}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${ue_sn} shell ps |grep iperf |grep -v grep |awk '{print $${iperf_index}}'
    ...    connection=cygwin    timeout=120
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${status}    ${iperf_process}    Run Keyword And Ignore Error   evaluate    ${output.strip()}
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${ue_sn} shell kill -9 ${iperf_process}
    ...    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

M60_RedCap.Stop Traffic
    [Arguments]    ${ue_index}=${0}    ${ul_traffic}=${True}    ${dl_traffic}=${True}
    ...    ${dl_port}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Run Keyword If    ${ul_traffic}    M60_RedCap.Close Iperf Process On Android UE    ue_index=${ue_index}
    Run Keyword If    ${dl_traffic}    Close the iperf process on APPserver    port=${dl_port}

M60_RedCap.UE Detach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

M60_RedCap.Check Tput
    [Arguments]    ${direction}=ULDL
    ...            ${expect_ul_tput}=82
    ...            ${expect_dl_tput}=91
    ...            ${target_avg_percent}=0.9
    ...            ${min_percent}=0.8
    ...            ${cellid}=1
    ...            ${duration}=90
    ...            ${ue_type}=${ue_type}
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    @{direction_component_list}    Run Keyword If    '${direction}'=='DL'    Create List    DL
    ...    ELSE IF    '${direction}'=='UL'    Create List    UL
    ...    ELSE    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=${duration}
    ...                                                                expect_ul_tput=${expect_ul_tput}
    ...                                                                expect_dl_tput=${expect_dl_tput}
    ...                                                                cellid=${cellid}
    ...                                                                target_avg_percent=${target_avg_percent}
    ...                                                                ue_type=${ue_type}
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=${min_percent}
    ...                                                                connection=${connection}
    ...                                                                gnb_index=${gnb_index}

M60_RedCap.Start VONR Call
    [Arguments]    ${ue_index}=${0}
    ...            ${interval}=60s
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=vonr_setup_${timestamp}
    ...    asik_connection_alias=ASIK Master
    ...    gnb_index=0
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   3s
    csn.send_command    command=adb shell mipc_wan_cli --dial_request="+6688"    connection=cygwin
    sleep   6s
    csn.send_command    command=adb shell mipc_wan_cli --answer_ringing    connection=cygwin
    Sleep    ${interval}
    ${vonr_log_path}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=vonr_setup_${timestamp}
    Sleep    10s
    [Return]    ${vonr_log_path}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=vonr_setup_${timestamp}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=vonr_setup_${timestamp}    AND
    ...                           Run Keyword And Ignore Error     csn.disconnect      connection=cygwin

M60_RedCap.Stop VONR Call
    [Arguments]    ${ue_index}=${0}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=vonr_release_${timestamp}
    ...    asik_connection_alias=ASIK Master
    ...    gnb_index=0
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   3s
    csn.send_command    command=adb shell mipc_wan_cli --hangup_all    connection=cygwin
    sleep   20s
    ${vonr_log_path}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=vonr_release_${timestamp}
    Sleep    15s
    [Return]    ${vonr_log_path}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=vonr_release_${timestamp}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=vonr_release_${timestamp}
    ...    AND    Run Keyword And Ignore Error     csn.disconnect      connection=cygwin

M60_RedCap.Check VONR Not Release
    [Arguments]    ${cpif_log_path}
    ${filter_expression}    Catenate    ngap.procedureCode == 26 and ngap.nas == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    ${status}    Run Keyword And Return Status    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    Run Keyword If    '${status}'=='${True}'    Fail    msg=vonr call released.

M60_RedCap.Check VONR Call SetUp
    [Arguments]    ${cpif_log_path}
    ${filter_expression}    Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 1
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${5QI}    pcap.get_field_value    field_name=ngap.fiveQI
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${status_invalid}    Evaluate    [x[0] for x in ${5QI} if x[0]!='1']
    Run Keyword And Continue On Failure     Should Be Empty     ${status_invalid}
    ...   msg=vonr call is not setup

M60_RedCap.Check VONR Normal Release
    [Arguments]    ${cpif_log_path}
    ${filter_expression}    Catenate    ngap.procedureCode == 26 and ngap.nas == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${release_status}    pcap.get_field_value    field_name=ngap.nas
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${status_invalid}    Evaluate    [x[0] for x in ${release_status} if x[0]!='0']
    Run Keyword And Continue On Failure     Should Be Empty     ${status_invalid}
    ...   msg=vonr call is not normal release success

Spark_RedCap.Start UL traffic
    [Arguments]    ${ue_index}=${1}    ${bat_file_path}=C:/TA/iperf_udp.bat
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=schtasks /create /tn iperf /sc once /tr '${bat_file_path}' /st 00:00 /RL highest /f
    ...    connection=cygwin    timeout=120
    ${output}    csn.read_output    size=1000    connection=cygwin
    Should Contain    ${output}    SUCCESS    msg=create iperf schtasks failed.
    csn.send_command    command=schtasks /run /tn iperf
    ...    connection=cygwin    timeout=120
    ${output}    csn.read_output    size=1000    connection=cygwin
    Should Contain    ${output}    SUCCESS    msg=run iperf schtasks failed.
    [Teardown]    csn.disconnect      connection=cygwin

Spark_RedCap.Stop UL traffic
    [Arguments]    ${ue_index}=${1}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=schtasks /end /tn iperf
    ...    connection=cygwin    timeout=120
    ${output}    csn.read_output    size=1000    connection=cygwin
    Run Keyword And Continue On Failure    Should Contain    ${output}    SUCCESS    msg=end iperf schtasks failed.
    csn.send_command    command=schtasks /delete /tn iperf /f
    ...    connection=cygwin    timeout=120
    ${output}    csn.read_output    size=1000    connection=cygwin
    Should Contain    ${output}    SUCCESS    msg=delete iperf schtasks failed.
    [Teardown]    csn.disconnect      connection=cygwin

Spark_RedCap.UE Attach
    [Documentation]   Stella.lin@nokia-sbell.com
    [Arguments]    ${wireshark_log_prefix}=cpif_attach
    ...            ${ue_mode}=SA
    ...            ${coam_connection}=GNB_OAM
    ...            ${ue_index}=${1}
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${enb_index}=${1}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=15 sec
    ...            ${du_index}=0
    ...            ${enb_host}=${None}
    ...            ${enb_user}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${enb_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...            ${expect_attach_cell_index}=1
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${coam_connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_name}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ${enb_in_init_file_existence}    ${output}    Run Keyword And Ignore Error    Set Variable    ${tl.enbs[0]}
    ${enb_ip}    Run Keyword If    '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='FAIL'
    ...    Get ENB IPaddress From GNB    gnb_index=${gnb_index}
    ...    ELSE IF   '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='PASS'
    ...    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If     '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}'    ${enb_ip}    ${enb_host}
    Run Keyword If    '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    ...                                                                        is_multi_rat=${is_multi_rat}
    ...                                                                        gnb_index=${gnb_index}
    ...                                                                        enb_host=${enb_host}
    ...                                                                        enb_user=${enb_user}
    ...                                                                        enb_password=${enb_password}
    Sleep    ${sleep_interval}
    Log To Console    ${\n}INFO:-- start to attach --
    Spark_common_keywords.Start UE Attach in X65 with WA Restart UE    ue_index=${ue_index}
    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    Sleep    ${sleep_interval}
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_name}
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ${attach_cell_index}    Run Keyword And Continue On Failure
    ...                     Get Attach Cell Index From Wireshark
    ...                     cpif_log_path=${cpif_attach_log_on_testPC}
    ...                     connection=${coam_connection}
    ...                     gnb_index=${gnb_index}
    ...                     mode=${ue_mode}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_cell_index}    ${expect_attach_cell_index}
    ...    msg=attached to wrong cell.expect is cell-${expect_attach_cell_index} ,actual is ${attach_cell_index}.
    ${attach_info}    Run Keyword If    '${ue_mode}'=='NSA'
    ...            Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                 attach_cell_index=${attach_cell_index}
    ...                                 enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
    ...    ELSE    Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}    attach_cell_index=${attach_cell_index}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}