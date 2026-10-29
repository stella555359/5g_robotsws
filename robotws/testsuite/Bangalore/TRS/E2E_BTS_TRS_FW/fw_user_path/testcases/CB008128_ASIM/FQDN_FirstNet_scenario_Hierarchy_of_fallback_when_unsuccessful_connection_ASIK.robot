***Settings ***
Documentation
    ...     [Procedure]             "CB008128_static_dynamic_call_verrification_asik"
    ...     [Date]                  "22-10-22"
    ...     [Author]                "Monika Parasar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD"

Force Tags     	    CA_E2ET_BTSTRSPZ        SBTS00        [SBTS22R2] 	       QCD_MN_RAN        QCP_RAN_VRF        CRT

Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Pre-conditions for testsuite
Suite Teardown     Post-conditions for testteardown


#Suite Setup         Setup Oamops
#Suite Teardown     Teardown Oamops



*** Test Cases ***
[1][1.0] The purpose of this test case is to verify that the Security Gateway CM commissioning with FQDN - FirstNet scenario Hierarchy
# of fallback when unsuccessful connection

    Precondition
	Bring UP interfaces on VM
#	Install DNS package			${ipv6_zone_file}			fwd.olympians.nsn.com.db
#    Sleep       300
    Run     sudo systemctl restart bind9
    Run     sudo systemctl enable bind9
    Run     sudo systemctl status bind9
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Perform Recommissioning     type=delta        delta_file=8128_ipv6_tunnels_with_ikep_fqdn_ASIK.xml
    ...        skip_parameter_relation_errors=${True}      timeout=300
    sleep       100
    Wait Until Keyword Succeeds     3 minute     60 s       Get IP address
#a	Certificate Configure    operation=install_certificate    cert_file=${Ipsec_Cert_file}
#a	...     cert_type=BtsTrustChain         cert_format=P12         password=${Ipsec_Cert_password}
    Perform Recommissioning    type=delta   type=delta    delta_file=CMP_RSA_static.xml    timeout=100
    Sleep    30
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=RSA       timeout=600
	sleep		60
	IPSEC Configuration for Strongswan
#	Enable IPsec
	sleep		100
	Verify Ipsec Tunnels Status
    Verify Alarm    faultid=61654
    Verify Alarm    faultid=61030       should_exist=${False}
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	Verify wireshark for FQDN Hierarchy			${Wireshark_file}
#a	Call Setup  5g=CB008128_IPV6_2op_cfg:data   parallel=${False}    verify_attach=${False}       attach=${False}
#a	Verify Bts Status
#a    Verify AMF status
    Validate mplane login
#a	Attach call
    Run     ping 2c00::3:3 >ping.txt & echo $! > pid.txt
	Enable DPD optimisation
    Verify Alarm    faultid=6450     should_exist=${False}
	Verify No isakmp messages
    Run     for pid in $(ps -ef | grep ping | awk '{print $2}'); do kill -9 $pid; done
#a	Configure UE        5g=CB008128_IPV6_2op_cfg:data  command=ue_detach   id=11
	Verify isakmp messages
	Disable DPD optimisation
    Verify Alarm    faultid=6450     should_exist=${False}
	Verify isakmp messages
#a	Attach call
	sleep		30
	Verify isakmp messages
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=reset_eth3_pcap
    Perform reset BTS
    Verify Alarm    faultid=6450     should_exist=${False}
    ${Wireshark_file}=       Traffic Capture Stop        alias=reset_eth3_pcap
    Verify wireshark for FQDN Hierarchy         ${Wireshark_file}
    Validate mplane login
    Perform Recommissioning     type=delta        delta_file=online_mplane_modification.xml
    ...        skip_parameter_relation_errors=${True}      timeout=300
    sleep       120
	Disable IPsec
	Enable Mplane DNS Source IP
    Get IP address
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
	Enable IPsec
	sleep		120
	Verify Ipsec Tunnels Status
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	Verify wireshark for FQDN Hierarchy with Mplane			${Wireshark_file}
	Disable IPsec
    Enable LTEP DNS Source IP
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
	Enable IPsec
	sleep		120
	Verify Ipsec Tunnels Status
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	Verify wireshark for FQDN Hierarchy			${Wireshark_file}

