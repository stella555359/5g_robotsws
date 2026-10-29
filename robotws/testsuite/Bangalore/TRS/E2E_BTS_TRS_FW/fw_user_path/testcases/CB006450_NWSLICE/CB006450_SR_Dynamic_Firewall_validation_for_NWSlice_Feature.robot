***Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate Activation of the feature SR002488"
    ...     [Date]                  "06-04-2020"
	...		[SCF]					"SCF_Vlan_IPV6_single_slice_single_operator_SBTS3737.xml"
    ...     [Author]                "Monika Parasar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB006450"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "SBTS3737"

Force Tags     CA_E2ET_BTSTRSPZ        SBTS00        [SBTS21A]     4G_FDD       CRT
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

#Suite Setup     Setup Oamops
#Suite Teardown     Teardown Oamops

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops

*** Test Cases ***
[1]CB006450-SR_Dynamic Firewall validation for NWSlice Feature
    Precondition
	Call Setup  lte=CB006450_IPv6_single_operaror_cfg:data    parallel=${False}    verify_attach=${False}       attach=${False}
    Verify Bts Status
	Verify Alarm    faultid=6150	 should_exist=${False}
	sleep		60
	Get IP Address
	Perform Recommissioning     type=param  param_path=${DynamicFirewall_flag}    operation=update    value=true     timeout=300
	Check ip tables with dynamic firewall			True
	sleep		60
	modify NWSLICE SGW and verify iptables
	Perform Recommissioning     type=param  param_path=${DynamicFirewall_flag}    operation=update    value=false     timeout=300
	sleep		60
	Check ip tables with dynamic firewall			False
    Verify Alarm    faultid=6150	 should_exist=${False}

