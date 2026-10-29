*** Settings ***
Documentation
...            [Author]         "Nandini R"

Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../../resources/Common_Ipsec_Rekeying.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot

*** Keywords ***
LTE739 Suite Setup precondition
	Pre-conditions for testsuite
	Perform Recommissioning     type=delta		delta_file=${LTE739_DualStack_SA_NSA_delta}     timeout=300
	Run     sudo cp ${SECGW_CONF} ${SECGW_BACKUP_COPY}
	Run		sudo cp ${SECGW_IPSEC_FILE} ${SECGW_CONF}

LTE739 Suite Teardown Postcondition
	Post-conditions for testteardown
    Run     sudo cp ${SECGW_BACKUP_COPY} ${SECGW_CONF}
    Run     sudo killall egate edaemon

Testcase precondition
	Enable Ipsec on SecureGW
	Enable Ipsec on Admin
	Verify IPSEC Security Association   ${Combination_1_Policy_List}
    Verify Ipsec Tunnels Status

Testcase postcondition
	Disable Ipsec on Admin
	Disable Ipsec on SecureGW

Check for No DPD Alarm
    Verify Alarm    faultid=${DPD_fault_ID}     should_exist=${False}

Pump ingress & egress High traffic
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...		timeout=120   alias=point_B
    Configure UE    5g=airphone_DualStack_sansa:data    command=set_pdu_param   ue=1    pdu=1   trf_type=internal
    Configure UE    5g=airphone_DualStack_sansa:data    command=ue_register      id=1     profile=1
    Sleep   2
    Configure UE    5g=airphone_DualStack_sansa:data    command=ue_pdu_session_setup     pdu=1  gw=1    ue=1
    Sleep   3
    Configure UE	5g=airphone_DualStack_sansa:data	command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=1	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=2	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=3	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=4	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=5	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa:data	command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=2	protocol=udp	mbps=75
    Sleep   30
    Configure UE    5g=airphone_DualStack_sansa:data    command=ue_pdu_session_release  ue=1    pdu=1
    Sleep   3
    Configure UE    5g=airphone_DualStack_sansa:data    command=ue_deregister   id=1    ue_deregister_type=switch_off
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B
    Set Suite Variable		${Point_B_Capture}
    Check for No DPD Alarm

Pump ingress & egress High traffic with high MTU
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...		timeout=120   alias=point_B_MTU
    Configure UE    5g=airphone_DualStack_sansa:data    command=set_pdu_param   ue=1    pdu=1   trf_type=internal
    Configure UE    5g=airphone_DualStack_sansa:data    command=ue_register      id=1     profile=1
    Sleep   2
    Configure UE	5g=airphone_DualStack_sansa:data    command=ue_pdu_session_setup     pdu=1  gw=1    ue=1
    Sleep   3
    Configure UE	5g=airphone_DualStack_sansa:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=1	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=2	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=3	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=4	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=5	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=2	protocol=udp	mbps=75	size=2000
    Sleep   30
    Configure UE    5g=airphone_DualStack_sansa:data    command=ue_pdu_session_release  ue=1    pdu=1
    Sleep   3
    Configure UE    5g=airphone_DualStack_sansa:data    command=ue_deregister   id=1    ue_deregister_type=switch_off
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_MTU
    Set Suite Variable        ${Point_B_Capture}
    Check for No DPD Alarm

Start Ingress&Egress High traffic
    Pump ingress & egress High traffic
	Verify if call is successful        ${Point_B_Capture}
    Pump ingress & egress High traffic with high MTU
	Verify if call is successful        ${Point_B_Capture}
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...		timeout=120   alias=point_B_Ping
    Run     ping -6 fc00::3:7 -I fc00::3:6 -s 500 -c 20
    Run     ping -6 fc00::3:7 -I fc00::3:6 -s 1800 -c 20
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_Ping

Verify if call is successful
    [Arguments]     ${pcap_file}
    Analyse pcap    pcap_filename=${pcap_file}      analysis=ESP_UL
    Analyse pcap    pcap_filename=${pcap_file}      analysis=ESP_DL

Verify if call is successful for ASOE
    [Arguments]     ${pcap_file}
    Analyse pcap    pcap_filename=${pcap_file}      analysis=ESP_UL_asoe
    Analyse pcap    pcap_filename=${pcap_file}      analysis=ESP_DL_asoe

Reboot enB And verify IPSEC connections
    Run     sudo killall egate edaemon
    Reset Bts   verify_bts=${False}
    Sleep   300s
    Verify IPSEC Security Association       ${Combination_1_Policy_List}

