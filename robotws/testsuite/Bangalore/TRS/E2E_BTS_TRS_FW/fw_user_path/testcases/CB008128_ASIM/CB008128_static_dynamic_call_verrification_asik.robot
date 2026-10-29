*** Settings ***
Documentation
    ...     [Procedure]             "CB008128_static_dynamic_call_verrification_asik"
    ...     [Date]                  "22-09-11"
    ...     [Author]                "adhn"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "ASIK_5g01"
    ...     [Config_File]           "Vlan_Ipv6.xml/CB008128_static_dynamic.xml"

Force Tags   			CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  	    CA_E2ET_BTSTRSPZ        SBTS00
...		[SBTS23R2] 	       QCD_MN_RAN        QCP_RAN_ET        CRT

Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup     Setup Oamops
Suite Teardown     Teardown Oamops



*** Test Cases ***
[1]CB008128_static_dynamic_call_verrification_asik


	Copy the Files from Rotta
	Bring UP interfaces on VM
    Install DNS package			${ipv6_zone_file}			fwd.olympians.nsn.com.db
    Perform Commissioning with static to Dynamic ip configuration
	Certificate Configure    operation=install_certificate    cert_file=${Ipsec_Cert_file}
	...     cert_type=BtsTrustChain         cert_format=P12         password=${Ipsec_Cert_password}
	sleep		60
	IPSEC Configuration for Strongswan
	Verify Ipsec Tunnels Status
	Call Setup  5g=CB008128_IPV6_2op_cfg:data   parallel=${False}    verify_attach=${False}       attach=${False}
    Configure UE        5g=CB008128_IPV6_2op_cfg:data  command=enb_x2_link_up  enb=5   target=2
    sleep       120
	Verify Bts Status
    Verify AMF status
	Attach call				CB008128_IPV6_2op_cfg
	Verify Calls		fc00::3:3			2c00::3:7           pointA
	Detach call				CB008128_IPV6_2op_cfg
    Call Teardown           5g=CB008128_IPV6_2op_cfg:data
    Run         sudo killall egate edaemon
    Perform FQDN switchover
    sleep       180
	Create cfg file with new ip
    Call Setup  5g=CB008128_IPV6_2op_After_switchover_cfg:data   parallel=${False}    verify_attach=${False}
    ...     attach=${False}
    sleep       60
    Configure UE        5g=CB008128_IPV6_2op_After_switchover_cfg:data  command=enb_x2_link_up  enb=5   target=2
    Verify AMF status
	Attach call			CB008128_IPV6_2op_After_switchover_cfg
	Verify Calls		fc00::3:3			2c00::3:5           after_switchover
	Detach call			CB008128_IPV6_2op_After_switchover_cfg

***Keywords***
Copy the Files from Rotta
    Run     wget -O ${luapath}/acceNB_4K3_004-cert.p12 ${Rotta_link}/acceNB_4K3_004-cert.p12
    Run     wget -O ${luapath}/fwd.ipv6olympians.nsn.com.db ${Rotta_link}/fwd.ipv6olympians.nsn.com.db
    Run     wget -O ${luapath}/fwd.olympians.nsn.com.db ${Rotta_link}/fwd.olympians.nsn.com.db
    Run     wget -O ${luapath}/named.conf.local ${Rotta_link}/named.conf.local

Perform Commissioning with static to Dynamic ip configuration
    ${VLAN_ID}=          Get Parameter           param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1:vlanId
	Run			sed -i 's/{{VLANID}}/${VLAN_ID}/g' ${SCF_ASIM_ipv6_plain}
	Perform Commissioning       scf_file=${SCF_ASIM_ipv6_plain}       verify_bts_status=False
    sleep       300
    Perform Recommissioning     type=delta        delta_file=8128_ASIM_non_main_operator_ipv6.xml
    ...     skip_parameter_relation_errors=${True}      timeout=300
    sleep       1000

Create cfg file with new ip
	Run			cp ${CB008128_IPV6_2op} ${CB008128_IPV6_2op_After_switchover}
	Run			sed -i "s/2c00::3:7/2c00::3:5/g" ${CB008128_IPV6_2op_After_switchover}

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
			Append To List      ${application_ip}          ${interface_adddress_last_octet_IPv6_hex}
			Run		sudo ifconfig eth3 inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
	       ${interface_adddress_last_octet_IPv6}=          Evaluate
	       ...     hex(${interface_adddress_last_octet_IPv6}+4)
	END
	Run		sudo ifconfig eth3 inet6 add fc00::20/116
	Run		sudo ifconfig eth3 inet6 add fc00::21/116
	Run		sudo ifconfig eth3 inet6 add fc00::121/116
	Run		sudo ifconfig eth3 inet6 add fc00::122/116
	Run		sudo ifconfig eth3 inet6 add fc00::1/116
    Run     sudo ifconfig eth3 inet6 add fc00::12/116
    Run     sudo ifconfig eth3 inet6 add fc00::13/116
    Run		sudo ip a a 10.0.1.121/24 dev eth3
	Run		sudo ip a a 10.0.1.12/24 dev eth3
	Run		sudo ip a a 10.0.1.13/24 dev eth3
	Run		sudo ip a a 10.0.1.20/24 dev eth3
    sleep       60

	Set Suite Variable			@{interface_ip}		    @{interface_ip}
	Set Suite Variable			@{application_ip}		@{application_ip}

