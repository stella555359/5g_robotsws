***Settings ***
Documentation
    ...     [Procedure]             "CB008128_The_purpose_of_this_test_case_is_to_assign_s1u_ip address_for_5g_NSA_non_main_operator_First_net_
    ...	    scenario_via_ipsec_tunnel_establishment_at_BTS_startup_time_with_IPv6"
    ...     [Date]                  "22-02-11"
    ...     [Author]                "Monika Parasar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "ASIK_5g01"
    ...     [Config_File]           "CB008128_ipv6.xml"

#Force Tags     	    CA_E2ET_BTSTRSPZ        SBTS00        [SBTS22R2] 	       QCD_MN_RAN        QCP_RAN_ET        CRT

Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot

Suite Setup     Setup Oamops
Suite Teardown     Teardown Oamops

*** Variables ***
${Vlan_id}                                                  1810         1814         1818         1822


*** Test Cases ***
#[1][1.0] CB008128-The purpose of this test case is to assign s1u ip address for 5g NSA non-main operator –
#First net scenario via ipsec tunnel establishment at BTS startup time with IPv6
[1][1.0] CB008128_Verify_to_assign_s1u_ip_address_for_5g_NSA_non_main_operator_First_net_scenario_via_ipsec_tunnel_
#establishment_at_BTS_startup_time_with_IPv6


    Perform Commissioning with Dynamic ip configuration
    IPSEC Configuration for Strongswan
	Verify Ipsec Tunnels Status
	Run Keyword And Ignore Error     Call Setup  5g=CB008128_IPV6_SANSA_cfg:data   parallel=${False}    verify_attach=${False}
	...       attach=${False}
    Run Keyword And Ignore Error     Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=enb_x2_link_up  enb=1   target=2
	Verify Bts Status
	Attach call
	Verify Calls		2c00::3:3
#	Verify Calls            2c00::3:3                       2c00::3:7
	Detach call
	[Teardown]      Execute Teardown At The End

***Keywords***

Perform Commissioning with Dynamic ip configuration
    Perform Commissioning              verify_bts_status=False
	${interface_adddress_last_octet}=        Set Variable        1
    ${interface_adddress_last_octet_IPv6}=      Set Variable        0X02

    FOR        ${i}        IN RANGE    0      4
#        ${vlan_ids}=        Set Variable            ${Vlan_id}[${i}]
        ${interface_adddress_last_octet_IPv6_hex}=      Evaluate        hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
		${application_adddress_last_octet_IPv6_hex}=	Evaluate        hex(${interface_adddress_last_octet_IPv6}+1).lstrip("0x")
        ${broadcast_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+2
        Run     sudo ip link add link eth3 name eth3.${tl.vlan_ids}[${i}] type vlan id ${tl.vlan_ids}[${i}]
        Run     sudo ip addr add 10.0.3.${interface_adddress_last_octet}/30 brd 10.0.3.${broadcast_adddress_last_octet} dev eth3.${tl.vlan_ids}[${i}]
        Run     sudo ip link set dev eth3.${tl.vlan_ids}[${i}] up
        Run     sudo ifconfig eth3.${tl.vlan_ids}[${i}] inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
	Run	sudo ip -6 route add 2c00::3:${application_adddress_last_octet_IPv6_hex} via fc00::3:${application_adddress_last_octet_IPv6_hex}
        ${interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+4
        ${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
#		${vlan_ids}=                            Evaluate        ${vlan_ids}+1
	END

	FOR 		${i}		IN RANGE		1		10
	Run     sudo ip a a 10.0.1.13${i}/24 dev eth3
        Run     sudo ip a a fc00::13${i}/116 dev eth3
        Run     sudo ip a a fc00::14${i}/116 dev eth3
        Run     sudo ip a a fc00::15${i}/116 dev eth3
	END
	Run     sudo ifconfig eth3 inet6 add fc00::1/116
	sleep       360

IPSEC Configuration for Strongswan
	Run	sudo cp /etc/ipsec.conf /etc/ipsec_bkup.conf
	Run	sudo cp ${IPsec_ASIK_ipv6_conf} /etc/ipsec.conf
	Run 	sudo ipsec restart
	sleep		30

Verify Ipsec Tunnels Status
        @{parent_tunnel_moc_list} =     Query Admin Infomodel           query=get list ${ike_sa_l_moc_path}
        FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
               ${parent_tunnel_stateInfo}=     Get From Dictionary             dictionary=${ike_tunnel}                key=stateInfo
               ${parent_tunnel_proceduralState}=       Get From Dictionary	dictionary=${parent_tunnel_stateInfo}	key=proceduralState
               Should Be True  '${parent_tunnel_proceduralState}'=='Established'
		END

        @{child_tunnel_moc_list} =      Query Admin Infomodel           query=get list ${ipsec_sa_l_moc_path}
        FOR    ${child_tunnel}     IN      @{child_tunnel_moc_list}
               ${child_tunnel_stateInfo}=      Get From Dictionary             dictionary=${child_tunnel}              key=stateInfo
               ${child_tunnel_proceduralState}=        Get From Dictionary	dictionary=${child_tunnel_stateInfo}	key=proceduralState
               Should Be True  '${child_tunnel_proceduralState}'=='Installed'
		END



Attach call
	Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=ue_attach   id=11  selected_plmn=311:489
#    Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=enb_ue_dc_start  ue=11  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=trf_data_start  ue=11  id=2  dir=ul  trf_id=3  mbps=1
#    Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=ue_change_location     id=12    enb=5   cell=1
    Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=ue_attach   id=12  selected_plmn=311:490
#    Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=enb_ue_dc_start  ue=12  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=trf_data_start  ue=12  id=2  dir=ul  trf_id=3  mbps=1

Detach call
	Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=ue_detach   id=11
    Configure UE        5g=CB008128_IPV6_SANSA_cfg:data  command=ue_detach   id=12

Wireshark check
    [Arguments]         ${uplane}           ${pdn}              ${Wireshark_file}       ${analysis}
    Set Suite Variable          ${uplane_addr}          ${uplane}
    Set Suite Variable          ${PDN_IP}               ${pdn}
    Analyse Pcap        pcap_filename=${Wireshark_file}            analysis=${analysis}       filter_file_name=${pcap_file}



Verify Calls
	[Arguments]	${s1uplane}
	Generate Esp Sa Key File                    wireshark_host=wireshark_host               esp_sa_file=/home/ute/.config/wireshark/esp_sa
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
	sleep		60
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	Run Keyword And Ignore Error     Wireshark check	${s1uplane}	 4.7.254.208	${Wireshark_file}	Traffic_check_IPV6
#    Wireshark check         ${s1uplane_op2}             4.7.254.209         ${Wireshark_file}       Traffic_check_IPV6

Execute Teardown At The End
    FOR    ${i}        IN RANGE        0    4
           Run     sudo ip link delete eth3.${Vlan_id}[${i}]
	END
