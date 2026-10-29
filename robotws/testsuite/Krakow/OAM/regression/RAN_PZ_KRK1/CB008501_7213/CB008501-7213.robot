*** Settings ***
Documentation
...   Test suite for regression testing of features CB008501 and CB007213 CRT
...   author: Marek Szlapa
...   contact: marek.szlapa@nokia.com

Library         taf/rfrl/bts/devices/du/commissioning.py
Library         ./resources/snapshot_analyzer.py
Library         ./resources/keywords.py
Library         keywords.BbuOperations
Library         keywords.RuOperations
Library         keywords.WsOperations
Resource        taf/rfrl/bts/robot/gnb.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        ./resources/keywords_SR_A.robot
Resource        ./resources/keywords_SR_B.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables       ./resources/deltas.py

Suite Setup     Run Keywords    Common Suite Setup With OnAir Test Line Preparation
...                             swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...             AND   Reconfigure DHCP config   AND   Install NetAct Certificate On BTS   AND   Clone moler devices   5
Suite Teardown  Common Suite Teardown

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms


*** Variables ***
${Pre_snapshot_name}     Pre_snapshot.zip
${Post_snapshot_name}    Post_snapshot.zip


*** Test Cases ***
[1]CB008501-SR-A_TC02_Ingress_rate_limiting_for_ICMP_Destination_Unreachable_packets
    [Documentation]    The purpose of this test case is to verify if limit rate 100 packets (+/-10% variance) burst size
    ...                16 messages (+-10%) per second of the  ingress ICMP Destination Unreachable rule is present
    ...                on the RU firewall 20000 packets are sent with pps of 1000 in which
    ...                2016 to 4032 packets are accepted, 15968 to 17984 packets are rejected
    [Setup]            Run Keywords    Common Preconditions With Watching Alarms    AND    Clear IP tables

    ${protocol}                  Set Variable    "ICMP(type=3, code=1)"
    ${packets_number}            Set Variable    20000
    ${pps}                       Set Variable    1000
    ${chain}                     Set Variable    ICMP_INPUT_RATE_LIMIT
    ${accepted_packets_range}    Create List     2016     4032
    ${dropped_packets_range}     Create List     15968    17984
    ${accepted_search_info}      Create Dictionary    TARGET=ACCEPT
    ${dropped_search_info}       Create Dictionary    TARGET=DROP

    ${extracted_path}       Snapshot download and extract    ${Pre_snapshot_name}
    ${pre_accepted_packets_count}      Get packets    ${extracted_path}     ${chain}     ${accepted_search_info}
    ${pre_dropped_packets_count}       Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Run scapy command       ${protocol}     ${packets_number}    ${pps}
    ${extracted_path}       Snapshot download and extract    ${Post_snapshot_name}
    ${post_accepted_packets_count}     Get packets    ${extracted_path}     ${chain}     ${accepted_search_info}
    ${post_dropped_packets_count}      Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Verify packets count    ${pre_accepted_packets_count}     ${pre_dropped_packets_count}
    ...                     ${post_accepted_packets_count}    ${post_dropped_packets_count}
    ...                     ${accepted_packets_range}         ${dropped_packets_range}

[1]CB008501-SR-A_TC07_Limit_to_the_number_of_simultaneous_SSH_connections_on_the_M-Plane_IP
    [Documentation]    The purpose of this testcase is to verify a firewall rule to prevent brute force attack
    ...                via SSH interface by limiting number of TCP connections on the SSH port per minute
    ...                60 packets are sent with pps of 1, 9 to 11 packets are accepted and 49 to 51 are dropped
    [Setup]            Run Keywords    Common Preconditions With Watching Alarms    AND    Clear IP tables

    ${protocol}                  Set Variable    "TCP(dport=22, flags='"'"S"'"')"
    ${packets_number}            Set Variable    60
    ${pps}                       Set Variable    1
    ${chain}                     Set Variable    ECPRI_INPUT_0
    ${accepted_packets_range}    Create List     9       11
    ${dropped_packets_range}     Create List     49      51
    ${sent_search_info}          Create Dictionary     DESTINATION=tcp
    ${dropped_search_info}       Create Dictionary     TARGET=DROP    REST=recent

    ${extracted_path}    Snapshot download and extract    ${Pre_snapshot_name}
    ${pre_sent_packets_count}         Get packets    ${extracted_path}     ${chain}     ${sent_search_info}
    ${pre_dropped_packets_count}      Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    ${pre_accepted_packets_count}     Evaluate       ${pre_sent_packets_count}-${pre_dropped_packets_count}
    Run scapy command    ${protocol}   ${packets_number}     ${pps}
    ${extracted_path}    Snapshot download and extract    ${Post_snapshot_name}
    ${post_sent_packets_count}        Get packets    ${extracted_path}     ${chain}     ${sent_search_info}
    ${post_dropped_packets_count}     Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    ${post_accepted_packets_count}    Evaluate       ${post_sent_packets_count}-${post_dropped_packets_count}
    Verify packets count    ${pre_accepted_packets_count}     ${pre_dropped_packets_count}
    ...                     ${post_accepted_packets_count}    ${post_dropped_packets_count}
    ...                     ${accepted_packets_range}         ${dropped_packets_range}

