***Settings ***
Documentation
    ...     [Procedure]             "MLDv2 reponse to queries with different destination addresses"
    ...     [Date]                  "13-05-24"
    ...     [Author]                "Monika Parasar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "LTE2807"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "ASOG 10.58.143.209"


Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup     Pre-conditions for testsuite
Suite Teardown     Post-conditions for testteardown
***Variables***
${Vlan_1_ip}                            2c00::2
${Multicast_address}                    ff3b::8000:0001
${count}                                0
${dscp}									56



*** Test Cases ***
[1][1.0] TRS_CRL29353_Verification_of_IPv6 interface Multicast Tx packet, octet and Discard counters

#Configure Setup with MBMS
    Perform Commissioning       scf_file=${SCF_MBMS_ipv6_plain}       verify_bts_status=False       timeout=300
    sleep       400
    Bring Up Logical Interfaces on VM
    sleep       120
    actMBMS flag should be activated
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Call Setup    lte=MBMS_IPV6_plain:data     parallel=${False}    verify_attach=${False}       attach=${False}
    Perform Recommissioning     type=param     param_path=LNM3-0:administrativeState   operation=update
	...     value=locked      timeout=300
    Perform Recommissioning     type=param     param_path=LNM3-0:administrativeState   operation=update
    ...     value=unlocked      timeout=300
    sleep       300
    Verify Bts Status
    Establish MBMS Session
    sleep       180
    ${MBMS_start}=       Traffic Capture Stop        alias=eth3_pcap
    sleep       180
    verify Wireshark For MBMS session message            ${MBMS_start}
    Get IP and MAC address
    install scapy

#send query messages with one session
    General query           ${br0_mac_addr}     ${Vlan_1_ip}            2
    G query           33:33:00:00:00:01       ff02::1             2
    Multicast address specific query with unicast dst                   2
    Multicast address specific query with multicast dst                 2
    Source and Multicast address specific query with unicast dst        2
    Source and Multicast address specific query with multicast dst      2

#Repeat the above step with 64 MBMS session
    Perform Recommissioning     type=param     param_path=IPNO-1:ndMldDscp   operation=update
    ...     value=36      timeout=300
    Set Suite Variable      ${dscp}     36
    Traffic Capture Start   capture_device=vm_eth3_interface             alias=MBMS_64start
    Establish 64 MBMS Sessions
    sleep       120
	${MBMS_64start}=       Traffic Capture Stop        alias=MBMS_64start
    verify Wireshark For 64 MBMS session message            ${MBMS_64start}
#send query messages with 64 MBMS session
    G1 query           ${br0_mac_addr}     ${Vlan_1_ip}            65
    G2 query           33:33:00:00:00:01       ff02::1             65
    Multicast address specific query with unicast dst1                   65
    Multicast address specific query with multicast dst1                 65
    Source and Multicast address specific query with unicast dst1        65
    Source and Multicast address specific query with multicast dst1      65

#Enhancement to  check 65th session gets rejected
#Step 7: verify 65 session
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=MBMS_65_SESSION
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=66:244:09 duration=0:900
    ...      sai=9 m1_dst_addr=ff3b::8000:0066 m1_teid=266 mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=5066
    ...      max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    sleep       30
    ${MBMS_65_SESSION}=       Traffic Capture Stop        alias=MBMS_65_SESSION
    verify Wireshark For 65 MBMS session message        ${MBMS_65_SESSION}
    Verify MBMS counters


***Keywords***
Stop Syslog And Analyse
    Stop syslog for 'enb' and 'iphy'
    Analyse Syslog  /tmp  out.csv  ${pattern}
	${unwanted_msg_found}=    Check For Unwanted Syslog Messages    out.csv
	Should Be True     '${unwanted_msg_found}'=='False'

actMBMS flag should be activated
    ${flag_status}=     Get Parameter      param_path=MRBTS-1/LNBTS-1:actMBMS
    ${flag_status1}=     Get Parameter      param_path=MRBTS-1/LNBTS-1:actIPv6MBMS
    Should Be Equal     '${flag_status}'    'True'
    Should Be Equal     '${flag_status1}'    'True'

