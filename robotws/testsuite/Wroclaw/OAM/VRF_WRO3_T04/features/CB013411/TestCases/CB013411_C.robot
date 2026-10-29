*** Settings ***
Documentation
...  author:      Klaudyna Piechocka
...  contact:     klaudyna.piechocka@nokia.com
...  description: TC for CB013411. CB013411 verifies if there are restrictions for parameters when BTS is in India.
Resource   ../Resources/CB013411_resources.robot
Resource   ../../../common_resources/commissioning/parameters.robot
Resource   ../../../common_resources/ip_traffic/ip_traffic.robot
Resource   ../../../common_resources/alarms/alarm.robot
Resource   ../../../common_resources/ssh/ssh_operations.robot
Library    SSHLibrary
Library    BuiltIn
Library    taf.sbts.oam.coam.admin    WITH NAME    coam_admin

*** Variables ***
#TL189
${bsh}=            1:1
${TEST_PC_IP}=     10.42.215.18
${TEST_PC_USER}=   trs
${TEST_PC_PASS}=   YT_xk39b
${FHNET_IP}=       172.21.0.2    #Login to FHNET (lxc-attach -n 0x1018) and execute: "ip a | grep 'scope global rlan0.ecpri'"
${SIM_RU_MAC}=     40:a6:b7:2c:6f:a5  #Login to FHNET and check mac addres of simulated RU in /var/lib/radio-dhcpd/lease_list.csv
${SIM_RU_IP}       172.22.0.10         #Login to FHNET and check ip addres of simulated RU in /var/lib/radio-dhcpd/lease_list.csv
${FHNET_MAC}=      28:74:f5:08:ad:e7    #Login to test pc and execute "ip n". The MAC address can be found next to interface of our simulated radio
${BBMOD_IP}=       172.22.0.9    #Login to test pc and execute "ip n". The IP address can be found next to interface of our simulated radio
${interface}=      enp1s0f1.8

*** Keywords ***
CB013411-A_IPSec_defect_handling_between_the_DU_and_RU
    Log    Step 1: Turn Off TLS    console=true
    Turn Off TLS
    Log    Step 2: Start collecting pcap on FHNET    console=true
    Start Tcpdump On FHNET via SSH
    Log    Step 3: Login to admin and set actEcpriRuMPlaneSecurity to RuProtectEnabled   console=true
    ${conn}=     Connect To Admin
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=actEcpriRuMPlaneSecurity
    ...                                  param_value=RuProtectEnabled
    ...                                  connection=${conn}
    Wait Until Keyword Succeeds    15min    1min
    ...                            Check If RU operationalState has expected value   excpected_value=[Ee]nabled
    Wait Until Keyword Succeeds    15min    30sec    Check If All Cells Are OnAir
    Log    Step 2: Stop collecting pcap and check if ISAKMP packets are present     console=true
    ${pcap_file}=    Stop Tcpdump on FHNET And Download Pcap Via SSH
    ISAKMP Packets Should Be Present On BTS    ${pcap_file}
    ESP Packets Should Be Present On BTS
    ${radio_ip}=      Get IP Address For All RUs
    ${ru_ip}=    Set Variable    ${radio_ip}[0]
    Create nft Rule To Break Link To RU    ${ru_ip}
    ${expected_fault}=    Create List    10
    Wait Until Keyword Succeeds    10min    30sec    Check If Expected Faults Except Allowed Are Present On BTS
    ...                                             expected_faults_list=${expected_fault}
    Delete nft Rule to Unbreak Link to RU    ${ru_ip}
    Wait Until Keyword Succeeds    13min    1min
    ...                            Check If RU operationalState has expected value   excpected_value=[Ee]nabled
    Wait Until Keyword Succeeds    15min    30sec    Check If All Cells Are OnAir
    ESP Packets Should Be Present On BTS
    [Teardown]    Run Keywords
    ...           Run Keyword And Ignore Error   Stop Tcpdump on FHNET And Download Pcap Via SSH    AND
    ...           Run Keyword And Ignore Error   Delete nft Rule to Unbreak Link to RU    ${ru_ip}   AND
    ...           Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=actEcpriRuMPlaneSecurity
    ...                                  param_value=RuProtectDisabled
    ...                                  connection=${conn}     AND
    ...           CB013411_resources.Wait Until RU Will Automatically Reboot    AND
    ...           Wait Until Keyword Succeeds    15min    30sec    Check If All Cells Are OnAir   AND
    ...           ESP Packets Should Not Be Present On BTS    AND
    ...           Run Keyword And Ignore Error   Disconnect from ADMIN    ${conn}