[1]CB008501-SR-A_TC13_Stateful_ingress_packet_filtering_for_TCP_packets
    [Documentation]  The purpose of this test case  ft h verify statefull packet filtering. Stateful packet filtering is
    ...              applicable to transport protocols running over IP (TCP, UDP and ICMP). For RU initiated connection
    ...              the state of the connection is maintained. Every ingress packet received by gNB-RU from the peer is
    ...              checked against the communication state stored on gNB-RU for the applicable protocol rules.
    ...              Packets that pass the check are accepted and packets that fail the check are rejected and logged
    ...              100 packets are sent with pps of 10, 90 to 110 packets are dropped and 0 to 2 are accepted.
    [Setup]          Run Keywords    Common Preconditions With Watching Alarms    AND    Clear IP tables

    ${protocol}                  Set Variable    "TCP(dport=22, flags='"'"APRSF"'"')"
    ${packets_number}            Set Variable    100
    ${pps}                       Set Variable    10
    ${chain}                     Set Variable    ECPRI_INPUT_0
    ${accepted_packets_range}    Create List     0     2
    ${dropped_packets_range}     Create List     90    110
    ${accepted_search_info}      Create Dictionary    DESTINATION=tcp
    ${dropped_search_info}       Create Dictionary    TARGET=DROP      PROT=all

    ${extracted_path}    Snapshot download and extract    ${Pre_snapshot_name}
    ${pre_accepted_packets_count}    Get packets      ${extracted_path}     ${chain}     ${accepted_search_info}
    ${pre_dropped_packets_count}     Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Run scapy command    ${protocol}   ${packets_number}    ${pps}
    ${extracted_path}    Snapshot download and extract    ${Post_snapshot_name}
    ${post_accepted_packets_count}   Get packets    ${extracted_path}     ${chain}     ${accepted_search_info}
    ${post_dropped_packets_count}    Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Verify packets count    ${pre_accepted_packets_count}     ${pre_dropped_packets_count}
    ...                     ${post_accepted_packets_count}    ${post_dropped_packets_count}
    ...                     ${accepted_packets_range}         ${dropped_packets_range}

[1]CB008501-SR-A_TC14_Stateful_ingress_packet_filtering_for_UDP_packets
    [Documentation]  The purpose of this test case is to verify statefull packet filtering. Stateful packet filtering is
    ...              applicable to transport protocols running over IP (TCP, UDP and ICMP). For RU initiated connection
    ...              the state of the connection is maintained. Every ingress packet received by gNB-RU from the peer is
    ...              checked against the communication state stored on gNB-RU for the applicable protocol rules.
    ...              Packets that pass the check are accepted and packets that fail the check are rejected and logged
    ...              100 packets are sent with pps of 10, 90 to 110 packets are dropped and 0 to 2 are accepted.
    [Setup]          Run Keywords    Common Preconditions With Watching Alarms    AND    Clear IP tables

    ${protocol}                  Set Variable    "UDP(sport=1235, dport=9000)"
    ${packets_number}            Set Variable    100
    ${pps}                       Set Variable    10
    ${chain}                     Set Variable    ECPRI_INPUT_0
    ${accepted_packets_range}    Create List     0     2
    ${dropped_packets_range}     Create List     90    110
    ${accepted_search_info}      Create Dictionary    TARGET=ACCEPT    PROT=udp
    ${dropped_search_info}       Create Dictionary    TARGET=DROP      PROT=all

    ${extracted_path}    Snapshot download and extract    ${Pre_snapshot_name}
    ${pre_accepted_packets_count}    Get packets      ${extracted_path}     ${chain}     ${accepted_search_info}
    ${pre_dropped_packets_count}     Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Run scapy command    ${protocol}   ${packets_number}    ${pps}
    ${extracted_path}    Snapshot download and extract    ${Post_snapshot_name}
    ${post_accepted_packets_count}   Get packets    ${extracted_path}     ${chain}     ${accepted_search_info}
    ${post_dropped_packets_count}    Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Verify packets count    ${pre_accepted_packets_count}     ${pre_dropped_packets_count}
    ...                     ${post_accepted_packets_count}    ${post_dropped_packets_count}
    ...                     ${accepted_packets_range}         ${dropped_packets_range}

