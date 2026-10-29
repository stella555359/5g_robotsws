*** Settings ***
Documentation
...    author: yifan.hu
...    contact: yifan.hu@nokia-sbell.com
...    squad group: SG_03
...    feature : CB009384

Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot


*** Variables ***
${ue_type}           ${tl.ues[2].capabilities[1]}
${tl_scf_dir_path}    /opt/workspace/SCF/
${serial_number}    ${tl.ues[2].serial_number}
${gnb_index}    ${0}
${gnb2_index}    ${1}
${tshark_path}      /usr/bin/tshark
${gnb_instance0}    ${tl.gnbs[0].instance_id}
${gnb_instance1}    ${tl.gnbs[1].instance_id}
${index}    ${0}
@{gnb_id}    34411    24211
###TL344
${34411_port_1_gnb1_cell1}                ${tl.attenuator[0].attenuator_ports[1]}
${34411_port_2_gnb1_cell1}                ${tl.attenuator[0].attenuator_ports[2]}
${34411_port_1_gnb1_cell2}                ${tl.attenuator[0].attenuator_ports[3]}
${34411_port_2_gnb1_cell2}                ${tl.attenuator[0].attenuator_ports[4]}
${34411_port_1_gnb1_cell3}                ${tl.attenuator[0].attenuator_ports[10]}
${34411_port_2_gnb1_cell3}                ${tl.attenuator[0].attenuator_ports[12]}
${34411_port_1_gnb2_cell1}                ${tl.attenuator[0].attenuator_ports[5]}
${34411_port_2_gnb2_cell1}                ${tl.attenuator[0].attenuator_ports[7]}
${34411_port_1_gnb2_cell2}                ${tl.attenuator[0].attenuator_ports[6]}
${34411_port_2_gnb2_cell2}                ${tl.attenuator[0].attenuator_ports[8]}
###TL242
${24211_port_1_gnb1_cell1}                ${tl.attenuator[0].attenuator_ports[4]}
${24211_port_2_gnb1_cell1}                ${tl.attenuator[0].attenuator_ports[8]}
${24211_port_1_gnb1_cell2}                ${tl.attenuator[0].attenuator_ports[3]}
${24211_port_2_gnb1_cell2}                ${tl.attenuator[0].attenuator_ports[9]}
${24211_port_1_gnb1_cell3}                ${tl.attenuator[0].attenuator_ports[15]}
${24211_port_2_gnb1_cell3}                ${tl.attenuator[0].attenuator_ports[16]}
${24211_port_1_gnb2_cell1}                ${tl.attenuator[0].attenuator_ports[5]}
${24211_port_2_gnb2_cell1}                ${tl.attenuator[0].attenuator_ports[7]}
${24211_port_1_gnb2_cell2}                ${tl.attenuator[0].attenuator_ports[1]}
${24211_port_2_gnb2_cell2}                ${tl.attenuator[0].attenuator_ports[2]}
${att_ipaddr_gnb1_cell1}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell3}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell1}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2}                ${tl.attenuator[0].ip_addr}
${xnap_gnb1}    ${tl.gnbs[0].dus[0].f1_c_ip_addr}
${xnap_gnb2}    ${tl.gnbs[1].dus[0].f1_c_ip_addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${bts_host2}    ${tl.gnbs[2].cu.oam_http_connection_details.addr}
${traffic_duration}    360
${Send_Tput_DL}    300M
${Send_Tput_UL}    100M
${DL_PORT}        ${tl.ues[2].iperf_details.ssh_connection_details.port}

${protocol_UDP}    udp
${seg_size}    1180
@{allow_fault_list}    7523    7107    7311
@{branch}    SBTS23R4_ENB_0000    SBTS24R1_ENB_0000    SBTS24R2_ENB_9999
*** Keywords ***
Connect to gnb
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${bts_host${gnb_index}}    gnb_index=${gnb_index}
    [Teardown]    coam.teardown    connection=gnb${gnb_index}

Case Teardown
    Run Keyword And Ignore Error    Teardown Stop Capture Wireshark Logs on gNB    gnb_index=${0}
    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${2}
    Common Case Teardown for COAM

Tear down the connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    csn.Disconnect    connection=enb
    Run keyword and ignore error    csn.Disconnect    connection=gnb
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=BB1

Common Case TestLine Setup with MultiBTS
    [Arguments]        ${golden_scf_name_gnb}    ${gnb_nums}=${1}
    FOR    ${index}    IN RANGE    ${0}    ${gnb_nums}
        Common Case TestLine Setup with singe BTS
        ...    gnb_index=${index}    is_commission=True    golden_scf_name=${${golden_scf_name_gnb}${index}}
        COAM Wait for gnb ready and cell setup    timeout=20 min    gnb_type='SA'
        ...    is_x2_check_from_gnb_needed=False    gnb_index=${index}
    END

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

############### wireshark log #######################
Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
    [Return]    ${filtered_result}

Teardown Stop Capture Wireshark Logs on gNB
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${bts_host${gnb_index}}    gnb_index=${gnb_index}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

### PA adjust ###
Adjust gNB_RU Attenuation
    [Arguments]
    ...    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb1_cell3_value}=${127}
    ...    ${gnb1_cell3_value1}=${gnb1_cell3_value}    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${${gnb_instance0}_port_1_gnb1_cell1}    ${${gnb_instance0}_port_2_gnb1_cell1}
    ...    ${${gnb_instance0}_port_1_gnb1_cell1}    ${${gnb_instance0}_port_2_gnb1_cell1}
    @{att_ports_gnb1_cell2}    Create List    ${${gnb_instance0}_port_1_gnb1_cell2}    ${${gnb_instance0}_port_2_gnb1_cell2}
    ...    ${${gnb_instance0}_port_1_gnb1_cell2}    ${${gnb_instance0}_port_2_gnb1_cell2}
    @{att_ports_gnb1_cell3}    Create List    ${${gnb_instance0}_port_1_gnb1_cell3}    ${${gnb_instance0}_port_2_gnb1_cell3}
    ...    ${${gnb_instance0}_port_1_gnb1_cell3}    ${${gnb_instance0}_port_2_gnb1_cell3}
    @{att_ports_gnb2_cell1}    Create List    ${${gnb_instance0}_port_1_gnb2_cell1}    ${${gnb_instance0}_port_2_gnb2_cell1}
    ...    ${${gnb_instance0}_port_1_gnb2_cell1}    ${${gnb_instance0}_port_2_gnb2_cell1}
    @{att_ports_gnb2_cell2}    Create List    ${${gnb_instance0}_port_1_gnb2_cell2}    ${${gnb_instance0}_port_2_gnb2_cell2}
    ...    ${${gnb_instance0}_port_1_gnb2_cell2}    ${${gnb_instance0}_port_2_gnb2_cell2}
    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb1_cell3}    Create List    ${gnb1_cell3_value}    ${gnb1_cell3_value1}    ${gnb1_cell3_value}    ${gnb1_cell3_value1}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${${gnb_instance0}_port_1_gnb1_cell1}    att_ipaddr=${att_ipaddr_gnb1_cell1}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${${gnb_instance0}_port_1_gnb1_cell2}    att_ipaddr=${att_ipaddr_gnb1_cell2}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
    ...    att_connection_port=${${gnb_instance0}_port_1_gnb1_cell3}    att_ipaddr=${att_ipaddr_gnb1_cell3}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${${gnb_instance0}_port_1_gnb2_cell1}    att_ipaddr=${att_ipaddr_gnb2_cell1}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${${gnb_instance0}_port_1_gnb2_cell2}    att_ipaddr=${att_ipaddr_gnb2_cell2}

