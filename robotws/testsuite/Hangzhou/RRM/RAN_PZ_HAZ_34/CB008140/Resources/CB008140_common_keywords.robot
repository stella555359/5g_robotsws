*** Settings ***
Documentation
...    author: xiaodan.li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03
...    feature : CB008140

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
${ue_type}           ${tl.ues[0].capabilities[0]}
${tl_scf_dir_path}    /opt/workspace/SCF/
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${bts_host2}    ${tl.gnbs[2].cu.oam_http_connection_details.addr}
${bts_host3}    ${tl.gnbs[3].cu.oam_http_connection_details.addr}
${bts_host4}    ${tl.gnbs[4].cu.oam_http_connection_details.addr}
${WEBUI_host0}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_host1}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_host4}    https://${tl.gnbs[4].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${xnap_gnb1}    ${tl.gnbs[0].dus[0].f1_c_ip_addr}
${xnap_gnb2}    ${tl.gnbs[1].dus[0].f1_c_ip_addr}
${xnap_gnb3}    ${tl.gnbs[2].dus[0].f1_c_ip_addr}
${xnap_gnb4}    ${tl.gnbs[3].dus[0].f1_c_ip_addr}
${xnap_gnb5}    ${tl.gnbs[4].dus[0].f1_c_ip_addr}
${xpu_gnb1}    ${tl.gnbs[0].dus[0].f1_u_ip_addr}
${xpu_gnb2}    ${tl.gnbs[1].dus[0].f1_u_ip_addr}
${xpu_gnb3}    ${tl.gnbs[2].dus[0].f1_u_ip_addr}
@{xnap_gnb}    ${xnap_gnb1}    ${xnap_gnb2}
${gnb_index}    ${0}
${gnb2_index}    ${1}
${tshark_path}      /usr/bin/tshark
${gnb_instance0}    ${tl.gnbs[0].instance_id}
${gnb_instance1}    ${tl.gnbs[1].instance_id}
${enb_instance}    ${tl.enbs[0].instance_id}
${index}    ${0}
@{gnb_id}    38511    38611    38711
${att_port_1_gnb1_cell1_38511}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_38511}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_38511}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_38511}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb2_cell1_38511}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb2_cell1_38511}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb2_cell1_38511}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb2_cell1_38511}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_gnb1_cell2_38511}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_gnb1_cell2_38511}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_gnb1_cell2_38511}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_gnb1_cell2_38511}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_gnb2_cell2_38511}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_gnb2_cell2_38511}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_3_gnb2_cell2_38511}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_4_gnb2_cell2_38511}                ${tl.attenuator[1].attenuator_ports[8]}
${att_ipaddr_gnb1_cell1_38511}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_38511}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_38511}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2_38511}                ${tl.attenuator[1].ip_addr}

${att_port_1_gnb1_cell1_38611}                ${tl.attenuator[2].attenuator_ports[13]}
${att_port_2_gnb1_cell1_38611}                ${tl.attenuator[2].attenuator_ports[14]}
${att_port_3_gnb1_cell1_38611}                ${tl.attenuator[2].attenuator_ports[15]}
${att_port_4_gnb1_cell1_38611}                ${tl.attenuator[2].attenuator_ports[16]}
${att_port_1_gnb1_cell2_38611}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_2_gnb1_cell2_38611}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_3_gnb1_cell2_38611}                ${tl.attenuator[1].attenuator_ports[11]}
${att_port_4_gnb1_cell2_38611}                ${tl.attenuator[1].attenuator_ports[12]}
${att_port_1_gnb2_cell2_38611}                ${tl.attenuator[1].attenuator_ports[13]}
${att_port_2_gnb2_cell2_38611}                ${tl.attenuator[1].attenuator_ports[14]}
${att_port_3_gnb2_cell2_38611}                ${tl.attenuator[1].attenuator_ports[15]}
${att_port_4_gnb2_cell2_38611}                ${tl.attenuator[1].attenuator_ports[16]}
${att_port_1_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[16]}
${att_ipaddr_gnb1_cell1_38611}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_gnb1_cell2_38611}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_38611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2_38611}                ${tl.attenuator[1].ip_addr}

${att_port_1_gnb1_cell1_38711}                ${tl.attenuator[2].attenuator_ports[5]}
${att_port_2_gnb1_cell1_38711}                ${tl.attenuator[2].attenuator_ports[6]}
${att_port_3_gnb1_cell1_38711}                ${tl.attenuator[2].attenuator_ports[7]}
${att_port_4_gnb1_cell1_38711}                ${tl.attenuator[2].attenuator_ports[8]}
${att_port_1_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_gnb1_cell3_38711}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_2_gnb1_cell3_38711}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_3_gnb1_cell3_38711}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_4_gnb1_cell3_38711}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_5_gnb1_cell3_38711}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_1_gnb2_cell1_38711}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2_gnb2_cell1_38711}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3_gnb2_cell1_38711}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4_gnb2_cell1_38711}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_gnb2_cell2_38711}                ${tl.attenuator[2].attenuator_ports[25]}
${att_port_2_gnb2_cell2_38711}                ${tl.attenuator[2].attenuator_ports[26]}
${att_port_3_gnb2_cell2_38711}                ${tl.attenuator[2].attenuator_ports[27]}
${att_port_4_gnb2_cell2_38711}                ${tl.attenuator[2].attenuator_ports[28]}
${att_port_1_gnb3_cell1_38711}                ${tl.attenuator[2].attenuator_ports[9]}
${att_port_2_gnb3_cell1_38711}                ${tl.attenuator[2].attenuator_ports[10]}
${att_port_3_gnb3_cell1_38711}                ${tl.attenuator[2].attenuator_ports[11]}
${att_port_4_gnb3_cell1_38711}                ${tl.attenuator[2].attenuator_ports[12]}
${att_port_1_gnb3_cell2_38711}                ${tl.attenuator[2].attenuator_ports[1]}
${att_port_2_gnb3_cell2_38711}                ${tl.attenuator[2].attenuator_ports[2]}
${att_port_3_gnb3_cell2_38711}                ${tl.attenuator[2].attenuator_ports[3]}
${att_port_4_gnb3_cell2_38711}                ${tl.attenuator[2].attenuator_ports[4]}
${att_port_1_gnb3_cell3_38711}                ${tl.attenuator[2].attenuator_ports[21]}
${att_port_2_gnb3_cell3_38711}                ${tl.attenuator[2].attenuator_ports[22]}
${att_port_3_gnb3_cell3_38711}                ${tl.attenuator[2].attenuator_ports[23]}
${att_port_4_gnb3_cell3_38711}                ${tl.attenuator[2].attenuator_ports[24]}
${att_port_1_gnb4_cell1_38711}                ${tl.attenuator[2].attenuator_ports[13]}
${att_port_2_gnb4_cell1_38711}                ${tl.attenuator[2].attenuator_ports[14]}
${att_port_3_gnb4_cell1_38711}                ${tl.attenuator[2].attenuator_ports[15]}
${att_port_4_gnb4_cell1_38711}                ${tl.attenuator[2].attenuator_ports[16]}
${att_port_1_gnb4_cell2_38711}                ${tl.attenuator[2].attenuator_ports[17]}
${att_port_2_gnb4_cell2_38711}                ${tl.attenuator[2].attenuator_ports[18]}
${att_port_3_gnb4_cell2_38711}                ${tl.attenuator[2].attenuator_ports[19]}
${att_port_4_gnb4_cell2_38711}                ${tl.attenuator[2].attenuator_ports[20]}
${att_port_1_gnb4_cell3_38711}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_gnb4_cell3_38711}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_gnb4_cell3_38711}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_gnb4_cell3_38711}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_5_gnb4_cell3_38711}                ${tl.attenuator[1].attenuator_ports[5]}

${att_ipaddr_gnb1_cell1_38711}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_gnb1_cell2_38711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell3_38711}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_38711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2_38711}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_gnb3_cell1_38711}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_gnb3_cell2_38711}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_gnb3_cell3_38711}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_gnb4_cell1_38711}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_gnb4_cell2_38711}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_gnb4_cell3_38711}                ${tl.attenuator[1].ip_addr}

@{gnb_ips}    ${bts_host0}    ${bts_host1}
@{gnb_list}    ${0}    ${1}
${traffic_duration}    360
${Send_Tput_DL}    2000M
${Send_Tput_DL_MultiUE}    2000
${Send_Tput_UL}    80M
${Send_Tput_UL_MultiUE}    220
${Send_Tput_DL_DRB7}    1500M
${Send_Tput_DL_DRB9}    500M
${DL_PORT}        ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT_387}        ${tl.ues[0].iperf_details.port}
@{numberOfActiveUlUEs_value}    0    0
${expected_tput_ul}    NULL
${expected_tput_dl_T}    NULL

${protocol_TCP}    tcp
${protocol_UDP}    udp
${seg_size}    1180
${process_num_DL}    10
${process_num_UL}    2
${ue_apn}    dxdata1

*** Keywords ***
Connect to gnb
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${bts_host${gnb_index}}    gnb_index=${gnb_index}
    [Teardown]    coam.teardown    connection=gnb${gnb_index}

Case Teardown
    [Arguments]    ${parameters_to_update_gnb1}='NULL'    ${parameters_to_update_gnb2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Run Keyword And Ignore Error    Remove NRREL online    parameters_to_update_gnb1=${parameters_to_update_gnb1}
    ...    parameters_to_update_gnb2=${parameters_to_update_gnb2}
    ...    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    Run Keyword And Ignore Error    Teardown Stop Capture Wireshark Logs on gNB    gnb_index=${0}
    Run Keyword And Ignore Error    Teardown Stop Capture Wireshark Logs on gNB    gnb_index=${1}
    robot_common_operations.Common Case Teardown
#    Run Keyword And Ignore Error    Hanging resource test
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

Check the gnb1 and gnb2 cells status on air
    Check the cells status on air    bts_host=${bts_host0}    connection=gnb${gnb_index}
    Check the cells status on air    bts_host=${bts_host1}    connection=gnb${gnb2_index}

Reset the gnb1 and gnb2 and wait them on air
    [Arguments]    ${gnb_index_prime}=${0}    ${gnb_index_Ext}=${1}
    COAM gNB Reset site via api    gnb_index=${gnb_index_prime}    is_need_check_cell_onair=False    wait_for_reconnection=False
    COAM gNB Reset site via api    gnb_index=${gnb_index_Ext}    is_need_check_cell_onair=False    wait_for_reconnection=False
    wait until keyword succeeds    15 min    20s   Check the gnb1 and gnb2 cells status on air

Reset all gnb and wait them on air
    [Arguments]    ${gnb_list}=${gnb_list}
    FOR    ${index}    IN    @{gnb_list}
        COAM gNB Reset site via api    gnb_index=${index}    is_need_check_cell_onair=False    wait_for_reconnection=False
    END
    FOR    ${index}    IN    @{gnb_list}
        wait until keyword succeeds    10 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${index}}    connection=gnb${gnb_index}
    END

Check only default Fault Present
    [Arguments]    ${gnb_index}=0
    Connect to gnb coam via ssl
    @{alarm_list}    COAM Get active alarms
    FOR    ${alarms}    IN    @{alarm_list}
       ${alarms_tmp}    Convert To String    ${alarms}[additionalFaultID]
       List Should Contain Value    ${ALLOWED_FAULT}    ${alarms_tmp}
    END
    [Teardown]  COAM Teardown gnb connections

Check the gnb1 and gnb2 ready
    COAM Wait for gnb ready and cell setup    timeout=20 min    gnb_type='SA'
    ...    is_x2_check_from_gnb_needed=False    gnb_index=0
    COAM Wait for gnb ready and cell setup    timeout=20 min    gnb_type='SA'
    ...    is_x2_check_from_gnb_needed=False    gnb_index=1

Reset the gnb1 and gnb2 and wait them ready
    COAM gNB Reset site via api    gnb_index=${0}    is_need_check_cell_onair=False    wait_for_reconnection=False
    COAM gNB Reset site via api    gnb_index=${1}    is_need_check_cell_onair=False    wait_for_reconnection=False
    Check the gnb1 and gnb2 ready

