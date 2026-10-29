*** Settings ***
Documentation
...  author:      Klaudyna Piechocka
...  contact:     klaudyna.piechocka@nokia.com
...  description: TC for CB013411. CB013411 verifies if there are restrictions for parameters when BTS is in India.
Resource   ../Resources/CB013411_resources_CR.robot
Resource   ../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../cloud_common_resources/logs/logs.robot
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource   ../../../../cloud_common_resources/alarms/alarms.robot
Resource   ../../../../cloud_common_resources/resets/resets.robot
Resource   ../../../cloud_common_resources/tls/tls.robot
Resource   ../../../cloud_common_resources/counters/counters.robot
Library    SSHLibrary
Library    BuiltIn

*** Variables ***
#TL8685
${TEST_PC_IP}=     10.42.215.41
${TEST_PC_USER}=   ute
${TEST_PC_PASS}=   YT_xk39b
${FHNET_IP}=       192.168.254.33    #Login to FHNET (lxc-attach -n 0x1018) and execute: "ip a | grep 'scope global rlan0.ecpri'"
${SIM_RU_MAC}=     b8:59:9f:08:19:1e  #Login to FHNET and check mac addres of simulated RU in /var/lib/radio-dhcpd/lease_list.csv
${SIM_RU_IP}       192.168.254.34         #Login to FHNET and check ip addres of simulated RU in /var/lib/radio-dhcpd/lease_list.csv
${RU_IP}=          192.168.254.36
${ORU_IP}=         192.168.254.48
${RMOD_ID}         RMOD_R-2
${FHNET_MAC}=      c6:8b:37:59:91:80    #Login to test pc and execute "ip n". The MAC address can be found next to interface of our simulated radio
${interface}=      enp1s0f0np0.295
*** Keywords ***
CB013411-A_IPSec_defect_handling_between_the_DU_and_RU_vDU
    Log    Step 1: Turn Off TLS    console=true
    Turn On/Off TLS    state=off     hw_type=vDU
    Change Parameter on BTS              dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=actEcpriRuMPlaneSecurity
    ...                                  param_value=RuProtectDisabled
    ...                                  hw_type=vDU
    Log    Step 2: Login to admin and set actEcpriRuMPlaneSecurity to RuProtectEnabled   console=true
    ${conn}=     Connect To Admin    hw_type=vDU
    Change Parameter on BTS              dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=actEcpriRuMPlaneSecurity
    ...                                  param_value=RuProtectEnabled
    ...                                  hw_type=vDU
    Wait Until Keyword Succeeds    15min    1min
    ...    Check If RU operationalState has expected value   excpected_value=[Ee]nabled
    Wait Until Keyword Succeeds    15min    30sec    Check if Unit Status is OnAir    hw_type=vDU

    Log    Step 3: Create nft rules to break conncection to ru   console=true
    Create nft Rule To Break Link To RU    ${RU_IP}
    Wait Until Keyword Succeeds    10min    30sec    Check If FID 10 Is Present On vDU    ${RMOD_ID}
    Log    Step 4: Delete nft rules to fix conncection to ru   console=true
    Delete nft Rule to Unbreak Link to RU
    Wait Until Keyword Succeeds    13min    1min
    ...                            Check If RU operationalState has expected value   excpected_value=[Ee]nabled
    Wait Until Keyword Succeeds    15min    30sec    Check if Unit Status is OnAir    hw_type=vDU
    [Teardown]    Run Keywords
    ...           Run Keyword And Ignore Error   Delete nft Rule to Unbreak Link to RU    AND
    ...           Change Parameter on BTS              dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=actEcpriRuMPlaneSecurity
    ...                                  param_value=RuProtectDisabled
    ...                                  hw_type=vDU      AND
    ...           Wait Until Keyword Succeeds    15min    30sec    Check if Unit Status is OnAir    hw_type=vDU   AND
    ...           Disconnect from ADMIN    ${conn}    hw_type=vDU

