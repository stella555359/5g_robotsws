*** Settings ***
Documentation
...     [Procedure]     "Verify IPSEC NCDR"
...     [Author]        "Santoshkumar"
...     [Maintenance]   "TRS_VRF"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Function_Hash_Tags]    "IPSEC"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "ASIB HR"

***Keywords***
Perform BASIC Commisioning
    Perform Commissioning       scf_file=${Tunnels}        verify_bts_status=False         timeout=600         alias=default
    Sleep   600

Perform IPSEC Commisioning
    Perform Commissioning       scf_file=${IPSEC_SCF}        verify_bts_status=False         timeout=600         alias=default
    Sleep   600

Perform IPSEC Recommisioning
	Perform Recommissioning		type=delta		delta_file=${Delta_IPSEC}		skip_parameter_relation_errors=${False}		timeout=600
	Sleep	100

Verify Ipsec Tunnels Status
    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel	query=get list ${ike_sa_l_moc_path}	alias=${dut}
    FOR    ${ike_tunnel}	IN      @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary	dictionary=${ike_tunnel}	key=stateInfo
        ${parent_tunnel_proceduralState}=    Get From Dictionary	dictionary=${parent_tunnel_stateInfo}
     ...    key=proceduralState
        Should Be True	'${parent_tunnel_proceduralState}'=='Established'
    END
    @{child_tunnel_moc_list} =      Query Admin Infomodel	query=get list ${ipsec_sa_l_moc_path}	alias=${dut}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=      Get From Dictionary	dictionary=${child_tunnel}	key=stateInfo
        ${child_tunnel_proceduralState}=        Get From Dictionary	dictionary=${child_tunnel_stateInfo}
     ...    key=proceduralState
        Should Be True	'${child_tunnel_proceduralState}'=='Installed'
    END

Verify BTS on Air status
	Call Setup      5g=kbk_plain:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
    Wait Until Keyword Succeeds   300 sec   20 sec    Verify Alarm    faultid=61030    should_exist=${False}
    Wait until keyword succeeds   300 sec   60 sec    Verify Bts Status    should_be_onair=${True}      timeout=600

Upgrade to target build and verify the status
    Perform software download and update   package=${profile}   should_activate=True    timeout=2400
	Sleep	600
    Wait until keyword succeeds   300 sec   60 sec    Verify Bts Status    should_be_onair=${True}      timeout=600
    Wait Until Keyword Succeeds   300 sec   20 sec    Verify Alarm    faultid=61030    should_exist=${False}

Verify Mplane Access
     setup Oamops    dut=mplane    alias=mplane
     Perform Recommissioning        type=param           param_path=${ssh_enable}     operation=update     value=false    timeout=180
     Sleep    120
     Perform Recommissioning        type=param           param_path=${ssh_enable}     operation=update     value=true    timeout=180
     Sleep    120
     Teardown Oamops    alias=mplane

IPsec Disable and Enable
    Perform Recommissioning        type=param           param_path=IPSECC-1:ipSecEnabled     operation=update     value=false    timeout=180
    Sleep   120
	Wait Until Keyword Succeeds   300 sec   10 sec    Verify Established Tunnels	0
    Perform Recommissioning        type=param           param_path=IPSECC-1:ipSecEnabled     operation=update     value=true    timeout=180
    Sleep   120
    Wait Until Keyword Succeeds   300 sec   10 sec    Verify Established Tunnels   647
    Verify Ipsec Tunnels Status
    Wait Until Keyword Succeeds   300 sec   20 sec    Verify Alarm    faultid=61030    should_exist=${False}

