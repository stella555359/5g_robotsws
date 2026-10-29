***Settings ***
Documentation
    ...     [Procedure]             "CB007158_5G_C_Dual_u_planewithDualstackconfigurationfor_SA_NSA_ransharing_with_QOS_and_Dynamic_Firewall.robot"
    ...     [Date]                  "08-06-2022"
	...		[SCF]					"CB007158_SCF_dual_U_plane_dual_stack_ransharing_SA_NSA_concurent.xml"
    ...     [Author]                "Monika Parasar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB007158"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "ASOE_10.45.141.214"

#Force Tags          CA_E2ET_BTSTRSPZ        SBTS00        [SBTS23R1]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_ET        CRT

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup      Setup Oamops
Suite Teardown   Teardown Oamops
#Suite Setup             Run Keywords    Pre-conditions for testsuite
#Suite Teardown     Run Keywords         Post-conditions for testteardown





*** Test Cases ***

[1]CB007158_5G_C Dual u plane with Dual stack configuration for SA_NSA ransharing with QOS and Dynamic_Firewall

    Precondition
    Call Setup  5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data    parallel=${False}    verify_attach=${False}       attach=${False}
    Get IP Address
    Bring up x2 link for all operator
    Verify Bts Status
    sleep       120
	Check for No reboot
	Verify Bts Status
    Configure UE        5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=ue_change_location     id=13    enb=9   cell=1
    Configure UE        5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=ue_change_location     id=14    enb=9   cell=1
	Perform NSA Call		14		1		311:491
	Check wireshark for Shaping	${NSA_Uplane1_ip}[2]	${NSA_Uplane2_ip}[2]	1	  2000		Data_Traffic_check	ip.src
    Perform NSA call detach     14
    sleep       5
    Perform NSA Call		14		1		311:491
	Check wireshark for Shaping	${NSA_Uplane1_ip}[2]	${NSA_Uplane2_ip}[2]	2	  2000      Data_Traffic_check      ip.src
    Perform NSA call detach     14
#	Perform SA Call			1		1
#	Check wireshark for Shaping	${SA_UPlane1_ipv6}[0]	${SA_UPlane2_ipv6}[0]	1	5000	Data_Traffic_check_v6	ipv6.src
#	Deregister UE			1
#	Perform SA Call			1		1
#	Check wireshark for Shaping	${SA_UPlane1_ipv6}[0]	${SA_UPlane2_ipv6}[0]	2	5000	Data_Traffic_check_v6   ipv6.src
#	Deregister UE		1
	Perform SA Call		2	2
	Check wireshark for Shaping	${SA_UPlane1_ipv6}[1]	${SA_UPlane2_ipv6}[1]	1	3000	Data_Traffic_check_v6	ipv6.src
	Deregister UE		2
	Perform SA Call		2	2
	Check wireshark for Shaping	${SA_UPlane1_ipv6}[1]	${SA_UPlane2_ipv6}[1]	2	3000	Data_Traffic_check_v6	ipv6.src
	Deregister UE			2
#    	Run Keyword And Expect Error  *Assertion not met: NRBTS.s1Uplane(ipV6AddressDN2 defined) have ipV6AddressDN1 defined and
#	...	ipV6AddressDN1 <> ipV6AddressDN2*    Perform Recommissioning     type=delta        delta_file=${modify_uplaneip_DN}
#	...	skip_parameter_relation_errors=${False}      timeout=300
# 	uncomment above run keyword
#    [Teardown]      Run keyword at the end

***Keywords***

Precondition
    Run     sudo killall egate edaemon