### traffic ###
Start UE DLUL traffic
    [Arguments]    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${ul_throughput}=${Send_Tput_UL}
    ...    ${dl_port}=${DL_PORT}    ${duration}=600    ${seg_size}=1180    ${ue_index}=${0}    ${dl_length}=1024B
    run keyword If    '${dl_throughput}'!='NULL'
    ...    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${dl_throughput}    dl_port=${dl_port}
    ...    duration=${duration}    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}
    run keyword If    '${ul_throughput}'!='NULL'
    ...    Power UE Start UL traffic    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}
    ...    seg_size=${seg_size}    ue_index=${ue_index}

Start UE DLUL traffic MTK
    [Arguments]    ${UE_IP}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}
    ...    ${dl_port}=${DL_PORT}    ${duration}=600    ${seg_size}=1180   ${ul_throughput}=${Send_Tput_UL}
    ...    ${ul_length}=1024B      ${dl_length}=1024B    ${ue_index}=${0}
    run keyword If    '${dl_throughput}'!='NULL'
    ...    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${dl_throughput}    dl_port=${dl_port}
    ...    duration=${duration}    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}
    run keyword If    '${ul_throughput}'!='NULL' and '${gnb_instance0}'== '${gnb_id}[0]'
    ...    ute_ue.start_data_transfer    dt_name=UL_${ue_index}    ue_alias=UE_${ue_index}
    ...    direction=ul    throughput=${ul_throughput}bits/sec
    ...    duration=${duration}s    protocol=udp    packet_size=${ul_length}
    ...    appserver=${tl.appservers[1]}
    ...    ELSE IF    '${ul_throughput}'!='NULL' and '${gnb_instance0}'== '${gnb_id}[1]'
    ...    Redcap UE Start UL traffic    ue_ip=${UE_IP}

