*** Settings ***
Documentation
...     [Procedure]             "The test case is planned to validate IPv4 Ingress rate limit for icmp packet"
...     [Date]                  "27-12-21"
...     [Author]                "Vishal G"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "FIREWALL, COUNTERS, NETACT"
...     [Domain_Hash_Tags]      "counters"
...     [Feature_ID]            "RP000366,5G000265,CNI40152-A,CB007672,SR002103"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-3907"
...     [Config_Comments]       "This script requires basic SCF loading"
...     [RunTime Parameters]    "bts_id used is 3907 and we have pass the rule type depending on the HW. for ASOE it is
...                              nftlist"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB007672_5G_Porting of SR002103_Rate limiting for ingress & egress ICMP echo request packets IPV4 and IPV6
	[Documentation]		This test case validates firewall Ingress rate limits for various ICMPv4 types
    Perform Commissioning       scf_file=${Full_Configuration}   verify_bts_status=False     timeout=400     alias=default
    Sleep   900

    Setup Ems   config_device=netact3   alias=lab1042
    Cm Upload   config_device=netact3   alias=lab1042

	Get IPs To Ping

	Verify Ingress Rate Limit For ICMPv4
    Verify Ingress Rate Limit For ICMPv6

    [Teardown]  Teardown Ems    config_device=netact3   alias=lab1042

*** Keywords ***
Get IPs To Ping
	[Documentation]		This keyword reads a common IPv4 IP for all RAT config perspective.
	${mplane_ipv4} =  Get Parameter       param_path=${mplane_ip_moc_path}  rat=5g
	Set Suite Variable      ${ipv4_ip}        ${mplane_ipv4}
    ${mplane_ipv6} =  Get Parameter      param_path=${mplane_v6_ip_moc_path}
    Set Suite Variable      ${ipv6_ip}        ${mplane_ipv6}

Verify Ingress Rate Limit For ICMPv4
	[Documentation]		This keyword sends traffic at speed more than accepted limit (more than 25 pkt/sec) and
	...     verifies the rate limit funtionality.

	Fetch Ingress Rules From Board

    Start Netact Pm Counters      config_device=netact3     analysis=verify_icmp_ingress_rate_limit_packet_drop
    ...     counter_analysis_file=${counter_analysis_file_name}     alias=lab1042
    Sleep   90

    Traffic Setup       device=device_1

    #Below step is sending all packets with rate lmiit 25 pkts/sec for every 100 sec and verification is based on
    #cumulative count.
    #As each of below types have same rate limit so cumulative average still remains same.
    #If we need to check only one type in case of a failure, then commment out other packet and time from other types
    #and handle ${totl_p_sent} and ${totl_time} accordingly

	${p_echo_req}	    ${t_echo_req}=	    Send Packets to BTS		profile=icmpv4_rate_limit_drop
	...     type='echo-request'
	${p_echo_resp}    ${t_echo_resp}=      Send Packets to BTS     profile=icmpv4_rate_limit_drop
	...     type='echo-reply'
	${p_dest_unreach}    ${t_dest_unreach}=    Send Packets to BTS     profile=icmpv4_rate_limit_drop
	...     type='dest-unreach'
    ${p_param_prob}    ${t_param_prob}=    Send Packets to BTS     profile=icmpv4_rate_limit_drop
    ...     type='parameter-problem'
    ${p_time_exceed}    ${t_time_exceed}=    Send Packets to BTS     profile=icmpv4_rate_limit_drop
    ...     type='time-exceeded'

    &{rate_limit_counters_list}=        Verify Netact Pm Counters     config_device=netact3
    ...     analysis=verify_icmp_ingress_rate_limit_packet_drop      counter_analysis_file=${counter_analysis_file_name}
    ...     alias=lab1042

    ${totl_p_sent}=  Evaluate    ${p_echo_req} + ${p_dest_unreach} + ${p_echo_resp} + ${p_param_prob} + ${p_time_exceed}
    ${totl_time}=  Evaluate    ${t_echo_req} + ${t_dest_unreach} + ${t_echo_resp} + ${t_param_prob} + ${t_time_exceed}

    Verify Rate Limit Per Counter       ${rate_limit_counters_list}     ${totl_p_sent}      ${totl_time}

	[Teardown]		Run Keyword And Ignore Error		Traffic Teardown

Verify Rate Limit Per Counter
    [Arguments]     ${rate_limit_counters_list}     ${totl_p_sent}      ${totl_time}

    &{rl_rules}=    Create Dictionary       ${C0}        ${icmp_C0_rate_limit}          ${C15}       ${icmp_C15_rate_limit}
    ${counter_list} =   Get Dictionary Values     ${rate_limit_counters_list}
    @{counters_to_verify}=     Create List      ${C0}        ${C15}
     FOR   ${counter}      IN     @{counters_to_verify}
           Verify Counter List Against Counter Number    ${counter_list}     ${counter}      ${totl_p_sent}     ${totl_time}
           ...      ${rl_rules['${counter}']}
     END

