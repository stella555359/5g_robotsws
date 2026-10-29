*** Settings ***
Documentation
...		[Author]     	"Ruchika"
variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
#Resource        packet_generation_verification_common_keywords.robot
Library    taf.sw.scout    WITH NAME    scout

*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***
Disable Ipsec on Strongswan
    Setup Remote Access    remote_device=secure_gateway
    ${stdout}       Remote Command Execute      command=sudo ipsec stop
    #Should not Be Empty     ${stdout}
    Teardown remote Access

Enable Ipsec on Strongswan
    Setup Remote Access    remote_device=secure_gateway
    ${stdout}       Remote Command Execute      command=sudo ipsec start
    #Should not Be Empty     ${stdout}
    Teardown remote Access

Verify Ipsec Tunnels Status from Webem
    @{ike_peer_moc_list} =      Query Admin Infomodel    query=get list ${ike_peer_moc_path}
    FOR    ${ike_peer}    IN       @{ike_peer_moc_list}
         ${ike_peer_state}=      Get From Dictionary    dictionary=${ike_peer}    key=ikePeerState
         Should Be True    '${ike_peer_state}'=='ESTABLISHED'
    END


Preconditions for IPSec
	Certificate Configure	operation=install_certificate	cert_file=${valid_ipsec_cert}
    ...     cert_type=BtsTrustChain	cert_format=P12	password=${valid_ipsec_cert_password}
	Add Routes for Strongswan			### to be part of resource file
	Perform Commissioning		timeout=600
	Sleep	60

ICMP Capture
	[Arguments]	   ${ip}
    Log       ${ip}
	${mplane_ip}=	Get parameter     param_path=MPLANENW-1:mPlaneIpv4AddressDN:localIpAddr
	Set Suite Variable	${mplane_ip}	${mplane_ip}
	Traffic Capture Start	capture_device=l2_wireshark	capture_filter=vlan and (host ${mplane_ip})
	Sleep	60
	${s1trace}=	Traffic Capture Stop
	Set Suite Variable		${s1trace}	${s1trace}

ICMP Capture pingtimer
	[Arguments]	   ${ip}
    Log       ${ip}
	${mplane_ip}=	Get parameter     param_path=MPLANENW-1:mPlaneIpv4AddressDN:localIpAddr
	Set Suite Variable	${mplane_ip}	${mplane_ip}
	Traffic Capture Start        capture_device=oam_device    mode=file    measurement_point=NE_Terminated	uplane_capturing=${True}
	Sleep	300
	${s2trace}=	Traffic Capture Stop	mode=file
	Set Suite Variable		${s2trace}	${s2trace}


Verify Emergency Bypass Policy
	[Arguments]		${ip}
    Log       ${ip}
	Setup Enb Fsm Access
	${output}=	Execute Command On Enb	ip x p
	Teardown Enb Fsm Access
	Convert To List		${output}
	Log List	${output}
	Should Contain	 	${output}	${dummyIp}

Check Ping Retrytimer
    [Arguments]     ${timer}
    ${pcap_list}=   Analyse Pcap    pcap_filename=${s2trace}     analysis=verify_time_interval  filter_file_name=${filter_file}
    Set Suite Variable       ${pcap_list}
    ${count}=      Get Length      ${pcap_list}
    ${end}=     Evaluate    ${count}-1
    FOR    ${time}  IN RANGE    0   ${end}
        ${value}=    Set Variable     ${pcap_list}[${time}]
        ${curr_pack_info}=  Get From Dictionary     ${value}      frame.time
        ${t}    ${curr_pack_time}   ${rem}      Split String From Right      ${curr_pack_info}[0]    max_split=2
        ${time_1}=      Evaluate      ${time}+1
        ${next_value}=      Set Variable      ${pcap_list}[${time_1}]
        ${next_pack_info}=  Get From Dictionary       ${next_value}     frame.time
        ${t}   ${next_pack_time}     ${rem}     Split String From Right    ${next_pack_info}[0]   max_split=2
        ${time_diff}=   Subtract time from time      ${next_pack_time}     ${curr_pack_time}    exclude_millis=True
        Should Be True     ${time_diff}==${timer}
    END