Create SA failure
	Perform Recommissioning		type=param		param_path=IPSECP-1:extendedSequenceNumberMode	operation=update	value=EXTENDED_SEQUENCE
	...		timeout=300
	Perform Recommissioning		type=param		param_path=IPSECP-1:saMaxLifeTime	operation=update	value=300		timeout=300

Remove SA Failure
    Perform Recommissioning     type=param	param_path=IPSECP-1:extendedSequenceNumberMode  operation=update    value=NORMAL_SEQUENCE	timeout=300

Create SA Failure and Verify failedSAEstablishments Counter
	Comment		Create Child tunnels failure by changing extendedSequenceNumberMode only on Enb.
	Create SA failure
	Pm Counters Start		analysis=failedSAEstablishments		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Traffic Capture Start	capture_device=vm_eth3_interface
	Configure UE    5g=airphone_DualStack_sansa:data	command=set_pdu_param	ue=1	pdu=1	trf_type=internal
	Configure UE    5g=airphone_DualStack_sansa:data	command=ue_register		id=1	profile=1
	Sleep   2
	Configure UE    5g=airphone_DualStack_sansa:data	command=ue_pdu_session_setup	pdu=1	gw=1	ue=1
	Sleep   3
	Configure UE    5g=airphone_DualStack_sansa:data	command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl  packets=1000
	Configure UE    5g=airphone_DualStack_sansa:data	command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul  packets=1000
	Sleep	90
	Configure UE	5g=airphone_DualStack_sansa:data	command=ue_pdu_session_release	ue=1	pdu=1
	Configure UE    5g=airphone_DualStack_sansa:data	command=ue_deregister	id=1	ue_deregister_type=switch_off
	${GTP_eth3_capture}=   Traffic Capture Stop
	${GTP_packet_count}=	Analyse Pcap	pcap_filename=${GTP_eth3_capture}	analysis=Verify_GTP_packets
	Verify Pm Counters		analysis=failedSAEstablishments		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	[Teardown]	Perform Recommissioning		type=param		param_path=IPSECP-1:extendedSequenceNumberMode	operation=update	value=NORMAL_SEQUENCE
	...		timeout=300