Reset all gnb and wait them ready
    [Arguments]    ${gnb_list}=${gnb_list}
    FOR    ${index}    IN    @{gnb_list}
        COAM gNB Reset site via api    gnb_index=${index}    is_need_check_cell_onair=False    wait_for_reconnection=False
    END
    FOR    ${index}    IN    @{gnb_list}
        COAM Wait for gnb ready and cell setup    timeout=20 min    gnb_type='SA'
    ...    is_x2_check_from_gnb_needed=False    gnb_index=${index}
    END

Add NRREL online
    [Arguments]    ${parameters_to_update_gnb1}='NULL'    ${parameters_to_update_gnb2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    ...    Add_Mo_Online=${parameters_to_update_gnb1}    Add_Mo_Online_GNB2=${parameters_to_update_gnb2}
    Wait until keyword succeeds    10 min    20s   Check the gnb1 and gnb2 cells status on air

Remove NRREL online
    [Arguments]    ${parameters_to_update_gnb1}='NULL'    ${parameters_to_update_gnb2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    ...    Delete_Mo_Online=${parameters_to_update_gnb1}    Delete_Mo_Online_GNB2=${parameters_to_update_gnb2}
    Wait until keyword succeeds    10 min    20s   Check the gnb1 and gnb2 cells status on air

Delete A2MeasSCellRelSsb online
    [Arguments]    ${Delete_Para_Online_gnb1}='NULL'    ${Delete_Para_Online_gnb2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    ...    Delete_Para_Online=${Delete_Para_Online_gnb1}    Delete_Para_Online_GNB2=${Delete_Para_Online_gnb2}
    Wait until keyword succeeds    10 min    20s   Check the gnb1 and gnb2 cells status on air

Colse Overheating online
    Common Case TestLine Setup    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_Overheating_false}
    ...    Delete_Para_Online=${PARAMETERS_TO_ONLINE_DELETE_GNB1_GE001}
    Wait until keyword succeeds    10 min    20s   Check the gnb1 and gnb2 cells status on air

Online modify NIDD on gnb1 and gnb2
    [Arguments]    ${Modify_Para_Online}='NULL'    ${Modify_Para_Online_GNB2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    ...    Modify_Para_Online=${Modify_Para_Online}    Modify_Para_Online_GNB2=${Modify_Para_Online_GNB2}
    sleep    5s

Lock or unlock DSS cell on enb
    [Arguments]    ${value}=locked
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-371    parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372   parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-375    parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-376    parameter=administrativeState     value=${value}

############### wireshark log #######################
Start capture gNB log on gnb1 and gnb2
    [Arguments]    ${gnb1_filename}    ${gnb2_filename}    ${gnb_prime}=${0}    ${gnb_Etx}=${1}
    Run Keyword If    '${gnb_instance0}' == '${gnb_id}[1]'     Run keywords
    ...     Start capture gNB log on master    filename=${gnb1_filename}   gNB_index=${gnb_prime}    AND
    ...     Start Capture Wireshark Logs on ASIK    filename=${gnb2_filename}   gNB_index=${gnb_Etx}
    ...     ELSE    Run keywords
    ...     Start capture gNB log on master    filename=${gnb1_filename}   gNB_index=${gnb_prime}    AND
    ...     Start capture gNB log on master    filename=${gnb2_filename}   gNB_index=${gnb_Etx}

Stop and download gNB log on gnb1 and gnb2
    [Arguments]    ${gnb1_filename}    ${gnb2_filename}    ${gnb_prime}=${0}    ${gnb_Etx}=${1}
    Run Keyword If    '${gnb_instance0}' == '${gnb_id}[1]'     Run keywords
    ...    Stop and download the Logs    filename=${gnb1_filename}    gNB_index=${gnb_prime}     AND
    ...    Stop Capture Wireshark Logs on ASIK    filename=${gnb2_filename}    gNB_index=${gnb_Etx}
    ...     ELSE    Run keywords
    ...    Stop and download the Logs    filename=${gnb1_filename}    gNB_index=${gnb_prime}     AND
    ...    Stop and download the Logs    filename=${gnb2_filename}    gNB_index=${gnb_Etx}

Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
    [Return]    ${filtered_result}

Check timer differ
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${xpath}
    ...    ${iGnbCaXnSetupReqTmr}=${60}    ${message_index}=${0}    ${message2_index}=${0}
    ${time} =    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${time1} =    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${time} =    Convert To Number    ${time[${message_index}]}
    ${time1} =    convert_to_number    ${time1[${message2_index}]}
    ${time_dif1} =    evaluate    abs(${time1}-${time})
    ${time_dif1} =    evaluate    round(${time_dif1},2)
    should be true    ${time_dif1}<=${iGnbCaXnSetupReqTmr}

Check message time regularly
    [Arguments]    ${logname}    ${message_filter}    ${xpath}
    ${result}    Check wireshark log    logname=${logname}   message_filter=${message_filter}    xpath=${xpath}
    ${length}=        Get Length    ${result}
    FOR    ${index}    IN RANGE    ${0}    ${length}-${1}
        ${frame_time}    Convert To Number    ${result[${index}]}    0
        ${frame_time1}    Convert To Number    ${result[${index}+${1}]}    0
        ${time_dif1} =    evaluate    abs(${frame_time1}-${frame_time})
        should be equal    ${time_dif1}    ${2}
    END

Get message time list
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${frame_time}=     cap.get_field_value_by_xpath    xpath=.//frame.time_epoch     pcap_parser=test6
    [Return]    ${frame_time}

Teardown Stop Capture Wireshark Logs on gNB
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${bts_host${gnb_index}}    gnb_index=${gnb_index}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

### PA adjust ###
Adjust gNB_RU Attenuation
    [Arguments]     ${tl}=${gnb_instance0}
    ...    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb1_cell3_value}=${127}
    ...    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}
    ...    ${gnb3_cell1_value}=${127}    ${gnb3_cell2_value}=${127}
    ...    ${gnb3_cell3_value}=${127}    ${gnb3_cell3_value_1}=${gnb3_cell3_value}
    ...    ${gnb4_cell1_value}=${127}    ${gnb4_cell2_value}=${127}
    ...    ${gnb4_cell3_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_1_gnb1_cell2_${tl}}    ${att_port_2_gnb1_cell2_${tl}}
    ...    ${att_port_3_gnb1_cell2_${tl}}    ${att_port_4_gnb1_cell2_${tl}}
    @{att_ports_gnb1_cell3}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'
    ...    Create List    ${att_port_1_gnb1_cell3_${tl}}    ${att_port_2_gnb1_cell3_${tl}}
    ...    ${att_port_3_gnb1_cell3_${tl}}    ${att_port_4_gnb1_cell3_${tl}}    ${att_port_5_gnb1_cell3_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Create List    ${att_port_1_gnb2_cell2_${tl}}    ${att_port_2_gnb2_cell2_${tl}}
    ...    ${att_port_3_gnb2_cell2_${tl}}    ${att_port_4_gnb2_cell2_${tl}}
    @{att_ports_gnb3_cell1}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'
    ...    Create List    ${att_port_1_gnb3_cell1_${tl}}    ${att_port_2_gnb3_cell1_${tl}}
    ...    ${att_port_3_gnb3_cell1_${tl}}    ${att_port_4_gnb3_cell1_${tl}}
    @{att_ports_gnb3_cell2}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'
    ...    Create List    ${att_port_1_gnb3_cell2_${tl}}    ${att_port_2_gnb3_cell2_${tl}}
    ...    ${att_port_3_gnb3_cell2_${tl}}    ${att_port_4_gnb3_cell2_${tl}}
    @{att_ports_gnb3_cell3}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'
    ...    Create List    ${att_port_1_gnb3_cell3_${tl}}    ${att_port_2_gnb3_cell3_${tl}}
    ...    ${att_port_3_gnb3_cell3_${tl}}    ${att_port_4_gnb3_cell3_${tl}}
    @{att_ports_gnb4_cell1}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'
    ...    Create List    ${att_port_1_gnb4_cell1_${tl}}    ${att_port_2_gnb4_cell1_${tl}}
    ...    ${att_port_3_gnb4_cell1_${tl}}    ${att_port_4_gnb4_cell1_${tl}}
    @{att_ports_gnb4_cell2}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'
    ...    Create List    ${att_port_1_gnb4_cell2_${tl}}    ${att_port_2_gnb4_cell2_${tl}}
    ...    ${att_port_3_gnb4_cell2_${tl}}    ${att_port_4_gnb4_cell2_${tl}}
    @{att_ports_gnb4_cell3}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'
    ...    Create List    ${att_port_1_gnb4_cell3_${tl}}    ${att_port_2_gnb4_cell3_${tl}}
    ...    ${att_port_3_gnb4_cell3_${tl}}    ${att_port_4_gnb4_cell3_${tl}}    ${att_port_5_gnb4_cell3_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb1_cell3}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Create List
    ...    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_gnb3_cell1}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Create List
    ...    ${gnb3_cell1_value}    ${gnb3_cell1_value}    ${gnb3_cell1_value}    ${gnb3_cell1_value}
    @{values_gnb3_cell2}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Create List
    ...    ${gnb3_cell2_value}    ${gnb3_cell2_value}    ${gnb3_cell2_value}    ${gnb3_cell2_value}
    @{values_gnb3_cell3}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Create List
    ...    ${gnb3_cell3_value}    ${gnb3_cell3_value}    ${gnb3_cell3_value_1}    ${gnb3_cell3_value}
    @{values_gnb4_cell1}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Create List
    ...    ${gnb4_cell1_value}    ${gnb4_cell1_value}    ${gnb4_cell1_value}    ${gnb4_cell1_value}
    @{values_gnb4_cell2}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Create List
    ...    ${gnb4_cell2_value}    ${gnb4_cell2_value}    ${gnb4_cell2_value}    ${gnb4_cell2_value}
    @{values_gnb4_cell3}    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Create List
    ...    ${gnb4_cell3_value}    ${gnb4_cell3_value}    ${gnb4_cell3_value}    ${gnb4_cell3_value}    ${gnb4_cell3_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell2_${tl}}
    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Set the attenuation value
    ...    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
    ...    att_connection_port=${att_port_1_gnb1_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell3_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_gnb2_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell2_${tl}}
    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Set the attenuation value
    ...    att_ports=${att_ports_gnb3_cell1}    values=${values_gnb3_cell1}
    ...    att_connection_port=${att_port_1_gnb3_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb3_cell1_${tl}}
    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Set the attenuation value
    ...    att_ports=${att_ports_gnb3_cell2}    values=${values_gnb3_cell2}
    ...    att_connection_port=${att_port_1_gnb3_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb3_cell2_${tl}}
    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Set the attenuation value
    ...    att_ports=${att_ports_gnb3_cell3}    values=${values_gnb3_cell3}
    ...    att_connection_port=${att_port_1_gnb3_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb3_cell3_${tl}}
    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Set the attenuation value
    ...    att_ports=${att_ports_gnb4_cell1}    values=${values_gnb4_cell1}
    ...    att_connection_port=${att_port_1_gnb4_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb4_cell1_${tl}}
    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Set the attenuation value
    ...    att_ports=${att_ports_gnb4_cell2}    values=${values_gnb4_cell2}
    ...    att_connection_port=${att_port_1_gnb4_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb4_cell2_${tl}}
    run keyword If    '${gnb_instance0}'=='${gnb_id[2]}'    Set the attenuation value
    ...    att_ports=${att_ports_gnb4_cell3}    values=${values_gnb4_cell3}
    ...    att_connection_port=${att_port_1_gnb4_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb4_cell3_${tl}}

### traffic ###
Perpare and attach UE
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}    ${gnb_index}=${0}
    Adjust gNB_RU Attenuation   gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}   gnb2_cell2_value=${gnb2_cell2_value}
    Attach and check power UE    ue_type=${ue_type}    gnb_index=${gnb_index}

