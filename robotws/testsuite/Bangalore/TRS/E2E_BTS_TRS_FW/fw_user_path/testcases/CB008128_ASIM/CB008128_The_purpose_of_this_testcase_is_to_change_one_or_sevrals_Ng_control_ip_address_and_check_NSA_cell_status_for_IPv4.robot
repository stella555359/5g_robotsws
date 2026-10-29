***Settings ***
Documentation
    ...     [Procedure]             "verify online modifcation of c and s1u plane"
    ...     [Date]                  "29-01-24"
    ...     [Author]                "Adarsh H N"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD"

#Force Tags 				CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    	    CA_E2ET_BTSTRSPZ        SBTS00
#...			[SBTS23R2] 	       QCD_MN_RAN        QCP_RAN_VRF        CRT

Resource        ${CURDIR}/../resources/common_keywords.robot

#Suite Setup       Setup Oamops
#Suite Teardown    Teardown Oamops


Suite Setup     Pre-conditions for testsuite
Suite Teardown     Post-conditions for testteardown




*** Test Cases ***
[1][1.0] CB008128_The_purpose_of_this_testcase_is_to_change_one_or_sevrals_Ng_control_ip_address_and_check_NSA_cell_status_for_IPv4
#[1][1.0] CB008128_To perform online modification of MRBTS parametrs when site configuration changes in C plane with IPv4

    Perform Commissioning       scf_file=${8128_base_scf}        verify_bts_status=False         timeout=600         alias=default
    Sleep    360
    Perform Recommissioning     type=delta        delta_file=8128_tunnels_with_ipv4.xml
    ...        skip_parameter_relation_errors=${True}      timeout=300
    Bring UP interfaces on VM
    Certificate Configure       operation=install_cmp_certificate       key_pool_type=RSA       timeout=300
    sleep     30

##    Certificate Configure    operation=install_certificate
    ...		cert_file=/home/ute/MN/UTE/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_user_path/testcases/resources/acceNB_4K3_004-cert.p12
##    ...     cert_type=BtsTrustChain         cert_format=P12         password=${Ipsec_Cert_password}
##    sleep	60
    IPSEC Configuration for Strongswan
    Verify Ipsec Tunnels Status
    Call Setup  nr=CB008128_IPV4_2op_cfg:data   parallel=${False}    verify_attach=${False}       attach=${False}
    Sleep   120
    Verify Bts Status
    Verify AMF status
    Attach call
    Verify calls Ngcplane
    Detach call
    Call Teardown       5g=CB008128_IPV4_2op_cfg:data
    Perform Recommissioning     type=delta        delta_file=cplane_s1uplane_modification.xml        skip_parameter_relation_errors=${True}
    ...		timeout=300
    Call Setup  nr=CB008128_IPV4_2op_online_modified:data   parallel=${False}    verify_attach=${False}       attach=${False}
    Sleep   90
    Verify Bts Status
    Verify AMF status
    Attach call after modified
    Verify calls modified Ngcplane
    Detach call after modified
   Perform Recommissioning    	type=delta        delta_file=secpol_ikep_modification.xml        skip_parameter_relation_errors=${True}
    ...      timeout=300
##    sleep   120
    Call Setup  nr=CB008128_IPV4_2op_cfg:data   parallel=${False}    verify_attach=${False}       attach=${False}
    Run Keyword And Ignore Error     Call Setup  nr=CB008128_IPV4_2op_online_modified:data   parallel=${False}    verify_attach=${False}
    ...       attach=${False}
    Sleep   60
    Verify Bts Status
    Verify AMF status
##    Attach call after modified
    Attach call
    Verify calls Ngcplane
##    Verify calls modified Ngcplane
    Detach call
##    Detach call after modified
    IPSEC Configuration for Strongswan Down
    Verify Alarm	faultid=61030		occurrences=8
    IPSEC Configuration for Strongswan Up
    Verify Alarm	faultid=61030	should_exist=${False}
    Verify Ipsec Tunnels Status
    Verify Bts Status
    Verify AMF status

***Keywords***
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

Verify AMF status
    ${AMF1_status}=      Get Parameter      param_path=MRBTS-1/NRBTS-1/SERVEDAMF-1:guAMI:guamiStatus
#    ${AMF2_status}=      Get Parameter      param_path=MRBTS-1/NRBTS-1/SERVEDAMF-2:guAMI:guamiStatus
    Should Be Equal     ${AMF1_status}     available
