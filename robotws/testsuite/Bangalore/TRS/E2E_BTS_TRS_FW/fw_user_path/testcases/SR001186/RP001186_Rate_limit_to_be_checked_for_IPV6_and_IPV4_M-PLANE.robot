*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to validate firewall rate limit for mplane packet"
	...		[Date]					"25-07-18"
	...		[Author]				"Abhishek Gupta"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
    ...		[Funtion_Hash_Tags]		"FIREWALL"

Force Tags              CA_E2ET_BTSTRSPZ        SBTS00        QCD_MN_RAN        QCP_RAN_VRF        CRT

Resource  taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup         Pre-conditions for testsuite
Suite Teardown      Post-conditions for test teardown



*** Test Cases ***
[1][1.1] RP001186_Rate limit to be checked for IPV6 and IPV4 M-PLANE.
    Pre-condition
	Get IPs and Vlan
	Check Firewall Status
	Verify MPlane Rate Limit	protocol=ntp	traffic_type=mplane_ipv4_rate_limit_drop
	Verify MPlane Rate Limit	protocol=ntp	traffic_type=mplane_ipv6_rate_limit_drop

	Verify Ssh Http Https Rate Limit	protocol=ssh	ipv4_traffic_type=mplane_ipv4_ssh_rate_limit_drop
    ...     ipv6_traffic_type=mplane_ipv6_ssh_rate_limit_drop	iptables_chain_name=${iptables_ssh_ratelimit_chain}
    ... 	iptables_limit_string_to_grep=${ssh_iptables_limit_string}	rate_limit_speed=${ssh_rate_limit_speed}

	Verify Ssh Http Https Rate Limit	protocol=http	ipv4_traffic_type=mplane_ipv4_http_rate_limit_drop
    ...	    ipv6_traffic_type=mplane_ipv6_http_rate_limit_drop	iptables_chain_name=${iptables_http_ratelimit_chain}
    ... 	iptables_limit_string_to_grep=${http_iptables_limit_string}	rate_limit_speed=${http_rate_limit_speed}

	Verify Ssh Http Https Rate Limit	protocol=https	ipv4_traffic_type=mplane_ipv4_https_rate_limit_drop
    ... 	ipv6_traffic_type=mplane_ipv6_https_rate_limit_drop	iptables_chain_name=${iptables_https_ratelimit_chain}
    ... 	iptables_limit_string_to_grep=${https_iptables_limit_string}	rate_limit_speed=${https_rate_limit_speed}
	Check Firewall Status

*** Keywords ***
Pre-condition
    Perform Commissioning       scf_file=${Base_scf}   verify_bts_status=False     timeout=400     alias=default
    sleep   300
    Run         sudo ifconfig eth3.300 inet6 add fc00::1/120