[1]CB008501-SR-A_TC16_Stateless_packet_filtering_for_ICMP_packets
    [Documentation]  The purpose of this test case is to verify stateless packet filtering. The RU shall provide
    ...              stateless ingress packet filtering for IP traffic according to defined protocol stack based on
    ...              Quintuple IP header inspection (protocol type, IP addresses, Port numbers). If a match is found
    ...              the packet is accepted otherwise it is rejected and the counter of rejected packets is incremented.
    ...              2*100 packets are sent with pps of 100, 90 to 110 packets are rejected and 90 to 110 are accepted.
    [Setup]          Run Keywords    Common Preconditions With Watching Alarms    AND    Clear IP tables

    ${protocol_echo_request}     Set Variable    "ICMP(type=8, code=0)"
    ${protocol_source_quench}    Set Variable    "ICMP(type=4, code=0)"
    ${packets_number}            Set Variable    100
    ${pps}                       Set Variable    100
    ${chain_accepted}            Set Variable    ICMP_INPUT_RATE_LIMIT
    ${chain_dropped}             Set Variable    ICMP_BLACKLIST
    ${accepted_packets_range}    Create List     90      110
    ${dropped_packets_range}     Create List     90      110
    ${accepted_search_info}      Create Dictionary    TARGET=ACCEPT
    ${dropped_search_info}       Create Dictionary    TARGET=DROP    REST=icmptype 4

    ${extracted_path}       Snapshot download and extract    ${Pre_snapshot_name}
    ${pre_accepted_packets_count}      Get packets    ${extracted_path}     ${chain_accepted}    ${accepted_search_info}
    ${pre_dropped_packets_count}       Get packets    ${extracted_path}     ${chain_dropped}     ${dropped_search_info}
    Run scapy command       ${protocol_echo_request}     ${packets_number}    ${pps}
    Run scapy command       ${protocol_source_quench}    ${packets_number}    ${pps}
    ${extracted_path}       Snapshot download and extract    ${Post_snapshot_name}
    ${post_accepted_packets_count}     Get packets    ${extracted_path}     ${chain_accepted}    ${accepted_search_info}
    ${post_dropped_packets_count}      Get packets    ${extracted_path}     ${chain_dropped}     ${dropped_search_info}
    Verify packets count    ${pre_accepted_packets_count}     ${pre_dropped_packets_count}
    ...                     ${post_accepted_packets_count}    ${post_dropped_packets_count}
    ...                     ${accepted_packets_range}         ${dropped_packets_range}

