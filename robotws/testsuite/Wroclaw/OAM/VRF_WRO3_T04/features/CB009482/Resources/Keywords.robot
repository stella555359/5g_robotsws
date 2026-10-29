*** Settings ***
Documentation   Keywords for CB009482

...             Test Case automation author: Szymon Romanowski
...             Test Case automation contact: szymon.romanowski@nokia.com

Resource           ../../../common_resources/admin/admin.robot
Resource           ../../../common_resources/certificates/certificates.robot
Library            XML   True
Library            taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Variables          ../../CB008259/Resources/resources.py

*** Variables ***

${TEST_PC_IPv4_ADDRESS}=                10.42.22.118
${TEST_PC_LOGIN}=                       root
${TEST_PC_PASSWORD}=                    YT_xk39b

${TEST_PC_CONNECTION_FOR_ASIM_TL-187}=   TL187_ASIM
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

# ipRmDropPcktsRtLimEap [M51328C19] test settings
${M51328C19_BURST}=                               9
${M51328C19_LIMIT}=                               25
${M51328C19_INCREASE_PERCENT}=                    1
${M51328C19_PPS}=                                 ${M51328C19_LIMIT} + (${M51328C19_LIMIT} * ${M51328C19_INCREASE_PERCENT})
${M51328C19_LOOP}=                                10
${M51328C19_PACKETS_LIMIT}=                       (${M51328C19_LIMIT} * ${M51328C19_LOOP} + ${M51328C19_BURST})
${M51328C19_PACKETS}=                             ${M51328C19_LOOP} * (${M51328C19_PPS})
${M51328C19_TCPDUMP_STATISTICAL_ERROR}=           0.1
${M51328C19_TCPDUMP_STATISTICAL_ERROR_MORE}=      (1 + ${M51328C19_TCPDUMP_STATISTICAL_ERROR})
${M51328C19_TCPDUMP_STATISTICAL_ERROR_LESS}=      (1 - ${M51328C19_TCPDUMP_STATISTICAL_ERROR})
${M51328C19_SHOULD_BE_COLLECTED}=                 ${M51328C19_PACKETS} - (${M51328C19_LIMIT} * ${M51328C19_LOOP}) - ${M51328C19_BURST}
${M51328C19_TEST_STATISTICAL_ERROR}=              (${M51328C19_LOOP} * (${M51328C19_PPS})) / 10

*** Keywords ***
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

Send Packets For M51328C19 Counter To BTS
    [Arguments]  ${dst_mac_address}  ${pps_number}  ${pps_loop}  ${testPC_interface}
    ssh.connect to    ${TEST_PC_IPv4_ADDRESS}    ${TEST_PC_LOGIN}    ${TEST_PC_PASSWORD}    alias=conn_m51328c19_test_pc
    ${python_path}=  ssh.execute  which python3  connection=conn_m51328c19_test_pc
    ${python_path_stripped}=  Strip String  ${python_path}
    ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether(dst="${dst_mac_address}", type=0x888e)
    ...    / scapy.EAP(code=1, id=1, type=1)), pps=${pps_number}, iface="${testPC_interface}", loop=${pps_loop}, parse_results=1)'
    ${scapy_command_status}=  ssh.execute  ${python_path_stripped} -c ${command}  connection=conn_m51328c19_test_pc
    [Teardown]  ssh.disconnect  connection=conn_m51328c19_test_pc
    [Return]  ${scapy_command_status}

Start Tcpdump For M51328C19 Counter
    ssh.connect to    ${SSH_IP}    ${SSH_USERNAME}    ${SSH_PASSWORD}    alias=conn_m51328c19_tcpdump
    ${m_plane_interface}=  ssh.execute  ip a | grep ${MPLANE_IPV4}/ | awk '{print $7}'  connection=conn_m51328c19_tcpdump
    ${start_command}=  Catenate  tcpdump -i any ether proto 0x888e -w 9482-B.cap
    ${tcpdump_pid}=  ssh.send command  ${start_command}  connection=conn_m51328c19_tcpdump

Kill Tcpdump For M51328C19 Counter
    ${tcpdump_pid_command}=  Catenate  ps aux | grep 'ether proto 0x888e -w 9482-B.cap' | grep -wv 'grep' | awk '{print $2}'
    ${tcpdump_pid}=  ssh.execute  ${tcpdump_pid_command}  connection=conn_m51328c19_tcpdump
    ${tcpdump_pid_stripped}=  Strip String  ${tcpdump_pid}
    Sleep    5s
    ${kill_comand}=  Catenate  kill -2 ${tcpdump_pid_stripped}
    ssh.execute  ${kill_comand}  connection=conn_m51328c19_tcpdump
    ssh.disconnect  connection=conn_m51328c19_tcpdump

