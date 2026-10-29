*** Settings ***
Documentation
...    Author:            Julia Wijas
...    Contact:           julia.wijas@nokia.com
...    Test Plan (QC):    /VRF_WRO3_T04/24R3/CB009857/
...    Description:

Resource    ../Resources/NESAS-A_Cloud_Keywords.robot
Resource    ../../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource    ../../../../../cloud_common_resources/connections/connections.robot
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../../cloud_common_resources/certificates/certificates.robot
Resource    ../../../../../cloud_common_resources/resets/resets.robot
Resource    ../../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource    ../../../../cloud_common_resources/test_pc/test_pc.robot
Resource    ../../../../cloud_common_resources/counters/counters.robot
Resource    ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource    ../../../../cloud_common_resources/tls/tls.robot
Library    BuiltIn
Library    String
Library    SSHLibrary       encoding=None
Library    DateTime

*** Variables ***
${VLAN_MPLANE_VCU}=     vlan764
${VLAN_CPLANE_VCU}=     vlan763
${VLAN_MPLANE_VDU}=     vlan761
${VLAN_CPLANE_VDU}=     vlan759

*** Test Cases ***
NESAS
    NESAS-CR_Security_Event_Logging_In_ATL_RANNIC

*** Keywords ***
NESAS-CR_Packet_Filtering_IPv4_vCU
    Wait For Next Counter Interval and Get Counter Timestamp with Value    counter_id=M51328C18    ip_address=${LMP_VCU_IP}      hw_type=vCU
    ${nft_tables}   Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=nft list chain ip filter ICMP_ENABLE_DISABLE
    ${nft_before}   Get Packets From Firewall    ${nft_tables}
    Log to console  ${nft_before}
    Execute Traffic From TestPC       packet_type=ICMP   ip_src=${LMP_VCU_IP}  pps=1000   loop=10000   vlan=${VLAN_MPLANE_VCU}  type=8   hw_type=vCU
    ${nft_tables}   Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=nft list chain ip filter ICMP_ENABLE_DISABLE
    ${nft_after}    Get Regexp Matches    ${nft_tables}    (?<=packets )\\d+
    Log to console  ${nft_after}
    Check difference between two counters   ${nft_before}    ${nft_after}    10000
    Wait For Next Counter Interval and Get Counter Timestamp with Value     counter_id=M51328C14    ip_address=${LMP_VCU_IP}      hw_type=vCU
    ${nft_tables}   Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=nft list chain ip filter ICMP_ENABLE_DISABLE
    ${nft_before}   Get Packets From Firewall    ${nft_tables}
    Log to console  ${nft_before}
    Execute Traffic From TestPC       packet_type=ICMP   ip_src=${F1C_VCU}  pps=1000   loop=10000   vlan=${VLAN_CPLANE_VCU}  type=8   hw_type=vCU
    ${nft_tables}   Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=nft list chain ip filter ICMP_ENABLE_DISABLE
    ${nft_after}    Get Regexp Matches    ${nft_tables}    (?<=packets )\\d+
    Log to console  ${nft_after}
    Check difference between two counters   ${nft_before}    ${nft_after}    10000

