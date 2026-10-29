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

Force Tags 				CA_E2ET_BTSTRSPZ        SBTS00        QCD_MN_RAN        QCP_RAN_VRF        CRT

Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Pre-conditions for testsuite
Suite Teardown     Post-conditions for testteardown
#Suite Setup         Setup Oamops
#Suite Teardown     Teardown Oamops




*** Test Cases ***
[1][1.0] CB008128-The purpose of this testcase is to disable dynamic IP for single tunnel with IPv4 in 5G NSA

    Bring UP interfaces on VM
    Perform Recommissioning    type=delta    delta_file=CMP_RSA.xml    timeout=100
    Sleep   30
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=RSA       timeout=600
    Perform Recommissioning     type=delta        delta_file=8128_tunnel_with_ipv4_Single_IP.xml
    ...        skip_parameter_relation_errors=${True}      timeout=300
    sleep	60
    IPSEC Configuration for Strongswan      8128_enable
    Verify Ipsec Tunnels Status

    Perform Recommissioning     type=param      param_path=IKEP-1:ikeIdentityIndex      operation=delete    value=1     timeout=120
    Perform Recommissioning     type=delta        delta_file=Without_8128_config.xml    skip_parameter_relation_errors=${True}      timeout=300
    IPSEC Configuration for Strongswan      8128_disable
    Verify Ipsec Tunnels Status
    Sleep   60

    Perform Recommissioning     type=param      param_path=SECPOL-9:ikePDN      operation=delete    value=2     timeout=120
    Perform Recommissioning     type=param      param_path=SECPOL-9:ipSecPDN      operation=delete    value=2     timeout=120
    Perform Recommissioning     type=delta        delta_file=With_8128_config.xml    skip_parameter_relation_errors=${True}      timeout=300
    IPSEC Configuration for Strongswan      8128_enable_2nd
    Verify Ipsec Tunnels Status
    Sleep   60


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
    ${AMF2_status}=      Get Parameter      param_path=MRBTS-1/NRBTS-1/SERVEDAMF-2:guAMI:guamiStatus
    Should Be Equal     ${AMF1_status}     available
    Should Be Equal     ${AMF2_status}     available

IPSEC Configuration for Strongswan
    [Arguments]         ${CB008128_state}
#	Run			sudo cp /etc/ipsec.conf /etc/ipsec_bkup.conf
	Run			sudo cp ${CURDIR}/resources/${CB008128_state}_ipsec.conf /etc/ipsec.conf
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
    Configure UE        5g=CB008128_IPV4_2op_cfg:data
    ...         command=enb_ue_dc_start  ue=11  target_gnb=2  target_cells=1  bearer=2  type=split_scg
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
    Wireshark check             11.0.1.2            10.0.1.1        ${Wireshark_file}       Traffic_verrify_IPV4
    Wireshark check             11.0.1.3            10.0.1.20        ${Wireshark_file}       Traffic_verrify_IPV4

Verify calls modified Ngcplane
    Generate Esp Sa Key File    wireshark_host=wireshark_host_local   esp_sa_file=/home/ute/.config/wireshark/esp_sa
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    sleep       120
    ${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
    Wireshark check             11.0.1.4            10.0.1.1        ${Wireshark_file}       Traffic_verrify_IPV4
    Wireshark check             11.0.1.5            10.0.1.20        ${Wireshark_file}       Traffic_verrify_IPV4