***Keywords***
Precondition
#    Run     cp ${luapath}/fwd.ipv6olympians.nsn.com.txt ${luapath}/fwd.ipv6olympians.nsn.com.db
#    Run     cp ${luapath}/fwd.olympians.nsn.com.txt ${luapath}/fwd.olympians.nsn.com.db
#    Run     cp ${luapath}/named.conf.txt ${luapath}/named.conf.local
#    Run     cp ${resource_path}/acceNB_4K3_004-cert.p12 ${luapath}/acceNB_4K3_004-cert.p12
#	Run     cp ${fw_resource_path}/rise.csv ${luapath}/rise.csv
    Run     sudo cp ${CURDIR}/resources/fwd.olympians.nsn.com.db /etc/bind/fwd.olympians.nsn.com.db

Perform reset BTS
    Reset Bts            should_be_onair=${False}
    sleep       300
    Run         sudo ipsec restart
    sleep       300
    Verify Ipsec Tunnels Status
    Verify Alarm    faultid=61654
    Verify Alarm    faultid=61030       should_exist=${False}

Validate mplane login
    setup oamops    bts_host=2c00::3:3      alias=mplane_mplane_login
    sleep   30
    Teardown Oamops          alias=mplane_mplane_login


Perform IPv6 Dynamic IP configuration
	${VLAN_ID}=          Get Parameter           param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1:vlanId
	Run			sed -i 's/{{VLANID}}/${VLAN_ID}/g' ${SCF_CB008128_ASIM_ipv6}
    Perform Commissioning       scf_file=${SCF_CB008128_ASIM_ipv6}       verify_bts_status=False


Get IP address
	@{FQDN_name}=         Create List
	@{local_tunnel_ip_list}=         Create List
	${primary_DNS_IP} =        Get Parameter           param_path=DNS-1:serverIpAddressPrimary
    ${secondary_DNS_IP} =        Get Parameter           param_path=DNS-1:serverIpAddressSecondary
	FOR	${i}		IN RANGE		1		9
			${FQDN}=           Run Keyword IF		${i}<3		Get Parameter
	...     param_path=IKEP-${i}:remoteTunnelEndpoint2
	...		ELSE				Get Parameter           param_path=IKEP-${i}:remoteTunnelEndpoint
			Append To List      ${FQDN_name}          ${FQDN}
			${local_ip}=			  Get Parameter           param_path=IKEP-${i}:localTunnelEndpointDN:localIpAddr
			Append To List      ${local_tunnel_ip_list}          ${local_ip}
    END
    ${invalid_FQDN}=            Get Parameter           param_path=IKEP-1:remoteTunnelEndpoint
	${Wrong_IP_FQDN}=            Get Parameter           param_path=IKEP-2:remoteTunnelEndpoint
	${mplane_ip}=            Get Parameter           param_path=MPLANENW-1:mPlaneIpv6AddressDN:localIpAddr

	Set Suite Variable			@{FQDN_name}				@{FQDN_name}
	Set Suite Variable			@{local_tunnel_ip_list}		@{local_tunnel_ip_list}
	Set Suite Variable			${primary_DNS_IP}			${primary_DNS_IP}
	Set Suite Variable			${secondary_DNS_IP}			${secondary_DNS_IP}
	Set Suite Variable			${invalid_FQDN}				${invalid_FQDN}
	Set Suite Variable			${Wrong_IP_FQDN}			${Wrong_IP_FQDN}
	Set Suite Variable			${mplane_ip}				${mplane_ip}