NESAS-CR_Packet_Filtering_IPv4_vDU
    Wait For Next Counter Interval and Get Counter Timestamp with Value    counter_id=M51328C18    ip_address=${LMP_VDU_IP}      hw_type=vDU
    ${nft_tables}   Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=nft list chain ip filter ICMP_ENABLE_DISABLE
    ${nft_before}   Get Packets From Firewall    ${nft_tables}
    Log to console  ${nft_before}
    Execute Traffic From TestPC       packet_type=ICMP   ip_src=${LMP_VDU_IP}  pps=1000   loop=10000   vlan=${VLAN_MPLANE_VDU}  type=8   hw_type=vDU
    ${nft_tables}   Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=nft list chain ip filter ICMP_ENABLE_DISABLE
    ${nft_after}    Get Regexp Matches    ${nft_tables}    (?<=packets )\\d+
    Log to console  ${nft_after}
    Check difference between two counters   ${nft_before}    ${nft_after}    10000
    Wait For Next Counter Interval and Get Counter Timestamp with Value     counter_id=M51328C14    ip_address=${LMP_VDU_IP}      hw_type=vDU
    ${nft_tables}   Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=nft list chain ip filter ICMP_ENABLE_DISABLE
    ${nft_before}   Get Packets From Firewall    ${nft_tables}
    Log to console  ${nft_before}
    Execute Traffic From TestPC       packet_type=ICMP   ip_src=${F1C_VDU}  pps=1000   loop=10000   vlan=${VLAN_CPLANE_VDU}  type=8   hw_type=vDU
    ${nft_tables}   Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=nft list chain ip filter ICMP_ENABLE_DISABLE
    ${nft_after}    Get Regexp Matches    ${nft_tables}    (?<=packets )\\d+
    Log to console  ${nft_after}
    Check difference between two counters   ${nft_before}    ${nft_after}    10000

NESAS-CR_IPv4_Packet_With_And_Without_IP_Options_vDU
    ${command}=      Catenate     echo ${TEST_PC_PASS} | sudo -E /usr/bin/python -c 'import scapy.all as scapy;
    ...                           x,y = scapy.sr(scapy.IP(dst="${LMP_VDU_IP}" ,options = scapy.IPOption(option = "timestamp"))
    ...                           /scapy.TCP(dport=443, flags="S") /"with IP options", timeout=2); print(x); print(y)'
    ${pcap_filter}   Catenate     tshark -r tcp1.pcap -Y "ip.addr == ${LMP_VDU_IP}" | wc -l
    ${output}    ${output_pacap}=   Execute Commend on Test PC during TCPDUMP   ${LMP_VDU_IP}    ${command}     tcp1.pcap   ${pcap_filter}
    Should Contain   ${output}   <Results: TCP:0 UDP:0 ICMP:0 Other:0>
    Should Contain   ${output}   <Unanswered: TCP:1 UDP:0 ICMP:0 Other:0
    Should Contain   ${output}   1

    ${command}=      Catenate    echo YT_xk39b | sudo -E /usr/bin/python -c 'import scapy.all as scapy;
    ...                          x,y = scapy.sr(scapy.IP(dst="${LMP_VDU_IP}")
    ...                          /scapy.TCP(dport=443, flags="S"), timeout=2); print(x); print(y)'
    ${pcap_filter}   Catenate    tshark -r tcp2.pcap -Y "ip.addr == ${LMP_VDU_IP}" | wc -l
    ${output}    ${output_pacap}=   Execute Commend on Test PC during TCPDUMP   ${LMP_VDU_IP}    ${command}     tcp2.pcap   ${pcap_filter}
    Should Contain   ${output}   <Results: TCP:1 UDP:0 ICMP:0 Other:0>
    Should Contain   ${output}   <Unanswered: TCP:0 UDP:0 ICMP:0 Other:0>
    Should Contain   ${output}   2

