** Settings ***

Documentation
...     [Procedure]                 "NCDR Test Execution"
...     [Date]                      "30-05-2023"
...     [Author]                    "Aditya Kanakamalla"
...     [Scrum]                     "TRS VRF-6"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Library         taf.sbts.oam.coam.admin

Suite Setup     Setup Oamops
Suite Teardown     Teardown Oamops

*** Test Cases ***
[1]Verification_of_multiple_software_upgrade_scenario_with_dual_stack_ipsec_FSMF
    Precondition
    Bring setup onair
    Enable IPSEC
    Verify Ipsec Tunnels Status
    Send traffic and verify packets


***Keywords***
Precondition
    taf.sbts.oam.coam.admin.Perform Commissioning       scf_file=${ipsec_base_scf}    verify_bts_status=False      timeout=400     alias=default
    Sleep   300
    Run         sudo ipsec stop

Bring setup onair
    Call Setup      lte=IPSEC_config:data   parallel=${False}    verify_attach=${False}       attach=${False}
    Verify BTS status   should_be_onair=${True}

Enable IPSEC
    Certificate Configure    operation=install_certificate    cert_file=${valid_ipsec_cert}     cert_type=BtsTrustChain     cert_format=P12
    ...     password=${valid_ipsec_cert_password}
    sleep     60
    Perform Recommissioning     type=param      rat=lte      param_path=IPSECC-1:ipSecEnabled    operation=update    value=true  timeout=300
    Sleep   60
    Run         sudo ipsec restart
    sleep       120

Verify Ipsec Tunnels Status
#    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel    query=get list ${ike_sa_l_moc_path}
    FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
    ${parent_tunnel_stateInfo}=     Get From Dictionary         dictionary=${ike_tunnel}    key=stateInfo
    ${parent_tunnel_proceduralState}=    Get From Dictionary        dictionary=${parent_tunnel_stateInfo}   key=proceduralState
    Should Be True  '${parent_tunnel_proceduralState}'=='Established'
    END

    @{child_tunnel_moc_list} =      Query Admin Infomodel   query=get list ${ipsec_sa_l_moc_path}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
    ${child_tunnel_stateInfo}=      Get From Dictionary         dictionary=${child_tunnel}  key=stateInfo
    ${child_tunnel_proceduralState}=        Get From Dictionary     dictionary=${child_tunnel_stateInfo}    key=proceduralState
    Should Be True  '${child_tunnel_proceduralState}'=='Installed'
    END

Send traffic and verify packets
    Traffic Capture Start         capture_device=vm_eth3_interface      alias=ipsec_packets
    Configure UE      lte=IPSEC_config:data     command=ue_attach id=1 cell=1
    Sleep   5
    Configure UE      lte=IPSEC_config:data     command=trf_data_start ue=1 dir=dl protocol=udp Mbps=75
    Sleep   5
    Configure UE      lte=IPSEC_config:data     command=trf_data_start ue=1 dir=ul protocol=udp Mbps=75
    Sleep   60

    ${Wireshark_file} =      Traffic Capture Stop        alias=ipsec_packets

    Point A Traffic capture and verify
    Point B Traffic capture and verify for ESP Packets


Point A Traffic capture and verify
#    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=True   timeout=120
    sleep   60

    ${filename_A}=  Traffic Capture Stop   mode=file    timeout=100

    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=UL_Traffic_check1
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=DL_Traffic_check1

Point B Traffic capture and verify for ESP Packets
#    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=True   timeout=120

    sleep   60

    ${filename_A}=  Traffic Capture Stop   mode=file    timeout=100

    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=ESP
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=ESP