Get IPs and Vlan
	${mplane_ipv6_ip} = 	Get Parameter		param_path=${mplane_ipv6_moc_path}
	Set Suite Variable		${mplane_ipv6_ip}		${mplane_ipv6_ip}
	${mplane_ipv4_ip} = 	Get Parameter		param_path=${mplane_ipv4_moc_path}
	Set Suite Variable		${mplane_ipv4_ip}		${mplane_ipv4_ip}
	${cmp_ipv6_ip} = 	Get Parameter		param_path=${cmp_primary_ip_path}
	Set Suite Variable		${cmp_ipv6_ip}		${cmp_ipv6_ip}
	${cmp_ipv4_ip} = 	Get Parameter		param_path=${cmp_secondary_ip_path}
	Set Suite Variable		${cmp_ipv4_ip}		${cmp_ipv4_ip}

	${mplane_ipv4_ipif_dict} = 		Query Admin Infomodel		query=get object ${ipif_ipv4_moc_path} is [localIpAddr=${mplane_ipv4_ip}]
	${mplane_ipv4_ipif_moc}=		Get From Dictionary	dictionary=${mplane_ipv4_ipif_dict}		key=dist_name
	${mplane_ipv4_ipif}=			Replace String Using Regexp		string=${mplane_ipv4_ipif_moc}		pattern=${pattern_to_replace_in_moc}
    ...		replace_with=${EMPTY}
	${mplane_ipv4_ipif_path}=		Split String From Right		string=${mplane_ipv4_ipif}	separator=/
	${mplane_ipv4_ipif_id}=	Set Variable	${mplane_ipv4_ipif_path}[-2]
	${mplane_ipv4_vlan_value} = 	Get Parameter 	rat=lte 	param_path=${mplane_ipv4_ipif_id}:interfaceDN:vlanId

	${mplane_ipv6_ipif_dict} = 		Query Admin Infomodel		query=get object ${ipif_ipv6_moc_path} is [localIpAddr=${mplane_ipv6_ip}]
	${mplane_ipv6_ipif_moc}=		Get From Dictionary	dictionary=${mplane_ipv6_ipif_dict}		key=dist_name
	${mplane_ipv6_ipif}=			Replace String Using Regexp		string=${mplane_ipv6_ipif_moc}		pattern=${pattern_to_replace_in_moc}
    ...		replace_with=${EMPTY}
	${mplane_ipv6_ipif_path}=		Split String From Right		string=${mplane_ipv6_ipif}	separator=/
	${mplane_ipv6_ipif_id}=	Set Variable	${mplane_ipv6_ipif_path}[-2]
	${mplane_ipv6_vlan_value} = 	Get Parameter 	rat=lte 	param_path=${mplane_ipv6_ipif_id}:interfaceDN:vlanId

	Set Suite Variable	${mplane_ipv4_vlan_value}	${mplane_ipv4_vlan_value}
	Set Suite Variable	${mplane_ipv6_vlan_value}	${mplane_ipv6_vlan_value}

Check Firewall Status
	${mplane} = 	Get Parameter		param_path=${mplane_ip_moc_path}
	Set Suite Variable		${mplane}		${mplane}
	Setup Remote Access	remote_device=bts
	${ipv4_iptables_output}=		Remote Command Execute		command=iptables -xnvL	return_rc=True
    Convert To List		${ipv4_iptables_output}
	Log List	${ipv4_iptables_output}
	Should Contain Match		${ipv4_iptables_output}	regexp=${firewall_iptables_ratelimit_search_string}
	${ipv6_iptables_output}=		Remote Command Execute		command=ip6tables -xnvL	return_rc=True
    Convert To List		${ipv6_iptables_output}
	Log List	${ipv6_iptables_output}
	Should Contain Match		${ipv6_iptables_output}	regexp=${firewall_iptables_ratelimit_search_string}
	[Teardown]		Teardown Remote Access