NESAS-CR_IPv4_Packet_With_And_Without_IP_Options_vCU
    ${command}=      Catenate     echo ${TEST_PC_PASS} | sudo -E /usr/bin/python -c 'import scapy.all as scapy;
    ...                           x,y = scapy.sr(scapy.IP(dst="${LMP_VCU_IP}" ,options = scapy.IPOption(option = "timestamp"))
    ...                           /scapy.TCP(dport=443, flags="S") /"with IP options", timeout=2); print(x); print(y)'
    ${pcap_filter}   Catenate     tshark -r tcp1.pcap -Y "ip.addr == ${LMP_VDU_IP}" | wc -l
    ${output}    ${output_pacap}=   Execute Commend on Test PC during TCPDUMP   ${LMP_VDU_IP}    ${command}     tcp1.pcap   ${pcap_filter}
    Should Contain   ${output}   <Results: TCP:0 UDP:0 ICMP:0 Other:0>
    Should Contain   ${output}   <Unanswered: TCP:1 UDP:0 ICMP:0 Other:0
    Should Contain   ${output}   1
    ${command}=      Catenate    echo YT_xk39b | sudo -E /usr/bin/python -c 'import scapy.all as scapy;
    ...                          x,y = scapy.sr(scapy.IP(dst="10.45.186.143")
    ...                          /scapy.TCP(dport=443, flags="S"), timeout=2); print(x); print(y)'
    ${pcap_filter}   Catenate    tshark -r tcp2.pcap -Y "ip.addr == ${LMP_VDU_IP}" | wc -l
    ${output}    ${output_pacap}=   Execute Commend on Test PC during TCPDUMP   ${LMP_VDU_IP}    ${command}     tcp2.pcap   ${pcap_filter}
    Should Contain   ${output}   <Results: TCP:1 UDP:0 ICMP:0 Other:0>
    Should Contain   ${output}   <Unanswered: TCP:0 UDP:0 ICMP:0 Other:0>
    Should Contain   ${output}   2

NESAS-CR_SYN_Flood_Prevention_DOS_VDU
    Change Parameter on BTS     dist_name=MRBTS-${MRBTS}/TNLSVC-1/PMTNLINT-1
    ...                         param_name=ipFilteringInterval
    ...                         param_value=15min
    ...                         hw_type=vDU
    Wait For Next Counter Interval and Get Counter Timestamp with Value    counter_id=M51328C18    ip_address=${LMP_VDU_IP}      hw_type=vDU
    ${nft_tables}   Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=nft list chain ip filter RATELIMIT_CHAIN
    ${nft_before}   Get Packets From Firewall    ${nft_tables}
    Log to console  ${nft_before}
    SSHLibrary.Open Connection    ${TEST_PC_IP}
    SSHLibrary.Login              ${TEST_PC_LOGIN}   ${TEST_PC_PASS}
    ${write}=  SSHLibrary.Write  sudo su
    Sleep  5
    ${sudo}=  SSHLibrary.Read
    Should contain  ${sudo}  password
    SSHLibrary.Write  ${TEST_PC_PASS}
    Sleep  5          reason=Wait until login
    SSHLibrary.Write  timeout 20 tcpdump -i ${VLAN_MPLANE_VDU} -w pcap3.pcap &
    Sleep  15s        reason=Wait until PCAP file is started properly
    Execute Traffic From TestPC       packet_type=TCP   ip_src=${LMP_VDU_IP}  pps=100000   loop=60000000
    ...                               vlan=${VLAN_MPLANE_VDU}  dport=443    hw_type=vDU
    ${nft_tables}   Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=nft list chain ip filter RATELIMIT_CHAIN
    ${nft_after}    Get Regexp Matches    ${nft_tables}    (?<=packets )\\d+
    Log to console  ${nft_after}
    Check difference between two counters   ${nft_before}    ${nft_after}    60000000
    SSHLibrary.Write  exit
    SSHLibrary.Read Until        expected=$
    SSHLibrary.Start Command  tshark -r pcap3.pcap -Y "tcp.analysis.out_of_order && ip.addr==${LMP_VDU_IP}" | wc -l
    Sleep  15s        reason=Wait until commend is executed
    ${output_pcap}=  Read Command Output
    Should Not Be Equal          ${output_pcap}     0
    [Teardown]        Run Keywords            SSHLibrary.close all connections
    ...               AND                     Change Parameter on BTS     dist_name=MRBTS-${MRBTS}/TNLSVC-1/PMTNLINT-1
    ...                                                                   param_name=ipFilteringInterval
    ...                                                                   param_value=5min
    ...                                                                   hw_type=vDU