Get UE IP from wirehsark
    [Arguments]    ${logname}
    ...    ${message_filter}=ngap.procedureCode == 29 and nas_5gs.sm.5qi == 7
    ...    ${xpath}=.//nas-5gs.sm.pdu_addr_inf_ipv4
    Log    Get UE IP from wirehsark
    ${UE_IP}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    [Return]    ${UE_IP}[-1]

Redcap UE Start UL traffic
    [Documentation]  This keyword connect to android control pc and start the iperf data.
    ...    2020-03-19 Cui Lingxue: use ${ue_sn} to indicate specific UE; add verification for iperf process
    ...    2020-12-22 Jia Lei: abstract three arguments for cpc_ip, cpc_usrname and cpc_passwd
    [Arguments]    ${ue_ip}    ${ue_index}=${2}    ${ul_time}=9999    ${ul_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...    ${ul_throughput}=100M    ${ul_length}=1400
    ...    ${ue_sn}=${tl.ues[${ue_index}].serial_number}     ${process_num}=${2}   ${iperf_index}=${1}
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
    ...    ${iperf_path} -c ${appserver_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P ${process_num} -f m -b ${ul_throughput}
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

Stop UE DLUL traffic
    [Arguments]    ${ue_index}=${0}    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}    ${ue_type}=${ue_type}
    run keyword If    '${ul_port}'!='NULL'
    ...    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    iperf_port=${ul_port}
    run keyword If    '${dl_port}'!='NULL'
    ...    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}    iperf_port=${dl_port}

######### check HO  #########
Check intergNB HO process on source gNB
    [Arguments]    ${logname}    ${ip_source}=${xnap_gnb1}    ${ip_target}=${xnap_gnb2}
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=xnap.procedureCode == 0 and ip.src == ${ip_source}
    ...    xpath=.//xnap.procedureCode
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}    message_filter=xnap.procedureCode == 0 and ip.src == ${ip_target}
    ...    xpath=.//xnap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel}=    Check wireshark log    logname=${logname}    message_filter=xnap.procedureCode == 6
    ...    xpath=.//xnap.procedureCode
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel}=    Check wireshark log    logname=${logname}    message_filter=xnap.procedureCode == 2 and xnap.XnAP_PDU == 0
    ...    xpath=.//xnap.procedureCode
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel}=    Check wireshark log    logname=${logname}    message_filter=f1ap.procedureCode == 6 and f1ap.radioNetwork == 10
    ...    xpath=.//f1ap.radioNetwork
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC}=    Check wireshark log    logname=${logname}    message_filter=f1ap.procedureCode == 6 and f1ap.F1AP_PDU == 1
    ...    xpath=.//f1ap.F1AP_PDU
    should contain    ${UE_Cont_relC}    1


Check intergNB HO process on target gNB
    [Arguments]    ${logname}    ${ip_source}=${xnap_gnb1}    ${ip_target}=${xnap_gnb2}
    ####HandoverRequest
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=xnap.procedureCode == 0 and ip.dst == ${ip_source}
    ...    xpath=.//xnap.procedureCode
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}    message_filter=xnap.procedureCode == 0 and ip.src == ${ip_source}
    ...    xpath=.//xnap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 25 and ip.src == ${ip_target}
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 25 and ip.dst == ${ip_target}
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel}=    Check wireshark log    logname=${logname}    message_filter=xnap.procedureCode == 6
    ...    xpath=.//xnap.procedureCode
    Should Be Equal    ${UE_rel[0]}    6
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ...    xpath=.//ngap.radioNetwork
    should not contain    ${UE_contextreleasereq}    0