[1]CB008501-SR-A_TC17_Stateless_packet_filtering_for_TCP_packets
    [Documentation]  The purpose of this test case is to verify stateless packet filtering. The RU shall provide
    ...              stateless ingress packet filtering for IP traffic according to defined protocol stack based on
    ...              Quintuple IP header inspection (protocol type, IP addresses, Port numbers). If a match is found
    ...              the packet is accepted otherwise it is rejected and the counter of rejected packets is incremented.
    ...              2*100 packets are sent with pps of 100, 90 to 110 packets are rejected and 90 to 110 are accepted.
    [Setup]          Run Keywords    Common Preconditions With Watching Alarms    AND    Clear IP tables

    ${protocol_dest_port_22}     Set Variable    "TCP(dport=22, flags='"'"S"'"')"
    ${protocol_dest_port_80}     Set Variable    "TCP(dport=80, flags='"'"S"'"')"
    ${packets_number}            Set Variable    100
    ${pps}                       Set Variable    100
    ${chain}                     Set Variable    ECPRI_INPUT_0
    ${accepted_packets_range}    Create List     90      115
    ${dropped_packets_range}     Create List     90      115
    ${accepted_search_info}      Create Dictionary     DESTINATION=tcp
    ${dropped_search_info}       Create Dictionary     TARGET=DROP    PROT=all

    ${extracted_path}       Snapshot download and extract    ${Pre_snapshot_name}
    ${pre_accepted_packets_count}      Get packets    ${extracted_path}     ${chain}     ${accepted_search_info}
    ${pre_dropped_packets_count}       Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Run scapy command       ${protocol_dest_port_80}     ${packets_number}    ${pps}
    Run scapy command       ${protocol_dest_port_22}     ${packets_number}    ${pps}
    ${extracted_path}       Snapshot download and extract    ${Post_snapshot_name}
    ${post_accepted_packets_count}     Get packets    ${extracted_path}     ${chain}     ${accepted_search_info}
    ${post_dropped_packets_count}      Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Verify packets count    ${pre_accepted_packets_count}     ${pre_dropped_packets_count}
    ...                     ${post_accepted_packets_count}    ${post_dropped_packets_count}
    ...                     ${accepted_packets_range}         ${dropped_packets_range}

[1]CB008501-SR-A_TC18_Stateless_packet_filtering_for_UDP_packets
    [Documentation]  The purpose of this test case is to verify stateless packet filtering. The RU shall provide
    ...              stateless ingress packet filtering for IP traffic according to defined protocol stack based on
    ...              Quintuple IP header inspection (protocol type, IP addresses, Port numbers). If a match is found
    ...              the packet is accepted otherwise it is rejected and the counter of rejected packets is incremented.
    ...              3*100 packets are sent with pps of 100, 90 to 110 packets are rejected and 180 to 220 are accepted.
    [Setup]          Run Keywords    Common Preconditions With Watching Alarms    AND    Clear IP tables

    ${protocol_dest_port_13100}      Set Variable    "UDP(dport=13100, sport=13010)"
    ${protocol_dest_port_500}        Set Variable    "UDP(dport=500)"
    ${protocol_dest_port_80}         Set Variable    "UDP(dport=80)"
    ${packets_number}                Set Variable    100
    ${pps}                           Set Variable    100
    ${chain}                         Set Variable    ECPRI_INPUT_0
    ${accepted_packets_range}        Create List     180       220
    ${dropped_packets_range}         Create List     90        110
    ${accepted_search_info_13100}    Create Dictionary     TARGET=ACCEPT    REST=dpt:13100
    ${accepted_search_info_500}      Create Dictionary     TARGET=ACCEPT    REST=dpt:500
    ${dropped_search_info}           Create Dictionary     TARGET=DROP      PROT=all

    ${extracted_path}    Snapshot download and extract    ${Pre_snapshot_name}
    ${pre_accepted_packets_count_1}     Get packets    ${extracted_path}     ${chain}     ${accepted_search_info_13100}
    ${pre_accepted_packets_count_2}     Get packets    ${extracted_path}     ${chain}     ${accepted_search_info_500}
    ${pre_accepted_packets_count}       Evaluate       ${pre_accepted_packets_count_1}+${pre_accepted_packets_count_2}
    ${pre_dropped_packets_count}        Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Run scapy command    ${protocol_dest_port_13100}   ${packets_number}    ${pps}
    Run scapy command    ${protocol_dest_port_500}     ${packets_number}    ${pps}
    Run scapy command    ${protocol_dest_port_80}      ${packets_number}    ${pps}
    ${extracted_path}    Snapshot download and extract    ${Post_snapshot_name}
    ${post_accepted_packets_count_1}    Get packets    ${extracted_path}     ${chain}     ${accepted_search_info_13100}
    ${post_accepted_packets_count_2}    Get packets    ${extracted_path}     ${chain}     ${accepted_search_info_500}
    ${post_accepted_packets_count}      Evaluate       ${post_accepted_packets_count_1}+${post_accepted_packets_count_2}
    ${post_dropped_packets_count}       Get packets    ${extracted_path}     ${chain}     ${dropped_search_info}
    Verify packets count    ${pre_accepted_packets_count}     ${pre_dropped_packets_count}
    ...                     ${post_accepted_packets_count}    ${post_dropped_packets_count}
    ...                     ${accepted_packets_range}         ${dropped_packets_range}