CB013411-Counters_verification_WebEM_vDU
    Log    Step 1: Configure actMplaneFronthaulFirewall and miIpFilteringFhStatistics parameters    console=true
    ${num_of_packets}=    Set Variable    1000
    ${packet_per_second}=   Set Variable   50
    ${num_low}=    Evaluate    ${num_of_packets}-5
    ${num_high}=    Evaluate    ${num_of_packets}+100
    ${ratelimit}=    Evaluate    ${num_of_packets}/2-0.01*${num_of_packets}
    ${conn}=    Connect to ADMIN     hw_type=vDU
    Change Parameter on BTS              dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=actMplaneFronthaulFirewall
    ...                                  param_value=true
    ...                                  hw_type=vDU
    Change Parameter on BTS              dist_name=MRBTS-${MRBTS}/TNLSVC-1/PMTNLINT-1
    ...                                  param_name=ipFilteringInterval
    ...                                  param_value=5min
    ...                                  hw_type=vDU
    Change Parameter on BTS              dist_name=MRBTS-${MRBTS}/TNLSVC-1/TNL-4/IPNO-1
    ...                                  param_name=icmpResponseEnabled
    ...                                  param_value=false
    ...                                  hw_type=vDU
    ${FHNET_MAC}=    Get FH Mac address    ${interface}
    Log    Step 2: Send ICMP (type 0) packets to correct FH ip addres
    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                counter_id=M51328C0
    ...                address_or_objects=address
    ...                ip_address=${FHNET_IP}
    ...                hw_type=vDU
    ${scapy_command1}=     Catenate     sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...           IP(dst='${FHNET_IP}')/ICMP(type=0, code=0), iface='${interface}', pps=${packet_per_second},
    ...           count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${M51328C0}=    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                counter_id=M51328C0
    ...                address_or_objects=address
    ...                ip_address=${FHNET_IP}
    ...                hw_type=vDU
    ${M51328C0_val}=    Get Dictionary Values    ${M51328C0}
    IF     '${M51328C0_val[0]}'=='0'
        ${M51328C0}=    Wait For Next Counter Interval and Get Counter Timestamp with Value
        ...                counter_id=M51328C0
        ...                address_or_objects=address
        ...                ip_address=${FHNET_IP}
        ...                hw_type=vDU
        ${M51328C0_val}=    Get Dictionary Values    ${M51328C0}
    END
    IF     '${M51328C0_val[0]}'=='0'
        ${M51328C0}=    Wait For Next Counter Interval and Get Counter Timestamp with Value
        ...                counter_id=M51328C0
        ...                address_or_objects=address
        ...                ip_address=${FHNET_IP}
        ...                hw_type=vDU
        ${M51328C0_val}=    Get Dictionary Values    ${M51328C0}
    END
    IF    ${ratelimit} < ${M51328C0_val[0]} < ${num_of_packets}
        Log    Counter is not increased
    ELSE
        Fail    Counter is not increased
    END
    Log    Step 3: Send ICMP (type 8) packets to correct FH ip addres
    ${scapy_command2}=     Catenate     sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...           IP(dst='${FHNET_IP}')/ICMP(type=8, code=0), iface='${interface}',
    ...           pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command2}
    ${M51328C1}=    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                counter_id=M51328C1
    ...                address_or_objects=address
    ...                ip_address=${FHNET_IP}
    ...                hw_type=vDU
    ${M51328C1_val}=    Get Dictionary Values    ${M51328C1}
    IF     '${M51328C1_val[0]}'=='0'
        ${M51328C1}=    Wait For Next Counter Interval and Get Counter Timestamp with Value
        ...                counter_id=M51328C1
        ...                address_or_objects=address
        ...                ip_address=${FHNET_IP}
        ...                hw_type=vDU
        ${M51328C1_val}=    Get Dictionary Values    ${M51328C1}
    END
    IF     '${M51328C1_val[0]}'=='0'
        ${M51328C1}=    Wait For Next Counter Interval and Get Counter Timestamp with Value
        ...                counter_id=M51328C1
        ...                address_or_objects=address
        ...                ip_address=${FHNET_IP}
        ...                hw_type=vDU
        ${M51328C1_val}=    Get Dictionary Values    ${M51328C1}
    END
    IF    ${num_low} < ${M51328C1_val[0]} < ${num_high}
        Log    Counter is increased
    ELSE
        Fail    Counter is not increased
    END
    Wait Until Keyword Succeeds    5min    30sec    Check if Unit Status is OnAir    hw_type=vDU
    [Teardown]   Run Keyword And Ignore Error    Disconnect from ADMIN    ${conn}    hw_type=vDU