Check intergNB NGHO process on source gNB
    [Arguments]    ${logname}
    ####HandoverRequest
    Log To Console    HandoverRequired
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 12 and ngap.radioNetwork == 16
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HO_req[0]}    12
    ####HandoverRequestAckonwledge
    Log To Console    HandoverCommand
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}
    ...    message_filter=ngap.procedureCode == 12 and ngap.PDUSessionResourceHandoverList == 2
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    12
    ####UEContextReleaseCommand
    Log To Console    UEContextRelease
    ${UE_rel}=    Check wireshark log    logname=${logname}    message_filter=ngap.radioNetwork == 2 and ngap.procedureCode == 41
    ...    xpath=.//ngap.radioNetwork
    Should Be Equal    ${UE_rel[0]}    2
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC}=    Check wireshark log    logname=${logname}    message_filter=ngap.id == 10 and ngap.procedureCode == 41
    ...    xpath=.//ngap.id
    should contain    ${UE_Cont_relC}    10

Check intergNB NGHO process on target gNB
    [Arguments]    ${logname}
    ####HandoverRequest
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 13 and ngap.id == 29
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HO_req[0]}    13
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}
    ...    message_filter=ngap.procedureCode == 13 and ngap.PDUSessionResourceAdmittedList == 2
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    13
    ####DownlinkRANStatusTransfer
    Log To Console    DownlinkRANStatusTransfer
    ${Transfer}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 7
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${Transfer[0]}    7
    ####HandoverNotify
    Log To Console    HandoverNotify
    ${HandoverNotify}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 11
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HandoverNotify[0]}    11

Check wireshark log for multi-drbs
    [Arguments]    ${logname}    ${multi_apn}    ${drb_length}    ${multi_drbs}
    ...    ${message_filter1}=ngap.fiveQI and nas_5gs.cmn.dnn == dxdata2
    ...    ${message_filter2}=ngap.fiveQI and nas_5gs.cmn.dnn == ims
    ...    ${message_filter3}=ngap.procedureCode == 29 and nas_5gs.cmn.dnn == ${multi_apn}
    ...    ${message_filter4}=ngap.associatedQosFlowList
    ...    ${xpath}=.//ngap.fiveQI
    ...    ${xpath_qos}=.//ngap.qosFlowIdentifier
    Log    Check multi drb for dxdata2
    ${dxdata_drb}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    should be equal    ${dxdata_drb[0]}    7
    Log    Check multi drb for ims
    ${ims_drb}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    should be equal    ${ims_drb[0]}    5
    Log    Check multi drb for mdrb1
    ${multi_drb}=    Check wireshark log    logname=${logname}    message_filter=${message_filter3}    xpath=${xpath}
    ${multi_drb_length}    Get Length    ${multi_drb}
    should be equal    ${multi_drb_length}    ${drb_length}
    FOR    ${index}    IN RANGE    ${multi_drb_length}
        should contain    ${multi_drb}    ${multi_drbs[${index}]}
    END
    ${qos_flow}=    Check wireshark log    logname=${logname}    message_filter=${message_filter4}    xpath=${xpath_qos}
    ${qos_flow_length}    Get Length    ${qos_flow}
    should be equal    ${qos_flow_length}    ${${drb_length}+2}
    [Return]    ${qos_flow}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Check the PM counter should be greater than value
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should Be True    ${counter_value[0]} > ${value}
    END
    [Teardown]    COAM Teardown gnb connections

Check the PM counter should be equal
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    Should Be True    ${counter_value_list[0]} > 0
    Should be equal    ${counter_value_list[0]}    ${counter_value_list[1]}
    [Teardown]    COAM Teardown gnb connections

MTK prepare UE
    [Arguments]    ${ue_index}=${2}    ${ue_type}=${ue_type}
    run keyword If    '${${gnb_instance0}}'== '${gnb_id}[1]'    MTK UE reboot    ue_index=${ue_index}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}

MTK UE reboot
    [Arguments]    ${ue_index}=${2}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} reboot   connection=cygwin
    sleep   40s
    [Teardown]    csn.disconnect      connection=cygwin

MTK UE Attach
    [Arguments]    ${ue_index}    ${ue_type}=mtk    ${gnb_index}=${0}    ${ue_alias}=UE_${ue_index}    ${timeout}=15
    ${timeout}    Evaluate    int(${timeout})
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    ue_alias=${ue_alias}    timeout=${timeout}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
#    ...    gnb_index=${gnb_index}
    sleep    5s

MTK UE Act Additional PDN
    [Arguments]    ${ue_index}    ${pdn}
    ute_ue.Connect Additional Pdn    ue_alias=UE_${ue_index}    pdn=${pdn}

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