CB013411-SyVe_Counters_Verification
    Log    Step 1: Configure actMplaneFronthaulFirewall and miIpFilteringFhStatistics parameters    console=true
    ${conn}=    Connect to ADMIN
    Change Parameter on BTS
    ...              MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...              actMplaneFronthaulFirewall
    ...              true
    ...              connection=${conn}
    Change Parameter on BTS
    ...              MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    ...              miIpFilteringFhStatistics
    ...              5min
    ...              connection=${conn}
    Sleep    300
    Log    Step 2: Send ICMP pacckets to correct FH ip addres
    ${scapy_command1}=     Catenate     sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...           IP(dst='${FHNET_IP}')/ICMP(type=8, code=0), iface='${interface}', pps=50, loop=1000, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    Sleep    300
    Log    Step 3: Check if M51334C1 was NOT incresed    console=true
    ${newest_value}    ${previous_value}=    Check M51334C1 Counter by WebEM   TNL=1  connection=${conn}
    IF    ${newest_value} < 100 and ${previous_value} < 100
        Log    Counter is not increased
    ELSE
        Fail    Counter is  increased
    END
    Log    Step 4: Send ICMP pacckets to INCORRECT FH ip addres    console=true
    ${scapy_command2}=     Catenate     sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...           IP(dst='172.23.0.1')/ICMP(type=8, code=0), iface='${interface}', pps=50, loop=1000, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command2}
    Sleep    300
    Log    Step 5: Check if M51334C1 was incresed    console=true
        ${newest_value}    ${previous_value}=    Check M51334C1 Counter by WebEM   TNL=1  connection=${conn}
    IF    (${newest_value} > 1000 and ${previous_value} <= 1000) or (${newest_value} <= 1000 and ${previous_value} > 1000)
        Log    Counter increased
    ELSE
        Log    Counter not increased
    END
    Log    Step 6: Send correct UDP packets   console=true
    ${scapy_command3}=     Catenate     sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...           IP(dst='${FHNET_IP}')/UDP(dport=13001), iface='${interface}', pps=50, loop=1000, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command3}
    Sleep    300
    Log    Step 8: Check if M51334C1 was NOT incresed    console=true
    ${newest_value}    ${previous_value}=    Check M51334C1 Counter by WebEM   TNL=1  connection=${conn}
    IF    ${newest_value} < 100 and ${previous_value} < 100
        Log    Counter is not increased
    ELSE
        Fail    Counter is  increased
    END
    Log    Step 9: Send incorrect UDP packets   console=true

    ${scapy_command4}=     Catenate     sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...           IP(dst='${FHNET_IP}')/UDP(dport=13001), iface='${interface}', pps=50, loop=1000, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command3}
    Sleep    300
    Log    Step 10: Check if M51334C1 was incresed    console=true
    ${newest_value}    ${previous_value}=    Check M51334C1 Counter by WebEM   TNL=1  connection=${conn}
    IF    (${newest_value} > 1000 and ${previous_value} <= 1000) or (${newest_value} <= 1000 and ${previous_value} > 1000)
        Log    Counter increased
    ELSE
        Log    Counter not increased
    END

        Check if BTS status is Configured or OnAir
    [Teardown]   Run Keyword     Disconnect from ADMIN    ${conn}