Send Traffic and Verify SentESP and ReceivedESP Counter
	${Index}=	Evaluate    random.choice(range(0, ${IPv4_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 1
	Set Suite Variable		${secpol_index}		${secpol_index}
	Pm Counters Start		analysis=Send_and_Rcv_ESP_Counter		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -I 10.0.1.1 ${IPv4_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=Send_and_Rcv_ESP_Counter		counter_analysis_file=${counter_analysis_file}		pm_interval=5

	${Index}=	Evaluate    random.choice(range(0, ${IPv6_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 7
	Set Suite Variable		${secpol_index}		${secpol_index}
	Pm Counters Start		analysis=Send_and_Rcv_ESP_Counter		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -6 -I fc00::1 ${IPv6_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=Send_and_Rcv_ESP_Counter		counter_analysis_file=${counter_analysis_file}		pm_interval=5

Duplicate and reorder downlink traffic and Verify AntiReplayErrors Counter
	${Index}=	Evaluate    random.choice(range(0, ${IPv4_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 1
	Set Suite Variable		${secpol_index}		${secpol_index}
	Pm Counters Start		analysis=antiReplayErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Comment     Duplicate and reorder downlink traffic
	Run     sudo tc qdisc add dev eth3 root netem duplicate 100% delay 100ms reorder 100%
	Run		ping -I 10.0.1.1 ${IPv4_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=antiReplayErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5

	${Index}=	Evaluate    random.choice(range(0, ${IPv6_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 7
	Set Suite Variable		${secpol_index}		${secpol_index}
	Pm Counters Start		analysis=antiReplayErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -6 -I fc00::1 ${IPv6_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=antiReplayErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	[Teardown]		Run     sudo tc qdisc del dev eth3 root netem duplicate 100% delay 100ms reorder 100%

Corrupt ESP packets sent to eNB and Verify espCryptographicErrors Counter
	Comment		Corrupt ESP packets sent to eNB
	Run     sudo tc qdisc add dev eth3 root netem corrupt 30%
	${Index}=	Evaluate    random.choice(range(0, ${IPv4_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 1
	Set Suite Variable		${secpol_index}		${secpol_index}
	Pm Counters Start		analysis=espCryptographicErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -I 10.0.1.1 ${IPv4_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=espCryptographicErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5

	${Index}=	Evaluate    random.choice(range(0, ${IPv6_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 7
	Set Suite Variable		${secpol_index}		${secpol_index}
	Pm Counters Start		analysis=espCryptographicErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -6 -I fc00::1 ${IPv6_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=espCryptographicErrors		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	[Teardown]		Run     sudo tc qdisc del dev eth3 root netem corrupt 30%

Start Ping test from Enb for Unconfigured IP and Verify sentPacketMatchDefPol counter
	Run		sudo ip addr add 10.0.1.10/24 brd 10.0.1.255 dev eth3
	${Index}=	Evaluate    random.choice(range(0, ${IPv4_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 1
	Set Suite Variable		${secpol_index}		${secpol_index}
	Pm Counters Start		analysis=sent_and_Rcv_PacketMatchDefPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -I 10.0.1.10 ${IPv4_Application_IP_List}[${Index}] -c ${Ping_Packet_Count} 1>/dev/null &
	Execute command on ENodeB		ping 10.0.1.10 -I ${IPv4_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	${Index}=	Evaluate    random.choice(range(0, ${IPv6_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 7
	Set Suite Variable		${secpol_index}		${secpol_index}
	Run		ping -6 -I 10.0.1.10 ${IPv6_Application_IP_List}[${Index}] -c ${Ping_Packet_Count} 1>/dev/null &
	Execute command on ENodeB		ping 10.0.1.10 -I ${IPv6_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=sent_and_Rcv_PacketMatchDefPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5

Verify ipsecSaNotFound and recvUnprotPacketMatchProtPol counter
    Pm Counters Start	analysis=ipsecSaNotFound_and_recvUnprotPacketMatchProtPol	counter_analysis_file=${counter_analysis_file}	pm_interval=5
	Comment		Send ESP with different SPI to verify ipsecSaNotFound counter
    FOR    ${Index}    IN RANGE    0   ${IPv4_IP_Count}
		${stdout}=		Run		expect ${CURDIR}/Send_ESP_Packets.exp IPv4 ${IPv4_Application_IP_List}[${Index}] 10
	END
    FOR    ${Index}    IN RANGE    0   ${IPv6_IP_Count}
		${stdout}=      Run     expect ${CURDIR}/Send_ESP_Packets.exp IPv6 ${IPv6_Application_IP_List}[${Index}] 10
	END
	${ESP_Count}=		Evaluate	(${IPv4_IP_Count}+${IPv6_IP_Count})*10
    Set Suite Variable      ${ESP_Count}        ${ESP_Count}

	Comment		Send Unencrypted packets to verify recvUnprotPacketMatchProtPol counter
	${stdout}=		Run
	...		expect Send_UDP_TCP_SCTP_packets.exp IPv4 ${IPv4_Application_IP_List}[0] ${IPv4_Application_IP_List}[1] ${IPv4_Application_IP_List}[2] 10
	${stdout}=		Run
	...		expect Send_UDP_TCP_SCTP_packets.exp IPv6 ${IPv6_Application_IP_List}[0] ${IPv6_Application_IP_List}[1] ${IPv6_Application_IP_List}[2] 10
    Set Suite Variable      ${Unprotect_Count}        60
    Verify Pm Counters	analysis=ipsecSaNotFound_and_recvUnprotPacketMatchProtPol	counter_analysis_file=${counter_analysis_file}	pm_interval=5

Create Discard Policy and Verify setPacketMatchDiscPol and receivedPacketMatchDiscPol Counter
	${Index}=	Evaluate    random.choice(range(0, ${IPv4_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 1
	Perform Recommissioning		type=param		param_path=SECPOL-${secpol_index}:ipSecAction	operation=update	value=DISCARD		timeout=300
    ${IPv6_Index}=   Evaluate    random.choice(range(0, ${IPv6_IP_Count}))  random
    ${secpol_index}=    Evaluate    ${IPv6_Index} + 7
    Perform Recommissioning     type=param      param_path=SECPOL-${secpol_index}:ipSecAction   operation=update    value=DISCARD       timeout=300

	Pm Counters Start		analysis=sent_and_received_PacketMatchDiscPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -I 10.0.1.1 ${IPv4_Application_IP_List}[${Index}] -c ${Ping_Packet_Count} 1>/dev/null &
	Execute command on ENodeB		ping 10.0.1.1 -I ${IPv4_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	Run		ping -6 -I fc00::1 ${IPv6_Application_IP_List}[${IPv6_Index}] -c ${Ping_Packet_Count} 1>/dev/null &
	Execute command on ENodeB		ping -6 fc00::1 -I ${IPv6_Application_IP_List}[${IPv6_Index}] -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=sent_and_received_PacketMatchDiscPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5

Create Discard Policy and Verify setPacketMatchBypassPol and receivedPacketMatchBypassPol Counter
	${Index}=	Evaluate    random.choice(range(0, ${IPv4_IP_Count}))  random
	${secpol_index}=	Evaluate	${Index} + 1
	Perform Recommissioning		type=param		param_path=SECPOL-${secpol_index}:ipSecAction	operation=update	value=BYPASS		timeout=300
    ${IPv6_Index}=   Evaluate    random.choice(range(0, ${IPv6_IP_Count}))  random
    ${secpol_index}=    Evaluate    ${IPv6_Index} + 7
    Perform Recommissioning     type=param      param_path=SECPOL-${secpol_index}:ipSecAction   operation=update    value=BYPASS       timeout=300

	Pm Counters Start		analysis=sent_and_received_PacketMatchBypassPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Run		ping -I 10.0.1.1 ${IPv4_Application_IP_List}[${Index}] -c ${Ping_Packet_Count} 1>/dev/null &
	Execute command on ENodeB		ping 10.0.1.1 -I ${IPv4_Application_IP_List}[${Index}] -c ${Ping_Packet_Count}
	Run		ping -6 -I fc00::1 ${IPv6_Application_IP_List}[${IPv6_Index}] -c ${Ping_Packet_Count} 1>/dev/null &
	Execute command on ENodeB		ping -6 fc00::1 -I ${IPv6_Application_IP_List}[${IPv6_Index}] -c ${Ping_Packet_Count}
	Verify Pm Counters		analysis=sent_and_received_PacketMatchBypassPol		counter_analysis_file=${counter_analysis_file}		pm_interval=5

Pump ingress & egress High traffic for combination 2
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...		timeout=120   alias=point_B
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=set_pdu_param   ue=1    pdu=1   trf_type=internal
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=ue_register      id=1     profile=1
    Sleep   2
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=ue_pdu_session_setup     pdu=1  gw=1    ue=1
    Sleep   3
    Configure UE	5g=airphone_DualStack_sansa_asoe:data	command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=1	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=2	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=3	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=4	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=5	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa_asoe:data	command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	protocol=udp	mbps=175
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=2	protocol=udp	mbps=75
    Sleep   30
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=ue_pdu_session_release  ue=1    pdu=1
    Sleep   3
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=ue_deregister   id=1    ue_deregister_type=switch_off
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B
    Verify if call is successful for        ${Point_B_Capture}
    Check for No DPD Alarm

Pump ingress & egress High traffic with high MTU for combination 2
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...		timeout=120   alias=point_B_MTU
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=set_pdu_param   ue=1    pdu=1   trf_type=internal
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=ue_register      id=1     profile=1
    Sleep   2
    Configure UE	5g=airphone_DualStack_sansa_asoe:data    command=ue_pdu_session_setup     pdu=1  gw=1    ue=1
    Sleep   3
    Configure UE	5g=airphone_DualStack_sansa_asoe:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=1	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa_asoe:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=2	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa_asoe:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=3	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa_asoe:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=4	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa_asoe:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	trf_id=5	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa_asoe:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	protocol=udp	mbps=175	size=2000
    Configure UE    5g=airphone_DualStack_sansa_asoe:data
	...		command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=2	protocol=udp	mbps=75	size=2000
    Sleep   30
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=ue_pdu_session_release  ue=1    pdu=1
    Sleep   3
    Configure UE    5g=airphone_DualStack_sansa_asoe:data    command=ue_deregister   id=1    ue_deregister_type=switch_off
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_MTU
    Verify if call is successful for        ${Point_B_Capture}
    Check for No DPD Alarm

Verify if call is successful for
    [Arguments]     ${pcap_file}
    Analyse pcap    pcap_filename=${pcap_file}      analysis=ESP_UL_asoe
    Analyse pcap    pcap_filename=${pcap_file}      analysis=ESP_DL_asoe

Reboot And verify IPSEC connections
    Run     sudo killall egate edaemon
    Reset Bts   verify_bts=${False}
    Sleep   300s
    Verify IPSEC Security Association       ${Combination_2_Policy_List}