[1]CB008501-SR-B_TC01_Disable_RSA_KEx_algorithms
    [Documentation]   The purpose of this testcase is to verify that BTS assigns cipher suites to the TLS end point
    ...               according to the operator defined settings i.e. when the RSA Key Exchange algorithms are disabled.
    [Setup]           Run Keywords
    ...               Common Preconditions With Watching Alarms
    ...               AND
    ...               Perform Delta Commissioning On gNB    delta=${delta_SR_B_TC01_TC03}

    ${cipher}         Set Variable     AES256-GCM-SHA384

    Create OpenSSL test connections    ${moler_devices}    ${cipher}
    Start OpenSSL connections
    Change BTS parameter value    tls12RsaKExDisabled    true
    Wait for OpenSSL connections interruption
    Scan available ciphers using NMAP    forbidden_cipher=TLS_RSA
    Create OpenSSL connections with disabled RSA KEx algorithms    ${moler_devices}   ${cipher}
    Start OpenSSL connections
    ${open_ssl_result}    Stop OpenSSL connections
    Verify Openssl Outputs with disabled RSA KEx algorithms    ${open_ssl_result}    ${cipher}

    [Teardown]    Run Keywords
    ...           Common Postconditions With Watching Alarms
    ...           AND
    ...           Change BTS parameter value    tls12RsaKExDisabled    false

[1]CB008501-SR-B_TC02_Disable_TLSv1_1_downgrade
    [Documentation]   The purpose of this testcase is to verify that BTS assigns cipher suites to the TLS end point
    ...               according to the operator defined settings i.e. when the TLSv1.1 is disabled
    [Setup]           Run Keywords
    ...               Common Preconditions With Watching Alarms
    ...               AND
    ...               Perform Delta Commissioning On gNB    delta=${delta_SR_B_TC02}

    ${cipher}         Set Variable     ECDHE-RSA-AES256-GCM-SHA384

    Create OpenSSL test connections    ${moler_devices}
    Start OpenSSL connections
    Change BTS parameter value    tls12Enabled    false
    Wait for OpenSSL connections interruption
    Scan available TLS versions using NMAP    forbidden_tls=TLSv1.1
    Create OpenSSL connections with disabled TLSv1_1 Downgrade    ${moler_devices}
    Start OpenSSL connections
    ${open_ssl_result}    Stop OpenSSL connections
    Verify Openssl Outputs with disabled TLSv1_1 Downgrade    ${open_ssl_result}    ${cipher}

    [Teardown]    Run Keywords
    ...           Common Postconditions With Watching Alarms
    ...           AND
    ...           Change BTS parameter value    tls12Enabled    true

[1]CB008501-SR-B_TC03_Disabling_CBC_cipher_support
    [Documentation]   The purpose of this testcase is to verify that BTS assigns cipher suites to the TLS end point
    ...               according to the operator defined settings i.e. when the CBC ciphers are disabled.
    [Setup]           Run Keywords
    ...               Common Preconditions With Watching Alarms
    ...               AND
    ...               Perform Delta Commissioning On gNB    delta=${delta_SR_B_TC01_TC03}

    ${cipher1}        Set Variable     DHE-RSA-AES256-SHA256
    ${cipher2}        Set Variable     ECDHE-RSA-AES256-GCM-SHA384

    Create OpenSSL test connections    ${moler_devices}    ${cipher1}
    Start OpenSSL connections
    Change BTS parameter value    tls12CbcCipherDisabled    true
    Wait for OpenSSL connections interruption
    Scan available ciphers using NMAP    forbidden_cipher=CBC
    Create OpenSSL connections with disabled CBC Cipher    ${moler_devices}    ${cipher1}
    Start OpenSSL connections
    ${open_ssl_result}    Stop OpenSSL connections
    Verify Openssl Outputs with disabled CBC Cipher    ${open_ssl_result}    ${cipher2}

    [Teardown]    Run Keywords
    ...           Common Postconditions With Watching Alarms
    ...           AND
    ...           Change BTS parameter value    tls12CbcCipherDisabled    false

