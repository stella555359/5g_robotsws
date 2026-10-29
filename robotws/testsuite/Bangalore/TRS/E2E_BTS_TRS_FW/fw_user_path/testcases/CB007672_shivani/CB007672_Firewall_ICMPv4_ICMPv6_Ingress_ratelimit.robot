***Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate IPv6 Ingress rate limit for icmp packet"
    ...     [Date]                  "30-03-20"
    ...     [Author]                "Abhishek Gupta"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "FIREWALL, COUNTERS"
    ...     [Feature_ID]            "RP000366,5G000265,CNI40152-A"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5G-9016"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

#Suite Setup     Run Keywords        Suite Setup Preconditions
#...     AND     Setup Oamops
#Suite Teardown     Run Keywords     Suite Teardown Postconditions
#...     AND     Teardown Oamops
Suite Setup     Setup Oamops
Suite Teardown      Teardown Oamops
#Suite Setup                 Pre-conditions for testsuite
#Suite Teardown              Post-conditions for testteardown

*** Variables ***
${counter_analysis_file_name}                   cb7135_counters_analysis.json
#${iprt_ip6_moc_path}         IPRTV6-1:staticIpv6Routes:gatewayIpv6Addr
#${mplane_ip6_moc_path}       MPLANENM-1:mPlaneIpv6AddressDN:localIpAddr
${mplane_ipv6}          fc00::2
${iprt_ipv6}            fc00::1

*** Test Cases ***
[1][1.0]TRS_CB007672_A_Ingress_rate_limiting_ICMPv6_errormessages
	[Documentation]		This test case validates firewall Ingress rate limits for various ICMPv6 types
	Perform Recommissioning        type=delta      delta_file=${basic_7135_configuration}
	...		timeout=400     skip_parameter_relation_errors=${False}
    Run     sudo ip a a fc00::3:1/120 dev eth3
    Get IPs To Ping
    Test Ipconnectivity       remote_address=${iprt_ipv6}       dscp=10       payload_size=16
	...		source_address=${mplane_ipv6}       timeout=30       alias=default
	Verify Ingress Rate Limit For ICMPv6 Type Vmap

	Verify Ingress Rate Limit For ICMPv6 Type MLD And NDP
*** Keywords ***
Install Scapy
    Run         unzip /home/ute/MN/UTE/robotlte/resources/TRS_IV_BLR/lib/scapy/scapy-2.3.1.zip
    ${a}=    Run    cd scapy-2.3.1; sudo python setup.py install;
    Sleep   30

Get IPs To Ping
	[Documentation]		This keyword reads a common IPv6 IP for all RAT config perspective.
    ${mplane_ipv6} =    Get Parameter      param_path=${mplane_ip6_moc_path}
    Set Suite Variable      ${mplane_ipv6}
    ${iprt_ipv6} =      Get Parameter      param_path=${iprt_ip6_moc_path}
    Set Suite Variable      ${iprt_ipv6}
Fetch Ingress Rules From Board
	[Documentation]		This keyword checks for the user defined runtime argument ${rule_type} and calls different keywords accordingly.
#	${rule_type} is pybot command line argument.
	Run Keyword If      '${rule_type}'=='nftlist'       Fetch Ingress Rules From NFTLIST And Verify
	Run Keyword If      '${rule_type}'=='iptables'      Fetch Ingress Rules From IPTABLES And Verify

