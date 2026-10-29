*** Settings ***
Documentation    Description:      Resources used during sending some traffic from TestPC to TL.
...              Author:           jagoda.kubacka@nokia.com
...              Modification:     14-05-2024 made by jagoda.kubacka@nokia.com

Library    taf.transport.ssh       WITH NAME    ssh

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
    ...                ${vlan}           # The ID of vlan
    ...                ${sport}=${NONE}  # The source port (neccessary in SCTP)
    ...                ${dport}=${NONE}  # The destination port (neccessary in UDP, TCP)
    ...                ${type}=${NONE}   # Type of ICMP packet (0 - echo-replay; 3 - destination-unreachable;
                                         # 8 - echo-request; 11 - time-exceeded; 12 - parameter-problem)
    Log    The ${packet_type} packets are sent via Scapy to the ${ip_src} address    console=true
    ${conn}=          ssh.Connect To    ${IP_TEST_PC}    ${LOGIN_TEST_PC}    ${PASS_TEST_PC}
    ${scapy}=         Run Keyword If  '${packet_type}'=='SCTP'
    ...    Catenate  'import scapy.all as scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${ip_src}")
    ...               /scapy.SCTP(sport=${sport}, dport=${dport}), pps=${pps}, loop=${loop}, iface="enp1s0f0.${vlan}")'
    ...    ELSE IF   '${packet_type}'=='UDP'
    ...    Catenate  'import scapy.all as scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${ip_src}")
    ...               /scapy.UDP(dport=${dport}), pps=${pps}, loop=${loop}, iface="enp1s0f0.${vlan}")'
    ...    ELSE IF    '${packet_type}'=='TCP'
    ...    Catenate   'import scapy.all as scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${ip_src}")
    ...               /scapy.TCP(dport=${dport}), pps=${pps}, loop=${loop}, iface="enp1s0f0.${vlan}")'
    ...    ELSE IF    '${packet_type}'=='ICMP'
    ...    Catenate   'import scapy.all as scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${ip_src}")
    ...                /scapy.ICMP(type=${type}), pps=${pps}, loop=${loop}, iface="enp1s0f0.${vlan}")'
    ...    ELSE        Log    The packet_type was not provided - this is neccessary!    console=true
    ${command}=        Catenate  sudo -E /usr/bin/python -c ${scapy}
    ssh.Execute        ${command}    connection=${conn}
    ${time}            Evaluate    ${loop} / ${pps}
    Sleep              ${time}    reason=Wait for sending packets
    ${exec_time}=      Get Current Date    result_format=%H:%M:%S
    [Return]           ${exec_time}
    [Teardown]         ssh.Disconnect    connection=${conn}

Execute Ping Test From TestPC
    [Arguments]       ${deadline}=5    ${ping}=${None}    ${hw_type}=${None}
    ${ip}=            Set Variable If    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${conn}=          ssh.Connect To    ${IP_TEST_PC}    ${LOGIN_TEST_PC}    ${PASS_TEST_PC}
    ${command}=       Set Variable    ping -w ${deadline} ${IP} | grep -o '[0-9]\\+ packets transmitted, [0-9]\\+ received'
    ${output}=        Execute    command=${command}    connection=${conn}
    Should Contain    ${output}    ${deadline} packets transmitted
    Run Keyword If    '${ping}'=='on'    Should Not Contain    ${output}    0 received
    ...    ELSE IF    '${ping}'=='off'    Should Contain    ${output}    0 received
    ...    ELSE       Log    The information if ping is on or off is not provided - this is neccessary!    console=true
    [Teardown]        ssh.Disconnect    connection=${conn}

Execute Traceroute Test From TestPC
    [Arguments]       ${deadline}=5    ${ping}=${None}    ${hw_type}=${None}
    ${ip}=            Set Variable If    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${conn}=          ssh.Connect To    ${IP_TEST_PC}    ${LOGIN_TEST_PC}    ${PASS_TEST_PC}
    ${command}=       Set Variable    traceroute -w ${deadline} ${ip}
    ${output}=        Execute    command=${command}    connection=${conn}
    ${list}=          Split String    ${output}    \n
    ${length}=        Get Length    ${list}
    ${response}=      Set Variable If    '${ping}'=='off'    * * *    ${ip}
    FOR    ${i}    IN RANGE   1    ${length}-1
      Should Contain    ${list}[${i}]    ${response}
    END
    [Teardown]        ssh.Disconnect    connection=${conn}