Modify IPSEC configuration and check for tunnel status
    Perform Recommissioning		type=delta		delta_file=${IKEP_IPSECP_delta}		skip_parameter_relation_errors=${True}		timeout=600
    Wait Until Keyword Succeeds   300 sec   10 sec    Verify Established Tunnels   647
    Verify Ipsec Tunnels Status
    Perform Recommissioning     type=delta      delta_file=${delta_12}    skip_parameter_relation_errors=${True}      timeout=600
    Wait Until Keyword Succeeds   300 sec   10 sec    Verify Established Tunnels   647
    Verify Ipsec Tunnels Status
    Perform Recommissioning     type=delta      delta_file=${secpol_deletion}     skip_parameter_relation_errors=${True}      timeout=600
    Sleep   120
    Perform Recommissioning     type=delta      delta_file=${secpol_addition}     skip_parameter_relation_errors=${True}      timeout=600
    Wait Until Keyword Succeeds   300 sec   10 sec    Verify Established Tunnels   647
	Verify Alarm    faultid=61030    should_exist=${False}
    Verify Ipsec Tunnels Status

Mplane ping test
    ${output}=        Run     ping -c 50 10.0.1.2 -I 10.0.1.15
    Should contain     ${output}        0% packet loss

Get Iteration DSCP
    [Arguments]    ${index}
    IF    ${index} == 0
        ${DSCP}=    Set Variable    ${DEFAULT_DSCP}
        Log    Iteration ${index}: Using default DSCP = ${DSCP}
    ELSE
        ${DSCP}=    Evaluate    (${DEFAULT_DSCP} + ${index}) if (${DEFAULT_DSCP} + ${index}) <= ${MAX_DSCP} else (${DEFAULT_DSCP} + ${index}) -
        ...    ${MAX_DSCP}
        Log    Iteration ${index}: Changing DSCP to ${DSCP}
    END
    [Return]    ${DSCP}

Verify Established Tunnels
    [Arguments]    ${expected_tun}
    Setup Remote Access     remote_device=bts     timeout=30     alias=default
     ${no_tunnel}=       Remote Command Execute      command=ipsec status | grep INSTALLED | wc -l
     Sleep   100
     Set Suite Variable     ${no_tunnel}
     Teardown Remote Access    alias=default
     Should be equal   ${no_tunnel}    ${expected_tun}

ETHIF Counter Verification

    Pm Counters Start     analysis=verify_tagged_untagged_counters
    ...     counter_analysis_file=${counter_analysis_file_name}
    sleep       30

    Set Suite Variable      ${Class1}               90..100
    Set Suite Variable      ${Class2}               0..10
    Set Suite Variable      ${Class3}               0..10
    Set Suite Variable      ${Class4}               0..10
    Set Suite Variable      ${Class5}               0..10

    Verify Pm Counters      analysis=verify_tagged_untagged_counters
    ...     counter_analysis_file=${counter_analysis_file_name}


ETHLK Counter Verification

    Pm Counters Start     analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}
    sleep       30

    Set Suite Variable      ${Class1}               0..10
    Set Suite Variable      ${Class2}               90..100
    Set Suite Variable      ${Class3}               0..10
    Set Suite Variable      ${Class4}               0..10
    Set Suite Variable      ${Class5}               0..10

    Verify Pm Counters      analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}

Send Traffic and Verify SentESP and ReceivedESP Counter
	Pm Counters Start		analysis=Send_and_Rcv_ESP_Counter		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -I 10.0.1.4 10.0.3.1 -c ${Ping_Packet_Count}
    Execute command on ENodeB       ping 10.0.3.1 -I 10.0.1.4 -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=Send_and_Rcv_ESP_Counter		counter_analysis_file=${counter_analysis_file}		pm_interval=5

Duplicate and reorder downlink traffic and Verify AntiReplayErrors Counter
    Pm Counters Start		analysis=antiReplayErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5
    Comment     Duplicate and reorder downlink traffic
    Run     sudo tc qdisc add dev eth3.551 root netem duplicate 100% delay 100ms reorder 100%
	Run		ping -I 10.0.1.4 10.0.3.1 -c ${Ping_Packet_Count}
    Execute command on ENodeB       ping 10.0.3.1 -I 10.0.1.4 -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=antiReplayErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5
   [Teardown]		Run     sudo tc qdisc del dev eth3.551 root netem duplicate 100% delay 100ms reorder 100%