Verify MPlane Rate Limit
	[Arguments]	${protocol}		${traffic_type}
	Set Suite Variable		${protocol}		${protocol}
	PM Counters Start		analysis=verify_ingress_rate_limit_packet_drop		counter_analysis_file=${counter_analysis_file_name}
	Send Packets		traffic_type=${traffic_type}
    ${rate_limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_rate_limit_packet_drop
    ...		counter_analysis_file=${counter_analysis_file_name}
	Set Suite Variable		${rate_limit_counters_list}		${rate_limit_counters_list}
	Verify Rate Limit	rate_limit_counters_list=${rate_limit_counters_list}

Verify Ssh Http Https Rate Limit
	[Arguments]	${protocol}	${ipv4_traffic_type}	${ipv6_traffic_type}	${iptables_chain_name}	${iptables_limit_string_to_grep}
    ...   ${rate_limit_speed}
	Set Suite Variable		${protocol}		${protocol}
	Get Initial Packet Value From Board	iptables_chain_name=${iptables_chain_name}	iptables_limit_string_to_grep=${iptables_limit_string_to_grep}
	Send Packets		traffic_type=${ipv4_traffic_type}
	Send Packets		traffic_type=${ipv6_traffic_type}
	Verify the Rate Limiting Speed Through Board	iptables_chain_name=${iptables_chain_name}
    ... 	iptables_limit_string_to_grep=${iptables_limit_string_to_grep}
    ...		rate_limit_speed=${rate_limit_speed}

Get Initial Packet Value From Board
	[Arguments]		${iptables_chain_name}	${iptables_limit_string_to_grep}
    Setup Remote Access	remote_device=bts
	${ipv4_iptables_initial_value}=		Remote Command Execute
    ... 		command=iptables -xnvL ${iptables_chain_name} | grep "${iptables_limit_string_to_grep}" | awk '{print $1}'

	${ipv6_iptables_initial_value}=		Remote Command Execute
    ... 		command=ip6tables -xnvL ${iptables_chain_name} | grep "${iptables_limit_string_to_grep}" | awk '{print $1}'

	Set Suite Variable		${ipv4_iptables_initial_value}		${ipv4_iptables_initial_value}
	Set Suite Variable		${ipv6_iptables_initial_value}		${ipv6_iptables_initial_value}
	[Teardown]		Teardown Remote Access

Send Packets
	[Arguments]		${traffic_type}
	Set Suite Variable		${traffic_type}		${traffic_type}
	Traffic Setup			device=device_1			alias=mplane
	${packet_speed}		${time} = 		Traffic Start 		profile=${traffic_type}		 alias=mplane
	Traffic Teardown	alias=mplane
	${packets}=		Evaluate	${packet_speed} * ${time}
	Set Suite Variable		${packets}		${packets}
	Set Suite Variable		${packet_speed}		${packet_speed}
	Set Suite Variable		${time}		${time}
    [Teardown]		Run Keyword And Ignore Error		Traffic Teardown	alias=mplane
Verify Rate Limit
	[Arguments]	${rate_limit_counters_list}
	Log 	${rate_limit_counters_list}
	${counters_list}=		Get Dictionary Values	${rate_limit_counters_list}

	FOR    ${counter}    IN    @{counters_list}
		${counter_param_dict}=		Get Dictionary Values	${counter}
		Final Calculations	${counter_param_dict}
    END

	${counters_increased} = 	Evaluate	${packets} - ${rate_limit_counters_increased}
	${rate_limiting_speed} = 	Evaluate	${counters_increased} / ${time}

	${packets_tolerance}=		Evaluate		${mplane_rate_limit} * 0.1
	${packets_min}=		Evaluate		${mplane_rate_limit} - ${packets_tolerance}
	${packets_max}=		Evaluate		${mplane_rate_limit} + ${packets_tolerance}
Final Calculations
	[Arguments]		${counter_param_dict}
	FOR    ${items}    IN    @{counter_param_dict}
		${rate_limit_counters_increased}=			Get From Dictionary  ${items}  final_counter_value
		Set Suite Variable		${rate_limit_counters_increased}		${rate_limit_counters_increased}
    END

Verify the Rate Limiting Speed Through Board
	[Arguments]		${iptables_chain_name}	${iptables_limit_string_to_grep}	${rate_limit_speed}
	Setup Remote Access	remote_device=bts
	${ipv4_iptables_final_value}=		Remote Command Execute
    ...		command=iptables -xnvL ${iptables_chain_name} | grep "${iptables_limit_string_to_grep}" | awk '{print $1}'
	${ipv4_packet_increase}=		Evaluate		${ipv4_iptables_final_value} - ${ipv4_iptables_initial_value}
	${ipv4_rate_limiting_speed} = 	Evaluate	${ipv4_packet_increase} / ${time}

	${ipv6_iptables_final_value}=		Remote Command Execute
    ...		command=ip6tables -xnvL ${iptables_chain_name} | grep "${iptables_limit_string_to_grep}" | awk '{print $1}'
	${ipv6_packet_increase}=		Evaluate		${ipv6_iptables_final_value} - ${ipv6_iptables_initial_value}
	${ipv6_rate_limiting_speed} = 	Evaluate	${ipv6_packet_increase} / ${time}

	${packets_tolerance}=		Evaluate		${rate_limit_speed} * 0.1
	${packets_min}=		Evaluate		${rate_limit_speed} - ${packets_tolerance}
	${packets_max}=		Evaluate		${rate_limit_speed} + ${packets_tolerance}

	Should be True		${packets_min} < ${ipv6_rate_limiting_speed} < ${packets_max}
    ...		msg=Rate Limiting not within 10% of expected ${rate_limit_speed} packets/sec
    [Teardown]		Teardown Remote Access
