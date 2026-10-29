***Settings ***
Documentation
    ...     [Procedure]             "verify that Select M-plane source IP for FQDN resolution"
    ...     [Date]                  "22-10-22"
    ...     [Author]                "Monika Parasar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD"

Force Tags 				CA_E2ET_BTSTRSPZ        SBTS00      QCD_MN_RAN        QCP_RAN_VRF        CRT

Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Pre-conditions for testsuite
Suite Teardown     Post-conditions for testteardown




*** Test Cases ***
[1][1.0] CB008128_The purpose of this test case is to verify that Select M-plane source IP for FQDN resolution for IPSEC tunnel remote tunnel end
# Point.

	Copy the Files from Rotta
#	Install DNS package			${ipv4_zone_file}			fwd.olympians.nsn.com.db
    Run     sudo systemctl restart bind9
    Run     sudo systemctl enable bind9
    Run     sudo systemctl status bind9
    Perform Commissioning       scf_file=/home/ute/Downloads/Base_SCF/CB008128_Select_M_plane_source_IP_Refer_For_Delta.xml
    ...     verify_bts_status=False     timeout=400
#a    Perform Recommissioning     type=delta        delta_file=8128_tunnels_with_fqdn.xml       skip_parameter_relation_errors=${True}  timeout=300
#a    Perform Recommissioning     type=delta        delta_file=test_delta.xml       skip_parameter_relation_errors=${True}      timeout=300
    Sleep   300
	Bring UP interfaces on VM
	sleep	120
	IPSEC Configuration for Strongswan
	Verify Ipsec Tunnels Status
#	Call Setup  5g=CB008128_IPV4_2op_cfg:data   parallel=${False}    verify_attach=${False}       attach=${False}
#	Verify Bts Status
#    Verify AMF status
#	Attach call
    Run     ping 11.0.1.2 >ping.txt & echo $! > pid.txt
	Enable DPD optimisation
    Verify Alarm    faultid=6450     should_exist=${False}
#    Detach call
#    Attach call
    sleep       20
	Verify No isakmp messages
    Run     for pid in $(ps -ef | grep ping | awk '{print $2}'); do kill -9 $pid; done
#	Detach call
    sleep       180
	Verify isakmp messages
	Disable DPD optimisation
    Verify Alarm    faultid=6450     should_exist=${False}
	Verify isakmp messages
#	Attach call
    Run     ping 11.0.1.2 >ping.txt & echo $! > pid.txt
	sleep		30
	Verify isakmp messages


***Keywords***
Copy the Files from Rotta
#    Run     wget -O ${luapath}/acceNB_4K3_004-cert.p12 ${Rotta_link}/acceNB_4K3_004-cert.p12
#    Run     wget -O ${luapath}/fwd.ipv6olympians.nsn.com.db ${Rotta_link}/fwd.ipv6olympians.nsn.com.db
#    Run     wget -O ${luapath}/fwd.olympians.nsn.com.db ${Rotta_link}/fwd.olympians.nsn.com.db
#    Run     wget -O ${luapath}/named.conf.local ${Rotta_link}/named.conf.local
    Run     sudo cp ${CURDIR}/resources/fwd.olympians.nsn.com.db /etc/bind/fwd.olympians.nsn.com.db

Bring UP interfaces on VM

	FOR 		${i}		IN RANGE		1		10
    	Run     sudo ip a a 10.0.1.13${i}/24 dev eth3
		Run     sudo ip a a 10.0.1.14${i}/24 dev eth3
    END
    Run		sudo ip a a 10.0.1.121/24 dev eth3
	Run		sudo ip a a 10.0.1.122/24 dev eth3
	Run		sudo ip a a 10.0.1.12/24 dev eth3
	Run		sudo ip a a 10.0.1.13/24 dev eth3
	Run		sudo ip a a 10.0.1.20/24 dev eth3
    sleep       60

Enable DPD optimisation
	Perform Recommissioning     type=param     param_path=IPSECC-1:dpdOptimisationEnabled
	...     operation=update    value=true      timeout=300
    Run     sudo ipsec restart
	sleep		200

Disable DPD optimisation
	Perform Recommissioning     type=param     param_path=IPSECC-1:dpdOptimisationEnabled
	...     operation=update    value=false      timeout=300
    Run     sudo ipsec restart
	sleep		200

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
               ${parent_tunnel_stateInfo}=     Get From Dictionary             dictionary=${ike_tunnel}         key=stateInfo
               ${parent_tunnel_proceduralState}=       Get From Dictionary         dictionary=${parent_tunnel_stateInfo}          key=proceduralState
               Should Be True  '${parent_tunnel_proceduralState}'=='Established'
        END

        @{child_tunnel_moc_list} =      Query Admin Infomodel           query=get list ${ipsec_sa_l_moc_path}
        FOR    ${child_tunnel}     IN      @{child_tunnel_moc_list}
               ${child_tunnel_stateInfo}=      Get From Dictionary             dictionary=${child_tunnel}        key=stateInfo
               ${child_tunnel_proceduralState}=        Get From Dictionary        dictionary=${child_tunnel_stateInfo}            key=proceduralState
               Should Be True  '${child_tunnel_proceduralState}'=='Installed'
        END


Attach call
	Configure UE        5g=CB008128_IPV4_2op_cfg:data  command=ue_attach   id=11  selected_plmn=311:489
    Configure UE        5g=CB008128_IPV4_2op_cfg:data
    ...         command=enb_ue_dc_start  ue=11  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE        5g=CB008128_IPV4_2op_cfg:data  command=trf_data_start  ue=11  id=2  dir=dl  trf_id=3  mbps=1

Detach call
	Configure UE        5g=CB008128_IPV4_2op_cfg:data  command=ue_detach   id=11

Wireshark check
    [Arguments]         ${local_tunnel_ip}           ${remote_tunnel_ip}        ${Wireshark_file}       ${analysis}
    Set Suite Variable          ${local_tunnel_ip}          ${local_tunnel_ip}
    Set Suite Variable          ${remote_tunnel_ip}               ${remote_tunnel_ip}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=${analysis}     filter_file_name=${pcap_file}

Verify isakmp messages
	Generate Esp Sa Key File    wireshark_host=wireshark_host_local   esp_sa_file=/home/ute/.config/wireshark/esp_sa
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
	sleep		120
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	FOR		${i}		IN RANGE		2		9
			Wireshark check				10.0.1.${i}			10.0.1.1		${Wireshark_file}		isakmp_check_IPV4
    END

Verify No isakmp messages
	Generate Esp Sa Key File    wireshark_host=wireshark_host_local       esp_sa_file=/home/ute/.config/wireshark/esp_sa
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
	sleep		120
	${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
	Wireshark check				10.0.1.2			10.0.1.1		${Wireshark_file}		no_isakmp_check_IPV4
	FOR		${i}		IN RANGE		3		9
			Wireshark check				10.0.1.${i}			10.0.1.1		${Wireshark_file}		isakmp_check_IPV4
    END