Perform FQDN switchover
    Run				sudo ifconfig eth3 inet6 del fc00::3:6/126
    Run				sudo ifconfig eth3 inet6 add fc00::3:5/126
    Run             sudo ipsec restart
    sleep           60
    Verify Ipsec Tunnels Status

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
               ${parent_tunnel_stateInfo}=     Get From Dictionary             dictionary=${ike_tunnel}
               ...        key=stateInfo
               ${parent_tunnel_proceduralState}=       Get From Dictionary
               ...     dictionary=${parent_tunnel_stateInfo}           key=proceduralState
               Should Be True  '${parent_tunnel_proceduralState}'=='Established'
        END

        @{child_tunnel_moc_list} =      Query Admin Infomodel           query=get list ${ipsec_sa_l_moc_path}
        FOR    ${child_tunnel}     IN      @{child_tunnel_moc_list}
               ${child_tunnel_stateInfo}=      Get From Dictionary             dictionary=${child_tunnel}
               ...     key=stateInfo
               ${child_tunnel_proceduralState}=        Get From Dictionary
               ...     dictionary=${child_tunnel_stateInfo}            key=proceduralState
               Should Be True  '${child_tunnel_proceduralState}'=='Installed'
        END



Attach call
	[Arguments]			${cfg_file}
	Configure UE        5g=${cfg_file}:data  command=ue_attach   id=11  selected_plmn=311:489
    Configure UE        5g=${cfg_file}:data
    ...     command=enb_ue_dc_start  ue=11  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE        5g=${cfg_file}:data  command=trf_data_start  ue=11  id=2  dir=ul  trf_id=3  mbps=1
    Configure UE        5g=${cfg_file}:data  command=ue_change_location     id=12    enb=5   cell=1
    Configure UE        5g=${cfg_file}:data  command=ue_attach   id=12  selected_plmn=311:490
    Configure UE        5g=${cfg_file}:data
    ...         command=enb_ue_dc_start  ue=12  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE        5g=${cfg_file}:data  command=trf_data_start  ue=12  id=2  dir=ul  trf_id=3  mbps=1


Detach call
	[Arguments]			${cfg_file}
	Configure UE        5g=${cfg_file}:data  command=ue_detach   id=11
    Configure UE        5g=${cfg_file}:data  command=ue_detach   id=12

Wireshark check
    [Arguments]         ${uplane}           ${pdn}              ${Wireshark_file}       ${analysis}
    Set Suite Variable          ${uplane_addr}          ${uplane}
    Set Suite Variable          ${PDN_IP}               ${pdn}
    Analyse Pcap        pcap_filename=${Wireshark_file}            analysis=${analysis}
    ...     filter_file_name=${pcap_file}

Extract The traffic capture file
    [Arguments]         ${Wireshark_file}           ${alias}
    Run         mv ${Wireshark_file} execution_logs/${alias}_1.pcap.gz.enc
    ${command}=     Catenate        openssl aes-128-cbc -d -a -in execution_logs/${alias}_1.pcap.gz.enc -out
    ...     execution_logs/${alias}_1.pcap.gz -k ${file_password}
    Run          ${command}
    Run         gunzip execution_logs/${alias}_1.pcap.gz
    RETURN            execution_logs/${alias}_1.pcap


Verify Calls
	[Arguments]				${s1uplane}				${s1uplane_op2}             ${alias}
    Traffic Capture Start        capture_device=oam_device    mode=file             measurement_point=NE_Terminated
    ...         uplane_capturing=True            password=${file_password}      timeout=120           alias=${alias}
	sleep		60
    ${Wireshark_file}=   Traffic Capture Stop   mode=file    timeout=120        alias=${alias}
    ${Wireshark_file}=    Extract The traffic capture file        ${Wireshark_file}     ${alias}
	Wireshark check			${s1uplane}			    4.7.254.208			${Wireshark_file}		Traffic_check_IPV6
    Wireshark check         ${s1uplane_op2}             4.7.254.209         ${Wireshark_file}       Traffic_check_IPV6