NESAS-CR_SYN_Flood_Prevention_DOS_VCU
    Change Parameter on BTS     dist_name=MRBTS-${MRBTS_CU}/TNLSVC-1/PMTNLINT-1
    ...                         param_name=ipFilteringInterval
    ...                         param_value=15min
    ...                         hw_type=vCU
    Wait For Next Counter Interval and Get Counter Timestamp with Value    counter_id=M51328C18    ip_address=${LMP_VCU_IP}      hw_type=vCU
    ${nft_tables}   Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=nft list chain ip filter RATELIMIT_CHAIN
    ${nft_before}   Get Packets From Firewall    ${nft_tables}
    Log to console  ${nft_before}
    SSHLibrary.Open Connection    ${TEST_PC_IP}
    SSHLibrary.Login              ${TEST_PC_LOGIN}   ${TEST_PC_PASS}
    ${write}=  SSHLibrary.Write  sudo su
    Sleep  5
    ${sudo}=  SSHLibrary.Read
    Should contain  ${sudo}  password
    SSHLibrary.Write  ${TEST_PC_PASS}
    Sleep  5          reason=Wait until login
    SSHLibrary.Write  timeout 20 tcpdump -i ${VLAN_MPLANE_VCU} -w pcap3.pcap &
    Sleep  15s        reason=Wait until PCAP file is started properly
    Execute Traffic From TestPC       packet_type=TCP   ip_src=${LMP_VCU_IP}  pps=100000   loop=60000000
    ...                               vlan=${VLAN_MPLANE_VCU}  dport=443    hw_type=vCU
    ${nft_tables}   Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=nft list chain ip filter RATELIMIT_CHAIN
    ${nft_after}    Get Regexp Matches    ${nft_tables}    (?<=packets )\\d+
    Log to console  ${nft_after}
    Check difference between two counters   ${nft_before}    ${nft_after}    60000000
    SSHLibrary.Write  exit
    SSHLibrary.Read Until        expected=$
    SSHLibrary.Start Command  tshark -r pcap3.pcap -Y "tcp.analysis.out_of_order && ip.addr==${LMP_VCU_IP}" | wc -l
    Sleep  15s        reason=Wait until commend is executed
    ${output_pcap}=  Read Command Output
    Should Not Be Equal          ${output_pcap}     0
    [Teardown]        Run Keywords            SSHLibrary.close all connections
    ...               AND                     Change Parameter on BTS     dist_name=MRBTS-${MRBTS_CU}/TNLSVC-1/PMTNLINT-1
    ...                                                                   param_name=ipFilteringInterval
    ...                                                                   param_value=5min
    ...                                                                   hw_type=vCU

NESAS-CR_IP_Source_Address_Spoofing_Mitigation_VDU
    Wait For Next Counter Interval and Get Counter Timestamp with Value    counter_id=M51328C18    ip_address=${LMP_VDU_IP}      hw_type=vDU
    ${nft_tables}   Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=nft list chain ip filter MPLANE_OVERALL_RATELIMIT_CHAIN
    ${nft_before}   Get Packets From Firewall    ${nft_tables}
    Log to console  ${nft_before}
    ${timeout}       Evaluate     10000/1000
    ${command}=      Catenate     echo ${TEST_PC_PASS} | sudo -E timeout ${timeout} /usr/bin/python -c 'import scapy.all as scapy;
    ...                           scapy.sendpfast(scapy.Ether()/scapy.IP(src="0.39.114.125", dst="${LMP_VDU_IP}")
    ...                           /scapy.TCP(dport=443), pps=1000, loop=10000, iface="${VLAN_MPLANE_VDU}")'
    ${pcap_filter}=  Catenate     tshark -r tcp5.pcap -Y "ip.addr == ${LMP_VDU_IP}" | wc -l
    ${output}    ${output_pcap}=   Execute Commend on Test PC during TCPDUMP   ${LMP_VDU_IP}    ${command}     tcp5.pcap   ${pcap_filter}
    Should Not Be Equal          ${output_pcap}     0
    ${nft_tables}   Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=nft list chain ip filter MPLANE_OVERALL_RATELIMIT_CHAIN
    ${nft_after}    Get Regexp Matches    ${nft_tables}    (?<=packets )\\d+
    Log to console  ${nft_after}
    Check difference between two counters   ${nft_before}    ${nft_after}    10000

