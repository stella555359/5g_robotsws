*** Settings ***
Documentation
...	[Author]	"Ankita"


#Resource   setup/framework.robot
#Resource  testcases/resources/route_operations.robot
#Resource  testcases/resources/common_keywords.robot
Resource   ${CURDIR}/../resources/route_operations.robot
Resource   ${CURDIR}/../resources/common_keywords.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

#Force Tags    CA_E2ET_BTSTRSPZ        SBTS00	SBTS21A        SBTS20C   4G_FDD     QCD_MN_SRAN        QCP_SRAN_SBTS        CIT
Force Tags    CA_E2ET_BTSTRSPZ        SBTS00   SBTS21B        SBTS22R1    SBTS22R2    4G_FDD     QCD_MN_RAN    QCP_RAN_VRF      CIT

*** Variables ***
${Internal_mac_address}=	Run 	ifconfig -a | grep eth1 | awk '/HWaddr/ {print $5}'


*** Test Cases ***
#[1]SBTS_Transport_Network_scenario_Ipv4Ipv6_VirtualIp_Concurrent_tunnel_EIF2
[1.0] SBTS_Transport_Network_scenario_Ipv4Ipv6_VirtualIp_Concurrent_tunnel_EIF2

    Pre Conditions
	Perform Commissioning	timeout=900     verify_bts_status=True
#Unexpected alarms
    Sleep   300
	Verify Alarm    expected_alarms=${expected_alarms}
#	Pm Counters Start	analysis=verify_ethernet_counters_multiip		counter_analysis_file=${counter_analysis_file_name}
#	DPD Validation
#a	Verify Ipsec Tunnels Status
#a	Generate Esp Sa Key File	wireshark_host=wireshark_host
#	Lte IPv6 Call
#	Wcdma And Gsm Call
#u	Dual Stack For Mplane
#Snapshot
#Unexpected alarms
#u	Verify Alarm    expected_alarms=${expected_alarms}
#Snapshot
#u        ${snap}=        Collect Snapshot        timeout=1200
#anki	[Teardown]	Post Conditions


*** Keywords ***

Pre Conditions
	Certificate Configure    operation=install_certificate    cert_file=${valid_ipsec_cert} 	cert_type=BtsTrustChain
 	...		cert_format=P12 	password=${valid_ipsec_cert_password}
	Add Routes for Strongswan

Post Conditions
	Remove Routes for Strongswan
#a	Ipsec Enable	source=secure_gw	device=secure_gw_name1

DPD Validation
	${dpdDelay}=	Get Parameter	param_path=IKEP-1:dpdDelay
#	Ipsec Disable	source=secure_gw	device=secure_gw_name1
	Configure Switch	device=l2_switch		command_profile=disable_ports
	Wait Until Keyword Succeeds	100 sec	5 sec	Verify Alarm	faultid=${dpdFaultId}	occurrences=${4}
#	Ipsec Enable	source=secure_gw	device=secure_gw_name1
	Configure Switch	device=l2_switch		command_profile=enable_ports
	Sleep	76
	Verify Ipsec Tunnels Status
	${dpdDelay_max_sleep}=	Evaluate	${dpdDelay}+10
	Sleep	${dpdDelay_max_sleep}
#	Verify Alarm	faultid=${dpdFaultId}	should_exist=${False}
	[Teardown]	Run Keyword And Ignore Error	Configure Switch	device=l2_switch		command_profile=enable_ports

Verify Ipsec Tunnels Status
	@{parent_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ike_sa_l_moc_path}
	:FOR 	${ike_tunnel}	IN 	@{parent_tunnel_moc_list}
	\	${parent_tunnel_stateInfo}=	Get From Dictionary		dictionary=${ike_tunnel}		key=stateInfo
	\	${parent_tunnel_proceduralState}=	Get From Dictionary	dictionary=${parent_tunnel_stateInfo}	key=proceduralState
	\	Should Be True	'${parent_tunnel_proceduralState}'=='Established'

	@{child_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ipsec_sa_l_moc_path}
	:FOR 	${child_tunnel}	IN 	@{child_tunnel_moc_list}
	\	${child_tunnel_stateInfo}=	Get From Dictionary	dictionary=${child_tunnel}		key=stateInfo
	\	${child_tunnel_proceduralState}=	Get From Dictionary	dictionary=${child_tunnel_stateInfo}	key=proceduralState
	\	Should Be True	'${child_tunnel_proceduralState}'=='Installed'

Dual Stack For Mplane
#s	Login Via V6 Ip
	Login Via V4 Ip

Login Via V6 Ip
	${mplaneV6}=	Get parameter     param_path=${mplanev6_path}
	Setup Oamops	bts_host=${mplaneV6}			timeout=900		alias=mplaneV6
	Traffic Capture Start        capture_device=oam_device_mplanev6    mode=file 	measurement_point=NE_Terminated
	uplane_capturing=False  	timeout=120	  alias=mplaneV6
    Sleep    10
	Traffic Capture Stop   mode=file  alias=mplaneV6  timeout=120
	Teardown Oamops		alias=mplaneV6

Login Via V4 Ip
	${mplane}=	Get parameter     param_path=${mplane_path}
	Setup Oamops	bts_host=${mplane}			timeout=120		alias=mplane
	Traffic Capture Start        capture_device=oam_device_mplane    mode=file  measurement_point=Transport_Interface
	uplane_capturing=True  timeout=120  alias=mplane
	Traffic Capture Stop   mode=file  alias=mplane  timeout=120
	Teardown Oamops		alias=mplane

Validate Snapshot
        [Arguments]             ${snap}
        Run     unzip -o ${snap} -d Sample/
        ${ext_location}=        Run     cat Sample/snapshot_file_list.txt | grep -B 1000 Exte | grep -e "zip:" | tail -1 | awk -F ':' '{print $1}'
        Run     unzip -o Sample/${ext_location} -d Sample/
        ${ExtendedNezip}=       Run     find . -name *Extended*.txz
        Run     xz -d ${ExtendedNezip}
        ${ExtendedNeziptar}=    Run     find . -name *Extended*.tar
	${ext_content}=		Run     tar xvf ${ExtendedNeziptar} -C Sample/
        log     ${mandatoryfiles}
        :FOR    ${ELEMENT}    IN    @{mandatoryfiles}
        \       Should Match Regexp     ${ext_content}  ${ELEMENT}


Lte IPv6 Call
	Call Setup      lte=device_1:data      parallel=${True}	ipv4_or_6=ipv6
	Call Start      lte=device_1:data       profile=udp_ul	iperf_device=ipv6_server
        Call Start      lte=device_1:data       profile=udp_dl	iperf_device=ipv6_server
	Sleep   30
	Run Keyword And Ignore Error	Call Stop       lte=device_1:data       profile=udp_ul	iperf_device=ipv6_server
        Run Keyword And Ignore Error	Call Stop       lte=device_1:data       profile=udp_dl	iperf_device=ipv6_server

Wcdma And Gsm Call
#	Call Setup	wcdma=device_1:voice     gsm=device_1:voice      parallel=${True}
 #       Call Start      wcdma=device_1:voice
        Call Start      gsm=device_1:voice
        Sleep   30
  #      Call Stop       wcdma=device_1:voice
        Call Stop       gsm=device_1:voice
#Suite Teardown Postconditions
#        Run Keyword And Ignore Error    Setup Oamops
#        Collect Im Snapshot     timeout=300
#        Collect Snapshot        timeout=1200
#        [Teardown]        Stop Syslog       alias=collect_syslog