#	Perform Commissioning    	verify_bts_status=False        timeout=400
	${SGW_S11_ADDR}=                         Set Variable        131
    ${interface_adddress_last_octet}=           Set Variable        1
    ${interface_adddress_last_octet_IPv6}=      Set Variable        0X02
    ${vlan_ids}=                             Set Variable        1810
    FOR        ${i}        IN RANGE    0      24
    ${interface_adddress_last_octet_IPv6_hex}=      Evaluate        hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
    ${broadcast_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+2
    Run     sudo ip link add link eth3 name eth3.${vlan_ids} type vlan id ${vlan_ids}
    Run     sudo ip addr add 10.0.3.${interface_adddress_last_octet}/30 brd 10.0.3.${broadcast_adddress_last_octet} dev eth3.${vlan_ids}
    Run     sudo ip link set dev eth3.${vlan_ids} up
    Run     sudo ifconfig eth3.${vlan_ids} inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
    ${interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+4
    ${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
    ${vlan_ids}=            Evaluate            ${vlan_ids}+1
    END
    sleep       60
    FOR        ${i}        IN RANGE    20       26
    Run         sudo ip a a 10.0.1.${i}/24 dev eth3
    Run         sudo ip a a fc00::${i}/116 dev eth3
    END

    FOR        ${i}        IN RANGE    0        60
    Run         sudo ip a a 10.0.1.${SGW_S11_ADDR}/24 dev eth3
    Run         sudo ip a a fc00::${SGW_S11_ADDR}/116 dev eth3
    ${SGW_S11_ADDR}=        Evaluate            ${SGW_S11_ADDR}+1
    END

    Run         sudo ip a a fc00::1/116 dev eth3
    Run         sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 reboot
    Run         sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 reboot
	sleep		400


Run keyword at the end
    ${vlan_ids}=                             Set Variable        1810
    FOR        ${i}        IN RANGE    0      24
    Run     sudo ip link delete eth3.${vlan_ids}
    ${vlan_ids}=            Evaluate            ${vlan_ids}+1
    END

Bring up x2 link for all operator
    FOR         ${i}        IN RANGE        8       13
    Configure UE        5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=enb_x2_link_up  enb=${i}   target=2
    END

Modify FSTSCH and check that traffic shapping
    Perform Recommissioning     type=delta	delta_file=${modify_FSTSCH_SIR}        skip_parameter_relation_errors=${True}      timeout=300
    sleep       60
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    sleep       60
    ${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark       ${Wireshark_file}       ip.src==${NSA_Uplane1_ip}[2]         10000
    Verify Data Rate in wireshark       ${Wireshark_file}       ip.src==${NSA_Uplane2_ip}[2]         10000
    Verify Data Rate in wireshark       ${Wireshark_file}       ip.src==${NSA_Uplane1_ip}[0] or ip.src==${NSA_Uplane2_ip}[0]         10000

Perform SW upgrade
    ${active}       ${passive}=         Get Sw Version          timeout=30
    ${status}=  Run Keyword And Return Status       Should Contain      ${active}            SBTS22R3
    Run Keyword If      ${status}==True     Perform Software Download And Update    wft_profile=branch_SBTS22R3
    ...		package=auto    activate_sw=True    update_timeout=3800
    ...     ELSE	Perform Software Download And Update    wft_profile=sbtstrunk_00      package=auto    activate_sw=True
    ...		update_timeout=3800



Get IP Address
	@{NSA_Uplane1_ip}=				Create List
	@{SA_UPlane1_ip}=				Create List
    @{SA_UPlane1_ipv6}=             Create List
	@{NSA_Uplane2_ip}=				Create List
	@{SA_UPlane2_ip}=				Create List
    @{SA_UPlane2_ipv6}=             Create List
    @{amf_ip}=                      Create List

    FOR         ${i}        IN RANGE        1           7
    ${SERVEDAMF_ip}=          Get Parameter         param_path=SERVEDAMF-${i}:amfIPAddress
    Append To List          ${amf_ip}       ${SERVEDAMF_ip}
    END

	${UplaneIP}=     Get Parameter           param_path=NRBTS-1:ngUplane
	FOR     ${i}        IN RANGE      0     6
	${value}=           Get Dictionary Values      ${UplaneIP}[${i}]
	${UPlane1_ip}=      Get Parameter            param_path=${value}[0]:localIpAddr
	${UPlane2_ip}=      Get Parameter            param_path=${value}[1]:localIpAddr
	${UPlane1_ipv6}=      Get Parameter            param_path=${value}[2]:localIpAddr
	${UPlane2_ipv6}=      Get Parameter            param_path=${value}[3]:localIpAddr
	Append To List      ${SA_UPlane1_ip}          ${UPlane1_ip}
	Append To List      ${SA_UPlane2_ip}          ${UPlane2_ip}
	Append To List      ${SA_UPlane1_ipv6}          ${UPlane1_ipv6}
	Append To List      ${SA_UPlane2_ipv6}          ${UPlane2_ipv6}
	END

	${UplaneIP}=     Get Parameter           param_path=NRBTS-1:s1Uplane
	FOR     ${i}        IN RANGE      0     6
	${value}=           Get Dictionary Values      ${UplaneIP}[${i}]
	${UPlane1_ip}=      Get Parameter            param_path=${value}[0]:localIpAddr
	${UPlane2_ip}=      Get Parameter            param_path=${value}[1]:localIpAddr
	Append To List      ${NSA_Uplane1_ip}          ${UPlane1_ip}
	Append To List      ${NSA_Uplane2_ip}          ${UPlane2_ip}
	END
	Set Suite Variable      @{SA_UPlane1_ip}         	@{SA_UPlane1_ip}
	Set Suite Variable      @{SA_UPlane2_ip}         	@{SA_UPlane2_ip}
	Set Suite Variable      @{SA_UPlane1_ipv6}            @{SA_UPlane1_ipv6}
	Set Suite Variable      @{SA_UPlane2_ipv6}            @{SA_UPlane2_ipv6}
	Set Suite Variable      @{NSA_Uplane1_ip}         	@{NSA_Uplane1_ip}
	Set Suite Variable      @{NSA_Uplane2_ip}         	@{NSA_Uplane2_ip}
	Set Suite Variable      @{amf_ip}           @{amf_ip}

Check for No reboot
	${stdout}=      Run     ping -c 50 192.168.255.129
    Should contain  ${stdout}  50 packets transmitted, 50 received


Perform NSA Call
	[Arguments]				${ue_id}		${sgw_id}		${plmn}
	Configure UE        5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=ue_mme_param     id=${ue_id}    sgw_id=${sgw_id}
    sleep       5
    Configure UE        5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=ue_sgw_param     id=${ue_id}     s1u_preferred_ip_ver=v4
    sleep       5
    Configure UE        5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=ue_attach        id=${ue_id}        selected_plmn=${plmn}
    sleep       5
	Configure UE        5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=enb_ue_dc_start  ue=${ue_id}  target_gnb=2
	...	target_cells=1  bearer=2  type=split_scg
    sleep       5
	Configure UE        5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=trf_data_start   ue=${ue_id}    id=2
	...	dir=ul  trf_id=3    mbps=10
    sleep       5

Perform SA Call
	[Arguments]				${ue_id}		${gw_id}
	Configure UE	5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=set_pdu_param    ue=${ue_id}     pdu=1   trf_type=internal
    sleep       5
	Configure UE    5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=ue_register  id=${ue_id}     profile=1
    sleep       5
	Configure UE    5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=ue_pdu_session_setup     pdu=1   ue=${ue_id}
    ...     nwslice=${gw_id}   gw=1
    sleep       5
	Configure UE    5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=trf_data_start   ue=${ue_id}     pdu=1   qfi=1
    ...   dir=ul  mbps=10
    sleep       5

Deregister UE
	[Arguments]				${ue_id}
    Configure UE    5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=ue_deregister    id=${ue_id}     ue_deregister_type=switch_off
    sleep       5

Perform NSA call detach
    [Arguments]             ${ue_id}
    Configure UE        5g=ASOE_CB007158_Dual_stack_multiple_operaror_cfg:data  command=ue_detach    id=${ue_id}
    sleep       5



Check wireshark for Shaping
	[Arguments]	${uplane1}	${uplane2}	${iteration}	${data_rate}	 ${wireshark_analysis}	${filter}
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
	sleep		10
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	${status}=	Run Keyword If		${iteration}==1		Run Keyword And Return Status 		Wireshark check
	...         ${uplane1}           ${Wireshark_file}       ${wireshark_analysis}
    Run Keyword If  ('${status}'=='True' and '${iteration}'=='1')     run keywords
	...		Set Suite Variable		${First_uplane}		${uplane1}
	...		AND			Set Suite Variable		${second_uplane}	${uplane2}
	Run Keyword If  ('${status}'=='False' and '${iteration}'=='1')		run keywords
        ... 	Set Suite Variable		${First_uplane}		${uplane2}
	...		AND			Set Suite Variable		${second_uplane}		${uplane1}
	Run Keyword If		${iteration}==1		Verify Data Rate in wireshark	${Wireshark_file}	${filter}==${First_uplane}
	...	${data_rate}
	...	ELSE	Verify Data Rate in wireshark		${Wireshark_file}	${filter}==${second_uplane}	${data_rate}

Check wireshark for Shaping for 0 data rate
    [Arguments]         ${uplane1}          ${uplane2}           ${wireshark_analysis}
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    sleep      5
    ${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
    ${status}=		 Run Keyword And Return Status           Wireshark check         ${uplane1}           ${Wireshark_file}
    ...       ${wireshark_analysis}
    Run Keyword If  '${status}'=='True'		Verify Data Rate in wireshark       ${Wireshark_file}
    ...		(ipv6.src==${uplane1}) && (gtp.message == 0xff)         0
    ${status}=		Run Keyword And Return Status           Wireshark check         ${uplane2}           ${Wireshark_file}       Traffic_check
    Run Keyword If  '${status}'=='True'                Verify Data Rate in wireshark       ${Wireshark_file}       (ipv6.src==${uplane2}) &&
    ...		(gtp.message == 0xff)         0

Verify Data Rate in wireshark
    [Arguments]         ${pcap_file}        ${filter}       ${expected_data_rate}
    Run  tshark -o esp.enable_encryption_decode:TRUE -r ${pcap_file} -Y "${filter}" -w ${EXECDIR}/ue_shaping 2>/dev/null
    ${data_rate}=  Run  capinfos ${EXECDIR}/ue_shaping -i | tail -1 | awk '{ print $4 }' | tr -dc '0-9'
    ${data_rate}=        Remove String       ${data_rate}     ,
    Set Suite Variable     ${data_rate}
    ${higher_limit}=        Evaluate        ${expected_data_rate}+300
    ${lower_limit}=         Evaluate            ${expected_data_rate}-300
    Should Be True      ${data_rate}>${lower_limit}
    Should Be True      ${data_rate}<${higher_limit}


Wireshark check
	[Arguments]			${uplane}	${Wireshark_file} 		${analysis}
	Set Suite Variable          ${uplane_addr}          ${uplane}
   Analyse Pcap        pcap_filename=${Wireshark_file}            analysis=${analysis}       filter_file_name=${pcap_file}