CB013411-SyVe_Spoof_Prevention_IPv4
    Log    Step 1: Check the value of RATE-LIMIT Counter    console=true
    ${drpooed_packets1}=    Check RATE-LIMIT Counter    ${bsh}
    Log    Step 2: Send spoofing from text PC    console=true
    SSHLibrary.Open Connection   host=${TEST_PC_IP}
    SSHLibrary.Login             username=${TEST_PC_USER}       password=${TEST_PC_PASS}
    SSHLibrary.Write             sudo su
    Sleep    2
    SSHLibrary.Write             ${TEST_PC_PASS}
    SSHLibrary.Write             sudo hping3 -p 21 ${BBMOD_IP} --spoof 172.21.1.20 -c 2000 -i u1000
    Sleep    20
    SSHLibrary.Read Until        2000 packets transmitted, 0 packets received, 100% packet loss
    Log    Step 3: Check the value of RATE-LIMIT Counter and compere it to previous one    console=true
    ${drpooed_packets2}=    Check RATE-LIMIT Counter    ${bsh}
    ${diff}=    Evaluate    ${drpooed_packets2}-${drpooed_packets1}
    ${equation}=    Catenate    1999 < ${diff} < 2005
    Should Be True    ${equation}

CB013411-SyVe_Stateful_Packet_Filtering_IPv4
    Log    Step 1: Clear Iptables Statistics
    CB013411_resources.Clear Iptables Statistics

    Log    Step 2: Send TCP traffic which is out of state (SYN flag) by scapy and compare iptables  console=True
    CB013411_resources.Check Iptables   type="RELATED,ESTABLISHED" | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${SIM_RU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=21, flags='S', seq=100), iface='${interface}',
    ...                               pps=50, loop=500, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type="RELATED,ESTABLISHED" | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets  packets=500

    Log    Step 3: Send TCP traffic which is out of state (ACK flag) by scapy and compare iptables  console=True
    CB013411_resources.Check Iptables   type="FILTER_DISCARD_CHAIN ${SPACE}tcp" | tail -1     pre/post=pre
    ${scapy_command2}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${SIM_RU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=21, flags='A', seq=100), iface='${interface}',
    ...                               pps=50, loop=500, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command2}
    CB013411_resources.Check Iptables   type="FILTER_DISCARD_CHAIN ${SPACE}tcp" | tail -1    pre/post=post
    CB013411_resources.Compare Iptables Packets  packets=500

    Log    Step 4: Send TCP traffic which is out of state (FIN flag) by scapy and compare iptables  console=True
    CB013411_resources.Check Iptables   type="FILTER_DISCARD_CHAIN ${SPACE}tcp" | tail -1     pre/post=pre
    ${scapy_command3}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${SIM_RU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=21, flags='F', seq=100), iface='${interface}',
    ...                               pps=50, loop=700, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command3}
    CB013411_resources.Check Iptables   type="FILTER_DISCARD_CHAIN ${SPACE}tcp" | tail -1    pre/post=post
    CB013411_resources.Compare Iptables Packets  packets=700

    Log    Step 5:
    CB013411_resources.Check Iptables   type="FILTER_DISCARD_CHAIN ${SPACE}tcp" | tail -1     pre/post=pre
    ${scapy_command4}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(src='${SIM_RU_IP}',
    ...                               dst='${FHNET_IP}')/TCP(dport=21, flags='F', seq=100), iface='${interface}',
    ...                               pps=50, loop=700, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command4}
    CB013411_resources.Check Iptables   type="FILTER_DISCARD_CHAIN ${SPACE}tcp" | tail -1    pre/post=post
    CB013411_resources.Compare Iptables Packets  packets=700