NESAS-CR_IP_Source_Address_Spoofing_Mitigation_VCU
    Wait For Next Counter Interval and Get Counter Timestamp with Value    counter_id=M51328C18    ip_address=${LMP_VCU_IP}      hw_type=vCU
    ${nft_tables}   Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=nft list chain ip filter MPLANE_OVERALL_RATELIMIT_CHAIN
    ${nft_before}   Get Packets From Firewall    ${nft_tables}
    Log to console  ${nft_before}
    ${timeout}       Evaluate     10000/1000
    ${command}=      Catenate     echo ${TEST_PC_PASS} | sudo -E timeout ${timeout} /usr/bin/python -c 'import scapy.all as scapy;
    ...                           scapy.sendpfast(scapy.Ether()/scapy.IP(src="0.39.114.125", dst="${LMP_VCU_IP}")
    ...                           /scapy.TCP(dport=443), pps=1000, loop=10000, iface="${VLAN_MPLANE_VCU}")'
    ${pcap_filter}=  Catenate     tshark -r tcp6.pcap -Y "ip.addr == ${LMP_VCU_IP}" | wc -l
    ${output}    ${output_pcap}=   Execute Commend on Test PC during TCPDUMP   ${LMP_VCU_IP}    ${command}     tcp6.pcap   ${pcap_filter}
    Should Not Be Equal          ${output_pcap}     0
    ${nft_tables}   Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=nft list chain ip filter MPLANE_OVERALL_RATELIMIT_CHAIN
    ${nft_after}    Get Regexp Matches    ${nft_tables}    (?<=packets )\\d+
    Log to console  ${nft_after}
    Check difference between two counters   ${nft_before}    ${nft_after}    10000

NESAS-CR_M51321C4-IPv4_Filtering_vDU
    Change Parameter on BTS     dist_name=MRBTS-${MRBTS}/TNLSVC-1/PMTNLINT-1
    ...                         param_name=IpInterfaceStatisticsInterval
    ...                         param_value=5min
    ...                         hw_type=vDU
    ${timeout}=      Evaluate   2000000/20000
    ${bytes}=        Evaluate   bytes("\\x00\\x01\\x02\\x03", "utf-8")
    log      ${bytes}      console=true
    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         ip_address=${LMP_VDU_IP}
    ...                         hw_type=vDU
    SSHLibrary.Open Connection    ${TEST_PC_IP}
    SSHLibrary.Login              ${TEST_PC_LOGIN}   ${TEST_PC_PASS}
    ${write}=  SSHLibrary.Write  sudo su
    Sleep  5
    ${sudo}=  SSHLibrary.Read
    Should contain    ${sudo}  password
    SSHLibrary.Write  ${TEST_PC_PASS}
    SSHLibrary.Read Until       expected=#
    Sleep  5           reason=Wait until login
    ${command}=      Catenate   sudo -S timeout 10 /usr/bin/python3 -c 'import scapy.all as
    ...                         scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${F1U_VDU}")/scapy.ICMP(chksum=0o22),
    ...                         pps=20000, loop=200000, iface="${F1U_VDU_VLAN}")'
    SSHLibrary.Write   ${command}
    Sleep  20          reason=Wait until commend is executed
    ${counter_value_after_1}    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         ip_address=${LMP_VDU_IP}
    ...                         hw_type=vDU
    ${counter_value_after_2}    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         ip_address=${LMP_VDU_IP}
    ...                         hw_type=vDU
    ${counter_value_after_1}=    Get Dictionary Values    ${counter_value_after_1}
    ${counter_value_after_2}=    Get Dictionary Values    ${counter_value_after_2}
    ${int_value_1}=    Convert To Integer    ${counter_value_after_1}[0]
    ${int_value_2}=    Convert To Integer    ${counter_value_after_2}[0]
    ${counters}=  Evaluate    ${int_value_1}+${int_value_2} > 0.75*200000
    Should Be True  ${counters}
    ${command}=      Catenate   sudo -S timeout 10 /usr/bin/python3 -c 'import scapy.all as
    ...                         scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${F1U_VDU}", ihl=6, len=20)/scapy.ICMP(),
    ...                         pps=20000, loop=200000, iface="${F1U_VDU_VLAN}")'
    SSHLibrary.Write   ${command}
    Sleep  20          reason=Wait until commend is executed
    ${counter_value_after_1}    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         ip_address=${LMP_VDU_IP}
    ...                         hw_type=vDU
    ${counter_value_after_2}    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         ip_address=${LMP_VDU_IP}
    ...                         hw_type=vDU
    ${counter_value_after_1}=    Get Dictionary Values    ${counter_value_after_1}
    ${counter_value_after_2}=    Get Dictionary Values    ${counter_value_after_2}
    ${int_value_1}=    Convert To Integer    ${counter_value_after_1}[0]
    ${int_value_2}=    Convert To Integer    ${counter_value_after_2}[0]
    ${counters}=  Evaluate    ${int_value_1}+${int_value_2} > 0.75*200000
    Should Be True  ${counters}
    [Teardown]  SSHLibrary.close all connections