[1]CB008501-SR-B_TC04_Enable_RSA_KEx_algorithms
    [Documentation]   The purpose of this testcase is to verify that BTS assigns cipher suites to the TLS end point
    ...               according to the operator defined settings i.e. when the RSA Key Exchange algorithms are enabled.
    [Setup]           Run Keywords
    ...               Common Preconditions With Watching Alarms
    ...               AND
    ...               Perform Delta Commissioning On gNB    delta=${delta_SR_B_TC04}

    ${cipher1}        Set Variable     ECDHE-RSA-AES256-GCM-SHA384
    ${cipher2}        Set Variable     AES256-GCM-SHA384

    Create OpenSSL test connections    ${moler_devices}    ${cipher1}
    Start OpenSSL connections
    Change BTS parameter value    tls12RsaKExDisabled    false
    Wait for OpenSSL connections interruption
    Scan available ciphers using NMAP    required_cipher=TLS_RSA
    Create OpenSSL connections with enabled RSA KEx algorithms    ${moler_devices}    ${cipher1}    ${cipher2}
    Start OpenSSL connections
    ${open_ssl_result}    Stop OpenSSL connections
    Verify Openssl Outputs with enabled RSA KEx algorithms    ${open_ssl_result}    ${cipher1}    ${cipher2}

    [Teardown]    Run Keywords
    ...           Common Postconditions With Watching Alarms
    ...           AND
    ...           Run Keyword If Test Failed    Change BTS parameter value    tls12RsaKExDisabled    false



[1]CB008501-SR-B_TC05_Enable_TLSv1_1_downgrade
    [Documentation]   The purpose of this testcase is to verify that BTS assigns cipher suites to the TLS end point
    ...               according to the operator defined settings i.e. when the TLSv1.1 is enabled.
    [Setup]           Run Keywords
    ...               Common Preconditions With Watching Alarms
    ...               AND
    ...               Perform Delta Commissioning On gNB    delta=${delta_SR_B_TC05}

    ${cipher}         Set Variable    ECDHE-RSA-AES256-GCM-SHA384

    Create OpenSSL test connections    ${moler_devices}
    Start OpenSSL connections
    Change BTS parameter value    tls12Enabled    true
    Wait for OpenSSL connections interruption
    Scan available TLS versions using NMAP    forbidden_tls=TLSv1.1    required_tls=TLSv1.2
    Create OpenSSL connections with enabled TLSv1_1 Downgrade    ${moler_devices}
    Start OpenSSL connections
    ${open_ssl_result}    Stop OpenSSL connections
    Verify Openssl Outputs with enabled TLSv1_1 Downgrade    ${open_ssl_result}    ${cipher}

    [Teardown]    Run Keywords
    ...           Common Postconditions With Watching Alarms
    ...           AND
    ...           Run Keyword If Test Failed    Change BTS parameter value    tls12Enabled    true

[1]CB008501-SR-B_TC06_Enabling_CBC_cipher_support
    [Documentation]   The purpose of this testcase is to verify the BTS assigns cipher suites to the TLS end point
    ...               according to the operator defined settings i.e. when the CBC ciphers are enabled.
    [Setup]           Run Keywords
    ...               Common Preconditions With Watching Alarms
    ...               AND
    ...               Perform Delta Commissioning On gNB    delta=${delta_SR_B_TC06}

    ${cipher1}        Set Variable     ECDHE-RSA-AES256-GCM-SHA384
    ${cipher2}        Set Variable     DHE-RSA-AES256-SHA256

    Create OpenSSL test connections    ${moler_devices}    ${cipher1}
    Start OpenSSL connections
    Change BTS parameter value    tls12CbcCipherDisabled    false
    Wait for OpenSSL connections interruption
    Scan available ciphers using NMAP    required_cipher=TLS_DHE_RSA_WITH_AES_256_CBC_SHA256
    Create OpenSSL connections with enabled CBC Cipher    ${moler_devices}    ${cipher1}    ${cipher2}
    Start OpenSSL connections
    ${open_ssl_result}    Stop OpenSSL connections
    Verify Openssl Outputs with enabled CBC Cipher    ${open_ssl_result}    ${cipher1}    ${cipher2}

    [Teardown]    Run Keywords
    ...           Common Postconditions With Watching Alarms
    ...           AND
    ...           Run Keyword If Test Failed    Change BTS parameter value    tls12CbcCipherDisabled    false


*** Keywords ***
Clone moler devices
    [Arguments]    ${clones_number}
    ${moler_devices}      Clone WS moler devices    ${clones_number}
    Set Suite Variable    ${moler_devices}