Corrupt ESP packets sent to eNB and Verify espCryptographicErrors Counter
    Pm Counters Start    analysis=espCryptographicErrors    counter_analysis_file=${counter_analysis_file}    pm_interval=5
    Comment    Corrupt ESP packets sent to eNB
    Run    sudo tc qdisc add dev eth3.551 root netem corrupt 30%
    Execute command on ENodeB    ping 10.0.3.1 -I 10.0.1.4 -c ${Ping_Packet_Count}
    Verify Pm Counters    analysis=espCryptographicErrors    counter_analysis_file=${counter_analysis_file}    pm_interval=5
    [Teardown]    Run    sudo tc qdisc del dev eth3.551 root netem corrupt 30%

Verify ipsecSaNotFound and recvUnprotPacketMatchProtPol counter
    Pm Counters Start    analysis=ipsecSaNotFound_and_recvUnprotPacketMatchProtPol    counter_analysis_file=${counter_analysis_file}    pm_interval=5
    Comment     Send ESP with wrong SPI to verify ipsecSaNotFound counter
    ${stdout}=      Run     expect ${CURDIR}/Send_ESP_Packets.exp IPv4 10.0.1.4 10
    Set Suite Variable      ${ESP_Count}	10
    Comment     Send Unencrypted packets to verify recvUnprotPacketMatchProtPol counter
    ${stdout}=      Run		expect ${CURDIR}/Send_UDP_TCP_SCTP_packets.exp IPv4 10.0.1.10 10.0.1.10 10.0.1.10 10
    Set Suite Variable      ${Unprotect_Count}		30
    Verify Pm Counters    analysis=ipsecSaNotFound_and_recvUnprotPacketMatchProtPol    counter_analysis_file=${counter_analysis_file}    pm_interval=5

Create Bypass Policy and Verify setPacketMatchBypassPol and receivedPacketMatchBypassPol Counter
    	Perform Recommissioning      type=param      param_path=SECPOL-1:ipSecAction     operation=update        value=BYPASS       timeout=300
	Pm Counters Start		analysis=sent_and_received_PacketMatchBypassPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5
        Run     ping -I 10.0.3.1 10.0.1.4 -c ${Ping_Packet_Count} 1>/dev/null &
        Execute command on ENodeB       ping 10.0.3.1 -I 10.0.1.4 -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=sent_and_received_PacketMatchBypassPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5
    [Teardown]    Perform Recommissioning    type=param    param_path=SECPOL-1:ipSecAction    operation=update    value=PROTECT    timeout=300

Start Ping test from Enb for Unconfigured IP and Verify sentPacketMatchDefPol counter
	Run		sudo ip addr add 10.0.1.10/24 brd 10.0.1.255 dev eth3
	Pm Counters Start		analysis=sent_and_Rcv_PacketMatchDefPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -I 10.0.1.10 10.0.1.4 -c ${Ping_Packet_Count} 1>/dev/null &
	Execute command on ENodeB		ping 10.0.1.10 -I 10.0.1.4 -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=sent_and_Rcv_PacketMatchDefPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	[Teardown]	Run	sudo ip addr del 10.0.1.10/24 brd 10.0.1.255 dev eth3

Create Discard Policy and Verify setPacketMatchDiscPol and receivedPacketMatchDiscPol Counter
   Perform Recommissioning      type=param      param_path=SECPOL-1:ipSecAction     operation=update        value=DISCARD       timeout=300
   Pm Counters Start        analysis=sent_and_received_PacketMatchDiscPol       counter_analysis_file=${counter_analysis_file}      pm_interval=5
   Run     ping -I 10.0.3.1 10.0.1.4 -c ${Ping_Packet_Count} 1>/dev/null &
   Execute command on ENodeB       ping 10.0.3.1 -I 10.0.1.4 -c ${Ping_Packet_Count}
   Verify Pm Counters       analysis=sent_and_received_PacketMatchDiscPol       counter_analysis_file=${counter_analysis_file}      pm_interval=5
    [Teardown]    Perform Recommissioning    type=param    param_path=SECPOL-1:ipSecAction    operation=update    value=PROTECT    timeout=300