Fetch Ingress Rules From NFTLIST And Verify
	[Documentation]		This keyword fetches firewall rules for all IPv4 and IPv6 types Ingress traffic using nft list command. \n
	...		If any rule is not present, the keyword will fail.
	Setup Remote Access		remote_device=bts
	${file_permission_output}=		Remote Command Execute		command=nft list chain inet filter ICMP_INGRESS

	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_ECHO_RESPONSE
	Log	${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_DEST_UNREACHABLE
	Log	${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_ECHO_REQUEST
	Log	${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_TIME_EXCEEDED
	Log	${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_PARAMETER_PROBLEM
	Log	${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_DEST_UNREACHABLE
	Log	${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_PACKET_2BIG
	Log	${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_TIME_EXCEEDED
	Log	${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_PARAMETER_PROBLEM
	Log	${icmp_vmap_ingress_output}
    ${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_ECHO_REQUEST
    ${icmp_vmap_ingress_output}=       Remote Command Execute
	...		command=nft list chain inet filter V6INGRESS_ECHO_REQUEST | grep -i "limit rate 25/second burst 8 packets"

	Log	${icmp_vmap_ingress_output}
    Convert To List		${icmp_vmap_ingress_output}
	Should Contain Match		${icmp_vmap_ingress_output}	regexp=${search_string}


    ${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_ECHO_RESPONSE
	Log	${icmp_vmap_ingress_output}

	${icmpv6_mld_ingress_output}=	Remote Command Execute		command=nft list chain inet filter INGRESS_MLD_CHAIN
	Log	${icmpv6_mld_ingress_output}
	${icmpv6_ndp_ingress_output}=	Remote Command Execute		command=nft list chain inet filter INGRESS_NDP_CHAIN
	Log	${icmpv6_ndp_ingress_output}

	[Teardown]		Teardown Remote Access


Fetch Ingress Rules From IPTABLES And Verify
	[Documentation]		This keyword fetches firewall rules for all IPv4 and IPv6 types Ingress traffic using iptables command. \n
	...		If any rule is not present, the keyword will fail.

	Setup Remote Access		remote_device=bts

	${icmp_ingress_output}=		Remote Command Execute		command=iptables -nvL ICMP_INGRESS
	Log	${icmp_ingress_output}

	${icmpv6_ingress_output}=	Remote Command Execute		command=ip6tables -nvL ICMPV6_INGRESS
	Log	${icmpv6_ingress_output}

	${icmpv6_mldv6_ingress_output}=	Remote Command Execute		command=ip6tables -nvL MLDV6_INGRESS
	Log	${icmpv6_mldv6_ingress_output}
	${icmpv6_ndpv6_ingress_output}=	Remote Command Execute		command=ip6tables -nvL NDPV6_INGRESS
	Log	${icmpv6_ndpv6_ingress_output}

	[Teardown]		Teardown Remote Access


Verify Ingress Rate Limit For ICMPv6 Type Vmap
	[Documentation]		This keyword sends traffic at speed more than accepted limit (more than 25 pkt/sec) and verifies the rate limit funtionality.

	Fetch Ingress Rules From Board
	PM Counters Start		analysis=verify_ingress_rate_limit_packet_drop		counter_analysis_file=${counter_analysis_file_name}
	Traffic Setup			device=device_1

	#Below step is sending all packets will rate lmiit 25 pkts/sec for every 100 sec and verification is based on cumulative count.

    ${packets_128}	${time_128}=	Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=128		code=0		speed=1500
	${packets_129}	${time_129}=        Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=129		code=0		speed=1300
	${packets_1}	${time_1}=      Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=1		code=0		speed=1300
	${packets_2}	${time_2}=      Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=2		code=0		speed=1300
	${packets_3}	${time_3}=      Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=3		code=0		speed=1300
	${packets_4}	${time_4}=      Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=4		code=0		speed=1300

	${rate_limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_rate_limit_packet_drop
	...		counter_analysis_file=${counter_analysis_file_name}
 ${rate_limit_counters_list}=        Run Keyword And Ignore Error   Verify PM Counters      analysis=verify_ingress_rate_limit_packet_drop
 	...		counter_analysis_file=${counter_analysis_file_name}
	Set Suite Variable		${rate_limit_counters_list}		${rate_limit_counters_list}

	${total_packets_sent} = 	Evaluate	${packets_129} + ${packets_1} + ${packets_2} + ${packets_3} + ${packets_4} + ${packets_128}
	${total_time} = 	Evaluate	${time_129} + ${time_1} + ${time_2} + ${time_3} + ${time_4} + ${time_128}

 W/O 128
	${total_packets_sent} = 	Evaluate	${packets_129} + ${packets_1} + ${packets_2} + ${packets_3} + ${packets_4}
	${total_time} = 	Evaluate	${time_129} + ${time_1} + ${time_2} + ${time_3} + ${time_4}

	Run Keyword And Continue On Failure		Verify Rate Limit From Admin For One Counter	rate_limit_counters_list=${rate_limit_counters_list}
	...		packets_sent=${total_packets_sent}		total_time=${total_time}	rate_limit_to_verify=${icmpv6_vmap_rate_limit}
	Fetch Ingress Rules From Board

	[Teardown]		Run Keyword And Ignore Error		Traffic Teardown

Verify Ingress Rate Limit For ICMPv6 Type MLD And NDP
	[Documentation]		This keyword sends traffic at speed more than accepted limit (more than 500 pkt/sec) and verifies the rate limit funtionality.
	Fetch Ingress Rules From Board
	PM Counters Start		analysis=verify_ingress_rate_limit_packet_drop		counter_analysis_file=${counter_analysis_file_name}
	Traffic Setup			device=device_1     alias=device_1
	#Below step is sending all packets will rate lmiit 500 pkts/sec for every 100 sec and verification is based on cumulative count.
	#As each of below types have same rate limit so cumulative average still remains same.
	#If we need to check only one type in case of a failure, then commment out other packet and time
	#from other types and handle ${total_packets_sent} and ${total_time} accordingly

	${packets_133}	${time_133}=	Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=133		code=0		speed=1500
	${packets_134}	${time_134}=	Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=134		code=0		speed=1500
	${packets_135}	${time_135}=	Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=135		code=0		speed=1500
	${packets_136}	${time_136}=	Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=136		code=0		speed=1500
	${packets_130}	${time_130}=	Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=130		code=0		speed=1500
	${packets_143}	${time_143}=	Send Packets to BTS		profile=icmpv6_rate_limit_drop		type=143		code=0		speed=1500

	${rate_limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_rate_limit_packet_drop
	...		counter_analysis_file=${counter_analysis_file_name}
    ${rate_limit_counters_list}=        Run Keyword And Ignore Error   Verify PM Counters      analysis=verify_ingress_rate_limit_packet_drop
	...      counter_analysis_file=${counter_analysis_file_name}
	Set Suite Variable		${rate_limit_counters_list}		${rate_limit_counters_list}

#ORG
	${total_packets_sent}= 	Evaluate	${packets_133} + ${packets_134} + ${packets_135} + ${packets_136} + ${packets_130} + ${packets_143}
	${total_time}= 	Evaluate	${time_133} + ${time_134} + ${time_135} + ${time_136} + ${time_130} + ${time_143}


#without 133
    ${total_packets_sent}=  Evaluate    ${packets_134} + ${packets_135} + ${packets_136} + ${packets_130} + ${packets_143}
    ${total_time}=  Evaluate    ${time_134} + ${time_135} + ${time_136} + ${time_130} + ${time_143}



	Run Keyword And Continue On Failure		Verify Rate Limit From Admin For One Counter	rate_limit_counters_list=${rate_limit_counters_list}
	...		packets_sent=${total_packets_sent}		total_time=${total_time}	rate_limit_to_verify=${icmpv6_mld_ndp_rate_limit}
	Fetch Ingress Rules From Board
	[Teardown]		Run Keyword And Ignore Error		Traffic Teardown