CB013411-SyVe_Spoof_Prevention_vDU
    Log    Step 1: Check the value of RATE-LIMIT Counter    console=true
    ${filter}=    Create List    tcp    21
    ${num_of_packets}=    Set Variable    2000
    ${num_low}=    Evaluate    ${num_of_packets}-5
    ${num_high}=    Evaluate    ${num_of_packets}+5
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    Log    Step 2: Send spoofing from text PC    console=true
    SSHLibrary.Open Connection   host=${TEST_PC_IP}
    SSHLibrary.Login             username=${TEST_PC_USER}       password=${TEST_PC_PASS}
    SSHLibrary.Write             sudo su
    Sleep    2
    SSHLibrary.Write             ${TEST_PC_PASS}
    SSHLibrary.Write             sudo hping3 -p 21 ${FHNET_IP} --spoof ${ORU_IP} -c ${num_of_packets} -i u1000
    Sleep    20
    SSHLibrary.Read Until        2000 packets transmitted, 0 packets received, 100% packet loss
    SSHLibrary.Write             sudo hping3 -p 21 ${FHNET_IP} --spoof 172.21.1.20 -c ${num_of_packets} -i u1000
    Sleep    20
    SSHLibrary.Read Until        ${num_of_packets} packets transmitted, 0 packets received, 100% packet loss
    Log    Step 3: Check the value of RATE-LIMIT Counter and compere it to previous one    console=true
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2} - ${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff} < ${num_high}
    Should Be True    ${equation}

CB013411-SyVe_Stateful_Packet_Filtering_IPv4_vDU
    Log    Step 1: Get MAC address
    ${num_of_packets}=    Set Variable    1000
    ${packet_per_second}=   Set Variable   50
    ${num_low}=    Evaluate    ${num_of_packets}-1
    ${FHNET_MAC}=    Get FH Mac address    ${interface}
    Log    Step 2: Send TCP traffic to port 21 which is out of state (SYN flag) by scapy and compare nftables  console=True
    ${filter}=    Create List    tcp    21
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${RU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=21, flags='S', seq=100), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff}
    Should Be True    ${equation}
    Log    Step 3: Send TCP traffict o port 21 which is out of state (ACK flag) by scapy and compare nftables  console=True
    ${filter}=    Create List    tcp    21
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command2}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${RU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=21, flags='A', seq=100), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command2}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff}
    Should Be True    ${equation}
    Log    Step 4: Send TCP traffic to port 21 which is out of state (FIN flag) by scapy and compare nftables  console=True
    ${filter}=    Create List    tcp    21
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command2}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${RU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=21, flags='F', seq=100), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command2}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff}
    Should Be True    ${equation}
    Log    Step 5: Send TCP traffic to port 22 which is out of state (SYN flag) by scapy and compare nftables  console=True
    ${filter}=    Create List    tcp    22    ${ORU_IP}
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${ORU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=22, flags='S', seq=100), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff}
    Should Be True    ${equation}
    Log    Step 6: Send TCP traffict o port 22 which is out of state (ACK flag) by scapy and compare nftables  console=True
    ${filter}=    Create List    tcp    22    ${ORU_IP}
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command2}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${ORU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=22, flags='A', seq=100), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command2}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff}
    Should Be True    ${equation}
    Log    Step 7: Send TCP traffic to port 22 which is out of state (FIN flag) by scapy and compare nftables  console=True
    ${filter}=    Create List    tcp    22    ${ORU_IP}
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command2}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${ORU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=22, flags='F', seq=100), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command2}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff}
    Should Be True    ${equation}
    Log    Step 8: Send TCP traffic to port 4334 which is out of state (SYN flag) by scapy and compare nftables  console=True
    ${filter}=    Create List    tcp    4334    ${ORU_IP}
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${ORU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=4334, flags='S', seq=100), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff}
    Should Be True    ${equation}
    Log    Step 9: Send TCP traffict o port 4334 which is out of state (ACK flag) by scapy and compare nftables  console=True
    ${filter}=    Create List    tcp    4334    ${ORU_IP}
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command2}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${ORU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=4334, flags='A', seq=100), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command2}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff}
    Should Be True    ${equation}
    Log    Step 10: Send TCP traffic to port 22 which is out of state (FIN flag) by scapy and compare nftables  console=True
    ${filter}=    Create List    tcp    4334    ${ORU_IP}
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command2}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${ORU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=4334, flags='F', seq=100), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command2}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}    Catenate    ${num_low} < ${diff}
    Should Be True    ${equation}