#    Should Be Equal     ${AMF2_status}     available

IPSEC Configuration for Strongswan
	Run			sudo cp /etc/ipsec.conf /etc/ipsec_bkup.conf
	Run			sudo cp ${IPSEC_plain_conf} /etc/ipsec.conf
	Run 		sudo ipsec restart
	sleep		120

IPSEC Configuration for Strongswan Down
	Run 		sudo ipsec stop
	sleep		120

IPSEC Configuration for Strongswan Up
	Run 		sudo ipsec restart
	sleep		120


Verify Ipsec Tunnels Status
        @{parent_tunnel_moc_list} =     Query Admin Infomodel           query=get list ${ike_sa_l_moc_path}
        FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
               ${parent_tunnel_stateInfo}=     Get From Dictionary             dictionary=${ike_tunnel}
        ...         key=stateInfo
               ${parent_tunnel_proceduralState}=       Get From Dictionary
        ...         dictionary=${parent_tunnel_stateInfo}           key=proceduralState
               Should Be True  '${parent_tunnel_proceduralState}'=='Established'
        END

        @{child_tunnel_moc_list} =      Query Admin Infomodel           query=get list ${ipsec_sa_l_moc_path}
        FOR    ${child_tunnel}     IN      @{child_tunnel_moc_list}
               ${child_tunnel_stateInfo}=      Get From Dictionary             dictionary=${child_tunnel}
        ...         key=stateInfo
               ${child_tunnel_proceduralState}=        Get From Dictionary
        ...         dictionary=${child_tunnel_stateInfo}            key=proceduralState
               Should Be True  '${child_tunnel_proceduralState}'=='Installed'
        END



Attach call
	Configure UE        5g=CB008128_IPV4_2op_cfg:data  command=ue_attach   id=11  selected_plmn=311:489
#    Configure UE        5g=CB008128_IPV4_2op_cfg:data
#    ...         command=enb_ue_dc_start  ue=11  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE        5g=CB008128_IPV4_2op_cfg:data  command=trf_data_start  ue=11  id=2  dir=dl  trf_id=3  mbps=1

Detach call
	Configure UE        5g=CB008128_IPV4_2op_cfg:data  command=ue_detach   id=11

Attach call after modified
    Configure UE        5g=CB008128_IPV4_2op_online_modified:data  command=ue_attach   id=11  selected_plmn=311:489
    Configure UE        5g=CB008128_IPV4_2op_online_modified:data
    ...         command=enb_ue_dc_start  ue=11  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE        5g=CB008128_IPV4_2op_online_modified:data  command=trf_data_start  ue=11  id=2  dir=dl  trf_id=3  mbps=1

Detach call after modified
    Configure UE        5g=CB008128_IPV4_2op_online_modified:data  command=ue_detach   id=11

Wireshark check
    [Arguments]         ${Ngcplane_ip}           ${amf_ip}        ${Wireshark_file}       ${analysis}
    Set Suite Variable          ${cplane_ip}          ${Ngcplane_ip}
    Set Suite Variable          ${amf_ip}               ${amf_ip}
    Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=${analysis}     filter_file_name=${pcap_file}

Verify calls Ngcplane
    Generate Esp Sa Key File    wireshark_host=wireshark_host_local   esp_sa_file=/home/ute/.config/wireshark/esp_sa
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    sleep       120
    ${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
    Run Keyword And Ignore Error        Wireshark check             11.0.1.2            10.0.1.1        ${Wireshark_file}       Traffic_verrify_IPV4
    Run Keyword And Ignore Error        Wireshark check             11.0.1.4            10.0.1.1        ${Wireshark_file}       Traffic_verrify_IPV4
#    Wireshark check             11.0.1.3            10.0.1.20        ${Wireshark_file}       Traffic_verrify_IPV4

Verify calls modified Ngcplane
    Generate Esp Sa Key File    wireshark_host=wireshark_host_local   esp_sa_file=/home/ute/.config/wireshark/esp_sa
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    sleep       120
    ${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
    Wireshark check             11.0.1.4            10.0.1.1        ${Wireshark_file}       Traffic_verrify_IPV4
#    Wireshark check             11.0.1.5            10.0.1.20        ${Wireshark_file}       Traffic_verrify_IPV4
