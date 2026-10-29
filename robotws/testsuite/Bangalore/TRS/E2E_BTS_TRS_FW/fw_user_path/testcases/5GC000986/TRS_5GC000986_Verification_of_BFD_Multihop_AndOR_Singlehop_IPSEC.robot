*** Settings ***
Documentation
    ...     [Procedure]             "The test case to verify BFD session on IPSEC setup"
    ...     [Date]                  "25-05-20"
    ...     [Author]                "Madhu Chinthakindi"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "FIPR","BFD","IPSEC"
    ...     [Feature_ID]            "5GC000986"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5G-9008"

Variables         ta_e2e_bts_trs_fw
Resource         ${CURDIR}/../resources/Common_BFD.robot
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Resource          ${CURDIR}/../resources/route_operations.robot
Library            random


Suite Setup              Setup Oamops	  dut=multihop_target_bts 	alias=remote
Suite Teardown           Teardown Oamops       alias=remote




*** Test Cases ***
[1]TRS_5GC000986_Verification_of_BFD_Multihop_AndOR_Singlehop_IPSEC
	[Documentation]		This test case verify BFD session with ipsec configuration
    Pre Conditions
    Verify Alarm    expected_alarms=${expected_alarms}
    Read BFD Details
    Verify BFD status and configurations
    Verify ipsec status
	[Teardown]		Remove Routes for Strongswan

*** Keywords ***
Pre Conditions
	Certificate Configure    operation=install_certificate    cert_file=${valid_ipsec_cert} 	cert_type=BtsTrustChain 	cert_format=P12
	...                      password=${valid_ipsec_cert_password}
	Perform Commissioning 	  timeout=600		verify_bts_status=False  	timeout=300
	Perform Commissioning    scf_file=${multihop_target_bts['scf_9035_multihop_target_bts']}    verify_bts_status=False	timeout=300    alias=remote
  	Sleep   900
    Add Routes for Strongswan

Verify BFD status and configurations
	Generate Esp Sa Key File		wireshark_host=wireshark_host
    Traffic Capture Start    capture_device=l2_wireshark    capture_filter=vlan and (${l2_capture_filter_ipv4_ips})    alias=VerifyBFDConfigurations
    Sleep       30
    ${pcap_name}=    Traffic Capture Stop    alias=VerifyBFDConfigurations
    Set Suite Variable       ${pcap_name}
    FOR    ${value}    IN    @{bfdindex_list}
        GetBFDDetails      ${value}
        VerifyBfdConfiguration        ${bfdAdminUpStatus}
    END
    [Teardown]    Run Keyword And Ignore Error         Traffic Capture Stop    alias=VerifyBFDConfigurations

Read BFD Details
    GetBFDCount
    Get_BFD_Src_IPs
    GetLocalTunnelIps

VerifyBfdConfiguration
   [Arguments]      ${AdminStatus}
   Run Keyword If     ${AdminStatus} == True    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BfdUpStatus
   ...                filter_file_name=${traffic_filer_file_name}
   Run Keyword If     ${AdminStatus} == False    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BfdDownStatus
   ...                 filter_file_name=${traffic_filer_file_name}
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=BfdDscp    filter_file_name=${traffic_filer_file_name}
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=udpport    filter_file_name=${traffic_filer_file_name}

Verify ipsec status
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=isakmp_req    filter_file_name=${traffic_filer_file_name}
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=isakmp_resp    filter_file_name=${traffic_filer_file_name}

GetLocalTunnelIps
	${traffic_capture_filter_ipv4}=	Create List
	@{ipObjects_dict_list} = 		Query Admin Infomodel		query=get list ${ipif_ipv4_a_moc_path}
	FOR    ${eachIP}    IN    @{ipObjects_dict_list}
		${localIpv4Addr}=	Get From Dictionary	dictionary=${eachIP}		key=localIpAddr
		Append To List	${traffic_capture_filter_ipv4}    ${localIpv4Addr}
    END

	${l2_capture_filter_ipv4_ips}=	Set Variable	host @{traffic_capture_filter_ipv4}[0]
	FOR    ${ipv4_address}    IN    @{traffic_capture_filter_ipv4}
		${l2_capture_filter_ipv4_ips}=	Set Variable	${l2_capture_filter_ipv4_ips} or host ${ipv4_address}
    END

	Set Suite Variable	${l2_capture_filter_ipv4_ips}	${l2_capture_filter_ipv4_ips}
