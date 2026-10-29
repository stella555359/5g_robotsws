*** Settings ***
Documentation    Description:      Resources used during sending some traffic from TestPC to TL.
...              Author:           jagoda.kubacka@nokia.com
...              Modification:     14-05-2024 made by jagoda.kubacka@nokia.com

Library     taf.transport.ssh       WITH NAME    ssh
Resource    taf/rfrl/cbts/utilities/init_variables.robot

*** Variables ***

${TEST_PC_IP}=     10.42.63.239
${TEST_PC_LOGIN}=  trs
${TEST_PC_PASS}=   YT_xk39b

*** Keywords ***

Execute Traffic From TestPC
    [Documentation]    Description:      Sending traffic to vCU/vDU via Test PC. The packages are sent via Scapy
    ...                                  tool. Scapy is based on Python.
    ...                Return:           Execution time. The time that packets are sent. This is neccessary to
    ...                                  have the specific value of counter that should collect the dropped packets.
    ...                Author:           jagoda.kubacka@nokia.com
    ...                Modification:     14-05-2024 made by jagoda.kubacka@nokia.com
    [Arguments]        ${packet_type}    # Type of packets that can be sent: TCP, SCTP, ICMP, UDP
    ...                ${ip_src}         # The destination address that packets will be sent on this IP
    ...                ${pps}            # The amount of packets sent per second
    ...                ${loop}           # The amount of all packets that will be sent
    ...                ${vlan}=${NONE}           # The ID of vlan
    ...                ${sport}=${NONE}  # The source port (neccessary in SCTP)
    ...                ${dport}=${NONE}  # The destination port (neccessary in UDP, TCP)
    ...                ${type}=${NONE}   # Type of ICMP packet (0 - echo-replay; 3 - destination-unreachable;
                                         # 8 - echo-request; 11 - time-exceeded; 12 - parameter-problem)
    ...                ${hw_type}=${NONE}
    Log    The ${packet_type} packets are sent via Scapy to the ${ip_src} address    console=true
    ${nesas_vlan}    ssh.Connect To    ${TEST_PC_IP}    ${TEST_PC_LOGIN}    ${TEST_PC_PASS}
    ${kill_scapy}    ssh.execute    pkill -f scapy    connection=${nesas_vlan}
    ${python_path}=  ssh.execute  which python3  connection=${nesas_vlan}
    ${python_path_stripped}=  Strip String  ${python_path}
    ${vlan}=    Run Keyword If    "${vlan}"=="${NONE}"    Get VLAN from Test PC    hw_type=${hw_type}
    ssh.Disconnect    connection=${nesas_vlan}
    ${kill_scapy}    ssh.Connect To    ${TEST_PC_IP}    ${TEST_PC_LOGIN}    ${TEST_PC_PASS}
    ${kill_scapy_output}    ssh.execute    pkill -f scapy    connection=${kill_scapy}
    ${if_password}    Run Keyword And Return Status    Should Contain    ${kill_scapy_output}    password
    Run Keyword If    '${if_password}'=='True'    ssh.execute    ${TEST_PC_PASS}   connection=${kill_scapy}
    ssh.Disconnect    connection=${kill_scapy}
    Log    The vlan for the TL is ${vlan}    console=True
    ${command}=         Run Keyword If  '${packet_type}'=='SCTP'
    ...    Catenate  'import scapy.all as scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${ip_src}")
    ...               /scapy.SCTP(sport=${sport}, dport=${dport}), pps=${pps}, loop=${loop}, iface="${vlan}")'
    ...    ELSE IF   '${packet_type}'=='UDP'
    ...    Catenate  'import scapy.all as scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${ip_src}")
    ...               /scapy.UDP(dport=${dport}), pps=${pps}, loop=${loop}, iface="${vlan}")'
    ...    ELSE IF    '${packet_type}'=='TCP'
    ...    Catenate    scapy.sendpfast(scapy.Ether()/scapy.IP(src="${TEST_PC_IP}", dst="${ip_src}") /
    ...                scapy.TCP(dport=${dport}), pps=${pps}, count=${loop}, iface="${vlan}")
    ...    ELSE IF    '${packet_type}'=='ICMP'
    ...    Catenate   'import scapy.all as scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${ip_src}")
    ...                /scapy.ICMP(type=${type}), pps=${pps}, count=${loop}, iface="${vlan}")'
    ...    ELSE        Log    The packet_type was not provided - this is neccessary!    console=true
    ${import}    Set Variable    import scapy.all as scapy;
    Log    Command "echo ${TEST_PC_PASS} | sudo -S ${python_path_stripped} -c '${import} ${command}'"    console=True
    ssh.Connect To    ${TEST_PC_IP}    ${TEST_PC_LOGIN}    ${TEST_PC_PASS}    alias=nesas_packets
    ssh.execute        echo ${TEST_PC_PASS} | sudo -S ${python_path_stripped} -c '${import} ${command}'  connection=nesas_packets
    ${exec_time}=      Get Current Date    result_format=%H:%M:%S
    [Return]           ${exec_time}
    [Teardown]         Run Keywords
    ...                Run Keyword and Ignore Error    ssh.Disconnect    connection=${nesas_vlan}   AND
    ...                Run Keyword and Ignore Error    ssh.Disconnect    connection=${kill_scapy}

