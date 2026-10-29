# *** Settings ***
# Force Tags    PY36
# Documentation    author: Tian chun
# ...              contact: chun.tian@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Suite Setup
# Suite Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# #Resource   taf.sbts.oam.coam.admin              WITH NAME    coam
# Library    taf.transport.ssh    WITH NAME    csn
# Library    taf.sbts.oam.coam.admin    WITH NAME    coam
# Library    taf.analyzer.pcap    WITH NAME    cap
# Library    BuiltIn
# Library    String
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${BTS_NAME}    ${tl.gnbs[1].global_bts_id}
# ${BTS_NAME_first}    ${tl.gnbs[0].global_bts_id}
# ${dist_name}    MRBTS-${BTS_NAME_first}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
# ${dist_name_first}    MRBTS-${BTS_NAME_first}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-3
# ${dist_name_second}    MRBTS-${BTS_NAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-3
# ${dist_name_second_two}      MRBTS-${BTS_NAME}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
# ${DU_OAM_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection[0].addr}
# ${DU_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection[0].username}
# ${DU_OAM_SSH_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection[0].password}
# 
# ${DU_second_ip}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection[1].addr}
# ${DU_second_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection[1].username}
# ${DU_second_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection[1].password}
# ${WEBEM_USERNAME}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBEM_PASSWORD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${filename_port1}    capture_EIF5.pcap
# ${filename_port8}    capture_EIF6.pcap
# ${filename}    tcpdump.pcap
# ${log_dir}    /tmp
# ${listen_port}    fp0
# ${UTE_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
# ${UTE_username}    ${tl.test_pc.default_ssh_connection_details.username}
# ${UTE_password}    ${tl.test_pc.default_ssh_connection_details.password}
# ${testcenter_UL}    test_UL.tcl
# ${testcenter_DL}    test_DL.tcl
# ${testcenter_UL_DL}        case06.tcl
# ${LOG_PATH}    /home/ute/Downloads/1566_A
# ${src_ip_value}    192.168.101.98
# ${dest_ip_value}    10.57.228.126
# ${connection}    du_conn
# ${class_name}    ETHIF_R
# ${MAC_ADDRESS}   00:10:94:00:00:04
# 
# *** Test Cases ***
# [1] 5GC001566-5GC000519-A_002_Flexible_configuration_of_EIF1_used_for_F1_and_EIF2_locked_with_Chaining_feature_activated_of_cloud_NSA
#     [Tags]    CRT_20B
#     [Setup]
#     Change parameter
#     Change parameter    dist_name=${dist_name_first}    parameter=administrativeState    value=unlocked
#     Change parameter    oam_ip=${DU_second_ip}
#     ...        dist_name=${dist_name_second}    parameter=administrativeState    value=locked
#     sleep   10s
#     Send Testcenter packet for traffic    testcenter_traffic=${testcenter_UL_DL}
#     Check traffic by counter    connection=${connection}
#     Check log by counter    connection=${connection}
#     [Teardown]  Recovery env
# 
# [1]5GC001566-5GC000519-A_004_Configure_no_Ethernet_switching_between_physical_Transport_Ethernet_switch_ports_of_cloud_NSA
#     [Tags]    CRT_20B
#     [Documentation]
#     ...  This case is used to verify that configure no Ethernet switching of EIF1 used for backhaul (C,M,U)traffic
#     [Setup]
#     Change parameter
#     Change parameter    oam_ip=${DU_second_ip}
#     ...    dist_name=${dist_name_second_two}    parameter=l2SwitchingEnabled    value=true
#     sleep   5s
#     Send Testcenter packet for traffic    testcenter_traffic=${testcenter_UL}
#     Read And Check in tcpdump   filename=${filename_port1}    src_ip=${src_ip_value}    dest_ip=${dest_ip_value}
#     sleep  5s
#     Send Testcenter packet for traffic    testcenter_traffic=${testcenter_DL}
#     Read And Check in tcpdump    filename=${filename_port8}    src_ip=${dest_ip_value}    dest_ip=${src_ip_value}
#     Change parameter   oam_ip=${DU_second_ip}
#     ...    dist_name=${dist_name_second_two}    parameter=l2SwitchingEnabled    value=false
#     Check log by counter    connection=${connection}
#     [Teardown]  Recovery env again
# 
# [1]5GC001566-A_006_Configure_of_EIF1_and_EIF2_for_backhaul_of_Ethernet_switch_MAC_address_learning_and_ageing_of_cloud_NSA
#    [Documentation]
#     ...  This case is used to verify that Vlan aware ethernet switch of EIF1 used for
#     ...  M/ F1-C/F1-U traffic, EIF2 used for Chaining on webGUI or NetAct on cloud BTS with Ethernet
#     ...  switch MAC address learning of NSA
#     [Tags]    CRT_20B
#     [Setup]
#     Change parameter    dist_name=${dist_name_first}    parameter=administrativeState    value=unlocked
#     sleep   5s
#     Change parameter    oam_ip=${DU_second_ip}
#     ...    dist_name=${dist_name_second}    parameter=administrativeState    value=unlocked
#     Send Testcenter packet for traffic    testcenter_traffic=${testcenter_UL_DL}
#     sleep   60s
#     ${unlocked_skip}    get mac address table    mac_address=${mac_address}
#     should be equal as strings    @{unlocked_skip}[0]    0
#     Change parameter    dist_name=${dist_name_first}    parameter=administrativeState    value=locked
#     sleep    8min
#     ${locked_skip}    get mac address table    mac_address=${mac_address}
#     should be equal as strings    @{locked_skip}[0]    1
#     Change parameter    dist_name=${dist_name_first}    parameter=administrativeState    value=unlocked
#     Send Testcenter packet for traffic    testcenter_traffic=${testcenter_UL_DL}
#     sleep   60s
#     ${second_unlocked_skip}    get mac address table    mac_address=${mac_address}
#     should be equal as strings    @{second_unlocked_skip}[0]    0
#     [Teardown]    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# get DU mac address
#     [Arguments]    ${oam_ip}=${DU_OAM_IP}    ${username}=${DU_second_username}    ${password}=${DU_second_password}
#     ${conn_second}    Connect to DU    ip=${oam_ip}    username=${username}    password=${password}    alias=OAM_admin
#     ${ETTHI_info}    coam.get_managed_objects     class_name=${class_name}    connection=${conn_second}
#     ${mac}    set variable    ${None}
#     FOR    ${item}    IN    @{ETTHI_info}
#          ${parameters}    get from dictionary    ${item}    parameters
#          ${mac}    get from dictionary    ${parameters}    macAddr
#          exit for loop if    '${mac}'!='${None}'
#     END
#     log to console    ${mac}
#     [Return]    ${mac}
#     [Teardown]    Disconnect from Du
# 
# Read And Check in tcpdump
#     [Arguments]    ${filename}    ${src_ip}    ${dest_ip}    ${filter}=${None}
#     csn.connect_to    hostname=${UTE_IP}    username=${UTE_username}    password=${WEBEM_PASSWORD}
#     ...    alias=connection_ute
#     csn.send command   command=/usr/bin/tshark -r ${LOG_PATH}/${filename} -X -Y "ip.src==${src_ip}"
#     ...    connection=connection_ute
#     ${return_value}    csn.Read Output    connection=connection_ute
#     run keyword and continue on failure    should not be empty    ${return_value}
#     sleep    10s
#     csn.Disconnect    connection=connection_ute
# 
# get parameter
#     [Arguments]    ${oam_ip}=${DU_OAM_IP}    ${username}=${WEBEM_USERNAME}    ${password}=${WEBEM_PASSWORD}
#     ...   ${dist_name}=${VLAN_DIST_NAME}    ${parameter}=administrativeState
#     ${conn_second}    Connect to DU    ip=${oam_ip}    username=${username}    password=${password}    alias=OAM_admin
#     ${parameter_dict}    coam.get_parameters     dist_name=${dist_name}    parameter=${parameter}    connection=OAM_admin
#     log    ${parameter_dict}
#     [Return]    ${administrative_state}
#     [Teardown]    Disconnect from Du
# 
# get mac address table
#     [Arguments]    ${mac_address}=${MAC_ADDRESS}    ${du_ip}=${DU_OAM_IP}    ${username}=${DU_SSH_USERNAME}
#     ...  ${password}=${DU_OAM_SSH_PASSWORD}    ${connection}=GNB_DU
#     csn.connect to    hostname=${du_ip}    username=${username}    password=${password}    alias=${connection}
#     csn.send_command     command=cat /var/run/cpss/mac_address_table | grep ${mac_address} |awk '{print $5}'   connection=${connection}
#     ${skip}    csn.read output    connection=${connection}
#     ${skip_list}    split string    ${skip}    \n
#     remove values from list     ${skip_list}   ${SPACE}
#     [Teardown]      csn.disconnect    connection=${connection}
#     [Return]     ${skip_list}
# 
# Change parameter
#     [Arguments]    ${oam_ip}=${DU_OAM_IP}    ${username}=${WEBEM_USERNAME}    ${password}=${WEBEM_PASSWORD}
#     ...   ${dist_name}=${dist_name}    ${parameter}=l2SwitchingEnabled    ${value}=true
#     ${conn_second}    Connect to DU    ip=${oam_ip}    username=${username}    password=${password}
#     coam.perform_parameter_recommissioning     dist_name=${dist_name}
#     ...                                        parameter=${parameter}
#     ...                                        operation=update
#     ...                                        value=${value}
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=${conn_second}
#     [Teardown]    Disconnect from Du
# 
# Connect to DU
#      [Arguments]    ${ip}    ${username}   ${password}    ${alias}=OAM_admin
#     ${conn_second}=    coam.connect_to
#     ...    bts_host=${ip}
#     ...    username=${username}
#     ...    password=${password}
#     ...    name=${alias}
#     [Return]    ${conn_second}
# 
# Disconnect from DU
#     [Arguments]    ${alias}=OAM_admin
#     coam.teardown     connection=${alias}
# 
# Send Testcenter packet for traffic
#     [Arguments]    ${testcenter_traffic}=${testcenter_UL}    ${container_alias}=ute_conn
#     csn.connect_to
#     ...    hostname=${UTE_IP}
#     ...    username=${UTE_username}
#     ...    password=${UTE_password}
#     ...    alias=${container_alias}
#     csn.Send Command  command=sudo tclsh ${CURDIR}/Resources/${testcenter_traffic}
#     ...    connection=${container_alias}
#     log to console  send Testcenter packet successful
#     log to console  wait 15s
#     sleep   15s
#     [Teardown]  csn.disconnect   connection=${container_alias}
# 
# Read tcpdump log
#     [Arguments]    ${filename}    ${src_ip}    ${dest_ip}    ${filter}=${None}
#     cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}
#     log to console  Read Wireshark Log successful
#     ${return_src_ip}     Get PARAM Value from Wireshark Log   check_param=ip.src
#     ...    element_idx=${0}     condition_expression=ip.src == ${src_ip}
#     run keyword and continue on failure     should not be empty    ${return_src_ip}
#     ${return_dst_ip}    Get PARAM Value from Wireshark Log    check_param=ip.dst
#     ...    element_idx=${0}       condition_expression=ip.dst == ${dest_ip}
#     run keyword and continue on failure    should not be empty    ${return_dst_ip}
# 
# Check traffic by counter
#     [Arguments]    ${connection}
#     csn.connect_to   hostname=${DU_OAM_IP}  username=${DU_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}  alias=${connection}
#     csn.send command    command=echo 1 > /var/run/cpss/ports/2/clear_port_mac_counters
#     ...     connection=${connection}
#     csn.send command    command=cat /var/run/cpss/ports/2/mac_counters | awk -F ':' '{print $2}' | head -n 1
#     ...     connection=${connection}
#     ${return_result_EIF1}    csn.read output   connection=${connection}
#     ${number_EIF1}    evaluate    int(${return_result_EIF1.split('\n')[0]})
#     should be true       ${number_EIF1} > 0
#     [Teardown]  csn.disconnect   connection=${connection}
# 
# Check log by counter
#     [Arguments]    ${connection}
#     csn.connect_to   hostname=${DU_second_ip}  username=${DU_second_username}   password=${DU_second_password}  alias=${connection}
#     csn.send command    command=echo 1 > /var/run/cpss/ports/1/clear_port_mac_counters
#     ...     connection=${connection}
#     csn.send command    command=cat /var/run/cpss/ports/1/mac_counters | awk -F ':' '{print $2}' | head -n 1
#     ...     connection=${connection}
#     ${return_result}    csn.read output   connection=${connection}
#     ${number}    evaluate    int(${return_result.split('\n')[0]})
#     should be equal    ${0}     ${number}
#     csn.send command    command=echo 1 > /var/run/cpss/ports/2/clear_port_mac_counters
#     ...     connection=${connection}
#     csn.send command    command=cat /var/run/cpss/ports/2/mac_counters | awk -F ':' '{print $2}' | head -n 1
#     ...     connection=${connection}
#     ${return_result_EIF1}    csn.read output   connection=${connection}
#     ${number_EIF1}    evaluate    int(${return_result_EIF1.split('\n')[0]})
#     should be true       ${number_EIF1} > 0
#     [Teardown]  csn.disconnect   connection=${connection}
# 
# Get PARAM Value from Wireshark Log
#     [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
#     ${value}     cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
#     ...    default_value=${default_value}    condition_expression=${condition_expression}
#     log to console  Get PARAM Value from Wireshark Log successful
#     [Return]    ${value}
# 
# Recovery env
#     Change parameter    oam_ip=${DU_second_ip}
#     ...    dist_name=${dist_name_second}    parameter=administrativeState    value=unlocked
#     CI_interface.Common Case Teardown
# 
# Recovery env again
#     Change parameter    oam_ip=${DU_second_ip}
#     ...    dist_name=${dist_name_second_two}    parameter=l2SwitchingEnabled    value=true
#     CI_interface.Common Case Teardown