NESAS-CR_M51321C4-IPv4_Filtering_vCU
    Change Parameter on BTS     dist_name=MRBTS-${MRBTS_CU}/TNLSVC-1/PMTNLINT-1
    ...                         param_name=IpInterfaceStatisticsInterval
    ...                         param_value=5min
    ...                         hw_type=vCU
    Log    ${MRBTS_CU}     console=true
    ${timeout}=      Evaluate   2000000/20000
    ${bytes}=        Evaluate   bytes("\\x00\\x01\\x02\\x03", "utf-8")
    log      ${bytes}      console=true
    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         choosen_object=3
    ...                         ip_address=${LMP_VCU_IP}
    ...                         hw_type=vCU
    SSHLibrary.Open Connection    ${TEST_PC_IP}
    SSHLibrary.Login              ${TEST_PC_LOGIN}   ${TEST_PC_PASS}
    ${write}=  SSHLibrary.Write  sudo su
    Sleep  5
    ${sudo}=  SSHLibrary.Read
    Should contain    ${sudo}  password
    SSHLibrary.Write  ${TEST_PC_PASS}
    SSHLibrary.Read Until       expected=#
    Sleep  5           reason=Wait until login
    ${command}=      Catenate   sudo -S timeout 10 /usr/bin/python3 -c 'import scapy.all as
    ...                         scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${F1U_VCU}")/scapy.ICMP(chksum=0o22),
    ...                         pps=20000, loop=200000, iface="${F1U_VCU_VLAN}")'
    SSHLibrary.Write   ${command}
    Sleep  20          reason=Wait until commend is executed
    ${counter_value_after_1}    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         choosen_object=3
    ...                         ip_address=${LMP_VCU_IP}
    ...                         hw_type=vCU
    ${counter_value_after_2}    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         choosen_object=3
    ...                         ip_address=${LMP_VCU_IP}
    ...                         hw_type=vCU
    ${counter_value_after_1}=    Get Dictionary Values    ${counter_value_after_1}
    ${counter_value_after_2}=    Get Dictionary Values    ${counter_value_after_2}
    ${int_value_1}=    Convert To Integer    ${counter_value_after_1}[0]
    ${int_value_2}=    Convert To Integer    ${counter_value_after_2}[0]
    ${counters}=  Evaluate    ${int_value_1}+${int_value_2} > 0.75*200000
    Should Be True  ${counters}
    ${command}=      Catenate   sudo -S timeout 10 /usr/bin/python3 -c 'import scapy.all as
    ...                         scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${F1U_VCU}", ihl=6, len=20)/scapy.ICMP(),
    ...                         pps=20000, loop=200000, iface="${F1U_VCU_VLAN}")'
    SSHLibrary.Write   ${command}
    Sleep  20          reason=Wait until commend is executed
    ${counter_value_after_1}    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         choosen_object=3
    ...                         ip_address=${LMP_VCU_IP}
    ...                         hw_type=vCU
    ${counter_value_after_2}    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...                         counter_id=M51321C4
    ...                         address_or_objects=objects
    ...                         choosen_object=3
    ...                         ip_address=${LMP_VCU_IP}
    ...                         hw_type=vCU
    ${counter_value_after_1}=    Get Dictionary Values    ${counter_value_after_1}
    ${counter_value_after_2}=    Get Dictionary Values    ${counter_value_after_2}
    ${int_value_1}=    Convert To Integer    ${counter_value_after_1}[0]
    ${int_value_2}=    Convert To Integer    ${counter_value_after_2}[0]
    ${counters}=  Evaluate    ${int_value_1}+${int_value_2} > 0.75*200000
    Should Be True  ${counters}
    [Teardown]  SSHLibrary.close all connections