***Keywords***
Precondition
	Perform Commissioning    	verify_bts_status=False        timeout=400
	${interface_last_octet}=        Set Variable        209
    ${Application_adddress_last_octet}=     Set Variable        210
	${interface_adddress_last_octet_IPv6}=      Set Variable        0X06
    FOR        ${i}        IN RANGE    0      9
            ${interface_adddress_last_octet_IPv6_hex}=      Evaluate        hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
            ${broadcast_last_octet}=       Evaluate        ${interface_last_octet}+2
            Run     sudo ip link add link eth3 name eth3.${tl.vlan_ids}[${i}] type vlan id ${tl.vlan_ids}[${i}]
    		Run     sudo ip addr add 10.0.3.${interface_last_octet}/30 brd 10.0.3.${broadcast_last_octet} dev eth3.${tl.vlan_ids}[${i}]
    		Run     sudo ip link set dev eth3.${tl.vlan_ids}[${i}] up
			Run		sudo ifconfig eth3.${tl.vlan_ids}[${i}] inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
            ${interface_last_octet}=       Evaluate        ${interface_last_octet}+4
	 		${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
    END
    Run     sudo ip a a 10.0.1.130/24 dev eth3
    Run     sudo ip a a 10.0.1.5/24 dev eth3
    Run     sudo ifconfig eth3 inet6 add fc00::20/116
    Run     sudo ifconfig eth3 inet6 add fc00::21/116
    Run     sudo ifconfig eth3 inet6 add fc00::1/116
	sleep		1000

Get IP Address
    ${GTP_Sgw_ip_addr}=         Create List
    ${NWSLICE_SGW}=         Create List
    ${NW_SLICE_ip}=         Create List
    ${MME_ip_addr}=         Create List
    ${uplane1}=             Create List
    ${uplane1_ipv6}=        Create List
    ${cplane1}=             Create List
    ${cplanev6}=             Create List
    ${UPLANE_IP} =        Get Parameter           param_path=${UPLANE_IP}
    ${UPLANE_IPV6} =        Get Parameter           param_path=${UPLANE_IPV6}
    ${CPLANE_IP} =        Get Parameter           param_path=${CPLANE_IP}
    ${CPLANEv6_IP} =        Get Parameter           param_path=${CPLANE_IPV6}
    ${Sgw_ip_addr_list}=     Get Parameter           param_path=${GTPU_address}
    FOR    ${Sgw_ip}         IN      @{Sgw_ip_addr_list}
           ${Sgw_ip_address}=      Get From Dictionary             dictionary=${Sgw_ip}             key=sgwIpAddress
           Append To List      ${GTP_Sgw_ip_addr}          ${Sgw_ip_address}
    END
    FOR            ${i}        IN RANGE        0       1
           ${MMEIp}=       Get Parameter           param_path=LNMME-${i}:ipAddrPrim
           Append To List      ${MME_ip_addr}          ${MMEIp}
    END
    Set Suite Variable      ${GTP_Sgw_ip_addr}          ${GTP_Sgw_ip_addr}
    Set Suite Variable      ${NWSLICE_SGW}          ${NWSLICE_SGW}
    Set Suite Variable      ${NW_SLICE_ip}          ${NW_SLICE_ip}
    Set Suite Variable      ${uplane1}              ${UPLANE_IP}
    Set Suite Variable      ${uplane1_ipv6}         ${UPLANE_IPV6}
    Set Suite Variable      ${cplanev6}             ${CPLANEv6_IP}
    Set Suite Variable      ${cplane1}              ${CPLANE_IP}
    Set Suite Variable      ${MME_ip_addr}          ${MME_ip_addr}

Check for No reboot
	${stdout}=      Run     ping -c 50 192.168.255.129
    Should contain  ${stdout}  50 packets transmitted, 50 received

modify NWSLICE SGW and verify iptables
    Perform Recommissioning     type=param  param_path=NWSLICE-0:sgwIpAddress    operation=update    value=fc00::21     timeout=300
    Set List Value      ${NWSLICE_SGW}      0        fc00::21
    Check ip tables with dynamic firewall           True

Check ip tables with dynamic firewall
	[Arguments]			${status}
	Execute command on ENodeB          /opt/trs/bin/vtc l4clfr ipv4 show
	${ipv4_uplane}=		Set Variable	${stdout}
	Execute command on ENodeB          /opt/trs/bin/vtc l4clfr ipv6 show
	${ipv6_uplane}=		Set Variable	${stdout}
    Should Match Regexp             ${ipv6_uplane}       from\\s*<TRSW_65>
    ...     ${GTP_Sgw_ip_addr}[0]</TRSW_65>/128\\s*to\\s*<TRSW_65>${uplane1_ipv6}</TRSW_65>/128\\s*proto\\s*17\\s*dport\\s*2152\\s*action\\s*luplane
    Should Match Regexp             ${ipv6_uplane}       from\\s*<TRSW_65>
    ...     ${NWSLICE_SGW}[0]</TRSW_65>/128\\s*to\\s*<TRSW_65>${NW_SLICE_ip}[0]</TRSW_65>/128\\s*proto\\s*17\\s*dport\\s*2152\\s*action\\s*luplane

	Run Keyword IF 		'${status}'=='False'	Should Not Match Regexp         	${ipv4_uplane}    	proto\\s*17\\s*dport\\s*2152\\s*action\\s*drop
	... 		ELSE							Should Match Regexp					${ipv4_uplane}    	proto\\s*17\\s*dport\\s*2152\\s*action\\s*drop

	Run Keyword IF 		'${status}'=='False'	Should Not Match Regexp         ${ipv6_uplane}    	proto\\s*17\\s*dport\\s*2152\\s*action\\s*drop
	... 		ELSE							Should Match Regexp				${ipv6_uplane}    	proto\\s*17\\s*dport\\s*2152\\s*action\\s*drop
Perform call with default qci
    Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=ue_attach id=1 cell=11    timeout=60  #4g call
    Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=trf_data_start ue=1 id=2 dir=ul trf_id=3 mbps=1    timeout=60
	Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=ue_attach id=2    timeout=60
	Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=ue_measurement_send id=2 phycell_id=50 nrsrp=127 event=B1_NR    timeout=60
	Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=trf_data_start ue=2 id=2 dir=ul trf_id=3 mbps=1    timeout=60
	Check wireshark for default qci
Perform SLice specific call
	For 		${i}		IN RANGE		3		5		2
			Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=ue_attach id=${i}    timeout=60  #4g call
			Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data
            ...     command=bearer_add ue=${i} id=3 filter=4 precedence=4 proto=17 filter=5 precedence=5 proto=17    timeout=60  #4g call
			Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=trf_data_start ue=${i} id=3 dir=ul trf_id=3 mbps=1    timeout=60
    END
	For 		${i}		IN RANGE		4		5		2
			Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=ue_attach id=${i}    timeout=60
			Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=bearer_add ue=${i} id=3 filter=4 precedence=4 proto=17
            ...      filter=5 precedence=5 proto=17    timeout=60  #4g call
			Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=ue_measurement_send id=${i} phycell_id=50 nrsrp=127
            ...      event=B1_NR		timeout=60
            Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=bearer_ue_param ue=${i} id=3 scg_ul_dist_percent=100
			Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=trf_data_start ue=${i} id=3 dir=ul trf_id=3 mbps=1    timeout=60
    END

Detach Slice calls
	[Arguments]			${range}
	FOR			${i}		IN RANGE		3		${range}
		Configure UE        lte=CB006450_IPv6_single_operaror_cfg:data  command=ue_detach id=${i}    timeout=60
    END
Wireshark check
	[Arguments]			${uplane}			${pdn}				${Wireshark_file} 		${analysis}
	Set Suite Variable          ${uplane_addr}          ${uplane}
	Set Suite Variable			${PDN_IP}				${pdn}
    Analyse Pcap        pcap_filename=${Wireshark_file}            analysis=${analysis}     filter_file_name=${pcap_file}

Check wireshark for Slice Traffic when Flag enabled
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
	sleep		60
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	Wireshark check			fc00::3:23			4.7.254.210		${Wireshark_file}		Traffic_check_IPV6
	Wireshark check			fc00::3:27			4.7.254.211		${Wireshark_file}		Traffic_check_IPV6