Create SA Failure and Verify failedSAEstablishment
    Call Setup      5g=kbk_plain:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
    Verify Bts Status    should_be_onair=${True}      timeout=600
    Create SA Failure and Verify failedSAEstablishments Counter
    Call Teardown  5g=kbk_plain:data
    Remove SA Failure

Create SA failure
	Perform Recommissioning		type=param		param_path=IPSECP-1:extendedSequenceNumberMode	operation=update	value=EXTENDED_SEQUENCE
	...		timeout=300
	Perform Recommissioning		type=param		param_path=IPSECP-1:saMaxLifeTime	operation=update	value=300		timeout=300

Remove SA Failure
    Perform Recommissioning     type=param	param_path=IPSECP-1:extendedSequenceNumberMode  operation=update    value=NORMAL_SEQUENCE	timeout=300

Create SA Failure and Verify failedSAEstablishments Counter
    Comment    Create Child tunnels failure by changing extendedSequenceNumberMode only on Enb.
    Create SA failure
    Pm Counters Start    analysis=failedSAEstablishments    counter_analysis_file=${counter_analysis_file}    pm_interval=5
    ${GTP_eth3_capture}=    Traffic Capture Start    capture_device=oam_device    mode=file    measurement_point=NE_Terminated
    ...    uplane_capturing=True    timeout=120
    Configure UE    5g=kbk_plain:data    command=set_pdu_param    ue=51    pdu=1    trf_type=internal
    Configure UE    5g=kbk_plain:data    command=ue_register    id=51    profile=1
    Sleep    2
    Configure UE    5g=kbk_plain:data    command=ue_pdu_session_setup    pdu=1    gw=1    ue=51
    Sleep    3
    Configure UE    5g=kbk_plain:data    command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    packets=100
    Configure UE    5g=kbk_plain:data    command=trf_data_start    ue=51    pdu=1    qfi=1    dir=ul    packets=75
    Sleep    90
    Configure UE    5g=kbk_plain:data    command=ue_pdu_session_release    ue=51    pdu=1
    Configure UE    5g=kbk_plain:data    command=ue_deregister    id=51    ue_deregister_type=switch_off
    ${GTP_eth3_capture}=    Traffic Capture Stop	mode=file	timeout=100
    ${GTP_packet_count}=    Analyse Pcap    pcap_filename=${GTP_eth3_capture}    analysis=Verify_GTP_packets
    Verify Pm Counters    analysis=failedSAEstablishments    counter_analysis_file=${counter_analysis_file}    pm_interval=5
    [Teardown]    Perform Recommissioning    type=param    param_path=IPSECP-1:extendedSequenceNumberMode    operation=update
    ...    value=NORMAL_SEQUENCE    timeout=300

Attach UE and send traffic
    Call Setup      5g=kbk_plain:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
    Sleep   100
    Configure UE    5G=kbk_plain:data        command=ue_register        id=51        profile=1
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=set_pdu_param        ue=51        pdu=1        trf_type=internal
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=ue_pdu_session_setup        pdu=1        gw=1         ue=51
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=1     protocol=udp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=2     protocol=tcp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=3     protocol=udp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=4     protocol=tcp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=5     protocol=udp    mbps=75
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=ul    trf_id=1     protocol=tcp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=ul    trf_id=2     protocol=udp    mbps=75

Stop SA Calls
    Configure UE    5G=kbk_plain:data        command=ue_pdu_session_release         ue=51        pdu=1
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_stop        ue=51        dir=dl
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_stop        ue=51        dir=ul
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=ue_deregister        id=51        ue_deregister_type=switch_off

Point A Traffic capture and verify
    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=True   timeout=120
    ...    alias=${pcap_1}
    sleep  360
    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=UL_Traffic_check1

Point B Traffic capture and verify for ESP Packets
    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=True   timeout=120
    ...    alias=${pcap_1}
    sleep   360
    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=ESP
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=ESP