CB013411-SyVe_Stateless_Packet_Filtering_vDU
    Log    Step 1: Get MAC address
    ${num_of_packets}=    Set Variable    1000
    ${packet_per_second}=   Set Variable   10
    ${num_low}=    Evaluate    ${num_of_packets}-1
    ${num_high}=    Evaluate    ${num_of_packets}+5
    ${FHNET_MAC}=    Get FH Mac address    ${interface}
    Log    Step 2: Send correct ICMP traffic (type 8) and compare nftables  console=True
    ${filter}=    Create List    icmp
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=8, code=0), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    IF    ${num_low} < ${diff} < ${num_high}
            Log    Execution passed
    ELSE
        fail
    END
    Log    Step 3: Send correct ICMP traffic (type 0) and compare nftables  console=True
    ${filter}=    Create List    icmp
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=0, code=0), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    IF    ${num_low} < ${diff} < ${num_high}
            Log    Execution passed
    ELSE
        fail
    END
    Log    Step 4: Send correct ICMP traffic (type 11) and compare nftables  console=True
    ${filter}=    Create List    icmp
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=11, code=0), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    IF    ${num_low} < ${diff} < ${num_high}
            Log    Execution passed
    ELSE
        fail
    END
    Log    Step 5: Send correct ICMP traffic (type 3) and compare nftables  console=True
    ${filter}=    Create List    icmp
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=3, code=0), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    IF    ${num_low} < ${diff} < ${num_high}
            Log    Execution passed
    ELSE
        fail
    END
    Log    Step 6: Send correct ICMP traffic (type 12) and compare nftables  console=True
    ${filter}=    Create List    icmp
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=12, code=0), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    IF    ${num_low} < ${diff} < ${num_high}
            Log    Execution passed
    ELSE
        fail
    END
    Log    Step 7: Send correct UDP packets (dport=13001) and compare nftables  console=True
    ${filter}=    Create List    udp    13001
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               UDP(dport=13001), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    IF    ${num_low} < ${diff}
            Log    Execution passed
    ELSE
        fail
    END
    Log    Step 8: Send correct UDP packets (dport=13037) and compare nftables  console=True
    ${filter}=    Create List    udp   13037
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               UDP(dport=13037), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    IF    ${num_low} < ${diff}
            Log    Execution passed
    ELSE
        fail
    END
        Log    Step 9: Send correct UDP packets (dport=5001) and compare nftables  console=True
    ${filter}=    Create List    udp   5001
    ${drpooed_packets1}=    Check Counter Value In INPUT Chain  ${filter}
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               UDP(dport=5001), iface='${interface}',
    ...                               pps=${packet_per_second}, count=${num_of_packets}, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    ${drpooed_packets2}=    Check Counter Value In INPUT Chain  ${filter}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    IF    ${num_low} < ${diff}
            Log    Execution passed
    ELSE
        fail
    END
    Log  Step 11: Check all RUs are in expected state  console=True
    Wait Until Keyword Succeeds    5min    30sec    Check if Unit Status is OnAir    hw_type=vDU