Start DL traffic and check 2CC tput
    [Arguments]    ${scellid}=1    ${pcellid}=1    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul}    ${tput_ul_scell}=NULL
    ...    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}    ${dl_port}=${DL_PORT}
    ...    ${gnb_prime}=${0}    ${gnb_external}=${1}    ${dl_throughput}=${Send_Tput_DL}
    ...    ${ul_throughput}=${Send_Tput_UL}    ${protocol}=${protocol_UDP}
    Adjust gNB_RU Attenuation   gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}   gnb2_cell2_value=${gnb2_cell2_value}
    Run keyword If    '${protocol}'=='tcp'
    ...    Start UE DLUL TCP traffic    ELSE
    ...    Start UE DLUL traffic    dl_port=${dl_port}    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
    sleep    20s
    Check 2CC DLUL tput     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    tput_ul_scell=${tput_ul_scell}    scellid=${scellid}    pcellid=${pcellid}
    ...    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}

Start DL traffic parallel and check 2CC tput
    [Arguments]    ${scellid}=1    ${pcellid}=1    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul}    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}    ${dl_port}=${DL_PORT}    ${gnb_prime}=${0}
    ...    ${gnb_external}=${1}    ${Send_Tput_DL_DRB7}=${Send_Tput_DL_DRB7}    ${Send_Tput_DL_DRB9}=${Send_Tput_DL_DRB9}
    ...    ${dl_throughput}=${Send_Tput_DL}
    Adjust gNB_RU Attenuation   gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}   gnb2_cell2_value=${gnb2_cell2_value}
    Power UE Start UL traffic    ue_type=${ue_type}    ul_throughput=${Send_Tput_UL}
    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${Send_Tput_DL_DRB9}    dl_port=${dl_port}
    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${Send_Tput_DL_DRB7}
    Check 2CC DLUL tput     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    scellid=${scellid}    pcellid=${pcellid}    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}

Check 2CC DLUL tput
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul}    ${tput_ul_scell}=NULL
    ...    ${scellid}=1   ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${1}    ${ue_type}=${ue_type}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_prime}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}    gnb_index=${gnb_external}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell}    Create list  ${nrcellid_scell}
    ${tput_log_prime}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_prime}
    ${tput_log_external}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_external}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}    log=${tput_log_external}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell}
    run keyword If    '${tput_ul_pcell}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_pcell}    log=${tput_log_prime}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul_pcell}
    run keyword If    '${tput_ul_scell}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_scell}    log=${tput_log_external}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul_scell}

Start UE DLUL traffic
    [Arguments]    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${ul_throughput}=${Send_Tput_UL}
    ...    ${dl_port}=${DL_PORT}    ${duration}=600
    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${dl_throughput}    dl_port=${dl_port}    duration=${duration}
    Power UE Start UL traffic    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}

Start UE DLUL TCP traffic
    [Arguments]    ${ue_type}=${ue_type}     ${process_num_DL}=${process_num_DL}    ${seg_size}=${seg_size}
    ...    ${process_num_UL}=${process_num_UL}
    Power UE Start DL traffic   ue_type=${ue_type}    protocol=${protocol_TCP}    process_num=${process_num_DL}
    ...    seg_size=${seg_size}    dl_throughput=${Send_Tput_DL}
    Power UE Start UL traffic    ue_type=${ue_type}    protocol=${protocol_TCP}    process_num=${process_num_UL}
    ...    seg_size=${seg_size}    ul_throughput=${Send_Tput_UL}

Stop UE DLUL traffic
    [Arguments]
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

Switch APN to muti DRB
    Run Keyword And Ignore Error    Perpare and attach UE    gnb1_cell1_value=${20}
    Android UE SwitchApn    ue_index=${0}    apn_name=mdrb
    power_ue.UE Detach  ue_type=${ue_type}

Start traffic with qct_dx50
    [Arguments]    ${direction}=dl    ${throughput}=10    ${duration}=600    ${iperf_port}=default    ${ue_index}=${0}
    ...            ${cap_index}=${0}    ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${process_num}=${5}
    ...            ${seg_size}=${1180}    ${ue_apn}=${ue_apn}    ${window}=2M    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer, like 10M
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  iperf_port: port number used for traffic start via iperf.
    ...  :param  process_num: the number of process which are used for tcp data transfer, the more the better.
    ...  :param  window: tcp window size. eg, default value is 2M
    ${ue_addr} =    Get the UE need Ip address    ue_index=${ue_index}    ue_apn=${ue_apn}
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    wait until keyword succeeds    3x    10s    Start DL traffic via iperf on Appserver
    ...                                                                                    ue_addr=${ue_addr}
    ...                                                                                    dl_time=${duration}
    ...                                                                                    dl_port=${port}
    ...                                                                                    dl_throughput=${throughput}
    ...                                                                                    dl_length=${buffer_size}
    ...                                                                                    appserver=${appserver}
    ...                                                                                    protocol=${protocol}
    ...                                                                                    ue_index=${ue_index}
    ...                                                                                    process_num=${process_num}
    ...                                                                                    seg_size=${seg_size}
    ...                                                                                    window=${window}
    ...    ELSE IF    '${direction}' == 'ul'    wait until keyword succeeds    3x    10s    Start UL traffic via iperf from andriod UE
    ...                                                                                       ue_index=${ue_index}
    ...                                                                                       ul_time=${duration}
    ...                                                                                       ul_port=${port}
    ...                                                                                       ul_throughput=${throughput}
    ...                                                                                       ul_length=${buffer_size}
    ...                                                                                       appserver=${appserver}
    ...                                                                                       protocol=${protocol}
    ...                                                                                       process_num=${process_num}
    ...                                                                                       window=${window}

Get the UE need Ip address
    [Documentation]  After UE attach success, can use this keyword to get the UE IP for data transfer.
    [Arguments]    ${ue_index}=${0}    ${ue_apn}=${ue_apn}
    ${ips}    Get Ue Info    UE_${ue_index}    IPS
    ${IP}=    Evaluate    ${ips}[${ue_apn}]['ip_address']
    [return]  ${IP}

############### wireshark xnap log #######################
Check 1st IgNBCASetupRequest
    [Arguments]    ${logname}
    ...    ${message_filter1}=nokiaxnap.procedureCode == 17 and nokiaxnap.XnAP_PDU == 1
    ...    ${message_filter2}=nokiaxnap.IgNBCASetupRequest_element and ip.src == ${xnap_gnb1}
    ...    ${xpath}=.//ip.src
    ...    ${xpath1}=.//ip.dst
    ...    ${xpath2}=.//frame.time_epoch
    ...    ${iGnbCaXnSetupReqTmr}=${60}
    Log    check first send IgNBCASetupRequest gnb is gnb1 and timediff less than 1 with last XnSetupResponse
    ${ip_src_result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    List Should Contain Value    ${xnap_gnb}    ${ip_src_result[-1]}
    ${ip_dst_result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    List Should Contain Value    ${xnap_gnb}    ${ip_dst_result[-1]}
    Check timer differ    logname=${logname}    message_filter=${message_filter1}    message_filter1=${message_filter2}
    ...    xpath=${xpath2}    iGnbCaXnSetupReqTmr=${iGnbCaXnSetupReqTmr}    message_index=${-1}    message2_index=${0}

Check IgNBCASetup on 2gnb
    [Arguments]    ${logname}    ${PrimegNB}=${xnap_gnb1}    ${ExtgNB}=${xnap_gnb2}
    ...    ${message_filter1}=nokiaxnap.IgNBCASetupRequest_element and ip.src == ${PrimegNB}
    ...    ${message_filter2}=nokiaxnap.IgNBCASetupResponse_element and ip.src == ${ExtgNB}
    ...    ${xpath}=.//nokiaxnap.NR-Cell-Identity
    Log    check IgNBCASetupRequest has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${extcell_id}
    Log    check gNBCASetupResponse has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${primecell1_id}


Check IgNBCAconfig on 2gnb
    [Arguments]    ${logname}
    ...    ${message_filter1}=nokiaxnap.CellLoadReportingPeriodicity and ip.src == ${xnap_gnb1}
    ...    ${message_filter2}=nokiaxnap.CellLoadReportingPeriodicity and ip.src == ${xnap_gnb2}
    ...    ${xpath}=.//nokiaxnap.CellLoadReportingPeriodicity
    Log    check gNB1 IgNBCAConfigurationUpdateIndication has the 2000
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    should be equal    ${result[0]}    2000
    Log    check gNB2 IgNBCAConfigurationUpdateIndication has the 2000
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    should be equal    ${result[0]}    2000


Check IgNBCAconfigcellstatus on 2gnb
    [Arguments]    ${logname}
    ...    ${message_filter1}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb1}
    ...    ${message_filter2}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb2}
    ...    ${xpath}=.//nokiaxnap.NR-Cell-Identity
    ...    ${xpath1}=.//nokiaxnap.cell_Availability
    Log    check gNB1 IgNBCASetupRequest has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${primecell1_id}
    Log    check gNB2 IgNBCASetupRequest has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${extcell_id}
    Log    check gNB1 IgNBCAConfigurationUpdateIndication cell status is avaliable
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    should be equal    ${result[0]}    1
    Log    check gNB2 IgNBCAConfigurationUpdateIndication cell status is avaliable
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath1}
    should be equal    ${result[0]}    1

Check IgNBCAResourceStatusUpdate has nrcellid on PrimegNB
    [Arguments]    ${logname}    ${scell}    ${scell_nums}=${1}    ${xnap_gnb}=${xnap_gnb2}
    ...    ${message_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb} and nokiaxnap.CellLoadResult == ${scell_nums}
    ...    ${xpath}=.//nokiaxnap.NR-Cell-Identity
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    FOR   ${cell_index}   IN RANGE    ${0}    ${scell_nums}
        ${result_scell}=    Convert To Integer    ${result[${cell_index}]}    16
        Should be equal    ${result_scell}    ${scell[${cell_index}]}
    END

Check numberOfActiveUEs and numberOfActiveUlUEs
    [Arguments]    ${logname}    ${numberOfActiveUEs_value}    ${numberOfActiveUlUEs_value}
    ...    ${xnap_gnb}=${xnap_gnb2}
    ...    ${message_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb} and nokiaxnap.CellLoadResult
    ...    ${xpath}=.//nokiaxnap.numberOfActiveUEs
    ...    ${xpath1}=.//nokiaxnap.numberOfActiveUlUEs
    ${numberOfActiveUEs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${numberOfActiveUlUEs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    List Should Contain Sub List    ${numberOfActiveUEs}    ${numberOfActiveUEs_value}
    List Should Contain Sub List    ${numberOfActiveUlUEs}    ${numberOfActiveUlUEs_value}

Check IgNBCAResourceStatusUpdate time interval on 2gnb
    [Arguments]    ${logname}
    ...    ${message1_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb1}
    ...    ${message1_filter2}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb1}
    ...    ${message2_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb2}
    ...    ${message2_filter2}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb2}
    ...    ${xpath}=.//frame.time_epoch
    Check timer differ    logname=${logname}    message_filter=${message1_filter1}    message_filter1=${message1_filter2}
    ...    xpath=${xpath}
    Check timer differ    logname=${logname}    message_filter=${message2_filter1}    message_filter1=${message2_filter2}
    ...    xpath=${xpath}
    Check message time regularly    logname=${logname}    message_filter=${message1_filter1}    xpath=${xpath}
    Check message time regularly    logname=${logname}    message_filter=${message2_filter1}    xpath=${xpath}

Check IgNBCASetup on extGnb
    [Arguments]    ${logname}
    ...    ${message_filter1}=nokiaxnap.IgNBCASetupRequest_element
    ...    ${message_filter2}=nokiaxnap.IgNBCASetupResponse_element
    ...    ${xpath}=.//nokiaxnap.NR-Cell-Identity
    Log    check IgNBCASetupRequest has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${extcell_id}
    Log    check gNBCASetupResponse has not the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    Should Be Empty    ${result}