NESAS-CR_Security_Event_Logging_In_ATL_vDU
    Test Setup NMS             vDU
    FOR    ${i}    IN RANGE    3
        Log      Step 1: Login to vDU via WebEM using Nemuadmin account    console=True
        ${conn}  Connect to ADMIN                                          hw_type=vDU
        Log      Step 2: Login to vDU via Rest API using BTS Security Administrator Account.    console=True
        Setup Local User Account           account_type=BTSSecurity        password=QAws123!@#
        ...                                status=active                   hw_type=vDU
        ${login}=    rest_api.Perform REST login      ${BTSSecurity}       vDU
        Log      Step 3: Gather tcpdump for 3 min.    console=True
        Start TCPdump          capture_type=pod       pod_names=po-cran1-oamext-0               hw_type=vDU
        Sleep    3min          reason=TCPdump
        ${pcap_path}=          Stop TCPdump and Download Pcap    pod_name=po-cran1-oamext-0     hw_type=vDU
        Disconnect from ADMIN          ${conn}              hw_type=vDU
    END
    Collect and check ATL logs NESAS        hw_type=vDU     username=Nemuadmin
    [Teardown]   Test Teardown NMS          vDU

NESAS-CR_Security_Event_Logging_In_ATL_vCU
    Test Setup NMS             vCU
    FOR    ${i}    IN RANGE    3
        Log      Step 1: Login to vCU via WebEM using Nemuadmin account    console=True
        ${conn}  Connect to ADMIN           hw_type=vCU
        Log      Step 2: Login to vDU via Rest API using BTS Security Administrator Account.    console=True
        Setup Local User Account           account_type=BTSSecurity        password=QAws123!@#
        ...                                status=active                   hw_type=vCU
        ${login}=  rest_api.Perform REST login             ${BTSSecurity}  vCU
        Log      Step 3: Gather tcpdump for 3 min.         console=True
        Start TCPdump    capture_type=pod   pod_names=po-cran${MRBTS}-oamext-0                  hw_type=vCU
        Sleep    3min                       reason=TCPdump
        ${pcap_path}=    Stop TCPdump and Download Pcap    pod_name=po-cran${MRBTS}-oamext-0    hw_type=vCU
        Disconnect from ADMIN          ${conn}              hw_type=vCU
    END
    Collect and check ATL logs NESAS        hw_type=vCU     username=Nemuadmin
    [Teardown]    Test Teardown NMS         vCU

NESAS-CR_Security_Event_Logging_In_ATL_RANNIC
    Test Setup NMS             vDU
    FOR    ${i}    IN RANGE    3
        Log       Step 1: Login to rannic via SSH                               console=True
        Login to RANNIC
        Log       Step 2: Gather tcpdump for 3 min.    console=True
        Start TCPdump                   capture_type=pod    pod_names=po-cran1-oamext-0    hw_type=vDU
        Sleep    3min                   reason=TCPdump
        ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=po-cran1-oamext-0    hw_type=vDU
    END
    Collect and check ATL logs NESAS        hw_type=vCU     username=toor4nsn
    [Teardown]    Test Teardown NMS         vCU