Verify Counter List Against Counter Number
    [Arguments]     ${counter_output_list}      ${counter}      ${packets_sent}     ${total_time}       ${rate_limit_to_verify}
    FOR   ${counter_content}      IN      ${counter_output_list}[0]
          ${content}=   Get From Dictionary         ${counter_content}        ${counter}
          Run Keyword If    ${content}==''      Exit For Loop
          ${rate_limit_counters_increased}=     Get From Dictionary     ${content}      final_counter_value

          ${counters_increased} =       Evaluate        ${packets_sent} - ${rate_limit_counters_increased}
          ${rate_limiting_speed} =      Evaluate     ${counters_increased} / ${total_time}
          ${packets_tolerance}=     Evaluate    ${rate_limit_to_verify} * 0.1
          ${packets_min}=   Evaluate    ${rate_limit_to_verify} - ${packets_tolerance}
          ${packets_max}=   Evaluate      ${rate_limit_to_verify} + ${packets_tolerance}

          Should be True    ${packets_min} < ${rate_limiting_speed} < ${packets_max}
          ...       msg=Rate Limiting not within 10% of expected ${rate_limit_to_verify}
    END

Verify Ingress Rate Limit For ICMPv6
    [Documentation]     This keyword sends traffic at speed more than accepted limit (more than 25 pkt/sec) and
    ...     verifies the rate limit funtionality.

    Fetch Ingress Rules From Board
    Start Netact Pm Counters      config_device=netact3     analysis=verify_icmp_ingress_rate_limit_v6_packet_drop
    ...     counter_analysis_file=${counter_analysis_file_name}     alias=lab1042
    Sleep   90
    Traffic Setup           device=device_1

    #Below step is sending all packets with rate lmiit 25 pkts/sec for every 100 sec and verification is based on
    #cumulative count.
    #As each of below types have same rate limit so cumulative average still remains same.
    #If we need to check only one type in case of a failure, then commment out other packet and time from other types
    #and handle ${totl_p_sent} and ${totl_time} accordingly

#   ${pkt_1}    type='destination-unreachable'      code=3(address_unreachable)
#   ${pkt_2}    type='packet-too-big'
#   ${pkt_3}    type='time-exceeded'
#   ${pkt_4}    type='parameter problem'
#   ${pkt_128}  type='echo-request'
#   ${pkt_129}  type='echo-reply'

    ${pkt_128}  ${time_128}=    Send Packets to BTS     profile=icmpv6_rate_limit_drop      type=128    code=0
    ...     speed=1300
    ${pkt_129}  ${time_129}=    Send Packets to BTS     profile=icmpv6_rate_limit_drop      type=129    code=0
    ...     speed=1300
    ${pkt_1}    ${time_1}=      Send Packets to BTS     profile=icmpv6_rate_limit_drop      type=1      code=0
    ...     speed=1300
    ${pkt_2}    ${time_2}=      Send Packets to BTS     profile=icmpv6_rate_limit_drop      type=2      code=0
    ...     speed=1300
    ${pkt_3}    ${time_3}=      Send Packets to BTS     profile=icmpv6_rate_limit_drop      type=3      code=0
    ...     speed=1300
    ${pkt_4}    ${time_4}=      Send Packets to BTS     profile=icmpv6_rate_limit_drop      type=4      code=0
    ...     speed=1300

    ${rate_limit_counters_list}=    Verify Netact Pm Counters     config_device=netact3
    ...     analysis=verify_icmp_ingress_rate_limit_v6_packet_drop
    ...     counter_analysis_file=${counter_analysis_file_name}     alias=lab1042

    ${totl_p_sent} =     Evaluate    ${pkt_1} + ${pkt_2} + ${pkt_3} + ${pkt_4} + ${pkt_129} + ${pkt_128}
    ${totl_time} =     Evaluate    ${time_1} + ${time_2} + ${time_3} + ${time_4} + ${time_129} + ${time_128}

    Verify Rate Limit Per Counter       ${rate_limit_counters_list}     ${totl_p_sent}      ${totl_time}

    [Teardown]      Run Keyword And Ignore Error        Traffic Teardown

Fetch Ingress Rules From Board
	[Documentation]		This keyword checks for the user defined runtime argument ${rule_type} and calls different
	...     keywords accordingly.
#	${rule_type} is pybot command line argument.
	Run Keyword If		'${rule_type}'=='nftlist'	Fetch Ingress Rules From NFTLIST And Verify
	Run Keyword If		'${rule_type}'=='iptables'	Fetch Ingress Rules From IPTABLES And Verify

Fetch Ingress Rules From NFTLIST And Verify
	[Documentation]		This keyword fetches firewall rules for all IPv4 Ingress traffic using nft list command. \n
	...		If any rule is not present, the keyword will fail.

	Setup Remote Access		remote_device=bts

	${file_permission_output}=		Remote Command Execute		command=nft list chain inet filter ICMP_INGRESS

	${icmp_vmap_ingress_output}=		Remote Command Execute
	...     command=nft list chain inet filter INGRESS_ECHO_RESPONSE
	Log	    ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute
	...     command=nft list chain inet filter INGRESS_DEST_UNREACHABLE
	Log	    ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute
	...     command=nft list chain inet filter INGRESS_ECHO_REQUEST
	Log	    ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute
	...     command=nft list chain inet filter INGRESS_TIME_EXCEEDED
	Log	    ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute
	...     command=nft list chain inet filter INGRESS_PARAMETER_PROBLEM
	Log	    ${icmp_vmap_ingress_output}

	[Teardown]		Teardown Remote Access

Fetch Ingress Rules From IPTABLES And Verify
	[Documentation]		This keyword fetches firewall rules for all IPv4 Ingress traffic using iptables command. \n
	...		If any rule is not present, the keyword will fail.

	Setup Remote Access		remote_device=bts

	${icmp_ingress_output}=		Remote Command Execute		command=iptables -nvL ICMP_INGRESS
	Log	    ${icmp_ingress_output}

	[Teardown]		Teardown Remote Access