CB013411-SyVe_Stateless_Packet_Filtering_IPv4
    Log    Step 1: Clear Iptables Statistics
    CB013411_resources.Clear Iptables Statistics

    Log    Step 2: Send correct ICMP traffic (ICMP Echo Request) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=8, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets

    Log    Step 3: Send correct UDP packets (dport=162) and compare iptables  console=True
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="udp dpt:162"
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               UDP(dport=162), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="udp dpt:162"
    ...                     pre/post=post
    CB013411_resources.Compare Iptables Packets

    Log    Step 4: Send correct UDP packets (dport=13000) and compare iptables  console=True
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="udp dpts:13000"
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               UDP(dport=13000), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="udp dpts:13000"
    ...                     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=100

    Log    Step 5: Send correct UDP packets (dport=500, sport=500) and compare iptables  console=True
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="udp spt:500"
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               UDP(dport=500, sport=500), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="udp spt:500"
    ...                     pre/post=post
    CB013411_resources.Compare Iptables Packets

    Log    Step 6: Send correct TCP packets (dport=21) and compare iptables  console=True
    CB013411_resources.Check Iptables   type="RELATED,ESTABLISHED" | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               TCP(dport=21, flags='S', seq=100), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type="RELATED,ESTABLISHED" | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets

    Log    Step 7: Send correct TCP packets (dport=65300) and compare iptables  console=True
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="tcp dpts:65300"
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               TCP(dport=65300, flags='S', seq=100), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
     CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="tcp dpts:65300"
    ...                     pre/post=post
    CB013411_resources.Compare Iptables Packets


    Log    Step 8: Send 100 incorrect ICMP traffic packets (Source Quench (type=4)) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=4, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 9: Send 100 incorrect ICMP traffic packets (Redirect (type=5)) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=5, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 10: Send 100 incorrect ICMP traffic packets (Timestamp (type=13)) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=13, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 11: Send 100 incorrect ICMP traffic packets (Timestamp reply (type 14)) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=14, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 12: Send 100 incorrect ICMP traffic packets (Information request (type 15)) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=15, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 13: Send 100 incorrect ICMP traffic packets (Information reply (type 16)) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=16, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 14: Send 100 incorrect ICMP traffic packets (Address Mask Request (type 17)) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=17, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 15: Send 100 incorrect ICMP traffic packets (Address Mask Reply (type 18)) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               ICMP(type=18, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 16: Send 100 incorrect ICMP traffic packets (ICMP Echo Request, sIP=out_of_RU_subnet) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...                               IP(src='172.22.49.49', dst='${FHNET_IP}')/
    ...                               ICMP(type=18, code=0), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=icmp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 16: Send 100 incorrect UDP packets with incorrect source port (dport=500, sport=501) and compare iptables  console=True
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="udp spt:500"
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...                               IP(dst='${FHNET_IP}')/
    ...                               UDP(dport=500, sport=501), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="udp spt:500"
    ...                     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 17: Send 100 incorrect UDP packets to closed port (dport=10000) and compare iptables  console=True
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type=udp
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...                               IP(dst='${FHNET_IP}')/
    ...                               UDP(dport=10000), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type=udp
    ...                     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log    Step 18: Send 100 incorrect TCP packets to closed port (dport=53) and compare iptables  console=True
    CB013411_resources.Check Iptables   type=tcp | tail -1     pre/post=pre
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type=tcp
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...                               IP(dst='${FHNET_IP}')/
    ...                               (dport=53, flags='S', seq=100), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables   type=tcp | tail -1     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type=tcp
    ...                     pre/post=post

    Log    Step 19: Send 100 incorrect CP packets (dport=21, sIP=out_of_RU_subnet) and compare iptables  console=True
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="tcp dpt:21"
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/
    ...                               IP(src='172.22.49.49', dst='${FHNET_IP}')/
    ...                               TCP(dport=21, flags='S', seq=100), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="tcp dpt:21"
    ...                     pre/post=post
    CB013411_resources.Compare Iptables Packets    packets=0

    Log  Step 20: Check all RUs are in expected state  console=True
    Check if BTS status is Configured or OnAir

CB013411-SyVe_Stateless_Packet_Filtering_IPv4_ORAN
    Log    Step 1: Clear Iptables Statistics
    CB013411_resources.Clear Iptables Statistics

    Log    Step 2: Send correct TCP packets (dport=22) and compare iptables  console=True
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="tcp dpt:22"
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               TCP(dport=22, flags='S', seq=100), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="tcp dpt:22"
    ...                     pre/post=post
    CB013411_resources.Compare Iptables Packets

    Log    Step 3: Send correct TCP packets (dport=4334) and compare iptables  console=True
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="tcp dpt:4334"
    ...                     pre/post=pre
    ${scapy_command1}=    Catenate    sendpfast(Ether(src='${SIM_RU_MAC}', dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                               TCP(dport=4334, flags='S', seq=100), iface='${interface}',
    ...                               pps=10, loop=100, parse_results=1)
    Send packets from test PC using scapy sendpfast    ${scapy_command1}
    CB013411_resources.Check Iptables With Given Chain
    ...                     chain=ECPRI_STATIC_CHAIN
    ...                     type="tcp dpt:4334"
    ...                     pre/post=post
    CB013411_resources.Compare Iptables Packets
    Check if BTS status is Configured or OnAir
