*** Settings ***
Documentation   Keywords for CB008259
...
...             Test Case automation author:
...             Test Case automation contact:

Resource           ../../../common_resources/admin/admin.robot
Resource           ../../../common_resources/certificates/certificates.robot
Library            ./resources.py  WITH NAME  8259_resources
Library            XML   True
Library            taf.sbts.oam.coam.admin    WITH NAME    coam_admin

*** Variables ***
${CMP_OBJECT_PATH}=         Set Variable    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
${CRLH_OBJECT_PATH}=        Set Variable    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1
${CERT_ERROR_MSG}=                      ErrorCode: 7

${TEST_PC_IPv4_ADDRESS}=                10.42.22.118
${TEST_PC_LOGIN}=                       root
${TEST_PC_PASSWORD}=                    YT_xk39b

${TEST_PC_CONNECTION_FOR_ASIM_TL-187}=   TL187_ASIM
${TEST_PC_CONNECTION_FOR_ASIB_TL-267}=   TL267_ASIB
${TEST_PC_CONNECTION_FOR_ASIL_TL-310}=   TL310_ASIL-ABIP
${TEST_PC_CONNECTION_FOR_ASIK_TL-342}=   TL342_ASIK
${TEST_PC_CONNECTION_FOR_ASOF_TL-421}=   TL421_ASOF

${TEST_PC_INTERFACE_FOR_ASIM_TL-187}=   enp1s0f1.454                                  #  TL187_ASIM
${TEST_PC_INTERFACE_FOR_ASIB_TL-267}=   enp1s0f1.454   # works for TL310 as well         TL267_ASIB
${TEST_PC_INTERFACE_FOR_ASIL_TL-310}=   enp1s0f1.458   # does not work for this TL       TL310_ASIL-ABIP
${TEST_PC_INTERFACE_FOR_ASIK_TL-342}=   enp1s0f1.488                                  #  TL342_ASIK
${TEST_PC_INTERFACE_FOR_ASOF_TL-421}=   enp1s0f1.454                                  #  TL421_ASOF

# ipRmDropPcktsRtLimArp [M51328C17] test settings
${M51328C17_BURST}=                               4000
${M51328C17_LIMIT}=                               4064
${M51328C17_INCREASE_PERCENT}=                    1
${M51328C17_PPS}=                                 ${M51328C17_LIMIT} + (${M51328C17_LIMIT} * ${M51328C17_INCREASE_PERCENT})
${M51328C17_LOOP}=                                10
${M51328C17_PACKETS_LIMIT}=                       (${M51328C17_LIMIT} * ${M51328C17_LOOP} + ${M51328C17_BURST})
${M51328C17_PACKETS}=                             ${M51328C17_LOOP} * (${M51328C17_PPS})
${M51328C17_TCPDUMP_STATISTICAL_ERROR}=           0.1
${M51328C17_TCPDUMP_STATISTICAL_ERROR_MORE}=      (1 + ${M51328C17_TCPDUMP_STATISTICAL_ERROR})
${M51328C17_TCPDUMP_STATISTICAL_ERROR_LESS}=      (1 - ${M51328C17_TCPDUMP_STATISTICAL_ERROR})
${M51328C17_SHOULD_BE_COLLECTED}=                 ${M51328C17_PACKETS} - (${M51328C17_LIMIT} * ${M51328C17_LOOP}) - ${M51328C17_BURST}
${M51328C17_TEST_STATISTICAL_ERROR}=              (${M51328C17_LOOP} * (${M51328C17_PPS})) / 10

*** Keywords ***
Change parameter in CMP object
    [Arguments]   ${param_name}  ${param_value}  ${admin_conn}
    ${CMP_OBJECT_PATH}=         Set Variable    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    Change Parameter On BTS             dist_name=${CMP_OBJECT_PATH}
    ...                                 param_name=${param_name}
    ...                                 param_value=${param_value}
    ...                                 skip_parameter_relation_errors=${TRUE}
    ...                                 connection=${admin_conn}

Change parameter in CRLH object
    [Arguments]   ${param_name}  ${param_value}  ${admin_conn}
    ${CRLH_OBJECT_PATH}=        Set Variable    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1
    Change Parameter On BTS             dist_name=${CRLH_OBJECT_PATH}
    ...                                 param_name=${param_name}
    ...                                 param_value=${param_value}
    ...                                 skip_parameter_relation_errors=${TRUE}
    ...                                 connection=${admin_conn}

Create CRLDPCONFIG Object
    [Arguments]  ${admin_conn}
    ${CRLH_OBJECT_PATH}=        Set Variable    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1
    ${params_list}=  Get List Of Params For crldpconfig Object
    coam_admin.Perform Object Recommissioning   dist_name=${CRLH_OBJECT_PATH}/CRLDPCONFIG-1
    ...                                         parameter=${params_list}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${TRUE}
    ...                                         should_activate=${TRUE}
    ...                                         connection=${admin_conn}