attach with normal UE
    Precondition for Sansumg UE    ue_type=${UE_type_sansumg}   ui_version=S21UI3.1   ue_index=${3}
    Attach and check power UE    ue_type=${UE_type_sansumg}     ue_index=${3}


Download DL Traffic File
    [Arguments]     ${file_name}    ${ue_index}=${0}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    csn.download_file   remote_path=/tmp/${file_name}   local_path=${epc_log_path}${file_name}
    ...    connection=cygwin
    sleep    3s
    [Teardown]    csn.disconnect      connection=cygwin
################################################################################################################

MTK UE start VoNR
    [Arguments]    ${filename}    ${ue_index}=${0}    ${gNB_index}=${0}    ${call_index}=${0}
#    MTK UE Prepare for VoNR    ue_index=${ue_index}
    Make a VoNR and Capture log    filename=${filename}    gNB_index=${gNB_index}
    ...    call_index=${call_index}    ue_index=${ue_index}
    Check wireshark log for VONR setup    filename=${filename}

MTK UE Prepare for VoNR
    [Arguments]    ${ue_index}=${0}
    ute_ue.Connect Additional Pdn    ue_alias=UE_${ue_index}    pdn=ims
#    ute_ue.Enable Vonr Capability    alias=UE_${ue_index}

Make a VoNR and Capture log
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${call_index}=${0}    ${ue_index}=${0}
    Start capture gNB log on master    filename=${filename}    gNB_index=${gNB_index}
    ute_ue.Start Voice Call    vc_alias=VC_${call_index}    ue_alias=UE_${ue_index}    to=+6688
    sleep    10s
    Stop and download the Logs    filename=${filename}   gNB_index=${gNB_index}

Check wireshark log for VONR setup
    [Arguments]    ${filename}    ${message_filter1}=ngap.procedureCode == 26 and ngap.fiveQI == 1
    ...    ${message_filter2}=ngap.procedureCode == 46 and nas_5gs.sm.message_type == 0xcc
    ####VONR setup
    Log To Console    check VONR setup
    ${vonr_setup}=    Check wireshark log    logname=${filename}    message_filter=${message_filter1}
    ...    xpath=.//ngap.fiveQI
    should be equal    ${vonr_setup[0]}    1
    ####VONR PDU modify complete
    Log To Console    check VONR modify complete
    ${vonr_setup}=    Check wireshark log    logname=${filename}    message_filter=${message_filter2}
    ...    xpath=.//nas_5gs.sm.message_type
    should be equal    ${vonr_setup[0]}    0xcc
    ${vonr_qos_flow}=    Check wireshark log    logname=${filename}    message_filter=${message_filter1}
    ...    xpath=.//ngap.qosFlowIdentifier
    [Return]    ${vonr_qos_flow[0]}

VoNR call hang up
    [Arguments]    ${call_index}=${0}
    ute_ue.Stop Voice Call    vc_alias=VC_${call_index}

check IE wireshark log for VONR Release
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_nas}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.nas
    should be equal    ${ngap_nas[0]}    0

Check VONR NOT Release
    [Arguments]    ${logname}
    ${normal_release}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 26 and ngap.nas == 0
    ...    xpath=.//ngap.nas
    should not contain    ${normal_release}    0

Prepare M60 for UL traffic for TL34411
    [Arguments]    ${ue_index}=${2}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell mtk_usb_tether_off.sh   connection=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell mtk_usb_tether_on.sh    connection=cygwin
    sleep   40s
    [Teardown]    csn.disconnect      connection=cygwin

Prepare M60 for UL traffic for TL24211
    [Arguments]    ${ue_ip_addr}    ${ue_index}=${2}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell mtk_usb_tether_off.sh   connection=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell mtk_usb_tether_on.sh    connection=cygwin
    sleep   40s
#    csn.send_command    command=adb shell ip addr add ${ue_ip_addr}/24 dev wwan2    connection=cygwin
#    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell ip addr add ${ue_ip_addr}/24 dev wwan1    connection=cygwin
    sleep   5s
#    csn.send_command    command=adb shell ifconfig wwan2 up    connection=cygwin
#    sleep   10s
    csn.send_command    command=adb -s ${serial_number} shell ifconfig wwan1 up    connection=cygwin
    sleep   10s
#    csn.send_command    command=adb shell ip route add default dev wwan2    connection=cygwin
#    sleep   10s
    csn.send_command    command=adb -s ${serial_number} shell ip route add default dev wwan1    connection=cygwin
    sleep   10s
    [Teardown]    csn.disconnect      connection=cygwin