Check IgNBCAconfig on extgnb
    [Arguments]    ${logname}
    ...    ${message_filter1}=nokiaxnap.CellLoadReportingPeriodicity and ip.src == ${xnap_gnb1}
    ...    ${message_filter2}=nokiaxnap.CellLoadReportingPeriodicity and ip.src == ${xnap_gnb2}
    ...    ${xpath}=.//nokiaxnap.CellLoadReportingPeriodicity
    Log    check gNB1 IgNBCAConfigurationUpdateIndication has the 2000
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    should be equal    ${result[0]}    2000
    Log    check gNB2 has not IgNBCAConfigurationUpdateIndication
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    Should Be Empty    ${result}


Check IgNBCAconfigcellstatus on extgnb
    [Arguments]    ${logname}    ${cell_status}=1
    ...    ${message_filter1}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb2}
    ...    ${xpath}=.//nokiaxnap.NR-Cell-Identity
    ...    ${xpath1}=.//nokiaxnap.cell_Availability
    Log    check gNB2 IgNBCASetupRequest has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${extcell_id}
    Log    check gNB1 IgNBCAConfigurationUpdateIndication cell status is avaliable
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    should be equal    ${result[0]}    ${cell_status}


Check IgNBCAResourceStatusUpdate time interval on extgnb
    [Arguments]    ${logname}
    ...    ${message2_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb2}
    ...    ${message2_filter2}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb2}
    ...    ${xpath}=.//frame.time_epoch
    Check timer differ    logname=${logname}    message_filter=${message2_filter1}    message_filter1=${message2_filter2}
    ...    xpath=${xpath}
    Check message time regularly    logname=${logname}    message_filter=${message2_filter1}    xpath=${xpath}

Check has no IgNBCAResourceStatusUpdate after unlock to lock
    [Arguments]    ${logname}
    ...    ${message2_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb2}
    ...    ${message2_filter2}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb2}
    ...    ${xpath}=.//frame.time_epoch
    ${time} =    Check wireshark log    logname=${logname}    message_filter=${message2_filter1}    xpath=${xpath}
    ${time1} =    Check wireshark log    logname=${logname}    message_filter=${message2_filter2}    xpath=${xpath}
    ${time} =    Convert To Number    ${time[-1]}
    ${time1} =    convert_to_number    ${time1[0]}
    Should Be True    ${time1}>${time}

Check IgNBCAXpSetupRequest message
    [Arguments]    ${logname}    ${gnb_ID}
    ${gnb_ID_log}    Check wireshark log    logname=${logname}    attribute_name=value
    ...    message_filter=nokiaf1ap.procedureCode == 14 and nokiaf1ap.Nokia_F1AP_PDU == 0
    ...    xpath=.//nokiaf1ap.gnb_ID
    ${gnb_ID_transition_DEC}    Evaluate    list(map(lambda x: int(x, 16), ${gnb_ID_log}))
    should be equal    ${gnb_ID_transition_DEC[0]}    ${gnb_ID}

Check IgNBCAXpSetupResponse message
    [Arguments]    ${logname}    ${XP_Status}    ${gnb_ID}
    ${XpConnectionStatus}    Check wireshark log    logname=${logname}
    ...    message_filter=nokiaf1ap.procedureCode == 14
    ...    xpath=.//nokiaf1ap.XpConnectionStatus
    ${XpStatus}    Convert to Integer     ${XpConnectionStatus[0]}
    should be equal    ${XpStatus}    ${XP_Status}
#    ${IgNBCAXpProtocolVersion}    Check wireshark log    logname=${logname}
#    ...    message_filter=nokiaf1ap.procedureCode == 14
#    ...    xpath=.//nokiaf1ap.IgNBCAXpProtocolVersion
#    should be equal    ${IgNBCAXpProtocolVersion[0]}    1
    ${gnb_ID_log}    Check wireshark log    logname=${logname}    attribute_name=value
    ...    message_filter=nokiaf1ap.procedureCode == 14 and nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    xpath=.//nokiaf1ap.gnb_ID
    ${gnb_ID_transition_DEC}    Evaluate    list(map(lambda x: int(x, 16), ${gnb_ID_log}))
    should be equal    ${gnb_ID_transition_DEC[0]}    ${gnb_ID}

Check IgNBCAconfigurationUpdateIndication message
    [Arguments]    ${logname}    ${soure_ip}
    ${IgNBCAXpProtocolVersion_indication}    Check wireshark log    logname=${logname}
    ...    message_filter=nokiaxnap.procedureCode == 22 and ip.src == ${soure_ip}
    ...    xpath=.//nokiaxnap.IgNBCAXpProtocolVersion
    ${IgNBCAXpProtocolVersion_response}    Check wireshark log    logname=${logname}
    ...    message_filter=nokiaf1ap.procedureCode == 14
    ...    xpath=.//nokiaf1ap.IgNBCAXpProtocolVersion
    should be equal    ${IgNBCAXpProtocolVersion_indication[0]}    ${IgNBCAXpProtocolVersion_response[0]}

Check XpConnectionStatusNotification message
    [Arguments]    ${logname}    ${gnb_ID}    ${XP_Status}
    ${gnb_ID_log}    Check wireshark log    logname=${logname}    attribute_name=value
    ...    message_filter=nokiaf1ap.procedureCode == 14
    ...    xpath=.//nokiaf1ap.gnb_ID
    ${gnb_ID_transition_DEC}    Evaluate    list(map(lambda x: int(x, 16), ${gnb_ID_log}))
    should be equal    ${gnb_ID_transition_DEC[0]}    ${gnb_ID}
    ${XpConnectionStatus}    Check wireshark log    logname=${logname}
    ...    message_filter=nokiaf1ap.procedureCode == 14
    ...    xpath=.//nokiaf1ap.XpConnectionStatus
    ${XpStatus}    Convert to Integer     ${XpConnectionStatus[0]}
    should be equal    ${XpStatus}    ${XP_Status}

Check 1st IgNBCAUeContextModificationRequest message has igNBCASetup on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.queryPurpose==0
    ...    ${xpath}=.//nokiaf1ap.queryPurpose
    Log    check IgNBCAUeContextModificationRequest has igNBCASetup
    ${igNBCASetup}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${igNBCASetup[0]}    0

Check has no the IgNBCAUeContextModificationRequest message
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.queryPurpose==0
    ...    ${xpath}=.//nokiaf1ap.queryPurpose
    Log    check IgNBCAUeContextModificationRequest has igNBCASetup
    ${igNBCASetup}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be empty    ${igNBCASetup}


Check IgNBCAUeContextModificationResponse has messages on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAUeContextModificationResponse message
    ${F1AP_PDU}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should contain   ${F1AP_PDU}    1

Check IgNBCAUeContextModificationResponse has transport messages on PrimegNB
    [Arguments]    ${logname}    ${xgU_addr}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.transportLayerAddressIPv6
    Log    Check IgNBCAUeContextModificationResponse has transport messages
    ${transport_addr}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal   ${transport_addr[0]}    ${xgU_addr}

Check IgNBCAUeContextSetupResponse has transport messages on ExtgNB
    [Arguments]    ${logname}    ${xgU_addr}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.transportLayerAddressIPv6
    Log    Check IgNBCAUeContextSetupResponse has transport messages
    ${transport_addr}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal   ${transport_addr[0]}    ${xgU_addr}

Check IgNBCAUeContextSetupResponse has no transport ip on ExtgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.transportLayerAddressIPv6
    Log    Check IgNBCAUeContextSetupResponse has transport messages
    ${transport_addr}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be empty   ${transport_addr}

Check IgNBCAAdditionRequest message has pGNBIP and pcellid and scellid on PrimegNB
    [Arguments]    ${logname}    ${gnb_index}=${0}   ${xpu_gnb}=${xpu_gnb${${gnb_index}+${1}}}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 0 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.TransportLayerAddressIPv4
    ...    ${xpath1}=.//nokiaxnap.NR-Cell-Identity
    Log    check IgNBCAAdditionRequest message
    ${prime_gnbip}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${prime_gnbip[0]}    ${xpu_gnb}
    ${cellid}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${result_primecell1}=    Convert To Integer    ${cellid[0]}    16
    ${result_extcell}=    Convert To Integer    ${cellid[1]}    16
    Should be equal    ${result_primecell1}    ${primecell1_id}
    Should be equal    ${result_extcell}    ${extcell_id}

