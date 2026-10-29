*** Settings ***
Documentation
...     [Author]        "Shankar Manurwar"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "ASOF_1_Olympians_10.58.143.83"



variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown

*** Variables ***
${filter_file_name}         RP000727_traffic_filters.json
#${valid_ipsec_cert}         /home/ute/MN/UTE/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/resources/acceNB_4K3_004-cert.p12
${valid_ipsec_cert_password}        nsnCERT
${RP000727_base.xml}        /home/ute/Downloads/Base_SCF/RP000727/RP000727_base.xml
${IPSEC_RP000727_conf}      /home/ute/Downloads/Base_SCF/RP000727/RP000727_ipsec.conf

*** Test Cases ***
[1][2.0] RP000727_IPsec Concurrent tunnels RAN sharing

    Preconditons
    Add Online IPv6 configuration
    Bringup On Air
    Ipsec Configuration
    Concurrent Tunnel verification
   Run     sudo ipsec stop
#    OP1 call and verify
#    OP2 call and verify

***Keywords***

Preconditons

    Add Routes
    sleep   10
    Perform commissioning       scf_file=${RP000727_base.xml}   verify_bts_status=False     timeout=400     alias=default
    Sleep   100
    Certificate Configure   operation=install_cmp_certificate    key_pool_type=RSA    timeout=600



Add Online IPv6 configuration

    Perform Recommissioning     type=delta      delta_file=${Add_Ipv6_config}     timeout=300
    sleep     60
    Verify Alarm        	faultid=6450    should_exist=${False}    occurrences=1   alarm_type=active
    sleep   5

Bringup On Air
    Call Setup  lte=RP000727_CUS:data   parallel=${False}   verify_attach=${False}     attach=
    Verify BTS status   should_be_onair=${True}

Ipsec Configuration

    Perform Recommissioning     type=delta      delta_file=${delta_RP000727}     timeout=300
    Run         sudo cp /etc/ipsec.conf /etc/ipsec_bkup.conf
    Run         sudo cp ${IPSEC_RP000727_conf} /etc/ipsec.conf
    Run         sudo ipsec restart
    sleep       120

    Verify BTS status   should_be_onair=${True}

Concurrent Tunnel verification

        @{parent_tunnel_moc_list} =     Query Admin Infomodel           query=get list ${ike_sa_l_moc_path}
        FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
               ${parent_tunnel_stateInfo}=     Get From Dictionary             dictionary=${ike_tunnel}
        ...     key=stateInfo
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
Add Routes
    Run     sudo ipsec stop
    Run     sudo killall egate edaemon
    Run     sudo ip link delete eth3.1200
    Run     sudo ip link delete eth3.1201
    Run     sudo ip a d 10.0.1.1/24 dev eth3
    Run		sudo ip link add link eth3 name eth3.1200 type vlan id 1200
    Run		sudo ip addr add 10.0.1.1/30 brd 10.0.1.255 dev eth3.1200
    Run		sudo ip link set dev eth3.1200 up
    Run		sudo ifconfig eth3.1200 inet6 add fc00::1/126

    Run	  	sudo ip link add link eth3 name eth3.1201 type vlan id 1201
    Run		sudo ip addr add 10.0.1.5/30 brd 10.0.1.255 dev eth3.1201
    Run		sudo ip link set dev eth3.1201 up
    Run		sudo ifconfig eth3.1201 inet6 add fc00::5/126

    Run		sudo ifconfig eth3.1200 inet6 add fc00::133/126
    Run		sudo ifconfig eth3.1200 inet6 add fc00::134/126
    Run		sudo ifconfig eth3 inet6 add fc00::26/126
    Run		sudo ifconfig eth3 inet6 add fc00::27/126

    Run	sudo ip a a 10.0.1.131/24 dev eth3
    Run	sudo ip a a 10.0.1.132/24 dev eth3
    Run	sudo ip a a 10.0.1.133/24 dev eth3
    Run	sudo ip a a 10.0.1.134/24 dev eth3
    Run	sudo ip a a 10.0.1.135/24 dev eth3
    Run	sudo ip a a 10.0.1.136/24 dev eth3
    Run	sudo ip a a 10.0.1.137/24 dev eth3
    Run	sudo ip a a 10.0.1.26/24 dev eth3
    Run	sudo ip a a 10.0.1.27/24 dev eth3


OP1 call and verify

    Traffic Capture Start   capture_device=oam_device   mode=file    measurement_point=NE_Terminated    uplane_capturing=${True}    timeout=200
    sleep   10

    Configure UE     lte=RP000727_CUS:data       command=ue_attach id=1 cell=12 selected_plmn=311:489
    Configure UE     lte=RP000727_CUS:data       command=trf_data_start ue=1 dir=dl_and_ul protocol=udp kbps_dl=2000 kbps_ul=2000
    sleep   120

    ${pcap_fileA}=  Traffic Capture Stop    mode=file    timeout=200
    Analyse Pcap        pcap_filename=${pcap_fileA}     analysis=verify_OP1           filter_file_name=${filter_file_name}

    Configure UE     lte=RP000727_CUS:data       command=ue_detach   id=1
    sleep   10

OP2 call and verify

    Traffic Capture Start   capture_device=oam_device   mode=file    measurement_point=NE_Terminated    uplane_capturing=${True}    timeout=200
    sleep   10

    Configure UE     lte=RP000727_CUS:data       command=ue_attach id=1 cell=12 selected_plmn=311:490
    Configure UE     lte=RP000727_CUS:data       command=trf_data_start ue=1 dir=dl_and_ul protocol=udp kbps_dl=2000 kbps_ul=2000
    sleep   120

    ${pcap_fileA}=  Traffic Capture Stop    mode=file    timeout=200
    Analyse Pcap        pcap_filename=${pcap_fileA}     analysis=verify_OP2           filter_file_name=${filter_file_name}


    Configure UE     lte=RP000727_CUS:data       command=ue_detach   id=1