Bring UP interfaces on VM
	@{interface_ip}=			 Create List
	@{application_ip}=			 Create List

	FOR 		${i}		IN RANGE		1		10
    		Run     sudo ip a a 10.0.1.13${i}/24 dev eth3
			Run     sudo ip a a 10.0.1.14${i}/24 dev eth3
			Run		sudo ifconfig eth3 inet6 add fc00::13${i}/116
			Run		sudo ifconfig eth3 inet6 add fc00::14${i}/116
    END
	${interface_adddress_last_octet_IPv6}=      Set Variable        0X02
	FOR 		${i} 		IN RANGE		0		8
			${interface_adddress_last_octet_IPv6_hex}=      Evaluate
	...     hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
			Append To List      ${interface_ip}          ${interface_adddress_last_octet_IPv6_hex}
	        ${application_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+1)
            ${application_last_octet_IPv6_hex}=      Evaluate        hex(${application_last_octet_IPv6}).lstrip("0x")
			Append To List      ${application_ip}          ${application_last_octet_IPv6_hex}
			Run		sudo ifconfig eth3 inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
    	    ${command}=     Catenate        sudo ip -6 route add 2c00::3:${application_last_octet_IPv6_hex} via
    ...     fc00::3:${application_last_octet_IPv6_hex}
            Run        ${command}
	        ${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
    END
	Run		sudo ifconfig eth3 inet6 add fc00::20/116
	Run		sudo ifconfig eth3 inet6 add fc00::21/116
	Run		sudo ifconfig eth3 inet6 add fc00::121/116
	Run		sudo ifconfig eth3 inet6 add fc00::122/116
	Run		sudo ifconfig eth3 inet6 add fc00::1/116
   	Run		sudo ifconfig eth3 inet6 add fc00::12/116
	Run		sudo ifconfig eth3 inet6 add fc00::13/116
    Run		sudo ip a a 10.0.1.121/24 dev eth3
	Run		sudo ip a a 10.0.1.12/24 dev eth3
	Run		sudo ip a a 10.0.1.13/24 dev eth3
	Run		sudo ip a a 10.0.1.20/24 dev eth3
    sleep       60

	Set Suite Variable			@{interface_ip}		    @{interface_ip}
	Set Suite Variable			@{application_ip}		@{application_ip}

Enable IPsec
	Perform Recommissioning     type=param     param_path=IPSECC-1:ipSecEnabled   operation=update
	...     value=true      timeout=300
	sleep		120

Disable IPsec
	Perform Recommissioning     type=param     param_path=IPSECC-1:ipSecEnabled   operation=update
	...     value=false      timeout=300
	sleep		120

Enable Mplane DNS Source IP
	Perform Recommissioning     type=param     param_path=IPSECC-1:dnsSrcIpSelection   operation=update
	...     value=Mplane      timeout=300
    Run     sudo ipsec restart
	sleep		120

Enable LTEP DNS Source IP
	Perform Recommissioning     type=param     param_path=IPSECC-1:dnsSrcIpSelection   operation=update
	...     value=LTEP      timeout=300
    Run     sudo ipsec restart
	sleep		120

Enable DPD optimisation
	Perform Recommissioning     type=param     param_path=IPSECC-1:dpdOptimisationEnabled
	...     operation=update    value=true      timeout=300
    Run     sudo ipsec restart
	sleep		120

Disable DPD optimisation
	Perform Recommissioning     type=param     param_path=IPSECC-1:dpdOptimisationEnabled
	...     operation=update    value=false      timeout=300
    Run     sudo ipsec restart
	sleep		120

Verify AMF status
    ${AMF1_status}=      Get Parameter      param_path=MRBTS-1/NRBTS-1/SERVEDAMF-1:guAMI:guamiStatus
    ${AMF2_status}=      Get Parameter      param_path=MRBTS-1/NRBTS-1/SERVEDAMF-2:guAMI:guamiStatus
    Should Be Equal     ${AMF1_status}     available
    Should Be Equal     ${AMF2_status}     available

IPSEC Configuration for Strongswan
	Run			sudo cp /etc/ipsec.conf /etc/ipsec_bkup.conf
	Run			sudo cp ${IPSEC_plain_conf} /etc/ipsec.conf
	Run 		sudo ipsec restart
	sleep		120

Verify Ipsec Tunnels Status
        @{parent_tunnel_moc_list} =     Query Admin Infomodel           query=get list ${ike_sa_l_moc_path}
        FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
               ${parent_tunnel_stateInfo}=     Get From Dictionary     dictionary=${ike_tunnel}        key=stateInfo
               ${parent_tunnel_proceduralState}=       Get From Dictionary             dictionary=${parent_tunnel_stateInfo}
			   ...		key=proceduralState
               Should Be True  '${parent_tunnel_proceduralState}'=='Established'
        END

        @{child_tunnel_moc_list} =      Query Admin Infomodel           query=get list ${ipsec_sa_l_moc_path}
        FOR    ${child_tunnel}     IN      @{child_tunnel_moc_list}
               ${child_tunnel_stateInfo}=      Get From Dictionary             dictionary=${child_tunnel}     key=stateInfo
               ${child_tunnel_proceduralState}=        Get From Dictionary       dictionary=${child_tunnel_stateInfo}
			   ...		key=proceduralState
               Should Be True  '${child_tunnel_proceduralState}'=='Installed'
        END

Verify wireshark for FQDN Hierarchy
	[Arguments]			${Wireshark_file}
	FOR 		${i}		IN RANGE			0		8
				Wireshark check     ${FQDN_name}[${i}]		${local_tunnel_ip_list}[${i}]		${secondary_DNS_IP}
	...         fc00::3:${interface_ip}[${i}]			4c00::3:${interface_ip}[${i}] 		${Wireshark_file}
	...         DNS_query
				Wireshark check			${FQDN_name}[${i}]		${local_tunnel_ip_list}[${i}]		${secondary_DNS_IP}
	...         fc00::3:${interface_ip}[${i}]			4c00::3:${interface_ip}[${i}]  		${Wireshark_file}
	...         DNS_response
    END

    FOR        ${i}        IN RANGE            0       2
				Wireshark check			${FQDN_name}[${i}]		${local_tunnel_ip_list}[${i}]		${primary_DNS_IP}
	...         fc00::3:${interface_ip}[${i}]			4c00::3:${interface_ip}[${i}]  		${Wireshark_file}
	...         DNS_query
				Wireshark check			${FQDN_name}[${i}]		${local_tunnel_ip_list}[${i}]		${primary_DNS_IP}
	...         fc00::3:${interface_ip}[${i}]			4c00::3:${interface_ip}[${i}]  		${Wireshark_file}
	...         no_DNS_response
    END

	Wireshark check					${invalid_FQDN}		${local_tunnel_ip_list}[0]		${secondary_DNS_IP}
	...     fc00::3:${interface_ip}[0]			4c00::3:${interface_ip}[0]  		${Wireshark_file}		DNS_query
	Wireshark check					${invalid_FQDN}		${local_tunnel_ip_list}[0]		${secondary_DNS_IP}
	...     fc00::3:${interface_ip}[0]			4c00::3:${interface_ip}[0]  		${Wireshark_file}
	...     invalid_fqdn_response
	Wireshark check					${invalid_FQDN}		${local_tunnel_ip_list}[0]		${primary_DNS_IP}
	...     fc00::3:${interface_ip}[0]			4c00::3:${interface_ip}[0]  		${Wireshark_file}		DNS_query
	Wireshark check					${invalid_FQDN}		${local_tunnel_ip_list}[0]		${primary_DNS_IP}
	...     fc00::3:${interface_ip}[0]			4c00::3:${interface_ip}[0]  		${Wireshark_file}
	...     no_DNS_response


	Wireshark check					${Wrong_IP_FQDN}		${local_tunnel_ip_list}[1]		${secondary_DNS_IP}
	...     3c00::3:2			3c00::3:3  		${Wireshark_file}		DNS_query
	Wireshark check					${Wrong_IP_FQDN}		${local_tunnel_ip_list}[1]		${secondary_DNS_IP}
	...     3c00::3:2			3c00::3:3  		${Wireshark_file}		DNS_response
	Wireshark check					${Wrong_IP_FQDN}		${local_tunnel_ip_list}[1]		${primary_DNS_IP}
	...     3c00::3:2			3c00::3:3  		${Wireshark_file}		DNS_query
	Wireshark check					${Wrong_IP_FQDN}		${local_tunnel_ip_list}[1]		${primary_DNS_IP}
	...     3c00::3:2			3c00::3:3  		${Wireshark_file}		no_DNS_response


Verify wireshark for FQDN Hierarchy with Mplane
	[Arguments]			${Wireshark_file}
	FOR 		${i}		IN RANGE			0		8
				Wireshark check			${FQDN_name}[${i}]		${mplane_ip}		${secondary_DNS_IP}
	...     fc00::3:${interface_ip}[${i}]			4c00::3:${interface_ip}[${i}] 		${Wireshark_file}
	...     DNS_query
				Wireshark check			${FQDN_name}[${i}]		${mplane_ip}		${secondary_DNS_IP}
	...     fc00::3:${interface_ip}[${i}]			4c00::3:${interface_ip}[${i}]  		${Wireshark_file}
	...     DNS_response
    END

    FOR        ${i}        IN RANGE            0       2
				Wireshark check			${FQDN_name}[${i}]		${mplane_ip}		${primary_DNS_IP}
	...     fc00::3:${interface_ip}[${i}]			4c00::3:${interface_ip}[${i}]  		${Wireshark_file}
	...     DNS_query
				Wireshark check			${FQDN_name}[${i}]		${mplane_ip}		${primary_DNS_IP}
	...     fc00::3:${interface_ip}[${i}]			4c00::3:${interface_ip}[${i}]  		${Wireshark_file}
	...     no_DNS_response
    END

	Wireshark check					${invalid_FQDN}		${mplane_ip}		${secondary_DNS_IP}
	...     fc00::3:${interface_ip}[0]			4c00::3:${interface_ip}[0]  		${Wireshark_file}		DNS_query
	Wireshark check					${invalid_FQDN}		${mplane_ip}		${secondary_DNS_IP}
	...     fc00::3:${interface_ip}[0]			4c00::3:${interface_ip}[0]  		${Wireshark_file}
	...     invalid_fqdn_response
	Wireshark check					${invalid_FQDN}		${mplane_ip}		${primary_DNS_IP}
	...     fc00::3:${interface_ip}[0]			4c00::3:${interface_ip}[0]  		${Wireshark_file}		DNS_query
	Wireshark check					${invalid_FQDN}		${mplane_ip}		${primary_DNS_IP}
	...     fc00::3:${interface_ip}[0]			4c00::3:${interface_ip}[0]  		${Wireshark_file}
	...     no_DNS_response


	Wireshark check					${Wrong_IP_FQDN}		${mplane_ip}		${secondary_DNS_IP}			3c00::3:2
	...     3c00::3:3  		${Wireshark_file}		DNS_query
	Wireshark check					${Wrong_IP_FQDN}		${mplane_ip}		${secondary_DNS_IP}			3c00::3:2
	...     3c00::3:3  		${Wireshark_file}		DNS_response
	Wireshark check					${Wrong_IP_FQDN}		${mplane_ip}		${primary_DNS_IP}			3c00::3:2
	...     3c00::3:3  		${Wireshark_file}		DNS_query
	Wireshark check					${Wrong_IP_FQDN}		${mplane_ip}		${primary_DNS_IP}			3c00::3:2
	...     3c00::3:3  		${Wireshark_file}		no_DNS_response



Attach call
	Configure UE        5g=CB008128_IPV6_2op_cfg:data  command=ue_attach   id=11  selected_plmn=311:489
    Configure UE        5g=CB008128_IPV6_2op_cfg:data
    ...     command=enb_ue_dc_start  ue=11  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE        5g=CB008128_IPV6_2op_cfg:data  command=trf_data_start  ue=11  id=2  dir=dl  trf_id=3  mbps=1


Wireshark check
    [Arguments]     ${DNS_query_name}       ${local_tunnel_ip}      ${DNS_IP}   ${first_ip}     ${second_ip}
    ...     ${Wireshark_file}       ${analysis}
    Set Suite Variable          ${DNS_query_name}        ${DNS_query_name}
    Set Suite Variable          ${src_ip}          ${local_tunnel_ip}
	Set Suite Variable          ${dns_ip}                   ${DNS_IP}
	Set Suite Variable          ${first_ip}               ${first_ip}
	Set Suite Variable          ${second_ip}               ${second_ip}
	Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=${analysis}       filter_file_name=${pcap_file}


Wireshark check isakmp
    [Arguments]         ${local_tunnel_ip}           ${remote_tunnel_ip}              ${Wireshark_file}       ${analysis}
    Set Suite Variable          ${local_tunnel_ip}          ${local_tunnel_ip}
    Set Suite Variable          ${remote_tunnel_ip}               ${remote_tunnel_ip}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=${analysis}     filter_file_name=${pcap_file}



Verify isakmp messages
	Generate Esp Sa Key File                    wireshark_host=wireshark_host_local
	...     esp_sa_file=/home/ute/.config/wireshark/esp_sa
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
	sleep		60
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	FOR		${i}		IN RANGE		0			8
			Wireshark check isakmp				fc00::3:${application_ip}[${i}]
	...     fc00::3:${interface_ip}[${i}]		${Wireshark_file}		isakmp_check_IPV6
    END

Verify No isakmp messages
	Generate Esp Sa Key File                    wireshark_host=wireshark_host_local
	...     esp_sa_file=/home/ute/.config/wireshark/esp_sa
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
	sleep		60
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	Wireshark check isakmp				fc00::3:${application_ip}[0]			fc00::3:${interface_ip}[0]
	...     ${Wireshark_file}		no_isakmp_check_IPV6
	FOR		${i}		IN RANGE		1			8
			Wireshark check isakmp				fc00::3:${application_ip}[${i}]			fc00::3:${interface_ip}[${i}]
	...     ${Wireshark_file}		isakmp_check_IPV6
    END