Check IgNBCAAdditionRequestReject message on PrimegNB and ExtgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.transport == 0 and nokiaxnap.Nokia_XnAP_PDU == 2
    ...    ${xpath}=.//nokiaxnap.transport
    Log    IgNBCAAdditionRequestReject message
    ${transport_cause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${transport_cause[0]}    0

Check IgNBCAAdditionAcknowledge message has eGNBIP and scellid on PrimegNB
    [Arguments]    ${logname}    ${gnb_index}=${1}    ${xpu_gnb}=${xpu_gnb${${gnb_index}+${1}}}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 1 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.TransportLayerAddressIPv4
    ...    ${xpath1}=.//nokiaxnap.NR-Cell-Identity
    Log    check IgNBCAAdditionAcknowledge message
    ${ext_gnbip}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${ext_gnbip[0]}    ${xpu_gnb}
    ${scellid}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${result_extcell}=    Convert To Integer    ${scellid[0]}    16
    should be equal    ${result_extcell}    ${extcell_id}

Check 2st has the IgNBCAUeContextModificationRequest message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.dRBID
    ...    ${xpath}=.//nokiaf1ap.dRBID
    Log    check IgNBCAUeContextModificationRequest message
    ${dRBID}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should contain    ${dRBID}    4

Check 2st IgNBCAUeContextModificationRequest message with CA cancel on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.queryPurpose == 1 and nokiaf1ap.procedureCode == 193
    ...    ${xpath}=.//nokiaf1ap.queryPurpose
    Log    check 2st IgNBCAUeContextModificationRequest message with CA cancel
    ${queryPurpose}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${queryPurpose[0]}    1

Check 2st IgNBCAUeContextModificationResponse message with CA cancel on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1 and nokiaf1ap.procedureCode == 193 and !nokiaf1ap.dRBID
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    IgNBCAUeContextModificationResponse message
    ${f1ap_pdu}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${f1ap_pdu[0]}    1

Check IgNBCAModificationRequest message has complete on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 141 and nokiaxnap.Nokia_XnAP_PDU == 0
    ...    ${xpath}=.//nokiaxnap.ProcedureCompleteIndicator
    Log    check IgNBCAModificationRequest message
    ${CompleteIndicator}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${CompleteIndicator}    0

Check IgNBCAModificationAcknowledge message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 1 and nokiaxnap.procedureCode == 141
    ...    ${xpath}=.//nokiaxnap.Nokia_XnAP_PDU
    Log    check IgNBCAModificationRequest message
    ${XnAP_PDU}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${XnAP_PDU[0]}    1

Check UEContextModificationResponse has physcellid on PrimegNB
    [Arguments]    ${logname}    ${pci_scell}=${pci_scell}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList
    ...    ${xpath}=.//nr-rrc.sCellToAddModList
    ...    ${xpath1}=.//nr-rrc.physCellId
    Log    check UEContextModificationResponse message
    ${sCellToAddModList}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${physCellId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${sCellToAddModList[-1]}    1
    should contain    ${physCellId[-1]}    ${pci_scell}

Check UEContextModificationResponse has scellid on PrimegNB
    [Arguments]    ${logname}    ${pci_scell}=${pci_scell}    ${scell_num}=2
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num}
    ...    ${xpath}=.//nr-rrc.physCellId
    Log    check UEContextModificationResponse message
    ${physCellId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    List Should Contain Sub List    ${physCellId}    ${pci_scell}

Check UEContextModificationResponse has no the sCellToAddModList on PrimegNB
    [Arguments]    ${logname}    ${scell_num}=1
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num}
    ...    ${xpath}=.//nr-rrc.sCellToAddModList
    Log    check UEContextModificationResponse message
    ${sCellToAddModList}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be empty    ${sCellToAddModList}

Check UEContextModificationResponse carrierBandwidth on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList
    ...    ${xpath}=.//nr-rrc.carrierBandwidth
    Log    check carrierBandwidth message
    ${carrierBandwidth}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${carrierBandwidth[-1]}    106

Check IgNBCAContextSetupRequest message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.procedureCode == 192
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAContextSetupRequest message
    ${procedureCode}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${procedureCode[0]}    0

Check IgNBCAContextSetupResponse message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1 and nokiaf1ap.procedureCode == 192
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAContextSetupResponse message
    ${procedureCode}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${procedureCode[0]}    1

Check IgNBCAContextSetupFailure message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.transport == 1 and nokiaf1ap.procedureCode == 192
    ...    ${xpath}=.//nokiaf1ap.transport
    Log    check IgNBCAContextSetupFailure message
    ${transport_cause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${transport_cause[0]}    1

Check IgNBCAUeContextModificationRequest message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.procedureCode == 193
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAUeContextModificationRequest message
    ${procedureCode}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${procedureCode[0]}    0

Check IgNBCAUeContextModificationResponse message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1 and nokiaf1ap.procedureCode == 193
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAUeContextModificationResponse message
    ${procedureCode}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${procedureCode[0]}    1

####scell_addition_failure_log####
Check IgNBCAUEContextModificationFailure on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 2 and nokiaf1ap.procedureCode == 193
    ...    ${xpath}=.//nokiaf1ap.privateCause
    Log    check IgNBCAUEContextModificationFailure message has the cause "no-CA-eligible-DRB-found"
    ${privateCause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${privateCause[0]}    1

Check 2st IgNBCAUeContextModificationRequest has the cancel CA message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.queryPurpose == 1
    ...    ${xpath}=.//nokiaf1ap.queryPurpose
    Log    check IgNBCAUeContextModificationRequest has the cancel CA message
    ${queryPurpose}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${queryPurpose[0]}    1

Check IgNBCAAdditionReject message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 2 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.transport
    Log    check IgNBCAAdditionReject message has the cause "trasport-resource-unavailable"
    ${transport}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${transport[0]}    0

Check IgNBCAAdditionReject message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 2 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.radioNetwork
    Log    check IgNBCAAdditionReject message has the cause "no-raideo-resources-available"
    ${radioNetwork}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${radioNetwork[0]}    29

Check IgNBCAUeContextSetupFailure message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 192 and nokiaf1ap.Nokia_F1AP_PDU == 2
    ...    ${xpath}=.//nokiaf1ap.transport
    Log    check IgNBCAAdditionReject message has the cause "trasport-resource-unavailable"
    ${transport}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${transport[0]}    1

####check UErelease#####
Check UeContextReleaseCommand message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=ngap.procedureCode == 41 && ngap.nas == 2
    ...    ${xpath}=.//ngap.nas
    Log    check UeContextReleaseCommand has the deregister(2) message
    ${ngap_nas}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${ngap_nas[0]}    2

Check IgNBCAReleaseRequest message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.radioNetwork == 65
    ...    ${xpath}=.//nokiaxnap.radioNetwork
    ...    ${xpath1}=.//nokiaxnap.Ext_gNB_CU_UE_XnAP_ID
    Log    check IgNBCAReleaseRequest has the normal-release(65) message
    ${radioNetwork}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${radioNetwork[0]}    65
    Log    check IgNBCAReleaseRequest Ext-gNB-CU-UE-XnAP-ID
    ${xnap_id_request}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    set suite variable    ${xnap_id_request}

Check IgNBCAReleaseRequestAcknowledge message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 142 and nokiaxnap.Nokia_XnAP_PDU == 1
    ...    ${xpath}=.//nokiaxnap.Ext_gNB_CU_UE_XnAP_ID
    Log    check IgNBCAReleaseRequestAcknowledge message
    ${xnap_id}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${xnap_id}    ${xnap_id_request}

Check IgNBCAUeContextReleaseCommand message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 194 and nokiaf1ap.Nokia_F1AP_PDU == 0
    ...    ${xpath}=.//nokiaf1ap.radioNetwork
    Log    check UeContextReleaseCommand has the normal release message
    ${release_cause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${release_cause[0]}    10

Check IgNBCAUeContextReleaseComplete message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 194 and nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check UeContextReleaseCommand has the deregister message
    ${f1ap_pdu}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${f1ap_pdu[0]}    1

Check overheatingAssistanceConfig in RRC Reconfiguration when CA setup
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 12 and nr-rrc.overheatingAssistanceConfig and nr-rrc.overheatingIndicationProhibitTimer
    ...    ${xpath}=.//nr-rrc.overheatingAssistanceConfig
    ...    ${xpath1}=.//nr-rrc.overheatingIndicationProhibitTimer
    Log    Check overheatingAssistanceConfig in RRC Reconfiguration when CA setup
    ${overheatingAssistanceConfig}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${overheatingAssistanceConfig[0]}    1
    ${overheatingIndicationProhibitTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${overheatingIndicationProhibitTimer[0]}    2

Check overheatingAssistanceConfig in RRC Reconfiguration when scell release
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 12 and nr-rrc.overheatingAssistanceConfig and nr-rrc.SCellIndex
    ...    ${xpath}=.//nr-rrc.overheatingAssistanceConfig
    ...    ${xpath1}=.//nr-rrc.SCellIndex
    Log    Check overheatingAssistanceConfig in RRC Reconfiguration when scell release
    ${overheatingAssistanceConfig}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${overheatingAssistanceConfig[0]}    0
    ${SCellIndex}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${SCellIndex[0]}    1

####check Event and RRC Reconfiguration#####
Check RRC Reconfiguration message on PrimegNB
    [Arguments]    ${logname}    ${event}=NULL    ${rsrp}=NULL    ${rsrq}=NULL
    ...    ${message_filter}=nokiaf1ap.procedureCode == 12 && nr-rrc.eventId == ${event}
    ...    ${xpath}=.//nr-rrc.eventId
    ...    ${xpath1}=.//nr-rrc.measTriggerQuantity.rsrp
    ...    ${xpath2}=.//nr-rrc.measTriggerQuantity.rsrq
    Log    check RRC Reconfiguration message has eventid and rsrp/rsrq config
    ${eventId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should contain    ${eventId}    ${event}
    ${rsrp_value}=    Run keyword If    '${rsrp}'!='NULL'    Check wireshark log
    ...    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    Run keyword If    '${rsrp}'!='NULL'    Should contain    ${rsrp_value}    ${rsrp}
    ${rsrq_value}=    Run keyword If    '${rsrq}'!='NULL'    Check wireshark log
    ...    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    Run keyword If    '${rsrq}'!='NULL'    Should contain    ${rsrq_value}    ${rsrq}

Check A2 release RRC Reconfiguration message on PrimegNB
    [Arguments]    ${logname}    ${scell_release_index}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 12 && nr-rrc.sCellToReleaseList == 1
    ...    ${xpath}=.//nr-rrc.sCellToReleaseList
    ...    ${xpath1}=.//nr-rrc.SCellIndex
    ...    ${xpath2}=.//nr-rrc.eventId
    ...    ${xpath2}=.//nr-rrc.measTriggerQuantity.rsrp
    ...    ${xpath3}=.//nr-rrc.measTriggerQuantity.rsrq
    Log    check RRC Reconfiguration message has the scell to release
    ${scellreleaselist}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${scellreleaselist[0]}    1
    ${scellreleaseindex}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${scellreleaseindex}    ${scell_release_index}

    Log    check RRC Reconfiguration message has no eventid and rsrp/rsrq config
    ${eventId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    should be empty    ${eventId}


Check Measurement message on PrimegNB
    [Arguments]    ${logname}    ${pci_id}    ${event}=0
    ...    ${message_filter}=nokiaf1ap.procedureCode == 13 and nr-rrc.physCellId and nr-rrc.measResultServingMOList == ${${event}+1}
    ...    ${xpath}=.//nr-rrc.physCellId
    Log    check Measurement message has physCellId
    ${physCellId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should contain    ${physCellId}    ${pci_id}

Check has no Measurement message on PrimegNB
    [Arguments]    ${logname}    ${pci_id}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 13 and nr-rrc.physCellId
    ...    ${xpath}=.//nr-rrc.physCellId
    Log    check has no Measurement message
    ${physCellId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should Be Empty    ${physCellId}

Check the measurement report with A2 release
    [Arguments]    ${logname}    ${pci_id_list}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 13 and nr-rrc.measResultServingMOList == 3
    ...    ${xpath}=.//nr-rrc.physCellId
    Log    check has Measurement message
    ${physCellId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Lists Should Be Equal    ${physCellId}    ${pci_id_list}


Check IgNBCAAdditionRequest message has scellAdditionMethodIndicator
    [Arguments]    ${logname}    ${MethodIndicator}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 0 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.scellAdditionMethodIndicator
    Log    check IgNBCAAdditionRequest message has scellAdditionMethodIndicator
    ${Method}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${Method[0]}    ${MethodIndicator}

Check IgNBCAUeContextModificationRequest message has scell ToBeRemoved
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.id == 61721
    ...    ${xpath}=.//nokiaf1ap.nRCellIdentity
    Log    check IgNBCAUeContextModificationRequest message has scell ToBeRemoved
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ...    attribute_name=showname
    ${result_Hex}=    Split String    ${result[0]}    value
    ${result_Hex}=    Strip String    ${result_Hex[-1]}
    ${result_Hex}=    Remove String    ${result_Hex}    ]
    should be equal As Integers    ${result_Hex}    ${extcell_id}

Check has no IgnbCAUeContextModificationRequest and IgNBCAAdditionRequest message
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.id == 61721
    ...    ${message_filter1}=nokiaxnap.Nokia_XnAP_PDU == 0 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.scellAdditionMethodIndicator
    ...    ${xpath1}=.//nokiaf1ap.nRCellIdentity
    Log    check IgNBCAAdditionRequest message has scellAdditionMethodIndicator
    ${Message1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${Message2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    Should Be Empty    ${Message1}
    Should Be Empty    ${Message2}


Check IgNBCAUeContextModificationResponse message has scell ToBeRemoved
    [Arguments]    ${logname}    ${scelllcird}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1 and nr-rrc.SCellIndex
    ...    ${xpath}=.//nr-rrc.SCellIndex
    Log    check IgNBCAUeContextModificationResponse message has scell ToBeRemoved
    ${SCellIndex}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${SCellIndex[0]}    ${scelllcird}

### Check BCS #####
Check IgNBCAAdditionRequest message has no the BCS IE on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.allowUnsuppBcOrBcs
    ...    ${xpath}=.//nokiaxnap.allowUnsuppBcOrBcs
    Log    Check IgNBCAAdditionRequest message has no the BCS IE
    ${allowUnsuppBcOrBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should Be Empty    ${allowUnsuppBcOrBcs}

Check IgNBCAAdditionRequest message has the BCS IE on PrimegNB
    [Arguments]    ${logname}    ${allowBcs}=60    ${rejectBcs}=1
    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.allowUnsuppBcOrBcs
    ...    ${xpath}=.//nokiaxnap.allowUnsuppBcOrBcs
    ...    ${xpath1}=.//nokiaxnap.rejectSuppBcs
    Log    Check IgNBCAAdditionRequest message has no the BCS IE
    ${allowUnsuppBcOrBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${rejectSuppBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${allowUnsuppBcOrBcs[0]}    ${allowBcs}
    should be equal    ${rejectSuppBcs[0]}    ${rejectBcs}

Check IgNBCAUEContextSetupRequest message has no the BCS IE on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.allowUnsuppBcOrBcs
    ...    ${xpath}=.//nokiaf1ap.allowUnsuppBcOrBcs
    Log    Check IgNBCAAdditionRequest message has no the BCS IE
    ${allowUnsuppBcOrBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should Be Empty    ${allowUnsuppBcOrBcs}

Check IgNBCAUEContextSetupRequest message has the BCS IE on extgNB
    [Arguments]    ${logname}    ${allowBcs}=60    ${rejectBcs}=1
    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.allowUnsuppBcOrBcs
    ...    ${xpath}=.//nokiaf1ap.allowUnsuppBcOrBcs
    ...    ${xpath1}=.//nokiaf1ap.rejectSuppBcs
    Log    Check IgNBCAAdditionRequest message has no the BCS IE
    ${allowUnsuppBcOrBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${rejectSuppBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${allowUnsuppBcOrBcs[0]}    ${allowBcs}
    should be equal    ${rejectSuppBcs[0]}    ${rejectBcs}

Check IgNBCAGnbDuConfigurationIndication message has release scellid on Prime gNB
    [Arguments]    ${logname}    ${scell_id_release}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 195 and nokiaf1ap.nRCellIdentity
    ...    ${xpath}=.//nokiaf1ap.nRCellIdentity
    Log    IgNBCAGnbDuConfigurationIndication message has release scellid
    ${scell_id}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${scell_id_Hex}=    Split String    ${scell_id[0]}    value
    ${scell_id_Hex}=    Strip String    ${scell_id_Hex[-1]}
    ${scell_id_Hex}=    Remove String    ${scell_id_Hex}    ]
    should be equal As Integers    ${scell_id_Hex}    ${scell_id_release}

### Check DRX #####
Check UEContextModificationRequest message has Drx release on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nokiaf1ap.DRXConfigurationIndicator == 0
    ...    ${xpath}=.//nokiaf1ap.DRXConfigurationIndicator
    Log    Check UEContextModificationRequest message has Drx release
    ${DRX}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${DRX[0]}   0

Check IgNBCAModificationRequest message has Drx release on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 141 and nokiaxnap.DRXConfigurationIndicator == 0
    ...    ${xpath}=.//nokiaxnap.DRXConfigurationIndicator
    Log    IgNBCAModificationRequest message has Drx release
    ${DRX}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${DRX[0]}   0

Check DRX disable on PrimegNB
    [Arguments]    ${logname}    ${milliSeconds}=8    ${InactivityTimer}=14    ${StartOffset}=11
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.milliSeconds
    ...    ${message_filter1}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 1 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.drx_InactivityTimer
    ...    ${xpath2}=.//nr-rrc.drx_LongCycleStartOffset
    Log    Check ANR DRX enable
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${DRX_milliSeconds1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${DRX_milliSeconds2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    Should be equal    ${DRX_milliSeconds[0]}    ${milliSeconds}
    Should be equal    ${DRX_milliSeconds1[0]}    ${milliSeconds}
#    Should be equal    ${DRX_milliSeconds2[0]}    ${milliSeconds}

Check ANR DRX enable on PrimegNB
    [Arguments]    ${logname}    ${milliSeconds}=8    ${InactivityTimer}=14    ${StartOffset}=11
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.milliSeconds == ${milliSeconds}
    ...    ${message_filter1}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds == ${milliSeconds}
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 1 and nr-rrc.milliSeconds == ${milliSeconds}
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.drx_InactivityTimer
    ...    ${xpath2}=.//nr-rrc.drx_LongCycleStartOffset
    Log    Check ANR DRX enable
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${DRX_milliSeconds1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${DRX_milliSeconds2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${DRX_InactivityTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${DRX_InactivityTimer1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ${DRX_InactivityTimer2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath1}
    ${DRX_StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    ${DRX_StartOffset_1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath2}
    ${DRX_StartOffset_2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    Should be equal    ${DRX_milliSeconds}[0]   ${milliSeconds}
    Should be equal    ${DRX_milliSeconds1}[0]    ${milliSeconds}
#    Should be equal    ${DRX_milliSeconds2}[0]    ${milliSeconds}
    Should be equal    ${DRX_InactivityTimer}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer1}[0]    ${InactivityTimer}
#    Should be equal    ${DRX_InactivityTimer2}[0]    ${InactivityTimer}
    Should be equal    ${DRX_StartOffset}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_1}[0]    ${StartOffset}
#    Should be equal    ${DRX_StartOffset_2}[0]    ${StartOffset}

Check VONR DRX enable on PrimegNB
    [Arguments]    ${logname}    ${milliSeconds1}=5    ${milliSeconds2}=17     ${InactivityTimer}=14    ${StartOffset}=9
    ...    ${message_filter}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${message_filter1}=nokiaf1ap.procedureCode == 12 and nr-rrc.milliSeconds
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 7 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.drx_InactivityTimer
    ...    ${xpath2}=.//nr-rrc.drx_LongCycleStartOffset
    Log    Check VONR drx enable
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    ${DRX_milliSeconds1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${DRX_milliSeconds2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${DRX_InactivityTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    ${DRX_InactivityTimer1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ${DRX_InactivityTimer2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath1}
    ${DRX_StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
#    ${DRX_StartOffset_1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath2}
    ${DRX_StartOffset_2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    Should Contain any    ${DRX_milliSeconds}[0]    ${milliSeconds1}    ${milliSeconds2}
#    Should Contain any   ${DRX_milliSeconds1}[0]    ${milliSeconds1}    ${milliSeconds2}
    Should Contain any    ${DRX_milliSeconds2}[0]    ${milliSeconds1}    ${milliSeconds2}
    Should Contain any    ${DRX_milliSeconds2}[1]    ${milliSeconds1}    ${milliSeconds2}
    Should be equal    ${DRX_InactivityTimer}[0]    ${InactivityTimer}
#    Should be equal    ${DRX_InactivityTimer1}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer2}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer2}[1]    ${InactivityTimer}
    Should be equal    ${DRX_StartOffset}[0]    ${StartOffset}
#    Should be equal    ${DRX_StartOffset_1}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_2}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_2}[1]    ${StartOffset}

Check DRX enable on PrimegNB or Externgnb
    [Arguments]    ${logname}    ${milliSeconds}=17    ${milliSeconds2}=${milliSeconds}    ${InactivityTimer}=14    ${StartOffset}=13
    ...    ${message_filter}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.drx_InactivityTimer
    ...    ${xpath2}=.//nr-rrc.drx_LongCycleStartOffset
    Log    Check DRX enable
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${DRX_InactivityTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${DRX_StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    Should Contain any    ${DRX_milliSeconds[0]}   ${milliSeconds}    ${milliSeconds2}
    Should be equal    ${DRX_InactivityTimer[0]}    ${InactivityTimer}
    Should be equal    ${DRX_StartOffset[0]}   ${StartOffset}

Check DRX recover as attach on PrimegNB
    [Arguments]    ${logname}    ${milliSeconds}=17    ${InactivityTimer}=14    ${StartOffset}=13
    ...    ${message_filter}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${message_filter1}=nokiaf1ap.procedureCode == 12 and nr-rrc.milliSeconds
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 7 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.drx_InactivityTimer
    ...    ${xpath2}=.//nr-rrc.drx_LongCycleStartOffset
    Log    Check ANR DRX recover by A1
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    ${DRX_milliSeconds1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${DRX_milliSeconds2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${DRX_InactivityTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    ${DRX_InactivityTimer1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ${DRX_InactivityTimer2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath1}
    ${DRX_StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
#    ${DRX_StartOffset_1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath2}
    ${DRX_StartOffset_2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    Should be equal    ${DRX_milliSeconds}[0]   ${milliSeconds}
#    Should be equal    ${DRX_milliSeconds1}[0]    ${milliSeconds}
    Should be equal    ${DRX_milliSeconds2}[0]    ${milliSeconds}
    Should be equal    ${DRX_milliSeconds2}[1]    ${milliSeconds}
    Should be equal    ${DRX_InactivityTimer}[0]    ${InactivityTimer}
#    Should be equal    ${DRX_InactivityTimer1}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer2}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer2}[1]    ${InactivityTimer}
    Should be equal    ${DRX_StartOffset}[0]    ${StartOffset}
#    Should be equal    ${DRX_StartOffset_1}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_2}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_2}[1]    ${StartOffset}

Check CSIRS and CSI-reporting in onduration in UEContextModificationResponse
    [Arguments]    ${logname}   ${scell_num}=2   ${cycle}=20
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num} and nr-rrc.csi_IM_ResourceId == 0
    ...    ${xpath}=.//nr-rrc.periodicityAndOffset/nr-rrc.slots20
    ...    ${message_filter1}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num} and nr-rrc.reportConfigId == 0
    ...    ${xpath1}=.//nr-rrc.reportSlotConfig/nr-rrc.slots160
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num} and nr-rrc.drx_Config == 1
    ...    ${xpath2}=.//nr-rrc.ms160
    ${onduratin}    Get onduration slot    logname=${logname}    xpath1=${xpath2}
    ${onduratin_start}    Set variable    ${onduratin}[0]
    ${OndurationTimer}    Set variable    ${onduratin}[1]
    Log    check pcell's CSIRS period
    ${onduratin_start_CSIRS}=    Run Keyword IF    ${onduratin_start} >= 20    Evaluate    ${onduratin_start}%20
    ...    ELSE    Set Variable    ${onduratin_start}
    ${onduratin_end_CSIRS}=    Evaluate    ${onduratin_start_CSIRS} + ${ondurationTimer}
    ${value}    Run Keyword IF   ${onduratin_end_CSIRS} > 20    Evaluate    ${onduratin_end_CSIRS} - 20
    ...    ELSE    Set Variable    ${0}
    ${pcell_CSIRS}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${pcell_CSIRS}=    Run Keyword IF    ${pcell_CSIRS}[0] < ${value}  Evaluate    ${pcell_CSIRS}[0]+20
    ...    ELSE IF    ${pcell_CSIRS}[0] > ${onduratin_end_CSIRS}    Evaluate    ${pcell_CSIRS}[0]%20
    ...    ELSE   Set Variable    ${pcell_CSIRS}[0]
    Should Be True    ${onduratin_start_CSIRS} <= ${pcell_CSIRS} < ${onduratin_end_CSIRS}
    Log    check pcell's CSI-report period
    ${onduratin_start_report}=    Run Keyword IF    ${onduratin_start} >= ${cycle}    Evaluate    ${onduratin_start}%${cycle}
    ...    ELSE    Set Variable    ${onduratin_start}
    ${onduratin_end_report}=    Evaluate    ${onduratin_start_report} + ${ondurationTimer}
    ${value_report}    Run Keyword IF   ${onduratin_end_report} > ${cycle}    Evaluate    ${onduratin_end_report} - ${cycle}
    ...    ELSE    Set Variable    ${0}
    ${pcell_CSI-report}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ${pcell_CSI-report}=    Run Keyword IF    ${pcell_CSI-report}[0] < ${value}  Evaluate    ${pcell_CSI-report}[0]+${cycle}
    ...    ELSE IF    ${pcell_CSI-report}[0] > ${onduratin_end_report}    Evaluate    ${pcell_CSI-report}[0]%${cycle}
    ...    ELSE    Set Variable    ${pcell_CSI-report}[0]
    Should Be True    ${onduratin_start_report} <= ${pcell_CSI-report} < ${onduratin_end_report}
    [Return]

Get onduration slot
     [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.ms160
         Log    get OndurationTimer
    ${OndurationTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ...    attribute_name=showname
    ${OndurationTimer}=    Split String    ${OndurationTimer[0]}    :
    ${OndurationTimer}=    Strip String    ${OndurationTimer[-1]}
    ${OndurationTimer}=    Split String    ${OndurationTimer}    (
    ${OndurationTimer}=    Remove String    ${OndurationTimer[0]}    ms
    Log    get start offset
    ${StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    ${onduratin_end}=    Evaluate    ${StartOffset} + ${ondurationTimer}
    [Return]    ${StartOffset}[0]    ${OndurationTimer}

Check 2200 enable with Scell when attach
    [Arguments]    ${logname}    ${scell_num}=2    ${cycle}=80
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num} and nr-rrc.drx_Config == 1
    ...    ${xpath}=.//nr-rrc.ms160    ${index}=${3}    ${CSI_RS_index}=${1}
    ...    ${pscell_Meas}=.//nr-rrc.spCellConfigDedicated_element/nr-rrc.csi_MeasConfig/nr-rrc.setup_element/nr-rrc.csi_ReportConfigToAddModList
    ...    ${CSIRS_reporting}=/_[${index}]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element/nr-rrc.reportSlotConfig
    ...    ${xpath_scell1_CSIRS_reporting}=${pscell_Meas}${CSIRS_reporting}/nr-rrc.slots160
    ...    ${xpath_nrofPorts}=/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
    ...    ${xpath_scell1_CSIRS_slot}=/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.periodicityAndOffset/nr-rrc.slots80
    ${onduratin}    Get onduration slot    logname=${logname}    cycle=${cycle}    xpath1=${xpath}
    ${onduratin_start}    Set variable    ${onduratin}[0]
    ${onduratin_end}    Set variable    ${onduratin}[1]
    ${scell1_CSIRS_reporting}=    Check wireshark log    logname=${logname}
    ...    message_filter=${message_filter}    xpath=${xpath_scell1_CSIRS_reporting}
    @{2200_ports_list}    Create List
    @{CSIRS_slot_list}    Create List
    FOR    ${CSI_RS_index}    IN RANGE    1    5
        ${2200_ports}    Get scell CSIRS Resource with enable 2200   logname=${logname}
        ...    index=${CSI_RS_index}   scell_num=${scell_num}    xpath=${xpath_nrofPorts}
        Append TO List    ${2200_ports_list}    ${2200_ports}[0]
    END
    ${2200_ports_num}    Count values In list    ${2200_ports_list}   3
    FOR    ${CSI_RS_index}    IN RANGE    1    ${2200_ports_num}+1
        ${CSIRS_slot_list}    Get scell CSIRS Resource with enable 2200   logname=${logname}
        ...    index=${CSI_RS_index}   scell_num=${scell_num}    xpath=${xpath_scell1_CSIRS_slot}
        Append TO List    ${CSIRS_slot_list}    ${CSIRS_slot_list}[0]
    END
    Run Keyword IF    ${2200_ports_num} == ${1}    Run Keywords
    ...    Should Be True    ${onduratin_start} <= ${CSIRS_slot_list}[0] < ${onduratin_end}    AND
    ...    Should Be True    ${onduratin_start} <= ${scell1_CSIRS_reporting}[0] < ${onduratin_end}
    ...    ELSE IF    ${2200_ports_num} == ${2}    Run keywords
    ...    Should Be True    ${onduratin_start} <= ${CSIRS_slot_list}[0] < ${onduratin_end}    AND
    ...    Should Be True    ${onduratin_start} <= ${CSIRS_slot_list}[1] < ${onduratin_end}    AND
    ...    Should Be True    ${onduratin_start} <= ${scell1_CSIRS_reporting}[0] < ${onduratin_end}
    ...    ELSE    Should Be True    ${2200_ports_num} == ${4}

Get scell CSIRS Resource with enable 2200
    [Arguments]    ${logname}    ${scell_num}=2   ${index}=${1}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num} and nr-rrc.drx_Config == 1
    ...    ${scell1_Meas}=.//nr-rrc.sCellToAddModList/_[1]/nr-rrc.SCellConfig_element/nr-rrc.sCellConfigDedicated_element/nr-rrc.csi_MeasConfig
    ...    ${scell1_CSRIS}= /nr-rrc.setup_element/nr-rrc.nzp_CSI_RS_ResourceToAddModList
    ...    ${xpath}=/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
    ${CSIRS Resource}    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=${scell1_Meas}${scell1_CSRIS}/_[${index}]${xpath}
    [Return]    ${CSIRS Resource}

###cell info###
Get cell id 2gnb
    [Arguments]    ${lcrid}=${1}    ${lcrid_gnb2}=${1}    ${PrimegNB_index}=${0}    ${extgNB_index}=${1}
    ${primecell1_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid}    gnb_index=${PrimegNB_index}
    set suite variable    ${primecell1_id}
    ${extcell_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid_gnb2}    gnb_index=${extgNB_index}
    set suite variable    ${extcell_id}

Get gnb length from webEM
    [Arguments]    ${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${gNbIdLength_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${gNbIdLength_value}=    selenium_coam.get_parameter_value    dist_name=${gNbIdLength_distname}
    ...    filter_param=gNB id length    abbr=gNbIdLength
    Run Keyword And Ignore Error    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [Return]    ${gNbIdLength_value}    ${bts_id}


Gnb id conversion
    [Arguments]    ${WEBUI_COAM}
     @{gNb_Message}    Get gnb length from webEM    WEBUI_COAM=${WEBUI_COAM}
     ${gNbIdLength}    set variable    ${gNb_Message}[0]
     ${bts_id}    set variable    ${gNb_Message}[1]
     ${gNbIdLength_int}    Convert to Integer    ${gNbIdLength}
     ${remainder}    Evaluate    ${gNbIdLength_int}%4
     ${gNbId_DEC}    Run Keyword If    ${remainder}==${0}    set variable    ${bts_id}
     ...    ELSE   Evaluate    2**${remainder}*${bts_id}
      ${gNbId_DEC_int}    Convert to Integer    ${gNbId_DEC}
     [Return]    ${gNbId_DEC_int}

Get 2gnb length with HEX
    ${gNb1Id_DEC}    Gnb id conversion    WEBUI_COAM=${WEBUI_host0}
    set suite variable    ${gNb1Id_DEC}
    ${gNb2Id_DEC}    Gnb id conversion    WEBUI_COAM=${WEBUI_host1}
    set suite variable    ${gNb2Id_DEC}

Get value of parameter from WEBEM
    [Arguments]    ${value}    ${dist_name}    ${filter_param}    ${abbr}    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${parameter_value}=    selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=${filter_param}    abbr=${abbr}
    Should Be Equal    ${parameter_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

############### cell lock/unlock #######################
GNB Cell Lock Or Unlock And Check Status
    [Arguments]    ${Modify_Para_Online_GNB}    ${is_locked}=True
    ...    ${gnb_index}=${0}    ${cell_idx}=${1}   ${cell_group_idx}=${0}
    Run keyword If    '${gnb_index}'=='${0}'
    ...    Common Case TestLine Setup
    ...    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_GNB}
    ...    ELSE    Common Case TestLine Setup
    ...    ModifySCF_Aftercommission_for_GNB2=True    Modify_Para_Online_GNB2=${Modify_Para_Online_GNB}
    Wait Until Keyword Succeeds    180sec    30 sec    Cell Should Be Lock or Unlock
    ...    gnb_index=${gnb_index}    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}    is_locked=${is_locked}
    Run keyword If    ${is_locked}!=True
    ...    Wait Until Keyword Succeeds    180sec    30 sec    Check the cells status on air    bts_host=${bts_host${gnb_index}}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Cell Should Be Lock or Unlock
    [Arguments]    ${gnb_index}=${0}    ${cell_idx}=${1}    ${cell_group_idx}=${0}    ${is_locked}=True
    Connect to gnb coam via ssl    bts_host=${bts_host${gnb_index}}
    Run keyword If    ${is_locked}==True    Cell Should Be Locked
    ...    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
    ...    ELSE    Cell Should Be UnLocked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Hanging resource test
    [Arguments]    ${gnb_ips}=@{gnb_ips}    ${ue_index}=${0}
    [Documentation]    hanging resource test
    [Timeout]    1hour
    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ue_index=${ue_index}

######## check attach and detach wireshark log ##########
Check attach and detach wireshark log
    [Arguments]    ${logname}    ${logname1}    ${Primegnb_index}=${0}    ${extgnb_index}=${1}
    Check attach wireshark log    logname=${logname}    logname1=${logname1}
    ...    Primegnb_index=${Primegnb_index}    extgnb_index=${extgnb_index}
    Check detach wireshark log    logname=${logname}    logname1=${logname1}

Check attach wireshark log
    [Arguments]    ${logname}    ${logname1}    ${Primegnb_index}=${0}    ${extgnb_index}=${1}    ${pci_scell}=${pci_scell}
    ...    ${IP_type_Xpath}=.//nokiaxnap.TransportLayerAddressIPv4    ${xgU_addr_prime}=${xpu_gnb${${Primegnb_index}+${1}}}
    ...    ${xgU_addr_Ext}=${xpu_gnb${${extgnb_index}+${1}}}
    ### PrimegNB log###
    Check 1st IgNBCAUeContextModificationRequest message has igNBCASetup on PrimegNB   logname=${logname}
    Check IgNBCAUeContextModificationResponse has messages on PrimegNB   logname=${logname}
    Check IgNBCAAdditionRequest message has pGNBIP and pcellid and scellid on PrimegNB   logname=${logname}
    ...    gnb_index=${Primegnb_index}    xpath=${IP_type_Xpath}    xpu_gnb=${xgU_addr_prime}
    Check IgNBCAAdditionAcknowledge message has eGNBIP and scellid on PrimegNB   logname=${logname}
    ...    gnb_index=${extgnb_index}    xpath=${IP_type_Xpath}    xpu_gnb=${xgU_addr_Ext}
    Check 2st has the IgNBCAUeContextModificationRequest message on PrimegNB   logname=${logname}
    Check IgNBCAModificationAcknowledge message on PrimegNB    logname=${logname}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}    pci_scell=${pci_scell}
    ### ExtgNB log###
    Check IgNBCAContextSetupRequest message on extgNB    logname=${logname1}
    Check IgNBCAContextSetupResponse message on extgNB    logname=${logname1}
    Check IgNBCAUeContextModificationRequest message on extgNB    logname=${logname1}
    Check IgNBCAUeContextModificationResponse message on extgNB    logname=${logname1}

Check detach wireshark log
    [Arguments]    ${logname}    ${logname1}
    ### PrimegNB log###
    Check UeContextReleaseCommand message on PrimegNB    logname=${logname}
    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname}
    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname}
    ### ExtgNB log###
    Check IgNBCAUeContextReleaseCommand message on extgNB    logname=${logname1}
    Check IgNBCAUeContextReleaseComplete message on extgNB    logname=${logname1}

Check attach wireshark log failed
    [Arguments]    ${logname}
    Check has no the IgNBCAUeContextModificationRequest message   logname=${logname}
    Check UEContextModificationResponse has no the sCellToAddModList on PrimegNB    logname=${logname}

Check pscell and scell release wireshark log
    [Arguments]    ${logname}    ${logname1}
    ### PrimegNB log###
    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname}
    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname}
    ### ExtgNB log###
    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname1}
    Check IgNBCAUeContextReleaseCommand message on extgNB    logname=${logname1}
    Check IgNBCAUeContextReleaseComplete message on extgNB    logname=${logname1}
    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname1}

######### check Mearsurement report A1/A2 scell addition/release#########
Check wireshark log for Measurement EventA1/A2
    [Arguments]    ${logname}    ${event}=0    ${rsrp}=NULL    ${rsrq}=NULL    ${pci_id}=${pci_pcell}
    Check RRC Reconfiguration message on PrimegNB    logname=${logname}    event=${event}    rsrp=${rsrp}    rsrq=${rsrq}
    Check Measurement message on PrimegNB    logname=${logname}    pci_id=${pci_id}    event=${event}

Check gNBs Scells selection
    [Arguments]    ${logname}    ${numberOfActiveUEs_value}    ${numberOfActiveUlUEs_value}
    ...    ${gnb_index}    ${cell_index}    ${golden_scf_name_gnb}=golden_scf_name_gnb    ${scell_nums}=1
    Check numberOfActiveUEs and numberOfActiveUlUEs    logname=${logname}    numberOfActiveUEs_value=${numberOfActiveUEs_value}
    ...    numberOfActiveUlUEs_value=${numberOfActiveUlUEs_value}    xnap_gnb=${xnap_gnb${${gnb_index}+${1}}}
    @{scell_gnb}    Create List
    FOR   ${index}   IN RANGE    ${0}    ${scell_nums}
        log    ${index}
        ${scell}=    Get physCellId from SCF    golden_scf_name=${${golden_scf_name_gnb}${gnb_index}}
        ...    gnb_index=${gnb_index}    cell_index=${cell_index[${index}]}
        Append to List    ${scell_gnb}    ${scell}
    END
    Check UEContextModificationResponse has scellid on PrimegNB    logname=${logname}    pci_scell=${scell_gnb}
    ...    scell_num=${scell_nums}
######### check RRC reestablishment #########
Check RRC Reestablishment message on PrimegNB
    [Arguments]    ${logname}    ${RRE_source_physcellid}    ${RRE_target_cellid}
    ...    ${message_filter}=nr-rrc.reestablishmentCause == 2 && nr-rrc.c1 == 2
    Log    check RRC Reestablishment has other failure
    ${rrestablishmentCause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=.//nr-rrc.reestablishmentCause
    should be equal    ${rrestablishmentCause[0]}    2
    Log    check RRC Reestablishment has source physcellid
    ${physcellid_id}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=.//nr-rrc.physCellId
    should be equal    ${physcellid_id[0]}    ${RRE_source_physcellid}
    Log    check RRC Reestablishment has target cellid
    ${cell_id}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=.//nokiaf1ap.nRCellIdentity
    ...    attribute_name=showname
    ${cell_id_Hex}=    Split String    ${cell_id[0]}    value
    ${cell_id_Hex}=    Strip String    ${cell_id_Hex[-1]}
    ${cell_id_Hex}=    Remove String    ${cell_id_Hex}    ]
    should be equal As Integers    ${cell_id_Hex}    ${RRE_target_cellid}

Check UEContextModifucationRequest message
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.TransmissionActionIndicator == 1 and nokiaf1ap.RRCReconfigurationCompleteIndicator == 0
    ...    ${xpath}=.//nokiaf1ap.RRCReconfigurationCompleteIndicator
    Log    Check UEContextModifucationRequest has RRCReconfigurationCompleteIndicator
    ${UEContextModifucationRequest}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=${xpath}
    should be equal    ${UEContextModifucationRequest[0]}    0

######### check HO  #########
Check intergNB HO process on source gNB
    [Arguments]    ${logname}    ${ip_source}=${xnap_gnb1}    ${ip_target}=${xnap_gnb2}
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 0 and ip.src == ${ip_source}
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 0 and ip.src == ${ip_target}
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 6
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 2 and xnap.XnAP_PDU == 0
    ...    xpath=.//nokiaxnap.procedureCode
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel}=    Check wireshark log    logname=${logname}    message_filter=nokiaf1ap.procedureCode == 6 and nokiaf1ap.radioNetwork == 10
    ...    xpath=.//nokiaf1ap.radioNetwork
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC}=    Check wireshark log    logname=${logname}    message_filter=nokiaf1ap.procedureCode == 6 and nokiaf1ap.F1AP_PDU == 1
    ...    xpath=.//nokiaf1ap.F1AP_PDU
    should contain    ${UE_Cont_relC}    1


Check intergNB HO process on target gNB
    [Arguments]    ${logname}    ${ip_source}=${xnap_gnb1}    ${ip_target}=${xnap_gnb2}    ${npap_ip_target}=${bts_host1}
    ####HandoverRequest
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 0 and ip.dst == ${ip_source}
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 0 and ip.src == ${ip_source}
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 25 and ip.src == ${npap_ip_target}
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 25 and ip.dst == ${npap_ip_target}
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 6
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${UE_rel[0]}    6
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ...    xpath=.//ngap.radioNetwork
    should not contain    ${UE_contextreleasereq}    0

Check intergNB NGHO process on source gNB
    [Arguments]    ${logname}    ${ip_source}=${xnap_gnb1}    ${ip_target}=${xnap_gnb2}
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
    Log To Console    PathSwitchRequest
    ${Transfer}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 7
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${Transfer[0]}    7
    ####HandoverNotify
    Log To Console    PathSwitchRequestAckonwledge
    ${HandoverNotify}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 11
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HandoverNotify[0]}    11

Check intra-F intra-gNB HO procedure
    [Arguments]    ${logname}    ${target_cellID}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 13 and nr-rrc.measResultListNR == 1
    ...    ${xpath_filter}=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId
    ${filtered_value}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=${xpath_filter}
    should be equal    ${filtered_value[0]}    ${target_cellID}

Check wireshark log for Measurement EventA1 after HO
    [Arguments]    ${logname}    ${event}=0    ${rsrp}=NULL    ${rsrq}=NULL    ${pci_id}=${pci_pcell}
    Check RRC Reconfiguration message after HO   logname=${logname}    event=${event}    rsrp=${rsrp}    rsrq=${rsrq}
    Check Measurement message on PrimegNB    logname=${logname}    pci_id=${pci_id}    event=${event}

Check RRC Reconfiguration message after HO
    [Arguments]    ${logname}    ${event}=NULL    ${rsrp}=NULL    ${rsrq}=NULL
    ...    ${message_filter}=nokiaf1ap.procedureCode == 5 && nr-rrc.eventId == ${event}
    ...    ${xpath}=.//nr-rrc.eventId
    ...    ${xpath1}=.//nr-rrc.measTriggerQuantity.rsrp
    ...    ${xpath2}=.//nr-rrc.measTriggerQuantity.rsrq
    Log    check RRC Reconfiguration message has eventid and rsrp/rsrq config
    ${eventId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should Contain    ${eventId}    ${event}
    ${rsrp_value}=    Run keyword If    '${rsrp}'!='NULL'    Check wireshark log
    ...    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    Run keyword If    '${rsrp}'!='NULL'    Should Contain   ${rsrp_value}    ${rsrp}


###### UE #########
Prepare UE and detach UE
    [Arguments]    ${ue_type}=${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}

MultiUE.Prepare UE
    [Arguments]    ${ue_num}=${5}
    FOR   ${ue_index}   IN RANGE    ${0}    ${ue_num}
        power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...    detach_request=${True}    power_reset=True    get_spark_license=False
        sleep    10s
    END

MultiUE.Attach
    [Arguments]    ${ue_index}=${0}
    ${res}    run keyword and ignore error   power_ue.UE Attach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=true
    sleep    10s
    log    ${res}
    run keyword if    '${res[0]}'!='PASS'   Run Keyword And Continue On Failure
    ...    Basic.ThroughExceptionWithMsg    msg=Attach UE_${ue_index} Failed
    ${res}    run keyword and ignore error   power_ue.Verify attach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    4G_check=False
    run keyword if    '${res[0]}'!='PASS'   Run Keyword And Continue On Failure
    ...     Basic.ThroughExceptionWithMsg    msg=Check Attach UE_${ue_index} Failed
    log to console   UE attach completed

MultiUE.Detach
    [Arguments]    ${ue_index}=${0}
    power_ue.UE Detach
    ...   ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=True

MultiUE.Start DL Traffic
    [Arguments]    ${throughput_for_DL}=5   ${direction}=dl   ${ue_index}=${0}    ${duration}=600    ${protocol}=UDP
     ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}    ${APN}=dxdata1    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    power_ue.Start traffic
        ...    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}
        ...    throughput=${throughput_for_DL}MKbits/sec
        ...    duration=${duration}
        ...    apn_address=${APN}
        ...    ue_mode=SA
        ...    iperf_port=${iperf_port}
        ...    multidrb_QoS_dest=${None}
        ...    protocol=${protocol}

MultiUE.Start UE DLUL traffic
    [Arguments]    ${dl_throughput}=${Send_Tput_DL_MultiUE}    ${ul_throughput}=${Send_Tput_UL_MultiUE}
    ...    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...    ${duration}=600    ${ue_index}=${7}    ${APN}=dxdata1
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${dl_throughput}   duration=${duration}
    ...   APN=${APN}    iperf_port=${iperf_port}
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${ul_throughput}   duration=${duration}    direction=ul
    ...   APN=${APN}    iperf_port=${iperf_port}

MultiUE.Stop DL Traffic
    [Arguments]    ${direction}=dl   ${ue_index}=${0}
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    power_ue.Stop traffic
        ...    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}
        ...    apn_address=dxdata1
        ...    iperf_port=${tl.ues[0].iperf_details.port}

MultiUE.Start DLUL traffic and check 2CC tput
    [Arguments]    ${scellid}=1    ${pcellid}=1    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul}    ${tput_ul_scell}=NULL    ${dl_port}=${DL_PORT_387}
    ...    ${gnb_prime}=${0}    ${gnb_external}=${1}    ${dl_throughput}=${Send_Tput_DL_MultiUE}    ${APN}=dxdata1
    ...    ${ul_throughput}=${Send_Tput_UL}    ${protocol}=${protocol_UDP}    ${ue_index}=${7}    ${duration}=600
    Run keyword If    '${protocol}'=='tcp'
    ...    Start UE DLUL TCP traffic    ELSE
    ...    MultiUE.Start UE DLUL traffic    ue_index=${ue_index}    dl_throughput=${dl_throughput}
    ...    ul_throughput=${ul_throughput}    duration=${duration}    APN=${APN}    iperf_port=${dl_port}
    sleep    60s
    Check 2CC DLUL tput     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    tput_ul_scell=${tput_ul_scell}    scellid=${scellid}    pcellid=${pcellid}
    ...    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}

MultiUE.Start DL traffic parallel and check 2CC tput
    [Arguments]    ${scellid}=1    ${pcellid}=1    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul}    ${dl_port_mdrb}=${DL_PORT_387}    ${gnb_prime}=${0}
    ...    ${gnb_external}=${1}    ${Send_Tput_DL_DRB7}=${Send_Tput_DL_DRB7}    ${Send_Tput_DL_DRB9}=${Send_Tput_DL_DRB9}
    ...    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${7}    ${duration}=600    ${APN}=dxdata1
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${Send_Tput_DL_DRB9}   duration=${duration}
    ...   APN=${APN}    iperf_port=${dl_port_mdrb}
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${Send_Tput_DL_DRB7}   duration=${duration}
    ...   APN=${APN}
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${ul_throughput}   duration=${duration}    direction=ul
    ...   APN=${APN}    iperf_port=${dl_port_mdrb}
    Check 2CC DLUL tput     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    scellid=${scellid}    pcellid=${pcellid}    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}

MultiUE.Stop DLUL traffic
    [Arguments]    ${ue_index}=${0}   ${APN}=dxdata1    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...    ${iperf_port_mdrb}=NULL
    power_ue.Stop traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
        ...    apn_address=${APN}
        ...    iperf_port=${iperf_port}
    run keyword If    '${iperf_port_mdrb}'!='NULL'
    ...    power_ue.Stop traffic
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
    ...    apn_address=${APN}
    ...    iperf_port=${iperf_port_mdrb}
    power_ue.Stop traffic
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=ul
    ...    apn_address=${APN}
    ...    iperf_port=${iperf_port}

Make VONR call
   [Arguments]    ${ue_index}=0
   spark.send AT command CPE     param=ATD006688;     ue_alias=UE_${ue_index}
   ${Vonr_call_status}    Run Keyword And Continue On Failure   spark.get Vonr call status on ue
   ...      ue_alias=UE_${ue_index}   param={"LastEventIndex":0}
   run keyword if    '${Vonr_call_status}'=='True'    sleep    10s
   ...    ELSE  Fail    VONR call failed

MultiUE.Change APN
    [Arguments]    ${APN}=dxdata1    ${ue_index}=S{7}
    MultiUE.Attach    ue_index=${ue_index}
    Sleep    2s
    Spark.send AT command CPE     param=at+cgdcont=1,"IP","${APN}";     ue_alias=UE_${ue_index}
    Sleep    2s
    MultiUE.Detach    ue_index=${ue_index}

Basic.ThroughExceptionWithMsg
    [Arguments]     ${msg}
    Fail    ${msg}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

#### get value from GNB
Check value of parameter xgUplane address
    [Arguments]    ${WEBUI_COAM}=${WEBUI_host0}   ${SNSSAI}=true
    ...    ${xgU_addr}=ipV6AddressDN1    ${filter_param_DN}=IPv6 address 1 distinguished name
    ...    ${filter_param_local}=Local IPv6 address
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Run keyword If    '${SNSSAI}'=='true'
    ...    Set suite Variable    ${xgUplane_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1    ELSE
    ...    Set suite Variable    ${xgUplane_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ${xgUplane_address_value}=    selenium_coam.get_parameter_value    dist_name=${xgUplane_distname}
    ...    filter_param=${filter_param_DN}    abbr=${xgU_addr}
    ${xgUplane_address}=    selenium_coam.get_parameter_value    dist_name=${xgUplane_address_value}
    ...    filter_param=${filter_param_local}    abbr=localIpAddr
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [Return]    ${xgUplane_address}
