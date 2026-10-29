*** Settings ***
Documentation
    ...     [Maintenance]           "TRS I&V Tools Bangalore Team"
    ...     [Procedure]             "The test case is to validate 5G call functionality"
    ...     [Date]                  "27-04-20"
    ...     [Author]                "Sharavathi Achar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "NSA DS"
    ...     [Feature_ID]            "5GC001049"
    ...     [Validation_status]     "Not yet tested"
    ...     [Validated_TestLine]    "5G-9010"
variables   ta_e2e_bts_trs_fw
Resource    ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Variables ***
${mtu_vlaue_dscp}    ETHIF-1/VLANIF-1:ipMtu
${initial_mtu_value}    1500
${pcap_point_A}	      ${EXECDIR}/wireshark_pointA.pcap
${pcap_point_B}	      ${EXECDIR}/wireshark_pointB.pcap
***Test Cases***
[1][1.0] TRS_5GC001049_Activation_Deactivation_Startup_SA
    [Documentation]     The test case is to validate 5G call functionality along dynamic fw enabled
    Perform Commissioning       scf_file=${scf_file}     timeout=400     alias=default      verify_bts_status=False
    Sleep   300
    Perform Recommissioning     type=param      rat=lte     param_path=MRBTS-1/NRBTS-1:actDynamicFirewall   operation=update     value=true
    ...      timeout=600
    Read BTS Parameters
    Sleep   30
    Verify 5g call
    [Teardown]     Teardown 5g call
***Keywords***
Add routes on VM
    Run     sudo ip a a 10.0.1.121/24 dev eth3
    Run     sudo ip a a 10.0.1.122/24 dev eth3
    Run     sudo ip a a 10.0.1.123/24 dev eth3
    Run     sudo ip a a 10.0.1.124/24 dev eth3
    Run     sudo ip a a 10.0.1.125/24 dev eth3
    Run     sudo ip a a 10.0.1.131/24 dev eth3
    Run     sudo ip a a 10.0.1.132/24 dev eth3
    Run     sudo ip a a 10.0.1.133/24 dev eth3
    Run     sudo ip a a 10.0.1.134/24 dev eth3
    Run     sudo ip a a 10.0.1.135/24 dev eth3
    Run     sudo ip a a 10.0.1.136/24 dev eth3
    Run     sudo ip a a 10.0.1.137/24 dev eth3
    Run     sudo ip a a 10.0.2.90/24 dev eth3
    Run     sudo ip a a 10.0.2.91/24 dev eth3
Read BTS Parameters
    [Documentation]     This keyword reads the configured value for cplane IPs based on the rat environment
    ${5g_ngu} =             Get Parameter   rat=common      param_path=${5g_sa_uplane1_ipv4_moc_path}
    Set Suite Variable  ${5g_ngu}       ${5g_ngu}
Perform 5G call
	Traffic capture start           capture_device=vm_eth3_interface
    Setup Remote Access    remote_device=bts
    Call Setup      5g=device1:data      parallel=${False}    verify_attach=${False}      ipv4_or_6=ipv4
    ...      attach=${False}   timeout=600
    Sleep   10
    Block    operation=Cell    rat=NR
    Sleep    120
    Unblock    operation=Cell    rat=NR
    Sleep    50
    Configure UE         5g=device1:data        command=ue_register      id=1        profile=1
    Sleep   5
    Configure UE       5g=device1:data     command=set_pdu_param     ue=1    pdu=1  trf_type=intrenal
    Sleep   5
    Configure UE      5g=device1:data     command=ue_pdu_session_setup  pdu=1   ue=1    nwslice=1   gw=1
    Sleep   5
    Configure UE      5g=device1:data     command=trf_data_start  ue=1      pdu=1    qfi=1      dir=ul       mbps=20
    Sleep   300
    Configure UE      5g=device1:data     command=ue_deregister     id=1     ue_deregister_type=switch_off
    Sleep   5
	${pcap_file}=	Traffic Capture Stop
    Set Suite Variable     ${pcap_file}     ${pcap_file}
Perform 5G call for downlink taraffic
    [Arguments]      ${udp_dl_profile}
    Traffic capture start           capture_device=vm_eth3_interface
    Setup Remote Access    remote_device=bts
    Call Setup      5g=device1:data  parallel=${False}  verify_attach=${False}  ipv4_or_6=ipv4
    Call    Setup      5g=device1:data    parallel=${False}    verify_attach=${False}    ipv4_or_6=ipv4    attach=${False}
    Configure UE       5g=device1:data    command=ue_attach  id=1  profile=1
    Configure UE       5g=device1:data    command=enb_ue_dc_start  ue=1  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE      5g=device1:data    command=trf_data_start  ue=1  id=2  dir=ul  trf_id=1  size=${higher_mtu_value}
    Call Start      5g=device1:data  profile=${udp_dl_profile}
    Sleep   15
    Run Keyword And Ignore Error    Call Stop  5g=device1:data  profile=${udp_dl_profile}
    Call Teardown   5g=device1:data
    Teardown remote Access
    ${pcap_file}=       Traffic capture stop
    Set Suite Variable     ${pcap_file}
Teardown 5g call
    Run    sudo killall egate edaemon
Verify wireshark traffic
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_uplink_traffic       filter_file_name=${5GC000577_traffic_filter}
Send packets from UE that is lesser than MTU of gNB
	 FOR   ${i}   IN RANGE   10
	     ${lesser_mtu_value}=         Evaluate    random.choice(range(200, ${initial_mtu_value}))  random
	     Set Suite Variable      ${lesser_mtu_value}      ${lesser_mtu_value}
	     Exit For Loop if     ${lesser_mtu_value} != ${initial_mtu_value}
	 END
     Perform 5G call
     Verify wireshark traffic
Verify 5g call
    ${dict} =     Query Admin Infomodel    query=get object //IPIF_A-*
    ${initial_mtu_value}=        Get From Dictionary    dictionary=${dict}        key=ipMtu
    LOG To Console    ${initial_mtu_value}
	Set Suite Variable      ${initial_mtu_value}    ${initial_mtu_value}
    Send packets from UE that is lesser than MTU of gNB