Send Pre fragmented traffic and Verify traffic
    Perform Recommissioning     type=param  param_path=${Set_pre_fragmentation}    operation=update    value=Pre-fragmentation     timeout=300
    Verify BTS status   should_be_onair=${True}
   Configure UE    5G=kbk_plain:data        command=ue_register        id=51        profile=1
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=set_pdu_param        ue=51        pdu=1        trf_type=internal
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=ue_pdu_session_setup        pdu=1        gw=1         ue=51
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=1     protocol=udp    mbps=175
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=2     protocol=tcp    mbps=175
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=3     protocol=udp    mbps=175
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=4     protocol=tcp    mbps=175
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=5     protocol=udp    mbps=75
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=ul    trf_id=1     protocol=tcp    mbps=175
    ...    size=3000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=ul    trf_id=2     protocol=udp    mbps=75
    ...    size=3000
    Sleep   420
    Point A Traffic capture and verify      ${traffic_1}
    Point B Traffic capture and verify for ESP Packets    ${traffic_2}

Stop Traffic
    Configure UE    5G=kbk_plain:data        command=ue_pdu_session_release         ue=1        pdu=1
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_stop        ue=51        dir=dl
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_stop        ue=51        dir=ul
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=ue_deregister        id=51        ue_deregister_type=switch_off

Jumbo frame verification
    Run     sudo ip link set eth3 mtu 9000
    Run     sudo ip link set eth3.551 mtu 9000
    Configure UE       5g=kbk_plain:data     command=trf_data_start   ue=51    pdu=1    qfi=1   dir=ul     trf_id=1    mbps=175    size=9000
    Sleep   5
    Configure UE       5g=kbk_plain:data     command=trf_data_start   ue=51     pdu=1    qfi=1    dir=dl      trf_id=1    mbps=175   size=9000
    sleep       180
    Verify BTS status   should_be_onair=${True}
    Point A Traffic capture and verify      ${traffic_3}
    Point B Traffic capture and verify for ESP Packets      ${traffic_4}
    Run     sudo ip link set eth3 mtu 1500
    Run     sudo ip link set eth3.551 mtu 1500

Send Post fragmented traffic
    Send Post fragmented traffic and Verify traffic
    Sleep   60
    Stop Traffic
    Configure UE       5g=kbk_plain:data    command=trf_data_stop   ue=51

Send Post fragmented traffic and Verify traffic
    Perform Recommissioning     type=param  param_path=${Set_post_fragmentation}    operation=update    value=Post-fragmentation     timeout=300
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status
    Configure UE    5G=kbk_plain:data        command=ue_register        id=51        profile=1
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=set_pdu_param        ue=51        pdu=1        trf_type=internal
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=ue_pdu_session_setup        pdu=1        gw=1         ue=51
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=1     protocol=udp    mbps=175
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=2     protocol=tcp    mbps=175
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=3     protocol=udp    mbps=175
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=4     protocol=tcp    mbps=175
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=dl    trf_id=5     protocol=udp    mbps=75
    ...    size=2000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=ul    trf_id=1     protocol=tcp    mbps=175
    ...    size=3000
    Sleep   5
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=51    pdu=1    qfi=1    dir=ul    trf_id=2     protocol=udp    mbps=75
    ...    size=3000
    Sleep   420
    Point A Traffic capture and verify for post-fragmentation	${traffic_5}
    Point B Traffic capture and verify for ESP Packets for post-fragmentation	${traffic_6}
    Stop Traffic

Point A Traffic capture and verify for post-fragmentation
    [Arguments]     ${pcap_2}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=True   timeout=120
    ...    alias=${pcap_2}
    sleep  360

    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_2}      timeout=100

    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=UL_Traffic_check1

Point B Traffic capture and verify for ESP Packets for post-fragmentation

    [Arguments]     ${pcap_2}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=True   timeout=120
    ...    alias=${pcap_2}
    sleep   360
    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_2}      timeout=100
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=ESP
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=ESP