Take backup commissioning file
    Generate Scf    ${target_file}


verify Wireshark For 65 MBMS session message
    [Arguments]         ${Wireshark_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=MBMS_65_session_response     filter_file_name=${pcap_file}

check mbms session display
    ${MBMS_SESSION}=   Execute Cmd On Egate   lte=MBMS_IPV6_plain:data        cmd=mbms_session_disp
    FOR    ${index}    IN RANGE    1  65
    Should Match Regexp        ${MBMS_SESSION}
    ...     (?i)${index}:244:08.*src:2c00::5,dst:ff3b::8000:${index},teid:20${index}.*
    END
   Should Not Match Regexp        ${MBMS_SESSION}     (?i):244:08.*src:2c00::5,dst:ff3b::8000:0066,teid:66.*


install scapy
    Run     pip install scapy


General query
    [Arguments]         ${dest_MAC_ADDR}        ${dest_ip}      ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...    alias=general_query
    send query message using scapy      general_query   ${dest_MAC_ADDR}     ${dest_ip}    1   eth3.200  ff3b::8000:0001
    sleep       30
    ${general_query}=       Traffic Capture Stop        alias=general_query
    Verify General Query message         ${general_query}       ${dest_ip}      ${range}


G query
    [Arguments]         ${dest_MAC_ADDR}        ${dest_ip}      ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...    alias=g_query
    send query message using scapy      general_query   ${dest_MAC_ADDR}     ${dest_ip}    1   eth3.200  ff3b::8000:0001
    sleep       30
    ${general_query}=       Traffic Capture Stop        alias=g_query
    Verify General Query message         ${general_query}       ${dest_ip}      ${range}


G1 query
    [Arguments]         ${dest_MAC_ADDR}        ${dest_ip}      ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...    alias=g1_query
    send query message using scapy      general_query   ${dest_MAC_ADDR}     ${dest_ip}    1   eth3.200  ff3b::8000:0001
    sleep       30
    ${general_query}=       Traffic Capture Stop        alias=g1_query
    Verify General Query message         ${general_query}       ${dest_ip}      ${range}

G2 query
    [Arguments]         ${dest_MAC_ADDR}        ${dest_ip}      ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...    alias=g2_query
    send query message using scapy      general_query   ${dest_MAC_ADDR}     ${dest_ip}    1   eth3.200  ff3b::8000:0001
    sleep       30
    ${general_query}=       Traffic Capture Stop        alias=g2_query
    Verify General Query message         ${general_query}       ${dest_ip}      ${range}




Multicast address specific query with unicast dst
    [Arguments]         ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ipi6
    ...       alias=multicast_addr_specific_unicast
    FOR  ${i}  IN RANGE    1   ${range}
    send query message using scapy      Multicast_address_specific_query    ${br0_mac_addr}     ${Vlan_1_ip}
    ...     1   eth3.200  ff3b::8000:${i}
    END
    sleep   120
    ${multicast_addr_specific_unicast}=     Traffic Capture Stop        alias=multicast_addr_specific_unicast
    Verify Multicast address specific query message with unicast dst
    ...     ${multicast_addr_specific_unicast}     ${range}

Multicast address specific query with multicast dst
    [Arguments]         ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...      alias=multicast_addr_specific_multicast
    FOR  ${i}  IN RANGE    1   ${range}
    send query message using scapy      Multicast_address_specific_query    33:33:80:00:00:${i}
    ...     ff3b::8000:${i}     1   eth3.200  ff3b::8000:${i}
    END
    sleep   120
	${multicast_addr_specific_multicast}=     Traffic Capture Stop        alias=multicast_addr_specific_multicast
    Verify Multicast address specific query message with muticast dst
    ...          ${multicast_addr_specific_multicast}          ${range}


Source and Multicast address specific query with unicast dst
    [Arguments]         ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...     alias=src_multicast_addr_specific_unicast
    FOR  ${i}  IN RANGE    1   ${range}
    send query message using scapy      Source_and_Multicast_address_specific_query     ${br0_mac_addr}
    ...         ${Vlan_1_ip}    1   eth3.200  ff3b::8000:${i}
    END
    sleep   120
    ${src_multicast_addr_specific_unicast}=     Traffic Capture Stop        alias=src_multicast_addr_specific_unicast
    Verify Source and Multicast address specific query message with unicast dst
    ...         ${src_multicast_addr_specific_unicast}        ${range}

Source and Multicast address specific query with multicast dst
    [Arguments]         ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...     alias=src_multicast_addr_specific_multicast
    FOR  ${i}  IN RANGE    1   ${range}
    send query message using scapy      Source_and_Multicast_address_specific_query     33:33:80:00:00:${i}
    ...     ff3b::8000:${i}     1   eth3.200  ff3b::8000:${i}
    END
    sleep   120
	${src_multicast_addr_specific_multicast}=     Traffic Capture Stop        alias=src_multicast_addr_specific_multicast
    Verify Source and Multicast address specific query message with multicast dst
    ...         ${src_multicast_addr_specific_multicast}        ${range}


Multicast address specific query with unicast dst1
    [Arguments]         ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...       alias=multicast_addr_specific_unicast1
    FOR  ${i}  IN RANGE    1   ${range}
    send query message using scapy      Multicast_address_specific_query    ${br0_mac_addr}     ${Vlan_1_ip}
    ...     1   eth3.200  ff3b::8000:${i}
    END
    sleep   120
    ${multicast_addr_specific_unicast}=     Traffic Capture Stop        alias=multicast_addr_specific_unicast1
    Verify Multicast address specific query message with unicast dst
    ...     ${multicast_addr_specific_unicast}     ${range}

Multicast address specific query with multicast dst1
    [Arguments]         ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...       alias=multicast_addr_specific_multicast1
    FOR  ${i}  IN RANGE    1   ${range}
    send query message using scapy      Multicast_address_specific_query    33:33:80:00:00:${i}
    ...     ff3b::8000:${i}     1   eth3.200  ff3b::8000:${i}
    END
    sleep   120
    ${multicast_addr_specific_multicast}=     Traffic Capture Stop        alias=multicast_addr_specific_multicast1
    Verify Multicast address specific query message with muticast dst
    ...          ${multicast_addr_specific_multicast}          ${range}

Source and Multicast address specific query with unicast dst1
    [Arguments]         ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...     alias=src_multicast_addr_specific_unicast1
    FOR  ${i}  IN RANGE    1   ${range}
    send query message using scapy      Source_and_Multicast_address_specific_query     ${br0_mac_addr}
    ...         ${Vlan_1_ip}    1   eth3.200  ff3b::8000:${i}
    END
    sleep   120
    ${src_multicast_addr_specific_unicast}=     Traffic Capture Stop        alias=src_multicast_addr_specific_unicast1
    Verify Source and Multicast address specific query message with unicast dst
    ...         ${src_multicast_addr_specific_unicast}        ${range}

Source and Multicast address specific query with multicast dst1
    [Arguments]         ${range}
    Traffic Capture Start   capture_device=vm_eth3_interface        capture_filter=(not broadcast and not multicast) or ip6
    ...     alias=src_multicast_addr_specific_multicast1
    FOR  ${i}  IN RANGE    1   ${range}
    send query message using scapy      Source_and_Multicast_address_specific_query     33:33:80:00:00:${i}
    ...     ff3b::8000:${i}     1   eth3.200  ff3b::8000:${i}
    END
    sleep   120
    ${src_multicast_addr_specific_multicast}=     Traffic Capture Stop        alias=src_multicast_addr_specific_multicast1
    Verify Source and Multicast address specific query message with multicast dst
    ...         ${src_multicast_addr_specific_multicast}        ${range}





Modify Vlan ID
     Copy File      ${delta_file_vlan_create}     ${tmp_delta_file_vlan_create}
    :FOR    ${i}    IN RANGE       4
    \       Run      sed -i -- 's/{{vlan_id_${i}}}/@{tl.vlan_ids}[${i}]/g' ${tmp_delta_file_vlan_create}

Bring Up Logical Interfaces on VM

    Run     sudo ifconfig eth3.200 inet6 add 2c00::1/116
    Run     sudo ifconfig eth3.200 inet6 add 2c00::5/116
    Run     sudo ip -6 route add table local ff00::/8 dev eth3.200 proto kernel metric 1
    Run     sudo sysctl -w net.ipv6.conf.eth0.disable_ipv6=1
    Run     sudo sysctl -w net.ipv6.conf.eth1.disable_ipv6=1
    Run     sudo sysctl -w net.ipv6.conf.eth2.disable_ipv6=1
    Run     sudo sysctl -w net.ipv6.conf.eth4.disable_ipv6=1

Establish MBMS Session
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=1:244:09 duration=0:900
    ...      sai=1 m1_dst_addr=ff3b::8000:0001 m1_teid=201 mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=5001
    ...      max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50

Establish 64 MBMS Sessions
    FOR    ${i}        IN RANGE    2  9
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=${i}:244:09 duration=0:900
    ...     sai=1 m1_dst_addr=ff3b::8000:${i} m1_teid=20${i} mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=500${i}
    ...     max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    END
    FOR    ${i}        IN RANGE    9  17
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=${i}:244:09 duration=0:900
    ...     sai=2 m1_dst_addr=ff3b::8000:${i} m1_teid=20${i} mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=500${i}
    ...     max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    END
    FOR    ${i}        IN RANGE    17  25
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=${i}:244:09 duration=0:900
    ...    sai=3 m1_dst_addr=ff3b::8000:${i} m1_teid=20${i} mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=500${i}
    ...      max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    END

    FOR    ${i}        IN RANGE    25  33
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=${i}:244:09 duration=0:900
    ...     sai=4 m1_dst_addr=ff3b::8000:${i} m1_teid=20${i} mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=500${i}
    ...      max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    END

    FOR    ${i}        IN RANGE    33  41
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=${i}:244:09 duration=0:900
    ...     sai=5 m1_dst_addr=ff3b::8000:${i} m1_teid=20${i} mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=500${i}
    ...      max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    END

    FOR    ${i}        IN RANGE    41  49
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=${i}:244:09 duration=0:900
    ...      sai=6 m1_dst_addr=ff3b::8000:${i} m1_teid=20${i} mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=500${i}
    ...      max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    END


    FOR    ${i}        IN RANGE    49  57
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=${i}:244:09 duration=0:900
    ...      sai=7 m1_dst_addr=ff3b::8000:${i} m1_teid=20${i} mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=500${i}
    ...      max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    END

    FOR    ${i}        IN RANGE    57  65
    Execute Cmd On Egate        lte=MBMS_IPV6_plain:data        cmd=mbms_session_start tmgi=${i}:244:09 duration=0:900
    ...      sai=8 m1_dst_addr=ff3b::8000:${i} m1_teid=20${i} mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=500${i}
    ...      max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    END

send query message using scapy
    [Arguments]     ${query_type}      ${Dst_MAC_addr}        ${Dst_ip}     ${count}      ${Interface}      ${m1addr}
    ${argumets}=    Catenate    ${query_type} ${source_MAC_ADDR} ${Dst_MAC_addr} ${source_ip} ${Dst_ip} ${count}
    ...     ${Interface} ${m1addr}
    Run             expect ${CURDIR}/../resources/send_multicast_query.exp ${argumets}

Get IP and MAC address
    Get MAC Address of br0 interface
    Get MAC Address of VM at eth3
    Get Link local ip from VM

Get MAC Address of br0 interface
    Execute command on gNB          ifconfig br0 | grep ether | awk -F ' ' '{print $2}'
    Set Suite Variable      ${br0_mac_addr}     ${stdout}
Get MAC Address of VM at eth3
    ${source_MAC_ADDR}=     Run     sudo ifconfig eth3 | grep ether | awk -F ' ' '{print $2}'
    Set Suite Variable      ${source_MAC_ADDR}          ${source_MAC_ADDR}

Get Link local ip from VM
    ${source_ip}=   Run     sudo ifconfig eth3 | grep fe80 | awk -F ' ' '{print $2}'| awk -F '/' '{print $1}'
    Set Suite Variable      ${source_ip}          ${source_ip}

verify Wireshark For MBMS session message
    [Arguments]         ${wireshark_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=MBMS_session_request     filter_file_name=${pcap_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=MBMS_session_response     filter_file_name=${pcap_file}

verify Wireshark For 64 MBMS session message
    [Arguments]         ${wireshark_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=MBMS_session_request_64_session     filter_file_name=${pcap_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=MBMS_session_response_64_session     filter_file_name=${pcap_file}

Verify General Query message
    [Arguments]         ${wireshark_file}   ${dst_ip}    ${range}
    Set Suite Variable          ${source_ip}          ${source_ip}
    Set Suite Variable          ${dst_ip}             ${dst_ip}
    Set Suite Variable          ${br0_mac_addr}          ${br0_mac_addr}
    Set Suite Variable          ${dscp}          ${dscp}
#    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=General_query_request     filter_file_name=${pcap_file}
    FOR  ${i}   IN RANGE  1  ${range}
    Set Suite Variable          ${i}          ${i}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=General_query_response     filter_file_name=${pcap_file}
    END

Verify Multicast address specific query message with unicast dst
    [Arguments]         ${wireshark_file}    ${range}
    Set Suite Variable          ${source_ip}          ${source_ip}
    Set Suite Variable          ${Vlan_1_ip}             ${Vlan_1_ip}
    Set Suite Variable          ${br0_mac_addr}          ${br0_mac_addr}
    FOR  ${i}   IN RANGE  1  ${range}
    Set Suite Variable          ${i}          ${i}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=Multicast_address_specific_with_unicast_dst_query
    ...     filter_file_name=${pcap_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=Multicast_address_specific_with_unicast_dst_response
    ...     filter_file_name=${pcap_file}
    END
Verify Multicast address specific query message with muticast dst
    [Arguments]         ${wireshark_file}    ${range}
    Set Suite Variable          ${source_ip}          ${source_ip}
    Set Suite Variable          ${br0_mac_addr}          ${br0_mac_addr}
    Set Suite Variable          ${dscp}          ${dscp}
    FOR  ${i}   IN RANGE  1  ${range}
    Set Suite Variable          ${i}          ${i}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=Multicast_address_specific_with_multicast_dst_response
    ...    filter_file_name=${pcap_file}
    END

Verify Source and Multicast address specific query message with unicast dst
    [Arguments]         ${wireshark_file}        ${range}
    Set Suite Variable          ${source_ip}          ${source_ip}
    Set Suite Variable          ${Vlan_1_ip}             ${Vlan_1_ip}
    Set Suite Variable          ${br0_mac_addr}          ${br0_mac_addr}
    FOR  ${i}   IN RANGE  1  ${range}
    Set Suite Variable          ${i}          ${i}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=Source_Multicast_address_specific_with_unicast_dst_query
    ...     filter_file_name=${pcap_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=Source_Multicast_address_specific_with_unicast_dst_response
    ...     filter_file_name=${pcap_file}
    END

Verify Source and Multicast address specific query message with multicast dst
    [Arguments]         ${Wireshark_file}        ${range}
    Set Suite Variable          ${source_ip}          ${source_ip}
    Set Suite Variable          ${br0_mac_addr}          ${br0_mac_addr}
    Set Suite Variable          ${dscp}          ${dscp}
    FOR  ${i}   IN RANGE  1  ${range}
    Set Suite Variable          ${i}          ${i}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=Source_Multicast_address_specific_with_multicast_dst_response
    ...     filter_file_name=${pcap_file}
    END
Verify MBMS counters
     Pm Counters Start     analysis=verify_Mcast_IPIF_counters       counter_analysis_file=${counter_analysis_file_name}
     sleep       120
     Verify Pm Counters      analysis=verify_Mcast_IPIF_counters       counter_analysis_file=${counter_analysis_file_name}