Get Number Of Packets After Packets Flood For M51328C19
    ssh.connect to    ${SSH_IP}    ${SSH_USERNAME}    ${SSH_PASSWORD}    alias=conn_m51328c19_tcpdump_read
    ${info_about_packets}=  ssh.execute  tcpdump -r 9482-B.cap | wc -l  connection=conn_m51328c19_tcpdump_read
    ${number_of_packets}=  Get Line  ${info_about_packets}  -1
    ssh.execute  rm 9482-B.cap  connection=conn_m51328c19_tcpdump_read
    ssh.disconnect  connection=conn_m51328c19_tcpdump_read
    [Return]  ${number_of_packets}

Settings Certificates for Syslog and RTPM
    [Arguments]    ${ca_ECDSA}    ${ca_RSA}
    Set CMP Server Settings                 key_pool_type=RSA
    Set CMP Server Settings                 key_pool_type=ECDSA
    Configure CMP                   ca_subject_name=${ca_ECDSA}
    ...                             server_type=ECDSA
    Configure CMP                   ca_subject_name=${ca_RSA}
    ...                             server_type=RSA
    Initialize Certificates         key_pool_type=ECDSA
    Initialize Certificates         key_pool_type=RSA

Start Syslog and RTPM Transmission
    [Arguments]    ${syslog}    ${rtpm}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                        param_name=actRemoteSyslogTransmission    param_value=${syslog}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...                        param_name=act5gRTPM    param_value=${rtpm}

Get Supplementary Alarm Information
    [Arguments]    ${response_list}
    ${4776}    Get From Dictionary    ${response_list}    4776
    Should Contain    ${4776}    certificate verify failed
    Should Contain    ${4776}    self-signed certificate
    ${4752}    Get From Dictionary    ${response_list}    4752
    Should Contain    ${4752}    self-signed certificate
    ${4203}    Get From Dictionary    ${response_list}    4203
#    Should Contain    ${4203}    TLS error
    Should Contain    ${4203}    Connection failure

Get Alarms with suplinfo
    ${active}    admin.Get Active Alarms From BTS
    Log    ${active}    console=true
    ${conn}    Connect to admin
    ${x}    coam_admin.get_alarms    connection=${conn}    detailed_output=True
    ${response_list}    Create Dictionary
    ${request}    Get From Dictionary    ${x}    requestMessage
    FOR    ${alarm}    IN    @{request}
       ${faultId}    Get From Dictionary    ${alarm}    faultId
       ${alarmInformation}    Get From Dictionary    ${alarm}    alarmInformation
       ${alarmAdditionalInfo}    Get From Dictionary    ${alarmInformation}    alarmAdditionalInfo
       ${status}    Run Keyword And Return Status
       ...          Dictionary Should Contain Key   ${alarmAdditionalInfo}    supplAlarmInfo
       ${supplAlarmInfo}    Run Keyword If    '${status}'=='True'
       ...                  Get From Dictionary    ${alarmAdditionalInfo}    supplAlarmInfo
       ...    ELSE    Set Variable    No supplementary information available
       ${faultId}    Convert to String    ${faultId}
       ${supplAlarmInfo}    Convert to String    ${supplAlarmInfo}
       Set To Dictionary    ${response_list}    ${faultId}=${supplAlarmInfo}
    END
    [Return]    ${response_list}

Add remoteSyslogConfig and rTPmCollEntity and nrRTPMMeasurementsList Structures To SCF
    [Arguments]    ${list_elements}    ${nrRTPMMeasurementsList_elements}    ${rTPmCollEntity_elements}
    ${base_scf_path}=    Download SCF
    ${first_scf_path}=     add_populated_list_to_scf    ${base_scf_path}
    ...                    MNL-1/MNLENT-1/TRBLCADM-1    remoteSyslogConfig    ${list_elements}
    ${second_scf_path}=    add_simple_list_to_scf       ${first_scf_path}   MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPMRNL-1
    ...                    nrRTPMMeasurementsList    ${nrRTPMMeasurementsList_elements}
    ${final_scf_path}=     add_populated_list_to_scf    ${second_scf_path}  MNL-1/MNLENT-1/PMCADM-1
    ...                    rTPmCollEntity    ${rTPmCollEntity_elements}
    Log  Uploading scf...  console=true
    Commission SCF    scf_file=${final_scf_path}    skip_parameter_relation_errors=False    timeout=900
    Log  Scf uploaded  console=true