Execute Ping Test From TestPC
    [Arguments]       ${deadline}=5    ${ping}=${None}    ${hw_type}=${None}
    ${ip}=            Set Variable If    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${conn}=          ssh.Connect To    ${TEST_PC_IP}    ${TEST_PC_LOGIN}    ${TEST_PC_PASS}
    ${command}=       Set Variable    ping -w ${deadline} ${IP} | grep -o '[0-9]\\+ packets transmitted, [0-9]\\+ received'
    ${output}=        ssh.Execute    command=${command}    connection=${conn}
    Should Contain    ${output}    ${deadline} packets transmitted
    Run Keyword If    '${ping}'=='on'    Should Not Contain    ${output}    0 received
    ...    ELSE IF    '${ping}'=='off'    Should Contain    ${output}    0 received
    ...    ELSE       Log    The information if ping is on or off is not provided - this is neccessary!    console=true
    [Teardown]        ssh.Disconnect    connection=${conn}

Execute Traceroute Test From TestPC
    [Arguments]       ${deadline}=5    ${ping}=${None}    ${hw_type}=${None}
    ${ip}=            Set Variable If    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${conn}=          ssh.Connect To    ${TEST_PC_IP}    ${TEST_PC_LOGIN}    ${TEST_PC_PASS}
    ${command}=       Set Variable    traceroute -w ${deadline} ${ip}
    ${output}=        ssh.Execute    command=${command}    connection=${conn}
    ${list}=          Split String    ${output}    \n
    ${length}=        Get Length    ${list}
    ${response}=      Set Variable If    '${ping}'=='off'    * * *    ${ip}
    FOR    ${i}    IN RANGE   1    ${length}-1
      Should Contain    ${list}[${i}]    ${response}
    END
    [Teardown]        ssh.Disconnect    connection=${conn}

Get VLAN from Test PC
    [Arguments]    ${hw_type}
    ssh.Connect To    ${TEST_PC_IP}    ${TEST_PC_LOGIN}    ${TEST_PC_PASS}    alias=pc_conn
    ${LMP_IP}=         Set Variable If    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${output}=         ssh.execute  ip route get ${LMP_IP}    connection=pc_conn
    ${clean_vlan}=     Evaluate    __import__('re').sub(r'\x1b\\[[0-9;]*m', '', '''${output}''')
    ${correct_vlan}=          Get Regexp Matches    ${clean_vlan}    (?<=dev )\\S+
    [Return]           ${correct_vlan}[0]
    [Teardown]         ssh.Disconnect    connection=pc_conn

Execute Commend on Test PC during TCPDUMP
    [Arguments]      ${command}     ${pcap_file_name}    ${pcap_filter}
    SSHLibrary.Open Connection    ${TEST_PC_IP}
    SSHLibrary.Login              ${TEST_PC_LOGIN}   ${TEST_PC_PASS}
    ${write}=  SSHLibrary.Write  sudo su
    Sleep  5
    ${sudo}=  SSHLibrary.Read
    Should contain  ${sudo}  password
    SSHLibrary.Write  ${TEST_PC_PASS}
    Sleep  5          reason=Wait until login
    SSHLibrary.Write  timeout 30 tcpdump -i any -w ${pcap_file_name} &
    Sleep  15s        reason=Wait until PCAP file is started properly
    SSHLibrary.Write  ${command}
    Sleep  15s        reason=Wait until commend is executed
    ${output}=  SSHLibrary.Read
    SSHLibrary.Write  exit
    SSHLibrary.Read Until        expected=$
    SSHLibrary.Start Command     ${pcap_filter}
    Sleep  15s        reason=Wait until commend is executed
    ${output_pcap}=   Read Command Output
    [Return]    ${output}    ${output_pcap}
    [Teardown]  SSHLibrary.close all connections

Start Tcpdump For Counter
    [Arguments]    ${pc_interface}=${NONE}    ${hw_type}=${None}
    ${pc_interface}=    Run Keyword If    "${pc_interface}"=="${NONE}"    Get VLAN from Test PC    hw_type=${hw_type}
    ssh.connect to    ${TEST_PC_IP}    ${TEST_PC_LOGIN}    ${TEST_PC_PASS}    alias=packets_tcpdump_conn
    ${kill_pcaps}    Catenate    echo ${TEST_PC_PASS} | sudo pkill -9 tcpdump
    ${kill_pcap}=  ssh.send command  ${kill_pcaps}  connection=packets_tcpdump_conn
    ${start_command}=  Catenate  echo ${TEST_PC_PASS} | sudo -S tcpdump -i ${pc_interface} -w SCAPY_PACKETS.cap
    ${tcpdump_pid}=  ssh.send command  ${start_command}  connection=packets_tcpdump_conn

Kill Tcpdump For Counter
    ${tcpdump_pid_command}=  Catenate  ps aux | grep -- '-w SCAPY_PACKETS.cap' | grep -wv grep | awk '{print $2}'
    ${tcpdump_pid}=  ssh.execute  ${tcpdump_pid_command}  connection=packets_tcpdump_conn
    ${tcpdump_pid_stripped}=  Strip String  ${tcpdump_pid}
    ${kill_comand}=  Catenate  kill -9 ${tcpdump_pid_stripped}
    ssh.execute  ${kill_comand}  connection=packets_tcpdump_conn
    ssh.disconnect  connection=packets_tcpdump_conn

Get Number Of Packets After Packets Flood
    ssh.connect to    ${TEST_PC_IP}    ${TEST_PC_LOGIN}    ${TEST_PC_PASS}    alias=packets_tcpdump_read
    ${info_about_packets}=  ssh.execute  tcpdump -r SCAPY_PACKETS.cap | wc -l  connection=packets_tcpdump_read
    ${number_of_packets}=  Get Line  ${info_about_packets}  -1
    ssh.execute  echo ${TEST_PC_PASS} | sudo -S rm SCAPY_PACKETS.cap  connection=packets_tcpdump_read
    ssh.disconnect  connection=packets_tcpdump_read
    Log    ${number_of_packets}    console=true
    [Return]  ${number_of_packets}