Delete CRLDPCONFIG Object
    [Arguments]  ${admin_conn}
    ${CRLH_OBJECT_PATH}=        Set Variable    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1
    @{empty_list}=   Create List
    Run Keyword And Ignore Error  coam_admin.perform_object_recommissioning
    ...                                         dist_name=${CRLH_OBJECT_PATH}/CRLDPCONFIG-1
    ...                                         parameter=${empty_list}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${TRUE}
    ...                                         should_activate=${True}
    ...                                         connection=${admin_conn}

Activate connection on Test PC
    [Arguments]  ${test_line_connection}
    ssh.connect to    ${TEST_PC_IPv4_ADDRESS}    ${TEST_PC_LOGIN}    ${TEST_PC_PASSWORD}    alias=conn_m51328c17_test_pc
    ssh.execute  nmcli connection up ${test_line_connection}  connection=conn_m51328c17_test_pc
    [Teardown]  ssh.disconnect  connection=conn_m51328c17_test_pc

Get MAC address for IPv4 address
    [Arguments]  ${IPv4_address}
    ssh.connect to    ${SSH_IP}    ${SSH_USERNAME}    ${SSH_PASSWORD}    alias=conn_m51328c17_mac_address
    ${mac_address}=  ssh.execute  ip a | grep -B 1 ${IPv4_address}/ | grep link/ether | awk '{print $2}'  connection=conn_m51328c17_mac_address
    ${mac_address_stripped}=  Strip String  ${mac_address}
    ssh.disconnect  connection=conn_m51328c17_mac_address
    [Return]  ${mac_address_stripped}

Send Packets For M51328C17 Counter To BTS
    [Arguments]  ${dst_mac_address}  ${pps_number}  ${pps_loop}  ${testPC_interface}
    ssh.connect to    ${TEST_PC_IPv4_ADDRESS}    ${TEST_PC_LOGIN}    ${TEST_PC_PASSWORD}    alias=conn_m51328c17_test_pc
    ${python_path}=  ssh.execute  which python3  connection=conn_m51328c17_test_pc
    ${python_path_stripped}=  Strip String  ${python_path}
    ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether(dst="${dst_mac_address}") / scapy.ARP(pdst="${MPLANE_IPV4}")),
    ...                     pps=${pps_number}, iface="${testPC_interface}", loop=${pps_loop}, parse_results=1)'
    ${scapy_command_status}=  ssh.execute  ${python_path_stripped} -c ${command}  connection=conn_m51328c17_test_pc
    [Teardown]  ssh.disconnect  connection=conn_m51328c17_test_pc
    [Return]  ${scapy_command_status}

Start Tcpdump For M51328C17 Counter
    ssh.connect to    ${SSH_IP}    ${SSH_USERNAME}    ${SSH_PASSWORD}    alias=conn_m51328c17_tcpdump
    ${m_plane_interface}=  ssh.execute  ip a | grep ${MPLANE_IPV4}/ | awk '{print $7}'  connection=conn_m51328c17_tcpdump
    ${m_plane_interface_stripped}=  Strip String  ${m_plane_interface}
    ${start_command}=  Catenate  tcpdump -i ${m_plane_interface_stripped} inbound and arp -w 8259-A.cap
    ${tcpdump_pid}=  ssh.send command  ${start_command}  connection=conn_m51328c17_tcpdump

Kill Tcpdump For M51328C17 Counter
    ${tcpdump_pid_command}=  Catenate  ps aux | grep 'inbound and arp -w 8259-A.cap' | grep -wv 'grep' | awk '{print $2}'
    ${tcpdump_pid}=  ssh.execute  ${tcpdump_pid_command}  connection=conn_m51328c17_tcpdump
    ${tcpdump_pid_stripped}=  Strip String  ${tcpdump_pid}
    ${kill_comand}=  Catenate  kill -9 ${tcpdump_pid_stripped}
    ssh.execute  ${kill_comand}  connection=conn_m51328c17_tcpdump
    ssh.disconnect  connection=conn_m51328c17_tcpdump

Get Number Of Packets After Packets Flood For M51328C17
    ssh.connect to    ${SSH_IP}    ${SSH_USERNAME}    ${SSH_PASSWORD}    alias=conn_m51328c17_tcpdump_read
    ${info_about_packets}=  ssh.execute  tcpdump -r 8259-A.cap | wc -l  connection=conn_m51328c17_tcpdump_read
    ${number_of_packets}=  Get Line  ${info_about_packets}  -1
    ssh.execute  rm 8259-A.cap  connection=conn_m51328c17_tcpdump_read
    ssh.disconnect  connection=conn_m51328c17_tcpdump_read
    [Return]  ${number_of_packets}