Start DLUL traffic and check throughput
    [Arguments]    ${logname}=NULL    ${cellid}=1    ${tput_dl}=${expected_tput_dl}    ${tput_ul}=${expected_tput_ul}
    ...    ${dl_throughput}=${Send_Tput_DL}    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${0}
    ...    ${dl_port}=${DL_PORT}    ${gnb_index}=${0}    ${seg_size}=1180
    ...    ${dl_length}=1024B
    ${UE_IP}    Run keyword If    '${logname}'!='NULL'
    ...    Get UE IP from wirehsark    logname=${logname}
    run keyword If    '${ul_throughput}'!='NULL'
    ...    Prepare M60 for UL traffic for TL24211    ue_ip_addr=${UE_IP}    ue_index=${ue_index}
    Start UE DLUL traffic MTK    dl_port=${dl_port}    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
    ...    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}    UE_IP=${UE_IP}
    sleep    20s
    Check DLUL tput     tput_dl=${tput_dl}    tput_ul=${tput_ul}    cellid=${cellid}    gnb_index=${gnb_index}
    ...    ue_index=${ue_index}

Check DLUL tput
    [Arguments]    ${tput_dl}=${expected_tput_dl}    ${tput_ul}=${expected_tput_ul}
    ...    ${cellid}=1    ${gnb_index}=${0}    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${duration}=30s
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid}    Create list  ${nrcellid}
    ${tput_log}    power_ue.Collect Tput    duration=${duration}    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_index}
    ...    ue_index=${ue_index}
    run keyword If    '${tput_dl}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl}    ue_index=${ue_index}
    run keyword If    '${tput_ul}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul}    ue_index=${ue_index}

Check PCMD log on source gNB
    [Arguments]    ${logname}
    ####ueCtxSetupRecord
    Log To Console    check ueCtxSetupRecord
    ${ueCtxSetupRecord}=    Check wireshark log    logname=${logname}    message_filter=nsetapx.DuVendorExtensionRecordDataType == 1
    ...    xpath=.//nsetapx.DuVendorExtensionRecordDataType
    should contain    ${ueCtxSetupRecord}    1
    ####redCapSupported
    Log To Console    check redCapSupported
    ${redCapSupported}=    Check wireshark log    logname=${logname}    message_filter=nsetapx.redCapSupported == 0
    ...    xpath=.//nsetapx.redCapSupported
    should contain    ${redCapSupported}    0
    ####ueInfoRecord
    Log To Console    check ueInfoRecord
    ${ueInfoRecord}=    Check wireshark log    logname=${logname}    message_filter=nsetapx.CuVendorExtensionRecordDataType == 4
    ...    xpath=.//nsetapx.CuVendorExtensionRecordDataType
    should contain    ${ueInfoRecord}    4
    ####ueInfo_redCapSupported
    Log To Console    check ueInfo_redCapSupported
    ${ueInfo_redCap}=    Check wireshark log    logname=${logname}    message_filter=nsetapx.redCapSupported == 1
    ...    xpath=.//nsetapx.redCapSupported
    should contain    ${ueInfo_redCap}    1

Check PCMD log on target gNB
    [Arguments]    ${logname}
    ####ueCtxSetupRecord
    Log To Console    check ueCtxSetupRecord
    ${ueCtxSetupRecord}=    Check wireshark log    logname=${logname}    message_filter=nsetapx.DuVendorExtensionRecordDataType == 1
    ...    xpath=.//nsetapx.DuVendorExtensionRecordDataType
    Should Be Equal    ${ueCtxSetupRecord[0]}    1
    ####redCapSupported
    Log To Console    check redCapSupported
    ${redCapSupported}=    Check wireshark log    logname=${logname}    message_filter=nsetapx.redCapSupported == 0
    ...    xpath=.//nsetapx.redCapSupported
    Should Be Equal    ${redCapSupported[0]}    0

Check HO for qos flow HO
    [Arguments]    ${logname}    ${drb_qos}     ${vonr_qos}
    ${qosflow}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 25
    ...    xpath=.//ngap.qosFlowIdentifier
    append to list    ${drb_qos}    ${vonr_qos[0]}
    ${qosflow_length}    Get Length    ${qosflow}
    should be equal    ${qosflow_length}    ${5}
    FOR    ${index}    IN RANGE    ${qosflow_length}
        should contain    ${qosflow}    ${drb_qos[${index}]}
    END
